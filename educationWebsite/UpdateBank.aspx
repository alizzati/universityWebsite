<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UpdateBank.aspx.cs" Inherits="UniversitySystem.UpdateBank" %>
<%@ Register Src="~/Controls/NavBar.ascx" TagPrefix="uc" TagName="NavBar" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Update Bank Details — UniSys</title>
<link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:wght@300;400;500;700&display=swap" rel="stylesheet"/>
<link href="~/Styles/NavBar.css" rel="stylesheet"/>
<style>
:root{--red:#C0001D;--red-deep:#8B0015;--red-light:#FFF0F2;--red-glow:rgba(192,0,29,.12);--bg:#F7F7F5;--card:#FFFFFF;--border:#E5E5E0;--text:#1A1A1A;--muted:#6B6B65;--r:12px;}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
body{font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);}

/* HEADER */
.hdr{background:linear-gradient(135deg,var(--red-deep),var(--red));padding:2.5rem 2.5rem 2.2rem;position:relative;overflow:hidden;}
.hdr::after{content:'BANK';position:absolute;right:-1rem;top:50%;transform:translateY(-50%);font-family:'Bebas Neue',sans-serif;font-size:10rem;color:rgba(255,255,255,.06);pointer-events:none;white-space:nowrap;}
.hdr h1{font-family:'Bebas Neue',sans-serif;font-size:2.4rem;letter-spacing:3px;color:#fff;position:relative;z-index:1;}
.hdr p{color:rgba(255,255,255,.72);font-size:.88rem;margin-top:.4rem;position:relative;z-index:1;}

/* MAIN */
.wrap{max-width:580px;margin:0 auto;padding:2rem 1.5rem 5rem;}

/* SECTION HEADING */
.sec{font-family:'Bebas Neue',sans-serif;font-size:.93rem;letter-spacing:2.5px;color:var(--red);margin:0 0 1rem;display:flex;align-items:center;gap:.7rem;}
.sec::after{content:'';flex:1;height:1px;background:var(--border);}

/* ALERTS */
.ok{background:#F0FFF7;border:1px solid #B7EBD0;color:#1A7A47;border-radius:8px;padding:.85rem 1rem;font-size:.85rem;margin-bottom:1.4rem;}
.er{background:#FFF5F6;border:1px solid #FFCCD2;color:#C0001D;border-radius:8px;padding:.85rem 1rem;font-size:.85rem;margin-bottom:1.4rem;}

/* CURRENT BANK DISPLAY */
.cur-card{background:var(--card);border:1px solid var(--border);border-radius:var(--r);padding:1.4rem 1.6rem;margin-bottom:1.8rem;box-shadow:0 1px 6px rgba(0,0,0,.05);position:relative;overflow:hidden;}
.cur-card::before{content:'';position:absolute;left:0;top:0;bottom:0;width:4px;background:var(--red);}
.cur-title{font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:.8rem;}
.cur-row{display:flex;justify-content:space-between;padding:.38rem 0;border-bottom:1px solid #F0F0EC;font-size:.87rem;}
.cur-row:last-child{border-bottom:none;}
.cur-row span:first-child{color:var(--muted);}
.cur-row span:last-child{font-weight:600;color:var(--text);}
.no-bank{color:var(--muted);font-size:.84rem;font-style:italic;}

/* FORM CARD */
.fcard{background:var(--card);border:1px solid var(--border);border-radius:var(--r);padding:2rem;box-shadow:0 2px 14px rgba(0,0,0,.07);}
.fcard-hd{display:flex;align-items:center;gap:.9rem;margin-bottom:1.3rem;}
.fcard-ico{width:44px;height:44px;background:var(--red-light);border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:1.5rem;flex-shrink:0;}
.fcard-txt h3{font-family:'Bebas Neue',sans-serif;font-size:.95rem;letter-spacing:1.5px;color:var(--text);}
.fcard-txt p{font-size:.77rem;color:var(--muted);}
.info-box{background:var(--red-light);border-left:4px solid var(--red);padding:.8rem 1rem;border-radius:0 8px 8px 0;margin-bottom:1.3rem;font-size:.82rem;color:var(--text);line-height:1.5;}

.fg{margin-bottom:1.25rem;}
.fg label{display:block;font-size:.73rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--muted);margin-bottom:.38rem;}

/* ═══ KEY FIX ═══
   Style inputs and select by ELEMENT TYPE.
   asp:TextBox   → <input type="text">
   asp:DropDownList → <select>
   Browser will always apply these styles regardless of CssClass.
*/
input[type="text"],
select {
  display:block;width:100%;
  padding:.82rem 1rem;
  border:1.5px solid var(--border);border-radius:9px;
  font-family:'DM Sans',sans-serif;font-size:.88rem;
  color:var(--text);background:var(--bg);
  transition:border-color .2s,background .2s;
  -webkit-appearance:none;appearance:none;
}
input[type="text"]:focus,
select:focus {
  outline:none;border-color:var(--red);
  background:#fff;box-shadow:0 0 0 3px var(--red-glow);
}
.vm{font-size:.74rem;color:#C0001D;margin-top:.25rem;display:block;}

/* BUTTON */
.btn-save{display:block;width:100%;padding:1rem;margin-top:.4rem;background:var(--red);color:#fff;font-family:'Bebas Neue',sans-serif;font-size:1.1rem;letter-spacing:3px;border:none;border-radius:10px;cursor:pointer;transition:background .2s,transform .15s;}
.btn-save:hover{background:#A8001A;transform:translateY(-1px);}
.btn-save:active{transform:translateY(0);}

@media(max-width:600px){.hdr{padding:1.8rem 1rem;}.hdr h1{font-size:2rem;}.wrap{padding:1.4rem 1rem 4rem;}}
</style>
</head>
<body>
<form id="form1" runat="server">

<uc:NavBar ID="NavBar1" runat="server"/>

<div class="hdr">
  <h1>UPDATE BANK DETAILS</h1>
  <p>Manage your payment bank preference</p>
</div>

<div class="wrap">

  <!-- Alerts -->
  <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
    <div class="ok">&#10003; Bank details updated successfully!</div>
  </asp:Panel>
  <asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="er"><asp:Label ID="lblError" runat="server"/></div>
  </asp:Panel>

  <!-- CURRENT BANK INFO -->
  <div class="sec">CURRENT BANK INFORMATION</div>
  <div class="cur-card">
    <div class="cur-title">&#127981; Saved Bank Details</div>
    <asp:Panel ID="pnlNoBank" runat="server">
      <p class="no-bank">No bank details saved yet. Fill in the form below.</p>
    </asp:Panel>
    <asp:Panel ID="pnlBankInfo" runat="server" Visible="false">
      <div class="cur-row">
        <span>Bank Name</span>
        <span><asp:Label ID="lblCurBank" runat="server" Text="—"/></span>
      </div>
      <div class="cur-row">
        <span>Account Holder</span>
        <span><asp:Label ID="lblCurHolder" runat="server" Text="—"/></span>
      </div>
      <div class="cur-row">
        <span>Account Number</span>
        <span><asp:Label ID="lblCurAccount" runat="server" Text="—"/></span>
      </div>
    </asp:Panel>
  </div>

  <!-- EDIT FORM -->
  <div class="sec">UPDATE BANK DETAILS</div>
  <div class="fcard">
    <div class="fcard-hd">
      <div class="fcard-ico">&#127981;</div>
      <div class="fcard-txt">
        <h3>BANK ACCOUNT INFORMATION</h3>
        <p>Update your preferred bank for refund &amp; verification</p>
      </div>
    </div>
    <div class="info-box">
      &#128274; Your bank details are used for refund processing and verification only.
    </div>

    <asp:Panel ID="pnlForm" runat="server">

      <div class="fg">
        <label>Bank Name <span style="color:var(--red)">*</span></label>
        <asp:DropDownList ID="ddlBank" runat="server">
          <asp:ListItem Value=""              Text="-- Select Bank --"/>
          <asp:ListItem Value="Maybank"       Text="Maybank"/>
          <asp:ListItem Value="CIMB Bank"     Text="CIMB Bank"/>
          <asp:ListItem Value="Public Bank"   Text="Public Bank"/>
          <asp:ListItem Value="RHB Bank"      Text="RHB Bank"/>
          <asp:ListItem Value="Hong Leong Bank" Text="Hong Leong Bank"/>
          <asp:ListItem Value="AmBank"        Text="AmBank"/>
          <asp:ListItem Value="Bank Islam"    Text="Bank Islam"/>
          <asp:ListItem Value="Bank Muamalat" Text="Bank Muamalat"/>
          <asp:ListItem Value="Affin Bank"    Text="Affin Bank"/>
          <asp:ListItem Value="Other"         Text="Other"/>
        </asp:DropDownList>
        <asp:RequiredFieldValidator ID="rfvBank" runat="server"
          ControlToValidate="ddlBank" InitialValue=""
          ErrorMessage="Please select a bank." CssClass="vm" Display="Dynamic"/>
      </div>

      <!-- Other bank — hidden by default, shown via JS -->
      <div class="fg" id="grpOther" style="display:none">
        <label>Other Bank Name</label>
        <asp:TextBox ID="txtOtherBank" runat="server" placeholder="Enter bank name"/>
      </div>

      <div class="fg">
        <label>Account Holder Name <span style="color:var(--red)">*</span></label>
        <asp:TextBox ID="txtHolder" runat="server" placeholder="Full name as per bank account"/>
        <asp:RequiredFieldValidator ID="rfvHolder" runat="server"
          ControlToValidate="txtHolder" ErrorMessage="Account holder name is required."
          CssClass="vm" Display="Dynamic"/>
      </div>

      <div class="fg">
        <label>Account Number <span style="color:var(--red)">*</span></label>
        <asp:TextBox ID="txtAccount" runat="server" placeholder="Digits only, 8–20 characters"/>
        <asp:RequiredFieldValidator ID="rfvAccount" runat="server"
          ControlToValidate="txtAccount" ErrorMessage="Account number is required."
          CssClass="vm" Display="Dynamic"/>
        <asp:RegularExpressionValidator ID="revAccount" runat="server"
          ControlToValidate="txtAccount" ValidationExpression="^\d{8,20}$"
          ErrorMessage="Account number must be 8–20 digits." CssClass="vm" Display="Dynamic"/>
      </div>

      <asp:Button ID="btnSave" runat="server" Text="SAVE BANK DETAILS"
        CssClass="btn-save" OnClick="btnSave_Click"/>
    </asp:Panel>
  </div>

</div>
</form>
<script src="~/Scripts/NavBar.js"></script>
<script>
    // Show / hide "Other Bank" input based on dropdown selection
    var ddl = document.getElementById('<%=ddlBank.ClientID%>');
    var grp = document.getElementById('grpOther');
    if (ddl && grp) {
        function toggleOther() {
            grp.style.display = ddl.value === 'Other' ? 'block' : 'none';
        }
        ddl.addEventListener('change', toggleOther);
        toggleOther(); // run on page load (handles postback state)
    }
</script>
</body>
</html>
