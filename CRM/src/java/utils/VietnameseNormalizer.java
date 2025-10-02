package utils;

import java.text.Normalizer;
import java.util.regex.Pattern;

public class VietnameseNormalizer {
    public static String removeDiacritics(String input) {
        // Lọc ra kí tự và dấu riêng biệt
        String normalized = Normalizer.normalize(input, Normalizer.Form.NFD);
        // Lọc ra các dấu
        Pattern pattern = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
        // Xóa các dấu đi, giữ lại các chữ cái 
        return pattern.matcher(normalized).replaceAll("").toLowerCase();
    }
}

