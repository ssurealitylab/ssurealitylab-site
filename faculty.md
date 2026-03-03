---
layout: page
title: Faculty - Reality Lab | 교수진 - 리얼리티랩
description: Prof. Heewon Kim leads Reality Lab at Soongsil University, specializing in Computer Vision, Deep Learning, and Embodied AI. 숭실대학교 김희원 교수.
keywords: Prof. Heewon Kim, 김희원, 김희원 교수, Soongsil University, 숭실대학교, 숭실대, SSU, Reality Lab, 리얼리티랩, AI소프트웨어학부, School of AI Software, 글로벌미디어학부, Global School of Media, AI대학, College of AI, IT대학, College of IT, Computer Vision, Deep Learning, Embodied AI, AI professor, 인공지능 교수, CVPR, AAAI, Seoul National University, 서울대학교
---

# Faculty

<div class="faculty-container">
  {% for member in site.data.members.faculty %}
  <div class="faculty-card">
    <div class="external-icons-container">
      {% if member.bio and member.bio != "" %}
        <a href="{{ member.bio }}" target="_blank" class="external-icon-link bio-icon" title="Bio">
          <i class="fas fa-user"></i>
          <span class="icon-label">BIO</span>
        </a>
      {% endif %}
      {% if member.scholar and member.scholar != "" %}
        <a href="{{ member.scholar }}" target="_blank" class="external-icon-link scholar-icon" title="Google Scholar Profile">
          <i class="fas fa-graduation-cap"></i>
          <span class="icon-label">GOOGLE SCHOLAR</span>
        </a>
      {% endif %}
    </div>

    <div class="member-photo">
      <img src="{{ member.photo }}" alt="{{ member.name }}" onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDIwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIyMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjZjNmNGY2Ii8+CjxjaXJjbGUgY3g9IjEwMCIgY3k9IjgwIiByPSIzMCIgZmlsbD0iIzllYTNhOCIvPgo8cGF0aCBkPSJNNjAgMTYwYzAtMjIuMDkgMTcuOTEtNDAgNDAtNDBzNDAgMTcuOTEgNDAgNDB2MjBINjB2LTIweiIgZmlsbD0iIzllYTNhOCIvPgo8L3N2Zz4K'">
    </div>
    <div class="member-info">
      <h3 class="member-name">{{ member.name }}</h3>
      {% if member.name_ko %}
      <p class="member-name-ko">{{ member.name_ko }}</p>
      {% endif %}
      <p class="member-position">{{ member.position }}</p>
      <p class="member-affiliation">{{ member.affiliation }}</p>
      {% if member.affiliation_detail %}
      <div class="member-affiliation-detail">
        {% for detail in member.affiliation_detail %}
          {{ detail }}<br>
        {% endfor %}
      </div>
      {% endif %}
      {% if member.phone %}
      <p class="member-contact">
        <i class="fas fa-phone"></i> {{ member.phone }}
      </p>
      {% endif %}
      {% if member.email %}
      <p class="member-email">
        <i class="fas fa-envelope"></i>
        <span>{{ member.email }}</span>
      </p>
      {% endif %}

      <div class="member-social">
        {% if member.github and member.github != "" %}
        <a href="{{ member.github }}" target="_blank" title="GitHub">
          <i class="fab fa-github"></i>
        </a>
        {% endif %}
        {% if member.linkedin and member.linkedin != "" %}
        <a href="{{ member.linkedin }}" target="_blank" title="LinkedIn">
          <i class="fab fa-linkedin"></i>
        </a>
        {% endif %}
      </div>
    </div>
  </div>
  {% endfor %}
</div>

<style>
.faculty-container {
  display: flex;
  flex-direction: column;
  gap: 30px;
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

.faculty-card {
  display: flex;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  padding: 30px;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  position: relative;
}

.faculty-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.external-icons-container {
  position: absolute;
  top: 15px;
  right: 15px;
  display: flex;
  gap: 10px;
  z-index: 10;
}

.external-icon-link {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  text-decoration: none;
  transition: all 0.3s ease;
  padding: 6px 8px;
}

.external-icon-link i {
  font-size: 1.8rem;
  transition: transform 0.3s ease;
}

.external-icon-link .icon-label {
  font-size: 0.55rem;
  font-weight: 600;
  letter-spacing: 0.3px;
  opacity: 0.8;
  transition: opacity 0.3s ease;
}

.external-icon-link.bio-icon i {
  color: #28a745;
}

.external-icon-link.bio-icon .icon-label {
  color: #28a745;
}

.external-icon-link.bio-icon:hover i {
  transform: scale(1.1);
}

.external-icon-link.bio-icon:hover .icon-label {
  opacity: 1;
}

.external-icon-link.scholar-icon i {
  color: #4285f4;
}

.external-icon-link.scholar-icon .icon-label {
  color: #4285f4;
}

.external-icon-link.scholar-icon:hover i {
  transform: scale(1.1);
}

.external-icon-link.scholar-icon:hover .icon-label {
  opacity: 1;
}

.member-photo {
  flex-shrink: 0;
  margin-right: 30px;
}

.member-photo img {
  width: 150px;
  height: 150px;
  border-radius: 50%;
  object-fit: cover;
  border: 4px solid #f8f9fa;
}

.member-info {
  flex: 1;
}

.member-name {
  font-size: 1.8rem;
  font-weight: 700;
  color: #2c3e50;
  margin-bottom: 5px;
}

.member-name-ko {
  font-size: 1.2rem;
  color: #7f8c8d;
  margin-bottom: 10px;
  font-style: italic;
}

.member-position {
  font-size: 1.2rem;
  color: #3498db;
  font-weight: 600;
  margin-bottom: 10px;
}

.member-affiliation {
  font-size: 1rem;
  color: #6c757d;
  margin-bottom: 10px;
  line-height: 1.5;
  font-weight: 600;
}

.member-affiliation-detail {
  font-size: 0.95rem;
  color: #6c757d;
  margin-bottom: 15px;
  line-height: 1.6;
}

.member-contact {
  font-size: 1rem;
  color: #2c3e50;
  margin-bottom: 10px;
}

.member-contact i {
  color: #3498db;
  margin-right: 8px;
}

.member-email {
  font-size: 1rem;
  margin-bottom: 20px;
}

.member-email i {
  color: #3498db;
  margin-right: 8px;
}

.member-email span {
  color: #2c3e50;
}

.member-social {
  display: flex;
  gap: 15px;
}

.member-social a {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
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

@media (max-width: 768px) {
  .faculty-card {
    flex-direction: column;
    text-align: center;
    padding: 20px;
  }
  
  .member-photo {
    margin-right: 0;
    margin-bottom: 20px;
    align-self: center;
  }
  
  .member-photo img {
    width: 120px;
    height: 120px;
  }
  
  .member-name {
    font-size: 1.5rem;
  }
}
</style>