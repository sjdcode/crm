<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath= request.getScheme() + "://"+request.getServerName()+":"+ request.getServerPort()+request.getContextPath()+"/";
%>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<%--引入日历插件--%>
<link rel="stylesheet" href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css">
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<%--引入typehead框架--%>
<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>
<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		/*$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").show();
		});
		
		$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").hide();
		});
		
		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});*/

		$("#customerRemarkTBody").on('mouseover','.remarkDiv',function (){
			$(this).children("div").children("div").show();
		})

		$("#customerRemarkTBody").on('mouseout','.remarkDiv',function (){
			$(this).children("div").children("div").hide();
		})

		$("#customerRemarkTBody").on('mouseover','.myHref',function (){
			$(this).children("span").css("color","red");
		})

		$("#customerRemarkTBody").on('mouseout','.myHref',function (){
			$(this).children("span").css("color","#E6E6E6");
		})

		//添加备注
		$("#createCustomerRemarkBtn").click(function (){
			//收集参数
			var customerId='${customerDetail.id}';
			var noteContent=$.trim($("#remark").val());

			//判断参数
			if(noteContent===""){
				alert("请输入备注内容");
				return;
			}

			//发送请求
			$.ajax({
				url:'workbench/customer/saveCreateCustomerRemark.do',
				data:{
					customerId:customerId,
					noteContent:noteContent
				},
				type:'post',
				datatype:'json',
				success:function (data){
					if(data.code==='1'){
						//清空输入输入框,显示数据
						$("#remark").val("");
						var appendCustomerRemarkStr="";
						appendCustomerRemarkStr+="<div class=\"remarkDiv\" id=\"div_"+data.retData.id+"\" style=\"height: 60px;\">";
						appendCustomerRemarkStr+="<img title=\"${sessionScope.loginUserMsg.name}\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">";
						appendCustomerRemarkStr+="<div style=\"position: relative; top: -40px; left: 40px;\" >";
						appendCustomerRemarkStr+="<h5>"+data.retData.noteContent+"</h5>";
						appendCustomerRemarkStr+="<font color=\"gray\">客户</font> <font color=\"gray\">-</font> <b>${customerDetail.name}</b> <small style=\"color: gray;\"> "+data.retData.createTime+" 由${sessionScope.loginUserMsg.name}创建</small>";
						appendCustomerRemarkStr+="<div style=\"position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;\">";
						appendCustomerRemarkStr+="<a class=\"myHref\" name=\"edit\" customerRemarkId=\""+data.retData.id+"\" href=\"javascript:void(0);\"><span class=\"glyphicon glyphicon-edit\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
						appendCustomerRemarkStr+="&nbsp;&nbsp;&nbsp;&nbsp;";
						appendCustomerRemarkStr+="<a class=\"myHref\" name=\"delete\" customerRemarkId=\""+data.retData.id+"\" href=\"javascript:void(0);\"><span class=\"glyphicon glyphicon-remove\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
						appendCustomerRemarkStr+="</div>";
						appendCustomerRemarkStr+="</div>";
						appendCustomerRemarkStr+="</div>";
						$("#remarkDiv").before(appendCustomerRemarkStr);
					}else if(data.code==='0'){
						alert(data.message);
					}
				}
			})
		})

		//删除备注
		$("#customerRemarkTBody").on('click','a[name="delete"]',function (){
			//收集参数
			var id=$(this).attr("customerRemarkId");

			//发送请求
			$.ajax({
				url:'workbench/customer/deleteCustomerRemark.do',
				data:{
					id:id
				},
				type:'post',
				datatype:'json',
				success:function (data){
					if(data.code==='0'){
						alert(data.message);
					}else if(data.code==='1'){
						//清空备注信息
						$("#div_"+id).remove();
					}
				}
			})
		})

		//编辑用户
		$("#customerRemarkTBody").on('click','a[name="edit"]',function (){
			var id=$(this).attr("customerRemarkId");
			var oldNoteContent=$("#div_"+id+" h5").text();
			//数据回显
			$("#noteContent").val(oldNoteContent);
			//打开模态框
			$("#editRemarkModal").modal("show");

			//click内嵌click事件,内层click绑定之前用unbind()清除事件
			$("#updateRemarkBtn").unbind();
			//点击编辑按钮   click嵌套绑定需要在内层使用one
			$("#updateRemarkBtn").one('click',function (){
				var noteContent=$.trim($("#noteContent").val());
				//判断参数合法性
				if(noteContent===''){
					alert("请输入修改后的内容");
					return;
				}
				//发送请求
				$.ajax({
					url:'workbench/customer/editCustomerRemark.do',
					data:{
						id:id,
						noteContent:noteContent
					},
					type:'post',
					datatype:'json',
					success:function (data){
						if(data.code==='0'){
							alert(data.message);
							$("#editRemarkModal").modal("show");
						}else if(data.code==='1'){
							//清空输入框
							$("#noteContent").val("");
							//更新数据内容
							$("#div_"+id+" h5").text(noteContent);
							$("#div_"+id+" small").text(" "+data.retData.editTime+" 由${sessionScope.loginUserMsg.name}修改")
							//关闭模态框
							$("#editRemarkModal").modal("hide");
						}
					}
				})
			})
		})

		//删除Tran
		$("#tranTBody").on('click','a',function (){
			//判断是否删除
			if(window.confirm("您确定删除吗>")===false){
				return false;
			}
			//打开模态框
			$("#removeTransactionModal").modal("show");
			//收集参数
			var tranId=$(this).attr("tranId");
			//点击确认按钮  发送请求
			$("#confirmDeleteTranBtn").unbind();
			$("#confirmDeleteTranBtn").click(function (){
				$.ajax({
					url:'workbench/transaction/deleteTran.do',
					data:{
						id:tranId
					},
					type:'post',
					datatype:'json',
					success:function (data){
						if(data.code==='0'){
							alert(data.message);
							$("#removeTransactionModal").modal("show");
						}else if(data.code==='1'){
							//删除数据
							$("#tr_"+tranId).remove();
							//关闭modal
							$("#removeTransactionModal").modal("hide");
						}
					}
				})
			})
		})

		//日历插件
		$(".datetimepicker").datetimepicker({
			language:'zh-CN',//语言
			format:'yyyy-mm-dd',//日期的格式
			minView:'month',//可以选择的最小视图
			initialDate:new Date(),//打开后默认选择日期
			autoclose:'true',//选择完之后是否默认关闭
			todayBtn:'true',//显示今天的按钮
			clearBtn:'true'//设置清空按钮
		})

		//添加Contacts的modal客户名称下拉菜单使用typehead框架
		$("#create-customerName").typeahead({
			source:function (jquery,process){
				$.ajax({
					url:'workbench/transaction/queryCustomerNameByDimName.do',
					data:{
						dimName:jquery
					},
					type:'post',
					datatype:'json',
					success:function (data){
						process(data);
					}
				})
			}
		})

		//添加Contacts
		$("#createContactsBtn").click(function (){
			//打开模态框
			$("#createContactsModal").modal("show");
		})

		//确定创建Contacts
		$("#confirmSaveCreateContactsBtn").click(function (){
			//收集参数
			var owner=$("#create-contactsOwner").val();
			var source=$("#create-clueSource").val();
			var fullname=$("#create-surname").val();
			var appellation=$("#create-call").val();
			var job=$("#create-job").val();
			var mphone=$("#create-mphone").val();
			var email=$("#create-email").val();
			var birthDay=$("#create-birth").val();
			var customerName=$("#create-customerName").val();
			var description=$("#create-describe").val();
			var contactSummary=$("#edit-contactSummary").val();
			var nextContactTime=$("#edit-nextContactTime").val();
			var address=$("#edit-address1").val();
			//效验参数
			if(fullname===''){
				alert("姓名不能为空");
				return
			}
			//发送请求
			$.ajax({
				url:'workbench/contacts/saveCreateContacts.do',
				data:{
					owner:owner,
					source:source,
					fullname:fullname,
					appellation:appellation,
					job:job,
					mphone:mphone,
					email:email,
					birthDay:birthDay,
					customerName:customerName,
					description:description,
					contactSummary:contactSummary,
					nextContactTime:nextContactTime,
					address:address,
				},
				type:'post',
				datatype:'json',
				success:function (data){
					if(data.code===0){
						alert(data.message);
						$("#createContactsModal").modal("show");
					}else if(data.code==='1'){
						//清空输入框
						$("#createContactForm")[0].reset();
						//显示数据  判断是否属于该客户,是则显示数据
						if(data.retData.customerId==='${customerDetail.id}'){
							var addContactsStr="";
							addContactsStr+="<tr id=\"tr_"+data.retData.id+"\">";
							addContactsStr+="<td><a href=\"workbench/contacts/toDetail.do?id="+data.retData.id+"\" style=\"text-decoration: none;\">"+data.retData.fullname+"</a></td>";
							addContactsStr+="<td>"+data.retData.email+"</td>";
							addContactsStr+="<td>"+data.retData.mphone+"</td>";
							addContactsStr+="<td><a href=\"javascript:void(0);\" contactsId=\""+data.retData.id+"\"  style=\"text-decoration: none;\"><span class=\"glyphicon glyphicon-remove\"></span>删除</a></td>";
							addContactsStr+="</tr>";
							$("#contactsTBody").append(addContactsStr);
						}
						//关闭modal
						$("#createContactsModal").modal("hide");
					}
				}
			})
		})

		//删除contacts
		$("#contactsTBody").on('click','a[contactsId]',function (){
			//确定判断
			if(window.confirm("您确定要删除吗?")===false){
				return;
			}

			//收集参数
			var id=$(this).attr('contactsId');
			//发送请求
			$.ajax({
				url:'workbench/contacts/deleteContactsById.do',
				data:{
					id:id
				},
				type:'post',
				datatype:'json',
				success:function (data){
					if(data.code==='0'){
						alert(data.message);
					}else if(data.code==='1'){
						//清空数据
						$("#tr_"+id).remove();
					}
				}
			})
		})
	});
	
</script>

</head>
<body>

	<!-- 修改市场活动备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<%-- 备注的id --%>
		<input type="hidden" id="remarkId">
		<div class="modal-dialog" role="document" style="width: 40%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">修改备注</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<div class="form-group">
							<label for="noteContent" class="col-sm-2 control-label">内容</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="noteContent"></textarea>
							</div>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
				</div>
			</div>
		</div>
	</div>

	<!-- 删除联系人的模态窗口 -->
	<div class="modal fade" id="removeContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 30%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">删除联系人</h4>
				</div>
				<div class="modal-body">
					<p>您确定要删除该联系人吗？</p>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" id="confirmDeleteContactsBtn" class="btn btn-danger" >删除</button>
				</div>
			</div>
		</div>
	</div>

    <!-- 删除交易的模态窗口 -->
    <div class="modal fade" id="removeTransactionModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 30%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title">删除交易</h4>
                </div>
                <div class="modal-body">
                    <p>您确定要删除该交易吗？</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                    <button type="button" class="btn btn-danger" id="confirmDeleteTranBtn">删除</button>
                </div>
            </div>
        </div>
    </div>
	
	<!-- 创建联系人的模态窗口 -->
	<div class="modal fade" id="createContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" onclick="$('#createContactsModal').modal('hide');">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建联系人</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" id="createContactForm" role="form">
					
						<div class="form-group">
							<label for="create-contactsOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-contactsOwner">
								  <%--<option>zhangsan</option>
								  <option>lisi</option>
								  <option>wangwu</option>--%>
									<c:forEach items="${userList}" var="user">
										<option value="${user.id}">${user.name}</option>
									</c:forEach>
								</select>
							</div>
							<label for="create-clueSource" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-clueSource">
								  <option></option>
								  <%--<option>广告</option>
								  <option>推销电话</option>
								  <option>员工介绍</option>
								  <option>外部介绍</option>
								  <option>在线商场</option>
								  <option>合作伙伴</option>
								  <option>公开媒介</option>
								  <option>销售邮件</option>
								  <option>合作伙伴研讨会</option>
								  <option>内部研讨会</option>
								  <option>交易会</option>
								  <option>web下载</option>
								  <option>web调研</option>
								  <option>聊天</option>--%>
									<c:forEach items="${sourceList}" var="source">
										<option value="${source.id}">${source.value}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-surname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-surname">
							</div>
							<label for="create-call" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-call">
								  <option></option>
								  <%--<option>先生</option>
								  <option>夫人</option>
								  <option>女士</option>
								  <option>博士</option>
								  <option>教授</option>--%>
									<c:forEach items="${appellationList}" var="appellation">
										<option value="${appellation.id}">${appellation.value}</option>
									</c:forEach>
								</select>
							</div>
							
						</div>
						
						<div class="form-group">
							<label for="create-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-job">
							</div>
							<label for="create-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-mphone">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email">
							</div>
							<label for="create-birth" class="col-sm-2 control-label">生日</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control datetimepicker" readonly="readonly" id="create-birth">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-customerName" placeholder="支持自动补全，输入客户不存在则新建">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-describe"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                        <div style="position: relative;top: 15px;">
                            <div class="form-group">
                                <label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                                <div class="col-sm-10" style="width: 300px;">
                                    <input type="text" class="form-control datetimepicker" readonly="readonly" id="edit-nextContactTime" value="">
                                </div>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address1" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address1"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="confirmSaveCreateContactsBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${customerDetail.name} <small><a href="http://www.bjpowernode.com" target="_blank">${customerDetail.website}</a></small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" data-toggle="modal" data-target="#editCustomerModal"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	
	<br/>
	<br/>
	<br/>

	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${customerDetail.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${customerDetail.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">公司网站</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${customerDetail.website}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${customerDetail.phone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${customerDetail.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${customerDetail.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${customerDetail.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${customerDetail.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 40px;">
            <div style="width: 300px; color: gray;">联系纪要</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
					${customerDetail.contactSummary}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
        <div style="position: relative; left: 40px; height: 30px; top: 50px;">
            <div style="width: 300px; color: gray;">下次联系时间</div>
            <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${customerDetail.nextContactTime}</b></div>
            <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
        </div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${customerDetail.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 70px;">
            <div style="width: 300px; color: gray;">详细地址</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
					${customerDetail.address}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
	</div>
	
	<!-- 备注 -->
	<div style="position: relative; top: 10px; left: 40px;" id="customerRemarkTBody">
		<div class="page-header">
			<h4>备注</h4>
		</div>

		<%--<!-- 备注1 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">客户</font> <font color="gray">-</font> <b>北京动力节点</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		
		<!-- 备注2 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">客户</font> <font color="gray">-</font> <b>北京动力节点</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>--%>

		<c:forEach items="${customerRemarkList}" var="customerRemark">
			<div class="remarkDiv" id="div_${customerRemark.id}" style="height: 60px;">
				<img title="${customerRemark.createBy}" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
				<div style="position: relative; top: -40px; left: 40px;" >
					<h5>${customerRemark.noteContent}</h5>
					<font color="gray">客户</font> <font color="gray">-</font> <b>${customerDetail.name}</b> <small style="color: gray;"> ${customerRemark.editFlag=='0'?customerRemark.createTime:customerRemark.editTime} 由${customerRemark.editFlag=='0'?customerRemark.createBy:customerRemark.editBy}${customerRemark.editFlag=='0'?"创建":"修改"}</small>
					<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
						<a class="myHref" name="edit" customerRemarkId="${customerRemark.id}" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
						&nbsp;&nbsp;&nbsp;&nbsp;
						<a class="myHref" name="delete" customerRemarkId="${customerRemark.id}" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
					</div>
				</div>
			</div>
		</c:forEach>

		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" id="createCustomerRemarkBtn" class="btn btn-primary">保存</button>
				</p>
			</form>
		</div>
	</div>
	
	<!-- 交易 -->
	<div>
		<div style="position: relative; top: 20px; left: 40px;">
			<div class="page-header">
				<h4>交易</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable2" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>金额</td>
							<td>阶段</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>类型</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="tranTBody">
						<%--<tr>
							<td><a href="transaction/detail.jsp" style="text-decoration: none;">动力节点-交易01</a></td>
							<td>5,000</td>
							<td>谈判/复审</td>
							<td>90</td>
							<td>2017-02-07</td>
							<td>新业务</td>
							<td><a href="javascript:void(0);" data-toggle="modal" data-target="#removeTransactionModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
						</tr>--%>
						<c:forEach items="${tranList}" var="tran">
							<tr id="tr_${tran.id}">
								<td><a href="workbench/transaction/toDetail.do?id=${tran.id}" style="text-decoration: none;">${tran.name}</a></td>
								<td>${tran.money}</td>
								<td>${tran.stage}</td>
								<td>${tran.possibility}</td>
								<td>${tran.expectedDate}</td>
								<td>${tran.type}</td>
								<td><a href="javascript:void(0);" tranId="${tran.id}" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
							</tr>
						</c:forEach>
					</tbody>
				</table>
			</div>

			<div>
				<a href="workbench/transaction/toSave.do?customerId=${customerDetail.id}" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建交易</a>
			</div>
		</div>
	</div>
	
	<!-- 联系人 -->
	<div>
		<div style="position: relative; top: 20px; left: 40px;">
			<div class="page-header">
				<h4>联系人</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>邮箱</td>
							<td>手机</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="contactsTBody">
						<%--<tr>
							<td><a href="contacts/detail.jsp" style="text-decoration: none;">李四</a></td>
							<td>lisi@bjpowernode.com</td>
							<td>13543645364</td>
							<td><a href="javascript:void(0);" data-toggle="modal" data-target="#removeContactsModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
						</tr>--%>
					<c:forEach items="${contactsList}" var="contacts">
						<tr id="tr_${contacts.id}">
							<td><a href="workbench/contacts/toDetail.do?id=${contacts.id}" style="text-decoration: none;">${contacts.fullname}</a></td>
							<td>${contacts.email}</td>
							<td>${contacts.mphone}</td>
							<td><a href="javascript:void(0);" contactsId="${contacts.id}"  style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
						</tr>
					</c:forEach>
					</tbody>
				</table>
			</div>
			
			<div>
				<a href="javascript:void(0);" id="createContactsBtn" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建联系人</a>
			</div>
		</div>
	</div>
	
	<div style="height: 200px;"></div>
</body>
</html>