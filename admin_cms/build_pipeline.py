"""Build pipeline: validate -> backup -> write -> build -> test -> push"""
import os
import subprocess
import time
import fcntl
from config import SITE_ROOT, SITE_DIR

# Lock file for preventing concurrent edits
LOCK_FILE = os.path.join(SITE_ROOT, "admin_cms", ".edit_lock")


class PipelineError(Exception):
    def __init__(self, step, message, auto_restored=False):
        self.step = step
        self.message = message
        self.auto_restored = auto_restored
        super().__init__(f"[{step}] {message}")


class EditLock:
    """File-based exclusive lock for edit operations."""
    def __init__(self):
        self._fd = None

    def acquire(self, timeout=30):
        self._fd = open(LOCK_FILE, 'w')
        start = time.time()
        while True:
            try:
                fcntl.flock(self._fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
                self._fd.write(str(os.getpid()))
                self._fd.flush()
                return True
            except BlockingIOError:
                if time.time() - start > timeout:
                    self._fd.close()
                    self._fd = None
                    return False
                time.sleep(0.5)

    def release(self):
        if self._fd:
            try:
                fcntl.flock(self._fd, fcntl.LOCK_UN)
                self._fd.close()
            except Exception:
                pass
            self._fd = None

    def __enter__(self):
        if not self.acquire():
            raise PipelineError("lock", "Another edit is in progress. Please try again.")
        return self

    def __exit__(self, *args):
        self.release()


def jekyll_build() -> tuple:
    """Run Jekyll build. Returns (success, output)."""
    try:
        result = subprocess.run(
            ["bundle", "exec", "jekyll", "build"],
            cwd=SITE_ROOT,
            capture_output=True,
            text=True,
            timeout=120
        )
        output = result.stdout + result.stderr
        return result.returncode == 0, output
    except subprocess.TimeoutExpired:
        return False, "Jekyll build timed out (120s)"
    except Exception as e:
        return False, str(e)


def smoke_test() -> tuple:
    """Check that essential pages exist after build. Returns (success, details)."""
    essential_pages = [
        "index.html",
        "students.html",
        "news.html",
        "faculty.html",
        "alumni.html",
        "international.html",
    ]

    missing = []
    for page in essential_pages:
        path = os.path.join(SITE_DIR, page)
        if not os.path.exists(path):
            missing.append(page)
        elif os.path.getsize(path) < 500:
            missing.append(f"{page} (too small)")

    if missing:
        return False, f"Missing/broken pages: {', '.join(missing)}"
    return True, "All essential pages OK"


def git_commit(message: str, files: list) -> tuple:
    """Stage specific files and commit (no push). Returns (success, output)."""
    try:
        for f in files:
            subprocess.run(["git", "add", f], cwd=SITE_ROOT, capture_output=True, timeout=10)

        result = subprocess.run(
            ["git", "commit", "-m", message],
            cwd=SITE_ROOT, capture_output=True, text=True, timeout=30
        )
        if result.returncode != 0:
            if "nothing to commit" in result.stdout + result.stderr:
                return True, "No changes to commit"
            return False, result.stdout + result.stderr

        return True, "Committed locally"
    except subprocess.TimeoutExpired:
        return False, "Git operation timed out"
    except Exception as e:
        return False, str(e)


def git_push() -> tuple:
    """Push all local commits to remote. Returns (success, output)."""
    try:
        result = subprocess.run(
            ["git", "push"], cwd=SITE_ROOT, capture_output=True, text=True, timeout=60
        )
        if result.returncode != 0:
            return False, f"Push failed: {result.stderr}"
        return True, "Pushed to remote successfully"
    except subprocess.TimeoutExpired:
        return False, "Push timed out"
    except Exception as e:
        return False, str(e)


def has_unpushed_commits() -> dict:
    """Check if there are local commits not pushed to remote."""
    try:
        result = subprocess.run(
            ["git", "log", "origin/main..HEAD", "--oneline"],
            cwd=SITE_ROOT, capture_output=True, text=True, timeout=10
        )
        lines = [l for l in result.stdout.strip().split('\n') if l]
        return {"unpushed": len(lines), "commits": lines}
    except Exception:
        return {"unpushed": 0, "commits": []}


def full_deploy(yaml_filename: str, data: dict, operation: str,
                validate_fn=None, extra_files=None):
    """Full deploy pipeline with safety.

    Args:
        yaml_filename: key from EDITABLE_FILES (e.g., 'members')
        data: the complete YAML data to write
        operation: description for backup/commit
        validate_fn: optional validation function(data) -> list of errors
        extra_files: additional files to stage (e.g., uploaded images)

    Returns:
        dict with status, backup_id, message
    """
    from backup_manager import create_backup, restore_backup
    from yaml_manager import write_yaml, get_yaml_path
    from config import EDITABLE_FILES

    # Step 1: Validate
    if validate_fn:
        errors = validate_fn(data)
        if errors:
            return {"status": "error", "step": "validate", "errors": errors}

    backup_id = None
    yml_name = EDITABLE_FILES[yaml_filename]
    yml_rel_path = os.path.join("_data", yml_name)
    files_to_stage = [yml_rel_path]
    if extra_files:
        files_to_stage.extend(extra_files)

    with EditLock():
        # Step 2: Backup
        backup_id = create_backup(operation, [yaml_filename])

        # Step 3: Write YAML
        try:
            write_yaml(yaml_filename, data)
        except Exception as e:
            restore_backup(backup_id)
            return {"status": "error", "step": "write", "message": str(e),
                    "auto_restored": True, "backup_id": backup_id}

        # Step 4: Jekyll build
        success, output = jekyll_build()
        if not success:
            restore_backup(backup_id)
            # Rebuild with restored data
            jekyll_build()
            return {"status": "error", "step": "build", "message": output,
                    "auto_restored": True, "backup_id": backup_id}

        # Step 5: Smoke test
        success, details = smoke_test()
        if not success:
            restore_backup(backup_id)
            jekyll_build()
            return {"status": "error", "step": "smoke_test", "message": details,
                    "auto_restored": True, "backup_id": backup_id}

        # Step 6: Git commit (no push - user pushes manually via "Apply" button)
        commit_msg = f"CMS: {operation}"
        success, git_output = git_commit(commit_msg, files_to_stage)

        return {
            "status": "success",
            "backup_id": backup_id,
            "message": f"Saved. {git_output}",
            "pushed": False,
        }
