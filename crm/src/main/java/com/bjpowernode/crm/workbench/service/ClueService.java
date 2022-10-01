package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.workbench.domain.Clue;

import java.util.List;
import java.util.Map;

public interface ClueService {

    /**
     * 通过分页和条件查询Clue
     */
    List<Clue> queryClueByConditionForPage(Map<String,Object> map);

    /**
     * 通过条件查询Clue总记录数
     */
    int queryCountOfClueByCondition(Map<String,Object> map);

    /**
     * 保存Clue
     */
    int saveClue(Clue clue);

    /**
     * 根据id传销Clue
     */
    Clue queryClueById(String id);

    /**
     * 修改Clue
     */
    int saveEditClue(Clue clue);

    /**
     * 根据ids删除Clue
     */
    int deleteClueByIds(String[] ids);

    /**
     * 通过id查询Clue全部细节信息
     */
    Clue queryClueForDetailById(String id);
}
