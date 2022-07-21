//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   5 May 2022  Brian Frank  Creation
//

**
** Parse a pog file into CProto AST nodes
**
internal class Parser
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  ** Wrap input stream
  new make(Parse step, File file)
  {
    this.step = step
    this.file = file
    this.fileLoc = Loc(file)

    this.tokenizer = Tokenizer(file.in)
    {
      it.keepComments = true
    }

    this.cur = this.peek = Token.eof
    consume
    consume
  }

//////////////////////////////////////////////////////////////////////////
// Public
//////////////////////////////////////////////////////////////////////////

  ** Parse the file
  Void parse(CLib lib)
  {
    try
    {
      parsePragma(lib)
      while (true)
      {
        proto := parseNamedProto(lib.proto)
        if (proto == null) break
      }
      verify(Token.eof)
    }
    finally
    {
      tokenizer.close
    }
  }

//////////////////////////////////////////////////////////////////////////
// Pramga
//////////////////////////////////////////////////////////////////////////

  private Void parsePragma(CLib lib)
  {
    if (file.name == "lib.pog")
    {
      parseLibMeta(lib)
      lib.proto.pragma = CPragma(fileLoc, lib)
    }

    // TODO
    pragma = CPragma(fileLoc, lib)
  }

  private Void parseLibMeta(CLib lib)
  {
    doc := parseLeadingDoc
    if (cur !== Token.libMeta) throw err("Expecting #<> lib meta, not $curToStr")
    parseChildren(lib.proto, Token.libMeta, Token.gt, true)
  }

//////////////////////////////////////////////////////////////////////////
// Protos
//////////////////////////////////////////////////////////////////////////

  private CProto? parseNamedProto(CProto parent, Bool isMeta := false)
  {
    // leading comment
    doc := parseLeadingDoc

    // end of file or closing symbols
    if (cur === Token.eof) return null
    if (cur === Token.rbrace) return null
    if (cur === Token.gt) return null

    // name: proto
    loc := curToLoc
    name := consumeName
    if (isMeta) name = StrBuf(name.size+1).addChar('_').add(name).toStr
    if (cur !== Token.colon)
    {
      // marker
      return addProto(parent, loc, name, doc, CType(loc, "sys.Marker"))
    }
    else
    {
      // proto value
      consume(Token.colon)
      skipNewlines
      return parseProtoX(parent, loc, doc, name)
    }
  }

  private CProto parseProtoX(CProto parent, Loc loc, Str? doc, Str name)
  {
    // type
    type := null
    if (cur === Token.id)
      type = parseType

    // now we can initialize this proto instance
    proto := addProto(parent, loc, name, doc, type)

    // parse <meta>
    parseChildren(proto, Token.lt, Token.gt, true)
    trailingDocOk := !skipNewlines

    // parse value | {children}
    if (cur.isLiteral)
    {
      proto.val = curVal
      consume
    }
    else
    {
      parseChildren(proto, Token.lbrace, Token.rbrace, false)
    }

    // trailing comment
    if (cur === Token.comment && trailingDocOk)
    {
      doc = curVal.toStr.trimToNull
      if (doc != null && proto.doc == null)
        proto.doc = doc
      consume
    }

    // skip any trailing newlines
    skipNewlines

    return proto
  }

  private CProto addProto(CProto parent, Loc loc, Str name, Str? doc, CType? type)
  {
    proto := CProto(loc, name, doc, type)
    proto.pragma = this.pragma
    step.addSlot(parent, proto)
    return proto
  }

  private CType parseType()
  {
    loc := curToLoc
    name := consumeName
    while (cur == Token.dot)
    {
      consume
      name += "." + consumeName
    }
    return CType(loc, name)
  }

  private Void parseChildren(CProto parent, Token open, Token close, Bool isMeta)
  {
    if (cur === open)
    {
      consume
      while (cur !== close)
      {
        parseNamedProto(parent, isMeta)
        skipComma
      }
      consume
    }
  }

//////////////////////////////////////////////////////////////////////////
// Doc
//////////////////////////////////////////////////////////////////////////

  private Str? parseLeadingDoc()
  {
    Str? doc
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

//////////////////////////////////////////////////////////////////////////
// Char Reads
//////////////////////////////////////////////////////////////////////////

  private Bool skipNewlines()
  {
    if (cur !== Token.nl) return false
    while (cur === Token.nl) consume
    return true
  }

  private Void skipComma()
  {
    if (cur === Token.comma) consume
  }

  private Void verify(Token expected)
  {
    if (cur !== expected) throw err("Expected $expected not $curToStr")
  }

  private Loc curToLoc()
  {
    Loc(fileLoc.file, tokenizer.line)
  }

  private Str curToStr()
  {
    curVal != null ? "$cur $curVal.toStr.toCode" : cur.toStr
  }

  private Str consumeName()
  {
    verify(Token.id)
    name := curVal.toStr
    consume
    return name
  }

  private Void consume(Token? expected := null)
  {
    if (expected != null) verify(expected)

    cur      = peek
    curVal   = peekVal
    curLine  = peekLine

    peek     = tokenizer.next
    peekVal  = tokenizer.val
    peekLine = tokenizer.line
  }

  private Err err(Str msg, Loc loc := curToLoc)
  {
    step.err(msg, loc)
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private Parse step
  private File file
  private Loc fileLoc
  private Tokenizer tokenizer
  private CPragma? pragma

  private Token cur      // current token
  private Obj? curVal    // current token value
  private Int curLine    // current token line number

  private Token peek     // next token
  private Obj? peekVal   // next token value
  private Int peekLine   // next token line number
}