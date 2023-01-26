//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   24 Jan 2023  Brian Frank  Creation
//

**
** Axon shell command line interface program
**
class Main
{
  OutStream out := Env.cur.out

  Int main(Str[] args)
  {
    // short circuiting options
    if (hasArg(args, "-help", "-?")) return printHelp
    if (hasArg(args, "-version", "-v")) return printVersion

    // if no args, then enter interactive shell
    session := Session(out)
    if (args.isEmpty) return session.run

    // run arg as either file or expression
    arg := args[0]
    if (arg.endsWith(".axon")) arg = File.os(arg).readAllStr
    return session.runExpr(arg)
  }

  Bool hasArg(Str[] args, Str name, Str? abbr := null)
  {
    args.any { it == name || it == abbr }
  }

  Int printHelp()
  {
    out.printLine
    out.printLine("Usage:")
    out.printLine("  axon               Start interactive shell")
    out.printLine("  axon file          Execute axon script from file")
    out.printLine("  axon 'expr'        Evaluate axon expression")
    out.printLine("Options:")
    out.printLine("  -help, -?          Print usage help")
    out.printLine("  -version, -v       Print version info")
    out.printLine
    return 0
  }

  private Int printVersion()
  {
    out.printLine
    out.printLine("Axon Shell")
    out.printLine
    out.printLine("axon.version:  " + typeof.pod.version)
    out.printLine("java.version:  " + Env.cur.vars["java.version"])
    out.printLine("java.vm.name:  " + Env.cur.vars["java.vm.name"])
    out.printLine("java.home:     " + Env.cur.vars["java.home"])
    out.printLine("fan.version:   " + Pod.find("sys").version)
    out.printLine("fan.home:      " + Env.cur.homeDir.osPath)
    out.printLine
    return 0
  }

}

