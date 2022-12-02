//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   7 Aug 2022  Brian Frank  Creation
//

using pog
using pogc

**
** Compile all the protos found in the path
**
internal class CompileGraph : Step
{
  override Void run()
  {
    env := PogEnv.cur
    compiler.graph = ProtoCompiler
    {
      it.logger   = compiler.logger
      it.env      = env
      it.libNames = env.installed
    }
    .compileGraph

    info("Compiled protos [$graph.libs.size libs]")
  }
}

