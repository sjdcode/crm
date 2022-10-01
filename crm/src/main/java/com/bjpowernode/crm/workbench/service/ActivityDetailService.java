package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.ActivityRemark;

import java.util.List;

public interface ActivityDetailService {
    /**
     * 根据ActiivityId查询ActivityRemark
     */
    List<ActivityRemark> queryActivityForDetailByActivityId(String activityId);

    /**
     * 保存ActivityRemark
     */
    int saveCreateActivityRemark(ActivityRemark activityRemark);

    /**
     * 根据Id删除ActivityRemark
     */
    int deleteActivityRemarkById(String id);

    /**
     * 更新ActivityRemark
     */
    int updateActivityRemark(ActivityRemark activityRemark);

}
