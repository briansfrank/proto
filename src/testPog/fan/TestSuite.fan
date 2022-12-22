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
        case "parse":   runParse(def)
        case "resolve": runResolve(def)
        default:        throw Err("Unknown test type: $filename")
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
    pog := def.getChecked("pog")
    ast := env.transduce("parse", ["read":pog]).get
    verifyJson(def, ast)
  }

  Void runResolve(Str:Obj def)
  {
    pog := def.getChecked("pog")
    ast := env.transduce("parse", ["read":pog]).get
    proto := env.transduce("resolve", ["ast":ast]).get
    verifyJson(def, proto)
  }

  Void verifyJson(Str:Obj def, Obj actual)
  {
    expected := def.getChecked("json").toStr.trim

    // transduce actual normalized JSON
    buf := StrBuf()
    env.transduce("json", ["val":actual, "write":buf.out])
    json := buf.toStr.trim

    if (verbose || json != expected)
    {
      echo
      echo(json)
      dump(json, expected)
    }

    // verify
    test.verifyEq(json, expected)
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

