# Love2D Universal
A universal Love2D project template for cross platform compillation

## Supported platforms
- Windows 32, 64
- Linux 64
- Nintendo 3DS

Feel free to contribute to Love2D and the Makefile to add support for more platforms!

## Building and testing your project
First install `make` with your distro's package manager such as `pacman` or `apt`.

The Makefile script will automatically download all dependencies and automate the build process for you. All you need is internet access on the first run. 
All projects share the same dependencies so they won't have to be downloaded again for each project.

### Building
#### Linux x86_64 AppImage
```
make linux
```

#### Windows
x86_64 (64 bit)
```
make win64
```
x86_32 (32 bit)
```
TODO!!!!
```
#### Nintendo 3DS
To run your game on a 3DS you'll need to install the `3ds-dev` toolchain from [devkitPro](https://devkitpro.org/wiki/Getting_Started).

3DSX
```
make 3dsx
```
CIA
```
TODO!!!!!
```

### Running
Running locally
```
make run
```
#### Nintendo 3DS
Remotely launching the project on your 3DS
```
TODO!!!!
```
Emulating your project locally
> [!NOTE]
> [LOVEPotion](https://github.com/lovebrew/LovePotion) currently does not run on emulators and will result in a black screen. However maybe you'll have luck getting it to work.
```
make 3ds_emu
```

#### LOVE file.
```
make love
```
