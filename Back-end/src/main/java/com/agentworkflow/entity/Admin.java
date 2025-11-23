package com.agentworkflow.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;

import java.io.Serializable;
import java.util.Date;

import lombok.Data;

@Data
public class Admin implements Serializable {

    private static final long serialVersionUID = 1L;
    
    private Long id;
    private String username;
    @JsonIgnore
    private String password;
    private String nickname;
    private String email;
    private String phone;
    private String avatar;
    private Long roleId;
    private Integer status;
    private Date lastLoginTime;
    private Date createdAt;
    private Date updatedAt;
    private Integer isDeleted;
}