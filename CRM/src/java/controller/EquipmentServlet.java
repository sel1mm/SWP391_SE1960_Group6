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
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet(name = "EquipmentServlet", urlPatterns = {"/equipment"})
public class EquipmentServlet extends HttpServlet {

    private EquipmentDAO equipmentDAO;
    
    private static final int PAGE_SIZE = 10; // ← THAY ĐỔI SỐ NÀY ĐỂ ĐIỀU CHỈNH
    // ============================================

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

        if ("search".equals(action) || "filter".equals(action)) {
            handleSearchAndFilter(request, response, customerId);
        } else {
            displayAllEquipment(request, response, customerId);
        }
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
            List<Equipment> allEquipment = equipmentDAO.getEquipmentByCustomerContracts(customerId);
            System.out.println("📦 Total equipment: " + allEquipment.size());

            // Lấy thống kê
            Map<String, Integer> stats = equipmentDAO.getEquipmentStatsByCustomer(customerId);

            // Tạo danh sách với thông tin đầy đủ
            List<EquipmentWithContract> fullList = new ArrayList<>();
            for (Equipment equipment : allEquipment) {
                EquipmentWithContract ewc = new EquipmentWithContract();
                ewc.setEquipment(equipment);
                
                String contractId = equipmentDAO.getContractIdForEquipment(
                        equipment.getEquipmentId(), customerId);
                ewc.setContractId(contractId != null ? contractId : "N/A");
                
                String status = equipmentDAO.getEquipmentStatus(equipment.getEquipmentId());
                ewc.setStatus(status);
                
                fullList.add(ewc);
            }

            // ============ PHÂN TRANG ============
            int totalItems = fullList.size();
            int totalPages = (int) Math.ceil((double) totalItems / PAGE_SIZE);
            
            // Điều chỉnh currentPage nếu vượt quá totalPages
            if (currentPage > totalPages && totalPages > 0) {
                currentPage = totalPages;
            }

            int startIndex = (currentPage - 1) * PAGE_SIZE;
            int endIndex = Math.min(startIndex + PAGE_SIZE, totalItems);
            
            List<EquipmentWithContract> paginatedList = new ArrayList<>();
            if (startIndex < totalItems) {
                paginatedList = fullList.subList(startIndex, endIndex);
            }

            System.out.println("📄 Pagination Info:");
            System.out.println("   - Total items: " + totalItems);
            System.out.println("   - Page size: " + PAGE_SIZE);
            System.out.println("   - Total pages: " + totalPages);
            System.out.println("   - Current page: " + currentPage);
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
            request.setAttribute("searchMode", false);

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
            List<Equipment> allEquipment = equipmentDAO.getEquipmentByCustomerContracts(customerId);
            List<EquipmentWithContract> filteredList = new ArrayList<>();

            // Tạo danh sách đầy đủ
            for (Equipment equipment : allEquipment) {
                EquipmentWithContract ewc = new EquipmentWithContract();
                ewc.setEquipment(equipment);
                
                String contractId = equipmentDAO.getContractIdForEquipment(
                        equipment.getEquipmentId(), customerId);
                ewc.setContractId(contractId != null ? contractId : "N/A");
                
                String status = equipmentDAO.getEquipmentStatus(equipment.getEquipmentId());
                ewc.setStatus(status);
                
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
            int totalPages = (int) Math.ceil((double) totalItems / PAGE_SIZE);
            
            if (currentPage > totalPages && totalPages > 0) {
                currentPage = totalPages;
            }

            int startIndex = (currentPage - 1) * PAGE_SIZE;
            int endIndex = Math.min(startIndex + PAGE_SIZE, totalItems);
            
            List<EquipmentWithContract> paginatedList = new ArrayList<>();
            if (startIndex < totalItems) {
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
            request.setAttribute("keyword", keyword);
            request.setAttribute("searchMode", true);

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
        private String status;

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

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }
    }
}