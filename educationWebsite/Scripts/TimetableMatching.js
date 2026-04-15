// TimetableMatching.js

(function () {
    'use strict';

    /* ── Page loader ── */
    function initPageLoader() {
        var loader = document.getElementById('pageLoader');
        if (!loader) return;
        window.addEventListener('load', function () {
            setTimeout(function () {
                loader.classList.add('hidden');
                setTimeout(function () { loader.style.display = 'none'; }, 400);
            }, 500);
        });
    }

    /* ── Radio card: make entire card clickable and update ASP.NET radio ── */
    function initRadioCards() {
        var cards = document.querySelectorAll('.radio-card');
        cards.forEach(function (card) {
            card.addEventListener('click', function () {
                var radio = card.querySelector('input[type=radio]');
                if (radio) radio.checked = true;
                // Trigger change for IE compat
                if (radio && radio.dispatchEvent)
                    radio.dispatchEvent(new Event('change'));
            });
        });
    }

    /* ── Smooth scroll to timetable after postback ── */
    function scrollToResult() {
        var panel = document.getElementById('<%=pnlTimetable.ClientID %>') ||
                    document.querySelector('[id$="pnlTimetable"]');
        if (panel && panel.offsetParent !== null) {
            setTimeout(function () {
                panel.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }, 200);
        }
    }

    document.addEventListener('DOMContentLoaded', function () {
        initPageLoader();
        initRadioCards();
        scrollToResult();
    });

})();
