
import 'package:dio/dio.dart';
import 'package:temp/app_information/app_information.dart';
import 'package:temp/http/token/http_token.dart';
import 'package:temp/http/user/http_user.dart';
import 'package:temp/localStorage/tokenStorage/token_storage.dart';


class ErrorTypeTimeout{

}

enum ErrorTypeTimeoutEnum{
  timeout,
}


class AuthInterceptor extends Interceptor {
  int repeatCounter = 0;
  late Dio dio;
  AuthInterceptor(Dio _dio){
    dio=_dio;
  }
  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    
    if(err.error==DioExceptionType.sendTimeout){
      return ErrorTypeTimeout();
    }


    if (err.response?.statusCode == 401&&repeatCounter.isEven) {
      repeatCounter++;
      
      await HttpToken().refreshToken();
      final token= tokenStorage.accessToken;
      dio.options.headers["Authorization"]="Bearer $token"; 
      print("reReq401");
      final result=  await dio.request(
          err.requestOptions.path, 
          data:  err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: Options(method:  err.requestOptions.method),
          );  
          print(result);
          return handler.resolve(result);
          
    }
    repeatCounter=0;
    if (err.response?.statusCode == 400) {


      
    }
    if (err.response?.statusCode == 409) {
        print(err.response?.data);
      DioException newErr=err;
      newErr.message!="409";
      handler.next(newErr);
    }
    if (err.response?.statusCode == 500) {
        print(err.requestOptions.path);
        print(err.response?.data);

      
    }
    
    handler.next(err);
    
    
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    //print(options.queryParameters);
   options.headers.addEntries({
    MapEntry("app_version","1.0.6"),
    MapEntry("Authorization",'Bearer ${tokenStorage.accessToken}')
   });
   //print("HV"+options.headers["version"]);
    handler.next(options);
  }
}