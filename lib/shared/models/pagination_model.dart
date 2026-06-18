import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_model.freezed.dart';

@freezed
class PaginationModel<T> with _$PaginationModel<T> {
  const factory PaginationModel({
    required List<T> data,
    @Default(1) int page,
    @Default(false) bool hasMore,
    @Default(0) int total,
  }) = _PaginationModel<T>;

  const PaginationModel._();

  PaginationModel<T> append(List<T> newData, {required bool hasMore}) {
    return copyWith(
      data: [...data, ...newData],
      page: page + 1,
      hasMore: hasMore,
      total: total + newData.length,
    );
  }
}
