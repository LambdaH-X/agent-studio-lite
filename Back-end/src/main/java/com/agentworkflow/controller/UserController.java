package com.agentworkflow.controller;

import com.agentworkflow.entity.User;
import com.agentworkflow.entity.Admin;
import com.agentworkflow.mapper.UserMapper;
import com.agentworkflow.mapper.AdminMapper;
import com.agentworkflow.utils.ApiResponse;
import com.agentworkflow.utils.JwtService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 用户相关接口控制器
 */
@RestController
@RequestMapping("/api/user")
public class UserController {

    private static final Logger logger = LoggerFactory.getLogger(UserController.class);

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private AdminMapper adminMapper;

    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * 用户登录接口
     * @param loginRequest 登录请求参数
     * @return 登录结果，包含JWT令牌
     */
    @PostMapping("/login")
    public ApiResponse login(@RequestBody LoginRequest loginRequest) {
        logger.info("用户登录请求: 用户名 = {}", loginRequest.getUsername());
        
        try {
            // 认证用户
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginRequest.getUsername(),
                            loginRequest.getPassword()
                    )
            );
            
            SecurityContextHolder.getContext().setAuthentication(authentication);
            
            // 生成JWT令牌
            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            
            // 获取用户ID和角色信息
            Long userId = null;
            String role = null;
            
            // 先查询普通用户
            User user = userMapper.findByUsername(loginRequest.getUsername());
            if (user != null) {
                userId = user.getId();
                role = "user"; // 明确标识为普通用户
            } else {
                // 查询管理员
                Admin admin = adminMapper.findByUsername(loginRequest.getUsername());
                if (admin != null) {
                    // 管理员使用特殊ID标识
                    userId = -admin.getId();
                    role = "admin"; // 明确标识为管理员
                }
            }
            
            // 使用带用户ID的方法生成JWT令牌
            String jwtToken = jwtService.generateToken(userDetails, userId);
            
            // 更新最后登录时间
            updateLastLoginTime(loginRequest.getUsername());
            
            Map<String, Object> data = new HashMap<>();
            data.put("token", jwtToken);
            data.put("username", userDetails.getUsername());
            data.put("authorities", userDetails.getAuthorities());
            data.put("role", role); // 添加明确的角色信息
            
            return ApiResponse.success(data);
        } catch (Exception e) {
            logger.error("登录失败: {}", e.getMessage());
            return ApiResponse.fail(401, "用户名或密码错误");
        }
    }

    /**
     * 用户注册接口
     * @param registerRequest 注册请求参数
     * @return 注册结果
     */
    @PostMapping("/register")
    public ApiResponse register(@RequestBody RegisterRequest registerRequest) {
        logger.info("用户注册请求: 用户名 = {}", registerRequest.getUsername());
        
        // 检查用户名是否已存在
        if (userMapper.existsByUsername(registerRequest.getUsername())) {
            return ApiResponse.fail(400, "用户名已存在");
        }
        
        // 创建新用户
        User user = new User();
        user.setUsername(registerRequest.getUsername());
        user.setPassword(passwordEncoder.encode(registerRequest.getPassword()));
        user.setEmail(registerRequest.getEmail());
        user.setPhone(registerRequest.getPhone());
        user.setNickname(registerRequest.getNickname());
        user.setStatus(1); // 默认为启用状态
        user.setCreatedAt(new Date());
        user.setUpdatedAt(new Date());
        user.setLastLoginAt(null);
        user.setIsDeleted(0);
        
        // 插入用户数据
        int result = userMapper.insertUser(user);
        if (result > 0) {
            return ApiResponse.success("注册成功");
        } else {
            return ApiResponse.fail(500, "注册失败，请重试");
        }
    }

    /**
     * 获取当前用户信息
     * @return 用户信息（包括普通用户和管理员）
     */
    @GetMapping("/info")
    public ApiResponse getUserInfo() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        logger.info("获取用户信息: 用户名 = {}", username);
        
        // 构建统一的用户信息响应对象
        Map<String, Object> userInfo = new HashMap<>();
        
        // 先查询普通用户
        User user = userMapper.findByUsername(username);
        if (user != null) {
            // 移除敏感信息
            user.setPassword(null);
            
            // 构建统一格式的响应
            userInfo.put("id", user.getId());
            userInfo.put("username", user.getUsername());
            userInfo.put("nickname", user.getNickname());
            userInfo.put("avatar", user.getAvatar());
            userInfo.put("email", user.getEmail());
            userInfo.put("phone", user.getPhone());
            userInfo.put("gender", user.getGender());
            userInfo.put("birthdate", user.getBirthdate());
            userInfo.put("role", "user"); // 明确标识角色为用户
            
            return ApiResponse.success(userInfo);
        }
        
        // 如果不是普通用户，查询管理员
        Admin admin = adminMapper.findByUsername(username);
        if (admin != null) {
            // 移除敏感信息
            admin.setPassword(null);
            
            // 构建统一格式的响应
            userInfo.put("id", admin.getId());
            userInfo.put("username", admin.getUsername());
            userInfo.put("nickname", admin.getNickname());
            userInfo.put("avatar", admin.getAvatar());
            userInfo.put("email", admin.getEmail());
            userInfo.put("phone", admin.getPhone());
            userInfo.put("role", "admin"); // 明确标识角色为管理员
            // 管理员没有gender和birthdate字段，设置为null
            userInfo.put("gender", null);
            userInfo.put("birthdate", null);
            
            return ApiResponse.success(userInfo);
        }
        
        return ApiResponse.fail(404, "用户不存在");
    }

    /**
     * 获取所有用户信息（需要管理员权限）
     * @return 用户列表
     */
    @GetMapping("/all")
    public ApiResponse getAllUsers() {
        List<User> users = userMapper.findAll();
        
        // 移除敏感信息
        users.forEach(user -> user.setPassword(null));
        
        return ApiResponse.success(users);
    }

    /**
     * 更新用户最后登录时间
     */
    private void updateLastLoginTime(String username) {
        // 暂时注释掉更新登录时间的逻辑，避免编译错误
    }

    // 内部类：登录请求参数
    static class LoginRequest {
        private String username;
        private String password;
        
        // getter和setter
        public String getUsername() {
            return username;
        }
        public void setUsername(String username) {
            this.username = username;
        }
        public String getPassword() {
            return password;
        }
        public void setPassword(String password) {
            this.password = password;
        }
    }

    // 内部类：注册请求参数
    static class RegisterRequest {
        private String username;
        private String password;
        private String email;
        private String phone;
        private String nickname;
        
        // getter和setter
        public String getUsername() {
            return username;
        }
        public void setUsername(String username) {
            this.username = username;
        }
        public String getPassword() {
            return password;
        }
        public void setPassword(String password) {
            this.password = password;
        }
        public String getEmail() {
            return email;
        }
        public void setEmail(String email) {
            this.email = email;
        }
        public String getPhone() {
            return phone;
        }
        public void setPhone(String phone) {
            this.phone = phone;
        }
        public String getNickname() {
            return nickname;
        }
        public void setNickname(String nickname) {
            this.nickname = nickname;
        }
    }
}
