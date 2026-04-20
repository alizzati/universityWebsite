<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TimetableMatching.aspx.cs" Inherits="UniversitySystem.TimetableMatching" %>
<%@ Register Src="~/Controls/NavBar.ascx" TagName="NavBar" TagPrefix="uc" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Timetable Matching — UniSys</title>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:wght@300;400;500;700&display=swap" rel="stylesheet"/>
    <%-- FIX: use ~/ paths --%>
    <link href="~/Styles/NavBar.css"            rel="stylesheet"/>
    <link href="~/Styles/TimetableMatching.css" rel="stylesheet"/>
    <style>
        .btn-pdf {
            display:inline-flex; align-items:center; gap:.5rem;
            background:var(--red); color:#FFF;
            border:none; border-radius:8px;
            padding:.6rem 1.2rem;
            font-family:'Bebas Neue',sans-serif;
            font-size:.9rem; letter-spacing:1.5px;
            cursor:pointer; transition:background .2s;
            margin-bottom:1.2rem;
        }
        .btn-pdf:hover { background:#A8001A; }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <div id="pageLoader">
        <div class="loader-logo">UNIV<span>&middot;</span>SYS</div>
        <div class="loader-bar-wrap"><div class="loader-bar"></div></div>
        <div class="loader-text">Loading timetable...</div>
    </div>

    <uc:NavBar ID="ucNavBar" runat="server"/>

    <div class="page-header" data-label="TIMETABLE">
        <a class="back-btn" href="~/Dashboard.aspx" runat="server">&#8592; Back to Dashboard</a>
        <h1>Timetable Matching</h1>
        <p>View your class schedule for enrolled courses.</p>
    </div>

    <div class="main">

        <asp:Label ID="lblError"   runat="server" CssClass="alert alert-error"   Visible="false" EnableViewState="false"/>
        <asp:Label ID="lblSuccess" runat="server" CssClass="alert alert-success" Visible="false" EnableViewState="false"/>

        <div class="info-card">
            <div class="info-grid">
                <div class="info-item">
                    <label>Session</label>
                    <div class="val"><asp:Label ID="lblSession" runat="server" Text="JAN2026"/></div>
                </div>
                <div class="info-item">
                    <label>Student ID</label>
                    <div class="val"><asp:Label ID="lblStudentId" runat="server"/></div>
                </div>
                <div class="info-item info-item-wide">
                    <label>Student Name / Program</label>
                    <div class="val"><asp:Label ID="lblProgram" runat="server"/></div>
                </div>
                <div class="info-item">
                    <label>Semester Type</label>
                    <div class="val">
                        <asp:RadioButton ID="rbLong"  runat="server" GroupName="semType" Text="Long"  Checked="true" CssClass="rb-label"/>
                        <asp:RadioButton ID="rbShort" runat="server" GroupName="semType" Text="Short" CssClass="rb-label"/>
                    </div>
                </div>
            </div>
        </div>

        <div class="section-label">ENROLLED COURSES</div>

        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th style="width:40px">No</th>
                        <th>Course Code</th>
                        <th>Course Name</th>
                        <th>Lecturer</th>
                        <th style="width:60px">Credits</th>
                        <th style="width:70px">Day</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptCourses" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td class="td-num"><%# Container.ItemIndex + 1 %></td>
                                <td><span class="course-code-badge"><%# Eval("CourseCode") %></span></td>
                                <td><%# Eval("CourseName") %></td>
                                <td><%# Eval("LectureName") %></td>
                                <td style="text-align:center"><%# Eval("Credits") %></td>
                                <td><span class="section-badge"><%# Eval("Day") %></span></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>

        <div class="view-mode-card">
            <div class="section-label" style="margin-bottom:1.2rem">VIEW OPTIONS</div>
            <div class="radio-group">
                <label class="radio-card">
                    <asp:RadioButton ID="rbShowAll"      runat="server" GroupName="viewMode" Checked="true" CssClass="rb-hidden"/>
                    <div class="radio-card-inner">
                        <div class="radio-icon">&#128197;</div>
                        <div>
                            <div class="radio-title">Show All Timetable Schedule</div>
                            <div class="radio-desc">Display the complete timetable for all enrolled courses</div>
                        </div>
                    </div>
                </label>
                <label class="radio-card">
                    <asp:RadioButton ID="rbShowMatching" runat="server" GroupName="viewMode" CssClass="rb-hidden"/>
                    <div class="radio-card-inner">
                        <div class="radio-icon">&#127919;</div>
                        <div>
                            <div class="radio-title">Show Matching Schedule</div>
                            <div class="radio-desc">Show matched slots for your enrolled courses only</div>
                        </div>
                    </div>
                </label>
            </div>

            <asp:Button ID="btnShow" runat="server"
                Text="SHOW TIMETABLE"
                CssClass="btn-show"
                OnClick="btnShow_Click"/>
        </div>

        <asp:Panel ID="pnlTimetable" runat="server" Visible="false">

            <div class="section-label" style="margin-top:2rem">
                <asp:Label ID="lblTimetableTitle" runat="server" Text="TIMETABLE SCHEDULE"/>
            </div>

            <div style="margin-bottom:1rem">
                <button type="button" class="btn-pdf" onclick="printTimetableGrid()">
                    &#128438; Export as PDF
                </button>
            </div>

            <%-- Legend --%>
            <div class="legend-row">
                <asp:Repeater ID="rptLegend" runat="server">
                    <ItemTemplate>
                        <div class="legend-item">
                            <span class="legend-dot" style='background:<%# Eval("Color") %>'></span>
                            <span><%# Eval("CourseCode") %></span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <%-- Weekly grid --%>
            <div class="timetable-scroll">
                <div class="timetable-grid" id="timetableGrid">
                    <asp:Literal ID="litTimetable" runat="server"/>
                </div>
            </div>

            <div class="section-label" style="margin-top:2rem">SCHEDULE DETAILS</div>
            <div class="schedule-list">
                <asp:Repeater ID="rptSchedule" runat="server">
                    <ItemTemplate>
                        <div class="schedule-item" style='border-left-color:<%# Eval("Color") %>'>
                            <div class="sched-left">
                                <div class="sched-code" style='color:<%# Eval("Color") %>'><%# Eval("CourseCode") %></div>
                                <div class="sched-name"><%# Eval("CourseName") %></div>
                            </div>
                            <div class="sched-right">
                                <div class="sched-detail"><span class="sched-icon">&#128197;</span> <%# Eval("Day") %></div>
                                <div class="sched-detail"><span class="sched-icon">&#128336;</span> <%# Eval("StartTime") %> &ndash; <%# Eval("EndTime") %></div>
                                <div class="sched-detail"><span class="sched-icon">&#127979;</span> <%# Eval("Venue") %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

        </asp:Panel>

    </div>

</form>
<script src="~/Scripts/NavBar.js"></script>
<script src="~/Scripts/TimetableMatching.js"></script>
<script>
    (function(){var l=document.getElementById('pageLoader');if(!l)return;window.addEventListener('load',function(){setTimeout(function(){l.classList.add('hidden');setTimeout(function(){l.style.display='none';},400);},500);});})();

    function printTimetableGrid() {
        var gridEl = document.getElementById('timetableGrid');
        if (!gridEl) { alert('Please click SHOW TIMETABLE first.'); return; }

        // Collect student info from the page
        var studentId  = document.getElementById('<%= lblStudentId.ClientID %>');
        var studentName= document.getElementById('<%= lblProgram.ClientID %>');
        var session    = document.getElementById('<%= lblSession.ClientID %>');

        var sidText  = studentId   ? studentId.innerText   : '';
        var nameText = studentName ? studentName.innerText : '';
        var sessText = session     ? session.innerText     : '';
        var today    = new Date();
        var dateStr  = today.toLocaleDateString('en-GB', {day:'2-digit',month:'short',year:'numeric'});
        var timeStr  = today.toLocaleTimeString('en-GB', {hour:'2-digit',minute:'2-digit'});

        // Collect enrolled courses table rows
        var courseRows = '';
        var tbody = document.querySelector('#<%= rptCourses.ClientID %> tr, .data-table tbody tr');
        var allRows = document.querySelectorAll('.data-table tbody tr');
        var totalCredits = 0;
        allRows.forEach(function(tr, i) {
            var cells = tr.querySelectorAll('td');
            if (cells.length < 6) return;
            var credits = parseFloat(cells[4].innerText) || 0;
            totalCredits += credits;
            courseRows +=
                '<tr>' +
                '<td>' + (i+1) + '</td>' +
                '<td><b>' + cells[1].innerText.trim() + '</b></td>' +
                '<td>' + cells[2].innerText.trim() + '</td>' +
                '<td>' + cells[3].innerText.trim() + '</td>' +
                '<td style="text-align:center">' + credits.toFixed(2) + '</td>' +
                '</tr>';
        });
        courseRows += '<tr style="font-weight:700;background:#f5f5f5"><td colspan="4" style="text-align:right">Total Credit Hours</td><td style="text-align:center">' + totalCredits.toFixed(2) + '</td></tr>';

        var pw = window.open('', '_blank', 'width=1200,height=800');
        pw.document.write(
            '<!DOCTYPE html><html><head>' +
            '<meta charset="UTF-8"/>' +
            '<title>Registration Summary – ' + sidText + '</title>' +
            '<style>' +
            '  @page { size: A4 landscape; margin: 12mm 10mm; }' +
            '  * { box-sizing:border-box; margin:0; padding:0; }' +
            '  body { font-family: Arial, sans-serif; font-size: 11px; color:#111; background:#fff; }' +
            '  /* ── Header ── */' +
            '  .hdr { display:flex; justify-content:space-between; align-items:flex-start; border-bottom:2px solid #C0001D; padding-bottom:6px; margin-bottom:8px; }' +
            '  .hdr-left h1 { font-size:15px; color:#C0001D; letter-spacing:1px; }' +
            '  .hdr-left p  { font-size:10px; color:#555; margin-top:2px; }' +
            '  .hdr-right   { text-align:right; font-size:10px; color:#555; }' +
            '  /* ── Student Info ── */' +
            '  .info-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:6px; margin-bottom:10px; background:#f9f9f9; padding:7px; border-radius:4px; border:1px solid #E5E5E0; }' +
            '  .info-item label { display:block; font-size:9px; color:#888; text-transform:uppercase; letter-spacing:.5px; }' +
            '  .info-item .val  { font-weight:700; font-size:11px; margin-top:2px; }' +
            '  /* ── Section label ── */' +
            '  .sec-label { background:#C0001D; color:#fff; font-weight:700; font-size:10px; letter-spacing:1.5px; padding:4px 8px; margin:8px 0 4px; }' +
            '  /* ── Course table ── */' +
            '  table.ctbl { width:100%; border-collapse:collapse; margin-bottom:10px; }' +
            '  table.ctbl th { background:#C0001D; color:#fff; padding:5px 7px; font-size:10px; text-align:left; }' +
            '  table.ctbl td { border:1px solid #E5E5E0; padding:4px 7px; font-size:10px; }' +
            '  table.ctbl tr:nth-child(even) td { background:#fafafa; }' +
            '  /* ── Timetable grid ── */' +
            '  .timetable-grid { width:100%; }' +
            '  .tg-header-row,.tg-row { display:flex; }' +
            '  .tg-time-col { width:52px; min-width:52px; font-size:9px; color:#555; padding:3px 4px; border:1px solid #E5E5E0; }' +
            '  .tg-day-cell { flex:1; font-weight:700; font-size:10px; padding:4px 3px; border:1px solid #E5E5E0; text-align:center; }' +
            '  .tg-header-cell { background:#C0001D !important; color:#fff !important; -webkit-print-color-adjust:exact; print-color-adjust:exact; }' +
            '  .tg-cell { flex:1; min-height:38px; border:1px solid #E5E5E0; padding:2px; }' +
            '  .tg-slot { border-radius:3px; padding:3px 4px; margin-bottom:1px; color:#fff !important; border-left:3px solid rgba(0,0,0,.2); -webkit-print-color-adjust:exact; print-color-adjust:exact; }' +
            '  .tg-slot-code  { display:block; font-weight:700; font-size:9px; }' +
            '  .tg-slot-venue { display:block; font-size:8px; opacity:.9; }' +
            '</style>' +
            '</head><body>' +

            // Header
            '<div class="hdr">' +
            '  <div class="hdr-left"><h1>INTI INTERNATIONAL UNIVERSITY</h1><p>REGISTRATION SUMMARY</p></div>' +
            '  <div class="hdr-right">Date: ' + dateStr + '<br>Time: ' + timeStr + '</div>' +
            '</div>' +

            // Student info
            '<div class="info-grid">' +
            '  <div class="info-item"><label>Matriculation No</label><div class="val">' + sidText + '</div></div>' +
            '  <div class="info-item"><label>Student Name</label><div class="val">' + nameText + '</div></div>' +
            '  <div class="info-item"><label>Session</label><div class="val">' + sessText + '</div></div>' +
            '  <div class="info-item"><label>Mode Of Study</label><div class="val">FULL TIME</div></div>' +
            '</div>' +

            // Enrolled courses
            '<div class="sec-label">ENROLLED COURSES</div>' +
            '<table class="ctbl">' +
            '  <thead><tr><th style="width:30px">No</th><th style="width:110px">Course Code</th><th>Course Name</th><th>Lecturer</th><th style="width:80px;text-align:center">Credit Hours</th></tr></thead>' +
            '  <tbody>' + courseRows + '</tbody>' +
            '</table>' +

            // Timetable grid
            '<div class="sec-label">TIMETABLE SCHEDULE</div>' +
            '<div class="timetable-grid">' + gridEl.innerHTML + '</div>' +

            '</body></html>'
        );
        pw.document.close();
        pw.focus();
        setTimeout(function() { pw.print(); pw.close(); }, 600);
    }
</script>
</body>
</html>
