package com.library;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;

@WebServlet("/admin/*")
public class LoanApprovalServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        // Check if user is admin
        if (user == null || !"ADMIN".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getPathInfo();
        
        try {
            switch (action) {
                case "/approveLoan":
                    approveLoan(request, response, user.getId());
                    break;
                case "/rejectLoan":
                    rejectLoan(request, response, user.getId());
                    break;
                case "/approveReturn":
                    approveReturn(request, response, user.getId());
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private void approveLoan(HttpServletRequest request, HttpServletResponse response, int adminId)
            throws SQLException, IOException {
        int loanId = Integer.parseInt(request.getParameter("loanId"));
        
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            // First ensure the loan has a proper due date
            String checkDueDateSql = "SELECT due_date, loan_date FROM loans WHERE id = ?";
            Date dueDate = null;
            Date loanDate = null;
            
            try (PreparedStatement checkStmt = conn.prepareStatement(checkDueDateSql)) {
                checkStmt.setInt(1, loanId);
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next()) {
                    dueDate = rs.getDate("due_date");
                    loanDate = rs.getDate("loan_date");
                }
            }

            // Update loan status and ensure due date is set
            String updateLoanSql;
            if (dueDate == null) {
                // Set due date if it's null
                updateLoanSql = "UPDATE loans SET status = 'APPROVED', admin_approval = 1, " +
                              "approved_by = ?, approval_date = NOW(), " +
                              "due_date = COALESCE(due_date, DATE_ADD(COALESCE(loan_date, CURDATE()), INTERVAL 14 DAY)) " +
                              "WHERE id = ?";
            } else {
                updateLoanSql = "UPDATE loans SET status = 'APPROVED', admin_approval = 1, " +
                              "approved_by = ?, approval_date = NOW() WHERE id = ?";
            }
            
            try (PreparedStatement stmt = conn.prepareStatement(updateLoanSql)) {
                stmt.setInt(1, adminId);
                stmt.setInt(2, loanId);
                stmt.executeUpdate();
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) conn.rollback();
            throw e;
        } finally {
            if (conn != null) conn.close();
        }

        response.sendRedirect(request.getContextPath() + "/library/loans");
    }

    private void rejectLoan(HttpServletRequest request, HttpServletResponse response, int adminId)
            throws SQLException, IOException {
        int loanId = Integer.parseInt(request.getParameter("loanId"));
        
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            // Get book ID first
            int bookId = 0;
            String selectSql = "SELECT book_id FROM loans WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(selectSql)) {
                stmt.setInt(1, loanId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    bookId = rs.getInt("book_id");
                }
            }

            // Update loan status to rejected
            String updateLoanSql = "UPDATE loans SET status = 'REJECTED', approved_by = ?, " +
                                  "approval_date = NOW() WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateLoanSql)) {
                stmt.setInt(1, adminId);
                stmt.setInt(2, loanId);
                stmt.executeUpdate();
            }

            // Return book stock
            String updateBookSql = "UPDATE books SET available_quantity = available_quantity + 1, " +
                                  "available = true WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateBookSql)) {
                stmt.setInt(1, bookId);
                stmt.executeUpdate();
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) conn.rollback();
            throw e;
        } finally {
            if (conn != null) conn.close();
        }

        response.sendRedirect(request.getContextPath() + "/library/loans");
    }

    private void approveReturn(HttpServletRequest request, HttpServletResponse response, int adminId)
            throws SQLException, IOException {
        int loanId = Integer.parseInt(request.getParameter("loanId"));
        
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            // Get book ID
            int bookId = 0;
            String selectSql = "SELECT book_id FROM loans WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(selectSql)) {
                stmt.setInt(1, loanId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    bookId = rs.getInt("book_id");
                }
            }

            // Update loan record
            String updateLoanSql = "UPDATE loans SET return_date = CURDATE(), returned = true, " +
                                  "status = 'RETURNED', approved_by = ?, approval_date = NOW() WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateLoanSql)) {
                stmt.setInt(1, adminId);
                stmt.setInt(2, loanId);
                stmt.executeUpdate();
            }

            // Update book availability
            String updateBookSql = "UPDATE books SET available_quantity = available_quantity + 1, " +
                                  "available = true WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateBookSql)) {
                stmt.setInt(1, bookId);
                stmt.executeUpdate();
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) conn.rollback();
            throw e;
        } finally {
            if (conn != null) conn.close();
        }

        response.sendRedirect(request.getContextPath() + "/library/loans");
    }
}