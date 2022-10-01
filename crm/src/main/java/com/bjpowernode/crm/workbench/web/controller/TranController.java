package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.constant.Constant;
import com.bjpowernode.crm.commons.domain.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtil;
import com.bjpowernode.crm.commons.utils.UUIDUtil;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.DicValueService;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.workbench.domain.Tran;
import com.bjpowernode.crm.workbench.service.ActivityService;
import com.bjpowernode.crm.workbench.service.ContactsService;
import com.bjpowernode.crm.workbench.service.CustomerService;
import com.bjpowernode.crm.workbench.service.TranService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpSession;
import java.util.*;

@Controller
public class TranController {
    @Autowired
    private DicValueService dicValueService;
    @Autowired
    private TranService tranService;
    @Autowired
    private UserService userService;
    @Autowired
    private CustomerService customerService;
    @Autowired
    private ActivityService activityService;
    @Autowired
    private ContactsService contactsService;

    @RequestMapping("/workbench/transaction/toIndex.do")
    public String toIndex(Model model){
        //查询阶段,类型,来源
        model.addAttribute("stageList",dicValueService.queryDicValueByTypeValue("stage"));
        model.addAttribute("typeList",dicValueService.queryDicValueByTypeValue("transactionType"));
        model.addAttribute("sourceList",dicValueService.queryDicValueByTypeValue("source"));
        return "/workbench/transaction/index";
    }

    @RequestMapping("/workbench/transaction/queryTranByConditionForPage.do")
    @ResponseBody
    public Object queryTranByConditionForPage(String owner,String name,String customerName,String stage,String type,
                                              String source,String contactsName,int pageNo,int pageSize){
        //封装参数
        HashMap<String, Object> map = new HashMap<>();
        map.put("owner",owner);
        map.put("name",name);
        map.put("customerName",customerName);
        map.put("stage",stage);
        map.put("type",type);
        map.put("source",source);
        map.put("contactsName",contactsName);
        map.put("beginNo",(pageNo-1)*pageSize);
        map.put("pageSize",pageSize);
        //生成信息
        List<Tran> tranList = tranService.queryTranByConditionForPage(map);
        int totalRows = tranService.queryCountForTranByCondition(map);
        //返回信息
        HashMap<String, Object> returnMap = new HashMap<>();
        returnMap.put("tranList",tranList);
        returnMap.put("totalRows",totalRows);
        return returnMap;
    }

    @RequestMapping("/workbench/transaction/toSave.do")
    public String toSave(Model model,String customerId){
        //下拉字段菜单显示
        model.addAttribute("userList",userService.queryAllUsers());
        model.addAttribute("stageList",dicValueService.queryDicValueByTypeValue("stage"));
        model.addAttribute("typeList",dicValueService.queryDicValueByTypeValue("transactionType"));
        model.addAttribute("sourceList",dicValueService.queryDicValueByTypeValue("source"));
        //如果customerId不是null,就是客户处点的添加Tran按钮,需要在返回页面客户处自动补全  返回customer真实姓名
        model.addAttribute("customer",customerService.queryCustomerForDetailById(customerId));
        return "/workbench/transaction/save";
    }

    @RequestMapping("/workbench/transaction/queryPossibility.do")
    @ResponseBody
    public Object queryPossibility(String stage){
        //返回可能性
        ResourceBundle possibility = ResourceBundle.getBundle("possibility");
        return possibility.getString(stage)+"%";
    }

    @RequestMapping("/workbench/transaction/queryCustomerNameByDimName.do")
    @ResponseBody
    public Object queryCustomerNameByDimName(String dimName){
        //根据模糊的公司名字返回可能的公司名字
        return customerService.queryCustomerNameByDimName(dimName);
    }

    @RequestMapping("/workbench/transaction/queryActivityForDetailByDimName.do")
    @ResponseBody
    public Object queryActivityForDetailByDimName(String dimName){
        return activityService.queryActivityForDetailByDimName(dimName);
    }

    @RequestMapping("/workbench/transaction/saveCreateTran.do")
    @ResponseBody
    public Object saveCreateTran(Tran tran, HttpSession httpSession){
        User user=(User)httpSession.getAttribute(Constant.Login_User_Msg);
        //封装后台参数
        tran.setId(UUIDUtil.getUUID());
        tran.setCreateBy(user.getId());
        tran.setCreateTime(DateUtil.FormatDateTime(new Date()));

        ReturnObject returnObject = new ReturnObject();
        try {
            tranService.saveCreateTran(tran,user);
            returnObject.setCode(Constant.Operation_Success);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constant.Operation_Fail);
            returnObject.setMessage("系统忙,请稍后重试...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/transaction/toDetail.do")
    public String toDetail(@RequestParam("id") String tranId){
        return "/workbench/transaction/detail";
    }

    @RequestMapping("/workbench/transaction/deleteTran.do")
    @ResponseBody
    public Object deleteTran(String id){
        ReturnObject returnObject = new ReturnObject();
        try {
            int deleteNum = tranService.deleteTranById(id);
            if(deleteNum>0){
                returnObject.setCode(Constant.Operation_Success);
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


}

