package controller;

import dal.ContractDAO;
import dal.ContractDAO.ContractWithCustomer;
import dal.ContractDAO.Customer;
import model.Contract;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "ContractServlet", urlPatterns = {"/managerContracts"})
public class ContractServlet extends HttpServlet {

    private ContractDAO contractDAO;

    @Override
    public void init() throws ServletException {
        contractDAO = new ContractDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if ("search".equals(action)) {
            handleSearch(request, response);
        } else if ("filter".equals(action)) {
            handleFilter(request, response);
        } else {
            displayAllContracts(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if ("create".equals(action)) {
            handleCreateContract(request, response);
        } else if ("update".equals(action)) {
            handleUpdateContract(request, response);
        } else if ("renew".equals(action)) {
            handleRenewContract(request, response);
        } else if ("activate".equals(action)) {
            handleActivateContract(request, response);
        }
    }

    private void displayAllContracts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Phân trang
            int page = 1;
            int pageSize = 10;
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.trim().isEmpty()) {
                try {
                    page = Integer.parseInt(pageParam);
                    if (page < 1) page = 1;
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }

            // Lấy danh sách hợp đồng
            List<ContractWithCustomer> contracts = contractDAO.searchContracts(null, null, page, pageSize);
            int totalContracts = contractDAO.getContractCount(null, null);
            int totalPages = (int) Math.ceil((double) totalContracts / pageSize);

            // Thống kê
            int activeCount = contractDAO.getContractCount(null, "Active");
            int pendingCount = contractDAO.getContractCount(null, "Pending");
            int expiredCount = contractDAO.getContractCount(null, "Expired");
            int terminatedCount = contractDAO.getContractCount(null, "Terminated");

            // Đếm hợp đồng sắp hết hạn (trong vòng 30 ngày)
            int expiringCount = countExpiringContracts(contracts);

            request.setAttribute("contracts", contracts);
            request.setAttribute("totalContracts", totalContracts);
            request.setAttribute("activeCount", activeCount);
            request.setAttribute("pendingCount", pendingCount);
            request.setAttribute("expiredCount", expiredCount);
            request.setAttribute("terminatedCount", terminatedCount);
            request.setAttribute("expiringCount", expiringCount);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);

            request.getRequestDispatcher("/managerContracts.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tải danh sách hợp đồng: " + e.getMessage());
            request.getRequestDispatcher("/managerContracts.jsp").forward(request, response);
        }
    }

    private void handleSearch(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");

        try {
            int page = 1;
            int pageSize = 10;
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.trim().isEmpty()) {
                try {
                    page = Integer.parseInt(pageParam);
                    if (page < 1) page = 1;
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }

            List<ContractWithCustomer> contracts = contractDAO.searchContracts(keyword, null, page, pageSize);
            int totalContracts = contractDAO.getContractCount(keyword, null);
            int totalPages = (int) Math.ceil((double) totalContracts / pageSize);

            // Thống kê
            int activeCount = contractDAO.getContractCount(null, "Active");
            int pendingCount = contractDAO.getContractCount(null, "Pending");
            int expiredCount = contractDAO.getContractCount(null, "Expired");
            int terminatedCount = contractDAO.getContractCount(null, "Terminated");
            int expiringCount = countExpiringContracts(contracts);

            request.setAttribute("contracts", contracts);
            request.setAttribute("totalContracts", totalContracts);
            request.setAttribute("activeCount", activeCount);
            request.setAttribute("pendingCount", pendingCount);
            request.setAttribute("expiredCount", expiredCount);
            request.setAttribute("terminatedCount", terminatedCount);
            request.setAttribute("expiringCount", expiringCount);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("keyword", keyword);
            request.setAttribute("searchMode", true);

            request.getRequestDispatcher("/managerContracts.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tìm kiếm: " + e.getMessage());
            request.getRequestDispatcher("/managerContracts.jsp").forward(request, response);
        }
    }

    private void handleFilter(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String status = request.getParameter("status");
        String type = request.getParameter("type");

        try {
            int page = 1;
            int pageSize = 10;
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.trim().isEmpty()) {
                try {
                    page = Integer.parseInt(pageParam);
                    if (page < 1) page = 1;
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }

            List<ContractWithCustomer> contracts = contractDAO.searchContracts(null, status, page, pageSize);
            int totalContracts = contractDAO.getContractCount(null, status);
            int totalPages = (int) Math.ceil((double) totalContracts / pageSize);

            // Thống kê
            int activeCount = contractDAO.getContractCount(null, "Active");
            int pendingCount = contractDAO.getContractCount(null, "Pending");
            int expiredCount = contractDAO.getContractCount(null, "Expired");
            int terminatedCount = contractDAO.getContractCount(null, "Terminated");
            int expiringCount = countExpiringContracts(contracts);

            request.setAttribute("contracts", contracts);
            request.setAttribute("totalContracts", totalContracts);
            request.setAttribute("activeCount", activeCount);
            request.setAttribute("pendingCount", pendingCount);
            request.setAttribute("expiredCount", expiredCount);
            request.setAttribute("terminatedCount", terminatedCount);
            request.setAttribute("expiringCount", expiringCount);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("filterStatus", status);
            request.setAttribute("filterType", type);
            request.setAttribute("filterMode", true);

            request.getRequestDispatcher("/managerContracts.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi lọc: " + e.getMessage());
            request.getRequestDispatcher("/managerContracts.jsp").forward(request, response);
        }
    }

    private void handleCreateContract(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String customerIdStr = request.getParameter("customerId");
        String contractType = request.getParameter("contractType");
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
        String contractValueStr = request.getParameter("contractValue");
        String terms = request.getParameter("terms");
        String notes = request.getParameter("notes");

        // Validation
        if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng nhập mã khách hàng!");
            response.sendRedirect(request.getContextPath() + "/contracts");
            return;
        }

        if (contractType == null || contractType.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng chọn loại hợp đồng!");
            response.sendRedirect(request.getContextPath() + "/contracts");
            return;
        }

        if (startDateStr == null || startDateStr.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng chọn ngày bắt đầu!");
            response.sendRedirect(request.getContextPath() + "/contracts");
            return;
        }

        if (endDateStr == null || endDateStr.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng chọn ngày kết thúc!");
            response.sendRedirect(request.getContextPath() + "/contracts");
            return;
        }

        try {
            int customerId = Integer.parseInt(customerIdStr.trim());
            LocalDate startDate = LocalDate.parse(startDateStr);
            LocalDate endDate = LocalDate.parse(endDateStr);

            // Kiểm tra ngày
            if (endDate.isBefore(startDate) || endDate.isEqual(startDate)) {
                session.setAttribute("error", "Ngày kết thúc phải sau ngày bắt đầu!");
                response.sendRedirect(request.getContextPath() + "/contracts");
                return;
            }

            // Tạo details từ terms và notes
            String details = "";
            if (terms != null && !terms.trim().isEmpty()) {
                details = "Điều khoản: " + terms.trim();
            }
            if (notes != null && !notes.trim().isEmpty()) {
                if (!details.isEmpty()) details += "\n";
                details += "Ghi chú: " + notes.trim();
            }
            if (details.isEmpty()) {
                details = "Hợp đồng " + contractType;
            }

            // Tạo hợp đồng
            long newContractId = contractDAO.createContract(
                customerId,
                Date.valueOf(startDate),
                contractType,
                "Pending", // Trạng thái mặc định
                details
            );

            if (newContractId > 0) {
                session.setAttribute("success", "Tạo hợp đồng thành công! Mã hợp đồng: #CT" + String.format("%03d", newContractId));
            } else {
                session.setAttribute("error", "Đã có lỗi xảy ra khi tạo hợp đồng!");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("error", "Mã khách hàng phải là số nguyên!");
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Lỗi: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/contracts");
    }

    private void handleUpdateContract(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String contractIdStr = request.getParameter("contractId");
        String contractType = request.getParameter("contractType");
        String status = request.getParameter("status");
        String endDateStr = request.getParameter("endDate");
        String contractValueStr = request.getParameter("contractValue");
        String terms = request.getParameter("terms");
        String notes = request.getParameter("notes");

        if (contractIdStr == null || contractIdStr.trim().isEmpty()) {
            session.setAttribute("error", "Mã hợp đồng không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/contracts");
            return;
        }

        try {
            int contractId = Integer.parseInt(contractIdStr.trim());

            // Lấy hợp đồng hiện tại
            Contract contract = contractDAO.getContractById(contractId);
            if (contract == null) {
                session.setAttribute("error", "Không tìm thấy hợp đồng!");
                response.sendRedirect(request.getContextPath() + "/contracts");
                return;
            }

            // Cập nhật status
            if (status != null && !status.trim().isEmpty()) {
                boolean success = contractDAO.updateContractStatus(contractId, status);
                if (success) {
                    session.setAttribute("success", "Cập nhật hợp đồng #CT" + String.format("%03d", contractId) + " thành công!");
                } else {
                    session.setAttribute("error", "Có lỗi khi cập nhật hợp đồng!");
                }
            }

        } catch (NumberFormatException e) {
            session.setAttribute("error", "Mã hợp đồng phải là số nguyên!");
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/contracts");
    }

    private void handleRenewContract(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String contractIdStr = request.getParameter("contractId");
        String renewalPeriodStr = request.getParameter("renewalPeriod");
        String renewalNote = request.getParameter("renewalNote");

        if (contractIdStr == null || contractIdStr.trim().isEmpty()) {
            session.setAttribute("error", "Mã hợp đồng không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/contracts");
            return;
        }

        try {
            int contractId = Integer.parseInt(contractIdStr.trim());
            int renewalPeriod = Integer.parseInt(renewalPeriodStr.trim());

            // Lấy hợp đồng hiện tại
            Contract contract = contractDAO.getContractById(contractId);
            if (contract == null) {
                session.setAttribute("error", "Không tìm thấy hợp đồng!");
                response.sendRedirect(request.getContextPath() + "/contracts");
                return;
            }

            // Tạo hợp đồng mới (gia hạn)
            LocalDate newStartDate = contract.getContractDate().plusMonths(renewalPeriod);
            LocalDate newEndDate = newStartDate.plusMonths(renewalPeriod);

            String details = "Gia hạn từ hợp đồng #CT" + String.format("%03d", contractId);
            if (renewalNote != null && !renewalNote.trim().isEmpty()) {
                details += "\nGhi chú: " + renewalNote.trim();
            }

            long newContractId = contractDAO.createContract(
                contract.getCustomerId(),
                Date.valueOf(newStartDate),
                contract.getContractType(),
                "Pending",
                details
            );

            if (newContractId > 0) {
                session.setAttribute("success", "Gia hạn thành công! Hợp đồng mới: #CT" + String.format("%03d", newContractId));
            } else {
                session.setAttribute("error", "Đã có lỗi xảy ra khi gia hạn!");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("error", "Dữ liệu không hợp lệ!");
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/contracts");
    }

    private void handleActivateContract(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String contractIdStr = request.getParameter("contractId");

        if (contractIdStr == null || contractIdStr.trim().isEmpty()) {
            session.setAttribute("error", "Mã hợp đồng không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/contracts");
            return;
        }

        try {
            int contractId = Integer.parseInt(contractIdStr.trim());

            boolean success = contractDAO.updateContractStatus(contractId, "Active");

            if (success) {
                session.setAttribute("success", "Kích hoạt hợp đồng #CT" + String.format("%03d", contractId) + " thành công!");
            } else {
                session.setAttribute("error", "Có lỗi khi kích hoạt hợp đồng!");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("error", "Mã hợp đồng phải là số nguyên!");
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/contracts");
    }

    // Helper method: Đếm hợp đồng sắp hết hạn
    private int countExpiringContracts(List<ContractWithCustomer> contracts) {
        int count = 0;
        LocalDate today = LocalDate.now();
        LocalDate thirtyDaysLater = today.plusDays(30);

        for (ContractWithCustomer cwc : contracts) {
            Contract contract = cwc.getContract();
            if (contract.getContractDate() != null) {
                LocalDate contractDate = contract.getContractDate();
                if (contractDate.isAfter(today) && contractDate.isBefore(thirtyDaysLater)) {
                    count++;
                }
            }
        }
        return count;
    }
}