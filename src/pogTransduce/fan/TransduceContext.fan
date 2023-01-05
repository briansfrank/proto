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
  new make(Transducer transducer, Str:TransduceData args)
  {
    this.transducer = transducer
    this.args       = args
    this.isTest     = args["isTest"]?.get(false) == true
  }

  ** Environment
  PogEnv env() { transducer.env }

  ** Parent transducer for context
  const Transducer transducer

  ** Are we running within the test suite
  const Bool isTest

  ** Arguments passed to transduce
  Str:TransduceData args

  ** Is given argument defined
  Bool hasArg(Str name) { args[name] != null }

  ** Accumulated events
  MTransduceEvent[] events := [,]

  ** Explicit base qname from arguments or auto-generate one
  once QName base()
  {
    base := args["base"]?.getStr
    if (base == null) base = "_" + baseCounter.getAndIncrement
    return QName.fromStr(base)
  }
  private static const AtomicInt baseCounter := AtomicInt()

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
  TransduceData? arg(Str name, Bool checked := true)
  {
    arg := args[name]
    if (arg != null) return arg
    if (checked) throw ArgErr("Missing argument: $name")
    return null
  }

  ** Get standard "it" argument
  TransduceData? argIt(Bool checked := true)
  {
    arg("it", checked)
  }

  ** Get standard write "to" arg or default to stdout
  TransduceData argWriteTo()
  {
    arg("to", false) ?: env.data(Env.cur.out, ["stdout"])
  }

  ** Get an arg which is a proto or pog soruce
  Proto? argToProto(Str name, Bool checked := true)
  {
    arg := arg(name, checked)
    if (arg == null) return null
    proto := arg.getProto(false)
    if (proto != null) return proto
    src := arg.getStr(false)
    if (src != null) return env.transduce("compile", ["it":arg]).getProto
    throw ArgErr("Cannot coerce arg '$name' to proto: $arg")
  }

  ** Wrap result with current events
  TransduceData toResult(Obj? val, Str[] tags, FileLoc loc)
  {
    if (val is TransduceData) throw Err("Already data")
    return MTransduceData(val, tags, loc, events)
  }

  ** Get a qualified name from a Proto
  QName? toQName(Obj x)
  {
    if (x is Proto) return ((Proto)x).qname
    return null
  }

  ** Coerce an object to its location
  FileLoc toLoc(Obj? x)
  {
    if (x is TransduceData) return ((TransduceData)x).loc
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

  ** Instantiate proto from initialization data
  Proto instantiate(FileLoc loc, QName qname, AtomicRef isa, Obj? val, [Str:Proto]? children)
  {
    ((MPogEnv)env).factory.instantiate(MProtoInit(loc, qname, isa, val, children))
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


