//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Dec 2022  Brian Frank  Creation
//

using util
using pog

**
** Pog command line interface session state
**
internal class Session
{

  new make(PogEnv env, OutStream out)
  {
    this.env = env
    this.out = out
    this.cmds = Cmd.findCmds(this)
  }

  const PogEnv env

  const Cmd[] cmds

  Cmd? cmd(Str name)
  {
    cmds.find |c| { c.name == name || c.aliases.contains(name) }
  }

  OutStream out { private set }

  Bool isDone

  Int execute(Str expr)
  {
    CmdExpr.parse(expr).each |c|
    {
      executeExpr(c)
    }
    return 0
  }

  Int executeExpr(CmdExpr expr)
  {
    name := expr.name
    try
    {
      cmd := cmd(name)
      if (cmd == null)
      {
        out.printLine("Unknown cmd: $name")
        return 1
      }

      cmd.execute(this, expr.args)
      return 0
    }
    catch (Err e)
    {
      err("$name failed\n$e.traceToStr")
      return 1
    }
  }

  private Void err(Str msg, Err? err := null)
  {
    if (err == null)
      Env.cur.err.printLine("ERROR: $msg")
    else if (err is FileLocErr)
      Env.cur.err.printLine("ERROR: $msg [" +  ((FileLocErr)err).loc + "]\n$err.traceToStr")
    else
      Env.cur.err.printLine("ERROR: $msg\n$err.traceToStr")
  }

}