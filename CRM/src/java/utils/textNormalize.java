package utils;

import java.text.Normalizer;
import java.util.regex.Pattern;

public class textNormalize {
    public static String removeVietnameseDiacritics(String input) {
        if (input == null) return null;
        String normalized = Normalizer.normalize(input, Normalizer.Form.NFD);
        Pattern pattern = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
        return pattern.matcher(normalized).replaceAll("").toLowerCase(); // thường hóa để so dễ hơn
    }
}
