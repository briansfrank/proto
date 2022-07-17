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
mixin Proto
{
  ** Parent object or null if this is the root object
  abstract Proto? parent()

  ** Simple name within parent
  abstract Str name()

  ** Full dotted path from root
  abstract Path path()

  ** Prototype this object inherits from.  Return null if this 'Obj' itself.
  abstract Proto? type()

  ** Point in time transaction id
  abstract Int tx()

  ** Value of the object
  abstract Str? val(Bool checked := true)

  ** Get the inherited child mapped by the given name.  If it is not
  ** mapped to a non-null value, then throw an UnknownProtoErr.
  override abstract Obj? trap(Str name, Obj?[]? args := null)

  ** Get inherited child object by name or return null if not found
  @Operator abstract Proto? get(Str name, Bool checked := true)

  ** Get a declared child object by name or return null if not found
  abstract Proto? declared(Str name)

  ** Iterate the children objects
  abstract Void each(|Proto| f)

  ** Iterate through the children until the given function returns
  ** non-null, then break the iteration and return resulting object.
  ** Return null if function returns null for every child.
  abstract Obj? eachWhile(|Proto->Obj?| f)

  ** Debug dump with some pretty print
  @NoDoc abstract Void dump(OutStream out := Env.cur.out, [Str:Obj]? opts := null)
}

