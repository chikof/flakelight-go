{
  description = "Go module for flakelight";
  inputs.flakelight.url = "github:nix-community/flakelight";
  outputs = {flakelight, ...}:
    flakelight ./. ({lib, ...}: {
      imports = [flakelight.flakelightModules.extendFlakelight];
      systems = lib.systems.flakeExposed;
      templates = import ./templates;
      nixDir = ./.;
      flakelightModule = {...}: {
        imports = [./flakelight-go.nix];
      };
    });
}
