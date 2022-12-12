//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Dec 2022  Brian Frank  Creation
//

using pog

**
** LintEngine runs the line pipeline against a
** graph and returns the resulting report
**
@Js
internal class LintEngine : LintContext
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  ** Implementation of Graph.lint
  static PogLint lint(Graph graph, LintPlan? plan)
  {
    make(graph).run
  }

  private new make(Graph graph)
  {
    this.graph = graph
    this.proto = graph
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  PogLint run()
  {
    initRules
    runOn(graph)
    return toResult
  }

  private Void initRules()
  {
    // TODO just find all the classes in this pod for now
    acc := LintRule[,]
    typeof.pod.types.each |t|
    {
      if (!t.isAbstract && t.fits(LintRule#))
        acc.add(t.make)
    }
    this.rules = acc
  }

  private Void runOn(Proto p)
  {
    // run all the rules on this proto
    this.proto = p
    rules.each |rule| { runRule(rule) }

    // run on kids
    p.eachOwn |kid| { runOn(kid) }
  }

  private Void runRule(LintRule rule)
  {
    try
      rule.lint(this)
    catch (Err e)
      echo("LintRule failed $rule\n$e.traceToStr")
  }

  private MPogLint toResult()
  {
    MPogLint {
      it.graph = this.graph
      it.isOk  = this.numErrs == 0
      it.isErr = this.numErrs != 0
      it.items = this.items
    }
  }

//////////////////////////////////////////////////////////////////////////
// Logging
//////////////////////////////////////////////////////////////////////////

  override Void err(Str msg)
  {
    log(LintLevel.err, msg)
  }

  override Void warn(Str msg)
  {
    log(LintLevel.warn, msg)
  }

  override Void info(Str msg)
  {
    log(LintLevel.info, msg)
  }

  private Void log(LintLevel level, Str msg)
  {
    items.add(MLintItem(proto, level, msg))
    if (level === LintLevel.err) numErrs++
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  const override Graph graph      // make
  override Proto proto            // make/runOn
  LintRule[]? rules               // initRules
  MLintItem[] items := [,]        // log
  Int numErrs                     // log
}

**************************************************************************
** MLintItem
**************************************************************************

@Js
internal const class MLintItem
{
  new make(Proto target, LintLevel level, Str msg)
  {
    this.target = target
    this.level  = level
    this.msg    = msg
  }

  const Proto target
  const LintLevel level
  const Str msg
}


**************************************************************************
** MPogLint
**************************************************************************

@Js
internal const class MPogLint : PogLint
{
  new make(|This| f) { f(this) }

  const override Graph graph
  const override Bool isOk
  const override Bool isErr
  const MLintItem[] items

  override once LintReport report()
  {
    // lazily build report
    // TODO: need to really beef up Fantom ease of use APIs
    newGraph := graph.env.create(["sys", "sys.lint"]).update |u|
    {
      reportType := u.graph.sys->lint->LintReport
      itemsType  := u.graph.sys->lint->LintReport->items
      itemType   := u.graph.sys->lint->LintItem

      reportStub := u.clone(reportType)
      graph.set("lintReport", reportStub)

      itemsStub := u.clone(itemsType)
      reportStub.set("items", itemsStub)


      items.each |item|
      {
        itemStub := u.clone(itemType)
        itemStub.set("target", item.target.qname.toStr)
        itemStub.set("level",  item.level.name)
        itemStub.set("msg",    item.msg)
        itemsStub.add(itemStub)
      }
    }
    return newGraph->lintReport
  }
}