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
    if (val is Proto) return ["proto"]
    if (val is File) return ((File)val).isDir ? ["dir"] : ["file"]
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
    s := StrBuf()
    if (tags.isEmpty)
    {
      if (val == null) s.add("Null")
      else s.add(val.typeof.name)
    }
    else
    {
      s.add(tags[0].capitalize)
      if (tags.size > 1) s.add(" (").add(tags[1..-1].join(" ")).add(")")
    }
    if (!loc.isUnknown) s.add(" [").add(loc).add("]")
    if (val is Str) s.add(" ").add(val.toStr.toCode)
    if (val is Bool) s.add(" ").add(val.toStr)
    return s.toStr
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

  override InStream? getInStream(Bool checked := true)
  {
    if (val == "stdin") return Env.cur.in
    if (val is InStream) return val
    if (val is Str) return ((Str)val).in
    if (val is File) return ((File)val).in
    return argErr("InStream", checked)
  }

  override OutStream? getOutStream(Bool checked := true)
  {
    if (val == null) return Env.cur.out
    if (val == "stdout") return Env.cur.out
    if (val == "stderr") return Env.cur.err
    if (val is OutStream) return val
    if (val is File) return ((File)val).out
    return argErr("OutStream", checked)
  }

  override Str? getStr(Bool checked := true)
  {
    if (val is Str) return val
    return argErr("Str", checked)
  }

  override File? getFile(Bool checked := true)
  {
    file := val as File
    if (file != null) return file
    return argErr("File", checked)
  }

  override File? getDir(Bool checked := true)
  {
    file := val as File
    if (file != null && file.isDir) return file
    return argErr("Dir", checked)
  }

  override [Str:Obj?]? getAst(Bool checked := true)
  {
    map := val as Str:Obj?
    if (map != null) return map
    return argErr("AST Str:Obj", checked)
  }

  override Proto? getProto(Bool checked := true)
  {
    proto := val as Proto
    if (proto != null) return proto
    return argErr("Proto", checked)
  }

  override Obj? getAs(Type expected, Bool checked := true)
  {
    if (val != null && val.typeof.fits(expected)) return val
    return argErr(expected.name, checked)
  }

  Obj? argErr(Str expected, Bool checked)
  {
    if (checked) throw ArgErr("Cannot get as $expected: ${val?.typeof} $tags")
    return null
  }
}

