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
    this.varsRef["dir"] = data(`./`.toFile.normalize)
    this.varsRef["showloc"] = data(false)
    this.varsRef["showdoc"] = data(true)
    initEnvVars
  }

  private Void initEnvVars()
  {
    try
    {
      expr := Env.cur.vars["POG_INIT"]
      if (expr != null) execute(expr)
    }
    catch (Err e) err("Cannot init from POG_INIT", e)
  }

  const PogEnv env

  const Cmd[] cmds

  File curDir() { vars["dir"]?.getDir(false) ?: `./`.toFile }

  Cmd? cmd(Str name)
  {
    cmds.find |c| { c.name == name || c.aliases.contains(name) }
  }

  TransduceData data(Obj? val, Str[]? tags := null, FileLoc? loc := null)
  {
    env.data(val, tags, loc, null)
  }

  TransduceData argToData(CmdArg arg)
  {
    name := arg.name
    val  := arg.val

    // fixed names
    if (name == "base") return data(val)

    // fixed values
    if (val == "false") return data(false)
    if (val == "true") return data(true)
    if (val.toInt(10, false) != null) return data(val.toInt)

    // assume anything with slash or dot if file
    if (val.contains(".") || val.contains("/"))
      return data(curDir.plus(val.toUri, false))

    // check for variable
    if (name != null && vars[val] != null) return vars[val]

    // use string literal
    return data(val)
  }

  OutStream out { private set }

  Bool isDone

  Str:TransduceData vars() { varsRef.ro }

  Void setVar(Str name, TransduceData? val)
  {
    if (val == null) return
    if (!PogUtil.isName(name)) return err("Invalid var name: $name")
    if (name == "dir" && val.getDir(false) == null)
    {
      return err("Invalid directory for dir var: $val.loc")
    }
    varsRef[name] = val
  }

  private Str:TransduceData varsRef := [:]

  Int run()
  {
    out.printLine("Pog shell v${typeof.pod.version} ('?' for help, 'quit' to quit)")
    while (!isDone)
    {
      try
      {
        exprs := prompt
        executeExprs(exprs)
      }
      catch (Err e)
      {
        err("Internal error", e)
      }
    }
    return 0
  }

  CmdExpr[] prompt()
  {
    // prompt for line of commands separated by comma
    line := Env.cur.prompt("pog> ").trim
    if (line.isEmpty) return CmdExpr#.emptyList

    // if line ends with colon we are going to prompt from stdin
    if (!line.endsWith(":")) return CmdExpr.parse(line)

    // get additional lines from stdin
    x := StrBuf()
    while (true)
    {
      another := Env.cur.prompt("... ")
      if (another.trim.isEmpty) break
      x.add(another).add("\n")
    }


    exprs := CmdExpr.parse(line+"x")
    exprs[-1] = exprs[-1].replaceLastArg(x.toStr)
    return exprs
  }

  Int execute(Str expr)
  {
    executeExprs(CmdExpr.parse(expr))
    return 0
  }

  Void executeExprs(CmdExpr[] exprs)
  {
    exprs.each |expr| { executeExpr(expr) }
  }

  Void executeExpr(CmdExpr expr)
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

      result := cmd.execute(this, expr)
      if (result != null) setVar("it", result)
    }
    catch (Err e)
    {
      err("$name failed\n$e.traceToStr")
    }
  }

  Obj? err(Str msg, Err? err := null)
  {
    if (err == null)
      Env.cur.err.printLine("ERROR: $msg")
    else if (err is FileLocErr)
      Env.cur.err.printLine("ERROR: $msg [" +  ((FileLocErr)err).loc + "]\n$err.traceToStr")
    else
      Env.cur.err.printLine("ERROR: $msg\n$err.traceToStr")
    return null
  }

}