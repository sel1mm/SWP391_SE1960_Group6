package controller;

import dal.AccountProfileDAO;
import dal.PartDAO;
import dal.PartDetailDAO;
import dal.CategoryDAO;
import dal.EquipmentDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.AccountProfile;
import model.NewPart;
import model.NewPartDetail;
import java.util.List;
import java.util.Map;

/**
 * Servlet for Storekeeper Dashboard with Real Data
 * @author Admin
 */
public class StorekeeperServlet extends HttpServlet {
   
    private AccountProfileDAO profileDAO;
    private PartDAO partDAO;
    private PartDetailDAO partDetailDAO;
    private CategoryDAO categoryDAO;
    private EquipmentDAO equipmentDAO;
    

    @Override
    public void init() throws ServletException {
        super.init();
        profileDAO = new AccountProfileDAO();
        partDAO = new PartDAO();
        partDetailDAO = new PartDetailDAO();
        categoryDAO = new CategoryDAO();
        equipmentDAO = new EquipmentDAO();
        
        System.out.println("✅ StorekeeperServlet initialized with DAOs");
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet StorekeeperServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet StorekeeperServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    } 

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Account acc = (Account) session.getAttribute("session_login");
        
        if (acc == null) {
            response.sendRedirect("login");
            return;
        }
        
        // Set username
        String username = acc.getUsername();
        session.setAttribute("username", username);
        
        // Load avatar từ AccountProfile
        try {
            AccountProfile profile = profileDAO.getProfileByAccountId(acc.getAccountId());
            
            if (profile != null) {
                ChangeInformationServlet.UserDTO user = new ChangeInformationServlet.UserDTO();
                user.setFullName(acc.getFullName());
                user.setEmail(acc.getEmail());
                user.setPhone(acc.getPhone());
                user.setAddress(profile.getAddress());
                user.setNationalId(profile.getNationalId());
                user.setDob(profile.getDateOfBirth() != null ? profile.getDateOfBirth().toString() : "");
                user.setAvatar(profile.getAvatarUrl());
                
                session.setAttribute("user", user);
                
                System.out.println("✅ StorekeeperServlet: Loaded user data");
                System.out.println("   - Full Name: " + user.getFullName());
                System.out.println("   - Avatar: " + user.getAvatar());
            }
        } catch (Exception e) {
            System.err.println("❌ Error loading profile: " + e.getMessage());
            e.printStackTrace();
        }
        
        // ===== LẤY DỮ LIỆU THẬT TỪ DATABASE =====
        try {
            // 1. Lấy tổng số loại thiết bị (Equipment categories)
            List<model.Category> equipmentCategories = categoryDAO.getCategoriesByType("Equipment");
            
            int totalEquipmentTypes = equipmentDAO.getEquipmentCount() ;
            request.setAttribute("totalEquipmentTypes", totalEquipmentTypes);
            
            // 2. Lấy tổng số loại linh kiện (Part categories)
           
            int totalPartTypes = partDAO.getPartCount() ;
            request.setAttribute("totalPartTypes", totalPartTypes);
            
            // 3. Lấy số lượng PartDetail theo trạng thái
            Map<String, Integer> statusCount = partDetailDAO.getStatusCount();
            int availableCount = statusCount.getOrDefault("Available", 0);
            int faultyCount = statusCount.getOrDefault("Faulty", 0);
            int inUseCount = statusCount.getOrDefault("InUse", 0);
            int retiredCount = statusCount.getOrDefault("Retired", 0);
            
            request.setAttribute("availableCount", availableCount);
            request.setAttribute("faultyCount", faultyCount);
            request.setAttribute("inUseCount", inUseCount);
            request.setAttribute("retiredCount", retiredCount);
            
            // 4. Tính tổng số linh kiện
            int totalParts = availableCount + faultyCount + inUseCount + retiredCount;
            request.setAttribute("totalParts", totalParts);
            
            // 5. Tính phần trăm
            double availablePercent = totalParts > 0 ? (availableCount * 100.0 / totalParts) : 0;
            double retiredPercent = totalParts > 0 ? (retiredCount * 100.0 / totalParts) : 0;
            
            request.setAttribute("availablePercent", String.format("%.1f", availablePercent));
            request.setAttribute("retiredPercent", String.format("%.1f", retiredPercent));
            
            // 6. Tính số lượng linh kiện sắp hết (ví dụ: Parts có ít hơn 5 Available)
            List<NewPart> allParts = partDAO.getAllParts();
            int lowStockCount = 0;
            for (NewPart part : allParts) {
                int available = partDAO.getAvailableQuantity(part.getPartId());
                if (available > 0 && available < 5) {
                    lowStockCount++;
                }
            }
            request.setAttribute("lowStockCount", lowStockCount);
            
            // 7. Lấy danh sách linh kiện sắp hết (top 5)
            List<NewPart> lowStockParts = getLowStockParts(allParts, 5);
            request.setAttribute("lowStockParts", lowStockParts);
            
            // 8. Lấy danh sách linh kiện được sử dụng nhiều (top 5 có InUse cao nhất)
            List<NewPart> mostUsedParts = getMostUsedParts(allParts, 5);
            request.setAttribute("mostUsedParts", mostUsedParts);
            //8,5. Lấy danh sách linh kiện hết hàng
            int chartOutOfStock = partDAO.getZeroQuantityPartsCount() ;
            // 9. Dữ liệu cho Chart
            request.setAttribute("chartInStock", availableCount);
            request.setAttribute("chartOutOfStock", chartOutOfStock); // Có thể tính từ Parts có quantity = 0
            request.setAttribute("chartLowStock", lowStockCount);
            request.setAttribute("chartDeadStock", retiredCount);
            
            System.out.println("✅ Dashboard data loaded successfully");
            System.out.println("   - Equipment Types: " + totalEquipmentTypes);
            System.out.println("   - Part Types: " + totalPartTypes);
            System.out.println("   - Available: " + availableCount);
            System.out.println("   - Faulty: " + faultyCount);
            System.out.println("   - InUse: " + inUseCount);
            System.out.println("   - Retired: " + retiredCount);
            System.out.println("   - Low Stock: " + lowStockCount);
            
        } catch (Exception e) {
            System.err.println("❌ Error loading dashboard data: " + e.getMessage());
            e.printStackTrace();
            
            // Set giá trị mặc định nếu có lỗi
            request.setAttribute("totalEquipmentTypes", 0);
            request.setAttribute("totalPartTypes", 0);
            request.setAttribute("availableCount", 0);
            request.setAttribute("faultyCount", 0);
            request.setAttribute("inUseCount", 0);
            request.setAttribute("retiredCount", 0);
            request.setAttribute("totalParts", 0);
            request.setAttribute("availablePercent", "0.0");
            request.setAttribute("retiredPercent", "0.0");
            request.setAttribute("lowStockCount", 0);
        }
        
        // Forward to JSP
        request.getRequestDispatcher("storekeeper.jsp").forward(request, response);
    } 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        doGet(request, response);
    }

    /**
     * Helper: Lấy danh sách linh kiện sắp hết
     */
    private List<NewPart> getLowStockParts(List<NewPart> allParts, int limit) {
        List<NewPart> lowStockParts = new java.util.ArrayList<>();
        
        for (NewPart part : allParts) {
            int available = partDAO.getAvailableQuantity(part.getPartId());
            if (available > 0 && available < 5) {
                part.setQuantity(available); // Set quantity để hiển thị
                lowStockParts.add(part);
                
                if (lowStockParts.size() >= limit) {
                    break;
                }
            }
        }
        
        return lowStockParts;
    }

    /**
     * Helper: Lấy danh sách linh kiện được sử dụng nhiều nhất
     */
    private List<NewPart> getMostUsedParts(List<NewPart> allParts, int limit) {
        List<NewPart> mostUsedParts = new java.util.ArrayList<>();
        
        // Tính số lượng InUse cho mỗi Part
        for (NewPart part : allParts) {
            Map<String, Integer> statusCount = partDAO.getPartStatusCount(part.getPartId());
            int inUseCount = statusCount.getOrDefault("InUse", 0);
            part.setQuantity(inUseCount); // Tạm dùng quantity để lưu InUse count
        }
        
        // Sắp xếp theo InUse count giảm dần
        allParts.sort((p1, p2) -> Integer.compare(p2.getQuantity(), p1.getQuantity()));
        
        // Lấy top N
        for (int i = 0; i < Math.min(limit, allParts.size()); i++) {
            if (allParts.get(i).getQuantity() > 0) {
                mostUsedParts.add(allParts.get(i));
            }
        }
        
        return mostUsedParts;
    }

    @Override
    public String getServletInfo() {
        return "Storekeeper Dashboard Servlet with Real Data from Database";
    }
}