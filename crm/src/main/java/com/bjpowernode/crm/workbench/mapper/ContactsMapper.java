package com.bjpowernode.crm.workbench.mapper;

import com.bjpowernode.crm.commons.constant.Constant;
import com.bjpowernode.crm.workbench.domain.Contacts;
import com.bjpowernode.crm.workbench.domain.Customer;

import java.util.List;

public interface ContactsMapper {
    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_contacts
     *
     * @mbggenerated Wed Aug 10 10:29:08 CST 2022
     */
    int deleteByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_contacts
     *
     * @mbggenerated Wed Aug 10 10:29:08 CST 2022
     */
    int insert(Contacts record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_contacts
     *
     * @mbggenerated Wed Aug 10 10:29:08 CST 2022
     */
    int insertSelective(Contacts record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_contacts
     *
     * @mbggenerated Wed Aug 10 10:29:08 CST 2022
     */
    Contacts selectByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_contacts
     *
     * @mbggenerated Wed Aug 10 10:29:08 CST 2022
     */
    int updateByPrimaryKeySelective(Contacts record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_contacts
     *
     * @mbggenerated Wed Aug 10 10:29:08 CST 2022
     */
    int updateByPrimaryKey(Contacts record);

    /**
     * 添加Contacts
     */
    int insertContacts(Contacts contacts);

    /**
     * 根据ContactsName模糊查询ContactsList
     */
    List<Contacts> selectContactsForDetailByDimName(String dimName);

    /**
     * 根据customerId查询Contacts的明细信息
     * @param customerId
     * @return
     */
    List<Contacts> selectContactsForDetailByCustomerId(String customerId);

    /**
     * 根据Id删除contacts
     */
    int deleteContactsById(String id);
}