package com.agentworkflow.mapper;

import com.agentworkflow.entity.Admin;
import org.apache.ibatis.annotations.Mapper;

/**
 * 管理员数据访问接口
 * 使用MyBatis进行数据库操作
 */
@Mapper
public interface AdminMapper {
    
    /**
     * 根据用户名查询管理员
     * @param username 用户名
     * @return 管理员对象
     */
    Admin findByUsername(String username);
    
    /**
     * 更新管理员最后登录时间
     * @param id 管理员ID
     */
    void updateLastLoginTime(Long id);
}