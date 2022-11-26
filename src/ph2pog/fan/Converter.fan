//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   24 Aug 2022  Brian Frank  Creation
//

using proto
using haystack
using haystack::Lib

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
    this.choice = ns.def("choice")
    this.feature = ns.def("feature")
  }

  ** Namespace of defs to convert
  const Namespace ns

  ** Output directory of the "ph" library
  const File phDir

  ** Do it!
  Void convert()
  {
    writeLib
    writeTags
    writeEntites
  }

//////////////////////////////////////////////////////////////////////////
// Lib
//////////////////////////////////////////////////////////////////////////

  ** Write lib file
  private Void writeLib()
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

//////////////////////////////////////////////////////////////////////////
// Tags
//////////////////////////////////////////////////////////////////////////

  ** Write tags file
  private Void writeTags()
  {
    tags := ns.findDefs |def| { def.symbol.type.isTag }
    tags.sort |a, b| { a.name <=> b.name }

    write(`tags.pog`) |out|
    {
      out.printLine("// All standard tags defined by Project Haystack")
      out.printLine("Tag : {")
      out.printLine

      tags.each |tag|
      {
        if (skip(tag.name)) return

        if (isChoice(tag))
          writeChoice(out, tag)
        else
          writeTag(out, tag)
      }

      out.printLine("}")
    }
  }

  private Bool isChoice(Def def)
  {
    Symbol.toList(def["is"]).first == choice.symbol
  }

  private Void writeTag(OutStream out, Def tag)
  {
    type := tagToType(tag)
    if (type == null) return

    writeDoc(out, tag)
    out.printLine("$tag: $type")
    out.printLine
  }

  private Str? tagToType(Def def)
  {
    if (ns.fits(def, feature)) return null

    kind := ns.defToKind(def)
    if (kind == Kind.span) return Kind.xstr.name
    return kind.name
  }

//////////////////////////////////////////////////////////////////////////
// Choices
//////////////////////////////////////////////////////////////////////////

  private Void writeChoice(OutStream out, Def choice)
  {
    writeDoc(out, choice)
    out.print("$choice: Choice <of: ")

    of := choice["of"]
    enums := Str[,]
    if (of != null)
    {
      enums.add(of.toStr)
    }
    else
    {
      ns.subtypes(choice).each |subtype| { enums.add(subtype.name) }
    }

    enums.each |x, i|
    {
      if (i > 0) out.print(" | ")
      out.print("ph.Tag.$x")
    }
    out.printLine(">")
    out.printLine
  }

//////////////////////////////////////////////////////////////////////////
// Entities
//////////////////////////////////////////////////////////////////////////

  private Void writeEntites()
  {
    // get all the entity defs
    entityDef := ns.def("entity")
    entities := ns.findDefs |def| { ns.fits(def, entityDef) }
    entities.sort |a, b| { a.name <=> b.name }
    entities.moveTo(entityDef, 0)

    write(`entities.pog`) |out|
    {
      entities.each |def|
      {
        writeDoc(out, def)
        name := toEntityName(def)
        type := toEntityType(def)
        out.printLine("$name: $type {")
        writeEntityUsage(out, def)
        writeEntityTags(out, def)
        writeEntityChildren(out, def)
        out.printLine("}")
        out.printLine
      }
    }
  }

  private Str toEntityName(Def def)
  {
    symbol := def.symbol
    if (symbol.type.isTag) return def.name.capitalize

    s := StrBuf()
    def.symbol.eachPart |n|
    {
      s.add(n.capitalize)
    }
    return s.toStr
  }

  private Str toEntityType(Def def)
  {
    if (def.name == "entity") return "Dict"
    supers := def["is"] as Symbol[]
    return toEntityName(ns.def(supers.first.toStr))
  }

  private Void writeEntityUsage(OutStream out, Def entity)
  {
    symbol := entity.symbol
    name := symbol.name

    // not sure how to best handle this, but for now just
    // consider these tags as abstract
    if (name == "airHandlingEquip" ||
        name == "airQualityZonePoints" ||
        name == "airTerminalUnit" ||
        name == "conduit" ||
        name == "coil" ||
        name == "entity" ||
        name == "radiantEquip" ||
        name == "verticalTransport")
      return

    if (symbol.type.isTag)
    {
      // simple name
      out.printLine("  $symbol")
      return
    }
    else
    {
      // conjunct (but only entity tags we don't inherit)
      bases := ns.supertypes(entity).findAll |x| { ns.fits(x, ns.def("entity")) }
      symbol.eachPart |part|
      {
        if (bases.any { it.symbol.hasTermName(part) }) return
        out.printLine("  $part")
      }
    }
  }

  private Void writeEntityTags(OutStream out, Def entity)
  {
    tags := Def[,]
    maxNameSize := 2
    ns.tags(entity).each |tag|
    {
      if (isInherited(entity, tag)) return
      if (skip(tag.name)) return
      tags.add(tag)
      maxNameSize = maxNameSize.max(tag.name.size)
    }

    tags.sort |a, b| { a.name <=> b.name }

    tags.each |tag|
    {
      out.printLine("  $tag: " + Str.spaces(maxNameSize-tag.toStr.size) + "ph.Tag.$tag?")
    }
  }

  private Void writeEntityChildren(OutStream out, Def entity)
  {
    // for right now, add points for equip
    if (entity.name == "equip")
      out.printLine("  points: Dict<of:Point>")
  }

  private Bool isInherited(Def entity, Def tag)
  {
    on := tag["tagOn"] as Symbol[]
    return !on.contains(entity.symbol)
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

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


  ** Write doc comment
  Void writeDoc(OutStream out, Def def)
  {
    doc := def["doc"] as Str ?: def.name
    doc.splitLines.each |line|
    {
      out.print("// ").printLine(line)
    }
  }

  ** Log message to stdout
  Void info(Str msg)
  {
    echo(msg)
  }

  ** Skip tag
  private Bool skip(Str name)
  {
    // TODO: chillerMechanism and vavAirCircuit have conjuncts
    name ==  "chillerMechanism" || name ==  "vavAirCircuit"
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  const Lib ph
  const Def choice
  const Def feature
  const Str ts := DateTime.now.toLocale("DD-MMM-YYYY")

}

