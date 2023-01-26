//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util
using data
using xeto

**
** DataType implementation
**
@Js
internal const class MDataFunc : MDataType, DataFunc
{

  new make(MDataLib lib, XetoObj ast, MDataType base)
    : super(lib, ast, base)
  {
    returns = slot("return")
    params = slots.findAll |s| { s.name != "return" }
  }

  override MDataEnv env() { libRef.env }
  override MDataLib lib() { libRef }
  override const DataSlot returns
  const override DataSlot[] params

  override DataSlot? param(Str name, Bool checked := true)
  {
    if (name != "return")
    {
      slot := slot(name, false)
      if (slot != null) return slot
    }
    if (checked) throw UnknownParamErr("${qname}.${name}")
    return null
  }

  override Obj? call(DataDict args)
  {
    method.call(args)
  }

  once Method method()
  {
    Str? pod
    switch (lib.qname)
    {
      case "sys.lint": pod = "dataLint"
      default: throw UnsupportedErr("No registered pod for DataFuncs: $lib.qname")
    }
    funcs := Pod.find(pod).type("Funcs")
    method := funcs.method(name.decapitalize)
    if (!method.isStatic) throw Err("DataFunc method must be static: $method")
    return method
  }

}