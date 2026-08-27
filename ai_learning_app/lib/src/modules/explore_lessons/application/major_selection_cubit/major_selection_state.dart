import 'package:equatable/equatable.dart';

enum MajorSelectionStatus { initial, loading, success, failure }

class MajorSelectionState extends Equatable {
  final MajorSelectionStatus status;
  final String? selectedMajor;
  final String? errorMessage;

  const MajorSelectionState({
    this.status = MajorSelectionStatus.initial,
    this.selectedMajor,
    this.errorMessage,
  });

  bool get isLoading => status == MajorSelectionStatus.loading;
  bool get isSuccess => status == MajorSelectionStatus.success;

  MajorSelectionState copyWith({
    MajorSelectionStatus? status,
    String? selectedMajor,
    String? errorMessage,
  }) {
    return MajorSelectionState(
      status: status ?? this.status,
      selectedMajor: selectedMajor ?? this.selectedMajor,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, selectedMajor, errorMessage];
}
