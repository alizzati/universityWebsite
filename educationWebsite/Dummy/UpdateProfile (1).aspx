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
        :root{--red:#C0001D;--red-deep:#8B0015;--red-light:#FFF0F2;--red-glow:rgba(192,0,29,.12);--bg:#F7F7F5;--card-bg:#FFFFFF;--border:#E5E5E0;--text:#1A1A1A;--muted:#6B6B65;--radius:12px;}
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
        body{font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;}

        /* ── Loader ── */
        #pageLoader{position:fixed;inset:0;background:#FFF;z-index:9999;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:1.5rem;transition:opacity .4s;}
        #pageLoader.hidden{opacity:0;pointer-events:none;}
        .loader-logo{font-family:'Bebas Neue',sans-serif;font-size:2.4rem;letter-spacing:3px;color:#8B0015;}
        .loader-logo span{color:rgba(139,0,21,.3);}
        .loader-bar-wrap{width:200px;height:3px;background:#EFEFEC;border-radius:2px;overflow:hidden;}
        .loader-bar{height:100%;width:0%;background:linear-gradient(90deg,#8B0015,#C0001D);border-radius:2px;animation:lp 1.2s ease forwards;}
        @keyframes lp{0%{width:0%}60%{width:75%}100%{width:100%}}
        .loader-text{font-size:.78rem;color:#6B6B65;letter-spacing:1px;font-weight:500;text-transform:uppercase;}

        /* ── Header ── */
        .page-header{background:linear-gradient(135deg,var(--red-deep) 0%,var(--red) 100%);padding:0;position:relative;overflow:hidden;}
        .page-header::before{content:'PROFILE';position:absolute;right:-1rem;top:50%;transform:translateY(-50%);font-family:'Bebas Neue',sans-serif;font-size:8rem;color:rgba(255,255,255,.06);pointer-events:none;letter-spacing:4px;white-space:nowrap;}

        /* ── Profile Hero ── */
        .profile-hero{display:flex;align-items:center;gap:2rem;padding:2.5rem 2.5rem 2rem;flex-wrap:wrap;}
        .avatar-wrap{position:relative;flex-shrink:0;}
        .avatar{width:90px;height:90px;border-radius:50%;background:rgba(255,255,255,.2);border:3px solid rgba(255,255,255,.5);display:flex;align-items:center;justify-content:center;font-family:'Bebas Neue',sans-serif;font-size:2.4rem;color:#FFF;letter-spacing:1px;}
        .profile-info{}
        .profile-info h1{font-family:'Bebas Neue',sans-serif;font-size:2rem;letter-spacing:3px;color:#FFF;line-height:1.1;}
        .profile-info .pid{font-size:.85rem;color:rgba(255,255,255,.75);margin-top:.3rem;}
        .profile-info .pemail{font-size:.82rem;color:rgba(255,255,255,.65);margin-top:.15rem;}

        /* ── Stats strip ── */
        .profile-stats{display:flex;gap:0;border-top:1px solid rgba(255,255,255,.15);}
        .pstat{flex:1;padding:1rem 1.5rem;text-align:center;border-right:1px solid rgba(255,255,255,.15);}
        .pstat:last-child{border-right:none;}
        .pstat-val{font-family:'Bebas Neue',sans-serif;font-size:1.5rem;color:#FFF;letter-spacing:1px;}
        .pstat-lbl{font-size:.72rem;color:rgba(255,255,255,.65);text-transform:uppercase;letter-spacing:.6px;}

        /* ── Main ── */
        .main{max-width:780px;margin:0 auto;padding:2.5rem 1.5rem 5rem;}

        /* ── Alerts ── */
        .alert-block{border-radius:8px;padding:.85rem 1rem;font-size:.85rem;margin-bottom:1.5rem;display:block;}
        .alert-success{background:#F0FFF7;border:1px solid #B7EBD0;color:#1A7A47;}
        .alert-error  {background:#FFF5F6;border:1px solid #FFCCD2;color:#C0001D;}

        /* ── Section label ── */
        .section-label{font-family:'Bebas Neue',sans-serif;font-size:.95rem;letter-spacing:2.5px;color:var(--red);margin-bottom:1.2rem;display:flex;align-items:center;gap:.7rem;}
        .section-label::after{content:'';flex:1;height:1px;background:var(--border);}

        /* ── View card ── */
        .view-card{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);padding:1.8rem 2rem;box-shadow:0 1px 8px rgba(0,0,0,.06);margin-bottom:2rem;}
        .view-grid{display:grid;grid-template-columns:1fr 1fr;gap:1.2rem 2rem;}
        @media(max-width:550px){.view-grid{grid-template-columns:1fr;}}
        .view-item label{font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);display:block;margin-bottom:.25rem;}
        .view-item .val{font-size:.92rem;color:var(--text);font-weight:500;word-break:break-all;}
        .view-item .val.full{grid-column:span 2;}

        /* ── Edit form card ── */
        .form-card{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);padding:1.8rem 2rem;box-shadow:0 2px 16px rgba(0,0,0,.06);}
        .form-row{display:grid;grid-template-columns:1fr 1fr;gap:0 1.5rem;}
        @media(max-width:600px){.form-row{grid-template-columns:1fr;}}
        .form-group{margin-bottom:1.3rem;}
        .form-group label{display:block;font-size:.75rem;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:.4rem;}

        /* Style ALL asp:TextBox rendered outputs */
        .form-group input,
        .form-group textarea {
            width:100%;padding:.82rem 1rem;border:1.5px solid var(--border);border-radius:9px;
            font-family:'DM Sans',sans-serif;font-size:.9rem;color:var(--text);background:var(--bg);
            transition:border-color .2s,background .2s;display:block;box-sizing:border-box;
        }
        .form-group input:focus,.form-group textarea:focus{
            outline:none;border-color:var(--red);background:#FFF;box-shadow:0 0 0 3px var(--red-glow);
        }
        .form-group input[disabled]{background:#F0F0EC;color:var(--muted);cursor:not-allowed;}
        .form-group textarea{resize:vertical;min-height:80px;}
        .val-msg{font-size:.75rem;color:#C0001D;margin-top:.25rem;display:block;}

        .btn-submit{display:block;width:100%;padding:1rem;background:var(--red);color:#FFF;font-family:'Bebas Neue',sans-serif;font-size:1.2rem;letter-spacing:3px;border:none;border-radius:10px;cursor:pointer;transition:background .2s,transform .15s,box-shadow .2s;margin-top:.5rem;}
        .btn-submit:hover{background:#A8001A;transform:translateY(-1px);box-shadow:0 6px 20px rgba(192,0,29,.3);}
        .btn-submit:active{transform:translateY(0);}

        @media(max-width:600px){.profile-hero{padding:1.5rem 1rem 1.2rem;gap:1rem;}.pstat{padding:.7rem .5rem;}.main{padding:1.5rem 1rem 4rem;}}
    </style>
</head>
<body>
<form id="form1" runat="server">

    <div id="pageLoader">
        <div class="loader-logo">UNIV<span>&middot;</span>SYS</div>
        <div class="loader-bar-wrap"><div class="loader-bar"></div></div>
        <div class="loader-text">Loading profile...</div>
    </div>

    <uc:NavBar ID="NavBar1" runat="server"/>

    <%-- ── Profile Hero (dynamic from code-behind) ── --%>
    <div class="page-header">
        <div class="profile-hero">
            <div class="avatar-wrap">
                <div class="avatar"><asp:Label ID="lblAvatarInitials" runat="server" Text="S"/></div>
            </div>
            <div class="profile-info">
                <h1><asp:Label ID="lblHeroName" runat="server" Text="Student Name"/></h1>
                <div class="pid">Student ID: <asp:Label ID="lblHeroId" runat="server"/></div>
                <div class="pemail"><asp:Label ID="lblHeroEmail" runat="server"/></div>
            </div>
        </div>
        <div class="profile-stats">
            <div class="pstat">
                <div class="pstat-val"><asp:Label ID="lblStatCourses" runat="server" Text="0"/></div>
                <div class="pstat-lbl">Active Courses</div>
            </div>
            <div class="pstat">
                <div class="pstat-val"><asp:Label ID="lblStatCredits" runat="server" Text="0"/></div>
                <div class="pstat-lbl">Total Credits</div>
            </div>
            <div class="pstat">
                <div class="pstat-val"><asp:Label ID="lblStatPayments" runat="server" Text="0"/></div>
                <div class="pstat-lbl">Payments Made</div>
            </div>
        </div>
    </div>

    <div class="main">

        <%-- Alerts --%>
        <asp:Panel ID="pnlSuccess" runat="server" CssClass="alert-block alert-success" Visible="false">
            &#10003; Profile updated successfully!
        </asp:Panel>
        <asp:Panel ID="pnlError" runat="server" CssClass="alert-block alert-error" Visible="false">
            <asp:Label ID="lblError" runat="server"/>
        </asp:Panel>

        <%-- ── VIEW PROFILE ── --%>
        <div class="section-label">MY PROFILE INFORMATION</div>
        <div class="view-card">
            <div class="view-grid">
                <div class="view-item">
                    <label>Student ID</label>
                    <div class="val"><asp:Label ID="lblViewId" runat="server" Text="—"/></div>
                </div>
                <div class="view-item">
                    <label>Full Name</label>
                    <div class="val"><asp:Label ID="lblViewName" runat="server" Text="—"/></div>
                </div>
                <div class="view-item">
                    <label>Email Address</label>
                    <div class="val"><asp:Label ID="lblViewEmail" runat="server" Text="—"/></div>
                </div>
                <div class="view-item">
                    <label>Phone Number</label>
                    <div class="val"><asp:Label ID="lblViewPhone" runat="server" Text="—"/></div>
                </div>
                <div class="view-item" style="grid-column:span 2">
                    <label>Address</label>
                    <div class="val"><asp:Label ID="lblViewAddress" runat="server" Text="—"/></div>
                </div>
            </div>
        </div>

        <%-- ── EDIT PROFILE ── --%>
        <div class="section-label">EDIT PROFILE</div>
        <div class="form-card">
            <asp:Panel ID="pnlForm" runat="server">

                <div class="form-row">
                    <div class="form-group">
                        <label>Student ID</label>
                        <asp:TextBox ID="txtStudentId" runat="server" Enabled="false"/>
                    </div>
                    <div class="form-group">
                        <label>Full Name <span style="color:var(--red)">*</span></label>
                        <asp:TextBox ID="txtName" runat="server" placeholder="Enter your full name"/>
                        <asp:RequiredFieldValidator ID="rfvName" runat="server"
                            ControlToValidate="txtName" ErrorMessage="Name is required."
                            CssClass="val-msg" Display="Dynamic"/>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Email Address <span style="color:var(--red)">*</span></label>
                        <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" placeholder="email@university.edu"/>
                        <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                            ControlToValidate="txtEmail" ErrorMessage="Email is required."
                            CssClass="val-msg" Display="Dynamic"/>
                        <asp:RegularExpressionValidator ID="revEmail" runat="server"
                            ControlToValidate="txtEmail"
                            ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                            ErrorMessage="Invalid email format."
                            CssClass="val-msg" Display="Dynamic"/>
                    </div>
                    <div class="form-group">
                        <label>Phone Number</label>
                        <asp:TextBox ID="txtPhone" runat="server" placeholder="0123456789"/>
                        <asp:RegularExpressionValidator ID="revPhone" runat="server"
                            ControlToValidate="txtPhone"
                            ValidationExpression="^[\d\s\-\+\(\)]*$"
                            ErrorMessage="Invalid phone number."
                            CssClass="val-msg" Display="Dynamic"/>
                    </div>
                </div>

                <div class="form-group">
                    <label>Address</label>
                    <asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" Rows="3"
                        placeholder="Enter your complete address"/>
                </div>

                <asp:Button ID="btnUpdate" runat="server" Text="SAVE CHANGES"
                    CssClass="btn-submit" OnClick="btnUpdate_Click"/>

            </asp:Panel>
        </div>

    </div>

</form>
<script src="~/Scripts/NavBar.js"></script>
<script>
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
