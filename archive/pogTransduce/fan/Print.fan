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
using haystack

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
    """print                     Print last value to stdout
       print <data>              Print data to stdout
       print <data> to:<file>    Print data to given file
       print showdoc:<bool>      Toggle doc meta in output
       print showloc:<bool>      Toggle file location meta in output
       print summary:<bool>      Print in compact summary mode
       """
  }

  override TransduceData transduce(Str:TransduceData args)
  {
    cx := TransduceContext(this, args)
    data := cx.argIt
    cx.argWriteTo.withOutStream |out| { print(cx, data, out) }
    return data
  }

  private Obj? print(TransduceContext cx, TransduceData data, OutStream out)
  {
    out.printLine
    if (!cx.isTest) out.printLine(data).printLine
    printContent(cx, data, out)
    out.printLine
    out.printLine
    return null
  }

  private Void printContent(TransduceContext cx, TransduceData data, OutStream out)
  {
    val := data.get(false)
    if (cx.hasArg("summary")) return printSummary(cx, val, out)
    if (val is Proto) return printProto(cx, val, out)
    if (val is Grid)  return printGrid(cx, val, out)
    if (val is File)  return printFile(cx, val, out)
    printJson(cx, out, val)
  }

  private Void printSummary(TransduceContext cx, Obj val, OutStream out)
  {
    SummaryPrinter(out, cx.args).print(val)
  }

  private Void printProto(TransduceContext cx, Proto proto, OutStream out)
  {
    PogPrinter(out, cx.args).print(proto)
  }

  private Void printGrid(TransduceContext cx, Grid grid, OutStream out)
  {
    TablePrinter(out, cx.args).printGrid(grid)
  }

  private Void printFile(TransduceContext cx, File file, OutStream out)
  {
    if (file.isDir)
      printDir(cx, out, file)
    else if (file.exists)
      out.print(file.readAllStr)
    else out.printLine("File does not exist: $file")
  }

  private Void printDir(TransduceContext cx, OutStream out, File dir)
  {
    dir.listDirs.sort.each |f| { out.printLine(f.name + "/") }
    dir.listFiles.sort.each |f| { out.printLine(f.name) }
  }

  private Void printJson(TransduceContext cx, OutStream out, Obj? val)
  {
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
    this.showloc = optBool("showloc", true)
    this.showdoc = optBool("showdoc", true)
    this.terminalWidth = optInt("terminalWidth", 150).max(40)
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

  Obj? opt(Str name, Obj? def := null)
  {
    val := opts?.get(name, null)
    if (val is TransduceData) val = ((TransduceData)val).get(false)
    return val ?: def
  }

  Bool optBool(Str name, Bool def) { opt(name, def) as Bool ?: def }

  Int optInt(Str name, Int def) { opt(name, def) as Int ?: def }

  OutStream out
  [Str:Obj?]? opts
  Bool escapeUnicode
  Bool showloc
  Bool showdoc
  Int terminalWidth
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

  static const AtomicRef configuredRef := AtomicRef()

  static PrinterTheme configured()
  {
    theme := configuredRef.val as PrinterTheme
    if (theme == null)
      configuredRef.val = theme = loadConfigured
    return theme
  }

  private static PrinterTheme loadConfigured()
  {
    try
    {
      // load from POG_THEME environment variable
      var := Env.cur.vars["POG_THEME"]
      if (var == null) return none

      // variable should be formatted as symbol:color, str:color, comment:color
      toks := var.split(',')
      map := Str:Str[:]
      toks.each |tok|
      {
        pair := tok.split(':')
        if (pair.size != 2) return
        key := pair[0]
        color := PrinterTheme#.field(pair[1], false)?.get(null)
        map.addNotNull(key, color)
      }

      // construct
      return make {
        it.symbol  = map["symbol"]
        it.str     = map["str"]
        it.comment = map["comment"]
      }
    }
    catch (Err e)
    {
      echo("ERROR: Cannot load pog theme")
      e.trace
      return none
    }
  }

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
    if (p.isa == null || !p.isa.info.isMarker) return false
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
    if (p.qname.isRoot || p.qname.isOrdinal || p.name.isEmpty) return
    name := p.name
    if (PogUtil.isMetaName(name)) name = name[1..-1]
    w(name)
    if (!markerOnly) wsymbol(":").sp
  }

  private Void printIs(Proto p)
  {
    isa := p.isa
    if (isa == null) return
    if (isa.info.isMaybe) return printIsMaybe(p)
    w(p.isa.qname.toStr)
  }

  private Void printIsMaybe(Proto p)
  {
    of := p.getOwn("_of", false)?.isa
    w(of == null ? "sys.Obj" : of.qname.toStr)
    wsymbol("?")
  }

  private Void printVal(Proto p)
  {
    val := p.valOwn(false)
    if (val == null) return
    sp.wquoted(val.toStr)
  }

  private Void printChildren(Proto p, Bool meta, Str open, Str close)
  {
    // find all the kids to dump
    kids := Proto[,]
    p.eachOwn |kid|
    {
      if (kid.isMeta != meta) return
      if (kid.name == "_doc") return
      if (kid.name == "_of" && p.isa.info.isMaybe) return
      kids.add(kid)
    }
    if (kids.isEmpty) return

    // if just markers then print in compact mode
    allMarkers := kids.all { printAsMarker(it) }
    if (allMarkers)
    {
      sp.wsymbol(open)
      kids.each |kid, i|
      {
        if (i > 0) wsymbol(",").sp
        printName(kid, true)
      }
      wsymbol(close)
    }
    else
    {
      sp.wsymbol(open).nl
      indention++
      kids.each |kid, i|
      {
        if (i > 0 && kid.name.size > 1 && kid.name[0].isUpper) nl
        print(kid)
      }
      indention--
      windent
      wsymbol(close)
    }
  }
}

**************************************************************************
** JsonPrinter
**************************************************************************

@Js
internal class JsonPrinter : Printer
{
  new make(OutStream out, [Str:Obj?]? opts := null) : super(out, opts) {}

  Void print(Obj? val)
  {
    if (val is Proto)
      printProto(val)
    else if (val is Map)
      printMap(val)
    else if (val is List)
      printList(val)
    else if (val == null)
      w("null")
    else if (val is Bool)
      w(val.toStr)
    else
      wquoted(val.toStr)
  }

  Void printProto(Proto proto)
  {
    map := Str:Obj[:]
    map.ordered = true
    map.addNotNull("_is", proto.isa?.qname)
    map.addNotNull("_val", proto.valOwn(false))
    proto.eachOwn |kid|
    {
      map[kid.name] = kid
    }
    printMap(map)
  }

  Void printMap(Str:Obj? map)
  {
    keys := map.keys
    if (!showloc) keys.remove("_loc")
    if (!showdoc) keys.remove("_doc")

    if (keys.size == 0)
      wsymbol("{}")
    else if (keys.size <= 1 || map["_val"] != null)
      printCompact(keys, map)
    else
      printComplex(keys, map)
  }

  Void printCompact(Str[] keys, Str:Obj? map)
  {
    first := true
    wsymbol("{")
    if (keys.contains("_is"))  first = printPair("_is", map["_is"], false, first)
    if (keys.contains("_val")) first = printPair("_val", map["_val"], false, first)
    keys.each |n|
    {
      if (n == "_is" || n == "_val") return
      v := map[n]
      first = printPair(n, v, false, first)
    }
    wsymbol("}")
  }

  Void printComplex(Str[] keys, Str:Obj? map)
  {
    wsymbol("{").nl
    indention++
    first := true
    keys.each |n|
    {
      v := map[n]
      first = printPair(n, v, true, first)
    }
    indention--
    nl.windent.wsymbol("}")
  }

  Bool printPair(Str n, Obj? v, Bool indenting, Bool first)
  {
    if (first)
    {
      if (indenting) windent
    }
    else
    {
      if (indenting)
         wsymbol(",").nl.windent
      else
        wsymbol(",").sp
    }
    wquoted(n)
    wsymbol(":")
    print(v)
    return false
  }

  Void printList(Obj?[] list)
  {
    wsymbol("[").nl
    indention++
    list.each |item, i|
    {
      if (i > 0) wsymbol(",").nl
      windent
      print(item)
    }
    indention--
    nl.windent.wsymbol("]")
  }
}

**************************************************************************
** TablePrinter
**************************************************************************

@Js
internal class TablePrinter : Printer
{
  new make(OutStream out, [Str:Obj?]? opts := null) : super(out, opts) {}

  This print(Str[][] cells)
  {
    if (cells.isEmpty) return this

    // compute col widths
    numCols := cells[0].size
    colWidths := Int[,].fill(0, numCols)
    cells.each |row|
    {
      row.each |cell, col|
      {
        colWidths[col] = colWidths[col].max(cell.size)
      }
    }

    // if total width exceeds terminal, first try to shrink down the biggest ones
    while (true)
    {
      total := 0
      colWidths.each |w| { total += w + 2 }
      if (total <= terminalWidth) break
      maxi := colWidths.size-1
      colWidths.each |w, i| { if (w > colWidths[maxi]) maxi = i }
      if (colWidths[maxi] < 16) break
      colWidths[maxi] = colWidths[maxi] - 1
    }

    // if total width still exceeds terminal, chop off last columns
    lastCol := numCols
    total := 0
    for (i := 0; i<numCols; ++i)
    {
      total += colWidths[i] + 2
      if (total > terminalWidth) break
      lastCol = i
    }

    // output
    cells.each |row, rowIndex|
    {
      isHeader := rowIndex == 0
      if (isHeader) wtheme(theme.comment)
      row.each |cell, col|
      {
        if (col > lastCol) return
        str := cell.replace("\n", " ")
        colw := colWidths[col]
        if (str.size > colw) str = str[0..<(colw-2)] + ".."
        w(str).w(Str.spaces(colw - str.size + 2))
      }
        nl
      if (isHeader)
      {
        numCols.times |col|
        {
          if (col > lastCol) return
          colw := colWidths[col]
          colw.times { wc('-') }
          w("  ")
        }
        nl
        wreset(theme.comment)
      }
    }

    return this
  }

  This printGrid(Grid g)
  {
    table := Str[][,]
    table.add(g.cols.map |c->Str| { c.dis })
    g.each |row|
    {
      cells := Str[,]
      cells.capacity = g.cols.size
      g.cols.each |c|
      {
        val := row.val(c)
        if (val is Str)
          cells.add(val)
        else
          cells.add(row.dis(c.name))
      }
      table.add(cells)
    }
    return print(table)
  }

}

**************************************************************************
** SummaryPrinter
**************************************************************************

@Js
internal class SummaryPrinter : Printer
{
  new make(OutStream out, [Str:Obj?]? opts := null) : super(out, opts) {}

  This print(Obj? val)
  {
    if (val == null)
      w("null").nl
    if (val is Proto)
      ((Proto)val).eachOwn |kid| { printProto(kid) }
    else if (val is Grid)
      ((Grid)val).each |row| { printDict(row) }
    else
      w("$val [$val.typeof]")
    return this
  }

  Void printProto(Proto p)
  {
    w(p.qname).wsymbol(":").sp
    if (p.isa != null) w(p.isa.qname)
    if (p.hasValOwn) sp.wquoted(p.valOwn.toStr)
    nl
  }

  Void printDict(Dict d)
  {
    wquoted(d.dis).sp.wsymbol("{")
    first := true
    d.each |v, n|
    {
      if (v == Marker.val)
      {
        if (first)
          first = false
        else
          sp
        w(n)
      }
    }
    wsymbol("}").nl
  }
}

