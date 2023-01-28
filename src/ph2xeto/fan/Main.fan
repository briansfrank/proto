//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   24 Aug 2022  Brian Frank  Creation
//

using util
using defc

**
** Command line program main
**
class Main : AbstractMain
{
  @Opt { help = "Print version info"; aliases = ["v"] }
  Bool version

  @Opt { help = "Output directory for ph lib" }
  File phDir := `/work/proto/pog/ph/`.toFile

  override Int run()
  {
    out := Env.cur.out
    if (version) return printVersion(out)

    // compile namespace using default ph pods
    ns := DefCompiler().compileNamespace

    // convert
    c := Converter { it.ns = ns; it.phDir = this.phDir }
    c.convert
    return 0
  }

  private Int printVersion(OutStream out)
  {
    out.printLine
    out.printLine("Proto Compiler")
    out.printLine
    out.printLine("protoc.version:   " + typeof.pod.version)
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

