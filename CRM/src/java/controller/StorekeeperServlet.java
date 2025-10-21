package controller;

import dal.AccountProfileDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.AccountProfile;

/**
 * Servlet for Storekeeper Dashboard
 * @author Admin
 */
public class StorekeeperServlet extends HttpServlet {
   
    private AccountProfileDAO profileDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        profileDAO = new AccountProfileDAO();
        System.out.println("✅ StorekeeperServlet initialized");
    }

    /** 
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
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
            out.println("<h1>Servlet StorekeeperServlet at " + request.getContextPath () + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    } 

    /** 
     * Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Account acc = (Account) session.getAttribute("session_login");
        
        if (acc == null) {
            response.sendRedirect("login");
            return;
        }
        
        // GIỮ NGUYÊN - Set username vào session
        String username = acc.getUsername();
        session.setAttribute("username", username);
        
        // ✅ THÊM - Load avatar từ AccountProfile
        try {
            AccountProfile profile = profileDAO.getProfileByAccountId(acc.getAccountId());
            
            if (profile != null) {
                // Tạo UserDTO với avatar mới nhất
                ChangeInformationServlet.UserDTO user = new ChangeInformationServlet.UserDTO();
                user.setFullName(acc.getFullName());
                user.setEmail(acc.getEmail());
                user.setPhone(acc.getPhone());
                user.setAddress(profile.getAddress());
                user.setNationalId(profile.getNationalId());
                user.setDob(profile.getDateOfBirth() != null ? profile.getDateOfBirth().toString() : "");
                user.setAvatar(profile.getAvatarUrl()); // ✅ Avatar mới nhất từ DB
                
                session.setAttribute("user", user);
                
                System.out.println("✅ StorekeeperServlet: Loaded user data");
                System.out.println("   - Full Name: " + user.getFullName());
                System.out.println("   - Avatar: " + user.getAvatar());
            } else {
                System.out.println("⚠️ No profile found for accountId: " + acc.getAccountId());
            }
        } catch (Exception e) {
            System.err.println("❌ Error loading profile: " + e.getMessage());
            e.printStackTrace();
        }
        
        // GIỮ NGUYÊN - Forward to JSP
        request.getRequestDispatcher("storekeeper.jsp").forward(request, response);
    } 

    /** 
     * Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        request.getRequestDispatcher("storekeeper.jsp").forward(request, response);
    }

    /** 
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Storekeeper Dashboard Servlet with Avatar Support";
    }
}