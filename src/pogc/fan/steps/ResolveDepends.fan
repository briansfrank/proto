//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Jul 2022  Brian Frank  Creation
//

using pog

**
** ResolveDepends resolves each lib's dependencies
**
internal class ResolveDepends : Step
{
  override Void run()
  {
    libs.each |lib| { resolveLib(lib) }
    bombIfErr
  }

  Void resolveLib(CLib lib)
  {
    // sys has no depends
    if (lib.isSys)
    {
      lib.depends = CLib[,]
      return
    }

    // get depends meta tag from lib, if
    // if unspecified then default depends to just sys
    depends := lib.proto.getOwn("_depends", false)
    if (depends == null)
    {
      lib.depends = CLib[libs.find { it.isSys }]
      return
    }

    // resolve the list of Depend objects
    hasSys := false
    acc := Str:CLib[:]
    depends.eachOwn |depend|
    {
      // get Depend.lib string
      dependName := depend.getOwn("lib", false)?.val
      if (dependName == null) return err("Depend missing lib name", depend.loc)

      // check dup depends
      if (acc[dependName] != null) return err("Duplicate depend: $dependName", depend.loc)

      // resolve depend
      dependLib := libs.find { it.qname == dependName }
      if (dependLib == null) return err("Depend not found: $dependName", depend.loc)

      // add to our list of depends
      acc.add(dependName, dependLib)
    }

    // make sure we have "sys" as a depend
    if (!acc.containsKey("sys")) err("Must declare 'sys' as a dependency", depends.loc)
    lib.depends = acc.vals.sort |a, b| { a.qname <=> b.qname }
  }
}

