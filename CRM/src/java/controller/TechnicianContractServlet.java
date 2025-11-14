package controller;

import dal.ContractDAO;
import dal.EquipmentDAO;
import model.Contract;
import model.Equipment;
import model.EquipmentWithStatus;
import model.ContractEquipment;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Servlet for handling technician contract and equipment operations.
 * Provides read-only access to contracts and equipment for technicians.
 */
public class TechnicianContractServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;
        
        // Check authentication
        if (sessionId == null || !isTechnicianOrAdmin(userRole)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = req.getParameter("action");
        String contractIdParam = req.getParameter("contractId");
        String equipmentIdParam = req.getParameter("equipmentId");
        
        try {
            ContractDAO contractDAO = new ContractDAO();
            EquipmentDAO equipmentDAO = new EquipmentDAO();
            
            if ("create".equals(action)) {
                // Contract creation is out of scope for technicians - redirect to contracts list
                req.setAttribute("error", "Tạo hợp đồng không nằm trong phạm vi quyền của kỹ thuật viên.");
                doGetContracts(req, resp);
                return;
                
            } else if ("contracts".equals(action) || action == null) {
                // Show contracts list with pagination and filtering
                doGetContracts(req, resp);
                
            } else if ("contractDetail".equals(action) && contractIdParam != null) {
                // Show contract detail with equipment
                int contractId = Integer.parseInt(contractIdParam);
                ContractDAO.ContractWithEquipment contractWithEquipment = contractDAO.getContractWithEquipment(contractId);
                
                if (contractWithEquipment != null) {
                    req.setAttribute("contractWithEquipment", contractWithEquipment);
                    req.setAttribute("pageTitle", "Chi tiết hợp đồng");
                    req.setAttribute("contentView", "/WEB-INF/technician/contract-detail.jsp");
                    req.setAttribute("activePage", "contracts");
                    req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                } else {
                    req.setAttribute("error", "Không tìm thấy hợp đồng");
                    doGetContracts(req, resp);
                }
                
            } else if ("equipment".equals(action)) {
                // Show equipment list
                doGetEquipment(req, resp);
                
            } else if ("equipmentDetail".equals(action) && equipmentIdParam != null) {
                // Show equipment detail
                int equipmentId = Integer.parseInt(equipmentIdParam);
                Equipment equipment = equipmentDAO.findById(equipmentId);
                
                if (equipment != null) {
                    req.setAttribute("equipment", equipment);
                    req.setAttribute("pageTitle", "Chi tiết thiết bị");
                    req.setAttribute("contentView", "/WEB-INF/technician/equipment-detail.jsp");
                    req.setAttribute("activePage", "equipment");
                    req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                } else {
                    req.setAttribute("error", "Không tìm thấy thiết bị");
                    doGetEquipment(req, resp);
                }
                
            } else {
                // Default to contracts
                doGetContracts(req, resp);
            }
            
        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Tham số ID không hợp lệ");
            doGetContracts(req, resp);
        }
    }
    
    private void doGetContracts(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        try {
            String searchQuery = sanitize(req.getParameter("q"));
            String statusFilter = sanitize(req.getParameter("status"));
            int page = parseInt(req.getParameter("page"), 1);
            int pageSize = Math.min(parseInt(req.getParameter("pageSize"), 10), 100);
            
            ContractDAO contractDAO = new ContractDAO();
            List<ContractDAO.ContractWithCustomer> contracts = contractDAO.searchContracts(searchQuery, statusFilter, page, pageSize);
            int totalContracts = contractDAO.getContractCount(searchQuery, statusFilter);
            
            // Convert ContractWithCustomer to ContractWithEquipment for each contract
            List<ContractDAO.ContractWithEquipment> contractsWithEquipment = new ArrayList<>();
            for (ContractDAO.ContractWithCustomer contractWithCustomer : contracts) {
                ContractDAO.ContractWithEquipment contractWithEquipment = contractDAO.getContractWithEquipment(contractWithCustomer.contract.getContractId());
                if (contractWithEquipment == null) {
                    // Create a ContractWithEquipment without equipment if none exists
                    contractWithEquipment = new ContractDAO.ContractWithEquipment();
                    contractWithEquipment.contract = contractWithCustomer.contract;
                    contractWithEquipment.customerName = contractWithCustomer.customerName;
                    contractWithEquipment.equipment = null;
                }
                contractsWithEquipment.add(contractWithEquipment);
            }
            
            req.setAttribute("contracts", contractsWithEquipment);
            req.setAttribute("totalContracts", totalContracts);
            req.setAttribute("currentPage", page);
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("totalPages", (int) Math.ceil((double) totalContracts / pageSize));
            req.setAttribute("searchQuery", searchQuery);
            req.setAttribute("statusFilter", statusFilter);
            req.setAttribute("pageTitle", "Danh sách hợp đồng");
            req.setAttribute("contentView", "/WEB-INF/technician/contracts.jsp");
            req.setAttribute("activePage", "contracts");
            req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
            
        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        }
    }
    
    private void doGetEquipment(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        try {
            String searchQuery = sanitize(req.getParameter("q"));
            int page = parseInt(req.getParameter("page"), 1);
            int pageSize = Math.min(parseInt(req.getParameter("pageSize"), 10), 100);
            
            EquipmentDAO equipmentDAO = new EquipmentDAO();
            
            // Get equipment with status information from inventory
            List<EquipmentWithStatus> equipmentWithStatusList = equipmentDAO.getEquipmentWithStatus();
            
            // Apply search filter if provided
            if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                equipmentWithStatusList = equipmentWithStatusList.stream()
                    .filter(e -> e.getModel().toLowerCase().contains(searchQuery.toLowerCase()) ||
                               e.getDescription().toLowerCase().contains(searchQuery.toLowerCase()) ||
                               e.getSerialNumber().toLowerCase().contains(searchQuery.toLowerCase()))
                    .collect(java.util.stream.Collectors.toList());
            }
            
            // Apply pagination
            int totalEquipment = equipmentWithStatusList.size();
            int startIndex = (page - 1) * pageSize;
            int endIndex = Math.min(startIndex + pageSize, totalEquipment);
            
            List<EquipmentWithStatus> paginatedList = equipmentWithStatusList.subList(startIndex, endIndex);
            
            req.setAttribute("equipmentList", paginatedList);
            req.setAttribute("totalEquipment", totalEquipment);
            req.setAttribute("currentPage", page);
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("totalPages", (int) Math.ceil((double) totalEquipment / pageSize));
            req.setAttribute("searchQuery", searchQuery);
            req.setAttribute("pageTitle", "Kho thiết bị");
            req.setAttribute("contentView", "/WEB-INF/technician/equipment.jsp");
            req.setAttribute("activePage", "equipment");
            req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
            
        } catch (Exception e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        }
    }

    private String sanitize(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    private int parseInt(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;
        
        // Check authentication
        if (sessionId == null || !isTechnicianOrAdmin(userRole)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = req.getParameter("action");
        
        if ("create".equals(action)) {
            // Contract creation is out of scope for technicians - redirect to contracts list
            req.getSession().setAttribute("error", "Tạo hợp đồng không nằm trong phạm vi quyền của kỹ thuật viên.");
        }
        
        // Redirect to contracts list
        resp.sendRedirect(req.getContextPath() + "/technician/contracts");
    }

    private boolean isTechnicianOrAdmin(String role) {
        if (role == null) return false;
        String r = role.toLowerCase();
        return r.contains("technician") || r.equals("admin");
    }
}