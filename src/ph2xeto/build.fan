#! /usr/bin/env fan
//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   24 Aug 2022  Brian Frank  Creation
//

using build

**
** Build: ph2xeto
**
class Build : BuildPod
{
  new make()
  {
    podName = "ph2xeto"
    summary = "Project Haystack def to xeto converter"
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
               "haystack @{hx.depend}",
               "def @{hx.depend}",
               "defc @{hx.depend}"]
    srcDirs = [`fan/`]
  }
}