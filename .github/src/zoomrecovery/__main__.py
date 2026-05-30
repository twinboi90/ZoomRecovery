"""
zoomrecovery – entry point for the PyPI-installed command.

Extracts the bundled shell script to a temp file and executes it,
forwarding all arguments and preserving exit status.
"""

import importlib.resources
import os
import stat
import subprocess
import sys
import tempfile


def main() -> None:
    # Locate the bundled shell script inside the package
    pkg = importlib.resources.files("zoomrecovery")
    script_bytes = pkg.joinpath("_script.sh").read_bytes()

    # Write to a temp file so we can chmod + exec it
    fd, tmp_path = tempfile.mkstemp(suffix=".sh", prefix="zoomrecovery_")
    try:
        with os.fdopen(fd, "wb") as f:
            f.write(script_bytes)
        # rwxr-xr-x
        os.chmod(
            tmp_path,
            stat.S_IRWXU | stat.S_IRGRP | stat.S_IXGRP | stat.S_IROTH | stat.S_IXOTH,
        )
        result = subprocess.run(["/bin/bash", tmp_path] + sys.argv[1:])
        sys.exit(result.returncode)
    finally:
        try:
            os.unlink(tmp_path)
        except OSError:
            pass


if __name__ == "__main__":
    main()
