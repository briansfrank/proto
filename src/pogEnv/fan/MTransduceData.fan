//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   21 Dec 2022  Brian Frank  Creation
//

using util
using pog

**
** MTransduceData is implementation of TransduceData
**
@Js
class MTransduceData : TransduceData
{
  new make(Obj? val, Str[]? tags, FileLoc? loc, TransduceEvent[]? events)
  {
    this.val    = val
    this.tags   = initTags(val, tags)
    this.loc    = initLoc(val, loc)
    this.events = events ?: TransduceEvent#.emptyList
    this.errs   = this.events.findAll |e| { e.level === TransduceEventLevel.err }
    this.isOk   = errs.isEmpty
    this.isErr  = !isOk
  }

  private static Str[] initTags(Obj? val, Str[]? tags)
  {
    if (tags != null) return tags
    if (val is Proto) return Str["proto"]
    if (val is File) return Str["file"]
    return Str#.emptyList
  }

  private static FileLoc initLoc(Obj? val, FileLoc? loc)
  {
    if (loc != null) return loc
    if (val is File) return FileLoc.makeFile(val)
    return FileLoc.unknown
  }

  Obj? val
  const override Str[] tags
  const override FileLoc loc
  const override Bool isOk
  const override Bool isErr
  const override TransduceEvent[] events
  const override TransduceEvent[] errs

  override Str toStr()
  {
    if (tags.isEmpty) return val == null ? "Null" : val.typeof.name
    str := tags[0].capitalize
    if (tags.size > 1) str += " (" + tags[1..-1].join(" ") + ")"
    return str
  }

  override Obj? get(Bool checked := true)
  {
    if (isOk) return val
    if (checked) throw TransduceErr("Failed with $errs.size errs")
    return val
  }
}

