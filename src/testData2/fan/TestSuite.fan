//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Dec 2022  Brian Frank  Creation
//

using util
using yaml
using data2
using haystack

**
** TestSuite runs all the declartive tests captured in YAML files.
**
class TestSuite : Test
{
  Void test() { run(Str[,]) }

  Void run(Str[] args)
  {
    testsDir := `src/testData2/tests/`
    testsFile := testsDir + `sys.yaml`
    base := Env.cur.path.find { it.plus(testsFile).exists }
    if (base == null) throw Err("Test dir not found")
    r := DataTestRunner(this, args).runDir(base.plus(testsDir))
    if (r.numFails > 0) fail("TestSuite $r.numFails failures: $r.failed")
  }
}

** Main to run test suite straight from command line
class Main { Void main(Str[] args) { TestSuite().run(args) } }

**************************************************************************
** DataTestRunner
**************************************************************************

class DataTestRunner
{
  new make(Test test, Str[] args)
  {
    this.test     = test
    this.args     = args
    this.runAll   = args.isEmpty || args.contains("-all")
    this.verbose  = args.contains("-v")
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

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
    YamlReader(file).parse.each |doc|
    {
      def := doc.decode
      if (def == null) return
      runTest(doc.loc, def)
    }
    return this
  }

  This runTest(FileLoc loc, Str:Obj? def)
  {
    name := def["name"] ?: "unknown"
    qname := loc.file.toUri.basename + "." + name

    if (skip(qname)) return this

    cur = qname
    echo("   - $qname [Line $loc.line]")

    try
    {
      doRunTest(def)
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

  Void doRunTest(Str:Obj? def)
  {
    withType := def["withType"]
    if (withType != null)
    {
      type := env.type(withType)
      runVerifies(type, def)
      return
    }
    throw Err("Test missing any verifies")
  }

  Void runVerifies(DataType type, Str:Obj? def)
  {
    def.each |v, n|
    {
      if (!n.startsWith("verify")) return
      typeof.method(n).callOn(this, [type, v])
    }
  }

//////////////////////////////////////////////////////////////////////////
// Verify Methods
//////////////////////////////////////////////////////////////////////////

  Void verifyBase(DataType type, Str? expected)
  {
    verifyEq(type.base?.qname, expected)
  }

  Void verifyVal(DataSpec spec, Str expected)
  {
    what := "${spec}.val"
    val := spec.val

    verifyEq(env.typeOf(val), spec.type, what)
    if (val.toStr == expected)
      verifyEq(val.toStr, expected)
    else
      verifyEq(val.typeof.method("fromStr").call(expected), val)
  }

  Void verifyMeta(DataSpec spec, Str:Obj? expected)
  {
    expected.each |v, n|
    {
      verifyMetaPair(spec, n, v)
    }

    spec.each |v, n| { test.verify(expected[n] != null, n) }
    spec.own.each |v, n| { test.verify(expected[n] != null && expected[n].toStr.startsWith("o"), n) }
  }

  Void verifyMetaPair(DataSpec spec, Str name, Str expected)
  {
    what := "${spec}.${name}"

    // parse "flag type val"
    flag := expected[0..0]
    type := expected[2..-1].trim
    val := null
    sp := expected.index(" ", 2)
    if (sp != null)
    {
      type = expected[2..<sp].trim
      val = expected[sp+1..-1].trim
    }

    switch (flag)
    {
      case "o":
        verifyEq(spec.has(name), true, what)
        verifyEq(spec.missing(name), false, what)
        verifyEq(spec.own.has(name), true, what)
        verifyEq(spec.own.missing(name), false, what)
        verifySame(spec[name], spec.own[name], what)
        verifyScalar(spec.own[name], type, val, what)

      default:
        throw Err("Invalid flag for verifyMeta: $flag.toCode; $expected")
    }

  }

  Void verifyScalar(Obj? actual, Str type, Str? val, Str what)
  {
    //echo("     $what: $actual [$actual.typeof] ?= $type $val")
    verifyEq(env.typeOf(actual).qname, type, what)
    if (val != null) verifyEq(actual.toStr, val, what)
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  Void verifyStr(Str actual, Str expected)
  {
    actual = actual.trim
    expected = expected.trim

    if (verbose || actual != expected)
    {
      echo
      echo("--- Str [$cur] ---")
      dump(actual, expected)
    }
    verifyEq(actual, expected)
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

  Void verifyEq(Obj? a, Obj? b, Str? msg := null)
  {
    if (a != b) echo("  FAIL: $a [${a?.typeof}] ?= $b [${b?.typeof}] | $msg")
    test.verifyEq(a, b, msg)
  }

  Void verifySame(Obj? a, Obj? b, Str? msg := null)
  {
    test.verifySame(a, b, msg)
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

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  DataEnv env := DataEnv.cur
  Str[] args
  Bool runAll
  Bool verbose
  Test test
  Int numFails
  Str cur := "?"
  Str[] failed := [,]
}

