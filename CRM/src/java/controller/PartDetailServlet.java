package controller;

import dal.PartDetailDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.Comparator;
import java.util.List;
import model.Account;
import model.NewPartDetail;

/**
 * PartDetailServlet - Quản lý chi tiết thiết bị
 * @author Admin
 */
public class PartDetailServlet extends HttpServlet {
    
    private PartDetailDAO dao = new PartDetailDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy danh sách tất cả part details
        List<NewPartDetail> list = dao.getAllPartDetails();
        request.setAttribute("list", list);
        
        // Forward về JSP
        request.getRequestDispatcher("partDetail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
        String action = request.getParameter("action");
        if (action == null) action = "";

        // ===== XỬ LÝ ADD =====
        if ("add".equalsIgnoreCase(action)) {
            try {
                System.out.println("=== START ADD ===");
                
                // Lấy accountId từ session
                Account acc = (Account) session.getAttribute("session_login");
                System.out.println("AccountId from session: " + acc.getAccountId());
                
                if (acc.getAccountId() == -1) {
                    System.out.println("❌ AccountId is NULL - redirect to login");
                    session.setAttribute("errorMessage", "Bạn cần đăng nhập để thực hiện thao tác này!");
                    response.sendRedirect("login");
                    return;
                }
                
                // Tạo object mới
                NewPartDetail newPart = new NewPartDetail();
                newPart.setPartId(Integer.parseInt(request.getParameter("partId")));
                newPart.setSerialNumber(request.getParameter("serialNumber"));
                newPart.setStatus(request.getParameter("status"));
                newPart.setLocation(request.getParameter("location"));
                newPart.setLastUpdatedBy(acc.getAccountId()); // SET accountId (INT)
                newPart.setLastUpdatedDate(java.time.LocalDate.now());
                
                System.out.println("Data prepared:");
                System.out.println("  PartId: " + newPart.getPartId());
                System.out.println("  SerialNumber: " + newPart.getSerialNumber());
                System.out.println("  Status: " + newPart.getStatus());
                System.out.println("  Location: " + newPart.getLocation());
                System.out.println("  LastUpdatedBy: " + acc.getFullName());
                
                // Gọi DAO để insert
                boolean success = dao.addPartDetail(newPart);
                
                if (success) {
                    System.out.println("✅ Add successful!");
                    session.setAttribute("successMessage", "Thêm mới thành công!");
                } else {
                    System.out.println("❌ Add failed!");
                    session.setAttribute("errorMessage", "Thêm mới thất bại! Vui lòng kiểm tra lại.");
                }
                
                response.sendRedirect("partDetail");
                return;
                
            } catch (NumberFormatException e) {
                System.out.println("❌ Number format error: " + e.getMessage());
                session.setAttribute("errorMessage", "Dữ liệu không hợp lệ! Vui lòng kiểm tra lại.");
                response.sendRedirect("partDetail");
                return;
            } catch (Exception e) {
                System.out.println("❌ Unexpected error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
                response.sendRedirect("partDetail");
                return;
            }
        }

        // ===== XỬ LÝ EDIT =====
        if ("edit".equalsIgnoreCase(action)) {
            try {
                System.out.println("=== START EDIT ===");
                
                Account acc = (Account) session.getAttribute("session_login");
                System.out.println("AccountId from session: " + acc.getAccountId());
                if (acc.getAccountId()== -1l) {
                    System.out.println("❌ AccountId is NULL - redirect to login");
                    session.setAttribute("errorMessage", "Bạn cần đăng nhập để thực hiện thao tác này!");
                    response.sendRedirect("login");
                    return;
                }
                
                int partDetailId = Integer.parseInt(request.getParameter("partDetailId"));
                System.out.println("Editing partDetailId: " + partDetailId);
                
                NewPartDetail part = dao.getPartDetailById(partDetailId);
                
                if (part != null) {
                    part.setPartId(Integer.parseInt(request.getParameter("partId")));
                    part.setSerialNumber(request.getParameter("serialNumber"));
                    part.setStatus(request.getParameter("status"));
                    part.setLocation(request.getParameter("location"));
                    part.setUsername(acc.getUsername()); // UPDATE với accountId hiện tại
                    part.setLastUpdatedDate(java.time.LocalDate.now());
                    
                    System.out.println("Updated data:");
                    System.out.println("  PartDetailId: " + partDetailId);
                    System.out.println("  PartId: " + part.getPartId());
                    System.out.println("  SerialNumber: " + part.getSerialNumber());
                    System.out.println("  Status: " + part.getStatus());
                    System.out.println("  Location: " + part.getLocation());
                    
                    boolean success = dao.updatePartDetail(part);
                    
                    if (success) {
                        System.out.println("✅ Edit successful!");
                        session.setAttribute("successMessage", "Cập nhật thành công!");
                    } else {
                        System.out.println("❌ Edit failed!");
                        session.setAttribute("errorMessage", "Cập nhật thất bại!");
                    }
                } else {
                    System.out.println("❌ PartDetail not found with ID: " + partDetailId);
                    session.setAttribute("errorMessage", "Không tìm thấy thiết bị với ID: " + partDetailId);
                }
                
                response.sendRedirect("partDetail");
                return;
                
            } catch (NumberFormatException e) {
                System.out.println("❌ Number format error: " + e.getMessage());
                session.setAttribute("errorMessage", "Dữ liệu không hợp lệ!");
                response.sendRedirect("partDetail");
                return;
            } catch (Exception e) {
                System.out.println("❌ Unexpected error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
                response.sendRedirect("partDetail");
                return;
            }
        }

        // ===== XỬ LÝ DELETE =====
        if ("delete".equalsIgnoreCase(action)) {
            try {
                System.out.println("=== START DELETE ===");
                
                int partDetailId = Integer.parseInt(request.getParameter("partDetailId"));
                System.out.println("Deleting partDetailId: " + partDetailId);
                
                boolean success = dao.deletePartDetail(partDetailId);
                
                if (success) {
                    System.out.println("✅ Delete successful!");
                    session.setAttribute("successMessage", "Xóa thành công!");
                } else {
                    System.out.println("❌ Delete failed!");
                    session.setAttribute("errorMessage", "Xóa thất bại!");
                }
                
                response.sendRedirect("partDetail");
                return;
                
            } catch (NumberFormatException e) {
                System.out.println("❌ Number format error: " + e.getMessage());
                session.setAttribute("errorMessage", "ID không hợp lệ!");
                response.sendRedirect("partDetail");
                return;
            } catch (Exception e) {
                System.out.println("❌ Unexpected error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
                response.sendRedirect("partDetail");
                return;
            }
        }

        // ===== XỬ LÝ SEARCH & FILTER =====
        List<NewPartDetail> list = dao.getAllPartDetails();
        String keyword = request.getParameter("keyword");
        String filter = request.getParameter("filter");

        // Search theo keyword
        if (keyword != null && !keyword.trim().isEmpty()) {
            String keywordLower = keyword.toLowerCase().trim();
            System.out.println("Searching with keyword: " + keywordLower);
            
            list = list.stream()
                .filter(pd -> 
                    String.valueOf(pd.getPartDetailId()).contains(keywordLower) ||
                    String.valueOf(pd.getPartId()).contains(keywordLower) ||
                    pd.getSerialNumber().toLowerCase().contains(keywordLower) ||
                    pd.getStatus().toLowerCase().contains(keywordLower) ||
                    pd.getLocation().toLowerCase().contains(keywordLower) ||
                    (pd.getUsername() != null && pd.getUsername().toLowerCase().contains(keywordLower))
                )
                .collect(java.util.stream.Collectors.toList());
            
            System.out.println("Found " + list.size() + " results");
        }

        // Filter theo cột
        if (filter != null && !filter.isEmpty()) {
            System.out.println("Filtering by: " + filter);
            switch (filter.toLowerCase()) {
                case "partid": 
                    list.sort(Comparator.comparing(NewPartDetail::getPartId)); 
                    break;
                case "inventoryid": 
                    list.sort(Comparator.comparing(NewPartDetail::getPartDetailId)); 
                    break;
                case "partname": 
                    list.sort(Comparator.comparing(NewPartDetail::getSerialNumber)); 
                    break;
                case "lastupdateperson": 
                    list.sort(Comparator.comparing(pd -> 
                        pd.getUsername() != null ? pd.getUsername() : ""
                    )); 
                    break;
                case "lastupdatetime": 
                    list.sort(Comparator.comparing(NewPartDetail::getLastUpdatedDate).reversed()); 
                    break;
            }
        }

        request.setAttribute("list", list);
        request.getRequestDispatcher("partDetail.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "PartDetail Servlet - Manages part detail CRUD operations";
    }
}