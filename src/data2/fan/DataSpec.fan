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

  ** Parent library for spec
  abstract DataLib lib()

  ** Base type this spec inherits from.  Return null if this is 'Obj' itself
  abstract DataSpec? base()

  ** Full qualified name of this spec
  abstract Str qname()

  ** Simple name of the spec.
  ** If this spec is the library itself then return qname.
  abstract Str name()

  ** Meta data for this spec
  abstract DataDict meta()

  ** List all the effective children specs
  abstract DataSpec[] list()

  ** Lookup a child by name
  @Operator abstract DataSpec? get(Str name, Bool checked := true)

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