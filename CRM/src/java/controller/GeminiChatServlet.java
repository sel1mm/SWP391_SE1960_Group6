package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.*;
import java.net.*;
import org.json.*;

public class GeminiChatServlet extends HttpServlet {

    private static final String API_KEY = "AIzaSyDcz2sQY8VB3JJ4J6LgSZQjObBeP24gP7Q";
    private static final String API_URL =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String userMessage = request.getParameter("message");

        if (userMessage == null || userMessage.trim().isEmpty()) {
            response.getWriter().write("{\"error\":\"Tin nhắn không được để trống\"}");
            return;
        }

        // 🧩 Đọc dữ liệu JSON trong thư mục /data
        String dataPath = getServletContext().getRealPath("/../data/TechManager.json");
        String knowledge = readFile(dataPath);

        // 🧠 Ghép dữ liệu vào prompt
        String fullPrompt = "Dưới đây là dữ liệu nội bộ của hệ thống:\n\n"
                + knowledge
                + "\n\nDựa vào thông tin trên, hãy trả lời câu hỏi sau bằng tiếng Việt:\n"
                + userMessage;

        HttpURLConnection conn = null;
        try {
            URL url = new URL(API_URL);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("X-goog-api-key", API_KEY);
            conn.setConnectTimeout(15000);
            conn.setReadTimeout(30000);

            // Gửi request lên Gemini
            JSONObject requestBody = new JSONObject();
            JSONArray contents = new JSONArray();
            JSONObject content = new JSONObject();
            JSONArray parts = new JSONArray();

            JSONObject part = new JSONObject();
            part.put("text", fullPrompt);
            parts.put(part);

            content.put("parts", parts);
            contents.put(content);
            requestBody.put("contents", contents);

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = requestBody.toString().getBytes("UTF-8");
                os.write(input, 0, input.length);
            }

            int statusCode = conn.getResponseCode();

            if (statusCode == 200) {
                String responseBody = readStream(conn.getInputStream());
                JSONObject jsonResponse = new JSONObject(responseBody);

                String reply = jsonResponse
                        .getJSONArray("candidates")
                        .getJSONObject(0)
                        .getJSONObject("content")
                        .getJSONArray("parts")
                        .getJSONObject(0)
                        .getString("text");

                JSONObject result = new JSONObject();
                result.put("success", true);
                result.put("reply", reply);
                response.getWriter().write(result.toString());

            } else {
                String errorBody = readStream(conn.getErrorStream());
                response.getWriter().write("{\"error\":\"Lỗi Gemini API: " + errorBody + "\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"error\":\"Lỗi kết nối: " + e.getMessage() + "\"}");
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    private String readStream(InputStream stream) throws IOException {
        if (stream == null) return "";
        BufferedReader reader = new BufferedReader(new InputStreamReader(stream, "UTF-8"));
        StringBuilder result = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) result.append(line);
        return result.toString();
    }

    private String readFile(String path) throws IOException {
        File file = new File(path);
        if (!file.exists()) {
            return "Không tìm thấy dữ liệu.";
        }
        BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(file), "UTF-8"));
        StringBuilder content = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            content.append(line).append("\n");
        }
        reader.close();
        return content.toString();
    }
     protected void doGet(HttpServletRequest request, HttpServletResponse response){
           
    }
}
