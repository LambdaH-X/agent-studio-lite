package com.agentworkflow.entity;

import lombok.Data;
import java.util.Date;

@Data
public class AgentKnowledge {
    private Long id;
    private Long agentId;
    private Long knowledgeBaseId;
    private Date createdAt;
}