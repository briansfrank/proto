//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   21 Dec 2022  Brian Frank  Creation
//   27 Jan 2023  Brian Frank  Redesign from proto
//

using util
using data

**
** Infer unspecified types from inheritance and values
**
@Js
internal class Infer : Step
{
  override Void run()
  {
    if (!isLib) return
    ast.each |type| { inheritType(type) }
    bombIfErr
  }

  private Void inheritType(XetoObj type)
  {
    type.slots.each |slot| { inheritSlot(slot) }
  }

  private Void inheritSlot(XetoObj slot)
  {
    if (slot.type == null)
    {
      // TODO: for now infer from value
      if (slot.val != null)
        slot.type = XetoType(slot.loc, "Str")
      else
        slot.type = XetoType(slot.loc, "Obj")
    }
  }
}