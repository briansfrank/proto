//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Dec 2022  Brian Frank  Creation
//

using util

**
** Pog command line interface
**
class Main
{
  Int main(Str[] args := Env.cur.args)
  {
    // use reflection to delegate to pogCli::Main
    Type.find("pogCli::Main").make->main(args)
  }
}