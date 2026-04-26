---
layout: page
title: Domestic Publications
---

<!-- Publications Header -->
<section class="publications-header text-center py-5">
  <div class="container">
    <h1 class="section-heading text-uppercase">Domestic Publications</h1>
    <h3 class="section-subheading text-muted">Korean research contributions and achievements</h3>
    <p style="color: #6c757d; font-size: 0.85rem; margin-top: 10px;">Click on a publication to view detailed information</p>
  </div>
</section>

<!-- Publications Content -->
<section class="publications-content py-5">
  <div class="container">
    <div class="category-section mb-5">
      <div class="row">
        <div class="col-12">
          <div class="category-header d-flex align-items-center mb-4">
            <div class="category-badge domestic-badge">{{ site.data.domestic_publications.year_range }}</div>
            <div class="category-line flex-grow-1"></div>
          </div>
        </div>
      </div>
      <div class="row" id="domestic-pub-list">
        {% for pub in site.data.domestic_publications.publications %}
        <div class="col-12 mb-3">
          <div class="publication-list-item" data-pub-id="{{ pub.id }}">
            <div class="publication-badge domestic-badge">{{ pub.venue }}</div>
            <h5 class="list-title">{{ pub.title }}</h5>
            <p class="list-authors">{{ pub.authors }}</p>
          </div>
        </div>
        {% endfor %}
      </div>
    </div>
  </div>
</section>

<!-- Research Focus -->
<section class="py-5 bg-light">
  <div class="container text-center">
    <div class="row">
      <div class="col-lg-10 mx-auto">
        <h3 class="text-uppercase mb-4">Domestic Research Focus</h3>
        <div class="row">
          <div class="col-md-6">
            <h5>Korean Conferences</h5>
            <ul class="list-unstyled text-left">
              <li><i class="fas fa-users text-primary"></i> KCCV (Korean Conference on Computer Vision)</li>
              <li><i class="fas fa-brain text-success"></i> KIISE (Korea Information Science Society)</li>
              <li><i class="fas fa-robot text-warning"></i> KRoC (Korea Robotics Conference)</li>
              <li><i class="fas fa-graduation-cap text-info"></i> KIPS (Korea Information Processing Society)</li>
            </ul>
          </div>
          <div class="col-md-6">
            <h5>Korean Journals</h5>
            <ul class="list-unstyled text-left">
              <li><i class="fas fa-file-alt text-primary"></i> JKIISE (Journal of KIISE)</li>
              <li><i class="fas fa-file-alt text-success"></i> JKIPS (Journal of KIPS)</li>
              <li><i class="fas fa-file-alt text-warning"></i> JKCGS (Journal of Korea Computer Graphics Society)</li>
              <li><i class="fas fa-file-alt text-info"></i> JKROS (Journal of Korea Robotics Society)</li>
            </ul>
          </div>
        </div>
        <hr class="my-4">
        <p class="text-muted">
          <strong>Reality Lab</strong> | Global School of Media, College of IT, Soongsil University<br>
          <strong>Principal Investigator:</strong> Prof. Heewon Kim
        </p>
      </div>
    </div>
  </div>
</section>

<style>
/* Publications Content Styles */
.publications-header {
  background: transparent;
}

/* Category Section */
.category-section {
  margin-bottom: 4rem;
}

.category-header {
  margin-bottom: 2rem;
}

.category-badge {
  color: white;
  padding: 12px 24px;
  border-radius: 50px;
  font-size: 1.3rem;
  font-weight: bold;
  margin-right: 20px;
  min-width: 140px;
  text-align: center;
}

.domestic-badge {
  background: linear-gradient(135deg, #27ae60, #229954);
  box-shadow: 0 4px 15px rgba(39, 174, 96, 0.3);
}

.category-line {
  height: 3px;
  background: linear-gradient(90deg, #27ae60, rgba(39, 174, 96, 0.1));
  border-radius: 2px;
}

/* Publication Cards */
.publication-card {
  border: none;
  border-radius: 15px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  height: 100%;
  background: white;
  border: 3px solid transparent;
  position: relative;
}

.publication-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.15);
}

/* Category-based Border Colors */
.challenge-card {
  border-color: #ffd700 !important;
}

.challenge-card:hover {
  border-color: #ffed4a !important;
  box-shadow: 0 8px 30px rgba(255, 215, 0, 0.3);
}

.paper-card {
  border-color: #3498db !important;
}

.paper-card:hover {
  border-color: #5dade2 !important;
  box-shadow: 0 8px 30px rgba(52, 152, 219, 0.3);
}

.research-card {
  border-color: #9b59b6 !important;
}

.research-card:hover {
  border-color: #bb8fce !important;
  box-shadow: 0 8px 30px rgba(155, 89, 182, 0.3);
}

/* Card Layout - All Uniform */
.publication-card .card-title {
  font-size: 1.1rem;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 8px;
}

.publication-card .card-subtitle {
  font-size: 0.85rem;
  color: #7f8c8d;
  margin-bottom: 10px;
  font-weight: 500;
}

.publication-card .card-text {
  font-size: 0.9rem;
  color: #5a6c7d;
  line-height: 1.4;
}

/* Publication Badge */
.publication-badge {
  position: absolute;
  top: 10px;
  right: 10px;
  background: transparent;
  color: #27ae60;
  border: 2px solid #27ae60;
  padding: 6px 12px;
  border-radius: 20px;
  font-weight: bold;
  font-size: 0.8rem;
}

/* Placeholder Card */
.placeholder-card {
  border: 2px dashed #bdc3c7 !important;
  background: #f8f9fa;
}

.placeholder-img {
  height: 150px;
  background: #ecf0f1;
  border-radius: 8px;
  margin: 15px;
}

/* Card Body Styling */
.card-body {
  padding: 1.25rem;
}

/* Publication List Item */
.publication-list-item {
  background: white;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  padding: 20px 24px;
  transition: all 0.3s ease;
  cursor: pointer;
  position: relative;
  min-height: 90px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.publication-list-item:hover {
  border-color: #27ae60;
  box-shadow: 0 4px 12px rgba(39, 174, 96, 0.15);
  transform: translateY(-2px);
}

.publication-list-item .publication-badge {
  position: absolute;
  top: 12px;
  right: 16px;
}

.publication-list-item .list-title {
  font-size: 1.1rem;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 8px;
  padding-right: 120px;
  line-height: 1.4;
}

.publication-list-item .list-authors {
  font-size: 0.95rem;
  color: #7f8c8d;
  margin-bottom: 0;
  font-weight: 400;
  line-height: 1.4;
}

/* External Links */
.external-links {
  position: absolute;
  right: 16px;
  top: 45px;
  display: flex;
  gap: 10px;
  z-index: 5;
}

.external-icon-link {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  text-decoration: none;
  transition: all 0.3s ease;
  opacity: 1;
}

.external-icon-link:hover {
  transform: scale(1.15);
}

.external-icon-link i {
  font-size: 1.3rem;
}

.external-icon-link.pdf-link {
  color: #dc3545;
}

.external-icon-link.pdf-link:hover {
  color: #c82333;
}

.external-icon-link.website-link {
  color: #28a745;
}

.external-icon-link.website-link:hover {
  color: #218838;
}

.external-icon-link.github-link {
  color: #333;
}

.external-icon-link.github-link:hover {
  color: #000;
}

/* Responsive Design */
@media (max-width: 768px) {
  .category-badge {
    font-size: 1.1rem;
    padding: 10px 20px;
    min-width: 120px;
  }
  
  .placeholder-img {
    height: 120px;
    margin: 10px;
  }
  
  .card-body {
    padding: 1rem;
  }
}

@media (max-width: 576px) {
  .category-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .category-badge {
    margin-bottom: 15px;
    margin-right: 0;
  }
  
  .category-line {
    height: 2px;
  }
}
</style>