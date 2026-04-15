// TeachingEvaluation.js
// Handles: course card selection, form reveal, gauge animation, submit validation

(function () {
    'use strict';

    /* ── Gauge animation on page load ──────────────────────────────── */
    function animateGauge() {
        var arc = document.getElementById('gaugeArc');
        var fill = document.getElementById('progressFill');
        var pct = window.evalPct || 0;

        // Gauge semicircle dasharray = 126
        var offset = 126 - (126 * pct / 100);

        // Determine color: green if > 50%, red otherwise
        var isGreen = pct > 50;
        var strokeColor = isGreen ? '#1A7A47' : '#C0001D';

        setTimeout(function () {
            if (arc) {
                arc.style.transition = 'stroke-dashoffset .8s ease, stroke .6s ease';
                arc.setAttribute('stroke-dashoffset', offset);
                arc.setAttribute('stroke', strokeColor);
            }
            if (fill) {
                fill.style.transition = 'width .6s ease, background .6s ease';
                fill.style.width = pct + '%';
                if (isGreen) fill.classList.add('green');
                else fill.classList.remove('green');
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
        var cards = document.querySelectorAll('.course-card:not(.done)');
        cards.forEach(function (c) { c.classList.remove('selected'); });

        el.classList.add('selected');

        var hf = document.getElementById(window.hfCourseIdClientId);
        if (hf) hf.value = courseId;

        var titleEl = document.getElementById('selectedCourseName');
        if (titleEl) titleEl.textContent = courseCode + ' \u2014 ' + courseName;

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
            var hf = document.getElementById(window.hfCourseIdClientId);
            if (!hf || !hf.value || hf.value === '0') {
                e.preventDefault();
                alert('Sila pilih kursus terlebih dahulu.');
                return;
            }

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
                var answered = groups[groupNames[i]].some(function (r) { return r.checked; });
                if (!answered) { allAnswered = false; break; }
            }

            if (!allAnswered) {
                e.preventDefault();
                alert('Sila jawab semua soalan sebelum menghantar.');
            }
        });
    }

    /* ── Page loader ────────────────────────────────────────────────── */
    function initPageLoader() {
        var loader = document.getElementById('pageLoader');
        if (!loader) return;
        window.addEventListener('load', function () {
            setTimeout(function () {
                loader.classList.add('hidden');
                setTimeout(function () { loader.style.display = 'none'; }, 400);
            }, 600);
        });
    }

    /* ── Init ───────────────────────────────────────────────────────── */
    document.addEventListener('DOMContentLoaded', function () {
        animateGauge();
        setupSubmitValidation();
        initPageLoader();
    });

})();