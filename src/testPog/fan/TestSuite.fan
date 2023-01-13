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
using pogCli
using haystack

**
** TestSuite runs all the declartive tests captured YAML files.
**
class TestSuite : Test
{
  Void test() { run(Str[,]) }

  Void run(Str[] args)
  {
    base := Env.cur.path.find { it.plus(`test/parse.yaml`).exists }
    if (base == null) throw Err("Test dir not found")
    r := PogTestRunner(this, args).runDir(base.plus(`test/`))
    if (r.numFails > 0) fail("TestSuite $r.numFails failures: $r.failed")
  }
}

** Main to run test suite straight from command line
class Main { Void main(Str[] args) { TestSuite().run(args) } }

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
      runExprs(def)
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

  Void runExprs(Str:Obj def)
  {
    // parse the 'test' field into list of CLI exprs
    exprs := CmdExpr.parse(def.getChecked("test"))

    // map fields into variable scope
    vars := Str:TransduceData[:]
    def.each |v, n|
    {
      if (n == "name" || n == "test") return
      vars[n] = env.data(v, ["str", "test"], FileLoc("test.$n"))
    }
    vars["temp"] = env.data(Buf())

    // evaluate each expr
    exprs.each |expr, i|
    {
      if (expr.name == "verify")
        runVerify(expr, vars)
      else
        runTransduce(expr, vars, !isNextVerifyEvents(exprs.getSafe(i+1)))
    }


    hasVerify := exprs.any |expr| { expr.name == "verify" }
    if (!hasVerify) fail("No verify expr", null)
  }

  private Bool isNextVerifyEvents(CmdExpr? next)
  {
    if (next == null) return false
    if (next.name != "verify") return false
    return next.args.first?.val == "events"
  }


  Void runTransduce(CmdExpr expr, Str:TransduceData vars, Bool dumpErrs)
  {
    targs := Str:TransduceData[:]
    targs.addNotNull("it", vars["it"])
    targs["isTest"] = env.data(true)
    expr.args.each |arg|
    {
      name := arg.name ?: "it"
      val := arg.val
      data := PogUtil.isName(val) ? vars.getChecked(val) : env.data(val)
      targs[name] = data
    }
    result := env.transduce(expr.name, targs)
    if (result.isErr && dumpErrs) echo(result.events.join("\n"))
    vars["it"] = result
  }

  Void runVerify(CmdExpr expr, Str:TransduceData vars)
  {
    actual := vars.get("it") as TransduceData ?: throw Err("Missing it data")
    arg    := expr.args.first ?: throw Err("Expecting verify mode:field")
    mode   := arg.name ?: arg.val
    expect := vars.getChecked(arg.val).getStr
    switch (mode)
    {
      case "json":   verifyJson(actual, expect)
      case "pog":    verifyPog(actual, expect)
      case "zinc":   verifyZinc(actual,expect)
      case "str":    verifyStr(actual,expect)
      case "events": verifyEvents(actual, expect)
      default: throw Err("Unknown verify mode: $mode")
    }
  }

  Void verifyJson(TransduceData t, Str expected)
  {
    expected = expected.trim
    buf := StrBuf()
    if (t.tags.first == "proto") t = env.transduce("export", ["ast":t, "isTest":env.data(true)])
    env.transduce("print", ["it":t, "to":env.data(buf.out), "showloc":env.data(false), "isTest":env.data(true)])
    json := buf.toStr.trim

    if (verbose || json != expected)
    {
      echo
      echo("--- JSON [$cur] ---")
      PogUtil.print(t.get(false), Env.cur.out, ["showloc":env.data(false)])
      dump(json, expected)
    }
    verifyEq(json, expected)
  }

  Void verifyPog(TransduceData t, Str expected)
  {
    expected = expected.trim
    buf := StrBuf()
    env.transduce("print", ["it":t, "to":env.data(buf.out), "isTest":env.data(true)])
    pog := buf.toStr.trim

    if (verbose || pog != expected)
    {
      echo
      echo("--- POG [$cur] ---")
      PogUtil.print(t.get(false))
      dump(pog, expected)
      echo
      PogUtil.print(t.get(false), Env.cur.out, ["summary":true])
    }
    verifyEq(pog, expected)
  }

  Void verifyZinc(TransduceData data, Str expected)
  {
    expected = expected.trim
    buf := StrBuf()
    grid := data.getAs(Grid#)
    actual := ZincWriter.gridToStr(grid).trim

    if (verbose || actual != expected)
    {
      echo
      echo("--- Zinc [$cur] ---")
      PogUtil.print(data.get(false))
      dump(actual, expected)
    }
    verifyEq(actual, expected)
  }

  Void verifyStr(TransduceData data, Str expected)
  {
    expected = expected.trim
    actual := data.getStr.trim

    if (verbose || actual != expected)
    {
      echo
      echo("--- Str [$cur] ---")
      echo(data.getStr)
      dump(actual, expected)
    }
    verifyEq(actual, expected)
  }

  Void verifyEvents(TransduceData t, Str? expectedTable)
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

  Void fail(Str msg, Err? e)
  {
    numFails++
    if (e is FileLocErr) msg += " " + ((FileLocErr)e).loc
    echo
    echo("TEST FAILED: $msg")
    e?.trace
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

