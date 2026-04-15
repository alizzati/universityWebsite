<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TeachingEvaluation.aspx.cs" Inherits="UniversitySystem.TeachingEvaluation" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Student Evaluation of Teaching</title>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:ital,wght@0,300;0,400;0,500;0,700;1,300&display=swap" rel="stylesheet"/>
    <style>
        :root {
            --red:       #C0001D;
            --red-deep:  #8B0015;
            --red-glow:  rgba(192, 0, 29, 0.18);
            --black:     #0D0D0D;
            --off-black: #161616;
            --card-bg:   #1A1A1A;
            --border:    #2A2A2A;
            --white:     #F5F5F0;
            --muted:     #888880;
            --radius:    12px;
        }

        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--black);
            color: var(--white);
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* ── NAV ── */
        nav {
            background: var(--red-deep);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 2.5rem;
            height: 64px;
            position: sticky;
            top: 0;
            z-index: 100;
            box-shadow: 0 2px 24px rgba(0,0,0,.5);
        }
        .nav-logo {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 1.6rem;
            letter-spacing: 2px;
            color: var(--white);
        }
        .nav-links { display: flex; gap: 2rem; list-style: none; }
        .nav-links a {
            color: rgba(245,245,240,.75);
            text-decoration: none;
            font-size: .88rem;
            font-weight: 500;
            letter-spacing: .5px;
            transition: color .2s;
        }
        .nav-links a:hover { color: var(--white); }

        /* ── HERO STRIP ── */
        .page-header {
            background: linear-gradient(135deg, var(--red-deep) 0%, var(--red) 60%, #E8001F 100%);
            padding: 3rem 2.5rem 2.5rem;
            position: relative;
            overflow: hidden;
        }
        .page-header::before {
            content: 'EVALUATE';
            position: absolute;
            right: -1rem;
            top: 50%;
            transform: translateY(-50%);
            font-family: 'Bebas Neue', sans-serif;
            font-size: 9rem;
            color: rgba(255,255,255,.06);
            pointer-events: none;
            letter-spacing: 4px;
        }
        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: .4rem;
            color: rgba(255,255,255,.7);
            font-size: .82rem;
            text-decoration: none;
            margin-bottom: 1.2rem;
            transition: color .2s;
        }
        .back-btn:hover { color: var(--white); }
        .page-header h1 {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 2.8rem;
            letter-spacing: 3px;
            line-height: 1;
        }
        .page-header p { margin-top: .5rem; color: rgba(255,255,255,.75); font-size: .9rem; }

        /* ── MAIN ── */
        .main {
            max-width: 860px;
            margin: 0 auto;
            padding: 2.5rem 1.5rem 5rem;
        }

        /* ── STATUS CARD ── */
        .status-card {
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 1.8rem 2rem;
            display: flex;
            align-items: center;
            gap: 2.5rem;
            margin-bottom: 2rem;
            position: relative;
            overflow: hidden;
        }
        .status-card::before {
            content: '';
            position: absolute;
            left: 0; top: 0; bottom: 0;
            width: 4px;
            background: var(--red);
        }
        .gauge-wrap { flex-shrink: 0; position: relative; width: 100px; height: 60px; }
        .gauge-svg { width: 100px; }
        .gauge-pct {
            position: absolute;
            bottom: 0; left: 50%;
            transform: translateX(-50%);
            font-family: 'Bebas Neue', sans-serif;
            font-size: 1.5rem;
            color: var(--white);
        }
        .status-info { flex: 1; }
        .status-info h3 { font-size: 1rem; font-weight: 500; color: var(--muted); margin-bottom: .6rem; }
        .status-row { display: flex; gap: 2rem; flex-wrap: wrap; }
        .status-item label { font-size: .75rem; color: var(--muted); display: block; margin-bottom: .15rem; }
        .status-item .val { font-size: .92rem; font-weight: 600; }
        .badge {
            display: inline-block;
            padding: .2rem .7rem;
            border-radius: 50px;
            font-size: .75rem;
            font-weight: 700;
            letter-spacing: .5px;
        }
        .badge-open   { background: rgba(0,200,100,.15); color: #00C864; border: 1px solid rgba(0,200,100,.3); }
        .badge-closed { background: rgba(192,0,29,.15);  color: #FF3355;  border: 1px solid rgba(192,0,29,.3); }
        .badge-pending { background: rgba(255,180,0,.12); color: #FFB800; border: 1px solid rgba(255,180,0,.3); }

        /* ── ALERT ── */
        .alert {
            padding: .9rem 1.2rem;
            border-radius: 8px;
            font-size: .88rem;
            margin-bottom: 1.5rem;
            display: none;
        }
        .alert-success { background: rgba(0,200,100,.1); border: 1px solid rgba(0,200,100,.3); color: #00C864; display: block; }
        .alert-error   { background: rgba(192,0,29,.1);  border: 1px solid rgba(192,0,29,.4);  color: #FF4466;  display: block; }

        /* ── COURSE SELECTOR ── */
        .section-label {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 1.1rem;
            letter-spacing: 2px;
            color: var(--red);
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: .6rem;
        }
        .section-label::after {
            content: '';
            flex: 1;
            height: 1px;
            background: var(--border);
        }

        .course-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
            gap: .9rem;
            margin-bottom: 2rem;
        }
        .course-card {
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 1.1rem 1.3rem;
            cursor: pointer;
            transition: border-color .2s, background .2s, transform .15s;
            position: relative;
        }
        .course-card:hover {
            border-color: var(--red);
            background: #1f1f1f;
            transform: translateY(-2px);
        }
        .course-card.selected {
            border-color: var(--red);
            background: rgba(192,0,29,.08);
            box-shadow: 0 0 0 2px var(--red-glow);
        }
        .course-card.done { opacity: .55; cursor: default; }
        .course-card.done:hover { transform: none; border-color: var(--border); background: var(--card-bg); }
        .course-code { font-family: 'Bebas Neue', sans-serif; font-size: 1.05rem; letter-spacing: 1.5px; color: var(--red); }
        .course-name { font-size: .82rem; color: var(--muted); margin-top: .15rem; line-height: 1.4; }
        .course-lecturer { font-size: .78rem; color: var(--white); margin-top: .5rem; font-weight: 500; }
        .done-tick {
            position: absolute;
            top: .7rem; right: .7rem;
            width: 20px; height: 20px;
            background: var(--red);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: .6rem;
        }

        /* ── FORM CARD ── */
        .form-card {
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 2rem;
            margin-bottom: 2rem;
            display: none;
        }
        .form-card.visible { display: block; animation: slideIn .3s ease; }
        @keyframes slideIn { from { opacity:0; transform:translateY(12px); } to { opacity:1; transform:translateY(0); } }

        .form-header {
            border-bottom: 1px solid var(--border);
            padding-bottom: 1.2rem;
            margin-bottom: 1.5rem;
        }
        .form-header h2 { font-size: 1.1rem; font-weight: 600; }
        .form-header p { font-size: .82rem; color: var(--muted); margin-top: .3rem; }

        /* ── QUESTION ROW ── */
        .question-list { display: flex; flex-direction: column; gap: 1.4rem; }
        .question-item { }
        .question-text {
            font-size: .9rem;
            line-height: 1.6;
            margin-bottom: .7rem;
            color: rgba(245,245,240,.9);
        }
        .question-num {
            font-family: 'Bebas Neue', sans-serif;
            font-size: .85rem;
            color: var(--red);
            margin-right: .4rem;
        }

        /* Likert scale */
        .likert {
            display: flex;
            gap: .5rem;
            flex-wrap: wrap;
        }
        .likert input[type=radio] { display: none; }
        .likert label {
            width: 44px; height: 44px;
            display: flex; align-items: center; justify-content: center;
            border-radius: 8px;
            border: 1.5px solid var(--border);
            font-size: .88rem;
            font-weight: 600;
            cursor: pointer;
            transition: all .18s;
            color: var(--muted);
        }
        .likert label:hover { border-color: var(--red); color: var(--white); }
        .likert input[type=radio]:checked + label {
            background: var(--red);
            border-color: var(--red);
            color: var(--white);
            box-shadow: 0 0 12px var(--red-glow);
        }
        .likert-legend {
            display: flex;
            justify-content: space-between;
            font-size: .72rem;
            color: var(--muted);
            margin-top: .35rem;
            padding: 0 2px;
        }

        /* Comment */
        .comment-wrap { margin-top: 1.8rem; }
        .comment-wrap label { font-size: .88rem; color: var(--muted); display: block; margin-bottom: .5rem; }
        textarea.comment-box {
            width: 100%;
            background: var(--off-black);
            border: 1px solid var(--border);
            border-radius: 8px;
            color: var(--white);
            font-family: 'DM Sans', sans-serif;
            font-size: .88rem;
            padding: .9rem 1rem;
            resize: vertical;
            min-height: 90px;
            transition: border-color .2s;
        }
        textarea.comment-box:focus { outline: none; border-color: var(--red); }

        /* ── SUBMIT BTN ── */
        .btn-submit {
            display: block;
            width: 100%;
            margin-top: 2rem;
            padding: 1rem;
            background: var(--red);
            color: var(--white);
            font-family: 'Bebas Neue', sans-serif;
            font-size: 1.2rem;
            letter-spacing: 3px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            transition: background .2s, transform .15s, box-shadow .2s;
        }
        .btn-submit:hover {
            background: #E8001F;
            transform: translateY(-1px);
            box-shadow: 0 6px 24px rgba(192,0,29,.4);
        }
        .btn-submit:active { transform: translateY(0); }
        .btn-submit:disabled { opacity: .45; cursor: not-allowed; transform: none; }

        /* ── PROGRESS ── */
        .progress-bar {
            height: 4px;
            background: var(--border);
            border-radius: 2px;
            margin-top: 1.5rem;
            overflow: hidden;
        }
        .progress-fill {
            height: 100%;
            background: var(--red);
            border-radius: 2px;
            transition: width .4s ease;
        }

        /* ── COMPLETED STATE ── */
        .completed-banner {
            text-align: center;
            padding: 3rem 2rem;
            display: none;
        }
        .completed-banner.visible { display: block; }
        .big-check {
            width: 80px; height: 80px;
            border-radius: 50%;
            background: rgba(0,200,100,.15);
            border: 2px solid rgba(0,200,100,.4);
            display: flex; align-items: center; justify-content: center;
            font-size: 2rem;
            margin: 0 auto 1.5rem;
        }
        .completed-banner h2 {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 2rem;
            letter-spacing: 3px;
            margin-bottom: .5rem;
        }
        .completed-banner p { color: var(--muted); font-size: .9rem; }

        /* ── RESPONSIVE ── */
        @media(max-width: 600px) {
            nav { padding: 0 1rem; }
            .page-header { padding: 2rem 1rem 1.8rem; }
            .page-header h1 { font-size: 2rem; }
            .main { padding: 1.5rem 1rem 4rem; }
            .status-card { flex-direction: column; gap: 1rem; }
            .form-card { padding: 1.2rem; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <!-- NAV -->
    <nav>
        <div class="nav-logo">UNIV<span style="color:rgba(255,255,255,.45)">·</span>SYS</div>
        <ul class="nav-links">
            <li><a href="#">Enquiry</a></li>
            <li><a href="#">Enrollment</a></li>
            <li><a href="#">Add / Drop</a></li>
            <li><a href="#">Timetable</a></li>
        </ul>
    </nav>

    <!-- PAGE HEADER -->
    <div class="page-header">
        <a class="back-btn" href="#">&#8592; Back to Dashboard</a>
        <h1>Student Evaluation of Teaching</h1>
        <p>Rate your lecturers for the current semester — your feedback drives improvement.</p>
    </div>

    <!-- MAIN -->
    <div class="main">

        <!-- ALERTS -->
        <asp:Label ID="lblSuccess" runat="server" CssClass="alert alert-success" Visible="false" />
        <asp:Label ID="lblError"   runat="server" CssClass="alert alert-error"   Visible="false" />

        <!-- STATUS CARD -->
        <div class="status-card">
            <div class="gauge-wrap">
                <svg class="gauge-svg" viewBox="0 0 100 55" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M10 50 A40 40 0 0 1 90 50" stroke="#2A2A2A" stroke-width="10" stroke-linecap="round"/>
                    <path id="gaugeArc" d="M10 50 A40 40 0 0 1 90 50" stroke="#C0001D" stroke-width="10"
                          stroke-linecap="round" stroke-dasharray="126" stroke-dashoffset="126"/>
                </svg>
                <div class="gauge-pct"><asp:Label ID="lblPercent" runat="server" Text="0%" /></div>
            </div>
            <div class="status-info">
                <h3>Evaluation Progress</h3>
                <div class="status-row">
                    <div class="status-item">
                        <label>Status</label>
                        <div class="val">
                            <asp:Label ID="lblQuestionerStatus" runat="server" />
                        </div>
                    </div>
                    <div class="status-item">
                        <label>Start Date</label>
                        <div class="val" style="color:#00C864"><asp:Label ID="lblStartDate" runat="server" /></div>
                    </div>
                    <div class="status-item">
                        <label>End Date</label>
                        <div class="val" style="color:#00C864"><asp:Label ID="lblEndDate" runat="server" /></div>
                    </div>
                    <div class="status-item">
                        <label>Completed</label>
                        <div class="val"><asp:Label ID="lblCompletedCount" runat="server" Text="0" /> / <asp:Label ID="lblTotalCount" runat="server" Text="0" /></div>
                    </div>
                </div>
                <div class="progress-bar" style="margin-top:.9rem">
                    <div class="progress-fill" id="progressFill" style="width:0%"></div>
                </div>
            </div>
        </div>

        <!-- ALL DONE BANNER (shown when 100%) -->
        <div class="completed-banner" id="completedBanner">
            <div class="big-check">✓</div>
            <h2>ALL EVALUATIONS COMPLETE</h2>
            <p>You have successfully evaluated all your lecturers for this semester. Thank you!</p>
        </div>

        <!-- COURSE SELECTION -->
        <div id="evaluationSection">
            <div class="section-label">SELECT COURSE TO EVALUATE</div>
            <div class="course-grid" id="courseGrid">
                <asp:Repeater ID="rptCourses" runat="server" OnItemCommand="rptCourses_ItemCommand">
                    <ItemTemplate>
                        <div class="course-card <%# (bool)Eval("IsCompleted") ? "done" : "" %>"
                             onclick='<%# !(bool)Eval("IsCompleted") ? "selectCourse(this, " + Eval("CourseId") + ")" : "" %>'>
                            <%# (bool)Eval("IsCompleted") ? "<div class='done-tick'>✓</div>" : "" %>
                            <div class="course-code"><%# Eval("CourseCode") %></div>
                            <div class="course-name"><%# Eval("CourseName") %></div>
                            <div class="course-lecturer">&#128100; <%# Eval("LecturerName") %></div>
                            <%# !(bool)Eval("IsCompleted") ?
                                "<asp:Button runat='server' style='display:none' CommandName='SelectCourse' CommandArgument='" + Eval("CourseId") + "' />" : "" %>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <!-- HIDDEN FIELD to pass selected course -->
            <asp:HiddenField ID="hfSelectedCourseId" runat="server" Value="0" />

            <!-- EVALUATION FORM -->
            <div class="form-card" id="evalForm">
                <div class="form-header">
                    <h2>Evaluate: <span id="selectedCourseName">—</span></h2>
                    <p>Rate each statement on a scale of 1 (Strongly Disagree) to 5 (Strongly Agree)</p>
                </div>

                <div class="question-list" id="questionList">
                    <!-- Questions rendered by repeater -->
                    <asp:Repeater ID="rptQuestions" runat="server">
                        <ItemTemplate>
                            <div class="question-item">
                                <div class="question-text">
                                    <span class="question-num"><%# Container.ItemIndex + 1 %>.</span><%# Eval("QuestionText") %>
                                </div>
                                <div class="likert" id="likert_<%# Eval("QuestionId") %>">
                                    <%# BuildLikertHtml((int)Eval("QuestionId")) %>
                                </div>
                                <div class="likert-legend">
                                    <span>Strongly Disagree</span>
                                    <span>Neutral</span>
                                    <span>Strongly Agree</span>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="comment-wrap">
                    <label for="txtComment">Additional Comments (Optional)</label>
                    <asp:TextBox ID="txtComment" runat="server" TextMode="MultiLine"
                        CssClass="comment-box" placeholder="Share any additional thoughts about this lecturer..." />
                </div>

                <asp:Button ID="btnSubmit" runat="server" Text="SUBMIT EVALUATION"
                    CssClass="btn-submit" OnClick="btnSubmit_Click" />
            </div>
        </div>

    </div><!-- /main -->

</form>

<script>
    // Gauge animation
    (function () {
        const arc = document.getElementById('gaugeArc');
        const fill = document.getElementById('progressFill');
        const pctLabel = document.querySelector('#lblPercent, [id$=lblPercent]');
        const total = parseInt('<%=TotalCourses %>') || 0;
        const done  = parseInt('<%=CompletedCourses %>') || 0;
        const pct   = total > 0 ? Math.round(done / total * 100) : 0;

        // Gauge: dasharray=126 = full semicircle
        const offset = 126 - (126 * pct / 100);
        setTimeout(() => {
            if (arc) arc.style.transition = 'stroke-dashoffset .8s ease';
            if (arc) arc.setAttribute('stroke-dashoffset', offset);
            if (fill) fill.style.width = pct + '%';
        }, 200);

        // Show completed banner if 100%
        if (pct >= 100) {
            const banner = document.getElementById('completedBanner');
            const section = document.getElementById('evaluationSection');
            if (banner) banner.classList.add('visible');
            if (section) section.style.display = 'none';
        }
    })();

    // Select course card
    let selectedId = 0;
    function selectCourse(el, courseId) {
        document.querySelectorAll('.course-card').forEach(c => c.classList.remove('selected'));
        el.classList.add('selected');
        selectedId = courseId;

        document.getElementById('<%= hfSelectedCourseId.ClientID %>').value = courseId;

        // Show form
        const formCard = document.getElementById('evalForm');
        formCard.classList.add('visible');
        formCard.scrollIntoView({ behavior: 'smooth', block: 'start' });

        // Update title
        const name = el.querySelector('.course-name').textContent;
        const code = el.querySelector('.course-code').textContent;
        document.getElementById('selectedCourseName').textContent = code + ' — ' + name;
    }

    // Validate all questions answered before submit
    document.getElementById('<%= btnSubmit.ClientID %>').addEventListener('click', function(e) {
        const radios = document.querySelectorAll('#evalForm .likert input[type=radio]');
        const groups = {};
        radios.forEach(r => { groups[r.name] = groups[r.name] || []; groups[r.name].push(r); });
        let allAnswered = true;
        for (const g in groups) {
            if (!groups[g].some(r => r.checked)) { allAnswered = false; break; }
        }
        if (!allAnswered) {
            e.preventDefault();
            alert('Please rate all questions before submitting.');
        }
        if (!selectedId || selectedId == 0) {
            e.preventDefault();
            alert('Please select a course first.');
        }
    });
</script>
</body>
</html>
