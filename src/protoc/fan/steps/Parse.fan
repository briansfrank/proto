//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Jul 2022  Brian Frank  Creation
//

**
** Parse all source files into AST nodes
**
internal class Parse : Step
{
  override Void run()
  {
    compiler.root = CProto(Loc.synthetic, "")
    libs.each |lib| { parseLib(lib) }
    bombIfErr
  }

  private Void parseLib(CLib lib)
  {
    // build path of protos to lib itself
    parent := compiler.root
    lib.name.each |n|
    {
      x := parent.child(n)
      if (x == null) addSlot(parent, x = CProto(Loc.synthetic, n))
      parent = x
    }
    lib.src.each |file| { parseFile(parent, file) }
  }

  private Void parseFile(CProto parent, File file)
  {
    try
      Parser(this, file).parse(parent)
    catch (Err e)
      err("Cannot parse file", Loc(file), e)
  }
}