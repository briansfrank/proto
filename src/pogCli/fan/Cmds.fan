//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   31 Dec 2022  Brian Frank  Creation
//

using util
using pog

**
** Cmd models one CLI command
**
internal abstract const class Cmd
{
  static Cmd[] findCmds(Session session)
  {
    acc := Cmd[,]
    Cmd#.pod.types.each |t|
    {
      if (!t.isAbstract && t.fits(Cmd#) && t.name != "Transduce")
        acc.add(t.make)
    }
    session.env.transducers.each |t| { acc.add(Transduce(t)) }
    return acc
  }

  abstract Str name()

  virtual Str[] aliases() { Str#.emptyList }

  abstract Str summary()

  virtual Str usage() { "" }

  abstract TransduceData? execute(Session session, CmdExpr expr)

  virtual Str sortKey() { name }

  override Int compare(Obj that) { sortKey <=> ((Cmd)that).sortKey }

  override final Str toStr() { name }
}

**************************************************************************
** Help
**************************************************************************

internal const class Help : Cmd
{
  override const Str name := "help"
  override const Str[] aliases := ["?"]
  override Str summary() { "Print usage help" }
  override Str sortKey() { "_0" }
  override TransduceData? execute(Session session, CmdExpr expr)
  {
    on := expr.args.first?.val
    shell := on != "in-main"

    if (on != null && shell)
    {
      printOn(session, on)
      return null
    }

    out := session.out
    if (shell)
    {
      out.printLine
      out.printLine("Pog Shell Commands:")
    }
    session.cmds.dup.sort.each |cmd|
    {
      out.printLine("  " + cmdToNames(cmd).padr(18) + "  " + cmd.summary)
    }
    if (shell)
    {
      out.printLine
    }
    return null
  }

  private Void printOn(Session session, Str name)
  {
    out := session.out
    cmd := session.cmd(name)
    if (cmd == null) return out.printLine("Help command not found: $name")

    out.printLine
    out.printLine("Command:")
    out.printLine("  " + cmdToNames(cmd))
    out.printLine("Summary:")
    out.printLine("  " + cmd.summary)
    usage := cmd.usage.trim
    if (!usage.isEmpty)
    {
      out.printLine("Usage:")
      usage.splitLines.each |line| { out.printLine("  $line") }
    }
    out.printLine
  }

  private Str cmdToNames(Cmd cmd)
  {
    s := StrBuf().add(cmd.name)
    cmd.aliases.each |alias| { s.join(alias, ", ") }
    return s.toStr
  }
}

**************************************************************************
** Quit
**************************************************************************

internal const class Quit : Cmd
{
  override const Str name := "quit"
  override const Str[] aliases := ["bye", "exit"]
  override Str summary() { "Quit the interactive shell" }
  override Str sortKey() { "_1" }
  override TransduceData? execute(Session session, CmdExpr expr)
  {
    session.isDone = true
    return null
  }
}

**************************************************************************
** Version
**************************************************************************

internal const class Version : Cmd
{
  override const Str name := "version"
  override Str summary() { "Print version info" }
  override TransduceData? execute(Session session, CmdExpr expr)
  {
    out := session.out
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
    out.printLine
    return null
  }
}

**************************************************************************
** EnvCmd
**************************************************************************

internal const class EnvCmd : Cmd
{
  override const Str name := "env"
  override Str summary() { "Print environment info" }
  override TransduceData? execute(Session session, CmdExpr expr)
  {
    out := session.out
    out.printLine
    session.env.dump(out)
    out.printLine
    return null
  }
}

**************************************************************************
** Get
**************************************************************************

internal const class Get : Cmd
{
  override const Str name := "get"
  override Str summary() { "Get a variable by name" }
  override Str usage() { """get name      Get variable by name""" }
  override TransduceData? execute(Session session, CmdExpr expr)
  {
    if (expr.args.isEmpty) return session.err("Must specify var name")
    name := expr.args[0].val
    var := session.vars[name]
    if (var == null) return session.err("Var not found: $name")
    session.setVar("it", var)
    return var
  }
}

**************************************************************************
** Set
**************************************************************************

internal const class Set : Cmd
{
  override const Str name := "set"
  override Str summary() { "Save current value to variable" }
  override Str usage()
  {
    """set <name>         Set var to current value
       set <name> <val>   Set var to given value
       """
  }
  override TransduceData? execute(Session session, CmdExpr expr)
  {
    if (expr.args.isEmpty) return session.err("Must specify var name")
    name := expr.args[0].val
    data := expr.args.size >= 2 ? session.argToData(expr.args[1]) : session.vars["it"]
    session.setVar(name, data)
    return data
  }
}

**************************************************************************
** Vars
**************************************************************************

internal const class Vars : Cmd
{
  override const Str name := "vars"
  override Str summary() { "Print session variables" }
  override TransduceData? execute(Session session, CmdExpr expr)
  {
    out := session.out
    out.printLine
    out.printLine("Session Vars:")
    keys := session.vars.keys.sort.moveTo("it", -1)
    keys.each |k|
    {
      out.printLine("  " + (k+":").padr(8) + "  " + session.vars[k])
    }
    out.printLine
    return null
  }
}

**************************************************************************
** Dir
**************************************************************************

internal const class Dir : Cmd
{
  override const Str name := "dir"
  override Str summary() { "List files in the dir" }
  override Str usage()
  {
    """dir           List files in current working dir
       dir <path>    List files in the given dir
       """
  }
  override TransduceData? execute(Session session, CmdExpr expr)
  {
    data := expr.args.size >= 1 ? session.argToData(expr.args[0]) : session.vars["dir"]
    dir := data?.getDir(false)
    if (dir == null) return session.err("Not a directory: " + expr.args[0].val)
    out := session.out
    out.printLine
    out.printLine(dir.osPath)

    dir.listDirs.sort.each |f| { out.print("  ").print(f.name).printLine("/") }
    dir.listFiles.sort.each |f| { out.print("  ").print(f.name).printLine }
    out.printLine
    return data
  }
}

**************************************************************************
** Load
**************************************************************************

internal const class Load : Cmd
{
  override const Str name := "load"
  override Str summary() { "Load library by qname" }
  override Str usage() { """load qname      Load library by name""" }
  override TransduceData? execute(Session session, CmdExpr expr)
  {
    qname := expr.arg("it", false)?.val
    if (qname == null) return session.err("Load qname not specified")
    lib := session.env.load(qname)
    return session.env.data(lib, ["proto", "lib"])
  }
}

**************************************************************************
** Transduce
**************************************************************************

internal const class Transduce : Cmd
{
  new make(Transducer transducer) { this.transducer = transducer }

  const Transducer transducer

  override Str name() { transducer.name }

  override Str summary() { transducer.summary }

  override Str usage() { transducer.usage }

  override TransduceData? execute(Session session, CmdExpr expr)
  {
    // inherit all the session variables
    targs := session.vars.dup

    // override the specific command arguments
    expr.args.each |arg|
    {
      targs[arg.name ?: "it"] = session.argToData(arg)
    }

    result := transducer.transduce(targs)

    if (!result.events.isEmpty)
    {
      result.events.each |event| { Env.cur.err.printLine(event) }
    }

    return result
  }
}


