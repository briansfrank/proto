//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Feb 2023  Brian Frank  Creation
//

using concurrent
using data2

**
** Assemble AST into implementation
**
@Js
internal class Assemble : Step
{
  override Void run()
  {
    compiler.lib = asmSpec(compiler.ast, compiler.qname, compiler.qname)
  }

  private MSpec asmSpec(AObj obj, Str qname, Str name)
  {
    loc      := obj.loc
    libRef   := ast.asmRef
    baseRef  := asmBase(obj)
    meta     := asmMeta(obj)
    declared := asmDeclared(obj, qname)

    spec := obj.isLib ?
      MLib(env, loc, libRef, qname, name, baseRef, meta, declared) :
      MSpec(loc, libRef, qname, name, baseRef, meta, declared, obj.val)

    obj.asmRef.val = spec
    return spec
  }

  private AtomicRef asmBase(AObj obj)
  {
    if (obj.type == null) return AtomicRef()  // sys::Obj
    return obj.type.resolved.asmRef
  }

  private DataDict asmMeta(AObj obj)
  {
    meta := obj.meta
    if (meta == null || meta.isEmpty) return env.emptyDict
    acc := Str:Obj[:]
    meta.each |kid|
    {
      acc.addNotNull(kid.name, asmVal(kid))
    }
    return env.dict(acc)
  }

  private Obj? asmVal(AObj obj)
  {
    obj.val
  }

  private Str:MSpec asmDeclared(AObj obj, Str qname)
  {
    slots := obj.slots
    if (slots == null || slots.isEmpty) return noDeclared
    acc := Str:MSpec[:]
    slots.each |kid|
    {
      name := kid.name
      sep := obj.isLib ? "::" : "."
      acc.add(name, asmSpec(kid, qname + sep + name, name))
    }
    return acc
  }

  static const Str:MSpec noDeclared := [:]

}