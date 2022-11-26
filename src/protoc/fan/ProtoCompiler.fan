//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using util
using proto

**
** Proto compiler
**
class ProtoCompiler
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  ** It-block constructor
  new make(|This| f) { f(this) }

//////////////////////////////////////////////////////////////////////////
// Inputs
//////////////////////////////////////////////////////////////////////////

  ** Install environment
  const ProtoEnv env := ProtoEnv.cur

  ** Library names to compile
  const Str[] libNames

  ** Output directory for compiler/documentation results
  const File? outDir

  ** Info, warning, and error logging
  Logger logger := Logger.makeOutStream

//////////////////////////////////////////////////////////////////////////
// Pipelines
//////////////////////////////////////////////////////////////////////////

  ** Compile input libs to a Graph
  Graph compileGraph()
  {
    run(frontend).graph
  }

  ** Compile list of output files for command line main
  Graph compileMain(Str[] outputs)
  {
    steps := frontend.dup
    outputs.each |o|
    {
      switch (o)
      {
        case "json": steps.add(GenJson())
        default: throw err("Unknown output format: $o", FileLoc.inputs)
      }
    }
    return run(steps).graph
  }

  ** List of front end steps to compile to the Graph
  private Step[] frontend()
  {
    return [
      InitLibs(),
      Parse(),
      ResolveSys(),
      ResolveDepends(),
      ExpandNested(),
      ResolveNames(),
      AddMeta(),
      Inherit(),
      Assemble(),
    ]
  }

  ** Run the pipeline with the given steps
  internal This run(Step[] steps)
  {
    try
    {
      t1 := Duration.now
      steps.each |step|
      {
        step.compiler = this
        step.run
      }
      t2 := Duration.now
      duration = t2 - t1
      info("ok [$graph.libs.size libs, $duration.toLocale]")
      return this
    }
    catch (CompilerErr e)
    {
      throw e
    }
    catch (Err e)
    {
      throw err("Internal compiler error", FileLoc.unknown, e)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  ** Log info message
  Void info(Str msg)
  {
    logger.info(msg)
  }

  ** Log warning message
  Void warn(Str msg, FileLoc loc, Err? cause := null)
  {
    logger.warn(msg, loc, cause)
  }

  ** Log err message
  CompilerErr err(Str msg, FileLoc loc, Err? cause := null)
  {
    err := CompilerErr(msg, loc, cause)
    errs.add(err)
    logger.err(msg, loc, cause)
    return err
  }

  ** Log err message with two locations of duplicate identifiers
  CompilerErr err2(Str msg, FileLoc loc1, FileLoc loc2, Err? cause := null)
  {
    err := CompilerErr(msg, loc1, cause)
    errs.add(err)
    logger.err("$msg [$loc2]", loc1, cause)
    return err
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  CompilerErr[] errs := [,]              // err
  internal Duration? duration            // run
  internal CLib[]? libs                  // InitLibs
  internal CProto? root                  // Parse
  internal CSys? sys                     // ResolveSys
  internal MGraph? graph                 // Assemble
}


