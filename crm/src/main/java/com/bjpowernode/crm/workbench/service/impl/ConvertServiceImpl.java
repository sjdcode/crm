package com.bjpowernode.crm.workbench.service.impl;

import com.bjpowernode.crm.commons.constant.Constant;
import com.bjpowernode.crm.commons.utils.DateUtil;
import com.bjpowernode.crm.commons.utils.UUIDUtil;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.workbench.domain.*;
import com.bjpowernode.crm.workbench.mapper.*;
import com.bjpowernode.crm.workbench.service.ConvertService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

@Service("convertService")
public class ConvertServiceImpl implements ConvertService {

    @Autowired
    private ClueMapper clueMapper;
    @Autowired
    private CustomerMapper customerMapper;
    @Autowired
    private ContactsMapper contactsMapper;
    @Autowired
    private ClueRemarkMapper clueRemarkMapper;
    @Autowired
    private CustomerRemarkMapper customerRemarkMapper;
    @Autowired
    private ContactsRemarkMapper contactsRemarkMapper;
    @Autowired
    private ClueActivityRelationMapper clueActivityRelationMapper;
    @Autowired
    private ContactsActivityRelationMapper contactsActivityRelationMapper;
    @Autowired
    private TranMapper tranMapper;
    @Autowired
    private TranRemarkMapper tranRemarkMapper;

    @Override
    public void clueConvert(Map<String, Object> map) {
        User user=(User)map.get(Constant.Login_User_Msg);

        //查找clue信息
        Clue clue = clueMapper.selectClueById((String) map.get("clueId"));

        //添加Customer信息
        Customer cus = new Customer();
        cus.setId(UUIDUtil.getUUID());
        cus.setOwner(user.getId());
        cus.setName(clue.getCompany());
        cus.setWebsite(clue.getWebsite());
        cus.setPhone(clue.getPhone());
        cus.setCreateBy(user.getId());
        cus.setCreateTime(DateUtil.FormatDateTime(new Date()));
        cus.setContactSummary(clue.getContactSummary());
        cus.setNextContactTime(clue.getNextContactTime());
        cus.setDescription(clue.getDescription());
        cus.setAddress(clue.getAddress());
        customerMapper.insertCustomer(cus);

        //添加Contacts
        Contacts co = new Contacts();
        co.setId(UUIDUtil.getUUID());
        co.setOwner(user.getId());
        co.setSource(clue.getSource());
        co.setCustomerId(cus.getId());
        co.setFullname(clue.getFullname());
        co.setAppellation(clue.getAppellation());
        co.setEmail(clue.getEmail());
        co.setMphone(clue.getMphone());
        co.setJob(clue.getJob());
        co.setCreateBy(user.getId());
        co.setCreateTime(DateUtil.FormatDateTime(new Date()));
        co.setDescription(clue.getDescription());
        co.setContactSummary(clue.getContactSummary());
        co.setNextContactTime(clue.getNextContactTime());
        co.setAddress(clue.getAddress());
        contactsMapper.insertContacts(co);

        //查询Clue下所有备注
        List<ClueRemark> clueRemarkList = clueRemarkMapper.selectClueRemarkByClueId((String) map.get("clueId"));

        //Clue线索转换到Customer和Contacts下
        if(clueRemarkList!=null && clueRemarkList.size()>0){
            List<CustomerRemark> customerRemarkList = new ArrayList<>();
            List<ContactsRemark> contactsRemarkList = new ArrayList<>();
            CustomerRemark cur;
            ContactsRemark cos;
            for(ClueRemark cr: clueRemarkList){
                cur=new CustomerRemark();
                cur.setId(UUIDUtil.getUUID());
                cur.setNoteContent(cr.getNoteContent());
                cur.setCreateBy(cr.getCreateBy());
                cur.setCreateTime(cr.getCreateTime());
                cur.setEditBy(cr.getEditBy());
                cur.setEditTime(cr.getEditTime());
                cur.setEditFlag(cr.getEditFlag());
                cur.setCustomerId(cus.getId());
                customerRemarkList.add(cur);

                cos=new ContactsRemark();
                cos.setId(UUIDUtil.getUUID());
                cos.setNoteContent(cr.getNoteContent());
                cos.setCreateBy(cr.getCreateBy());
                cos.setCreateTime(cr.getCreateTime());
                cos.setEditBy(cr.getEditBy());
                cos.setEditTime(cr.getEditTime());
                cos.setEditFlag(cr.getEditFlag());
                cos.setContactsId(co.getId());
                contactsRemarkList.add(cos);
            }
            customerRemarkMapper.insertCustomerRemarkByList(customerRemarkList);
            contactsRemarkMapper.insertContactsRemarkByList(contactsRemarkList);
        }

        //查询Clue关联的Activity活动
        List<ClueActivityRelation> clueActivityRelationList = clueActivityRelationMapper.selectClueActivityRelationByClueId((String) map.get("clueId"));

        //线索和市场活动的关系转换为联系人和市场活动的关系
        if(clueActivityRelationList!=null&&clueActivityRelationList.size()>0){
            List<ContactsActivityRelation> carList = new ArrayList<>();
            ContactsActivityRelation contactsActivityRelation;
            for(ClueActivityRelation car:clueActivityRelationList){
                contactsActivityRelation=new ContactsActivityRelation();
                contactsActivityRelation.setActivityId(car.getActivityId());
                contactsActivityRelation.setContactsId(co.getId());
                contactsActivityRelation.setId(UUIDUtil.getUUID());
                carList.add(contactsActivityRelation);
            }
            contactsActivityRelationMapper.insertContactsActivityRelationByList(carList);
        }

        //是否创建交易,对象未赋值,使用mybatis添加,不会显示null,就是未赋值的状态
        //clueRemark转换到tranRemark
        if("true".equals(map.get("isCreateTran"))){
            Tran tran = new Tran();
            tran.setId(UUIDUtil.getUUID());
            tran.setOwner(user.getId());
            tran.setMoney((String) map.get("money"));
            tran.setName((String) map.get("name"));
            tran.setExpectedDate((String) map.get("expectedDate"));
            tran.setCustomerId(cus.getId());
            tran.setStage((String) map.get("stage"));
            tran.setActivityId((String) map.get("activityId"));
            tran.setContactsId(co.getId());
            tran.setCreateBy(user.getId());
            tran.setCreateTime(DateUtil.FormatDateTime(new Date()));
            tran.setDescription(clue.getDescription());
            tran.setContactSummary(clue.getContactSummary());
            tran.setNextContactTime(clue.getNextContactTime());
            tranMapper.insertTran(tran);

            if(clueRemarkList!=null&&clueRemarkList.size()>0){
                List<TranRemark> trms = new ArrayList<>();
                for(ClueRemark clueRemark:clueRemarkList){
                    TranRemark tr = new TranRemark();
                    tr.setId(UUIDUtil.getUUID());
                    tr.setNoteContent(clueRemark.getNoteContent());
                    tr.setCreateBy(clueRemark.getCreateBy());
                    tr.setCreateTime(clueRemark.getCreateTime());
                    tr.setEditBy(clueRemark.getEditBy());
                    tr.setEditBy(clueRemark.getEditBy());
                    tr.setEditFlag(clueRemark.getEditFlag());
                    tr.setTranId(tran.getId());
                    trms.add(tr);
                }
                tranRemarkMapper.insertTranRemarkByList(trms);
            }
        }

        //删除该clue下的所有clueRemark
        clueRemarkMapper.deleteAllClueRemarkByClueId(clue.getId());

        //删除该clue和activity的关联关系
        clueActivityRelationMapper.deleteAllClueRemarkRelationByClueId(clue.getId());

        //删除该clue
        clueMapper.deleteClueById(clue.getId());
    }
}
