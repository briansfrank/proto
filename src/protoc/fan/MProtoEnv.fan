//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using util
using proto

**
** Standard implementation for ProtoEnv
**
internal const class MProtoEnv : ProtoEnv
{
  ** Constructor
  new make()
  {
    this.path = initPath
    this.installedMap = initInstalled(this.path)
    this.installed = installedMap.keys.sort
  }

  private static File[] initPath()
  {
    fanPath := (Env.cur as PathEnv)?.path ?: File[Env.cur.homeDir]
    return fanPath.map |dir->File| { dir.plus(`pio/`) }
  }

  private static Str:File initInstalled(File[] path)
  {
    acc := Str:File[:]
    path.each |dir| { doInitInstalled(acc, "", dir) }
    return acc
  }

  private static Void doInitInstalled(Str:File acc, Str path, File dir)
  {
    hasLib := dir.plus(`lib.pio`).exists
    if (hasLib && !path.isEmpty)
    {
      dup := acc[path]
      if (dup != null) echo("WARN: ProtoEnv '$path' lib path hidden [$dup.osPath]")
      acc[path] = dir
    }
    dir.listDirs.each |kid|
    {
      if (!ProtoUtil.isName(kid.name)) return
      kidPath := StrBuf().add(path).join(kid.name, ".").toStr
      doInitInstalled(acc, kidPath, kid)
    }
  }

  ** List the library names installed by this environment
  const override Str[] installed

  ** Search path of directories from lowest to highest priority.  Standard
  ** behavior is to map 'pio/' directory of the Fantom `sys::Env` path.
  const override File[] path

  ** Install lib name to directory mapping
  const Str:File installedMap

  ** Return root directory for the given library name.  The result
  ** might be on the local file system or a directory within a pod file.
  ** Raise exception if library name is not installed.
  override File libDir(Str name)
  {
    installedMap[name] ?: throw UnknownLibErr("Not installed: $name")
  }

  ** Debug dump
  override Void dump(OutStream out := Env.cur.out)
  {
    out.printLine("=== ProtoEnv ===")
    out.printLine("Path:")
    path.each |x| { out.printLine("  $x.osPath") }
    out.printLine("Installed:")
    installed.each |x| { out.printLine("  $x [" + libDir(x).osPath + "]") }
  }

  ** Test main to dump
  static Void main() { cur.dump }
}