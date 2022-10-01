<%--
  Created by IntelliJ IDEA.
  User: dell
  Date: 2022/7/19
  Time: 13:07
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String basePath= request.getScheme() + "://"+request.getServerName()+":"+ request.getServerPort()+request.getContextPath()+"/";
%>
<html>
<head>
    <base href="<%=basePath%>">
    <%--引入jq--%>
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <%--引入bootstrap框架--%>
    <link rel="stylesheet" href="jquery/bootstrap_3.3.0/css/bootstrap.min.css">
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <%--引入分页插件--%>
    <link rel="stylesheet" href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css">
    <script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
    <script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>
    <title>演示bs_pagination插件的使用</title>
</head>
<script>
    $(function (){
        $("#demo1_page01").bs_pagination({
            totalPages:100,//总页数---必须写
            totalRows:1000,//总记录条数
            rowsPerPage:10,//每页显示的条数

            currentPage:1,//当前显示的页面

            visiblePageLinks: 10,//显示的卡片数量

            showGoToPage: true,//显示跳转页面
            showRowsPerPage: true,//显示每页的条数
            showRowsInfo: true,//显示记录的信息

            onChangePage:function (event,pageObj){//用户切换页码时触发的函数 --返回切换页码时pageNo和pageSize
                //event   事件
                //pageObj 翻页信息
                alert(pageObj.currentPage);
                alert(pageObj.rowsPerPage);
            }
        })
    })
</script>
<body>
<div id="demo1_page01"></div>
</body>
</html>
