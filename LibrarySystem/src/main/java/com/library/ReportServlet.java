package com.library;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/reports/*")
public class ReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check if user is admin
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"ADMIN".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        String pathInfo = request.getPathInfo();
        
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                showReportDashboard(request, response);
            } else {
                switch (pathInfo) {
                    case "/overdue" -> showOverdueBooks(request, response);
                    case "/users" -> showAllUsers(request, response);
                    case "/popular-authors" -> showPopularAuthors(request, response);
                    case "/popular-categories" -> showPopularCategories(request, response);
                    default -> response.sendError(HttpServletResponse.SC_NOT_FOUND);
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }

    private void showReportDashboard(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        
        Map<String, Integer> stats = new HashMap<>();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            // Total books
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as count FROM books")) {
                if (rs.next()) {
                    stats.put("totalBooks", rs.getInt("count"));
                }
            }
            
            // Total registered users (instead of members)
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as count FROM users WHERE role = 'USER'")) {
                if (rs.next()) {
                    stats.put("totalMembers", rs.getInt("count"));
                }
            }
            
            // Active loans
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as count FROM loans WHERE status = 'APPROVED' AND returned = FALSE")) {
                if (rs.next()) {
                    stats.put("activeLoans", rs.getInt("count"));
                }
            }
            
            // Overdue books
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as count FROM loans WHERE status = 'APPROVED' AND returned = FALSE AND due_date < CURDATE()")) {
                if (rs.next()) {
                    stats.put("overdueBooks", rs.getInt("count"));
                }
            }
        }
        
        request.setAttribute("stats", stats);
        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }

    private void showOverdueBooks(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        
        List<Map<String, Object>> overdueBooks = new ArrayList<>();
        
        String sql = "SELECT l.id as loan_id, b.title as book_title, b.author, " +
                    "u.full_name as member_name, u.email as member_email, " +
                    "l.loan_date, l.due_date, " +
                    "DATEDIFF(CURDATE(), l.due_date) as days_overdue " +
                    "FROM loans l " +
                    "JOIN books b ON l.book_id = b.id " +
                    "JOIN users u ON l.member_id = u.id " +
                    "WHERE l.status = 'APPROVED' AND l.returned = FALSE AND l.due_date < CURDATE() " +
                    "ORDER BY days_overdue DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Map<String, Object> book = new HashMap<>();
                book.put("loanId", rs.getInt("loan_id"));
                book.put("bookTitle", rs.getString("book_title"));
                book.put("author", rs.getString("author"));
                book.put("memberName", rs.getString("member_name"));
                book.put("memberEmail", rs.getString("member_email"));
                book.put("loanDate", rs.getDate("loan_date"));
                book.put("dueDate", rs.getDate("due_date"));
                book.put("daysOverdue", rs.getInt("days_overdue"));
                overdueBooks.add(book);
            }
        }
        
        request.setAttribute("overdueBooks", overdueBooks);
        request.getRequestDispatcher("/overdue.jsp").forward(request, response);
    }

    private void showAllUsers(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        
        List<Map<String, Object>> users = new ArrayList<>();
        
        String sql = "SELECT u.id, u.username, u.email, u.full_name, u.role, u.created_at, " +
                    "COUNT(l.id) as total_loans, " +
                    "COUNT(CASE WHEN l.status = 'APPROVED' AND l.returned = FALSE THEN 1 END) as active_loans " +
                    "FROM users u " +
                    "LEFT JOIN loans l ON u.id = l.member_id " +
                    "GROUP BY u.id, u.username, u.email, u.full_name, u.role, u.created_at " +
                    "ORDER BY u.created_at DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Map<String, Object> user = new HashMap<>();
                user.put("id", rs.getInt("id"));
                user.put("username", rs.getString("username"));
                user.put("email", rs.getString("email"));
                user.put("fullName", rs.getString("full_name"));
                user.put("role", rs.getString("role"));
                user.put("createdAt", rs.getTimestamp("created_at"));
                user.put("totalLoans", rs.getInt("total_loans"));
                user.put("activeLoans", rs.getInt("active_loans"));
                users.add(user);
            }
        }
        
        request.setAttribute("users", users);
        request.getRequestDispatcher("/users.jsp").forward(request, response);
    }

    private void showPopularAuthors(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        
        List<Map<String, Object>> authorStats = new ArrayList<>();
        
        String sql = "SELECT author, COUNT(*) as book_count, " +
                    "SUM(quantity - available_quantity) as times_borrowed " +
                    "FROM books " +
                    "GROUP BY author " +
                    "ORDER BY times_borrowed DESC, book_count DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Map<String, Object> stat = new HashMap<>();
                stat.put("author", rs.getString("author"));
                stat.put("bookCount", rs.getInt("book_count"));
                stat.put("timesBorrowed", rs.getInt("times_borrowed"));
                authorStats.add(stat);
            }
        }
        
        request.setAttribute("authorStats", authorStats);
        request.getRequestDispatcher("/popular-authors.jsp").forward(request, response);
    }

    private void showPopularCategories(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        
        List<Map<String, Object>> categoryStats = new ArrayList<>();
        
        String sql = "SELECT category, COUNT(*) as total_books, " +
                    "SUM(quantity) as total_copies, " +
                    "SUM(quantity - available_quantity) as copies_borrowed " +
                    "FROM books " +
                    "WHERE category IS NOT NULL " +
                    "GROUP BY category " +
                    "ORDER BY total_books DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Map<String, Object> stat = new HashMap<>();
                stat.put("category", rs.getString("category"));
                stat.put("totalBooks", rs.getInt("total_books"));
                stat.put("totalCopies", rs.getInt("total_copies"));
                stat.put("copiesBorrowed", rs.getInt("copies_borrowed"));
                categoryStats.add(stat);
            }
        }
        
        request.setAttribute("categoryStats", categoryStats);
        request.getRequestDispatcher("/popular-categories.jsp").forward(request, response);
    }
}