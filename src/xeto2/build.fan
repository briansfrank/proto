#! /usr/bin/env fan
//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   25 Jan 2023  Brian Frank  Creation
//

using build

**
** Build: xeto2
**
class Build : BuildPod
{
  new make()
  {
    podName = "xeto2"
    summary = "Xeto is eXtensible Explicitly Typed Objects"
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
               "data2 @{pog.depend}",
               ]
    srcDirs = [`fan/env/`,
               `fan/compiler/`,
               `fan/ast/`,
               `fan/impl/`,
               `fan/model/`,
               `fan/util/`,
               ]
  }
}