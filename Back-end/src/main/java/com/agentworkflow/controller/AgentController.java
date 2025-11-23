package com.agentworkflow.controller;

import com.agentworkflow.entity.Agent;
import com.agentworkflow.entity.AgentKnowledge;
import com.agentworkflow.entity.AgentPlugin;
import com.agentworkflow.service.AgentService;
import com.agentworkflow.utils.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/agents")
public class AgentController {

    @Autowired
    private AgentService agentService;

    // 智能体管理
    @GetMapping
    public ApiResponse getAllAgents() {
        List<Agent> agents = agentService.getAllAgents();
        return ApiResponse.success(agents);
    }

    @GetMapping("/{id}")
    public ApiResponse getAgentById(@PathVariable Long id) {
        Agent agent = agentService.getAgentById(id);
        if (agent != null) {
            return ApiResponse.success(agent);
        } else {
            return ApiResponse.fail(404, "Agent not found");
        }
    }

    @PostMapping
    public ApiResponse createAgent(@RequestBody Agent agent) {
        // 确保字段映射正确 - 添加model到type的映射
        if (agent.getAgentType() == null && agent.getSystemPrompt() != null) {
            // 如果没有设置type但设置了systemPrompt，使用默认值
            agent.setAgentType("default");
        }
        Agent createdAgent = agentService.createAgent(agent);
        return ApiResponse.success(createdAgent);
    }

    @PutMapping("/{id}")
    public ApiResponse updateAgent(@PathVariable Long id, @RequestBody Agent agent) {
        agent.setId(id);
        // 确保更新逻辑正确
        Agent updatedAgent = agentService.updateAgent(agent);
        if (updatedAgent != null) {
            return ApiResponse.success(updatedAgent);
        } else {
            return ApiResponse.fail(404, "Agent not found");
        }
    }

    @DeleteMapping("/{id}")
    public ApiResponse deleteAgent(@PathVariable Long id) {
        boolean deleted = agentService.deleteAgent(id);
        if (deleted) {
            return ApiResponse.success(null);
        } else {
            return ApiResponse.fail(404, "Agent not found");
        }
    }

    // 智能体知识库管理
    @GetMapping("/{agentId}/knowledge")
    public ApiResponse getAgentKnowledge(@PathVariable Long agentId) {
        List<AgentKnowledge> knowledgeList = agentService.getAgentKnowledge(agentId);
        return ApiResponse.success(knowledgeList);
    }

    @PostMapping("/knowledge")
    public ApiResponse addAgentKnowledge(@RequestBody AgentKnowledge agentKnowledge) {
        AgentKnowledge created = agentService.addAgentKnowledge(agentKnowledge);
        return ApiResponse.success(created);
    }

    // 智能体插件管理
    @GetMapping("/plugins")
    public ApiResponse getAllPlugins() {
        List<AgentPlugin> plugins = agentService.getAllPlugins();
        return ApiResponse.success(plugins);
    }

    @PostMapping("/plugins")
    public ApiResponse createPlugin(@RequestBody AgentPlugin plugin) {
        AgentPlugin createdPlugin = agentService.createPlugin(plugin);
        return ApiResponse.success(createdPlugin);
    }
}