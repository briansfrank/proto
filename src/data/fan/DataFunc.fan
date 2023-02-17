//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Jan 2023  Brian Frank  Creation
//

using util

**
** Function specification with parameter types and a return type.
**
@Js
const mixin DataFunc : DataType
{
  ** Return type slot
  abstract DataSlot returns()

  ** Parameter slots
  abstract DataSlot[] params()

  ** Lookup a parameter slot by name
  abstract DataSlot? param(Str name, Bool checked := true)

  ** Call this function with the given arguments
  abstract Obj? call(Dict args)
}