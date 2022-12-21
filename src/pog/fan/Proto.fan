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
const mixin Proto : ProtoStub
{

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  ** Simple name within parent
  abstract Str name()

  ** Fully qualified name as dotted path from root
  abstract QName qname()

  ** Prototype this object inherits from.  Return null if this 'sys.Obj' itself.
  abstract Proto? type()

  ** Does this proto fit the given proto from a nominal type perspective
  ** Examples:
  **   Str.fits(Str)     >>>  true
  **   Str.fits(Scalar)  >>>  true
  **   Scalar.fits(Str)  >>>  false
  abstract Bool fits(Proto base)

  ** Transaction version for when this proto was last modified
  abstract Int tx()

  ** Service provider interface for this proto object
  @NoDoc abstract ProtoSpi spi()

//////////////////////////////////////////////////////////////////////////
// Scalar
//////////////////////////////////////////////////////////////////////////

  ** Does this proto have a scalar value
  abstract Bool hasVal()

  ** Scalar value string of the object
  abstract Obj? val(Bool checked := true)

//////////////////////////////////////////////////////////////////////////
// Children
//////////////////////////////////////////////////////////////////////////

  ** Does this object contain an effective child with the given name.
  abstract Bool has(Str name)

  ** Does this object contain a non-inherited child with the given name.
  abstract Bool hasOwn(Str name)

  ** Get the effective child mapped by the given name.  If it is not
  ** mapped to a non-null value, then throw an UnknownProtoErr.
  abstract override Proto? trap(Str name, Obj?[]? args := null)

  ** Get effective child object by name.
  @Operator abstract Proto? get(Str name, Bool checked := true)

  ** Get a non-inherited child object by name.
  abstract Proto? getOwn(Str name, Bool checked := true)

  ** Iterate the effective children objects.  This iteration includes
  ** inherited children and can be very expensive; prefer `eachOwn()`.
  abstract Void each(|Proto| f)

  ** Iterate the non-inherited children objects.
  abstract Void eachOwn(|Proto| f)

  ** Iterate the non-inherited children objects until callback returns non-null.
  abstract Obj? eachOwnWhile(|Proto->Obj?| f)

  ** Return a list of this object effective children.  This iteration includes
  ** inherited children and can be very expensive; prefer `listOwn()`.
  abstract Proto[] list()

  ** Return a list of this object non-inherited children.
  ** It is preferable to to use `eachOwn`.
  abstract Proto[] listOwn()

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  ** Source file location if support or unknown
  abstract FileLoc loc()

  ** Debug dump with some pretty print
  @NoDoc abstract Void dump(OutStream out := Env.cur.out, [Str:Obj]? opts := null)

}

**************************************************************************
** AbstractProto
**************************************************************************

**
** Base class for proto implementation classes
**
@Js
const class AbstractProto :  Proto
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
  override Str name() { spiRef.name }

  ** Fully qualified name as dotted path from root
  override QName qname() { spiRef.qname }

  ** Prototype this object inherits from.  Return null if this 'sys.Obj' itself.
  override Proto? type() { spiRef.type }

  ** Does this proto fit the given proto from a nominal type perspective
  ** Examples:
  **   Str.fits(Str)     >>>  true
  **   Str.fits(Scalar)  >>>  true
  **   Scalar.fits(Str)  >>>  false
  override Bool fits(Proto base) { spiRef.fits(base) }

  ** Transaction version for when this proto was last modified
  override Int tx() { spiRef.tx }

  ** Service provider interface for this proto object
  @NoDoc override ProtoSpi spi() { spiRef }
  internal const ProtoSpi spiRef

  ** String representation is always qname
  override final Str toStr() { qname.toStr }

//////////////////////////////////////////////////////////////////////////
// Scalar
//////////////////////////////////////////////////////////////////////////

  ** Does this proto have a scalar value
  override Bool hasVal() { spiRef.hasVal }

  ** Scalar value string of the object
  override Obj? val(Bool checked := true) { spiRef.val(checked) }

//////////////////////////////////////////////////////////////////////////
// Children
//////////////////////////////////////////////////////////////////////////

  ** Does this object contain an effective child with the given name.
  override Bool has(Str name) { spiRef.has(name) }

  ** Does this object contain a non-inherited child with the given name.
  override Bool hasOwn(Str name) { spiRef.hasOwn(name) }

  ** Get the effective child mapped by the given name.  If it is not
  ** mapped to a non-null value, then throw an UnknownProtoErr.
  override Proto? trap(Str name, Obj?[]? args := null) { spiRef.trap(name, args) }

  ** Get effective child object by name.
  @Operator override Proto? get(Str name, Bool checked := true) { spiRef.get(name, checked) }

  ** Get a non-inherited child object by name.
  override Proto? getOwn(Str name, Bool checked := true) { spiRef.getOwn(name, checked) }

  ** Iterate the effective children objects.  This iteration includes
  ** inherited children and can be very expensive; prefer `eachOwn()`.
  override Void each(|Proto| f) { spiRef.each(f) }

  ** Iterate the non-inherited children objects.
  override Void eachOwn(|Proto| f) { spiRef.eachOwn(f) }

  ** Iterate the non-inherited children objects until callback returns non-null.
  override Obj? eachOwnWhile(|Proto->Obj?| f) { spiRef.eachOwnWhile(f) }

  ** Return a list of this object effective children.  This iteration includes
  ** inherited children and can be very expensive; prefer `listOwn()`.
  override Proto[] list() { spiRef.list }

  ** Return a list of this object non-inherited children.
  ** It is preferable to to use `eachOwn`.
  override Proto[] listOwn()  { spiRef.listOwn }

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  ** Source file location if support or unknown
  override FileLoc loc() { spiRef.loc }

  ** Debug dump with some pretty print
  @NoDoc override Void dump(OutStream out := Env.cur.out, [Str:Obj]? opts := null) { spiRef.dump(out, opts) }

}

**************************************************************************
** ProtoSpi
**************************************************************************

@NoDoc @Js
abstract const class ProtoSpi
{
  abstract Str name()
  abstract QName qname()
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
  abstract Obj? eachOwnWhile(|Proto->Obj?| f)
  abstract Void eachSeen(Str:Str seen, |Proto| f)
  abstract Proto[] list()
  abstract Proto[] listOwn()
  abstract FileLoc loc()
  abstract Void dump(OutStream out := Env.cur.out, [Str:Obj]? opts := null)
}



