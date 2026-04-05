// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Cerca messaggi...';

  @override
  String get search => 'Cerca';

  @override
  String get clearSearch => 'Cancella ricerca';

  @override
  String get closeSearch => 'Chiudi ricerca';

  @override
  String get moreOptions => 'Altre opzioni';

  @override
  String get back => 'Indietro';

  @override
  String get cancel => 'Annulla';

  @override
  String get close => 'Chiudi';

  @override
  String get confirm => 'Conferma';

  @override
  String get remove => 'Rimuovi';

  @override
  String get save => 'Salva';

  @override
  String get add => 'Aggiungi';

  @override
  String get copy => 'Copia';

  @override
  String get skip => 'Salta';

  @override
  String get done => 'Fatto';

  @override
  String get apply => 'Applica';

  @override
  String get export => 'Esporta';

  @override
  String get import => 'Importa';

  @override
  String get homeNewGroup => 'Nuovo gruppo';

  @override
  String get homeSettings => 'Impostazioni';

  @override
  String get homeSearching => 'Ricerca messaggi...';

  @override
  String get homeNoResults => 'Nessun risultato trovato';

  @override
  String get homeNoChatHistory => 'Nessuna cronologia chat';

  @override
  String homeTransportSwitched(String address) {
    return 'Trasporto cambiato → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name sta chiamando...';
  }

  @override
  String get homeAccept => 'Accetta';

  @override
  String get homeDecline => 'Rifiuta';

  @override
  String get homeLoadEarlier => 'Carica messaggi precedenti';

  @override
  String get homeChats => 'Chat';

  @override
  String get homeSelectConversation => 'Seleziona una conversazione';

  @override
  String get homeNoChatsYet => 'Nessuna chat';

  @override
  String get homeAddContactToStart =>
      'Aggiungi un contatto per iniziare a chattare';

  @override
  String get homeNewChat => 'Nuova chat';

  @override
  String get homeNewChatTooltip => 'Nuova chat';

  @override
  String get homeIncomingCallTitle => 'Chiamata in arrivo';

  @override
  String get homeIncomingGroupCallTitle => 'Chiamata di gruppo in arrivo';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — chiamata di gruppo in arrivo';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Nessuna chat corrispondente a \"$query\"';
  }

  @override
  String get homeSectionChats => 'Chat';

  @override
  String get homeSectionMessages => 'Messaggi';

  @override
  String get homeDbEncryptionUnavailable =>
      'Crittografia del database non disponibile — installa SQLCipher per la protezione completa';

  @override
  String get chatFileTooLargeGroup =>
      'I file superiori a 512 KB non sono supportati nelle chat di gruppo';

  @override
  String get chatLargeFile => 'File grande';

  @override
  String get chatCancel => 'Annulla';

  @override
  String get chatSend => 'Invia';

  @override
  String get chatFileTooLarge =>
      'File troppo grande — dimensione massima 100 MB';

  @override
  String get chatMicDenied => 'Permesso microfono negato';

  @override
  String get chatVoiceFailed =>
      'Impossibile salvare il messaggio vocale — controlla lo spazio disponibile';

  @override
  String get chatScheduleFuture =>
      'L\'orario programmato deve essere nel futuro';

  @override
  String get chatToday => 'Oggi';

  @override
  String get chatYesterday => 'Ieri';

  @override
  String get chatEdited => 'modificato';

  @override
  String get chatYou => 'Tu';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Questo file è di $size MB. L\'invio di file grandi potrebbe essere lento su alcune reti. Continuare?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'La chiave di sicurezza di $name è cambiata. Tocca per verificare.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Impossibile crittografare il messaggio per $name — messaggio non inviato.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Il numero di sicurezza è cambiato per $name. Tocca per verificare.';
  }

  @override
  String get chatNoMessagesFound => 'Nessun messaggio trovato';

  @override
  String get chatMessagesE2ee => 'I messaggi sono crittografati end-to-end';

  @override
  String get chatSayHello => 'Manda un saluto';

  @override
  String get appBarOnline => 'online';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'sta scrivendo';

  @override
  String get appBarSearchMessages => 'Cerca messaggi...';

  @override
  String get appBarMute => 'Silenzia';

  @override
  String get appBarUnmute => 'Riattiva';

  @override
  String get appBarMedia => 'Media';

  @override
  String get appBarDisappearing => 'Messaggi effimeri';

  @override
  String get appBarDisappearingOn => 'Messaggi effimeri: attivi';

  @override
  String get appBarGroupSettings => 'Impostazioni gruppo';

  @override
  String get appBarSearchTooltip => 'Cerca messaggi';

  @override
  String get appBarVoiceCall => 'Chiamata vocale';

  @override
  String get appBarVideoCall => 'Videochiamata';

  @override
  String get inputMessage => 'Messaggio...';

  @override
  String get inputAttachFile => 'Allega file';

  @override
  String get inputSendMessage => 'Invia messaggio';

  @override
  String get inputRecordVoice => 'Registra messaggio vocale';

  @override
  String get inputSendVoice => 'Invia messaggio vocale';

  @override
  String get inputCancelReply => 'Annulla risposta';

  @override
  String get inputCancelEdit => 'Annulla modifica';

  @override
  String get inputCancelRecording => 'Annulla registrazione';

  @override
  String get inputRecording => 'Registrazione…';

  @override
  String get inputEditingMessage => 'Modifica messaggio';

  @override
  String get inputPhoto => 'Foto';

  @override
  String get inputVoiceMessage => 'Messaggio vocale';

  @override
  String get inputFile => 'File';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messaggi programmati',
      one: '$count messaggio programmato',
    );
    return '$_temp0';
  }

  @override
  String get callInitializing => 'Inizializzazione chiamata…';

  @override
  String get callConnecting => 'Connessione…';

  @override
  String get callConnectingRelay => 'Connessione (relay)…';

  @override
  String get callSwitchingRelay => 'Passaggio alla modalità relay…';

  @override
  String get callConnectionFailed => 'Connessione fallita';

  @override
  String get callReconnecting => 'Riconnessione…';

  @override
  String get callEnded => 'Chiamata terminata';

  @override
  String get callLive => 'In corso';

  @override
  String get callEnd => 'Fine';

  @override
  String get callEndCall => 'Termina chiamata';

  @override
  String get callMute => 'Silenzia';

  @override
  String get callUnmute => 'Riattiva';

  @override
  String get callSpeaker => 'Altoparlante';

  @override
  String get callCameraOn => 'Fotocamera attiva';

  @override
  String get callCameraOff => 'Fotocamera spenta';

  @override
  String get callShareScreen => 'Condividi schermo';

  @override
  String get callStopShare => 'Interrompi condivisione';

  @override
  String callTorBackup(String duration) {
    return 'Backup Tor · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Backup Tor attivo — percorso primario non disponibile';

  @override
  String get callDirectFailed =>
      'Connessione diretta fallita — passaggio alla modalità relay…';

  @override
  String get callTurnUnreachable =>
      'Server TURN irraggiungibili. Aggiungi un TURN personalizzato in Impostazioni → Avanzate.';

  @override
  String get callRelayMode => 'Modalità relay attiva (rete limitata)';

  @override
  String get callStarting => 'Avvio chiamata…';

  @override
  String get callConnectingToGroup => 'Connessione al gruppo…';

  @override
  String get callGroupOpenedInBrowser =>
      'Chiamata di gruppo aperta nel browser';

  @override
  String get callCouldNotOpenBrowser => 'Impossibile aprire il browser';

  @override
  String get callInviteLinkSent =>
      'Link di invito inviato a tutti i membri del gruppo.';

  @override
  String get callOpenLinkManually =>
      'Apri il link sopra manualmente o tocca per riprovare.';

  @override
  String get callJitsiNotE2ee =>
      'Le chiamate Jitsi NON sono crittografate end-to-end';

  @override
  String get callRetryOpenBrowser => 'Riprova ad aprire il browser';

  @override
  String get callClose => 'Chiudi';

  @override
  String get callCamOn => 'Cam attiva';

  @override
  String get callCamOff => 'Cam spenta';

  @override
  String get noConnection => 'Nessuna connessione — i messaggi saranno in coda';

  @override
  String get connected => 'Connesso';

  @override
  String get connecting => 'Connessione…';

  @override
  String get disconnected => 'Disconnesso';

  @override
  String get offlineBanner =>
      'Nessuna connessione — i messaggi saranno in coda e inviati al ritorno online';

  @override
  String get lanModeBanner =>
      'Modalità LAN — Nessun internet · Solo rete locale';

  @override
  String get probeCheckingNetwork => 'Verifica connettività di rete…';

  @override
  String get probeDiscoveringRelays =>
      'Scoperta relay tramite directory della comunità…';

  @override
  String get probeStartingTor => 'Avvio di Tor per il bootstrap…';

  @override
  String get probeFindingRelaysTor => 'Ricerca relay raggiungibili via Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count relay trovati',
      one: '$count relay trovato',
    );
    return 'Rete pronta — $_temp0';
  }

  @override
  String get probeNoRelaysFound =>
      'Nessun relay raggiungibile trovato — i messaggi potrebbero subire ritardi';

  @override
  String get jitsiWarningTitle => 'Non crittografato end-to-end';

  @override
  String get jitsiWarningBody =>
      'Le chiamate Jitsi Meet non sono crittografate da Pulse. Usare solo per conversazioni non sensibili.';

  @override
  String get jitsiConfirm => 'Partecipa comunque';

  @override
  String get jitsiGroupWarningTitle => 'Non crittografato end-to-end';

  @override
  String get jitsiGroupWarningBody =>
      'Questa chiamata ha troppi partecipanti per la mesh crittografata integrata.\n\nUn link Jitsi Meet verrà aperto nel browser. Jitsi NON è crittografato end-to-end — il server può vedere la chiamata.';

  @override
  String get jitsiContinueAnyway => 'Continua comunque';

  @override
  String get retry => 'Riprova';

  @override
  String get setupCreateAnonymousAccount => 'Crea un account anonimo';

  @override
  String get setupTapToChangeColor => 'Tocca per cambiare colore';

  @override
  String get setupReqMinLength => 'Almeno 16 caratteri';

  @override
  String get setupReqVariety => '3 su 4: maiuscole, minuscole, cifre, simboli';

  @override
  String get setupReqMatch => 'Le password corrispondono';

  @override
  String get setupYourNickname => 'Il tuo nickname';

  @override
  String get setupRecoveryPassword => 'Password di recupero (min. 16)';

  @override
  String get setupConfirmPassword => 'Conferma password';

  @override
  String get setupMin16Chars => 'Minimo 16 caratteri';

  @override
  String get setupPasswordsDoNotMatch => 'Le password non corrispondono';

  @override
  String get setupEntropyWeak => 'Debole';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Forte';

  @override
  String get setupEntropyWeakNeedsVariety =>
      'Debole (servono 3 tipi di carattere)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bit)';
  }

  @override
  String get setupPasswordWarning =>
      'Questa password è l\'unico modo per recuperare il tuo account. Non esiste un server — nessun ripristino password. Ricordala o annotala.';

  @override
  String get setupCreateAccount => 'Crea account';

  @override
  String get setupAlreadyHaveAccount => 'Hai già un account? ';

  @override
  String get setupRestore => 'Ripristina →';

  @override
  String get restoreTitle => 'Ripristina account';

  @override
  String get restoreInfoBanner =>
      'Inserisci la tua password di recupero — il tuo indirizzo (Nostr + Session) verrà ripristinato automaticamente. Contatti e messaggi erano memorizzati solo localmente.';

  @override
  String get restoreNewNickname => 'Nuovo nickname (modificabile in seguito)';

  @override
  String get restoreButton => 'Ripristina account';

  @override
  String get lockTitle => 'Pulse è bloccato';

  @override
  String get lockSubtitle => 'Inserisci la password per continuare';

  @override
  String get lockPasswordHint => 'Password';

  @override
  String get lockUnlock => 'Sblocca';

  @override
  String get lockPanicHint =>
      'Password dimenticata? Inserisci la chiave di emergenza per cancellare tutti i dati.';

  @override
  String get lockTooManyAttempts =>
      'Troppi tentativi. Cancellazione di tutti i dati…';

  @override
  String get lockWrongPassword => 'Password errata';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Password errata — $attempts/$max tentativi';
  }

  @override
  String get onboardingSkip => 'Salta';

  @override
  String get onboardingNext => 'Avanti';

  @override
  String get onboardingGetStarted => 'Inizia';

  @override
  String get onboardingWelcomeTitle => 'Benvenuto su Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Un messenger decentralizzato con crittografia end-to-end.\n\nNessun server centrale. Nessuna raccolta dati. Nessuna backdoor.\nLe tue conversazioni appartengono solo a te.';

  @override
  String get onboardingTransportTitle => 'Agnostico al trasporto';

  @override
  String get onboardingTransportBody =>
      'Usa Firebase, Nostr o entrambi contemporaneamente.\n\nI messaggi vengono instradati tra le reti automaticamente. Supporto integrato per Tor e I2P per la resistenza alla censura.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Ogni messaggio è crittografato con il protocollo Signal (Double Ratchet + X3DH) per la segretezza in avanti.\n\nInoltre avvolto con Kyber-1024 — un algoritmo post-quantistico standard NIST — che protegge dai futuri computer quantistici.';

  @override
  String get onboardingKeysTitle => 'Le tue chiavi, il tuo controllo';

  @override
  String get onboardingKeysBody =>
      'Le tue chiavi di identità non lasciano mai il tuo dispositivo.\n\nLe impronte digitali Signal ti permettono di verificare i contatti fuori banda. TOFU (Trust On First Use) rileva automaticamente i cambiamenti delle chiavi.';

  @override
  String get onboardingThemeTitle => 'Scegli il tuo stile';

  @override
  String get onboardingThemeBody =>
      'Scegli un tema e un colore di accento. Puoi sempre cambiarlo nelle Impostazioni.';

  @override
  String get contactsNewChat => 'Nuova chat';

  @override
  String get contactsAddContact => 'Aggiungi contatto';

  @override
  String get contactsSearchHint => 'Cerca...';

  @override
  String get contactsNewGroup => 'Nuovo gruppo';

  @override
  String get contactsNoContactsYet => 'Nessun contatto';

  @override
  String get contactsAddHint =>
      'Tocca + per aggiungere l\'indirizzo di qualcuno';

  @override
  String get contactsNoMatch => 'Nessun contatto corrispondente';

  @override
  String get contactsRemoveTitle => 'Rimuovi contatto';

  @override
  String contactsRemoveMessage(String name) {
    return 'Rimuovere $name?';
  }

  @override
  String get contactsRemove => 'Rimuovi';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contatti',
      one: '$count contatto',
    );
    return '$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Apri link';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Aprire questo URL nel browser?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Apri';

  @override
  String get bubbleSecurityWarning => 'Avviso di sicurezza';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" è un file eseguibile. Salvarlo ed eseguirlo potrebbe danneggiare il dispositivo. Salvare comunque?';
  }

  @override
  String get bubbleSaveAnyway => 'Salva comunque';

  @override
  String bubbleSavedTo(String path) {
    return 'Salvato in $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Salvataggio fallito: $error';
  }

  @override
  String get bubbleNotEncrypted => 'NON CRITTOGRAFATO';

  @override
  String get bubbleCorruptedImage => '[Immagine corrotta]';

  @override
  String get bubbleReplyPhoto => 'Foto';

  @override
  String get bubbleReplyVoice => 'Messaggio vocale';

  @override
  String get bubbleReplyVideo => 'Messaggio video';

  @override
  String bubbleReadBy(String names) {
    return 'Letto da $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Letto da $count';
  }

  @override
  String get chatTileTapToStart => 'Tocca per iniziare a chattare';

  @override
  String get chatTileMessageSent => 'Messaggio inviato';

  @override
  String get chatTileEncryptedMessage => 'Messaggio crittografato';

  @override
  String chatTileYouPrefix(String text) {
    return 'Tu: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Messaggio vocale';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Messaggio vocale ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Messaggio crittografato';

  @override
  String get groupNewGroup => 'Nuovo gruppo';

  @override
  String get groupGroupName => 'Nome del gruppo';

  @override
  String get groupSelectMembers => 'Seleziona membri (min 2)';

  @override
  String get groupNoContactsYet =>
      'Nessun contatto. Aggiungi prima dei contatti.';

  @override
  String get groupCreate => 'Crea';

  @override
  String get groupLabel => 'Gruppo';

  @override
  String get profileVerifyIdentity => 'Verifica identità';

  @override
  String profileVerifyInstructions(String name) {
    return 'Confronta queste impronte digitali con $name durante una chiamata vocale o di persona. Se entrambi i valori corrispondono su entrambi i dispositivi, tocca \"Segna come verificato\".';
  }

  @override
  String get profileTheirKey => 'La loro chiave';

  @override
  String get profileYourKey => 'La tua chiave';

  @override
  String get profileRemoveVerification => 'Rimuovi verifica';

  @override
  String get profileMarkAsVerified => 'Segna come verificato';

  @override
  String get profileAddressCopied => 'Indirizzo copiato';

  @override
  String get profileNoContactsToAdd =>
      'Nessun contatto da aggiungere — sono già tutti membri';

  @override
  String get profileAddMembers => 'Aggiungi membri';

  @override
  String profileAddCount(int count) {
    return 'Aggiungi ($count)';
  }

  @override
  String get profileRenameGroup => 'Rinomina gruppo';

  @override
  String get profileRename => 'Rinomina';

  @override
  String get profileRemoveMember => 'Rimuovere il membro?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Rimuovere $name da questo gruppo?';
  }

  @override
  String get profileKick => 'Espelli';

  @override
  String get profileSignalFingerprints => 'Impronte digitali Signal';

  @override
  String get profileVerified => 'VERIFICATO';

  @override
  String get profileVerify => 'Verifica';

  @override
  String get profileEdit => 'Modifica';

  @override
  String get profileNoSession =>
      'Nessuna sessione stabilita — invia prima un messaggio.';

  @override
  String get profileFingerprintCopied => 'Impronta digitale copiata';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membri',
      one: '$count membro',
    );
    return '$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Verifica numero di sicurezza';

  @override
  String get profileShowContactQr => 'Mostra QR contatto';

  @override
  String profileContactAddress(String name) {
    return 'Indirizzo di $name';
  }

  @override
  String get profileExportChatHistory => 'Esporta cronologia chat';

  @override
  String profileSavedTo(String path) {
    return 'Salvato in $path';
  }

  @override
  String get profileExportFailed => 'Esportazione fallita';

  @override
  String get profileClearChatHistory => 'Cancella cronologia chat';

  @override
  String get profileDeleteGroup => 'Elimina gruppo';

  @override
  String get profileDeleteContact => 'Elimina contatto';

  @override
  String get profileLeaveGroup => 'Esci dal gruppo';

  @override
  String get profileLeaveGroupBody =>
      'Verrai rimosso da questo gruppo e sarà eliminato dai tuoi contatti.';

  @override
  String get groupInviteTitle => 'Invito al gruppo';

  @override
  String groupInviteBody(String from, String group) {
    return '$from ti ha invitato a unirti a \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Accetta';

  @override
  String get groupInviteDecline => 'Rifiuta';

  @override
  String get groupMemberLimitTitle => 'Troppi partecipanti';

  @override
  String groupMemberLimitBody(int count) {
    return 'Questo gruppo avrà $count partecipanti. Le chiamate mesh crittografate supportano fino a 6 persone. Gruppi più grandi passano a Jitsi (non E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Aggiungi comunque';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name ha rifiutato di unirsi a \"$group\"';
  }

  @override
  String get transferTitle => 'Trasferisci su un altro dispositivo';

  @override
  String get transferInfoBox =>
      'Trasferisci la tua identità Signal e le chiavi Nostr su un nuovo dispositivo.\nLe sessioni di chat NON vengono trasferite — la segretezza in avanti è preservata.';

  @override
  String get transferSendFromThis => 'Invia da questo dispositivo';

  @override
  String get transferSendSubtitle =>
      'Questo dispositivo ha le chiavi. Condividi un codice con il nuovo dispositivo.';

  @override
  String get transferReceiveOnThis => 'Ricevi su questo dispositivo';

  @override
  String get transferReceiveSubtitle =>
      'Questo è il nuovo dispositivo. Inserisci il codice dal vecchio dispositivo.';

  @override
  String get transferChooseMethod => 'Scegli metodo di trasferimento';

  @override
  String get transferLan => 'LAN (stessa rete)';

  @override
  String get transferLanSubtitle =>
      'Veloce e diretto. Entrambi i dispositivi devono essere sulla stessa rete Wi-Fi.';

  @override
  String get transferNostrRelay => 'Relay Nostr';

  @override
  String get transferNostrRelaySubtitle =>
      'Funziona su qualsiasi rete usando un relay Nostr esistente.';

  @override
  String get transferRelayUrl => 'URL del relay';

  @override
  String get transferEnterCode => 'Inserisci codice di trasferimento';

  @override
  String get transferPasteCode => 'Incolla qui il codice LAN:... o NOS:...';

  @override
  String get transferConnect => 'Connetti';

  @override
  String get transferGenerating => 'Generazione codice di trasferimento…';

  @override
  String get transferShareCode => 'Condividi questo codice con il ricevente:';

  @override
  String get transferCopyCode => 'Copia codice';

  @override
  String get transferCodeCopied => 'Codice copiato negli appunti';

  @override
  String get transferWaitingReceiver =>
      'In attesa della connessione del ricevente…';

  @override
  String get transferConnectingSender => 'Connessione al mittente…';

  @override
  String get transferVerifyBoth =>
      'Confronta questo codice su entrambi i dispositivi.\nSe corrispondono, il trasferimento è sicuro.';

  @override
  String get transferComplete => 'Trasferimento completato';

  @override
  String get transferKeysImported => 'Chiavi importate';

  @override
  String get transferCompleteSenderBody =>
      'Le tue chiavi restano attive su questo dispositivo.\nIl ricevente può ora usare la tua identità.';

  @override
  String get transferCompleteReceiverBody =>
      'Chiavi importate con successo.\nRiavvia l\'app per applicare la nuova identità.';

  @override
  String get transferRestartApp => 'Riavvia app';

  @override
  String get transferFailed => 'Trasferimento fallito';

  @override
  String get transferTryAgain => 'Riprova';

  @override
  String get transferEnterRelayFirst => 'Inserisci prima un URL del relay';

  @override
  String get transferPasteCodeFromSender =>
      'Incolla il codice di trasferimento dal mittente';

  @override
  String get menuReply => 'Rispondi';

  @override
  String get menuForward => 'Inoltra';

  @override
  String get menuReact => 'Reagisci';

  @override
  String get menuCopy => 'Copia';

  @override
  String get menuEdit => 'Modifica';

  @override
  String get menuRetry => 'Riprova';

  @override
  String get menuCancelScheduled => 'Annulla programmato';

  @override
  String get menuDelete => 'Elimina';

  @override
  String get menuForwardTo => 'Inoltra a…';

  @override
  String menuForwardedTo(String name) {
    return 'Inoltrato a $name';
  }

  @override
  String get menuScheduledMessages => 'Messaggi programmati';

  @override
  String get menuNoScheduledMessages => 'Nessun messaggio programmato';

  @override
  String menuSendsOn(String date) {
    return 'Invio il $date';
  }

  @override
  String get menuDisappearingMessages => 'Messaggi effimeri';

  @override
  String get menuDisappearingSubtitle =>
      'I messaggi si cancellano automaticamente dopo il tempo selezionato.';

  @override
  String get menuTtlOff => 'Disattivato';

  @override
  String get menuTtl1h => '1 ora';

  @override
  String get menuTtl24h => '24 ore';

  @override
  String get menuTtl7d => '7 giorni';

  @override
  String get menuAttachPhoto => 'Foto';

  @override
  String get menuAttachFile => 'File';

  @override
  String get menuAttachVideo => 'Video';

  @override
  String get mediaTitle => 'Media';

  @override
  String get mediaFileLabel => 'FILE';

  @override
  String mediaPhotosTab(int count) {
    return 'Foto ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'File ($count)';
  }

  @override
  String get mediaNoPhotos => 'Nessuna foto';

  @override
  String get mediaNoFiles => 'Nessun file';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Salvato in Download/$name';
  }

  @override
  String get mediaFailedToSave => 'Salvataggio file fallito';

  @override
  String get statusNewStatus => 'Nuovo stato';

  @override
  String get statusPublish => 'Pubblica';

  @override
  String get statusExpiresIn24h => 'Lo stato scade in 24 ore';

  @override
  String get statusWhatsOnYourMind => 'A cosa stai pensando?';

  @override
  String get statusPhotoAttached => 'Foto allegata';

  @override
  String get statusAttachPhoto => 'Allega foto (opzionale)';

  @override
  String get statusEnterText => 'Inserisci del testo per il tuo stato.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Impossibile selezionare la foto: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Pubblicazione fallita: $error';
  }

  @override
  String get panicSetPanicKey => 'Imposta chiave di emergenza';

  @override
  String get panicEmergencySelfDestruct => 'Autodistruzione di emergenza';

  @override
  String get panicIrreversible => 'Questa azione è irreversibile';

  @override
  String get panicWarningBody =>
      'Inserendo questa chiave nella schermata di blocco si cancellano TUTTI i dati — messaggi, contatti, chiavi, identità. Usa una chiave diversa dalla tua password abituale.';

  @override
  String get panicKeyHint => 'Chiave di emergenza';

  @override
  String get panicConfirmHint => 'Conferma chiave di emergenza';

  @override
  String get panicMinChars =>
      'La chiave di emergenza deve avere almeno 8 caratteri';

  @override
  String get panicKeysDoNotMatch => 'Le chiavi non corrispondono';

  @override
  String get panicSetFailed =>
      'Impossibile salvare la chiave di emergenza — riprova';

  @override
  String get passwordSetAppPassword => 'Imposta password dell\'app';

  @override
  String get passwordProtectsMessages => 'Protegge i tuoi messaggi a riposo';

  @override
  String get passwordInfoBanner =>
      'Richiesta ogni volta che apri Pulse. Se dimenticata, i tuoi dati non possono essere recuperati.';

  @override
  String get passwordHint => 'Password';

  @override
  String get passwordConfirmHint => 'Conferma password';

  @override
  String get passwordSetButton => 'Imposta password';

  @override
  String get passwordSkipForNow => 'Salta per ora';

  @override
  String get passwordMinChars => 'La password deve avere almeno 6 caratteri';

  @override
  String get passwordsDoNotMatch => 'Le password non corrispondono';

  @override
  String get profileCardSaved => 'Profilo salvato!';

  @override
  String get profileCardE2eeIdentity => 'Identità E2EE';

  @override
  String get profileCardDisplayName => 'Nome visualizzato';

  @override
  String get profileCardDisplayNameHint => 'es. Mario Rossi';

  @override
  String get profileCardAbout => 'Info';

  @override
  String get profileCardSaveProfile => 'Salva profilo';

  @override
  String get profileCardYourName => 'Il tuo nome';

  @override
  String get profileCardAddressCopied => 'Indirizzo copiato!';

  @override
  String get profileCardInboxAddress => 'Il tuo indirizzo di posta';

  @override
  String get profileCardInboxAddresses => 'I tuoi indirizzi di posta';

  @override
  String get profileCardShareAllAddresses =>
      'Condividi tutti gli indirizzi (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Condividi con i contatti così possono scriverti.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Tutti i $count indirizzi copiati come un unico link!';
  }

  @override
  String get settingsMyProfile => 'Il mio profilo';

  @override
  String get settingsYourInboxAddress => 'Il tuo indirizzo di posta';

  @override
  String get settingsMyQrCode => 'Il mio codice QR';

  @override
  String get settingsMyQrSubtitle =>
      'Condividi il tuo indirizzo come QR scansionabile';

  @override
  String get settingsShareMyAddress => 'Condividi il mio indirizzo';

  @override
  String get settingsNoAddressYet =>
      'Nessun indirizzo ancora — salva prima le impostazioni';

  @override
  String get settingsInviteLink => 'Link di invito';

  @override
  String get settingsRawAddress => 'Indirizzo diretto';

  @override
  String get settingsCopyLink => 'Copia link';

  @override
  String get settingsCopyAddress => 'Copia indirizzo';

  @override
  String get settingsInviteLinkCopied => 'Link di invito copiato';

  @override
  String get settingsAppearance => 'Aspetto';

  @override
  String get settingsThemeEngine => 'Motore dei temi';

  @override
  String get settingsThemeEngineSubtitle => 'Personalizza colori e caratteri';

  @override
  String get settingsSignalProtocol => 'Protocollo Signal';

  @override
  String get settingsSignalProtocolSubtitle =>
      'Le chiavi E2EE sono memorizzate in modo sicuro';

  @override
  String get settingsActive => 'ATTIVO';

  @override
  String get settingsIdentityBackup => 'Backup identità';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Esporta o importa la tua identità Signal';

  @override
  String get settingsIdentityBackupBody =>
      'Esporta le tue chiavi di identità Signal in un codice di backup o ripristina da uno esistente.';

  @override
  String get settingsTransferDevice => 'Trasferisci su un altro dispositivo';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Sposta la tua identità tramite LAN o relay Nostr';

  @override
  String get settingsExportIdentity => 'Esporta identità';

  @override
  String get settingsExportIdentityBody =>
      'Copia questo codice di backup e conservalo in modo sicuro:';

  @override
  String get settingsSaveFile => 'Salva file';

  @override
  String get settingsImportIdentity => 'Importa identità';

  @override
  String get settingsImportIdentityBody =>
      'Incolla il tuo codice di backup qui sotto. Questo sovrascriverà la tua identità attuale.';

  @override
  String get settingsPasteBackupCode => 'Incolla qui il codice di backup…';

  @override
  String get settingsIdentityImported =>
      'Identità + contatti importati! Riavvia l\'app per applicare.';

  @override
  String get settingsSecurity => 'Sicurezza';

  @override
  String get settingsAppPassword => 'Password dell\'app';

  @override
  String get settingsPasswordEnabled => 'Attivata — richiesta ad ogni avvio';

  @override
  String get settingsPasswordDisabled =>
      'Disattivata — l\'app si apre senza password';

  @override
  String get settingsChangePassword => 'Cambia password';

  @override
  String get settingsChangePasswordSubtitle =>
      'Aggiorna la password di blocco dell\'app';

  @override
  String get settingsSetPanicKey => 'Imposta chiave di emergenza';

  @override
  String get settingsChangePanicKey => 'Cambia chiave di emergenza';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Aggiorna la chiave di cancellazione d\'emergenza';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Una chiave che cancella istantaneamente tutti i dati';

  @override
  String get settingsRemovePanicKey => 'Rimuovi chiave di emergenza';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Disattiva l\'autodistruzione di emergenza';

  @override
  String get settingsRemovePanicKeyBody =>
      'L\'autodistruzione di emergenza verrà disattivata. Puoi riattivarla in qualsiasi momento.';

  @override
  String get settingsDisableAppPassword => 'Disattiva password dell\'app';

  @override
  String get settingsEnterCurrentPassword =>
      'Inserisci la password attuale per confermare';

  @override
  String get settingsCurrentPassword => 'Password attuale';

  @override
  String get settingsIncorrectPassword => 'Password errata';

  @override
  String get settingsPasswordUpdated => 'Password aggiornata';

  @override
  String get settingsChangePasswordProceed =>
      'Inserisci la password attuale per procedere';

  @override
  String get settingsData => 'Dati';

  @override
  String get settingsBackupMessages => 'Backup messaggi';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Esporta la cronologia messaggi crittografata in un file';

  @override
  String get settingsRestoreMessages => 'Ripristina messaggi';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Importa messaggi da un file di backup';

  @override
  String get settingsExportKeys => 'Esporta chiavi';

  @override
  String get settingsExportKeysSubtitle =>
      'Salva le chiavi di identità in un file crittografato';

  @override
  String get settingsImportKeys => 'Importa chiavi';

  @override
  String get settingsImportKeysSubtitle =>
      'Ripristina le chiavi di identità da un file esportato';

  @override
  String get settingsBackupPassword => 'Password del backup';

  @override
  String get settingsPasswordCannotBeEmpty =>
      'La password non può essere vuota';

  @override
  String get settingsPasswordMin4Chars =>
      'La password deve avere almeno 4 caratteri';

  @override
  String get settingsCallsTurn => 'Chiamate e TURN';

  @override
  String get settingsLocalNetwork => 'Rete locale';

  @override
  String get settingsCensorshipResistance => 'Resistenza alla censura';

  @override
  String get settingsNetwork => 'Rete';

  @override
  String get settingsProxyTunnels => 'Proxy e tunnel';

  @override
  String get settingsTurnServers => 'Server TURN';

  @override
  String get settingsProviderTitle => 'Provider';

  @override
  String get settingsLanFallback => 'Fallback LAN';

  @override
  String get settingsLanFallbackSubtitle =>
      'Annuncia la presenza e consegna i messaggi sulla rete locale quando internet non è disponibile. Disattiva su reti non fidate (Wi-Fi pubblico).';

  @override
  String get settingsBgDelivery => 'Consegna in background';

  @override
  String get settingsBgDeliverySubtitle =>
      'Continua a ricevere messaggi quando l\'app è ridotta a icona. Mostra una notifica persistente.';

  @override
  String get settingsYourInboxProvider => 'Il tuo provider di posta';

  @override
  String get settingsConnectionDetails => 'Dettagli connessione';

  @override
  String get settingsSaveAndConnect => 'Salva e connetti';

  @override
  String get settingsSecondaryInboxes => 'Caselle di posta secondarie';

  @override
  String get settingsAddSecondaryInbox => 'Aggiungi casella secondaria';

  @override
  String get settingsAdvanced => 'Avanzate';

  @override
  String get settingsDiscover => 'Scopri';

  @override
  String get settingsAbout => 'Informazioni';

  @override
  String get settingsPrivacyPolicy => 'Informativa sulla privacy';

  @override
  String get settingsPrivacyPolicySubtitle => 'Come Pulse protegge i tuoi dati';

  @override
  String get settingsCrashReporting => 'Segnalazione crash';

  @override
  String get settingsCrashReportingSubtitle =>
      'Invia segnalazioni di crash anonime per migliorare Pulse. Nessun contenuto di messaggi o contatti viene mai inviato.';

  @override
  String get settingsCrashReportingEnabled =>
      'Segnalazione crash attivata — riavvia l\'app per applicare';

  @override
  String get settingsCrashReportingDisabled =>
      'Segnalazione crash disattivata — riavvia l\'app per applicare';

  @override
  String get settingsSensitiveOperation => 'Operazione sensibile';

  @override
  String get settingsSensitiveOperationBody =>
      'Queste chiavi sono la tua identità. Chiunque abbia questo file può impersonarti. Conservalo in modo sicuro e cancellalo dopo il trasferimento.';

  @override
  String get settingsIUnderstandContinue => 'Ho capito, continua';

  @override
  String get settingsReplaceIdentity => 'Sostituire l\'identità?';

  @override
  String get settingsReplaceIdentityBody =>
      'Questo sovrascriverà le tue chiavi di identità attuali. Le sessioni Signal esistenti verranno invalidate e i contatti dovranno ristabilire la crittografia. L\'app dovrà riavviarsi.';

  @override
  String get settingsReplaceKeys => 'Sostituisci chiavi';

  @override
  String get settingsKeysImported => 'Chiavi importate';

  @override
  String settingsKeysImportedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chiavi importate con successo',
      one: '$count chiave importata con successo',
    );
    return '$_temp0. Riavvia l\'app per reinizializzare con la nuova identità.';
  }

  @override
  String get settingsRestartNow => 'Riavvia ora';

  @override
  String get settingsLater => 'Più tardi';

  @override
  String get profileGroupLabel => 'Gruppo';

  @override
  String get profileAddButton => 'Aggiungi';

  @override
  String get profileKickButton => 'Espelli';

  @override
  String get dataSectionTitle => 'Dati';

  @override
  String get dataBackupMessages => 'Backup messaggi';

  @override
  String get dataBackupPasswordSubtitle =>
      'Scegli una password per crittografare il backup dei messaggi.';

  @override
  String get dataBackupConfirmLabel => 'Crea backup';

  @override
  String get dataCreatingBackup => 'Creazione backup';

  @override
  String get dataBackupPreparing => 'Preparazione...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Esportazione messaggio $done di $total...';
  }

  @override
  String get dataBackupSavingFile => 'Salvataggio file...';

  @override
  String get dataSaveMessageBackupDialog => 'Salva backup messaggi';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Backup salvato ($count messaggi)\n$path';
  }

  @override
  String get dataBackupFailed => 'Backup fallito — nessun dato esportato';

  @override
  String dataBackupFailedError(String error) {
    return 'Backup fallito: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Seleziona backup messaggi';

  @override
  String get dataInvalidBackupFile =>
      'File di backup non valido (troppo piccolo)';

  @override
  String get dataNotValidBackupFile => 'Non è un file di backup Pulse valido';

  @override
  String get dataRestoreMessages => 'Ripristina messaggi';

  @override
  String get dataRestorePasswordSubtitle =>
      'Inserisci la password usata per creare questo backup.';

  @override
  String get dataRestoreConfirmLabel => 'Ripristina';

  @override
  String get dataRestoringMessages => 'Ripristino messaggi';

  @override
  String get dataRestoreDecrypting => 'Decrittazione...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Importazione messaggio $done di $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Ripristino fallito — password errata o file corrotto';

  @override
  String dataRestoreSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuovi messaggi ripristinati',
      one: '$count nuovo messaggio ripristinato',
    );
    return '$_temp0';
  }

  @override
  String get dataRestoreNothingNew =>
      'Nessun nuovo messaggio da importare (tutti già esistenti)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Ripristino fallito: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Seleziona esportazione chiavi';

  @override
  String get dataNotValidKeyFile =>
      'Non è un file di esportazione chiavi Pulse valido';

  @override
  String get dataExportKeys => 'Esporta chiavi';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Scegli una password per crittografare l\'esportazione delle chiavi.';

  @override
  String get dataExportKeysConfirmLabel => 'Esporta';

  @override
  String get dataExportingKeys => 'Esportazione chiavi';

  @override
  String get dataExportingKeysStatus => 'Crittografia chiavi di identità...';

  @override
  String get dataSaveKeyExportDialog => 'Salva esportazione chiavi';

  @override
  String dataKeysExportedTo(String path) {
    return 'Chiavi esportate in:\n$path';
  }

  @override
  String get dataExportFailed =>
      'Esportazione fallita — nessuna chiave trovata';

  @override
  String dataExportFailedError(String error) {
    return 'Esportazione fallita: $error';
  }

  @override
  String get dataImportKeys => 'Importa chiavi';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Inserisci la password usata per crittografare questa esportazione di chiavi.';

  @override
  String get dataImportKeysConfirmLabel => 'Importa';

  @override
  String get dataImportingKeys => 'Importazione chiavi';

  @override
  String get dataImportingKeysStatus => 'Decrittazione chiavi di identità...';

  @override
  String get dataImportFailed =>
      'Importazione fallita — password errata o file corrotto';

  @override
  String dataImportFailedError(String error) {
    return 'Importazione fallita: $error';
  }

  @override
  String get securitySectionTitle => 'Sicurezza';

  @override
  String get securityIncorrectPassword => 'Password errata';

  @override
  String get securityPasswordUpdated => 'Password aggiornata';

  @override
  String get appearanceSectionTitle => 'Aspetto';

  @override
  String appearanceExportFailed(String error) {
    return 'Esportazione fallita: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Salvato in $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Salvataggio fallito: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Importazione fallita: $error';
  }

  @override
  String get aboutSectionTitle => 'Informazioni';

  @override
  String get providerPublicKey => 'Chiave pubblica';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Configurato automaticamente dalla tua password di recupero. Relay individuato automaticamente.';

  @override
  String get providerKeyStoredLocally =>
      'La tua chiave è memorizzata localmente in modo sicuro — non viene mai inviata a nessun server.';

  @override
  String get providerSessionInfo =>
      'Session Network — E2EE con routing onion. Il tuo ID Session viene generato automaticamente e archiviato in modo sicuro. I nodi vengono scoperti automaticamente dai nodi seed integrati.';

  @override
  String get providerAdvanced => 'Avanzate';

  @override
  String get providerSaveAndConnect => 'Salva e connetti';

  @override
  String get providerAddSecondaryInbox => 'Aggiungi casella secondaria';

  @override
  String get providerSecondaryInboxes => 'Caselle di posta secondarie';

  @override
  String get providerYourInboxProvider => 'Il tuo provider di posta';

  @override
  String get providerConnectionDetails => 'Dettagli connessione';

  @override
  String get addContactTitle => 'Aggiungi contatto';

  @override
  String get addContactInviteLinkLabel => 'Link di invito o indirizzo';

  @override
  String get addContactTapToPaste => 'Tocca per incollare il link di invito';

  @override
  String get addContactPasteTooltip => 'Incolla dagli appunti';

  @override
  String get addContactAddressDetected => 'Indirizzo del contatto rilevato';

  @override
  String addContactRoutesDetected(int count) {
    return '$count percorsi rilevati — SmartRouter sceglie il più veloce';
  }

  @override
  String get addContactFetchingProfile => 'Recupero profilo…';

  @override
  String addContactProfileFound(String name) {
    return 'Trovato: $name';
  }

  @override
  String get addContactNoProfileFound => 'Nessun profilo trovato';

  @override
  String get addContactDisplayNameLabel => 'Nome visualizzato';

  @override
  String get addContactDisplayNameHint => 'Come vuoi chiamarlo?';

  @override
  String get addContactAddManually => 'Aggiungi indirizzo manualmente';

  @override
  String get addContactButton => 'Aggiungi contatto';

  @override
  String get networkDiagnosticsTitle => 'Diagnostica di rete';

  @override
  String get networkDiagnosticsNostrRelays => 'Relay Nostr';

  @override
  String get networkDiagnosticsDirect => 'Diretti';

  @override
  String get networkDiagnosticsTorOnly => 'Solo Tor';

  @override
  String get networkDiagnosticsBest => 'Migliore';

  @override
  String get networkDiagnosticsNone => 'nessuno';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Stato';

  @override
  String get networkDiagnosticsConnected => 'Connesso';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Connessione $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Spento';

  @override
  String get networkDiagnosticsTransport => 'Trasporto';

  @override
  String get networkDiagnosticsInfrastructure => 'Infrastruttura';

  @override
  String get networkDiagnosticsSessionNodes => 'Nodi Session';

  @override
  String get networkDiagnosticsTurnServers => 'Server TURN';

  @override
  String get networkDiagnosticsLastProbe => 'Ultimo test';

  @override
  String get networkDiagnosticsRunning => 'In esecuzione...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Esegui diagnostica';

  @override
  String get networkDiagnosticsForceReprobe => 'Forza nuovo test completo';

  @override
  String get networkDiagnosticsJustNow => 'adesso';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '${minutes}min fa';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '${hours}h fa';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '${days}g fa';
  }

  @override
  String get homeNoEch => 'No ECH';

  @override
  String get homeNoEchTooltip =>
      'Proxy uTLS non disponibile — ECH disabilitato.\nL\'impronta TLS è visibile al DPI.';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Salvato e connesso a $provider';
  }

  @override
  String get settingsTorFailedToStart => 'L\'avvio di Tor integrato è fallito';

  @override
  String get settingsPsiphonFailedToStart => 'L\'avvio di Psiphon è fallito';

  @override
  String get verifyTitle => 'Verifica numero di sicurezza';

  @override
  String get verifyIdentityVerified => 'Identità verificata';

  @override
  String get verifyNotYetVerified => 'Non ancora verificato';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Hai verificato il numero di sicurezza di $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Confronta questi numeri con $name di persona o tramite un canale fidato.';
  }

  @override
  String get verifyExplanation =>
      'Ogni conversazione ha un numero di sicurezza unico. Se entrambi vedete gli stessi numeri sui vostri dispositivi, la vostra connessione è verificata end-to-end.';

  @override
  String verifyContactKey(String name) {
    return 'Chiave di $name';
  }

  @override
  String get verifyYourKey => 'La tua chiave';

  @override
  String get verifyRemoveVerification => 'Rimuovi verifica';

  @override
  String get verifyMarkAsVerified => 'Segna come verificato';

  @override
  String verifyAfterReinstall(String name) {
    return 'Se $name reinstalla l\'app, il numero di sicurezza cambierà e la verifica verrà rimossa automaticamente.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Segna come verificato solo dopo aver confrontato i numeri con $name tramite chiamata vocale o di persona.';
  }

  @override
  String get verifyNoSession =>
      'Nessuna sessione di crittografia stabilita. Invia prima un messaggio per generare i numeri di sicurezza.';

  @override
  String get verifyNoKeyAvailable => 'Nessuna chiave disponibile';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Impronta digitale di $label copiata';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL del database';

  @override
  String get providerOptionalHint => 'Opzionale';

  @override
  String get providerWebApiKeyLabel => 'Chiave API Web';

  @override
  String get providerOptionalForPublicDb => 'Opzionale per DB pubblico';

  @override
  String get providerRelayUrlLabel => 'URL del relay';

  @override
  String get providerPrivateKeyLabel => 'Chiave privata';

  @override
  String get providerPrivateKeyNsecLabel => 'Chiave privata (nsec)';

  @override
  String get providerStorageNodeLabel =>
      'URL nodo di archiviazione (opzionale)';

  @override
  String get providerStorageNodeHint =>
      'Lascia vuoto per i nodi seme integrati';

  @override
  String get transferInvalidCodeFormat =>
      'Formato codice non riconosciuto — deve iniziare con LAN: o NOS:';

  @override
  String get profileCardFingerprintCopied => 'Impronta digitale copiata';

  @override
  String get profileCardAboutHint => 'Privacy first 🔒';

  @override
  String get profileCardSaveButton => 'Salva profilo';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Esporta messaggi crittografati, contatti e avatar in un file';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Audio';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Consegnato a $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Consegnato a $count';
  }

  @override
  String get groupStatusDialogTitle => 'Info messaggio';

  @override
  String get groupStatusRead => 'Letto';

  @override
  String get groupStatusDelivered => 'Consegnato';

  @override
  String get groupStatusPending => 'In attesa';

  @override
  String get groupStatusNoData => 'Nessuna informazione sulla consegna ancora';

  @override
  String get profileTransferAdmin => 'Nomina amministratore';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Nominare $name nuovo amministratore?';
  }

  @override
  String get profileTransferAdminBody =>
      'Perderai i privilegi di amministratore. Non può essere annullato.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name è ora l\'amministratore';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Informativa sulla privacy';

  @override
  String get privacyOverviewHeading => 'Panoramica';

  @override
  String get privacyOverviewBody =>
      'Pulse è un messenger serverless con crittografia end-to-end. La tua privacy non è solo una funzionalità — è l\'architettura. Non esistono server Pulse. Nessun account è memorizzato da nessuna parte. Nessun dato viene raccolto, trasmesso o conservato dagli sviluppatori.';

  @override
  String get privacyDataCollectionHeading => 'Raccolta dati';

  @override
  String get privacyDataCollectionBody =>
      'Pulse non raccoglie alcun dato personale. Nello specifico:\n\n- Non è richiesto email, numero di telefono o nome reale\n- Nessuna analisi, tracciamento o telemetria\n- Nessun identificatore pubblicitario\n- Nessun accesso alla rubrica\n- Nessun backup cloud (i messaggi esistono solo sul tuo dispositivo)\n- Nessun metadato viene inviato a server Pulse (non ne esistono)';

  @override
  String get privacyEncryptionHeading => 'Crittografia';

  @override
  String get privacyEncryptionBody =>
      'Tutti i messaggi sono crittografati con il protocollo Signal (Double Ratchet con accordo di chiavi X3DH). Le chiavi di crittografia vengono generate e memorizzate esclusivamente sul tuo dispositivo. Nessuno — inclusi gli sviluppatori — può leggere i tuoi messaggi.';

  @override
  String get privacyNetworkHeading => 'Architettura di rete';

  @override
  String get privacyNetworkBody =>
      'Pulse utilizza adattatori di trasporto federati (relay Nostr, nodi del servizio Session/Oxen, Firebase Realtime Database, LAN). Questi trasporti trasportano solo testo cifrato. Gli operatori dei relay possono vedere il tuo indirizzo IP e il volume di traffico, ma non possono decifrare il contenuto dei messaggi.\n\nQuando Tor è abilitato, anche il tuo indirizzo IP è nascosto agli operatori dei relay.';

  @override
  String get privacyStunHeading => 'Server STUN/TURN';

  @override
  String get privacyStunBody =>
      'Le chiamate vocali e video utilizzano WebRTC con crittografia DTLS-SRTP. I server STUN (usati per scoprire il tuo IP pubblico per connessioni peer-to-peer) e i server TURN (usati per inoltrare media quando la connessione diretta fallisce) possono vedere il tuo indirizzo IP e la durata della chiamata, ma non possono decifrare il contenuto della chiamata.\n\nPuoi configurare il tuo server TURN nelle Impostazioni per la massima privacy.';

  @override
  String get privacyCrashHeading => 'Segnalazione crash';

  @override
  String get privacyCrashBody =>
      'Se la segnalazione crash Sentry è abilitata (tramite SENTRY_DSN in fase di compilazione), possono essere inviate segnalazioni di crash anonime. Queste non contengono contenuti di messaggi, informazioni sui contatti o dati personali identificabili. La segnalazione crash può essere disabilitata in fase di compilazione omettendo il DSN.';

  @override
  String get privacyPasswordHeading => 'Password e chiavi';

  @override
  String get privacyPasswordBody =>
      'La tua password di recupero viene utilizzata per derivare chiavi crittografiche tramite Argon2id (KDF memory-hard). La password non viene mai trasmessa da nessuna parte. Se perdi la password, il tuo account non può essere recuperato — non esiste un server per reimpostarla.';

  @override
  String get privacyFontsHeading => 'Caratteri';

  @override
  String get privacyFontsBody =>
      'Pulse include tutti i caratteri localmente. Non vengono effettuate richieste a Google Fonts o qualsiasi servizio di caratteri esterno.';

  @override
  String get privacyThirdPartyHeading => 'Servizi di terze parti';

  @override
  String get privacyThirdPartyBody =>
      'Pulse non si integra con reti pubblicitarie, fornitori di analisi, piattaforme di social media o broker di dati. Le uniche connessioni di rete sono ai relay di trasporto che configuri.';

  @override
  String get privacyOpenSourceHeading => 'Open Source';

  @override
  String get privacyOpenSourceBody =>
      'Pulse è software open-source. Puoi controllare il codice sorgente completo per verificare queste affermazioni sulla privacy.';

  @override
  String get privacyContactHeading => 'Contatti';

  @override
  String get privacyContactBody =>
      'Per domande sulla privacy, apri un issue nel repository del progetto.';

  @override
  String get privacyLastUpdated => 'Ultimo aggiornamento: marzo 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Salvataggio fallito: $error';
  }

  @override
  String get themeEngineTitle => 'Motore dei temi';

  @override
  String get torBuiltInTitle => 'Tor integrato';

  @override
  String get torConnectedSubtitle =>
      'Connesso — Nostr instradato via 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Connessione… $pct%';
  }

  @override
  String get torNotRunning =>
      'Non in esecuzione — tocca l\'interruttore per riavviare';

  @override
  String get torDescription =>
      'Instrada Nostr via Tor (Snowflake per reti censurate)';

  @override
  String get torNetworkDiagnostics => 'Diagnostica di rete';

  @override
  String get torTransportLabel => 'Trasporto: ';

  @override
  String get torPtAuto => 'Auto';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Diretto';

  @override
  String get torTimeoutLabel => 'Timeout: ';

  @override
  String get torInfoDescription =>
      'Quando abilitato, le connessioni WebSocket Nostr vengono instradate tramite Tor (SOCKS5). Tor Browser ascolta su 127.0.0.1:9150. Il demone tor standalone usa la porta 9050. Le connessioni Firebase non sono interessate.';

  @override
  String get torRouteNostrTitle => 'Instrada Nostr via Tor';

  @override
  String get torManagedByBuiltin => 'Gestito da Tor integrato';

  @override
  String get torActiveRouting =>
      'Attivo — traffico Nostr instradato tramite Tor';

  @override
  String get torDisabled => 'Disabilitato';

  @override
  String get torProxySocks5 => 'Proxy Tor (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Host proxy';

  @override
  String get torProxyPortLabel => 'Porta';

  @override
  String get torPortInfo =>
      'Tor Browser: porta 9150  •  demone tor: porta 9050';

  @override
  String get torForceNostrTitle => 'Instrada i messaggi tramite Tor';

  @override
  String get torForceNostrSubtitle =>
      'Tutte le connessioni ai relay Nostr passeranno attraverso Tor. Più lento ma nasconde il tuo IP dai relay.';

  @override
  String get torForceNostrDisabled => 'Tor deve essere attivato prima';

  @override
  String get torForcePulseTitle => 'Instrada il relay Pulse tramite Tor';

  @override
  String get torForcePulseSubtitle =>
      'Tutte le connessioni al relay Pulse passeranno attraverso Tor. Più lento ma nasconde il tuo IP dal server.';

  @override
  String get torForcePulseDisabled => 'Tor deve essere attivato prima';

  @override
  String get i2pProxySocks5 => 'Proxy I2P (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P usa SOCKS5 sulla porta 4447 per impostazione predefinita. Connettiti a un relay Nostr tramite outproxy I2P (es. relay.damus.i2p) per comunicare con utenti su qualsiasi trasporto. Tor ha la priorità quando entrambi sono abilitati.';

  @override
  String get i2pRouteNostrTitle => 'Instrada Nostr via I2P';

  @override
  String get i2pActiveRouting =>
      'Attivo — traffico Nostr instradato tramite I2P';

  @override
  String get i2pDisabled => 'Disabilitato';

  @override
  String get i2pProxyHostLabel => 'Host proxy';

  @override
  String get i2pProxyPortLabel => 'Porta';

  @override
  String get i2pPortInfo => 'Porta SOCKS5 predefinita del router I2P: 4447';

  @override
  String get customProxySocks5 => 'Proxy personalizzato (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'Relay CF Worker';

  @override
  String get customProxyInfoDescription =>
      'Il proxy personalizzato instrada il traffico tramite V2Ray/Xray/Shadowsocks. CF Worker funge da relay proxy personale su CDN Cloudflare — il GFW vede *.workers.dev, non il vero relay.';

  @override
  String get customSocks5ProxyTitle => 'Proxy SOCKS5 personalizzato';

  @override
  String get customProxyActive => 'Attivo — traffico instradato via SOCKS5';

  @override
  String get customProxyDisabled => 'Disabilitato';

  @override
  String get customProxyHostLabel => 'Host proxy';

  @override
  String get customProxyPortLabel => 'Porta';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Dominio Worker (opzionale)';

  @override
  String get customWorkerHelpTitle =>
      'Come distribuire un relay CF Worker (gratuito)';

  @override
  String get customWorkerScriptCopied => 'Script copiato!';

  @override
  String get customWorkerStep1 =>
      '1. Vai su dash.cloudflare.com → Workers & Pages\n2. Crea Worker → incolla questo script:\n';

  @override
  String get customWorkerStep2 =>
      '3. Distribuisci → copia il dominio (es. my-relay.user.workers.dev)\n4. Incolla il dominio sopra → Salva\n\nL\'app si connette automaticamente: wss://dominio/?r=url_relay\nIl GFW vede: connessione a *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Connesso — SOCKS5 su 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Connessione…';

  @override
  String get psiphonNotRunning =>
      'Non in esecuzione — tocca l\'interruttore per riavviare';

  @override
  String get psiphonDescription =>
      'Tunnel veloce (~3s bootstrap, 2000+ VPS a rotazione)';

  @override
  String get turnCommunityServers => 'Server TURN della comunità';

  @override
  String get turnCustomServer => 'Server TURN personalizzato (BYOD)';

  @override
  String get turnInfoDescription =>
      'I server TURN inoltrano solo stream già crittografati (DTLS-SRTP). Un operatore relay vede il tuo IP e il volume di traffico, ma non può decifrare le chiamate. TURN viene usato solo quando il P2P diretto fallisce (~15–20% delle connessioni).';

  @override
  String get turnFreeLabel => 'GRATIS';

  @override
  String get turnServerUrlLabel => 'URL server TURN';

  @override
  String get turnServerUrlHint => 'turn:tuo-server.com:3478 o turns:...';

  @override
  String get turnUsernameLabel => 'Nome utente';

  @override
  String get turnPasswordLabel => 'Password';

  @override
  String get turnOptionalHint => 'Opzionale';

  @override
  String get turnCustomInfo =>
      'Ospita coturn su qualsiasi VPS da \$5/mese per il massimo controllo. Le credenziali sono memorizzate localmente.';

  @override
  String get themePickerAppearance => 'Aspetto';

  @override
  String get themePickerAccentColor => 'Colore di accento';

  @override
  String get themeModeLight => 'Chiaro';

  @override
  String get themeModeDark => 'Scuro';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeDynamicPresets => 'Preset';

  @override
  String get themeDynamicPrimaryColor => 'Colore primario';

  @override
  String get themeDynamicBorderRadius => 'Raggio bordi';

  @override
  String get themeDynamicFont => 'Carattere';

  @override
  String get themeDynamicAppearance => 'Aspetto';

  @override
  String get themeDynamicUiStyle => 'Stile UI';

  @override
  String get themeDynamicUiStyleDescription =>
      'Controlla l\'aspetto di finestre di dialogo, interruttori e indicatori.';

  @override
  String get themeDynamicSharp => 'Angolare';

  @override
  String get themeDynamicRound => 'Arrotondato';

  @override
  String get themeDynamicModeDark => 'Scuro';

  @override
  String get themeDynamicModeLight => 'Chiaro';

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
      'URL Firebase non valido. Formato previsto: https://progetto.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'URL relay non valido. Formato previsto: wss://relay.esempio.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'URL server Pulse non valido. Formato previsto: https://server:porta';

  @override
  String get providerPulseServerUrlLabel => 'URL del server';

  @override
  String get providerPulseServerUrlHint => 'https://tuo-server:8443';

  @override
  String get providerPulseInviteLabel => 'Codice invito';

  @override
  String get providerPulseInviteHint => 'Codice invito (se richiesto)';

  @override
  String get providerPulseInfo =>
      'Relay self-hosted. Chiavi derivate dalla tua password di recupero.';

  @override
  String get providerScreenTitle => 'Caselle di posta';

  @override
  String get providerSecondaryInboxesHeader => 'CASELLE SECONDARIE';

  @override
  String get providerSecondaryInboxesInfo =>
      'Le caselle secondarie ricevono messaggi simultaneamente per ridondanza.';

  @override
  String get providerRemoveTooltip => 'Rimuovi';

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
  String get emojiNoRecent => 'Nessun emoji recente';

  @override
  String get emojiSearchHint => 'Cerca emoji...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Tocca per chattare';

  @override
  String get imageViewerSaveToDownloads => 'Salva nei Download';

  @override
  String imageViewerSavedTo(String path) {
    return 'Salvato in $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguageSubtitle => 'Lingua di visualizzazione dell\'app';

  @override
  String get settingsLanguageSystem => 'Predefinito di sistema';

  @override
  String get onboardingLanguageTitle => 'Scegli la tua lingua';

  @override
  String get onboardingLanguageSubtitle =>
      'Puoi modificarlo in seguito nelle Impostazioni';

  @override
  String get videoNoteRecord => 'Registra un messaggio video';

  @override
  String get videoNoteTapToRecord => 'Tocca per registrare';

  @override
  String get videoNoteTapToStop => 'Tocca per fermare';

  @override
  String get videoNoteCameraPermission => 'Autorizzazione fotocamera negata';

  @override
  String get videoNoteMaxDuration => 'Massimo 30 secondi';

  @override
  String get videoNoteNotSupported =>
      'Le note video non sono supportate su questa piattaforma';

  @override
  String get navChats => 'Chat';

  @override
  String get navUpdates => 'Aggiornamenti';

  @override
  String get navCalls => 'Chiamate';

  @override
  String get filterAll => 'Tutti';

  @override
  String get filterUnread => 'Non letti';

  @override
  String get filterGroups => 'Gruppi';

  @override
  String get callsNoRecent => 'Nessuna chiamata recente';

  @override
  String get callsEmptySubtitle => 'La cronologia delle chiamate apparirà qui';

  @override
  String get appBarEncrypted => 'crittografia end-to-end';

  @override
  String get newStatus => 'Nuovo stato';

  @override
  String get newCall => 'Nuova chiamata';
}
