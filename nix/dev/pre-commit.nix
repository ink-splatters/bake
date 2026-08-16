{
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.packages) bake;
  in {
    pre-commit = {
      check.enable = true;

      settings = {
        configPath = ".pre-commit-config-nix.yaml";
        hooks = {
          # TOML/Cargo files
          check-toml.enable = true;

          # Markdown
          markdownlint = {
            enable = true;
            settings.configuration = {
              MD013 = false; # Disable line length
              MD033 = false; # Allow inline HTML
              MD040 = false; # Don't require language for code blocks
              # MD041 = false; # First line doesn't need to be a heading
            };
          };

          # Python tools
          black.enable = true;
          mypy = {
            enable = true;
            excludes = ["^tests/"];
            extraPackages = with pkgs.python3.pkgs; [
              # Runtime dependencies
              typer
              rich
              tomli
              # Dev dependencies for type checking
              pytest
              pytest-cov
            ];
          };
          ruff.enable = true;

          # Spell checking - only check markdown files
          typos = {
            enable = true;
            files = "\\.md$";
            excludes = ["^tests/"];
          };

          # Nix hooks
          deadnix.enable = true;
          nil.enable = true;
          alejandra.enable = true;
          statix.enable = true;

          # Makefile validation and formatting
          mbake-validate = {
            enable = true;
            name = "mbake validate";
            description = "Run 'mbake validate' for Makefile validation";
            entry = "mbake validate";
            types = ["makefile"];
            excludes = ["^tests/"];
            require_serial = true;
            pass_filenames = true;
            extraPackages = [bake];
          };

          mbake-format = {
            enable = true;
            name = "mbake format";
            description = "Run 'mbake format' for Makefile formatting";
            entry = "mbake format";
            types = ["makefile"];
            excludes = ["^tests/"];
            require_serial = true;
            pass_filenames = true;
            extraPackages = [bake];
          };
        };

        excludes = ["^\.direnv/" "^\.venv/" "^venv/" "^__pycache__/"];
      };
    };

    apps.install-hooks = {
      type = "app";
      program = toString (pkgs.writeShellScript "install-hooks" ''
        ${config.pre-commit.installationScript}
        echo "Pre-commit hooks installed!"
      '');
      meta.description = "install pre-commit hooks";
    };
  };
}
