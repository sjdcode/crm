package com.bjpowernode.crm.workbench.service.impl;

import com.bjpowernode.crm.commons.utils.DateUtil;
import com.bjpowernode.crm.commons.utils.UUIDUtil;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.workbench.domain.Customer;
import com.bjpowernode.crm.workbench.domain.Tran;
import com.bjpowernode.crm.workbench.mapper.CustomerMapper;
import com.bjpowernode.crm.workbench.mapper.TranMapper;
import com.bjpowernode.crm.workbench.service.TranService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service("tranService")
public class TranServiceImpl implements TranService {
    @Autowired
    private TranMapper tranMapper;
    @Autowired
    private CustomerMapper customerMapper;

    @Override
    public List<Tran> queryTranByConditionForPage(Map<String, Object> map) {
        return tranMapper.selectTranByConditionForPage(map);
    }

    @Override
    public int queryCountForTranByCondition(Map<String, Object> map) {
        return tranMapper.selectCountForTranByCondition(map);
    }

    @Override
    public void saveCreateTran(Tran tran, User user) {
        //Tran中的customer名称是实际字段,需要判断该customer是否存在,再存储customerId,
        //查询客户
        String customerId = customerMapper.selectCustomerIdByName(tran.getCustomerId());

        //用户存在
        //用户不存在,创建用户
        if(customerId!=null){
            tran.setCustomerId(customerId);
        }else{
            String customerUUID = UUIDUtil.getUUID();
            Customer cu = new Customer();
            cu.setId(customerUUID);
            cu.setOwner(user.getId());
            cu.setName(tran.getCustomerId());
            cu.setCreateBy(user.getId());
            cu.setCreateTime(DateUtil.FormatDateTime(new Date()));
            cu.setContactSummary(tran.getContactSummary());
            cu.setNextContactTime(tran.getNextContactTime());
            cu.setDescription(tran.getDescription());
            customerMapper.insertCustomer(cu);
            tran.setCustomerId(customerUUID);
        }
        //创建交易
        tranMapper.insertTran(tran);
    }

    @Override
    public List<Tran> queryTranForDetailByCustomerId(String customerId) {
        return tranMapper.selectTranForDetailByCustomerId(customerId);
    }

    @Override
    public int deleteTranById(String id) {
        return tranMapper.deleteTranById(id);
    }
}
