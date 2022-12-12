//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Jul 2022  Brian Frank  Creation
//

using util
using pog

**
** ResolveSys resolves the built-in sys protos into CSys
**
internal class ResolveSys : Step
{
  override Void run()
  {
    lib := libs.find |lib| { lib.isSys }
    if (lib == null) throw err("Must include 'sys' lib", FileLoc.inputs)

    compiler.sys = CSys
    {
      it.sys    = lib
      it.obj    = resolve(lib.proto, "Obj")
      it.marker = resolve(lib.proto, "Marker")
      it.str    = resolve(lib.proto, "Str")
      it.dict   = resolve(lib.proto, "Dict")
      it.list   = resolve(lib.proto, "List")
      it.objDoc = resolve(obj, "_doc")
    }

    root.type = CType(root.loc, sys.dict)

    bombIfErr
  }

  private CProto resolve(CProto parent, Str name)
  {
    parent.getOwn(name, false) ?: throw err("Sys type not found: ${parent.qname}.$name", parent.loc)
  }
}

