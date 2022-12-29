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
** Command line main
**
class Main : AbstractMain
{
  @Opt { help = "Print version info"; aliases = ["v"] }
  Bool version

  override Int run()
  {
    out := Env.cur.out
    if (version) return printVersion(out)

    c := PogStubCompiler {}

    try
    {
      c.compile
      return 0
    }
    catch (CompilerErr e)
    {
      out.printLine("Compile failed [$c.errs.size errors]")
      return 1
    }
  }

  private Int printVersion(OutStream out)
  {
    out.printLine
    out.printLine("Pog Stub Compiler")
    out.printLine
    out.printLine("pogStub.version:  " + typeof.pod.version)
    out.printLine("java.version:     " + Env.cur.vars["java.version"])
    out.printLine("java.vm.name:     " + Env.cur.vars["java.vm.name"])
    out.printLine("java.home:        " + Env.cur.vars["java.home"])
    out.printLine("fan.version:      " + Pod.find("sys").version)
    out.printLine("fan.platform:     " + Env.cur.platform)
    out.printLine("fan.homeDir:      " + Env.cur.homeDir.osPath)
    out.printLine("fan.workDir:      " + Env.cur.workDir.osPath)
    out.printLine
    out.flush
    return 1
  }
}




