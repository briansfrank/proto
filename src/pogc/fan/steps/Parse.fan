//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Jul 2022  Brian Frank  Creation
//

using util

**
** Parse all source files into AST nodes
**
internal class Parse : Step
{
  override Void run()
  {
    libs.each |lib| { parseLib(lib) }
    bombIfErr
  }

  private Void parseLib(CLib lib)
  {
    lib.src.each |file| { parseFile(lib, file, lib.isLibMetaFile(file)) }
  }

  private Void parseFile(CLib lib, File file, Bool isLibMetaFile)
  {
    try
      Parser(this, file).parse(lib, isLibMetaFile)
    catch (CompilerErr e)
      throw e
    catch (Err e)
      err("Cannot parse file", FileLoc(file), e)
  }
}