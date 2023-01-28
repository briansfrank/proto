//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Jan 2023  Brian Frank  Creation
//

using pog

**
** AbstractPogTest
**
abstract class AbstractPogTest : Test
{
  const PogEnv env := PogEnv.cur

  Lib compileLib(Str src, Str depends := "sys", Str qname := "test")
  {
    data := doCompileLib(src, depends, qname)
    if (data.isErr) echo(data.events.join("\n"))
    return data.get
  }

  TransduceEvent[] compileLibErrs(Str src, Str depends := "sys", Str qname := "test")
  {
    doCompileLib(src, depends, qname).events
  }

  TransduceData doCompileLib(Str src, Str depends := "sys", Str qname := "test")
  {
    // add pragma is test doesn't explicitly provide one
    if (!src.startsWith("pragma"))
    {
      pragma := StrBuf()
      pragma.add("pragma: Lib <\n")
            .add("  depends: {\n")
      depends.split(',').each |d| { pragma.add("    { lib:\"").add(d).add("\"}\n") }
      pragma.add("  }\n")
            .add(">\n")
      src = pragma.toStr + src
    }
    args := ["it":env.data(src), "base":env.data(qname)]
    return env.transduce("compile", args)
  }

}