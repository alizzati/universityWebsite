<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="NavBar.ascx.cs" Inherits="UniversitySystem.Controls.NavBar" %>

<nav class="site-nav">
    <div class="nav-logo">UNIV<span class="nav-dot">&middot;</span>SYS</div>
    <button class="nav-toggle" id="navToggle" onclick="toggleMobileNav()" aria-label="Toggle menu">
        <span></span><span></span><span></span>
    </button>
    <ul class="nav-links" id="navLinks">
        <li><a href="/Enquiry.aspx"         class='<%=ActiveClass("Enquiry") %>'>Enquiry</a></li>
        <li><a href="/Enrollment.aspx"      class='<%=ActiveClass("Enrollment") %>'>Enrollment</a></li>
        <li><a href="/AddDrop.aspx"         class='<%=ActiveClass("AddDrop") %>'>Add / Drop</a></li>
        <li><a href="/TimetableMatching.aspx" class='<%=ActiveClass("TimetableMatching") %>'>Timetable</a></li>
        <li><a href="/TeachingEvaluation.aspx" class='<%=ActiveClass("TeachingEvaluation") %>'>Evaluation</a></li>
        <li>
            <div class="nav-user">
                <span class="nav-user-name"><%=StudentName %></span>
                <a href="/Logout.aspx" class="nav-logout">Logout</a>
            </div>
        </li>
    </ul>
</nav>
