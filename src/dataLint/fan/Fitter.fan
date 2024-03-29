//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   22 Jan 2023  Brian Frank  Creation
//

using data
using haystackx
using axonx

**
** Fitter
**
@Js
class Fitter
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(AxonContext cx) { this.cx = cx }

//////////////////////////////////////////////////////////////////////////
// Fits
//////////////////////////////////////////////////////////////////////////

  Bool fits(Obj? val, DataType type)
  {
    // get type for value
    valType := data.typeOf(val, false)
    if (valType == null) return explainNoType(val)

    // check nominal typing
    if (valType.isa(type)) return true

    // check structurally typing
    if (val is Dict && type.isaDict)
      return fitsStruct(val, type)

    return explainNoFit(valType, type)
  }

  Bool fitsStruct(Dict dict, DataType type)
  {
    slots := type.slots
    match := true
    for (i := 0; i<slots.size; ++i)
    {
      slot := slots[i]
      match = fitsSlot(dict, type, slot) && match
      if (failFast && !match) return false
    }
    return match
  }

  private Bool fitsSlot(Dict dict, DataType type, DataSlot slot)
  {
    t := slot.slotType

    if (t.isaQuery) return fitsQuery(dict, type, slot)

    val := dict.get(slot.name, null)

    if (val == null)
    {
      if (t.isaMaybe) return true
      return explainMissingSlot(slot)
    }

    valFits := Fitter(cx).fits(val, t)
    valType := data.typeOf(val, false) ?: data.type("sys.None")
    if (!valFits) return explainInvalidSlotType(valType, slot)

    return true
  }

  private Bool fitsQuery(Dict dict, DataType type, DataSlot slot)
  {
    // if no constraints then no additional checking required
    constraints := slot.constraints
    if (constraints.isEmpty) return true

    // run the query to get matching extent
    extent := Query(cx).query(dict, slot)

    // TODO: we need to store of in meta to get of type
    ofDis := slot.name
    if (ofDis.endsWith("s")) ofDis = ofDis[0..-2]

    // make sure each constraint has exactly one match
    match := true
    constraints.eachWhile |constraint, name|
    {
      match = fitQueryConstraint(dict, ofDis, extent, constraint) && match
      if (failFast && !match) return "break"
      return null
    }

    return match
  }

  private Bool fitQueryConstraint(Dict rec, Str ofDis, Dict[] extent, DataType constraint)
  {
    isMaybe := constraint.isaMaybe
    if (isMaybe) constraint = constraint.of ?: throw Err("Expecting maybe of: $constraint")

    matches := Dict[,]
    extent.each |x|
    {
      if (Fitter(cx).fits(x, constraint)) matches.add(x)
    }

    if (matches.size == 1) return true

    if (matches.size == 0)
    {
      if (isMaybe) return true
      return explainMissingQueryConstraint(ofDis, constraint)
    }

    return explainAmbiguousQueryConstraint(ofDis, constraint, matches)
  }

//////////////////////////////////////////////////////////////////////////
// Match All
//////////////////////////////////////////////////////////////////////////

  DataType[] matchAll(Dict rec, Str:DataType types)
  {
    // first pass is fit each type
    matches := types.findAll |type| { fits(rec, type) }

    // second pass is to remove supertypes so we only
    // return the most specific subtype
    best := DataType[,]
    matches.each |type|
    {
      // check if this type has subtypes in our match list
      hasSubtypes := matches.any |x| { x !== type && x.isa(type) }

      // add it to our best accumulator only if no subtypes
      if (!hasSubtypes) best.add(type)
    }

    // return most specific matches sorted
    return best.sort
  }

//////////////////////////////////////////////////////////////////////////
// Lint Explain
//////////////////////////////////////////////////////////////////////////

  virtual Bool explainNoType(Obj? val) { false }

  virtual Bool explainNoFit(DataType valType, DataType type) { false }

  virtual Bool explainMissingSlot(DataSlot slot) { false }

  virtual Bool explainInvalidSlotType(DataType valType, DataSlot slot) { false }

  virtual Bool explainMissingQueryConstraint(Str ofDis, DataType constraint) { false }

  virtual Bool explainAmbiguousQueryConstraint(Str ofDis, DataType constraint, Dict[] matches) { false }

  DataEnv data() { cx.data }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  AxonContext cx
  Bool failFast := true
}

