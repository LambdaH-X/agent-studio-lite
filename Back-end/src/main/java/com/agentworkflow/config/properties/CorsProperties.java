package com.agentworkflow.config.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * CORS配置属性类
 * 用于将application.yml中的cors配置映射到Java对象
 */
@Data
@Component
@ConfigurationProperties(prefix = "cors")
public class CorsProperties {
    
    /**
     * 允许的源
     */
    private String allowedOrigins;
    
    /**
     * 允许的HTTP方法
     */
    private String allowedMethods;
    
    /**
     * 允许的请求头
     */
    private String allowedHeaders;
}