//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   7 Aug 2022  Brian Frank  Creation
//

using util
using pog

**
** Find pods which match the lib names
**
internal class FindPods : Step
{
  override Void run()
  {
    info("FindPods")
    path := ((PathEnv)Env.cur).path
    acc := PodSrc[,]
    graph.libs.each |lib|
    {
      acc.addNotNull(findPod(path, lib))
    }
    compiler.pods = acc
  }

  PodSrc? findPod(File[] path, Lib lib)
  {
    // lookup pod name from lib qname
    podName := env.factory.toPod[lib.qname]
    if (podName == null) return null

    // search for source directory
    dir := findPodSrc(path, podName)
    if (dir == null) return null

    info("  $lib.qname [$dir.osPath]")

    return PodSrc(lib, podName, dir)
  }

  File? findPodSrc(File[] path, Str podName)
  {
    path.eachWhile |f| { findPodSrcIn(f+`src/`, podName) }
  }

  File? findPodSrcIn(File dir, Str podName)
  {
    dir.list.eachWhile |x|
    {
      if (!x.isDir) return null

      if (x.name == podName && x.plus(`build.fan`).exists)
        return x

      return findPodSrcIn(x, podName)
    }
  }
}

