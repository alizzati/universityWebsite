<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentStatement.aspx.cs" Inherits="UniversitySystem.StudentStatement" %>
<%@ Register Src="~/Controls/NavBar.ascx" TagPrefix="uc" TagName="NavBar" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <title>Student Statement - UniSys</title>
    <link rel="stylesheet" href="Styles/NavBar.css" />
    <style>
        :root { --red: #C0001D; --red-deep: #8B0015; --bg: #F7F7F5; --white: #FFFFFF; --border: #E5E5E0; --text: #1A1A1A; --muted: #6B6B65; --radius: 12px; }
        body { font-family: 'DM Sans', sans-serif; background: var(--bg); margin: 0; }
        .statement-container { max-width: 1000px; margin: 2rem auto; padding: 0 1rem; }
        .statement-card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--border); padding: 2rem; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
        .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 2rem; border-bottom: 2px solid var(--bg); padding-bottom: 1rem; }
        .amount { font-weight: bold; color: var(--red); }
        .btn-download { background: var(--black); color: white; padding: 0.8rem 1.5rem; border: none; border-radius: 8px; cursor: pointer; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <uc:NavBar ID="ucNavBar" runat="server" />

        <div class="statement-container">
            <asp:Panel ID="pnlStatement" runat="server">
                <div class="statement-card">
                    <div class="info-grid">
                        <div>
                            <p><strong>Student Name:</strong> <asp:Label ID="lblStudentName" runat="server" /></p>
                            <p><strong>Student ID:</strong> <asp:Label ID="lblStudentId" runat="server" /></p>
                            <p><strong>Email:</strong> <asp:Label ID="lblEmail" runat="server" /></p>
                        </div>
                        <div style="text-align:right">
                            <p><strong>Statement ID:</strong> <asp:Label ID="lblStatementId" runat="server" /></p>
                            <p><strong>Date:</strong> <asp:Label ID="lblStatementDate" runat="server" /></p>
                        </div>
                    </div>

                    <h3>Course Enrollment</h3>
                    <asp:GridView ID="gvCourses" runat="server" AutoGenerateColumns="true" Width="100%" CssClass="table" />

                    <h3 style="margin-top:2rem">Payment History</h3>
                    <asp:GridView ID="gvPayments" runat="server" AutoGenerateColumns="true" Width="100%" CssClass="table" />

                    <div style="margin-top:2rem; text-align:right;">
                        <h3>Total Balance: RM <asp:Label ID="lblTotalBalance" runat="server" CssClass="amount" /></h3>
                        <asp:Button ID="btnDownloadPDF" runat="server" Text="Download PDF" CssClass="btn-download" OnClick="btnDownloadPDF_Click" />
                    </div>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlError" runat="server" Visible="false">
                <div class="statement-card">
                    <h2 style="color:var(--red)">Error</h2>
                    <asp:Label ID="lblError" runat="server" />
                </div>
            </asp:Panel>
        </div>
    </form>
</body>
</html>