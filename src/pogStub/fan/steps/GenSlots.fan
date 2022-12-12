//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   7 Aug 2022  Brian Frank  Creation
//

using util
using pog

**
** Generate Fantom source code for node slots
**
internal class GenSlots : Step
{
  override Void run()
  {
    info("GenSlots")
    pods.each |pod| { genPod(pod) }
  }

  Void genPod(PodSrc pod)
  {
    pod.types.each |type| { genType(type) }
  }

  Void genType(TypeSrc type)
  {
    s := StrBuf()
    type.proto.eachOwn |x|
    {
      if (x.name.startsWith("_")) return  // skip meta
      if (type.proto.type.has(x.name)) return // skip inherited
      s.add("\n")
      genSlot(type, s, x)
    }

    if (type.isEnum) s.removeRange(-2..-2)  // remove last comma

    type.gen = s.toStr.splitLines
  }

  Void genSlot(TypeSrc type, StrBuf s, Proto x)
  {
    // fandoc
    doc := x.get("_doc")?.val(false) as Str
    if (doc != null)
      doc.splitLines.each |line| { s.add("  ** ").add(line).add("\n") }


    // if this is an enum, then just comma
    if (type.isEnum) return s.add("  ").add(x.name).add(",\n")

    // field getter/setter
    sig := TypeSig.map(graph, x)
    s.add("  ").add(sig.toStr).add(" ").add(x.name).add("\n")
    s.add("  {\n")

    s.add("    get { get(\"").add(x.name).add("\"").add(sig.isMaybe ? ", false)" : ")")
    if (sig.isScalar) s.add(sig.isMaybe ? "?.val" : ".val")
    else if (sig.isList) s.add(sig.isMaybe ? "?.listOwn" : ".listOwn")
    s.add(" }\n")

    s.add("    set { set(\"").add(x.name).add("\", it) }\n")
    s.add("  }\n")
  }

  Bool isScalar(Proto x)
  {
    if (x.qname.toStr == "sys.Scalar") return true
    if (x.type == null) return false
    return isScalar(x.type)
  }

  Str typeSig(Proto x, Bool isList)
  {
    if (isList)
    {
      of := x.getOwn("_of", false)
      if (of == null) return "Obj[]"
      return typeSig(of, false) + "[]"
    }
    type := x.type
    if (type.name == "Obj") return "Proto"
    return type.name
  }

}

**************************************************************************
** TypeSig
**************************************************************************

** Map Proto to Fantom type signature
internal const class TypeSig
{
  static TypeSig map(Graph graph, Proto? proto)
  {
    if (proto == null) return TypeSig("Obj", 0)
    if (proto.type == null) return TypeSig("Proto", 0)

    isList := proto.fits(graph.sys->List)
    if (isList)
    {
      of := map(graph, proto.get("_of", false))
      return make(of.sig+"[]", list)
    }

    isMaybe := proto.type?.qname?.toStr == "sys.Maybe"
    if (isMaybe)
    {
      of := map(graph, proto.get("_of", false))
      return make(of.sig+"?", of.flags.or(maybe))
    }

    isEnum := proto.fits(graph.sys->Enum)
    isScalar := proto.fits(graph.sys->Scalar)

    flags := 0
    if (isEnum)   flags = flags.or(scalar)
    if (isScalar) flags = flags.or(scalar)

    name := proto.type.name
    if (name == "Obj") name = "Proto"

    return make(name, flags)
  }

  private new make(Str sig, Int flags)
  {
    this.sig = sig
    this.flags = flags
  }

  static const Int scalar := 0x01
  static const Int list   := 0x02
  static const Int maybe  := 0x04

  const Str sig
  const Int flags
  Bool isScalar() { flags.and(scalar) != 0 }
  Bool isList()   { flags.and(list)   != 0 }
  Bool isMaybe()  { flags.and(maybe)  != 0 }
  override Str toStr() { sig }
}