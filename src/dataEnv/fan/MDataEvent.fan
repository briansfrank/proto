//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Jan 2023  Brian Frank  Creation
//

using util
using data
using pog

**
** DataEvent implementation
**
@Js
internal const class MDataEvent : DataDict, DataEvent
{
  new make(DataEventLevel level, Str msg, Obj? subjectId, FileLoc loc, Err? err := null)
  {
    this.level     = level
    this.msg       = msg
    this.loc       = loc
    this.subjectId = subjectId
    this.err       = err
  }

  const override DataEventLevel level
  const override Obj? subjectId
  const override Str msg
  const override FileLoc loc
  const override Err? err

  override DataType type() { ((MDataEnv)DataEnv.cur).sys.dict }

  override DataObj? getData(Str name, Bool checked := true) { throw Err("TODO") }

  override Void eachData(|DataObj,Str| f) { throw Err("TODO") }

  override Obj? get(Str name, Obj? def := null) { throw Err("TODO") }

  override Str toStr()
  {
    s := StrBuf()
    if (!loc.isUnknown) s.add(loc).add(" ")
    s.add("[$level.name.upper] ")
    if (subjectId != null) s.add(" '").add(subjectId).add("' ")
    s.add(msg)
    return s.toStr
  }
}

**************************************************************************
** DataEventSet implementation
**************************************************************************

@Js
internal const class MDataEventSet : MDataSet, DataEventSet
{
  new make(DataSet subjectSet, DataEvent[] events) : super.makeList(events)
  {
    this.subjectSet = subjectSet
    this.events = events
  }

  const override DataSet subjectSet
  const override DataEvent[] events
}

