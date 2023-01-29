//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   25 Jan 2023  Brian Frank  Creation
//

using data
using dataLint
using axonx

**
** Experimental functions to eventually push back into core
**
const class XFuncs
{
  ** Return the data type of the given value.  Raise exception
  ** if value type is not mapped into the data type system.
  **
  ** Examples:
  **    typeof("hi")  >>  sys.Str
  **    typeof(@id)   >>  sys.Ref
  **    typeof({})    >>  sys.Dict
  @Axon static DataType? _typeof(Obj? val, Bool checked := true)
  {
    cx := AxonContext.curAxon
    return cx.data.typeOf(val, checked)
  }

  ** Return if value is an instance of the given type.  This
  ** function tests the type based on nominal typing via explicit
  ** inheritance.  If val is itself a type, then we test that
  ** it explicitly inherits from type.  Raise exception if value is
  ** not mapped into the data type sytem.
  **
  ** Note that dict values will only match the generic 'sys.Dict'
  ** type.  Use `fits()` for structural type matching.
  **
  ** Examples:
  **   isa("hi", Str)     >>  true
  **   isa("hi", Dict)    >>  false
  **   isa({}, Dict)      >>  true
  **   isa(Meter, Equip)  >>  true
  @Axon static Bool isa(Obj? val, DataType type)
  {
    if (val is DataType) return ((DataType)(val)).isa(type)
    cx := AxonContext.curAxon
    return cx.data.typeOf(val).isa(type)
  }

  ** Return if the given value fits the type.  This function tests
  ** the type based on either nominally or structural typing.  Also
  ** see `isa()` that tests strictly by nominal typing.
  **
  ** Examples:
  **    fits("foo", Str)    >>  true
  **    fits(123, Str)      >>  false
  @Axon static Bool fits(Obj? val, DataType type)
  {
    cx := AxonContext.curAxon
    return Linter(cx).fits(val, type)
  }
}