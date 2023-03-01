//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Feb 2023  Brian Frank  Creation
//

using concurrent
using util
using data2

**
** Assemble AST into implementation
**
@Js
internal class Assemble : Step
{
  override Void run()
  {
    if (isLib)
      compiler.lib = asmLib
    else
      compiler.data = asmData
  }

//////////////////////////////////////////////////////////////////////////
// Data
//////////////////////////////////////////////////////////////////////////

  private Obj? asmData()
  {
    // the actual data is in the root ast as "_0"
    ast := this.ast.slots.get("_0") ?: throw Err("asmData")

    // if value is a scalar, return it
    if (ast.val != null) return asmVal(ast)

    return asmDict(ast)
  }

//////////////////////////////////////////////////////////////////////////
// Lib + Specs
//////////////////////////////////////////////////////////////////////////

  private MLib asmLib()
  {
    // first pass creates slots
    lib := asmSpec(compiler.ast, compiler.qname, compiler.qname)

    // second pass for meta
    asmFinalize(compiler.ast)

    return lib
  }

  private MSpec asmSpec(AObj obj, Str qname, Str name)
  {
    loc      := obj.loc
    libRef   := ast.asmRef
    baseRef  := asmBase(obj)
    metaRef  := asmMetaRef(obj)
    declared := asmDeclared(obj, qname)
    val      := asmSpecVal(qname, obj)

    MSpec? spec
    if (obj.isLib)
      spec = MLib(env, loc, libRef, qname, name, baseRef, metaRef, declared)
    else if (obj.isType)
      spec = MType(env, loc, obj.asmRef, libRef, qname, name, baseRef, metaRef, declared, val)
    else
      spec = MSpec(env, loc, obj.asmRef, baseRef, metaRef, declared, val)

    obj.asmRef.val = spec
    return spec
  }

  private AtomicRef asmBase(AObj obj)
  {
    if (obj.spec.type == null) return AtomicRef()  // sys::Obj
    return obj.spec.type.resolved
  }

  private AtomicRef asmMetaRef(AObj obj)
  {
    if (obj.spec.meta.isEmpty) return emptyMetaRef
    obj.metaRef = AtomicRef()
    return obj.metaRef
  }

  private MSlots asmDeclared(AObj obj, Str qname)
  {
    slots := obj.slots
    if (slots.isEmpty) return MSlots.empty
    acc := Str:MSpec[:]
    acc.ordered = true
    slots.each |kid, name|
    {
      sep := obj.isLib ? "::" : "."
      acc.add(name, asmSpec(kid, qname + sep + name, name))
    }
    return MSlots(acc)
  }

  private Void asmFinalize(AObj obj)
  {
    asmMeta(obj)

    if (!obj.slots.isEmpty) obj.slots.each |kid| { asmFinalize(kid) }
  }

  private Void asmMeta(AObj obj)
  {
    // if metaRef null, then we used emptyDict ref
    if (obj.metaRef == null) return

    acc := Str:Obj[:]
    obj.spec.meta.each |kid, name|
    {
      acc.add(name, asmVal(kid))
    }
    obj.metaRef.val = env.dict(acc)
  }

//////////////////////////////////////////////////////////////////////////
// Values
//////////////////////////////////////////////////////////////////////////

  private Obj? asmSpecVal(Str qname, AObj obj)
  {
    if (obj.val == null) return null
    mapping := env.factory.fromXeto[qname]
    if (mapping != null) return asmFantom(mapping, obj.val, obj.loc)
    return obj.val
  }

  private Obj? asmVal(AObj obj)
  {
    if (obj.val != null) return asmScalar(obj)
// TODO
if (obj.isSpec) return obj.spec.type.resolved.val
    return asmDict(obj)
  }

  private Obj? asmScalar(AObj obj)
  {
    // AST ref is whatever it resolves to
    val := obj.val
    if (val is ARef) return ((ARef)val).resolved.val
    if (val is ASpec) return asmNestedSpec(val)

    // Recurse if value is a list
    if (val is List)
    {
      list := (List)val
      if (list.of === ARef#) return list.map |ARef r->DataSpec| { r.resolved.val }
      return list
    }

    // TODO: every object should have type at some point
    if (obj.spec.type == null) return val

    // map to Fantom type if still a string
    qname := obj.spec.type.resolvedType.qname
    mapping := env.factory.fromXeto[qname]
    if (mapping != null) return asmFantom(mapping, val, obj.loc)

    // fallback to string
    return val
  }

  private MSpec asmNestedSpec(ASpec spec)
  {
spec.meta.each |v, n|
{
  v.isSpec = true
}

    if (spec.isTypeOnly) return spec.type.resolved.val

    shim := AObj(spec.type.loc)
    shim.spec = spec
    asm := asmSpec(shim, "unused", "unused")
    asmMeta(shim)
    return asm
  }

  private DataDict asmDict(AObj obj)
  {
    if (obj.slots.isEmpty && obj.spec.type == null) return env.emptyDict

    spec := obj.spec.type?.resolvedType
    if (!obj.spec.meta.isEmpty) err("Data spec with meta not supported", obj.loc)

    acc := Str:Obj[:]
    acc.ordered = true
    obj.slots.each |kid, name|
    {
      acc.addNotNull(name, asmVal(kid))
    }

    return env.dict(acc, spec)
  }

  private Obj? asmFantom(XetoScalarType mapping, Obj val, FileLoc loc)
  {
    // if already typed, then return it
    if (val isnot Str) return val

    // if string type
    if (mapping.isStr) return val.toStr

    // lookup fromStr method
    fromStr := mapping.fantom.method("fromStr", false)
    if (fromStr == null)
    {
      err("Fantom type '$mapping.fantom' missing fromStr", loc)
      return val
    }

    try
    {
      return fromStr.call(val)
    }
    catch (Err e)
    {
      err("Invalid '$mapping.xeto' value: $val.toStr.toCode", loc)
      return val
    }
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  once AtomicRef emptyMetaRef() { AtomicRef(env.emptyDict) }
}