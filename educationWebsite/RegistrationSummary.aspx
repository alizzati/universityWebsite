<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RegistrationSummary.aspx.cs" Inherits="UniversitySystem.RegistrationSummary" %>
<%@ Register Src="~/Controls/NavBar.ascx" TagPrefix="uc" TagName="NavBar" %>

<!DOCTYPE html>
<html lang="en">
<%-- FIX: <head runat="server"> required for ~/ path resolution --%>
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Registration Summary — UniSys</title>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:wght@300;400;500;700&display=swap" rel="stylesheet"/>
    <link href="~/Styles/NavBar.css" rel="stylesheet"/>
    <style>
        :root{--red:#C0001D;--red-deep:#8B0015;--red-light:#FFF0F2;--bg:#F7F7F5;--card-bg:#FFFFFF;--border:#E5E5E0;--text:#1A1A1A;--muted:#6B6B65;--radius:12px;}
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
        .page-header::before{content:'SUMMARY';position:absolute;right:-1rem;top:50%;transform:translateY(-50%);font-family:'Bebas Neue',sans-serif;font-size:7rem;color:rgba(255,255,255,.06);pointer-events:none;letter-spacing:4px;white-space:nowrap;}
        .page-header h1{font-family:'Bebas Neue',sans-serif;font-size:2.6rem;letter-spacing:3px;color:#FFFFFF;}
        .page-header p{margin-top:.5rem;color:rgba(255,255,255,.75);font-size:.9rem;}

        .main{max-width:1100px;margin:0 auto;padding:2.5rem 1.5rem 5rem;}

        /* Tab nav */
        .tabs{display:flex;gap:.5rem;margin-bottom:1.5rem;background:var(--card-bg);padding:.5rem;border-radius:10px;border:1px solid var(--border);overflow-x:auto;}
        .tab-btn{padding:.7rem 1.4rem;border:none;background:transparent;color:var(--muted);font-family:'DM Sans',sans-serif;font-size:.9rem;font-weight:500;cursor:pointer;border-radius:6px;transition:all .2s;white-space:nowrap;}
        .tab-btn.active{background:var(--red);color:white;}
        .tab-btn:hover:not(.active){background:var(--red-light);color:var(--red);}

        .tab-content{display:none;}
        .tab-content.active{display:block;}

        /* Card */
        .card{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);padding:2rem;box-shadow:0 2px 16px rgba(0,0,0,.06);margin-bottom:1.5rem;}

        /* Section title */
        .section-title{font-family:'Bebas Neue',sans-serif;font-size:1.1rem;letter-spacing:2px;color:var(--red);margin-bottom:1.2rem;display:flex;align-items:center;gap:.7rem;}
        .section-title::after{content:'';flex:1;height:1px;background:var(--border);}

        /* Info grid */
        .info-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:1.2rem;margin-bottom:2rem;}
        .info-item{background:var(--bg);padding:1rem;border-radius:8px;}
        .info-item label{font-size:.72rem;color:var(--muted);text-transform:uppercase;letter-spacing:.5px;display:block;margin-bottom:.3rem;}
        .info-item .value{font-size:.95rem;font-weight:600;color:var(--text);}

        /* Stats */
        .summary-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:1rem;margin-bottom:2rem;}
        .stat-box{background:linear-gradient(135deg,var(--red-deep) 0%,var(--red) 100%);color:white;padding:1.5rem;border-radius:10px;text-align:center;}
        .stat-box .number{font-family:'Bebas Neue',sans-serif;font-size:2.5rem;letter-spacing:2px;}
        .stat-box .label{font-size:.78rem;opacity:.9;text-transform:uppercase;letter-spacing:1px;}

        /* Data table */
        .data-table{width:100%;border-collapse:collapse;font-size:.86rem;}
        .data-table th{background:var(--red-light);color:var(--red-deep);font-size:.72rem;text-transform:uppercase;letter-spacing:.5px;padding:.85rem 1rem;text-align:left;font-weight:700;}
        .data-table td{padding:.85rem 1rem;border-bottom:1px solid var(--border);vertical-align:middle;}
        .data-table tr:last-child td{border-bottom:none;}
        .data-table tr:hover td{background:#FAFAF8;}
        .course-code{font-family:'Bebas Neue',sans-serif;color:var(--red);font-size:1.05rem;letter-spacing:1px;}
        .badge{display:inline-block;padding:.25rem .75rem;border-radius:50px;font-size:.72rem;font-weight:700;letter-spacing:.3px;}
        .badge-active{background:#F0FFF7;color:#1A7A47;border:1px solid #B7EBD0;}
        .badge-dropped{background:#FFF5F6;color:#C0001D;border:1px solid #FFCCD2;}
        .badge-enrolled{background:#F0FFF7;color:#1A7A47;border:1px solid #B7EBD0;}

        /* Timetable grid */
        .timetable-grid{display:grid;grid-template-columns:80px repeat(5,1fr);gap:1px;background:var(--border);border-radius:10px;overflow:hidden;overflow-x:auto;}
        .timetable-header{background:var(--red-deep);color:white;padding:.9rem .5rem;text-align:center;font-size:.78rem;font-weight:700;letter-spacing:.5px;}
        .timetable-time{background:var(--red-light);color:var(--red-deep);padding:.75rem .5rem;text-align:center;font-size:.72rem;font-weight:700;}
        .timetable-slot{background:white;padding:.4rem;min-height:72px;position:relative;}
        .class-block{background:var(--red);color:white;padding:.45rem .5rem;border-radius:5px;font-size:.72rem;height:100%;display:flex;flex-direction:column;justify-content:center;}
        .class-block .course-name{font-weight:700;margin-bottom:.15rem;font-size:.7rem;}
        .class-block .room{opacity:.85;font-size:.65rem;}

        @media(max-width:768px){
            .summary-stats{grid-template-columns:repeat(2,1fr);}
            .timetable-grid{grid-template-columns:55px repeat(5,1fr);font-size:.68rem;}
        }
        @media(max-width:600px){.page-header{padding:1.8rem 1rem;}.page-header h1{font-size:2rem;}.main{padding:1.5rem 1rem 4rem;}}
    </style>
</head>
<body>
<form id="form1" runat="server">

    <div id="pageLoader">
        <div class="loader-logo">UNIV<span>&middot;</span>SYS</div>
        <div class="loader-bar-wrap"><div class="loader-bar"></div></div>
        <div class="loader-text">Loading summary...</div>
    </div>

    <uc:NavBar ID="NavBar1" runat="server"/>

    <div class="page-header">
        <h1>REGISTRATION SUMMARY</h1>
        <p>View your course registration and class schedule</p>
    </div>

    <main class="main">

        <div class="tabs">
            <button type="button" class="tab-btn active" onclick="switchTab(this,'summary')">&#128203; Summary</button>
            <button type="button" class="tab-btn"        onclick="switchTab(this,'timetable')">&#128197; Class Timetable</button>
            <button type="button" class="tab-btn"        onclick="switchTab(this,'history')">&#128200; Add/Drop History</button>
        </div>

        <%-- TAB 1: Summary --%>
        <div id="summary" class="tab-content active">
            <div class="card">
                <div class="section-title">Student Information</div>
                <div class="info-grid">
                    <div class="info-item"><label>Student Name</label><div class="value"><asp:Label ID="lblStudentName" runat="server"/></div></div>
                    <div class="info-item"><label>Student ID</label><div class="value"><asp:Label ID="lblStudentId" runat="server"/></div></div>
                    <div class="info-item"><label>Semester</label><div class="value">Current Semester</div></div>
                    <div class="info-item"><label>Status</label><div class="value"><asp:Label ID="lblStatus" runat="server" Text="Active"/></div></div>
                </div>

                <div class="section-title">Registration Statistics</div>
                <div class="summary-stats">
                    <div class="stat-box"><div class="number"><asp:Label ID="lblTotalCourses" runat="server" Text="0"/></div><div class="label">Total Courses</div></div>
                    <div class="stat-box"><div class="number"><asp:Label ID="lblTotalCredits" runat="server" Text="0"/></div><div class="label">Total Credits</div></div>
                    <div class="stat-box"><div class="number"><asp:Label ID="lblTotalHours"   runat="server" Text="0"/></div><div class="label">Contact Hours</div></div>
                    <div class="stat-box"><div class="number">&#10003;</div><div class="label">Enrolled</div></div>
                </div>

                <div class="section-title">Registered Courses</div>
                <asp:GridView ID="gvRegisteredCourses" runat="server"
                    AutoGenerateColumns="false"
                    CssClass="data-table"
                    EmptyDataText="No courses registered."
                    GridLines="None">
                    <Columns>
                        <asp:TemplateField HeaderText="Course">
                            <ItemTemplate>
                                <div class="course-code"><%# Eval("course_code") %></div>
                                <div style="font-size:.8rem;color:white"><%# Eval("course_name") %></div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="lecturer"  HeaderText="Lecturer"/>
                        <asp:BoundField DataField="credits"   HeaderText="Credits"/>
                        <asp:BoundField DataField="schedule"  HeaderText="Schedule"/>
                        <asp:BoundField DataField="room"      HeaderText="Room"/>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='badge badge-<%# Eval("status").ToString().ToLower() %>'>
                                    <%# Eval("status") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <%-- TAB 2: Timetable --%>
        <div id="timetable" class="tab-content">
            <div class="card">
                <div class="section-title">Weekly Class Timetable</div>
                <div class="timetable-grid">
                    <div class="timetable-header">Time</div>
                    <div class="timetable-header">Monday</div>
                    <div class="timetable-header">Tuesday</div>
                    <div class="timetable-header">Wednesday</div>
                    <div class="timetable-header">Thursday</div>
                    <div class="timetable-header">Friday</div>
                    <%-- Literal is populated by code-behind --%>
                    <asp:Literal ID="litTimetable" runat="server"/>
                </div>
            </div>
        </div>

        <%-- TAB 3: Add/Drop History --%>
        <div id="history" class="tab-content">
            <div class="card">
                <div class="section-title">Add/Drop History</div>
                <asp:GridView ID="gvHistory" runat="server"
                    AutoGenerateColumns="false"
                    CssClass="data-table"
                    EmptyDataText="No add/drop history found."
                    GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="action_date"  HeaderText="Date"        DataFormatString="{0:dd MMM yyyy}"/>
                        <asp:BoundField DataField="course_code"  HeaderText="Course Code"/>
                        <asp:BoundField DataField="course_name"  HeaderText="Course Name"/>
                        <asp:BoundField DataField="action_type"  HeaderText="Action"/>
                        <asp:BoundField DataField="processed_by" HeaderText="Processed By"/>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

    </main>

</form>
<script src="~/Scripts/NavBar.js"></script>
<script>
    function switchTab(btn, tabId) {
        document.querySelectorAll('.tab-content').forEach(function (t) { t.classList.remove('active'); });
        document.querySelectorAll('.tab-btn').forEach(function (b) { b.classList.remove('active'); });
        document.getElementById(tabId).classList.add('active');
        btn.classList.add('active');
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
