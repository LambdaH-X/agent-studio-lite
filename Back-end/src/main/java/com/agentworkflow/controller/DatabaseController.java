package com.agentworkflow.controller;

import com.agentworkflow.utils.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/database")
public class DatabaseController {

    @Autowired
    private DataSource dataSource;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private Environment environment;

    /**
     * 检查数据库连接状态
     */
    @GetMapping("/check")
    public ApiResponse checkConnection() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 尝试获取数据库连接
            try (Connection connection = dataSource.getConnection()) {
                result.put("connected", true);
                
                // 获取数据库元数据
                DatabaseMetaData metaData = connection.getMetaData();
                result.put("databaseProductName", metaData.getDatabaseProductName());
                result.put("databaseProductVersion", metaData.getDatabaseProductVersion());
                result.put("driverName", metaData.getDriverName());
                result.put("driverVersion", metaData.getDriverVersion());
                result.put("url", metaData.getURL());
                result.put("username", metaData.getUserName());
            }
            
            // 尝试执行简单查询，测试数据库读写能力
            try {
                String testQuery = "SELECT COUNT(*) FROM user";
                Integer userCount = jdbcTemplate.queryForObject(testQuery, Integer.class);
                result.put("userCount", userCount);
                result.put("querySuccess", true);
            } catch (Exception e) {
                result.put("querySuccess", false);
                result.put("queryError", e.getMessage());
            }
            
            return ApiResponse.success(result);
        } catch (Exception e) {
            result.put("connected", false);
            result.put("error", e.getMessage());
            return ApiResponse.fail(500, "数据库连接失败: " + e.getMessage());
        }
    }

    /**
     * 获取数据库配置信息
     */
    @GetMapping("/config")
    public ApiResponse getDatabaseConfig() {
        Map<String, Object> config = new HashMap<>();
        
        // 获取数据库配置
        config.put("url", environment.getProperty("spring.datasource.url"));
        config.put("username", environment.getProperty("spring.datasource.username"));
        config.put("driver", environment.getProperty("spring.datasource.driver-class-name"));
        config.put("maxPoolSize", environment.getProperty("spring.datasource.hikari.maximum-pool-size"));
        config.put("minIdle", environment.getProperty("spring.datasource.hikari.minimum-idle"));
        config.put("connectionTimeout", environment.getProperty("spring.datasource.hikari.connection-timeout"));
        
        return ApiResponse.success(config);
    }
}