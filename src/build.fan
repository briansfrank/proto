#! /usr/bin/env fan
//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Feb 2022  Brian Frank  Creation
//

using build

**
** Top-level build
**
class Build : BuildGroup
{
  new make()
  {
    childrenScripts =
    [
      `proto/build.fan`,
      `testProto/build.fan`,
    ]
  }

  @Target { help = "Delete entire lib/ directory" }
  Void superclean()
  {
    Delete(this, Env.cur.workDir + `lib/`).run
  }

}

