// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Nachrichten durchsuchen...';

  @override
  String get search => 'Suchen';

  @override
  String get clearSearch => 'Suche löschen';

  @override
  String get closeSearch => 'Suche schließen';

  @override
  String get moreOptions => 'Weitere Optionen';

  @override
  String get back => 'Zurück';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get close => 'Schließen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get remove => 'Entfernen';

  @override
  String get save => 'Speichern';

  @override
  String get add => 'Hinzufügen';

  @override
  String get copy => 'Kopieren';

  @override
  String get skip => 'Überspringen';

  @override
  String get done => 'Fertig';

  @override
  String get apply => 'Anwenden';

  @override
  String get export => 'Exportieren';

  @override
  String get import => 'Importieren';

  @override
  String get homeNewGroup => 'Neue Gruppe';

  @override
  String get homeSettings => 'Einstellungen';

  @override
  String get homeSearching => 'Nachrichten werden durchsucht...';

  @override
  String get homeNoResults => 'Keine Ergebnisse gefunden';

  @override
  String get homeNoChatHistory => 'Noch kein Chatverlauf';

  @override
  String homeTransportSwitched(String address) {
    return 'Transport gewechselt → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name ruft an...';
  }

  @override
  String get homeAccept => 'Annehmen';

  @override
  String get homeDecline => 'Ablehnen';

  @override
  String get homeLoadEarlier => 'Ältere Nachrichten laden';

  @override
  String get homeChats => 'Chats';

  @override
  String get homeSelectConversation => 'Wählen Sie eine Unterhaltung aus';

  @override
  String get homeNoChatsYet => 'Noch keine Chats';

  @override
  String get homeAddContactToStart =>
      'Fügen Sie einen Kontakt hinzu, um loszulegen';

  @override
  String get homeNewChat => 'Neuer Chat';

  @override
  String get homeNewChatTooltip => 'Neuer Chat';

  @override
  String get homeIncomingCallTitle => 'Eingehender Anruf';

  @override
  String get homeIncomingGroupCallTitle => 'Eingehender Gruppenanruf';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — eingehender Gruppenanruf';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Keine Chats passend zu \"$query\"';
  }

  @override
  String get homeSectionChats => 'Chats';

  @override
  String get homeSectionMessages => 'Nachrichten';

  @override
  String get homeDbEncryptionUnavailable =>
      'Datenbankverschlüsselung nicht verfügbar — installieren Sie SQLCipher für vollständigen Schutz';

  @override
  String get chatFileTooLargeGroup =>
      'Dateien über 512 KB werden in Gruppenchats nicht unterstützt';

  @override
  String get chatLargeFile => 'Große Datei';

  @override
  String get chatCancel => 'Abbrechen';

  @override
  String get chatSend => 'Senden';

  @override
  String get chatFileTooLarge =>
      'Datei zu groß — maximale Größe beträgt 100 MB';

  @override
  String get chatMicDenied => 'Mikrofonberechtigung verweigert';

  @override
  String get chatVoiceFailed =>
      'Sprachnachricht konnte nicht gespeichert werden — prüfen Sie den verfügbaren Speicherplatz';

  @override
  String get chatScheduleFuture =>
      'Der geplante Zeitpunkt muss in der Zukunft liegen';

  @override
  String get chatToday => 'Heute';

  @override
  String get chatYesterday => 'Gestern';

  @override
  String get chatEdited => 'bearbeitet';

  @override
  String get chatYou => 'Du';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Diese Datei ist $size MB groß. Das Senden großer Dateien kann in manchen Netzwerken langsam sein. Fortfahren?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Der Sicherheitsschlüssel von $name hat sich geändert. Tippen zum Verifizieren.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Nachricht an $name konnte nicht verschlüsselt werden — Nachricht nicht gesendet.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Die Sicherheitsnummer für $name hat sich geändert. Tippen zum Verifizieren.';
  }

  @override
  String get chatNoMessagesFound => 'Keine Nachrichten gefunden';

  @override
  String get chatMessagesE2ee => 'Nachrichten sind Ende-zu-Ende-verschlüsselt';

  @override
  String get chatSayHello => 'Sag Hallo';

  @override
  String get appBarOnline => 'online';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'tippt';

  @override
  String get appBarSearchMessages => 'Nachrichten durchsuchen...';

  @override
  String get appBarMute => 'Stumm';

  @override
  String get appBarUnmute => 'Ton an';

  @override
  String get appBarMedia => 'Medien';

  @override
  String get appBarDisappearing => 'Verschwindende Nachrichten';

  @override
  String get appBarDisappearingOn => 'Verschwindend: an';

  @override
  String get appBarGroupSettings => 'Gruppeneinstellungen';

  @override
  String get appBarSearchTooltip => 'Nachrichten durchsuchen';

  @override
  String get appBarVoiceCall => 'Sprachanruf';

  @override
  String get appBarVideoCall => 'Videoanruf';

  @override
  String get inputMessage => 'Nachricht...';

  @override
  String get inputAttachFile => 'Datei anhängen';

  @override
  String get inputSendMessage => 'Nachricht senden';

  @override
  String get inputRecordVoice => 'Sprachnachricht aufnehmen';

  @override
  String get inputSendVoice => 'Sprachnachricht senden';

  @override
  String get inputCancelReply => 'Antwort abbrechen';

  @override
  String get inputCancelEdit => 'Bearbeitung abbrechen';

  @override
  String get inputCancelRecording => 'Aufnahme abbrechen';

  @override
  String get inputRecording => 'Aufnahme…';

  @override
  String get inputEditingMessage => 'Nachricht wird bearbeitet';

  @override
  String get inputPhoto => 'Foto';

  @override
  String get inputVoiceMessage => 'Sprachnachricht';

  @override
  String get inputFile => 'Datei';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en',
      one: '',
    );
    return '$count geplante Nachricht$_temp0';
  }

  @override
  String get callInitializing => 'Anruf wird initialisiert…';

  @override
  String get callConnecting => 'Verbindung wird hergestellt…';

  @override
  String get callConnectingRelay => 'Verbindung (Relay)…';

  @override
  String get callSwitchingRelay => 'Wechsel zum Relay-Modus…';

  @override
  String get callConnectionFailed => 'Verbindung fehlgeschlagen';

  @override
  String get callReconnecting => 'Verbindung wird wiederhergestellt…';

  @override
  String get callEnded => 'Anruf beendet';

  @override
  String get callLive => 'Live';

  @override
  String get callEnd => 'Ende';

  @override
  String get callEndCall => 'Auflegen';

  @override
  String get callMute => 'Stumm';

  @override
  String get callUnmute => 'Ton an';

  @override
  String get callSpeaker => 'Lautsprecher';

  @override
  String get callCameraOn => 'Kamera an';

  @override
  String get callCameraOff => 'Kamera aus';

  @override
  String get callShareScreen => 'Bildschirm teilen';

  @override
  String get callStopShare => 'Teilen beenden';

  @override
  String callTorBackup(String duration) {
    return 'Tor-Backup · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor-Backup aktiv — primärer Pfad nicht verfügbar';

  @override
  String get callDirectFailed =>
      'Direkte Verbindung fehlgeschlagen — Wechsel zum Relay-Modus…';

  @override
  String get callTurnUnreachable =>
      'TURN-Server nicht erreichbar. Fügen Sie einen eigenen TURN-Server in Einstellungen → Erweitert hinzu.';

  @override
  String get callRelayMode => 'Relay-Modus aktiv (eingeschränktes Netzwerk)';

  @override
  String get callStarting => 'Anruf wird gestartet…';

  @override
  String get callConnectingToGroup => 'Verbindung zur Gruppe…';

  @override
  String get callGroupOpenedInBrowser => 'Gruppenanruf im Browser geöffnet';

  @override
  String get callCouldNotOpenBrowser => 'Browser konnte nicht geöffnet werden';

  @override
  String get callInviteLinkSent =>
      'Einladungslink an alle Gruppenmitglieder gesendet.';

  @override
  String get callOpenLinkManually =>
      'Öffnen Sie den Link oben manuell oder tippen Sie zum Wiederholen.';

  @override
  String get callJitsiNotE2ee =>
      'Jitsi-Anrufe sind NICHT Ende-zu-Ende-verschlüsselt';

  @override
  String get callRetryOpenBrowser => 'Browser erneut öffnen';

  @override
  String get callClose => 'Schließen';

  @override
  String get callCamOn => 'Kamera an';

  @override
  String get callCamOff => 'Kamera aus';

  @override
  String get noConnection =>
      'Keine Verbindung — Nachrichten werden in die Warteschlange gestellt';

  @override
  String get connected => 'Verbunden';

  @override
  String get connecting => 'Verbindung wird hergestellt…';

  @override
  String get disconnected => 'Getrennt';

  @override
  String get offlineBanner =>
      'Keine Verbindung — Nachrichten werden gesendet, sobald Sie wieder online sind';

  @override
  String get lanModeBanner =>
      'LAN-Modus — Kein Internet · Nur lokales Netzwerk';

  @override
  String get probeCheckingNetwork => 'Netzwerkverbindung wird geprüft…';

  @override
  String get probeDiscoveringRelays =>
      'Relays über Community-Verzeichnisse werden gesucht…';

  @override
  String get probeStartingTor => 'Tor wird für den Bootstrap gestartet…';

  @override
  String get probeFindingRelaysTor =>
      'Erreichbare Relays über Tor werden gesucht…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'Netzwerk bereit — $count Relay$_temp0 gefunden';
  }

  @override
  String get probeNoRelaysFound =>
      'Keine erreichbaren Relays gefunden — Nachrichten könnten verzögert werden';

  @override
  String get jitsiWarningTitle => 'Nicht Ende-zu-Ende-verschlüsselt';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet-Anrufe werden nicht von Pulse verschlüsselt. Nur für nicht vertrauliche Gespräche verwenden.';

  @override
  String get jitsiConfirm => 'Trotzdem beitreten';

  @override
  String get jitsiGroupWarningTitle => 'Nicht Ende-zu-Ende-verschlüsselt';

  @override
  String get jitsiGroupWarningBody =>
      'Dieser Anruf hat zu viele Teilnehmer für das eingebaute verschlüsselte Mesh.\n\nEin Jitsi Meet-Link wird in Ihrem Browser geöffnet. Jitsi ist NICHT Ende-zu-Ende-verschlüsselt — der Server kann Ihren Anruf sehen.';

  @override
  String get jitsiContinueAnyway => 'Trotzdem fortfahren';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get setupCreateAnonymousAccount => 'Anonymes Konto erstellen';

  @override
  String get setupTapToChangeColor => 'Tippen zum Farbwechsel';

  @override
  String get setupReqMinLength => 'Mindestens 16 Zeichen';

  @override
  String get setupReqVariety =>
      '3 von 4: Groß-, Kleinbuchstaben, Ziffern, Symbole';

  @override
  String get setupReqMatch => 'Passwörter stimmen überein';

  @override
  String get setupYourNickname => 'Ihr Spitzname';

  @override
  String get setupRecoveryPassword => 'Wiederherstellungspasswort (min. 16)';

  @override
  String get setupConfirmPassword => 'Passwort bestätigen';

  @override
  String get setupMin16Chars => 'Mindestens 16 Zeichen';

  @override
  String get setupPasswordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get setupEntropyWeak => 'Schwach';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Stark';

  @override
  String get setupEntropyWeakNeedsVariety =>
      'Schwach (3 Zeichentypen erforderlich)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits Bits)';
  }

  @override
  String get setupPasswordWarning =>
      'Dieses Passwort ist der einzige Weg, Ihr Konto wiederherzustellen. Es gibt keinen Server — kein Passwort-Reset. Merken Sie es sich oder schreiben Sie es auf.';

  @override
  String get setupCreateAccount => 'Konto erstellen';

  @override
  String get setupAlreadyHaveAccount => 'Sie haben bereits ein Konto? ';

  @override
  String get setupRestore => 'Wiederherstellen →';

  @override
  String get restoreTitle => 'Konto wiederherstellen';

  @override
  String get restoreInfoBanner =>
      'Geben Sie Ihr Wiederherstellungspasswort ein — Ihre Adresse (Nostr + Session) wird automatisch wiederhergestellt. Kontakte und Nachrichten waren nur lokal gespeichert.';

  @override
  String get restoreNewNickname =>
      'Neuer Spitzname (kann später geändert werden)';

  @override
  String get restoreButton => 'Konto wiederherstellen';

  @override
  String get lockTitle => 'Pulse ist gesperrt';

  @override
  String get lockSubtitle => 'Geben Sie Ihr Passwort ein, um fortzufahren';

  @override
  String get lockPasswordHint => 'Passwort';

  @override
  String get lockUnlock => 'Entsperren';

  @override
  String get lockPanicHint =>
      'Passwort vergessen? Geben Sie Ihren Panikschlüssel ein, um alle Daten zu löschen.';

  @override
  String get lockTooManyAttempts =>
      'Zu viele Versuche. Alle Daten werden gelöscht…';

  @override
  String get lockWrongPassword => 'Falsches Passwort';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Falsches Passwort — $attempts/$max Versuche';
  }

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingGetStarted => 'Konto erstellen';

  @override
  String get onboardingWelcomeTitle => 'Willkommen bei Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Ein dezentraler, Ende-zu-Ende-verschlüsselter Messenger.\n\nKeine zentralen Server. Keine Datenerfassung. Keine Hintertüren.\nIhre Gespräche gehören nur Ihnen.';

  @override
  String get onboardingTransportTitle => 'Transportagnostisch';

  @override
  String get onboardingTransportBody =>
      'Verwenden Sie Firebase, Nostr oder beides gleichzeitig.\n\nNachrichten werden automatisch über Netzwerke geleitet. Integrierte Tor- und I2P-Unterstützung für Zensurresistenz.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Jede Nachricht wird mit dem Signal-Protokoll (Double Ratchet + X3DH) für Forward Secrecy verschlüsselt.\n\nZusätzlich mit Kyber-1024 umhüllt — ein NIST-standardisierter Post-Quantum-Algorithmus — zum Schutz vor zukünftigen Quantencomputern.';

  @override
  String get onboardingKeysTitle => 'Ihre Schlüssel gehören Ihnen';

  @override
  String get onboardingKeysBody =>
      'Ihre Identitätsschlüssel verlassen niemals Ihr Gerät.\n\nSignal-Fingerabdrücke ermöglichen die Out-of-Band-Verifizierung von Kontakten. TOFU (Trust On First Use) erkennt Schlüsseländerungen automatisch.';

  @override
  String get onboardingThemeTitle => 'Wählen Sie Ihren Stil';

  @override
  String get onboardingThemeBody =>
      'Wählen Sie ein Design und eine Akzentfarbe. Sie können dies jederzeit in den Einstellungen ändern.';

  @override
  String get contactsNewChat => 'Neuer Chat';

  @override
  String get contactsAddContact => 'Kontakt hinzufügen';

  @override
  String get contactsSearchHint => 'Suchen...';

  @override
  String get contactsNewGroup => 'Neue Gruppe';

  @override
  String get contactsNoContactsYet => 'Noch keine Kontakte';

  @override
  String get contactsAddHint =>
      'Tippen Sie auf +, um eine Adresse hinzuzufügen';

  @override
  String get contactsNoMatch => 'Keine passenden Kontakte';

  @override
  String get contactsRemoveTitle => 'Kontakt entfernen';

  @override
  String contactsRemoveMessage(String name) {
    return '$name entfernen?';
  }

  @override
  String get contactsRemove => 'Entfernen';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'e',
      one: '',
    );
    return '$count Kontakt$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Link öffnen';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Diese URL im Browser öffnen?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Öffnen';

  @override
  String get bubbleSecurityWarning => 'Sicherheitswarnung';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" ist eine ausführbare Datei. Das Speichern und Ausführen könnte Ihr Gerät beschädigen. Trotzdem speichern?';
  }

  @override
  String get bubbleSaveAnyway => 'Trotzdem speichern';

  @override
  String bubbleSavedTo(String path) {
    return 'Gespeichert unter $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Speichern fehlgeschlagen: $error';
  }

  @override
  String get bubbleNotEncrypted => 'NICHT VERSCHLÜSSELT';

  @override
  String get bubbleCorruptedImage => '[Beschädigtes Bild]';

  @override
  String get bubbleReplyPhoto => 'Foto';

  @override
  String get bubbleReplyVoice => 'Sprachnachricht';

  @override
  String get bubbleReplyVideo => 'Videonachricht';

  @override
  String bubbleReadBy(String names) {
    return 'Gelesen von $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Gelesen von $count';
  }

  @override
  String get chatTileTapToStart => 'Tippen, um zu chatten';

  @override
  String get chatTileMessageSent => 'Nachricht gesendet';

  @override
  String get chatTileEncryptedMessage => 'Verschlüsselte Nachricht';

  @override
  String chatTileYouPrefix(String text) {
    return 'Du: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Sprachnachricht';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Sprachnachricht ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Verschlüsselte Nachricht';

  @override
  String get groupNewGroup => 'Neue Gruppe';

  @override
  String get groupGroupName => 'Gruppenname';

  @override
  String get groupSelectMembers => 'Mitglieder auswählen (min. 2)';

  @override
  String get groupNoContactsYet =>
      'Noch keine Kontakte. Fügen Sie zuerst Kontakte hinzu.';

  @override
  String get groupCreate => 'Erstellen';

  @override
  String get groupLabel => 'Gruppe';

  @override
  String get profileVerifyIdentity => 'Identität verifizieren';

  @override
  String profileVerifyInstructions(String name) {
    return 'Vergleichen Sie diese Fingerabdrücke mit $name bei einem Sprachanruf oder persönlich. Wenn beide Werte auf beiden Geräten übereinstimmen, tippen Sie auf „Als verifiziert markieren“.';
  }

  @override
  String get profileTheirKey => 'Ihr Schlüssel';

  @override
  String get profileYourKey => 'Ihr Schlüssel';

  @override
  String get profileRemoveVerification => 'Verifizierung entfernen';

  @override
  String get profileMarkAsVerified => 'Als verifiziert markieren';

  @override
  String get profileAddressCopied => 'Adresse kopiert';

  @override
  String get profileNoContactsToAdd =>
      'Keine Kontakte zum Hinzufügen — alle sind bereits Mitglieder';

  @override
  String get profileAddMembers => 'Mitglieder hinzufügen';

  @override
  String profileAddCount(int count) {
    return 'Hinzufügen ($count)';
  }

  @override
  String get profileRenameGroup => 'Gruppe umbenennen';

  @override
  String get profileRename => 'Umbenennen';

  @override
  String get profileRemoveMember => 'Mitglied entfernen?';

  @override
  String profileRemoveMemberBody(String name) {
    return '$name aus dieser Gruppe entfernen?';
  }

  @override
  String get profileKick => 'Entfernen';

  @override
  String get profileSignalFingerprints => 'Signal-Fingerabdrücke';

  @override
  String get profileVerified => 'VERIFIZIERT';

  @override
  String get profileVerify => 'Verifizieren';

  @override
  String get profileEdit => 'Bearbeiten';

  @override
  String get profileNoSession =>
      'Noch keine Sitzung aufgebaut — senden Sie zuerst eine Nachricht.';

  @override
  String get profileFingerprintCopied => 'Fingerabdruck kopiert';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'er',
      one: '',
    );
    return '$count Mitglied$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Sicherheitsnummer verifizieren';

  @override
  String get profileShowContactQr => 'Kontakt-QR anzeigen';

  @override
  String profileContactAddress(String name) {
    return 'Adresse von $name';
  }

  @override
  String get profileExportChatHistory => 'Chatverlauf exportieren';

  @override
  String profileSavedTo(String path) {
    return 'Gespeichert unter $path';
  }

  @override
  String get profileExportFailed => 'Export fehlgeschlagen';

  @override
  String get profileClearChatHistory => 'Chatverlauf löschen';

  @override
  String get profileDeleteGroup => 'Gruppe löschen';

  @override
  String get profileDeleteContact => 'Kontakt löschen';

  @override
  String get profileLeaveGroup => 'Gruppe verlassen';

  @override
  String get profileLeaveGroupBody =>
      'Sie werden aus dieser Gruppe entfernt und sie wird aus Ihren Kontakten gelöscht.';

  @override
  String get groupInviteTitle => 'Gruppeneinladung';

  @override
  String groupInviteBody(String from, String group) {
    return '$from hat Sie eingeladen, \"$group\" beizutreten';
  }

  @override
  String get groupInviteAccept => 'Annehmen';

  @override
  String get groupInviteDecline => 'Ablehnen';

  @override
  String get groupMemberLimitTitle => 'Zu viele Teilnehmer';

  @override
  String groupMemberLimitBody(int count) {
    return 'Diese Gruppe wird $count Teilnehmer haben. Verschlüsselte Mesh-Anrufe unterstützen bis zu 6. Größere Gruppen wechseln zu Jitsi (nicht E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Trotzdem hinzufügen';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name hat die Einladung zu \"$group\" abgelehnt';
  }

  @override
  String get transferTitle => 'Auf anderes Gerät übertragen';

  @override
  String get transferInfoBox =>
      'Übertragen Sie Ihre Signal-Identität und Nostr-Schlüssel auf ein neues Gerät.\nChat-Sitzungen werden NICHT übertragen — Forward Secrecy bleibt erhalten.';

  @override
  String get transferSendFromThis => 'Von diesem Gerät senden';

  @override
  String get transferSendSubtitle =>
      'Dieses Gerät hat die Schlüssel. Teilen Sie einen Code mit dem neuen Gerät.';

  @override
  String get transferReceiveOnThis => 'Auf diesem Gerät empfangen';

  @override
  String get transferReceiveSubtitle =>
      'Dies ist das neue Gerät. Geben Sie den Code vom alten Gerät ein.';

  @override
  String get transferChooseMethod => 'Übertragungsmethode wählen';

  @override
  String get transferLan => 'LAN (Gleiches Netzwerk)';

  @override
  String get transferLanSubtitle =>
      'Schnell und direkt. Beide Geräte müssen im selben WLAN sein.';

  @override
  String get transferNostrRelay => 'Nostr-Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'Funktioniert über jedes Netzwerk über ein bestehendes Nostr-Relay.';

  @override
  String get transferRelayUrl => 'Relay-URL';

  @override
  String get transferEnterCode => 'Übertragungscode eingeben';

  @override
  String get transferPasteCode => 'LAN:... oder NOS:...-Code hier einfügen';

  @override
  String get transferConnect => 'Verbinden';

  @override
  String get transferGenerating => 'Übertragungscode wird generiert…';

  @override
  String get transferShareCode => 'Teilen Sie diesen Code mit dem Empfänger:';

  @override
  String get transferCopyCode => 'Code kopieren';

  @override
  String get transferCodeCopied => 'Code in Zwischenablage kopiert';

  @override
  String get transferWaitingReceiver => 'Warten auf Verbindung des Empfängers…';

  @override
  String get transferConnectingSender => 'Verbindung zum Sender…';

  @override
  String get transferVerifyBoth =>
      'Vergleichen Sie diesen Code auf beiden Geräten.\nWenn sie übereinstimmen, ist die Übertragung sicher.';

  @override
  String get transferComplete => 'Übertragung abgeschlossen';

  @override
  String get transferKeysImported => 'Schlüssel importiert';

  @override
  String get transferCompleteSenderBody =>
      'Ihre Schlüssel bleiben auf diesem Gerät aktiv.\nDer Empfänger kann jetzt Ihre Identität verwenden.';

  @override
  String get transferCompleteReceiverBody =>
      'Schlüssel erfolgreich importiert.\nStarten Sie die App neu, um die neue Identität anzuwenden.';

  @override
  String get transferRestartApp => 'App neu starten';

  @override
  String get transferFailed => 'Übertragung fehlgeschlagen';

  @override
  String get transferTryAgain => 'Erneut versuchen';

  @override
  String get transferEnterRelayFirst => 'Geben Sie zuerst eine Relay-URL ein';

  @override
  String get transferPasteCodeFromSender =>
      'Fügen Sie den Übertragungscode des Senders ein';

  @override
  String get menuReply => 'Antworten';

  @override
  String get menuForward => 'Weiterleiten';

  @override
  String get menuReact => 'Reagieren';

  @override
  String get menuCopy => 'Kopieren';

  @override
  String get menuEdit => 'Bearbeiten';

  @override
  String get menuRetry => 'Erneut versuchen';

  @override
  String get menuCancelScheduled => 'Geplant abbrechen';

  @override
  String get menuDelete => 'Löschen';

  @override
  String get menuForwardTo => 'Weiterleiten an…';

  @override
  String menuForwardedTo(String name) {
    return 'Weitergeleitet an $name';
  }

  @override
  String get menuScheduledMessages => 'Geplante Nachrichten';

  @override
  String get menuNoScheduledMessages => 'Keine geplanten Nachrichten';

  @override
  String menuSendsOn(String date) {
    return 'Wird gesendet am $date';
  }

  @override
  String get menuDisappearingMessages => 'Verschwindende Nachrichten';

  @override
  String get menuDisappearingSubtitle =>
      'Nachrichten werden nach der gewählten Zeit automatisch gelöscht.';

  @override
  String get menuTtlOff => 'Aus';

  @override
  String get menuTtl1h => '1 Stunde';

  @override
  String get menuTtl24h => '24 Stunden';

  @override
  String get menuTtl7d => '7 Tage';

  @override
  String get menuAttachPhoto => 'Foto';

  @override
  String get menuAttachFile => 'Datei';

  @override
  String get menuAttachVideo => 'Video';

  @override
  String get mediaTitle => 'Medien';

  @override
  String get mediaFileLabel => 'DATEI';

  @override
  String mediaPhotosTab(int count) {
    return 'Fotos ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Dateien ($count)';
  }

  @override
  String get mediaNoPhotos => 'Noch keine Fotos';

  @override
  String get mediaNoFiles => 'Noch keine Dateien';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Gespeichert unter Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'Datei konnte nicht gespeichert werden';

  @override
  String get statusNewStatus => 'Neuer Status';

  @override
  String get statusPublish => 'Veröffentlichen';

  @override
  String get statusExpiresIn24h => 'Status läuft in 24 Stunden ab';

  @override
  String get statusWhatsOnYourMind => 'Was beschäftigt Sie?';

  @override
  String get statusPhotoAttached => 'Foto angehängt';

  @override
  String get statusAttachPhoto => 'Foto anhängen (optional)';

  @override
  String get statusEnterText =>
      'Bitte geben Sie einen Text für Ihren Status ein.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Foto konnte nicht ausgewählt werden: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Veröffentlichung fehlgeschlagen: $error';
  }

  @override
  String get panicSetPanicKey => 'Panikschlüssel festlegen';

  @override
  String get panicEmergencySelfDestruct => 'Notfall-Selbstzerstörung';

  @override
  String get panicIrreversible => 'Diese Aktion ist unwiderruflich';

  @override
  String get panicWarningBody =>
      'Die Eingabe dieses Schlüssels am Sperrbildschirm löscht sofort ALLE Daten — Nachrichten, Kontakte, Schlüssel, Identität. Verwenden Sie einen anderen Schlüssel als Ihr reguläres Passwort.';

  @override
  String get panicKeyHint => 'Panikschlüssel';

  @override
  String get panicConfirmHint => 'Panikschlüssel bestätigen';

  @override
  String get panicMinChars =>
      'Der Panikschlüssel muss mindestens 8 Zeichen lang sein';

  @override
  String get panicKeysDoNotMatch => 'Die Schlüssel stimmen nicht überein';

  @override
  String get panicSetFailed =>
      'Panikschlüssel konnte nicht gespeichert werden — bitte erneut versuchen';

  @override
  String get passwordSetAppPassword => 'App-Passwort festlegen';

  @override
  String get passwordProtectsMessages =>
      'Schützt Ihre Nachrichten im Ruhezustand';

  @override
  String get passwordInfoBanner =>
      'Bei jedem Öffnen von Pulse erforderlich. Bei Verlust können Ihre Daten nicht wiederhergestellt werden.';

  @override
  String get passwordHint => 'Passwort';

  @override
  String get passwordConfirmHint => 'Passwort bestätigen';

  @override
  String get passwordSetButton => 'Passwort festlegen';

  @override
  String get passwordSkipForNow => 'Vorerst überspringen';

  @override
  String get passwordMinChars =>
      'Das Passwort muss mindestens 8 Zeichen lang sein';

  @override
  String get passwordNeedsVariety =>
      'Muss Buchstaben, Zahlen und Sonderzeichen enthalten';

  @override
  String get passwordRequirements =>
      'Min. 8 Zeichen mit Buchstaben, Zahlen und einem Sonderzeichen';

  @override
  String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get profileCardSaved => 'Profil gespeichert!';

  @override
  String get profileCardE2eeIdentity => 'E2EE-Identität';

  @override
  String get profileCardDisplayName => 'Anzeigename';

  @override
  String get profileCardDisplayNameHint => 'z. B. Max Mustermann';

  @override
  String get profileCardAbout => 'Über mich';

  @override
  String get profileCardSaveProfile => 'Profil speichern';

  @override
  String get profileCardYourName => 'Ihr Name';

  @override
  String get profileCardAddressCopied => 'Adresse kopiert!';

  @override
  String get profileCardInboxAddress => 'Ihre Eingangsadresse';

  @override
  String get profileCardInboxAddresses => 'Ihre Eingangsadressen';

  @override
  String get profileCardShareAllAddresses =>
      'Alle Adressen teilen (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Teilen Sie dies mit Kontakten, damit sie Ihnen schreiben können.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Alle $count Adressen als ein Link kopiert!';
  }

  @override
  String get settingsMyProfile => 'Mein Profil';

  @override
  String get settingsYourInboxAddress => 'Ihre Eingangsadresse';

  @override
  String get settingsMyQrCode => 'Kontakt teilen';

  @override
  String get settingsMyQrSubtitle =>
      'QR-Code und Einladungslink für deine Adresse';

  @override
  String get settingsShareMyAddress => 'Meine Adresse teilen';

  @override
  String get settingsNoAddressYet =>
      'Noch keine Adresse — speichern Sie zuerst die Einstellungen';

  @override
  String get settingsInviteLink => 'Einladungslink';

  @override
  String get settingsRawAddress => 'Rohadresse';

  @override
  String get settingsCopyLink => 'Link kopieren';

  @override
  String get settingsCopyAddress => 'Adresse kopieren';

  @override
  String get settingsInviteLinkCopied => 'Einladungslink kopiert';

  @override
  String get settingsAppearance => 'Erscheinungsbild';

  @override
  String get settingsThemeEngine => 'Design-Engine';

  @override
  String get settingsThemeEngineSubtitle => 'Farben & Schriften anpassen';

  @override
  String get settingsSignalProtocol => 'Signal-Protokoll';

  @override
  String get settingsSignalProtocolSubtitle =>
      'E2EE-Schlüssel werden sicher gespeichert';

  @override
  String get settingsActive => 'AKTIV';

  @override
  String get settingsIdentityBackup => 'Identitätssicherung';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Signal-Identität exportieren oder importieren';

  @override
  String get settingsIdentityBackupBody =>
      'Exportieren Sie Ihre Signal-Identitätsschlüssel in einen Sicherungscode oder stellen Sie sie aus einem vorhandenen wieder her.';

  @override
  String get settingsTransferDevice => 'Auf anderes Gerät übertragen';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Identität per LAN oder Nostr-Relay übertragen';

  @override
  String get settingsExportIdentity => 'Identität exportieren';

  @override
  String get settingsExportIdentityBody =>
      'Kopieren Sie diesen Sicherungscode und bewahren Sie ihn sicher auf:';

  @override
  String get settingsSaveFile => 'Datei speichern';

  @override
  String get settingsImportIdentity => 'Identität importieren';

  @override
  String get settingsImportIdentityBody =>
      'Fügen Sie Ihren Sicherungscode unten ein. Dies überschreibt Ihre aktuelle Identität.';

  @override
  String get settingsPasteBackupCode => 'Sicherungscode hier einfügen…';

  @override
  String get settingsIdentityImported =>
      'Identität + Kontakte importiert! Starten Sie die App neu, um sie anzuwenden.';

  @override
  String get settingsSecurity => 'Sicherheit';

  @override
  String get settingsAppPassword => 'App-Passwort';

  @override
  String get settingsPasswordEnabled =>
      'Aktiviert — bei jedem Start erforderlich';

  @override
  String get settingsPasswordDisabled =>
      'Deaktiviert — App öffnet ohne Passwort';

  @override
  String get settingsChangePassword => 'Passwort ändern';

  @override
  String get settingsChangePasswordSubtitle =>
      'App-Sperrpasswort aktualisieren';

  @override
  String get settingsSetPanicKey => 'Panikschlüssel festlegen';

  @override
  String get settingsChangePanicKey => 'Panikschlüssel ändern';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Notfall-Löschschlüssel aktualisieren';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Ein Schlüssel, der sofort alle Daten löscht';

  @override
  String get settingsRemovePanicKey => 'Panikschlüssel entfernen';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Notfall-Selbstzerstörung deaktivieren';

  @override
  String get settingsRemovePanicKeyBody =>
      'Die Notfall-Selbstzerstörung wird deaktiviert. Sie können sie jederzeit wieder aktivieren.';

  @override
  String get settingsDisableAppPassword => 'App-Passwort deaktivieren';

  @override
  String get settingsEnterCurrentPassword =>
      'Geben Sie Ihr aktuelles Passwort zur Bestätigung ein';

  @override
  String get settingsCurrentPassword => 'Aktuelles Passwort';

  @override
  String get settingsIncorrectPassword => 'Falsches Passwort';

  @override
  String get settingsPasswordUpdated => 'Passwort aktualisiert';

  @override
  String get settingsChangePasswordProceed =>
      'Geben Sie Ihr aktuelles Passwort ein, um fortzufahren';

  @override
  String get settingsData => 'Daten';

  @override
  String get settingsBackupMessages => 'Nachrichten sichern';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Verschlüsselten Nachrichtenverlauf in eine Datei exportieren';

  @override
  String get settingsRestoreMessages => 'Nachrichten wiederherstellen';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Nachrichten aus einer Sicherungsdatei importieren';

  @override
  String get settingsExportKeys => 'Schlüssel exportieren';

  @override
  String get settingsExportKeysSubtitle =>
      'Identitätsschlüssel in eine verschlüsselte Datei speichern';

  @override
  String get settingsImportKeys => 'Schlüssel importieren';

  @override
  String get settingsImportKeysSubtitle =>
      'Identitätsschlüssel aus einer exportierten Datei wiederherstellen';

  @override
  String get settingsBackupPassword => 'Sicherungspasswort';

  @override
  String get settingsPasswordCannotBeEmpty => 'Passwort darf nicht leer sein';

  @override
  String get settingsPasswordMin4Chars =>
      'Das Passwort muss mindestens 4 Zeichen lang sein';

  @override
  String get settingsCallsTurn => 'Anrufe & TURN';

  @override
  String get settingsLocalNetwork => 'Lokales Netzwerk';

  @override
  String get settingsCensorshipResistance => 'Zensurresistenz';

  @override
  String get settingsNetwork => 'Netzwerk';

  @override
  String get settingsProxyTunnels => 'Proxy & Tunnel';

  @override
  String get settingsTurnServers => 'TURN-Server';

  @override
  String get settingsProviderTitle => 'Anbieter';

  @override
  String get settingsLanFallback => 'LAN-Fallback';

  @override
  String get settingsLanFallbackSubtitle =>
      'Präsenz und Nachrichten im lokalen Netzwerk übertragen, wenn kein Internet verfügbar ist. In nicht vertrauenswürdigen Netzwerken (öffentliches WLAN) deaktivieren.';

  @override
  String get settingsBgDelivery => 'Hintergrundzustellung';

  @override
  String get settingsBgDeliverySubtitle =>
      'Nachrichten weiterhin empfangen, wenn die App minimiert ist. Zeigt eine dauerhafte Benachrichtigung an.';

  @override
  String get settingsYourInboxProvider => 'Ihr Eingangsanbieter';

  @override
  String get settingsConnectionDetails => 'Verbindungsdetails';

  @override
  String get settingsSaveAndConnect => 'Speichern & Verbinden';

  @override
  String get settingsSecondaryInboxes => 'Sekundäre Posteingänge';

  @override
  String get settingsAddSecondaryInbox => 'Sekundären Posteingang hinzufügen';

  @override
  String get settingsAdvanced => 'Erweitert';

  @override
  String get settingsDiscover => 'Entdecken';

  @override
  String get settingsAbout => 'Über';

  @override
  String get settingsPrivacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get settingsPrivacyPolicySubtitle => 'Wie Pulse Ihre Daten schützt';

  @override
  String get settingsCrashReporting => 'Absturzberichte';

  @override
  String get settingsCrashReportingSubtitle =>
      'Anonyme Absturzberichte senden, um Pulse zu verbessern. Keine Nachrichteninhalte oder Kontakte werden jemals gesendet.';

  @override
  String get settingsCrashReportingEnabled =>
      'Absturzberichte aktiviert — App neu starten, um anzuwenden';

  @override
  String get settingsCrashReportingDisabled =>
      'Absturzberichte deaktiviert — App neu starten, um anzuwenden';

  @override
  String get settingsSensitiveOperation => 'Sensible Operation';

  @override
  String get settingsSensitiveOperationBody =>
      'Diese Schlüssel sind Ihre Identität. Jeder mit dieser Datei kann sich als Sie ausgeben. Bewahren Sie sie sicher auf und löschen Sie sie nach der Übertragung.';

  @override
  String get settingsIUnderstandContinue => 'Ich verstehe, fortfahren';

  @override
  String get settingsReplaceIdentity => 'Identität ersetzen?';

  @override
  String get settingsReplaceIdentityBody =>
      'Dies überschreibt Ihre aktuellen Identitätsschlüssel. Ihre bestehenden Signal-Sitzungen werden ungültig und Kontakte müssen die Verschlüsselung neu aufbauen. Die App muss neu gestartet werden.';

  @override
  String get settingsReplaceKeys => 'Schlüssel ersetzen';

  @override
  String get settingsKeysImported => 'Schlüssel importiert';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count Schlüssel erfolgreich importiert. Bitte starten Sie die App neu, um mit der neuen Identität zu initialisieren.';
  }

  @override
  String get settingsRestartNow => 'Jetzt neu starten';

  @override
  String get settingsLater => 'Später';

  @override
  String get profileGroupLabel => 'Gruppe';

  @override
  String get profileAddButton => 'Hinzufügen';

  @override
  String get profileKickButton => 'Entfernen';

  @override
  String get dataSectionTitle => 'Daten';

  @override
  String get dataBackupMessages => 'Nachrichten sichern';

  @override
  String get dataBackupPasswordSubtitle =>
      'Wählen Sie ein Passwort, um Ihre Sicherung zu verschlüsseln.';

  @override
  String get dataBackupConfirmLabel => 'Sicherung erstellen';

  @override
  String get dataCreatingBackup => 'Sicherung wird erstellt';

  @override
  String get dataBackupPreparing => 'Vorbereitung...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Nachricht $done von $total wird exportiert...';
  }

  @override
  String get dataBackupSavingFile => 'Datei wird gespeichert...';

  @override
  String get dataSaveMessageBackupDialog => 'Nachrichtensicherung speichern';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Sicherung gespeichert ($count Nachrichten)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Sicherung fehlgeschlagen — keine Daten exportiert';

  @override
  String dataBackupFailedError(String error) {
    return 'Sicherung fehlgeschlagen: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Nachrichtensicherung auswählen';

  @override
  String get dataInvalidBackupFile => 'Ungültige Sicherungsdatei (zu klein)';

  @override
  String get dataNotValidBackupFile => 'Keine gültige Pulse-Sicherungsdatei';

  @override
  String get dataRestoreMessages => 'Nachrichten wiederherstellen';

  @override
  String get dataRestorePasswordSubtitle =>
      'Geben Sie das Passwort ein, das zur Erstellung dieser Sicherung verwendet wurde.';

  @override
  String get dataRestoreConfirmLabel => 'Wiederherstellen';

  @override
  String get dataRestoringMessages => 'Nachrichten werden wiederhergestellt';

  @override
  String get dataRestoreDecrypting => 'Entschlüsselung...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Nachricht $done von $total wird importiert...';
  }

  @override
  String get dataRestoreFailed =>
      'Wiederherstellung fehlgeschlagen — falsches Passwort oder beschädigte Datei';

  @override
  String dataRestoreSuccess(int count) {
    return '$count neue Nachrichten wiederhergestellt';
  }

  @override
  String get dataRestoreNothingNew =>
      'Keine neuen Nachrichten zum Importieren (alle bereits vorhanden)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Wiederherstellung fehlgeschlagen: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Schlüsselexport auswählen';

  @override
  String get dataNotValidKeyFile => 'Keine gültige Pulse-Schlüsselexportdatei';

  @override
  String get dataExportKeys => 'Schlüssel exportieren';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Wählen Sie ein Passwort, um Ihren Schlüsselexport zu verschlüsseln.';

  @override
  String get dataExportKeysConfirmLabel => 'Exportieren';

  @override
  String get dataExportingKeys => 'Schlüssel werden exportiert';

  @override
  String get dataExportingKeysStatus =>
      'Identitätsschlüssel werden verschlüsselt...';

  @override
  String get dataSaveKeyExportDialog => 'Schlüsselexport speichern';

  @override
  String dataKeysExportedTo(String path) {
    return 'Schlüssel exportiert nach:\n$path';
  }

  @override
  String get dataExportFailed =>
      'Export fehlgeschlagen — keine Schlüssel gefunden';

  @override
  String dataExportFailedError(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get dataImportKeys => 'Schlüssel importieren';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Geben Sie das Passwort ein, das zur Verschlüsselung dieses Schlüsselexports verwendet wurde.';

  @override
  String get dataImportKeysConfirmLabel => 'Importieren';

  @override
  String get dataImportingKeys => 'Schlüssel werden importiert';

  @override
  String get dataImportingKeysStatus =>
      'Identitätsschlüssel werden entschlüsselt...';

  @override
  String get dataImportFailed =>
      'Import fehlgeschlagen — falsches Passwort oder beschädigte Datei';

  @override
  String dataImportFailedError(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get securitySectionTitle => 'Sicherheit';

  @override
  String get securityIncorrectPassword => 'Falsches Passwort';

  @override
  String get securityPasswordUpdated => 'Passwort aktualisiert';

  @override
  String get appearanceSectionTitle => 'Erscheinungsbild';

  @override
  String appearanceExportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Gespeichert unter $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Speichern fehlgeschlagen: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get aboutSectionTitle => 'Über';

  @override
  String get providerPublicKey => 'Öffentlicher Schlüssel';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Automatisch aus Ihrem Wiederherstellungspasswort konfiguriert. Relay automatisch entdeckt.';

  @override
  String get providerKeyStoredLocally =>
      'Ihr Schlüssel wird lokal im sicheren Speicher gespeichert — niemals an einen Server gesendet.';

  @override
  String get providerSessionInfo =>
      'Session Network — Zwiebel-geroutetes E2EE. Ihre Session-ID wird automatisch generiert und sicher gespeichert. Knoten werden automatisch von integrierten Seed-Knoten entdeckt.';

  @override
  String get providerAdvanced => 'Erweitert';

  @override
  String get providerSaveAndConnect => 'Speichern & Verbinden';

  @override
  String get providerAddSecondaryInbox => 'Sekundären Posteingang hinzufügen';

  @override
  String get providerSecondaryInboxes => 'Sekundäre Posteingänge';

  @override
  String get providerYourInboxProvider => 'Ihr Eingangsanbieter';

  @override
  String get providerConnectionDetails => 'Verbindungsdetails';

  @override
  String get addContactTitle => 'Kontakt hinzufügen';

  @override
  String get addContactInviteLinkLabel => 'Einladungslink oder Adresse';

  @override
  String get addContactTapToPaste => 'Tippen, um Einladungslink einzufügen';

  @override
  String get addContactPasteTooltip => 'Aus Zwischenablage einfügen';

  @override
  String get addContactAddressDetected => 'Kontaktadresse erkannt';

  @override
  String addContactRoutesDetected(int count) {
    return '$count Routen erkannt — SmartRouter wählt die schnellste';
  }

  @override
  String get addContactFetchingProfile => 'Profil wird abgerufen…';

  @override
  String addContactProfileFound(String name) {
    return 'Gefunden: $name';
  }

  @override
  String get addContactNoProfileFound => 'Kein Profil gefunden';

  @override
  String get addContactDisplayNameLabel => 'Anzeigename';

  @override
  String get addContactDisplayNameHint => 'Wie möchten Sie die Person nennen?';

  @override
  String get addContactAddManually => 'Adresse manuell eingeben';

  @override
  String get addContactButton => 'Kontakt hinzufügen';

  @override
  String get networkDiagnosticsTitle => 'Netzwerkdiagnose';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr-Relays';

  @override
  String get networkDiagnosticsDirect => 'Direkt';

  @override
  String get networkDiagnosticsTorOnly => 'Nur Tor';

  @override
  String get networkDiagnosticsBest => 'Bester';

  @override
  String get networkDiagnosticsNone => 'keiner';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Status';

  @override
  String get networkDiagnosticsConnected => 'Verbunden';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Verbindung $percent %';
  }

  @override
  String get networkDiagnosticsOff => 'Aus';

  @override
  String get networkDiagnosticsTransport => 'Transport';

  @override
  String get networkDiagnosticsInfrastructure => 'Infrastruktur';

  @override
  String get networkDiagnosticsSessionNodes => 'Session-Knoten';

  @override
  String get networkDiagnosticsTurnServers => 'TURN-Server';

  @override
  String get networkDiagnosticsLastProbe => 'Letzte Prüfung';

  @override
  String get networkDiagnosticsRunning => 'Läuft...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Diagnose starten';

  @override
  String get networkDiagnosticsForceReprobe =>
      'Vollständige Neuprüfung erzwingen';

  @override
  String get networkDiagnosticsJustNow => 'gerade eben';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'vor $minutes Min.';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'vor $hours Std.';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'vor $days T.';
  }

  @override
  String get homeNoEch => 'Kein ECH';

  @override
  String get homeNoEchTooltip =>
      'uTLS-Proxy nicht verfügbar — ECH deaktiviert.\nTLS-Fingerabdruck ist für DPI sichtbar.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Gespeichert & verbunden mit $provider';
  }

  @override
  String get settingsTorFailedToStart =>
      'Eingebauter Tor konnte nicht gestartet werden';

  @override
  String get settingsPsiphonFailedToStart =>
      'Psiphon konnte nicht gestartet werden';

  @override
  String get verifyTitle => 'Sicherheitsnummer verifizieren';

  @override
  String get verifyIdentityVerified => 'Identität verifiziert';

  @override
  String get verifyNotYetVerified => 'Noch nicht verifiziert';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Sie haben die Sicherheitsnummer von $name verifiziert.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Vergleichen Sie diese Nummern mit $name persönlich oder über einen vertrauenswürdigen Kanal.';
  }

  @override
  String get verifyExplanation =>
      'Jede Unterhaltung hat eine einzigartige Sicherheitsnummer. Wenn Sie beide die gleichen Nummern auf Ihren Geräten sehen, ist Ihre Verbindung Ende-zu-Ende verifiziert.';

  @override
  String verifyContactKey(String name) {
    return 'Schlüssel von $name';
  }

  @override
  String get verifyYourKey => 'Ihr Schlüssel';

  @override
  String get verifyRemoveVerification => 'Verifizierung entfernen';

  @override
  String get verifyMarkAsVerified => 'Als verifiziert markieren';

  @override
  String verifyAfterReinstall(String name) {
    return 'Wenn $name die App neu installiert, ändert sich die Sicherheitsnummer und die Verifizierung wird automatisch entfernt.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Markieren Sie die Identität erst als verifiziert, nachdem Sie die Nummern mit $name bei einem Sprachanruf oder persönlich verglichen haben.';
  }

  @override
  String get verifyNoSession =>
      'Noch keine Verschlüsselungssitzung aufgebaut. Senden Sie zuerst eine Nachricht, um Sicherheitsnummern zu generieren.';

  @override
  String get verifyNoKeyAvailable => 'Kein Schlüssel verfügbar';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label-Fingerabdruck kopiert';
  }

  @override
  String get providerDatabaseUrlLabel => 'Datenbank-URL';

  @override
  String get providerOptionalHint => 'Optional';

  @override
  String get providerWebApiKeyLabel => 'Web-API-Schlüssel';

  @override
  String get providerOptionalForPublicDb =>
      'Optional für öffentliche Datenbank';

  @override
  String get providerRelayUrlLabel => 'Relay-URL';

  @override
  String get providerPrivateKeyLabel => 'Privater Schlüssel';

  @override
  String get providerPrivateKeyNsecLabel => 'Privater Schlüssel (nsec)';

  @override
  String get providerStorageNodeLabel => 'Speicherknoten-URL (optional)';

  @override
  String get providerStorageNodeHint =>
      'Leer lassen für eingebaute Seed-Knoten';

  @override
  String get transferInvalidCodeFormat =>
      'Unbekanntes Codeformat — muss mit LAN: oder NOS: beginnen';

  @override
  String get profileCardFingerprintCopied => 'Fingerabdruck kopiert';

  @override
  String get profileCardAboutHint => 'Privatsphäre zuerst 🔒';

  @override
  String get profileCardSaveButton => 'Profil speichern';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Verschlüsselte Nachrichten, Kontakte und Avatare in eine Datei exportieren';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Audio';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Zugestellt an $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Zugestellt an $count';
  }

  @override
  String get groupStatusDialogTitle => 'Nachrichteninfo';

  @override
  String get groupStatusRead => 'Gelesen';

  @override
  String get groupStatusDelivered => 'Zugestellt';

  @override
  String get groupStatusPending => 'Ausstehend';

  @override
  String get groupStatusNoData => 'Noch keine Zustellinformationen';

  @override
  String get profileTransferAdmin => 'Zum Admin machen';

  @override
  String profileTransferAdminConfirm(String name) {
    return '$name zum neuen Admin machen?';
  }

  @override
  String get profileTransferAdminBody =>
      'Sie verlieren Ihre Adminrechte. Dies kann nicht rückgängig gemacht werden.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name ist jetzt der Admin';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Datenschutzrichtlinie';

  @override
  String get privacyOverviewHeading => 'Überblick';

  @override
  String get privacyOverviewBody =>
      'Pulse ist ein serverloser, Ende-zu-Ende-verschlüsselter Messenger. Ihre Privatsphäre ist nicht nur eine Funktion — sie ist die Architektur. Es gibt keine Pulse-Server. Keine Konten werden irgendwo gespeichert. Keine Daten werden von den Entwicklern erfasst, übertragen oder gespeichert.';

  @override
  String get privacyDataCollectionHeading => 'Datenerfassung';

  @override
  String get privacyDataCollectionBody =>
      'Pulse erfasst keinerlei persönliche Daten. Im Einzelnen:\n\n- Keine E-Mail, Telefonnummer oder Klarname erforderlich\n- Keine Analysen, Tracking oder Telemetrie\n- Keine Werbe-Identifikatoren\n- Kein Zugriff auf die Kontaktliste\n- Keine Cloud-Backups (Nachrichten existieren nur auf Ihrem Gerät)\n- Keine Metadaten werden an einen Pulse-Server gesendet (es gibt keine)';

  @override
  String get privacyEncryptionHeading => 'Verschlüsselung';

  @override
  String get privacyEncryptionBody =>
      'Alle Nachrichten werden mit dem Signal-Protokoll (Double Ratchet mit X3DH-Schlüsselvereinbarung) verschlüsselt. Verschlüsselungsschlüssel werden ausschließlich auf Ihrem Gerät generiert und gespeichert. Niemand — auch nicht die Entwickler — kann Ihre Nachrichten lesen.';

  @override
  String get privacyNetworkHeading => 'Netzwerkarchitektur';

  @override
  String get privacyNetworkBody =>
      'Pulse verwendet föderierte Transportadapter (Nostr-Relays, Session/Oxen-Dienstknoten, Firebase Realtime Database, LAN). Diese Transporte übertragen nur verschlüsselten Chiffretext. Relay-Betreiber können Ihre IP-Adresse und das Verkehrsvolumen sehen, aber den Nachrichteninhalt nicht entschlüsseln.\n\nWenn Tor aktiviert ist, wird Ihre IP-Adresse auch vor Relay-Betreibern verborgen.';

  @override
  String get privacyStunHeading => 'STUN/TURN-Server';

  @override
  String get privacyStunBody =>
      'Sprach- und Videoanrufe verwenden WebRTC mit DTLS-SRTP-Verschlüsselung. STUN-Server (zur Ermittlung Ihrer öffentlichen IP für Peer-to-Peer-Verbindungen) und TURN-Server (zur Weiterleitung von Medien, wenn eine direkte Verbindung fehlschlägt) können Ihre IP-Adresse und die Anrufdauer sehen, aber den Anrufinhalt nicht entschlüsseln.\n\nSie können in den Einstellungen einen eigenen TURN-Server konfigurieren, um maximale Privatsphäre zu gewährleisten.';

  @override
  String get privacyCrashHeading => 'Absturzberichte';

  @override
  String get privacyCrashBody =>
      'Wenn Sentry-Absturzberichte aktiviert sind (über SENTRY_DSN zur Build-Zeit), können anonyme Absturzberichte gesendet werden. Diese enthalten keinen Nachrichteninhalt, keine Kontaktinformationen und keine persönlich identifizierbaren Daten. Absturzberichte können zur Build-Zeit durch Weglassen der DSN deaktiviert werden.';

  @override
  String get privacyPasswordHeading => 'Passwort & Schlüssel';

  @override
  String get privacyPasswordBody =>
      'Ihr Wiederherstellungspasswort wird verwendet, um kryptografische Schlüssel über Argon2id (speicher-harte KDF) abzuleiten. Das Passwort wird nirgendwohin übertragen. Wenn Sie Ihr Passwort verlieren, kann Ihr Konto nicht wiederhergestellt werden — es gibt keinen Server, um es zurückzusetzen.';

  @override
  String get privacyFontsHeading => 'Schriften';

  @override
  String get privacyFontsBody =>
      'Pulse enthält alle Schriften lokal. Es werden keine Anfragen an Google Fonts oder externe Schriftdienste gestellt.';

  @override
  String get privacyThirdPartyHeading => 'Drittanbieterdienste';

  @override
  String get privacyThirdPartyBody =>
      'Pulse integriert sich mit keinen Werbenetzwerken, Analyseanbietern, Social-Media-Plattformen oder Datenhändlern. Die einzigen Netzwerkverbindungen sind zu den Transport-Relays, die Sie konfigurieren.';

  @override
  String get privacyOpenSourceHeading => 'Open Source';

  @override
  String get privacyOpenSourceBody =>
      'Pulse ist Open-Source-Software. Sie können den vollständigen Quellcode prüfen, um diese Datenschutzaussagen zu verifizieren.';

  @override
  String get privacyContactHeading => 'Kontakt';

  @override
  String get privacyContactBody =>
      'Für datenschutzbezogene Fragen öffnen Sie ein Issue im Projektrepository.';

  @override
  String get privacyLastUpdated => 'Zuletzt aktualisiert: März 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Speichern fehlgeschlagen: $error';
  }

  @override
  String get themeEngineTitle => 'Design-Engine';

  @override
  String get torBuiltInTitle => 'Eingebauter Tor';

  @override
  String get torConnectedSubtitle =>
      'Verbunden — Nostr geroutet über 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Verbindung… $pct %';
  }

  @override
  String get torNotRunning => 'Nicht aktiv — tippen zum Neustart';

  @override
  String get torDescription =>
      'Routet Nostr über Tor (Snowflake für zensierte Netzwerke)';

  @override
  String get torNetworkDiagnostics => 'Netzwerkdiagnose';

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
  String get torTimeoutLabel => 'Zeitlimit: ';

  @override
  String get torInfoDescription =>
      'Wenn aktiviert, werden Nostr-WebSocket-Verbindungen über Tor (SOCKS5) geroutet. Tor Browser lauscht auf 127.0.0.1:9150. Der eigenständige Tor-Daemon nutzt Port 9050. Firebase-Verbindungen sind nicht betroffen.';

  @override
  String get torRouteNostrTitle => 'Nostr über Tor routen';

  @override
  String get torManagedByBuiltin => 'Verwaltet durch eingebautes Tor';

  @override
  String get torActiveRouting => 'Aktiv — Nostr-Verkehr wird über Tor geroutet';

  @override
  String get torDisabled => 'Deaktiviert';

  @override
  String get torProxySocks5 => 'Tor-Proxy (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Proxy-Host';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser: Port 9150  •  Tor-Daemon: Port 9050';

  @override
  String get torForceNostrTitle => 'Nachrichten über Tor leiten';

  @override
  String get torForceNostrSubtitle =>
      'Alle Nostr-Relay-Verbindungen werden über Tor geleitet. Langsamer, aber Ihre IP wird vor Relays verborgen.';

  @override
  String get torForceNostrDisabled => 'Tor muss zuerst aktiviert werden';

  @override
  String get torForcePulseTitle => 'Pulse-Relay über Tor leiten';

  @override
  String get torForcePulseSubtitle =>
      'Alle Pulse-Relay-Verbindungen werden über Tor geleitet. Langsamer, aber Ihre IP wird vor dem Server verborgen.';

  @override
  String get torForcePulseDisabled => 'Tor muss zuerst aktiviert werden';

  @override
  String get i2pProxySocks5 => 'I2P-Proxy (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P nutzt standardmäßig SOCKS5 auf Port 4447. Verbinden Sie sich mit einem Nostr-Relay über I2P-Outproxy (z. B. relay.damus.i2p), um mit Benutzern auf jedem Transport zu kommunizieren. Tor hat Vorrang, wenn beide aktiviert sind.';

  @override
  String get i2pRouteNostrTitle => 'Nostr über I2P routen';

  @override
  String get i2pActiveRouting => 'Aktiv — Nostr-Verkehr wird über I2P geroutet';

  @override
  String get i2pDisabled => 'Deaktiviert';

  @override
  String get i2pProxyHostLabel => 'Proxy-Host';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'I2P-Router Standard-SOCKS5-Port: 4447';

  @override
  String get customProxySocks5 => 'Benutzerdefinierter Proxy (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Der benutzerdefinierte Proxy routet den Verkehr über Ihren V2Ray/Xray/Shadowsocks. Der CF Worker fungiert als persönlicher Relay-Proxy auf dem Cloudflare CDN — die GFW sieht *.workers.dev, nicht das echte Relay.';

  @override
  String get customSocks5ProxyTitle => 'Benutzerdefinierter SOCKS5-Proxy';

  @override
  String get customProxyActive => 'Aktiv — Verkehr wird über SOCKS5 geroutet';

  @override
  String get customProxyDisabled => 'Deaktiviert';

  @override
  String get customProxyHostLabel => 'Proxy-Host';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker-Domain (optional)';

  @override
  String get customWorkerHelpTitle =>
      'So deployen Sie ein CF Worker Relay (kostenlos)';

  @override
  String get customWorkerScriptCopied => 'Skript kopiert!';

  @override
  String get customWorkerStep1 =>
      '1. Gehen Sie zu dash.cloudflare.com → Workers & Pages\n2. Create Worker → fügen Sie dieses Skript ein:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → kopieren Sie die Domain (z. B. my-relay.user.workers.dev)\n4. Fügen Sie die Domain oben ein → Speichern\n\nApp verbindet automatisch: wss://domain/?r=relay_url\nGFW sieht: Verbindung zu *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Verbunden — SOCKS5 auf 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Verbindung wird hergestellt…';

  @override
  String get psiphonNotRunning => 'Nicht aktiv — tippen zum Neustart';

  @override
  String get psiphonDescription =>
      'Schneller Tunnel (~3s Bootstrap, 2000+ rotierende VPS)';

  @override
  String get turnCommunityServers => 'Community-TURN-Server';

  @override
  String get turnCustomServer => 'Benutzerdefinierter TURN-Server (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN-Server leiten nur bereits verschlüsselte Streams weiter (DTLS-SRTP). Ein Relay-Betreiber sieht Ihre IP und das Verkehrsvolumen, kann aber keine Anrufe entschlüsseln. TURN wird nur verwendet, wenn direktes P2P fehlschlägt (~15–20 % der Verbindungen).';

  @override
  String get turnFreeLabel => 'KOSTENLOS';

  @override
  String get turnServerUrlLabel => 'TURN-Server-URL';

  @override
  String get turnServerUrlHint => 'turn:ihr-server.com:3478 oder turns:...';

  @override
  String get turnUsernameLabel => 'Benutzername';

  @override
  String get turnPasswordLabel => 'Passwort';

  @override
  String get turnOptionalHint => 'Optional';

  @override
  String get turnCustomInfo =>
      'Betreiben Sie coturn auf einem beliebigen 5\$/Monat VPS für maximale Kontrolle. Anmeldedaten werden lokal gespeichert.';

  @override
  String get themePickerAppearance => 'Erscheinungsbild';

  @override
  String get themePickerAccentColor => 'Akzentfarbe';

  @override
  String get themeModeLight => 'Hell';

  @override
  String get themeModeDark => 'Dunkel';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeDynamicPresets => 'Voreinstellungen';

  @override
  String get themeDynamicPrimaryColor => 'Primärfarbe';

  @override
  String get themeDynamicBorderRadius => 'Rahmenradius';

  @override
  String get themeDynamicFont => 'Schrift';

  @override
  String get themeDynamicAppearance => 'Erscheinungsbild';

  @override
  String get themeDynamicUiStyle => 'UI-Stil';

  @override
  String get themeDynamicUiStyleDescription =>
      'Steuert das Aussehen von Dialogen, Schaltern und Indikatoren.';

  @override
  String get themeDynamicSharp => 'Eckig';

  @override
  String get themeDynamicRound => 'Rund';

  @override
  String get themeDynamicModeDark => 'Dunkel';

  @override
  String get themeDynamicModeLight => 'Hell';

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
      'Ungültige Firebase-URL. Erwartet: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Ungültige Relay-URL. Erwartet: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Ungültige Pulse-Server-URL. Erwartet: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'Server-URL';

  @override
  String get providerPulseServerUrlHint => 'https://ihr-server:8443';

  @override
  String get providerPulseInviteLabel => 'Einladungscode';

  @override
  String get providerPulseInviteHint => 'Einladungscode (falls erforderlich)';

  @override
  String get providerPulseInfo =>
      'Selbst gehostetes Relay. Schlüssel aus Ihrem Wiederherstellungspasswort abgeleitet.';

  @override
  String get providerScreenTitle => 'Posteingänge';

  @override
  String get providerSecondaryInboxesHeader => 'SEKUNDÄRE POSTEINGÄNGE';

  @override
  String get providerSecondaryInboxesInfo =>
      'Sekundäre Posteingänge empfangen Nachrichten gleichzeitig für Redundanz.';

  @override
  String get providerRemoveTooltip => 'Entfernen';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... or hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... or hex private key';

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
  String get emojiNoRecent => 'Keine kürzlich verwendeten Emojis';

  @override
  String get emojiSearchHint => 'Emoji suchen...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Tippen zum Chatten';

  @override
  String get imageViewerSaveToDownloads => 'In Downloads speichern';

  @override
  String imageViewerSavedTo(String path) {
    return 'Gespeichert unter $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSubtitle => 'App-Anzeigesprache';

  @override
  String get settingsLanguageSystem => 'Systemstandard';

  @override
  String get onboardingLanguageTitle => 'Sprache wählen';

  @override
  String get onboardingLanguageSubtitle =>
      'Sie können dies später in den Einstellungen ändern';

  @override
  String get videoNoteRecord => 'Videonachricht aufnehmen';

  @override
  String get videoNoteTapToRecord => 'Zum Aufnehmen tippen';

  @override
  String get videoNoteTapToStop => 'Zum Stoppen tippen';

  @override
  String get videoNoteCameraPermission => 'Kamerazugriff verweigert';

  @override
  String get videoNoteMaxDuration => 'Maximal 30 Sekunden';

  @override
  String get videoNoteNotSupported =>
      'Videonotizen werden auf dieser Plattform nicht unterstützt';

  @override
  String get navChats => 'Chats';

  @override
  String get navUpdates => 'Aktualisierungen';

  @override
  String get navCalls => 'Anrufe';

  @override
  String get filterAll => 'Alle';

  @override
  String get filterUnread => 'Ungelesen';

  @override
  String get filterGroups => 'Gruppen';

  @override
  String get callsNoRecent => 'Keine aktuellen Anrufe';

  @override
  String get callsEmptySubtitle => 'Ihr Anrufverlauf wird hier angezeigt';

  @override
  String get appBarEncrypted => 'Ende-zu-Ende-verschlüsselt';

  @override
  String get newStatus => 'Neuer Status';

  @override
  String get newCall => 'Neuer Anruf';

  @override
  String get joinChannelTitle => 'Kanal beitreten';

  @override
  String get joinChannelDescription => 'KANAL-URL';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'Kanalinformationen werden abgerufen…';

  @override
  String get joinChannelNotFound => 'Kein Kanal unter dieser URL gefunden';

  @override
  String get joinChannelNetworkError => 'Server nicht erreichbar';

  @override
  String get joinChannelAlreadyJoined => 'Bereits beigetreten';

  @override
  String get joinChannelButton => 'Beitreten';

  @override
  String get channelFeedEmpty => 'Noch keine Beiträge';

  @override
  String get channelLeave => 'Kanal verlassen';

  @override
  String get channelLeaveConfirm =>
      'Diesen Kanal verlassen? Gespeicherte Beiträge werden gelöscht.';

  @override
  String get channelInfo => 'Kanalinfo';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'bearbeitet';

  @override
  String get channelLoadMore => 'Mehr laden';

  @override
  String get channelSearchPosts => 'Beiträge suchen…';

  @override
  String get channelNoResults => 'Keine passenden Beiträge';

  @override
  String get channelUrl => 'Kanal-URL';

  @override
  String get channelCreated => 'Beigetreten';

  @override
  String channelPostCount(int count) {
    return '$count Beiträge';
  }

  @override
  String get channelCopyUrl => 'URL kopieren';

  @override
  String get setupNext => 'Weiter';

  @override
  String get setupKeyWarning =>
      'Ein Wiederherstellungsschlüssel wird für dich generiert. Er ist die einzige Möglichkeit, dein Konto auf einem neuen Gerät wiederherzustellen — es gibt keinen Server, kein Passwort-Reset.';

  @override
  String get setupKeyTitle => 'Dein Wiederherstellungsschlüssel';

  @override
  String get setupKeySubtitle =>
      'Schreibe diesen Schlüssel auf und bewahre ihn an einem sicheren Ort auf. Du brauchst ihn, um dein Konto auf einem neuen Gerät wiederherzustellen.';

  @override
  String get setupKeyCopied => 'Kopiert!';

  @override
  String get setupKeyWroteItDown => 'Ich habe ihn aufgeschrieben';

  @override
  String get setupKeyWarnBody =>
      'Schreibe diesen Schlüssel als Backup auf. Du kannst ihn auch später unter Einstellungen → Sicherheit ansehen.';

  @override
  String get setupVerifyTitle => 'Wiederherstellungsschlüssel bestätigen';

  @override
  String get setupVerifySubtitle =>
      'Gib deinen Wiederherstellungsschlüssel erneut ein, um zu bestätigen, dass du ihn korrekt gespeichert hast.';

  @override
  String get setupVerifyButton => 'Bestätigen';

  @override
  String get setupKeyMismatch =>
      'Schlüssel stimmt nicht überein. Überprüfe und versuche es erneut.';

  @override
  String get setupSkipVerify => 'Überprüfung überspringen';

  @override
  String get setupSkipVerifyTitle => 'Überprüfung überspringen?';

  @override
  String get setupSkipVerifyBody =>
      'Wenn du deinen Wiederherstellungsschlüssel verlierst, kann dein Konto nicht wiederhergestellt werden. Bist du sicher?';

  @override
  String get setupCreatingAccount => 'Konto wird erstellt…';

  @override
  String get setupRestoringAccount => 'Konto wird wiederhergestellt…';

  @override
  String get restoreKeyInfoBanner =>
      'Gib deinen Wiederherstellungsschlüssel ein — deine Adresse (Nostr + Session) wird automatisch wiederhergestellt. Kontakte und Nachrichten wurden nur lokal gespeichert.';

  @override
  String get restoreKeyHint => 'Wiederherstellungsschlüssel';

  @override
  String get settingsViewRecoveryKey => 'Wiederherstellungsschlüssel anzeigen';

  @override
  String get settingsViewRecoveryKeySubtitle =>
      'Ihren Konto-Wiederherstellungsschlüssel anzeigen';

  @override
  String get settingsRecoveryKeyNotStored =>
      'Wiederherstellungsschlüssel nicht verfügbar (vor dieser Funktion erstellt)';

  @override
  String get settingsRecoveryKeyWarning =>
      'Bewahren Sie diesen Schlüssel sicher auf. Jeder, der ihn hat, kann Ihr Konto auf einem anderen Gerät wiederherstellen.';

  @override
  String get replaceIdentityTitle => 'Bestehende Identität ersetzen?';

  @override
  String get replaceIdentityBodyRestore =>
      'Auf diesem Gerät existiert bereits eine Identität. Das Wiederherstellen ersetzt dauerhaft deinen aktuellen Nostr-Schlüssel und Oxen-Seed. Alle Kontakte verlieren die Möglichkeit, deine aktuelle Adresse zu erreichen.\n\nDies kann nicht rückgängig gemacht werden.';

  @override
  String get replaceIdentityBodyCreate =>
      'Auf diesem Gerät existiert bereits eine Identität. Eine neue zu erstellen ersetzt dauerhaft deinen aktuellen Nostr-Schlüssel und Oxen-Seed. Alle Kontakte verlieren die Möglichkeit, deine aktuelle Adresse zu erreichen.\n\nDies kann nicht rückgängig gemacht werden.';

  @override
  String get replace => 'Ersetzen';

  @override
  String get callNoScreenSources => 'Keine Bildschirmquellen verfügbar';

  @override
  String get callScreenShareQuality => 'Bildschirmfreigabe-Qualität';

  @override
  String get callFrameRate => 'Bildrate';

  @override
  String get callResolution => 'Auflösung';

  @override
  String get callAutoResolution => 'Auto = native Bildschirmauflösung';

  @override
  String get callStartSharing => 'Freigabe starten';

  @override
  String get callCameraUnavailable =>
      'Kamera nicht verfügbar — wird möglicherweise von einer anderen App verwendet';

  @override
  String get themeResetToDefaults => 'Auf Standard zurücksetzen';

  @override
  String get backupSaveToDownloadsTitle => 'Backup in Downloads speichern?';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'Keine Dateiauswahl verfügbar. Das Backup wird gespeichert unter:\n$path';
  }

  @override
  String get systemLabel => 'System';

  @override
  String get next => 'Weiter';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return 'Noch $remaining Mal tippen für Entwicklermodus';
  }

  @override
  String get devModeEnabled => 'Entwicklermodus aktiviert';

  @override
  String get devTools => 'Entwicklertools';

  @override
  String get devAdapterDiagnostics => 'Adapter-Schalter & Diagnose';

  @override
  String get devEnableAll => 'Alle aktivieren';

  @override
  String get devDisableAll => 'Alle deaktivieren';

  @override
  String get turnUrlValidation =>
      'TURN-URL muss mit turn: oder turns: beginnen (max. 512 Zeichen)';

  @override
  String get callMissedCall => 'Verpasster Anruf';

  @override
  String get callOutgoingCall => 'Ausgehender Anruf';

  @override
  String get callIncomingCall => 'Eingehender Anruf';

  @override
  String get mediaMissingData => 'Mediendaten fehlen';

  @override
  String get mediaDownloadFailed => 'Download fehlgeschlagen';

  @override
  String get mediaDecryptFailed => 'Entschlüsselung fehlgeschlagen';

  @override
  String get callEndCallBanner => 'Anruf beenden';

  @override
  String get meFallback => 'Ich';

  @override
  String get imageSaveToDownloads => 'In Downloads speichern';

  @override
  String imageSavedToPath(String path) {
    return 'Gespeichert unter $path';
  }

  @override
  String get callScreenShareRequiresPermission =>
      'Bildschirmfreigabe erfordert Berechtigung';

  @override
  String get callScreenShareUnavailable => 'Bildschirmfreigabe nicht verfügbar';

  @override
  String get statusJustNow => 'Gerade eben';

  @override
  String statusMinutesAgo(int minutes) {
    return 'vor $minutes Min.';
  }

  @override
  String statusHoursAgo(int hours) {
    return 'vor $hours Std.';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Routen',
      one: '1 Route',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => 'Bereit zum Hinzufügen';

  @override
  String groupSelectedCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String get paste => 'Einfügen';

  @override
  String get sfuAudioOnly => 'Nur Audio';

  @override
  String sfuParticipants(int count) {
    return '$count Teilnehmer';
  }

  @override
  String get dataUnencryptedBackup => 'Unverschlüsseltes Backup';

  @override
  String get dataUnencryptedBackupBody =>
      'Diese Datei ist ein unverschlüsseltes Identitäts-Backup und überschreibt Ihre aktuellen Schlüssel. Importieren Sie nur Dateien, die Sie selbst erstellt haben. Fortfahren?';

  @override
  String get dataImportAnyway => 'Trotzdem importieren';

  @override
  String get securityStorageError =>
      'Sicherheitsspeicherfehler — App neu starten';

  @override
  String get aboutDevModeActive => 'Entwicklermodus aktiv';

  @override
  String get themeColors => 'Farben';

  @override
  String get themePrimaryAccent => 'Primärakzent';

  @override
  String get themeSecondaryAccent => 'Sekundärakzent';

  @override
  String get themeBackground => 'Hintergrund';

  @override
  String get themeSurface => 'Oberfläche';

  @override
  String get themeChatBubbles => 'Chat-Blasen';

  @override
  String get themeOutgoingMessage => 'Ausgehende Nachricht';

  @override
  String get themeIncomingMessage => 'Eingehende Nachricht';

  @override
  String get themeShape => 'Form';

  @override
  String get devSectionDeveloper => 'Entwickler';

  @override
  String get devAdapterChannelsHint =>
      'Adapterkanäle — deaktivieren, um bestimmte Transporte zu testen.';

  @override
  String get devNostrRelays => 'Nostr-Relays (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Session-Netzwerk';

  @override
  String get devPulseRelay => 'Pulse selbstgehostetes Relay';

  @override
  String get devLanNetwork => 'Lokales Netzwerk (UDP/TCP)';

  @override
  String get devSectionCalls => 'Anrufe';

  @override
  String get devForceTurnRelay => 'TURN-Relay erzwingen';

  @override
  String get devForceTurnRelaySubtitle =>
      'P2P deaktivieren — alle Anrufe nur über TURN-Server';

  @override
  String get devRestartWarning =>
      '⚠ Änderungen gelten ab dem nächsten Senden/Anruf. App neu starten für eingehende Verbindungen.';

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
  String get pulseUseServerTitle => 'Pulse-Server verwenden?';

  @override
  String pulseUseServerBody(String name, String host) {
    return '$name verwendet den Pulse-Server $host. Beitreten, um schneller mit ihnen (und anderen auf demselben Server) zu chatten?';
  }

  @override
  String pulseContactUsesPulse(String name) {
    return '$name verwendet Pulse';
  }

  @override
  String pulseJoinForFaster(String host) {
    return '$host beitreten für schnelleren Chat';
  }

  @override
  String get pulseNotNow => 'Nicht jetzt';

  @override
  String get pulseJoin => 'Beitreten';

  @override
  String get pulseDismiss => 'Schließen';

  @override
  String get pulseHide7Days => '7 Tage ausblenden';

  @override
  String get pulseNeverAskAgain => 'Nicht mehr fragen';

  @override
  String get groupSearchContactsHint => 'Kontakte suchen…';

  @override
  String get systemActorYou => 'Du';

  @override
  String get systemActorPeer => 'Gegenüber';

  @override
  String systemTtlEnabled(String actor, String duration) {
    return '$actor hat verschwindende Nachrichten aktiviert: $duration';
  }

  @override
  String systemTtlDisabled(String actor) {
    return '$actor hat verschwindende Nachrichten deaktiviert';
  }

  @override
  String get menuClearChatHistory => 'Chatverlauf löschen';

  @override
  String get clearChatTitle => 'Chatverlauf löschen?';

  @override
  String get clearChatBody =>
      'Alle Nachrichten in diesem Chat werden von diesem Gerät gelöscht. Die andere Person behält ihre Kopie.';

  @override
  String get clearChatAction => 'Löschen';

  @override
  String systemGroupRenamed(String actor, String name) {
    return '$actor hat die Gruppe in „$name\" umbenannt';
  }

  @override
  String systemGroupAvatarChanged(String actor) {
    return '$actor hat das Gruppenfoto geändert';
  }

  @override
  String systemGroupMetaChanged(String actor, String name) {
    return '$actor hat die Gruppe in „$name\" umbenannt und das Foto geändert';
  }

  @override
  String get profileInviteLink => 'Einladungslink';

  @override
  String get profileInviteLinkSubtitle => 'Jeder mit dem Link kann beitreten';

  @override
  String get profileInviteLinkCopied =>
      'Einladungslink in die Zwischenablage kopiert';

  @override
  String get groupInviteLinkTitle => 'Gruppe beitreten?';

  @override
  String groupInviteLinkBody(String name, int count) {
    return 'Du wurdest zu „$name\" eingeladen ($count Mitglieder).';
  }

  @override
  String get groupInviteLinkJoin => 'Beitreten';

  @override
  String get drawerCreateGroup => 'Gruppe erstellen';

  @override
  String get drawerJoinGroup => 'Gruppe beitreten';

  @override
  String get drawerJoinGroupByLinkInvalid =>
      'Das sieht nicht wie ein Pulse-Gruppeneinladungslink aus';

  @override
  String get groupModeMeshTitle => 'Normal';

  @override
  String groupModeMeshSubtitle(int n) {
    return 'Ohne Server, bis zu $n Personen';
  }

  @override
  String get groupModePulseTitle => 'Pulse-Server';

  @override
  String groupModePulseSubtitle(int n) {
    return 'Über Server, bis zu $n Personen';
  }

  @override
  String get groupPulseServerHint => 'https://dein-pulse-server';

  @override
  String get groupPulseServerClosed =>
      'Geschlossener Server (Einladungscode erforderlich)';

  @override
  String get groupPulseInviteHint => 'Einladungscode';

  @override
  String pulseGroupForeignServerBanner(String host) {
    return 'Nachrichten laufen über $host (nicht dein Pulse-Server)';
  }

  @override
  String groupMeshLimitReached(int n) {
    return 'Dieser Anruftyp ist auf $n Personen begrenzt';
  }
}
