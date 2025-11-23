package com.agentworkflow.controller;

import com.agentworkflow.utils.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.HashMap;
import java.util.Map;
// 以下导入在未来扩展健康检查功能时可能用到
// import java.sql.Connection;
// import java.sql.DatabaseMetaData;
// import java.util.Properties;

@RestController
@RequestMapping("/health")
public class HealthController {

    @Autowired
    private Environment environment;

    // 数据源 - 未来如需数据库健康检查可能会用到
    // @Autowired
    // private DataSource dataSource;

    // JDBC模板 - 未来如需数据库查询健康检查可能会用到
    // @Autowired
    // private JdbcTemplate jdbcTemplate;

    /**
     * 基础健康检查接口
     */
    @GetMapping("/status")
    public ApiResponse status() {
        Map<String, Object> statusInfo = new HashMap<>();
        statusInfo.put("status", "UP");
        statusInfo.put("service", "Agent Workflow Backend");
        statusInfo.put("version", "1.0.0");
        
        return ApiResponse.success(statusInfo);
    }

    /**
     * 简单问候接口
     */
    @GetMapping("/hello")
    public ApiResponse hello() {
        return ApiResponse.success("Hello from Agent Workflow Backend!");
    }

    /**
     * 获取应用信息
     */
    @GetMapping("/info")
    public ApiResponse info() {
        Map<String, Object> info = new HashMap<>();
        info.put("appName", "Agent Workflow Backend");
        info.put("javaVersion", System.getProperty("java.version"));
        info.put("springBootVersion", environment.getProperty("spring.boot.version", "unknown"));
        info.put("activeProfile", environment.getProperty("spring.profiles.active", "unknown"));
        
        return ApiResponse.success(info);
    }
}