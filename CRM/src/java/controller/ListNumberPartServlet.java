package controller;

import dal.CategoryDAO;
import dal.PartDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import model.Account;
import model.Category;
import model.NewPart;

/**
 * ListNumberPartServlet - Quản lý danh sách hàng tồn kho với Category
 * @author Admin
 */
public class ListNumberPartServlet extends HttpServlet {

    private PartDAO dao = new PartDAO();
    private CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra đăng nhập
        HttpSession session = request.getSession();
        Account acc = (Account) session.getAttribute("session_login");
        
        System.out.println("=== doGet - Session Check ===");
        System.out.println("Account: " + acc);
        
        if (acc == null) {
            response.sendRedirect("login");
            return;
        }

        // ✅ Load categories
        List<Category> categories = categoryDAO.getCategoriesByType("Part");
        request.setAttribute("categories", categories);
        System.out.println("Loaded " + categories.size() + " categories");

        // Lấy danh sách tất cả parts
        List<NewPart> list = dao.getAllParts();
        request.setAttribute("list", list);
        System.out.println("Loaded " + list.size() + " parts");

        // Forward về JSP
        request.getRequestDispatcher("numberPart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Account acc = (Account) session.getAttribute("session_login");

        // ✅ DEBUG SESSION
        System.out.println("=== doPost - Session Check ===");
        System.out.println("Account from session: " + acc);
        if (acc != null) {
            System.out.println("Account ID: " + acc.getAccountId());
            System.out.println("Account Username: " + acc.getUsername());
            System.out.println("Account FullName: " + acc.getFullName());
        } else {
            System.out.println("❌ Account is NULL!");
        }

        // Kiểm tra đăng nhập
        if (acc == null) {
            System.out.println("❌ User not logged in, redirecting to login");
            response.sendRedirect("login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "";
        
        System.out.println("Action: " + action);

        // ===== XỬ LÝ ADD =====
        if ("add".equalsIgnoreCase(action)) {
            try {
                System.out.println("=== START ADD PART ===");

                String partName = request.getParameter("partName");
                String description = request.getParameter("description");
                String unitPriceStr = request.getParameter("unitPrice");
                String categoryIdStr = request.getParameter("categoryId");

                System.out.println("PartName: [" + partName + "]");
                System.out.println("Description: [" + description + "]");
                System.out.println("UnitPrice: [" + unitPriceStr + "]");
                System.out.println("CategoryId: [" + categoryIdStr + "]");

                // ✅ VALIDATION CHI TIẾT
                if (partName == null || partName.trim().isEmpty()) {
                    System.out.println("❌ Part Name is empty");
                    session.setAttribute("errorMessage", "Part Name không được để trống!");
                    response.sendRedirect("numberPart");
                    return;
                }

                if (description == null || description.trim().isEmpty()) {
                    System.out.println("❌ Description is empty");
                    session.setAttribute("errorMessage", "Description không được để trống!");
                    response.sendRedirect("numberPart");
                    return;
                }

                if (unitPriceStr == null || unitPriceStr.trim().isEmpty()) {
                    System.out.println("❌ Unit Price is empty");
                    session.setAttribute("errorMessage", "Unit Price không được để trống!");
                    response.sendRedirect("numberPart");
                    return;
                }

                double unitPrice;
                try {
                    unitPrice = Double.parseDouble(unitPriceStr);
                    System.out.println("Parsed unitPrice: " + unitPrice);
                } catch (NumberFormatException e) {
                    System.out.println("❌ Cannot parse unitPrice: " + e.getMessage());
                    session.setAttribute("errorMessage", "Giá không hợp lệ!");
                    response.sendRedirect("numberPart");
                    return;
                }

                if (unitPrice <= 0 || unitPrice >= 10000000) {
                    System.out.println("❌ Unit Price out of range: " + unitPrice);
                    session.setAttribute("errorMessage", "Giá phải > 0 và < 10,000,000!");
                    response.sendRedirect("numberPart");
                    return;
                }

                // ✅ CHECK ACCOUNT ID
                Integer accountId = acc.getAccountId();
                System.out.println("Account ID from session: " + accountId);
                
                if (accountId == null || accountId <= 0) {
                    System.out.println("❌ Account ID is invalid: " + accountId);
                    session.setAttribute("errorMessage", "Account ID không hợp lệ! Vui lòng đăng nhập lại.");
                    response.sendRedirect("login");
                    return;
                }

                // ✅ CREATE PART OBJECT
                NewPart part = new NewPart();
                part.setPartName(partName.trim());
                part.setDescription(description.trim());
                part.setUnitPrice(unitPrice);

                // ✅ SET CATEGORY (có thể NULL)
                if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
                    try {
                        int catId = Integer.parseInt(categoryIdStr);
                        part.setCategoryId(catId);
                        System.out.println("Set CategoryId: " + catId);
                    } catch (NumberFormatException e) {
                        System.out.println("⚠️ Invalid categoryId format: " + categoryIdStr);
                        // Không set categoryId nếu invalid
                    }
                } else {
                    System.out.println("CategoryId is null or empty - will be set as NULL");
                }

                part.setLastUpdatedBy(accountId);
                part.setLastUpdatedDate(LocalDate.now());

                // ✅ PRINT FULL OBJECT
                System.out.println("=== Part object before save ===");
                System.out.println("  - PartName: [" + part.getPartName() + "]");
                System.out.println("  - Description: [" + part.getDescription() + "]");
                System.out.println("  - UnitPrice: " + part.getUnitPrice());
                System.out.println("  - CategoryId: " + part.getCategoryId());
                System.out.println("  - LastUpdatedBy: " + part.getLastUpdatedBy());
                System.out.println("  - LastUpdatedDate: " + part.getLastUpdatedDate());

                System.out.println("Calling DAO.addPart()...");
                boolean success = dao.addPart(part);

                System.out.println("DAO.addPart() returned: " + success);

                if (success) {
                    System.out.println("✅ Add part successful!");
                    session.setAttribute("successMessage", "Thêm Part thành công!");
                } else {
                    System.out.println("❌ Add part failed!");
                    session.setAttribute("errorMessage", "Thêm Part thất bại! Kiểm tra database hoặc DAO.");
                }

                response.sendRedirect("numberPart");
                return;

            } catch (NumberFormatException e) {
                System.out.println("❌ Number format error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Giá không hợp lệ!");
                response.sendRedirect("numberPart");
                return;
            } catch (Exception e) {
                System.out.println("❌ Unexpected error during ADD: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
                response.sendRedirect("numberPart");
                return;
            }
        }

        // ===== XỬ LÝ EDIT =====
        if ("edit".equalsIgnoreCase(action)) {
            try {
                System.out.println("=== START EDIT PART ===");

                String partIdStr = request.getParameter("partId");
                String partName = request.getParameter("partName");
                String description = request.getParameter("description");
                String unitPriceStr = request.getParameter("unitPrice");
                String categoryIdStr = request.getParameter("categoryId");

                System.out.println("PartId: [" + partIdStr + "]");
                System.out.println("PartName: [" + partName + "]");
                System.out.println("Description: [" + description + "]");
                System.out.println("UnitPrice: [" + unitPriceStr + "]");
                System.out.println("CategoryId: [" + categoryIdStr + "]");

                if (partIdStr == null || partIdStr.trim().isEmpty()) {
                    System.out.println("❌ Part ID is empty");
                    session.setAttribute("errorMessage", "Part ID không hợp lệ!");
                    response.sendRedirect("numberPart");
                    return;
                }

                int partId = Integer.parseInt(partIdStr);

                if (partName == null || partName.trim().isEmpty()) {
                    System.out.println("❌ Part Name is empty");
                    session.setAttribute("errorMessage", "Part Name không được để trống!");
                    response.sendRedirect("numberPart");
                    return;
                }

                if (description == null || description.trim().isEmpty()) {
                    System.out.println("❌ Description is empty");
                    session.setAttribute("errorMessage", "Description không được để trống!");
                    response.sendRedirect("numberPart");
                    return;
                }

                double unitPrice = Double.parseDouble(unitPriceStr);

                if (unitPrice <= 0 || unitPrice >= 10000000) {
                    System.out.println("❌ Unit Price out of range: " + unitPrice);
                    session.setAttribute("errorMessage", "Giá phải > 0 và < 10,000,000!");
                    response.sendRedirect("numberPart");
                    return;
                }

                NewPart part = new NewPart();
                part.setPartId(partId);
                part.setPartName(partName.trim());
                part.setDescription(description.trim());
                part.setUnitPrice(unitPrice);

                // ✅ SET CATEGORY
                if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
                    try {
                        int catId = Integer.parseInt(categoryIdStr);
                        part.setCategoryId(catId);
                        System.out.println("Set CategoryId: " + catId);
                    } catch (NumberFormatException e) {
                        System.out.println("⚠️ Invalid categoryId: " + categoryIdStr);
                    }
                } else {
                    System.out.println("CategoryId is null - will be set as NULL");
                }

                part.setLastUpdatedBy(acc.getAccountId());
                part.setLastUpdatedDate(LocalDate.now());

                System.out.println("=== Part object before update ===");
                System.out.println("  - PartId: " + part.getPartId());
                System.out.println("  - PartName: [" + part.getPartName() + "]");
                System.out.println("  - Description: [" + part.getDescription() + "]");
                System.out.println("  - UnitPrice: " + part.getUnitPrice());
                System.out.println("  - CategoryId: " + part.getCategoryId());
                System.out.println("  - LastUpdatedBy: " + part.getLastUpdatedBy());

                boolean success = dao.updatePart(part);

                if (success) {
                    System.out.println("✅ Edit part successful!");
                    session.setAttribute("successMessage", "Cập nhật Part thành công!");
                } else {
                    System.out.println("❌ Edit part failed!");
                    session.setAttribute("errorMessage", "Cập nhật Part thất bại!");
                }

                response.sendRedirect("numberPart");
                return;

            } catch (NumberFormatException e) {
                System.out.println("❌ Number format error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Dữ liệu không hợp lệ!");
                response.sendRedirect("numberPart");
                return;
            } catch (Exception e) {
                System.out.println("❌ Unexpected error during EDIT: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
                response.sendRedirect("numberPart");
                return;
            }
        }

        // ===== XỬ LÝ DELETE =====
        if ("delete".equalsIgnoreCase(action)) {
            try {
                System.out.println("=== START DELETE PART ===");

                String partIdStr = request.getParameter("partId");
                System.out.println("PartId to delete: [" + partIdStr + "]");

                if (partIdStr == null || partIdStr.trim().isEmpty()) {
                    System.out.println("❌ Part ID is empty");
                    session.setAttribute("errorMessage", "Part ID không hợp lệ!");
                    response.sendRedirect("numberPart");
                    return;
                }

                int partId = Integer.parseInt(partIdStr);
                System.out.println("Deleting PartId: " + partId);

                boolean success = dao.deletePart(partId);

                if (success) {
                    System.out.println("✅ Delete part successful!");
                    session.setAttribute("successMessage", "Xóa Part thành công!");
                } else {
                    System.out.println("❌ Delete part failed!");
                    session.setAttribute("errorMessage", "Xóa Part thất bại!");
                }

                response.sendRedirect("numberPart");
                return;

            } catch (NumberFormatException e) {
                System.out.println("❌ Number format error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "ID không hợp lệ!");
                response.sendRedirect("numberPart");
                return;
            } catch (Exception e) {
                System.out.println("❌ Unexpected error during DELETE: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
                response.sendRedirect("numberPart");
                return;
            }
        }

        // ===== XỬ LÝ DETAIL (Lấy thống kê trạng thái) =====
        if ("detail".equalsIgnoreCase(action)) {
            try {
                System.out.println("=== START DETAIL ===");

                String partIdStr = request.getParameter("partId");
                System.out.println("PartId for detail: [" + partIdStr + "]");

                if (partIdStr == null || partIdStr.trim().isEmpty()) {
                    System.out.println("❌ Part ID is empty");
                    session.setAttribute("errorMessage", "Part ID không hợp lệ!");
                    response.sendRedirect("numberPart");
                    return;
                }

                int partId = Integer.parseInt(partIdStr);
                System.out.println("Getting detail for PartId: " + partId);

                // Lấy thông tin Part
                NewPart part = dao.getPartById(partId);

                if (part == null) {
                    System.out.println("❌ Part not found with ID: " + partId);
                    session.setAttribute("errorMessage", "Không tìm thấy Part với ID: " + partId);
                    response.sendRedirect("numberPart");
                    return;
                }

                System.out.println("Found part: " + part.getPartName());

                // Lấy số lượng theo trạng thái
                Map<String, Integer> statusCount = dao.getPartStatusCount(partId);
                System.out.println("Status count: " + statusCount);

                // Lấy danh sách tất cả parts (để hiển thị bảng chính)
                List<NewPart> list = dao.getAllParts();

                // ✅ Load categories
                List<Category> categories = categoryDAO.getCategoriesByType("Part");

                // Set attributes
                request.setAttribute("list", list);
                request.setAttribute("categories", categories);
                request.setAttribute("selectedPart", part);
                request.setAttribute("statusCount", statusCount);
                request.setAttribute("showDetail", true);

                System.out.println("✅ Detail loaded successfully!");

                request.getRequestDispatcher("numberPart.jsp").forward(request, response);
                return;

            } catch (NumberFormatException e) {
                System.out.println("❌ Number format error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "ID không hợp lệ!");
                response.sendRedirect("numberPart");
                return;
            } catch (Exception e) {
                System.out.println("❌ Unexpected error during DETAIL: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
                response.sendRedirect("numberPart");
                return;
            }
        }

        // ===== XỬ LÝ SEARCH & FILTER =====
        System.out.println("=== SEARCH & FILTER ===");
        
        List<NewPart> list = dao.getAllParts();
        String keyword = request.getParameter("keyword");
        String filter = request.getParameter("filter");
        String categoryFilter = request.getParameter("categoryFilter");

        System.out.println("Keyword: [" + keyword + "]");
        System.out.println("Filter: [" + filter + "]");
        System.out.println("CategoryFilter: [" + categoryFilter + "]");

        // ✅ FILTER BY CATEGORY TRƯỚC
        if (categoryFilter != null && !categoryFilter.isEmpty()) {
            try {
                int catId = Integer.parseInt(categoryFilter);
                list = dao.getPartsByCategory(catId);
                System.out.println("Filtered by categoryId " + catId + ": " + list.size() + " parts");
            } catch (NumberFormatException e) {
                System.out.println("❌ Invalid categoryId: " + categoryFilter);
            }
        }

        // Search theo keyword
        if (keyword != null && !keyword.trim().isEmpty()) {
            String keywordLower = keyword.toLowerCase().trim();
            System.out.println("Searching with keyword: [" + keywordLower + "]");

            list = list.stream()
                .filter(p -> 
                    String.valueOf(p.getPartId()).contains(keywordLower) ||
                    p.getPartName().toLowerCase().contains(keywordLower) ||
                    p.getDescription().toLowerCase().contains(keywordLower) ||
                    String.valueOf(p.getUnitPrice()).contains(keywordLower) ||
                    (p.getCategoryName() != null && p.getCategoryName().toLowerCase().contains(keywordLower)) ||
                    (p.getUserName() != null && p.getUserName().toLowerCase().contains(keywordLower)) ||
                    (p.getLastUpdatedDate() != null && p.getLastUpdatedDate().toString().contains(keywordLower))
                )
                .collect(Collectors.toList());

            System.out.println("Found " + list.size() + " results");
        }

        // Filter/Sort theo cột
        if (filter != null && !filter.isEmpty()) {
            System.out.println("Sorting by: " + filter);
            switch (filter.toLowerCase()) {
                case "partid": 
                    list.sort(Comparator.comparing(NewPart::getPartId)); 
                    break;
                case "partname": 
                    list.sort(Comparator.comparing(NewPart::getPartName)); 
                    break;
                case "category":
                    list.sort(Comparator.comparing(p -> 
                        p.getCategoryName() != null ? p.getCategoryName() : ""
                    )); 
                    break;
                case "quantity":
                    list.sort(Comparator.comparing(NewPart::getQuantity).reversed()); 
                    break;
                case "unitprice": 
                    list.sort(Comparator.comparing(NewPart::getUnitPrice)); 
                    break;
                case "updateperson": 
                    list.sort(Comparator.comparing(p -> 
                        p.getUserName() != null ? p.getUserName() : ""
                    )); 
                    break;
                case "updatedate": 
                    list.sort(Comparator.comparing(NewPart::getLastUpdatedDate).reversed()); 
                    break;
            }
        }

        // ✅ Load categories cho form
        List<Category> categories = categoryDAO.getCategoriesByType("Part");
        request.setAttribute("categories", categories);

        request.setAttribute("list", list);
        
        System.out.println("Forwarding to JSP with " + list.size() + " parts");
        request.getRequestDispatcher("numberPart.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "ListNumberPart Servlet - Manages part inventory CRUD operations with Category support";
    }
}