//package controller;
//
//import dal.EquipmentDAO;
//import model.Equipment;
//import jakarta.servlet.ServletException;
//import jakarta.servlet.annotation.WebServlet;
//import jakarta.servlet.http.HttpServlet;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//import jakarta.servlet.http.HttpSession;
//import java.io.IOException;
//import java.util.ArrayList;
//import java.util.Enumeration;
//import java.util.List;
//import java.util.Map;
//
//@WebServlet(name = "EquipmentServlet", urlPatterns = {"/equipment"})
//public class EquipmentServlet extends HttpServlet {
//
//    private EquipmentDAO equipmentDAO;
//
//    @Override
//    public void init() throws ServletException {
//        equipmentDAO = new EquipmentDAO();
//        System.out.println("✅ EquipmentDAO initialized");
//    }
//
//    @Override
//    protected void doGet(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//
//        request.setCharacterEncoding("UTF-8");
//        response.setCharacterEncoding("UTF-8");
//
//        HttpSession session = request.getSession();
//
//        //  🔍 DEBUG: Print all session attributes
//        System.out.println("========== EQUIPMENT SERVLET DEBUG ==========");
//        System.out.println("📋 All Session Attributes:");
//        Enumeration<String> attrs = session.getAttributeNames();
//        while (attrs.hasMoreElements()) {
//            String attr = attrs.nextElement();
//            System.out.println("   " + attr + " = " + session.getAttribute(attr));
//        }
//
//        Integer customerId = (Integer) session.getAttribute("session_login_id");
//        System.out.println("🔢 Customer ID from session: " + customerId);
//
//        // Kiểm tra đăng nhập
//        if (customerId == null) {
//            System.out.println("❌ Customer not logged in! Redirecting to login...");
//            String targetUrl = request.getRequestURI();
//            String queryString = request.getQueryString();
//            if (queryString != null) {
//                targetUrl += "?" + queryString;
//            }
//            session.setAttribute("targetUrl", targetUrl);
//            response.sendRedirect(request.getContextPath() + "/login");
//            return;
//        }
//
//        System.out.println("✅ Customer logged in successfully: " + customerId);
//        System.out.println("=============================================");
//
//        String action = request.getParameter("action");
//
//        if ("search".equals(action)) {
//            handleSearch(request, response, customerId);
//        } else {
//            displayAllEquipment(request, response, customerId);
//        }
//    }
//
//    /**
//     * Hiển thị tất cả thiết bị của customer
//     */
//    private void displayAllEquipment(HttpServletRequest request, HttpServletResponse response, int customerId)
//            throws ServletException, IOException {
//
//        System.out.println("🚀 Starting displayAllEquipment for customer: " + customerId);
//
//        try {
//            // Lấy danh sách thiết bị của customer từ các hợp đồng
//            List<Equipment> equipmentList = equipmentDAO.getEquipmentByCustomerContracts(customerId);
//            System.out.println("📦 Equipment list size: " + equipmentList.size());
//
//            // ✅ THÊM DEBUG CHO TỪNG EQUIPMENT
//            System.out.println("========== EQUIPMENT DETAILS ==========");
//            for (Equipment eq : equipmentList) {
//                System.out.println("Equipment ID: " + eq.getEquipmentId());
//                System.out.println("  Model: " + eq.getModel());
//                System.out.println("  Serial: " + eq.getSerialNumber());
//                System.out.println("  Description: " + eq.getDescription());
//                System.out.println("  Install Date: " + eq.getInstallDate());
//                System.out.println("  Last Updated: " + eq.getLastUpdatedDate());
//                System.out.println("  Last Updated By: " + eq.getLastUpdatedBy());
//                System.out.println("--------------------------------------");
//            }
//            System.out.println("=========================================");
//
//            // Lấy thống kê thiết bị
//            Map<String, Integer> stats = equipmentDAO.getEquipmentStatsByCustomer(customerId);
//            System.out.println("📊 Stats: " + stats);
//
//            // Thêm thông tin hợp đồng và trạng thái cho mỗi thiết bị
//            List<EquipmentWithContract> equipmentWithContracts = new ArrayList<>();
//            for (Equipment equipment : equipmentList) {
//                System.out.println("🔧 Processing equipment: " + equipment.getEquipmentId() + " - " + equipment.getModel());
//
//                EquipmentWithContract ewc = new EquipmentWithContract();
//                ewc.setEquipment(equipment);
//
//                // Lấy thông tin hợp đồng liên quan
//                String contractId = equipmentDAO.getContractIdForEquipment(
//                        equipment.getEquipmentId(), customerId);
//                System.out.println("   📄 Contract ID: " + contractId);
//                ewc.setContractId(contractId != null ? contractId : "N/A");
//
//                // Lấy trạng thái thiết bị
//                String status = equipmentDAO.getEquipmentStatus(equipment.getEquipmentId());
//                System.out.println("   🔴 Status: " + status);
//                ewc.setStatus(status);
//
//                equipmentWithContracts.add(ewc);
//            }
//
//            System.out.println("✅ Final list size: " + equipmentWithContracts.size());
//
//            // Set attributes
//            request.setAttribute("totalEquipment", stats.get("total"));
//            request.setAttribute("activeCount", stats.get("active"));
//            request.setAttribute("repairCount", stats.get("repair"));
//            request.setAttribute("maintenanceCount", stats.get("maintenance"));
//            request.setAttribute("equipmentList", equipmentWithContracts);
//
//            System.out.println("🎯 Forwarding to equipment.jsp...");
//            request.getRequestDispatcher("/equipment.jsp").forward(request, response);
//
//        } catch (Exception e) {
//            System.out.println("💥 ERROR in displayAllEquipment: " + e.getMessage());
//            e.printStackTrace();
//
//            request.setAttribute("error", "Có lỗi xảy ra khi tải danh sách thiết bị: " + e.getMessage());
//            request.setAttribute("totalEquipment", 0);
//            request.setAttribute("activeCount", 0);
//            request.setAttribute("repairCount", 0);
//            request.setAttribute("maintenanceCount", 0);
//            request.setAttribute("equipmentList", new ArrayList<>());
//
//            request.getRequestDispatcher("/equipment.jsp").forward(request, response);
//        }
//    }
//
//    /**
//     * Tìm kiếm thiết bị
//     */
//    private void handleSearch(HttpServletRequest request, HttpServletResponse response, int customerId)
//            throws ServletException, IOException {
//
//        String keyword = request.getParameter("keyword");
//        System.out.println("🔍 Search keyword: " + keyword);
//
//        try {
//            List<Equipment> allEquipment = equipmentDAO.getEquipmentByCustomerContracts(customerId);
//            List<EquipmentWithContract> filteredList = new ArrayList<>();
//
//            // Lọc theo keyword
//            if (keyword != null && !keyword.trim().isEmpty()) {
//                String lowerKeyword = keyword.toLowerCase().trim();
//
//                for (Equipment equipment : allEquipment) {
//                    boolean match = false;
//
//                    if (equipment.getModel() != null
//                            && equipment.getModel().toLowerCase().contains(lowerKeyword)) {
//                        match = true;
//                    }
//                    if (equipment.getSerialNumber() != null
//                            && equipment.getSerialNumber().toLowerCase().contains(lowerKeyword)) {
//                        match = true;
//                    }
//                    if (equipment.getDescription() != null
//                            && equipment.getDescription().toLowerCase().contains(lowerKeyword)) {
//                        match = true;
//                    }
//
//                    if (match) {
//                        EquipmentWithContract ewc = new EquipmentWithContract();
//                        ewc.setEquipment(equipment);
//
//                        String contractId = equipmentDAO.getContractIdForEquipment(
//                                equipment.getEquipmentId(), customerId);
//                        ewc.setContractId(contractId != null ? contractId : "N/A");
//
//                        String status = equipmentDAO.getEquipmentStatus(equipment.getEquipmentId());
//                        ewc.setStatus(status);
//
//                        filteredList.add(ewc);
//                    }
//                }
//            } else {
//                // Nếu không có keyword, hiển thị tất cả
//                for (Equipment equipment : allEquipment) {
//                    EquipmentWithContract ewc = new EquipmentWithContract();
//                    ewc.setEquipment(equipment);
//
//                    String contractId = equipmentDAO.getContractIdForEquipment(
//                            equipment.getEquipmentId(), customerId);
//                    ewc.setContractId(contractId != null ? contractId : "N/A");
//
//                    String status = equipmentDAO.getEquipmentStatus(equipment.getEquipmentId());
//                    ewc.setStatus(status);
//
//                    filteredList.add(ewc);
//                }
//            }
//
//            System.out.println("✅ Search results: " + filteredList.size() + " items");
//
//            // Tính lại thống kê cho kết quả tìm kiếm
//            int totalCount = filteredList.size();
//            int activeCount = 0, repairCount = 0, maintenanceCount = 0;
//
//            for (EquipmentWithContract ewc : filteredList) {
//                String status = ewc.getStatus();
//                if ("Active".equals(status)) {
//                    activeCount++;
//                } else if ("Repair".equals(status)) {
//                    repairCount++;
//                } else if ("Maintenance".equals(status)) {
//                    maintenanceCount++;
//                }
//            }
//
//            request.setAttribute("totalEquipment", totalCount);
//            request.setAttribute("activeCount", activeCount);
//            request.setAttribute("repairCount", repairCount);
//            request.setAttribute("maintenanceCount", maintenanceCount);
//            request.setAttribute("equipmentList", filteredList);
//            request.setAttribute("keyword", keyword);
//            request.setAttribute("searchMode", true);
//
//            request.getRequestDispatcher("/equipment.jsp").forward(request, response);
//
//        } catch (Exception e) {
//            System.out.println("💥 ERROR in handleSearch: " + e.getMessage());
//            e.printStackTrace();
//
//            request.setAttribute("error", "Có lỗi xảy ra khi tìm kiếm: " + e.getMessage());
//
//            // Set default stats in case of error
//            request.setAttribute("totalEquipment", 0);
//            request.setAttribute("activeCount", 0);
//            request.setAttribute("repairCount", 0);
//            request.setAttribute("maintenanceCount", 0);
//            request.setAttribute("equipmentList", new ArrayList<>());
//            request.setAttribute("keyword", keyword);
//            request.setAttribute("searchMode", true);
//
//            request.getRequestDispatcher("/equipment.jsp").forward(request, response);
//        }
//    }
//
//    /**
//     * Inner class để kết hợp Equipment với Contract info và Status
//     */
//    public static class EquipmentWithContract {
//
//        private Equipment equipment;
//        private String contractId;
//        private String status; // Active, Repair, Maintenance
//
//        public Equipment getEquipment() {
//            return equipment;
//        }
//
//        public void setEquipment(Equipment equipment) {
//            this.equipment = equipment;
//        }
//
//        public String getContractId() {
//            return contractId;
//        }
//
//        public void setContractId(String contractId) {
//            this.contractId = contractId;
//        }
//
//        public String getStatus() {
//            return status;
//        }
//
//        public void setStatus(String status) {
//            this.status = status;
//        }
//    }
//}
