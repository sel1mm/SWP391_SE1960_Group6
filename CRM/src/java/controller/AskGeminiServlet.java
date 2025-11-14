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

        String faqContent = readFAQFile();
        if (faqContent == null || faqContent.equals("[]")) {
            System.err.println("WARNING: FAQ file not found or empty");
            faqContent = "[]";
        }

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
            question = Optional.ofNullable(request.getParameter("q")).orElse("").trim();
        }

        if (question.isEmpty()) {
            JSONObject error = new JSONObject();
            error.put("error", "Vui lòng nhập câu hỏi");
            response.getWriter().println(error.toString());
            return;
        }

        try {
            // Kiểm tra loại câu hỏi và xử lý phù hợp
            String answer = answerQuestion(question, faqContent);
            
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

    /**
     * Phương thức mới: Phân loại và trả lời câu hỏi
     */
    private String answerQuestion(String question, String faqContent) throws IOException {
        // Kiểm tra xem có phải câu hỏi chào hỏi/thông thường không
        if (isGreetingOrSmallTalk(question)) {
            return handleGeneralConversation(question);
        }
        
        // Nếu không phải, tìm trong FAQ
        return answerFromFAQ(question, faqContent);
    }

    /**
     * Kiểm tra câu hỏi có phải chào hỏi/hội thoại thông thường
     */
    private boolean isGreetingOrSmallTalk(String question) {
        String q = question.toLowerCase().trim();
        
        // Danh sách từ khóa chào hỏi và câu hỏi thông thường
        String[] greetings = {
            "hello", "hi", "hey", "chào", "xin chào", "chao",
            "how are you", "bạn khỏe không", "bạn thế nào",
            "good morning", "good afternoon", "good evening",
            "buổi sáng", "buổi chiều", "buổi tối",
            "cảm ơn", "thank", "thanks", "ok", "okay",
            "tạm biệt", "bye", "goodbye", "see you",
            "bạn là ai", "who are you", "you are",
            "tên bạn", "your name", "giới thiệu",
            "help me", "giúp tôi", "giúp mình"
        };
        
        for (String keyword : greetings) {
            if (q.contains(keyword)) {
                return true;
            }
        }
        
        // Câu hỏi ngắn (dưới 15 ký tự) thường là chào hỏi
        if (q.length() < 15 && !q.contains("?")) {
            return true;
        }
        
        return false;
    }

    /**
     * Xử lý các câu hỏi chào hỏi và hội thoại thông thường
     */
    private String handleGeneralConversation(String question) throws IOException {
        String prompt = 
            "Bạn là trợ lý AI thân thiện cho hệ thống quản lý bảo trì thiết bị.\n\n" +
            "THÔNG TIN VỀ BẠN:\n" +
            "- Tên: Trợ lý AI\n" +
            "- Vai trò: Hỗ trợ khách hàng về hệ thống quản lý bảo trì thiết bị\n" +
            "- Khả năng: Trả lời câu hỏi về bảo trì thiết bị, hướng dẫn sử dụng hệ thống\n\n" +
            "CÂU NÓI CỦA NGƯỜI DÙNG: " + question + "\n\n" +
            "YÊU CẦU:\n" +
            "- Trả lời một cách tự nhiên, thân thiện bằng tiếng Việt\n" +
            "- Nếu là lời chào, hãy chào lại và giới thiệu bản thân ngắn gọn\n" +
            "- Nếu là cảm ơn, hãy đáp lại lịch sự\n" +
            "- Nếu hỏi về khả năng, giải thích bạn có thể giúp gì\n" +
            "- Giữ câu trả lời ngắn gọn (dưới 150 từ)\n" +
            "- Luôn thể hiện sẵn sàng hỗ trợ\n\n" +
            "CÂU TRẢ LỜI:";
        
        JSONObject payload = new JSONObject();
        JSONArray contents = new JSONArray();
        JSONArray parts = new JSONArray();
        parts.put(new JSONObject().put("text", prompt));
        contents.put(new JSONObject().put("role", "user").put("parts", parts));
        payload.put("contents", contents);
        
        String resp = callGeminiApi(payload.toString());
        if (resp == null) {
            return "Xin chào! Tôi là trợ lý AI. Tôi có thể giúp gì cho bạn hôm nay?";
        }
        
        return extractTextFromGeminiResponse(resp, 500);
    }

    /**
     * Trả lời câu hỏi từ FAQ
     */
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
        
        text = text.replace("\r\n", "\n").replace("\r", "\n");
        
        StringBuilder formatted = new StringBuilder();
        String[] paragraphs = text.split("\n");
        
        for (String paragraph : paragraphs) {
            if (paragraph.trim().isEmpty()) {
                formatted.append("\n");
                continue;
            }
            
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