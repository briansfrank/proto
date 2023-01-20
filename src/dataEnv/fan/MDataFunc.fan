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
** DataType implementation
**
@Js
internal const class MDataFunc : MDataType, DataFunc
{

  new make(MDataLib lib, Proto p, MDataType base)
    : super(lib, p, base)
  {
    returns = slot("return")
    params = slots.findAll |s| { s.name != "return" }
  }

  override MDataLib lib() { libRef }
  override const DataSlot returns
  const override DataSlot[] params

  override DataSlot? param(Str name, Bool checked := true)
  {
    if (name != "return")
    {
      slot := slot(name, false)
      if (slot != null) return slot
    }
    if (checked) throw UnknownParamErr("${qname}.${name}")
    return null
  }

  override DataObj call(DataDict args)
  {
echo(">>>> call $qname($args)")
    return env.emptyDict
  }

}