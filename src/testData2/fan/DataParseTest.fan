//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   24 Feb 2023  Brian Frank  Creation
//

using util
using data2
using haystack

**
** DataParseTest
**
@Js
class DataParseTest : HaystackTest
{
  Void testBasics()
  {
    // system scalars
    verifyParse(Str<|"hi"|>, "hi")
    verifyParse(Str<|Bool "true"|>, true)
    verifyParse(Str<|Int "123"|>, 123)
    verifyParse(Str<|Float "123"|>, 123f)
    verifyParse(Str<|Duration "123sec"|>, 123sec)
    verifyParse(Str<|Number "123kW"|>, n(123, "kW"))
    verifyParse(Str<|Str "123"|>, "123")
    verifyParse(Str<|Date "2023-02-24"|>, Date("2023-02-24"))
    verifyParse(Str<|Time "02:30:00"|>, Time("02:30:00"))
    verifyParse(Str<|Ref "abc"|>, Ref("abc"))
    verifyParse(Str<|Version "1.2.3"|>, Version("1.2.3"))
    verifyParse(Str<|Uri "file.txt"|>, `file.txt`)
    verifyParse(Str<|DateTime "2023-02-24T10:51:47.21-05:00 New_York"|>, DateTime("2023-02-24T10:51:47.21-05:00 New_York"))
  }

  Void verifyParse(Str src, Obj? expected)
  {
    actual := parse(src)
    // echo("$actual [$actual.typeof]")
    verifyEq(actual, expected)
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  DataEnv env() { DataEnv.cur }

  Obj? parse(Str s) { env.parse(s) }
}