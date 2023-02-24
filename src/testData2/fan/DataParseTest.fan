//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   24 Feb 2023  Brian Frank  Creation
//

using util
using data2

**
** DataParseTest
**
@Js
class DataParseTest : Test
{
  Void testBasics()
  {
    verifyParse(Str<|"hi"|>, "hi")
  }

  Void verifyParse(Str src, Obj? expected)
  {
echo
echo("---")
echo(src)
    actual := parse(src)
echo
echo(actual)
    verifyEq(actual, expected)
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  DataEnv env() { DataEnv.cur }

  Obj? parse(Str s) { env.parse(s) }
}