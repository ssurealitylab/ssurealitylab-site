"""YAML file manager with safe read/write and validation"""
import os
import copy
from ruamel.yaml import YAML
from config import DATA_DIR, EDITABLE_FILES

yaml = YAML()
yaml.preserve_quotes = True
yaml.width = 4096  # prevent line wrapping


def get_yaml_path(filename: str) -> str:
    """Get full path to a YAML data file"""
    if filename in EDITABLE_FILES:
        return os.path.join(DATA_DIR, EDITABLE_FILES[filename])
    raise ValueError(f"Unknown file: {filename}")


def read_yaml(filename: str) -> dict:
    """Read and parse a YAML file"""
    path = get_yaml_path(filename)
    with open(path, 'r', encoding='utf-8') as f:
        data = yaml.load(f)
    return data or {}


def write_yaml(filename: str, data: dict) -> None:
    """Write data to YAML file with round-trip verification"""
    path = get_yaml_path(filename)

    # Write to file
    with open(path, 'w', encoding='utf-8') as f:
        yaml.dump(data, f)

    # Round-trip verification: read back and compare structure
    with open(path, 'r', encoding='utf-8') as f:
        readback = yaml.load(f)

    if not _deep_compare(data, readback):
        raise RuntimeError("YAML round-trip verification failed! Data mismatch after write.")


def _deep_compare(a, b) -> bool:
    """Deep compare two data structures (ruamel CommentedMap/Seq compatible)"""
    if type(a).__name__ != type(b).__name__:
        # Allow CommentedMap vs dict, CommentedSeq vs list
        a = _to_plain(a)
        b = _to_plain(b)

    if isinstance(a, dict):
        if set(a.keys()) != set(b.keys()):
            return False
        return all(_deep_compare(a[k], b[k]) for k in a)
    elif isinstance(a, list):
        if len(a) != len(b):
            return False
        return all(_deep_compare(x, y) for x, y in zip(a, b))
    else:
        return str(a) == str(b)


def _to_plain(obj):
    """Convert ruamel types to plain Python types"""
    if hasattr(obj, 'items'):
        return {str(k): _to_plain(v) for k, v in obj.items()}
    elif hasattr(obj, '__iter__') and not isinstance(obj, (str, bytes)):
        return [_to_plain(item) for item in obj]
    else:
        return obj


def resolve_path(data: dict, path: str):
    """Resolve a dot-notation path to a value in nested data.
    Example: 'students.ms_students.3' -> data['students']['ms_students'][3]
    """
    if not path:
        return data

    parts = path.split('.')
    current = data
    for part in parts:
        if part.isdigit():
            idx = int(part)
            if not isinstance(current, list) or idx >= len(current):
                raise KeyError(f"Index {idx} out of range")
            current = current[idx]
        else:
            if not hasattr(current, '__getitem__'):
                raise KeyError(f"Cannot index into {type(current)}")
            current = current[part]
    return current


def set_at_path(data: dict, path: str, value) -> dict:
    """Set a value at a dot-notation path. Returns modified data."""
    parts = path.split('.')
    current = data
    for part in parts[:-1]:
        if part.isdigit():
            current = current[int(part)]
        else:
            current = current[part]

    last = parts[-1]
    if last.isdigit():
        current[int(last)] = value
    else:
        current[last] = value
    return data


def append_at_path(data: dict, path: str, value) -> dict:
    """Append a value to a list at a dot-notation path."""
    target = resolve_path(data, path)
    if not isinstance(target, list):
        raise TypeError(f"Target at '{path}' is not a list")
    target.append(value)
    return data


def delete_at_path(data: dict, path: str) -> dict:
    """Delete an item at a dot-notation path."""
    parts = path.split('.')
    parent_path = '.'.join(parts[:-1])
    parent = resolve_path(data, parent_path) if parent_path else data

    last = parts[-1]
    if last.isdigit():
        idx = int(last)
        if isinstance(parent, list) and idx < len(parent):
            parent.pop(idx)
        else:
            raise KeyError(f"Index {idx} out of range")
    else:
        if last in parent:
            del parent[last]
        else:
            raise KeyError(f"Key '{last}' not found")
    return data


def get_file_hash(filename: str) -> str:
    """Get a hash of the file content for ETag/concurrency control"""
    import hashlib
    path = get_yaml_path(filename)
    with open(path, 'rb') as f:
        return hashlib.md5(f.read()).hexdigest()
