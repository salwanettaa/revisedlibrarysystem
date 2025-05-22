<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page import="com.library.User"%>
<%
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    User user = (User) session.getAttribute("user");
    boolean showLogin = (isLoggedIn == null || !isLoggedIn || user == null);
    boolean isAdmin = user != null && "ADMIN".equals(user.getRole());
%>
<!DOCTYPE html>
<html>
<head>
    <title>Books - Library Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/">Library System</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">
                <li class="nav-item">
                    <a class="nav-link active" href="${pageContext.request.contextPath}/library/books">Books</a>
                </li>
                <% if (!showLogin) { %>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/library/loans">My Loans</a>
                </li>
                <% } else { %>
                <li class="nav-item">
                    <a class="nav-link" href="#" onclick="showLoginRequiredAlert()">My Loans</a>
                </li>
                <% } %>
                <% if (isAdmin) { %>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/reports">Reports</a>
                </li>
                <% } %>
            </ul>
            <ul class="navbar-nav">
                <% if (showLogin) { %>
                    <li class="nav-item">
                        <a class="btn btn-outline-light me-2" href="${pageContext.request.contextPath}/auth/login">Login</a>
                    </li>
                    <li class="nav-item">
                        <a class="btn btn-light" href="${pageContext.request.contextPath}/auth/register">Register</a>
                    </li>
                <% } else { %>
                    <li class="nav-item">
                        <span class="nav-link">Welcome, ${sessionScope.user.fullName}</span>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/auth/logout">Logout</a>
                    </li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>

    <div class="container mt-4">
        <h2>Books Catalog</h2>
        
        <!-- Error messages -->
        <c:if test="${param.error == 'active_loans'}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle-fill"></i>
                Cannot delete book: There are active loans for this book.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        
        <!-- Search Form -->
        <div class="card mb-4">
            <div class="card-header">
                <i class="bi bi-search"></i> Search Books
            </div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/library/searchBooks" method="get" class="row g-3">
                    <div class="col-md-6">
                        <input type="text" name="query" class="form-control" placeholder="Search..." value="${searchQuery}">
                    </div>
                    <div class="col-md-4">
                        <select name="searchType" class="form-control">
                            <option value="all" ${searchType == 'all' ? 'selected' : ''}>All Fields</option>
                            <option value="title" ${searchType == 'title' ? 'selected' : ''}>Title</option>
                            <option value="author" ${searchType == 'author' ? 'selected' : ''}>Author</option>
                            <option value="isbn" ${searchType == 'isbn' ? 'selected' : ''}>ISBN</option>
                            <option value="category" ${searchType == 'category' ? 'selected' : ''}>Category</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-search"></i> Search
                        </button>
                    </div>
                </form>
            </div>
        </div>
        
        <!-- Add Book Form (ADMIN ONLY) -->
        <% if (isAdmin) { %>
        <div class="card mb-4">
            <div class="card-header">
                <i class="bi bi-plus-circle"></i> Add New Book
            </div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/library/addBook" method="post">
                    <div class="row">
                        <div class="col-md-3">
                            <input type="text" name="title" class="form-control" placeholder="Title" required>
                        </div>
                        <div class="col-md-2">
                            <input type="text" name="author" class="form-control" placeholder="Author" required>
                        </div>
                        <div class="col-md-2">
                            <input type="text" name="isbn" class="form-control" placeholder="ISBN" required>
                        </div>
                        <div class="col-md-2">
                            <select name="category" class="form-control" required>
                                <option value="">Select Category</option>
                                <option value="Fiction">Fiction</option>
                                <option value="Non-Fiction">Non-Fiction</option>
                                <option value="Science">Science</option>
                                <option value="Technology">Technology</option>
                                <option value="History">History</option>
                                <option value="Biography">Biography</option>
                                <option value="Literature">Literature</option>
                                <option value="Education">Education</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                        <div class="col-md-1">
                            <input type="number" name="quantity" class="form-control" placeholder="Qty" min="1" required>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-primary">
                                <i class="bi bi-plus-circle"></i> Add Book
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        <% } %>

        <!-- Books Table -->
        <div class="card">
            <div class="card-header">
                <i class="bi bi-book"></i> Book List
                <small class="text-muted ms-2">
                    <i class="bi bi-sort-down"></i> Showing newest books first
                </small>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Author</th>
                                <th>ISBN</th>
                                <th>Category</th>
                                <% if (isAdmin) { %>
                                <th>Total Stock</th>
                                <% } %>
                                <th>Available</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${books}" var="book">
                                <tr>
                                    <td>
                                        <strong>${book.title}</strong>
                                        <c:if test="${book.id > (books.size() > 5 ? books.get(4).id : 0)}">
                                            <span class="badge bg-success ms-1">
                                                <i class="bi bi-star-fill"></i> NEW
                                            </span>
                                        </c:if>
                                    </td>
                                    <td>${book.author}</td>
                                    <td><small class="text-muted">${book.isbn}</small></td>
                                    <td>
                                        <span class="badge bg-secondary">${book.category}</span>
                                    </td>
                                    <% if (isAdmin) { %>
                                    <td>
                                        <span class="badge bg-info">${book.quantity}</span>
                                    </td>
                                    <% } %>
                                    <td>
                                        <span class="badge bg-primary">${book.availableQuantity}</span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${book.availableQuantity > 0}">
                                                <span class="badge bg-success">
                                                    <i class="bi bi-check-circle"></i> Available
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-danger">
                                                    <i class="bi bi-x-circle"></i> Out of Stock
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="btn-group-vertical btn-group-sm" role="group">
                                            <% if (showLogin) { %>
                                                <!-- PUBLIC USER: Show login required for borrowing -->
                                                <c:if test="${book.availableQuantity > 0}">
                                                    <button class="btn btn-success btn-sm" onclick="showLoginRequiredModal()">
                                                        <i class="bi bi-download"></i> Borrow
                                                    </button>
                                                </c:if>
                                            <% } else if (!isAdmin) { %>
                                                <!-- LOGGED IN USER: Can borrow -->
                                                <c:if test="${book.availableQuantity > 0}">
                                                    <form action="${pageContext.request.contextPath}/library/addLoan" method="post" style="display:inline;">
                                                        <input type="hidden" name="bookId" value="${book.id}">
                                                        <button type="submit" class="btn btn-success btn-sm">
                                                            <i class="bi bi-download"></i> Borrow
                                                        </button>
                                                    </form>
                                                </c:if>
                                            <% } %>
                                            
                                            <% if (isAdmin) { %>
                                                <!-- ADMIN: Full controls -->
                                                <button type="button" class="btn btn-warning btn-sm" 
                                                        onclick="showEditBookModal('${book.id}', '${book.title}', '${book.author}', '${book.isbn}', '${book.category}')">
                                                    <i class="bi bi-pencil"></i> Edit
                                                </button>
                                                
                                                <button type="button" class="btn btn-info btn-sm" 
                                                        onclick="showUpdateStockModal(${book.id}, ${book.quantity})">
                                                    <i class="bi bi-box"></i> Update Stock
                                                </button>
                                                
                                                <form action="${pageContext.request.contextPath}/library/deleteBook" method="post" style="display:inline;">
                                                    <input type="hidden" name="id" value="${book.id}">
                                                    <button type="submit" class="btn btn-danger btn-sm" 
                                                            onclick="return confirm('Are you sure you want to delete this book? This action cannot be undone.')">
                                                        <i class="bi bi-trash"></i> Delete
                                                    </button>
                                                </form>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty books}">
                                <tr>
                                    <td colspan="<% if (isAdmin) { %>8<% } else { %>7<% } %>" class="text-center text-muted">
                                        <i class="bi bi-inbox"></i> No books found.
                                        <% if (isAdmin) { %>
                                            <br><small>Add some books using the form above.</small>
                                        <% } %>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Login Required Modal -->
    <div class="modal fade" id="loginRequiredModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="bi bi-lock"></i> Login Required
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p><i class="bi bi-info-circle"></i> Please login to borrow books and access your loan history.</p>
                    <form action="${pageContext.request.contextPath}/auth/login" method="post">
                        <div class="mb-3">
                            <label for="username" class="form-label">Username</label>
                            <input type="text" class="form-control" id="username" name="username" required>
                        </div>
                        <div class="mb-3">
                            <label for="password" class="form-label">Password</label>
                            <input type="password" class="form-control" id="password" name="password" required>
                        </div>
                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-primary">
                                <i class="bi bi-box-arrow-in-right"></i> Login
                            </button>
                            <a href="${pageContext.request.contextPath}/auth/register" class="btn btn-outline-secondary">
                                <i class="bi bi-person-plus"></i> Create Account
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Edit Book Modal (ADMIN ONLY) -->
    <% if (isAdmin) { %>
    <div class="modal fade" id="editBookModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="bi bi-pencil"></i> Edit Book
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="${pageContext.request.contextPath}/library/editBook" method="post">
                    <div class="modal-body">
                        <input type="hidden" name="bookId" id="editBookId">
                        <div class="mb-3">
                            <label for="editTitle" class="form-label">Title</label>
                            <input type="text" class="form-control" id="editTitle" name="title" required>
                        </div>
                        <div class="mb-3">
                            <label for="editAuthor" class="form-label">Author</label>
                            <input type="text" class="form-control" id="editAuthor" name="author" required>
                        </div>
                        <div class="mb-3">
                            <label for="editIsbn" class="form-label">ISBN</label>
                            <input type="text" class="form-control" id="editIsbn" name="isbn" required>
                        </div>
                        <div class="mb-3">
                            <label for="editCategory" class="form-label">Category</label>
                            <select class="form-control" id="editCategory" name="category" required>
                                <option value="">Select Category</option>
                                <option value="Fiction">Fiction</option>
                                <option value="Non-Fiction">Non-Fiction</option>
                                <option value="Science">Science</option>
                                <option value="Technology">Technology</option>
                                <option value="History">History</option>
                                <option value="Biography">Biography</option>
                                <option value="Literature">Literature</option>
                                <option value="Education">Education</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="bi bi-x"></i> Cancel
                        </button>
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-check"></i> Save Changes
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Update Stock Modal (ADMIN ONLY) -->
    <div class="modal fade" id="updateStockModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="bi bi-box"></i> Update Stock
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="${pageContext.request.contextPath}/library/updateStock" method="post">
                    <div class="modal-body">
                        <input type="hidden" name="bookId" id="updateBookId">
                        <div class="mb-3">
                            <label for="updateQuantity" class="form-label">New Quantity</label>
                            <input type="number" class="form-control" id="updateQuantity" name="quantity" min="0" required>
                            <div class="form-text">
                                <i class="bi bi-info-circle"></i> 
                                Current loans will be maintained. Available quantity will be adjusted accordingly.
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="bi bi-x"></i> Cancel
                        </button>
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-check"></i> Update
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <% } %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function showLoginRequiredModal() {
            new bootstrap.Modal(document.getElementById('loginRequiredModal')).show();
        }
        
        function showLoginRequiredAlert() {
            alert('Please login to access your loans!');
            window.location.href = '${pageContext.request.contextPath}/auth/login';
        }
        
        <% if (isAdmin) { %>
        function showEditBookModal(bookId, title, author, isbn, category) {
            document.getElementById('editBookId').value = bookId;
            document.getElementById('editTitle').value = title;
            document.getElementById('editAuthor').value = author;
            document.getElementById('editIsbn').value = isbn;
            document.getElementById('editCategory').value = category;
            new bootstrap.Modal(document.getElementById('editBookModal')).show();
        }
        
        function showUpdateStockModal(bookId, currentQuantity) {
            document.getElementById('updateBookId').value = bookId;
            document.getElementById('updateQuantity').value = currentQuantity;
            new bootstrap.Modal(document.getElementById('updateStockModal')).show();
        }
        <% } %>
    </script>
</body>
</html>