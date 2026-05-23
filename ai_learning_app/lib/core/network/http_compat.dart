import 'dart:convert';

import 'package:dio/dio.dart';

final Dio _dio = Dio();

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
      formDataMap[file.field] = await DioMultipartFile.fromFile(file.filePath);
    }

    final response = await _dio.request<List<int>>(
      url.toString(),
      data: FormData.fromMap(formDataMap),
      options: Options(
        method: method,
        responseType: ResponseType.bytes,
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
    options: Options(headers: headers, responseType: ResponseType.plain),
  );
  return Response(
    statusCode: response.statusCode ?? 500,
    body: response.data ?? '',
  );
}

Future<Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
  final response = await _dio.post<String>(
    url.toString(),
    data: body,
    options: Options(headers: headers, responseType: ResponseType.plain),
  );
  return Response(
    statusCode: response.statusCode ?? 500,
    body: response.data ?? '',
  );
}

Future<Response> put(Uri url, {Map<String, String>? headers, Object? body}) async {
  final response = await _dio.put<String>(
    url.toString(),
    data: body,
    options: Options(headers: headers, responseType: ResponseType.plain),
  );
  return Response(
    statusCode: response.statusCode ?? 500,
    body: response.data ?? '',
  );
}
