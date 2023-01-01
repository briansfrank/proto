//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   31 Dec 2022  Brian Frank  Creation
//

using util

**
** CmdExpr models one parsed command and its arguments
**
internal const class CmdExpr
{
  static CmdExpr[] parse(Str s)
  {
    s.split(',').map |tok->CmdExpr| { parseCmd(tok) }
  }

  private static CmdExpr parseCmd(Str s)
  {
    toks := s.split
    name := toks[0]
    args := CmdArg[,]

    // normalize arg toks
    argToks := Str[,]
    toks.eachRange(1..-1) |tok|
    {
      if (tok.isEmpty) return
      colon := tok.index(":")
      if (colon == null || tok.size == 1) argToks.add(tok)
      else if (colon == 0) argToks.add(":").add(tok[1..-1])
      else if (colon == tok.size-1) argToks.add(tok[0..-2]).add(":")
      else argToks.add(tok[0..<colon]).add(":").add(tok[colon+1..-1])
    }

    for (i := 0; i<argToks.size; ++i)
    {
      x := argToks[i]
      if (i+2 < argToks.size && argToks[i+1] == ":" )
      {
        args.add(CmdArg(x, argToks[i+2]))
        i += 2
      }
      else
      {
        args.add(CmdArg(null, x))
      }
    }

    return CmdExpr(name, args)
  }

  new make(Str name, CmdArg[] args)
  {
    this.name = name
    this.args = args
  }

  const Str name

  const CmdArg[] args


  CmdArg? arg(Str name, Bool checked := true)
  {
    arg := args.find { it.name == name || (name == "it" && it.name == null) }
    if (arg != null) return arg
    if (checked) throw ArgErr("Missing argument: $name")
    return null
  }

  override Str toStr()
  {
    s := StrBuf()
    s.add(name)
    args.each |arg| { s.join(arg, " ") }
    return s.toStr
  }

  CmdExpr replaceLastArg(Str val)
  {
    last := args[-1]
    args := args[0..-2]
    args.add(CmdArg(last.name, val))
    args.add(CmdArg("loc", "shell"))
    return make(name, args)
  }

  static Void main(Str[] args)
  {
    str := args.join(" ")
    parse(str).each |cmd| { echo(cmd) }
  }
}

**************************************************************************
** CmdArg
**************************************************************************

internal const class CmdArg
{
  new make(Str? name, Str val)
  {
    this.name = name
    this.val  = val
  }

  const Str? name
  const Str val

  override Str toStr()
  {
    if (name == null) return val.toCode
    else return name + ":" + val.toCode
  }
}


