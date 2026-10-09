package Projet_Stage.PFE.security;

import Projet_Stage.PFE.entities.User;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.security.Key;
import java.util.Date;

@Service
@Getter
public class JwtService {

    @Value("${app.jwt.secret}")
    private String secret;

    @Value("${app.jwt.expiration}")
    private Long expiration;


    private Key getKey() {
        return Keys.hmacShaKeyFor(
                secret.getBytes()
        );
    }


    // =========================
    // GENERER TOKEN
    // =========================
    public String generateToken(User user) {

        return Jwts.builder()

                .setSubject(
                        user.getId().toString()
                )

                .claim(
                        "role",
                        user.getRole().name()
                )

                .setIssuedAt(
                        new Date()
                )

                .setExpiration(
                        new Date(
                                System.currentTimeMillis()
                                        + expiration
                        )
                )

                .signWith(
                        getKey(),
                        SignatureAlgorithm.HS256
                )

                .compact();
    }


    // =========================
    // EXTRAIRE USER ID
    // =========================
    public Long extractUserId(String token) {

        Claims claims = parse(token);

        return Long.parseLong(
                claims.getSubject()
        );
    }


    // =========================
    // EXTRAIRE ROLE
    // =========================
    public String extractRole(String token) {

        Claims claims = parse(token);

        return claims.get(
                "role",
                String.class
        );
    }


    private Claims parse(String token) {

        return Jwts.parserBuilder()

                .setSigningKey(
                        getKey()
                )

                .build()

                .parseClaimsJws(token)

                .getBody();
    }
}