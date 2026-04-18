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
        .page-header::before{content:'BANK';position:absolute;right:-1rem;top:50%;transform:translateY(-50%);font-family:'Bebas Neue',sans-serif;font-size:10rem;color:rgba(255,255,255,.06);pointer-events:none;letter-spacing:4px;white-space:nowrap;}
        .page-header h1{font-family:'Bebas Neue',sans-serif;font-size:2.6rem;letter-spacing:3px;color:#FFF;line-height:1;}
        .page-header p{margin-top:.5rem;color:rgba(255,255,255,.75);font-size:.9rem;}

        .main{max-width:620px;margin:0 auto;padding:2.5rem 1.5rem 5rem;}

        .alert-block{border-radius:8px;padding:.85rem 1rem;font-size:.85rem;margin-bottom:1.5rem;display:block;}
        .alert-success{background:#F0FFF7;border:1px solid #B7EBD0;color:#1A7A47;}
        .alert-error  {background:#FFF5F6;border:1px solid #FFCCD2;color:#C0001D;}

        /* Current bank display */
        .current-bank-card{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);padding:1.4rem 1.6rem;margin-bottom:1.5rem;box-shadow:0 1px 6px rgba(0,0,0,.05);position:relative;overflow:hidden;}
        .current-bank-card::before{content:'';position:absolute;left:0;top:0;bottom:0;width:4px;background:var(--red);}
        .cb-title{font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:.8rem;}
        .cb-row{display:flex;justify-content:space-between;align-items:center;padding:.4rem 0;border-bottom:1px solid #F0F0EC;font-size:.88rem;}
        .cb-row:last-child{border-bottom:none;}
        .cb-row .lbl{color:var(--muted);}
        .cb-row .val{font-weight:600;color:var(--text);}
        .no-bank{color:var(--muted);font-size:.85rem;font-style:italic;}

        .section-label{font-family:'Bebas Neue',sans-serif;font-size:.95rem;letter-spacing:2.5px;color:var(--red);margin-bottom:1rem;display:flex;align-items:center;gap:.7rem;}
        .section-label::after{content:'';flex:1;height:1px;background:var(--border);}

        .form-card{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);padding:2rem;box-shadow:0 2px 16px rgba(0,0,0,.06);}

        .bank-icon-wrap{display:flex;align-items:center;gap:1rem;margin-bottom:1.3rem;}
        .bank-icon{width:48px;height:48px;background:var(--red-light);border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:1.6rem;flex-shrink:0;}
        .bank-icon-text h3{font-family:'Bebas Neue',sans-serif;font-size:1rem;letter-spacing:1.5px;color:var(--text);}
        .bank-icon-text p{font-size:.78rem;color:var(--muted);}

        .info-box{background:var(--red-light);border-left:4px solid var(--red);padding:.85rem 1.1rem;border-radius:0 8px 8px 0;margin-bottom:1.4rem;font-size:.83rem;color:var(--text);line-height:1.5;}

        .form-group{margin-bottom:1.3rem;}
        .form-group label{display:block;font-size:.75rem;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:.4rem;}

        /* Style asp:TextBox and asp:DropDownList rendered elements */
        .form-group input,
        .form-group select {
            width:100%;padding:.85rem 1rem;border:1.5px solid var(--border);border-radius:9px;
            font-family:'DM Sans',sans-serif;font-size:.9rem;color:var(--text);background:var(--bg);
            transition:border-color .2s,background .2s;display:block;
            -webkit-appearance:none;appearance:none;box-sizing:border-box;
        }
        .form-group input:focus,.form-group select:focus{
            outline:none;border-color:var(--red);background:#FFF;box-shadow:0 0 0 3px var(--red-glow);
        }
        .val-msg{font-size:.75rem;color:#C0001D;margin-top:.25rem;display:block;}

        .btn-submit{display:block;width:100%;padding:1rem;background:var(--red);color:#FFF;font-family:'Bebas Neue',sans-serif;font-size:1.2rem;letter-spacing:3px;border:none;border-radius:10px;cursor:pointer;transition:background .2s,transform .15s,box-shadow .2s;margin-top:.5rem;}
        .btn-submit:hover{background:#A8001A;transform:translateY(-1px);box-shadow:0 6px 20px rgba(192,0,29,.3);}
        .btn-submit:active{transform:translateY(0);}

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
        <h1>UPDATE BANK DETAILS</h1>
        <p>Manage your payment bank preference for refunds and verification</p>
    </div>

    <div class="main">

        <asp:Panel ID="pnlSuccess" runat="server" CssClass="alert-block alert-success" Visible="false">
            &#10003; Bank details updated successfully!
        </asp:Panel>
        <asp:Panel ID="pnlError" runat="server" CssClass="alert-block alert-error" Visible="false">
            <asp:Label ID="lblError" runat="server"/>
        </asp:Panel>

        <%-- ── CURRENT BANK INFO DISPLAY ── --%>
        <div class="section-label">CURRENT BANK INFORMATION</div>
        <div class="current-bank-card">
            <div class="cb-title">&#127981; Saved Bank Details</div>
            <asp:Panel ID="pnlNoBankInfo" runat="server">
                <p class="no-bank">No bank details saved yet. Fill in the form below to save your bank details.</p>
            </asp:Panel>
            <asp:Panel ID="pnlBankInfo" runat="server" Visible="false">
                <div class="cb-row">
                    <span class="lbl">Bank Name</span>
                    <span class="val"><asp:Label ID="lblCurrentBank" runat="server" Text="—"/></span>
                </div>
                <div class="cb-row">
                    <span class="lbl">Account Holder</span>
                    <span class="val"><asp:Label ID="lblCurrentHolder" runat="server" Text="—"/></span>
                </div>
                <div class="cb-row">
                    <span class="lbl">Account Number</span>
                    <span class="val"><asp:Label ID="lblCurrentAccount" runat="server" Text="—"/></span>
                </div>
            </asp:Panel>
        </div>

        <%-- ── EDIT FORM ── --%>
        <div class="section-label">UPDATE BANK DETAILS</div>
        <div class="form-card">

            <div class="bank-icon-wrap">
                <div class="bank-icon">&#127981;</div>
                <div class="bank-icon-text">
                    <h3>BANK ACCOUNT INFORMATION</h3>
                    <p>Update your preferred bank for refund processing</p>
                </div>
            </div>

            <div class="info-box">
                &#128274; These details are used for refund processing and payment verification only. Your information is securely stored.
            </div>

            <asp:Panel ID="pnlForm" runat="server">

                <div class="form-group">
                    <label>Bank Name <span style="color:var(--red)">*</span></label>
                    <asp:DropDownList ID="ddlBankName" runat="server">
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
                        ControlToValidate="ddlBankName" InitialValue=""
                        ErrorMessage="Please select a bank."
                        CssClass="val-msg" Display="Dynamic"/>
                </div>

                <div class="form-group" id="otherBankGroup" runat="server" style="display:none">
                    <label>Other Bank Name</label>
                    <asp:TextBox ID="txtOtherBank" runat="server" placeholder="Enter bank name"/>
                </div>

                <div class="form-group">
                    <label>Account Holder Name <span style="color:var(--red)">*</span></label>
                    <asp:TextBox ID="txtAccountHolder" runat="server" placeholder="Full name as per bank account"/>
                    <asp:RequiredFieldValidator ID="rfvHolder" runat="server"
                        ControlToValidate="txtAccountHolder"
                        ErrorMessage="Account holder name is required."
                        CssClass="val-msg" Display="Dynamic"/>
                </div>

                <div class="form-group">
                    <label>Account Number <span style="color:var(--red)">*</span></label>
                    <asp:TextBox ID="txtAccountNumber" runat="server" placeholder="Enter account number (digits only)"/>
                    <asp:RequiredFieldValidator ID="rfvAccount" runat="server"
                        ControlToValidate="txtAccountNumber"
                        ErrorMessage="Account number is required."
                        CssClass="val-msg" Display="Dynamic"/>
                    <asp:RegularExpressionValidator ID="revAccount" runat="server"
                        ControlToValidate="txtAccountNumber"
                        ValidationExpression="^\d{8,20}$"
                        ErrorMessage="Account number must be 8–20 digits."
                        CssClass="val-msg" Display="Dynamic"/>
                </div>

                <asp:Button ID="btnUpdate" runat="server" Text="SAVE BANK DETAILS"
                    CssClass="btn-submit" OnClick="btnUpdate_Click"/>

            </asp:Panel>
        </div>

    </div>

</form>
<script src="~/Scripts/NavBar.js"></script>
<script>
    // Show/hide Other Bank input
    var ddl = document.getElementById('<%=ddlBankName.ClientID%>');
    var grp = document.getElementById('<%=otherBankGroup.ClientID%>');
    if (ddl) {
        ddl.addEventListener('change', function () {
            if (grp) grp.style.display = this.value === 'Other' ? 'block' : 'none';
        });
        // On load (postback), check state
        if (grp) grp.style.display = ddl.value === 'Other' ? 'block' : 'none';
    }

    (function(){
        var l=document.getElementById('pageLoader');
        if(!l)return;
        window.addEventListener('load',function(){
            setTimeout(function(){l.classList.add('hidden');setTimeout(function(){l.style.display='none';},400);},400);
        });
    })();
</script>
</body>
</html>
