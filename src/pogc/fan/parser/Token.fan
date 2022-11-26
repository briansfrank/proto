//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//    5 May 2022  Brian Frank  Repurpose code from HaystackTokenizer
//

**
** Token type for pog syntax
**
internal enum class Token
{

//////////////////////////////////////////////////////////////////////////
// Enum
//////////////////////////////////////////////////////////////////////////

  // identifer/literals
  id  ("identifier"),
  str ("Str", true),

  // operators
  dot           ("."),
  colon         (":"),
  comma         (","),
  semicolon     (";"),
  lt            ("<"),
  gt            (">"),
  lbrace        ("{"),
  rbrace        ("}"),
  lparen        ("("),
  rparen        (")"),
  lbracket      ("["),
  rbracket      ("]"),
  pound         ("#"),
  libMeta       ("#<"),
  pragma        ("#{"),
  question      ("?"),
  amp           ("&"),
  pipe          ("|"),
  nl            ("newline"),

  // misc
  comment("comment"),
  eof("eof");

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  private new make(Str dis, Bool isLiteral := false)
  {
    this.dis  = dis
    this.isLiteral = isLiteral
  }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  ** Get string used to display token to user in error messages
  const Str dis

  ** Does token represent a literal value such as string or date
  const Bool isLiteral

  ** Symbol
  override Str toStr() { dis }

}

