package com.agentworkflow;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.agentworkflow.mapper")
public class AgentWorkflowApplication {

    public static void main(String[] args) {
        SpringApplication.run(AgentWorkflowApplication.class, args);
    }

}