package com.school.canteen.config;

import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.jsontype.impl.LaissezFaireSubTypeValidator;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.lang.NonNull;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;
import org.springframework.data.redis.serializer.StringRedisSerializer;

import java.time.Duration;

/**
 * Redis 缓存配置类
 * <p>配置 RedisCacheManager，使用 JSON 序列化，设置默认过期时间</p>
 */
@Configuration
@EnableCaching
public class CacheConfig {

    private final ObjectMapper objectMapper;
    
    // 注入在JacksonConfig中配置的ObjectMapper
    public CacheConfig(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @Bean
    public CacheManager cacheManager(@NonNull RedisConnectionFactory redisConnectionFactory) {
        // 创建一个专门用于Redis缓存的ObjectMapper，复制全局配置
        ObjectMapper redisObjectMapper = objectMapper.copy();
        
        // 注册Hibernate5Module（如果存在）或配置忽略Lazy加载异常
        // 即使没有引入Hibernate模块，也可以通过配置来忽略Hibernate Proxy
        redisObjectMapper.configure(com.fasterxml.jackson.databind.SerializationFeature.FAIL_ON_EMPTY_BEANS, false);
        
        // 注册Hibernate5JakartaModule
        // 使用jackson-datatype-hibernate5-jakarta处理Hibernate Lazy加载
        try {
            Class<?> hibernateModuleClass = Class.forName("com.fasterxml.jackson.datatype.hibernate5.jakarta.Hibernate5JakartaModule");
            com.fasterxml.jackson.databind.Module hibernateModule = (com.fasterxml.jackson.databind.Module) hibernateModuleClass.getDeclaredConstructor().newInstance();
            
            // 显式配置：序列化时如果遇到Lazy字段且未初始化，不要强制初始化（避免No Session错误），而是输出null
            // Hibernate5JakartaModule默认行为是: FORCE_LAZY_LOADING=false (不强制加载)
            
            redisObjectMapper.registerModule(hibernateModule);
        } catch (Exception e) {
             // 忽略，说明没有Hibernate模块依赖
             // 如果类名不对（比如旧版hibernate5），尝试旧版类名
             try {
                Class<?> hibernateModuleClass = Class.forName("com.fasterxml.jackson.datatype.hibernate5.Hibernate5Module");
                com.fasterxml.jackson.databind.Module hibernateModule = (com.fasterxml.jackson.databind.Module) hibernateModuleClass.getDeclaredConstructor().newInstance();
                redisObjectMapper.registerModule(hibernateModule);
             } catch (Exception ignored) {}
        }

        // 启用类型信息，解决反序列化时变成LinkedHashMap的问题
        redisObjectMapper.activateDefaultTyping(
                LaissezFaireSubTypeValidator.instance,
                ObjectMapper.DefaultTyping.NON_FINAL,
                JsonTypeInfo.As.PROPERTY);

        // 使用配置好的ObjectMapper创建GenericJackson2JsonRedisSerializer
        // 这样可以确保Redis缓存也能正确处理Java 8的日期时间类型
        GenericJackson2JsonRedisSerializer jacksonSerializer = new GenericJackson2JsonRedisSerializer(redisObjectMapper);
        
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
                .entryTtl(Duration.ofHours(1)) // 设置缓存过期时间为1小时
                .serializeKeysWith(RedisSerializationContext.SerializationPair.fromSerializer(new StringRedisSerializer()))
                .serializeValuesWith(RedisSerializationContext.SerializationPair.fromSerializer(jacksonSerializer))
                .disableCachingNullValues(); // 不缓存空值

        return RedisCacheManager.builder(redisConnectionFactory)
                .cacheDefaults(config)
                .build();
    }
}