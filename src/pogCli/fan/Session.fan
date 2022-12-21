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
class Session
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  ** Constructor
  new make(PogEnv env, OutStream out) { this.env = env; this.out = out }

//////////////////////////////////////////////////////////////////////////
// Execution
//////////////////////////////////////////////////////////////////////////

  ** Execute a script which is one or more commands separated by a newlines or comma
  Int execute(Str script)
  {

    script.splitLines.each |line|
    {
      script.split(',').each |cmd|
      {
        executeCmd(cmd)
      }
    }
    return 0
  }

  ** Parse and execute command.
  private Obj? executeCmd(Str cmd)
  {
    result := doExecute(cmd)
    if (result != null) vars[lastVarName] = result
    return result
  }

  private Obj? doExecute(Str cmd)
  {
    toks := cmd.split.findAll { !it.isEmpty }
    if (toks.isEmpty) return null

    name := toks[0]
    args := toks[1..-1]

    switch (name.lower)
    {
      case "quit":
      case "exit":
      case "bye":
        isDone = true
        return null

      case "?":
      case "help":
      case "usage":
        help(true)
        return null

      case "get":
        return vars[args.first ?: lastVarName]

      case "set":
        return set(args)

      case "print":
        return print(vars[args.first ?: lastVarName])

      case "vars":
        return dumpVars
    }

    transducer := env.transducer(name, false)
    if (transducer == null)
    {
      out.printLine("Unknown command '$name'")
      return null
    }

    return executeTransducer(transducer, args)
  }

  ** Execute transducer
  private Obj? executeTransducer(Transducer t, Str[] args)
  {
    // TODO: need a bit of work here...
    try
    {
      inputs := args.map |arg->Obj| { arg.toUri.toFile }
      input := inputs.first
      return t.transduce(["read":input])
    }
    catch (FileLocErr e)
    {
      err("$t.name failed [$e.loc]\n$e.traceToStr")
      return null
    }
    catch (Err e)
    {
      err("$t.name failed\n$e.traceToStr")
      return null
    }
  }

//////////////////////////////////////////////////////////////////////////
// Built-in Commands
//////////////////////////////////////////////////////////////////////////

  private Obj? set(Str[] args)
  {
    if (args.size < 1) return err("Incomplete set command: set name <command>")
    name := args[0]
    result := args.size == 1 ? vars[lastVarName] : doExecute(args[1..-1].join(" "))
    vars[name] = result
    return result
  }

  private Obj? print(Obj? x)
  {
    out.printLine(x)
    return x
  }

  private Obj? dumpVars()
  {
    out.printLine
    out.printLine("Vars:")
    vars.keys.sort.each |k|
    {
      str := vars[k].toStr
      if (str.size > 80) str = str[0..79] + "..."
      out.printLine("  $k: " + str.toCode)
    }
    out.printLine
    return null
  }

  Void help(Bool inShell)
  {
    if (inShell)
    {
      out.printLine
      out.printLine("Pog Shell Commands:")
      out.printLine("  quit, exit, bye        Exit the shell")
      out.printLine("  ?, help, usage         Print command summary")
    }
    out.printLine("  help [command]         Usage help on given command")
    out.printLine("  get [var]              Get variable name or last result")
    out.printLine("  set <var> [command]    Set variable to result of command or last result")
    out.printLine("  print [var]            Print variable name or last result")
    out.printLine("  vars                   Dump variable names")
    env.transducers.each |t|
    {
      out.printLine("  " + t.name.padr(22) + " " + t.summary)
    }
    if (inShell)
    {
      out.printLine
    }
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  private Obj? err(Str msg)
  {
    Env.cur.err.printLine("ERROR: $msg")
    return null
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Bool isDone { private set }
  private const PogEnv env := PogEnv.cur
  private const Str lastVarName := "_"
  private OutStream out
  private Str:Obj vars := [:]
}