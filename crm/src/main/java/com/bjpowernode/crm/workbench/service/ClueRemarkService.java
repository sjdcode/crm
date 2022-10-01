package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.workbench.domain.ClueRemark;

import java.util.List;

public interface ClueRemarkService {

    /**
     * 根据ClueId查询ClueRemark
     */
    List<ClueRemark> queryClueRemarkByClueId(String clueId);

    /**
     * 爆粗ClueRemark
     */
    int saveClueRemark(ClueRemark clueRemark);

    /**
     * 根据Id删除ClueRemark
     */
    int deleteClueRemark(String id);

    /**
     * 更新ClueRemark
     */
    int saveEditClueRemark(ClueRemark clueRemark);
}
