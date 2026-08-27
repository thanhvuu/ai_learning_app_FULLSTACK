import 'package:equatable/equatable.dart';

enum MyLessonsStatus { initial, loading, success, failure }

class MyLessonsState extends Equatable {
  final MyLessonsStatus status;
  final List<Map<String, dynamic>> lessons;
  final String? errorMessage;

  const MyLessonsState({
    this.status = MyLessonsStatus.initial,
    this.lessons = const [],
    this.errorMessage,
  });

  bool get isLoading => status == MyLessonsStatus.loading;

  MyLessonsState copyWith({
    MyLessonsStatus? status,
    List<Map<String, dynamic>>? lessons,
    String? errorMessage,
  }) {
    return MyLessonsState(
      status: status ?? this.status,
      lessons: lessons ?? this.lessons,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, lessons, errorMessage];
}
