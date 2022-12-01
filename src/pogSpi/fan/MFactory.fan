//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   8 Aug 2022  Brian Frank  Creation
//

using pog

**
** MFactory maps proto qnames to/from their proper Fantom type
**
@Js
internal const class MFactory
{
  new make(MPogEnv env)
  {
    this.toFantom         = initToFantom(env)
    this.fromFantomProto  = initFromFantomProto(toFantom)
    this.fromFantomScalar = initFromFantomScalar
  }

  private static Str:Str initToFantom(MPogEnv env)
  {
    acc := Str:Str[:]
    acc["sys.Lib"]              = "pog::Lib"

    Env.cur.index("pog.types").each |str|
    {
      try
      {
        // parse: "pog.types": "acme.someib:Foo,Bar,Baz"
        colon := str.index(":") ?: throw Err("Missing colon")
        qname := str[0..<colon].trim

        // skip if lib not installed
        if (!env.isInstalled(qname)) return

        // parse type names to Fantom types
        pod := PogUtil.qnameToCamelCase(qname)
        types := str[colon+1..-1].split(',')
        types.each |type|
        {
          acc[qname + "." + type] = pod + "::" + type
        }
      }
      catch (Err e)
      {
        echo("ERROR: MFactory invalid pog.types: $str")
        e.trace
      }
    }

    return acc
  }

  private static Str:Str initFromFantomProto(Str:Str toFantom)
  {
    acc := Str:Str[:]
    toFantom.each |v, n| { acc[v] = n }
    return acc
  }

  private static Str:Str initFromFantomScalar()
  {
    acc := Str:Str[:]
    acc["sys::Str"]             = "sys.Str"
    acc["sys::Bool"]            = "sys.Bool"
    acc["sys::Int"]             = "sys.Int"
    acc["sys::Float"]           = "sys.Float"
    acc["sys::Duration"]        = "sys.Duration"
    acc["sys::Date"]            = "sys.Date"
    acc["sys::Time"]            = "sys.Time"
    acc["sys::DateTime"]        = "sys.DateTime"
    acc["sys::Version"]         = "sys.Version"

    acc["haystack::Marker"]     = "sys.Marker"
    acc["haystack::Number"]     = "sys.Number"
    acc["haystack::NA"]         = "ph.NA"
    acc["haystack::Remove"]     = "ph.Remove"
    acc["haystack::Ref"]        = "ph.Ref"
    acc["haystack::Coord"]      = "ph.Coord"
    acc["haystack::XStr"]       = "ph.XStr"
    acc["haystack::TagSymbol"]  = "ph.Symbol"
    acc["haystack::ConjunctSymbol"]  = "ph.Symbol"
    acc["haystack::KeySymbol"]  = "ph.Symbol"

    acc["graphics::Color"]      = "ion.ui.Color"
    acc["graphics::FontStyle"]  = "ion.ui.FontStyle"
    acc["graphics::FontWeight"] = "ion.ui.FontWeight"
    acc["graphics::Insets"]     = "ion.ui.Insets"
    acc["graphics::Point"]      = "ion.ui.Point"
    acc["graphics::Stroke"]     = "ion.ui.Stroke"

    acc["ionUi::Dim"]           = "ion.ui.Dim"

    return acc
  }

  ** Proto qname to Fantom type
  const Str:Str toFantom

  ** Fantom Proto subtype to Proto qname
  const Str:Str fromFantomProto

  ** Fantom scalar type to Proto qname
  const Str:Str fromFantomScalar
}