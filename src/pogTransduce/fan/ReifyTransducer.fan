//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   21 Dec 2022  Brian Frank  Creation
//

using concurrent
using util
using pog

**
** Reify transducer
**
@Js
const class ReifyTransducer : Transducer
{
  new make(PogEnv env) : super(env, "reify") {}

  override Str summary()
  {
    "Construct a Proto tree from an AST object tree"
  }

  override Str usage()
  {
    """Summary:
         Construct a Proto tree from an AST object tree.  All
         qualified and relative names are resolved to their protos.
       Usage:
         reify ast:obj                Transform AST to Protos
       Arguments:
         obj                          AST object tree
       """
  }

  override Transduction transduce(Str:Obj? args)
  {
    cx := TransduceContext(this, args)
    return cx.toResult(Reifier(cx).reify)
  }

}

**************************************************************************
** Reifier
**************************************************************************

@Js
internal class Reifier : Resolver
{
  new make(TransduceContext cx) : super(cx) {}

  Proto reify()
  {
    resolveDepends
    root := reifyNode(QName(base), ast)
    refs.each |ref, qname| { resolveRef(qname, ref) }
    return root
  }

  private Proto reifyNode(QName qname, Str:Obj node)
  {
    loc      := cx.toLoc(node)
    isa      := ref(getOrInferIs(qname, node, loc))
    val      := node["_val"]
    children := MProto.noChildren

    node.each |v, n|
    {
      child := v as Str:Obj
      if (child == null) return
      if (children === MProto.noChildren)
      {
        children = Str:MProto[:]
        children.ordered = true
      }
      children.add(n, reifyNode(qname.add(n), child))
    }

    proto := MProto(loc, qname, isa, val, children)
    ref(qname.toStr).val = proto
    return proto
  }

  Str getOrInferIs(QName qname, Str:Obj node, FileLoc loc)
  {
    explicit := node["_is"]
    if (explicit != null) return explicit

    if (node["_val"] != null) return "sys.Str"
    return "sys.Dict"
  }

  AtomicRef ref(Str qname)
  {
    ref := refs[qname]
    if (ref == null) refs[qname] = ref = AtomicRef()
    return ref
  }

  Void resolveRef(Str qname, AtomicRef ref)
  {
    // short circuit if already resolved
    if (ref.val != null) return

    // any unresolved qnames must be in dependencies
    ref.val = resolveInDepends(qname) ?: throw Err("Unresolved depend qname: $qname")
  }

  Str:AtomicRef refs := [:]
}

**************************************************************************
** MProto
**************************************************************************

@Js
internal const class MProto : Proto
{
  new make(FileLoc loc, QName qname, AtomicRef isa, Obj? val, Str:MProto children)
  {
    this.loc      = loc
    this.qname    = qname
    this.isaRef   = isa
    this.valRef   = val
    this.children = children
  }

  override ProtoSpi spi() { throw Err("TODO") }

  override Str name() { qname.name }

  override const QName qname

  override Proto? isa() { isaRef.val }
  private const AtomicRef isaRef

  override Int tx() { 0 }

  override final Str toStr() { qname.toStr }

  override Bool hasVal() { valRef != null }

  override Obj? val(Bool checked := true)
  {
    if (valRef != null) return valRef
    return isa.val(checked)
  }
  private const Obj? valRef

  override Bool has(Str name)
  {
    if (hasOwn(name)) return true
    return isa.has(name)
  }

  override Bool hasOwn(Str name)
  {
    children.containsKey(name)
  }

  override final Proto? trap(Str name, Obj?[]? args := null)
  {
    get(name, true)
  }

  @Operator override Proto? get(Str name, Bool checked := true)
  {
    child := children.get(name, null) ?: isa.get(name)
    if (child != null) return child
    if (checked) throw UnknownProtoErr(name)
    return null
  }

  override Proto? getOwn(Str name, Bool checked := true)
  {
    child := children.get(name, null)
    if (child != null) return child
    if (checked) throw UnknownProtoErr(name)
    return null
  }

  internal const Str:Proto children

  override Void each(|Proto| f)
  {
    // expensive
    seen := Str:Str[:]
    eachSeen(seen, f)
  }

  override Void eachSeen(Str:Str seen, |Proto| f)
  {
    children.each |kid|
    {
      if (seen[kid.name] != null) return
      seen[kid.name] = kid.name
      f(kid)
    }
    isa.eachSeen(seen, f)
  }

  override Void eachOwn(|Proto| f)
  {
    children.each(f)
  }

  override Obj? eachOwnWhile(|Proto->Obj?| f)
  {
    children.eachWhile(f)
  }

  override Proto[] list()
  {
    acc := Proto[,]
    each |x| { acc.add(x) }
    return acc
  }

  override Proto[] listOwn()
  {
    children.vals
  }

  override Bool fits(Proto that)
  {
    this === that || isa.fits(that)
  }

  override const FileLoc loc

  override Void dump(OutStream out := Env.cur.out, [Str:Obj]? opts := null)
  {
    indent := opts?.get("indent") as Str ?: ""
    if (qname.isRoot)
    {
      out.print(isa)
    }
    else
    {
      out.print(indent).print(name)
      if (isa != null) out.print(": ").print(isa)
    }
    if (valRef != null) out.print(" ").print(valRef.toStr.toCode)
    if (children.size == 0) out.printLine
    else
    {
      kidOpts := (opts ?: Str:Obj?[:]).dup.set("indent", indent+"  ")
      out.printLine(" {")
      children.each |kid| { kid.dump(out, kidOpts) }
      out.print(indent).printLine("}")
    }
  }

  static const Str:Proto noChildren := [:] { ordered = true }
}

