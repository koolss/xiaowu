import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:xiaowu/common/Constants.dart';
import 'package:xiaowu/entity/user_entity.dart';
import 'package:xiaowu/page/login/CheckPage.dart';
import 'package:xiaowu/page/tab_bar/TabBarPage.dart';
import 'package:xiaowu/service/service_method.dart';
import 'package:xiaowu/service/service_url.dart';
import 'package:xiaowu/util/ColorUtil.dart';

class LoginPage extends StatefulWidget {
  @override
  State createState() {
    return new _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController phoneController = new TextEditingController();
  FocusNode focusNode = FocusNode();

  // 按钮是否启用
  bool btnEnable = false;

  // 按钮透明度
  double btnOpacity = 0.5;

  @override
  Widget build(BuildContext context) {
    Widget logoSection = Container(
      alignment: Alignment(0, 0),
      child: Image.asset(
        "assets/images/login/logo.png",
        width: ScreenUtil.getInstance().getAdapterSize(130),
        height: ScreenUtil.getInstance().getAdapterSize(130),
      ),
    );

    Widget labelSection = Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(
              "手机验证码登录",
              style: TextStyle(
                  fontSize: ScreenUtil.getInstance().getSp(24),
                  color: ColorUtil.fromHex('#FF161833')),
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(top: ScreenUtil.getInstance().getHeight(16)),
            child: Text(
              "未注册手机可输入验证码完成注册",
              style: TextStyle(
                  fontSize: ScreenUtil.getInstance().getSp(14),
                  color: ColorUtil.fromHex('#FF94969E')),
            ),
          ),
        ],
      ),
    );

    Widget phoneSection = Container(
      child: TextField(
        controller: phoneController,
        keyboardType: TextInputType.phone,
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: "请输入手机号码",
          hintStyle: TextStyle(
            color: ColorUtil.fromHex("#FF94969E"),
          ),
          prefixIcon: GestureDetector(
            onTap: () {
              if (!focusNode.hasFocus) {
                setState(() {
                  focusNode.canRequestFocus = false;
                });
              }
            },
            child: Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Text(
                      "+86",
                      style: TextStyle(
                          color: ColorUtil.fromHex("#161833"),
                          fontSize: ScreenUtil.getInstance().getSp(16)),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 2, right: 2),
                    child: Icon(
                      Icons.keyboard_arrow_down_sharp,
                      color: ColorUtil.fromHex("#94969E"),
                    ),
                  )
                ],
              ),
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: ColorUtil.fromHex("#DDDEDD")),
          ),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: ColorUtil.fromHex("#DDDEDD"))),
          suffixIcon: GestureDetector(
            onTap: () {
              this.phoneController.clear();
              if (!focusNode.hasFocus) {
                focusNode.canRequestFocus = false;
              }
              setState(() {
                this.btnEnable = false;
                this.btnOpacity = 0.5;
              });
            },
            child: Image.asset("assets/images/login/cha.png"),
          ),
        ),
        autofocus: false,
        onChanged: (val) {
          setState(() {
            if (this._checkPhone()) {
              this.btnEnable = true;
              this.btnOpacity = 1.0;
            } else {
              this.btnEnable = false;
              this.btnOpacity = 0.5;
            }
          });
        },
      ),
    );

    Widget btnSection = Opacity(
      opacity: btnOpacity,
      child: Container(
        height: ScreenUtil.getInstance().getHeight(49),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorUtil.fromHex("#F76600"),
              ColorUtil.fromHex("#FCA000")
            ],
          ),
          borderRadius: BorderRadius.circular(24.5),
        ),
        child: TextButton(
          style: ButtonStyle(
            //设置水波纹颜色 透明
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
          child: Text(
            '获取验证码',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () =>
              btnEnable == true ? this._getVerificationCode() : null,
        ),
      ),
    );

    Widget weiXinSection = Container(
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorUtil.fromHex("#FFFFFF"),
                        ColorUtil.fromHex("#94969E")
                      ],
                    ),
                  ),
                  child: Container(
                    width: ScreenUtil.getInstance().getWidth(50),
                    height: 1,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: ScreenUtil.getInstance().getWidth(10)),
                  child: Text(
                    "使用第三方登录",
                    style: TextStyle(
                        color: ColorUtil.fromHex("#93959B"), fontSize: 14),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: ScreenUtil.getInstance().getWidth(10)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorUtil.fromHex("#94969E"),
                        ColorUtil.fromHex("#FFFFFF")
                      ],
                    ),
                  ),
                  child: Container(
                    width: ScreenUtil.getInstance().getWidth(50),
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: GestureDetector(
              onTap: () {
                this._weiXinLogin();
              },
              child: Image.asset(
                "assets/images/login/weixin.png",
                width: ScreenUtil.getInstance().getWidth(32),
                height: ScreenUtil.getInstance().getHeight(32),
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
        //可以通过设置 这个属性 防止键盘 覆盖内容 或者 键盘 撑起内容
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // 触摸收起键盘
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            decoration: BoxDecoration(
              image: new DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage("assets/images/login/bg.png"),
              ),
            ),
            child: Container(
                margin: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: ScreenUtil.getInstance().getAdapterSize(30)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: ScreenUtil.getInstance().getHeight(96),
                    ),
                    logoSection,
                    SizedBox(
                      height: ScreenUtil.getInstance().getHeight(30),
                    ),
                    labelSection,
                    SizedBox(
                      height: ScreenUtil.getInstance().getHeight(45),
                    ),
                    phoneSection,
                    SizedBox(
                      height: ScreenUtil.getInstance().getHeight(39),
                    ),
                    btnSection,
                    Spacer(),
                    weiXinSection,
                    SizedBox(
                      height: ScreenUtil.getInstance().getHeight(53),
                    ),
                  ],
                )),
          ),
        ));
  }

  /// 校验电话号码是否通过
  bool _checkPhone() {
    var phone = this.phoneController.text;
    if (phone.isEmpty) {
      return false;
    }
    if (phone.length != 11) {
      return false;
    }
    return true;
  }

  // 获取验证码
  void _getVerificationCode() {
    var phone = this.phoneController.text;
    var param = {"phone": phone};
    Navigator.pushNamed(context, "loginCheck",
        arguments: param);
    /*request(servicePath["getVerificationCode"],
            data: param, contentType: Headers.formUrlEncodedContentType)
        .then(
      (data) {
        if (data["code"] == 200) {
          Navigator.pushNamed(context, "loginCheck",
              arguments: {"phone": phone});
        } else {
          EasyLoading.showToast(data["msg"]);
        }
      },
    );*/
  }

  void _weiXinLogin() {
    checkCode("18108099936", "6666");
    print("点击微信登录");
  }

  void checkCode(String phone, String code) {
    // 验证码登录
    request(servicePath["verificationCodeLogin"],
            data: {"userName": phone, "code": code},
            contentType: Headers.formUrlEncodedContentType)
        .then((data) {
      // 校验成功
      if (data["code"] == 200) {
        var user = UserEntity().fromJson(data["data"]);
        SpUtil.putObject(Constants.LOGIN_DATA_KEY, user);
        Navigator.pushNamed(context, "/");
      }
    });
  }
}
