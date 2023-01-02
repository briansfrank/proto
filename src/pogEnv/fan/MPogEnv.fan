//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using util
using pog

**
** Standard implementation for PogEnv
**
@Js
const class MPogEnv : PogEnv
{
  ** Constructor
  new make()
  {
    this.libMgr = MLibMgr(this)
    this.transducersMap = initTransducers(this)
    this.transducers = transducersMap.vals.sort
    this.factory = MFactory(this)
  }

  static Str:Transducer initTransducers(PogEnv env)
  {
    acc := Str:Transducer[:]
    Env.cur.index("pog.transducer").each |qname|
    {
      try
      {
        io := (Transducer)Type.find(qname).make([env])
        acc.add(io.name, io)
      }
      catch (Err e)
      {
        echo("ERROR: cannot init pog::Transducer: $qname\n$e.traceToStr")
      }
    }
    return acc
  }

//////////////////////////////////////////////////////////////////////////
// Libs
//////////////////////////////////////////////////////////////////////////

  internal const MLibMgr libMgr

  override File[] path() { libMgr.path }

  override Str[] installed()  { libMgr.installed }

  override Bool isInstalled(Str qname) { libMgr.isInstalled(qname) }

  override File? libDir(Str qname, Bool checked := true) { libMgr.libDir(qname, checked) }

  override Lib? load(Str qname, Bool checked := true) { libMgr.load(qname, checked) }

//////////////////////////////////////////////////////////////////////////
// Transducers
//////////////////////////////////////////////////////////////////////////

  override TransduceData data(Obj? val, Str[]? tags := null, FileLoc? loc := null, TransduceEvent[]? events := null)
  {
    MTransduceData(val, tags, loc, events)
  }

  override const Transducer[] transducers

  override Transducer? transducer(Str name, Bool checked := true)
  {
    t := transducersMap[name]
    if (t != null) return t
    if (checked) throw UnknownTransducerErr(name)
    return null
  }
  private const Str:Transducer transducersMap

//////////////////////////////////////////////////////////////////////////
// Misc
//////////////////////////////////////////////////////////////////////////

  const MFactory factory

  override Void dump(OutStream out := Env.cur.out)
  {
    out.printLine("=== PogEnv ===")
    out.printLine("Path:")
    path.each |x| { out.printLine("  $x.osPath") }
    out.printLine("Installed:")
    installed.each |x| { out.printLine("  $x [" + libDir(x).osPath + "]") }
  }

}