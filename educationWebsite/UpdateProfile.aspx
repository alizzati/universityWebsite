<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UpdateProfile.aspx.cs" Inherits="UniversitySystem.UpdateProfile" %>
<%@ Register Src="~/Controls/NavBar.ascx" TagPrefix="uc" TagName="NavBar" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>My Profile — UniSys</title>
<link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:wght@300;400;500;700&display=swap" rel="stylesheet"/>
<link href="~/Styles/NavBar.css" rel="stylesheet"/>
<style>
:root{--red:#C0001D;--red-deep:#8B0015;--red-light:#FFF0F2;--red-glow:rgba(192,0,29,.12);--bg:#F7F7F5;--card:#FFFFFF;--border:#E5E5E0;--text:#1A1A1A;--muted:#6B6B65;--r:12px;}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
body{font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);}

/* HEADER */
.hdr{background:linear-gradient(135deg,var(--red-deep),var(--red));overflow:hidden;position:relative;}
.hdr::after{content:'PROFILE';position:absolute;right:-1rem;top:50%;transform:translateY(-50%);font-family:'Bebas Neue',sans-serif;font-size:9rem;color:rgba(255,255,255,.05);pointer-events:none;white-space:nowrap;}
.hero{display:flex;align-items:center;gap:1.5rem;padding:2.2rem 2.5rem 1.8rem;flex-wrap:wrap;position:relative;z-index:1;}
.avatar{width:80px;height:80px;border-radius:50%;background:rgba(255,255,255,.18);border:2.5px solid rgba(255,255,255,.4);display:flex;align-items:center;justify-content:center;font-family:'Bebas Neue',sans-serif;font-size:2.2rem;color:#fff;flex-shrink:0;}
.hero-txt h1{font-family:'Bebas Neue',sans-serif;font-size:1.9rem;letter-spacing:2px;color:#fff;line-height:1.1;}
.hero-txt p{font-size:.82rem;color:rgba(255,255,255,.7);margin-top:.25rem;}
.stats{display:flex;border-top:1px solid rgba(255,255,255,.15);position:relative;z-index:1;}
.stat{flex:1;padding:.9rem 1rem;text-align:center;border-right:1px solid rgba(255,255,255,.15);}
.stat:last-child{border-right:none;}
.stat-n{font-family:'Bebas Neue',sans-serif;font-size:1.5rem;color:#fff;}
.stat-l{font-size:.69rem;color:rgba(255,255,255,.6);text-transform:uppercase;letter-spacing:.6px;}

/* MAIN */
.wrap{max-width:760px;margin:0 auto;padding:2rem 1.5rem 5rem;}
.sec{font-family:'Bebas Neue',sans-serif;font-size:.93rem;letter-spacing:2.5px;color:var(--red);margin:0 0 1rem;display:flex;align-items:center;gap:.7rem;}
.sec::after{content:'';flex:1;height:1px;background:var(--border);}

/* ALERTS */
.ok{background:#F0FFF7;border:1px solid #B7EBD0;color:#1A7A47;border-radius:8px;padding:.85rem 1rem;font-size:.85rem;margin-bottom:1.4rem;}
.er{background:#FFF5F6;border:1px solid #FFCCD2;color:#C0001D;border-radius:8px;padding:.85rem 1rem;font-size:.85rem;margin-bottom:1.4rem;}

/* VIEW CARD */
.vcard{background:var(--card);border:1px solid var(--border);border-radius:var(--r);padding:1.6rem 2rem;box-shadow:0 1px 8px rgba(0,0,0,.06);margin-bottom:2rem;}
.vg{display:grid;grid-template-columns:1fr 1fr;gap:1rem 2rem;}
.vi label{font-size:.71rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--muted);display:block;margin-bottom:.2rem;}
.vi .vv{font-size:.9rem;color:var(--text);font-weight:500;}
.vi.span2{grid-column:span 2;}

/* FORM CARD */
.fcard{background:var(--card);border:1px solid var(--border);border-radius:var(--r);padding:1.8rem 2rem;box-shadow:0 2px 14px rgba(0,0,0,.07);}
.row2{display:grid;grid-template-columns:1fr 1fr;gap:0 1.4rem;}
.fg{margin-bottom:1.25rem;}
.fg label{display:block;font-size:.73rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--muted);margin-bottom:.38rem;}

input[type="text"],
input[type="email"],
textarea {
  display:block;width:100%;
  padding:.82rem 1rem;
  border:1.5px solid var(--border);border-radius:9px;
  font-family:'DM Sans',sans-serif;font-size:.88rem;
  color:var(--text);background:var(--bg);
  transition:border-color .2s,background .2s;
}
input[type="text"]:focus,input[type="email"]:focus,textarea:focus{
  outline:none;border-color:var(--red);
  background:#fff;box-shadow:0 0 0 3px var(--red-glow);
}
input[disabled],input[readonly]{background:#F0F0EC;color:var(--muted);cursor:not-allowed;}
textarea{resize:vertical;min-height:82px;}
.vm{font-size:.74rem;color:#C0001D;margin-top:.25rem;display:block;}

/* BUTTON */
.btn-save{display:block;width:100%;padding:1rem;margin-top:.4rem;background:var(--red);color:#fff;font-family:'Bebas Neue',sans-serif;font-size:1.1rem;letter-spacing:3px;border:none;border-radius:10px;cursor:pointer;transition:background .2s,transform .15s;}
.btn-save:hover{background:#A8001A;transform:translateY(-1px);}
.btn-save:active{transform:translateY(0);}

@media(max-width:600px){.vg,.row2{grid-template-columns:1fr;}.vi.span2{grid-column:auto;}.hero{padding:1.4rem 1rem;}.wrap{padding:1.4rem 1rem 4rem;}}
</style>
</head>
<body>
<form id="form1" runat="server">

<uc:NavBar ID="NavBar1" runat="server"/>

<!-- PROFILE HERO -->
<div class="hdr">
  <div class="hero">
    <div class="avatar"><asp:Label ID="lblInitials" runat="server" Text="S"/></div>
    <div class="hero-txt">
      <h1><asp:Label ID="lblHeroName" runat="server" Text="Student Name"/></h1>
      <p>ID: <asp:Label ID="lblHeroId" runat="server"/> &nbsp;|&nbsp; <asp:Label ID="lblHeroEmail" runat="server"/></p>
    </div>
  </div>
  <div class="stats">
    <div class="stat">
      <div class="stat-n"><asp:Label ID="lblStatCourses" runat="server" Text="0"/></div>
      <div class="stat-l">Active Courses</div>
    </div>
    <div class="stat">
      <div class="stat-n"><asp:Label ID="lblStatCredits" runat="server" Text="0"/></div>
      <div class="stat-l">Total Credits</div>
    </div>
    <div class="stat">
      <div class="stat-n"><asp:Label ID="lblStatPaid" runat="server" Text="0"/></div>
      <div class="stat-l">Payments Made</div>
    </div>
  </div>
</div>

<div class="wrap">

  <!-- Alerts -->
  <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
    <div class="ok">&#10003; Profile updated successfully!</div>
  </asp:Panel>
  <asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="er"><asp:Label ID="lblError" runat="server"/></div>
  </asp:Panel>

  <!-- VIEW PROFILE -->
  <div class="sec">MY PROFILE INFORMATION</div>
  <div class="vcard">
    <div class="vg">
      <div class="vi"><label>Student ID</label><div class="vv"><asp:Label ID="lblViewId" runat="server" Text="—"/></div></div>
      <div class="vi"><label>Full Name</label><div class="vv"><asp:Label ID="lblViewName" runat="server" Text="—"/></div></div>
      <div class="vi"><label>Email</label><div class="vv"><asp:Label ID="lblViewEmail" runat="server" Text="—"/></div></div>
      <div class="vi"><label>Phone</label><div class="vv"><asp:Label ID="lblViewPhone" runat="server" Text="—"/></div></div>
      <div class="vi span2"><label>Address</label><div class="vv"><asp:Label ID="lblViewAddress" runat="server" Text="—"/></div></div>
    </div>
  </div>

  <!-- EDIT PROFILE -->
  <div class="sec">EDIT PROFILE</div>
  <div class="fcard">
    <asp:Panel ID="pnlForm" runat="server">
      <div class="row2">
        <div class="fg">
          <label>Student ID (read-only)</label>
          <asp:TextBox ID="txtStudentId" runat="server" Enabled="false"/>
        </div>
        <div class="fg">
          <label>Full Name <span style="color:var(--red)">*</span></label>
          <asp:TextBox ID="txtName" runat="server" placeholder="Enter your full name"/>
          <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName"
            ErrorMessage="Name is required." CssClass="vm" Display="Dynamic"/>
        </div>
      </div>
      <div class="row2">
        <div class="fg">
          <label>Email Address <span style="color:var(--red)">*</span></label>
          <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" placeholder="email@example.com"/>
          <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
            ErrorMessage="Email is required." CssClass="vm" Display="Dynamic"/>
          <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
            ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
            ErrorMessage="Invalid email format." CssClass="vm" Display="Dynamic"/>
        </div>
        <div class="fg">
          <label>Phone Number</label>
          <asp:TextBox ID="txtPhone" runat="server" placeholder="0123456789"/>
          <asp:RegularExpressionValidator ID="revPhone" runat="server" ControlToValidate="txtPhone"
            ValidationExpression="^[\d\s\-\+\(\)]*$"
            ErrorMessage="Invalid phone number." CssClass="vm" Display="Dynamic"/>
        </div>
      </div>
      <div class="fg">
        <label>Address</label>
        <asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" Rows="3"
          placeholder="Enter your complete address"/>
      </div>
      <asp:Button ID="btnUpdate" runat="server" Text="SAVE CHANGES"
        CssClass="btn-save" OnClick="btnUpdate_Click"/>
    </asp:Panel>
  </div>

</div>
</form>
<script src="~/Scripts/NavBar.js"></script>
</body>
</html>
