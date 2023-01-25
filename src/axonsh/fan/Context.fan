//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   24 Jan 2023  Brian Frank  Creation
//

using haystackx
using axonx

**
** Session context
**
internal class Context : AxonContext
{
  new make(Session session)
  {
    this.session = session
    this.funcs = loadFuncs
  }

  static Str:TopFn loadFuncs()
  {
    acc := Str:TopFn[:]
    acc.addAll(FantomFn.reflectType(CoreLib#))
    acc.addAll(FantomFn.reflectType(ShellFuncs#))
    return acc
  }

  Session session

  const Str:TopFn funcs

  override Namespace ns()
  {
    throw Err("TODO")
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
}