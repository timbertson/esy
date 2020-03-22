open EsyLib
open EsyInstall
open EsyProject


let getSandboxSolution solvespec proj =
	let dumpCudfInput=None in
	let dumpCudfOutput=None in
	let open EsySolve in
	let open RunAsync.Syntax in
  let%bind solution =
    Solver.solve
      ?dumpCudfInput
      ?dumpCudfOutput
      solvespec
      proj.Project.solveSandbox
	in
  (* let lockPath = SandboxSpec.solutionLockPath(proj.solveSandbox.Sandbox.spec) in *)
  (* let%bind () = { *)
  (*   let%bind digest = Sandbox.digest(solvespec, proj.solveSandbox) in *)
  (*  *)
  (*   EsyInstall.SolutionLock.toPath( *)
  (*     ~digest, *)
  (*     proj.installSandbox, *)
  (*     solution, *)
  (*     lockPath, *)
  (*   ) *)
  (* } in *)

  return(solution)

let () =
	Logs.set_level (Some Logs.Debug);
	Logs.set_reporter (Logs.format_reporter ());
	print_endline "making digest";
	flush stdout;
	let digest = Digestv.empty in
	let project_path = Path.(currentPath () / "package.json") in
	print_endline "loading sandbox spec";
	let sandbox_spec = EsyInstall.SandboxSpec.ofPath project_path
		|> RunAsync.runExn ?err:None in
	print_endline "making project config";
	let projectConfig = ProjectConfig.{
		mainprg = "false"; (* `esy` I guess? *)
		path = project_path; (* could be esy too? *)
		esyVersion = "TODO";
		spec = sandbox_spec;
		prefixPath = None;
		cacheTarballsPath = None;
		opamRepository = None;
		esyOpamOverride = None;
		npmRegistry = None;
		solveTimeout = None;
		skipRepositoryUpdate = true;
		solveCudfCommand = Some (Cmd.v "esy-solve-cudf-not-installed");
	} in
	print_endline "loading project";
	let (project, _fileInfos) = Project.make projectConfig
		|> RunAsync.runExn ?err:None in
	(* let fetched = Project.fetched project *)
	(* 	|> RunAsync.runExn ?err:None in *)

	let lockPath = SandboxSpec.solutionLockPath project.solveSandbox.spec in


	(* let lockPath = Path.(currentPath () / "esy.lock") in (* v "/Users/tcuthbertson/dev/ocaml/esy/esy.lock" in *) *)
	(* let sandbox = project.installSandbox in *)
	Logs.info(fun m->m "loading lock from %s" (Path.show lockPath));
	let solution = SolutionLock.ofPath
		~digest project.installSandbox lockPath
	|> RunAsync.runExn ?err:None
	in

	Logs.info(fun m->m "solving ...");
	let solution = match solution with
		| Some s -> s
		| None -> getSandboxSolution project.workflow.solvespec project
			|> RunAsync.runExn ?err:None
	in

	Logs.info(fun m->m "configuring ...");
	let _configured = Project.configured project
		|> RunAsync.runExn ?err:None
	in

	let outPath = Path.v "/tmp/esy.lock" in
	print_endline "writing lock";
	(* NOTE: solutionLock.toPath (writeOverride) assumes it's writing to the sandbox lock path, which is presumably a bug.
	 * We need to make a fresh sandbox with the dest path we want *)
	let () = SolutionLock.toPath
		~digest project.installSandbox solution outPath
	|> RunAsync.runExn ?err:None
	in
	let () = print_endline "Done!" in
	ignore (digest, project_path, sandbox_spec, projectConfig );
	()
