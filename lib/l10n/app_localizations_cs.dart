// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Hledat ve zprávách...';

  @override
  String get search => 'Hledat';

  @override
  String get clearSearch => 'Vymazat hledání';

  @override
  String get closeSearch => 'Zavřít hledání';

  @override
  String get moreOptions => 'Další možnosti';

  @override
  String get back => 'Zpět';

  @override
  String get cancel => 'Zrušit';

  @override
  String get close => 'Zavřít';

  @override
  String get confirm => 'Potvrdit';

  @override
  String get remove => 'Odstranit';

  @override
  String get save => 'Uložit';

  @override
  String get add => 'Přidat';

  @override
  String get copy => 'Kopírovat';

  @override
  String get skip => 'Přeskočit';

  @override
  String get done => 'Hotovo';

  @override
  String get apply => 'Použít';

  @override
  String get export => 'Exportovat';

  @override
  String get import => 'Importovat';

  @override
  String get homeNewGroup => 'Nová skupina';

  @override
  String get homeSettings => 'Nastavení';

  @override
  String get homeSearching => 'Prohledávání zpráv...';

  @override
  String get homeNoResults => 'Žádné výsledky';

  @override
  String get homeNoChatHistory => 'Zatím žádná historie chatů';

  @override
  String homeTransportSwitched(String address) {
    return 'Transport přepnut → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name volá...';
  }

  @override
  String get homeAccept => 'Přijmout';

  @override
  String get homeDecline => 'Odmítnout';

  @override
  String get homeLoadEarlier => 'Načíst starší zprávy';

  @override
  String get homeChats => 'Chaty';

  @override
  String get homeSelectConversation => 'Vyberte konverzaci';

  @override
  String get homeNoChatsYet => 'Zatím žádné chaty';

  @override
  String get homeAddContactToStart => 'Přidejte kontakt a začněte chatovat';

  @override
  String get homeNewChat => 'Nový chat';

  @override
  String get homeNewChatTooltip => 'Nový chat';

  @override
  String get homeIncomingCallTitle => 'Příchozí hovor';

  @override
  String get homeIncomingGroupCallTitle => 'Příchozí skupinový hovor';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — příchozí skupinový hovor';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Žádné chaty odpovídající \"$query\"';
  }

  @override
  String get homeSectionChats => 'Chaty';

  @override
  String get homeSectionMessages => 'Zprávy';

  @override
  String get homeDbEncryptionUnavailable =>
      'Šifrování databáze není dostupné — nainstalujte SQLCipher pro plnou ochranu';

  @override
  String get chatFileTooLargeGroup =>
      'Soubory větší než 512 KB nejsou ve skupinových chatech podporovány';

  @override
  String get chatLargeFile => 'Velký soubor';

  @override
  String get chatCancel => 'Zrušit';

  @override
  String get chatSend => 'Odeslat';

  @override
  String get chatFileTooLarge =>
      'Soubor je příliš velký — maximální velikost je 100 MB';

  @override
  String get chatMicDenied => 'Přístup k mikrofonu byl zamítnut';

  @override
  String get chatVoiceFailed =>
      'Hlasovou zprávu se nepodařilo uložit — zkontrolujte dostupné úložiště';

  @override
  String get chatScheduleFuture => 'Naplánovaný čas musí být v budoucnosti';

  @override
  String get chatToday => 'Dnes';

  @override
  String get chatYesterday => 'Včera';

  @override
  String get chatEdited => 'upraveno';

  @override
  String get chatYou => 'Vy';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Tento soubor má $size MB. Odesílání velkých souborů může být v některých sítích pomalé. Pokračovat?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Bezpečnostní klíč kontaktu $name se změnil. Klepněte pro ověření.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Zprávu pro $name se nepodařilo zašifrovat — zpráva nebyla odeslána.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Bezpečnostní číslo pro $name se změnilo. Klepněte pro ověření.';
  }

  @override
  String get chatNoMessagesFound => 'Žádné zprávy nenalezeny';

  @override
  String get chatMessagesE2ee => 'Zprávy jsou šifrovány end-to-end';

  @override
  String get chatSayHello => 'Pozdravte';

  @override
  String get appBarOnline => 'online';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'píše';

  @override
  String get appBarSearchMessages => 'Hledat ve zprávách...';

  @override
  String get appBarMute => 'Ztlumit';

  @override
  String get appBarUnmute => 'Zrušit ztlumení';

  @override
  String get appBarMedia => 'Média';

  @override
  String get appBarDisappearing => 'Mizející zprávy';

  @override
  String get appBarDisappearingOn => 'Mizející: zapnuto';

  @override
  String get appBarGroupSettings => 'Nastavení skupiny';

  @override
  String get appBarSearchTooltip => 'Hledat ve zprávách';

  @override
  String get appBarVoiceCall => 'Hlasový hovor';

  @override
  String get appBarVideoCall => 'Videohovor';

  @override
  String get inputMessage => 'Zpráva...';

  @override
  String get inputAttachFile => 'Připojit soubor';

  @override
  String get inputSendMessage => 'Odeslat zprávu';

  @override
  String get inputRecordVoice => 'Nahrát hlasovou zprávu';

  @override
  String get inputSendVoice => 'Odeslat hlasovou zprávu';

  @override
  String get inputCancelReply => 'Zrušit odpověď';

  @override
  String get inputCancelEdit => 'Zrušit úpravu';

  @override
  String get inputCancelRecording => 'Zrušit nahrávání';

  @override
  String get inputRecording => 'Nahrávání…';

  @override
  String get inputEditingMessage => 'Úprava zprávy';

  @override
  String get inputPhoto => 'Fotografie';

  @override
  String get inputVoiceMessage => 'Hlasová zpráva';

  @override
  String get inputFile => 'Soubor';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ých zpráv',
      one: 'á zpráva',
    );
    return '$count naplánovan$_temp0';
  }

  @override
  String get callInitializing => 'Inicializace hovoru…';

  @override
  String get callConnecting => 'Připojování…';

  @override
  String get callConnectingRelay => 'Připojování (relay)…';

  @override
  String get callSwitchingRelay => 'Přepínání do režimu relay…';

  @override
  String get callConnectionFailed => 'Připojení selhalo';

  @override
  String get callReconnecting => 'Opětovné připojování…';

  @override
  String get callEnded => 'Hovor ukončen';

  @override
  String get callLive => 'Živě';

  @override
  String get callEnd => 'Konec';

  @override
  String get callEndCall => 'Ukončit hovor';

  @override
  String get callMute => 'Ztlumit';

  @override
  String get callUnmute => 'Zrušit ztlumení';

  @override
  String get callSpeaker => 'Reproduktor';

  @override
  String get callCameraOn => 'Kamera zapnuta';

  @override
  String get callCameraOff => 'Kamera vypnuta';

  @override
  String get callShareScreen => 'Sdílet obrazovku';

  @override
  String get callStopShare => 'Zastavit sdílení';

  @override
  String callTorBackup(String duration) {
    return 'Záloha Tor · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Záloha Tor aktivní — primární cesta nedostupná';

  @override
  String get callDirectFailed =>
      'Přímé spojení selhalo — přepínání do režimu relay…';

  @override
  String get callTurnUnreachable =>
      'TURN servery nedostupné. Přidejte vlastní TURN v Nastavení → Pokročilé.';

  @override
  String get callRelayMode => 'Režim relay aktivní (omezená síť)';

  @override
  String get callStarting => 'Zahajování hovoru…';

  @override
  String get callConnectingToGroup => 'Připojování ke skupině…';

  @override
  String get callGroupOpenedInBrowser => 'Skupinový hovor otevřen v prohlížeči';

  @override
  String get callCouldNotOpenBrowser => 'Nelze otevřít prohlížeč';

  @override
  String get callInviteLinkSent =>
      'Odkaz s pozvánkou odeslán všem členům skupiny.';

  @override
  String get callOpenLinkManually =>
      'Otevřete odkaz výše ručně nebo klepněte pro opakování.';

  @override
  String get callJitsiNotE2ee => 'Jitsi hovory NEJSOU šifrovány end-to-end';

  @override
  String get callRetryOpenBrowser => 'Zkusit znovu otevřít prohlížeč';

  @override
  String get callClose => 'Zavřít';

  @override
  String get callCamOn => 'Kamera zap.';

  @override
  String get callCamOff => 'Kamera vyp.';

  @override
  String get noConnection =>
      'Žádné připojení — zprávy budou zařazeny do fronty';

  @override
  String get connected => 'Připojeno';

  @override
  String get connecting => 'Připojování…';

  @override
  String get disconnected => 'Odpojeno';

  @override
  String get offlineBanner =>
      'Žádné připojení — zprávy budou odeslány po obnovení spojení';

  @override
  String get lanModeBanner => 'Režim LAN — Bez internetu · Pouze lokální síť';

  @override
  String get probeCheckingNetwork => 'Kontrola síťového připojení…';

  @override
  String get probeDiscoveringRelays =>
      'Vyhledávání relay přes komunitní adresáře…';

  @override
  String get probeStartingTor => 'Spouštění Tor pro bootstrap…';

  @override
  String get probeFindingRelaysTor => 'Hledání dostupných relay přes Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'o $count relay',
      one: 'o 1 relay',
    );
    return 'Síť připravena — nalezen$_temp0';
  }

  @override
  String get probeNoRelaysFound =>
      'Nenalezeny žádné dostupné relay — zprávy mohou být zpožděny';

  @override
  String get jitsiWarningTitle => 'Bez end-to-end šifrování';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet hovory nejsou šifrovány aplikací Pulse. Používejte pouze pro necitlivé konverzace.';

  @override
  String get jitsiConfirm => 'Přesto se připojit';

  @override
  String get jitsiGroupWarningTitle => 'Bez end-to-end šifrování';

  @override
  String get jitsiGroupWarningBody =>
      'Tento hovor má příliš mnoho účastníků pro vestavěnou šifrovanou síť.\n\nV prohlížeči se otevře odkaz na Jitsi Meet. Jitsi NENÍ šifrováno end-to-end — server může vidět váš hovor.';

  @override
  String get jitsiContinueAnyway => 'Přesto pokračovat';

  @override
  String get retry => 'Opakovat';

  @override
  String get setupCreateAnonymousAccount => 'Vytvořit anonymní účet';

  @override
  String get setupTapToChangeColor => 'Klepněte pro změnu barvy';

  @override
  String get setupReqMinLength => 'Alespoň 16 znaků';

  @override
  String get setupReqVariety => '3 ze 4: velká, malá písmena, číslice, symboly';

  @override
  String get setupReqMatch => 'Hesla se shodují';

  @override
  String get setupYourNickname => 'Vaše přezdívka';

  @override
  String get setupRecoveryPassword => 'Heslo pro obnovení (min. 16)';

  @override
  String get setupConfirmPassword => 'Potvrdit heslo';

  @override
  String get setupMin16Chars => 'Minimálně 16 znaků';

  @override
  String get setupPasswordsDoNotMatch => 'Hesla se neshodují';

  @override
  String get setupEntropyWeak => 'Slabé';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Silné';

  @override
  String get setupEntropyWeakNeedsVariety => 'Slabé (potřeba 3 typy znaků)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bitů)';
  }

  @override
  String get setupPasswordWarning =>
      'Toto heslo je jediný způsob obnovení vašeho účtu. Neexistuje žádný server — žádný reset hesla. Zapamatujte si ho nebo si ho zapište.';

  @override
  String get setupCreateAccount => 'Vytvořit účet';

  @override
  String get setupAlreadyHaveAccount => 'Již máte účet? ';

  @override
  String get setupRestore => 'Obnovit →';

  @override
  String get restoreTitle => 'Obnovit účet';

  @override
  String get restoreInfoBanner =>
      'Zadejte heslo pro obnovení — vaše adresa (Nostr + Session) bude automaticky obnovena. Kontakty a zprávy byly uloženy pouze lokálně.';

  @override
  String get restoreNewNickname => 'Nová přezdívka (lze změnit později)';

  @override
  String get restoreButton => 'Obnovit účet';

  @override
  String get lockTitle => 'Pulse je zamčen';

  @override
  String get lockSubtitle => 'Zadejte heslo pro pokračování';

  @override
  String get lockPasswordHint => 'Heslo';

  @override
  String get lockUnlock => 'Odemknout';

  @override
  String get lockPanicHint =>
      'Zapomněli jste heslo? Zadejte panický klíč pro smazání všech dat.';

  @override
  String get lockTooManyAttempts => 'Příliš mnoho pokusů. Mazání všech dat…';

  @override
  String get lockWrongPassword => 'Nesprávné heslo';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Nesprávné heslo — $attempts/$max pokusů';
  }

  @override
  String get onboardingSkip => 'Přeskočit';

  @override
  String get onboardingNext => 'Další';

  @override
  String get onboardingGetStarted => 'Vytvořit účet';

  @override
  String get onboardingWelcomeTitle => 'Vítejte v Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Decentralizovaný messenger se šifrováním end-to-end.\n\nŽádné centrální servery. Žádný sběr dat. Žádná zadní vrátka.\nVaše konverzace patří jen vám.';

  @override
  String get onboardingTransportTitle => 'Nezávislý na transportu';

  @override
  String get onboardingTransportBody =>
      'Používejte Firebase, Nostr nebo obojí současně.\n\nZprávy se automaticky směrují přes sítě. Vestavěná podpora Tor a I2P pro odolnost proti cenzuře.';

  @override
  String get onboardingSignalTitle => 'Signal + post-kvantové šifrování';

  @override
  String get onboardingSignalBody =>
      'Každá zpráva je šifrována protokolem Signal (Double Ratchet + X3DH) pro dopřednou bezpečnost.\n\nNavíc obalena Kyber-1024 — postkvantovým algoritmem standardu NIST — chránícím proti budoucím kvantovým počítačům.';

  @override
  String get onboardingKeysTitle => 'Vaše klíče patří vám';

  @override
  String get onboardingKeysBody =>
      'Vaše identitní klíče nikdy neopustí vaše zařízení.\n\nOtisky Signal umožňují ověření kontaktů mimo pásmo. TOFU (Trust On First Use) automaticky detekuje změny klíčů.';

  @override
  String get onboardingThemeTitle => 'Vyberte si vzhled';

  @override
  String get onboardingThemeBody =>
      'Vyberte motiv a barvu zvýraznění. Kdykoli to můžete změnit v Nastavení.';

  @override
  String get contactsNewChat => 'Nový chat';

  @override
  String get contactsAddContact => 'Přidat kontakt';

  @override
  String get contactsSearchHint => 'Hledat...';

  @override
  String get contactsNewGroup => 'Nová skupina';

  @override
  String get contactsNoContactsYet => 'Zatím žádné kontakty';

  @override
  String get contactsAddHint => 'Klepněte na + pro přidání adresy';

  @override
  String get contactsNoMatch => 'Žádné odpovídající kontakty';

  @override
  String get contactsRemoveTitle => 'Odstranit kontakt';

  @override
  String contactsRemoveMessage(String name) {
    return 'Odstranit $name?';
  }

  @override
  String get contactsRemove => 'Odstranit';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ů',
      one: '',
    );
    return '$count kontakt$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Otevřít odkaz';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Otevřít tuto URL v prohlížeči?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Otevřít';

  @override
  String get bubbleSecurityWarning => 'Bezpečnostní varování';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" je spustitelný soubor. Jeho uložení a spuštění může poškodit vaše zařízení. Přesto uložit?';
  }

  @override
  String get bubbleSaveAnyway => 'Přesto uložit';

  @override
  String bubbleSavedTo(String path) {
    return 'Uloženo do $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Uložení selhalo: $error';
  }

  @override
  String get bubbleNotEncrypted => 'NEŠIFROVÁNO';

  @override
  String get bubbleCorruptedImage => '[Poškozený obrázek]';

  @override
  String get bubbleReplyPhoto => 'Fotografie';

  @override
  String get bubbleReplyVoice => 'Hlasová zpráva';

  @override
  String get bubbleReplyVideo => 'Videozpráva';

  @override
  String bubbleReadBy(String names) {
    return 'Přečteno: $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Přečteno: $count';
  }

  @override
  String get chatTileTapToStart => 'Klepněte pro zahájení chatu';

  @override
  String get chatTileMessageSent => 'Zpráva odeslána';

  @override
  String get chatTileEncryptedMessage => 'Šifrovaná zpráva';

  @override
  String chatTileYouPrefix(String text) {
    return 'Vy: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Hlasová zpráva';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Hlasová zpráva ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Šifrovaná zpráva';

  @override
  String get groupNewGroup => 'Nová skupina';

  @override
  String get groupGroupName => 'Název skupiny';

  @override
  String get groupSelectMembers => 'Vyberte členy (min. 2)';

  @override
  String get groupNoContactsYet =>
      'Zatím žádné kontakty. Nejdříve přidejte kontakty.';

  @override
  String get groupCreate => 'Vytvořit';

  @override
  String get groupLabel => 'Skupina';

  @override
  String get profileVerifyIdentity => 'Ověřit identitu';

  @override
  String profileVerifyInstructions(String name) {
    return 'Porovnejte tyto otisky s kontaktem $name při hlasovém hovoru nebo osobně. Pokud se obě hodnoty shodují na obou zařízeních, klepněte na „Označit jako ověřené“.';
  }

  @override
  String get profileTheirKey => 'Jejich klíč';

  @override
  String get profileYourKey => 'Váš klíč';

  @override
  String get profileRemoveVerification => 'Zrušit ověření';

  @override
  String get profileMarkAsVerified => 'Označit jako ověřené';

  @override
  String get profileAddressCopied => 'Adresa zkopírována';

  @override
  String get profileNoContactsToAdd =>
      'Žádné kontakty k přidání — všichni jsou již členy';

  @override
  String get profileAddMembers => 'Přidat členy';

  @override
  String profileAddCount(int count) {
    return 'Přidat ($count)';
  }

  @override
  String get profileRenameGroup => 'Přejmenovat skupinu';

  @override
  String get profileRename => 'Přejmenovat';

  @override
  String get profileRemoveMember => 'Odstranit člena?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Odstranit $name z této skupiny?';
  }

  @override
  String get profileKick => 'Vyloučit';

  @override
  String get profileSignalFingerprints => 'Otisky Signal';

  @override
  String get profileVerified => 'OVĚŘENO';

  @override
  String get profileVerify => 'Ověřit';

  @override
  String get profileEdit => 'Upravit';

  @override
  String get profileNoSession =>
      'Zatím nebyla navázána relace — nejdříve odešlete zprávu.';

  @override
  String get profileFingerprintCopied => 'Otisk zkopírován';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ů',
      one: '',
    );
    return '$count člen$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Ověřit bezpečnostní číslo';

  @override
  String get profileShowContactQr => 'Zobrazit QR kontaktu';

  @override
  String profileContactAddress(String name) {
    return 'Adresa kontaktu $name';
  }

  @override
  String get profileExportChatHistory => 'Exportovat historii chatu';

  @override
  String profileSavedTo(String path) {
    return 'Uloženo do $path';
  }

  @override
  String get profileExportFailed => 'Export selhal';

  @override
  String get profileClearChatHistory => 'Vymazat historii chatu';

  @override
  String get profileDeleteGroup => 'Smazat skupinu';

  @override
  String get profileDeleteContact => 'Smazat kontakt';

  @override
  String get profileLeaveGroup => 'Opustit skupinu';

  @override
  String get profileLeaveGroupBody =>
      'Budete odebrání z této skupiny a bude smazána z vašich kontaktů.';

  @override
  String get groupInviteTitle => 'Pozvánka do skupiny';

  @override
  String groupInviteBody(String from, String group) {
    return '$from vás pozval do skupiny \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Přijmout';

  @override
  String get groupInviteDecline => 'Odmítnout';

  @override
  String get groupMemberLimitTitle => 'Příliš mnoho účastníků';

  @override
  String groupMemberLimitBody(int count) {
    return 'Tato skupina bude mít $count účastníků. Šifrované mesh hovory podporují maximálně 6. Větší skupiny přejdou na Jitsi (bez E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Přesto přidat';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name odmítl pozvánku do skupiny \"$group\"';
  }

  @override
  String get transferTitle => 'Přenos na jiné zařízení';

  @override
  String get transferInfoBox =>
      'Přesuňte svou identitu Signal a klíče Nostr na nové zařízení.\nRelace chatu se NEPŘENÁŠEJÍ — dopředná bezpečnost je zachována.';

  @override
  String get transferSendFromThis => 'Odeslat z tohoto zařízení';

  @override
  String get transferSendSubtitle =>
      'Toto zařízení má klíče. Sdílejte kód s novým zařízením.';

  @override
  String get transferReceiveOnThis => 'Přijmout na tomto zařízení';

  @override
  String get transferReceiveSubtitle =>
      'Toto je nové zařízení. Zadejte kód ze starého zařízení.';

  @override
  String get transferChooseMethod => 'Vyberte metodu přenosu';

  @override
  String get transferLan => 'LAN (stejná síť)';

  @override
  String get transferLanSubtitle =>
      'Rychlý a přímý. Obě zařízení musí být na stejné Wi-Fi.';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'Funguje přes jakoukoli síť pomocí existujícího Nostr relay.';

  @override
  String get transferRelayUrl => 'URL relay';

  @override
  String get transferEnterCode => 'Zadejte kód přenosu';

  @override
  String get transferPasteCode => 'Vložte kód LAN:... nebo NOS:... zde';

  @override
  String get transferConnect => 'Připojit';

  @override
  String get transferGenerating => 'Generování kódu přenosu…';

  @override
  String get transferShareCode => 'Sdílejte tento kód s příjemcem:';

  @override
  String get transferCopyCode => 'Kopírovat kód';

  @override
  String get transferCodeCopied => 'Kód zkopírován do schránky';

  @override
  String get transferWaitingReceiver => 'Čekání na připojení příjemce…';

  @override
  String get transferConnectingSender => 'Připojování k odesílateli…';

  @override
  String get transferVerifyBoth =>
      'Porovnejte tento kód na obou zařízeních.\nPokud se shodují, přenos je bezpečný.';

  @override
  String get transferComplete => 'Přenos dokončen';

  @override
  String get transferKeysImported => 'Klíče importovány';

  @override
  String get transferCompleteSenderBody =>
      'Vaše klíče zůstávají aktivní na tomto zařízení.\nPříjemce nyní může používat vaši identitu.';

  @override
  String get transferCompleteReceiverBody =>
      'Klíče úspěšně importovány.\nRestartujte aplikaci pro použití nové identity.';

  @override
  String get transferRestartApp => 'Restartovat aplikaci';

  @override
  String get transferFailed => 'Přenos selhal';

  @override
  String get transferTryAgain => 'Zkusit znovu';

  @override
  String get transferEnterRelayFirst => 'Nejdříve zadejte URL relay';

  @override
  String get transferPasteCodeFromSender => 'Vložte kód přenosu od odesílatele';

  @override
  String get menuReply => 'Odpovědět';

  @override
  String get menuForward => 'Přeposlat';

  @override
  String get menuReact => 'Reagovat';

  @override
  String get menuCopy => 'Kopírovat';

  @override
  String get menuEdit => 'Upravit';

  @override
  String get menuRetry => 'Opakovat';

  @override
  String get menuCancelScheduled => 'Zrušit naplánované';

  @override
  String get menuDelete => 'Smazat';

  @override
  String get menuForwardTo => 'Přeposlat…';

  @override
  String menuForwardedTo(String name) {
    return 'Přeposláno kontaktu $name';
  }

  @override
  String get menuScheduledMessages => 'Naplánované zprávy';

  @override
  String get menuNoScheduledMessages => 'Žádné naplánované zprávy';

  @override
  String menuSendsOn(String date) {
    return 'Odeslání dne $date';
  }

  @override
  String get menuDisappearingMessages => 'Mizející zprávy';

  @override
  String get menuDisappearingSubtitle =>
      'Zprávy se po zvoleném čase automaticky smažou.';

  @override
  String get menuTtlOff => 'Vypnuto';

  @override
  String get menuTtl1h => '1 hodina';

  @override
  String get menuTtl24h => '24 hodin';

  @override
  String get menuTtl7d => '7 dní';

  @override
  String get menuAttachPhoto => 'Fotografie';

  @override
  String get menuAttachFile => 'Soubor';

  @override
  String get menuAttachVideo => 'Video';

  @override
  String get mediaTitle => 'Média';

  @override
  String get mediaFileLabel => 'SOUBOR';

  @override
  String mediaPhotosTab(int count) {
    return 'Fotografie ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Soubory ($count)';
  }

  @override
  String get mediaNoPhotos => 'Zatím žádné fotografie';

  @override
  String get mediaNoFiles => 'Zatím žádné soubory';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Uloženo do Stažené/$name';
  }

  @override
  String get mediaFailedToSave => 'Uložení souboru selhalo';

  @override
  String get statusNewStatus => 'Nový status';

  @override
  String get statusPublish => 'Publikovat';

  @override
  String get statusExpiresIn24h => 'Status vyprší za 24 hodin';

  @override
  String get statusWhatsOnYourMind => 'Co máte na mysli?';

  @override
  String get statusPhotoAttached => 'Fotografie přiložena';

  @override
  String get statusAttachPhoto => 'Přiložit fotografii (volitelné)';

  @override
  String get statusEnterText => 'Zadejte prosím text pro svůj status.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Nepodařilo se vybrat fotografii: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Publikování selhalo: $error';
  }

  @override
  String get panicSetPanicKey => 'Nastavit panický klíč';

  @override
  String get panicEmergencySelfDestruct => 'Nouzová autodestrukce';

  @override
  String get panicIrreversible => 'Tato akce je nevratná';

  @override
  String get panicWarningBody =>
      'Zadání tohoto klíče na zamykací obrazovce okamžitě smaže VŠECHNA data — zprávy, kontakty, klíče, identitu. Použijte klíč odlišný od vašeho běžného hesla.';

  @override
  String get panicKeyHint => 'Panický klíč';

  @override
  String get panicConfirmHint => 'Potvrdit panický klíč';

  @override
  String get panicMinChars => 'Panický klíč musí mít alespoň 8 znaků';

  @override
  String get panicKeysDoNotMatch => 'Klíče se neshodují';

  @override
  String get panicSetFailed =>
      'Panický klíč se nepodařilo uložit — zkuste to prosím znovu';

  @override
  String get passwordSetAppPassword => 'Nastavit heslo aplikace';

  @override
  String get passwordProtectsMessages => 'Chrání vaše zprávy v klidu';

  @override
  String get passwordInfoBanner =>
      'Vyžadováno při každém otevření aplikace Pulse. Pokud ho zapomenete, vaše data nelze obnovit.';

  @override
  String get passwordHint => 'Heslo';

  @override
  String get passwordConfirmHint => 'Potvrdit heslo';

  @override
  String get passwordSetButton => 'Nastavit heslo';

  @override
  String get passwordSkipForNow => 'Prozatím přeskočit';

  @override
  String get passwordMinChars => 'Heslo musí mít alespoň 8 znaků';

  @override
  String get passwordNeedsVariety =>
      'Musí obsahovat písmena, čísla a speciální znaky';

  @override
  String get passwordRequirements =>
      'Min. 8 znaků s písmeny, čísly a speciálním znakem';

  @override
  String get passwordsDoNotMatch => 'Hesla se neshodují';

  @override
  String get profileCardSaved => 'Profil uložen!';

  @override
  String get profileCardE2eeIdentity => 'E2EE identita';

  @override
  String get profileCardDisplayName => 'Zobrazované jméno';

  @override
  String get profileCardDisplayNameHint => 'např. Jan Novák';

  @override
  String get profileCardAbout => 'O mně';

  @override
  String get profileCardSaveProfile => 'Uložit profil';

  @override
  String get profileCardYourName => 'Vaše jméno';

  @override
  String get profileCardAddressCopied => 'Adresa zkopírována!';

  @override
  String get profileCardInboxAddress => 'Vaše adresa příchozí pošty';

  @override
  String get profileCardInboxAddresses => 'Vaše adresy příchozí pošty';

  @override
  String get profileCardShareAllAddresses =>
      'Sdílet všechny adresy (SmartRouter)';

  @override
  String get profileCardShareHint => 'Sdílejte s kontakty, aby vám mohli psát.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Všech $count adres zkopírováno jako jeden odkaz!';
  }

  @override
  String get settingsMyProfile => 'Můj profil';

  @override
  String get settingsYourInboxAddress => 'Vaše adresa příchozí pošty';

  @override
  String get settingsMyQrCode => 'Sdílet kontakt';

  @override
  String get settingsMyQrSubtitle => 'QR kód a odkaz pozvánky pro vaši adresu';

  @override
  String get settingsShareMyAddress => 'Sdílet mou adresu';

  @override
  String get settingsNoAddressYet =>
      'Zatím žádná adresa — nejdříve uložte nastavení';

  @override
  String get settingsInviteLink => 'Odkaz s pozvánkou';

  @override
  String get settingsRawAddress => 'Nezpracovaná adresa';

  @override
  String get settingsCopyLink => 'Kopírovat odkaz';

  @override
  String get settingsCopyAddress => 'Kopírovat adresu';

  @override
  String get settingsInviteLinkCopied => 'Odkaz s pozvánkou zkopírován';

  @override
  String get settingsAppearance => 'Vzhled';

  @override
  String get settingsThemeEngine => 'Systém motivů';

  @override
  String get settingsThemeEngineSubtitle => 'Přizpůsobit barvy a písma';

  @override
  String get settingsSignalProtocol => 'Protokol Signal';

  @override
  String get settingsSignalProtocolSubtitle =>
      'E2EE klíče jsou bezpečně uloženy';

  @override
  String get settingsActive => 'AKTIVNÍ';

  @override
  String get settingsIdentityBackup => 'Záloha identity';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Exportovat nebo importovat identitu Signal';

  @override
  String get settingsIdentityBackupBody =>
      'Exportujte své klíče identity Signal do záložního kódu nebo obnovte z existujícího.';

  @override
  String get settingsTransferDevice => 'Přenos na jiné zařízení';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Přeneste identitu přes LAN nebo Nostr relay';

  @override
  String get settingsExportIdentity => 'Exportovat identitu';

  @override
  String get settingsExportIdentityBody =>
      'Zkopírujte tento záložní kód a uložte ho bezpečně:';

  @override
  String get settingsSaveFile => 'Uložit soubor';

  @override
  String get settingsImportIdentity => 'Importovat identitu';

  @override
  String get settingsImportIdentityBody =>
      'Vložte záložní kód níže. Tím přepíšete svou současnou identitu.';

  @override
  String get settingsPasteBackupCode => 'Vložte záložní kód zde…';

  @override
  String get settingsIdentityImported =>
      'Identita + kontakty importovány! Restartujte aplikaci pro použití.';

  @override
  String get settingsSecurity => 'Zabezpečení';

  @override
  String get settingsAppPassword => 'Heslo aplikace';

  @override
  String get settingsPasswordEnabled =>
      'Povoleno — vyžadováno při každém spuštění';

  @override
  String get settingsPasswordDisabled =>
      'Zakázáno — aplikace se otevře bez hesla';

  @override
  String get settingsChangePassword => 'Změnit heslo';

  @override
  String get settingsChangePasswordSubtitle =>
      'Aktualizovat heslo zámku aplikace';

  @override
  String get settingsSetPanicKey => 'Nastavit panický klíč';

  @override
  String get settingsChangePanicKey => 'Změnit panický klíč';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Aktualizovat nouzový klíč pro smazání';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Jeden klíč, který okamžitě smaže všechna data';

  @override
  String get settingsRemovePanicKey => 'Odstranit panický klíč';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Deaktivovat nouzovou autodestrukci';

  @override
  String get settingsRemovePanicKeyBody =>
      'Nouzová autodestrukce bude deaktivována. Můžete ji kdykoli znovu aktivovat.';

  @override
  String get settingsDisableAppPassword => 'Deaktivovat heslo aplikace';

  @override
  String get settingsEnterCurrentPassword =>
      'Zadejte současné heslo pro potvrzení';

  @override
  String get settingsCurrentPassword => 'Současné heslo';

  @override
  String get settingsIncorrectPassword => 'Nesprávné heslo';

  @override
  String get settingsPasswordUpdated => 'Heslo aktualizováno';

  @override
  String get settingsChangePasswordProceed =>
      'Zadejte současné heslo pro pokračování';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsBackupMessages => 'Zálohovat zprávy';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Exportovat šifrovanou historii zpráv do souboru';

  @override
  String get settingsRestoreMessages => 'Obnovit zprávy';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Importovat zprávy ze záložního souboru';

  @override
  String get settingsExportKeys => 'Exportovat klíče';

  @override
  String get settingsExportKeysSubtitle =>
      'Uložit identitní klíče do šifrovaného souboru';

  @override
  String get settingsImportKeys => 'Importovat klíče';

  @override
  String get settingsImportKeysSubtitle =>
      'Obnovit identitní klíče z exportovaného souboru';

  @override
  String get settingsBackupPassword => 'Heslo zálohy';

  @override
  String get settingsPasswordCannotBeEmpty => 'Heslo nesmí být prázdné';

  @override
  String get settingsPasswordMin4Chars => 'Heslo musí mít alespoň 4 znaky';

  @override
  String get settingsCallsTurn => 'Hovory a TURN';

  @override
  String get settingsLocalNetwork => 'Lokální síť';

  @override
  String get settingsCensorshipResistance => 'Odolnost proti cenzuře';

  @override
  String get settingsNetwork => 'Síť';

  @override
  String get settingsProxyTunnels => 'Proxy a tunely';

  @override
  String get settingsTurnServers => 'TURN servery';

  @override
  String get settingsProviderTitle => 'Poskytovatel';

  @override
  String get settingsLanFallback => 'Záložní LAN';

  @override
  String get settingsLanFallbackSubtitle =>
      'Vysílat přítomnost a doručovat zprávy v lokální síti, když internet není dostupný. Deaktivujte v nedůvěryhodných sítích (veřejná Wi-Fi).';

  @override
  String get settingsBgDelivery => 'Doručování na pozadí';

  @override
  String get settingsBgDeliverySubtitle =>
      'Pokračovat v přijímání zpráv, když je aplikace minimalizována. Zobrazí trvalé oznámení.';

  @override
  String get settingsYourInboxProvider => 'Váš poskytovatel příchozí pošty';

  @override
  String get settingsConnectionDetails => 'Podrobnosti připojení';

  @override
  String get settingsSaveAndConnect => 'Uložit a připojit';

  @override
  String get settingsSecondaryInboxes => 'Sekundární schránky';

  @override
  String get settingsAddSecondaryInbox => 'Přidat sekundární schránku';

  @override
  String get settingsAdvanced => 'Pokročilé';

  @override
  String get settingsDiscover => 'Objevit';

  @override
  String get settingsAbout => 'O aplikaci';

  @override
  String get settingsPrivacyPolicy => 'Zásady ochrany osobních údajů';

  @override
  String get settingsPrivacyPolicySubtitle => 'Jak Pulse chrání vaše data';

  @override
  String get settingsCrashReporting => 'Hlášení pádů';

  @override
  String get settingsCrashReportingSubtitle =>
      'Odesílat anonymní hlášení o pádech pro zlepšení Pulse. Žádný obsah zpráv ani kontakty se nikdy neodesílají.';

  @override
  String get settingsCrashReportingEnabled =>
      'Hlášení pádů povoleno — restartujte aplikaci pro použití';

  @override
  String get settingsCrashReportingDisabled =>
      'Hlášení pádů zakázáno — restartujte aplikaci pro použití';

  @override
  String get settingsSensitiveOperation => 'Citlivá operace';

  @override
  String get settingsSensitiveOperationBody =>
      'Tyto klíče jsou vaše identita. Kdokoli s tímto souborem se může za vás vydávat. Uložte ho bezpečně a po přenosu ho smažte.';

  @override
  String get settingsIUnderstandContinue => 'Rozumím, pokračovat';

  @override
  String get settingsReplaceIdentity => 'Nahradit identitu?';

  @override
  String get settingsReplaceIdentityBody =>
      'Tím přepíšete vaše současné identitní klíče. Vaše stávající relace Signal budou zneplatněny a kontakty budou muset znovu navázat šifrování. Aplikace bude muset být restartována.';

  @override
  String get settingsReplaceKeys => 'Nahradit klíče';

  @override
  String get settingsKeysImported => 'Klíče importovány';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count klíčů úspěšně importováno. Restartujte prosím aplikaci pro inicializaci s novou identitou.';
  }

  @override
  String get settingsRestartNow => 'Restartovat nyní';

  @override
  String get settingsLater => 'Později';

  @override
  String get profileGroupLabel => 'Skupina';

  @override
  String get profileAddButton => 'Přidat';

  @override
  String get profileKickButton => 'Vyloučit';

  @override
  String get dataSectionTitle => 'Data';

  @override
  String get dataBackupMessages => 'Zálohovat zprávy';

  @override
  String get dataBackupPasswordSubtitle =>
      'Zvolte heslo pro zašifrování zálohy zpráv.';

  @override
  String get dataBackupConfirmLabel => 'Vytvořit zálohu';

  @override
  String get dataCreatingBackup => 'Vytváření zálohy';

  @override
  String get dataBackupPreparing => 'Příprava...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Export zprávy $done z $total...';
  }

  @override
  String get dataBackupSavingFile => 'Ukládání souboru...';

  @override
  String get dataSaveMessageBackupDialog => 'Uložit zálohu zpráv';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Záloha uložena ($count zpráv)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Záloha selhala — žádná data nebyla exportována';

  @override
  String dataBackupFailedError(String error) {
    return 'Záloha selhala: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Vybrat zálohu zpráv';

  @override
  String get dataInvalidBackupFile => 'Neplatný záložní soubor (příliš malý)';

  @override
  String get dataNotValidBackupFile => 'Neplatný záložní soubor Pulse';

  @override
  String get dataRestoreMessages => 'Obnovit zprávy';

  @override
  String get dataRestorePasswordSubtitle =>
      'Zadejte heslo použité k vytvoření této zálohy.';

  @override
  String get dataRestoreConfirmLabel => 'Obnovit';

  @override
  String get dataRestoringMessages => 'Obnovování zpráv';

  @override
  String get dataRestoreDecrypting => 'Dešifrování...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Import zprávy $done z $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Obnovení selhalo — nesprávné heslo nebo poškozený soubor';

  @override
  String dataRestoreSuccess(int count) {
    return 'Obnoveno $count nových zpráv';
  }

  @override
  String get dataRestoreNothingNew =>
      'Žádné nové zprávy k importu (všechny již existují)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Obnovení selhalo: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Vybrat export klíčů';

  @override
  String get dataNotValidKeyFile => 'Neplatný soubor exportu klíčů Pulse';

  @override
  String get dataExportKeys => 'Exportovat klíče';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Zvolte heslo pro zašifrování exportu klíčů.';

  @override
  String get dataExportKeysConfirmLabel => 'Exportovat';

  @override
  String get dataExportingKeys => 'Export klíčů';

  @override
  String get dataExportingKeysStatus => 'Šifrování identitních klíčů...';

  @override
  String get dataSaveKeyExportDialog => 'Uložit export klíčů';

  @override
  String dataKeysExportedTo(String path) {
    return 'Klíče exportovány do:\n$path';
  }

  @override
  String get dataExportFailed => 'Export selhal — žádné klíče nenalezeny';

  @override
  String dataExportFailedError(String error) {
    return 'Export selhal: $error';
  }

  @override
  String get dataImportKeys => 'Importovat klíče';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Zadejte heslo použité k zašifrování tohoto exportu klíčů.';

  @override
  String get dataImportKeysConfirmLabel => 'Importovat';

  @override
  String get dataImportingKeys => 'Import klíčů';

  @override
  String get dataImportingKeysStatus => 'Dešifrování identitních klíčů...';

  @override
  String get dataImportFailed =>
      'Import selhal — nesprávné heslo nebo poškozený soubor';

  @override
  String dataImportFailedError(String error) {
    return 'Import selhal: $error';
  }

  @override
  String get securitySectionTitle => 'Zabezpečení';

  @override
  String get securityIncorrectPassword => 'Nesprávné heslo';

  @override
  String get securityPasswordUpdated => 'Heslo aktualizováno';

  @override
  String get appearanceSectionTitle => 'Vzhled';

  @override
  String appearanceExportFailed(String error) {
    return 'Export selhal: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Uloženo do $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Uložení selhalo: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Import selhal: $error';
  }

  @override
  String get aboutSectionTitle => 'O aplikaci';

  @override
  String get providerPublicKey => 'Veřejný klíč';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Automaticky nakonfigurováno z hesla pro obnovení. Relay automaticky nalezen.';

  @override
  String get providerKeyStoredLocally =>
      'Váš klíč je uložen lokálně v zabezpečeném úložišti — nikdy není odeslán na žádný server.';

  @override
  String get providerSessionInfo =>
      'Session Network — E2EE s cibulkovým směrováním. Vaše Session ID se generuje automaticky a ukládá se bezpečně. Uzly se automaticky zjišťují z vestavěných základních uzlů.';

  @override
  String get providerAdvanced => 'Pokročilé';

  @override
  String get providerSaveAndConnect => 'Uložit a připojit';

  @override
  String get providerAddSecondaryInbox => 'Přidat sekundární schránku';

  @override
  String get providerSecondaryInboxes => 'Sekundární schránky';

  @override
  String get providerYourInboxProvider => 'Váš poskytovatel příchozí pošty';

  @override
  String get providerConnectionDetails => 'Podrobnosti připojení';

  @override
  String get addContactTitle => 'Přidat kontakt';

  @override
  String get addContactInviteLinkLabel => 'Odkaz s pozvánkou nebo adresa';

  @override
  String get addContactTapToPaste => 'Klepněte pro vložení odkazu s pozvánkou';

  @override
  String get addContactPasteTooltip => 'Vložit ze schránky';

  @override
  String get addContactAddressDetected => 'Adresa kontaktu rozpoznána';

  @override
  String addContactRoutesDetected(int count) {
    return '$count tras rozpoznáno — SmartRouter vybere nejrychlejší';
  }

  @override
  String get addContactFetchingProfile => 'Načítání profilu…';

  @override
  String addContactProfileFound(String name) {
    return 'Nalezeno: $name';
  }

  @override
  String get addContactNoProfileFound => 'Profil nenalezen';

  @override
  String get addContactDisplayNameLabel => 'Zobrazované jméno';

  @override
  String get addContactDisplayNameHint => 'Jak je chcete nazývat?';

  @override
  String get addContactAddManually => 'Zadat adresu ručně';

  @override
  String get addContactButton => 'Přidat kontakt';

  @override
  String get networkDiagnosticsTitle => 'Diagnostika sítě';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr Relay';

  @override
  String get networkDiagnosticsDirect => 'Přímé';

  @override
  String get networkDiagnosticsTorOnly => 'Pouze Tor';

  @override
  String get networkDiagnosticsBest => 'Nejlepší';

  @override
  String get networkDiagnosticsNone => 'žádné';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Stav';

  @override
  String get networkDiagnosticsConnected => 'Připojeno';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Připojování $percent %';
  }

  @override
  String get networkDiagnosticsOff => 'Vypnuto';

  @override
  String get networkDiagnosticsTransport => 'Transport';

  @override
  String get networkDiagnosticsInfrastructure => 'Infrastruktura';

  @override
  String get networkDiagnosticsSessionNodes => 'Session uzly';

  @override
  String get networkDiagnosticsTurnServers => 'TURN servery';

  @override
  String get networkDiagnosticsLastProbe => 'Poslední sonda';

  @override
  String get networkDiagnosticsRunning => 'Probíhá...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Spustit diagnostiku';

  @override
  String get networkDiagnosticsForceReprobe => 'Vynutit úplnou opětovnou sondu';

  @override
  String get networkDiagnosticsJustNow => 'právě teď';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'před $minutes min';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'před $hours hod';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'před $days dny';
  }

  @override
  String get homeNoEch => 'Bez ECH';

  @override
  String get homeNoEchTooltip =>
      'uTLS proxy nedostupný — ECH deaktivováno.\nOtisk TLS je viditelný pro DPI.';

  @override
  String get settingsTitle => 'Nastavení';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Uloženo a připojeno k $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Vestavěný Tor se nepodařilo spustit';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon se nepodařilo spustit';

  @override
  String get verifyTitle => 'Ověřit bezpečnostní číslo';

  @override
  String get verifyIdentityVerified => 'Identita ověřena';

  @override
  String get verifyNotYetVerified => 'Zatím neověřeno';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Ověřili jste bezpečnostní číslo kontaktu $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Porovnejte tato čísla s kontaktem $name osobně nebo přes důvěryhodný kanál.';
  }

  @override
  String get verifyExplanation =>
      'Každá konverzace má jedinečné bezpečnostní číslo. Pokud oba vidíte stejná čísla na svých zařízeních, vaše spojení je ověřeno end-to-end.';

  @override
  String verifyContactKey(String name) {
    return 'Klíč kontaktu $name';
  }

  @override
  String get verifyYourKey => 'Váš klíč';

  @override
  String get verifyRemoveVerification => 'Zrušit ověření';

  @override
  String get verifyMarkAsVerified => 'Označit jako ověřené';

  @override
  String verifyAfterReinstall(String name) {
    return 'Pokud $name přeinstaluje aplikaci, bezpečnostní číslo se změní a ověření bude automaticky odstraněno.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Označte jako ověřené až po porovnání čísel s kontaktem $name při hlasovém hovoru nebo osobně.';
  }

  @override
  String get verifyNoSession =>
      'Zatím nebyla navázána šifrovací relace. Nejdříve odešlete zprávu pro vygenerování bezpečnostních čísel.';

  @override
  String get verifyNoKeyAvailable => 'Klíč není k dispozici';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Otisk $label zkopírován';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL databáze';

  @override
  String get providerOptionalHint => 'Volitelné';

  @override
  String get providerWebApiKeyLabel => 'Webový API klíč';

  @override
  String get providerOptionalForPublicDb => 'Volitelné pro veřejnou databázi';

  @override
  String get providerRelayUrlLabel => 'URL relay';

  @override
  String get providerPrivateKeyLabel => 'Soukromý klíč';

  @override
  String get providerPrivateKeyNsecLabel => 'Soukromý klíč (nsec)';

  @override
  String get providerStorageNodeLabel => 'URL uzlu úložiště (volitelné)';

  @override
  String get providerStorageNodeHint =>
      'Ponechte prázdné pro vestavěné seed uzly';

  @override
  String get transferInvalidCodeFormat =>
      'Nerozpoznaný formát kódu — musí začínat LAN: nebo NOS:';

  @override
  String get profileCardFingerprintCopied => 'Otisk zkopírován';

  @override
  String get profileCardAboutHint => 'Soukromí na prvním místě 🔒';

  @override
  String get profileCardSaveButton => 'Uložit profil';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Exportovat šifrované zprávy, kontakty a avatary do souboru';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Audio';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Doručeno: $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Doručeno: $count';
  }

  @override
  String get groupStatusDialogTitle => 'Informace o zprávě';

  @override
  String get groupStatusRead => 'Přečteno';

  @override
  String get groupStatusDelivered => 'Doručeno';

  @override
  String get groupStatusPending => 'Čeká na doručení';

  @override
  String get groupStatusNoData => 'Zatím žádné informace o doručení';

  @override
  String get profileTransferAdmin => 'Jmenovat správcem';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Jmenovat $name novým správcem?';
  }

  @override
  String get profileTransferAdminBody =>
      'Přijdete o oprávnění správce. Tuto akci nelze vrátit zpět.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name je nyní správcem';
  }

  @override
  String get profileAdminBadge => 'Správce';

  @override
  String get privacyPolicyTitle => 'Zásady ochrany osobních údajů';

  @override
  String get privacyOverviewHeading => 'Přehled';

  @override
  String get privacyOverviewBody =>
      'Pulse je messenger bez serverů se šifrováním end-to-end. Vaše soukromí není jen funkce — je to architektura. Neexistují žádné servery Pulse. Žádné účty nejsou nikde uloženy. Žádná data nejsou vývojáři sbírána, přenášena ani ukládána.';

  @override
  String get privacyDataCollectionHeading => 'Sběr dat';

  @override
  String get privacyDataCollectionBody =>
      'Pulse neshromažďuje žádné osobní údaje. Konkrétně:\n\n- Není vyžadován e-mail, telefonní číslo ani skutečné jméno\n- Žádné analýzy, sledování ani telemetrie\n- Žádné reklamní identifikátory\n- Žádný přístup ke kontaktům\n- Žádné cloudové zálohy (zprávy existují pouze na vašem zařízení)\n- Žádná metadata nejsou odesílána na žádný server Pulse (žádné neexistují)';

  @override
  String get privacyEncryptionHeading => 'Šifrování';

  @override
  String get privacyEncryptionBody =>
      'Všechny zprávy jsou šifrovány protokolem Signal (Double Ratchet s dohodou klíčů X3DH). Šifrovací klíče jsou generovány a uloženy výhradně na vašem zařízení. Nikdo — včetně vývojářů — nemůže číst vaše zprávy.';

  @override
  String get privacyNetworkHeading => 'Síťová architektura';

  @override
  String get privacyNetworkBody =>
      'Pulse používá federované transportní adaptéry (Nostr relay, uzly služby Session/Oxen, Firebase Realtime Database, LAN). Tyto transporty přenášejí pouze šifrovaný text. Provozovatelé relay mohou vidět vaši IP adresu a objem provozu, ale nemohou dešifrovat obsah zpráv.\n\nKdyž je povolen Tor, vaše IP adresa je skryta i před provozovateli relay.';

  @override
  String get privacyStunHeading => 'STUN/TURN servery';

  @override
  String get privacyStunBody =>
      'Hlasové a videohovory používají WebRTC s šifrováním DTLS-SRTP. STUN servery (používané k zjištění vaší veřejné IP pro peer-to-peer spojení) a TURN servery (používané k přenosu médií, když přímé spojení selže) mohou vidět vaši IP adresu a délku hovoru, ale nemohou dešifrovat obsah hovoru.\n\nV Nastavení si můžete nakonfigurovat vlastní TURN server pro maximální soukromí.';

  @override
  String get privacyCrashHeading => 'Hlášení pádů';

  @override
  String get privacyCrashBody =>
      'Pokud je povoleno hlášení pádů Sentry (přes SENTRY_DSN při sestavení), mohou být odesílána anonymní hlášení o pádech. Neobsahují žádný obsah zpráv, žádné kontaktní informace a žádné osobně identifikovatelné údaje. Hlášení pádů lze deaktivovat při sestavení vynecháním DSN.';

  @override
  String get privacyPasswordHeading => 'Heslo a klíče';

  @override
  String get privacyPasswordBody =>
      'Vaše heslo pro obnovení se používá k odvození kryptografických klíčů přes Argon2id (paměťově náročná KDF). Heslo není nikam přenášeno. Pokud heslo ztratíte, váš účet nelze obnovit — neexistuje žádný server pro jeho resetování.';

  @override
  String get privacyFontsHeading => 'Písma';

  @override
  String get privacyFontsBody =>
      'Pulse obsahuje všechna písma lokálně. Nejsou prováděny žádné požadavky na Google Fonts ani žádné externí služby s písmy.';

  @override
  String get privacyThirdPartyHeading => 'Služby třetích stran';

  @override
  String get privacyThirdPartyBody =>
      'Pulse se neintegruje s žádnými reklamními sítěmi, poskytovateli analýz, platformami sociálních médií ani zprostředkovateli dat. Jediná síťová spojení jsou k transportním relay, které si nakonfigurujete.';

  @override
  String get privacyOpenSourceHeading => 'Open Source';

  @override
  String get privacyOpenSourceBody =>
      'Pulse je open-source software. Můžete prověřit kompletní zdrojový kód a ověřit si tato tvrzení o ochraně soukromí.';

  @override
  String get privacyContactHeading => 'Kontakt';

  @override
  String get privacyContactBody =>
      'V případě otázek ohledně soukromí otevřete issue v repozitáři projektu.';

  @override
  String get privacyLastUpdated => 'Poslední aktualizace: březen 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Uložení selhalo: $error';
  }

  @override
  String get themeEngineTitle => 'Systém motivů';

  @override
  String get torBuiltInTitle => 'Vestavěný Tor';

  @override
  String get torConnectedSubtitle =>
      'Připojeno — Nostr směrováno přes 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Připojování… $pct %';
  }

  @override
  String get torNotRunning => 'Neběží — klepněte pro restart';

  @override
  String get torDescription =>
      'Směruje Nostr přes Tor (Snowflake pro cenzurované sítě)';

  @override
  String get torNetworkDiagnostics => 'Diagnostika sítě';

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
  String get torPtPlain => 'Nešifrovaný';

  @override
  String get torTimeoutLabel => 'Časový limit: ';

  @override
  String get torInfoDescription =>
      'Když je povoleno, připojení Nostr WebSocket jsou směrována přes Tor (SOCKS5). Tor Browser naslouchá na 127.0.0.1:9150. Samostatný tor daemon používá port 9050. Připojení Firebase nejsou ovlivněna.';

  @override
  String get torRouteNostrTitle => 'Směrovat Nostr přes Tor';

  @override
  String get torManagedByBuiltin => 'Spravováno vestavěným Tor';

  @override
  String get torActiveRouting => 'Aktivní — provoz Nostr směrován přes Tor';

  @override
  String get torDisabled => 'Deaktivováno';

  @override
  String get torProxySocks5 => 'Tor Proxy (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Host proxy';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser: port 9150  •  tor daemon: port 9050';

  @override
  String get torForceNostrTitle => 'Směrovat zprávy přes Tor';

  @override
  String get torForceNostrSubtitle =>
      'Všechna připojení k Nostr relay půjdou přes Tor. Pomalejší, ale skryje vaši IP adresu před relay.';

  @override
  String get torForceNostrDisabled => 'Nejprve je třeba zapnout Tor';

  @override
  String get torForcePulseTitle => 'Směrovat Pulse relay přes Tor';

  @override
  String get torForcePulseSubtitle =>
      'Všechna připojení k Pulse relay půjdou přes Tor. Pomalejší, ale skryje vaši IP adresu před serverem.';

  @override
  String get torForcePulseDisabled => 'Nejprve je třeba zapnout Tor';

  @override
  String get i2pProxySocks5 => 'I2P Proxy (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P standardně používá SOCKS5 na portu 4447. Připojte se k Nostr relay přes I2P outproxy (např. relay.damus.i2p) pro komunikaci s uživateli na jakémkoli transportu. Tor má přednost, pokud jsou oba povoleny.';

  @override
  String get i2pRouteNostrTitle => 'Směrovat Nostr přes I2P';

  @override
  String get i2pActiveRouting => 'Aktivní — provoz Nostr směrován přes I2P';

  @override
  String get i2pDisabled => 'Deaktivováno';

  @override
  String get i2pProxyHostLabel => 'Host proxy';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'Výchozí SOCKS5 port I2P routeru: 4447';

  @override
  String get customProxySocks5 => 'Vlastní proxy (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Vlastní proxy směruje provoz přes váš V2Ray/Xray/Shadowsocks. CF Worker funguje jako osobní relay proxy na Cloudflare CDN — GFW vidí *.workers.dev, ne skutečný relay.';

  @override
  String get customSocks5ProxyTitle => 'Vlastní SOCKS5 proxy';

  @override
  String get customProxyActive => 'Aktivní — provoz směrován přes SOCKS5';

  @override
  String get customProxyDisabled => 'Deaktivováno';

  @override
  String get customProxyHostLabel => 'Host proxy';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Doména Worker (volitelné)';

  @override
  String get customWorkerHelpTitle => 'Jak nasadit CF Worker relay (zdarma)';

  @override
  String get customWorkerScriptCopied => 'Skript zkopírován!';

  @override
  String get customWorkerStep1 =>
      '1. Přejděte na dash.cloudflare.com → Workers & Pages\n2. Create Worker → vložte tento skript:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → zkopírujte doménu (např. my-relay.user.workers.dev)\n4. Vložte doménu výše → Uložit\n\nAplikace se automaticky připojí: wss://domain/?r=relay_url\nGFW vidí: připojení k *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Připojeno — SOCKS5 na 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Připojování…';

  @override
  String get psiphonNotRunning => 'Neběží — klepněte pro restart';

  @override
  String get psiphonDescription =>
      'Rychlý tunel (~3s bootstrap, 2000+ rotujících VPS)';

  @override
  String get turnCommunityServers => 'Komunitní TURN servery';

  @override
  String get turnCustomServer => 'Vlastní TURN server (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN servery pouze přenášejí již šifrované streamy (DTLS-SRTP). Provozovatel relay vidí vaši IP a objem provozu, ale nemůže dešifrovat hovory. TURN se používá pouze když přímé P2P selže (~15–20 % spojení).';

  @override
  String get turnFreeLabel => 'ZDARMA';

  @override
  String get turnServerUrlLabel => 'URL TURN serveru';

  @override
  String get turnServerUrlHint => 'turn:vas-server.com:3478 nebo turns:...';

  @override
  String get turnUsernameLabel => 'Uživatelské jméno';

  @override
  String get turnPasswordLabel => 'Heslo';

  @override
  String get turnOptionalHint => 'Volitelné';

  @override
  String get turnCustomInfo =>
      'Provozujte coturn na jakémkoli VPS za 5\$/měs. pro maximální kontrolu. Přihlašovací údaje jsou uloženy lokálně.';

  @override
  String get themePickerAppearance => 'Vzhled';

  @override
  String get themePickerAccentColor => 'Barva zvýraznění';

  @override
  String get themeModeLight => 'Světlý';

  @override
  String get themeModeDark => 'Tmavý';

  @override
  String get themeModeSystem => 'Systém';

  @override
  String get themeDynamicPresets => 'Předvolby';

  @override
  String get themeDynamicPrimaryColor => 'Primární barva';

  @override
  String get themeDynamicBorderRadius => 'Zaoblení rohů';

  @override
  String get themeDynamicFont => 'Písmo';

  @override
  String get themeDynamicAppearance => 'Vzhled';

  @override
  String get themeDynamicUiStyle => 'Styl UI';

  @override
  String get themeDynamicUiStyleDescription =>
      'Ovládá vzhled dialogů, přepínačů a indikátorů.';

  @override
  String get themeDynamicSharp => 'Ostrý';

  @override
  String get themeDynamicRound => 'Zaoblený';

  @override
  String get themeDynamicModeDark => 'Tmavý';

  @override
  String get themeDynamicModeLight => 'Světlý';

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
      'Neplatná Firebase URL. Očekáváno https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Neplatná URL relay. Očekáváno wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Neplatná URL serveru Pulse. Očekáváno https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'URL serveru';

  @override
  String get providerPulseServerUrlHint => 'https://vas-server:8443';

  @override
  String get providerPulseInviteLabel => 'Kód pozvánky';

  @override
  String get providerPulseInviteHint => 'Kód pozvánky (pokud je vyžadován)';

  @override
  String get providerPulseInfo =>
      'Vlastní relay. Klíče odvozeny z hesla pro obnovení.';

  @override
  String get providerScreenTitle => 'Schránky';

  @override
  String get providerSecondaryInboxesHeader => 'SEKUNDÁRNÍ SCHRÁNKY';

  @override
  String get providerSecondaryInboxesInfo =>
      'Sekundární schránky přijímají zprávy současně pro redundanci.';

  @override
  String get providerRemoveTooltip => 'Odstranit';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... nebo hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... nebo hex soukromý klíč';

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
  String get emojiNoRecent => 'Žádné nedávné emoji';

  @override
  String get emojiSearchHint => 'Hledat emoji...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Klepněte pro chat';

  @override
  String get imageViewerSaveToDownloads => 'Uložit do Stažené';

  @override
  String imageViewerSavedTo(String path) {
    return 'Uloženo do $path';
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
  String get settingsLanguageSubtitle => 'Jazyk zobrazení aplikace';

  @override
  String get settingsLanguageSystem => 'Výchozí systémový';

  @override
  String get onboardingLanguageTitle => 'Vyberte si jazyk';

  @override
  String get onboardingLanguageSubtitle =>
      'Můžete to změnit později v Nastavení';

  @override
  String get videoNoteRecord => 'Nahrát video zprávu';

  @override
  String get videoNoteTapToRecord => 'Klepnutím zahájíte nahrávání';

  @override
  String get videoNoteTapToStop => 'Klepnutím zastavíte';

  @override
  String get videoNoteCameraPermission => 'Přístup ke kameře byl odepřen';

  @override
  String get videoNoteMaxDuration => 'Maximum 30 sekund';

  @override
  String get videoNoteNotSupported =>
      'Video poznámky nejsou na této platformě podporovány';

  @override
  String get navChats => 'Chaty';

  @override
  String get navUpdates => 'Aktualizace';

  @override
  String get navCalls => 'Hovory';

  @override
  String get filterAll => 'Vše';

  @override
  String get filterUnread => 'Nepřečtené';

  @override
  String get filterGroups => 'Skupiny';

  @override
  String get callsNoRecent => 'Žádná nedávná volání';

  @override
  String get callsEmptySubtitle => 'Vaše historie hovorů se zobrazí zde';

  @override
  String get appBarEncrypted => 'šifrováno end-to-end';

  @override
  String get newStatus => 'Nový stav';

  @override
  String get newCall => 'Nový hovor';

  @override
  String get joinChannelTitle => 'Připojit se ke kanálu';

  @override
  String get joinChannelDescription => 'URL KANÁLU';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'Načítání informací o kanálu…';

  @override
  String get joinChannelNotFound => 'Na této URL nebyl nalezen žádný kanál';

  @override
  String get joinChannelNetworkError => 'Nelze se připojit k serveru';

  @override
  String get joinChannelAlreadyJoined => 'Již připojeno';

  @override
  String get joinChannelButton => 'Připojit se';

  @override
  String get channelFeedEmpty => 'Zatím žádné příspěvky';

  @override
  String get channelLeave => 'Opustit kanál';

  @override
  String get channelLeaveConfirm =>
      'Opustit tento kanál? Uložené příspěvky budou smazány.';

  @override
  String get channelInfo => 'Informace o kanálu';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'upraveno';

  @override
  String get channelLoadMore => 'Načíst další';

  @override
  String get channelSearchPosts => 'Hledat příspěvky…';

  @override
  String get channelNoResults => 'Žádné odpovídající příspěvky';

  @override
  String get channelUrl => 'URL kanálu';

  @override
  String get channelCreated => 'Připojeno';

  @override
  String channelPostCount(int count) {
    return '$count příspěvků';
  }

  @override
  String get channelCopyUrl => 'Kopírovat URL';

  @override
  String get setupNext => 'Další';

  @override
  String get setupKeyWarning =>
      'Bude vám vygenerován obnovovací klíč. Je to jediný způsob, jak obnovit účet na novém zařízení — neexistuje server, neexistuje reset hesla.';

  @override
  String get setupKeyTitle => 'Váš obnovovací klíč';

  @override
  String get setupKeySubtitle =>
      'Zapište si tento klíč a uložte ho na bezpečné místo. Budete ho potřebovat k obnovení účtu na novém zařízení.';

  @override
  String get setupKeyCopied => 'Zkopírováno!';

  @override
  String get setupKeyWroteItDown => 'Zapsal jsem si to';

  @override
  String get setupKeyWarnBody =>
      'Zapište si tento klíč jako zálohu. Můžete si ho také zobrazit později v Nastavení → Zabezpečení.';

  @override
  String get setupVerifyTitle => 'Ověřte obnovovací klíč';

  @override
  String get setupVerifySubtitle =>
      'Zadejte znovu svůj obnovovací klíč pro potvrzení, že jste si ho správně uložili.';

  @override
  String get setupVerifyButton => 'Ověřit';

  @override
  String get setupKeyMismatch =>
      'Klíč nesouhlasí. Zkontrolujte a zkuste to znovu.';

  @override
  String get setupSkipVerify => 'Přeskočit ověření';

  @override
  String get setupSkipVerifyTitle => 'Přeskočit ověření?';

  @override
  String get setupSkipVerifyBody =>
      'Pokud ztratíte obnovovací klíč, váš účet nelze obnovit. Opravdu chcete přeskočit?';

  @override
  String get setupCreatingAccount => 'Vytváření účtu…';

  @override
  String get setupRestoringAccount => 'Obnovování účtu…';

  @override
  String get restoreKeyInfoBanner =>
      'Zadejte svůj obnovovací klíč — vaše adresa (Nostr + Session) bude obnovena automaticky. Kontakty a zprávy byly uloženy pouze lokálně.';

  @override
  String get restoreKeyHint => 'Obnovovací klíč';

  @override
  String get settingsViewRecoveryKey => 'Zobrazit obnovovací klíč';

  @override
  String get settingsViewRecoveryKeySubtitle => 'Zobrazit obnovovací klíč účtu';

  @override
  String get settingsRecoveryKeyNotStored =>
      'Obnovovací klíč není k dispozici (vytvořen před touto funkcí)';

  @override
  String get settingsRecoveryKeyWarning =>
      'Uchovejte tento klíč v bezpečí. Kdokoli s ním může obnovit váš účet na jiném zařízení.';

  @override
  String get replaceIdentityTitle => 'Nahradit stávající identitu?';

  @override
  String get replaceIdentityBodyRestore =>
      'Na tomto zařízení již existuje identita. Obnovení trvale nahradí váš aktuální Nostr klíč a Oxen seed. Všechny kontakty ztratí možnost kontaktovat vaši současnou adresu.\n\nTuto akci nelze vrátit zpět.';

  @override
  String get replaceIdentityBodyCreate =>
      'Na tomto zařízení již existuje identita. Vytvoření nové trvale nahradí váš aktuální Nostr klíč a Oxen seed. Všechny kontakty ztratí možnost kontaktovat vaši současnou adresu.\n\nTuto akci nelze vrátit zpět.';

  @override
  String get replace => 'Nahradit';

  @override
  String get callNoScreenSources => 'Nejsou dostupné žádné zdroje obrazovky';

  @override
  String get callScreenShareQuality => 'Kvalita sdílení obrazovky';

  @override
  String get callFrameRate => 'Snímková frekvence';

  @override
  String get callResolution => 'Rozlišení';

  @override
  String get callAutoResolution => 'Auto = nativní rozlišení obrazovky';

  @override
  String get callStartSharing => 'Zahájit sdílení';

  @override
  String get callCameraUnavailable =>
      'Kamera není dostupná — může být používána jinou aplikací';

  @override
  String get themeResetToDefaults => 'Obnovit výchozí';

  @override
  String get backupSaveToDownloadsTitle => 'Uložit zálohu do Stažených?';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'Není k dispozici výběr souborů. Záloha bude uložena do:\n$path';
  }

  @override
  String get systemLabel => 'Systém';

  @override
  String get next => 'Další';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return 'Ještě $remaining klepnutí pro zapnutí vývojářského režimu';
  }

  @override
  String get devModeEnabled => 'Vývojářský režim zapnut';

  @override
  String get devTools => 'Vývojářské nástroje';

  @override
  String get devAdapterDiagnostics => 'Přepínače adaptéru a diagnostika';

  @override
  String get devEnableAll => 'Aktivovat vše';

  @override
  String get devDisableAll => 'Deaktivovat vše';

  @override
  String get turnUrlValidation =>
      'TURN URL musí začínat turn: nebo turns: (max 512 znaků)';

  @override
  String get callMissedCall => 'Zmeškaný hovor';

  @override
  String get callOutgoingCall => 'Odchozí hovor';

  @override
  String get callIncomingCall => 'Příchozí hovor';

  @override
  String get mediaMissingData => 'Chybějící mediální data';

  @override
  String get mediaDownloadFailed => 'Stahování selhalo';

  @override
  String get mediaDecryptFailed => 'Dešifrování selhalo';

  @override
  String get callEndCallBanner => 'Ukončit hovor';

  @override
  String get meFallback => 'Já';

  @override
  String get imageSaveToDownloads => 'Uložit do Stažených';

  @override
  String imageSavedToPath(String path) {
    return 'Uloženo do $path';
  }

  @override
  String get callScreenShareRequiresPermission =>
      'Sdílení obrazovky vyžaduje oprávnění';

  @override
  String get callScreenShareUnavailable => 'Sdílení obrazovky není dostupné';

  @override
  String get statusJustNow => 'Právě teď';

  @override
  String statusMinutesAgo(int minutes) {
    return 'před ${minutes}m';
  }

  @override
  String statusHoursAgo(int hours) {
    return 'před ${hours}h';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tras',
      one: '1 trasa',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => 'Připraveno k přidání';

  @override
  String groupSelectedCount(int count) {
    return '$count vybráno';
  }

  @override
  String get paste => 'Vložit';

  @override
  String get sfuAudioOnly => 'Pouze zvuk';

  @override
  String sfuParticipants(int count) {
    return '$count účastníků';
  }

  @override
  String get dataUnencryptedBackup => 'Nešifrovaná záloha';

  @override
  String get dataUnencryptedBackupBody =>
      'Tento soubor je nešifrovaná záloha identity a přepíše vaše stávající klíče. Importujte pouze soubory, které jste sami vytvořili. Pokračovat?';

  @override
  String get dataImportAnyway => 'Přesto importovat';

  @override
  String get securityStorageError =>
      'Chyba bezpečného úložiště — restartujte aplikaci';

  @override
  String get aboutDevModeActive => 'Vývojářský režim aktivní';

  @override
  String get themeColors => 'Barvy';

  @override
  String get themePrimaryAccent => 'Primární akcent';

  @override
  String get themeSecondaryAccent => 'Sekundární akcent';

  @override
  String get themeBackground => 'Pozadí';

  @override
  String get themeSurface => 'Povrch';

  @override
  String get themeChatBubbles => 'Chatovací bubliny';

  @override
  String get themeOutgoingMessage => 'Odchozí zpráva';

  @override
  String get themeIncomingMessage => 'Příchozí zpráva';

  @override
  String get themeShape => 'Tvar';

  @override
  String get devSectionDeveloper => 'Vývojář';

  @override
  String get devAdapterChannelsHint =>
      'Kanály adaptéru — deaktivujte pro testování konkrétních přenosů.';

  @override
  String get devNostrRelays => 'Nostr relay (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Síť Session';

  @override
  String get devPulseRelay => 'Pulse samohostovaný relay';

  @override
  String get devLanNetwork => 'Lokální síť (UDP/TCP)';

  @override
  String get devSectionCalls => 'Hovory';

  @override
  String get devForceTurnRelay => 'Vynutit TURN relay';

  @override
  String get devForceTurnRelaySubtitle =>
      'Deaktivovat P2P — všechny hovory pouze přes TURN servery';

  @override
  String get devRestartWarning =>
      '⚠ Změny se projeví při dalším odesílání/hovoru. Restartujte aplikaci pro příchozí.';

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
  String get pulseUseServerTitle => 'Použít server Pulse?';

  @override
  String pulseUseServerBody(String name, String host) {
    return '$name používá server Pulse $host. Připojit se, abyste si mohli rychleji chatovat (a s ostatními na stejném serveru)?';
  }

  @override
  String pulseContactUsesPulse(String name) {
    return '$name používá Pulse';
  }

  @override
  String pulseJoinForFaster(String host) {
    return 'Připojit se k $host pro rychlejší chat';
  }

  @override
  String get pulseNotNow => 'Teď ne';

  @override
  String get pulseJoin => 'Připojit se';

  @override
  String get pulseDismiss => 'Zavřít';

  @override
  String get pulseHide7Days => 'Skrýt na 7 dní';

  @override
  String get pulseNeverAskAgain => 'Neptat se znovu';

  @override
  String get groupSearchContactsHint => 'Hledat kontakty…';
}
