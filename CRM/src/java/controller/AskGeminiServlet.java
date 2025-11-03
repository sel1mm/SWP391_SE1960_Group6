package controller;

import java.io.*;
import java.net.*;
import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import org.json.JSONArray;
import org.json.JSONObject;
import dal.DBContext;

public class AskGeminiServlet extends HttpServlet {

    private static final String API_URL =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";
    private static final String API_KEY = "AIzaSyDcz2sQY8VB3JJ4J6LgSZQjObBeP24gP7Q";
    private static final int MAX_SCHEMA_CHARS = 12000;
    private static final int MAX_ROWS = 200;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        if (API_KEY == null || API_KEY.isBlank()) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().println(new JSONObject().put("error", "GEMINI_API_KEY not set").toString());
            return;
        }

        String techDataContent = readFileSafe("/data/tech_manager_data.json", "{\"warning\":\"Không đọc được tech_manager_data.json\"}");
        String schemaContent = readFileSafe("/data/dbschema.json", "{\"warning\":\"Không đọc được dbschema.json\"}");

        if (schemaContent.length() > MAX_SCHEMA_CHARS) {
            String truncated = schemaContent.substring(schemaContent.length() - MAX_SCHEMA_CHARS);
            schemaContent = "/* SCHEMA TRUNCATED - showing last " + MAX_SCHEMA_CHARS + " chars */\n" + truncated;
        }

        String question = Optional.ofNullable(request.getParameter("q")).orElse("").trim();
        if (question.isEmpty()) {
            response.getWriter().println(new JSONObject().put("error", "No question provided (param q)").toString());
            return;
        }

        try {
            // Step 1: Classify question type
            String questionType = classifyQuestion(question);
            
            // Step 2: Handle based on question type
            if ("BUSINESS_PROCESS".equals(questionType)) {
                // Answer about business process/workflow using tech_manager_data.json
                String directAnswer = answerBusinessProcess(question, techDataContent);
                JSONObject resp = new JSONObject();
                resp.put("ai_answer", directAnswer);
                resp.put("question_type", "business_process");
                response.getWriter().println(resp.toString(2));
                return;
            } else if ("CHITCHAT".equals(questionType)) {
                // Handle greetings and casual conversation
                String directAnswer = answerChitchat(question);
                JSONObject resp = new JSONObject();
                resp.put("ai_answer", directAnswer);
                resp.put("question_type", "chitchat");
                response.getWriter().println(resp.toString(2));
                return;
            }
            
            // Step 3: Generate SQL for data queries
            String sql = generateSqlFromGemini(schemaContent, techDataContent, question);

            if (sql == null || sql.isBlank()) {
                JSONObject err = new JSONObject();
                err.put("error", "Gemini did not return a SQL statement.");
                response.getWriter().println(err.toString());
                return;
            }

            String sqlTrim = sql.trim();
            String sqlLower = sqlTrim.toLowerCase(Locale.ROOT);

            if (sqlLower.contains(";")) {
                response.getWriter().println(new JSONObject().put("error", "Multiple statements or semicolon not allowed.").toString());
                return;
            }
            
            String[] forbidden = {"insert ", "update ", "delete ", "drop ", "create ", "alter ", "truncate ", "replace "};
            for (String kw : forbidden) {
                if (sqlLower.contains(kw)) {
                    response.getWriter().println(new JSONObject().put("error", "Only SELECT queries allowed. Forbidden keyword: " + kw.trim()).toString());
                    return;
                }
            }
            
            if (!(sqlLower.startsWith("select") || sqlLower.startsWith("with"))) {
                response.getWriter().println(new JSONObject().put("error", "Only SELECT queries (or WITH ...) are allowed. Generated SQL: " + sqlTrim).toString());
                return;
            }

            JSONObject queryResult = executeSelectToJson(sqlTrim);

            JSONObject finalResponse = new JSONObject();
            finalResponse.put("generated_sql", sqlTrim);
            finalResponse.put("result", queryResult);

            // Generate natural language answer
            String resultSnapshot = buildResultSnapshot(queryResult, 10);
            String nlAnswer = generateNaturalLanguageFromGemini(question, sqlTrim, resultSnapshot);
            if (nlAnswer != null && !nlAnswer.isBlank()) {
                finalResponse.put("ai_answer", nlAnswer);
            }

            response.getWriter().println(finalResponse.toString(2));
        } catch (Exception ex) {
            ex.printStackTrace();
            JSONObject err = new JSONObject();
            err.put("error", "Internal error: " + ex.getMessage());
            response.getWriter().println(err.toString());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }

    private String readFileSafe(String webPath, String fallback) {
        try {
            String real = getServletContext().getRealPath(webPath);
            if (real == null) return fallback;
            Path p = Paths.get(real);
            if (!Files.exists(p)) return fallback;
            return Files.readString(p, StandardCharsets.UTF_8);
        } catch (Exception e) {
            e.printStackTrace();
            return fallback;
        }
    }

    private String generateSqlFromGemini(String schemaContent, String techDataContent, String question) throws IOException {
        String prompt = ""
            + "You are a SQL expert for a maintenance management system database.\n\n"
            + "DATABASE SCHEMA:\n"
            + schemaContent + "\n\n"
            + "BUSINESS CONTEXT:\n"
            + techDataContent + "\n\n"
            + "KEY TABLES AND RELATIONSHIPS:\n"
            + "- Account: Users (customers, technicians, managers)\n"
            + "- Contract: Service contracts with customers\n"
            + "- Equipment: Equipment items under maintenance\n"
            + "- ServiceRequest: Service/repair requests from customers\n"
            + "- WorkTask: Work assignments for technicians\n"
            + "- MaintenanceSchedule: Scheduled maintenance tasks\n"
            + "- Part/PartDetail/Inventory: Spare parts management\n"
            + "- Invoice/Payment: Billing and payment tracking\n"
            + "- RepairReport/RepairResult: Repair documentation\n"
            + "- TechnicianSkill/TechnicianWorkload: Technician capabilities\n\n"
            + "IMPORTANT JOINS:\n"
            + "- Contract -> Account (customerId)\n"
            + "- ContractEquipment -> Contract, Equipment\n"
            + "- ServiceRequest -> Contract, Equipment, Account (createdBy)\n"
            + "- WorkTask -> ServiceRequest, Account (technicianId)\n"
            + "- RepairReport -> ServiceRequest, Account (technicianId)\n"
            + "- MaintenanceSchedule -> Account (assignedTo)\n\n"
            + "USER QUESTION (Vietnamese):\n"
            + question + "\n\n"
            + "INSTRUCTIONS:\n"
            + "1. Analyze the question carefully and identify which tables are needed\n"
            + "2. Use appropriate JOINs to connect related tables\n"
            + "3. If counting/aggregating, use COUNT, SUM, AVG with GROUP BY\n"
            + "4. If filtering by date but no date given, query recent data (e.g., last 30 days or all data)\n"
            + "5. Use meaningful column aliases in Vietnamese if helpful\n"
            + "6. Limit results to 100 rows if no aggregation\n"
            + "7. Output ONLY this JSON format, nothing else:\n"
            + "{\"sql\": \"YOUR_SQL_QUERY_HERE\"}\n\n"
            + "EXAMPLES:\n"
            + "Q: 'Có bao nhiêu khách hàng?'\n"
            + "A: {\"sql\": \"SELECT COUNT(*) as so_khach_hang FROM Account a JOIN AccountRole ar ON a.accountId=ar.accountId JOIN Role r ON ar.roleId=r.roleId WHERE r.roleName='Customer'\"}\n\n"
            + "Q: 'Danh sách thiết bị đang bảo trì'\n"
            + "A: {\"sql\": \"SELECT e.equipmentId, e.serialNumber, e.model FROM Equipment e JOIN ContractEquipment ce ON e.equipmentId=ce.equipmentId JOIN Contract c ON ce.contractId=c.contractId WHERE c.status='Active' LIMIT 100\"}\n\n"
            + "Now generate SQL for the user's question. Output ONLY the JSON format.\n";

        JSONObject payload = new JSONObject();
        JSONArray contents = new JSONArray();
        JSONArray parts = new JSONArray();
        parts.put(new JSONObject().put("text", prompt));
        contents.put(new JSONObject().put("role", "user").put("parts", parts));
        payload.put("contents", contents);

        String resp = callGeminiApi(payload.toString());
        if (resp == null) return null;

        return extractSqlFromGeminiResponse(resp);
    }

    private String extractSqlFromGeminiResponse(String rawResponse) {
        try {
            JSONObject respObj = new JSONObject(rawResponse);
            
            if (respObj.has("candidates")) {
                JSONArray candidates = respObj.getJSONArray("candidates");
                if (candidates.length() > 0) {
                    JSONObject candidate = candidates.getJSONObject(0);
                    if (candidate.has("content")) {
                        JSONObject content = candidate.getJSONObject("content");
                        if (content.has("parts")) {
                            JSONArray parts = content.getJSONArray("parts");
                            if (parts.length() > 0) {
                                JSONObject part = parts.getJSONObject(0);
                                if (part.has("text")) {
                                    String text = part.getString("text");
                                    
                                    // Try to extract JSON {"sql":"..."} from text
                                    String jsonText = extractJsonObject(text);
                                    if (jsonText != null) {
                                        try {
                                            JSONObject sqlObj = new JSONObject(jsonText);
                                            if (sqlObj.has("sql")) {
                                                return sqlObj.getString("sql");
                                            }
                                        } catch (Exception ignore) {}
                                    }
                                    
                                    // Fallback: extract SQL from code blocks
                                    return extractSqlFromText(text);
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private String callGeminiApi(String bodyJson) throws IOException {
        URL url = new URL(API_URL + "?key=" + API_KEY);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
        conn.setDoOutput(true);
        try (OutputStream os = conn.getOutputStream()) {
            os.write(bodyJson.getBytes(StandardCharsets.UTF_8));
        }
        InputStream is = (conn.getResponseCode() == 200) ? conn.getInputStream() : conn.getErrorStream();
        String responseText = new String(is.readAllBytes(), StandardCharsets.UTF_8);
        return responseText;
    }

    private String extractJsonObject(String text) {
        if (text == null) return null;
        int start = text.indexOf('{');
        int end = text.lastIndexOf('}');
        if (start >= 0 && end > start) {
            String sub = text.substring(start, end + 1).trim();
            if (sub.contains("\"sql\"") || sub.contains("'sql'")) return sub;
        }
        return null;
    }

    private String extractSqlFromText(String text) {
        if (text == null) return null;
        
        // Try code fence ```sql ... ```
        int idx = text.toLowerCase().indexOf("```sql");
        if (idx >= 0) {
            int end = text.indexOf("```", idx + 6);
            if (end > idx) {
                return text.substring(idx + 6, end).trim();
            }
        }
        
        // Try generic code fence ``` ... ```
        idx = text.indexOf("```");
        if (idx >= 0) {
            int end = text.indexOf("```", idx + 3);
            if (end > idx) {
                String code = text.substring(idx + 3, end).trim();
                if (code.toLowerCase().startsWith("sql")) {
                    code = code.substring(3).trim();
                }
                if (code.toLowerCase().startsWith("select") || code.toLowerCase().startsWith("with")) {
                    return code;
                }
            }
        }
        
        // Fallback: find first line starting with SELECT or WITH
        String[] lines = text.split("\\r?\\n");
        StringBuilder sb = new StringBuilder();
        boolean started = false;
        for (String l : lines) {
            String lt = l.trim();
            if (!started && (lt.toLowerCase().startsWith("select") || lt.toLowerCase().startsWith("with"))) {
                started = true;
                sb.append(lt).append(" ");
            } else if (started) {
                if (lt.isEmpty() || lt.matches("^[A-Z].*:")) break;
                sb.append(lt).append(" ");
            }
        }
        String candidate = sb.toString().trim();
        return candidate.isEmpty() ? null : candidate;
    }

    private JSONObject executeSelectToJson(String sql) throws SQLException {
        JSONObject out = new JSONObject();
        JSONArray rows = new JSONArray();
        JSONArray cols = new JSONArray();

        DBContext dbctx = new DBContext();
        Connection conn = dbctx.connection;
        if (conn == null) {
            throw new SQLException("Không thể tạo kết nối đến DB (connection is null)");
        }

        try (Connection c = conn;
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            ResultSetMetaData md = rs.getMetaData();
            int colCount = md.getColumnCount();
            for (int i = 1; i <= colCount; i++) {
                cols.put(md.getColumnLabel(i));
            }

            int rowCount = 0;
            while (rs.next() && rowCount < MAX_ROWS) {
                JSONObject row = new JSONObject();
                for (int i = 1; i <= colCount; i++) {
                    Object val = rs.getObject(i);
                    row.put(md.getColumnLabel(i), val == null ? JSONObject.NULL : val);
                }
                rows.put(row);
                rowCount++;
            }
            out.put("columns", cols);
            out.put("rows", rows);
            out.put("rowCount", rows.length());
            if (!rs.isAfterLast()) {
                out.put("note", "Result truncated to " + MAX_ROWS + " rows.");
            }
        }

        return out;
    }

    private String buildResultSnapshot(JSONObject queryResult, int maxRows) {
        StringBuilder sb = new StringBuilder();
        sb.append("Query result snapshot (up to ").append(maxRows).append(" rows):\n");
        JSONArray cols = queryResult.optJSONArray("columns");
        JSONArray rows = queryResult.optJSONArray("rows");
        if (cols == null || rows == null) {
            sb.append("No rows.");
            return sb.toString();
        }
        
        for (int i = 0; i < cols.length(); i++) {
            if (i > 0) sb.append(" | ");
            sb.append(cols.getString(i));
        }
        sb.append("\n");
        
        for (int r = 0; r < Math.min(rows.length(), maxRows); r++) {
            JSONObject row = rows.getJSONObject(r);
            for (int c = 0; c < cols.length(); c++) {
                if (c > 0) sb.append(" | ");
                String colName = cols.getString(c);
                Object v = row.opt(colName);
                sb.append(v == JSONObject.NULL ? "NULL" : v.toString());
            }
            sb.append("\n");
        }
        if (rows.length() == 0) sb.append("No rows.\n");
        return sb.toString();
    }

    private String generateNaturalLanguageFromGemini(String question, String sql, String resultSnapshot) {
        try {
            String prompt = ""
                + "USER QUESTION (Vietnamese): " + question + "\n\n"
                + "SQL EXECUTED: " + sql + "\n\n"
                + "QUERY RESULTS:\n" + resultSnapshot + "\n\n"
                + "TASK: Provide a SHORT, CLEAR answer in Vietnamese based on the results.\n"
                + "- Answer in 1-2 sentences maximum\n"
                + "- Be specific with numbers/names from results\n"
                + "- If no data: say 'Không có dữ liệu'\n"
                + "- Do NOT include SQL or technical explanations\n"
                + "- Keep under 150 characters\n"
                + "- Use natural Vietnamese language\n\n"
                + "ANSWER (Vietnamese only):\n";

            JSONObject payload = new JSONObject();
            JSONArray contents = new JSONArray();
            JSONArray parts = new JSONArray();
            parts.put(new JSONObject().put("text", prompt));
            contents.put(new JSONObject().put("role", "user").put("parts", parts));
            payload.put("contents", contents);

            String resp = callGeminiApi(payload.toString());
            if (resp == null) return null;
            
            // Parse Gemini response to get natural language text
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
                                        // Remove code blocks if any
                                        text = text.replaceAll("(?s)```.*?```", "").trim();
                                        // Truncate if too long
                                        if (text.length() > 500) {
                                            text = text.substring(0, 500);
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
            return null;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    // Classify question into: DATA_QUERY, BUSINESS_PROCESS, or CHITCHAT
    private String classifyQuestion(String question) throws IOException {
        String prompt = ""
            + "Classify this Vietnamese question into ONE category:\n\n"
            + "Categories:\n"
            + "1. DATA_QUERY: Questions asking for data, statistics, lists, counts from database\n"
            + "   Examples: 'Có bao nhiêu khách hàng?', 'Danh sách thiết bị', 'Tổng số yêu cầu'\n\n"
            + "2. BUSINESS_PROCESS: Questions about workflows, procedures, how things work\n"
            + "   Examples: 'Quy trình tạo hợp đồng như thế nào?', 'Luồng xử lý yêu cầu sửa chữa', 'Cách phân công kỹ thuật viên'\n\n"
            + "3. CHITCHAT: Greetings, casual talk, unclear questions\n"
            + "   Examples: 'hello', 'xin chào', 'bạn là ai', 'cảm ơn'\n\n"
            + "User question: " + question + "\n\n"
            + "Output ONLY ONE word: DATA_QUERY or BUSINESS_PROCESS or CHITCHAT\n";
        
        JSONObject payload = new JSONObject();
        JSONArray contents = new JSONArray();
        JSONArray parts = new JSONArray();
        parts.put(new JSONObject().put("text", prompt));
        contents.put(new JSONObject().put("role", "user").put("parts", parts));
        payload.put("contents", contents);
        
        String resp = callGeminiApi(payload.toString());
        if (resp == null) return "DATA_QUERY"; // Default fallback
        
        // Extract classification from response
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
                                    String text = part.getString("text").trim().toUpperCase();
                                    if (text.contains("BUSINESS_PROCESS")) return "BUSINESS_PROCESS";
                                    if (text.contains("CHITCHAT")) return "CHITCHAT";
                                    if (text.contains("DATA_QUERY")) return "DATA_QUERY";
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "DATA_QUERY"; // Default
    }
    
    // Answer questions about business processes using tech_manager_data.json
    private String answerBusinessProcess(String question, String techDataContent) throws IOException {
        String prompt = ""
            + "You are an expert on a maintenance management system.\n\n"
            + "BUSINESS PROCESS DOCUMENTATION:\n"
            + techDataContent + "\n\n"
            + "USER QUESTION (Vietnamese): " + question + "\n\n"
            + "TASK: Answer the question clearly in Vietnamese based on the business process documentation.\n"
            + "- Explain the workflow/process step by step if asked\n"
            + "- Be specific and reference relevant roles/steps\n"
            + "- Keep answer under 500 characters\n"
            + "- Use natural Vietnamese language\n"
            + "- If information not available, say 'Tôi chưa có thông tin về quy trình này'\n\n"
            + "ANSWER (Vietnamese):\n";
        
        JSONObject payload = new JSONObject();
        JSONArray contents = new JSONArray();
        JSONArray parts = new JSONArray();
        parts.put(new JSONObject().put("text", prompt));
        contents.put(new JSONObject().put("role", "user").put("parts", parts));
        payload.put("contents", contents);
        
        String resp = callGeminiApi(payload.toString());
        if (resp == null) return "Xin lỗi, tôi không thể trả lời câu hỏi này.";
        
        // Extract answer
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
                                    if (text.length() > 800) text = text.substring(0, 800);
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
    
    // Answer chitchat questions
    private String answerChitchat(String question) throws IOException {
        String prompt = ""
            + "You are a friendly AI assistant for a maintenance management system.\n\n"
            + "USER MESSAGE (Vietnamese): " + question + "\n\n"
            + "TASK: Respond naturally and friendly in Vietnamese.\n"
            + "- For greetings: greet back and offer help\n"
            + "- For thanks: acknowledge politely\n"
            + "- For unclear questions: ask for clarification\n"
            + "- Keep response under 100 characters\n\n"
            + "RESPONSE (Vietnamese):\n";
        
        JSONObject payload = new JSONObject();
        JSONArray contents = new JSONArray();
        JSONArray parts = new JSONArray();
        parts.put(new JSONObject().put("text", prompt));
        contents.put(new JSONObject().put("role", "user").put("parts", parts));
        payload.put("contents", contents);
        
        String resp = callGeminiApi(payload.toString());
        if (resp == null) return "Xin chào! Tôi có thể giúp gì cho bạn?";
        
        // Extract answer
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
                                    if (text.length() > 200) text = text.substring(0, 200);
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
        return "Xin chào! Tôi có thể giúp gì cho bạn?";
    }
}