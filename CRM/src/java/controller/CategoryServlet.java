package controller;

import dal.CategoryDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.Account;
import model.Category;

/**
 * CategoryServlet - Quản lý Category CRUD operations
 * @author Admin
 */
public class CategoryServlet extends HttpServlet {
    
    private CategoryDAO dao = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập
        HttpSession session = request.getSession();
        Account acc = (Account) session.getAttribute("session_login");
        if (acc == null) {
            response.sendRedirect("login");
            return;
        }

        // Lấy filter parameter
        String typeFilter = request.getParameter("typeFilter");
        
        List<Category> categoryList;
        
        if (typeFilter != null && !typeFilter.isEmpty()) {
            // Filter by type
            categoryList = dao.getCategoriesByType(typeFilter);
            System.out.println("Filtered by type: " + typeFilter + " (" + categoryList.size() + " results)");
        } else {
            // Get all categories
            categoryList = dao.getAllCategories();
            System.out.println("Loaded all categories: " + categoryList.size());
        }
        
        request.setAttribute("categoryList", categoryList);
        request.getRequestDispatcher("category.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Account acc = (Account) session.getAttribute("session_login");
        
        // Xóa message cũ
        session.removeAttribute("successMessage");
        session.removeAttribute("errorMessage");
        
        // Kiểm tra đăng nhập
        if (acc == null) {
            response.sendRedirect("login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "";

        // ===== XỬ LÝ ADD =====
        if ("add".equalsIgnoreCase(action)) {
            try {
                System.out.println("=== START ADD CATEGORY ===");
                
                String categoryName = request.getParameter("categoryName");
                String type = request.getParameter("type");

                System.out.println("CategoryName: " + categoryName);
                System.out.println("Type: " + type);
                
                // Validation
                if (categoryName == null || categoryName.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Category name cannot be empty!");
                    response.sendRedirect("category");
                    return;
                }
                
                categoryName = categoryName.trim();
                
                if (categoryName.length() < 3) {
                    session.setAttribute("errorMessage", "Category name must be at least 3 characters!");
                    response.sendRedirect("category");
                    return;
                }
                
                if (categoryName.length() > 50) {
                    session.setAttribute("errorMessage", "Category name cannot exceed 50 characters!");
                    response.sendRedirect("category");
                    return;
                }
                
                if (type == null || type.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Type cannot be empty!");
                    response.sendRedirect("category");
                    return;
                }
                
                if (!type.equals("Part") && !type.equals("Product")) {
                    session.setAttribute("errorMessage", "Invalid type! Must be 'Part' or 'Product'");
                    response.sendRedirect("category");
                    return;
                }
                
                // Check if category name already exists
                if (dao.categoryNameExists(categoryName, type)) {
                    session.setAttribute("errorMessage", "Category name already exists for this type!");
                    response.sendRedirect("category");
                    return;
                }
                
                Category category = new Category(categoryName, type);
                
                System.out.println("Calling DAO to add category...");
                boolean success = dao.addCategory(category);
                
                if (success) {
                    System.out.println("✅ Add category successful!");
                    session.setAttribute("successMessage", "Category added successfully!");
                } else {
                    System.out.println("❌ Add category failed!");
                    session.setAttribute("errorMessage", "Failed to add category!");
                }
                
                response.sendRedirect("category");
                return;
                
            } catch (Exception e) {
                System.out.println("❌ Unexpected error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
                response.sendRedirect("category");
                return;
            }
        }

        // ===== XỬ LÝ EDIT =====
        if ("edit".equalsIgnoreCase(action)) {
            try {
                System.out.println("=== START EDIT CATEGORY ===");
                
                int categoryId = Integer.parseInt(request.getParameter("categoryId"));
                String categoryName = request.getParameter("categoryName");
                String type = request.getParameter("type");
                
                System.out.println("Editing CategoryId: " + categoryId);
                System.out.println("New CategoryName: " + categoryName);
                System.out.println("New Type: " + type);
                
                // Validation
                if (categoryName == null || categoryName.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Category name cannot be empty!");
                    response.sendRedirect("category");
                    return;
                }
                
                categoryName = categoryName.trim();
                
                if (categoryName.length() < 3) {
                    session.setAttribute("errorMessage", "Category name must be at least 3 characters!");
                    response.sendRedirect("category");
                    return;
                }
                
                if (categoryName.length() > 50) {
                    session.setAttribute("errorMessage", "Category name cannot exceed 50 characters!");
                    response.sendRedirect("category");
                    return;
                }
                
                if (type == null || type.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Type cannot be empty!");
                    response.sendRedirect("category");
                    return;
                }
                
                if (!type.equals("Part") && !type.equals("Product")) {
                    session.setAttribute("errorMessage", "Invalid type! Must be 'Part' or 'Product'");
                    response.sendRedirect("category");
                    return;
                }
                
                // Check if new name already exists (for different category)
                Category existingCategory = dao.getCategoryById(categoryId);
                if (existingCategory == null) {
                    session.setAttribute("errorMessage", "Category not found!");
                    response.sendRedirect("category");
                    return;
                }
                
                // Check duplicate name (only if name changed)
                if (!existingCategory.getCategoryName().equals(categoryName)) {
                    if (dao.categoryNameExists(categoryName, type)) {
                        session.setAttribute("errorMessage", "Category name already exists for this type!");
                        response.sendRedirect("category");
                        return;
                    }
                }
                
                Category category = new Category(categoryId, categoryName, type);
                
                boolean success = dao.updateCategory(category);
                
                if (success) {
                    System.out.println("✅ Edit category successful!");
                    session.setAttribute("successMessage", "Category updated successfully!");
                } else {
                    System.out.println("❌ Edit category failed!");
                    session.setAttribute("errorMessage", "Failed to update category!");
                }
                
                response.sendRedirect("category");
                return;
                
            } catch (NumberFormatException e) {
                System.out.println("❌ Number format error: " + e.getMessage());
                session.setAttribute("errorMessage", "Invalid data!");
                response.sendRedirect("category");
                return;
            } catch (Exception e) {
                System.out.println("❌ Unexpected error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
                response.sendRedirect("category");
                return;
            }
        }

        // ===== XỬ LÝ DELETE =====
        if ("delete".equalsIgnoreCase(action)) {
            try {
                System.out.println("=== START DELETE CATEGORY ===");
                
                int categoryId = Integer.parseInt(request.getParameter("categoryId"));
                System.out.println("Deleting CategoryId: " + categoryId);
                
                // Check if category is being used
                Category category = dao.getCategoryById(categoryId);
                if (category != null) {
                    int itemCount = dao.countItemsInCategory(categoryId, category.getType());
                    if (itemCount > 0) {
                        session.setAttribute("errorMessage", 
                            "Cannot delete category! It is being used by " + itemCount + " " + 
                            category.getType() + "(s).");
                        response.sendRedirect("category");
                        return;
                    }
                }
                
                boolean success = dao.deleteCategory(categoryId);
                
                if (success) {
                    System.out.println("✅ Delete category successful!");
                    session.setAttribute("successMessage", "Category deleted successfully!");
                } else {
                    System.out.println("❌ Delete category failed!");
                    session.setAttribute("errorMessage", "Failed to delete category!");
                }
                
                response.sendRedirect("category");
                return;
                
            } catch (NumberFormatException e) {
                System.out.println("❌ Number format error: " + e.getMessage());
                session.setAttribute("errorMessage", "Invalid ID!");
                response.sendRedirect("category");
                return;
            } catch (Exception e) {
                System.out.println("❌ Unexpected error: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
                response.sendRedirect("category");
                return;
            }
        }

        // Default: redirect to GET
        response.sendRedirect("category");
    }

    @Override
    public String getServletInfo() {
        return "Category Servlet - Manages category CRUD operations";
    }
}