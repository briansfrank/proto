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

  new make(AxonContext cx) : super(cx) {}

//////////////////////////////////////////////////////////////////////////
// Fits
//////////////////////////////////////////////////////////////////////////

  Grid lintFits(Obj? val, DataType type)
  {
    failFast = false
    recs := Etc.toRecs(val)
    recs.each |rec|
    {
      startRow := rows.size

      subject = rec
      subjectId = rec["id"] as Ref
      fits(rec, type)

      // insert summary about the rows we added for this rec
      numAdded := rows.size - startRow
      if (numAdded > 0)
      {
        countStr := numAdded == 1 ? "1 error" : "$numAdded errors"
        rows.insert(startRow, [subjectId, countStr])
      }
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

  override Bool explainMissingQueryConstraint(Str ofDis, DataType constraint)
  {
    log("Missing required $ofDis $constraint.name")
  }

  override Bool explainAmbiguousQueryConstraint(Str ofDis, DataType constraint, DataDict[] matches)
  {
    log("Ambiguous match for $ofDis $constraint.name: " + recsToDis(matches))
  }

  private Str recsToDis(DataDict[] recs)
  {
    s := StrBuf()
    for (i := 0; i<recs.size; ++i)
    {
      rec := recs[i]
      str := "@" + rec->id
      dis := relDis(rec)
      if (dis != null) str += " $dis.toCode"
      s.join(str, ", ")
      if (s.size > 50 && i+1<recs.size)
        return s.add(", ${recs.size - i - 1} more ...").toStr
    }
    return s.toStr
  }

  private Str? relDis(DataDict d)
  {
    x := dis(d)
    if (x == null) return null

    p := dis(subject)
    if (p == null) return x

    return Etc.relDis(p, x)
  }

  private Str? dis(DataDict? d)
  {
    d?.get("dis", null)
  }

//////////////////////////////////////////////////////////////////////////
// Logging
//////////////////////////////////////////////////////////////////////////

  Bool log(Str msg)
  {
    rows.add([subjectId, msg])
    return false
  }

  Grid toGrid()
  {
    gb := GridBuilder()
    gb.addCol("subject")
    gb.addCol("msg")
    gb.capacity = rows.size
    rows.each |row| { gb.addRow(row) }
    return gb.toGrid
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private Dict? subject
  private Ref? subjectId
  private Obj?[][] rows := [,]
}

