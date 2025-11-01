package controller;

import java.io.*;
import java.net.*;
import java.nio.file.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import org.json.JSONArray;
import org.json.JSONObject;


public class AskGeminiServlet extends HttpServlet {

    private static final String API_URL =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";
    private static final String API_KEY = "AIzaSyDcz2sQY8VB3JJ4J6LgSZQjObBeP24gP7Q"; // 🔑 thay bằng key của bạn

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1️⃣ Đọc dữ liệu JSON làm "knowledge base"
        String filePath = getServletContext().getRealPath("/data/tech_manager_data.json");
        String content = Files.readString(Paths.get(filePath), java.nio.charset.StandardCharsets.UTF_8);
        JSONArray dataArray = new JSONArray(content);

        // 2️⃣ Chuẩn bị câu hỏi
        String question = request.getParameter("q");
        if (question == null || question.isEmpty()) {
            question = "TechManager làm gì khi hợp đồng là bảo trì?";
        }

        // 3️⃣ Ghép dữ liệu thành context cho Gemini
        StringBuilder context = new StringBuilder();
        for (int i = 0; i < dataArray.length(); i++) {
            JSONObject item = dataArray.getJSONObject(i);
            context.append(item.getString("text")).append("\n");
        }

        JSONObject payload = new JSONObject();
        JSONArray contents = new JSONArray();
        JSONArray parts = new JSONArray();

        parts.put(new JSONObject().put("text", "Dưới đây là thông tin về vai trò TechManager:\n" + context));
        parts.put(new JSONObject().put("text", "Câu hỏi: " + question));

        contents.put(new JSONObject().put("role", "user").put("parts", parts));
        payload.put("contents", contents);

        // 4️⃣ Gọi API Gemini
        URL url = new URL(API_URL + "?key=" + API_KEY);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(payload.toString().getBytes(java.nio.charset.StandardCharsets.UTF_8));
        }

        // 5️⃣ Nhận phản hồi
        InputStream inputStream = (conn.getResponseCode() == 200)
                ? conn.getInputStream()
                : conn.getErrorStream();

        String responseText = new String(inputStream.readAllBytes(), java.nio.charset.StandardCharsets.UTF_8);
responseText = responseText.replaceAll("^\\*+\\s*", "");  // xóa * đầu dòng
responseText = responseText.replaceAll("\\s*\\*\\s*", ""); // xóa * còn lại trong câu
responseText = responseText.replaceAll("[\\t ]+", " ");    // chuẩn hóa khoảng trắng
responseText = responseText.trim();                        // loại bỏ khoảng trắng đầu-cuối
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().println(responseText);
    }
     protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
                doPost(request, response);
    }
}
