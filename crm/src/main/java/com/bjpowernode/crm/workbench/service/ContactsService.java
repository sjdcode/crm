package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.workbench.domain.Contacts;

import java.util.List;
import java.util.Map;

public interface ContactsService {

    List<Contacts> queryContactsForDetailByDimName(String dimName);

    List<Contacts> queryContactsForDetailByCustomerId(String customerId);

    Contacts saveCreateContacts(Map<String,Object> map);

    int deleteContactsById(String id);
}
