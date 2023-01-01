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

  abstract Obj? execute(Session session, CmdExpr expr)

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
  override Obj? execute(Session session, CmdExpr expr)
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
  override Obj? execute(Session session, CmdExpr expr)
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
  override Obj? execute(Session session, CmdExpr expr)
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
  override Obj? execute(Session session, CmdExpr expr)
  {
    out := session.out
    out.printLine
    session.env.dump(out)
    out.printLine
    return null
  }
}

**************************************************************************
** Vars
**************************************************************************

internal const class Vars : Cmd
{
  override const Str name := "vars"
  override Str summary() { "Print session variables" }
  override Obj? execute(Session session, CmdExpr expr)
  {
    out := session.out
    out.printLine
    out.printLine("Session Vars:")
    keys := session.vars.keys.sort.moveTo("it", 0)
    keys.each |k|
    {
      out.printLine("  $k: " + valToStr(session.vars[k]))
    }
    out.printLine
    return null
  }

  Str valToStr(Obj val)
  {
    if (val is Str:Obj) return "JSON"
    if (val is Proto) return "Proto"
    return val.typeof.name
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
  override Obj? execute(Session session, CmdExpr expr)
  {
    qname := expr.arg("it", false)?.val
    if (qname == null) return session.err("Load qname not specified")
    return session.env.load(qname)
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

  override Obj? execute(Session session, CmdExpr expr)
  {
    targs := Str:Obj[:]
    targs.addNotNull("it", session.vars["it"])
    expr.args.each |arg|
    {
      targs[arg.name ?: "it"] = toArg(session, arg.name, arg.val)
    }

    result := transducer.transduce(targs)

    if (!result.events.isEmpty)
    {
      result.events.each |event| { Env.cur.err.printLine(event) }
    }

    return result.get(false)
  }

  Obj toArg(Session session, Str? name, Str arg)
  {
    if (name == "base") return arg
    if (name == "loc") return FileLoc(arg)

    // assume anything with slash or dot if file
    if (arg.contains(".") || arg.contains("/")) return arg.toUri.toFile

    // check for variable
    var := session.vars[arg]
    if (var != null) return var

    // use string literal
    return arg
  }
}


