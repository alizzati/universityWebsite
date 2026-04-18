<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Payment.aspx.cs" Inherits="UniversitySystem.Payment" %>
<%@ Register Src="~/Controls/NavBar.ascx" TagName="NavBar" TagPrefix="uc" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Payment — UniSys</title>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:wght@300;400;500;700&display=swap" rel="stylesheet"/>
    <link href="~/Styles/NavBar.css" rel="stylesheet"/>
    <style>
        :root{--red:#C0001D;--red-deep:#8B0015;--red-light:#FFF0F2;--red-glow:rgba(192,0,29,.12);--bg:#F7F7F5;--card-bg:#FFFFFF;--border:#E5E5E0;--text:#1A1A1A;--muted:#6B6B65;--radius:12px;}
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
        body{font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;}
        .page-header{background:linear-gradient(135deg,var(--red-deep) 0%,var(--red) 100%);padding:2.5rem 2.5rem 2.2rem;position:relative;overflow:hidden;}
        .page-header::before{content:'PAYMENT';position:absolute;right:-1rem;top:50%;transform:translateY(-50%);font-family:'Bebas Neue',sans-serif;font-size:8rem;color:rgba(255,255,255,.06);pointer-events:none;letter-spacing:4px;white-space:nowrap;}
        .page-header h1{font-family:'Bebas Neue',sans-serif;font-size:2.6rem;letter-spacing:3px;color:#FFF;line-height:1;}
        .page-header p{margin-top:.5rem;color:rgba(255,255,255,.75);font-size:.9rem;}
        .main{max-width:880px;margin:0 auto;padding:2.5rem 1.5rem 5rem;}
        .student-bar{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);padding:1.2rem 1.8rem;display:flex;align-items:center;justify-content:space-between;margin-bottom:2rem;box-shadow:0 1px 8px rgba(0,0,0,.06);flex-wrap:wrap;gap:.8rem;position:relative;overflow:hidden;}
        .student-bar::before{content:'';position:absolute;left:0;top:0;bottom:0;width:4px;background:var(--red);}
        .student-name{font-weight:700;font-size:1rem;}
        .student-id{font-size:.82rem;color:var(--muted);margin-top:.15rem;}
        .section-label{font-family:'Bebas Neue',sans-serif;font-size:1rem;letter-spacing:2.5px;color:var(--red);margin-bottom:1rem;display:flex;align-items:center;gap:.7rem;}
        .section-label::after{content:'';flex:1;height:1px;background:var(--border);}
        .pay-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));gap:1.2rem;}
        .pay-card{background:var(--card-bg);border:1.5px solid var(--border);border-radius:var(--radius);padding:1.8rem 1.6rem;text-decoration:none;color:var(--text);transition:border-color .2s,box-shadow .2s,transform .15s;display:flex;flex-direction:column;gap:.6rem;box-shadow:0 1px 6px rgba(0,0,0,.05);}
        .pay-card:hover{border-color:var(--red);transform:translateY(-2px);box-shadow:0 6px 20px var(--red-glow);}
        .pay-icon{font-size:2rem;}
        .pay-title{font-family:'Bebas Neue',sans-serif;font-size:1.2rem;letter-spacing:1.5px;color:var(--text);}
        .pay-desc{font-size:.82rem;color:var(--muted);line-height:1.4;}
        .pay-arrow{margin-top:.5rem;font-size:.78rem;color:var(--red);font-weight:700;letter-spacing:.5px;}
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
        <div class="loader-text">Loading...</div>
    </div>

    <uc:NavBar ID="ucNavBar" runat="server"/>

    <div class="page-header">
        <h1>Payment</h1>
        <p>Manage your tuition fees and view payment records.</p>
    </div>

    <div class="main">

        <div class="student-bar">
            <div>
                <div class="student-name"><asp:Label ID="lblStudentName" runat="server"/></div>
                <div class="student-id"><asp:Label ID="lblStudentInfo" runat="server"/></div>
            </div>
        </div>

        <div class="section-label">PAYMENT SERVICES</div>

        <div class="pay-grid">
            <a href="~/OnlinePayment.aspx" runat="server" class="pay-card">
                <div class="pay-icon">&#128179;</div>
                <div class="pay-title">Online Payment</div>
                <div class="pay-desc">Pay your tuition fees and course charges securely. Enrolment is confirmed after payment.</div>
                <div class="pay-arrow">PAY NOW &rarr;</div>
            </a>
            <a href="~/PaymentHistory.aspx" runat="server" class="pay-card">
                <div class="pay-icon">&#128200;</div>
                <div class="pay-title">Payment History / Receipt</div>
                <div class="pay-desc">View all past transactions and download receipts.</div>
                <div class="pay-arrow">VIEW HISTORY &rarr;</div>
            </a>
            <a href="~/invoicepayment.aspx" runat="server" class="pay-card">
                <div class="pay-icon">&#129534;</div>
                <div class="pay-title">Invoice &amp; Adjustment Note</div>
                <div class="pay-desc">View your invoices and any fee adjustment notes by period.</div>
                <div class="pay-arrow">VIEW INVOICES &rarr;</div>
            </a>
        </div>

    </div>
</form>
<script src="~/Scripts/NavBar.js"></script>
<script>
    (function () { var l = document.getElementById('pageLoader'); if (!l) return; window.addEventListener('load', function () { setTimeout(function () { l.classList.add('hidden'); setTimeout(function () { l.style.display = 'none'; }, 400); }, 400); }); })();
</script>
</body>
</html>
