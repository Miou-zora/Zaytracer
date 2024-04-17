# IMPORTANT NOTE: THIS IS NOT THE GOOD README

## Coding with codespace
Create a codespace with current configuration

Execute `mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" | tee ~/.config/nix/nix.conf`

Execute `eval "$(direnv hook bash)"` for bash or you can find you're hook command [here](https://direnv.net/docs/hook.html)

Execute `direnv allow`

# Nix Flake for Zig + Raylib

This repository is a Nix flake for building Zig projects with Raylib. It is currently based on the `master` branch of Zig with the [Zig-overlay](https://github.com/mitchellh/zig-overlay). It use the `raylib` package from the Nixpkgs repository.

This repository is meant to be used as a template for Zig projects that use Raylib. It provides a `flake.nix` file that create a development environment with Zig and Raylib. It also provides a `build.zig` file that can be used to build the project.

> [!NOTE]
> It's a direct raylib binding from C to Zig. It's not a wrapper around the C library.

## :bookmark_tabs: <samp>Requirements</samp>

- :cherry_blossom: <samp>[Nix](https://nixos.org/download.html)</samp>

> [!IMPORTANT]
> You will need to enable `nix-command` and `flakes`experimental features
> If you get an error about it, consider this command:
> `mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" | tee ~/.config/nix/nix.conf`

## :zap: <samp>Usage</samp>

### :wrench: <samp>Setup</samp>

Clone this repository and run `nix develop` to enter the development environment
```shell
git clone https://github.com/Miou-zora/Raylib-Zig-Nix.git
cd Raylib-Zig-Nix
nix develop
```

> [!WARNING]
> Don't forget to remove the `.git` folder if you want to use this repository for a project.
>
> Rename every `Zaytracer` in the project by the name of your project.


### :construction_worker: <samp>Building</samp>

```shell
zig build
```


### :rocket: <samp>Running</samp>


```shell
# It will build the project and run it. (do nothing if the project is already built)
zig build run
# or you can run the executable directly
./zig-out/bin/[Zaytracer]
```

> [!NOTE]
> `nix build` is not supported yet. If you try to use it, it will create a `result` symlink that contain the executable BUT musl isn't linked correctly to binary. It would be appreciated if someone could help me to fix this issue.

### :heavy_plus_sign: <samp>Using direnv</samp>

You may load the devShell automatically using [direnv](https://direnv.net)
shell integration.

```
echo "use flake" | tee .envrc
direnv allow
```
