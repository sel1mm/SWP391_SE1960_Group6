package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.nio.file.Files;

/**
 * Servlet để phục vụ (serve) ảnh avatar từ thư mục lưu trữ cố định
 * URL pattern: /avatar/{filename}
 * Ví dụ: /avatar/avatar_123_1234567890.jpg
 * 
 * @author Admin
 */
@WebServlet(name = "AvatarServlet", urlPatterns = {"/avatar/*"})
public class AvatarServlet extends HttpServlet {
    
    // PHẢI GIỐNG VỚI UPLOAD_DIR TRONG ChangeInformationServlet
    private static final String UPLOAD_DIR = "D:/Every thing relate to Lam/BTVN/Hoc tap/SWP/app-uploads/avatar";
    
    
  @Override
    public void init() throws ServletException {
        super.init();
        System.out.println("✅ AvatarServlet initialized");
        System.out.println("   Serving images from: " + UPLOAD_DIR);
        
        // Create directory if not exists
        File dir = new File(UPLOAD_DIR);
        if (!dir.exists()) {
            if (dir.mkdirs()) {
                System.out.println("   ✅ Directory created successfully");
            } else {
                System.err.println("   ❌ Failed to create directory");
            }
        }
    }

    /**
     * Handles the HTTP GET method - Serve avatar images
     * 
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    
    
     
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy tên file từ URL path
        String pathInfo = request.getPathInfo();
        
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Filename is required");
            return;
        }
        
        // Remove leading slash
        String filename = pathInfo.substring(1);
        
        // Security: Validate filename (không cho phép path traversal)
        if (filename.contains("..") || filename.contains("/") || filename.contains("\\")) {
            System.err.println("❌ Invalid filename: " + filename);
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid filename");
            return;
        }
        
        // Construct full file path
        File file = new File(UPLOAD_DIR, filename);
        
        System.out.println("📁 Requested file: " + filename);
        System.out.println("📁 Full path: " + file.getAbsolutePath());
        System.out.println("📁 Exists: " + file.exists());
        
        // Check if file exists
        if (!file.exists() || !file.isFile()) {
            System.err.println("❌ File not found: " + file.getAbsolutePath());
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found");
            return;
        }
        
        // Get content type based on file extension
        String contentType = getServletContext().getMimeType(filename);
        if (contentType == null) {
            contentType = "application/octet-stream";
        }
        
        // Set response headers
        response.setContentType(contentType);
        response.setContentLengthLong(file.length());
        response.setHeader("Cache-Control", "public, max-age=86400"); // Cache for 1 day
        
        // Send file
        Files.copy(file.toPath(), response.getOutputStream());
        
        System.out.println("✅ File served successfully: " + filename);
    }


    /**
     * Returns a short description of the servlet.
     */
   @Override
    public String getServletInfo() {
        return "Servlet for serving avatar images";
    }
}