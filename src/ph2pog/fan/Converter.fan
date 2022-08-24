//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   24 Aug 2022  Brian Frank  Creation
//

using proto
using haystack

**
** Command line program main
**
class Converter
{
  ** It-block constructor
  new make(|This| f)
  {
    f(this)
    this.ph = ns.lib("ph")
  }

  ** Namespace of defs to convert
  const Namespace ns

  ** Output directory of the "ph" library
  const File phDir

  ** Defs for "ph" lib
  const Lib ph

  ** Autogen timestamp
  const Str ts := DateTime.now.toLocale("DD-MMM-YYYY")

  ** Do it!
  Void convert()
  {
    writeLib
    writeTags
  }

  ** Write lib file
  Void writeLib()
  {
    write(`lib.pog`) |out|
    {
      out.printLine(
       """#<
            doc: "Project haystack core library"
            version: "$ph.version.toStr"
            depends: {
              { lib: "sys" }
            }
            org: {
             dis: "Project Haystack"
             uri: "https://project-haystack.org/"
            }
          >""")
    }
  }

  ** Write tags file
  Void writeTags()
  {
    write(`tags.pog`) |out|
    {
      out.printLine("// All standard tags defined by Project Haystack")
      out.printLine("PhTags : {")
      out.printLine

      tags := ns.findDefs |def| { def.symbol.type.isTag }
      tags.sort |a, b| { a.name <=> b.name }
      tags.each |tag|
      {
        writeTag(out, tag)
      }

      out.printLine("}")
    }
  }

  private Void writeTag(OutStream out, Def tag)
  {
    // write doc comment
    doc := tag["doc"] as Str ?: tag.name
    doc.splitLines.each |line|
    {
      out.print("// ").printLine(line)
    }

    type := tagToType(tag)

    out.printLine("${tag}?: $type")
    out.printLine
  }

  private Str tagToType(Def def)
  {
    kind := ns.defToKind(def)
    if (kind == Kind.span) return Kind.xstr.name
    return kind.name
  }

  ** Write given file under phDir
  Void write(Uri file, |OutStream| cb)
  {
    info("write [$file]")
    f := phDir + file
    out := f.out
    try
    {
      out.printLine("// Auto-generated $ts")
      out.printLine
      cb(out)
    }
    finally out.close
  }

  ** Log message to stdout
  Void info(Str msg)
  {
    echo(msg)
  }
}

