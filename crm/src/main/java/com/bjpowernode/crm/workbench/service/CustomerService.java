package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.workbench.domain.Customer;

import java.util.List;
import java.util.Map;

public interface CustomerService {

    String[] queryCustomerNameByDimName(String dimName);

    List<Customer> queryCustomerForPageByCondition(Map<String,Object> map);

    int queryCountForCustomerByConditon(Map<String,Object> map);

    int saveCreateCustomer(Customer customer);

    Customer queryCustomerForDetailById(String id);

    int editCustomer(Customer customer);

    int deleteCustomerByIds(String[] ids);

}
