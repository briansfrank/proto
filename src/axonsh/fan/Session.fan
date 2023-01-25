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
    return Env.cur.prompt("axon> ").trim

    // get additional lines from stdin
    /*
    x := StrBuf()
    while (true)
    {
      another := Env.cur.prompt(".... ")
      if (another.trim.isEmpty) break
      x.add(another).add("\n")
    }
    */
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
    if (expr.contains(";") || expr.contains("\n"))
      expr = "do\n$expr\nend"

    val := cx.eval(expr)
    print(val)
  }

  private Void print(Obj? val)
  {
    if (val === noEcho) return
    out.printLine(val)
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

}

