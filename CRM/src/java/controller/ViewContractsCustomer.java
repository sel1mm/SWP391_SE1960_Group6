package controller;

import dal.ContractDAO;
import dal.ContractAppendixDAO;
import dal.ServiceRequestDAO;
import model.Account;
import model.Contract;
import model.ContractAppendix;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Collections;
import java.util.Comparator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.google.gson.Gson;

/**
 * Servlet for Customer to view their contracts and related information
 */
@WebServlet(name = "ViewContractsCustomer", urlPatterns = {"/viewcontracts"})
public class ViewContractsCustomer extends HttpServlet {

    private ContractDAO contractDAO;
    private ContractAppendixDAO appendixDAO;
    private ServiceRequestDAO serviceRequestDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        super.init();
        contractDAO = new ContractDAO();
        appendixDAO = new ContractAppendixDAO();
        serviceRequestDAO = new ServiceRequestDAO();
        gson = new Gson();
    }

    /**
     * Handles the HTTP <code>GET</code> method - Display contracts list with
     * filters or handle API requests
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        String servletPath = request.getServletPath();

        // Handle API requests
        if (servletPath.equals("/getContractEquipment")) {
            handleGetContractEquipment(request, response);
            return;
        } else if (servletPath.equals("/getContractRequests")) {
            handleGetContractRequests(request, response);
            return;
        } else if (servletPath.equals("/getContractAppendix")) {
            handleGetContractAppendix(request, response);
            return;
        } else if (servletPath.equals("/getAppendixEquipment")) {
            handleGetAppendixEquipment(request, response);
            return;
        }

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Account customer = (Account) session.getAttribute("session_login");

        // Kiểm tra đăng nhập
        if (customer == null) {
            System.out.println("ERROR ViewContractsCustomer: No customer in session, redirecting to login");
            response.sendRedirect("login.jsp");
            return;
        }

        System.out.println("=== ViewContractsCustomer START ===");
        System.out.println("Customer ID: " + customer.getAccountId());
        System.out.println("Customer Name: " + customer.getFullName());

        try {
            // Lấy tham số tìm kiếm và filter
            String keyword = request.getParameter("keyword");
            String status = request.getParameter("status");
            String contractType = request.getParameter("contractType");
            String sortBy = request.getParameter("sortBy");
            String fromDate = request.getParameter("fromDate");
            String toDate = request.getParameter("toDate");

            System.out.println("Filter params - keyword: " + keyword + ", status: " + status
                    + ", contractType: " + contractType + ", sortBy: " + sortBy);

            // Pagination
            int page = 1;
            int pageSize = 10;

            try {
                String pageParam = request.getParameter("page");
                if (pageParam != null && !pageParam.isEmpty()) {
                    page = Integer.parseInt(pageParam);
                    if (page < 1) {
                        page = 1;
                    }
                }
            } catch (NumberFormatException e) {
                page = 1;
            }

            int offset = (page - 1) * pageSize;

            // Lấy danh sách hợp đồng của khách hàng
            System.out.println("Getting contracts for customer ID: " + customer.getAccountId());
            List<Contract> contractList = getFilteredContracts(
                    customer.getAccountId(),
                    keyword,
                    status,
                    contractType,
                    sortBy,
                    fromDate,
                    toDate,
                    offset,
                    pageSize
            );
            System.out.println("Found " + contractList.size() + " contracts after filtering");

            // Đếm tổng số hợp đồng để tính pagination
            int totalContracts = countFilteredContracts(
                    customer.getAccountId(),
                    keyword,
                    status,
                    contractType,
                    fromDate,
                    toDate
            );

            int totalPages = (int) Math.ceil((double) totalContracts / pageSize);

            // Đếm số hợp đồng theo trạng thái
            int activeCount = countContractsByStatus(customer.getAccountId(), "Active");
            int completedCount = countContractsByStatus(customer.getAccountId(), "Completed");

            System.out.println("Statistics - Active: " + activeCount + ", Completed: " + completedCount);
            System.out.println("Pagination - Page: " + page + "/" + totalPages + ", Total contracts: " + totalContracts);

            // Set attributes
            request.setAttribute("contractList", contractList);
            request.setAttribute("currentPageNumber", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("activeCount", activeCount);
            request.setAttribute("completedCount", completedCount);

            System.out.println("=== ViewContractsCustomer END - SUCCESS ===");

            // Forward to JSP
            request.getRequestDispatcher("viewcontracts.jsp").forward(request, response);

        } catch (SQLException e) {
            System.err.println("=== ViewContractsCustomer ERROR ===");
            System.err.println("SQL Error: " + e.getMessage());
            e.printStackTrace();
            log("Error in ViewContractsCustomer.doGet: " + e.getMessage(), e);

            // Set empty list and error message
            request.setAttribute("contractList", new ArrayList<>());
            request.setAttribute("currentPageNumber", 1);
            request.setAttribute("totalPages", 0);
            request.setAttribute("activeCount", 0);
            request.setAttribute("completedCount", 0);
            request.setAttribute("errorMessage", "Không thể tải danh sách hợp đồng. Vui lòng thử lại sau.");

            System.err.println("=== ViewContractsCustomer END - ERROR ===");

            // Forward to JSP with error message
            request.getRequestDispatcher("viewcontracts.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("=== ViewContractsCustomer UNEXPECTED ERROR ===");
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();

            // Set empty list and error message
            request.setAttribute("contractList", new ArrayList<>());
            request.setAttribute("currentPageNumber", 1);
            request.setAttribute("totalPages", 0);
            request.setAttribute("activeCount", 0);
            request.setAttribute("completedCount", 0);
            request.setAttribute("errorMessage", "Đã xảy ra lỗi không mong muốn. Vui lòng thử lại sau.");

            System.err.println("=== ViewContractsCustomer END - UNEXPECTED ERROR ===");

            // Forward to JSP with error message
            request.getRequestDispatcher("viewcontracts.jsp").forward(request, response);
        }
    }

    /**
     * Handles the HTTP <code>POST</code> method - Currently not used
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    /**
     * Get filtered contracts for a customer with sorting support
     */
    /**
     * Get filtered contracts for a customer with sorting support ✅ Now includes
     * BOTH main contracts AND appendixes
     */
    private List<Contract> getFilteredContracts(int customerId, String keyword, String status,
            String contractType, String sortBy, String fromDate, String toDate, int offset, int limit) throws SQLException {

        System.out.println("=== getFilteredContracts START ===");
        System.out.println("Filters - keyword: " + keyword + ", status: " + status
                + ", contractType: " + contractType + ", sortBy: " + sortBy);

        // ✅ THAY ĐỔI: Dùng method mới để lấy CẢ hợp đồng VÀ phụ lục
        List<Contract> allContracts = contractDAO.getContractsAndAppendixesByCustomer(customerId);
        System.out.println("Total contracts + appendixes loaded: " + allContracts.size());

        List<Contract> filteredList = new ArrayList<>();

        for (Contract contract : allContracts) {
            if ("Appendix".equals(contract.getContractType())) {
                continue;
            }
            // Apply filters
            if (status != null && !status.isEmpty() && !contract.getStatus().equals(status)) {
                continue;
            }

            // Filter by contract type
            if (contractType != null && !contractType.isEmpty()) {
                String currentType = contract.getContractType();
                if (currentType == null) {
                    currentType = "MainContract"; // Default type
                }
                if (!currentType.equals(contractType)) {
                    continue;
                }
            }

            if (keyword != null && !keyword.isEmpty()) {
                String keywordLower = keyword.toLowerCase();
                boolean matchKeyword
                        = String.valueOf(contract.getContractId()).contains(keywordLower)
                        || (contract.getContractType() != null && contract.getContractType().toLowerCase().contains(keywordLower))
                        || (contract.getDetails() != null && contract.getDetails().toLowerCase().contains(keywordLower));

                if (!matchKeyword) {
                    continue;
                }
            }

            if (fromDate != null && !fromDate.isEmpty()) {
                if (contract.getContractDate().isBefore(java.time.LocalDate.parse(fromDate))) {
                    continue;
                }
            }

            if (toDate != null && !toDate.isEmpty()) {
                if (contract.getContractDate().isAfter(java.time.LocalDate.parse(toDate))) {
                    continue;
                }
            }

            filteredList.add(contract);
        }

        System.out.println("After filtering: " + filteredList.size() + " items");

        // Apply sorting
        if (sortBy != null && !sortBy.isEmpty()) {
            switch (sortBy) {
                case "newest":
                    Collections.sort(filteredList, (a, b) -> b.getContractDate().compareTo(a.getContractDate()));
                    break;
                case "oldest":
                    Collections.sort(filteredList, (a, b) -> a.getContractDate().compareTo(b.getContractDate()));
                    break;
                case "id_asc":
                    Collections.sort(filteredList, (a, b) -> Integer.compare(a.getContractId(), b.getContractId()));
                    break;
                case "id_desc":
                    Collections.sort(filteredList, (a, b) -> Integer.compare(b.getContractId(), a.getContractId()));
                    break;
                default:
                    // Default sort by newest
                    Collections.sort(filteredList, (a, b) -> b.getContractDate().compareTo(a.getContractDate()));
                    break;
            }
        } else {
            // Default sort by newest
            Collections.sort(filteredList, (a, b) -> b.getContractDate().compareTo(a.getContractDate()));
        }

        // Enrich contract data with additional info
        for (Contract contract : filteredList) {
            enrichContractData(contract);
        }

        // Apply pagination
        int start = offset;
        int end = Math.min(start + limit, filteredList.size());

        if (start >= filteredList.size()) {
            System.out.println("=== getFilteredContracts END - Empty result (offset > size) ===");
            return new ArrayList<>();
        }

        List<Contract> result = filteredList.subList(start, end);
        System.out.println("=== getFilteredContracts END - Returning " + result.size() + " items ===");

        return result;
    }

    /**
     * Count filtered contracts
     */
    /**
     * Count filtered contracts ✅ Now includes BOTH main contracts AND
     * appendixes
     */
    private int countFilteredContracts(int customerId, String keyword, String status,
            String contractType, String fromDate, String toDate) throws SQLException {

        // ✅ THAY ĐỔI: Dùng method mới
        List<Contract> allContracts = contractDAO.getContractsAndAppendixesByCustomer(customerId);
        int count = 0;

        for (Contract contract : allContracts) {
            
            if ("Appendix".equals(contract.getContractType())) {
            continue;
        }
            // Apply same filters as getFilteredContracts
            if (status != null && !status.isEmpty() && !contract.getStatus().equals(status)) {
                continue;
            }

            // Filter by contract type
            if (contractType != null && !contractType.isEmpty()) {
                String currentType = contract.getContractType();
                if (currentType == null) {
                    currentType = "MainContract"; // Default type
                }
                if (!currentType.equals(contractType)) {
                    continue;
                }
            }

            if (keyword != null && !keyword.isEmpty()) {
                String keywordLower = keyword.toLowerCase();
                boolean matchKeyword
                        = String.valueOf(contract.getContractId()).contains(keywordLower)
                        || (contract.getContractType() != null && contract.getContractType().toLowerCase().contains(keywordLower))
                        || (contract.getDetails() != null && contract.getDetails().toLowerCase().contains(keywordLower));

                if (!matchKeyword) {
                    continue;
                }
            }

            if (fromDate != null && !fromDate.isEmpty()) {
                if (contract.getContractDate().isBefore(java.time.LocalDate.parse(fromDate))) {
                    continue;
                }
            }

            if (toDate != null && !toDate.isEmpty()) {
                if (contract.getContractDate().isAfter(java.time.LocalDate.parse(toDate))) {
                    continue;
                }
            }

            count++;
        }

        return count;
    }

    /**
     * Count contracts by status ✅ Now includes BOTH main contracts AND
     * appendixes
     */
    private int countContractsByStatus(int customerId, String status) throws SQLException {
        // ✅ THAY ĐỔI: Dùng method mới
        List<Contract> allContracts = contractDAO.getContractsAndAppendixesByCustomer(customerId);
        int count = 0;

        for (Contract contract : allContracts) {
            if ("Appendix".equals(contract.getContractType())) {
            continue;
        }
            if (contract.getStatus().equals(status)) {
                count++;
            }
        }

        return count;
    }

    /**
     * Enrich contract with additional data (customer info, equipment count,
     * request count)
     */
    private void enrichContractData(Contract contract) throws SQLException {
        // Get customer information
        String customerName = contractDAO.getCustomerNameByContractId(contract.getContractId());
        contract.setCustomerName(customerName);

        // Get equipment count (from ContractEquipment table)
        int equipmentCount = getEquipmentCountForContract(contract.getContractId());
        contract.setEquipmentCount(equipmentCount);

        // Get service request count
        int requestCount = getRequestCountForContract(contract.getContractId());
        contract.setRequestCount(requestCount);

        // Get customer details for tooltip
        try {
            Map<String, String> customerInfo = getCustomerInfo(contract.getCustomerId());
            contract.setCustomerEmail(customerInfo.get("email"));
            contract.setCustomerPhone(customerInfo.get("phone"));
            contract.setCustomerAddress(customerInfo.get("address"));
        } catch (Exception e) {
            log("Warning: Could not load customer info for contract " + contract.getContractId(), e);
        }
    }

    /**
     * Get equipment count for a contract (including appendix equipment)
     */
    private int getEquipmentCountForContract(int contractId) throws SQLException {
        // Count equipment in main contract
        String sql1 = "SELECT COUNT(*) FROM ContractEquipment WHERE contractId = ?";
        int mainEquipmentCount = 0;

        try (Connection conn = new dal.DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql1)) {
            ps.setInt(1, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    mainEquipmentCount = rs.getInt(1);
                }
            }
        }

        // Count equipment in appendixes
        String sql2 = "SELECT COUNT(DISTINCT cae.equipmentId) "
                + "FROM ContractAppendix ca "
                + "JOIN ContractAppendixEquipment cae ON ca.appendixId = cae.appendixId "
                + "WHERE ca.contractId = ?";
        int appendixEquipmentCount = 0;

        try (Connection conn = new dal.DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql2)) {
            ps.setInt(1, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    appendixEquipmentCount = rs.getInt(1);
                }
            }
        }

        return mainEquipmentCount + appendixEquipmentCount;
    }

    /**
     * Get service request count for a contract (including requests from
     * appendix equipment)
     */
    private int getRequestCountForContract(int contractId) throws SQLException {
        String sql = "SELECT COUNT(DISTINCT sr.requestId) "
                + "FROM ServiceRequest sr "
                + "LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId "
                + "WHERE sr.contractId = ? "
                + "OR EXISTS ("
                + "    SELECT 1 "
                + "    FROM ContractAppendixEquipment cae "
                + "    JOIN ContractAppendix ca ON cae.appendixId = ca.appendixId "
                + "    WHERE cae.equipmentId = sr.equipmentId "
                + "    AND ca.contractId = ?"
                + ")";

        try (Connection conn = new dal.DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            ps.setInt(2, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    /**
     * Get customer information
     */
    private Map<String, String> getCustomerInfo(int customerId) throws SQLException {
        Map<String, String> info = new HashMap<>();
        String sql = "SELECT a.email, a.phone, ap.address FROM Account a "
                + "LEFT JOIN AccountProfile ap ON a.accountId = ap.accountId "
                + "WHERE a.accountId = ?";

        try (Connection conn = new dal.DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String email = rs.getString("email");
                    String phone = rs.getString("phone");
                    String address = rs.getString("address");
                    
                    info.put("email", email != null ? email : "Chưa cập nhật");
                    info.put("phone", phone != null ? phone : "Chưa cập nhật");
                    info.put("address", address != null ? address : "Chưa cập nhật");
                    
                    System.out.println("DEBUG: Customer " + customerId + " - Email: " + email + ", Phone: " + phone);
                } else {
                    System.out.println("WARNING: No customer found with ID: " + customerId);
                    info.put("email", "Không tìm thấy");
                    info.put("phone", "Không tìm thấy");
                    info.put("address", "Không tìm thấy");
                }
            }
        }

        return info;
    }

    /**
     * Handle API request to get contract equipment
     */
    private void handleGetContractEquipment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");

        try {
            int contractId = Integer.parseInt(request.getParameter("contractId"));

            // Get equipment from main contract
            List<Map<String, Object>> equipment = new ArrayList<>();
            String sql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, "
                    + "ce.startDate, ce.endDate, 'Hợp đồng' as source "
                    + "FROM ContractEquipment ce "
                    + "JOIN Equipment e ON ce.equipmentId = e.equipmentId "
                    + "WHERE ce.contractId = ?";

            try (Connection conn = new dal.DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, contractId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> item = new HashMap<>();
                        item.put("equipmentId", rs.getInt("equipmentId"));
                        item.put("serialNumber", rs.getString("serialNumber"));
                        item.put("model", rs.getString("model"));
                        item.put("description", rs.getString("description"));
                        item.put("startDate", rs.getDate("startDate"));
                        item.put("endDate", rs.getDate("endDate"));
                        item.put("source", rs.getString("source"));
                        equipment.add(item);
                    }
                }
            }

            // Get equipment from appendixes
            String sql2 = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, "
                    + "ca.effectiveDate as startDate, null as endDate, 'Phụ lục' as source "
                    + "FROM ContractAppendix ca "
                    + "JOIN ContractAppendixEquipment cae ON ca.appendixId = cae.appendixId "
                    + "JOIN Equipment e ON cae.equipmentId = e.equipmentId "
                    + "WHERE ca.contractId = ?";

            try (Connection conn = new dal.DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql2)) {
                ps.setInt(1, contractId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> item = new HashMap<>();
                        item.put("equipmentId", rs.getInt("equipmentId"));
                        item.put("serialNumber", rs.getString("serialNumber"));
                        item.put("model", rs.getString("model"));
                        item.put("description", rs.getString("description"));
                        item.put("startDate", rs.getDate("startDate"));
                        item.put("endDate", rs.getDate("endDate"));
                        item.put("source", rs.getString("source"));
                        equipment.add(item);
                    }
                }
            }

            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("equipment", equipment);

            response.getWriter().write(gson.toJson(result));

        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "Lỗi: " + e.getMessage());
            response.getWriter().write(gson.toJson(result));
        }
    }

    /**
     * Handle API request to get contract service requests
     */
    private void handleGetContractRequests(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");

        try {
            int contractId = Integer.parseInt(request.getParameter("contractId"));

            List<Map<String, Object>> requests = new ArrayList<>();
            String sql = "SELECT sr.requestId, sr.requestType, sr.priorityLevel, sr.status, "
                    + "sr.requestDate, sr.description, e.model as equipmentModel "
                    + "FROM ServiceRequest sr "
                    + "LEFT JOIN Equipment e ON sr.equipmentId = e.equipmentId "
                    + "WHERE sr.contractId = ? "
                    + "ORDER BY sr.requestDate DESC";

            try (Connection conn = new dal.DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, contractId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> item = new HashMap<>();
                        item.put("requestId", rs.getInt("requestId"));
                        item.put("requestType", rs.getString("requestType"));
                        item.put("priorityLevel", rs.getString("priorityLevel"));
                        item.put("status", rs.getString("status"));
                        item.put("requestDate", rs.getDate("requestDate"));
                        item.put("description", rs.getString("description"));
                        item.put("equipmentModel", rs.getString("equipmentModel"));
                        requests.add(item);
                    }
                }
            }

            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("requests", requests);

            response.getWriter().write(gson.toJson(result));

        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "Lỗi: " + e.getMessage());
            response.getWriter().write(gson.toJson(result));
        }
    }

    /**
     * Handle API request to get contract appendixes
     */
    private void handleGetContractAppendix(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");

        try {
            int contractId = Integer.parseInt(request.getParameter("contractId"));

            List<Map<String, Object>> appendixes = new ArrayList<>();
            String sql = "SELECT ca.appendixId, ca.appendixName, ca.appendixType, ca.description, "
                    + "ca.effectiveDate, ca.status, ca.fileAttachment, "
                    + "COUNT(cae.equipmentId) as equipmentCount "
                    + "FROM ContractAppendix ca "
                    + "LEFT JOIN ContractAppendixEquipment cae ON ca.appendixId = cae.appendixId "
                    + "WHERE ca.contractId = ? "
                    + "GROUP BY ca.appendixId "
                    + "ORDER BY ca.effectiveDate DESC";

            try (Connection conn = new dal.DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, contractId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> item = new HashMap<>();
                        item.put("appendixId", rs.getInt("appendixId"));
                        item.put("appendixName", rs.getString("appendixName"));
                        item.put("appendixType", rs.getString("appendixType"));
                        item.put("description", rs.getString("description"));
                        item.put("effectiveDate", rs.getDate("effectiveDate"));
                        item.put("status", rs.getString("status"));
                        item.put("fileAttachment", rs.getString("fileAttachment"));
                        item.put("equipmentCount", rs.getInt("equipmentCount"));
                        appendixes.add(item);
                    }
                }
            }

            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("appendixes", appendixes);

            response.getWriter().write(gson.toJson(result));

        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "Lỗi: " + e.getMessage());
            response.getWriter().write(gson.toJson(result));
        }
    }

    /**
     * Handle API request to get appendix equipment
     */
    private void handleGetAppendixEquipment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");

        try {
            int appendixId = Integer.parseInt(request.getParameter("appendixId"));

            List<Map<String, Object>> equipment = new ArrayList<>();
            String sql = "SELECT e.equipmentId, e.serialNumber, e.model, e.description, "
                    + "cae.note "
                    + "FROM ContractAppendixEquipment cae "
                    + "JOIN Equipment e ON cae.equipmentId = e.equipmentId "
                    + "WHERE cae.appendixId = ?";

            try (Connection conn = new dal.DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, appendixId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> item = new HashMap<>();
                        item.put("equipmentId", rs.getInt("equipmentId"));
                        item.put("serialNumber", rs.getString("serialNumber"));
                        item.put("model", rs.getString("model"));
                        item.put("description", rs.getString("description"));
                        item.put("note", rs.getString("note"));
                        equipment.add(item);
                    }
                }
            }

            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("equipment", equipment);

            response.getWriter().write(gson.toJson(result));

        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "Lỗi: " + e.getMessage());
            response.getWriter().write(gson.toJson(result));
        }
    }

    @Override
    public String getServletInfo() {
        return "Customer Contract Viewing Servlet - Displays contracts with appendix support";
    }
}
