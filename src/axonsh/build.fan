#! /usr/bin/env fan
//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   24 Jan 2023  Brian Frank  Creation
//

using build

**
** Build: axonsh
**
class Build : BuildPod
{
  new make()
  {
    podName = "axonsh"
    summary = "Axon shell command line interface"
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
               "web @{fan.depend}",
               "data @{pog.depend}",
               "haystackx @{pog.depend}",
               "axonx @{pog.depend}"]
    srcDirs = [`fan/`]
  }
}