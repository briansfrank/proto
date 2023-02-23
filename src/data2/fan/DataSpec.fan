//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util

**
** Data specification.
**
@Js
const mixin DataSpec
{

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  ** Environment for spec
  abstract DataEnv env()

  ** Type this spec inherits from.  Return null if this is 'Obj' itself
  abstract DataType? type()

  ** Meta data for this spec
  abstract DataDict meta()

  ** Get the declared children slots
  abstract DataSlots declared()

  ** Get the effective children slots including inherited
  //abstract DataSlots slots()

  ** Scalar value or null
  abstract Obj? val()

  ** File location of definition or unknown
  @NoDoc abstract FileLoc loc()

//////////////////////////////////////////////////////////////////////////
// Is-A
//////////////////////////////////////////////////////////////////////////

  ** Return if this inherits from that from a nominal type perspective.
  abstract Bool isa(DataSpec that)

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