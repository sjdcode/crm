<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String basePath= request.getScheme() + "://"+request.getServerName()+":"+ request.getServerPort()+request.getContextPath()+"/";
%>
<html>
<head>
    <base href="<%=basePath%>">
    <%--引入jq--%>
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <title>Title</title>
    <script type="text/javascript">
        $(function (){
            $("#downloadBtn").click(function (){
                window.location.href="workbench/activity/exportAllActivitys.do";
            })
        })
    </script>
</head>
<body>
<input type="button" id="downloadBtn" value="文件下载">
</body>
</html>
