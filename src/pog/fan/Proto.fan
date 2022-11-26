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
const mixin Proto
{
  ** Simple name within parent
  abstract Str name()

  ** Fully qualified name as dotted path from root
  abstract Str qname()

  ** Prototype this object inherits from.  Return null if this 'sys.Obj' itself.
  abstract Proto? type()

  ** Does this proto have a scalar value
  abstract Bool hasVal()

  ** Scalar value string of the object
  abstract Str? val(Bool checked := true)

  ** Does this object contain an effective child with the given name.
  abstract Bool has(Str name)

  ** Does this object contain a non-inherited child with the given name.
  abstract Bool hasOwn(Str name)

  ** Get the effective child mapped by the given name.  If it is not
  ** mapped to a non-null value, then throw an UnknownProtoErr.
  override abstract Proto? trap(Str name, Obj?[]? args := null)

  ** Get effective child object by name.
  @Operator abstract Proto? get(Str name, Bool checked := true)

  ** Get a non-inherited child object by name.
  abstract Proto? getOwn(Str name, Bool checked := true)

  ** Iterate the effective children objects.  This iteration includes
  ** inherited children and can be very expensive; prefer `eachOwn()`.
  abstract Void each(|Proto| f)

  ** Iterate the non-inherited children objects.
  abstract Void eachOwn(|Proto| f)

  ** Return a list of this object effective children.  This iteration includes
  ** inherited children and can be very expensive; prefer `listOwn()`.
  abstract Proto[] list()

  ** Return a list of this object non-inherited children.
  ** It is preferable to to use `eachOwn`.
  abstract Proto[] listOwn()

  ** Does this proto fit the given proto from a nominal type perspective
  ** Examples:
  **   Str.fits(Str)     >>>  true
  **   Str.fits(Scalar)  >>>  true
  **   Scalar.fits(Str)  >>>  false
  abstract Bool fits(Proto base)

  ** Source file location if support or unknown
  abstract FileLoc loc()

  ** Debug dump with some pretty print
  @NoDoc abstract Void dump(OutStream out := Env.cur.out, [Str:Obj]? opts := null)
}

