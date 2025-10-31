package controller;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;
import dal.ContractDAO;
import dal.ServiceRequestDAO;
import dal.EquipmentDAO;
import dto.Response;
import jakarta.servlet.ServletException;
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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ViewCustomerContractController", urlPatterns = {
    "/viewCustomerContracts", "/getContractEquipment", "/getContractRequests"
})
public class ViewCustomerContractController extends HttpServlet {

    private final ContractDAO contractDAO = new ContractDAO();
    private final EquipmentDAO equipmentDAO = new EquipmentDAO();
    private final ServiceRequestDAO requestDAO = new ServiceRequestDAO();

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
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"Lỗi hệ thống: " + e.getMessage() + "\"}");
        }
    }

    // ✅ Lấy danh sách hợp đồng (full hoặc theo filter)
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

        int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
        if (totalPages == 0) {
            totalPages = 1;
        }

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

    // ✅ API lấy danh sách thiết bị theo hợp đồng
    private void handleGetContractEquipment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int contractId = Integer.parseInt(request.getParameter("contractId"));
        List<EquipmentWithStatus> equipmentList = equipmentDAO.getEquipmentByContractId(contractId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("equipment", equipmentList);
        sendJson(response, result);
    }

    // ✅ API lấy danh sách Service Request theo hợp đồng
    private void handleGetContractRequests(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
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
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(data));
        out.flush();
    }
}
