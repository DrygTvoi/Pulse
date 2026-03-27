// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Serbian (`sr`).
class AppLocalizationsSr extends AppLocalizations {
  AppLocalizationsSr([String locale = 'sr']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Претражи поруке...';

  @override
  String get search => 'Претрага';

  @override
  String get clearSearch => 'Обриши претрагу';

  @override
  String get closeSearch => 'Затвори претрагу';

  @override
  String get moreOptions => 'Више опција';

  @override
  String get back => 'Назад';

  @override
  String get cancel => 'Откажи';

  @override
  String get close => 'Затвори';

  @override
  String get confirm => 'Потврди';

  @override
  String get remove => 'Уклони';

  @override
  String get save => 'Сачувај';

  @override
  String get add => 'Додај';

  @override
  String get copy => 'Копирај';

  @override
  String get skip => 'Прескочи';

  @override
  String get done => 'Готово';

  @override
  String get apply => 'Примени';

  @override
  String get export => 'Извези';

  @override
  String get import => 'Увези';

  @override
  String get homeNewGroup => 'Нова група';

  @override
  String get homeSettings => 'Подешавања';

  @override
  String get homeSearching => 'Претраживање порука...';

  @override
  String get homeNoResults => 'Нема резултата';

  @override
  String get homeNoChatHistory => 'Још нема историје ћаскања';

  @override
  String homeTransportSwitched(String address) {
    return 'Транспорт промењен → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name зове...';
  }

  @override
  String get homeAccept => 'Прихвати';

  @override
  String get homeDecline => 'Одбиј';

  @override
  String get homeLoadEarlier => 'Учитај старије поруке';

  @override
  String get homeChats => 'Ћаскања';

  @override
  String get homeSelectConversation => 'Изаберите разговор';

  @override
  String get homeNoChatsYet => 'Још нема ћаскања';

  @override
  String get homeAddContactToStart => 'Додајте контакт да бисте почели';

  @override
  String get homeNewChat => 'Нови разговор';

  @override
  String get homeNewChatTooltip => 'Нови разговор';

  @override
  String get homeIncomingCallTitle => 'Долазни позив';

  @override
  String get homeIncomingGroupCallTitle => 'Долазни групни позив';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — долазни групни позив';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Нема ћаскања која одговарају \"$query\"';
  }

  @override
  String get homeSectionChats => 'Ћаскања';

  @override
  String get homeSectionMessages => 'Поруке';

  @override
  String get homeDbEncryptionUnavailable =>
      'Шифровање базе података није доступно — инсталирајте SQLCipher за пуну заштиту';

  @override
  String get chatFileTooLargeGroup =>
      'Фајлови преко 512 KB нису подржани у групним ћаскањима';

  @override
  String get chatLargeFile => 'Велики фајл';

  @override
  String get chatCancel => 'Откажи';

  @override
  String get chatSend => 'Пошаљи';

  @override
  String get chatFileTooLarge =>
      'Фајл је превелик — максимална величина је 100 MB';

  @override
  String get chatMicDenied => 'Дозвола за микрофон одбијена';

  @override
  String get chatVoiceFailed =>
      'Није успело чување гласовне поруке — проверите доступан простор';

  @override
  String get chatScheduleFuture => 'Заказано време мора бити у будућности';

  @override
  String get chatToday => 'Данас';

  @override
  String get chatYesterday => 'Јуче';

  @override
  String get chatEdited => 'измењено';

  @override
  String get chatYou => 'Ви';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Овај фајл има $size MB. Слање великих фајлова може бити споро на неким мрежама. Наставити?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Безбедносни кључ корисника $name је промењен. Додирните за верификацију.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Није могуће шифровати поруку за $name — порука није послата.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Безбедносни број за $name је промењен. Додирните за верификацију.';
  }

  @override
  String get chatNoMessagesFound => 'Нису пронађене поруке';

  @override
  String get chatMessagesE2ee => 'Поруке су шифроване од краја до краја';

  @override
  String get chatSayHello => 'Реците здраво';

  @override
  String get appBarOnline => 'на мрежи';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'куца';

  @override
  String get appBarSearchMessages => 'Претражи поруке...';

  @override
  String get appBarMute => 'Утишај';

  @override
  String get appBarUnmute => 'Укључи звук';

  @override
  String get appBarMedia => 'Медији';

  @override
  String get appBarDisappearing => 'Нестајуће поруке';

  @override
  String get appBarDisappearingOn => 'Нестајуће: укључено';

  @override
  String get appBarGroupSettings => 'Подешавања групе';

  @override
  String get appBarSearchTooltip => 'Претражи поруке';

  @override
  String get appBarVoiceCall => 'Гласовни позив';

  @override
  String get appBarVideoCall => 'Видео позив';

  @override
  String get inputMessage => 'Порука...';

  @override
  String get inputAttachFile => 'Приложи фајл';

  @override
  String get inputSendMessage => 'Пошаљи поруку';

  @override
  String get inputRecordVoice => 'Сними гласовну поруку';

  @override
  String get inputSendVoice => 'Пошаљи гласовну поруку';

  @override
  String get inputCancelReply => 'Откажи одговор';

  @override
  String get inputCancelEdit => 'Откажи измену';

  @override
  String get inputCancelRecording => 'Откажи снимање';

  @override
  String get inputRecording => 'Снимање…';

  @override
  String get inputEditingMessage => 'Измена поруке';

  @override
  String get inputPhoto => 'Фотографија';

  @override
  String get inputVoiceMessage => 'Гласовна порука';

  @override
  String get inputFile => 'Фајл';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заказаних порука',
      few: '$count заказане поруке',
      one: '$count заказана порука',
    );
    return '$_temp0';
  }

  @override
  String get callInitializing => 'Иницијализација позива…';

  @override
  String get callConnecting => 'Повезивање…';

  @override
  String get callConnectingRelay => 'Повезивање (преко релеја)…';

  @override
  String get callSwitchingRelay => 'Прелазак на режим релеја…';

  @override
  String get callConnectionFailed => 'Повезивање неуспешно';

  @override
  String get callReconnecting => 'Поновно повезивање…';

  @override
  String get callEnded => 'Позив завршен';

  @override
  String get callLive => 'Уживо';

  @override
  String get callEnd => 'Заврши';

  @override
  String get callEndCall => 'Заврши позив';

  @override
  String get callMute => 'Утишај';

  @override
  String get callUnmute => 'Укључи звук';

  @override
  String get callSpeaker => 'Звучник';

  @override
  String get callCameraOn => 'Камера укључена';

  @override
  String get callCameraOff => 'Камера искључена';

  @override
  String get callShareScreen => 'Дели екран';

  @override
  String get callStopShare => 'Заустави дељење';

  @override
  String callTorBackup(String duration) {
    return 'Tor резерва · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor резерва активна — примарна путања недоступна';

  @override
  String get callDirectFailed =>
      'Директна веза неуспешна — прелазак на режим релеја…';

  @override
  String get callTurnUnreachable =>
      'TURN сервери недоступни. Додајте прилагођени TURN у Подешавања → Напредно.';

  @override
  String get callRelayMode => 'Режим релеја активан (ограничена мрежа)';

  @override
  String get callStarting => 'Покретање позива…';

  @override
  String get callConnectingToGroup => 'Повезивање на групу…';

  @override
  String get callGroupOpenedInBrowser => 'Групни позив отворен у прегледачу';

  @override
  String get callCouldNotOpenBrowser => 'Није могуће отворити прегледач';

  @override
  String get callInviteLinkSent =>
      'Линк за позивницу послат свим члановима групе.';

  @override
  String get callOpenLinkManually =>
      'Отворите линк изнад ручно или додирните за поновни покушај.';

  @override
  String get callJitsiNotE2ee =>
      'Jitsi позиви НИСУ шифровани од краја до краја';

  @override
  String get callRetryOpenBrowser => 'Поново отвори прегледач';

  @override
  String get callClose => 'Затвори';

  @override
  String get callCamOn => 'Камера укљ.';

  @override
  String get callCamOff => 'Камера искљ.';

  @override
  String get noConnection => 'Нема везе — поруке ће бити у реду чекања';

  @override
  String get connected => 'Повезано';

  @override
  String get connecting => 'Повезивање…';

  @override
  String get disconnected => 'Неповезано';

  @override
  String get offlineBanner =>
      'Нема везе — поруке ће бити у реду чекања и послате кад се вратите на мрежу';

  @override
  String get lanModeBanner => 'LAN режим — Без интернета · Само локална мрежа';

  @override
  String get probeCheckingNetwork => 'Провера мрежне повезаности…';

  @override
  String get probeDiscoveringRelays =>
      'Откривање релеја преко директоријума заједнице…';

  @override
  String get probeStartingTor => 'Покретање Tor-а за покретање…';

  @override
  String get probeFindingRelaysTor =>
      'Проналажење доступних релеја преко Tor-а…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Мрежа спремна — $count релеја пронађено',
      few: 'Мрежа спремна — $count релеја пронађена',
      one: 'Мрежа спремна — $count релеј пронађен',
    );
    return '$_temp0';
  }

  @override
  String get probeNoRelaysFound =>
      'Нема доступних релеја — поруке могу каснити';

  @override
  String get jitsiWarningTitle => 'Није шифровано од краја до краја';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet позиви нису шифровани од стране Pulse. Користите само за неосетљиве разговоре.';

  @override
  String get jitsiConfirm => 'Придружи се свеједно';

  @override
  String get jitsiGroupWarningTitle => 'Није шифровано од краја до краја';

  @override
  String get jitsiGroupWarningBody =>
      'Овај позив има превише учесника за уграђену шифровану мрежу.\n\nJitsi Meet линк ће бити отворен у вашем прегледачу. Jitsi НИЈЕ шифрован од краја до краја — сервер може видети ваш позив.';

  @override
  String get jitsiContinueAnyway => 'Настави свеједно';

  @override
  String get retry => 'Покушај поново';

  @override
  String get setupCreateAnonymousAccount => 'Направи анонимни налог';

  @override
  String get setupTapToChangeColor => 'Додирни за промену боје';

  @override
  String get setupYourNickname => 'Ваш надимак';

  @override
  String get setupRecoveryPassword => 'Лозинка за опоравак (мин. 16)';

  @override
  String get setupConfirmPassword => 'Потврди лозинку';

  @override
  String get setupMin16Chars => 'Минимум 16 знакова';

  @override
  String get setupPasswordsDoNotMatch => 'Лозинке се не подударају';

  @override
  String get setupEntropyWeak => 'Слаба';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Јака';

  @override
  String get setupEntropyWeakNeedsVariety =>
      'Слаба (потребна су 3 типа знакова)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits бита)';
  }

  @override
  String get setupPasswordWarning =>
      'Ова лозинка је једини начин да повратите свој налог. Нема сервера — нема ресетовања лозинке. Запамтите је или запишите.';

  @override
  String get setupCreateAccount => 'Направи налог';

  @override
  String get setupAlreadyHaveAccount => 'Већ имате налог? ';

  @override
  String get setupRestore => 'Поврати →';

  @override
  String get restoreTitle => 'Поврати налог';

  @override
  String get restoreInfoBanner =>
      'Унесите лозинку за опоравак — ваша адреса (Nostr + Session) биће аутоматски повраћена. Контакти и поруке су били ускладиштени само локално.';

  @override
  String get restoreNewNickname => 'Нови надимак (можете променити касније)';

  @override
  String get restoreButton => 'Поврати налог';

  @override
  String get lockTitle => 'Pulse је закључан';

  @override
  String get lockSubtitle => 'Унесите лозинку за наставак';

  @override
  String get lockPasswordHint => 'Лозинка';

  @override
  String get lockUnlock => 'Откључај';

  @override
  String get lockPanicHint =>
      'Заборавили лозинку? Унесите панични кључ за брисање свих података.';

  @override
  String get lockTooManyAttempts => 'Превише покушаја. Брисање свих података…';

  @override
  String get lockWrongPassword => 'Погрешна лозинка';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Погрешна лозинка — $attempts/$max покушаја';
  }

  @override
  String get onboardingSkip => 'Прескочи';

  @override
  String get onboardingNext => 'Следеће';

  @override
  String get onboardingGetStarted => 'Започни';

  @override
  String get onboardingWelcomeTitle => 'Добродошли у Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Децентрализовани месинџер са шифровањем од краја до краја.\n\nБез централних сервера. Без прикупљања података. Без задњих врата.\nВаши разговори припадају само вама.';

  @override
  String get onboardingTransportTitle => 'Независност транспорта';

  @override
  String get onboardingTransportBody =>
      'Користите Firebase, Nostr или обоје истовремено.\n\nПоруке се аутоматски рутирају кроз мреже. Уграђена подршка за Tor и I2P за отпорност на цензуру.';

  @override
  String get onboardingSignalTitle => 'Signal + пост-квантум';

  @override
  String get onboardingSignalBody =>
      'Свака порука је шифрована Signal протоколом (Double Ratchet + X3DH) за тајност унапред.\n\nДодатно обавијена Kyber-1024 — NIST стандардним пост-квантним алгоритмом — који штити од будућих квантних рачунара.';

  @override
  String get onboardingKeysTitle => 'Ваши кључеви су ваши';

  @override
  String get onboardingKeysBody =>
      'Ваши кључеви идентитета никада не напуштају ваш уређај.\n\nSignal отисци вам омогућавају верификацију контаката ван канала. TOFU (Trust On First Use) аутоматски детектује промене кључева.';

  @override
  String get onboardingThemeTitle => 'Изаберите свој изглед';

  @override
  String get onboardingThemeBody =>
      'Изаберите тему и боју нагласка. Увек можете ово променити касније у Подешавањима.';

  @override
  String get contactsNewChat => 'Нови разговор';

  @override
  String get contactsAddContact => 'Додај контакт';

  @override
  String get contactsSearchHint => 'Претрага...';

  @override
  String get contactsNewGroup => 'Нова група';

  @override
  String get contactsNoContactsYet => 'Још нема контаката';

  @override
  String get contactsAddHint => 'Додирните + да додате нечију адресу';

  @override
  String get contactsNoMatch => 'Нема подударајућих контаката';

  @override
  String get contactsRemoveTitle => 'Уклони контакт';

  @override
  String contactsRemoveMessage(String name) {
    return 'Уклонити $name?';
  }

  @override
  String get contactsRemove => 'Уклони';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count контаката',
      few: '$count контакта',
      one: '$count контакт',
    );
    return '$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Отвори линк';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Отворити овај URL у прегледачу?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Отвори';

  @override
  String get bubbleSecurityWarning => 'Безбедносно упозорење';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" је извршни тип фајла. Чување и покретање може оштетити ваш уређај. Сачувати свеједно?';
  }

  @override
  String get bubbleSaveAnyway => 'Сачувај свеједно';

  @override
  String bubbleSavedTo(String path) {
    return 'Сачувано у $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Чување неуспешно: $error';
  }

  @override
  String get bubbleNotEncrypted => 'НИЈЕ ШИФРОВАНО';

  @override
  String get bubbleCorruptedImage => '[Оштећена слика]';

  @override
  String get bubbleReplyPhoto => 'Фотографија';

  @override
  String get bubbleReplyVoice => 'Гласовна порука';

  @override
  String get bubbleReplyVideo => 'Видео порука';

  @override
  String bubbleReadBy(String names) {
    return 'Прочитано од $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Прочитано од $count';
  }

  @override
  String get chatTileTapToStart => 'Додирните за почетак ћаскања';

  @override
  String get chatTileMessageSent => 'Порука послата';

  @override
  String get chatTileEncryptedMessage => 'Шифрована порука';

  @override
  String chatTileYouPrefix(String text) {
    return 'Ви: $text';
  }

  @override
  String get bannerEncryptedMessage => 'Шифрована порука';

  @override
  String get groupNewGroup => 'Нова група';

  @override
  String get groupGroupName => 'Назив групе';

  @override
  String get groupSelectMembers => 'Изаберите чланове (мин. 2)';

  @override
  String get groupNoContactsYet => 'Још нема контаката. Прво додајте контакте.';

  @override
  String get groupCreate => 'Направи';

  @override
  String get groupLabel => 'Група';

  @override
  String get profileVerifyIdentity => 'Верификуј идентитет';

  @override
  String profileVerifyInstructions(String name) {
    return 'Упоредите ове отиске прстију са $name преко гласовног позива или лично. Ако се обе вредности подударају на оба уређаја, додирните \"Означи као верификовано\".';
  }

  @override
  String get profileTheirKey => 'Њихов кључ';

  @override
  String get profileYourKey => 'Ваш кључ';

  @override
  String get profileRemoveVerification => 'Уклони верификацију';

  @override
  String get profileMarkAsVerified => 'Означи као верификовано';

  @override
  String get profileAddressCopied => 'Адреса копирана';

  @override
  String get profileNoContactsToAdd =>
      'Нема контаката за додавање — сви су већ чланови';

  @override
  String get profileAddMembers => 'Додај чланове';

  @override
  String profileAddCount(int count) {
    return 'Додај ($count)';
  }

  @override
  String get profileRenameGroup => 'Преименуј групу';

  @override
  String get profileRename => 'Преименуј';

  @override
  String get profileRemoveMember => 'Уклонити члана?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Уклонити $name из ове групе?';
  }

  @override
  String get profileKick => 'Избаци';

  @override
  String get profileSignalFingerprints => 'Signal отисци';

  @override
  String get profileVerified => 'ВЕРИФИКОВАНО';

  @override
  String get profileVerify => 'Верификуј';

  @override
  String get profileEdit => 'Измени';

  @override
  String get profileNoSession =>
      'Сесија још није успостављена — прво пошаљите поруку.';

  @override
  String get profileFingerprintCopied => 'Отисак копиран';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count чланова',
      few: '$count члана',
      one: '$count члан',
    );
    return '$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Верификуј безбедносни број';

  @override
  String get profileShowContactQr => 'Прикажи QR контакта';

  @override
  String profileContactAddress(String name) {
    return 'Адреса корисника $name';
  }

  @override
  String get profileExportChatHistory => 'Извези историју ћаскања';

  @override
  String profileSavedTo(String path) {
    return 'Сачувано у $path';
  }

  @override
  String get profileExportFailed => 'Извоз неуспешан';

  @override
  String get profileClearChatHistory => 'Обриши историју ћаскања';

  @override
  String get profileDeleteGroup => 'Обриши групу';

  @override
  String get profileDeleteContact => 'Обриши контакт';

  @override
  String get profileLeaveGroup => 'Напусти групу';

  @override
  String get profileLeaveGroupBody =>
      'Бићете уклоњени из ове групе и она ће бити обрисана из ваших контаката.';

  @override
  String get groupInviteTitle => 'Позивница за групу';

  @override
  String groupInviteBody(String from, String group) {
    return '$from вас позива да се придружите групи \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Прихвати';

  @override
  String get groupInviteDecline => 'Одбиј';

  @override
  String get groupMemberLimitTitle => 'Превише учесника';

  @override
  String groupMemberLimitBody(int count) {
    return 'Ова група ће имати $count учесника. Шифровани мрежни позиви подржавају до 6. Веће групе прелазе на Jitsi (без E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Додај свеједно';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name је одбио/ла да се придружи групи \"$group\"';
  }

  @override
  String get transferTitle => 'Пренос на други уређај';

  @override
  String get transferInfoBox =>
      'Преместите свој Signal идентитет и Nostr кључеве на нови уређај.\nСесије ћаскања се НЕ преносе — тајност унапред је очувана.';

  @override
  String get transferSendFromThis => 'Пошаљи са овог уређаја';

  @override
  String get transferSendSubtitle =>
      'Овај уређај има кључеве. Поделите код са новим уређајем.';

  @override
  String get transferReceiveOnThis => 'Прими на овом уређају';

  @override
  String get transferReceiveSubtitle =>
      'Ово је нови уређај. Унесите код са старог уређаја.';

  @override
  String get transferChooseMethod => 'Изаберите начин преноса';

  @override
  String get transferLan => 'LAN (иста мрежа)';

  @override
  String get transferLanSubtitle =>
      'Брзо, директно. Оба уређаја морају бити на истом Wi-Fi-ју.';

  @override
  String get transferNostrRelay => 'Nostr релеј';

  @override
  String get transferNostrRelaySubtitle =>
      'Ради преко било које мреже користећи постојећи Nostr релеј.';

  @override
  String get transferRelayUrl => 'URL релеја';

  @override
  String get transferEnterCode => 'Унесите код за пренос';

  @override
  String get transferPasteCode => 'Налепите LAN:... или NOS:... код овде';

  @override
  String get transferConnect => 'Повежи';

  @override
  String get transferGenerating => 'Генерисање кода за пренос…';

  @override
  String get transferShareCode => 'Поделите овај код са примаоцем:';

  @override
  String get transferCopyCode => 'Копирај код';

  @override
  String get transferCodeCopied => 'Код копиран у клипборд';

  @override
  String get transferWaitingReceiver => 'Чекање на повезивање примаоца…';

  @override
  String get transferConnectingSender => 'Повезивање са пошиљаоцем…';

  @override
  String get transferVerifyBoth =>
      'Упоредите овај код на оба уређаја.\nАко се подударају, пренос је безбедан.';

  @override
  String get transferComplete => 'Пренос завршен';

  @override
  String get transferKeysImported => 'Кључеви увезени';

  @override
  String get transferCompleteSenderBody =>
      'Ваши кључеви остају активни на овом уређају.\nПрималац сада може користити ваш идентитет.';

  @override
  String get transferCompleteReceiverBody =>
      'Кључеви су успешно увезени.\nПоново покрените апликацију да примените нови идентитет.';

  @override
  String get transferRestartApp => 'Поново покрени';

  @override
  String get transferFailed => 'Пренос неуспешан';

  @override
  String get transferTryAgain => 'Покушај поново';

  @override
  String get transferEnterRelayFirst => 'Прво унесите URL релеја';

  @override
  String get transferPasteCodeFromSender =>
      'Налепите код за пренос од пошиљаоца';

  @override
  String get menuReply => 'Одговори';

  @override
  String get menuForward => 'Проследи';

  @override
  String get menuReact => 'Реагуј';

  @override
  String get menuCopy => 'Копирај';

  @override
  String get menuEdit => 'Измени';

  @override
  String get menuRetry => 'Покушај поново';

  @override
  String get menuCancelScheduled => 'Откажи заказано';

  @override
  String get menuDelete => 'Обриши';

  @override
  String get menuForwardTo => 'Проследи у…';

  @override
  String menuForwardedTo(String name) {
    return 'Прослеђено кориснику $name';
  }

  @override
  String get menuScheduledMessages => 'Заказане поруке';

  @override
  String get menuNoScheduledMessages => 'Нема заказаних порука';

  @override
  String menuSendsOn(String date) {
    return 'Шаље се $date';
  }

  @override
  String get menuDisappearingMessages => 'Нестајуће поруке';

  @override
  String get menuDisappearingSubtitle =>
      'Поруке се аутоматски бришу после изабраног времена.';

  @override
  String get menuTtlOff => 'Искључено';

  @override
  String get menuTtl1h => '1 сат';

  @override
  String get menuTtl24h => '24 сата';

  @override
  String get menuTtl7d => '7 дана';

  @override
  String get menuAttachPhoto => 'Фотографија';

  @override
  String get menuAttachFile => 'Фајл';

  @override
  String get menuAttachVideo => 'Видео';

  @override
  String get mediaTitle => 'Медији';

  @override
  String get mediaFileLabel => 'ФАЈЛ';

  @override
  String mediaPhotosTab(int count) {
    return 'Фотографије ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Фајлови ($count)';
  }

  @override
  String get mediaNoPhotos => 'Још нема фотографија';

  @override
  String get mediaNoFiles => 'Још нема фајлова';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Сачувано у Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'Чување фајла неуспешно';

  @override
  String get statusNewStatus => 'Нови статус';

  @override
  String get statusPublish => 'Објави';

  @override
  String get statusExpiresIn24h => 'Статус истиче за 24 сата';

  @override
  String get statusWhatsOnYourMind => 'Шта вам је на уму?';

  @override
  String get statusPhotoAttached => 'Фотографија приложена';

  @override
  String get statusAttachPhoto => 'Приложи фотографију (опционо)';

  @override
  String get statusEnterText => 'Молимо унесите текст за свој статус.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Избор фотографије неуспешан: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Објава неуспешна: $error';
  }

  @override
  String get panicSetPanicKey => 'Постави панични кључ';

  @override
  String get panicEmergencySelfDestruct => 'Хитно самоуништење';

  @override
  String get panicIrreversible => 'Ова радња је неповратна';

  @override
  String get panicWarningBody =>
      'Унос овог кључа на закључаном екрану тренутно брише СВЕ податке — поруке, контакте, кључеве, идентитет. Користите кључ различит од ваше редовне лозинке.';

  @override
  String get panicKeyHint => 'Панични кључ';

  @override
  String get panicConfirmHint => 'Потврди панични кључ';

  @override
  String get panicMinChars => 'Панични кључ мора имати најмање 8 знакова';

  @override
  String get panicKeysDoNotMatch => 'Кључеви се не подударају';

  @override
  String get panicSetFailed =>
      'Чување паничног кључа неуспешно — покушајте поново';

  @override
  String get passwordSetAppPassword => 'Постави лозинку апликације';

  @override
  String get passwordProtectsMessages => 'Штити ваше поруке у мировању';

  @override
  String get passwordInfoBanner =>
      'Потребна при сваком отварању Pulse. Ако заборавите, подаци не могу бити повраћени.';

  @override
  String get passwordHint => 'Лозинка';

  @override
  String get passwordConfirmHint => 'Потврди лозинку';

  @override
  String get passwordSetButton => 'Постави лозинку';

  @override
  String get passwordSkipForNow => 'Прескочи за сад';

  @override
  String get passwordMinChars => 'Лозинка мора имати најмање 6 знакова';

  @override
  String get passwordsDoNotMatch => 'Лозинке се не подударају';

  @override
  String get profileCardSaved => 'Профил сачуван!';

  @override
  String get profileCardE2eeIdentity => 'E2EE идентитет';

  @override
  String get profileCardDisplayName => 'Име за приказ';

  @override
  String get profileCardDisplayNameHint => 'нпр. Иван Иванов';

  @override
  String get profileCardAbout => 'О мени';

  @override
  String get profileCardSaveProfile => 'Сачувај профил';

  @override
  String get profileCardYourName => 'Ваше име';

  @override
  String get profileCardAddressCopied => 'Адреса копирана!';

  @override
  String get profileCardInboxAddress => 'Ваша адреса пријемног сандучета';

  @override
  String get profileCardInboxAddresses => 'Ваше адресе пријемног сандучета';

  @override
  String get profileCardShareAllAddresses => 'Подели све адресе (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Поделите са контактима да би вам могли слати поруке.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Свих $count адреса копирано као један линк!';
  }

  @override
  String get settingsMyProfile => 'Мој профил';

  @override
  String get settingsYourInboxAddress => 'Ваша адреса пријемног сандучета';

  @override
  String get settingsMyQrCode => 'Мој QR код';

  @override
  String get settingsMyQrSubtitle => 'Поделите адресу као QR код за скенирање';

  @override
  String get settingsShareMyAddress => 'Подели моју адресу';

  @override
  String get settingsNoAddressYet =>
      'Још нема адресе — прво сачувајте подешавања';

  @override
  String get settingsInviteLink => 'Линк за позивницу';

  @override
  String get settingsRawAddress => 'Необрађена адреса';

  @override
  String get settingsCopyLink => 'Копирај линк';

  @override
  String get settingsCopyAddress => 'Копирај адресу';

  @override
  String get settingsInviteLinkCopied => 'Линк за позивницу копиран';

  @override
  String get settingsAppearance => 'Изглед';

  @override
  String get settingsThemeEngine => 'Мотор теме';

  @override
  String get settingsThemeEngineSubtitle => 'Прилагоди боје и фонтове';

  @override
  String get settingsSignalProtocol => 'Signal протокол';

  @override
  String get settingsSignalProtocolSubtitle =>
      'E2EE кључеви безбедно ускладиштени';

  @override
  String get settingsActive => 'АКТИВНО';

  @override
  String get settingsIdentityBackup => 'Резервна копија идентитета';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Извезите или увезите свој Signal идентитет';

  @override
  String get settingsIdentityBackupBody =>
      'Извезите своје Signal кључеве идентитета у резервни код, или повратите из постојећег.';

  @override
  String get settingsTransferDevice => 'Пренос на други уређај';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Преместите идентитет преко LAN-а или Nostr релеја';

  @override
  String get settingsExportIdentity => 'Извези идентитет';

  @override
  String get settingsExportIdentityBody =>
      'Копирајте овај резервни код и безбедно га ускладиштите:';

  @override
  String get settingsSaveFile => 'Сачувај фајл';

  @override
  String get settingsImportIdentity => 'Увези идентитет';

  @override
  String get settingsImportIdentityBody =>
      'Налепите резервни код испод. Ово ће преписати ваш тренутни идентитет.';

  @override
  String get settingsPasteBackupCode => 'Налепите резервни код овде…';

  @override
  String get settingsIdentityImported =>
      'Идентитет + контакти увезени! Поново покрените апликацију.';

  @override
  String get settingsSecurity => 'Безбедност';

  @override
  String get settingsAppPassword => 'Лозинка апликације';

  @override
  String get settingsPasswordEnabled =>
      'Укључено — потребно при сваком покретању';

  @override
  String get settingsPasswordDisabled =>
      'Искључено — апликација се отвара без лозинке';

  @override
  String get settingsChangePassword => 'Промени лозинку';

  @override
  String get settingsChangePasswordSubtitle =>
      'Ажурирајте лозинку за закључавање апликације';

  @override
  String get settingsSetPanicKey => 'Постави панични кључ';

  @override
  String get settingsChangePanicKey => 'Промени панични кључ';

  @override
  String get settingsPanicKeySetSubtitle => 'Ажурирајте кључ за хитно брисање';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Један кључ који тренутно брише све податке';

  @override
  String get settingsRemovePanicKey => 'Уклони панични кључ';

  @override
  String get settingsRemovePanicKeySubtitle => 'Онемогући хитно самоуништење';

  @override
  String get settingsRemovePanicKeyBody =>
      'Хитно самоуништење ће бити онемогућено. Можете га поново укључити у било ком тренутку.';

  @override
  String get settingsDisableAppPassword => 'Онемогући лозинку апликације';

  @override
  String get settingsEnterCurrentPassword =>
      'Унесите тренутну лозинку за потврду';

  @override
  String get settingsCurrentPassword => 'Тренутна лозинка';

  @override
  String get settingsIncorrectPassword => 'Погрешна лозинка';

  @override
  String get settingsPasswordUpdated => 'Лозинка ажурирана';

  @override
  String get settingsChangePasswordProceed =>
      'Унесите тренутну лозинку за наставак';

  @override
  String get settingsData => 'Подаци';

  @override
  String get settingsBackupMessages => 'Резервна копија порука';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Извезите шифровану историју порука у фајл';

  @override
  String get settingsRestoreMessages => 'Поврати поруке';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Увезите поруке из резервне копије';

  @override
  String get settingsExportKeys => 'Извези кључеве';

  @override
  String get settingsExportKeysSubtitle =>
      'Сачувајте кључеве идентитета у шифрован фајл';

  @override
  String get settingsImportKeys => 'Увези кључеве';

  @override
  String get settingsImportKeysSubtitle =>
      'Повратите кључеве идентитета из извезеног фајла';

  @override
  String get settingsBackupPassword => 'Лозинка за резервну копију';

  @override
  String get settingsPasswordCannotBeEmpty => 'Лозинка не може бити празна';

  @override
  String get settingsPasswordMin4Chars => 'Лозинка мора имати најмање 4 знака';

  @override
  String get settingsCallsTurn => 'Позиви и TURN';

  @override
  String get settingsLocalNetwork => 'Локална мрежа';

  @override
  String get settingsCensorshipResistance => 'Отпорност на цензуру';

  @override
  String get settingsNetwork => 'Мрежа';

  @override
  String get settingsProxyTunnels => 'Прокси и тунели';

  @override
  String get settingsTurnServers => 'TURN сервери';

  @override
  String get settingsProviderTitle => 'Провајдер';

  @override
  String get settingsLanFallback => 'LAN резерва';

  @override
  String get settingsLanFallbackSubtitle =>
      'Емитујте присуство и достављајте поруке на локалној мрежи кад интернет није доступан. Онемогућите на непоузданим мрежама (јавни Wi-Fi).';

  @override
  String get settingsBgDelivery => 'Достава у позадини';

  @override
  String get settingsBgDeliverySubtitle =>
      'Наставите да примате поруке кад је апликација минимизована. Приказује стално обавештење.';

  @override
  String get settingsYourInboxProvider => 'Ваш провајдер пријемног сандучета';

  @override
  String get settingsConnectionDetails => 'Детаљи конекције';

  @override
  String get settingsSaveAndConnect => 'Сачувај и повежи';

  @override
  String get settingsSecondaryInboxes => 'Секундарна пријемна сандучад';

  @override
  String get settingsAddSecondaryInbox => 'Додај секундарно сандуче';

  @override
  String get settingsAdvanced => 'Напредно';

  @override
  String get settingsDiscover => 'Откриј';

  @override
  String get settingsAbout => 'О апликацији';

  @override
  String get settingsPrivacyPolicy => 'Политика приватности';

  @override
  String get settingsPrivacyPolicySubtitle => 'Како Pulse штити ваше податке';

  @override
  String get settingsCrashReporting => 'Пријава грешака';

  @override
  String get settingsCrashReportingSubtitle =>
      'Шаљите анонимне извештаје о грешкама да побољшате Pulse. Садржај порука и контакти се никад не шаљу.';

  @override
  String get settingsCrashReportingEnabled =>
      'Пријава грешака укључена — поново покрените апликацију';

  @override
  String get settingsCrashReportingDisabled =>
      'Пријава грешака искључена — поново покрените апликацију';

  @override
  String get settingsSensitiveOperation => 'Осетљива операција';

  @override
  String get settingsSensitiveOperationBody =>
      'Ови кључеви су ваш идентитет. Свако ко има овај фајл може да вас имитира. Безбедно га ускладиштите и обришите после преноса.';

  @override
  String get settingsIUnderstandContinue => 'Разумем, настави';

  @override
  String get settingsReplaceIdentity => 'Заменити идентитет?';

  @override
  String get settingsReplaceIdentityBody =>
      'Ово ће преписати ваше тренутне кључеве идентитета. Постојеће Signal сесије ће бити поништене и контакти ће морати поново успоставити шифровање. Апликација мора бити поново покренута.';

  @override
  String get settingsReplaceKeys => 'Замени кључеве';

  @override
  String get settingsKeysImported => 'Кључеви увезени';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count кључева успешно увезено. Поново покрените апликацију за иницијализацију са новим идентитетом.';
  }

  @override
  String get settingsRestartNow => 'Поново покрени';

  @override
  String get settingsLater => 'Касније';

  @override
  String get profileGroupLabel => 'Група';

  @override
  String get profileAddButton => 'Додај';

  @override
  String get profileKickButton => 'Избаци';

  @override
  String get dataSectionTitle => 'Подаци';

  @override
  String get dataBackupMessages => 'Резервна копија порука';

  @override
  String get dataBackupPasswordSubtitle =>
      'Изаберите лозинку за шифровање резервне копије порука.';

  @override
  String get dataBackupConfirmLabel => 'Направи резервну копију';

  @override
  String get dataCreatingBackup => 'Прављење резервне копије';

  @override
  String get dataBackupPreparing => 'Припрема...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Извоз поруке $done од $total...';
  }

  @override
  String get dataBackupSavingFile => 'Чување фајла...';

  @override
  String get dataSaveMessageBackupDialog => 'Сачувај резервну копију порука';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Резервна копија сачувана ($count порука)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Резервна копија неуспешна — нема извезених података';

  @override
  String dataBackupFailedError(String error) {
    return 'Резервна копија неуспешна: $error';
  }

  @override
  String get dataSelectMessageBackupDialog =>
      'Изаберите резервну копију порука';

  @override
  String get dataInvalidBackupFile => 'Неважећи фајл резервне копије (премали)';

  @override
  String get dataNotValidBackupFile => 'Није важећи Pulse фајл резервне копије';

  @override
  String get dataRestoreMessages => 'Поврати поруке';

  @override
  String get dataRestorePasswordSubtitle =>
      'Унесите лозинку коришћену за прављење ове резервне копије.';

  @override
  String get dataRestoreConfirmLabel => 'Поврати';

  @override
  String get dataRestoringMessages => 'Повраћај порука';

  @override
  String get dataRestoreDecrypting => 'Дешифровање...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Увоз поруке $done од $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Повраћај неуспешан — погрешна лозинка или оштећен фајл';

  @override
  String dataRestoreSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Повраћено $count нових порука',
      few: 'Повраћене $count нове поруке',
      one: 'Повраћена $count нова порука',
    );
    return '$_temp0';
  }

  @override
  String get dataRestoreNothingNew =>
      'Нема нових порука за увоз (све већ постоје)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Повраћај неуспешан: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Изаберите извезене кључеве';

  @override
  String get dataNotValidKeyFile => 'Није важећи Pulse фајл извезених кључева';

  @override
  String get dataExportKeys => 'Извези кључеве';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Изаберите лозинку за шифровање извоза кључева.';

  @override
  String get dataExportKeysConfirmLabel => 'Извези';

  @override
  String get dataExportingKeys => 'Извоз кључева';

  @override
  String get dataExportingKeysStatus => 'Шифровање кључева идентитета...';

  @override
  String get dataSaveKeyExportDialog => 'Сачувај извезене кључеве';

  @override
  String dataKeysExportedTo(String path) {
    return 'Кључеви извезени у:\n$path';
  }

  @override
  String get dataExportFailed => 'Извоз неуспешан — кључеви нису пронађени';

  @override
  String dataExportFailedError(String error) {
    return 'Извоз неуспешан: $error';
  }

  @override
  String get dataImportKeys => 'Увези кључеве';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Унесите лозинку коришћену за шифровање овог извоза кључева.';

  @override
  String get dataImportKeysConfirmLabel => 'Увези';

  @override
  String get dataImportingKeys => 'Увоз кључева';

  @override
  String get dataImportingKeysStatus => 'Дешифровање кључева идентитета...';

  @override
  String get dataImportFailed =>
      'Увоз неуспешан — погрешна лозинка или оштећен фајл';

  @override
  String dataImportFailedError(String error) {
    return 'Увоз неуспешан: $error';
  }

  @override
  String get securitySectionTitle => 'Безбедност';

  @override
  String get securityIncorrectPassword => 'Погрешна лозинка';

  @override
  String get securityPasswordUpdated => 'Лозинка ажурирана';

  @override
  String get appearanceSectionTitle => 'Изглед';

  @override
  String appearanceExportFailed(String error) {
    return 'Извоз неуспешан: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Сачувано у $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Чување неуспешно: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Увоз неуспешан: $error';
  }

  @override
  String get aboutSectionTitle => 'О апликацији';

  @override
  String get providerPublicKey => 'Јавни кључ';

  @override
  String get providerRelay => 'Релеј';

  @override
  String get providerAutoConfigured =>
      'Аутоматски подешено из ваше лозинке за опоравак. Релеј аутоматски откривен.';

  @override
  String get providerKeyStoredLocally =>
      'Ваш кључ је ускладиштен локално у безбедном складишту — никад се не шаље серверу.';

  @override
  String get providerOxenInfo =>
      'Oxen/Session мрежа — E2EE рутирано кроз луковичасту мрежу. Ваш Session ID је аутоматски генерисан и безбедно ускладиштен. Чворови аутоматски откривени од уграђених сид чворова.';

  @override
  String get providerAdvanced => 'Напредно';

  @override
  String get providerSaveAndConnect => 'Сачувај и повежи';

  @override
  String get providerAddSecondaryInbox => 'Додај секундарно сандуче';

  @override
  String get providerSecondaryInboxes => 'Секундарна сандучад';

  @override
  String get providerYourInboxProvider => 'Ваш провајдер пријемног сандучета';

  @override
  String get providerConnectionDetails => 'Детаљи конекције';

  @override
  String get addContactTitle => 'Додај контакт';

  @override
  String get addContactInviteLinkLabel => 'Линк за позивницу или адреса';

  @override
  String get addContactTapToPaste => 'Додирните да налепите линк за позивницу';

  @override
  String get addContactPasteTooltip => 'Налепи из клипборда';

  @override
  String get addContactAddressDetected => 'Адреса контакта откривена';

  @override
  String addContactRoutesDetected(int count) {
    return '$count путања откривено — SmartRouter бира најбржу';
  }

  @override
  String get addContactFetchingProfile => 'Преузимање профила…';

  @override
  String addContactProfileFound(String name) {
    return 'Пронађено: $name';
  }

  @override
  String get addContactNoProfileFound => 'Профил није пронађен';

  @override
  String get addContactDisplayNameLabel => 'Име за приказ';

  @override
  String get addContactDisplayNameHint => 'Како желите да их зовете?';

  @override
  String get addContactAddManually => 'Додај адресу ручно';

  @override
  String get addContactButton => 'Додај контакт';

  @override
  String get networkDiagnosticsTitle => 'Мрежна дијагностика';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr релеји';

  @override
  String get networkDiagnosticsDirect => 'Директно';

  @override
  String get networkDiagnosticsTorOnly => 'Само Tor';

  @override
  String get networkDiagnosticsBest => 'Најбољи';

  @override
  String get networkDiagnosticsNone => 'ниједан';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Статус';

  @override
  String get networkDiagnosticsConnected => 'Повезано';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Повезивање $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Искључено';

  @override
  String get networkDiagnosticsTransport => 'Транспорт';

  @override
  String get networkDiagnosticsInfrastructure => 'Инфраструктура';

  @override
  String get networkDiagnosticsOxenNodes => 'Oxen чворови';

  @override
  String get networkDiagnosticsTurnServers => 'TURN сервери';

  @override
  String get networkDiagnosticsLastProbe => 'Последња провера';

  @override
  String get networkDiagnosticsRunning => 'Извршавање...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Покрени дијагностику';

  @override
  String get networkDiagnosticsForceReprobe => 'Принудна потпуна провера';

  @override
  String get networkDiagnosticsJustNow => 'управо сад';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'пре $minutes мин';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'пре $hours сата';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'пре $days дана';
  }

  @override
  String get homeNoEch => 'Без ECH';

  @override
  String get homeNoEchTooltip =>
      'uTLS прокси недоступан — ECH онемогућен.\nTLS отисак је видљив за DPI.';

  @override
  String get settingsTitle => 'Подешавања';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Сачувано и повезано на $provider';
  }

  @override
  String get settingsTorFailedToStart =>
      'Уграђени Tor није успео да се покрене';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon није успео да се покрене';

  @override
  String get verifyTitle => 'Верификуј безбедносни број';

  @override
  String get verifyIdentityVerified => 'Идентитет верификован';

  @override
  String get verifyNotYetVerified => 'Још није верификовано';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Верификовали сте безбедносни број корисника $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Упоредите ове бројеве са $name лично или преко поузданог канала.';
  }

  @override
  String get verifyExplanation =>
      'Сваки разговор има јединствени безбедносни број. Ако обоје видите исте бројеве на својим уређајима, ваша веза је верификована од краја до краја.';

  @override
  String verifyContactKey(String name) {
    return 'Кључ корисника $name';
  }

  @override
  String get verifyYourKey => 'Ваш кључ';

  @override
  String get verifyRemoveVerification => 'Уклони верификацију';

  @override
  String get verifyMarkAsVerified => 'Означи као верификовано';

  @override
  String verifyAfterReinstall(String name) {
    return 'Ако $name поново инсталира апликацију, безбедносни број ће се променити и верификација ће бити аутоматски уклоњена.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Означите као верификовано тек након упоређивања бројева са $name преко гласовног позива или лично.';
  }

  @override
  String get verifyNoSession =>
      'Сесија шифровања још није успостављена. Прво пошаљите поруку да генеришете безбедносне бројеве.';

  @override
  String get verifyNoKeyAvailable => 'Кључ није доступан';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Отисак $label копиран';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL базе података';

  @override
  String get providerOptionalHint => 'Опционо';

  @override
  String get providerWebApiKeyLabel => 'Web API кључ';

  @override
  String get providerOptionalForPublicDb => 'Опционо за јавну базу';

  @override
  String get providerRelayUrlLabel => 'URL релеја';

  @override
  String get providerPrivateKeyLabel => 'Приватни кључ';

  @override
  String get providerPrivateKeyNsecLabel => 'Приватни кључ (nsec)';

  @override
  String get providerStorageNodeLabel => 'URL чвора за складиштење (опционо)';

  @override
  String get providerStorageNodeHint =>
      'Оставите празно за уграђене сид чворове';

  @override
  String get transferInvalidCodeFormat =>
      'Непознат формат кода — мора почети са LAN: или NOS:';

  @override
  String get profileCardFingerprintCopied => 'Отисак копиран';

  @override
  String get profileCardAboutHint => 'Приватност на првом месту 🔒';

  @override
  String get profileCardSaveButton => 'Сачувај профил';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Извезите шифроване поруке, контакте и аватаре у фајл';

  @override
  String get callVideo => 'Видео';

  @override
  String get callAudio => 'Аудио';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Достављено кориснику $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Достављено за $count';
  }

  @override
  String get groupStatusDialogTitle => 'Информације о поруци';

  @override
  String get groupStatusRead => 'Прочитано';

  @override
  String get groupStatusDelivered => 'Достављено';

  @override
  String get groupStatusPending => 'На чекању';

  @override
  String get groupStatusNoData => 'Још нема информација о достави';

  @override
  String get profileTransferAdmin => 'Постави за админа';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Поставити $name за новог админа?';
  }

  @override
  String get profileTransferAdminBody =>
      'Изгубићете админ привилегије. Ово се не може поништити.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name је сада админ';
  }

  @override
  String get profileAdminBadge => 'Админ';

  @override
  String get privacyPolicyTitle => 'Политика приватности';

  @override
  String get privacyOverviewHeading => 'Преглед';

  @override
  String get privacyOverviewBody =>
      'Pulse је месинџер без сервера, са шифровањем од краја до краја. Ваша приватност није само функција — она је архитектура. Не постоје Pulse сервери. Ниједан налог се нигде не чува. Програмери не прикупљају, не преносе и не складиште никакве податке.';

  @override
  String get privacyDataCollectionHeading => 'Прикупљање података';

  @override
  String get privacyDataCollectionBody =>
      'Pulse не прикупља никакве личне податке. Конкретно:\n\n- Не захтева се е-пошта, телефонски број или право име\n- Без аналитике, праћења или телеметрије\n- Без рекламних идентификатора\n- Без приступа листи контаката\n- Без резервних копија у облаку (поруке постоје само на вашем уређају)\n- Никакви метаподаци се не шаљу ни на један Pulse сервер (јер не постоје)';

  @override
  String get privacyEncryptionHeading => 'Шифровање';

  @override
  String get privacyEncryptionBody =>
      'Све поруке су шифроване Signal протоколом (Double Ratchet са X3DH договором о кључевима). Кључеви за шифровање се генеришу и чувају искључиво на вашем уређају. Нико — укључујући програмере — не може читати ваше поруке.';

  @override
  String get privacyNetworkHeading => 'Мрежна архитектура';

  @override
  String get privacyNetworkBody =>
      'Pulse користи федеративне транспортне адаптере (Nostr релеји, Session/Oxen сервисни чворови, Firebase Realtime Database, LAN). Ови транспорти преносе само шифровани текст. Оператори релеја могу видети вашу IP адресу и обим саобраћаја, али не могу дешифровати садржај порука.\n\nКада је Tor укључен, ваша IP адреса је такође скривена од оператора релеја.';

  @override
  String get privacyStunHeading => 'STUN/TURN сервери';

  @override
  String get privacyStunBody =>
      'Гласовни и видео позиви користе WebRTC са DTLS-SRTP шифровањем. STUN сервери (за откривање јавне IP адресе за директне P2P конекције) и TURN сервери (за преусмеравање медија кад директна конекција не успе) могу видети вашу IP адресу и трајање позива, али не могу дешифровати садржај позива.\n\nМожете подесити сопствени TURN сервер у Подешавањима за максималну приватност.';

  @override
  String get privacyCrashHeading => 'Пријава грешака';

  @override
  String get privacyCrashBody =>
      'Ако је Sentry пријава грешака укључена (путем SENTRY_DSN у време изградње), анонимни извештаји о грешкама могу бити послати. Они не садрже садржај порука, информације о контактима, нити лично препознатљиве информације. Пријава грешака може бити искључена у време изградње изостављањем DSN-а.';

  @override
  String get privacyPasswordHeading => 'Лозинка и кључеви';

  @override
  String get privacyPasswordBody =>
      'Ваша лозинка за опоравак се користи за извођење криптографских кључева путем Argon2id (меморијски захтевна KDF функција). Лозинка се никад не преноси нигде. Ако изгубите лозинку, ваш налог не може бити повраћен — не постоји сервер за ресетовање.';

  @override
  String get privacyFontsHeading => 'Фонтови';

  @override
  String get privacyFontsBody =>
      'Pulse садржи све фонтове локално. Не шаљу се захтеви ка Google Fonts или било ком спољном сервису за фонтове.';

  @override
  String get privacyThirdPartyHeading => 'Услуге трећих страна';

  @override
  String get privacyThirdPartyBody =>
      'Pulse се не интегрише ни са једном рекламном мрежом, провајдером аналитике, платформом друштвених медија или посредником података. Једине мрежне конекције су ка транспортним релејима које подесите.';

  @override
  String get privacyOpenSourceHeading => 'Отворени код';

  @override
  String get privacyOpenSourceBody =>
      'Pulse је софтвер отвореног кода. Можете ревидирати комплетан изворни код да верификујете ове тврдње о приватности.';

  @override
  String get privacyContactHeading => 'Контакт';

  @override
  String get privacyContactBody =>
      'За питања везана за приватност, отворите тему на репозиторијуму пројекта.';

  @override
  String get privacyLastUpdated => 'Последње ажурирање: март 2026.';

  @override
  String imageSaveFailed(Object error) {
    return 'Чување неуспешно: $error';
  }

  @override
  String get themeEngineTitle => 'Мотор теме';

  @override
  String get torBuiltInTitle => 'Уграђени Tor';

  @override
  String get torConnectedSubtitle =>
      'Повезано — Nostr рутиран преко 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Повезивање… $pct%';
  }

  @override
  String get torNotRunning => 'Не ради — додирните прекидач за рестарт';

  @override
  String get torDescription =>
      'Рутира Nostr преко Tor-а (Snowflake за цензурисане мреже)';

  @override
  String get torNetworkDiagnostics => 'Мрежна дијагностика';

  @override
  String get torTransportLabel => 'Транспорт: ';

  @override
  String get torPtAuto => 'Аутоматски';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Обични';

  @override
  String get torTimeoutLabel => 'Временско ограничење: ';

  @override
  String get torInfoDescription =>
      'Када је укључено, Nostr WebSocket конекције се рутирају кроз Tor (SOCKS5). Tor Browser слуша на 127.0.0.1:9150. Самостални tor демон користи порт 9050. Firebase конекције нису погођене.';

  @override
  String get torRouteNostrTitle => 'Рутирај Nostr преко Tor-а';

  @override
  String get torManagedByBuiltin => 'Управља уграђени Tor';

  @override
  String get torActiveRouting => 'Активно — Nostr саобраћај рутиран кроз Tor';

  @override
  String get torDisabled => 'Онемогућено';

  @override
  String get torProxySocks5 => 'Tor прокси (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Хост проксија';

  @override
  String get torProxyPortLabel => 'Порт';

  @override
  String get torPortInfo => 'Tor Browser: порт 9150  •  tor демон: порт 9050';

  @override
  String get i2pProxySocks5 => 'I2P прокси (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P подразумевано користи SOCKS5 на порту 4447. Повежите се на Nostr релеј преко I2P излазног проксија (нпр. relay.damus.i2p) за комуникацију са корисницима на било ком транспорту. Tor има приоритет када су оба укључена.';

  @override
  String get i2pRouteNostrTitle => 'Рутирај Nostr преко I2P';

  @override
  String get i2pActiveRouting => 'Активно — Nostr саобраћај рутиран кроз I2P';

  @override
  String get i2pDisabled => 'Онемогућено';

  @override
  String get i2pProxyHostLabel => 'Хост проксија';

  @override
  String get i2pProxyPortLabel => 'Порт';

  @override
  String get i2pPortInfo => 'I2P рутер подразумевани SOCKS5 порт: 4447';

  @override
  String get customProxySocks5 => 'Прилагођени прокси (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker релеј';

  @override
  String get customProxyInfoDescription =>
      'Прилагођени прокси рутира саобраћај кроз ваш V2Ray/Xray/Shadowsocks. CF Worker делује као лични релеј прокси на Cloudflare CDN — GFW види *.workers.dev, а не прави релеј.';

  @override
  String get customSocks5ProxyTitle => 'Прилагођени SOCKS5 прокси';

  @override
  String get customProxyActive => 'Активно — саобраћај рутиран преко SOCKS5';

  @override
  String get customProxyDisabled => 'Онемогућено';

  @override
  String get customProxyHostLabel => 'Хост проксија';

  @override
  String get customProxyPortLabel => 'Порт';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Домен Worker-а (опционо)';

  @override
  String get customWorkerHelpTitle =>
      'Како поставити CF Worker релеј (бесплатно)';

  @override
  String get customWorkerScriptCopied => 'Скрипта копирана!';

  @override
  String get customWorkerStep1 =>
      '1. Идите на dash.cloudflare.com → Workers & Pages\n2. Create Worker → налепите ову скрипту:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → копирајте домен (нпр. my-relay.user.workers.dev)\n4. Налепите домен изнад → Сачувај\n\nАпликација се аутоматски повезује: wss://domain/?r=relay_url\nGFW види: конекцију ка *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Повезано — SOCKS5 на 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Повезивање…';

  @override
  String get psiphonNotRunning => 'Не ради — додирните прекидач за рестарт';

  @override
  String get psiphonDescription =>
      'Брз тунел (~3с покретање, 2000+ ротирајућих VPS)';

  @override
  String get turnCommunityServers => 'TURN сервери заједнице';

  @override
  String get turnCustomServer => 'Прилагођени TURN сервер (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN сервери само преусмеравају већ шифроване токове (DTLS-SRTP). Оператор релеја види вашу IP адресу и обим саобраћаја, али не може дешифровати позиве. TURN се користи само када директни P2P не успе (~15–20% конекција).';

  @override
  String get turnFreeLabel => 'БЕСПЛАТНО';

  @override
  String get turnServerUrlLabel => 'URL TURN сервера';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 или turns:...';

  @override
  String get turnUsernameLabel => 'Корисничко име';

  @override
  String get turnPasswordLabel => 'Лозинка';

  @override
  String get turnOptionalHint => 'Опционо';

  @override
  String get turnCustomInfo =>
      'Хостујте coturn на било ком VPS за \$5/мес за максималну контролу. Акредитиви се чувају локално.';

  @override
  String get themePickerAppearance => 'Изглед';

  @override
  String get themePickerAccentColor => 'Боја нагласка';

  @override
  String get themeModeLight => 'Светла';

  @override
  String get themeModeDark => 'Тамна';

  @override
  String get themeModeSystem => 'Системска';

  @override
  String get themeDynamicPresets => 'Предефинисано';

  @override
  String get themeDynamicPrimaryColor => 'Примарна боја';

  @override
  String get themeDynamicBorderRadius => 'Радијус ивица';

  @override
  String get themeDynamicFont => 'Фонт';

  @override
  String get themeDynamicAppearance => 'Изглед';

  @override
  String get themeDynamicUiStyle => 'UI стил';

  @override
  String get themeDynamicUiStyleDescription =>
      'Контролише како дијалози, прекидачи и индикатори изгледају.';

  @override
  String get themeDynamicSharp => 'Оштро';

  @override
  String get themeDynamicRound => 'Заобљено';

  @override
  String get themeDynamicModeDark => 'Тамна';

  @override
  String get themeDynamicModeLight => 'Светла';

  @override
  String get themeDynamicModeAuto => 'Аутоматски';

  @override
  String get themeDynamicPlatformAuto => 'Аутоматски';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'Неважећи Firebase URL. Очекивано: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Неважећи URL релеја. Очекивано: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Неважећи URL Pulse сервера. Очекивано: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'URL сервера';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'Код за позивницу';

  @override
  String get providerPulseInviteHint => 'Код за позивницу (ако је потребан)';

  @override
  String get providerPulseInfo =>
      'Самохостовани релеј. Кључеви изведени из ваше лозинке за опоравак.';

  @override
  String get providerScreenTitle => 'Пријемна сандучад';

  @override
  String get providerSecondaryInboxesHeader => 'СЕКУНДАРНА ПРИЈЕМНА САНДУЧАД';

  @override
  String get providerSecondaryInboxesInfo =>
      'Секундарна сандучад истовремено примају поруке ради редундантности.';

  @override
  String get providerRemoveTooltip => 'Уклони';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... или hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... или hex приватни кључ';

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
  String get emojiNoRecent => 'Нема скорашњих емоџија';

  @override
  String get emojiSearchHint => 'Претражи емоџије...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Додирните за ћаскање';

  @override
  String get imageViewerSaveToDownloads => 'Сачувај у Downloads';

  @override
  String imageViewerSavedTo(String path) {
    return 'Сачувано у $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Језик';

  @override
  String get settingsLanguageSubtitle => 'Језик приказа апликације';

  @override
  String get settingsLanguageSystem => 'Подразумевани системски';

  @override
  String get onboardingLanguageTitle => 'Изаберите свој језик';

  @override
  String get onboardingLanguageSubtitle =>
      'Можете ово променити касније у Подешавањима';
}
