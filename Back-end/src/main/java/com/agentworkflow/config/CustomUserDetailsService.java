package com.agentworkflow.config;

import com.agentworkflow.entity.User;
import com.agentworkflow.entity.Admin;
import com.agentworkflow.mapper.UserMapper;
import com.agentworkflow.mapper.AdminMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;

/**
 * 自定义UserDetailsService实现
 * 用于Spring Security身份验证，通过数据库表判断用户角色
 */
@Service
public class CustomUserDetailsService implements UserDetailsService {

    private static final Logger logger = LoggerFactory.getLogger(CustomUserDetailsService.class);

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private AdminMapper adminMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        logger.info("加载用户信息: 用户名 = {}", username);
        
        // 先查询用户表
        User user = userMapper.findByUsername(username);
        logger.info("查询普通用户结果: {}", user != null ? "找到" : "未找到");
        
        // 如果是普通用户
        if (user != null) {
            // 为用户设置角色权限
            List<SimpleGrantedAuthority> authorities = Collections.singletonList(
                    new SimpleGrantedAuthority("ROLE_USER")
            );
            
            // 构建并返回UserDetails对象
            return new org.springframework.security.core.userdetails.User(
                    user.getUsername(),
                    user.getPassword(),
                    authorities
            );
        } else {
            // 查询管理员表
            Admin admin = adminMapper.findByUsername(username);
            logger.info("查询管理员结果: {}", admin != null ? "找到" : "未找到");
            
            // 如果管理员也不存在，抛出异常
            if (admin == null) {
                logger.error("用户不存在: {}", username);
                throw new UsernameNotFoundException("用户不存在: " + username);
            }
            
            // 为管理员设置角色权限
            List<SimpleGrantedAuthority> authorities = Collections.singletonList(
                    new SimpleGrantedAuthority("ROLE_ADMIN")
            );
            
            // 构建并返回UserDetails对象
            return new org.springframework.security.core.userdetails.User(
                    admin.getUsername(),
                    admin.getPassword(),
                    authorities
            );
        }
    }
}