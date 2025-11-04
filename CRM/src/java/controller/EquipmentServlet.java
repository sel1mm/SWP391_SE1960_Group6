package controller;

import dal.EquipmentDAO;
import model.Equipment;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet(name = "EquipmentServlet", urlPatterns = {"/equipment"})
public class EquipmentServlet extends HttpServlet {

    private EquipmentDAO equipmentDAO;
    
    private static final int PAGE_SIZE = 3;

    @Override
    public void init() throws ServletException {
        equipmentDAO = new EquipmentDAO();
        System.out.println("✅ EquipmentDAO initialized");
        System.out.println("📄 PAGE_SIZE configured: " + PAGE_SIZE + " thiết bị/trang");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("session_login_id");

        if (customerId == null) {
            System.out.println("❌ Customer not logged in! Redirecting to login...");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        // ✅ XỬ LÝ ACTION LẤY THÔNG TIN SỬA CHỮA
        if ("getRepairInfo".equals(action)) {
            handleGetRepairInfo(request, response);
        } else if ("search".equals(action) || "filter".equals(action)) {
            handleSearchAndFilter(request, response, customerId);
        } else {
            displayAllEquipment(request, response, customerId);
        }
    }

    /**
     * ✅ XỬ LÝ LẤY THÔNG TIN SỬA CHỮA THIẾT BỊ
     */
    private void handleGetRepairInfo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String equipmentIdStr = request.getParameter("equipmentId");
        
        try (PrintWriter out = response.getWriter()) {
            if (equipmentIdStr == null || equipmentIdStr.isEmpty()) {
                out.print("{\"success\": false, \"message\": \"Equipment ID is required\"}");
                return;
            }
            
            int equipmentId = Integer.parseInt(equipmentIdStr);
            System.out.println("🔍 Getting repair info for equipment: " + equipmentId);
            
            // Lấy thông tin sửa chữa từ DAO
            Map<String, Object> repairInfo = equipmentDAO.getEquipmentRepairInfo(equipmentId);
            
            if (repairInfo != null && !repairInfo.isEmpty()) {
                // Tạo JSON string thủ công thay vì dùng JSONObject
                StringBuilder json = new StringBuilder();
                json.append("{\"success\": true, \"repairInfo\": {");
                
                // Escape và format các giá trị
                String technicianName = escapeJsonString((String) repairInfo.get("technicianName"));
                String repairDate = escapeJsonString(String.valueOf(repairInfo.get("repairDate")));
                String diagnosis = escapeJsonString((String) repairInfo.get("diagnosis"));
                String repairDetails = escapeJsonString((String) repairInfo.get("repairDetails"));
                String estimatedCost = escapeJsonString(String.valueOf(repairInfo.get("estimatedCost")));
                String quotationStatus = escapeJsonString((String) repairInfo.get("quotationStatus"));
                
                json.append("\"technicianName\": \"").append(technicianName).append("\",");
                json.append("\"repairDate\": \"").append(repairDate).append("\",");
                json.append("\"diagnosis\": \"").append(diagnosis).append("\",");
                json.append("\"repairDetails\": \"").append(repairDetails).append("\",");
                json.append("\"estimatedCost\": \"").append(estimatedCost).append("\",");
                json.append("\"quotationStatus\": \"").append(quotationStatus).append("\"");
                json.append("}}");
                
                System.out.println("✅ Repair info found: " + repairInfo.get("technicianName"));
                out.print(json.toString());
            } else {
                System.out.println("⚠️ No repair info found for equipment: " + equipmentId);
                out.print("{\"success\": false, \"message\": \"No repair information found\"}");
            }
            
        } catch (NumberFormatException e) {
            System.out.println("❌ Invalid equipment ID: " + equipmentIdStr);
            response.getWriter().print("{\"success\": false, \"message\": \"Invalid equipment ID\"}");
        } catch (Exception e) {
            System.out.println("💥 Error getting repair info: " + e.getMessage());
            e.printStackTrace();
            String errorMsg = escapeJsonString(e.getMessage());
            response.getWriter().print("{\"success\": false, \"message\": \"" + errorMsg + "\"}");
        }
    }
    
    /**
     * Escape JSON string để tránh lỗi format
     */
    private String escapeJsonString(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }

    /**
     * Hiển thị tất cả thiết bị với phân trang
     */
    private void displayAllEquipment(HttpServletRequest request, HttpServletResponse response, int customerId)
            throws ServletException, IOException {

        System.out.println("🚀 displayAllEquipment for customer: " + customerId);

        try {
            // Lấy trang hiện tại
            int currentPage = 1;
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isEmpty()) {
                try {
                    currentPage = Integer.parseInt(pageParam);
                    if (currentPage < 1) currentPage = 1;
                } catch (NumberFormatException e) {
                    currentPage = 1;
                }
            }

            // Lấy danh sách thiết bị
            List<Equipment> allEquipment = equipmentDAO.getEquipmentByCustomerContractsAndAppendix(customerId);
            System.out.println("📦 Total equipment: " + allEquipment.size());

            // Lấy thống kê
            Map<String, Integer> stats = equipmentDAO.getEquipmentStatsByCustomer(customerId);

            // Tạo danh sách với thông tin đầy đủ
            List<EquipmentWithContract> fullList = new ArrayList<>();
            for (Equipment equipment : allEquipment) {
                EquipmentWithContract ewc = new EquipmentWithContract();
                ewc.setEquipment(equipment);
                
                // Sử dụng method mới để lấy thông tin hợp đồng và loại
                EquipmentDAO.EquipmentContractInfo contractInfo = equipmentDAO.getEquipmentContractInfo(
                        equipment.getEquipmentId(), customerId);
                
                if (contractInfo.hasContract()) {
                    ewc.setContractId(contractInfo.getFormattedContractId());
                    ewc.setSourceType(contractInfo.getSource().equals("Contract") ? "Hợp Đồng" : "Phụ Lục");
                } else {
                    ewc.setContractId("N/A");
                    ewc.setSourceType("Không xác định");
                }
                
                String status = equipmentDAO.getEquipmentStatus(equipment.getEquipmentId());
                ewc.setStatus(status);
                
                // ✅ NẾU THIẾT BỊ ĐANG SỬA CHỮA → LẤY THÔNG TIN SỬA CHỮA
                if ("Repair".equals(status)) {
                    try {
                        Map<String, Object> repairInfo = equipmentDAO.getEquipmentRepairInfo(equipment.getEquipmentId());
                        if (repairInfo != null && !repairInfo.isEmpty()) {
                            ewc.setTechnicianName((String) repairInfo.get("technicianName"));
                            ewc.setRepairDate(String.valueOf(repairInfo.get("repairDate")));
                            ewc.setDiagnosis((String) repairInfo.get("diagnosis"));
                            ewc.setRepairDetails((String) repairInfo.get("repairDetails"));
                            ewc.setEstimatedCost(String.valueOf(repairInfo.get("estimatedCost")));
                            ewc.setQuotationStatus((String) repairInfo.get("quotationStatus"));
                            
                            System.out.println("✅ Loaded repair info for equipment " + equipment.getEquipmentId() + 
                                             " - Technician: " + ewc.getTechnicianName());
                        } else {
                            System.out.println("⚠️ No repair info found for equipment " + equipment.getEquipmentId());
                        }
                    } catch (Exception e) {
                        System.out.println("❌ Error loading repair info for equipment " + equipment.getEquipmentId() + ": " + e.getMessage());
                    }
                }
                
                fullList.add(ewc);
            }

            // ============ PHÂN TRANG ============
            int totalItems = fullList.size();
            int totalPages = (totalItems > 0) ? (int) Math.ceil((double) totalItems / PAGE_SIZE) : 0;
            
            // Đảm bảo currentPage hợp lệ
            if (currentPage < 1) {
                currentPage = 1;
            }
            if (currentPage > totalPages && totalPages > 0) {
                currentPage = totalPages;
            }

            int startIndex = (currentPage - 1) * PAGE_SIZE;
            int endIndex = Math.min(startIndex + PAGE_SIZE, totalItems);
            
            List<EquipmentWithContract> paginatedList = new ArrayList<>();
            if (startIndex < totalItems && startIndex >= 0) {
                paginatedList = fullList.subList(startIndex, endIndex);
            }

            System.out.println("📄 Pagination Info:");
            System.out.println("   - Total items: " + totalItems);
            System.out.println("   - Page size: " + PAGE_SIZE);
            System.out.println("   - Total pages: " + totalPages);
            System.out.println("   - Current page: " + currentPage);
            System.out.println("   - Start index: " + startIndex);
            System.out.println("   - End index: " + endIndex);
            System.out.println("   - Items on this page: " + paginatedList.size());
            System.out.println("   - Show pagination: " + (totalPages > 1 ? "YES" : "NO"));

            // Set attributes cho JSP
            request.setAttribute("totalEquipment", stats.get("total"));
            request.setAttribute("activeCount", stats.get("active"));
            request.setAttribute("repairCount", stats.get("repair"));
            request.setAttribute("maintenanceCount", stats.get("maintenance"));
            request.setAttribute("equipmentList", paginatedList);
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalItems", totalItems);
            request.setAttribute("searchMode", false);
            
            System.out.println("✅ Attributes set for JSP:");
            System.out.println("   - equipmentList size: " + paginatedList.size());
            System.out.println("   - currentPage: " + currentPage);
            System.out.println("   - totalPages: " + totalPages);
            System.out.println("   - totalItems: " + totalItems);

            request.getRequestDispatcher("/equipment.jsp").forward(request, response);

        } catch (Exception e) {
            System.out.println("💥 ERROR in displayAllEquipment: " + e.getMessage());
            e.printStackTrace();
            handleError(request, response, "Có lỗi xảy ra khi tải danh sách thiết bị: " + e.getMessage());
        }
    }

    /**
     * Xử lý tìm kiếm và lọc
     */
    private void handleSearchAndFilter(HttpServletRequest request, HttpServletResponse response, int customerId)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        String statusFilter = request.getParameter("status");
        String sortBy = request.getParameter("sortBy");
        
        System.out.println("🔍 Search - Keyword: " + keyword + ", Status: " + statusFilter + ", Sort: " + sortBy);

        try {
            List<Equipment> allEquipment = equipmentDAO.getEquipmentByCustomerContractsAndAppendix(customerId);
            List<EquipmentWithContract> filteredList = new ArrayList<>();

            // Tạo danh sách đầy đủ
            for (Equipment equipment : allEquipment) {
                EquipmentWithContract ewc = new EquipmentWithContract();
                ewc.setEquipment(equipment);
                
                // Sử dụng method mới để lấy thông tin hợp đồng và loại
                EquipmentDAO.EquipmentContractInfo contractInfo = equipmentDAO.getEquipmentContractInfo(
                        equipment.getEquipmentId(), customerId);
                
                if (contractInfo.hasContract()) {
                    ewc.setContractId(contractInfo.getFormattedContractId());
                    ewc.setSourceType(contractInfo.getSource().equals("Contract") ? "Hợp Đồng" : "Phụ Lục");
                } else {
                    ewc.setContractId("N/A");
                    ewc.setSourceType("Không xác định");
                }
                
                String status = equipmentDAO.getEquipmentStatus(equipment.getEquipmentId());
                ewc.setStatus(status);
                
                // ✅ NẾU THIẾT BỊ ĐANG SỬA CHỮA → LẤY THÔNG TIN SỬA CHỮA
                if ("Repair".equals(status)) {
                    try {
                        Map<String, Object> repairInfo = equipmentDAO.getEquipmentRepairInfo(equipment.getEquipmentId());
                        if (repairInfo != null && !repairInfo.isEmpty()) {
                            ewc.setTechnicianName((String) repairInfo.get("technicianName"));
                            ewc.setRepairDate(String.valueOf(repairInfo.get("repairDate")));
                            ewc.setDiagnosis((String) repairInfo.get("diagnosis"));
                            ewc.setRepairDetails((String) repairInfo.get("repairDetails"));
                            ewc.setEstimatedCost(String.valueOf(repairInfo.get("estimatedCost")));
                            ewc.setQuotationStatus((String) repairInfo.get("quotationStatus"));
                        }
                    } catch (Exception e) {
                        System.out.println("❌ Error loading repair info for equipment " + equipment.getEquipmentId() + ": " + e.getMessage());
                    }
                }
                
                filteredList.add(ewc);
            }

            // ============ LỌC KEYWORD ============
            if (keyword != null && !keyword.trim().isEmpty()) {
                String lowerKeyword = keyword.toLowerCase().trim();
                filteredList = filteredList.stream()
                    .filter(ewc -> {
                        Equipment eq = ewc.getEquipment();
                        return (eq.getModel() != null && eq.getModel().toLowerCase().contains(lowerKeyword))
                            || (eq.getSerialNumber() != null && eq.getSerialNumber().toLowerCase().contains(lowerKeyword))
                            || (eq.getDescription() != null && eq.getDescription().toLowerCase().contains(lowerKeyword))
                            || (ewc.getContractId() != null && ewc.getContractId().toLowerCase().contains(lowerKeyword));
                    })
                    .collect(Collectors.toList());
            }

            // ============ LỌC TRẠNG THÁI ============
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                filteredList = filteredList.stream()
                    .filter(ewc -> statusFilter.equals(ewc.getStatus()))
                    .collect(Collectors.toList());
            }

            // ============ SẮP XẾP ============
            if (sortBy == null || sortBy.isEmpty()) {
                sortBy = "newest";
            }

            switch (sortBy) {
                case "oldest":
                    filteredList.sort(Comparator.comparing(ewc -> 
                        ewc.getEquipment().getInstallDate() != null 
                        ? ewc.getEquipment().getInstallDate() 
                        : java.time.LocalDate.MIN));
                    break;
                    
                case "name_asc":
                    filteredList.sort(Comparator.comparing(ewc -> 
                        ewc.getEquipment().getModel() != null 
                        ? ewc.getEquipment().getModel() 
                        : ""));
                    break;
                    
                case "name_desc":
                    filteredList.sort(Comparator.comparing(ewc -> 
                        ewc.getEquipment().getModel() != null 
                        ? ewc.getEquipment().getModel() 
                        : "", Comparator.reverseOrder()));
                    break;
                    
                case "newest":
                default:
                    filteredList.sort(Comparator.comparing(ewc -> 
                        ewc.getEquipment().getInstallDate() != null 
                        ? ewc.getEquipment().getInstallDate() 
                        : java.time.LocalDate.MIN, Comparator.reverseOrder()));
                    break;
            }

            // ============ PHÂN TRANG ============
            int currentPage = 1;
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isEmpty()) {
                try {
                    currentPage = Integer.parseInt(pageParam);
                    if (currentPage < 1) currentPage = 1;
                } catch (NumberFormatException e) {
                    currentPage = 1;
                }
            }

            int totalItems = filteredList.size();
            int totalPages = (totalItems > 0) ? (int) Math.ceil((double) totalItems / PAGE_SIZE) : 0;
            
            // Đảm bảo currentPage hợp lệ
            if (currentPage < 1) {
                currentPage = 1;
            }
            if (currentPage > totalPages && totalPages > 0) {
                currentPage = totalPages;
            }

            int startIndex = (currentPage - 1) * PAGE_SIZE;
            int endIndex = Math.min(startIndex + PAGE_SIZE, totalItems);
            
            List<EquipmentWithContract> paginatedList = new ArrayList<>();
            if (startIndex < totalItems && startIndex >= 0) {
                paginatedList = filteredList.subList(startIndex, endIndex);
            }

            // ============ THỐNG KÊ ============
            int totalCount = filteredList.size();
            int activeCount = (int) filteredList.stream().filter(e -> "Active".equals(e.getStatus())).count();
            int repairCount = (int) filteredList.stream().filter(e -> "Repair".equals(e.getStatus())).count();
            int maintenanceCount = (int) filteredList.stream().filter(e -> "Maintenance".equals(e.getStatus())).count();

            System.out.println("✅ Search/Filter Results:");
            System.out.println("   - Total items found: " + totalItems);
            System.out.println("   - Total pages: " + totalPages);
            System.out.println("   - Current page: " + currentPage);
            System.out.println("   - Items on this page: " + paginatedList.size());
            System.out.println("   - Show pagination: " + (totalPages > 1 ? "YES" : "NO"));

            // Set attributes
            request.setAttribute("totalEquipment", totalCount);
            request.setAttribute("activeCount", activeCount);
            request.setAttribute("repairCount", repairCount);
            request.setAttribute("maintenanceCount", maintenanceCount);
            request.setAttribute("equipmentList", paginatedList);
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalItems", totalItems);
            request.setAttribute("keyword", keyword);
            request.setAttribute("searchMode", true);
            
            System.out.println("✅ Search/Filter Attributes set for JSP:");
            System.out.println("   - equipmentList size: " + paginatedList.size());
            System.out.println("   - currentPage: " + currentPage);
            System.out.println("   - totalPages: " + totalPages);
            System.out.println("   - totalItems: " + totalItems);

            request.getRequestDispatcher("/equipment.jsp").forward(request, response);

        } catch (Exception e) {
            System.out.println("💥 ERROR in handleSearchAndFilter: " + e.getMessage());
            e.printStackTrace();
            handleError(request, response, "Có lỗi xảy ra khi tìm kiếm: " + e.getMessage());
        }
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response, String errorMessage)
            throws ServletException, IOException {
        
        request.setAttribute("error", errorMessage);
        request.setAttribute("totalEquipment", 0);
        request.setAttribute("activeCount", 0);
        request.setAttribute("repairCount", 0);
        request.setAttribute("maintenanceCount", 0);
        request.setAttribute("equipmentList", new ArrayList<>());
        request.setAttribute("currentPage", 1);
        request.setAttribute("totalPages", 0);
        
        request.getRequestDispatcher("/equipment.jsp").forward(request, response);
    }

    /**
     * Inner class để kết hợp Equipment với Contract và Status
     */
    public static class EquipmentWithContract {
        private Equipment equipment;
        private String contractId;
        private String sourceType; // "Hợp Đồng" hoặc "Phụ Lục"
        private String status;
        
        // ✅ THÊM THÔNG TIN SỬA CHỮA
        private String technicianName;
        private String repairDate;
        private String diagnosis;
        private String repairDetails;
        private String estimatedCost;
        private String quotationStatus;

        public Equipment getEquipment() {
            return equipment;
        }

        public void setEquipment(Equipment equipment) {
            this.equipment = equipment;
        }

        public String getContractId() {
            return contractId;
        }

        public void setContractId(String contractId) {
            this.contractId = contractId;
        }

        public String getSourceType() {
            return sourceType;
        }

        public void setSourceType(String sourceType) {
            this.sourceType = sourceType;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        // ✅ GETTER/SETTER CHO THÔNG TIN SỬA CHỮA
        public String getTechnicianName() {
            return technicianName;
        }

        public void setTechnicianName(String technicianName) {
            this.technicianName = technicianName;
        }

        public String getRepairDate() {
            return repairDate;
        }

        public void setRepairDate(String repairDate) {
            this.repairDate = repairDate;
        }

        public String getDiagnosis() {
            return diagnosis;
        }

        public void setDiagnosis(String diagnosis) {
            this.diagnosis = diagnosis;
        }

        public String getRepairDetails() {
            return repairDetails;
        }

        public void setRepairDetails(String repairDetails) {
            this.repairDetails = repairDetails;
        }

        public String getEstimatedCost() {
            return estimatedCost;
        }

        public void setEstimatedCost(String estimatedCost) {
            this.estimatedCost = estimatedCost;
        }

        public String getQuotationStatus() {
            return quotationStatus;
        }

        public void setQuotationStatus(String quotationStatus) {
            this.quotationStatus = quotationStatus;
        }
    }
}