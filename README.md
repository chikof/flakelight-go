# flakelight-go

Go module for [flakelight][1].

Initializes a Go project flake from its source directory.

[1]: https://github.com/nix-community/flakelight

## Configured options

Sets `package` to a Go package built from the flake source.

Adds `go`, `gotools`, and `golangci-lint` to the default devShell.

Adds checks for `go test` and `gofmt`.

Configures `go` files to be formatted with `gofmt`.

## Options

`fileset` configures the fileset the package is built with. By default, it
includes `*.go`, `go.mod`, `go.sum`, and `.golangci.yml`.

`go.version` selects the Go version to use by looking up `pkgs.go_1_<version>`.
For example:

- `go.version = 23;` → `pkgs.go_1_23`
- `go.version = 25;` → `pkgs.go_1_25`

The default Go version is `25`.

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

To choose a specific Go version:

```nix
{
  inputs.flakelight-go.url = "github:chikof/flakelight-go";
  outputs = { flakelight-go, ... }:
    flakelight-go ./. {
      go.version = 25;
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
  };
}
```

With a pinned Go version:

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
