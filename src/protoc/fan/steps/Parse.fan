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
    libProto := compiler.root
    lib.name.each |n|
    {
      x := libProto.child(n)
      if (x == null) addSlot(libProto, x = CProto(Loc.synthetic, n))
      libProto = x
    }

    lib.proto = libProto
    lib.proto.isLib = true
    lib.src.each |file| { parseFile(libProto, file) }
  }

  private Void parseFile(CProto libProto, File file)
  {
    try
      Parser(this, file).parse(libProto)
    catch (Err e)
      err("Cannot parse file", Loc(file), e)
  }
}