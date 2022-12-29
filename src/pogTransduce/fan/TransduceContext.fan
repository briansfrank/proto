//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   21 Dec 2022  Brian Frank  Creation
//

using concurrent
using util
using pog
using pogEnv

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

  ** Return if there was one or more error events
  Bool isErr() { events.any { it.level === TransduceEventLevel.err } }

  ** Log an error event
  Void err(Str msg, Obj loc, Err? cause := null)
  {
    event(MTransduceEvent(TransduceEventLevel.err, msg, toQName(loc), toLoc(loc), cause))
  }

  ** Get an argument by name
  Obj? arg(Str name, Bool checked := true, Type? type := null)
  {
    arg := args[name]
    if (arg != null)
    {
      if (type != null && !arg.typeof.fits(type))
        throw ArgErr("Expecting '$name' to be $type.signature, not $arg.typeof")
      return arg
    }
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
    if (arg == "stdout") return Env.cur.out
    throw ArgErr("Invalid write arg for $transducer.name transducer")
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
    loc := toLoc(arg)
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
      if (out !== Env.cur.out) out.close
  }

  ** Instantiate proto from initialization data
  Proto instantiate(FileLoc loc, QName qname, AtomicRef isa, Obj? val, [Str:Proto]? children)
  {
    ((MPogEnv)env).factory.instantiate(MProtoInit(loc, qname, isa, val, children))
  }

  ** Get a qualified name from a Proto
  QName? toQName(Obj x)
  {
    if (x is Proto) return ((Proto)x).qname
    return null
  }

  ** Get a file location from:
  **   - FileLoc return itself
  **   - Str:Obj assume its an AST node and get "_loc" value
  FileLoc toLoc(Obj x)
  {
    if (x is FileLoc) return x
    if (x is Proto) return ((Proto)x).loc
    if (x is File) return FileLoc.makeFile(x)
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
    return FileLoc.unknown
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
    return result
  }
}

**************************************************************************
** MTransduceEvent
**************************************************************************

** TransduceEvent implementation
@Js
const class MTransduceEvent : TransduceEvent
{
  new make(TransduceEventLevel level, Str msg, QName? qname, FileLoc loc, Err? err := null)
  {
    this.level = level
    this.msg   = msg
    this.loc   = loc
    this.qname = qname
    this.err   = err
  }

  const override TransduceEventLevel level
  const override Str msg
  const override FileLoc loc
  const override QName? qname
  const override Err? err

  override Str toStr()
  {
    s := StrBuf()
    if (!loc.isUnknown) s.add(loc).add(" ")
    s.add("[$level.name.upper] ")
    if (qname != null) s.add("'").add(qname).add("' ")
    s.add(msg)
    return s.toStr
  }
}


