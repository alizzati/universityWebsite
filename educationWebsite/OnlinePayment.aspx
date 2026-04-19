<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OnlinePayment.aspx.cs" Inherits="UniversitySystem.OnlinePayment" %>
<%@ Register Src="~/Controls/NavBar.ascx" TagName="NavBar" TagPrefix="uc" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Online Payment — UniSys</title>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:wght@300;400;500;700&display=swap" rel="stylesheet"/>
    <link href="~/Styles/NavBar.css" rel="stylesheet"/>
    <style>
        :root{--red:#C0001D;--red-deep:#8B0015;--red-light:#FFF0F2;--red-glow:rgba(192,0,29,.12);--bg:#F7F7F5;--card-bg:#FFFFFF;--border:#E5E5E0;--text:#1A1A1A;--muted:#6B6B65;--radius:12px;--green:#1A7A47;--green-light:#F0FFF7;}
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
        body{font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;}

        /* pageLoader — hidden immediately on DOMContentLoaded */
        #pageLoader{position:fixed;inset:0;background:#FFF;z-index:9999;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:1.5rem;transition:opacity .35s;}
        #pageLoader.hidden{opacity:0;pointer-events:none;}
        .loader-logo{font-family:'Bebas Neue',sans-serif;font-size:2.4rem;letter-spacing:3px;color:#8B0015;}
        .loader-logo span{color:rgba(139,0,21,.3);}
        .loader-bar-wrap{width:200px;height:3px;background:#EFEFEC;border-radius:2px;overflow:hidden;}
        .loader-bar{height:100%;width:0%;background:linear-gradient(90deg,#8B0015,#C0001D);border-radius:2px;animation:lp 1.2s ease forwards;}
        @keyframes lp{0%{width:0%}60%{width:75%}100%{width:100%}}
        .loader-text{font-size:.78rem;color:#6B6B65;letter-spacing:1px;font-weight:500;text-transform:uppercase;}

        /* Processing overlay — fixed, covers entire screen while postback runs */
        #processingOverlay{display:none;position:fixed;inset:0;background:rgba(255,255,255,.95);z-index:8888;flex-direction:column;align-items:center;justify-content:center;gap:1.5rem;}
        #processingOverlay.show{display:flex;}
        .spin{width:58px;height:58px;border:4px solid #EEE;border-top-color:var(--red);border-radius:50%;animation:sp .9s linear infinite;}
        @keyframes sp{to{transform:rotate(360deg)}}
        .proc-title{font-family:'Bebas Neue',sans-serif;font-size:1.6rem;letter-spacing:2px;color:var(--text);}
        .proc-sub{font-size:.85rem;color:var(--muted);text-align:center;max-width:280px;line-height:1.5;}

        .page-header{background:linear-gradient(135deg,var(--red-deep) 0%,var(--red) 100%);padding:2.5rem 2.5rem 2.2rem;position:relative;overflow:hidden;}
        .page-header::before{content:'PAYMENT';position:absolute;right:-1rem;top:50%;transform:translateY(-50%);font-family:'Bebas Neue',sans-serif;font-size:8rem;color:rgba(255,255,255,.06);pointer-events:none;letter-spacing:4px;white-space:nowrap;}
        .back-btn{display:inline-flex;align-items:center;gap:.4rem;color:rgba(255,255,255,.75);font-size:.82rem;text-decoration:none;margin-bottom:1rem;transition:color .2s;}
        .back-btn:hover{color:#FFF;}
        .page-header h1{font-family:'Bebas Neue',sans-serif;font-size:2.6rem;letter-spacing:3px;color:#FFF;line-height:1;}
        .page-header p{margin-top:.5rem;color:rgba(255,255,255,.75);font-size:.9rem;}

        .main{max-width:720px;margin:0 auto;padding:2.5rem 1.5rem 5rem;}

        .alert-block{border-radius:8px;padding:.85rem 1rem;font-size:.85rem;margin-bottom:1.4rem;display:block;}
        .alert-error  {background:#FFF5F6;border:1px solid #FFCCD2;color:#C0001D;}
        .alert-success{background:var(--green-light);border:1px solid #B7EBD0;color:var(--green);}

        /* Steps */
        .steps-bar{display:flex;align-items:center;margin-bottom:2rem;}
        .step-item{display:flex;flex-direction:column;align-items:center;flex:1;position:relative;}
        .step-item:not(:last-child)::after{content:'';position:absolute;top:16px;left:50%;width:100%;height:2px;background:var(--border);z-index:0;}
        .step-item.done::after,.step-item.active::after{background:var(--red);}
        .step-dot{width:32px;height:32px;border-radius:50%;border:2px solid var(--border);background:var(--card-bg);display:flex;align-items:center;justify-content:center;font-size:.78rem;font-weight:700;color:var(--muted);z-index:1;position:relative;}
        .step-item.done .step-dot{background:var(--green);border-color:var(--green);color:#FFF;}
        .step-item.active .step-dot{background:var(--red);border-color:var(--red);color:#FFF;}
        .step-label{font-size:.68rem;color:var(--muted);margin-top:.4rem;text-align:center;font-weight:500;}
        .step-item.active .step-label{color:var(--red);font-weight:700;}
        .step-item.done .step-label{color:var(--green);}

        .pay-card{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);padding:1.8rem 2rem;margin-bottom:1.4rem;box-shadow:0 2px 12px rgba(0,0,0,.06);}
        .pay-card h3{font-family:'Bebas Neue',sans-serif;font-size:1rem;letter-spacing:2px;color:var(--text);margin-bottom:1.2rem;display:flex;align-items:center;gap:.6rem;}
        .pay-card h3::after{content:'';flex:1;height:1px;background:var(--border);}

        .field{margin-bottom:1.2rem;}
        .field label{display:block;font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.7px;color:var(--muted);margin-bottom:.42rem;}
        .field input[type=text]{width:100%;padding:.82rem 1rem;border:1.5px solid var(--border);border-radius:9px;font-family:'DM Sans',sans-serif;font-size:.9rem;color:var(--text);background:var(--bg);}
        .field input[readonly]{color:var(--muted);cursor:not-allowed;}

        .course-items{width:100%;border-collapse:collapse;font-size:.86rem;margin-bottom:.5rem;}
        .course-items th{font-size:.7rem;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);padding:.5rem .6rem;border-bottom:1px solid var(--border);text-align:left;font-weight:700;}
        .course-items td{padding:.65rem .6rem;border-bottom:1px solid #F0F0EC;vertical-align:middle;}
        .course-items tr:last-child td{border-bottom:none;}
        .ci-code{font-family:'Bebas Neue',sans-serif;font-size:.95rem;letter-spacing:1px;color:var(--red);}
        .ci-total{background:#F8F8F5;border-top:2px solid var(--border)!important;}
        .ci-total td{padding:.75rem .6rem;font-weight:700;}
        .ci-total .grand{color:var(--red);font-family:'Bebas Neue',sans-serif;font-size:1.1rem;}

        .bank-grid{display:grid;grid-template-columns:1fr 1fr;gap:.9rem;}
        .bank-card{border:1.5px solid var(--border);border-radius:10px;padding:1rem 1.2rem;cursor:pointer;display:flex;align-items:center;gap:.8rem;transition:border-color .2s,background .2s,box-shadow .2s;background:var(--bg);}
        .bank-card:hover{border-color:var(--red);transform:translateY(-1px);box-shadow:0 4px 12px var(--red-glow);}
        .bank-card.selected{border-color:var(--red);background:var(--red-light);box-shadow:0 0 0 3px var(--red-glow);}
        .bank-radio{width:18px;height:18px;accent-color:var(--red);flex-shrink:0;}
        .bank-name{font-size:.88rem;font-weight:600;}
        .bank-logo{font-size:1.4rem;flex-shrink:0;}

        .va-box{background:#F0F6FF;border:1.5px solid #A0C0F0;border-radius:10px;padding:1.4rem 1.6rem;margin-top:1rem;}
        .va-bank-name{font-family:'Bebas Neue',sans-serif;font-size:1.1rem;letter-spacing:1.5px;color:#0066CC;margin-bottom:.6rem;}
        .va-label{font-size:.72rem;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:.3rem;}
        .va-number{font-size:1.5rem;font-weight:700;letter-spacing:4px;color:var(--text);display:flex;align-items:center;gap:.8rem;}
        .btn-copy{background:none;border:1px solid var(--border);border-radius:6px;padding:.3rem .7rem;font-size:.75rem;cursor:pointer;color:var(--muted);transition:all .2s;}
        .btn-copy:hover{border-color:var(--red);color:var(--red);}
        .va-amount{margin-top:.8rem;padding-top:.8rem;border-top:1px solid #C0D8F8;}
        .va-amount-val{font-size:1.1rem;font-weight:700;color:#0066CC;}
        .va-note{font-size:.75rem;color:var(--muted);margin-top:.7rem;line-height:1.5;}
        .va-expire{color:#C0001D;font-weight:600;}

        .btn-confirm{display:block;width:100%;padding:1rem;background:var(--green);color:#FFF;font-family:'Bebas Neue',sans-serif;font-size:1.15rem;letter-spacing:3px;border:none;border-radius:10px;cursor:pointer;margin-top:1.2rem;transition:background .2s,transform .15s;}
        .btn-confirm:hover{background:#145E36;transform:translateY(-1px);}
        .btn-confirm:active{transform:translateY(0);}

        .success-panel{text-align:center;padding:2.5rem 2rem;}
        .success-icon{width:80px;height:80px;border-radius:50%;background:var(--green-light);border:2px solid #B7EBD0;display:flex;align-items:center;justify-content:center;font-size:2.5rem;margin:0 auto 1.2rem;}
        .success-title{font-family:'Bebas Neue',sans-serif;font-size:2rem;letter-spacing:3px;color:var(--text);margin-bottom:.5rem;}
        .success-sub{font-size:.9rem;color:var(--muted);margin-bottom:1.5rem;}
        .receipt-box{background:var(--green-light);border:1px solid #B7EBD0;border-radius:10px;padding:1.2rem 1.5rem;text-align:left;margin-bottom:1.5rem;}
        .receipt-row{display:flex;justify-content:space-between;padding:.3rem 0;font-size:.86rem;}
        .receipt-row:not(:last-child){border-bottom:1px solid #C8F0D8;}
        .receipt-row .rl{color:var(--muted);}
        .receipt-row .rv{font-weight:700;color:var(--text);}
        .receipt-row .rv.big{color:var(--green);font-family:'Bebas Neue',sans-serif;font-size:1.05rem;}
        .btn-group{display:flex;gap:.8rem;justify-content:center;flex-wrap:wrap;}
        .btn-dl{background:var(--green);color:#FFF;border:none;border-radius:9px;padding:.75rem 1.6rem;font-family:'Bebas Neue',sans-serif;font-size:.95rem;letter-spacing:2px;cursor:pointer;text-decoration:none;display:inline-flex;align-items:center;gap:.5rem;transition:background .2s;}
        .btn-dl:hover{background:#145E36;}
        .btn-hist{background:none;border:1.5px solid var(--border);color:var(--text);border-radius:9px;padding:.75rem 1.6rem;font-family:'Bebas Neue',sans-serif;font-size:.95rem;letter-spacing:2px;cursor:pointer;text-decoration:none;display:inline-flex;align-items:center;gap:.5rem;transition:all .2s;}
        .btn-hist:hover{border-color:var(--red);color:var(--red);}

        @media(max-width:600px){.page-header{padding:1.8rem 1rem;}.page-header h1{font-size:2rem;}.main{padding:1.5rem 1rem 4rem;}.bank-grid{grid-template-columns:1fr;}.pay-card{padding:1.2rem;}}
    </style>
</head>
<body>
<form id="form1" runat="server">

    <%-- Page loader — dismissed immediately by DOMContentLoaded JS --%>
    <div id="pageLoader">
        <div class="loader-logo">UNIV<span>&middot;</span>SYS</div>
        <div class="loader-bar-wrap"><div class="loader-bar"></div></div>
        <div class="loader-text">Loading payment...</div>
    </div>

    <%-- Processing overlay — shown by JS ONLY during the postback trip.
         JS reads hfPaymentDone on DOMContentLoaded: if "1" → hide overlay.         --%>
    <div id="processingOverlay">
        <div class="spin"></div>
        <div class="proc-title">Payment Processing</div>
        <div class="proc-sub">Please wait while we verify your payment and activate your enrolment...</div>
    </div>

    <%-- KEY: server sets this to "1" after successful payment --%>
    <asp:HiddenField ID="hfPaymentDone" runat="server" Value="0"/>

    <uc:NavBar ID="ucNavBar" runat="server"/>

    <div class="page-header">
        <a class="back-btn" href="javascript:history.back()">&#8592; Back</a>
        <h1>Online Payment</h1>
        <p>Complete your course fee payment to confirm enrolment.</p>
    </div>

    <div class="main">

        <asp:Label ID="lblError" runat="server" CssClass="alert-block alert-error" Visible="false" EnableViewState="false"/>

        <%-- Steps bar --%>
        <div class="steps-bar">
            <div class="step-item" id="s1"><div class="step-dot">1</div><div class="step-label">Details</div></div>
            <div class="step-item" id="s2"><div class="step-dot">2</div><div class="step-label">Method</div></div>
            <div class="step-item" id="s3"><div class="step-dot">3</div><div class="step-label">Confirm</div></div>
            <div class="step-item" id="s4"><div class="step-dot">&#10003;</div><div class="step-label">Done</div></div>
        </div>

        <%-- ═══ PAYMENT FORM — hidden by server after success ═══ --%>
        <asp:Panel ID="pnlPaymentForm" runat="server">

            <div class="pay-card">
                <h3>Student Information</h3>
                <div class="field">
                    <label>Student ID</label>
                    <asp:TextBox ID="txtStudentId" runat="server" ReadOnly="true"/>
                </div>
            </div>

            <div class="pay-card">
                <h3>Courses &amp; Fees</h3>
                <table class="course-items">
                    <thead><tr>
                        <th>Course Code</th><th>Course Name</th>
                        <th>Credits</th><th style="text-align:right">Fee (RM)</th>
                    </tr></thead>
                    <tbody>
                        <asp:Repeater ID="rptCourseItems" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><span class="ci-code"><%# Eval("CourseId") %></span></td>
                                    <td><%# Eval("CourseName") %></td>
                                    <td><%# Eval("Credits") %></td>
                                    <td style="text-align:right;font-weight:600"><%# Eval("FeeFormatted") %></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                    <tfoot>
                        <tr class="ci-total">
                            <td colspan="3" style="font-weight:700">TOTAL PAYABLE</td>
                            <td style="text-align:right"><span class="grand">RM <asp:Label ID="lblGrandTotal" runat="server" Text="0.00"/></span></td>
                        </tr>
                    </tfoot>
                </table>
                <asp:HiddenField ID="hfGrandTotal" runat="server"/>
            </div>

            <div class="pay-card">
                <h3>Payment Method</h3>
                <div class="bank-grid">
                    <div class="bank-card selected" id="cMaybank" onclick="selBank('maybank')">
                        <asp:RadioButton ID="rbMaybank" runat="server" GroupName="BankGroup" Checked="true" CssClass="bank-radio"/>
                        <span class="bank-logo">🏦</span><span class="bank-name">Maybank2u</span>
                    </div>
                    <div class="bank-card" id="cCimb" onclick="selBank('cimb')">
                        <asp:RadioButton ID="rbCimb" runat="server" GroupName="BankGroup" CssClass="bank-radio"/>
                        <span class="bank-logo">🏦</span><span class="bank-name">CIMB Clicks</span>
                    </div>
                    <div class="bank-card" id="cPublic" onclick="selBank('public')">
                        <asp:RadioButton ID="rbPublic" runat="server" GroupName="BankGroup" CssClass="bank-radio"/>
                        <span class="bank-logo">🏦</span><span class="bank-name">Public Bank</span>
                    </div>
                    <div class="bank-card" id="cRhb" onclick="selBank('rhb')">
                        <asp:RadioButton ID="rbRhb" runat="server" GroupName="BankGroup" CssClass="bank-radio"/>
                        <span class="bank-logo">🏦</span><span class="bank-name">RHB Online</span>
                    </div>
                </div>

                <asp:Panel ID="pnlVA" runat="server">
                    <div class="va-box">
                        <div class="va-bank-name"><asp:Label ID="lblVABank" runat="server"/></div>
                        <div class="va-label">Virtual Account Number</div>
                        <div class="va-number">
                            <asp:Label ID="lblVANumber" runat="server"/>
                            <button type="button" class="btn-copy" onclick="copyVA(event)">COPY</button>
                        </div>
                        <div class="va-amount">
                            <div class="va-label">Total Amount to Transfer</div>
                            <div class="va-amount-val">RM <asp:Label ID="lblVAAmount" runat="server"/></div>
                        </div>
                        <div class="va-note">
                            &#9888; Transfer the exact amount. VA valid for <span class="va-expire">24 hours</span>.<br/>
                            After transferring, click <strong>"I Have Paid"</strong> below.
                        </div>
                    </div>
                </asp:Panel>
            </div>

            <%-- OnClientClick shows processing overlay; return true allows postback --%>
            <asp:Button ID="btnSubmit" runat="server"
                Text="I HAVE PAID — CONFIRM PAYMENT"
                CssClass="btn-confirm"
                OnClick="btnSubmit_Click"
                OnClientClick="showProcessing();"/>

        </asp:Panel>

        <%-- ═══ SUCCESS — shown by server after payment committed ═══ --%>
        <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
            <div class="pay-card">
                <div class="success-panel">
                    <div class="success-icon">&#10003;</div>
                    <div class="success-title">PAYMENT SUCCESSFUL</div>
                    <div class="success-sub">Your enrolment is confirmed. Your receipt is below.</div>

                    <div class="receipt-box">
                        <div class="receipt-row"><span class="rl">Invoice No</span>  <span class="rv"><asp:Label ID="lblReceiptInvNo"  runat="server"/></span></div>
                        <div class="receipt-row"><span class="rl">Student ID</span>  <span class="rv"><asp:Label ID="lblReceiptStudent" runat="server"/></span></div>
                        <div class="receipt-row"><span class="rl">Course(s)</span>   <span class="rv"><asp:Label ID="lblReceiptCourses" runat="server"/></span></div>
                        <div class="receipt-row"><span class="rl">Bank</span>        <span class="rv"><asp:Label ID="lblReceiptBank"   runat="server"/></span></div>
                        <div class="receipt-row"><span class="rl">Date</span>        <span class="rv"><asp:Label ID="lblReceiptDate"   runat="server"/></span></div>
                        <div class="receipt-row"><span class="rl">Total Paid</span> <span class="rv big">RM <asp:Label ID="lblReceiptTotal" runat="server"/></span></div>
                    </div>

                    <div class="btn-group">
                        <asp:HyperLink ID="lnkDownloadInvoice" runat="server" CssClass="btn-dl">
                            &#128438; Download Invoice
                        </asp:HyperLink>
                        <a href="~/PaymentHistory.aspx" runat="server" class="btn-hist">
                            &#128200; View Payment History
                        </a>
                    </div>
                </div>
            </div>
        </asp:Panel>

    </div>

</form>
<script src="~/Scripts/NavBar.js"></script>
<script>
    // ── Bank card selection ──────────────────────────────────────────────
    var bMap = {
        maybank: ['cMaybank','<%=rbMaybank.ClientID %>'],
    cimb:   ['cCimb',   '<%=rbCimb.ClientID %>'],
    public: ['cPublic', '<%=rbPublic.ClientID %>'],
    rhb:    ['cRhb',    '<%=rbRhb.ClientID %>']
};
function selBank(k) {
    Object.keys(bMap).forEach(function(b){
        document.getElementById(bMap[b][0]).classList.remove('selected');
        document.getElementById(bMap[b][1]).checked = false;
    });
    document.getElementById(bMap[k][0]).classList.add('selected');
    document.getElementById(bMap[k][1]).checked = true;
}

// ── Copy VA number ───────────────────────────────────────────────────
function copyVA(ev) {
    var va = document.getElementById('<%=lblVANumber.ClientID %>');
    if (!va) return;
    navigator.clipboard.writeText(va.textContent.trim()).then(function(){
        ev.target.textContent = 'COPIED!';
        setTimeout(function(){ ev.target.textContent = 'COPY'; }, 2000);
    });
}

// ── Show processing overlay when confirm is clicked ──────────────────
// Called from OnClientClick — postback still proceeds normally.
function showProcessing() {
    document.getElementById('processingOverlay').classList.add('show');
}

// ── DOMContentLoaded: runs on EVERY page load including after postback ──
// KEY FIX: check hfPaymentDone. If "1" → payment succeeded, hide overlay
// and show success. If "0" → normal page load, just hide pageLoader.
document.addEventListener('DOMContentLoaded', function () {
    var done = document.getElementById('<%=hfPaymentDone.ClientID %>');
    var isDone = done && done.value === '1';

    // Always hide the page loader immediately
    var loader = document.getElementById('pageLoader');
    if (loader) {
        loader.classList.add('hidden');
        setTimeout(function () { loader.style.display = 'none'; }, 380);
    }

    // If payment completed → hide the processing overlay
    if (isDone) {
        document.getElementById('processingOverlay').classList.remove('show');
    }

    // Update step bar
    var stepIds = ['s1', 's2', 's3', 's4'];
    var activeN = isDone ? 4 : 2;
    stepIds.forEach(function (id, i) {
        var el = document.getElementById(id);
        if (!el) return;
        el.classList.remove('active', 'done');
        if (i + 1 < activeN) el.classList.add('done');
        else if (i + 1 === activeN) el.classList.add('active');
    });
});
</script>
</body>
</html>
