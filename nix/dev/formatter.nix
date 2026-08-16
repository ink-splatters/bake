{
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    formatter = pkgs.writeShellApplication {
      name = "formatter";
      runtimeInputs = with pkgs; [alejandra config.packages.bake python3.pkgs.black taplo fd];
      text = ''
        echo running alejandra...
        alejandra .

        echo running bake...
        mbake format Makefile

        echo running black
        black .

        echo running taplo...
        fd -u \.toml\$ -x taplo fmt
      '';
    };
  };
}
