//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Nov 2022  Brian Frank  Creation
//

using proto

**
** Base clas for tests which compile new pogs
**
abstract class AbstractCompileTest : Test
{

  ProtoSpace? ps

  Proto get(Str qname)
  {
    ps.get(qname)
  }

  ProtoSpace compile(Str[] libs)
  {
    this.ps = ProtoEnv.cur.compile(libs)
  }

  ProtoLib compileSrc(Str src)
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
    return ps.lib("test")
  }
}

