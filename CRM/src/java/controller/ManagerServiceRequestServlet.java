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
import java.util.Date;
import java.util.List;
import dal.EquipmentDAO;
import model.Equipment;
import model.RepairReport;
import dal.ServiceRequestDAO.ServiceRequestWithQuotation;
import java.math.BigDecimal;

@WebServlet(name = "ManagerServiceRequestServlet", urlPatterns = {"/managerServiceRequest"})
public class ManagerServiceRequestServlet extends HttpServlet {

    private ServiceRequestDAO serviceRequestDAO;
    private static final int PAGE_SIZE = 10; // Số hợp đồng per page

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

        // ✅ LOAD EQUIPMENT LIST FOR DROPDOWN
        try {
            EquipmentDAO equipmentDAO = new EquipmentDAO();
            List<EquipmentWithContract> equipmentList = new ArrayList<>();

            List<Equipment> allEquipment = equipmentDAO.getEquipmentByCustomerContracts(customerId);
            for (Equipment eq : allEquipment) {
                EquipmentWithContract ewc = new EquipmentWithContract();
                ewc.setEquipmentId(eq.getEquipmentId());
                ewc.setModel(eq.getModel());
                ewc.setSerialNumber(eq.getSerialNumber());

                String contractIdStr = equipmentDAO.getContractIdForEquipment(eq.getEquipmentId(), customerId);
                if (contractIdStr != null && contractIdStr.startsWith("HD")) {
                    ewc.setContractId(Integer.parseInt(contractIdStr.substring(2)));
                }

                equipmentList.add(ewc);
            }

            session.setAttribute("customerEquipmentList", equipmentList);
            System.out.println("✅ Loaded " + equipmentList.size() + " equipment for dropdown");

        } catch (Exception e) {
            System.out.println("❌ Error loading equipment list: " + e.getMessage());
            e.printStackTrace();
        }

        String action = request.getParameter("action");

        // ✅ THÊM ACTION XEM CHI TIẾT
        if ("viewDetail".equals(action)) {
            handleViewDetail(request, response, customerId);
        } else if ("search".equals(action)) {
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
        } else if ("AcceptQuotation".equals(action)) {  // ✅ THÊM ACTION MỚI
            handleAcceptQuotation(request, response, customerId);
        }
    }

    // ✅ INNER CLASS FOR EQUIPMENT DROPDOWN
    public static class EquipmentWithContract {

        private int equipmentId;
        private String model;
        private String serialNumber;
        private int contractId;

        public int getEquipmentId() {
            return equipmentId;
        }

        public void setEquipmentId(int equipmentId) {
            this.equipmentId = equipmentId;
        }

        public String getModel() {
            return model;
        }

        public void setModel(String model) {
            this.model = model;
        }

        public String getSerialNumber() {
            return serialNumber;
        }

        public void setSerialNumber(String serialNumber) {
            this.serialNumber = serialNumber;
        }

        public int getContractId() {
            return contractId;
        }

        public void setContractId(int contractId) {
            this.contractId = contractId;
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

        // ✅ TÍNH THỐNG KÊ DỰA TRÊN getDisplayStatus()
        int totalRequests = allRequests.size();
        int countChoXacNhan = 0;
        int countChoXuLy = 0;
        int countDangXuLy = 0;
        int countHoanThanh = 0;
        int countDaHuy = 0;

        for (ServiceRequest req : allRequests) {
            String displayStatus = req.getDisplayStatus();

            if ("Chờ Xác Nhận".equals(displayStatus)) {
                countChoXacNhan++;
            } else if ("Chờ Xử Lý".equals(displayStatus)) {
                countChoXuLy++;
            } else if ("Đang Xử Lý".equals(displayStatus)) {
                countDangXuLy++;
            } else if ("Hoàn Thành".equals(displayStatus)) {
                countHoanThanh++;
            } else if ("Đã Hủy".equals(displayStatus)) {
                countDaHuy++;
            }
        }

        request.setAttribute("requests", requests);
        request.setAttribute("allRequests", allRequests); // ✅ ĐỂ JSP DÙNG
        request.setAttribute("totalRequests", totalRequests);
        request.setAttribute("countChoXacNhan", countChoXacNhan);
        request.setAttribute("countChoXuLy", countChoXuLy);
        request.setAttribute("countDangXuLy", countDangXuLy);
        request.setAttribute("countHoanThanh", countHoanThanh);
        request.setAttribute("countDaHuy", countDaHuy);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pageSize", PAGE_SIZE);

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

        // ✅ TÌM KIẾM CHỈ THEO EQUIPMENT NAME VÀ DESCRIPTION
        List<ServiceRequest> allRequests = serviceRequestDAO.searchRequestsByEquipmentAndDescription(customerId, keyword.trim());

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

        // ✅ TÍNH THỐNG KÊ DỰA TRÊN getDisplayStatus()
        int totalRequests = allRequests.size();
        int countChoXacNhan = 0;
        int countChoXuLy = 0;
        int countDangXuLy = 0;
        int countHoanThanh = 0;
        int countDaHuy = 0;

        for (ServiceRequest req : allRequests) {
            String displayStatus = req.getDisplayStatus();

            if ("Chờ Xác Nhận".equals(displayStatus)) {
                countChoXacNhan++;
            } else if ("Chờ Xử Lý".equals(displayStatus)) {
                countChoXuLy++;
            } else if ("Đang Xử Lý".equals(displayStatus)) {
                countDangXuLy++;
            } else if ("Hoàn Thành".equals(displayStatus)) {
                countHoanThanh++;
            } else if ("Đã Hủy".equals(displayStatus)) {
                countDaHuy++;
            }
        }

        request.setAttribute("requests", requests);
        request.setAttribute("allRequests", allRequests); // ✅ ĐỂ JSP DÙNG
        request.setAttribute("totalRequests", totalRequests);
        request.setAttribute("countChoXacNhan", countChoXacNhan);
        request.setAttribute("countChoXuLy", countChoXuLy);
        request.setAttribute("countDangXuLy", countDangXuLy);
        request.setAttribute("countHoanThanh", countHoanThanh);
        request.setAttribute("countDaHuy", countDaHuy);
        request.setAttribute("keyword", keyword);
        request.setAttribute("searchMode", true);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pageSize", PAGE_SIZE);

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

        // ✅ TÍNH THỐNG KÊ DỰA TRÊN getDisplayStatus()
        int totalRequests = allRequests.size();
        int countChoXacNhan = 0;
        int countChoXuLy = 0;
        int countDangXuLy = 0;
        int countHoanThanh = 0;
        int countDaHuy = 0;

        for (ServiceRequest req : allRequests) {
            String displayStatus = req.getDisplayStatus();

            if ("Chờ Xác Nhận".equals(displayStatus)) {
                countChoXacNhan++;
            } else if ("Chờ Xử Lý".equals(displayStatus)) {
                countChoXuLy++;
            } else if ("Đang Xử Lý".equals(displayStatus)) {
                countDangXuLy++;
            } else if ("Hoàn Thành".equals(displayStatus)) {
                countHoanThanh++;
            } else if ("Đã Hủy".equals(displayStatus)) {
                countDaHuy++;
            }
        }

        request.setAttribute("requests", requests);
        request.setAttribute("allRequests", allRequests); // ✅ ĐỂ JSP DÙNG
        request.setAttribute("totalRequests", totalRequests);
        request.setAttribute("countChoXacNhan", countChoXacNhan);
        request.setAttribute("countChoXuLy", countChoXuLy);
        request.setAttribute("countDangXuLy", countDangXuLy);
        request.setAttribute("countHoanThanh", countHoanThanh);
        request.setAttribute("countDaHuy", countDaHuy);
        request.setAttribute("filterStatus", status);
        request.setAttribute("filterMode", true);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pageSize", PAGE_SIZE);

        request.getRequestDispatcher("/managerServiceRequest.jsp").forward(request, response);
    }

    private void handleCreateRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("session_login_id");

        if (customerId == null) {
            session.setAttribute("error", "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String supportType = request.getParameter("supportType");
        String description = request.getParameter("description");
        String priorityLevel = request.getParameter("priorityLevel");

        // ✅ VALIDATE CHUNG
        if (description == null || description.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng nhập mô tả vấn đề!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }

        if (description.trim().length() < 10) {
            session.setAttribute("error", "Mô tả vấn đề phải có ít nhất 10 ký tự!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }

        if (description.trim().length() > 1000) {
            session.setAttribute("error", "Mô tả vấn đề không được vượt quá 1000 ký tự!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }

        if (priorityLevel == null || priorityLevel.trim().isEmpty()) {
            priorityLevel = "Normal";
        }

        System.out.println("========== CREATE SERVICE REQUEST ==========");
        System.out.println("Support Type: " + supportType);
        System.out.println("Customer ID: " + customerId);

        // ========== XỬ LÝ HỖ TRỢ THIẾT BỊ ==========
        if ("equipment".equals(supportType)) {

            // ✅ KIỂM TRA: Form 1 (nhiều thiết bị) hay Form 2 (1 thiết bị)?
            String singleEquipmentId = request.getParameter("equipmentId"); // Form 2
            String[] multipleEquipmentIds = request.getParameterValues("equipmentIds"); // Form 1

            if (singleEquipmentId != null && !singleEquipmentId.trim().isEmpty()) {
                // ========== FORM 2: TẠO ĐƠN TỪ TRANG THIẾT BỊ (1 thiết bị) ==========
                System.out.println("✅ Processing SINGLE equipment from Equipment Management page");

                try {
                    int equipmentId = Integer.parseInt(singleEquipmentId.trim());
                    String contractIdStr = request.getParameter("contractId");

                    if (contractIdStr == null || contractIdStr.trim().isEmpty()) {
                        session.setAttribute("error", "Không tìm thấy thông tin hợp đồng!");

                        // ✅ QUAY LẠI TRANG TRƯỚC
                        String referer = request.getHeader("Referer");
                        response.sendRedirect(referer != null ? referer : request.getContextPath() + "/managerServiceRequest");
                        return;
                    }

                    int contractId = Integer.parseInt(contractIdStr.trim());

                    ServiceRequest newRequest = new ServiceRequest();
                    newRequest.setContractId(contractId);
                    newRequest.setEquipmentId(equipmentId);
                    newRequest.setCreatedBy(customerId);
                    newRequest.setDescription(description.trim());
                    newRequest.setPriorityLevel(priorityLevel);
                    newRequest.setRequestDate(new Date());
                    newRequest.setStatus("Pending");
                    newRequest.setRequestType("Service");

                    int result = serviceRequestDAO.createServiceRequest(newRequest);

                    if (result > 0) {
                        session.setAttribute("success", "✅ Yêu cầu hỗ trợ thiết bị đã được gửi thành công!");
                        System.out.println("✅ Created service request for equipment " + equipmentId);
                    } else {
                        session.setAttribute("error", "❌ Có lỗi khi tạo yêu cầu. Vui lòng thử lại!");
                        System.out.println("❌ Failed to create request for equipment " + equipmentId);
                    }

                } catch (NumberFormatException e) {
                    session.setAttribute("error", "Thông tin thiết bị không hợp lệ!");
                    System.out.println("❌ Invalid equipment ID: " + e.getMessage());
                } catch (Exception e) {
                    session.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
                    System.out.println("❌ Error creating request: " + e.getMessage());
                    e.printStackTrace();
                }

                // ✅ QUAY LẠI TRANG TRƯỚC (hoặc fallback về trang yêu cầu)
                String referer = request.getHeader("Referer");
                if (referer != null && !referer.isEmpty()) {
                    response.sendRedirect(referer);
                } else {
                    response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
                }
                return;
            } else if (multipleEquipmentIds != null && multipleEquipmentIds.length > 0) {
                // ========== FORM 1: TẠO NHIỀU ĐƠN TỪ TRANG YÊU CẦU (nhiều thiết bị) ==========
                System.out.println("✅ Processing MULTIPLE equipment from Service Request page");
                System.out.println("Selected " + multipleEquipmentIds.length + " equipment(s)");

                int successCount = 0;
                int failCount = 0;

                for (String equipmentIdStr : multipleEquipmentIds) {
                    try {
                        int equipmentId = Integer.parseInt(equipmentIdStr);

                        // Get contract ID for this equipment
                        EquipmentDAO equipmentDAO = new EquipmentDAO();
                        String contractIdStr = equipmentDAO.getContractIdForEquipment(equipmentId, customerId);

                        if (contractIdStr == null || !contractIdStr.startsWith("HD")) {
                            System.out.println("❌ No valid contract for equipment " + equipmentId);
                            failCount++;
                            continue;
                        }

                        int contractId = Integer.parseInt(contractIdStr.substring(2));

                        ServiceRequest newRequest = new ServiceRequest();
                        newRequest.setContractId(contractId);
                        newRequest.setEquipmentId(equipmentId);
                        newRequest.setCreatedBy(customerId);
                        newRequest.setDescription(description.trim());
                        newRequest.setPriorityLevel(priorityLevel);
                        newRequest.setRequestDate(new Date());
                        newRequest.setStatus("Pending");
                        newRequest.setRequestType("Service");

                        int result = serviceRequestDAO.createServiceRequest(newRequest);

                        if (result > 0) {
                            successCount++;
                            System.out.println("✅ Created request for equipment " + equipmentId);
                        } else {
                            failCount++;
                            System.out.println("❌ Failed to create request for equipment " + equipmentId);
                        }

                    } catch (Exception e) {
                        failCount++;
                        System.out.println("❌ Error processing equipment " + equipmentIdStr + ": " + e.getMessage());
                    }
                }

                if (successCount > 0) {
                    session.setAttribute("success", "✅ Đã tạo thành công " + successCount + " yêu cầu hỗ trợ!");
                }
                if (failCount > 0) {
                    session.setAttribute("error", "⚠️ Có " + failCount + " yêu cầu không thể tạo. Vui lòng kiểm tra lại!");
                }

                // ✅ REDIRECT VỀ TRANG YÊU CẦU
                response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
                return;

            } else {
                // ❌ KHÔNG CÓ THIẾT BỊ NÀO ĐƯỢC CHỌN
                session.setAttribute("error", "Vui lòng chọn ít nhất một thiết bị!");
                response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
                return;
            }
        } // ========== XỬ LÝ HỖ TRỢ TÀI KHOẢN ==========
        else if ("account".equals(supportType)) {
            ServiceRequest newRequest = new ServiceRequest();
            newRequest.setContractId(null);
            newRequest.setEquipmentId(null);
            newRequest.setCreatedBy(customerId);
            newRequest.setDescription(description.trim());
            newRequest.setPriorityLevel(priorityLevel);
            newRequest.setRequestDate(new Date());
            newRequest.setStatus("Pending");
            newRequest.setRequestType("InformationUpdate");

            int result = serviceRequestDAO.createServiceRequest(newRequest);

            if (result > 0) {
                session.setAttribute("success", "✅ Tạo yêu cầu hỗ trợ tài khoản thành công!");
            } else {
                session.setAttribute("error", "❌ Có lỗi xảy ra khi tạo yêu cầu. Vui lòng thử lại!");
            }

            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        } // ❌ SUPPORTTYPE KHÔNG HỢP LỆ
        else {
            session.setAttribute("error", "Loại hỗ trợ không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }

    }

    private void handleUpdateRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        // ✅ LẤY customerId TỪ SESSION
        Integer customerId = (Integer) session.getAttribute("session_login_id");

        if (customerId == null) {
            session.setAttribute("error", "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

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
            session.setAttribute("success", "Cập nhật yêu cầu thành công!");
        } else {
            session.setAttribute("error", "Có lỗi xảy ra khi cập nhật yêu cầu. Vui lòng thử lại!");
        }
        response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
    }

    private void handleCancelRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        // ✅ LẤY customerId TỪ SESSION
        Integer customerId = (Integer) session.getAttribute("session_login_id");

        if (customerId == null) {
            session.setAttribute("error", "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

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
            session.setAttribute("success", "Đã hủy yêu cầu thành công!");
        } else {
            session.setAttribute("error", "Có lỗi xảy ra khi hủy yêu cầu. Vui lòng thử lại!");
        }
        response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
    }

    /**
     * ✅ XỬ LÝ XEM CHI TIẾT YÊU CẦU Lấy thông tin đầy đủ theo trạng thái: - "Chờ
     * Xác Nhận": Thông tin cơ bản - "Chờ Xử Lý": + Tên người xử lý - "Đang Xử
     * Lý": + Báo giá (RepairReport)
     */
    private void handleViewDetail(HttpServletRequest request, HttpServletResponse response, int customerId)
            throws ServletException, IOException {

        String requestIdStr = request.getParameter("requestId");

        if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\": false, \"message\": \"Mã yêu cầu không hợp lệ!\"}");
            return;
        }

        try {
            int requestId = Integer.parseInt(requestIdStr.trim());

            // Lấy thông tin đầy đủ
            ServiceRequestWithQuotation data = serviceRequestDAO.getRequestWithQuotation(requestId, customerId);

            if (data == null || data.getServiceRequest() == null) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Không tìm thấy yêu cầu!\"}");
                return;
            }

            ServiceRequest sr = data.getServiceRequest();
            String displayStatus = sr.getDisplayStatus();

            // Tạo JSON response
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"success\": true,");
            json.append("\"requestId\": ").append(sr.getRequestId()).append(",");
            json.append("\"contractId\": \"").append(sr.getContractId() != null ? "HD" + String.format("%03d", sr.getContractId()) : "N/A").append("\",");
            json.append("\"equipmentId\": ").append(sr.getEquipmentId() != null ? sr.getEquipmentId() : 0).append(",");
            json.append("\"equipmentName\": \"").append(escapeJson(sr.getEquipmentName() != null ? sr.getEquipmentName() : "N/A")).append("\",");
            json.append("\"description\": \"").append(escapeJson(sr.getDescription())).append("\",");
            json.append("\"priorityLevel\": \"").append(sr.getPriorityLevel()).append("\",");
            json.append("\"requestDate\": \"").append(new java.text.SimpleDateFormat("dd/MM/yyyy").format(sr.getRequestDate())).append("\",");
            json.append("\"displayStatus\": \"").append(escapeJson(displayStatus)).append("\",");
            json.append("\"requestType\": \"").append(sr.getRequestType()).append("\",");
            json.append("\"paymentStatus\": \"").append(sr.getPaymentStatus() != null ? sr.getPaymentStatus() : "Pending").append("\"");

            // ✅ THÊM THÔNG TIN NGƯỜI XỬ LÝ (cho "Chờ Xử Lý")
            if (data.getAssignedTechnicianName() != null) {
                json.append(",\"assignedTechnicianName\": \"").append(escapeJson(data.getAssignedTechnicianName())).append("\"");
            }

            // ✅ THÊM THÔNG TIN BÁO GIÁ (cho "Đang Xử Lý")
            if (data.getRepairReport() != null) {
                RepairReport report = data.getRepairReport();
                json.append(",\"hasQuotation\": true");
                json.append(",\"quotation\": {");
                json.append("\"reportId\": ").append(report.getReportId()).append(",");
                json.append("\"details\": \"").append(escapeJson(report.getDetails() != null ? report.getDetails() : "")).append("\",");
                json.append("\"diagnosis\": \"").append(escapeJson(report.getDiagnosis() != null ? report.getDiagnosis() : "")).append("\",");
                json.append("\"estimatedCost\": ").append(report.getEstimatedCost() != null ? report.getEstimatedCost() : 0).append(",");
                json.append("\"quotationStatus\": \"").append(report.getQuotationStatus() != null ? report.getQuotationStatus() : "Pending").append("\",");
                json.append("\"technicianName\": \"").append(escapeJson(report.getTechnicianName() != null ? report.getTechnicianName() : "N/A")).append("\"");

                if (report.getRepairDate() != null) {
                    json.append(",\"repairDate\": \"").append(report.getRepairDate().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"))).append("\"");
                }

                json.append("}");
            } else {
                json.append(",\"hasQuotation\": false");
            }

            json.append("}");

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(json.toString());

        } catch (NumberFormatException e) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\": false, \"message\": \"Mã yêu cầu phải là số nguyên!\"}");
        } catch (Exception e) {
            System.err.println("❌ Error in handleViewDetail: " + e.getMessage());
            e.printStackTrace();
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\": false, \"message\": \"Có lỗi xảy ra: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    /**
     * ✅ XỬ LÝ ĐỒNG Ý BÁO GIÁ Chuyển hướng sang trang thanh toán
     */
    private void handleAcceptQuotation(HttpServletRequest request, HttpServletResponse response, int customerId)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String requestIdStr = request.getParameter("requestId");

        if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
            session.setAttribute("error", "Mã yêu cầu không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
            return;
        }

        try {
            int requestId = Integer.parseInt(requestIdStr.trim());

            // Kiểm tra request có thuộc về customer không
            ServiceRequest sr = serviceRequestDAO.getRequestById(requestId);

            if (sr == null || sr.getCreatedBy() != customerId) {
                session.setAttribute("error", "Bạn không có quyền xử lý yêu cầu này!");
                response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
                return;
            }

            // Kiểm tra trạng thái hợp lệ (phải là "Đang Xử Lý")
            if (!"Đang Xử Lý".equals(sr.getDisplayStatus())) {
                session.setAttribute("error", "Chỉ có thể thanh toán cho yêu cầu đang xử lý!");
                response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
                return;
            }

            // Kiểm tra có báo giá không
            RepairReport report = serviceRequestDAO.getRepairReportByRequestId(requestId);

            if (report == null || report.getEstimatedCost() == null) {
                session.setAttribute("error", "Không tìm thấy thông tin báo giá!");
                response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
                return;
            }

            // ✅ CHUYỂN SANG TRANG THANH TOÁN
            // TODO: Thay đổi URL này theo đúng payment servlet của bạn
            session.setAttribute("paymentRequestId", requestId);
            session.setAttribute("paymentAmount", report.getEstimatedCost());
            session.setAttribute("success", "Vui lòng tiến hành thanh toán để hoàn tất yêu cầu!");

            // Redirect đến trang thanh toán (bạn cần tạo trang này)
            response.sendRedirect(request.getContextPath() + "/payment?requestId=" + requestId);

        } catch (NumberFormatException e) {
            session.setAttribute("error", "Mã yêu cầu phải là số nguyên!");
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
        } catch (Exception e) {
            System.err.println("❌ Error accepting quotation: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/managerServiceRequest");
        }
    }

    /**
     * Helper method để escape JSON string
     */
    private String escapeJson(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
