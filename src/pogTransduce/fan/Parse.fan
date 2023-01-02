//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   13 Aug 2022  Brian Frank  Creation
//

using util
using pog

**
** Parse transducer
**
@Js
const class ParseTransducer : Transducer
{
  new make(PogEnv env) : super(env, "parse") {}

  override Str summary()
  {
    "Parse pog source into JSON AST"
  }

  override Str usage()
  {
    """parse file              Convenience for read:file
       parse read:             Parse from prompt
       parse read:file         Parse file into JSON
       parse dir:file          Parse all pog files in directory
       """
  }

  override TransduceData transduce(Str:TransduceData args)
  {
    cx := TransduceContext(this, args)

    input := cx.arg("dir", false)
    if (input != null) return parseDir(cx, input)

    input = cx.arg("it")
    return input.withInStream |in|
    {
      toAstResult(cx, input, parse(cx, input.loc, in, Parser.newMap))
    }
  }

  private TransduceData parseDir(TransduceContext cx, TransduceData input)
  {
    dir := input.get as File ?: throw ArgErr("Expecting dir to be File, not ${input.get.typeof}")
    files := dir.list.findAll { it.ext == "pog" }
    if (files.isEmpty) throw ArgErr("No pog files in dir [$dir.osPath]")
    files = files.sort |a, b| { a.name <=> b.name }

    loc := FileLoc(dir)
    ast := Parser.newMap
    files.each |file|
    {
      parse(cx, FileLoc(file), file.in, ast)
    }
    return toAstResult(cx, input, ast)
  }

  private Obj? parse(TransduceContext cx, FileLoc loc, InStream in, Str:Obj root)
  {
    try
    {
      return Parser(loc, in).parse(root)
    }
    catch (FileLocErr e)
    {
      cx.err(e.msg, e.loc)
    }
    catch (Err e)
    {
      cx.err(e.toStr, loc, e)
    }
    return root
  }

  private TransduceData toAstResult(TransduceContext cx, TransduceData input, Str:Obj? ast)
  {
    cx.toResult(ast, ["json", "ast", "unresolved"], input.loc)
  }

}

**************************************************************************
** Parser
**************************************************************************

@Js
internal class Parser
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(FileLoc fileLoc, InStream in)
  {
    this.fileLoc = fileLoc
    this.tokenizer = Tokenizer(in) { it.keepComments = true }
    this.cur = this.peek = Token.eof
    consume
    consume
  }

//////////////////////////////////////////////////////////////////////////
// Public
//////////////////////////////////////////////////////////////////////////

  Str:Obj parse(Str:Obj root)
  {
    try
    {
      parseProtos(ParsedProto(curToLoc) { it.map = root } , false)
      verify(Token.eof)
      return root
    }
    catch (ParseErr e)
    {
      throw err(e.msg, curToLoc)
    }
    finally
    {
      tokenizer.close
    }
  }

//////////////////////////////////////////////////////////////////////////
// Parsing
//////////////////////////////////////////////////////////////////////////

  private Void parseProtos(ParsedProto parent, Bool isMeta)
  {
    while (true)
    {
      child := parseProto
      if (child == null) break
      parseEndOfProto
      addToParent(parent, child, isMeta)
    }
  }

  private ParsedProto? parseProto()
  {
    // leading comment
    doc := parseLeadingDoc

    // end of file or closing symbols
    if (cur === Token.eof) return null
    if (cur === Token.rbrace) return null
    if (cur === Token.gt) return null

    // this token is start of our proto production
    p := ParsedProto(curToLoc)
    p.doc = doc

    // <markerOnly> | <named> | <unnamed>
    if (cur === Token.id && peek === Token.colon)
    {
      p.name = consumeName
      consume(Token.colon)
      parseBody(p)
    }
    else if (cur === Token.id && curVal.toStr[0].isLower && peek !== Token.dot)
    {
      p.name = consumeName
      p.map = isMarker
    }
    else
    {
      parseBody(p)
    }

    // trailing comment
    parseTrailingDoc(p)

    return p
  }

  private Void parseBody(ParsedProto p)
  {
    a := parseIs(p)
    b := parseMeta(p)
    c := parseChildrenOrVal(p)
    if (!a && !b && !c) throw err("Expecting proto body not $curToStr")
  }

  private Bool parseMeta(ParsedProto p)
  {
    if (cur !== Token.lt) return false
    parseChildren(p, Token.lt, Token.gt, true)
    return true
  }

  private Bool parseChildrenOrVal(ParsedProto p)
  {
    if (cur === Token.lbrace) return parseChildren(p, Token.lbrace, Token.rbrace, false)
    if (cur.isVal) return parseVal(p)
    return false
  }

  private Bool parseChildren(ParsedProto p, Token open, Token close, Bool isMeta)
  {
    consume(open)
    skipNewlines
    parseProtos(p, isMeta)
    while (cur !== close)
    {
      if (cur === Token.eof) throw err("Unexpected end of file, missing closing $close")
      parseProtos(p, isMeta)
    }
    consume(close)
    return true
  }

  private Bool parseVal(ParsedProto p)
  {
    p.map.add("_val", curVal)
    consume
    return true
  }

  private Bool parseIs(ParsedProto p)
  {
    if (cur === Token.str && peek === Token.pipe)
      return parseIsOr(p, null, consumeVal)

    if (cur !== Token.id) return false

    qname := consumeQName
    if (cur === Token.amp)      return parseIsAnd(p, qname)
    if (cur === Token.pipe)     return parseIsOr(p, qname, null)
    if (cur === Token.question) return parseIsMaybe(p, qname)

    p.map["_is"] = qname
    return true
  }

  private Bool parseIsAnd(ParsedProto p, Str qname)
  {
    of := newMap
    addToOf(of, qname, null)
    while (cur === Token.amp)
    {
      consume
      skipNewlines
      addToOf(of, parseIsSimple("Expecting next proto name after '&' and symbol"), null)
    }
    p.map["_is"] = "sys.And"
    p.map["_of"] = of
    return true
  }

  private Bool parseIsOr(ParsedProto p, Str? qname, Str? val)
  {
    of := newMap
    addToOf(of, qname, val)
    while (cur === Token.pipe)
    {
      consume
      skipNewlines
      if (cur.isVal)
        addToOf(of, null, consumeVal)
      else
        addToOf(of, parseIsSimple("Expecting next proto name after '|' or symbol"), null)
    }
    p.map["_is"] = "sys.Or"
    p.map["_of"] = of
    return true
  }

  private Bool parseIsMaybe(ParsedProto p, Str qname)
  {
    consume(Token.question)
    p.map["_is"] = "sys.Maybe"
    p.map["_of"] = ["_is":qname]
    return true
  }

  private Str parseIsSimple(Str errMsg)
  {
    if (cur !== Token.id) throw err(errMsg)
    return consumeQName
  }

  private Void addToOf(Str:Obj of, Str? qname, Str? val)
  {
    of["_"+of.size] = Str:Obj[:].addNotNull("_is", qname).addNotNull("_val", val)
  }

  private Void parseEndOfProto()
  {
    if (cur === Token.comma)
    {
      consume
      skipNewlines
      return
    }

    if (cur === Token.nl)
    {
      skipNewlines
      return
    }

    if (cur === Token.rbrace) return
    if (cur === Token.gt) return
    if (cur === Token.eof) return

    throw err("Expecting end of proto: comma or newline, not $curToStr")
  }

//////////////////////////////////////////////////////////////////////////
// AST Manipulation
//////////////////////////////////////////////////////////////////////////

  private Void addToParent(ParsedProto parent, ParsedProto child, Bool isMeta)
  {
    addDoc(child)
    addLoc(child)
    name := child.name
    if (name == null)
    {
      name = autoName(parent)
    }
    else
    {
      if (isMeta)
      {
        if (name == "is") throw err("Proto name 'is' is reserved", child.loc)
        if (name == "val") throw err("Proto name 'val' is reserved", child.loc)
        name = "_" + name
      }
      if (parent.map[name] != null) throw err("Duplicate names '$name'", child.loc)
    }
    parent.map.add(name, child.map)
  }

  private Void addDoc(ParsedProto p)
  {
    if (p.doc == null) return
    if (p.map.isRO) p.map = p.map.dup
    p.map["_doc"] = ["_is":"sys.Str", "_val":p.doc]
  }

  private Void addLoc(ParsedProto p)
  {
    if (fileLoc === FileLoc.unknown) return
    if (p.map.isRO) p.map = p.map.dup
    p.map["_loc"] = ["_is":"sys.Str", "_val":p.loc]
  }

  private Str autoName(ParsedProto parent)
  {
    map := parent.map
    for (i := 0; i<1_000_000; ++i)
    {
      name := "_" + i.toStr
      if (map[name] == null) return name
    }
    throw err("Too many children", parent.loc)
  }

  static Str:Obj newMap()
  {
    map := Str:Obj[:]
    map.ordered = true
    return map
  }

//////////////////////////////////////////////////////////////////////////
// Doc
//////////////////////////////////////////////////////////////////////////

  private Str? parseLeadingDoc()
  {
    Str? doc := null
    while (true)
    {
      // skip leading blank lines
      skipNewlines

      // if not a comment, then return null
      if (cur !== Token.comment) return null

      // parse one or more lines of comments
      s := StrBuf()
      while (cur === Token.comment)
      {
        s.join(curVal.toStr, "\n")
        consume
        consume(Token.nl)
      }

      // if there is a blank line after comments, then
      // this comment does not apply to next production
      if (cur === Token.nl) continue

      // use this comment as our doc
      doc = s.toStr.trimToNull
      break
    }
    return doc
  }

  private Void parseTrailingDoc(ParsedProto p)
  {
    if (cur === Token.comment)
    {
      // leading trumps trailing
      if (p.doc == null) p.doc = curVal.toStr.trimToNull
      consume
    }
  }

//////////////////////////////////////////////////////////////////////////
// Char Reads
//////////////////////////////////////////////////////////////////////////

  private Bool skipNewlines()
  {
    if (cur !== Token.nl) return false
    while (cur === Token.nl) consume
    return true
  }

  private Void verify(Token expected)
  {
    if (cur !== expected) throw err("Expected $expected not $curToStr")
  }

  private FileLoc curToLoc()
  {
    FileLoc(fileLoc.file, curLine, curCol)
  }

  private Str curToStr()
  {
    curVal != null ? "$cur $curVal.toStr.toCode" : cur.toStr
  }

  private Str consumeQName()
  {
    qname := consumeName
    while (cur === Token.dot)
    {
      consume
      qname += "." + consumeName
    }
    return qname
  }

  private Str consumeName()
  {
    verify(Token.id)
    name := curVal.toStr
    consume
    return name
  }

  private Str consumeVal()
  {
    verify(Token.str)
    val := curVal
    consume
    return val
  }

  private Void consume(Token? expected := null)
  {
    if (expected != null) verify(expected)

    cur      = peek
    curVal   = peekVal
    curLine  = peekLine
    curCol   = peekCol

    peek     = tokenizer.next
    peekVal  = tokenizer.val
    peekLine = tokenizer.line
    peekCol  = tokenizer.col
  }

  private Err err(Str msg, FileLoc loc := curToLoc)
  {
    FileLocErr(msg, loc)
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  static const Str:Obj isMarker := ["_is":"sys.Marker"]

  Bool includeLoc

  private FileLoc fileLoc
  private Tokenizer tokenizer

  private Token cur      // current token
  private Obj? curVal    // current token value
  private Int curLine    // current token line number
  private Int curCol     // current token col number

  private Token peek     // next token
  private Obj? peekVal   // next token value
  private Int peekLine   // next token line number
  private Int peekCol    // next token col number
}

**************************************************************************
** ParsedProto
**************************************************************************

@Js
internal class ParsedProto
{
  new make(FileLoc loc)
  {
    this.loc = loc
    this.map = Parser.newMap
  }

  const FileLoc loc
  Str? doc
  Str? name
  Str:Obj map
}

**************************************************************************
** Tokenizer
**************************************************************************

@Js
internal class Tokenizer
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(InStream in)
  {
    this.in  = in
    this.tok = Token.eof
    consume
    consume
  }

//////////////////////////////////////////////////////////////////////////
// Tokenizing
//////////////////////////////////////////////////////////////////////////

  ** Current token type
  Token tok

  ** Current token value based on type:
  **  - id: identifier string
  **  - literals: the literal value
  **  - comment: comment line if keepComments set
  **  - ParseErr: the error message
  Obj? val

  ** One based line number for current token
  Int line := 1

  ** One based column number for current token
  Int col := 1

  ** Tokenize and return slash-slash comments
  Bool keepComments := true

  ** Read the next token, store result in `tok` and `val`
  Token next()
  {
    // reset
    val = null

    // skip non-meaningful whitespace and comments
    while (true)
    {
      // treat space, tab, non-breaking space as whitespace
      if (cur == ' ' || cur == '\t' || cur == 0xa0)  { consume; continue }

      // comments
      if (cur == '/')
      {
        if (peek == '/' && keepComments) { lockLoc; return tok = parseComment }
        if (peek == '/') { skipCommentSL; continue }
        if (peek == '*') { skipCommentML; continue }
      }

      break
    }

    // lock in location
    lockLoc

    // newlines
    if (cur == '\n' || cur == '\r')
    {
      if (cur == '\r' && peek == '\n') consume
      consume
      return tok = Token.nl
    }

    // handle various starting chars
    if (cur.isAlpha) return tok = id
    if (cur == '"')  return tok = str

    // operator
    return tok = operator
  }

  ** Lock in location of start of token
  private Void lockLoc()
  {
    this.line = curLine
    this.col  = curCol
  }

  ** Close
  Bool close() { in.close }

//////////////////////////////////////////////////////////////////////////
// Token Productions
//////////////////////////////////////////////////////////////////////////

  private Token id()
  {
    s := StrBuf()
    while (cur.isAlphaNum || cur == '_')
    {
      s.addChar(cur)
      consume
    }
    id := s.toStr

    // normal id
    this.val = id
    return Token.id
  }

  private Token str()
  {
    consume // opening quote
    isTriple := cur == '"' && peek == '"'
    if (isTriple) { consume; consume }
    s := StrBuf()
    while (true)
    {
      ch := cur
      if (ch == '"')
      {
        consume
        if (isTriple)
        {
          if (cur != '"' || peek != '"')
          {
            s.addChar('"')
            continue
          }
          consume
          consume
        }
        break
      }
      if (ch == 0) throw err("Unexpected end of string literal")
      if (ch == '\\') { s.addChar(escape); continue }
      consume
      s.addChar(ch)
    }
    this.val = s.toStr
    return Token.str
  }

  private Int escape()
  {
    // consume slash
    consume

    // check basics
    switch (cur)
    {
      case 'b':   consume; return '\b'
      case 'f':   consume; return '\f'
      case 'n':   consume; return '\n'
      case 'r':   consume; return '\r'
      case 't':   consume; return '\t'
      case '"':   consume; return '"'
      case '$':   consume; return '$'
      case '\'':  consume; return '\''
      case '`':   consume; return '`'
      case '\\':  consume; return '\\'
    }

    // check for uxxxx
    if (cur == 'u')
    {
      consume
      n3 := cur.fromDigit(16); consume
      n2 := cur.fromDigit(16); consume
      n1 := cur.fromDigit(16); consume
      n0 := cur.fromDigit(16); consume
      if (n3 == null || n2 == null || n1 == null || n0 == null) throw err("Invalid hex value for \\uxxxx")
      return n3.shiftl(12).or(n2.shiftl(8)).or(n1.shiftl(4)).or(n0)
    }

    throw err("Invalid escape sequence")
  }

  ** Parse a symbol token (typically into an operator).
  private Token operator()
  {
    c := cur
    consume
    switch (c)
    {
      case ',':  return Token.comma
      case ':':  return Token.colon
      case '[':  return Token.lbracket
      case ']':  return Token.rbracket
      case '{':  return Token.lbrace
      case '}':  return Token.rbrace
      case '<':  return Token.lt
      case '>':  return Token.gt
      case '.':  return Token.dot
      case '?':  return Token.question
      case '&':  return Token.amp
      case '|':  return Token.pipe
      case 0:    return Token.eof
    }

    if (c == 0) return Token.eof

    throw err("Unexpected symbol: " + c.toChar.toCode('\'') + " (0x" + c.toHex + ")")
  }

//////////////////////////////////////////////////////////////////////////
// Comments
//////////////////////////////////////////////////////////////////////////

  ** Parse single line comment when keeping comments
  private Token parseComment()
  {
    s := StrBuf()
    consume  // first slash
    consume  // next slash
    if (cur == ' ') consume // first space
    while (true)
    {
      if (cur == '\n' || cur == 0) break
      s.addChar(cur)
      consume
    }
    this.val = s.toStr
    return Token.comment
  }

  ** Skip a single line // comment
  private Void skipCommentSL()
  {
    consume  // first slash
    consume  // next slash
    while (true)
    {
      if (cur == '\n' || cur == 0) break
      consume
    }
  }

  ** Skip a multi line /* comment.  Note unlike C/Java,
  ** slash/star comments can be nested.
  private Void skipCommentML()
  {
    consume   // first slash
    consume   // next slash
    depth := 1
    while (true)
    {
      if (cur == '*' && peek == '/') { consume; consume; depth--; if (depth <= 0) break }
      if (cur == '/' && peek == '*') { consume; consume; depth++; continue }
      if (cur == 0) break
      consume
    }
  }

//////////////////////////////////////////////////////////////////////////
// Error Handling
//////////////////////////////////////////////////////////////////////////

  ParseErr err(Str msg)
  {
    this.val = msg
    return ParseErr(msg)
  }

//////////////////////////////////////////////////////////////////////////
// Char Reads
//////////////////////////////////////////////////////////////////////////

  private Void consume()
  {
    cur     = peek
    curLine = peekLine
    curCol  = peekCol

    peek = in.readChar ?: 0
    if (peek == '\n') { peekLine++; peekCol = 0 }
    else { peekCol++ }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private InStream in       // underlying stream
  private Int cur           // current char
  private Int peek          // next char
  private Int peekLine := 1
  private Int peekCol
  private Int curLine
  private Int curCol
}

**************************************************************************
** Token
**************************************************************************

@Js
internal enum class Token
{

  id       ("identifier"),
  str      ("Str", true),
  dot      ("."),
  colon    (":"),
  comma    (","),
  lt       ("<"),
  gt       (">"),
  lbrace   ("{"),
  rbrace   ("}"),
  lparen   ("("),
  rparen   (")"),
  lbracket ("["),
  rbracket ("]"),
  question ("?"),
  amp      ("&"),
  pipe     ("|"),
  nl       ("newline"),
  comment  ("comment"),
  eof      ("eof");

  private new make(Str dis, Bool isVal := false)
  {
    this.dis  = dis.size <= 2 ? "'${dis}' $name" : dis
    this.isVal = isVal
  }

  const Str dis
  const Bool isVal
  override Str toStr() { dis }
}