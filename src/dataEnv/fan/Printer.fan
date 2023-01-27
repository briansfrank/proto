//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   28 Dec 2022  Brian Frank  Creation
//

using util
using concurrent
using data
using xeto

**
** Pretty printer
**
@Js
internal class Printer
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  ** Constructor
  new make(OutStream out, DataDict opts)
  {
    this.out        = out
    this.opts       = opts
    this.escUnicode = optBool("escapeUnicode", false)
    this.showdoc    = optBool("showdoc", true)
    this.indention  = optInt("indent", 0)
    this.width      = optInt("width", terminalWidth)
    this.isStdout   = out === Env.cur.out
    this.theme      = isStdout ? PrinterTheme.configured : PrinterTheme.none
  }

//////////////////////////////////////////////////////////////////////////
// Objects
//////////////////////////////////////////////////////////////////////////

  ** Top level print
  This print(Obj? v)
  {
    val(v)
  }

  ** Print inline value
  This val(Obj? val)
  {
    if (val is DataSeq) return seq(val)
    if (val is Str) return quoted(val.toStr)
    if (val is List) return list(val)
    return w(val)
  }

  ** Print data sequence
  This seq(DataSeq seq)
  {
    if (seq is DataDict) return dict(seq)
    if (seq.typeof.name.endsWith("Grid")) return grid(seq)
    return list(seq.x.toList)
  }

  ** Print list
  This list(Obj?[] list)
  {
    bracket("[")
    list.each |v, i|
    {
      if (i > 0) w(", ")
      val(v)
    }
    bracket("]")
    return this
  }

  ** Print dict
  This dict(DataDict dict)
  {
    bracket("{")
    first := true
    dict.x.each |v, n|
    {
      if (first) first = false
      else w(", ")
      w(n)
      if (isMarker(v)) return
      w(": ")
      val(v)
    }
    bracket("}")
    return this
  }

  ** Print list
  This grid(DataSeq seq)
  {
    return table(seq->printCells)
  }

//////////////////////////////////////////////////////////////////////////
// Table
//////////////////////////////////////////////////////////////////////////

  ** Print table
  This table(Str[][] cells)
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
      if (total <= width) break
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
      if (total > width) break
      lastCol = i
    }

    // output
    cells.each |row, rowIndex|
    {
      isHeader := rowIndex == 0
      if (isHeader) color(theme.comment)
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
        colorEnd(theme.comment)
      }
    }

    return this
  }

//////////////////////////////////////////////////////////////////////////
// Theme Utils
//////////////////////////////////////////////////////////////////////////

  ** Enter color section which should be constant from PrinterTheme
  This color(Str? color)
  {
    if (color != null) w(color)
    return this
  }

  ** Exit colored section
  This colorEnd(Str? color)
  {
    if (color != null) w(PrinterTheme.reset)
    return this
  }

  ** Print quoted string in theme color
  This quoted(Str str, Str quote := "\"")
  {
    color(theme.str)
    w(quote)
    str.each |char|
    {
      if (char <= 0x7f || !escUnicode)
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
    w(quote)
    colorEnd(theme.str)
    return this
  }

  ** Print bracket such as "{}" in theme color
  This bracket(Str symbol)
  {
    color(theme.bracket).w(symbol).colorEnd(theme.bracket)
  }

  ** Print comment string in theme color
  This comment(Str str)
  {
    color(theme.comment).w(str).colorEnd(theme.comment)
  }

//////////////////////////////////////////////////////////////////////////
// OutStream Utils
//////////////////////////////////////////////////////////////////////////

  This w(Obj str) { out.print(str); return this }

  This wc(Int char) { out.writeChar(char); return this }

  This sp() { wc(' ') }

  This nl() { out.printLine; return this }

  This indent() { w(Str.spaces(indention*2)) }

//////////////////////////////////////////////////////////////////////////
// Data Utils
//////////////////////////////////////////////////////////////////////////

  private Bool isMarker(Obj? val) { val is DataMarker }

//////////////////////////////////////////////////////////////////////////
// Options
//////////////////////////////////////////////////////////////////////////

  Obj? opt(Str name, Obj? def := null) { opts.get(name, def) }

  Bool optBool(Str name, Bool def) { opt(name, def) as Bool ?: def }

  Int optInt(Str name, Int def) { opt(name, def) as Int ?: def }

  static Int terminalWidth()
  {
    try
    {
      jline := Type.find("[java]jline::TerminalFactory", false)
      if (jline != null) return jline.method("get").call->getWidth
    }
    catch (Err e) { e.trace }
    return 80
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private OutStream out        // output stream
  private Int indention        // current level of indentation
  const Bool isStdout          // are we printing to stdout
  const DataDict opts          // options
  const Bool escUnicode        // escape unicode above 0x7f
  const Bool showdoc           // print documentation
  const Int width              // terminal width
  const PrinterTheme theme     // syntax color coding
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
      // load from environment variable:
      // export DATA_PRINT_THEME="bracket:red, str:cyan, comment:green"
      var := Env.cur.vars["DATA_PRINT_THEME"]
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
        it.bracket = map["bracket"]
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

  const Str? bracket
  const Str? str
  const Str? comment
}