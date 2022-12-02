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
      genSlot(s, x)
    }

    type.gen = s.toStr.splitLines
  }

  Void genSlot(StrBuf s, Proto x)
  {
    doc := x.get("_doc")?.val(false) as Str
    if (doc != null)
      doc.splitLines.each |line| { s.add("  ** ").add(line).add("\n") }

    isList := x.fits(graph.sys->List)
    typeSig := typeSig(x, isList)

    s.add("  ").add(typeSig).add(" ").add(x.name).add("\n")
    s.add("  {\n")

    s.add("    get { get(\"").add(x.name).add("\")")
    if (isScalar(x)) s.add(".val")
    else if (isList) s.add(".listOwn")
    s.add(" }\n")

    s.add("    set { set(\"").add(x.name).add("\", it) }\n")
    s.add("  }\n")
  }

  Bool isScalar(Proto x)
  {
    if (x.qname == "sys.Scalar") return true
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

