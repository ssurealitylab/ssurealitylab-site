---
layout: page
title: Alumni - Reality Lab | 졸업생 - 리얼리티랩
description: Former members of Reality Lab at Soongsil University. Alumni and former research interns who contributed to AI research. 숭실대학교 김희원 교수 연구실 졸업생.
keywords: Reality Lab alumni, 리얼리티랩 졸업생, Soongsil University, 숭실대학교, 숭실대, SSU, former interns, 전 연구원, 김희원, Heewon Kim, 글로벌미디어학부, Computer Vision, Deep Learning, AI researchers
---

# Alumni

## Former Master's Students
<p style="color: #6c757d; font-size: 0.9rem; margin-top: -10px; margin-bottom: 20px;">Click on a card to view detailed information</p>

<div class="members-grid">
  {% for alumnus in site.data.members.alumni.former_ms_students %}
  <div class="member-card clickable-card" onclick="openMemberModal('ms-alumni-{{ alumnus.name | slugify }}')">
    <div class="member-photo">
      <img src="{{ alumnus.photo }}" alt="{{ alumnus.name }}" onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDIwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIyMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjZjNmNGY2Ii8+CjxjaXJjbGUgY3g9IjEwMCIgY3k9IjgwIiByPSIzMCIgZmlsbD0iIzllYTNhOCIvPgo8cGF0aCBkPSJNNjAgMTYwYzAtMjIuMDkgMTcuOTEtNDAgNDAtNDBzNDAgMTcuOTEgNDAgNDB2MjBINjB2LTIweiIgZmlsbD0iIzllYTNhOCIvPgo8L3N2Zz4K'">
    </div>
    <div class="member-info">
      <h3 class="member-name">{{ alumnus.name }}</h3>
      {% if alumnus.current_position %}
      <p class="member-current-position">{{ alumnus.current_position }}</p>
      {% endif %}
      {% if alumnus.email %}
      <p class="member-email">{{ alumnus.email }}</p>
      {% endif %}
      {% if alumnus.university %}
      <p class="member-university">{{ alumnus.university }}</p>
      {% endif %}
      {% if alumnus.research %}
      <p class="member-research">{{ alumnus.research }}</p>
      {% endif %}
      {% if alumnus.period %}
      <p class="member-period">{{ alumnus.period }}</p>
      {% endif %}
      <div class="member-social">
        {% if alumnus.email and alumnus.email != "" %}
          <a href="#" onclick="event.preventDefault(); event.stopPropagation(); copyEmail('{{ alumnus.email }}', event)" title="Email">
            <i class="fas fa-envelope"></i>
          </a>
        {% endif %}
        {% if alumnus.github and alumnus.github != "" %}
        <a href="{{ alumnus.github }}" target="_blank" onclick="event.stopPropagation()" title="GitHub">
          <i class="fab fa-github"></i>
        </a>
        {% endif %}
        {% if alumnus.linkedin and alumnus.linkedin != "" %}
        <a href="{{ alumnus.linkedin }}" target="_blank" onclick="event.stopPropagation()" title="LinkedIn">
          <i class="fab fa-linkedin"></i>
        </a>
        {% endif %}
      </div>
    </div>
  </div>

  <!-- Modal for {{ alumnus.name }} -->
  <div id="modal-ms-alumni-{{ alumnus.name | slugify }}" class="member-modal">
    <div class="modal-content">
      <span class="close-modal" onclick="closeMemberModal('ms-alumni-{{ alumnus.name | slugify }}')">&times;</span>
      <div class="modal-photo">
        <img src="{{ alumnus.photo }}" alt="{{ alumnus.name }}" onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDIwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIyMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjZjNmNGY2Ii8+CjxjaXJjbGUgY3g9IjEwMCIgY3k9IjgwIiByPSIzMCIgZmlsbD0iIzllYTNhOCIvPgo8cGF0aCBkPSJNNjAgMTYwYzAtMjIuMDkgMTcuOTEtNDAgNDAtNDBzNDAgMTcuOTEgNDAgNDB2MjBINjB2LTIweiIgZmlsbD0iIzllYTNhOCIvPgo8L3N2Zz4K'">
      </div>
      <div class="modal-info">
        <h2 class="modal-name">{{ alumnus.name }}</h2>
        {% if alumnus.current_position %}
        <p class="modal-current-position"><strong>Current:</strong> {{ alumnus.current_position }}</p>
        {% endif %}
        {% if alumnus.university %}
        <p class="modal-university"><strong>University:</strong> {{ alumnus.university }}</p>
        {% endif %}
        {% if alumnus.research %}
        <p class="modal-research"><strong>Research:</strong> {{ alumnus.research }}</p>
        {% endif %}
        {% if alumnus.period %}
        <p class="modal-period"><strong>Period:</strong> {{ alumnus.period }}</p>
        {% endif %}
        <div class="modal-social">
          {% if alumnus.github and alumnus.github != "" %}
          <a href="{{ alumnus.github }}" target="_blank" title="GitHub">
            <i class="fab fa-github"></i>
          </a>
          {% endif %}
          {% if alumnus.linkedin and alumnus.linkedin != "" %}
          <a href="{{ alumnus.linkedin }}" target="_blank" title="LinkedIn">
            <i class="fab fa-linkedin"></i>
          </a>
          {% endif %}
        </div>
      </div>
    </div>
  </div>
  {% endfor %}
</div>

## Former Research Interns
<p style="color: #6c757d; font-size: 0.9rem; margin-top: -10px; margin-bottom: 20px;">Click on a card to view detailed information</p>

<div class="members-grid">
  {% for alumnus in site.data.members.alumni.former_interns %}
  <div class="member-card clickable-card" onclick="openMemberModal('alumni-{{ alumnus.name | slugify }}')">
    <div class="member-photo">
      <img src="{{ alumnus.photo }}" alt="{{ alumnus.name }}" onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDIwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIyMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjZjNmNGY2Ii8+CjxjaXJjbGUgY3g9IjEwMCIgY3k9IjgwIiByPSIzMCIgZmlsbD0iIzllYTNhOCIvPgo8cGF0aCBkPSJNNjAgMTYwYzAtMjIuMDkgMTcuOTEtNDAgNDAtNDBzNDAgMTcuOTEgNDAgNDB2MjBINjB2LTIweiIgZmlsbD0iIzllYTNhOCIvPgo8L3N2Zz4K'">
    </div>
    <div class="member-info">
      <h3 class="member-name">{{ alumnus.name }}</h3>
      {% if alumnus.email %}
      <p class="member-email">{{ alumnus.email }}</p>
      {% endif %}
      {% if alumnus.university %}
      <p class="member-university">{{ alumnus.university }}</p>
      {% endif %}
      {% if alumnus.research %}
      <p class="member-research">{{ alumnus.research }}</p>
      {% endif %}
      {% if alumnus.period %}
      <p class="member-period">{{ alumnus.period }}</p>
      {% endif %}
      <div class="member-social">
        {% if alumnus.email and alumnus.email != "" %}
          <a href="#" onclick="event.preventDefault(); event.stopPropagation(); copyEmail('{{ alumnus.email }}', event)" title="Email">
            <i class="fas fa-envelope"></i>
          </a>
        {% else %}
          <a href="#" onclick="event.preventDefault(); event.stopPropagation()" title="Email">
            <i class="fas fa-envelope"></i>
          </a>
        {% endif %}
        {% if alumnus.github and alumnus.github != "" %}
        <a href="{{ alumnus.github }}" target="_blank" onclick="event.stopPropagation()" title="GitHub">
          <i class="fab fa-github"></i>
        </a>
        {% endif %}
      </div>
    </div>
  </div>

  <!-- Modal for {{ alumnus.name }} -->
  <div id="modal-alumni-{{ alumnus.name | slugify }}" class="member-modal">
    <div class="modal-content">
      <span class="close-modal" onclick="closeMemberModal('alumni-{{ alumnus.name | slugify }}')">&times;</span>
      <div class="modal-photo">
        <img src="{{ alumnus.photo }}" alt="{{ alumnus.name }}" onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDIwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIyMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjZjNmNGY2Ii8+CjxjaXJjbGUgY3g9IjEwMCIgY3k9IjgwIiByPSIzMCIgZmlsbD0iIzllYTNhOCIvPgo8cGF0aCBkPSJNNjAgMTYwYzAtMjIuMDkgMTcuOTEtNDAgNDAtNDBzNDAgMTcuOTEgNDAgNDB2MjBINjB2LTIweiIgZmlsbD0iIzllYTNhOCIvPgo8L3N2Zz4K'">
      </div>
      <div class="modal-info">
        <h2 class="modal-name">{{ alumnus.name }}</h2>
        {% if alumnus.university %}
        <p class="modal-university"><strong>University:</strong> {{ alumnus.university }}</p>
        {% endif %}
        {% if alumnus.research %}
        <p class="modal-research"><strong>Research:</strong> {{ alumnus.research }}</p>
        {% endif %}
        {% if alumnus.period %}
        <p class="modal-period"><strong>Period:</strong> {{ alumnus.period }}</p>
        {% endif %}
        <div class="modal-social">
          {% if alumnus.github and alumnus.github != "" %}
          <a href="{{ alumnus.github }}" target="_blank" title="GitHub">
            <i class="fab fa-github"></i>
          </a>
          {% endif %}
        </div>
      </div>
    </div>
  </div>
  {% endfor %}
</div>

<style>
.members-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 25px;
  margin-bottom: 50px;
  padding: 20px 0;
}

.member-card {
  background: white;
  border-radius: 12px;
  padding: 25px;
  text-align: center;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.member-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.member-photo {
  margin-bottom: 20px;
}

.member-photo img {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid #f8f9fa;
}

.member-name {
  font-size: 1.3rem;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 5px;
}

.member-email {
  font-size: 0.85rem;
  color: #495057;
  margin-bottom: 8px;
  line-height: 1.4;
  font-weight: 500;
}

.member-university {
  font-size: 0.85rem;
  color: #495057;
  margin-bottom: 10px;
  line-height: 1.4;
  font-weight: 500;
}

.member-research {
  font-size: 0.9rem;
  color: #6c757d;
  margin-bottom: 10px;
  line-height: 1.4;
}

.member-current-position {
  font-size: 0.9rem;
  color: #3498db;
  font-weight: 600;
  margin-bottom: 8px;
}

.modal-current-position {
  font-size: 1rem;
  color: #3498db;
  font-weight: 600;
  margin-bottom: 15px;
}

.member-period {
  font-size: 0.85rem;
  color: #28a745;
  font-weight: 600;
  background: #f8f9fa;
  padding: 5px 10px;
  border-radius: 15px;
  display: inline-block;
  margin-top: 5px;
}

.member-social {
  display: flex;
  justify-content: center;
  gap: 10px;
  margin-top: 15px;
  position: relative;
}

.member-social a {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 35px;
  height: 35px;
  border-radius: 50%;
  background: #f8f9fa;
  color: #6c757d;
  text-decoration: none;
  transition: all 0.3s ease;
}

.member-social a:hover {
  background: #3498db;
  color: white;
  transform: translateY(-2px);
}

.email-copied-tooltip {
  position: absolute;
  bottom: -35px;
  left: 50%;
  transform: translateX(-50%);
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 0.8em;
  white-space: nowrap;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
  z-index: 1000;
  animation: tooltipFadeIn 0.2s ease-out;
  pointer-events: none;
}

.email-copied-tooltip::before {
  content: '';
  position: absolute;
  top: -6px;
  left: 50%;
  transform: translateX(-50%);
  border-left: 6px solid transparent;
  border-right: 6px solid transparent;
  border-bottom: 6px solid #667eea;
}

@keyframes tooltipFadeIn {
  from {
    opacity: 0;
    transform: translateX(-50%) translateY(5px);
  }
  to {
    opacity: 1;
    transform: translateX(-50%) translateY(0);
  }
}

h2 {
  color: #2c3e50;
  font-size: 2rem;
  margin-bottom: 20px;
  margin-top: 40px;
  border-bottom: 2px solid #3498db;
  padding-bottom: 10px;
}

h2:first-of-type {
  margin-top: 20px;
}

.clickable-card {
  cursor: pointer;
}

.clickable-card:hover {
  transform: translateY(-5px) scale(1.02);
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.2);
}

/* Modal Styles */
.member-modal {
  display: none;
  position: fixed;
  z-index: 9999;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.8);
  justify-content: center;
  align-items: center;
}

.modal-content {
  background: white;
  width: 450px;
  height: 450px;
  border-radius: 20px;
  padding: 40px;
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: modalSlideIn 0.3s ease-out;
}

@keyframes modalSlideIn {
  from {
    opacity: 0;
    transform: scale(0.8);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.close-modal {
  position: absolute;
  top: 15px;
  right: 20px;
  font-size: 28px;
  font-weight: bold;
  color: #999;
  cursor: pointer;
  transition: color 0.3s ease;
}

.close-modal:hover {
  color: #333;
}

.modal-photo {
  margin-bottom: 25px;
}

.modal-photo img {
  width: 150px;
  height: 150px;
  border-radius: 50%;
  object-fit: cover;
  border: 4px solid #f8f9fa;
}

.modal-name {
  font-size: 1.8rem;
  font-weight: 700;
  color: #2c3e50;
  margin-bottom: 15px;
}

.modal-university,
.modal-research,
.modal-period {
  font-size: 1rem;
  color: #6c757d;
  margin-bottom: 15px;
  line-height: 1.5;
}

.modal-period {
  color: #28a745;
  font-weight: 600;
  background: #f8f9fa;
  padding: 8px 15px;
  border-radius: 15px;
  display: inline-block;
}

@media (max-width: 768px) {
  .members-grid {
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 20px;
  }
  
  .member-card {
    padding: 20px;
  }
  
  .member-photo img {
    width: 100px;
    height: 100px;
  }
  
  .member-name {
    font-size: 1.2rem;
  }
}
</style>

<script>
function copyEmail(email, event) {
  // Create a temporary textarea element
  const textarea = document.createElement('textarea');
  textarea.value = email;
  textarea.style.position = 'fixed';
  textarea.style.opacity = '0';
  document.body.appendChild(textarea);
  textarea.select();

  try {
    // Copy to clipboard
    document.execCommand('copy');

    // Show tooltip below the clicked icon
    showEmailTooltip(event.currentTarget);
  } catch (err) {
    console.error('Failed to copy email:', err);
  }

  document.body.removeChild(textarea);
}

function showEmailTooltip(element) {
  // Remove any existing tooltip
  const existingTooltip = document.querySelector('.email-copied-tooltip');
  if (existingTooltip) {
    existingTooltip.remove();
  }

  // Find the parent member-social container
  const socialLinks = element.closest('.member-social');
  if (!socialLinks) return;

  // Create new tooltip
  const tooltip = document.createElement('div');
  tooltip.className = 'email-copied-tooltip';
  tooltip.textContent = '이메일이 복사되었습니다';

  // Append to social-links container
  socialLinks.appendChild(tooltip);

  // Remove tooltip after 2 seconds
  setTimeout(() => {
    tooltip.remove();
  }, 2000);
}

function openMemberModal(memberId) {
  const modal = document.getElementById('modal-' + memberId);
  if (modal) {
    modal.style.display = 'flex';
    document.body.style.overflow = 'hidden'; // Prevent background scrolling
  }
}

function closeMemberModal(memberId) {
  const modal = document.getElementById('modal-' + memberId);
  if (modal) {
    modal.style.display = 'none';
    document.body.style.overflow = 'auto'; // Restore scrolling
  }
}

// Close modal when clicking outside of it
document.addEventListener('click', function(event) {
  if (event.target.classList.contains('member-modal')) {
    event.target.style.display = 'none';
    document.body.style.overflow = 'auto';
  }
});

// Close modal with Escape key
document.addEventListener('keydown', function(event) {
  if (event.key === 'Escape') {
    const modals = document.querySelectorAll('.member-modal');
    modals.forEach(modal => {
      if (modal.style.display === 'flex') {
        modal.style.display = 'none';
      }
    });
    // Force restore scrolling
    document.body.style.overflow = 'auto';
    document.documentElement.style.overflow = 'auto';
  }
});
</script>