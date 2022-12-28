//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   28 Dec 2022  Brian Frank  Creation
//

using concurrent
using util
using pog

**
** Print transducer
**
@Js
const class PrintTransducer : Transducer
{
  new make(PogEnv env) : super(env, "print") {}

  override Str summary()
  {
    "Print data to output stream"
  }

  override Str usage()
  {
    """Summary:
         Print data to output stream.
       Usage:
         print val:data                Print data to stdout
         print val:data write:output   Print data to given output stream
       Arguments:
         data                          Proto, JSON
         write                         Output file or 'stdout'
       """
  }

  override Transduction transduce(Str:Obj? args)
  {
    cx := TransduceContext(this, args)
    val := cx.arg("val")
    return cx.write |out|
    {
      print(cx, out, val)
      return val
    }
  }

  private Void print(TransduceContext cx, OutStream out, Obj val)
  {
    if (val is Proto)
      PogPrinter(out, cx.args).print(val)
    else
      JsonPrinter(out, cx.args).print(val)
  }

}

**************************************************************************
** Printer
**************************************************************************

@Js
abstract internal class Printer
{
  new make(OutStream out, [Str:Obj?]? opts := null)
  {
    this.out  = out
    this.opts = opts
    this.escapeUnicode = optBool("escapeUnicode", false)
    this.indention = optInt("indent", 0)
  }

  This wquoted(Str str)
  {
    wc('"')
    str.each |char|
    {
      if (char <= 0x7f || !escapeUnicode)
      {
        switch (char)
        {
          case '\b': wc('\\').wc('b')
          case '\f': wc('\\').wc('f')
          case '\n': wc('\\').wc('n')
          case '\r': wc('\\').wc('r')
          case '\t': wc('\\').wc('t')
          case '\\': wc('\\').wc('\\')
          case '"':  wc('\\').wc('"')
          default: wc(char)
        }
      }
      else
      {
        wc('\\').wc('u').w(char.toHex(4))
      }
    }
    wc('"')
    return this
  }

  This wsymbol(Str symbol) { w(symbol) }

  This w(Obj str) { out.print(str); return this }

  This wc(Int char) { out.writeChar(char); return this }

  This sp() { wc(' ') }

  This nl() { out.printLine; return this }

  This windent() { w(Str.spaces(indention*2)) }

  Obj? opt(Str name, Obj? def := null) { opts?.get(name, null) ?: def }

  Bool optBool(Str name, Bool def) { opt(name, def) as Bool ?: def }

  Int optInt(Str name, Int def) { opt(name, def) as Int ?: def }

  OutStream out
  [Str:Obj?]? opts
  Bool escapeUnicode
  Int indention
}

**************************************************************************
** PogPrinter
**************************************************************************

@Js
internal class PogPrinter : Printer
{
  new make(OutStream out, [Str:Obj?]? opts := null) : super(out, opts) {}

  This print(Proto p)
  {
    windent
    printName(p)
    printIs(p)
    printVal(p)
    printChildren(p, true, "<", ">")
    printChildren(p, false, "{", "}")
    nl
    return this
  }

  private Void printName(Proto p)
  {
    if (p.qname.isRoot || p.qname.isAuto || p.name.isEmpty) return
    w(p.name).wsymbol(":").sp
  }

  private Void printIs(Proto p)
  {
    isa := p.isa
    if (isa == null) return
    w(p.isa.qname.toStr)
  }

  private Void printVal(Proto p)
  {
    val := p.valOwn(false)
    if (val == null) return
    sp.wquoted(val.toStr)
  }

  private Void printChildren(Proto p, Bool meta, Str open, Str close)
  {
    first := true
    p.eachOwn |kid|
    {
      if (kid.isMeta != meta) return
      if (first)
      {
        first = false
        sp.wsymbol(open).nl
        indention++
      }
      print(kid)
    }
    if (!first)
    {
      indention--
      windent
      wsymbol(close)
    }
  }

}

