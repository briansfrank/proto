#! /usr/bin/env fan
//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Jan 2023  Brian Frank  Creation
//

using build

**
** Build: dataHaystack
**
class Build : BuildPod
{
  new make()
  {
    podName = "dataHaystack"
    summary = "Haystack support for data processing APIs"
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
               "data @{pog.depend}",
               "dataEnv @{pog.depend}",
               "haystack @{hx.depend}",
               ]
    srcDirs = [`fan/`]
  }
}