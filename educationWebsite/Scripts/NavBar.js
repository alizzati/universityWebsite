// NavBar.js — Dropdown & Mobile hamburger toggle

(function () {
    'use strict';

    /* ── Mobile hamburger toggle ── */
    window.toggleMobileNav = function () {
        var links = document.getElementById('navLinks');
        if (links) links.classList.toggle('open');
    };

    /* ── Mobile: tap dropdown parent to expand ── */
    document.addEventListener('DOMContentLoaded', function () {
        var parents = document.querySelectorAll('.site-nav .has-dropdown > .nav-parent');
        parents.forEach(function (parent) {
            parent.addEventListener('click', function (e) {
                // Only intercept on mobile (nav-links visible as column)
                var links = document.getElementById('navLinks');
                if (!links || !links.classList.contains('open')) return;

                e.preventDefault();
                var li = parent.closest('.has-dropdown');
                var isOpen = li.classList.contains('mobile-open');

                // Close all
                document.querySelectorAll('.has-dropdown').forEach(function (d) {
                    d.classList.remove('mobile-open');
                });

                if (!isOpen) li.classList.add('mobile-open');
            });
        });

        /* ── Close mobile menu on outside click ── */
        document.addEventListener('click', function (e) {
            var nav = document.querySelector('.site-nav');
            var links = document.getElementById('navLinks');
            if (!nav || !links) return;
            if (!nav.contains(e.target)) {
                links.classList.remove('open');
                document.querySelectorAll('.has-dropdown').forEach(function (d) {
                    d.classList.remove('mobile-open');
                });
            }
        });
    });

})();