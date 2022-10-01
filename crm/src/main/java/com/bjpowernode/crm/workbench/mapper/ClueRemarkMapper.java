package com.bjpowernode.crm.workbench.mapper;

import com.bjpowernode.crm.workbench.domain.ClueRemark;

import java.util.List;

public interface ClueRemarkMapper {
    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_remark
     *
     * @mbggenerated Fri Aug 05 10:52:29 CST 2022
     */
    int deleteByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_remark
     *
     * @mbggenerated Fri Aug 05 10:52:29 CST 2022
     */
    int insert(ClueRemark record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_remark
     *
     * @mbggenerated Fri Aug 05 10:52:29 CST 2022
     */
    int insertSelective(ClueRemark record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_remark
     *
     * @mbggenerated Fri Aug 05 10:52:29 CST 2022
     */
    ClueRemark selectByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_remark
     *
     * @mbggenerated Fri Aug 05 10:52:29 CST 2022
     */
    int updateByPrimaryKeySelective(ClueRemark record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_remark
     *
     * @mbggenerated Fri Aug 05 10:52:29 CST 2022
     */
    int updateByPrimaryKey(ClueRemark record);

    /**
     * 根据ClueId查询ClueRemark
     */
    List<ClueRemark> selectClueRemarkForDetailByClueId(String clueId);

    /**
     * 保存ClueRemark
     */
    int insertClueRemark(ClueRemark clueRemark);

    /**
     * 根据Id删除ClueRemark
     */
    int deleteClueRemarkById(String id);

    /**
     * 修改ClueRemark
     */
    int updateClueRemark(ClueRemark clueRemark);

    /**
     * 根据clueId查询ClueRemark
     */
    List<ClueRemark> selectClueRemarkByClueId(String clueId);

    /**
     * 根据clueId删除所有clueRemark
     */
    int deleteAllClueRemarkByClueId(String clueId);

}