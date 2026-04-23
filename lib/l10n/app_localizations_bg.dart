// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class AppLocalizationsBg extends AppLocalizations {
  AppLocalizationsBg([String locale = 'bg']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Търсене в съобщенията...';

  @override
  String get search => 'Търсене';

  @override
  String get clearSearch => 'Изчистване на търсенето';

  @override
  String get closeSearch => 'Затваряне на търсенето';

  @override
  String get moreOptions => 'Още опции';

  @override
  String get back => 'Назад';

  @override
  String get cancel => 'Отказ';

  @override
  String get close => 'Затваряне';

  @override
  String get confirm => 'Потвърждаване';

  @override
  String get remove => 'Премахване';

  @override
  String get save => 'Запазване';

  @override
  String get add => 'Добавяне';

  @override
  String get copy => 'Копиране';

  @override
  String get skip => 'Пропускане';

  @override
  String get done => 'Готово';

  @override
  String get apply => 'Прилагане';

  @override
  String get export => 'Експортиране';

  @override
  String get import => 'Импортиране';

  @override
  String get homeNewGroup => 'Нова група';

  @override
  String get homeSettings => 'Настройки';

  @override
  String get homeSearching => 'Търсене в съобщенията...';

  @override
  String get homeNoResults => 'Няма намерени резултати';

  @override
  String get homeNoChatHistory => 'Все още няма история на чатовете';

  @override
  String homeTransportSwitched(String address) {
    return 'Транспортът е сменен → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name ви звъни...';
  }

  @override
  String get homeAccept => 'Приемане';

  @override
  String get homeDecline => 'Отхвърляне';

  @override
  String get homeLoadEarlier => 'Зареждане на по-стари съобщения';

  @override
  String get homeChats => 'Чатове';

  @override
  String get homeSelectConversation => 'Изберете разговор';

  @override
  String get homeNoChatsYet => 'Все още няма чатове';

  @override
  String get homeAddContactToStart => 'Добавете контакт, за да започнете';

  @override
  String get homeNewChat => 'Нов чат';

  @override
  String get homeNewChatTooltip => 'Нов чат';

  @override
  String get homeIncomingCallTitle => 'Входящо обаждане';

  @override
  String get homeIncomingGroupCallTitle => 'Входящо групово обаждане';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — входящо групово обаждане';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Няма чатове, съответстващи на \"$query\"';
  }

  @override
  String get homeSectionChats => 'Чатове';

  @override
  String get homeSectionMessages => 'Съобщения';

  @override
  String get homeDbEncryptionUnavailable =>
      'Криптирането на базата данни не е налично — инсталирайте SQLCipher за пълна защита';

  @override
  String get chatFileTooLargeGroup =>
      'Файлове над 512 KB не се поддържат в групови чатове';

  @override
  String get chatLargeFile => 'Голям файл';

  @override
  String get chatCancel => 'Отказ';

  @override
  String get chatSend => 'Изпращане';

  @override
  String get chatFileTooLarge =>
      'Файлът е твърде голям — максималният размер е 100 MB';

  @override
  String get chatMicDenied => 'Достъпът до микрофона е отказан';

  @override
  String get chatVoiceFailed =>
      'Гласовото съобщение не можа да бъде запазено — проверете наличното място';

  @override
  String get chatScheduleFuture => 'Насроченото време трябва да е в бъдещето';

  @override
  String get chatToday => 'Днес';

  @override
  String get chatYesterday => 'Вчера';

  @override
  String get chatEdited => 'редактирано';

  @override
  String get chatYou => 'Вие';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Този файл е $size MB. Изпращането на големи файлове може да е бавно в някои мрежи. Да се продължи ли?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Ключът за сигурност на $name е променен. Натиснете, за да проверите.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Съобщението до $name не можа да бъде криптирано — съобщението не е изпратено.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Номерът за сигурност на $name е променен. Натиснете, за да проверите.';
  }

  @override
  String get chatNoMessagesFound => 'Няма намерени съобщения';

  @override
  String get chatMessagesE2ee => 'Съобщенията са криптирани от край до край';

  @override
  String get chatSayHello => 'Кажете здравей';

  @override
  String get appBarOnline => 'онлайн';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'пише';

  @override
  String get appBarSearchMessages => 'Търсене в съобщенията...';

  @override
  String get appBarMute => 'Заглушаване';

  @override
  String get appBarUnmute => 'Включване на звука';

  @override
  String get appBarMedia => 'Медия';

  @override
  String get appBarDisappearing => 'Изчезващи съобщения';

  @override
  String get appBarDisappearingOn => 'Изчезващи: включено';

  @override
  String get appBarGroupSettings => 'Настройки на групата';

  @override
  String get appBarSearchTooltip => 'Търсене в съобщенията';

  @override
  String get appBarVoiceCall => 'Гласово обаждане';

  @override
  String get appBarVideoCall => 'Видео обаждане';

  @override
  String get inputMessage => 'Съобщение...';

  @override
  String get inputAttachFile => 'Прикачване на файл';

  @override
  String get inputSendMessage => 'Изпращане на съобщение';

  @override
  String get inputRecordVoice => 'Записване на гласово съобщение';

  @override
  String get inputSendVoice => 'Изпращане на гласово съобщение';

  @override
  String get inputCancelReply => 'Отказ от отговор';

  @override
  String get inputCancelEdit => 'Отказ от редакция';

  @override
  String get inputCancelRecording => 'Отказ от записа';

  @override
  String get inputRecording => 'Записване…';

  @override
  String get inputEditingMessage => 'Редактиране на съобщение';

  @override
  String get inputPhoto => 'Снимка';

  @override
  String get inputVoiceMessage => 'Гласово съобщение';

  @override
  String get inputFile => 'Файл';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'и съобщения',
      one: 'о съобщение',
    );
    return '$count насрочен$_temp0';
  }

  @override
  String get callInitializing => 'Инициализиране на обаждането…';

  @override
  String get callConnecting => 'Свързване…';

  @override
  String get callConnectingRelay => 'Свързване (relay)…';

  @override
  String get callSwitchingRelay => 'Превключване към relay режим…';

  @override
  String get callConnectionFailed => 'Връзката е неуспешна';

  @override
  String get callReconnecting => 'Повторно свързване…';

  @override
  String get callEnded => 'Обаждането приключи';

  @override
  String get callLive => 'На живо';

  @override
  String get callEnd => 'Край';

  @override
  String get callEndCall => 'Край на обаждането';

  @override
  String get callMute => 'Заглушаване';

  @override
  String get callUnmute => 'Включване на звука';

  @override
  String get callSpeaker => 'Високоговорител';

  @override
  String get callCameraOn => 'Камера вкл.';

  @override
  String get callCameraOff => 'Камера изкл.';

  @override
  String get callShareScreen => 'Споделяне на екрана';

  @override
  String get callStopShare => 'Спиране на споделянето';

  @override
  String callTorBackup(String duration) {
    return 'Tor резерва · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor резервата е активна — основният път е недостъпен';

  @override
  String get callDirectFailed =>
      'Директната връзка е неуспешна — превключване към relay режим…';

  @override
  String get callTurnUnreachable =>
      'TURN сървърите са недостъпни. Добавете потребителски TURN в Настройки → Разширени.';

  @override
  String get callRelayMode => 'Relay режим е активен (ограничена мрежа)';

  @override
  String get callStarting => 'Стартиране на обаждането…';

  @override
  String get callConnectingToGroup => 'Свързване с групата…';

  @override
  String get callGroupOpenedInBrowser =>
      'Груповото обаждане е отворено в браузъра';

  @override
  String get callCouldNotOpenBrowser => 'Браузърът не можа да бъде отворен';

  @override
  String get callInviteLinkSent =>
      'Линкът за покана е изпратен до всички членове на групата.';

  @override
  String get callOpenLinkManually =>
      'Отворете линка по-горе ръчно или натиснете, за да опитате отново.';

  @override
  String get callJitsiNotE2ee =>
      'Jitsi обажданията НЕ са криптирани от край до край';

  @override
  String get callRetryOpenBrowser => 'Повторно отваряне на браузъра';

  @override
  String get callClose => 'Затваряне';

  @override
  String get callCamOn => 'Камера вкл.';

  @override
  String get callCamOff => 'Камера изкл.';

  @override
  String get noConnection =>
      'Няма връзка — съобщенията ще се наредят на опашка';

  @override
  String get connected => 'Свързан';

  @override
  String get connecting => 'Свързване…';

  @override
  String get disconnected => 'Прекъснат';

  @override
  String get offlineBanner =>
      'Няма връзка — съобщенията ще бъдат изпратени, когато сте отново онлайн';

  @override
  String get lanModeBanner => 'LAN режим — Без интернет · Само локална мрежа';

  @override
  String get probeCheckingNetwork => 'Проверка на мрежовата свързаност…';

  @override
  String get probeDiscoveringRelays =>
      'Откриване на relay-и чрез общностни директории…';

  @override
  String get probeStartingTor => 'Стартиране на Tor за зареждане…';

  @override
  String get probeFindingRelaysTor => 'Намиране на достъпни relay-и чрез Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'намерени са $count relay-я',
      one: 'намерен е $count relay',
    );
    return 'Мрежата е готова — $_temp0';
  }

  @override
  String get probeNoRelaysFound =>
      'Не са намерени достъпни relay-и — съобщенията може да закъснеят';

  @override
  String get jitsiWarningTitle => 'Не е криптирано от край до край';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet обажданията не са криптирани от Pulse. Използвайте само за неповерителни разговори.';

  @override
  String get jitsiConfirm => 'Присъединяване въпреки това';

  @override
  String get jitsiGroupWarningTitle => 'Не е криптирано от край до край';

  @override
  String get jitsiGroupWarningBody =>
      'Това обаждане има твърде много участници за вградената криптирана мрежа.\n\nЩе бъде отворен линк към Jitsi Meet във вашия браузър. Jitsi НЕ е криптиран от край до край — сървърът може да вижда обаждането ви.';

  @override
  String get jitsiContinueAnyway => 'Продължаване въпреки това';

  @override
  String get retry => 'Повторен опит';

  @override
  String get setupCreateAnonymousAccount => 'Създаване на анонимен акаунт';

  @override
  String get setupTapToChangeColor => 'Натиснете, за да смените цвета';

  @override
  String get setupReqMinLength => 'Поне 16 символа';

  @override
  String get setupReqVariety => '3 от 4: главни, малки букви, цифри, символи';

  @override
  String get setupReqMatch => 'Паролите съвпадат';

  @override
  String get setupYourNickname => 'Вашият псевдоним';

  @override
  String get setupRecoveryPassword => 'Парола за възстановяване (мин. 16)';

  @override
  String get setupConfirmPassword => 'Потвърдете паролата';

  @override
  String get setupMin16Chars => 'Минимум 16 символа';

  @override
  String get setupPasswordsDoNotMatch => 'Паролите не съвпадат';

  @override
  String get setupEntropyWeak => 'Слаба';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Силна';

  @override
  String get setupEntropyWeakNeedsVariety =>
      'Слаба (необходими са 3 вида символи)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits бита)';
  }

  @override
  String get setupPasswordWarning =>
      'Тази парола е единственият начин да възстановите акаунта си. Няма сървър — няма нулиране на паролата. Запомнете я или я запишете.';

  @override
  String get setupCreateAccount => 'Създаване на акаунт';

  @override
  String get setupAlreadyHaveAccount => 'Вече имате акаунт? ';

  @override
  String get setupRestore => 'Възстановяване →';

  @override
  String get restoreTitle => 'Възстановяване на акаунт';

  @override
  String get restoreInfoBanner =>
      'Въведете паролата си за възстановяване — адресът ви (Nostr + Session) ще бъде възстановен автоматично. Контактите и съобщенията бяха съхранени само локално.';

  @override
  String get restoreNewNickname =>
      'Нов псевдоним (може да се промени по-късно)';

  @override
  String get restoreButton => 'Възстановяване на акаунт';

  @override
  String get lockTitle => 'Pulse е заключен';

  @override
  String get lockSubtitle => 'Въведете паролата си, за да продължите';

  @override
  String get lockPasswordHint => 'Парола';

  @override
  String get lockUnlock => 'Отключване';

  @override
  String get lockPanicHint =>
      'Забравили сте паролата? Въведете паник ключа, за да изтриете всички данни.';

  @override
  String get lockTooManyAttempts =>
      'Твърде много опити. Изтриване на всички данни…';

  @override
  String get lockWrongPassword => 'Грешна парола';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Грешна парола — $attempts/$max опита';
  }

  @override
  String get onboardingSkip => 'Пропускане';

  @override
  String get onboardingNext => 'Напред';

  @override
  String get onboardingGetStarted => 'Създай акаунт';

  @override
  String get onboardingWelcomeTitle => 'Добре дошли в Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Децентрализиран месинджър с криптиране от край до край.\n\nБез централни сървъри. Без събиране на данни. Без задни вратички.\nВашите разговори принадлежат само на вас.';

  @override
  String get onboardingTransportTitle => 'Транспортно-агностичен';

  @override
  String get onboardingTransportBody =>
      'Използвайте Firebase, Nostr или и двете едновременно.\n\nСъобщенията се маршрутизират автоматично между мрежите. Вградена поддръжка на Tor и I2P за устойчивост срещу цензура.';

  @override
  String get onboardingSignalTitle => 'Signal + пост-квантов';

  @override
  String get onboardingSignalBody =>
      'Всяко съобщение е криптирано със Signal Protocol (Double Ratchet + X3DH) за секретност при препращане.\n\nДопълнително обвито с Kyber-1024 — NIST-стандартен пост-квантов алгоритъм — за защита от бъдещи квантови компютри.';

  @override
  String get onboardingKeysTitle => 'Вие притежавате ключовете си';

  @override
  String get onboardingKeysBody =>
      'Вашите идентификационни ключове никога не напускат устройството ви.\n\nSignal отпечатъците ви позволяват да проверявате контактите извън канала. TOFU (Trust On First Use) открива смяната на ключовете автоматично.';

  @override
  String get onboardingThemeTitle => 'Изберете вашия стил';

  @override
  String get onboardingThemeBody =>
      'Изберете тема и акцентен цвят. Можете да промените това по-късно в Настройки.';

  @override
  String get contactsNewChat => 'Нов чат';

  @override
  String get contactsAddContact => 'Добавяне на контакт';

  @override
  String get contactsSearchHint => 'Търсене...';

  @override
  String get contactsNewGroup => 'Нова група';

  @override
  String get contactsNoContactsYet => 'Все още няма контакти';

  @override
  String get contactsAddHint => 'Натиснете +, за да добавите адрес';

  @override
  String get contactsNoMatch => 'Няма съвпадащи контакти';

  @override
  String get contactsRemoveTitle => 'Премахване на контакт';

  @override
  String contactsRemoveMessage(String name) {
    return 'Да се премахне ли $name?';
  }

  @override
  String get contactsRemove => 'Премахване';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'а',
      one: '',
    );
    return '$count контакт$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Отваряне на линк';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Да се отвори ли този URL в браузъра?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Отваряне';

  @override
  String get bubbleSecurityWarning => 'Предупреждение за сигурност';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" е изпълним файл. Запазването и стартирането му може да навреди на устройството ви. Да се запази ли въпреки това?';
  }

  @override
  String get bubbleSaveAnyway => 'Запазване въпреки това';

  @override
  String bubbleSavedTo(String path) {
    return 'Запазено в $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Запазването неуспешно: $error';
  }

  @override
  String get bubbleNotEncrypted => 'НЕ Е КРИПТИРАНО';

  @override
  String get bubbleCorruptedImage => '[Повредено изображение]';

  @override
  String get bubbleReplyPhoto => 'Снимка';

  @override
  String get bubbleReplyVoice => 'Гласово съобщение';

  @override
  String get bubbleReplyVideo => 'Видео съобщение';

  @override
  String bubbleReadBy(String names) {
    return 'Прочетено от $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Прочетено от $count';
  }

  @override
  String get chatTileTapToStart => 'Натиснете, за да започнете чат';

  @override
  String get chatTileMessageSent => 'Съобщението е изпратено';

  @override
  String get chatTileEncryptedMessage => 'Криптирано съобщение';

  @override
  String chatTileYouPrefix(String text) {
    return 'Вие: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Гласово съобщение';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Гласово съобщение ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Криптирано съобщение';

  @override
  String get groupNewGroup => 'Нова група';

  @override
  String get groupGroupName => 'Име на групата';

  @override
  String get groupSelectMembers => 'Изберете членове (мин. 2)';

  @override
  String get groupNoContactsYet =>
      'Все още няма контакти. Първо добавете контакти.';

  @override
  String get groupCreate => 'Създаване';

  @override
  String get groupLabel => 'Група';

  @override
  String get profileVerifyIdentity => 'Проверка на самоличността';

  @override
  String profileVerifyInstructions(String name) {
    return 'Сравнете тези отпечатъци с $name по време на гласово обаждане или лично. Ако и двете стойности съвпадат на двете устройства, натиснете „Маркиране като проверен“.';
  }

  @override
  String get profileTheirKey => 'Техният ключ';

  @override
  String get profileYourKey => 'Вашият ключ';

  @override
  String get profileRemoveVerification => 'Премахване на проверката';

  @override
  String get profileMarkAsVerified => 'Маркиране като проверен';

  @override
  String get profileAddressCopied => 'Адресът е копиран';

  @override
  String get profileNoContactsToAdd =>
      'Няма контакти за добавяне — всички вече са членове';

  @override
  String get profileAddMembers => 'Добавяне на членове';

  @override
  String profileAddCount(int count) {
    return 'Добавяне ($count)';
  }

  @override
  String get profileRenameGroup => 'Преименуване на групата';

  @override
  String get profileRename => 'Преименуване';

  @override
  String get profileRemoveMember => 'Премахване на член?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Да се премахне ли $name от тази група?';
  }

  @override
  String get profileKick => 'Изгонване';

  @override
  String get profileSignalFingerprints => 'Signal отпечатъци';

  @override
  String get profileVerified => 'ПРОВЕРЕН';

  @override
  String get profileVerify => 'Проверка';

  @override
  String get profileEdit => 'Редактиране';

  @override
  String get profileNoSession =>
      'Все още няма установена сесия — първо изпратете съобщение.';

  @override
  String get profileFingerprintCopied => 'Отпечатъкът е копиран';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'а',
      one: '',
    );
    return '$count член$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Проверка на номера за сигурност';

  @override
  String get profileShowContactQr => 'Показване на QR кода на контакта';

  @override
  String profileContactAddress(String name) {
    return 'Адрес на $name';
  }

  @override
  String get profileExportChatHistory => 'Експортиране на историята на чата';

  @override
  String profileSavedTo(String path) {
    return 'Запазено в $path';
  }

  @override
  String get profileExportFailed => 'Експортирането е неуспешно';

  @override
  String get profileClearChatHistory => 'Изчистване на историята на чата';

  @override
  String get profileDeleteGroup => 'Изтриване на групата';

  @override
  String get profileDeleteContact => 'Изтриване на контакт';

  @override
  String get profileLeaveGroup => 'Напускане на групата';

  @override
  String get profileLeaveGroupBody =>
      'Ще бъдете премахнат от тази група и тя ще бъде изтрита от контактите ви.';

  @override
  String get groupInviteTitle => 'Покана за група';

  @override
  String groupInviteBody(String from, String group) {
    return '$from ви покани да се присъедините към \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Приемане';

  @override
  String get groupInviteDecline => 'Отхвърляне';

  @override
  String get groupMemberLimitTitle => 'Твърде много участници';

  @override
  String groupMemberLimitBody(int count) {
    return 'Тази група ще има $count участници. Криптираните mesh обаждания поддържат до 6. По-големите групи преминават към Jitsi (не E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Добавяне въпреки това';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name отказа да се присъедини към \"$group\"';
  }

  @override
  String get transferTitle => 'Прехвърляне на друго устройство';

  @override
  String get transferInfoBox =>
      'Преместете вашата Signal идентичност и Nostr ключове на ново устройство.\nЧат сесиите НЕ се прехвърлят — секретността при препращане е запазена.';

  @override
  String get transferSendFromThis => 'Изпращане от това устройство';

  @override
  String get transferSendSubtitle =>
      'Това устройство има ключовете. Споделете код с новото устройство.';

  @override
  String get transferReceiveOnThis => 'Получаване на това устройство';

  @override
  String get transferReceiveSubtitle =>
      'Това е новото устройство. Въведете кода от старото устройство.';

  @override
  String get transferChooseMethod => 'Изберете метод за прехвърляне';

  @override
  String get transferLan => 'LAN (Една и съща мрежа)';

  @override
  String get transferLanSubtitle =>
      'Бързо и директно. И двете устройства трябва да са в една и съща Wi-Fi мрежа.';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'Работи през всяка мрежа чрез съществуващ Nostr relay.';

  @override
  String get transferRelayUrl => 'URL на relay';

  @override
  String get transferEnterCode => 'Въведете код за прехвърляне';

  @override
  String get transferPasteCode => 'Поставете LAN:... или NOS:... кода тук';

  @override
  String get transferConnect => 'Свързване';

  @override
  String get transferGenerating => 'Генериране на код за прехвърляне…';

  @override
  String get transferShareCode => 'Споделете този код с получателя:';

  @override
  String get transferCopyCode => 'Копиране на кода';

  @override
  String get transferCodeCopied => 'Кодът е копиран в клипборда';

  @override
  String get transferWaitingReceiver => 'Изчакване на получателя да се свърже…';

  @override
  String get transferConnectingSender => 'Свързване с подателя…';

  @override
  String get transferVerifyBoth =>
      'Сравнете този код на двете устройства.\nАко съвпадат, прехвърлянето е сигурно.';

  @override
  String get transferComplete => 'Прехвърлянето е завършено';

  @override
  String get transferKeysImported => 'Ключовете са импортирани';

  @override
  String get transferCompleteSenderBody =>
      'Вашите ключове остават активни на това устройство.\nПолучателят вече може да използва вашата идентичност.';

  @override
  String get transferCompleteReceiverBody =>
      'Ключовете са импортирани успешно.\nРестартирайте приложението, за да приложите новата идентичност.';

  @override
  String get transferRestartApp => 'Рестартиране на приложението';

  @override
  String get transferFailed => 'Прехвърлянето е неуспешно';

  @override
  String get transferTryAgain => 'Опитайте отново';

  @override
  String get transferEnterRelayFirst => 'Първо въведете URL на relay';

  @override
  String get transferPasteCodeFromSender =>
      'Поставете кода за прехвърляне от подателя';

  @override
  String get menuReply => 'Отговор';

  @override
  String get menuForward => 'Препращане';

  @override
  String get menuReact => 'Реакция';

  @override
  String get menuCopy => 'Копиране';

  @override
  String get menuEdit => 'Редактиране';

  @override
  String get menuRetry => 'Повторен опит';

  @override
  String get menuCancelScheduled => 'Отмяна на насроченото';

  @override
  String get menuDelete => 'Изтриване';

  @override
  String get menuForwardTo => 'Препращане до…';

  @override
  String menuForwardedTo(String name) {
    return 'Препратено до $name';
  }

  @override
  String get menuScheduledMessages => 'Насрочени съобщения';

  @override
  String get menuNoScheduledMessages => 'Няма насрочени съобщения';

  @override
  String menuSendsOn(String date) {
    return 'Изпращане на $date';
  }

  @override
  String get menuDisappearingMessages => 'Изчезващи съобщения';

  @override
  String get menuDisappearingSubtitle =>
      'Съобщенията се изтриват автоматично след избраното време.';

  @override
  String get menuTtlOff => 'Изкл.';

  @override
  String get menuTtl1h => '1 час';

  @override
  String get menuTtl24h => '24 часа';

  @override
  String get menuTtl7d => '7 дни';

  @override
  String get menuAttachPhoto => 'Снимка';

  @override
  String get menuAttachFile => 'Файл';

  @override
  String get menuAttachVideo => 'Видео';

  @override
  String get mediaTitle => 'Медия';

  @override
  String get mediaFileLabel => 'ФАЙЛ';

  @override
  String mediaPhotosTab(int count) {
    return 'Снимки ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Файлове ($count)';
  }

  @override
  String get mediaNoPhotos => 'Все още няма снимки';

  @override
  String get mediaNoFiles => 'Все още няма файлове';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Запазено в Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'Файлът не можа да бъде запазен';

  @override
  String get statusNewStatus => 'Нов статус';

  @override
  String get statusPublish => 'Публикуване';

  @override
  String get statusExpiresIn24h => 'Статусът изтича след 24 часа';

  @override
  String get statusWhatsOnYourMind => 'Какво мислите?';

  @override
  String get statusPhotoAttached => 'Снимката е прикачена';

  @override
  String get statusAttachPhoto => 'Прикачване на снимка (по избор)';

  @override
  String get statusEnterText => 'Моля, въведете текст за вашия статус.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Снимката не можа да бъде избрана: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Публикуването е неуспешно: $error';
  }

  @override
  String get panicSetPanicKey => 'Задаване на паник ключ';

  @override
  String get panicEmergencySelfDestruct => 'Аварийно самоунищожаване';

  @override
  String get panicIrreversible => 'Това действие е необратимо';

  @override
  String get panicWarningBody =>
      'Въвеждането на този ключ на заключения екран незабавно изтрива ВСИЧКИ данни — съобщения, контакти, ключове, идентичност. Използвайте ключ, различен от обикновената ви парола.';

  @override
  String get panicKeyHint => 'Паник ключ';

  @override
  String get panicConfirmHint => 'Потвърдете паник ключа';

  @override
  String get panicMinChars => 'Паник ключът трябва да е поне 8 символа';

  @override
  String get panicKeysDoNotMatch => 'Ключовете не съвпадат';

  @override
  String get panicSetFailed =>
      'Паник ключът не можа да бъде запазен — моля, опитайте отново';

  @override
  String get passwordSetAppPassword => 'Задаване на парола за приложението';

  @override
  String get passwordProtectsMessages => 'Защитава съобщенията ви в покой';

  @override
  String get passwordInfoBanner =>
      'Изисква се при всяко отваряне на Pulse. Ако бъде забравена, данните ви не могат да бъдат възстановени.';

  @override
  String get passwordHint => 'Парола';

  @override
  String get passwordConfirmHint => 'Потвърдете паролата';

  @override
  String get passwordSetButton => 'Задаване на парола';

  @override
  String get passwordSkipForNow => 'Пропускане засега';

  @override
  String get passwordMinChars => 'Паролата трябва да е поне 8 символа';

  @override
  String get passwordNeedsVariety =>
      'Трябва да включва букви, цифри и специални символи';

  @override
  String get passwordRequirements =>
      'Мин. 8 символа с букви, цифри и специален символ';

  @override
  String get passwordsDoNotMatch => 'Паролите не съвпадат';

  @override
  String get profileCardSaved => 'Профилът е запазен!';

  @override
  String get profileCardE2eeIdentity => 'E2EE идентичност';

  @override
  String get profileCardDisplayName => 'Име за показване';

  @override
  String get profileCardDisplayNameHint => 'напр. Иван Иванов';

  @override
  String get profileCardAbout => 'За мен';

  @override
  String get profileCardSaveProfile => 'Запазване на профила';

  @override
  String get profileCardYourName => 'Вашето име';

  @override
  String get profileCardAddressCopied => 'Адресът е копиран!';

  @override
  String get profileCardInboxAddress => 'Вашият входящ адрес';

  @override
  String get profileCardInboxAddresses => 'Вашите входящи адреси';

  @override
  String get profileCardShareAllAddresses =>
      'Споделяне на всички адреси (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Споделете с контакти, за да могат да ви пишат.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Всички $count адреса са копирани като един линк!';
  }

  @override
  String get settingsMyProfile => 'Моят профил';

  @override
  String get settingsYourInboxAddress => 'Вашият входящ адрес';

  @override
  String get settingsMyQrCode => 'Споделяне на контакт';

  @override
  String get settingsMyQrSubtitle => 'QR код и линк за покана за вашия адрес';

  @override
  String get settingsShareMyAddress => 'Споделяне на адреса ми';

  @override
  String get settingsNoAddressYet =>
      'Все още няма адрес — първо запазете настройките';

  @override
  String get settingsInviteLink => 'Линк за покана';

  @override
  String get settingsRawAddress => 'Суров адрес';

  @override
  String get settingsCopyLink => 'Копиране на линка';

  @override
  String get settingsCopyAddress => 'Копиране на адреса';

  @override
  String get settingsInviteLinkCopied => 'Линкът за покана е копиран';

  @override
  String get settingsAppearance => 'Външен вид';

  @override
  String get settingsThemeEngine => 'Тема';

  @override
  String get settingsThemeEngineSubtitle =>
      'Персонализиране на цветове и шрифтове';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle =>
      'E2EE ключовете се съхраняват сигурно';

  @override
  String get settingsActive => 'АКТИВЕН';

  @override
  String get settingsIdentityBackup => 'Резервно копие на идентичността';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Експортиране или импортиране на Signal идентичността';

  @override
  String get settingsIdentityBackupBody =>
      'Експортирайте Signal идентификационните си ключове като резервен код или ги възстановете от съществуващ.';

  @override
  String get settingsTransferDevice => 'Прехвърляне на друго устройство';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Преместете идентичността си чрез LAN или Nostr relay';

  @override
  String get settingsExportIdentity => 'Експортиране на идентичност';

  @override
  String get settingsExportIdentityBody =>
      'Копирайте този резервен код и го съхранете на сигурно място:';

  @override
  String get settingsSaveFile => 'Запазване на файл';

  @override
  String get settingsImportIdentity => 'Импортиране на идентичност';

  @override
  String get settingsImportIdentityBody =>
      'Поставете резервния си код по-долу. Това ще замени текущата ви идентичност.';

  @override
  String get settingsPasteBackupCode => 'Поставете резервния код тук…';

  @override
  String get settingsIdentityImported =>
      'Идентичност + контакти импортирани! Рестартирайте приложението, за да ги приложите.';

  @override
  String get settingsSecurity => 'Сигурност';

  @override
  String get settingsAppPassword => 'Парола за приложението';

  @override
  String get settingsPasswordEnabled =>
      'Активирана — изисква се при всяко стартиране';

  @override
  String get settingsPasswordDisabled =>
      'Деактивирана — приложението се отваря без парола';

  @override
  String get settingsChangePassword => 'Промяна на паролата';

  @override
  String get settingsChangePasswordSubtitle =>
      'Актуализиране на паролата за заключване';

  @override
  String get settingsSetPanicKey => 'Задаване на паник ключ';

  @override
  String get settingsChangePanicKey => 'Промяна на паник ключ';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Актуализиране на ключа за аварийно изтриване';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Един ключ, който мигновено изтрива всички данни';

  @override
  String get settingsRemovePanicKey => 'Премахване на паник ключа';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Деактивиране на аварийното самоунищожаване';

  @override
  String get settingsRemovePanicKeyBody =>
      'Аварийното самоунищожаване ще бъде деактивирано. Можете да го активирате отново по всяко време.';

  @override
  String get settingsDisableAppPassword =>
      'Деактивиране на паролата за приложението';

  @override
  String get settingsEnterCurrentPassword =>
      'Въведете текущата си парола за потвърждение';

  @override
  String get settingsCurrentPassword => 'Текуща парола';

  @override
  String get settingsIncorrectPassword => 'Грешна парола';

  @override
  String get settingsPasswordUpdated => 'Паролата е актуализирана';

  @override
  String get settingsChangePasswordProceed =>
      'Въведете текущата си парола, за да продължите';

  @override
  String get settingsData => 'Данни';

  @override
  String get settingsBackupMessages => 'Резервно копие на съобщенията';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Експортиране на криптирана история на съобщенията във файл';

  @override
  String get settingsRestoreMessages => 'Възстановяване на съобщенията';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Импортиране на съобщения от резервен файл';

  @override
  String get settingsExportKeys => 'Експортиране на ключове';

  @override
  String get settingsExportKeysSubtitle =>
      'Запазване на идентификационни ключове в криптиран файл';

  @override
  String get settingsImportKeys => 'Импортиране на ключове';

  @override
  String get settingsImportKeysSubtitle =>
      'Възстановяване на идентификационни ключове от експортиран файл';

  @override
  String get settingsBackupPassword => 'Парола за резервно копие';

  @override
  String get settingsPasswordCannotBeEmpty => 'Паролата не може да бъде празна';

  @override
  String get settingsPasswordMin4Chars => 'Паролата трябва да е поне 4 символа';

  @override
  String get settingsCallsTurn => 'Обаждания и TURN';

  @override
  String get settingsLocalNetwork => 'Локална мрежа';

  @override
  String get settingsCensorshipResistance => 'Устойчивост срещу цензура';

  @override
  String get settingsNetwork => 'Мрежа';

  @override
  String get settingsProxyTunnels => 'Прокси и тунели';

  @override
  String get settingsTurnServers => 'TURN сървъри';

  @override
  String get settingsProviderTitle => 'Доставчик';

  @override
  String get settingsLanFallback => 'LAN резерва';

  @override
  String get settingsLanFallbackSubtitle =>
      'Излъчване на присъствие и доставяне на съобщения в локалната мрежа, когато интернетът не е наличен. Деактивирайте в ненадеждни мрежи (публичен Wi-Fi).';

  @override
  String get settingsBgDelivery => 'Фонова доставка';

  @override
  String get settingsBgDeliverySubtitle =>
      'Продължете да получавате съобщения, когато приложението е минимизирано. Показва постоянно известие.';

  @override
  String get settingsYourInboxProvider => 'Вашият доставчик на пощенска кутия';

  @override
  String get settingsConnectionDetails => 'Подробности за връзката';

  @override
  String get settingsSaveAndConnect => 'Запазване и свързване';

  @override
  String get settingsSecondaryInboxes => 'Вторични пощенски кутии';

  @override
  String get settingsAddSecondaryInbox => 'Добавяне на вторична пощенска кутия';

  @override
  String get settingsAdvanced => 'Разширени';

  @override
  String get settingsDiscover => 'Откриване';

  @override
  String get settingsAbout => 'Относно';

  @override
  String get settingsPrivacyPolicy => 'Политика за поверителност';

  @override
  String get settingsPrivacyPolicySubtitle => 'Как Pulse защитава данните ви';

  @override
  String get settingsCrashReporting => 'Отчитане на сривове';

  @override
  String get settingsCrashReportingSubtitle =>
      'Изпращане на анонимни отчети за сривове, за да помогнете за подобряването на Pulse. Никога не се изпраща съдържание на съобщения или контакти.';

  @override
  String get settingsCrashReportingEnabled =>
      'Отчитането на сривове е активирано — рестартирайте приложението, за да приложите';

  @override
  String get settingsCrashReportingDisabled =>
      'Отчитането на сривове е деактивирано — рестартирайте приложението, за да приложите';

  @override
  String get settingsSensitiveOperation => 'Чувствителна операция';

  @override
  String get settingsSensitiveOperationBody =>
      'Тези ключове са вашата идентичност. Всеки с този файл може да се представя за вас. Съхранявайте го сигурно и го изтрийте след прехвърлянето.';

  @override
  String get settingsIUnderstandContinue => 'Разбирам, продължаване';

  @override
  String get settingsReplaceIdentity => 'Замяна на идентичността?';

  @override
  String get settingsReplaceIdentityBody =>
      'Това ще замени текущите ви идентификационни ключове. Съществуващите ви Signal сесии ще бъдат обезсилени и контактите ще трябва да установят криптирането наново. Приложението ще трябва да бъде рестартирано.';

  @override
  String get settingsReplaceKeys => 'Замяна на ключовете';

  @override
  String get settingsKeysImported => 'Ключовете са импортирани';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count ключа са импортирани успешно. Моля, рестартирайте приложението, за да се инициализира с новата идентичност.';
  }

  @override
  String get settingsRestartNow => 'Рестартиране сега';

  @override
  String get settingsLater => 'По-късно';

  @override
  String get profileGroupLabel => 'Група';

  @override
  String get profileAddButton => 'Добавяне';

  @override
  String get profileKickButton => 'Изгонване';

  @override
  String get dataSectionTitle => 'Данни';

  @override
  String get dataBackupMessages => 'Резервно копие на съобщенията';

  @override
  String get dataBackupPasswordSubtitle =>
      'Изберете парола за криптиране на резервното копие на съобщенията.';

  @override
  String get dataBackupConfirmLabel => 'Създаване на резервно копие';

  @override
  String get dataCreatingBackup => 'Създаване на резервно копие';

  @override
  String get dataBackupPreparing => 'Подготовка...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Експортиране на съобщение $done от $total...';
  }

  @override
  String get dataBackupSavingFile => 'Запазване на файла...';

  @override
  String get dataSaveMessageBackupDialog =>
      'Запазване на резервно копие на съобщенията';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Резервното копие е запазено ($count съобщения)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Резервното копие е неуспешно — няма експортирани данни';

  @override
  String dataBackupFailedError(String error) {
    return 'Резервното копие е неуспешно: $error';
  }

  @override
  String get dataSelectMessageBackupDialog =>
      'Избор на резервно копие на съобщенията';

  @override
  String get dataInvalidBackupFile =>
      'Невалиден файл с резервно копие (твърде малък)';

  @override
  String get dataNotValidBackupFile =>
      'Не е валиден Pulse файл с резервно копие';

  @override
  String get dataRestoreMessages => 'Възстановяване на съобщенията';

  @override
  String get dataRestorePasswordSubtitle =>
      'Въведете паролата, използвана за създаване на това резервно копие.';

  @override
  String get dataRestoreConfirmLabel => 'Възстановяване';

  @override
  String get dataRestoringMessages => 'Възстановяване на съобщенията';

  @override
  String get dataRestoreDecrypting => 'Декриптиране...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Импортиране на съобщение $done от $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Възстановяването е неуспешно — грешна парола или повреден файл';

  @override
  String dataRestoreSuccess(int count) {
    return 'Възстановени са $count нови съобщения';
  }

  @override
  String get dataRestoreNothingNew =>
      'Няма нови съобщения за импортиране (всички вече съществуват)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Възстановяването е неуспешно: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Избор на експорт на ключове';

  @override
  String get dataNotValidKeyFile =>
      'Не е валиден Pulse файл за експорт на ключове';

  @override
  String get dataExportKeys => 'Експортиране на ключове';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Изберете парола за криптиране на експорта на ключове.';

  @override
  String get dataExportKeysConfirmLabel => 'Експортиране';

  @override
  String get dataExportingKeys => 'Експортиране на ключове';

  @override
  String get dataExportingKeysStatus =>
      'Криптиране на идентификационните ключове...';

  @override
  String get dataSaveKeyExportDialog => 'Запазване на експорт на ключове';

  @override
  String dataKeysExportedTo(String path) {
    return 'Ключовете са експортирани в:\n$path';
  }

  @override
  String get dataExportFailed =>
      'Експортирането е неуспешно — не са намерени ключове';

  @override
  String dataExportFailedError(String error) {
    return 'Експортирането е неуспешно: $error';
  }

  @override
  String get dataImportKeys => 'Импортиране на ключове';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Въведете паролата, използвана за криптиране на този експорт на ключове.';

  @override
  String get dataImportKeysConfirmLabel => 'Импортиране';

  @override
  String get dataImportingKeys => 'Импортиране на ключове';

  @override
  String get dataImportingKeysStatus =>
      'Декриптиране на идентификационните ключове...';

  @override
  String get dataImportFailed =>
      'Импортирането е неуспешно — грешна парола или повреден файл';

  @override
  String dataImportFailedError(String error) {
    return 'Импортирането е неуспешно: $error';
  }

  @override
  String get securitySectionTitle => 'Сигурност';

  @override
  String get securityIncorrectPassword => 'Грешна парола';

  @override
  String get securityPasswordUpdated => 'Паролата е актуализирана';

  @override
  String get appearanceSectionTitle => 'Външен вид';

  @override
  String appearanceExportFailed(String error) {
    return 'Експортирането е неуспешно: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Запазено в $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Запазването е неуспешно: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Импортирането е неуспешно: $error';
  }

  @override
  String get aboutSectionTitle => 'Относно';

  @override
  String get providerPublicKey => 'Публичен ключ';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Автоматично конфигуриран от паролата ви за възстановяване. Relay-ят е открит автоматично.';

  @override
  String get providerKeyStoredLocally =>
      'Вашият ключ се съхранява локално в защитено хранилище — никога не се изпраща на сървър.';

  @override
  String get providerSessionInfo =>
      'Session Network — E2EE с лукова маршрутизация. Вашият Session ID се генерира автоматично и се съхранява сигурно. Възлите се откриват автоматично от вградените начални възли.';

  @override
  String get providerAdvanced => 'Разширени';

  @override
  String get providerSaveAndConnect => 'Запазване и свързване';

  @override
  String get providerAddSecondaryInbox => 'Добавяне на вторична пощенска кутия';

  @override
  String get providerSecondaryInboxes => 'Вторични пощенски кутии';

  @override
  String get providerYourInboxProvider => 'Вашият доставчик на пощенска кутия';

  @override
  String get providerConnectionDetails => 'Подробности за връзката';

  @override
  String get addContactTitle => 'Добавяне на контакт';

  @override
  String get addContactInviteLinkLabel => 'Линк за покана или адрес';

  @override
  String get addContactTapToPaste =>
      'Натиснете, за да поставите линк за покана';

  @override
  String get addContactPasteTooltip => 'Поставяне от клипборда';

  @override
  String get addContactAddressDetected => 'Открит е адрес на контакт';

  @override
  String addContactRoutesDetected(int count) {
    return '$count маршрута открити — SmartRouter избира най-бързия';
  }

  @override
  String get addContactFetchingProfile => 'Извличане на профил…';

  @override
  String addContactProfileFound(String name) {
    return 'Намерен: $name';
  }

  @override
  String get addContactNoProfileFound => 'Не е намерен профил';

  @override
  String get addContactDisplayNameLabel => 'Име за показване';

  @override
  String get addContactDisplayNameHint => 'Как искате да го/я наречете?';

  @override
  String get addContactAddManually => 'Ръчно въвеждане на адрес';

  @override
  String get addContactButton => 'Добавяне на контакт';

  @override
  String get networkDiagnosticsTitle => 'Мрежова диагностика';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr Relay-и';

  @override
  String get networkDiagnosticsDirect => 'Директни';

  @override
  String get networkDiagnosticsTorOnly => 'Само Tor';

  @override
  String get networkDiagnosticsBest => 'Най-добър';

  @override
  String get networkDiagnosticsNone => 'няма';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Статус';

  @override
  String get networkDiagnosticsConnected => 'Свързан';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Свързване $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Изкл.';

  @override
  String get networkDiagnosticsTransport => 'Транспорт';

  @override
  String get networkDiagnosticsInfrastructure => 'Инфраструктура';

  @override
  String get networkDiagnosticsSessionNodes => 'Session възли';

  @override
  String get networkDiagnosticsTurnServers => 'TURN сървъри';

  @override
  String get networkDiagnosticsLastProbe => 'Последна проверка';

  @override
  String get networkDiagnosticsRunning => 'Изпълнява се...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Стартиране на диагностиката';

  @override
  String get networkDiagnosticsForceReprobe => 'Пълна повторна проверка';

  @override
  String get networkDiagnosticsJustNow => 'току-що';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'преди $minutes мин.';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'преди $hours ч.';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'преди $days д.';
  }

  @override
  String get homeNoEch => 'Без ECH';

  @override
  String get homeNoEchTooltip =>
      'uTLS прокси не е наличен — ECH е деактивиран.\nTLS отпечатъкът е видим за DPI.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Запазено и свързано с $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Вграденият Tor не можа да стартира';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon не можа да стартира';

  @override
  String get verifyTitle => 'Проверка на номера за сигурност';

  @override
  String get verifyIdentityVerified => 'Идентичността е проверена';

  @override
  String get verifyNotYetVerified => 'Все още не е проверена';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Вие проверихте номера за сигурност на $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Сравнете тези числа с $name лично или чрез надежден канал.';
  }

  @override
  String get verifyExplanation =>
      'Всеки разговор има уникален номер за сигурност. Ако и двамата виждате едни и същи числа на устройствата си, връзката ви е проверена от край до край.';

  @override
  String verifyContactKey(String name) {
    return 'Ключ на $name';
  }

  @override
  String get verifyYourKey => 'Вашият ключ';

  @override
  String get verifyRemoveVerification => 'Премахване на проверката';

  @override
  String get verifyMarkAsVerified => 'Маркиране като проверен';

  @override
  String verifyAfterReinstall(String name) {
    return 'Ако $name преинсталира приложението, номерът за сигурност ще се промени и проверката ще бъде премахната автоматично.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Маркирайте като проверен само след като сравните числата с $name по време на гласово обаждане или лично.';
  }

  @override
  String get verifyNoSession =>
      'Все още няма установена сесия за криптиране. Първо изпратете съобщение, за да генерирате номера за сигурност.';

  @override
  String get verifyNoKeyAvailable => 'Няма наличен ключ';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Отпечатъкът на $label е копиран';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL на базата данни';

  @override
  String get providerOptionalHint => 'По избор';

  @override
  String get providerWebApiKeyLabel => 'Web API ключ';

  @override
  String get providerOptionalForPublicDb => 'По избор за публична база данни';

  @override
  String get providerRelayUrlLabel => 'URL на relay';

  @override
  String get providerPrivateKeyLabel => 'Частен ключ';

  @override
  String get providerPrivateKeyNsecLabel => 'Частен ключ (nsec)';

  @override
  String get providerStorageNodeLabel =>
      'URL на възел за съхранение (по избор)';

  @override
  String get providerStorageNodeHint =>
      'Оставете празно за вградени seed възли';

  @override
  String get transferInvalidCodeFormat =>
      'Неразпознат формат на кода — трябва да започва с LAN: или NOS:';

  @override
  String get profileCardFingerprintCopied => 'Отпечатъкът е копиран';

  @override
  String get profileCardAboutHint => 'Поверителност на първо място 🔒';

  @override
  String get profileCardSaveButton => 'Запазване на профила';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Експортиране на криптирани съобщения, контакти и аватари във файл';

  @override
  String get callVideo => 'Видео';

  @override
  String get callAudio => 'Аудио';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Доставено до $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Доставено до $count';
  }

  @override
  String get groupStatusDialogTitle => 'Информация за съобщението';

  @override
  String get groupStatusRead => 'Прочетено';

  @override
  String get groupStatusDelivered => 'Доставено';

  @override
  String get groupStatusPending => 'Изчакващо';

  @override
  String get groupStatusNoData => 'Все още няма информация за доставката';

  @override
  String get profileTransferAdmin => 'Направи администратор';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Да се направи ли $name нов администратор?';
  }

  @override
  String get profileTransferAdminBody =>
      'Ще загубите администраторските си права. Това не може да бъде отменено.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name вече е администратор';
  }

  @override
  String get profileAdminBadge => 'Админ';

  @override
  String get privacyPolicyTitle => 'Политика за поверителност';

  @override
  String get privacyOverviewHeading => 'Преглед';

  @override
  String get privacyOverviewBody =>
      'Pulse е безсървърен месинджър с криптиране от край до край. Вашата поверителност не е просто функция — тя е архитектурата. Няма Pulse сървъри. Никъде не се съхраняват акаунти. Никакви данни не се събират, предават или съхраняват от разработчиците.';

  @override
  String get privacyDataCollectionHeading => 'Събиране на данни';

  @override
  String get privacyDataCollectionBody =>
      'Pulse не събира никакви лични данни. По-конкретно:\n\n- Не се изисква имейл, телефонен номер или истинско име\n- Без анализи, проследяване или телеметрия\n- Без рекламни идентификатори\n- Без достъп до списъка с контакти\n- Без облачни резервни копия (съобщенията съществуват само на вашето устройство)\n- Никакви метаданни не се изпращат на Pulse сървър (такъв няма)';

  @override
  String get privacyEncryptionHeading => 'Криптиране';

  @override
  String get privacyEncryptionBody =>
      'Всички съобщения са криптирани чрез Signal Protocol (Double Ratchet с X3DH споразумение за ключове). Криптографските ключове се генерират и съхраняват изключително на вашето устройство. Никой — включително разработчиците — не може да чете съобщенията ви.';

  @override
  String get privacyNetworkHeading => 'Мрежова архитектура';

  @override
  String get privacyNetworkBody =>
      'Pulse използва федерирани транспортни адаптери (Nostr relay-и, Session/Oxen обслужващи възли, Firebase Realtime Database, LAN). Тези транспорти пренасят само криптиран шифротекст. Операторите на relay-и могат да видят вашия IP адрес и обема на трафика, но не могат да декриптират съдържанието на съобщенията.\n\nКогато Tor е активиран, вашият IP адрес е скрит и от операторите на relay-и.';

  @override
  String get privacyStunHeading => 'STUN/TURN сървъри';

  @override
  String get privacyStunBody =>
      'Гласовите и видео обажданията използват WebRTC с DTLS-SRTP криптиране. STUN сървърите (използвани за откриване на публичния ви IP за peer-to-peer връзки) и TURN сървърите (използвани за препредаване на медия, когато директната връзка е неуспешна) могат да видят вашия IP адрес и продължителността на обаждането, но не могат да декриптират съдържанието на обаждането.\n\nМожете да конфигурирате собствен TURN сървър в Настройки за максимална поверителност.';

  @override
  String get privacyCrashHeading => 'Отчитане на сривове';

  @override
  String get privacyCrashBody =>
      'Ако отчитането на сривове чрез Sentry е активирано (чрез SENTRY_DSN при компилация), могат да бъдат изпратени анонимни отчети за сривове. Те не съдържат съдържание на съобщения, информация за контакти или лични данни. Отчитането на сривове може да бъде деактивирано при компилация чрез пропускане на DSN.';

  @override
  String get privacyPasswordHeading => 'Парола и ключове';

  @override
  String get privacyPasswordBody =>
      'Вашата парола за възстановяване се използва за извличане на криптографски ключове чрез Argon2id (KDF с висока памет). Паролата никога не се предава никъде. Ако загубите паролата си, акаунтът ви не може да бъде възстановен — няма сървър, който да го нулира.';

  @override
  String get privacyFontsHeading => 'Шрифтове';

  @override
  String get privacyFontsBody =>
      'Pulse включва всички шрифтове локално. Не се правят заявки към Google Fonts или към други външни шрифтови услуги.';

  @override
  String get privacyThirdPartyHeading => 'Услуги на трети страни';

  @override
  String get privacyThirdPartyBody =>
      'Pulse не се интегрира с рекламни мрежи, доставчици на анализи, социални медийни платформи или брокери на данни. Единствените мрежови връзки са към транспортните relay-и, които конфигурирате.';

  @override
  String get privacyOpenSourceHeading => 'Отворен код';

  @override
  String get privacyOpenSourceBody =>
      'Pulse е софтуер с отворен код. Можете да проверите пълния изходен код, за да потвърдите тези твърдения за поверителност.';

  @override
  String get privacyContactHeading => 'Контакт';

  @override
  String get privacyContactBody =>
      'За въпроси, свързани с поверителността, отворете issue в хранилището на проекта.';

  @override
  String get privacyLastUpdated => 'Последна актуализация: март 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Запазването е неуспешно: $error';
  }

  @override
  String get themeEngineTitle => 'Тема';

  @override
  String get torBuiltInTitle => 'Вграден Tor';

  @override
  String get torConnectedSubtitle =>
      'Свързан — Nostr маршрутизиран чрез 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Свързване… $pct%';
  }

  @override
  String get torNotRunning =>
      'Не работи — натиснете превключвателя за рестартиране';

  @override
  String get torDescription =>
      'Маршрутизира Nostr чрез Tor (Snowflake за цензурирани мрежи)';

  @override
  String get torNetworkDiagnostics => 'Мрежова диагностика';

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
  String get torPtPlain => 'Обикновен';

  @override
  String get torTimeoutLabel => 'Таймаут: ';

  @override
  String get torInfoDescription =>
      'Когато е активирано, Nostr WebSocket връзките се маршрутизират през Tor (SOCKS5). Tor Browser слуша на 127.0.0.1:9150. Самостоятелният Tor демон използва порт 9050. Firebase връзките не са засегнати.';

  @override
  String get torRouteNostrTitle => 'Маршрутизиране на Nostr чрез Tor';

  @override
  String get torManagedByBuiltin => 'Управлявано от вградения Tor';

  @override
  String get torActiveRouting =>
      'Активно — Nostr трафикът се маршрутизира през Tor';

  @override
  String get torDisabled => 'Деактивирано';

  @override
  String get torProxySocks5 => 'Tor прокси (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Хост на прокси';

  @override
  String get torProxyPortLabel => 'Порт';

  @override
  String get torPortInfo => 'Tor Browser: порт 9150  •  Tor демон: порт 9050';

  @override
  String get torForceNostrTitle => 'Насочване на съобщенията през Tor';

  @override
  String get torForceNostrSubtitle =>
      'Всички Nostr relay връзки ще минават през Tor. По-бавно, но скрива IP адреса ви от relay сървърите.';

  @override
  String get torForceNostrDisabled => 'Tor трябва първо да бъде включен';

  @override
  String get torForcePulseTitle => 'Насочване на Pulse relay през Tor';

  @override
  String get torForcePulseSubtitle =>
      'Всички Pulse relay връзки ще минават през Tor. По-бавно, но скрива IP адреса ви от сървъра.';

  @override
  String get torForcePulseDisabled => 'Tor трябва първо да бъде включен';

  @override
  String get i2pProxySocks5 => 'I2P прокси (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P използва SOCKS5 на порт 4447 по подразбиране. Свържете се с Nostr relay чрез I2P outproxy (напр. relay.damus.i2p), за да комуникирате с потребители на всеки транспорт. Tor има приоритет, когато и двете са активирани.';

  @override
  String get i2pRouteNostrTitle => 'Маршрутизиране на Nostr чрез I2P';

  @override
  String get i2pActiveRouting =>
      'Активно — Nostr трафикът се маршрутизира през I2P';

  @override
  String get i2pDisabled => 'Деактивирано';

  @override
  String get i2pProxyHostLabel => 'Хост на прокси';

  @override
  String get i2pProxyPortLabel => 'Порт';

  @override
  String get i2pPortInfo => 'I2P Router SOCKS5 порт по подразбиране: 4447';

  @override
  String get customProxySocks5 => 'Потребителски прокси (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Потребителският прокси маршрутизира трафика през вашия V2Ray/Xray/Shadowsocks. CF Worker действа като личен relay прокси в Cloudflare CDN — GFW вижда *.workers.dev, а не истинския relay.';

  @override
  String get customSocks5ProxyTitle => 'Потребителски SOCKS5 прокси';

  @override
  String get customProxyActive =>
      'Активно — трафикът се маршрутизира чрез SOCKS5';

  @override
  String get customProxyDisabled => 'Деактивирано';

  @override
  String get customProxyHostLabel => 'Хост на прокси';

  @override
  String get customProxyPortLabel => 'Порт';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Домейн на Worker (по избор)';

  @override
  String get customWorkerHelpTitle =>
      'Как да разгърнете CF Worker relay (безплатно)';

  @override
  String get customWorkerScriptCopied => 'Скриптът е копиран!';

  @override
  String get customWorkerStep1 =>
      '1. Отидете на dash.cloudflare.com → Workers & Pages\n2. Create Worker → поставете този скрипт:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → копирайте домейна (напр. my-relay.user.workers.dev)\n4. Поставете домейна по-горе → Запазване\n\nПриложението се свързва автоматично: wss://domain/?r=relay_url\nGFW вижда: връзка към *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Свързан — SOCKS5 на 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Свързване…';

  @override
  String get psiphonNotRunning =>
      'Не работи — натиснете превключвателя за рестартиране';

  @override
  String get psiphonDescription =>
      'Бърз тунел (~3 сек. зареждане, 2000+ ротиращи VPS)';

  @override
  String get turnCommunityServers => 'Общностни TURN сървъри';

  @override
  String get turnCustomServer => 'Потребителски TURN сървър (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN сървърите препредават само вече криптирани потоци (DTLS-SRTP). Операторът на relay вижда вашия IP и обема на трафика, но не може да декриптира обажданията. TURN се използва само когато директният P2P е неуспешен (~15–20% от връзките).';

  @override
  String get turnFreeLabel => 'БЕЗПЛАТНО';

  @override
  String get turnServerUrlLabel => 'URL на TURN сървъра';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 или turns:...';

  @override
  String get turnUsernameLabel => 'Потребителско име';

  @override
  String get turnPasswordLabel => 'Парола';

  @override
  String get turnOptionalHint => 'По избор';

  @override
  String get turnCustomInfo =>
      'Хостнете coturn на произволен VPS за \$5/мес. за максимален контрол. Данните за достъп се съхраняват локално.';

  @override
  String get themePickerAppearance => 'Външен вид';

  @override
  String get themePickerAccentColor => 'Акцентен цвят';

  @override
  String get themeModeLight => 'Светъл';

  @override
  String get themeModeDark => 'Тъмен';

  @override
  String get themeModeSystem => 'Системен';

  @override
  String get themeDynamicPresets => 'Предварителни настройки';

  @override
  String get themeDynamicPrimaryColor => 'Основен цвят';

  @override
  String get themeDynamicBorderRadius => 'Радиус на ъглите';

  @override
  String get themeDynamicFont => 'Шрифт';

  @override
  String get themeDynamicAppearance => 'Външен вид';

  @override
  String get themeDynamicUiStyle => 'UI стил';

  @override
  String get themeDynamicUiStyleDescription =>
      'Контролира как изглеждат диалозите, превключвателите и индикаторите.';

  @override
  String get themeDynamicSharp => 'Ъглов';

  @override
  String get themeDynamicRound => 'Кръгъл';

  @override
  String get themeDynamicModeDark => 'Тъмен';

  @override
  String get themeDynamicModeLight => 'Светъл';

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
      'Невалиден Firebase URL. Очакван: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Невалиден relay URL. Очакван: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Невалиден Pulse сървър URL. Очакван: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'URL на сървъра';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'Код за покана';

  @override
  String get providerPulseInviteHint => 'Код за покана (ако е необходим)';

  @override
  String get providerPulseInfo =>
      'Самостоятелно хостван relay. Ключовете са извлечени от паролата ви за възстановяване.';

  @override
  String get providerScreenTitle => 'Пощенски кутии';

  @override
  String get providerSecondaryInboxesHeader => 'ВТОРИЧНИ ПОЩЕНСКИ КУТИИ';

  @override
  String get providerSecondaryInboxesInfo =>
      'Вторичните пощенски кутии получават съобщения едновременно за излишък.';

  @override
  String get providerRemoveTooltip => 'Премахване';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... или hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... или hex частен ключ';

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
  String get emojiNoRecent => 'Няма скорошни емотикони';

  @override
  String get emojiSearchHint => 'Търсене на емотикони...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Натиснете, за да чатите';

  @override
  String get imageViewerSaveToDownloads => 'Запазване в Downloads';

  @override
  String imageViewerSavedTo(String path) {
    return 'Запазено в $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Език';

  @override
  String get settingsLanguageSubtitle => 'Език на приложението';

  @override
  String get settingsLanguageSystem => 'Системен по подразбиране';

  @override
  String get onboardingLanguageTitle => 'Изберете вашия език';

  @override
  String get onboardingLanguageSubtitle =>
      'Можете да промените това по-късно в Настройки';

  @override
  String get videoNoteRecord => 'Запиши видео съобщение';

  @override
  String get videoNoteTapToRecord => 'Докоснете за запис';

  @override
  String get videoNoteTapToStop => 'Докоснете за спиране';

  @override
  String get videoNoteCameraPermission => 'Достъпът до камерата е отказан';

  @override
  String get videoNoteMaxDuration => 'Максимум 30 секунди';

  @override
  String get videoNoteNotSupported =>
      'Видео бележките не се поддържат на тази платформа';

  @override
  String get navChats => 'Чатове';

  @override
  String get navUpdates => 'Обновления';

  @override
  String get navCalls => 'Обаждания';

  @override
  String get filterAll => 'Всички';

  @override
  String get filterUnread => 'Непрочетени';

  @override
  String get filterGroups => 'Групи';

  @override
  String get callsNoRecent => 'Няма последни обаждания';

  @override
  String get callsEmptySubtitle =>
      'Историята на обажданията ви ще се появи тук';

  @override
  String get appBarEncrypted => 'криптирано от край до край';

  @override
  String get newStatus => 'Нов статус';

  @override
  String get newCall => 'Ново обаждане';

  @override
  String get joinChannelTitle => 'Присъединяване към канал';

  @override
  String get joinChannelDescription => 'URL НА КАНАЛА';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'Извличане на информация за канала…';

  @override
  String get joinChannelNotFound => 'Не е намерен канал на този URL';

  @override
  String get joinChannelNetworkError => 'Няма връзка със сървъра';

  @override
  String get joinChannelAlreadyJoined => 'Вече сте присъединени';

  @override
  String get joinChannelButton => 'Присъединяване';

  @override
  String get channelFeedEmpty => 'Все още няма публикации';

  @override
  String get channelLeave => 'Напускане на канала';

  @override
  String get channelLeaveConfirm =>
      'Напускане на този канал? Кешираните публикации ще бъдат изтрити.';

  @override
  String get channelInfo => 'Информация за канала';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'редактирано';

  @override
  String get channelLoadMore => 'Зареди още';

  @override
  String get channelSearchPosts => 'Търсене на публикации…';

  @override
  String get channelNoResults => 'Няма съвпадащи публикации';

  @override
  String get channelUrl => 'URL на канала';

  @override
  String get channelCreated => 'Присъединен';

  @override
  String channelPostCount(int count) {
    return '$count публикации';
  }

  @override
  String get channelCopyUrl => 'Копиране на URL';

  @override
  String get setupNext => 'Напред';

  @override
  String get setupKeyWarning =>
      'За вас ще бъде генериран ключ за възстановяване. Това е единственият начин да възстановите акаунта си на ново устройство — няма сървър, няма нулиране на паролата.';

  @override
  String get setupKeyTitle => 'Вашият ключ за възстановяване';

  @override
  String get setupKeySubtitle =>
      'Запишете този ключ и го съхранете на сигурно място. Ще ви е необходим, за да възстановите акаунта си на ново устройство.';

  @override
  String get setupKeyCopied => 'Копирано!';

  @override
  String get setupKeyWroteItDown => 'Записах го';

  @override
  String get setupKeyWarnBody =>
      'Запишете този ключ като резервно копие. Можете също да го видите по-късно в Настройки → Сигурност.';

  @override
  String get setupVerifyTitle => 'Потвърдете ключа за възстановяване';

  @override
  String get setupVerifySubtitle =>
      'Въведете отново ключа за възстановяване, за да потвърдите, че сте го запазили правилно.';

  @override
  String get setupVerifyButton => 'Потвърди';

  @override
  String get setupKeyMismatch =>
      'Ключът не съвпада. Проверете и опитайте отново.';

  @override
  String get setupSkipVerify => 'Пропусни потвърждението';

  @override
  String get setupSkipVerifyTitle => 'Пропускане на потвърждението?';

  @override
  String get setupSkipVerifyBody =>
      'Ако загубите ключа за възстановяване, акаунтът ви не може да бъде възстановен. Сигурни ли сте, че искате да пропуснете?';

  @override
  String get setupCreatingAccount => 'Създаване на акаунт…';

  @override
  String get setupRestoringAccount => 'Възстановяване на акаунт…';

  @override
  String get restoreKeyInfoBanner =>
      'Въведете ключа за възстановяване — адресът ви (Nostr + Session) ще бъде възстановен автоматично. Контактите и съобщенията бяха съхранени само локално.';

  @override
  String get restoreKeyHint => 'Ключ за възстановяване';

  @override
  String get settingsViewRecoveryKey => 'Виж ключа за възстановяване';

  @override
  String get settingsViewRecoveryKeySubtitle =>
      'Покажи ключа за възстановяване на акаунта';

  @override
  String get settingsRecoveryKeyNotStored =>
      'Ключът за възстановяване не е наличен (създаден преди тази функция)';

  @override
  String get settingsRecoveryKeyWarning =>
      'Пазете този ключ на сигурно място. Всеки, който го притежава, може да възстанови акаунта ви на друго устройство.';

  @override
  String get replaceIdentityTitle => 'Замяна на съществуваща самоличност?';

  @override
  String get replaceIdentityBodyRestore =>
      'На това устройство вече съществува самоличност. Възстановяването ще замени завинаги текущия ви Nostr ключ и Oxen seed. Всички контакти ще загубят възможността да достигнат текущия ви адрес.\n\nТова не може да бъде отменено.';

  @override
  String get replaceIdentityBodyCreate =>
      'На това устройство вече съществува самоличност. Създаването на нова ще замени завинаги текущия ви Nostr ключ и Oxen seed. Всички контакти ще загубят възможността да достигнат текущия ви адрес.\n\nТова не може да бъде отменено.';

  @override
  String get replace => 'Замени';

  @override
  String get callNoScreenSources => 'Няма налични източници на екран';

  @override
  String get callScreenShareQuality => 'Качество на споделяне на екран';

  @override
  String get callFrameRate => 'Кадрова честота';

  @override
  String get callResolution => 'Разделителна способност';

  @override
  String get callAutoResolution => 'Авто = нативна разделителна способност';

  @override
  String get callStartSharing => 'Започни споделяне';

  @override
  String get callCameraUnavailable =>
      'Камерата не е налична — може да се използва от друго приложение';

  @override
  String get themeResetToDefaults => 'Нулиране до стандартните';

  @override
  String get backupSaveToDownloadsTitle =>
      'Запазване на резервно копие в Изтегляния?';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'Няма наличен файлов диалог. Резервното копие ще бъде запазено в:\n$path';
  }

  @override
  String get systemLabel => 'Система';

  @override
  String get next => 'Напред';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return 'Още $remaining докосвания за активиране на режим за разработчици';
  }

  @override
  String get devModeEnabled => 'Режимът за разработчици е активиран';

  @override
  String get devTools => 'Инструменти за разработчици';

  @override
  String get devAdapterDiagnostics => 'Превключватели на адаптер и диагностика';

  @override
  String get devEnableAll => 'Активирай всички';

  @override
  String get devDisableAll => 'Деактивирай всички';

  @override
  String get turnUrlValidation =>
      'TURN URL трябва да започва с turn: или turns: (макс. 512 символа)';

  @override
  String get callMissedCall => 'Пропуснато обаждане';

  @override
  String get callOutgoingCall => 'Изходящо обаждане';

  @override
  String get callIncomingCall => 'Входящо обаждане';

  @override
  String get mediaMissingData => 'Липсват медийни данни';

  @override
  String get mediaDownloadFailed => 'Изтеглянето неуспешно';

  @override
  String get mediaDecryptFailed => 'Дешифрирането неуспешно';

  @override
  String get callEndCallBanner => 'Край на разговора';

  @override
  String get meFallback => 'Аз';

  @override
  String get imageSaveToDownloads => 'Запази в Изтегляния';

  @override
  String imageSavedToPath(String path) {
    return 'Запазено в $path';
  }

  @override
  String get callScreenShareRequiresPermission =>
      'Споделянето на екран изисква разрешение';

  @override
  String get callScreenShareUnavailable => 'Споделянето на екран не е налично';

  @override
  String get statusJustNow => 'Току-що';

  @override
  String statusMinutesAgo(int minutes) {
    return 'преди $minutesмин';
  }

  @override
  String statusHoursAgo(int hours) {
    return 'преди $hoursч';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count маршрута',
      one: '1 маршрут',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => 'Готов за добавяне';

  @override
  String groupSelectedCount(int count) {
    return '$count избрани';
  }

  @override
  String get paste => 'Поставяне';

  @override
  String get sfuAudioOnly => 'Само аудио';

  @override
  String sfuParticipants(int count) {
    return '$count участници';
  }

  @override
  String get dataUnencryptedBackup => 'Нешифровано резервно копие';

  @override
  String get dataUnencryptedBackupBody =>
      'Този файл е нешифровано резервно копие на самоличност и ще презапише текущите ви ключове. Импортирайте само файлове, създадени от вас. Продължи?';

  @override
  String get dataImportAnyway => 'Импортирай въпреки това';

  @override
  String get securityStorageError =>
      'Грешка в сигурното хранилище — рестартирайте приложението';

  @override
  String get aboutDevModeActive => 'Режим за разработчици активен';

  @override
  String get themeColors => 'Цветове';

  @override
  String get themePrimaryAccent => 'Основен акцент';

  @override
  String get themeSecondaryAccent => 'Вторичен акцент';

  @override
  String get themeBackground => 'Фон';

  @override
  String get themeSurface => 'Повърхност';

  @override
  String get themeChatBubbles => 'Балончета за чат';

  @override
  String get themeOutgoingMessage => 'Изходящо съобщение';

  @override
  String get themeIncomingMessage => 'Входящо съобщение';

  @override
  String get themeShape => 'Форма';

  @override
  String get devSectionDeveloper => 'Разработчик';

  @override
  String get devAdapterChannelsHint =>
      'Канали на адаптер — деактивирайте за тестване на определени транспорти.';

  @override
  String get devNostrRelays => 'Nostr релета (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Session мрежа';

  @override
  String get devPulseRelay => 'Pulse самостоятелно хостван relay';

  @override
  String get devLanNetwork => 'Локална мрежа (UDP/TCP)';

  @override
  String get devSectionCalls => 'Обаждания';

  @override
  String get devForceTurnRelay => 'Принуди TURN relay';

  @override
  String get devForceTurnRelaySubtitle =>
      'Деактивирай P2P — всички обаждания само чрез TURN сървъри';

  @override
  String get devRestartWarning =>
      '⚠ Промените влизат в сила при следващото изпращане/обаждане. Рестартирайте приложението за входящи.';

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

  @override
  String get pulseUseServerTitle => 'Използване на сървъра Pulse?';

  @override
  String pulseUseServerBody(String name, String host) {
    return '$name използва сървъра Pulse $host. Присъединете се, за да общувате по-бързо (и с други на същия сървър)?';
  }

  @override
  String pulseContactUsesPulse(String name) {
    return '$name използва Pulse';
  }

  @override
  String pulseJoinForFaster(String host) {
    return 'Присъединете се към $host за по-бърз чат';
  }

  @override
  String get pulseNotNow => 'Не сега';

  @override
  String get pulseJoin => 'Присъедини се';

  @override
  String get pulseDismiss => 'Отхвърли';

  @override
  String get pulseHide7Days => 'Скрий за 7 дни';

  @override
  String get pulseNeverAskAgain => 'Не питай повече';

  @override
  String get groupSearchContactsHint => 'Търсене на контакти…';

  @override
  String get systemActorYou => 'Вие';

  @override
  String get systemActorPeer => 'Събеседник';

  @override
  String systemTtlEnabled(String actor, String duration) {
    return '$actor включи изчезващи съобщения: $duration';
  }

  @override
  String systemTtlDisabled(String actor) {
    return '$actor изключи изчезващи съобщения';
  }

  @override
  String get menuClearChatHistory => 'Изчисти историята на чата';

  @override
  String get clearChatTitle => 'Да се изчисти историята на чата?';

  @override
  String get clearChatBody =>
      'Всички съобщения в този чат ще бъдат изтрити от това устройство. Другият човек ще запази своето копие.';

  @override
  String get clearChatAction => 'Изчисти';

  @override
  String systemGroupRenamed(String actor, String name) {
    return '$actor преименува групата на „$name\"';
  }

  @override
  String systemGroupAvatarChanged(String actor) {
    return '$actor смени снимката на групата';
  }

  @override
  String systemGroupMetaChanged(String actor, String name) {
    return '$actor преименува групата на „$name\" и смени снимката';
  }

  @override
  String get profileInviteLink => 'Връзка за покана';

  @override
  String get profileInviteLinkSubtitle =>
      'Всеки с връзката може да се присъедини';

  @override
  String get profileInviteLinkCopied => 'Връзката за покана е копирана';

  @override
  String get groupInviteLinkTitle => 'Присъединяване към групата?';

  @override
  String groupInviteLinkBody(String name, int count) {
    return 'Поканен сте в „$name\" ($count участници).';
  }

  @override
  String get groupInviteLinkJoin => 'Присъединяване';

  @override
  String get drawerCreateGroup => 'Създаване на група';

  @override
  String get drawerJoinGroup => 'Присъединяване към група';

  @override
  String get drawerJoinGroupByLinkInvalid =>
      'Това не изглежда като връзка за покана в Pulse';

  @override
  String get groupModeMeshTitle => 'Обикновена';

  @override
  String groupModeMeshSubtitle(int n) {
    return 'Без сървър, до $n души';
  }

  @override
  String get groupModeSfuTitle => 'С Pulse сървър';

  @override
  String groupModeSfuSubtitle(int n) {
    return 'През сървър, до $n души';
  }

  @override
  String get groupPulseServerHint => 'https://вашият-pulse-сървър';

  @override
  String get groupPulseServerClosed => 'Затворен сървър (нужен код за покана)';

  @override
  String get groupPulseInviteHint => 'Код за покана';

  @override
  String groupMeshLimitReached(int n) {
    return 'Този тип обаждане е ограничен до $n души';
  }
}
