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
@Js
internal class Parse : Step
{
  override Void run()
  {
    // get input dir/file
    input := compiler.input
    if (input == null) throw err("Compiler input not configured", FileLoc.inputs)
    if (!input.exists) throw err("Input file not found: $input", FileLoc.inputs)

    // parse into root object
    root := AObj(FileLoc(input))
    if (input.isDir)
    {
      input.list.each |f|
      {
        if (f.ext == "xeto") parseFile(root.slots, f)
      }
    }
    else
    {
      parseFile(root.slots, input)
    }

    pragma := root.slots.remove("pragma")
    if (isLib && pragma != null) root.spec.meta = pragma.spec.meta

    bombIfErr

    // root is library, and its children are types
    root.isLib = true
    root.slots.each |kid|
    {
      if (kid.name[0].isUpper) kid.isType = true
    }

    compiler.ast = root
    compiler.pragma = pragma
  }

  private Void parseFile(AMap root, File file)
  {
    loc := FileLoc(file)
    try
    {
      Parser(compiler, loc, file.in).parse(root)
    }
    catch (FileLocErr e)
    {
      err(e.msg, e.loc)
    }
    catch (Err e)
    {
      err(e.toStr, loc, e)
    }
  }
}