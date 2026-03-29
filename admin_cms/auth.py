"""Authentication module for Admin CMS"""
import os
import json
import time
import secrets
import bcrypt
from datetime import timedelta
from functools import wraps
from flask import session, request, jsonify, redirect, url_for
from config import CONFIG_FILE, SESSION_TIMEOUT_HOURS, LOGIN_RATE_LIMIT, LOGIN_LOCKOUT_MINUTES


def load_config():
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    return {}


def save_config(config):
    with open(CONFIG_FILE, 'w') as f:
        json.dump(config, f, indent=2)


def init_auth(app):
    """Initialize authentication. Returns True if password is already set."""
    config = load_config()

    # Generate secret key if not exists
    if 'secret_key' not in config:
        config['secret_key'] = secrets.token_hex(32)
        save_config(config)

    app.secret_key = config['secret_key']
    app.permanent_session_lifetime = timedelta(hours=SESSION_TIMEOUT_HOURS)

    return 'password_hash' in config


def set_password(password: str):
    """Set admin password (first-time setup or password change)"""
    config = load_config()
    config['password_hash'] = bcrypt.hashpw(
        password.encode('utf-8'), bcrypt.gensalt()
    ).decode('utf-8')
    config['failed_attempts'] = 0
    config['lockout_until'] = 0
    save_config(config)


def verify_password(password: str) -> bool:
    """Verify password and handle rate limiting"""
    config = load_config()

    # Check lockout
    if config.get('lockout_until', 0) > time.time():
        return False

    stored_hash = config.get('password_hash', '')
    if not stored_hash:
        return False

    if bcrypt.checkpw(password.encode('utf-8'), stored_hash.encode('utf-8')):
        config['failed_attempts'] = 0
        config['lockout_until'] = 0
        save_config(config)
        return True
    else:
        config['failed_attempts'] = config.get('failed_attempts', 0) + 1
        if config['failed_attempts'] >= LOGIN_RATE_LIMIT:
            config['lockout_until'] = time.time() + LOGIN_LOCKOUT_MINUTES * 60
            config['failed_attempts'] = 0
        save_config(config)
        return False


def is_locked_out() -> bool:
    config = load_config()
    return config.get('lockout_until', 0) > time.time()


def login_required(f):
    """Decorator to require authentication"""
    @wraps(f)
    def decorated(*args, **kwargs):
        if not session.get('authenticated'):
            if request.is_json:
                return jsonify({"error": "Authentication required"}), 401
            return redirect('/login')
        return f(*args, **kwargs)
    return decorated
