<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="login.aspx.cs" Inherits="UniversitySystem.login" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Student Login — UniSys</title>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:wght@300;400;500;700&display=swap" rel="stylesheet"/>
    <style>
        :root {
            --red: #C0001D; --red-deep: #8B0015; --red-light: #FFF0F2;
            --red-glow: rgba(192,0,29,.12);
            --bg: #F7F7F5; --white: #FFFFFF;
            --border: #E5E5E0; --text: #1A1A1A; --muted: #6B6B65;
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            display: grid;
            grid-template-columns: 1fr 1fr;
        }

        /* ASP.NET wraps everything in a <form> — make it display:contents so grid still works */
        body > form { display: contents; }

        /* ── LEFT PANEL ── */
        .left-panel {
            background: linear-gradient(150deg, var(--red-deep) 0%, var(--red) 100%);
            display: flex; flex-direction: column;
            justify-content: space-between;
            padding: 3.5rem; position: relative; overflow: hidden;
        }
        .left-panel::before {
            content: 'PORTAL';
            position: absolute; bottom: -1.5rem; left: -1rem;
            font-family: 'Bebas Neue', sans-serif; font-size: 9rem;
            color: rgba(255,255,255,.06); letter-spacing: 6px;
            white-space: nowrap; pointer-events: none; line-height: 1;
        }
        .left-logo {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 2rem; letter-spacing: 3px; color: #FFFFFF;
        }
        .left-logo span { color: rgba(255,255,255,.3); }

        .left-headline h1 {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 3.8rem; letter-spacing: 4px;
            line-height: 1.0; color: #FFFFFF; margin-bottom: .8rem;
        }
        .left-headline p {
            color: rgba(255,255,255,.7); font-size: .9rem; line-height: 1.6; max-width: 320px;
        }
        .left-pills {
            display: flex; flex-wrap: wrap; gap: .5rem; margin-top: 1.4rem;
        }
        .left-pill {
            background: rgba(255,255,255,.12); color: rgba(255,255,255,.85);
            border: 1px solid rgba(255,255,255,.2); border-radius: 50px;
            padding: .3rem .9rem; font-size: .75rem; font-weight: 500;
        }
        .left-footer { color: rgba(255,255,255,.3); font-size: .72rem; }

        /* ── RIGHT PANEL ── */
        .right-panel {
            display: flex; align-items: center;
            justify-content: center; padding: 2.5rem;
        }
        .form-box { width: 100%; max-width: 400px; }

        .form-box h2 {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 2.2rem; letter-spacing: 2.5px; color: var(--text); margin-bottom: .3rem;
        }
        .subtitle { font-size: .85rem; color: var(--muted); margin-bottom: 2rem; line-height: 1.5; }

        /* Notice banners */
        .notice {
            border-radius: 8px; padding: .8rem 1rem; font-size: .82rem;
            margin-bottom: 1.2rem; display: flex; align-items: flex-start;
            gap: .55rem; line-height: 1.5;
        }
        .notice-session { background: #FFF5F6; border: 1px solid #FFCCD2; color: #8B0015; }
        .notice-timeout { background: #FFFBF0; border: 1px solid #F0E0A0; color: #7A6000; }

        /* Alert */
        .alert-block {
            border-radius: 8px; padding: .8rem 1rem; font-size: .83rem;
            margin-bottom: 1.2rem; display: block;
        }
        .alert-error   { background: #FFF5F6; border: 1px solid #FFCCD2; color: #C0001D; }
        .alert-success { background: #F0FFF7; border: 1px solid #B7EBD0; color: #1A7A47; }

        /* Fields */
        .field { margin-bottom: 1.2rem; }
        .field label {
            display: block; font-size: .72rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: .7px;
            color: var(--muted); margin-bottom: .42rem;
        }
        .field input {
            width: 100%; padding: .85rem 1rem;
            border: 1.5px solid var(--border); border-radius: 9px;
            font-family: 'DM Sans', sans-serif; font-size: .9rem;
            color: var(--text); background: var(--bg);
            transition: border-color .2s, background .2s;
        }
        .field input:focus {
            outline: none; border-color: var(--red);
            background: var(--white); box-shadow: 0 0 0 3px var(--red-glow);
        }

        /* Password wrapper */
        .pw-wrap { position: relative; }
        .pw-wrap input { padding-right: 3.2rem; }
        .pw-toggle {
            position: absolute; right: 1rem; top: 50%;
            transform: translateY(-50%);
            background: none; border: none; cursor: pointer;
            color: var(--muted); font-size: .9rem; padding: 0;
            transition: color .2s; line-height: 1;
        }
        .pw-toggle:hover { color: var(--red); }

        /* Submit button */
        .btn-login {
            display: block; width: 100%; padding: 1rem;
            background: var(--red); color: #FFFFFF;
            font-family: 'Bebas Neue', sans-serif; font-size: 1.15rem; letter-spacing: 3px;
            border: none; border-radius: 10px; cursor: pointer; margin-top: .4rem;
            transition: background .2s, transform .15s, box-shadow .2s;
        }
        .btn-login:hover { background: #A8001A; transform: translateY(-1px); box-shadow: 0 6px 20px rgba(192,0,29,.28); }
        .btn-login:active { transform: translateY(0); }

        /* Divider */
        .divider {
            display: flex; align-items: center; gap: .8rem;
            margin: 1.5rem 0; color: var(--muted); font-size: .75rem;
        }
        .divider::before, .divider::after { content: ''; flex: 1; height: 1px; background: var(--border); }

        /* Register link */
        .register-row { text-align: center; font-size: .84rem; color: var(--muted); }
        .register-row a { color: var(--red); font-weight: 700; text-decoration: none; transition: color .2s; }
        .register-row a:hover { color: var(--red-deep); text-decoration: underline; }

        /* Responsive */
        @media (max-width: 768px) {
            body { grid-template-columns: 1fr; }
            .left-panel { display: none; }
            .right-panel { padding: 2rem 1.5rem; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <%-- LEFT DECORATIVE PANEL --%>
    <div class="left-panel">
        <div class="left-logo">UNIV<span>&middot;</span>SYS</div>
        <div class="left-headline">
            <h1>STUDENT<br/>PORTAL</h1>
            <p>Access your academic records, payment history, timetable, evaluation and more — all in one place.</p>
            <div class="left-pills">
                <span class="left-pill">&#128197; Timetable</span>
                <span class="left-pill">&#11088; Evaluation</span>
                <span class="left-pill">&#128179; Payment</span>
                <span class="left-pill">&#128203; Enrollment</span>
            </div>
        </div>
        <div class="left-footer">&copy; 2026 UniSys &mdash; All rights reserved.</div>
    </div>

    <%-- RIGHT FORM PANEL --%>
    <div class="right-panel">
        <div class="form-box">
            <h2>Welcome Back</h2>
            <p class="subtitle">Sign in with your Student ID to continue.</p>

            <%-- Session / Timeout notices --%>
            <asp:Panel ID="pnlSessionNotice" runat="server" Visible="false">
                <div class="notice notice-session">
                    <span>&#128274;</span>
                    <span>Your session has expired. Please sign in again.</span>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlTimeoutNotice" runat="server" Visible="false">
                <div class="notice notice-timeout">
                    <span>&#9203;</span>
                    <span>Connection timed out. Please try again.</span>
                </div>
            </asp:Panel>

            <%-- Error / success from server --%>
            <asp:Label ID="lblMessage" runat="server" CssClass="alert-block alert-error" Visible="false" EnableViewState="false"/>

            <%-- Student ID --%>
            <div class="field">
                <label for="<%=txtStudentId.ClientID %>">Student ID</label>
                <asp:TextBox ID="txtStudentId" runat="server" placeholder="e.g. A1234567"/>
            </div>

            <%-- Password --%>
            <div class="field">
                <label for="<%=txtPassword.ClientID %>">Password</label>
                <div class="pw-wrap">
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" placeholder="Enter your password"/>
                    <button type="button" class="pw-toggle" onclick="togglePw()" title="Show/hide">&#128065;</button>
                </div>
            </div>

            <asp:Button ID="btnLogin" runat="server" Text="SIGN IN"
                CssClass="btn-login" OnClick="btnLogin_Click"/>

            <div class="divider">or</div>

            <div class="register-row">
                New student? <a href="register.aspx">Create an account</a>
            </div>
        </div>
    </div>

</form>
<script>
    function togglePw() {
        var i = document.getElementById('<%=txtPassword.ClientID %>');
        i.type = i.type === 'password' ? 'text' : 'password';
    }
    (function () {
        var r = new URLSearchParams(window.location.search).get('reason');
        if (r === 'session') {
            var el = document.getElementById('<%=pnlSessionNotice.ClientID %>');
            if (el) el.style.display = 'block';
        }
        if (r === 'timeout') {
            var el2 = document.getElementById('<%=pnlTimeoutNotice.ClientID %>');
            if (el2) el2.style.display = 'block';
        }
    })();
</script>
</body>
</html>
