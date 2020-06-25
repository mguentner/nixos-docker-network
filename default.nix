{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.docker-networks;

  dockerNetwork = { ... }: {
    options = {
      usedBy = mkOption {
        type = with types; listOf str;
        default = [];
      };
    };
  };

  mkService = name: network: let
    mkBefore = map (x: "docker-${x}.service") network.usedBy;
  in rec {
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" "docker.socket" ];
    before = mkBefore;
    requires = after;

    serviceConfig = {
      ExecStart = pkgs.writeScript "docker-network-create-${name}" ''
        #!${pkgs.runtimeShell} -e
        set -x
        if [[ -z "$(${pkgs.docker}/bin/docker network ls | grep ${name} | tr -d '\n')" ]]; then
           ${pkgs.docker}/bin/docker network create ${name}
        fi
      '';
      ExecStop = ''
        ${pkgs.docker}/bin/docker network rm ${name}
      '';
      RemainAfterExit="true";
      Type="oneshot";
    };
  };
in
{
  options.docker-networks = mkOption {
    default = {};
    type = types.attrsOf (types.submodule dockerNetwork);
    description = "docker networks";
  };

  config = mkIf (cfg != {}) {
    systemd.services = mapAttrs' (n: v: nameValuePair "docker-network-${n}" (mkService n v)) cfg;
  };
}
