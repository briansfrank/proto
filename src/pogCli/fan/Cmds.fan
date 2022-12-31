//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   31 Dec 2022  Brian Frank  Creation
//

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

  abstract Void execute(Session session, CmdArg[] args)

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
  override Void execute(Session session, CmdArg[] args)
  {
    out := session.out
    shell := args.first?.name != "main"
    if (shell)
    {
      out.printLine
      out.printLine("Pog Shell Commands:")
    }
    session.cmds.dup.sort.each |cmd|
    {
      names := StrBuf().add(cmd.name)
      cmd.aliases.each |alias| { names.join(alias, ", ") }

      out.printLine("  " + names.toStr.padr(18) + "  " + cmd.summary)
    }
    if (shell)
    {
      out.printLine
    }
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
  override Void execute(Session session, CmdArg[] args)
  {
    session.isDone = true
  }
}

**************************************************************************
** Version
**************************************************************************

internal const class Version : Cmd
{
  override const Str name := "version"
  override Str summary() { "Print version info" }
  override Void execute(Session session, CmdArg[] args)
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
  }
}

**************************************************************************
** EnvCmd
**************************************************************************

internal const class EnvCmd : Cmd
{
  override const Str name := "env"
  override Str summary() { "Print environment info" }
  override Void execute(Session session, CmdArg[] args)
  {
    out := session.out
    out.printLine
    session.env.dump(out)
    out.printLine
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
  override Void execute(Session session, CmdArg[] args)
  {
    echo("TODO: $transducer")
  }
}


