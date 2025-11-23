package com.agentworkflow.entity;

import lombok.Data;
import java.util.Date;
import java.util.Map;

@Data
public class AgentPlugin {
    private Long id;
    private String name;
    private String description;
    private String type;
    private Map<String, Object> configJson;
    private Integer status;
    private Date createdAt;
    private Date updatedAt;
}