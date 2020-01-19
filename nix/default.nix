{ stdenv, pkgs, fetchFromGitHub, ocaml-ng, opam2nix, self}:
let
	args = {
		inherit (pkgs.ocaml-ng.ocamlPackages_4_08) ocaml;
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
			});
		};
	};
	opam-selection = opam2nix.build args;
	resolve = opam2nix.resolve args [ ../esy.opam ];
in
{
	inherit (opam-selection) esy;
	inherit resolve;
	selection = opam-selection;
}
