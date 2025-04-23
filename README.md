# Zaytracer (Raytracer in zig)

![Rendered image of the raytracer](render.png)

## :bookmark_tabs: <samp>Requirements</samp>

- :cherry_blossom: <samp>zig 0.14</samp>

## :zap: <samp>Usage</samp>

### :construction_worker: <samp>Building</samp>

#### Release
```sh
zig build -Doptimize=ReleaseFast
```

#### Debug
```sh
zig build
```

### :rocket: <samp>Running</samp>

#### With `zig build` or `zig build -Doptimize=ReleaseFast`

```sh
# It will build the project and run it. (do nothing if the project is already built)
zig build run
# or you can run the executable directly
./zig-out/bin/Zaytracer
```

## Perf

### Performance measures

To take performance measures you can use th perf tool like this:
```sh
perf record -g ./Zaytracer
perf report -g 'graph,0.5,caller'
```

You will need a debug build for that, else you won't have debug symbols.

### Time measures

You can use the hyperfine tool to measure the time of execution of the program.

After `zig build -Doptimize=ReleaseFast`:
```sh
hyperfine "./zig-out/bin/Zaytracer" --warmup 10
```
