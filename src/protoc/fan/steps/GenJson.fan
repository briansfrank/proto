//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Aug 2022  Brian Frank  Creation
//

using proto

**
** Generate a JSON file for the proto space
**
internal class GenJson : Step
{
  override Void run()
  {
    file := compiler.outDir + `protos.json`

    out := GenJsonOutStream(file.out)
    out.printLine("{")
    kids := ps.root.listOwn
    kids.each |kid, i|
    {
      gen(out, kid, i + 1 < kids.size)
    }
    out.printLine("}")
    out.close

    info("generated JSON [$file.osPath]")
  }

  Void gen(GenJsonOutStream out, Proto p, Bool comma)
  {
    kids := p.listOwn
    typeComma := kids.isEmpty && !p.hasVal ? "" : ","
    valComma := kids.isEmpty ? "" : ","

    out.indent.quoted(p.name).printLine(": {")

    out.indentation++

    if (p.type != null)
      out.indent.quoted("_type").print(": ").quoted(p.type.qname).printLine(typeComma)

    if (p.hasVal)
      out.indent.quoted("_val").print(": ").quoted(p.val).printLine(valComma)

    kids.each |kid, i|
    {
      gen(out, kid, i + 1 < kids.size)
    }

    out.indentation--
    out.indent.print("}")
    if (comma) out.print(",")
    out.printLine
  }

}

**************************************************************************
** GenJsonOutStream
**************************************************************************

internal class GenJsonOutStream : OutStream
{
  new make(OutStream out) : super(out) {}

  This quoted(Str s) { print(s.toCode) }

  This indent() { print(Str.spaces(indentation*2)) }

  Int indentation
}