//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util

**
** Data specification.  DataSpec implements the DataDict mixin
** which models the effective meta-data (including from inherited
** types).  Use the `own` method to get only the declared meta-data.
**
@Js
const mixin DataSpec : DataDict
{

  ** Environment for spec
  abstract DataEnv env()

  ** Type of this spec.   If this spec is a DataType itself then return self.
  abstract DataType type()

  ** Get my own declared meta-data
  abstract DataDict own()

  ** Get the declared children slots
  abstract DataSlots slotsOwn()

  ** Get the effective children slots including inherited
  abstract DataSlots slots()

  ** Convenience for 'slots.get'
  abstract DataSpec? slot(Str name, Bool checked := true)

  ** Convenience for 'slotsOwn.get'
  abstract DataSpec? slotOwn(Str name, Bool checked := true)

  ** Scalar value or null
  abstract Obj? val()

  ** Return if this specs inherits from that from a nominal type perspective.
  abstract Bool isa(DataSpec that)

  ** File location of definition or unknown
  @NoDoc abstract FileLoc loc()

}