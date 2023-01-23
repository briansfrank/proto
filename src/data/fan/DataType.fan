//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util

**
** Type definition for data objects.
** Use `DataEnv.type` and `DataEnv.typeOf` to lookup types.
**
@Js
const mixin DataType : DataDef
{
  ** Base type this type inherits from or null if this is 'Obj' itself
  abstract DataType? base()

  ** Simple name of this type within its library
  abstract Str name()

  ** List all the slots both inherited and declared
  abstract DataSlot[] slots()

  ** Lookup a slot by name
  abstract DataSlot? slot(Str name, Bool checked := true)

  ** Return if this type fits that from a nominal type perspective.  This
  ** will return true if this type or one its supertypes is the same as that.
  abstract Bool inherits(DataType that)

}