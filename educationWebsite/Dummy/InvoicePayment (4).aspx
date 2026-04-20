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
            <button type="button" class="btn-download" onclick="printInvoice()">
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
                    <asp:BoundField DataField="course_code"    HeaderText="Course Code"/>
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

        <%-- ── PRINT-ONLY INVOICE TEMPLATE built via JS popup ── --%>
        <%-- Hidden data carriers for JS to read --%>
        <span id="hdnStudentName" style="display:none"><asp:Label ID="lblStudentNamePrint" runat="server"/></span>
        <span id="hdnPeriod"      style="display:none"><asp:Label ID="lblPeriodPrint"      runat="server"/></span>
        <span id="hdnTotal"       style="display:none"><asp:Label ID="hdnTotalAmt"         runat="server"/></span>

    </div>

</form>
<script src="~/Scripts/NavBar.js"></script>
<script>
    (function(){var l=document.getElementById('pageLoader');if(!l)return;window.addEventListener('load',function(){setTimeout(function(){l.classList.add('hidden');setTimeout(function(){l.style.display='none';},400);},400);});})();

    function printInvoice() {
        // ── Collect data from the on-screen GridView ──────────────────────
        var tbl = document.querySelector('.inv-table');
        if (!tbl) { alert('No invoice data to print.'); return; }

        var studentName = (document.getElementById('hdnStudentName') || {}).innerText || '';
        var period      = (document.getElementById('hdnPeriod')      || {}).innerText || '';
        var today       = new Date();
        var dateStr     = today.toLocaleDateString('en-GB', {day:'2-digit', month:'long', year:'numeric'});

        // Build rows from the GridView tbody
        var rows = tbl.querySelectorAll('tbody tr');
        var tableRows = '';
        var grandTotal = 0;
        var paymentMethod = '';
        var invoiceDate = '';
        var statusAll = 'Success';

        rows.forEach(function(tr) {
            var cells = tr.querySelectorAll('td');
            if (cells.length < 7) return;

            var invNo   = cells[0].innerText.trim();
            var date    = cells[2].innerText.trim();
            var code    = cells[3].innerText.trim();
            var desc    = cells[4].innerText.trim();
            var bank    = cells[5].innerText.trim();
            var amtText = cells[6].innerText.trim().replace('RM','').replace(/,/g,'').trim();
            var status  = cells[7] ? cells[7].innerText.trim() : 'Success';
            var amt     = parseFloat(amtText) || 0;

            grandTotal += amt;
            if (!paymentMethod && bank) paymentMethod = bank;
            if (!invoiceDate  && date) invoiceDate = date;
            if (status.toLowerCase() !== 'success') statusAll = status;

            var statusClass = status.toLowerCase() === 'success'
                ? 'background:#e8f8f0;color:#1A7A47;border:1px solid #a3dfc0;'
                : 'background:#fffbf0;color:#7A6000;border:1px solid #f0e0a0;';

            tableRows +=
                '<tr>' +
                '<td style="padding:10px 12px;border-bottom:1px solid #f0f0ec;font-family:monospace;font-weight:700;color:#8B0015;font-size:12px;">' + invNo + '</td>' +
                '<td style="padding:10px 12px;border-bottom:1px solid #f0f0ec;font-weight:600;font-size:12px;">' + code + '</td>' +
                '<td style="padding:10px 12px;border-bottom:1px solid #f0f0ec;font-size:12px;">' + desc + '</td>' +
                '<td style="padding:10px 12px;border-bottom:1px solid #f0f0ec;font-size:12px;">' + date + '</td>' +
                '<td style="padding:10px 12px;border-bottom:1px solid #f0f0ec;font-size:12px;">' + bank + '</td>' +
                '<td style="padding:10px 12px;border-bottom:1px solid #f0f0ec;text-align:right;font-weight:700;font-size:12px;">RM ' + amt.toFixed(2) + '</td>' +
                '<td style="padding:10px 12px;border-bottom:1px solid #f0f0ec;text-align:center;">' +
                    '<span style="display:inline-block;padding:3px 10px;border-radius:50px;font-size:11px;font-weight:700;letter-spacing:.3px;' + statusClass + '">' + status + '</span>' +
                '</td>' +
                '</tr>';
        });

        // ── Build professional invoice HTML ───────────────────────────────
        var html =
            '<!DOCTYPE html><html><head>' +
            '<meta charset="UTF-8"/>' +
            '<title>Invoice — UniSys</title>' +
            '<style>' +
            '  @page { size: A4 portrait; margin: 18mm 15mm; }' +
            '  * { box-sizing:border-box; margin:0; padding:0; }' +
            '  body { font-family: Arial, sans-serif; font-size:13px; color:#1A1A1A; background:#fff; }' +

            // ── Top header band
            '  .hdr-band { background:#8B0015; padding:22px 28px 18px; color:#fff; display:flex; justify-content:space-between; align-items:flex-start; -webkit-print-color-adjust:exact; print-color-adjust:exact; }' +
            '  .hdr-uni  { font-size:22px; font-weight:900; letter-spacing:3px; }' +
            '  .hdr-sub  { font-size:10px; opacity:.8; margin-top:3px; }' +
            '  .hdr-right { text-align:right; }' +
            '  .hdr-right h2 { font-size:18px; font-weight:900; letter-spacing:2px; }' +
            '  .hdr-right p  { font-size:11px; opacity:.85; margin-top:4px; }' +

            // ── Info section
            '  .info-wrap { display:flex; justify-content:space-between; padding:22px 28px 16px; border-bottom:2px solid #8B0015; }' +
            '  .info-block label { display:block; font-size:9px; text-transform:uppercase; letter-spacing:.8px; color:#888; margin-bottom:4px; }' +
            '  .info-block .val  { font-size:13px; font-weight:700; color:#1A1A1A; }' +
            '  .info-block .sub  { font-size:11px; color:#555; margin-top:2px; }' +

            // ── Status pill
            '  .status-pill { display:inline-flex; align-items:center; gap:6px; background:#e8f8f0; color:#1A7A47; border:1px solid #a3dfc0; border-radius:20px; padding:5px 14px; font-size:12px; font-weight:700; -webkit-print-color-adjust:exact; print-color-adjust:exact; }' +
            '  .status-pill::before { content:"✓"; font-size:13px; }' +

            // ── Table
            '  .items-wrap { padding:22px 28px 0; }' +
            '  .items-wrap h3 { font-size:10px; text-transform:uppercase; letter-spacing:1.5px; color:#8B0015; margin-bottom:10px; font-weight:700; }' +
            '  table.items { width:100%; border-collapse:collapse; }' +
            '  table.items thead tr { background:#8B0015; -webkit-print-color-adjust:exact; print-color-adjust:exact; }' +
            '  table.items thead th { padding:9px 12px; color:#fff; font-size:10px; text-transform:uppercase; letter-spacing:.8px; text-align:left; font-weight:700; }' +
            '  table.items thead th:last-child, table.items thead th:nth-last-child(2) { text-align:center; }' +
            '  table.items tbody tr:nth-child(even) td { background:#fafaf8; -webkit-print-color-adjust:exact; print-color-adjust:exact; }' +
            '  table.items tfoot tr { background:#f5f5f2; -webkit-print-color-adjust:exact; print-color-adjust:exact; }' +
            '  table.items tfoot td { padding:10px 12px; font-weight:700; font-size:13px; }' +

            // ── Footer
            '  .footer { padding:20px 28px 0; display:flex; justify-content:space-between; align-items:flex-end; margin-top:24px; border-top:1px solid #e5e5e0; }' +
            '  .footer-note { font-size:10px; color:#888; line-height:1.6; }' +
            '  .footer-total-box { text-align:right; }' +
            '  .footer-total-box .lbl { font-size:10px; text-transform:uppercase; letter-spacing:.8px; color:#888; }' +
            '  .footer-total-box .amount { font-size:24px; font-weight:900; color:#8B0015; letter-spacing:1px; }' +
            '  .footer-total-box .paid-lbl { font-size:11px; color:#1A7A47; font-weight:700; margin-top:4px; }' +
            '  .watermark { text-align:center; margin-top:28px; font-size:10px; color:#ccc; letter-spacing:2px; }' +
            '</style>' +
            '</head><body>' +

            // Header band
            '<div class="hdr-band">' +
            '  <div><div class="hdr-uni">UNIV&middot;SYS</div><div class="hdr-sub">UniSys University &nbsp;|&nbsp; No. 1 Jalan Universiti, 71800 Nilai, Malaysia</div></div>' +
            '  <div class="hdr-right"><h2>OFFICIAL INVOICE</h2><p>Period: ' + period + '</p></div>' +
            '</div>' +

            // Info row
            '<div class="info-wrap">' +
            '  <div>' +
            '    <div class="info-block" style="margin-bottom:14px"><label>Bill To</label><div class="val">' + studentName + '</div></div>' +
            '    <div class="info-block"><label>Payment Method</label><div class="val">' + (paymentMethod || '—') + '</div></div>' +
            '  </div>' +
            '  <div style="text-align:right">' +
            '    <div class="info-block" style="margin-bottom:14px"><label>Invoice Date</label><div class="val">' + invoiceDate + '</div></div>' +
            '    <div class="info-block" style="margin-bottom:14px"><label>Printed On</label><div class="val">' + dateStr + '</div></div>' +
            '    <div class="status-pill">Payment Verified</div>' +
            '  </div>' +
            '</div>' +

            // Items table
            '<div class="items-wrap">' +
            '  <h3>Invoice Items</h3>' +
            '  <table class="items">' +
            '    <thead><tr>' +
            '      <th style="width:90px">Invoice No</th>' +
            '      <th style="width:95px">Course Code</th>' +
            '      <th>Description</th>' +
            '      <th style="width:120px">Date &amp; Time</th>' +
            '      <th style="width:100px">Method</th>' +
            '      <th style="width:90px;text-align:right">Amount</th>' +
            '      <th style="width:80px;text-align:center">Status</th>' +
            '    </tr></thead>' +
            '    <tbody>' + tableRows + '</tbody>' +
            '    <tfoot><tr>' +
            '      <td colspan="5" style="text-align:right;font-size:12px;color:#666;padding:10px 12px;">Total Amount Paid</td>' +
            '      <td style="text-align:right;font-size:15px;color:#8B0015;padding:10px 12px;">RM ' + grandTotal.toFixed(2) + '</td>' +
            '      <td></td>' +
            '    </tr></tfoot>' +
            '  </table>' +
            '</div>' +

            // Footer
            '<div class="footer">' +
            '  <div class="footer-note">' +
            '    This is a computer-generated invoice and does not require a signature.<br>' +
            '    For enquiries, please contact finance@unisys.edu.my or call +603-1234-5678.' +
            '  </div>' +
            '  <div class="footer-total-box">' +
            '    <div class="lbl">Grand Total</div>' +
            '    <div class="amount">RM ' + grandTotal.toFixed(2) + '</div>' +
            '    <div class="paid-lbl">&#10003; PAID</div>' +
            '  </div>' +
            '</div>' +
            '<div class="watermark">UNIV &middot; SYS &nbsp;&mdash;&nbsp; OFFICIAL PAYMENT RECEIPT</div>' +

            '</body></html>';

        // ── Open popup & print ────────────────────────────────────────────
        var pw = window.open('', '_blank', 'width=820,height=900');
        pw.document.write(html);
        pw.document.close();
        pw.focus();
        setTimeout(function() { pw.print(); }, 700);
    }
</script>
</body>
</html>
