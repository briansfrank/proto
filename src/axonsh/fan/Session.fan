//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Dec 2022  Brian Frank  Creation
//

using axonx
using util

**
** Axon shell session
**
internal class Session
{
  new make(OutStream out)
  {
    this.out = out
    this.cx  = Context(this)
  }

  Int runExpr(Str expr)
  {
    try
    {
      eval(expr)
      return 0
    }
    catch (Err e)
    {
      err("Internal error", e)
      return 0
    }
  }

  Int run()
  {
    out.printLine("Axon shell v${typeof.pod.version} ('?' for help, 'quit' to quit)")
    while (!isDone)
    {
      try
      {
        expr := prompt
        execute(expr)
      }
      catch (EvalErr e)
      {
        err(e.msg, e.cause)
      }
      catch (Err e)
      {
        err("Internal error", e)
      }
    }
    return 0
  }

  private Str prompt()
  {
    // prompt for one or more lines
    expr := Env.cur.prompt("axon> ").trim

    // if it looks like expression is incomplete, then
    // prompt for additional lines until empty
    if (isMultiLine(expr))
    {
      x := StrBuf().add(expr).add("\n")
      while (true)
      {
        next := Env.cur.prompt("..... ")
        if (next.trim.isEmpty) break
        x.add(next).add("\n")
      }
      expr = x.toStr
    }

    return expr
  }

  private Bool isMultiLine(Str expr)
  {
    if (expr.endsWith("do")) return true
    if (expr.endsWith("{")) return true
    return false
  }

  private Void execute(Str expr)
  {
    // skip empty string
    if (expr.isEmpty) return

    // check for special commands
    switch (expr)
    {
      case "?":
      case "help": return help
      case "bye":
      case "exit":
      case "quit": return quit
    }

    // evaluate as axon
    eval(expr)
  }

  private Void eval(Str expr)
  {
    // wrap list of expressions in do/end block
    if (expr.contains(";") || expr.contains("\n"))
      expr = "do\n$expr\nend"

    // evaluate the expression
    val := cx.eval(expr)

    // print the value if no echo
    if (val !== noEcho) out.printLine(val)

    // save last value as "it"
    if (val != null && val != noEcho) cx.defOrAssign("it", val, Loc.eval)
  }

  private Void help()
  {
    eval("help()")
  }

  private Void quit()
  {
    isDone = true
  }

  private Obj? err(Str msg, Err? err := null)
  {
    if (err == null)
      Env.cur.err.printLine("ERROR: $msg")
    else if (err is FileLocErr)
      Env.cur.err.printLine("ERROR: $msg [" +  ((FileLocErr)err).loc + "]\n$err.traceToStr")
    else
      Env.cur.err.printLine("ERROR: $msg\n$err.traceToStr")
    return null
  }

  static const Str noEcho := "_no_echo_"

  OutStream out
  Context cx
  Bool isDone := false
  ShellDb db := ShellDb()
}

