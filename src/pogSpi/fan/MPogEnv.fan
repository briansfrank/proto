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
abstract const class MPogEnv : PogEnv
{
  ** Factory to map to/from Protos and Fantom types
  abstract  MFactory factory()
}

**************************************************************************
** LocalPogEnv
**************************************************************************

**
** Environment with access to local file system
**
const class LocalPogEnv : MPogEnv
{
  ** Constructor
  new make()
  {
    this.path = initPath
    this.installedMap = initInstalled(this.path)
    this.installed = installedMap.keys.sort
    this.io = MPogEnvIO.init(this)
    this.factory = MFactory(this)
    this.transducersMap = initTransducers(this)
    this.transducers = transducersMap.vals.sort
  }

  private static File[] initPath()
  {
    fanPath := (Env.cur as PathEnv)?.path ?: File[Env.cur.homeDir]
    return fanPath.map |dir->File| { dir.plus(`pog/`) }
  }

  private static Str:File initInstalled(File[] path)
  {
    acc := Str:File[:]
    path.each |pogDir|
    {
      pogDir.listDirs.each |dir|
      {
        doInitInstalled(acc, dir)
      }
    }
    return acc
  }

  private static Void doInitInstalled(Str:File acc, File dir)
  {
    hasLib := dir.plus(`lib.pog`).exists
    if (!hasLib) return

    qname := dir.name
    dup := acc[qname]
    if (dup != null) echo("WARN: PogEnv '$qname' lib hidden [$dup.osPath]")
    acc[qname] = dir
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

  ** List the library names installed by this environment
  const override Str[] installed

  ** Search path of directories from lowest to highest priority.  Standard
  ** behavior is to map 'pog/' directory of the Fantom `sys::Env` path.
  const override File[] path

  ** Install lib name to directory mapping
  const Str:File installedMap

  ** Factory to map to/from Protos and Fantom types
  const override MFactory factory

  ** Is given library qname installed
  override Bool isInstalled(Str libName) { installedMap[libName] != null }

  ** Return root directory for the given library name.  The result
  ** might be on the local file system or a directory within a pod file.
  ** Raise exception if library name is not installed.
  override File? libDir(Str qname, Bool checked := true)
  {
    dir := installedMap[qname]
    if (dir != null) return dir
    if (checked) throw UnknownLibErr("Not installed: $qname")
    return null
  }

  ** List the installed transducers
  override const Transducer[] transducers

  ** Lookup a transducer by name
  override Transducer? transducer(Str name, Bool checked := true)
  {
    t := transducersMap[name]
    if (t != null) return t
    if (checked) throw UnknownTransducerErr(name)
    return null
  }
  private const Str:Transducer transducersMap

  ** I/O regsitry
  override const PogEnvIO io

  ** Compile a new namespace from a list of library names.
  ** Raise exception if there are any compiler errors.
  override Graph create(Str[] libNames)
  {
    Slot.findMethod("pogc::ProtoCompiler.create").call(this, libNames)
  }

  ** Debug dump
  override Void dump(OutStream out := Env.cur.out)
  {
    out.printLine("=== PogEnv ===")
    out.printLine("Path:")
    path.each |x| { out.printLine("  $x.osPath") }
    out.printLine("Installed:")
    installed.each |x| { out.printLine("  $x [" + libDir(x).osPath + "]") }
  }

  ** Test main to dump
  static Void main() { cur.dump }
}

**************************************************************************
** MPogEnvIO
**************************************************************************

@Js
internal const class MPogEnvIO : PogEnvIO
{
  static MPogEnvIO init(PogEnv env)
  {
    acc := Str:PogIO[:]
    Env.cur.index("pog.io").each |qname|
    {
      try
      {
        io := (PogIO)Type.find(qname).make([env])
        acc.add(io.name, io)
      }
      catch (Err e)
      {
        echo("ERROR: cannot init PogIO: $qname\n$e.traceToStr")
      }
    }
    return make(acc)
  }

  private new make(Str:PogIO map)
  {
    this.map = map
    this.list = map.vals.sort |a, b| { a.name <=> b.name }
  }

  const override PogIO[] list

  const Str:PogIO map

  override PogIO? get(Str name, Bool checked := true)
  {
    io := map[name]
    if (io != null) return io
    if (checked) throw Err("Unknown PogIO format: $name")
    return null
  }
}

