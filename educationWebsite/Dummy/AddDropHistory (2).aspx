<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddDropHistory.aspx.cs" Inherits="UniversitySystem.AddDropHistory" %>
<%@ Register Src="~/Controls/NavBar.ascx" TagName="NavBar" TagPrefix="uc" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Add/Drop History — UniSys</title>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:wght@300;400;500;700&display=swap" rel="stylesheet"/>
    <link href="~/Styles/NavBar.css" rel="stylesheet"/>
    <style>
        :root{--red:#C0001D;--red-deep:#8B0015;--red-light:#FFF0F2;--red-glow:rgba(192,0,29,.12);--bg:#F7F7F5;--card-bg:#FFFFFF;--border:#E5E5E0;--text:#1A1A1A;--muted:#6B6B65;--radius:12px;}
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
        body{font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;}
        .page-header{background:linear-gradient(135deg,var(--red-deep) 0%,var(--red) 100%);padding:2.5rem 2.5rem 2.2rem;position:relative;overflow:hidden;}
        .page-header::before{content:'HISTORY';position:absolute;right:-1rem;top:50%;transform:translateY(-50%);font-family:'Bebas Neue',sans-serif;font-size:8rem;color:rgba(255,255,255,.05);pointer-events:none;letter-spacing:4px;white-space:nowrap;}
        .page-header h1{font-family:'Bebas Neue',sans-serif;font-size:2.6rem;letter-spacing:3px;color:#FFF;line-height:1;}
        .page-header p{margin-top:.5rem;color:rgba(255,255,255,.75);font-size:.9rem;}
        .main{max-width:960px;margin:0 auto;padding:2.5rem 1.5rem 5rem;}
        .section-label{font-family:'Bebas Neue',sans-serif;font-size:1rem;letter-spacing:2.5px;color:var(--red);margin-bottom:1rem;display:flex;align-items:center;gap:.7rem;}
        .section-label::after{content:'';flex:1;height:1px;background:var(--border);}
        .stats-row{display:grid;grid-template-columns:repeat(4,1fr);gap:1rem;margin-bottom:2rem;}
        .stat-card{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);padding:1.2rem 1.5rem;box-shadow:0 1px 6px rgba(0,0,0,.05);}
        .stat-label{font-size:.72rem;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:.3rem;}
        .stat-value{font-family:'Bebas Neue',sans-serif;font-size:1.8rem;letter-spacing:1px;color:var(--text);}
        .stat-value.add-color{color:#1A7A47;}
        .stat-value.drop-color{color:var(--red);}
        .filter-bar{display:flex;gap:1rem;align-items:center;margin-bottom:1.5rem;flex-wrap:wrap;}
        .filter-bar select{padding:.55rem .9rem;border:1.5px solid var(--border);border-radius:8px;font-family:'DM Sans',sans-serif;font-size:.85rem;color:var(--text);background:var(--card-bg);cursor:pointer;}
        .filter-bar select:focus{outline:none;border-color:var(--red);}
        .export-btns{display:flex;gap:.6rem;margin-left:auto;}
        .btn-export{padding:.5rem 1rem;border:1.5px solid var(--border);border-radius:7px;font-family:'Bebas Neue',sans-serif;font-size:.82rem;letter-spacing:1px;cursor:pointer;background:var(--card-bg);color:var(--text);text-decoration:none;display:inline-block;transition:all .2s;}
        .btn-export:hover{border-color:var(--red);color:var(--red);}
        #btnExportTxt::before { content: '📄 '; }
        #btnExportCsv::before { content: '📊 '; }
        .table-wrap{background:var(--card-bg);border:1px solid var(--border);border-radius:var(--radius);overflow:hidden;box-shadow:0 1px 8px rgba(0,0,0,.06);overflow-x:auto;}
        .data-table{width:100%;border-collapse:collapse;font-size:.86rem;}
        .data-table thead tr{background:#F2F2EF;}
        .data-table th{padding:.85rem 1.1rem;text-align:left;font-weight:700;font-size:.72rem;text-transform:uppercase;letter-spacing:.8px;color:var(--muted);border-bottom:1px solid var(--border);}
        .data-table td{padding:.85rem 1.1rem;border-bottom:1px solid #F0F0EC;vertical-align:middle;}
        .data-table tbody tr:hover{background:#FAFAF8;}
        .data-table tbody tr:last-child td{border-bottom:none;}
        .badge-add{background:#F0FFF7;color:#1A7A47;border:1px solid #B7EBD0;border-radius:50px;font-size:.72rem;font-weight:700;padding:.2rem .65rem;}
        .badge-drop{background:#FFF5F6;color:#C0001D;border:1px solid #FFCCD2;border-radius:50px;font-size:.72rem;font-weight:700;padding:.2rem .65rem;}
        .cc-code{font-family:'Bebas Neue',sans-serif;font-size:.95rem;letter-spacing:1px;color:var(--red);}
        .empty-row td{text-align:center;padding:3rem;color:var(--muted);font-style:italic;}
        @media(max-width:700px){.stats-row{grid-template-columns:1fr 1fr;}.filter-bar{flex-direction:column;align-items:flex-start;}.export-btns{margin-left:0;}}
        @media(max-width:480px){.stats-row{grid-template-columns:1fr;}}
    </style>
</head>
<body>
<form id="form1" runat="server">

    <uc:NavBar ID="ucNavBar" runat="server"/>

    <div class="page-header">
        <h1>Add / Drop History</h1>
        <p>Complete record of your course add and drop transactions.</p>
    </div>

    <div class="main">

        <%-- STATS --%>
        <div class="stats-row">
            <div class="stat-card">
                <div class="stat-label">Total Adds</div>
                <div class="stat-value add-color"><asp:Label ID="lblTotalAdds" runat="server" Text="0"/></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Total Drops</div>
                <div class="stat-value drop-color"><asp:Label ID="lblTotalDrops" runat="server" Text="0"/></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Total Actions</div>
                <div class="stat-value"><asp:Label ID="lblTotalActions" runat="server" Text="0"/></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Active Enrollments</div>
                <div class="stat-value"><asp:Label ID="lblCurrentEnrollments" runat="server" Text="0"/></div>
            </div>
        </div>

        <div class="section-label">TRANSACTION HISTORY</div>

        <%-- Filter bar --%>
        <div class="filter-bar">
            <asp:DropDownList ID="ddlActionType" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
                <asp:ListItem Text="All Actions" Value=""/>
                <asp:ListItem Text="Add Only"    Value="Add"/>
                <asp:ListItem Text="Drop Only"   Value="Drop"/>
            </asp:DropDownList>

            <asp:DropDownList ID="ddlDateRange" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
                <asp:ListItem Text="All Time"    Value=""/>
                <asp:ListItem Text="Last 7 days"  Value="7"/>
                <asp:ListItem Text="Last 30 days" Value="30"/>
                <asp:ListItem Text="Last 90 days" Value="90"/>
            </asp:DropDownList>

            <%-- FIX: Export buttons use asp:Button with proper OnClick --%>
            <div class="export-btns">
                <asp:Button ID="btnExportTxt" runat="server"
                    Text="Export TXT"
                    CssClass="btn-export"
                    OnClick="btnExportPDF_Click"
                    CausesValidation="false"/>
                <asp:Button ID="btnExportCsv" runat="server"
                    Text="Export CSV"
                    CssClass="btn-export"
                    OnClick="btnExportExcel_Click"
                    CausesValidation="false"/>
            </div>
        </div>

        <%-- History table --%>
        <div class="table-wrap">
            <asp:GridView ID="gvHistory" runat="server"
                CssClass="data-table"
                AutoGenerateColumns="false"
                GridLines="None"
                AllowPaging="true"
                PageSize="15"
                OnPageIndexChanging="gvHistory_PageIndexChanging">
                <Columns>
                    <asp:BoundField  DataField="ActionDate"  HeaderText="Date"        DataFormatString="{0:dd MMM yyyy}"/>
                    <asp:TemplateField HeaderText="Action">
                        <ItemTemplate>
                            <span class='<%# Eval("Action").ToString() == "Add" ? "badge-add" : "badge-drop" %>'>
                                <%# Eval("Action") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Course Code">
                        <ItemTemplate>
                            <span class="cc-code"><%# Eval("CourseCode") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField  DataField="CourseName"  HeaderText="Course Name"/>
                    <asp:BoundField  DataField="CreditHours" HeaderText="Credits"     ItemStyle-CssClass="td-center"/>
                </Columns>
                <EmptyDataTemplate>
                    <table class="data-table"><tr class="empty-row"><td colspan="5">No add/drop transactions found.</td></tr></table>
                </EmptyDataTemplate>
                <PagerStyle CssClass="grid-pager"/>
            </asp:GridView>
        </div>

    </div>
</form>
<script src="~/Scripts/NavBar.js"></script>
</body>
</html>
