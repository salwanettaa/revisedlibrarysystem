<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page import="com.library.User"%>
<%
    Boolean isLoggedIn = (Boolean) session.getAttribute("isLoggedIn");
    User user = (User) session.getAttribute("user");
    boolean showLogin = (isLoggedIn == null || !isLoggedIn || user == null);
    boolean isAdmin = user != null && "ADMIN".equals(user.getRole());
    
    // Redirect non-admin users
    if (!isAdmin) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Admin privileges required.");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Reports Dashboard - Library Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .stat-card {
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            cursor: pointer;
        }
        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
        }
        .stat-number {
            font-size: 2.5rem;
            font-weight: bold;
        }
        .stat-icon {
            font-size: 3rem;
            opacity: 0.7;
        }
    </style>
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
                    <a class="nav-link" href="${pageContext.request.contextPath}/library/loans">Loan Management</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link active" href="${pageContext.request.contextPath}/reports">Reports</a>
                </li>
            </ul>
            <ul class="navbar-nav">
                <li class="nav-item">
                    <span class="nav-link">Welcome, ${sessionScope.user.fullName} (Admin)</span>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/auth/logout">Logout</a>
                </li>
            </ul>
        </div>
    </div>
</nav>

    <div class="container mt-4">
        <h2><i class="bi bi-graph-up"></i> Library Reports Dashboard</h2>
        <p class="text-muted">Click on any statistic card to view detailed information</p>
        
        <!-- Summary Cards with Clickable Links -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card text-white bg-primary stat-card" 
                     onclick="window.location.href='${pageContext.request.contextPath}/library/books'">
                    <div class="card-body text-center">
                        <div class="row align-items-center">
                            <div class="col">
                                <i class="bi bi-book stat-icon"></i>
                            </div>
                            <div class="col">
                                <h5 class="card-title mb-1">Total Books</h5>
                                <div class="stat-number">${stats.totalBooks}</div>
                                <small><i class="bi bi-arrow-right"></i> View Catalog</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-white bg-success stat-card" 
                     onclick="window.location.href='${pageContext.request.contextPath}/reports/users'">
                    <div class="card-body text-center">
                        <div class="row align-items-center">
                            <div class="col">
                                <i class="bi bi-people stat-icon"></i>
                            </div>
                            <div class="col">
                                <h5 class="card-title mb-1">Registered Users</h5>
                                <div class="stat-number">${stats.totalMembers}</div>
                                <small><i class="bi bi-arrow-right"></i> View Users</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-white bg-info stat-card" 
                     onclick="window.location.href='${pageContext.request.contextPath}/library/loans'">
                    <div class="card-body text-center">
                        <div class="row align-items-center">
                            <div class="col">
                                <i class="bi bi-journal-check stat-icon"></i>
                            </div>
                            <div class="col">
                                <h5 class="card-title mb-1">Active Loans</h5>
                                <div class="stat-number">${stats.activeLoans}</div>
                                <small><i class="bi bi-arrow-right"></i> Manage Loans</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-white bg-danger stat-card" 
                     onclick="window.location.href='${pageContext.request.contextPath}/reports/overdue'">
                    <div class="card-body text-center">
                        <div class="row align-items-center">
                            <div class="col">
                                <i class="bi bi-exclamation-triangle stat-icon"></i>
                            </div>
                            <div class="col">
                                <h5 class="card-title mb-1">Overdue Books</h5>
                                <div class="stat-number">${stats.overdueBooks}</div>
                                <small><i class="bi bi-arrow-right"></i> View Overdue</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Report Links -->
        <div class="row">
            <div class="col-md-6">
                <div class="card mb-3">
                    <div class="card-header">
                        <h5><i class="bi bi-file-earmark-text"></i> Available Reports</h5>
                    </div>
                    <div class="list-group list-group-flush">
                        <a href="${pageContext.request.contextPath}/reports/overdue" class="list-group-item list-group-item-action">
                            <i class="bi bi-exclamation-triangle-fill text-danger"></i> Overdue Books Report
                            <span class="badge bg-danger float-end">${stats.overdueBooks}</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/library/loans" class="list-group-item list-group-item-action">
                            <i class="bi bi-journal-check text-info"></i> Active Loans Management
                            <span class="badge bg-info float-end">${stats.activeLoans}</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/reports/users" class="list-group-item list-group-item-action">
                            <i class="bi bi-people-fill text-success"></i> All Users Report
                            <span class="badge bg-success float-end">${stats.totalMembers}</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/reports/popular-authors" class="list-group-item list-group-item-action">
                            <i class="bi bi-person-fill text-primary"></i> Popular Authors Report
                        </a>
                        <a href="${pageContext.request.contextPath}/reports/popular-categories" class="list-group-item list-group-item-action">
                            <i class="bi bi-bookmark-fill text-warning"></i> Popular Categories Report
                        </a>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card mb-3">
                    <div class="card-header">
                        <h5><i class="bi bi-lightning"></i> Quick Actions</h5>
                    </div>
                    <div class="list-group list-group-flush">
                        <a href="${pageContext.request.contextPath}/library/loans" class="list-group-item list-group-item-action">
                            <i class="bi bi-clipboard-check text-warning"></i> Manage Loan Requests
                            <small class="text-muted d-block">Approve/reject pending requests</small>
                        </a>
                        <a href="${pageContext.request.contextPath}/library/books" class="list-group-item list-group-item-action">
                            <i class="bi bi-book text-info"></i> Manage Books
                            <small class="text-muted d-block">Add, edit, or update book inventory</small>
                        </a>
                    </div>
                </div>
            </div>
        </div>

       

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>