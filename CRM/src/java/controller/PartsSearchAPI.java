package controller;

import dal.PartDetailDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

/**
 * API endpoint for searching available parts for repair reports.
 * Returns JSON array of available parts matching search criteria.
 */
public class PartsSearchAPI extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json");

        String query = req.getParameter("q");
        int limit = Math.min(parseInt(req.getParameter("limit"), 20), 50); // Max 50 results

        if (query == null || query.trim().isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            try (PrintWriter out = resp.getWriter()) {
                JsonObject error = new JsonObject();
                error.addProperty("error", "Query parameter 'q' is required");
                out.print(new Gson().toJson(error));
            }
            return;
        }

        try {
            List<Map<String, Object>> results = searchAvailableParts(query.trim(), limit);

            Gson gson = new Gson();
            try (PrintWriter out = resp.getWriter()) {
                out.print(gson.toJson(results));
            }

        } catch (SQLException e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            try (PrintWriter out = resp.getWriter()) {
                JsonObject error = new JsonObject();
                error.addProperty("error", "Database error: " + e.getMessage());
                out.print(new Gson().toJson(error));
            }
        }
    }

    /**
     * Search for available parts by name or serial number.
     */
    private List<Map<String, Object>> searchAvailableParts(String query, int limit) throws SQLException {
        List<Map<String, Object>> results = new ArrayList<>();

        String sql = "SELECT " +
                    "    p.partId, " +
                    "    p.partName, " +
                    "    p.unitPrice, " +
                    "    MIN(pd.partDetailId) as partDetailId, " +
                    "    MIN(CASE WHEN pd.status = 'Available' THEN pd.serialNumber END) as serialNumber, " +
                    "    MIN(CASE WHEN pd.status = 'Available' THEN pd.location END) as location, " +
                    "    COUNT(CASE WHEN pd.status = 'Available' THEN 1 END) as availableQuantity " +
                    "FROM Part p " +
                    "LEFT JOIN PartDetail pd ON p.partId = pd.partId " +
                    "WHERE pd.status = 'Available' " +
                    "  AND (p.partName LIKE ? OR pd.serialNumber LIKE ?) " +
                    "GROUP BY p.partId, p.partName, p.unitPrice " +
                    "HAVING availableQuantity > 0 " +
                    "ORDER BY p.partName " +
                    "LIMIT ?";

        try (var con = new dal.DBContext().connection;
             var ps = con.prepareStatement(sql)) {

            String searchPattern = "%" + query + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setInt(3, limit);

            try (var rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> part = new HashMap<>();
                    part.put("partId", rs.getInt("partId"));
                    part.put("partName", rs.getString("partName"));
                    part.put("serialNumber", rs.getString("serialNumber"));
                    part.put("location", rs.getString("location"));
                    part.put("unitPrice", rs.getBigDecimal("unitPrice"));
                    part.put("availableQuantity", rs.getInt("availableQuantity"));
                    results.add(part);
                }
            }
        }

        return results;
    }

    private int parseInt(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }
}
