# Cubo
A (meta) build system with multiple  backends (make, ninja, tup, custom) for C# application.

## Usage
1. Install `cubo`
- [Precompiled binaries for windows & linux](https://github.com/o3o/cubo/releases/)
- [Archlinux package]()

2. Create a `cubo.json` file in your Dub project. It should look like this:

```json
[
   {"name": "alyx2", "version": "v0.13.0", "url" : "git@gitlab.com:o3o_d/alyx2.git"},
   {"name": "bindbc-raylib", "version": "0.1.0", "url" : "git@github.com:o3o/bindbc-raylib.git"}
]
```

3. Run `cubo`
```
$ cubo
```
It will create `.cubo` folder, clones the repositories and creates ninja files

It is recommended to add `.cubo` folder to `.gitignore`.


## Json file
`cubo.json` is an array of Json objects.

