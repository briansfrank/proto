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
using pogEnv

**
** Reify transducer
**
@Js
const class ReifyTransducer : Transducer
{
  new make(PogEnv env) : super(env, "reify") {}

  override Str summary()
  {
    "Construct a proto tree from an JSON AST"
  }

  override Str usage()
  {
    """reify <ast>    Transform JSON AST to unvalidated proto
       """
  }

  override TransduceData transduce(Str:TransduceData args)
  {
    cx := TransduceContext(this, args)
    return Reifier(cx).reify
  }

}

**************************************************************************
** Reifier
**************************************************************************

@Js
internal class Reifier : Resolver
{
  new make(TransduceContext cx) : super(cx) {}

  TransduceData reify()
  {
    resolveDepends
    normalizeLibPragma
    root := reifyNode(QName(base), ast, this.loc)
    resolveRefs
    resolveIsInfers
    return cx.toResult(root, ["proto", "unvalidated"], loc)
  }

  private Void normalizeLibPragma()
  {
    // if pragma is a sys.Lib, then flatten it as root meta
    pragma := ast["pragma"] as Str:Obj
    if (pragma != null && pragma["_is"] == "sys.Lib")
    {
      newAst := pragma.findAll |v, n| { n.startsWith("_") }
      ast.each |v, n| { if (n != "pragma") newAst[n] = v }
      this.ast = newAst
    }
  }

  private Proto reifyNode(QName qname, Str:Obj node, FileLoc loc)
  {
    isObj := qname.toStr == "sys.Obj"
    isName := node["_is"]
    inferIs := isName == null

    isa      := inferIs ? AtomicRef(isName) : ref(isName)
    val      := node["_val"]
    children := MProtoInit.noChildren

    node.each |v, n|
    {
      child := v as Str:Obj
      if (child == null) return
      if (n == "_loc") return
      if (children.isImmutable)
      {
        children = Str:MProto[:]
        children.ordered = true
      }
      children.add(n, reifyNode(qname.add(n), child, cx.toLoc(child)))
    }

    proto := cx.instantiate(loc, qname, isa, val, children)
    ref(qname.toStr).val = proto
    if (inferIs && !isObj) isInfers.add(IsInfer(proto, isa))
    return proto
  }

  AtomicRef ref(Str qname)
  {
    ref := refs[qname]
    if (ref == null) refs[qname] = ref = AtomicRef(qname)
    return ref
  }

  Void resolveRefs()
  {
    refs.each |ref, qname| { resolveRef(qname, ref) }
  }

  Void resolveRef(Str qname, AtomicRef ref)
  {
    // short circuit if already resolved
    if (ref.val is Proto) return

    // any unresolved qnames must be in dependencies
    ref.val = resolveInDepends(qname) ?: throw Err("Unresolved depend qname: $qname")
  }

  Void resolveIsInfers()
  {
    // iterate in reverse so parents are inferred first
    isInfers.eachr |x| { x.isaRef.val = resolveIsInfer(x.proto) }
  }

  Proto resolveIsInfer(Proto p)
  {
     // infer from parent's inherited type
    inherited := resolveIsInferInherited(p)
    if (inherited != null) return inherited

    // fallback to Str/Dict
    return p.valOwn(false) != null  ? str.val : dict.val
  }

  Proto? resolveIsInferInherited(Proto p)
  {
    // resolve parent (its either already in my refs map or in a depdendency)
    parentQName := p.qname.parent.toStr
    Proto? parent := refs[parentQName]?.val ?: resolveInDepends(parentQName)
    if (parent == null) return null

    // get slot from parent's type
    slot := parent.isa?.get(p.name, false)
    if (slot == null) return null

    return slot.isa
  }

  Str:AtomicRef refs := [:]
  AtomicRef str := ref("sys.Str")
  AtomicRef dict := ref("sys.Dict")
  IsInfer[] isInfers := [,]
}

**************************************************************************
** IsInfer
**************************************************************************

@Js
internal const class IsInfer
{
  new make(Proto p, AtomicRef r) { proto = p; isaRef = r }
  const Proto proto
  const AtomicRef isaRef
}


