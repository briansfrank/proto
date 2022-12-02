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
** Rewrite the types file
**
internal class RewriteTypes : Step
{
  override Void run()
  {
    info("RewriteTypes")
    pods.each |pod| { rewritePod(pod) }
  }

  Void rewritePod(PodSrc pod)
  {
    // collapse types into unique source files (we
    // might have multiple types in a single source)
    pod.typesByFile.each |types, file|
    {
      writeFile(file, types)
    }
  }

  Void writeFile(File file, TypeSrc[] types)
  {
    // read all current lines
    oldLines := file.readAllLines

    // create new lines
    newLines := Str[,]
    for (i := 0; i<oldLines.size; ++i)
    {
      // check if this line maps to start of a pog-start
      type := types.find |t| { t.lines.start == i }

      // pass thru original line
      if (type == null)
      {
        newLines.add(oldLines[i])
        continue
      }

      // insert new lines
      newLines.add(oldLines[i])  // pog-start line
      newLines.addAll(type.gen)  // new auto-generated lines
      i = type.lines.end         // skip to pog-end line
      newLines.add(oldLines[i])  // pog-end line
    }

    info("  Rewrite [$file.osPath]")
    file.out.print(newLines.join("\n")).close
  }

}

