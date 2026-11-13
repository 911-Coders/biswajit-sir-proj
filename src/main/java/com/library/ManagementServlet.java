package com.library;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ManagementServlet", urlPatterns = "/ManagementServlet")
public class ManagementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            response.sendRedirect("index.jsp");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                response.sendRedirect("index.jsp?error=" + urlEncode("Database connection failed"));
                return;
            }

            if ("addStock".equals(action)) {
                int bookId = Integer.parseInt(request.getParameter("bookId"));
                int additionalQuantity = Integer.parseInt(request.getParameter("quantity"));

                String sql = "UPDATE BOOK SET QUANTITY = QUANTITY + ? WHERE BOOK_ID = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, additionalQuantity);
                    ps.setInt(2, bookId);
                    int rows = ps.executeUpdate();
                    if (rows > 0) {
                        response.sendRedirect("index.jsp?msg=" + urlEncode("Stock updated successfully."));
                    } else {
                        response.sendRedirect("index.jsp?error=" + urlEncode("Book ID not found."));
                    }
                }
            } else if ("lend".equals(action)) {
                int bookId = Integer.parseInt(request.getParameter("bookId"));
                String studentName = request.getParameter("studentName");

                String checkSql = "SELECT QUANTITY FROM BOOK WHERE BOOK_ID = ?";
                int currentStock = 0;
                try (PreparedStatement ps = con.prepareStatement(checkSql)) {
                    ps.setInt(1, bookId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            currentStock = rs.getInt("QUANTITY");
                        } else {
                            response.sendRedirect("index.jsp?error=" + urlEncode("Book not found."));
                            return;
                        }
                    }
                }

                if (currentStock <= 0) {
                    response.sendRedirect("index.jsp?error=" + urlEncode("Book is out of stock."));
                    return;
                }

                String updateSql = "UPDATE BOOK SET QUANTITY = QUANTITY - 1 WHERE BOOK_ID = ?";
                try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                    ps.setInt(1, bookId);
                    ps.executeUpdate();
                }

                String insertSql = "INSERT INTO BOOK_ISSUE (ISSUE_ID, BOOK_ID, STUDENT_NAME, ISSUE_DATE, STATUS) "
                        + "VALUES ((SELECT NVL(MAX(ISSUE_ID), 0) + 1 FROM BOOK_ISSUE), ?, ?, TO_CHAR(SYSDATE, 'YYYY-MM-DD'), 'ISSUED')";
                try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                    ps.setInt(1, bookId);
                    ps.setString(2, studentName);
                    ps.executeUpdate();
                }

                response.sendRedirect("index.jsp?msg=" + urlEncode("Book lent to " + studentName + "."));
            } else if ("return".equals(action)) {
                int issueId = Integer.parseInt(request.getParameter("issueId"));
                int bookId = -1;

                String findSql = "SELECT BOOK_ID FROM BOOK_ISSUE WHERE ISSUE_ID = ? AND STATUS = 'ISSUED'";
                try (PreparedStatement ps = con.prepareStatement(findSql)) {
                    ps.setInt(1, issueId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            bookId = rs.getInt("BOOK_ID");
                        } else {
                            response.sendRedirect("index.jsp?error=" + urlEncode("Issue record not found."));
                            return;
                        }
                    }
                }

                String updateIssueSql = "UPDATE BOOK_ISSUE SET STATUS = 'RETURNED' WHERE ISSUE_ID = ?";
                try (PreparedStatement ps = con.prepareStatement(updateIssueSql)) {
                    ps.setInt(1, issueId);
                    ps.executeUpdate();
                }

                String updateStockSql = "UPDATE BOOK SET QUANTITY = QUANTITY + 1 WHERE BOOK_ID = ?";
                try (PreparedStatement ps = con.prepareStatement(updateStockSql)) {
                    ps.setInt(1, bookId);
                    ps.executeUpdate();
                }

                response.sendRedirect("index.jsp?msg=" + urlEncode("Book returned successfully."));
            } else {
                response.sendRedirect("index.jsp");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?error=" + urlEncode("Database error: " + e.getMessage()));
        } catch (NumberFormatException e) {
            response.sendRedirect("index.jsp?error=" + urlEncode("Invalid numeric input."));
        }
    }

    private String urlEncode(String text) {
        return URLEncoder.encode(text, StandardCharsets.UTF_8);
    }
}
