//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Aug 2022  Brian Frank  Creation
//

using util
using pog

**
** Command line program main
**
class Main : AbstractMain
{
  @Opt { help = "Print version info"; aliases = ["v"] }
  Bool version

  @Opt { help = "Output directory" }
  File outDir := Env.cur.workDir + `out/`

  @Opt { help = "List the installed libraries found in path" }
  Bool installed

  @Opt { help = "Comma separated list of input library names (defaults to all installed)" }
  Str? libs

  @Opt { help = "Comma separated outputs: json" }
  Str output := ""

  @Opt { help = "Dump the proto tree" }
  Bool dump

  @Opt { help = "Comma separated outputs: json" }
  Str json := ""

  PogEnv env := PogEnv.cur

  override Int run()
  {
    out := Env.cur.out
    if (version) return printVersion(out)
    if (installed) return printInstalled(out)


    c := ProtoCompiler()
    {
      it.libNames = this.libs?.split(',') ?: this.env.installed
      it.outDir = this.outDir
    }

    try
    {
      g := c.compileMain(output.split(',').findAll { !it.isEmpty })
      if (dump) g.print
      return 0
    }
    catch (CompilerErr e)
    {
      out.printLine("Compile failed [$c.errs.size errors]")
      return 1
    }
  }

  override Int usage(OutStream out := Env.cur.out)
  {
    r := super.usage(out)
    out.printLine("Examples:")
    out.printLine("  protoc               // compile all installed libs and report errors")
    out.printLine("  protoc -libs sys,ph  // compile only sys and ph libs")
    out.printLine("  protoc -output json  // compile all libs to protos.json")
    out.printLine("  protoc -dump         // compile all libs and dump to stdout")
    return r
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
    out.printLine("proto.path:")
    env.path.each |path|
    {
      out.printLine("  $path.osPath")
    }
    out.printLine
    out.flush
    return 1
  }

  private Int printInstalled(OutStream out)
  {
    out.printLine
    out.printLine("Installed Libs")
    out.printLine("--------------")
    env.installed.each |lib|
    {
      out.printLine(lib.padr(16) + "  " + env.libDir(lib).osPath)
    }
    out.printLine
    return 1
  }

}

