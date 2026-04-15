<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TeachingEvaluation.aspx.cs" Inherits="UniversitySystem.TeachingEvaluation" %>
<%@ Register Src="~/Controls/NavBar.ascx" TagName="NavBar" TagPrefix="uc" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Student Evaluation of Teaching — UniSys</title>
    <link href="~/Styles/NavBar.css"              rel="stylesheet" />
    <link href="~/Styles/TeachingEvaluation.css"  rel="stylesheet" />
</head>
<body>
<form id="form1" runat="server">

    <%-- ══ NAVBAR (reusable user control) ══ --%>
    <uc:NavBar ID="ucNavBar" runat="server" />

    <%-- ══ PAGE HEADER ══ --%>
    <div class="page-header">
        <a class="back-btn" href="#">&#8592; Back to Dashboard</a>
        <h1>Student Evaluation of Teaching</h1>
        <p>Rate your lecturers for the current semester &mdash; responses are anonymous.</p>
    </div>

    <%-- ══ MAIN ══ --%>
    <div class="main">

        <%-- ALERTS --%>
        <asp:Label ID="lblSuccess" runat="server" CssClass="alert alert-success" Visible="false" EnableViewState="false" />
        <asp:Label ID="lblError"   runat="server" CssClass="alert alert-error"   Visible="false" EnableViewState="false" />

        <%-- STATUS CARD --%>
        <div class="status-card">
            <div class="gauge-wrap">
                <svg class="gauge-svg" viewBox="0 0 100 55" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M10 50 A40 40 0 0 1 90 50" stroke="#EFEFEC" stroke-width="10" stroke-linecap="round"/>
                    <path id="gaugeArc"
                          d="M10 50 A40 40 0 0 1 90 50"
                          stroke="#C0001D"
                          stroke-width="10"
                          stroke-linecap="round"
                          stroke-dasharray="126"
                          stroke-dashoffset="126"/>
                </svg>
                <div class="gauge-pct">
                    <asp:Label ID="lblPercent" runat="server" Text="0%" />
                </div>
            </div>

            <div class="status-info">
                <h3>Evaluation Progress</h3>
                <div class="status-row">
                    <div class="status-item">
                        <label>Questioner Status</label>
                        <div class="val"><asp:Label ID="lblQuestionerStatus" runat="server" /></div>
                    </div>
                    <div class="status-item">
                        <label>Start Date</label>
                        <div class="val date-green"><asp:Label ID="lblStartDate" runat="server" /></div>
                    </div>
                    <div class="status-item">
                        <label>End Date</label>
                        <div class="val date-green"><asp:Label ID="lblEndDate" runat="server" /></div>
                    </div>
                    <div class="status-item">
                        <label>Completed</label>
                        <div class="val">
                            <asp:Label ID="lblCompletedCount" runat="server" Text="0" />
                            <span style="color:#9A9A93"> / </span>
                            <asp:Label ID="lblTotalCount" runat="server" Text="0" />
                        </div>
                    </div>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill" id="progressFill"></div>
                </div>
            </div>
        </div>

        <%-- ANONYMOUS NOTICE --%>
        <div class="anon-notice">
            &#128274; Your responses are completely anonymous. Ratings are not linked to your identity.
        </div>

        <%-- COMPLETED BANNER (shown at 100%) --%>
        <div class="completed-banner" id="completedBanner">
            <div class="big-check">&#10003;</div>
            <h2>ALL EVALUATIONS COMPLETE</h2>
            <p>You have successfully evaluated all your lecturers for this semester. Thank you!</p>
        </div>

        <%-- EVALUATION SECTION --%>
        <div id="evaluationSection">

            <div class="section-label">SELECT COURSE TO EVALUATE</div>

            <%-- COURSE CARDS --%>
            <div class="course-grid">
                <asp:Repeater ID="rptCourses" runat="server">
                    <ItemTemplate>
                        <div class='course-card <%# (bool)Eval("IsCompleted") ? "done" : "" %>'
                             onclick='<%# !(bool)Eval("IsCompleted")
                                         ? string.Format("selectCourse(this,\"{0}\",\"{1}\",\"{2}\")",
                                             Eval("CourseId"),
                                             Eval("CourseCode"),
                                             Eval("CourseName").ToString().Replace("\"","&quot;"))
                                         : "" %>'>

                            <%# (bool)Eval("IsCompleted") ? "<div class='done-tick'>&#10003;</div>" : "" %>

                            <div class="course-code"><%# Eval("CourseCode") %></div>
                            <div class="course-name"><%# Eval("CourseName") %></div>
                            <div class="course-lecturer">&#128100; <%# Eval("LecturerName") %></div>
                            <%# (bool)Eval("IsCompleted") ? "<div class='done-label'>Evaluated</div>" : "" %>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <%-- Hidden field — course yang dipilih --%>
            <asp:HiddenField ID="hfSelectedCourseId" runat="server" Value="0" />

            <%-- EVALUATION FORM --%>
            <div class="form-card" id="evalForm">
                <div class="form-header">
                    <h2>Evaluating: <span id="selectedCourseName" style="color:#C0001D">—</span></h2>
                    <p>Rate each statement honestly: 1 = Strongly Disagree &nbsp;&bull;&nbsp; 5 = Strongly Agree</p>
                </div>

                <div class="question-list">
                    <asp:Repeater ID="rptQuestions" runat="server">
                        <ItemTemplate>
                            <div class="question-item">
                                <div class="question-text">
                                    <span class="question-num"><%# Container.ItemIndex + 1 %>.</span>
                                    <%# Eval("QuestionText") %>
                                </div>

                                <%-- Likert 1-5 — pure HTML (no runat=server) agar JS berfungsi --%>
                                <div class="likert">
                                    <input type="radio" id='<%# "q"+Eval("QuestionId")+"_r1" %>' name='<%# "rating_q"+Eval("QuestionId") %>' value="1"/><label for='<%# "q"+Eval("QuestionId")+"_r1" %>'>1</label>
                                    <input type="radio" id='<%# "q"+Eval("QuestionId")+"_r2" %>' name='<%# "rating_q"+Eval("QuestionId") %>' value="2"/><label for='<%# "q"+Eval("QuestionId")+"_r2" %>'>2</label>
                                    <input type="radio" id='<%# "q"+Eval("QuestionId")+"_r3" %>' name='<%# "rating_q"+Eval("QuestionId") %>' value="3"/><label for='<%# "q"+Eval("QuestionId")+"_r3" %>'>3</label>
                                    <input type="radio" id='<%# "q"+Eval("QuestionId")+"_r4" %>' name='<%# "rating_q"+Eval("QuestionId") %>' value="4"/><label for='<%# "q"+Eval("QuestionId")+"_r4" %>'>4</label>
                                    <input type="radio" id='<%# "q"+Eval("QuestionId")+"_r5" %>' name='<%# "rating_q"+Eval("QuestionId") %>' value="5"/><label for='<%# "q"+Eval("QuestionId")+"_r5" %>'>5</label>
                                </div>

                                <div class="likert-legend">
                                    <span>Strongly Disagree</span>
                                    <span>Neutral</span>
                                    <span>Strongly Agree</span>
                                </div>
                            </div>
                            <%# Container.ItemIndex < 9 ? "<hr class='question-divider'/>" : "" %>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="comment-wrap">
                    <label for="<%=txtComment.ClientID %>">Additional Comments <span style="color:#9A9A93;font-weight:400">(Optional)</span></label>
                    <asp:TextBox ID="txtComment" runat="server" TextMode="MultiLine"
                        CssClass="comment-box"
                        placeholder="Share any additional thoughts about this lecturer..." />
                </div>

                <asp:Button ID="btnSubmit" runat="server"
                    Text="SUBMIT EVALUATION"
                    CssClass="btn-submit"
                    OnClick="btnSubmit_Click"
                    UseSubmitBehavior="true" />
            </div>

        </div><%-- /evaluationSection --%>

    </div><%-- /main --%>

</form>

<%-- Inject nilai dari server untuk JS --%>
<script>
    window.evalPct            = <%=EvalPercent %>;
    window.hfCourseIdClientId = '<%=hfSelectedCourseId.ClientID %>';
    window.btnSubmitClientId  = '<%=btnSubmit.ClientID %>';
</script>
<script src="~/Scripts/TeachingEvaluation.js"></script>
<script src="~/Scripts/NavBar.js"></script>

</body>
</html>
