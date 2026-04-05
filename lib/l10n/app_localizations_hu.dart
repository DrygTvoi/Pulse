// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Keresés az üzenetekben...';

  @override
  String get search => 'Keresés';

  @override
  String get clearSearch => 'Keresés törlése';

  @override
  String get closeSearch => 'Keresés bezárása';

  @override
  String get moreOptions => 'További lehetőségek';

  @override
  String get back => 'Vissza';

  @override
  String get cancel => 'Mégse';

  @override
  String get close => 'Bezárás';

  @override
  String get confirm => 'Megerősítés';

  @override
  String get remove => 'Eltávolítás';

  @override
  String get save => 'Mentés';

  @override
  String get add => 'Hozzáadás';

  @override
  String get copy => 'Másolás';

  @override
  String get skip => 'Kihagyás';

  @override
  String get done => 'Kész';

  @override
  String get apply => 'Alkalmaz';

  @override
  String get export => 'Exportálás';

  @override
  String get import => 'Importálás';

  @override
  String get homeNewGroup => 'Új csoport';

  @override
  String get homeSettings => 'Beállítások';

  @override
  String get homeSearching => 'Keresés az üzenetekben...';

  @override
  String get homeNoResults => 'Nincs találat';

  @override
  String get homeNoChatHistory => 'Még nincs csevegési előzmény';

  @override
  String homeTransportSwitched(String address) {
    return 'Átvitel váltva → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name hív...';
  }

  @override
  String get homeAccept => 'Elfogadás';

  @override
  String get homeDecline => 'Elutasítás';

  @override
  String get homeLoadEarlier => 'Korábbi üzenetek betöltése';

  @override
  String get homeChats => 'Csevegések';

  @override
  String get homeSelectConversation => 'Válassz egy beszélgetést';

  @override
  String get homeNoChatsYet => 'Még nincs csevegés';

  @override
  String get homeAddContactToStart =>
      'Adj hozzá egy névjegyet a csevegés indításához';

  @override
  String get homeNewChat => 'Új csevegés';

  @override
  String get homeNewChatTooltip => 'Új csevegés';

  @override
  String get homeIncomingCallTitle => 'Bejövő hívás';

  @override
  String get homeIncomingGroupCallTitle => 'Bejövő csoporthívás';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — bejövő csoporthívás';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Nincs egyező csevegés: \"$query\"';
  }

  @override
  String get homeSectionChats => 'Csevegések';

  @override
  String get homeSectionMessages => 'Üzenetek';

  @override
  String get homeDbEncryptionUnavailable =>
      'Adatbázis-titkosítás nem elérhető — telepítsd az SQLCipher-t a teljes védelemhez';

  @override
  String get chatFileTooLargeGroup =>
      'Az 512 KB-nál nagyobb fájlok nem támogatottak csoportos csevegésben';

  @override
  String get chatLargeFile => 'Nagy fájl';

  @override
  String get chatCancel => 'Mégse';

  @override
  String get chatSend => 'Küldés';

  @override
  String get chatFileTooLarge => 'A fájl túl nagy — a maximális méret 100 MB';

  @override
  String get chatMicDenied => 'Mikrofon engedély megtagadva';

  @override
  String get chatVoiceFailed =>
      'A hangüzenet mentése sikertelen — ellenőrizd a szabad tárhelyet';

  @override
  String get chatScheduleFuture =>
      'Az ütemezett időpontnak a jövőben kell lennie';

  @override
  String get chatToday => 'Ma';

  @override
  String get chatYesterday => 'Tegnap';

  @override
  String get chatEdited => 'szerkesztve';

  @override
  String get chatYou => 'Te';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Ez a fájl $size MB. A nagy fájlok küldése egyes hálózatokon lassú lehet. Folytatod?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return '$name biztonsági kulcsa megváltozott. Koppints az ellenőrzéshez.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Nem sikerült titkosítani az üzenetet $name számára — az üzenet nem lett elküldve.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'A biztonsági szám megváltozott $name esetében. Koppints az ellenőrzéshez.';
  }

  @override
  String get chatNoMessagesFound => 'Nem találhatók üzenetek';

  @override
  String get chatMessagesE2ee =>
      'Az üzenetek végponttól végpontig titkosítottak';

  @override
  String get chatSayHello => 'Köszönj';

  @override
  String get appBarOnline => 'online';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'gépel';

  @override
  String get appBarSearchMessages => 'Keresés az üzenetekben...';

  @override
  String get appBarMute => 'Némítás';

  @override
  String get appBarUnmute => 'Némítás feloldása';

  @override
  String get appBarMedia => 'Média';

  @override
  String get appBarDisappearing => 'Eltűnő üzenetek';

  @override
  String get appBarDisappearingOn => 'Eltűnő: bekapcsolva';

  @override
  String get appBarGroupSettings => 'Csoport beállítások';

  @override
  String get appBarSearchTooltip => 'Keresés az üzenetekben';

  @override
  String get appBarVoiceCall => 'Hanghívás';

  @override
  String get appBarVideoCall => 'Videohívás';

  @override
  String get inputMessage => 'Üzenet...';

  @override
  String get inputAttachFile => 'Fájl csatolása';

  @override
  String get inputSendMessage => 'Üzenet küldése';

  @override
  String get inputRecordVoice => 'Hangüzenet rögzítése';

  @override
  String get inputSendVoice => 'Hangüzenet küldése';

  @override
  String get inputCancelReply => 'Válasz megszakítása';

  @override
  String get inputCancelEdit => 'Szerkesztés megszakítása';

  @override
  String get inputCancelRecording => 'Felvétel megszakítása';

  @override
  String get inputRecording => 'Felvétel…';

  @override
  String get inputEditingMessage => 'Üzenet szerkesztése';

  @override
  String get inputPhoto => 'Fotó';

  @override
  String get inputVoiceMessage => 'Hangüzenet';

  @override
  String get inputFile => 'Fájl';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count ütemezett üzenet$_temp0';
  }

  @override
  String get callInitializing => 'Hívás inicializálása…';

  @override
  String get callConnecting => 'Csatlakozás…';

  @override
  String get callConnectingRelay => 'Csatlakozás (relay)…';

  @override
  String get callSwitchingRelay => 'Váltás relay módra…';

  @override
  String get callConnectionFailed => 'A kapcsolat sikertelen';

  @override
  String get callReconnecting => 'Újracsatlakozás…';

  @override
  String get callEnded => 'Hívás befejezve';

  @override
  String get callLive => 'Élő';

  @override
  String get callEnd => 'Vége';

  @override
  String get callEndCall => 'Hívás befejezése';

  @override
  String get callMute => 'Némítás';

  @override
  String get callUnmute => 'Némítás feloldása';

  @override
  String get callSpeaker => 'Hangszóró';

  @override
  String get callCameraOn => 'Kamera be';

  @override
  String get callCameraOff => 'Kamera ki';

  @override
  String get callShareScreen => 'Képernyő megosztása';

  @override
  String get callStopShare => 'Megosztás leállítása';

  @override
  String callTorBackup(String duration) {
    return 'Tor tartalék · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor tartalék aktív — az elsődleges útvonal nem elérhető';

  @override
  String get callDirectFailed =>
      'A közvetlen kapcsolat sikertelen — váltás relay módra…';

  @override
  String get callTurnUnreachable =>
      'A TURN szerverek nem elérhetők. Adj hozzá egyéni TURN-t a Beállítások → Speciális menüben.';

  @override
  String get callRelayMode => 'Relay mód aktív (korlátozott hálózat)';

  @override
  String get callStarting => 'Hívás indítása…';

  @override
  String get callConnectingToGroup => 'Csatlakozás a csoporthoz…';

  @override
  String get callGroupOpenedInBrowser => 'Csoporthívás megnyitva a böngészőben';

  @override
  String get callCouldNotOpenBrowser => 'Nem sikerült megnyitni a böngészőt';

  @override
  String get callInviteLinkSent =>
      'Meghívó link elküldve az összes csoporttagnak.';

  @override
  String get callOpenLinkManually =>
      'Nyisd meg a fenti linket manuálisan, vagy koppints az újrapróbálkozáshoz.';

  @override
  String get callJitsiNotE2ee =>
      'A Jitsi hívások NEM végponttól végpontig titkosítottak';

  @override
  String get callRetryOpenBrowser => 'Böngésző megnyitásának újrapróbálása';

  @override
  String get callClose => 'Bezárás';

  @override
  String get callCamOn => 'Kamera be';

  @override
  String get callCamOff => 'Kamera ki';

  @override
  String get noConnection => 'Nincs kapcsolat — az üzenetek sorba kerülnek';

  @override
  String get connected => 'Csatlakozva';

  @override
  String get connecting => 'Csatlakozás…';

  @override
  String get disconnected => 'Lecsatlakozva';

  @override
  String get offlineBanner =>
      'Nincs kapcsolat — az üzenetek el lesznek küldve, amint újra online leszel';

  @override
  String get lanModeBanner => 'LAN mód — Nincs internet · Csak helyi hálózat';

  @override
  String get probeCheckingNetwork => 'Hálózati kapcsolat ellenőrzése…';

  @override
  String get probeDiscoveringRelays =>
      'Relay-k felfedezése közösségi könyvtárakon keresztül…';

  @override
  String get probeStartingTor => 'Tor indítása a bootstraphoz…';

  @override
  String get probeFindingRelaysTor =>
      'Elérhető relay-k keresése Tor-on keresztül…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'Hálózat kész — $count relay$_temp0 találva';
  }

  @override
  String get probeNoRelaysFound =>
      'Nem található elérhető relay — az üzenetek késhetnek';

  @override
  String get jitsiWarningTitle => 'Nincs végponttól végpontig titkosítás';

  @override
  String get jitsiWarningBody =>
      'A Jitsi Meet hívások nincsenek a Pulse által titkosítva. Csak nem érzékeny beszélgetésekhez használd.';

  @override
  String get jitsiConfirm => 'Csatlakozás mindenképp';

  @override
  String get jitsiGroupWarningTitle => 'Nincs végponttól végpontig titkosítás';

  @override
  String get jitsiGroupWarningBody =>
      'Ez a hívás túl sok résztvevővel rendelkezik a beépített titkosított mesh számára.\n\nEgy Jitsi Meet link fog megnyílni a böngészőben. A Jitsi NEM végponttól végpontig titkosított — a szerver láthatja a hívásod.';

  @override
  String get jitsiContinueAnyway => 'Folytatás mindenképp';

  @override
  String get retry => 'Újra';

  @override
  String get setupCreateAnonymousAccount => 'Névtelen fiók létrehozása';

  @override
  String get setupTapToChangeColor => 'Koppints a szín megváltoztatásához';

  @override
  String get setupReqMinLength => 'Legalább 16 karakter';

  @override
  String get setupReqVariety =>
      '4-ből 3: nagy-, kisbetűk, számjegyek, szimbólumok';

  @override
  String get setupReqMatch => 'A jelszavak egyeznek';

  @override
  String get setupYourNickname => 'A beceneved';

  @override
  String get setupRecoveryPassword => 'Helyreállítási jelszó (min. 16)';

  @override
  String get setupConfirmPassword => 'Jelszó megerősítése';

  @override
  String get setupMin16Chars => 'Legalább 16 karakter';

  @override
  String get setupPasswordsDoNotMatch => 'A jelszavak nem egyeznek';

  @override
  String get setupEntropyWeak => 'Gyenge';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Erős';

  @override
  String get setupEntropyWeakNeedsVariety =>
      'Gyenge (3 karaktertípus szükséges)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bit)';
  }

  @override
  String get setupPasswordWarning =>
      'Ez a jelszó az egyetlen módja a fióked helyreállításának. Nincs szerver — nincs jelszó-visszaállítás. Jegyezd meg, vagy írd le.';

  @override
  String get setupCreateAccount => 'Fiók létrehozása';

  @override
  String get setupAlreadyHaveAccount => 'Már van fiókod? ';

  @override
  String get setupRestore => 'Helyreállítás →';

  @override
  String get restoreTitle => 'Fiók helyreállítása';

  @override
  String get restoreInfoBanner =>
      'Add meg a helyreállítási jelszót — a címed (Nostr + Session) automatikusan helyreáll. A névjegyek és üzenetek csak helyileg voltak tárolva.';

  @override
  String get restoreNewNickname => 'Új becenév (később módosítható)';

  @override
  String get restoreButton => 'Fiók helyreállítása';

  @override
  String get lockTitle => 'A Pulse zárolva van';

  @override
  String get lockSubtitle => 'Add meg a jelszavad a folytatáshoz';

  @override
  String get lockPasswordHint => 'Jelszó';

  @override
  String get lockUnlock => 'Feloldás';

  @override
  String get lockPanicHint =>
      'Elfelejtetted a jelszavad? Add meg a pánik kulcsot az összes adat törléséhez.';

  @override
  String get lockTooManyAttempts => 'Túl sok próbálkozás. Minden adat törlése…';

  @override
  String get lockWrongPassword => 'Helytelen jelszó';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Helytelen jelszó — $attempts/$max próbálkozás';
  }

  @override
  String get onboardingSkip => 'Kihagyás';

  @override
  String get onboardingNext => 'Következő';

  @override
  String get onboardingGetStarted => 'Kezdjük';

  @override
  String get onboardingWelcomeTitle => 'Üdvözöl a Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Egy decentralizált, végponttól végpontig titkosított üzenetküldő.\n\nNincsenek központi szerverek. Nincs adatgyűjtés. Nincsenek hátsó ajtók.\nA beszélgetéseid csak a tieid.';

  @override
  String get onboardingTransportTitle => 'Átvitel-független';

  @override
  String get onboardingTransportBody =>
      'Használj Firebase-t, Nostr-t, vagy mindkettőt egyszerre.\n\nAz üzenetek automatikusan átjutnak a hálózatokon. Beépített Tor és I2P támogatás a cenzúra ellenálláshoz.';

  @override
  String get onboardingSignalTitle => 'Signal + posztkvantum';

  @override
  String get onboardingSignalBody =>
      'Minden üzenet a Signal protokollal (Double Ratchet + X3DH) van titkosítva az előre titkosságért.\n\nEzenfelül Kyber-1024-gyel burkolva — egy NIST-szabványú posztkvantum algoritmus — védelmet nyújtva a jövőbeli kvantumszámítógépek ellen.';

  @override
  String get onboardingKeysTitle => 'A kulcsaid a tieid';

  @override
  String get onboardingKeysBody =>
      'Az identitás kulcsaid soha nem hagyják el az eszközöd.\n\nA Signal ujjlenyomatok lehetővé teszik a névjegyek sávon kívüli ellenőrzését. A TOFU (Trust On First Use) automatikusan észleli a kulcsváltozásokat.';

  @override
  String get onboardingThemeTitle => 'Válaszd ki a megjelenésedet';

  @override
  String get onboardingThemeBody =>
      'Válassz témát és kiemelő színt. Ezt bármikor módosíthatod a Beállításokban.';

  @override
  String get contactsNewChat => 'Új csevegés';

  @override
  String get contactsAddContact => 'Névjegy hozzáadása';

  @override
  String get contactsSearchHint => 'Keresés...';

  @override
  String get contactsNewGroup => 'Új csoport';

  @override
  String get contactsNoContactsYet => 'Még nincsenek névjegyek';

  @override
  String get contactsAddHint => 'Koppints a + gombra egy cím hozzáadásához';

  @override
  String get contactsNoMatch => 'Nincs egyező névjegy';

  @override
  String get contactsRemoveTitle => 'Névjegy eltávolítása';

  @override
  String contactsRemoveMessage(String name) {
    return 'Eltávolítod $name-t?';
  }

  @override
  String get contactsRemove => 'Eltávolítás';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count névjegy$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Link megnyitása';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Megnyitod ezt az URL-t a böngészőben?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Megnyitás';

  @override
  String get bubbleSecurityWarning => 'Biztonsági figyelmeztetés';

  @override
  String bubbleExecutableWarning(String name) {
    return 'A \"$name\" egy futtatható fájltípus. A mentése és futtatása károsíthatja az eszközöd. Mégis mented?';
  }

  @override
  String get bubbleSaveAnyway => 'Mentés mindenképp';

  @override
  String bubbleSavedTo(String path) {
    return 'Mentve: $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Mentés sikertelen: $error';
  }

  @override
  String get bubbleNotEncrypted => 'NEM TITKOSÍTOTT';

  @override
  String get bubbleCorruptedImage => '[Sérült kép]';

  @override
  String get bubbleReplyPhoto => 'Fotó';

  @override
  String get bubbleReplyVoice => 'Hangüzenet';

  @override
  String get bubbleReplyVideo => 'Videóüzenet';

  @override
  String bubbleReadBy(String names) {
    return 'Olvasta: $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Olvasta: $count';
  }

  @override
  String get chatTileTapToStart => 'Koppints a csevegés indításához';

  @override
  String get chatTileMessageSent => 'Üzenet elküldve';

  @override
  String get chatTileEncryptedMessage => 'Titkosított üzenet';

  @override
  String chatTileYouPrefix(String text) {
    return 'Te: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Hangüzenet';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Hangüzenet ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Titkosított üzenet';

  @override
  String get groupNewGroup => 'Új csoport';

  @override
  String get groupGroupName => 'Csoport neve';

  @override
  String get groupSelectMembers => 'Tagok kiválasztása (min. 2)';

  @override
  String get groupNoContactsYet =>
      'Még nincsenek névjegyek. Először adj hozzá névjegyeket.';

  @override
  String get groupCreate => 'Létrehozás';

  @override
  String get groupLabel => 'Csoport';

  @override
  String get profileVerifyIdentity => 'Identitás ellenőrzése';

  @override
  String profileVerifyInstructions(String name) {
    return 'Hasonlítsd össze ezeket az ujjlenyomatokat $name-vel hanghíváson vagy személyesen. Ha mindkét érték megegyezik mindkét eszközön, koppints az „Ellenőrzöttnek jelölés“ gombra.';
  }

  @override
  String get profileTheirKey => 'Az ő kulcsa';

  @override
  String get profileYourKey => 'A te kulcsod';

  @override
  String get profileRemoveVerification => 'Ellenőrzés eltávolítása';

  @override
  String get profileMarkAsVerified => 'Ellenőrzöttnek jelölés';

  @override
  String get profileAddressCopied => 'Cím másolva';

  @override
  String get profileNoContactsToAdd =>
      'Nincs hozzáadható névjegy — mindenki már tag';

  @override
  String get profileAddMembers => 'Tagok hozzáadása';

  @override
  String profileAddCount(int count) {
    return 'Hozzáadás ($count)';
  }

  @override
  String get profileRenameGroup => 'Csoport átnevezése';

  @override
  String get profileRename => 'Átnevezés';

  @override
  String get profileRemoveMember => 'Tag eltávolítása?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Eltávolítod $name-t ebből a csoportból?';
  }

  @override
  String get profileKick => 'Kizárás';

  @override
  String get profileSignalFingerprints => 'Signal ujjlenyomatok';

  @override
  String get profileVerified => 'ELLENŐRZÖTT';

  @override
  String get profileVerify => 'Ellenőrzés';

  @override
  String get profileEdit => 'Szerkesztés';

  @override
  String get profileNoSession =>
      'Még nincs munkamenet létrehozva — először küldj egy üzenetet.';

  @override
  String get profileFingerprintCopied => 'Ujjlenyomat másolva';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count tag$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Biztonsági szám ellenőrzése';

  @override
  String get profileShowContactQr => 'Névjegy QR megjelenítése';

  @override
  String profileContactAddress(String name) {
    return '$name címe';
  }

  @override
  String get profileExportChatHistory => 'Csevegési előzmények exportálása';

  @override
  String profileSavedTo(String path) {
    return 'Mentve: $path';
  }

  @override
  String get profileExportFailed => 'Az exportálás sikertelen';

  @override
  String get profileClearChatHistory => 'Csevegési előzmények törlése';

  @override
  String get profileDeleteGroup => 'Csoport törlése';

  @override
  String get profileDeleteContact => 'Névjegy törlése';

  @override
  String get profileLeaveGroup => 'Csoport elhagyása';

  @override
  String get profileLeaveGroupBody =>
      'El leszel távolítva a csoportból, és az törlődik a névjegyeid közül.';

  @override
  String get groupInviteTitle => 'Csoportmeghívó';

  @override
  String groupInviteBody(String from, String group) {
    return '$from meghívott a(z) \"$group\" csoportba';
  }

  @override
  String get groupInviteAccept => 'Elfogadás';

  @override
  String get groupInviteDecline => 'Elutasítás';

  @override
  String get groupMemberLimitTitle => 'Túl sok résztvevő';

  @override
  String groupMemberLimitBody(int count) {
    return 'Ez a csoport $count résztvevős lesz. A titkosított mesh hívások legfeljebb 6 főt támogatnak. Nagyobb csoportok Jitsire váltanak (nem E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Hozzáadás mindenképp';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name elutasította a meghívót a(z) \"$group\" csoportba';
  }

  @override
  String get transferTitle => 'Átvitel másik eszközre';

  @override
  String get transferInfoBox =>
      'Mozgasd át a Signal identitásodat és Nostr kulcsaidat egy új eszközre.\nA csevegés munkamenetek NEM kerülnek átvitelre — az előre titkosság megmarad.';

  @override
  String get transferSendFromThis => 'Küldés erről az eszközről';

  @override
  String get transferSendSubtitle =>
      'Ezen az eszközön vannak a kulcsok. Oszd meg a kódot az új eszközzel.';

  @override
  String get transferReceiveOnThis => 'Fogadás ezen az eszközön';

  @override
  String get transferReceiveSubtitle =>
      'Ez az új eszköz. Add meg a kódot a régi eszközről.';

  @override
  String get transferChooseMethod => 'Átviteli módszer kiválasztása';

  @override
  String get transferLan => 'LAN (azonos hálózat)';

  @override
  String get transferLanSubtitle =>
      'Gyors és közvetlen. Mindkét eszköznek ugyanazon a Wi-Fi-n kell lennie.';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'Bármilyen hálózaton működik egy meglévő Nostr relay-en keresztül.';

  @override
  String get transferRelayUrl => 'Relay URL';

  @override
  String get transferEnterCode => 'Átviteli kód megadása';

  @override
  String get transferPasteCode => 'Illeszd be a LAN:... vagy NOS:... kódot ide';

  @override
  String get transferConnect => 'Csatlakozás';

  @override
  String get transferGenerating => 'Átviteli kód generálása…';

  @override
  String get transferShareCode => 'Oszd meg ezt a kódot a fogadóval:';

  @override
  String get transferCopyCode => 'Kód másolása';

  @override
  String get transferCodeCopied => 'Kód a vágólapra másolva';

  @override
  String get transferWaitingReceiver => 'Várakozás a fogadó csatlakozására…';

  @override
  String get transferConnectingSender => 'Csatlakozás a küldőhöz…';

  @override
  String get transferVerifyBoth =>
      'Hasonlítsd össze ezt a kódot mindkét eszközön.\nHa megegyeznek, az átvitel biztonságos.';

  @override
  String get transferComplete => 'Átvitel befejezve';

  @override
  String get transferKeysImported => 'Kulcsok importálva';

  @override
  String get transferCompleteSenderBody =>
      'A kulcsaid aktívak maradnak ezen az eszközön.\nA fogadó most használhatja az identitásodat.';

  @override
  String get transferCompleteReceiverBody =>
      'A kulcsok sikeresen importálva.\nIndítsd újra az alkalmazást az új identitás alkalmazásához.';

  @override
  String get transferRestartApp => 'Alkalmazás újraindítása';

  @override
  String get transferFailed => 'Az átvitel sikertelen';

  @override
  String get transferTryAgain => 'Próbáld újra';

  @override
  String get transferEnterRelayFirst => 'Először adj meg egy relay URL-t';

  @override
  String get transferPasteCodeFromSender =>
      'Illeszd be a küldő átviteli kódját';

  @override
  String get menuReply => 'Válasz';

  @override
  String get menuForward => 'Továbbítás';

  @override
  String get menuReact => 'Reagálás';

  @override
  String get menuCopy => 'Másolás';

  @override
  String get menuEdit => 'Szerkesztés';

  @override
  String get menuRetry => 'Újrapróbálás';

  @override
  String get menuCancelScheduled => 'Ütemezés törlése';

  @override
  String get menuDelete => 'Törlés';

  @override
  String get menuForwardTo => 'Továbbítás…';

  @override
  String menuForwardedTo(String name) {
    return 'Továbbítva: $name';
  }

  @override
  String get menuScheduledMessages => 'Ütemezett üzenetek';

  @override
  String get menuNoScheduledMessages => 'Nincsenek ütemezett üzenetek';

  @override
  String menuSendsOn(String date) {
    return 'Küldés dátuma: $date';
  }

  @override
  String get menuDisappearingMessages => 'Eltűnő üzenetek';

  @override
  String get menuDisappearingSubtitle =>
      'Az üzenetek automatikusan törlődnek a kiválasztott idő után.';

  @override
  String get menuTtlOff => 'Ki';

  @override
  String get menuTtl1h => '1 óra';

  @override
  String get menuTtl24h => '24 óra';

  @override
  String get menuTtl7d => '7 nap';

  @override
  String get menuAttachPhoto => 'Fotó';

  @override
  String get menuAttachFile => 'Fájl';

  @override
  String get menuAttachVideo => 'Videó';

  @override
  String get mediaTitle => 'Média';

  @override
  String get mediaFileLabel => 'FÁJL';

  @override
  String mediaPhotosTab(int count) {
    return 'Fotók ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Fájlok ($count)';
  }

  @override
  String get mediaNoPhotos => 'Még nincsenek fotók';

  @override
  String get mediaNoFiles => 'Még nincsenek fájlok';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Mentve: Letöltések/$name';
  }

  @override
  String get mediaFailedToSave => 'A fájl mentése sikertelen';

  @override
  String get statusNewStatus => 'Új státusz';

  @override
  String get statusPublish => 'Közzététel';

  @override
  String get statusExpiresIn24h => 'A státusz 24 óra múlva lejár';

  @override
  String get statusWhatsOnYourMind => 'Mi jár a fejedben?';

  @override
  String get statusPhotoAttached => 'Fotó csatolva';

  @override
  String get statusAttachPhoto => 'Fotó csatolása (opcionális)';

  @override
  String get statusEnterText => 'Kérjük, adj meg szöveget a státuszodhoz.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'A fotó kiválasztása sikertelen: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'A közzététel sikertelen: $error';
  }

  @override
  String get panicSetPanicKey => 'Pánik kulcs beállítása';

  @override
  String get panicEmergencySelfDestruct => 'Vészhelyzeti önmegsemmisítés';

  @override
  String get panicIrreversible => 'Ez a művelet visszafordíthatatlan';

  @override
  String get panicWarningBody =>
      'Ennek a kulcsnak a megadása a zárolási képernyőn azonnal törli az ÖSSZES adatot — üzeneteket, névjegyeket, kulcsokat, identitást. Használj a szokásos jelszavadtól eltérő kulcsot.';

  @override
  String get panicKeyHint => 'Pánik kulcs';

  @override
  String get panicConfirmHint => 'Pánik kulcs megerősítése';

  @override
  String get panicMinChars =>
      'A pánik kulcsnak legalább 8 karakter hosszúnak kell lennie';

  @override
  String get panicKeysDoNotMatch => 'A kulcsok nem egyeznek';

  @override
  String get panicSetFailed =>
      'A pánik kulcs mentése sikertelen — kérjük, próbáld újra';

  @override
  String get passwordSetAppPassword => 'Alkalmazás jelszó beállítása';

  @override
  String get passwordProtectsMessages =>
      'Védi az üzeneteidet nyugalmi állapotban';

  @override
  String get passwordInfoBanner =>
      'A Pulse minden megnyitásakor szükséges. Elfelejtése esetén az adataid nem állíthatók helyre.';

  @override
  String get passwordHint => 'Jelszó';

  @override
  String get passwordConfirmHint => 'Jelszó megerősítése';

  @override
  String get passwordSetButton => 'Jelszó beállítása';

  @override
  String get passwordSkipForNow => 'Kihagyás egyelőre';

  @override
  String get passwordMinChars =>
      'A jelszónak legalább 6 karakter hosszúnak kell lennie';

  @override
  String get passwordsDoNotMatch => 'A jelszavak nem egyeznek';

  @override
  String get profileCardSaved => 'Profil mentve!';

  @override
  String get profileCardE2eeIdentity => 'E2EE identitás';

  @override
  String get profileCardDisplayName => 'Megjelenítési név';

  @override
  String get profileCardDisplayNameHint => 'pl. Kovács János';

  @override
  String get profileCardAbout => 'Rólam';

  @override
  String get profileCardSaveProfile => 'Profil mentése';

  @override
  String get profileCardYourName => 'A neved';

  @override
  String get profileCardAddressCopied => 'Cím másolva!';

  @override
  String get profileCardInboxAddress => 'A postafiók címed';

  @override
  String get profileCardInboxAddresses => 'A postafiók címeid';

  @override
  String get profileCardShareAllAddresses =>
      'Összes cím megosztása (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Oszd meg a névjegyeiddel, hogy üzenetet küldhessenek neked.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Mind a(z) $count cím egyetlen linkként másolva!';
  }

  @override
  String get settingsMyProfile => 'Profilom';

  @override
  String get settingsYourInboxAddress => 'A postafiók címed';

  @override
  String get settingsMyQrCode => 'QR kódom';

  @override
  String get settingsMyQrSubtitle => 'Oszd meg a címedet beolvasható QR-ként';

  @override
  String get settingsShareMyAddress => 'Címem megosztása';

  @override
  String get settingsNoAddressYet =>
      'Még nincs cím — először mentsd el a beállításokat';

  @override
  String get settingsInviteLink => 'Meghívó link';

  @override
  String get settingsRawAddress => 'Nyers cím';

  @override
  String get settingsCopyLink => 'Link másolása';

  @override
  String get settingsCopyAddress => 'Cím másolása';

  @override
  String get settingsInviteLinkCopied => 'Meghívó link másolva';

  @override
  String get settingsAppearance => 'Megjelenés';

  @override
  String get settingsThemeEngine => 'Téma motor';

  @override
  String get settingsThemeEngineSubtitle =>
      'Színek és betűtípusok testreszabása';

  @override
  String get settingsSignalProtocol => 'Signal protokoll';

  @override
  String get settingsSignalProtocolSubtitle =>
      'Az E2EE kulcsok biztonságosan vannak tárolva';

  @override
  String get settingsActive => 'AKTÍV';

  @override
  String get settingsIdentityBackup => 'Identitás biztonsági mentés';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Signal identitás exportálása vagy importálása';

  @override
  String get settingsIdentityBackupBody =>
      'Exportáld a Signal identitás kulcsaidat egy biztonsági kódba, vagy állítsd helyre egy meglévőből.';

  @override
  String get settingsTransferDevice => 'Átvitel másik eszközre';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Identitás átvitele LAN-on vagy Nostr relay-en keresztül';

  @override
  String get settingsExportIdentity => 'Identitás exportálása';

  @override
  String get settingsExportIdentityBody =>
      'Másold ki ezt a biztonsági kódot és tárold biztonságosan:';

  @override
  String get settingsSaveFile => 'Fájl mentése';

  @override
  String get settingsImportIdentity => 'Identitás importálása';

  @override
  String get settingsImportIdentityBody =>
      'Illeszd be a biztonsági kódot alább. Ez felülírja a jelenlegi identitásodat.';

  @override
  String get settingsPasteBackupCode => 'Illeszd be a biztonsági kódot ide…';

  @override
  String get settingsIdentityImported =>
      'Identitás + névjegyek importálva! Indítsd újra az alkalmazást az alkalmazáshoz.';

  @override
  String get settingsSecurity => 'Biztonság';

  @override
  String get settingsAppPassword => 'Alkalmazás jelszó';

  @override
  String get settingsPasswordEnabled =>
      'Engedélyezve — minden indításkor szükséges';

  @override
  String get settingsPasswordDisabled =>
      'Letiltva — az alkalmazás jelszó nélkül nyílik meg';

  @override
  String get settingsChangePassword => 'Jelszó módosítása';

  @override
  String get settingsChangePasswordSubtitle =>
      'Alkalmazás zárolási jelszó frissítése';

  @override
  String get settingsSetPanicKey => 'Pánik kulcs beállítása';

  @override
  String get settingsChangePanicKey => 'Pánik kulcs módosítása';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Vészhelyzeti törlő kulcs frissítése';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Egy kulcs, ami azonnal törli az összes adatot';

  @override
  String get settingsRemovePanicKey => 'Pánik kulcs eltávolítása';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Vészhelyzeti önmegsemmisítés letiltása';

  @override
  String get settingsRemovePanicKeyBody =>
      'A vészhelyzeti önmegsemmisítés le lesz tiltva. Bármikor újra engedélyezheted.';

  @override
  String get settingsDisableAppPassword => 'Alkalmazás jelszó letiltása';

  @override
  String get settingsEnterCurrentPassword =>
      'Add meg a jelenlegi jelszavad a megerősítéshez';

  @override
  String get settingsCurrentPassword => 'Jelenlegi jelszó';

  @override
  String get settingsIncorrectPassword => 'Helytelen jelszó';

  @override
  String get settingsPasswordUpdated => 'Jelszó frissítve';

  @override
  String get settingsChangePasswordProceed =>
      'Add meg a jelenlegi jelszavad a folytatáshoz';

  @override
  String get settingsData => 'Adatok';

  @override
  String get settingsBackupMessages => 'Üzenetek biztonsági mentése';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Titkosított üzenetelőzmények exportálása fájlba';

  @override
  String get settingsRestoreMessages => 'Üzenetek visszaállítása';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Üzenetek importálása biztonsági mentés fájlból';

  @override
  String get settingsExportKeys => 'Kulcsok exportálása';

  @override
  String get settingsExportKeysSubtitle =>
      'Identitás kulcsok mentése titkosított fájlba';

  @override
  String get settingsImportKeys => 'Kulcsok importálása';

  @override
  String get settingsImportKeysSubtitle =>
      'Identitás kulcsok visszaállítása exportált fájlból';

  @override
  String get settingsBackupPassword => 'Biztonsági mentés jelszava';

  @override
  String get settingsPasswordCannotBeEmpty => 'A jelszó nem lehet üres';

  @override
  String get settingsPasswordMin4Chars =>
      'A jelszónak legalább 4 karakter hosszúnak kell lennie';

  @override
  String get settingsCallsTurn => 'Hívások és TURN';

  @override
  String get settingsLocalNetwork => 'Helyi hálózat';

  @override
  String get settingsCensorshipResistance => 'Cenzúra ellenállás';

  @override
  String get settingsNetwork => 'Hálózat';

  @override
  String get settingsProxyTunnels => 'Proxy és alagutak';

  @override
  String get settingsTurnServers => 'TURN szerverek';

  @override
  String get settingsProviderTitle => 'Szolgáltató';

  @override
  String get settingsLanFallback => 'LAN tartalék';

  @override
  String get settingsLanFallbackSubtitle =>
      'Jelenlét közvetítése és üzenetek kézbesítése a helyi hálózaton, ha az internet nem elérhető. Tiltsd le nem megbízható hálózatokon (nyilvános Wi-Fi).';

  @override
  String get settingsBgDelivery => 'Háttérbeli kézbesítés';

  @override
  String get settingsBgDeliverySubtitle =>
      'Folytasd az üzenetek fogadását, amikor az alkalmazás minimalizálva van. Állandó értesítést jelenít meg.';

  @override
  String get settingsYourInboxProvider => 'A postafiók szolgáltatód';

  @override
  String get settingsConnectionDetails => 'Kapcsolat részletei';

  @override
  String get settingsSaveAndConnect => 'Mentés és csatlakozás';

  @override
  String get settingsSecondaryInboxes => 'Másodlagos postafiók';

  @override
  String get settingsAddSecondaryInbox => 'Másodlagos postafiók hozzáadása';

  @override
  String get settingsAdvanced => 'Speciális';

  @override
  String get settingsDiscover => 'Felfedezés';

  @override
  String get settingsAbout => 'Névjegy';

  @override
  String get settingsPrivacyPolicy => 'Adatvédelmi irányelvek';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Hogyan védi a Pulse az adataidat';

  @override
  String get settingsCrashReporting => 'Összeomlás jelentés';

  @override
  String get settingsCrashReportingSubtitle =>
      'Névtelen összeomlás jelentések küldése a Pulse fejlesztéséhez. Soha nem kerül küldésre üzenettartalom vagy névjegy.';

  @override
  String get settingsCrashReportingEnabled =>
      'Összeomlás jelentés engedélyezve — indítsd újra az alkalmazást az alkalmazáshoz';

  @override
  String get settingsCrashReportingDisabled =>
      'Összeomlás jelentés letiltva — indítsd újra az alkalmazást az alkalmazáshoz';

  @override
  String get settingsSensitiveOperation => 'Érzékeny művelet';

  @override
  String get settingsSensitiveOperationBody =>
      'Ezek a kulcsok az identitásod. Bárki, aki rendelkezik ezzel a fájllal, megszemélyesíthet téged. Tárold biztonságosan, és töröld az átvitel után.';

  @override
  String get settingsIUnderstandContinue => 'Megértettem, folytatás';

  @override
  String get settingsReplaceIdentity => 'Identitás cseréje?';

  @override
  String get settingsReplaceIdentityBody =>
      'Ez felülírja a jelenlegi identitás kulcsaidat. A meglévő Signal munkamenetek érvénytelenítve lesznek, és a névjegyeknek újra kell létrehozniuk a titkosítást. Az alkalmazást újra kell indítani.';

  @override
  String get settingsReplaceKeys => 'Kulcsok cseréje';

  @override
  String get settingsKeysImported => 'Kulcsok importálva';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count kulcs sikeresen importálva. Kérjük, indítsd újra az alkalmazást az új identitás inicializálásához.';
  }

  @override
  String get settingsRestartNow => 'Újraindítás most';

  @override
  String get settingsLater => 'Később';

  @override
  String get profileGroupLabel => 'Csoport';

  @override
  String get profileAddButton => 'Hozzáadás';

  @override
  String get profileKickButton => 'Kizárás';

  @override
  String get dataSectionTitle => 'Adatok';

  @override
  String get dataBackupMessages => 'Üzenetek biztonsági mentése';

  @override
  String get dataBackupPasswordSubtitle =>
      'Válassz egy jelszót az üzenetek biztonsági mentésének titkosításához.';

  @override
  String get dataBackupConfirmLabel => 'Biztonsági mentés létrehozása';

  @override
  String get dataCreatingBackup => 'Biztonsági mentés létrehozása';

  @override
  String get dataBackupPreparing => 'Előkészítés...';

  @override
  String dataBackupExporting(int done, int total) {
    return '$done/$total üzenet exportálása...';
  }

  @override
  String get dataBackupSavingFile => 'Fájl mentése...';

  @override
  String get dataSaveMessageBackupDialog => 'Üzenet biztonsági mentés mentése';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Biztonsági mentés elmentve ($count üzenet)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'A biztonsági mentés sikertelen — nem lett adat exportálva';

  @override
  String dataBackupFailedError(String error) {
    return 'A biztonsági mentés sikertelen: $error';
  }

  @override
  String get dataSelectMessageBackupDialog =>
      'Üzenet biztonsági mentés kiválasztása';

  @override
  String get dataInvalidBackupFile =>
      'Érvénytelen biztonsági mentés fájl (túl kicsi)';

  @override
  String get dataNotValidBackupFile =>
      'Nem érvényes Pulse biztonsági mentés fájl';

  @override
  String get dataRestoreMessages => 'Üzenetek visszaállítása';

  @override
  String get dataRestorePasswordSubtitle =>
      'Add meg a biztonsági mentés létrehozásához használt jelszót.';

  @override
  String get dataRestoreConfirmLabel => 'Visszaállítás';

  @override
  String get dataRestoringMessages => 'Üzenetek visszaállítása';

  @override
  String get dataRestoreDecrypting => 'Visszafejtés...';

  @override
  String dataRestoreImporting(int done, int total) {
    return '$done/$total üzenet importálása...';
  }

  @override
  String get dataRestoreFailed =>
      'A visszaállítás sikertelen — helytelen jelszó vagy sérült fájl';

  @override
  String dataRestoreSuccess(int count) {
    return '$count új üzenet visszaállítva';
  }

  @override
  String get dataRestoreNothingNew =>
      'Nincs új importálható üzenet (mind létezik már)';

  @override
  String dataRestoreFailedError(String error) {
    return 'A visszaállítás sikertelen: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Kulcs export kiválasztása';

  @override
  String get dataNotValidKeyFile => 'Nem érvényes Pulse kulcs export fájl';

  @override
  String get dataExportKeys => 'Kulcsok exportálása';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Válassz egy jelszót a kulcs export titkosításához.';

  @override
  String get dataExportKeysConfirmLabel => 'Exportálás';

  @override
  String get dataExportingKeys => 'Kulcsok exportálása';

  @override
  String get dataExportingKeysStatus => 'Identitás kulcsok titkosítása...';

  @override
  String get dataSaveKeyExportDialog => 'Kulcs export mentése';

  @override
  String dataKeysExportedTo(String path) {
    return 'Kulcsok exportálva ide:\n$path';
  }

  @override
  String get dataExportFailed =>
      'Az exportálás sikertelen — nem található kulcs';

  @override
  String dataExportFailedError(String error) {
    return 'Az exportálás sikertelen: $error';
  }

  @override
  String get dataImportKeys => 'Kulcsok importálása';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Add meg a kulcs export titkosításához használt jelszót.';

  @override
  String get dataImportKeysConfirmLabel => 'Importálás';

  @override
  String get dataImportingKeys => 'Kulcsok importálása';

  @override
  String get dataImportingKeysStatus => 'Identitás kulcsok visszafejtése...';

  @override
  String get dataImportFailed =>
      'Az importálás sikertelen — helytelen jelszó vagy sérült fájl';

  @override
  String dataImportFailedError(String error) {
    return 'Az importálás sikertelen: $error';
  }

  @override
  String get securitySectionTitle => 'Biztonság';

  @override
  String get securityIncorrectPassword => 'Helytelen jelszó';

  @override
  String get securityPasswordUpdated => 'Jelszó frissítve';

  @override
  String get appearanceSectionTitle => 'Megjelenés';

  @override
  String appearanceExportFailed(String error) {
    return 'Az exportálás sikertelen: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Mentve: $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Mentés sikertelen: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Az importálás sikertelen: $error';
  }

  @override
  String get aboutSectionTitle => 'Névjegy';

  @override
  String get providerPublicKey => 'Nyilvános kulcs';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Automatikusan konfigurálva a helyreállítási jelszóból. Relay automatikusan felfedezve.';

  @override
  String get providerKeyStoredLocally =>
      'A kulcsod biztonságos helyi tárolóban van — soha nem kerül elküldésre semmilyen szerverre.';

  @override
  String get providerSessionInfo =>
      'Session Network — hagymás útválasztású E2EE. A Session ID-je automatikusan generálódik és biztonságosan tárolódik. A csomópontok automatikusan felfedezhetők a beépített kezdő csomópontokból.';

  @override
  String get providerAdvanced => 'Speciális';

  @override
  String get providerSaveAndConnect => 'Mentés és csatlakozás';

  @override
  String get providerAddSecondaryInbox => 'Másodlagos postafiók hozzáadása';

  @override
  String get providerSecondaryInboxes => 'Másodlagos postafiók';

  @override
  String get providerYourInboxProvider => 'A postafiók szolgáltatód';

  @override
  String get providerConnectionDetails => 'Kapcsolat részletei';

  @override
  String get addContactTitle => 'Névjegy hozzáadása';

  @override
  String get addContactInviteLinkLabel => 'Meghívó link vagy cím';

  @override
  String get addContactTapToPaste => 'Koppints a meghívó link beillesztéséhez';

  @override
  String get addContactPasteTooltip => 'Beillesztés a vágólapról';

  @override
  String get addContactAddressDetected => 'Névjegy cím észlelve';

  @override
  String addContactRoutesDetected(int count) {
    return '$count útvonal észlelve — a SmartRouter a leggyorsabbat választja';
  }

  @override
  String get addContactFetchingProfile => 'Profil betöltése…';

  @override
  String addContactProfileFound(String name) {
    return 'Találat: $name';
  }

  @override
  String get addContactNoProfileFound => 'Nem található profil';

  @override
  String get addContactDisplayNameLabel => 'Megjelenítési név';

  @override
  String get addContactDisplayNameHint => 'Hogyan szeretnéd hívni?';

  @override
  String get addContactAddManually => 'Cím manuális hozzáadása';

  @override
  String get addContactButton => 'Névjegy hozzáadása';

  @override
  String get networkDiagnosticsTitle => 'Hálózati diagnosztika';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr Relay-k';

  @override
  String get networkDiagnosticsDirect => 'Közvetlen';

  @override
  String get networkDiagnosticsTorOnly => 'Csak Tor';

  @override
  String get networkDiagnosticsBest => 'Legjobb';

  @override
  String get networkDiagnosticsNone => 'nincs';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Állapot';

  @override
  String get networkDiagnosticsConnected => 'Csatlakozva';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Csatlakozás $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Ki';

  @override
  String get networkDiagnosticsTransport => 'Átvitel';

  @override
  String get networkDiagnosticsInfrastructure => 'Infrastruktúra';

  @override
  String get networkDiagnosticsSessionNodes => 'Session csomópontok';

  @override
  String get networkDiagnosticsTurnServers => 'TURN szerverek';

  @override
  String get networkDiagnosticsLastProbe => 'Utolsó vizsgálat';

  @override
  String get networkDiagnosticsRunning => 'Fut...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Diagnosztika futtatása';

  @override
  String get networkDiagnosticsForceReprobe =>
      'Teljes újravizsgálat kényszerítése';

  @override
  String get networkDiagnosticsJustNow => 'éppen most';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes perce';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours órája';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days napja';
  }

  @override
  String get homeNoEch => 'Nincs ECH';

  @override
  String get homeNoEchTooltip =>
      'uTLS proxy nem elérhető — ECH letiltva.\nA TLS ujjlenyomat látható a DPI számára.';

  @override
  String get settingsTitle => 'Beállítások';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Mentve és csatlakozva: $provider';
  }

  @override
  String get settingsTorFailedToStart => 'A beépített Tor indítása sikertelen';

  @override
  String get settingsPsiphonFailedToStart => 'A Psiphon indítása sikertelen';

  @override
  String get verifyTitle => 'Biztonsági szám ellenőrzése';

  @override
  String get verifyIdentityVerified => 'Identitás ellenőrizve';

  @override
  String get verifyNotYetVerified => 'Még nem ellenőrzött';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Ellenőrizted $name biztonsági számát.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Hasonlítsd össze ezeket a számokat $name-vel személyesen vagy megbízható csatornán.';
  }

  @override
  String get verifyExplanation =>
      'Minden beszélgetésnek egyedi biztonsági száma van. Ha mindketten ugyanazokat a számokat látjátok az eszközeiteken, a kapcsolat végponttól végpontig ellenőrzött.';

  @override
  String verifyContactKey(String name) {
    return '$name kulcsa';
  }

  @override
  String get verifyYourKey => 'A te kulcsod';

  @override
  String get verifyRemoveVerification => 'Ellenőrzés eltávolítása';

  @override
  String get verifyMarkAsVerified => 'Ellenőrzöttnek jelölés';

  @override
  String verifyAfterReinstall(String name) {
    return 'Ha $name újratelepíti az alkalmazást, a biztonsági szám megváltozik, és az ellenőrzés automatikusan eltávolításra kerül.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Csak azután jelöld ellenőrzöttnek, miután összehasonlítottad a számokat $name-vel hanghíváson vagy személyesen.';
  }

  @override
  String get verifyNoSession =>
      'Még nincs titkosítási munkamenet létrehozva. Először küldj egy üzenetet a biztonsági számok generálásához.';

  @override
  String get verifyNoKeyAvailable => 'Nincs elérhető kulcs';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label ujjlenyomat másolva';
  }

  @override
  String get providerDatabaseUrlLabel => 'Adatbázis URL';

  @override
  String get providerOptionalHint => 'Opcionális';

  @override
  String get providerWebApiKeyLabel => 'Web API kulcs';

  @override
  String get providerOptionalForPublicDb => 'Opcionális nyilvános adatbázishoz';

  @override
  String get providerRelayUrlLabel => 'Relay URL';

  @override
  String get providerPrivateKeyLabel => 'Privát kulcs';

  @override
  String get providerPrivateKeyNsecLabel => 'Privát kulcs (nsec)';

  @override
  String get providerStorageNodeLabel => 'Tárolási csomópont URL (opcionális)';

  @override
  String get providerStorageNodeHint =>
      'Hagyd üresen a beépített seed csomópontokhoz';

  @override
  String get transferInvalidCodeFormat =>
      'Ismeretlen kódformátum — LAN: vagy NOS: előtaggal kell kezdődnie';

  @override
  String get profileCardFingerprintCopied => 'Ujjlenyomat másolva';

  @override
  String get profileCardAboutHint => 'Adatvédelem az első 🔒';

  @override
  String get profileCardSaveButton => 'Profil mentése';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Titkosított üzenetek, névjegyek és avatarok exportálása fájlba';

  @override
  String get callVideo => 'Videó';

  @override
  String get callAudio => 'Hang';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Kézbesítve: $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Kézbesítve: $count';
  }

  @override
  String get groupStatusDialogTitle => 'Üzenet információ';

  @override
  String get groupStatusRead => 'Olvasva';

  @override
  String get groupStatusDelivered => 'Kézbesítve';

  @override
  String get groupStatusPending => 'Függőben';

  @override
  String get groupStatusNoData => 'Még nincs kézbesítési információ';

  @override
  String get profileTransferAdmin => 'Adminná tétel';

  @override
  String profileTransferAdminConfirm(String name) {
    return '$name legyen az új admin?';
  }

  @override
  String get profileTransferAdminBody =>
      'Elveszíted az admin jogosultságaidat. Ez nem vonható vissza.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name mostantól az admin';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Adatvédelmi irányelvek';

  @override
  String get privacyOverviewHeading => 'Áttekintés';

  @override
  String get privacyOverviewBody =>
      'A Pulse egy szerver nélküli, végponttól végpontig titkosított üzenetküldő. Az adatvédelmed nem csupán egy funkció — ez az architektúra. Nincsenek Pulse szerverek. Semmilyen fiók nincs sehol tárolva. Semmilyen adatot nem gyűjtenek, továbbítanak vagy tárolnak a fejlesztők.';

  @override
  String get privacyDataCollectionHeading => 'Adatgyűjtés';

  @override
  String get privacyDataCollectionBody =>
      'A Pulse semmilyen személyes adatot nem gyűjt. Konkrétan:\n\n- Nem szükséges e-mail, telefonszám vagy valódi név\n- Nincs analitika, követés vagy telemetria\n- Nincsenek hirdetési azonosítók\n- Nincs hozzáférés a névjegylistához\n- Nincsenek felhő biztonsági mentések (az üzenetek csak az eszközödön léteznek)\n- Semmilyen metaadat nem kerül elküldésre Pulse szerverre (nincsenek ilyenek)';

  @override
  String get privacyEncryptionHeading => 'Titkosítás';

  @override
  String get privacyEncryptionBody =>
      'Minden üzenet a Signal protokollal (Double Ratchet X3DH kulcsmegállapodással) van titkosítva. A titkosítási kulcsok kizárólag az eszközödön kerülnek generálásra és tárolásra. Senki — beleértve a fejlesztőket — nem tudja olvasni az üzeneteidet.';

  @override
  String get privacyNetworkHeading => 'Hálózati architektúra';

  @override
  String get privacyNetworkBody =>
      'A Pulse föderált átviteli adaptereket használ (Nostr relay-k, Session/Oxen szolgáltatási csomópontok, Firebase Realtime Database, LAN). Ezek az átvitelek csak titkosított rejtjelszöveget szállítanak. A relay üzemeltetők láthatják az IP-címedet és a forgalom mennyiségét, de nem tudják visszafejteni az üzenetek tartalmát.\n\nHa a Tor engedélyezve van, az IP-címed a relay üzemeltetők elől is rejtve marad.';

  @override
  String get privacyStunHeading => 'STUN/TURN szerverek';

  @override
  String get privacyStunBody =>
      'A hang- és videohívások WebRTC-t használnak DTLS-SRTP titkosítással. A STUN szerverek (a nyilvános IP-d felfedezéséhez peer-to-peer kapcsolatokhoz) és a TURN szerverek (média továbbítására, ha a közvetlen kapcsolat sikertelen) láthatják az IP-címedet és a hívás időtartamát, de nem tudják visszafejteni a hívás tartalmát.\n\nA Beállításokban konfigurálhatsz saját TURN szervert a maximális adatvédelem érdekében.';

  @override
  String get privacyCrashHeading => 'Összeomlás jelentés';

  @override
  String get privacyCrashBody =>
      'Ha a Sentry összeomlás jelentés engedélyezve van (a fordítási SENTRY_DSN-en keresztül), névtelen összeomlás jelentések küldhetők. Ezek nem tartalmaznak üzenettartalmat, névjegy információt vagy személyazonosításra alkalmas adatot. Az összeomlás jelentés letiltható fordítási időben a DSN elhagyásával.';

  @override
  String get privacyPasswordHeading => 'Jelszó és kulcsok';

  @override
  String get privacyPasswordBody =>
      'A helyreállítási jelszavad kriptográfiai kulcsok levezetésére szolgál az Argon2id-n (memória-intenzív KDF) keresztül. A jelszó sehova nem kerül továbbításra. Ha elveszíted a jelszavad, a fiókod nem állítható helyre — nincs szerver a visszaállításhoz.';

  @override
  String get privacyFontsHeading => 'Betűtípusok';

  @override
  String get privacyFontsBody =>
      'A Pulse minden betűtípust helyileg tartalmaz. Nem történik kérés a Google Fonts vagy bármely külső betűtípus szolgáltatás felé.';

  @override
  String get privacyThirdPartyHeading =>
      'Harmadik féltől származó szolgáltatások';

  @override
  String get privacyThirdPartyBody =>
      'A Pulse nem integrálódik semmilyen hirdetési hálózattal, analitikai szolgáltatóval, közösségi média platformmal vagy adatbrókerrel. Az egyetlen hálózati kapcsolatok az általad konfigurált átviteli relay-khez vannak.';

  @override
  String get privacyOpenSourceHeading => 'Open Source';

  @override
  String get privacyOpenSourceBody =>
      'A Pulse nyílt forráskódú szoftver. Auditálhatod a teljes forráskódot, hogy ellenőrizd ezeket az adatvédelmi állításokat.';

  @override
  String get privacyContactHeading => 'Kapcsolat';

  @override
  String get privacyContactBody =>
      'Adatvédelemmel kapcsolatos kérdések esetén nyiss egy issue-t a projekt tárhelyén.';

  @override
  String get privacyLastUpdated => 'Utolsó frissítés: 2026. március';

  @override
  String imageSaveFailed(Object error) {
    return 'Mentés sikertelen: $error';
  }

  @override
  String get themeEngineTitle => 'Téma motor';

  @override
  String get torBuiltInTitle => 'Beépített Tor';

  @override
  String get torConnectedSubtitle =>
      'Csatlakozva — Nostr irányítva a 127.0.0.1:9250-n keresztül';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Csatlakozás… $pct%';
  }

  @override
  String get torNotRunning => 'Nem fut — koppints az újraindításhoz';

  @override
  String get torDescription =>
      'Nostr irányítása Tor-on keresztül (Snowflake cenzúrázott hálózatokhoz)';

  @override
  String get torNetworkDiagnostics => 'Hálózati diagnosztika';

  @override
  String get torTransportLabel => 'Átvitel: ';

  @override
  String get torPtAuto => 'Auto';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Sima';

  @override
  String get torTimeoutLabel => 'Időkorlát: ';

  @override
  String get torInfoDescription =>
      'Ha engedélyezve van, a Nostr WebSocket kapcsolatok Tor-on (SOCKS5) keresztül vannak irányítva. A Tor Browser a 127.0.0.1:9150-en figyel. Az önálló tor démon a 9050-es portot használja. A Firebase kapcsolatok nem érintettek.';

  @override
  String get torRouteNostrTitle => 'Nostr irányítása Tor-on keresztül';

  @override
  String get torManagedByBuiltin => 'Beépített Tor által kezelve';

  @override
  String get torActiveRouting =>
      'Aktív — Nostr forgalom Tor-on keresztül irányítva';

  @override
  String get torDisabled => 'Letiltva';

  @override
  String get torProxySocks5 => 'Tor Proxy (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Proxy hoszt';

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
  String get torForcePulseTitle => 'Route Pulse relay through Tor';

  @override
  String get torForcePulseSubtitle =>
      'All Pulse relay connections will go through Tor. Slower but hides your IP from the server.';

  @override
  String get torForcePulseDisabled => 'Tor must be enabled first';

  @override
  String get i2pProxySocks5 => 'I2P Proxy (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'Az I2P alapértelmezés szerint SOCKS5-öt használ a 4447-es porton. Csatlakozz egy Nostr relay-hez I2P outproxy-n keresztül (pl. relay.damus.i2p) a más átvitelen lévő felhasználókkal való kommunikációhoz. A Tor prioritást élvez, ha mindkettő engedélyezve van.';

  @override
  String get i2pRouteNostrTitle => 'Nostr irányítása I2P-n keresztül';

  @override
  String get i2pActiveRouting =>
      'Aktív — Nostr forgalom I2P-n keresztül irányítva';

  @override
  String get i2pDisabled => 'Letiltva';

  @override
  String get i2pProxyHostLabel => 'Proxy hoszt';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'I2P Router alapértelmezett SOCKS5 port: 4447';

  @override
  String get customProxySocks5 => 'Egyéni proxy (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Az egyéni proxy a forgalmat a V2Ray/Xray/Shadowsocks-on keresztül irányítja. A CF Worker személyes relay proxyként működik a Cloudflare CDN-en — a GFW *.workers.dev-et lát, nem a valódi relay-t.';

  @override
  String get customSocks5ProxyTitle => 'Egyéni SOCKS5 proxy';

  @override
  String get customProxyActive =>
      'Aktív — forgalom SOCKS5-ön keresztül irányítva';

  @override
  String get customProxyDisabled => 'Letiltva';

  @override
  String get customProxyHostLabel => 'Proxy hoszt';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker domain (opcionális)';

  @override
  String get customWorkerHelpTitle => 'CF Worker relay telepítése (ingyenes)';

  @override
  String get customWorkerScriptCopied => 'Szkript másolva!';

  @override
  String get customWorkerStep1 =>
      '1. Menj a dash.cloudflare.com → Workers & Pages oldalra\n2. Create Worker → illeszd be ezt a szkriptet:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → másold ki a domaint (pl. my-relay.user.workers.dev)\n4. Illeszd be a domaint fent → Mentés\n\nAz alkalmazás automatikusan csatlakozik: wss://domain/?r=relay_url\nA GFW ezt látja: kapcsolat a *.workers.dev-hez (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Csatlakozva — SOCKS5 a 127.0.0.1:$port-on';
  }

  @override
  String get psiphonConnecting => 'Csatlakozás…';

  @override
  String get psiphonNotRunning => 'Nem fut — koppints az újraindításhoz';

  @override
  String get psiphonDescription =>
      'Gyors alagút (~3mp bootstrap, 2000+ rotáló VPS)';

  @override
  String get turnCommunityServers => 'Közösségi TURN szerverek';

  @override
  String get turnCustomServer => 'Egyéni TURN szerver (BYOD)';

  @override
  String get turnInfoDescription =>
      'A TURN szerverek csak már titkosított streameket továbbítanak (DTLS-SRTP). A relay üzemeltető látja az IP-d és a forgalom mennyiségét, de nem tudja visszafejteni a hívásokat. A TURN csak akkor használatos, ha a közvetlen P2P sikertelen (~15–20% a kapcsolatoknak).';

  @override
  String get turnFreeLabel => 'INGYENES';

  @override
  String get turnServerUrlLabel => 'TURN szerver URL';

  @override
  String get turnServerUrlHint => 'turn:a-szervered.com:3478 vagy turns:...';

  @override
  String get turnUsernameLabel => 'Felhasználónév';

  @override
  String get turnPasswordLabel => 'Jelszó';

  @override
  String get turnOptionalHint => 'Opcionális';

  @override
  String get turnCustomInfo =>
      'Futtass coturn-t bármilyen 5\$/hó VPS-en a maximális kontrolért. A hitelesítő adatok helyileg vannak tárolva.';

  @override
  String get themePickerAppearance => 'Megjelenés';

  @override
  String get themePickerAccentColor => 'Kiemelő szín';

  @override
  String get themeModeLight => 'Világos';

  @override
  String get themeModeDark => 'Sötét';

  @override
  String get themeModeSystem => 'Rendszer';

  @override
  String get themeDynamicPresets => 'Előbeállítások';

  @override
  String get themeDynamicPrimaryColor => 'Elsődleges szín';

  @override
  String get themeDynamicBorderRadius => 'Sarokkerekítés';

  @override
  String get themeDynamicFont => 'Betűtípus';

  @override
  String get themeDynamicAppearance => 'Megjelenés';

  @override
  String get themeDynamicUiStyle => 'UI stílus';

  @override
  String get themeDynamicUiStyleDescription =>
      'A dialógusok, kapcsolók és jelzők megjelenését szabályozza.';

  @override
  String get themeDynamicSharp => 'Éles';

  @override
  String get themeDynamicRound => 'Kerekített';

  @override
  String get themeDynamicModeDark => 'Sötét';

  @override
  String get themeDynamicModeLight => 'Világos';

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
      'Érvénytelen Firebase URL. Elvárt: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Érvénytelen relay URL. Elvárt: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Érvénytelen Pulse szerver URL. Elvárt: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'Szerver URL';

  @override
  String get providerPulseServerUrlHint => 'https://a-szervered:8443';

  @override
  String get providerPulseInviteLabel => 'Meghívó kód';

  @override
  String get providerPulseInviteHint => 'Meghívó kód (ha szükséges)';

  @override
  String get providerPulseInfo =>
      'Saját üzemeltetésű relay. Kulcsok a helyreállítási jelszóból levezetve.';

  @override
  String get providerScreenTitle => 'Postafiók';

  @override
  String get providerSecondaryInboxesHeader => 'MÁSODLAGOS POSTAFIÓKOK';

  @override
  String get providerSecondaryInboxesInfo =>
      'A másodlagos postafiókok egyidejűleg fogadnak üzeneteket a redundancia érdekében.';

  @override
  String get providerRemoveTooltip => 'Eltávolítás';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... vagy hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... vagy hex privát kulcs';

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
  String get emojiNoRecent => 'Nincsenek legutóbbi emojik';

  @override
  String get emojiSearchHint => 'Emoji keresése...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Koppints a csevegéshez';

  @override
  String get imageViewerSaveToDownloads => 'Mentés a Letöltésekbe';

  @override
  String imageViewerSavedTo(String path) {
    return 'Mentve: $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Nyelv';

  @override
  String get settingsLanguageSubtitle => 'Az alkalmazás megjelenítési nyelve';

  @override
  String get settingsLanguageSystem => 'Rendszer alapértelmezett';

  @override
  String get onboardingLanguageTitle => 'Válaszd ki a nyelvedet';

  @override
  String get onboardingLanguageSubtitle =>
      'Később módosíthatod a Beállításokban';

  @override
  String get videoNoteRecord => 'Videóüzenet felvétele';

  @override
  String get videoNoteTapToRecord => 'Koppintson a felvételhez';

  @override
  String get videoNoteTapToStop => 'Koppintson a leállításhoz';

  @override
  String get videoNoteCameraPermission => 'Kamera-engedély megtagadva';

  @override
  String get videoNoteMaxDuration => 'Maximum 30 másodperc';

  @override
  String get videoNoteNotSupported =>
      'A videójegyzetek ezen a platformon nem támogatottak';

  @override
  String get navChats => 'Csevegések';

  @override
  String get navUpdates => 'Frissítések';

  @override
  String get navCalls => 'Hívások';

  @override
  String get filterAll => 'Összes';

  @override
  String get filterUnread => 'Olvasatlan';

  @override
  String get filterGroups => 'Csoportok';

  @override
  String get callsNoRecent => 'Nincs legutóbbi hívás';

  @override
  String get callsEmptySubtitle => 'A hívási előzmények itt fognak megjelenni';

  @override
  String get appBarEncrypted => 'végponttól végpontig titkosított';

  @override
  String get newStatus => 'Új állapot';

  @override
  String get newCall => 'Új hívás';
}
