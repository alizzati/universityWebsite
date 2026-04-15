<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="NavBar.ascx.cs" Inherits="UniversitySystem.Controls.NavBar" %>

<nav class="site-nav">
    <div class="nav-logo">UNIV<span class="nav-dot">&middot;</span>SYS</div>

    <button class="nav-toggle" id="navToggle" onclick="toggleMobileNav()" aria-label="Toggle menu">
        <span></span><span></span><span></span>
    </button>

    <ul class="nav-links" id="navLinks">

        <%-- 1. Online Enrollment --%>
        <li class="has-dropdown">
            <a href="#" class='nav-parent <%=ActiveClass("Enrollment") %>'>
                Enrollment <svg class="nav-chevron" viewBox="0 0 10 6"><path d="M1 1l4 4 4-4" stroke="currentColor" stroke-width="1.5" fill="none" stroke-linecap="round"/></svg>
            </a>
            <ul class="dropdown">
                <li><a href="/Enrollment.aspx" class='<%=ActiveClass("Enrollment") %>'>&#127979; Course Enrolment</a></li>
            </ul>
        </li>

        <%-- 2. Add/Drop --%>
        <li class="has-dropdown">
            <a href="#" class='nav-parent <%=ActiveClass("AddDrop") %>'>
                Add / Drop <svg class="nav-chevron" viewBox="0 0 10 6"><path d="M1 1l4 4 4-4" stroke="currentColor" stroke-width="1.5" fill="none" stroke-linecap="round"/></svg>
            </a>
            <ul class="dropdown">
                <li><a href="/AddDrop.aspx"        class='<%=ActiveClass("AddDrop") %>'>&#43; Course Add/Drop</a></li>
                <li><a href="/AddDropHistory.aspx" class='<%=ActiveClass("AddDropHistory") %>'>&#128203; Add/Drop History</a></li>
            </ul>
        </li>

        <%-- 3. Enquiry --%>
        <li class="has-dropdown">
            <a href="#" class='nav-parent <%=ActiveClass("Enquiry") %>'>
                Enquiry <svg class="nav-chevron" viewBox="0 0 10 6"><path d="M1 1l4 4 4-4" stroke="currentColor" stroke-width="1.5" fill="none" stroke-linecap="round"/></svg>
            </a>
            <ul class="dropdown">
                <li><a href="/ContactUs.aspx"          class='<%=ActiveClass("ContactUs") %>'>&#128222; Contact Us</a></li>
                <li><a href="/TimetableMatching.aspx"  class='<%=ActiveClass("TimetableMatching") %>'>&#128197; Timetable Matching</a></li>
                <li><a href="/TeachingEvaluation.aspx" class='<%=ActiveClass("TeachingEvaluation") %>'>&#11088; Student Evaluation of Teaching</a></li>
            </ul>
        </li>

        <%-- 4. Statement --%>
        <li class="has-dropdown">
            <a href="#" class='nav-parent <%=ActiveClass("Statement") %>'>
                Statement <svg class="nav-chevron" viewBox="0 0 10 6"><path d="M1 1l4 4 4-4" stroke="currentColor" stroke-width="1.5" fill="none" stroke-linecap="round"/></svg>
            </a>
            <ul class="dropdown">
                <li><a href="/StudentStatement.aspx"    class='<%=ActiveClass("StudentStatement") %>'>&#128196; Student Statement</a></li>
                <li><a href="/RegistrationSummary.aspx" class='<%=ActiveClass("RegistrationSummary") %>'>&#128203; Registration Summary / Class Timetable</a></li>
            </ul>
        </li>

        <%-- 5. Payment --%>
        <li class="has-dropdown">
            <a href="#" class='nav-parent <%=ActiveClass("Payment") %>'>
                Payment <svg class="nav-chevron" viewBox="0 0 10 6"><path d="M1 1l4 4 4-4" stroke="currentColor" stroke-width="1.5" fill="none" stroke-linecap="round"/></svg>
            </a>
            <ul class="dropdown">
                <li><a href="/Payment.aspx"            class='<%=ActiveClass("Payment") %>'>&#128181; Payment</a></li>
                <li><a href="/PaymentHistory.aspx"     class='<%=ActiveClass("PaymentHistory") %>'>&#128200; Online Payment History / Receipt</a></li>
                <li><a href="/Invoice.aspx"            class='<%=ActiveClass("Invoice") %>'>&#129534; Invoice and Adjustment Note</a></li>
            </ul>
        </li>

        <%-- 6. Account --%>
        <li class="has-dropdown">
            <a href="#" class='nav-parent <%=ActiveClass("Account") %>'>
                <span class="nav-user-name"><%=StudentName %></span>
                <svg class="nav-chevron" viewBox="0 0 10 6"><path d="M1 1l4 4 4-4" stroke="currentColor" stroke-width="1.5" fill="none" stroke-linecap="round"/></svg>
            </a>
            <ul class="dropdown dropdown-right">
                <li><a href="/ChangePassword.aspx"  class='<%=ActiveClass("ChangePassword") %>'>&#128274; Change Password</a></li>
                <li><a href="/UpdateProfile.aspx"   class='<%=ActiveClass("UpdateProfile") %>'>&#128100; Update Profile</a></li>
                <li><a href="/UpdateBank.aspx"      class='<%=ActiveClass("UpdateBank") %>'>&#127981; Update Bank Details</a></li>
                <li class="dropdown-divider"></li>
                <li><a href="/Logout.aspx" class="nav-logout-item">&#128682; Logout</a></li>
            </ul>
        </li>

    </ul>
</nav>
