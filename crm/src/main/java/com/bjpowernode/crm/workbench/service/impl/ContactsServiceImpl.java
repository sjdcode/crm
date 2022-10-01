package com.bjpowernode.crm.workbench.service.impl;

import com.bjpowernode.crm.commons.constant.Constant;
import com.bjpowernode.crm.commons.utils.DateUtil;
import com.bjpowernode.crm.commons.utils.UUIDUtil;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.workbench.domain.Contacts;
import com.bjpowernode.crm.workbench.domain.Customer;
import com.bjpowernode.crm.workbench.mapper.ContactsMapper;
import com.bjpowernode.crm.workbench.mapper.CustomerMapper;
import com.bjpowernode.crm.workbench.service.ContactsService;
import com.bjpowernode.crm.workbench.service.CustomerService;
import org.apache.ibatis.annotations.Param;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Map;

@Service("contactsService")
public class ContactsServiceImpl implements ContactsService {
    @Autowired
    private ContactsMapper contactsMapper;
    @Autowired
    private CustomerMapper customerMapper;

    @Override
    public List<Contacts> queryContactsForDetailByDimName(String dimName) {
        return contactsMapper.selectContactsForDetailByDimName(dimName);
    }

    @Override
    public List<Contacts> queryContactsForDetailByCustomerId(String customerId) {
        return contactsMapper.selectContactsForDetailByCustomerId(customerId);
    }

    @Override
    public Contacts saveCreateContacts(Map<String,Object> map) {
        User user=(User)map.get(Constant.Login_User_Msg);
        //判断客户是否存在
        String customerId = customerMapper.selectCustomerIdByName((String) map.get("customerName"));
        if(customerId==null){
            Customer cus = new Customer();
            String createCustomerId = UUIDUtil.getUUID();
            cus.setId(createCustomerId);
            cus.setOwner(user.getId());
            cus.setName((String) map.get("customerName"));
            cus.setCreateBy(user.getId());
            cus.setCreateTime(DateUtil.FormatDateTime(new Date()));
            customerMapper.insertCustomer(cus);
            customerId=createCustomerId;
        }

        //封装参数
        Contacts cts = new Contacts();
        cts.setId(UUIDUtil.getUUID());
        cts.setOwner(user.getId());
        cts.setSource((String) map.get("source"));
        cts.setCustomerId(customerId);
        cts.setFullname((String) map.get("fullname"));
        cts.setAppellation((String) map.get("appellation"));
        cts.setEmail((String) map.get("email"));
        cts.setMphone((String) map.get("mphone"));
        cts.setJob((String) map.get("job"));
        cts.setCreateBy(user.getId());
        cts.setCreateTime(DateUtil.FormatDateTime(new Date()));
        cts.setDescription((String) map.get("description"));
        cts.setContactSummary((String) map.get("contactSummary"));
        cts.setNextContactTime((String) map.get("nextContactTime"));
        cts.setAddress((String) map.get("address"));
        contactsMapper.insertContacts(cts);

        //返回数据
        return cts;
    }

    @Override
    public int deleteContactsById(String id) {
        return contactsMapper.deleteContactsById(id);
    }
}
