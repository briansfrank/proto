//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//    5 May 2022  Brian Frank  Repurpose code from HaystackTokenizer
//

**
** Stream based tokenizer for pog syntax
**
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

  ** Tokenize and return slash-slash comments
  Bool keepComments := true

  ** Read the next token, store result in `tok` and `val`
  Token next()
  {
    // reset
    val = null

    // skip non-meaningful whitespace and comments
    startLine := line
    while (true)
    {
      // treat space, tab, non-breaking space as whitespace
      if (cur == ' ' || cur == '\t' || cur == 0xa0)  { consume; continue }

      // comments
      if (cur == '/')
      {
        if (peek == '/' && keepComments) return tok = parseComment
        if (peek == '/') { skipCommentSL; continue }
        if (peek == '*') { skipCommentML; continue }
      }

      break
    }

    // newlines
    if (cur == '\n' || cur == '\r')
    {
      if (cur == '\r' && peek == '\n') consume
      consume
      line++
      return tok = Token.nl
    }

    // handle various starting chars
    if (cur.isAlpha || cur == '_') return tok = id
    if (cur == '"')  return tok = str

    // operator
    return tok = operator
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
      if (ch == 0) throw err("Unexpected end of str")
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
      case ';':  return Token.semicolon
      case '[':  return Token.lbracket
      case ']':  return Token.rbracket
      case '{':  return Token.lbrace
      case '}':  return Token.rbrace
      case '(':  return Token.lparen
      case ')':  return Token.rparen
      case '<':  return Token.lt
      case '>':  return Token.gt
      case '.':  return Token.dot
      case '?':  return Token.question
      case '&':  return Token.amp
      case '|':  return Token.pipe
      case '#':
        if (cur == '<') { consume; return Token.libMeta }
        if (cur == '{') { consume; return Token.pragma }
        return Token.pound
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
      if (cur == '\n') ++line
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
    return ParseErr("$msg [line $line]")
  }

//////////////////////////////////////////////////////////////////////////
// Char Reads
//////////////////////////////////////////////////////////////////////////

  private Void consume()
  {
    cur  = peek
    peek = in.readChar ?: 0
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private InStream in  // underlying stream
  private Int cur      // current char
  private Int peek     // next char
}