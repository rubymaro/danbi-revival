package database;

import sun.misc.BASE64Encoder;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import config.Config;

import java.nio.charset.StandardCharsets;

public class Crypto {
    private static final String key = Config.getInstance().getProperty("Database.password");

    public static String encrypt(final String text) {
        try {
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            byte[] keyBytes = new byte[16];
            byte[] b = key.getBytes(StandardCharsets.UTF_8);
            final int len = Math.min(b.length, keyBytes.length);

            System.arraycopy(b, 0, keyBytes, 0, len);
            SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
            IvParameterSpec ivSpec = new IvParameterSpec(keyBytes);
            cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivSpec);

            BASE64Encoder encoder = new BASE64Encoder();
            byte[] results = cipher.doFinal(text.getBytes(StandardCharsets.UTF_8));

            return encoder.encode(results);
        } catch (Exception e) {
            e.printStackTrace();

            return text;
        }
    }
}