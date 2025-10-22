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
                // Show contract creation form
                List<ContractDAO.Customer> customers = contractDAO.getAllCustomers();
                List<EquipmentWithStatus> availableEquipment = contractDAO.getAvailableEquipment();
                
                req.setAttribute("customers", customers);
                req.setAttribute("availableEquipment", availableEquipment);
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
                ContractDAO.ContractWithEquipment contractWithEquipment = contractDAO.getContractWithEquipment(contractId);
                
                if (contractWithEquipment != null) {
                    req.setAttribute("contractWithEquipment", contractWithEquipment);
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
            req.setAttribute("pageTitle", "Equipment Inventory");
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
            // Handle contract creation with equipment validation
            try {
                ContractDAO contractDAO = new ContractDAO();
                
                // Get form parameters
                int customerId = Integer.parseInt(req.getParameter("customerId"));
                String contractType = req.getParameter("contractType");
                String description = req.getParameter("description");
                String contractDate = req.getParameter("contractDate");
                String status = req.getParameter("status");
                String equipmentIdParam = req.getParameter("equipmentId");
                
                // Validate equipment availability if equipment is selected
                int equipmentId = 0;
                if (equipmentIdParam != null && !equipmentIdParam.trim().isEmpty()) {
                    equipmentId = Integer.parseInt(equipmentIdParam);
                    
                    if (!contractDAO.isEquipmentAvailable(equipmentId)) {
                        req.getSession().setAttribute("errorMessage", "Selected equipment is not available. Please choose another equipment or contact storekeeper.");
                        resp.sendRedirect(req.getContextPath() + "/technician/contracts?action=create");
                        return;
                    }
                }
                
                // Create contract with or without equipment
                long contractId;
                if (equipmentId > 0) {
                    contractId = contractDAO.createContractWithEquipment(
                        customerId, 
                        java.sql.Date.valueOf(contractDate), 
                        contractType, 
                        status, 
                        description,
                        equipmentId
                    );
                } else {
                    contractId = contractDAO.createContract(
                        customerId, 
                        java.sql.Date.valueOf(contractDate), 
                        contractType, 
                        status, 
                        description
                    );
                }
                
                if (contractId > 0) {
                    String successMsg = equipmentId > 0 ? 
                        "Contract created successfully with equipment assignment ✅" : 
                        "Contract created successfully ✅";
                    req.getSession().setAttribute("successMessage", successMsg);
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