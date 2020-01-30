open EsyLib
open EsyInstall
let () =
	let digest = Digestv.empty in
	let sandbox = Obj.magic () in
	let project_path = Path.(currentPath () / "package.json") in
	let sandbox_spec = EsyInstall.SandboxSpec.ofPath project_path in
	let project_config = ProjectConfig.{
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
		solveCudfCommand = None;
	} in
	let lockPath = Path.(currentPath () / "esy.lock") in (* v "/Users/tcuthbertson/dev/ocaml/esy/esy.lock" in *)
	let solution = SolutionLock.ofPath
		~digest sandbox inPath
	|> RunAsync.runExn ?err:None |> Stdlib.Option.get
	in
	let outPath = Path.v "/tmp/esy.lock" in
	let () = SolutionLock.toPath
		~digest sandbox solution outPath
	|> RunAsync.runExn ?err:None
	in
	let () = print_endline "Done!" in
	()
