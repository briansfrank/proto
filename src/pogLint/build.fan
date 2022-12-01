#! /usr/bin/env fan
//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   1 Dec 2022  Brian Frank  Creation
//

using build

**
** Build: pogLint
**
class Build : BuildPod
{
  new make()
  {
    podName = "pogLint"
    summary = "Proto object graph validation engine"
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
    srcDirs = [`fan/`]
    index = ["pog.types": "pogLint; sys.lint; LintReport,LintItem,LintPlan,LintRule"]
  }
}