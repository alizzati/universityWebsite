<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="InvoicePayment.aspx.cs" Inherits="UniversitySystem.invoicepayment" %>
<%@ Register Src="~/Controls/NavBar.ascx" TagName="NavBar" TagPrefix="uc" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Invoice — UniSys</title>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:wght@300;400;500;700&display=swap" rel="stylesheet"/>
    <link href="~/Styles/NavBar.css" rel="stylesheet"/>
    <style>
        :root{--red:#C0001D;--red-deep:#8B0015;--red-light:#FFF0F2;--red-glow:rgba(192,0,29,.12);--bg:#F7F7F5;--card-bg:#FFFFFF;--border:#E5E5E0;--text:#1A1A1A;--muted:#6B6B65;--radius:12px;--green:#1A7A47;}
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
        .page-header::before{content:'INVOICE';position:absolute;right:-1rem;top:50%;transform:translateY(-50%);font-family:'Bebas Neue',sans-serif;font-size:8rem;color:rgba(255,255,255,.06);pointer-events:none;letter-spacing:4px;white-space:nowrap;}
        .back-btn{display:inline-flex;align-items:center;gap:.4rem;color:rgba(255,255,255,.75);font-size:.82rem;text-decoration:none;margin-bottom:1rem;transition:color .2s;}
        .back-btn:hover{color:#FFF;}
        .page-header h1{font-family:'Bebas Neue',sans-serif;font-size:2.6rem;letter-spacing:3px;color:#FFF;line-height:1;}
        .page-header p{margin-top:.5rem;color:rgba(255,255,255,.75);font-size:.9rem;}

        .main{max-width:880px;margin:0 auto;padding:2.5rem 1.5rem 5rem;}

        /* Filter bar */
        .filter-bar{display:flex;gap:.8rem;align-items:center;margin-bottom:1.5rem;flex-wrap:wrap;}
        .filter-bar select{padding:.6rem .9rem;border:1.5px solid var(--border);border-radius:8px;font-family:'DM Sans',sans-serif;font-size:.85rem;color:var(--text);background:var(--card-bg);appearance:none;}
        .filter-bar select:focus{outline:none;border-color:var(--red);}
        .btn-download{background:var(--red);color:#FFF;border:none;border-radius:8px;padding:.6rem 1.3rem;font-family:'Bebas Neue',sans-serif;font-size:.85rem;letter-spacing:1.5px;cursor:pointer;display:flex;align-items:center;gap:.5rem;transition:background .2s;margin-left:auto;}
        .btn-download:hover{background:#A8001A;}

        /* Summary cards */
        .summary-row{display:grid;grid-template-columns:repeat(3,1fr);gap:1rem;margin-bottom:2rem;}
        .sum-card{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);padding:1.2rem 1.5rem;box-shadow:0 1px 6px rgba(0,0,0,.05);}
        .sum-card label{font-size:.7rem;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);display:block;margin-bottom:.4rem;}
        .sum-card .val{font-family:'Bebas Neue',sans-serif;font-size:1.4rem;letter-spacing:1px;color:var(--text);}
        .sum-card:last-child .val{color:var(--red);}

        /* Student info */
        .student-bar{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);padding:1rem 1.5rem;display:flex;align-items:center;justify-content:space-between;margin-bottom:1.5rem;box-shadow:0 1px 6px rgba(0,0,0,.05);position:relative;overflow:hidden;}
        .student-bar::before{content:'';position:absolute;left:0;top:0;bottom:0;width:4px;background:var(--red);}
        .student-bar .name{font-weight:700;font-size:.95rem;}

        /* Section label */
        .section-label{font-family:'Bebas Neue',sans-serif;font-size:1rem;letter-spacing:2.5px;color:var(--red);margin-bottom:1rem;display:flex;align-items:center;gap:.7rem;}
        .section-label::after{content:'';flex:1;height:1px;background:var(--border);}

        /* Invoice table */
        .table-wrap{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);overflow:hidden;box-shadow:0 1px 8px rgba(0,0,0,.06);overflow-x:auto;}
        .inv-table{width:100%;border-collapse:collapse;font-size:.86rem;}
        .inv-table thead tr{background:#F2F2EF;}
        .inv-table th{padding:.85rem 1.1rem;text-align:left;font-weight:700;font-size:.72rem;text-transform:uppercase;letter-spacing:.8px;color:var(--muted);border-bottom:1px solid var(--border);}
        .inv-table td{padding:.9rem 1.1rem;border-bottom:1px solid #F0F0EC;vertical-align:middle;}
        .inv-table tbody tr:hover{background:#FAFAF8;}
        .inv-table tbody tr:last-child td{border-bottom:none;}
        .inv-no{font-family:'Bebas Neue',sans-serif;font-size:.95rem;letter-spacing:1px;color:var(--red);}
        .badge-success{background:#F0FFF7;color:#1A7A47;border:1px solid #B7EBD0;border-radius:50px;font-size:.72rem;font-weight:700;padding:.2rem .65rem;}
        .badge-pending{background:#FFFBF0;color:#7A6000;border:1px solid #F0E0A0;border-radius:50px;font-size:.72rem;font-weight:700;padding:.2rem .65rem;}
        .amt-col{font-weight:700;text-align:right;}

        /* ── PRINTABLE INVOICE ── */
        @media print {
            #pageLoader,.site-nav,.filter-bar,.btn-download,
            .page-header,.section-label,#noprint{display:none!important;}
            body{background:white;}
            .main{padding:0;max-width:100%;}
            .print-invoice{display:block!important;}
        }
        .print-invoice{display:none;}
        .inv-header{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:2rem;padding-bottom:1.5rem;border-bottom:2px solid var(--red);}
        .inv-uni-name{font-family:'Bebas Neue',sans-serif;font-size:1.8rem;letter-spacing:3px;color:var(--red-deep);}
        .inv-uni-sub{font-size:.8rem;color:var(--muted);}
        .inv-title{font-family:'Bebas Neue',sans-serif;font-size:1.4rem;letter-spacing:2px;color:var(--text);text-align:right;}
        .inv-no-print{font-size:.85rem;color:var(--muted);text-align:right;}
        .inv-detail{display:grid;grid-template-columns:1fr 1fr;gap:1.5rem;margin-bottom:2rem;}
        .inv-detail-group label{font-size:.7rem;text-transform:uppercase;letter-spacing:.5px;color:var(--muted);display:block;margin-bottom:.2rem;}
        .inv-detail-group .v{font-size:.9rem;font-weight:600;color:var(--text);}

        @media(max-width:600px){.page-header{padding:1.8rem 1rem;}.page-header h1{font-size:2rem;}.main{padding:1.5rem 1rem 4rem;}.summary-row{grid-template-columns:1fr;}}
    </style>
</head>
<body>
<form id="form1" runat="server">

    <div id="pageLoader">
        <div class="loader-logo">UNIV<span>&middot;</span>SYS</div>
        <div class="loader-bar-wrap"><div class="loader-bar"></div></div>
        <div class="loader-text">Loading invoices...</div>
    </div>

    <uc:NavBar ID="ucNavBar" runat="server"/>

    <div class="page-header">
        <a class="back-btn" href="Payment.aspx">&#8592; Back to Payment</a>
        <h1>Invoice &amp; Adjustment Note</h1>
        <p>View and download your payment invoices by period.</p>
    </div>

    <div class="main">

        <%-- Filter + Download bar --%>
        <div class="filter-bar" id="noprint">
            <asp:DropDownList ID="ddlPeriod" runat="server"
                AutoPostBack="true"
                OnSelectedIndexChanged="ddlPeriod_SelectedIndexChanged">
                <asp:ListItem Text="JAN 2026" Value="JAN2026"/>
                <asp:ListItem Text="FEB 2026" Value="FEB2026"/>
                <asp:ListItem Text="MAR 2026" Value="MAR2026"/>
                <asp:ListItem Text="APR 2026" Value="APR2026"/>
                <asp:ListItem Text="MAY 2026" Value="MAY2026"/>
                <asp:ListItem Text="JUN 2026" Value="JUN2026"/>
                <asp:ListItem Text="JUL 2026" Value="JUL2026"/>
                <asp:ListItem Text="AUG 2026" Value="AUG2026"/>
                <asp:ListItem Text="SEP 2026" Value="SEP2026"/>
                <asp:ListItem Text="OCT 2026" Value="OCT2026"/>
                <asp:ListItem Text="NOV 2026" Value="NOV2026"/>
                <asp:ListItem Text="DEC 2026" Value="DEC2026"/>
            </asp:DropDownList>
            <button type="button" class="btn-download" onclick="window.print()">
                &#128438; Download / Print Invoice
            </button>
        </div>

        <%-- Student info --%>
        <div class="student-bar">
            <div>
                <div class="name"><asp:Label ID="lblStudentName" runat="server"/></div>
            </div>
            <div style="font-size:.82rem;color:var(--muted)">
                Period: <strong><asp:Label ID="lblPeriod" runat="server"/></strong>
            </div>
        </div>

        <%-- Summary cards --%>
        <div class="summary-row">
            <div class="sum-card">
                <label>Total Invoices</label>
                <div class="val"><asp:Label ID="lblTotalInvoices" runat="server" Text="RM 0.00"/></div>
            </div>
            <div class="sum-card">
                <label>Scholarship / Waiver</label>
                <div class="val"><asp:Label ID="lblTotalScholarships" runat="server" Text="RM 0.00"/></div>
            </div>
            <div class="sum-card">
                <label>Net Amount</label>
                <div class="val"><asp:Label ID="lblNetAmount" runat="server" Text="RM 0.00"/></div>
            </div>
        </div>

        <div class="section-label">INVOICE DETAILS</div>

        <div class="table-wrap">
            <asp:GridView ID="gvInvoice" runat="server"
                AutoGenerateColumns="false"
                CssClass="inv-table"
                GridLines="None"
                EmptyDataText="No invoice records found for this period.">
                <Columns>
                    <asp:TemplateField HeaderText="Invoice No">
                        <ItemTemplate><span class="inv-no"><%# Eval("Particulars") %></span></ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="Type"         HeaderText="Type"/>
                    <asp:BoundField DataField="DocumentDate" HeaderText="Date"/>
                    <asp:BoundField DataField="course_id"    HeaderText="Course"/>
                    <asp:BoundField DataField="course_name"  HeaderText="Description"/>
                    <asp:BoundField DataField="bank_name"    HeaderText="Payment Method"/>
                    <asp:TemplateField HeaderText="Amount" ItemStyle-CssClass="amt-col" HeaderStyle-CssClass="amt-col">
                        <ItemTemplate>RM <%# string.Format("{0:N2}", Eval("Amount")) %></ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Status" ItemStyle-CssClass="text-center">
                        <ItemTemplate>
                            <span class='<%# Eval("Status").ToString().ToLower() == "success" ? "badge-success" : "badge-pending" %>'>
                                <%# Eval("Status") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>

        <%-- ── PRINT-ONLY INVOICE TEMPLATE ── --%>
        <div class="print-invoice" id="printArea">
            <div class="inv-header">
                <div>
                    <div class="inv-uni-name">UNIV&middot;SYS</div>
                    <div class="inv-uni-sub">UniSys University, No. 1 Jalan Universiti, 71800 Nilai, Malaysia</div>
                </div>
                <div>
                    <div class="inv-title">OFFICIAL INVOICE</div>
                    <div class="inv-no-print">Period: <asp:Label ID="lblPeriodPrint" runat="server"/></div>
                </div>
            </div>
            <div class="inv-detail">
                <div class="inv-detail-group">
                    <label>Bill To</label>
                    <div class="v"><asp:Label ID="lblStudentNamePrint" runat="server"/></div>
                </div>
                <div class="inv-detail-group">
                    <label>Issued On</label>
                    <div class="v"><%=DateTime.Now.ToString("dd MMMM yyyy") %></div>
                </div>
            </div>
            <%-- GridView is also visible during print via CSS --%>
        </div>

    </div>

</form>
<script src="~/Scripts/NavBar.js"></script>
<script>
    (function(){var l=document.getElementById('pageLoader');if(!l)return;window.addEventListener('load',function(){setTimeout(function(){l.classList.add('hidden');setTimeout(function(){l.style.display='none';},400);},400);});})();
</script>
</body>
</html>
