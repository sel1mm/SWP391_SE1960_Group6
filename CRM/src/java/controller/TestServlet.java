package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * Simple test servlet to verify deployment is working
 */
public class TestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<title>Test Servlet</title>");
        out.println("</head>");
        out.println("<body>");
        out.println("<h1>Technician Module Test</h1>");
        out.println("<p>Servlet deployment is working!</p>");
        out.println("<p>Time: " + new java.util.Date() + "</p>");
        out.println("<hr>");
        out.println("<h2>Available Endpoints:</h2>");
        out.println("<ul>");
        out.println("<li><a href='/CRM/technician/tasks'>Technician Tasks</a></li>");
        out.println("<li><a href='/CRM/technician/reports'>Technician Reports</a></li>");
        out.println("<li><a href='/CRM/technician/contracts'>Technician Contracts</a></li>");
        out.println("<li><a href='/CRM/technician/dashboard'>Technician Dashboard</a></li>");
        out.println("</ul>");
        out.println("</body>");
        out.println("</html>");
    }
}
