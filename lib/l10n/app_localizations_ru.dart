// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Поиск сообщений...';

  @override
  String get search => 'Поиск';

  @override
  String get clearSearch => 'Очистить поиск';

  @override
  String get closeSearch => 'Закрыть поиск';

  @override
  String get moreOptions => 'Ещё';

  @override
  String get back => 'Назад';

  @override
  String get homeNewGroup => 'Новая группа';

  @override
  String get homeSettings => 'Настройки';

  @override
  String get homeSearching => 'Поиск сообщений...';

  @override
  String get homeNoResults => 'Ничего не найдено';

  @override
  String get homeNoChatHistory => 'История чатов пуста';

  @override
  String homeTransportSwitched(String address) {
    return 'Транспорт переключён → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name звонит...';
  }

  @override
  String get homeAccept => 'Принять';

  @override
  String get homeDecline => 'Отклонить';

  @override
  String get homeLoadEarlier => 'Загрузить ранние сообщения';

  @override
  String get chatFileTooLargeGroup =>
      'Файлы больше 512 КБ не поддерживаются в групповых чатах';

  @override
  String get chatLargeFile => 'Большой файл';

  @override
  String get chatCancel => 'Отмена';

  @override
  String get chatSend => 'Отправить';

  @override
  String get chatFileTooLarge => 'Файл слишком большой — максимум 100 МБ';

  @override
  String get chatMicDenied => 'Доступ к микрофону запрещён';

  @override
  String get chatVoiceFailed =>
      'Не удалось сохранить голосовое сообщение — проверьте свободное место';

  @override
  String get chatScheduleFuture =>
      'Запланированное время должно быть в будущем';

  @override
  String get chatToday => 'Сегодня';

  @override
  String get chatYesterday => 'Вчера';

  @override
  String get chatEdited => 'изменено';

  @override
  String get chatYou => 'Вы';

  @override
  String get appBarOnline => 'в сети';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'печатает';

  @override
  String get appBarSearchMessages => 'Поиск сообщений...';

  @override
  String get appBarMute => 'Отключить звук';

  @override
  String get appBarUnmute => 'Включить звук';

  @override
  String get appBarMedia => 'Медиа';

  @override
  String get appBarDisappearing => 'Исчезающие сообщения';

  @override
  String get appBarDisappearingOn => 'Исчезающие: вкл';

  @override
  String get appBarGroupSettings => 'Настройки группы';

  @override
  String get appBarSearchTooltip => 'Поиск сообщений';

  @override
  String get appBarVoiceCall => 'Голосовой звонок';

  @override
  String get appBarVideoCall => 'Видеозвонок';

  @override
  String get inputMessage => 'Сообщение...';

  @override
  String get inputAttachFile => 'Прикрепить файл';

  @override
  String get inputSendMessage => 'Отправить сообщение';

  @override
  String get inputRecordVoice => 'Записать голосовое сообщение';

  @override
  String get inputSendVoice => 'Отправить голосовое сообщение';

  @override
  String get inputCancelReply => 'Отменить ответ';

  @override
  String get inputCancelEdit => 'Отменить редактирование';

  @override
  String get inputCancelRecording => 'Отменить запись';

  @override
  String get inputRecording => 'Запись…';

  @override
  String get inputEditingMessage => 'Редактирование сообщения';

  @override
  String get inputPhoto => 'Фото';

  @override
  String get inputVoiceMessage => 'Голосовое сообщение';

  @override
  String get inputFile => 'Файл';

  @override
  String inputScheduledMessages(int count) {
    return '$count запланированных сообщений';
  }

  @override
  String get callInitializing => 'Инициализация звонка…';

  @override
  String get callConnecting => 'Подключение…';

  @override
  String get callConnectingRelay => 'Подключение (реле)…';

  @override
  String get callSwitchingRelay => 'Переключение на реле…';

  @override
  String get callConnectionFailed => 'Ошибка подключения';

  @override
  String get callReconnecting => 'Переподключение…';

  @override
  String get callEnded => 'Звонок завершён';

  @override
  String get callLive => 'Онлайн';

  @override
  String get callEnd => 'Завершить';

  @override
  String get callEndCall => 'Завершить звонок';

  @override
  String get callMute => 'Выкл. микрофон';

  @override
  String get callUnmute => 'Вкл. микрофон';

  @override
  String get callSpeaker => 'Динамик';

  @override
  String get callCameraOn => 'Камера вкл';

  @override
  String get callCameraOff => 'Камера выкл';

  @override
  String get callShareScreen => 'Показать экран';

  @override
  String get callStopShare => 'Остановить показ';

  @override
  String callTorBackup(String duration) {
    return 'Tor резерв · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor резерв активен — основной путь недоступен';

  @override
  String get callDirectFailed =>
      'Прямое подключение не удалось — переключение на реле…';

  @override
  String get callTurnUnreachable =>
      'TURN-серверы недоступны. Добавьте TURN в Настройки → Дополнительно.';

  @override
  String get callRelayMode => 'Релейный режим (ограниченная сеть)';

  @override
  String get noConnection => 'Нет подключения — сообщения будут в очереди';

  @override
  String get connected => 'Подключено';

  @override
  String get connecting => 'Подключение…';

  @override
  String get disconnected => 'Отключено';

  @override
  String get jitsiWarningTitle => 'Не зашифровано сквозным шифрованием';

  @override
  String get jitsiWarningBody =>
      'Звонки Jitsi Meet не шифруются Pulse. Используйте только для неконфиденциальных разговоров.';

  @override
  String get jitsiConfirm => 'Всё равно присоединиться';

  @override
  String get retry => 'Повторить';
}
