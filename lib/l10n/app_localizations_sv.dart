// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Sök meddelanden...';

  @override
  String get search => 'Sök';

  @override
  String get clearSearch => 'Rensa sökning';

  @override
  String get closeSearch => 'Stäng sökning';

  @override
  String get moreOptions => 'Fler alternativ';

  @override
  String get back => 'Tillbaka';

  @override
  String get cancel => 'Avbryt';

  @override
  String get close => 'Stäng';

  @override
  String get confirm => 'Bekräfta';

  @override
  String get remove => 'Ta bort';

  @override
  String get save => 'Spara';

  @override
  String get add => 'Lägg till';

  @override
  String get copy => 'Kopiera';

  @override
  String get skip => 'Hoppa över';

  @override
  String get done => 'Klar';

  @override
  String get apply => 'Tillämpa';

  @override
  String get export => 'Exportera';

  @override
  String get import => 'Importera';

  @override
  String get homeNewGroup => 'Ny grupp';

  @override
  String get homeSettings => 'Inställningar';

  @override
  String get homeSearching => 'Söker meddelanden...';

  @override
  String get homeNoResults => 'Inga resultat hittades';

  @override
  String get homeNoChatHistory => 'Ingen chatthistorik ännu';

  @override
  String homeTransportSwitched(String address) {
    return 'Transport bytt → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name ringer...';
  }

  @override
  String get homeAccept => 'Acceptera';

  @override
  String get homeDecline => 'Avvisa';

  @override
  String get homeLoadEarlier => 'Ladda tidigare meddelanden';

  @override
  String get homeChats => 'Chattar';

  @override
  String get homeSelectConversation => 'Välj en konversation';

  @override
  String get homeNoChatsYet => 'Inga chattar ännu';

  @override
  String get homeAddContactToStart =>
      'Lägg till en kontakt för att börja chatta';

  @override
  String get homeNewChat => 'Ny Chatt';

  @override
  String get homeNewChatTooltip => 'Ny chatt';

  @override
  String get homeIncomingCallTitle => 'Inkommande Samtal';

  @override
  String get homeIncomingGroupCallTitle => 'Inkommande Gruppsamtal';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — inkommande gruppsamtal';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Inga chattar som matchar \"$query\"';
  }

  @override
  String get homeSectionChats => 'Chattar';

  @override
  String get homeSectionMessages => 'Meddelanden';

  @override
  String get homeDbEncryptionUnavailable =>
      'Databaskryptering inte tillgänglig — installera SQLCipher för fullt skydd';

  @override
  String get chatFileTooLargeGroup =>
      'Filer över 512 KB stöds inte i gruppchatter';

  @override
  String get chatLargeFile => 'Stor Fil';

  @override
  String get chatCancel => 'Avbryt';

  @override
  String get chatSend => 'Skicka';

  @override
  String get chatFileTooLarge =>
      'Filen är för stor — maximal storlek är 100 MB';

  @override
  String get chatMicDenied => 'Mikrofonbehörighet nekad';

  @override
  String get chatVoiceFailed =>
      'Kunde inte spara röstmeddelande — kontrollera tillgängligt lagringsutrymme';

  @override
  String get chatScheduleFuture => 'Schemalagd tid måste vara i framtiden';

  @override
  String get chatToday => 'Idag';

  @override
  String get chatYesterday => 'Igår';

  @override
  String get chatEdited => 'redigerad';

  @override
  String get chatYou => 'Du';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Den här filen är $size MB. Att skicka stora filer kan vara långsamt på vissa nätverk. Fortsätta?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Säkerhetsnyckeln för $name har ändrats. Tryck för att verifiera.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Kunde inte kryptera meddelande till $name — meddelandet skickades inte.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Säkerhetsnumret för $name har ändrats. Tryck för att verifiera.';
  }

  @override
  String get chatNoMessagesFound => 'Inga meddelanden hittades';

  @override
  String get chatMessagesE2ee => 'Meddelanden är end-to-end-krypterade';

  @override
  String get chatSayHello => 'Säg hej';

  @override
  String get appBarOnline => 'online';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'skriver';

  @override
  String get appBarSearchMessages => 'Sök meddelanden...';

  @override
  String get appBarMute => 'Tysta';

  @override
  String get appBarUnmute => 'Slå på ljud';

  @override
  String get appBarMedia => 'Media';

  @override
  String get appBarDisappearing => 'Försvinnande meddelanden';

  @override
  String get appBarDisappearingOn => 'Försvinnande: på';

  @override
  String get appBarGroupSettings => 'Gruppinställningar';

  @override
  String get appBarSearchTooltip => 'Sök meddelanden';

  @override
  String get appBarVoiceCall => 'Röstsamtal';

  @override
  String get appBarVideoCall => 'Videosamtal';

  @override
  String get inputMessage => 'Meddelande...';

  @override
  String get inputAttachFile => 'Bifoga fil';

  @override
  String get inputSendMessage => 'Skicka meddelande';

  @override
  String get inputRecordVoice => 'Spela in röstmeddelande';

  @override
  String get inputSendVoice => 'Skicka röstmeddelande';

  @override
  String get inputCancelReply => 'Avbryt svar';

  @override
  String get inputCancelEdit => 'Avbryt redigering';

  @override
  String get inputCancelRecording => 'Avbryt inspelning';

  @override
  String get inputRecording => 'Spelar in…';

  @override
  String get inputEditingMessage => 'Redigerar meddelande';

  @override
  String get inputPhoto => 'Foto';

  @override
  String get inputVoiceMessage => 'Röstmeddelande';

  @override
  String get inputFile => 'Fil';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'n',
      one: '',
    );
    return '$count schemalagt meddelande$_temp0';
  }

  @override
  String get callInitializing => 'Initierar samtal…';

  @override
  String get callConnecting => 'Ansluter…';

  @override
  String get callConnectingRelay => 'Ansluter (relä)…';

  @override
  String get callSwitchingRelay => 'Byter till reläläge…';

  @override
  String get callConnectionFailed => 'Anslutningen misslyckades';

  @override
  String get callReconnecting => 'Återansluter…';

  @override
  String get callEnded => 'Samtalet avslutat';

  @override
  String get callLive => 'Live';

  @override
  String get callEnd => 'Avsluta';

  @override
  String get callEndCall => 'Lägg på';

  @override
  String get callMute => 'Tysta';

  @override
  String get callUnmute => 'Slå på ljud';

  @override
  String get callSpeaker => 'Högtalare';

  @override
  String get callCameraOn => 'Kamera På';

  @override
  String get callCameraOff => 'Kamera Av';

  @override
  String get callShareScreen => 'Dela Skärm';

  @override
  String get callStopShare => 'Sluta Dela';

  @override
  String callTorBackup(String duration) {
    return 'Tor-backup · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor-backup aktiv — primär väg otillgänglig';

  @override
  String get callDirectFailed =>
      'Direktanslutning misslyckades — byter till reläläge…';

  @override
  String get callTurnUnreachable =>
      'TURN-servrar onåbara. Lägg till en anpassad TURN i Inställningar → Avancerat.';

  @override
  String get callRelayMode => 'Reläläge aktivt (begränsat nätverk)';

  @override
  String get callStarting => 'Startar samtal…';

  @override
  String get callConnectingToGroup => 'Ansluter till grupp…';

  @override
  String get callGroupOpenedInBrowser => 'Gruppsamtal öppnat i webbläsare';

  @override
  String get callCouldNotOpenBrowser => 'Kunde inte öppna webbläsare';

  @override
  String get callInviteLinkSent =>
      'Inbjudningslänk skickad till alla gruppmedlemmar.';

  @override
  String get callOpenLinkManually =>
      'Öppna länken ovan manuellt eller tryck för att försöka igen.';

  @override
  String get callJitsiNotE2ee => 'Jitsi-samtal är INTE end-to-end-krypterade';

  @override
  String get callRetryOpenBrowser => 'Försök öppna webbläsare igen';

  @override
  String get callClose => 'Stäng';

  @override
  String get callCamOn => 'Kamera på';

  @override
  String get callCamOff => 'Kamera av';

  @override
  String get noConnection => 'Ingen anslutning — meddelanden köas';

  @override
  String get connected => 'Ansluten';

  @override
  String get connecting => 'Ansluter…';

  @override
  String get disconnected => 'Frånkopplad';

  @override
  String get offlineBanner =>
      'Ingen anslutning — meddelanden köas och skickas när du är online igen';

  @override
  String get lanModeBanner =>
      'LAN-läge — Inget internet · Endast lokalt nätverk';

  @override
  String get probeCheckingNetwork => 'Kontrollerar nätverksanslutning…';

  @override
  String get probeDiscoveringRelays =>
      'Upptäcker reläer via gemenskapens kataloger…';

  @override
  String get probeStartingTor => 'Startar Tor för bootstrap…';

  @override
  String get probeFindingRelaysTor => 'Hittar nåbara reläer via Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'er',
      one: '',
    );
    return 'Nätverk redo — $count relä$_temp0 hittade';
  }

  @override
  String get probeNoRelaysFound =>
      'Inga nåbara reläer hittades — meddelanden kan fördröjas';

  @override
  String get jitsiWarningTitle => 'Inte end-to-end-krypterat';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet-samtal krypteras inte av Pulse. Använd bara för icke-känsliga samtal.';

  @override
  String get jitsiConfirm => 'Gå med ändå';

  @override
  String get jitsiGroupWarningTitle => 'Inte end-to-end-krypterat';

  @override
  String get jitsiGroupWarningBody =>
      'Det här samtalet har för många deltagare för det inbyggda krypterade meshnätverket.\n\nEn Jitsi Meet-länk öppnas i din webbläsare. Jitsi är INTE end-to-end-krypterat — servern kan se ditt samtal.';

  @override
  String get jitsiContinueAnyway => 'Fortsätt ändå';

  @override
  String get retry => 'Försök igen';

  @override
  String get setupCreateAnonymousAccount => 'Skapa ett anonymt konto';

  @override
  String get setupTapToChangeColor => 'Tryck för att ändra färg';

  @override
  String get setupReqMinLength => 'Minst 16 tecken';

  @override
  String get setupReqVariety =>
      '3 av 4: stora, små bokstäver, siffror, symboler';

  @override
  String get setupReqMatch => 'Lösenorden stämmer överens';

  @override
  String get setupYourNickname => 'Ditt smeknamn';

  @override
  String get setupRecoveryPassword => 'Återställningslösenord (min. 16)';

  @override
  String get setupConfirmPassword => 'Bekräfta lösenord';

  @override
  String get setupMin16Chars => 'Minst 16 tecken';

  @override
  String get setupPasswordsDoNotMatch => 'Lösenorden matchar inte';

  @override
  String get setupEntropyWeak => 'Svagt';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Starkt';

  @override
  String get setupEntropyWeakNeedsVariety => 'Svagt (behöver 3 teckentyper)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bitar)';
  }

  @override
  String get setupPasswordWarning =>
      'Det här lösenordet är enda sättet att återställa ditt konto. Det finns ingen server — ingen lösenordsåterställning. Kom ihåg det eller skriv ner det.';

  @override
  String get setupCreateAccount => 'Skapa konto';

  @override
  String get setupAlreadyHaveAccount => 'Har du redan ett konto? ';

  @override
  String get setupRestore => 'Återställ →';

  @override
  String get restoreTitle => 'Återställ konto';

  @override
  String get restoreInfoBanner =>
      'Ange ditt återställningslösenord — din adress (Nostr + Session) återställs automatiskt. Kontakter och meddelanden lagrades bara lokalt.';

  @override
  String get restoreNewNickname => 'Nytt smeknamn (kan ändras senare)';

  @override
  String get restoreButton => 'Återställ konto';

  @override
  String get lockTitle => 'Pulse är låst';

  @override
  String get lockSubtitle => 'Ange ditt lösenord för att fortsätta';

  @override
  String get lockPasswordHint => 'Lösenord';

  @override
  String get lockUnlock => 'Lås upp';

  @override
  String get lockPanicHint =>
      'Glömt ditt lösenord? Ange din paniknyckel för att radera all data.';

  @override
  String get lockTooManyAttempts => 'För många försök. Raderar all data…';

  @override
  String get lockWrongPassword => 'Fel lösenord';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Fel lösenord — $attempts/$max försök';
  }

  @override
  String get onboardingSkip => 'Hoppa över';

  @override
  String get onboardingNext => 'Nästa';

  @override
  String get onboardingGetStarted => 'Skapa konto';

  @override
  String get onboardingWelcomeTitle => 'Välkommen till Pulse';

  @override
  String get onboardingWelcomeBody =>
      'En decentraliserad, end-to-end-krypterad meddelandeapp.\n\nInga centrala servrar. Ingen datainsamling. Inga bakdörrar.\nDina samtal tillhör bara dig.';

  @override
  String get onboardingTransportTitle => 'Transportagnostisk';

  @override
  String get onboardingTransportBody =>
      'Använd Firebase, Nostr, eller båda samtidigt.\n\nMeddelanden routas automatiskt över nätverk. Inbyggt Tor- och I2P-stöd för censurresistens.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Varje meddelande krypteras med Signal Protocol (Double Ratchet + X3DH) för framåtsekretess.\n\nDessutom insvept med Kyber-1024 — en NIST-standardiserad post-kvantalgoritm — som skyddar mot framtida kvantdatorer.';

  @override
  String get onboardingKeysTitle => 'Du äger dina nycklar';

  @override
  String get onboardingKeysBody =>
      'Dina identitetsnycklar lämnar aldrig din enhet.\n\nSignal-fingeravtryck låter dig verifiera kontakter utanför bandet. TOFU (Trust On First Use) upptäcker nyckelbyten automatiskt.';

  @override
  String get onboardingThemeTitle => 'Välj ditt utseende';

  @override
  String get onboardingThemeBody =>
      'Välj ett tema och accentfärg. Du kan alltid ändra detta senare i Inställningar.';

  @override
  String get contactsNewChat => 'Ny chatt';

  @override
  String get contactsAddContact => 'Lägg till kontakt';

  @override
  String get contactsSearchHint => 'Sök...';

  @override
  String get contactsNewGroup => 'Ny grupp';

  @override
  String get contactsNoContactsYet => 'Inga kontakter ännu';

  @override
  String get contactsAddHint => 'Tryck på + för att lägga till någons adress';

  @override
  String get contactsNoMatch => 'Inga matchande kontakter';

  @override
  String get contactsRemoveTitle => 'Ta bort kontakt';

  @override
  String contactsRemoveMessage(String name) {
    return 'Ta bort $name?';
  }

  @override
  String get contactsRemove => 'Ta bort';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'er',
      one: '',
    );
    return '$count kontakt$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Öppna Länk';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Öppna denna URL i din webbläsare?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Öppna';

  @override
  String get bubbleSecurityWarning => 'Säkerhetsvarning';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" är en körbar filtyp. Att spara och köra den kan skada din enhet. Spara ändå?';
  }

  @override
  String get bubbleSaveAnyway => 'Spara Ändå';

  @override
  String bubbleSavedTo(String path) {
    return 'Sparad till $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Kunde inte spara: $error';
  }

  @override
  String get bubbleNotEncrypted => 'INTE KRYPTERAT';

  @override
  String get bubbleCorruptedImage => '[Korrupt bild]';

  @override
  String get bubbleReplyPhoto => 'Foto';

  @override
  String get bubbleReplyVoice => 'Röstmeddelande';

  @override
  String get bubbleReplyVideo => 'Videomeddelande';

  @override
  String bubbleReadBy(String names) {
    return 'Läst av $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Läst av $count';
  }

  @override
  String get chatTileTapToStart => 'Tryck för att börja chatta';

  @override
  String get chatTileMessageSent => 'Meddelande skickat';

  @override
  String get chatTileEncryptedMessage => 'Krypterat meddelande';

  @override
  String chatTileYouPrefix(String text) {
    return 'Du: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Röstmeddelande';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Röstmeddelande ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Krypterat meddelande';

  @override
  String get groupNewGroup => 'Ny Grupp';

  @override
  String get groupGroupName => 'Gruppnamn';

  @override
  String get groupSelectMembers => 'Välj medlemmar (min 2)';

  @override
  String get groupNoContactsYet =>
      'Inga kontakter ännu. Lägg till kontakter först.';

  @override
  String get groupCreate => 'Skapa';

  @override
  String get groupLabel => 'Grupp';

  @override
  String get profileVerifyIdentity => 'Verifiera Identitet';

  @override
  String profileVerifyInstructions(String name) {
    return 'Jämför dessa fingeravtryck med $name via ett röstsamtal eller personligen. Om båda värdena matchar på båda enheterna, tryck på \"Markera som Verifierad\".';
  }

  @override
  String get profileTheirKey => 'Deras nyckel';

  @override
  String get profileYourKey => 'Din nyckel';

  @override
  String get profileRemoveVerification => 'Ta Bort Verifiering';

  @override
  String get profileMarkAsVerified => 'Markera som Verifierad';

  @override
  String get profileAddressCopied => 'Adress kopierad';

  @override
  String get profileNoContactsToAdd =>
      'Inga kontakter att lägga till — alla är redan medlemmar';

  @override
  String get profileAddMembers => 'Lägg Till Medlemmar';

  @override
  String profileAddCount(int count) {
    return 'Lägg till ($count)';
  }

  @override
  String get profileRenameGroup => 'Byt Namn på Grupp';

  @override
  String get profileRename => 'Byt namn';

  @override
  String get profileRemoveMember => 'Ta bort medlem?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Ta bort $name från den här gruppen?';
  }

  @override
  String get profileKick => 'Sparka ut';

  @override
  String get profileSignalFingerprints => 'Signal-fingeravtryck';

  @override
  String get profileVerified => 'VERIFIERAD';

  @override
  String get profileVerify => 'Verifiera';

  @override
  String get profileEdit => 'Redigera';

  @override
  String get profileNoSession =>
      'Ingen session upprättad ännu — skicka ett meddelande först.';

  @override
  String get profileFingerprintCopied => 'Fingeravtryck kopierat';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mar',
      one: '',
    );
    return '$count medlem$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Verifiera Säkerhetsnummer';

  @override
  String get profileShowContactQr => 'Visa Kontakt-QR';

  @override
  String profileContactAddress(String name) {
    return 'Adress för $name';
  }

  @override
  String get profileExportChatHistory => 'Exportera Chatthistorik';

  @override
  String profileSavedTo(String path) {
    return 'Sparad till $path';
  }

  @override
  String get profileExportFailed => 'Export misslyckades';

  @override
  String get profileClearChatHistory => 'Rensa chatthistorik';

  @override
  String get profileDeleteGroup => 'Ta bort grupp';

  @override
  String get profileDeleteContact => 'Ta bort kontakt';

  @override
  String get profileLeaveGroup => 'Lämna grupp';

  @override
  String get profileLeaveGroupBody =>
      'Du kommer att tas bort från den här gruppen och den raderas från dina kontakter.';

  @override
  String get groupInviteTitle => 'Gruppinbjudan';

  @override
  String groupInviteBody(String from, String group) {
    return '$from bjöd in dig att gå med i \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Acceptera';

  @override
  String get groupInviteDecline => 'Avvisa';

  @override
  String get groupMemberLimitTitle => 'För många deltagare';

  @override
  String groupMemberLimitBody(int count) {
    return 'Den här gruppen kommer att ha $count deltagare. Krypterade mesh-samtal stödjer upp till 6. Större grupper faller tillbaka på Jitsi (inte E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Lägg till ändå';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name avvisade att gå med i \"$group\"';
  }

  @override
  String get transferTitle => 'Överför till Annan Enhet';

  @override
  String get transferInfoBox =>
      'Flytta din Signal-identitet och Nostr-nycklar till en ny enhet.\nChattsessioner överförs INTE — framåtsekretess bevaras.';

  @override
  String get transferSendFromThis => 'Skicka från den här enheten';

  @override
  String get transferSendSubtitle =>
      'Den här enheten har nycklarna. Dela en kod med den nya enheten.';

  @override
  String get transferReceiveOnThis => 'Ta emot på den här enheten';

  @override
  String get transferReceiveSubtitle =>
      'Det här är den nya enheten. Ange koden från den gamla enheten.';

  @override
  String get transferChooseMethod => 'Välj Överföringsmetod';

  @override
  String get transferLan => 'LAN (Samma Nätverk)';

  @override
  String get transferLanSubtitle =>
      'Snabbt och direkt. Båda enheterna måste vara på samma Wi-Fi.';

  @override
  String get transferNostrRelay => 'Nostr Relä';

  @override
  String get transferNostrRelaySubtitle =>
      'Fungerar över alla nätverk via ett befintligt Nostr relä.';

  @override
  String get transferRelayUrl => 'Relä-URL';

  @override
  String get transferEnterCode => 'Ange Överföringskod';

  @override
  String get transferPasteCode => 'Klistra in LAN:... eller NOS:...-koden här';

  @override
  String get transferConnect => 'Anslut';

  @override
  String get transferGenerating => 'Genererar överföringskod…';

  @override
  String get transferShareCode => 'Dela den här koden med mottagaren:';

  @override
  String get transferCopyCode => 'Kopiera Kod';

  @override
  String get transferCodeCopied => 'Kod kopierad till urklipp';

  @override
  String get transferWaitingReceiver => 'Väntar på att mottagaren ansluter…';

  @override
  String get transferConnectingSender => 'Ansluter till avsändaren…';

  @override
  String get transferVerifyBoth =>
      'Jämför den här koden på båda enheterna.\nOm de matchar är överföringen säker.';

  @override
  String get transferComplete => 'Överföring Klar';

  @override
  String get transferKeysImported => 'Nycklar Importerade';

  @override
  String get transferCompleteSenderBody =>
      'Dina nycklar förblir aktiva på den här enheten.\nMottagaren kan nu använda din identitet.';

  @override
  String get transferCompleteReceiverBody =>
      'Nycklar importerade framgångsrikt.\nStarta om appen för att tillämpa den nya identiteten.';

  @override
  String get transferRestartApp => 'Starta Om Appen';

  @override
  String get transferFailed => 'Överföring Misslyckades';

  @override
  String get transferTryAgain => 'Försök Igen';

  @override
  String get transferEnterRelayFirst => 'Ange en relä-URL först';

  @override
  String get transferPasteCodeFromSender =>
      'Klistra in överföringskoden från avsändaren';

  @override
  String get menuReply => 'Svara';

  @override
  String get menuForward => 'Vidarebefordra';

  @override
  String get menuReact => 'Reagera';

  @override
  String get menuCopy => 'Kopiera';

  @override
  String get menuEdit => 'Redigera';

  @override
  String get menuRetry => 'Försök igen';

  @override
  String get menuCancelScheduled => 'Avbryt schemalagd';

  @override
  String get menuDelete => 'Radera';

  @override
  String get menuForwardTo => 'Vidarebefordra till…';

  @override
  String menuForwardedTo(String name) {
    return 'Vidarebefordrat till $name';
  }

  @override
  String get menuScheduledMessages => 'Schemalagda meddelanden';

  @override
  String get menuNoScheduledMessages => 'Inga schemalagda meddelanden';

  @override
  String menuSendsOn(String date) {
    return 'Skickas den $date';
  }

  @override
  String get menuDisappearingMessages => 'Försvinnande Meddelanden';

  @override
  String get menuDisappearingSubtitle =>
      'Meddelanden raderas automatiskt efter den valda tiden.';

  @override
  String get menuTtlOff => 'Av';

  @override
  String get menuTtl1h => '1 timme';

  @override
  String get menuTtl24h => '24 timmar';

  @override
  String get menuTtl7d => '7 dagar';

  @override
  String get menuAttachPhoto => 'Foto';

  @override
  String get menuAttachFile => 'Fil';

  @override
  String get menuAttachVideo => 'Video';

  @override
  String get mediaTitle => 'Media';

  @override
  String get mediaFileLabel => 'FIL';

  @override
  String mediaPhotosTab(int count) {
    return 'Foton ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Filer ($count)';
  }

  @override
  String get mediaNoPhotos => 'Inga foton ännu';

  @override
  String get mediaNoFiles => 'Inga filer ännu';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Sparad till Nedladdningar/$name';
  }

  @override
  String get mediaFailedToSave => 'Kunde inte spara fil';

  @override
  String get statusNewStatus => 'Ny Status';

  @override
  String get statusPublish => 'Publicera';

  @override
  String get statusExpiresIn24h => 'Statusen upphör om 24 timmar';

  @override
  String get statusWhatsOnYourMind => 'Vad tänker du på?';

  @override
  String get statusPhotoAttached => 'Foto bifogat';

  @override
  String get statusAttachPhoto => 'Bifoga foto (valfritt)';

  @override
  String get statusEnterText => 'Ange lite text för din status.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Kunde inte välja foto: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Publicering misslyckades: $error';
  }

  @override
  String get panicSetPanicKey => 'Ange Paniknyckel';

  @override
  String get panicEmergencySelfDestruct => 'Nödsjälvförstöring';

  @override
  String get panicIrreversible => 'Den här åtgärden är oåterkallelig';

  @override
  String get panicWarningBody =>
      'Att ange den här nyckeln på låsskärmen raderar omedelbart ALL data — meddelanden, kontakter, nycklar, identitet. Använd en annan nyckel än ditt vanliga lösenord.';

  @override
  String get panicKeyHint => 'Paniknyckel';

  @override
  String get panicConfirmHint => 'Bekräfta paniknyckel';

  @override
  String get panicMinChars => 'Paniknyckeln måste vara minst 8 tecken';

  @override
  String get panicKeysDoNotMatch => 'Nycklarna matchar inte';

  @override
  String get panicSetFailed => 'Kunde inte spara paniknyckel — försök igen';

  @override
  String get passwordSetAppPassword => 'Ange Applösenord';

  @override
  String get passwordProtectsMessages => 'Skyddar dina meddelanden i vila';

  @override
  String get passwordInfoBanner =>
      'Krävs varje gång du öppnar Pulse. Om du glömmer det kan dina data inte återställas.';

  @override
  String get passwordHint => 'Lösenord';

  @override
  String get passwordConfirmHint => 'Bekräfta lösenord';

  @override
  String get passwordSetButton => 'Ange Lösenord';

  @override
  String get passwordSkipForNow => 'Hoppa över för nu';

  @override
  String get passwordMinChars => 'Lösenordet måste vara minst 8 tecken';

  @override
  String get passwordNeedsVariety =>
      'Måste innehålla bokstäver, siffror och specialtecken';

  @override
  String get passwordRequirements =>
      'Min. 8 tecken med bokstäver, siffror och ett specialtecken';

  @override
  String get passwordsDoNotMatch => 'Lösenorden matchar inte';

  @override
  String get profileCardSaved => 'Profil sparad!';

  @override
  String get profileCardE2eeIdentity => 'E2EE-identitet';

  @override
  String get profileCardDisplayName => 'Visningsnamn';

  @override
  String get profileCardDisplayNameHint => 't.ex. Erik Svensson';

  @override
  String get profileCardAbout => 'Om';

  @override
  String get profileCardSaveProfile => 'Spara Profil';

  @override
  String get profileCardYourName => 'Ditt Namn';

  @override
  String get profileCardAddressCopied => 'Adress kopierad!';

  @override
  String get profileCardInboxAddress => 'Din Inkorgsadress';

  @override
  String get profileCardInboxAddresses => 'Dina Inkorgsadresser';

  @override
  String get profileCardShareAllAddresses => 'Dela Alla Adresser (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Dela med kontakter så att de kan skicka meddelanden till dig.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Alla $count adresser kopierade som en länk!';
  }

  @override
  String get settingsMyProfile => 'Min Profil';

  @override
  String get settingsYourInboxAddress => 'Din Inkorgsadress';

  @override
  String get settingsMyQrCode => 'Dela kontakt';

  @override
  String get settingsMyQrSubtitle =>
      'QR-kod och inbjudningslänk för din adress';

  @override
  String get settingsShareMyAddress => 'Dela Min Adress';

  @override
  String get settingsNoAddressYet =>
      'Ingen adress ännu — spara inställningar först';

  @override
  String get settingsInviteLink => 'Inbjudningslänk';

  @override
  String get settingsRawAddress => 'Rå Adress';

  @override
  String get settingsCopyLink => 'Kopiera Länk';

  @override
  String get settingsCopyAddress => 'Kopiera Adress';

  @override
  String get settingsInviteLinkCopied => 'Inbjudningslänk kopierad';

  @override
  String get settingsAppearance => 'Utseende';

  @override
  String get settingsThemeEngine => 'Temamotor';

  @override
  String get settingsThemeEngineSubtitle => 'Anpassa färger och typsnitt';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle => 'E2EE-nycklar lagras säkert';

  @override
  String get settingsActive => 'AKTIV';

  @override
  String get settingsIdentityBackup => 'Identitetssäkerhetskopiering';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Exportera eller importera din Signal-identitet';

  @override
  String get settingsIdentityBackupBody =>
      'Exportera dina Signal-identitetsnycklar till en säkerhetskod, eller återställ från en befintlig.';

  @override
  String get settingsTransferDevice => 'Överför till Annan Enhet';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Flytta din identitet via LAN eller Nostr relä';

  @override
  String get settingsExportIdentity => 'Exportera Identitet';

  @override
  String get settingsExportIdentityBody =>
      'Kopiera den här säkerhetskoden och förvara den säkert:';

  @override
  String get settingsSaveFile => 'Spara Fil';

  @override
  String get settingsImportIdentity => 'Importera Identitet';

  @override
  String get settingsImportIdentityBody =>
      'Klistra in din säkerhetskod nedan. Detta skriver över din nuvarande identitet.';

  @override
  String get settingsPasteBackupCode => 'Klistra in säkerhetskod här…';

  @override
  String get settingsIdentityImported =>
      'Identitet + kontakter importerade! Starta om appen för att tillämpa.';

  @override
  String get settingsSecurity => 'Säkerhet';

  @override
  String get settingsAppPassword => 'Applösenord';

  @override
  String get settingsPasswordEnabled => 'Aktiverat — krävs vid varje start';

  @override
  String get settingsPasswordDisabled =>
      'Inaktiverat — appen öppnas utan lösenord';

  @override
  String get settingsChangePassword => 'Ändra Lösenord';

  @override
  String get settingsChangePasswordSubtitle => 'Uppdatera ditt applåslösenord';

  @override
  String get settingsSetPanicKey => 'Ange Paniknyckel';

  @override
  String get settingsChangePanicKey => 'Ändra Paniknyckel';

  @override
  String get settingsPanicKeySetSubtitle => 'Uppdatera nödraderingsnyckel';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'En nyckel som omedelbart raderar all data';

  @override
  String get settingsRemovePanicKey => 'Ta Bort Paniknyckel';

  @override
  String get settingsRemovePanicKeySubtitle => 'Inaktivera nödsjälvförstöring';

  @override
  String get settingsRemovePanicKeyBody =>
      'Nödsjälvförstöring inaktiveras. Du kan aktivera den igen när som helst.';

  @override
  String get settingsDisableAppPassword => 'Inaktivera Applösenord';

  @override
  String get settingsEnterCurrentPassword =>
      'Ange ditt nuvarande lösenord för att bekräfta';

  @override
  String get settingsCurrentPassword => 'Nuvarande lösenord';

  @override
  String get settingsIncorrectPassword => 'Felaktigt lösenord';

  @override
  String get settingsPasswordUpdated => 'Lösenord uppdaterat';

  @override
  String get settingsChangePasswordProceed =>
      'Ange ditt nuvarande lösenord för att fortsätta';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsBackupMessages => 'Säkerhetskopiera Meddelanden';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Exportera krypterad meddelandehistorik till en fil';

  @override
  String get settingsRestoreMessages => 'Återställ Meddelanden';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Importera meddelanden från en säkerhetskopia';

  @override
  String get settingsExportKeys => 'Exportera Nycklar';

  @override
  String get settingsExportKeysSubtitle =>
      'Spara identitetsnycklar till en krypterad fil';

  @override
  String get settingsImportKeys => 'Importera Nycklar';

  @override
  String get settingsImportKeysSubtitle =>
      'Återställ identitetsnycklar från en exporterad fil';

  @override
  String get settingsBackupPassword => 'Säkerhetskopieringslösenord';

  @override
  String get settingsPasswordCannotBeEmpty => 'Lösenordet kan inte vara tomt';

  @override
  String get settingsPasswordMin4Chars =>
      'Lösenordet måste vara minst 4 tecken';

  @override
  String get settingsCallsTurn => 'Samtal & TURN';

  @override
  String get settingsLocalNetwork => 'Lokalt Nätverk';

  @override
  String get settingsCensorshipResistance => 'Censurresistens';

  @override
  String get settingsNetwork => 'Nätverk';

  @override
  String get settingsProxyTunnels => 'Proxy & Tunnlar';

  @override
  String get settingsTurnServers => 'TURN-servrar';

  @override
  String get settingsProviderTitle => 'Leverantör';

  @override
  String get settingsLanFallback => 'LAN-reserv';

  @override
  String get settingsLanFallbackSubtitle =>
      'Sänd närvaro och leverera meddelanden på det lokala nätverket när internet inte är tillgängligt. Inaktivera på opålitliga nätverk (offentligt Wi-Fi).';

  @override
  String get settingsBgDelivery => 'Bakgrundsleverans';

  @override
  String get settingsBgDeliverySubtitle =>
      'Fortsätt ta emot meddelanden när appen är minimerad. Visar en permanent avisering.';

  @override
  String get settingsYourInboxProvider => 'Din Inkorgsleverantör';

  @override
  String get settingsConnectionDetails => 'Anslutningsdetaljer';

  @override
  String get settingsSaveAndConnect => 'Spara & Anslut';

  @override
  String get settingsSecondaryInboxes => 'Sekundära Inkorgar';

  @override
  String get settingsAddSecondaryInbox => 'Lägg till Sekundär Inkorg';

  @override
  String get settingsAdvanced => 'Avancerat';

  @override
  String get settingsDiscover => 'Upptäck';

  @override
  String get settingsAbout => 'Om';

  @override
  String get settingsPrivacyPolicy => 'Integritetspolicy';

  @override
  String get settingsPrivacyPolicySubtitle => 'Hur Pulse skyddar dina data';

  @override
  String get settingsCrashReporting => 'Kraschrapportering';

  @override
  String get settingsCrashReportingSubtitle =>
      'Skicka anonyma kraschrapporter för att förbättra Pulse. Inget meddelandeinnehåll eller kontakter skickas.';

  @override
  String get settingsCrashReportingEnabled =>
      'Kraschrapportering aktiverad — starta om appen för att tillämpa';

  @override
  String get settingsCrashReportingDisabled =>
      'Kraschrapportering inaktiverad — starta om appen för att tillämpa';

  @override
  String get settingsSensitiveOperation => 'Känslig Åtgärd';

  @override
  String get settingsSensitiveOperationBody =>
      'Dessa nycklar är din identitet. Vem som helst med den här filen kan utge sig för att vara dig. Förvara den säkert och radera den efter överföring.';

  @override
  String get settingsIUnderstandContinue => 'Jag Förstår, Fortsätt';

  @override
  String get settingsReplaceIdentity => 'Ersätt Identitet?';

  @override
  String get settingsReplaceIdentityBody =>
      'Detta skriver över dina nuvarande identitetsnycklar. Dina befintliga Signal-sessioner ogiltigförklaras och kontakter behöver återupprätta kryptering. Appen behöver startas om.';

  @override
  String get settingsReplaceKeys => 'Ersätt Nycklar';

  @override
  String get settingsKeysImported => 'Nycklar Importerade';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count nycklar importerade framgångsrikt. Starta om appen för att initiera med den nya identiteten.';
  }

  @override
  String get settingsRestartNow => 'Starta Om Nu';

  @override
  String get settingsLater => 'Senare';

  @override
  String get profileGroupLabel => 'Grupp';

  @override
  String get profileAddButton => 'Lägg till';

  @override
  String get profileKickButton => 'Sparka ut';

  @override
  String get dataSectionTitle => 'Data';

  @override
  String get dataBackupMessages => 'Säkerhetskopiera Meddelanden';

  @override
  String get dataBackupPasswordSubtitle =>
      'Välj ett lösenord för att kryptera din meddelandesäkerhetskopia.';

  @override
  String get dataBackupConfirmLabel => 'Skapa Säkerhetskopia';

  @override
  String get dataCreatingBackup => 'Skapar Säkerhetskopia';

  @override
  String get dataBackupPreparing => 'Förbereder...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Exporterar meddelande $done av $total...';
  }

  @override
  String get dataBackupSavingFile => 'Sparar fil...';

  @override
  String get dataSaveMessageBackupDialog => 'Spara Meddelandesäkerhetskopia';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Säkerhetskopia sparad ($count meddelanden)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Säkerhetskopiering misslyckades — inga data exporterade';

  @override
  String dataBackupFailedError(String error) {
    return 'Säkerhetskopiering misslyckades: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Välj Meddelandesäkerhetskopia';

  @override
  String get dataInvalidBackupFile => 'Ogiltig säkerhetskopia (för liten)';

  @override
  String get dataNotValidBackupFile => 'Inte en giltig Pulse-säkerhetskopia';

  @override
  String get dataRestoreMessages => 'Återställ Meddelanden';

  @override
  String get dataRestorePasswordSubtitle =>
      'Ange lösenordet som användes för att skapa denna säkerhetskopia.';

  @override
  String get dataRestoreConfirmLabel => 'Återställ';

  @override
  String get dataRestoringMessages => 'Återställer Meddelanden';

  @override
  String get dataRestoreDecrypting => 'Dekrypterar...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Importerar meddelande $done av $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Återställning misslyckades — fel lösenord eller korrupt fil';

  @override
  String dataRestoreSuccess(int count) {
    return '$count nya meddelanden återställda';
  }

  @override
  String get dataRestoreNothingNew =>
      'Inga nya meddelanden att importera (alla finns redan)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Återställning misslyckades: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Välj Nyckelexport';

  @override
  String get dataNotValidKeyFile => 'Inte en giltig Pulse-nyckelexportfil';

  @override
  String get dataExportKeys => 'Exportera Nycklar';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Välj ett lösenord för att kryptera din nyckelexport.';

  @override
  String get dataExportKeysConfirmLabel => 'Exportera';

  @override
  String get dataExportingKeys => 'Exporterar Nycklar';

  @override
  String get dataExportingKeysStatus => 'Krypterar identitetsnycklar...';

  @override
  String get dataSaveKeyExportDialog => 'Spara Nyckelexport';

  @override
  String dataKeysExportedTo(String path) {
    return 'Nycklar exporterade till:\n$path';
  }

  @override
  String get dataExportFailed => 'Export misslyckades — inga nycklar hittades';

  @override
  String dataExportFailedError(String error) {
    return 'Export misslyckades: $error';
  }

  @override
  String get dataImportKeys => 'Importera Nycklar';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Ange lösenordet som användes för att kryptera denna nyckelexport.';

  @override
  String get dataImportKeysConfirmLabel => 'Importera';

  @override
  String get dataImportingKeys => 'Importerar Nycklar';

  @override
  String get dataImportingKeysStatus => 'Dekrypterar identitetsnycklar...';

  @override
  String get dataImportFailed =>
      'Import misslyckades — fel lösenord eller korrupt fil';

  @override
  String dataImportFailedError(String error) {
    return 'Import misslyckades: $error';
  }

  @override
  String get securitySectionTitle => 'Säkerhet';

  @override
  String get securityIncorrectPassword => 'Felaktigt lösenord';

  @override
  String get securityPasswordUpdated => 'Lösenord uppdaterat';

  @override
  String get appearanceSectionTitle => 'Utseende';

  @override
  String appearanceExportFailed(String error) {
    return 'Export misslyckades: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Sparad till $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Kunde inte spara: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Import misslyckades: $error';
  }

  @override
  String get aboutSectionTitle => 'Om';

  @override
  String get providerPublicKey => 'Publik Nyckel';

  @override
  String get providerRelay => 'Relä';

  @override
  String get providerAutoConfigured =>
      'Automatiskt konfigurerat från ditt återställningslösenord. Relä automatiskt upptäckt.';

  @override
  String get providerKeyStoredLocally =>
      'Din nyckel lagras lokalt i säker lagring — skickas aldrig till någon server.';

  @override
  String get providerSessionInfo =>
      'Session Network — lök-rutad E2EE. Ditt Session ID genereras automatiskt och lagras säkert. Noder upptäcks automatiskt från inbyggda frönoder.';

  @override
  String get providerAdvanced => 'Avancerat';

  @override
  String get providerSaveAndConnect => 'Spara & Anslut';

  @override
  String get providerAddSecondaryInbox => 'Lägg till Sekundär Inkorg';

  @override
  String get providerSecondaryInboxes => 'Sekundära Inkorgar';

  @override
  String get providerYourInboxProvider => 'Din Inkorgsleverantör';

  @override
  String get providerConnectionDetails => 'Anslutningsdetaljer';

  @override
  String get addContactTitle => 'Lägg till Kontakt';

  @override
  String get addContactInviteLinkLabel => 'Inbjudningslänk eller Adress';

  @override
  String get addContactTapToPaste => 'Tryck för att klistra in inbjudningslänk';

  @override
  String get addContactPasteTooltip => 'Klistra in från urklipp';

  @override
  String get addContactAddressDetected => 'Kontaktadress upptäckt';

  @override
  String addContactRoutesDetected(int count) {
    return '$count rutter upptäckta — SmartRouter väljer den snabbaste';
  }

  @override
  String get addContactFetchingProfile => 'Hämtar profil…';

  @override
  String addContactProfileFound(String name) {
    return 'Hittad: $name';
  }

  @override
  String get addContactNoProfileFound => 'Ingen profil hittad';

  @override
  String get addContactDisplayNameLabel => 'Visningsnamn';

  @override
  String get addContactDisplayNameHint => 'Vad vill du kalla dem?';

  @override
  String get addContactAddManually => 'Lägg till adress manuellt';

  @override
  String get addContactButton => 'Lägg till Kontakt';

  @override
  String get networkDiagnosticsTitle => 'Nätverksdiagnostik';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr Reläer';

  @override
  String get networkDiagnosticsDirect => 'Direkt';

  @override
  String get networkDiagnosticsTorOnly => 'Endast Tor';

  @override
  String get networkDiagnosticsBest => 'Bäst';

  @override
  String get networkDiagnosticsNone => 'ingen';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Status';

  @override
  String get networkDiagnosticsConnected => 'Ansluten';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Ansluter $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Av';

  @override
  String get networkDiagnosticsTransport => 'Transport';

  @override
  String get networkDiagnosticsInfrastructure => 'Infrastruktur';

  @override
  String get networkDiagnosticsSessionNodes => 'Session-noder';

  @override
  String get networkDiagnosticsTurnServers => 'TURN-servrar';

  @override
  String get networkDiagnosticsLastProbe => 'Senaste kontroll';

  @override
  String get networkDiagnosticsRunning => 'Kör...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Kör Diagnostik';

  @override
  String get networkDiagnosticsForceReprobe => 'Tvinga Fullständig Omkontroll';

  @override
  String get networkDiagnosticsJustNow => 'just nu';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '${minutes}m sedan';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '${hours}t sedan';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '${days}d sedan';
  }

  @override
  String get homeNoEch => 'Ingen ECH';

  @override
  String get homeNoEchTooltip =>
      'uTLS-proxy otillgänglig — ECH inaktiverat.\nTLS-fingeravtryck är synligt för DPI.';

  @override
  String get settingsTitle => 'Inställningar';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Sparad & ansluten till $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Inbyggd Tor kunde inte startas';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon kunde inte startas';

  @override
  String get verifyTitle => 'Verifiera Säkerhetsnummer';

  @override
  String get verifyIdentityVerified => 'Identitet Verifierad';

  @override
  String get verifyNotYetVerified => 'Ännu Inte Verifierad';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Du har verifierat säkerhetsnumret för $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Jämför dessa nummer med $name personligen eller via en betrodd kanal.';
  }

  @override
  String get verifyExplanation =>
      'Varje konversation har ett unikt säkerhetsnummer. Om ni båda ser samma nummer på era enheter är er anslutning verifierad end-to-end.';

  @override
  String verifyContactKey(String name) {
    return 'Nyckel för $name';
  }

  @override
  String get verifyYourKey => 'Din Nyckel';

  @override
  String get verifyRemoveVerification => 'Ta Bort Verifiering';

  @override
  String get verifyMarkAsVerified => 'Markera som Verifierad';

  @override
  String verifyAfterReinstall(String name) {
    return 'Om $name installerar om appen ändras säkerhetsnumret och verifieringen tas bort automatiskt.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Markera bara som verifierad efter att ha jämfört nummer med $name via ett röstsamtal eller personligen.';
  }

  @override
  String get verifyNoSession =>
      'Ingen krypteringssession upprättad ännu. Skicka ett meddelande först för att generera säkerhetsnummer.';

  @override
  String get verifyNoKeyAvailable => 'Ingen nyckel tillgänglig';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label-fingeravtryck kopierat';
  }

  @override
  String get providerDatabaseUrlLabel => 'Databas-URL';

  @override
  String get providerOptionalHint => 'Valfritt';

  @override
  String get providerWebApiKeyLabel => 'Webb-API-nyckel';

  @override
  String get providerOptionalForPublicDb => 'Valfritt för offentlig databas';

  @override
  String get providerRelayUrlLabel => 'Relä-URL';

  @override
  String get providerPrivateKeyLabel => 'Privat Nyckel';

  @override
  String get providerPrivateKeyNsecLabel => 'Privat Nyckel (nsec)';

  @override
  String get providerStorageNodeLabel => 'Lagringsnod-URL (valfritt)';

  @override
  String get providerStorageNodeHint => 'Lämna tomt för inbyggda seed-noder';

  @override
  String get transferInvalidCodeFormat =>
      'Okänt kodformat — måste börja med LAN: eller NOS:';

  @override
  String get profileCardFingerprintCopied => 'Fingeravtryck kopierat';

  @override
  String get profileCardAboutHint => 'Integritet först 🔒';

  @override
  String get profileCardSaveButton => 'Spara Profil';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Exportera krypterade meddelanden, kontakter och avatarer till en fil';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Ljud';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Levererat till $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Levererat till $count';
  }

  @override
  String get groupStatusDialogTitle => 'Meddelandeinfo';

  @override
  String get groupStatusRead => 'Läst';

  @override
  String get groupStatusDelivered => 'Levererat';

  @override
  String get groupStatusPending => 'Väntande';

  @override
  String get groupStatusNoData => 'Ingen leveransinformation ännu';

  @override
  String get profileTransferAdmin => 'Gör till Admin';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Göra $name till ny admin?';
  }

  @override
  String get profileTransferAdminBody =>
      'Du förlorar dina administratörsrättigheter. Detta kan inte ångras.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name är nu admin';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Integritetspolicy';

  @override
  String get privacyOverviewHeading => 'Översikt';

  @override
  String get privacyOverviewBody =>
      'Pulse är en serverlös, end-to-end-krypterad meddelandeapp. Din integritet är inte bara en funktion — det är arkitekturen. Det finns inga Pulse-servrar. Inga konton lagras någonstans. Inga data samlas in, överförs till eller lagras av utvecklarna.';

  @override
  String get privacyDataCollectionHeading => 'Datainsamling';

  @override
  String get privacyDataCollectionBody =>
      'Pulse samlar in noll personuppgifter. Specifikt:\n\n- Ingen e-post, telefonnummer eller riktigt namn krävs\n- Ingen analys, spårning eller telemetri\n- Inga reklamidentifierare\n- Ingen åtkomst till kontaktlista\n- Inga molnsäkerhetskopior (meddelanden finns bara på din enhet)\n- Inga metadata skickas till någon Pulse-server (det finns inga)';

  @override
  String get privacyEncryptionHeading => 'Kryptering';

  @override
  String get privacyEncryptionBody =>
      'Alla meddelanden krypteras med Signal Protocol (Double Ratchet med X3DH nyckelöverenskommelse). Krypteringsnycklar genereras och lagras uteslutande på din enhet. Ingen — inklusive utvecklarna — kan läsa dina meddelanden.';

  @override
  String get privacyNetworkHeading => 'Nätverksarkitektur';

  @override
  String get privacyNetworkBody =>
      'Pulse använder federerade transportadaptrar (Nostr reläer, Session/Oxen tjänstnoder, Firebase Realtime Database, LAN). Dessa transporter bär bara krypterad chiffertext. Reläoperatörer kan se din IP-adress och trafikvolym, men kan inte dekryptera meddelandeinnehåll.\n\nNär Tor är aktiverat döljs din IP-adress också för reläoperatörer.';

  @override
  String get privacyStunHeading => 'STUN/TURN-servrar';

  @override
  String get privacyStunBody =>
      'Röst- och videosamtal använder WebRTC med DTLS-SRTP-kryptering. STUN-servrar (används för att upptäcka din publika IP för peer-to-peer-anslutningar) och TURN-servrar (används för att vidarebefordra media när direktanslutning misslyckas) kan se din IP-adress och samtalslängd, men kan inte dekryptera samtalsinnehåll.\n\nDu kan konfigurera din egen TURN-server i Inställningar för maximal integritet.';

  @override
  String get privacyCrashHeading => 'Kraschrapportering';

  @override
  String get privacyCrashBody =>
      'Om Sentry-kraschrapportering är aktiverad (via byggtids-SENTRY_DSN) kan anonyma kraschrapporter skickas. Dessa innehåller inget meddelandeinnehåll, ingen kontaktinformation och ingen personligt identifierbar information. Kraschrapportering kan inaktiveras vid byggtid genom att utelämna DSN.';

  @override
  String get privacyPasswordHeading => 'Lösenord & Nycklar';

  @override
  String get privacyPasswordBody =>
      'Ditt återställningslösenord används för att härleda kryptografiska nycklar via Argon2id (minneshard KDF). Lösenordet överförs aldrig någonstans. Om du förlorar ditt lösenord kan ditt konto inte återställas — det finns ingen server att återställa det på.';

  @override
  String get privacyFontsHeading => 'Typsnitt';

  @override
  String get privacyFontsBody =>
      'Pulse paketerar alla typsnitt lokalt. Inga förfrågningar görs till Google Fonts eller någon extern typsnittjänst.';

  @override
  String get privacyThirdPartyHeading => 'Tredjepartstjänster';

  @override
  String get privacyThirdPartyBody =>
      'Pulse integrerar inte med några reklamnätverk, analysleverantörer, sociala medieplattformar eller datamäklare. De enda nätverksanslutningarna är till de transportreläer du konfigurerar.';

  @override
  String get privacyOpenSourceHeading => 'Öppen Källkod';

  @override
  String get privacyOpenSourceBody =>
      'Pulse är öppen källkod. Du kan granska den fullständiga källkoden för att verifiera dessa integritetspåståenden.';

  @override
  String get privacyContactHeading => 'Kontakt';

  @override
  String get privacyContactBody =>
      'För integritetsrelaterade frågor, öppna ett ärende i projektförrådet.';

  @override
  String get privacyLastUpdated => 'Senast uppdaterad: mars 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Kunde inte spara: $error';
  }

  @override
  String get themeEngineTitle => 'Temamotor';

  @override
  String get torBuiltInTitle => 'Inbyggd Tor';

  @override
  String get torConnectedSubtitle =>
      'Ansluten — Nostr routas via 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Ansluter… $pct%';
  }

  @override
  String get torNotRunning =>
      'Inte igång — tryck på reglaget för att starta om';

  @override
  String get torDescription =>
      'Routar Nostr via Tor (Snowflake för censurerade nätverk)';

  @override
  String get torNetworkDiagnostics => 'Nätverksdiagnostik';

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
  String get torPtPlain => 'Enkel';

  @override
  String get torTimeoutLabel => 'Tidsgräns: ';

  @override
  String get torInfoDescription =>
      'När aktiverat routas Nostr WebSocket-anslutningar genom Tor (SOCKS5). Tor Browser lyssnar på 127.0.0.1:9150. Den fristående tor-demonen använder port 9050. Firebase-anslutningar påverkas inte.';

  @override
  String get torRouteNostrTitle => 'Routa Nostr via Tor';

  @override
  String get torManagedByBuiltin => 'Hanteras av Inbyggd Tor';

  @override
  String get torActiveRouting => 'Aktiv — Nostr-trafik routas genom Tor';

  @override
  String get torDisabled => 'Inaktiverad';

  @override
  String get torProxySocks5 => 'Tor-proxy (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Proxyvärd';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser: port 9150  •  tor-demon: port 9050';

  @override
  String get torForceNostrTitle => 'Dirigera meddelanden via Tor';

  @override
  String get torForceNostrSubtitle =>
      'Alla Nostr relay-anslutningar går genom Tor. Långsammare men döljer din IP från relay-servrar.';

  @override
  String get torForceNostrDisabled => 'Tor måste aktiveras först';

  @override
  String get torForcePulseTitle => 'Dirigera Pulse relay via Tor';

  @override
  String get torForcePulseSubtitle =>
      'Alla Pulse relay-anslutningar går genom Tor. Långsammare men döljer din IP från servern.';

  @override
  String get torForcePulseDisabled => 'Tor måste aktiveras först';

  @override
  String get i2pProxySocks5 => 'I2P-proxy (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P använder SOCKS5 på port 4447 som standard. Anslut till ett Nostr relä via I2P outproxy (t.ex. relay.damus.i2p) för att kommunicera med användare på valfritt transport. Tor har prioritet när båda är aktiverade.';

  @override
  String get i2pRouteNostrTitle => 'Routa Nostr via I2P';

  @override
  String get i2pActiveRouting => 'Aktiv — Nostr-trafik routas genom I2P';

  @override
  String get i2pDisabled => 'Inaktiverad';

  @override
  String get i2pProxyHostLabel => 'Proxyvärd';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'I2P Router standard SOCKS5-port: 4447';

  @override
  String get customProxySocks5 => 'Anpassad Proxy (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Anpassad proxy routar trafik via din V2Ray/Xray/Shadowsocks. CF Worker fungerar som en personlig reläproxy på Cloudflare CDN — GFW ser *.workers.dev, inte det riktiga relät.';

  @override
  String get customSocks5ProxyTitle => 'Anpassad SOCKS5-proxy';

  @override
  String get customProxyActive => 'Aktiv — trafik routas via SOCKS5';

  @override
  String get customProxyDisabled => 'Inaktiverad';

  @override
  String get customProxyHostLabel => 'Proxyvärd';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Workerdomän (valfritt)';

  @override
  String get customWorkerHelpTitle =>
      'Så här driftar du ett CF Worker relay (gratis)';

  @override
  String get customWorkerScriptCopied => 'Skript kopierat!';

  @override
  String get customWorkerStep1 =>
      '1. Gå till dash.cloudflare.com → Workers & Pages\n2. Create Worker → klistra in detta skript:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → kopiera domän (t.ex. my-relay.user.workers.dev)\n4. Klistra in domänen ovan → Spara\n\nAppen ansluter automatiskt: wss://domain/?r=relay_url\nGFW ser: anslutning till *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Ansluten — SOCKS5 på 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Ansluter…';

  @override
  String get psiphonNotRunning =>
      'Inte igång — tryck på reglaget för att starta om';

  @override
  String get psiphonDescription =>
      'Snabb tunnel (~3s bootstrap, 2000+ roterande VPS)';

  @override
  String get turnCommunityServers => 'Community TURN-servrar';

  @override
  String get turnCustomServer => 'Anpassad TURN-server (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN-servrar vidarebefordrar bara redan krypterade strömmar (DTLS-SRTP). En reläoperatör ser din IP och trafikvolym, men kan inte dekryptera samtal. TURN används bara när direkt P2P misslyckas (~15–20% av anslutningar).';

  @override
  String get turnFreeLabel => 'GRATIS';

  @override
  String get turnServerUrlLabel => 'TURN-server-URL';

  @override
  String get turnServerUrlHint => 'turn:din-server.com:3478 eller turns:...';

  @override
  String get turnUsernameLabel => 'Användarnamn';

  @override
  String get turnPasswordLabel => 'Lösenord';

  @override
  String get turnOptionalHint => 'Valfritt';

  @override
  String get turnCustomInfo =>
      'Hosta coturn själv på valfri \$5/mån VPS för maximal kontroll. Inloggningsuppgifter lagras lokalt.';

  @override
  String get themePickerAppearance => 'Utseende';

  @override
  String get themePickerAccentColor => 'Accentfärg';

  @override
  String get themeModeLight => 'Ljust';

  @override
  String get themeModeDark => 'Mörkt';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeDynamicPresets => 'Förinställningar';

  @override
  String get themeDynamicPrimaryColor => 'Primärfärg';

  @override
  String get themeDynamicBorderRadius => 'Kantradie';

  @override
  String get themeDynamicFont => 'Typsnitt';

  @override
  String get themeDynamicAppearance => 'Utseende';

  @override
  String get themeDynamicUiStyle => 'UI-stil';

  @override
  String get themeDynamicUiStyleDescription =>
      'Styr hur dialoger, reglage och indikatorer ser ut.';

  @override
  String get themeDynamicSharp => 'Skarpt';

  @override
  String get themeDynamicRound => 'Runt';

  @override
  String get themeDynamicModeDark => 'Mörkt';

  @override
  String get themeDynamicModeLight => 'Ljust';

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
      'Ogiltig Firebase-URL. Förväntad: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Ogiltig relä-URL. Förväntad: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Ogiltig Pulse-server-URL. Förväntad: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'Server-URL';

  @override
  String get providerPulseServerUrlHint => 'https://din-server:8443';

  @override
  String get providerPulseInviteLabel => 'Inbjudningskod';

  @override
  String get providerPulseInviteHint => 'Inbjudningskod (om det krävs)';

  @override
  String get providerPulseInfo =>
      'Självhostat relä. Nycklar härledda från ditt återställningslösenord.';

  @override
  String get providerScreenTitle => 'Inkorgar';

  @override
  String get providerSecondaryInboxesHeader => 'SEKUNDÄRA INKORGAR';

  @override
  String get providerSecondaryInboxesInfo =>
      'Sekundära inkorgar tar emot meddelanden samtidigt för redundans.';

  @override
  String get providerRemoveTooltip => 'Ta bort';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... eller hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... eller hex privat nyckel';

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
  String get emojiNoRecent => 'Inga senaste emojis';

  @override
  String get emojiSearchHint => 'Sök emoji...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Tryck för att chatta';

  @override
  String get imageViewerSaveToDownloads => 'Spara till Nedladdningar';

  @override
  String imageViewerSavedTo(String path) {
    return 'Sparad till $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Språk';

  @override
  String get settingsLanguageSubtitle => 'Appens visningsspråk';

  @override
  String get settingsLanguageSystem => 'Systemstandard';

  @override
  String get onboardingLanguageTitle => 'Välj ditt språk';

  @override
  String get onboardingLanguageSubtitle =>
      'Du kan ändra detta senare i Inställningar';

  @override
  String get videoNoteRecord => 'Spela in videomeddelande';

  @override
  String get videoNoteTapToRecord => 'Tryck för att spela in';

  @override
  String get videoNoteTapToStop => 'Tryck för att stoppa';

  @override
  String get videoNoteCameraPermission => 'Kameraåtkomst nekad';

  @override
  String get videoNoteMaxDuration => 'Maximalt 30 sekunder';

  @override
  String get videoNoteNotSupported =>
      'Videoanteckningar stöds inte på den här plattformen';

  @override
  String get navChats => 'Chattar';

  @override
  String get navUpdates => 'Uppdateringar';

  @override
  String get navCalls => 'Samtal';

  @override
  String get filterAll => 'Alla';

  @override
  String get filterUnread => 'Oläst';

  @override
  String get filterGroups => 'Grupper';

  @override
  String get callsNoRecent => 'Inga senaste samtal';

  @override
  String get callsEmptySubtitle => 'Din samtalshistorik visas här';

  @override
  String get appBarEncrypted => 'ände-till-ände krypterat';

  @override
  String get newStatus => 'Ny status';

  @override
  String get newCall => 'Nytt samtal';

  @override
  String get joinChannelTitle => 'Gå med i kanal';

  @override
  String get joinChannelDescription => 'KANAL-URL';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'Hämtar kanalinformation…';

  @override
  String get joinChannelNotFound => 'Ingen kanal hittades på denna URL';

  @override
  String get joinChannelNetworkError => 'Kunde inte nå servern';

  @override
  String get joinChannelAlreadyJoined => 'Redan med';

  @override
  String get joinChannelButton => 'Gå med';

  @override
  String get channelFeedEmpty => 'Inga inlägg ännu';

  @override
  String get channelLeave => 'Lämna kanal';

  @override
  String get channelLeaveConfirm =>
      'Lämna denna kanal? Cachade inlägg kommer att raderas.';

  @override
  String get channelInfo => 'Kanalinfo';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'redigerat';

  @override
  String get channelLoadMore => 'Ladda fler';

  @override
  String get channelSearchPosts => 'Sök inlägg…';

  @override
  String get channelNoResults => 'Inga matchande inlägg';

  @override
  String get channelUrl => 'Kanal-URL';

  @override
  String get channelCreated => 'Gick med';

  @override
  String channelPostCount(int count) {
    return '$count inlägg';
  }

  @override
  String get channelCopyUrl => 'Kopiera URL';

  @override
  String get setupNext => 'Nästa';

  @override
  String get setupKeyWarning =>
      'A recovery key will be generated for you. It is the only way to restore your account on a new device — there is no server, no password reset.';

  @override
  String get setupKeyTitle => 'Your Recovery Key';

  @override
  String get setupKeySubtitle =>
      'Write this key down and store it in a safe place. You will need it to restore your account on a new device.';

  @override
  String get setupKeyCopied => 'Kopierat!';

  @override
  String get setupKeyWroteItDown => 'Jag har skrivit ner den';

  @override
  String get setupKeyWarnBody =>
      'Write this key down as a backup. You can also view it later in Settings → Security.';

  @override
  String get setupVerifyTitle => 'Verify Recovery Key';

  @override
  String get setupVerifySubtitle =>
      'Re-enter your recovery key to confirm you saved it correctly.';

  @override
  String get setupVerifyButton => 'Verifiera';

  @override
  String get setupKeyMismatch => 'Key does not match. Check and try again.';

  @override
  String get setupSkipVerify => 'Skip verification';

  @override
  String get setupSkipVerifyTitle => 'Skip verification?';

  @override
  String get setupSkipVerifyBody =>
      'If you lose your recovery key, your account cannot be restored. Are you sure you want to skip?';

  @override
  String get setupCreatingAccount => 'Creating account…';

  @override
  String get setupRestoringAccount => 'Restoring account…';

  @override
  String get restoreKeyInfoBanner =>
      'Enter your recovery key — your address (Nostr + Session) will be restored automatically. Contacts and messages were stored locally only.';

  @override
  String get restoreKeyHint => 'Recovery key';

  @override
  String get settingsViewRecoveryKey => 'Visa återställningsnyckel';

  @override
  String get settingsViewRecoveryKeySubtitle =>
      'Visa din kontos återställningsnyckel';

  @override
  String get settingsRecoveryKeyNotStored =>
      'Återställningsnyckel inte tillgänglig (skapad innan denna funktion)';

  @override
  String get settingsRecoveryKeyWarning =>
      'Förvara denna nyckel säkert. Vem som helst som har den kan återställa ditt konto på en annan enhet.';

  @override
  String get replaceIdentityTitle => 'Ersätt befintlig identitet?';

  @override
  String get replaceIdentityBodyRestore =>
      'En identitet finns redan på den här enheten. Återställning kommer permanent ersätta din nuvarande Nostr-nyckel och Oxen-seed. Alla kontakter förlorar möjligheten att nå din nuvarande adress.\n\nDetta kan inte ångras.';

  @override
  String get replaceIdentityBodyCreate =>
      'En identitet finns redan på den här enheten. Att skapa en ny kommer permanent ersätta din nuvarande Nostr-nyckel och Oxen-seed. Alla kontakter förlorar möjligheten att nå din nuvarande adress.\n\nDetta kan inte ångras.';

  @override
  String get replace => 'Ersätt';

  @override
  String get callNoScreenSources => 'Inga skärmkällor tillgängliga';

  @override
  String get callScreenShareQuality => 'Kvalitet för skärmdelning';

  @override
  String get callFrameRate => 'Bildfrekvens';

  @override
  String get callResolution => 'Upplösning';

  @override
  String get callAutoResolution => 'Auto = skärmens ursprungliga upplösning';

  @override
  String get callStartSharing => 'Börja dela';

  @override
  String get callCameraUnavailable =>
      'Kamera otillgänglig — kan vara i bruk av en annan app';

  @override
  String get themeResetToDefaults => 'Återställ till standard';

  @override
  String get backupSaveToDownloadsTitle =>
      'Spara säkerhetskopia till Nedladdningar?';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'Ingen filväljare tillgänglig. Säkerhetskopian sparas till:\n$path';
  }

  @override
  String get systemLabel => 'System';

  @override
  String get next => 'Nästa';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return '$remaining tryck till för att aktivera utvecklarläge';
  }

  @override
  String get devModeEnabled => 'Utvecklarläge aktiverat';

  @override
  String get devTools => 'Utvecklarverktyg';

  @override
  String get devAdapterDiagnostics => 'Adapterväxlar och diagnostik';

  @override
  String get devEnableAll => 'Aktivera alla';

  @override
  String get devDisableAll => 'Inaktivera alla';

  @override
  String get turnUrlValidation =>
      'TURN URL måste börja med turn: eller turns: (max 512 tecken)';

  @override
  String get callMissedCall => 'Missat samtal';

  @override
  String get callOutgoingCall => 'Utgående samtal';

  @override
  String get callIncomingCall => 'Inkommande samtal';

  @override
  String get mediaMissingData => 'Mediadata saknas';

  @override
  String get mediaDownloadFailed => 'Nedladdning misslyckades';

  @override
  String get mediaDecryptFailed => 'Dekryptering misslyckades';

  @override
  String get callEndCallBanner => 'Avsluta samtal';

  @override
  String get meFallback => 'Jag';

  @override
  String get imageSaveToDownloads => 'Spara till Nedladdningar';

  @override
  String imageSavedToPath(String path) {
    return 'Sparad till $path';
  }

  @override
  String get callScreenShareRequiresPermission =>
      'Skärmdelning kräver behörighet';

  @override
  String get callScreenShareUnavailable => 'Skärmdelning otillgänglig';

  @override
  String get statusJustNow => 'Just nu';

  @override
  String statusMinutesAgo(int minutes) {
    return '${minutes}m sedan';
  }

  @override
  String statusHoursAgo(int hours) {
    return '${hours}t sedan';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rutter',
      one: '1 rutt',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => 'Redo att lägga till';

  @override
  String groupSelectedCount(int count) {
    return '$count valda';
  }

  @override
  String get paste => 'Klistra in';

  @override
  String get sfuAudioOnly => 'Endast ljud';

  @override
  String sfuParticipants(int count) {
    return '$count deltagare';
  }

  @override
  String get dataUnencryptedBackup => 'Okrypterad säkerhetskopia';

  @override
  String get dataUnencryptedBackupBody =>
      'Den här filen är en okrypterad identitetssäkerhetskopia och kommer att skriva över dina nuvarande nycklar. Importera bara filer du skapat själv. Fortsätta?';

  @override
  String get dataImportAnyway => 'Importera ändå';

  @override
  String get securityStorageError => 'Säkerhetslagringsfel — starta om appen';

  @override
  String get aboutDevModeActive => 'Utvecklarläge aktivt';

  @override
  String get themeColors => 'Färger';

  @override
  String get themePrimaryAccent => 'Primär accent';

  @override
  String get themeSecondaryAccent => 'Sekundär accent';

  @override
  String get themeBackground => 'Bakgrund';

  @override
  String get themeSurface => 'Yta';

  @override
  String get themeChatBubbles => 'Chattbubblor';

  @override
  String get themeOutgoingMessage => 'Utgående meddelande';

  @override
  String get themeIncomingMessage => 'Inkommande meddelande';

  @override
  String get themeShape => 'Form';

  @override
  String get devSectionDeveloper => 'Utvecklare';

  @override
  String get devAdapterChannelsHint =>
      'Adapterkanaler — inaktivera för att testa specifika transporter.';

  @override
  String get devNostrRelays => 'Nostr-reläer (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Session-nätverk';

  @override
  String get devPulseRelay => 'Pulse egenhostad relay';

  @override
  String get devLanNetwork => 'Lokalt nätverk (UDP/TCP)';

  @override
  String get devSectionCalls => 'Samtal';

  @override
  String get devForceTurnRelay => 'Tvinga TURN-relay';

  @override
  String get devForceTurnRelaySubtitle =>
      'Inaktivera P2P — alla samtal via TURN-servrar enbart';

  @override
  String get devRestartWarning =>
      '⚠ Ändringar träder i kraft vid nästa sändning/samtal. Starta om appen för inkommande.';

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
  String get pulseUseServerTitle => 'Använda Pulse-server?';

  @override
  String pulseUseServerBody(String name, String host) {
    return '$name använder Pulse-servern $host. Gå med för att chatta snabbare (och med andra på samma server)?';
  }

  @override
  String pulseContactUsesPulse(String name) {
    return '$name använder Pulse';
  }

  @override
  String pulseJoinForFaster(String host) {
    return 'Gå med i $host för snabbare chatt';
  }

  @override
  String get pulseNotNow => 'Inte nu';

  @override
  String get pulseJoin => 'Gå med';

  @override
  String get pulseDismiss => 'Stäng';

  @override
  String get pulseHide7Days => 'Dölj i 7 dagar';

  @override
  String get pulseNeverAskAgain => 'Fråga inte igen';

  @override
  String get groupSearchContactsHint => 'Sök kontakter…';

  @override
  String get systemActorYou => 'Du';

  @override
  String get systemActorPeer => 'Kontakt';

  @override
  String systemTtlEnabled(String actor, String duration) {
    return '$actor aktiverade försvinnande meddelanden: $duration';
  }

  @override
  String systemTtlDisabled(String actor) {
    return '$actor avaktiverade försvinnande meddelanden';
  }

  @override
  String get menuClearChatHistory => 'Rensa chatthistorik';

  @override
  String get clearChatTitle => 'Rensa chatthistoriken?';

  @override
  String get clearChatBody =>
      'Alla meddelanden i denna chatt raderas från den här enheten. Den andra personen behåller sin kopia.';

  @override
  String get clearChatAction => 'Rensa';

  @override
  String systemGroupRenamed(String actor, String name) {
    return '$actor bytte namn på gruppen till \"$name\"';
  }

  @override
  String systemGroupAvatarChanged(String actor) {
    return '$actor ändrade gruppfotot';
  }

  @override
  String systemGroupMetaChanged(String actor, String name) {
    return '$actor bytte namn på gruppen till \"$name\" och ändrade fotot';
  }

  @override
  String get profileInviteLink => 'Inbjudningslänk';

  @override
  String get profileInviteLinkSubtitle => 'Alla med länken kan gå med';

  @override
  String get profileInviteLinkCopied => 'Inbjudningslänk kopierad';

  @override
  String get groupInviteLinkTitle => 'Gå med i gruppen?';

  @override
  String groupInviteLinkBody(String name, int count) {
    return 'Du har bjudits in till \"$name\" ($count medlemmar).';
  }

  @override
  String get groupInviteLinkJoin => 'Gå med';

  @override
  String get drawerCreateGroup => 'Skapa grupp';

  @override
  String get drawerJoinGroup => 'Gå med i grupp';

  @override
  String get drawerJoinGroupByLinkInvalid =>
      'Det ser inte ut som en Pulse-inbjudningslänk';

  @override
  String get groupModeMeshTitle => 'Vanlig';

  @override
  String groupModeMeshSubtitle(int n) {
    return 'Ingen server, upp till $n personer';
  }

  @override
  String get groupModeSfuTitle => 'Med Pulse-server';

  @override
  String groupModeSfuSubtitle(int n) {
    return 'Via server, upp till $n personer';
  }

  @override
  String get groupPulseServerHint => 'https://din-pulse-server';

  @override
  String get groupPulseServerClosed => 'Stängd server (kräver inbjudningskod)';

  @override
  String get groupPulseInviteHint => 'Inbjudningskod';

  @override
  String groupMeshLimitReached(int n) {
    return 'Denna samtalstyp är begränsad till $n personer';
  }
}
