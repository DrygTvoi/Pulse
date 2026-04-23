// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Søg i beskeder...';

  @override
  String get search => 'Søg';

  @override
  String get clearSearch => 'Ryd søgning';

  @override
  String get closeSearch => 'Luk søgning';

  @override
  String get moreOptions => 'Flere muligheder';

  @override
  String get back => 'Tilbage';

  @override
  String get cancel => 'Annuller';

  @override
  String get close => 'Luk';

  @override
  String get confirm => 'Bekræft';

  @override
  String get remove => 'Fjern';

  @override
  String get save => 'Gem';

  @override
  String get add => 'Tilføj';

  @override
  String get copy => 'Kopiér';

  @override
  String get skip => 'Spring over';

  @override
  String get done => 'Færdig';

  @override
  String get apply => 'Anvend';

  @override
  String get export => 'Eksportér';

  @override
  String get import => 'Importér';

  @override
  String get homeNewGroup => 'Ny gruppe';

  @override
  String get homeSettings => 'Indstillinger';

  @override
  String get homeSearching => 'Søger i beskeder...';

  @override
  String get homeNoResults => 'Ingen resultater fundet';

  @override
  String get homeNoChatHistory => 'Ingen chathistorik endnu';

  @override
  String homeTransportSwitched(String address) {
    return 'Transport skiftet → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name ringer...';
  }

  @override
  String get homeAccept => 'Accepter';

  @override
  String get homeDecline => 'Afvis';

  @override
  String get homeLoadEarlier => 'Indlæs ældre beskeder';

  @override
  String get homeChats => 'Samtaler';

  @override
  String get homeSelectConversation => 'Vælg en samtale';

  @override
  String get homeNoChatsYet => 'Ingen samtaler endnu';

  @override
  String get homeAddContactToStart =>
      'Tilføj en kontakt for at begynde at chatte';

  @override
  String get homeNewChat => 'Ny samtale';

  @override
  String get homeNewChatTooltip => 'Ny samtale';

  @override
  String get homeIncomingCallTitle => 'Indgående opkald';

  @override
  String get homeIncomingGroupCallTitle => 'Indgående gruppeopkald';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — indgående gruppeopkald';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Ingen samtaler matcher \"$query\"';
  }

  @override
  String get homeSectionChats => 'Samtaler';

  @override
  String get homeSectionMessages => 'Beskeder';

  @override
  String get homeDbEncryptionUnavailable =>
      'Databasekryptering utilgængelig — installér SQLCipher for fuld beskyttelse';

  @override
  String get chatFileTooLargeGroup =>
      'Filer over 512 KB understøttes ikke i gruppesamtaler';

  @override
  String get chatLargeFile => 'Stor fil';

  @override
  String get chatCancel => 'Annuller';

  @override
  String get chatSend => 'Send';

  @override
  String get chatFileTooLarge =>
      'Filen er for stor — maksimal størrelse er 100 MB';

  @override
  String get chatMicDenied => 'Mikrofontilladelse nægtet';

  @override
  String get chatVoiceFailed =>
      'Kunne ikke gemme talebeskeden — tjek tilgængelig lagerplads';

  @override
  String get chatScheduleFuture => 'Planlagt tidspunkt skal være i fremtiden';

  @override
  String get chatToday => 'I dag';

  @override
  String get chatYesterday => 'I går';

  @override
  String get chatEdited => 'redigeret';

  @override
  String get chatYou => 'Dig';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Denne fil er $size MB. Afsendelse af store filer kan være langsomt på nogle netværk. Fortsæt?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Sikkerhedsnøglen for $name er ændret. Tryk for at verificere.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Kunne ikke kryptere besked til $name — beskeden blev ikke sendt.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Sikkerhedsnummeret for $name er ændret. Tryk for at verificere.';
  }

  @override
  String get chatNoMessagesFound => 'Ingen beskeder fundet';

  @override
  String get chatMessagesE2ee => 'Beskeder er ende-til-ende-krypterede';

  @override
  String get chatSayHello => 'Sig hej';

  @override
  String get appBarOnline => 'online';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'skriver';

  @override
  String get appBarSearchMessages => 'Søg i beskeder...';

  @override
  String get appBarMute => 'Slå lyd fra';

  @override
  String get appBarUnmute => 'Slå lyd til';

  @override
  String get appBarMedia => 'Medier';

  @override
  String get appBarDisappearing => 'Forsvindende beskeder';

  @override
  String get appBarDisappearingOn => 'Forsvindende: til';

  @override
  String get appBarGroupSettings => 'Gruppeindstillinger';

  @override
  String get appBarSearchTooltip => 'Søg i beskeder';

  @override
  String get appBarVoiceCall => 'Taleopkald';

  @override
  String get appBarVideoCall => 'Videoopkald';

  @override
  String get inputMessage => 'Besked...';

  @override
  String get inputAttachFile => 'Vedhæft fil';

  @override
  String get inputSendMessage => 'Send besked';

  @override
  String get inputRecordVoice => 'Optag talebesked';

  @override
  String get inputSendVoice => 'Send talebesked';

  @override
  String get inputCancelReply => 'Annuller svar';

  @override
  String get inputCancelEdit => 'Annuller redigering';

  @override
  String get inputCancelRecording => 'Annuller optagelse';

  @override
  String get inputRecording => 'Optager…';

  @override
  String get inputEditingMessage => 'Redigerer besked';

  @override
  String get inputPhoto => 'Foto';

  @override
  String get inputVoiceMessage => 'Talebesked';

  @override
  String get inputFile => 'Fil';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'er',
      one: '',
    );
    return '$count planlagt besked$_temp0';
  }

  @override
  String get callInitializing => 'Starter opkald…';

  @override
  String get callConnecting => 'Forbinder…';

  @override
  String get callConnectingRelay => 'Forbinder (relay)…';

  @override
  String get callSwitchingRelay => 'Skifter til relay-tilstand…';

  @override
  String get callConnectionFailed => 'Forbindelse mislykkedes';

  @override
  String get callReconnecting => 'Genopretter forbindelse…';

  @override
  String get callEnded => 'Opkald afsluttet';

  @override
  String get callLive => 'Live';

  @override
  String get callEnd => 'Afslut';

  @override
  String get callEndCall => 'Læg på';

  @override
  String get callMute => 'Slå lyd fra';

  @override
  String get callUnmute => 'Slå lyd til';

  @override
  String get callSpeaker => 'Højttaler';

  @override
  String get callCameraOn => 'Kamera til';

  @override
  String get callCameraOff => 'Kamera fra';

  @override
  String get callShareScreen => 'Del skærm';

  @override
  String get callStopShare => 'Stop deling';

  @override
  String callTorBackup(String duration) {
    return 'Tor-backup · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor-backup aktiv — primær forbindelse utilgængelig';

  @override
  String get callDirectFailed =>
      'Direkte forbindelse mislykkedes — skifter til relay-tilstand…';

  @override
  String get callTurnUnreachable =>
      'TURN-servere utilgængelige. Tilføj en egen TURN-server i Indstillinger → Avanceret.';

  @override
  String get callRelayMode => 'Relay-tilstand aktiv (begrænset netværk)';

  @override
  String get callStarting => 'Starter opkald…';

  @override
  String get callConnectingToGroup => 'Forbinder til gruppen…';

  @override
  String get callGroupOpenedInBrowser => 'Gruppeopkald åbnet i browser';

  @override
  String get callCouldNotOpenBrowser => 'Kunne ikke åbne browser';

  @override
  String get callInviteLinkSent =>
      'Invitationslink sendt til alle gruppemedlemmer.';

  @override
  String get callOpenLinkManually =>
      'Åbn linket ovenfor manuelt, eller tryk for at prøve igen.';

  @override
  String get callJitsiNotE2ee =>
      'Jitsi-opkald er IKKE ende-til-ende-krypterede';

  @override
  String get callRetryOpenBrowser => 'Prøv at åbne browser igen';

  @override
  String get callClose => 'Luk';

  @override
  String get callCamOn => 'Kamera til';

  @override
  String get callCamOff => 'Kamera fra';

  @override
  String get noConnection => 'Ingen forbindelse — beskeder sættes i kø';

  @override
  String get connected => 'Forbundet';

  @override
  String get connecting => 'Forbinder…';

  @override
  String get disconnected => 'Afbrudt';

  @override
  String get offlineBanner =>
      'Ingen forbindelse — beskeder sendes, når du er online igen';

  @override
  String get lanModeBanner =>
      'LAN-tilstand — Intet internet · Kun lokalt netværk';

  @override
  String get probeCheckingNetwork => 'Tjekker netværksforbindelse…';

  @override
  String get probeDiscoveringRelays => 'Opdager relays via fælleskataloger…';

  @override
  String get probeStartingTor => 'Starter Tor til bootstrap…';

  @override
  String get probeFindingRelaysTor => 'Finder tilgængelige relays via Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'Netværk klar — $count relay$_temp0 fundet';
  }

  @override
  String get probeNoRelaysFound =>
      'Ingen tilgængelige relays fundet — beskeder kan blive forsinket';

  @override
  String get jitsiWarningTitle => 'Ikke ende-til-ende-krypteret';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet-opkald er ikke krypteret af Pulse. Brug kun til ikke-følsomme samtaler.';

  @override
  String get jitsiConfirm => 'Deltag alligevel';

  @override
  String get jitsiGroupWarningTitle => 'Ikke ende-til-ende-krypteret';

  @override
  String get jitsiGroupWarningBody =>
      'Dette opkald har for mange deltagere til det indbyggede krypterede mesh.\n\nEt Jitsi Meet-link åbnes i din browser. Jitsi er IKKE ende-til-ende-krypteret — serveren kan se dit opkald.';

  @override
  String get jitsiContinueAnyway => 'Fortsæt alligevel';

  @override
  String get retry => 'Prøv igen';

  @override
  String get setupCreateAnonymousAccount => 'Opret en anonym konto';

  @override
  String get setupTapToChangeColor => 'Tryk for at ændre farve';

  @override
  String get setupReqMinLength => 'Mindst 16 tegn';

  @override
  String get setupReqVariety => '3 af 4: store, små bogstaver, cifre, symboler';

  @override
  String get setupReqMatch => 'Adgangskoderne stemmer overens';

  @override
  String get setupYourNickname => 'Dit kaldenavn';

  @override
  String get setupRecoveryPassword => 'Gendannelsesadgangskode (min. 16)';

  @override
  String get setupConfirmPassword => 'Bekræft adgangskode';

  @override
  String get setupMin16Chars => 'Minimum 16 tegn';

  @override
  String get setupPasswordsDoNotMatch => 'Adgangskoderne stemmer ikke overens';

  @override
  String get setupEntropyWeak => 'Svag';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Stærk';

  @override
  String get setupEntropyWeakNeedsVariety => 'Svag (kræver 3 tegntyper)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bits)';
  }

  @override
  String get setupPasswordWarning =>
      'Denne adgangskode er den eneste måde at gendanne din konto på. Der er ingen server — ingen nulstilling af adgangskode. Husk den eller skriv den ned.';

  @override
  String get setupCreateAccount => 'Opret konto';

  @override
  String get setupAlreadyHaveAccount => 'Har du allerede en konto? ';

  @override
  String get setupRestore => 'Gendan →';

  @override
  String get restoreTitle => 'Gendan konto';

  @override
  String get restoreInfoBanner =>
      'Indtast din gendannelsesadgangskode — din adresse (Nostr + Session) gendannes automatisk. Kontakter og beskeder var kun gemt lokalt.';

  @override
  String get restoreNewNickname => 'Nyt kaldenavn (kan ændres senere)';

  @override
  String get restoreButton => 'Gendan konto';

  @override
  String get lockTitle => 'Pulse er låst';

  @override
  String get lockSubtitle => 'Indtast din adgangskode for at fortsætte';

  @override
  String get lockPasswordHint => 'Adgangskode';

  @override
  String get lockUnlock => 'Lås op';

  @override
  String get lockPanicHint =>
      'Glemt din adgangskode? Indtast din paniknøgle for at slette alle data.';

  @override
  String get lockTooManyAttempts => 'For mange forsøg. Sletter alle data…';

  @override
  String get lockWrongPassword => 'Forkert adgangskode';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Forkert adgangskode — $attempts/$max forsøg';
  }

  @override
  String get onboardingSkip => 'Spring over';

  @override
  String get onboardingNext => 'Næste';

  @override
  String get onboardingGetStarted => 'Opret konto';

  @override
  String get onboardingWelcomeTitle => 'Velkommen til Pulse';

  @override
  String get onboardingWelcomeBody =>
      'En decentral, ende-til-ende-krypteret beskedtjeneste.\n\nIngen centrale servere. Ingen dataindsamling. Ingen bagdøre.\nDine samtaler tilhører kun dig.';

  @override
  String get onboardingTransportTitle => 'Transportagnostisk';

  @override
  String get onboardingTransportBody =>
      'Brug Firebase, Nostr eller begge på samme tid.\n\nBeskeder routes automatisk på tværs af netværk. Indbygget støtte for Tor og I2P til censurresistens.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Hver besked krypteres med Signal-protokollen (Double Ratchet + X3DH) for fremadrettet hemmelighed.\n\nDesuden indpakket med Kyber-1024 — en NIST-standardiseret post-kvantealgoritme — der beskytter mod fremtidige kvantecomputere.';

  @override
  String get onboardingKeysTitle => 'Du ejer dine nøgler';

  @override
  String get onboardingKeysBody =>
      'Dine identitetsnøgler forlader aldrig din enhed.\n\nSignal-fingeraftryk lader dig verificere kontakter ud-af-bånd. TOFU (Trust On First Use) registrerer nøgleændringer automatisk.';

  @override
  String get onboardingThemeTitle => 'Vælg dit udseende';

  @override
  String get onboardingThemeBody =>
      'Vælg et tema og en accentfarve. Du kan altid ændre dette senere i Indstillinger.';

  @override
  String get contactsNewChat => 'Ny samtale';

  @override
  String get contactsAddContact => 'Tilføj kontakt';

  @override
  String get contactsSearchHint => 'Søg...';

  @override
  String get contactsNewGroup => 'Ny gruppe';

  @override
  String get contactsNoContactsYet => 'Ingen kontakter endnu';

  @override
  String get contactsAddHint => 'Tryk + for at tilføje en adresse';

  @override
  String get contactsNoMatch => 'Ingen kontakter matcher';

  @override
  String get contactsRemoveTitle => 'Fjern kontakt';

  @override
  String contactsRemoveMessage(String name) {
    return 'Fjern $name?';
  }

  @override
  String get contactsRemove => 'Fjern';

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
  String get bubbleOpenLink => 'Åbn link';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Åbn denne URL i din browser?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Åbn';

  @override
  String get bubbleSecurityWarning => 'Sikkerhedsadvarsel';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" er en eksekverbar filtype. At gemme og køre den kan skade din enhed. Gem alligevel?';
  }

  @override
  String get bubbleSaveAnyway => 'Gem alligevel';

  @override
  String bubbleSavedTo(String path) {
    return 'Gemt i $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Gemning mislykkedes: $error';
  }

  @override
  String get bubbleNotEncrypted => 'IKKE KRYPTERET';

  @override
  String get bubbleCorruptedImage => '[Beskadiget billede]';

  @override
  String get bubbleReplyPhoto => 'Foto';

  @override
  String get bubbleReplyVoice => 'Talebesked';

  @override
  String get bubbleReplyVideo => 'Videobesked';

  @override
  String bubbleReadBy(String names) {
    return 'Læst af $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Læst af $count';
  }

  @override
  String get chatTileTapToStart => 'Tryk for at starte samtale';

  @override
  String get chatTileMessageSent => 'Besked sendt';

  @override
  String get chatTileEncryptedMessage => 'Krypteret besked';

  @override
  String chatTileYouPrefix(String text) {
    return 'Dig: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Talebesked';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Talebesked ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Krypteret besked';

  @override
  String get groupNewGroup => 'Ny gruppe';

  @override
  String get groupGroupName => 'Gruppenavn';

  @override
  String get groupSelectMembers => 'Vælg medlemmer (min. 2)';

  @override
  String get groupNoContactsYet =>
      'Ingen kontakter endnu. Tilføj kontakter først.';

  @override
  String get groupCreate => 'Opret';

  @override
  String get groupLabel => 'Gruppe';

  @override
  String get profileVerifyIdentity => 'Verificer identitet';

  @override
  String profileVerifyInstructions(String name) {
    return 'Sammenlign disse fingeraftryk med $name over et taleopkald eller personligt. Hvis begge værdier stemmer på begge enheder, tryk «Markering som verificeret».';
  }

  @override
  String get profileTheirKey => 'Deres nøgle';

  @override
  String get profileYourKey => 'Din nøgle';

  @override
  String get profileRemoveVerification => 'Fjern verificering';

  @override
  String get profileMarkAsVerified => 'Markér som verificeret';

  @override
  String get profileAddressCopied => 'Adresse kopieret';

  @override
  String get profileNoContactsToAdd =>
      'Ingen kontakter at tilføje — alle er allerede medlemmer';

  @override
  String get profileAddMembers => 'Tilføj medlemmer';

  @override
  String profileAddCount(int count) {
    return 'Tilføj ($count)';
  }

  @override
  String get profileRenameGroup => 'Omdøb gruppe';

  @override
  String get profileRename => 'Omdøb';

  @override
  String get profileRemoveMember => 'Fjern medlem?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Fjern $name fra denne gruppe?';
  }

  @override
  String get profileKick => 'Smid ud';

  @override
  String get profileSignalFingerprints => 'Signal-fingeraftryk';

  @override
  String get profileVerified => 'VERIFICERET';

  @override
  String get profileVerify => 'Verificer';

  @override
  String get profileEdit => 'Rediger';

  @override
  String get profileNoSession =>
      'Ingen session etableret endnu — send en besked først.';

  @override
  String get profileFingerprintCopied => 'Fingeraftryk kopieret';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mer',
      one: '',
    );
    return '$count medlem$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Verificer sikkerhedsnummer';

  @override
  String get profileShowContactQr => 'Vis kontakt-QR';

  @override
  String profileContactAddress(String name) {
    return '${name}s adresse';
  }

  @override
  String get profileExportChatHistory => 'Eksporter chathistorik';

  @override
  String profileSavedTo(String path) {
    return 'Gemt i $path';
  }

  @override
  String get profileExportFailed => 'Eksport mislykkedes';

  @override
  String get profileClearChatHistory => 'Ryd chathistorik';

  @override
  String get profileDeleteGroup => 'Slet gruppe';

  @override
  String get profileDeleteContact => 'Slet kontakt';

  @override
  String get profileLeaveGroup => 'Forlad gruppe';

  @override
  String get profileLeaveGroupBody =>
      'Du vil blive fjernet fra denne gruppe, og den slettes fra dine kontakter.';

  @override
  String get groupInviteTitle => 'Gruppeinvitation';

  @override
  String groupInviteBody(String from, String group) {
    return '$from har inviteret dig til at deltage i \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Accepter';

  @override
  String get groupInviteDecline => 'Afvis';

  @override
  String get groupMemberLimitTitle => 'For mange deltagere';

  @override
  String groupMemberLimitBody(int count) {
    return 'Denne gruppe vil have $count deltagere. Krypterede mesh-opkald understøtter op til 6. Større grupper falder tilbage til Jitsi (ikke E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Tilføj alligevel';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name afslog at deltage i \"$group\"';
  }

  @override
  String get transferTitle => 'Overfør til en anden enhed';

  @override
  String get transferInfoBox =>
      'Flyt din Signal-identitet og Nostr-nøgler til en ny enhed.\nChatsessioner overføres IKKE — fremadrettet hemmelighed bevares.';

  @override
  String get transferSendFromThis => 'Send fra denne enhed';

  @override
  String get transferSendSubtitle =>
      'Denne enhed har nøglerne. Del en kode med den nye enhed.';

  @override
  String get transferReceiveOnThis => 'Modtag på denne enhed';

  @override
  String get transferReceiveSubtitle =>
      'Dette er den nye enhed. Indtast koden fra den gamle enhed.';

  @override
  String get transferChooseMethod => 'Vælg overførselsmetode';

  @override
  String get transferLan => 'LAN (Samme netværk)';

  @override
  String get transferLanSubtitle =>
      'Hurtigt og direkte. Begge enheder skal være på samme Wi-Fi.';

  @override
  String get transferNostrRelay => 'Nostr-relay';

  @override
  String get transferNostrRelaySubtitle =>
      'Virker over ethvert netværk via et eksisterende Nostr-relay.';

  @override
  String get transferRelayUrl => 'Relay-URL';

  @override
  String get transferEnterCode => 'Indtast overførselskode';

  @override
  String get transferPasteCode => 'Indsæt LAN:... eller NOS:...-kode her';

  @override
  String get transferConnect => 'Forbind';

  @override
  String get transferGenerating => 'Genererer overførselskode…';

  @override
  String get transferShareCode => 'Del denne kode med modtageren:';

  @override
  String get transferCopyCode => 'Kopiér kode';

  @override
  String get transferCodeCopied => 'Kode kopieret til udklipsholderen';

  @override
  String get transferWaitingReceiver => 'Venter på at modtageren forbinder…';

  @override
  String get transferConnectingSender => 'Forbinder til afsenderen…';

  @override
  String get transferVerifyBoth =>
      'Sammenlign denne kode på begge enheder.\nHvis de stemmer, er overførslen sikker.';

  @override
  String get transferComplete => 'Overførsel færdig';

  @override
  String get transferKeysImported => 'Nøgler importeret';

  @override
  String get transferCompleteSenderBody =>
      'Dine nøgler forbliver aktive på denne enhed.\nModtageren kan nu bruge din identitet.';

  @override
  String get transferCompleteReceiverBody =>
      'Nøgler importeret.\nGenstart appen for at anvende den nye identitet.';

  @override
  String get transferRestartApp => 'Genstart app';

  @override
  String get transferFailed => 'Overførsel mislykkedes';

  @override
  String get transferTryAgain => 'Prøv igen';

  @override
  String get transferEnterRelayFirst => 'Indtast en relay-URL først';

  @override
  String get transferPasteCodeFromSender =>
      'Indsæt overførselskoden fra afsenderen';

  @override
  String get menuReply => 'Svar';

  @override
  String get menuForward => 'Videresend';

  @override
  String get menuReact => 'Reagér';

  @override
  String get menuCopy => 'Kopiér';

  @override
  String get menuEdit => 'Rediger';

  @override
  String get menuRetry => 'Prøv igen';

  @override
  String get menuCancelScheduled => 'Annuller planlagt';

  @override
  String get menuDelete => 'Slet';

  @override
  String get menuForwardTo => 'Videresend til…';

  @override
  String menuForwardedTo(String name) {
    return 'Videresendt til $name';
  }

  @override
  String get menuScheduledMessages => 'Planlagte beskeder';

  @override
  String get menuNoScheduledMessages => 'Ingen planlagte beskeder';

  @override
  String menuSendsOn(String date) {
    return 'Sendes $date';
  }

  @override
  String get menuDisappearingMessages => 'Forsvindende beskeder';

  @override
  String get menuDisappearingSubtitle =>
      'Beskeder slettes automatisk efter den valgte tid.';

  @override
  String get menuTtlOff => 'Fra';

  @override
  String get menuTtl1h => '1 time';

  @override
  String get menuTtl24h => '24 timer';

  @override
  String get menuTtl7d => '7 dage';

  @override
  String get menuAttachPhoto => 'Foto';

  @override
  String get menuAttachFile => 'Fil';

  @override
  String get menuAttachVideo => 'Video';

  @override
  String get mediaTitle => 'Medier';

  @override
  String get mediaFileLabel => 'FIL';

  @override
  String mediaPhotosTab(int count) {
    return 'Fotos ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Filer ($count)';
  }

  @override
  String get mediaNoPhotos => 'Ingen fotos endnu';

  @override
  String get mediaNoFiles => 'Ingen filer endnu';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Gemt i Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'Kunne ikke gemme filen';

  @override
  String get statusNewStatus => 'Ny status';

  @override
  String get statusPublish => 'Udgiv';

  @override
  String get statusExpiresIn24h => 'Status udløber om 24 timer';

  @override
  String get statusWhatsOnYourMind => 'Hvad tænker du på?';

  @override
  String get statusPhotoAttached => 'Foto vedhæftet';

  @override
  String get statusAttachPhoto => 'Vedhæft foto (valgfrit)';

  @override
  String get statusEnterText => 'Indtast tekst til din status.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Kunne ikke vælge foto: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Udgivelse mislykkedes: $error';
  }

  @override
  String get panicSetPanicKey => 'Indstil paniknøgle';

  @override
  String get panicEmergencySelfDestruct => 'Nød-selvdestruktion';

  @override
  String get panicIrreversible => 'Denne handling kan ikke fortrydes';

  @override
  String get panicWarningBody =>
      'Indtastning af denne nøgle på låseskærmen sletter øjeblikkeligt ALLE data — beskeder, kontakter, nøgler, identitet. Brug en nøgle, der er forskellig fra din normale adgangskode.';

  @override
  String get panicKeyHint => 'Paniknøgle';

  @override
  String get panicConfirmHint => 'Bekræft paniknøgle';

  @override
  String get panicMinChars => 'Paniknøglen skal være mindst 8 tegn';

  @override
  String get panicKeysDoNotMatch => 'Nøglerne stemmer ikke overens';

  @override
  String get panicSetFailed => 'Kunne ikke gemme paniknøgle — prøv igen';

  @override
  String get passwordSetAppPassword => 'Indstil app-adgangskode';

  @override
  String get passwordProtectsMessages => 'Beskytter dine beskeder i hvile';

  @override
  String get passwordInfoBanner =>
      'Kræves hver gang du åbner Pulse. Hvis den glemmes, kan dine data ikke gendannes.';

  @override
  String get passwordHint => 'Adgangskode';

  @override
  String get passwordConfirmHint => 'Bekræft adgangskode';

  @override
  String get passwordSetButton => 'Indstil adgangskode';

  @override
  String get passwordSkipForNow => 'Spring over for nu';

  @override
  String get passwordMinChars => 'Adgangskoden skal være mindst 8 tegn';

  @override
  String get passwordNeedsVariety =>
      'Skal indeholde bogstaver, tal og specialtegn';

  @override
  String get passwordRequirements =>
      'Min. 8 tegn med bogstaver, tal og et specialtegn';

  @override
  String get passwordsDoNotMatch => 'Adgangskoderne stemmer ikke overens';

  @override
  String get profileCardSaved => 'Profil gemt!';

  @override
  String get profileCardE2eeIdentity => 'E2EE-identitet';

  @override
  String get profileCardDisplayName => 'Visningsnavn';

  @override
  String get profileCardDisplayNameHint => 'f.eks. Anders Andersen';

  @override
  String get profileCardAbout => 'Om';

  @override
  String get profileCardSaveProfile => 'Gem profil';

  @override
  String get profileCardYourName => 'Dit navn';

  @override
  String get profileCardAddressCopied => 'Adresse kopieret!';

  @override
  String get profileCardInboxAddress => 'Din indbakkeadresse';

  @override
  String get profileCardInboxAddresses => 'Dine indbakkeadresser';

  @override
  String get profileCardShareAllAddresses => 'Del alle adresser (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Del med kontakter, så de kan sende dig beskeder.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Alle $count adresser kopieret som ét link!';
  }

  @override
  String get settingsMyProfile => 'Min profil';

  @override
  String get settingsYourInboxAddress => 'Din indbakkeadresse';

  @override
  String get settingsMyQrCode => 'Del kontakt';

  @override
  String get settingsMyQrSubtitle =>
      'QR-kode og invitationslink til din adresse';

  @override
  String get settingsShareMyAddress => 'Del min adresse';

  @override
  String get settingsNoAddressYet =>
      'Ingen adresse endnu — gem indstillingerne først';

  @override
  String get settingsInviteLink => 'Invitationslink';

  @override
  String get settingsRawAddress => 'Rå adresse';

  @override
  String get settingsCopyLink => 'Kopiér link';

  @override
  String get settingsCopyAddress => 'Kopiér adresse';

  @override
  String get settingsInviteLinkCopied => 'Invitationslink kopieret';

  @override
  String get settingsAppearance => 'Udseende';

  @override
  String get settingsThemeEngine => 'Temamotor';

  @override
  String get settingsThemeEngineSubtitle => 'Tilpas farver og skrifttyper';

  @override
  String get settingsSignalProtocol => 'Signal-protokol';

  @override
  String get settingsSignalProtocolSubtitle => 'E2EE-nøgler gemmes sikkert';

  @override
  String get settingsActive => 'AKTIV';

  @override
  String get settingsIdentityBackup => 'Identitetssikkerhedskopi';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Eksportér eller importér din Signal-identitet';

  @override
  String get settingsIdentityBackupBody =>
      'Eksportér dine Signal-identitetsnøgler til en sikkerhedskopi, eller gendan fra en eksisterende.';

  @override
  String get settingsTransferDevice => 'Overfør til en anden enhed';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Flyt din identitet via LAN eller Nostr-relay';

  @override
  String get settingsExportIdentity => 'Eksportér identitet';

  @override
  String get settingsExportIdentityBody =>
      'Kopiér denne sikkerhedskode og opbevar den sikkert:';

  @override
  String get settingsSaveFile => 'Gem fil';

  @override
  String get settingsImportIdentity => 'Importér identitet';

  @override
  String get settingsImportIdentityBody =>
      'Indsæt din sikkerhedskode nedenfor. Dette vil overskrive din nuværende identitet.';

  @override
  String get settingsPasteBackupCode => 'Indsæt sikkerhedskode her…';

  @override
  String get settingsIdentityImported =>
      'Identitet + kontakter importeret! Genstart appen for at anvende.';

  @override
  String get settingsSecurity => 'Sikkerhed';

  @override
  String get settingsAppPassword => 'App-adgangskode';

  @override
  String get settingsPasswordEnabled => 'Aktiveret — kræves ved hver start';

  @override
  String get settingsPasswordDisabled =>
      'Deaktiveret — appen åbner uden adgangskode';

  @override
  String get settingsChangePassword => 'Ændre adgangskode';

  @override
  String get settingsChangePasswordSubtitle =>
      'Opdater din app-låseadgangskode';

  @override
  String get settingsSetPanicKey => 'Indstil paniknøgle';

  @override
  String get settingsChangePanicKey => 'Ændre paniknøgle';

  @override
  String get settingsPanicKeySetSubtitle => 'Opdater nødsletningsnøgle';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Én nøgle, der sletter alle data øjeblikkeligt';

  @override
  String get settingsRemovePanicKey => 'Fjern paniknøgle';

  @override
  String get settingsRemovePanicKeySubtitle => 'Deaktiver nød-selvdestruktion';

  @override
  String get settingsRemovePanicKeyBody =>
      'Nød-selvdestruktion deaktiveres. Du kan genaktivere den når som helst.';

  @override
  String get settingsDisableAppPassword => 'Deaktiver app-adgangskode';

  @override
  String get settingsEnterCurrentPassword =>
      'Indtast din nuværende adgangskode for at bekræfte';

  @override
  String get settingsCurrentPassword => 'Nuværende adgangskode';

  @override
  String get settingsIncorrectPassword => 'Forkert adgangskode';

  @override
  String get settingsPasswordUpdated => 'Adgangskode opdateret';

  @override
  String get settingsChangePasswordProceed =>
      'Indtast din nuværende adgangskode for at fortsætte';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsBackupMessages => 'Sikkerhedskopiér beskeder';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Eksportér krypteret beskedhistorik til en fil';

  @override
  String get settingsRestoreMessages => 'Gendan beskeder';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Importér beskeder fra en sikkerhedskopi';

  @override
  String get settingsExportKeys => 'Eksportér nøgler';

  @override
  String get settingsExportKeysSubtitle =>
      'Gem identitetsnøgler til en krypteret fil';

  @override
  String get settingsImportKeys => 'Importér nøgler';

  @override
  String get settingsImportKeysSubtitle =>
      'Gendan identitetsnøgler fra en eksporteret fil';

  @override
  String get settingsBackupPassword => 'Sikkerhedskopi-adgangskode';

  @override
  String get settingsPasswordCannotBeEmpty => 'Adgangskoden må ikke være tom';

  @override
  String get settingsPasswordMin4Chars =>
      'Adgangskoden skal være mindst 4 tegn';

  @override
  String get settingsCallsTurn => 'Opkald og TURN';

  @override
  String get settingsLocalNetwork => 'Lokalt netværk';

  @override
  String get settingsCensorshipResistance => 'Censurresistens';

  @override
  String get settingsNetwork => 'Netværk';

  @override
  String get settingsProxyTunnels => 'Proxy og tunneler';

  @override
  String get settingsTurnServers => 'TURN-servere';

  @override
  String get settingsProviderTitle => 'Udbyder';

  @override
  String get settingsLanFallback => 'LAN-fallback';

  @override
  String get settingsLanFallbackSubtitle =>
      'Send tilstedeværelse og beskeder på lokalt netværk, når internet ikke er tilgængeligt. Deaktiver på upålidelige netværk (offentligt Wi-Fi).';

  @override
  String get settingsBgDelivery => 'Baggrundslevering';

  @override
  String get settingsBgDeliverySubtitle =>
      'Bliv ved med at modtage beskeder, når appen er minimeret. Viser en vedvarende notifikation.';

  @override
  String get settingsYourInboxProvider => 'Din indbakkeudbyder';

  @override
  String get settingsConnectionDetails => 'Forbindelsesdetaljer';

  @override
  String get settingsSaveAndConnect => 'Gem og forbind';

  @override
  String get settingsSecondaryInboxes => 'Sekundære indbakker';

  @override
  String get settingsAddSecondaryInbox => 'Tilføj sekundær indbakke';

  @override
  String get settingsAdvanced => 'Avanceret';

  @override
  String get settingsDiscover => 'Opdag';

  @override
  String get settingsAbout => 'Om';

  @override
  String get settingsPrivacyPolicy => 'Privatlivspolitik';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Hvordan Pulse beskytter dine data';

  @override
  String get settingsCrashReporting => 'Nedbrudsrapportering';

  @override
  String get settingsCrashReportingSubtitle =>
      'Send anonyme nedbrudsrapporter for at forbedre Pulse. Intet beskedindhold eller kontakter sendes.';

  @override
  String get settingsCrashReportingEnabled =>
      'Nedbrudsrapportering aktiveret — genstart appen for at anvende';

  @override
  String get settingsCrashReportingDisabled =>
      'Nedbrudsrapportering deaktiveret — genstart appen for at anvende';

  @override
  String get settingsSensitiveOperation => 'Følsom handling';

  @override
  String get settingsSensitiveOperationBody =>
      'Disse nøgler er din identitet. Alle med denne fil kan udgive sig for at være dig. Opbevar den sikkert og slet den efter overførsel.';

  @override
  String get settingsIUnderstandContinue => 'Jeg forstår, fortsæt';

  @override
  String get settingsReplaceIdentity => 'Erstat identitet?';

  @override
  String get settingsReplaceIdentityBody =>
      'Dette overskriver dine nuværende identitetsnøgler. Dine eksisterende Signal-sessioner bliver ugyldige, og kontakter skal genetablere kryptering. Appen skal genstartes.';

  @override
  String get settingsReplaceKeys => 'Erstat nøgler';

  @override
  String get settingsKeysImported => 'Nøgler importeret';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count nøgler importeret. Genstart appen for at initialisere med den nye identitet.';
  }

  @override
  String get settingsRestartNow => 'Genstart nu';

  @override
  String get settingsLater => 'Senere';

  @override
  String get profileGroupLabel => 'Gruppe';

  @override
  String get profileAddButton => 'Tilføj';

  @override
  String get profileKickButton => 'Smid ud';

  @override
  String get dataSectionTitle => 'Data';

  @override
  String get dataBackupMessages => 'Sikkerhedskopiér beskeder';

  @override
  String get dataBackupPasswordSubtitle =>
      'Vælg en adgangskode til at kryptere din sikkerhedskopi.';

  @override
  String get dataBackupConfirmLabel => 'Opret sikkerhedskopi';

  @override
  String get dataCreatingBackup => 'Opretter sikkerhedskopi';

  @override
  String get dataBackupPreparing => 'Forbereder...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Eksporterer besked $done af $total...';
  }

  @override
  String get dataBackupSavingFile => 'Gemmer fil...';

  @override
  String get dataSaveMessageBackupDialog => 'Gem beskedsikkerhedskopi';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Sikkerhedskopi gemt ($count beskeder)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Sikkerhedskopiering mislykkedes — ingen data eksporteret';

  @override
  String dataBackupFailedError(String error) {
    return 'Sikkerhedskopiering mislykkedes: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Vælg beskedsikkerhedskopi';

  @override
  String get dataInvalidBackupFile => 'Ugyldig sikkerhedskopifil (for lille)';

  @override
  String get dataNotValidBackupFile => 'Ikke en gyldig Pulse-sikkerhedskopifil';

  @override
  String get dataRestoreMessages => 'Gendan beskeder';

  @override
  String get dataRestorePasswordSubtitle =>
      'Indtast adgangskoden, der blev brugt til at oprette denne sikkerhedskopi.';

  @override
  String get dataRestoreConfirmLabel => 'Gendan';

  @override
  String get dataRestoringMessages => 'Gendanner beskeder';

  @override
  String get dataRestoreDecrypting => 'Dekrypterer...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Importerer besked $done af $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Gendannelse mislykkedes — forkert adgangskode eller beskadiget fil';

  @override
  String dataRestoreSuccess(int count) {
    return '$count nye beskeder gendannet';
  }

  @override
  String get dataRestoreNothingNew =>
      'Ingen nye beskeder at importere (alle findes allerede)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Gendannelse mislykkedes: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Vælg nøgleeksport';

  @override
  String get dataNotValidKeyFile => 'Ikke en gyldig Pulse-nøgleeksportfil';

  @override
  String get dataExportKeys => 'Eksportér nøgler';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Vælg en adgangskode til at kryptere din nøgleeksport.';

  @override
  String get dataExportKeysConfirmLabel => 'Eksportér';

  @override
  String get dataExportingKeys => 'Eksporterer nøgler';

  @override
  String get dataExportingKeysStatus => 'Krypterer identitetsnøgler...';

  @override
  String get dataSaveKeyExportDialog => 'Gem nøgleeksport';

  @override
  String dataKeysExportedTo(String path) {
    return 'Nøgler eksporteret til:\n$path';
  }

  @override
  String get dataExportFailed => 'Eksport mislykkedes — ingen nøgler fundet';

  @override
  String dataExportFailedError(String error) {
    return 'Eksport mislykkedes: $error';
  }

  @override
  String get dataImportKeys => 'Importér nøgler';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Indtast adgangskoden, der blev brugt til at kryptere denne nøgleeksport.';

  @override
  String get dataImportKeysConfirmLabel => 'Importér';

  @override
  String get dataImportingKeys => 'Importerer nøgler';

  @override
  String get dataImportingKeysStatus => 'Dekrypterer identitetsnøgler...';

  @override
  String get dataImportFailed =>
      'Import mislykkedes — forkert adgangskode eller beskadiget fil';

  @override
  String dataImportFailedError(String error) {
    return 'Import mislykkedes: $error';
  }

  @override
  String get securitySectionTitle => 'Sikkerhed';

  @override
  String get securityIncorrectPassword => 'Forkert adgangskode';

  @override
  String get securityPasswordUpdated => 'Adgangskode opdateret';

  @override
  String get appearanceSectionTitle => 'Udseende';

  @override
  String appearanceExportFailed(String error) {
    return 'Eksport mislykkedes: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Gemt i $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Gemning mislykkedes: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Import mislykkedes: $error';
  }

  @override
  String get aboutSectionTitle => 'Om';

  @override
  String get providerPublicKey => 'Offentlig nøgle';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Automatisk konfigureret fra din gendannelsesadgangskode. Relay opdaget automatisk.';

  @override
  String get providerKeyStoredLocally =>
      'Din nøgle gemmes lokalt i sikker lagring — sendes aldrig til nogen server.';

  @override
  String get providerSessionInfo =>
      'Session Network — løg-ruteret E2EE. Dit Session ID genereres automatisk og gemmes sikkert. Noder opdages automatisk fra indbyggede frønoder.';

  @override
  String get providerAdvanced => 'Avanceret';

  @override
  String get providerSaveAndConnect => 'Gem og forbind';

  @override
  String get providerAddSecondaryInbox => 'Tilføj sekundær indbakke';

  @override
  String get providerSecondaryInboxes => 'Sekundære indbakker';

  @override
  String get providerYourInboxProvider => 'Din indbakkeudbyder';

  @override
  String get providerConnectionDetails => 'Forbindelsesdetaljer';

  @override
  String get addContactTitle => 'Tilføj kontakt';

  @override
  String get addContactInviteLinkLabel => 'Invitationslink eller adresse';

  @override
  String get addContactTapToPaste => 'Tryk for at indsætte invitationslink';

  @override
  String get addContactPasteTooltip => 'Indsæt fra udklipsholder';

  @override
  String get addContactAddressDetected => 'Kontaktadresse registreret';

  @override
  String addContactRoutesDetected(int count) {
    return '$count ruter registreret — SmartRouter vælger den hurtigste';
  }

  @override
  String get addContactFetchingProfile => 'Henter profil…';

  @override
  String addContactProfileFound(String name) {
    return 'Fundet: $name';
  }

  @override
  String get addContactNoProfileFound => 'Ingen profil fundet';

  @override
  String get addContactDisplayNameLabel => 'Visningsnavn';

  @override
  String get addContactDisplayNameHint => 'Hvad vil du kalde dem?';

  @override
  String get addContactAddManually => 'Tilføj adresse manuelt';

  @override
  String get addContactButton => 'Tilføj kontakt';

  @override
  String get networkDiagnosticsTitle => 'Netværksdiagnostik';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr-relays';

  @override
  String get networkDiagnosticsDirect => 'Direkte';

  @override
  String get networkDiagnosticsTorOnly => 'Kun Tor';

  @override
  String get networkDiagnosticsBest => 'Bedste';

  @override
  String get networkDiagnosticsNone => 'ingen';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Status';

  @override
  String get networkDiagnosticsConnected => 'Forbundet';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Forbinder $percent %';
  }

  @override
  String get networkDiagnosticsOff => 'Fra';

  @override
  String get networkDiagnosticsTransport => 'Transport';

  @override
  String get networkDiagnosticsInfrastructure => 'Infrastruktur';

  @override
  String get networkDiagnosticsSessionNodes => 'Session noder';

  @override
  String get networkDiagnosticsTurnServers => 'TURN-servere';

  @override
  String get networkDiagnosticsLastProbe => 'Sidste tjek';

  @override
  String get networkDiagnosticsRunning => 'Kører...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Kør diagnostik';

  @override
  String get networkDiagnosticsForceReprobe => 'Tving fuld genprøvning';

  @override
  String get networkDiagnosticsJustNow => 'lige nu';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes min. siden';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours t. siden';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days d. siden';
  }

  @override
  String get homeNoEch => 'Ingen ECH';

  @override
  String get homeNoEchTooltip =>
      'uTLS-proxy utilgængelig — ECH deaktiveret.\nTLS-fingeraftryk er synligt for DPI.';

  @override
  String get settingsTitle => 'Indstillinger';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Gemt og forbundet til $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Indbygget Tor kunne ikke starte';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon kunne ikke starte';

  @override
  String get verifyTitle => 'Verificer sikkerhedsnummer';

  @override
  String get verifyIdentityVerified => 'Identitet verificeret';

  @override
  String get verifyNotYetVerified => 'Ikke verificeret endnu';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Du har verificeret sikkerhedsnummeret for $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Sammenlign disse numre med $name personligt eller over en betroet kanal.';
  }

  @override
  String get verifyExplanation =>
      'Hver samtale har et unikt sikkerhedsnummer. Hvis I begge ser de samme numre på jeres enheder, er forbindelsen verificeret ende-til-ende.';

  @override
  String verifyContactKey(String name) {
    return '${name}s nøgle';
  }

  @override
  String get verifyYourKey => 'Din nøgle';

  @override
  String get verifyRemoveVerification => 'Fjern verificering';

  @override
  String get verifyMarkAsVerified => 'Markér som verificeret';

  @override
  String verifyAfterReinstall(String name) {
    return 'Hvis $name geninstallerer appen, ændres sikkerhedsnummeret, og verificeringen fjernes automatisk.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Markér kun som verificeret efter at have sammenlignet numrene med $name over et taleopkald eller personligt.';
  }

  @override
  String get verifyNoSession =>
      'Ingen krypteringssession etableret endnu. Send en besked først for at generere sikkerhedsnumre.';

  @override
  String get verifyNoKeyAvailable => 'Ingen nøgle tilgængelig';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label-fingeraftryk kopieret';
  }

  @override
  String get providerDatabaseUrlLabel => 'Database-URL';

  @override
  String get providerOptionalHint => 'Valgfrit';

  @override
  String get providerWebApiKeyLabel => 'Web API-nøgle';

  @override
  String get providerOptionalForPublicDb => 'Valgfrit for offentlig database';

  @override
  String get providerRelayUrlLabel => 'Relay-URL';

  @override
  String get providerPrivateKeyLabel => 'Privat nøgle';

  @override
  String get providerPrivateKeyNsecLabel => 'Privat nøgle (nsec)';

  @override
  String get providerStorageNodeLabel => 'Lagernodé-URL (valgfrit)';

  @override
  String get providerStorageNodeHint =>
      'Lad stå tomt for indbyggede seed-noder';

  @override
  String get transferInvalidCodeFormat =>
      'Ukendt kodeformat — skal starte med LAN: eller NOS:';

  @override
  String get profileCardFingerprintCopied => 'Fingeraftryk kopieret';

  @override
  String get profileCardAboutHint => 'Privatliv først 🔒';

  @override
  String get profileCardSaveButton => 'Gem profil';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Eksportér krypterede beskeder, kontakter og avatarer til en fil';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Lyd';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Leveret til $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Leveret til $count';
  }

  @override
  String get groupStatusDialogTitle => 'Beskedinfo';

  @override
  String get groupStatusRead => 'Læst';

  @override
  String get groupStatusDelivered => 'Leveret';

  @override
  String get groupStatusPending => 'Afventer';

  @override
  String get groupStatusNoData => 'Ingen leveringsoplysninger endnu';

  @override
  String get profileTransferAdmin => 'Gør til administrator';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Gøre $name til ny administrator?';
  }

  @override
  String get profileTransferAdminBody =>
      'Du mister dine administratorrettigheder. Dette kan ikke fortrydes.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name er nu administrator';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Privatlivspolitik';

  @override
  String get privacyOverviewHeading => 'Oversigt';

  @override
  String get privacyOverviewBody =>
      'Pulse er en serverløs, ende-til-ende-krypteret beskedtjeneste. Dit privatliv er ikke bare en funktion — det er arkitekturen. Der er ingen Pulse-servere. Ingen konti gemmes nogen steder. Ingen data indsamles, sendes til eller gemmes af udviklerne.';

  @override
  String get privacyDataCollectionHeading => 'Dataindsamling';

  @override
  String get privacyDataCollectionBody =>
      'Pulse indsamler nul personlige data. Specifikt:\n\n- Ingen e-mail, telefonnummer eller rigtigt navn kræves\n- Ingen analyser, sporing eller telemetri\n- Ingen reklameidentifikatorer\n- Ingen adgang til kontaktliste\n- Ingen cloud-sikkerhedskopier (beskeder eksisterer kun på din enhed)\n- Ingen metadata sendes til nogen Pulse-server (der er ingen)';

  @override
  String get privacyEncryptionHeading => 'Kryptering';

  @override
  String get privacyEncryptionBody =>
      'Alle beskeder krypteres med Signal-protokollen (Double Ratchet med X3DH-nøgleaftale). Krypteringsnøgler genereres og gemmes udelukkende på din enhed. Ingen — heller ikke udviklerne — kan læse dine beskeder.';

  @override
  String get privacyNetworkHeading => 'Netværksarkitektur';

  @override
  String get privacyNetworkBody =>
      'Pulse bruger fødererede transportadaptere (Nostr-relays, Session/Oxen-servicenoder, Firebase Realtime Database, LAN). Disse transporter bærer kun krypteret chiffertekst. Relay-operatører kan se din IP-adresse og trafikmængde, men kan ikke dekryptere beskedindhold.\n\nNår Tor er aktiveret, skjules din IP-adresse også for relay-operatører.';

  @override
  String get privacyStunHeading => 'STUN/TURN-servere';

  @override
  String get privacyStunBody =>
      'Tale- og videoopkald bruger WebRTC med DTLS-SRTP-kryptering. STUN-servere (brugt til at opdage din offentlige IP til P2P-forbindelser) og TURN-servere (brugt til at videresende medier, når direkte forbindelse mislykkes) kan se din IP-adresse og opkaldsvarighed, men kan ikke dekryptere opkaldsindhold.\n\nDu kan konfigurere din egen TURN-server i Indstillinger for maksimalt privatliv.';

  @override
  String get privacyCrashHeading => 'Nedbrudsrapportering';

  @override
  String get privacyCrashBody =>
      'Hvis Sentry-nedbrudsrapportering er aktiveret (via SENTRY_DSN ved build), kan anonyme nedbrudsrapporter sendes. Disse indeholder intet beskedindhold, ingen kontaktoplysninger og ingen personligt identificerbare oplysninger. Nedbrudsrapportering kan deaktiveres ved build ved at udelade DSN.';

  @override
  String get privacyPasswordHeading => 'Adgangskode og nøgler';

  @override
  String get privacyPasswordBody =>
      'Din gendannelsesadgangskode bruges til at udlede kryptografiske nøgler via Argon2id (hukommelses-hård KDF). Adgangskoden sendes aldrig nogen steder. Hvis du mister din adgangskode, kan din konto ikke gendannes — der er ingen server til at nulstille den.';

  @override
  String get privacyFontsHeading => 'Skrifttyper';

  @override
  String get privacyFontsBody =>
      'Pulse inkluderer alle skrifttyper lokalt. Ingen forespørgsler sendes til Google Fonts eller nogen ekstern skrifttjeneste.';

  @override
  String get privacyThirdPartyHeading => 'Tredjepartstjenester';

  @override
  String get privacyThirdPartyBody =>
      'Pulse integrerer ikke med nogen reklamenetværk, analyseudbydere, sociale medieplatforme eller datamæglere. De eneste netværksforbindelser er til de transportrelays, du konfigurerer.';

  @override
  String get privacyOpenSourceHeading => 'Åben kildekode';

  @override
  String get privacyOpenSourceBody =>
      'Pulse er open source-software. Du kan gennemgå den komplette kildekode for at verificere disse privatlivspåstande.';

  @override
  String get privacyContactHeading => 'Kontakt';

  @override
  String get privacyContactBody =>
      'For privatlivsrelaterede spørgsmål, opret en sag i projektets kodelager.';

  @override
  String get privacyLastUpdated => 'Sidst opdateret: marts 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Gemning mislykkedes: $error';
  }

  @override
  String get themeEngineTitle => 'Temamotor';

  @override
  String get torBuiltInTitle => 'Indbygget Tor';

  @override
  String get torConnectedSubtitle =>
      'Forbundet — Nostr routet via 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Forbinder… $pct %';
  }

  @override
  String get torNotRunning => 'Kører ikke — tryk for at genstarte';

  @override
  String get torDescription =>
      'Router Nostr via Tor (Snowflake til censurerede netværk)';

  @override
  String get torNetworkDiagnostics => 'Netværksdiagnostik';

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
  String get torPtPlain => 'Normal';

  @override
  String get torTimeoutLabel => 'Timeout: ';

  @override
  String get torInfoDescription =>
      'Når aktiveret, routes Nostr WebSocket-forbindelser gennem Tor (SOCKS5). Tor Browser lytter på 127.0.0.1:9150. Den selvstændige tor-dæmon bruger port 9050. Firebase-forbindelser påvirkes ikke.';

  @override
  String get torRouteNostrTitle => 'Rout Nostr via Tor';

  @override
  String get torManagedByBuiltin => 'Styret af indbygget Tor';

  @override
  String get torActiveRouting => 'Aktiv — Nostr-trafik routes gennem Tor';

  @override
  String get torDisabled => 'Deaktiveret';

  @override
  String get torProxySocks5 => 'Tor-proxy (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Proxy-vært';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser: port 9150  •  tor-dæmon: port 9050';

  @override
  String get torForceNostrTitle => 'Send beskeder via Tor';

  @override
  String get torForceNostrSubtitle =>
      'Alle Nostr relay-forbindelser vil gå gennem Tor. Langsommere, men skjuler din IP fra relays.';

  @override
  String get torForceNostrDisabled => 'Tor skal aktiveres først';

  @override
  String get torForcePulseTitle => 'Send Pulse relay via Tor';

  @override
  String get torForcePulseSubtitle =>
      'Alle Pulse relay-forbindelser vil gå gennem Tor. Langsommere, men skjuler din IP fra serveren.';

  @override
  String get torForcePulseDisabled => 'Tor skal aktiveres først';

  @override
  String get i2pProxySocks5 => 'I2P-proxy (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P bruger SOCKS5 på port 4447 som standard. Forbind til et Nostr-relay via I2P-outproxy (f.eks. relay.damus.i2p) for at kommunikere med brugere på enhver transport. Tor har prioritet, når begge er aktiveret.';

  @override
  String get i2pRouteNostrTitle => 'Rout Nostr via I2P';

  @override
  String get i2pActiveRouting => 'Aktiv — Nostr-trafik routes gennem I2P';

  @override
  String get i2pDisabled => 'Deaktiveret';

  @override
  String get i2pProxyHostLabel => 'Proxy-vært';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'I2P-router standard SOCKS5-port: 4447';

  @override
  String get customProxySocks5 => 'Brugerdefineret proxy (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Brugerdefineret proxy router trafik gennem din V2Ray/Xray/Shadowsocks. CF Worker fungerer som en personlig relay-proxy på Cloudflare CDN — GFW ser *.workers.dev, ikke det rigtige relay.';

  @override
  String get customSocks5ProxyTitle => 'Brugerdefineret SOCKS5-proxy';

  @override
  String get customProxyActive => 'Aktiv — trafik routes via SOCKS5';

  @override
  String get customProxyDisabled => 'Deaktiveret';

  @override
  String get customProxyHostLabel => 'Proxy-vært';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker-domæne (valgfrit)';

  @override
  String get customWorkerHelpTitle =>
      'Sådan opretter du et CF Worker-relay (gratis)';

  @override
  String get customWorkerScriptCopied => 'Script kopieret!';

  @override
  String get customWorkerStep1 =>
      '1. Gå til dash.cloudflare.com → Workers & Pages\n2. Create Worker → indsæt dette script:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → kopiér domænet (f.eks. my-relay.user.workers.dev)\n4. Indsæt domænet ovenfor → Gem\n\nAppen forbinder automatisk: wss://domain/?r=relay_url\nGFW ser: forbindelse til *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Forbundet — SOCKS5 på 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Forbinder…';

  @override
  String get psiphonNotRunning => 'Kører ikke — tryk for at genstarte';

  @override
  String get psiphonDescription =>
      'Hurtig tunnel (~3s bootstrap, 2000+ roterende VPS)';

  @override
  String get turnCommunityServers => 'Fællesskabets TURN-servere';

  @override
  String get turnCustomServer => 'Brugerdefineret TURN-server (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN-servere videresender kun allerede krypterede strømme (DTLS-SRTP). En relay-operatør ser din IP og trafikmængde, men kan ikke dekryptere opkald. TURN bruges kun, når direkte P2P mislykkes (~15–20 % af forbindelser).';

  @override
  String get turnFreeLabel => 'GRATIS';

  @override
  String get turnServerUrlLabel => 'TURN-server-URL';

  @override
  String get turnServerUrlHint => 'turn:din-server.com:3478 eller turns:...';

  @override
  String get turnUsernameLabel => 'Brugernavn';

  @override
  String get turnPasswordLabel => 'Adgangskode';

  @override
  String get turnOptionalHint => 'Valgfrit';

  @override
  String get turnCustomInfo =>
      'Kør coturn på en vilkårlig \$5/md VPS for maksimal kontrol. Legitimationsoplysninger gemmes lokalt.';

  @override
  String get themePickerAppearance => 'Udseende';

  @override
  String get themePickerAccentColor => 'Accentfarve';

  @override
  String get themeModeLight => 'Lys';

  @override
  String get themeModeDark => 'Mørk';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeDynamicPresets => 'Forudindstillinger';

  @override
  String get themeDynamicPrimaryColor => 'Primærfarve';

  @override
  String get themeDynamicBorderRadius => 'Kantradius';

  @override
  String get themeDynamicFont => 'Skrifttype';

  @override
  String get themeDynamicAppearance => 'Udseende';

  @override
  String get themeDynamicUiStyle => 'UI-stil';

  @override
  String get themeDynamicUiStyleDescription =>
      'Styrer udseendet af dialoger, kontakter og indikatorer.';

  @override
  String get themeDynamicSharp => 'Skarp';

  @override
  String get themeDynamicRound => 'Rund';

  @override
  String get themeDynamicModeDark => 'Mørk';

  @override
  String get themeDynamicModeLight => 'Lys';

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
      'Ugyldig Firebase-URL. Forventet: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Ugyldig relay-URL. Forventet: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Ugyldig Pulse-server-URL. Forventet: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'Server-URL';

  @override
  String get providerPulseServerUrlHint => 'https://din-server:8443';

  @override
  String get providerPulseInviteLabel => 'Invitationskode';

  @override
  String get providerPulseInviteHint => 'Invitationskode (hvis påkrævet)';

  @override
  String get providerPulseInfo =>
      'Selvhostet relay. Nøgler udledt fra din gendannelsesadgangskode.';

  @override
  String get providerScreenTitle => 'Indbakker';

  @override
  String get providerSecondaryInboxesHeader => 'SEKUNDÆRE INDBAKKER';

  @override
  String get providerSecondaryInboxesInfo =>
      'Sekundære indbakker modtager beskeder samtidigt for redundans.';

  @override
  String get providerRemoveTooltip => 'Fjern';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... eller hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... eller hex privatnøgle';

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
  String get emojiNoRecent => 'Ingen nylige emojis';

  @override
  String get emojiSearchHint => 'Søg emoji...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Tryk for at chatte';

  @override
  String get imageViewerSaveToDownloads => 'Gem i Downloads';

  @override
  String imageViewerSavedTo(String path) {
    return 'Gemt i $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Sprog';

  @override
  String get settingsLanguageSubtitle => 'Appens visningssprog';

  @override
  String get settingsLanguageSystem => 'Systemstandard';

  @override
  String get onboardingLanguageTitle => 'Vælg dit sprog';

  @override
  String get onboardingLanguageSubtitle =>
      'Du kan ændre dette senere i Indstillinger';

  @override
  String get videoNoteRecord => 'Optag en videobesked';

  @override
  String get videoNoteTapToRecord => 'Tryk for at optage';

  @override
  String get videoNoteTapToStop => 'Tryk for at stoppe';

  @override
  String get videoNoteCameraPermission => 'Kameraadgang nægtet';

  @override
  String get videoNoteMaxDuration => 'Maksimalt 30 sekunder';

  @override
  String get videoNoteNotSupported =>
      'Videonoter understøttes ikke på denne platform';

  @override
  String get navChats => 'Chats';

  @override
  String get navUpdates => 'Opdateringer';

  @override
  String get navCalls => 'Opkald';

  @override
  String get filterAll => 'Alle';

  @override
  String get filterUnread => 'Ulæst';

  @override
  String get filterGroups => 'Grupper';

  @override
  String get callsNoRecent => 'Ingen seneste opkald';

  @override
  String get callsEmptySubtitle => 'Din opkaldshistorik vises her';

  @override
  String get appBarEncrypted => 'ende-til-ende krypteret';

  @override
  String get newStatus => 'Ny status';

  @override
  String get newCall => 'Nyt opkald';

  @override
  String get joinChannelTitle => 'Tilslut kanal';

  @override
  String get joinChannelDescription => 'KANAL-URL';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'Henter kanaloplysninger…';

  @override
  String get joinChannelNotFound => 'Ingen kanal fundet på denne URL';

  @override
  String get joinChannelNetworkError => 'Kunne ikke nå serveren';

  @override
  String get joinChannelAlreadyJoined => 'Allerede tilsluttet';

  @override
  String get joinChannelButton => 'Tilslut';

  @override
  String get channelFeedEmpty => 'Ingen opslag endnu';

  @override
  String get channelLeave => 'Forlad kanal';

  @override
  String get channelLeaveConfirm =>
      'Forlad denne kanal? Gemte opslag vil blive slettet.';

  @override
  String get channelInfo => 'Kanalinfo';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'redigeret';

  @override
  String get channelLoadMore => 'Indlæs flere';

  @override
  String get channelSearchPosts => 'Søg i opslag…';

  @override
  String get channelNoResults => 'Ingen matchende opslag';

  @override
  String get channelUrl => 'Kanal-URL';

  @override
  String get channelCreated => 'Tilmeldt';

  @override
  String channelPostCount(int count) {
    return '$count opslag';
  }

  @override
  String get channelCopyUrl => 'Kopiér URL';

  @override
  String get setupNext => 'Næste';

  @override
  String get setupKeyWarning =>
      'Der vil blive genereret en gendannelsesnøgle til dig. Det er den eneste måde at gendanne din konto på en ny enhed — der er ingen server, ingen nulstilling af adgangskode.';

  @override
  String get setupKeyTitle => 'Din gendannelsesnøgle';

  @override
  String get setupKeySubtitle =>
      'Skriv denne nøgle ned og opbevar den et sikkert sted. Du får brug for den til at gendanne din konto på en ny enhed.';

  @override
  String get setupKeyCopied => 'Kopieret!';

  @override
  String get setupKeyWroteItDown => 'Jeg har skrevet den ned';

  @override
  String get setupKeyWarnBody =>
      'Skriv denne nøgle ned som backup. Du kan også se den senere under Indstillinger → Sikkerhed.';

  @override
  String get setupVerifyTitle => 'Bekræft gendannelsesnøgle';

  @override
  String get setupVerifySubtitle =>
      'Indtast din gendannelsesnøgle igen for at bekræfte, at du har gemt den korrekt.';

  @override
  String get setupVerifyButton => 'Bekræft';

  @override
  String get setupKeyMismatch => 'Nøglen matcher ikke. Tjek og prøv igen.';

  @override
  String get setupSkipVerify => 'Spring bekræftelse over';

  @override
  String get setupSkipVerifyTitle => 'Spring bekræftelse over?';

  @override
  String get setupSkipVerifyBody =>
      'Hvis du mister din gendannelsesnøgle, kan din konto ikke gendannes. Er du sikker på, at du vil springe over?';

  @override
  String get setupCreatingAccount => 'Opretter konto…';

  @override
  String get setupRestoringAccount => 'Gendanner konto…';

  @override
  String get restoreKeyInfoBanner =>
      'Indtast din gendannelsesnøgle — din adresse (Nostr + Session) gendannes automatisk. Kontakter og beskeder var kun gemt lokalt.';

  @override
  String get restoreKeyHint => 'Gendannelsesnøgle';

  @override
  String get settingsViewRecoveryKey => 'Vis gendannelsesnøgle';

  @override
  String get settingsViewRecoveryKeySubtitle =>
      'Vis din kontos gendannelsesnøgle';

  @override
  String get settingsRecoveryKeyNotStored =>
      'Gendannelsesnøgle ikke tilgængelig (oprettet før denne funktion)';

  @override
  String get settingsRecoveryKeyWarning =>
      'Opbevar denne nøgle sikkert. Enhver med den kan gendanne din konto på en anden enhed.';

  @override
  String get replaceIdentityTitle => 'Erstat eksisterende identitet?';

  @override
  String get replaceIdentityBodyRestore =>
      'Der findes allerede en identitet på denne enhed. Gendannelse vil permanent erstatte din nuværende Nostr-nøgle og Oxen-seed. Alle kontakter vil miste muligheden for at nå din nuværende adresse.\n\nDette kan ikke fortrydes.';

  @override
  String get replaceIdentityBodyCreate =>
      'Der findes allerede en identitet på denne enhed. Oprettelse af en ny vil permanent erstatte din nuværende Nostr-nøgle og Oxen-seed. Alle kontakter vil miste muligheden for at nå din nuværende adresse.\n\nDette kan ikke fortrydes.';

  @override
  String get replace => 'Erstat';

  @override
  String get callNoScreenSources => 'Ingen skærmkilder tilgængelige';

  @override
  String get callScreenShareQuality => 'Skærmdelingskvalitet';

  @override
  String get callFrameRate => 'Billedhastighed';

  @override
  String get callResolution => 'Opløsning';

  @override
  String get callAutoResolution => 'Auto = skærmens native opløsning';

  @override
  String get callStartSharing => 'Start deling';

  @override
  String get callCameraUnavailable =>
      'Kamera utilgængeligt — bruges muligvis af en anden app';

  @override
  String get themeResetToDefaults => 'Nulstil til standard';

  @override
  String get backupSaveToDownloadsTitle => 'Gem sikkerhedskopi i Overførsler?';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'Ingen filvælger tilgængelig. Sikkerhedskopien gemmes i:\n$path';
  }

  @override
  String get systemLabel => 'System';

  @override
  String get next => 'Næste';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return '$remaining tryk mere for at aktivere udviklertilstand';
  }

  @override
  String get devModeEnabled => 'Udviklertilstand aktiveret';

  @override
  String get devTools => 'Udviklerværktøjer';

  @override
  String get devAdapterDiagnostics => 'Adapterskift og diagnostik';

  @override
  String get devEnableAll => 'Aktivér alle';

  @override
  String get devDisableAll => 'Deaktivér alle';

  @override
  String get turnUrlValidation =>
      'TURN-URL skal starte med turn: eller turns: (maks. 512 tegn)';

  @override
  String get callMissedCall => 'Ubesvaret opkald';

  @override
  String get callOutgoingCall => 'Udgående opkald';

  @override
  String get callIncomingCall => 'Indgående opkald';

  @override
  String get mediaMissingData => 'Manglende mediedata';

  @override
  String get mediaDownloadFailed => 'Download mislykkedes';

  @override
  String get mediaDecryptFailed => 'Dekryptering mislykkedes';

  @override
  String get callEndCallBanner => 'Afslut opkald';

  @override
  String get meFallback => 'Mig';

  @override
  String get imageSaveToDownloads => 'Gem i Overførsler';

  @override
  String imageSavedToPath(String path) {
    return 'Gemt i $path';
  }

  @override
  String get callScreenShareRequiresPermission =>
      'Skærmdeling kræver tilladelse';

  @override
  String get callScreenShareUnavailable => 'Skærmdeling utilgængelig';

  @override
  String get statusJustNow => 'Lige nu';

  @override
  String statusMinutesAgo(int minutes) {
    return '${minutes}m siden';
  }

  @override
  String statusHoursAgo(int hours) {
    return '${hours}t siden';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ruter',
      one: '1 rute',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => 'Klar til at tilføje';

  @override
  String groupSelectedCount(int count) {
    return '$count valgt';
  }

  @override
  String get paste => 'Indsæt';

  @override
  String get sfuAudioOnly => 'Kun lyd';

  @override
  String sfuParticipants(int count) {
    return '$count deltagere';
  }

  @override
  String get dataUnencryptedBackup => 'Ukrypteret sikkerhedskopi';

  @override
  String get dataUnencryptedBackupBody =>
      'Denne fil er en ukrypteret identitets-sikkerhedskopi og vil overskrive dine nuværende nøgler. Importér kun filer du selv har oprettet. Fortsæt?';

  @override
  String get dataImportAnyway => 'Importér alligevel';

  @override
  String get securityStorageError => 'Sikkerhedslagringsfejl — genstart appen';

  @override
  String get aboutDevModeActive => 'Udviklertilstand aktiv';

  @override
  String get themeColors => 'Farver';

  @override
  String get themePrimaryAccent => 'Primær accent';

  @override
  String get themeSecondaryAccent => 'Sekundær accent';

  @override
  String get themeBackground => 'Baggrund';

  @override
  String get themeSurface => 'Overflade';

  @override
  String get themeChatBubbles => 'Chatbobler';

  @override
  String get themeOutgoingMessage => 'Udgående besked';

  @override
  String get themeIncomingMessage => 'Indgående besked';

  @override
  String get themeShape => 'Form';

  @override
  String get devSectionDeveloper => 'Udvikler';

  @override
  String get devAdapterChannelsHint =>
      'Adapterkanaler — deaktivér for at teste specifikke transporter.';

  @override
  String get devNostrRelays => 'Nostr-relæer (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Session-netværk';

  @override
  String get devPulseRelay => 'Pulse selvhostet relay';

  @override
  String get devLanNetwork => 'Lokalt netværk (UDP/TCP)';

  @override
  String get devSectionCalls => 'Opkald';

  @override
  String get devForceTurnRelay => 'Tving TURN-relay';

  @override
  String get devForceTurnRelaySubtitle =>
      'Deaktivér P2P — alle opkald kun via TURN-servere';

  @override
  String get devRestartWarning =>
      '⚠ Ændringer træder i kraft ved næste afsendelse/opkald. Genstart appen for at anvende på indgående.';

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
  String get pulseUseServerTitle => 'Brug Pulse-server?';

  @override
  String pulseUseServerBody(String name, String host) {
    return '$name bruger Pulse-serveren $host. Deltag for at chatte hurtigere med dem (og med andre på samme server)?';
  }

  @override
  String pulseContactUsesPulse(String name) {
    return '$name bruger Pulse';
  }

  @override
  String pulseJoinForFaster(String host) {
    return 'Deltag i $host for hurtigere chat';
  }

  @override
  String get pulseNotNow => 'Ikke nu';

  @override
  String get pulseJoin => 'Deltag';

  @override
  String get pulseDismiss => 'Luk';

  @override
  String get pulseHide7Days => 'Skjul i 7 dage';

  @override
  String get pulseNeverAskAgain => 'Spørg ikke igen';

  @override
  String get groupSearchContactsHint => 'Søg kontakter…';

  @override
  String get systemActorYou => 'Du';

  @override
  String get systemActorPeer => 'Kontakt';

  @override
  String systemTtlEnabled(String actor, String duration) {
    return '$actor aktiverede forsvindende beskeder: $duration';
  }

  @override
  String systemTtlDisabled(String actor) {
    return '$actor deaktiverede forsvindende beskeder';
  }

  @override
  String get menuClearChatHistory => 'Ryd chathistorik';

  @override
  String get clearChatTitle => 'Ryd chathistorikken?';

  @override
  String get clearChatBody =>
      'Alle beskeder i denne chat slettes fra denne enhed. Den anden person beholder deres kopi.';

  @override
  String get clearChatAction => 'Ryd';

  @override
  String systemGroupRenamed(String actor, String name) {
    return '$actor omdøbte gruppen til \"$name\"';
  }

  @override
  String systemGroupAvatarChanged(String actor) {
    return '$actor ændrede gruppens foto';
  }

  @override
  String systemGroupMetaChanged(String actor, String name) {
    return '$actor omdøbte gruppen til \"$name\" og ændrede fotoet';
  }

  @override
  String get profileInviteLink => 'Invitationslink';

  @override
  String get profileInviteLinkSubtitle => 'Alle med linket kan deltage';

  @override
  String get profileInviteLinkCopied => 'Invitationslink kopieret';

  @override
  String get groupInviteLinkTitle => 'Deltag i gruppen?';

  @override
  String groupInviteLinkBody(String name, int count) {
    return 'Du er inviteret til at deltage i \"$name\" ($count medlemmer).';
  }

  @override
  String get groupInviteLinkJoin => 'Deltag';

  @override
  String get drawerCreateGroup => 'Opret gruppe';

  @override
  String get drawerJoinGroup => 'Tilslut gruppe';

  @override
  String get drawerJoinGroupByLinkInvalid =>
      'Det ligner ikke et Pulse-invitationslink';

  @override
  String get groupModeMeshTitle => 'Almindelig';

  @override
  String groupModeMeshSubtitle(int n) {
    return 'Ingen server, op til $n personer';
  }

  @override
  String get groupModeSfuTitle => 'Med Pulse-server';

  @override
  String groupModeSfuSubtitle(int n) {
    return 'Via server, op til $n personer';
  }

  @override
  String get groupPulseServerHint => 'https://din-pulse-server';

  @override
  String get groupPulseServerClosed => 'Lukket server (kræver invitationskode)';

  @override
  String get groupPulseInviteHint => 'Invitationskode';

  @override
  String groupMeshLimitReached(int n) {
    return 'Denne opkaldstype er begrænset til $n personer';
  }
}
