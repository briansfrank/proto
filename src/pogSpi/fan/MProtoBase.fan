//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Nov 2022  Brian Frank  Creation
//

using util
using concurrent
using pog

**
** MProtoBase models the inheritance base types(s)
**
@Js
abstract const class MProtoBase
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
@Js
const class MNullBase : MProtoBase
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
@Js
const class MSingleBase : MProtoBase
{
  new make(Proto proto) { this.proto = proto }
  override const Proto? proto
  override Bool has(Str name) { proto.has(name) }
  override Proto? get(Str name) { proto.get(name, false) }
  override Void eachSeen(Str:Str seen, |Proto| f) { proto.spi.eachSeen(seen, f) }
  override Bool fits(Proto base) { proto.fits(base) }
}

**************************************************************************
** MAndBase
**************************************************************************

**
** MAndBase handles an And construct with intersects all base types
**
@Js
const class MAndBase : MProtoBase
{
  new make(Proto and, Proto[] bases) { this.proto = and; this.bases = bases }
  override const Proto? proto
  override Bool has(Str name) { get(name) != null }
  override Proto? get(Str name) { bases.eachWhile |b| { b.get(name, false) } }
  override Void eachSeen(Str:Str seen, |Proto| f) { bases.each |b| { b.spi.eachSeen(seen, f) } }
  override Bool fits(Proto base) { proto.fits(base) || bases.any |b| { b.fits(base) } }
  const Proto[] bases
}

**************************************************************************
** MOrBase
**************************************************************************

**
** MOrBase handles an Or construct with union all base types
**
@Js
const class MOrBase : MProtoBase
{
  new make(Proto and, Proto[] bases) { this.proto = and; this.bases = bases }
  override const Proto? proto
  override Bool has(Str name) { get(name) != null }
  override Proto? get(Str name)
  {
    // the child must be the same in all bases
    kid := bases[0].get(name, false)
    if (kid == null) return null
    for (i := 1; i<bases.size; ++i)
    {
      x := bases[i].get(name, false)
      if (x !== kid) return null
    }
    return kid
  }
  override Void eachSeen(Str:Str seen, |Proto| f)
  {
    // TODO this is crazy expensive
    bases[0].each |kid|
    {
      // only invoke callback for children which are same in all base types
      name := kid.name
      if (seen[name] == null && get(name) != null)
      {
        seen[name] = name
        f(kid)
      }
    }
  }
  override Bool fits(Proto base) { proto.fits(base) || bases.all |b| { b.fits(base) } }
  const Proto[] bases
}