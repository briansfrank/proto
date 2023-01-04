//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   21 Dec 2022  Brian Frank  Creation
//

using util
using concurrent
using pog

**
** MLibMgr manages the cache and loading of the environments libs
**
@Js
internal const class MLibMgr
{
  new make(MPogEnv env)
  {
    this.env = env
    this.path = Env.cur.path.map |dir->File| { dir.plus(`pog/`) }
    this.entries = initEntries(this.path)
    this.installed = entries.keys.sort
  }

  private static Str:MLibEntry initEntries(File[] path)
  {
    acc := Str:MLibEntry[:]
    path.each |pogDir|
    {
      pogDir.listDirs.each |dir|
      {
        doInitInstalled(acc, dir)
      }
    }
    return acc
  }

  private static Void doInitInstalled(Str:MLibEntry acc, File dir)
  {
    hasLib := dir.plus(`lib.pog`).exists
    if (!hasLib) return

    qname := dir.name
    dup := acc[qname]
    if (dup != null) echo("WARN: PogEnv '$qname' lib hidden [$dup.dir.osPath]")
    acc[qname] = MLibEntry(qname, dir)
  }

  Bool isInstalled(Str libName)
  {
    entries[libName] != null
  }

  File? libDir(Str qname, Bool checked)
  {
    entry(qname, checked)?.dir
  }

  Lib? load(Str qname, Bool checked := true)
  {
    // check for install
    entry := entry(qname, checked)
    if (entry == null) return null

    // check for cached loaded lib
    lib := entry.libRef.val as Lib
    if (lib != null) return lib

    // compile the lib into memory and atomically cache once
    entry.libRef.compareAndSet(null, compile(entry))
    return entry.libRef.val
  }

  MLibEntry? entry(Str qname, Bool checked)
  {
    x := entries[qname]
    if (x != null) return x
    if (checked) throw UnknownLibErr("Not installed: $qname")
    return null
  }

  Proto compile(MLibEntry entry)
  {
    compilingPush(entry.qname)
    try
    {
      // TODO: change this to compile once we get ph working
      args := ["pog":env.data(entry.dir), "base":env.data(entry.qname)]
      return transduce("read", args).get
    }
    finally
    {
      compilingPop
    }
  }

  private Void compilingPush(Str qname)
  {
    stack := Actor.locals[compilingKey] as Str[]
    if (stack == null) Actor.locals[compilingKey] = stack = Str[,]
    if (stack.contains(qname)) throw Err("Cyclic lib dependency: $stack")
    stack.push(qname)
  }

  private Void compilingPop()
  {
    stack := Actor.locals[compilingKey] as Str[]
    if (stack == null) return
    stack.pop
    if (stack.isEmpty) Actor.locals.remove(compilingKey)
  }

  private TransduceData transduce(Str name, Str:Obj args)
  {
    x := env.transduce(name, args)
    if (x.isErr) echo(x.events.join("\n"))
    return x
  }

  const PogEnv env
  const Str compilingKey := "pogEnv.compiling"
  const File[] path
  const Str[] installed
  const Str:MLibEntry entries
}

**************************************************************************
** MLibEntry
**************************************************************************

@Js
internal const class MLibEntry
{
  new make(Str qname, File dir) { this.qname = qname; this.dir = dir }

  const Str qname
  const File dir
  const AtomicRef libRef := AtomicRef()
  override Str toStr() { "$qname [$dir.osPath]" }


  static Void main(Str[] args)
  {
    qname := args.first ?: "sys"
    echo("LOAD $qname ...")
    p := PogEnv.cur.load(qname)
    echo("LOADED!")
    p.print
  }
}