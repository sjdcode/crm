<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
    <%--引入typehead框架--%>
    <script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>
    <title>演示typehead框架</title>

    <script type="text/javascript">
        $(function (){
            $("#typeheadBtn").typeahead({
                source:function (jquery,process){
                    alert(jquery)
                    $.ajax({
                        url:"workbench/transaction/queryCustomerNameByDimName.do",
                        data:{
                            //jquery是输入框的内容
                            dimCustomerName:jquery
                        },
                        type:'post',
                        datatyoe:'json',
                        success:function (data){
                            //process可以转化数据为[a,b,c,...]的格式,符合框架要求
                            process(data);
                        }
                    })
                }
            })
        })
    </script>
</head>
<body>
<input type="text" id="typeheadBtn">
</body>
</html>
