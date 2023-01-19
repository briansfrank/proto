//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util

**
** Collection of name/value slots.
**
@Js
const mixin DataDict : DataObj
{
  ** Return this
  override abstract DataDict val()

  ** Does this dict contains the given slot name
  abstract Bool has(Str name)

  ** Does this dict not contain the given slot name
  abstract Bool missing(Str name)

  ** Return true if this dict contains no name/value pairs
  abstract Bool isEmpty()

  ** Get the data object value for the given name or 'def' is not mapped.
  @Operator abstract Obj? get(Str name, Obj? def := null)

  ** Get the value mapped by the given name.  If it is not
  ** mapped to a non-null value, then throw an exception.
  override abstract Obj? trap(Str name, Obj?[]? args := null)

  ** Get the value for given name a typed data object
  abstract DataObj? getData(Str name, Bool checked := true)

  ** Iterate the data object values
  abstract Void each(|Obj?,Str| f)

  ** Iterate the data object values until callback returns non-null
  abstract Obj? eachWhile(|Obj?,Str->Obj?| f)

  ** Iterate the data objects
  abstract Void eachData(|DataObj,Str| f)
}