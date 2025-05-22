<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@page import="com.library.User"%>
<%
    User user = (User) session.getAttribute("user");
    boolean isAdmin = user != null && "ADMIN".equals(user.getRole());
%>
<!DOCTYPE html>
<html>
<head>
    <title>Loans - Library Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
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
                    <a class="nav-link" href="${pageContext.request.contextPath}/library/books">Books</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link active" href="${pageContext.request.contextPath}/library/loans">
                        <% if (isAdmin) { %>Loan Management<% } else { %>My Loans<% } %>
                    </a>
                </li>
                <% if (isAdmin) { %>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/reports">Reports</a>
                </li>
                <% } %>
            </ul>
            <ul class="navbar-nav">
                <li class="nav-item">
                    <span class="nav-link">Welcome, ${sessionScope.user.fullName}<% if (isAdmin) { %> (Admin)<% } %></span>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/auth/logout">Logout</a>
                </li>
            </ul>
        </div>
    </div>
</nav>

    <div class="container mt-4">
        <h2><% if (isAdmin) { %>Loan Requests Management<% } else { %>My Loans<% } %></h2>
        
        <!-- Create New Loan Form (For Users Only) -->
        <% if (!isAdmin) { %>
        <div class="card mb-4">
            <div class="card-header">
                <i class="bi bi-plus-circle"></i> Borrow a Book
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-8">
                        <input type="text" id="bookSearch" class="form-control" placeholder="Search for books by title, author, or ISBN...">
                        <div id="bookSearchResults" class="mt-2"></div>
                    </div>
                </div>
            </div>
        </div>
        <% } %>

        <!-- Admin Summary Cards -->
        <% if (isAdmin) { %>
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card text-white bg-warning">
                    <div class="card-body text-center">
                        <h5>Pending Requests</h5>
                        <h3>
                            <c:set var="pendingCount" value="0" />
                            <c:forEach items="${loans}" var="loan">
                                <c:if test="${loan[8] == 'PENDING'}">
                                    <c:set var="pendingCount" value="${pendingCount + 1}" />
                                </c:if>
                            </c:forEach>
                            ${pendingCount}
                        </h3>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-white bg-info">
                    <div class="card-body text-center">
                        <h5>Active Loans</h5>
                        <h3>
                            <c:set var="activeCount" value="0" />
                            <c:forEach items="${loans}" var="loan">
                                <c:if test="${loan[8] == 'APPROVED' && !loan[6]}">
                                    <c:set var="activeCount" value="${activeCount + 1}" />
                                </c:if>
                            </c:forEach>
                            ${activeCount}
                        </h3>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-white bg-secondary">
                    <div class="card-body text-center">
                        <h5>Return Requests</h5>
                        <h3>
                            <c:set var="returnCount" value="0" />
                            <c:forEach items="${loans}" var="loan">
                                <c:if test="${loan[8] == 'RETURN_REQUESTED'}">
                                    <c:set var="returnCount" value="${returnCount + 1}" />
                                </c:if>
                            </c:forEach>
                            ${returnCount}
                        </h3>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-white bg-success">
                    <div class="card-body text-center">
                        <h5>Completed</h5>
                        <h3>
                            <c:set var="completedCount" value="0" />
                            <c:forEach items="${loans}" var="loan">
                                <c:if test="${loan[8] == 'RETURNED' || loan[6]}">
                                    <c:set var="completedCount" value="${completedCount + 1}" />
                                </c:if>
                            </c:forEach>
                            ${completedCount}
                        </h3>
                    </div>
                </div>
            </div>
        </div>
        <% } %>

        <!-- Loans Table -->
        <div class="card">
            <div class="card-header">
                <% if (isAdmin) { %>
                    <i class="bi bi-list-check"></i> All Loan Requests & Returns
                <% } else { %>
                    <i class="bi bi-book"></i> My Loan History
                <% } %>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Book</th>
                                <th>Author</th>
                                <% if (isAdmin) { %>
                                <th>Member</th>
                                <th>Email</th>
                                <% } %>
                                <th>Request Date</th>
                                <th>Due Date</th>
                                <th>Return Date</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${loans}" var="loan">
                                <tr>
                                    <td>#${loan[0]}</td>
                                    <td><strong>${loan[1]}</strong></td>
                                    <td>${loan[2]}</td>
                                    <% if (isAdmin) { %>
                                    <td><strong>${loan[3]}</strong></td>
                                    <td>
                                        <small class="text-muted">
                                            <c:choose>
                                                <c:when test="${not empty loan[9]}">
                                                    ${loan[9]}
                                                </c:when>
                                                <c:otherwise>
                                                    No email
                                                </c:otherwise>
                                            </c:choose>
                                        </small>
                                    </td>
                                    <% } %>
                                    <td>
                                        <fmt:formatDate value="${loan[4]}" pattern="yyyy-MM-dd"/>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${loan[5] != null}">
                                                <fmt:formatDate value="${loan[5]}" pattern="yyyy-MM-dd"/>
                                                <c:if test="${loan[5] < java.sql.Date.valueOf(java.time.LocalDate.now()) && loan[8] == 'APPROVED' && !loan[6]}">
                                                    <br><small class="text-danger"><strong>OVERDUE</strong></small>
                                                </c:if>
                                            </c:when>
                                            <c:otherwise>
                                                <small class="text-muted">Not set</small>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:if test="${loan[7] != null}">
                                            <fmt:formatDate value="${loan[7]}" pattern="yyyy-MM-dd"/>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${loan[8] == 'PENDING'}">
                                                <span class="badge bg-warning text-dark">Pending Approval</span>
                                            </c:when>
                                            <c:when test="${loan[8] == 'APPROVED'}">
                                                <c:choose>
                                                    <c:when test="${loan[6]}">
                                                        <span class="badge bg-success">Returned</span>
                                                    </c:when>
                                                    <c:when test="${loan[5] < java.sql.Date.valueOf(java.time.LocalDate.now())}">
                                                        <span class="badge bg-danger">Overdue</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-info">Active Loan</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:when test="${loan[8] == 'REJECTED'}">
                                                <span class="badge bg-danger">Rejected</span>
                                            </c:when>
                                            <c:when test="${loan[8] == 'RETURN_REQUESTED'}">
                                                <span class="badge bg-secondary">Return Requested</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-success">Completed</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <% if (isAdmin) { %>
                                            <!-- ADMIN ACTIONS -->
                                            <div class="btn-group-vertical btn-group-sm" role="group">
                                                <c:if test="${loan[8] == 'PENDING'}">
                                                    <form action="${pageContext.request.contextPath}/admin/approveLoan" method="post" style="display:inline;">
                                                        <input type="hidden" name="loanId" value="${loan[0]}">
                                                        <button type="submit" class="btn btn-success btn-sm" title="Approve Loan">
                                                            <i class="bi bi-check-circle"></i> Approve
                                                        </button>
                                                    </form>
                                                    <form action="${pageContext.request.contextPath}/admin/rejectLoan" method="post" style="display:inline;">
                                                        <input type="hidden" name="loanId" value="${loan[0]}">
                                                        <button type="submit" class="btn btn-danger btn-sm" title="Reject Loan" 
                                                                onclick="return confirm('Are you sure you want to reject this loan request?')">
                                                            <i class="bi bi-x-circle"></i> Reject
                                                        </button>
                                                    </form>
                                                </c:if>
                                                <c:if test="${loan[8] == 'RETURN_REQUESTED'}">
                                                    <form action="${pageContext.request.contextPath}/admin/approveReturn" method="post" style="display:inline;">
                                                        <input type="hidden" name="loanId" value="${loan[0]}">
                                                        <button type="submit" class="btn btn-primary btn-sm" title="Approve Return">
                                                            <i class="bi bi-arrow-return-left"></i> Approve Return
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </div>
                                        <% } else { %>
                                            <!-- USER ACTIONS -->
                                            <c:if test="${loan[8] == 'APPROVED' && !loan[6]}">
                                                <form action="${pageContext.request.contextPath}/library/requestReturn" method="post" style="display:inline;">
                                                    <input type="hidden" name="loanId" value="${loan[0]}">
                                                    <button type="submit" class="btn btn-warning btn-sm" title="Request Return">
                                                        <i class="bi bi-arrow-return-left"></i> Request Return
                                                    </button>
                                                </form>
                                            </c:if>
                                            <c:if test="${loan[8] == 'PENDING'}">
                                                <small class="text-muted">Waiting for approval</small>
                                            </c:if>
                                            <c:if test="${loan[8] == 'RETURN_REQUESTED'}">
                                                <small class="text-info">Return request sent</small>
                                            </c:if>
                                        <% } %>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty loans}">
                                <tr>
                                    <td colspan="<% if (isAdmin) { %>10<% } else { %>8<% } %>" class="text-center text-muted">
                                        <% if (isAdmin) { %>
                                            No loan requests found.
                                        <% } else { %>
                                            You haven't borrowed any books yet. Use the search above to find books to borrow.
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

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <% if (!isAdmin) { %>
    <script>
        let searchTimeout;
        
        document.getElementById('bookSearch').addEventListener('input', function() {
            clearTimeout(searchTimeout);
            const query = this.value.trim();
            
            if (query.length < 2) {
                document.getElementById('bookSearchResults').innerHTML = '';
                return;
            }
            
            searchTimeout = setTimeout(() => {
                fetch('${pageContext.request.contextPath}/library/searchAvailableBooks?query=' + encodeURIComponent(query))
                    .then(response => response.json())
                    .then(books => {
                        let resultsHtml = '';
                        
                        if (books.length === 0) {
                            resultsHtml = '<div class="alert alert-info">No available books found matching your search.</div>';
                        } else {
                            resultsHtml = '<div class="list-group">';
                            books.forEach(book => {
                                resultsHtml += `
                                    <div class="list-group-item d-flex justify-content-between align-items-center">
                                        <div>
                                            <strong>${book.title}</strong> by ${book.author}
                                            <br><small class="text-muted">${book.available} copies available</small>
                                        </div>
                                        <form action="${pageContext.request.contextPath}/library/addLoan" method="post" style="display:inline;">
                                            <input type="hidden" name="bookId" value="${book.id}">
                                            <button type="submit" class="btn btn-primary btn-sm">
                                                <i class="bi bi-plus-circle"></i> Borrow
                                            </button>
                                        </form>
                                    </div>
                                `;
                            });
                            resultsHtml += '</div>';
                        }
                        
                        document.getElementById('bookSearchResults').innerHTML = resultsHtml;
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        document.getElementById('bookSearchResults').innerHTML = 
                            '<div class="alert alert-danger">Error searching books. Please try again.</div>';
                    });
            }, 300);
        });
    </script>
    <% } %>
    
    <!-- Add Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
</body>
</html>