package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.constant.Constant;
import com.bjpowernode.crm.commons.domain.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtil;
import com.bjpowernode.crm.commons.utils.UUIDUtil;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.workbench.domain.Contacts;
import com.bjpowernode.crm.workbench.service.ContactsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpSession;
import java.util.Date;
import java.util.Map;

@Controller
public class ContactsController {
    @Autowired
    private ContactsService contactsService;

    @RequestMapping("/workbench/contacts/toIndex.do")
    public String toContacts(){
        return "/workbench/contacts/index";
    }

    @RequestMapping("/workbench/contacts/saveCreateContacts.do")
    @ResponseBody
    public Object saveCreateContacts(@RequestParam Map<String,Object> map, HttpSession session){
        User user=(User) session.getAttribute(Constant.Login_User_Msg);
        map.put(Constant.Login_User_Msg,user);
        //返回响应数据
        ReturnObject returnObject = new ReturnObject();
        try {
            Contacts contacts = contactsService.saveCreateContacts(map);
            returnObject.setCode(Constant.Operation_Success);
            returnObject.setRetData(contacts);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("系统忙,请稍后联系管理员");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/contacts/deleteContactsById.do")
    @ResponseBody
    public Object deleteContactsById(@RequestParam("id") String contactsId){
        ReturnObject returnObject = new ReturnObject();
        try {
            int deleteNum = contactsService.deleteContactsById(contactsId);
            if(deleteNum>0){
                returnObject.setCode(Constant.Operation_Success);
            }else{
                returnObject.setCode(Constant.Operation_Fail);
                returnObject.setMessage("系统忙,请稍后联系管理员...");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("系统忙,请稍后联系管理员...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/contacts/toDetail.do")
    public String toDetail(@RequestParam("id") String contactsId){
        return "/workbench/contacts/detail";
    }
}
