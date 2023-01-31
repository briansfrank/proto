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

  ** TODO
  @NoDoc abstract DataType? of()

  ** TODO
  @NoDoc abstract DataType[] ofs()

//////////////////////////////////////////////////////////////////////////
// Is-A
//////////////////////////////////////////////////////////////////////////

  ** Return if this inherits that from a nominal type perspective:
  ** true when this type or one its supertypes is the same as that.
  abstract Bool isa(DataType that)

  ** Return if this type inherits from 'sys.Scalar'
  @NoDoc abstract Bool isaScalar()

  ** Return if this type inherits from 'sys.Marker'
  @NoDoc abstract Bool isaMarker()

  ** Return if this type inherits from 'sys.Seq'
  @NoDoc abstract Bool isaSeq()

  ** Return if this type inherits from 'sys.Dict'
  @NoDoc abstract Bool isaDict()

  ** Return if this type inherits from 'sys.List'
  @NoDoc abstract Bool isaList()

  ** Return if this type inherits from 'sys.Maybe'
  @NoDoc abstract Bool isaMaybe()

  ** Return if this type inherits from 'sys.And'
  @NoDoc abstract Bool isaAnd()

  ** Return if this type inherits from 'sys.Or'
  @NoDoc abstract Bool isaOr()

  ** Return if this type inherits from 'sys.Query'
  @NoDoc abstract Bool isaQuery()

}