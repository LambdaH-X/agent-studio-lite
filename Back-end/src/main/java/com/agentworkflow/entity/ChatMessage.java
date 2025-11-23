package com.agentworkflow.entity;

import lombok.Data;
import java.util.Date;

@Data
public class ChatMessage {
    private Long id;
    private Long sessionId;
    private Integer senderType;
    private String content;
    private String contentType;
    private Date createdAt;
    private Integer isDeleted;
}