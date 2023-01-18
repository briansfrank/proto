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
**
@Js
const mixin DataType : DataDef
{
  ** Environment
  abstract DataEnv env()

  ** Parent library for this type
  abstract DataLib lib()

  ** Base type this type inherits from or null if this is 'Obj' itself
  abstract DataType? base()

  ** Simple name of this type within its library
  abstract Str name()

  ** Qualified name of the type which is the library qname plus type name.
  abstract Str qname()

  ** List all the slots both inherited and declared
  abstract DataSlot[] slots()

  ** Lookup a slot by name
  abstract DataSlot? slot(Str name, Bool checked := true)

  ** Return if this type fits the given type.  If true, then
  ** this type is assignable to the specified type (although the
  ** converse is not necessarily true).
  abstract Bool fits(DataType that)

}