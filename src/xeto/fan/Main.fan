//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Aug 2022  Brian Frank  Creation
//

using util
using data

**
** Xeto command line program main.
**
class Main
{
  OutStream out := Env.cur.out

  Int main(Str[] args)
  {
    if (hasArg(args, "-help", "-?")) return printHelp
    if (hasArg(args, "-version", "-v")) return printVersion
    if (hasArg(args, "-env")) return printEnv

    input := args.find { !it.startsWith("-") }
    if (input == null) return printHelp

    c := XetoCompiler()
    {
      it.input = File.os(input)
    }

    try
    {
      lib := c.compileLib()
      if (hasArg(args, "-print", "-p")) echo(lib)
      return 0
    }
    catch (XetoCompilerErr e)
    {
      out.printLine("Compile failed [$c.errs.size errors]")
      return 1
    }
  }

  Bool hasArg(Str[] args, Str name, Str? abbr := null)
  {
    args.any { it == name || it == abbr }
  }

  Int printHelp()
  {
    out.printLine
    out.printLine("Usage:")
    out.printLine("  xeto -env             Print installed libs")
    out.printLine("  xeto lib/data/sys     Compile lib dir and report errors")
    out.printLine("  xeto -p lib/data/sys  Compile lib dir and print to stdout")
    out.printLine("Options:")
    out.printLine("  -help, -?             Print usage help")
    out.printLine("  -version, -v          Print version info")
    out.printLine("  -env                  Print path and installed libs")
    out.printLine("  -print, -p            Print compiler output")
    out.printLine
    return 0
  }

  private Int printVersion()
  {
    out.printLine
    out.printLine("Xeto Compiler")
    out.printLine
    out.printLine("xeto.version:  " + typeof.pod.version)
    out.printLine("java.version:  " + Env.cur.vars["java.version"])
    out.printLine("java.vm.name:  " + Env.cur.vars["java.vm.name"])
    out.printLine("java.home:     " + Env.cur.vars["java.home"])
    out.printLine("fan.version:   " + Pod.find("sys").version)
    out.printLine("fan.homeDir:   " + Env.cur.homeDir.osPath)
    out.printLine
    return 0
  }

  private Int printEnv()
  {
    out.printLine
    DataEnv.cur.dump(out)
    out.printLine
    return 0
  }

}

