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
    out.printLine("  -help, -?           Print usage help")
    out.printLine("  -version, -v        Print version info")
    out.printLine("  -shell, -sh         Enter interactive shell")
    out.printLine("Commands:")
    Session(env, out).execute("help main:true")
    out.printLine
    return 1
  }

  private Int printVersion()
  {
    Session(env, out).execute("version")
    return 1
  }

}

