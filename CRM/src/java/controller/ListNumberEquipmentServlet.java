package controller;

import dal.CategoryDAO;
import dal.EquipmentDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;
import model.Account;
import model.Category;
import model.Equipment;

/**
 * ListNumberEquipmentServlet - Quản lý danh sách thiết bị với Grouped View và Pagination
 * Fixed: Filter, Search, Pagination, và Add Mode
 */
@WebServlet(name = "ListNumberEquipmentServlet", urlPatterns = {"/numberEquipment"})
public class ListNumberEquipmentServlet extends HttpServlet {
    
    private EquipmentDAO dao = new EquipmentDAO();
    private CategoryDAO categoryDAO = new CategoryDAO();
    private static final int RECORDS_PER_PAGE = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // ===== LOAD USED EQUIPMENT IDS =====
Set<Integer> usedEquipmentIds = dao.getUsedEquipmentIds();
request.setAttribute("usedEquipmentIds", usedEquipmentIds);
        // Kiểm tra đăng nhập
        HttpSession session = request.getSession();
        Account acc = (Account) session.getAttribute("session_login");
        if (acc == null) {
            response.sendRedirect("login");
            return;
        }

        String action = request.getParameter("action");
        
        // ===== XỬ LÝ AJAX REQUEST - GET DETAIL BY MODEL =====
        if ("getDetailByModel".equals(action)) {
            handleGetDetailByModel(request, response);
            return;
        }

        // ===== LẤY CÁC THAM SỐ FILTER =====
        String searchKeyword = request.getParameter("search");
        String categoryFilter = request.getParameter("categoryFilter");
        String sortByName = request.getParameter("sortByName");
        
        System.out.println("=== FILTER PARAMETERS ===");
        System.out.println("Search: " + searchKeyword);
        System.out.println("Category Filter: " + categoryFilter);
        System.out.println("Sort by Name: " + sortByName);

        // ===== LOAD TẤT CẢ GROUPED EQUIPMENT LIST =====
        List<Equipment> allGroupedList = dao.getEquipmentGroupedByModel();
        System.out.println("Total grouped items before filter: " + allGroupedList.size());
        
        // ===== APPLY SEARCH FILTER =====
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            String keyword = searchKeyword.trim().toLowerCase();
            allGroupedList = allGroupedList.stream()
                .filter(eq -> 
                    (eq.getModel() != null && eq.getModel().toLowerCase().contains(keyword)) ||
                    (eq.getDescription() != null && eq.getDescription().toLowerCase().contains(keyword))
                )
                .collect(Collectors.toList());
            System.out.println("After search filter: " + allGroupedList.size() + " items");
        }
        
        // ===== APPLY CATEGORY FILTER =====
        if (categoryFilter != null && !categoryFilter.trim().isEmpty()) {
            try {
                int catId = Integer.parseInt(categoryFilter);
                allGroupedList = allGroupedList.stream()
                    .filter(eq -> {
                        Integer equipCatId = eq.getCategoryId();
                        return equipCatId != null && equipCatId == catId;
                    })
                    .collect(Collectors.toList());
                System.out.println("After category filter: " + allGroupedList.size() + " items");
            } catch (NumberFormatException e) {
                System.out.println("Invalid category ID: " + categoryFilter);
            }
        }
        
        // ===== APPLY SORT BY NAME =====
        if (sortByName != null && !sortByName.trim().isEmpty()) {
            if ("asc".equals(sortByName)) {
                allGroupedList.sort(Comparator.comparing(eq -> eq.getModel() != null ? eq.getModel().toLowerCase() : ""));
                System.out.println("Sorted by Name ascending");
            } else if ("desc".equals(sortByName)) {
                allGroupedList.sort(Comparator.comparing((Equipment eq) -> eq.getModel() != null ? eq.getModel().toLowerCase() : "").reversed());
                System.out.println("Sorted by Name descending");
            }
        }
        
        int totalRecords = allGroupedList.size();
        System.out.println("Total records after filtering: " + totalRecords);
        
        // ===== PAGINATION LOGIC =====
        int currentPage = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageParam);
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }
        
        int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);
        if (totalPages == 0) totalPages = 1;
        if (currentPage < 1) currentPage = 1;
        if (currentPage > totalPages) currentPage = totalPages;
        
        int startIndex = (currentPage - 1) * RECORDS_PER_PAGE;
        int endIndex = Math.min(startIndex + RECORDS_PER_PAGE, totalRecords);
        
        List<Equipment> groupedList = new ArrayList<>();
        if (totalRecords > 0) {
            groupedList = allGroupedList.subList(startIndex, endIndex);
        }
        
        System.out.println("Pagination: Page " + currentPage + "/" + totalPages);
        System.out.println("Displaying records: " + startIndex + " to " + endIndex);
        
        // ===== CALCULATE PAGE RANGE FOR DISPLAY =====
        int startPage = Math.max(1, currentPage - 2);
        int endPage = Math.min(totalPages, currentPage + 2);
        
        // ===== LOAD CATEGORIES =====
        List<Category> categories = categoryDAO.getCategoriesByType("Equipment");
        
        // ===== LOAD ALL UNIQUE MODELS (không filter) cho dropdown =====
        List<Equipment> allModelsRaw = dao.getEquipmentGroupedByModel();
        List<String> allModels = allModelsRaw.stream()
            .map(Equipment::getModel)
            .distinct()
            .sorted()
            .collect(Collectors.toList());
        
        // ===== SET ATTRIBUTES =====
        request.setAttribute("groupedList", groupedList);
        request.setAttribute("categories", categories);
        request.setAttribute("allModels", allModels);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("startPage", startPage);
        request.setAttribute("endPage", endPage);
        
        // Forward về JSP
        request.getRequestDispatcher("numberEquipment.jsp").forward(request, response);
    }

    /**
     * Xử lý AJAX request để lấy chi tiết equipment theo model
     */
  private void handleGetDetailByModel(HttpServletRequest request, HttpServletResponse response)
        throws IOException {
    String model = request.getParameter("model");
    
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    EquipmentDAO dao = new EquipmentDAO();
    List<Equipment> equipmentList = dao.getEquipmentByModel(model);
    
    // ✅ LẤY DANH SÁCH EQUIPMENT ĐÃ DÙNG
    Set<Integer> usedEquipmentIds = dao.getUsedEquipmentIds();
    
    // Convert to JSON
    PrintWriter out = response.getWriter();
    out.print("[");
    for (int i = 0; i < equipmentList.size(); i++) {
        Equipment eq = equipmentList.get(i);
        if (i > 0) out.print(",");
        out.print("{");
        out.print("\"equipmentId\":" + eq.getEquipmentId() + ",");
        out.print("\"serialNumber\":\"" + escapeJson(eq.getSerialNumber()) + "\",");
        out.print("\"model\":\"" + escapeJson(eq.getModel()) + "\",");
        out.print("\"categoryName\":\"" + escapeJson(eq.getCategoryName()) + "\",");
        out.print("\"description\":\"" + escapeJson(eq.getDescription()) + "\",");
        out.print("\"installDate\":\"" + (eq.getInstallDate() != null ? eq.getInstallDate().toString() : "") + "\",");
        out.print("\"username\":\"" + escapeJson(eq.getUsername()) + "\",");
        out.print("\"lastUpdatedDate\":\"" + (eq.getLastUpdatedDate() != null ? eq.getLastUpdatedDate().toString() : "") + "\",");
        out.print("\"categoryId\":" + eq.getCategoryId() + ",");
        // ✅ THÊM FLAG isUsed
        out.print("\"isUsed\":" + usedEquipmentIds.contains(eq.getEquipmentId()));
        out.print("}");
    }
    out.print("]");
}
    
    /**
     * Helper method để escape JSON string
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
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
            handleAddEquipment(request, response, acc, session);
            return;
        }

        // ===== XỬ LÝ EDIT =====
        if ("edit".equalsIgnoreCase(action)) {
            handleEditEquipment(request, response, acc, session);
            return;
        }

        // ===== XỬ LÝ DELETE =====
        if ("delete".equalsIgnoreCase(action)) {
            handleDeleteEquipment(request, response, session);
            return;
        }

        // Default: redirect về trang chính
        response.sendRedirect("numberEquipment");
    }

    /**
     * Xử lý thêm equipment mới
     */
    private void handleAddEquipment(HttpServletRequest request, HttpServletResponse response, 
                                   Account acc, HttpSession session) throws IOException {
        try {
            System.out.println("=== START ADD EQUIPMENT ===");
            
            String addMode = request.getParameter("addMode");
            String serialNumber = request.getParameter("serialNumber");
            String installDateStr = request.getParameter("installDate");
            
            System.out.println("Add Mode: " + addMode);
            System.out.println("SerialNumber: " + serialNumber);
            System.out.println("InstallDate: " + installDateStr);
            
            // Validate required fields
            if (serialNumber == null || installDateStr == null || serialNumber.trim().isEmpty()) {
                session.setAttribute("errorMessage", "❌ Vui lòng điền đầy đủ thông tin!");
                response.sendRedirect("numberEquipment");
                return;
            }
            
            // Validate Serial Number
            if (serialNumber.trim().length() < 3 || serialNumber.trim().length() > 30) {
                session.setAttribute("errorMessage", "❌ Serial Number phải từ 3-30 ký tự!");
                response.sendRedirect("numberEquipment");
                return;
            }
            
            // Check duplicate Serial Number
            Equipment existingEquipment = dao.findBySerialNumber(serialNumber.trim());
            if (existingEquipment != null) {
                session.setAttribute("errorMessage", "❌ Serial Number đã tồn tại!");
                response.sendRedirect("numberEquipment");
                return;
            }

            LocalDate installDate = LocalDate.parse(installDateStr);
            Equipment equipment = new Equipment();
            equipment.setSerialNumber(serialNumber.trim());
            equipment.setInstallDate(installDate);
            equipment.setLastUpdatedBy(acc.getAccountId());
            equipment.setLastUpdatedDate(LocalDate.now());
            
            // ===== MODE: EXISTING MODEL =====
            if ("existing".equals(addMode)) {
                String selectedModel = request.getParameter("selectedModel");
                System.out.println("Selected Model from form: " + selectedModel);
                
                if (selectedModel == null || selectedModel.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "❌ Vui lòng chọn Model!");
                    response.sendRedirect("numberEquipment");
                    return;
                }
                
                // Lấy tất cả equipment có model này
                List<Equipment> existingModels = dao.getEquipmentByModel(selectedModel.trim());
                
                if (existingModels == null || existingModels.isEmpty()) {
                    session.setAttribute("errorMessage", "❌ Không tìm thấy Model: " + selectedModel);
                    response.sendRedirect("numberEquipment");
                    return;
                }
                
                // Lấy thông tin từ equipment đầu tiên (vì cùng model thì thông tin giống nhau)
                Equipment modelTemplate = existingModels.get(0);
                
                equipment.setModel(modelTemplate.getModel());
                equipment.setDescription(modelTemplate.getDescription());
                
                Integer catId = modelTemplate.getCategoryId();
                if (catId != null && catId > 0) {
                    equipment.setCategoryId(catId);
                } else {
                    equipment.setCategoryId(null);
                }
                
                System.out.println("Using existing model: " + selectedModel);
                System.out.println("Template - Model: " + modelTemplate.getModel());
                System.out.println("Template - Description: " + modelTemplate.getDescription());
                System.out.println("Template - CategoryId: " + modelTemplate.getCategoryId());
            }
            // ===== MODE: NEW MODEL =====
            else {
                String model = request.getParameter("model");
                String description = request.getParameter("description");
                String categoryIdStr = request.getParameter("categoryId");
                
                System.out.println("Model: " + model);
                System.out.println("Description: " + description);
                System.out.println("CategoryId: " + categoryIdStr);
                
                // Validate
                if (model == null || description == null || model.trim().isEmpty() || description.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "❌ Vui lòng điền đầy đủ thông tin!");
                    response.sendRedirect("numberEquipment");
                    return;
                }
                
                if (model.trim().length() < 3) {
                    session.setAttribute("errorMessage", "❌ Model phải có ít nhất 3 ký tự!");
                    response.sendRedirect("numberEquipment");
                    return;
                }
                
                if (description.trim().length() < 10 || description.trim().length() > 100) {
                    session.setAttribute("errorMessage", "❌ Mô tả phải từ 10-100 ký tự!");
                    response.sendRedirect("numberEquipment");
                    return;
                }
                
                // Check duplicate model
                List<Equipment> existingModel = dao.getEquipmentByModel(model.trim());
                if (existingModel != null && !existingModel.isEmpty()) {
                    session.setAttribute("errorMessage", "❌ Model '" + model.trim() + "' đã tồn tại!");
                    response.sendRedirect("numberEquipment");
                    return;
                }
                
                equipment.setModel(model.trim());
                equipment.setDescription(description.trim());
                
                if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
                    equipment.setCategoryId(Integer.parseInt(categoryIdStr));
                } else {
                    equipment.setCategoryId(null);
                }
                
                System.out.println("Creating new model: " + model);
            }
            
            boolean success = dao.insertEquipment(equipment);
            
            if (success) {
                System.out.println("✅ Add equipment successful!");
                session.setAttribute("successMessage", "✅ Thêm Equipment thành công!");
            } else {
                System.out.println("❌ Add equipment failed!");
                session.setAttribute("errorMessage", "❌ Thêm Equipment thất bại!");
            }
            
            response.sendRedirect("numberEquipment");
            
        } catch (Exception e) {
            System.out.println("❌ Unexpected error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "❌ Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect("numberEquipment");
        }
    }

    /**
     * Xử lý cập nhật equipment
     */
    private void handleEditEquipment(HttpServletRequest request, HttpServletResponse response, 
                                    Account acc, HttpSession session) throws IOException {
        try {
            System.out.println("=== START EDIT EQUIPMENT ===");
            
            int equipmentId = Integer.parseInt(request.getParameter("equipmentId"));
            String serialNumber = request.getParameter("serialNumber");
            String installDateStr = request.getParameter("installDate");
            
            Equipment oldEquipment = dao.findById(equipmentId);
            if (oldEquipment == null) {
                session.setAttribute("errorMessage", "❌ Không tìm thấy Equipment!");
                response.sendRedirect("numberEquipment");
                return;
            }
            
            System.out.println("Editing EquipmentId: " + equipmentId);
            
            // Validate
            if (serialNumber == null || installDateStr == null || serialNumber.trim().isEmpty()) {
                session.setAttribute("errorMessage", "❌ Vui lòng điền đầy đủ thông tin!");
                response.sendRedirect("numberEquipment");
                return;
            }
            
            if (serialNumber.trim().length() < 3 || serialNumber.trim().length() > 30) {
                session.setAttribute("errorMessage", "❌ Serial Number phải từ 3-30 ký tự!");
                response.sendRedirect("numberEquipment");
                return;
            }
            
            // Check duplicate
            Equipment existingEquipment = dao.findBySerialNumber(serialNumber.trim());
            if (existingEquipment != null && existingEquipment.getEquipmentId() != equipmentId) {
                session.setAttribute("errorMessage", "❌ Serial Number đã tồn tại!");
                response.sendRedirect("numberEquipment");
                return;
            }
            
            LocalDate installDate = LocalDate.parse(installDateStr);
            
            Equipment equipment = new Equipment();
            equipment.setEquipmentId(equipmentId);
            equipment.setSerialNumber(serialNumber.trim());
            equipment.setInstallDate(installDate);
            equipment.setModel(oldEquipment.getModel());
            equipment.setDescription(oldEquipment.getDescription());
            equipment.setCategoryId(oldEquipment.getCategoryId());
            equipment.setLastUpdatedBy(acc.getAccountId());
            equipment.setLastUpdatedDate(LocalDate.now());
            
            boolean success = dao.updateEquipment(equipment);
            
            if (success) {
                System.out.println("✅ Edit equipment successful!");
                session.setAttribute("successMessage", "✅ Cập nhật Equipment thành công!");
            } else {
                System.out.println("❌ Edit equipment failed!");
                session.setAttribute("errorMessage", "❌ Cập nhật Equipment thất bại!");
            }
            
            response.sendRedirect("numberEquipment");
            
        } catch (Exception e) {
            System.out.println("❌ Unexpected error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "❌ Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect("numberEquipment");
        }
    }

    /**
     * Xử lý xóa equipment
     */
    private void handleDeleteEquipment(HttpServletRequest request, HttpServletResponse response, 
                                      HttpSession session) throws IOException {
        try {
            System.out.println("=== START DELETE EQUIPMENT ===");
            
            int equipmentId = Integer.parseInt(request.getParameter("equipmentId"));
            System.out.println("Deleting EquipmentId: " + equipmentId);
            
            boolean success = dao.deleteEquipment(equipmentId);
            
            if (success) {
                System.out.println("✅ Delete equipment successful!");
                session.setAttribute("successMessage", "✅ Xóa Equipment thành công!");
            } else {
                System.out.println("❌ Delete equipment failed!");
                session.setAttribute("errorMessage", "❌ Xóa Equipment thất bại!");
            }
            
            response.sendRedirect("numberEquipment");
            
        } catch (Exception e) {
            System.out.println("❌ Unexpected error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "❌ Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect("numberEquipment");
        }
    }

    @Override
    public String getServletInfo() {
        return "ListNumberEquipment Servlet - with pagination, filter, search and sort support";
    }
}