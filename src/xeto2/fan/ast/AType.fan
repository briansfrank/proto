//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Mar 2023  Brian Frank  Creation
//

using util

**
** AST DataType
**
@Js
internal class AType : ASpec
{
  ** Constructor
  new make(FileLoc loc, ARef type, ALib lib, Str name)
    : super(loc, type, XetoType())
  {
    this.qname = lib.qname + "::" + name
    this.name  = name
  }

  ** Assembled DataType reference
  override XetoType asm() { asmRef }

  ** Qualified name "foo.bar::Baz"
  const Str qname

  ** Simple name
  const Str name

  ** Return qname
  override Str toStr() { qname }
}