package com.agentworkflow.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;

import java.io.Serializable;
import java.util.Date;

import lombok.Data;

@Data
public class User implements Serializable {

    private static final long serialVersionUID = 1L;
    
    private Long id;
    private String username;
    @JsonIgnore
    private String password;
    private String email;
    private String phone;
    private String nickname;
    private String avatar;
    private Integer gender;
    private Date birthdate;
    private Integer status;
    private Date createdAt;
    private Date updatedAt;
    private Date lastLoginAt;
    private Integer isDeleted;
    private Long roleId;
}