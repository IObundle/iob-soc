import os
import shutil

from iob_module import iob_module


class iob_tasks(iob_module):
    name = "iob_tasks"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    # Copy sources of this module to the build directory
    @classmethod
    def _copy_srcs(cls):
        out_dir = cls.get_purpose_dir(cls._setup_purpose[-1])
        # Copy source to build directory
        shutil.copyfile(
            os.path.join(cls.setup_dir, "iob_tasks.vs"),
            os.path.join(cls.build_dir, out_dir, "iob_tasks.vs"),
        )

        # Ensure sources of other purposes are deleted (except software)
        # Check that latest purpose is hardware
        if cls._setup_purpose[-1] == "hardware" and len(cls._setup_purpose) > 1:
            # Purposes that have been setup previously
            for purpose in [x for x in cls._setup_purpose[:-1] if x != "software"]:
                # Delete sources for this purpose
                os.remove(
                    os.path.join(
                        cls.build_dir, cls.PURPOSE_DIRS[purpose], "iob_tasks.v"
                    )
                )
