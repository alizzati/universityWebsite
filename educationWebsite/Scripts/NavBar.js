// NavBar.js — Mobile hamburger toggle
// Include di setiap halaman yang pakai NavBar.ascx

function toggleMobileNav() {
    var links = document.getElementById('navLinks');
    if (links) {
        links.classList.toggle('open');
    }
}

// Tutup menu bila klik luar
document.addEventListener('click', function (e) {
    var nav    = document.querySelector('.site-nav');
    var toggle = document.getElementById('navToggle');
    var links  = document.getElementById('navLinks');

    if (!nav || !links) return;
    if (!nav.contains(e.target)) {
        links.classList.remove('open');
    }
});
