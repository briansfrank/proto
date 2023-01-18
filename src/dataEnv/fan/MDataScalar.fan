//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util
using data
using pog

**
** DataObj implementation for scalars
**
@Js
internal final const class MDataScalar : DataObj
{
  new make(DataType type, Obj val)
  {
    this.type = type
    this.val  = val
  }

  const override DataType type

  const override Obj val

  override Int hash() { val.hash }

  override Bool equals(Obj? x)
  {
    that := x as MDataScalar
    return that != null && that.type === this.type && that.val == this.val
  }

  override Str toStr() { val.toStr }
}

