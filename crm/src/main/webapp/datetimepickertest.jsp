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
    <%--引入日历插件--%>
    <link rel="stylesheet" href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css">
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
    <title>演示日历插件</title>
    <script type="text/javascript">
        $(function (){
           $("#myDate").datetimepicker({
               language:'zh-CN',//语言
               format:'yyyy-mm-dd',//日期的格式
               minView:'month',//可以选择的最小视图
               initialDate:new Date(),//打开后默认选择日期
               autoclose:'true',//选择完之后是否默认关闭
               todayBtn:'true',//显示今天的按钮
               clearBtn:'true'//设置清空按钮
           });
        });
    </script>
</head>
<body>
<%--readonly:不能改能提交--%>
<%--disable :不能改不能提交--%>
<input type="text" id="myDate" readonly="readonly">
</body>
</html>
