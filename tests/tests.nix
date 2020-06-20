{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { inherit system; }
}:

with import <nixpkgs/nixos/lib/testing-python.nix> { inherit system pkgs; };

let
  registry = import ./static_registry/default.nix;
  nginx_image = registry.nginx.nginx_7d0cdcc60a96;
in
{
  nginx = makeTest {
    machine = { ... }: {
      imports = [ ../default.nix ];

      virtualisation.cores = 4;
      virtualisation.memorySize = 1024;


      docker-networks.web = {
        usedBy = [ "nginx_alpha" "nginx_bravo" ];
      };
      docker-containers.nginx_alpha =
      {
        image = nginx_image.tag;
        imageFile = nginx_image.image;
        extraDockerOptions = [ "--network=web" ];
        ports = ["8181:80"];
        volumes = [
          "${./nginx.conf}:/etc/nginx/conf.d/default.conf:ro"
          "${./index.alpha.html}:/var/www/html/index.html:ro"
        ];
      };
      docker-containers.nginx_bravo =
      {
        image = nginx_image.tag;
        imageFile = nginx_image.image;
        extraDockerOptions = [ "--network=web" ];
        volumes = [
          "${./nginx.conf}:/etc/nginx/conf.d/default.conf:ro"
          "${./index.bravo.html}:/var/www/html/index.html:ro"
        ];
      };
    };

    testScript = ''
      machine.start()
      machine.wait_for_unit("docker-nginx_alpha.service")
      machine.wait_for_unit("docker-nginx_bravo.service")
      machine.wait_for_open_port(8181)
      machine.wait_until_succeeds("curl http://localhost:8181 | grep alpha")
      machine.wait_until_succeeds("curl http://localhost:8181/bravo | grep bravo")
    '';
  };
}
