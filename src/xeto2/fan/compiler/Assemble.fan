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

    MSpec? spec
    if (obj.isLib)
      spec = MLib(env, loc, libRef, qname, name, baseRef, metaRef, declared)
    else if (obj.isType)
      spec = MType(env, loc, obj.asmRef, libRef, qname, name, baseRef, metaRef, declared, obj.val)
    else
      spec = MSpec(env, loc, obj.asmRef, baseRef, metaRef, declared, obj.val)

    obj.asmRef.val = spec
    return spec
  }

  private AtomicRef asmBase(AObj obj)
  {
    if (obj.type == null) return AtomicRef()  // sys::Obj
    return obj.type.resolved
  }

  private AtomicRef asmMetaRef(AObj obj)
  {
    if (obj.meta == null || obj.meta.isEmpty) return emptyMetaRef
    obj.metaRef = AtomicRef()
    return obj.metaRef
  }

  private MSlots asmDeclared(AObj obj, Str qname)
  {
    slots := obj.slots
    if (slots == null || slots.isEmpty) return MSlots.empty
    acc := Str:MSpec[:]
    acc.ordered = true
    slots.each |kid|
    {
      name := kid.name
      sep := obj.isLib ? "::" : "."
      acc.add(name, asmSpec(kid, qname + sep + name, name))
    }
    return MSlots(acc)
  }

  private Void asmFinalize(AObj obj)
  {
    asmMeta(obj)

    if (obj.slots != null) obj.slots.each |kid| { asmFinalize(kid) }
  }

  private Void asmMeta(AObj obj)
  {
    // if metaRef null, then we used emptyDict ref
    if (obj.metaRef == null) return

    acc := Str:Obj[:]
    obj.meta.each |kid|
    {
      if (kid.val == null) return // TODO
      acc.add(kid.name, asmVal(kid))
    }
    obj.metaRef.val = env.dict(acc)
  }

//////////////////////////////////////////////////////////////////////////
// Values
//////////////////////////////////////////////////////////////////////////

  private Obj? asmVal(AObj obj)
  {
    if (obj.val != null) return asmScalar(obj)
    return asmDict(obj)
  }

  private Obj? asmScalar(AObj obj)
  {
    // AST ref is whatever it resolves to
    val := obj.val
    if (val is ARef) return ((ARef)val).resolved.val

    // Recurse if value is a list
    if (val is List)
    {
      list := (List)val
      if (list.of === ARef#) return list.map |ARef r->DataSpec| { r.resolved.val }
      return list
    }

    // TODO: every object should have type at some point
    if (obj.type == null) return val

    // map to Fantom type if still a string
    qname := obj.type.resolvedType.qname
    mapping := env.factory.fromXeto[qname]
    if (mapping != null) return asmFantom(mapping, val, obj.loc)

    // fallback to string
    return val
  }

  private DataDict asmDict(AObj obj)
  {
    if (obj.slots == null || obj.slots.isEmpty && obj.type == null) return env.emptyDict

    spec := obj.type?.resolvedType
    if (obj.meta != null) err("Data spec with meta not supported", obj.loc)

    acc := Str:Obj[:]
    acc.ordered = true
    obj.slots.each |kid|
    {
       acc.addNotNull(kid.name, asmVal(kid))
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