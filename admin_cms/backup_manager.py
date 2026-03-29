"""Backup manager with automatic backup and rollback"""
import os
import json
import shutil
import time
from datetime import datetime
from config import DATA_DIR, BACKUP_DIR, MAX_BACKUPS, EDITABLE_FILES


def create_backup(operation: str, files: list) -> str:
    """Create a backup of specified YAML files before editing.
    Returns backup_id (directory name).
    """
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    safe_op = operation.replace('/', '_').replace(' ', '_').replace('.', '_')
    backup_id = f"{timestamp}_{safe_op}"
    backup_dir = os.path.join(BACKUP_DIR, backup_id)
    os.makedirs(backup_dir, exist_ok=True)

    # Copy each file
    backed_up = []
    for filename in files:
        yml_name = EDITABLE_FILES.get(filename, filename)
        src = os.path.join(DATA_DIR, yml_name)
        if os.path.exists(src):
            shutil.copy2(src, os.path.join(backup_dir, yml_name))
            backed_up.append(yml_name)

    # Write manifest
    manifest = {
        "timestamp": timestamp,
        "operation": operation,
        "files": backed_up,
        "created_at": datetime.now().isoformat(),
    }
    with open(os.path.join(backup_dir, "manifest.json"), 'w') as f:
        json.dump(manifest, f, indent=2)

    # Cleanup old backups
    _cleanup_old_backups()

    return backup_id


def restore_backup(backup_id: str) -> bool:
    """Restore files from a backup."""
    backup_dir = os.path.join(BACKUP_DIR, backup_id)
    if not os.path.exists(backup_dir):
        return False

    manifest_path = os.path.join(backup_dir, "manifest.json")
    if not os.path.exists(manifest_path):
        return False

    with open(manifest_path, 'r') as f:
        manifest = json.load(f)

    for yml_name in manifest['files']:
        src = os.path.join(backup_dir, yml_name)
        dst = os.path.join(DATA_DIR, yml_name)
        if os.path.exists(src):
            shutil.copy2(src, dst)

    return True


def list_backups() -> list:
    """List all available backups, newest first."""
    if not os.path.exists(BACKUP_DIR):
        return []

    backups = []
    for name in sorted(os.listdir(BACKUP_DIR), reverse=True):
        manifest_path = os.path.join(BACKUP_DIR, name, "manifest.json")
        if os.path.exists(manifest_path):
            with open(manifest_path, 'r') as f:
                manifest = json.load(f)
            manifest['backup_id'] = name
            backups.append(manifest)

    return backups


def _cleanup_old_backups():
    """Keep only the most recent MAX_BACKUPS backups."""
    if not os.path.exists(BACKUP_DIR):
        return

    dirs = sorted([
        d for d in os.listdir(BACKUP_DIR)
        if os.path.isdir(os.path.join(BACKUP_DIR, d))
    ])

    while len(dirs) > MAX_BACKUPS:
        oldest = dirs.pop(0)
        shutil.rmtree(os.path.join(BACKUP_DIR, oldest), ignore_errors=True)
