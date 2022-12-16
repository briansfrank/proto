//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Dec 2022  Brian Frank  Creation
//

using pog

**
** Pog command line interface
**
class Main
{
  OutStream out := Env.cur.out

  PogEnv env := PogEnv.cur

  Int main(Str[] args)
  {
    if (hasArg(args, "-help", "-?")) return printHelp
    if (hasArg(args, "-version", "-v")) return printVersion
    if (hasArg(args, "-installed")) return printInstalled
    if (args.isEmpty || hasArg(args, "-shell", "-sh")) return shell
    return Session(env, out).execute(args.join(" "))
  }

  Int shell()
  {
    out.printLine("Pog shell v${typeof.pod.version} ('?' for help, 'quit' to quit)")
    session := Session(env, out)
    while (!session.isDone)
    {
      session.execute(Env.cur.prompt("pog> ").trim)
    }
    return 0
  }

  Bool hasArg(Str[] args, Str name, Str? abbr := null)
  {
    args.any { it == name || it == abbr }
  }

  Int printHelp()
  {
    out.printLine
    out.printLine("Usage:")
    out.printLine("  pog [options] <command 1>, <command 2>, ...")
    out.printLine("Options:")
    out.printLine("  -help, -?              Print usage help")
    out.printLine("  -version, -v           Print version info")
    out.printLine("  -installed             List the installed libraries found in path")
    out.printLine("  -shell, -sh            Enter interactive shell")
    out.printLine("Commands:")
    Session(env, out).help(false)
    out.printLine("Examples")
    out.printLine("  pog                    Enter interactive shell")
    out.printLine("  pog -sh                Enter interactive shell")
    out.printLine("  pog -v                 Print version information")
    out.printLine("  pog -installed         Print installed libraries")
    out.printLine
    return 1
  }

  private Int printVersion()
  {
    out.printLine
    out.printLine("Proto object graph command line interface")
    out.printLine
    out.printLine("pog.version:   " + typeof.pod.version)
    out.printLine("java.version:  " + Env.cur.vars["java.version"])
    out.printLine("java.vm.name:  " + Env.cur.vars["java.vm.name"])
    out.printLine("java.home:     " + Env.cur.vars["java.home"])
    out.printLine("fan.version:   " + Pod.find("sys").version)
    out.printLine("fan.platform:  " + Env.cur.platform)
    out.printLine("fan.homeDir:   " + Env.cur.homeDir.osPath)
    out.printLine("fan.workDir:   " + Env.cur.workDir.osPath)
    out.printLine("pog.path:")
    env.path.each |path|
    {
      out.printLine("  $path.osPath")
    }
    out.printLine
    out.flush
    return 1
  }

  private Int printInstalled()
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

