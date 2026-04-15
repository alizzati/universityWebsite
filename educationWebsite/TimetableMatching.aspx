<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="T2_imetableMatching.aspx.cs" Inherits="UniversitySystem.TimetableMatching" %>
<%@ Register Src="~/Controls/NavBar.ascx" TagName="NavBar" TagPrefix="uc" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Timetable Matching — UniSys</title>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:wght@300;400;500;700&display=swap" rel="stylesheet"/>
    <link href="Styles/NavBar.css"            rel="stylesheet"/>
    <link href="Styles/TimetableMatching.css" rel="stylesheet"/>
</head>
<body>
<form id="form1" runat="server">

    <%-- PAGE LOADER --%>
    <div id="pageLoader">
        <div class="loader-logo">UNIV<span>&middot;</span>SYS</div>
        <div class="loader-bar-wrap"><div class="loader-bar"></div></div>
        <div class="loader-text">Loading timetable...</div>
    </div>

    <%-- NAVBAR --%>
    <uc:NavBar ID="ucNavBar" runat="server" />

    <%-- PAGE HEADER --%>
    <div class="page-header" data-label="TIMETABLE">
        <a class="back-btn" href="#">&#8592; Back to Dashboard</a>
        <h1>Timetable Matching</h1>
        <p>View your class schedule and find matching timetable slots for your enrolled courses.</p>
    </div>

    <div class="main">

        <%-- ALERTS --%>
        <asp:Label ID="lblError"   runat="server" CssClass="alert alert-error"   Visible="false" EnableViewState="false"/>
        <asp:Label ID="lblSuccess" runat="server" CssClass="alert alert-success" Visible="false" EnableViewState="false"/>

        <%-- INFO CARD — Session / Student / Program --%>
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
                    <label>Program</label>
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

        <%-- ── ENROLLED COURSES (read-only) ── --%>
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

        <%-- ── VIEW MODE SELECTOR ── --%>
        <div class="view-mode-card">
            <div class="section-label" style="margin-bottom:1.2rem">VIEW OPTIONS</div>
            <div class="radio-group">
                <label class="radio-card">
                    <asp:RadioButton ID="rbShowAll"      runat="server" GroupName="viewMode" Checked="true" CssClass="rb-hidden"/>
                    <div class="radio-card-inner">
                        <div class="radio-icon">&#128197;</div>
                        <div>
                            <div class="radio-title">Show All Timetable Schedule</div>
                            <div class="radio-desc">Display the complete timetable for all courses this semester</div>
                        </div>
                    </div>
                </label>
                <label class="radio-card">
                    <asp:RadioButton ID="rbShowMatching" runat="server" GroupName="viewMode" CssClass="rb-hidden"/>
                    <div class="radio-card-inner">
                        <div class="radio-icon">&#127919;</div>
                        <div>
                            <div class="radio-title">Show Matching Schedule</div>
                            <div class="radio-desc">Show only matched slots for your enrolled courses</div>
                        </div>
                    </div>
                </label>
            </div>

            <asp:Button ID="btnShow" runat="server"
                Text="SHOW TIMETABLE"
                CssClass="btn-show"
                OnClick="btnShow_Click"/>
        </div>

        <%-- ── TIMETABLE RESULT (shown after button click) ── --%>
        <asp:Panel ID="pnlTimetable" runat="server" Visible="false">

            <div class="section-label" style="margin-top:2rem">
                <asp:Label ID="lblTimetableTitle" runat="server" Text="TIMETABLE SCHEDULE"/>
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

            <%-- Weekly timetable grid --%>
            <div class="timetable-scroll">
                <div class="timetable-grid" id="timetableGrid">
                    <asp:Literal ID="litTimetable" runat="server"/>
                </div>
            </div>

            <%-- Detailed schedule list --%>
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

    </div><%-- /main --%>

</form>
<script src="Scripts/NavBar.js"></script>
<script src="Scripts/TimetableMatching.js"></script>
</body>
</html>
