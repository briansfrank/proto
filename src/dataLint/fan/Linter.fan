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
** Linter
**
@Js
class Linter : Fitter
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(AxonContext cx) : super(cx)
  {
    gb = GridBuilder()
    gb.addCol("subject")
    gb.addCol("msg")
  }

//////////////////////////////////////////////////////////////////////////
// Fits
//////////////////////////////////////////////////////////////////////////

  Grid lintFits(Obj? val, DataType type)
  {
    failFast = false
    recs := Etc.toRecs(val)
    recs.each |rec|
    {
      subject = rec["id"] as Ref
      fits(rec, type)
    }
    return toGrid
  }

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
    if (slot.slotType.isaMarker)
      return log("Missing required marker '$slot.name'")
    else
      return log("Missing required slot '$slot.name'")
  }

//////////////////////////////////////////////////////////////////////////
// Logging
//////////////////////////////////////////////////////////////////////////

  Bool log(Str msg)
  {
    gb.addRow2(subject, msg)
    return false
  }

  Grid toGrid() { gb.toGrid }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private Ref? subject
  private GridBuilder gb
}

