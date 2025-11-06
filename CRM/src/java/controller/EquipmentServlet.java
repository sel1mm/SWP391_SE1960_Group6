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
import java.util.List;
import java.util.stream.Collectors;
import java.util.Comparator;
import model.Account;
import model.Category;
import model.Equipment;

/**
 * ListNumberEquipmentServlet - Quản lý danh sách thiết bị với Grouped View
 * Updated: Support search, filter by category, sort by ID
 * @author Admin
 */

public class EquipmentServlet extends HttpServlet {
    
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

        String action = request.getParameter("action");
        
        // ===== XỬ LÝ AJAX REQUEST - GET DETAIL BY MODEL =====
        if ("getDetailByModel".equals(action)) {
            handleGetDetailByModel(request, response);
            return;
        }

        // ===== GET FILTER PARAMETERS =====
        String searchKeyword = request.getParameter("search");
        String categoryFilter = request.getParameter("categoryFilter");
        String sortById = request.getParameter("sortById");
        
        // ===== LOAD GROUPED EQUIPMENT LIST =====
        List<Equipment> groupedList = dao.getEquipmentGroupedByModel();
        
        // ===== APPLY SEARCH FILTER =====
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            final String keyword = searchKeyword.trim().toLowerCase();
            groupedList = groupedList.stream()
                .filter(eq -> 
                    (eq.getModel() != null && eq.getModel().toLowerCase().contains(keyword)) ||
                    (eq.getDescription() != null && eq.getDescription().toLowerCase().contains(keyword))
                )
                .collect(Collectors.toList());
        }
        
        // ===== APPLY CATEGORY FILTER =====
        if (categoryFilter != null && !categoryFilter.trim().isEmpty() && !categoryFilter.equals("all")) {
            try {
                final int catId = Integer.parseInt(categoryFilter);
                groupedList = groupedList.stream()
                    .filter(eq -> eq.getCategoryId() == catId)
                    .collect(Collectors.toList());
            } catch (NumberFormatException e) {
                // Ignore invalid category ID
            }
        }
        
        // ===== APPLY SORT BY ID =====
        if (sortById != null && !sortById.trim().isEmpty()) {
            if ("asc".equals(sortById)) {
                groupedList.sort(Comparator.comparingInt(Equipment::getEquipmentId));
            } else if ("desc".equals(sortById)) {
                groupedList.sort(Comparator.comparingInt(Equipment::getEquipmentId).reversed());
            }
        }
        
        List<Category> categories = categoryDAO.getCategoriesByType("Equipment");
        
        request.setAttribute("groupedList", groupedList);
        request.setAttribute("categories", categories);
        
        // Preserve filter values
        request.setAttribute("searchKeyword", searchKeyword);
        request.setAttribute("categoryFilter", categoryFilter);
        request.setAttribute("sortById", sortById);
        
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
            out.print("\"categoryId\":" + eq.getCategoryId());
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
            
            if ("existing".equals(addMode)) {
                String selectedModel = request.getParameter("selectedModel");
                
                if (selectedModel == null || selectedModel.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "❌ Vui lòng chọn Model!");
                    response.sendRedirect("numberEquipment");
                    return;
                }
                
                Equipment modelTemplate = dao.getEquipmentGroupedByModelSingle(selectedModel.trim());
                if (modelTemplate == null) {
                    session.setAttribute("errorMessage", "❌ Không tìm thấy Model!");
                    response.sendRedirect("numberEquipment");
                    return;
                }
                
                equipment.setModel(modelTemplate.getModel());
                equipment.setDescription(modelTemplate.getDescription());
                
                if (modelTemplate.getCategoryId() > 0) {
                    equipment.setCategoryId(modelTemplate.getCategoryId());
                } else {
                    equipment.setCategoryId(-1);
                }
                
                System.out.println("Using existing model: " + selectedModel);
            } else {
                String model = request.getParameter("model");
                String description = request.getParameter("description");
                String categoryIdStr = request.getParameter("categoryId");
                
                System.out.println("Model: " + model);
                System.out.println("Description: " + description);
                System.out.println("CategoryId: " + categoryIdStr);
                
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
                
                Equipment existingModel = dao.getEquipmentGroupedByModelSingle(model.trim());
                if (existingModel != null) {
                    session.setAttribute("errorMessage", "❌ Model '" + model.trim() + "' đã tồn tại! Vui lòng chọn 'Thêm thiết bị (Model có sẵn)' hoặc đặt tên Model khác.");
                    response.sendRedirect("numberEquipment");
                    return;
                }
                System.out.println("✅ Model validation passed - Model is unique");
                
                equipment.setModel(model.trim());
                equipment.setDescription(description.trim());
                
                if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
                    equipment.setCategoryId(Integer.parseInt(categoryIdStr));
                } else {
                    equipment.setCategoryId(-1);
                }
                
                System.out.println("Creating new model: " + model);
            }
            
            System.out.println("Calling DAO to add equipment...");
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
            System.out.println("New SerialNumber: " + serialNumber);
            System.out.println("New InstallDate: " + installDateStr);
            
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
        return "ListNumberEquipment Servlet - Manages equipment with search and filter";
    }
}