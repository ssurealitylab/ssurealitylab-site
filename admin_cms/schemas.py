"""Validation schemas for each data type"""
import re
import os
from config import SITE_ROOT

EMAIL_RE = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
URL_RE = re.compile(r'^https?://[^\s]+$')


class ValidationError(Exception):
    def __init__(self, field, message):
        self.field = field
        self.message = message
        super().__init__(f"{field}: {message}")


def validate_member(data: dict, section: str = "intern") -> list:
    """Validate a member entry. Returns list of errors."""
    errors = []

    if not data.get('name', '').strip():
        errors.append({"field": "name", "message": "English name is required"})
    if not data.get('name_ko', '').strip():
        errors.append({"field": "name_ko", "message": "Korean name is required"})

    email = data.get('email', '')
    if email and not EMAIL_RE.match(email):
        errors.append({"field": "email", "message": "Invalid email format"})

    if section != "robot" and not data.get('research', '').strip():
        errors.append({"field": "research", "message": "Research area is required"})

    # Validate photo path exists
    photo = data.get('photo', '')
    if photo:
        full_path = os.path.join(SITE_ROOT, photo)
        if not os.path.exists(full_path):
            errors.append({"field": "photo", "message": f"Photo not found: {photo}"})

    # Validate URLs
    for url_field in ['github', 'linkedin']:
        url = data.get(url_field, '')
        if url and not URL_RE.match(url):
            errors.append({"field": url_field, "message": f"Invalid URL format"})

    return errors


def validate_news(data: dict) -> list:
    """Validate a news entry."""
    errors = []

    if not data.get('title', '').strip():
        errors.append({"field": "title", "message": "Title is required"})
    if len(data.get('title', '')) > 200:
        errors.append({"field": "title", "message": "Title must be under 200 characters"})

    date = data.get('date', '')
    if not date:
        errors.append({"field": "date", "message": "Date is required"})
    elif not re.match(r'^\d{4}-\d{2}-\d{2}$', str(date)):
        errors.append({"field": "date", "message": "Date format must be YYYY-MM-DD"})

    valid_categories = ['Publication', 'Awards', 'Internship', 'Grants', 'Event', 'General']
    category = data.get('category', '')
    if category and category not in valid_categories:
        errors.append({"field": "category", "message": f"Category must be one of: {', '.join(valid_categories)}"})

    if not data.get('description', '').strip():
        errors.append({"field": "description", "message": "Description is required"})

    return errors


def validate_publication(data: dict, existing_ids: list = None) -> list:
    """Validate a publication entry."""
    errors = []

    if not data.get('id', '').strip():
        errors.append({"field": "id", "message": "ID is required"})
    elif existing_ids and data['id'] in existing_ids:
        errors.append({"field": "id", "message": "ID already exists"})

    if not data.get('title', '').strip():
        errors.append({"field": "title", "message": "Title is required"})
    if not data.get('authors', '').strip():
        errors.append({"field": "authors", "message": "Authors are required"})
    if not data.get('venue', '').strip():
        errors.append({"field": "venue", "message": "Venue is required"})

    year = data.get('year')
    if year is not None:
        try:
            y = int(year)
            if y < 2000 or y > 2100:
                errors.append({"field": "year", "message": "Year must be between 2000-2100"})
        except (ValueError, TypeError):
            errors.append({"field": "year", "message": "Year must be a number"})

    valid_types = ['conference', 'journal', 'workshop']
    pub_type = data.get('type', '')
    if pub_type and pub_type not in valid_types:
        errors.append({"field": "type", "message": f"Type must be one of: {', '.join(valid_types)}"})

    # Validate links
    links = data.get('links', {})
    if isinstance(links, dict):
        for key, url in links.items():
            if url and not URL_RE.match(str(url)):
                errors.append({"field": f"links.{key}", "message": f"Invalid URL"})

    return errors


def validate_data(filename: str, data: dict, path: str = "", **kwargs) -> list:
    """Route validation to the appropriate schema."""
    if filename == "members":
        section = kwargs.get('section')
        if not section:
            # Auto-detect section from path or fields
            if 'robots' in path or 'model' in data or 'specs' in data:
                section = 'robot'
            elif 'faculty' in path:
                section = 'faculty'
            else:
                section = 'intern'
        return validate_member(data, section)
    elif filename == "news":
        return validate_news(data)
    elif filename == "publications":
        return validate_publication(data, **kwargs)
    return []  # No validation for other files yet
