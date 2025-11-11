package controller;

import java.io.*;
import java.net.*;
import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet("/askGemini")
public class AskGeminiServlet extends HttpServlet {

    private static final String API_URL =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";
    private static final String API_KEY = "AIzaSyDcz2sQY8VB3JJ4J6LgSZQjObBeP24gP7Q";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // Enable CORS if needed
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");

        if (API_KEY == null || API_KEY.isBlank()) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JSONObject error = new JSONObject();
            error.put("error", "API_KEY not configured");
            response.getWriter().println(error.toString());
            return;
        }

        // Đọc file customer.json từ thư mục data
        String faqContent = readFAQFile();
        
        if (faqContent == null || faqContent.equals("[]")) {
            System.err.println("WARNING: FAQ file not found or empty");
            faqContent = "[]"; // Fallback to empty array
        }

        // Đọc câu hỏi từ request
        String question = "";
        try {
            BufferedReader reader = request.getReader();
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            
            if (sb.length() > 0) {
                JSONObject requestBody = new JSONObject(sb.toString());
                question = requestBody.optString("q", "").trim();
            }
        } catch (Exception e) {
            // Fallback to parameter
            question = Optional.ofNullable(request.getParameter("q")).orElse("").trim();
        }

        if (question.isEmpty()) {
            JSONObject error = new JSONObject();
            error.put("error", "Vui lòng nhập câu hỏi");
            response.getWriter().println(error.toString());
            return;
        }

        try {
            // Gọi Gemini để trả lời
            String answer = answerFromFAQ(question, faqContent);
            
            JSONObject resp = new JSONObject();
            resp.put("answer", answer);
            resp.put("success", true);
            
            response.getWriter().println(resp.toString());
        } catch (Exception ex) {
            ex.printStackTrace();
            JSONObject err = new JSONObject();
            err.put("error", "Có lỗi xảy ra: " + ex.getMessage());
            err.put("success", false);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().println(err.toString());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setStatus(HttpServletResponse.SC_OK);
    }

    private String readFAQFile() {
        try {
            // Try multiple paths
            String[] paths = {
                "/data/customer.json",
                "/WEB-INF/data/customer.json",
                "data/customer.json"
            };
            
            for (String webPath : paths) {
                String real = getServletContext().getRealPath(webPath);
                if (real != null) {
                    Path p = Paths.get(real);
                    if (Files.exists(p)) {
                        String content = Files.readString(p, StandardCharsets.UTF_8);
                        System.out.println("FAQ loaded from: " + webPath);
                        return content;
                    }
                }
            }
            
            // Try as resource
            InputStream is = getServletContext().getResourceAsStream("/data/customer.json");
            if (is != null) {
                String content = new String(is.readAllBytes(), StandardCharsets.UTF_8);
                System.out.println("FAQ loaded from resource stream");
                return content;
            }
            
            System.err.println("FAQ file not found in any location");
            return "[]";
        } catch (Exception e) {
            e.printStackTrace();
            return "[]";
        }
    }

    private String answerFromFAQ(String question, String faqContent) throws IOException {
        String prompt = 
            "Bạn là trợ lý AI hỗ trợ khách hàng cho hệ thống quản lý bảo trì thiết bị.\n\n" +
            "CƠ SỞ KIẾN THỨC FAQ:\n" +
            faqContent + "\n\n" +
            "CÂU HỎI CỦA KHÁCH HÀNG: " + question + "\n\n" +
            "NHIỆM VỤ:\n" +
            "- Tìm câu trả lời phù hợp nhất từ cơ sở kiến thức FAQ\n" +
            "- Trả lời bằng tiếng Việt, rõ ràng và chi tiết\n" +
            "- Nếu là hướng dẫn, liệt kê từng bước cụ thể\n" +
            "- Giữ câu trả lời dưới 1000 ký tự\n" +
            "- Sử dụng ngôn ngữ tự nhiên, thân thiện\n" +
            "- Nếu không tìm thấy thông tin liên quan, trả lời: 'Tôi chưa có thông tin về câu hỏi này. Vui lòng liên hệ bộ phận hỗ trợ khách hàng để được tư vấn chi tiết.'\n\n" +
            "CÂU TRẢ LỜI (Tiếng Việt):\n";
        
        JSONObject payload = new JSONObject();
        JSONArray contents = new JSONArray();
        JSONArray parts = new JSONArray();
        parts.put(new JSONObject().put("text", prompt));
        contents.put(new JSONObject().put("role", "user").put("parts", parts));
        payload.put("contents", contents);
        
        String resp = callGeminiApi(payload.toString());
        if (resp == null) {
            return "Xin lỗi, tôi không thể trả lời câu hỏi này lúc này. Vui lòng thử lại sau.";
        }
        
        return extractTextFromGeminiResponse(resp, 1200);
    }

    private String callGeminiApi(String bodyJson) throws IOException {
        URL url = new URL(API_URL + "?key=" + API_KEY);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
        conn.setDoOutput(true);
        conn.setConnectTimeout(10000);
        conn.setReadTimeout(10000);
        
        try (OutputStream os = conn.getOutputStream()) {
            os.write(bodyJson.getBytes(StandardCharsets.UTF_8));
            os.flush();
        }
        
        int responseCode = conn.getResponseCode();
        InputStream is = (responseCode == 200) ? conn.getInputStream() : conn.getErrorStream();
        String responseText = new String(is.readAllBytes(), StandardCharsets.UTF_8);
        is.close();
        
        if (responseCode != 200) {
            System.err.println("Gemini API Error: " + responseText);
        }
        
        return responseText;
    }

 private String extractTextFromGeminiResponse(String resp, int maxLength) {
    try {
        JSONObject respObj = new JSONObject(resp);
        if (respObj.has("candidates")) {
            JSONArray candidates = respObj.getJSONArray("candidates");
            if (candidates.length() > 0) {
                JSONObject candidate = candidates.getJSONObject(0);
                if (candidate.has("content")) {
                    JSONObject content = candidate.getJSONObject("content");
                    if (content.has("parts")) {
                        JSONArray resParts = content.getJSONArray("parts");
                        if (resParts.length() > 0) {
                            JSONObject part = resParts.getJSONObject(0);
                            if (part.has("text")) {
                                String text = part.getString("text").trim();
                                
                                // Format text để xuống dòng đẹp hơn
                                text = formatTextForDisplay(text);
                                
                                text = text.replaceAll("(?s)```.*?```", "").trim();
                                if (text.length() > maxLength) {
                                    text = text.substring(0, maxLength) + "...";
                                }
                                return text;
                            }
                        }
                    }
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return "Xin lỗi, tôi không thể trả lời câu hỏi này.";
}

private String formatTextForDisplay(String text) {
    if (text == null || text.isEmpty()) {
        return text;
    }
    
    // 1. Giữ nguyên các dòng mới có sẵn
    text = text.replace("\r\n", "\n").replace("\r", "\n");
    
    // 2. Đảm bảo mỗi dòng không quá dài (tự động xuống dòng)
    StringBuilder formatted = new StringBuilder();
    String[] paragraphs = text.split("\n");
    
    for (String paragraph : paragraphs) {
        if (paragraph.trim().isEmpty()) {
            formatted.append("\n"); // Giữ khoảng cách giữa các đoạn
            continue;
        }
        
        // Nếu đoạn văn quá dài, tự động xuống dòng
        if (paragraph.length() > 80) {
            String[] words = paragraph.split(" ");
            StringBuilder line = new StringBuilder();
            
            for (String word : words) {
                if (line.length() + word.length() + 1 > 80) {
                    formatted.append(line.toString().trim()).append("\n");
                    line = new StringBuilder();
                }
                line.append(word).append(" ");
            }
            if (line.length() > 0) {
                formatted.append(line.toString().trim()).append("\n");
            }
        } else {
            formatted.append(paragraph).append("\n");
        }
    }
    
    return formatted.toString().trim();
}
}