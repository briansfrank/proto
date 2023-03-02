//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Mar 2023  Brian Frank  Creation
//

using util

**
** AST DataLib
**
@Js
internal class ALib : ASpec
{
  ** Constructor
  new make(FileLoc loc, ARef type, Str qname)
    : super(loc, type, XetoLib())
  {
    this.qname = qname
  }

  ** Assembled DataLib reference
  override XetoLib asm() { asmRef }

  ** Qualified name "foo.bar.baz"
  const Str qname
}