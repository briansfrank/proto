//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Jul 2022  Brian Frank  Creation
//

using proto

**
** ResolveSys resolves the built-in sys protos into CSys
**
internal class ResolveSys : Step
{
  override Void run()
  {
    lib := libs.find |lib| { lib.name.toStr == "sys" }
    if (lib == null) throw err("Sys lib not found", Loc.inputs)

    compiler.sys = CSys
    {
      it.obj = resolve(lib, "Obj")
      it.str = resolve(lib, "Str")
    }
    bombIfErr
  }

  private CProto resolve(CLib lib, Str name)
  {
    lib.proto.child(name) ?: throw err("Sys type not found: sys.$name", lib.loc)
  }
}

