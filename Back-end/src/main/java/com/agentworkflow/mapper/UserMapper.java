package com.agentworkflow.mapper;

import com.agentworkflow.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 用户数据访问接口
 * 使用MyBatis进行数据库操作
 */
@Mapper
public interface UserMapper {
    
    /**
     * 查询所有用户
     * @return 用户列表
     */
    List<User> findAll();
    
    /**
     * 根据ID查询用户
     * @param id 用户ID
     * @return 用户对象
     */
    User findById(Long id);
    
    /**
     * 根据用户名查询用户
     * @param username 用户名
     * @return 用户对象
     */
    User findByUsername(String username);
    
    /**
     * 检查用户名是否存在
     * @param username 用户名
     * @return 是否存在
     */
    boolean existsByUsername(String username);
    
    /**
     * 更新用户最后登录时间
     * @param id 用户ID
     */
    void updateLastLoginTime(Long id);
    
    /**
     * 插入新用户
     * @param user 用户对象
     * @return 影响的行数
     */
    int insertUser(User user);
    
    /**
     * 更新用户资料
     * @param user 用户对象
     * @return 影响的行数
     */
    int updateUser(User user);
    
    /**
     * 修改密码
     * @param id 用户ID
     * @param password 新密码
     * @return 影响的行数
     */
    int updatePassword(@Param("id") Long id, @Param("password") String password);
}