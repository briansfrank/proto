//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Jul 2022  Brian Frank  Creation
//

using proto

**
** Initialize the input libNames to CLibs
**
internal class InitLibs : Step
{
  override Void run()
  {
    createRoot
    checkDups
    initLibs
    bombIfErr
  }

  private Void createRoot()
  {
    compiler.root = CProto(Loc.synthetic, "")
  }

  private Void checkDups()
  {
    names := Str:Str[:]
    libNames.each |name|
    {
      if (names[name] != null) err("Duplicate lib name: $name", Loc.inputs)
      names[name] = name
    }
  }

  private Void initLibs()
  {
    acc := CLib[,] { it.capacity = libNames.size }
    libNames.dup.sort.each |name| { acc.addNotNull(initLib(name)) }
    compiler.libs = acc
  }

  private CLib? initLib(Str name)
  {
    // resolve lib name to its source directory
    dir := env.libDir(name, false)
    if (dir == null)
    {
      if (name.contains("#")) return initSrcLib(name)
      err("Lib not installed: $name", Loc.inputs)
      return null
    }

    // resolve source files
    src := dir.list.findAll |f| { f.ext == "pog" }
    libFile := src.find |f| { f.name == "lib.pog" }
    if (libFile == null) { err("Missing lib.pog: $name", Loc(dir)); return null }
    src.moveTo(libFile, 0)

    // create lib and its proto
    loc := Loc(dir)
    path := Path(name)
    return CLib(loc, path, dir, src, initProto(loc, path))
  }

  private CLib initSrcLib(Str src)
  {
    // this is backdoor hook to pass the source string for as lib
    // formatted as "libName #<> ...."
    pound := src.index("#")
    name := src[0..<pound].trim
    file := src[pound..-1].toBuf.toFile(`lib.pog`)

    loc := Loc("memory")
    path := Path(name)
    return CLib(loc, path, Env.cur.workDir, [file], initProto(loc, path))
  }

  private CProto initProto(Loc loc, Path path)
  {
    // build path of generic protos to base of lib itself
    libBase := root
    for (i := 0; i<path.size-1; ++i)
    {
      n := path[i]
      x := libBase.child(n)
      if (x == null) addSlot(libBase, x = CProto(Loc.synthetic, n))
      libBase = x
    }

    // build Lib object itself
    proto := CProto(loc, path.name, null, CType(loc, "sys.Lib"))
    proto.isLib = true
    addSlot(libBase, proto)
    return proto
  }
}