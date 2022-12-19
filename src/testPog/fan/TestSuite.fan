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
  Void test()
  {
    base := Env.cur.path.find { it.plus(`test/parse.yaml`).exists }
    if (base == null) throw Err("Test dir not found")
    r := PogTestRunner(this).runDir(base.plus(`test/`))
    if (r.numFails > 0) fail("TestSuite $r.numFails failures")
  }
}

**************************************************************************
** PogTestRunner
**************************************************************************

class PogTestRunner
{
  new make(Test test)
  {
    this.test = test
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
    echo("   - $qname")
    try
    {
      // right now only support "parse, json"
      run := def.getChecked("run")
      if (run != "parse, json") throw Err("TODO: $run")
      runParseJson(def)
    }
    catch (Err e)
    {
      fail("$qname failed", e)
    }
    return this
  }

  Void runParseJson(Str:Obj def)
  {
    pog := def.getChecked("pog")
    expected := def.getChecked("json").toStr.trim
    actual := env.transducer("parse").transduce(pog)
    buf := StrBuf()
    JsonOutStream(buf.out).writeJson(actual)
    test.verifyEq(buf.toStr, expected)
  }


  Void fail(Str msg, Err e)
  {
    echo
    echo("TEST FAILED: $msg")
    e.trace
    echo
  }

  PogEnv env := PogEnv.cur
  Test test
  Int numFails
}

