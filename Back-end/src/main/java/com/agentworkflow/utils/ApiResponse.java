package com.agentworkflow.utils;

import lombok.Data;

@Data
public class ApiResponse {
    private Integer code;
    private String message;
    private Object data;

    public ApiResponse(Integer code, String message, Object data) {
        this.code = code;
        this.message = message;
        this.data = data;
    }

    public static ApiResponse success(Object data) {
        return new ApiResponse(200, "success", data);
    }

    public static ApiResponse fail(Integer code, String message) {
        return new ApiResponse(code, message, null);
    }
}