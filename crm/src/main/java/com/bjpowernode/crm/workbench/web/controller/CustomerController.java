package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.constant.Constant;
import com.bjpowernode.crm.commons.domain.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtil;
import com.bjpowernode.crm.commons.utils.UUIDUtil;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.DicValueService;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.workbench.domain.Customer;
import com.bjpowernode.crm.workbench.domain.CustomerRemark;
import com.bjpowernode.crm.workbench.domain.Tran;
import com.bjpowernode.crm.workbench.service.ContactsService;
import com.bjpowernode.crm.workbench.service.CustomerRemarkService;
import com.bjpowernode.crm.workbench.service.CustomerService;
import com.bjpowernode.crm.workbench.service.TranService;
import org.apache.ibatis.annotations.Param;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpSession;
import java.util.*;

@Controller
public class CustomerController {
    @Autowired
    private CustomerService customerService;
    @Autowired
    private UserService userService;
    @Autowired
    private CustomerRemarkService customerRemarkService;
    @Autowired
    private TranService tranService;
    @Autowired
    private ContactsService contactsService;
    @Autowired
    private DicValueService dicValueService;

    @RequestMapping("/workbench/customer/toIndex.do")
    public String toCustomer(Model model){
        //所有者下拉菜单数据保存到作用域中
        model.addAttribute("userList",userService.queryAllUsers());
        return "/workbench/customer/index";
    }

    @RequestMapping("/workbench/customer/queryCustomerForPageByConditon.do")
    @ResponseBody
    public Object queryCustomerForPageByConditon(@RequestParam Map<String,Object> map,int pageNo,int pageSize){
        //limit在mybatis中的使用必须让beginNo和pageSize是int类型
        map.put("beginNo",(pageNo-1)*pageSize);
        map.put("pageSize",pageSize);
        //返回响应数据
        HashMap<String, Object> returnMap = new HashMap<>();
        returnMap.put("customerList",customerService.queryCustomerForPageByCondition(map));
        returnMap.put("totalRows",customerService.queryCountForCustomerByConditon(map));
        return returnMap;
    }

    @RequestMapping("/workbench/customer/saveCreateCustomer.do")
    @ResponseBody
    public Object saveCreateCustomer(Customer customer, HttpSession session){
        User user=(User)session.getAttribute(Constant.Login_User_Msg);
        //设置后端参数
        customer.setId(UUIDUtil.getUUID());
        customer.setCreateBy(user.getId());
        customer.setCreateTime(DateUtil.FormatDateTime(new Date()));
        //返回响应数据
        ReturnObject returnObject = new ReturnObject();
        try {
            int saveNum = customerService.saveCreateCustomer(customer);
            if(saveNum>0){
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

    @RequestMapping("/workbench/customer/queryCustomerForDetailById.do")
    @ResponseBody
    public Object queryCustomerForDetailById(String id){
        return customerService.queryCustomerForDetailById(id);
    }

    @RequestMapping("/workbench/customer/editCustomer.do")
    @ResponseBody
    public Object editCustomer(Customer customer,HttpSession session){
        User user=(User)session.getAttribute(Constant.Login_User_Msg);
        //生成后端参数
        customer.setEditBy(user.getId());
        customer.setEditTime(DateUtil.FormatDateTime(new Date()));
        //返回响应数据
        ReturnObject returnObject = new ReturnObject();
        try {
            int editNum = customerService.editCustomer(customer);
            if(editNum>0){
                returnObject.setCode(Constant.Operation_Success);
                returnObject.setMessage("修改成功");
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

    @RequestMapping("/workbench/customer/deleteCustomerByIds.do")
    @ResponseBody
    public Object delectCustomerByIds(@RequestParam("id") String[] ids){
        ReturnObject returnObject = new ReturnObject();
        try {
            int deleteNum = customerService.deleteCustomerByIds(ids);
            if(deleteNum>0){
                returnObject.setCode(Constant.Operation_Success);
                returnObject.setMessage("删除成功");
            }else{
                returnObject.setCode(Constant.Operation_Fail);
                returnObject.setMessage("系统忙,请稍后重试...");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("系统忙,请稍后重试...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/customer/toDetail.do")
    public String toDetail(@RequestParam("id") String customerId, Model model){
        ResourceBundle readPossibility = ResourceBundle.getBundle("possibility");
        List<Tran> trans = tranService.queryTranForDetailByCustomerId(customerId);
        String possibility;
        for(Tran tran:trans){
             possibility = readPossibility.getString(tran.getStage());
             tran.setPossibility(possibility);
        }
        //返回需要显示数据
        model.addAttribute("customerDetail",customerService.queryCustomerForDetailById(customerId));
        model.addAttribute("customerRemarkList",customerRemarkService.queryCustomerRemarkForDetailByCustomerId(customerId));
        model.addAttribute("tranList",trans);
        model.addAttribute("contactsList",contactsService.queryContactsForDetailByCustomerId(customerId));
        //添加Contacts的modal需要userList,sourceList,appellationList
        model.addAttribute("userList",userService.queryAllUsers());
        model.addAttribute("sourceList",dicValueService.queryDicValueByTypeValue("source"));
        model.addAttribute("appellationList",dicValueService.queryDicValueByTypeValue("appellation"));
        return "/workbench/customer/detail";
    }

    @RequestMapping("/workbench/customer/saveCreateCustomerRemark.do")
    @ResponseBody
    public Object saveCreateCustomerRemark(CustomerRemark customerRemark,HttpSession session){
        //生成后端参数
        User user=(User) session.getAttribute(Constant.Login_User_Msg);
        customerRemark.setId(UUIDUtil.getUUID());
        customerRemark.setCreateTime(DateUtil.FormatDateTime(new Date()));
        customerRemark.setCreateBy(user.getId());
        customerRemark.setEditFlag(Constant.Edit_No);
        //返回数据
        ReturnObject returnObject = new ReturnObject();
        try {
            int saveNum = customerRemarkService.saveCreateCustomerRemark(customerRemark);
            if(saveNum>0){
                returnObject.setCode(Constant.Operation_Success);
                //返回保存的CustomerRemark对象
                returnObject.setRetData(customerRemark);
            }else{
                returnObject.setCode(Constant.Operation_Fail);
                returnObject.setMessage("备注失败,请稍后联系管理员...");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("备注失败,请稍后联系管理员...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/customer/deleteCustomerRemark.do")
    @ResponseBody
    public Object deleteCustomerRemark(@RequestParam("id") String customerRemarkId){
        ReturnObject returnObject = new ReturnObject();
        try {
            int deleteNum = customerRemarkService.deleteCustomerRemarkById(customerRemarkId);
            if(deleteNum>0){
                returnObject.setCode(Constant.Operation_Success);
            }else{
                returnObject.setCode(Constant.Operation_Fail);
                returnObject.setMessage("系统忙,请稍后重试");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("系统忙,请稍后重试");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/customer/editCustomerRemark.do")
    @ResponseBody
    public Object editCustomerRemark(@RequestParam("id") String customerRemarkId,String noteContent,HttpSession session){
        User user=(User)session.getAttribute(Constant.Login_User_Msg);
        //设置数据
        CustomerRemark cur = new CustomerRemark();
        cur.setId(customerRemarkId);
        cur.setNoteContent(noteContent);
        cur.setEditBy(user.getId());
        cur.setEditTime(DateUtil.FormatDateTime(new Date()));
        cur.setEditFlag(Constant.Edit_Yes);
        //返回信息
        ReturnObject returnObject = new ReturnObject();
        try {
            int editNum = customerRemarkService.editCustomerRemark(cur);
            if(editNum>0){
                returnObject.setCode(Constant.Operation_Success);
                returnObject.setRetData(cur);
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

    @RequestMapping("/workbench/customer/queryContactsForDetailByDimName.do")
    @ResponseBody
    public Object queryContactsForDetailByDimName(String dimName){
        return contactsService.queryContactsForDetailByDimName(dimName);
    }



}
