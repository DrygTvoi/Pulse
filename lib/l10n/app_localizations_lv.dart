// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Latvian (`lv`).
class AppLocalizationsLv extends AppLocalizations {
  AppLocalizationsLv([String locale = 'lv']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Meklēt ziņas...';

  @override
  String get search => 'Meklēt';

  @override
  String get clearSearch => 'Notīrīt meklēšanu';

  @override
  String get closeSearch => 'Aizvērt meklēšanu';

  @override
  String get moreOptions => 'Vairāk iespēju';

  @override
  String get back => 'Atpakaļ';

  @override
  String get cancel => 'Atcelt';

  @override
  String get close => 'Aizvērt';

  @override
  String get confirm => 'Apstiprināt';

  @override
  String get remove => 'Noņemt';

  @override
  String get save => 'Saglabāt';

  @override
  String get add => 'Pievienot';

  @override
  String get copy => 'Kopēt';

  @override
  String get skip => 'Izlaist';

  @override
  String get done => 'Gatavs';

  @override
  String get apply => 'Lietot';

  @override
  String get export => 'Eksportēt';

  @override
  String get import => 'Importēt';

  @override
  String get homeNewGroup => 'Jauna grupa';

  @override
  String get homeSettings => 'Iestatījumi';

  @override
  String get homeSearching => 'Meklē ziņas...';

  @override
  String get homeNoResults => 'Rezultāti nav atrasti';

  @override
  String get homeNoChatHistory => 'Sarunu vēstures vēl nav';

  @override
  String homeTransportSwitched(String address) {
    return 'Transports pārslēgts → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name zvana...';
  }

  @override
  String get homeAccept => 'Pieņemt';

  @override
  String get homeDecline => 'Noraidīt';

  @override
  String get homeLoadEarlier => 'Ielādēt vecākas ziņas';

  @override
  String get homeChats => 'Sarunas';

  @override
  String get homeSelectConversation => 'Izvēlieties sarunu';

  @override
  String get homeNoChatsYet => 'Sarunu vēl nav';

  @override
  String get homeAddContactToStart =>
      'Pievienojiet kontaktu, lai sāktu saraksti';

  @override
  String get homeNewChat => 'Jauna saruna';

  @override
  String get homeNewChatTooltip => 'Jauna saruna';

  @override
  String get homeIncomingCallTitle => 'Ienākošais zvans';

  @override
  String get homeIncomingGroupCallTitle => 'Ienākošais grupas zvans';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — ienākošais grupas zvans';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Nav sarunu, kas atbilst \"$query\"';
  }

  @override
  String get homeSectionChats => 'Sarunas';

  @override
  String get homeSectionMessages => 'Ziņas';

  @override
  String get homeDbEncryptionUnavailable =>
      'Datubāzes šifrēšana nav pieejama — instalējiet SQLCipher pilnai aizsardzībai';

  @override
  String get chatFileTooLargeGroup =>
      'Faili, kas lielāki par 512 KB, grupas sarunās netiek atbalstīti';

  @override
  String get chatLargeFile => 'Liels fails';

  @override
  String get chatCancel => 'Atcelt';

  @override
  String get chatSend => 'Sūtīt';

  @override
  String get chatFileTooLarge =>
      'Fails pārāk liels — maksimālais izmērs ir 100 MB';

  @override
  String get chatMicDenied => 'Mikrofona atļauja noraidīta';

  @override
  String get chatVoiceFailed =>
      'Neizdevās saglabāt balss ziņu — pārbaudiet pieejamo krātuvi';

  @override
  String get chatScheduleFuture => 'Ieplānotajam laikam jābūt nākotnē';

  @override
  String get chatToday => 'Šodien';

  @override
  String get chatYesterday => 'Vakar';

  @override
  String get chatEdited => 'rediģēts';

  @override
  String get chatYou => 'Jūs';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Šis fails ir $size MB. Lielu failu sūtīšana dažos tīklos var būt lēna. Turpināt?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return '$name drošības atslēga ir mainījusies. Pieskarieties, lai verificētu.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Neizdevās šifrēt ziņu $name — ziņa nav nosūtīta.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Drošības numurs mainījies kontaktam $name. Pieskarieties, lai verificētu.';
  }

  @override
  String get chatNoMessagesFound => 'Ziņas nav atrastas';

  @override
  String get chatMessagesE2ee => 'Ziņas ir pilnībā šifrētas';

  @override
  String get chatSayHello => 'Sveicināties';

  @override
  String get appBarOnline => 'tiešsaistē';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'raksta';

  @override
  String get appBarSearchMessages => 'Meklēt ziņas...';

  @override
  String get appBarMute => 'Izslēgt skaņu';

  @override
  String get appBarUnmute => 'Ieslēgt skaņu';

  @override
  String get appBarMedia => 'Multivide';

  @override
  String get appBarDisappearing => 'Pazūdošās ziņas';

  @override
  String get appBarDisappearingOn => 'Pazūdošās: ieslēgtas';

  @override
  String get appBarGroupSettings => 'Grupas iestatījumi';

  @override
  String get appBarSearchTooltip => 'Meklēt ziņas';

  @override
  String get appBarVoiceCall => 'Balss zvans';

  @override
  String get appBarVideoCall => 'Video zvans';

  @override
  String get inputMessage => 'Ziņa...';

  @override
  String get inputAttachFile => 'Pievienot failu';

  @override
  String get inputSendMessage => 'Sūtīt ziņu';

  @override
  String get inputRecordVoice => 'Ierakstīt balss ziņu';

  @override
  String get inputSendVoice => 'Sūtīt balss ziņu';

  @override
  String get inputCancelReply => 'Atcelt atbildi';

  @override
  String get inputCancelEdit => 'Atcelt rediģēšanu';

  @override
  String get inputCancelRecording => 'Atcelt ierakstīšanu';

  @override
  String get inputRecording => 'Ieraksta…';

  @override
  String get inputEditingMessage => 'Rediģē ziņu';

  @override
  String get inputPhoto => 'Foto';

  @override
  String get inputVoiceMessage => 'Balss ziņa';

  @override
  String get inputFile => 'Fails';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's ziņas',
      one: ' ziņa',
    );
    return '$count ieplānota$_temp0';
  }

  @override
  String get callInitializing => 'Inicializē zvanu…';

  @override
  String get callConnecting => 'Savienojas…';

  @override
  String get callConnectingRelay => 'Savienojas (relejs)…';

  @override
  String get callSwitchingRelay => 'Pārslēdzas uz releja režīmu…';

  @override
  String get callConnectionFailed => 'Savienojums neizdevās';

  @override
  String get callReconnecting => 'Atjauno savienojumu…';

  @override
  String get callEnded => 'Zvans beidzies';

  @override
  String get callLive => 'Tiešraide';

  @override
  String get callEnd => 'Beigt';

  @override
  String get callEndCall => 'Beigt zvanu';

  @override
  String get callMute => 'Izslēgt skaņu';

  @override
  String get callUnmute => 'Ieslēgt skaņu';

  @override
  String get callSpeaker => 'Skaļrunis';

  @override
  String get callCameraOn => 'Kamera ieslēgta';

  @override
  String get callCameraOff => 'Kamera izslēgta';

  @override
  String get callShareScreen => 'Kopīgot ekrānu';

  @override
  String get callStopShare => 'Pārtraukt kopīgošanu';

  @override
  String callTorBackup(String duration) {
    return 'Tor rezerve · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor rezerve aktīva — primārais ceļš nav pieejams';

  @override
  String get callDirectFailed =>
      'Tiešais savienojums neizdevās — pārslēdzas uz releja režīmu…';

  @override
  String get callTurnUnreachable =>
      'TURN serveri nav sasniedzami. Pievienojiet pielāgotu TURN serverī Iestatījumi → Papildu.';

  @override
  String get callRelayMode => 'Releja režīms aktīvs (ierobežots tīkls)';

  @override
  String get callStarting => 'Sāk zvanu…';

  @override
  String get callConnectingToGroup => 'Savienojas ar grupu…';

  @override
  String get callGroupOpenedInBrowser => 'Grupas zvans atvērts pārlūkā';

  @override
  String get callCouldNotOpenBrowser => 'Neizdevās atvērt pārlūku';

  @override
  String get callInviteLinkSent =>
      'Ielūguma saite nosūtīta visiem grupas dalībniekiem.';

  @override
  String get callOpenLinkManually =>
      'Atveriet saiti augstāk manuāli vai pieskarieties, lai mēģinātu vēlreiz.';

  @override
  String get callJitsiNotE2ee => 'Jitsi zvani NAV pilnībā šifrēti';

  @override
  String get callRetryOpenBrowser => 'Mēģināt atvērt pārlūku vēlreiz';

  @override
  String get callClose => 'Aizvērt';

  @override
  String get callCamOn => 'Kamera iesl.';

  @override
  String get callCamOff => 'Kamera izsl.';

  @override
  String get noConnection => 'Nav savienojuma — ziņas tiks ierindotas';

  @override
  String get connected => 'Savienots';

  @override
  String get connecting => 'Savienojas…';

  @override
  String get disconnected => 'Atvienots';

  @override
  String get offlineBanner =>
      'Nav savienojuma — ziņas tiks nosūtītas, kad atgriezīsieties tiešsaistē';

  @override
  String get lanModeBanner =>
      'LAN režīms — Nav interneta · Tikai lokālais tīkls';

  @override
  String get probeCheckingNetwork => 'Pārbauda tīkla savienojumu…';

  @override
  String get probeDiscoveringRelays =>
      'Atklāj relejus caur kopienas direktorijiem…';

  @override
  String get probeStartingTor => 'Startē Tor ielādei…';

  @override
  String get probeFindingRelaysTor => 'Meklē sasniedzamus relejus caur Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'i',
      one: 's',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'i',
      one: 's',
    );
    return 'Tīkls gatavs — $count relej$_temp0 atrast$_temp1';
  }

  @override
  String get probeNoRelaysFound =>
      'Nav atrasts neviens sasniedzams relejs — ziņas var kavēties';

  @override
  String get jitsiWarningTitle => 'Nav pilnībā šifrēts';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet zvani netiek šifrēti ar Pulse. Izmantojiet tikai nejutīgām sarunām.';

  @override
  String get jitsiConfirm => 'Pievienoties tik un tā';

  @override
  String get jitsiGroupWarningTitle => 'Nav pilnībā šifrēts';

  @override
  String get jitsiGroupWarningBody =>
      'Šajā zvanā ir pārāk daudz dalībnieku iebūvētajam šifrētajam tīklam.\n\nJūsu pārlūkā tiks atvērta Jitsi Meet saite. Jitsi NAV pilnībā šifrēts — serveris var redzēt jūsu zvanu.';

  @override
  String get jitsiContinueAnyway => 'Turpināt tik un tā';

  @override
  String get retry => 'Mēģināt vēlreiz';

  @override
  String get setupCreateAnonymousAccount => 'Izveidot anonīmu kontu';

  @override
  String get setupTapToChangeColor => 'Pieskarieties, lai mainītu krāsu';

  @override
  String get setupReqMinLength => 'Vismaz 16 rakstzīmes';

  @override
  String get setupReqVariety => '3 no 4: lielie, mazie burti, cipari, simboli';

  @override
  String get setupReqMatch => 'Paroles sakrīt';

  @override
  String get setupYourNickname => 'Jūsu segvārds';

  @override
  String get setupRecoveryPassword => 'Atjaunošanas parole (min. 16)';

  @override
  String get setupConfirmPassword => 'Apstiprināt paroli';

  @override
  String get setupMin16Chars => 'Vismaz 16 rakstzīmes';

  @override
  String get setupPasswordsDoNotMatch => 'Paroles nesakrīt';

  @override
  String get setupEntropyWeak => 'Vāja';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Spēcīga';

  @override
  String get setupEntropyWeakNeedsVariety =>
      'Vāja (nepieciešami 3 rakstzīmju veidi)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits biti)';
  }

  @override
  String get setupPasswordWarning =>
      'Šī parole ir vienīgais veids, kā atjaunot jūsu kontu. Nav servera — nav paroles atiestatīšanas. Atcerieties to vai pierakstiet.';

  @override
  String get setupCreateAccount => 'Izveidot kontu';

  @override
  String get setupAlreadyHaveAccount => 'Jau ir konts? ';

  @override
  String get setupRestore => 'Atjaunot →';

  @override
  String get restoreTitle => 'Atjaunot kontu';

  @override
  String get restoreInfoBanner =>
      'Ievadiet savu atjaunošanas paroli — jūsu adrese (Nostr + Session) tiks atjaunota automātiski. Kontakti un ziņas tika glabāti tikai lokāli.';

  @override
  String get restoreNewNickname => 'Jauns segvārds (var mainīt vēlāk)';

  @override
  String get restoreButton => 'Atjaunot kontu';

  @override
  String get lockTitle => 'Pulse ir bloķēts';

  @override
  String get lockSubtitle => 'Ievadiet paroli, lai turpinātu';

  @override
  String get lockPasswordHint => 'Parole';

  @override
  String get lockUnlock => 'Atbloķēt';

  @override
  String get lockPanicHint =>
      'Aizmirsāt paroli? Ievadiet panikas atslēgu, lai dzēstu visus datus.';

  @override
  String get lockTooManyAttempts => 'Pārāk daudz mēģinājumu. Dzēš visus datus…';

  @override
  String get lockWrongPassword => 'Nepareiza parole';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Nepareiza parole — $attempts/$max mēģinājumi';
  }

  @override
  String get onboardingSkip => 'Izlaist';

  @override
  String get onboardingNext => 'Tālāk';

  @override
  String get onboardingGetStarted => 'Sākt';

  @override
  String get onboardingWelcomeTitle => 'Laipni lūgti Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Decentralizēts, pilnībā šifrēts ziņapmaiņas lietotne.\n\nNav centrālo serveru. Nav datu vākšanas. Nav aizmugures durvju.\nJūsu sarunas pieder tikai jums.';

  @override
  String get onboardingTransportTitle => 'Transporta neatkarīgs';

  @override
  String get onboardingTransportBody =>
      'Izmantojiet Firebase, Nostr vai abus vienlaicīgi.\n\nZiņas automātiski tiek maršrutētas starp tīkliem. Iebūvēts Tor un I2P atbalsts cenzūras apiešanai.';

  @override
  String get onboardingSignalTitle => 'Signal + pēc-kvantu';

  @override
  String get onboardingSignalBody =>
      'Katra ziņa tiek šifrēta ar Signal protokolu (Double Ratchet + X3DH) tiešās slepenības nodrošināšanai.\n\nPapildus apvīta ar Kyber-1024 — NIST standarta pēc-kvantu algoritmu — aizsardzībai pret nākotnes kvantu datoriem.';

  @override
  String get onboardingKeysTitle => 'Jūsu atslēgas pieder jums';

  @override
  String get onboardingKeysBody =>
      'Jūsu identitātes atslēgas nekad neatstāj jūsu ierīci.\n\nSignal pirkstu nospiedumi ļauj verificēt kontaktus ārpus kanāla. TOFU (Trust On First Use) automātiski atklāj atslēgu izmaiņas.';

  @override
  String get onboardingThemeTitle => 'Izvēlieties savu izskatu';

  @override
  String get onboardingThemeBody =>
      'Izvēlieties motīvu un akcenta krāsu. Jūs vienmēr varat to mainīt vēlāk Iestatījumos.';

  @override
  String get contactsNewChat => 'Jauna saruna';

  @override
  String get contactsAddContact => 'Pievienot kontaktu';

  @override
  String get contactsSearchHint => 'Meklēt...';

  @override
  String get contactsNewGroup => 'Jauna grupa';

  @override
  String get contactsNoContactsYet => 'Kontaktu vēl nav';

  @override
  String get contactsAddHint => 'Pieskarieties +, lai pievienotu adresi';

  @override
  String get contactsNoMatch => 'Nav atbilstošu kontaktu';

  @override
  String get contactsRemoveTitle => 'Noņemt kontaktu';

  @override
  String contactsRemoveMessage(String name) {
    return 'Noņemt $name?';
  }

  @override
  String get contactsRemove => 'Noņemt';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'i',
      one: 's',
    );
    return '$count kontakt$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Atvērt saiti';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Atvērt šo URL pārlūkā?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Atvērt';

  @override
  String get bubbleSecurityWarning => 'Drošības brīdinājums';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" ir izpildāms faila tips. Tā saglabāšana un palaišana var kaitēt jūsu ierīcei. Saglabāt tik un tā?';
  }

  @override
  String get bubbleSaveAnyway => 'Saglabāt tik un tā';

  @override
  String bubbleSavedTo(String path) {
    return 'Saglabāts $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Saglabāšana neizdevās: $error';
  }

  @override
  String get bubbleNotEncrypted => 'NAV ŠIFRĒTS';

  @override
  String get bubbleCorruptedImage => '[Bojāts attēls]';

  @override
  String get bubbleReplyPhoto => 'Foto';

  @override
  String get bubbleReplyVoice => 'Balss ziņa';

  @override
  String get bubbleReplyVideo => 'Video ziņa';

  @override
  String bubbleReadBy(String names) {
    return 'Izlasīja $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Izlasīja $count';
  }

  @override
  String get chatTileTapToStart => 'Pieskarieties, lai sāktu saraksti';

  @override
  String get chatTileMessageSent => 'Ziņa nosūtīta';

  @override
  String get chatTileEncryptedMessage => 'Šifrēta ziņa';

  @override
  String chatTileYouPrefix(String text) {
    return 'Jūs: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Balss ziņa';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Balss ziņa ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Šifrēta ziņa';

  @override
  String get groupNewGroup => 'Jauna grupa';

  @override
  String get groupGroupName => 'Grupas nosaukums';

  @override
  String get groupSelectMembers => 'Izvēlieties dalībniekus (min. 2)';

  @override
  String get groupNoContactsYet =>
      'Kontaktu vēl nav. Vispirms pievienojiet kontaktus.';

  @override
  String get groupCreate => 'Izveidot';

  @override
  String get groupLabel => 'Grupa';

  @override
  String get profileVerifyIdentity => 'Verificēt identitāti';

  @override
  String profileVerifyInstructions(String name) {
    return 'Salīdziniet šos pirkstu nospiedumus ar $name balss zvanā vai klātienē. Ja abas vērtības sakrīt abās ierīcēs, pieskarieties \"Atzīmēt kā verificētu\".';
  }

  @override
  String get profileTheirKey => 'Viņu atslēga';

  @override
  String get profileYourKey => 'Jūsu atslēga';

  @override
  String get profileRemoveVerification => 'Noņemt verifikāciju';

  @override
  String get profileMarkAsVerified => 'Atzīmēt kā verificētu';

  @override
  String get profileAddressCopied => 'Adrese nokopēta';

  @override
  String get profileNoContactsToAdd =>
      'Nav kontaktu, ko pievienot — visi jau ir dalībnieki';

  @override
  String get profileAddMembers => 'Pievienot dalībniekus';

  @override
  String profileAddCount(int count) {
    return 'Pievienot ($count)';
  }

  @override
  String get profileRenameGroup => 'Pārdēvēt grupu';

  @override
  String get profileRename => 'Pārdēvēt';

  @override
  String get profileRemoveMember => 'Noņemt dalībnieku?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Noņemt $name no šīs grupas?';
  }

  @override
  String get profileKick => 'Izmest';

  @override
  String get profileSignalFingerprints => 'Signal pirkstu nospiedumi';

  @override
  String get profileVerified => 'VERIFICĒTS';

  @override
  String get profileVerify => 'Verificēt';

  @override
  String get profileEdit => 'Rediģēt';

  @override
  String get profileNoSession =>
      'Sesija vēl nav izveidota — vispirms nosūtiet ziņu.';

  @override
  String get profileFingerprintCopied => 'Pirkstu nospiedums nokopēts';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'i',
      one: '',
    );
    return '$count dalībnieks$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Verificēt drošības numuru';

  @override
  String get profileShowContactQr => 'Rādīt kontakta QR';

  @override
  String profileContactAddress(String name) {
    return '$name adrese';
  }

  @override
  String get profileExportChatHistory => 'Eksportēt sarunu vēsturi';

  @override
  String profileSavedTo(String path) {
    return 'Saglabāts $path';
  }

  @override
  String get profileExportFailed => 'Eksports neizdevās';

  @override
  String get profileClearChatHistory => 'Dzēst sarunu vēsturi';

  @override
  String get profileDeleteGroup => 'Dzēst grupu';

  @override
  String get profileDeleteContact => 'Dzēst kontaktu';

  @override
  String get profileLeaveGroup => 'Pamest grupu';

  @override
  String get profileLeaveGroupBody =>
      'Jūs tiksiet noņemts no šīs grupas un tā tiks dzēsta no jūsu kontaktiem.';

  @override
  String get groupInviteTitle => 'Grupas ielūgums';

  @override
  String groupInviteBody(String from, String group) {
    return '$from aicināja jūs pievienoties grupai \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Pieņemt';

  @override
  String get groupInviteDecline => 'Noraidīt';

  @override
  String get groupMemberLimitTitle => 'Pārāk daudz dalībnieku';

  @override
  String groupMemberLimitBody(int count) {
    return 'Šajā grupā būs $count dalībnieki. Šifrētie tīkla zvani atbalsta līdz 6. Lielākas grupas pārslēdzas uz Jitsi (nav E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Pievienot tik un tā';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name noraidīja ielūgumu grupai \"$group\"';
  }

  @override
  String get transferTitle => 'Pārsūtīt uz citu ierīci';

  @override
  String get transferInfoBox =>
      'Pārvietojiet savu Signal identitāti un Nostr atslēgas uz jaunu ierīci.\nSarunu sesijas NETIEK pārsūtītas — tiešā slepenība tiek saglabāta.';

  @override
  String get transferSendFromThis => 'Sūtīt no šīs ierīces';

  @override
  String get transferSendSubtitle =>
      'Šajā ierīcē ir atslēgas. Kopīgojiet kodu ar jauno ierīci.';

  @override
  String get transferReceiveOnThis => 'Saņemt šajā ierīcē';

  @override
  String get transferReceiveSubtitle =>
      'Šī ir jaunā ierīce. Ievadiet kodu no vecās ierīces.';

  @override
  String get transferChooseMethod => 'Izvēlieties pārsūtīšanas metodi';

  @override
  String get transferLan => 'LAN (Viens tīkls)';

  @override
  String get transferLanSubtitle =>
      'Ātri un tieši. Abām ierīcēm jābūt vienā Wi-Fi tīklā.';

  @override
  String get transferNostrRelay => 'Nostr relejs';

  @override
  String get transferNostrRelaySubtitle =>
      'Darbojas jebkurā tīklā, izmantojot esošu Nostr releju.';

  @override
  String get transferRelayUrl => 'Releja URL';

  @override
  String get transferEnterCode => 'Ievadīt pārsūtīšanas kodu';

  @override
  String get transferPasteCode => 'Ielīmējiet LAN:... vai NOS:... kodu šeit';

  @override
  String get transferConnect => 'Savienoties';

  @override
  String get transferGenerating => 'Ģenerē pārsūtīšanas kodu…';

  @override
  String get transferShareCode => 'Kopīgojiet šo kodu ar saņēmēju:';

  @override
  String get transferCopyCode => 'Kopēt kodu';

  @override
  String get transferCodeCopied => 'Kods nokopēts starpliktuvē';

  @override
  String get transferWaitingReceiver => 'Gaida saņēmēja savienojumu…';

  @override
  String get transferConnectingSender => 'Savienojas ar sūtītāju…';

  @override
  String get transferVerifyBoth =>
      'Salīdziniet šo kodu abās ierīcēs.\nJa tie sakrīt, pārsūtīšana ir droša.';

  @override
  String get transferComplete => 'Pārsūtīšana pabeigta';

  @override
  String get transferKeysImported => 'Atslēgas importētas';

  @override
  String get transferCompleteSenderBody =>
      'Jūsu atslēgas paliek aktīvas šajā ierīcē.\nSaņēmējs tagad var izmantot jūsu identitāti.';

  @override
  String get transferCompleteReceiverBody =>
      'Atslēgas veiksmīgi importētas.\nRestartējiet lietotni, lai piemērotu jauno identitāti.';

  @override
  String get transferRestartApp => 'Restartēt lietotni';

  @override
  String get transferFailed => 'Pārsūtīšana neizdevās';

  @override
  String get transferTryAgain => 'Mēģināt vēlreiz';

  @override
  String get transferEnterRelayFirst => 'Vispirms ievadiet releja URL';

  @override
  String get transferPasteCodeFromSender =>
      'Ielīmējiet sūtītāja pārsūtīšanas kodu';

  @override
  String get menuReply => 'Atbildēt';

  @override
  String get menuForward => 'Pārsūtīt';

  @override
  String get menuReact => 'Reaģēt';

  @override
  String get menuCopy => 'Kopēt';

  @override
  String get menuEdit => 'Rediģēt';

  @override
  String get menuRetry => 'Mēģināt vēlreiz';

  @override
  String get menuCancelScheduled => 'Atcelt ieplānoto';

  @override
  String get menuDelete => 'Dzēst';

  @override
  String get menuForwardTo => 'Pārsūtīt…';

  @override
  String menuForwardedTo(String name) {
    return 'Pārsūtīts $name';
  }

  @override
  String get menuScheduledMessages => 'Ieplānotās ziņas';

  @override
  String get menuNoScheduledMessages => 'Nav ieplānoto ziņu';

  @override
  String menuSendsOn(String date) {
    return 'Tiks nosūtīts $date';
  }

  @override
  String get menuDisappearingMessages => 'Pazūdošās ziņas';

  @override
  String get menuDisappearingSubtitle =>
      'Ziņas tiek automātiski dzēstas pēc izvēlētā laika.';

  @override
  String get menuTtlOff => 'Izslēgts';

  @override
  String get menuTtl1h => '1 stunda';

  @override
  String get menuTtl24h => '24 stundas';

  @override
  String get menuTtl7d => '7 dienas';

  @override
  String get menuAttachPhoto => 'Foto';

  @override
  String get menuAttachFile => 'Fails';

  @override
  String get menuAttachVideo => 'Video';

  @override
  String get mediaTitle => 'Multivide';

  @override
  String get mediaFileLabel => 'FAILS';

  @override
  String mediaPhotosTab(int count) {
    return 'Fotoattēli ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Faili ($count)';
  }

  @override
  String get mediaNoPhotos => 'Fotoattēlu vēl nav';

  @override
  String get mediaNoFiles => 'Failu vēl nav';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Saglabāts mapē Lejupielādes/$name';
  }

  @override
  String get mediaFailedToSave => 'Neizdevās saglabāt failu';

  @override
  String get statusNewStatus => 'Jauns statuss';

  @override
  String get statusPublish => 'Publicēt';

  @override
  String get statusExpiresIn24h => 'Statuss beidzas pēc 24 stundām';

  @override
  String get statusWhatsOnYourMind => 'Kas jums prātā?';

  @override
  String get statusPhotoAttached => 'Foto pievienots';

  @override
  String get statusAttachPhoto => 'Pievienot foto (neobligāti)';

  @override
  String get statusEnterText => 'Lūdzu, ievadiet tekstu savam statusam.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Neizdevās izvēlēties foto: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Neizdevās publicēt: $error';
  }

  @override
  String get panicSetPanicKey => 'Iestatīt panikas atslēgu';

  @override
  String get panicEmergencySelfDestruct => 'Ārkārtas pašiznīcināšanās';

  @override
  String get panicIrreversible => 'Šī darbība ir neatgriezeniska';

  @override
  String get panicWarningBody =>
      'Ievadot šo atslēgu bloķēšanas ekrānā, tiks nekavējoties dzēsti VISI dati — ziņas, kontakti, atslēgas, identitāte. Izmantojiet atslēgu, kas atšķiras no jūsu parastās paroles.';

  @override
  String get panicKeyHint => 'Panikas atslēga';

  @override
  String get panicConfirmHint => 'Apstiprināt panikas atslēgu';

  @override
  String get panicMinChars => 'Panikas atslēgai jābūt vismaz 8 rakstzīmēm';

  @override
  String get panicKeysDoNotMatch => 'Atslēgas nesakrīt';

  @override
  String get panicSetFailed =>
      'Neizdevās saglabāt panikas atslēgu — lūdzu, mēģiniet vēlreiz';

  @override
  String get passwordSetAppPassword => 'Iestatīt lietotnes paroli';

  @override
  String get passwordProtectsMessages => 'Aizsargā jūsu ziņas miera stāvoklī';

  @override
  String get passwordInfoBanner =>
      'Nepieciešama katru reizi, atverot Pulse. Ja aizmirsīsiet, jūsu datus nevarēs atgūt.';

  @override
  String get passwordHint => 'Parole';

  @override
  String get passwordConfirmHint => 'Apstiprināt paroli';

  @override
  String get passwordSetButton => 'Iestatīt paroli';

  @override
  String get passwordSkipForNow => 'Pagaidām izlaist';

  @override
  String get passwordMinChars => 'Parolei jābūt vismaz 6 rakstzīmēm';

  @override
  String get passwordsDoNotMatch => 'Paroles nesakrīt';

  @override
  String get profileCardSaved => 'Profils saglabāts!';

  @override
  String get profileCardE2eeIdentity => 'E2EE identitāte';

  @override
  String get profileCardDisplayName => 'Attēlojamais vārds';

  @override
  String get profileCardDisplayNameHint => 'piem. Jānis Bērziņš';

  @override
  String get profileCardAbout => 'Par mani';

  @override
  String get profileCardSaveProfile => 'Saglabāt profilu';

  @override
  String get profileCardYourName => 'Jūsu vārds';

  @override
  String get profileCardAddressCopied => 'Adrese nokopēta!';

  @override
  String get profileCardInboxAddress => 'Jūsu iesūtnes adrese';

  @override
  String get profileCardInboxAddresses => 'Jūsu iesūtnes adreses';

  @override
  String get profileCardShareAllAddresses =>
      'Kopīgot visas adreses (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Kopīgojiet ar kontaktiem, lai viņi varētu jums rakstīt.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Visas $count adreses nokopētas kā viena saite!';
  }

  @override
  String get settingsMyProfile => 'Mans profils';

  @override
  String get settingsYourInboxAddress => 'Jūsu iesūtnes adrese';

  @override
  String get settingsMyQrCode => 'Mans QR kods';

  @override
  String get settingsMyQrSubtitle => 'Kopīgojiet adresi kā skenējamu QR kodu';

  @override
  String get settingsShareMyAddress => 'Kopīgot manu adresi';

  @override
  String get settingsNoAddressYet =>
      'Adreses vēl nav — vispirms saglabājiet iestatījumus';

  @override
  String get settingsInviteLink => 'Ielūguma saite';

  @override
  String get settingsRawAddress => 'Neapstrādāta adrese';

  @override
  String get settingsCopyLink => 'Kopēt saiti';

  @override
  String get settingsCopyAddress => 'Kopēt adresi';

  @override
  String get settingsInviteLinkCopied => 'Ielūguma saite nokopēta';

  @override
  String get settingsAppearance => 'Izskats';

  @override
  String get settingsThemeEngine => 'Motīvu dzinējs';

  @override
  String get settingsThemeEngineSubtitle => 'Pielāgojiet krāsas un fontus';

  @override
  String get settingsSignalProtocol => 'Signal protokols';

  @override
  String get settingsSignalProtocolSubtitle =>
      'E2EE atslēgas tiek glabātas droši';

  @override
  String get settingsActive => 'AKTĪVS';

  @override
  String get settingsIdentityBackup => 'Identitātes dublējums';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Eksportēt vai importēt jūsu Signal identitāti';

  @override
  String get settingsIdentityBackupBody =>
      'Eksportējiet Signal identitātes atslēgas dublējuma kodā vai atjaunojiet no esoša.';

  @override
  String get settingsTransferDevice => 'Pārsūtīt uz citu ierīci';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Pārvietojiet identitāti caur LAN vai Nostr releju';

  @override
  String get settingsExportIdentity => 'Eksportēt identitāti';

  @override
  String get settingsExportIdentityBody =>
      'Nokopējiet šo dublējuma kodu un glabājiet to droši:';

  @override
  String get settingsSaveFile => 'Saglabāt failu';

  @override
  String get settingsImportIdentity => 'Importēt identitāti';

  @override
  String get settingsImportIdentityBody =>
      'Ielīmējiet dublējuma kodu zemāk. Tas pārrakstīs jūsu pašreizējo identitāti.';

  @override
  String get settingsPasteBackupCode => 'Ielīmējiet dublējuma kodu šeit…';

  @override
  String get settingsIdentityImported =>
      'Identitāte + kontakti importēti! Restartējiet lietotni, lai piemērotu.';

  @override
  String get settingsSecurity => 'Drošība';

  @override
  String get settingsAppPassword => 'Lietotnes parole';

  @override
  String get settingsPasswordEnabled =>
      'Iespējota — nepieciešama katrā palaišanā';

  @override
  String get settingsPasswordDisabled =>
      'Atspējota — lietotne atveras bez paroles';

  @override
  String get settingsChangePassword => 'Mainīt paroli';

  @override
  String get settingsChangePasswordSubtitle =>
      'Atjaunināt lietotnes bloķēšanas paroli';

  @override
  String get settingsSetPanicKey => 'Iestatīt panikas atslēgu';

  @override
  String get settingsChangePanicKey => 'Mainīt panikas atslēgu';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Atjaunināt ārkārtas dzēšanas atslēgu';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Viena atslēga, kas nekavējoties dzēš visus datus';

  @override
  String get settingsRemovePanicKey => 'Noņemt panikas atslēgu';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Atspējot ārkārtas pašiznīcināšanos';

  @override
  String get settingsRemovePanicKeyBody =>
      'Ārkārtas pašiznīcināšanās tiks atspējota. Jūs varat to atkārtoti iespējot jebkurā laikā.';

  @override
  String get settingsDisableAppPassword => 'Atspējot lietotnes paroli';

  @override
  String get settingsEnterCurrentPassword =>
      'Ievadiet pašreizējo paroli, lai apstiprinātu';

  @override
  String get settingsCurrentPassword => 'Pašreizējā parole';

  @override
  String get settingsIncorrectPassword => 'Nepareiza parole';

  @override
  String get settingsPasswordUpdated => 'Parole atjaunināta';

  @override
  String get settingsChangePasswordProceed =>
      'Ievadiet pašreizējo paroli, lai turpinātu';

  @override
  String get settingsData => 'Dati';

  @override
  String get settingsBackupMessages => 'Dublēt ziņas';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Eksportēt šifrētu ziņu vēsturi failā';

  @override
  String get settingsRestoreMessages => 'Atjaunot ziņas';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Importēt ziņas no dublējuma faila';

  @override
  String get settingsExportKeys => 'Eksportēt atslēgas';

  @override
  String get settingsExportKeysSubtitle =>
      'Saglabāt identitātes atslēgas šifrētā failā';

  @override
  String get settingsImportKeys => 'Importēt atslēgas';

  @override
  String get settingsImportKeysSubtitle =>
      'Atjaunot identitātes atslēgas no eksportēta faila';

  @override
  String get settingsBackupPassword => 'Dublējuma parole';

  @override
  String get settingsPasswordCannotBeEmpty => 'Parole nevar būt tukša';

  @override
  String get settingsPasswordMin4Chars => 'Parolei jābūt vismaz 4 rakstzīmēm';

  @override
  String get settingsCallsTurn => 'Zvani un TURN';

  @override
  String get settingsLocalNetwork => 'Lokālais tīkls';

  @override
  String get settingsCensorshipResistance => 'Cenzūras pretestība';

  @override
  String get settingsNetwork => 'Tīkls';

  @override
  String get settingsProxyTunnels => 'Starpniekserveri un tuneļi';

  @override
  String get settingsTurnServers => 'TURN serveri';

  @override
  String get settingsProviderTitle => 'Pakalpojumu sniedzējs';

  @override
  String get settingsLanFallback => 'LAN rezerve';

  @override
  String get settingsLanFallbackSubtitle =>
      'Pārraidīt klātbūtni un piegādāt ziņas lokālajā tīklā, kad internets nav pieejams. Atspējojiet neuzticamos tīklos (publiskais Wi-Fi).';

  @override
  String get settingsBgDelivery => 'Fona piegāde';

  @override
  String get settingsBgDeliverySubtitle =>
      'Turpināt saņemt ziņas, kad lietotne ir minimizēta. Rāda pastāvīgu paziņojumu.';

  @override
  String get settingsYourInboxProvider => 'Jūsu iesūtnes pakalpojumu sniedzējs';

  @override
  String get settingsConnectionDetails => 'Savienojuma informācija';

  @override
  String get settingsSaveAndConnect => 'Saglabāt un savienoties';

  @override
  String get settingsSecondaryInboxes => 'Sekundārās iesūtnes';

  @override
  String get settingsAddSecondaryInbox => 'Pievienot sekundāro iesūtni';

  @override
  String get settingsAdvanced => 'Papildu';

  @override
  String get settingsDiscover => 'Atklāt';

  @override
  String get settingsAbout => 'Par';

  @override
  String get settingsPrivacyPolicy => 'Privātuma politika';

  @override
  String get settingsPrivacyPolicySubtitle => 'Kā Pulse aizsargā jūsu datus';

  @override
  String get settingsCrashReporting => 'Avāriju ziņošana';

  @override
  String get settingsCrashReportingSubtitle =>
      'Sūtīt anonīmus avāriju ziņojumus, lai uzlabotu Pulse. Nekad netiek sūtīts ziņu saturs vai kontakti.';

  @override
  String get settingsCrashReportingEnabled =>
      'Avāriju ziņošana iespējota — restartējiet lietotni, lai piemērotu';

  @override
  String get settingsCrashReportingDisabled =>
      'Avāriju ziņošana atspējota — restartējiet lietotni, lai piemērotu';

  @override
  String get settingsSensitiveOperation => 'Jutīga operācija';

  @override
  String get settingsSensitiveOperationBody =>
      'Šīs atslēgas ir jūsu identitāte. Jebkurš ar šo failu var uzdoties par jums. Glabājiet to droši un dzēsiet pēc pārsūtīšanas.';

  @override
  String get settingsIUnderstandContinue => 'Es saprotu, turpināt';

  @override
  String get settingsReplaceIdentity => 'Aizstāt identitāti?';

  @override
  String get settingsReplaceIdentityBody =>
      'Tas pārrakstīs jūsu pašreizējās identitātes atslēgas. Jūsu esošās Signal sesijas kļūs nederīgas un kontaktiem būs atkārtoti jāizveido šifrēšana. Lietotne būs jārestartē.';

  @override
  String get settingsReplaceKeys => 'Aizstāt atslēgas';

  @override
  String get settingsKeysImported => 'Atslēgas importētas';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count atslēgas veiksmīgi importētas. Lūdzu, restartējiet lietotni, lai inicializētu ar jauno identitāti.';
  }

  @override
  String get settingsRestartNow => 'Restartēt tagad';

  @override
  String get settingsLater => 'Vēlāk';

  @override
  String get profileGroupLabel => 'Grupa';

  @override
  String get profileAddButton => 'Pievienot';

  @override
  String get profileKickButton => 'Izmest';

  @override
  String get dataSectionTitle => 'Dati';

  @override
  String get dataBackupMessages => 'Dublēt ziņas';

  @override
  String get dataBackupPasswordSubtitle =>
      'Izvēlieties paroli, lai šifrētu ziņu dublējumu.';

  @override
  String get dataBackupConfirmLabel => 'Izveidot dublējumu';

  @override
  String get dataCreatingBackup => 'Veido dublējumu';

  @override
  String get dataBackupPreparing => 'Sagatavo...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Eksportē ziņu $done no $total...';
  }

  @override
  String get dataBackupSavingFile => 'Saglabā failu...';

  @override
  String get dataSaveMessageBackupDialog => 'Saglabāt ziņu dublējumu';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Dublējums saglabāts ($count ziņas)\n$path';
  }

  @override
  String get dataBackupFailed => 'Dublēšana neizdevās — dati nav eksportēti';

  @override
  String dataBackupFailedError(String error) {
    return 'Dublēšana neizdevās: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Izvēlēties ziņu dublējumu';

  @override
  String get dataInvalidBackupFile => 'Nederīgs dublējuma fails (pārāk mazs)';

  @override
  String get dataNotValidBackupFile => 'Nav derīgs Pulse dublējuma fails';

  @override
  String get dataRestoreMessages => 'Atjaunot ziņas';

  @override
  String get dataRestorePasswordSubtitle =>
      'Ievadiet paroli, kas tika izmantota šī dublējuma izveidei.';

  @override
  String get dataRestoreConfirmLabel => 'Atjaunot';

  @override
  String get dataRestoringMessages => 'Atjauno ziņas';

  @override
  String get dataRestoreDecrypting => 'Atšifrē...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Importē ziņu $done no $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Atjaunošana neizdevās — nepareiza parole vai bojāts fails';

  @override
  String dataRestoreSuccess(int count) {
    return 'Atjaunotas $count jaunas ziņas';
  }

  @override
  String get dataRestoreNothingNew =>
      'Nav jaunu ziņu importēšanai (visas jau pastāv)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Atjaunošana neizdevās: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Izvēlēties atslēgu eksportu';

  @override
  String get dataNotValidKeyFile => 'Nav derīgs Pulse atslēgu eksporta fails';

  @override
  String get dataExportKeys => 'Eksportēt atslēgas';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Izvēlieties paroli, lai šifrētu atslēgu eksportu.';

  @override
  String get dataExportKeysConfirmLabel => 'Eksportēt';

  @override
  String get dataExportingKeys => 'Eksportē atslēgas';

  @override
  String get dataExportingKeysStatus => 'Šifrē identitātes atslēgas...';

  @override
  String get dataSaveKeyExportDialog => 'Saglabāt atslēgu eksportu';

  @override
  String dataKeysExportedTo(String path) {
    return 'Atslēgas eksportētas uz:\n$path';
  }

  @override
  String get dataExportFailed => 'Eksports neizdevās — atslēgas nav atrastas';

  @override
  String dataExportFailedError(String error) {
    return 'Eksports neizdevās: $error';
  }

  @override
  String get dataImportKeys => 'Importēt atslēgas';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Ievadiet paroli, kas tika izmantota šī atslēgu eksporta šifrēšanai.';

  @override
  String get dataImportKeysConfirmLabel => 'Importēt';

  @override
  String get dataImportingKeys => 'Importē atslēgas';

  @override
  String get dataImportingKeysStatus => 'Atšifrē identitātes atslēgas...';

  @override
  String get dataImportFailed =>
      'Imports neizdevās — nepareiza parole vai bojāts fails';

  @override
  String dataImportFailedError(String error) {
    return 'Imports neizdevās: $error';
  }

  @override
  String get securitySectionTitle => 'Drošība';

  @override
  String get securityIncorrectPassword => 'Nepareiza parole';

  @override
  String get securityPasswordUpdated => 'Parole atjaunināta';

  @override
  String get appearanceSectionTitle => 'Izskats';

  @override
  String appearanceExportFailed(String error) {
    return 'Eksports neizdevās: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Saglabāts $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Saglabāšana neizdevās: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Imports neizdevās: $error';
  }

  @override
  String get aboutSectionTitle => 'Par';

  @override
  String get providerPublicKey => 'Publiskā atslēga';

  @override
  String get providerRelay => 'Relejs';

  @override
  String get providerAutoConfigured =>
      'Automātiski konfigurēts no jūsu atjaunošanas paroles. Relejs atklāts automātiski.';

  @override
  String get providerKeyStoredLocally =>
      'Jūsu atslēga tiek glabāta lokāli drošā krātuvē — nekad netiek sūtīta nevienam serverim.';

  @override
  String get providerSessionInfo =>
      'Session Network — sīpolu maršrutizācijas E2EE. Jūsu Session ID tiek automātiski ģenerēts un droši uzglabāts. Mezgli tiek automātiski atklāti no iebūvētajiem sēklas mezgliem.';

  @override
  String get providerAdvanced => 'Papildu';

  @override
  String get providerSaveAndConnect => 'Saglabāt un savienoties';

  @override
  String get providerAddSecondaryInbox => 'Pievienot sekundāro iesūtni';

  @override
  String get providerSecondaryInboxes => 'Sekundārās iesūtnes';

  @override
  String get providerYourInboxProvider => 'Jūsu iesūtnes pakalpojumu sniedzējs';

  @override
  String get providerConnectionDetails => 'Savienojuma informācija';

  @override
  String get addContactTitle => 'Pievienot kontaktu';

  @override
  String get addContactInviteLinkLabel => 'Ielūguma saite vai adrese';

  @override
  String get addContactTapToPaste =>
      'Pieskarieties, lai ielīmētu ielūguma saiti';

  @override
  String get addContactPasteTooltip => 'Ielīmēt no starpliktuves';

  @override
  String get addContactAddressDetected => 'Kontakta adrese atklāta';

  @override
  String addContactRoutesDetected(int count) {
    return '$count maršruti atklāti — SmartRouter izvēlas ātrāko';
  }

  @override
  String get addContactFetchingProfile => 'Ielādē profilu…';

  @override
  String addContactProfileFound(String name) {
    return 'Atrasts: $name';
  }

  @override
  String get addContactNoProfileFound => 'Profils nav atrasts';

  @override
  String get addContactDisplayNameLabel => 'Attēlojamais vārds';

  @override
  String get addContactDisplayNameHint => 'Kā jūs vēlaties viņu saukt?';

  @override
  String get addContactAddManually => 'Pievienot adresi manuāli';

  @override
  String get addContactButton => 'Pievienot kontaktu';

  @override
  String get networkDiagnosticsTitle => 'Tīkla diagnostika';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr releji';

  @override
  String get networkDiagnosticsDirect => 'Tiešie';

  @override
  String get networkDiagnosticsTorOnly => 'Tikai Tor';

  @override
  String get networkDiagnosticsBest => 'Labākais';

  @override
  String get networkDiagnosticsNone => 'nav';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Statuss';

  @override
  String get networkDiagnosticsConnected => 'Savienots';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Savienojas $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Izslēgts';

  @override
  String get networkDiagnosticsTransport => 'Transports';

  @override
  String get networkDiagnosticsInfrastructure => 'Infrastruktūra';

  @override
  String get networkDiagnosticsSessionNodes => 'Session mezgli';

  @override
  String get networkDiagnosticsTurnServers => 'TURN serveri';

  @override
  String get networkDiagnosticsLastProbe => 'Pēdējā pārbaude';

  @override
  String get networkDiagnosticsRunning => 'Darbojas...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Palaist diagnostiku';

  @override
  String get networkDiagnosticsForceReprobe =>
      'Piespiest pilnu atkārtotu pārbaudi';

  @override
  String get networkDiagnosticsJustNow => 'tikko';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'pirms $minutes min.';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'pirms $hours st.';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'pirms $days d.';
  }

  @override
  String get homeNoEch => 'Nav ECH';

  @override
  String get homeNoEchTooltip =>
      'uTLS starpniekserveris nav pieejams — ECH atspējots.\nTLS pirkstu nospiedums ir redzams DPI.';

  @override
  String get settingsTitle => 'Iestatījumi';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Saglabāts un savienots ar $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Iebūvētais Tor neizdevās startēt';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon neizdevās startēt';

  @override
  String get verifyTitle => 'Verificēt drošības numuru';

  @override
  String get verifyIdentityVerified => 'Identitāte verificēta';

  @override
  String get verifyNotYetVerified => 'Vēl nav verificēts';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Jūs esat verificējis $name drošības numuru.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Salīdziniet šos numurus ar $name klātienē vai caur uzticamu kanālu.';
  }

  @override
  String get verifyExplanation =>
      'Katrai sarunai ir unikāls drošības numurs. Ja jūs abi redzat vienādus numurus savās ierīcēs, jūsu savienojums ir pilnībā verificēts.';

  @override
  String verifyContactKey(String name) {
    return '$name atslēga';
  }

  @override
  String get verifyYourKey => 'Jūsu atslēga';

  @override
  String get verifyRemoveVerification => 'Noņemt verifikāciju';

  @override
  String get verifyMarkAsVerified => 'Atzīmēt kā verificētu';

  @override
  String verifyAfterReinstall(String name) {
    return 'Ja $name pārinstalēs lietotni, drošības numurs mainīsies un verifikācija tiks automātiski noņemta.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Atzīmējiet identitāti kā verificētu tikai pēc numuru salīdzināšanas ar $name balss zvanā vai klātienē.';
  }

  @override
  String get verifyNoSession =>
      'Šifrēšanas sesija vēl nav izveidota. Vispirms nosūtiet ziņu, lai ģenerētu drošības numurus.';

  @override
  String get verifyNoKeyAvailable => 'Atslēga nav pieejama';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label pirkstu nospiedums nokopēts';
  }

  @override
  String get providerDatabaseUrlLabel => 'Datubāzes URL';

  @override
  String get providerOptionalHint => 'Neobligāts';

  @override
  String get providerWebApiKeyLabel => 'Web API atslēga';

  @override
  String get providerOptionalForPublicDb => 'Neobligāts publiskai datubāzei';

  @override
  String get providerRelayUrlLabel => 'Releja URL';

  @override
  String get providerPrivateKeyLabel => 'Privātā atslēga';

  @override
  String get providerPrivateKeyNsecLabel => 'Privātā atslēga (nsec)';

  @override
  String get providerStorageNodeLabel => 'Krātuves mezgla URL (neobligāts)';

  @override
  String get providerStorageNodeHint =>
      'Atstājiet tukšu iebūvētajiem sākuma mezgliem';

  @override
  String get transferInvalidCodeFormat =>
      'Neatpazīts koda formāts — jāsākas ar LAN: vai NOS:';

  @override
  String get profileCardFingerprintCopied => 'Pirkstu nospiedums nokopēts';

  @override
  String get profileCardAboutHint => 'Privātums vispirms 🔒';

  @override
  String get profileCardSaveButton => 'Saglabāt profilu';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Eksportēt šifrētas ziņas, kontaktus un avatārus failā';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Audio';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Piegādāts $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Piegādāts $count';
  }

  @override
  String get groupStatusDialogTitle => 'Ziņas informācija';

  @override
  String get groupStatusRead => 'Izlasīts';

  @override
  String get groupStatusDelivered => 'Piegādāts';

  @override
  String get groupStatusPending => 'Gaida';

  @override
  String get groupStatusNoData => 'Piegādes informācijas vēl nav';

  @override
  String get profileTransferAdmin => 'Padarīt par administratoru';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Padarīt $name par jauno administratoru?';
  }

  @override
  String get profileTransferAdminBody =>
      'Jūs zaudēsiet administratora tiesības. To nevar atsaukt.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name tagad ir administrators';
  }

  @override
  String get profileAdminBadge => 'Administrators';

  @override
  String get privacyPolicyTitle => 'Privātuma politika';

  @override
  String get privacyOverviewHeading => 'Pārskats';

  @override
  String get privacyOverviewBody =>
      'Pulse ir bezserveru, pilnībā šifrēts ziņapmaiņas lietotne. Jūsu privātums nav tikai funkcija — tā ir arhitektūra. Nav Pulse serveru. Nekādi konti nekur netiek glabāti. Nekādi dati netiek vākti, pārsūtīti vai glabāti izstrādātāju pusē.';

  @override
  String get privacyDataCollectionHeading => 'Datu vākšana';

  @override
  String get privacyDataCollectionBody =>
      'Pulse nevāc nekādus personas datus. Konkrēti:\n\n- Nav nepieciešams e-pasts, tālruņa numurs vai īstais vārds\n- Nav analītikas, izsekošanas vai telemetrijas\n- Nav reklāmas identifikatoru\n- Nav piekļuves kontaktu sarakstam\n- Nav mākoņa dublējumu (ziņas pastāv tikai jūsu ierīcē)\n- Nekādi metadati netiek sūtīti nevienam Pulse serverim (tādu nav)';

  @override
  String get privacyEncryptionHeading => 'Šifrēšana';

  @override
  String get privacyEncryptionBody =>
      'Visas ziņas tiek šifrētas, izmantojot Signal protokolu (Double Ratchet ar X3DH atslēgu vienošanos). Šifrēšanas atslēgas tiek ģenerētas un glabātas tikai jūsu ierīcē. Neviens — tostarp izstrādātāji — nevar lasīt jūsu ziņas.';

  @override
  String get privacyNetworkHeading => 'Tīkla arhitektūra';

  @override
  String get privacyNetworkBody =>
      'Pulse izmanto federētos transporta adapterus (Nostr relejus, Session/Oxen pakalpojumu mezglus, Firebase Realtime Database, LAN). Šie transporti pārsūta tikai šifrētu šifrētekstu. Releju operatori var redzēt jūsu IP adresi un datplūsmas apjomu, bet nevar atšifrēt ziņu saturu.\n\nKad Tor ir iespējots, jūsu IP adrese ir paslēpta arī no releju operatoriem.';

  @override
  String get privacyStunHeading => 'STUN/TURN serveri';

  @override
  String get privacyStunBody =>
      'Balss un video zvani izmanto WebRTC ar DTLS-SRTP šifrēšanu. STUN serveri (izmantoti jūsu publiskās IP atklāšanai vienādranga savienojumiem) un TURN serveri (izmantoti multivides pārsūtīšanai, kad tiešais savienojums neizdodas) var redzēt jūsu IP adresi un zvana ilgumu, bet nevar atšifrēt zvana saturu.\n\nJūs varat konfigurēt savu TURN serveri Iestatījumos maksimālam privātumam.';

  @override
  String get privacyCrashHeading => 'Avāriju ziņojumi';

  @override
  String get privacyCrashBody =>
      'Ja Sentry avāriju ziņošana ir iespējota (caur būvēšanas laika SENTRY_DSN), var tikt sūtīti anonīmi avāriju ziņojumi. Tie nesatur ziņu saturu, kontaktu informāciju un personiski identificējamu informāciju. Avāriju ziņošanu var atspējot būvēšanas laikā, izlaižot DSN.';

  @override
  String get privacyPasswordHeading => 'Parole un atslēgas';

  @override
  String get privacyPasswordBody =>
      'Jūsu atjaunošanas parole tiek izmantota kriptogrāfisko atslēgu atvasināšanai caur Argon2id (atmiņas ietilpīgs KDF). Parole nekad netiek pārsūtīta nekur. Ja jūs zaudēsiet paroli, jūsu kontu nevarēs atgūt — nav servera, kas to atiestatītu.';

  @override
  String get privacyFontsHeading => 'Fonti';

  @override
  String get privacyFontsBody =>
      'Pulse iekļauj visus fontus lokāli. Nekādi pieprasījumi netiek veikti Google Fonts vai citiem ārējiem fontu pakalpojumiem.';

  @override
  String get privacyThirdPartyHeading => 'Trešo pušu pakalpojumi';

  @override
  String get privacyThirdPartyBody =>
      'Pulse neintegrējas ne ar vienu reklāmas tīklu, analītikas pakalpojumu sniedzēju, sociālo mediju platformu vai datu brokeri. Vienīgie tīkla savienojumi ir ar transporta relejiem, ko jūs konfigurējat.';

  @override
  String get privacyOpenSourceHeading => 'Atvērtais pirmkods';

  @override
  String get privacyOpenSourceBody =>
      'Pulse ir atvērtā pirmkoda programmatūra. Jūs varat pārbaudīt pilnu pirmkodu, lai verificētu šos privātuma apgalvojumus.';

  @override
  String get privacyContactHeading => 'Kontakti';

  @override
  String get privacyContactBody =>
      'Ar privātumu saistītiem jautājumiem atveriet problēmu projekta repozitorijā.';

  @override
  String get privacyLastUpdated => 'Pēdējo reizi atjaunināts: 2026. gada marts';

  @override
  String imageSaveFailed(Object error) {
    return 'Saglabāšana neizdevās: $error';
  }

  @override
  String get themeEngineTitle => 'Motīvu dzinējs';

  @override
  String get torBuiltInTitle => 'Iebūvētais Tor';

  @override
  String get torConnectedSubtitle =>
      'Savienots — Nostr maršrutēts caur 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Savienojas… $pct%';
  }

  @override
  String get torNotRunning =>
      'Nedarbojas — pieskarieties slēdzim, lai restartētu';

  @override
  String get torDescription =>
      'Maršrutē Nostr caur Tor (Snowflake cenzētiem tīkliem)';

  @override
  String get torNetworkDiagnostics => 'Tīkla diagnostika';

  @override
  String get torTransportLabel => 'Transports: ';

  @override
  String get torPtAuto => 'Auto';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Parasts';

  @override
  String get torTimeoutLabel => 'Taimauts: ';

  @override
  String get torInfoDescription =>
      'Kad iespējots, Nostr WebSocket savienojumi tiek maršrutēti caur Tor (SOCKS5). Tor Browser klausās uz 127.0.0.1:9150. Atsevišķais Tor dēmons izmanto portu 9050. Firebase savienojumi netiek ietekmēti.';

  @override
  String get torRouteNostrTitle => 'Maršrutēt Nostr caur Tor';

  @override
  String get torManagedByBuiltin => 'Pārvalda iebūvētais Tor';

  @override
  String get torActiveRouting => 'Aktīvs — Nostr trafiks maršrutēts caur Tor';

  @override
  String get torDisabled => 'Atspējots';

  @override
  String get torProxySocks5 => 'Tor starpniekserveris (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Starpniekservera saimnieks';

  @override
  String get torProxyPortLabel => 'Ports';

  @override
  String get torPortInfo =>
      'Tor Browser: ports 9150  •  Tor dēmons: ports 9050';

  @override
  String get torForceNostrTitle => 'Route messages through Tor';

  @override
  String get torForceNostrSubtitle =>
      'All Nostr relay connections will go through Tor. Slower but hides your IP from relays.';

  @override
  String get torForceNostrDisabled => 'Tor must be enabled first';

  @override
  String get torForcePulseTitle => 'Route Pulse relay through Tor';

  @override
  String get torForcePulseSubtitle =>
      'All Pulse relay connections will go through Tor. Slower but hides your IP from the server.';

  @override
  String get torForcePulseDisabled => 'Tor must be enabled first';

  @override
  String get i2pProxySocks5 => 'I2P starpniekserveris (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P pēc noklusējuma izmanto SOCKS5 uz porta 4447. Savienojieties ar Nostr releju caur I2P outproxy (piem. relay.damus.i2p), lai sazinātos ar lietotājiem jebkurā transportā. Tor ir prioritārs, kad abi ir iespējoti.';

  @override
  String get i2pRouteNostrTitle => 'Maršrutēt Nostr caur I2P';

  @override
  String get i2pActiveRouting => 'Aktīvs — Nostr trafiks maršrutēts caur I2P';

  @override
  String get i2pDisabled => 'Atspējots';

  @override
  String get i2pProxyHostLabel => 'Starpniekservera saimnieks';

  @override
  String get i2pProxyPortLabel => 'Ports';

  @override
  String get i2pPortInfo => 'I2P maršrutētāja noklusējuma SOCKS5 ports: 4447';

  @override
  String get customProxySocks5 => 'Pielāgots starpniekserveris (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker relejs';

  @override
  String get customProxyInfoDescription =>
      'Pielāgotais starpniekserveris maršrutē trafiku caur jūsu V2Ray/Xray/Shadowsocks. CF Worker darbojas kā personīgais releja starpniekserveris Cloudflare CDN — GFW redz *.workers.dev, nevis īsto releju.';

  @override
  String get customSocks5ProxyTitle => 'Pielāgots SOCKS5 starpniekserveris';

  @override
  String get customProxyActive => 'Aktīvs — trafiks maršrutēts caur SOCKS5';

  @override
  String get customProxyDisabled => 'Atspējots';

  @override
  String get customProxyHostLabel => 'Starpniekservera saimnieks';

  @override
  String get customProxyPortLabel => 'Ports';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker domēns (neobligāts)';

  @override
  String get customWorkerHelpTitle =>
      'Kā izvietot CF Worker releju (bezmaksas)';

  @override
  String get customWorkerScriptCopied => 'Skripts nokopēts!';

  @override
  String get customWorkerStep1 =>
      '1. Dodieties uz dash.cloudflare.com → Workers & Pages\n2. Create Worker → ielīmējiet šo skriptu:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → nokopējiet domēnu (piem. my-relay.user.workers.dev)\n4. Ielīmējiet domēnu augstāk → Saglabāt\n\nLietotne automātiski savienojas: wss://domain/?r=relay_url\nGFW redz: savienojums ar *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Savienots — SOCKS5 uz 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Savienojas…';

  @override
  String get psiphonNotRunning =>
      'Nedarbojas — pieskarieties slēdzim, lai restartētu';

  @override
  String get psiphonDescription =>
      'Ātrs tunelis (~3s ielāde, 2000+ rotējoši VPS)';

  @override
  String get turnCommunityServers => 'Kopienas TURN serveri';

  @override
  String get turnCustomServer => 'Pielāgots TURN serveris (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN serveri pārsūta tikai jau šifrētas plūsmas (DTLS-SRTP). Releja operators redz jūsu IP un datplūsmas apjomu, bet nevar atšifrēt zvanus. TURN tiek izmantots tikai tad, kad tiešais P2P neizdodas (~15–20% savienojumu).';

  @override
  String get turnFreeLabel => 'BEZMAKSAS';

  @override
  String get turnServerUrlLabel => 'TURN servera URL';

  @override
  String get turnServerUrlHint => 'turn:jūsu-serveris.com:3478 vai turns:...';

  @override
  String get turnUsernameLabel => 'Lietotājvārds';

  @override
  String get turnPasswordLabel => 'Parole';

  @override
  String get turnOptionalHint => 'Neobligāts';

  @override
  String get turnCustomInfo =>
      'Uzstādiet coturn uz jebkura 5\$/mēn. VPS maksimālai kontrolei. Akreditācijas dati tiek glabāti lokāli.';

  @override
  String get themePickerAppearance => 'Izskats';

  @override
  String get themePickerAccentColor => 'Akcenta krāsa';

  @override
  String get themeModeLight => 'Gaišs';

  @override
  String get themeModeDark => 'Tumšs';

  @override
  String get themeModeSystem => 'Sistēmas';

  @override
  String get themeDynamicPresets => 'Iepriekšiestatījumi';

  @override
  String get themeDynamicPrimaryColor => 'Primārā krāsa';

  @override
  String get themeDynamicBorderRadius => 'Apmales rādiuss';

  @override
  String get themeDynamicFont => 'Fonts';

  @override
  String get themeDynamicAppearance => 'Izskats';

  @override
  String get themeDynamicUiStyle => 'UI stils';

  @override
  String get themeDynamicUiStyleDescription =>
      'Kontrolē, kā izskatās dialogi, slēdži un indikatori.';

  @override
  String get themeDynamicSharp => 'Ass';

  @override
  String get themeDynamicRound => 'Apaļš';

  @override
  String get themeDynamicModeDark => 'Tumšs';

  @override
  String get themeDynamicModeLight => 'Gaišs';

  @override
  String get themeDynamicModeAuto => 'Auto';

  @override
  String get themeDynamicPlatformAuto => 'Auto';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'Nederīgs Firebase URL. Paredzēts: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Nederīgs releja URL. Paredzēts: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Nederīgs Pulse servera URL. Paredzēts: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'Servera URL';

  @override
  String get providerPulseServerUrlHint => 'https://jūsu-serveris:8443';

  @override
  String get providerPulseInviteLabel => 'Ielūguma kods';

  @override
  String get providerPulseInviteHint => 'Ielūguma kods (ja nepieciešams)';

  @override
  String get providerPulseInfo =>
      'Pašmitināts relejs. Atslēgas atvasinātas no jūsu atjaunošanas paroles.';

  @override
  String get providerScreenTitle => 'Iesūtnes';

  @override
  String get providerSecondaryInboxesHeader => 'SEKUNDĀRĀS IESŪTNES';

  @override
  String get providerSecondaryInboxesInfo =>
      'Sekundārās iesūtnes vienlaicīgi saņem ziņas redundancei.';

  @override
  String get providerRemoveTooltip => 'Noņemt';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... vai hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... vai hex privātā atslēga';

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
  String get emojiNoRecent => 'Nav nesenu emocijzīmju';

  @override
  String get emojiSearchHint => 'Meklēt emocijzīmi...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Pieskarieties, lai sāktu sarunu';

  @override
  String get imageViewerSaveToDownloads => 'Saglabāt Lejupielādēs';

  @override
  String imageViewerSavedTo(String path) {
    return 'Saglabāts $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Valoda';

  @override
  String get settingsLanguageSubtitle => 'Lietotnes attēlošanas valoda';

  @override
  String get settingsLanguageSystem => 'Sistēmas noklusējums';

  @override
  String get onboardingLanguageTitle => 'Izvēlieties valodu';

  @override
  String get onboardingLanguageSubtitle =>
      'Jūs varat to mainīt vēlāk Iestatījumos';

  @override
  String get videoNoteRecord => 'Ierakstīt video ziņu';

  @override
  String get videoNoteTapToRecord => 'Pieskarieties, lai ierakstītu';

  @override
  String get videoNoteTapToStop => 'Pieskarieties, lai apturētu';

  @override
  String get videoNoteCameraPermission => 'Kameras atļauja liegta';

  @override
  String get videoNoteMaxDuration => 'Maksimāli 30 sekundes';

  @override
  String get videoNoteNotSupported =>
      'Video piezīmes netiek atbalstītas šajā platformā';

  @override
  String get navChats => 'Tērzēšanas';

  @override
  String get navUpdates => 'Atjauninājumi';

  @override
  String get navCalls => 'Zvani';

  @override
  String get filterAll => 'Visi';

  @override
  String get filterUnread => 'Nelasīti';

  @override
  String get filterGroups => 'Grupas';

  @override
  String get callsNoRecent => 'Nav nesenu zvanu';

  @override
  String get callsEmptySubtitle => 'Jūsu zvanu vēsture parādīsies šeit';

  @override
  String get appBarEncrypted => 'pilnībā šifrēts';

  @override
  String get newStatus => 'Jauns statuss';

  @override
  String get newCall => 'Jauns zvans';
}
