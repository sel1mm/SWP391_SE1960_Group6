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
import java.util.ArrayList;
import java.util.List;

/**
 * Servlet xử lý quản lý yêu cầu dịch vụ
 * Có hỗ trợ Priority Level khi tạo mới
 */
@WebServlet(name = "ManagerServiceRequestServlet", urlPatterns = {"/managerServiceRequest"})
public class ManagerServiceRequestServlet extends HttpServlet {
    
    private ServiceRequestDAO serviceRequestDAO;
    private static final int PAGE_SIZE = 10;
    
    @Override
    public void init() throws ServletException {
        serviceRequestDAO = new ServiceRequestDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("session_login_id");
        
        if (customerId == null) {
            String targetUrl = request.getRequestURI();
            String queryString = request.getQueryString();
            if (queryString != null) {
                targetUrl += "?" + queryString;
            }
            session.setAttribute("targetUrl", targetUrl);
            response.sendRedirect(request.getContextPath() + "/login");
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

        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("session_login_id");
        
        if (customerId == null) {
            session.setAttribute("error", "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("CreateServiceRequest".equals(action)) {
            handleCreateRequest(request, response);
        } else if ("UpdateServiceRequest".equals(action)) {
            handleUpdateRequest(request, response);
        } else if ("CancelServiceRequest".equals(action)) {
            handleCancelRequest(request, response);
        }
    }
    
    private int getPageNumber(HttpServletRequest request) {
        String pageStr = request.getParameter("page");
        
        if (pageStr == null || pageStr.trim().isEmpty()) {
            return 1;
        }
        
        try {
            int page = Integer.parseInt(pageStr.trim());
            return page < 1 ? 1 : page;
        } catch (NumberFormatException e) {
            return 1;
        }
    }
    
    private void displayAllRequests(HttpServletRequest request, HttpServletResponse response, int customerId)
            throws ServletException, IOException {
        
        int currentPage = getPageNumber(request);
        int offset = (currentPage - 1) * PAGE_SIZE;
        
        List<ServiceRequest> allRequests = serviceRequestDAO.getRequestsByCustomerId(customerId);
        
        int totalRecords = allRequests.size();
        int totalPages = (int) Math.ceil((double) totalRecords / PAGE_SIZE);
        
        if (currentPage > totalPages && totalPages > 0) {
            currentPage = totalPages;
            offset = (currentPage - 1) * PAGE_SIZE;
        }
        
        List<ServiceRequest> requests = new ArrayList<>();
        int endIndex = Math.min(offset + PAGE_SIZE, allRequests.size());
        if (offset < allRequests.size()) {
            requests = allRequests.subList(offset, endIndex);
        }
        
        int totalRequests = serviceRequestDAO.getTotalRequests(customerId);
        int pendingCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Pending");
        int inProgressCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Approved");
        int completedCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Completed");
        int cancelledCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Cancelled");
        
        request.setAttribute("requests", requests);
        request.setAttribute("totalRequests", totalRequests);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("inProgressCount", inProgressCount);
        request.setAttribute("completedCount", completedCount);
        request.setAttribute("cancelledCount", cancelledCount);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("startIndex", offset + 1);
        
        request.getRequestDispatcher("/managerServiceRequest.jsp").forward(request, response);
    }
    
    private void handleSearch(HttpServletRequest request, HttpServletResponse response, int customerId)
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        
        if (keyword == null || keyword.trim().isEmpty()) {
            displayAllRequests(request, response, customerId);
            return;
        }
        
        int currentPage = getPageNumber(request);
        int offset = (currentPage - 1) * PAGE_SIZE;
        
        List<ServiceRequest> allRequests = serviceRequestDAO.searchRequests(customerId, keyword.trim());
        
        int totalRecords = allRequests.size();
        int totalPages = (int) Math.ceil((double) totalRecords / PAGE_SIZE);
        
        if (currentPage > totalPages && totalPages > 0) {
            currentPage = totalPages;
            offset = (currentPage - 1) * PAGE_SIZE;
        }
        
        List<ServiceRequest> requests = new ArrayList<>();
        int endIndex = Math.min(offset + PAGE_SIZE, allRequests.size());
        if (offset < allRequests.size()) {
            requests = allRequests.subList(offset, endIndex);
        }
        
        int totalRequests = serviceRequestDAO.getTotalRequests(customerId);
        int pendingCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Pending");
        int inProgressCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Approved");
        int completedCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Completed");
        int cancelledCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Cancelled");

        request.setAttribute("requests", requests);
        request.setAttribute("totalRequests", totalRequests);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("inProgressCount", inProgressCount);
        request.setAttribute("completedCount", completedCount);
        request.setAttribute("cancelledCount", cancelledCount);
        request.setAttribute("keyword", keyword);
        request.setAttribute("searchMode", true);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("startIndex", offset + 1);
        
        request.getRequestDispatcher("/managerServiceRequest.jsp").forward(request, response);
    }
    
    private void handleFilter(HttpServletRequest request, HttpServletResponse response, int customerId)
            throws ServletException, IOException {
        
        String status = request.getParameter("status");
        
        int currentPage = getPageNumber(request);
        int offset = (currentPage - 1) * PAGE_SIZE;
        
        List<ServiceRequest> allRequests;
        if (status == null || status.trim().isEmpty()) {
            allRequests = serviceRequestDAO.getRequestsByCustomerId(customerId);
        } else {
            allRequests = serviceRequestDAO.filterRequestsByStatus(customerId, status);
        }
        
        int totalRecords = allRequests.size();
        int totalPages = (int) Math.ceil((double) totalRecords / PAGE_SIZE);
        
        if (currentPage > totalPages && totalPages > 0) {
            currentPage = totalPages;
            offset = (currentPage - 1) * PAGE_SIZE;
        }
        
        List<ServiceRequest> requests = new ArrayList<>();
        int endIndex = Math.min(offset + PAGE_SIZE, allRequests.size());
        if (offset < allRequests.size()) {
            requests = allRequests.subList(offset, endIndex);
        }
        
        int totalRequests = serviceRequestDAO.getTotalRequests(customerId);
        int pendingCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Pending");
        int inProgressCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Approved");
        int completedCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Completed");
        int cancelledCount = serviceRequestDAO.getRequestCountByStatus(customerId, "Cancelled");
        
        request.setAttribute("requests", requests);
        request.setAttribute("totalRequests", totalRequests);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("inProgressCount", inProgressCount);
        request.setAttribute("completedCount", completedCount);
        request.setAttribute("cancelledCount", cancelledCount);
        request.setAttribute("filterStatus", status);
        request.setAttribute("filterMode", true);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("startIndex", offset + 1);
        
        request.getRequestDispatcher("/managerServiceRequest.jsp").forward(request, response);
    }
    
    /**
     * ⭐ TẠO YÊU CẦU MỚI - CÓ HỖ TRỢ PRIORITY LEVEL
     */
    private void handleCreateRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("session_login_id");

        // ========== BƯỚC 1: LẤY DỮ LIỆU TỪ FORM ==========
        String contractIdStr = request.getParameter("contractId");
        String equipmentIdStr = request.getParameter("equipmentId");
        String description = request.getParameter("description");
        String priorityLevel = request.getParameter("priorityLevel"); // ⭐ MỚI THÊM
        
        // ========== BƯỚC 2: VALIDATE INPUT ==========
        
        // Validate contractId
        if (contractIdStr == null || contractIdStr.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng nhập mã hợp đồng!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // Validate equipmentId
        if (equipmentIdStr == null || equipmentIdStr.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng nhập mã thiết bị!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // Validate description
        if (description == null || description.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng nhập mô tả vấn đề!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // ⭐ Validate priorityLevel không rỗng
        if (priorityLevel == null || priorityLevel.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng chọn mức độ ưu tiên!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // ⭐ Validate priorityLevel phải là một trong 3 giá trị hợp lệ
        if (!priorityLevel.equals("Normal") && 
            !priorityLevel.equals("High") && 
            !priorityLevel.equals("Urgent")) {
            session.setAttribute("error", "Mức độ ưu tiên không hợp lệ! Chỉ chấp nhận: Normal, High, Urgent");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // Parse integer
        int contractId;
        int equipmentId;
        try {
            contractId = Integer.parseInt(contractIdStr.trim());
            equipmentId = Integer.parseInt(equipmentIdStr.trim());
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Mã hợp đồng và mã thiết bị phải là số nguyên!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // Validate số dương
        if (contractId <= 0 || equipmentId <= 0) {
            session.setAttribute("error", "Mã hợp đồng và mã thiết bị phải là số dương!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // Validate độ dài description
        if (description.trim().length() < 10) {
            session.setAttribute("error", "Mô tả vấn đề phải có ít nhất 10 ký tự!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // ========== BƯỚC 3: VALIDATE DATABASE ==========
        
        // Kiểm tra contract có thuộc customer không
        if (!serviceRequestDAO.isValidContract(contractId, customerId)) {
            session.setAttribute("error", "Mã hợp đồng không tồn tại hoặc không thuộc về bạn!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // Kiểm tra equipment có tồn tại không
        if (!serviceRequestDAO.isValidEquipment(equipmentId)) {
            session.setAttribute("error", "Mã thiết bị không tồn tại!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        // Kiểm tra equipment có trong contract không
        if (!serviceRequestDAO.isEquipmentInContract(contractId, equipmentId)) {
            session.setAttribute("error", "Thiết bị này không thuộc hợp đồng bạn đã chọn!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }

        // ========== BƯỚC 4: TẠO OBJECT VÀ INSERT DATABASE ==========
        
        ServiceRequest newRequest = new ServiceRequest();
        newRequest.setContractId(contractId);
        newRequest.setEquipmentId(equipmentId);
        newRequest.setCreatedBy(customerId);
        newRequest.setDescription(description.trim());
        newRequest.setPriorityLevel(priorityLevel); // ⭐ SET PRIORITY LEVEL TỪ FORM
        newRequest.setRequestDate(new java.util.Date());
        newRequest.setStatus("Pending");
        newRequest.setRequestType("Service");
        
        // Insert vào database
        int newRequestId = serviceRequestDAO.createServiceRequest(newRequest);
        
        // ========== BƯỚC 5: KIỂM TRA KẾT QUẢ ==========
        
        if (newRequestId > 0) {
            // Thành công - Hiển thị thông báo với priority level
            String priorityText = "";
            if (priorityLevel.equals("Urgent")) {
                priorityText = " với mức độ ưu tiên KHẨN CẤP";
            } else if (priorityLevel.equals("High")) {
                priorityText = " với mức độ ưu tiên CAO";
            } else {
                priorityText = " với mức độ ưu tiên BÌNH THƯỜNG";
            }
            
            session.setAttribute("success", 
                "✅ Bạn đã tạo đơn thành công! Mã yêu cầu: #" + newRequestId + priorityText);
        } else {
            // Thất bại
            session.setAttribute("error", 
                "❌ Đã có lỗi xảy ra phía máy chủ khi tạo yêu cầu. Vui lòng thử lại!");
        }
        
        response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
    }
    
    /**
     * CẬP NHẬT YÊU CẦU
     */
    private void handleUpdateRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("session_login_id");
        
        String requestIdStr = request.getParameter("requestId");
        String description = request.getParameter("description");
        String priorityLevel = request.getParameter("priorityLevel");
        
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
        
        int requestId;
        try {
            requestId = Integer.parseInt(requestIdStr.trim());
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Mã yêu cầu phải là số nguyên!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        if (requestId <= 0) {
            session.setAttribute("error", "Mã yêu cầu phải là số dương!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }

        if (!serviceRequestDAO.canUpdateRequest(requestId, customerId)) {
            session.setAttribute("error", "Bạn không có quyền cập nhật hoặc yêu cầu này đã được xử lý!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        boolean success = serviceRequestDAO.updateServiceRequest(requestId, description.trim(), priorityLevel);
        
        if (success) {
            session.setAttribute("success", "✅ Cập nhật yêu cầu #" + requestId + " thành công!");
        } else {
            session.setAttribute("error", "❌ Có lỗi xảy ra khi cập nhật yêu cầu. Vui lòng thử lại!");
        }
        response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
    }
    
    /**
     * HỦY YÊU CẦU
     */
    private void handleCancelRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("session_login_id");
        
        String requestIdStr = request.getParameter("requestId");
        
        if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
            session.setAttribute("error", "Mã yêu cầu không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        int requestId;
        try {
            requestId = Integer.parseInt(requestIdStr.trim());
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Mã yêu cầu phải là số nguyên!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        if (requestId <= 0) {
            session.setAttribute("error", "Mã yêu cầu phải là số dương!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        if (!serviceRequestDAO.canCancelRequest(requestId, customerId)) {
            session.setAttribute("error", "Bạn không có quyền hủy hoặc yêu cầu này đã được xử lý!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }
        
        boolean success = serviceRequestDAO.cancelServiceRequest(requestId);
        
        if (success) {
            session.setAttribute("success", "✅ Đã hủy yêu cầu #" + requestId + " thành công!");
        } else {
            session.setAttribute("error", "❌ Có lỗi xảy ra khi hủy yêu cầu. Vui lòng thử lại!");
        }
        response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
    }
}