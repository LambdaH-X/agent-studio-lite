package com.agentworkflow.entity;

import lombok.Data;
import java.util.Date;

@Data
public class ChatSession {
    private Long id;
    private Long userId;
    private String title;
    private Integer status;
    private Date createdAt;
    private Date updatedAt;
    private Integer isDeleted;
}