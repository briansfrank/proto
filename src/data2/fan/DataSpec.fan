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

  ** Parent spec which contains this spec definition and scopes `name`.
  ** Returns null for a lib.
  abstract DataSpec? parent()

  ** Return simple name scoped by `parent`.  This method returns the
  ** empty string if parent is null (such as lib).
  abstract Str name()

  ** Return fully qualified name of this spec:
  **   - DataLib will return "foo.bar"
  **   - DataType will return "foo.bar::Baz"
  **   - DataType slots will return "foo.bar::Baz.qux"
  abstract Str qname()

  ** Type of this spec.   If this spec is a DataType itself then return self.
  abstract DataType type()

  ** Super type this specs inherits from.  If this spec is not a DataType
  ** itself, then this method returns `type`.  If this spec is a DataType,
  ** then return this type's supertype or null if 'sys::Obj' itself.
  abstract DataType? supertype()

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