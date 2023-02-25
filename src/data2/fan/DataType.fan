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

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  ** Parent library for type
  abstract DataLib lib()

  ** Base type this type inherits from or null if this is 'sys::Obj' itself
  abstract DataType? base()

  ** Full qualified name of this type
  abstract Str qname()

  ** Simple name of the type within its library
  abstract Str name()

//////////////////////////////////////////////////////////////////////////
// Is-A
//////////////////////////////////////////////////////////////////////////

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

