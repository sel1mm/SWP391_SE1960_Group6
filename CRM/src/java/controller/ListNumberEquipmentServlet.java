package controller;

import dal.CategoryDAO;
import dal.EquipmentDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDate;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import model.Account;
import model.Category;
import model.Equipment;

/**
 * ListNumberEquipmentServlet - Quản lý danh sách thiết bị với Category
 * @author Admin
 */
public class ListNumberEquipmentServlet extends HttpServlet {
    
    private EquipmentDAO dao = new EquipmentDAO();
    private CategoryDAO categoryDAO = new CategoryDAO();

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

        // ✅ Load categories (Equipment type)
        List<Category> categories = categoryDAO.getCategoriesByType("Equipment");
        request.setAttribute("categories", categories);

        // Lấy danh sách tất cả equipment
        List<Equipment> list = dao.getAllEquipment();
        request.setAttribute("list", list);
        
        // Forward về JSP
        request.getRequestDispatcher("numberEquipment.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Account acc = (Account) session.getAttribute("session_login");
        
        // Xóa message cũ
   
        
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
                System.out.println("=== START ADD EQUIPMENT ===");
                
                String serialNumber = request.getParameter("serialNumber");
                String model = request.getParameter("model");
                String description = request.getParameter("description");
                String installDateStr = request.getParameter("installDate");
                String categoryIdStr = request.getParameter("categoryId");

                System.out.println("SerialNumber: " + serialNumber);
                System.out.println("Model: " + model);
                System.out.println("Description: " + description);
                System.out.println("InstallDate: " + installDateStr);
                System.out.println("CategoryId: " + categoryIdStr);
                
                if (serialNumber == null || model == null || description == null || installDateStr == null
                    || serialNumber.trim().isEmpty() || model.trim().isEmpty() || description.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin!");
                    response.sendRedirect("numberEquipment");
                    return;
                }
                
                // Validate Serial Number (3-30 chars)
                if (serialNumber.trim().length() < 3 || serialNumber.trim().length() > 30) {
                    session.setAttribute("errorMessage", "Serial Number phải từ 3-30 ký tự!");
                    response.sendRedirect("numberEquipment");
                    return;
                }
                
                // Validate Model (>= 3 chars)
                if (model.trim().length() < 3) {
                    session.setAttribute("errorMessage", "Model phải có ít nhất 3 ký tự!");
                    response.sendRedirect("numberEquipment");
                    return;
                }
                
                // Validate Description (10-100 chars)
                if (description.trim().length() < 10 || description.trim().length() > 100) {
                    session.setAttribute("errorMessage", "Mô tả phải từ 10-100 ký tự!");
                    response.sendRedirect("numberEquipment");
                    return;
                }
                
                // Check duplicate Serial Number
                Equipment existingEquipment = dao.findBySerialNumber(serialNumber.trim());
                if (existingEquipment != null) {
                    session.setAttribute("errorMessage", "Serial Number đã tồn tại!");
                    response.sendRedirect("numberEquipment");
                    return;
                }

                LocalDate installDate = LocalDate.parse(installDateStr);
                
                Equipment equipment = new Equipment();
                equipment.setSerialNumber(serialNumber.trim());
                equipment.setModel(model.trim());
                equipment.setDescription(description.trim());
                equipment.setInstallDate(installDate);
                
                // ✅ SET CATEGORY (có thể NULL)
                if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
                    equipment.setCategoryId(Integer.parseInt(categoryIdStr));
                }
                
                equipment.setLastUpdatedBy(acc.getAccountId());
                equipment.setLastUpdatedDate(LocalDate.now());
                
                System.out.println("Calling DAO to add equipment...");
                boolean success = dao.insertEquipment(equipment);
                
                if (success) {
                    System.out.println("✅ Add equipment successful!");
                    session.setAttribute("successMessage", "Thêm Equipment thành công!");
                } else {
                    System.out.println("❌ Add equipment failed!");
                    session.setAttribute("errorMessage", "Thêm Equipment thất bại!");
                }
                
                response.sendRedirect("numberEquipment");
                return;
                
            } catch (Exception e) {
                System.out.println("❌ Unexpected error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
                response.sendRedirect("numberEquipment");
                return;
            }
        }

        // ===== XỬ LÝ EDIT =====
        if ("edit".equalsIgnoreCase(action)) {
            try {
                System.out.println("=== START EDIT EQUIPMENT ===");
                
                int equipmentId = Integer.parseInt(request.getParameter("equipmentId"));
                String serialNumber = request.getParameter("serialNumber");
                String model = request.getParameter("model");
                String description = request.getParameter("description");
                String categoryIdStr = request.getParameter("categoryId");
                
                // ❌ Install Date KHÔNG THỂ EDIT - giữ nguyên giá trị cũ
                Equipment oldEquipment = dao.findById(equipmentId);
                if (oldEquipment == null) {
                    session.setAttribute("errorMessage", "Không tìm thấy Equipment!");
                    response.sendRedirect("numberEquipment");
                    return;
                }
                
                System.out.println("Editing EquipmentId: " + equipmentId);
                System.out.println("New SerialNumber: " + serialNumber);
                System.out.println("New Model: " + model);
                System.out.println("New CategoryId: " + categoryIdStr);
                System.out.println("InstallDate (unchanged): " + oldEquipment.getInstallDate());
                
                if (serialNumber == null || model == null || description == null 
                    || serialNumber.trim().isEmpty() || model.trim().isEmpty() || description.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin!");
                    response.sendRedirect("numberEquipment");
                    return;
                }
                
                // Validate Serial Number (3-30 chars)
                if (serialNumber.trim().length() < 3 || serialNumber.trim().length() > 30) {
                    session.setAttribute("errorMessage", "Serial Number phải từ 3-30 ký tự!");
                    response.sendRedirect("numberEquipment");
                    return;
                }
                
                // Validate Model (>= 3 chars)
                if (model.trim().length() < 3) {
                    session.setAttribute("errorMessage", "Model phải có ít nhất 3 ký tự!");
                    response.sendRedirect("numberEquipment");
                    return;
                }
                
                // Validate Description (10-100 chars)
                if (description.trim().length() < 10 || description.trim().length() > 100) {
                    session.setAttribute("errorMessage", "Mô tả phải từ 10-100 ký tự!");
                    response.sendRedirect("numberEquipment");
                    return;
                }
                
                // Check duplicate Serial Number (ngoại trừ chính nó)
                Equipment existingEquipment = dao.findBySerialNumber(serialNumber.trim());
                if (existingEquipment != null && existingEquipment.getEquipmentId() != equipmentId) {
                    session.setAttribute("errorMessage", "Serial Number đã tồn tại!");
                    response.sendRedirect("numberEquipment");
                    return;
                }
                
                Equipment equipment = new Equipment();
                equipment.setEquipmentId(equipmentId);
                equipment.setSerialNumber(serialNumber.trim());
                equipment.setModel(model.trim());
                equipment.setDescription(description.trim());
                
                // ✅ GIỮ NGUYÊN INSTALL DATE
                equipment.setInstallDate(oldEquipment.getInstallDate());
                
                // ✅ SET CATEGORY
                if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
                    equipment.setCategoryId(Integer.parseInt(categoryIdStr));
                }
                
                equipment.setLastUpdatedBy(acc.getAccountId());
                equipment.setLastUpdatedDate(LocalDate.now());
                
                boolean success = dao.updateEquipment(equipment);
                
                if (success) {
                    System.out.println("✅ Edit equipment successful!");
                    session.setAttribute("successMessage", "Cập nhật Equipment thành công!");
                } else {
                    System.out.println("❌ Edit equipment failed!");
                    session.setAttribute("errorMessage", "Cập nhật Equipment thất bại!");
                }
                
                response.sendRedirect("numberEquipment");
                return;
                
            } catch (Exception e) {
                System.out.println("❌ Unexpected error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
                response.sendRedirect("numberEquipment");
                return;
            }
        }

        // ===== XỬ LÝ DELETE =====
        if ("delete".equalsIgnoreCase(action)) {
            try {
                System.out.println("=== START DELETE EQUIPMENT ===");
                
                int equipmentId = Integer.parseInt(request.getParameter("equipmentId"));
                System.out.println("Deleting EquipmentId: " + equipmentId);
                
                boolean success = dao.deleteEquipment(equipmentId);
                
                if (success) {
                    System.out.println("✅ Delete equipment successful!");
                    session.setAttribute("successMessage", "Xóa Equipment thành công!");
                } else {
                    System.out.println("❌ Delete equipment failed!");
                    session.setAttribute("errorMessage", "Xóa Equipment thất bại!");
                }
                
                response.sendRedirect("numberEquipment");
                return;
                
            } catch (Exception e) {
                System.out.println("❌ Unexpected error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
                response.sendRedirect("numberEquipment");
                return;
            }
        }

        // ===== XỬ LÝ DETAIL (Lấy thống kê trạng thái) =====
        if ("detail".equalsIgnoreCase(action)) {
            try {
                System.out.println("=== START DETAIL ===");
                
                int equipmentId = Integer.parseInt(request.getParameter("equipmentId"));
                System.out.println("Getting detail for EquipmentId: " + equipmentId);
                
                // Lấy thông tin Equipment
                Equipment equipment = dao.findById(equipmentId);
                
                if (equipment == null) {
                    session.setAttribute("errorMessage", "Không tìm thấy Equipment với ID: " + equipmentId);
                    response.sendRedirect("numberEquipment");
                    return;
                }
                
                // ✅ Lấy status của equipment này
                String status = dao.getEquipmentStatus(equipmentId);
                
                // Tạo status count map
                Map<String, Integer> statusCount = new HashMap<>();
                statusCount.put("Active", 0);
                statusCount.put("Repair", 0);
                statusCount.put("Maintenance", 0);
                
                // Cập nhật count theo status
                if ("Active".equals(status)) {
                    statusCount.put("Active", 1);
                } else if ("Repair".equals(status)) {
                    statusCount.put("Repair", 1);
                } else if ("Maintenance".equals(status)) {
                    statusCount.put("Maintenance", 1);
                }
                
                // Lấy danh sách tất cả equipment (để hiển thị bảng chính)
                List<Equipment> list = dao.getAllEquipment();
                
                // ✅ Load categories
                List<Category> categories = categoryDAO.getCategoriesByType("Equipment");
                
                // Set attributes
                request.setAttribute("list", list);
                request.setAttribute("categories", categories);
                request.setAttribute("selectedEquipment", equipment);
                request.setAttribute("statusCount", statusCount);
                request.setAttribute("showDetail", true);
                
                System.out.println("✅ Detail loaded successfully! Status: " + status);
                
                request.getRequestDispatcher("numberEquipment.jsp").forward(request, response);
                return;
                
            } catch (Exception e) {
                System.out.println("❌ Unexpected error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
                response.sendRedirect("numberEquipment");
                return;
            }
        }

        // ===== XỬ LÝ SEARCH & FILTER =====
        List<Equipment> list = dao.getAllEquipment();
        String keyword = request.getParameter("keyword");
        String filter = request.getParameter("filter");
        String categoryFilter = request.getParameter("categoryFilter");

        // ✅ FILTER BY CATEGORY TRƯỚC
        if (categoryFilter != null && !categoryFilter.isEmpty()) {
            try {
                int catId = Integer.parseInt(categoryFilter);
                list = dao.getEquipmentByCategory(catId);
                System.out.println("Filtered by categoryId: " + catId);
            } catch (Exception e) {
                System.out.println("Invalid categoryId: " + categoryFilter);
            }
        }

        // Search theo keyword
        if (keyword != null && !keyword.trim().isEmpty()) {
            String keywordLower = keyword.toLowerCase().trim();
            System.out.println("Searching with keyword: " + keywordLower);
            
            list = list.stream()
                .filter(eq -> 
                    String.valueOf(eq.getEquipmentId()).contains(keywordLower) ||
                    eq.getSerialNumber().toLowerCase().contains(keywordLower) ||
                    eq.getModel().toLowerCase().contains(keywordLower) ||
                    eq.getDescription().toLowerCase().contains(keywordLower) ||
                    (eq.getCategoryName() != null && eq.getCategoryName().toLowerCase().contains(keywordLower)) ||
                    (eq.getUsername() != null && eq.getUsername().toLowerCase().contains(keywordLower)) ||
                    (eq.getInstallDate() != null && eq.getInstallDate().toString().contains(keywordLower)) ||
                    (eq.getLastUpdatedDate() != null && eq.getLastUpdatedDate().toString().contains(keywordLower))
                )
                .collect(Collectors.toList());
            
            System.out.println("Found " + list.size() + " results");
        }

        // Filter/Sort theo cột
        if (filter != null && !filter.isEmpty()) {
            System.out.println("Filtering by: " + filter);
            switch (filter.toLowerCase()) {
                case "equipmentid": 
                    list.sort(Comparator.comparing(Equipment::getEquipmentId)); 
                    break;
                case "serialnumber": 
                    list.sort(Comparator.comparing(Equipment::getSerialNumber)); 
                    break;
                case "model": 
                    list.sort(Comparator.comparing(Equipment::getModel)); 
                    break;
                case "category":
                    list.sort(Comparator.comparing(eq -> 
                        eq.getCategoryName() != null ? eq.getCategoryName() : ""
                    )); 
                    break;
                case "installdate":
                    list.sort((eq1, eq2) -> {
                        LocalDate date1 = eq1.getInstallDate();
                        LocalDate date2 = eq2.getInstallDate();
                        if (date1 == null && date2 == null) return 0;
                        if (date1 == null) return 1;
                        if (date2 == null) return -1;
                        return date2.compareTo(date1); // DESC order
                    });
                    break;
                case "updateperson": 
                    list.sort(Comparator.comparing(eq -> 
                        eq.getUsername() != null ? eq.getUsername() : ""
                    )); 
                    break;
                case "updatedate": 
                    list.sort(Comparator.comparing(Equipment::getLastUpdatedDate).reversed()); 
                    break;
            }
        }

        // ✅ Load categories cho form
        List<Category> categories = categoryDAO.getCategoriesByType("Equipment");
        request.setAttribute("categories", categories);
        
        request.setAttribute("list", list);
        request.getRequestDispatcher("numberEquipment.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "ListNumberEquipment Servlet - Manages equipment inventory CRUD operations with Category support";
    }
}