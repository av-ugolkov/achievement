// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Active`
  String get active {
    return Intl.message(
      'Active',
      name: 'active',
      desc: '',
      args: [],
    );
  }

  /// `Achievement`
  String get app_name {
    return Intl.message(
      'Achievement',
      name: 'app_name',
      desc: '',
      args: [],
    );
  }

  /// `Archived`
  String get archived {
    return Intl.message(
      'Archived',
      name: 'archived',
      desc: '',
      args: [],
    );
  }

  /// `Create achievement`
  String get create_achievement {
    return Intl.message(
      'Create achievement',
      name: 'create_achievement',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message(
      'Done',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `Duration`
  String get duration_achiev {
    return Intl.message(
      'Duration',
      name: 'duration_achiev',
      desc: '',
      args: [],
    );
  }

  /// `The title cannot be less than 3 characters`
  String get error_header {
    return Intl.message(
      'The title cannot be less than 3 characters',
      name: 'error_header',
      desc: '',
      args: [],
    );
  }

  /// `Selected date in the past`
  String get error_remind_card {
    return Intl.message(
      'Selected date in the past',
      name: 'error_remind_card',
      desc: '',
      args: [],
    );
  }

  /// `Fail`
  String get fail {
    return Intl.message(
      'Fail',
      name: 'fail',
      desc: '',
      args: [],
    );
  }

  /// `Finish achiev`
  String get finish_achiev {
    return Intl.message(
      'Finish achiev',
      name: 'finish_achiev',
      desc: '',
      args: [],
    );
  }

  /// `Finished`
  String get finished {
    return Intl.message(
      'Finished',
      name: 'finished',
      desc: '',
      args: [],
    );
  }

  /// `Header`
  String get header {
    return Intl.message(
      'Header',
      name: 'header',
      desc: '',
      args: [],
    );
  }

  /// `Remind`
  String get remind {
    return Intl.message(
      'Remind',
      name: 'remind',
      desc: '',
      args: [],
    );
  }

  /// `Repeat`
  String get repeat {
    return Intl.message(
      'Repeat',
      name: 'repeat',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Start achiev`
  String get start_achiev {
    return Intl.message(
      'Start achiev',
      name: 'start_achiev',
      desc: '',
      args: [],
    );
  }

  /// `Achievement`
  String get view_achievement_title {
    return Intl.message(
      'Achievement',
      name: 'view_achievement_title',
      desc: '',
      args: [],
    );
  }

  /// `What do you do?`
  String get what_do_you_do {
    return Intl.message(
      'What do you do?',
      name: 'what_do_you_do',
      desc: '',
      args: [],
    );
  }

  /// `What do you do or not do`
  String get what_do_you_do_or_not_do {
    return Intl.message(
      'What do you do or not do',
      name: 'what_do_you_do_or_not_do',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
