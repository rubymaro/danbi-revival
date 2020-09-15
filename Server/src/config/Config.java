package config;

import java.io.IOException;
import java.io.FileInputStream;
import java.util.Properties;

public final class Config {
    private static final String FILE_NAME = "config.properties";
    private static final Properties properties = new Properties();

    public static Properties getInstance() {
        if (properties.isEmpty()) {
            FileInputStream file;
            try {
                file = new FileInputStream(FILE_NAME);
                properties.load(file);
                file.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        return properties;
    }
}
