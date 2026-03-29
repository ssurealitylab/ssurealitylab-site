"""Image upload, resize, and browsing"""
import os
import re
from PIL import Image
from config import IMAGE_DIRS, IMAGE_SIZES, MAX_UPLOAD_SIZE, SITE_ROOT


ALLOWED_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.webp'}


def sanitize_filename(name: str) -> str:
    """Convert name to safe filename: lowercase, underscores, ASCII only."""
    name = name.lower().strip()
    name = re.sub(r'[^a-z0-9_.]', '_', name)
    name = re.sub(r'_+', '_', name)
    name = name.strip('_')
    return name


def get_unique_filename(directory: str, filename: str) -> str:
    """If filename exists, append _2, _3, etc."""
    base, ext = os.path.splitext(filename)
    candidate = filename
    counter = 2
    while os.path.exists(os.path.join(directory, candidate)):
        candidate = f"{base}_{counter}{ext}"
        counter += 1
    return candidate


def list_images(category: str) -> list:
    """List all images in a category directory."""
    directory = IMAGE_DIRS.get(category)
    if not directory or not os.path.exists(directory):
        return []

    images = []
    for f in sorted(os.listdir(directory)):
        ext = os.path.splitext(f)[1].lower()
        if ext in ALLOWED_EXTENSIONS:
            full_path = os.path.join(directory, f)
            stat = os.stat(full_path)
            images.append({
                "filename": f,
                "size": stat.st_size,
                "path": os.path.relpath(full_path, SITE_ROOT),
            })
    return images


def save_image(file_storage, category: str, custom_name: str = None) -> dict:
    """Save and resize an uploaded image.

    Args:
        file_storage: Flask FileStorage object
        category: one of 'members', 'news', 'publications', etc.
        custom_name: optional custom filename (without extension)

    Returns:
        dict with filename, path, size info
    """
    directory = IMAGE_DIRS.get(category)
    if not directory:
        raise ValueError(f"Unknown image category: {category}")

    os.makedirs(directory, exist_ok=True)

    # Validate extension
    original_name = file_storage.filename or "upload.jpg"
    ext = os.path.splitext(original_name)[1].lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise ValueError(f"File type not allowed. Use: {', '.join(ALLOWED_EXTENSIONS)}")

    # Determine filename
    if custom_name:
        filename = sanitize_filename(custom_name) + ext
    else:
        filename = sanitize_filename(os.path.splitext(original_name)[0]) + ext

    filename = get_unique_filename(directory, filename)

    # Save temp file first
    temp_path = os.path.join(directory, f"_temp_{filename}")
    file_storage.save(temp_path)

    # Check file size
    if os.path.getsize(temp_path) > MAX_UPLOAD_SIZE:
        os.remove(temp_path)
        raise ValueError(f"File too large. Maximum size: {MAX_UPLOAD_SIZE // (1024*1024)}MB")

    # Resize
    try:
        img = Image.open(temp_path)

        # Convert to RGB if needed (handles RGBA, P mode etc.)
        if img.mode in ('RGBA', 'P'):
            img = img.convert('RGB')

        max_w, max_h, quality = IMAGE_SIZES.get(category, (1000, 1000, 85))

        # For members: center crop to square then resize
        if category == "members":
            # Square center crop
            w, h = img.size
            side = min(w, h)
            left = (w - side) // 2
            top = (h - side) // 2
            img = img.crop((left, top, left + side, top + side))
            img = img.resize((max_w, max_h), Image.LANCZOS)
        else:
            # Maintain aspect ratio, fit within bounds
            img.thumbnail((max_w, max_h), Image.LANCZOS)

        # Save final
        final_path = os.path.join(directory, filename)
        if ext in ('.jpg', '.jpeg'):
            img.save(final_path, 'JPEG', quality=quality, optimize=True)
        elif ext == '.png':
            img.save(final_path, 'PNG', optimize=True)
        elif ext == '.webp':
            img.save(final_path, 'WEBP', quality=quality)

        os.remove(temp_path)

    except Exception as e:
        if os.path.exists(temp_path):
            os.remove(temp_path)
        raise ValueError(f"Image processing failed: {str(e)}")

    relative_path = os.path.relpath(final_path, SITE_ROOT)
    return {
        "filename": filename,
        "path": relative_path,
        "size": os.path.getsize(final_path),
    }


def delete_image(category: str, filename: str) -> bool:
    """Delete an image file (with path traversal protection)."""
    directory = IMAGE_DIRS.get(category)
    if not directory:
        return False

    filepath = os.path.join(directory, filename)
    # Prevent path traversal
    if not os.path.realpath(filepath).startswith(os.path.realpath(directory)):
        return False
    if os.path.exists(filepath) and os.path.isfile(filepath):
        os.remove(filepath)
        return True
    return False
