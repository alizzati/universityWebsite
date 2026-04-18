<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OnlineEnrollment.aspx.cs" Inherits="UniversitySystem.OnlineEnrollment" %>
<%@ Register Src="~/Controls/NavBar.ascx" TagName="NavBar" TagPrefix="uc" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Course Enrolment — UniSys</title>
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
        .page-header::before{content:'ENROLMENT';position:absolute;right:-1rem;top:50%;transform:translateY(-50%);font-family:'Bebas Neue',sans-serif;font-size:7rem;color:rgba(255,255,255,.06);pointer-events:none;letter-spacing:4px;white-space:nowrap;}
        .page-header h1{font-family:'Bebas Neue',sans-serif;font-size:2.6rem;letter-spacing:3px;color:#FFF;line-height:1;}
        .page-header p{margin-top:.5rem;color:rgba(255,255,255,.75);font-size:.9rem;}
        .main{max-width:960px;margin:0 auto;padding:2.5rem 1.5rem 5rem;}
        .alert-block{border-radius:8px;padding:.85rem 1rem;font-size:.85rem;margin-bottom:1.5rem;display:block;}
        .alert-success{background:#F0FFF7;border:1px solid #B7EBD0;color:#1A7A47;}
        .alert-error  {background:#FFF5F6;border:1px solid #FFCCD2;color:#C0001D;}
        .alert-warning{background:#FFFBF0;border:1px solid #F0E0A0;color:#7A6000;}
        .section-label{font-family:'Bebas Neue',sans-serif;font-size:1rem;letter-spacing:2.5px;color:var(--red);margin-bottom:1rem;display:flex;align-items:center;gap:.7rem;}
        .section-label::after{content:'';flex:1;height:1px;background:var(--border);}
        .info-card{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);padding:1.2rem 1.8rem;display:flex;align-items:center;justify-content:space-between;margin-bottom:2rem;box-shadow:0 1px 8px rgba(0,0,0,.06);flex-wrap:wrap;gap:.8rem;position:relative;overflow:hidden;}
        .info-card::before{content:'';position:absolute;left:0;top:0;bottom:0;width:4px;background:var(--red);}
        .info-card .name{font-weight:700;font-size:1rem;}
        .info-card .sid{font-size:.82rem;color:var(--muted);margin-top:.15rem;}
        .credit-badge{font-family:'Bebas Neue',sans-serif;font-size:1.1rem;letter-spacing:1px;color:var(--red);}
        .credit-label{font-size:.72rem;color:var(--muted);text-transform:uppercase;letter-spacing:.6px;}

        /* Course table with checkboxes */
        .table-wrap{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);overflow:hidden;box-shadow:0 1px 8px rgba(0,0,0,.06);overflow-x:auto;margin-bottom:1.5rem;}
        .data-table{width:100%;border-collapse:collapse;font-size:.86rem;}
        .data-table thead tr{background:#F2F2EF;}
        .data-table th{padding:.85rem 1.1rem;text-align:left;font-weight:700;font-size:.72rem;text-transform:uppercase;letter-spacing:.8px;color:var(--muted);border-bottom:1px solid var(--border);}
        .data-table td{padding:.85rem 1.1rem;border-bottom:1px solid #F0F0EC;vertical-align:middle;}
        .data-table tbody tr:hover{background:#FAFAF8;}
        .data-table tbody tr:last-child td{border-bottom:none;}
        .data-table tbody tr.row-enrolled{background:#F8FFFC;}
        .data-table tbody tr.row-pending{background:#FFFBF0;}
        .cc-code{font-family:'Bebas Neue',sans-serif;font-size:.95rem;letter-spacing:1px;color:var(--red);}

        /* Custom checkbox */
        .chk-wrap{display:flex;align-items:center;justify-content:center;}
        .chk-wrap input[type=checkbox]{width:18px;height:18px;accent-color:var(--red);cursor:pointer;}
        .chk-wrap input[type=checkbox]:disabled{cursor:not-allowed;opacity:.5;}

        /* Badges */
        .badge{display:inline-block;padding:.2rem .7rem;border-radius:50px;font-size:.72rem;font-weight:700;letter-spacing:.3px;}
        .badge-active {background:#F0FFF7;color:#1A7A47;border:1px solid #B7EBD0;}
        .badge-pending{background:#FFFBF0;color:#7A6000;border:1px solid #F0E0A0;}

        /* Cart / selection bar */
        .cart-bar{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);padding:1.2rem 1.5rem;display:flex;align-items:center;justify-content:space-between;gap:1rem;flex-wrap:wrap;box-shadow:0 2px 12px rgba(0,0,0,.08);position:sticky;bottom:1.5rem;z-index:50;}
        .cart-info{font-size:.9rem;color:var(--muted);}
        .cart-info strong{color:var(--red);font-family:'Bebas Neue',sans-serif;font-size:1.2rem;letter-spacing:1px;}
        .btn-proceed{background:var(--red);color:#FFF;border:none;border-radius:9px;padding:.85rem 2rem;font-family:'Bebas Neue',sans-serif;font-size:1rem;letter-spacing:2px;cursor:pointer;transition:background .2s,transform .15s,box-shadow .2s;}
        .btn-proceed:hover{background:#A8001A;transform:translateY(-1px);box-shadow:0 6px 20px rgba(192,0,29,.3);}
        .btn-proceed:active{transform:translateY(0);}

        .empty{text-align:center;padding:4rem 2rem;color:var(--muted);}
        .empty-icon{font-size:3rem;margin-bottom:1rem;}
        @media(max-width:600px){.page-header{padding:1.8rem 1rem;}.page-header h1{font-size:2rem;}.main{padding:1.5rem 1rem 5rem;}}
    </style>
</head>
<body>
<form id="form1" runat="server">

    <div id="pageLoader">
        <div class="loader-logo">UNIV<span>&middot;</span>SYS</div>
        <div class="loader-bar-wrap"><div class="loader-bar"></div></div>
        <div class="loader-text">Loading courses...</div>
    </div>

    <uc:NavBar ID="ucNavBar" runat="server"/>

    <div class="page-header">
        <h1>Course Enrolment</h1>
        <p>Select the courses you want to enrol in, then proceed to payment.</p>
    </div>

    <div class="main">

        <div class="alert-block alert-warning" style="display:block">
            &#128179; <strong>Note:</strong> Tick the courses you want to enrol in, then click <strong>PROCEED TO PAYMENT</strong>. Your enrolment is only confirmed after successful payment.
        </div>

        <asp:Label ID="lblSuccess" runat="server" CssClass="alert-block alert-success" Visible="false" EnableViewState="false"/>
        <asp:Label ID="lblError"   runat="server" CssClass="alert-block alert-error"   Visible="false" EnableViewState="false"/>

        <%-- Student info --%>
        <div class="info-card">
            <div>
                <div class="name"><asp:Label ID="lblStudentName" runat="server" Text="Student"/></div>
                <div class="sid">Student ID: <asp:Label ID="lblStudentId" runat="server"/></div>
            </div>
            <div style="text-align:right">
                <div class="credit-badge"><asp:Label ID="lblCreditHours" runat="server" Text="0"/> Credits</div>
                <div class="credit-label">Active enrollments</div>
            </div>
        </div>

        <div class="section-label">AVAILABLE COURSES</div>

        <div class="table-wrap">
            <asp:Repeater ID="rptCourses" runat="server">
                <HeaderTemplate>
                    <table class="data-table">
                    <thead><tr>
                        <th style="width:44px;text-align:center">
                            <input type="checkbox" id="chkAll" onclick="toggleAll(this)" title="Select all available"/>
                        </th>
                        <th>Course Code</th>
                        <th>Course Name</th>
                        <th>Credits</th>
                        <th>Lecturer</th>
                        <th>Room</th>
                        <th style="text-align:center">Status</th>
                    </tr></thead><tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr class='<%# Eval("EnrolStatus").ToString() == "Active" ? "row-enrolled" : Eval("EnrolStatus").ToString() == "Pending Payment" ? "row-pending" : "" %>'>
                        <td class="chk-wrap">
                            <%-- Hidden field carries courseId back to server --%>
                            <asp:HiddenField ID="hidCourseId" runat="server" Value='<%# Eval("CourseId") %>'/>
                            <%-- Checkbox disabled if already enrolled/pending --%>
                            <asp:CheckBox ID="chkEnrol" runat="server" CssClass="enrol-chk"
                                Enabled='<%# Eval("EnrolStatus").ToString() == "None" %>'
                                onchange="updateCount()"/>
                        </td>
                        <td><span class="cc-code"><%# Eval("CourseId") %></span></td>
                        <td><%# Eval("CourseName") %></td>
                        <td><%# Eval("Credits") %></td>
                        <td><%# Eval("LectureName") %></td>
                        <td><%# Eval("ClassRoom") %></td>
                        <td style="text-align:center">
                            <%# Eval("EnrolStatus").ToString() == "Active"
                                ? "<span class='badge badge-active'>&#10003; Enrolled</span>"
                                : Eval("EnrolStatus").ToString() == "Pending Payment"
                                ? "<span class='badge badge-pending'>&#9201; Pending Payment</span>"
                                : "<span style='font-size:.78rem;color:var(--muted)'>Available</span>" %>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate></tbody></table></FooterTemplate>
            </asp:Repeater>
        </div>

        <asp:PlaceHolder ID="phEmpty" runat="server" Visible="false">
            <div class="empty">
                <div class="empty-icon">&#128218;</div>
                <p>No courses available for enrolment at this time.</p>
            </div>
        </asp:PlaceHolder>

        <%-- Sticky cart bar --%>
        <div class="cart-bar">
            <div class="cart-info">
                <strong id="selCount">0</strong> course(s) selected
            </div>
            <asp:Button ID="btnProceedPayment" runat="server"
                Text="PROCEED TO PAYMENT →"
                CssClass="btn-proceed"
                OnClick="btnProceedPayment_Click"
                CausesValidation="false"/>
        </div>

    </div>
</form>
<script src="~/Scripts/NavBar.js"></script>
<script>
    function updateCount() {
        var chks = document.querySelectorAll('.enrol-chk input[type=checkbox]:not(:disabled)');
        var n = 0;
        chks.forEach(function (c) { if (c.checked) n++; });
        document.getElementById('selCount').textContent = n;
    }
    function toggleAll(master) {
        var chks = document.querySelectorAll('.enrol-chk input[type=checkbox]:not(:disabled)');
        chks.forEach(function (c) { c.checked = master.checked; });
        updateCount();
    }
    (function () { var l = document.getElementById('pageLoader'); if (!l) return; window.addEventListener('load', function () { setTimeout(function () { l.classList.add('hidden'); setTimeout(function () { l.style.display = 'none'; }, 400); }, 400); }); })();
</script>
</body>
</html>
