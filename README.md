# flakelight-go

Go module for [flakelight][1].

Initializes a Go project flake from its source directory.

[1]: https://github.com/nix-community/flakelight

## Configured options

Sets `package` to a Go package built from the flake source.

Adds `go` to the default devShell.

Adds checks for `go test` and `gofmt`.

Configures `go` files to be formatted with `gofmt`.

## Options

`fileset` configures the fileset the package is built with. By default, it
includes `*.go`, `go.mod`, `go.sum`, and `.golangci.yml`.

`go.version` selects the Go version by looking up `pkgs.go_1_<version>`. For
example, `go.version = 23;` uses `pkgs.go_1_23`. The default is `25`.

`go.ldflags` passes linker flags to `buildGoModule`. The default is `[]`.

`go.buildFlags` passes build flags to `buildGoModule`. The default is `[]`.

`go.tags` sets Go build tags. The default is `[]`.

`go.subPackages` sets the subpackages to build. The default is `[ "." ]`.

`go.vendorHash` sets the `vendorHash` used by `buildGoModule`. Projects with
external dependencies usually need this set. A common workflow is to start with
a fake hash, build once, then replace it with the hash reported by Nix. The
default is `null`.

`go.proxyVendor` sets the `proxyVendor` option for `buildGoModule`. The default
is `false`.

## Getting started

To create a new project in an empty directory, run the following:

```sh
nix flake init -t github:chikof/flakelight-go
````

Existing projects can use one of the example `flake.nix` files below.

## Example flake

You can call this flake directly:

```nix
{
  inputs.flakelight-go.url = "github:chikof/flakelight-go";
  outputs = { flakelight-go, ... }: flakelight-go ./. { };
}
```

With Go build options:

```nix
{
  inputs.flakelight-go.url = "github:chikof/flakelight-go";

  outputs = {flakelight-go, ...}:
    flakelight-go ./. {
      go = {
        version = 25;
        ldflags = [
          "-w"
          "-s"
          "-X main.version=dev"
        ];
        buildFlags = [ "-trimpath" ];
        tags = [ "go" "flakelight" ];
        subPackages = [ "." ];
        vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        proxyVendor = true;
      };
    };
}
```

Alternatively, add this module to your Flakelight config:

```nix
{
  inputs = {
    flakelight.url = "github:nix-community/flakelight";
    flakelight-go.url = "github:chikof/flakelight-go";
  };

  outputs = { flakelight, flakelight-go, ... }: flakelight ./. {
    imports = [ flakelight-go.flakelightModules.default ];

    go.version = 25;
  };
}
```
