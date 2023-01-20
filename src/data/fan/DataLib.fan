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
  ** Qualified name of the library
  abstract Str qname()

  ** Version of the library
  abstract Version version()

  ** List all the types contained by this library
  abstract DataType[] types()

  ** Lookup a type contained by this libary
  abstract DataType? type(Str name, Bool checked := true)
}