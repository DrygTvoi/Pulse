// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian (`no`).
class AppLocalizationsNo extends AppLocalizations {
  AppLocalizationsNo([String locale = 'no']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Søk i meldinger...';

  @override
  String get search => 'Søk';

  @override
  String get clearSearch => 'Tøm søk';

  @override
  String get closeSearch => 'Lukk søk';

  @override
  String get moreOptions => 'Flere alternativer';

  @override
  String get back => 'Tilbake';

  @override
  String get cancel => 'Avbryt';

  @override
  String get close => 'Lukk';

  @override
  String get confirm => 'Bekreft';

  @override
  String get remove => 'Fjern';

  @override
  String get save => 'Lagre';

  @override
  String get add => 'Legg til';

  @override
  String get copy => 'Kopier';

  @override
  String get skip => 'Hopp over';

  @override
  String get done => 'Ferdig';

  @override
  String get apply => 'Bruk';

  @override
  String get export => 'Eksporter';

  @override
  String get import => 'Importer';

  @override
  String get homeNewGroup => 'Ny gruppe';

  @override
  String get homeSettings => 'Innstillinger';

  @override
  String get homeSearching => 'Søker i meldinger...';

  @override
  String get homeNoResults => 'Ingen resultater funnet';

  @override
  String get homeNoChatHistory => 'Ingen samtalehistorikk ennå';

  @override
  String homeTransportSwitched(String address) {
    return 'Transport byttet → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name ringer...';
  }

  @override
  String get homeAccept => 'Godta';

  @override
  String get homeDecline => 'Avslå';

  @override
  String get homeLoadEarlier => 'Last inn eldre meldinger';

  @override
  String get homeChats => 'Samtaler';

  @override
  String get homeSelectConversation => 'Velg en samtale';

  @override
  String get homeNoChatsYet => 'Ingen samtaler ennå';

  @override
  String get homeAddContactToStart =>
      'Legg til en kontakt for å begynne å chatte';

  @override
  String get homeNewChat => 'Ny samtale';

  @override
  String get homeNewChatTooltip => 'Ny samtale';

  @override
  String get homeIncomingCallTitle => 'Innkommende samtale';

  @override
  String get homeIncomingGroupCallTitle => 'Innkommende gruppesamtale';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — innkommende gruppesamtale';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Ingen samtaler som matcher \"$query\"';
  }

  @override
  String get homeSectionChats => 'Samtaler';

  @override
  String get homeSectionMessages => 'Meldinger';

  @override
  String get homeDbEncryptionUnavailable =>
      'Databasekryptering utilgjengelig — installer SQLCipher for full beskyttelse';

  @override
  String get chatFileTooLargeGroup =>
      'Filer over 512 KB støttes ikke i gruppesamtaler';

  @override
  String get chatLargeFile => 'Stor fil';

  @override
  String get chatCancel => 'Avbryt';

  @override
  String get chatSend => 'Send';

  @override
  String get chatFileTooLarge =>
      'Filen er for stor — maksimal størrelse er 100 MB';

  @override
  String get chatMicDenied => 'Mikrofontillatelse avslått';

  @override
  String get chatVoiceFailed =>
      'Kunne ikke lagre talemelding — sjekk tilgjengelig lagringsplass';

  @override
  String get chatScheduleFuture => 'Planlagt tidspunkt må være i fremtiden';

  @override
  String get chatToday => 'I dag';

  @override
  String get chatYesterday => 'I går';

  @override
  String get chatEdited => 'redigert';

  @override
  String get chatYou => 'Du';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Denne filen er $size MB. Sending av store filer kan være tregt på noen nettverk. Fortsette?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Sikkerhetnøkkelen til $name har endret seg. Trykk for å verifisere.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Kunne ikke kryptere melding til $name — meldingen ble ikke sendt.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Sikkerhetsnummeret for $name har endret seg. Trykk for å verifisere.';
  }

  @override
  String get chatNoMessagesFound => 'Ingen meldinger funnet';

  @override
  String get chatMessagesE2ee => 'Meldinger er ende-til-ende-kryptert';

  @override
  String get chatSayHello => 'Si hei';

  @override
  String get appBarOnline => 'tilkoblet';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'skriver';

  @override
  String get appBarSearchMessages => 'Søk i meldinger...';

  @override
  String get appBarMute => 'Demp';

  @override
  String get appBarUnmute => 'Slå på lyd';

  @override
  String get appBarMedia => 'Media';

  @override
  String get appBarDisappearing => 'Forsvinnende meldinger';

  @override
  String get appBarDisappearingOn => 'Forsvinnende: på';

  @override
  String get appBarGroupSettings => 'Gruppeinnstillinger';

  @override
  String get appBarSearchTooltip => 'Søk i meldinger';

  @override
  String get appBarVoiceCall => 'Taleanrop';

  @override
  String get appBarVideoCall => 'Videoanrop';

  @override
  String get inputMessage => 'Melding...';

  @override
  String get inputAttachFile => 'Legg ved fil';

  @override
  String get inputSendMessage => 'Send melding';

  @override
  String get inputRecordVoice => 'Ta opp talemelding';

  @override
  String get inputSendVoice => 'Send talemelding';

  @override
  String get inputCancelReply => 'Avbryt svar';

  @override
  String get inputCancelEdit => 'Avbryt redigering';

  @override
  String get inputCancelRecording => 'Avbryt opptak';

  @override
  String get inputRecording => 'Tar opp…';

  @override
  String get inputEditingMessage => 'Redigerer melding';

  @override
  String get inputPhoto => 'Bilde';

  @override
  String get inputVoiceMessage => 'Talemelding';

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
    return '$count planlagt melding$_temp0';
  }

  @override
  String get callInitializing => 'Starter samtale…';

  @override
  String get callConnecting => 'Kobler til…';

  @override
  String get callConnectingRelay => 'Kobler til (relé)…';

  @override
  String get callSwitchingRelay => 'Bytter til relémodus…';

  @override
  String get callConnectionFailed => 'Tilkobling mislyktes';

  @override
  String get callReconnecting => 'Kobler til på nytt…';

  @override
  String get callEnded => 'Samtale avsluttet';

  @override
  String get callLive => 'Direkte';

  @override
  String get callEnd => 'Avslutt';

  @override
  String get callEndCall => 'Legg på';

  @override
  String get callMute => 'Demp';

  @override
  String get callUnmute => 'Slå på lyd';

  @override
  String get callSpeaker => 'Høyttaler';

  @override
  String get callCameraOn => 'Kamera på';

  @override
  String get callCameraOff => 'Kamera av';

  @override
  String get callShareScreen => 'Del skjerm';

  @override
  String get callStopShare => 'Stopp deling';

  @override
  String callTorBackup(String duration) {
    return 'Tor-backup · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor-backup aktiv — primærforbindelse utilgjengelig';

  @override
  String get callDirectFailed =>
      'Direkte tilkobling mislyktes — bytter til relémodus…';

  @override
  String get callTurnUnreachable =>
      'TURN-servere utilgjengelige. Legg til en egen TURN-server i Innstillinger → Avansert.';

  @override
  String get callRelayMode => 'Relémodus aktiv (begrenset nettverk)';

  @override
  String get callStarting => 'Starter samtale…';

  @override
  String get callConnectingToGroup => 'Kobler til gruppen…';

  @override
  String get callGroupOpenedInBrowser => 'Gruppesamtale åpnet i nettleser';

  @override
  String get callCouldNotOpenBrowser => 'Kunne ikke åpne nettleser';

  @override
  String get callInviteLinkSent =>
      'Invitasjonslenke sendt til alle gruppemedlemmer.';

  @override
  String get callOpenLinkManually =>
      'Åpne lenken ovenfor manuelt eller trykk for å prøve igjen.';

  @override
  String get callJitsiNotE2ee =>
      'Jitsi-samtaler er IKKE ende-til-ende-kryptert';

  @override
  String get callRetryOpenBrowser => 'Prøv å åpne nettleser igjen';

  @override
  String get callClose => 'Lukk';

  @override
  String get callCamOn => 'Kamera på';

  @override
  String get callCamOff => 'Kamera av';

  @override
  String get noConnection => 'Ingen tilkobling — meldinger settes i kø';

  @override
  String get connected => 'Tilkoblet';

  @override
  String get connecting => 'Kobler til…';

  @override
  String get disconnected => 'Frakoblet';

  @override
  String get offlineBanner =>
      'Ingen tilkobling — meldinger sendes når du er tilkoblet igjen';

  @override
  String get lanModeBanner =>
      'LAN-modus — Ingen internett · Kun lokalt nettverk';

  @override
  String get probeCheckingNetwork => 'Sjekker nettverkstilkobling…';

  @override
  String get probeDiscoveringRelays => 'Oppdager reléer via felleskataloger…';

  @override
  String get probeStartingTor => 'Starter Tor for oppstart…';

  @override
  String get probeFindingRelaysTor => 'Finner tilgjengelige reléer via Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'er',
      one: '',
    );
    return 'Nettverk klart — $count relé$_temp0 funnet';
  }

  @override
  String get probeNoRelaysFound =>
      'Ingen tilgjengelige reléer funnet — meldinger kan bli forsinket';

  @override
  String get jitsiWarningTitle => 'Ikke ende-til-ende-kryptert';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet-samtaler er ikke kryptert av Pulse. Bruk kun for samtaler som ikke er sensitive.';

  @override
  String get jitsiConfirm => 'Bli med likevel';

  @override
  String get jitsiGroupWarningTitle => 'Ikke ende-til-ende-kryptert';

  @override
  String get jitsiGroupWarningBody =>
      'Denne samtalen har for mange deltakere for det innebygde krypterte mesh-nettverket.\n\nEn Jitsi Meet-lenke vil bli åpnet i nettleseren din. Jitsi er IKKE ende-til-ende-kryptert — serveren kan se samtalen din.';

  @override
  String get jitsiContinueAnyway => 'Fortsett likevel';

  @override
  String get retry => 'Prøv igjen';

  @override
  String get setupCreateAnonymousAccount => 'Opprett en anonym konto';

  @override
  String get setupTapToChangeColor => 'Trykk for å endre farge';

  @override
  String get setupReqMinLength => 'Minst 16 tegn';

  @override
  String get setupReqVariety => '3 av 4: store, små bokstaver, sifre, symboler';

  @override
  String get setupReqMatch => 'Passordene stemmer overens';

  @override
  String get setupYourNickname => 'Ditt kallenavn';

  @override
  String get setupRecoveryPassword => 'Gjenopprettingspassord (min. 16)';

  @override
  String get setupConfirmPassword => 'Bekreft passord';

  @override
  String get setupMin16Chars => 'Minimum 16 tegn';

  @override
  String get setupPasswordsDoNotMatch => 'Passordene samsvarer ikke';

  @override
  String get setupEntropyWeak => 'Svakt';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Sterkt';

  @override
  String get setupEntropyWeakNeedsVariety => 'Svakt (trenger 3 tegntyper)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bits)';
  }

  @override
  String get setupPasswordWarning =>
      'Dette passordet er den eneste måten å gjenopprette kontoen din på. Det finnes ingen server — ingen tilbakestilling av passord. Husk det eller skriv det ned.';

  @override
  String get setupCreateAccount => 'Opprett konto';

  @override
  String get setupAlreadyHaveAccount => 'Har du allerede en konto? ';

  @override
  String get setupRestore => 'Gjenopprett →';

  @override
  String get restoreTitle => 'Gjenopprett konto';

  @override
  String get restoreInfoBanner =>
      'Skriv inn gjenopprettingspassordet ditt — adressen din (Nostr + Session) gjenopprettes automatisk. Kontakter og meldinger var kun lagret lokalt.';

  @override
  String get restoreNewNickname => 'Nytt kallenavn (kan endres senere)';

  @override
  String get restoreButton => 'Gjenopprett konto';

  @override
  String get lockTitle => 'Pulse er låst';

  @override
  String get lockSubtitle => 'Skriv inn passordet ditt for å fortsette';

  @override
  String get lockPasswordHint => 'Passord';

  @override
  String get lockUnlock => 'Lås opp';

  @override
  String get lockPanicHint =>
      'Glemt passordet? Skriv inn panikk-nøkkelen for å slette alle data.';

  @override
  String get lockTooManyAttempts => 'For mange forsøk. Sletter alle data…';

  @override
  String get lockWrongPassword => 'Feil passord';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Feil passord — $attempts/$max forsøk';
  }

  @override
  String get onboardingSkip => 'Hopp over';

  @override
  String get onboardingNext => 'Neste';

  @override
  String get onboardingGetStarted => 'Opprett konto';

  @override
  String get onboardingWelcomeTitle => 'Velkommen til Pulse';

  @override
  String get onboardingWelcomeBody =>
      'En desentralisert, ende-til-ende-kryptert meldingstjeneste.\n\nIngen sentrale servere. Ingen datainnsamling. Ingen bakdører.\nSamtalene dine tilhører bare deg.';

  @override
  String get onboardingTransportTitle => 'Transportagnostisk';

  @override
  String get onboardingTransportBody =>
      'Bruk Firebase, Nostr, eller begge samtidig.\n\nMeldinger rutes automatisk på tvers av nettverk. Innebygd støtte for Tor og I2P for sensurresistens.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Hver melding krypteres med Signal-protokollen (Double Ratchet + X3DH) for fremoverhemmelighold.\n\nI tillegg pakket med Kyber-1024 — en NIST-standardisert post-kvantealgoritme — som beskytter mot fremtidige kvantedatamaskiner.';

  @override
  String get onboardingKeysTitle => 'Du eier nøklene dine';

  @override
  String get onboardingKeysBody =>
      'Identitetsnøklene dine forlater aldri enheten din.\n\nSignal-fingeravtrykk lar deg verifisere kontakter utenfor båndet. TOFU (Trust On First Use) oppdager nøkkelendringer automatisk.';

  @override
  String get onboardingThemeTitle => 'Velg ditt utseende';

  @override
  String get onboardingThemeBody =>
      'Velg et tema og en aksentfarge. Du kan alltid endre dette senere i Innstillinger.';

  @override
  String get contactsNewChat => 'Ny samtale';

  @override
  String get contactsAddContact => 'Legg til kontakt';

  @override
  String get contactsSearchHint => 'Søk...';

  @override
  String get contactsNewGroup => 'Ny gruppe';

  @override
  String get contactsNoContactsYet => 'Ingen kontakter ennå';

  @override
  String get contactsAddHint => 'Trykk + for å legge til noens adresse';

  @override
  String get contactsNoMatch => 'Ingen kontakter samsvarer';

  @override
  String get contactsRemoveTitle => 'Fjern kontakt';

  @override
  String contactsRemoveMessage(String name) {
    return 'Fjerne $name?';
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
  String get bubbleOpenLink => 'Åpne lenke';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Åpne denne URL-en i nettleseren din?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Åpne';

  @override
  String get bubbleSecurityWarning => 'Sikkerhetsadvarsel';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" er en kjørbar filtype. Lagring og kjøring kan skade enheten din. Lagre likevel?';
  }

  @override
  String get bubbleSaveAnyway => 'Lagre likevel';

  @override
  String bubbleSavedTo(String path) {
    return 'Lagret i $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Lagring mislyktes: $error';
  }

  @override
  String get bubbleNotEncrypted => 'IKKE KRYPTERT';

  @override
  String get bubbleCorruptedImage => '[Skadet bilde]';

  @override
  String get bubbleReplyPhoto => 'Bilde';

  @override
  String get bubbleReplyVoice => 'Talemelding';

  @override
  String get bubbleReplyVideo => 'Videomelding';

  @override
  String bubbleReadBy(String names) {
    return 'Lest av $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Lest av $count';
  }

  @override
  String get chatTileTapToStart => 'Trykk for å starte samtale';

  @override
  String get chatTileMessageSent => 'Melding sendt';

  @override
  String get chatTileEncryptedMessage => 'Kryptert melding';

  @override
  String chatTileYouPrefix(String text) {
    return 'Du: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Talemelding';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Talemelding ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Kryptert melding';

  @override
  String get groupNewGroup => 'Ny gruppe';

  @override
  String get groupGroupName => 'Gruppenavn';

  @override
  String get groupSelectMembers => 'Velg medlemmer (min. 2)';

  @override
  String get groupNoContactsYet =>
      'Ingen kontakter ennå. Legg til kontakter først.';

  @override
  String get groupCreate => 'Opprett';

  @override
  String get groupLabel => 'Gruppe';

  @override
  String get profileVerifyIdentity => 'Verifiser identitet';

  @override
  String profileVerifyInstructions(String name) {
    return 'Sammenlign disse fingeravtrykkene med $name over en talesamtale eller personlig. Hvis begge verdiene stemmer på begge enheter, trykk «Merk som verifisert».';
  }

  @override
  String get profileTheirKey => 'Deres nøkkel';

  @override
  String get profileYourKey => 'Din nøkkel';

  @override
  String get profileRemoveVerification => 'Fjern verifisering';

  @override
  String get profileMarkAsVerified => 'Merk som verifisert';

  @override
  String get profileAddressCopied => 'Adresse kopiert';

  @override
  String get profileNoContactsToAdd =>
      'Ingen kontakter å legge til — alle er allerede medlemmer';

  @override
  String get profileAddMembers => 'Legg til medlemmer';

  @override
  String profileAddCount(int count) {
    return 'Legg til ($count)';
  }

  @override
  String get profileRenameGroup => 'Gi gruppen nytt navn';

  @override
  String get profileRename => 'Gi nytt navn';

  @override
  String get profileRemoveMember => 'Fjerne medlem?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Fjerne $name fra denne gruppen?';
  }

  @override
  String get profileKick => 'Spark';

  @override
  String get profileSignalFingerprints => 'Signal-fingeravtrykk';

  @override
  String get profileVerified => 'VERIFISERT';

  @override
  String get profileVerify => 'Verifiser';

  @override
  String get profileEdit => 'Rediger';

  @override
  String get profileNoSession =>
      'Ingen økt etablert ennå — send en melding først.';

  @override
  String get profileFingerprintCopied => 'Fingeravtrykk kopiert';

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
  String get profileVerifySafetyNumber => 'Verifiser sikkerhetsnummer';

  @override
  String get profileShowContactQr => 'Vis kontakt-QR';

  @override
  String profileContactAddress(String name) {
    return 'Adressen til $name';
  }

  @override
  String get profileExportChatHistory => 'Eksporter samtalehistorikk';

  @override
  String profileSavedTo(String path) {
    return 'Lagret i $path';
  }

  @override
  String get profileExportFailed => 'Eksport mislyktes';

  @override
  String get profileClearChatHistory => 'Tøm samtalehistorikk';

  @override
  String get profileDeleteGroup => 'Slett gruppe';

  @override
  String get profileDeleteContact => 'Slett kontakt';

  @override
  String get profileLeaveGroup => 'Forlat gruppe';

  @override
  String get profileLeaveGroupBody =>
      'Du vil bli fjernet fra denne gruppen, og den slettes fra kontaktene dine.';

  @override
  String get groupInviteTitle => 'Gruppeinvitasjon';

  @override
  String groupInviteBody(String from, String group) {
    return '$from inviterte deg til å bli med i \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Godta';

  @override
  String get groupInviteDecline => 'Avslå';

  @override
  String get groupMemberLimitTitle => 'For mange deltakere';

  @override
  String groupMemberLimitBody(int count) {
    return 'Denne gruppen vil ha $count deltakere. Krypterte mesh-samtaler støtter opptil 6. Større grupper faller tilbake til Jitsi (ikke E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Legg til likevel';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name avslå å bli med i \"$group\"';
  }

  @override
  String get transferTitle => 'Overfør til en annen enhet';

  @override
  String get transferInfoBox =>
      'Flytt din Signal-identitet og Nostr-nøkler til en ny enhet.\nSamtaleøkter overføres IKKE — fremoverhemmelighold bevares.';

  @override
  String get transferSendFromThis => 'Send fra denne enheten';

  @override
  String get transferSendSubtitle =>
      'Denne enheten har nøklene. Del en kode med den nye enheten.';

  @override
  String get transferReceiveOnThis => 'Motta på denne enheten';

  @override
  String get transferReceiveSubtitle =>
      'Dette er den nye enheten. Skriv inn koden fra den gamle enheten.';

  @override
  String get transferChooseMethod => 'Velg overføringsmetode';

  @override
  String get transferLan => 'LAN (Samme nettverk)';

  @override
  String get transferLanSubtitle =>
      'Raskt og direkte. Begge enheter må være på samme Wi-Fi.';

  @override
  String get transferNostrRelay => 'Nostr-relé';

  @override
  String get transferNostrRelaySubtitle =>
      'Fungerer over ethvert nettverk via et eksisterende Nostr-relé.';

  @override
  String get transferRelayUrl => 'Relé-URL';

  @override
  String get transferEnterCode => 'Skriv inn overføringskode';

  @override
  String get transferPasteCode => 'Lim inn LAN:... eller NOS:...-kode her';

  @override
  String get transferConnect => 'Koble til';

  @override
  String get transferGenerating => 'Genererer overføringskode…';

  @override
  String get transferShareCode => 'Del denne koden med mottakeren:';

  @override
  String get transferCopyCode => 'Kopier kode';

  @override
  String get transferCodeCopied => 'Kode kopiert til utklippstavlen';

  @override
  String get transferWaitingReceiver => 'Venter på at mottakeren kobler til…';

  @override
  String get transferConnectingSender => 'Kobler til senderen…';

  @override
  String get transferVerifyBoth =>
      'Sammenlign denne koden på begge enhetene.\nHvis de stemmer, er overføringen sikker.';

  @override
  String get transferComplete => 'Overføring fullført';

  @override
  String get transferKeysImported => 'Nøkler importert';

  @override
  String get transferCompleteSenderBody =>
      'Nøklene dine forblir aktive på denne enheten.\nMottakeren kan nå bruke identiteten din.';

  @override
  String get transferCompleteReceiverBody =>
      'Nøkler importert.\nStart appen på nytt for å ta i bruk den nye identiteten.';

  @override
  String get transferRestartApp => 'Start appen på nytt';

  @override
  String get transferFailed => 'Overføring mislyktes';

  @override
  String get transferTryAgain => 'Prøv igjen';

  @override
  String get transferEnterRelayFirst => 'Skriv inn en relé-URL først';

  @override
  String get transferPasteCodeFromSender =>
      'Lim inn overføringskoden fra senderen';

  @override
  String get menuReply => 'Svar';

  @override
  String get menuForward => 'Videresend';

  @override
  String get menuReact => 'Reager';

  @override
  String get menuCopy => 'Kopier';

  @override
  String get menuEdit => 'Rediger';

  @override
  String get menuRetry => 'Prøv igjen';

  @override
  String get menuCancelScheduled => 'Avbryt planlagt';

  @override
  String get menuDelete => 'Slett';

  @override
  String get menuForwardTo => 'Videresend til…';

  @override
  String menuForwardedTo(String name) {
    return 'Videresendt til $name';
  }

  @override
  String get menuScheduledMessages => 'Planlagte meldinger';

  @override
  String get menuNoScheduledMessages => 'Ingen planlagte meldinger';

  @override
  String menuSendsOn(String date) {
    return 'Sendes $date';
  }

  @override
  String get menuDisappearingMessages => 'Forsvinnende meldinger';

  @override
  String get menuDisappearingSubtitle =>
      'Meldinger slettes automatisk etter valgt tid.';

  @override
  String get menuTtlOff => 'Av';

  @override
  String get menuTtl1h => '1 time';

  @override
  String get menuTtl24h => '24 timer';

  @override
  String get menuTtl7d => '7 dager';

  @override
  String get menuAttachPhoto => 'Bilde';

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
    return 'Bilder ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Filer ($count)';
  }

  @override
  String get mediaNoPhotos => 'Ingen bilder ennå';

  @override
  String get mediaNoFiles => 'Ingen filer ennå';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Lagret i Nedlastinger/$name';
  }

  @override
  String get mediaFailedToSave => 'Kunne ikke lagre filen';

  @override
  String get statusNewStatus => 'Ny status';

  @override
  String get statusPublish => 'Publiser';

  @override
  String get statusExpiresIn24h => 'Status utløper om 24 timer';

  @override
  String get statusWhatsOnYourMind => 'Hva tenker du på?';

  @override
  String get statusPhotoAttached => 'Bilde vedlagt';

  @override
  String get statusAttachPhoto => 'Legg ved bilde (valgfritt)';

  @override
  String get statusEnterText => 'Skriv inn tekst for statusen din.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Kunne ikke velge bilde: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Publisering mislyktes: $error';
  }

  @override
  String get panicSetPanicKey => 'Sett panikk-nøkkel';

  @override
  String get panicEmergencySelfDestruct => 'Nød-selvdestruksjon';

  @override
  String get panicIrreversible => 'Denne handlingen kan ikke angres';

  @override
  String get panicWarningBody =>
      'Hvis du skriver inn denne nøkkelen på låseskjermen, slettes ALLE data umiddelbart — meldinger, kontakter, nøkler, identitet. Bruk en nøkkel som er forskjellig fra ditt vanlige passord.';

  @override
  String get panicKeyHint => 'Panikk-nøkkel';

  @override
  String get panicConfirmHint => 'Bekreft panikk-nøkkel';

  @override
  String get panicMinChars => 'Panikk-nøkkelen må være minst 8 tegn';

  @override
  String get panicKeysDoNotMatch => 'Nøklene samsvarer ikke';

  @override
  String get panicSetFailed => 'Kunne ikke lagre panikk-nøkkel — prøv igjen';

  @override
  String get passwordSetAppPassword => 'Sett app-passord';

  @override
  String get passwordProtectsMessages => 'Beskytter meldingene dine i hvile';

  @override
  String get passwordInfoBanner =>
      'Kreves hver gang du åpner Pulse. Hvis det glemmes, kan dataene dine ikke gjenopprettes.';

  @override
  String get passwordHint => 'Passord';

  @override
  String get passwordConfirmHint => 'Bekreft passord';

  @override
  String get passwordSetButton => 'Sett passord';

  @override
  String get passwordSkipForNow => 'Hopp over for nå';

  @override
  String get passwordMinChars => 'Passordet må være minst 8 tegn';

  @override
  String get passwordNeedsVariety =>
      'Må inneholde bokstaver, tall og spesialtegn';

  @override
  String get passwordRequirements =>
      'Min. 8 tegn med bokstaver, tall og et spesialtegn';

  @override
  String get passwordsDoNotMatch => 'Passordene samsvarer ikke';

  @override
  String get profileCardSaved => 'Profil lagret!';

  @override
  String get profileCardE2eeIdentity => 'E2EE-identitet';

  @override
  String get profileCardDisplayName => 'Visningsnavn';

  @override
  String get profileCardDisplayNameHint => 'f.eks. Ola Nordmann';

  @override
  String get profileCardAbout => 'Om';

  @override
  String get profileCardSaveProfile => 'Lagre profil';

  @override
  String get profileCardYourName => 'Ditt navn';

  @override
  String get profileCardAddressCopied => 'Adresse kopiert!';

  @override
  String get profileCardInboxAddress => 'Din innboksadresse';

  @override
  String get profileCardInboxAddresses => 'Dine innboksadresser';

  @override
  String get profileCardShareAllAddresses => 'Del alle adresser (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Del med kontakter så de kan sende deg meldinger.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Alle $count adresser kopiert som én lenke!';
  }

  @override
  String get settingsMyProfile => 'Min profil';

  @override
  String get settingsYourInboxAddress => 'Din innboksadresse';

  @override
  String get settingsMyQrCode => 'Del kontakt';

  @override
  String get settingsMyQrSubtitle =>
      'QR-kode og invitasjonslenke for adressen din';

  @override
  String get settingsShareMyAddress => 'Del min adresse';

  @override
  String get settingsNoAddressYet =>
      'Ingen adresse ennå — lagre innstillingene først';

  @override
  String get settingsInviteLink => 'Invitasjonslenke';

  @override
  String get settingsRawAddress => 'Råadresse';

  @override
  String get settingsCopyLink => 'Kopier lenke';

  @override
  String get settingsCopyAddress => 'Kopier adresse';

  @override
  String get settingsInviteLinkCopied => 'Invitasjonslenke kopiert';

  @override
  String get settingsAppearance => 'Utseende';

  @override
  String get settingsThemeEngine => 'Temamotor';

  @override
  String get settingsThemeEngineSubtitle => 'Tilpass farger og skrifttyper';

  @override
  String get settingsSignalProtocol => 'Signal-protokoll';

  @override
  String get settingsSignalProtocolSubtitle => 'E2EE-nøkler lagres sikkert';

  @override
  String get settingsActive => 'AKTIV';

  @override
  String get settingsIdentityBackup => 'Identitetssikkerhetskopi';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Eksporter eller importer din Signal-identitet';

  @override
  String get settingsIdentityBackupBody =>
      'Eksporter Signal-identitetsnøklene dine til en sikkerhetskopi, eller gjenopprett fra en eksisterende.';

  @override
  String get settingsTransferDevice => 'Overfør til en annen enhet';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Flytt identiteten din via LAN eller Nostr-relé';

  @override
  String get settingsExportIdentity => 'Eksporter identitet';

  @override
  String get settingsExportIdentityBody =>
      'Kopier denne sikkerhetskopikoden og oppbevar den trygt:';

  @override
  String get settingsSaveFile => 'Lagre fil';

  @override
  String get settingsImportIdentity => 'Importer identitet';

  @override
  String get settingsImportIdentityBody =>
      'Lim inn sikkerhetskopikoden din nedenfor. Dette vil overskrive din nåværende identitet.';

  @override
  String get settingsPasteBackupCode => 'Lim inn sikkerhetskopikode her…';

  @override
  String get settingsIdentityImported =>
      'Identitet + kontakter importert! Start appen på nytt for å ta i bruk.';

  @override
  String get settingsSecurity => 'Sikkerhet';

  @override
  String get settingsAppPassword => 'App-passord';

  @override
  String get settingsPasswordEnabled => 'Aktivert — kreves ved hver oppstart';

  @override
  String get settingsPasswordDisabled =>
      'Deaktivert — appen åpnes uten passord';

  @override
  String get settingsChangePassword => 'Endre passord';

  @override
  String get settingsChangePasswordSubtitle =>
      'Oppdater app-låsepassordet ditt';

  @override
  String get settingsSetPanicKey => 'Sett panikk-nøkkel';

  @override
  String get settingsChangePanicKey => 'Endre panikk-nøkkel';

  @override
  String get settingsPanicKeySetSubtitle => 'Oppdater nødslettnøkkel';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Én nøkkel som sletter alle data umiddelbart';

  @override
  String get settingsRemovePanicKey => 'Fjern panikk-nøkkel';

  @override
  String get settingsRemovePanicKeySubtitle => 'Deaktiver nød-selvdestruksjon';

  @override
  String get settingsRemovePanicKeyBody =>
      'Nød-selvdestruksjon deaktiveres. Du kan aktivere den igjen når som helst.';

  @override
  String get settingsDisableAppPassword => 'Deaktiver app-passord';

  @override
  String get settingsEnterCurrentPassword =>
      'Skriv inn ditt nåværende passord for å bekrefte';

  @override
  String get settingsCurrentPassword => 'Nåværende passord';

  @override
  String get settingsIncorrectPassword => 'Feil passord';

  @override
  String get settingsPasswordUpdated => 'Passord oppdatert';

  @override
  String get settingsChangePasswordProceed =>
      'Skriv inn ditt nåværende passord for å fortsette';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsBackupMessages => 'Sikkerhetskopier meldinger';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Eksporter kryptert meldingshistorikk til en fil';

  @override
  String get settingsRestoreMessages => 'Gjenopprett meldinger';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Importer meldinger fra en sikkerhetskopifil';

  @override
  String get settingsExportKeys => 'Eksporter nøkler';

  @override
  String get settingsExportKeysSubtitle =>
      'Lagre identitetsnøkler til en kryptert fil';

  @override
  String get settingsImportKeys => 'Importer nøkler';

  @override
  String get settingsImportKeysSubtitle =>
      'Gjenopprett identitetsnøkler fra en eksportert fil';

  @override
  String get settingsBackupPassword => 'Sikkerhetskopi-passord';

  @override
  String get settingsPasswordCannotBeEmpty => 'Passordet kan ikke være tomt';

  @override
  String get settingsPasswordMin4Chars => 'Passordet må være minst 4 tegn';

  @override
  String get settingsCallsTurn => 'Samtaler og TURN';

  @override
  String get settingsLocalNetwork => 'Lokalt nettverk';

  @override
  String get settingsCensorshipResistance => 'Sensurresistens';

  @override
  String get settingsNetwork => 'Nettverk';

  @override
  String get settingsProxyTunnels => 'Proxy og tunneler';

  @override
  String get settingsTurnServers => 'TURN-servere';

  @override
  String get settingsProviderTitle => 'Leverandør';

  @override
  String get settingsLanFallback => 'LAN-reserveløsning';

  @override
  String get settingsLanFallbackSubtitle =>
      'Send tilstedeværelse og meldinger på lokalt nettverk når internett ikke er tilgjengelig. Deaktiver på upålitelige nettverk (offentlig Wi-Fi).';

  @override
  String get settingsBgDelivery => 'Bakgrunnslevering';

  @override
  String get settingsBgDeliverySubtitle =>
      'Fortsett å motta meldinger når appen er minimert. Viser et vedvarende varsel.';

  @override
  String get settingsYourInboxProvider => 'Din innboksleverandør';

  @override
  String get settingsConnectionDetails => 'Tilkoblingsdetaljer';

  @override
  String get settingsSaveAndConnect => 'Lagre og koble til';

  @override
  String get settingsSecondaryInboxes => 'Sekundære innbokser';

  @override
  String get settingsAddSecondaryInbox => 'Legg til sekundær innboks';

  @override
  String get settingsAdvanced => 'Avansert';

  @override
  String get settingsDiscover => 'Oppdag';

  @override
  String get settingsAbout => 'Om';

  @override
  String get settingsPrivacyPolicy => 'Personvernerklæring';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Hvordan Pulse beskytter dataene dine';

  @override
  String get settingsCrashReporting => 'Krasjrapportering';

  @override
  String get settingsCrashReportingSubtitle =>
      'Send anonyme krasjrapporter for å forbedre Pulse. Ingen meldingsinnhold eller kontakter sendes.';

  @override
  String get settingsCrashReportingEnabled =>
      'Krasjrapportering aktivert — start appen på nytt for å ta i bruk';

  @override
  String get settingsCrashReportingDisabled =>
      'Krasjrapportering deaktivert — start appen på nytt for å ta i bruk';

  @override
  String get settingsSensitiveOperation => 'Sensitiv operasjon';

  @override
  String get settingsSensitiveOperationBody =>
      'Disse nøklene er identiteten din. Alle med denne filen kan utgi seg for å være deg. Oppbevar den sikkert og slett den etter overføring.';

  @override
  String get settingsIUnderstandContinue => 'Jeg forstår, fortsett';

  @override
  String get settingsReplaceIdentity => 'Erstatt identitet?';

  @override
  String get settingsReplaceIdentityBody =>
      'Dette vil overskrive dine nåværende identitetsnøkler. Dine eksisterende Signal-økter blir ugyldige og kontakter må gjenopprette kryptering. Appen må startes på nytt.';

  @override
  String get settingsReplaceKeys => 'Erstatt nøkler';

  @override
  String get settingsKeysImported => 'Nøkler importert';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count nøkler importert. Start appen på nytt for å initialisere med den nye identiteten.';
  }

  @override
  String get settingsRestartNow => 'Start på nytt nå';

  @override
  String get settingsLater => 'Senere';

  @override
  String get profileGroupLabel => 'Gruppe';

  @override
  String get profileAddButton => 'Legg til';

  @override
  String get profileKickButton => 'Spark';

  @override
  String get dataSectionTitle => 'Data';

  @override
  String get dataBackupMessages => 'Sikkerhetskopier meldinger';

  @override
  String get dataBackupPasswordSubtitle =>
      'Velg et passord for å kryptere sikkerhetskopien din.';

  @override
  String get dataBackupConfirmLabel => 'Opprett sikkerhetskopi';

  @override
  String get dataCreatingBackup => 'Oppretter sikkerhetskopi';

  @override
  String get dataBackupPreparing => 'Forbereder...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Eksporterer melding $done av $total...';
  }

  @override
  String get dataBackupSavingFile => 'Lagrer fil...';

  @override
  String get dataSaveMessageBackupDialog => 'Lagre meldingssikkerhetskopi';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Sikkerhetskopi lagret ($count meldinger)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Sikkerhetskopiering mislyktes — ingen data eksportert';

  @override
  String dataBackupFailedError(String error) {
    return 'Sikkerhetskopiering mislyktes: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Velg meldingssikkerhetskopi';

  @override
  String get dataInvalidBackupFile => 'Ugyldig sikkerhetskopifil (for liten)';

  @override
  String get dataNotValidBackupFile => 'Ikke en gyldig Pulse-sikkerhetskopifil';

  @override
  String get dataRestoreMessages => 'Gjenopprett meldinger';

  @override
  String get dataRestorePasswordSubtitle =>
      'Skriv inn passordet som ble brukt til å opprette denne sikkerhetskopien.';

  @override
  String get dataRestoreConfirmLabel => 'Gjenopprett';

  @override
  String get dataRestoringMessages => 'Gjenoppretter meldinger';

  @override
  String get dataRestoreDecrypting => 'Dekrypterer...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Importerer melding $done av $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Gjenoppretting mislyktes — feil passord eller skadet fil';

  @override
  String dataRestoreSuccess(int count) {
    return '$count nye meldinger gjenopprettet';
  }

  @override
  String get dataRestoreNothingNew =>
      'Ingen nye meldinger å importere (alle finnes allerede)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Gjenoppretting mislyktes: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Velg nøkkeleksport';

  @override
  String get dataNotValidKeyFile => 'Ikke en gyldig Pulse-nøkkeleksportfil';

  @override
  String get dataExportKeys => 'Eksporter nøkler';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Velg et passord for å kryptere nøkkeleksporten din.';

  @override
  String get dataExportKeysConfirmLabel => 'Eksporter';

  @override
  String get dataExportingKeys => 'Eksporterer nøkler';

  @override
  String get dataExportingKeysStatus => 'Krypterer identitetsnøkler...';

  @override
  String get dataSaveKeyExportDialog => 'Lagre nøkkeleksport';

  @override
  String dataKeysExportedTo(String path) {
    return 'Nøkler eksportert til:\n$path';
  }

  @override
  String get dataExportFailed => 'Eksport mislyktes — ingen nøkler funnet';

  @override
  String dataExportFailedError(String error) {
    return 'Eksport mislyktes: $error';
  }

  @override
  String get dataImportKeys => 'Importer nøkler';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Skriv inn passordet som ble brukt til å kryptere denne nøkkeleksporten.';

  @override
  String get dataImportKeysConfirmLabel => 'Importer';

  @override
  String get dataImportingKeys => 'Importerer nøkler';

  @override
  String get dataImportingKeysStatus => 'Dekrypterer identitetsnøkler...';

  @override
  String get dataImportFailed =>
      'Import mislyktes — feil passord eller skadet fil';

  @override
  String dataImportFailedError(String error) {
    return 'Import mislyktes: $error';
  }

  @override
  String get securitySectionTitle => 'Sikkerhet';

  @override
  String get securityIncorrectPassword => 'Feil passord';

  @override
  String get securityPasswordUpdated => 'Passord oppdatert';

  @override
  String get appearanceSectionTitle => 'Utseende';

  @override
  String appearanceExportFailed(String error) {
    return 'Eksport mislyktes: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Lagret i $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Lagring mislyktes: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Import mislyktes: $error';
  }

  @override
  String get aboutSectionTitle => 'Om';

  @override
  String get providerPublicKey => 'Offentlig nøkkel';

  @override
  String get providerRelay => 'Relé';

  @override
  String get providerAutoConfigured =>
      'Automatisk konfigurert fra gjenopprettingspassordet ditt. Relé oppdaget automatisk.';

  @override
  String get providerKeyStoredLocally =>
      'Nøkkelen din lagres lokalt i sikker lagring — sendes aldri til noen server.';

  @override
  String get providerSessionInfo =>
      'Session Network — løk-rutet E2EE. Din Session ID genereres automatisk og lagres sikkert. Noder oppdages automatisk fra innebygde frø-noder.';

  @override
  String get providerAdvanced => 'Avansert';

  @override
  String get providerSaveAndConnect => 'Lagre og koble til';

  @override
  String get providerAddSecondaryInbox => 'Legg til sekundær innboks';

  @override
  String get providerSecondaryInboxes => 'Sekundære innbokser';

  @override
  String get providerYourInboxProvider => 'Din innboksleverandør';

  @override
  String get providerConnectionDetails => 'Tilkoblingsdetaljer';

  @override
  String get addContactTitle => 'Legg til kontakt';

  @override
  String get addContactInviteLinkLabel => 'Invitasjonslenke eller adresse';

  @override
  String get addContactTapToPaste => 'Trykk for å lime inn invitasjonslenke';

  @override
  String get addContactPasteTooltip => 'Lim inn fra utklippstavlen';

  @override
  String get addContactAddressDetected => 'Kontaktadresse oppdaget';

  @override
  String addContactRoutesDetected(int count) {
    return '$count ruter oppdaget — SmartRouter velger den raskeste';
  }

  @override
  String get addContactFetchingProfile => 'Henter profil…';

  @override
  String addContactProfileFound(String name) {
    return 'Funnet: $name';
  }

  @override
  String get addContactNoProfileFound => 'Ingen profil funnet';

  @override
  String get addContactDisplayNameLabel => 'Visningsnavn';

  @override
  String get addContactDisplayNameHint => 'Hva vil du kalle dem?';

  @override
  String get addContactAddManually => 'Legg til adresse manuelt';

  @override
  String get addContactButton => 'Legg til kontakt';

  @override
  String get networkDiagnosticsTitle => 'Nettverksdiagnose';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr-reléer';

  @override
  String get networkDiagnosticsDirect => 'Direkte';

  @override
  String get networkDiagnosticsTorOnly => 'Kun Tor';

  @override
  String get networkDiagnosticsBest => 'Beste';

  @override
  String get networkDiagnosticsNone => 'ingen';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Status';

  @override
  String get networkDiagnosticsConnected => 'Tilkoblet';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Kobler til $percent %';
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
  String get networkDiagnosticsTurnServers => 'TURN-servere';

  @override
  String get networkDiagnosticsLastProbe => 'Siste sjekk';

  @override
  String get networkDiagnosticsRunning => 'Kjører...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Kjør diagnose';

  @override
  String get networkDiagnosticsForceReprobe => 'Tving full ny sjekk';

  @override
  String get networkDiagnosticsJustNow => 'nettopp';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes min siden';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours t siden';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days d siden';
  }

  @override
  String get homeNoEch => 'Ingen ECH';

  @override
  String get homeNoEchTooltip =>
      'uTLS-proxy utilgjengelig — ECH deaktivert.\nTLS-fingeravtrykk er synlig for DPI.';

  @override
  String get settingsTitle => 'Innstillinger';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Lagret og tilkoblet $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Innebygd Tor klarte ikke å starte';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon klarte ikke å starte';

  @override
  String get verifyTitle => 'Verifiser sikkerhetsnummer';

  @override
  String get verifyIdentityVerified => 'Identitet verifisert';

  @override
  String get verifyNotYetVerified => 'Ikke verifisert ennå';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Du har verifisert sikkerhetsnummeret til $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Sammenlign disse numrene med $name personlig eller over en pålitelig kanal.';
  }

  @override
  String get verifyExplanation =>
      'Hver samtale har et unikt sikkerhetsnummer. Hvis dere begge ser de samme numrene på enhetene deres, er tilkoblingen verifisert ende-til-ende.';

  @override
  String verifyContactKey(String name) {
    return 'Nøkkelen til $name';
  }

  @override
  String get verifyYourKey => 'Din nøkkel';

  @override
  String get verifyRemoveVerification => 'Fjern verifisering';

  @override
  String get verifyMarkAsVerified => 'Merk som verifisert';

  @override
  String verifyAfterReinstall(String name) {
    return 'Hvis $name installerer appen på nytt, endres sikkerhetsnummeret og verifiseringen fjernes automatisk.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Merk som verifisert kun etter å ha sammenlignet numrene med $name over en talesamtale eller personlig.';
  }

  @override
  String get verifyNoSession =>
      'Ingen krypteringsøkt etablert ennå. Send en melding først for å generere sikkerhetsnumre.';

  @override
  String get verifyNoKeyAvailable => 'Ingen nøkkel tilgjengelig';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label-fingeravtrykk kopiert';
  }

  @override
  String get providerDatabaseUrlLabel => 'Database-URL';

  @override
  String get providerOptionalHint => 'Valgfritt';

  @override
  String get providerWebApiKeyLabel => 'Web API-nøkkel';

  @override
  String get providerOptionalForPublicDb => 'Valgfritt for offentlig database';

  @override
  String get providerRelayUrlLabel => 'Relé-URL';

  @override
  String get providerPrivateKeyLabel => 'Privat nøkkel';

  @override
  String get providerPrivateKeyNsecLabel => 'Privat nøkkel (nsec)';

  @override
  String get providerStorageNodeLabel => 'Lagringsnodé-URL (valgfritt)';

  @override
  String get providerStorageNodeHint => 'La stå tom for innebygde frønoder';

  @override
  String get transferInvalidCodeFormat =>
      'Ukjent kodeformat — må starte med LAN: eller NOS:';

  @override
  String get profileCardFingerprintCopied => 'Fingeravtrykk kopiert';

  @override
  String get profileCardAboutHint => 'Personvern først 🔒';

  @override
  String get profileCardSaveButton => 'Lagre profil';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Eksporter krypterte meldinger, kontakter og avatarer til en fil';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Lyd';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Levert til $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Levert til $count';
  }

  @override
  String get groupStatusDialogTitle => 'Meldingsinfo';

  @override
  String get groupStatusRead => 'Lest';

  @override
  String get groupStatusDelivered => 'Levert';

  @override
  String get groupStatusPending => 'Venter';

  @override
  String get groupStatusNoData => 'Ingen leveringsinformasjon ennå';

  @override
  String get profileTransferAdmin => 'Gjør til administrator';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Gjøre $name til ny administrator?';
  }

  @override
  String get profileTransferAdminBody =>
      'Du mister administratorrettighetene dine. Dette kan ikke angres.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name er nå administrator';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Personvernerklæring';

  @override
  String get privacyOverviewHeading => 'Oversikt';

  @override
  String get privacyOverviewBody =>
      'Pulse er en serverløs, ende-til-ende-kryptert meldingstjeneste. Personvernet ditt er ikke bare en funksjon — det er arkitekturen. Det finnes ingen Pulse-servere. Ingen kontoer lagres noe sted. Ingen data samles inn, sendes til eller lagres av utviklerne.';

  @override
  String get privacyDataCollectionHeading => 'Datainnsamling';

  @override
  String get privacyDataCollectionBody =>
      'Pulse samler inn null personlige data. Spesifikt:\n\n- Ingen e-post, telefonnummer eller ekte navn kreves\n- Ingen analyser, sporing eller telemetri\n- Ingen reklameidentifikatorer\n- Ingen tilgang til kontaktliste\n- Ingen skysikkerhetskopier (meldinger finnes kun på enheten din)\n- Ingen metadata sendes til noen Pulse-server (det finnes ingen)';

  @override
  String get privacyEncryptionHeading => 'Kryptering';

  @override
  String get privacyEncryptionBody =>
      'Alle meldinger krypteres med Signal-protokollen (Double Ratchet med X3DH-nøkkelavtale). Krypteringsnøkler genereres og lagres utelukkende på enheten din. Ingen — inkludert utviklerne — kan lese meldingene dine.';

  @override
  String get privacyNetworkHeading => 'Nettverksarkitektur';

  @override
  String get privacyNetworkBody =>
      'Pulse bruker fødererte transportadaptere (Nostr-reléer, Session/Oxen-tjenestenoder, Firebase Realtime Database, LAN). Disse transportene bærer kun kryptert chiffertekst. Reléoperatører kan se din IP-adresse og trafikkvolum, men kan ikke dekryptere meldingsinnhold.\n\nNår Tor er aktivert, skjules også IP-adressen din for reléoperatører.';

  @override
  String get privacyStunHeading => 'STUN/TURN-servere';

  @override
  String get privacyStunBody =>
      'Tale- og videosamtaler bruker WebRTC med DTLS-SRTP-kryptering. STUN-servere (brukes til å oppdage din offentlige IP for P2P-tilkoblinger) og TURN-servere (brukes til å videresende media når direkte tilkobling mislykkes) kan se din IP-adresse og samtalevarighet, men kan ikke dekryptere samtaleinnhold.\n\nDu kan konfigurere din egen TURN-server i Innstillinger for maksimalt personvern.';

  @override
  String get privacyCrashHeading => 'Krasjrapportering';

  @override
  String get privacyCrashBody =>
      'Hvis Sentry-krasjrapportering er aktivert (via SENTRY_DSN ved bygging), kan anonyme krasjrapporter bli sendt. Disse inneholder ikke meldingsinnhold, kontaktinformasjon eller personlig identifiserbar informasjon. Krasjrapportering kan deaktiveres ved bygging ved å utelate DSN.';

  @override
  String get privacyPasswordHeading => 'Passord og nøkler';

  @override
  String get privacyPasswordBody =>
      'Gjenopprettingspassordet ditt brukes til å utlede kryptografiske nøkler via Argon2id (minnehard KDF). Passordet sendes aldri noe sted. Hvis du mister passordet, kan kontoen din ikke gjenopprettes — det finnes ingen server for tilbakestilling.';

  @override
  String get privacyFontsHeading => 'Skrifttyper';

  @override
  String get privacyFontsBody =>
      'Pulse inkluderer alle skrifttyper lokalt. Ingen forespørsler sendes til Google Fonts eller noen ekstern skrifttjeneste.';

  @override
  String get privacyThirdPartyHeading => 'Tredjepartstjenester';

  @override
  String get privacyThirdPartyBody =>
      'Pulse integrerer ikke med noen reklamenettverk, analyseleverandører, sosiale medieplattformer eller datameglere. De eneste nettverkstilkoblingene går til transportreléene du konfigurerer.';

  @override
  String get privacyOpenSourceHeading => 'Åpen kildekode';

  @override
  String get privacyOpenSourceBody =>
      'Pulse er programvare med åpen kildekode. Du kan granske hele kildekoden for å verifisere disse personvernpåstandene.';

  @override
  String get privacyContactHeading => 'Kontakt';

  @override
  String get privacyContactBody =>
      'For personvernrelaterte spørsmål, opprett en sak i prosjektets kodelager.';

  @override
  String get privacyLastUpdated => 'Sist oppdatert: mars 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Lagring mislyktes: $error';
  }

  @override
  String get themeEngineTitle => 'Temamotor';

  @override
  String get torBuiltInTitle => 'Innebygd Tor';

  @override
  String get torConnectedSubtitle =>
      'Tilkoblet — Nostr rutet via 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Kobler til… $pct %';
  }

  @override
  String get torNotRunning => 'Kjører ikke — trykk for å starte på nytt';

  @override
  String get torDescription =>
      'Ruter Nostr via Tor (Snowflake for sensurerte nettverk)';

  @override
  String get torNetworkDiagnostics => 'Nettverksdiagnose';

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
  String get torPtPlain => 'Vanlig';

  @override
  String get torTimeoutLabel => 'Tidsavbrudd: ';

  @override
  String get torInfoDescription =>
      'Når aktivert, rutes Nostr WebSocket-tilkoblinger gjennom Tor (SOCKS5). Tor Browser lytter på 127.0.0.1:9150. Den frittstående tor-daemonen bruker port 9050. Firebase-tilkoblinger påvirkes ikke.';

  @override
  String get torRouteNostrTitle => 'Rut Nostr via Tor';

  @override
  String get torManagedByBuiltin => 'Administrert av innebygd Tor';

  @override
  String get torActiveRouting => 'Aktiv — Nostr-trafikk rutes gjennom Tor';

  @override
  String get torDisabled => 'Deaktivert';

  @override
  String get torProxySocks5 => 'Tor-proxy (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Proxy-vert';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser: port 9150  •  tor-daemon: port 9050';

  @override
  String get torForceNostrTitle => 'Send meldinger via Tor';

  @override
  String get torForceNostrSubtitle =>
      'Alle Nostr relay-tilkoblinger vil gå gjennom Tor. Tregere, men skjuler IP-en din fra reléer.';

  @override
  String get torForceNostrDisabled => 'Tor må aktiveres først';

  @override
  String get torForcePulseTitle => 'Rut Pulse relay via Tor';

  @override
  String get torForcePulseSubtitle =>
      'Alle Pulse relay-tilkoblinger vil gå gjennom Tor. Tregere, men skjuler IP-en din fra serveren.';

  @override
  String get torForcePulseDisabled => 'Tor må aktiveres først';

  @override
  String get i2pProxySocks5 => 'I2P-proxy (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P bruker SOCKS5 på port 4447 som standard. Koble til et Nostr-relé via I2P-utproxy (f.eks. relay.damus.i2p) for å kommunisere med brukere på alle transporter. Tor har prioritet når begge er aktivert.';

  @override
  String get i2pRouteNostrTitle => 'Rut Nostr via I2P';

  @override
  String get i2pActiveRouting => 'Aktiv — Nostr-trafikk rutes gjennom I2P';

  @override
  String get i2pDisabled => 'Deaktivert';

  @override
  String get i2pProxyHostLabel => 'Proxy-vert';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'I2P-ruter standard SOCKS5-port: 4447';

  @override
  String get customProxySocks5 => 'Egendefinert proxy (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Egendefinert proxy ruter trafikk gjennom din V2Ray/Xray/Shadowsocks. CF Worker fungerer som en personlig relé-proxy på Cloudflare CDN — GFW ser *.workers.dev, ikke det ekte reléet.';

  @override
  String get customSocks5ProxyTitle => 'Egendefinert SOCKS5-proxy';

  @override
  String get customProxyActive => 'Aktiv — trafikk rutes via SOCKS5';

  @override
  String get customProxyDisabled => 'Deaktivert';

  @override
  String get customProxyHostLabel => 'Proxy-vert';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker-domene (valgfritt)';

  @override
  String get customWorkerHelpTitle =>
      'Slik setter du opp et CF Worker-relé (gratis)';

  @override
  String get customWorkerScriptCopied => 'Skript kopiert!';

  @override
  String get customWorkerStep1 =>
      '1. Gå til dash.cloudflare.com → Workers & Pages\n2. Create Worker → lim inn dette skriptet:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → kopier domenet (f.eks. my-relay.user.workers.dev)\n4. Lim inn domenet ovenfor → Lagre\n\nAppen kobler automatisk til: wss://domain/?r=relay_url\nGFW ser: tilkobling til *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Tilkoblet — SOCKS5 på 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Kobler til…';

  @override
  String get psiphonNotRunning => 'Kjører ikke — trykk for å starte på nytt';

  @override
  String get psiphonDescription =>
      'Rask tunnel (~3s oppstart, 2000+ roterende VPS)';

  @override
  String get turnCommunityServers => 'Fellesskapets TURN-servere';

  @override
  String get turnCustomServer => 'Egendefinert TURN-server (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN-servere videresender kun allerede krypterte strømmer (DTLS-SRTP). En reléoperatør ser din IP og trafikkvolum, men kan ikke dekryptere samtaler. TURN brukes kun når direkte P2P mislykkes (~15–20 % av tilkoblinger).';

  @override
  String get turnFreeLabel => 'GRATIS';

  @override
  String get turnServerUrlLabel => 'TURN-server-URL';

  @override
  String get turnServerUrlHint => 'turn:din-server.com:3478 eller turns:...';

  @override
  String get turnUsernameLabel => 'Brukernavn';

  @override
  String get turnPasswordLabel => 'Passord';

  @override
  String get turnOptionalHint => 'Valgfritt';

  @override
  String get turnCustomInfo =>
      'Kjør coturn på en hvilken som helst VPS til \$5/mnd for maksimal kontroll. Påloggingsinfo lagres lokalt.';

  @override
  String get themePickerAppearance => 'Utseende';

  @override
  String get themePickerAccentColor => 'Aksentfarge';

  @override
  String get themeModeLight => 'Lys';

  @override
  String get themeModeDark => 'Mørk';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeDynamicPresets => 'Forhåndsinnstillinger';

  @override
  String get themeDynamicPrimaryColor => 'Primærfarge';

  @override
  String get themeDynamicBorderRadius => 'Kantradius';

  @override
  String get themeDynamicFont => 'Skrifttype';

  @override
  String get themeDynamicAppearance => 'Utseende';

  @override
  String get themeDynamicUiStyle => 'UI-stil';

  @override
  String get themeDynamicUiStyleDescription =>
      'Styrer utseendet på dialoger, brytere og indikatorer.';

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
      'Ugyldig relé-URL. Forventet: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Ugyldig Pulse-server-URL. Forventet: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'Server-URL';

  @override
  String get providerPulseServerUrlHint => 'https://din-server:8443';

  @override
  String get providerPulseInviteLabel => 'Invitasjonskode';

  @override
  String get providerPulseInviteHint => 'Invitasjonskode (hvis påkrevd)';

  @override
  String get providerPulseInfo =>
      'Selvhostet relé. Nøkler utledet fra gjenopprettingspassordet ditt.';

  @override
  String get providerScreenTitle => 'Innbokser';

  @override
  String get providerSecondaryInboxesHeader => 'SEKUNDÆRE INNBOKSER';

  @override
  String get providerSecondaryInboxesInfo =>
      'Sekundære innbokser mottar meldinger samtidig for redundans.';

  @override
  String get providerRemoveTooltip => 'Fjern';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... eller hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... eller hex privatnøkkel';

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
  String get emojiNoRecent => 'Ingen nylige emojier';

  @override
  String get emojiSearchHint => 'Søk emoji...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Trykk for å chatte';

  @override
  String get imageViewerSaveToDownloads => 'Lagre til Nedlastinger';

  @override
  String imageViewerSavedTo(String path) {
    return 'Lagret i $path';
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
  String get onboardingLanguageTitle => 'Velg språket ditt';

  @override
  String get onboardingLanguageSubtitle =>
      'Du kan endre dette senere i Innstillinger';

  @override
  String get videoNoteRecord => 'Ta opp videomelding';

  @override
  String get videoNoteTapToRecord => 'Trykk for å ta opp';

  @override
  String get videoNoteTapToStop => 'Trykk for å stoppe';

  @override
  String get videoNoteCameraPermission => 'Kameratilgang avslått';

  @override
  String get videoNoteMaxDuration => 'Maks 30 sekunder';

  @override
  String get videoNoteNotSupported =>
      'Videonotater støttes ikke på denne plattformen';

  @override
  String get navChats => 'Samtaler';

  @override
  String get navUpdates => 'Oppdateringer';

  @override
  String get navCalls => 'Samtaler';

  @override
  String get filterAll => 'Alle';

  @override
  String get filterUnread => 'Ulest';

  @override
  String get filterGroups => 'Grupper';

  @override
  String get callsNoRecent => 'Ingen nylige samtaler';

  @override
  String get callsEmptySubtitle => 'Samtaleloggen din vises her';

  @override
  String get appBarEncrypted => 'ende-til-ende kryptert';

  @override
  String get newStatus => 'Ny status';

  @override
  String get newCall => 'Ny samtale';

  @override
  String get joinChannelTitle => 'Bli med i kanal';

  @override
  String get joinChannelDescription => 'KANAL-URL';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'Henter kanalinformasjon…';

  @override
  String get joinChannelNotFound => 'Ingen kanal funnet på denne URLen';

  @override
  String get joinChannelNetworkError => 'Kunne ikke nå serveren';

  @override
  String get joinChannelAlreadyJoined => 'Allerede med';

  @override
  String get joinChannelButton => 'Bli med';

  @override
  String get channelFeedEmpty => 'Ingen innlegg ennå';

  @override
  String get channelLeave => 'Forlat kanal';

  @override
  String get channelLeaveConfirm =>
      'Forlate denne kanalen? Bufrede innlegg vil bli slettet.';

  @override
  String get channelInfo => 'Kanalinfo';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'redigert';

  @override
  String get channelLoadMore => 'Last flere';

  @override
  String get channelSearchPosts => 'Søk i innlegg…';

  @override
  String get channelNoResults => 'Ingen treff';

  @override
  String get channelUrl => 'Kanal-URL';

  @override
  String get channelCreated => 'Ble med';

  @override
  String channelPostCount(int count) {
    return '$count innlegg';
  }

  @override
  String get channelCopyUrl => 'Kopier URL';

  @override
  String get setupNext => 'Neste';

  @override
  String get setupKeyWarning =>
      'A recovery key will be generated for you. It is the only way to restore your account on a new device — there is no server, no password reset.';

  @override
  String get setupKeyTitle => 'Your Recovery Key';

  @override
  String get setupKeySubtitle =>
      'Write this key down and store it in a safe place. You will need it to restore your account on a new device.';

  @override
  String get setupKeyCopied => 'Kopiert!';

  @override
  String get setupKeyWroteItDown => 'Jeg har skrevet den ned';

  @override
  String get setupKeyWarnBody =>
      'Write this key down as a backup. You can also view it later in Settings → Security.';

  @override
  String get setupVerifyTitle => 'Verify Recovery Key';

  @override
  String get setupVerifySubtitle =>
      'Re-enter your recovery key to confirm you saved it correctly.';

  @override
  String get setupVerifyButton => 'Bekreft';

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
  String get settingsViewRecoveryKey => 'Vis gjenopprettingsnøkkel';

  @override
  String get settingsViewRecoveryKeySubtitle =>
      'Vis din kontos gjenopprettingsnøkkel';

  @override
  String get settingsRecoveryKeyNotStored =>
      'Gjenopprettingsnøkkel ikke tilgjengelig (opprettet før denne funksjonen)';

  @override
  String get settingsRecoveryKeyWarning =>
      'Oppbevar denne nøkkelen trygt. Alle som har den, kan gjenopprette kontoen din på en annen enhet.';

  @override
  String get replaceIdentityTitle => 'Erstatte eksisterende identitet?';

  @override
  String get replaceIdentityBodyRestore =>
      'En identitet finnes allerede på denne enheten. Gjenoppretting vil permanent erstatte din nåværende Nostr-nøkkel og Oxen-frø. Alle kontakter vil miste muligheten til å nå din nåværende adresse.\n\nDette kan ikke angres.';

  @override
  String get replaceIdentityBodyCreate =>
      'En identitet finnes allerede på denne enheten. Å opprette en ny vil permanent erstatte din nåværende Nostr-nøkkel og Oxen-frø. Alle kontakter vil miste muligheten til å nå din nåværende adresse.\n\nDette kan ikke angres.';

  @override
  String get replace => 'Erstatt';

  @override
  String get callNoScreenSources => 'Ingen skjermkilder tilgjengelig';

  @override
  String get callScreenShareQuality => 'Kvalitet på skjermdeling';

  @override
  String get callFrameRate => 'Bildefrekvens';

  @override
  String get callResolution => 'Oppløsning';

  @override
  String get callAutoResolution => 'Auto = skjermens opprinnelige oppløsning';

  @override
  String get callStartSharing => 'Start deling';

  @override
  String get callCameraUnavailable =>
      'Kamera utilgjengelig — kan være i bruk av en annen app';

  @override
  String get themeResetToDefaults => 'Tilbakestill til standard';

  @override
  String get backupSaveToDownloadsTitle =>
      'Lagre sikkerhetskopi til Nedlastinger?';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'Filvelger er ikke tilgjengelig. Sikkerhetskopien lagres til:\n$path';
  }

  @override
  String get systemLabel => 'System';

  @override
  String get next => 'Neste';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return '$remaining trykk igjen for å aktivere utviklermodus';
  }

  @override
  String get devModeEnabled => 'Utviklermodus aktivert';

  @override
  String get devTools => 'Utviklerverktøy';

  @override
  String get devAdapterDiagnostics => 'Adaptervekslere og diagnostikk';

  @override
  String get devEnableAll => 'Aktiver alle';

  @override
  String get devDisableAll => 'Deaktiver alle';

  @override
  String get turnUrlValidation =>
      'TURN-URL må starte med turn: eller turns: (maks 512 tegn)';

  @override
  String get callMissedCall => 'Ubesvart samtale';

  @override
  String get callOutgoingCall => 'Utgående samtale';

  @override
  String get callIncomingCall => 'Innkommende samtale';

  @override
  String get mediaMissingData => 'Manglende mediedata';

  @override
  String get mediaDownloadFailed => 'Nedlasting mislyktes';

  @override
  String get mediaDecryptFailed => 'Dekryptering mislyktes';

  @override
  String get callEndCallBanner => 'Avslutt samtale';

  @override
  String get meFallback => 'Meg';

  @override
  String get imageSaveToDownloads => 'Lagre til Nedlastinger';

  @override
  String imageSavedToPath(String path) {
    return 'Lagret til $path';
  }

  @override
  String get callScreenShareRequiresPermission =>
      'Skjermdeling krever tillatelse';

  @override
  String get callScreenShareUnavailable => 'Skjermdeling utilgjengelig';

  @override
  String get statusJustNow => 'Akkurat nå';

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
  String get addContactReadyToAdd => 'Klar til å legge til';

  @override
  String groupSelectedCount(int count) {
    return '$count valgt';
  }

  @override
  String get paste => 'Lim inn';

  @override
  String get sfuAudioOnly => 'Kun lyd';

  @override
  String sfuParticipants(int count) {
    return '$count deltakere';
  }

  @override
  String get dataUnencryptedBackup => 'Ukryptert sikkerhetskopi';

  @override
  String get dataUnencryptedBackupBody =>
      'Denne filen er en ukryptert identitets-sikkerhetskopi og vil overskrive dine nåværende nøkler. Importer kun filer du selv har opprettet. Fortsette?';

  @override
  String get dataImportAnyway => 'Importer likevel';

  @override
  String get securityStorageError =>
      'Sikkerhetslager-feil — start appen på nytt';

  @override
  String get aboutDevModeActive => 'Utviklermodus aktiv';

  @override
  String get themeColors => 'Farger';

  @override
  String get themePrimaryAccent => 'Primæraksent';

  @override
  String get themeSecondaryAccent => 'Sekundæraksent';

  @override
  String get themeBackground => 'Bakgrunn';

  @override
  String get themeSurface => 'Overflate';

  @override
  String get themeChatBubbles => 'Chatbobler';

  @override
  String get themeOutgoingMessage => 'Utgående melding';

  @override
  String get themeIncomingMessage => 'Innkommende melding';

  @override
  String get themeShape => 'Form';

  @override
  String get devSectionDeveloper => 'Utvikler';

  @override
  String get devAdapterChannelsHint =>
      'Adapterkanaler — deaktiver for å teste spesifikke transporter.';

  @override
  String get devNostrRelays => 'Nostr-reléer (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Session Network';

  @override
  String get devPulseRelay => 'Pulse selvhostet relé';

  @override
  String get devLanNetwork => 'Lokalt nettverk (UDP/TCP)';

  @override
  String get devSectionCalls => 'Samtaler';

  @override
  String get devForceTurnRelay => 'Tving TURN-relé';

  @override
  String get devForceTurnRelaySubtitle =>
      'Deaktiver P2P — alle samtaler kun via TURN-servere';

  @override
  String get devRestartWarning =>
      '⚠ Endringer trer i kraft ved neste sending/samtale. Start appen på nytt for å gjelde innkommende.';

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
  String get pulseUseServerTitle => 'Bruke Pulse-server?';

  @override
  String pulseUseServerBody(String name, String host) {
    return '$name bruker Pulse-serveren $host. Bli med for å chatte raskere (og med andre på samme server)?';
  }

  @override
  String pulseContactUsesPulse(String name) {
    return '$name bruker Pulse';
  }

  @override
  String pulseJoinForFaster(String host) {
    return 'Bli med i $host for raskere chat';
  }

  @override
  String get pulseNotNow => 'Ikke nå';

  @override
  String get pulseJoin => 'Bli med';

  @override
  String get pulseDismiss => 'Lukk';

  @override
  String get pulseHide7Days => 'Skjul i 7 dager';

  @override
  String get pulseNeverAskAgain => 'Ikke spør igjen';

  @override
  String get groupSearchContactsHint => 'Søk i kontakter…';

  @override
  String get systemActorYou => 'Du';

  @override
  String get systemActorPeer => 'Kontakt';

  @override
  String systemTtlEnabled(String actor, String duration) {
    return '$actor aktiverte forsvinnende meldinger: $duration';
  }

  @override
  String systemTtlDisabled(String actor) {
    return '$actor deaktiverte forsvinnende meldinger';
  }

  @override
  String get menuClearChatHistory => 'Tøm chatlogg';

  @override
  String get clearChatTitle => 'Tømme chatloggen?';

  @override
  String get clearChatBody =>
      'Alle meldinger i denne chatten slettes fra denne enheten. Den andre personen beholder sin kopi.';

  @override
  String get clearChatAction => 'Tøm';

  @override
  String systemGroupRenamed(String actor, String name) {
    return '$actor ga gruppen nytt navn \"$name\"';
  }

  @override
  String systemGroupAvatarChanged(String actor) {
    return '$actor endret gruppebildet';
  }

  @override
  String systemGroupMetaChanged(String actor, String name) {
    return '$actor ga gruppen nytt navn \"$name\" og endret bildet';
  }

  @override
  String get profileInviteLink => 'Invitasjonslenke';

  @override
  String get profileInviteLinkSubtitle => 'Alle med lenken kan bli med';

  @override
  String get profileInviteLinkCopied => 'Invitasjonslenke kopiert';

  @override
  String get groupInviteLinkTitle => 'Bli med i gruppen?';

  @override
  String groupInviteLinkBody(String name, int count) {
    return 'Du er invitert til å bli med i \"$name\" ($count medlemmer).';
  }

  @override
  String get groupInviteLinkJoin => 'Bli med';

  @override
  String get drawerCreateGroup => 'Opprett gruppe';

  @override
  String get drawerJoinGroup => 'Bli med i gruppe';

  @override
  String get drawerJoinGroupByLinkInvalid =>
      'Det ser ikke ut som en Pulse-invitasjonslenke';

  @override
  String get groupModeMeshTitle => 'Vanlig';

  @override
  String groupModeMeshSubtitle(int n) {
    return 'Ingen tjener, opptil $n personer';
  }

  @override
  String get groupModePulseTitle => 'Pulse-server';

  @override
  String groupModePulseSubtitle(int n) {
    return 'Via server, opptil $n personer';
  }

  @override
  String get groupPulseServerHint => 'https://din-pulse-tjener';

  @override
  String get groupPulseServerClosed => 'Lukket tjener (krever invitasjonskode)';

  @override
  String get groupPulseInviteHint => 'Invitasjonskode';

  @override
  String pulseGroupForeignServerBanner(String host) {
    return 'Meldinger rutes via $host';
  }

  @override
  String groupMeshLimitReached(int n) {
    return 'Denne samtaletypen er begrenset til $n personer';
  }
}
