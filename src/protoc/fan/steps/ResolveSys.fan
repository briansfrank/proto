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
      it.obj    = resolve(lib.proto, "Obj")
      it.str    = resolve(lib.proto, "Str")
      it.objDoc = resolve(obj, "_doc")
    }
    bombIfErr
  }

  private CProto resolve(CProto parent, Str name)
  {
    parent.child(name) ?: throw err("Sys type not found: ${parent.path}.$name", parent.loc)
  }
}

