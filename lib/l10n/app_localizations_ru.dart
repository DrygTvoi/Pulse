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
  String get cancel => 'Отмена';

  @override
  String get close => 'Закрыть';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get remove => 'Удалить';

  @override
  String get save => 'Сохранить';

  @override
  String get add => 'Добавить';

  @override
  String get copy => 'Копировать';

  @override
  String get skip => 'Пропустить';

  @override
  String get done => 'Готово';

  @override
  String get apply => 'Применить';

  @override
  String get export => 'Экспорт';

  @override
  String get import => 'Импорт';

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
  String get homeChats => 'Чаты';

  @override
  String get homeSelectConversation => 'Выберите диалог';

  @override
  String get homeNoChatsYet => 'Нет чатов';

  @override
  String get homeAddContactToStart => 'Добавьте контакт, чтобы начать';

  @override
  String get homeNewChat => 'Новый чат';

  @override
  String get homeNewChatTooltip => 'Новый чат';

  @override
  String get homeIncomingCallTitle => 'Входящий звонок';

  @override
  String get homeIncomingGroupCallTitle => 'Входящий групповой звонок';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — входящий групповой звонок';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Нет чатов, содержащих \"$query\"';
  }

  @override
  String get homeSectionChats => 'Чаты';

  @override
  String get homeSectionMessages => 'Сообщения';

  @override
  String get homeDbEncryptionUnavailable =>
      'Шифрование БД недоступно — установите SQLCipher для полной защиты';

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
  String chatLargeFileSizeWarning(String size) {
    return 'Этот файл занимает $size МБ. Отправка больших файлов может быть медленной. Продолжить?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Ключ безопасности $name изменился. Нажмите для проверки.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Не удалось зашифровать сообщение для $name — сообщение не отправлено.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Номер безопасности изменился для $name. Нажмите для проверки.';
  }

  @override
  String get chatNoMessagesFound => 'Сообщения не найдены';

  @override
  String get chatMessagesE2ee => 'Сообщения зашифрованы сквозным шифрованием';

  @override
  String get chatSayHello => 'Поздоровайтесь';

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
  String get callStarting => 'Начинаем звонок…';

  @override
  String get callConnectingToGroup => 'Подключение к группе…';

  @override
  String get callGroupOpenedInBrowser => 'Групповой звонок открыт в браузере';

  @override
  String get callCouldNotOpenBrowser => 'Не удалось открыть браузер';

  @override
  String get callInviteLinkSent =>
      'Ссылка-приглашение отправлена всем участникам группы.';

  @override
  String get callOpenLinkManually =>
      'Откройте ссылку вручную или нажмите для повтора.';

  @override
  String get callJitsiNotE2ee =>
      'Jitsi-звонки НЕ зашифрованы сквозным шифрованием';

  @override
  String get callRetryOpenBrowser => 'Повторить открытие браузера';

  @override
  String get callClose => 'Закрыть';

  @override
  String get callCamOn => 'Камера вкл';

  @override
  String get callCamOff => 'Камера выкл';

  @override
  String get noConnection => 'Нет подключения — сообщения будут в очереди';

  @override
  String get connected => 'Подключено';

  @override
  String get connecting => 'Подключение…';

  @override
  String get disconnected => 'Отключено';

  @override
  String get offlineBanner =>
      'Нет соединения — сообщения отправятся при восстановлении связи';

  @override
  String get lanModeBanner =>
      'LAN-режим — нет интернета · только локальная сеть';

  @override
  String get probeCheckingNetwork => 'Проверка сетевого подключения…';

  @override
  String get probeDiscoveringRelays => 'Поиск реле через каталоги…';

  @override
  String get probeStartingTor => 'Запуск Tor…';

  @override
  String get probeFindingRelaysTor => 'Поиск доступных реле через Tor…';

  @override
  String probeNetworkReady(int count) {
    return 'Сеть готова — найдено $count реле';
  }

  @override
  String get probeNoRelaysFound =>
      'Доступных реле не найдено — сообщения могут задерживаться';

  @override
  String get jitsiWarningTitle => 'Не зашифровано сквозным шифрованием';

  @override
  String get jitsiWarningBody =>
      'Звонки Jitsi Meet не шифруются Pulse. Используйте только для неконфиденциальных разговоров.';

  @override
  String get jitsiConfirm => 'Всё равно присоединиться';

  @override
  String get jitsiGroupWarningTitle => 'Не зашифровано сквозным шифрованием';

  @override
  String get jitsiGroupWarningBody =>
      'Слишком много участников для зашифрованной сетки.\n\nСсылка Jitsi Meet будет открыта в браузере. Jitsi НЕ использует сквозное шифрование — сервер может видеть ваш звонок.';

  @override
  String get jitsiContinueAnyway => 'Всё равно продолжить';

  @override
  String get retry => 'Повторить';

  @override
  String get setupCreateAnonymousAccount => 'Создайте анонимный аккаунт';

  @override
  String get setupTapToChangeColor => 'Нажмите чтобы сменить цвет';

  @override
  String get setupYourNickname => 'Ваш псевдоним';

  @override
  String get setupRecoveryPassword => 'Пароль восстановления (мин. 16)';

  @override
  String get setupConfirmPassword => 'Повторите пароль';

  @override
  String get setupMin16Chars => 'Минимум 16 символов';

  @override
  String get setupPasswordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get setupEntropyWeak => 'Слабый';

  @override
  String get setupEntropyOk => 'Средний';

  @override
  String get setupEntropyStrong => 'Сильный';

  @override
  String get setupEntropyWeakNeedsVariety => 'Слабый (нужно 3 типа символов)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits бит)';
  }

  @override
  String get setupPasswordWarning =>
      'Этот пароль — единственный способ восстановить аккаунт. Нет сервера — нет сброса пароля. Запомните или запишите его.';

  @override
  String get setupCreateAccount => 'Создать аккаунт';

  @override
  String get setupAlreadyHaveAccount => 'Уже есть аккаунт? ';

  @override
  String get setupRestore => 'Восстановить →';

  @override
  String get restoreTitle => 'Восстановление аккаунта';

  @override
  String get restoreInfoBanner =>
      'Введите пароль восстановления — ваш адрес (Nostr + Session) будет восстановлен автоматически. Контакты и сообщения хранились только локально.';

  @override
  String get restoreNewNickname => 'Новый псевдоним (можно изменить)';

  @override
  String get restoreButton => 'Восстановить аккаунт';

  @override
  String get lockTitle => 'Pulse заблокирован';

  @override
  String get lockSubtitle => 'Введите пароль для продолжения';

  @override
  String get lockPasswordHint => 'Пароль';

  @override
  String get lockUnlock => 'Разблокировать';

  @override
  String get lockPanicHint =>
      'Забыли пароль? Введите паник-ключ для удаления всех данных.';

  @override
  String get lockTooManyAttempts =>
      'Слишком много попыток. Удаление всех данных…';

  @override
  String get lockWrongPassword => 'Неверный пароль';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Неверный пароль — $attempts/$max попыток';
  }

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingGetStarted => 'Начать';

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать в Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Децентрализованный мессенджер со сквозным шифрованием.\n\nНикаких центральных серверов. Никакого сбора данных. Никаких бэкдоров.\nВаши разговоры принадлежат только вам.';

  @override
  String get onboardingTransportTitle => 'Транспорт-агностик';

  @override
  String get onboardingTransportBody =>
      'Используйте Firebase, Nostr или оба одновременно.\n\nСообщения маршрутизируются автоматически. Встроенная поддержка Tor и I2P для обхода цензуры.';

  @override
  String get onboardingSignalTitle => 'Signal + постквантовое';

  @override
  String get onboardingSignalBody =>
      'Каждое сообщение зашифровано протоколом Signal (Double Ratchet + X3DH) для прямой секретности.\n\nДополнительно обёрнуто Kyber-1024 — стандарт NIST для постквантовой защиты от будущих квантовых компьютеров.';

  @override
  String get onboardingKeysTitle => 'Вы владеете ключами';

  @override
  String get onboardingKeysBody =>
      'Ваши ключи никогда не покидают устройство.\n\nОтпечатки Signal позволяют верифицировать контакты. TOFU автоматически обнаруживает смену ключей.';

  @override
  String get onboardingThemeTitle => 'Выберите оформление';

  @override
  String get onboardingThemeBody =>
      'Выберите тему и акцентный цвет. Вы всегда можете изменить это в настройках.';

  @override
  String get contactsNewChat => 'Новый чат';

  @override
  String get contactsAddContact => 'Добавить контакт';

  @override
  String get contactsSearchHint => 'Поиск...';

  @override
  String get contactsNewGroup => 'Новая группа';

  @override
  String get contactsNoContactsYet => 'Нет контактов';

  @override
  String get contactsAddHint => 'Нажмите + чтобы добавить адрес';

  @override
  String get contactsNoMatch => 'Нет совпадений';

  @override
  String get contactsRemoveTitle => 'Удалить контакт';

  @override
  String contactsRemoveMessage(String name) {
    return 'Удалить $name?';
  }

  @override
  String get contactsRemove => 'Удалить';

  @override
  String contactsCount(int count) {
    return '$count контактов';
  }

  @override
  String get bubbleOpenLink => 'Открыть ссылку';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Открыть этот URL в браузере?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Открыть';

  @override
  String get bubbleSecurityWarning => 'Предупреждение безопасности';

  @override
  String bubbleExecutableWarning(String name) {
    return '«$name» — исполняемый файл. Сохранение и запуск могут навредить устройству. Сохранить?';
  }

  @override
  String get bubbleSaveAnyway => 'Сохранить';

  @override
  String bubbleSavedTo(String path) {
    return 'Сохранено в $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Ошибка сохранения: $error';
  }

  @override
  String get bubbleNotEncrypted => 'НЕ ЗАШИФРОВАНО';

  @override
  String get bubbleCorruptedImage => '[Повреждённое изображение]';

  @override
  String get bubbleReplyPhoto => 'Фото';

  @override
  String get bubbleReplyVoice => 'Голосовое сообщение';

  @override
  String bubbleReadBy(String names) {
    return 'Прочитано: $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Прочитано: $count';
  }

  @override
  String get chatTileTapToStart => 'Нажмите чтобы начать чат';

  @override
  String get chatTileMessageSent => 'Сообщение отправлено';

  @override
  String get chatTileEncryptedMessage => 'Зашифрованное сообщение';

  @override
  String chatTileYouPrefix(String text) {
    return 'Вы: $text';
  }

  @override
  String get bannerEncryptedMessage => 'Зашифрованное сообщение';

  @override
  String get groupNewGroup => 'Новая группа';

  @override
  String get groupGroupName => 'Название группы';

  @override
  String get groupSelectMembers => 'Выберите участников (мин. 2)';

  @override
  String get groupNoContactsYet => 'Нет контактов. Сначала добавьте контакты.';

  @override
  String get groupCreate => 'Создать';

  @override
  String get groupLabel => 'Группа';

  @override
  String get profileVerifyIdentity => 'Проверка личности';

  @override
  String profileVerifyInstructions(String name) {
    return 'Сравните эти отпечатки с $name по голосовому звонку или лично. Если оба значения совпадают на обоих устройствах, нажмите «Отметить как проверенный».';
  }

  @override
  String get profileTheirKey => 'Их ключ';

  @override
  String get profileYourKey => 'Ваш ключ';

  @override
  String get profileRemoveVerification => 'Снять проверку';

  @override
  String get profileMarkAsVerified => 'Отметить как проверенный';

  @override
  String get profileAddressCopied => 'Адрес скопирован';

  @override
  String get profileNoContactsToAdd =>
      'Нет контактов для добавления — все уже являются участниками';

  @override
  String get profileAddMembers => 'Добавить участников';

  @override
  String profileAddCount(int count) {
    return 'Добавить ($count)';
  }

  @override
  String get profileRenameGroup => 'Переименовать группу';

  @override
  String get profileRename => 'Переименовать';

  @override
  String get profileRemoveMember => 'Удалить участника?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Удалить $name из этой группы?';
  }

  @override
  String get profileKick => 'Исключить';

  @override
  String get profileSignalFingerprints => 'Отпечатки Signal';

  @override
  String get profileVerified => 'ПРОВЕРЕН';

  @override
  String get profileVerify => 'Проверить';

  @override
  String get profileEdit => 'Изменить';

  @override
  String get profileNoSession =>
      'Сессия ещё не установлена — сначала отправьте сообщение.';

  @override
  String get profileFingerprintCopied => 'Отпечаток скопирован';

  @override
  String profileMemberCount(int count) {
    return '$count участников';
  }

  @override
  String get profileVerifySafetyNumber => 'Проверить код безопасности';

  @override
  String get profileShowContactQr => 'Показать QR контакта';

  @override
  String profileContactAddress(String name) {
    return 'Адрес $name';
  }

  @override
  String get profileExportChatHistory => 'Экспорт истории чата';

  @override
  String profileSavedTo(String path) {
    return 'Сохранено в $path';
  }

  @override
  String get profileExportFailed => 'Ошибка экспорта';

  @override
  String get profileClearChatHistory => 'Очистить историю чата';

  @override
  String get profileDeleteGroup => 'Удалить группу';

  @override
  String get profileDeleteContact => 'Удалить контакт';

  @override
  String get transferTitle => 'Перенос на другое устройство';

  @override
  String get transferInfoBox =>
      'Перенесите свою Signal-личность и ключи Nostr на новое устройство.\nСессии чатов НЕ переносятся — прямая секретность сохраняется.';

  @override
  String get transferSendFromThis => 'Отправить с этого устройства';

  @override
  String get transferSendSubtitle =>
      'На этом устройстве ключи. Поделитесь кодом с новым устройством.';

  @override
  String get transferReceiveOnThis => 'Получить на этом устройстве';

  @override
  String get transferReceiveSubtitle =>
      'Это новое устройство. Введите код со старого устройства.';

  @override
  String get transferChooseMethod => 'Выберите метод переноса';

  @override
  String get transferLan => 'LAN (одна сеть)';

  @override
  String get transferLanSubtitle =>
      'Быстро, напрямую. Оба устройства должны быть в одной Wi-Fi.';

  @override
  String get transferNostrRelay => 'Nostr-реле';

  @override
  String get transferNostrRelaySubtitle =>
      'Работает через любую сеть используя существующее Nostr-реле.';

  @override
  String get transferRelayUrl => 'URL реле';

  @override
  String get transferEnterCode => 'Введите код переноса';

  @override
  String get transferPasteCode => 'Вставьте код LAN:... или NOS:... сюда';

  @override
  String get transferConnect => 'Подключиться';

  @override
  String get transferGenerating => 'Генерация кода переноса…';

  @override
  String get transferShareCode => 'Поделитесь этим кодом с получателем:';

  @override
  String get transferCopyCode => 'Копировать код';

  @override
  String get transferCodeCopied => 'Код скопирован в буфер обмена';

  @override
  String get transferWaitingReceiver => 'Ожидание подключения получателя…';

  @override
  String get transferConnectingSender => 'Подключение к отправителю…';

  @override
  String get transferVerifyBoth =>
      'Сравните этот код на обоих устройствах.\nЕсли они совпадают, перенос безопасен.';

  @override
  String get transferComplete => 'Перенос завершён';

  @override
  String get transferKeysImported => 'Ключи импортированы';

  @override
  String get transferCompleteSenderBody =>
      'Ваши ключи остаются активными на этом устройстве.\nПолучатель теперь может использовать вашу личность.';

  @override
  String get transferCompleteReceiverBody =>
      'Ключи успешно импортированы.\nПерезапустите приложение для применения новой личности.';

  @override
  String get transferRestartApp => 'Перезапустить';

  @override
  String get transferFailed => 'Ошибка переноса';

  @override
  String get transferTryAgain => 'Попробовать снова';

  @override
  String get transferEnterRelayFirst => 'Сначала введите URL реле';

  @override
  String get transferPasteCodeFromSender =>
      'Вставьте код переноса от отправителя';

  @override
  String get menuReply => 'Ответить';

  @override
  String get menuForward => 'Переслать';

  @override
  String get menuReact => 'Реакция';

  @override
  String get menuCopy => 'Копировать';

  @override
  String get menuEdit => 'Редактировать';

  @override
  String get menuRetry => 'Повторить';

  @override
  String get menuCancelScheduled => 'Отменить отправку';

  @override
  String get menuDelete => 'Удалить';

  @override
  String get menuForwardTo => 'Переслать…';

  @override
  String menuForwardedTo(String name) {
    return 'Переслано $name';
  }

  @override
  String get menuScheduledMessages => 'Запланированные сообщения';

  @override
  String get menuNoScheduledMessages => 'Нет запланированных сообщений';

  @override
  String menuSendsOn(String date) {
    return 'Отправка $date';
  }

  @override
  String get menuDisappearingMessages => 'Исчезающие сообщения';

  @override
  String get menuDisappearingSubtitle =>
      'Сообщения автоматически удаляются через выбранное время.';

  @override
  String get menuTtlOff => 'Выкл';

  @override
  String get menuTtl1h => '1 час';

  @override
  String get menuTtl24h => '24 часа';

  @override
  String get menuTtl7d => '7 дней';

  @override
  String get menuAttachPhoto => 'Фото';

  @override
  String get menuAttachFile => 'Файл';

  @override
  String get mediaTitle => 'Медиа';

  @override
  String mediaPhotosTab(int count) {
    return 'Фото ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Файлы ($count)';
  }

  @override
  String get mediaNoPhotos => 'Нет фотографий';

  @override
  String get mediaNoFiles => 'Нет файлов';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Сохранено в Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'Не удалось сохранить файл';

  @override
  String get statusNewStatus => 'Новый статус';

  @override
  String get statusPublish => 'Опубликовать';

  @override
  String get statusExpiresIn24h => 'Статус исчезает через 24 часа';

  @override
  String get statusWhatsOnYourMind => 'О чём вы думаете?';

  @override
  String get statusPhotoAttached => 'Фото прикреплено';

  @override
  String get statusAttachPhoto => 'Прикрепить фото (необязательно)';

  @override
  String get statusEnterText => 'Введите текст для вашего статуса.';

  @override
  String get panicSetPanicKey => 'Установить паник-ключ';

  @override
  String get panicEmergencySelfDestruct => 'Экстренное самоуничтожение';

  @override
  String get panicIrreversible => 'Это действие необратимо';

  @override
  String get panicWarningBody =>
      'Ввод этого ключа на экране блокировки мгновенно стирает ВСЕ данные — сообщения, контакты, ключи, личность. Используйте ключ, отличный от обычного пароля.';

  @override
  String get panicKeyHint => 'Паник-ключ';

  @override
  String get panicConfirmHint => 'Подтвердите паник-ключ';

  @override
  String get panicMinChars => 'Паник-ключ должен быть не менее 4 символов';

  @override
  String get panicKeysDoNotMatch => 'Ключи не совпадают';

  @override
  String get passwordSetAppPassword => 'Установить пароль';

  @override
  String get passwordProtectsMessages => 'Защищает ваши сообщения';

  @override
  String get passwordInfoBanner =>
      'Требуется при каждом запуске Pulse. Если забудете, данные не могут быть восстановлены.';

  @override
  String get passwordHint => 'Пароль';

  @override
  String get passwordConfirmHint => 'Подтвердите пароль';

  @override
  String get passwordSetButton => 'Установить пароль';

  @override
  String get passwordSkipForNow => 'Пропустить';

  @override
  String get passwordMinChars => 'Пароль должен быть не менее 6 символов';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get profileCardSaved => 'Профиль сохранён!';

  @override
  String get profileCardE2eeIdentity => 'E2EE-личность';

  @override
  String get profileCardDisplayName => 'Отображаемое имя';

  @override
  String get profileCardDisplayNameHint => 'напр. Иван Иванов';

  @override
  String get profileCardAbout => 'О себе';

  @override
  String get profileCardSaveProfile => 'Сохранить профиль';

  @override
  String get profileCardYourName => 'Ваше имя';

  @override
  String get profileCardAddressCopied => 'Адрес скопирован!';

  @override
  String get profileCardInboxAddress => 'Ваш адрес входящих';

  @override
  String get profileCardInboxAddresses => 'Ваши адреса входящих';

  @override
  String get profileCardShareAllAddresses =>
      'Поделиться всеми адресами (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Поделитесь с контактами, чтобы они могли вам написать.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Все $count адресов скопированы как одна ссылка!';
  }

  @override
  String get settingsMyProfile => 'Мой профиль';

  @override
  String get settingsYourInboxAddress => 'Ваш адрес входящих';

  @override
  String get settingsMyQrCode => 'Мой QR-код';

  @override
  String get settingsMyQrSubtitle => 'Поделитесь адресом как сканируемым QR';

  @override
  String get settingsShareMyAddress => 'Поделиться адресом';

  @override
  String get settingsNoAddressYet => 'Нет адреса — сначала сохраните настройки';

  @override
  String get settingsInviteLink => 'Ссылка-приглашение';

  @override
  String get settingsRawAddress => 'Адрес';

  @override
  String get settingsCopyLink => 'Копировать ссылку';

  @override
  String get settingsCopyAddress => 'Копировать адрес';

  @override
  String get settingsInviteLinkCopied => 'Ссылка-приглашение скопирована';

  @override
  String get settingsAppearance => 'Внешний вид';

  @override
  String get settingsThemeEngine => 'Тема оформления';

  @override
  String get settingsThemeEngineSubtitle => 'Настройте цвета и шрифты';

  @override
  String get settingsSignalProtocol => 'Протокол Signal';

  @override
  String get settingsSignalProtocolSubtitle => 'Ключи E2EE хранятся надёжно';

  @override
  String get settingsActive => 'АКТИВЕН';

  @override
  String get settingsIdentityBackup => 'Резервная копия личности';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Экспорт или импорт Signal-личности';

  @override
  String get settingsIdentityBackupBody =>
      'Экспортируйте ключи Signal-личности в резервный код или восстановите из существующего.';

  @override
  String get settingsTransferDevice => 'Перенос на другое устройство';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Перенесите личность через LAN или Nostr-реле';

  @override
  String get settingsExportIdentity => 'Экспорт личности';

  @override
  String get settingsExportIdentityBody =>
      'Скопируйте этот резервный код и сохраните его надёжно:';

  @override
  String get settingsSaveFile => 'Сохранить файл';

  @override
  String get settingsImportIdentity => 'Импорт личности';

  @override
  String get settingsImportIdentityBody =>
      'Вставьте резервный код ниже. Это перезапишет вашу текущую личность.';

  @override
  String get settingsPasteBackupCode => 'Вставьте резервный код…';

  @override
  String get settingsIdentityImported =>
      'Личность + контакты импортированы! Перезапустите приложение.';

  @override
  String get settingsSecurity => 'Безопасность';

  @override
  String get settingsAppPassword => 'Пароль приложения';

  @override
  String get settingsPasswordEnabled =>
      'Включён — требуется при каждом запуске';

  @override
  String get settingsPasswordDisabled =>
      'Отключён — приложение открывается без пароля';

  @override
  String get settingsChangePassword => 'Изменить пароль';

  @override
  String get settingsChangePasswordSubtitle => 'Обновите пароль блокировки';

  @override
  String get settingsSetPanicKey => 'Установить паник-ключ';

  @override
  String get settingsChangePanicKey => 'Изменить паник-ключ';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Обновить ключ экстренного стирания';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Один ключ мгновенно стирает все данные';

  @override
  String get settingsRemovePanicKey => 'Удалить паник-ключ';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Отключить экстренное самоуничтожение';

  @override
  String get settingsRemovePanicKeyBody =>
      'Экстренное самоуничтожение будет отключено. Вы можете включить его в любое время.';

  @override
  String get settingsDisableAppPassword => 'Отключить пароль';

  @override
  String get settingsEnterCurrentPassword =>
      'Введите текущий пароль для подтверждения';

  @override
  String get settingsCurrentPassword => 'Текущий пароль';

  @override
  String get settingsIncorrectPassword => 'Неверный пароль';

  @override
  String get settingsPasswordUpdated => 'Пароль обновлён';

  @override
  String get settingsChangePasswordProceed =>
      'Введите текущий пароль для продолжения';

  @override
  String get settingsData => 'Данные';

  @override
  String get settingsBackupMessages => 'Резервная копия сообщений';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Экспорт зашифрованной истории сообщений в файл';

  @override
  String get settingsRestoreMessages => 'Восстановить сообщения';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Импорт сообщений из файла резервной копии';

  @override
  String get settingsExportKeys => 'Экспорт ключей';

  @override
  String get settingsExportKeysSubtitle =>
      'Сохранить ключи личности в зашифрованный файл';

  @override
  String get settingsImportKeys => 'Импорт ключей';

  @override
  String get settingsImportKeysSubtitle =>
      'Восстановить ключи личности из экспортированного файла';

  @override
  String get settingsBackupPassword => 'Пароль резервной копии';

  @override
  String get settingsPasswordCannotBeEmpty => 'Пароль не может быть пустым';

  @override
  String get settingsPasswordMin4Chars =>
      'Пароль должен быть не менее 4 символов';

  @override
  String get settingsCallsTurn => 'Звонки и TURN';

  @override
  String get settingsLocalNetwork => 'Локальная сеть';

  @override
  String get settingsCensorshipResistance => 'Обход цензуры';

  @override
  String get settingsLanFallback => 'LAN-резерв';

  @override
  String get settingsLanFallbackSubtitle =>
      'Обнаруживать присутствие и доставлять сообщения по локальной сети при отсутствии интернета. Отключите в ненадёжных сетях (публичный Wi-Fi).';

  @override
  String get settingsBgDelivery => 'Фоновая доставка';

  @override
  String get settingsBgDeliverySubtitle =>
      'Получайте сообщения когда приложение свёрнуто. Показывает постоянное уведомление.';

  @override
  String get settingsYourInboxProvider => 'Ваш провайдер входящих';

  @override
  String get settingsConnectionDetails => 'Параметры подключения';

  @override
  String get settingsSaveAndConnect => 'Сохранить и подключиться';

  @override
  String get settingsSecondaryInboxes => 'Дополнительные почтовые ящики';

  @override
  String get settingsAddSecondaryInbox => 'Добавить дополнительный ящик';

  @override
  String get settingsAdvanced => 'Дополнительно';

  @override
  String get settingsDiscover => 'Обнаружить';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get settingsPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get settingsPrivacyPolicySubtitle => 'Как Pulse защищает ваши данные';

  @override
  String get settingsCrashReporting => 'Отчёты об ошибках';

  @override
  String get settingsCrashReportingSubtitle =>
      'Отправлять анонимные отчёты об ошибках для улучшения Pulse. Содержимое сообщений и контакты никогда не отправляются.';

  @override
  String get settingsCrashReportingEnabled =>
      'Отчёты об ошибках включены — перезапустите приложение';

  @override
  String get settingsCrashReportingDisabled =>
      'Отчёты об ошибках отключены — перезапустите приложение';

  @override
  String get settingsSensitiveOperation => 'Важная операция';

  @override
  String get settingsSensitiveOperationBody =>
      'Эти ключи — ваша личность. Любой с этим файлом может выдать себя за вас. Храните надёжно и удалите после переноса.';

  @override
  String get settingsIUnderstandContinue => 'Понимаю, продолжить';

  @override
  String get settingsReplaceIdentity => 'Заменить личность?';

  @override
  String get settingsReplaceIdentityBody =>
      'Это перезапишет ваши текущие ключи. Существующие Signal-сессии будут аннулированы, контактам нужно будет восстановить шифрование. Потребуется перезапуск приложения.';

  @override
  String get settingsReplaceKeys => 'Заменить ключи';

  @override
  String get settingsKeysImported => 'Ключи импортированы';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count ключей успешно импортировано. Перезапустите приложение для инициализации с новой личностью.';
  }

  @override
  String get settingsRestartNow => 'Перезапустить сейчас';

  @override
  String get settingsLater => 'Позже';
}
