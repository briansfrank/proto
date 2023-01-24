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
    this.cx  = Context()
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
    val := cx.eval(expr)
    print(val)
  }

  private Void print(Obj? val)
  {
    out.printLine(val)
  }

  private Void help()
  {
    out.printLine
    cx.funcs.keys.sort.each |n|
    {
      f := cx.funcs[n]
      if (f.meta.has("nodoc")) return
      out.printLine(n)
    }
    out.printLine
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

  private OutStream out
  private Context cx
  private Bool isDone := false

}

