<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddDrop.aspx.cs" Inherits="UniversitySystem.AddDrop" %>
<%@ Register Src="~/Controls/NavBar.ascx" TagName="NavBar" TagPrefix="uc" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Course Add / Drop — UniSys</title>
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
        .page-header::before{content:'ADD DROP';position:absolute;right:-1rem;top:50%;transform:translateY(-50%);font-family:'Bebas Neue',sans-serif;font-size:7rem;color:rgba(255,255,255,.06);pointer-events:none;letter-spacing:4px;white-space:nowrap;}
        .page-header h1{font-family:'Bebas Neue',sans-serif;font-size:2.6rem;letter-spacing:3px;color:#FFF;line-height:1;}
        .page-header p{margin-top:.5rem;color:rgba(255,255,255,.75);font-size:.9rem;}

        .main{max-width:960px;margin:0 auto;padding:2.5rem 1.5rem 5rem;}

        .alert-block{border-radius:8px;padding:.85rem 1rem;font-size:.85rem;margin-bottom:1.5rem;display:block;}
        .alert-success{background:#F0FFF7;border:1px solid #B7EBD0;color:#1A7A47;}
        .alert-error  {background:#FFF5F6;border:1px solid #FFCCD2;color:#C0001D;}

        .section-label{font-family:'Bebas Neue',sans-serif;font-size:1rem;letter-spacing:2.5px;color:var(--red);margin-bottom:1rem;display:flex;align-items:center;gap:.7rem;}
        .section-label::after{content:'';flex:1;height:1px;background:var(--border);}

        /* Tabs */
        .tabs{display:flex;gap:.5rem;margin-bottom:1.5rem;}
        .tab-btn{padding:.6rem 1.4rem;border:1.5px solid var(--border);border-radius:8px;font-family:'Bebas Neue',sans-serif;font-size:.9rem;letter-spacing:1.5px;cursor:pointer;background:var(--card-bg);color:var(--muted);transition:all .2s;}
        .tab-btn.active{background:var(--red);color:#FFF;border-color:var(--red);}
        .tab-btn:hover:not(.active){border-color:var(--red);color:var(--red);}

        /* Course table */
        .table-wrap{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);overflow:hidden;box-shadow:0 1px 8px rgba(0,0,0,.06);overflow-x:auto;}
        .data-table{width:100%;border-collapse:collapse;font-size:.86rem;}
        .data-table thead tr{background:#F2F2EF;}
        .data-table th{padding:.85rem 1.1rem;text-align:left;font-weight:700;font-size:.72rem;text-transform:uppercase;letter-spacing:.8px;color:var(--muted);border-bottom:1px solid var(--border);}
        .data-table td{padding:.85rem 1.1rem;border-bottom:1px solid #F0F0EC;vertical-align:middle;}
        .data-table tbody tr:hover{background:#FAFAF8;}
        .data-table tbody tr:last-child td{border-bottom:none;}

        .cc-code{font-family:'Bebas Neue',sans-serif;font-size:.95rem;letter-spacing:1px;color:var(--red);}

        /* Action buttons */
        .btn-drop{background:none;border:1.5px solid #FFCCD2;color:#C0001D;border-radius:7px;padding:.38rem .9rem;font-family:'Bebas Neue',sans-serif;font-size:.78rem;letter-spacing:1px;cursor:pointer;transition:all .2s;}
        .btn-drop:hover{background:#FFF5F6;}
        .btn-add-new{background:var(--red);color:#FFF;border:none;border-radius:7px;padding:.38rem .9rem;font-family:'Bebas Neue',sans-serif;font-size:.78rem;letter-spacing:1px;cursor:pointer;transition:background .2s;}
        .btn-add-new:hover{background:#A8001A;}

        .empty{text-align:center;padding:3.5rem;color:var(--muted);font-size:.88rem;}

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

    <uc:NavBar ID="ucNavBar" runat="server"/>

    <div class="page-header">
        <h1>Course Add / Drop</h1>
        <p>Manage your enrolled courses for the current semester.</p>
    </div>

    <div class="main">

        <asp:Label ID="lblSuccess" runat="server" CssClass="alert-block alert-success" Visible="false" EnableViewState="false"/>
        <asp:Label ID="lblError"   runat="server" CssClass="alert-block alert-error"   Visible="false" EnableViewState="false"/>

        <%-- Tab switcher --%>
        <div class="tabs">
            <asp:Button ID="btnTabEnrolled"  runat="server" Text="MY COURSES"        CssClass="tab-btn active" OnClick="btnTab_Click" CommandArgument="enrolled"  CausesValidation="false"/>
            <asp:Button ID="btnTabAvailable" runat="server" Text="ADD COURSE"        CssClass="tab-btn"        OnClick="btnTab_Click" CommandArgument="available" CausesValidation="false"/>
        </div>

        <%-- ENROLLED COURSES panel --%>
        <asp:Panel ID="pnlEnrolled" runat="server">
            <div class="section-label">ENROLLED COURSES</div>
            <div class="table-wrap">
                <asp:Repeater ID="rptEnrolled" runat="server">
                    <HeaderTemplate>
                        <table class="data-table">
                        <thead><tr>
                            <th>Course Code
                            </th><th>Course Name</th><th>Credits</th><th>Lecturer</th><th>Room</th><th style="text-align:center">Action</th>
                        </tr></thead><tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td><span class="cc-code"><%# Eval("CourseCode") %></span></td>
                            <td><%# Eval("CourseName") %></td>
                            <td><%# Eval("Credits") %></td>
                            <td><%# Eval("LectureName") %></td>
                            <td><%# Eval("ClassRoom") %></td>
                            <td style="text-align:center">
                                <asp:Button runat="server" Text="DROP" CssClass="btn-drop"
                                    CommandArgument='<%# Eval("EnrollmentId") %>'
                                    OnClick="btnDrop_Click" CausesValidation="false"
                                    OnClientClick="return confirm('Drop this course?');"/>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate></tbody></table></FooterTemplate>
                </asp:Repeater>
                <asp:PlaceHolder ID="phNoEnrolled" runat="server" Visible="false">
                    <div class="empty">You have no active enrolments. Use the <strong>ADD COURSE</strong> tab to enrol.</div>
                </asp:PlaceHolder>
            </div>
        </asp:Panel>

        <%-- AVAILABLE COURSES panel --%>
        <asp:Panel ID="pnlAvailable" runat="server" Visible="false">
            <div class="section-label">AVAILABLE TO ADD</div>
            <div class="table-wrap">
                <asp:Repeater ID="rptAvailable" runat="server">
                    <HeaderTemplate>
                        <table class="data-table">
                        <thead><tr>
                            <th>Course Code</th><th>Course Name</th><th>Credits</th><th>Lecturer</th><th>Room</th><th style="text-align:center">Action</th>
                        </tr></thead><tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td><span class="cc-code"><%# Eval("CourseCode") %></span></td>
                            <td><%# Eval("CourseName") %></td>
                            <td><%# Eval("Credits") %></td>
                            <td><%# Eval("LectureName") %></td>
                            <td><%# Eval("ClassRoom") %></td>
                            <td style="text-align:center">
                                <asp:Button runat="server" Text="ADD" CssClass="btn-add-new"
                                    CommandArgument='<%# Eval("CourseId") %>'
                                    OnClick="btnAdd_Click" CausesValidation="false"/>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate></tbody></table></FooterTemplate>
                </asp:Repeater>
                <asp:PlaceHolder ID="phNoAvailable" runat="server" Visible="false">
                    <div class="empty">No additional courses available to add.</div>
                </asp:PlaceHolder>
            </div>
        </asp:Panel>

    </div>
</form>
<script src="~/Scripts/NavBar.js"></script>
<script>
    (function () { var l = document.getElementById('pageLoader'); if (!l) return; window.addEventListener('load', function () { setTimeout(function () { l.classList.add('hidden'); setTimeout(function () { l.style.display = 'none'; }, 400); }, 400); }); })();
</script>
</body>
</html>
