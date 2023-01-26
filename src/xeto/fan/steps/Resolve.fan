//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   21 Dec 2022  Brian Frank  Creation
//   25 Jan 2023  Brian Frank  Redesign from proto
//

using util
using data

**
** Resolve all type refs
**
@Js
internal class Resolve : Step
{
  override Void run()
  {
    resolveDepends
    resolve(ast)
    bombIfErr
  }

  private Void resolveDepends()
  {
    // sys has no dependencies
    if (isSys) return

    // import dependencies from pragma
    astDepends := pragma?.meta?.get("depends") ?: XetoObj(FileLoc.unknown)
    astDepends.slots.each |astDepend|
    {
      // get library name from depend formattd as "{lib:<qname>}"
      loc := astDepend.loc
      libName := astDepend.slots["lib"]?.val as Str
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

  private Void resolve(XetoObj obj)
  {
    resolveType(obj.type)
    obj.each |kid| { resolve(kid) }
  }

  private Void resolveType(XetoType? type)
  {
    if (type == null) return
    if (type.isResolved) return

    name := type.name

    // resolve qualified name
    if (name.contains(".")) return resolveQualifiedType(type)

    // match to name within this AST which trumps depends
    type.inside = ast.slots[name]
    if (type.inside != null) return

    // match to external dependencies
    matches := DataType[,]
    depends.each |lib|
    {
      matches.addNotNull(lib.libType(name, false))
    }
    if (matches.isEmpty)
      err("Unresolved type: $name", type.loc)
    else if (matches.size > 1)
      err("Ambiguous type: $name $matches", type.loc)
    else
      type.outside = matches.first
  }

  private Void resolveQualifiedType(XetoType type)
  {
    // find lib name index
    qname := type.name
    typei := -1
    for (i := 2; i<qname.size; ++i)
    {
      if (qname[i-1] == '.' && qname[i].isUpper) { typei = i; break; }
    }
    if (typei < 0) return err("Invalid type qname '$qname'", type.loc)

    // parse lib name / type name
    libName := qname[0..typei-2]
    typeName := qname[typei+1..-1]

    // resolve qualified type lib
    lib := depends[libName]
    if (lib == null) return err("Type lib '$libName' is not included in depends", type.loc)

    // resolve type in lib
    type.outside = lib.libType(typeName, false)
    if (type.outside == null) return err("Unresolved type '$qname' in lib", type.loc)
  }

  private Str:DataLib depends := [:]
}