import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ai_learning_app/src/common/enum/language_code.dart';

class LanguageState extends Equatable {
  final LanguageCode language;

  const LanguageState({this.language = LanguageCode.vi});

  Locale get locale => language.locale;
  String get languageCode => language.code;
  String get languageName => language.displayName;

  LanguageState copyWith({LanguageCode? language}) {
    return LanguageState(language: language ?? this.language);
  }

  @override
  List<Object?> get props => [language];
}
