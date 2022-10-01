package com.bjpowernode.crm.workbench.mapper;

import com.bjpowernode.crm.workbench.domain.ActivityRemark;

import java.util.List;

public interface ActivityRemarkMapper {
    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_activity_remark
     *
     * @mbggenerated Tue Aug 02 12:29:26 CST 2022
     */
    int deleteByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_activity_remark
     *
     * @mbggenerated Tue Aug 02 12:29:26 CST 2022
     */
    int insert(ActivityRemark record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_activity_remark
     *
     * @mbggenerated Tue Aug 02 12:29:26 CST 2022
     */
    int insertSelective(ActivityRemark record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_activity_remark
     *
     * @mbggenerated Tue Aug 02 12:29:26 CST 2022
     */
    ActivityRemark selectByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_activity_remark
     *
     * @mbggenerated Tue Aug 02 12:29:26 CST 2022
     */
    int updateByPrimaryKeySelective(ActivityRemark record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_activity_remark
     *
     * @mbggenerated Tue Aug 02 12:29:26 CST 2022
     */
    int updateByPrimaryKey(ActivityRemark record);

    /**
     * 根据ActivityId查询具体内容Activity_Remark
     */
    List<ActivityRemark> selectActivityRemarkForDetailByActivityId(String activityId);

    /**
     * 根据ActivityRemark保存数据
     */
    int insetActivityRemark(ActivityRemark activityRemark);

    /**
     * 根据id删除ActivityRemark
     */
    int deleteActivityRemarkById(String id);

    /**
     * 更新ActivityRemark
     */
    int updateActivityRemark(ActivityRemark activityRemark);
}