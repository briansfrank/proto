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
      if (root == null) root = AMap()
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

  private Void parseObjs(AMap parent)
  {
    while (true)
    {
      if (!parseObj(parent)) break
      parseEndOfObj
    }
  }

  private Bool parseObj(AMap parent)
  {
    // leading comment
    doc := parseLeadingDoc

    // end of file or closing symbols
    if (cur === Token.eof) return false
    if (cur === Token.rbrace) return false
    if (cur === Token.gt) return false

    // this token is start of our object production
    p := AObj(curToLoc)

    // <markerOnly> | <named> | <unnamed>
    Str? name := null
    if (cur === Token.id && peek === Token.colon)
    {
      name = consumeName
      consume(Token.colon)
      parseBody(p)
    }
    else if (cur === Token.id && curVal.toStr[0].isLower && peek !== Token.dot && peek !== Token.doubleColon)
    {
      name = consumeName
      p.spec.type = compiler.sys.marker
      p.val = env.marker
    }
    else
    {
      parseBody(p)
    }

    // trailing comment
    parseTrailingDoc(doc)

    addToMap(parent, name, p, doc)
    return true
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
      return parseChildren(p.slots, Token.lbrace, Token.rbrace)

    if (cur.isVal)
      return parseVal(p)

    return false
  }

  private Bool parseChildren(AMap map, Token open, Token close)
  {
    consume(open)
    skipNewlines
    parseObjs(map)
    if (cur !== close)
    {
      throw err("Unmatched closing '$close.symbol'")
    }
    consume(close)
    return true
  }

  private Bool parseVal(AObj p)
  {
    p.val = curVal
    consume
    return true
  }

  private Bool parseSpec(AObj p)
  {
    p.spec.type = parseType(p.spec.meta)

    if (p.spec.type == null)
    {
      // allow <meta> without type only for sys::Obj
      if (cur !== Token.lt) return false
      if (!compiler.isSys) throw err("Must specify type name before <meta>")
    }

    if (cur === Token.lt)
      parseChildren(p.spec.meta, Token.lt, Token.gt)

    if (cur === Token.question)
      p.spec = parseTypeMaybe(p.spec)

    return true
  }

  ARef? parseType(AMap meta)
  {
    if (cur !== Token.id) return null

    type := parseTypeSimple("Expecting type name")
    if (cur === Token.amp)  return parseTypeCompound("And", compiler.sys.and, meta, type)
    if (cur === Token.pipe) return parseTypeCompound("Or", compiler.sys.or,  meta, type)
    return type
  }

  private ARef parseTypeCompound(Str dis, ARef compoundType, AMap meta, ARef first)
  {
    sepToken := cur
    ofs := ARef[,].add(first)
    while (cur === sepToken)
    {
      consume
      skipNewlines
      ofs.add(parseTypeSimple("Expecting next '$dis' type after $sepToken"))
    }

    loc := ofs.first.loc
    x := AObj(loc)
    x.val = ofs
    meta.add(compiler, "ofs", x)

    return compoundType
  }

  private ASpecX parseTypeMaybe(ASpecX oldSpec)
  {
    consume(Token.question)

    loc := oldSpec.loc
    oldType := oldSpec.type

    // if spec is just a type ref, just add into the old's meta
    if (oldSpec.isTypeOnly)
    {
      oldSpec.meta.add(compiler, "of", AObj(loc, oldType))
      oldSpec.type = compiler.sys.maybe
      return oldSpec
    }

    // otherwise we need to wrap the entire old spec inside a maybe
    wrap := ASpecX()
    wrap.type = compiler.sys.maybe
    wrap.meta.add(compiler, "of", AObj(loc, oldSpec))
    return wrap
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

  private Void addToMap(AMap map, Str? name, AObj child, Str? doc)
  {
    addDoc(child, doc)
    map.add(compiler, name, child)
  }

  private Void addDoc(AObj p, Str? docStr)
  {
    if (docStr == null) return
    if (p.spec.meta.get("doc") != null) return

    loc := p.loc

    docVal := AObj(loc)
    docVal.spec.type = compiler.sys.str
    docVal.val = docStr

    p.spec.meta.add(compiler, "doc", docVal)
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

  private Str? parseTrailingDoc(Str? doc)
  {
    if (cur === Token.comment)
    {
      // leading trumps trailing
      if (doc == null) doc = curVal.toStr.trimToNull
      consume
    }
    return doc
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

