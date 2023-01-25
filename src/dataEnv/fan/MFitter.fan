//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   22 Jan 2023  Brian Frank  Creation
//

using data

**
** MFitter implements DataEnv.fits
**
@Js
internal class MFitter
{
  new make(DataEnv env)
  {
    this.env = env
    this.sys = this.env.sys
  }

  Bool fits(Obj? val, DataType type)
  {
    // get type for value
    valType := env.typeOf(val, false)
    if (valType == null) return explainNoType(val)

    // check nominal typing
    if (valType.inherits(type)) return true

    // check structurally typing
    if (valType is DataDict && type.inherits(sys.dict))
      return fitsStruct(val, type)

    return explainNoFit(valType, type)
  }

  Bool fitsStruct(DataDict dict, DataType type)
  {
    match := true
    type.slots.each |slot|
    {
      match = fitsSlot(dict.get(slot.name, null), slot) && match
    }
    return match
  }

  private Bool fitsSlot(Obj? val, DataSlot slot)
  {
    t := slot.slotType
    if (val == null && !t.inherits(sys.maybe))
      return explainMissingSlot(slot)

    // TODO: check value type without high level logging

    return true
  }

  virtual Bool explainNoType(Obj? val) { false }

  virtual Bool explainNoFit(DataType valType, DataType type) { false }

  virtual Bool explainMissingSlot(DataSlot slot) { false }

  const MDataEnv env
  const MSys sys
}

**************************************************************************
** MFitterExplain
**************************************************************************

@Js
internal class MFitterExplain : MFitter
{
  new make(DataEnv env) : super(env) {}

  override Bool explainNoType(Obj? val)
  {
    log("Value not mapped to data type [${val?.typeof}]")
  }

  override Bool explainNoFit(DataType valType, DataType type)
  {
    log("Type '$valType' does not fit '$type'")
  }

  override Bool explainMissingSlot(DataSlot slot)
  {
    if (slot.slotType.inherits(sys.marker))
      return log("Missing required marker '$slot.name'")
    else
      return log("Missing required slot '$slot.name'")
  }

  Bool log(Str msg)
  {
    items.add(env.dict(["msg":msg]))
    return false
  }

  DataSet explain(Obj? val, DataType type)
  {
    fits(val, type)
    return env.set(items)
  }

  DataDict[] items := DataDict[,]
}

