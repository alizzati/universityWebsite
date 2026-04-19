<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContactUs.aspx.cs" Inherits="UniversitySystem.ContactUs" %>
<%@ Register Src="~/Controls/NavBar.ascx" TagName="NavBar" TagPrefix="uc" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Contact Us — UniSys</title>
<link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:wght@300;400;500;700&display=swap" rel="stylesheet"/>
<link href="~/Styles/NavBar.css" rel="stylesheet"/>
<style>
:root{--red:#C0001D;--red-deep:#8B0015;--red-light:#FFF0F2;--red-glow:rgba(192,0,29,.12);--bg:#F7F7F5;--card:#FFFFFF;--border:#E5E5E0;--text:#1A1A1A;--muted:#6B6B65;--r:12px;}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
body{font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);}

/* HEADER */
.hdr{background:linear-gradient(135deg,var(--red-deep),var(--red));padding:2.5rem 2.5rem 2.2rem;position:relative;overflow:hidden;}
.hdr::after{content:'CONTACT';position:absolute;right:-1rem;top:50%;transform:translateY(-50%);font-family:'Bebas Neue',sans-serif;font-size:8rem;color:rgba(255,255,255,.05);pointer-events:none;white-space:nowrap;}
.hdr h1{font-family:'Bebas Neue',sans-serif;font-size:2.4rem;letter-spacing:3px;color:#fff;position:relative;z-index:1;}
.hdr p{color:rgba(255,255,255,.72);font-size:.88rem;margin-top:.4rem;position:relative;z-index:1;}

/* MAIN */
.wrap{max-width:980px;margin:0 auto;padding:2rem 1.5rem 5rem;}

/* ALERTS */
.ok{background:#F0FFF7;border:1px solid #B7EBD0;color:#1A7A47;border-radius:8px;padding:.85rem 1rem;font-size:.85rem;margin-bottom:1.4rem;}
.er{background:#FFF5F6;border:1px solid #FFCCD2;color:#C0001D;border-radius:8px;padding:.85rem 1rem;font-size:.85rem;margin-bottom:1.4rem;}

/* SECTION */
.sec{font-family:'Bebas Neue',sans-serif;font-size:.93rem;letter-spacing:2.5px;color:var(--red);margin:0 0 1rem;display:flex;align-items:center;gap:.7rem;}
.sec::after{content:'';flex:1;height:1px;background:var(--border);}

/* TWO-COLUMN LAYOUT */
.layout{display:grid;grid-template-columns:1fr 1.35fr;gap:2rem;align-items:start;}
@media(max-width:760px){.layout{grid-template-columns:1fr;}}

/* ── INFO CARDS (left column) ── */
.info-cards{display:flex;flex-direction:column;gap:.9rem;}
.ic{background:var(--card);border:1px solid var(--border);border-radius:var(--r);padding:1.2rem 1.5rem;position:relative;overflow:hidden;}
.ic::before{content:'';position:absolute;left:0;top:0;bottom:0;width:4px;background:var(--red);}
.ic-icon{font-size:1.4rem;margin-bottom:.5rem;display:block;}
.ic-title{font-family:'Bebas Neue',sans-serif;font-size:.9rem;letter-spacing:1.5px;color:var(--text);margin-bottom:.4rem;}
.ic p{font-size:.82rem;color:var(--muted);line-height:1.65;}
.ic a{color:var(--red);text-decoration:none;font-weight:500;}
.ic a:hover{text-decoration:underline;}
.ht{width:100%;margin-top:.4rem;}
.ht td{font-size:.8rem;padding:.18rem 0;color:var(--muted);}
.ht td:last-child{text-align:right;font-weight:600;color:var(--text);}
.map{margin-top:1rem;background:var(--card);border:1px solid var(--border);border-radius:var(--r);height:140px;display:flex;align-items:center;justify-content:center;color:var(--muted);font-size:.82rem;}

/* ── MESSAGE FORM (right column) ── */
.fcard{background:var(--card);border:1px solid var(--border);border-radius:var(--r);padding:2rem;box-shadow:0 2px 14px rgba(0,0,0,.07);}
.fcard h2{font-family:'Bebas Neue',sans-serif;font-size:1.15rem;letter-spacing:2px;color:var(--text);margin-bottom:.3rem;}
.fcard .sub{font-size:.81rem;color:var(--muted);margin-bottom:1.5rem;line-height:1.5;}

/* FORM FIELDS */
/* ════════════════════════════════════════════════════════
   ROOT CAUSE FIX — ContactUs form not visible:

   The issue was that previous versions used CSS selectors
   like ".field input" or ".fc-input" which don't work
   reliably across all browsers when applied to ASP.NET
   server controls, because ASP.NET wraps controls in a
   <span> or changes element IDs.

   THE ONLY GUARANTEED FIX:
   Style inputs by their RAW ELEMENT TYPE:
     input[type="text"]  → matches asp:TextBox
     select              → matches asp:DropDownList
     textarea            → matches asp:TextBox TextMode=MultiLine

   These selectors ALWAYS apply regardless of CssClass,
   wrapper divs, or ASP.NET rendering quirks.
   ════════════════════════════════════════════════════════ */
.fg{margin-bottom:1.2rem;}
.fg label{display:block;font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.55px;color:var(--muted);margin-bottom:.35rem;}

/* Style ALL inputs inside .fcard */
.fcard input[type="text"],
.fcard select,
.fcard textarea {
  display:block;
  width:100%;
  padding:.82rem 1rem;
  border:1.5px solid var(--border);
  border-radius:9px;
  font-family:'DM Sans',sans-serif;
  font-size:.87rem;
  color:var(--text);
  background:var(--bg);
  transition:border-color .2s,background .2s;
  box-sizing:border-box;
}
.fcard input[type="text"]:focus,
.fcard select:focus,
.fcard textarea:focus {
  outline:none;
  border-color:var(--red);
  background:#fff;
  box-shadow:0 0 0 3px var(--red-glow);
}
.fcard input[readonly] {
  background:#F0F0EC;
  color:var(--muted);
  cursor:not-allowed;
}
.fcard textarea {
  min-height:128px;
  resize:vertical;
}
.char-count{font-size:.69rem;color:var(--muted);text-align:right;margin-top:.22rem;}

/* SEND BUTTON */
.btn-send{display:block;width:100%;padding:1rem;margin-top:.4rem;background:var(--red);color:#fff;font-family:'Bebas Neue',sans-serif;font-size:1.1rem;letter-spacing:3px;border:none;border-radius:10px;cursor:pointer;transition:background .2s,transform .15s;}
.btn-send:hover{background:#A8001A;transform:translateY(-1px);}
.btn-send:active{transform:translateY(0);}

@media(max-width:600px){.hdr{padding:1.8rem 1rem;}.hdr h1{font-size:2rem;}.wrap{padding:1.4rem 1rem 4rem;}.fcard{padding:1.3rem;}}
</style>
</head>
<body>
<form id="form1" runat="server">

<uc:NavBar ID="ucNavBar" runat="server"/>

<div class="hdr">
  <h1>Contact Us</h1>
  <p>Reach out to the University's academic administration team.</p>
</div>

<div class="wrap">

  <!-- Alerts — placed above layout so they're always visible -->
  <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
    <div class="ok">&#10003; <asp:Label ID="lblSuccess" runat="server" Text="Message sent successfully!"/></div>
  </asp:Panel>
  <asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="er">&#9888; <asp:Label ID="lblError" runat="server"/></div>
  </asp:Panel>

  <div class="layout">

    <!-- ══ LEFT: CONTACT INFO ══ -->
    <div>
      <div class="sec">CONTACT INFORMATION</div>
      <div class="info-cards">

        <div class="ic">
          <span class="ic-icon">&#127970;</span>
          <div class="ic-title">MAIN CAMPUS</div>
          <p>UniSys University<br/>No. 1, Jalan Universiti, Nilai<br/>71800 Negeri Sembilan, Malaysia</p>
        </div>

        <div class="ic">
          <span class="ic-icon">&#128222;</span>
          <div class="ic-title">PHONE &amp; FAX</div>
          <p>
            General: <a href="tel:+60676508000">+60 6765 0800</a><br/>
            Registrar: <a href="tel:+60676508100">+60 6765 0810</a><br/>
            Student Affairs: <a href="tel:+60676508200">+60 6765 0820</a><br/>
            Fax: +60 6765 0999
          </p>
        </div>

        <div class="ic">
          <span class="ic-icon">&#9993;</span>
          <div class="ic-title">EMAIL</div>
          <p>
            General: <a href="mailto:info@unisys.edu.my">info@unisys.edu.my</a><br/>
            Registrar: <a href="mailto:registrar@unisys.edu.my">registrar@unisys.edu.my</a><br/>
            IT Support: <a href="mailto:itsupport@unisys.edu.my">itsupport@unisys.edu.my</a>
          </p>
        </div>

        <div class="ic">
          <span class="ic-icon">&#128336;</span>
          <div class="ic-title">OFFICE HOURS</div>
          <table class="ht">
            <tr><td>Mon – Fri</td><td>8:00 AM – 5:00 PM</td></tr>
            <tr><td>Saturday</td><td>8:00 AM – 1:00 PM</td></tr>
            <tr><td>Sun &amp; Holidays</td><td>Closed</td></tr>
          </table>
        </div>

      </div>
      <div class="map">&#128205; Campus map — embed Google Maps here</div>
    </div>

    <!-- ══ RIGHT: MESSAGE FORM ══ -->
    <div>
      <div class="sec">SEND A MESSAGE</div>
      <div class="fcard">
        <h2>GET IN TOUCH</h2>
        <p class="sub">Fill in the form below and we will respond within 1–2 business days.</p>

        <!-- Your Name (readonly, set from session in code-behind) -->
        <div class="fg">
          <label>Your Name</label>
          <asp:TextBox ID="txtName" runat="server" ReadOnly="true"/>
        </div>

        <!-- Student ID (readonly) -->
        <div class="fg">
          <label>Student ID</label>
          <asp:TextBox ID="txtStudentId" runat="server" ReadOnly="true"/>
        </div>

        <!-- Subject -->
        <div class="fg">
          <label>Subject <span style="color:var(--red)">*</span></label>
          <asp:DropDownList ID="ddlSubject" runat="server">
            <asp:ListItem Value=""                        Text="— Select a subject —"/>
            <asp:ListItem Value="Course Enrollment Query" Text="Course Enrollment Query"/>
            <asp:ListItem Value="Payment / Finance Issue" Text="Payment / Finance Issue"/>
            <asp:ListItem Value="Timetable Query"         Text="Timetable Query"/>
            <asp:ListItem Value="Academic Results/Grade"  Text="Academic Results / Grade"/>
            <asp:ListItem Value="Technical Support"       Text="Technical Support (Portal)"/>
            <asp:ListItem Value="Add/Drop Course Query"   Text="Add / Drop Course Query"/>
            <asp:ListItem Value="Other"                   Text="Other"/>
          </asp:DropDownList>
        </div>

        <!-- Message -->
        <div class="fg">
          <label>Message <span style="color:var(--red)">*</span></label>
          <asp:TextBox ID="txtMessage" runat="server"
            TextMode="MultiLine"
            placeholder="Describe your enquiry in detail..."
            onkeyup="updateCount(this,'charCnt',1000)"/>
          <div class="char-count"><span id="charCnt">0</span> / 1000 characters</div>
        </div>

        <!-- Send button -->
        <asp:Button ID="btnSend" runat="server"
          Text="SEND MESSAGE"
          CssClass="btn-send"
          OnClick="btnSend_Click"
          CausesValidation="false"/>

      </div>
    </div>

  </div><%-- /layout --%>
</div><%-- /wrap --%>

</form>
<script src="~/Scripts/NavBar.js"></script>
<script>
    function updateCount(el, id, max) {
        var len = el.value.length;
        if (len > max) { el.value = el.value.substring(0, max); len = max; }
        var s = document.getElementById(id);
        if (s) s.textContent = len;
    }
</script>
</body>
</html>
