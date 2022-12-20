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
    //if (name != "metaAndChildren") return this
    qname := filename + "." + name
    echo("   - $qname")
    try
    {
      // right now only support "parse, json"
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

    // parse pog string to AST
    ast := env.transduce("parse", ["read":pog])

    // transduce AST to normalized JSON
    buf := StrBuf()
    env.transduce("json", ["val":ast, "write":buf.out])
    json := buf.toStr.trim

    // echo; echo(json)
    // dump(json, expected)

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
  }

  PogEnv env := PogEnv.cur
  Test test
  Int numFails
}

