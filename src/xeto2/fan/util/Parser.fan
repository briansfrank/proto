//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   13 Aug 2022  Brian Frank  Creation
//

using util

**
** Parser for the Xeto data type language
**
@Js
internal class Parser
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(XetoCompiler c, FileLoc fileLoc, InStream in)
  {
    this.compiler = c
    this.env = c.env
    this.fileLoc = fileLoc
    this.tokenizer = Tokenizer(in) { it.keepComments = true }
    this.cur = this.peek = Token.eof
    consume
    consume
  }

//////////////////////////////////////////////////////////////////////////
// Public
//////////////////////////////////////////////////////////////////////////

  AMap parse(AMap? root := null)
  {
    try
    {
      if (root == null) root = AMap(curToLoc)
      parseObjs(root)
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

  private Void parseObjs(AMap map)
  {
    while (true)
    {
      child := parseObj
      if (child == null) break
      parseEndOfObj
      addToMap(map, child)
    }
  }

  private AObj? parseObj()
  {
    // leading comment
    doc := parseLeadingDoc

    // end of file or closing symbols
    if (cur === Token.eof) return null
    if (cur === Token.rbrace) return null
    if (cur === Token.gt) return null

    // this token is start of our object production
    p := AObj(curToLoc)
    p.doc = doc

    // <markerOnly> | <named> | <unnamed>
    if (cur === Token.id && peek === Token.colon)
    {
      p.name = consumeName
      consume(Token.colon)
      parseBody(p)
    }
    else if (cur === Token.id && curVal.toStr[0].isLower && peek !== Token.dot && peek !== Token.doubleColon)
    {
      p.name = consumeName
      p.type = compiler.sys.marker
      p.val = env.marker
    }
    else
    {
      parseBody(p)
    }

    // trailing comment
    parseTrailingDoc(p)

    return p
  }

  private Void parseBody(AObj p)
  {
    a := parseSpec(p)
    b := parseChildrenOrVal(p)
    if (!a && !b) throw err("Expecting object body not $curToStr")
  }

  private Bool parseChildrenOrVal(AObj p)
  {
    if (cur === Token.lbrace)
    {
      p.slots = parseChildren(Token.lbrace, Token.rbrace)
      return true
    }

    if (cur.isVal) return parseVal(p)

    return false
  }

  private AMap parseChildren(Token open, Token close)
  {
    map := AMap(curToLoc)
    consume(open)
    skipNewlines
    parseObjs(map)
    if (cur !== close)
    {
      throw err("Unmatched closing '$close.symbol'", map.loc)
    }
    consume(close)
    return map
  }

  private Bool parseVal(AObj p)
  {
    p.val = curVal
    consume
    return true
  }

  private Bool parseSpec(AObj p)
  {
    // type
    p.type = parseType(p)
    if (p.type == null)
    {
      // allow <meta> without type only for sys::Obj
      if (cur == Token.lt && !compiler.isSys) throw err("Must specify type name before <meta>")
    }

    // meta
    if (cur === Token.lt)
      p.setMeta(compiler, parseChildren(Token.lt, Token.gt))

    return true
  }

  ARef? parseType(AObj p)
  {
    if (cur !== Token.id) return null

    type := parseTypeSimple("Expecting type name")
    if (cur === Token.amp)      return parseTypeAnd(p, type)
    if (cur === Token.pipe)     return parseTypeOr(p, type)
    if (cur === Token.question) return parseTypeMaybe(p, type)
    return type
  }

  private ARef parseTypeAnd(AObj p, ARef first)
  {
    ofs := ARef[,].add(first)
    while (cur === Token.amp)
    {
      consume
      skipNewlines
      ofs.add(parseTypeSimple("Expecting next type name after '&' and symbol"))
    }
    p.addOfs(compiler, ofs)
    return compiler.sys.and
  }

  private ARef parseTypeOr(AObj p, ARef first)
  {
    ofs := ARef[,].add(first)
    while (cur === Token.pipe)
    {
      consume
      skipNewlines
      ofs.add(parseTypeSimple("Expecting next type name after '|' or symbol"))
    }
    p.addOfs(compiler, ofs)
    return compiler.sys.or
  }

  private ARef parseTypeMaybe(AObj p, ARef of)
  {
    consume(Token.question)
    p.addOf(compiler, of)
    return compiler.sys.maybe
  }

  private ARef parseTypeSimple(Str errMsg)
  {
    if (cur !== Token.id) throw err(errMsg)
    loc := curToLoc
    name := consumeQName
    return ARef(loc, name)
  }

  private Void parseEndOfObj()
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

    throw err("Expecting end of object: comma or newline, not $curToStr")
  }

//////////////////////////////////////////////////////////////////////////
// AST Manipulation
//////////////////////////////////////////////////////////////////////////

  private Void addToMap(AMap map, AObj child)
  {
    addDoc(child, child.doc)
    map.add(compiler, child)
  }


  private Void addDoc(AObj p, Str? docStr)
  {
    if (docStr == null) return
    if (p.meta != null && p.meta.get("doc") != null) return

    loc := p.loc

    docVal := AObj(loc)
    docVal.name = "doc"
    docVal.type = compiler.sys.str
    docVal.val = docStr

    if (p.meta == null) p.meta = AMap(loc)
    p.meta.add(compiler, docVal)
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

  private Void parseTrailingDoc(AObj p)
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

  private AName consumeQName()
  {
    Str? lib := null
    name := consumeName
    while (cur === Token.dot)
    {
      consume
      name += "." + consumeName
    }
    if (cur === Token.doubleColon)
    {
      consume
      lib = name
      name = consumeName
    }
    return AName(lib, name)
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

  private XetoCompiler compiler
  private XetoEnv env
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

