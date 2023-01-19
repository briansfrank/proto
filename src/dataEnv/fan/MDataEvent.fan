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

  override DataDict val() { this }

  override Bool has(Str name) { get(name, null) != null }

  override Bool missing(Str name) { get(name, null) == null }

  override Bool isEmpty() { false }

  override Obj? get(Str name, Obj? def := null)
  {
    if (name == "level")     return level
    if (name == "subjectId") return subjectId ?: def
    if (name == "msg")       return msg
    if (name == "loc")       return loc
    if (name == "err")       return err ?: def
    return def
  }

  override Void each(|Obj?,Str| f)
  {
    eachWhile |v, n| { f(v, n); return null }
  }

  override Obj? eachWhile(|Obj?,Str->Obj?| f)
  {
    r := f(level, "level"); if (r != null) return f
    if (subjectId != null) { r = f(subjectId, "subjectId"); if (r != null) return r }
    r = f(msg, "msg"); if (r != null) return r
    r = f(loc, "loc"); if (r != null) return r
    r = f(err, "err"); if (r != null) return r
    return null
  }

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
  new make(DataSet subjectSet, DataEvent[] events) : super(subjectSet.env, listToMap(events))
  {
    this.subjectSet = subjectSet
    this.events = events
  }

  const override DataSet subjectSet
  const override DataEvent[] events
  override MDataEnv env() { envRef }
}

