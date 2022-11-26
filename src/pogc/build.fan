#! /usr/bin/env fan
//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Feb 2022  Brian Frank  Creation
//

using build

**
** Build: pogc
**
class Build : BuildPod
{
  new make()
  {
    podName = "pogc"
    summary = "Proto object graph data type system compiler"
    meta    = ["org.name":     "SkyFoundry",
               "org.uri":      "https://skyfoundry.com/",
               "proj.name":    "Haxall",
               "proj.uri":     "https://haxall.io/",
               "license.name": "Academic Free License 3.0",
               "vcs.name":     "Git",
               "vcs.uri":      "https://github.com//briansfrank/proto"]
    depends = ["sys @{fan.depend}",
               "concurrent @{fan.depend}",
               "util @{fan.depend}",
               "pog @{pog.depend}"]
    srcDirs = [`fan/`,
               `fan/ast/`,
               `fan/impl/`,
               `fan/parser/`,
               `fan/steps/`]
  }
}