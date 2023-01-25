//
// Copyright (c) 2009, SkyFoundry LLC
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Sep 2009  Brian Frank  Creation
//

using haystackx

**
** Literal
**
@NoDoc
@Js
const class TypeExpr : Expr
{
  new make(Loc loc, Str name)
  {
    this.loc = loc
    this.name = name
  }

  override ExprType type() { ExprType.type }

  override const Loc loc

  const Str name

  override Obj? eval(AxonContext cx)
  {
    cx.findType(name)
  }

  override Void walk(|Str key, Obj? val| f)
  {
    f("name", name)
  }

  override Printer print(Printer out) { out.w(name) }
}


