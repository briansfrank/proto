//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   8 Aug 2022  Brian Frank  Creation
//

using util
using pog

**
** Rewrite the index in build.fan for each pod
**
internal class RewriteIndex : Step
{
  override Void run()
  {
    info("RewriteIndex")
    pods.each |pod|
    {
      rewritePod(pod)
    }
    bombIfErr
  }

  Void rewritePod(PodSrc pod)
  {
    types := pod.toIndex
    if (types.isEmpty) return

    file := pod.dir + `build.fan`

    // find start/end of lines to replace
    oldLines := file.readAllLines
    s := oldLines.findIndex |line| { line.contains("pog-start") }
    e := oldLines.findIndex |line| { line.contains("pog-end") }
    if (s == null || e == null)
      return err("Cannot find pog-start/end lines", FileLoc(file))

    // generate new lines
    newLines := Str[,]
    for (i := 0; i<oldLines.size; ++i)
    {
      if (i <= s || i >= e) newLines.add(oldLines[i])
      if (i == s)
      {
        newLines.add("")
        newLines.add("    index = [\"pog.types\": \"" + gen(pod, types) + + "\"]")
        newLines.add("")
      }
    }

    info("  Rewrite [$file.osPath]")
    file.out.print(newLines.join("\n")).close
  }

  Str gen(PodSrc pod, TypeSrc[] types)
  {
    s := StrBuf()
    s.add(pod.podName).add("; ")
    s.add(pod.lib.qname).add("; ")
    types.each |t, i|
    {
      if (i > 0) s.add(",")
      s.add(t.name)
    }
    return s.toStr
  }
}

