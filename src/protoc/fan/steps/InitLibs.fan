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
    checkDups
    acc := CLib[,] { it.capacity = libNames.size }
    libNames.each |name| { acc.addNotNull(init(name)) }
    compiler.libs = acc
    bombIfErr
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

  private CLib? init(Str name)
  {
    // resolve lib name to its source directory
    dir := env.libDir(name, false)
    if (dir == null) { err("Lib not installed: $name", Loc.inputs); return null }

    // resolve source files
    src := dir.list.findAll |f| { f.ext == "pog" }
    libFile := src.find |f| { f.name == "lib.pog" }
    if (libFile == null) { err("Missing lib.pog: $name", Loc(dir)); return null }
    src.moveTo(libFile, 0)

    return CLib(Path(name), dir, src)
  }
}