<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.library.DBConnection" %>
<%
    List<Map<String, Object>> books = new ArrayList<>();
    List<Map<String, Object>> issuedBooks = new ArrayList<>();
    String dbError = null;

    try (Connection con = DBConnection.getConnection()) {
        if (con != null) {
            String bookSql = "SELECT BOOK_ID, BOOK_TITLE, AUTHOR_NAME, PUBLISHER_NAME, CATEGORY, "
                    + "EDITION, PUBLICATION_YEAR, PRICE, QUANTITY FROM BOOK ORDER BY BOOK_ID ASC";
            try (Statement st = con.createStatement(); ResultSet rs = st.executeQuery(bookSql)) {
                while (rs.next()) {
                    Map<String, Object> b = new HashMap<>();
                    b.put("bookId", rs.getInt("BOOK_ID"));
                    b.put("bookTitle", rs.getString("BOOK_TITLE"));
                    b.put("authorName", rs.getString("AUTHOR_NAME"));
                    b.put("publisherName", rs.getString("PUBLISHER_NAME"));
                    b.put("category", rs.getString("CATEGORY"));
                    b.put("edition", rs.getString("EDITION"));
                    b.put("publicationYear", rs.getObject("PUBLICATION_YEAR"));
                    b.put("price", rs.getObject("PRICE"));
                    b.put("quantity", rs.getInt("QUANTITY"));
                    books.add(b);
                }
            }

            String issueSql = "SELECT i.ISSUE_ID, i.BOOK_ID, b.BOOK_TITLE, i.STUDENT_NAME, i.ISSUE_DATE "
                    + "FROM BOOK_ISSUE i JOIN BOOK b ON i.BOOK_ID = b.BOOK_ID "
                    + "WHERE i.STATUS = 'ISSUED' ORDER BY i.ISSUE_ID DESC";
            try (Statement st = con.createStatement(); ResultSet rs = st.executeQuery(issueSql)) {
                while (rs.next()) {
                    Map<String, Object> issue = new HashMap<>();
                    issue.put("issueId", rs.getInt("ISSUE_ID"));
                    issue.put("bookId", rs.getInt("BOOK_ID"));
                    issue.put("bookTitle", rs.getString("BOOK_TITLE"));
                    issue.put("studentName", rs.getString("STUDENT_NAME"));
                    issue.put("issueDate", rs.getString("ISSUE_DATE"));
                    issuedBooks.add(issue);
                }
            }
        } else {
            dbError = "Database connection failed.";
        }
    } catch (Exception e) {
        dbError = e.getMessage();
    }

    String msg = request.getParameter("msg");
    String err = request.getParameter("error");
    if (dbError != null) {
        err = dbError;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Library Management System</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f6f9;
            color: #333;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 1100px;
            margin: 0 auto;
        }
        .header {
            background: #fff;
            padding: 20px;
            border-radius: 4px;
            border: 1px solid #ddd;
            margin-bottom: 20px;
        }
        .header h2 {
            margin: 0 0 5px 0;
            color: #2c3e50;
        }
        .header p {
            margin: 0;
            color: #7f8c8d;
            font-size: 14px;
        }
        .msg-box {
            padding: 12px 15px;
            margin-bottom: 20px;
            border-radius: 4px;
            font-size: 14px;
        }
        .msg-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .msg-error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .actions-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin-bottom: 25px;
        }
        .action-box {
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 18px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        .action-box h3 {
            margin: 0 0 8px 0;
            font-size: 16px;
            color: #34495e;
        }
        .action-box p {
            margin: 0 0 15px 0;
            font-size: 13px;
            color: #7f8c8d;
            min-height: 36px;
        }
        .btn {
            background-color: #3498db;
            color: #fff;
            border: none;
            padding: 8px 14px;
            border-radius: 3px;
            cursor: pointer;
            font-size: 13px;
        }
        .btn:hover {
            background-color: #2980b9;
        }
        .btn-green {
            background-color: #27ae60;
        }
        .btn-green:hover {
            background-color: #219150;
        }
        .btn-secondary {
            background-color: #95a5a6;
        }
        .btn-secondary:hover {
            background-color: #7f8c8d;
        }
        .panel {
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 18px;
            margin-bottom: 20px;
        }
        .panel h3 {
            margin: 0 0 15px 0;
            font-size: 16px;
            color: #34495e;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }
        th, td {
            border: 1px solid #e0e0e0;
            padding: 9px 10px;
            text-align: left;
        }
        th {
            background-color: #f8f9fa;
            color: #555;
            font-weight: 600;
        }
        tr:nth-child(even) {
            background-color: #fafafa;
        }
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.4);
            z-index: 100;
            justify-content: center;
            align-items: center;
        }
        .modal-content {
            background: #fff;
            width: 480px;
            border-radius: 4px;
            border: 1px solid #ccc;
            padding: 20px;
        }
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
            margin-bottom: 15px;
        }
        .modal-header h4 {
            margin: 0;
            font-size: 16px;
        }
        .close-btn {
            background: none;
            border: none;
            font-size: 18px;
            cursor: pointer;
            color: #888;
        }
        .form-group {
            margin-bottom: 12px;
        }
        .form-group label {
            display: block;
            margin-bottom: 4px;
            font-size: 13px;
            font-weight: 600;
        }
        .form-group input, .form-group select {
            width: 100%;
            box-sizing: border-box;
            padding: 7px 9px;
            border: 1px solid #ccc;
            border-radius: 3px;
            font-size: 13px;
        }
        .form-row {
            display: flex;
            gap: 10px;
        }
        .form-row .form-group {
            flex: 1;
        }
        .modal-footer {
            margin-top: 15px;
            text-align: right;
            border-top: 1px solid #eee;
            padding-top: 12px;
        }
        .tab-btn {
            background: #eee;
            border: 1px solid #ccc;
            padding: 6px 12px;
            cursor: pointer;
            font-size: 13px;
        }
        .tab-btn.active {
            background: #3498db;
            color: #fff;
            border-color: #3498db;
        }
    </style>
</head>
<body>

<div class="container">

    <div class="header">
        <h2>Library Management System</h2>
        <p>Book Registration, Stock Management, and Lending</p>
    </div>

    <% if (msg != null) { %>
        <div class="msg-box msg-success"><%= msg %></div>
    <% } %>
    <% if (err != null) { %>
        <div class="msg-box msg-error"><%= err %></div>
    <% } %>

    <div class="actions-grid">
        <div class="action-box">
            <h3>1. Register Book</h3>
            <p>Add a new book entry to the library catalog.</p>
            <button class="btn" onclick="openModal('registerModal')">Open Form</button>
        </div>

        <div class="action-box">
            <h3>2. Add Stock</h3>
            <p>Increase available stock quantity for an existing book.</p>
            <button class="btn btn-green" onclick="openModal('stockModal')">Add Stock</button>
        </div>

        <div class="action-box">
            <h3>3. Lend / Return Book</h3>
            <p>Issue a book to a student or process a returned book.</p>
            <button class="btn" onclick="openModal('lendModal')">Manage Lending</button>
        </div>
    </div>

    <div class="panel">
        <h3>Registered Books (<%= books.size() %>)</h3>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Title</th>
                    <th>Author</th>
                    <th>Publisher</th>
                    <th>Category</th>
                    <th>Edition</th>
                    <th>Year</th>
                    <th>Price</th>
                    <th>Quantity</th>
                </tr>
            </thead>
            <tbody>
                <% if (!books.isEmpty()) { 
                    for (Map<String, Object> b : books) { %>
                    <tr>
                        <td><%= b.get("bookId") %></td>
                        <td><%= b.get("bookTitle") %></td>
                        <td><%= b.get("authorName") != null ? b.get("authorName") : "-" %></td>
                        <td><%= b.get("publisherName") != null ? b.get("publisherName") : "-" %></td>
                        <td><%= b.get("category") != null ? b.get("category") : "-" %></td>
                        <td><%= b.get("edition") != null ? b.get("edition") : "-" %></td>
                        <td><%= b.get("publicationYear") != null ? b.get("publicationYear") : "-" %></td>
                        <td><%= b.get("price") != null ? b.get("price") : "-" %></td>
                        <td><strong><%= b.get("quantity") %></strong></td>
                    </tr>
                <% } 
                } else { %>
                    <tr>
                        <td colspan="9" style="text-align: center; color: #888;">No books registered yet.</td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    </div>

    <div class="panel">
        <h3>Currently Borrowed Books (<%= issuedBooks.size() %>)</h3>
        <table>
            <thead>
                <tr>
                    <th>Issue ID</th>
                    <th>Book ID</th>
                    <th>Book Title</th>
                    <th>Student Name</th>
                    <th>Date</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <% if (!issuedBooks.isEmpty()) { 
                    for (Map<String, Object> issue : issuedBooks) { %>
                    <tr>
                        <td><%= issue.get("issueId") %></td>
                        <td><%= issue.get("bookId") %></td>
                        <td><%= issue.get("bookTitle") %></td>
                        <td><%= issue.get("studentName") %></td>
                        <td><%= issue.get("issueDate") %></td>
                        <td>
                            <form action="ManagementServlet" method="post" style="margin:0;">
                                <input type="hidden" name="action" value="return">
                                <input type="hidden" name="issueId" value="<%= issue.get("issueId") %>">
                                <button type="submit" class="btn btn-green" style="padding: 4px 8px; font-size: 12px;">Return</button>
                            </form>
                        </td>
                    </tr>
                <% } 
                } else { %>
                    <tr>
                        <td colspan="6" style="text-align: center; color: #888;">No books currently borrowed.</td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    </div>

</div>

<!-- Register Modal -->
<div class="modal" id="registerModal">
    <div class="modal-content">
        <div class="modal-header">
            <h4>Register Book</h4>
            <button class="close-btn" onclick="closeModal('registerModal')">&times;</button>
        </div>
        <form action="RegisterServlet" method="post">
            <div class="form-row">
                <div class="form-group">
                    <label>Book ID</label>
                    <input type="number" name="bookId" required>
                </div>
                <div class="form-group">
                    <label>Quantity</label>
                    <input type="number" name="quantity" required>
                </div>
            </div>
            <div class="form-group">
                <label>Book Title</label>
                <input type="text" name="bookTitle" required>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Author Name</label>
                    <input type="text" name="authorName">
                </div>
                <div class="form-group">
                    <label>Publisher Name</label>
                    <input type="text" name="publisherName">
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Category</label>
                    <select name="category">
                        <option value="">Select</option>
                        <option value="Computer Science">Computer Science</option>
                        <option value="Mathematics">Mathematics</option>
                        <option value="Science">Science</option>
                        <option value="Literature">Literature</option>
                        <option value="History">History</option>
                        <option value="Others">Others</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Edition</label>
                    <input type="text" name="edition">
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Publication Year</label>
                    <input type="number" name="publicationYear">
                </div>
                <div class="form-group">
                    <label>Price</label>
                    <input type="number" name="price" step="0.01">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeModal('registerModal')">Cancel</button>
                <button type="submit" class="btn">Register</button>
            </div>
        </form>
    </div>
</div>

<!-- Stock Modal -->
<div class="modal" id="stockModal">
    <div class="modal-content">
        <div class="modal-header">
            <h4>Add Stock</h4>
            <button class="close-btn" onclick="closeModal('stockModal')">&times;</button>
        </div>
        <form action="ManagementServlet" method="post">
            <input type="hidden" name="action" value="addStock">
            <div class="form-group">
                <label>Select Book</label>
                <select name="bookId" required>
                    <option value="">-- Select Book --</option>
                    <% for (Map<String, Object> b : books) { %>
                        <option value="<%= b.get("bookId") %>">
                            #<%= b.get("bookId") %> - <%= b.get("bookTitle") %> (Current: <%= b.get("quantity") %>)
                        </option>
                    <% } %>
                </select>
            </div>
            <div class="form-group">
                <label>Quantity to Add</label>
                <input type="number" name="quantity" min="1" required>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeModal('stockModal')">Cancel</button>
                <button type="submit" class="btn btn-green">Update</button>
            </div>
        </form>
    </div>
</div>

<!-- Lend/Return Modal -->
<div class="modal" id="lendModal">
    <div class="modal-content">
        <div class="modal-header">
            <h4>Lend / Return Book</h4>
            <button class="close-btn" onclick="closeModal('lendModal')">&times;</button>
        </div>

        <div style="margin-bottom: 15px;">
            <button type="button" class="tab-btn active" id="btnTabLend" onclick="setTab('lend')">Lend Book</button>
            <button type="button" class="tab-btn" id="btnTabReturn" onclick="setTab('return')">Return Book</button>
        </div>

        <div id="tabLend">
            <form action="ManagementServlet" method="post">
                <input type="hidden" name="action" value="lend">
                <div class="form-group">
                    <label>Select Book</label>
                    <select name="bookId" required>
                        <option value="">-- Select Book --</option>
                        <% for (Map<String, Object> b : books) { 
                            int q = (Integer) b.get("quantity");
                        %>
                            <option value="<%= b.get("bookId") %>" <%= q <= 0 ? "disabled" : "" %>>
                                #<%= b.get("bookId") %> - <%= b.get("bookTitle") %> (<%= q %> available)
                            </option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label>Student Name</label>
                    <input type="text" name="studentName" required>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closeModal('lendModal')">Cancel</button>
                    <button type="submit" class="btn">Lend Book</button>
                </div>
            </form>
        </div>

        <div id="tabReturn" style="display: none;">
            <form action="ManagementServlet" method="post">
                <input type="hidden" name="action" value="return">
                <div class="form-group">
                    <label>Select Borrowed Record</label>
                    <select name="issueId" required>
                        <option value="">-- Select Record --</option>
                        <% for (Map<String, Object> issue : issuedBooks) { %>
                            <option value="<%= issue.get("issueId") %>">
                                #<%= issue.get("issueId") %>: <%= issue.get("bookTitle") %> (<%= issue.get("studentName") %>)
                            </option>
                        <% } %>
                    </select>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closeModal('lendModal')">Cancel</button>
                    <button type="submit" class="btn btn-green">Return Book</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function openModal(id) {
    document.getElementById(id).style.display = 'flex';
}
function closeModal(id) {
    document.getElementById(id).style.display = 'none';
}
function setTab(tab) {
    if (tab === 'lend') {
        document.getElementById('tabLend').style.display = 'block';
        document.getElementById('tabReturn').style.display = 'none';
        document.getElementById('btnTabLend').className = 'tab-btn active';
        document.getElementById('btnTabReturn').className = 'tab-btn';
    } else {
        document.getElementById('tabLend').style.display = 'none';
        document.getElementById('tabReturn').style.display = 'block';
        document.getElementById('btnTabLend').className = 'tab-btn';
        document.getElementById('btnTabReturn').className = 'tab-btn active';
    }
}
</script>

</body>
</html>
