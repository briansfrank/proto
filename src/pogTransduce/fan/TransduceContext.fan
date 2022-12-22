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
** Models state for transduce pipelines and resulting Transduction
**
@Js
class TransduceContext
{
  ** Constructor
  new make(Transducer transducer, Str:Obj? args)
  {
    this.transducer = transducer
    this.args       = args
  }

  ** Environment
  PogEnv env() { transducer.env }

  ** Parent transducer for context
  const Transducer transducer

  ** Arguments passed to transduce
  Str:Obj args

  ** Accumulated events
  MTransduceEvent[] events := [,]

  ** Log an event
  Void event(MTransduceEvent e)
  {
    events.add(e)
  }

  ** Log an error event
  Void err(Str msg, Obj loc, Err? cause := null)
  {
    event(MTransduceEvent(TransduceEventLevel.err, msg, toLoc(loc), cause))
  }

  ** Get an argument by name
  Obj? arg(Str name, Bool checked := true)
  {
    arg := args[name]
    if (arg != null) return arg
    if (checked) throw ArgErr("Missing argument: $name")
    return null
  }

  ** Convert arg into an input stream
  InStream toInStream(Obj arg)
  {
    if (arg is InStream) return arg
    if (arg is Str) return ((Str)arg).in
    if (arg is File) return ((File)arg).in
    throw ArgErr("Invalid read arg for $transducer.name transducer")
  }

  ** Convert arg into an output stream
  OutStream toOutStream(Obj arg)
  {
    if (arg is OutStream) return arg
    if (arg is File) return ((File)arg).out
    throw ArgErr("Invalid write arg for $transducer.name transducer")
  }

  ** Convert an arg into a file location
  FileLoc toFileLoc(Obj arg)
  {
    if (arg is File) return FileLoc.makeFile(arg)
    return FileLoc.unknown
  }

  ** Wrap result with current events
  MTransduction toResult(Obj? result)
  {
    MTransduction(transducer, result, events)
  }

  ** Standard read using 'read' arg as input stream and file location
  MTransduction read(|InStream, FileLoc->Obj?| f)
  {
    arg := arg("read")
    loc := toFileLoc(arg)
    in := toInStream(arg)
    try
      return toResult(f(in, loc))
    finally
      in.close
  }

  ** Standard write using 'write' arg as output stream
  MTransduction write(|OutStream->Obj?| f)
  {
    arg := arg("write")
    out := toOutStream(arg)
    try
      return toResult(f(out))
    finally
      out.close
  }

  ** Get a file location from:
  **   - FileLoc return itself
  **   - Str:Obj assume its an AST node and get "_loc" value
  FileLoc toLoc(Obj x)
  {
    if (x is FileLoc) return x
    if (x is Map)
    {
      loc := ((Map)x).get("_loc") as Str:Obj
      if (loc != null)
      {
        val := loc["_val"]
        if (val is FileLoc) return val
        if (val != null) return FileLoc.parse(val.toStr)
      }
      return FileLoc.unknown
    }
    throw Err("toLoc: $x [$x.typeof]")
  }

}

**************************************************************************
** MTransduction
**************************************************************************

** Transduction implementation
@Js
const class MTransduction : Transduction
{
  new make(Transducer transducer, Obj? result, MTransduceEvent[] events)
  {
    this.transducer = transducer
    this.result     = result
    this.events     = events
    this.errs       = events.findAll |e| { e.level === TransduceEventLevel.err }
    this.isOk       = errs.isEmpty
    this.isErr      = !isOk
  }

  const Transducer transducer
  const Obj? result
  const override Bool isOk
  const override Bool isErr
  const override TransduceEvent[] events
  const override TransduceEvent[] errs

  override Obj? get(Bool checked := true)
  {
    if (isOk) return result
    if (checked) throw TransduceErr("$transducer.name failed with $errs.size errs")
    return null
  }
}

**************************************************************************
** MTransduceEvent
**************************************************************************

** TransduceEvent implementation
@Js
const class MTransduceEvent : TransduceEvent
{
  new make(TransduceEventLevel level, Str msg, FileLoc loc, Err? err := null)
  {
    this.level = level
    this.msg   = msg
    this.loc   = loc
    this.err   = err
  }

  const override TransduceEventLevel level
  const override Str msg
  const override FileLoc loc
  const override Err? err

  override Str toStr()
  {
    s := StrBuf()
    if (!loc.isUnknown) s.add(loc).add(" ")
    s.add("[$level.name.upper] ")
    s.add(msg)
    return s.toStr
  }
}


