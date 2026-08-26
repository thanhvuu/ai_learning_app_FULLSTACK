import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart' as dio;

class Response {
  final int statusCode;
  final String body;
  final Uint8List bodyBytes;
  final Map<String, dynamic> headers;

  Response({
    required this.statusCode,
    required this.body,
    required this.bodyBytes,
    required this.headers,
  });

  static Future<Response> fromStream(StreamedResponse streamed) async {
    return Response(
      statusCode: streamed.statusCode,
      body: utf8.decode(streamed.bytes, allowMalformed: true),
      bodyBytes: streamed.bytes,
      headers: {},
    );
  }
}

class MultipartRequest {
  final String method;
  final Uri url;
  final Map<String, String> fields = {};
  final List<dio.MultipartFile> files = [];

  MultipartRequest(this.method, this.url);

  Future<StreamedResponse> send() async {
    final client = dio.Dio();
    final formData = dio.FormData();

    fields.forEach((k, v) => formData.fields.add(MapEntry(k, v)));
    for (final file in files) {
      formData.files.add(MapEntry('file', file));
    }

    try {
      final response = await client.requestUri(
        url,
        data: formData,
        options: dio.Options(
          method: method,
          responseType: dio.ResponseType.bytes,
          validateStatus: (status) => true,
        ),
      );

      final bytes = Uint8List.fromList((response.data as List<dynamic>).cast<int>());
      return StreamedResponse(bytes, response.statusCode ?? 500);
    } catch (_) {
      return StreamedResponse(Uint8List(0), 500);
    }
  }
}

class StreamedResponse {
  final Uint8List _bytes;
  final int statusCode;

  StreamedResponse(this._bytes, this.statusCode);

  Uint8List get bytes => _bytes;
}

class MultipartFile {
  static Future<dio.MultipartFile> fromPath(String field, String filePath) async {
    return dio.MultipartFile.fromFile(filePath, filename: filePath.split(RegExp(r'[/\\]')).last);
  }

  static Future<dio.MultipartFile> fromFile(String filePath, {String? filename}) async {
    return dio.MultipartFile.fromFile(filePath, filename: filename);
  }
}

Future<Response> get(Uri url, {Map<String, String>? headers}) async {
  final client = dio.Dio();
  try {
    final response = await client.getUri(
      url,
      options: dio.Options(
        headers: headers,
        responseType: dio.ResponseType.bytes,
        validateStatus: (status) => true,
      ),
    );

    final bytes = response.data is List<int>
        ? Uint8List.fromList(response.data as List<int>)
        : Uint8List.fromList(utf8.encode(response.data.toString()));

    return Response(
      statusCode: response.statusCode ?? 500,
      body: utf8.decode(bytes, allowMalformed: true),
      bodyBytes: bytes,
      headers: response.headers.map,
    );
  } catch (e) {
    return Response(
      statusCode: 500,
      body: jsonEncode({'error': e.toString()}),
      bodyBytes: Uint8List.fromList(utf8.encode(jsonEncode({'error': e.toString()}))),
      headers: {},
    );
  }
}

Future<Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
  final client = dio.Dio();
  try {
    final response = await client.postUri(
      url,
      data: body,
      options: dio.Options(
        headers: headers,
        responseType: dio.ResponseType.bytes,
        validateStatus: (status) => true,
      ),
    );

    final bytes = response.data is List<int>
        ? Uint8List.fromList(response.data as List<int>)
        : Uint8List.fromList(utf8.encode(response.data.toString()));

    return Response(
      statusCode: response.statusCode ?? 500,
      body: utf8.decode(bytes, allowMalformed: true),
      bodyBytes: bytes,
      headers: response.headers.map,
    );
  } catch (e) {
    return Response(
      statusCode: 500,
      body: jsonEncode({'error': e.toString()}),
      bodyBytes: Uint8List.fromList(utf8.encode(jsonEncode({'error': e.toString()}))),
      headers: {},
    );
  }
}

Future<Response> put(Uri url, {Map<String, String>? headers, Object? body}) async {
  final client = dio.Dio();
  try {
    final response = await client.putUri(
      url,
      data: body,
      options: dio.Options(
        headers: headers,
        responseType: dio.ResponseType.bytes,
        validateStatus: (status) => true,
      ),
    );

    final bytes = response.data is List<int>
        ? Uint8List.fromList(response.data as List<int>)
        : Uint8List.fromList(utf8.encode(response.data.toString()));

    return Response(
      statusCode: response.statusCode ?? 500,
      body: utf8.decode(bytes, allowMalformed: true),
      bodyBytes: bytes,
      headers: response.headers.map,
    );
  } catch (e) {
    return Response(
      statusCode: 500,
      body: jsonEncode({'error': e.toString()}),
      bodyBytes: Uint8List.fromList(utf8.encode(jsonEncode({'error': e.toString()}))),
      headers: {},
    );
  }
}

Future<Response> delete(Uri url, {Map<String, String>? headers, Object? body}) async {
  final client = dio.Dio();
  try {
    final response = await client.deleteUri(
      url,
      data: body,
      options: dio.Options(
        headers: headers,
        responseType: dio.ResponseType.bytes,
        validateStatus: (status) => true,
      ),
    );

    final bytes = response.data is List<int>
        ? Uint8List.fromList(response.data as List<int>)
        : Uint8List.fromList(utf8.encode(response.data.toString()));

    return Response(
      statusCode: response.statusCode ?? 500,
      body: utf8.decode(bytes, allowMalformed: true),
      bodyBytes: bytes,
      headers: response.headers.map,
    );
  } catch (e) {
    return Response(
      statusCode: 500,
      body: jsonEncode({'error': e.toString()}),
      bodyBytes: Uint8List.fromList(utf8.encode(jsonEncode({'error': e.toString()}))),
      headers: {},
    );
  }
}
