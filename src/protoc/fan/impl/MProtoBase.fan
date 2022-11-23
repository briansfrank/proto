//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Nov 2022  Brian Frank  Creation
//

using util
using concurrent
using proto

**
** MProtoBase models the inheritance base types(s)
**
@Js
internal abstract const class MProtoBase
{

  ** Proto type return for base type
  abstract Proto? proto()

  ** Does the type contain the given slot
  abstract Bool has(Str name)

  ** Get the given inherited slot
  abstract Proto? get(Str name)

  ** Iterate the inherited slots
  abstract Void eachSeen(Str:Str seen, |Proto| f)

  ** Return if the base type(s) fit the given base
  abstract Bool fits(Proto base)
}

**************************************************************************
** MNullBase
**************************************************************************

**
** MNullBase is for sys.Obj itself which has no base type
**
internal const class MNullBase : MProtoBase
{
  override Proto? proto()  { null }
  override Bool has(Str name) { false }
  override Proto? get(Str name) { null }
  override Void eachSeen(Str:Str seen, |Proto| f) {}
  override Bool fits(Proto base) { false }
}

**************************************************************************
** MSingleBase
**************************************************************************

**
** MSingleBase handles the standard case for a single prototype base type
**
internal const class MSingleBase : MProtoBase
{
  new make(MProto proto) { this.proto = proto }
  override const MProto? proto
  override Bool has(Str name) { proto.has(name) }
  override Proto? get(Str name) { proto.get(name, false) }
  override Void eachSeen(Str:Str seen, |Proto| f) { proto.eachSeen(seen, f) }
  override Bool fits(Proto base) { proto.fits(base) }
}

**************************************************************************
** MAndBase
**************************************************************************

**
** MAndBase handles an And construct with intersects all base types
**
internal const class MAndBase : MProtoBase
{
  new make(MProto and, MProto[] bases) { this.proto = and; this.bases = bases }
  override const MProto? proto
  override Bool has(Str name) { get(name) != null }
  override Proto? get(Str name) { bases.eachWhile |b| { b.get(name, false) } }
  override Void eachSeen(Str:Str seen, |Proto| f) { bases.each |b| { b.eachSeen(seen, f) } }
  override Bool fits(Proto base) { bases.any |b| { b.fits(base) } }
  const MProto[] bases
}