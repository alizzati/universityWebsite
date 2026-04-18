<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="register.aspx.cs" Inherits="payment.register" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Register — UniSys</title>
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
            min-height: 100vh;
            display: grid;
            grid-template-columns: 1fr 1fr;
        }

        /* ASP.NET form wrapper — must be contents so grid layout works */
        body > form { display: contents; }

        /* ── LEFT PANEL ── */
        .left-panel {
            background: linear-gradient(150deg, var(--red-deep) 0%, var(--red) 100%);
            display: flex; flex-direction: column;
            justify-content: space-between;
            padding: 3.5rem; position: relative; overflow: hidden;
        }
        .left-panel::before {
            content: 'JOIN US';
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
        .left-footer { color: rgba(255,255,255,.3); font-size: .72rem; }

        /* Steps list on left panel */
        .steps { margin-top: 1.6rem; display: flex; flex-direction: column; gap: .7rem; }
        .step { display: flex; align-items: center; gap: .8rem; }
        .step-num {
            width: 28px; height: 28px; border-radius: 50%;
            background: rgba(255,255,255,.15); border: 1px solid rgba(255,255,255,.3);
            display: flex; align-items: center; justify-content: center;
            font-size: .75rem; font-weight: 700; color: #FFFFFF; flex-shrink: 0;
        }
        .step-text { font-size: .82rem; color: rgba(255,255,255,.8); }

        /* ── RIGHT PANEL ── */
        .right-panel {
            overflow-y: auto;
            display: flex; align-items: flex-start;
            justify-content: center; padding: 2.5rem;
        }
        .form-box { width: 100%; max-width: 440px; padding-top: 1rem; padding-bottom: 2rem; }

        .form-box h2 {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 2.2rem; letter-spacing: 2.5px; color: var(--text); margin-bottom: .3rem;
        }
        .subtitle { font-size: .85rem; color: var(--muted); margin-bottom: 1.8rem; line-height: 1.5; }

        /* Alerts */
        .alert-block {
            border-radius: 8px; padding: .8rem 1rem; font-size: .83rem;
            margin-bottom: 1.2rem; display: block;
        }
        .alert-error   { background: #FFF5F6; border: 1px solid #FFCCD2; color: #C0001D; }
        .alert-success { background: #F0FFF7; border: 1px solid #B7EBD0; color: #1A7A47; }

        /* Section divider label */
        .sec-label {
            font-family: 'Bebas Neue', sans-serif; font-size: .85rem;
            letter-spacing: 2px; color: var(--red);
            display: flex; align-items: center; gap: .6rem;
            margin-bottom: .9rem; margin-top: 1.4rem;
        }
        .sec-label::after { content: ''; flex: 1; height: 1px; background: var(--border); }
        .sec-label:first-of-type { margin-top: 0; }

        /* Fields */
        .field { margin-bottom: .95rem; }
        .field label {
            display: block; font-size: .72rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: .7px;
            color: var(--muted); margin-bottom: .38rem;
        }
        /* Override generic input selector from old CSS — use class for specificity */
        .field input[type="text"],
        .field input[type="password"],
        .field input[type="email"] {
            width: 100%; padding: .82rem 1rem;
            border: 1.5px solid var(--border); border-radius: 9px;
            font-family: 'DM Sans', sans-serif; font-size: .88rem;
            color: var(--text); background: var(--bg);
            transition: border-color .2s, background .2s;
        }
        .field input[type="text"]:focus,
        .field input[type="password"]:focus,
        .field input[type="email"]:focus {
            outline: none; border-color: var(--red);
            background: var(--white); box-shadow: 0 0 0 3px var(--red-glow);
        }

        /* Two-column field row */
        .field-row { display: grid; grid-template-columns: 1fr 1fr; gap: .8rem; }

        /* Password toggle */
        .pw-wrap { position: relative; }
        .pw-wrap input { padding-right: 3.2rem !important; }
        .pw-toggle {
            position: absolute; right: 1rem; top: 50%;
            transform: translateY(-50%);
            background: none; border: none; cursor: pointer;
            color: var(--muted); font-size: .9rem; padding: 0;
            transition: color .2s; line-height: 1;
        }
        .pw-toggle:hover { color: var(--red); }

        /* Password strength meter */
        .pw-strength { margin-top: .35rem; }
        .strength-bar { height: 3px; background: var(--border); border-radius: 2px; overflow: hidden; margin-bottom: .28rem; }
        .strength-fill { height: 100%; width: 0%; border-radius: 2px; transition: all .3s; }
        .strength-text { font-size: .68rem; color: var(--muted); }

        /* Submit button */
        .btn-register {
            display: block; width: 100%; padding: 1rem;
            background: var(--red); color: #FFFFFF;
            font-family: 'Bebas Neue', sans-serif; font-size: 1.15rem; letter-spacing: 3px;
            border: none; border-radius: 10px; cursor: pointer; margin-top: 1.2rem;
            transition: background .2s, transform .15s, box-shadow .2s;
        }
        .btn-register:hover { background: #A8001A; transform: translateY(-1px); box-shadow: 0 6px 20px rgba(192,0,29,.28); }
        .btn-register:active { transform: translateY(0); }

        /* Login link */
        .login-row { text-align: center; margin-top: 1.3rem; font-size: .84rem; color: var(--muted); }
        .login-row a { color: var(--red); font-weight: 700; text-decoration: none; }
        .login-row a:hover { text-decoration: underline; }

        /* Responsive */
        @media (max-width: 768px) {
            body { grid-template-columns: 1fr; }
            .left-panel { display: none; }
            .right-panel { padding: 2rem 1.5rem; }
            .field-row { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <%-- LEFT DECORATIVE PANEL --%>
    <div class="left-panel">
        <div class="left-logo">UNIV<span>&middot;</span>SYS</div>
        <div class="left-headline">
            <h1>CREATE<br/>ACCOUNT</h1>
            <p>Register once to access all UniSys student services.</p>
            <div class="steps">
                <div class="step">
                    <div class="step-num">1</div>
                    <div class="step-text">Fill in your personal details</div>
                </div>
                <div class="step">
                    <div class="step-num">2</div>
                    <div class="step-text">Set your Student ID and password</div>
                </div>
                <div class="step">
                    <div class="step-num">3</div>
                    <div class="step-text">Log in and access the portal</div>
                </div>
            </div>
        </div>
        <div class="left-footer">&copy; 2026 UniSys &mdash; All rights reserved.</div>
    </div>

    <%-- RIGHT FORM PANEL --%>
    <div class="right-panel">
        <div class="form-box">
            <h2>New Student</h2>
            <p class="subtitle">Complete the form below to create your account.</p>

            <asp:Label ID="lblError"   runat="server" CssClass="alert-block alert-error"   Visible="false" EnableViewState="false"/>
            <asp:Label ID="lblSuccess" runat="server" CssClass="alert-block alert-success" Visible="false" EnableViewState="false"/>

            <%-- PERSONAL INFO --%>
            <div class="sec-label">Personal Info</div>

            <div class="field">
                <label>Full Name <span style="color:var(--red)">*</span></label>
                <asp:TextBox ID="txtName" runat="server" placeholder="e.g. Ahmad Danial bin Razak"/>
            </div>
            <div class="field-row">
                <div class="field">
                    <label>Student ID <span style="color:var(--red)">*</span></label>
                    <asp:TextBox ID="txtStudentId" runat="server" placeholder="e.g. A1234567"/>
                </div>
                <div class="field">
                    <label>Email</label>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" placeholder="you@university.edu"/>
                </div>
            </div>
            <div class="field-row">
                <div class="field">
                    <label>Phone</label>
                    <asp:TextBox ID="txtPhone" runat="server" placeholder="0123456789"/>
                </div>
                <div class="field">
                    <label>Address</label>
                    <asp:TextBox ID="txtAddress" runat="server" placeholder="City, State"/>
                </div>
            </div>

            <%-- ACCOUNT SECURITY --%>
            <div class="sec-label">Account Security</div>

            <div class="field">
                <label>Password <span style="color:var(--red)">*</span></label>
                <div class="pw-wrap">
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" placeholder="Min. 8 characters"/>
                    <button type="button" class="pw-toggle" onclick="togglePw('pw1')" title="Toggle">&#128065;</button>
                </div>
                <div class="pw-strength">
                    <div class="strength-bar"><div class="strength-fill" id="sFill"></div></div>
                    <div class="strength-text" id="sText">Enter a password</div>
                </div>
            </div>
            <div class="field">
                <label>Confirm Password <span style="color:var(--red)">*</span></label>
                <div class="pw-wrap">
                    <asp:TextBox ID="txtConfirm" runat="server" TextMode="Password" placeholder="Re-enter password"/>
                    <button type="button" class="pw-toggle" onclick="togglePw('pw2')" title="Toggle">&#128065;</button>
                </div>
            </div>

            <asp:Button ID="btnRegister" runat="server" Text="CREATE ACCOUNT"
                CssClass="btn-register" OnClick="btnRegister_Click"/>

            <div class="login-row">
                Already have an account? <a href="login.aspx">Sign in</a>
            </div>
        </div>
    </div>

</form>
<script>
    var _ids = { pw1: '<%=txtPassword.ClientID %>', pw2: '<%=txtConfirm.ClientID %>' };
    function togglePw(k) {
        var i = document.getElementById(_ids[k]);
        i.type = i.type === 'password' ? 'text' : 'password';
    }
    document.addEventListener('DOMContentLoaded', function () {
        var pw = document.getElementById(_ids['pw1']);
        if (!pw) return;
        pw.addEventListener('input', function () {
            var v = pw.value, s = 0;
            if (v.length >= 8) s++;
            if (/[A-Z]/.test(v)) s++;
            if (/[0-9]/.test(v)) s++;
            if (/[^A-Za-z0-9]/.test(v)) s++;
            var f = document.getElementById('sFill'), t = document.getElementById('sText');
            var c = ['#E5E5E0', '#C0001D', '#E67E22', '#F1C40F', '#1A7A47'];
            var l = ['Too short', 'Weak', 'Fair', 'Good', 'Strong'];
            f.style.width = (s * 25) + '%'; f.style.background = c[s];
            t.textContent = v.length === 0 ? 'Enter a password' : l[s];
            t.style.color = s <= 1 ? '#C0001D' : s <= 2 ? '#7A6000' : '#1A7A47';
        });
    });
</script>
</body>
</html>
