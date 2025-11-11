package controller;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;
import dal.AccountDAO;
import dal.ContractAppendixDAO;
import dal.ContractDAO;
import dal.ServiceRequestDAO;
import dal.EquipmentDAO;
import dto.Response;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Contract;
import model.EquipmentWithStatus;
import model.ServiceRequest;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.ContractAppendix;
import jakarta.servlet.http.Part;
import java.io.File;
import java.math.BigDecimal;
import java.time.format.DateTimeParseException;
import model.Account;

@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10, // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
)
@WebServlet(name = "ViewCustomerContractController", urlPatterns = {
    "/viewCustomerContracts", "/getContractEquipment", "/getContractRequests",
    "/getAvailableEquipment",
    "/addContractAppendix",
    "/getContractAppendix",
    "/getAppendixEquipment",
    "/getAppendixDetails",
    "/updateContractAppendix",
    "/deleteContractAppendix",
    "/getAvailableEquipmentForCustomer",
    "/createContract",
    "/deleteContract",
    "/getContractDeletionInfo",
    "/viewAppendixDetails",
    "/getRepairPartAppendixDetails"
})
public class ViewCustomerContractController extends HttpServlet {

    private final ContractDAO contractDAO = new ContractDAO();
    private final EquipmentDAO equipmentDAO = new EquipmentDAO();
    private final ServiceRequestDAO requestDAO = new ServiceRequestDAO();
    private final ContractAppendixDAO appendixDAO = new ContractAppendixDAO();
    private final AccountDAO accountDAO = new AccountDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        try {
            switch (path) {
                case "/viewCustomerContracts":
                    handleListOrSearch(request, response);
                    break;
                case "/getContractEquipment":
                    handleGetContractEquipment(request, response);
                    break;
                case "/getContractRequests":
                    handleGetContractRequests(request, response);
                    break;
                case "/getAvailableEquipment":
                    handleGetAvailableEquipment(request, response);
                    break;
                case "/getContractAppendix":
                    handleGetContractAppendix(request, response);
                    break;
                case "/getAppendixEquipment":
                    handleGetAppendixEquipment(request, response);
                    break;
                case "/getAppendixDetails":
                    handleGetAppendixDetails(request, response);
                    break;
                case "/getAvailableEquipmentForCustomer":
                    handleGetAvailableEquipmentForCustomer(request, response);
                    break;
                case "/getContractDeletionInfo":
                    handleGetContractDeletionInfo(request, response);
                    break;
                case "/viewAppendixDetails":
                    handleViewAppendixDetails(request, response);
                    break;
                case "/getRepairPartAppendixDetails":
                    handleGetRepairPartAppendixDetails(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"Lỗi hệ thống: " + e.getMessage() + "\"}");
        }
    }

    private void handleViewAppendixDetails(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        int appendixId = Integer.parseInt(request.getParameter("appendixId"));

        ContractAppendix appendix = appendixDAO.getAppendixById(appendixId);
        List<Map<String, Object>> equipment = appendixDAO.getEquipmentByAppendixId(appendixId);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("appendix", appendix);
        result.put("equipment", equipment);
        sendJson(response, result);
    }

    // Lấy danh sách hợp đồng (full hoặc theo filter)
    private void handleListOrSearch(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");
        String contractType = request.getParameter("contractType");
        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");

        int page = 1;
        int recordsPerPage = 10;
        if (request.getParameter("page") != null) {
            try {
                page = Integer.parseInt(request.getParameter("page").trim());
                if (page < 1) {
                    page = 1;
                }
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        boolean hasFilter = (keyword != null && !keyword.trim().isEmpty())
                || (status != null && !status.trim().isEmpty())
                || (contractType != null && !contractType.trim().isEmpty())
                || (fromDate != null && !fromDate.trim().isEmpty())
                || (toDate != null && !toDate.trim().isEmpty());

        List<Contract> contractList;
        int totalRecords;

        if (hasFilter) {
            contractList = contractDAO.filterContractsPaged(
                    keyword != null ? keyword.trim() : null,
                    status, contractType, fromDate, toDate,
                    (page - 1) * recordsPerPage,
                    recordsPerPage
            );
            totalRecords = contractDAO.countFilteredContracts(keyword, status, contractType, fromDate, toDate);
        } else {
            contractList = contractDAO.getAllContractsPaged(
                    (page - 1) * recordsPerPage,
                    recordsPerPage
            );
            totalRecords = contractDAO.countAllContracts();
        }

        // Thêm flag canDelete cho mỗi hợp đồng
        for (Contract contract : contractList) {
            boolean canDelete = contractDAO.canDeleteContract(contract.getContractId());
            contract.setCanDelete(canDelete);
        }

        int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
        if (totalPages == 0) {
            totalPages = 1;
        }

        List<Account> customerList = accountDAO.getAccountsByRole("Customer");
        request.setAttribute("customerList", customerList);

        request.setAttribute("contractList", contractList);
        request.setAttribute("paramKeyword", keyword);
        request.setAttribute("paramStatus", status);
        request.setAttribute("paramContractType", contractType);
        request.setAttribute("paramFromDate", fromDate);
        request.setAttribute("paramToDate", toDate);
        request.setAttribute("currentPageNumber", page);
        request.setAttribute("totalPages", totalPages);

        request.getRequestDispatcher("viewCustomerContract.jsp").forward(request, response);
    }

    // API lấy danh sách thiết bị theo hợp đồng
    private void handleGetContractEquipment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        testGsonSerialization();

        int contractId = Integer.parseInt(request.getParameter("contractId"));
        List<EquipmentWithStatus> equipmentList = equipmentDAO.getEquipmentAndAppendixByContractId(contractId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("equipment", equipmentList);
        sendJson(response, result);
    }

    // API lấy danh sách Service Request theo hợp đồng
    private void handleGetContractRequests(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {
        int contractId = Integer.parseInt(request.getParameter("contractId"));
        List<ServiceRequest> requestList = requestDAO.getRequestsByContractIdWithEquipment(contractId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("requests", requestList);
        sendJson(response, result);
    }

    private void sendJson(HttpServletResponse response, Object data) throws IOException {
        response.setContentType("application/json;charset=UTF-8");

        Gson gson = new GsonBuilder()
                .registerTypeAdapter(LocalDate.class, (JsonSerializer<LocalDate>) (src, typeOfSrc, context)
                        -> src == null ? null : new JsonPrimitive(src.toString()))
                .registerTypeAdapter(LocalDateTime.class, (JsonSerializer<LocalDateTime>) (src, typeOfSrc, context)
                        -> src == null ? null : new JsonPrimitive(src.toString()))
                .serializeNulls()
                .setPrettyPrinting()
                .create();

        String json = gson.toJson(data);

        // ✅ DEBUG: Print ACTUAL JSON response
        System.out.println("\n=== ACTUAL JSON RESPONSE TO CLIENT ===");
        System.out.println(json);
        System.out.println("======================================\n");

        PrintWriter out = response.getWriter();
        out.print(json);
        out.flush();
    }

    private void handleGetContractDeletionInfo(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        try {
            String contractIdStr = request.getParameter("contractId");

            if (contractIdStr == null || contractIdStr.trim().isEmpty()) {
                Map<String, Object> errorResult = new HashMap<>();
                errorResult.put("success", false);
                errorResult.put("message", "Contract ID không được để trống");
                sendJson(response, errorResult);
                return;
            }

            int contractId = Integer.parseInt(contractIdStr.trim());
            Map<String, Object> info = contractDAO.getContractDeletionInfo(contractId);

            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("info", info);
            sendJson(response, result);

        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "Lỗi: " + e.getMessage());
            sendJson(response, result);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        try {
            switch (path) {
                case "/addContractAppendix":
                    handleAddContractAppendix(request, response);
                    break;
                case "/updateContractAppendix":
                    handleUpdateContractAppendix(request, response);
                    break;
                case "/deleteContractAppendix":
                    handleDeleteContractAppendix(request, response);
                    break;
                case "/createContract":
                    handleCreateContract(request, response);
                    break;
                case "/deleteContract":
                    handleDeleteContract(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"Lỗi hệ thống: " + e.getMessage() + "\"}");
        }
    }

    // API lấy danh sách thiết bị khả dụng (chưa gán hợp đồng hoặc có thể thêm)
    private void handleGetAvailableEquipment(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {
        List<Map<String, Object>> equipmentList = equipmentDAO.getAllAvailableEquipment();
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("equipment", equipmentList);
        sendJson(response, result);
    }

    // API thêm phụ lục hợp đồng
    private void handleAddContractAppendix(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        try {
            System.out.println("=== DEBUG ADD APPENDIX ===");

            // Lấy các tham số text
            String contractIdStr = request.getParameter("contractId");
            System.out.println("contractId: " + contractIdStr);

            if (contractIdStr == null || contractIdStr.trim().isEmpty()) {
                Map<String, Object> errorResult = new HashMap<>();
                errorResult.put("success", false);
                errorResult.put("message", "Contract ID không được để trống");
                sendJson(response, errorResult);
                return;
            }

            int contractId = Integer.parseInt(contractIdStr.trim());

            String appendixType = request.getParameter("appendixType");
            System.out.println("appendixType: " + appendixType);

            String appendixName = request.getParameter("appendixName");
            String description = request.getParameter("description");
            if (description == null) {
                description = "";
            }

            // Xử lý ngày hiệu lực
            String effectiveDateStr = request.getParameter("effectiveDate");
            LocalDate effectiveDate;

            if (effectiveDateStr == null || effectiveDateStr.trim().isEmpty()) {
                effectiveDate = LocalDate.now();
            } else {
                effectiveDate = LocalDate.parse(effectiveDateStr);
            }

            String status = request.getParameter("status");
            if (status == null || status.trim().isEmpty()) {
                status = "Approved";
            }

            // XỬ LÝ UPLOAD FILE
            String fileUrl = null;
            Part filePart = request.getPart("fileAttachment");

            if (filePart != null && filePart.getSize() > 0) {
                String fileName = getFileName(filePart);
                System.out.println("Uploading file: " + fileName);

                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "appendix";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                String fileExtension = fileName.substring(fileName.lastIndexOf("."));
                String uniqueFileName = "appendix_" + contractId + "_" + System.currentTimeMillis() + fileExtension;
                String filePath = uploadPath + File.separator + uniqueFileName;

                filePart.write(filePath);
                fileUrl = "uploads/appendix/" + uniqueFileName;
                System.out.println("File saved: " + fileUrl);
            }

            // XỬ LÝ EQUIPMENT IDS
            String equipmentIdsJson = request.getParameter("equipmentIds");
            System.out.println("equipmentIds JSON: " + equipmentIdsJson);

            int[] equipmentIds = null;

            if (equipmentIdsJson != null && !equipmentIdsJson.trim().isEmpty()
                    && !equipmentIdsJson.equals("[]")) {
                Gson gson = new Gson();
                equipmentIds = gson.fromJson(equipmentIdsJson, int[].class);
            }

            // ✅ VALIDATE: AddEquipment BẮT BUỘC có thiết bị
            if ("AddEquipment".equals(appendixType)) {
                if (equipmentIds == null || equipmentIds.length == 0) {
                    Map<String, Object> errorResult = new HashMap<>();
                    errorResult.put("success", false);
                    errorResult.put("message", "Loại phụ lục 'Thêm thiết bị' yêu cầu chọn ít nhất một thiết bị");
                    sendJson(response, errorResult);
                    return;
                }
                System.out.println("✓ AddEquipment type - Equipment count: " + equipmentIds.length);
            } else {
                System.out.println("ℹ Other type - Equipment not required");
                if (equipmentIds == null || equipmentIds.length == 0) {
                    System.out.println("  No equipment selected (OK for Other type)");
                } else {
                    System.out.println("  Equipment selected: " + equipmentIds.length);
                }
            }

            model.Account user = (model.Account) request.getSession().getAttribute("session_login");
            int createdBy = user != null ? user.getAccountId() : 0;

            System.out.println("Creating appendix...");

            // Tạo phụ lục
            int appendixId = appendixDAO.createAppendix(
                    contractId,
                    appendixType,
                    appendixName,
                    description,
                    effectiveDate,
                    0.0,
                    status,
                    fileUrl,
                    createdBy
            );

            System.out.println("Created appendix ID: " + appendixId);

            // Thêm thiết bị (nếu có)
            if (equipmentIds != null && equipmentIds.length > 0) {
                for (int equipmentId : equipmentIds) {
                    appendixDAO.addEquipmentToAppendix(appendixId, equipmentId, null, null);
                    System.out.println("Added equipment " + equipmentId + " to appendix " + appendixId);
                }
            } else {
                System.out.println("No equipment added (Other type appendix)");
            }

            Map<String, Object> result = new HashMap<>();
            result.put("success", true);

            if ("AddEquipment".equals(appendixType)) {
                result.put("message", "Đã thêm phụ lục hợp đồng với " + equipmentIds.length + " thiết bị thành công");
            } else {
                result.put("message", "Đã thêm phụ lục thông tin thành công");
            }

            result.put("appendixId", appendixId);
            sendJson(response, result);

        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "Lỗi khi thêm phụ lục: " + e.getMessage());
            sendJson(response, result);
        }
    }

// Helper method để lấy tên file
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        for (String content : contentDisposition.split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }

    // API lấy danh sách phụ lục theo hợp đồng
    private void handleGetContractAppendix(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        int contractId = Integer.parseInt(request.getParameter("contractId"));
        List<ContractAppendix> appendixList = appendixDAO.getAppendixesByContractId(contractId);

        // ✅ Thêm thông tin canEdit và canDelete cho mỗi phụ lục
        for (ContractAppendix appendix : appendixList) {
            boolean withinEditPeriod = appendixDAO.canEditAppendix(appendix.getAppendixId());
            boolean hasNonPending = hasNonPendingServiceRequests(appendix.getAppendixId());

            // ✅ CHỈ cho phép EDIT nếu: trong vòng 15 ngày VÀ không có request nào khác Pending/Cancelled
            boolean canEdit = withinEditPeriod && !hasNonPending;
            appendix.setCanEdit(canEdit);

            // ✅ CHỈ cho phép DELETE nếu: trong vòng 15 ngày VÀ không có request nào khác Pending/Cancelled
            boolean canDelete = withinEditPeriod && !hasNonPending;
            appendix.setCanDelete(canDelete);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("appendixes", appendixList);
        sendJson(response, result);
    }

    // API lấy danh sách thiết bị trong phụ lục
    private void handleGetAppendixEquipment(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        int appendixId = Integer.parseInt(request.getParameter("appendixId"));
        List<Map<String, Object>> equipmentList = appendixDAO.getEquipmentByAppendixId(appendixId);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("equipment", equipmentList);
        sendJson(response, result);
    }

    //Lấy chi tiết phụ lục để edit
    private void handleGetAppendixDetails(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        int appendixId = Integer.parseInt(request.getParameter("appendixId"));

        // ✅ Kiểm tra xem có thể edit không (trong vòng 15 ngày VÀ không có request nào đang xử lý)
        boolean withinEditPeriod = appendixDAO.canEditAppendix(appendixId);
        boolean hasNonPending = hasNonPendingServiceRequests(appendixId);

        if (!withinEditPeriod || hasNonPending) {
            Map<String, Object> errorResult = new HashMap<>();
            errorResult.put("success", false);

            if (!withinEditPeriod) {
                errorResult.put("message", "Phụ lục này đã quá 15 ngày, không thể chỉnh sửa");
            } else {
                errorResult.put("message", "Không thể chỉnh sửa phụ lục vì có yêu cầu dịch vụ đang được xử lý");
            }

            sendJson(response, errorResult);
            return;
        }

        ContractAppendix appendix = appendixDAO.getAppendixById(appendixId);
        List<Map<String, Object>> equipment = appendixDAO.getEquipmentByAppendixId(appendixId);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("appendix", appendix);
        result.put("equipment", equipment);
        sendJson(response, result);
    }

// Cập nhật phụ lục
    private void handleUpdateContractAppendix(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        System.out.println("=== UPDATE APPENDIX REQUEST ===");

        try {
            String appendixIdStr = request.getParameter("appendixId");
            System.out.println("appendixId: " + appendixIdStr);

            if (appendixIdStr == null || appendixIdStr.trim().isEmpty()) {
                Map<String, Object> errorResult = new HashMap<>();
                errorResult.put("success", false);
                errorResult.put("message", "Appendix ID không được để trống");
                sendJson(response, errorResult);
                return;
            }

            int appendixId = Integer.parseInt(appendixIdStr.trim());
            System.out.println("Parsed appendixId: " + appendixId);

            // ✅ Kiểm tra xem có thể edit không
            boolean withinEditPeriod = appendixDAO.canEditAppendix(appendixId);
            boolean hasNonPending = hasNonPendingServiceRequests(appendixId);

            System.out.println("Within edit period: " + withinEditPeriod);
            System.out.println("Has non-pending requests: " + hasNonPending);

            if (!withinEditPeriod) {
                Map<String, Object> errorResult = new HashMap<>();
                errorResult.put("success", false);
                errorResult.put("message", "Phụ lục này đã quá 15 ngày, không thể chỉnh sửa");
                sendJson(response, errorResult);
                return;
            }

            if (hasNonPending) {
                Map<String, Object> errorResult = new HashMap<>();
                errorResult.put("success", false);
                errorResult.put("message", "Không thể chỉnh sửa phụ lục vì có yêu cầu dịch vụ đang được xử lý (Approved/In Progress/Completed)");
                sendJson(response, errorResult);
                return;
            }

            String appendixType = request.getParameter("appendixType");
            String appendixName = request.getParameter("appendixName");
            String description = request.getParameter("description");
            if (description == null) {
                description = "";
            }

            System.out.println("appendixType: " + appendixType);
            System.out.println("appendixName: " + appendixName);
            System.out.println("description: " + description);

            // XỬ LÝ LocalDate
            String effectiveDateStr = request.getParameter("effectiveDate");
            System.out.println("effectiveDate string: " + effectiveDateStr);

            LocalDate effectiveDate;
            if (effectiveDateStr == null || effectiveDateStr.trim().isEmpty()) {
                effectiveDate = LocalDate.now();
            } else {
                try {
                    effectiveDate = LocalDate.parse(effectiveDateStr);
                } catch (DateTimeParseException e) {
                    System.err.println("Invalid date format: " + effectiveDateStr);
                    e.printStackTrace();
                    effectiveDate = LocalDate.now();
                }
            }

            System.out.println("Parsed effectiveDate: " + effectiveDate);

            String status = request.getParameter("status");
            System.out.println("status: " + status);

            // Xử lý file upload (nếu có)
            String fileUrl = null;
            Part filePart = request.getPart("fileAttachment");
            System.out.println("File part: " + (filePart != null ? filePart.getSize() + " bytes" : "null"));

            if (filePart != null && filePart.getSize() > 0) {
                String fileName = getFileName(filePart);
                System.out.println("Uploading file: " + fileName);

                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "appendix";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                String fileExtension = fileName.substring(fileName.lastIndexOf("."));
                String uniqueFileName = "appendix_" + appendixId + "_" + System.currentTimeMillis() + fileExtension;
                String filePath = uploadPath + File.separator + uniqueFileName;

                filePart.write(filePath);
                fileUrl = "uploads/appendix/" + uniqueFileName;
                System.out.println("File saved: " + fileUrl);
            } else {
                // Giữ nguyên file cũ
                ContractAppendix oldAppendix = appendixDAO.getAppendixById(appendixId);
                fileUrl = oldAppendix.getFileAttachment();
                System.out.println("Keeping old file: " + fileUrl);
            }

            System.out.println("Calling updateAppendix...");

            // Cập nhật phụ lục
            boolean updated = appendixDAO.updateAppendix(
                    appendixId, appendixType, appendixName, description,
                    effectiveDate,
                    status, fileUrl
            );

            System.out.println("Update result: " + updated);

            // Cập nhật thiết bị
            String equipmentIdsJson = request.getParameter("equipmentIds");
            System.out.println("equipmentIds JSON: " + equipmentIdsJson);

            if (equipmentIdsJson != null && !equipmentIdsJson.trim().isEmpty()) {
                Gson gson = new Gson();
                int[] equipmentIds = gson.fromJson(equipmentIdsJson, int[].class);
                System.out.println("Parsed equipment IDs: " + Arrays.toString(equipmentIds));

                // Xóa tất cả thiết bị cũ
                System.out.println("Removing old equipment...");
                appendixDAO.removeAllEquipmentFromAppendix(appendixId);

                // Thêm lại thiết bị mới
                System.out.println("Adding new equipment...");
                for (int equipmentId : equipmentIds) {
                    appendixDAO.addEquipmentToAppendix(appendixId, equipmentId, null, null);
                    System.out.println("Added equipment: " + equipmentId);
                }
            }

            Map<String, Object> result = new HashMap<>();
            if (updated) {
                result.put("success", true);
                result.put("message", "Đã cập nhật phụ lục thành công");
            } else {
                result.put("success", false);
                result.put("message", "Không thể cập nhật phụ lục");
            }

            System.out.println("Sending response: " + result);
            sendJson(response, result);

        } catch (NumberFormatException e) {
            System.err.println("NumberFormatException:");
            e.printStackTrace();
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "Lỗi định dạng số: " + e.getMessage());
            sendJson(response, result);

        } catch (SQLException e) {
            System.err.println("SQLException:");
            e.printStackTrace();
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "Lỗi database: " + e.getMessage());
            sendJson(response, result);

        } catch (Exception e) {
            System.err.println("General Exception:");
            e.printStackTrace();
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "Lỗi hệ thống: " + e.getMessage());
            sendJson(response, result);
        }

        System.out.println("=== END UPDATE APPENDIX ===");
    }
// Xóa phụ lục

    private void handleDeleteContractAppendix(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        try {
            int appendixId = Integer.parseInt(request.getParameter("appendixId"));

            System.out.println("\n╔════════════════════════════════════════════════════════════╗");
            System.out.println("║  DELETE APPENDIX REQUEST FOR ID: " + appendixId);
            System.out.println("╚════════════════════════════════════════════════════════════╝");

            // Kiểm tra xem có thể xóa không (trong vòng 15 ngày)
            if (!appendixDAO.canEditAppendix(appendixId)) {
                Map<String, Object> errorResult = new HashMap<>();
                errorResult.put("success", false);
                errorResult.put("message", "Phụ lục này đã quá 15 ngày, không thể xóa");
                sendJson(response, errorResult);
                return;
            }

            // Lấy thông tin phụ lục
            ContractAppendix appendix = appendixDAO.getAppendixById(appendixId);
            System.out.println("📄 Appendix type: " + appendix.getAppendixType());
            System.out.println("📄 Equipment count: " + appendix.getEquipmentCount());

            // Chỉ xử lý requests nếu có thiết bị
            if (appendix.getEquipmentCount() > 0) {
                // Kiểm tra non-pending requests
                if (hasNonPendingServiceRequests(appendixId)) {
                    Map<String, Object> errorResult = new HashMap<>();
                    errorResult.put("success", false);
                    errorResult.put("message", "Không thể xóa phụ lục này vì có yêu cầu dịch vụ đã được xử lý");
                    sendJson(response, errorResult);
                    return;
                }

                // ✅ XÓA PENDING REQUESTS
                ServiceRequestDAO srDAO = new ServiceRequestDAO();
                int deletedCount = srDAO.deletePendingRequestsForAppendix(appendixId);
                System.out.println("🗑️ Total pending requests deleted: " + deletedCount);

                // ✅ VERIFY: Debug lại sau khi xóa
                System.out.println("\n--- VERIFICATION AFTER DELETE ---");
                srDAO.debugServiceRequestsForAppendix(appendixId);

            } else {
                System.out.println("ℹ️ No equipment in appendix, skipping request deletion");
            }

            // Xóa phụ lục
            System.out.println("🗑️ Now deleting appendix...");
            boolean deleted = appendixDAO.deleteAppendix(appendixId);
            System.out.println("📊 Appendix deletion result: " + deleted);

            Map<String, Object> result = new HashMap<>();
            if (deleted) {
                result.put("success", true);
                if (appendix.getEquipmentCount() > 0) {
                    result.put("message", "Đã xóa phụ lục và các yêu cầu Pending liên quan thành công");
                } else {
                    result.put("message", "Đã xóa phụ lục thông tin thành công");
                }
            } else {
                result.put("success", false);
                result.put("message", "Không thể xóa phụ lục");
            }

            System.out.println("\n╔════════════════════════════════════════════════════════════╗");
            System.out.println("║  DELETION COMPLETED");
            System.out.println("╚════════════════════════════════════════════════════════════╝\n");

            sendJson(response, result);

        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "Lỗi khi xóa phụ lục: " + e.getMessage());
            sendJson(response, result);
        }
    }

    // Lấy danh sách thiết bị khả dụng cho khách hàng (chưa được dùng trong hợp đồng/phụ lục nào)
    private void handleGetAvailableEquipmentForCustomer(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        String customerIdStr = request.getParameter("customerId");

        if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
            Map<String, Object> errorResult = new HashMap<>();
            errorResult.put("success", false);
            errorResult.put("message", "Customer ID không được để trống");
            sendJson(response, errorResult);
            return;
        }

        int customerId = Integer.parseInt(customerIdStr.trim());

        // Lấy tất cả thiết bị chưa được dùng (không có trong bất kỳ hợp đồng hoặc phụ lục nào)
        List<Map<String, Object>> equipmentList = equipmentDAO.getAvailableEquipmentNotInAnyContract();

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("equipment", equipmentList);
        sendJson(response, result);
    }

// Tạo hợp đồng mới
    private void handleCreateContract(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        try {
            System.out.println("=== CREATE CONTRACT ===");

            String customerIdStr = request.getParameter("customerId");
            String contractType = request.getParameter("contractType");
            String contractDateStr = request.getParameter("contractDate");
            String status = request.getParameter("status");
            String details = request.getParameter("details");

            // Validation...
            if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
                Map<String, Object> errorResult = new HashMap<>();
                errorResult.put("success", false);
                errorResult.put("message", "Vui lòng chọn khách hàng");
                sendJson(response, errorResult);
                return;
            }

            if (details == null || details.trim().length() < 10 || details.trim().length() > 255) {
                Map<String, Object> errorResult = new HashMap<>();
                errorResult.put("success", false);
                errorResult.put("message", "Chi tiết hợp đồng phải từ 10-255 ký tự");
                sendJson(response, errorResult);
                return;
            }

            int customerId = Integer.parseInt(customerIdStr.trim());
            LocalDate contractDate = LocalDate.parse(contractDateStr);

            if (contractDate.isAfter(LocalDate.now())) {
                Map<String, Object> errorResult = new HashMap<>();
                errorResult.put("success", false);
                errorResult.put("message", "Ngày ký hợp đồng không được ở tương lai");
                sendJson(response, errorResult);
                return;
            }

            String equipmentIdsJson = request.getParameter("equipmentIds");
            if (equipmentIdsJson == null || equipmentIdsJson.trim().isEmpty()) {
                Map<String, Object> errorResult = new HashMap<>();
                errorResult.put("success", false);
                errorResult.put("message", "Vui lòng chọn ít nhất một thiết bị");
                sendJson(response, errorResult);
                return;
            }

            Gson gson = new Gson();
            int[] equipmentIds = gson.fromJson(equipmentIdsJson, int[].class);

            if (equipmentIds == null || equipmentIds.length == 0) {
                Map<String, Object> errorResult = new HashMap<>();
                errorResult.put("success", false);
                errorResult.put("message", "Vui lòng chọn ít nhất một thiết bị");
                sendJson(response, errorResult);
                return;
            }

            // Tạo hợp đồng với createdDate = NOW()
            int contractId = contractDAO.createContractWithCreatedDate(
                    customerId, contractDate, contractType, status, details.trim()
            );

            System.out.println("Created contract ID: " + contractId);

            if (contractId <= 0) {
                Map<String, Object> errorResult = new HashMap<>();
                errorResult.put("success", false);
                errorResult.put("message", "Không thể tạo hợp đồng");
                sendJson(response, errorResult);
                return;
            }

            // ✅ Thêm thiết bị vào hợp đồng với startDate và endDate tự động
            for (int equipmentId : equipmentIds) {
                contractDAO.addEquipmentToContract(
                        contractId,
                        equipmentId,
                        contractDate // Chỉ cần truyền contractDate
                );
                System.out.println("Added equipment " + equipmentId + " to contract " + contractId);
            }

            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "Đã tạo hợp đồng thành công với " + equipmentIds.length
                    + " thiết bị (bảo hành 3 năm)");
            result.put("contractId", contractId);
            sendJson(response, result);

        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "Lỗi khi tạo hợp đồng: " + e.getMessage());
            sendJson(response, result);
        }
    }

    private boolean hasNonPendingServiceRequests(int appendixId) throws SQLException {
        ServiceRequestDAO srDAO = new ServiceRequestDAO();
        return srDAO.hasNonPendingRequestsForAppendix(appendixId);
    }

    // Handler xóa cứng hợp đồng
    private void handleDeleteContract(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        try {
            String contractIdStr = request.getParameter("contractId");

            if (contractIdStr == null || contractIdStr.trim().isEmpty()) {
                Map<String, Object> errorResult = new HashMap<>();
                errorResult.put("success", false);
                errorResult.put("message", "Contract ID không được để trống");
                sendJson(response, errorResult);
                return;
            }

            int contractId = Integer.parseInt(contractIdStr.trim());

            System.out.println("=== DELETE CONTRACT REQUEST ===");
            System.out.println("Contract ID: " + contractId);

            // Kiểm tra xem có thể xóa không
            if (!contractDAO.canDeleteContract(contractId)) {
                Map<String, Object> errorResult = new HashMap<>();
                errorResult.put("success", false);
                errorResult.put("message", "Không thể xóa hợp đồng này. Hợp đồng đã quá 15 ngày, có phụ lục, có yêu cầu dịch vụ hoặc đã bị hủy.");
                sendJson(response, errorResult);
                return;
            }

            // Xóa cứng hợp đồng
            boolean deleted = contractDAO.hardDeleteContract(contractId);

            Map<String, Object> result = new HashMap<>();
            if (deleted) {
                result.put("success", true);
                result.put("message", "Đã xóa hợp đồng #" + contractId + " thành công");
            } else {
                result.put("success", false);
                result.put("message", "Không thể xóa hợp đồng. Hợp đồng không tồn tại hoặc đã bị xóa.");
            }
            sendJson(response, result);

        } catch (NumberFormatException e) {
            System.err.println("Invalid contract ID format:");
            e.printStackTrace();
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "Contract ID không hợp lệ");
            sendJson(response, result);

        } catch (SQLException e) {
            System.err.println("Database error during delete:");
            e.printStackTrace();
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "Lỗi database: " + e.getMessage());
            sendJson(response, result);

        } catch (Exception e) {
            System.err.println("Unexpected error during delete:");
            e.printStackTrace();
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "Lỗi hệ thống: " + e.getMessage());
            sendJson(response, result);
        }
    }

    private void handleGetRepairPartAppendixDetails(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        int appendixId = Integer.parseInt(request.getParameter("appendixId"));

        ContractAppendix appendix = appendixDAO.getAppendixById(appendixId);
        List<Map<String, Object>> parts = appendixDAO.getRepairPartsByAppendixId(appendixId);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("appendix", appendix);
        result.put("parts", parts);
        sendJson(response, result);
    }

    private void testGsonSerialization() {
        System.out.println("\n=== GSON SERIALIZATION TEST ===");

        // Tạo test object
        EquipmentWithStatus testEq = new EquipmentWithStatus();
        testEq.setEquipmentId(999);
        testEq.setModel("Test Model");
        testEq.setSerialNumber("TEST-001");
        testEq.setDescription("Test Description");
        testEq.setStartDate(LocalDate.of(2024, 1, 1));
        testEq.setEndDate(LocalDate.of(2027, 1, 1));
        testEq.setStatus("Active");
        testEq.setSource("Contract");
        testEq.setPrice(new BigDecimal("50000000"));

        // Test Gson
        Gson gson = new GsonBuilder()
                .registerTypeAdapter(LocalDate.class, (JsonSerializer<LocalDate>) (src, typeOfSrc, context)
                        -> src == null ? null : new JsonPrimitive(src.toString()))
                .serializeNulls()
                .setPrettyPrinting()
                .create();

        String json = gson.toJson(testEq);
        System.out.println("Test JSON:");
        System.out.println(json);
        System.out.println("================================\n");
    }

}
