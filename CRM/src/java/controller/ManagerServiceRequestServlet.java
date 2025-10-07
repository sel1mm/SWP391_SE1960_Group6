package controller;

import dal.ServiceRequestDAO;
import model.ServiceRequest;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Date;
import java.util.List;

@WebServlet(name = "ManagerServiceRequestServlet", urlPatterns = {"/managerServiceRequest"})
public class ManagerServiceRequestServlet extends HttpServlet {
    
    private ServiceRequestDAO serviceRequestDAO;
    
    @Override
    public void init() throws ServletException {
        serviceRequestDAO = new ServiceRequestDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // Lấy thông tin customer từ session
        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("accountId");
        
        // Kiểm tra đăng nhập
        if (customerId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("search".equals(action)) {
            handleSearch(request, response, customerId);
        } else if ("filter".equals(action)) {
            handleFilter(request, response, customerId);
        } else {
            displayAllRequests(request, response, customerId);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        
        if ("CreateServiceRequest".equals(action)) {
            handleCreateRequest(request, response);
        } else if ("UpdateServiceRequest".equals(action)) {
            handleUpdateRequest(request, response);
        }
    }
    
    /**
     * Hiển thị tất cả requests
     */
    private void displayAllRequests(HttpServletRequest request, HttpServletResponse response, int customerId)
            throws ServletException, IOException {
        
        List<ServiceRequest> requests = serviceRequestDAO.getRequestsByCustomerId(customerId);
        
        // Lấy thống kê
        int totalRequests = serviceRequestDAO.getTotalRequests(customerId);
        int pendingCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Pending");
        int inProgressCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Approved");
        int completedCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Rejected");
        
        // Set attributes
        request.setAttribute("requests", requests);
        request.setAttribute("totalRequests", totalRequests);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("inProgressCount", inProgressCount);
        request.setAttribute("completedCount", completedCount);
        
        request.getRequestDispatcher("/managerServiceRequest.jsp").forward(request, response);
    }
    
    /**
     * Xử lý tìm kiếm
     */
    private void handleSearch(HttpServletRequest request, HttpServletResponse response, int customerId)
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        
        if (keyword == null || keyword.trim().isEmpty()) {
            displayAllRequests(request, response, customerId);
            return;
        }
        
        List<ServiceRequest> requests = serviceRequestDAO.searchRequests(customerId, keyword.trim());
        
        // Lấy thống kê
        int totalRequests = serviceRequestDAO.getTotalRequests(customerId);
        int pendingCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Pending");
        int inProgressCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Approved");
        int completedCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Rejected");
        
        request.setAttribute("requests", requests);
        request.setAttribute("totalRequests", totalRequests);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("inProgressCount", inProgressCount);
        request.setAttribute("completedCount", completedCount);
        request.setAttribute("keyword", keyword);
        request.setAttribute("searchMode", true);
        
        request.getRequestDispatcher("/managerServiceRequest.jsp").forward(request, response);
    }
    
    /**
     * Xử lý lọc theo status
     */
    private void handleFilter(HttpServletRequest request, HttpServletResponse response, int customerId)
            throws ServletException, IOException {
        
        String status = request.getParameter("status");
        
        List<ServiceRequest> requests;
        if (status == null || status.trim().isEmpty()) {
            requests = serviceRequestDAO.getRequestsByCustomerId(customerId);
        } else {
            requests = serviceRequestDAO.filterRequestsByStatus(customerId, status);
        }
        
        // Lấy thống kê
        int totalRequests = serviceRequestDAO.getTotalRequests(customerId);
        int pendingCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Pending");
        int inProgressCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Approved");
        int completedCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Rejected");
        
        request.setAttribute("requests", requests);
        request.setAttribute("totalRequests", totalRequests);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("inProgressCount", inProgressCount);
        request.setAttribute("completedCount", completedCount);
        request.setAttribute("filterStatus", status);
        request.setAttribute("filterMode", true);
        
        request.getRequestDispatcher("/managerServiceRequest.jsp").forward(request, response);
    }
    
    /**
     * Xử lý tạo service request mới - VALIDATION TẤT CẢ Ở BACKEND
     */
    private void handleCreateRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("accountId");
        
        // Kiểm tra đăng nhập
        if (customerId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Lấy dữ liệu từ form
        String contractIdStr = request.getParameter("contractId");
        String equipmentIdStr = request.getParameter("equipmentId");
        String description = request.getParameter("description");
        
        // ========== BACKEND VALIDATION ==========
        
        // 1. Validate required fields
        if (contractIdStr == null || contractIdStr.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng nhập mã hợp đồng!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        if (equipmentIdStr == null || equipmentIdStr.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng nhập mã thiết bị!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        if (description == null || description.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng nhập mô tả vấn đề!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // 2. Validate số nguyên
        int contractId;
        int equipmentId;
        try {
            contractId = Integer.parseInt(contractIdStr.trim());
            equipmentId = Integer.parseInt(equipmentIdStr.trim());
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Mã hợp đồng và mã thiết bị phải là số!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // 3. Validate số dương
        if (contractId <= 0 || equipmentId <= 0) {
            session.setAttribute("error", "Mã hợp đồng và mã thiết bị phải lớn hơn 0!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // 4. Validate độ dài description
        if (description.trim().length() < 10) {
            session.setAttribute("error", "Mô tả vấn đề phải có ít nhất 10 ký tự!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        if (description.trim().length() > 255) {
            session.setAttribute("error", "Mô tả vấn đề không được vượt quá 255 ký tự!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // 5. Validate contractId có tồn tại và thuộc về customer không
        if (!serviceRequestDAO.isValidContract(contractId, customerId)) {
            session.setAttribute("error", "Mã hợp đồng không tồn tại hoặc không thuộc về bạn!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // 6. Validate equipmentId có tồn tại không
        if (!serviceRequestDAO.isValidEquipment(equipmentId)) {
            session.setAttribute("error", "Mã thiết bị không tồn tại trong hệ thống!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // 7. Validate equipment có trong contract không
        if (!serviceRequestDAO.isEquipmentInContract(contractId, equipmentId)) {
            session.setAttribute("error", "Thiết bị này không thuộc hợp đồng bạn đã chọn!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // ========== TẤT CẢ VALIDATION ĐÃ PASS ==========
        
        // Tạo ServiceRequest object
        ServiceRequest newRequest = new ServiceRequest();
        newRequest.setContractId(contractId);
        newRequest.setEquipmentId(equipmentId);
        newRequest.setCreatedBy(customerId);
        newRequest.setDescription(description.trim());
        newRequest.setPriorityLevel("Normal"); // Mặc định
        newRequest.setRequestDate(new Date()); // Ngày hiện tại
        newRequest.setStatus("Pending"); // Mặc định
        newRequest.setRequestType("Service"); // Mặc định
        
        // Insert vào database
        int requestId = serviceRequestDAO.createServiceRequest(newRequest);
        
        if (requestId > 0) {
            session.setAttribute("success", "Tạo yêu cầu dịch vụ thành công! Mã yêu cầu: #" + requestId);
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
        } else {
            session.setAttribute("error", "Có lỗi xảy ra khi tạo yêu cầu. Vui lòng thử lại!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
        }
    }
    
    /**
     * Xử lý cập nhật service request - VALIDATION TẤT CẢ Ở BACKEND
     */
    private void handleUpdateRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("accountId");
        
        // Kiểm tra đăng nhập
        if (customerId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Lấy dữ liệu từ form
        String requestIdStr = request.getParameter("requestId");
        String description = request.getParameter("description");
        String priorityLevel = request.getParameter("priorityLevel");
        
        // ========== BACKEND VALIDATION ==========
        
        // 1. Validate required fields
        if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
            session.setAttribute("error", "Mã yêu cầu không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        if (description == null || description.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng nhập mô tả vấn đề!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        if (priorityLevel == null || priorityLevel.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng chọn mức độ ưu tiên!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // 2. Validate số nguyên
        int requestId;
        try {
            requestId = Integer.parseInt(requestIdStr.trim());
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Mã yêu cầu phải là số!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // 3. Validate số dương
        if (requestId <= 0) {
            session.setAttribute("error", "Mã yêu cầu phải lớn hơn 0!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // 4. Validate độ dài description
        if (description.trim().length() < 10) {
            session.setAttribute("error", "Mô tả vấn đề phải có ít nhất 10 ký tự!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        if (description.trim().length() > 255) {
            session.setAttribute("error", "Mô tả vấn đề không được vượt quá 255 ký tự!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // 5. Validate priorityLevel hợp lệ
        if (!priorityLevel.equals("Normal") && !priorityLevel.equals("High") && !priorityLevel.equals("Urgent")) {
            session.setAttribute("error", "Mức độ ưu tiên không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // 6. Validate request có thuộc về customer và đang Pending không
        if (!serviceRequestDAO.canUpdateRequest(requestId, customerId)) {
            session.setAttribute("error", "Bạn không có quyền cập nhật yêu cầu này hoặc yêu cầu đã được xử lý!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // ========== TẤT CẢ VALIDATION ĐÃ PASS ==========
        
        // Update vào database
        boolean success = serviceRequestDAO.updateServiceRequest(requestId, description.trim(), priorityLevel);
        
        if (success) {
            session.setAttribute("success", "Cập nhật yêu cầu #" + requestId + " thành công!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
        } else {
            session.setAttribute("error", "Có lỗi xảy ra khi cập nhật yêu cầu. Vui lòng thử lại!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
        }
    }
}