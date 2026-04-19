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
:root{--red:#C0001D;--red-deep:#8B0015;--red-light:#FFF0F2;--red-glow:rgba(192,0,29,.12);--bg:#F7F7F5;--card:#FFFFFF;--border:#E5E5E0;--text:#1A1A1A;--muted:#6B6B65;--r:12px;}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
body{font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);}

/* HEADER */
.hdr{background:linear-gradient(135deg,var(--red-deep),var(--red));padding:2.5rem 2.5rem 2.2rem;position:relative;overflow:hidden;}
.hdr::after{content:'PASSWORD';position:absolute;right:-1rem;top:50%;transform:translateY(-50%);font-family:'Bebas Neue',sans-serif;font-size:7rem;color:rgba(255,255,255,.06);pointer-events:none;white-space:nowrap;}
.hdr h1{font-family:'Bebas Neue',sans-serif;font-size:2.4rem;letter-spacing:3px;color:#fff;position:relative;z-index:1;}
.hdr p{color:rgba(255,255,255,.72);font-size:.88rem;margin-top:.4rem;position:relative;z-index:1;}

/* MAIN */
.wrap{max-width:520px;margin:0 auto;padding:2rem 1.5rem 5rem;}

/* ALERTS */
.er{background:#FFF5F6;border:1px solid #FFCCD2;color:#C0001D;border-radius:8px;padding:.85rem 1rem;font-size:.85rem;margin-bottom:1.4rem;}

/* CARD */
.card{background:var(--card);border:1px solid var(--border);border-radius:var(--r);padding:2rem;box-shadow:0 2px 14px rgba(0,0,0,.07);}
.card-title{font-family:'Bebas Neue',sans-serif;font-size:1rem;letter-spacing:2px;color:var(--text);margin-bottom:1.5rem;display:flex;align-items:center;gap:.5rem;}

/* TIPS BOX */
.tips{background:#F8F8F5;border:1px solid var(--border);border-radius:9px;padding:1rem 1.2rem;margin-bottom:1.4rem;font-size:.81rem;color:var(--muted);}
.tips b{color:var(--text);}
.tips ul{padding-left:1.1rem;margin-top:.3rem;}
.tips li{margin-bottom:.2rem;}

/* FORM GROUP */
.fg{margin-bottom:1.3rem;}
.fg label{display:block;font-size:.73rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--muted);margin-bottom:.38rem;}

/* PASSWORD WRAP — input + toggle button */
.pw{position:relative;}
.pw input[type="password"],
.pw input[type="text"] {
  display:block;width:100%;
  padding:.82rem 2.8rem .82rem 1rem;
  border:1.5px solid var(--border);border-radius:9px;
  font-family:'DM Sans',sans-serif;font-size:.88rem;
  color:var(--text);background:var(--bg);
  transition:border-color .2s,background .2s;
}
.pw input:focus{outline:none;border-color:var(--red);background:#fff;box-shadow:0 0 0 3px var(--red-glow);}
.pw-eye{position:absolute;right:.75rem;top:50%;transform:translateY(-50%);
  background:none;border:none;cursor:pointer;font-size:1rem;color:var(--muted);padding:.2rem;line-height:1;}
.pw-eye:hover{color:var(--text);}

/* STRENGTH BAR */
.sb-wrap{margin-top:.5rem;}
.sb-bg{height:5px;background:#EFEFEC;border-radius:3px;overflow:hidden;}
.sb-fill{height:100%;width:0;border-radius:3px;transition:width .3s,background .3s;}
.sb-lbl{font-size:.71rem;color:var(--muted);margin-top:.28rem;}

.vm{font-size:.74rem;color:#C0001D;margin-top:.25rem;display:block;}

/* BUTTON */
.btn-pw{display:block;width:100%;padding:1rem;margin-top:.4rem;background:var(--red);color:#fff;font-family:'Bebas Neue',sans-serif;font-size:1.1rem;letter-spacing:3px;border:none;border-radius:10px;cursor:pointer;transition:background .2s,transform .15s;}
.btn-pw:hover{background:#A8001A;transform:translateY(-1px);}
.btn-pw:active{transform:translateY(0);}

/* SUCCESS SCREEN */
.success-screen{text-align:center;padding:2rem;}
.success-screen .ico{font-size:3.5rem;margin-bottom:1rem;display:block;}
.success-screen h2{font-family:'Bebas Neue',sans-serif;font-size:1.6rem;letter-spacing:2px;color:#1A7A47;margin-bottom:.5rem;}
.success-screen p{color:var(--muted);font-size:.87rem;margin-bottom:1.5rem;}
.btn-dash{display:inline-block;padding:.7rem 1.8rem;background:var(--red);color:#fff;font-family:'Bebas Neue',sans-serif;font-size:1rem;letter-spacing:2px;border-radius:9px;text-decoration:none;}
.btn-dash:hover{background:#A8001A;}

@media(max-width:600px){.hdr{padding:1.8rem 1rem;}.hdr h1{font-size:2rem;}.wrap{padding:1.4rem 1rem 4rem;}}
</style>
</head>
<body>
<form id="form1" runat="server">

<uc:NavBar ID="NavBar1" runat="server"/>

<div class="hdr">
  <h1>CHANGE PASSWORD</h1>
  <p>Update your account security credentials</p>
</div>

<div class="wrap">

  <!-- Error alert -->
  <asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="er"><asp:Label ID="lblError" runat="server"/></div>
  </asp:Panel>

  <!-- FORM -->
  <asp:Panel ID="pnlForm" runat="server">
    <div class="card">
      <div class="card-title">&#128274; SECURITY SETTINGS</div>

      <div class="tips">
        <b>&#128161; Password must:</b>
        <ul>
          <li>Be at least 8 characters long</li>
          <li>Contain uppercase &amp; lowercase letters</li>
          <li>Contain at least one number</li>
        </ul>
      </div>

      <!-- Current Password -->
      <div class="fg">
        <label>Current Password <span style="color:var(--red)">*</span></label>
        <div class="pw">
          <asp:TextBox ID="txtCurrent" runat="server" TextMode="Password"
            placeholder="Enter your current password"/>
          <button type="button" class="pw-eye" onclick="togglePw('<%=txtCurrent.ClientID%>',this)">&#128065;</button>
        </div>
        <asp:RequiredFieldValidator ID="rfvCurrent" runat="server"
          ControlToValidate="txtCurrent" ErrorMessage="Current password is required."
          CssClass="vm" Display="Dynamic"/>
      </div>

      <!-- New Password -->
      <div class="fg">
        <label>New Password <span style="color:var(--red)">*</span></label>
        <div class="pw">
          <asp:TextBox ID="txtNew" runat="server" TextMode="Password"
            placeholder="Min. 8 chars, uppercase + number"
            onkeyup="checkStrength(this.value)"/>
          <button type="button" class="pw-eye" onclick="togglePw('<%=txtNew.ClientID%>',this)">&#128065;</button>
        </div>
        <asp:RequiredFieldValidator ID="rfvNew" runat="server"
          ControlToValidate="txtNew" ErrorMessage="New password is required."
          CssClass="vm" Display="Dynamic"/>
        <asp:RegularExpressionValidator ID="revNew" runat="server"
          ControlToValidate="txtNew"
          ValidationExpression="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$"
          ErrorMessage="Must be 8+ chars with uppercase, lowercase and number."
          CssClass="vm" Display="Dynamic"/>
        <div class="sb-wrap">
          <div class="sb-bg"><div class="sb-fill" id="sbFill"></div></div>
          <div class="sb-lbl" id="sbLbl">Enter a new password</div>
        </div>
      </div>

      <!-- Confirm Password -->
      <div class="fg">
        <label>Confirm New Password <span style="color:var(--red)">*</span></label>
        <div class="pw">
          <asp:TextBox ID="txtConfirm" runat="server" TextMode="Password"
            placeholder="Re-enter new password"/>
          <button type="button" class="pw-eye" onclick="togglePw('<%=txtConfirm.ClientID%>',this)">&#128065;</button>
        </div>
        <asp:RequiredFieldValidator ID="rfvConfirm" runat="server"
          ControlToValidate="txtConfirm" ErrorMessage="Please confirm your new password."
          CssClass="vm" Display="Dynamic"/>
        <asp:CompareValidator ID="cvConfirm" runat="server"
          ControlToValidate="txtConfirm" ControlToCompare="txtNew"
          ErrorMessage="Passwords do not match." CssClass="vm" Display="Dynamic"/>
      </div>

      <asp:Button ID="btnChange" runat="server" Text="UPDATE PASSWORD"
        CssClass="btn-pw" OnClick="btnChange_Click"/>
    </div>
  </asp:Panel>

  <!-- SUCCESS SCREEN (shown after password changed) -->
  <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
    <div class="card">
      <div class="success-screen">
        <span class="ico">&#9989;</span>
        <h2>PASSWORD UPDATED!</h2>
        <p>Your password has been changed successfully.<br/>Use your new password next time you log in.</p>
        <a href="~/Dashboard.aspx" runat="server" class="btn-dash">GO TO DASHBOARD</a>
      </div>
    </div>
  </asp:Panel>

</div>
</form>
<script src="~/Scripts/NavBar.js"></script>
<script>
    function togglePw(id, btn) {
        var el = document.getElementById(id);
        if (!el) return;
        el.type = el.type === 'password' ? 'text' : 'password';
        btn.innerHTML = el.type === 'password' ? '&#128065;' : '&#128683;';
    }
    function checkStrength(v) {
        var fill = document.getElementById('sbFill');
        var lbl = document.getElementById('sbLbl');
        if (!fill || !lbl) return;
        var s = 0;
        if (v.length >= 8) s++;
        if (/[a-z]/.test(v) && /[A-Z]/.test(v)) s++;
        if (/\d/.test(v)) s++;
        if (/[^a-zA-Z0-9]/.test(v)) s++;
        var cols = ['#EFEFEC', '#C0001D', '#E67E22', '#F1C40F', '#1A7A47'];
        var lbls = ['Enter a new password', 'Weak', 'Fair', 'Good', 'Strong'];
        fill.style.width = (s * 25) + '%';
        fill.style.background = cols[s];
        lbl.textContent = v.length === 0 ? lbls[0] : lbls[s];
    }
</script>
</body>
</html>
