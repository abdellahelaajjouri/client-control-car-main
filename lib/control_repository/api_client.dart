// ignore_for_file: no_leading_underscores_for_local_identifiers, depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:client_control_car/models/errors/error_response.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as httpparse;
import 'package:flutter/foundation.dart' as foundation;

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static const String noInternetMessage =
      "La connexion au serveur API a échoué en raison d'une connexion Internet";
  final int timeoutInSeconds = 240;
  late String token;
  late Map<String, String> mainHeaders;

  ApiClient(
      {required this.appBaseUrl,
      required this.sharedPreferences,
      String? tokenApi}) {
    token = tokenApi ?? "";
    updateHeader(
      token,
    );
  }

  void updateHeader(String token) {
    mainHeaders = {
      'Content-Type': 'application/json;charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  // delete data
  Future<Response> deleteData(String uri,
      {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    try {
      http.Response _response = await http
          .delete(
            Uri.parse(appBaseUrl + uri),
            headers: headers ?? mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      Response response = handleResponse(_response);

      return response;
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  // get data
  Future<Response> getData(String uri,
      {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    try {
      http.Response _response = await http
          .get(
            Uri.parse(appBaseUrl + uri),
            headers: headers ?? mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      Response response = handleResponse(_response);

      return response;
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

// get lovation
  Future<Response> getLocationData(String uri,
      {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    try {
      http.Response _response = await http
          .get(
            Uri.parse(uri),
            headers: headers ?? mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      Response response = handleResponse(_response);

      return response;
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  // post data
  Future<Response> postData(String uri, dynamic body,
      {Map<String, String>? headers, bool isExt = false}) async {
    try {
      http.Response response = await http
          .post(
            Uri.parse(isExt ? uri : appBaseUrl + uri),
            body: isExt ? body : jsonEncode(body),
            headers: headers ?? mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));

      Response responsehandl = handleResponse(response);

      return responsehandl;
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(String uri, dynamic body,
      {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    try {
      http.Response _response = await http
          .put(
            Uri.parse(appBaseUrl + uri),
            headers: headers ?? mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      Response response = handleResponse(_response);

      return response;
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putDataWithBody(String uri, dynamic body,
      {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    try {
      http.Response rresponse = await http
          .put(
            Uri.parse(appBaseUrl + uri),
            headers: headers ?? mainHeaders,
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      Response response = handleResponse(rresponse);

      return response;
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postDataCustom(String uri, dynamic body,
      {Map<String, String>? headers}) async {
    try {
      http.Response response = await http
          .post(
            Uri.parse(uri),
            body: jsonEncode(body),
            headers: headers ?? mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));

      Response responsehandl = handleResponse(response);

      return responsehandl;
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  // post multipart data
  Future<Response> postMultipartData(
      String uri, Map<String, String> body, List<MultipartBody> multipartBody,
      {Map<String, String>? headers}) async {
    try {
      http.MultipartRequest _request =
          http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri));
      _request.headers.addAll(headers ?? mainHeaders);
      for (MultipartBody multipart in multipartBody) {
        if (foundation.kIsWeb) {
          Uint8List _list = await multipart.file.readAsBytes();
          http.MultipartFile _part = http.MultipartFile(
            multipart.key,
            multipart.file.readAsBytes().asStream(),
            _list.length,
            filename: path.basename(multipart.file.path),
            contentType: httpparse.MediaType('image', 'jpg'),
          );
          _request.files.add(_part);
        } else {
          File _file = File(multipart.file.path);
          _request.files.add(http.MultipartFile(
            multipart.key,
            _file.readAsBytes().asStream(),
            _file.lengthSync(),
            filename: _file.path.split('/').last,
          ));
        }
      }
      _request.fields.addAll(body);
      http.Response _response =
          await http.Response.fromStream(await _request.send());
      Response response = handleResponse(_response);

      return response;
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  // handle Response
  Response handleResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      log(e.toString());
      // printError(info: e.toString());
    }
    Response responseR = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );
    if (responseR.statusCode != 200 &&
        responseR.body != null &&
        responseR.body is! String) {
      if (responseR.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse errorResponse = ErrorResponse.fromJson(responseR.body);
        responseR = Response(
            statusCode: responseR.statusCode,
            body: responseR.body,
            statusText: errorResponse.errors[0].message);
      } else if (responseR.body.toString().startsWith('{message')) {
        responseR = Response(
            statusCode: responseR.statusCode,
            body: responseR.body,
            statusText: responseR.body['message']);
      }
    } else if (responseR.statusCode != 200 && responseR.body == null) {
      responseR = const Response(statusCode: 0, statusText: noInternetMessage);
    }
    return responseR;
  }

  // post multipart data
  Future<Response> putMultipartData(
      String uri, Map<String, String> body, List<MultipartBody> multipartBody,
      {Map<String, String>? headers}) async {
    try {
      http.MultipartRequest _request =
          http.MultipartRequest('PUT', Uri.parse(appBaseUrl + uri));
      _request.headers.addAll(headers ?? mainHeaders);
      for (MultipartBody multipart in multipartBody) {
        if (foundation.kIsWeb) {
          Uint8List _list = await multipart.file.readAsBytes();
          http.MultipartFile _part = http.MultipartFile(
            multipart.key,
            multipart.file.readAsBytes().asStream(),
            _list.length,
            filename: path.basename(multipart.file.path),
            contentType: httpparse.MediaType('image', 'jpg'),
          );
          _request.files.add(_part);
        } else {
          File _file = File(multipart.file.path);
          _request.files.add(http.MultipartFile(
            multipart.key,
            _file.readAsBytes().asStream(),
            _file.lengthSync(),
            filename: _file.path.split('/').last,
          ));
        }
      }
      _request.fields.addAll(body);
      http.Response _response =
          await http.Response.fromStream(await _request.send());
      Response response = handleResponse(_response);

      return response;
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }
}

class MultipartBody {
  String key;
  XFile file;

  MultipartBody(this.key, this.file);
}
