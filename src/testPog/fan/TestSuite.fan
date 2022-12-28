//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Dec 2022  Brian Frank  Creation
//

using util
using yaml
using pog

**
** TestSuite runs all the declartive tests captured YAML files.
**
class TestSuite : Test
{
  Void main(Str[] args) { run(args) }

  Void test() { run(Str[,]) }

  Void run(Str[] args)
  {
    base := Env.cur.path.find { it.plus(`test/parse.yaml`).exists }
    if (base == null) throw Err("Test dir not found")
    r := PogTestRunner(this, args).runDir(base.plus(`test/`))
    if (r.numFails > 0) fail("TestSuite $r.numFails failures: $r.failed")
  }
}

**************************************************************************
** PogTestRunner
**************************************************************************

class PogTestRunner
{
  new make(Test test, Str[] args)
  {
    this.test     = test
    this.args     = args
    this.runAll   = args.isEmpty || args.contains("-all")
    this.verbose  = args.contains("-v")
  }

  This runDir(File dir)
  {
    dir.list.each |file|
    {
      if (file.ext != "yaml") return
      try
        runFile(file)
      catch (Err e)
        fail("Cannot parse file [$file.osPath]", e)
    }
    return this
  }

  This runFile(File file)
  {
    echo("   Run [$file.osPath] ...")
    docs := (Obj?[])YamlReader(file.in).parse.decode
    docs.each |doc|
    {
      if (doc == null) return
      runTest(file.basename, doc)
    }
    return this
  }

  This runTest(Str filename, Str:Obj def)
  {
    name := def["name"] ?: "unknown"
    qname := filename + "." + name

    if (skip(qname)) return this

    cur = qname
    echo("   - $qname")

    try
    {
      // TODO test basd on filename
      switch (filename)
      {
        case "parse":    runParse(def)
        case "resolve":  runResolve(def)
        case "reify":    runReify(def)
        case "validate": runValidate(def)
        default:         throw Err("Unknown test type: $filename")
      }
    }
    catch (Err e)
    {
      fail("$qname failed", e)
    }
    return this
  }

  Bool skip(Str qname)
  {
    if (runAll) return false
    return !args.any { qname.contains(it) }
  }

  Void runParse(Str:Obj def)
  {
    pog    := def.getChecked("pog")
    events := def.get("events")
    json   := def.getChecked("json", events == null)

    a := transduce("parse", ["read":pog], events == null)
    if (events == null)
    {
      verifyJson(a, json)
    }
    else
    {
      verifyEvents(a, events)
    }
  }

  Void runResolve(Str:Obj def)
  {
    pog    := def.getChecked("pog")
    json   := def.getChecked("json")
    events := def.get("events")

    a := transduce("parse", ["read":pog]).get
    b := transduce("resolve", ["ast":a], false)
    verifyJson(b, json)
    verifyEvents(b, events)
  }

  Void runReify(Str:Obj def)
  {
    pog    := def.getChecked("src")
    json   := def.getChecked("json")

    a := transduce("parse",   ["read":pog]).get
    b := transduce("resolve", ["ast":a, "base":"test"]).get
    c := transduce("reify",   ["ast":b, "base":"test"])
    verifyJson(c, json)
  }

  Void runValidate(Str:Obj def)
  {
    pog    := def.getChecked("src")
    events := def.getChecked("events")

    a := transduce("parse",    ["read":pog]).get
    b := transduce("resolve",  ["ast":a, "base":"test"]).get
    c := transduce("reify",    ["ast":b, "base":"test"]).get
    d := transduce("validate", ["graph":c])
((Proto)d.get).dump
    verifyEvents(d, events)
  }

  Transduction transduce(Str name, Str:Obj args, Bool dumpErrs := true)
  {
    t := env.transduce(name, args)
    if (t.isErr && dumpErrs) echo(t.errs.join("\n"))
    return t
  }

  Void verifyJson(Transduction t, Str expected)
  {
    expected = expected.trim
    buf := StrBuf()
    env.transduce("json", ["val":t.get(false), "write":buf.out])
    json := buf.toStr.trim

    if (verbose || json != expected)
    {
      echo
      echo("--- JSON [$cur] ---")
      echo(json)
      dump(json, expected)
    }
    verifyEq(json, expected)
  }

  Void verifyEvents(Transduction t, Str? expectedTable)
  {
    if (expectedTable == null) return

    if (verbose)
    {
      echo
      echo("--- Events [$cur] ---")
      echo(t.events.join("\n"))
      echo
    }

    // inspect first line to detect separator
    lines := expectedTable.splitLines
    header := lines[0]
    sep := '|'
    for (i := 0; i<header.size; ++i)
    {
      ch := header[i]
      if (ch.isAlphaNum || ch.isSpace) continue
      sep = ch
      break
    }

    // process each line as table of cells with given separator
    names := header.split(sep)
    lines = lines[1..-1].findAll { !it.trim.isEmpty }
    lines.each |line, i|
    {
      event := t.events.getSafe(i)
      if (event == null) return

      s := StrBuf()
      names.each |n| { s.join(event.trap(n), sep.toChar) }
      actual := s.toStr

      expected := line.split(sep).join(sep.toChar)

      if (actual != expected)
      {
        echo("FAIL Event:")
        echo("  $actual")
        echo("  $expected")
      }

      verifyEq(actual, expected)
    }
    verifyEq(t.events.size, lines.size)
  }

  Void dump(Str a, Str b)
  {
    echo
    aLines := a.splitLines
    bLines := b.splitLines
    max := aLines.size.max(bLines.size)
    for (i := 0; i<max; ++i)
    {
      aLine := aLines.getSafe(i) ?: ""
      bLine := bLines.getSafe(i) ?: ""
      echo("$i:".padr(3) +  aLine)
      echo("   "         +  bLine)
      if (aLine != bLine)
      {
        s := StrBuf()
        aLine.each |ch, j|
        {
          match := bLine.getSafe(j) == ch
          s.add(match ? "_" : "^")
        }
        echo("   " + s)
      }
    }
  }

  Void verifyEq(Obj? a, Obj? b)
  {
    test.verifyEq(a, b)
  }

  Void fail(Str msg, Err e)
  {
    numFails++
    if (e is FileLocErr) msg += " " + ((FileLocErr)e).loc
    echo
    echo("TEST FAILED: $msg")
    e.trace
    echo
    failed.add(cur)
  }

  PogEnv env := PogEnv.cur
  Str[] args
  Bool runAll
  Bool verbose
  Test test
  Int numFails
  Str cur := "?"
  Str[] failed := [,]
}

