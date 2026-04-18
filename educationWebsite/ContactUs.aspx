<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContactUs.aspx.cs" Inherits="UniversitySystem.ContactUs" %>
<%@ Register Src="~/Controls/NavBar.ascx" TagName="NavBar" TagPrefix="uc" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Contact Us — UniSys</title>
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

        /* ── Header ── */
        .page-header{background:linear-gradient(135deg,var(--red-deep) 0%,var(--red) 100%);padding:2.5rem 2.5rem 2.2rem;position:relative;overflow:hidden;}
        .page-header::before{content:'CONTACT';position:absolute;right:-1rem;top:50%;transform:translateY(-50%);font-family:'Bebas Neue',sans-serif;font-size:8rem;color:rgba(255,255,255,.05);pointer-events:none;letter-spacing:4px;white-space:nowrap;}
        .page-header h1{font-family:'Bebas Neue',sans-serif;font-size:2.6rem;letter-spacing:3px;color:#FFF;line-height:1;}
        .page-header p{margin-top:.5rem;color:rgba(255,255,255,.75);font-size:.9rem;}

        /* ── Main ── */
        .main{max-width:980px;margin:0 auto;padding:2.5rem 1.5rem 5rem;}

        /* ── Alerts ── */
        .alert-block{border-radius:8px;padding:.85rem 1rem;font-size:.85rem;margin-bottom:1.5rem;display:block;}
        .alert-success{background:#F0FFF7;border:1px solid #B7EBD0;color:#1A7A47;}
        .alert-error  {background:#FFF5F6;border:1px solid #FFCCD2;color:#C0001D;}

        /* ── Section label ── */
        .section-label{font-family:'Bebas Neue',sans-serif;font-size:.95rem;letter-spacing:2.5px;color:var(--red);margin-bottom:1.2rem;display:flex;align-items:center;gap:.7rem;}
        .section-label::after{content:'';flex:1;height:1px;background:var(--border);}

        /* ── Layout ── */
        .contact-layout{display:grid;grid-template-columns:1fr 1.35fr;gap:2rem;}
        @media(max-width:780px){.contact-layout{grid-template-columns:1fr;}}

        /* ── Info cards ── */
        .info-cards{display:flex;flex-direction:column;gap:1rem;}
        .info-card{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);padding:1.3rem 1.6rem;box-shadow:0 1px 6px rgba(0,0,0,.05);position:relative;overflow:hidden;}
        .info-card::before{content:'';position:absolute;left:0;top:0;bottom:0;width:4px;background:var(--red);}
        .info-card-icon{font-size:1.5rem;margin-bottom:.6rem;display:block;}
        .info-card-title{font-family:'Bebas Neue',sans-serif;font-size:.95rem;letter-spacing:1.5px;color:var(--text);margin-bottom:.45rem;}
        .info-card p{font-size:.84rem;color:var(--muted);line-height:1.7;}
        .info-card a{color:var(--red);text-decoration:none;font-weight:500;}
        .info-card a:hover{text-decoration:underline;}
        .hours-table{width:100%;margin-top:.4rem;}
        .hours-table td{font-size:.81rem;padding:.2rem 0;color:var(--muted);}
        .hours-table td:last-child{text-align:right;font-weight:600;color:var(--text);}

        .map-wrap{margin-top:1.2rem;background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);height:160px;display:flex;align-items:center;justify-content:center;color:var(--muted);font-size:.84rem;overflow:hidden;}

        /* ── Message form card ── */
        .form-card{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);padding:2rem;box-shadow:0 2px 14px rgba(0,0,0,.07);}
        .form-card-title{font-family:'Bebas Neue',sans-serif;font-size:1.2rem;letter-spacing:2px;color:var(--text);margin-bottom:.3rem;}
        .form-card-sub{font-size:.82rem;color:var(--muted);margin-bottom:1.6rem;line-height:1.5;}

        /* ── All form fields ── */
        /*
          CRITICAL FIX: ASP.NET TextBox renders as <input type="text"> or <textarea>.
          We must style by element type + our added CSS class, NOT by .field input alone.
          We set CssClass="fc-input" / "fc-select" / "fc-textarea" on each control
          and style those classes here.
        */
        .fc-label{display:block;font-size:.73rem;font-weight:700;text-transform:uppercase;letter-spacing:.65px;color:var(--muted);margin-bottom:.38rem;}
        .fc-field{margin-bottom:1.2rem;}

        .fc-input, input.fc-input,
        textarea.fc-textarea {
            display:block;
            width:100%;
            padding:.82rem 1rem;
            border:1.5px solid var(--border);
            border-radius:9px;
            font-family:'DM Sans',sans-serif;
            font-size:.88rem;
            color:var(--text);
            background:var(--bg);
            transition:border-color .2s, background .2s;
            box-sizing:border-box;
        }
        select.fc-select {
            display:block;
            width:100%;
            padding:.82rem 1rem;
            border:1.5px solid var(--border);
            border-radius:9px;
            font-family:'DM Sans',sans-serif;
            font-size:.88rem;
            color:var(--text);
            background:var(--bg);
            transition:border-color .2s;
            box-sizing:border-box;
            -webkit-appearance:none;
            appearance:none;
            cursor:pointer;
        }
        .fc-input:focus, input.fc-input:focus,
        textarea.fc-textarea:focus,
        select.fc-select:focus {
            outline:none;
            border-color:var(--red);
            background:#FFF;
            box-shadow:0 0 0 3px var(--red-glow);
        }
        input.fc-input[readonly],
        input.fc-input[disabled] {
            background:#F0F0EC;
            color:var(--muted);
            cursor:not-allowed;
        }
        textarea.fc-textarea{
            min-height:130px;
            resize:vertical;
        }
        .char-count{font-size:.7rem;color:var(--muted);text-align:right;margin-top:.25rem;}

        .btn-send{
            display:block;width:100%;
            padding:1rem;
            background:var(--red);color:#FFF;
            font-family:'Bebas Neue',sans-serif;
            font-size:1.15rem;letter-spacing:3px;
            border:none;border-radius:10px;cursor:pointer;
            margin-top:.5rem;
            transition:background .2s,transform .15s,box-shadow .2s;
        }
        .btn-send:hover{background:#A8001A;transform:translateY(-1px);box-shadow:0 6px 20px rgba(192,0,29,.3);}
        .btn-send:active{transform:translateY(0);}

        @media(max-width:600px){.page-header{padding:1.8rem 1rem;}.page-header h1{font-size:2rem;}.main{padding:1.5rem 1rem 4rem;}.form-card{padding:1.3rem;}}
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
        <h1>Contact Us</h1>
        <p>Reach out to the University's academic administration team.</p>
    </div>

    <div class="main">

        <%-- ALERTS --%>
        <asp:Label ID="lblSuccess" runat="server"
            CssClass="alert-block alert-success"
            Visible="false" EnableViewState="false"/>
        <asp:Label ID="lblError" runat="server"
            CssClass="alert-block alert-error"
            Visible="false" EnableViewState="false"/>

        <div class="contact-layout">

            <%-- ═══ LEFT: CONTACT INFO (purely static HTML) ═══ --%>
            <div>
                <div class="section-label">CONTACT INFORMATION</div>
                <div class="info-cards">

                    <div class="info-card">
                        <span class="info-card-icon">&#127970;</span>
                        <div class="info-card-title">MAIN CAMPUS</div>
                        <p>UniSys University<br/>
                           No. 1, Jalan Universiti, Nilai<br/>
                           71800 Negeri Sembilan, Malaysia</p>
                    </div>

                    <div class="info-card">
                        <span class="info-card-icon">&#128222;</span>
                        <div class="info-card-title">PHONE &amp; FAX</div>
                        <p>
                            General Line: <a href="tel:+60676508000">+60 6765 0800</a><br/>
                            Registrar: <a href="tel:+60676508100">+60 6765 0810</a><br/>
                            Student Affairs: <a href="tel:+60676508200">+60 6765 0820</a><br/>
                            Fax: +60 6765 0999
                        </p>
                    </div>

                    <div class="info-card">
                        <span class="info-card-icon">&#9993;</span>
                        <div class="info-card-title">EMAIL</div>
                        <p>
                            General: <a href="mailto:info@unisys.edu.my">info@unisys.edu.my</a><br/>
                            Registrar: <a href="mailto:registrar@unisys.edu.my">registrar@unisys.edu.my</a><br/>
                            IT Support: <a href="mailto:itsupport@unisys.edu.my">itsupport@unisys.edu.my</a><br/>
                            Finance: <a href="mailto:finance@unisys.edu.my">finance@unisys.edu.my</a>
                        </p>
                    </div>

                    <div class="info-card">
                        <span class="info-card-icon">&#128336;</span>
                        <div class="info-card-title">OFFICE HOURS</div>
                        <table class="hours-table">
                            <tr><td>Monday – Friday</td><td>8:00 AM – 5:00 PM</td></tr>
                            <tr><td>Saturday</td><td>8:00 AM – 1:00 PM</td></tr>
                            <tr><td>Sunday &amp; Public Holidays</td><td>Closed</td></tr>
                        </table>
                    </div>

                </div>

                <div class="map-wrap">
                    <span>&#128205; Campus map — embed Google Maps here</span>
                </div>
            </div>

            <%-- ═══ RIGHT: MESSAGE FORM ═══ --%>
            <div>
                <div class="section-label">SEND A MESSAGE</div>
                <div class="form-card">
                    <div class="form-card-title">GET IN TOUCH</div>
                    <p class="form-card-sub">Fill in the form below and we will respond within 1–2 business days.</p>

                    <%-- Your Name (readonly, set from session) --%>
                    <div class="fc-field">
                        <label class="fc-label">Your Name</label>
                        <asp:TextBox ID="txtName" runat="server"
                            ReadOnly="true"
                            CssClass="fc-input"/>
                    </div>

                    <%-- Student ID (readonly) --%>
                    <div class="fc-field">
                        <label class="fc-label">Student ID</label>
                        <asp:TextBox ID="txtStudentId" runat="server"
                            ReadOnly="true"
                            CssClass="fc-input"/>
                    </div>

                    <%-- Subject dropdown --%>
                    <div class="fc-field">
                        <label class="fc-label">Subject <span style="color:var(--red)">*</span></label>
                        <asp:DropDownList ID="ddlSubject" runat="server"
                            CssClass="fc-select">
                            <asp:ListItem Text="— Select a subject —"        Value=""/>
                            <asp:ListItem Text="Course Enrollment Query"      Value="Course Enrollment Query"/>
                            <asp:ListItem Text="Payment / Finance Issue"      Value="Payment / Finance Issue"/>
                            <asp:ListItem Text="Timetable Query"              Value="Timetable Query"/>
                            <asp:ListItem Text="Academic Results / Grade"     Value="Academic Results / Grade"/>
                            <asp:ListItem Text="Technical Support (Portal)"   Value="Technical Support (Portal)"/>
                            <asp:ListItem Text="Add / Drop Course Query"      Value="Add / Drop Course Query"/>
                            <asp:ListItem Text="Other"                        Value="Other"/>
                        </asp:DropDownList>
                    </div>

                    <%-- Message textarea --%>
                    <div class="fc-field">
                        <label class="fc-label">Message <span style="color:var(--red)">*</span></label>
                        <asp:TextBox ID="txtMessage" runat="server"
                            TextMode="MultiLine"
                            CssClass="fc-textarea"
                            placeholder="Describe your enquiry in detail..."
                            onkeyup="updateCount(this,'charCount',1000)"/>
                        <div class="char-count">
                            <span id="charCount">0</span> / 1000 characters
                        </div>
                    </div>

                    <%-- Send button --%>
                    <asp:Button ID="btnSend" runat="server"
                        Text="SEND MESSAGE &#10148;"
                        CssClass="btn-send"
                        OnClick="btnSend_Click"
                        CausesValidation="false"/>

                </div>
            </div>

        </div><%-- /contact-layout --%>
    </div><%-- /main --%>

</form>
<script src="~/Scripts/NavBar.js"></script>
<script>
    function updateCount(el, id, max) {
        var len = el.value.length;
        if (len > max) { el.value = el.value.substring(0, max); len = max; }
        var span = document.getElementById(id);
        if (span) span.textContent = len;
    }
    (function () {
        var l = document.getElementById('pageLoader');
        if (!l) return;
        window.addEventListener('load', function () {
            setTimeout(function () { l.classList.add('hidden'); setTimeout(function () { l.style.display = 'none'; }, 400); }, 400);
        });
    })();
</script>
</body>
</html>
