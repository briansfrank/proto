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
    this.theme = out === Env.cur.out ? PrinterTheme.configured : PrinterTheme.none
  }

  This wquoted(Str str)
  {
    wtheme(theme.str)
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
    wreset(theme.str)
    return this
  }

  This wtheme(Str? color)
  {
    if (color != null) w(color)
    return this
  }

  This wreset(Str? color)
  {
    if (color != null) w(PrinterTheme.reset)
    return this
  }

  This wsymbol(Str symbol)
  {
    wtheme(theme.symbol).w(symbol).wreset(theme.symbol)
  }

  This wcomment(Str str)
  {
    wtheme(theme.comment).w(str).wreset(theme.comment)
  }

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
  PrinterTheme theme
  Int indention
}

**************************************************************************
** PrinterTheme
**************************************************************************

@Js
internal const class PrinterTheme
{
  static const Str reset  := "\u001B[0m"
  static const Str black  := "\u001B[30m"
  static const Str red    := "\u001B[31m"
  static const Str green  := "\u001B[32m"
  static const Str yellow := "\u001B[33m"
  static const Str blue   := "\u001B[34m"
  static const Str purple := "\u001B[35m"
  static const Str cyan   := "\u001B[36m"
  static const Str white  := "\u001B[37m"

  static const PrinterTheme none := make {}

  const static PrinterTheme configured := make { it.symbol = red; it.str = cyan; it.comment = green }

  new make(|This| f) { f(this) }

  const Str? symbol
  const Str? str
  const Str? comment
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
    if (p.name[0].isUpper) nl
    printDoc(p)
    windent
    if (printAsMarker(p))
    {
      printName(p, true)
    }
    else
    {
      printName(p, false)
      printIs(p)
      printVal(p)
      printChildren(p, true, "<", ">")
      printChildren(p, false, "{", "}")
    }
    nl
    return this
  }

  private Bool printAsMarker(Proto p)
  {
    if (p.isa?.qname?.toStr != "sys.Marker") return false
    list := p.listOwn
    if (list.size == 0) return true
    if (list.size == 1 && list[0].name == "_doc") return true
    return false
  }

  private Void printDoc(Proto p)
  {
    doc := p.getOwn("_doc", false)?.val
    if (doc == null) return

    doc.toStr.splitLines.each |line, i|
    {
      windent.wcomment("// $line").nl
    }
  }

  private Void printName(Proto p, Bool markerOnly)
  {
    if (p.qname.isRoot || p.qname.isAuto || p.name.isEmpty) return
    name := p.name
    if (PogUtil.isMeta(name)) name = name[1..-1]
    w(name)
    if (!markerOnly) wsymbol(":").sp
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
      if (kid.name == "_doc") return
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

