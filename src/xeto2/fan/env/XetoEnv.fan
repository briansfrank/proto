//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using concurrent
using util
using data2

**
** Xeto DataEnv implementation
**
@Js
internal const class XetoEnv : DataEnv
{
  new make()
  {
    this.libMgr = XetoLibMgr(this)
    this.emptyDict = MDict(Str:Obj[:])
    this.factory = XetoFactory()
    this.sys = MSys(libMgr.load("sys"))
  }

  const XetoLibMgr libMgr

  const MSys sys

  const XetoFactory factory

  override Obj marker() { factory.marker }

  const override DataDict emptyDict

  override DataSpec dictSpec() { sys.dict }

  override DataDict dict(Obj? val)
  {
    if (val == null) return emptyDict
    if (val is DataDict) return val
    map := val as Str:Obj? ?: throw ArgErr("Unsupported dict arg: $val.typeof")
    if (map.isEmpty) return emptyDict
    return MDict(map)
  }

  override Str[] libsInstalled() { libMgr.installed }

  override Bool isLibLoaded(Str qname) { libMgr.isLoaded(qname) }

  override MLib? lib(Str qname, Bool checked := true) { libMgr.load(qname, checked) }

  override Void print(Obj? val, OutStream out := Env.cur.out, Obj? opts := null)
  {
    Printer(this, out, dict(opts)).print(val)
  }

  override DataLib compile(Str src)
  {
    qname := "temp" + compileCount.getAndIncrement

    src = """pragma: Lib <
                version: "0"
                depends: { { lib: "sys" } }
              >
              """ + src

    c := XetoCompiler
    {
      it.env = this
      it.qname = qname
      it.input = src.toBuf.toFile(`temp.xeto`)
    }
    return c.compileLib
  }

  override Obj? parse(Str src)
  {
    c := XetoCompiler
    {
      it.env = this
      it.input = src.toBuf.toFile(`parse.xeto`)
    }
    return c.compileData
  }

  override MType? type(Str qname, Bool checked := true)
  {
    colon := qname.index("::") ?: throw ArgErr("Invalid qname: $qname")
    libName := qname[0..<colon]
    typeName := qname[colon+2..-1]
    return lib(libName, checked)?.declared?.get(typeName, checked)
  }

  override Void dump(OutStream out := Env.cur.out)
  {
    out.printLine("=== XetoEnv ===")
    out.printLine("Lib Path:")
    libMgr.path.each |x| { out.printLine("  $x.osPath") }
    max := libsInstalled.reduce(10) |acc, x| { x.size.max(acc) }
    out.printLine("Installed Libs:")
    libMgr.installed.each |x| { out.printLine("  " + x.padr(max) + " [" + libMgr.libDir(x, true).osPath + "]") }
  }

  private const ConcurrentMap libs := ConcurrentMap()
  private const AtomicInt compileCount := AtomicInt()
}

