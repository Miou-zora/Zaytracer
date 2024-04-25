# Zaytracer (Raytracer in zig)

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
git clone https://github.com/Miou-zora/Zaytracer.git
cd Zaytracer
nix develop
```

### :construction_worker: <samp>Building</samp>

```shell
zig build
```

### :rocket: <samp>Running</samp>


```shell
# It will build the project and run it. (do nothing if the project is already built)
zig build run
# or you can run the executable directly
./zig-out/bin/zaytracer
```

### :heavy_plus_sign: <samp>Using direnv</samp>

You may load the devShell automatically using [direnv](https://direnv.net)
shell integration.

```
echo "use flake" | tee .envrc
direnv allow
```

## Coding with codespace

If you want to works on the project using codespace, follow these instructions:

<kbd>I.</kbd> Create a codespace with current configuration

<kbd>II.</kbd> Execute `mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" | tee ~/.config/nix/nix.conf`

<kbd>III.</kbd> Execute `eval "$(direnv hook bash)"` for bash or you can find your hook command [here](https://direnv.net/docs/hook.html)

<kbd>IV.</kbd> Execute:
```
echo "use flake" | tee .envrc
direnv allow
```
