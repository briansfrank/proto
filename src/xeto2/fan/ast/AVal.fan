//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Mar 2023  Brian Frank  Creation
//

using util
using data2

**
** AST value type compiles into either scalar, list, or dict
**
@Js
internal class AVal: AObj
{
   ** Constructor
  new make(FileLoc loc, Str name) : super(loc, name) {}

  ** Node type
  override ANodeType nodeType() { ANodeType.val }

  ** Assembled value - raise exception if not assembled yet
  override Obj asm() { asmRef ?: throw NotAssembledErr() }

  ** Construct nested value
  override AObj makeChild(FileLoc loc, Str name) { AVal(loc, name) }

  ** Assembled dict
  Obj? asmRef

}