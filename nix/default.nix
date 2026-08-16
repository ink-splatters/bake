top @ {lib, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    inherit (top.config) name src;
    pyproject = builtins.fromTOML (builtins.readFile "${src}/pyproject.toml");

    meta = {
      description = "Mbake is a Makefile formatter and linter. It only took 50 years";
      homepage = "https://github.com/EbodShojaei/bake";
      changelog = "https://github.com/EbodShojaei/bake/blob/${src.rev}/CHANGELOG.md";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [];
      mainProgram = "bake";
    };
  in {
    packages.bake = with pkgs.python3.pkgs;
      buildPythonApplication {
        inherit name src;
        inherit (pyproject.project) version;

        pyproject = true;

        build-system = [
          hatchling
        ];

        dependencies = [
          rich
          tomli
          typer
        ];

        nativeCheckInputs = [
          black
          mypy
          pytest
          pytest-cov
          ruff
          tomli
        ];

        pythonImportsCheck = [
          "${name}"
        ];

        doCheck = true;

        checkPhase = ''
          make lint
        '';
        inherit meta;
      };
    apps.bake = {
      type = "app";
      program = "${config.packages.bake}/bin/mbake";
      inherit meta;
    };
  };
}
