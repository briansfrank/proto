//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   25 Feb 2022  Brian Frank  Creation
//

using pog
using pogc

**
** Misc API tests
**
class MiscTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Path
//////////////////////////////////////////////////////////////////////////

  Void testPath()
  {
    verifyPath("", Str[,])
    verifyPath("a", ["a"])
    verifyPath("a.b", ["a", "b"])
    verifyPath("a.b.c", ["a", "b", "c"])
    verifyPath("a.b.c.d", ["a", "b", "c", "d"])
    verifyPath("a.b.c.d.e", ["a", "b", "c", "d", "e"])

    verifyPath("alpha", ["alpha"])
    verifyPath("alpha.beta", ["alpha", "beta"])
    verifyPath("alpha.beta.charlie", ["alpha", "beta", "charlie"])
    verifyPath("alpha.beta.charlie.delta", ["alpha", "beta", "charlie", "delta"])
    verifyPath("alpha.beta.charlie.delta.episolon", ["alpha", "beta", "charlie", "delta", "episolon"])
  }

  Void verifyPath(Str s, Str[] names)
  {
    p := Path(s)
    verifyEq(p.isRoot, names.isEmpty)
    if (p.isRoot) verifySame(Path.root, p)
    verifyEq(p.size, names.size)
    verifyEq(p.name, names.last ?: "")
    verifyEq(p.toStr, s)
    verifySame(p.toStr, p.toStr)
    names.each |n, i| { verifyEq(p[i], n) }
    verifyEq(p, Path(s))
    verifyEq(p.add("foo").toStr, p.isRoot ? "foo" : "${s}.foo")
  }
}

