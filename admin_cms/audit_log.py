"""Audit log: record who edited what and when."""
import os
import json
from datetime import datetime
from config import SITE_ROOT

AUDIT_LOG = os.path.join(SITE_ROOT, "admin_cms", "audit_log.jsonl")
MAX_ENTRIES = 1000  # keep last N entries


def log_event(user: str, action: str, target: str = "", details: str = ""):
    """Append an audit log entry."""
    entry = {
        "ts": datetime.now().isoformat(timespec='seconds'),
        "user": user or "Anonymous",
        "action": action,
        "target": target,
        "details": details[:200],
    }
    try:
        with open(AUDIT_LOG, 'a', encoding='utf-8') as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")
        _trim_log()
    except Exception:
        pass


def get_recent(limit: int = 100) -> list:
    """Get recent audit log entries (newest first)."""
    if not os.path.exists(AUDIT_LOG):
        return []
    try:
        with open(AUDIT_LOG, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        entries = []
        for line in reversed(lines[-limit:]):
            try:
                entries.append(json.loads(line.strip()))
            except Exception:
                continue
        return entries
    except Exception:
        return []


def _trim_log():
    """Keep only the last MAX_ENTRIES entries."""
    if not os.path.exists(AUDIT_LOG):
        return
    try:
        with open(AUDIT_LOG, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        if len(lines) > MAX_ENTRIES:
            with open(AUDIT_LOG, 'w', encoding='utf-8') as f:
                f.writelines(lines[-MAX_ENTRIES:])
    except Exception:
        pass
