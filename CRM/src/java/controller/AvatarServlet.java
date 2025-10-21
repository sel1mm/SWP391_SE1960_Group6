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
        
        // Kiểm tra thư mục tồn tại
        File dir = new File(UPLOAD_DIR);
        if (!dir.exists()) {
            System.err.println("⚠️ WARNING: Upload directory does not exist: " + UPLOAD_DIR);
            System.out.println("   Attempting to create directory...");
            if (dir.mkdirs()) {
                System.out.println("   ✅ Directory created successfully");
            } else {
                System.err.println("   ❌ Failed to create directory");
            }
        } else {
            System.out.println("   ✅ Directory exists");
            System.out.println("   Files in directory: " + (dir.list() != null ? dir.list().length : 0));
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
        
        // Lấy tên file từ URL
        // Ví dụ: /avatar/avatar_123_1234567890.jpg -> avatar_123_1234567890.jpg
        String pathInfo = request.getPathInfo();
        
        if (pathInfo == null || pathInfo.equals("/")) {
            System.err.println("❌ AvatarServlet: No filename provided in URL");
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Filename is required");
            return;
        }
        
        // Remove leading slash
        String fileName = pathInfo.substring(1);
        
        System.out.println("\n=== AvatarServlet GET Request ===");
        System.out.println("Requested URL: " + request.getRequestURI());
        System.out.println("Path Info: " + pathInfo);
        System.out.println("File name: " + fileName);
        
        // Tạo đường dẫn đầy đủ đến file
        File file = new File(UPLOAD_DIR, fileName);
        
        System.out.println("Full file path: " + file.getAbsolutePath());
        System.out.println("File exists: " + file.exists());
        System.out.println("Is file: " + file.isFile());
        System.out.println("Can read: " + file.canRead());
        
        // Kiểm tra file có tồn tại không
        if (!file.exists() || !file.isFile()) {
            System.err.println("❌ File not found: " + file.getAbsolutePath());
            
            // List files in directory for debugging
            File dir = new File(UPLOAD_DIR);
            if (dir.exists() && dir.isDirectory()) {
                String[] files = dir.list();
                System.out.println("Files in upload directory:");
                if (files != null && files.length > 0) {
                    for (String f : files) {
                        System.out.println("  - " + f);
                    }
                } else {
                    System.out.println("  (empty directory)");
                }
            }
            
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Avatar image not found");
            return;
        }
        
        // Kiểm tra file có phải là ảnh hợp lệ không (bảo mật)
        String lowerFileName = fileName.toLowerCase();
        if (!lowerFileName.endsWith(".jpg") && 
            !lowerFileName.endsWith(".jpeg") && 
            !lowerFileName.endsWith(".png") && 
            !lowerFileName.endsWith(".gif")) {
            System.err.println("❌ Invalid file type requested: " + fileName);
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid file type");
            return;
        }
        
        try {
            // Xác định MIME type
            String mimeType = Files.probeContentType(file.toPath());
            if (mimeType == null) {
                // Fallback MIME types
                if (lowerFileName.endsWith(".jpg") || lowerFileName.endsWith(".jpeg")) {
                    mimeType = "image/jpeg";
                } else if (lowerFileName.endsWith(".png")) {
                    mimeType = "image/png";
                } else if (lowerFileName.endsWith(".gif")) {
                    mimeType = "image/gif";
                } else {
                    mimeType = "application/octet-stream";
                }
            }
            
            System.out.println("MIME type: " + mimeType);
            System.out.println("File size: " + file.length() + " bytes");
            
            // Set response headers
            response.setContentType(mimeType);
            response.setContentLengthLong(file.length());
            
            // Cache control (cache ảnh trong 7 ngày = 604800 seconds)
            response.setHeader("Cache-Control", "public, max-age=604800");
            response.setDateHeader("Expires", System.currentTimeMillis() + 604800000L);
            
            // Copy file content to response
            Files.copy(file.toPath(), response.getOutputStream());
            response.getOutputStream().flush();
            
            System.out.println("✅ Image served successfully");
            System.out.println("===========================\n");
            
        } catch (IOException e) {
            System.err.println("❌ Error serving image: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                             "Error serving image: " + e.getMessage());
        }
    }

    /**
     * Returns a short description of the servlet.
     */
    @Override
    public String getServletInfo() {
        return "Servlet for serving avatar images from: " + UPLOAD_DIR;
    }
}