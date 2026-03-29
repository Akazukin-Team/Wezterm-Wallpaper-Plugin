# Wezterm Wallpaper Plugin

A highly customizable lua mmodule for Wezterm to dynamiclly manage and update window wallpaper.

---

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
- [Contributing](#contributing)
- [Build Instructions](#build-instructions)
- [Continuous Integration](#continuous-integration)
- [License](#license)
- [Contact](#contact)

---

## Features

- Dynamic Updates: Change wallpapers on the fly via Lua API.
- Smart Context: Automatically applies backgrounds to active windows.
- Easy Setup: Seamless integration with your `wezterm.lua` configuration.

---

## Getting Started

### Prerequisites

Make sure you have the following installed:

- **Wezterm** nightly or later

---

### Installation

1. Clone the repository:

   ```shell
   git clone https://github.com/Akazukin-Team/Wezterm-Wallpaper-Plugin.git
   cd Wezterm-Wallpaper-Plugin
   ```

2. Write wezterm.lua

   ```lua
   local wallpaper = require 'path_to_repo/src/wallpaper'
   
   local wallpaper_cfg = wallpaper.create_config()
   wallpaper_cfg.paths = {'D:\\Wallpapers'}
   wallpaper_cfg.interval = 30
   wallpaper_cfg.max_depth = 5
   wallpaper_cfg.opacity = 0.9
   wallpaper_cfg.brightness = 0.15
   
   wallpaper.setup(wallpaper_config)
   ```

---

## Contributing

Please read the [Contribution Guide](./.github/CONTRIBUTING.md) carefully and follow the coding conventions and
guidelines when making your changes.

---

## Continuous Integration

This project uses GitHub Actions for Continuous Integration (CI).
Every push to the production or development branch automatically triggers the build and test workflow.

---

## License

This project is licensed under the terms described in the [License](LICENSE) file.

---

## Contact

If you need further assistance or wish to contact us directly,
please refer to the [Support](./.github/SUPPORT.md) page.

---
