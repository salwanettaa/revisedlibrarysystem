<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>All Users Report - Library Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/">Library System</a>
            <div class="navbar-nav">
                <a class="nav-link" href="${pageContext.request.contextPath}/library/books">Books</a>
                <a class="nav-link" href="${pageContext.request.contextPath}/library/loans">Loan Management</a>
                <a class="nav-link active" href="${pageContext.request.contextPath}/reports">Reports</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2><i class="bi bi-people"></i> All Users Report</h2>
                <p class="text-muted">Complete list of all registered users in the system</p>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/reports" class="btn btn-secondary">
                    <i class="bi bi-arrow-left"></i> Back to Dashboard
                </a>
            </div>
        </div>

        <!-- Summary Cards -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card bg-primary text-white">
                    <div class="card-body text-center">
                        <i class="bi bi-shield-check" style="font-size: 2rem;"></i>
                        <h5 class="mt-2">Admins</h5>
                        <h3>
                            <c:set var="adminCount" value="0" />
                            <c:forEach items="${users}" var="user">
                                <c:if test="${user.role == 'ADMIN'}">
                                    <c:set var="adminCount" value="${adminCount + 1}" />
                                </c:if>
                            </c:forEach>
                            ${adminCount}
                        </h3>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-success text-white">
                    <div class="card-body text-center">
                        <i class="bi bi-person" style="font-size: 2rem;"></i>
                        <h5 class="mt-2">Regular Users</h5>
                        <h3>
                            <c:set var="userCount" value="0" />
                            <c:forEach items="${users}" var="user">
                                <c:if test="${user.role == 'USER'}">
                                    <c:set var="userCount" value="${userCount + 1}" />
                                </c:if>
                            </c:forEach>
                            ${userCount}
                        </h3>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-info text-white">
                    <div class="card-body text-center">
                        <i class="bi bi-journal-check" style="font-size: 2rem;"></i>
                        <h5 class="mt-2">Active Borrowers</h5>
                        <h3>
                            <c:set var="activeBorrowers" value="0" />
                            <c:forEach items="${users}" var="user">
                                <c:if test="${user.activeLoans > 0}">
                                    <c:set var="activeBorrowers" value="${activeBorrowers + 1}" />
                                </c:if>
                            </c:forEach>
                            ${activeBorrowers}
                        </h3>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-secondary text-white">
                    <div class="card-body text-center">
                        <i class="bi bi-people-fill" style="font-size: 2rem;"></i>
                        <h5 class="mt-2">Total Users</h5>
                        <h3>${users.size()}</h3>
                    </div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <i class="bi bi-table"></i> User Details
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Username</th>
                                <th>Full Name</th>
                                <th>Email</th>
                                <th>Role</th>
                                <th>Joined Date</th>
                                <th>Total Loans</th>
                                <th>Active Loans</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${users}" var="user">
                                <tr>
                                    <td><strong>#${user.id}</strong></td>
                                    <td>
                                        <strong>${user.username}</strong>
                                        <c:if test="${user.role == 'ADMIN'}">
                                            <i class="bi bi-shield-check text-primary" title="Administrator"></i>
                                        </c:if>
                                    </td>
                                    <td>${user.fullName}</td>
                                    <td>
                                        <a href="mailto:${user.email}" class="text-decoration-none">
                                            <i class="bi bi-envelope"></i> ${user.email}
                                        </a>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${user.role == 'ADMIN'}">
                                                <span class="badge bg-primary">
                                                    <i class="bi bi-shield-check"></i> Admin
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary">
                                                    <i class="bi bi-person"></i> User
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${user.createdAt}" pattern="yyyy-MM-dd"/>
                                        <br><small class="text-muted">
                                            <fmt:formatDate value="${user.createdAt}" pattern="HH:mm"/>
                                        </small>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${user.totalLoans > 0}">
                                                <span class="badge bg-info">${user.totalLoans}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">0</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${user.activeLoans > 0}">
                                                <span class="badge bg-warning text-dark">${user.activeLoans}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">0</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${user.activeLoans > 0}">
                                                <span class="badge bg-success">
                                                    <i class="bi bi-circle-fill"></i> Active Borrower
                                                </span>
                                            </c:when>
                                            <c:when test="${user.totalLoans > 0}">
                                                <span class="badge bg-info">
                                                    <i class="bi bi-check-circle"></i> Past Borrower
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-light text-dark">
                                                    <i class="bi bi-circle"></i> New User
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="btn-group btn-group-sm" role="group">
                                            <a href="https://mail.google.com/mail/?view=cm&fs=1&to=${user.email}&su=Library%20System%20Notification"
                                               class="btn btn-outline-primary" title="Send Email via Gmail">
                                                <i class="bi bi-envelope"></i>
                                            </a>

                                            <c:if test="${user.activeLoans > 0}">
                                                <a href="${pageContext.request.contextPath}/library/loans" 
                                                   class="btn btn-outline-info" title="View User's Loans">
                                                    <i class="bi bi-journal-check"></i>
                                                </a>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty users}">
                                <tr>
                                    <td colspan="10" class="text-center text-muted py-4">
                                        <i class="bi bi-inbox" style="font-size: 3rem;"></i>
                                        <br>No users found.
                                        <br><small>This shouldn't happen in a normal system.</small>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="card-footer">
                <div class="row">
                    <div class="col-md-6">
                        <small class="text-muted">
                            <i class="bi bi-info-circle"></i>
                            Total users: ${users.size()} | 
                            Active borrowers: ${activeBorrowers} |
                            Registration rate: 
                            <fmt:formatNumber value="${activeBorrowers / users.size() * 100}" maxFractionDigits="1"/>% active
                        </small>
                    </div>
                    <div class="col-md-6 text-end">
                        <small class="text-muted">
                            <i class="bi bi-calendar"></i>
                            Report generated: <fmt:formatDate value="<%= new java.util.Date() %>" pattern="yyyy-MM-dd HH:mm"/>
                        </small>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>