package controller;

import dal.ContractDAO;
import dal.EquipmentDAO;
import model.Contract;
import model.Equipment;
import model.ContractEquipment;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
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
                // Show contract creation form
                List<ContractDAO.Customer> customers = contractDAO.getAllCustomers();
                req.setAttribute("customers", customers);
                req.setAttribute("pageTitle", "Create Contract");
                req.setAttribute("contentView", "/WEB-INF/technician/contract-form.jsp");
                req.setAttribute("activePage", "contracts");
                req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                
            } else if ("contracts".equals(action) || action == null) {
                // Show contracts list with pagination and filtering
                doGetContracts(req, resp);
                
            } else if ("contractDetail".equals(action) && contractIdParam != null) {
                // Show contract detail with equipment
                int contractId = Integer.parseInt(contractIdParam);
                Contract contract = contractDAO.getContractById(contractId);
                
                if (contract != null) {
                    String customerName = contractDAO.getCustomerNameByContractId(contractId);
                    List<Equipment> equipmentList = equipmentDAO.findByContractId(contractId);
                    List<ContractEquipment> contractEquipmentList = equipmentDAO.findContractEquipmentByContractId(contractId);
                    
                    req.setAttribute("contract", contract);
                    req.setAttribute("customerName", customerName);
                    req.setAttribute("equipmentList", equipmentList);
                    req.setAttribute("contractEquipmentList", contractEquipmentList);
                    req.setAttribute("pageTitle", "Contract Detail");
                    req.setAttribute("contentView", "/WEB-INF/technician/contract-detail.jsp");
                    req.setAttribute("activePage", "contracts");
                    req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                } else {
                    req.setAttribute("error", "Contract not found");
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
                    req.setAttribute("pageTitle", "Equipment Detail");
                    req.setAttribute("contentView", "/WEB-INF/technician/equipment-detail.jsp");
                    req.setAttribute("activePage", "equipment");
                    req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
                } else {
                    req.setAttribute("error", "Equipment not found");
                    doGetEquipment(req, resp);
                }
                
            } else {
                // Default to contracts
                doGetContracts(req, resp);
            }
            
        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Invalid ID parameter");
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
            
            req.setAttribute("contracts", contracts);
            req.setAttribute("totalContracts", totalContracts);
            req.setAttribute("currentPage", page);
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("totalPages", (int) Math.ceil((double) totalContracts / pageSize));
            req.setAttribute("searchQuery", searchQuery);
            req.setAttribute("statusFilter", statusFilter);
            req.setAttribute("pageTitle", "Contracts");
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
            List<Equipment> equipmentList = equipmentDAO.searchEquipment(searchQuery, page, pageSize);
            int totalEquipment = equipmentDAO.getEquipmentCount(searchQuery);
            
            req.setAttribute("equipmentList", equipmentList);
            req.setAttribute("totalEquipment", totalEquipment);
            req.setAttribute("currentPage", page);
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("totalPages", (int) Math.ceil((double) totalEquipment / pageSize));
            req.setAttribute("pageTitle", "Equipment");
            req.setAttribute("contentView", "/WEB-INF/technician/equipment.jsp");
            req.setAttribute("activePage", "equipment");
            req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
            
        } catch (SQLException e) {
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
            // Handle contract creation
            try {
                ContractDAO contractDAO = new ContractDAO();
                
                // Get form parameters
                int customerId = Integer.parseInt(req.getParameter("customerId"));
                String contractType = req.getParameter("contractType");
                String description = req.getParameter("description");
                String contractDate = req.getParameter("contractDate");
                String status = req.getParameter("status");
                
                // Create contract using DAO method
                long contractId = contractDAO.createContract(
                    customerId, 
                    java.sql.Date.valueOf(contractDate), 
                    contractType, 
                    status, 
                    description
                );
                
                if (contractId > 0) {
                    req.getSession().setAttribute("successMessage", "Contract created successfully ✅");
                } else {
                    req.getSession().setAttribute("errorMessage", "Failed to create contract. Please try again.");
                }
                
            } catch (Exception e) {
                req.getSession().setAttribute("errorMessage", "Error creating contract: " + e.getMessage());
            }
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