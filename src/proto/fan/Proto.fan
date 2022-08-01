//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Feb 2022  Brian Frank  Creation
//

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

  ** Value of the object
  abstract Str? val(Bool checked := true)

  ** Does this object contain an effective child with the given name.
  abstract Bool has(Str name)

  ** Does this object contain a non-inherited child with the given name.
  abstract Bool hasOwn(Str name)

  ** Get the effective child mapped by the given name.  If it is not
  ** mapped to a non-null value, then throw an UnknownProtoErr.
  override abstract Obj? trap(Str name, Obj?[]? args := null)

  ** Get effective child object by name.
  @Operator abstract Proto? get(Str name, Bool checked := true)

  ** Get a non-inherited child object by name.
  abstract Proto? getOwn(Str name, Bool checked := true)

  ** Iterate the effective children objects
  abstract Void each(|Proto| f)

  ** Iterate the non-inherited children objects.
  abstract Void eachOwn(|Proto| f)

  ** Iterate through the effective children until the given function returns
  ** non-null, then break the iteration and return resulting object.
  ** Return null if function returns null for every child.
  abstract Obj? eachWhile(|Proto->Obj?| f)

  ** Debug dump with some pretty print
  @NoDoc abstract Void dump(OutStream out := Env.cur.out, [Str:Obj]? opts := null)
}

