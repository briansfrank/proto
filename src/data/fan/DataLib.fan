//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util

**
** Versioned library module of type definitions
**
@Js
const mixin DataLib : DataDef
{

  ** Version of the library
  abstract Version version()

  ** List all the types contained by this library
  abstract DataType[] libTypes()

  ** Lookup a type contained by this libary
  abstract DataType? libType(Str name, Bool checked := true)
}