<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentStatement.aspx.cs" Inherits="UniversitySystem.StudentStatement" %>
<%@ Register Src="~/Controls/NavBar.ascx" TagPrefix="uc" TagName="NavBar" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Student Statement — UniSys</title>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:wght@300;400;500;700&display=swap" rel="stylesheet"/>
    <link href="~/Styles/NavBar.css" rel="stylesheet"/>
    <style>
        :root{--red:#C0001D;--red-deep:#8B0015;--red-light:#FFF0F2;--red-glow:rgba(192,0,29,.12);--bg:#F7F7F5;--card-bg:#FFFFFF;--border:#E5E5E0;--text:#1A1A1A;--muted:#6B6B65;--radius:12px;--green:#1A7A47;--green-light:#F0FFF7;}
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
        .page-header::before{content:'STATEMENT';position:absolute;right:-1rem;top:50%;transform:translateY(-50%);font-family:'Bebas Neue',sans-serif;font-size:7rem;color:rgba(255,255,255,.06);pointer-events:none;letter-spacing:4px;white-space:nowrap;}
        .page-header h1{font-family:'Bebas Neue',sans-serif;font-size:2.6rem;letter-spacing:3px;color:#FFF;line-height:1;}
        .page-header p{margin-top:.5rem;color:rgba(255,255,255,.75);font-size:.9rem;}

        .main{max-width:900px;margin:0 auto;padding:2.5rem 1.5rem 5rem;}

        /* Action bar */
        .action-bar{display:flex;justify-content:flex-end;gap:.8rem;margin-bottom:1.5rem;}
        .btn-print{background:var(--red);color:#FFF;border:none;border-radius:9px;padding:.72rem 1.5rem;font-family:'Bebas Neue',sans-serif;font-size:.95rem;letter-spacing:2px;cursor:pointer;display:flex;align-items:center;gap:.5rem;transition:background .2s;}
        .btn-print:hover{background:#A8001A;}

        /* Statement card */
        .stmt-card{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);padding:2.5rem;box-shadow:0 2px 16px rgba(0,0,0,.06);}

        /* Header inside statement */
        .stmt-header{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:2rem;padding-bottom:1.5rem;border-bottom:2px solid var(--red);}
        .stmt-uni{font-family:'Bebas Neue',sans-serif;font-size:1.6rem;letter-spacing:3px;color:var(--red-deep);}
        .stmt-uni-sub{font-size:.78rem;color:var(--muted);margin-top:.2rem;}
        .stmt-title-block{text-align:right;}
        .stmt-title{font-family:'Bebas Neue',sans-serif;font-size:1.2rem;letter-spacing:2px;color:var(--text);}
        .stmt-id{font-size:.78rem;color:var(--muted);margin-top:.25rem;}

        /* Info grid */
        .info-grid{display:grid;grid-template-columns:1fr 1fr;gap:1.5rem;margin-bottom:2rem;}
        .info-group label{font-size:.7rem;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);display:block;margin-bottom:.25rem;}
        .info-group .val{font-size:.95rem;font-weight:600;color:var(--text);}

        /* Section label */
        .section-label{font-family:'Bebas Neue',sans-serif;font-size:.9rem;letter-spacing:2px;color:var(--red);margin:1.5rem 0 .8rem;display:flex;align-items:center;gap:.7rem;}
        .section-label::after{content:'';flex:1;height:1px;background:var(--border);}

        /* Tables */
        .stmt-table{width:100%;border-collapse:collapse;font-size:.85rem;margin-bottom:.5rem;}
        .stmt-table thead tr{background:#F2F2EF;}
        .stmt-table th{padding:.7rem .9rem;text-align:left;font-weight:700;font-size:.7rem;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);border-bottom:1px solid var(--border);}
        .stmt-table td{padding:.7rem .9rem;border-bottom:1px solid #F0F0EC;vertical-align:middle;}
        .stmt-table tr:last-child td{border-bottom:none;}
        .stmt-table tr:hover td{background:#FAFAF8;}
        .cc-code{font-family:'Bebas Neue',sans-serif;font-size:.9rem;letter-spacing:1px;color:var(--red);}
        .amt{font-weight:700;text-align:right;}
        .badge-success{background:var(--green-light);color:var(--green);border:1px solid #B7EBD0;border-radius:50px;font-size:.7rem;font-weight:700;padding:.15rem .6rem;}
        .badge-pending{background:#FFFBF0;color:#7A6000;border:1px solid #F0E0A0;border-radius:50px;font-size:.7rem;font-weight:700;padding:.15rem .6rem;}

        /* Balance box */
        .balance-box{display:flex;justify-content:flex-end;margin-top:1.5rem;padding-top:1.5rem;border-top:2px solid var(--border);}
        .balance-inner{text-align:right;}
        .balance-label{font-size:.75rem;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:.3rem;}
        .balance-amount{font-family:'Bebas Neue',sans-serif;font-size:2rem;letter-spacing:2px;}
        .balance-amount.zero{color:var(--green);}
        .balance-amount.owing{color:var(--red);}
        .balance-note{font-size:.72rem;color:var(--muted);margin-top:.2rem;}

        /* Error */
        .error-box{background:#FFF5F6;border:1px solid #FFCCD2;border-radius:var(--radius);padding:1.5rem;color:#C0001D;}

        /* ── PRINT STYLES ── */
        @media print {
            #pageLoader, .site-nav, .action-bar { display:none !important; }
            body { background: white; }
            .main { padding: 0; max-width: 100%; }
            .stmt-card { box-shadow: none; border: none; padding: 1rem; }
            .page-header { display: none; }
        }

        @media(max-width:600px){
            .page-header{padding:1.8rem 1rem;}.page-header h1{font-size:2rem;}
            .main{padding:1.5rem 1rem 4rem;}
            .info-grid{grid-template-columns:1fr;}
            .stmt-header{flex-direction:column;gap:1rem;}
            .stmt-title-block{text-align:left;}
        }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <div id="pageLoader">
        <div class="loader-logo">UNIV<span>&middot;</span>SYS</div>
        <div class="loader-bar-wrap"><div class="loader-bar"></div></div>
        <div class="loader-text">Loading statement...</div>
    </div>

    <uc:NavBar ID="ucNavBar" runat="server"/>

    <div class="page-header">
        <h1>Student Statement</h1>
        <p>Your financial summary — enrolled courses and payment history.</p>
    </div>

    <div class="main">

        <asp:Panel ID="pnlError" runat="server" Visible="false">
            <div class="error-box">
                <strong>Error:</strong> <asp:Label ID="lblError" runat="server"/>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlStatement" runat="server">

            <%-- Action bar (hidden during print) --%>
            <div class="action-bar">
                <button type="button" class="btn-print" onclick="window.print()">
                    &#128438; Download / Print PDF
                </button>
            </div>

            <div class="stmt-card" id="statementContent">

                <%-- Statement header --%>
                <div class="stmt-header">
                    <div>
                        <div class="stmt-uni">UNIV&middot;SYS</div>
                        <div class="stmt-uni-sub">UniSys University, No. 1 Jalan Universiti, 71800 Nilai, Malaysia</div>
                    </div>
                    <div class="stmt-title-block">
                        <div class="stmt-title">STUDENT STATEMENT</div>
                        <div class="stmt-id">Ref: <asp:Label ID="lblStatementId" runat="server"/></div>
                        <div class="stmt-id">Date: <asp:Label ID="lblStatementDate" runat="server"/></div>
                    </div>
                </div>

                <%-- Student information --%>
                <div class="section-label">STUDENT INFORMATION</div>
                <div class="info-grid">
                    <div class="info-group">
                        <label>Full Name</label>
                        <div class="val"><asp:Label ID="lblStudentName" runat="server"/></div>
                    </div>
                    <div class="info-group">
                        <label>Student ID</label>
                        <div class="val"><asp:Label ID="lblStudentId" runat="server"/></div>
                    </div>
                    <div class="info-group">
                        <label>Email Address</label>
                        <div class="val"><asp:Label ID="lblEmail" runat="server"/></div>
                    </div>
                    <div class="info-group">
                        <label>Statement Period</label>
                        <div class="val">Current Semester</div>
                    </div>
                </div>

                <%-- Enrolled courses --%>
                <div class="section-label">ENROLLED COURSES</div>
                <asp:GridView ID="gvCourses" runat="server"
                    AutoGenerateColumns="false"
                    CssClass="stmt-table"
                    GridLines="None"
                    EmptyDataText="No active enrolments found.">
                    <Columns>
                        <asp:TemplateField HeaderText="Course Code">
                            <ItemTemplate><span class="cc-code"><%# Eval("course_code") %></span></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="course_name" HeaderText="Course Name"/>
                        <asp:BoundField DataField="credits"     HeaderText="Credits"/>
                        <asp:TemplateField HeaderText="Fee (RM)" ItemStyle-CssClass="amt" HeaderStyle-CssClass="amt">
                            <ItemTemplate>RM <%# string.Format("{0:N2}", Eval("amount")) %></ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>

                <%-- Payment history --%>
                <div class="section-label">PAYMENT HISTORY</div>
                <asp:GridView ID="gvPayments" runat="server"
                    AutoGenerateColumns="false"
                    CssClass="stmt-table"
                    GridLines="None"
                    EmptyDataText="No payment records found.">
                    <Columns>
                        <asp:BoundField DataField="payment_date" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}"/>
                        <asp:BoundField DataField="reference_no" HeaderText="Reference No"/>
                        <asp:BoundField DataField="description"  HeaderText="Description"/>
                        <asp:BoundField DataField="bank_name"    HeaderText="Bank"/>
                        <asp:TemplateField HeaderText="Amount (RM)" ItemStyle-CssClass="amt" HeaderStyle-CssClass="amt">
                            <ItemTemplate>RM <%# string.Format("{0:N2}", Eval("amount")) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='<%# Eval("status").ToString().ToLower() == "success" ? "badge-success" : "badge-pending" %>'>
                                    <%# Eval("status") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>

                <%-- Balance --%>
                <div class="balance-box">
                    <div class="balance-inner">
                        <div class="balance-label">Outstanding Balance</div>
                        <div class="balance-amount" id="balanceAmt">
                            RM <asp:Label ID="lblTotalBalance" runat="server" Text="0.00"/>
                        </div>
                        <div class="balance-note">Amount due after deducting all successful payments.</div>
                    </div>
                </div>

            </div><%-- /stmt-card --%>

        </asp:Panel>

    </div>
</form>
<script src="~/Scripts/NavBar.js"></script>
<script>
    (function(){
        var l=document.getElementById('pageLoader');
        if(!l) return;
        l.classList.add('hidden');
        setTimeout(function(){ l.style.display='none'; }, 400);
    })();

    // Color balance amount
    (function(){
        var lbl = document.querySelector('#balanceAmt span');
        if(!lbl) return;
        var val = parseFloat(lbl.textContent.replace(/[^0-9.]/g,''));
        var box = document.getElementById('balanceAmt');
        if(box) box.classList.add(val <= 0 ? 'zero' : 'owing');
    })();
</script>
</body>
</html>
