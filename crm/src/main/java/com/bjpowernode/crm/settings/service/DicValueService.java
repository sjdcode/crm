package com.bjpowernode.crm.settings.service;

import com.bjpowernode.crm.settings.domain.DicValue;

import java.util.List;

public interface DicValueService {

    /**
     * 根据typeValue查询DicValue
     */
    List<DicValue> queryDicValueByTypeValue(String typeCode);
}
