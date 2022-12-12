//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   25 Feb 2022  Brian Frank  Creation
//

using pog

**
** Misc API tests
**
class MiscTest : Test
{

//////////////////////////////////////////////////////////////////////////
// QName
//////////////////////////////////////////////////////////////////////////

  Void testQName()
  {
    verifyQName("", Str[,])
    verifyQName("a", ["a"])
    verifyQName("a.b", ["a", "b"])
    verifyQName("a.b.c", ["a", "b", "c"])
    verifyQName("a.b.c.d", ["a", "b", "c", "d"])
    verifyQName("a.b.c.d.e", ["a", "b", "c", "d", "e"])

    verifyQName("alpha", ["alpha"])
    verifyQName("alpha.beta", ["alpha", "beta"])
    verifyQName("alpha.beta.charlie", ["alpha", "beta", "charlie"])
    verifyQName("alpha.beta.charlie.delta", ["alpha", "beta", "charlie", "delta"])
    verifyQName("alpha.beta.charlie.delta.episolon", ["alpha", "beta", "charlie", "delta", "episolon"])

    // slice
    verifyEq(QName("a.b")[1..-1], QName("b"))
    verifyEq(QName("a.b")[0..-2], QName("a"))
    verifyEq(QName("a.b.c")[1..-1], QName("b.c"))
    verifyEq(QName("a.b.c")[0..-2], QName("a.b"))
    verifyEq(QName("a.b.c.d")[1..-1], QName("b.c.d"))
    verifyEq(QName("a.b.c.d")[0..-2], QName("a.b.c"))
    verifyEq(QName("a.b.c.d.e")[1..-1], QName("b.c.d.e"))
    verifyEq(QName("a.b.c.d.e")[0..-2], QName("a.b.c.d"))
    verifyEq(QName("a.b.c.d.e")[1..-2], QName("b.c.d"))
  }

  Void verifyQName(Str s, Str[] names)
  {
    x := QName(s)
    verifyEq(x.isRoot, names.isEmpty)
    if (x.isRoot) verifySame(QName.root, x)
    verifyEq(x.size, names.size)
    verifyEq(x.name, names.last ?: "")
    verifyEq(x.toStr, s)
    verifySame(x.toStr, x.toStr)
    names.each |n, i| { verifyEq(x[i], n) }
    verifyEq(x, QName(s))
    if (x.isRoot || names.size == 1)
    {
      verifySame(x.parent, QName.root)
    }
    else
    {
      verifyEq(x.parent, QName(names[0..-2]))
    }
    verifyEq(x.add("foo").toStr, x.isRoot ? "foo" : "${s}.foo")
  }
}

