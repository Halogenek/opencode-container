# OpenCode Container

A Docker container for running OpenCode v2 in an isolated environment to protect your host system from potential AI-executed commands.

## Overview

This project provides a containerized OpenCode v2 installation that:

- Isolates OpenCode execution from your host system
- Only exposes host files through explicit bind mounts
- Preserves OpenCode configuration, sessions, credentials, and cache across container restarts
- Installs a pinned OpenCode version from verified platform binaries
- Supports configurable package installation via `packages.txt`

The image installs OpenCode v2.3.2. OpenCode v2 is distributed as platform-specific npm packages (`@opencode/cli-<os>-<arch>`); the old `opencode-ai` npm package only contains v1 releases.

> Note: OpenCode v2 allows access to paths outside the project inside the container by default. Host files remain protected because only explicitly mounted directories are visible to the container.

## Usage

Recommended: Create a link to the run script in your path. The following creates a bin symlink called `opencode`, you may of course choose another name.

```
cd opencode-container
ln -s $(pwd)/build_and_run_opencode_container.sh ~/.local/bin/opencode
```

then you can run opencode from your project folder

```
cd my_awesome_project
opencode
```

Or also use open code commands like

```
opencode run "analyze project and init or update notes according to @./cursor/rules/notes.md"
```

### Running

```bash
# Run OpenCode in a container (rebuilds the image using Docker layer caching)
./build_and_run_opencode_container.sh
```

This will:

1. Build the OpenCode Docker image on every run (force a clean rebuild with `-b`)
2. Mount your current directory to `/app` in the container
3. Mount OpenCode config, data, state, and cache directories for persistence
4. Start an interactive OpenCode session

### Persistent directories

| Host path                   | Contents                                                                     |
| --------------------------- | ---------------------------------------------------------------------------- |
| `~/.local/share/opencode`   | Sessions, credentials database (`opencode.db`), logs, and repositories       |
| `~/.config/opencode`        | `opencode.json(c)`, `cli.json`, `AGENTS.md`, and other user configuration    |
| `~/.local/state/opencode`   | State and lock files                                                         |
| `~/.cache/opencode`         | Cached data and downloaded helper binaries                                   |

## Upgrading from OpenCode v1

- v2 reuses the same config, data, and state directories.
- An existing `~/.local/share/opencode/auth.json` is imported into the v2 credential database on first start.
- Global terminal settings are migrated from `tui.json` to `~/.config/opencode/cli.json` on first start.
- V1 plugins do not run in v2 (new plugin API), and integrations that use the v1 server API need porting.
- Rebuild the image instead of running `opencode upgrade` inside the container; the installed binary is pinned to the image.

See the OpenCode documentation at https://opencode.ai/docs for details.

## Customizing Packages

The container uses a `packages.txt` file to install system dependencies.

1. Edit `packages.txt` (one package per line, comments with `#`)
2. Rebuild the container: `./build_and_run_opencode_container.sh -b`

## License

Copyright 2025 European EPC Competence Center GmbH (EECC). Corresponding Author: Sebastian Schmittner <sebastian.schmittner@eecc.de>
Copyright 2026 Jakub Niemczuk (jakub@niemczuk.tech)

<a href="https://www.gnu.org/licenses/agpl-3.0.html">
<img alt="AGPLV3" style="border-width:0" src="https://www.gnu.org/graphics/agplv3-with-text-162x68.png" /><br />
</a>

All code published in this repository is free software: you can redistribute it and/or modify it under the terms of the
GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
</a>

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

[See LICENSE for details](./LICENSE)
