package com.agentworkflow.entity;

import java.io.Serializable;
import java.util.Date;

import lombok.Data;

@Data
public class Agent implements Serializable {

    private static final long serialVersionUID = 1L;
    
    private Long id;
    private String name;
    private String description;
    private String type;  // 改为与数据库表匹配的字段名
    private Integer status;
    private Long createdBy;  // 添加创建者ID字段
    private Date createdAt;
    private Date updatedAt;
    private Integer isDeleted;
    
    // 为了兼容前端，添加getter/setter方法
    public String getAgentType() {
        return type;
    }
    
    public void setAgentType(String agentType) {
        this.type = agentType;
    }
    
    // 由于数据库中没有systemPrompt字段，这些方法仅用于兼容前端
    public String getSystemPrompt() {
        return null;  // 返回null，因为数据库中没有此字段
    }
    
    public void setSystemPrompt(String systemPrompt) {
        // 不做任何操作，因为数据库中没有此字段
    }
}