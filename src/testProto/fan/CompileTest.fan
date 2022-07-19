//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Jul 2022  Brian Frank  Creation
//

using proto

**
** Compile tests
**
class CompileTest : Test
{

  Void testBasics()
  {
    ps := ProtoEnv.cur.compile(["sys"])
    ps.root.dump
  }
}

