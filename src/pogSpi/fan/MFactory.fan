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
const class MFactory
{
  new make(MPogEnv env)
  {
    toPod := Str:Str[:]
    toFantom := Str:Str[:]
    initToFantom(env, toPod, toFantom)

    this.toPod            = toPod
    this.toFantom         = toFantom
    this.fromFantomProto  = initFromFantomProto(toFantom)
    this.fromFantomScalar = initFromFantomScalar
  }

  private static Void initToFantom(MPogEnv env, Str:Str toPod, Str:Str toFantom)
  {

    toFantom["sys.Lib"] = "pog::Lib"
    Env.cur.index("pog.types").each |str|
    {
      try
      {
        // parse "pog.types": "<pod>; <lib>; <names>"
        // parse: "pog.types": "pogLint; sys.lint; LintReport,LintPlan..."
        semi1 := str.index(";") ?: throw Err("Missing semicolon 1")
        semi2 := str.index(";", semi1+1) ?: throw Err("Missing semicolon 2")
        pod := str[0..<semi1].trim
        lib := str[semi1+1..<semi2].trim
        types := str[semi2+1..-1].split(',')

        // skip if lib not installed
        if (!env.isInstalled(lib)) return

        toPod[lib] = pod

        // parse type names to Fantom types
        types.each |type|
        {
          toFantom[lib + "." + type] = pod + "::" + type
        }
      }
      catch (Err e)
      {
        echo("ERROR: MFactory invalid pog.types: $str")
        e.trace
      }
    }
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

    acc["pogLint::LintLevel"]   = "sys.lint.LintLevel"

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

  ** Proto lib to Fantom pod name
  const Str:Str toPod

  ** Proto qname to Fantom type
  const Str:Str toFantom

  ** Fantom Proto subtype to Proto qname
  const Str:Str fromFantomProto

  ** Fantom scalar type to Proto qname
  const Str:Str fromFantomScalar

  ** Create Fantom instance for library proto
  Proto init(Str qname, Str type)
  {
    fantom := toFantom[qname] ?: toFantom[type]
    if (fantom != null) return Type.find(fantom).make
    return Proto()
  }

  ** Create Fantom instance for library proto
  Proto instantiate(Str type)
  {
    fantom := toFantom[type]
    if (fantom != null) return Type.find(fantom).make
    return Proto()
  }
}