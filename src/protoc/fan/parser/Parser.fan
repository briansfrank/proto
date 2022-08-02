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
  Void parse(CLib lib, Bool isLibMetaFile)
  {
    try
    {
      parsePragma(lib, isLibMetaFile)
      parseProtos(lib.proto, false)
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

  private Void parsePragma(CLib lib, Bool isLibMetaFile)
  {
    if (isLibMetaFile)
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
    parseProtoChildren(lib.proto, Token.libMeta, Token.gt, true)
  }

//////////////////////////////////////////////////////////////////////////
// Protos
//////////////////////////////////////////////////////////////////////////

  private Void parseProtos(CProto parent, Bool isMeta)
  {
    while (true)
    {
      proto := parseProto(parent, isMeta)
      if (proto == null) break
      parseEndOfProto
    }
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

    throw err("Expecting end of proto: comma or newline, not $curToStr")
  }

  private CProto? parseProto(CProto parent, Bool isMeta)
  {
    // leading comment
    doc := parseLeadingDoc

    // end of file or closing symbols
    if (cur === Token.eof) return null
    if (cur === Token.rbrace) return null
    if (cur === Token.gt) return null

    // this token is start of our proto production
    loc := curToLoc

    // parse name+type productions as one of three cases:
    //  1) <name> only as shortcut for name:Marker (if lowercase name only)
    //  2) <name> ":" for named child
    //  3) unnamed child, auto assign name using "_digits"
    Str? name
    CType? type
    if (cur === Token.id && peek !== Token.colon && curVal.toStr[0].isLower)
    {
      // 1) <name> only as shortcut for name:Marker (if lowercase name only)
      name = parseProtoName(isMeta)
      type = CType(loc, "sys.Marker")
    }
    else if (cur === Token.id && peek === Token.colon)
    {
      // 2) <name> ":" for named child
      name = parseProtoName(isMeta)
      consume(Token.colon)
      skipNewlines
      type = parseProtoType
    }
    else
    {
      // 3) unnamed child, auto assign name using "_digits"
      name = "_" + (parent.nameCounter++)
      type = parseProtoType
    }

    // create the proto
    proto := addProto(parent, loc, name, doc, type)

    // proto body <meta> {data} "val"
    hasType := proto.type != null
    hasMeta := parseProtoMeta(proto)
    hasData := parseProtoData(proto)
    hasVal  := parseProtoVal(proto)
    parseTrailingDoc(parent)

    // verify we had one production: type |meta | data | val
    if (!(hasType || hasMeta || hasData || hasVal))
      throw err("Expecting proto body", loc)

    return proto
  }

  private Str parseProtoName(Bool isMeta)
  {
    name := consumeName
    if (isMeta) name = StrBuf(name.size+1).addChar('_').add(name).toStr
    return name
  }

  private CType? parseProtoType()
  {
    if (cur !== Token.id) return null
    loc := curToLoc
    name := consumeName
    while (cur == Token.dot)
    {
      consume
      name += "." + consumeName
    }
    return CType(loc, name)
  }

  private Bool parseProtoMeta(CProto parent)
  {
    parseProtoChildren(parent, Token.lt, Token.gt, true)
  }

  private Bool parseProtoData(CProto parent)
  {
    parseProtoChildren(parent, Token.lbrace, Token.rbrace, false)
  }

  private Bool parseProtoChildren(CProto parent, Token open, Token close, Bool isMeta)
  {
    if (cur !== open) return false
    consume
    skipNewlines
    parseProtos(parent, isMeta)
    //while (cur !== close) parseProto(parent, isMeta)
    consume(close)
    return true
  }

  private Bool parseProtoVal(CProto proto)
  {
    if (!cur.isLiteral) return false
    proto.val = curVal
    consume
    return true
  }

  private CProto addProto(CProto parent, Loc loc, Str name, Str? doc, CType? type)
  {
    proto := CProto(loc, name, doc, type)
    proto.pragma = this.pragma
    step.addSlot(parent, proto)
    return proto
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

  private Void parseTrailingDoc(CProto proto)
  {
    if (cur === Token.comment)
    {
      doc := curVal.toStr.trimToNull
      if (doc != null && proto.doc == null)
        proto.doc = doc
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

  private Loc curToLoc()
  {
    Loc(fileLoc.file, curLine, curCol)
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
    curCol   = peekCol

    peek     = tokenizer.next
    peekVal  = tokenizer.val
    peekLine = tokenizer.line
    peekCol  = tokenizer.col
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
  private Int curCol     // current token col number

  private Token peek     // next token
  private Obj? peekVal   // next token value
  private Int peekLine   // next token line number
  private Int peekCol    // next token col number
}