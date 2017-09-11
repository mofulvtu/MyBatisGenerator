<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>大图模式</title>
	<style>
		body {
			margin: 50px 0;
			text-align: center;
			font-family: "PingFangSC-Regular", "Open Sans", Arial, "Hiragino Sans GB", "Microsoft YaHei", "STHeiti", "WenQuanYi Micro Hei", SimSun, sans-serif;
		}

		.inp {
			border: 1px solid #cccccc;
			border-radius: 2px;
			padding: 0 10px;
			width: 278px;
			height: 40px;
			font-size: 18px;
		}

		.btn {
			display: inline-block;
			box-sizing: border-box;
			border: 1px solid #cccccc;
			border-radius: 2px;
			width: 100px;
			height: 40px;
			line-height: 40px;
			font-size: 16px;
			color: #666;
			cursor: pointer;
			background: white linear-gradient(180deg, #ffffff 0%, #f3f3f3 100%);
		}

		.btn:hover {
			background: white linear-gradient(0deg, #ffffff 0%, #f3f3f3 100%)
		}

		#captcha {
			width: 300px;
			display: inline-block;
		}

		label {
			vertical-align: top;
			display: inline-block;
			width: 80px;
			text-align: right;
		}

		#wait {
			text-align: left;
			color: #666;
			margin: 0;
		}

	</style>
</head>
<body>
<%--<h2><a href="./">返回</a></h2>--%>
<h1>大图模式</h1>
<form id="form">
	<div>
		<label for="username">用户名：</label>
		<input class="inp" id="username" name="username" type="text" >
	</div>
	<br>
	<div>
		<label for="userpwd">密码：</label>
		<input class="inp" id="userpwd" name="userpwd" type="password">
	</div>
	<br>
	<div>
		<label>完成验证：</label>
		<div id="captcha">
			<p id="wait" class="show">正在加载验证码......</p>
		</div>
	</div>
	<br>
	<div id="btn" class="btn">提交</div>
</form>

<!-- 注意，验证码本身是不需要 jquery 库，此处使用 jquery 仅为了在 demo 中使用，减少代码量 -->
<script src="http://apps.bdimg.com/libs/jquery/1.9.1/jquery.js"></script>
<!-- 引入 gt.js，既可以使用其中提供的 initGeetest 初始化函数 -->
<script src="gt.js"></script>
<script>
	var handler = function (captchaObj) {
		captchaObj.appendTo('#captcha');
		captchaObj.onReady(function () {
			$("#wait").hide();
		});
		$('#btn').click(function () {
			var result = captchaObj.getValidate();
			if (!result) {
				return alert('请完成验证');
			}
			$.ajax({
				url: '${base}/login',
				type: 'POST',
				dataType: 'json',
				data: {
					username: $('#username').val(),
					userpwd: $('#userpwd').val(),
					geetest_challenge: result.geetest_challenge,
					geetest_validate: result.geetest_validate,
					geetest_seccode: result.geetest_seccode
				},
				success: function (data) {
					if (data.status === 'success') {
						alert('登录成功');
						alert(data.user.username);
					} else if (data.status === 'fail') {
						alert('登录失败，请完成验证');
						captchaObj.reset();
					}
				}
			});
		})
	};

	$.ajax({
		url: "gt/login?t=" + (new Date()).getTime(), // 加随机数防止缓存
		type: "get",
		dataType: "json",
		success: function (data) {

			// 调用 initGeetest 进行初始化
			// 参数1：配置参数
			// 参数2：回调，回调的第一个参数验证码对象，之后可以使用它调用相应的接口
			initGeetest({
				// 以下 4 个配置参数为必须，不能缺少
				gt: data.gt,
				challenge: data.challenge,
				offline: !data.success, // 表示用户后台检测极验服务器是否宕机
				new_captcha: data.new_captcha, // 用于宕机时表示是新验证码的宕机

				product: "float", // 产品形式，包括：float，popup
				width: "300px"
				// 更多前端配置参数说明请参见：http://docs.geetest.com/install/client/web-front/
			}, handler);
		}
	});
</script>
</body>
</html>
