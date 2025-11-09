/**
 * ✅ THÊM CÁC METHOD NÀY VÀO CLASS VNPayService
 */

package service;

import config.VNPayConfig;
import jakarta.servlet.http.HttpServletRequest;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat;
import java.util.*;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public class VNPayService {
    
    /**
     * ✅ Lấy tất cả parameters từ VNPay callback
     */
    public Map<String, String> getVNPayParams(HttpServletRequest request) {
        Map<String, String> vnpParams = new HashMap<>();
        
        // Lấy tất cả parameters từ request
        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            String paramValue = request.getParameter(paramName);
            
            // Chỉ lấy các params bắt đầu với "vnp_"
            if (paramName.startsWith("vnp_")) {
                vnpParams.put(paramName, paramValue);
            }
        }
        
        return vnpParams;
    }
    
    /**
     * ✅ Verify VNPay signature
     */
    public boolean verifySignature(Map<String, String> vnpParams) {
        try {
            // Lấy signature từ VNPay
            String vnpSecureHash = vnpParams.get("vnp_SecureHash");
            if (vnpSecureHash == null || vnpSecureHash.isEmpty()) {
                System.err.println("❌ Missing vnp_SecureHash");
                return false;
            }
            
            // Remove vnp_SecureHash và vnp_SecureHashType khỏi params
            Map<String, String> paramsToSign = new HashMap<>(vnpParams);
            paramsToSign.remove("vnp_SecureHash");
            paramsToSign.remove("vnp_SecureHashType");
            
            // Tạo hash string
            String hashData = buildHashData(paramsToSign);
            
            // Tính hash với secret key
            String calculatedHash = hmacSHA512(VNPayConfig.vnp_HashSecret, hashData);
            
            // So sánh
            boolean isValid = calculatedHash.equalsIgnoreCase(vnpSecureHash);
            
            System.out.println("🔐 Signature Verification:");
            System.out.println("   - Received Hash: " + vnpSecureHash);
            System.out.println("   - Calculated Hash: " + calculatedHash);
            System.out.println("   - Valid: " + isValid);
            
            return isValid;
            
        } catch (Exception e) {
            System.err.println("❌ Error verifying signature: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * ✅ Build hash data từ params (sắp xếp theo alphabet)
     */
    private String buildHashData(Map<String, String> params) {
        // Sắp xếp params theo key (alphabet)
        List<String> fieldNames = new ArrayList<>(params.keySet());
        Collections.sort(fieldNames);
        
        StringBuilder hashData = new StringBuilder();
        Iterator<String> itr = fieldNames.iterator();
        
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = params.get(fieldName);
            
            if (fieldValue != null && !fieldValue.isEmpty()) {
                hashData.append(fieldName);
                hashData.append('=');
                hashData.append(fieldValue);
                
                if (itr.hasNext()) {
                    hashData.append('&');
                }
            }
        }
        
        return hashData.toString();
    }
    
    /**
     * ✅ HMAC SHA512 encryption
     */
    private String hmacSHA512(String key, String data) {
        try {
            Mac hmac = Mac.getInstance("HmacSHA512");
            SecretKeySpec secretKey = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
            hmac.init(secretKey);
            
            byte[] hash = hmac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            
            // Convert to hex
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            
            return hexString.toString();
            
        } catch (Exception e) {
            throw new RuntimeException("Error calculating HMAC SHA512", e);
        }
    }
    
    /**
     * ✅ Tạo VNPay payment URL
     */
    public String createPaymentUrl(long amount, String orderInfo, String orderId, int requestId) {
        try {
            Map<String, String> vnpParams = new HashMap<>();
            
            // Required params
            vnpParams.put("vnp_Version", VNPayConfig.vnp_Version);
            vnpParams.put("vnp_Command", VNPayConfig.vnp_Command);
            vnpParams.put("vnp_TmnCode", VNPayConfig.vnp_TmnCode);
            vnpParams.put("vnp_Amount", String.valueOf(amount * 100)); // VNPay yêu cầu amount * 100
            vnpParams.put("vnp_CurrCode", "VND");
            vnpParams.put("vnp_TxnRef", orderId);
            vnpParams.put("vnp_OrderInfo", orderInfo);
            vnpParams.put("vnp_OrderType", "other");
            vnpParams.put("vnp_Locale", "vn");
            vnpParams.put("vnp_ReturnUrl", VNPayConfig.vnp_ReturnUrl);
            vnpParams.put("vnp_IpAddr", "127.0.0.1");
            
            // Thời gian
            SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
            String vnpCreateDate = formatter.format(new Date());
            vnpParams.put("vnp_CreateDate", vnpCreateDate);
            
            // Expire time (15 phút)
            Calendar calendar = Calendar.getInstance();
            calendar.add(Calendar.MINUTE, 15);
            String vnpExpireDate = formatter.format(calendar.getTime());
            vnpParams.put("vnp_ExpireDate", vnpExpireDate);
            
            // Build hash data
            String hashData = buildHashData(vnpParams);
            String secureHash = hmacSHA512(VNPayConfig.vnp_HashSecret, hashData);
            
            // Build URL
            StringBuilder url = new StringBuilder(VNPayConfig.vnp_PayUrl);
            url.append("?");
            
            List<String> fieldNames = new ArrayList<>(vnpParams.keySet());
            Collections.sort(fieldNames);
            
            for (String fieldName : fieldNames) {
                String fieldValue = vnpParams.get(fieldName);
                if (fieldValue != null && !fieldValue.isEmpty()) {
                    url.append(fieldName).append("=").append(URLEncoder.encode(fieldValue, "UTF-8"));
                    url.append("&");
                }
            }
            
            url.append("vnp_SecureHash=").append(secureHash);
            
            System.out.println("✅ Created VNPay URL: " + url.toString());
            
            return url.toString();
            
        } catch (Exception e) {
            System.err.println("❌ Error creating VNPay URL: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
}

