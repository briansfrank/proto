//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Jul 2022  Brian Frank  Creation
//

using util
using proto

**
** AST library
**
internal class CLib
{
  new make(FileLoc loc, Path path, File dir, File[] src, CProto proto)
  {
    this.loc   = loc
    this.path  = path
    this.qname = path.toStr
    this.dir   = dir
    this.src   = src
    this.isSys = qname == "sys"
    this.proto = proto
  }

  const Path path     // library dotted name
  const Str qname     // dotted qualified name
  const FileLoc loc   // location of directory
  const File dir      // directory which contains lib.pog
  const File[] src    // pog files (first is always lib.pog)
  const Bool isSys    // is this the sys lib
  CProto? proto       // proto cloned from sys.Lib
  CLib[]? depends     // ResolveDepends

  Bool isLibMetaFile(File f) { f === src.first }
}

