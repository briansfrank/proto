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

  ** Get the value for the given name or 'def' is not mapped
  @Operator abstract Obj? get(Str name, Obj? def := null)

  ** Get a slot value as a data object
  abstract DataObj? getData(Str name, Bool checked := true)

  ** Iterate the slot data objects
  abstract Void eachData(|DataObj,Str| f)
}