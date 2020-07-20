# Cubo
A (meta) build system with multiple  backends (make, ninja, tup, custom) for C# application.


## Usage
1. Install `cubo`
- [Precompiled binaries for windows & linux](https://github.com/o3o/cubo/releases/)
- [Archlinux package]()

2. Create a `cubo.json` file in your Dub project. It should look like this:

```json
{
   "name": "Depot",
   "description": "A Depot Library",
   "copyright": "Copyright © 2018, Orefe",
   "homepage": "",
   "authors": ["Orfeo"],
   "license": "BSD 3-clause",
   "targetType": "library",
   "targetPath": "bin",
   "sdk" : "4.7",

   "libs": [ "System.Data.dll", "YamlDotNet.dll", "log4net.dll"],
   "sourceFiles": [],
   "dependencies": {
      "Exception": { "version": "0.3.1", "url" : "git@gitlab.com:ml_cs/Exception.git"},
      "Unstandard": { "version": "1.1.0", "url" : "git@gitlab.com:o3o/Unstandard.git"}
   }
}
```

3. Run `cubo`
```
$ cubo
```
It will create `.cubo` folder, clones the repositories and creates ninja files

It is recommended to add `.cubo` folder to `.gitignore`.


## Json file
`cubo.json` is a Json objects.

| Name            | Type      | Description                                                   |
| ---             | ---       | ---                                                           |
| name [required] | string    | Name of the package, used to uniquely identify the package.   |
| description     | string    | Brief description of the package                              |
| copyright       | string    | Copyright declaration string                                  |
| authors         | string[]  | List of project authors                                       |
| license         | string    | License(s) under which the project can be used                |
| targetType      | string    | Specifies a specific target type (`exe`, `winexe`, `library`) |
| targetPath      | string    | The destination path of the output binary                     |
| sdk             | string    | Specifies SDK version of referenced assemblies                |
| libs            | string[]  | Specifies the location of referenced assemblies               |
| sourceFiles     | string[]  | Additional files passed to the compile                        |
| dependencies    | T[string] | List of project dependencies                                  |








