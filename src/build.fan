#! /usr/bin/env fan
//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Feb 2022  Brian Frank  Creation
//

using build
using util

**
** Top-level build
**
class Build : BuildGroup
{
  new make()
  {
    childrenScripts =
    [
      `pog/build.fan`,
      `pogSpi/build.fan`,
      `pogc/build.fan`,
      `pogIO/build.fan`,
      `pogLint/build.fan`,
      `ph2pog/build.fan`,
      `pogStub/build.fan`,
      `testPog/build.fan`,
    ]
  }

//////////////////////////////////////////////////////////////////////////
// Superclean
//////////////////////////////////////////////////////////////////////////

  @Target { help = "Delete entire lib/ directory" }
  Void superclean()
  {
    Delete(this, Env.cur.workDir + `lib/`).run
  }

//////////////////////////////////////////////////////////////////////////
// Zip
//////////////////////////////////////////////////////////////////////////

  @Target { help = "Create dist zip file" }
  Void zip()
  {
    buildVersion := Version(config("buildVersion"))
    moniker := "pog-$buildVersion"

    // top level dirs to include
    env := (PathEnv)Env.cur
    if (env.path.size != 2) throw Err("Env must be fantom, proto")
    fanDir   := env.path[1]
    protoDir := env.path[0]
    topDirs := [
      // bin
      fanDir   + `bin/`,
      protoDir + `bin/`,
      // lib
      fanDir   + `lib/`,
      protoDir + `lib/`,
      // etc
      fanDir + `etc/build/`,
      fanDir + `etc/sys/`,
      // pog
      protoDir + `pog/`,
    ]

    // create zip-include dir
    includeDir := scriptDir + `../zip-include/`
    includeDir.delete

    // filter for zip task
    filter := |File f, Str path->Bool|
    {
      n := f.name

      // always recurse etc to get more fine grained matches
      if (f.name == "etc") return true

      // skip any files not in our topDir match
      topMatch := topDirs.any |topDir| { f.toStr.startsWith(topDir.toStr) }
      if (!topMatch) return false

      // skip hidden .* and .DS_Store files
      if (n.startsWith(".")) return false

      // fan bin
      if (f.parent.name == "bin")
      {
        if (!distBin(f.basename)) return false
      }

      // jar filter - strip swt jars
      if (f.ext == "jar")
      {
        return f.name == "sys.jar"
      }

      // pod filter
      if (f.ext == "pod")
      {
        if (!distPod(f.basename)) return false
      }

      if (f.isDir) log.info("  Adding dir [$f.osPath]")
      return true
    }

    // build path to zip up
    path := ((PathEnv)Env.cur).path.dup
    path.add(includeDir)

    // run it
    zip := CreateZip(this)
    {
      it.outFile    = scriptDir + `../${moniker}.zip`
      it.inDirs     = path
      it.pathPrefix = "$moniker/".toUri
      it.filter     = filter
    }
    zip.run

    // cleanup
    includeDir.delete
  }

  Bool distBin(Str name)
  {
    if (name == "fan") return true
    if (name == "fanlaunch") return true
    if (name == "protoc") return true
    return false
  }

  Bool distPod(Str name)
  {
    if (name.startsWith("test")) return false
    if (name.startsWith("doc")) return false
    if (name.startsWith("compiler")) return false
    if (name.startsWith("web")) return false
    if (name.startsWith("dom")) return false
    if (name.startsWith("flux")) return false
    if (name.startsWith("graphics")) return false
    if (name == "build") return false
    if (name == "fwt") return false
    if (name == "gfx") return false
    if (name == "email") return false
    if (name == "icons") return false
    if (name == "sql") return false
    if (name == "syntax") return false
    if (name == "wisp") return false
    if (name == "xml") return false
    return true
  }

}

