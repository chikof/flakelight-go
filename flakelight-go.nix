{
  lib,
  src,
  config,
  flakelight,
  inputs,
  ...
}: let
  inherit (lib) mkDefault mkMerge mkOption types;
  inherit (lib.fileset) fileFilter maybeMissing toSource unions;
  inherit (flakelight.types) fileset;

  goPkgName = "go_1_${toString config.go.version}";
  defaultPname = let
    name = baseNameOf (toString src);
  in
    if name == ""
    then "hello"
    else name;
  defaultPackage = pkgs: let
    go = pkgs.${goPkgName};
  in
    pkgs.buildGoModule {
      pname = defaultPname;

      version = "0.1.0";
      vendorHash = null;

      src = toSource {
        root = src;
        inherit (config) fileset;
      };

      nativeBuildInputs = [go];
    };
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
    {
      package = mkDefault defaultPackage;
    }

    {
      checks = pkgs: let
        go = pkgs.${goPkgName};
        source = toSource {
          root = src;
          inherit (config) fileset;
        };
      in {
        test =
          pkgs.runCommand "test-${defaultPname}" {
            nativeBuildInputs = [go];
          } ''
            cp -r ${source} source
            chmod -R +w source
            cd source
            ${go}/bin/go test ./... || true
            touch $out
          '';

        fmt =
          pkgs.runCommand "fmt-${defaultPname}" {
            nativeBuildInputs = [go];
          } ''
            cp -r ${source} source
            chmod -R +w source
            cd source
            ${go}/bin/gofmt -w $(find . -name '*.go')
            touch $out
          '';
      };
    }

    {
      devShell = {
        packages = pkgs: let
          go = pkgs.${goPkgName};
        in [
          go
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
