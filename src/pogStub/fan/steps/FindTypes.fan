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
** Find types in pods
**
internal class FindTypes : Step
{
  override Void run()
  {
    info("FindTypes")
    pods.each |pod| { findTypes(pod) }
  }

  Void findTypes(PodSrc pod)
  {
    acc := File:TypeSrc[][:]
    findTypesInDir(acc, pod, pod.dir)
    pod.typesByFile = acc
    pod.types = acc.vals.flatten.sort |TypeSrc a, TypeSrc b->Int| { a.name <=> b.name }
    bombIfErr
    info("  $pod.podName [$pod.types.size types]")
  }

  Void findTypesInDir(File:TypeSrc[] acc, PodSrc pod, File dir)
  {
    dir.list.each |f|
    {
      if (f.name == "build.fan") return
      if (f.ext == "fan") findTypesInSrc(acc, pod, f)
      if (f.isDir) findTypesInDir(acc, pod, f)
    }
  }

  Void findTypesInSrc(File:TypeSrc[] accByFile, PodSrc pod, File src)
  {
    acc := TypeSrc[,]
    parse(src) |header, loc, lines|
    {
      // parse out class header as "class Type: Base, Blah, Blah"
      cls := header.index("class ")
      colon := header.index(":", cls+1)
      if (colon == null) return err("Proto class must have base type", loc)
      comma := header.index(",", colon+1) ?: header.size

      type := header[cls+6..<colon].trim
      base := header[colon+1..<comma].trim
      isAbstract := header.contains("abstract ")

      // map type name to proto type
      proto := pod.lib.get(type, false)
      if (proto == null) return err("Unknown proto for Fantom type: $type", loc)

      // add to our accumulator
      acc.add(TypeSrc(proto, pod, src, isAbstract, base, lines))
    }
    if (!acc.isEmpty) accByFile[src] = acc
  }

  Void parse(File src, |Str header, FileLoc loc, Range lines| f)
  {
    // this is not a real parser, just a quick and dirty check for
    //   class Type : Base
    lines := src.readAllLines
    lines.each |line, start|
    {
      // start of range
      if (!line.contains("pog-start")) return

      // end of range
      end := lines.findIndex |x, i| { i > start && x.contains("pog-end") }
      if (end == null) return err("Matching pog-end not found", FileLoc(src, start+1))

      // look back for class Type: Base
      for (i := start; i>=0; --i)
      {
        if (lines[i].contains("class "))
        {
          f(lines[i], FileLoc(src, i+1), start..end)
          return
        }
      }
      err("Could not find class name for pog-start", FileLoc(src, start+1))
    }
  }
}

