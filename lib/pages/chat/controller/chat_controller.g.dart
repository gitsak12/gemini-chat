// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatMessageControllerHash() =>
    r'72f330efcd52bfc2b334d772233943b2061ddede';

/// See also [ChatMessageController].
@ProviderFor(ChatMessageController)
final chatMessageControllerProvider =
    NotifierProvider<ChatMessageController, List<Message>>.internal(
  ChatMessageController.new,
  name: r'chatMessageControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatMessageControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChatMessageController = Notifier<List<Message>>;
String _$geminiModelHash() => r'db6d5f9df0c6727c02d377c652e5334e48bf7148';

/// See also [GeminiModel].
@ProviderFor(GeminiModel)
final geminiModelProvider =
    NotifierProvider<GeminiModel, GenerativeModel>.internal(
  GeminiModel.new,
  name: r'geminiModelProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$geminiModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GeminiModel = Notifier<GenerativeModel>;
String _$chatIdHash() => r'9006d33434f66c6f3f095b04296c7f4ebfb616e5';

/// See also [ChatId].
@ProviderFor(ChatId)
final chatIdProvider = NotifierProvider<ChatId, String>.internal(
  ChatId.new,
  name: r'chatIdProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$chatIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChatId = Notifier<String>;
String _$messageLoaderHash() => r'3635bd8a1c6103e4ebe0f5a4efdb2102508e285e';

/// See also [MessageLoader].
@ProviderFor(MessageLoader)
final messageLoaderProvider = NotifierProvider<MessageLoader, bool>.internal(
  MessageLoader.new,
  name: r'messageLoaderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$messageLoaderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MessageLoader = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
