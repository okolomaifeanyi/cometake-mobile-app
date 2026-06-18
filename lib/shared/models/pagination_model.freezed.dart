// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pagination_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PaginationModel<T> {
  List<T> get data => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  /// Create a copy of PaginationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaginationModelCopyWith<T, PaginationModel<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginationModelCopyWith<T, $Res> {
  factory $PaginationModelCopyWith(
          PaginationModel<T> value, $Res Function(PaginationModel<T>) then) =
      _$PaginationModelCopyWithImpl<T, $Res, PaginationModel<T>>;
  @useResult
  $Res call({List<T> data, int page, bool hasMore, int total});
}

/// @nodoc
class _$PaginationModelCopyWithImpl<T, $Res, $Val extends PaginationModel<T>>
    implements $PaginationModelCopyWith<T, $Res> {
  _$PaginationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaginationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? page = null,
    Object? hasMore = null,
    Object? total = null,
  }) {
    return _then(_value.copyWith(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<T>,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaginationModelImplCopyWith<T, $Res>
    implements $PaginationModelCopyWith<T, $Res> {
  factory _$$PaginationModelImplCopyWith(_$PaginationModelImpl<T> value,
          $Res Function(_$PaginationModelImpl<T>) then) =
      __$$PaginationModelImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call({List<T> data, int page, bool hasMore, int total});
}

/// @nodoc
class __$$PaginationModelImplCopyWithImpl<T, $Res>
    extends _$PaginationModelCopyWithImpl<T, $Res, _$PaginationModelImpl<T>>
    implements _$$PaginationModelImplCopyWith<T, $Res> {
  __$$PaginationModelImplCopyWithImpl(_$PaginationModelImpl<T> _value,
      $Res Function(_$PaginationModelImpl<T>) _then)
      : super(_value, _then);

  /// Create a copy of PaginationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? page = null,
    Object? hasMore = null,
    Object? total = null,
  }) {
    return _then(_$PaginationModelImpl<T>(
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<T>,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$PaginationModelImpl<T> extends _PaginationModel<T> {
  const _$PaginationModelImpl(
      {required final List<T> data,
      this.page = 1,
      this.hasMore = false,
      this.total = 0})
      : _data = data,
        super._();

  final List<T> _data;
  @override
  List<T> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  @JsonKey()
  final int total;

  @override
  String toString() {
    return 'PaginationModel<$T>(data: $data, page: $page, hasMore: $hasMore, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginationModelImpl<T> &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.total, total) || other.total == total));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_data), page, hasMore, total);

  /// Create a copy of PaginationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaginationModelImplCopyWith<T, _$PaginationModelImpl<T>> get copyWith =>
      __$$PaginationModelImplCopyWithImpl<T, _$PaginationModelImpl<T>>(
          this, _$identity);
}

abstract class _PaginationModel<T> extends PaginationModel<T> {
  const factory _PaginationModel(
      {required final List<T> data,
      final int page,
      final bool hasMore,
      final int total}) = _$PaginationModelImpl<T>;
  const _PaginationModel._() : super._();

  @override
  List<T> get data;
  @override
  int get page;
  @override
  bool get hasMore;
  @override
  int get total;

  /// Create a copy of PaginationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaginationModelImplCopyWith<T, _$PaginationModelImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
