{ config, lib, ... }:

with lib;

let
  cfg = config.foo.bar;

in

{
  options.foo.bar = {
    enable = mkEnableOption "foobar";
  };

  config = mkIf cfg.enable {
    # ...
  };
}
