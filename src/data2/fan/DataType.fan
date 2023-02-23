//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util

**
** DataType is a named DataSpec in a DataLib.
**
@Js
const mixin DataType : DataSpec
{

  ** Parent library for type
  abstract DataLib lib()

  ** Full qualified name of this type
  abstract Str qname()

  ** Simple name of the type within its library
  abstract Str name()

}