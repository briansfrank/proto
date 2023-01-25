//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   24 Jan 2023  Brian Frank  Creation
//

using data
using haystackx
using haystackx::UnknownFuncErr
using axonx

**
** Session context
**
internal class Context : AxonContext
{
  new make(Session session)
  {
    this.session = session
    this.data = DataEnv.cur
    this.funcs = loadFuncs

    importDataLib("sys")
    importDataLib("ph")
  }

  static Str:TopFn loadFuncs()
  {
    acc := Str:TopFn[:]
    acc.addAll(FantomFn.reflectType(CoreLib#))
    acc.addAll(FantomFn.reflectType(ShellFuncs#))
    return acc
  }

  Session session

  const DataEnv data

  const Str:TopFn funcs

  Str:DataLib libs := [:]

  override Namespace ns()
  {
    throw Err("TODO")
  }

  override DataType? findType(Str name, Bool checked := true)
  {
    acc := DataType[,]
    libs.each |lib| { acc.addNotNull(lib.libType(name, false)) }
    if (acc.size == 1) return acc[0]
    if (acc.size > 1) throw Err("Ambiguous types for '$name' $acc")
    if (checked) throw UnknownTypeErr(name)
    return null
  }

  override Fn? findTop(Str name, Bool checked := true)
  {
    f := funcs[name]
    if (f != null) return f
    if (checked) throw UnknownFuncErr(name)
    return null
  }

  override Dict? deref(Ref id)
  {
    throw Err("TODO")
  }

  override FilterInference inference()
  {
    throw Err("TODO")
  }

  override Dict toDict()
  {
    throw Err("TODO")
  }

  DataLib importDataLib(Str qname)
  {
    lib := libs[qname]
    if (lib == null)
    {
      libs[qname] = lib = data.lib(qname)
    }
    return lib
  }

}