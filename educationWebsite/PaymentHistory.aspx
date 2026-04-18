<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PaymentHistory.aspx.cs" Inherits="UniversitySystem.PaymentHistory" %>
<%@ Register Src="~/Controls/NavBar.ascx" TagName="NavBar" TagPrefix="uc" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Payment History — UniSys</title>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:wght@300;400;500;700&display=swap" rel="stylesheet"/>
    <link href="~/Styles/NavBar.css" rel="stylesheet"/>
    <style>
        :root{--red:#C0001D;--red-deep:#8B0015;--red-light:#FFF0F2;--red-glow:rgba(192,0,29,.12);--bg:#F7F7F5;--card-bg:#FFFFFF;--border:#E5E5E0;--text:#1A1A1A;--muted:#6B6B65;--radius:12px;}
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
        body{font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;}
        .page-header{background:linear-gradient(135deg,var(--red-deep) 0%,var(--red) 100%);padding:2.5rem 2.5rem 2.2rem;position:relative;overflow:hidden;}
        .page-header::before{content:'HISTORY';position:absolute;right:-1rem;top:50%;transform:translateY(-50%);font-family:'Bebas Neue',sans-serif;font-size:8rem;color:rgba(255,255,255,.06);pointer-events:none;letter-spacing:4px;white-space:nowrap;}
        .back-btn{display:inline-flex;align-items:center;gap:.4rem;color:rgba(255,255,255,.75);font-size:.82rem;text-decoration:none;margin-bottom:1rem;transition:color .2s;}
        .back-btn:hover{color:#FFF;}
        .page-header h1{font-family:'Bebas Neue',sans-serif;font-size:2.6rem;letter-spacing:3px;color:#FFF;line-height:1;}
        .page-header p{margin-top:.5rem;color:rgba(255,255,255,.75);font-size:.9rem;}
        .main{max-width:960px;margin:0 auto;padding:2.5rem 1.5rem 5rem;}
        .alert-block{border-radius:8px;padding:.8rem 1rem;font-size:.85rem;margin-bottom:1.4rem;display:block;}
        .alert-success{background:#F0FFF7;border:1px solid #B7EBD0;color:#1A7A47;}
        .table-wrap{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);overflow:hidden;box-shadow:0 1px 8px rgba(0,0,0,.06);overflow-x:auto;}
        .data-table{width:100%;border-collapse:collapse;font-size:.86rem;}
        .data-table thead tr{background:#F2F2EF;}
        .data-table th{padding:.85rem 1.1rem;text-align:left;font-weight:700;font-size:.72rem;text-transform:uppercase;letter-spacing:.8px;color:var(--muted);border-bottom:1px solid var(--border);}
        .data-table td{padding:.9rem 1.1rem;border-bottom:1px solid #F0F0EC;vertical-align:middle;}
        .data-table tbody tr:hover{background:#FAFAF8;}
        .data-table tbody tr:last-child td{border-bottom:none;}
        .inv{font-family:'Bebas Neue',sans-serif;font-size:.95rem;letter-spacing:1px;color:var(--red);}
        .ccode{font-weight:700;}
        .csub{font-size:.75rem;color:var(--muted);}
        .badge{display:inline-block;padding:.25rem .75rem;border-radius:50px;font-size:.72rem;font-weight:700;letter-spacing:.4px;text-transform:uppercase;}
        .badge-success{background:#F0FFF7;color:#1A7A47;border:1px solid #B7EBD0;}
        .badge-pending{background:#FFFBF0;color:#7A6000;border:1px solid #F0E0A0;}
        .badge-failed {background:#FFF5F6;color:#C0001D;border:1px solid #FFCCD2;}
        .amt{font-weight:700;font-size:.92rem;text-align:right;}
        .btn-inv{font-size:.72rem;color:var(--red);text-decoration:none;font-weight:700;border:1px solid var(--red);border-radius:5px;padding:.2rem .55rem;transition:all .18s;white-space:nowrap;}
        .btn-inv:hover{background:var(--red);color:#FFF;}
        .empty{text-align:center;padding:4rem 2rem;}
        .empty-icon{font-size:3rem;margin-bottom:1rem;}
        .empty h3{font-family:'Bebas Neue',sans-serif;font-size:1.4rem;letter-spacing:2px;color:var(--muted);margin-bottom:.5rem;}
        .empty p{font-size:.85rem;color:var(--muted);margin-bottom:1.5rem;}
        .btn-pay{display:inline-block;padding:.75rem 1.8rem;background:var(--red);color:#FFF;font-family:'Bebas Neue',sans-serif;font-size:1rem;letter-spacing:2px;border-radius:9px;text-decoration:none;transition:background .2s;}
        .btn-pay:hover{background:#A8001A;}
        #pageLoader{position:fixed;inset:0;background:#FFF;z-index:9999;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:1.5rem;transition:opacity .4s;}
        #pageLoader.hidden{opacity:0;pointer-events:none;}
        .loader-logo{font-family:'Bebas Neue',sans-serif;font-size:2.4rem;letter-spacing:3px;color:#8B0015;}
        .loader-logo span{color:rgba(139,0,21,.3);}
        .loader-bar-wrap{width:200px;height:3px;background:#EFEFEC;border-radius:2px;overflow:hidden;}
        .loader-bar{height:100%;width:0%;background:linear-gradient(90deg,#8B0015,#C0001D);border-radius:2px;animation:lp 1.2s ease forwards;}
        @keyframes lp{0%{width:0%}60%{width:75%}100%{width:100%}}
        .loader-text{font-size:.78rem;color:#6B6B65;letter-spacing:1px;font-weight:500;text-transform:uppercase;}
        @media(max-width:600px){.page-header{padding:1.8rem 1rem;}.page-header h1{font-size:2rem;}.main{padding:1.5rem 1rem 4rem;}}
    </style>
</head>
<body>
<form id="form1" runat="server">

    <div id="pageLoader">
        <div class="loader-logo">UNIV<span>&middot;</span>SYS</div>
        <div class="loader-bar-wrap"><div class="loader-bar"></div></div>
        <div class="loader-text">Loading history...</div>
    </div>

    <uc:NavBar ID="ucNavBar" runat="server"/>

    <div class="page-header">
        <a class="back-btn" href="~/Payment.aspx" runat="server">&#8592; Back to Payment</a>
        <h1>Payment History</h1>
        <p>All your payment transactions and receipts.</p>
    </div>

    <div class="main">

        <asp:Label ID="lblPaidNotice" runat="server" CssClass="alert-block alert-success" Visible="false"
            Text="&#10003; Payment submitted successfully! Your enrolment is now Active."/>

        <div class="table-wrap">
            <asp:Repeater ID="rptPaymentHistory" runat="server">
                <HeaderTemplate>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Invoice No</th>
                                <th>Date</th>
                                <th>Course</th>
                                <th>Bank</th>
                                <th style="text-align:right">Amount</th>
                                <th style="text-align:center">Status</th>
                                <th style="text-align:center">Invoice</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><span class="inv">INV-<%# Eval("payment_id","{0:0000}") %></span></td>
                        <td><%# Eval("created_at","{0:dd MMM yyyy}") %></td>
                        <td>
                            <span class="ccode"><%# Eval("course_id") %></span><br/>
                            <span class="csub"><%# Eval("course_name") %></span>
                        </td>
                        <td><%# Eval("bank_name") %></td>
                        <td class="amt">RM <%# Eval("amount","{0:N0}") %></td>
                        <td style="text-align:center">
                            <span class='badge <%# GetBadgeClass(Eval("status").ToString()) %>'><%# Eval("status") %></span>
                        </td>
                        <td style="text-align:center">
                            <%-- Invoice link for each payment row --%>
                            <a href='<%# "invoicepayment.aspx?pid=" + Eval("payment_id") %>' class="btn-inv">&#128196; VIEW</a>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>

            <asp:PlaceHolder ID="phNoData" runat="server" Visible="false">
                <div class="empty">
                    <div class="empty-icon">&#128200;</div>
                    <h3>No Transactions Yet</h3>
                    <p>Enrol in a course to generate a payment.</p>
                    <a href="OnlineEnrollment.aspx" class="btn-pay">ENROL NOW</a>
                </div>
            </asp:PlaceHolder>
        </div>

    </div>
</form>
<script src="~/Scripts/NavBar.js"></script>
<script>
    (function () { var l = document.getElementById('pageLoader'); if (!l) return; window.addEventListener('load', function () { setTimeout(function () { l.classList.add('hidden'); setTimeout(function () { l.style.display = 'none'; }, 400); }, 400); }); })();
</script>
</body>
</html>
