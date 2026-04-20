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
                        <th>Section</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptCourses" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td class="td-num"><%# Container.ItemIndex + 1 %></td>
                                <td><span class="course-code-badge"><%# Eval("CourseCode") %></span></td>
                                <td><%# Eval("CourseName") %></td>
                                <td><span class="section-badge"><%# Eval("Section") %></span></td>
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
        if (!gridEl) { window.print(); return; }

        var titleEl = document.getElementById('<%= lblTimetableTitle.ClientID %>');
        var titleText = titleEl ? titleEl.innerText : 'TIMETABLE SCHEDULE';

        var printWindow = window.open('', '_blank', 'width=1100,height=700');
        printWindow.document.write(
            '<!DOCTYPE html><html><head>' +
            '<meta charset="UTF-8"/>' +
            '<title>Timetable – UniSys</title>' +
            '<style>' +
            '  @page { size: landscape; margin: 15mm; }' +
            '  body { font-family: DM Sans, Arial, sans-serif; background:#fff; color:#111; margin:0; padding:0; }' +
            '  h2 { font-family: Bebas Neue, Arial, sans-serif; color:#C0001D; letter-spacing:2px; margin:0 0 12px; }' +
            '  .timetable-grid { width:100%; }' +
            '  .tg-header-row, .tg-row { display:flex; }' +
            '  .tg-time-col { width:70px; min-width:70px; font-size:11px; color:#555; padding:4px 6px; border:1px solid #E5E5E0; }' +
            '  .tg-day-cell { flex:1; font-weight:700; font-size:12px; padding:6px; border:1px solid #E5E5E0; text-align:center; }' +
            '  .tg-header-cell { background:#C0001D; color:#fff; }' +
            '  .tg-cell { flex:1; min-height:48px; border:1px solid #E5E5E0; padding:2px; }' +
            '  .tg-slot { border-radius:4px; padding:4px 5px; margin-bottom:2px; color:#fff; border-left:3px solid rgba(0,0,0,.25); -webkit-print-color-adjust:exact; print-color-adjust:exact; }' +
            '  .tg-slot-code { display:block; font-weight:700; font-size:10px; }' +
            '  .tg-slot-venue { display:block; font-size:9px; opacity:.9; }' +
            '</style>' +
            '</head><body>' +
            '<h2>' + titleText + '</h2>' +
            '<div class="timetable-grid">' + gridEl.innerHTML + '</div>' +
            '</body></html>'
        );
        printWindow.document.close();
        printWindow.focus();
        setTimeout(function() {
            printWindow.print();
            printWindow.close();
        }, 500);
    }
</script>
</body>
</html>
