# OpenCode Container

A Docker container for running OpenCode in an isolated environment to protect your host system from potential AI-executed commands.

## Overview

This project provides a containerized OpenCode installation that:

- Isolates OpenCode execution from your host system
- Restricts AI operations to mounted project directories only
- Preserves OpenCode configuration across container restarts

- Configurable package installation via `packages.txt`

## Usage

Recommended: Create a link to the run script in your path. The following creates a bin symlink callen `opencode`, you may of course choose another name.

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
opencode run "analyze project and init or update notes according to @./cusror/rules/notes.md"
```

### Running

```bash
# Run OpenCode in a container (builds automatically if needed)
./build_and_run_opencode_container.sh
```

This will:

1. Build the OpenCode Docker image (if not already built, force with `-b`)
2. Mount your current directory to `/app` in the container
3. Mount OpenCode config directories for persistence
4. Start an interactive OpenCode session

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
