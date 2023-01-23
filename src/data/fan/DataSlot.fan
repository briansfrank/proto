//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util

**
** Statically typed field within a data type
** Use `DataType.slot` to lookup slots within a type.
**
@Js
const mixin DataSlot : DataDef
{
  ** Parent type which defines this slot.
  abstract DataType parent()

  ** Simple name of this slot within its type
  abstract Str name()

  ** Value type of the slot
  abstract DataType slotType()

}