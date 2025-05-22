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
    <title>Library Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .hero-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 4rem 0;
        }
        .feature-card {
            transition: transform 0.3s ease;
            border: none;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/">
                <i class="bi bi-book"></i> Library System
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/library/books">
                            <i class="bi bi-book-half"></i> Books
                        </a>
                    </li>
                    <% if (!showLogin) { %>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/library/loans">
                            <i class="bi bi-journal-check"></i> 
                            <% if (isAdmin) { %>Loan Management<% } else { %>My Loans<% } %>
                        </a>
                    </li>
                    <% } %>
                    <% if (isAdmin) { %>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/reports">
                            <i class="bi bi-graph-up"></i> Reports
                        </a>
                    </li>
                    <% } %>
                </ul>
                <ul class="navbar-nav">
                    <% if (showLogin) { %>
                        <li class="nav-item">
                            <a class="btn btn-outline-light me-2" href="${pageContext.request.contextPath}/auth/login">
                                <i class="bi bi-box-arrow-in-right"></i> Login
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="btn btn-light" href="${pageContext.request.contextPath}/auth/register">
                                <i class="bi bi-person-plus"></i> Register
                            </a>
                        </li>
                    <% } else { %>
                        <li class="nav-item">
                            <span class="nav-link">
                                <i class="bi bi-person-circle"></i> Welcome, ${sessionScope.user.fullName}
                                <% if (isAdmin) { %><span class="badge bg-warning text-dark ms-1">Admin</span><% } %>
                            </span>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/auth/logout">
                                <i class="bi bi-box-arrow-right"></i> Logout
                            </a>
                        </li>
                    <% } %>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <div class="hero-section">
        <div class="container text-center">
            <h1 class="display-4 mb-4">
                <i class="bi bi-building"></i> Library Management System
            </h1>
            <p class="lead mb-4">Efficiently manage your books, loans, and library operations</p>
            <% if (showLogin) { %>
                <div class="mb-4">
                    <a href="${pageContext.request.contextPath}/library/books" class="btn btn-light btn-lg me-3">
                        <i class="bi bi-eye"></i> Browse Books
                    </a>
                    <a href="${pageContext.request.contextPath}/auth/login" class="btn btn-outline-light btn-lg">
                        <i class="bi bi-box-arrow-in-right"></i> Login to Borrow
                    </a>
                </div>
            <% } else { %>
                <div class="mb-4">
                    <a href="${pageContext.request.contextPath}/library/books" class="btn btn-light btn-lg me-3">
                        <i class="bi bi-book-half"></i> Browse Books
                    </a>
                    <a href="${pageContext.request.contextPath}/library/loans" class="btn btn-outline-light btn-lg">
                        <i class="bi bi-journal-check"></i> 
                        <% if (isAdmin) { %>Manage Loans<% } else { %>My Loans<% } %>
                    </a>
                </div>
            <% } %>
        </div>
    </div>

    <!-- Features Section -->
    <div class="container my-5">
        <div class="row">
            <!-- Public Features -->
            <div class="col-md-4 mb-4">
                <div class="card feature-card h-100">
                    <div class="card-body text-center">
                        <div class="mb-3">
                            <i class="bi bi-book-half text-primary" style="font-size: 3rem;"></i>
                        </div>
                        <h5 class="card-title">Browse Books</h5>
                        <p class="card-text">Explore our extensive collection of books across various categories</p>
                        <a href="${pageContext.request.contextPath}/library/books" class="btn btn-primary">
                            <i class="bi bi-search"></i> Browse Now
                        </a>
                    </div>
                </div>
            </div>

            <% if (!showLogin) { %>
                <!-- Logged-in User Features -->
                <div class="col-md-4 mb-4">
                    <div class="card feature-card h-100">
                        <div class="card-body text-center">
                            <div class="mb-3">
                                <i class="bi bi-journal-check text-success" style="font-size: 3rem;"></i>
                            </div>
                            <h5 class="card-title">
                                <% if (isAdmin) { %>Manage Loans<% } else { %>My Loans<% } %>
                            </h5>
                            <p class="card-text">
                                <% if (isAdmin) { %>
                                    Review and approve loan requests, manage returns
                                <% } else { %>
                                    View your borrowed books and request returns
                                <% } %>
                            </p>
                            <a href="${pageContext.request.contextPath}/library/loans" class="btn btn-success">
                                <% if (isAdmin) { %>
                                    <i class="bi bi-gear"></i> Manage
                                <% } else { %>
                                    <i class="bi bi-list"></i> View Loans
                                <% } %>
                            </a>
                        </div>
                    </div>
                </div>

                <% if (isAdmin) { %>
                    <!-- Admin Features -->
                    <div class="col-md-4 mb-4">
                        <div class="card feature-card h-100">
                            <div class="card-body text-center">
                                <div class="mb-3">
                                    <i class="bi bi-graph-up text-info" style="font-size: 3rem;"></i>
                                </div>
                                <h5 class="card-title">Reports & Analytics</h5>
                                <p class="card-text">View comprehensive reports and library statistics</p>
                                <a href="${pageContext.request.contextPath}/reports" class="btn btn-info">
                                    <i class="bi bi-bar-chart"></i> View Reports
                                </a>
                            </div>
                        </div>
                    </div>
                <% } %>
            <% } else { %>
                <!-- Login Encouragement for Guests -->
                <div class="col-md-4 mb-4">
                    <div class="card feature-card h-100">
                        <div class="card-body text-center">
                            <div class="mb-3">
                                <i class="bi bi-bookmark-heart text-warning" style="font-size: 3rem;"></i>
                            </div>
                            <h5 class="card-title">Borrow Books</h5>
                            <p class="card-text">Login to borrow books and manage your reading list</p>
                            <a href="${pageContext.request.contextPath}/auth/login" class="btn btn-warning">
                                <i class="bi bi-box-arrow-in-right"></i> Login Required
                            </a>
                        </div>
                    </div>
                </div>

                <div class="col-md-4 mb-4">
                    <div class="card feature-card h-100">
                        <div class="card-body text-center">
                            <div class="mb-3">
                                <i class="bi bi-person-plus text-secondary" style="font-size: 3rem;"></i>
                            </div>
                            <h5 class="card-title">Join Our Library</h5>
                            <p class="card-text">Create an account to access all library features</p>
                            <a href="${pageContext.request.contextPath}/auth/register" class="btn btn-secondary">
                                <i class="bi bi-person-plus"></i> Register Now
                            </a>
                        </div>
                    </div>
                </div>
            <% } %>
        </div>

        <!-- Quick Stats Section -->
        <% if (isAdmin) { %>
        <div class="row mt-5">
            <div class="col-12">
                <h3 class="text-center mb-4">Quick Dashboard</h3>
                <div class="row text-center">
                    <div class="col-md-3">
                        <div class="card bg-primary text-white">
                            <div class="card-body">
                                <i class="bi bi-book" style="font-size: 2rem;"></i>
                                <h4 class="mt-2">Total Books</h4>
                                <a href="${pageContext.request.contextPath}/library/books" class="btn btn-light btn-sm">View</a>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card bg-warning text-dark">
                            <div class="card-body">
                                <i class="bi bi-clock-history" style="font-size: 2rem;"></i>
                                <h4 class="mt-2">Pending Requests</h4>
                                <a href="${pageContext.request.contextPath}/library/loans" class="btn btn-dark btn-sm">Review</a>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card bg-info text-white">
                            <div class="card-body">
                                <i class="bi bi-journal-check" style="font-size: 2rem;"></i>
                                <h4 class="mt-2">Active Loans</h4>
                                <a href="${pageContext.request.contextPath}/library/loans" class="btn btn-light btn-sm">Manage</a>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card bg-success text-white">
                            <div class="card-body">
                                <i class="bi bi-graph-up" style="font-size: 2rem;"></i>
                                <h4 class="mt-2">Reports</h4>
                                <a href="${pageContext.request.contextPath}/reports" class="btn btn-light btn-sm">View</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <% } %>

        <!-- Call to Action -->
        <% if (showLogin) { %>
        <div class="row mt-5">
            <div class="col-12 text-center">
                <div class="card bg-light">
                    <div class="card-body">
                        <h4>Ready to get started?</h4>
                        <p class="lead">Join our library community and start borrowing books today!</p>
                        <a href="${pageContext.request.contextPath}/auth/register" class="btn btn-success btn-lg me-3">
                            <i class="bi bi-person-plus"></i> Create Account
                        </a>
                        <a href="${pageContext.request.contextPath}/auth/login" class="btn btn-outline-primary btn-lg">
                            <i class="bi bi-box-arrow-in-right"></i> Login
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>