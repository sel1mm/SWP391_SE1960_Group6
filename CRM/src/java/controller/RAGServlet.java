package controller;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONArray;




public class RAGServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1️⃣ Đọc file JSON từ thư mục Web Pages/data/
        String filePath = getServletContext().getRealPath("/data/TechManager.json");
       String content = Files.readString(Paths.get(filePath), java.nio.charset.StandardCharsets.UTF_8);

        // 2️⃣ Parse và in ra dữ liệu
        JSONArray json = new JSONArray(content); 

        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().println(json.toString(2));
    }
}