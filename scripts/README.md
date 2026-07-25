# Scripts

Place deterministic project checks and maintenance commands here. No runtime, build system, task
runner, or deployment tooling is selected by the skeleton.

`verify-structure.sh` checks only that the skeleton's required baseline directories and files
exist. It deliberately permits any additional project files and subdirectories.

Requirements: Bash and `/usr/bin/env` for the script launcher. The structural checks themselves
use Bash built-ins and do not require `rg`, GNU `find`, or other validation tools.
