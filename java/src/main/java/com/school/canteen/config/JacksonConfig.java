package com.school.canteen.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.boot.autoconfigure.jackson.Jackson2ObjectMapperBuilderCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Jackson配置类，用于支持Java 8日期时间类型的序列化和反序列化
 */
@Configuration
public class JacksonConfig {

    // 使用Jackson2ObjectMapperBuilderCustomizer确保Spring Boot自动配置的ObjectMapper也应用这些设置
    @Bean
    public Jackson2ObjectMapperBuilderCustomizer jacksonCustomizer() {
        return builder -> {
            // 注册JavaTimeModule以支持Java 8日期时间类型
            builder.modules(new JavaTimeModule());
            // 禁用写入日期为时间戳
            builder.featuresToDisable(com.fasterxml.jackson.databind.SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
        };
    }
    
    // 同时保留ObjectMapper的Bean定义，确保全面覆盖
    @Bean
    public ObjectMapper objectMapper() {
        ObjectMapper objectMapper = new ObjectMapper();
        // 注册JavaTimeModule以支持Java 8日期时间类型
        objectMapper.registerModule(new JavaTimeModule());
        // 禁用写入日期为时间戳
        objectMapper.disable(com.fasterxml.jackson.databind.SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
        return objectMapper;
    }
}