//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Feb 2023  Brian Frank  Creation
//

using util

**
** AST system references
**
@Js
internal class ASys
{
  ARef obj    := init("Obj")
  ARef marker := init("Marker")
  ARef str    := init("Str")
  ARef dict   := init("Dict")
  ARef list   := init("List")
  ARef and    := init("And")
  ARef or     := init("Or")
  ARef maybe  := init("Maybe")

  private static ARef init(Str name) { ARef(FileLoc.synthetic, AName("sys", name)) }

}