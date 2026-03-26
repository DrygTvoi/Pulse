// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Cerca missatges...';

  @override
  String get search => 'Cerca';

  @override
  String get clearSearch => 'Esborra la cerca';

  @override
  String get closeSearch => 'Tanca la cerca';

  @override
  String get moreOptions => 'Més opcions';

  @override
  String get back => 'Enrere';

  @override
  String get cancel => 'Cancel·la';

  @override
  String get close => 'Tanca';

  @override
  String get confirm => 'Confirma';

  @override
  String get remove => 'Elimina';

  @override
  String get save => 'Desa';

  @override
  String get add => 'Afegeix';

  @override
  String get copy => 'Copia';

  @override
  String get skip => 'Omet';

  @override
  String get done => 'Fet';

  @override
  String get apply => 'Aplica';

  @override
  String get export => 'Exporta';

  @override
  String get import => 'Importa';

  @override
  String get homeNewGroup => 'Grup nou';

  @override
  String get homeSettings => 'Configuració';

  @override
  String get homeSearching => 'Cercant missatges...';

  @override
  String get homeNoResults => 'No s\'han trobat resultats';

  @override
  String get homeNoChatHistory => 'Encara no hi ha historial de xats';

  @override
  String homeTransportSwitched(String address) {
    return 'Transport canviat → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name està trucant...';
  }

  @override
  String get homeAccept => 'Accepta';

  @override
  String get homeDecline => 'Rebutja';

  @override
  String get homeLoadEarlier => 'Carrega missatges anteriors';

  @override
  String get homeChats => 'Xats';

  @override
  String get homeSelectConversation => 'Selecciona una conversa';

  @override
  String get homeNoChatsYet => 'Encara no hi ha xats';

  @override
  String get homeAddContactToStart =>
      'Afegeix un contacte per començar a xatejar';

  @override
  String get homeNewChat => 'Xat nou';

  @override
  String get homeNewChatTooltip => 'Xat nou';

  @override
  String get homeIncomingCallTitle => 'Trucada entrant';

  @override
  String get homeIncomingGroupCallTitle => 'Trucada de grup entrant';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — trucada de grup entrant';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Cap xat coincideix amb \"$query\"';
  }

  @override
  String get homeSectionChats => 'Xats';

  @override
  String get homeSectionMessages => 'Missatges';

  @override
  String get homeDbEncryptionUnavailable =>
      'Xifratge de base de dades no disponible — instal·leu SQLCipher per a protecció completa';

  @override
  String get chatFileTooLargeGroup =>
      'Els fitxers de més de 512 KB no són compatibles amb xats de grup';

  @override
  String get chatLargeFile => 'Fitxer gran';

  @override
  String get chatCancel => 'Cancel·la';

  @override
  String get chatSend => 'Envia';

  @override
  String get chatFileTooLarge =>
      'El fitxer és massa gran — la mida màxima és 100 MB';

  @override
  String get chatMicDenied => 'Permís de micròfon denegat';

  @override
  String get chatVoiceFailed =>
      'No s\'ha pogut desar el missatge de veu — comproveu l\'espai disponible';

  @override
  String get chatScheduleFuture => 'L\'hora programada ha de ser en el futur';

  @override
  String get chatToday => 'Avui';

  @override
  String get chatYesterday => 'Ahir';

  @override
  String get chatEdited => 'editat';

  @override
  String get chatYou => 'Tu';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Aquest fitxer fa $size MB. Enviar fitxers grans pot ser lent en algunes xarxes. Continuar?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'La clau de seguretat de $name ha canviat. Toca per verificar.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'No s\'ha pogut xifrar el missatge per a $name — el missatge no s\'ha enviat.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'El número de seguretat de $name ha canviat. Toca per verificar.';
  }

  @override
  String get chatNoMessagesFound => 'No s\'han trobat missatges';

  @override
  String get chatMessagesE2ee =>
      'Els missatges estan xifrats d\'extrem a extrem';

  @override
  String get chatSayHello => 'Digues hola';

  @override
  String get appBarOnline => 'en línia';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'escrivint';

  @override
  String get appBarSearchMessages => 'Cerca missatges...';

  @override
  String get appBarMute => 'Silencia';

  @override
  String get appBarUnmute => 'Activa el so';

  @override
  String get appBarMedia => 'Multimèdia';

  @override
  String get appBarDisappearing => 'Missatges temporals';

  @override
  String get appBarDisappearingOn => 'Temporals: activats';

  @override
  String get appBarGroupSettings => 'Configuració del grup';

  @override
  String get appBarSearchTooltip => 'Cerca missatges';

  @override
  String get appBarVoiceCall => 'Trucada de veu';

  @override
  String get appBarVideoCall => 'Videotrucada';

  @override
  String get inputMessage => 'Missatge...';

  @override
  String get inputAttachFile => 'Adjunta fitxer';

  @override
  String get inputSendMessage => 'Envia missatge';

  @override
  String get inputRecordVoice => 'Grava missatge de veu';

  @override
  String get inputSendVoice => 'Envia missatge de veu';

  @override
  String get inputCancelReply => 'Cancel·la la resposta';

  @override
  String get inputCancelEdit => 'Cancel·la l\'edició';

  @override
  String get inputCancelRecording => 'Cancel·la la gravació';

  @override
  String get inputRecording => 'Gravant…';

  @override
  String get inputEditingMessage => 'Editant missatge';

  @override
  String get inputPhoto => 'Foto';

  @override
  String get inputVoiceMessage => 'Missatge de veu';

  @override
  String get inputFile => 'Fitxer';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count missatge$_temp0 programat$_temp1';
  }

  @override
  String get callInitializing => 'Iniciant trucada…';

  @override
  String get callConnecting => 'Connectant…';

  @override
  String get callConnectingRelay => 'Connectant (retransmissió)…';

  @override
  String get callSwitchingRelay => 'Canviant a mode de retransmissió…';

  @override
  String get callConnectionFailed => 'La connexió ha fallat';

  @override
  String get callReconnecting => 'Reconnectant…';

  @override
  String get callEnded => 'Trucada finalitzada';

  @override
  String get callLive => 'En directe';

  @override
  String get callEnd => 'Fi';

  @override
  String get callEndCall => 'Penja';

  @override
  String get callMute => 'Silencia';

  @override
  String get callUnmute => 'Activa el so';

  @override
  String get callSpeaker => 'Altaveu';

  @override
  String get callCameraOn => 'Càmera activada';

  @override
  String get callCameraOff => 'Càmera desactivada';

  @override
  String get callShareScreen => 'Comparteix pantalla';

  @override
  String get callStopShare => 'Atura la compartició';

  @override
  String callTorBackup(String duration) {
    return 'Tor de reserva · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor de reserva actiu — ruta primària no disponible';

  @override
  String get callDirectFailed =>
      'La connexió directa ha fallat — canviant a mode de retransmissió…';

  @override
  String get callTurnUnreachable =>
      'Servidors TURN inaccessibles. Afegiu un servidor TURN personalitzat a Configuració → Avançat.';

  @override
  String get callRelayMode => 'Mode de retransmissió actiu (xarxa restringida)';

  @override
  String get callStarting => 'Iniciant trucada…';

  @override
  String get callConnectingToGroup => 'Connectant al grup…';

  @override
  String get callGroupOpenedInBrowser => 'Trucada de grup oberta al navegador';

  @override
  String get callCouldNotOpenBrowser => 'No s\'ha pogut obrir el navegador';

  @override
  String get callInviteLinkSent =>
      'Enllaç d\'invitació enviat a tots els membres del grup.';

  @override
  String get callOpenLinkManually =>
      'Obriu l\'enllaç de dalt manualment o toqueu per tornar-ho a provar.';

  @override
  String get callJitsiNotE2ee =>
      'Les trucades Jitsi NO estan xifrades d\'extrem a extrem';

  @override
  String get callRetryOpenBrowser => 'Torna a obrir el navegador';

  @override
  String get callClose => 'Tanca';

  @override
  String get callCamOn => 'Càmera activada';

  @override
  String get callCamOff => 'Càmera desactivada';

  @override
  String get noConnection => 'Sense connexió — els missatges s\'encuaran';

  @override
  String get connected => 'Connectat';

  @override
  String get connecting => 'Connectant…';

  @override
  String get disconnected => 'Desconnectat';

  @override
  String get offlineBanner =>
      'Sense connexió — els missatges s\'enviaran quan torneu a estar en línia';

  @override
  String get lanModeBanner => 'Mode LAN — Sense internet · Només xarxa local';

  @override
  String get probeCheckingNetwork => 'Comprovant la connectivitat de xarxa…';

  @override
  String get probeDiscoveringRelays =>
      'Descobrint retransmissors via directoris comunitaris…';

  @override
  String get probeStartingTor => 'Iniciant Tor per a l\'arrencada…';

  @override
  String get probeFindingRelaysTor =>
      'Trobant retransmissors accessibles via Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'Xarxa preparada — $count retransmissor$_temp0 trobat$_temp1';
  }

  @override
  String get probeNoRelaysFound =>
      'No s\'han trobat retransmissors accessibles — els missatges poden retardar-se';

  @override
  String get jitsiWarningTitle => 'No xifrat d\'extrem a extrem';

  @override
  String get jitsiWarningBody =>
      'Les trucades de Jitsi Meet no estan xifrades per Pulse. Utilitzeu-les només per a converses no sensibles.';

  @override
  String get jitsiConfirm => 'Uneix-t\'hi igualment';

  @override
  String get jitsiGroupWarningTitle => 'No xifrat d\'extrem a extrem';

  @override
  String get jitsiGroupWarningBody =>
      'Aquesta trucada té massa participants per a la malla xifrada integrada.\n\nS\'obrirà un enllaç de Jitsi Meet al navegador. Jitsi NO està xifrat d\'extrem a extrem — el servidor pot veure la trucada.';

  @override
  String get jitsiContinueAnyway => 'Continua igualment';

  @override
  String get retry => 'Torna-ho a provar';

  @override
  String get setupCreateAnonymousAccount => 'Crea un compte anònim';

  @override
  String get setupTapToChangeColor => 'Toca per canviar el color';

  @override
  String get setupYourNickname => 'El teu sobrenom';

  @override
  String get setupRecoveryPassword => 'Contrasenya de recuperació (mín. 16)';

  @override
  String get setupConfirmPassword => 'Confirma la contrasenya';

  @override
  String get setupMin16Chars => 'Mínim 16 caràcters';

  @override
  String get setupPasswordsDoNotMatch => 'Les contrasenyes no coincideixen';

  @override
  String get setupEntropyWeak => 'Feble';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Fort';

  @override
  String get setupEntropyWeakNeedsVariety => 'Feble (cal 3 tipus de caràcters)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bits)';
  }

  @override
  String get setupPasswordWarning =>
      'Aquesta contrasenya és l\'única manera de recuperar el teu compte. No hi ha servidor — no es pot restablir la contrasenya. Recorda-la o apunta-la.';

  @override
  String get setupCreateAccount => 'Crea un compte';

  @override
  String get setupAlreadyHaveAccount => 'Ja tens un compte? ';

  @override
  String get setupRestore => 'Recupera →';

  @override
  String get restoreTitle => 'Recupera el compte';

  @override
  String get restoreInfoBanner =>
      'Introdueix la teva contrasenya de recuperació — la teva adreça (Nostr + Session) es recuperarà automàticament. Els contactes i missatges només estaven desats localment.';

  @override
  String get restoreNewNickname => 'Nou sobrenom (es pot canviar després)';

  @override
  String get restoreButton => 'Recupera el compte';

  @override
  String get lockTitle => 'Pulse està bloquejat';

  @override
  String get lockSubtitle => 'Introdueix la contrasenya per continuar';

  @override
  String get lockPasswordHint => 'Contrasenya';

  @override
  String get lockUnlock => 'Desbloqueja';

  @override
  String get lockPanicHint =>
      'Has oblidat la contrasenya? Introdueix la clau de pànic per esborrar totes les dades.';

  @override
  String get lockTooManyAttempts => 'Massa intents. Esborrant totes les dades…';

  @override
  String get lockWrongPassword => 'Contrasenya incorrecta';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Contrasenya incorrecta — $attempts/$max intents';
  }

  @override
  String get onboardingSkip => 'Omet';

  @override
  String get onboardingNext => 'Següent';

  @override
  String get onboardingGetStarted => 'Comencem';

  @override
  String get onboardingWelcomeTitle => 'Benvingut a Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Un missatger descentralitzat amb xifratge d\'extrem a extrem.\n\nSense servidors centrals. Sense recollida de dades. Sense portes del darrere.\nLes teves converses només et pertanyen a tu.';

  @override
  String get onboardingTransportTitle => 'Agnòstic del transport';

  @override
  String get onboardingTransportBody =>
      'Utilitza Firebase, Nostr, o tots dos alhora.\n\nEls missatges s\'encaminen automàticament a través de les xarxes. Suport integrat per a Tor i I2P per a resistència a la censura.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Cada missatge es xifra amb el protocol Signal (Double Ratchet + X3DH) per a secret cap endavant.\n\nA més, embolcallat amb Kyber-1024 — un algorisme post-quàntic estàndard NIST — que protegeix contra futurs ordinadors quàntics.';

  @override
  String get onboardingKeysTitle => 'Les teves claus són teves';

  @override
  String get onboardingKeysBody =>
      'Les teves claus d\'identitat mai surten del teu dispositiu.\n\nLes empremtes digitals de Signal permeten verificar contactes fora de banda. TOFU (Trust On First Use) detecta canvis de claus automàticament.';

  @override
  String get onboardingThemeTitle => 'Tria el teu aspecte';

  @override
  String get onboardingThemeBody =>
      'Tria un tema i un color d\'accent. Sempre pots canviar-ho més tard a Configuració.';

  @override
  String get contactsNewChat => 'Xat nou';

  @override
  String get contactsAddContact => 'Afegeix contacte';

  @override
  String get contactsSearchHint => 'Cerca...';

  @override
  String get contactsNewGroup => 'Grup nou';

  @override
  String get contactsNoContactsYet => 'Encara no hi ha contactes';

  @override
  String get contactsAddHint => 'Toca + per afegir l\'adreça d\'algú';

  @override
  String get contactsNoMatch => 'Cap contacte coincideix';

  @override
  String get contactsRemoveTitle => 'Elimina el contacte';

  @override
  String contactsRemoveMessage(String name) {
    return 'Eliminar $name?';
  }

  @override
  String get contactsRemove => 'Elimina';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count contacte$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Obre l\'enllaç';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Obrir aquesta URL al navegador?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Obre';

  @override
  String get bubbleSecurityWarning => 'Avís de seguretat';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" és un tipus de fitxer executable. Desar-lo i executar-lo podria perjudicar el teu dispositiu. Desar igualment?';
  }

  @override
  String get bubbleSaveAnyway => 'Desa igualment';

  @override
  String bubbleSavedTo(String path) {
    return 'Desat a $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Error en desar: $error';
  }

  @override
  String get bubbleNotEncrypted => 'NO XIFRAT';

  @override
  String get bubbleCorruptedImage => '[Imatge corrupta]';

  @override
  String get bubbleReplyPhoto => 'Foto';

  @override
  String get bubbleReplyVoice => 'Missatge de veu';

  @override
  String get bubbleReplyVideo => 'Vídeo missatge';

  @override
  String bubbleReadBy(String names) {
    return 'Llegit per $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Llegit per $count';
  }

  @override
  String get chatTileTapToStart => 'Toca per començar a xatejar';

  @override
  String get chatTileMessageSent => 'Missatge enviat';

  @override
  String get chatTileEncryptedMessage => 'Missatge xifrat';

  @override
  String chatTileYouPrefix(String text) {
    return 'Tu: $text';
  }

  @override
  String get bannerEncryptedMessage => 'Missatge xifrat';

  @override
  String get groupNewGroup => 'Grup nou';

  @override
  String get groupGroupName => 'Nom del grup';

  @override
  String get groupSelectMembers => 'Selecciona membres (mín. 2)';

  @override
  String get groupNoContactsYet =>
      'Encara no hi ha contactes. Afegeix contactes primer.';

  @override
  String get groupCreate => 'Crea';

  @override
  String get groupLabel => 'Grup';

  @override
  String get profileVerifyIdentity => 'Verifica la identitat';

  @override
  String profileVerifyInstructions(String name) {
    return 'Compara aquestes empremtes digitals amb $name en una trucada de veu o en persona. Si tots dos valors coincideixen en ambdues dispositius, toca «Marca com a verificat».';
  }

  @override
  String get profileTheirKey => 'La seva clau';

  @override
  String get profileYourKey => 'La teva clau';

  @override
  String get profileRemoveVerification => 'Elimina la verificació';

  @override
  String get profileMarkAsVerified => 'Marca com a verificat';

  @override
  String get profileAddressCopied => 'Adreça copiada';

  @override
  String get profileNoContactsToAdd =>
      'No hi ha contactes per afegir — tots ja són membres';

  @override
  String get profileAddMembers => 'Afegeix membres';

  @override
  String profileAddCount(int count) {
    return 'Afegeix ($count)';
  }

  @override
  String get profileRenameGroup => 'Canvia el nom del grup';

  @override
  String get profileRename => 'Canvia el nom';

  @override
  String get profileRemoveMember => 'Eliminar membre?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Eliminar $name d\'aquest grup?';
  }

  @override
  String get profileKick => 'Expulsa';

  @override
  String get profileSignalFingerprints => 'Empremtes digitals de Signal';

  @override
  String get profileVerified => 'VERIFICAT';

  @override
  String get profileVerify => 'Verifica';

  @override
  String get profileEdit => 'Edita';

  @override
  String get profileNoSession =>
      'Encara no s\'ha establert cap sessió — envia un missatge primer.';

  @override
  String get profileFingerprintCopied => 'Empremta digital copiada';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count membre$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Verifica el número de seguretat';

  @override
  String get profileShowContactQr => 'Mostra QR del contacte';

  @override
  String profileContactAddress(String name) {
    return 'Adreça de $name';
  }

  @override
  String get profileExportChatHistory => 'Exporta l\'historial del xat';

  @override
  String profileSavedTo(String path) {
    return 'Desat a $path';
  }

  @override
  String get profileExportFailed => 'L\'exportació ha fallat';

  @override
  String get profileClearChatHistory => 'Esborra l\'historial del xat';

  @override
  String get profileDeleteGroup => 'Elimina el grup';

  @override
  String get profileDeleteContact => 'Elimina el contacte';

  @override
  String get profileLeaveGroup => 'Abandona el grup';

  @override
  String get profileLeaveGroupBody =>
      'Seràs eliminat d\'aquest grup i s\'esborrarà dels teus contactes.';

  @override
  String get groupInviteTitle => 'Invitació de grup';

  @override
  String groupInviteBody(String from, String group) {
    return '$from t\'ha convidat a unir-te a \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Accepta';

  @override
  String get groupInviteDecline => 'Rebutja';

  @override
  String get groupMemberLimitTitle => 'Massa participants';

  @override
  String groupMemberLimitBody(int count) {
    return 'Aquest grup tindrà $count participants. Les trucades de malla xifrades admeten fins a 6. Els grups més grans recorren a Jitsi (no E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Afegeix igualment';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name ha rebutjat unir-se a \"$group\"';
  }

  @override
  String get transferTitle => 'Transfereix a un altre dispositiu';

  @override
  String get transferInfoBox =>
      'Mou la teva identitat Signal i les claus Nostr a un dispositiu nou.\nLes sessions de xat NO es transfereixen — el secret cap endavant es preserva.';

  @override
  String get transferSendFromThis => 'Envia des d\'aquest dispositiu';

  @override
  String get transferSendSubtitle =>
      'Aquest dispositiu té les claus. Comparteix un codi amb el dispositiu nou.';

  @override
  String get transferReceiveOnThis => 'Rep en aquest dispositiu';

  @override
  String get transferReceiveSubtitle =>
      'Aquest és el dispositiu nou. Introdueix el codi del dispositiu antic.';

  @override
  String get transferChooseMethod => 'Tria el mètode de transferència';

  @override
  String get transferLan => 'LAN (Mateixa xarxa)';

  @override
  String get transferLanSubtitle =>
      'Ràpid i directe. Ambdues dispositius han d\'estar a la mateixa Wi-Fi.';

  @override
  String get transferNostrRelay => 'Retransmissor Nostr';

  @override
  String get transferNostrRelaySubtitle =>
      'Funciona a qualsevol xarxa a través d\'un retransmissor Nostr existent.';

  @override
  String get transferRelayUrl => 'URL del retransmissor';

  @override
  String get transferEnterCode => 'Introdueix el codi de transferència';

  @override
  String get transferPasteCode => 'Enganxa el codi LAN:... o NOS:... aquí';

  @override
  String get transferConnect => 'Connecta';

  @override
  String get transferGenerating => 'Generant codi de transferència…';

  @override
  String get transferShareCode => 'Comparteix aquest codi amb el receptor:';

  @override
  String get transferCopyCode => 'Copia el codi';

  @override
  String get transferCodeCopied => 'Codi copiat al porta-retalls';

  @override
  String get transferWaitingReceiver => 'Esperant que el receptor es connecti…';

  @override
  String get transferConnectingSender => 'Connectant amb l\'emissor…';

  @override
  String get transferVerifyBoth =>
      'Compara aquest codi en ambdues dispositius.\nSi coincideixen, la transferència és segura.';

  @override
  String get transferComplete => 'Transferència completada';

  @override
  String get transferKeysImported => 'Claus importades';

  @override
  String get transferCompleteSenderBody =>
      'Les teves claus romanen actives en aquest dispositiu.\nEl receptor ara pot utilitzar la teva identitat.';

  @override
  String get transferCompleteReceiverBody =>
      'Claus importades correctament.\nReinicia l\'aplicació per aplicar la nova identitat.';

  @override
  String get transferRestartApp => 'Reinicia l\'aplicació';

  @override
  String get transferFailed => 'La transferència ha fallat';

  @override
  String get transferTryAgain => 'Torna-ho a provar';

  @override
  String get transferEnterRelayFirst =>
      'Introdueix primer una URL de retransmissor';

  @override
  String get transferPasteCodeFromSender =>
      'Enganxa el codi de transferència de l\'emissor';

  @override
  String get menuReply => 'Respon';

  @override
  String get menuForward => 'Reenvia';

  @override
  String get menuReact => 'Reacciona';

  @override
  String get menuCopy => 'Copia';

  @override
  String get menuEdit => 'Edita';

  @override
  String get menuRetry => 'Torna-ho a provar';

  @override
  String get menuCancelScheduled => 'Cancel·la la programació';

  @override
  String get menuDelete => 'Elimina';

  @override
  String get menuForwardTo => 'Reenvia a…';

  @override
  String menuForwardedTo(String name) {
    return 'Reenviat a $name';
  }

  @override
  String get menuScheduledMessages => 'Missatges programats';

  @override
  String get menuNoScheduledMessages => 'No hi ha missatges programats';

  @override
  String menuSendsOn(String date) {
    return 'S\'envia el $date';
  }

  @override
  String get menuDisappearingMessages => 'Missatges temporals';

  @override
  String get menuDisappearingSubtitle =>
      'Els missatges s\'eliminen automàticament després del temps seleccionat.';

  @override
  String get menuTtlOff => 'Desactivat';

  @override
  String get menuTtl1h => '1 hora';

  @override
  String get menuTtl24h => '24 hores';

  @override
  String get menuTtl7d => '7 dies';

  @override
  String get menuAttachPhoto => 'Foto';

  @override
  String get menuAttachFile => 'Fitxer';

  @override
  String get menuAttachVideo => 'Vídeo';

  @override
  String get mediaTitle => 'Multimèdia';

  @override
  String get mediaFileLabel => 'FITXER';

  @override
  String mediaPhotosTab(int count) {
    return 'Fotos ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Fitxers ($count)';
  }

  @override
  String get mediaNoPhotos => 'Encara no hi ha fotos';

  @override
  String get mediaNoFiles => 'Encara no hi ha fitxers';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Desat a Descàrregues/$name';
  }

  @override
  String get mediaFailedToSave => 'No s\'ha pogut desar el fitxer';

  @override
  String get statusNewStatus => 'Estat nou';

  @override
  String get statusPublish => 'Publica';

  @override
  String get statusExpiresIn24h => 'L\'estat caduca en 24 hores';

  @override
  String get statusWhatsOnYourMind => 'Què tens al cap?';

  @override
  String get statusPhotoAttached => 'Foto adjuntada';

  @override
  String get statusAttachPhoto => 'Adjunta foto (opcional)';

  @override
  String get statusEnterText => 'Introdueix text per al teu estat.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'No s\'ha pogut seleccionar la foto: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'La publicació ha fallat: $error';
  }

  @override
  String get panicSetPanicKey => 'Estableix la clau de pànic';

  @override
  String get panicEmergencySelfDestruct => 'Autodestrucció d\'emergència';

  @override
  String get panicIrreversible => 'Aquesta acció és irreversible';

  @override
  String get panicWarningBody =>
      'Introduir aquesta clau a la pantalla de bloqueig esborra instantàniament TOTES les dades — missatges, contactes, claus, identitat. Utilitza una clau diferent de la teva contrasenya habitual.';

  @override
  String get panicKeyHint => 'Clau de pànic';

  @override
  String get panicConfirmHint => 'Confirma la clau de pànic';

  @override
  String get panicMinChars =>
      'La clau de pànic ha de tenir almenys 8 caràcters';

  @override
  String get panicKeysDoNotMatch => 'Les claus no coincideixen';

  @override
  String get panicSetFailed =>
      'No s\'ha pogut desar la clau de pànic — torna-ho a provar';

  @override
  String get passwordSetAppPassword =>
      'Estableix la contrasenya de l\'aplicació';

  @override
  String get passwordProtectsMessages =>
      'Protegeix els teus missatges en repòs';

  @override
  String get passwordInfoBanner =>
      'Necessària cada cop que obris Pulse. Si l\'oblides, les teves dades no es poden recuperar.';

  @override
  String get passwordHint => 'Contrasenya';

  @override
  String get passwordConfirmHint => 'Confirma la contrasenya';

  @override
  String get passwordSetButton => 'Estableix la contrasenya';

  @override
  String get passwordSkipForNow => 'Omet per ara';

  @override
  String get passwordMinChars =>
      'La contrasenya ha de tenir almenys 6 caràcters';

  @override
  String get passwordsDoNotMatch => 'Les contrasenyes no coincideixen';

  @override
  String get profileCardSaved => 'Perfil desat!';

  @override
  String get profileCardE2eeIdentity => 'Identitat E2EE';

  @override
  String get profileCardDisplayName => 'Nom visible';

  @override
  String get profileCardDisplayNameHint => 'p. ex. Joan Garcia';

  @override
  String get profileCardAbout => 'Sobre mi';

  @override
  String get profileCardSaveProfile => 'Desa el perfil';

  @override
  String get profileCardYourName => 'El teu nom';

  @override
  String get profileCardAddressCopied => 'Adreça copiada!';

  @override
  String get profileCardInboxAddress => 'La teva adreça de safata d\'entrada';

  @override
  String get profileCardInboxAddresses =>
      'Les teves adreces de safata d\'entrada';

  @override
  String get profileCardShareAllAddresses =>
      'Comparteix totes les adreces (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Comparteix amb els contactes perquè et puguin escriure.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Les $count adreces copiades com un sol enllaç!';
  }

  @override
  String get settingsMyProfile => 'El meu perfil';

  @override
  String get settingsYourInboxAddress => 'La teva adreça de safata d\'entrada';

  @override
  String get settingsMyQrCode => 'El meu codi QR';

  @override
  String get settingsMyQrSubtitle =>
      'Comparteix la teva adreça com un QR escanejable';

  @override
  String get settingsShareMyAddress => 'Comparteix la meva adreça';

  @override
  String get settingsNoAddressYet =>
      'Encara no hi ha adreça — desa la configuració primer';

  @override
  String get settingsInviteLink => 'Enllaç d\'invitació';

  @override
  String get settingsRawAddress => 'Adreça en brut';

  @override
  String get settingsCopyLink => 'Copia l\'enllaç';

  @override
  String get settingsCopyAddress => 'Copia l\'adreça';

  @override
  String get settingsInviteLinkCopied => 'Enllaç d\'invitació copiat';

  @override
  String get settingsAppearance => 'Aparença';

  @override
  String get settingsThemeEngine => 'Motor de temes';

  @override
  String get settingsThemeEngineSubtitle => 'Personalitza colors i tipografies';

  @override
  String get settingsSignalProtocol => 'Protocol Signal';

  @override
  String get settingsSignalProtocolSubtitle =>
      'Les claus E2EE s\'emmagatzemen de forma segura';

  @override
  String get settingsActive => 'ACTIU';

  @override
  String get settingsIdentityBackup => 'Còpia de seguretat de la identitat';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Exporta o importa la teva identitat Signal';

  @override
  String get settingsIdentityBackupBody =>
      'Exporta les teves claus d\'identitat Signal a un codi de còpia de seguretat, o restaura-les des d\'un existent.';

  @override
  String get settingsTransferDevice => 'Transfereix a un altre dispositiu';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Mou la teva identitat via LAN o retransmissor Nostr';

  @override
  String get settingsExportIdentity => 'Exporta la identitat';

  @override
  String get settingsExportIdentityBody =>
      'Copia aquest codi de còpia de seguretat i desa\'l en un lloc segur:';

  @override
  String get settingsSaveFile => 'Desa el fitxer';

  @override
  String get settingsImportIdentity => 'Importa la identitat';

  @override
  String get settingsImportIdentityBody =>
      'Enganxa el teu codi de còpia de seguretat a sota. Això sobreescriurà la teva identitat actual.';

  @override
  String get settingsPasteBackupCode =>
      'Enganxa el codi de còpia de seguretat aquí…';

  @override
  String get settingsIdentityImported =>
      'Identitat + contactes importats! Reinicia l\'aplicació per aplicar.';

  @override
  String get settingsSecurity => 'Seguretat';

  @override
  String get settingsAppPassword => 'Contrasenya de l\'aplicació';

  @override
  String get settingsPasswordEnabled => 'Activada — necessària a cada inici';

  @override
  String get settingsPasswordDisabled =>
      'Desactivada — l\'aplicació s\'obre sense contrasenya';

  @override
  String get settingsChangePassword => 'Canvia la contrasenya';

  @override
  String get settingsChangePasswordSubtitle =>
      'Actualitza la contrasenya de bloqueig de l\'aplicació';

  @override
  String get settingsSetPanicKey => 'Estableix la clau de pànic';

  @override
  String get settingsChangePanicKey => 'Canvia la clau de pànic';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Actualitza la clau d\'esborrat d\'emergència';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Una clau que esborra instantàniament totes les dades';

  @override
  String get settingsRemovePanicKey => 'Elimina la clau de pànic';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Desactiva l\'autodestrucció d\'emergència';

  @override
  String get settingsRemovePanicKeyBody =>
      'L\'autodestrucció d\'emergència es desactivarà. Pots reactivar-la en qualsevol moment.';

  @override
  String get settingsDisableAppPassword =>
      'Desactiva la contrasenya de l\'aplicació';

  @override
  String get settingsEnterCurrentPassword =>
      'Introdueix la teva contrasenya actual per confirmar';

  @override
  String get settingsCurrentPassword => 'Contrasenya actual';

  @override
  String get settingsIncorrectPassword => 'Contrasenya incorrecta';

  @override
  String get settingsPasswordUpdated => 'Contrasenya actualitzada';

  @override
  String get settingsChangePasswordProceed =>
      'Introdueix la teva contrasenya actual per continuar';

  @override
  String get settingsData => 'Dades';

  @override
  String get settingsBackupMessages => 'Còpia de seguretat dels missatges';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Exporta l\'historial de missatges xifrat a un fitxer';

  @override
  String get settingsRestoreMessages => 'Restaura missatges';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Importa missatges des d\'una còpia de seguretat';

  @override
  String get settingsExportKeys => 'Exporta les claus';

  @override
  String get settingsExportKeysSubtitle =>
      'Desa les claus d\'identitat en un fitxer xifrat';

  @override
  String get settingsImportKeys => 'Importa les claus';

  @override
  String get settingsImportKeysSubtitle =>
      'Restaura les claus d\'identitat des d\'un fitxer exportat';

  @override
  String get settingsBackupPassword => 'Contrasenya de la còpia de seguretat';

  @override
  String get settingsPasswordCannotBeEmpty =>
      'La contrasenya no pot estar buida';

  @override
  String get settingsPasswordMin4Chars =>
      'La contrasenya ha de tenir almenys 4 caràcters';

  @override
  String get settingsCallsTurn => 'Trucades i TURN';

  @override
  String get settingsLocalNetwork => 'Xarxa local';

  @override
  String get settingsCensorshipResistance => 'Resistència a la censura';

  @override
  String get settingsNetwork => 'Xarxa';

  @override
  String get settingsProxyTunnels => 'Proxy i túnels';

  @override
  String get settingsTurnServers => 'Servidors TURN';

  @override
  String get settingsProviderTitle => 'Proveïdor';

  @override
  String get settingsLanFallback => 'Alternativa LAN';

  @override
  String get settingsLanFallbackSubtitle =>
      'Transmet presència i missatges a la xarxa local quan no hi ha internet. Desactiva-ho en xarxes no fiables (Wi-Fi públic).';

  @override
  String get settingsBgDelivery => 'Lliurament en segon pla';

  @override
  String get settingsBgDeliverySubtitle =>
      'Continua rebent missatges quan l\'aplicació està minimitzada. Mostra una notificació persistent.';

  @override
  String get settingsYourInboxProvider =>
      'El teu proveïdor de safata d\'entrada';

  @override
  String get settingsConnectionDetails => 'Detalls de connexió';

  @override
  String get settingsSaveAndConnect => 'Desa i connecta';

  @override
  String get settingsSecondaryInboxes => 'Safates d\'entrada secundàries';

  @override
  String get settingsAddSecondaryInbox =>
      'Afegeix safata d\'entrada secundària';

  @override
  String get settingsAdvanced => 'Avançat';

  @override
  String get settingsDiscover => 'Descobreix';

  @override
  String get settingsAbout => 'Quant a';

  @override
  String get settingsPrivacyPolicy => 'Política de privadesa';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Com Pulse protegeix les teves dades';

  @override
  String get settingsCrashReporting => 'Informes d\'errors';

  @override
  String get settingsCrashReportingSubtitle =>
      'Envia informes d\'errors anònims per millorar Pulse. Mai s\'envien continguts de missatges ni contactes.';

  @override
  String get settingsCrashReportingEnabled =>
      'Informes d\'errors activats — reinicia l\'aplicació per aplicar';

  @override
  String get settingsCrashReportingDisabled =>
      'Informes d\'errors desactivats — reinicia l\'aplicació per aplicar';

  @override
  String get settingsSensitiveOperation => 'Operació sensible';

  @override
  String get settingsSensitiveOperationBody =>
      'Aquestes claus són la teva identitat. Qualsevol amb aquest fitxer pot suplantar-te. Desa-lo de forma segura i elimina\'l després de la transferència.';

  @override
  String get settingsIUnderstandContinue => 'Ho entenc, continua';

  @override
  String get settingsReplaceIdentity => 'Reemplaçar la identitat?';

  @override
  String get settingsReplaceIdentityBody =>
      'Això sobreescriurà les teves claus d\'identitat actuals. Les teves sessions Signal existents s\'invalidaran i els contactes hauran de restablir el xifratge. L\'aplicació s\'haurà de reiniciar.';

  @override
  String get settingsReplaceKeys => 'Reemplaça les claus';

  @override
  String get settingsKeysImported => 'Claus importades';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count claus importades correctament. Reinicia l\'aplicació per inicialitzar amb la nova identitat.';
  }

  @override
  String get settingsRestartNow => 'Reinicia ara';

  @override
  String get settingsLater => 'Més tard';

  @override
  String get profileGroupLabel => 'Grup';

  @override
  String get profileAddButton => 'Afegeix';

  @override
  String get profileKickButton => 'Expulsa';

  @override
  String get dataSectionTitle => 'Dades';

  @override
  String get dataBackupMessages => 'Còpia de seguretat dels missatges';

  @override
  String get dataBackupPasswordSubtitle =>
      'Tria una contrasenya per xifrar la còpia de seguretat.';

  @override
  String get dataBackupConfirmLabel => 'Crea la còpia de seguretat';

  @override
  String get dataCreatingBackup => 'Creant còpia de seguretat';

  @override
  String get dataBackupPreparing => 'Preparant...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Exportant missatge $done de $total...';
  }

  @override
  String get dataBackupSavingFile => 'Desant fitxer...';

  @override
  String get dataSaveMessageBackupDialog =>
      'Desa la còpia de seguretat de missatges';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Còpia de seguretat desada ($count missatges)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'La còpia de seguretat ha fallat — no s\'han exportat dades';

  @override
  String dataBackupFailedError(String error) {
    return 'La còpia de seguretat ha fallat: $error';
  }

  @override
  String get dataSelectMessageBackupDialog =>
      'Selecciona la còpia de seguretat de missatges';

  @override
  String get dataInvalidBackupFile =>
      'Fitxer de còpia de seguretat invàlid (massa petit)';

  @override
  String get dataNotValidBackupFile =>
      'No és un fitxer de còpia de seguretat vàlid de Pulse';

  @override
  String get dataRestoreMessages => 'Restaura missatges';

  @override
  String get dataRestorePasswordSubtitle =>
      'Introdueix la contrasenya que es va utilitzar per crear aquesta còpia de seguretat.';

  @override
  String get dataRestoreConfirmLabel => 'Restaura';

  @override
  String get dataRestoringMessages => 'Restaurant missatges';

  @override
  String get dataRestoreDecrypting => 'Desxifrant...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Important missatge $done de $total...';
  }

  @override
  String get dataRestoreFailed =>
      'La restauració ha fallat — contrasenya incorrecta o fitxer corrupte';

  @override
  String dataRestoreSuccess(int count) {
    return '$count missatges nous restaurats';
  }

  @override
  String get dataRestoreNothingNew =>
      'No hi ha missatges nous per importar (tots ja existeixen)';

  @override
  String dataRestoreFailedError(String error) {
    return 'La restauració ha fallat: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Selecciona l\'exportació de claus';

  @override
  String get dataNotValidKeyFile =>
      'No és un fitxer d\'exportació de claus vàlid de Pulse';

  @override
  String get dataExportKeys => 'Exporta les claus';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Tria una contrasenya per xifrar l\'exportació de claus.';

  @override
  String get dataExportKeysConfirmLabel => 'Exporta';

  @override
  String get dataExportingKeys => 'Exportant claus';

  @override
  String get dataExportingKeysStatus => 'Xifrant claus d\'identitat...';

  @override
  String get dataSaveKeyExportDialog => 'Desa l\'exportació de claus';

  @override
  String dataKeysExportedTo(String path) {
    return 'Claus exportades a:\n$path';
  }

  @override
  String get dataExportFailed =>
      'L\'exportació ha fallat — no s\'han trobat claus';

  @override
  String dataExportFailedError(String error) {
    return 'L\'exportació ha fallat: $error';
  }

  @override
  String get dataImportKeys => 'Importa les claus';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Introdueix la contrasenya que es va utilitzar per xifrar aquesta exportació de claus.';

  @override
  String get dataImportKeysConfirmLabel => 'Importa';

  @override
  String get dataImportingKeys => 'Important claus';

  @override
  String get dataImportingKeysStatus => 'Desxifrant claus d\'identitat...';

  @override
  String get dataImportFailed =>
      'La importació ha fallat — contrasenya incorrecta o fitxer corrupte';

  @override
  String dataImportFailedError(String error) {
    return 'La importació ha fallat: $error';
  }

  @override
  String get securitySectionTitle => 'Seguretat';

  @override
  String get securityIncorrectPassword => 'Contrasenya incorrecta';

  @override
  String get securityPasswordUpdated => 'Contrasenya actualitzada';

  @override
  String get appearanceSectionTitle => 'Aparença';

  @override
  String appearanceExportFailed(String error) {
    return 'L\'exportació ha fallat: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Desat a $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Error en desar: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'La importació ha fallat: $error';
  }

  @override
  String get aboutSectionTitle => 'Quant a';

  @override
  String get providerPublicKey => 'Clau pública';

  @override
  String get providerRelay => 'Retransmissor';

  @override
  String get providerAutoConfigured =>
      'Configurat automàticament des de la teva contrasenya de recuperació. Retransmissor descobert automàticament.';

  @override
  String get providerKeyStoredLocally =>
      'La teva clau s\'emmagatzema localment en l\'emmagatzematge segur — mai s\'envia a cap servidor.';

  @override
  String get providerOxenInfo =>
      'Xarxa Oxen/Session — E2EE encaminat per capes. El teu Session ID es genera automàticament i s\'emmagatzema de forma segura. Els nodes es descobreixen automàticament des dels nodes llavor integrats.';

  @override
  String get providerAdvanced => 'Avançat';

  @override
  String get providerSaveAndConnect => 'Desa i connecta';

  @override
  String get providerAddSecondaryInbox =>
      'Afegeix safata d\'entrada secundària';

  @override
  String get providerSecondaryInboxes => 'Safates d\'entrada secundàries';

  @override
  String get providerYourInboxProvider =>
      'El teu proveïdor de safata d\'entrada';

  @override
  String get providerConnectionDetails => 'Detalls de connexió';

  @override
  String get addContactTitle => 'Afegeix contacte';

  @override
  String get addContactInviteLinkLabel => 'Enllaç d\'invitació o adreça';

  @override
  String get addContactTapToPaste => 'Toca per enganxar l\'enllaç d\'invitació';

  @override
  String get addContactPasteTooltip => 'Enganxa des del porta-retalls';

  @override
  String get addContactAddressDetected => 'Adreça de contacte detectada';

  @override
  String addContactRoutesDetected(int count) {
    return '$count rutes detectades — SmartRouter tria la més ràpida';
  }

  @override
  String get addContactFetchingProfile => 'Obtenint perfil…';

  @override
  String addContactProfileFound(String name) {
    return 'Trobat: $name';
  }

  @override
  String get addContactNoProfileFound => 'No s\'ha trobat cap perfil';

  @override
  String get addContactDisplayNameLabel => 'Nom visible';

  @override
  String get addContactDisplayNameHint => 'Com vols anomenar-los?';

  @override
  String get addContactAddManually => 'Afegeix l\'adreça manualment';

  @override
  String get addContactButton => 'Afegeix contacte';

  @override
  String get networkDiagnosticsTitle => 'Diagnòstic de xarxa';

  @override
  String get networkDiagnosticsNostrRelays => 'Retransmissors Nostr';

  @override
  String get networkDiagnosticsDirect => 'Directe';

  @override
  String get networkDiagnosticsTorOnly => 'Només Tor';

  @override
  String get networkDiagnosticsBest => 'Millor';

  @override
  String get networkDiagnosticsNone => 'cap';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Estat';

  @override
  String get networkDiagnosticsConnected => 'Connectat';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Connectant $percent %';
  }

  @override
  String get networkDiagnosticsOff => 'Desactivat';

  @override
  String get networkDiagnosticsTransport => 'Transport';

  @override
  String get networkDiagnosticsInfrastructure => 'Infraestructura';

  @override
  String get networkDiagnosticsOxenNodes => 'Nodes Oxen';

  @override
  String get networkDiagnosticsTurnServers => 'Servidors TURN';

  @override
  String get networkDiagnosticsLastProbe => 'Última comprovació';

  @override
  String get networkDiagnosticsRunning => 'Executant...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Executa el diagnòstic';

  @override
  String get networkDiagnosticsForceReprobe =>
      'Força una recomprovació completa';

  @override
  String get networkDiagnosticsJustNow => 'ara mateix';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'fa $minutes min';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'fa $hours h';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'fa $days d';
  }

  @override
  String get homeNoEch => 'Sense ECH';

  @override
  String get homeNoEchTooltip =>
      'Proxy uTLS no disponible — ECH desactivat.\nL\'empremta TLS és visible per al DPI.';

  @override
  String get settingsTitle => 'Configuració';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Desat i connectat a $provider';
  }

  @override
  String get settingsTorFailedToStart =>
      'El Tor integrat no s\'ha pogut iniciar';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon no s\'ha pogut iniciar';

  @override
  String get verifyTitle => 'Verifica el número de seguretat';

  @override
  String get verifyIdentityVerified => 'Identitat verificada';

  @override
  String get verifyNotYetVerified => 'Encara no verificat';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Has verificat el número de seguretat de $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Compara aquests números amb $name en persona o per un canal de confiança.';
  }

  @override
  String get verifyExplanation =>
      'Cada conversa té un número de seguretat únic. Si ambdues persones veieu els mateixos números als vostres dispositius, la connexió està verificada d\'extrem a extrem.';

  @override
  String verifyContactKey(String name) {
    return 'Clau de $name';
  }

  @override
  String get verifyYourKey => 'La teva clau';

  @override
  String get verifyRemoveVerification => 'Elimina la verificació';

  @override
  String get verifyMarkAsVerified => 'Marca com a verificat';

  @override
  String verifyAfterReinstall(String name) {
    return 'Si $name reinstal·la l\'aplicació, el número de seguretat canviarà i la verificació s\'eliminarà automàticament.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Només marca com a verificat després de comparar els números amb $name en una trucada de veu o en persona.';
  }

  @override
  String get verifyNoSession =>
      'Encara no s\'ha establert cap sessió de xifratge. Envia un missatge primer per generar números de seguretat.';

  @override
  String get verifyNoKeyAvailable => 'No hi ha cap clau disponible';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Empremta digital de $label copiada';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL de la base de dades';

  @override
  String get providerOptionalHint => 'Opcional';

  @override
  String get providerWebApiKeyLabel => 'Clau API web';

  @override
  String get providerOptionalForPublicDb =>
      'Opcional per a base de dades pública';

  @override
  String get providerRelayUrlLabel => 'URL del retransmissor';

  @override
  String get providerPrivateKeyLabel => 'Clau privada';

  @override
  String get providerPrivateKeyNsecLabel => 'Clau privada (nsec)';

  @override
  String get providerStorageNodeLabel =>
      'URL del node d\'emmagatzematge (opcional)';

  @override
  String get providerStorageNodeHint =>
      'Deixa buit per als nodes llavor integrats';

  @override
  String get transferInvalidCodeFormat =>
      'Format de codi no reconegut — ha de començar amb LAN: o NOS:';

  @override
  String get profileCardFingerprintCopied => 'Empremta digital copiada';

  @override
  String get profileCardAboutHint => 'Privadesa primer 🔒';

  @override
  String get profileCardSaveButton => 'Desa el perfil';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Exporta missatges xifrats, contactes i avatars a un fitxer';

  @override
  String get callVideo => 'Vídeo';

  @override
  String get callAudio => 'Àudio';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Lliurat a $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Lliurat a $count';
  }

  @override
  String get groupStatusDialogTitle => 'Informació del missatge';

  @override
  String get groupStatusRead => 'Llegit';

  @override
  String get groupStatusDelivered => 'Lliurat';

  @override
  String get groupStatusPending => 'Pendent';

  @override
  String get groupStatusNoData => 'Encara no hi ha informació de lliurament';

  @override
  String get profileTransferAdmin => 'Fes administrador';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Fer $name el nou administrador?';
  }

  @override
  String get profileTransferAdminBody =>
      'Perdreu els privilegis d\'administrador. Això no es pot desfer.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name ara és l\'administrador';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Política de privadesa';

  @override
  String get privacyOverviewHeading => 'Resum';

  @override
  String get privacyOverviewBody =>
      'Pulse és un missatger sense servidor i amb xifratge d\'extrem a extrem. La teva privadesa no és només una funció — és l\'arquitectura. No hi ha servidors Pulse. No s\'emmagatzema cap compte enlloc. Els desenvolupadors no recullen, transmeten ni emmagatzemen cap dada.';

  @override
  String get privacyDataCollectionHeading => 'Recollida de dades';

  @override
  String get privacyDataCollectionBody =>
      'Pulse no recull cap dada personal. Específicament:\n\n- No cal correu electrònic, telèfon ni nom real\n- Cap analítica, seguiment ni telemetria\n- Cap identificador publicitari\n- Cap accés a la llista de contactes\n- Cap còpia de seguretat al núvol (els missatges només existeixen al teu dispositiu)\n- Cap metadada s\'envia a cap servidor Pulse (no n\'hi ha cap)';

  @override
  String get privacyEncryptionHeading => 'Xifratge';

  @override
  String get privacyEncryptionBody =>
      'Tots els missatges es xifren amb el protocol Signal (Double Ratchet amb acord de claus X3DH). Les claus de xifratge es generen i s\'emmagatzemen exclusivament al teu dispositiu. Ningú — inclòs els desenvolupadors — pot llegir els teus missatges.';

  @override
  String get privacyNetworkHeading => 'Arquitectura de xarxa';

  @override
  String get privacyNetworkBody =>
      'Pulse utilitza adaptadors de transport federats (retransmissors Nostr, nodes de servei Session/Oxen, Firebase Realtime Database, LAN). Aquests transports només porten text xifrat. Els operadors de retransmissors poden veure la teva adreça IP i el volum de tràfic, però no poden desxifrar el contingut dels missatges.\n\nQuan Tor està activat, la teva adreça IP també s\'amaga dels operadors de retransmissors.';

  @override
  String get privacyStunHeading => 'Servidors STUN/TURN';

  @override
  String get privacyStunBody =>
      'Les trucades de veu i vídeo utilitzen WebRTC amb xifratge DTLS-SRTP. Els servidors STUN (utilitzats per descobrir la teva IP pública per a connexions P2P) i TURN (per retransmetre multimèdia quan la connexió directa falla) poden veure la teva adreça IP i la durada de la trucada, però no poden desxifrar el contingut.\n\nPots configurar el teu propi servidor TURN a Configuració per a màxima privadesa.';

  @override
  String get privacyCrashHeading => 'Informes d\'errors';

  @override
  String get privacyCrashBody =>
      'Si els informes d\'errors de Sentry estan activats (via SENTRY_DSN en compilació), es poden enviar informes d\'errors anònims. Aquests no contenen contingut de missatges, informació de contactes ni informació personal identificable. Els informes d\'errors es poden desactivar en compilació ometent el DSN.';

  @override
  String get privacyPasswordHeading => 'Contrasenya i claus';

  @override
  String get privacyPasswordBody =>
      'La teva contrasenya de recuperació s\'utilitza per derivar claus criptogràfiques via Argon2id (KDF de memòria intensiva). La contrasenya mai es transmet enlloc. Si perds la contrasenya, el teu compte no es pot recuperar — no hi ha cap servidor per restablir-la.';

  @override
  String get privacyFontsHeading => 'Tipografies';

  @override
  String get privacyFontsBody =>
      'Pulse inclou totes les tipografies localment. No es fan peticions a Google Fonts ni a cap servei de tipografies extern.';

  @override
  String get privacyThirdPartyHeading => 'Serveis de tercers';

  @override
  String get privacyThirdPartyBody =>
      'Pulse no s\'integra amb cap xarxa publicitària, proveïdor d\'analítiques, plataforma de xarxes socials ni intermediaris de dades. Les úniques connexions de xarxa són als retransmissors de transport que configures.';

  @override
  String get privacyOpenSourceHeading => 'Codi obert';

  @override
  String get privacyOpenSourceBody =>
      'Pulse és programari de codi obert. Pots auditar el codi font complet per verificar aquestes afirmacions de privadesa.';

  @override
  String get privacyContactHeading => 'Contacte';

  @override
  String get privacyContactBody =>
      'Per a preguntes relacionades amb la privadesa, obre una incídencia al repositori del projecte.';

  @override
  String get privacyLastUpdated => 'Última actualització: març de 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Error en desar: $error';
  }

  @override
  String get themeEngineTitle => 'Motor de temes';

  @override
  String get torBuiltInTitle => 'Tor integrat';

  @override
  String get torConnectedSubtitle =>
      'Connectat — Nostr encaminat via 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Connectant… $pct %';
  }

  @override
  String get torNotRunning => 'No s\'està executant — toca per reiniciar';

  @override
  String get torDescription =>
      'Encamina Nostr via Tor (Snowflake per a xarxes censurades)';

  @override
  String get torNetworkDiagnostics => 'Diagnòstic de xarxa';

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
  String get torPtPlain => 'Simple';

  @override
  String get torTimeoutLabel => 'Temps d\'espera: ';

  @override
  String get torInfoDescription =>
      'Quan està activat, les connexions WebSocket de Nostr s\'encaminen a través de Tor (SOCKS5). Tor Browser escolta a 127.0.0.1:9150. El dimoni tor independent utilitza el port 9050. Les connexions Firebase no es veuen afectades.';

  @override
  String get torRouteNostrTitle => 'Encamina Nostr via Tor';

  @override
  String get torManagedByBuiltin => 'Gestionat pel Tor integrat';

  @override
  String get torActiveRouting =>
      'Actiu — Tràfic Nostr encaminat a través de Tor';

  @override
  String get torDisabled => 'Desactivat';

  @override
  String get torProxySocks5 => 'Proxy Tor (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Amfitrió del proxy';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser: port 9150  •  dimoni tor: port 9050';

  @override
  String get i2pProxySocks5 => 'Proxy I2P (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P utilitza SOCKS5 al port 4447 per defecte. Connecta a un retransmissor Nostr via I2P outproxy (p. ex. relay.damus.i2p) per comunicar-te amb usuaris de qualsevol transport. Tor té prioritat quan ambdues estan activats.';

  @override
  String get i2pRouteNostrTitle => 'Encamina Nostr via I2P';

  @override
  String get i2pActiveRouting =>
      'Actiu — Tràfic Nostr encaminat a través d\'I2P';

  @override
  String get i2pDisabled => 'Desactivat';

  @override
  String get i2pProxyHostLabel => 'Amfitrió del proxy';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'Port SOCKS5 per defecte del router I2P: 4447';

  @override
  String get customProxySocks5 => 'Proxy personalitzat (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'El proxy personalitzat encamina el tràfic a través del teu V2Ray/Xray/Shadowsocks. El CF Worker actua com un proxy de retransmissió personal a Cloudflare CDN — el GFW veu *.workers.dev, no el retransmissor real.';

  @override
  String get customSocks5ProxyTitle => 'Proxy SOCKS5 personalitzat';

  @override
  String get customProxyActive => 'Actiu — tràfic encaminat via SOCKS5';

  @override
  String get customProxyDisabled => 'Desactivat';

  @override
  String get customProxyHostLabel => 'Amfitrió del proxy';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Domini del Worker (opcional)';

  @override
  String get customWorkerHelpTitle =>
      'Com desplegar un CF Worker relay (gratuït)';

  @override
  String get customWorkerScriptCopied => 'Script copiat!';

  @override
  String get customWorkerStep1 =>
      '1. Ves a dash.cloudflare.com → Workers & Pages\n2. Create Worker → enganxa aquest script:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → copia el domini (p. ex. my-relay.user.workers.dev)\n4. Enganxa el domini a dalt → Desa\n\nL\'aplicació es connecta automàticament: wss://domain/?r=relay_url\nEl GFW veu: connexió a *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Connectat — SOCKS5 a 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Connectant…';

  @override
  String get psiphonNotRunning => 'No s\'està executant — toca per reiniciar';

  @override
  String get psiphonDescription =>
      'Túnel ràpid (~3s d\'arrencada, 2000+ VPS rotatius)';

  @override
  String get turnCommunityServers => 'Servidors TURN comunitaris';

  @override
  String get turnCustomServer => 'Servidor TURN personalitzat (BYOD)';

  @override
  String get turnInfoDescription =>
      'Els servidors TURN només retransmeten fluxos ja xifrats (DTLS-SRTP). Un operador de retransmissió veu la teva IP i el volum de tràfic, però no pot desxifrar les trucades. TURN només s\'utilitza quan el P2P directe falla (~15–20 % de les connexions).';

  @override
  String get turnFreeLabel => 'GRATUÏT';

  @override
  String get turnServerUrlLabel => 'URL del servidor TURN';

  @override
  String get turnServerUrlHint => 'turn:el-teu-servidor.com:3478 o turns:...';

  @override
  String get turnUsernameLabel => 'Nom d\'usuari';

  @override
  String get turnPasswordLabel => 'Contrasenya';

  @override
  String get turnOptionalHint => 'Opcional';

  @override
  String get turnCustomInfo =>
      'Allotja coturn en qualsevol VPS de \$5/mes per a màxim control. Les credencials es desen localment.';

  @override
  String get themePickerAppearance => 'Aparença';

  @override
  String get themePickerAccentColor => 'Color d\'accent';

  @override
  String get themeModeLight => 'Clar';

  @override
  String get themeModeDark => 'Fosc';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeDynamicPresets => 'Preconfigurats';

  @override
  String get themeDynamicPrimaryColor => 'Color primari';

  @override
  String get themeDynamicBorderRadius => 'Radi de la vora';

  @override
  String get themeDynamicFont => 'Tipografia';

  @override
  String get themeDynamicAppearance => 'Aparença';

  @override
  String get themeDynamicUiStyle => 'Estil de la IU';

  @override
  String get themeDynamicUiStyleDescription =>
      'Controla l\'aspecte de diàlegs, commutadors i indicadors.';

  @override
  String get themeDynamicSharp => 'Angular';

  @override
  String get themeDynamicRound => 'Rodona';

  @override
  String get themeDynamicModeDark => 'Fosc';

  @override
  String get themeDynamicModeLight => 'Clar';

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
      'URL de Firebase invàlida. S\'esperava: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'URL del retransmissor invàlida. S\'esperava: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'URL del servidor Pulse invàlida. S\'esperava: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'URL del servidor';

  @override
  String get providerPulseServerUrlHint => 'https://el-teu-servidor:8443';

  @override
  String get providerPulseInviteLabel => 'Codi d\'invitació';

  @override
  String get providerPulseInviteHint => 'Codi d\'invitació (si cal)';

  @override
  String get providerPulseInfo =>
      'Retransmissor allotjat per tu. Claus derivades de la teva contrasenya de recuperació.';

  @override
  String get providerScreenTitle => 'Safates d\'entrada';

  @override
  String get providerSecondaryInboxesHeader => 'SAFATES D\'ENTRADA SECUNDÀRIES';

  @override
  String get providerSecondaryInboxesInfo =>
      'Les safates d\'entrada secundàries reben missatges simultàniament per redundància.';

  @override
  String get providerRemoveTooltip => 'Elimina';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... o hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... o clau privada hex';

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
  String get emojiNoRecent => 'No hi ha emojis recents';

  @override
  String get emojiSearchHint => 'Cerca emoji...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Toca per xatejar';

  @override
  String get imageViewerSaveToDownloads => 'Desa a Descàrregues';

  @override
  String imageViewerSavedTo(String path) {
    return 'Desat a $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSubtitle =>
      'Idioma de visualització de l\'aplicació';

  @override
  String get settingsLanguageSystem => 'Per defecte del sistema';

  @override
  String get onboardingLanguageTitle => 'Tria el teu idioma';

  @override
  String get onboardingLanguageSubtitle =>
      'Pots canviar-ho més tard a Configuració';
}
