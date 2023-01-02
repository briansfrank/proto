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

  override Obj? withInStream(|InStream->Obj?| f)
  {
    in := getInStream
    close := in !== Env.cur.in
    try
      return f(in)
    finally
      if (close) in.close
  }

  override Obj? withOutStream(|OutStream->Obj?| f)
  {
    out := getOutStream
    close := out !== Env.cur.out && out !== Env.cur.err
    try
      return f(out)
    finally
      if (close) out.close
  }

  override InStream getInStream()
  {
    if (val == "stdin") return Env.cur.in
    if (val is InStream) return val
    if (val is Str) return ((Str)val).in
    if (val is File) return ((File)val).in
    throw argErr("InStream")
  }

  override OutStream getOutStream()
  {
    if (val == null) return Env.cur.out
    if (val == "stdout") return Env.cur.out
    if (val == "stderr") return Env.cur.err
    if (val is OutStream) return val
    if (val is File) return ((File)val).out
    throw argErr("OutStream")
  }

  override Str getStr()
  {
    if (val is Str) return val
    throw argErr("Str")
  }

  override File getDir()
  {
    file := val as File
    if (file != null && file.isDir) return file
    throw argErr("Dir")
  }

  override Str:Obj? getAst()
  {
    map := val as Str:Obj?
    if (map != null) return map
    throw argErr("AST Str:Obj")
  }

  override Proto getProto()
  {
    proto := val as Proto
    if (proto != null) return proto
    throw argErr("Proto")
  }

  ArgErr argErr(Str expected) { ArgErr("Cannot get as $expected: ${val?.typeof} $tags") }
}

