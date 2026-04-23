// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Caută în mesaje...';

  @override
  String get search => 'Caută';

  @override
  String get clearSearch => 'Șterge căutarea';

  @override
  String get closeSearch => 'Închide căutarea';

  @override
  String get moreOptions => 'Mai multe opțiuni';

  @override
  String get back => 'Înapoi';

  @override
  String get cancel => 'Anulează';

  @override
  String get close => 'Închide';

  @override
  String get confirm => 'Confirmă';

  @override
  String get remove => 'Elimină';

  @override
  String get save => 'Salvează';

  @override
  String get add => 'Adaugă';

  @override
  String get copy => 'Copiază';

  @override
  String get skip => 'Sari peste';

  @override
  String get done => 'Gata';

  @override
  String get apply => 'Aplică';

  @override
  String get export => 'Exportă';

  @override
  String get import => 'Importă';

  @override
  String get homeNewGroup => 'Grup nou';

  @override
  String get homeSettings => 'Setări';

  @override
  String get homeSearching => 'Se caută în mesaje...';

  @override
  String get homeNoResults => 'Niciun rezultat găsit';

  @override
  String get homeNoChatHistory => 'Încă nu există istoric de conversații';

  @override
  String homeTransportSwitched(String address) {
    return 'Transport schimbat → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name te sună...';
  }

  @override
  String get homeAccept => 'Acceptă';

  @override
  String get homeDecline => 'Refuză';

  @override
  String get homeLoadEarlier => 'Încarcă mesaje anterioare';

  @override
  String get homeChats => 'Conversații';

  @override
  String get homeSelectConversation => 'Selectează o conversație';

  @override
  String get homeNoChatsYet => 'Încă nu ai conversații';

  @override
  String get homeAddContactToStart =>
      'Adaugă un contact pentru a începe să conversezi';

  @override
  String get homeNewChat => 'Conversație nouă';

  @override
  String get homeNewChatTooltip => 'Conversație nouă';

  @override
  String get homeIncomingCallTitle => 'Apel primit';

  @override
  String get homeIncomingGroupCallTitle => 'Apel de grup primit';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — apel de grup primit';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Nicio conversație corespunzătoare cu \"$query\"';
  }

  @override
  String get homeSectionChats => 'Conversații';

  @override
  String get homeSectionMessages => 'Mesaje';

  @override
  String get homeDbEncryptionUnavailable =>
      'Criptarea bazei de date indisponibilă — instalează SQLCipher pentru protecție completă';

  @override
  String get chatFileTooLargeGroup =>
      'Fișierele mai mari de 512 KB nu sunt acceptate în conversațiile de grup';

  @override
  String get chatLargeFile => 'Fișier mare';

  @override
  String get chatCancel => 'Anulează';

  @override
  String get chatSend => 'Trimite';

  @override
  String get chatFileTooLarge =>
      'Fișier prea mare — dimensiunea maximă este 100 MB';

  @override
  String get chatMicDenied => 'Permisiunea microfonului a fost refuzată';

  @override
  String get chatVoiceFailed =>
      'Nu s-a putut salva mesajul vocal — verifică spațiul de stocare disponibil';

  @override
  String get chatScheduleFuture => 'Ora programată trebuie să fie în viitor';

  @override
  String get chatToday => 'Astăzi';

  @override
  String get chatYesterday => 'Ieri';

  @override
  String get chatEdited => 'editat';

  @override
  String get chatYou => 'Tu';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Acest fișier are $size MB. Trimiterea fișierelor mari poate fi lentă pe unele rețele. Continui?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Cheia de securitate a lui $name s-a schimbat. Atinge pentru verificare.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Nu s-a putut cripta mesajul pentru $name — mesajul nu a fost trimis.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Numărul de siguranță pentru $name s-a schimbat. Atinge pentru verificare.';
  }

  @override
  String get chatNoMessagesFound => 'Niciun mesaj găsit';

  @override
  String get chatMessagesE2ee => 'Mesajele sunt criptate end-to-end';

  @override
  String get chatSayHello => 'Salută';

  @override
  String get appBarOnline => 'online';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'scrie';

  @override
  String get appBarSearchMessages => 'Caută în mesaje...';

  @override
  String get appBarMute => 'Dezactivează sunet';

  @override
  String get appBarUnmute => 'Activează sunet';

  @override
  String get appBarMedia => 'Media';

  @override
  String get appBarDisappearing => 'Mesaje care dispar';

  @override
  String get appBarDisappearingOn => 'Dispariție: activată';

  @override
  String get appBarGroupSettings => 'Setări grup';

  @override
  String get appBarSearchTooltip => 'Caută în mesaje';

  @override
  String get appBarVoiceCall => 'Apel vocal';

  @override
  String get appBarVideoCall => 'Apel video';

  @override
  String get inputMessage => 'Mesaj...';

  @override
  String get inputAttachFile => 'Atașează fișier';

  @override
  String get inputSendMessage => 'Trimite mesaj';

  @override
  String get inputRecordVoice => 'Înregistrează mesaj vocal';

  @override
  String get inputSendVoice => 'Trimite mesaj vocal';

  @override
  String get inputCancelReply => 'Anulează răspunsul';

  @override
  String get inputCancelEdit => 'Anulează editarea';

  @override
  String get inputCancelRecording => 'Anulează înregistrarea';

  @override
  String get inputRecording => 'Se înregistrează…';

  @override
  String get inputEditingMessage => 'Se editează mesajul';

  @override
  String get inputPhoto => 'Fotografie';

  @override
  String get inputVoiceMessage => 'Mesaj vocal';

  @override
  String get inputFile => 'Fișier';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'e programate',
      one: ' programat',
    );
    return '$count mesaj$_temp0';
  }

  @override
  String get callInitializing => 'Se inițializează apelul…';

  @override
  String get callConnecting => 'Se conectează…';

  @override
  String get callConnectingRelay => 'Se conectează (relay)…';

  @override
  String get callSwitchingRelay => 'Se comută la modul relay…';

  @override
  String get callConnectionFailed => 'Conexiunea a eșuat';

  @override
  String get callReconnecting => 'Se reconectează…';

  @override
  String get callEnded => 'Apel încheiat';

  @override
  String get callLive => 'Live';

  @override
  String get callEnd => 'Sfârșit';

  @override
  String get callEndCall => 'Închide apelul';

  @override
  String get callMute => 'Dezactivează sunet';

  @override
  String get callUnmute => 'Activează sunet';

  @override
  String get callSpeaker => 'Difuzor';

  @override
  String get callCameraOn => 'Cameră pornită';

  @override
  String get callCameraOff => 'Cameră oprită';

  @override
  String get callShareScreen => 'Partajează ecranul';

  @override
  String get callStopShare => 'Oprește partajarea';

  @override
  String callTorBackup(String duration) {
    return 'Tor de rezervă · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor de rezervă activ — calea principală indisponibilă';

  @override
  String get callDirectFailed =>
      'Conexiunea directă a eșuat — se comută la modul relay…';

  @override
  String get callTurnUnreachable =>
      'Serverele TURN inaccesibile. Adaugă un TURN personalizat în Setări → Avansat.';

  @override
  String get callRelayMode => 'Modul relay activ (rețea restricționată)';

  @override
  String get callStarting => 'Se pornește apelul…';

  @override
  String get callConnectingToGroup => 'Se conectează la grup…';

  @override
  String get callGroupOpenedInBrowser => 'Apel de grup deschis în browser';

  @override
  String get callCouldNotOpenBrowser => 'Nu s-a putut deschide browserul';

  @override
  String get callInviteLinkSent =>
      'Link de invitație trimis tuturor membrilor grupului.';

  @override
  String get callOpenLinkManually =>
      'Deschide linkul de mai sus manual sau atinge pentru a reîncerca.';

  @override
  String get callJitsiNotE2ee => 'Apelurile Jitsi NU sunt criptate end-to-end';

  @override
  String get callRetryOpenBrowser => 'Reîncearcă deschiderea browserului';

  @override
  String get callClose => 'Închide';

  @override
  String get callCamOn => 'Cam. pornită';

  @override
  String get callCamOff => 'Cam. oprită';

  @override
  String get noConnection => 'Fără conexiune — mesajele vor fi puse în coadă';

  @override
  String get connected => 'Conectat';

  @override
  String get connecting => 'Se conectează…';

  @override
  String get disconnected => 'Deconectat';

  @override
  String get offlineBanner =>
      'Fără conexiune — mesajele vor fi trimise când revii online';

  @override
  String get lanModeBanner => 'Mod LAN — Fără internet · Doar rețea locală';

  @override
  String get probeCheckingNetwork => 'Se verifică conectivitatea rețelei…';

  @override
  String get probeDiscoveringRelays =>
      'Se descoperă relay-uri prin directoare comunitate…';

  @override
  String get probeStartingTor => 'Se pornește Tor pentru bootstrap…';

  @override
  String get probeFindingRelaysTor => 'Se caută relay-uri accesibile prin Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '-uri',
      one: '',
    );
    return 'Rețea pregătită — $count relay$_temp0 găsite';
  }

  @override
  String get probeNoRelaysFound =>
      'Niciun relay accesibil găsit — mesajele pot fi întârziate';

  @override
  String get jitsiWarningTitle => 'Fără criptare end-to-end';

  @override
  String get jitsiWarningBody =>
      'Apelurile Jitsi Meet nu sunt criptate de Pulse. Folosește doar pentru conversații nesensibile.';

  @override
  String get jitsiConfirm => 'Intră oricum';

  @override
  String get jitsiGroupWarningTitle => 'Fără criptare end-to-end';

  @override
  String get jitsiGroupWarningBody =>
      'Acest apel are prea mulți participanți pentru rețeaua criptată integrată.\n\nUn link Jitsi Meet va fi deschis în browser. Jitsi NU este criptat end-to-end — serverul poate vedea apelul tău.';

  @override
  String get jitsiContinueAnyway => 'Continuă oricum';

  @override
  String get retry => 'Reîncearcă';

  @override
  String get setupCreateAnonymousAccount => 'Creează un cont anonim';

  @override
  String get setupTapToChangeColor => 'Atinge pentru a schimba culoarea';

  @override
  String get setupReqMinLength => 'Cel puțin 16 caractere';

  @override
  String get setupReqVariety =>
      '3 din 4: majuscule, minuscule, cifre, simboluri';

  @override
  String get setupReqMatch => 'Parolele se potrivesc';

  @override
  String get setupYourNickname => 'Porecla ta';

  @override
  String get setupRecoveryPassword => 'Parolă de recuperare (min. 16)';

  @override
  String get setupConfirmPassword => 'Confirmă parola';

  @override
  String get setupMin16Chars => 'Minimum 16 caractere';

  @override
  String get setupPasswordsDoNotMatch => 'Parolele nu se potrivesc';

  @override
  String get setupEntropyWeak => 'Slabă';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Puternică';

  @override
  String get setupEntropyWeakNeedsVariety =>
      'Slabă (sunt necesare 3 tipuri de caractere)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits biți)';
  }

  @override
  String get setupPasswordWarning =>
      'Această parolă este singura modalitate de a-ți recupera contul. Nu există server — nu se poate reseta parola. Memorez-o sau notează-o.';

  @override
  String get setupCreateAccount => 'Creează cont';

  @override
  String get setupAlreadyHaveAccount => 'Ai deja un cont? ';

  @override
  String get setupRestore => 'Recuperează →';

  @override
  String get restoreTitle => 'Recuperează contul';

  @override
  String get restoreInfoBanner =>
      'Introdu parola de recuperare — adresa ta (Nostr + Session) va fi restaurată automat. Contactele și mesajele au fost stocate doar local.';

  @override
  String get restoreNewNickname => 'Poreclă nouă (se poate schimba mai târziu)';

  @override
  String get restoreButton => 'Recuperează contul';

  @override
  String get lockTitle => 'Pulse este blocat';

  @override
  String get lockSubtitle => 'Introdu parola pentru a continua';

  @override
  String get lockPasswordHint => 'Parolă';

  @override
  String get lockUnlock => 'Deblochează';

  @override
  String get lockPanicHint =>
      'Ai uitat parola? Introdu cheia de panică pentru a șterge toate datele.';

  @override
  String get lockTooManyAttempts =>
      'Prea multe încercări. Se șterg toate datele…';

  @override
  String get lockWrongPassword => 'Parolă greșită';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Parolă greșită — $attempts/$max încercări';
  }

  @override
  String get onboardingSkip => 'Sari peste';

  @override
  String get onboardingNext => 'Următorul';

  @override
  String get onboardingGetStarted => 'Creează cont';

  @override
  String get onboardingWelcomeTitle => 'Bine ai venit în Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Un messenger descentralizat, criptat end-to-end.\n\nFără servere centrale. Fără colectare de date. Fără uși ascunse.\nConversațiile tale aparțin doar ție.';

  @override
  String get onboardingTransportTitle => 'Independent de transport';

  @override
  String get onboardingTransportBody =>
      'Folosește Firebase, Nostr sau ambele simultan.\n\nMesajele se rutează automat prin rețele. Suport integrat Tor și I2P pentru rezistență la cenzură.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Fiecare mesaj este criptat cu protocolul Signal (Double Ratchet + X3DH) pentru secret înainte.\n\nÎn plus, învelit cu Kyber-1024 — un algoritm post-quantum standard NIST — protejând împotriva viitorilor calculatoare cuantice.';

  @override
  String get onboardingKeysTitle => 'Cheile tale îți aparțin';

  @override
  String get onboardingKeysBody =>
      'Cheile tale de identitate nu părăsesc niciodată dispozitivul.\n\nAmprentele Signal permit verificarea contactelor în afara benzii. TOFU (Trust On First Use) detectează automat schimbările de chei.';

  @override
  String get onboardingThemeTitle => 'Alege-ți aspectul';

  @override
  String get onboardingThemeBody =>
      'Alege o temă și o culoare de accent. Poți schimba oricând din Setări.';

  @override
  String get contactsNewChat => 'Conversație nouă';

  @override
  String get contactsAddContact => 'Adaugă contact';

  @override
  String get contactsSearchHint => 'Caută...';

  @override
  String get contactsNewGroup => 'Grup nou';

  @override
  String get contactsNoContactsYet => 'Încă nu ai contacte';

  @override
  String get contactsAddHint => 'Atinge + pentru a adăuga adresa cuiva';

  @override
  String get contactsNoMatch => 'Niciun contact corespunzător';

  @override
  String get contactsRemoveTitle => 'Elimină contact';

  @override
  String contactsRemoveMessage(String name) {
    return 'Elimini $name?';
  }

  @override
  String get contactsRemove => 'Elimină';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'e',
      one: '',
    );
    return '$count contact$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Deschide link';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Deschizi acest URL în browser?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Deschide';

  @override
  String get bubbleSecurityWarning => 'Avertisment de securitate';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" este un fișier executabil. Salvarea și rularea acestuia ar putea dăuna dispozitivului tău. Salvezi oricum?';
  }

  @override
  String get bubbleSaveAnyway => 'Salvează oricum';

  @override
  String bubbleSavedTo(String path) {
    return 'Salvat în $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Salvare eșuată: $error';
  }

  @override
  String get bubbleNotEncrypted => 'NECRIPTAT';

  @override
  String get bubbleCorruptedImage => '[Imagine coruptă]';

  @override
  String get bubbleReplyPhoto => 'Fotografie';

  @override
  String get bubbleReplyVoice => 'Mesaj vocal';

  @override
  String get bubbleReplyVideo => 'Mesaj video';

  @override
  String bubbleReadBy(String names) {
    return 'Citit de $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Citit de $count';
  }

  @override
  String get chatTileTapToStart => 'Atinge pentru a începe conversația';

  @override
  String get chatTileMessageSent => 'Mesaj trimis';

  @override
  String get chatTileEncryptedMessage => 'Mesaj criptat';

  @override
  String chatTileYouPrefix(String text) {
    return 'Tu: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Mesaj vocal';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Mesaj vocal ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Mesaj criptat';

  @override
  String get groupNewGroup => 'Grup nou';

  @override
  String get groupGroupName => 'Numele grupului';

  @override
  String get groupSelectMembers => 'Selectează membrii (min. 2)';

  @override
  String get groupNoContactsYet =>
      'Încă nu ai contacte. Adaugă contacte mai întâi.';

  @override
  String get groupCreate => 'Creează';

  @override
  String get groupLabel => 'Grup';

  @override
  String get profileVerifyIdentity => 'Verifică identitatea';

  @override
  String profileVerifyInstructions(String name) {
    return 'Compară aceste amprente cu $name într-un apel vocal sau personal. Dacă ambele valori se potrivesc pe ambele dispozitive, atinge „Marcare ca verificat“.';
  }

  @override
  String get profileTheirKey => 'Cheia lor';

  @override
  String get profileYourKey => 'Cheia ta';

  @override
  String get profileRemoveVerification => 'Elimină verificarea';

  @override
  String get profileMarkAsVerified => 'Marchează ca verificat';

  @override
  String get profileAddressCopied => 'Adresă copiată';

  @override
  String get profileNoContactsToAdd =>
      'Niciun contact de adăugat — toți sunt deja membri';

  @override
  String get profileAddMembers => 'Adaugă membri';

  @override
  String profileAddCount(int count) {
    return 'Adaugă ($count)';
  }

  @override
  String get profileRenameGroup => 'Redenumește grupul';

  @override
  String get profileRename => 'Redenumește';

  @override
  String get profileRemoveMember => 'Elimini membrul?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Elimini pe $name din acest grup?';
  }

  @override
  String get profileKick => 'Elimină';

  @override
  String get profileSignalFingerprints => 'Amprente Signal';

  @override
  String get profileVerified => 'VERIFICAT';

  @override
  String get profileVerify => 'Verifică';

  @override
  String get profileEdit => 'Editează';

  @override
  String get profileNoSession =>
      'Nicio sesiune stabilită încă — trimite mai întâi un mesaj.';

  @override
  String get profileFingerprintCopied => 'Amprentă copiată';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'i',
      one: 'u',
    );
    return '$count membr$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Verifică numărul de siguranță';

  @override
  String get profileShowContactQr => 'Afișează QR contact';

  @override
  String profileContactAddress(String name) {
    return 'Adresa lui $name';
  }

  @override
  String get profileExportChatHistory => 'Exportă istoricul conversației';

  @override
  String profileSavedTo(String path) {
    return 'Salvat în $path';
  }

  @override
  String get profileExportFailed => 'Exportul a eșuat';

  @override
  String get profileClearChatHistory => 'Șterge istoricul conversației';

  @override
  String get profileDeleteGroup => 'Șterge grupul';

  @override
  String get profileDeleteContact => 'Șterge contactul';

  @override
  String get profileLeaveGroup => 'Părăsește grupul';

  @override
  String get profileLeaveGroupBody =>
      'Vei fi eliminat din acest grup și acesta va fi șters din contactele tale.';

  @override
  String get groupInviteTitle => 'Invitație la grup';

  @override
  String groupInviteBody(String from, String group) {
    return '$from te-a invitat să te alături grupului \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Acceptă';

  @override
  String get groupInviteDecline => 'Refuză';

  @override
  String get groupMemberLimitTitle => 'Prea mulți participanți';

  @override
  String groupMemberLimitBody(int count) {
    return 'Acest grup va avea $count participanți. Apelurile mesh criptate suportă maximum 6. Grupurile mai mari vor folosi Jitsi (fără E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Adaugă oricum';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name a refuzat invitația la grupul \"$group\"';
  }

  @override
  String get transferTitle => 'Transfer pe alt dispozitiv';

  @override
  String get transferInfoBox =>
      'Mută identitatea Signal și cheile Nostr pe un dispozitiv nou.\nSesiunile de chat NU sunt transferate — secretul înainte este păstrat.';

  @override
  String get transferSendFromThis => 'Trimite de pe acest dispozitiv';

  @override
  String get transferSendSubtitle =>
      'Acest dispozitiv are cheile. Partajează un cod cu noul dispozitiv.';

  @override
  String get transferReceiveOnThis => 'Primește pe acest dispozitiv';

  @override
  String get transferReceiveSubtitle =>
      'Acesta este noul dispozitiv. Introdu codul de pe dispozitivul vechi.';

  @override
  String get transferChooseMethod => 'Alege metoda de transfer';

  @override
  String get transferLan => 'LAN (aceeași rețea)';

  @override
  String get transferLanSubtitle =>
      'Rapid și direct. Ambele dispozitive trebuie să fie pe aceeași rețea Wi-Fi.';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'Funcționează prin orice rețea folosind un relay Nostr existent.';

  @override
  String get transferRelayUrl => 'URL Relay';

  @override
  String get transferEnterCode => 'Introdu codul de transfer';

  @override
  String get transferPasteCode => 'Lipește codul LAN:... sau NOS:... aici';

  @override
  String get transferConnect => 'Conectează';

  @override
  String get transferGenerating => 'Se generează codul de transfer…';

  @override
  String get transferShareCode => 'Partajează acest cod cu receptorul:';

  @override
  String get transferCopyCode => 'Copiază codul';

  @override
  String get transferCodeCopied => 'Cod copiat în clipboard';

  @override
  String get transferWaitingReceiver => 'Se așteaptă conectarea receptorului…';

  @override
  String get transferConnectingSender => 'Se conectează la expeditor…';

  @override
  String get transferVerifyBoth =>
      'Compară acest cod pe ambele dispozitive.\nDacă se potrivesc, transferul este securizat.';

  @override
  String get transferComplete => 'Transfer finalizat';

  @override
  String get transferKeysImported => 'Chei importate';

  @override
  String get transferCompleteSenderBody =>
      'Cheile tale rămân active pe acest dispozitiv.\nReceptorul poate folosi acum identitatea ta.';

  @override
  String get transferCompleteReceiverBody =>
      'Chei importate cu succes.\nRepornește aplicația pentru a aplica noua identitate.';

  @override
  String get transferRestartApp => 'Repornește aplicația';

  @override
  String get transferFailed => 'Transferul a eșuat';

  @override
  String get transferTryAgain => 'Încearcă din nou';

  @override
  String get transferEnterRelayFirst => 'Introdu mai întâi un URL de relay';

  @override
  String get transferPasteCodeFromSender =>
      'Lipește codul de transfer de la expeditor';

  @override
  String get menuReply => 'Răspunde';

  @override
  String get menuForward => 'Redirecționează';

  @override
  String get menuReact => 'Reacționează';

  @override
  String get menuCopy => 'Copiază';

  @override
  String get menuEdit => 'Editează';

  @override
  String get menuRetry => 'Reîncearcă';

  @override
  String get menuCancelScheduled => 'Anulează programarea';

  @override
  String get menuDelete => 'Șterge';

  @override
  String get menuForwardTo => 'Redirecționează către…';

  @override
  String menuForwardedTo(String name) {
    return 'Redirecționat către $name';
  }

  @override
  String get menuScheduledMessages => 'Mesaje programate';

  @override
  String get menuNoScheduledMessages => 'Niciun mesaj programat';

  @override
  String menuSendsOn(String date) {
    return 'Se trimite la $date';
  }

  @override
  String get menuDisappearingMessages => 'Mesaje care dispar';

  @override
  String get menuDisappearingSubtitle =>
      'Mesajele se șterg automat după timpul selectat.';

  @override
  String get menuTtlOff => 'Dezactivat';

  @override
  String get menuTtl1h => '1 oră';

  @override
  String get menuTtl24h => '24 ore';

  @override
  String get menuTtl7d => '7 zile';

  @override
  String get menuAttachPhoto => 'Fotografie';

  @override
  String get menuAttachFile => 'Fișier';

  @override
  String get menuAttachVideo => 'Video';

  @override
  String get mediaTitle => 'Media';

  @override
  String get mediaFileLabel => 'FIȘIER';

  @override
  String mediaPhotosTab(int count) {
    return 'Fotografii ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Fișiere ($count)';
  }

  @override
  String get mediaNoPhotos => 'Încă nu există fotografii';

  @override
  String get mediaNoFiles => 'Încă nu există fișiere';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Salvat în Descărcări/$name';
  }

  @override
  String get mediaFailedToSave => 'Salvarea fișierului a eșuat';

  @override
  String get statusNewStatus => 'Status nou';

  @override
  String get statusPublish => 'Publică';

  @override
  String get statusExpiresIn24h => 'Statusul expiră în 24 de ore';

  @override
  String get statusWhatsOnYourMind => 'La ce te gândești?';

  @override
  String get statusPhotoAttached => 'Fotografie atașată';

  @override
  String get statusAttachPhoto => 'Atașează fotografie (opțional)';

  @override
  String get statusEnterText =>
      'Te rugăm să introduci un text pentru statusul tău.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Nu s-a putut selecta fotografia: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Publicarea a eșuat: $error';
  }

  @override
  String get panicSetPanicKey => 'Setează cheia de panică';

  @override
  String get panicEmergencySelfDestruct => 'Auto-distrugere de urgență';

  @override
  String get panicIrreversible => 'Această acțiune este ireversibilă';

  @override
  String get panicWarningBody =>
      'Introducerea acestei chei pe ecranul de blocare șterge instantaneu TOATE datele — mesaje, contacte, chei, identitate. Folosește o cheie diferită de parola ta obișnuită.';

  @override
  String get panicKeyHint => 'Cheie de panică';

  @override
  String get panicConfirmHint => 'Confirmă cheia de panică';

  @override
  String get panicMinChars =>
      'Cheia de panică trebuie să aibă cel puțin 8 caractere';

  @override
  String get panicKeysDoNotMatch => 'Cheile nu se potrivesc';

  @override
  String get panicSetFailed =>
      'Nu s-a putut salva cheia de panică — te rugăm să încerci din nou';

  @override
  String get passwordSetAppPassword => 'Setează parola aplicației';

  @override
  String get passwordProtectsMessages => 'Protejează mesajele tale în repaus';

  @override
  String get passwordInfoBanner =>
      'Necesară de fiecare dată când deschizi Pulse. Dacă este uitată, datele tale nu pot fi recuperate.';

  @override
  String get passwordHint => 'Parolă';

  @override
  String get passwordConfirmHint => 'Confirmă parola';

  @override
  String get passwordSetButton => 'Setează parola';

  @override
  String get passwordSkipForNow => 'Sari peste deocamdată';

  @override
  String get passwordMinChars => 'Parola trebuie să aibă cel puțin 8 caractere';

  @override
  String get passwordNeedsVariety =>
      'Trebuie să conțină litere, cifre și caractere speciale';

  @override
  String get passwordRequirements =>
      'Min. 8 caractere cu litere, cifre și un caracter special';

  @override
  String get passwordsDoNotMatch => 'Parolele nu se potrivesc';

  @override
  String get profileCardSaved => 'Profil salvat!';

  @override
  String get profileCardE2eeIdentity => 'Identitate E2EE';

  @override
  String get profileCardDisplayName => 'Nume afișat';

  @override
  String get profileCardDisplayNameHint => 'ex. Ion Popescu';

  @override
  String get profileCardAbout => 'Despre';

  @override
  String get profileCardSaveProfile => 'Salvează profilul';

  @override
  String get profileCardYourName => 'Numele tău';

  @override
  String get profileCardAddressCopied => 'Adresă copiată!';

  @override
  String get profileCardInboxAddress => 'Adresa ta de inbox';

  @override
  String get profileCardInboxAddresses => 'Adresele tale de inbox';

  @override
  String get profileCardShareAllAddresses =>
      'Partajează toate adresele (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Partajează cu contactele pentru a-ți putea trimite mesaje.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Toate cele $count adrese copiate ca un singur link!';
  }

  @override
  String get settingsMyProfile => 'Profilul meu';

  @override
  String get settingsYourInboxAddress => 'Adresa ta de inbox';

  @override
  String get settingsMyQrCode => 'Partajează contactul';

  @override
  String get settingsMyQrSubtitle =>
      'Cod QR și link de invitație pentru adresa ta';

  @override
  String get settingsShareMyAddress => 'Partajează adresa mea';

  @override
  String get settingsNoAddressYet =>
      'Încă nu ai o adresă — salvează mai întâi setările';

  @override
  String get settingsInviteLink => 'Link de invitație';

  @override
  String get settingsRawAddress => 'Adresă brută';

  @override
  String get settingsCopyLink => 'Copiază linkul';

  @override
  String get settingsCopyAddress => 'Copiază adresa';

  @override
  String get settingsInviteLinkCopied => 'Link de invitație copiat';

  @override
  String get settingsAppearance => 'Aspect';

  @override
  String get settingsThemeEngine => 'Motor de teme';

  @override
  String get settingsThemeEngineSubtitle =>
      'Personalizează culorile și fonturile';

  @override
  String get settingsSignalProtocol => 'Protocolul Signal';

  @override
  String get settingsSignalProtocolSubtitle =>
      'Cheile E2EE sunt stocate în siguranță';

  @override
  String get settingsActive => 'ACTIV';

  @override
  String get settingsIdentityBackup => 'Copie de rezervă identitate';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Exportă sau importă identitatea Signal';

  @override
  String get settingsIdentityBackupBody =>
      'Exportă cheile de identitate Signal într-un cod de rezervă sau restaurează din unul existent.';

  @override
  String get settingsTransferDevice => 'Transfer pe alt dispozitiv';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Mută identitatea prin LAN sau Nostr relay';

  @override
  String get settingsExportIdentity => 'Exportă identitatea';

  @override
  String get settingsExportIdentityBody =>
      'Copiază acest cod de rezervă și păstrează-l în siguranță:';

  @override
  String get settingsSaveFile => 'Salvează fișierul';

  @override
  String get settingsImportIdentity => 'Importă identitatea';

  @override
  String get settingsImportIdentityBody =>
      'Lipește codul de rezervă mai jos. Aceasta va suprascrie identitatea ta curentă.';

  @override
  String get settingsPasteBackupCode => 'Lipește codul de rezervă aici…';

  @override
  String get settingsIdentityImported =>
      'Identitate + contacte importate! Repornește aplicația pentru a aplica.';

  @override
  String get settingsSecurity => 'Securitate';

  @override
  String get settingsAppPassword => 'Parolă aplicație';

  @override
  String get settingsPasswordEnabled =>
      'Activată — necesară la fiecare lansare';

  @override
  String get settingsPasswordDisabled =>
      'Dezactivată — aplicația se deschide fără parolă';

  @override
  String get settingsChangePassword => 'Schimbă parola';

  @override
  String get settingsChangePasswordSubtitle =>
      'Actualizează parola de blocare a aplicației';

  @override
  String get settingsSetPanicKey => 'Setează cheia de panică';

  @override
  String get settingsChangePanicKey => 'Schimbă cheia de panică';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Actualizează cheia de ștergere de urgență';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'O cheie care șterge instantaneu toate datele';

  @override
  String get settingsRemovePanicKey => 'Elimină cheia de panică';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Dezactivează auto-distrugerea de urgență';

  @override
  String get settingsRemovePanicKeyBody =>
      'Auto-distrugerea de urgență va fi dezactivată. O poți reactiva oricând.';

  @override
  String get settingsDisableAppPassword => 'Dezactivează parola aplicației';

  @override
  String get settingsEnterCurrentPassword =>
      'Introdu parola curentă pentru confirmare';

  @override
  String get settingsCurrentPassword => 'Parola curentă';

  @override
  String get settingsIncorrectPassword => 'Parolă incorectă';

  @override
  String get settingsPasswordUpdated => 'Parolă actualizată';

  @override
  String get settingsChangePasswordProceed =>
      'Introdu parola curentă pentru a continua';

  @override
  String get settingsData => 'Date';

  @override
  String get settingsBackupMessages => 'Copie de rezervă mesaje';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Exportă istoricul criptat al mesajelor într-un fișier';

  @override
  String get settingsRestoreMessages => 'Restaurează mesajele';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Importă mesaje dintr-un fișier de rezervă';

  @override
  String get settingsExportKeys => 'Exportă cheile';

  @override
  String get settingsExportKeysSubtitle =>
      'Salvează cheile de identitate într-un fișier criptat';

  @override
  String get settingsImportKeys => 'Importă cheile';

  @override
  String get settingsImportKeysSubtitle =>
      'Restaurează cheile de identitate dintr-un fișier exportat';

  @override
  String get settingsBackupPassword => 'Parolă de rezervă';

  @override
  String get settingsPasswordCannotBeEmpty => 'Parola nu poate fi goală';

  @override
  String get settingsPasswordMin4Chars =>
      'Parola trebuie să aibă cel puțin 4 caractere';

  @override
  String get settingsCallsTurn => 'Apeluri & TURN';

  @override
  String get settingsLocalNetwork => 'Rețea locală';

  @override
  String get settingsCensorshipResistance => 'Rezistență la cenzură';

  @override
  String get settingsNetwork => 'Rețea';

  @override
  String get settingsProxyTunnels => 'Proxy & Tuneluri';

  @override
  String get settingsTurnServers => 'Servere TURN';

  @override
  String get settingsProviderTitle => 'Furnizor';

  @override
  String get settingsLanFallback => 'Fallback LAN';

  @override
  String get settingsLanFallbackSubtitle =>
      'Transmite prezența și livrează mesaje în rețeaua locală când internetul nu este disponibil. Dezactivează în rețele nesigure (Wi-Fi public).';

  @override
  String get settingsBgDelivery => 'Livrare în fundal';

  @override
  String get settingsBgDeliverySubtitle =>
      'Continuă să primești mesaje când aplicația este minimizată. Afișează o notificare persistentă.';

  @override
  String get settingsYourInboxProvider => 'Furnizorul tău de inbox';

  @override
  String get settingsConnectionDetails => 'Detalii conexiune';

  @override
  String get settingsSaveAndConnect => 'Salvează și conectează';

  @override
  String get settingsSecondaryInboxes => 'Inbox-uri secundare';

  @override
  String get settingsAddSecondaryInbox => 'Adaugă inbox secundar';

  @override
  String get settingsAdvanced => 'Avansat';

  @override
  String get settingsDiscover => 'Descoperă';

  @override
  String get settingsAbout => 'Despre';

  @override
  String get settingsPrivacyPolicy => 'Politica de confidențialitate';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Cum protejează Pulse datele tale';

  @override
  String get settingsCrashReporting => 'Raportare erori';

  @override
  String get settingsCrashReportingSubtitle =>
      'Trimite rapoarte anonime de erori pentru a îmbunătăți Pulse. Niciun conținut de mesaje sau contacte nu este trimis vreodată.';

  @override
  String get settingsCrashReportingEnabled =>
      'Raportare erori activată — repornește aplicația pentru a aplica';

  @override
  String get settingsCrashReportingDisabled =>
      'Raportare erori dezactivată — repornește aplicația pentru a aplica';

  @override
  String get settingsSensitiveOperation => 'Operație sensibilă';

  @override
  String get settingsSensitiveOperationBody =>
      'Aceste chei sunt identitatea ta. Oricine are acest fișier te poate impersona. Păstrează-l în siguranță și șterge-l după transfer.';

  @override
  String get settingsIUnderstandContinue => 'Am înțeles, continuă';

  @override
  String get settingsReplaceIdentity => 'Înlocuiești identitatea?';

  @override
  String get settingsReplaceIdentityBody =>
      'Aceasta va suprascrie cheile tale de identitate curente. Sesiunile Signal existente vor fi invalidate și contactele vor trebui să restabilească criptarea. Aplicația va trebui repornită.';

  @override
  String get settingsReplaceKeys => 'Înlocuiește cheile';

  @override
  String get settingsKeysImported => 'Chei importate';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count chei importate cu succes. Te rugăm să repornești aplicația pentru a reinițializa cu noua identitate.';
  }

  @override
  String get settingsRestartNow => 'Repornește acum';

  @override
  String get settingsLater => 'Mai târziu';

  @override
  String get profileGroupLabel => 'Grup';

  @override
  String get profileAddButton => 'Adaugă';

  @override
  String get profileKickButton => 'Elimină';

  @override
  String get dataSectionTitle => 'Date';

  @override
  String get dataBackupMessages => 'Copie de rezervă mesaje';

  @override
  String get dataBackupPasswordSubtitle =>
      'Alege o parolă pentru a cripta copia de rezervă a mesajelor.';

  @override
  String get dataBackupConfirmLabel => 'Creează copie de rezervă';

  @override
  String get dataCreatingBackup => 'Se creează copia de rezervă';

  @override
  String get dataBackupPreparing => 'Se pregătește...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Se exportă mesajul $done din $total...';
  }

  @override
  String get dataBackupSavingFile => 'Se salvează fișierul...';

  @override
  String get dataSaveMessageBackupDialog =>
      'Salvează copia de rezervă a mesajelor';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Copie de rezervă salvată ($count mesaje)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Copia de rezervă a eșuat — nu s-au exportat date';

  @override
  String dataBackupFailedError(String error) {
    return 'Copia de rezervă a eșuat: $error';
  }

  @override
  String get dataSelectMessageBackupDialog =>
      'Selectează copia de rezervă a mesajelor';

  @override
  String get dataInvalidBackupFile => 'Fișier de rezervă invalid (prea mic)';

  @override
  String get dataNotValidBackupFile =>
      'Nu este un fișier de rezervă Pulse valid';

  @override
  String get dataRestoreMessages => 'Restaurează mesajele';

  @override
  String get dataRestorePasswordSubtitle =>
      'Introdu parola folosită pentru a crea această copie de rezervă.';

  @override
  String get dataRestoreConfirmLabel => 'Restaurează';

  @override
  String get dataRestoringMessages => 'Se restaurează mesajele';

  @override
  String get dataRestoreDecrypting => 'Se decriptează...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Se importă mesajul $done din $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Restaurarea a eșuat — parolă greșită sau fișier corupt';

  @override
  String dataRestoreSuccess(int count) {
    return '$count mesaje noi restaurate';
  }

  @override
  String get dataRestoreNothingNew =>
      'Niciun mesaj nou de importat (toate există deja)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Restaurarea a eșuat: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Selectează exportul de chei';

  @override
  String get dataNotValidKeyFile =>
      'Nu este un fișier valid de export chei Pulse';

  @override
  String get dataExportKeys => 'Exportă cheile';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Alege o parolă pentru a cripta exportul de chei.';

  @override
  String get dataExportKeysConfirmLabel => 'Exportă';

  @override
  String get dataExportingKeys => 'Se exportă cheile';

  @override
  String get dataExportingKeysStatus => 'Se criptează cheile de identitate...';

  @override
  String get dataSaveKeyExportDialog => 'Salvează exportul de chei';

  @override
  String dataKeysExportedTo(String path) {
    return 'Chei exportate în:\n$path';
  }

  @override
  String get dataExportFailed => 'Exportul a eșuat — nu s-au găsit chei';

  @override
  String dataExportFailedError(String error) {
    return 'Exportul a eșuat: $error';
  }

  @override
  String get dataImportKeys => 'Importă cheile';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Introdu parola folosită pentru a cripta acest export de chei.';

  @override
  String get dataImportKeysConfirmLabel => 'Importă';

  @override
  String get dataImportingKeys => 'Se importă cheile';

  @override
  String get dataImportingKeysStatus =>
      'Se decriptează cheile de identitate...';

  @override
  String get dataImportFailed =>
      'Importul a eșuat — parolă greșită sau fișier corupt';

  @override
  String dataImportFailedError(String error) {
    return 'Importul a eșuat: $error';
  }

  @override
  String get securitySectionTitle => 'Securitate';

  @override
  String get securityIncorrectPassword => 'Parolă incorectă';

  @override
  String get securityPasswordUpdated => 'Parolă actualizată';

  @override
  String get appearanceSectionTitle => 'Aspect';

  @override
  String appearanceExportFailed(String error) {
    return 'Exportul a eșuat: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Salvat în $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Salvare eșuată: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Importul a eșuat: $error';
  }

  @override
  String get aboutSectionTitle => 'Despre';

  @override
  String get providerPublicKey => 'Cheie publică';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Configurat automat din parola de recuperare. Relay descoperit automat.';

  @override
  String get providerKeyStoredLocally =>
      'Cheia ta este stocată local în stocare securizată — nu este trimisă niciodată la vreun server.';

  @override
  String get providerSessionInfo =>
      'Session Network — E2EE cu rutare onion. ID-ul tău de Session este generat automat și stocat în siguranță. Nodurile sunt descoperite automat din nodurile seed integrate.';

  @override
  String get providerAdvanced => 'Avansat';

  @override
  String get providerSaveAndConnect => 'Salvează și conectează';

  @override
  String get providerAddSecondaryInbox => 'Adaugă inbox secundar';

  @override
  String get providerSecondaryInboxes => 'Inbox-uri secundare';

  @override
  String get providerYourInboxProvider => 'Furnizorul tău de inbox';

  @override
  String get providerConnectionDetails => 'Detalii conexiune';

  @override
  String get addContactTitle => 'Adaugă contact';

  @override
  String get addContactInviteLinkLabel => 'Link de invitație sau adresă';

  @override
  String get addContactTapToPaste => 'Atinge pentru a lipi linkul de invitație';

  @override
  String get addContactPasteTooltip => 'Lipește din clipboard';

  @override
  String get addContactAddressDetected => 'Adresă de contact detectată';

  @override
  String addContactRoutesDetected(int count) {
    return '$count rute detectate — SmartRouter alege cea mai rapidă';
  }

  @override
  String get addContactFetchingProfile => 'Se încarcă profilul…';

  @override
  String addContactProfileFound(String name) {
    return 'Găsit: $name';
  }

  @override
  String get addContactNoProfileFound => 'Niciun profil găsit';

  @override
  String get addContactDisplayNameLabel => 'Nume afișat';

  @override
  String get addContactDisplayNameHint => 'Cum vrei să-i numești?';

  @override
  String get addContactAddManually => 'Adaugă adresa manual';

  @override
  String get addContactButton => 'Adaugă contact';

  @override
  String get networkDiagnosticsTitle => 'Diagnosticare rețea';

  @override
  String get networkDiagnosticsNostrRelays => 'Relay-uri Nostr';

  @override
  String get networkDiagnosticsDirect => 'Direct';

  @override
  String get networkDiagnosticsTorOnly => 'Doar Tor';

  @override
  String get networkDiagnosticsBest => 'Cel mai bun';

  @override
  String get networkDiagnosticsNone => 'niciunul';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Stare';

  @override
  String get networkDiagnosticsConnected => 'Conectat';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Se conectează $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Oprit';

  @override
  String get networkDiagnosticsTransport => 'Transport';

  @override
  String get networkDiagnosticsInfrastructure => 'Infrastructură';

  @override
  String get networkDiagnosticsSessionNodes => 'Noduri Session';

  @override
  String get networkDiagnosticsTurnServers => 'Servere TURN';

  @override
  String get networkDiagnosticsLastProbe => 'Ultima verificare';

  @override
  String get networkDiagnosticsRunning => 'Se execută...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Rulează diagnosticarea';

  @override
  String get networkDiagnosticsForceReprobe =>
      'Forțează reverificarea completă';

  @override
  String get networkDiagnosticsJustNow => 'chiar acum';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'acum $minutes min';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'acum $hours ore';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'acum $days zile';
  }

  @override
  String get homeNoEch => 'Fără ECH';

  @override
  String get homeNoEchTooltip =>
      'Proxy uTLS indisponibil — ECH dezactivat.\nAmprenta TLS este vizibilă pentru DPI.';

  @override
  String get settingsTitle => 'Setări';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Salvat și conectat la $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Tor integrat nu a putut fi pornit';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon nu a putut fi pornit';

  @override
  String get verifyTitle => 'Verifică numărul de siguranță';

  @override
  String get verifyIdentityVerified => 'Identitate verificată';

  @override
  String get verifyNotYetVerified => 'Încă neverificat';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Ai verificat numărul de siguranță al lui $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Compară aceste numere cu $name personal sau printr-un canal de încredere.';
  }

  @override
  String get verifyExplanation =>
      'Fiecare conversație are un număr de siguranță unic. Dacă amândoi vedeți aceleași numere pe dispozitivele voastre, conexiunea este verificată end-to-end.';

  @override
  String verifyContactKey(String name) {
    return 'Cheia lui $name';
  }

  @override
  String get verifyYourKey => 'Cheia ta';

  @override
  String get verifyRemoveVerification => 'Elimină verificarea';

  @override
  String get verifyMarkAsVerified => 'Marchează ca verificat';

  @override
  String verifyAfterReinstall(String name) {
    return 'Dacă $name reinstalează aplicația, numărul de siguranță se va schimba și verificarea va fi eliminată automat.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Marchează ca verificat doar după ce ai comparat numerele cu $name într-un apel vocal sau personal.';
  }

  @override
  String get verifyNoSession =>
      'Nicio sesiune de criptare stabilită încă. Trimite mai întâi un mesaj pentru a genera numerele de siguranță.';

  @override
  String get verifyNoKeyAvailable => 'Nicio cheie disponibilă';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Amprentă $label copiată';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL bază de date';

  @override
  String get providerOptionalHint => 'Opțional';

  @override
  String get providerWebApiKeyLabel => 'Cheie API Web';

  @override
  String get providerOptionalForPublicDb =>
      'Opțional pentru baza de date publică';

  @override
  String get providerRelayUrlLabel => 'URL Relay';

  @override
  String get providerPrivateKeyLabel => 'Cheie privată';

  @override
  String get providerPrivateKeyNsecLabel => 'Cheie privată (nsec)';

  @override
  String get providerStorageNodeLabel => 'URL nod de stocare (opțional)';

  @override
  String get providerStorageNodeHint =>
      'Lasă gol pentru nodurile seed integrate';

  @override
  String get transferInvalidCodeFormat =>
      'Format de cod nerecunoscut — trebuie să înceapă cu LAN: sau NOS:';

  @override
  String get profileCardFingerprintCopied => 'Amprentă copiată';

  @override
  String get profileCardAboutHint => 'Confidențialitate mai întâi 🔒';

  @override
  String get profileCardSaveButton => 'Salvează profilul';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Exportă mesaje criptate, contacte și avataruri într-un fișier';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Audio';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Livrat la $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Livrat la $count';
  }

  @override
  String get groupStatusDialogTitle => 'Informații mesaj';

  @override
  String get groupStatusRead => 'Citit';

  @override
  String get groupStatusDelivered => 'Livrat';

  @override
  String get groupStatusPending => 'În așteptare';

  @override
  String get groupStatusNoData => 'Încă nu există informații de livrare';

  @override
  String get profileTransferAdmin => 'Fă administrator';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Faci pe $name noul administrator?';
  }

  @override
  String get profileTransferAdminBody =>
      'Vei pierde privilegiile de administrator. Aceasta nu poate fi anulată.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name este acum administratorul';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Politica de confidențialitate';

  @override
  String get privacyOverviewHeading => 'Prezentare generală';

  @override
  String get privacyOverviewBody =>
      'Pulse este un messenger fără server, criptat end-to-end. Confidențialitatea ta nu este doar o funcție — este arhitectura. Nu există servere Pulse. Niciun cont nu este stocat nicăieri. Nicio dată nu este colectată, transmisă sau stocată de dezvoltatori.';

  @override
  String get privacyDataCollectionHeading => 'Colectarea datelor';

  @override
  String get privacyDataCollectionBody =>
      'Pulse nu colectează date personale. Mai exact:\n\n- Nu necesită email, număr de telefon sau nume real\n- Fără analize, urmărire sau telemetrie\n- Fără identificatori publicitari\n- Fără acces la lista de contacte\n- Fără copii de rezervă în cloud (mesajele există doar pe dispozitivul tău)\n- Nicio metadată nu este trimisă la vreun server Pulse (nu există niciunul)';

  @override
  String get privacyEncryptionHeading => 'Criptare';

  @override
  String get privacyEncryptionBody =>
      'Toate mesajele sunt criptate folosind protocolul Signal (Double Ratchet cu acord de chei X3DH). Cheile de criptare sunt generate și stocate exclusiv pe dispozitivul tău. Nimeni — inclusiv dezvoltatorii — nu poate citi mesajele tale.';

  @override
  String get privacyNetworkHeading => 'Arhitectura rețelei';

  @override
  String get privacyNetworkBody =>
      'Pulse folosește adaptoare de transport federate (relay-uri Nostr, noduri de serviciu Session/Oxen, Firebase Realtime Database, LAN). Aceste transporturi transmit doar text cifrat criptat. Operatorii de relay pot vedea adresa ta IP și volumul de trafic, dar nu pot decripta conținutul mesajelor.\n\nCând Tor este activat, adresa ta IP este ascunsă și de operatorii de relay.';

  @override
  String get privacyStunHeading => 'Servere STUN/TURN';

  @override
  String get privacyStunBody =>
      'Apelurile vocale și video folosesc WebRTC cu criptare DTLS-SRTP. Serverele STUN (folosite pentru a descoperi IP-ul tău public pentru conexiuni peer-to-peer) și serverele TURN (folosite pentru a relaya media când conexiunea directă eșuează) pot vedea adresa ta IP și durata apelului, dar nu pot decripta conținutul apelului.\n\nPoți configura propriul server TURN din Setări pentru confidențialitate maximă.';

  @override
  String get privacyCrashHeading => 'Raportare erori';

  @override
  String get privacyCrashBody =>
      'Dacă raportarea erorilor Sentry este activată (prin SENTRY_DSN la compilare), pot fi trimise rapoarte anonime de erori. Acestea nu conțin conținut de mesaje, informații de contact sau date de identificare personală. Raportarea erorilor poate fi dezactivată la compilare prin omiterea DSN.';

  @override
  String get privacyPasswordHeading => 'Parolă și chei';

  @override
  String get privacyPasswordBody =>
      'Parola de recuperare este folosită pentru a deriva chei criptografice prin Argon2id (KDF rezistent la memorie). Parola nu este transmisă nicăieri. Dacă pierzi parola, contul nu poate fi recuperat — nu există un server pentru a o reseta.';

  @override
  String get privacyFontsHeading => 'Fonturi';

  @override
  String get privacyFontsBody =>
      'Pulse include toate fonturile local. Nu se fac cereri către Google Fonts sau vreun serviciu extern de fonturi.';

  @override
  String get privacyThirdPartyHeading => 'Servicii terțe';

  @override
  String get privacyThirdPartyBody =>
      'Pulse nu se integrează cu nicio rețea publicitară, furnizor de analize, platformă de social media sau broker de date. Singurele conexiuni de rețea sunt către relay-urile de transport pe care le configurezi.';

  @override
  String get privacyOpenSourceHeading => 'Open Source';

  @override
  String get privacyOpenSourceBody =>
      'Pulse este software open-source. Poți audita codul sursă complet pentru a verifica aceste afirmații privind confidențialitatea.';

  @override
  String get privacyContactHeading => 'Contact';

  @override
  String get privacyContactBody =>
      'Pentru întrebări legate de confidențialitate, deschide un issue în repository-ul proiectului.';

  @override
  String get privacyLastUpdated => 'Ultima actualizare: martie 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Salvare eșuată: $error';
  }

  @override
  String get themeEngineTitle => 'Motor de teme';

  @override
  String get torBuiltInTitle => 'Tor integrat';

  @override
  String get torConnectedSubtitle =>
      'Conectat — Nostr rutat prin 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Se conectează… $pct%';
  }

  @override
  String get torNotRunning => 'Nu rulează — atinge pentru a reporni';

  @override
  String get torDescription =>
      'Rutează Nostr prin Tor (Snowflake pentru rețele cenzurate)';

  @override
  String get torNetworkDiagnostics => 'Diagnosticare rețea';

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
  String get torPtPlain => 'Direct';

  @override
  String get torTimeoutLabel => 'Timeout: ';

  @override
  String get torInfoDescription =>
      'Când este activat, conexiunile WebSocket Nostr sunt rutate prin Tor (SOCKS5). Tor Browser ascultă pe 127.0.0.1:9150. Daemonul tor standalone folosește portul 9050. Conexiunile Firebase nu sunt afectate.';

  @override
  String get torRouteNostrTitle => 'Rutează Nostr prin Tor';

  @override
  String get torManagedByBuiltin => 'Gestionat de Tor integrat';

  @override
  String get torActiveRouting => 'Activ — traficul Nostr rutat prin Tor';

  @override
  String get torDisabled => 'Dezactivat';

  @override
  String get torProxySocks5 => 'Proxy Tor (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Host proxy';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser: port 9150  •  tor daemon: port 9050';

  @override
  String get torForceNostrTitle => 'Rutează mesajele prin Tor';

  @override
  String get torForceNostrSubtitle =>
      'Toate conexiunile relay-urilor Nostr vor trece prin Tor. Mai lent, dar ascunde IP-ul tău de relay-uri.';

  @override
  String get torForceNostrDisabled => 'Tor trebuie activat mai întâi';

  @override
  String get torForcePulseTitle => 'Rutează relay-ul Pulse prin Tor';

  @override
  String get torForcePulseSubtitle =>
      'Toate conexiunile relay-ului Pulse vor trece prin Tor. Mai lent, dar ascunde IP-ul tău de server.';

  @override
  String get torForcePulseDisabled => 'Tor trebuie activat mai întâi';

  @override
  String get i2pProxySocks5 => 'Proxy I2P (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P folosește SOCKS5 pe portul 4447 implicit. Conectează-te la un relay Nostr prin I2P outproxy (ex. relay.damus.i2p) pentru a comunica cu utilizatori pe orice transport. Tor are prioritate când ambele sunt activate.';

  @override
  String get i2pRouteNostrTitle => 'Rutează Nostr prin I2P';

  @override
  String get i2pActiveRouting => 'Activ — traficul Nostr rutat prin I2P';

  @override
  String get i2pDisabled => 'Dezactivat';

  @override
  String get i2pProxyHostLabel => 'Host proxy';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'Portul SOCKS5 implicit al routerului I2P: 4447';

  @override
  String get customProxySocks5 => 'Proxy personalizat (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Proxy-ul personalizat rutează traficul prin V2Ray/Xray/Shadowsocks. CF Worker acționează ca un proxy relay personal pe Cloudflare CDN — GFW vede *.workers.dev, nu relay-ul real.';

  @override
  String get customSocks5ProxyTitle => 'Proxy SOCKS5 personalizat';

  @override
  String get customProxyActive => 'Activ — trafic rutat prin SOCKS5';

  @override
  String get customProxyDisabled => 'Dezactivat';

  @override
  String get customProxyHostLabel => 'Host proxy';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Domeniu Worker (opțional)';

  @override
  String get customWorkerHelpTitle =>
      'Cum să implementezi un CF Worker relay (gratuit)';

  @override
  String get customWorkerScriptCopied => 'Script copiat!';

  @override
  String get customWorkerStep1 =>
      '1. Mergi la dash.cloudflare.com → Workers & Pages\n2. Create Worker → lipește acest script:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → copiază domeniul (ex. my-relay.user.workers.dev)\n4. Lipește domeniul mai sus → Salvează\n\nAplicația se conectează automat: wss://domain/?r=relay_url\nGFW vede: conexiune la *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Conectat — SOCKS5 pe 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Se conectează…';

  @override
  String get psiphonNotRunning => 'Nu rulează — atinge pentru a reporni';

  @override
  String get psiphonDescription =>
      'Tunel rapid (~3s bootstrap, 2000+ VPS-uri rotative)';

  @override
  String get turnCommunityServers => 'Servere TURN comunitate';

  @override
  String get turnCustomServer => 'Server TURN personalizat (BYOD)';

  @override
  String get turnInfoDescription =>
      'Serverele TURN transmit doar fluxuri deja criptate (DTLS-SRTP). Un operator de relay poate vedea IP-ul tău și volumul de trafic, dar nu poate decripta apelurile. TURN este folosit doar când P2P direct eșuează (~15–20% din conexiuni).';

  @override
  String get turnFreeLabel => 'GRATUIT';

  @override
  String get turnServerUrlLabel => 'URL server TURN';

  @override
  String get turnServerUrlHint => 'turn:serverul-tau.com:3478 sau turns:...';

  @override
  String get turnUsernameLabel => 'Nume utilizator';

  @override
  String get turnPasswordLabel => 'Parolă';

  @override
  String get turnOptionalHint => 'Opțional';

  @override
  String get turnCustomInfo =>
      'Găzduiește coturn pe orice VPS de 5\$/lună pentru control maxim. Datele de autentificare sunt stocate local.';

  @override
  String get themePickerAppearance => 'Aspect';

  @override
  String get themePickerAccentColor => 'Culoare de accent';

  @override
  String get themeModeLight => 'Deschis';

  @override
  String get themeModeDark => 'Întunecat';

  @override
  String get themeModeSystem => 'Sistem';

  @override
  String get themeDynamicPresets => 'Presetări';

  @override
  String get themeDynamicPrimaryColor => 'Culoare primară';

  @override
  String get themeDynamicBorderRadius => 'Raza bordurii';

  @override
  String get themeDynamicFont => 'Font';

  @override
  String get themeDynamicAppearance => 'Aspect';

  @override
  String get themeDynamicUiStyle => 'Stil UI';

  @override
  String get themeDynamicUiStyleDescription =>
      'Controlează aspectul dialogurilor, comutatoarelor și indicatoarelor.';

  @override
  String get themeDynamicSharp => 'Ascuțit';

  @override
  String get themeDynamicRound => 'Rotunjit';

  @override
  String get themeDynamicModeDark => 'Întunecat';

  @override
  String get themeDynamicModeLight => 'Deschis';

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
      'URL Firebase invalid. Se așteaptă https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'URL relay invalid. Se așteaptă wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'URL server Pulse invalid. Se așteaptă https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'URL server';

  @override
  String get providerPulseServerUrlHint => 'https://serverul-tau:8443';

  @override
  String get providerPulseInviteLabel => 'Cod de invitație';

  @override
  String get providerPulseInviteHint => 'Cod de invitație (dacă este necesar)';

  @override
  String get providerPulseInfo =>
      'Relay auto-găzduit. Chei derivate din parola de recuperare.';

  @override
  String get providerScreenTitle => 'Inbox-uri';

  @override
  String get providerSecondaryInboxesHeader => 'INBOX-URI SECUNDARE';

  @override
  String get providerSecondaryInboxesInfo =>
      'Inbox-urile secundare primesc mesaje simultan pentru redundanță.';

  @override
  String get providerRemoveTooltip => 'Elimină';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... sau hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... sau cheie privată hex';

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
  String get emojiNoRecent => 'Niciun emoji recent';

  @override
  String get emojiSearchHint => 'Caută emoji...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Atinge pentru a conversa';

  @override
  String get imageViewerSaveToDownloads => 'Salvează în Descărcări';

  @override
  String imageViewerSavedTo(String path) {
    return 'Salvat în $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Limbă';

  @override
  String get settingsLanguageSubtitle => 'Limba de afișare a aplicației';

  @override
  String get settingsLanguageSystem => 'Implicit sistem';

  @override
  String get onboardingLanguageTitle => 'Alege-ți limba';

  @override
  String get onboardingLanguageSubtitle => 'Poți schimba mai târziu din Setări';

  @override
  String get videoNoteRecord => 'Înregistrează mesaj video';

  @override
  String get videoNoteTapToRecord => 'Atinge pentru a înregistra';

  @override
  String get videoNoteTapToStop => 'Atinge pentru a opri';

  @override
  String get videoNoteCameraPermission => 'Permisiunea camerei a fost refuzată';

  @override
  String get videoNoteMaxDuration => 'Maximum 30 de secunde';

  @override
  String get videoNoteNotSupported =>
      'Notele video nu sunt acceptate pe această platformă';

  @override
  String get navChats => 'Conversații';

  @override
  String get navUpdates => 'Actualizări';

  @override
  String get navCalls => 'Apeluri';

  @override
  String get filterAll => 'Toate';

  @override
  String get filterUnread => 'Necitite';

  @override
  String get filterGroups => 'Grupuri';

  @override
  String get callsNoRecent => 'Niciun apel recent';

  @override
  String get callsEmptySubtitle => 'Istoricul apelurilor va apărea aici';

  @override
  String get appBarEncrypted => 'criptat de la capăt la capăt';

  @override
  String get newStatus => 'Stare nouă';

  @override
  String get newCall => 'Apel nou';

  @override
  String get joinChannelTitle => 'Alătură-te canalului';

  @override
  String get joinChannelDescription => 'URL CANAL';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'Se obțin informațiile canalului…';

  @override
  String get joinChannelNotFound => 'Niciun canal găsit la acest URL';

  @override
  String get joinChannelNetworkError => 'Nu s-a putut contacta serverul';

  @override
  String get joinChannelAlreadyJoined => 'Deja abonat';

  @override
  String get joinChannelButton => 'Alătură-te';

  @override
  String get channelFeedEmpty => 'Încă nu există postări';

  @override
  String get channelLeave => 'Părăsește canalul';

  @override
  String get channelLeaveConfirm =>
      'Părăsești acest canal? Postările salvate vor fi șterse.';

  @override
  String get channelInfo => 'Info canal';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'editat';

  @override
  String get channelLoadMore => 'Încarcă mai multe';

  @override
  String get channelSearchPosts => 'Căutare postare…';

  @override
  String get channelNoResults => 'Nicio postare potrivită';

  @override
  String get channelUrl => 'URL canal';

  @override
  String get channelCreated => 'Alăturat';

  @override
  String channelPostCount(int count) {
    return '$count postări';
  }

  @override
  String get channelCopyUrl => 'Copiază URL';

  @override
  String get setupNext => 'Următor';

  @override
  String get setupKeyWarning =>
      'A recovery key will be generated for you. It is the only way to restore your account on a new device — there is no server, no password reset.';

  @override
  String get setupKeyTitle => 'Your Recovery Key';

  @override
  String get setupKeySubtitle =>
      'Write this key down and store it in a safe place. You will need it to restore your account on a new device.';

  @override
  String get setupKeyCopied => 'Copiat!';

  @override
  String get setupKeyWroteItDown => 'Am notat-o';

  @override
  String get setupKeyWarnBody =>
      'Write this key down as a backup. You can also view it later in Settings → Security.';

  @override
  String get setupVerifyTitle => 'Verify Recovery Key';

  @override
  String get setupVerifySubtitle =>
      'Re-enter your recovery key to confirm you saved it correctly.';

  @override
  String get setupVerifyButton => 'Verifică';

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
  String get settingsViewRecoveryKey => 'Vizualizare cheie de recuperare';

  @override
  String get settingsViewRecoveryKeySubtitle =>
      'Afișează cheia de recuperare a contului';

  @override
  String get settingsRecoveryKeyNotStored =>
      'Cheia de recuperare nu este disponibilă (creată înainte de această funcție)';

  @override
  String get settingsRecoveryKeyWarning =>
      'Păstrați această cheie în siguranță. Oricine o are poate restaura contul dvs. pe alt dispozitiv.';

  @override
  String get replaceIdentityTitle => 'Înlocuiești identitatea existentă?';

  @override
  String get replaceIdentityBodyRestore =>
      'O identitate există deja pe acest dispozitiv. Restaurarea va înlocui permanent cheia Nostr și seed-ul Oxen curente. Toate contactele vor pierde posibilitatea de a ajunge la adresa ta curentă.\n\nAceastă acțiune nu poate fi anulată.';

  @override
  String get replaceIdentityBodyCreate =>
      'O identitate există deja pe acest dispozitiv. Crearea uneia noi va înlocui permanent cheia Nostr și seed-ul Oxen curente. Toate contactele vor pierde posibilitatea de a ajunge la adresa ta curentă.\n\nAceastă acțiune nu poate fi anulată.';

  @override
  String get replace => 'Înlocuiește';

  @override
  String get callNoScreenSources => 'Nu sunt surse de ecran disponibile';

  @override
  String get callScreenShareQuality => 'Calitatea partajării ecranului';

  @override
  String get callFrameRate => 'Rată de cadre';

  @override
  String get callResolution => 'Rezoluție';

  @override
  String get callAutoResolution => 'Auto = rezoluția nativă a ecranului';

  @override
  String get callStartSharing => 'Începe partajarea';

  @override
  String get callCameraUnavailable =>
      'Camera indisponibilă — poate fi folosită de altă aplicație';

  @override
  String get themeResetToDefaults => 'Resetare la valori implicite';

  @override
  String get backupSaveToDownloadsTitle =>
      'Salvezi copia de rezervă în Descărcări?';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'Selectorul de fișiere nu este disponibil. Copia de rezervă va fi salvată în:\n$path';
  }

  @override
  String get systemLabel => 'Sistem';

  @override
  String get next => 'Următorul';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return 'Încă $remaining atingeri pentru a activa modul dezvoltator';
  }

  @override
  String get devModeEnabled => 'Modul dezvoltator activat';

  @override
  String get devTools => 'Instrumente dezvoltator';

  @override
  String get devAdapterDiagnostics => 'Comutatoare adaptor și diagnosticare';

  @override
  String get devEnableAll => 'Activează toate';

  @override
  String get devDisableAll => 'Dezactivează toate';

  @override
  String get turnUrlValidation =>
      'URL-ul TURN trebuie să înceapă cu turn: sau turns: (max 512 caractere)';

  @override
  String get callMissedCall => 'Apel pierdut';

  @override
  String get callOutgoingCall => 'Apel efectuat';

  @override
  String get callIncomingCall => 'Apel primit';

  @override
  String get mediaMissingData => 'Lipsesc date media';

  @override
  String get mediaDownloadFailed => 'Descărcarea a eșuat';

  @override
  String get mediaDecryptFailed => 'Decriptarea a eșuat';

  @override
  String get callEndCallBanner => 'Încheie apelul';

  @override
  String get meFallback => 'Eu';

  @override
  String get imageSaveToDownloads => 'Salvează în Descărcări';

  @override
  String imageSavedToPath(String path) {
    return 'Salvat în $path';
  }

  @override
  String get callScreenShareRequiresPermission =>
      'Partajarea ecranului necesită permisiune';

  @override
  String get callScreenShareUnavailable => 'Partajarea ecranului indisponibilă';

  @override
  String get statusJustNow => 'Chiar acum';

  @override
  String statusMinutesAgo(int minutes) {
    return 'acum ${minutes}m';
  }

  @override
  String statusHoursAgo(int hours) {
    return 'acum ${hours}h';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rute',
      one: '1 rută',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => 'Gata de adăugat';

  @override
  String groupSelectedCount(int count) {
    return '$count selectate';
  }

  @override
  String get paste => 'Lipește';

  @override
  String get sfuAudioOnly => 'Doar audio';

  @override
  String sfuParticipants(int count) {
    return '$count participanți';
  }

  @override
  String get dataUnencryptedBackup => 'Copie de rezervă necriptată';

  @override
  String get dataUnencryptedBackupBody =>
      'Acest fișier este o copie de rezervă necriptată a identității și va suprascrie cheile tale curente. Importă doar fișiere create de tine. Continui?';

  @override
  String get dataImportAnyway => 'Importă oricum';

  @override
  String get securityStorageError =>
      'Eroare stocare de securitate — repornește aplicația';

  @override
  String get aboutDevModeActive => 'Modul dezvoltator activ';

  @override
  String get themeColors => 'Culori';

  @override
  String get themePrimaryAccent => 'Accent primar';

  @override
  String get themeSecondaryAccent => 'Accent secundar';

  @override
  String get themeBackground => 'Fundal';

  @override
  String get themeSurface => 'Suprafață';

  @override
  String get themeChatBubbles => 'Baloane de chat';

  @override
  String get themeOutgoingMessage => 'Mesaj trimis';

  @override
  String get themeIncomingMessage => 'Mesaj primit';

  @override
  String get themeShape => 'Formă';

  @override
  String get devSectionDeveloper => 'Dezvoltator';

  @override
  String get devAdapterChannelsHint =>
      'Canale adaptor — dezactivează pentru a testa transporturi specifice.';

  @override
  String get devNostrRelays => 'Relee Nostr (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Session Network';

  @override
  String get devPulseRelay => 'Releu Pulse auto-găzduit';

  @override
  String get devLanNetwork => 'Rețea locală (UDP/TCP)';

  @override
  String get devSectionCalls => 'Apeluri';

  @override
  String get devForceTurnRelay => 'Forțează TURN relay';

  @override
  String get devForceTurnRelaySubtitle =>
      'Dezactivează P2P — toate apelurile doar prin servere TURN';

  @override
  String get devRestartWarning =>
      '⚠ Modificările se aplică la următoarea trimitere/apel. Repornește aplicația pentru a se aplica la mesajele primite.';

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
  String get pulseUseServerTitle => 'Folosești serverul Pulse?';

  @override
  String pulseUseServerBody(String name, String host) {
    return '$name folosește serverul Pulse $host. Te alături pentru a conversa mai rapid (și cu alții pe același server)?';
  }

  @override
  String pulseContactUsesPulse(String name) {
    return '$name folosește Pulse';
  }

  @override
  String pulseJoinForFaster(String host) {
    return 'Alătură-te la $host pentru chat mai rapid';
  }

  @override
  String get pulseNotNow => 'Nu acum';

  @override
  String get pulseJoin => 'Alătură-te';

  @override
  String get pulseDismiss => 'Închide';

  @override
  String get pulseHide7Days => 'Ascunde pentru 7 zile';

  @override
  String get pulseNeverAskAgain => 'Nu mai întreba';

  @override
  String get groupSearchContactsHint => 'Caută contacte…';

  @override
  String get systemActorYou => 'Tu';

  @override
  String get systemActorPeer => 'Contact';

  @override
  String systemTtlEnabled(String actor, String duration) {
    return '$actor a activat mesajele care dispar: $duration';
  }

  @override
  String systemTtlDisabled(String actor) {
    return '$actor a dezactivat mesajele care dispar';
  }

  @override
  String get menuClearChatHistory => 'Șterge istoricul conversației';

  @override
  String get clearChatTitle => 'Ștergi istoricul conversației?';

  @override
  String get clearChatBody =>
      'Toate mesajele din această conversație vor fi șterse de pe acest dispozitiv. Cealaltă persoană își va păstra copia.';

  @override
  String get clearChatAction => 'Șterge';

  @override
  String systemGroupRenamed(String actor, String name) {
    return '$actor a redenumit grupul în „$name\"';
  }

  @override
  String systemGroupAvatarChanged(String actor) {
    return '$actor a schimbat fotografia grupului';
  }

  @override
  String systemGroupMetaChanged(String actor, String name) {
    return '$actor a redenumit grupul în „$name\" și a schimbat fotografia';
  }

  @override
  String get profileInviteLink => 'Link de invitație';

  @override
  String get profileInviteLinkSubtitle => 'Oricine are linkul se poate alătura';

  @override
  String get profileInviteLinkCopied => 'Link de invitație copiat';

  @override
  String get groupInviteLinkTitle => 'Te alături grupului?';

  @override
  String groupInviteLinkBody(String name, int count) {
    return 'Ai fost invitat în „$name\" ($count membri).';
  }

  @override
  String get groupInviteLinkJoin => 'Alătură-te';

  @override
  String get drawerCreateGroup => 'Creează grup';

  @override
  String get drawerJoinGroup => 'Alătură-te grupului';

  @override
  String get drawerJoinGroupByLinkInvalid =>
      'Acela nu pare un link de invitație Pulse';

  @override
  String get groupModeMeshTitle => 'Obișnuit';

  @override
  String groupModeMeshSubtitle(int n) {
    return 'Fără server, până la $n persoane';
  }

  @override
  String get groupModeSfuTitle => 'Cu server Pulse';

  @override
  String groupModeSfuSubtitle(int n) {
    return 'Prin server, până la $n persoane';
  }

  @override
  String get groupPulseServerHint => 'https://serverul-tau-pulse';

  @override
  String get groupPulseServerClosed =>
      'Server închis (necesită cod de invitație)';

  @override
  String get groupPulseInviteHint => 'Cod de invitație';

  @override
  String groupMeshLimitReached(int n) {
    return 'Acest tip de apel este limitat la $n persoane';
  }
}
