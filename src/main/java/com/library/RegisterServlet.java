package com.library;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "RegisterServlet", urlPatterns = "/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String bookIdStr = request.getParameter("bookId");
        String bookTitle = request.getParameter("bookTitle");
        String authorName = request.getParameter("authorName");
        String publisherName = request.getParameter("publisherName");
        String category = request.getParameter("category");
        String edition = request.getParameter("edition");
        String pubYearStr = request.getParameter("publicationYear");
        String priceStr = request.getParameter("price");
        String quantityStr = request.getParameter("quantity");

        int bookId = Integer.parseInt(bookIdStr);
        int quantity = Integer.parseInt(quantityStr);

        Integer pubYear = (pubYearStr != null && !pubYearStr.trim().isEmpty())
                ? Integer.parseInt(pubYearStr.trim()) : null;
        Double price = (priceStr != null && !priceStr.trim().isEmpty())
                ? Double.parseDouble(priceStr.trim()) : null;

        String sql = "INSERT INTO BOOK (BOOK_ID, BOOK_TITLE, AUTHOR_NAME, PUBLISHER_NAME, "
                + "CATEGORY, EDITION, PUBLICATION_YEAR, PRICE, QUANTITY) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                response.sendRedirect("index.jsp?error=" + URLEncoder.encode("Database connection failed", StandardCharsets.UTF_8));
                return;
            }

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, bookId);
                ps.setString(2, bookTitle);
                ps.setString(3, authorName);
                ps.setString(4, publisherName);
                ps.setString(5, category);
                ps.setString(6, edition);

                if (pubYear != null) {
                    ps.setInt(7, pubYear);
                } else {
                    ps.setNull(7, java.sql.Types.INTEGER);
                }

                if (price != null) {
                    ps.setDouble(8, price);
                } else {
                    ps.setNull(8, java.sql.Types.DOUBLE);
                }

                ps.setInt(9, quantity);
                ps.executeUpdate();
                response.sendRedirect("index.jsp?msg=" + URLEncoder.encode("Book registered successfully.", StandardCharsets.UTF_8));
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?error=" + URLEncoder.encode("Database error: " + e.getMessage(), StandardCharsets.UTF_8));
        } catch (NumberFormatException e) {
            response.sendRedirect("index.jsp?error=" + URLEncoder.encode("Invalid input format.", StandardCharsets.UTF_8));
        }
    }
}
