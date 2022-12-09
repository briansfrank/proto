//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Dec 2022  Brian Frank  Creation
//

using util

**
** PogTestReader is used to parse "pogtest" files:
**  1. all the files in a given dir with the "pogtest" file extension
**  2. plain text files in UTF-8
**  3. test cases separated by a line starting with "=="
**  4. case sections are separated by a line starting with "--"
**  5. sections are doc, input, output
**
** The interpretation of the input and output are based on the specific
** test directory.
**
class PogTestReader
{
  new make(Uri uri) { this.dir = toDir(uri) }

  static File toDir(Uri uri)
  {
    base := Env.cur.path.find { it.plus(uri).exists }
    if (base == null) throw Err("Test dir not found: $uri")
    return base.plus(uri)
  }

  const File dir

  Void readEach(|PogTestCase| f)
  {
    dir.list.each |file|
    {
      if (file.ext == "pogtest") readFile(file, f)
    }
  }

  Void readFile(File file, |PogTestCase| f)
  {
    // read lines
    lines := file.readAllLines

    // process sections
    start := -1
    for (i := 0; i<lines.size; ++i)
    {
      isDivider := lines[i].startsWith("==")
      if (isDivider)
      {
        readCase(file, lines, start, i, f)
        start = i
      }
    }
    readCase(file, lines, start, lines.size, f)
  }

  Void readCase(File file, Str[] lines, Int start, Int end, |PogTestCase| f)
  {
    if (start < 0) return
    if (!isCase(lines, start, end)) return

    loc := FileLoc(file, start+2)
    div1 := findCaseSectionDivider(lines, start, loc)
    div2 := findCaseSectionDivider(lines, div1, loc)

    c := PogTestCase
    {
      it.loc = loc
      it.doc = lines[start+1 ..< div1].join("\n").trim
      it.in  = lines[div1+1  ..< div2].join("\n").trim
      it.out = lines[div2+1  ..< end].join("\n").trim
    }
    f(c)
  }

  Int findCaseSectionDivider(Str[] lines, Int start, FileLoc loc)
  {
    for (i := start+1; i<lines.size; ++i)
      if (lines[i].startsWith("--")) return i
    throw Err("Invalid test case format; missing -- section [$loc]")
  }

  Bool isCase(Str[] lines, Int start, Int end)
  {
    for (i := start+1; i<end; ++i)
    {
      line := lines[i].trim
      if (!line.isEmpty && !line.startsWith("//"))
        return true
    }
    return false
  }
}

**************************************************************************
** PogTestCase
**************************************************************************

**
** PogTestCase represents one test case in a "pogtest" file
**
const class PogTestCase
{
  new make(|This| f) { f(this) }

  const FileLoc loc
  const Str doc
  const Str in
  const Str out
}