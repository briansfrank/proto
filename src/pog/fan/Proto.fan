//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Feb 2022  Brian Frank  Creation
//

using util

**
** Prototype object.
**
@Js
const class Proto : ProtoStub
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  ** Constructor must be run within an update
  new make() { this.spiRef = Update.cur.init(this)  }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  ** Simple name within parent
  Str name() { spiRef.name }

  ** Fully qualified name as dotted path from root
  Str qname() { spiRef.qname }

  ** Prototype this object inherits from.  Return null if this 'sys.Obj' itself.
  Proto? type() { spiRef.type }

  ** Does this proto fit the given proto from a nominal type perspective
  ** Examples:
  **   Str.fits(Str)     >>>  true
  **   Str.fits(Scalar)  >>>  true
  **   Scalar.fits(Str)  >>>  false
  Bool fits(Proto base) { spiRef.fits(base) }

  ** Transaction version for when this proto was last modified
  Int tx() { spiRef.tx }

  ** Service provider interface for this proto object
  @NoDoc virtual ProtoSpi spi() { spiRef }
  internal const ProtoSpi spiRef

  ** String representation is always qname
  override final Str toStr() { qname }

//////////////////////////////////////////////////////////////////////////
// Scalar
//////////////////////////////////////////////////////////////////////////

  ** Does this proto have a scalar value
  Bool hasVal() { spiRef.hasVal }

  ** Scalar value string of the object
  Str? val(Bool checked := true) { spiRef.val(checked) }

//////////////////////////////////////////////////////////////////////////
// Children
//////////////////////////////////////////////////////////////////////////

  ** Does this object contain an effective child with the given name.
  Bool has(Str name) { spiRef.has(name) }

  ** Does this object contain a non-inherited child with the given name.
  Bool hasOwn(Str name) { spiRef.hasOwn(name) }

  ** Get the effective child mapped by the given name.  If it is not
  ** mapped to a non-null value, then throw an UnknownProtoErr.
  override Proto? trap(Str name, Obj?[]? args := null) { spiRef.trap(name, args) }

  ** Get effective child object by name.
  @Operator Proto? get(Str name, Bool checked := true) { spiRef.get(name, checked) }

  ** Get a non-inherited child object by name.
  Proto? getOwn(Str name, Bool checked := true) { spiRef.getOwn(name, checked) }

  ** Iterate the effective children objects.  This iteration includes
  ** inherited children and can be very expensive; prefer `eachOwn()`.
  Void each(|Proto| f) { spiRef.each(f) }

  ** Iterate the non-inherited children objects.
  Void eachOwn(|Proto| f) { spiRef.eachOwn(f) }

  ** Return a list of this object effective children.  This iteration includes
  ** inherited children and can be very expensive; prefer `listOwn()`.
  Proto[] list() { spiRef.list }

  ** Return a list of this object non-inherited children.
  ** It is preferable to to use `eachOwn`.
  Proto[] listOwn()  { spiRef.listOwn }

//////////////////////////////////////////////////////////////////////////
// Updates
//////////////////////////////////////////////////////////////////////////

  ** Convenience for `Update.set`
  @Operator This set(Str name, Obj val) { Update.cur.set(this, name, val); return this }

  ** Convenience for `Update.add`
  @Operator This add(Obj val, Str? name := null) { Update.cur.add(this, val, name); return this }

  ** Convenience for `Update.remove`
  Void remove(Str name) { Update.cur.remove(this, name) }

  ** Convenience for `Update.clear`
  This clear() { Update.cur.clear(this); return this }

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  ** Source file location if support or unknown
  FileLoc loc() { spiRef.loc }

  ** Debug dump with some pretty print
  @NoDoc Void dump(OutStream out := Env.cur.out, [Str:Obj]? opts := null) { spiRef.dump(out, opts) }

}

**************************************************************************
** ProtoSpi
**************************************************************************

@NoDoc @Js
abstract const class ProtoSpi
{
  abstract Str name()
  abstract Str qname()
  abstract Proto? type()
  abstract Int tx()
  abstract Bool fits(Proto base)
  abstract Bool hasVal()
  abstract Obj? val(Bool checked)
  abstract Bool has(Str name)
  abstract Bool hasOwn(Str name)
  abstract Proto? get(Str name, Bool checked := true)
  abstract Proto? getOwn(Str name, Bool checked := true)
  abstract Void each(|Proto| f)
  abstract Void eachOwn(|Proto| f)
  abstract Void eachSeen(Str:Str seen, |Proto| f)
  abstract Proto[] list()
  abstract Proto[] listOwn()
  abstract FileLoc loc()
  abstract Void dump(OutStream out := Env.cur.out, [Str:Obj]? opts := null)
}



