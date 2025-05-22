package com.library;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(urlPatterns = {
    "/loans.jsp", 
    "/dashboard.jsp", 
    "/overdue.jsp",
    "/library/loans",
    "/library/addLoan",
    "/library/returnBook",
    "/library/requestReturn",
    "/library/addBook",
    "/library/deleteBook", 
    "/library/updateStock",
    "/library/deleteMember",
    "/library/addMember",
    "/reports/*",
    "/admin/*"
}) // Removed /library/books to allow public access to book catalog
public class AuthenticationFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        Boolean isLoggedIn = (session != null && Boolean.TRUE.equals(session.getAttribute("isLoggedIn")));

        if (!isLoggedIn) {
            // For AJAX requests, return JSON response
            if ("XMLHttpRequest".equals(req.getHeader("X-Requested-With"))) {
                res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                res.setContentType("application/json");
                res.getWriter().write("{\"error\": \"NOT_LOGGED_IN\", \"message\": \"Please login to continue\"}");
            } else {
                // For regular requests, redirect to login
                String requestURI = req.getRequestURI();
                String contextPath = req.getContextPath();
                
                // Store the original URL for redirect after login
                String originalUrl = requestURI;
                if (req.getQueryString() != null) {
                    originalUrl += "?" + req.getQueryString();
                }
                
                // Redirect to login with return URL
                res.sendRedirect(contextPath + "/auth/login?returnUrl=" + 
                    java.net.URLEncoder.encode(originalUrl, "UTF-8"));
            }
        } else {
            chain.doFilter(request, response);
        }
    }
}