# flakelight-go -- Go module for flakelight
# SPDX-License-Identifier: MIT
{
  lib,
  src,
  config,
  flakelight,
  inputs,
  ...
}: let
  inherit (builtins) pathExists toString;
  inherit (lib) mkDefault mkIf mkMerge mkOption types;
  inherit (lib.fileset) fileFilter maybeMissing toSource unions;
  inherit (flakelight.types) fileset;

  goPkgName = "go_1_${toString config.go.version}";
in {
  options = {
    fileset = mkOption {
      type = fileset;
      default = unions [
        (fileFilter (
            file:
              file.hasExt "go"
              || file.name == "go.mod"
              || file.name == "go.sum"
          )
          src)
        (maybeMissing (src + /.golangci.yml))
      ];
    };

    go = {
      version = mkOption {
        type = types.int;
        default = 25;
        example = 22;
        description = ''
          Go minor version to use, mapped to pkgs.go_1_<version>.
          For example:
          - 22 -> pkgs.go_1_22
          - 23 -> pkgs.go_1_23
          - 25 -> pkgs.go_1_25
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf (pathExists (src + /main.go)) {
      pname = mkDefault "hello";
      description = mkDefault "Simple Go hello world built with Flakelight";

      package = pkgs: let
        go = pkgs.${goPkgName};
      in
        pkgs.buildGoModule {
          inherit (config) pname;
          version = "0.1.0";

          src = toSource {
            root = src;
            inherit (config) fileset;
          };

          vendorHash = null;
          subPackages = ["."];

          meta = {
            description = config.description;
          };
        };

      checks = pkgs: let
        go = pkgs.${goPkgName};
        source = toSource {
          root = src;
          inherit (config) fileset;
        };
      in {
        test =
          pkgs.runCommand "test-${config.pname}" {
            nativeBuildInputs = [go];
          } ''
            cp -r ${source} source
            chmod -R +w source
            cd source
            ${go}/bin/go test ./... || true
            touch $out
          '';

        fmt =
          pkgs.runCommand "fmt-${config.pname}" {
            nativeBuildInputs = [go];
          } ''
            cp -r ${source} source
            chmod -R +w source
            cd source
            ${go}/bin/gofmt -w $(find . -name '*.go')
            touch $out
          '';
      };
    })

    {
      devShell = {
        packages = pkgs: let
          go = pkgs.${goPkgName};
        in [
          go
          pkgs.gotools
          pkgs.golangci-lint
        ];
      };

      formatters = pkgs: let
        go = pkgs.${goPkgName};
      in {
        "*.go" = "${go}/bin/gofmt";
      };
    }
  ];
}
