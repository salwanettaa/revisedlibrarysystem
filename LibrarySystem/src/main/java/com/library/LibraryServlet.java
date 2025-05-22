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
import java.util.List;

@WebServlet("/library/*")
public class LibraryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getPathInfo();
        if (action == null) action = "/";

        try {
            switch (action) {
                case "/books" -> listBooks(request, response);
                case "/searchBooks" -> searchBooks(request, response);
                case "/searchAvailableBooks" -> searchAvailableBooks(request, response);
                case "/loans" -> listLoans(request, response);
                default -> response.sendRedirect(request.getContextPath() + "/index.jsp");
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getPathInfo();

        try {
            switch (action) {
                case "/addBook" -> addBook(request, response);
                case "/editBook" -> editBook(request, response);
                case "/deleteBook" -> deleteBook(request, response);
                case "/updateStock" -> updateStock(request, response);
                case "/addLoan" -> addLoan(request, response);
                case "/requestReturn" -> requestReturn(request, response);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private void listBooks(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT * FROM books ORDER BY id DESC"; // Changed to show newest books first

        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Book book = new Book();
                book.setId(rs.getInt("id"));
                book.setTitle(rs.getString("title"));
                book.setAuthor(rs.getString("author"));
                book.setIsbn(rs.getString("isbn"));
                book.setCategory(rs.getString("category"));
                book.setQuantity(rs.getInt("quantity"));
                book.setAvailableQuantity(rs.getInt("available_quantity"));
                book.setAvailable(rs.getInt("available_quantity") > 0);
                books.add(book);
            }
        }

        request.setAttribute("books", books);
        request.getRequestDispatcher("/books.jsp").forward(request, response);
    }

    private void searchBooks(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        String searchQuery = request.getParameter("query");
        String searchType = request.getParameter("searchType");
        
        if (searchQuery == null || searchQuery.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/library/books");
            return;
        }

        List<Book> books = new ArrayList<>();
        String sql;
        
        if (null == searchType) {
            sql = "SELECT * FROM books WHERE title LIKE ? OR author LIKE ? OR isbn LIKE ? OR category LIKE ? ORDER BY id DESC";
        } else switch (searchType) {
            case "title":
                sql = "SELECT * FROM books WHERE title LIKE ? ORDER BY id DESC";
                break;
            case "author":
                sql = "SELECT * FROM books WHERE author LIKE ? ORDER BY id DESC";
                break;
            case "isbn":
                sql = "SELECT * FROM books WHERE isbn LIKE ? ORDER BY id DESC";
                break;
            case "category":
                sql = "SELECT * FROM books WHERE category LIKE ? ORDER BY id DESC";
                break;
            default:
                sql = "SELECT * FROM books WHERE title LIKE ? OR author LIKE ? OR isbn LIKE ? OR category LIKE ? ORDER BY id DESC";
                break;
        }

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            String searchPattern = "%" + searchQuery + "%";
            stmt.setString(1, searchPattern);
            
            if (searchType == null || "all".equals(searchType)) {
                stmt.setString(2, searchPattern);
                stmt.setString(3, searchPattern);
                stmt.setString(4, searchPattern);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Book book = new Book();
                    book.setId(rs.getInt("id"));
                    book.setTitle(rs.getString("title"));
                    book.setAuthor(rs.getString("author"));
                    book.setIsbn(rs.getString("isbn"));
                    book.setCategory(rs.getString("category"));
                    book.setQuantity(rs.getInt("quantity"));
                    book.setAvailableQuantity(rs.getInt("available_quantity"));
                    book.setAvailable(rs.getInt("available_quantity") > 0);
                    books.add(book);
                }
            }
        }

        request.setAttribute("books", books);
        request.setAttribute("searchQuery", searchQuery);
        request.setAttribute("searchType", searchType);
        request.getRequestDispatcher("/books.jsp").forward(request, response);
    }

    private void searchAvailableBooks(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        String searchQuery = request.getParameter("query");
        
        List<Book> books = new ArrayList<>();
        String sql = "SELECT * FROM books WHERE available_quantity > 0 AND " +
                    "(title LIKE ? OR author LIKE ? OR isbn LIKE ?) ORDER BY id DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            String searchPattern = "%" + searchQuery + "%";
            stmt.setString(1, searchPattern);
            stmt.setString(2, searchPattern);
            stmt.setString(3, searchPattern);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Book book = new Book();
                    book.setId(rs.getInt("id"));
                    book.setTitle(rs.getString("title"));
                    book.setAuthor(rs.getString("author"));
                    book.setIsbn(rs.getString("isbn"));
                    book.setCategory(rs.getString("category"));
                    book.setQuantity(rs.getInt("quantity"));
                    book.setAvailableQuantity(rs.getInt("available_quantity"));
                    book.setAvailable(true);
                    books.add(book);
                }
            }
        }

        // Return JSON response for AJAX
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < books.size(); i++) {
            Book book = books.get(i);
            if (i > 0) json.append(",");
            json.append("{\"id\":").append(book.getId())
                .append(",\"title\":\"").append(book.getTitle().replace("\"", "\\\""))
                .append("\",\"author\":\"").append(book.getAuthor().replace("\"", "\\\""))
                .append("\",\"available\":").append(book.getAvailableQuantity())
                .append("}");
        }
        json.append("]");
        
        response.getWriter().write(json.toString());
    }

    private void listLoans(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        List<Object[]> loans = new ArrayList<>();
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        boolean isAdmin = user != null && "ADMIN".equals(user.getRole());
        
        String sql;
        if (isAdmin) {
            // Admin sees all loans with member email information
            sql = "SELECT l.id, b.title, b.author, u.full_name, l.loan_date, l.due_date, " +
                  "l.returned, l.return_date, " +
                  "COALESCE(l.status, CASE WHEN l.returned THEN 'RETURNED' ELSE 'APPROVED' END) as status, " +
                  "u.email " +
                  "FROM loans l " +
                  "JOIN books b ON l.book_id = b.id " +
                  "JOIN users u ON l.member_id = u.id " +
                  "ORDER BY " +
                  "CASE " +
                  "  WHEN COALESCE(l.status, 'APPROVED') = 'PENDING' THEN 1 " +
                  "  WHEN COALESCE(l.status, 'APPROVED') = 'RETURN_REQUESTED' THEN 2 " +
                  "  WHEN COALESCE(l.status, 'APPROVED') = 'APPROVED' AND NOT l.returned THEN 3 " +
                  "  ELSE 4 " +
                  "END, l.loan_date DESC";
        } else {
            // User sees only their loans
            sql = "SELECT l.id, b.title, b.author, u.full_name, l.loan_date, l.due_date, " +
                  "l.returned, l.return_date, " +
                  "COALESCE(l.status, CASE WHEN l.returned THEN 'RETURNED' ELSE 'APPROVED' END) as status, " +
                  "u.email " +
                  "FROM loans l " +
                  "JOIN books b ON l.book_id = b.id " +
                  "JOIN users u ON l.member_id = u.id " +
                  "WHERE l.member_id = ? " +
                  "ORDER BY l.loan_date DESC";
        }

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            if (!isAdmin) {
                stmt.setInt(1, user.getId());
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Object[] loan = new Object[10]; // Increased to include email
                    loan[0] = rs.getInt("id");
                    loan[1] = rs.getString("title");
                    loan[2] = rs.getString("author");
                    loan[3] = rs.getString("full_name");
                    loan[4] = rs.getDate("loan_date");
                    loan[5] = rs.getDate("due_date");
                    loan[6] = rs.getBoolean("returned");
                    loan[7] = rs.getDate("return_date");
                    loan[8] = rs.getString("status");
                    loan[9] = rs.getString("email"); // Add email
                    loans.add(loan);
                }
            }
        }

        // Get available books for the form (for regular users)
        List<Book> availableBooks = new ArrayList<>();
        if (!isAdmin) {
            String bookSql = "SELECT * FROM books WHERE available_quantity > 0 ORDER BY id DESC LIMIT 10";
            try (Connection conn = DatabaseConnection.getConnection();
                 Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery(bookSql)) {

                while (rs.next()) {
                    Book book = new Book();
                    book.setId(rs.getInt("id"));
                    book.setTitle(rs.getString("title"));
                    book.setAuthor(rs.getString("author"));
                    availableBooks.add(book);
                }
            }
        }

        request.setAttribute("loans", loans);
        request.setAttribute("availableBooks", availableBooks);
        request.setAttribute("isAdmin", isAdmin);
        request.getRequestDispatcher("/loans.jsp").forward(request, response);
    }

    private void addBook(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        // Check if user is admin
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"ADMIN".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String title = request.getParameter("title");
        String author = request.getParameter("author");
        String isbn = request.getParameter("isbn");
        String category = request.getParameter("category");
        int quantity = Integer.parseInt(request.getParameter("quantity"));

        String sql = "INSERT INTO books (title, author, isbn, category, quantity, available_quantity, available) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, title);
            stmt.setString(2, author);
            stmt.setString(3, isbn);
            stmt.setString(4, category);
            stmt.setInt(5, quantity);
            stmt.setInt(6, quantity);
            stmt.setBoolean(7, quantity > 0);
            stmt.executeUpdate();
        }

        response.sendRedirect(request.getContextPath() + "/library/books");
    }

    private void editBook(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        // Check if user is admin
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"ADMIN".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int bookId = Integer.parseInt(request.getParameter("bookId"));
        String title = request.getParameter("title");
        String author = request.getParameter("author");
        String isbn = request.getParameter("isbn");
        String category = request.getParameter("category");

        String sql = "UPDATE books SET title = ?, author = ?, isbn = ?, category = ? WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, title);
            stmt.setString(2, author);
            stmt.setString(3, isbn);
            stmt.setString(4, category);
            stmt.setInt(5, bookId);
            stmt.executeUpdate();
        }

        response.sendRedirect(request.getContextPath() + "/library/books");
    }

    private void deleteBook(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        // Check if user is admin
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"ADMIN".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int id = Integer.parseInt(request.getParameter("id"));
        
        // Check if book has active loans
        String checkSql = "SELECT COUNT(*) as count FROM loans WHERE book_id = ? AND returned = false";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            
            checkStmt.setInt(1, id);
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next() && rs.getInt("count") > 0) {
                // Book has active loans, cannot delete
                response.sendRedirect(request.getContextPath() + "/library/books?error=active_loans");
                return;
            }
        }

        String sql = "DELETE FROM books WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            stmt.executeUpdate();
        }

        response.sendRedirect(request.getContextPath() + "/library/books");
    }

    private void updateStock(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        // Check if user is admin
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"ADMIN".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int bookId = Integer.parseInt(request.getParameter("bookId"));
        int newQuantity = Integer.parseInt(request.getParameter("quantity"));

        // First, get the current book info
        String selectSql = "SELECT * FROM books WHERE id = ?";
        int currentLoaned = 0;
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement selectStmt = conn.prepareStatement(selectSql)) {
            
            selectStmt.setInt(1, bookId);
            ResultSet rs = selectStmt.executeQuery();
            
            if (rs.next()) {
                int currentQuantity = rs.getInt("quantity");
                int currentAvailable = rs.getInt("available_quantity");
                currentLoaned = currentQuantity - currentAvailable;
            }
        }

        // Update the stock
        String updateSql = "UPDATE books SET quantity = ?, available_quantity = ?, available = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
            
            int newAvailable = newQuantity - currentLoaned;
            if (newAvailable < 0) newAvailable = 0;
            
            updateStmt.setInt(1, newQuantity);
            updateStmt.setInt(2, newAvailable);
            updateStmt.setBoolean(3, newAvailable > 0);
            updateStmt.setInt(4, bookId);
            updateStmt.executeUpdate();
        }

        response.sendRedirect(request.getContextPath() + "/library/books");
    }

    private void addLoan(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        
        // Validate bookId parameter
        String bookIdParam = request.getParameter("bookId");
        if (bookIdParam == null || bookIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/library/loans?error=missing_book_id");
            return;
        }
        
        int bookId;
        try {
            bookId = Integer.parseInt(bookIdParam.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/library/loans?error=invalid_book_id");
            return;
        }
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }
        
        int memberId = user.getId();
        int loanDays = 14; // Default loan period

        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            // Check if book exists and is available
            String checkSql = "SELECT title, available_quantity FROM books WHERE id = ?";
            int availableQuantity = 0;
            String bookTitle = "";
            
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setInt(1, bookId);
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next()) {
                    availableQuantity = rs.getInt("available_quantity");
                    bookTitle = rs.getString("title");
                } else {
                    conn.rollback();
                    response.sendRedirect(request.getContextPath() + "/library/loans?error=book_not_found");
                    return;
                }
            }

            if (availableQuantity <= 0) {
                conn.rollback();
                response.sendRedirect(request.getContextPath() + "/library/loans?error=book_not_available");
                return;
            }

            // Check if user already has an active loan for this book
            String checkExistingLoanSql = "SELECT COUNT(*) as count FROM loans WHERE book_id = ? AND member_id = ? AND status IN ('PENDING', 'APPROVED') AND returned = FALSE";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkExistingLoanSql)) {
                checkStmt.setInt(1, bookId);
                checkStmt.setInt(2, memberId);
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next() && rs.getInt("count") > 0) {
                    conn.rollback();
                    response.sendRedirect(request.getContextPath() + "/library/loans?error=already_borrowed");
                    return;
                }
            }

            // Add loan record with PENDING status and proper due date
            // Note: ID will be auto-generated, so we don't include it in the INSERT
            String sql = "INSERT INTO loans (book_id, member_id, loan_date, due_date, returned, status, admin_approval) " +
                        "VALUES (?, ?, CURDATE(), DATE_ADD(CURDATE(), INTERVAL ? DAY), FALSE, 'PENDING', 0)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, bookId);
                stmt.setInt(2, memberId);
                stmt.setInt(3, loanDays);
                int rowsInserted = stmt.executeUpdate();
                
                if (rowsInserted == 0) {
                    throw new SQLException("Failed to create loan record");
                }
            }

            // Temporarily reduce book availability
            String updateSql = "UPDATE books SET available_quantity = available_quantity - 1, available = (available_quantity - 1) > 0 WHERE id = ? AND available_quantity > 0";
            try (PreparedStatement stmt = conn.prepareStatement(updateSql)) {
                stmt.setInt(1, bookId);
                int rowsUpdated = stmt.executeUpdate();
                
                if (rowsUpdated == 0) {
                    throw new SQLException("Failed to update book availability");
                }
            }

            conn.commit();
            response.sendRedirect(request.getContextPath() + "/library/loans?success=loan_requested");
            
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            System.err.println("Error in addLoan: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/library/loans?error=database_error");
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private void requestReturn(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {
        
        // Validate loan ID parameter
        String loanIdParam = request.getParameter("loanId");
        if (loanIdParam == null || loanIdParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Loan ID is required");
            return;
        }
        
        int loanId;
        try {
            loanId = Integer.parseInt(loanIdParam.trim());
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid loan ID format");
            return;
        }
        
        // Validate user session
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Please log in");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Please log in");
            return;
        }
        
        // Database operation with proper error handling
        String sql = "UPDATE loans SET status = 'RETURN_REQUESTED' WHERE id = ? AND member_id = ? AND status = 'APPROVED' AND returned = FALSE";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, loanId);
            stmt.setInt(2, user.getId());
            
            int rowsUpdated = stmt.executeUpdate();
            
            if (rowsUpdated == 0) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Loan not found or not eligible for return request");
                return;
            }
            
        } catch (SQLException e) {
            throw new ServletException("Database operation failed", e);
        }
        
        response.sendRedirect(request.getContextPath() + "/library/loans");
    }
}