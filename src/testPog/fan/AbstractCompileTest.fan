//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Nov 2022  Brian Frank  Creation
//

using pog

**
** Base clas for tests which compile new pogs
**
abstract class AbstractCompileTest : Test
{

  Graph? graph

  Proto getq(Str qname)
  {
    graph.getq(qname)
  }

  Graph compile(Str[] libs)
  {
    this.graph = PogEnv.cur.compile(libs)
  }

  Lib compileSrc(Str src)
  {
    prelude :=
     Str<|test #<
            version: "0.0.1"
          >
         |>
    src = prelude + src

    if (false)
    {
      echo("---")
      src.splitLines.each |line, i| { echo("${i+1}: $line") }
      echo("---")
    }

    compile(["sys", src])
    return graph.lib("test")
  }
}

