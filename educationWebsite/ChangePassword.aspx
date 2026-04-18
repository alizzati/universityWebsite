<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChangePassword.aspx.cs" Inherits="UniversitySystem.ChangePassword" %>
<%@ Register Src="~/Controls/NavBar.ascx" TagPrefix="uc" TagName="NavBar" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Change Password — UniSys</title>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:wght@300;400;500;700&display=swap" rel="stylesheet"/>
    <link href="~/Styles/NavBar.css" rel="stylesheet"/>
    <style>
        :root{--red:#C0001D;--red-deep:#8B0015;--red-light:#FFF0F2;--red-glow:rgba(192,0,29,.12);--bg:#F7F7F5;--card-bg:#FFFFFF;--border:#E5E5E0;--text:#1A1A1A;--muted:#6B6B65;--radius:12px;}
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
        body{font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;}

        #pageLoader{position:fixed;inset:0;background:#FFF;z-index:9999;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:1.5rem;transition:opacity .4s;}
        #pageLoader.hidden{opacity:0;pointer-events:none;}
        .loader-logo{font-family:'Bebas Neue',sans-serif;font-size:2.4rem;letter-spacing:3px;color:#8B0015;}
        .loader-logo span{color:rgba(139,0,21,.3);}
        .loader-bar-wrap{width:200px;height:3px;background:#EFEFEC;border-radius:2px;overflow:hidden;}
        .loader-bar{height:100%;width:0%;background:linear-gradient(90deg,#8B0015,#C0001D);border-radius:2px;animation:lp 1.2s ease forwards;}
        @keyframes lp{0%{width:0%}60%{width:75%}100%{width:100%}}
        .loader-text{font-size:.78rem;color:#6B6B65;letter-spacing:1px;font-weight:500;text-transform:uppercase;}

        .page-header{background:linear-gradient(135deg,var(--red-deep) 0%,var(--red) 100%);padding:2.5rem 2.5rem 2.2rem;position:relative;overflow:hidden;}
        .page-header::before{content:'PASSWORD';position:absolute;right:-1rem;top:50%;transform:translateY(-50%);font-family:'Bebas Neue',sans-serif;font-size:7rem;color:rgba(255,255,255,.06);pointer-events:none;letter-spacing:4px;white-space:nowrap;}
        .page-header h1{font-family:'Bebas Neue',sans-serif;font-size:2.6rem;letter-spacing:3px;color:#FFFFFF;line-height:1;}
        .page-header p{margin-top:.5rem;color:rgba(255,255,255,.75);font-size:.9rem;}

        .main{max-width:560px;margin:0 auto;padding:2.5rem 1.5rem 5rem;}

        .alert-block{border-radius:8px;padding:.85rem 1rem;font-size:.85rem;margin-bottom:1.5rem;display:block;}
        .alert-success{background:#F0FFF7;border:1px solid #B7EBD0;color:#1A7A47;}
        .alert-error  {background:#FFF5F6;border:1px solid #FFCCD2;color:#C0001D;}

        .form-card{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);padding:2rem;box-shadow:0 2px 16px rgba(0,0,0,.06);}
        .card-title{font-family:'Bebas Neue',sans-serif;font-size:1.1rem;letter-spacing:2px;color:var(--text);margin-bottom:1.5rem;display:flex;align-items:center;gap:.5rem;}
        .card-title-icon{font-size:1.2rem;}

        .form-group{margin-bottom:1.4rem;}
        .form-group label{display:block;font-size:.75rem;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:.4rem;}

        /* Password input with toggle button */
        .pw-wrap{position:relative;}
        .pw-wrap input{
            width:100%;padding:.85rem 3rem .85rem 1rem;
            border:1.5px solid var(--border);border-radius:9px;
            font-family:'DM Sans',sans-serif;font-size:.9rem;
            color:var(--text);background:var(--bg);
            transition:border-color .2s,background .2s;display:block;
        }
        .pw-wrap input:focus{outline:none;border-color:var(--red);background:#FFF;box-shadow:0 0 0 3px var(--red-glow);}
        .pw-toggle{position:absolute;right:.8rem;top:50%;transform:translateY(-50%);background:none;border:none;cursor:pointer;font-size:1rem;color:var(--muted);padding:.2rem;line-height:1;}
        .pw-toggle:hover{color:var(--text);}

        .val-msg{font-size:.75rem;color:#C0001D;margin-top:.3rem;display:block;}

        /* Strength bar */
        .strength-wrap{margin-top:.5rem;}
        .strength-bar-bg{height:5px;background:#EFEFEC;border-radius:3px;overflow:hidden;}
        .strength-bar-fill{height:100%;width:0%;border-radius:3px;transition:width .3s,background .3s;}
        .strength-label{font-size:.72rem;color:var(--muted);margin-top:.3rem;}

        /* Security tips */
        .security-tips{background:#F8F8F5;border:1px solid var(--border);border-radius:9px;padding:1rem 1.2rem;margin-bottom:1.5rem;font-size:.82rem;color:var(--muted);}
        .security-tips ul{padding-left:1.2rem;margin-top:.4rem;}
        .security-tips li{margin-bottom:.25rem;}
        .tip-title{font-weight:700;color:var(--text);margin-bottom:.3rem;}

        .btn-submit{display:block;width:100%;padding:1rem;background:var(--red);color:#FFF;font-family:'Bebas Neue',sans-serif;font-size:1.2rem;letter-spacing:3px;border:none;border-radius:10px;cursor:pointer;transition:background .2s,transform .15s,box-shadow .2s;margin-top:.5rem;}
        .btn-submit:hover{background:#A8001A;transform:translateY(-1px);box-shadow:0 6px 20px rgba(192,0,29,.3);}
        .btn-submit:active{transform:translateY(0);}

        /* Success card */
        .success-card{text-align:center;padding:2.5rem;}
        .success-icon{font-size:3.5rem;margin-bottom:1rem;display:block;}
        .success-card h2{font-family:'Bebas Neue',sans-serif;font-size:1.6rem;letter-spacing:2px;color:#1A7A47;margin-bottom:.5rem;}
        .success-card p{color:var(--muted);font-size:.88rem;margin-bottom:1.5rem;}
        .btn-back{display:inline-block;padding:.7rem 1.8rem;background:var(--red);color:#FFF;font-family:'Bebas Neue',sans-serif;font-size:1rem;letter-spacing:2px;border-radius:9px;text-decoration:none;transition:background .2s;}
        .btn-back:hover{background:#A8001A;}

        @media(max-width:600px){.page-header{padding:1.8rem 1rem;}.page-header h1{font-size:2rem;}.main{padding:1.5rem 1rem 4rem;}}
    </style>
</head>
<body>
<form id="form1" runat="server">

    <div id="pageLoader">
        <div class="loader-logo">UNIV<span>&middot;</span>SYS</div>
        <div class="loader-bar-wrap"><div class="loader-bar"></div></div>
        <div class="loader-text">Loading...</div>
    </div>

    <uc:NavBar ID="NavBar1" runat="server"/>

    <div class="page-header">
        <h1>CHANGE PASSWORD</h1>
        <p>Update your account security credentials</p>
    </div>

    <div class="main">

        <%-- Error alert --%>
        <asp:Panel ID="pnlError" runat="server" CssClass="alert-block alert-error" Visible="false">
            <asp:Label ID="lblError" runat="server"/>
        </asp:Panel>

        <%-- ── FORM PANEL ── --%>
        <asp:Panel ID="pnlForm" runat="server">
            <div class="form-card">
                <div class="card-title"><span class="card-title-icon">&#128274;</span> SECURITY SETTINGS</div>

                <div class="security-tips">
                    <div class="tip-title">&#128161; Password Requirements</div>
                    <ul>
                        <li>At least 8 characters long</li>
                        <li>Contains uppercase &amp; lowercase letters</li>
                        <li>Contains at least one number</li>
                    </ul>
                </div>

                <div class="form-group">
                    <label>Current Password <span style="color:var(--red)">*</span></label>
                    <div class="pw-wrap">
                        <asp:TextBox ID="txtCurrentPassword" runat="server" TextMode="Password"
                            placeholder="Enter your current password"/>
                        <button type="button" class="pw-toggle" onclick="togglePw('<%=txtCurrentPassword.ClientID%>',this)" title="Show/hide">&#128065;</button>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvCurrent" runat="server"
                        ControlToValidate="txtCurrentPassword"
                        ErrorMessage="Current password is required."
                        CssClass="val-msg" Display="Dynamic"/>
                </div>

                <div class="form-group">
                    <label>New Password <span style="color:var(--red)">*</span></label>
                    <div class="pw-wrap">
                        <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password"
                            placeholder="Min. 8 characters (uppercase + number)"
                            onkeyup="checkStrength(this.value)"/>
                        <button type="button" class="pw-toggle" onclick="togglePw('<%=txtNewPassword.ClientID%>',this)" title="Show/hide">&#128065;</button>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvNew" runat="server"
                        ControlToValidate="txtNewPassword"
                        ErrorMessage="New password is required."
                        CssClass="val-msg" Display="Dynamic"/>
                    <asp:RegularExpressionValidator ID="revPassword" runat="server"
                        ControlToValidate="txtNewPassword"
                        ValidationExpression="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$"
                        ErrorMessage="Must be 8+ characters with uppercase, lowercase and a number."
                        CssClass="val-msg" Display="Dynamic"/>
                    <div class="strength-wrap">
                        <div class="strength-bar-bg">
                            <div class="strength-bar-fill" id="sBar"></div>
                        </div>
                        <div class="strength-label" id="sLabel">Enter a new password</div>
                    </div>
                </div>

                <div class="form-group">
                    <label>Confirm New Password <span style="color:var(--red)">*</span></label>
                    <div class="pw-wrap">
                        <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password"
                            placeholder="Re-enter new password"/>
                        <button type="button" class="pw-toggle" onclick="togglePw('<%=txtConfirmPassword.ClientID%>',this)" title="Show/hide">&#128065;</button>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvConfirm" runat="server"
                        ControlToValidate="txtConfirmPassword"
                        ErrorMessage="Please confirm your new password."
                        CssClass="val-msg" Display="Dynamic"/>
                    <asp:CompareValidator ID="cvPassword" runat="server"
                        ControlToValidate="txtConfirmPassword"
                        ControlToCompare="txtNewPassword"
                        ErrorMessage="Passwords do not match."
                        CssClass="val-msg" Display="Dynamic"/>
                </div>

                <asp:Button ID="btnChangePassword" runat="server"
                    Text="UPDATE PASSWORD"
                    CssClass="btn-submit"
                    OnClick="btnChangePassword_Click"/>
            </div>
        </asp:Panel>

        <%-- ── SUCCESS PANEL ── --%>
        <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
            <div class="form-card">
                <div class="success-card">
                    <span class="success-icon">&#10004;</span>
                    <h2>PASSWORD UPDATED!</h2>
                    <p>Your password has been changed successfully.<br/>Please use your new password the next time you log in.</p>
                    <a href="~/Dashboard.aspx" runat="server" class="btn-back">GO TO DASHBOARD</a>
                </div>
            </div>
        </asp:Panel>

    </div>

</form>
<script src="~/Scripts/NavBar.js"></script>
<script>
    function togglePw(fieldId, btn) {
        var el = document.getElementById(fieldId);
        if (!el) return;
        el.type = el.type === 'password' ? 'text' : 'password';
        btn.textContent = el.type === 'password' ? '\uD83D\uDC41' : '\uD83D\uDEAB';
    }

    function checkStrength(v) {
        var bar = document.getElementById('sBar');
        var lbl = document.getElementById('sLabel');
        if (!bar || !lbl) return;
        var s = 0;
        if (v.length >= 8) s++;
        if (/[a-z]/.test(v) && /[A-Z]/.test(v)) s++;
        if (/\d/.test(v)) s++;
        if (/[^a-zA-Z0-9]/.test(v)) s++;
        var colors = ['#EFEFEC', '#C0001D', '#E67E22', '#F1C40F', '#1A7A47'];
        var labels = ['Enter a new password', 'Weak — too short', 'Fair — add numbers', 'Good — add symbols', 'Strong'];
        bar.style.width = (s * 25) + '%';
        bar.style.background = colors[s];
        lbl.textContent = v.length === 0 ? 'Enter a new password' : labels[s];
    }

    (function () {
        var l = document.getElementById('pageLoader');
        if (!l) return;
        window.addEventListener('load', function () {
            setTimeout(function () { l.classList.add('hidden'); setTimeout(function () { l.style.display = 'none'; }, 400); }, 400);
        });
    })();
</script>
</body>
</html>
