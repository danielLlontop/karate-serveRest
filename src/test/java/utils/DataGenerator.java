package utils;
import net.datafaker.Faker;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

public class DataGenerator {
    private static final Faker faker = new Faker(Locale.of("es"));
    private enum InvalidEmailType {
        NO_EXTENSION,     // "usuario@dominio"
        NO_AT,            // "usuariodominio.com"
        NO_USERNAME,      // "@dominio.com"
        DOUBLE_AT         // "usuario@@dominio.com"
    }
    private static String getFullName() {
        return faker.name().fullName();
    }

    private static String getEmail() {

        return faker.internet().safeEmailAddress();
    }

    private static String getPassword() {
        return faker.internet().password(
                8,
                16,
                true,
                true,
                true);
    }

    private static String getIsAdmin() {
            boolean randomBoolean = faker.bool().bool();
            return String.valueOf(randomBoolean);
    }

    private static String getInvalidEmail(InvalidEmailType type) {
        String username = faker.internet().username();
        String domain = faker.internet().domainName();

        return switch (type) {
            case NO_EXTENSION->{
                yield username + "@" + faker.internet().domainWord(); // ej: "pedro@gmail"
            }
            case NO_AT-> {
                yield username + domain;                              // ej: "pedrogmail.com"
            }
            case NO_USERNAME-> {
                yield "@" + domain;                                   // ej: "@gmail.com"
            }
            case DOUBLE_AT-> {
                yield username + "@@" + domain;                       // ej: "pedro@@gmail.com"
            }
            default -> throw new IllegalArgumentException("Sin argumentos");
        };
    }

    public static String getInvalidEmail(String type) {
        return getInvalidEmail(InvalidEmailType.valueOf(type.toUpperCase()));
    }

    public static Map<String,Object> buildUserPayload() {
        Map<String,Object> user = new HashMap<>();
        user.put("nome", getFullName());
        user.put("email", getEmail());
        user.put("password", getPassword());
        user.put("administrador", getIsAdmin());
        return user;
    }

}
