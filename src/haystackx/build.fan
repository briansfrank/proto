#! /usr/bin/env fan
//
// Copyright (c) 2008, SkyFoundry LLC
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Dec 08  Brian Frank  Creation
//    2 Oct 12  Brian Frank  Rename folio -> haystack
//

using build

**
** Build: haystackx
**
class Build : BuildPod
{
  new make()
  {
    podName = "haystackx"
    summary = "Haystack model and client API"
    meta    = ["org.name":     "SkyFoundry",
               "org.uri":      "https://skyfoundry.com/",
               "proj.name":    "Haxall",
               "proj.uri":     "https://haxall.io/",
               "license.name": "Academic Free License 3.0",
               "vcs.name":     "Git",
               "vcs.uri":      "https://github.com/haxall/haxall",
               "hx.docFantom": "true",
               ]
    depends = ["sys @{fan.depend}",
               "concurrent @{fan.depend}",
               "util @{fan.depend}",
               "inet @{fan.depend}",
               "web @{fan.depend}",
               "data @{pog.depend}"]
    srcDirs = [`fan/`]
    resDirs = [`res/`, `locale/`]
  }
}