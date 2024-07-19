# Love2D Universal
A universal [Love2D](https://love2d.org/) project template for cross platform compillation.

This project uses [Love2D](https://love2d.org/). A 2D Lua game engine, and [LOVE Potion](https://lovebrew.org/), a port of Love2D for the Nintendo 3DS, Switch and Wii U.

## Features
- Automated cross-compillation process
- Automated binary downloads
- Easy to use Makefile script

## Platforms
| Platform     | File formats     | Architectures | Status   |
| ------------ | ---------------- | ------------- | -------- |
| Universal    | `love`           | *             | ✅       |
| Linux        | `AppImage`       | x86_64        | ✅       |
| Windows      | `exe`            | x86_64 x86_32 | ✅✅     |
| Nintendo 3DS | `3dsx` ~~`cia`~~ |               | ✅📁     |
| MacOS        |                  |               | 📁       |
| Android      |                  |               | 📁       |

✅ `supported` | 🟡 `unstable` | ❌ `unsupported` | 🕛 `in progress` | 📁 `planned` 

> [!NOTE]  
> The 3DS version may not work under emulators. On real hardware it will most likely crash on the first run, but run successfully when restarted. This seems to be a LovePotion bug (or my 3DS is broken lol).

Feel free to contribute to Love2D and the Makefile to add support for more platforms!
To learn how to run and build your project, refer to the [wiki](https://github.com/Wolfyxon/love2d-universal/wiki).
