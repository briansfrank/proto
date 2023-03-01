//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   21 Dec 2022  Brian Frank  Creation
//   25 Jan 2023  Brian Frank  Redesign from proto
//

using util
using data2

**
** Resolve all type refs
**
@Js
internal class Resolve : Step
{
  override Void run()
  {
    resolveDepends
    resolveObj(ast)
    bombIfErr
  }

  private Void resolveDepends()
  {
    // sys has no dependencies
    if (isSys) return

    // import dependencies from pragma
    astDepends := pragma?.meta?.get("depends") ?: AObj(FileLoc.unknown)
    astDepends.slots.each |astDepend|
    {
      // get library name from depend formattd as "{lib:<qname>}"
      loc := astDepend.loc
      libName := astDepend.slots.get("lib")?.val as Str
      if (libName == null) return err("Depend missing lib name", loc)

      // resolve the library from environment
      lib := env.lib(libName, false)
      if (lib == null) return err("Depend lib '$libName' not installed", loc)

      // register the library into our depends map
      if (depends[libName] != null) return err("Duplicate depend '$libName'", loc)
      depends[libName] = lib
    }

    // if not specified, assume just sys
    if (depends.isEmpty)
    {
      if (isLib) err("Must specify 'sys' in depends", pragma?.loc ?: ast.loc)
      depends["sys"] = env.lib("sys")
      return
    }
  }

  private Void resolveObj(AObj obj)
  {
    resolveRef(obj.type)
    resolveMap(obj.meta)
    resolveMap(obj.slots)
    resolveVal(obj.val)
  }

  private Void resolveMap(AMap? map)
  {
    if (map == null) return
    map.each |kid| { resolveObj(kid) }
  }

  private Void resolveVal(Obj? val)
  {
    if (val is ARef) { resolveRef(val); return }
    if (val is List) { ((List)val).each |x| { resolveVal(x) }; return }
  }

  private Void resolveRef(ARef? ref)
  {
    // short circuit if null or already resolved
    if (ref == null) return
    if (ref.isResolved) return

    // resolve qualified name
    n := ref.name
    if (n.isQualified) return resolveQualified(ref)

    // match to name within this AST which trumps depends
    ref.resolvedRef = ast.slots.get(n.name)?.asmRef
    if (ref.isResolved) return

    // match to external dependencies
    matches := MSpec[,]
    depends.each |lib| { matches.addNotNull(lib.slotOwn(n.name, false)) }
    if (matches.isEmpty)
      err("Unresolved type: $n", ref.loc)
    else if (matches.size > 1)
      err("Ambiguous type: $n $matches", ref.loc)
    else
      ref.resolvedRef = matches.first.selfRef
  }

  private Void resolveQualified(ARef ref)
  {
    // if in my own lib
    n := ref.name
    if (n.lib == compiler.qname)
    {
      ref.resolvedRef = ast.slots.get(n.name)?.asmRef
      if (!ref.isResolved) return err("Spec '$n' not found in lib", ref.loc)
      return
    }

    // resolve from dependent lib
    MLib? lib := depends[n.lib]
    if (lib == null) return err("Spec lib '$n' is not included in depends", ref.loc)

    // resolve in lib
    ref.resolvedRef = lib.slotOwn(n.name, false)?.selfRef
    if (!ref.isResolved) return err("Unresolved spec '$n' in lib", ref.loc)
  }

  private Str:MLib depends := [:]
}