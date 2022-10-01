package com.bjpowernode.crm.commons.domain;

import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;

public class ReturnObject {
    private String code;//处理成功或者失败的标记,1--成功,0--失败
    private String message;//提示信息
    private Object retData;//其他数据

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Object getRetData() {
        return retData;
    }

    public void setRetData(Object retData) {
        this.retData = retData;
    }
}
