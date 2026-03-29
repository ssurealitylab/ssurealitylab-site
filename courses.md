---
layout: page
title: Courses - Reality Lab SSU | 강의 - 리얼리티랩 숭실대
description: Courses taught by Prof. Heewon Kim at Soongsil University. Computer Vision, Machine Learning, Deep Learning, Image Processing, Data Science courses. 숭실대학교 김희원 교수 강의.
keywords: Computer Vision course, Machine Learning course, Deep Learning, Image Processing, Data Science, Soongsil University courses, 숭실대학교, 숭실대, SSU, AI education, 컴퓨터비전, 기계학습, 영상처리, 딥러닝, 인공지능 강의, 김희원, Heewon Kim, Prof. Heewon Kim, 글로벌미디어학부, Global School of Media, IT대학, Reality Lab, 리얼리티랩, 학부 수업, 대학원 수업
image: /assets/img/header.png
---

<div class="courses-container">

<h2 class="section-title">학부 과정 (Undergraduate Courses)</h2>

<table class="course-table">
  <thead>
    <tr>
      <th>학년/학기</th>
      <th>과목명</th>
      <th>과목 내용</th>
    </tr>
  </thead>
  <tbody>
    {% for course in site.data.courses.undergraduate %}
    <tr>
      <td class="year-cell">{{ course.year }}</td>
      <td class="course-name">
        <strong>{{ course.name_ko }}</strong><br>
        <span class="course-name-en">{{ course.name_en }}</span>
      </td>
      <td class="course-content">
        {{ course.content | newline_to_br }}
      </td>
    </tr>
    {% endfor %}
  </tbody>
</table>

<h2 class="section-title graduate-title">대학원 과정 (Graduate Course)</h2>

<table class="course-table graduate-table">
  <thead>
    <tr>
      <th>과목명</th>
      <th>과목 내용</th>
    </tr>
  </thead>
  <tbody>
    {% for course in site.data.courses.graduate %}
    <tr>
      <td class="course-name">
        <strong>{{ course.name_ko }}</strong><br>
        <span class="course-name-en">{{ course.name_en }}</span>
      </td>
      <td class="course-content">
        {{ course.content | newline_to_br }}
      </td>
    </tr>
    {% endfor %}
  </tbody>
</table>

<div class="course-info">
  <p><strong>Location:</strong> {{ site.data.courses.info.location }}</p>
  <p><strong>Instructor:</strong> {{ site.data.courses.info.instructor }}</p>
</div>

</div>

<style>
.courses-container {
  padding: 40px 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.section-title {
  font-size: 1.8rem;
  font-weight: 700;
  color: #1e293b;
  margin-bottom: 30px;
  margin-top: 50px;
  padding-bottom: 10px;
  border-bottom: 2px solid #3b82f6;
}

.section-title:first-of-type {
  margin-top: 0;
}

.graduate-title {
  border-bottom-color: #8b5cf6;
}

.course-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 40px;
  background: white;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.course-table thead {
  background: #f8fafc;
  border-bottom: 2px solid #e2e8f0;
}

.course-table th {
  padding: 15px;
  text-align: left;
  font-weight: 600;
  color: #475569;
  font-size: 0.9rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.course-table td {
  padding: 20px 15px;
  border-bottom: 1px solid #e2e8f0;
  vertical-align: top;
}

.course-table tbody tr:last-child td {
  border-bottom: none;
}

.course-table tbody tr:hover {
  background: #f8fafc;
}

.year-cell {
  font-weight: 600;
  color: #3b82f6;
  white-space: nowrap;
  width: 130px;
  font-size: 0.95rem;
}

.course-name {
  width: 250px;
}

.course-name strong {
  font-size: 1.05rem;
  color: #1e293b;
  display: block;
  margin-bottom: 5px;
}

.course-name-en {
  color: #64748b;
  font-size: 0.9rem;
  font-style: italic;
}

.course-content {
  color: #475569;
  font-size: 0.95rem;
  line-height: 1.8;
}

.graduate-table thead {
  background: #faf5ff;
  border-bottom-color: #c084fc;
}

.graduate-table .year-cell {
  color: #8b5cf6;
}

.course-info {
  margin-top: 50px;
  padding: 25px;
  background: #f8fafc;
  border-left: 4px solid #3b82f6;
  border-radius: 4px;
}

.course-info p {
  margin: 10px 0;
  color: #475569;
  font-size: 0.95rem;
}

.course-info strong {
  color: #1e293b;
}

/* Responsive */
@media (max-width: 768px) {
  .courses-container {
    padding: 20px 10px;
  }

  .section-title {
    font-size: 1.4rem;
  }

  .course-table {
    font-size: 0.85rem;
  }

  .course-table th,
  .course-table td {
    padding: 12px 10px;
  }

  .year-cell {
    font-size: 0.85rem;
  }

  .course-name strong {
    font-size: 0.95rem;
  }

  .course-name-en {
    font-size: 0.8rem;
  }

  .course-content {
    font-size: 0.85rem;
  }
}

@media (max-width: 576px) {
  .course-table thead {
    display: none;
  }

  .course-table,
  .course-table tbody,
  .course-table tr,
  .course-table td {
    display: block;
    width: 100%;
  }

  .course-table tr {
    margin-bottom: 20px;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    overflow: hidden;
  }

  .course-table td {
    border-bottom: 1px solid #e2e8f0;
    padding: 15px;
  }

  .course-table td:last-child {
    border-bottom: none;
  }

  .year-cell {
    background: #eff6ff;
    font-size: 0.9rem;
    text-align: center;
    padding: 12px;
  }

  .course-name {
    width: 100%;
    background: #f8fafc;
  }
}
</style>
