import 'dart:convert';

import 'package:dio/dio.dart' as dio;

final dio.Dio _dio = dio.Dio(
  dio.BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 20),
    validateStatus: (_) => true,
  ),
);

class Response {
  Response({required this.statusCode, required this.body});

  final int statusCode;
  final String body;

  List<int> get bodyBytes => utf8.encode(body);

  static Future<Response> fromStream(StreamedResponse streamedResponse) async {
    return Response(
      statusCode: streamedResponse.statusCode,
      body: utf8.decode(streamedResponse.bytes),
    );
  }
}

class StreamedResponse {
  StreamedResponse({required this.statusCode, required this.bytes});

  final int statusCode;
  final List<int> bytes;
}

class MultipartFile {
  MultipartFile._({required this.field, required this.filePath});

  final String field;
  final String filePath;

  static Future<MultipartFile> fromPath(String field, String filePath) async {
    return MultipartFile._(field: field, filePath: filePath);
  }
}

class MultipartRequest {
  MultipartRequest(this.method, this.url);

  final String method;
  final Uri url;
  final List<MultipartFile> files = [];
  final Map<String, String> fields = {};

  Future<StreamedResponse> send() async {
    final formDataMap = <String, dynamic>{...fields};
    for (final file in files) {
      formDataMap[file.field] = await dio.MultipartFile.fromFile(file.filePath);
    }

    final response = await _dio.request<List<int>>(
      url.toString(),
      data: dio.FormData.fromMap(formDataMap),
      options: dio.Options(
        method: method,
        responseType: dio.ResponseType.bytes,
      ),
    );

    return StreamedResponse(
      statusCode: response.statusCode ?? 500,
      bytes: response.data ?? <int>[],
    );
  }
}

Future<Response> get(Uri url, {Map<String, String>? headers}) async {
  final response = await _dio.get<String>(
    url.toString(),
    options: dio.Options(
      headers: headers,
      responseType: dio.ResponseType.plain,
    ),
  );
  return Response(
    statusCode: response.statusCode ?? 500,
    body: response.data ?? '',
  );
}

Future<Response> post(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
}) async {
  final response = await _dio.post<String>(
    url.toString(),
    data: body,
    options: dio.Options(
      headers: headers,
      responseType: dio.ResponseType.plain,
    ),
  );
  return Response(
    statusCode: response.statusCode ?? 500,
    body: response.data ?? '',
  );
}

Future<Response> put(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
}) async {
  final response = await _dio.put<String>(
    url.toString(),
    data: body,
    options: dio.Options(
      headers: headers,
      responseType: dio.ResponseType.plain,
    ),
  );
  return Response(
    statusCode: response.statusCode ?? 500,
    body: response.data ?? '',
  );
}
