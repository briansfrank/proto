//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   22 Jan 2023  Brian Frank  Creation
//

using data
using axonx

**
** Fitter
**
@Js
class Fitter
{
  new make(AxonContext cx) { this.cx = cx }

  Bool fits(Obj? val, DataType type)
  {
    // get type for value
    valType := data.typeOf(val, false)
    if (valType == null) return explainNoType(val)

    // check nominal typing
    if (valType.isa(type)) return true

    // check structurally typing
    if (valType is DataDict && type.isaDict)
      return fitsStruct(val, type)

    return explainNoFit(valType, type)
  }

  Bool fitsStruct(DataDict dict, DataType type)
  {
    slots := type.slots
    match := true
    for (i := 0; i<slots.size; ++i)
    {
      slot := slots[i]
      match = fitsSlot(dict.get(slot.name, null), slot) && match
      if (failFast && !match) return false
    }
    return match
  }

  private Bool fitsSlot(Obj? val, DataSlot slot)
  {
    t := slot.slotType
    if (val == null && !t.isaMaybe)
      return explainMissingSlot(slot)

    // TODO: check value type without high level logging

    return true
  }

  virtual Bool explainNoType(Obj? val) { false }

  virtual Bool explainNoFit(DataType valType, DataType type) { false }

  virtual Bool explainMissingSlot(DataSlot slot) { false }

  DataEnv data() { cx.data }

  AxonContext cx
  Bool failFast := true
}

