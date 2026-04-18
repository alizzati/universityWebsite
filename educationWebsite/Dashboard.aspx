<%@ Page Title="Dashboard" Language="C#" AutoEventWireup="true"
    CodeBehind="Dashboard.aspx.cs"
    Inherits="UniversitySystem.Pages.Dashboard" %>
<%@ Register Src="~/Controls/NavBar.ascx" TagName="NavBar" TagPrefix="uc" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Dashboard — UniSys</title>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:wght@300;400;500;700&display=swap" rel="stylesheet"/>
    <link href="~/Styles/NavBar.css" rel="stylesheet"/>
    <style>
        :root {
            --red:#C0001D; --red-deep:#8B0015; --red-light:#FFF0F2;
            --bg:#F7F7F5; --white:#FFFFFF;
            --border:#E5E5E0; --text:#1A1A1A; --muted:#6B6B65;
            --radius:14px;
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
        }

        /* ── Page Header ── */
        .page-header {
            background: linear-gradient(135deg, var(--red-deep) 0%, var(--red) 100%);
            padding: 2.5rem 2.5rem 2rem;
            position: relative; overflow: hidden;
        }
        .page-header::before {
            content: 'DASHBOARD';
            position: absolute; right: -1rem; top: 50%;
            transform: translateY(-50%);
            font-family: 'Bebas Neue', sans-serif; font-size: 7rem;
            color: rgba(255,255,255,.05); pointer-events: none;
            letter-spacing: 4px; white-space: nowrap;
        }
        .welcome-name {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 2.4rem; letter-spacing: 3px;
            color: #FFFFFF; line-height: 1;
        }
        .welcome-sub { color: rgba(255,255,255,.7); font-size: .9rem; margin-top: .4rem; }

        /* ── Main ── */
        .main { max-width: 960px; margin: 0 auto; padding: 2.5rem 1.5rem 5rem; }

        /* ── Section Label ── */
        .section-label {
            font-family: 'Bebas Neue', sans-serif; font-size: 1rem;
            letter-spacing: 2.5px; color: var(--red);
            display: flex; align-items: center; gap: .7rem;
            margin-bottom: 1.3rem;
        }
        .section-label::after { content: ''; flex: 1; height: 1px; background: var(--border); }

        /* ── Menu Grid ── */
        .menu-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1.2rem;
        }

        /* ── Menu Card ── */
        .menu-card {
            background: var(--white);
            border: 1.5px solid var(--border);
            border-radius: var(--radius);
            padding: 1.6rem 1.5rem;
            text-decoration: none;
            transition: border-color .2s, box-shadow .2s, transform .15s;
            display: block;
            position: relative;
            overflow: hidden;
        }
        .menu-card::before {
            content: '';
            position: absolute; left: 0; top: 0; bottom: 0;
            width: 0;
            background: var(--red);
            transition: width .2s;
        }
        .menu-card:hover {
            border-color: var(--red);
            box-shadow: 0 6px 24px rgba(192,0,29,.12);
            transform: translateY(-3px);
        }
        .menu-card:hover::before { width: 4px; }

        .card-icon { font-size: 2rem; margin-bottom: .9rem; display: block; }
        .card-title {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 1.1rem; letter-spacing: 2px;
            color: var(--text); margin-bottom: .6rem;
        }
        .card-links { list-style: none; padding: 0; }
        .card-links li { margin-bottom: .35rem; }
        .card-links a {
            font-size: .82rem; color: var(--muted);
            text-decoration: none;
            transition: color .18s;
            display: flex; align-items: center; gap: .3rem;
        }
        .card-links a::before { content: '›'; color: var(--red); font-weight: 700; }
        .card-links a:hover { color: var(--red); }

        /* ── Student Info Bar ── */
        .info-bar {
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 1.2rem 1.8rem;
            display: flex; align-items: center;
            gap: 2rem; flex-wrap: wrap;
            margin-bottom: 2rem;
            box-shadow: 0 1px 6px rgba(0,0,0,.05);
            position: relative; overflow: hidden;
        }
        .info-bar::before {
            content: ''; position: absolute; left: 0; top: 0; bottom: 0;
            width: 4px; background: var(--red);
        }
        .info-avatar {
            width: 44px; height: 44px;
            background: var(--red-light);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.3rem; flex-shrink: 0;
        }
        .info-name { font-weight: 700; font-size: 1rem; }
        .info-email { font-size: .78rem; color: var(--muted); margin-top: .15rem; }
        .info-session { margin-left: auto; font-size: .75rem; color: var(--muted); text-align: right; }

        /* ── Responsive ── */
        @media(max-width:700px) {
            .menu-grid { grid-template-columns: 1fr 1fr; }
        }
        @media(max-width:480px) {
            .menu-grid { grid-template-columns: 1fr; }
            .page-header { padding: 1.8rem 1rem; }
            .main { padding: 1.5rem 1rem 4rem; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <%-- ── NAVBAR ── --%>
    <uc:NavBar ID="ucNavBar" runat="server"/>

    <%-- ── PAGE HEADER ── --%>
    <div class="page-header">
        <div class="welcome-name">
            WELCOME, <asp:Label ID="lblName" runat="server" Text="STUDENT"/>
        </div>
        <div class="welcome-sub">
            UniSys Student Portal &mdash; Session: <%=DateTime.Now.ToString("dd MMM yyyy, HH:mm") %>
        </div>
    </div>

    <div class="main">

        <%-- Student Info Bar --%>
        <div class="info-bar">
            <div class="info-avatar">&#128100;</div>
            <div>
                <div class="info-name"><asp:Label ID="lblFullName" runat="server" Text="Student Name"/></div>
                <div class="info-email"><asp:Label ID="lblEmail" runat="server" Text=""/></div>
            </div>
            <div class="info-session">
                Student ID: <strong><asp:Label ID="lblStudentId" runat="server"/></strong>
            </div>
        </div>

        <div class="section-label">QUICK ACCESS</div>

        <%-- ── MENU GRID ── --%>
        <div class="menu-grid">

            <div class="menu-card">
                <span class="card-icon">&#128218;</span>
                <div class="card-title">Enrollment</div>
                <ul class="card-links">
                    <li><a href="~/OnlineEnrollment.aspx" runat="server">Course Enrollment</a></li>
                </ul>
            </div>

            <div class="menu-card">
                <span class="card-icon">&#10133;</span>
                <div class="card-title">Add / Drop</div>
                <ul class="card-links">
                    <li><a href="~/AddDrop.aspx" runat="server">Add / Drop Course</a></li>
                    <li><a href="~/AddDropHistory.aspx" runat="server">History</a></li>
                </ul>
            </div>

            <div class="menu-card">
                <span class="card-icon">&#9993;</span>
                <div class="card-title">Enquiry</div>
                <ul class="card-links">
                    <li><a href="~/ContactUs.aspx" runat="server">Contact Us</a></li>
                    <li><a href="~/TimetableMatching.aspx" runat="server">Timetable Matching</a></li>
                    <li><a href="~/TeachingEvaluation.aspx" runat="server">Teaching Evaluation</a></li>
                </ul>
            </div>

            <div class="menu-card">
                <span class="card-icon">&#128196;</span>
                <div class="card-title">Statement</div>
                <ul class="card-links">
                    <li><a href="~/StudentStatement.aspx" runat="server">Student Statement</a></li>
                    <li><a href="~/RegistrationSummary.aspx" runat="server">Registration Summary</a></li>
                </ul>
            </div>

            <div class="menu-card">
                <span class="card-icon">&#128179;</span>
                <div class="card-title">Payment</div>
                <ul class="card-links">
                    <li><a href="~/Payment.aspx" runat="server">Online Payment</a></li>
                    <li><a href="~/PaymentHistory.aspx" runat="server">Payment History</a></li>
                </ul>
            </div>

            <div class="menu-card">
                <span class="card-icon">&#9881;</span>
                <div class="card-title">Account</div>
                <ul class="card-links">
                    <li><a href="~/ChangePassword.aspx" runat="server">Change Password</a></li>
                    <li><a href="~/UpdateProfile.aspx" runat="server">Update Profile</a></li>
                    <li><a href="~/UpdateBank.aspx" runat="server">Update Bank Details</a></li>
                </ul>
            </div>

        </div>
    </div>

</form>
<script src="~/Scripts/NavBar.js"></script>
</body>
</html>
