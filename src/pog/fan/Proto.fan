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

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  ** Simple name within parent
  abstract Str name()

  ** Fully qualified name as dotted path from root
  abstract QName qname()

  ** Is this a type object; name starts with uppercase
  abstract Bool isType()

  ** Is this a field object; name starts with lowercase
  abstract Bool isField()

  ** Is this a meta object; name starts with underbar followed by letter
  abstract Bool isMeta()

  ** Is this a indexed/auto-named object; name starts with underbar followed by digits
  abstract Bool isOrdinal()

  ** Prototype this object extends from.  Return null if this 'sys.Obj' itself.
  abstract Proto? isa()

  ** Does this proto fit the given proto from a nominal type perspective
  ** Examples:
  **   Str.fits(Str)     >>>  true
  **   Str.fits(Scalar)  >>>  true
  **   Scalar.fits(Str)  >>>  false
  abstract Bool fits(Proto base)

  ** Transaction version for when this proto was last modified
  abstract Int tx()

  ** Additional identity info
  abstract ProtoInfo info()

//////////////////////////////////////////////////////////////////////////
// Scalar
//////////////////////////////////////////////////////////////////////////

  ** Does this proto have a scalar value
  abstract Bool hasVal()

  ** Scalar effective scalar value of the object
  abstract Obj? val(Bool checked := true)

  ** Scalar non-inherited value of this object
  abstract Obj? valOwn(Bool checked := true)

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

  ** Iterate over effective children keeping track of each name visited
  @NoDoc abstract Void eachSeen(Str:Str seen, |Proto| f)

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

  ** Print the proto in the pog format
  abstract Void print(OutStream out := Env.cur.out, [Str:Obj]? opts := null)

}

**************************************************************************
** ProtoInfo
**************************************************************************

**
** Proto additional information methods and flags
**
@Js
const mixin ProtoInfo
{
  ** Is this 'sys.Obj' - the root top type
  abstract Bool isObj()

  ** Is this 'sys.None' - the bottom type
  abstract Bool isNone()

  ** Does the proto fit 'sys.Scalar' - all non-collection types
  abstract Bool isScalar()

  ** Does the proto fit 'sys.Marker'
  abstract Bool isMarker()

  ** Does the proto fit 'sys.Dict' - all collection types
  abstract Bool isDict()

  ** Does the proto fit 'sys.List' - indexed based collection
  abstract Bool isList()

  ** Does the proto inherit from 'sys.Lib' - all libraries.
  ** This method returns false for the 'sys.Lib' proto itself.
  abstract Bool isLib()
}

