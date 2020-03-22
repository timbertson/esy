{ stdenv, pkgs, fetchFromGitHub, ocaml-ng, opam2nix, self}:
let
	ocamlPackages = pkgs.ocaml-ng.ocamlPackages_4_08;
	args = {
		inherit (ocamlPackages) ocaml;
		selection = ./opam-selection.nix;
		src = {
			esy = self;
		};
		override = {}: {
			cmdliner = super: super.overrideAttrs (attrs: {
				src = fetchFromGitHub {
						owner = "esy-ocaml";
						repo = "cmdliner";
						rev = "e9316bc34e4781ffdd51ffe6f2de7c59b36c741e";
						sha256 = "0dly2gskcfh2cari5s87bfqahkf8jsxrzp2wb0madl3v9dgmil3b";
					};
					# opam2nix = 
			});
		};
	};
	opam-selection = opam2nix.build args;
	resolve = opam2nix.resolve args [ ../esy.opam "utop" ../opam2nix/opam2nix.opam ];
in
{
	inherit (opam-selection) esy;
	inherit resolve;
	selection = opam-selection;
	shell = opam-selection.esy.overrideAttrs (o: {
		buildInputs = (o.buildInputs or []) ++ [
			opam-selection.utop
			pkgs.nghttp2.lib # required for ocurl, transitively. I think it's hidden behing pkgconfig, not directly obvious
		] ++ (opam-selection.opam2nix.drvAttrs.propagatedBuildInputs);
	});
}
