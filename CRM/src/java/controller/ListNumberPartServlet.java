
package controller;

import dal.PartDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
import model.Account;
import model.NewPart;

/**
 * ListNumberPartServlet - Quản lý danh sách hàng tồn kho
 * @author Admin
 */
public class ListNumberPartServlet extends HttpServlet {
    
    private PartDAO dao = new PartDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập
        HttpSession session = request.getSession();
        Account acc = (Account) session.getAttribute("session_login");
        if (acc == null) {
            response.sendRedirect("login");
            return;
        }

        // Lấy danh sách tất cả parts
        List<NewPart> list = dao.getAllParts();
        request.setAttribute("list", list);
        
        // Forward về JSP
        request.getRequestDispatcher("numberPart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Account acc = (Account) session.getAttribute("session_login");
        
        // Kiểm tra đăng nhập
        if (acc == null) {
            response.sendRedirect("login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "";

        // ===== XỬ LÝ ADD =====
        if ("add".equalsIgnoreCase(action)) {
            try {
                System.out.println("=== START ADD PART ===");
                
                String partName = request.getParameter("partName");
                String description = request.getParameter("description");
                String unitPriceStr = request.getParameter("unitPrice");

                System.out.println("PartName: " + partName);
                System.out.println("Description: " + description);
                System.out.println("UnitPrice: " + unitPriceStr);
                
                if (partName == null || description == null || unitPriceStr == null 
                    || partName.trim().isEmpty() || description.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin!");
                    response.sendRedirect("numberPart");
                    return;
                }

                double unitPrice = Double.parseDouble(unitPriceStr);
                
                if (unitPrice <= 0 || unitPrice >= 10000000) {
                    session.setAttribute("errorMessage", "Giá phải > 0 và < 10,000,000!");
                    response.sendRedirect("numberPart");
                    return;
                }

                NewPart part = new NewPart();
                part.setPartName(partName.trim());
                part.setDescription(description.trim());
                part.setUnitPrice(unitPrice);
                part.setLastUpdatedBy(acc.getAccountId());
                part.setLastUpdatedDate(LocalDate.now());
                
                System.out.println("Calling DAO to add part...");
                boolean success = dao.addPart(part);
                
                if (success) {
                    System.out.println("✅ Add part successful!");
                    session.setAttribute("successMessage", "Thêm Part thành công!");
                } else {
                    System.out.println("❌ Add part failed!");
                    session.setAttribute("errorMessage", "Thêm Part thất bại!");
                }
                
                response.sendRedirect("numberPart");
                return;
                
            } catch (NumberFormatException e) {
                System.out.println("❌ Number format error: " + e.getMessage());
                session.setAttribute("errorMessage", "Giá không hợp lệ!");
                response.sendRedirect("numberPart");
                return;
            } catch (Exception e) {
                System.out.println("❌ Unexpected error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
                response.sendRedirect("numberPart");
                return;
            }
        }

        // ===== XỬ LÝ EDIT =====
        if ("edit".equalsIgnoreCase(action)) {
            try {
                System.out.println("=== START EDIT PART ===");
                
                int partId = Integer.parseInt(request.getParameter("partId"));
                String partName = request.getParameter("partName");
                String description = request.getParameter("description");
                double unitPrice = Double.parseDouble(request.getParameter("unitPrice"));
                
                System.out.println("Editing PartId: " + partId);
                System.out.println("New PartName: " + partName);
                System.out.println("New UnitPrice: " + unitPrice);
                
                if (partName == null || description == null 
                    || partName.trim().isEmpty() || description.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin!");
                    response.sendRedirect("numberPart");
                    return;
                }
                
                if (unitPrice <= 0 || unitPrice >= 10000000) {
                    session.setAttribute("errorMessage", "Giá phải > 0 và < 10,000,000!");
                    response.sendRedirect("numberPart");
                    return;
                }
                
                NewPart part = new NewPart();
                part.setPartId(partId);
                part.setPartName(partName.trim());
                part.setDescription(description.trim());
                part.setUnitPrice(unitPrice);
                part.setLastUpdatedBy(acc.getAccountId());
                part.setLastUpdatedDate(LocalDate.now());
                
                boolean success = dao.updatePart(part);
                
                if (success) {
                    System.out.println("✅ Edit part successful!");
                    session.setAttribute("successMessage", "Cập nhật Part thành công!");
                } else {
                    System.out.println("❌ Edit part failed!");
                    session.setAttribute("errorMessage", "Cập nhật Part thất bại!");
                }
                
                response.sendRedirect("numberPart");
                return;
                
            } catch (NumberFormatException e) {
                System.out.println("❌ Number format error: " + e.getMessage());
                session.setAttribute("errorMessage", "Dữ liệu không hợp lệ!");
                response.sendRedirect("numberPart");
                return;
            } catch (Exception e) {
                System.out.println("❌ Unexpected error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
                response.sendRedirect("numberPart");
                return;
            }
        }

        // ===== XỬ LÝ DELETE =====
        if ("delete".equalsIgnoreCase(action)) {
            try {
                System.out.println("=== START DELETE PART ===");
                
                int partId = Integer.parseInt(request.getParameter("partId"));
                System.out.println("Deleting PartId: " + partId);
                
                boolean success = dao.deletePart(partId);
                
                if (success) {
                    System.out.println("✅ Delete part successful!");
                    session.setAttribute("successMessage", "Xóa Part thành công!");
                } else {
                    System.out.println("❌ Delete part failed!");
                    session.setAttribute("errorMessage", "Xóa Part thất bại!");
                }
                
                response.sendRedirect("numberPart");
                return;
                
            } catch (NumberFormatException e) {
                System.out.println("❌ Number format error: " + e.getMessage());
                session.setAttribute("errorMessage", "ID không hợp lệ!");
                response.sendRedirect("numberPart");
                return;
            } catch (Exception e) {
                System.out.println("❌ Unexpected error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
                response.sendRedirect("numberPart");
                return;
            }
        }

        // ===== XỬ LÝ SEARCH & FILTER =====
        List<NewPart> list = dao.getAllParts();
        String keyword = request.getParameter("keyword");
        String filter = request.getParameter("filter");

        // Search theo keyword
        if (keyword != null && !keyword.trim().isEmpty()) {
            String keywordLower = keyword.toLowerCase().trim();
            System.out.println("Searching with keyword: " + keywordLower);
            
            list = list.stream()
                .filter(p -> 
                    String.valueOf(p.getPartId()).contains(keywordLower) ||
                    p.getPartName().toLowerCase().contains(keywordLower) ||
                    p.getDescription().toLowerCase().contains(keywordLower) ||
                    String.valueOf(p.getUnitPrice()).contains(keywordLower) ||
                    (p.getUserName() != null && p.getUserName().toLowerCase().contains(keywordLower)) ||
                    (p.getLastUpdatedDate() != null && p.getLastUpdatedDate().toString().contains(keywordLower))
                )
                .collect(Collectors.toList());
            
            System.out.println("Found " + list.size() + " results");
        }

        // Filter theo cột
        if (filter != null && !filter.isEmpty()) {
            System.out.println("Filtering by: " + filter);
            switch (filter.toLowerCase()) {
                case "partid": 
                    list.sort(Comparator.comparing(NewPart::getPartId)); 
                    break;
                case "partname": 
                    list.sort(Comparator.comparing(NewPart::getPartName)); 
                    break;
                case "unitprice": 
                    list.sort(Comparator.comparing(NewPart::getUnitPrice)); 
                    break;
                case "updateperson": 
                    list.sort(Comparator.comparing(p -> 
                        p.getUserName() != null ? p.getUserName() : ""
                    )); 
                    break;
                case "updatedate": 
                    list.sort(Comparator.comparing(NewPart::getLastUpdatedDate).reversed()); 
                    break;
            }
        }

        request.setAttribute("list", list);
        request.getRequestDispatcher("numberPart.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "ListNumberPart Servlet - Manages part inventory CRUD operations";
    }
}