//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   29 Jan 2023  Brian Frank  Creation
//

using util
using data

**
** Compiler type
**
@Js
abstract class CType
{
  ** File location
  abstract FileLoc loc()

  ** Simple name
  abstract Str name()

  ** Qualified name if known yet
  abstract Str? qname()

  ** Resolved reified type
  abstract DataType reified()
}

**************************************************************************
** RType
**************************************************************************

**
** Reified compiler type
**
class RType : CType
{
  new make(FileLoc loc, DataType reified)
  {
    this.loc = loc
    this.reified = reified
  }

  const override FileLoc loc

  override Str name() { reified.name }

  override Str? qname() { reified.name }

  const override DataType reified

}

**************************************************************************
** AType
**************************************************************************

**
** AST compiler type
**
class AType : CType
{
  new makeName(FileLoc loc, Str name)
  {
    this.loc = loc
    this.name = name
  }

  new makeQName(FileLoc loc, Str qname)
  {
    this.loc = loc
    this.name = qname[qname.indexr(".")+1..-1]
    this.qname = qname
  }

  const override FileLoc loc
  const override Str name
  override Str? qname
  override DataType reified() { throw Err() }
}