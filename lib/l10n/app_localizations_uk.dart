// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Пошук повідомлень...';

  @override
  String get search => 'Пошук';

  @override
  String get clearSearch => 'Очистити пошук';

  @override
  String get closeSearch => 'Закрити пошук';

  @override
  String get moreOptions => 'Більше';

  @override
  String get back => 'Назад';

  @override
  String get cancel => 'Скасувати';

  @override
  String get close => 'Закрити';

  @override
  String get confirm => 'Підтвердити';

  @override
  String get remove => 'Видалити';

  @override
  String get save => 'Зберегти';

  @override
  String get add => 'Додати';

  @override
  String get copy => 'Копіювати';

  @override
  String get skip => 'Пропустити';

  @override
  String get done => 'Готово';

  @override
  String get apply => 'Застосувати';

  @override
  String get export => 'Експорт';

  @override
  String get import => 'Імпорт';

  @override
  String get homeNewGroup => 'Нова група';

  @override
  String get homeSettings => 'Налаштування';

  @override
  String get homeSearching => 'Пошук повідомлень...';

  @override
  String get homeNoResults => 'Нічого не знайдено';

  @override
  String get homeNoChatHistory => 'Історія чатів порожня';

  @override
  String homeTransportSwitched(String address) {
    return 'Транспорт переключено → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name дзвонить...';
  }

  @override
  String get homeAccept => 'Прийняти';

  @override
  String get homeDecline => 'Відхилити';

  @override
  String get homeLoadEarlier => 'Завантажити старіші повідомлення';

  @override
  String get homeChats => 'Чати';

  @override
  String get homeSelectConversation => 'Оберіть розмову';

  @override
  String get homeNoChatsYet => 'Чатів ще немає';

  @override
  String get homeAddContactToStart => 'Додайте контакт, щоб почати спілкування';

  @override
  String get homeNewChat => 'Новий чат';

  @override
  String get homeNewChatTooltip => 'Новий чат';

  @override
  String get homeIncomingCallTitle => 'Вхідний дзвінок';

  @override
  String get homeIncomingGroupCallTitle => 'Вхідний груповий дзвінок';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — вхідний груповий дзвінок';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Немає чатів за запитом \"$query\"';
  }

  @override
  String get homeSectionChats => 'Чати';

  @override
  String get homeSectionMessages => 'Повідомлення';

  @override
  String get homeDbEncryptionUnavailable =>
      'Шифрування бази даних недоступне — встановіть SQLCipher для повного захисту';

  @override
  String get chatFileTooLargeGroup =>
      'Файли понад 512 КБ не підтримуються в групових чатах';

  @override
  String get chatLargeFile => 'Великий файл';

  @override
  String get chatCancel => 'Скасувати';

  @override
  String get chatSend => 'Надіслати';

  @override
  String get chatFileTooLarge => 'Файл завеликий — максимальний розмір 100 МБ';

  @override
  String get chatMicDenied => 'Доступ до мікрофона заборонено';

  @override
  String get chatVoiceFailed =>
      'Не вдалося зберегти голосове повідомлення — перевірте вільне місце';

  @override
  String get chatScheduleFuture => 'Заплановий час має бути в майбутньому';

  @override
  String get chatToday => 'Сьогодні';

  @override
  String get chatYesterday => 'Вчора';

  @override
  String get chatEdited => 'змінено';

  @override
  String get chatYou => 'Ви';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Цей файл займає $size МБ. Надсилання великих файлів може бути повільним. Продовжити?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Ключ безпеки $name змінився. Натисніть для перевірки.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Не вдалося зашифрувати повідомлення для $name — повідомлення не надіслано.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Номер безпеки змінився для $name. Натисніть для перевірки.';
  }

  @override
  String get chatNoMessagesFound => 'Повідомлень не знайдено';

  @override
  String get chatMessagesE2ee => 'Повідомлення захищені наскрізним шифруванням';

  @override
  String get chatSayHello => 'Привітайтеся';

  @override
  String get appBarOnline => 'онлайн';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'друкує';

  @override
  String get appBarSearchMessages => 'Пошук повідомлень...';

  @override
  String get appBarMute => 'Вимкнути звук';

  @override
  String get appBarUnmute => 'Увімкнути звук';

  @override
  String get appBarMedia => 'Медіа';

  @override
  String get appBarDisappearing => 'Зникаючі повідомлення';

  @override
  String get appBarDisappearingOn => 'Зникаючі: увімк.';

  @override
  String get appBarGroupSettings => 'Налаштування групи';

  @override
  String get appBarSearchTooltip => 'Пошук повідомлень';

  @override
  String get appBarVoiceCall => 'Голосовий дзвінок';

  @override
  String get appBarVideoCall => 'Відеодзвінок';

  @override
  String get inputMessage => 'Повідомлення...';

  @override
  String get inputAttachFile => 'Прикріпити файл';

  @override
  String get inputSendMessage => 'Надіслати повідомлення';

  @override
  String get inputRecordVoice => 'Записати голосове повідомлення';

  @override
  String get inputSendVoice => 'Надіслати голосове повідомлення';

  @override
  String get inputCancelReply => 'Скасувати відповідь';

  @override
  String get inputCancelEdit => 'Скасувати редагування';

  @override
  String get inputCancelRecording => 'Скасувати запис';

  @override
  String get inputRecording => 'Запис…';

  @override
  String get inputEditingMessage => 'Редагування повідомлення';

  @override
  String get inputPhoto => 'Фото';

  @override
  String get inputVoiceMessage => 'Голосове повідомлення';

  @override
  String get inputFile => 'Файл';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count запланованих повідомлень',
      many: '$count запланованих повідомлень',
      few: '$count заплановані повідомлення',
      one: '1 заплановане повідомлення',
    );
    return '$_temp0';
  }

  @override
  String get callInitializing => 'Ініціалізація дзвінка…';

  @override
  String get callConnecting => 'Підключення…';

  @override
  String get callConnectingRelay => 'Підключення (реле)…';

  @override
  String get callSwitchingRelay => 'Перемикання на реле…';

  @override
  String get callConnectionFailed => 'Помилка підключення';

  @override
  String get callReconnecting => 'Перепідключення…';

  @override
  String get callEnded => 'Дзвінок завершено';

  @override
  String get callLive => 'Наживо';

  @override
  String get callEnd => 'Завершити';

  @override
  String get callEndCall => 'Завершити дзвінок';

  @override
  String get callMute => 'Вимкнути мікрофон';

  @override
  String get callUnmute => 'Увімкнути мікрофон';

  @override
  String get callSpeaker => 'Динамік';

  @override
  String get callCameraOn => 'Камера увімк.';

  @override
  String get callCameraOff => 'Камера вимк.';

  @override
  String get callShareScreen => 'Показати екран';

  @override
  String get callStopShare => 'Зупинити показ';

  @override
  String callTorBackup(String duration) {
    return 'Tor резерв · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor резерв активний — основний маршрут недоступний';

  @override
  String get callDirectFailed =>
      'Пряме підключення не вдалося — перемикання на реле…';

  @override
  String get callTurnUnreachable =>
      'TURN-сервери недоступні. Додайте власний TURN у Налаштування → Додатково.';

  @override
  String get callRelayMode => 'Режим реле (обмежена мережа)';

  @override
  String get callStarting => 'Починаємо дзвінок…';

  @override
  String get callConnectingToGroup => 'Підключення до групи…';

  @override
  String get callGroupOpenedInBrowser => 'Груповий дзвінок відкрито в браузері';

  @override
  String get callCouldNotOpenBrowser => 'Не вдалося відкрити браузер';

  @override
  String get callInviteLinkSent =>
      'Посилання-запрошення надіслано всім учасникам групи.';

  @override
  String get callOpenLinkManually =>
      'Відкрийте посилання вручну або натисніть для повтору.';

  @override
  String get callJitsiNotE2ee =>
      'Jitsi-дзвінки НЕ мають наскрізного шифрування';

  @override
  String get callRetryOpenBrowser => 'Повторити відкриття браузера';

  @override
  String get callClose => 'Закрити';

  @override
  String get callCamOn => 'Камера увімк.';

  @override
  String get callCamOff => 'Камера вимк.';

  @override
  String get noConnection => 'Немає зʼєднання — повідомлення стануть у чергу';

  @override
  String get connected => 'Підключено';

  @override
  String get connecting => 'Підключення…';

  @override
  String get disconnected => 'Відключено';

  @override
  String get offlineBanner =>
      'Немає зʼєднання — повідомлення надішлються після відновлення звʼязку';

  @override
  String get lanModeBanner =>
      'LAN-режим — немає інтернету · тільки локальна мережа';

  @override
  String get probeCheckingNetwork => 'Перевірка мережевого підключення…';

  @override
  String get probeDiscoveringRelays => 'Пошук реле через каталоги…';

  @override
  String get probeStartingTor => 'Запуск Tor…';

  @override
  String get probeFindingRelaysTor => 'Пошук доступних реле через Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count реле',
      many: '$count реле',
      few: '$count реле',
      one: '1 реле',
    );
    return 'Мережа готова — знайдено $_temp0';
  }

  @override
  String get probeNoRelaysFound =>
      'Доступних реле не знайдено — повідомлення можуть затримуватися';

  @override
  String get jitsiWarningTitle => 'Без наскрізного шифрування';

  @override
  String get jitsiWarningBody =>
      'Дзвінки Jitsi Meet не шифруються Pulse. Використовуйте лише для неконфіденційних розмов.';

  @override
  String get jitsiConfirm => 'Все одно приєднатися';

  @override
  String get jitsiGroupWarningTitle => 'Без наскрізного шифрування';

  @override
  String get jitsiGroupWarningBody =>
      'Забагато учасників для зашифрованої сітки.\n\nПосилання Jitsi Meet буде відкрито в браузері. Jitsi НЕ має наскрізного шифрування — сервер може бачити ваш дзвінок.';

  @override
  String get jitsiContinueAnyway => 'Все одно продовжити';

  @override
  String get retry => 'Повторити';

  @override
  String get setupCreateAnonymousAccount =>
      'Створіть анонімний обліковий запис';

  @override
  String get setupTapToChangeColor => 'Натисніть, щоб змінити колір';

  @override
  String get setupReqMinLength => 'Щонайменше 16 символів';

  @override
  String get setupReqVariety => '3 з 4: великі, малі літери, цифри, символи';

  @override
  String get setupReqMatch => 'Паролі збігаються';

  @override
  String get setupYourNickname => 'Ваш псевдонім';

  @override
  String get setupRecoveryPassword => 'Пароль відновлення (мін. 16)';

  @override
  String get setupConfirmPassword => 'Підтвердіть пароль';

  @override
  String get setupMin16Chars => 'Мінімум 16 символів';

  @override
  String get setupPasswordsDoNotMatch => 'Паролі не збігаються';

  @override
  String get setupEntropyWeak => 'Слабкий';

  @override
  String get setupEntropyOk => 'Нормальний';

  @override
  String get setupEntropyStrong => 'Сильний';

  @override
  String get setupEntropyWeakNeedsVariety =>
      'Слабкий (потрібно 3 типи символів)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits біт)';
  }

  @override
  String get setupPasswordWarning =>
      'Цей пароль — єдиний спосіб відновити обліковий запис. Немає сервера — немає скидання пароля. Запамʼятайте або запишіть його.';

  @override
  String get setupCreateAccount => 'Створити обліковий запис';

  @override
  String get setupAlreadyHaveAccount => 'Вже маєте обліковий запис? ';

  @override
  String get setupRestore => 'Відновити →';

  @override
  String get restoreTitle => 'Відновлення облікового запису';

  @override
  String get restoreInfoBanner =>
      'Введіть пароль відновлення — вашу адресу (Nostr + Session) буде відновлено автоматично. Контакти та повідомлення зберігалися лише локально.';

  @override
  String get restoreNewNickname => 'Новий псевдонім (можна змінити)';

  @override
  String get restoreButton => 'Відновити обліковий запис';

  @override
  String get lockTitle => 'Pulse заблоковано';

  @override
  String get lockSubtitle => 'Введіть пароль для продовження';

  @override
  String get lockPasswordHint => 'Пароль';

  @override
  String get lockUnlock => 'Розблокувати';

  @override
  String get lockPanicHint =>
      'Забули пароль? Введіть панік-ключ для видалення всіх даних.';

  @override
  String get lockTooManyAttempts => 'Забагато спроб. Видалення всіх даних…';

  @override
  String get lockWrongPassword => 'Неправильний пароль';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Неправильний пароль — $attempts/$max спроб';
  }

  @override
  String get onboardingSkip => 'Пропустити';

  @override
  String get onboardingNext => 'Далі';

  @override
  String get onboardingGetStarted => 'Створити акаунт';

  @override
  String get onboardingWelcomeTitle => 'Ласкаво просимо до Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Децентралізований месенджер з наскрізним шифруванням.\n\nЖодних центральних серверів. Жодного збору даних. Жодних бекдорів.\nВаші розмови належать тільки вам.';

  @override
  String get onboardingTransportTitle => 'Транспорт-агностик';

  @override
  String get onboardingTransportBody =>
      'Використовуйте Firebase, Nostr або обидва одночасно.\n\nПовідомлення маршрутизуються автоматично. Вбудована підтримка Tor та I2P для обходу цензури.';

  @override
  String get onboardingSignalTitle => 'Signal + постквантове';

  @override
  String get onboardingSignalBody =>
      'Кожне повідомлення зашифроване протоколом Signal (Double Ratchet + X3DH) для прямої секретності.\n\nДодатково обгорнуте Kyber-1024 — стандарт NIST для постквантового захисту від майбутніх квантових компʼютерів.';

  @override
  String get onboardingKeysTitle => 'Ви володієте ключами';

  @override
  String get onboardingKeysBody =>
      'Ваші ключі ніколи не залишають пристрій.\n\nВідбитки Signal дозволяють верифікувати контакти. TOFU автоматично виявляє зміну ключів.';

  @override
  String get onboardingThemeTitle => 'Оберіть оформлення';

  @override
  String get onboardingThemeBody =>
      'Оберіть тему та акцентний колір. Ви завжди можете змінити це в налаштуваннях.';

  @override
  String get contactsNewChat => 'Новий чат';

  @override
  String get contactsAddContact => 'Додати контакт';

  @override
  String get contactsSearchHint => 'Пошук...';

  @override
  String get contactsNewGroup => 'Нова група';

  @override
  String get contactsNoContactsYet => 'Контактів ще немає';

  @override
  String get contactsAddHint => 'Натисніть +, щоб додати адресу';

  @override
  String get contactsNoMatch => 'Збігів не знайдено';

  @override
  String get contactsRemoveTitle => 'Видалити контакт';

  @override
  String contactsRemoveMessage(String name) {
    return 'Видалити $name?';
  }

  @override
  String get contactsRemove => 'Видалити';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count контактів',
      many: '$count контактів',
      few: '$count контакти',
      one: '1 контакт',
    );
    return '$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Відкрити посилання';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Відкрити цей URL у браузері?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Відкрити';

  @override
  String get bubbleSecurityWarning => 'Попередження безпеки';

  @override
  String bubbleExecutableWarning(String name) {
    return '«$name» — виконуваний файл. Збереження та запуск можуть зашкодити пристрою. Зберегти?';
  }

  @override
  String get bubbleSaveAnyway => 'Все одно зберегти';

  @override
  String bubbleSavedTo(String path) {
    return 'Збережено в $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Помилка збереження: $error';
  }

  @override
  String get bubbleNotEncrypted => 'НЕ ЗАШИФРОВАНО';

  @override
  String get bubbleCorruptedImage => '[Пошкоджене зображення]';

  @override
  String get bubbleReplyPhoto => 'Фото';

  @override
  String get bubbleReplyVoice => 'Голосове повідомлення';

  @override
  String get bubbleReplyVideo => 'Відеоповідомлення';

  @override
  String bubbleReadBy(String names) {
    return 'Прочитано: $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Прочитано: $count';
  }

  @override
  String get chatTileTapToStart => 'Натисніть, щоб почати чат';

  @override
  String get chatTileMessageSent => 'Повідомлення надіслано';

  @override
  String get chatTileEncryptedMessage => 'Зашифроване повідомлення';

  @override
  String chatTileYouPrefix(String text) {
    return 'Ви: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Голосове повідомлення';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Голосове повідомлення ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Зашифроване повідомлення';

  @override
  String get groupNewGroup => 'Нова група';

  @override
  String get groupGroupName => 'Назва групи';

  @override
  String get groupSelectMembers => 'Оберіть учасників (мін. 2)';

  @override
  String get groupNoContactsYet =>
      'Немає контактів. Спочатку додайте контакти.';

  @override
  String get groupCreate => 'Створити';

  @override
  String get groupLabel => 'Група';

  @override
  String get profileVerifyIdentity => 'Перевірка особи';

  @override
  String profileVerifyInstructions(String name) {
    return 'Порівняйте ці відбитки з $name під час голосового дзвінка або особисто. Якщо обидва значення збігаються на обох пристроях, натисніть «Позначити як перевірений».';
  }

  @override
  String get profileTheirKey => 'Їхній ключ';

  @override
  String get profileYourKey => 'Ваш ключ';

  @override
  String get profileRemoveVerification => 'Зняти перевірку';

  @override
  String get profileMarkAsVerified => 'Позначити як перевірений';

  @override
  String get profileAddressCopied => 'Адресу скопійовано';

  @override
  String get profileNoContactsToAdd =>
      'Немає контактів для додавання — усі вже є учасниками';

  @override
  String get profileAddMembers => 'Додати учасників';

  @override
  String profileAddCount(int count) {
    return 'Додати ($count)';
  }

  @override
  String get profileRenameGroup => 'Перейменувати групу';

  @override
  String get profileRename => 'Перейменувати';

  @override
  String get profileRemoveMember => 'Видалити учасника?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Видалити $name із цієї групи?';
  }

  @override
  String get profileKick => 'Виключити';

  @override
  String get profileSignalFingerprints => 'Відбитки Signal';

  @override
  String get profileVerified => 'ПЕРЕВІРЕНО';

  @override
  String get profileVerify => 'Перевірити';

  @override
  String get profileEdit => 'Змінити';

  @override
  String get profileNoSession =>
      'Сеанс ще не встановлено — спочатку надішліть повідомлення.';

  @override
  String get profileFingerprintCopied => 'Відбиток скопійовано';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count учасників',
      many: '$count учасників',
      few: '$count учасники',
      one: '1 учасник',
    );
    return '$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Перевірити номер безпеки';

  @override
  String get profileShowContactQr => 'Показати QR контакту';

  @override
  String profileContactAddress(String name) {
    return 'Адреса $name';
  }

  @override
  String get profileExportChatHistory => 'Експорт історії чату';

  @override
  String profileSavedTo(String path) {
    return 'Збережено в $path';
  }

  @override
  String get profileExportFailed => 'Помилка експорту';

  @override
  String get profileClearChatHistory => 'Очистити історію чату';

  @override
  String get profileDeleteGroup => 'Видалити групу';

  @override
  String get profileDeleteContact => 'Видалити контакт';

  @override
  String get profileLeaveGroup => 'Покинути групу';

  @override
  String get profileLeaveGroupBody =>
      'Вас буде видалено з групи, і вона зникне з вашого списку контактів.';

  @override
  String get groupInviteTitle => 'Запрошення до групи';

  @override
  String groupInviteBody(String from, String group) {
    return '$from запрошує вас до \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Прийняти';

  @override
  String get groupInviteDecline => 'Відхилити';

  @override
  String get groupMemberLimitTitle => 'Забагато учасників';

  @override
  String groupMemberLimitBody(int count) {
    return 'У групі буде $count учасників. Зашифровані mesh-дзвінки підтримують до 6. Більші групи перемикаються на Jitsi (без E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Все одно додати';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name відхилив запрошення до \"$group\"';
  }

  @override
  String get transferTitle => 'Перенесення на інший пристрій';

  @override
  String get transferInfoBox =>
      'Перенесіть свою Signal-особу та ключі Nostr на новий пристрій.\nСеанси чатів НЕ переносяться — пряма секретність зберігається.';

  @override
  String get transferSendFromThis => 'Надіслати з цього пристрою';

  @override
  String get transferSendSubtitle =>
      'На цьому пристрої ключі. Поділіться кодом із новим пристроєм.';

  @override
  String get transferReceiveOnThis => 'Отримати на цьому пристрої';

  @override
  String get transferReceiveSubtitle =>
      'Це новий пристрій. Введіть код зі старого пристрою.';

  @override
  String get transferChooseMethod => 'Оберіть спосіб перенесення';

  @override
  String get transferLan => 'LAN (одна мережа)';

  @override
  String get transferLanSubtitle =>
      'Швидко, напряму. Обидва пристрої мають бути в одній Wi-Fi.';

  @override
  String get transferNostrRelay => 'Nostr-реле';

  @override
  String get transferNostrRelaySubtitle =>
      'Працює через будь-яку мережу за допомогою наявного Nostr-реле.';

  @override
  String get transferRelayUrl => 'URL реле';

  @override
  String get transferEnterCode => 'Введіть код перенесення';

  @override
  String get transferPasteCode => 'Вставте код LAN:... або NOS:... сюди';

  @override
  String get transferConnect => 'Підключитися';

  @override
  String get transferGenerating => 'Генерація коду перенесення…';

  @override
  String get transferShareCode => 'Поділіться цим кодом з отримувачем:';

  @override
  String get transferCopyCode => 'Копіювати код';

  @override
  String get transferCodeCopied => 'Код скопійовано до буфера обміну';

  @override
  String get transferWaitingReceiver => 'Очікування підключення отримувача…';

  @override
  String get transferConnectingSender => 'Підключення до відправника…';

  @override
  String get transferVerifyBoth =>
      'Порівняйте цей код на обох пристроях.\nЯкщо вони збігаються, перенесення безпечне.';

  @override
  String get transferComplete => 'Перенесення завершено';

  @override
  String get transferKeysImported => 'Ключі імпортовано';

  @override
  String get transferCompleteSenderBody =>
      'Ваші ключі залишаються активними на цьому пристрої.\nОтримувач тепер може використовувати вашу особу.';

  @override
  String get transferCompleteReceiverBody =>
      'Ключі успішно імпортовано.\nПерезапустіть застосунок для застосування нової особи.';

  @override
  String get transferRestartApp => 'Перезапустити';

  @override
  String get transferFailed => 'Помилка перенесення';

  @override
  String get transferTryAgain => 'Спробувати знову';

  @override
  String get transferEnterRelayFirst => 'Спочатку введіть URL реле';

  @override
  String get transferPasteCodeFromSender =>
      'Вставте код перенесення від відправника';

  @override
  String get menuReply => 'Відповісти';

  @override
  String get menuForward => 'Переслати';

  @override
  String get menuReact => 'Реакція';

  @override
  String get menuCopy => 'Копіювати';

  @override
  String get menuEdit => 'Редагувати';

  @override
  String get menuRetry => 'Повторити';

  @override
  String get menuCancelScheduled => 'Скасувати надсилання';

  @override
  String get menuDelete => 'Видалити';

  @override
  String get menuForwardTo => 'Переслати…';

  @override
  String menuForwardedTo(String name) {
    return 'Переслано $name';
  }

  @override
  String get menuScheduledMessages => 'Заплановані повідомлення';

  @override
  String get menuNoScheduledMessages => 'Немає запланованих повідомлень';

  @override
  String menuSendsOn(String date) {
    return 'Надсилання $date';
  }

  @override
  String get menuDisappearingMessages => 'Зникаючі повідомлення';

  @override
  String get menuDisappearingSubtitle =>
      'Повідомлення автоматично видаляються через обраний час.';

  @override
  String get menuTtlOff => 'Вимк.';

  @override
  String get menuTtl1h => '1 година';

  @override
  String get menuTtl24h => '24 години';

  @override
  String get menuTtl7d => '7 днів';

  @override
  String get menuAttachPhoto => 'Фото';

  @override
  String get menuAttachFile => 'Файл';

  @override
  String get menuAttachVideo => 'Відео';

  @override
  String get mediaTitle => 'Медіа';

  @override
  String get mediaFileLabel => 'ФАЙЛ';

  @override
  String mediaPhotosTab(int count) {
    return 'Фото ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Файли ($count)';
  }

  @override
  String get mediaNoPhotos => 'Фото ще немає';

  @override
  String get mediaNoFiles => 'Файлів ще немає';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Збережено в Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'Не вдалося зберегти файл';

  @override
  String get statusNewStatus => 'Новий статус';

  @override
  String get statusPublish => 'Опублікувати';

  @override
  String get statusExpiresIn24h => 'Статус зникає через 24 години';

  @override
  String get statusWhatsOnYourMind => 'Про що ви думаєте?';

  @override
  String get statusPhotoAttached => 'Фото прикріплено';

  @override
  String get statusAttachPhoto => 'Прикріпити фото (необовʼязково)';

  @override
  String get statusEnterText => 'Введіть текст для вашого статусу.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Не вдалося обрати фото: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Не вдалося опублікувати: $error';
  }

  @override
  String get panicSetPanicKey => 'Встановити панік-ключ';

  @override
  String get panicEmergencySelfDestruct => 'Екстрене самознищення';

  @override
  String get panicIrreversible => 'Цю дію не можна скасувати';

  @override
  String get panicWarningBody =>
      'Введення цього ключа на екрані блокування миттєво стирає ВСІ дані — повідомлення, контакти, ключі, особу. Використовуйте ключ, відмінний від звичайного пароля.';

  @override
  String get panicKeyHint => 'Панік-ключ';

  @override
  String get panicConfirmHint => 'Підтвердіть панік-ключ';

  @override
  String get panicMinChars => 'Панік-ключ має бути не менше 8 символів';

  @override
  String get panicKeysDoNotMatch => 'Ключі не збігаються';

  @override
  String get panicSetFailed =>
      'Не вдалося зберегти панік-ключ — спробуйте ще раз';

  @override
  String get passwordSetAppPassword => 'Встановити пароль';

  @override
  String get passwordProtectsMessages => 'Захищає ваші повідомлення';

  @override
  String get passwordInfoBanner =>
      'Потрібен при кожному запуску Pulse. Якщо забудете, дані не можна буде відновити.';

  @override
  String get passwordHint => 'Пароль';

  @override
  String get passwordConfirmHint => 'Підтвердіть пароль';

  @override
  String get passwordSetButton => 'Встановити пароль';

  @override
  String get passwordSkipForNow => 'Пропустити';

  @override
  String get passwordMinChars => 'Пароль має бути не менше 8 символів';

  @override
  String get passwordNeedsVariety =>
      'Має містити літери, цифри та спеціальні символи';

  @override
  String get passwordRequirements =>
      'Мін. 8 символів з літерами, цифрами та спеціальним символом';

  @override
  String get passwordsDoNotMatch => 'Паролі не збігаються';

  @override
  String get profileCardSaved => 'Профіль збережено!';

  @override
  String get profileCardE2eeIdentity => 'E2EE-особа';

  @override
  String get profileCardDisplayName => 'Відображуване імʼя';

  @override
  String get profileCardDisplayNameHint => 'напр. Іван Іваненко';

  @override
  String get profileCardAbout => 'Про себе';

  @override
  String get profileCardSaveProfile => 'Зберегти профіль';

  @override
  String get profileCardYourName => 'Ваше імʼя';

  @override
  String get profileCardAddressCopied => 'Адресу скопійовано!';

  @override
  String get profileCardInboxAddress => 'Ваша адреса вхідних';

  @override
  String get profileCardInboxAddresses => 'Ваші адреси вхідних';

  @override
  String get profileCardShareAllAddresses =>
      'Поділитися всіма адресами (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Поділіться з контактами, щоб вони могли вам написати.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Усі $count адрес скопійовано як одне посилання!';
  }

  @override
  String get settingsMyProfile => 'Мій профіль';

  @override
  String get settingsYourInboxAddress => 'Ваша адреса вхідних';

  @override
  String get settingsMyQrCode => 'Поділитися контактом';

  @override
  String get settingsMyQrSubtitle =>
      'QR-код та посилання-запрошення для вашої адреси';

  @override
  String get settingsShareMyAddress => 'Поділитися адресою';

  @override
  String get settingsNoAddressYet =>
      'Немає адреси — спочатку збережіть налаштування';

  @override
  String get settingsInviteLink => 'Посилання-запрошення';

  @override
  String get settingsRawAddress => 'Адреса';

  @override
  String get settingsCopyLink => 'Копіювати посилання';

  @override
  String get settingsCopyAddress => 'Копіювати адресу';

  @override
  String get settingsInviteLinkCopied => 'Посилання-запрошення скопійовано';

  @override
  String get settingsAppearance => 'Зовнішній вигляд';

  @override
  String get settingsThemeEngine => 'Двигун тем';

  @override
  String get settingsThemeEngineSubtitle => 'Налаштуйте кольори та шрифти';

  @override
  String get settingsSignalProtocol => 'Протокол Signal';

  @override
  String get settingsSignalProtocolSubtitle =>
      'Ключі E2EE зберігаються надійно';

  @override
  String get settingsActive => 'АКТИВНИЙ';

  @override
  String get settingsIdentityBackup => 'Резервна копія особи';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Експорт або імпорт вашої Signal-особи';

  @override
  String get settingsIdentityBackupBody =>
      'Експортуйте ключі Signal-особи в резервний код або відновіть з наявного.';

  @override
  String get settingsTransferDevice => 'Перенесення на інший пристрій';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Перенесіть особу через LAN або Nostr-реле';

  @override
  String get settingsExportIdentity => 'Експорт особи';

  @override
  String get settingsExportIdentityBody =>
      'Скопіюйте цей резервний код і збережіть його надійно:';

  @override
  String get settingsSaveFile => 'Зберегти файл';

  @override
  String get settingsImportIdentity => 'Імпорт особи';

  @override
  String get settingsImportIdentityBody =>
      'Вставте резервний код нижче. Це перезапише вашу поточну особу.';

  @override
  String get settingsPasteBackupCode => 'Вставте резервний код…';

  @override
  String get settingsIdentityImported =>
      'Особу + контакти імпортовано! Перезапустіть застосунок.';

  @override
  String get settingsSecurity => 'Безпека';

  @override
  String get settingsAppPassword => 'Пароль застосунку';

  @override
  String get settingsPasswordEnabled =>
      'Увімкнено — потрібен при кожному запуску';

  @override
  String get settingsPasswordDisabled =>
      'Вимкнено — застосунок відкривається без пароля';

  @override
  String get settingsChangePassword => 'Змінити пароль';

  @override
  String get settingsChangePasswordSubtitle => 'Оновити пароль блокування';

  @override
  String get settingsSetPanicKey => 'Встановити панік-ключ';

  @override
  String get settingsChangePanicKey => 'Змінити панік-ключ';

  @override
  String get settingsPanicKeySetSubtitle => 'Оновити ключ екстреного стирання';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Один ключ миттєво стирає всі дані';

  @override
  String get settingsRemovePanicKey => 'Видалити панік-ключ';

  @override
  String get settingsRemovePanicKeySubtitle => 'Вимкнути екстрене самознищення';

  @override
  String get settingsRemovePanicKeyBody =>
      'Екстрене самознищення буде вимкнено. Ви можете увімкнути його будь-коли.';

  @override
  String get settingsDisableAppPassword => 'Вимкнути пароль';

  @override
  String get settingsEnterCurrentPassword =>
      'Введіть поточний пароль для підтвердження';

  @override
  String get settingsCurrentPassword => 'Поточний пароль';

  @override
  String get settingsIncorrectPassword => 'Неправильний пароль';

  @override
  String get settingsPasswordUpdated => 'Пароль оновлено';

  @override
  String get settingsChangePasswordProceed =>
      'Введіть поточний пароль для продовження';

  @override
  String get settingsData => 'Дані';

  @override
  String get settingsBackupMessages => 'Резервна копія повідомлень';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Експорт зашифрованої історії повідомлень у файл';

  @override
  String get settingsRestoreMessages => 'Відновити повідомлення';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Імпорт повідомлень із файлу резервної копії';

  @override
  String get settingsExportKeys => 'Експорт ключів';

  @override
  String get settingsExportKeysSubtitle =>
      'Зберегти ключі особи в зашифрований файл';

  @override
  String get settingsImportKeys => 'Імпорт ключів';

  @override
  String get settingsImportKeysSubtitle =>
      'Відновити ключі особи з експортованого файлу';

  @override
  String get settingsBackupPassword => 'Пароль резервної копії';

  @override
  String get settingsPasswordCannotBeEmpty => 'Пароль не може бути порожнім';

  @override
  String get settingsPasswordMin4Chars => 'Пароль має бути не менше 4 символів';

  @override
  String get settingsCallsTurn => 'Дзвінки та TURN';

  @override
  String get settingsLocalNetwork => 'Локальна мережа';

  @override
  String get settingsCensorshipResistance => 'Обхід цензури';

  @override
  String get settingsNetwork => 'Мережа';

  @override
  String get settingsProxyTunnels => 'Проксі та тунелі';

  @override
  String get settingsTurnServers => 'TURN-сервери';

  @override
  String get settingsProviderTitle => 'Провайдер';

  @override
  String get settingsLanFallback => 'LAN-резерв';

  @override
  String get settingsLanFallbackSubtitle =>
      'Виявляти присутність та доставляти повідомлення по локальній мережі за відсутності інтернету. Вимкніть у ненадійних мережах (публічний Wi-Fi).';

  @override
  String get settingsBgDelivery => 'Фонова доставка';

  @override
  String get settingsBgDeliverySubtitle =>
      'Отримувати повідомлення коли застосунок згорнуто. Показує постійне сповіщення.';

  @override
  String get settingsYourInboxProvider => 'Ваш провайдер вхідних';

  @override
  String get settingsConnectionDetails => 'Параметри підключення';

  @override
  String get settingsSaveAndConnect => 'Зберегти та підключитися';

  @override
  String get settingsSecondaryInboxes => 'Додаткові поштові скриньки';

  @override
  String get settingsAddSecondaryInbox => 'Додати додаткову скриньку';

  @override
  String get settingsAdvanced => 'Додатково';

  @override
  String get settingsDiscover => 'Виявити';

  @override
  String get settingsAbout => 'Про застосунок';

  @override
  String get settingsPrivacyPolicy => 'Політика конфіденційності';

  @override
  String get settingsPrivacyPolicySubtitle => 'Як Pulse захищає ваші дані';

  @override
  String get settingsCrashReporting => 'Звіти про помилки';

  @override
  String get settingsCrashReportingSubtitle =>
      'Надсилати анонімні звіти про помилки для покращення Pulse. Вміст повідомлень та контакти ніколи не надсилаються.';

  @override
  String get settingsCrashReportingEnabled =>
      'Звіти про помилки увімкнено — перезапустіть застосунок';

  @override
  String get settingsCrashReportingDisabled =>
      'Звіти про помилки вимкнено — перезапустіть застосунок';

  @override
  String get settingsSensitiveOperation => 'Важлива операція';

  @override
  String get settingsSensitiveOperationBody =>
      'Ці ключі — ваша особа. Будь-хто з цим файлом може видати себе за вас. Зберігайте надійно та видаліть після перенесення.';

  @override
  String get settingsIUnderstandContinue => 'Розумію, продовжити';

  @override
  String get settingsReplaceIdentity => 'Замінити особу?';

  @override
  String get settingsReplaceIdentityBody =>
      'Це перезапише ваші поточні ключі. Існуючі Signal-сеанси буде анульовано, контактам потрібно буде відновити шифрування. Потрібен перезапуск застосунку.';

  @override
  String get settingsReplaceKeys => 'Замінити ключі';

  @override
  String get settingsKeysImported => 'Ключі імпортовано';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count ключів успішно імпортовано. Перезапустіть застосунок для ініціалізації з новою особою.';
  }

  @override
  String get settingsRestartNow => 'Перезапустити зараз';

  @override
  String get settingsLater => 'Пізніше';

  @override
  String get profileGroupLabel => 'Група';

  @override
  String get profileAddButton => 'Додати';

  @override
  String get profileKickButton => 'Виключити';

  @override
  String get dataSectionTitle => 'Дані';

  @override
  String get dataBackupMessages => 'Резервна копія повідомлень';

  @override
  String get dataBackupPasswordSubtitle =>
      'Оберіть пароль для шифрування резервної копії.';

  @override
  String get dataBackupConfirmLabel => 'Створити копію';

  @override
  String get dataCreatingBackup => 'Створення копії';

  @override
  String get dataBackupPreparing => 'Підготовка...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Експорт повідомлення $done з $total...';
  }

  @override
  String get dataBackupSavingFile => 'Збереження файлу...';

  @override
  String get dataSaveMessageBackupDialog => 'Зберегти резервну копію';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Копію збережено ($count повідомлень)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Помилка резервного копіювання — дані не експортовано';

  @override
  String dataBackupFailedError(String error) {
    return 'Помилка резервного копіювання: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Обрати резервну копію';

  @override
  String get dataInvalidBackupFile =>
      'Недійсний файл резервної копії (занадто малий)';

  @override
  String get dataNotValidBackupFile => 'Це не файл резервної копії Pulse';

  @override
  String get dataRestoreMessages => 'Відновити повідомлення';

  @override
  String get dataRestorePasswordSubtitle =>
      'Введіть пароль, використаний при створенні копії.';

  @override
  String get dataRestoreConfirmLabel => 'Відновити';

  @override
  String get dataRestoringMessages => 'Відновлення повідомлень';

  @override
  String get dataRestoreDecrypting => 'Розшифрування...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Імпорт повідомлення $done з $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Відновлення не вдалося — неправильний пароль або пошкоджений файл';

  @override
  String dataRestoreSuccess(int count) {
    return 'Відновлено $count нових повідомлень';
  }

  @override
  String get dataRestoreNothingNew =>
      'Нових повідомлень немає (усі вже існують)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Помилка відновлення: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Обрати експорт ключів';

  @override
  String get dataNotValidKeyFile => 'Це не файл експорту ключів Pulse';

  @override
  String get dataExportKeys => 'Експорт ключів';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Оберіть пароль для шифрування ключів.';

  @override
  String get dataExportKeysConfirmLabel => 'Експорт';

  @override
  String get dataExportingKeys => 'Експорт ключів';

  @override
  String get dataExportingKeysStatus => 'Шифрування ключів...';

  @override
  String get dataSaveKeyExportDialog => 'Зберегти експорт ключів';

  @override
  String dataKeysExportedTo(String path) {
    return 'Ключі експортовано:\n$path';
  }

  @override
  String get dataExportFailed => 'Експорт не вдався — ключів не знайдено';

  @override
  String dataExportFailedError(String error) {
    return 'Помилка експорту: $error';
  }

  @override
  String get dataImportKeys => 'Імпорт ключів';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Введіть пароль, використаний при експорті ключів.';

  @override
  String get dataImportKeysConfirmLabel => 'Імпорт';

  @override
  String get dataImportingKeys => 'Імпорт ключів';

  @override
  String get dataImportingKeysStatus => 'Розшифрування ключів...';

  @override
  String get dataImportFailed =>
      'Імпорт не вдався — неправильний пароль або пошкоджений файл';

  @override
  String dataImportFailedError(String error) {
    return 'Помилка імпорту: $error';
  }

  @override
  String get securitySectionTitle => 'Безпека';

  @override
  String get securityIncorrectPassword => 'Неправильний пароль';

  @override
  String get securityPasswordUpdated => 'Пароль оновлено';

  @override
  String get appearanceSectionTitle => 'Зовнішній вигляд';

  @override
  String appearanceExportFailed(String error) {
    return 'Помилка експорту: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Збережено в $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Помилка збереження: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Помилка імпорту: $error';
  }

  @override
  String get aboutSectionTitle => 'Про застосунок';

  @override
  String get providerPublicKey => 'Публічний ключ';

  @override
  String get providerRelay => 'Реле';

  @override
  String get providerAutoConfigured =>
      'Налаштовано автоматично з пароля відновлення. Реле виявляється автоматично.';

  @override
  String get providerKeyStoredLocally =>
      'Ваш ключ зберігається локально в захищеному сховищі — ніколи не надсилається на сервер.';

  @override
  String get providerSessionInfo =>
      'Session Network — E2EE з цибулевою маршрутизацією. Ваш Session ID генерується автоматично і зберігається безпечно. Вузли автоматично знаходяться з вбудованих початкових вузлів.';

  @override
  String get providerAdvanced => 'Додатково';

  @override
  String get providerSaveAndConnect => 'Зберегти та підключитися';

  @override
  String get providerAddSecondaryInbox => 'Додати додаткову скриньку';

  @override
  String get providerSecondaryInboxes => 'Додаткові скриньки';

  @override
  String get providerYourInboxProvider => 'Ваш провайдер вхідних';

  @override
  String get providerConnectionDetails => 'Параметри підключення';

  @override
  String get addContactTitle => 'Додати контакт';

  @override
  String get addContactInviteLinkLabel => 'Посилання-запрошення або адреса';

  @override
  String get addContactTapToPaste => 'Натисніть, щоб вставити посилання';

  @override
  String get addContactPasteTooltip => 'Вставити з буфера обміну';

  @override
  String get addContactAddressDetected => 'Адресу контакту виявлено';

  @override
  String addContactRoutesDetected(int count) {
    return 'Виявлено $count маршрутів — SmartRouter обере найшвидший';
  }

  @override
  String get addContactFetchingProfile => 'Завантаження профілю…';

  @override
  String addContactProfileFound(String name) {
    return 'Знайдено: $name';
  }

  @override
  String get addContactNoProfileFound => 'Профіль не знайдено';

  @override
  String get addContactDisplayNameLabel => 'Відображуване імʼя';

  @override
  String get addContactDisplayNameHint => 'Як ви хочете назвати цей контакт?';

  @override
  String get addContactAddManually => 'Додати адресу вручну';

  @override
  String get addContactButton => 'Додати контакт';

  @override
  String get networkDiagnosticsTitle => 'Діагностика мережі';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr-реле';

  @override
  String get networkDiagnosticsDirect => 'Прямі';

  @override
  String get networkDiagnosticsTorOnly => 'Тільки через Tor';

  @override
  String get networkDiagnosticsBest => 'Найкраще';

  @override
  String get networkDiagnosticsNone => 'немає';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Статус';

  @override
  String get networkDiagnosticsConnected => 'Підключено';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Підключення $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Вимк.';

  @override
  String get networkDiagnosticsTransport => 'Транспорт';

  @override
  String get networkDiagnosticsInfrastructure => 'Інфраструктура';

  @override
  String get networkDiagnosticsSessionNodes => 'Session вузли';

  @override
  String get networkDiagnosticsTurnServers => 'TURN-сервери';

  @override
  String get networkDiagnosticsLastProbe => 'Остання перевірка';

  @override
  String get networkDiagnosticsRunning => 'Виконується...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Запустити діагностику';

  @override
  String get networkDiagnosticsForceReprobe => 'Примусова повна перевірка';

  @override
  String get networkDiagnosticsJustNow => 'щойно';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes хв. тому';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours год. тому';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days дн. тому';
  }

  @override
  String get homeNoEch => 'Немає ECH';

  @override
  String get homeNoEchTooltip =>
      'uTLS-проксі недоступний — ECH вимкнено.\nTLS-відбиток видимий для DPI.';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Збережено та підключено до $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Вбудований Tor не запустився';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon не запустився';

  @override
  String get verifyTitle => 'Перевірка номера безпеки';

  @override
  String get verifyIdentityVerified => 'Особу підтверджено';

  @override
  String get verifyNotYetVerified => 'Ще не підтверджено';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Ви підтвердили номер безпеки $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Порівняйте ці номери з $name особисто або через надійний канал.';
  }

  @override
  String get verifyExplanation =>
      'Кожна розмова має унікальний номер безпеки. Якщо ви обидва бачите однакові номери на своїх пристроях, зʼєднання підтверджено наскрізним шифруванням.';

  @override
  String verifyContactKey(String name) {
    return 'Ключ $name';
  }

  @override
  String get verifyYourKey => 'Ваш ключ';

  @override
  String get verifyRemoveVerification => 'Зняти підтвердження';

  @override
  String get verifyMarkAsVerified => 'Позначити як перевірений';

  @override
  String verifyAfterReinstall(String name) {
    return 'Якщо $name перевстановить застосунок, номер безпеки зміниться і підтвердження буде знято автоматично.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Позначайте як перевірений лише після порівняння номерів з $name під час голосового дзвінка або особисто.';
  }

  @override
  String get verifyNoSession =>
      'Сеанс шифрування ще не встановлено. Спочатку надішліть повідомлення для генерації номерів безпеки.';

  @override
  String get verifyNoKeyAvailable => 'Ключ недоступний';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Відбиток $label скопійовано';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL бази даних';

  @override
  String get providerOptionalHint => 'Необовʼязково';

  @override
  String get providerWebApiKeyLabel => 'Web API-ключ';

  @override
  String get providerOptionalForPublicDb => 'Необовʼязково для публічної БД';

  @override
  String get providerRelayUrlLabel => 'URL реле';

  @override
  String get providerPrivateKeyLabel => 'Приватний ключ';

  @override
  String get providerPrivateKeyNsecLabel => 'Приватний ключ (nsec)';

  @override
  String get providerStorageNodeLabel => 'URL вузла зберігання (необовʼязково)';

  @override
  String get providerStorageNodeHint =>
      'Залиште порожнім для вбудованих вузлів';

  @override
  String get transferInvalidCodeFormat =>
      'Нерозпізнаний формат коду — має починатися з LAN: або NOS:';

  @override
  String get profileCardFingerprintCopied => 'Відбиток скопійовано';

  @override
  String get profileCardAboutHint => 'Конфіденційність понад усе 🔒';

  @override
  String get profileCardSaveButton => 'Зберегти профіль';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Експорт зашифрованих повідомлень, контактів та аватарів у файл';

  @override
  String get callVideo => 'Відео';

  @override
  String get callAudio => 'Аудіо';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Доставлено: $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Доставлено: $count';
  }

  @override
  String get groupStatusDialogTitle => 'Відомості про повідомлення';

  @override
  String get groupStatusRead => 'Прочитано';

  @override
  String get groupStatusDelivered => 'Доставлено';

  @override
  String get groupStatusPending => 'Очікування';

  @override
  String get groupStatusNoData => 'Дані про доставку ще не отримано';

  @override
  String get profileTransferAdmin => 'Призначити адміном';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Призначити $name новим адміністратором?';
  }

  @override
  String get profileTransferAdminBody =>
      'Ви втратите права адміністратора. Цю дію не можна скасувати.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name тепер адміністратор';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Політика конфіденційності';

  @override
  String get privacyOverviewHeading => 'Огляд';

  @override
  String get privacyOverviewBody =>
      'Pulse — месенджер без серверів із наскрізним шифруванням. Конфіденційність — це не функція, а архітектура. Серверів Pulse не існує. Жоден обліковий запис ніде не зберігається. Розробники не збирають, не передають і не зберігають жодних даних.';

  @override
  String get privacyDataCollectionHeading => 'Збір даних';

  @override
  String get privacyDataCollectionBody =>
      'Pulse не збирає жодних персональних даних:\n\n- Email, номер телефону та справжнє імʼя не потрібні\n- Жодної аналітики, відстеження чи телеметрії\n- Жодних рекламних ідентифікаторів\n- Жодного доступу до списку контактів\n- Жодних хмарних резервних копій (повідомлення існують лише на вашому пристрої)\n- Жодні метадані не надсилаються на сервери Pulse (їх не існує)';

  @override
  String get privacyEncryptionHeading => 'Шифрування';

  @override
  String get privacyEncryptionBody =>
      'Усі повідомлення шифруються за протоколом Signal (Double Ratchet з узгодженням ключів X3DH). Ключі шифрування генеруються та зберігаються виключно на вашому пристрої. Ніхто — включно з розробниками — не може прочитати ваші повідомлення.';

  @override
  String get privacyNetworkHeading => 'Мережева архітектура';

  @override
  String get privacyNetworkBody =>
      'Pulse використовує федеративні транспортні адаптери (Nostr-реле, вузли Session/Oxen, Firebase Realtime Database, LAN). Через ці транспорти передається лише зашифрований текст. Оператори реле бачать вашу IP-адресу та обсяг трафіку, але не можуть розшифрувати вміст повідомлень.\n\nПри увімкненому Tor ваша IP-адреса прихована і від операторів реле.';

  @override
  String get privacyStunHeading => 'STUN/TURN сервери';

  @override
  String get privacyStunBody =>
      'Голосові та відеодзвінки використовують WebRTC із шифруванням DTLS-SRTP. STUN-сервери (для визначення публічної IP при peer-to-peer зʼєднанні) та TURN-сервери (для ретрансляції медіа при неможливості прямого зʼєднання) бачать вашу IP-адресу та тривалість дзвінка, але не можуть розшифрувати його вміст.\n\nУ налаштуваннях можна вказати власний TURN-сервер для максимальної приватності.';

  @override
  String get privacyCrashHeading => 'Звіти про помилки';

  @override
  String get privacyCrashBody =>
      'Якщо звіти про помилки Sentry увімкнені (через SENTRY_DSN при збірці), можуть надсилатися анонімні звіти. Вони не містять вмісту повідомлень, контактної інформації та персональних даних. Звіти про помилки можна вимкнути при збірці, не вказуючи DSN.';

  @override
  String get privacyPasswordHeading => 'Пароль та ключі';

  @override
  String get privacyPasswordBody =>
      'Пароль відновлення використовується для генерації криптографічних ключів через Argon2id (KDF з високими вимогами до памʼяті). Пароль ніколи нікуди не передається. Якщо ви загубите пароль, обліковий запис не можна відновити — серверів для скидання не існує.';

  @override
  String get privacyFontsHeading => 'Шрифти';

  @override
  String get privacyFontsBody =>
      'Pulse постачається з усіма шрифтами локально. Жодних запитів до Google Fonts або інших зовнішніх сервісів шрифтів не виконується.';

  @override
  String get privacyThirdPartyHeading => 'Сторонні сервіси';

  @override
  String get privacyThirdPartyBody =>
      'Pulse не інтегрується з рекламними мережами, провайдерами аналітики, соціальними мережами чи брокерами даних. Єдині мережеві підключення — до транспортних реле, які ви налаштували.';

  @override
  String get privacyOpenSourceHeading => 'Відкритий вихідний код';

  @override
  String get privacyOpenSourceBody =>
      'Pulse — програма з відкритим вихідним кодом. Ви можете перевірити повний вихідний код, щоб переконатися у відповідності заявам про конфіденційність.';

  @override
  String get privacyContactHeading => 'Контакт';

  @override
  String get privacyContactBody =>
      'З питань конфіденційності створіть issue у репозиторії проєкту.';

  @override
  String get privacyLastUpdated => 'Останнє оновлення: березень 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Помилка збереження: $error';
  }

  @override
  String get themeEngineTitle => 'Двигун тем';

  @override
  String get torBuiltInTitle => 'Вбудований Tor';

  @override
  String get torConnectedSubtitle => 'Підключено — Nostr через 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Підключення… $pct%';
  }

  @override
  String get torNotRunning => 'Не запущено — натисніть для перезапуску';

  @override
  String get torDescription =>
      'Маршрутизація Nostr через Tor (Snowflake для мереж із цензурою)';

  @override
  String get torNetworkDiagnostics => 'Діагностика мережі';

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
  String get torPtPlain => 'Прямий';

  @override
  String get torTimeoutLabel => 'Тайм-аут: ';

  @override
  String get torInfoDescription =>
      'При увімкненні WebSocket-зʼєднання Nostr проходять через Tor (SOCKS5). Tor Browser слухає 127.0.0.1:9150. Демон tor використовує порт 9050. Зʼєднання Firebase не зачіпаються.';

  @override
  String get torRouteNostrTitle => 'Маршрутизувати Nostr через Tor';

  @override
  String get torManagedByBuiltin => 'Керується вбудованим Tor';

  @override
  String get torActiveRouting => 'Активний — трафік Nostr через Tor';

  @override
  String get torDisabled => 'Вимкнено';

  @override
  String get torProxySocks5 => 'Tor Проксі (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Хост проксі';

  @override
  String get torProxyPortLabel => 'Порт';

  @override
  String get torPortInfo => 'Tor Browser: порт 9150  •  демон tor: порт 9050';

  @override
  String get torForceNostrTitle => 'Маршрутизувати повідомлення через Tor';

  @override
  String get torForceNostrSubtitle =>
      'Усі з\'єднання з Nostr relay проходитимуть через Tor. Повільніше, але приховує вашу IP-адресу від relay.';

  @override
  String get torForceNostrDisabled => 'Спочатку потрібно увімкнути Tor';

  @override
  String get torForcePulseTitle => 'Маршрутизувати Pulse relay через Tor';

  @override
  String get torForcePulseSubtitle =>
      'Усі з\'єднання з Pulse relay проходитимуть через Tor. Повільніше, але приховує вашу IP-адресу від сервера.';

  @override
  String get torForcePulseDisabled => 'Спочатку потрібно увімкнути Tor';

  @override
  String get i2pProxySocks5 => 'I2P Проксі (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P використовує SOCKS5 на порту 4447 за замовчуванням. Підключайтеся до Nostr-реле через I2P-outproxy для звʼязку з користувачами на будь-якому транспорті. Tor має пріоритет.';

  @override
  String get i2pRouteNostrTitle => 'Маршрутизувати Nostr через I2P';

  @override
  String get i2pActiveRouting => 'Активний — трафік Nostr через I2P';

  @override
  String get i2pDisabled => 'Вимкнено';

  @override
  String get i2pProxyHostLabel => 'Хост проксі';

  @override
  String get i2pProxyPortLabel => 'Порт';

  @override
  String get i2pPortInfo => 'I2P Router SOCKS5 порт за замовчуванням: 4447';

  @override
  String get customProxySocks5 => 'Власний проксі (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker реле';

  @override
  String get customProxyInfoDescription =>
      'Проксі направляє трафік через V2Ray/Xray/Shadowsocks. CF Worker працює як персональний проксі-реле на Cloudflare CDN — GFW бачить *.workers.dev, а не справжнє реле.';

  @override
  String get customSocks5ProxyTitle => 'Власний SOCKS5 проксі';

  @override
  String get customProxyActive => 'Активний — трафік через SOCKS5';

  @override
  String get customProxyDisabled => 'Вимкнено';

  @override
  String get customProxyHostLabel => 'Хост проксі';

  @override
  String get customProxyPortLabel => 'Порт';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Домен Worker (необовʼязково)';

  @override
  String get customWorkerHelpTitle =>
      'Як розгорнути CF Worker реле (безкоштовно)';

  @override
  String get customWorkerScriptCopied => 'Скрипт скопійовано!';

  @override
  String get customWorkerStep1 =>
      '1. Відкрийте dash.cloudflare.com → Workers & Pages\n2. Створіть Worker → вставте цей скрипт:\n';

  @override
  String get customWorkerStep2 =>
      '3. Розгорніть → скопіюйте домен (напр. my-relay.user.workers.dev)\n4. Вставте домен вище → Збережіть\n\nЗастосунок підключається: wss://domain/?r=relay_url\nGFW бачить: зʼєднання з *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Підключено — SOCKS5 на 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Підключення…';

  @override
  String get psiphonNotRunning => 'Не запущено — натисніть для перезапуску';

  @override
  String get psiphonDescription =>
      'Швидкий тунель (~3с запуск, 2000+ ротованих VPS)';

  @override
  String get turnCommunityServers => 'Громадські TURN-сервери';

  @override
  String get turnCustomServer => 'Власний TURN-сервер (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN-сервери лише ретранслюють вже зашифровані потоки (DTLS-SRTP). Оператор бачить вашу IP та обсяг трафіку, але не може розшифрувати дзвінки. TURN використовується лише при неможливості прямого P2P (~15–20%).';

  @override
  String get turnFreeLabel => 'БЕЗКОШТОВНО';

  @override
  String get turnServerUrlLabel => 'URL TURN-сервера';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 або turns:...';

  @override
  String get turnUsernameLabel => 'Імʼя користувача';

  @override
  String get turnPasswordLabel => 'Пароль';

  @override
  String get turnOptionalHint => 'Необовʼязково';

  @override
  String get turnCustomInfo =>
      'Розгорніть coturn на будь-якому VPS за \$5/міс для максимального контролю. Облікові дані зберігаються локально.';

  @override
  String get themePickerAppearance => 'Оформлення';

  @override
  String get themePickerAccentColor => 'Акцентний колір';

  @override
  String get themeModeLight => 'Світла';

  @override
  String get themeModeDark => 'Темна';

  @override
  String get themeModeSystem => 'Система';

  @override
  String get themeDynamicPresets => 'Пресети';

  @override
  String get themeDynamicPrimaryColor => 'Основний колір';

  @override
  String get themeDynamicBorderRadius => 'Скруглення';

  @override
  String get themeDynamicFont => 'Шрифт';

  @override
  String get themeDynamicAppearance => 'Оформлення';

  @override
  String get themeDynamicUiStyle => 'Стиль інтерфейсу';

  @override
  String get themeDynamicUiStyleDescription =>
      'Визначає оформлення діалогів, перемикачів та індикаторів.';

  @override
  String get themeDynamicSharp => 'Гострий';

  @override
  String get themeDynamicRound => 'Круглий';

  @override
  String get themeDynamicModeDark => 'Темна';

  @override
  String get themeDynamicModeLight => 'Світла';

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
      'Невірний URL Firebase. Очікується https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Невірний URL реле. Очікується wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Невірний URL Pulse-сервера. Очікується https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'URL сервера';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'Код запрошення';

  @override
  String get providerPulseInviteHint => 'Код запрошення (якщо потрібен)';

  @override
  String get providerPulseInfo =>
      'Власне реле. Ключі отримані з пароля відновлення.';

  @override
  String get providerScreenTitle => 'Скриньки';

  @override
  String get providerSecondaryInboxesHeader => 'ДОДАТКОВІ СКРИНЬКИ';

  @override
  String get providerSecondaryInboxesInfo =>
      'Додаткові скриньки отримують повідомлення одночасно для надійності.';

  @override
  String get providerRemoveTooltip => 'Видалити';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... or hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... or hex private key';

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
  String get emojiNoRecent => 'Немає нещодавніх емодзі';

  @override
  String get emojiSearchHint => 'Пошук емодзі...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Натисніть для чату';

  @override
  String get imageViewerSaveToDownloads => 'Зберегти в Завантаження';

  @override
  String imageViewerSavedTo(String path) {
    return 'Збережено в $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Мова';

  @override
  String get settingsLanguageSubtitle => 'Мова відображення застосунку';

  @override
  String get settingsLanguageSystem => 'Системний за замовчуванням';

  @override
  String get onboardingLanguageTitle => 'Виберіть мову';

  @override
  String get onboardingLanguageSubtitle =>
      'Ви можете змінити це пізніше в Налаштуваннях';

  @override
  String get videoNoteRecord => 'Записати відеоповідомлення';

  @override
  String get videoNoteTapToRecord => 'Торкніться для запису';

  @override
  String get videoNoteTapToStop => 'Торкніться для зупинки';

  @override
  String get videoNoteCameraPermission => 'Доступ до камери заборонено';

  @override
  String get videoNoteMaxDuration => 'Максимум 30 секунд';

  @override
  String get videoNoteNotSupported =>
      'Відеонотатки не підтримуються на цій платформі';

  @override
  String get navChats => 'Чати';

  @override
  String get navUpdates => 'Оновлення';

  @override
  String get navCalls => 'Дзвінки';

  @override
  String get filterAll => 'Усі';

  @override
  String get filterUnread => 'Непрочитані';

  @override
  String get filterGroups => 'Групи';

  @override
  String get callsNoRecent => 'Немає нещодавніх дзвінків';

  @override
  String get callsEmptySubtitle => 'Ваша історія дзвінків з\'явиться тут';

  @override
  String get appBarEncrypted => 'наскрізне шифрування';

  @override
  String get newStatus => 'Новий статус';

  @override
  String get newCall => 'Новий дзвінок';

  @override
  String get joinChannelTitle => 'Приєднатися до каналу';

  @override
  String get joinChannelDescription => 'URL КАНАЛУ';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'Отримання інформації про канал…';

  @override
  String get joinChannelNotFound => 'Канал не знайдено за цією адресою';

  @override
  String get joinChannelNetworkError => 'Не вдалося з\'єднатися з сервером';

  @override
  String get joinChannelAlreadyJoined => 'Вже підписані';

  @override
  String get joinChannelButton => 'Приєднатися';

  @override
  String get channelFeedEmpty => 'Ще немає публікацій';

  @override
  String get channelLeave => 'Покинути канал';

  @override
  String get channelLeaveConfirm =>
      'Покинути цей канал? Кешовані публікації буде видалено.';

  @override
  String get channelInfo => 'Інформація про канал';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'змінено';

  @override
  String get channelLoadMore => 'Завантажити ще';

  @override
  String get channelSearchPosts => 'Пошук публікацій…';

  @override
  String get channelNoResults => 'Немає збігів';

  @override
  String get channelUrl => 'URL каналу';

  @override
  String get channelCreated => 'Приєднано';

  @override
  String channelPostCount(int count) {
    return '$count публікацій';
  }

  @override
  String get channelCopyUrl => 'Копіювати URL';

  @override
  String get setupNext => 'Далі';

  @override
  String get setupKeyWarning =>
      'Для вас буде згенеровано ключ відновлення. Це єдиний спосіб відновити обліковий запис на новому пристрої — сервера немає, скидання пароля немає.';

  @override
  String get setupKeyTitle => 'Ваш ключ відновлення';

  @override
  String get setupKeySubtitle =>
      'Запишіть цей ключ і зберігайте його у надійному місці. Він потрібен для відновлення облікового запису на новому пристрої.';

  @override
  String get setupKeyCopied => 'Скопійовано!';

  @override
  String get setupKeyWroteItDown => 'Я записав';

  @override
  String get setupKeyWarnBody =>
      'Запишіть цей ключ як резервну копію. Ви також можете переглянути його пізніше в Налаштування → Безпека.';

  @override
  String get setupVerifyTitle => 'Перевірте ключ відновлення';

  @override
  String get setupVerifySubtitle =>
      'Введіть ключ повторно, щоб переконатися, що ви його правильно зберегли.';

  @override
  String get setupVerifyButton => 'Перевірити';

  @override
  String get setupKeyMismatch =>
      'Ключ не збігається. Перевірте та спробуйте ще раз.';

  @override
  String get setupSkipVerify => 'Пропустити перевірку';

  @override
  String get setupSkipVerifyTitle => 'Пропустити перевірку?';

  @override
  String get setupSkipVerifyBody =>
      'Якщо ви втратите ключ відновлення, ваш обліковий запис неможливо буде відновити. Ви впевнені?';

  @override
  String get setupCreatingAccount => 'Створення облікового запису…';

  @override
  String get setupRestoringAccount => 'Відновлення облікового запису…';

  @override
  String get restoreKeyInfoBanner =>
      'Введіть ключ відновлення — вашу адресу (Nostr + Session) буде відновлено автоматично. Контакти та повідомлення зберігалися лише локально.';

  @override
  String get restoreKeyHint => 'Ключ відновлення';

  @override
  String get settingsViewRecoveryKey => 'Переглянути ключ відновлення';

  @override
  String get settingsViewRecoveryKeySubtitle =>
      'Показати ключ відновлення облікового запису';

  @override
  String get settingsRecoveryKeyNotStored =>
      'Ключ відновлення недоступний (створений до цієї функції)';

  @override
  String get settingsRecoveryKeyWarning =>
      'Зберігайте цей ключ у безпеці. Будь-хто, хто його має, може відновити ваш обліковий запис на іншому пристрої.';

  @override
  String get replaceIdentityTitle => 'Замінити існуючий обліковий запис?';

  @override
  String get replaceIdentityBodyRestore =>
      'На цьому пристрої вже є обліковий запис. Відновлення назавжди замінить ваш поточний ключ Nostr та сід Oxen. Усі контакти втратять можливість зв\'язатися з вашою поточною адресою.\n\nЦю дію не можна скасувати.';

  @override
  String get replaceIdentityBodyCreate =>
      'На цьому пристрої вже є обліковий запис. Створення нового назавжди замінить ваш поточний ключ Nostr та сід Oxen. Усі контакти втратять можливість зв\'язатися з вашою поточною адресою.\n\nЦю дію не можна скасувати.';

  @override
  String get replace => 'Замінити';

  @override
  String get callNoScreenSources => 'Немає доступних джерел екрана';

  @override
  String get callScreenShareQuality => 'Якість демонстрації екрана';

  @override
  String get callFrameRate => 'Частота кадрів';

  @override
  String get callResolution => 'Роздільність';

  @override
  String get callAutoResolution => 'Авто = рідна роздільність екрана';

  @override
  String get callStartSharing => 'Почати демонстрацію';

  @override
  String get callCameraUnavailable =>
      'Камера недоступна — можливо, використовується іншим додатком';

  @override
  String get themeResetToDefaults => 'Скинути до стандартних';

  @override
  String get backupSaveToDownloadsTitle =>
      'Зберегти резервну копію в Завантаження?';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'Засіб вибору файлів недоступний. Резервну копію буде збережено в:\n$path';
  }

  @override
  String get systemLabel => 'Система';

  @override
  String get next => 'Далі';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return 'Ще $remaining натискань для увімкнення режиму розробника';
  }

  @override
  String get devModeEnabled => 'Режим розробника увімкнено';

  @override
  String get devTools => 'Інструменти розробника';

  @override
  String get devAdapterDiagnostics => 'Перемикачі адаптерів та діагностика';

  @override
  String get devEnableAll => 'Увімкнути все';

  @override
  String get devDisableAll => 'Вимкнути все';

  @override
  String get turnUrlValidation =>
      'URL TURN повинен починатися з turn: або turns: (макс. 512 символів)';

  @override
  String get callMissedCall => 'Пропущений виклик';

  @override
  String get callOutgoingCall => 'Вихідний виклик';

  @override
  String get callIncomingCall => 'Вхідний виклик';

  @override
  String get mediaMissingData => 'Відсутні дані медіа';

  @override
  String get mediaDownloadFailed => 'Помилка завантаження';

  @override
  String get mediaDecryptFailed => 'Помилка розшифрування';

  @override
  String get callEndCallBanner => 'Завершити виклик';

  @override
  String get meFallback => 'Я';

  @override
  String get imageSaveToDownloads => 'Зберегти в Завантаження';

  @override
  String imageSavedToPath(String path) {
    return 'Збережено в $path';
  }

  @override
  String get callScreenShareRequiresPermission =>
      'Для демонстрації екрана потрібен дозвіл';

  @override
  String get callScreenShareUnavailable => 'Демонстрація екрана недоступна';

  @override
  String get statusJustNow => 'Щойно';

  @override
  String statusMinutesAgo(int minutes) {
    return '$minutesхв тому';
  }

  @override
  String statusHoursAgo(int hours) {
    return '$hoursгод тому';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count маршрутів',
      one: '1 маршрут',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => 'Готовий до додавання';

  @override
  String groupSelectedCount(int count) {
    return '$count обрано';
  }

  @override
  String get paste => 'Вставити';

  @override
  String get sfuAudioOnly => 'Лише аудіо';

  @override
  String sfuParticipants(int count) {
    return '$count учасників';
  }

  @override
  String get dataUnencryptedBackup => 'Незашифрована резервна копія';

  @override
  String get dataUnencryptedBackupBody =>
      'Цей файл є незашифрованою резервною копією особистості та перезапише ваші поточні ключі. Імпортуйте лише файли, створені вами. Продовжити?';

  @override
  String get dataImportAnyway => 'Імпортувати все одно';

  @override
  String get securityStorageError =>
      'Помилка безпечного сховища — перезапустіть додаток';

  @override
  String get aboutDevModeActive => 'Режим розробника активний';

  @override
  String get themeColors => 'Кольори';

  @override
  String get themePrimaryAccent => 'Основний акцент';

  @override
  String get themeSecondaryAccent => 'Вторинний акцент';

  @override
  String get themeBackground => 'Фон';

  @override
  String get themeSurface => 'Поверхня';

  @override
  String get themeChatBubbles => 'Бульбашки чату';

  @override
  String get themeOutgoingMessage => 'Вихідне повідомлення';

  @override
  String get themeIncomingMessage => 'Вхідне повідомлення';

  @override
  String get themeShape => 'Форма';

  @override
  String get devSectionDeveloper => 'Розробник';

  @override
  String get devAdapterChannelsHint =>
      'Канали адаптерів — вимкніть для тестування окремих транспортів.';

  @override
  String get devNostrRelays => 'Nostr-реле (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Мережа Session';

  @override
  String get devPulseRelay => 'Pulse самостійно розміщений relay';

  @override
  String get devLanNetwork => 'Локальна мережа (UDP/TCP)';

  @override
  String get devSectionCalls => 'Виклики';

  @override
  String get devForceTurnRelay => 'Примусовий TURN-relay';

  @override
  String get devForceTurnRelaySubtitle =>
      'Вимкнути P2P — всі виклики лише через TURN-сервери';

  @override
  String get devRestartWarning =>
      '⚠ Зміни набудуть чинності при наступному надсиланні/виклику. Перезапустіть додаток для вхідних.';

  @override
  String get messageRequest => 'Message request';

  @override
  String messageRequestFrom(String name) {
    return 'Message request from $name';
  }

  @override
  String get acceptContact => 'Accept';

  @override
  String get blockContact => 'Block';

  @override
  String get blockedContactsEmpty => 'No blocked contacts';

  @override
  String get pendingLimitReached => 'Too many pending requests';
}
