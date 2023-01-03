#! /usr/bin/env fan
//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Dec 2022  Brian Frank  Creation
//

using build

**
** Build: pogTransduce
**
class Build : BuildPod
{
  new make()
  {
    podName = "pogTransduce"
    summary = "Proto object graph transducers"
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
               "pog @{pog.depend}",
               "pogEnv @{pog.depend}",
               "haystack @{hx.depend}"]
    srcDirs = [`fan/`]
    index = [
      "pog.transducer": [
        "pogTransduce::CompileTransducer",
        "pogTransduce::ExportTransducer",
        "pogTransduce::ImportTransducer",
        "pogTransduce::ParseTransducer",
        "pogTransduce::PrintTransducer",
        "pogTransduce::ReadTransducer",
        "pogTransduce::ReifyTransducer",
        "pogTransduce::ResolveTransducer",
        "pogTransduce::ValidateTransducer",
        "pogTransduce::WriteTransducer",
      ]
    ]
  }
}