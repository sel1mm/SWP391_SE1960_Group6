package controller;

import dal.PartDetailDAO;
import dal.PartDetailHistoryDAO; // THÊM MỚI
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.Comparator;
import java.util.List;
import model.Account;
import model.NewPartDetail;

/**
 * PartDetailServlet - Quản lý chi tiết thiết bị (CÓ LƯU LỊCH SỬ)
 * @author Admin
 */
public class PartDetailServlet extends HttpServlet {
    
    private PartDetailDAO dao = new PartDetailDAO();
    private PartDetailHistoryDAO historyDAO = new PartDetailHistoryDAO(); // THÊM MỚI

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account acc = (Account) session.getAttribute("session_login");
        if (acc == null) {
            response.sendRedirect("login");
            return;
        }
        List<NewPartDetail> list = dao.getAllPartDetails();
        request.setAttribute("list", list);
        request.getRequestDispatcher("partDetail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        session.removeAttribute("successMessage");
        session.removeAttribute("errorMessage");
        String action = request.getParameter("action");
        if (action == null) action = "";

        // ===== XỬ LÝ ADD =====
        if ("add".equalsIgnoreCase(action)) {
            try {
                System.out.println("=== START ADD ===");
                
                Account acc = (Account) session.getAttribute("session_login");
                System.out.println("AccountId from session: " + acc.getAccountId());
                
                if (acc.getAccountId() == -1) {
                    System.out.println("❌ AccountId is NULL - redirect to login");
                    session.setAttribute("errorMessage", "Bạn cần đăng nhập để thực hiện thao tác này!");
                    response.sendRedirect("login");
                    return;
                }
                
                String serialNumber = request.getParameter("serialNumber");
                String status = request.getParameter("status");
                String location = request.getParameter("location");
                
                if (serialNumber == null || serialNumber.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Serial Number không được để trống!");
                    response.sendRedirect("partDetail");
                    return;
                }
                
                serialNumber = serialNumber.trim();
                
                String serialPattern = "^[A-Z]{3}-\\d{3}-\\d{4}$";
                if (!serialNumber.matches(serialPattern)) {
                    session.setAttribute("errorMessage", "Serial Number phải theo định dạng: AAA-XXX-YYYY (VD: SNK-001-2024)");
                    response.sendRedirect("partDetail");
                    return;
                }
                
                List<NewPartDetail> existingParts = dao.getAllPartDetails();
                final String serialNumberValue = serialNumber;
                boolean isDuplicate = existingParts.stream()
                    .anyMatch(p -> p.getSerialNumber() != null 
                               && p.getSerialNumber().equalsIgnoreCase(serialNumberValue));
                
                if (isDuplicate) {
                    session.setAttribute("errorMessage", "Serial Number đã tồn tại! Vui lòng nhập Serial Number khác.");
                    response.sendRedirect("partDetail");
                    return;
                }
                
                if (location == null || location.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Location không được để trống!");
                    response.sendRedirect("partDetail");
                    return;
                }
                
                location = location.trim();
                
                if (location.length() < 5) {
                    session.setAttribute("errorMessage", "Location phải có ít nhất 5 ký tự!");
                    response.sendRedirect("partDetail");
                    return;
                }
                
                if (location.length() > 50) {
                    session.setAttribute("errorMessage", "Location không được vượt quá 50 ký tự!");
                    response.sendRedirect("partDetail");
                    return;
                }
                
                if (status == null || status.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Status không được để trống!");
                    response.sendRedirect("partDetail");
                    return;
                }
                
                if ("InUse".equalsIgnoreCase(status)) {
                    session.setAttribute("errorMessage", "Không thể tạo Part Detail với trạng thái InUse!");
                    response.sendRedirect("partDetail");
                    return;
                }
                
                NewPartDetail newPart = new NewPartDetail();
                newPart.setPartId(Integer.parseInt(request.getParameter("partId")));
                newPart.setSerialNumber(serialNumber);
                newPart.setStatus(status);
                newPart.setLocation(location);
                newPart.setLastUpdatedBy(acc.getAccountId());
                newPart.setLastUpdatedDate(java.time.LocalDate.now());
                
                System.out.println("Data prepared:");
                System.out.println("  PartId: " + newPart.getPartId());
                System.out.println("  SerialNumber: " + newPart.getSerialNumber());
                System.out.println("  Status: " + newPart.getStatus());
                System.out.println("  Location: " + newPart.getLocation());
                
                boolean success = dao.addPartDetail(newPart);
                
                if (success) {
                    System.out.println("✅ Add successful!");
                    
                    // ===== LƯU LỊCH SỬ THÊM MỚI =====
                    int newPartDetailId = dao.getLastInsertedId(); // Cần thêm method này trong DAO
                    historyDAO.addHistory(newPartDetailId, null, status, acc.getAccountId(), "Thêm mới thiết bị");
                    
                    session.setAttribute("successMessage", "Thêm mới thành công!");
                } else {
                    System.out.println("❌ Add failed!");
                    session.setAttribute("errorMessage", "Thêm mới thất bại! Vui lòng kiểm tra lại.");
                }
                
                response.sendRedirect("partDetail");
                return;
                
            } catch (NumberFormatException e) {
                System.out.println("❌ Number format error: " + e.getMessage());
                session.setAttribute("errorMessage", "Dữ liệu không hợp lệ! Vui lòng kiểm tra lại.");
                response.sendRedirect("partDetail");
                return;
            } catch (Exception e) {
                System.out.println("❌ Unexpected error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
                response.sendRedirect("partDetail");
                return;
            }
        }

        // ===== XỬ LÝ EDIT (CÓ LƯU LỊCH SỬ) =====
        if ("edit".equalsIgnoreCase(action)) {
            try {
                System.out.println("=== START EDIT ===");
                
                Account acc = (Account) session.getAttribute("session_login");
                System.out.println("AccountId from session: " + acc.getAccountId());
                
                if (acc.getAccountId() == -1) {
                    System.out.println("❌ AccountId is NULL - redirect to login");
                    session.setAttribute("errorMessage", "Bạn cần đăng nhập để thực hiện thao tác này!");
                    response.sendRedirect("login");
                    return;
                }
                
                int partDetailId = Integer.parseInt(request.getParameter("partDetailId"));
                System.out.println("Editing partDetailId: " + partDetailId);
                
                NewPartDetail part = dao.getPartDetailById(partDetailId);
                
                if (part == null) {
                    System.out.println("❌ PartDetail not found with ID: " + partDetailId);
                    session.setAttribute("errorMessage", "Không tìm thấy thiết bị với ID: " + partDetailId);
                    response.sendRedirect("partDetail");
                    return;
                }
                
                String serialNumber = request.getParameter("serialNumber");
                String newStatus = request.getParameter("status");
                String location = request.getParameter("location");
                String oldStatus = part.getStatus(); // LƯU TRẠNG THÁI CŨ
                
                if ("InUse".equalsIgnoreCase(oldStatus)) {
                    session.setAttribute("errorMessage", "⚠️ Không thể thay đổi trạng thái khi Part Detail đã ở trạng thái InUse!");
                    response.sendRedirect("partDetail");
                    return;
                }
                
                if (serialNumber == null || serialNumber.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Serial Number không được để trống!");
                    response.sendRedirect("partDetail");
                    return;
                }
                
                serialNumber = serialNumber.trim();
                
                String serialPattern = "^[A-Z]{3}-\\d{3}-\\d{4}$";
                if (!serialNumber.matches(serialPattern)) {
                    session.setAttribute("errorMessage", "Serial Number phải theo định dạng: AAA-XXX-YYYY (VD: SNK-001-2024)");
                    response.sendRedirect("partDetail");
                    return;
                }
                
                List<NewPartDetail> existingParts = dao.getAllPartDetails();
                final String serialNumberValue = serialNumber;
                final int partDetailIdValue = partDetailId;

                boolean isDuplicate = existingParts != null && serialNumberValue != null &&
                    existingParts.stream()
                                 .anyMatch(p -> p.getSerialNumber() != null &&
                                                serialNumberValue.equalsIgnoreCase(p.getSerialNumber()) &&
                                                p.getPartDetailId() != partDetailIdValue);
                
                if (isDuplicate) {
                    session.setAttribute("errorMessage", "Serial Number đã tồn tại! Vui lòng nhập Serial Number khác.");
                    response.sendRedirect("partDetail");
                    return;
                }
                
                if (location == null || location.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Location không được để trống!");
                    response.sendRedirect("partDetail");
                    return;
                }
                
                location = location.trim();
                
                if (location.length() < 5) {
                    session.setAttribute("errorMessage", "Location phải có ít nhất 5 ký tự!");
                    response.sendRedirect("partDetail");
                    return;
                }
                
                if (location.length() > 50) {
                    session.setAttribute("errorMessage", "Location không được vượt quá 50 ký tự!");
                    response.sendRedirect("partDetail");
                    return;
                }
                
                part.setPartId(Integer.parseInt(request.getParameter("partId")));
                part.setSerialNumber(serialNumber);
                part.setStatus(newStatus);
                part.setLocation(location);
                part.setLastUpdatedBy(acc.getAccountId());
                part.setLastUpdatedDate(java.time.LocalDate.now());
                
                System.out.println("Updated data:");
                System.out.println("  PartDetailId: " + partDetailId);
                System.out.println("  Old Status: " + oldStatus);
                System.out.println("  New Status: " + newStatus);
                System.out.println("  SerialNumber: " + part.getSerialNumber());
                System.out.println("  Location: " + part.getLocation());
                
                boolean success = dao.updatePartDetail(part);
                
                if (success) {
                    System.out.println("✅ Edit successful!");
                    
                    // ===== LƯU LỊCH SỬ THAY ĐỔI =====
                    if (!oldStatus.equals(newStatus)) {
                        String notes = "Thay đổi trạng thái từ " + oldStatus + " sang " + newStatus;
                        historyDAO.addHistory(partDetailId, oldStatus, newStatus, acc.getAccountId(), notes);
                        System.out.println("✅ History saved: " + notes);
                    }
                    
                    if ("InUse".equalsIgnoreCase(newStatus)) {
                        session.setAttribute("successMessage", "⚠️ Cập nhật thành công! Lưu ý: Trạng thái InUse không thể thay đổi.");
                    } else {
                        session.setAttribute("successMessage", "Cập nhật thành công!");
                    }
                } else {
                    System.out.println("❌ Edit failed!");
                    session.setAttribute("errorMessage", "Cập nhật thất bại!");
                }
                
                response.sendRedirect("partDetail");
                return;
                
            } catch (NumberFormatException e) {
                System.out.println("❌ Number format error: " + e.getMessage());
                session.setAttribute("errorMessage", "Dữ liệu không hợp lệ!");
                response.sendRedirect("partDetail");
                return;
            } catch (Exception e) {
                System.out.println("❌ Unexpected error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
                response.sendRedirect("partDetail");
                return;
            }
        }

        // ===== XỬ LÝ DELETE =====
        if ("delete".equalsIgnoreCase(action)) {
            try {
                System.out.println("=== START DELETE ===");
                
                int partDetailId = Integer.parseInt(request.getParameter("partDetailId"));
                System.out.println("Deleting partDetailId: " + partDetailId);
                
                boolean success = dao.deletePartDetail(partDetailId);
                
                if (success) {
                    System.out.println("✅ Delete successful!");
                    session.setAttribute("successMessage", "Xóa thành công!");
                } else {
                    System.out.println("❌ Delete failed!");
                    session.setAttribute("errorMessage", "Xóa thất bại!");
                }
                
                response.sendRedirect("partDetail");
                return;
                
            } catch (NumberFormatException e) {
                System.out.println("❌ Number format error: " + e.getMessage());
                session.setAttribute("errorMessage", "ID không hợp lệ!");
                response.sendRedirect("partDetail");
                return;
            } catch (Exception e) {
                System.out.println("❌ Unexpected error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
                response.sendRedirect("partDetail");
                return;
            }
        }

        // ===== XỬ LÝ SEARCH & FILTER =====
        List<NewPartDetail> list = dao.getAllPartDetails();
        String keyword = request.getParameter("keyword");
        String filter = request.getParameter("filter");

        if (keyword != null && !keyword.trim().isEmpty()) {
            String keywordLower = keyword.toLowerCase().trim();
            System.out.println("Searching with keyword: " + keywordLower);
            
            list = list.stream()
                .filter(pd -> 
                    String.valueOf(pd.getPartDetailId()).contains(keywordLower) ||
                    String.valueOf(pd.getPartId()).contains(keywordLower) ||
                    pd.getSerialNumber().toLowerCase().contains(keywordLower) ||
                    pd.getStatus().toLowerCase().contains(keywordLower) ||
                    pd.getLocation().toLowerCase().contains(keywordLower) ||
                    (pd.getUsername() != null && pd.getUsername().toLowerCase().contains(keywordLower))
                )
                .collect(java.util.stream.Collectors.toList());
            
            System.out.println("Found " + list.size() + " results");
        }

        if (filter != null && !filter.isEmpty()) {
            System.out.println("Filtering by: " + filter);
            switch (filter.toLowerCase()) {
                case "partid": 
                    list.sort(Comparator.comparing(NewPartDetail::getPartId)); 
                    break;
                case "inventoryid": 
                    list.sort(Comparator.comparing(NewPartDetail::getPartDetailId)); 
                    break;
                case "partname": 
                    list.sort(Comparator.comparing(NewPartDetail::getSerialNumber)); 
                    break;
                case "lastupdateperson": 
                    list.sort(Comparator.comparing(pd -> 
                        pd.getUsername() != null ? pd.getUsername() : ""
                    )); 
                    break;
                case "lastupdatetime": 
                    list.sort(Comparator.comparing(NewPartDetail::getLastUpdatedDate).reversed()); 
                    break;
            }
        }

        request.setAttribute("list", list);
        request.getRequestDispatcher("partDetail.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "PartDetail Servlet - Manages part detail CRUD operations with history tracking";
    }
}