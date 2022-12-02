//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   7 Aug 2022  Brian Frank  Creation
//

using pog

**
** PodSrc models the source directory of a pod matched to a pog Lib
**
internal class PodSrc
{
  new make(Lib lib, Str podName, File dir)
  {
    this.lib     = lib
    this.podName = podName
    this.dir     = dir
  }

  const Lib lib                  // Proto lib for the pod
  const Str podName              // Fantom pod name
  const File dir                 // directory which contains build.fan, fan, etc
  TypeSrc[]? types               // FindTypes
  [File:TypeSrc[]]? typesByFile  // FindTypes

  once TypeSrc[] concrete() { types.findAll { !it.isAbstract }.ro }

  override Str toStr() { lib.qname }
}


