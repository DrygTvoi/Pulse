// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Hľadať v správach...';

  @override
  String get search => 'Hľadať';

  @override
  String get clearSearch => 'Vymazať vyhľadávanie';

  @override
  String get closeSearch => 'Zavrieť vyhľadávanie';

  @override
  String get moreOptions => 'Ďalšie možnosti';

  @override
  String get back => 'Späť';

  @override
  String get cancel => 'Zrušiť';

  @override
  String get close => 'Zavrieť';

  @override
  String get confirm => 'Potvrdiť';

  @override
  String get remove => 'Odstrániť';

  @override
  String get save => 'Uložiť';

  @override
  String get add => 'Pridať';

  @override
  String get copy => 'Kopírovať';

  @override
  String get skip => 'Preskočiť';

  @override
  String get done => 'Hotovo';

  @override
  String get apply => 'Použiť';

  @override
  String get export => 'Exportovať';

  @override
  String get import => 'Importovať';

  @override
  String get homeNewGroup => 'Nová skupina';

  @override
  String get homeSettings => 'Nastavenia';

  @override
  String get homeSearching => 'Vyhľadávanie správ...';

  @override
  String get homeNoResults => 'Nenašli sa žiadne výsledky';

  @override
  String get homeNoChatHistory => 'Zatiaľ žiadna história konverzácií';

  @override
  String homeTransportSwitched(String address) {
    return 'Transport prepnutý → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name volá...';
  }

  @override
  String get homeAccept => 'Prijať';

  @override
  String get homeDecline => 'Odmietnuť';

  @override
  String get homeLoadEarlier => 'Načítať staršie správy';

  @override
  String get homeChats => 'Konverzácie';

  @override
  String get homeSelectConversation => 'Vyberte konverzáciu';

  @override
  String get homeNoChatsYet => 'Zatiaľ žiadne konverzácie';

  @override
  String get homeAddContactToStart => 'Pridajte kontakt a začnite komunikovať';

  @override
  String get homeNewChat => 'Nová konverzácia';

  @override
  String get homeNewChatTooltip => 'Nová konverzácia';

  @override
  String get homeIncomingCallTitle => 'Prichádzajúci hovor';

  @override
  String get homeIncomingGroupCallTitle => 'Prichádzajúci skupinový hovor';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — prichádzajúci skupinový hovor';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Žiadne konverzácie zodpovedajúce \"$query\"';
  }

  @override
  String get homeSectionChats => 'Konverzácie';

  @override
  String get homeSectionMessages => 'Správy';

  @override
  String get homeDbEncryptionUnavailable =>
      'Šifrovanie databázy nie je dostupné — nainštalujte SQLCipher pre úplnú ochranu';

  @override
  String get chatFileTooLargeGroup =>
      'Súbory nad 512 KB nie sú v skupinových konverzáciách podporované';

  @override
  String get chatLargeFile => 'Veľký súbor';

  @override
  String get chatCancel => 'Zrušiť';

  @override
  String get chatSend => 'Odoslať';

  @override
  String get chatFileTooLarge =>
      'Súbor je príliš veľký — maximálna veľkosť je 100 MB';

  @override
  String get chatMicDenied => 'Prístup k mikrofónu zamietnutý';

  @override
  String get chatVoiceFailed =>
      'Nepodarilo sa uložiť hlasovú správu — skontrolujte dostupné úložisko';

  @override
  String get chatScheduleFuture => 'Naplánovaný čas musí byť v budúcnosti';

  @override
  String get chatToday => 'Dnes';

  @override
  String get chatYesterday => 'Včera';

  @override
  String get chatEdited => 'upravené';

  @override
  String get chatYou => 'Vy';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Tento súbor má $size MB. Odosielanie veľkých súborov môže byť v niektorých sieťach pomalé. Pokračovať?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Bezpečnostný kľúč kontaktu $name sa zmenil. Klepnite pre overenie.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Nepodarilo sa zašifrovať správu pre $name — správa nebola odoslaná.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Bezpečnostné číslo pre $name sa zmenilo. Klepnite pre overenie.';
  }

  @override
  String get chatNoMessagesFound => 'Nenašli sa žiadne správy';

  @override
  String get chatMessagesE2ee => 'Správy sú šifrované end-to-end';

  @override
  String get chatSayHello => 'Pozdravte sa';

  @override
  String get appBarOnline => 'online';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'píše';

  @override
  String get appBarSearchMessages => 'Hľadať v správach...';

  @override
  String get appBarMute => 'Stlmiť';

  @override
  String get appBarUnmute => 'Zrušiť stlmenie';

  @override
  String get appBarMedia => 'Médiá';

  @override
  String get appBarDisappearing => 'Miznúce správy';

  @override
  String get appBarDisappearingOn => 'Miznúce: zapnuté';

  @override
  String get appBarGroupSettings => 'Nastavenia skupiny';

  @override
  String get appBarSearchTooltip => 'Hľadať v správach';

  @override
  String get appBarVoiceCall => 'Hlasový hovor';

  @override
  String get appBarVideoCall => 'Videohovor';

  @override
  String get inputMessage => 'Správa...';

  @override
  String get inputAttachFile => 'Priložiť súbor';

  @override
  String get inputSendMessage => 'Odoslať správu';

  @override
  String get inputRecordVoice => 'Nahrať hlasovú správu';

  @override
  String get inputSendVoice => 'Odoslať hlasovú správu';

  @override
  String get inputCancelReply => 'Zrušiť odpoveď';

  @override
  String get inputCancelEdit => 'Zrušiť úpravu';

  @override
  String get inputCancelRecording => 'Zrušiť nahrávanie';

  @override
  String get inputRecording => 'Nahrávanie…';

  @override
  String get inputEditingMessage => 'Úprava správy';

  @override
  String get inputPhoto => 'Fotka';

  @override
  String get inputVoiceMessage => 'Hlasová správa';

  @override
  String get inputFile => 'Súbor';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ých správ',
      few: 'é správy',
      one: 'á správa',
    );
    return '$count naplánovan$_temp0';
  }

  @override
  String get callInitializing => 'Inicializácia hovoru…';

  @override
  String get callConnecting => 'Pripájanie…';

  @override
  String get callConnectingRelay => 'Pripájanie (relay)…';

  @override
  String get callSwitchingRelay => 'Prepínanie na relay režim…';

  @override
  String get callConnectionFailed => 'Pripojenie zlyhalo';

  @override
  String get callReconnecting => 'Opätovné pripájanie…';

  @override
  String get callEnded => 'Hovor ukončený';

  @override
  String get callLive => 'Naživo';

  @override
  String get callEnd => 'Koniec';

  @override
  String get callEndCall => 'Ukončiť hovor';

  @override
  String get callMute => 'Stlmiť';

  @override
  String get callUnmute => 'Zrušiť stlmenie';

  @override
  String get callSpeaker => 'Reproduktor';

  @override
  String get callCameraOn => 'Kamera zapnutá';

  @override
  String get callCameraOff => 'Kamera vypnutá';

  @override
  String get callShareScreen => 'Zdieľať obrazovku';

  @override
  String get callStopShare => 'Zastaviť zdieľanie';

  @override
  String callTorBackup(String duration) {
    return 'Tor záloha · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor záloha aktívna — primárna cesta nedostupná';

  @override
  String get callDirectFailed =>
      'Priame pripojenie zlyhalo — prepínanie na relay režim…';

  @override
  String get callTurnUnreachable =>
      'TURN servery sú nedostupné. Pridajte vlastný TURN server v Nastavenia → Rozšírené.';

  @override
  String get callRelayMode => 'Relay režim aktívny (obmedzená sieť)';

  @override
  String get callStarting => 'Spúšťanie hovoru…';

  @override
  String get callConnectingToGroup => 'Pripájanie ku skupine…';

  @override
  String get callGroupOpenedInBrowser =>
      'Skupinový hovor otvorený v prehliadači';

  @override
  String get callCouldNotOpenBrowser => 'Nepodarilo sa otvoriť prehliadač';

  @override
  String get callInviteLinkSent =>
      'Odkaz na pozvanie bol odoslaný všetkým členom skupiny.';

  @override
  String get callOpenLinkManually =>
      'Otvorte odkaz vyššie ručne alebo klepnite pre opakovanie.';

  @override
  String get callJitsiNotE2ee => 'Jitsi hovory NIE SÚ šifrované end-to-end';

  @override
  String get callRetryOpenBrowser => 'Znova otvoriť prehliadač';

  @override
  String get callClose => 'Zavrieť';

  @override
  String get callCamOn => 'Kamera zap.';

  @override
  String get callCamOff => 'Kamera vyp.';

  @override
  String get noConnection =>
      'Žiadne pripojenie — správy budú zaradené do fronty';

  @override
  String get connected => 'Pripojené';

  @override
  String get connecting => 'Pripájanie…';

  @override
  String get disconnected => 'Odpojené';

  @override
  String get offlineBanner =>
      'Žiadne pripojenie — správy budú odoslané po obnovení pripojenia';

  @override
  String get lanModeBanner => 'LAN režim — Bez internetu · Len lokálna sieť';

  @override
  String get probeCheckingNetwork => 'Kontrola sieťového pripojenia…';

  @override
  String get probeDiscoveringRelays =>
      'Vyhľadávanie relay serverov cez komunitné adresáre…';

  @override
  String get probeStartingTor => 'Spúšťanie Tor pre bootstrap…';

  @override
  String get probeFindingRelaysTor =>
      'Hľadanie dostupných relay serverov cez Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' serverov',
      one: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ých',
      one: 'ý',
    );
    return 'Sieť pripravená — $count relay$_temp0 nájden$_temp1';
  }

  @override
  String get probeNoRelaysFound =>
      'Nenašli sa žiadne dostupné relay servery — správy môžu byť oneskorené';

  @override
  String get jitsiWarningTitle => 'Nie je šifrované end-to-end';

  @override
  String get jitsiWarningBody =>
      'Hovory cez Jitsi Meet nie sú šifrované aplikáciou Pulse. Používajte len pre necitlivé konverzácie.';

  @override
  String get jitsiConfirm => 'Pripojiť sa aj tak';

  @override
  String get jitsiGroupWarningTitle => 'Nie je šifrované end-to-end';

  @override
  String get jitsiGroupWarningBody =>
      'Tento hovor má príliš veľa účastníkov pre vstavané šifrované prepojenie.\n\nOdkaz na Jitsi Meet sa otvorí vo vašom prehliadači. Jitsi NIE JE šifrované end-to-end — server môže vidieť váš hovor.';

  @override
  String get jitsiContinueAnyway => 'Pokračovať aj tak';

  @override
  String get retry => 'Skúsiť znova';

  @override
  String get setupCreateAnonymousAccount => 'Vytvoriť anonymný účet';

  @override
  String get setupTapToChangeColor => 'Klepnite pre zmenu farby';

  @override
  String get setupReqMinLength => 'Aspoň 16 znakov';

  @override
  String get setupReqVariety => '3 zo 4: veľké, malé písmená, číslice, symboly';

  @override
  String get setupReqMatch => 'Heslá sa zhodujú';

  @override
  String get setupYourNickname => 'Vaša prezývka';

  @override
  String get setupRecoveryPassword => 'Heslo na obnovenie (min. 16)';

  @override
  String get setupConfirmPassword => 'Potvrdiť heslo';

  @override
  String get setupMin16Chars => 'Minimálne 16 znakov';

  @override
  String get setupPasswordsDoNotMatch => 'Heslá sa nezhodujú';

  @override
  String get setupEntropyWeak => 'Slabé';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Silné';

  @override
  String get setupEntropyWeakNeedsVariety => 'Slabé (potrebné 3 typy znakov)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bitov)';
  }

  @override
  String get setupPasswordWarning =>
      'Toto heslo je jediný spôsob obnovenia vášho účtu. Neexistuje žiadny server — žiadny reset hesla. Zapamätajte si ho alebo si ho zapíšte.';

  @override
  String get setupCreateAccount => 'Vytvoriť účet';

  @override
  String get setupAlreadyHaveAccount => 'Už máte účet? ';

  @override
  String get setupRestore => 'Obnoviť →';

  @override
  String get restoreTitle => 'Obnoviť účet';

  @override
  String get restoreInfoBanner =>
      'Zadajte svoje heslo na obnovenie — vaša adresa (Nostr + Session) bude obnovená automaticky. Kontakty a správy boli uložené len lokálne.';

  @override
  String get restoreNewNickname => 'Nová prezývka (môžete zmeniť neskôr)';

  @override
  String get restoreButton => 'Obnoviť účet';

  @override
  String get lockTitle => 'Pulse je zamknutý';

  @override
  String get lockSubtitle => 'Zadajte heslo pre pokračovanie';

  @override
  String get lockPasswordHint => 'Heslo';

  @override
  String get lockUnlock => 'Odomknúť';

  @override
  String get lockPanicHint =>
      'Zabudli ste heslo? Zadajte panický kľúč pre vymazanie všetkých dát.';

  @override
  String get lockTooManyAttempts =>
      'Príliš veľa pokusov. Mazanie všetkých dát…';

  @override
  String get lockWrongPassword => 'Nesprávne heslo';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Nesprávne heslo — $attempts/$max pokusov';
  }

  @override
  String get onboardingSkip => 'Preskočiť';

  @override
  String get onboardingNext => 'Ďalej';

  @override
  String get onboardingGetStarted => 'Začať';

  @override
  String get onboardingWelcomeTitle => 'Vitajte v Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Decentralizovaný messenger so šifrovaním end-to-end.\n\nŽiadne centrálne servery. Žiadny zber dát. Žiadne zadné dvierka.\nVaše konverzácie patria len vám.';

  @override
  String get onboardingTransportTitle => 'Nezávislý na transporte';

  @override
  String get onboardingTransportBody =>
      'Používajte Firebase, Nostr alebo oboje súčasne.\n\nSprávy sa automaticky smerujú cez siete. Vstavaná podpora Tor a I2P pre odolnosť voči cenzúre.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Každá správa je šifrovaná protokolom Signal (Double Ratchet + X3DH) pre dopredné utajenie.\n\nNavyše obalená Kyber-1024 — NIST štandardným post-kvantovým algoritmom — ochrana pred budúcimi kvantovými počítačmi.';

  @override
  String get onboardingKeysTitle => 'Vaše kľúče sú vaše';

  @override
  String get onboardingKeysBody =>
      'Vaše identitné kľúče nikdy neopustia vaše zariadenie.\n\nSignal odtlačky vám umožňujú overenie kontaktov mimo pásma. TOFU (Trust On First Use) automaticky deteguje zmeny kľúčov.';

  @override
  String get onboardingThemeTitle => 'Vyberte si vzhľad';

  @override
  String get onboardingThemeBody =>
      'Vyberte si tému a farbu zvýraznenia. Kedykoľvek to môžete zmeniť v Nastaveniach.';

  @override
  String get contactsNewChat => 'Nová konverzácia';

  @override
  String get contactsAddContact => 'Pridať kontakt';

  @override
  String get contactsSearchHint => 'Hľadať...';

  @override
  String get contactsNewGroup => 'Nová skupina';

  @override
  String get contactsNoContactsYet => 'Zatiaľ žiadne kontakty';

  @override
  String get contactsAddHint => 'Klepnite na + pre pridanie adresy';

  @override
  String get contactsNoMatch => 'Žiadne zodpovedajúce kontakty';

  @override
  String get contactsRemoveTitle => 'Odstrániť kontakt';

  @override
  String contactsRemoveMessage(String name) {
    return 'Odstrániť $name?';
  }

  @override
  String get contactsRemove => 'Odstrániť';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ov',
      few: 'y',
      one: '',
    );
    return '$count kontakt$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Otvoriť odkaz';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Otvoriť túto URL v prehliadači?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Otvoriť';

  @override
  String get bubbleSecurityWarning => 'Bezpečnostné varovanie';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" je spustiteľný typ súboru. Uloženie a spustenie môže poškodiť vaše zariadenie. Napriek tomu uložiť?';
  }

  @override
  String get bubbleSaveAnyway => 'Napriek tomu uložiť';

  @override
  String bubbleSavedTo(String path) {
    return 'Uložené do $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Uloženie zlyhalo: $error';
  }

  @override
  String get bubbleNotEncrypted => 'NEŠIFROVANÉ';

  @override
  String get bubbleCorruptedImage => '[Poškodený obrázok]';

  @override
  String get bubbleReplyPhoto => 'Fotka';

  @override
  String get bubbleReplyVoice => 'Hlasová správa';

  @override
  String get bubbleReplyVideo => 'Video správa';

  @override
  String bubbleReadBy(String names) {
    return 'Prečítané: $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Prečítané: $count';
  }

  @override
  String get chatTileTapToStart => 'Klepnite pre začatie konverzácie';

  @override
  String get chatTileMessageSent => 'Správa odoslaná';

  @override
  String get chatTileEncryptedMessage => 'Šifrovaná správa';

  @override
  String chatTileYouPrefix(String text) {
    return 'Vy: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Hlasová správa';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Hlasová správa ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Šifrovaná správa';

  @override
  String get groupNewGroup => 'Nová skupina';

  @override
  String get groupGroupName => 'Názov skupiny';

  @override
  String get groupSelectMembers => 'Vyberte členov (min. 2)';

  @override
  String get groupNoContactsYet =>
      'Zatiaľ žiadne kontakty. Najprv pridajte kontakty.';

  @override
  String get groupCreate => 'Vytvoriť';

  @override
  String get groupLabel => 'Skupina';

  @override
  String get profileVerifyIdentity => 'Overiť identitu';

  @override
  String profileVerifyInstructions(String name) {
    return 'Porovnajte tieto odtlačky s kontaktom $name počas hlasového hovoru alebo osobne. Ak sa obe hodnoty zhodujú na oboch zariadeniach, klepnite na „Označiť ako overené“.';
  }

  @override
  String get profileTheirKey => 'Ich kľúč';

  @override
  String get profileYourKey => 'Váš kľúč';

  @override
  String get profileRemoveVerification => 'Odstrániť overenie';

  @override
  String get profileMarkAsVerified => 'Označiť ako overené';

  @override
  String get profileAddressCopied => 'Adresa skopírovaná';

  @override
  String get profileNoContactsToAdd =>
      'Žiadne kontakty na pridanie — všetci sú už členmi';

  @override
  String get profileAddMembers => 'Pridať členov';

  @override
  String profileAddCount(int count) {
    return 'Pridať ($count)';
  }

  @override
  String get profileRenameGroup => 'Premenovať skupinu';

  @override
  String get profileRename => 'Premenovať';

  @override
  String get profileRemoveMember => 'Odstrániť člena?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Odstrániť $name z tejto skupiny?';
  }

  @override
  String get profileKick => 'Vyhodiť';

  @override
  String get profileSignalFingerprints => 'Signal odtlačky';

  @override
  String get profileVerified => 'OVERENÉ';

  @override
  String get profileVerify => 'Overiť';

  @override
  String get profileEdit => 'Upraviť';

  @override
  String get profileNoSession =>
      'Zatiaľ nebola nadviazaná žiadna relácia — najprv pošlite správu.';

  @override
  String get profileFingerprintCopied => 'Odtlačok skopírovaný';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ov',
      few: 'ovia',
      one: '',
    );
    return '$count člen$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Overiť bezpečnostné číslo';

  @override
  String get profileShowContactQr => 'Zobraziť QR kontaktu';

  @override
  String profileContactAddress(String name) {
    return 'Adresa kontaktu $name';
  }

  @override
  String get profileExportChatHistory => 'Exportovať históriu konverzácie';

  @override
  String profileSavedTo(String path) {
    return 'Uložené do $path';
  }

  @override
  String get profileExportFailed => 'Export zlyhal';

  @override
  String get profileClearChatHistory => 'Vymazať históriu konverzácie';

  @override
  String get profileDeleteGroup => 'Zmazať skupinu';

  @override
  String get profileDeleteContact => 'Zmazať kontakt';

  @override
  String get profileLeaveGroup => 'Opustiť skupinu';

  @override
  String get profileLeaveGroupBody =>
      'Budete odstránený z tejto skupiny a bude vymazaná z vašich kontaktov.';

  @override
  String get groupInviteTitle => 'Pozvanie do skupiny';

  @override
  String groupInviteBody(String from, String group) {
    return '$from vás pozval do skupiny \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Prijať';

  @override
  String get groupInviteDecline => 'Odmietnuť';

  @override
  String get groupMemberLimitTitle => 'Príliš veľa účastníkov';

  @override
  String groupMemberLimitBody(int count) {
    return 'Táto skupina bude mať $count účastníkov. Šifrované mesh hovory podporujú maximálne 6. Väčšie skupiny prejdú na Jitsi (nie E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Pridať aj tak';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name odmietol pozvanie do skupiny \"$group\"';
  }

  @override
  String get transferTitle => 'Prenos na iné zariadenie';

  @override
  String get transferInfoBox =>
      'Preneste svoju Signal identitu a Nostr kľúče na nové zariadenie.\nRelácie konverzácií sa NEPRENÁŠAJÚ — dopredné utajenie je zachované.';

  @override
  String get transferSendFromThis => 'Odoslať z tohto zariadenia';

  @override
  String get transferSendSubtitle =>
      'Toto zariadenie má kľúče. Zdieľajte kód s novým zariadením.';

  @override
  String get transferReceiveOnThis => 'Prijať na tomto zariadení';

  @override
  String get transferReceiveSubtitle =>
      'Toto je nové zariadenie. Zadajte kód zo starého zariadenia.';

  @override
  String get transferChooseMethod => 'Zvoľte spôsob prenosu';

  @override
  String get transferLan => 'LAN (rovnaká sieť)';

  @override
  String get transferLanSubtitle =>
      'Rýchle a priame. Obe zariadenia musia byť v rovnakej Wi-Fi sieti.';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'Funguje cez akúkoľvek sieť pomocou existujúceho Nostr relay.';

  @override
  String get transferRelayUrl => 'URL relay servera';

  @override
  String get transferEnterCode => 'Zadajte prenosový kód';

  @override
  String get transferPasteCode => 'Prilepte kód LAN:... alebo NOS:... sem';

  @override
  String get transferConnect => 'Pripojiť';

  @override
  String get transferGenerating => 'Generovanie prenosového kódu…';

  @override
  String get transferShareCode => 'Zdieľajte tento kód s príjemcom:';

  @override
  String get transferCopyCode => 'Kopírovať kód';

  @override
  String get transferCodeCopied => 'Kód skopírovaný do schránky';

  @override
  String get transferWaitingReceiver => 'Čakanie na pripojenie príjemcu…';

  @override
  String get transferConnectingSender => 'Pripájanie k odosielateľovi…';

  @override
  String get transferVerifyBoth =>
      'Porovnajte tento kód na oboch zariadeniach.\nAk sa zhodujú, prenos je bezpečný.';

  @override
  String get transferComplete => 'Prenos dokončený';

  @override
  String get transferKeysImported => 'Kľúče importované';

  @override
  String get transferCompleteSenderBody =>
      'Vaše kľúče zostávajú aktívne na tomto zariadení.\nPríjemca teraz môže používať vašu identitu.';

  @override
  String get transferCompleteReceiverBody =>
      'Kľúče úspešne importované.\nReštartujte aplikáciu pre použitie novej identity.';

  @override
  String get transferRestartApp => 'Reštartovať aplikáciu';

  @override
  String get transferFailed => 'Prenos zlyhal';

  @override
  String get transferTryAgain => 'Skúsiť znova';

  @override
  String get transferEnterRelayFirst => 'Najprv zadajte URL relay servera';

  @override
  String get transferPasteCodeFromSender =>
      'Prilepte prenosový kód od odosielateľa';

  @override
  String get menuReply => 'Odpovedať';

  @override
  String get menuForward => 'Preposlať';

  @override
  String get menuReact => 'Reagovať';

  @override
  String get menuCopy => 'Kopírovať';

  @override
  String get menuEdit => 'Upraviť';

  @override
  String get menuRetry => 'Skúsiť znova';

  @override
  String get menuCancelScheduled => 'Zrušiť naplánované';

  @override
  String get menuDelete => 'Zmazať';

  @override
  String get menuForwardTo => 'Preposlať komu…';

  @override
  String menuForwardedTo(String name) {
    return 'Preposlané kontaktu $name';
  }

  @override
  String get menuScheduledMessages => 'Naplánované správy';

  @override
  String get menuNoScheduledMessages => 'Žiadne naplánované správy';

  @override
  String menuSendsOn(String date) {
    return 'Odošle sa $date';
  }

  @override
  String get menuDisappearingMessages => 'Miznúce správy';

  @override
  String get menuDisappearingSubtitle =>
      'Správy sa automaticky zmažú po zvolenom čase.';

  @override
  String get menuTtlOff => 'Vyp.';

  @override
  String get menuTtl1h => '1 hodina';

  @override
  String get menuTtl24h => '24 hodín';

  @override
  String get menuTtl7d => '7 dní';

  @override
  String get menuAttachPhoto => 'Fotka';

  @override
  String get menuAttachFile => 'Súbor';

  @override
  String get menuAttachVideo => 'Video';

  @override
  String get mediaTitle => 'Médiá';

  @override
  String get mediaFileLabel => 'SÚBOR';

  @override
  String mediaPhotosTab(int count) {
    return 'Fotky ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Súbory ($count)';
  }

  @override
  String get mediaNoPhotos => 'Zatiaľ žiadne fotky';

  @override
  String get mediaNoFiles => 'Zatiaľ žiadne súbory';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Uložené do Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'Nepodarilo sa uložiť súbor';

  @override
  String get statusNewStatus => 'Nový status';

  @override
  String get statusPublish => 'Publikovať';

  @override
  String get statusExpiresIn24h => 'Status vyprší za 24 hodín';

  @override
  String get statusWhatsOnYourMind => 'Čo máte na mysli?';

  @override
  String get statusPhotoAttached => 'Fotka priložená';

  @override
  String get statusAttachPhoto => 'Priložiť fotku (voliteľné)';

  @override
  String get statusEnterText => 'Prosím zadajte text pre váš status.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Nepodarilo sa vybrať fotku: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Publikovanie zlyhalo: $error';
  }

  @override
  String get panicSetPanicKey => 'Nastaviť panický kľúč';

  @override
  String get panicEmergencySelfDestruct => 'Núdzová sebalikvidácia';

  @override
  String get panicIrreversible => 'Táto akcia je nezvratná';

  @override
  String get panicWarningBody =>
      'Zadanie tohto kľúča na zamykacej obrazovke okamžite vymaže VŠETKY dáta — správy, kontakty, kľúče, identitu. Použite iný kľúč ako vaše bežné heslo.';

  @override
  String get panicKeyHint => 'Panický kľúč';

  @override
  String get panicConfirmHint => 'Potvrdiť panický kľúč';

  @override
  String get panicMinChars => 'Panický kľúč musí mať aspoň 8 znakov';

  @override
  String get panicKeysDoNotMatch => 'Kľúče sa nezhodujú';

  @override
  String get panicSetFailed =>
      'Nepodarilo sa uložiť panický kľúč — skúste to znova';

  @override
  String get passwordSetAppPassword => 'Nastaviť heslo aplikácie';

  @override
  String get passwordProtectsMessages => 'Chráni vaše správy v pokoji';

  @override
  String get passwordInfoBanner =>
      'Vyžaduje sa pri každom otvorení Pulse. Ak ho zabudnete, vaše dáta nemožno obnoviť.';

  @override
  String get passwordHint => 'Heslo';

  @override
  String get passwordConfirmHint => 'Potvrdiť heslo';

  @override
  String get passwordSetButton => 'Nastaviť heslo';

  @override
  String get passwordSkipForNow => 'Zatiaľ preskočiť';

  @override
  String get passwordMinChars => 'Heslo musí mať aspoň 6 znakov';

  @override
  String get passwordsDoNotMatch => 'Heslá sa nezhodujú';

  @override
  String get profileCardSaved => 'Profil uložený!';

  @override
  String get profileCardE2eeIdentity => 'E2EE identita';

  @override
  String get profileCardDisplayName => 'Zobrazované meno';

  @override
  String get profileCardDisplayNameHint => 'napr. Ján Novák';

  @override
  String get profileCardAbout => 'O mne';

  @override
  String get profileCardSaveProfile => 'Uložiť profil';

  @override
  String get profileCardYourName => 'Vaše meno';

  @override
  String get profileCardAddressCopied => 'Adresa skopírovaná!';

  @override
  String get profileCardInboxAddress => 'Vaša adresa schránky';

  @override
  String get profileCardInboxAddresses => 'Vaše adresy schránky';

  @override
  String get profileCardShareAllAddresses =>
      'Zdieľať všetky adresy (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Zdieľajte s kontaktmi, aby vám mohli písať.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Všetkých $count adries skopírovaných ako jeden odkaz!';
  }

  @override
  String get settingsMyProfile => 'Môj profil';

  @override
  String get settingsYourInboxAddress => 'Vaša adresa schránky';

  @override
  String get settingsMyQrCode => 'Môj QR kód';

  @override
  String get settingsMyQrSubtitle => 'Zdieľajte adresu ako skenovateľný QR kód';

  @override
  String get settingsShareMyAddress => 'Zdieľať moju adresu';

  @override
  String get settingsNoAddressYet =>
      'Zatiaľ žiadna adresa — najprv uložte nastavenia';

  @override
  String get settingsInviteLink => 'Odkaz na pozvanie';

  @override
  String get settingsRawAddress => 'Surová adresa';

  @override
  String get settingsCopyLink => 'Kopírovať odkaz';

  @override
  String get settingsCopyAddress => 'Kopírovať adresu';

  @override
  String get settingsInviteLinkCopied => 'Odkaz na pozvanie skopírovaný';

  @override
  String get settingsAppearance => 'Vzhľad';

  @override
  String get settingsThemeEngine => 'Téma';

  @override
  String get settingsThemeEngineSubtitle => 'Prispôsobte farby a písma';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle => 'E2EE kľúče sú bezpečne uložené';

  @override
  String get settingsActive => 'AKTÍVNE';

  @override
  String get settingsIdentityBackup => 'Záloha identity';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Exportujte alebo importujte svoju Signal identitu';

  @override
  String get settingsIdentityBackupBody =>
      'Exportujte svoje Signal identitné kľúče do zálohovacieho kódu alebo ich obnovte z existujúceho.';

  @override
  String get settingsTransferDevice => 'Prenos na iné zariadenie';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Preneste identitu cez LAN alebo Nostr relay';

  @override
  String get settingsExportIdentity => 'Exportovať identitu';

  @override
  String get settingsExportIdentityBody =>
      'Skopírujte tento zálohovací kód a uložte ho na bezpečné miesto:';

  @override
  String get settingsSaveFile => 'Uložiť súbor';

  @override
  String get settingsImportIdentity => 'Importovať identitu';

  @override
  String get settingsImportIdentityBody =>
      'Prilepte zálohovací kód nižšie. Prepíše vašu aktuálnu identitu.';

  @override
  String get settingsPasteBackupCode => 'Prilepte zálohovací kód sem…';

  @override
  String get settingsIdentityImported =>
      'Identita + kontakty importované! Reštartujte aplikáciu pre použitie.';

  @override
  String get settingsSecurity => 'Zabezpečenie';

  @override
  String get settingsAppPassword => 'Heslo aplikácie';

  @override
  String get settingsPasswordEnabled =>
      'Zapnuté — vyžaduje sa pri každom spustení';

  @override
  String get settingsPasswordDisabled =>
      'Vypnuté — aplikácia sa otvára bez hesla';

  @override
  String get settingsChangePassword => 'Zmeniť heslo';

  @override
  String get settingsChangePasswordSubtitle =>
      'Aktualizovať zamykacie heslo aplikácie';

  @override
  String get settingsSetPanicKey => 'Nastaviť panický kľúč';

  @override
  String get settingsChangePanicKey => 'Zmeniť panický kľúč';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Aktualizovať kľúč núdzového vymazania';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Jeden kľúč, ktorý okamžite vymaže všetky dáta';

  @override
  String get settingsRemovePanicKey => 'Odstrániť panický kľúč';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Deaktivovať núdzovú sebalikvidáciu';

  @override
  String get settingsRemovePanicKeyBody =>
      'Núdzová sebalikvidácia bude deaktivovaná. Kedykoľvek ju môžete znova aktivovať.';

  @override
  String get settingsDisableAppPassword => 'Vypnúť heslo aplikácie';

  @override
  String get settingsEnterCurrentPassword =>
      'Zadajte aktuálne heslo pre potvrdenie';

  @override
  String get settingsCurrentPassword => 'Aktuálne heslo';

  @override
  String get settingsIncorrectPassword => 'Nesprávne heslo';

  @override
  String get settingsPasswordUpdated => 'Heslo aktualizované';

  @override
  String get settingsChangePasswordProceed =>
      'Zadajte aktuálne heslo pre pokračovanie';

  @override
  String get settingsData => 'Dáta';

  @override
  String get settingsBackupMessages => 'Zálohovať správy';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Exportovať šifrovanú históriu správ do súboru';

  @override
  String get settingsRestoreMessages => 'Obnoviť správy';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Importovať správy zo zálohovacieho súboru';

  @override
  String get settingsExportKeys => 'Exportovať kľúče';

  @override
  String get settingsExportKeysSubtitle =>
      'Uložiť identitné kľúče do šifrovaného súboru';

  @override
  String get settingsImportKeys => 'Importovať kľúče';

  @override
  String get settingsImportKeysSubtitle =>
      'Obnoviť identitné kľúče z exportovaného súboru';

  @override
  String get settingsBackupPassword => 'Heslo zálohy';

  @override
  String get settingsPasswordCannotBeEmpty => 'Heslo nemôže byť prázdne';

  @override
  String get settingsPasswordMin4Chars => 'Heslo musí mať aspoň 4 znaky';

  @override
  String get settingsCallsTurn => 'Hovory a TURN';

  @override
  String get settingsLocalNetwork => 'Lokálna sieť';

  @override
  String get settingsCensorshipResistance => 'Odolnosť voči cenzúre';

  @override
  String get settingsNetwork => 'Sieť';

  @override
  String get settingsProxyTunnels => 'Proxy a tunely';

  @override
  String get settingsTurnServers => 'TURN servery';

  @override
  String get settingsProviderTitle => 'Poskytovateľ';

  @override
  String get settingsLanFallback => 'LAN záloha';

  @override
  String get settingsLanFallbackSubtitle =>
      'Vysielať prítomnosť a doručovať správy v lokálnej sieti, keď nie je dostupný internet. Vypnite v nedôveryhodných sieťach (verejná Wi-Fi).';

  @override
  String get settingsBgDelivery => 'Doručovanie na pozadí';

  @override
  String get settingsBgDeliverySubtitle =>
      'Pokračovať v prijímaní správ, keď je aplikácia minimalizovaná. Zobrazí trvalé upozornenie.';

  @override
  String get settingsYourInboxProvider => 'Váš poskytovateľ schránky';

  @override
  String get settingsConnectionDetails => 'Podrobnosti pripojenia';

  @override
  String get settingsSaveAndConnect => 'Uložiť a pripojiť';

  @override
  String get settingsSecondaryInboxes => 'Sekundárne schránky';

  @override
  String get settingsAddSecondaryInbox => 'Pridať sekundárnu schránku';

  @override
  String get settingsAdvanced => 'Rozšírené';

  @override
  String get settingsDiscover => 'Vyhľadať';

  @override
  String get settingsAbout => 'O aplikácii';

  @override
  String get settingsPrivacyPolicy => 'Zásady ochrany súkromia';

  @override
  String get settingsPrivacyPolicySubtitle => 'Ako Pulse chráni vaše dáta';

  @override
  String get settingsCrashReporting => 'Hlásenie pádov';

  @override
  String get settingsCrashReportingSubtitle =>
      'Odosielať anonymné hlásenia o pádoch pre vylepšenie Pulse. Žiadny obsah správ ani kontakty nie sú nikdy odosielané.';

  @override
  String get settingsCrashReportingEnabled =>
      'Hlásenie pádov zapnuté — reštartujte aplikáciu pre použitie';

  @override
  String get settingsCrashReportingDisabled =>
      'Hlásenie pádov vypnuté — reštartujte aplikáciu pre použitie';

  @override
  String get settingsSensitiveOperation => 'Citlivá operácia';

  @override
  String get settingsSensitiveOperationBody =>
      'Tieto kľúče sú vaša identita. Ktokoľvek s týmto súborom sa môže za vás vydávať. Uložte ho bezpečne a po prenose ho vymažte.';

  @override
  String get settingsIUnderstandContinue => 'Rozumiem, pokračovať';

  @override
  String get settingsReplaceIdentity => 'Nahradiť identitu?';

  @override
  String get settingsReplaceIdentityBody =>
      'Toto prepíše vaše aktuálne identitné kľúče. Vaše existujúce Signal relácie budú zneplatnené a kontakty budú musieť znova nadviazať šifrovanie. Aplikácia sa bude musieť reštartovať.';

  @override
  String get settingsReplaceKeys => 'Nahradiť kľúče';

  @override
  String get settingsKeysImported => 'Kľúče importované';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count kľúčov úspešne importovaných. Prosím reštartujte aplikáciu pre inicializáciu s novou identitou.';
  }

  @override
  String get settingsRestartNow => 'Reštartovať teraz';

  @override
  String get settingsLater => 'Neskôr';

  @override
  String get profileGroupLabel => 'Skupina';

  @override
  String get profileAddButton => 'Pridať';

  @override
  String get profileKickButton => 'Vyhodiť';

  @override
  String get dataSectionTitle => 'Dáta';

  @override
  String get dataBackupMessages => 'Zálohovať správy';

  @override
  String get dataBackupPasswordSubtitle =>
      'Zvoľte heslo na šifrovanie zálohy správ.';

  @override
  String get dataBackupConfirmLabel => 'Vytvoriť zálohu';

  @override
  String get dataCreatingBackup => 'Vytváranie zálohy';

  @override
  String get dataBackupPreparing => 'Príprava...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Export správy $done z $total...';
  }

  @override
  String get dataBackupSavingFile => 'Ukladanie súboru...';

  @override
  String get dataSaveMessageBackupDialog => 'Uložiť zálohu správ';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Záloha uložená ($count správ)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Zálohovanie zlyhalo — žiadne dáta neboli exportované';

  @override
  String dataBackupFailedError(String error) {
    return 'Zálohovanie zlyhalo: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Vybrať zálohu správ';

  @override
  String get dataInvalidBackupFile => 'Neplatný zálohovací súbor (príliš malý)';

  @override
  String get dataNotValidBackupFile => 'Neplatný zálohovací súbor Pulse';

  @override
  String get dataRestoreMessages => 'Obnoviť správy';

  @override
  String get dataRestorePasswordSubtitle =>
      'Zadajte heslo, ktoré bolo použité na vytvorenie tejto zálohy.';

  @override
  String get dataRestoreConfirmLabel => 'Obnoviť';

  @override
  String get dataRestoringMessages => 'Obnovovanie správ';

  @override
  String get dataRestoreDecrypting => 'Dešifrovanie...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Import správy $done z $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Obnovenie zlyhalo — nesprávne heslo alebo poškodený súbor';

  @override
  String dataRestoreSuccess(int count) {
    return 'Obnovených $count nových správ';
  }

  @override
  String get dataRestoreNothingNew =>
      'Žiadne nové správy na import (všetky už existujú)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Obnovenie zlyhalo: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Vybrať export kľúčov';

  @override
  String get dataNotValidKeyFile => 'Neplatný súbor exportu kľúčov Pulse';

  @override
  String get dataExportKeys => 'Exportovať kľúče';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Zvoľte heslo na šifrovanie exportu kľúčov.';

  @override
  String get dataExportKeysConfirmLabel => 'Exportovať';

  @override
  String get dataExportingKeys => 'Export kľúčov';

  @override
  String get dataExportingKeysStatus => 'Šifrovanie identitných kľúčov...';

  @override
  String get dataSaveKeyExportDialog => 'Uložiť export kľúčov';

  @override
  String dataKeysExportedTo(String path) {
    return 'Kľúče exportované do:\n$path';
  }

  @override
  String get dataExportFailed => 'Export zlyhal — žiadne kľúče neboli nájdené';

  @override
  String dataExportFailedError(String error) {
    return 'Export zlyhal: $error';
  }

  @override
  String get dataImportKeys => 'Importovať kľúče';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Zadajte heslo, ktoré bolo použité na šifrovanie tohto exportu kľúčov.';

  @override
  String get dataImportKeysConfirmLabel => 'Importovať';

  @override
  String get dataImportingKeys => 'Import kľúčov';

  @override
  String get dataImportingKeysStatus => 'Dešifrovanie identitných kľúčov...';

  @override
  String get dataImportFailed =>
      'Import zlyhal — nesprávne heslo alebo poškodený súbor';

  @override
  String dataImportFailedError(String error) {
    return 'Import zlyhal: $error';
  }

  @override
  String get securitySectionTitle => 'Zabezpečenie';

  @override
  String get securityIncorrectPassword => 'Nesprávne heslo';

  @override
  String get securityPasswordUpdated => 'Heslo aktualizované';

  @override
  String get appearanceSectionTitle => 'Vzhľad';

  @override
  String appearanceExportFailed(String error) {
    return 'Export zlyhal: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Uložené do $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Uloženie zlyhalo: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Import zlyhal: $error';
  }

  @override
  String get aboutSectionTitle => 'O aplikácii';

  @override
  String get providerPublicKey => 'Verejný kľúč';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Automaticky nakonfigurované z vášho hesla na obnovenie. Relay automaticky objavený.';

  @override
  String get providerKeyStoredLocally =>
      'Váš kľúč je uložený lokálne v bezpečnom úložisku — nikdy nie je odoslaný na žiadny server.';

  @override
  String get providerSessionInfo =>
      'Session Network — E2EE s cibuľovým smerovaním. Vaše Session ID sa generuje automaticky a bezpečne sa ukladá. Uzly sa automaticky objavujú z vstavaných základných uzlov.';

  @override
  String get providerAdvanced => 'Rozšírené';

  @override
  String get providerSaveAndConnect => 'Uložiť a pripojiť';

  @override
  String get providerAddSecondaryInbox => 'Pridať sekundárnu schránku';

  @override
  String get providerSecondaryInboxes => 'Sekundárne schránky';

  @override
  String get providerYourInboxProvider => 'Váš poskytovateľ schránky';

  @override
  String get providerConnectionDetails => 'Podrobnosti pripojenia';

  @override
  String get addContactTitle => 'Pridať kontakt';

  @override
  String get addContactInviteLinkLabel => 'Odkaz na pozvanie alebo adresa';

  @override
  String get addContactTapToPaste =>
      'Klepnite pre prilepenie odkazu na pozvanie';

  @override
  String get addContactPasteTooltip => 'Prilepiť zo schránky';

  @override
  String get addContactAddressDetected => 'Adresa kontaktu rozpoznaná';

  @override
  String addContactRoutesDetected(int count) {
    return '$count trás rozpoznaných — SmartRouter vyberie najrýchlejšiu';
  }

  @override
  String get addContactFetchingProfile => 'Získavanie profilu…';

  @override
  String addContactProfileFound(String name) {
    return 'Nájdené: $name';
  }

  @override
  String get addContactNoProfileFound => 'Profil nebol nájdený';

  @override
  String get addContactDisplayNameLabel => 'Zobrazované meno';

  @override
  String get addContactDisplayNameHint => 'Ako ich chcete volať?';

  @override
  String get addContactAddManually => 'Zadať adresu ručne';

  @override
  String get addContactButton => 'Pridať kontakt';

  @override
  String get networkDiagnosticsTitle => 'Diagnostika siete';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr relay servery';

  @override
  String get networkDiagnosticsDirect => 'Priame';

  @override
  String get networkDiagnosticsTorOnly => 'Len Tor';

  @override
  String get networkDiagnosticsBest => 'Najlepší';

  @override
  String get networkDiagnosticsNone => 'žiadny';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Stav';

  @override
  String get networkDiagnosticsConnected => 'Pripojené';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Pripájanie $percent %';
  }

  @override
  String get networkDiagnosticsOff => 'Vypnuté';

  @override
  String get networkDiagnosticsTransport => 'Transport';

  @override
  String get networkDiagnosticsInfrastructure => 'Infraštruktúra';

  @override
  String get networkDiagnosticsSessionNodes => 'Session uzly';

  @override
  String get networkDiagnosticsTurnServers => 'TURN servery';

  @override
  String get networkDiagnosticsLastProbe => 'Posledná kontrola';

  @override
  String get networkDiagnosticsRunning => 'Prebieha...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Spustiť diagnostiku';

  @override
  String get networkDiagnosticsForceReprobe =>
      'Vynútiť úplnú opätovnú kontrolu';

  @override
  String get networkDiagnosticsJustNow => 'práve teraz';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'pred $minutes min.';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'pred $hours hod.';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'pred $days d.';
  }

  @override
  String get homeNoEch => 'Bez ECH';

  @override
  String get homeNoEchTooltip =>
      'uTLS proxy nedostupný — ECH vypnuté.\nTLS odtlačok je viditeľný pre DPI.';

  @override
  String get settingsTitle => 'Nastavenia';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Uložené a pripojené k $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Vstavaný Tor sa nepodarilo spustiť';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon sa nepodarilo spustiť';

  @override
  String get verifyTitle => 'Overiť bezpečnostné číslo';

  @override
  String get verifyIdentityVerified => 'Identita overená';

  @override
  String get verifyNotYetVerified => 'Zatiaľ neoverené';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Overili ste bezpečnostné číslo kontaktu $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Porovnajte tieto čísla s kontaktom $name osobne alebo cez dôveryhodný kanál.';
  }

  @override
  String get verifyExplanation =>
      'Každá konverzácia má jedinečné bezpečnostné číslo. Ak obaja vidíte rovnaké čísla na svojich zariadeniach, vaše spojenie je overené end-to-end.';

  @override
  String verifyContactKey(String name) {
    return 'Kľúč kontaktu $name';
  }

  @override
  String get verifyYourKey => 'Váš kľúč';

  @override
  String get verifyRemoveVerification => 'Odstrániť overenie';

  @override
  String get verifyMarkAsVerified => 'Označiť ako overené';

  @override
  String verifyAfterReinstall(String name) {
    return 'Ak $name preinštaluje aplikáciu, bezpečnostné číslo sa zmení a overenie bude automaticky odstránené.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Identitu označte ako overenú až po porovnaní čísel s kontaktom $name počas hlasového hovoru alebo osobne.';
  }

  @override
  String get verifyNoSession =>
      'Zatiaľ nebola nadviazaná žiadna šifrovacia relácia. Najprv pošlite správu pre vygenerovanie bezpečnostných čísel.';

  @override
  String get verifyNoKeyAvailable => 'Kľúč nie je dostupný';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Odtlačok $label skopírovaný';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL databázy';

  @override
  String get providerOptionalHint => 'Voliteľné';

  @override
  String get providerWebApiKeyLabel => 'Web API kľúč';

  @override
  String get providerOptionalForPublicDb => 'Voliteľné pre verejnú databázu';

  @override
  String get providerRelayUrlLabel => 'URL relay servera';

  @override
  String get providerPrivateKeyLabel => 'Súkromný kľúč';

  @override
  String get providerPrivateKeyNsecLabel => 'Súkromný kľúč (nsec)';

  @override
  String get providerStorageNodeLabel => 'URL úložného uzla (voliteľné)';

  @override
  String get providerStorageNodeHint =>
      'Nechajte prázdne pre vstavané seed uzly';

  @override
  String get transferInvalidCodeFormat =>
      'Nerozpoznaný formát kódu — musí začínať LAN: alebo NOS:';

  @override
  String get profileCardFingerprintCopied => 'Odtlačok skopírovaný';

  @override
  String get profileCardAboutHint => 'Súkromie na prvom mieste 🔒';

  @override
  String get profileCardSaveButton => 'Uložiť profil';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Exportovať šifrované správy, kontakty a avatary do súboru';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Audio';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Doručené: $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Doručené: $count';
  }

  @override
  String get groupStatusDialogTitle => 'Informácie o správe';

  @override
  String get groupStatusRead => 'Prečítané';

  @override
  String get groupStatusDelivered => 'Doručené';

  @override
  String get groupStatusPending => 'Čakajúce';

  @override
  String get groupStatusNoData => 'Zatiaľ žiadne informácie o doručení';

  @override
  String get profileTransferAdmin => 'Urobiť adminom';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Urobiť $name novým adminom?';
  }

  @override
  String get profileTransferAdminBody =>
      'Stratíte oprávnenia admina. Toto nemožno vrátiť späť.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name je teraz admin';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Zásady ochrany súkromia';

  @override
  String get privacyOverviewHeading => 'Prehľad';

  @override
  String get privacyOverviewBody =>
      'Pulse je bezserverový messenger so šifrovaním end-to-end. Vaše súkromie nie je len funkcia — je to architektúra. Neexistujú žiadne servery Pulse. Žiadne účty nie sú nikde uložené. Žiadne dáta nie sú vývojármi zhromažďované, prenášané ani ukladané.';

  @override
  String get privacyDataCollectionHeading => 'Zber dát';

  @override
  String get privacyDataCollectionBody =>
      'Pulse nezhromažďuje žiadne osobné údaje. Konkrétne:\n\n- Nevyžaduje sa žiadny e-mail, telefónne číslo ani skutočné meno\n- Žiadna analytika, sledovanie ani telemetria\n- Žiadne reklamné identifikátory\n- Žiadny prístup k zoznamu kontaktov\n- Žiadne cloudové zálohy (správy existujú len na vašom zariadení)\n- Žiadne metadáta nie sú posielané na žiadny server Pulse (žiadne neexistujú)';

  @override
  String get privacyEncryptionHeading => 'Šifrovanie';

  @override
  String get privacyEncryptionBody =>
      'Všetky správy sú šifrované pomocou Signal Protocol (Double Ratchet s dohodou kľúčov X3DH). Šifrovacie kľúče sú generované a ukladané výhradne na vašom zariadení. Nikto — vrátane vývojárov — nemôže čítať vaše správy.';

  @override
  String get privacyNetworkHeading => 'Sieťová architektúra';

  @override
  String get privacyNetworkBody =>
      'Pulse používa federované transportné adaptéry (Nostr relay servery, Session/Oxen uzly služieb, Firebase Realtime Database, LAN). Tieto transporty prenášajú len šifrovaný text. Prevádzkovatelia relay serverov môžu vidieť vašu IP adresu a objem prevádzky, ale nemôžu dešifrovať obsah správ.\n\nKeď je zapnutý Tor, vaša IP adresa je skrytá aj pred prevádzkovateľmi relay serverov.';

  @override
  String get privacyStunHeading => 'STUN/TURN servery';

  @override
  String get privacyStunBody =>
      'Hlasové a video hovory používajú WebRTC so šifrovaním DTLS-SRTP. STUN servery (na zistenie vašej verejnej IP pre peer-to-peer pripojenia) a TURN servery (na prenos médií, keď priame pripojenie zlyhá) môžu vidieť vašu IP adresu a trvanie hovoru, ale nemôžu dešifrovať obsah hovoru.\n\nVlastný TURN server môžete nakonfigurovať v Nastaveniach pre maximálne súkromie.';

  @override
  String get privacyCrashHeading => 'Hlásenie pádov';

  @override
  String get privacyCrashBody =>
      'Ak je hlásenie pádov Sentry zapnuté (cez SENTRY_DSN pri zostavovaní), môžu byť odosielané anonymné hlásenia o pádoch. Tieto neobsahujú žiadny obsah správ, žiadne kontaktné informácie a žiadne osobné identifikačné údaje. Hlásenie pádov je možné vypnúť pri zostavovaní vynechaním DSN.';

  @override
  String get privacyPasswordHeading => 'Heslo a kľúče';

  @override
  String get privacyPasswordBody =>
      'Vaše heslo na obnovenie sa používa na odvodenie kryptografických kľúčov pomocou Argon2id (pamäťovo náročná KDF). Heslo nie je nikdy nikam prenášané. Ak stratíte heslo, váš účet nemožno obnoviť — neexistuje žiadny server na jeho resetovanie.';

  @override
  String get privacyFontsHeading => 'Písma';

  @override
  String get privacyFontsBody =>
      'Pulse obsahuje všetky písma lokálne. Žiadne požiadavky nie sú odosielané na Google Fonts ani žiadnu externú službu písem.';

  @override
  String get privacyThirdPartyHeading => 'Služby tretích strán';

  @override
  String get privacyThirdPartyBody =>
      'Pulse nie je integrovaný so žiadnymi reklamnými sieťami, poskytovateľmi analytiky, platformami sociálnych médií ani sprostredkovateľmi dát. Jediné sieťové pripojenia sú k transportným relay serverom, ktoré si nakonfigurujete.';

  @override
  String get privacyOpenSourceHeading => 'Open Source';

  @override
  String get privacyOpenSourceBody =>
      'Pulse je softvér s otvoreným zdrojovým kódom. Môžete preskúmať kompletný zdrojový kód a overiť tieto tvrdenia o ochrane súkromia.';

  @override
  String get privacyContactHeading => 'Kontakt';

  @override
  String get privacyContactBody =>
      'Pre otázky týkajúce sa súkromia otvorte issue v repozitári projektu.';

  @override
  String get privacyLastUpdated => 'Naposledy aktualizované: marec 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Uloženie zlyhalo: $error';
  }

  @override
  String get themeEngineTitle => 'Téma';

  @override
  String get torBuiltInTitle => 'Vstavaný Tor';

  @override
  String get torConnectedSubtitle =>
      'Pripojené — Nostr smerované cez 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Pripájanie… $pct %';
  }

  @override
  String get torNotRunning => 'Nebeží — klepnite na prepínač pre reštart';

  @override
  String get torDescription =>
      'Smeruje Nostr cez Tor (Snowflake pre cenzurované siete)';

  @override
  String get torNetworkDiagnostics => 'Diagnostika siete';

  @override
  String get torTransportLabel => 'Transport: ';

  @override
  String get torPtAuto => 'Auto';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Obyčajný';

  @override
  String get torTimeoutLabel => 'Časový limit: ';

  @override
  String get torInfoDescription =>
      'Keď je zapnuté, Nostr WebSocket pripojenia sú smerované cez Tor (SOCKS5). Tor Browser počúva na 127.0.0.1:9150. Samostatný tor démon používa port 9050. Firebase pripojenia nie sú ovplyvnené.';

  @override
  String get torRouteNostrTitle => 'Smerovať Nostr cez Tor';

  @override
  String get torManagedByBuiltin => 'Spravované vstavaným Tor';

  @override
  String get torActiveRouting => 'Aktívne — Nostr prevádzka smerovaná cez Tor';

  @override
  String get torDisabled => 'Vypnuté';

  @override
  String get torProxySocks5 => 'Tor Proxy (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Hostiteľ proxy';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser: port 9150  •  tor démon: port 9050';

  @override
  String get torForceNostrTitle => 'Route messages through Tor';

  @override
  String get torForceNostrSubtitle =>
      'All Nostr relay connections will go through Tor. Slower but hides your IP from relays.';

  @override
  String get torForceNostrDisabled => 'Tor must be enabled first';

  @override
  String get i2pProxySocks5 => 'I2P Proxy (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P štandardne používa SOCKS5 na porte 4447. Pripojte sa k Nostr relay serveru cez I2P outproxy (napr. relay.damus.i2p) pre komunikáciu s používateľmi na akomkoľvek transporte. Tor má prednosť, keď sú oba zapnuté.';

  @override
  String get i2pRouteNostrTitle => 'Smerovať Nostr cez I2P';

  @override
  String get i2pActiveRouting => 'Aktívne — Nostr prevádzka smerovaná cez I2P';

  @override
  String get i2pDisabled => 'Vypnuté';

  @override
  String get i2pProxyHostLabel => 'Hostiteľ proxy';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'I2P Router predvolený SOCKS5 port: 4447';

  @override
  String get customProxySocks5 => 'Vlastný Proxy (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Vlastný proxy smeruje prevádzku cez váš V2Ray/Xray/Shadowsocks. CF Worker funguje ako osobný relay proxy na Cloudflare CDN — GFW vidí *.workers.dev, nie skutočný relay.';

  @override
  String get customSocks5ProxyTitle => 'Vlastný SOCKS5 Proxy';

  @override
  String get customProxyActive => 'Aktívny — prevádzka smerovaná cez SOCKS5';

  @override
  String get customProxyDisabled => 'Vypnutý';

  @override
  String get customProxyHostLabel => 'Hostiteľ proxy';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Doména Worker (voliteľné)';

  @override
  String get customWorkerHelpTitle => 'Ako nasadiť CF Worker relay (zadarmo)';

  @override
  String get customWorkerScriptCopied => 'Skript skopírovaný!';

  @override
  String get customWorkerStep1 =>
      '1. Prejdite na dash.cloudflare.com → Workers & Pages\n2. Create Worker → prilepte tento skript:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → skopírujte doménu (napr. my-relay.user.workers.dev)\n4. Prilepte doménu vyššie → Uložiť\n\nAplikácia sa automaticky pripojí: wss://domain/?r=relay_url\nGFW vidí: pripojenie k *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Pripojené — SOCKS5 na 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Pripájanie…';

  @override
  String get psiphonNotRunning => 'Nebeží — klepnite na prepínač pre reštart';

  @override
  String get psiphonDescription =>
      'Rýchly tunel (~3s bootstrap, 2000+ rotujúcich VPS)';

  @override
  String get turnCommunityServers => 'Komunitné TURN servery';

  @override
  String get turnCustomServer => 'Vlastný TURN server (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN servery prenášajú len už šifrované streamy (DTLS-SRTP). Prevádzkovateľ relay servera vidí vašu IP a objem prevádzky, ale nemôže dešifrovať hovory. TURN sa používa len keď priame P2P zlyhá (~15–20 % pripojení).';

  @override
  String get turnFreeLabel => 'ZADARMO';

  @override
  String get turnServerUrlLabel => 'URL TURN servera';

  @override
  String get turnServerUrlHint => 'turn:váš-server.com:3478 alebo turns:...';

  @override
  String get turnUsernameLabel => 'Používateľské meno';

  @override
  String get turnPasswordLabel => 'Heslo';

  @override
  String get turnOptionalHint => 'Voliteľné';

  @override
  String get turnCustomInfo =>
      'Prevádzkujte coturn na akomkoľvek VPS za 5\$/mesiac pre maximálnu kontrolu. Prihlasovacie údaje sú uložené lokálne.';

  @override
  String get themePickerAppearance => 'Vzhľad';

  @override
  String get themePickerAccentColor => 'Farba zvýraznenia';

  @override
  String get themeModeLight => 'Svetlý';

  @override
  String get themeModeDark => 'Tmavý';

  @override
  String get themeModeSystem => 'Systém';

  @override
  String get themeDynamicPresets => 'Prednastavenia';

  @override
  String get themeDynamicPrimaryColor => 'Primárna farba';

  @override
  String get themeDynamicBorderRadius => 'Polomer okrajov';

  @override
  String get themeDynamicFont => 'Písmo';

  @override
  String get themeDynamicAppearance => 'Vzhľad';

  @override
  String get themeDynamicUiStyle => 'Štýl UI';

  @override
  String get themeDynamicUiStyleDescription =>
      'Ovláda vzhľad dialógov, prepínačov a indikátorov.';

  @override
  String get themeDynamicSharp => 'Ostrý';

  @override
  String get themeDynamicRound => 'Oblý';

  @override
  String get themeDynamicModeDark => 'Tmavý';

  @override
  String get themeDynamicModeLight => 'Svetlý';

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
      'Neplatná Firebase URL. Očakáva sa: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Neplatná URL relay servera. Očakáva sa: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Neplatná URL Pulse servera. Očakáva sa: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'URL servera';

  @override
  String get providerPulseServerUrlHint => 'https://váš-server:8443';

  @override
  String get providerPulseInviteLabel => 'Kód pozvánky';

  @override
  String get providerPulseInviteHint => 'Kód pozvánky (ak je vyžadovaný)';

  @override
  String get providerPulseInfo =>
      'Vlastný relay server. Kľúče odvodené z vášho hesla na obnovenie.';

  @override
  String get providerScreenTitle => 'Schránky';

  @override
  String get providerSecondaryInboxesHeader => 'SEKUNDÁRNE SCHRÁNKY';

  @override
  String get providerSecondaryInboxesInfo =>
      'Sekundárne schránky prijímajú správy súčasne pre redundanciu.';

  @override
  String get providerRemoveTooltip => 'Odstrániť';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... alebo hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... alebo hex súkromný kľúč';

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
  String get emojiNoRecent => 'Žiadne nedávne emoji';

  @override
  String get emojiSearchHint => 'Hľadať emoji...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Klepnite pre konverzáciu';

  @override
  String get imageViewerSaveToDownloads => 'Uložiť do Downloads';

  @override
  String imageViewerSavedTo(String path) {
    return 'Uložené do $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Jazyk';

  @override
  String get settingsLanguageSubtitle => 'Jazyk zobrazenia aplikácie';

  @override
  String get settingsLanguageSystem => 'Predvolený systémový';

  @override
  String get onboardingLanguageTitle => 'Vyberte si jazyk';

  @override
  String get onboardingLanguageSubtitle =>
      'Neskôr to môžete zmeniť v Nastaveniach';

  @override
  String get videoNoteRecord => 'Nahrať video správu';

  @override
  String get videoNoteTapToRecord => 'Klepnutím spustíte nahrávanie';

  @override
  String get videoNoteTapToStop => 'Klepnutím zastavíte';

  @override
  String get videoNoteCameraPermission => 'Prístup ku kamere bol zamietnutý';

  @override
  String get videoNoteMaxDuration => 'Maximum 30 sekúnd';

  @override
  String get videoNoteNotSupported =>
      'Videopoznámky nie sú na tejto platforme podporované';

  @override
  String get navChats => 'Správy';

  @override
  String get navUpdates => 'Aktualizácie';

  @override
  String get navCalls => 'Hovory';

  @override
  String get filterAll => 'Všetky';

  @override
  String get filterUnread => 'Neprečítané';

  @override
  String get filterGroups => 'Skupiny';

  @override
  String get callsNoRecent => 'Žiadne nedávne hovory';

  @override
  String get callsEmptySubtitle => 'Vaša história hovorov sa zobrazí tu';

  @override
  String get appBarEncrypted => 'šifrované end-to-end';

  @override
  String get newStatus => 'Nový stav';

  @override
  String get newCall => 'Nový hovor';
}
