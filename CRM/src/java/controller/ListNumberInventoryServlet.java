/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import dal.InventoryDAO;
import dal.PartDetailDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
import model.Account;

import model.NewInventory;
import model.Part;

/**
 *
 * @author Admin
 */
public class ListNumberInventoryServlet extends HttpServlet {
   InventoryDAO dao = new InventoryDAO();
   PartDetailDAO dao1 = new PartDetailDAO();
    /** 
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ListNumberInventoryServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ListNumberInventoryServlet at " + request.getContextPath () + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    } 

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /** 
     * Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
         HttpSession  session = request.getSession();
        Account acc = (Account) session.getAttribute("session_login");
        if (acc == null) {
            response.sendRedirect("login");
            return;
        }
        String username = acc.getUsername() ;
        session.setAttribute("username", username);
        List<NewInventory> list = dao.getAllInventories();
        request.setAttribute("list", dao.getAllInventories());
        request.getRequestDispatcher("numberInventory.jsp").forward(request, response);
    } 

    /** 
     * Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
         HttpSession  session = request.getSession();
          session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
        Account acc = (Account) session.getAttribute("session_login");
        if (acc == null) {
            response.sendRedirect("login");
            return;
        }
        String username = acc.getUsername() ;
        session.setAttribute("username", username);
          List<NewInventory> list = dao.getAllInventories();
          String keyword = request.getParameter("keyword");
            if (keyword != null && !keyword.trim().isEmpty()) {
        String lowerKeyword = keyword.trim().toLowerCase();

        list = list.stream()
                .filter(item -> {
                    // Convert các trường về String để so sánh
                    String partIdStr = String.valueOf(item.getPartId());
                    String inventoryIdStr = String.valueOf(item.getInventoryId());
                    String partNameStr = item.getPartName() != null ? item.getPartName().toLowerCase() : "";
                    String quantityStr = String.valueOf(item.getQuantity());
                    String lastUpdatedByStr = String.valueOf(item.getLastUpdatedBy()); // là số
                    String lastUpdatedDateStr = item.getLastUpdatedDate() != null ? item.getLastUpdatedDate().toString().toLowerCase() : "";

                    // Nếu keyword xuất hiện ở bất kỳ trường nào thì trả về true
                    return partIdStr.contains(lowerKeyword)
                            || inventoryIdStr.contains(lowerKeyword)
                            || partNameStr.contains(lowerKeyword)
                            || quantityStr.contains(lowerKeyword)
                            || lastUpdatedByStr.contains(lowerKeyword)
                            || lastUpdatedDateStr.contains(lowerKeyword);
                })
                .collect(Collectors.toList());
    }

           String filter = request.getParameter("filter");
         if ( filter == null   ||  filter.isEmpty()){
            list.sort(Comparator.comparing(NewInventory::getInventoryId));
        }  
         else if (filter.equalsIgnoreCase("partId")){
            list.sort(Comparator.comparing(NewInventory::getPartId));
        } 
         else if  (filter.equalsIgnoreCase("inventoryId")){
           list.sort(Comparator.comparing(NewInventory::getInventoryId));
        } 
        else if (filter.equalsIgnoreCase("partName")){
           list.sort(Comparator.comparing(NewInventory::getPartName));
        }
           else if (filter.equalsIgnoreCase("quantity")){
           list.sort(Comparator.comparing(NewInventory::getQuantity));
        }
         else if (filter.equalsIgnoreCase("lastUpdatePerson")){
             list.sort(Comparator.comparing(NewInventory::getLastUpdatedBy));
        }
          else if (filter.equalsIgnoreCase("lastUpdateTime")){
           list.sort(Comparator.comparing(NewInventory::getLastUpdatedDate));
        }
        request.setAttribute("list", list);
        request.getRequestDispatcher("numberInventory.jsp").forward(request, response);
    }

    /** 
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
