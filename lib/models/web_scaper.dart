import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'dart:async';

//https://pub.dev/packages/cookie_jar
class WebScraper {
  var dio = Dio();
  var cookieJar = CookieJar();
  var response;

  WebScraper() {
    dio.interceptors.add(CookieManager(cookieJar));
    getCookie();
  }

  String getHtmlFromNesaLoginPage() {
    return "";
  }

  void getCookie() async {
    response = await dio.get('https://ksh.nesa-sg.ch/index.php?pageid=1');
    print(await cookieJar.loadForRequest(Uri.parse("https://ksh.nesa-sg.ch/index.php?pageid=1")));
  }
}
