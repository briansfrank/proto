//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Mar 2023  Brian Frank  Creation
//

using util

**
** AST DataType
**
@Js
internal class AType : ASpec
{
  ** Constructor
  new make(FileLoc loc, ALib lib, Str name)
    : super(loc, name, XetoType())
  {
    this.lib   = lib
    this.qname = lib.qname + "::" + name
    this.name  = name
  }

  ** Node type
  override ANodeType nodeType() { ANodeType.type }

  ** Assembled DataType reference
  override XetoType asm() { super.asm }

  ** Construct slot spec
  override AObj makeChild(FileLoc loc, Str name) { ASpec(loc, name) }

  ** Parent library
  ALib lib

  ** Qualified name "foo.bar::Baz"
  const Str qname

  ** We use AObj.type to model the supertype type
  ARef? supertype() { type }

  ** Value type is myself
  override Str valParseType() { qname }
}