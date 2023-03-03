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
  new make(FileLoc loc, Str qname)
    : super(loc, "lib", XetoLib())
  {
    this.qname = qname
  }

  ** Node type
  override ANodeType nodeType() { ANodeType.lib }

  ** Assembled DataLib reference
  override XetoLib asm() { asmRef }

  ** Construct type
  override AObj makeChild(FileLoc loc, Str name) { AType(loc, this, name) }

  ** Qualified name "foo.bar.baz"
  const Str qname
}