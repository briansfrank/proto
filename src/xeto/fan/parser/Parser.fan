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

  XetoObj parse()
  {
    try
    {
      root := XetoObj(curToLoc)
      parseObjs(root, false)
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

  private Void parseObjs(XetoObj parent, Bool isMeta)
  {
    while (true)
    {
      child := parseObj
      if (child == null) break
      parseEndOfObj
      addToParent(parent, child, isMeta)
    }
  }

  private XetoObj? parseObj()
  {
    // leading comment
    doc := parseLeadingDoc

    // end of file or closing symbols
    if (cur === Token.eof) return null
    if (cur === Token.rbrace) return null
    if (cur === Token.gt) return null

    // this token is start of our proto production
    p := XetoObj(curToLoc)
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
      p.type = markerType
    }
    else
    {
      parseBody(p)
    }

    // trailing comment
    parseTrailingDoc(p)

    return p
  }

  private Void parseBody(XetoObj p)
  {
    a := parseType(p)
    b := parseMeta(p)
    c := parseChildrenOrVal(p)
    if (!a && !b && !c) throw err("Expecting object body not $curToStr")
  }

  private Bool parseMeta(XetoObj p)
  {
    if (cur !== Token.lt) return false
    parseChildren(p, Token.lt, Token.gt, true)
    return true
  }

  private Bool parseChildrenOrVal(XetoObj p)
  {
    if (cur === Token.lbrace) return parseChildren(p, Token.lbrace, Token.rbrace, false)
    if (cur.isVal) return parseVal(p)
    return false
  }

  private Bool parseChildren(XetoObj p, Token open, Token close, Bool isMeta)
  {
    loc := curToLoc
    consume(open)
    skipNewlines
    parseObjs(p, isMeta)
    parseObjs(p, isMeta)
    if (cur !== close)
    {
      throw err("Unmatched closing '$close.symbol'", loc)
    }
    consume(close)
    return true
  }

  private Bool parseVal(XetoObj p)
  {
    p.val = curVal
    consume
    return true
  }

  private Bool parseType(XetoObj p)
  {
    /*
    if (cur === Token.str && peek === Token.pipe)
      return parseTypeOr(p, null, consumeVal)
    */

    if (cur !== Token.id) return false

    loc := curToLoc
    qname := consumeQName
    /*
    if (cur === Token.amp)      return parseTypeAnd(p, qname)
    if (cur === Token.pipe)     return parseTypeOr(p, qname, null)
    if (cur === Token.question) return parseTypeMaybe(p, qname)
    */

    p.type = XetoType(loc, qname)
    return true
  }

  /*
  private Bool parseTypeAnd(XetoObj p, Str qname)
  {
    of := newMap
    addToOf(of, qname, null)
    while (cur === Token.amp)
    {
      consume
      skipNewlines
      addToOf(of, parseTypeSimple("Expecting next type name after '&' and symbol"), null)
    }
    p.map["_is"] = "sys.And"
    p.map["_of"] = of
    return true
  }

  private Bool parseTypeOr(XetoObj p, Str? qname, Str? val)
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
        addToOf(of, parseTypeSimple("Expecting next type name after '|' or symbol"), null)
    }
    p.map["_is"] = "sys.Or"
    p.map["_of"] = of
    return true
  }

  private Bool parseTypeMaybe(XetoObj p, Str qname)
  {
    consume(Token.question)
    p.map["_is"] = "sys.Maybe"
    p.map["_of"] = ["_is":qname]
    return true
  }
  */

  private XetoType markerType()
  {
    XetoType(FileLoc.unknown, "sys.Marker")
  }

  private Str parseTypeSimple(Str errMsg)
  {
    if (cur !== Token.id) throw err(errMsg)
    return consumeQName
  }

  private Void addToOf(Str:Obj of, Str? qname, Str? val)
  {
    of["_"+of.size] = Str:Obj[:].addNotNull("_is", qname).addNotNull("_val", val)
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

    throw err("Expecting end of proto: comma or newline, not $curToStr")
  }

//////////////////////////////////////////////////////////////////////////
// AST Manipulation
//////////////////////////////////////////////////////////////////////////

  private Void addToParent(XetoObj parent, XetoObj child, Bool isMeta)
  {
    err  := parent.add(child, isMeta)
    if (err != null) throw this.err(err, child.loc)
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

  private Void parseTrailingDoc(XetoObj p)
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

