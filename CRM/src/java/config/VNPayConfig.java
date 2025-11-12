package config;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Random;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

/**
 * VNPay Configuration and Utilities
 * Using VNPay Sandbox environment
 */
public class VNPayConfig {
    
    // VNPay Sandbox Configuration
    public static String vnp_PayUrl = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
 public static String vnp_ReturnUrl = "http://localhost:8080/CRM/vnpayCallback";

    
    // VNPay Sandbox Test Credentials (từ APP XEM PHIM - đã test thành công)
    public static String vnp_TmnCode = "8LEQ9RXM"; // Terminal ID / Mã Website
    public static String vnp_HashSecret = "PWTVPXDRCHITWPEYQASMOLNVGZCBAZGU"; // Secret Key / Chuỗi bí mật tạo checksum
    
    // VNPay API version
    public static String vnp_Version = "2.1.0";
    public static String vnp_Command = "pay";
    public static String vnp_CurrCode = "VND";
    public static String vnp_Locale = "vn";
    public static String vnp_IpAddr = "127.0.0.1";
    
    /**
     * Tạo mã giao dịch ngẫu nhiên
     */
    public static String getRandomNumber(int len) {
        Random rnd = new Random();
        String chars = "0123456789";
        StringBuilder sb = new StringBuilder(len);
        for (int i = 0; i < len; i++) {
            sb.append(chars.charAt(rnd.nextInt(chars.length())));
        }
        return sb.toString();
    }
    
    /**
     * Hash SHA512
     */
    public static String Sha512(String message) {
        String digest = null;
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-512");
            byte[] bytes = md.digest(message.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }
            digest = sb.toString();
        } catch (NoSuchAlgorithmException ex) {
            ex.printStackTrace();
        }
        return digest;
    }
    
    /**
     * Tạo hash cho VNPay request
     */
    public static String hmacSHA512(final String key, final String data) {
        try {
            if (key == null || data == null) {
                throw new NullPointerException();
            }
            final Mac hmac512 = Mac.getInstance("HmacSHA512");
            byte[] hmacKeyBytes = key.getBytes();
            final SecretKeySpec secretKey = new SecretKeySpec(hmacKeyBytes, "HmacSHA512");
            hmac512.init(secretKey);
            byte[] dataBytes = data.getBytes(StandardCharsets.UTF_8);
            byte[] result = hmac512.doFinal(dataBytes);
            StringBuilder sb = new StringBuilder(2 * result.length);
            for (byte b : result) {
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();
        } catch (Exception ex) {
            return "";
        }
    }
    
    /**
     * Sắp xếp các field và tạo query string
     */
    public static String hashAllFields(Map fields) {
        List fieldNames = new ArrayList(fields.keySet());
        Collections.sort(fieldNames);
        StringBuilder sb = new StringBuilder();
        Iterator itr = fieldNames.iterator();
        while (itr.hasNext()) {
            String fieldName = (String) itr.next();
            String fieldValue = (String) fields.get(fieldName);
            if ((fieldValue != null) && (fieldValue.length() > 0)) {
                sb.append(fieldName);
                sb.append("=");
                sb.append(fieldValue);
                if (itr.hasNext()) {
                    sb.append("&");
                }
            }
        }
        return hmacSHA512(vnp_HashSecret, sb.toString());
    }
    
    /**
     * Tạo query string từ map
     */
    public static String getQueryString(Map<String, String> params) throws UnsupportedEncodingException {
        List<String> fieldNames = new ArrayList<>(params.keySet());
        Collections.sort(fieldNames);
        StringBuilder queryString = new StringBuilder();
        Iterator<String> itr = fieldNames.iterator();
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = params.get(fieldName);
            if (fieldValue != null && fieldValue.length() > 0) {
                queryString.append(URLEncoder.encode(fieldName, StandardCharsets.UTF_8.toString()));
                queryString.append('=');
                queryString.append(URLEncoder.encode(fieldValue, StandardCharsets.UTF_8.toString()));
                if (itr.hasNext()) {
                    queryString.append('&');
                }
            }
        }
        return queryString.toString();
    }
}

