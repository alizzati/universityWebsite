// TeachingEvaluation.js
// Handles: course card selection, form reveal, gauge animation, submit validation

(function () {
    'use strict';

    /* ── Gauge animation on page load ──────────────────────────────── */
    function animateGauge() {
        var arc = document.getElementById('gaugeArc');
        var fill = document.getElementById('progressFill');

        // pctValue is injected by ASPX inline: window.evalPct
        var pct = window.evalPct || 0;

        // Gauge semicircle dasharray = 126
        var offset = 126 - (126 * pct / 100);

        setTimeout(function () {
            if (arc) {
                arc.style.transition = 'stroke-dashoffset .8s ease';
                arc.setAttribute('stroke-dashoffset', offset);
            }
            if (fill) {
                fill.style.width = pct + '%';
            }
        }, 300);

        // Show completed banner if 100%
        if (pct >= 100) {
            var banner = document.getElementById('completedBanner');
            var section = document.getElementById('evaluationSection');
            if (banner) banner.classList.add('visible');
            if (section) section.style.display = 'none';
        }
    }

    /* ── Select course card ─────────────────────────────────────────── */
    window.selectCourse = function (el, courseId, courseCode, courseName) {
        // Deselect all
        var cards = document.querySelectorAll('.course-card:not(.done)');
        cards.forEach(function (c) { c.classList.remove('selected'); });

        // Select clicked
        el.classList.add('selected');

        // Store courseId in hidden field
        var hf = document.getElementById(window.hfCourseIdClientId);
        if (hf) hf.value = courseId;

        // Update form header
        var titleEl = document.getElementById('selectedCourseName');
        if (titleEl) titleEl.textContent = courseCode + ' \u2014 ' + courseName;

        // Show form card
        var formCard = document.getElementById('evalForm');
        if (formCard) {
            formCard.classList.add('visible');
            setTimeout(function () {
                formCard.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }, 50);
        }
    };

    /* ── Submit validation ──────────────────────────────────────────── */
    function setupSubmitValidation() {
        var btn = document.getElementById(window.btnSubmitClientId);
        if (!btn) return;

        btn.addEventListener('click', function (e) {
            // Check course selected
            var hf = document.getElementById(window.hfCourseIdClientId);
            if (!hf || !hf.value || hf.value === '0') {
                e.preventDefault();
                alert('Sila pilih kursus terlebih dahulu.');
                return;
            }

            // Check all likert questions answered
            var form = document.getElementById('evalForm');
            if (!form) return;

            var radios = form.querySelectorAll('input[type="radio"]');
            var groups = {};
            radios.forEach(function (r) {
                groups[r.name] = groups[r.name] || [];
                groups[r.name].push(r);
            });

            var allAnswered = true;
            var groupNames = Object.keys(groups);
            for (var i = 0; i < groupNames.length; i++) {
                var group = groups[groupNames[i]];
                var answered = group.some(function (r) { return r.checked; });
                if (!answered) {
                    allAnswered = false;
                    break;
                }
            }

            if (!allAnswered) {
                e.preventDefault();
                alert('Sila jawab semua soalan sebelum menghantar.');
            }
        });
    }

    /* ── Init ───────────────────────────────────────────────────────── */
    document.addEventListener('DOMContentLoaded', function () {
        animateGauge();
        setupSubmitValidation();
    });

})();