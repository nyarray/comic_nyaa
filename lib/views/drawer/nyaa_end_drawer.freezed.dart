// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nyaa_end_drawer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EndDrawerState {
  Map<int, bool> get expandState;
  double get scrollPosition;
  String get banner;

  /// Create a copy of EndDrawerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EndDrawerStateCopyWith<EndDrawerState> get copyWith =>
      _$EndDrawerStateCopyWithImpl<EndDrawerState>(
          this as EndDrawerState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EndDrawerState &&
            const DeepCollectionEquality()
                .equals(other.expandState, expandState) &&
            (identical(other.scrollPosition, scrollPosition) ||
                other.scrollPosition == scrollPosition) &&
            (identical(other.banner, banner) || other.banner == banner));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(expandState), scrollPosition, banner);

  @override
  String toString() {
    return 'EndDrawerState(expandState: $expandState, scrollPosition: $scrollPosition, banner: $banner)';
  }
}

/// @nodoc
abstract mixin class $EndDrawerStateCopyWith<$Res> {
  factory $EndDrawerStateCopyWith(
          EndDrawerState value, $Res Function(EndDrawerState) _then) =
      _$EndDrawerStateCopyWithImpl;
  @useResult
  $Res call({Map<int, bool> expandState, double scrollPosition, String banner});
}

/// @nodoc
class _$EndDrawerStateCopyWithImpl<$Res>
    implements $EndDrawerStateCopyWith<$Res> {
  _$EndDrawerStateCopyWithImpl(this._self, this._then);

  final EndDrawerState _self;
  final $Res Function(EndDrawerState) _then;

  /// Create a copy of EndDrawerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expandState = null,
    Object? scrollPosition = null,
    Object? banner = null,
  }) {
    return _then(_self.copyWith(
      expandState: null == expandState
          ? _self.expandState
          : expandState // ignore: cast_nullable_to_non_nullable
              as Map<int, bool>,
      scrollPosition: null == scrollPosition
          ? _self.scrollPosition
          : scrollPosition // ignore: cast_nullable_to_non_nullable
              as double,
      banner: null == banner
          ? _self.banner
          : banner // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [EndDrawerState].
extension EndDrawerStatePatterns on EndDrawerState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_EndDrawerState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EndDrawerState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_EndDrawerState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EndDrawerState():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_EndDrawerState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EndDrawerState() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            Map<int, bool> expandState, double scrollPosition, String banner)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EndDrawerState() when $default != null:
        return $default(_that.expandState, _that.scrollPosition, _that.banner);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            Map<int, bool> expandState, double scrollPosition, String banner)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EndDrawerState():
        return $default(_that.expandState, _that.scrollPosition, _that.banner);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            Map<int, bool> expandState, double scrollPosition, String banner)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EndDrawerState() when $default != null:
        return $default(_that.expandState, _that.scrollPosition, _that.banner);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _EndDrawerState implements EndDrawerState {
  const _EndDrawerState(
      {final Map<int, bool> expandState = const {0: true},
      this.scrollPosition = 0.0,
      this.banner = ''})
      : _expandState = expandState;

  final Map<int, bool> _expandState;
  @override
  @JsonKey()
  Map<int, bool> get expandState {
    if (_expandState is EqualUnmodifiableMapView) return _expandState;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_expandState);
  }

  @override
  @JsonKey()
  final double scrollPosition;
  @override
  @JsonKey()
  final String banner;

  /// Create a copy of EndDrawerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EndDrawerStateCopyWith<_EndDrawerState> get copyWith =>
      __$EndDrawerStateCopyWithImpl<_EndDrawerState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EndDrawerState &&
            const DeepCollectionEquality()
                .equals(other._expandState, _expandState) &&
            (identical(other.scrollPosition, scrollPosition) ||
                other.scrollPosition == scrollPosition) &&
            (identical(other.banner, banner) || other.banner == banner));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_expandState),
      scrollPosition,
      banner);

  @override
  String toString() {
    return 'EndDrawerState(expandState: $expandState, scrollPosition: $scrollPosition, banner: $banner)';
  }
}

/// @nodoc
abstract mixin class _$EndDrawerStateCopyWith<$Res>
    implements $EndDrawerStateCopyWith<$Res> {
  factory _$EndDrawerStateCopyWith(
          _EndDrawerState value, $Res Function(_EndDrawerState) _then) =
      __$EndDrawerStateCopyWithImpl;
  @override
  @useResult
  $Res call({Map<int, bool> expandState, double scrollPosition, String banner});
}

/// @nodoc
class __$EndDrawerStateCopyWithImpl<$Res>
    implements _$EndDrawerStateCopyWith<$Res> {
  __$EndDrawerStateCopyWithImpl(this._self, this._then);

  final _EndDrawerState _self;
  final $Res Function(_EndDrawerState) _then;

  /// Create a copy of EndDrawerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? expandState = null,
    Object? scrollPosition = null,
    Object? banner = null,
  }) {
    return _then(_EndDrawerState(
      expandState: null == expandState
          ? _self._expandState
          : expandState // ignore: cast_nullable_to_non_nullable
              as Map<int, bool>,
      scrollPosition: null == scrollPosition
          ? _self.scrollPosition
          : scrollPosition // ignore: cast_nullable_to_non_nullable
              as double,
      banner: null == banner
          ? _self.banner
          : banner // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
