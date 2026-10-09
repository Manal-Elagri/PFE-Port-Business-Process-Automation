package Projet_Stage.PFE.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.servlet.config.annotation.*;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    // =========================
    // PASSWORD ENCODER
    // =========================
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    // =========================
    // CORS (Flutter)
    // =========================
    @Override
    public void addCorsMappings(CorsRegistry registry) {

        registry.addMapping("/**")
                .allowedOrigins("*")
                .allowedMethods(
                        "GET",
                        "POST",
                        "PUT",
                        "DELETE",
                        "PATCH",
                        "OPTIONS"
                )
                .allowedHeaders("*");
    }

    // =========================
    // ACCESS FILES
    // =========================
    @Override
    public void addResourceHandlers(
            ResourceHandlerRegistry registry
    ) {

        registry.addResourceHandler("/uploads/**")
                .addResourceLocations(
                        "file:" + uploadDir + "/"
                );
    }
}