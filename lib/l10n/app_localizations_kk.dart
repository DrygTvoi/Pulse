// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Хабарламаларды іздеу...';

  @override
  String get search => 'Іздеу';

  @override
  String get clearSearch => 'Іздеуді тазалау';

  @override
  String get closeSearch => 'Іздеуді жабу';

  @override
  String get moreOptions => 'Қосымша параметрлер';

  @override
  String get back => 'Артқа';

  @override
  String get cancel => 'Бас тарту';

  @override
  String get close => 'Жабу';

  @override
  String get confirm => 'Растау';

  @override
  String get remove => 'Жою';

  @override
  String get save => 'Сақтау';

  @override
  String get add => 'Қосу';

  @override
  String get copy => 'Көшіру';

  @override
  String get skip => 'Өткізіп жіберу';

  @override
  String get done => 'Дайын';

  @override
  String get apply => 'Қолдану';

  @override
  String get export => 'Экспорттау';

  @override
  String get import => 'Импорттау';

  @override
  String get homeNewGroup => 'Жаңа топ';

  @override
  String get homeSettings => 'Параметрлер';

  @override
  String get homeSearching => 'Хабарламалар ізделуде...';

  @override
  String get homeNoResults => 'Нәтиже табылмады';

  @override
  String get homeNoChatHistory => 'Әлі чат тарихы жоқ';

  @override
  String homeTransportSwitched(String address) {
    return 'Транспорт ауыстырылды → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name қоңырау шалуда...';
  }

  @override
  String get homeAccept => 'Қабылдау';

  @override
  String get homeDecline => 'Қабылдамау';

  @override
  String get homeLoadEarlier => 'Бұрынғы хабарламаларды жүктеу';

  @override
  String get homeChats => 'Чаттар';

  @override
  String get homeSelectConversation => 'Әңгімені таңдаңыз';

  @override
  String get homeNoChatsYet => 'Әлі чаттар жоқ';

  @override
  String get homeAddContactToStart => 'Сөйлесуді бастау үшін контакт қосыңыз';

  @override
  String get homeNewChat => 'Жаңа чат';

  @override
  String get homeNewChatTooltip => 'Жаңа чат';

  @override
  String get homeIncomingCallTitle => 'Кіріс қоңырау';

  @override
  String get homeIncomingGroupCallTitle => 'Кіріс топтық қоңырау';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — топтық қоңырау түсуде';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return '\"$query\" сұранысына сәйкес чаттар жоқ';
  }

  @override
  String get homeSectionChats => 'Чаттар';

  @override
  String get homeSectionMessages => 'Хабарламалар';

  @override
  String get homeDbEncryptionUnavailable =>
      'Дерекқор шифрлау қолжетімсіз — толық қорғау үшін SQLCipher орнатыңыз';

  @override
  String get chatFileTooLargeGroup =>
      '512 КБ-тан үлкен файлдар топтық чаттарда қолдау көрсетілмейді';

  @override
  String get chatLargeFile => 'Үлкен файл';

  @override
  String get chatCancel => 'Бас тарту';

  @override
  String get chatSend => 'Жіберу';

  @override
  String get chatFileTooLarge => 'Файл тым үлкен — максималды өлшемі 100 МБ';

  @override
  String get chatMicDenied => 'Микрофон рұқсаты берілмеді';

  @override
  String get chatVoiceFailed =>
      'Дауыстық хабарламаны сақтау сәтсіз аяқталды — бос жадты тексеріңіз';

  @override
  String get chatScheduleFuture => 'Жоспарланған уақыт болашақта болуы керек';

  @override
  String get chatToday => 'Бүгін';

  @override
  String get chatYesterday => 'Кеше';

  @override
  String get chatEdited => 'өңделген';

  @override
  String get chatYou => 'Сіз';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Бұл файл $size МБ. Үлкен файлдарды жіберу кейбір желілерде баяу болуы мүмкін. Жалғастыру керек пе?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return '$name қауіпсіздік кілті өзгерді. Тексеру үшін басыңыз.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return '$name үшін хабарламаны шифрлау мүмкін болмады — хабарлама жіберілмеді.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return '$name үшін қауіпсіздік нөмірі өзгерді. Тексеру үшін басыңыз.';
  }

  @override
  String get chatNoMessagesFound => 'Хабарламалар табылмады';

  @override
  String get chatMessagesE2ee => 'Хабарламалар өтпелі шифрланған';

  @override
  String get chatSayHello => 'Сәлем айтыңыз';

  @override
  String get appBarOnline => 'желіде';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'жазуда';

  @override
  String get appBarSearchMessages => 'Хабарламаларды іздеу...';

  @override
  String get appBarMute => 'Дыбысын өшіру';

  @override
  String get appBarUnmute => 'Дыбысын қосу';

  @override
  String get appBarMedia => 'Медиа';

  @override
  String get appBarDisappearing => 'Жоғалатын хабарламалар';

  @override
  String get appBarDisappearingOn => 'Жоғалатын: қосулы';

  @override
  String get appBarGroupSettings => 'Топ параметрлері';

  @override
  String get appBarSearchTooltip => 'Хабарламаларды іздеу';

  @override
  String get appBarVoiceCall => 'Дауыстық қоңырау';

  @override
  String get appBarVideoCall => 'Бейне қоңырау';

  @override
  String get inputMessage => 'Хабарлама...';

  @override
  String get inputAttachFile => 'Файл тіркеу';

  @override
  String get inputSendMessage => 'Хабарлама жіберу';

  @override
  String get inputRecordVoice => 'Дауыстық хабарлама жазу';

  @override
  String get inputSendVoice => 'Дауыстық хабарлама жіберу';

  @override
  String get inputCancelReply => 'Жауапты бас тарту';

  @override
  String get inputCancelEdit => 'Өңдеуді бас тарту';

  @override
  String get inputCancelRecording => 'Жазуды бас тарту';

  @override
  String get inputRecording => 'Жазылуда…';

  @override
  String get inputEditingMessage => 'Хабарлама өңделуде';

  @override
  String get inputPhoto => 'Фото';

  @override
  String get inputVoiceMessage => 'Дауыстық хабарлама';

  @override
  String get inputFile => 'Файл';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count жоспарланған хабарлама$_temp0';
  }

  @override
  String get callInitializing => 'Қоңырау іске қосылуда…';

  @override
  String get callConnecting => 'Қосылуда…';

  @override
  String get callConnectingRelay => 'Қосылуда (relay)…';

  @override
  String get callSwitchingRelay => 'Relay режиміне ауысуда…';

  @override
  String get callConnectionFailed => 'Қосылу сәтсіз';

  @override
  String get callReconnecting => 'Қайта қосылуда…';

  @override
  String get callEnded => 'Қоңырау аяқталды';

  @override
  String get callLive => 'Тікелей';

  @override
  String get callEnd => 'Аяқтау';

  @override
  String get callEndCall => 'Қоңырауды аяқтау';

  @override
  String get callMute => 'Дыбысын өшіру';

  @override
  String get callUnmute => 'Дыбысын қосу';

  @override
  String get callSpeaker => 'Динамик';

  @override
  String get callCameraOn => 'Камера қосу';

  @override
  String get callCameraOff => 'Камера өшіру';

  @override
  String get callShareScreen => 'Экранды бөлісу';

  @override
  String get callStopShare => 'Бөлісуді тоқтату';

  @override
  String callTorBackup(String duration) {
    return 'Tor резерв · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor резерв белсенді — негізгі жол қолжетімсіз';

  @override
  String get callDirectFailed =>
      'Тікелей қосылу сәтсіз — relay режиміне ауысуда…';

  @override
  String get callTurnUnreachable =>
      'TURN серверлеріне қол жетімсіз. Параметрлер → Кеңейтілген бөлімінде өзіңіздің TURN қосыңыз.';

  @override
  String get callRelayMode => 'Relay режимі белсенді (шектеулі желі)';

  @override
  String get callStarting => 'Қоңырау басталуда…';

  @override
  String get callConnectingToGroup => 'Топқа қосылуда…';

  @override
  String get callGroupOpenedInBrowser => 'Топтық қоңырау браузерде ашылды';

  @override
  String get callCouldNotOpenBrowser => 'Браузерді ашу мүмкін болмады';

  @override
  String get callInviteLinkSent =>
      'Шақыру сілтемесі барлық топ мүшелеріне жіберілді.';

  @override
  String get callOpenLinkManually =>
      'Жоғарыдағы сілтемені қолмен ашыңыз немесе қайталау үшін басыңыз.';

  @override
  String get callJitsiNotE2ee => 'Jitsi қоңыраулары өтпелі шифрланбаған';

  @override
  String get callRetryOpenBrowser => 'Браузерді қайта ашу';

  @override
  String get callClose => 'Жабу';

  @override
  String get callCamOn => 'Камера қосу';

  @override
  String get callCamOff => 'Камера өшіру';

  @override
  String get noConnection => 'Байланыс жоқ — хабарламалар кезекке қойылады';

  @override
  String get connected => 'Қосылған';

  @override
  String get connecting => 'Қосылуда…';

  @override
  String get disconnected => 'Ажыратылған';

  @override
  String get offlineBanner =>
      'Байланыс жоқ — хабарламалар желіге қайта қосылғанда жіберіледі';

  @override
  String get lanModeBanner => 'LAN режимі — Интернет жоқ · Тек жергілікті желі';

  @override
  String get probeCheckingNetwork => 'Желі байланысы тексерілуде…';

  @override
  String get probeDiscoveringRelays =>
      'Қауымдастық каталогтары арқылы relay табылуда…';

  @override
  String get probeStartingTor => 'Tor іске қосылуда…';

  @override
  String get probeFindingRelaysTor => 'Tor арқылы қолжетімді relay ізделуде…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'Желі дайын — $count relay$_temp0 табылды';
  }

  @override
  String get probeNoRelaysFound =>
      'Қолжетімді relay табылмады — хабарламалар кешігуі мүмкін';

  @override
  String get jitsiWarningTitle => 'Өтпелі шифрланбаған';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet қоңыраулары Pulse арқылы шифрланбайды. Тек құпия емес әңгімелер үшін пайдаланыңыз.';

  @override
  String get jitsiConfirm => 'Бәрібір қосылу';

  @override
  String get jitsiGroupWarningTitle => 'Өтпелі шифрланбаған';

  @override
  String get jitsiGroupWarningBody =>
      'Бұл қоңырауда ендірілген шифрланған mesh үшін тым көп қатысушы бар.\n\nJitsi Meet сілтемесі браузеріңізде ашылады. Jitsi өтпелі шифрланбаған — сервер сіздің қоңырауыңызды көре алады.';

  @override
  String get jitsiContinueAnyway => 'Бәрібір жалғастыру';

  @override
  String get retry => 'Қайталау';

  @override
  String get setupCreateAnonymousAccount => 'Анонимді тіркелгі жасау';

  @override
  String get setupTapToChangeColor => 'Түсті өзгерту үшін басыңыз';

  @override
  String get setupYourNickname => 'Сіздің лақап атыңыз';

  @override
  String get setupRecoveryPassword => 'Қалпына келтіру құпия сөзі (мин. 16)';

  @override
  String get setupConfirmPassword => 'Құпия сөзді растау';

  @override
  String get setupMin16Chars => 'Кемінде 16 таңба';

  @override
  String get setupPasswordsDoNotMatch => 'Құпия сөздер сәйкес келмейді';

  @override
  String get setupEntropyWeak => 'Әлсіз';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Күшті';

  @override
  String get setupEntropyWeakNeedsVariety => 'Әлсіз (3 таңба түрі қажет)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits бит)';
  }

  @override
  String get setupPasswordWarning =>
      'Бұл құпия сөз тіркелгіңізді қалпына келтірудің жалғыз жолы. Сервер жоқ — құпия сөзді қалпына келтіру мүмкін емес. Есте сақтаңыз немесе жазып қойыңыз.';

  @override
  String get setupCreateAccount => 'Тіркелгі жасау';

  @override
  String get setupAlreadyHaveAccount => 'Тіркелгіңіз бар ма? ';

  @override
  String get setupRestore => 'Қалпына келтіру →';

  @override
  String get restoreTitle => 'Тіркелгіні қалпына келтіру';

  @override
  String get restoreInfoBanner =>
      'Қалпына келтіру құпия сөзін енгізіңіз — сіздің мекенжайыңыз (Nostr + Session) автоматты түрде қалпына келтіріледі. Контактілер мен хабарламалар тек жергілікті түрде сақталған.';

  @override
  String get restoreNewNickname => 'Жаңа лақап ат (кейін өзгертуге болады)';

  @override
  String get restoreButton => 'Тіркелгіні қалпына келтіру';

  @override
  String get lockTitle => 'Pulse құлыпталған';

  @override
  String get lockSubtitle => 'Жалғастыру үшін құпия сөзді енгізіңіз';

  @override
  String get lockPasswordHint => 'Құпия сөз';

  @override
  String get lockUnlock => 'Құлыпты ашу';

  @override
  String get lockPanicHint =>
      'Құпия сөзді ұмыттыңыз ба? Барлық деректерді жою үшін тосын кілтті енгізіңіз.';

  @override
  String get lockTooManyAttempts => 'Тым көп әрекет. Барлық деректер жойылуда…';

  @override
  String get lockWrongPassword => 'Қате құпия сөз';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Қате құпия сөз — $attempts/$max әрекет';
  }

  @override
  String get onboardingSkip => 'Өткізіп жіберу';

  @override
  String get onboardingNext => 'Келесі';

  @override
  String get onboardingGetStarted => 'Бастау';

  @override
  String get onboardingWelcomeTitle => 'Pulse-қа қош келдіңіз';

  @override
  String get onboardingWelcomeBody =>
      'Орталықсыздандырылған, өтпелі шифрланған мессенджер.\n\nОрталық серверлер жоқ. Деректер жинау жоқ. Құпия есіктер жоқ.\nСіздің әңгімелеріңіз тек сізге тиесілі.';

  @override
  String get onboardingTransportTitle => 'Транспортқа тәуелсіз';

  @override
  String get onboardingTransportBody =>
      'Firebase, Nostr немесе екеуін де бір уақытта пайдаланыңыз.\n\nХабарламалар желілер арқылы автоматты түрде бағытталады. Цензураға қарсы ендірілген Tor және I2P қолдауы.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Әрбір хабарлама алға құпиялылық үшін Signal Protocol (Double Ratchet + X3DH) арқылы шифрланады.\n\nСонымен қатар Kyber-1024 — NIST стандартты пост-кванттық алгоритм — болашақ кванттық компьютерлерден қорғау үшін қапталады.';

  @override
  String get onboardingKeysTitle => 'Кілттер сізге тиесілі';

  @override
  String get onboardingKeysBody =>
      'Сіздің жеке кілттеріңіз ешқашан құрылғыдан шықпайды.\n\nSignal саусақ іздері контактілерді сыртқы арна арқылы тексеруге мүмкіндік береді. TOFU (Trust On First Use) кілт өзгерістерін автоматты түрде анықтайды.';

  @override
  String get onboardingThemeTitle => 'Стиліңізді таңдаңыз';

  @override
  String get onboardingThemeBody =>
      'Тақырып пен акцент түсін таңдаңыз. Мұны кез келген уақытта Параметрлерде өзгертуге болады.';

  @override
  String get contactsNewChat => 'Жаңа чат';

  @override
  String get contactsAddContact => 'Контакт қосу';

  @override
  String get contactsSearchHint => 'Іздеу...';

  @override
  String get contactsNewGroup => 'Жаңа топ';

  @override
  String get contactsNoContactsYet => 'Әлі контактілер жоқ';

  @override
  String get contactsAddHint => 'Біреудің мекенжайын қосу үшін + басыңыз';

  @override
  String get contactsNoMatch => 'Сәйкес контактілер жоқ';

  @override
  String get contactsRemoveTitle => 'Контактіні жою';

  @override
  String contactsRemoveMessage(String name) {
    return '$name жою керек пе?';
  }

  @override
  String get contactsRemove => 'Жою';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count контакт$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Сілтемені ашу';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Бұл URL мекенжайын браузерде ашу керек пе?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Ашу';

  @override
  String get bubbleSecurityWarning => 'Қауіпсіздік ескертуі';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" орындалатын файл түрі. Оны сақтау және іске қосу құрылғыңызға зиян тигізуі мүмкін. Бәрібір сақтау керек пе?';
  }

  @override
  String get bubbleSaveAnyway => 'Бәрібір сақтау';

  @override
  String bubbleSavedTo(String path) {
    return '$path жеріне сақталды';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Сақтау сәтсіз: $error';
  }

  @override
  String get bubbleNotEncrypted => 'ШИФРЛАНБАҒАН';

  @override
  String get bubbleCorruptedImage => '[Бүлінген сурет]';

  @override
  String get bubbleReplyPhoto => 'Фото';

  @override
  String get bubbleReplyVoice => 'Дауыстық хабарлама';

  @override
  String get bubbleReplyVideo => 'Бейне хабарлама';

  @override
  String bubbleReadBy(String names) {
    return '$names оқыды';
  }

  @override
  String bubbleReadByCount(int count) {
    return '$count оқыды';
  }

  @override
  String get chatTileTapToStart => 'Сөйлесуді бастау үшін басыңыз';

  @override
  String get chatTileMessageSent => 'Хабарлама жіберілді';

  @override
  String get chatTileEncryptedMessage => 'Шифрланған хабарлама';

  @override
  String chatTileYouPrefix(String text) {
    return 'Сіз: $text';
  }

  @override
  String get bannerEncryptedMessage => 'Шифрланған хабарлама';

  @override
  String get groupNewGroup => 'Жаңа топ';

  @override
  String get groupGroupName => 'Топ атауы';

  @override
  String get groupSelectMembers => 'Мүшелерді таңдаңыз (мин. 2)';

  @override
  String get groupNoContactsYet =>
      'Әлі контактілер жоқ. Алдымен контактілер қосыңыз.';

  @override
  String get groupCreate => 'Жасау';

  @override
  String get groupLabel => 'Топ';

  @override
  String get profileVerifyIdentity => 'Жеке басын тексеру';

  @override
  String profileVerifyInstructions(String name) {
    return 'Бұл саусақ іздерін $name адаммен дауыстық қоңырау немесе жеке кездесу арқылы салыстырыңыз. Егер екі құрылғыда да мәндер бірдей болса, \"Тексерілген деп белгілеу\" батырмасын басыңыз.';
  }

  @override
  String get profileTheirKey => 'Олардың кілті';

  @override
  String get profileYourKey => 'Сіздің кілтіңіз';

  @override
  String get profileRemoveVerification => 'Тексеруді жою';

  @override
  String get profileMarkAsVerified => 'Тексерілген деп белгілеу';

  @override
  String get profileAddressCopied => 'Мекенжай көшірілді';

  @override
  String get profileNoContactsToAdd =>
      'Қосатын контактілер жоқ — барлығы мүше болып табылады';

  @override
  String get profileAddMembers => 'Мүшелер қосу';

  @override
  String profileAddCount(int count) {
    return 'Қосу ($count)';
  }

  @override
  String get profileRenameGroup => 'Топты қайта атау';

  @override
  String get profileRename => 'Қайта атау';

  @override
  String get profileRemoveMember => 'Мүшені жою керек пе?';

  @override
  String profileRemoveMemberBody(String name) {
    return '$name осы топтан жою керек пе?';
  }

  @override
  String get profileKick => 'Шығару';

  @override
  String get profileSignalFingerprints => 'Signal саусақ іздері';

  @override
  String get profileVerified => 'ТЕКСЕРІЛГЕН';

  @override
  String get profileVerify => 'Тексеру';

  @override
  String get profileEdit => 'Өңдеу';

  @override
  String get profileNoSession =>
      'Әлі сессия орнатылмаған — алдымен хабарлама жіберіңіз.';

  @override
  String get profileFingerprintCopied => 'Саусақ ізі көшірілді';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count мүше$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Қауіпсіздік нөмірін тексеру';

  @override
  String get profileShowContactQr => 'Контакт QR көрсету';

  @override
  String profileContactAddress(String name) {
    return '$name мекенжайы';
  }

  @override
  String get profileExportChatHistory => 'Чат тарихын экспорттау';

  @override
  String profileSavedTo(String path) {
    return '$path жеріне сақталды';
  }

  @override
  String get profileExportFailed => 'Экспорт сәтсіз';

  @override
  String get profileClearChatHistory => 'Чат тарихын тазалау';

  @override
  String get profileDeleteGroup => 'Топты жою';

  @override
  String get profileDeleteContact => 'Контактіні жою';

  @override
  String get profileLeaveGroup => 'Топтан шығу';

  @override
  String get profileLeaveGroupBody =>
      'Сіз бұл топтан шығарыласыз және ол контактілеріңізден жойылады.';

  @override
  String get groupInviteTitle => 'Топқа шақыру';

  @override
  String groupInviteBody(String from, String group) {
    return '$from сізді \"$group\" топқа қосылуға шақырды';
  }

  @override
  String get groupInviteAccept => 'Қабылдау';

  @override
  String get groupInviteDecline => 'Қабылдамау';

  @override
  String get groupMemberLimitTitle => 'Тым көп қатысушы';

  @override
  String groupMemberLimitBody(int count) {
    return 'Бұл топта $count қатысушы болады. Шифрланған mesh қоңыраулар 6 адамға дейін қолдайды. Үлкен топтар Jitsi-ге ауысады (E2EE емес).';
  }

  @override
  String get groupMemberLimitContinue => 'Бәрібір қосу';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name \"$group\" топқа қосылудан бас тартты';
  }

  @override
  String get transferTitle => 'Басқа құрылғыға тасымалдау';

  @override
  String get transferInfoBox =>
      'Signal жеке басын және Nostr кілттерін жаңа құрылғыға тасымалдаңыз.\nЧат сессиялары тасымалданбайды — алға құпиялылық сақталады.';

  @override
  String get transferSendFromThis => 'Осы құрылғыдан жіберу';

  @override
  String get transferSendSubtitle =>
      'Бұл құрылғыда кілттер бар. Жаңа құрылғымен код бөлісіңіз.';

  @override
  String get transferReceiveOnThis => 'Осы құрылғыда қабылдау';

  @override
  String get transferReceiveSubtitle =>
      'Бұл жаңа құрылғы. Ескі құрылғыдан кодты енгізіңіз.';

  @override
  String get transferChooseMethod => 'Тасымалдау әдісін таңдаңыз';

  @override
  String get transferLan => 'LAN (Бір желі)';

  @override
  String get transferLanSubtitle =>
      'Жылдам және тікелей. Екі құрылғы да бір Wi-Fi-да болуы керек.';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'Бар Nostr relay арқылы кез келген желіде жұмыс істейді.';

  @override
  String get transferRelayUrl => 'Relay URL';

  @override
  String get transferEnterCode => 'Тасымалдау кодын енгізіңіз';

  @override
  String get transferPasteCode => 'LAN:... немесе NOS:... кодын мұнда қойыңыз';

  @override
  String get transferConnect => 'Қосылу';

  @override
  String get transferGenerating => 'Тасымалдау коды жасалуда…';

  @override
  String get transferShareCode => 'Бұл кодты қабылдаушымен бөлісіңіз:';

  @override
  String get transferCopyCode => 'Кодты көшіру';

  @override
  String get transferCodeCopied => 'Код буферге көшірілді';

  @override
  String get transferWaitingReceiver => 'Қабылдаушының қосылуы күтілуде…';

  @override
  String get transferConnectingSender => 'Жіберушіге қосылуда…';

  @override
  String get transferVerifyBoth =>
      'Бұл кодты екі құрылғыда салыстырыңыз.\nЕгер олар сәйкес келсе, тасымалдау қауіпсіз.';

  @override
  String get transferComplete => 'Тасымалдау аяқталды';

  @override
  String get transferKeysImported => 'Кілттер импортталды';

  @override
  String get transferCompleteSenderBody =>
      'Кілттеріңіз бұл құрылғыда белсенді қалады.\nҚабылдаушы енді сіздің жеке басыңызды пайдалана алады.';

  @override
  String get transferCompleteReceiverBody =>
      'Кілттер сәтті импортталды.\nЖаңа жеке басты қолдану үшін қолданбаны қайта іске қосыңыз.';

  @override
  String get transferRestartApp => 'Қолданбаны қайта іске қосу';

  @override
  String get transferFailed => 'Тасымалдау сәтсіз';

  @override
  String get transferTryAgain => 'Қайталау';

  @override
  String get transferEnterRelayFirst => 'Алдымен relay URL енгізіңіз';

  @override
  String get transferPasteCodeFromSender =>
      'Жіберушінің тасымалдау кодын қойыңыз';

  @override
  String get menuReply => 'Жауап беру';

  @override
  String get menuForward => 'Қайта жіберу';

  @override
  String get menuReact => 'Реакция';

  @override
  String get menuCopy => 'Көшіру';

  @override
  String get menuEdit => 'Өңдеу';

  @override
  String get menuRetry => 'Қайталау';

  @override
  String get menuCancelScheduled => 'Жоспарланғанды бас тарту';

  @override
  String get menuDelete => 'Жою';

  @override
  String get menuForwardTo => 'Қайта жіберу…';

  @override
  String menuForwardedTo(String name) {
    return '$name адамға қайта жіберілді';
  }

  @override
  String get menuScheduledMessages => 'Жоспарланған хабарламалар';

  @override
  String get menuNoScheduledMessages => 'Жоспарланған хабарламалар жоқ';

  @override
  String menuSendsOn(String date) {
    return '$date күні жіберіледі';
  }

  @override
  String get menuDisappearingMessages => 'Жоғалатын хабарламалар';

  @override
  String get menuDisappearingSubtitle =>
      'Хабарламалар таңдалған уақыттан кейін автоматты түрде жойылады.';

  @override
  String get menuTtlOff => 'Өшірулі';

  @override
  String get menuTtl1h => '1 сағат';

  @override
  String get menuTtl24h => '24 сағат';

  @override
  String get menuTtl7d => '7 күн';

  @override
  String get menuAttachPhoto => 'Фото';

  @override
  String get menuAttachFile => 'Файл';

  @override
  String get menuAttachVideo => 'Бейне';

  @override
  String get mediaTitle => 'Медиа';

  @override
  String get mediaFileLabel => 'ФАЙЛ';

  @override
  String mediaPhotosTab(int count) {
    return 'Фотолар ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Файлдар ($count)';
  }

  @override
  String get mediaNoPhotos => 'Әлі фотолар жоқ';

  @override
  String get mediaNoFiles => 'Әлі файлдар жоқ';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Downloads/$name жеріне сақталды';
  }

  @override
  String get mediaFailedToSave => 'Файлды сақтау сәтсіз';

  @override
  String get statusNewStatus => 'Жаңа мәртебе';

  @override
  String get statusPublish => 'Жариялау';

  @override
  String get statusExpiresIn24h => 'Мәртебе 24 сағаттан кейін аяқталады';

  @override
  String get statusWhatsOnYourMind => 'Не ойлайсыз?';

  @override
  String get statusPhotoAttached => 'Фото тіркелді';

  @override
  String get statusAttachPhoto => 'Фото тіркеу (міндетті емес)';

  @override
  String get statusEnterText => 'Мәртебеңіз үшін мәтін енгізіңіз.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Фотоны таңдау сәтсіз: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Жариялау сәтсіз: $error';
  }

  @override
  String get panicSetPanicKey => 'Тосын кілтті орнату';

  @override
  String get panicEmergencySelfDestruct => 'Төтенше өзін-өзі жою';

  @override
  String get panicIrreversible => 'Бұл әрекетті кері қайтару мүмкін емес';

  @override
  String get panicWarningBody =>
      'Құлыптау экранында бұл кілтті енгізу БАРЛЫҚ деректерді бірден жояды — хабарламалар, контактілер, кілттер, жеке бас. Кәдімгі құпия сөзіңізден басқа кілт пайдаланыңыз.';

  @override
  String get panicKeyHint => 'Тосын кілт';

  @override
  String get panicConfirmHint => 'Тосын кілтті растау';

  @override
  String get panicMinChars => 'Тосын кілт кемінде 8 таңба болуы керек';

  @override
  String get panicKeysDoNotMatch => 'Кілттер сәйкес келмейді';

  @override
  String get panicSetFailed => 'Тосын кілтті сақтау сәтсіз — қайталап көріңіз';

  @override
  String get passwordSetAppPassword => 'Қолданба құпия сөзін орнату';

  @override
  String get passwordProtectsMessages =>
      'Хабарламаларыңызды тыныштықта қорғайды';

  @override
  String get passwordInfoBanner =>
      'Pulse ашқан сайын қажет. Ұмытылса, деректеріңізді қалпына келтіру мүмкін емес.';

  @override
  String get passwordHint => 'Құпия сөз';

  @override
  String get passwordConfirmHint => 'Құпия сөзді растау';

  @override
  String get passwordSetButton => 'Құпия сөз орнату';

  @override
  String get passwordSkipForNow => 'Әзірге өткізіп жіберу';

  @override
  String get passwordMinChars => 'Құпия сөз кемінде 6 таңба болуы керек';

  @override
  String get passwordsDoNotMatch => 'Құпия сөздер сәйкес келмейді';

  @override
  String get profileCardSaved => 'Профиль сақталды!';

  @override
  String get profileCardE2eeIdentity => 'E2EE жеке бас';

  @override
  String get profileCardDisplayName => 'Көрсетілетін аты';

  @override
  String get profileCardDisplayNameHint => 'мыс. Алмас Қасымов';

  @override
  String get profileCardAbout => 'Өзім туралы';

  @override
  String get profileCardSaveProfile => 'Профильді сақтау';

  @override
  String get profileCardYourName => 'Сіздің атыңыз';

  @override
  String get profileCardAddressCopied => 'Мекенжай көшірілді!';

  @override
  String get profileCardInboxAddress => 'Кіріс мекенжайыңыз';

  @override
  String get profileCardInboxAddresses => 'Кіріс мекенжайларыңыз';

  @override
  String get profileCardShareAllAddresses =>
      'Барлық мекенжайларды бөлісу (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Контактілермен бөлісіңіз, сонда олар сізге жаза алады.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Барлық $count мекенжай бір сілтеме ретінде көшірілді!';
  }

  @override
  String get settingsMyProfile => 'Менің профилім';

  @override
  String get settingsYourInboxAddress => 'Кіріс мекенжайыңыз';

  @override
  String get settingsMyQrCode => 'Менің QR кодым';

  @override
  String get settingsMyQrSubtitle =>
      'Мекенжайды сканерленетін QR ретінде бөлісу';

  @override
  String get settingsShareMyAddress => 'Мекенжайымды бөлісу';

  @override
  String get settingsNoAddressYet =>
      'Әлі мекенжай жоқ — алдымен параметрлерді сақтаңыз';

  @override
  String get settingsInviteLink => 'Шақыру сілтемесі';

  @override
  String get settingsRawAddress => 'Бастапқы мекенжай';

  @override
  String get settingsCopyLink => 'Сілтемені көшіру';

  @override
  String get settingsCopyAddress => 'Мекенжайды көшіру';

  @override
  String get settingsInviteLinkCopied => 'Шақыру сілтемесі көшірілді';

  @override
  String get settingsAppearance => 'Сыртқы түрі';

  @override
  String get settingsThemeEngine => 'Тақырып қозғалтқышы';

  @override
  String get settingsThemeEngineSubtitle => 'Түстер мен қаріптерді баптау';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle =>
      'E2EE кілттері қауіпсіз сақталған';

  @override
  String get settingsActive => 'БЕЛСЕНДІ';

  @override
  String get settingsIdentityBackup => 'Жеке бас сақтық көшірмесі';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Signal жеке басын экспорттау немесе импорттау';

  @override
  String get settingsIdentityBackupBody =>
      'Signal жеке бас кілттерін сақтық кодқа экспорттаңыз немесе бар кодтан қалпына келтіріңіз.';

  @override
  String get settingsTransferDevice => 'Басқа құрылғыға тасымалдау';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Жеке басты LAN немесе Nostr relay арқылы тасымалдау';

  @override
  String get settingsExportIdentity => 'Жеке басты экспорттау';

  @override
  String get settingsExportIdentityBody =>
      'Бұл сақтық кодты көшіріп, қауіпсіз сақтаңыз:';

  @override
  String get settingsSaveFile => 'Файлды сақтау';

  @override
  String get settingsImportIdentity => 'Жеке басты импорттау';

  @override
  String get settingsImportIdentityBody =>
      'Сақтық кодты төменге қойыңыз. Бұл ағымдағы жеке басыңызды қайта жазады.';

  @override
  String get settingsPasteBackupCode => 'Сақтық кодты мұнда қойыңыз…';

  @override
  String get settingsIdentityImported =>
      'Жеке бас + контактілер импортталды! Қолдану үшін қолданбаны қайта іске қосыңыз.';

  @override
  String get settingsSecurity => 'Қауіпсіздік';

  @override
  String get settingsAppPassword => 'Қолданба құпия сөзі';

  @override
  String get settingsPasswordEnabled => 'Қосулы — әр іске қосуда қажет';

  @override
  String get settingsPasswordDisabled =>
      'Өшірулі — қолданба құпия сөзсіз ашылады';

  @override
  String get settingsChangePassword => 'Құпия сөзді өзгерту';

  @override
  String get settingsChangePasswordSubtitle =>
      'Қолданба құлыптау құпия сөзін жаңарту';

  @override
  String get settingsSetPanicKey => 'Тосын кілтті орнату';

  @override
  String get settingsChangePanicKey => 'Тосын кілтті өзгерту';

  @override
  String get settingsPanicKeySetSubtitle => 'Төтенше жою кілтін жаңарту';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Барлық деректерді бірден жоятын бір кілт';

  @override
  String get settingsRemovePanicKey => 'Тосын кілтті жою';

  @override
  String get settingsRemovePanicKeySubtitle => 'Төтенше өзін-өзі жоюды өшіру';

  @override
  String get settingsRemovePanicKeyBody =>
      'Төтенше өзін-өзі жою өшіріледі. Оны кез келген уақытта қайта қосуға болады.';

  @override
  String get settingsDisableAppPassword => 'Қолданба құпия сөзін өшіру';

  @override
  String get settingsEnterCurrentPassword =>
      'Растау үшін ағымдағы құпия сөзді енгізіңіз';

  @override
  String get settingsCurrentPassword => 'Ағымдағы құпия сөз';

  @override
  String get settingsIncorrectPassword => 'Қате құпия сөз';

  @override
  String get settingsPasswordUpdated => 'Құпия сөз жаңартылды';

  @override
  String get settingsChangePasswordProceed =>
      'Жалғастыру үшін ағымдағы құпия сөзді енгізіңіз';

  @override
  String get settingsData => 'Деректер';

  @override
  String get settingsBackupMessages => 'Хабарламалардың сақтық көшірмесі';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Шифрланған хабарлама тарихын файлға экспорттау';

  @override
  String get settingsRestoreMessages => 'Хабарламаларды қалпына келтіру';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Сақтық көшірме файлынан хабарламаларды импорттау';

  @override
  String get settingsExportKeys => 'Кілттерді экспорттау';

  @override
  String get settingsExportKeysSubtitle =>
      'Жеке бас кілттерін шифрланған файлға сақтау';

  @override
  String get settingsImportKeys => 'Кілттерді импорттау';

  @override
  String get settingsImportKeysSubtitle =>
      'Экспортталған файлдан жеке бас кілттерін қалпына келтіру';

  @override
  String get settingsBackupPassword => 'Сақтық көшірме құпия сөзі';

  @override
  String get settingsPasswordCannotBeEmpty => 'Құпия сөз бос болмауы керек';

  @override
  String get settingsPasswordMin4Chars =>
      'Құпия сөз кемінде 4 таңба болуы керек';

  @override
  String get settingsCallsTurn => 'Қоңыраулар & TURN';

  @override
  String get settingsLocalNetwork => 'Жергілікті желі';

  @override
  String get settingsCensorshipResistance => 'Цензураға қарсылық';

  @override
  String get settingsNetwork => 'Желі';

  @override
  String get settingsProxyTunnels => 'Прокси & Туннельдер';

  @override
  String get settingsTurnServers => 'TURN серверлері';

  @override
  String get settingsProviderTitle => 'Провайдер';

  @override
  String get settingsLanFallback => 'LAN резерві';

  @override
  String get settingsLanFallbackSubtitle =>
      'Интернет қолжетімсіз болғанда жергілікті желіде болу мен хабарламаларды жеткізу. Сенімсіз желілерде (қоғамдық Wi-Fi) өшіріңіз.';

  @override
  String get settingsBgDelivery => 'Фондық жеткізу';

  @override
  String get settingsBgDeliverySubtitle =>
      'Қолданба кішірейтілгенде хабарламаларды қабылдауды жалғастыру. Тұрақты хабарландыру көрсетеді.';

  @override
  String get settingsYourInboxProvider => 'Кіріс провайдеріңіз';

  @override
  String get settingsConnectionDetails => 'Қосылу мәліметтері';

  @override
  String get settingsSaveAndConnect => 'Сақтау & Қосылу';

  @override
  String get settingsSecondaryInboxes => 'Қосымша кіріс жәшіктер';

  @override
  String get settingsAddSecondaryInbox => 'Қосымша кіріс жәшік қосу';

  @override
  String get settingsAdvanced => 'Кеңейтілген';

  @override
  String get settingsDiscover => 'Табу';

  @override
  String get settingsAbout => 'Бағдарлама туралы';

  @override
  String get settingsPrivacyPolicy => 'Құпиялылық саясаты';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Pulse деректеріңізді қалай қорғайды';

  @override
  String get settingsCrashReporting => 'Апат есептері';

  @override
  String get settingsCrashReportingSubtitle =>
      'Pulse-ды жақсарту үшін анонимді апат есептерін жіберу. Хабарлама мазмұны немесе контактілер ешқашан жіберілмейді.';

  @override
  String get settingsCrashReportingEnabled =>
      'Апат есептері қосулы — қолдану үшін қолданбаны қайта іске қосыңыз';

  @override
  String get settingsCrashReportingDisabled =>
      'Апат есептері өшірулі — қолдану үшін қолданбаны қайта іске қосыңыз';

  @override
  String get settingsSensitiveOperation => 'Сезімтал операция';

  @override
  String get settingsSensitiveOperationBody =>
      'Бұл кілттер сіздің жеке басыңыз. Бұл файлы бар кез келген адам сізді бұрмалай алады. Қауіпсіз сақтаңыз және тасымалдаудан кейін жойыңыз.';

  @override
  String get settingsIUnderstandContinue => 'Түсінемін, жалғастыру';

  @override
  String get settingsReplaceIdentity => 'Жеке басты ауыстыру керек пе?';

  @override
  String get settingsReplaceIdentityBody =>
      'Бұл ағымдағы жеке бас кілттеріңізді қайта жазады. Бар Signal сессиялары жарамсыз болады және контактілер шифрлауды қайта орнатуы керек. Қолданбаны қайта іске қосу қажет.';

  @override
  String get settingsReplaceKeys => 'Кілттерді ауыстыру';

  @override
  String get settingsKeysImported => 'Кілттер импортталды';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count кілт сәтті импортталды. Жаңа жеке баспен қайта іске қосу үшін қолданбаны қайта іске қосыңыз.';
  }

  @override
  String get settingsRestartNow => 'Қазір қайта іске қосу';

  @override
  String get settingsLater => 'Кейін';

  @override
  String get profileGroupLabel => 'Топ';

  @override
  String get profileAddButton => 'Қосу';

  @override
  String get profileKickButton => 'Шығару';

  @override
  String get dataSectionTitle => 'Деректер';

  @override
  String get dataBackupMessages => 'Хабарламалардың сақтық көшірмесі';

  @override
  String get dataBackupPasswordSubtitle =>
      'Сақтық көшірмені шифрлау үшін құпия сөз таңдаңыз.';

  @override
  String get dataBackupConfirmLabel => 'Сақтық көшірме жасау';

  @override
  String get dataCreatingBackup => 'Сақтық көшірме жасалуда';

  @override
  String get dataBackupPreparing => 'Дайындалуда...';

  @override
  String dataBackupExporting(int done, int total) {
    return '$total ішінен $done хабарлама экспортталуда...';
  }

  @override
  String get dataBackupSavingFile => 'Файл сақталуда...';

  @override
  String get dataSaveMessageBackupDialog =>
      'Хабарламалар сақтық көшірмесін сақтау';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Сақтық көшірме сақталды ($count хабарлама)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Сақтық көшірме сәтсіз — деректер экспортталмады';

  @override
  String dataBackupFailedError(String error) {
    return 'Сақтық көшірме сәтсіз: $error';
  }

  @override
  String get dataSelectMessageBackupDialog =>
      'Хабарламалар сақтық көшірмесін таңдау';

  @override
  String get dataInvalidBackupFile =>
      'Жарамсыз сақтық көшірме файлы (тым кішкентай)';

  @override
  String get dataNotValidBackupFile =>
      'Жарамды Pulse сақтық көшірме файлы емес';

  @override
  String get dataRestoreMessages => 'Хабарламаларды қалпына келтіру';

  @override
  String get dataRestorePasswordSubtitle =>
      'Осы сақтық көшірмені жасау үшін пайдаланылған құпия сөзді енгізіңіз.';

  @override
  String get dataRestoreConfirmLabel => 'Қалпына келтіру';

  @override
  String get dataRestoringMessages => 'Хабарламалар қалпына келтірілуде';

  @override
  String get dataRestoreDecrypting => 'Шифры ашылуда...';

  @override
  String dataRestoreImporting(int done, int total) {
    return '$total ішінен $done хабарлама импортталуда...';
  }

  @override
  String get dataRestoreFailed =>
      'Қалпына келтіру сәтсіз — қате құпия сөз немесе бүлінген файл';

  @override
  String dataRestoreSuccess(int count) {
    return '$count жаңа хабарлама қалпына келтірілді';
  }

  @override
  String get dataRestoreNothingNew =>
      'Импорттайтын жаңа хабарламалар жоқ (барлығы бұрыннан бар)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Қалпына келтіру сәтсіз: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Кілт экспортын таңдау';

  @override
  String get dataNotValidKeyFile => 'Жарамды Pulse кілт экспорт файлы емес';

  @override
  String get dataExportKeys => 'Кілттерді экспорттау';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Кілт экспортын шифрлау үшін құпия сөз таңдаңыз.';

  @override
  String get dataExportKeysConfirmLabel => 'Экспорттау';

  @override
  String get dataExportingKeys => 'Кілттер экспортталуда';

  @override
  String get dataExportingKeysStatus => 'Жеке бас кілттері шифрлануда...';

  @override
  String get dataSaveKeyExportDialog => 'Кілт экспортын сақтау';

  @override
  String dataKeysExportedTo(String path) {
    return 'Кілттер экспортталды:\n$path';
  }

  @override
  String get dataExportFailed => 'Экспорт сәтсіз — кілттер табылмады';

  @override
  String dataExportFailedError(String error) {
    return 'Экспорт сәтсіз: $error';
  }

  @override
  String get dataImportKeys => 'Кілттерді импорттау';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Осы кілт экспортын шифрлау үшін пайдаланылған құпия сөзді енгізіңіз.';

  @override
  String get dataImportKeysConfirmLabel => 'Импорттау';

  @override
  String get dataImportingKeys => 'Кілттер импортталуда';

  @override
  String get dataImportingKeysStatus => 'Жеке бас кілттерінің шифры ашылуда...';

  @override
  String get dataImportFailed =>
      'Импорт сәтсіз — қате құпия сөз немесе бүлінген файл';

  @override
  String dataImportFailedError(String error) {
    return 'Импорт сәтсіз: $error';
  }

  @override
  String get securitySectionTitle => 'Қауіпсіздік';

  @override
  String get securityIncorrectPassword => 'Қате құпия сөз';

  @override
  String get securityPasswordUpdated => 'Құпия сөз жаңартылды';

  @override
  String get appearanceSectionTitle => 'Сыртқы түрі';

  @override
  String appearanceExportFailed(String error) {
    return 'Экспорт сәтсіз: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return '$path жеріне сақталды';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Сақтау сәтсіз: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Импорт сәтсіз: $error';
  }

  @override
  String get aboutSectionTitle => 'Бағдарлама туралы';

  @override
  String get providerPublicKey => 'Ашық кілт';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Қалпына келтіру құпия сөзіңізден автоматты түрде бапталды. Relay автоматты түрде табылды.';

  @override
  String get providerKeyStoredLocally =>
      'Кілтіңіз қауіпсіз жадта жергілікті түрде сақталады — ешқашан серверге жіберілмейді.';

  @override
  String get providerOxenInfo =>
      'Oxen/Session желісі — onion-бағытталған E2EE. Session ID автоматты түрде жасалады және қауіпсіз сақталады. Түйіндер ендірілген seed түйіндерінен автоматты түрде табылады.';

  @override
  String get providerAdvanced => 'Кеңейтілген';

  @override
  String get providerSaveAndConnect => 'Сақтау & Қосылу';

  @override
  String get providerAddSecondaryInbox => 'Қосымша кіріс жәшік қосу';

  @override
  String get providerSecondaryInboxes => 'Қосымша кіріс жәшіктер';

  @override
  String get providerYourInboxProvider => 'Кіріс провайдеріңіз';

  @override
  String get providerConnectionDetails => 'Қосылу мәліметтері';

  @override
  String get addContactTitle => 'Контакт қосу';

  @override
  String get addContactInviteLinkLabel => 'Шақыру сілтемесі немесе мекенжай';

  @override
  String get addContactTapToPaste => 'Шақыру сілтемесін қою үшін басыңыз';

  @override
  String get addContactPasteTooltip => 'Буферден қою';

  @override
  String get addContactAddressDetected => 'Контакт мекенжайы анықталды';

  @override
  String addContactRoutesDetected(int count) {
    return '$count маршрут анықталды — SmartRouter ең жылдамын таңдайды';
  }

  @override
  String get addContactFetchingProfile => 'Профиль алынуда…';

  @override
  String addContactProfileFound(String name) {
    return 'Табылды: $name';
  }

  @override
  String get addContactNoProfileFound => 'Профиль табылмады';

  @override
  String get addContactDisplayNameLabel => 'Көрсетілетін аты';

  @override
  String get addContactDisplayNameHint => 'Оны қалай атағыңыз келеді?';

  @override
  String get addContactAddManually => 'Мекенжайды қолмен енгізу';

  @override
  String get addContactButton => 'Контакт қосу';

  @override
  String get networkDiagnosticsTitle => 'Желі диагностикасы';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr Relay-лар';

  @override
  String get networkDiagnosticsDirect => 'Тікелей';

  @override
  String get networkDiagnosticsTorOnly => 'Тек Tor';

  @override
  String get networkDiagnosticsBest => 'Ең жақсы';

  @override
  String get networkDiagnosticsNone => 'жоқ';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Күйі';

  @override
  String get networkDiagnosticsConnected => 'Қосылған';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Қосылуда $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Өшірулі';

  @override
  String get networkDiagnosticsTransport => 'Транспорт';

  @override
  String get networkDiagnosticsInfrastructure => 'Инфрақұрылым';

  @override
  String get networkDiagnosticsOxenNodes => 'Oxen түйіндері';

  @override
  String get networkDiagnosticsTurnServers => 'TURN серверлері';

  @override
  String get networkDiagnosticsLastProbe => 'Соңғы тексеру';

  @override
  String get networkDiagnosticsRunning => 'Жұмыс істеуде...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Диагностика жүргізу';

  @override
  String get networkDiagnosticsForceReprobe =>
      'Толық қайта тексеруді мәжбүрлеу';

  @override
  String get networkDiagnosticsJustNow => 'жаңа ғана';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes мин бұрын';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours сағ бұрын';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days күн бұрын';
  }

  @override
  String get homeNoEch => 'ECH жоқ';

  @override
  String get homeNoEchTooltip =>
      'uTLS прокси қолжетімсіз — ECH өшірілген.\nTLS саусақ ізі DPI-ге көрінеді.';

  @override
  String get settingsTitle => 'Параметрлер';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Сақталды & $provider провайдеріне қосылды';
  }

  @override
  String get settingsTorFailedToStart => 'Ендірілген Tor іске қосылмады';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon іске қосылмады';

  @override
  String get verifyTitle => 'Қауіпсіздік нөмірін тексеру';

  @override
  String get verifyIdentityVerified => 'Жеке бас тексерілді';

  @override
  String get verifyNotYetVerified => 'Әлі тексерілмеген';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Сіз $name қауіпсіздік нөмірін тексердіңіз.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Бұл сандарды $name адаммен жеке немесе сенімді арна арқылы салыстырыңыз.';
  }

  @override
  String get verifyExplanation =>
      'Әрбір әңгіменің бірегей қауіпсіздік нөмірі бар. Егер екеуіңіз де құрылғыларыңызда бірдей сандарды көрсеңіз, байланысыңыз өтпелі тексерілген.';

  @override
  String verifyContactKey(String name) {
    return '$name кілті';
  }

  @override
  String get verifyYourKey => 'Сіздің кілтіңіз';

  @override
  String get verifyRemoveVerification => 'Тексеруді жою';

  @override
  String get verifyMarkAsVerified => 'Тексерілген деп белгілеу';

  @override
  String verifyAfterReinstall(String name) {
    return 'Егер $name қолданбаны қайта орнатса, қауіпсіздік нөмірі өзгереді және тексеру автоматты түрде жойылады.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Тексерілген деп белгілеуді тек $name адаммен дауыстық қоңырау немесе жеке кездесу арқылы сандарды салыстырғаннан кейін ғана жасаңыз.';
  }

  @override
  String get verifyNoSession =>
      'Әлі шифрлау сессиясы орнатылмаған. Қауіпсіздік нөмірлерін жасау үшін алдымен хабарлама жіберіңіз.';

  @override
  String get verifyNoKeyAvailable => 'Кілт қолжетімсіз';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label саусақ ізі көшірілді';
  }

  @override
  String get providerDatabaseUrlLabel => 'Дерекқор URL';

  @override
  String get providerOptionalHint => 'Міндетті емес';

  @override
  String get providerWebApiKeyLabel => 'Web API кілті';

  @override
  String get providerOptionalForPublicDb =>
      'Қоғамдық дерекқор үшін міндетті емес';

  @override
  String get providerRelayUrlLabel => 'Relay URL';

  @override
  String get providerPrivateKeyLabel => 'Жеке кілт';

  @override
  String get providerPrivateKeyNsecLabel => 'Жеке кілт (nsec)';

  @override
  String get providerStorageNodeLabel => 'Сақтау түйіні URL (міндетті емес)';

  @override
  String get providerStorageNodeHint =>
      'Ендірілген seed түйіндері үшін бос қалдырыңыз';

  @override
  String get transferInvalidCodeFormat =>
      'Белгісіз код пішімі — LAN: немесе NOS: арқылы басталуы керек';

  @override
  String get profileCardFingerprintCopied => 'Саусақ ізі көшірілді';

  @override
  String get profileCardAboutHint => 'Құпиялылық бірінші 🔒';

  @override
  String get profileCardSaveButton => 'Профильді сақтау';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Шифрланған хабарламаларды, контактілерді және аватарларды файлға экспорттау';

  @override
  String get callVideo => 'Бейне';

  @override
  String get callAudio => 'Аудио';

  @override
  String bubbleDeliveredTo(String names) {
    return '$names жеткізілді';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return '$count жеткізілді';
  }

  @override
  String get groupStatusDialogTitle => 'Хабарлама ақпараты';

  @override
  String get groupStatusRead => 'Оқылды';

  @override
  String get groupStatusDelivered => 'Жеткізілді';

  @override
  String get groupStatusPending => 'Күтуде';

  @override
  String get groupStatusNoData => 'Әлі жеткізу ақпараты жоқ';

  @override
  String get profileTransferAdmin => 'Админ ету';

  @override
  String profileTransferAdminConfirm(String name) {
    return '$name жаңа админ ету керек пе?';
  }

  @override
  String get profileTransferAdminBody =>
      'Сіз админ құқықтарын жоғалтасыз. Бұл кері қайтарылмайды.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name енді админ';
  }

  @override
  String get profileAdminBadge => 'Админ';

  @override
  String get privacyPolicyTitle => 'Құпиялылық саясаты';

  @override
  String get privacyOverviewHeading => 'Шолу';

  @override
  String get privacyOverviewBody =>
      'Pulse — серверсіз, өтпелі шифрланған мессенджер. Сіздің құпиялылығыңыз тек мүмкіндік емес — бұл архитектура. Pulse серверлері жоқ. Тіркелгілер ешқайда сақталмайды. Деректер жасаушылар тарапынан жиналмайды, тасымалданбайды және сақталмайды.';

  @override
  String get privacyDataCollectionHeading => 'Деректер жинау';

  @override
  String get privacyDataCollectionBody =>
      'Pulse жеке деректерді мүлде жинамайды. Атап айтқанда:\n\n- Электрондық пошта, телефон нөмірі немесе нақты ат қажет емес\n- Аналитика, бақылау немесе телеметрия жоқ\n- Жарнамалық идентификаторлар жоқ\n- Контактілер тізіміне қол жетімділік жоқ\n- Бұлтты сақтық көшірмелер жоқ (хабарламалар тек құрылғыңызда бар)\n- Ешқандай Pulse серверіне метадеректер жіберілмейді (олар жоқ)';

  @override
  String get privacyEncryptionHeading => 'Шифрлау';

  @override
  String get privacyEncryptionBody =>
      'Барлық хабарламалар Signal Protocol (X3DH кілт келісімімен Double Ratchet) арқылы шифрланады. Шифрлау кілттері тек сіздің құрылғыңызда жасалады және сақталады. Ешкім — жасаушылар да — хабарламаларыңызды оқи алмайды.';

  @override
  String get privacyNetworkHeading => 'Желі архитектурасы';

  @override
  String get privacyNetworkBody =>
      'Pulse федерацияланған транспорт адаптерлерін пайдаланады (Nostr relay-лар, Session/Oxen қызмет түйіндері, Firebase Realtime Database, LAN). Бұл транспорттар тек шифрланған мәтінді тасымалдайды. Relay операторлары сіздің IP мекенжайыңыз бен трафик көлемін көре алады, бірақ хабарлама мазмұнын ашу мүмкін емес.\n\nTor қосылған кезде IP мекенжайыңыз relay операторларынан да жасырылады.';

  @override
  String get privacyStunHeading => 'STUN/TURN серверлері';

  @override
  String get privacyStunBody =>
      'Дауыстық және бейне қоңыраулар DTLS-SRTP шифрлауымен WebRTC пайдаланады. STUN серверлері (тікелей P2P қосылу үшін сіздің ашық IP-ңізді анықтау) және TURN серверлері (тікелей қосылу сәтсіз болғанда медианы ретрансляциялау) сіздің IP мекенжайыңыз бен қоңырау ұзақтығын көре алады, бірақ қоңырау мазмұнын ашу мүмкін емес.\n\nМаксималды құпиялылық үшін Параметрлерде өзіңіздің TURN серверін баптауға болады.';

  @override
  String get privacyCrashHeading => 'Апат есептері';

  @override
  String get privacyCrashBody =>
      'Егер Sentry апат есептері қосылса (құрастыру кезінде SENTRY_DSN арқылы), анонимді апат есептері жіберілуі мүмкін. Олар хабарлама мазмұнын, контакт ақпаратын және жеке сәйкестендіретін ақпаратты қамтымайды. Апат есептерін DSN-ді алып тастау арқылы құрастыру кезінде өшіруге болады.';

  @override
  String get privacyPasswordHeading => 'Құпия сөз & Кілттер';

  @override
  String get privacyPasswordBody =>
      'Қалпына келтіру құпия сөзіңіз Argon2id (жадқа қатаң KDF) арқылы криптографиялық кілттерді шығару үшін пайдаланылады. Құпия сөз ешқайда тасымалданбайды. Құпия сөзіңізді жоғалтсаңыз, тіркелгіңізді қалпына келтіру мүмкін емес — оны қалпына келтіретін сервер жоқ.';

  @override
  String get privacyFontsHeading => 'Қаріптер';

  @override
  String get privacyFontsBody =>
      'Pulse барлық қаріптерді жергілікті түрде қамтиды. Google Fonts немесе кез келген сыртқы қаріп қызметіне сұраулар жіберілмейді.';

  @override
  String get privacyThirdPartyHeading => 'Үшінші тарап қызметтері';

  @override
  String get privacyThirdPartyBody =>
      'Pulse ешқандай жарнамалық желілермен, аналитика провайдерлерімен, әлеуметтік медиа платформаларымен немесе деректер брокерлерімен интеграцияланбайды. Жалғыз желілік қосылулар сіз баптаған транспорт relay-ларына жасалады.';

  @override
  String get privacyOpenSourceHeading => 'Ашық бастапқы код';

  @override
  String get privacyOpenSourceBody =>
      'Pulse ашық бастапқы кодты бағдарламалық жасақтама. Осы құпиялылық мәлімдемелерін тексеру үшін толық бастапқы кодты тексеруге болады.';

  @override
  String get privacyContactHeading => 'Байланыс';

  @override
  String get privacyContactBody =>
      'Құпиялылыққа қатысты сұрақтар үшін жоба репозиторийінде мәселе ашыңыз.';

  @override
  String get privacyLastUpdated => 'Соңғы жаңарту: Наурыз 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Сақтау сәтсіз: $error';
  }

  @override
  String get themeEngineTitle => 'Тақырып қозғалтқышы';

  @override
  String get torBuiltInTitle => 'Ендірілген Tor';

  @override
  String get torConnectedSubtitle =>
      'Қосылған — Nostr 127.0.0.1:9250 арқылы бағытталады';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Қосылуда… $pct%';
  }

  @override
  String get torNotRunning =>
      'Жұмыс істемейді — қайта іске қосу үшін қосқышты басыңыз';

  @override
  String get torDescription =>
      'Nostr-ды Tor арқылы бағыттайды (цензураланған желілер үшін Snowflake)';

  @override
  String get torNetworkDiagnostics => 'Желі диагностикасы';

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
  String get torPtPlain => 'Қарапайым';

  @override
  String get torTimeoutLabel => 'Уақыт шегі: ';

  @override
  String get torInfoDescription =>
      'Қосылған кезде Nostr WebSocket қосылулары Tor (SOCKS5) арқылы бағытталады. Tor Browser 127.0.0.1:9150 портын тыңдайды. Жеке tor демоны 9050 портын пайдаланады. Firebase қосылулары әсер етпейді.';

  @override
  String get torRouteNostrTitle => 'Nostr-ды Tor арқылы бағыттау';

  @override
  String get torManagedByBuiltin => 'Ендірілген Tor арқылы басқарылады';

  @override
  String get torActiveRouting =>
      'Белсенді — Nostr трафигі Tor арқылы бағытталуда';

  @override
  String get torDisabled => 'Өшірілген';

  @override
  String get torProxySocks5 => 'Tor прокси (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Прокси хост';

  @override
  String get torProxyPortLabel => 'Порт';

  @override
  String get torPortInfo => 'Tor Browser: порт 9150  •  tor демоны: порт 9050';

  @override
  String get i2pProxySocks5 => 'I2P прокси (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P әдепкі бойынша 4447 портында SOCKS5 пайдаланады. Кез келген транспорттағы пайдаланушылармен байланысу үшін I2P outproxy арқылы Nostr relay-ға қосылыңыз (мыс. relay.damus.i2p). Екеуі де қосылған кезде Tor басымдыққа ие.';

  @override
  String get i2pRouteNostrTitle => 'Nostr-ды I2P арқылы бағыттау';

  @override
  String get i2pActiveRouting =>
      'Белсенді — Nostr трафигі I2P арқылы бағытталуда';

  @override
  String get i2pDisabled => 'Өшірілген';

  @override
  String get i2pProxyHostLabel => 'Прокси хост';

  @override
  String get i2pProxyPortLabel => 'Порт';

  @override
  String get i2pPortInfo => 'I2P Router әдепкі SOCKS5 порты: 4447';

  @override
  String get customProxySocks5 => 'Теңшелетін прокси (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Теңшелетін прокси трафикті V2Ray/Xray/Shadowsocks арқылы бағыттайды. CF Worker жеке relay прокси ретінде Cloudflare CDN-де жұмыс істейді — GFW *.workers.dev көреді, нақты relay емес.';

  @override
  String get customSocks5ProxyTitle => 'Теңшелетін SOCKS5 прокси';

  @override
  String get customProxyActive => 'Белсенді — трафик SOCKS5 арқылы бағытталуда';

  @override
  String get customProxyDisabled => 'Өшірілген';

  @override
  String get customProxyHostLabel => 'Прокси хост';

  @override
  String get customProxyPortLabel => 'Порт';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker домені (міндетті емес)';

  @override
  String get customWorkerHelpTitle =>
      'CF Worker relay-ді қалай орналастыру (тегін)';

  @override
  String get customWorkerScriptCopied => 'Скрипт көшірілді!';

  @override
  String get customWorkerStep1 =>
      '1. dash.cloudflare.com → Workers & Pages бөліміне өтіңіз\n2. Create Worker → осы скриптті қойыңыз:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → доменді көшіріңіз (мыс. my-relay.user.workers.dev)\n4. Доменді жоғарыға қойыңыз → Сақтау\n\nҚолданба автоматты қосылады: wss://domain/?r=relay_url\nGFW көреді: *.workers.dev (CF CDN) қосылуы';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Қосылған — SOCKS5 127.0.0.1:$port портында';
  }

  @override
  String get psiphonConnecting => 'Қосылуда…';

  @override
  String get psiphonNotRunning =>
      'Жұмыс істемейді — қайта іске қосу үшін қосқышты басыңыз';

  @override
  String get psiphonDescription =>
      'Жылдам туннель (~3 сек жүктеу, 2000+ ротациялық VPS)';

  @override
  String get turnCommunityServers => 'Қауымдастық TURN серверлері';

  @override
  String get turnCustomServer => 'Теңшелетін TURN сервері (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN серверлері тек бұрыннан шифрланған ағындарды ретрансляциялайды (DTLS-SRTP). Relay операторы сіздің IP мекенжайыңыз бен трафик көлемін көреді, бірақ қоңырауларды ашу мүмкін емес. TURN тікелей P2P сәтсіз болғанда ғана пайдаланылады (қосылулардың ~15–20%).';

  @override
  String get turnFreeLabel => 'ТЕГІН';

  @override
  String get turnServerUrlLabel => 'TURN сервер URL';

  @override
  String get turnServerUrlHint =>
      'turn:сіздің-сервер.com:3478 немесе turns:...';

  @override
  String get turnUsernameLabel => 'Пайдаланушы аты';

  @override
  String get turnPasswordLabel => 'Құпия сөз';

  @override
  String get turnOptionalHint => 'Міндетті емес';

  @override
  String get turnCustomInfo =>
      'Максималды басқару үшін кез келген \$5/ай VPS-те coturn орнатыңыз. Тіркелгі деректері жергілікті түрде сақталады.';

  @override
  String get themePickerAppearance => 'Сыртқы түрі';

  @override
  String get themePickerAccentColor => 'Акцент түсі';

  @override
  String get themeModeLight => 'Жарық';

  @override
  String get themeModeDark => 'Қараңғы';

  @override
  String get themeModeSystem => 'Жүйелік';

  @override
  String get themeDynamicPresets => 'Алдын ала орнатулар';

  @override
  String get themeDynamicPrimaryColor => 'Негізгі түс';

  @override
  String get themeDynamicBorderRadius => 'Шекара радиусы';

  @override
  String get themeDynamicFont => 'Қаріп';

  @override
  String get themeDynamicAppearance => 'Сыртқы түрі';

  @override
  String get themeDynamicUiStyle => 'UI стилі';

  @override
  String get themeDynamicUiStyleDescription =>
      'Диалогтар, қосқыштар мен индикаторлардың көрінісін басқарады.';

  @override
  String get themeDynamicSharp => 'Өткір';

  @override
  String get themeDynamicRound => 'Дөңгелек';

  @override
  String get themeDynamicModeDark => 'Қараңғы';

  @override
  String get themeDynamicModeLight => 'Жарық';

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
      'Жарамсыз Firebase URL. Күтілетін: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Жарамсыз relay URL. Күтілетін: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Жарамсыз Pulse сервер URL. Күтілетін: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'Сервер URL';

  @override
  String get providerPulseServerUrlHint => 'https://сіздің-сервер:8443';

  @override
  String get providerPulseInviteLabel => 'Шақыру коды';

  @override
  String get providerPulseInviteHint => 'Шақыру коды (қажет болса)';

  @override
  String get providerPulseInfo =>
      'Өздігінен орналастырылған relay. Кілттер қалпына келтіру құпия сөзіңізден алынған.';

  @override
  String get providerScreenTitle => 'Кіріс жәшіктер';

  @override
  String get providerSecondaryInboxesHeader => 'ҚОСЫМША КІРІС ЖӘШІКТЕР';

  @override
  String get providerSecondaryInboxesInfo =>
      'Қосымша кіріс жәшіктер артықшылық үшін хабарламаларды бір мезгілде қабылдайды.';

  @override
  String get providerRemoveTooltip => 'Жою';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... немесе hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... немесе hex жеке кілт';

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
  String get emojiNoRecent => 'Соңғы эмодзилер жоқ';

  @override
  String get emojiSearchHint => 'Эмодзи іздеу...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Сөйлесу үшін басыңыз';

  @override
  String get imageViewerSaveToDownloads => 'Downloads-қа сақтау';

  @override
  String imageViewerSavedTo(String path) {
    return '$path жеріне сақталды';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Тіл';

  @override
  String get settingsLanguageSubtitle => 'Қолданба көрсету тілі';

  @override
  String get settingsLanguageSystem => 'Жүйелік әдепкі';

  @override
  String get onboardingLanguageTitle => 'Тіліңізді таңдаңыз';

  @override
  String get onboardingLanguageSubtitle =>
      'Мұны кейін Параметрлерде өзгертуге болады';
}
