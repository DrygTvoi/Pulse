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
  String get setupReqMinLength => 'Минимум 16 символов';

  @override
  String get setupReqVariety =>
      '3 из 4: заглавные, строчные, цифры, спецсимволы';

  @override
  String get setupReqMatch => 'Пароли совпадают';

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
  String get bubbleReplyVideo => 'Видеосообщение';

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
  String get profileLeaveGroup => 'Покинуть группу';

  @override
  String get profileLeaveGroupBody =>
      'Вы будете удалены из группы, и она будет удалена из ваших контактов.';

  @override
  String get groupInviteTitle => 'Приглашение в группу';

  @override
  String groupInviteBody(String from, String group) {
    return '$from приглашает вас в \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Принять';

  @override
  String get groupInviteDecline => 'Отклонить';

  @override
  String get groupMemberLimitTitle => 'Слишком много участников';

  @override
  String groupMemberLimitBody(int count) {
    return 'В группе будет $count участников. Зашифрованные mesh-звонки поддерживают до 6. Большие группы переключаются на Jitsi (без E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Добавить всё равно';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name отклонил приглашение в \"$group\"';
  }

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
  String get menuAttachVideo => 'Видео';

  @override
  String get mediaTitle => 'Медиа';

  @override
  String get mediaFileLabel => 'ФАЙЛ';

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
  String statusPickPhotoFailed(String error) {
    return 'Не удалось выбрать фото: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Не удалось опубликовать: $error';
  }

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
  String get panicMinChars => 'Паник-ключ должен быть не менее 8 символов';

  @override
  String get panicKeysDoNotMatch => 'Ключи не совпадают';

  @override
  String get panicSetFailed =>
      'Не удалось сохранить паник-ключ — попробуйте ещё раз';

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
  String get profileCardDisplayName => 'Имя';

  @override
  String get profileCardDisplayNameHint => 'например, Иван Иванов';

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
  String get settingsNetwork => 'Сеть';

  @override
  String get settingsProxyTunnels => 'Прокси и туннели';

  @override
  String get settingsTurnServers => 'TURN-серверы';

  @override
  String get settingsProviderTitle => 'Провайдер';

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

  @override
  String get profileGroupLabel => 'Группа';

  @override
  String get profileAddButton => 'Добавить';

  @override
  String get profileKickButton => 'Исключить';

  @override
  String get dataSectionTitle => 'Данные';

  @override
  String get dataBackupMessages => 'Резервная копия сообщений';

  @override
  String get dataBackupPasswordSubtitle =>
      'Выберите пароль для шифрования резервной копии.';

  @override
  String get dataBackupConfirmLabel => 'Создать копию';

  @override
  String get dataCreatingBackup => 'Создание копии';

  @override
  String get dataBackupPreparing => 'Подготовка...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Экспорт сообщения $done из $total...';
  }

  @override
  String get dataBackupSavingFile => 'Сохранение файла...';

  @override
  String get dataSaveMessageBackupDialog => 'Сохранить резервную копию';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Копия сохранена ($count сообщений)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Ошибка резервной копии — данные не экспортированы';

  @override
  String dataBackupFailedError(String error) {
    return 'Ошибка резервной копии: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Выбрать резервную копию';

  @override
  String get dataInvalidBackupFile =>
      'Неверный файл резервной копии (слишком маленький)';

  @override
  String get dataNotValidBackupFile => 'Это не файл резервной копии Pulse';

  @override
  String get dataRestoreMessages => 'Восстановить сообщения';

  @override
  String get dataRestorePasswordSubtitle =>
      'Введите пароль, использованный при создании копии.';

  @override
  String get dataRestoreConfirmLabel => 'Восстановить';

  @override
  String get dataRestoringMessages => 'Восстановление сообщений';

  @override
  String get dataRestoreDecrypting => 'Расшифровка...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Импорт сообщения $done из $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Восстановление не удалось — неверный пароль или повреждённый файл';

  @override
  String dataRestoreSuccess(int count) {
    return 'Восстановлено $count новых сообщений';
  }

  @override
  String get dataRestoreNothingNew =>
      'Новых сообщений нет (все уже существуют)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Ошибка восстановления: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Выбрать экспорт ключей';

  @override
  String get dataNotValidKeyFile => 'Это не файл экспорта ключей Pulse';

  @override
  String get dataExportKeys => 'Экспорт ключей';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Выберите пароль для шифрования ключей.';

  @override
  String get dataExportKeysConfirmLabel => 'Экспорт';

  @override
  String get dataExportingKeys => 'Экспорт ключей';

  @override
  String get dataExportingKeysStatus => 'Шифрование ключей...';

  @override
  String get dataSaveKeyExportDialog => 'Сохранить экспорт ключей';

  @override
  String dataKeysExportedTo(String path) {
    return 'Ключи экспортированы:\n$path';
  }

  @override
  String get dataExportFailed => 'Экспорт не удался — ключи не найдены';

  @override
  String dataExportFailedError(String error) {
    return 'Ошибка экспорта: $error';
  }

  @override
  String get dataImportKeys => 'Импорт ключей';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Введите пароль, использованный при экспорте ключей.';

  @override
  String get dataImportKeysConfirmLabel => 'Импорт';

  @override
  String get dataImportingKeys => 'Импорт ключей';

  @override
  String get dataImportingKeysStatus => 'Расшифровка ключей...';

  @override
  String get dataImportFailed =>
      'Импорт не удался — неверный пароль или повреждённый файл';

  @override
  String dataImportFailedError(String error) {
    return 'Ошибка импорта: $error';
  }

  @override
  String get securitySectionTitle => 'Безопасность';

  @override
  String get securityIncorrectPassword => 'Неверный пароль';

  @override
  String get securityPasswordUpdated => 'Пароль обновлён';

  @override
  String get appearanceSectionTitle => 'Внешний вид';

  @override
  String appearanceExportFailed(String error) {
    return 'Ошибка экспорта: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Сохранено в $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Ошибка сохранения: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Ошибка импорта: $error';
  }

  @override
  String get aboutSectionTitle => 'О приложении';

  @override
  String get providerPublicKey => 'Публичный ключ';

  @override
  String get providerRelay => 'Реле';

  @override
  String get providerAutoConfigured =>
      'Настроено автоматически из пароля восстановления. Реле обнаруживается автоматически.';

  @override
  String get providerKeyStoredLocally =>
      'Ваш ключ хранится локально в защищённом хранилище — никогда не отправляется на сервер.';

  @override
  String get providerSessionInfo =>
      'Session Network — E2EE с луковой маршрутизацией. Session ID генерируется и хранится автоматически. Узлы обнаруживаются из встроенных.';

  @override
  String get providerAdvanced => 'Дополнительно';

  @override
  String get providerSaveAndConnect => 'Сохранить и подключиться';

  @override
  String get providerAddSecondaryInbox => 'Добавить дополнительный ящик';

  @override
  String get providerSecondaryInboxes => 'Дополнительные ящики';

  @override
  String get providerYourInboxProvider => 'Ваш провайдер входящих';

  @override
  String get providerConnectionDetails => 'Параметры подключения';

  @override
  String get addContactTitle => 'Добавить контакт';

  @override
  String get addContactInviteLinkLabel => 'Ссылка-приглашение или адрес';

  @override
  String get addContactTapToPaste => 'Нажмите, чтобы вставить ссылку';

  @override
  String get addContactPasteTooltip => 'Вставить из буфера обмена';

  @override
  String get addContactAddressDetected => 'Адрес контакта обнаружен';

  @override
  String addContactRoutesDetected(int count) {
    return '$count маршрутов обнаружено — SmartRouter выберет быстрейший';
  }

  @override
  String get addContactFetchingProfile => 'Загрузка профиля…';

  @override
  String addContactProfileFound(String name) {
    return 'Найдено: $name';
  }

  @override
  String get addContactNoProfileFound => 'Профиль не найден';

  @override
  String get addContactDisplayNameLabel => 'Отображаемое имя';

  @override
  String get addContactDisplayNameHint => 'Как вы хотите назвать этот контакт?';

  @override
  String get addContactAddManually => 'Добавить адрес вручную';

  @override
  String get addContactButton => 'Добавить контакт';

  @override
  String get networkDiagnosticsTitle => 'Диагностика сети';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr-реле';

  @override
  String get networkDiagnosticsDirect => 'Прямые';

  @override
  String get networkDiagnosticsTorOnly => 'Только через Tor';

  @override
  String get networkDiagnosticsBest => 'Лучшее';

  @override
  String get networkDiagnosticsNone => 'нет';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Статус';

  @override
  String get networkDiagnosticsConnected => 'Подключён';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Подключение $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Выкл';

  @override
  String get networkDiagnosticsTransport => 'Транспорт';

  @override
  String get networkDiagnosticsInfrastructure => 'Инфраструктура';

  @override
  String get networkDiagnosticsSessionNodes => 'Узлы Session';

  @override
  String get networkDiagnosticsTurnServers => 'TURN-серверы';

  @override
  String get networkDiagnosticsLastProbe => 'Последняя проверка';

  @override
  String get networkDiagnosticsRunning => 'Выполняется...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Запустить диагностику';

  @override
  String get networkDiagnosticsForceReprobe => 'Принудительная перепроверка';

  @override
  String get networkDiagnosticsJustNow => 'только что';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes мин. назад';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours ч. назад';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days д. назад';
  }

  @override
  String get homeNoEch => 'Нет ECH';

  @override
  String get homeNoEchTooltip =>
      'uTLS-прокси недоступен — ECH отключён.\nTLS-отпечаток виден DPI.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Сохранено и подключено к $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Встроенный Tor не запустился';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon не запустился';

  @override
  String get verifyTitle => 'Проверка номера безопасности';

  @override
  String get verifyIdentityVerified => 'Личность подтверждена';

  @override
  String get verifyNotYetVerified => 'Ещё не подтверждено';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Вы подтвердили номер безопасности $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Сравните эти номера с $name лично или по надёжному каналу.';
  }

  @override
  String get verifyExplanation =>
      'У каждого разговора есть уникальный номер безопасности. Если вы оба видите одинаковые номера на своих устройствах, соединение подтверждено сквозным шифрованием.';

  @override
  String verifyContactKey(String name) {
    return 'Ключ $name';
  }

  @override
  String get verifyYourKey => 'Ваш ключ';

  @override
  String get verifyRemoveVerification => 'Снять подтверждение';

  @override
  String get verifyMarkAsVerified => 'Отметить как проверенный';

  @override
  String verifyAfterReinstall(String name) {
    return 'Если $name переустановит приложение, номер безопасности изменится и подтверждение будет снято автоматически.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Отмечайте как проверенный только после сравнения номеров с $name по голосовому звонку или лично.';
  }

  @override
  String get verifyNoSession =>
      'Сеанс шифрования ещё не установлен. Сначала отправьте сообщение, чтобы сгенерировать номера безопасности.';

  @override
  String get verifyNoKeyAvailable => 'Ключ недоступен';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Отпечаток $label скопирован';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL базы данных';

  @override
  String get providerOptionalHint => 'Необязательно';

  @override
  String get providerWebApiKeyLabel => 'Web API-ключ';

  @override
  String get providerOptionalForPublicDb => 'Необязательно для публичной БД';

  @override
  String get providerRelayUrlLabel => 'URL реле';

  @override
  String get providerPrivateKeyLabel => 'Приватный ключ';

  @override
  String get providerPrivateKeyNsecLabel => 'Приватный ключ (nsec)';

  @override
  String get providerStorageNodeLabel => 'URL узла хранения (необязательно)';

  @override
  String get providerStorageNodeHint => 'Оставьте пустым для встроенных узлов';

  @override
  String get transferInvalidCodeFormat =>
      'Нераспознанный формат кода — должен начинаться с LAN: или NOS:';

  @override
  String get profileCardFingerprintCopied => 'Отпечаток скопирован';

  @override
  String get profileCardAboutHint => 'Приватность прежде всего 🔒';

  @override
  String get profileCardSaveButton => 'Сохранить профиль';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Экспорт зашифрованных сообщений, контактов и аватаров в файл';

  @override
  String get callVideo => 'Видео';

  @override
  String get callAudio => 'Аудио';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Доставлено: $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Доставлено: $count';
  }

  @override
  String get groupStatusDialogTitle => 'Сведения о сообщении';

  @override
  String get groupStatusRead => 'Прочитано';

  @override
  String get groupStatusDelivered => 'Доставлено';

  @override
  String get groupStatusPending => 'Ожидание';

  @override
  String get groupStatusNoData => 'Данные о доставке ещё не получены';

  @override
  String get profileTransferAdmin => 'Назначить admin';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Назначить $name новым администратором?';
  }

  @override
  String get profileTransferAdminBody =>
      'Вы потеряете права администратора. Это действие нельзя отменить.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name теперь администратор';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Политика конфиденциальности';

  @override
  String get privacyOverviewHeading => 'Обзор';

  @override
  String get privacyOverviewBody =>
      'Pulse — мессенджер без серверов с полным сквозным шифрованием. Конфиденциальность — это не функция, а архитектура. Серверов Pulse не существует. Ни аккаунты, ни сообщения нигде не хранятся. Разработчики не собирают, не передают и не хранят никаких данных.';

  @override
  String get privacyDataCollectionHeading => 'Сбор данных';

  @override
  String get privacyDataCollectionBody =>
      'Pulse не собирает никаких личных данных:\n\n- Email, номер телефона и настоящее имя не требуются\n- Нет аналитики, трекинга или телеметрии\n- Нет рекламных идентификаторов\n- Нет доступа к списку контактов\n- Нет облачных резервных копий (сообщения существуют только на вашем устройстве)\n- Никакие метаданные не отправляются на серверы Pulse (их не существует)';

  @override
  String get privacyEncryptionHeading => 'Шифрование';

  @override
  String get privacyEncryptionBody =>
      'Все сообщения шифруются по протоколу Signal (Double Ratchet с согласованием ключей X3DH). Ключи шифрования генерируются и хранятся исключительно на вашем устройстве. Никто — включая разработчиков — не может прочитать ваши сообщения.';

  @override
  String get privacyNetworkHeading => 'Сетевая архитектура';

  @override
  String get privacyNetworkBody =>
      'Pulse использует федеративные транспортные адаптеры (Nostr-реле, узлы Session Network, Firebase Realtime Database, LAN). Через эти транспорты передаётся только зашифрованный текст. Операторы реле видят ваш IP-адрес и объём трафика, но не могут расшифровать содержимое сообщений.\n\nПри включённом Tor ваш IP-адрес скрыт и от операторов реле.';

  @override
  String get privacyStunHeading => 'STUN/TURN серверы';

  @override
  String get privacyStunBody =>
      'Голосовые и видеозвонки используют WebRTC с шифрованием DTLS-SRTP. STUN-серверы (для определения публичного IP при peer-to-peer соединении) и TURN-серверы (для ретрансляции медиа при невозможности прямого соединения) видят ваш IP-адрес и длительность звонка, но не могут расшифровать его содержимое.\n\nВ настройках можно указать собственный TURN-сервер для максимальной приватности.';

  @override
  String get privacyCrashHeading => 'Отчёты об ошибках';

  @override
  String get privacyCrashBody =>
      'Если отчёты об ошибках Sentry включены (через SENTRY_DSN при сборке), могут отправляться анонимные отчёты. Они не содержат содержимого сообщений, контактных данных и личной информации. Отчёты об ошибках можно отключить при сборке, не указывая DSN.';

  @override
  String get privacyPasswordHeading => 'Пароль и ключи';

  @override
  String get privacyPasswordBody =>
      'Пароль восстановления используется для генерации криптографических ключей через Argon2id (KDF с высокими требованиями к памяти). Пароль никогда никуда не передаётся. Если вы потеряете пароль, аккаунт не может быть восстановлен — серверов для сброса не существует.';

  @override
  String get privacyFontsHeading => 'Шрифты';

  @override
  String get privacyFontsBody =>
      'Pulse поставляется со всеми шрифтами локально. Никакие запросы к Google Fonts или другим внешним сервисам шрифтов не выполняются.';

  @override
  String get privacyThirdPartyHeading => 'Сторонние сервисы';

  @override
  String get privacyThirdPartyBody =>
      'Pulse не интегрируется с рекламными сетями, аналитическими провайдерами, социальными сетями или брокерами данных. Единственные сетевые подключения — к транспортным реле, которые вы настроили.';

  @override
  String get privacyOpenSourceHeading => 'Открытый исходный код';

  @override
  String get privacyOpenSourceBody =>
      'Pulse — программа с открытым исходным кодом. Вы можете проверить полный исходный код, чтобы убедиться в соответствии заявлениям о конфиденциальности.';

  @override
  String get privacyContactHeading => 'Контакт';

  @override
  String get privacyContactBody =>
      'По вопросам конфиденциальности создайте issue в репозитории проекта.';

  @override
  String get privacyLastUpdated => 'Последнее обновление: март 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Ошибка сохранения: $error';
  }

  @override
  String get themeEngineTitle => 'Движок тем';

  @override
  String get torBuiltInTitle => 'Встроенный Tor';

  @override
  String get torConnectedSubtitle => 'Подключён — Nostr через 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Подключение… $pct%';
  }

  @override
  String get torNotRunning => 'Не запущен — нажмите для перезапуска';

  @override
  String get torDescription =>
      'Маршрутизация Nostr через Tor (Snowflake для сетей с цензурой)';

  @override
  String get torNetworkDiagnostics => 'Диагностика сети';

  @override
  String get torTransportLabel => 'Транспорт: ';

  @override
  String get torPtAuto => 'Авто';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Прямой';

  @override
  String get torTimeoutLabel => 'Таймаут: ';

  @override
  String get torInfoDescription =>
      'При включении WebSocket-соединения Nostr проходят через Tor (SOCKS5). Tor Browser слушает 127.0.0.1:9150. Демон tor использует порт 9050. Подключения Firebase не затронуты.';

  @override
  String get torRouteNostrTitle => 'Маршрутизировать Nostr через Tor';

  @override
  String get torManagedByBuiltin => 'Управляется встроенным Tor';

  @override
  String get torActiveRouting => 'Активен — трафик Nostr через Tor';

  @override
  String get torDisabled => 'Отключён';

  @override
  String get torProxySocks5 => 'Tor Прокси (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Хост прокси';

  @override
  String get torProxyPortLabel => 'Порт';

  @override
  String get torPortInfo => 'Tor Browser: порт 9150  •  демон tor: порт 9050';

  @override
  String get i2pProxySocks5 => 'I2P Прокси (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P использует SOCKS5 на порту 4447 по умолчанию. Подключайтесь к Nostr-реле через I2P-outproxy для связи с пользователями на любом транспорте. Tor имеет приоритет.';

  @override
  String get i2pRouteNostrTitle => 'Маршрутизировать Nostr через I2P';

  @override
  String get i2pActiveRouting => 'Активен — трафик Nostr через I2P';

  @override
  String get i2pDisabled => 'Отключён';

  @override
  String get i2pProxyHostLabel => 'Хост прокси';

  @override
  String get i2pProxyPortLabel => 'Порт';

  @override
  String get i2pPortInfo => 'I2P Router SOCKS5 порт по умолчанию: 4447';

  @override
  String get customProxySocks5 => 'Пользовательский прокси (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker реле';

  @override
  String get customProxyInfoDescription =>
      'Прокси направляет трафик через V2Ray/Xray/Shadowsocks. CF Worker работает как личный прокси на Cloudflare CDN — GFW видит *.workers.dev, а не реальное реле.';

  @override
  String get customSocks5ProxyTitle => 'Пользовательский SOCKS5 прокси';

  @override
  String get customProxyActive => 'Активен — трафик через SOCKS5';

  @override
  String get customProxyDisabled => 'Отключён';

  @override
  String get customProxyHostLabel => 'Хост прокси';

  @override
  String get customProxyPortLabel => 'Порт';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Домен Worker (необязательно)';

  @override
  String get customWorkerHelpTitle =>
      'Как развернуть CF Worker реле (бесплатно)';

  @override
  String get customWorkerScriptCopied => 'Скрипт скопирован!';

  @override
  String get customWorkerStep1 =>
      '1. Откройте dash.cloudflare.com → Workers & Pages\n2. Создайте Worker → вставьте этот скрипт:\n';

  @override
  String get customWorkerStep2 =>
      '3. Разверните → скопируйте домен (напр. my-relay.user.workers.dev)\n4. Вставьте домен выше → Сохраните\n\nПриложение подключается: wss://domain/?r=relay_url\nGFW видит: подключение к *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Подключён — SOCKS5 на 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Подключение…';

  @override
  String get psiphonNotRunning => 'Не запущен — нажмите для перезапуска';

  @override
  String get psiphonDescription =>
      'Быстрый туннель (~3с запуск, 2000+ ротируемых VPS)';

  @override
  String get turnCommunityServers => 'Общественные TURN-серверы';

  @override
  String get turnCustomServer => 'Пользовательский TURN-сервер (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN-серверы только ретранслируют уже зашифрованные потоки (DTLS-SRTP). Оператор видит ваш IP и объём трафика, но не может расшифровать звонки. TURN используется только при невозможности прямого P2P (~15–20%).';

  @override
  String get turnFreeLabel => 'БЕСПЛАТНО';

  @override
  String get turnServerUrlLabel => 'URL TURN-сервера';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 или turns:...';

  @override
  String get turnUsernameLabel => 'Логин';

  @override
  String get turnPasswordLabel => 'Пароль';

  @override
  String get turnOptionalHint => 'Необязательно';

  @override
  String get turnCustomInfo =>
      'Разверните coturn на любом VPS за \$5/мес для максимального контроля. Учётные данные хранятся локально.';

  @override
  String get themePickerAppearance => 'Оформление';

  @override
  String get themePickerAccentColor => 'Акцентный цвет';

  @override
  String get themeModeLight => 'Светлая';

  @override
  String get themeModeDark => 'Тёмная';

  @override
  String get themeModeSystem => 'Система';

  @override
  String get themeDynamicPresets => 'Предустановки';

  @override
  String get themeDynamicPrimaryColor => 'Основной цвет';

  @override
  String get themeDynamicBorderRadius => 'Скругление';

  @override
  String get themeDynamicFont => 'Шрифт';

  @override
  String get themeDynamicAppearance => 'Оформление';

  @override
  String get themeDynamicUiStyle => 'Стиль интерфейса';

  @override
  String get themeDynamicUiStyleDescription =>
      'Определяет оформление диалогов, переключателей и индикаторов.';

  @override
  String get themeDynamicSharp => 'Острый';

  @override
  String get themeDynamicRound => 'Круглый';

  @override
  String get themeDynamicModeDark => 'Тёмная';

  @override
  String get themeDynamicModeLight => 'Светлая';

  @override
  String get themeDynamicModeAuto => 'Авто';

  @override
  String get themeDynamicPlatformAuto => 'Авто';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'Неверный URL Firebase. Ожидается https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Неверный URL реле. Ожидается wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Неверный URL Pulse-сервера. Ожидается https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'URL сервера';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'Код приглашения';

  @override
  String get providerPulseInviteHint => 'Код приглашения (если требуется)';

  @override
  String get providerPulseInfo =>
      'Собственное реле. Ключи получены из пароля восстановления.';

  @override
  String get providerScreenTitle => 'Ящики';

  @override
  String get providerSecondaryInboxesHeader => 'ДОПОЛНИТЕЛЬНЫЕ ЯЩИКИ';

  @override
  String get providerSecondaryInboxesInfo =>
      'Дополнительные ящики получают сообщения одновременно для надёжности.';

  @override
  String get providerRemoveTooltip => 'Удалить';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... или hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... или hex приватный ключ';

  @override
  String get customProxyHostHint => '127.0.0.1';

  @override
  String get customProxyPortHint => '10808';

  @override
  String get i2pProxyHostHint => '127.0.0.1';

  @override
  String get i2pProxyPortHint => '4447';

  @override
  String get torProxyHostHint => '127.0.0.1';

  @override
  String get torProxyPortHint => '9050';

  @override
  String get cfWorkerDomainHint => 'my-relay.username.workers.dev';

  @override
  String get emojiNoRecent => 'Нет недавних эмодзи';

  @override
  String get emojiSearchHint => 'Поиск эмодзи...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Нажмите для чата';

  @override
  String get imageViewerSaveToDownloads => 'Сохранить в Загрузки';

  @override
  String imageViewerSavedTo(String path) {
    return 'Сохранено в $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'ОК';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSubtitle => 'Язык интерфейса';

  @override
  String get settingsLanguageSystem => 'Системный';

  @override
  String get onboardingLanguageTitle => 'Выберите язык';

  @override
  String get onboardingLanguageSubtitle =>
      'Вы можете изменить это позже в Настройках';

  @override
  String get videoNoteRecord => 'Записать видеосообщение';

  @override
  String get videoNoteTapToRecord => 'Нажмите для записи';

  @override
  String get videoNoteTapToStop => 'Нажмите для остановки';

  @override
  String get videoNoteCameraPermission => 'Нет доступа к камере';

  @override
  String get videoNoteMaxDuration => 'Максимум 30 секунд';

  @override
  String get videoNoteNotSupported =>
      'Видеосообщения не поддерживаются на этой платформе';

  @override
  String get navChats => 'Чаты';

  @override
  String get navUpdates => 'Обновления';

  @override
  String get navCalls => 'Звонки';

  @override
  String get filterAll => 'Все';

  @override
  String get filterUnread => 'Непрочитанные';

  @override
  String get filterGroups => 'Группы';

  @override
  String get callsNoRecent => 'Нет недавних звонков';

  @override
  String get callsEmptySubtitle => 'История звонков появится здесь';

  @override
  String get appBarEncrypted => 'сквозное шифрование';

  @override
  String get newStatus => 'Новый статус';

  @override
  String get newCall => 'Новый звонок';
}
