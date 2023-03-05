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
    testName := loc.file.toUri.basename + "." + name

    if (skip(testName)) return this

    echo("   - $testName [Line $loc.line]")

    try
    {
      DataTestCase(this, testName, def).run
    }
    catch (Err e)
    {
      fail(testName, e)
    }
    return this
  }

  Bool skip(Str testName)
  {
    if (runAll) return false
    return !args.any { testName.contains(it) }
  }

  Void fail(Str testName, Err? e)
  {
    numFails++
    echo
    echo("TEST FAILED: $testName")
    e?.trace
    echo
    failed.add(testName)
  }

  DataEnv env := DataEnv.cur
  Str[] args
  Bool runAll
  Bool verbose
  Test test
  Int numFails
  Str[] failed := [,]
}

**************************************************************************
** DataTestCase
**************************************************************************

class DataTestCase
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(DataTestRunner runner, Str testName, Str:Obj? def)
  {
    this.runner   = runner
    this.test     = runner.test
    this.env      = runner.env
    this.testName = testName
    this.def      = def
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  Void run()
  {
    def.each |v, n|
    {
      if (n == "name") return
      runStep(n, v)
    }
    if (numVerifies == 0) echo("     WARN: no verifies")
  }

  Void runStep(Str name, Obj? val)
  {
    m := typeof.method(name)
    m.callOn(this, [val])
  }

//////////////////////////////////////////////////////////////////////////
// Steps
//////////////////////////////////////////////////////////////////////////

  Void loadLib(Str qname)
  {
    this.libRef = env.lib(qname)
  }

  Void compileLib(Str src)
  {
    this.libRef = env.compileLib(src)
  }

  Void compileData(Str src)
  {
     this.dataRef = env.compileData(src)
  }

  Void verifyType(Str:Obj? expect)
  {
    doVerifyType(lib.slot(expect.getChecked("name")), expect)
  }

  Void verifyTypes(Str:Obj? expect)
  {
    expect.each |e, n| { doVerifyType(lib.slot(n), e) }
  }

  Void verifyData(Obj expect)
  {
    verifyVal(data, expect)
  }

//////////////////////////////////////////////////////////////////////////
// DataSpec Verifies
//////////////////////////////////////////////////////////////////////////

  Void doVerifyType(DataType type, Str:Obj? expect)
  {
    verifyEq(type.qname, type.lib.qname + "::" + type.name)
    verifySame(type.type, type)
    verifySupertype(type, expect["supertype"])
    verifyMeta(type, expect["meta"])
    verifySlots(type, expect["slots"])
  }

  Void verifySupertype(DataType type, Str? expect)
  {
    verifyEq(type.supertype?.qname, expect)
  }

  Void verifyMeta(DataSpec spec, [Str:Obj?]? expect)
  {
    if (expect == null)
    {
      verifyEq(spec.own.isEmpty, true)
      return
    }

    expect.each |e, n| { verifyMetaPair(spec, n, e) }
    spec.each |v, n| { verify(expect.containsKey(n), n) }
    spec.own.each |v, n| { verify(expect.containsKey(n), n) }
  }

  Void verifyMetaPair(DataSpec spec, Str name, Obj expect)
  {
    if (expect == "inherit")
      verifyMetaInherit(spec, name)
    else
      verifyMetaOwn(spec, name, expect)
  }

  Void verifyMetaInherit(DataSpec spec, Str name)
  {
    verifyEq(spec.own.has(name), false)
    verifyEq(spec.own.missing(name), true)
    verifyEq(spec.own[name], null)
    verifyErr(UnknownDataErr#) { spec.own.trap(name) }

    verifyEq(spec.has(name), true)
    verifyEq(spec.missing(name), false)
    verifySame(spec.get(name), spec.type.supertype.get(name))
  }

  Void verifyMetaOwn(DataSpec spec, Str name, Obj expect)
  {
    verifyEq(spec.own.has(name), true)
    verifyEq(spec.own.missing(name), false)
    verifyVal(spec.own[name], expect)

    verifyEq(spec.has(name), true)
    verifyEq(spec.missing(name), false)
    verifySame(spec.get(name), spec.own.get(name))

    verifyVal(spec.get(name), expect)
  }

  Void verifySlots(DataSpec spec, [Str:Obj?]? expect)
  {
    if (expect == null)
    {
      verifyEq(spec.slotsOwn.isEmpty, true)
      verifyEq(spec.slots.isEmpty, true)
      return
    }
    expect.each |e, n| { verifySlot(spec, n, e) }
    spec.slots.each |v, n| { verify(expect.containsKey(n)) }
    spec.slotsOwn.each |v, n| { verify(expect.containsKey(n)) }
  }

  Void verifySlot(DataSpec spec, Str name, Obj expect)
  {
    slot := spec.slot(name)
    verifySame(spec.slotOwn(name), slot)
    verifySame(spec.slots.get(name), slot)
    verifySame(spec.slotsOwn.get(name), slot)
    // TODO
  }

//////////////////////////////////////////////////////////////////////////
// Data Verifies
//////////////////////////////////////////////////////////////////////////

  Void verifyVal(Obj? val, Obj? expect)
  {
    if (expect == null) return
    type := env.typeOf(val)
    if (type.isaScalar)
      verifyScalar(val, type, expect)
    else if (type.isaDict)
      verifyDict(val, expect)
    else
      throw Err("Unhandled type: $type")
  }

  Void verifyScalar(Obj val, DataType type, Str expect)
  {
    // scalar expect format is "<type> <val>"
    expectType := expect
    expectVal := null
    sp := expect.index(" ")
    if (sp != null)
    {
      expectType = expect[0..<sp]
      expectVal  = expect[sp+1..-1].trim
    }

    verifyEq(type.qname, expectType)
    if (expectVal != null) verifyStr(val.toStr, expectVal)
  }

  Void verifyDict(DataDict dict, Str:Obj expect)
  {
    verifyDictSpec(dict.spec, expect.getChecked("spec"))
    expect.each |e, n|
    {
      if (n == "spec") return
      verifyVal(dict[n], e)
    }
    dict.each |v, n| { verify(expect[n] != null) }
  }

  Void verifyDictSpec(DataSpec spec, Str expect)
  {
    verifyEq(spec.type.qname, expect)
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  DataLib lib()
  {
    libRef ?: throw Err("Missing loadLib/compileLib")
  }

  Obj data()
  {
    dataRef ?: throw Err("Missing compileData")
  }

  Void verifyStr(Str actual, Str expected)
  {
    actual = actual.trim
    expected = expected.trim

    if (runner.verbose || actual != expected)
    {
      echo
      echo("--- Str [$testName] ---")
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

//////////////////////////////////////////////////////////////////////////
// Test Verifies
//////////////////////////////////////////////////////////////////////////

  Void verify(Bool cond, Str? msg := null)
  {
    numVerifies++
    test.verify(cond, msg)
  }

  Void verifyErr(Type? errType, |Test| c)
  {
    numVerifies++
    test.verifyErr(errType, c)
  }

  Void verifyEq(Obj? a, Obj? b, Str? msg := null)
  {
    // if (a != b) echo("  FAIL: $a [${a?.typeof}] ?= $b [${b?.typeof}] | $msg")
    numVerifies++
    test.verifyEq(a, b, msg)
  }

  Void verifySame(Obj? a, Obj? b, Str? msg := null)
  {
    numVerifies++
    test.verifySame(a, b, msg)
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  DataTestRunner runner   // make
  DataEnv env             // make
  Test test               // make
  Str testName            // make
  Str:Obj? def            // make
  DataLib? libRef         // compileLib, loadLib
  Obj? dataRef            // compileData
  Int numVerifies         // verifyX
}


