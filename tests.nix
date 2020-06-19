{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { inherit system; }
}:

with import <nixpkgs/nixos/lib/testing-python.nix> { inherit system pkgs; };

let
  registry = import ./static_registry/default.nix;
in
{
  mytest = makeTest {
    machine = { ... }: {
      imports = [ ./module.nix ];

      virtualisation.cores = 4;
      virtualisation.memorySize = 1024;

      foo.bar.enable = true;

      docker-containers.nginx = let
        image = registry.nginx.nginx_7d0cdcc60a96;
      in
      {
        image = image.tag;
        imageFile = image.image;
        ports = ["8181:80"];
      };
    };

    testScript = ''
      machine.start()
      machine.wait_for_unit("docker-nginx.service")
      machine.wait_for_open_port(8181)
      machine.wait_until_succeeds("curl http://localhost:8181")
    '';
  };
}
