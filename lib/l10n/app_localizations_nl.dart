// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Berichten doorzoeken...';

  @override
  String get search => 'Zoeken';

  @override
  String get clearSearch => 'Zoekopdracht wissen';

  @override
  String get closeSearch => 'Zoeken sluiten';

  @override
  String get moreOptions => 'Meer opties';

  @override
  String get back => 'Terug';

  @override
  String get cancel => 'Annuleren';

  @override
  String get close => 'Sluiten';

  @override
  String get confirm => 'Bevestigen';

  @override
  String get remove => 'Verwijderen';

  @override
  String get save => 'Opslaan';

  @override
  String get add => 'Toevoegen';

  @override
  String get copy => 'Kopiëren';

  @override
  String get skip => 'Overslaan';

  @override
  String get done => 'Klaar';

  @override
  String get apply => 'Toepassen';

  @override
  String get export => 'Exporteren';

  @override
  String get import => 'Importeren';

  @override
  String get homeNewGroup => 'Nieuwe groep';

  @override
  String get homeSettings => 'Instellingen';

  @override
  String get homeSearching => 'Berichten doorzoeken...';

  @override
  String get homeNoResults => 'Geen resultaten gevonden';

  @override
  String get homeNoChatHistory => 'Nog geen chatgeschiedenis';

  @override
  String homeTransportSwitched(String address) {
    return 'Transport gewisseld → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name belt...';
  }

  @override
  String get homeAccept => 'Accepteren';

  @override
  String get homeDecline => 'Weigeren';

  @override
  String get homeLoadEarlier => 'Eerdere berichten laden';

  @override
  String get homeChats => 'Chats';

  @override
  String get homeSelectConversation => 'Selecteer een gesprek';

  @override
  String get homeNoChatsYet => 'Nog geen chats';

  @override
  String get homeAddContactToStart => 'Voeg een contact toe om te beginnen';

  @override
  String get homeNewChat => 'Nieuw Gesprek';

  @override
  String get homeNewChatTooltip => 'Nieuw gesprek';

  @override
  String get homeIncomingCallTitle => 'Inkomend Gesprek';

  @override
  String get homeIncomingGroupCallTitle => 'Inkomend Groepsgesprek';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — inkomend groepsgesprek';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Geen chats passend bij \"$query\"';
  }

  @override
  String get homeSectionChats => 'Chats';

  @override
  String get homeSectionMessages => 'Berichten';

  @override
  String get homeDbEncryptionUnavailable =>
      'Databaseversleuteling niet beschikbaar — installeer SQLCipher voor volledige bescherming';

  @override
  String get chatFileTooLargeGroup =>
      'Bestanden groter dan 512 KB worden niet ondersteund in groepsgesprekken';

  @override
  String get chatLargeFile => 'Groot Bestand';

  @override
  String get chatCancel => 'Annuleren';

  @override
  String get chatSend => 'Verzenden';

  @override
  String get chatFileTooLarge =>
      'Bestand te groot — maximale grootte is 100 MB';

  @override
  String get chatMicDenied => 'Microfoontoestemming geweigerd';

  @override
  String get chatVoiceFailed =>
      'Spraakbericht opslaan mislukt — controleer beschikbare opslag';

  @override
  String get chatScheduleFuture => 'Ingeplande tijd moet in de toekomst liggen';

  @override
  String get chatToday => 'Vandaag';

  @override
  String get chatYesterday => 'Gisteren';

  @override
  String get chatEdited => 'bewerkt';

  @override
  String get chatYou => 'Jij';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Dit bestand is $size MB. Het verzenden van grote bestanden kan traag zijn op sommige netwerken. Doorgaan?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'De beveiligingssleutel van $name is gewijzigd. Tik om te verifiëren.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Kon bericht aan $name niet versleutelen — bericht niet verzonden.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Het veiligheidsnummer voor $name is gewijzigd. Tik om te verifiëren.';
  }

  @override
  String get chatNoMessagesFound => 'Geen berichten gevonden';

  @override
  String get chatMessagesE2ee => 'Berichten zijn end-to-end versleuteld';

  @override
  String get chatSayHello => 'Zeg hallo';

  @override
  String get appBarOnline => 'online';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'aan het typen';

  @override
  String get appBarSearchMessages => 'Berichten doorzoeken...';

  @override
  String get appBarMute => 'Dempen';

  @override
  String get appBarUnmute => 'Dempen opheffen';

  @override
  String get appBarMedia => 'Media';

  @override
  String get appBarDisappearing => 'Verdwijnende berichten';

  @override
  String get appBarDisappearingOn => 'Verdwijnend: aan';

  @override
  String get appBarGroupSettings => 'Groepsinstellingen';

  @override
  String get appBarSearchTooltip => 'Berichten doorzoeken';

  @override
  String get appBarVoiceCall => 'Spraakoproep';

  @override
  String get appBarVideoCall => 'Video-oproep';

  @override
  String get inputMessage => 'Bericht...';

  @override
  String get inputAttachFile => 'Bestand bijvoegen';

  @override
  String get inputSendMessage => 'Bericht verzenden';

  @override
  String get inputRecordVoice => 'Spraakbericht opnemen';

  @override
  String get inputSendVoice => 'Spraakbericht verzenden';

  @override
  String get inputCancelReply => 'Antwoord annuleren';

  @override
  String get inputCancelEdit => 'Bewerking annuleren';

  @override
  String get inputCancelRecording => 'Opname annuleren';

  @override
  String get inputRecording => 'Opnemen…';

  @override
  String get inputEditingMessage => 'Bericht bewerken';

  @override
  String get inputPhoto => 'Foto';

  @override
  String get inputVoiceMessage => 'Spraakbericht';

  @override
  String get inputFile => 'Bestand';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en',
      one: '',
    );
    return '$count ingepland bericht$_temp0';
  }

  @override
  String get callInitializing => 'Oproep initialiseren…';

  @override
  String get callConnecting => 'Verbinding maken…';

  @override
  String get callConnectingRelay => 'Verbinding maken (relay)…';

  @override
  String get callSwitchingRelay => 'Overschakelen naar relaymodus…';

  @override
  String get callConnectionFailed => 'Verbinding mislukt';

  @override
  String get callReconnecting => 'Opnieuw verbinden…';

  @override
  String get callEnded => 'Oproep beëindigd';

  @override
  String get callLive => 'Live';

  @override
  String get callEnd => 'Einde';

  @override
  String get callEndCall => 'Ophangen';

  @override
  String get callMute => 'Dempen';

  @override
  String get callUnmute => 'Dempen opheffen';

  @override
  String get callSpeaker => 'Luidspreker';

  @override
  String get callCameraOn => 'Camera Aan';

  @override
  String get callCameraOff => 'Camera Uit';

  @override
  String get callShareScreen => 'Scherm Delen';

  @override
  String get callStopShare => 'Delen Stoppen';

  @override
  String callTorBackup(String duration) {
    return 'Tor-backup · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor-backup actief — primair pad niet beschikbaar';

  @override
  String get callDirectFailed =>
      'Directe verbinding mislukt — overschakelen naar relaymodus…';

  @override
  String get callTurnUnreachable =>
      'TURN-servers onbereikbaar. Voeg een aangepaste TURN toe in Instellingen → Geavanceerd.';

  @override
  String get callRelayMode => 'Relaymodus actief (beperkt netwerk)';

  @override
  String get callStarting => 'Oproep starten…';

  @override
  String get callConnectingToGroup => 'Verbinden met groep…';

  @override
  String get callGroupOpenedInBrowser => 'Groepsgesprek geopend in browser';

  @override
  String get callCouldNotOpenBrowser => 'Kon browser niet openen';

  @override
  String get callInviteLinkSent =>
      'Uitnodigingslink verzonden naar alle groepsleden.';

  @override
  String get callOpenLinkManually =>
      'Open de bovenstaande link handmatig of tik om opnieuw te proberen.';

  @override
  String get callJitsiNotE2ee =>
      'Jitsi-oproepen zijn NIET end-to-end versleuteld';

  @override
  String get callRetryOpenBrowser => 'Browser opnieuw openen';

  @override
  String get callClose => 'Sluiten';

  @override
  String get callCamOn => 'Camera aan';

  @override
  String get callCamOff => 'Camera uit';

  @override
  String get noConnection =>
      'Geen verbinding — berichten worden in de wachtrij geplaatst';

  @override
  String get connected => 'Verbonden';

  @override
  String get connecting => 'Verbinding maken…';

  @override
  String get disconnected => 'Verbroken';

  @override
  String get offlineBanner =>
      'Geen verbinding — berichten worden verzonden zodra je weer online bent';

  @override
  String get lanModeBanner =>
      'LAN-modus — Geen internet · Alleen lokaal netwerk';

  @override
  String get probeCheckingNetwork => 'Netwerkverbinding controleren…';

  @override
  String get probeDiscoveringRelays =>
      'Relays ontdekken via communitydirectory\'s…';

  @override
  String get probeStartingTor => 'Tor starten voor bootstrap…';

  @override
  String get probeFindingRelaysTor => 'Bereikbare relays zoeken via Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'Netwerk gereed — $count relay$_temp0 gevonden';
  }

  @override
  String get probeNoRelaysFound =>
      'Geen bereikbare relays gevonden — berichten kunnen vertraagd worden';

  @override
  String get jitsiWarningTitle => 'Niet end-to-end versleuteld';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet-oproepen worden niet versleuteld door Pulse. Gebruik alleen voor niet-gevoelige gesprekken.';

  @override
  String get jitsiConfirm => 'Toch deelnemen';

  @override
  String get jitsiGroupWarningTitle => 'Niet end-to-end versleuteld';

  @override
  String get jitsiGroupWarningBody =>
      'Deze oproep heeft te veel deelnemers voor het ingebouwde versleutelde mesh.\n\nEen Jitsi Meet-link wordt geopend in je browser. Jitsi is NIET end-to-end versleuteld — de server kan je oproep zien.';

  @override
  String get jitsiContinueAnyway => 'Toch doorgaan';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get setupCreateAnonymousAccount => 'Anoniem account aanmaken';

  @override
  String get setupTapToChangeColor => 'Tik om kleur te wijzigen';

  @override
  String get setupReqMinLength => 'At least 16 characters';

  @override
  String get setupReqVariety => '3 of 4: uppercase, lowercase, digits, symbols';

  @override
  String get setupReqMatch => 'Passwords match';

  @override
  String get setupYourNickname => 'Je bijnaam';

  @override
  String get setupRecoveryPassword => 'Herstelwachtwoord (min. 16)';

  @override
  String get setupConfirmPassword => 'Wachtwoord bevestigen';

  @override
  String get setupMin16Chars => 'Minimaal 16 tekens';

  @override
  String get setupPasswordsDoNotMatch => 'Wachtwoorden komen niet overeen';

  @override
  String get setupEntropyWeak => 'Zwak';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Sterk';

  @override
  String get setupEntropyWeakNeedsVariety => 'Zwak (3 tekentypes nodig)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bits)';
  }

  @override
  String get setupPasswordWarning =>
      'Dit wachtwoord is de enige manier om je account te herstellen. Er is geen server — geen wachtwoordreset. Onthoud het of schrijf het op.';

  @override
  String get setupCreateAccount => 'Account aanmaken';

  @override
  String get setupAlreadyHaveAccount => 'Heb je al een account? ';

  @override
  String get setupRestore => 'Herstellen →';

  @override
  String get restoreTitle => 'Account herstellen';

  @override
  String get restoreInfoBanner =>
      'Voer je herstelwachtwoord in — je adres (Nostr + Session) wordt automatisch hersteld. Contacten en berichten waren alleen lokaal opgeslagen.';

  @override
  String get restoreNewNickname =>
      'Nieuwe bijnaam (kan later gewijzigd worden)';

  @override
  String get restoreButton => 'Account herstellen';

  @override
  String get lockTitle => 'Pulse is vergrendeld';

  @override
  String get lockSubtitle => 'Voer je wachtwoord in om door te gaan';

  @override
  String get lockPasswordHint => 'Wachtwoord';

  @override
  String get lockUnlock => 'Ontgrendelen';

  @override
  String get lockPanicHint =>
      'Wachtwoord vergeten? Voer je panieknoodsleutel in om alle gegevens te wissen.';

  @override
  String get lockTooManyAttempts =>
      'Te veel pogingen. Alle gegevens worden gewist…';

  @override
  String get lockWrongPassword => 'Verkeerd wachtwoord';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Verkeerd wachtwoord — $attempts/$max pogingen';
  }

  @override
  String get onboardingSkip => 'Overslaan';

  @override
  String get onboardingNext => 'Volgende';

  @override
  String get onboardingGetStarted => 'Aan de slag';

  @override
  String get onboardingWelcomeTitle => 'Welkom bij Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Een gedecentraliseerde, end-to-end versleutelde messenger.\n\nGeen centrale servers. Geen gegevensverzameling. Geen achterdeuren.\nJe gesprekken zijn alleen van jou.';

  @override
  String get onboardingTransportTitle => 'Transportagnostisch';

  @override
  String get onboardingTransportBody =>
      'Gebruik Firebase, Nostr, of beide tegelijkertijd.\n\nBerichten worden automatisch via netwerken gerouteerd. Ingebouwde Tor- en I2P-ondersteuning voor censuurbestendigheid.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Elk bericht is versleuteld met het Signal Protocol (Double Ratchet + X3DH) voor forward secrecy.\n\nDaarbovenop verpakt met Kyber-1024 — een NIST-standaard post-quantum algoritme — ter bescherming tegen toekomstige kwantumcomputers.';

  @override
  String get onboardingKeysTitle => 'Jij bezit je sleutels';

  @override
  String get onboardingKeysBody =>
      'Je identiteitssleutels verlaten nooit je apparaat.\n\nSignal-vingerafdrukken laten je contacten out-of-band verifiëren. TOFU (Trust On First Use) detecteert sleutelwijzigingen automatisch.';

  @override
  String get onboardingThemeTitle => 'Kies je stijl';

  @override
  String get onboardingThemeBody =>
      'Kies een thema en accentkleur. Je kunt dit later altijd wijzigen in Instellingen.';

  @override
  String get contactsNewChat => 'Nieuw gesprek';

  @override
  String get contactsAddContact => 'Contact toevoegen';

  @override
  String get contactsSearchHint => 'Zoeken...';

  @override
  String get contactsNewGroup => 'Nieuwe groep';

  @override
  String get contactsNoContactsYet => 'Nog geen contacten';

  @override
  String get contactsAddHint => 'Tik op + om iemands adres toe te voegen';

  @override
  String get contactsNoMatch => 'Geen overeenkomende contacten';

  @override
  String get contactsRemoveTitle => 'Contact verwijderen';

  @override
  String contactsRemoveMessage(String name) {
    return '$name verwijderen?';
  }

  @override
  String get contactsRemove => 'Verwijderen';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en',
      one: '',
    );
    return '$count contact$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Link Openen';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Deze URL openen in je browser?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Openen';

  @override
  String get bubbleSecurityWarning => 'Beveiligingswaarschuwing';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" is een uitvoerbaar bestandstype. Het opslaan en uitvoeren kan je apparaat beschadigen. Toch opslaan?';
  }

  @override
  String get bubbleSaveAnyway => 'Toch Opslaan';

  @override
  String bubbleSavedTo(String path) {
    return 'Opgeslagen naar $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Opslaan mislukt: $error';
  }

  @override
  String get bubbleNotEncrypted => 'NIET VERSLEUTELD';

  @override
  String get bubbleCorruptedImage => '[Beschadigd beeld]';

  @override
  String get bubbleReplyPhoto => 'Foto';

  @override
  String get bubbleReplyVoice => 'Spraakbericht';

  @override
  String get bubbleReplyVideo => 'Videobericht';

  @override
  String bubbleReadBy(String names) {
    return 'Gelezen door $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Gelezen door $count';
  }

  @override
  String get chatTileTapToStart => 'Tik om te beginnen met chatten';

  @override
  String get chatTileMessageSent => 'Bericht verzonden';

  @override
  String get chatTileEncryptedMessage => 'Versleuteld bericht';

  @override
  String chatTileYouPrefix(String text) {
    return 'Jij: $text';
  }

  @override
  String get bannerEncryptedMessage => 'Versleuteld bericht';

  @override
  String get groupNewGroup => 'Nieuwe Groep';

  @override
  String get groupGroupName => 'Groepsnaam';

  @override
  String get groupSelectMembers => 'Selecteer leden (min 2)';

  @override
  String get groupNoContactsYet =>
      'Nog geen contacten. Voeg eerst contacten toe.';

  @override
  String get groupCreate => 'Aanmaken';

  @override
  String get groupLabel => 'Groep';

  @override
  String get profileVerifyIdentity => 'Identiteit Verifiëren';

  @override
  String profileVerifyInstructions(String name) {
    return 'Vergelijk deze vingerafdrukken met $name via een spraakoproep of persoonlijk. Als beide waarden overeenkomen op beide apparaten, tik op \"Markeren als Geverifieerd\".';
  }

  @override
  String get profileTheirKey => 'Hun sleutel';

  @override
  String get profileYourKey => 'Jouw sleutel';

  @override
  String get profileRemoveVerification => 'Verificatie Verwijderen';

  @override
  String get profileMarkAsVerified => 'Markeren als Geverifieerd';

  @override
  String get profileAddressCopied => 'Adres gekopieerd';

  @override
  String get profileNoContactsToAdd =>
      'Geen contacten om toe te voegen — allemaal al lid';

  @override
  String get profileAddMembers => 'Leden Toevoegen';

  @override
  String profileAddCount(int count) {
    return 'Toevoegen ($count)';
  }

  @override
  String get profileRenameGroup => 'Groep Hernoemen';

  @override
  String get profileRename => 'Hernoemen';

  @override
  String get profileRemoveMember => 'Lid verwijderen?';

  @override
  String profileRemoveMemberBody(String name) {
    return '$name uit deze groep verwijderen?';
  }

  @override
  String get profileKick => 'Verwijderen';

  @override
  String get profileSignalFingerprints => 'Signal-vingerafdrukken';

  @override
  String get profileVerified => 'GEVERIFIEERD';

  @override
  String get profileVerify => 'Verifiëren';

  @override
  String get profileEdit => 'Bewerken';

  @override
  String get profileNoSession =>
      'Nog geen sessie opgebouwd — stuur eerst een bericht.';

  @override
  String get profileFingerprintCopied => 'Vingerafdruk gekopieerd';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'leden',
      one: '',
    );
    return '$count lid$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Veiligheidsnummer Verifiëren';

  @override
  String get profileShowContactQr => 'Contact-QR Tonen';

  @override
  String profileContactAddress(String name) {
    return 'Adres van $name';
  }

  @override
  String get profileExportChatHistory => 'Chatgeschiedenis Exporteren';

  @override
  String profileSavedTo(String path) {
    return 'Opgeslagen naar $path';
  }

  @override
  String get profileExportFailed => 'Export mislukt';

  @override
  String get profileClearChatHistory => 'Chatgeschiedenis wissen';

  @override
  String get profileDeleteGroup => 'Groep verwijderen';

  @override
  String get profileDeleteContact => 'Contact verwijderen';

  @override
  String get profileLeaveGroup => 'Groep verlaten';

  @override
  String get profileLeaveGroupBody =>
      'Je wordt uit deze groep verwijderd en de groep wordt verwijderd uit je contacten.';

  @override
  String get groupInviteTitle => 'Groepsuitnodiging';

  @override
  String groupInviteBody(String from, String group) {
    return '$from heeft je uitgenodigd om \"$group\" te betreden';
  }

  @override
  String get groupInviteAccept => 'Accepteren';

  @override
  String get groupInviteDecline => 'Weigeren';

  @override
  String get groupMemberLimitTitle => 'Te veel deelnemers';

  @override
  String groupMemberLimitBody(int count) {
    return 'Deze groep zal $count deelnemers hebben. Versleutelde mesh-oproepen ondersteunen maximaal 6. Grotere groepen vallen terug op Jitsi (niet E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Toch toevoegen';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name heeft geweigerd om \"$group\" te betreden';
  }

  @override
  String get transferTitle => 'Overdragen naar Ander Apparaat';

  @override
  String get transferInfoBox =>
      'Verplaats je Signal-identiteit en Nostr-sleutels naar een nieuw apparaat.\nChatsessies worden NIET overgedragen — forward secrecy blijft behouden.';

  @override
  String get transferSendFromThis => 'Verzenden vanaf dit apparaat';

  @override
  String get transferSendSubtitle =>
      'Dit apparaat heeft de sleutels. Deel een code met het nieuwe apparaat.';

  @override
  String get transferReceiveOnThis => 'Ontvangen op dit apparaat';

  @override
  String get transferReceiveSubtitle =>
      'Dit is het nieuwe apparaat. Voer de code van het oude apparaat in.';

  @override
  String get transferChooseMethod => 'Kies Overdrachtsmethode';

  @override
  String get transferLan => 'LAN (Zelfde Netwerk)';

  @override
  String get transferLanSubtitle =>
      'Snel en direct. Beide apparaten moeten op hetzelfde Wi-Fi zijn.';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'Werkt via elk netwerk via een bestaand Nostr relay.';

  @override
  String get transferRelayUrl => 'Relay-URL';

  @override
  String get transferEnterCode => 'Voer Overdrachtscode In';

  @override
  String get transferPasteCode => 'Plak hier de LAN:... of NOS:...-code';

  @override
  String get transferConnect => 'Verbinden';

  @override
  String get transferGenerating => 'Overdrachtscode genereren…';

  @override
  String get transferShareCode => 'Deel deze code met de ontvanger:';

  @override
  String get transferCopyCode => 'Code Kopiëren';

  @override
  String get transferCodeCopied => 'Code gekopieerd naar klembord';

  @override
  String get transferWaitingReceiver => 'Wachten op verbinding van ontvanger…';

  @override
  String get transferConnectingSender => 'Verbinden met verzender…';

  @override
  String get transferVerifyBoth =>
      'Vergelijk deze code op beide apparaten.\nAls ze overeenkomen, is de overdracht veilig.';

  @override
  String get transferComplete => 'Overdracht Voltooid';

  @override
  String get transferKeysImported => 'Sleutels Geïmporteerd';

  @override
  String get transferCompleteSenderBody =>
      'Je sleutels blijven actief op dit apparaat.\nDe ontvanger kan nu je identiteit gebruiken.';

  @override
  String get transferCompleteReceiverBody =>
      'Sleutels succesvol geïmporteerd.\nHerstart de app om de nieuwe identiteit toe te passen.';

  @override
  String get transferRestartApp => 'App Herstarten';

  @override
  String get transferFailed => 'Overdracht Mislukt';

  @override
  String get transferTryAgain => 'Opnieuw Proberen';

  @override
  String get transferEnterRelayFirst => 'Voer eerst een relay-URL in';

  @override
  String get transferPasteCodeFromSender =>
      'Plak de overdrachtscode van de verzender';

  @override
  String get menuReply => 'Beantwoorden';

  @override
  String get menuForward => 'Doorsturen';

  @override
  String get menuReact => 'Reageren';

  @override
  String get menuCopy => 'Kopiëren';

  @override
  String get menuEdit => 'Bewerken';

  @override
  String get menuRetry => 'Opnieuw proberen';

  @override
  String get menuCancelScheduled => 'Ingepland annuleren';

  @override
  String get menuDelete => 'Verwijderen';

  @override
  String get menuForwardTo => 'Doorsturen naar…';

  @override
  String menuForwardedTo(String name) {
    return 'Doorgestuurd naar $name';
  }

  @override
  String get menuScheduledMessages => 'Ingeplande berichten';

  @override
  String get menuNoScheduledMessages => 'Geen ingeplande berichten';

  @override
  String menuSendsOn(String date) {
    return 'Wordt verzonden op $date';
  }

  @override
  String get menuDisappearingMessages => 'Verdwijnende Berichten';

  @override
  String get menuDisappearingSubtitle =>
      'Berichten worden automatisch verwijderd na de geselecteerde tijd.';

  @override
  String get menuTtlOff => 'Uit';

  @override
  String get menuTtl1h => '1 uur';

  @override
  String get menuTtl24h => '24 uur';

  @override
  String get menuTtl7d => '7 dagen';

  @override
  String get menuAttachPhoto => 'Foto';

  @override
  String get menuAttachFile => 'Bestand';

  @override
  String get menuAttachVideo => 'Video';

  @override
  String get mediaTitle => 'Media';

  @override
  String get mediaFileLabel => 'BESTAND';

  @override
  String mediaPhotosTab(int count) {
    return 'Foto\'s ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Bestanden ($count)';
  }

  @override
  String get mediaNoPhotos => 'Nog geen foto\'s';

  @override
  String get mediaNoFiles => 'Nog geen bestanden';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Opgeslagen naar Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'Bestand opslaan mislukt';

  @override
  String get statusNewStatus => 'Nieuwe Status';

  @override
  String get statusPublish => 'Publiceren';

  @override
  String get statusExpiresIn24h => 'Status verloopt over 24 uur';

  @override
  String get statusWhatsOnYourMind => 'Waar denk je aan?';

  @override
  String get statusPhotoAttached => 'Foto bijgevoegd';

  @override
  String get statusAttachPhoto => 'Foto bijvoegen (optioneel)';

  @override
  String get statusEnterText => 'Voer tekst in voor je status.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Foto kiezen mislukt: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Publiceren mislukt: $error';
  }

  @override
  String get panicSetPanicKey => 'Panieknoodsleutel Instellen';

  @override
  String get panicEmergencySelfDestruct => 'Nood-zelfvernietiging';

  @override
  String get panicIrreversible => 'Deze actie is onomkeerbaar';

  @override
  String get panicWarningBody =>
      'Het invoeren van deze sleutel op het vergrendelscherm wist onmiddellijk ALLE gegevens — berichten, contacten, sleutels, identiteit. Gebruik een andere sleutel dan je gewone wachtwoord.';

  @override
  String get panicKeyHint => 'Panieknoodsleutel';

  @override
  String get panicConfirmHint => 'Panieknoodsleutel bevestigen';

  @override
  String get panicMinChars =>
      'Panieknoodsleutel moet minstens 8 tekens lang zijn';

  @override
  String get panicKeysDoNotMatch => 'Sleutels komen niet overeen';

  @override
  String get panicSetFailed =>
      'Panieknoodsleutel opslaan mislukt — probeer het opnieuw';

  @override
  String get passwordSetAppPassword => 'App-wachtwoord Instellen';

  @override
  String get passwordProtectsMessages => 'Beschermt je berichten in rust';

  @override
  String get passwordInfoBanner =>
      'Vereist elke keer dat je Pulse opent. Als je het vergeet, kunnen je gegevens niet worden hersteld.';

  @override
  String get passwordHint => 'Wachtwoord';

  @override
  String get passwordConfirmHint => 'Wachtwoord bevestigen';

  @override
  String get passwordSetButton => 'Wachtwoord Instellen';

  @override
  String get passwordSkipForNow => 'Voorlopig overslaan';

  @override
  String get passwordMinChars => 'Wachtwoord moet minstens 6 tekens lang zijn';

  @override
  String get passwordsDoNotMatch => 'Wachtwoorden komen niet overeen';

  @override
  String get profileCardSaved => 'Profiel opgeslagen!';

  @override
  String get profileCardE2eeIdentity => 'E2EE-identiteit';

  @override
  String get profileCardDisplayName => 'Weergavenaam';

  @override
  String get profileCardDisplayNameHint => 'bijv. Jan de Vries';

  @override
  String get profileCardAbout => 'Over';

  @override
  String get profileCardSaveProfile => 'Profiel Opslaan';

  @override
  String get profileCardYourName => 'Je Naam';

  @override
  String get profileCardAddressCopied => 'Adres gekopieerd!';

  @override
  String get profileCardInboxAddress => 'Je Inboxadres';

  @override
  String get profileCardInboxAddresses => 'Je Inboxadressen';

  @override
  String get profileCardShareAllAddresses =>
      'Alle Adressen Delen (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Deel met contacten zodat ze je berichten kunnen sturen.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Alle $count adressen gekopieerd als één link!';
  }

  @override
  String get settingsMyProfile => 'Mijn Profiel';

  @override
  String get settingsYourInboxAddress => 'Je Inboxadres';

  @override
  String get settingsMyQrCode => 'Mijn QR-code';

  @override
  String get settingsMyQrSubtitle => 'Deel je adres als een scanbare QR';

  @override
  String get settingsShareMyAddress => 'Mijn Adres Delen';

  @override
  String get settingsNoAddressYet =>
      'Nog geen adres — sla eerst de instellingen op';

  @override
  String get settingsInviteLink => 'Uitnodigingslink';

  @override
  String get settingsRawAddress => 'Rauw Adres';

  @override
  String get settingsCopyLink => 'Link Kopiëren';

  @override
  String get settingsCopyAddress => 'Adres Kopiëren';

  @override
  String get settingsInviteLinkCopied => 'Uitnodigingslink gekopieerd';

  @override
  String get settingsAppearance => 'Uiterlijk';

  @override
  String get settingsThemeEngine => 'Thema-engine';

  @override
  String get settingsThemeEngineSubtitle => 'Kleuren en lettertypen aanpassen';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle =>
      'E2EE-sleutels worden veilig opgeslagen';

  @override
  String get settingsActive => 'ACTIEF';

  @override
  String get settingsIdentityBackup => 'Identiteitsback-up';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Exporteer of importeer je Signal-identiteit';

  @override
  String get settingsIdentityBackupBody =>
      'Exporteer je Signal-identiteitssleutels naar een back-upcode, of herstel van een bestaande.';

  @override
  String get settingsTransferDevice => 'Overdragen naar Ander Apparaat';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Verplaats je identiteit via LAN of Nostr relay';

  @override
  String get settingsExportIdentity => 'Identiteit Exporteren';

  @override
  String get settingsExportIdentityBody =>
      'Kopieer deze back-upcode en bewaar hem veilig:';

  @override
  String get settingsSaveFile => 'Bestand Opslaan';

  @override
  String get settingsImportIdentity => 'Identiteit Importeren';

  @override
  String get settingsImportIdentityBody =>
      'Plak je back-upcode hieronder. Dit overschrijft je huidige identiteit.';

  @override
  String get settingsPasteBackupCode => 'Plak back-upcode hier…';

  @override
  String get settingsIdentityImported =>
      'Identiteit + contacten geïmporteerd! Herstart de app om toe te passen.';

  @override
  String get settingsSecurity => 'Beveiliging';

  @override
  String get settingsAppPassword => 'App-wachtwoord';

  @override
  String get settingsPasswordEnabled => 'Ingeschakeld — vereist bij elke start';

  @override
  String get settingsPasswordDisabled =>
      'Uitgeschakeld — app opent zonder wachtwoord';

  @override
  String get settingsChangePassword => 'Wachtwoord Wijzigen';

  @override
  String get settingsChangePasswordSubtitle =>
      'Je app-vergrendelingswachtwoord bijwerken';

  @override
  String get settingsSetPanicKey => 'Panieknoodsleutel Instellen';

  @override
  String get settingsChangePanicKey => 'Panieknoodsleutel Wijzigen';

  @override
  String get settingsPanicKeySetSubtitle => 'Nood-wissleutel bijwerken';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Eén sleutel die direct alle gegevens wist';

  @override
  String get settingsRemovePanicKey => 'Panieknoodsleutel Verwijderen';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Nood-zelfvernietiging uitschakelen';

  @override
  String get settingsRemovePanicKeyBody =>
      'Nood-zelfvernietiging wordt uitgeschakeld. Je kunt het op elk moment weer inschakelen.';

  @override
  String get settingsDisableAppPassword => 'App-wachtwoord Uitschakelen';

  @override
  String get settingsEnterCurrentPassword =>
      'Voer je huidige wachtwoord in om te bevestigen';

  @override
  String get settingsCurrentPassword => 'Huidig wachtwoord';

  @override
  String get settingsIncorrectPassword => 'Onjuist wachtwoord';

  @override
  String get settingsPasswordUpdated => 'Wachtwoord bijgewerkt';

  @override
  String get settingsChangePasswordProceed =>
      'Voer je huidige wachtwoord in om door te gaan';

  @override
  String get settingsData => 'Gegevens';

  @override
  String get settingsBackupMessages => 'Berichten Back-uppen';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Versleutelde berichtgeschiedenis exporteren naar een bestand';

  @override
  String get settingsRestoreMessages => 'Berichten Herstellen';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Berichten importeren uit een back-upbestand';

  @override
  String get settingsExportKeys => 'Sleutels Exporteren';

  @override
  String get settingsExportKeysSubtitle =>
      'Identiteitssleutels opslaan in een versleuteld bestand';

  @override
  String get settingsImportKeys => 'Sleutels Importeren';

  @override
  String get settingsImportKeysSubtitle =>
      'Identiteitssleutels herstellen uit een geëxporteerd bestand';

  @override
  String get settingsBackupPassword => 'Back-upwachtwoord';

  @override
  String get settingsPasswordCannotBeEmpty => 'Wachtwoord mag niet leeg zijn';

  @override
  String get settingsPasswordMin4Chars =>
      'Wachtwoord moet minstens 4 tekens lang zijn';

  @override
  String get settingsCallsTurn => 'Oproepen & TURN';

  @override
  String get settingsLocalNetwork => 'Lokaal Netwerk';

  @override
  String get settingsCensorshipResistance => 'Censuurbestendigheid';

  @override
  String get settingsNetwork => 'Netwerk';

  @override
  String get settingsProxyTunnels => 'Proxy & Tunnels';

  @override
  String get settingsTurnServers => 'TURN-servers';

  @override
  String get settingsProviderTitle => 'Provider';

  @override
  String get settingsLanFallback => 'LAN-terugval';

  @override
  String get settingsLanFallbackSubtitle =>
      'Zend aanwezigheid en berichten via het lokale netwerk als internet niet beschikbaar is. Schakel uit op onvertrouwde netwerken (openbare Wi-Fi).';

  @override
  String get settingsBgDelivery => 'Achtergrondlevering';

  @override
  String get settingsBgDeliverySubtitle =>
      'Blijf berichten ontvangen als de app geminimaliseerd is. Toont een permanente melding.';

  @override
  String get settingsYourInboxProvider => 'Je Inboxprovider';

  @override
  String get settingsConnectionDetails => 'Verbindingsdetails';

  @override
  String get settingsSaveAndConnect => 'Opslaan & Verbinden';

  @override
  String get settingsSecondaryInboxes => 'Secundaire Inboxen';

  @override
  String get settingsAddSecondaryInbox => 'Secundaire Inbox Toevoegen';

  @override
  String get settingsAdvanced => 'Geavanceerd';

  @override
  String get settingsDiscover => 'Ontdekken';

  @override
  String get settingsAbout => 'Over';

  @override
  String get settingsPrivacyPolicy => 'Privacybeleid';

  @override
  String get settingsPrivacyPolicySubtitle => 'Hoe Pulse je gegevens beschermt';

  @override
  String get settingsCrashReporting => 'Crashrapportage';

  @override
  String get settingsCrashReportingSubtitle =>
      'Stuur anonieme crashrapporten om Pulse te verbeteren. Er worden nooit berichtinhoud of contacten verzonden.';

  @override
  String get settingsCrashReportingEnabled =>
      'Crashrapportage ingeschakeld — herstart app om toe te passen';

  @override
  String get settingsCrashReportingDisabled =>
      'Crashrapportage uitgeschakeld — herstart app om toe te passen';

  @override
  String get settingsSensitiveOperation => 'Gevoelige Bewerking';

  @override
  String get settingsSensitiveOperationBody =>
      'Deze sleutels zijn je identiteit. Iedereen met dit bestand kan zich als jou voordoen. Bewaar het veilig en verwijder het na overdracht.';

  @override
  String get settingsIUnderstandContinue => 'Ik Begrijp Het, Doorgaan';

  @override
  String get settingsReplaceIdentity => 'Identiteit Vervangen?';

  @override
  String get settingsReplaceIdentityBody =>
      'Dit overschrijft je huidige identiteitssleutels. Je bestaande Signal-sessies worden ongeldig en contacten moeten de versleuteling opnieuw opbouwen. De app moet herstart worden.';

  @override
  String get settingsReplaceKeys => 'Sleutels Vervangen';

  @override
  String get settingsKeysImported => 'Sleutels Geïmporteerd';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count sleutels succesvol geïmporteerd. Herstart de app om te initialiseren met de nieuwe identiteit.';
  }

  @override
  String get settingsRestartNow => 'Nu Herstarten';

  @override
  String get settingsLater => 'Later';

  @override
  String get profileGroupLabel => 'Groep';

  @override
  String get profileAddButton => 'Toevoegen';

  @override
  String get profileKickButton => 'Verwijderen';

  @override
  String get dataSectionTitle => 'Gegevens';

  @override
  String get dataBackupMessages => 'Berichten Back-uppen';

  @override
  String get dataBackupPasswordSubtitle =>
      'Kies een wachtwoord om je berichtenback-up te versleutelen.';

  @override
  String get dataBackupConfirmLabel => 'Back-up Aanmaken';

  @override
  String get dataCreatingBackup => 'Back-up Aanmaken';

  @override
  String get dataBackupPreparing => 'Voorbereiden...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Bericht $done van $total exporteren...';
  }

  @override
  String get dataBackupSavingFile => 'Bestand opslaan...';

  @override
  String get dataSaveMessageBackupDialog => 'Berichtenback-up Opslaan';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Back-up opgeslagen ($count berichten)\n$path';
  }

  @override
  String get dataBackupFailed => 'Back-up mislukt — geen gegevens geëxporteerd';

  @override
  String dataBackupFailedError(String error) {
    return 'Back-up mislukt: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Berichtenback-up Selecteren';

  @override
  String get dataInvalidBackupFile => 'Ongeldig back-upbestand (te klein)';

  @override
  String get dataNotValidBackupFile => 'Geen geldig Pulse back-upbestand';

  @override
  String get dataRestoreMessages => 'Berichten Herstellen';

  @override
  String get dataRestorePasswordSubtitle =>
      'Voer het wachtwoord in dat gebruikt is om deze back-up te maken.';

  @override
  String get dataRestoreConfirmLabel => 'Herstellen';

  @override
  String get dataRestoringMessages => 'Berichten Herstellen';

  @override
  String get dataRestoreDecrypting => 'Ontsleutelen...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Bericht $done van $total importeren...';
  }

  @override
  String get dataRestoreFailed =>
      'Herstellen mislukt — verkeerd wachtwoord of beschadigd bestand';

  @override
  String dataRestoreSuccess(int count) {
    return '$count nieuwe berichten hersteld';
  }

  @override
  String get dataRestoreNothingNew =>
      'Geen nieuwe berichten om te importeren (allemaal al aanwezig)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Herstellen mislukt: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Sleutelexport Selecteren';

  @override
  String get dataNotValidKeyFile => 'Geen geldig Pulse sleutelexportbestand';

  @override
  String get dataExportKeys => 'Sleutels Exporteren';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Kies een wachtwoord om je sleutelexport te versleutelen.';

  @override
  String get dataExportKeysConfirmLabel => 'Exporteren';

  @override
  String get dataExportingKeys => 'Sleutels Exporteren';

  @override
  String get dataExportingKeysStatus => 'Identiteitssleutels versleutelen...';

  @override
  String get dataSaveKeyExportDialog => 'Sleutelexport Opslaan';

  @override
  String dataKeysExportedTo(String path) {
    return 'Sleutels geëxporteerd naar:\n$path';
  }

  @override
  String get dataExportFailed => 'Export mislukt — geen sleutels gevonden';

  @override
  String dataExportFailedError(String error) {
    return 'Export mislukt: $error';
  }

  @override
  String get dataImportKeys => 'Sleutels Importeren';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Voer het wachtwoord in dat gebruikt is om deze sleutelexport te versleutelen.';

  @override
  String get dataImportKeysConfirmLabel => 'Importeren';

  @override
  String get dataImportingKeys => 'Sleutels Importeren';

  @override
  String get dataImportingKeysStatus => 'Identiteitssleutels ontsleutelen...';

  @override
  String get dataImportFailed =>
      'Import mislukt — verkeerd wachtwoord of beschadigd bestand';

  @override
  String dataImportFailedError(String error) {
    return 'Import mislukt: $error';
  }

  @override
  String get securitySectionTitle => 'Beveiliging';

  @override
  String get securityIncorrectPassword => 'Onjuist wachtwoord';

  @override
  String get securityPasswordUpdated => 'Wachtwoord bijgewerkt';

  @override
  String get appearanceSectionTitle => 'Uiterlijk';

  @override
  String appearanceExportFailed(String error) {
    return 'Export mislukt: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Opgeslagen naar $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Opslaan mislukt: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Import mislukt: $error';
  }

  @override
  String get aboutSectionTitle => 'Over';

  @override
  String get providerPublicKey => 'Publieke Sleutel';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Automatisch geconfigureerd vanuit je herstelwachtwoord. Relay automatisch ontdekt.';

  @override
  String get providerKeyStoredLocally =>
      'Je sleutel wordt lokaal opgeslagen in beveiligde opslag — nooit naar een server verzonden.';

  @override
  String get providerOxenInfo =>
      'Oxen/Session-netwerk — onion-gerouteerde E2EE. Je Session-ID wordt automatisch gegenereerd en veilig opgeslagen. Nodes automatisch ontdekt via ingebouwde seed-nodes.';

  @override
  String get providerAdvanced => 'Geavanceerd';

  @override
  String get providerSaveAndConnect => 'Opslaan & Verbinden';

  @override
  String get providerAddSecondaryInbox => 'Secundaire Inbox Toevoegen';

  @override
  String get providerSecondaryInboxes => 'Secundaire Inboxen';

  @override
  String get providerYourInboxProvider => 'Je Inboxprovider';

  @override
  String get providerConnectionDetails => 'Verbindingsdetails';

  @override
  String get addContactTitle => 'Contact Toevoegen';

  @override
  String get addContactInviteLinkLabel => 'Uitnodigingslink of Adres';

  @override
  String get addContactTapToPaste => 'Tik om uitnodigingslink te plakken';

  @override
  String get addContactPasteTooltip => 'Plakken vanuit klembord';

  @override
  String get addContactAddressDetected => 'Contactadres gedetecteerd';

  @override
  String addContactRoutesDetected(int count) {
    return '$count routes gedetecteerd — SmartRouter kiest de snelste';
  }

  @override
  String get addContactFetchingProfile => 'Profiel ophalen…';

  @override
  String addContactProfileFound(String name) {
    return 'Gevonden: $name';
  }

  @override
  String get addContactNoProfileFound => 'Geen profiel gevonden';

  @override
  String get addContactDisplayNameLabel => 'Weergavenaam';

  @override
  String get addContactDisplayNameHint => 'Hoe wil je hen noemen?';

  @override
  String get addContactAddManually => 'Adres handmatig toevoegen';

  @override
  String get addContactButton => 'Contact Toevoegen';

  @override
  String get networkDiagnosticsTitle => 'Netwerkdiagnostiek';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr Relays';

  @override
  String get networkDiagnosticsDirect => 'Direct';

  @override
  String get networkDiagnosticsTorOnly => 'Alleen Tor';

  @override
  String get networkDiagnosticsBest => 'Beste';

  @override
  String get networkDiagnosticsNone => 'geen';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Status';

  @override
  String get networkDiagnosticsConnected => 'Verbonden';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Verbinden $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Uit';

  @override
  String get networkDiagnosticsTransport => 'Transport';

  @override
  String get networkDiagnosticsInfrastructure => 'Infrastructuur';

  @override
  String get networkDiagnosticsOxenNodes => 'Oxen-nodes';

  @override
  String get networkDiagnosticsTurnServers => 'TURN-servers';

  @override
  String get networkDiagnosticsLastProbe => 'Laatste controle';

  @override
  String get networkDiagnosticsRunning => 'Bezig...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Diagnostiek Uitvoeren';

  @override
  String get networkDiagnosticsForceReprobe => 'Volledige Hercontrole Forceren';

  @override
  String get networkDiagnosticsJustNow => 'zojuist';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '${minutes}m geleden';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '${hours}u geleden';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '${days}d geleden';
  }

  @override
  String get homeNoEch => 'Geen ECH';

  @override
  String get homeNoEchTooltip =>
      'uTLS-proxy niet beschikbaar — ECH uitgeschakeld.\nTLS-vingerafdruk is zichtbaar voor DPI.';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Opgeslagen & verbonden met $provider';
  }

  @override
  String get settingsTorFailedToStart =>
      'Ingebouwde Tor kon niet worden gestart';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon kon niet worden gestart';

  @override
  String get verifyTitle => 'Veiligheidsnummer Verifiëren';

  @override
  String get verifyIdentityVerified => 'Identiteit Geverifieerd';

  @override
  String get verifyNotYetVerified => 'Nog Niet Geverifieerd';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Je hebt het veiligheidsnummer van $name geverifieerd.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Vergelijk deze nummers met $name persoonlijk of via een vertrouwd kanaal.';
  }

  @override
  String get verifyExplanation =>
      'Elk gesprek heeft een uniek veiligheidsnummer. Als jullie beiden dezelfde nummers zien op jullie apparaten, is je verbinding end-to-end geverifieerd.';

  @override
  String verifyContactKey(String name) {
    return 'Sleutel van $name';
  }

  @override
  String get verifyYourKey => 'Jouw Sleutel';

  @override
  String get verifyRemoveVerification => 'Verificatie Verwijderen';

  @override
  String get verifyMarkAsVerified => 'Markeren als Geverifieerd';

  @override
  String verifyAfterReinstall(String name) {
    return 'Als $name de app opnieuw installeert, verandert het veiligheidsnummer en wordt de verificatie automatisch verwijderd.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Markeer pas als geverifieerd na het vergelijken van nummers met $name via een spraakoproep of persoonlijk.';
  }

  @override
  String get verifyNoSession =>
      'Nog geen versleutelingssessie opgebouwd. Stuur eerst een bericht om veiligheidsnummers te genereren.';

  @override
  String get verifyNoKeyAvailable => 'Geen sleutel beschikbaar';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label-vingerafdruk gekopieerd';
  }

  @override
  String get providerDatabaseUrlLabel => 'Database-URL';

  @override
  String get providerOptionalHint => 'Optioneel';

  @override
  String get providerWebApiKeyLabel => 'Web API-sleutel';

  @override
  String get providerOptionalForPublicDb => 'Optioneel voor openbare database';

  @override
  String get providerRelayUrlLabel => 'Relay-URL';

  @override
  String get providerPrivateKeyLabel => 'Privésleutel';

  @override
  String get providerPrivateKeyNsecLabel => 'Privésleutel (nsec)';

  @override
  String get providerStorageNodeLabel => 'Opslagnode-URL (optioneel)';

  @override
  String get providerStorageNodeHint => 'Laat leeg voor ingebouwde seed-nodes';

  @override
  String get transferInvalidCodeFormat =>
      'Onherkenbaar codeformaat — moet beginnen met LAN: of NOS:';

  @override
  String get profileCardFingerprintCopied => 'Vingerafdruk gekopieerd';

  @override
  String get profileCardAboutHint => 'Privacy eerst 🔒';

  @override
  String get profileCardSaveButton => 'Profiel Opslaan';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Versleutelde berichten, contacten en avatars exporteren naar een bestand';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Audio';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Bezorgd bij $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Bezorgd bij $count';
  }

  @override
  String get groupStatusDialogTitle => 'Berichtinfo';

  @override
  String get groupStatusRead => 'Gelezen';

  @override
  String get groupStatusDelivered => 'Bezorgd';

  @override
  String get groupStatusPending => 'In afwachting';

  @override
  String get groupStatusNoData => 'Nog geen bezorginformatie';

  @override
  String get profileTransferAdmin => 'Admin Maken';

  @override
  String profileTransferAdminConfirm(String name) {
    return '$name de nieuwe admin maken?';
  }

  @override
  String get profileTransferAdminBody =>
      'Je verliest je beheerdersrechten. Dit kan niet ongedaan worden gemaakt.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name is nu de admin';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Privacybeleid';

  @override
  String get privacyOverviewHeading => 'Overzicht';

  @override
  String get privacyOverviewBody =>
      'Pulse is een serverloze, end-to-end versleutelde messenger. Je privacy is niet slechts een functie — het is de architectuur. Er zijn geen Pulse-servers. Er worden nergens accounts opgeslagen. Er worden geen gegevens verzameld, verzonden naar, of opgeslagen door de ontwikkelaars.';

  @override
  String get privacyDataCollectionHeading => 'Gegevensverzameling';

  @override
  String get privacyDataCollectionBody =>
      'Pulse verzamelt nul persoonlijke gegevens. Specifiek:\n\n- Geen e-mail, telefoonnummer of echte naam vereist\n- Geen analyses, tracking of telemetrie\n- Geen advertentie-identifiers\n- Geen toegang tot contactenlijst\n- Geen cloudback-ups (berichten bestaan alleen op je apparaat)\n- Geen metadata wordt naar een Pulse-server verzonden (die bestaan niet)';

  @override
  String get privacyEncryptionHeading => 'Versleuteling';

  @override
  String get privacyEncryptionBody =>
      'Alle berichten zijn versleuteld met het Signal Protocol (Double Ratchet met X3DH sleutelovereenkomst). Versleutelingssleutels worden uitsluitend op je apparaat gegenereerd en opgeslagen. Niemand — inclusief de ontwikkelaars — kan je berichten lezen.';

  @override
  String get privacyNetworkHeading => 'Netwerkarchitectuur';

  @override
  String get privacyNetworkBody =>
      'Pulse gebruikt gefedereerde transportadapters (Nostr relays, Session/Oxen dienstnodes, Firebase Realtime Database, LAN). Deze transporten dragen alleen versleutelde cijfertekst. Relay-operators kunnen je IP-adres en verkeersvolume zien, maar kunnen de berichtinhoud niet ontsleutelen.\n\nWanneer Tor is ingeschakeld, is je IP-adres ook verborgen voor relay-operators.';

  @override
  String get privacyStunHeading => 'STUN/TURN-servers';

  @override
  String get privacyStunBody =>
      'Spraak- en video-oproepen gebruiken WebRTC met DTLS-SRTP-versleuteling. STUN-servers (gebruikt om je publieke IP te ontdekken voor peer-to-peer verbindingen) en TURN-servers (gebruikt om media door te sturen wanneer directe verbinding mislukt) kunnen je IP-adres en gespreksduur zien, maar kunnen de gespreksinhoud niet ontsleutelen.\n\nJe kunt je eigen TURN-server configureren in Instellingen voor maximale privacy.';

  @override
  String get privacyCrashHeading => 'Crashrapportage';

  @override
  String get privacyCrashBody =>
      'Als Sentry-crashrapportage is ingeschakeld (via build-time SENTRY_DSN), kunnen anonieme crashrapporten worden verzonden. Deze bevatten geen berichtinhoud, geen contactinformatie en geen persoonlijk identificeerbare informatie. Crashrapportage kan tijdens het bouwen worden uitgeschakeld door de DSN weg te laten.';

  @override
  String get privacyPasswordHeading => 'Wachtwoord & Sleutels';

  @override
  String get privacyPasswordBody =>
      'Je herstelwachtwoord wordt gebruikt om cryptografische sleutels af te leiden via Argon2id (geheugen-hard KDF). Het wachtwoord wordt nergens naartoe verzonden. Als je je wachtwoord verliest, kan je account niet worden hersteld — er is geen server om het te resetten.';

  @override
  String get privacyFontsHeading => 'Lettertypen';

  @override
  String get privacyFontsBody =>
      'Pulse bundelt alle lettertypen lokaal. Er worden geen verzoeken gedaan naar Google Fonts of een externe lettertypedienst.';

  @override
  String get privacyThirdPartyHeading => 'Diensten van Derden';

  @override
  String get privacyThirdPartyBody =>
      'Pulse integreert niet met advertentienetwerken, analyseproviders, sociale-mediaplatforms of gegevensmakelaars. De enige netwerkverbindingen zijn naar de transportrelays die je configureert.';

  @override
  String get privacyOpenSourceHeading => 'Open Source';

  @override
  String get privacyOpenSourceBody =>
      'Pulse is opensourcesoftware. Je kunt de volledige broncode controleren om deze privacyclaims te verifiëren.';

  @override
  String get privacyContactHeading => 'Contact';

  @override
  String get privacyContactBody =>
      'Voor privacygerelateerde vragen, open een issue op de projectrepository.';

  @override
  String get privacyLastUpdated => 'Laatst bijgewerkt: maart 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Opslaan mislukt: $error';
  }

  @override
  String get themeEngineTitle => 'Thema-engine';

  @override
  String get torBuiltInTitle => 'Ingebouwde Tor';

  @override
  String get torConnectedSubtitle =>
      'Verbonden — Nostr gerouteerd via 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Verbinden… $pct%';
  }

  @override
  String get torNotRunning =>
      'Niet actief — tik op schakelaar om te herstarten';

  @override
  String get torDescription =>
      'Routeert Nostr via Tor (Snowflake voor gecensureerde netwerken)';

  @override
  String get torNetworkDiagnostics => 'Netwerkdiagnostiek';

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
  String get torPtPlain => 'Gewoon';

  @override
  String get torTimeoutLabel => 'Time-out: ';

  @override
  String get torInfoDescription =>
      'Wanneer ingeschakeld, worden Nostr WebSocket-verbindingen via Tor (SOCKS5) gerouteerd. Tor Browser luistert op 127.0.0.1:9150. De standalone tor-daemon gebruikt poort 9050. Firebase-verbindingen worden niet beïnvloed.';

  @override
  String get torRouteNostrTitle => 'Nostr via Tor Routeren';

  @override
  String get torManagedByBuiltin => 'Beheerd door Ingebouwde Tor';

  @override
  String get torActiveRouting =>
      'Actief — Nostr-verkeer wordt via Tor gerouteerd';

  @override
  String get torDisabled => 'Uitgeschakeld';

  @override
  String get torProxySocks5 => 'Tor-proxy (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Proxyhost';

  @override
  String get torProxyPortLabel => 'Poort';

  @override
  String get torPortInfo =>
      'Tor Browser: poort 9150  •  tor-daemon: poort 9050';

  @override
  String get i2pProxySocks5 => 'I2P-proxy (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P gebruikt standaard SOCKS5 op poort 4447. Maak verbinding met een Nostr relay via I2P outproxy (bijv. relay.damus.i2p) om te communiceren met gebruikers op elk transport. Tor heeft voorrang wanneer beide zijn ingeschakeld.';

  @override
  String get i2pRouteNostrTitle => 'Nostr via I2P Routeren';

  @override
  String get i2pActiveRouting =>
      'Actief — Nostr-verkeer wordt via I2P gerouteerd';

  @override
  String get i2pDisabled => 'Uitgeschakeld';

  @override
  String get i2pProxyHostLabel => 'Proxyhost';

  @override
  String get i2pProxyPortLabel => 'Poort';

  @override
  String get i2pPortInfo => 'I2P Router standaard SOCKS5-poort: 4447';

  @override
  String get customProxySocks5 => 'Aangepaste Proxy (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Aangepaste proxy routeert verkeer via je V2Ray/Xray/Shadowsocks. CF Worker fungeert als persoonlijke relayproxy op Cloudflare CDN — GFW ziet *.workers.dev, niet het echte relay.';

  @override
  String get customSocks5ProxyTitle => 'Aangepaste SOCKS5-proxy';

  @override
  String get customProxyActive =>
      'Actief — verkeer wordt via SOCKS5 gerouteerd';

  @override
  String get customProxyDisabled => 'Uitgeschakeld';

  @override
  String get customProxyHostLabel => 'Proxyhost';

  @override
  String get customProxyPortLabel => 'Poort';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Workerdomein (optioneel)';

  @override
  String get customWorkerHelpTitle =>
      'Hoe je een CF Worker relay deployt (gratis)';

  @override
  String get customWorkerScriptCopied => 'Script gekopieerd!';

  @override
  String get customWorkerStep1 =>
      '1. Ga naar dash.cloudflare.com → Workers & Pages\n2. Create Worker → plak dit script:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → kopieer domein (bijv. my-relay.user.workers.dev)\n4. Plak domein hierboven → Opslaan\n\nApp maakt automatisch verbinding: wss://domain/?r=relay_url\nGFW ziet: verbinding naar *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Verbonden — SOCKS5 op 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Verbinding maken…';

  @override
  String get psiphonNotRunning =>
      'Niet actief — tik op schakelaar om te herstarten';

  @override
  String get psiphonDescription =>
      'Snelle tunnel (~3s bootstrap, 2000+ roterende VPS)';

  @override
  String get turnCommunityServers => 'Community TURN-servers';

  @override
  String get turnCustomServer => 'Aangepaste TURN-server (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN-servers sturen alleen al versleutelde streams door (DTLS-SRTP). Een relay-operator ziet je IP en verkeersvolume, maar kan geen oproepen ontsleutelen. TURN wordt alleen gebruikt wanneer direct P2P mislukt (~15–20% van verbindingen).';

  @override
  String get turnFreeLabel => 'GRATIS';

  @override
  String get turnServerUrlLabel => 'TURN-server-URL';

  @override
  String get turnServerUrlHint => 'turn:je-server.com:3478 of turns:...';

  @override
  String get turnUsernameLabel => 'Gebruikersnaam';

  @override
  String get turnPasswordLabel => 'Wachtwoord';

  @override
  String get turnOptionalHint => 'Optioneel';

  @override
  String get turnCustomInfo =>
      'Host zelf coturn op elke \$5/maand VPS voor maximale controle. Inloggegevens worden lokaal opgeslagen.';

  @override
  String get themePickerAppearance => 'Uiterlijk';

  @override
  String get themePickerAccentColor => 'Accentkleur';

  @override
  String get themeModeLight => 'Licht';

  @override
  String get themeModeDark => 'Donker';

  @override
  String get themeModeSystem => 'Systeem';

  @override
  String get themeDynamicPresets => 'Voorinstellingen';

  @override
  String get themeDynamicPrimaryColor => 'Primaire Kleur';

  @override
  String get themeDynamicBorderRadius => 'Randradius';

  @override
  String get themeDynamicFont => 'Lettertype';

  @override
  String get themeDynamicAppearance => 'Uiterlijk';

  @override
  String get themeDynamicUiStyle => 'UI-stijl';

  @override
  String get themeDynamicUiStyleDescription =>
      'Bepaalt hoe dialogen, schakelaars en indicatoren eruitzien.';

  @override
  String get themeDynamicSharp => 'Scherp';

  @override
  String get themeDynamicRound => 'Rond';

  @override
  String get themeDynamicModeDark => 'Donker';

  @override
  String get themeDynamicModeLight => 'Licht';

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
      'Ongeldige Firebase-URL. Verwacht: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Ongeldige relay-URL. Verwacht: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Ongeldige Pulse-server-URL. Verwacht: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'Server-URL';

  @override
  String get providerPulseServerUrlHint => 'https://je-server:8443';

  @override
  String get providerPulseInviteLabel => 'Uitnodigingscode';

  @override
  String get providerPulseInviteHint => 'Uitnodigingscode (indien vereist)';

  @override
  String get providerPulseInfo =>
      'Zelfgehoste relay. Sleutels afgeleid van je herstelwachtwoord.';

  @override
  String get providerScreenTitle => 'Inboxen';

  @override
  String get providerSecondaryInboxesHeader => 'SECUNDAIRE INBOXEN';

  @override
  String get providerSecondaryInboxesInfo =>
      'Secundaire inboxen ontvangen berichten gelijktijdig voor redundantie.';

  @override
  String get providerRemoveTooltip => 'Verwijderen';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... of hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... of hex privésleutel';

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
  String get emojiNoRecent => 'Geen recente emoji\'s';

  @override
  String get emojiSearchHint => 'Emoji zoeken...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Tik om te chatten';

  @override
  String get imageViewerSaveToDownloads => 'Opslaan naar Downloads';

  @override
  String imageViewerSavedTo(String path) {
    return 'Opgeslagen naar $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Taal';

  @override
  String get settingsLanguageSubtitle => 'Weergavetaal van de app';

  @override
  String get settingsLanguageSystem => 'Systeemstandaard';

  @override
  String get onboardingLanguageTitle => 'Kies je taal';

  @override
  String get onboardingLanguageSubtitle =>
      'Je kunt dit later wijzigen in Instellingen';

  @override
  String get videoNoteRecord => 'Videobericht opnemen';

  @override
  String get videoNoteTapToRecord => 'Tik om op te nemen';

  @override
  String get videoNoteTapToStop => 'Tik om te stoppen';

  @override
  String get videoNoteCameraPermission => 'Cameratoegang geweigerd';

  @override
  String get videoNoteMaxDuration => 'Maximaal 30 seconden';

  @override
  String get videoNoteNotSupported =>
      'Videonotities worden niet ondersteund op dit platform';
}
