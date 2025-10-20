package controller;

import dal.ContractDAO;
import dal.ContractEquipmentDAO;
import model.Contract;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.ArrayList;

/**
 * Handles contract management for technicians - listing, viewing, and creating contracts.
 */
public class TechnicianContractServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;
        String dev = req.getParameter("dev");

        if (sessionId == null || !isTechnicianOrAdmin(userRole)) {
            if ("true".equalsIgnoreCase(dev)) {
                // Dev mode - show mock data
                loadContractManagement(req, resp, 1L, dev);
            } else {
                resp.sendRedirect(req.getContextPath() + "/login.jsp");
                return;
            }
        } else {
            long technicianId = sessionId.longValue();
            loadContractManagement(req, resp, technicianId, dev);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Integer sessionId = session != null ? (Integer) session.getAttribute("session_login_id") : null;
        String userRole = session != null ? (String) session.getAttribute("session_role") : null;

        if (sessionId == null || !isTechnicianOrAdmin(userRole)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");
        
        try {
            if ("createContract".equals(action)) {
                handleCreateContract(req, resp, sessionId);
            } else if ("addEquipment".equals(action)) {
                handleAddEquipment(req, resp);
            } else if ("updateContractStatus".equals(action)) {
                handleUpdateContractStatus(req, resp);
            } else {
                resp.sendRedirect(req.getContextPath() + "/technician/contracts?error=" + 
                    java.net.URLEncoder.encode("Invalid action", "UTF-8"));
            }
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/technician/contracts?error=" + 
                java.net.URLEncoder.encode("Database error: " + e.getMessage(), "UTF-8"));
        }
    }

    private void loadContractManagement(HttpServletRequest req, HttpServletResponse resp, long technicianId, String dev)
            throws ServletException, IOException {
        ContractDAO contractDao = new ContractDAO();

        try {
            String contractIdParam = req.getParameter("contractId");
            String view = req.getParameter("view");
            
            if ("create".equals(view)) {
                // Show contract creation form with real customers
                List<ContractDAO.Customer> customers = contractDao.getAllCustomers();
                
                req.setAttribute("customers", customers);
                req.setAttribute("pageTitle", "Create New Contract");
                req.setAttribute("contentView", "/WEB-INF/technician/technician-contract-form.jsp");
            } else if (contractIdParam != null && !contractIdParam.isEmpty()) {
                // View specific contract details
                long contractId = Long.parseLong(contractIdParam);
                Contract contract = contractDao.getContractById((int) contractId);
                
                if (contract != null) {
                    String customerName = contractDao.getCustomerNameByContractId((int) contractId);
                    ContractEquipmentDAO contractEquipmentDao = new ContractEquipmentDAO();
                    List<ContractEquipmentDAO.ContractEquipmentRow> equipmentList = 
                        contractEquipmentDao.getEquipmentByContractId(contractId);
                    
                    req.setAttribute("contract", contract);
                    req.setAttribute("customerName", customerName);
                    req.setAttribute("equipmentList", equipmentList);
                    req.setAttribute("pageTitle", "Contract Details");
                    req.setAttribute("contentView", "/WEB-INF/technician/technician-equipment.jsp");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/technician/contracts?error=" + 
                        java.net.URLEncoder.encode("Contract not found.", "UTF-8"));
                    return;
                }
            } else {
                // List all contracts from database
                List<ContractDAO.ContractWithCustomer> contracts = contractDao.getAllContracts();
                req.setAttribute("contracts", contracts);
                req.setAttribute("pageTitle", "Contract Management");
                req.setAttribute("contentView", "/WEB-INF/technician/technician-contracts.jsp");
            }
            
            req.setAttribute("activePage", "contracts");
            req.getRequestDispatcher("/WEB-INF/technician/technician-layout.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/technician/contracts?error=" + 
                java.net.URLEncoder.encode("Invalid contract ID.", "UTF-8"));
        } catch (Exception e) {
            throw new ServletException("Database error while loading contracts", e);
        }
    }

    private void handleCreateContract(HttpServletRequest req, HttpServletResponse resp, Integer sessionId)
            throws ServletException, IOException {
        
        String customerIdStr = req.getParameter("customerId");
        String contractDateStr = req.getParameter("contractDate");
        String contractType = req.getParameter("contractType");
        String details = req.getParameter("details");
        
        // Validation
        if (customerIdStr == null || contractDateStr == null || contractType == null) {
            resp.sendRedirect(req.getContextPath() + "/technician/contracts?view=create&error=" + 
                java.net.URLEncoder.encode("Missing required fields", "UTF-8"));
            return;
        }
        
        try {
            int customerId = Integer.parseInt(customerIdStr);
            LocalDate contractDate = LocalDate.parse(contractDateStr);
            
            ContractDAO contractDao = new ContractDAO();
            long contractId = contractDao.createContract(customerId, java.sql.Date.valueOf(contractDate), 
                contractType, "Active", details);
            
            if (contractId > 0) {
                resp.sendRedirect(req.getContextPath() + "/technician/contracts?contractId=" + contractId + 
                    "&success=" + java.net.URLEncoder.encode("Contract created successfully! Contract ID: " + contractId, "UTF-8"));
            } else {
                resp.sendRedirect(req.getContextPath() + "/technician/contracts?view=create&error=" + 
                    java.net.URLEncoder.encode("Failed to create contract", "UTF-8"));
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/technician/contracts?view=create&error=" + 
                java.net.URLEncoder.encode("Invalid customer ID", "UTF-8"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/technician/contracts?view=create&error=" + 
                java.net.URLEncoder.encode("Error creating contract: " + e.getMessage(), "UTF-8"));
        }
    }

    private void handleAddEquipment(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        
        String contractIdStr = req.getParameter("contractId");
        String equipmentIdStr = req.getParameter("equipmentId");
        String startDateStr = req.getParameter("startDate");
        String endDateStr = req.getParameter("endDate");
        String quantityStr = req.getParameter("quantity");
        String priceStr = req.getParameter("price");
        
        // Validation
        if (contractIdStr == null || equipmentIdStr == null || startDateStr == null || 
            quantityStr == null) {
            resp.sendRedirect(req.getContextPath() + "/technician/contracts?error=" + 
                java.net.URLEncoder.encode("Missing required fields", "UTF-8"));
            return;
        }
        
        try {
            long contractId = Long.parseLong(contractIdStr);
            long equipmentId = Long.parseLong(equipmentIdStr);
            LocalDate startDate = LocalDate.parse(startDateStr);
            LocalDate endDate = endDateStr != null && !endDateStr.isEmpty() ? 
                LocalDate.parse(endDateStr) : null;
            int quantity = Integer.parseInt(quantityStr);
            java.math.BigDecimal price = priceStr != null && !priceStr.isEmpty() ? 
                new java.math.BigDecimal(priceStr) : null;
            
            ContractEquipmentDAO contractEquipmentDao = new ContractEquipmentDAO();
            long result = contractEquipmentDao.addEquipmentToContract(contractId, equipmentId, 
                java.sql.Date.valueOf(startDate), endDate != null ? java.sql.Date.valueOf(endDate) : null, 
                quantity, price);
            
            if (result > 0) {
                resp.sendRedirect(req.getContextPath() + "/technician/contracts?contractId=" + contractId + 
                    "&success=" + java.net.URLEncoder.encode("Equipment added to contract successfully!", "UTF-8"));
            } else {
                resp.sendRedirect(req.getContextPath() + "/technician/contracts?contractId=" + contractId + 
                    "&error=" + java.net.URLEncoder.encode("Failed to add equipment to contract", "UTF-8"));
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/technician/contracts?error=" + 
                java.net.URLEncoder.encode("Invalid numeric values", "UTF-8"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/technician/contracts?error=" + 
                java.net.URLEncoder.encode("Error adding equipment: " + e.getMessage(), "UTF-8"));
        }
    }

    private void handleUpdateContractStatus(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        
        String contractIdStr = req.getParameter("contractId");
        String newStatus = req.getParameter("status");
        
        if (contractIdStr == null || newStatus == null) {
            resp.sendRedirect(req.getContextPath() + "/technician/contracts?error=" + 
                java.net.URLEncoder.encode("Missing required fields", "UTF-8"));
            return;
        }
        
        try {
            long contractId = Long.parseLong(contractIdStr);
            ContractDAO contractDao = new ContractDAO();
            
            boolean success = contractDao.updateContractStatus((int) contractId, newStatus);
            
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/technician/contracts?contractId=" + contractId + 
                    "&success=" + java.net.URLEncoder.encode("Contract status updated to: " + newStatus, "UTF-8"));
            } else {
                resp.sendRedirect(req.getContextPath() + "/technician/contracts?contractId=" + contractId + 
                    "&error=" + java.net.URLEncoder.encode("Failed to update contract status", "UTF-8"));
            }
                
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/technician/contracts?error=" + 
                java.net.URLEncoder.encode("Invalid contract ID", "UTF-8"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/technician/contracts?error=" + 
                java.net.URLEncoder.encode("Error updating contract status: " + e.getMessage(), "UTF-8"));
        }
    }

    private boolean isTechnicianOrAdmin(String role) {
        if (role == null) return false;
        String r = role.toLowerCase();
        return r.contains("technician") || r.equals("admin");
    }
}