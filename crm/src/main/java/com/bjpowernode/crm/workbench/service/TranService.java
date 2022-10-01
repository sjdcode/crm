package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface TranService {

    List<Tran> queryTranByConditionForPage(Map<String,Object> map);

    int queryCountForTranByCondition(Map<String,Object> map);

    void saveCreateTran(Tran tran, User user);

    List<Tran> queryTranForDetailByCustomerId(String customerId);

    int deleteTranById(String id);
}
