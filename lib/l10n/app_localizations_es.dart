// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Buscar mensajes...';

  @override
  String get search => 'Buscar';

  @override
  String get clearSearch => 'Borrar búsqueda';

  @override
  String get closeSearch => 'Cerrar búsqueda';

  @override
  String get moreOptions => 'Más opciones';

  @override
  String get back => 'Atrás';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Cerrar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get remove => 'Eliminar';

  @override
  String get save => 'Guardar';

  @override
  String get add => 'Agregar';

  @override
  String get copy => 'Copiar';

  @override
  String get skip => 'Omitir';

  @override
  String get done => 'Listo';

  @override
  String get apply => 'Aplicar';

  @override
  String get export => 'Exportar';

  @override
  String get import => 'Importar';

  @override
  String get homeNewGroup => 'Nuevo grupo';

  @override
  String get homeSettings => 'Ajustes';

  @override
  String get homeSearching => 'Buscando mensajes...';

  @override
  String get homeNoResults => 'No se encontraron resultados';

  @override
  String get homeNoChatHistory => 'Aún no hay historial de chat';

  @override
  String homeTransportSwitched(String address) {
    return 'Transporte cambiado → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name está llamando...';
  }

  @override
  String get homeAccept => 'Aceptar';

  @override
  String get homeDecline => 'Rechazar';

  @override
  String get homeLoadEarlier => 'Cargar mensajes anteriores';

  @override
  String get homeChats => 'Chats';

  @override
  String get homeSelectConversation => 'Selecciona una conversación';

  @override
  String get homeNoChatsYet => 'Aún no hay chats';

  @override
  String get homeAddContactToStart =>
      'Agrega un contacto para empezar a chatear';

  @override
  String get homeNewChat => 'Nuevo chat';

  @override
  String get homeNewChatTooltip => 'Nuevo chat';

  @override
  String get homeIncomingCallTitle => 'Llamada entrante';

  @override
  String get homeIncomingGroupCallTitle => 'Llamada grupal entrante';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — llamada grupal entrante';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'No hay chats que coincidan con \"$query\"';
  }

  @override
  String get homeSectionChats => 'Chats';

  @override
  String get homeSectionMessages => 'Mensajes';

  @override
  String get homeDbEncryptionUnavailable =>
      'Cifrado de base de datos no disponible — instala SQLCipher para protección completa';

  @override
  String get chatFileTooLargeGroup =>
      'Los archivos de más de 512 KB no son compatibles en chats grupales';

  @override
  String get chatLargeFile => 'Archivo grande';

  @override
  String get chatCancel => 'Cancelar';

  @override
  String get chatSend => 'Enviar';

  @override
  String get chatFileTooLarge =>
      'Archivo demasiado grande — el tamaño máximo es 100 MB';

  @override
  String get chatMicDenied => 'Permiso de micrófono denegado';

  @override
  String get chatVoiceFailed =>
      'No se pudo guardar el mensaje de voz — verifica el almacenamiento disponible';

  @override
  String get chatScheduleFuture => 'La hora programada debe ser en el futuro';

  @override
  String get chatToday => 'Hoy';

  @override
  String get chatYesterday => 'Ayer';

  @override
  String get chatEdited => 'editado';

  @override
  String get chatYou => 'Tú';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Este archivo pesa $size MB. Enviar archivos grandes puede ser lento en algunas redes. ¿Continuar?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'La clave de seguridad de $name cambió. Toca para verificar.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'No se pudo cifrar el mensaje para $name — mensaje no enviado.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'El número de seguridad cambió para $name. Toca para verificar.';
  }

  @override
  String get chatNoMessagesFound => 'No se encontraron mensajes';

  @override
  String get chatMessagesE2ee =>
      'Los mensajes están cifrados de extremo a extremo';

  @override
  String get chatSayHello => 'Di hola';

  @override
  String get appBarOnline => 'en línea';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'escribiendo';

  @override
  String get appBarSearchMessages => 'Buscar mensajes...';

  @override
  String get appBarMute => 'Silenciar';

  @override
  String get appBarUnmute => 'Activar sonido';

  @override
  String get appBarMedia => 'Multimedia';

  @override
  String get appBarDisappearing => 'Mensajes temporales';

  @override
  String get appBarDisappearingOn => 'Temporales: activados';

  @override
  String get appBarGroupSettings => 'Ajustes del grupo';

  @override
  String get appBarSearchTooltip => 'Buscar mensajes';

  @override
  String get appBarVoiceCall => 'Llamada de voz';

  @override
  String get appBarVideoCall => 'Videollamada';

  @override
  String get inputMessage => 'Mensaje...';

  @override
  String get inputAttachFile => 'Adjuntar archivo';

  @override
  String get inputSendMessage => 'Enviar mensaje';

  @override
  String get inputRecordVoice => 'Grabar mensaje de voz';

  @override
  String get inputSendVoice => 'Enviar mensaje de voz';

  @override
  String get inputCancelReply => 'Cancelar respuesta';

  @override
  String get inputCancelEdit => 'Cancelar edición';

  @override
  String get inputCancelRecording => 'Cancelar grabación';

  @override
  String get inputRecording => 'Grabando…';

  @override
  String get inputEditingMessage => 'Editando mensaje';

  @override
  String get inputPhoto => 'Foto';

  @override
  String get inputVoiceMessage => 'Mensaje de voz';

  @override
  String get inputFile => 'Archivo';

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
    return '$count mensaje$_temp0 programado$_temp1';
  }

  @override
  String get callInitializing => 'Iniciando llamada…';

  @override
  String get callConnecting => 'Conectando…';

  @override
  String get callConnectingRelay => 'Conectando (retransmisor)…';

  @override
  String get callSwitchingRelay => 'Cambiando a modo retransmisor…';

  @override
  String get callConnectionFailed => 'La conexión falló';

  @override
  String get callReconnecting => 'Reconectando…';

  @override
  String get callEnded => 'Llamada finalizada';

  @override
  String get callLive => 'En vivo';

  @override
  String get callEnd => 'Fin';

  @override
  String get callEndCall => 'Finalizar llamada';

  @override
  String get callMute => 'Silenciar';

  @override
  String get callUnmute => 'Activar sonido';

  @override
  String get callSpeaker => 'Altavoz';

  @override
  String get callCameraOn => 'Cámara encendida';

  @override
  String get callCameraOff => 'Cámara apagada';

  @override
  String get callShareScreen => 'Compartir pantalla';

  @override
  String get callStopShare => 'Dejar de compartir';

  @override
  String callTorBackup(String duration) {
    return 'Respaldo Tor · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Respaldo Tor activo — ruta principal no disponible';

  @override
  String get callDirectFailed =>
      'La conexión directa falló — cambiando a modo retransmisor…';

  @override
  String get callTurnUnreachable =>
      'Servidores TURN inaccesibles. Agrega un TURN personalizado en Ajustes → Avanzado.';

  @override
  String get callRelayMode => 'Modo retransmisor activo (red restringida)';

  @override
  String get callStarting => 'Iniciando llamada…';

  @override
  String get callConnectingToGroup => 'Conectando al grupo…';

  @override
  String get callGroupOpenedInBrowser =>
      'Llamada grupal abierta en el navegador';

  @override
  String get callCouldNotOpenBrowser => 'No se pudo abrir el navegador';

  @override
  String get callInviteLinkSent =>
      'Enlace de invitación enviado a todos los miembros del grupo.';

  @override
  String get callOpenLinkManually =>
      'Abre el enlace anterior manualmente o toca para reintentar.';

  @override
  String get callJitsiNotE2ee =>
      'Las llamadas de Jitsi NO están cifradas de extremo a extremo';

  @override
  String get callRetryOpenBrowser => 'Reintentar abrir navegador';

  @override
  String get callClose => 'Cerrar';

  @override
  String get callCamOn => 'Cámara on';

  @override
  String get callCamOff => 'Cámara off';

  @override
  String get noConnection => 'Sin conexión — los mensajes se pondrán en cola';

  @override
  String get connected => 'Conectado';

  @override
  String get connecting => 'Conectando…';

  @override
  String get disconnected => 'Desconectado';

  @override
  String get offlineBanner =>
      'Sin conexión — los mensajes se enviarán cuando vuelvas a estar en línea';

  @override
  String get lanModeBanner => 'Modo LAN — Sin internet · Solo red local';

  @override
  String get probeCheckingNetwork => 'Verificando conectividad de red…';

  @override
  String get probeDiscoveringRelays =>
      'Descubriendo retransmisores a través de directorios comunitarios…';

  @override
  String get probeStartingTor => 'Iniciando Tor para el arranque…';

  @override
  String get probeFindingRelaysTor =>
      'Buscando retransmisores accesibles vía Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'es',
      one: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'Red lista — $count retransmisor$_temp0 encontrado$_temp1';
  }

  @override
  String get probeNoRelaysFound =>
      'No se encontraron retransmisores accesibles — los mensajes pueden retrasarse';

  @override
  String get jitsiWarningTitle => 'Sin cifrado de extremo a extremo';

  @override
  String get jitsiWarningBody =>
      'Las llamadas de Jitsi Meet no están cifradas por Pulse. Úsalas solo para conversaciones no sensibles.';

  @override
  String get jitsiConfirm => 'Unirse de todos modos';

  @override
  String get jitsiGroupWarningTitle => 'Sin cifrado de extremo a extremo';

  @override
  String get jitsiGroupWarningBody =>
      'Esta llamada tiene demasiados participantes para la malla cifrada integrada.\n\nSe abrirá un enlace de Jitsi Meet en tu navegador. Jitsi NO tiene cifrado de extremo a extremo — el servidor puede ver tu llamada.';

  @override
  String get jitsiContinueAnyway => 'Continuar de todos modos';

  @override
  String get retry => 'Reintentar';

  @override
  String get setupCreateAnonymousAccount => 'Crear una cuenta anónima';

  @override
  String get setupTapToChangeColor => 'Toca para cambiar el color';

  @override
  String get setupReqMinLength => 'Al menos 16 caracteres';

  @override
  String get setupReqVariety =>
      '3 de 4: mayúsculas, minúsculas, dígitos, símbolos';

  @override
  String get setupReqMatch => 'Las contraseñas coinciden';

  @override
  String get setupYourNickname => 'Tu apodo';

  @override
  String get setupRecoveryPassword => 'Contraseña de recuperación (mín. 16)';

  @override
  String get setupConfirmPassword => 'Confirmar contraseña';

  @override
  String get setupMin16Chars => 'Mínimo 16 caracteres';

  @override
  String get setupPasswordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get setupEntropyWeak => 'Débil';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Fuerte';

  @override
  String get setupEntropyWeakNeedsVariety =>
      'Débil (necesita 3 tipos de caracteres)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bits)';
  }

  @override
  String get setupPasswordWarning =>
      'Esta contraseña es la única forma de restaurar tu cuenta. No hay servidor — no hay recuperación de contraseña. Recuerdala o anótala.';

  @override
  String get setupCreateAccount => 'Crear cuenta';

  @override
  String get setupAlreadyHaveAccount => '¿Ya tienes una cuenta? ';

  @override
  String get setupRestore => 'Restaurar →';

  @override
  String get restoreTitle => 'Restaurar cuenta';

  @override
  String get restoreInfoBanner =>
      'Introduce tu contraseña de recuperación — tu dirección (Nostr + Session) se restaurará automáticamente. Los contactos y mensajes se almacenaron solo localmente.';

  @override
  String get restoreNewNickname => 'Nuevo apodo (puedes cambiarlo después)';

  @override
  String get restoreButton => 'Restaurar cuenta';

  @override
  String get lockTitle => 'Pulse está bloqueado';

  @override
  String get lockSubtitle => 'Introduce tu contraseña para continuar';

  @override
  String get lockPasswordHint => 'Contraseña';

  @override
  String get lockUnlock => 'Desbloquear';

  @override
  String get lockPanicHint =>
      '¿Olvidaste tu contraseña? Introduce tu clave de pánico para borrar todos los datos.';

  @override
  String get lockTooManyAttempts =>
      'Demasiados intentos. Borrando todos los datos…';

  @override
  String get lockWrongPassword => 'Contraseña incorrecta';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Contraseña incorrecta — $attempts/$max intentos';
  }

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingGetStarted => 'Comenzar';

  @override
  String get onboardingWelcomeTitle => 'Bienvenido a Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Un mensajero descentralizado con cifrado de extremo a extremo.\n\nSin servidores centrales. Sin recolección de datos. Sin puertas traseras.\nTus conversaciones te pertenecen solo a ti.';

  @override
  String get onboardingTransportTitle => 'Independiente del transporte';

  @override
  String get onboardingTransportBody =>
      'Usa Firebase, Nostr o ambos al mismo tiempo.\n\nLos mensajes se enrutan entre redes automáticamente. Soporte integrado de Tor e I2P para resistencia a la censura.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Cada mensaje se cifra con el Protocolo Signal (Double Ratchet + X3DH) para secreto perfecto hacia adelante.\n\nAdemás, se envuelve con Kyber-1024 — un algoritmo post-cuántico estándar del NIST — protegiendote contra futuros computadores cuánticos.';

  @override
  String get onboardingKeysTitle => 'Tú controlas tus claves';

  @override
  String get onboardingKeysBody =>
      'Tus claves de identidad nunca salen de tu dispositivo.\n\nLas huellas digitales de Signal te permiten verificar contactos fuera de banda. TOFU (Confianza en el Primer Uso) detecta cambios de claves automáticamente.';

  @override
  String get onboardingThemeTitle => 'Elige tu estilo';

  @override
  String get onboardingThemeBody =>
      'Elige un tema y color de acento. Siempre puedes cambiarlo más tarde en Ajustes.';

  @override
  String get contactsNewChat => 'Nuevo chat';

  @override
  String get contactsAddContact => 'Agregar contacto';

  @override
  String get contactsSearchHint => 'Buscar...';

  @override
  String get contactsNewGroup => 'Nuevo grupo';

  @override
  String get contactsNoContactsYet => 'Aún no hay contactos';

  @override
  String get contactsAddHint => 'Toca + para agregar la dirección de alguien';

  @override
  String get contactsNoMatch => 'Ningún contacto coincide';

  @override
  String get contactsRemoveTitle => 'Eliminar contacto';

  @override
  String contactsRemoveMessage(String name) {
    return '¿Eliminar a $name?';
  }

  @override
  String get contactsRemove => 'Eliminar';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count contacto$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Abrir enlace';

  @override
  String bubbleOpenLinkBody(String url) {
    return '¿Abrir esta URL en tu navegador?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Abrir';

  @override
  String get bubbleSecurityWarning => 'Advertencia de seguridad';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" es un tipo de archivo ejecutable. Guardarlo y ejecutarlo podría dañar tu dispositivo. ¿Guardar de todos modos?';
  }

  @override
  String get bubbleSaveAnyway => 'Guardar de todos modos';

  @override
  String bubbleSavedTo(String path) {
    return 'Guardado en $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String get bubbleNotEncrypted => 'SIN CIFRAR';

  @override
  String get bubbleCorruptedImage => '[Imagen corrupta]';

  @override
  String get bubbleReplyPhoto => 'Foto';

  @override
  String get bubbleReplyVoice => 'Mensaje de voz';

  @override
  String get bubbleReplyVideo => 'Mensaje de video';

  @override
  String bubbleReadBy(String names) {
    return 'Leído por $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Leído por $count';
  }

  @override
  String get chatTileTapToStart => 'Toca para empezar a chatear';

  @override
  String get chatTileMessageSent => 'Mensaje enviado';

  @override
  String get chatTileEncryptedMessage => 'Mensaje cifrado';

  @override
  String chatTileYouPrefix(String text) {
    return 'Tú: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Mensaje de voz';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Mensaje de voz ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Mensaje cifrado';

  @override
  String get groupNewGroup => 'Nuevo grupo';

  @override
  String get groupGroupName => 'Nombre del grupo';

  @override
  String get groupSelectMembers => 'Seleccionar miembros (mín. 2)';

  @override
  String get groupNoContactsYet =>
      'Aún no hay contactos. Agrega contactos primero.';

  @override
  String get groupCreate => 'Crear';

  @override
  String get groupLabel => 'Grupo';

  @override
  String get profileVerifyIdentity => 'Verificar identidad';

  @override
  String profileVerifyInstructions(String name) {
    return 'Compara estas huellas digitales con $name en una llamada de voz o en persona. Si ambos valores coinciden en ambos dispositivos, toca \"Marcar como verificado\".';
  }

  @override
  String get profileTheirKey => 'Su clave';

  @override
  String get profileYourKey => 'Tu clave';

  @override
  String get profileRemoveVerification => 'Eliminar verificación';

  @override
  String get profileMarkAsVerified => 'Marcar como verificado';

  @override
  String get profileAddressCopied => 'Dirección copiada';

  @override
  String get profileNoContactsToAdd =>
      'No hay contactos para agregar — todos ya son miembros';

  @override
  String get profileAddMembers => 'Agregar miembros';

  @override
  String profileAddCount(int count) {
    return 'Agregar ($count)';
  }

  @override
  String get profileRenameGroup => 'Renombrar grupo';

  @override
  String get profileRename => 'Renombrar';

  @override
  String get profileRemoveMember => '¿Eliminar miembro?';

  @override
  String profileRemoveMemberBody(String name) {
    return '¿Eliminar a $name de este grupo?';
  }

  @override
  String get profileKick => 'Expulsar';

  @override
  String get profileSignalFingerprints => 'Huellas digitales de Signal';

  @override
  String get profileVerified => 'VERIFICADO';

  @override
  String get profileVerify => 'Verificar';

  @override
  String get profileEdit => 'Editar';

  @override
  String get profileNoSession =>
      'Aún no se ha establecido sesión — envía un mensaje primero.';

  @override
  String get profileFingerprintCopied => 'Huella digital copiada';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count miembro$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Verificar número de seguridad';

  @override
  String get profileShowContactQr => 'Mostrar QR del contacto';

  @override
  String profileContactAddress(String name) {
    return 'Dirección de $name';
  }

  @override
  String get profileExportChatHistory => 'Exportar historial de chat';

  @override
  String profileSavedTo(String path) {
    return 'Guardado en $path';
  }

  @override
  String get profileExportFailed => 'La exportación falló';

  @override
  String get profileClearChatHistory => 'Borrar historial de chat';

  @override
  String get profileDeleteGroup => 'Eliminar grupo';

  @override
  String get profileDeleteContact => 'Eliminar contacto';

  @override
  String get profileLeaveGroup => 'Salir del grupo';

  @override
  String get profileLeaveGroupBody =>
      'Serás eliminado de este grupo y se borrará de tus contactos.';

  @override
  String get groupInviteTitle => 'Invitación al grupo';

  @override
  String groupInviteBody(String from, String group) {
    return '$from te invitó a unirte a \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Aceptar';

  @override
  String get groupInviteDecline => 'Rechazar';

  @override
  String get groupMemberLimitTitle => 'Demasiados participantes';

  @override
  String groupMemberLimitBody(int count) {
    return 'Este grupo tendrá $count participantes. Las llamadas cifradas en malla soportan hasta 6. Los grupos más grandes recurren a Jitsi (sin E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Agregar de todos modos';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name rechazó unirse a \"$group\"';
  }

  @override
  String get transferTitle => 'Transferir a otro dispositivo';

  @override
  String get transferInfoBox =>
      'Mueve tu identidad de Signal y claves de Nostr a un nuevo dispositivo.\nLas sesiones de chat NO se transfieren — se preserva el secreto perfecto hacia adelante.';

  @override
  String get transferSendFromThis => 'Enviar desde este dispositivo';

  @override
  String get transferSendSubtitle =>
      'Este dispositivo tiene las claves. Comparte un código con el nuevo dispositivo.';

  @override
  String get transferReceiveOnThis => 'Recibir en este dispositivo';

  @override
  String get transferReceiveSubtitle =>
      'Este es el nuevo dispositivo. Introduce el código del dispositivo anterior.';

  @override
  String get transferChooseMethod => 'Elegir método de transferencia';

  @override
  String get transferLan => 'LAN (misma red)';

  @override
  String get transferLanSubtitle =>
      'Rápido y directo. Ambos dispositivos deben estar en la misma Wi-Fi.';

  @override
  String get transferNostrRelay => 'Retransmisor Nostr';

  @override
  String get transferNostrRelaySubtitle =>
      'Funciona en cualquier red usando un retransmisor Nostr existente.';

  @override
  String get transferRelayUrl => 'URL del retransmisor';

  @override
  String get transferEnterCode => 'Introducir código de transferencia';

  @override
  String get transferPasteCode => 'Pega el código LAN:... o NOS:... aquí';

  @override
  String get transferConnect => 'Conectar';

  @override
  String get transferGenerating => 'Generando código de transferencia…';

  @override
  String get transferShareCode => 'Comparte este código con el receptor:';

  @override
  String get transferCopyCode => 'Copiar código';

  @override
  String get transferCodeCopied => 'Código copiado al portapapeles';

  @override
  String get transferWaitingReceiver =>
      'Esperando a que el receptor se conecte…';

  @override
  String get transferConnectingSender => 'Conectando con el emisor…';

  @override
  String get transferVerifyBoth =>
      'Compara este código en ambos dispositivos.\nSi coinciden, la transferencia es segura.';

  @override
  String get transferComplete => 'Transferencia completada';

  @override
  String get transferKeysImported => 'Claves importadas';

  @override
  String get transferCompleteSenderBody =>
      'Tus claves permanecen activas en este dispositivo.\nEl receptor ahora puede usar tu identidad.';

  @override
  String get transferCompleteReceiverBody =>
      'Claves importadas exitosamente.\nReinicia la app para aplicar la nueva identidad.';

  @override
  String get transferRestartApp => 'Reiniciar app';

  @override
  String get transferFailed => 'La transferencia falló';

  @override
  String get transferTryAgain => 'Intentar de nuevo';

  @override
  String get transferEnterRelayFirst =>
      'Introduce una URL de retransmisor primero';

  @override
  String get transferPasteCodeFromSender =>
      'Pega el código de transferencia del emisor';

  @override
  String get menuReply => 'Responder';

  @override
  String get menuForward => 'Reenviar';

  @override
  String get menuReact => 'Reaccionar';

  @override
  String get menuCopy => 'Copiar';

  @override
  String get menuEdit => 'Editar';

  @override
  String get menuRetry => 'Reintentar';

  @override
  String get menuCancelScheduled => 'Cancelar programado';

  @override
  String get menuDelete => 'Eliminar';

  @override
  String get menuForwardTo => 'Reenviar a…';

  @override
  String menuForwardedTo(String name) {
    return 'Reenviado a $name';
  }

  @override
  String get menuScheduledMessages => 'Mensajes programados';

  @override
  String get menuNoScheduledMessages => 'No hay mensajes programados';

  @override
  String menuSendsOn(String date) {
    return 'Se envía el $date';
  }

  @override
  String get menuDisappearingMessages => 'Mensajes temporales';

  @override
  String get menuDisappearingSubtitle =>
      'Los mensajes se eliminan automáticamente después del tiempo seleccionado.';

  @override
  String get menuTtlOff => 'Desactivado';

  @override
  String get menuTtl1h => '1 hora';

  @override
  String get menuTtl24h => '24 horas';

  @override
  String get menuTtl7d => '7 días';

  @override
  String get menuAttachPhoto => 'Foto';

  @override
  String get menuAttachFile => 'Archivo';

  @override
  String get menuAttachVideo => 'Video';

  @override
  String get mediaTitle => 'Multimedia';

  @override
  String get mediaFileLabel => 'ARCHIVO';

  @override
  String mediaPhotosTab(int count) {
    return 'Fotos ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Archivos ($count)';
  }

  @override
  String get mediaNoPhotos => 'Aún no hay fotos';

  @override
  String get mediaNoFiles => 'Aún no hay archivos';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Guardado en Descargas/$name';
  }

  @override
  String get mediaFailedToSave => 'Error al guardar el archivo';

  @override
  String get statusNewStatus => 'Nuevo estado';

  @override
  String get statusPublish => 'Publicar';

  @override
  String get statusExpiresIn24h => 'El estado expira en 24 horas';

  @override
  String get statusWhatsOnYourMind => '¿Qué tienes en mente?';

  @override
  String get statusPhotoAttached => 'Foto adjunta';

  @override
  String get statusAttachPhoto => 'Adjuntar foto (opcional)';

  @override
  String get statusEnterText => 'Por favor, escribe algo para tu estado.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Error al seleccionar foto: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Error al publicar: $error';
  }

  @override
  String get panicSetPanicKey => 'Configurar clave de pánico';

  @override
  String get panicEmergencySelfDestruct => 'Autodestrucción de emergencia';

  @override
  String get panicIrreversible => 'Esta acción es irreversible';

  @override
  String get panicWarningBody =>
      'Introducir esta clave en la pantalla de bloqueo borra instantáneamente TODOS los datos — mensajes, contactos, claves, identidad. Usa una clave diferente a tu contraseña habitual.';

  @override
  String get panicKeyHint => 'Clave de pánico';

  @override
  String get panicConfirmHint => 'Confirmar clave de pánico';

  @override
  String get panicMinChars =>
      'La clave de pánico debe tener al menos 8 caracteres';

  @override
  String get panicKeysDoNotMatch => 'Las claves no coinciden';

  @override
  String get panicSetFailed =>
      'Error al guardar la clave de pánico — inténtalo de nuevo';

  @override
  String get passwordSetAppPassword => 'Establecer contraseña de la app';

  @override
  String get passwordProtectsMessages => 'Protege tus mensajes en reposo';

  @override
  String get passwordInfoBanner =>
      'Se requiere cada vez que abras Pulse. Si la olvidas, tus datos no se pueden recuperar.';

  @override
  String get passwordHint => 'Contraseña';

  @override
  String get passwordConfirmHint => 'Confirmar contraseña';

  @override
  String get passwordSetButton => 'Establecer contraseña';

  @override
  String get passwordSkipForNow => 'Omitir por ahora';

  @override
  String get passwordMinChars =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get profileCardSaved => '¡Perfil guardado!';

  @override
  String get profileCardE2eeIdentity => 'Identidad E2EE';

  @override
  String get profileCardDisplayName => 'Nombre para mostrar';

  @override
  String get profileCardDisplayNameHint => 'ej. Juan Pérez';

  @override
  String get profileCardAbout => 'Acerca de';

  @override
  String get profileCardSaveProfile => 'Guardar perfil';

  @override
  String get profileCardYourName => 'Tu nombre';

  @override
  String get profileCardAddressCopied => '¡Dirección copiada!';

  @override
  String get profileCardInboxAddress => 'Tu dirección de buzón';

  @override
  String get profileCardInboxAddresses => 'Tus direcciones de buzón';

  @override
  String get profileCardShareAllAddresses =>
      'Compartir todas las direcciones (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Comparte con tus contactos para que puedan escribirte.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return '¡Las $count direcciones copiadas como un solo enlace!';
  }

  @override
  String get settingsMyProfile => 'Mi perfil';

  @override
  String get settingsYourInboxAddress => 'Tu dirección de buzón';

  @override
  String get settingsMyQrCode => 'Compartir contacto';

  @override
  String get settingsMyQrSubtitle =>
      'Código QR y enlace de invitación para tu dirección';

  @override
  String get settingsShareMyAddress => 'Compartir mi dirección';

  @override
  String get settingsNoAddressYet =>
      'Aún no hay dirección — guarda los ajustes primero';

  @override
  String get settingsInviteLink => 'Enlace de invitación';

  @override
  String get settingsRawAddress => 'Dirección sin formato';

  @override
  String get settingsCopyLink => 'Copiar enlace';

  @override
  String get settingsCopyAddress => 'Copiar dirección';

  @override
  String get settingsInviteLinkCopied => 'Enlace de invitación copiado';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsThemeEngine => 'Motor de temas';

  @override
  String get settingsThemeEngineSubtitle => 'Personalizar colores y fuentes';

  @override
  String get settingsSignalProtocol => 'Protocolo Signal';

  @override
  String get settingsSignalProtocolSubtitle =>
      'Las claves E2EE se almacenan de forma segura';

  @override
  String get settingsActive => 'ACTIVO';

  @override
  String get settingsIdentityBackup => 'Respaldo de identidad';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Exportar o importar tu identidad de Signal';

  @override
  String get settingsIdentityBackupBody =>
      'Exporta tus claves de identidad de Signal a un código de respaldo, o restaura desde uno existente.';

  @override
  String get settingsTransferDevice => 'Transferir a otro dispositivo';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Mover tu identidad vía LAN o retransmisor Nostr';

  @override
  String get settingsExportIdentity => 'Exportar identidad';

  @override
  String get settingsExportIdentityBody =>
      'Copia este código de respaldo y guárdalo de forma segura:';

  @override
  String get settingsSaveFile => 'Guardar archivo';

  @override
  String get settingsImportIdentity => 'Importar identidad';

  @override
  String get settingsImportIdentityBody =>
      'Pega tu código de respaldo a continuación. Esto sobrescribirá tu identidad actual.';

  @override
  String get settingsPasteBackupCode => 'Pega el código de respaldo aquí…';

  @override
  String get settingsIdentityImported =>
      '¡Identidad + contactos importados! Reinicia la app para aplicar.';

  @override
  String get settingsSecurity => 'Seguridad';

  @override
  String get settingsAppPassword => 'Contraseña de la app';

  @override
  String get settingsPasswordEnabled => 'Activada — requerida en cada inicio';

  @override
  String get settingsPasswordDisabled =>
      'Desactivada — la app abre sin contraseña';

  @override
  String get settingsChangePassword => 'Cambiar contraseña';

  @override
  String get settingsChangePasswordSubtitle =>
      'Actualizar la contraseña de bloqueo de la app';

  @override
  String get settingsSetPanicKey => 'Configurar clave de pánico';

  @override
  String get settingsChangePanicKey => 'Cambiar clave de pánico';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Actualizar clave de borrado de emergencia';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Una clave que borra todos los datos instantáneamente';

  @override
  String get settingsRemovePanicKey => 'Eliminar clave de pánico';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Desactivar autodestrucción de emergencia';

  @override
  String get settingsRemovePanicKeyBody =>
      'La autodestrucción de emergencia se desactivará. Puedes reactivarla en cualquier momento.';

  @override
  String get settingsDisableAppPassword => 'Desactivar contraseña de la app';

  @override
  String get settingsEnterCurrentPassword =>
      'Introduce tu contraseña actual para confirmar';

  @override
  String get settingsCurrentPassword => 'Contraseña actual';

  @override
  String get settingsIncorrectPassword => 'Contraseña incorrecta';

  @override
  String get settingsPasswordUpdated => 'Contraseña actualizada';

  @override
  String get settingsChangePasswordProceed =>
      'Introduce tu contraseña actual para continuar';

  @override
  String get settingsData => 'Datos';

  @override
  String get settingsBackupMessages => 'Respaldar mensajes';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Exportar historial cifrado de mensajes a un archivo';

  @override
  String get settingsRestoreMessages => 'Restaurar mensajes';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Importar mensajes desde un archivo de respaldo';

  @override
  String get settingsExportKeys => 'Exportar claves';

  @override
  String get settingsExportKeysSubtitle =>
      'Guardar claves de identidad en un archivo cifrado';

  @override
  String get settingsImportKeys => 'Importar claves';

  @override
  String get settingsImportKeysSubtitle =>
      'Restaurar claves de identidad desde un archivo exportado';

  @override
  String get settingsBackupPassword => 'Contraseña de respaldo';

  @override
  String get settingsPasswordCannotBeEmpty =>
      'La contraseña no puede estar vacía';

  @override
  String get settingsPasswordMin4Chars =>
      'La contraseña debe tener al menos 4 caracteres';

  @override
  String get settingsCallsTurn => 'Llamadas y TURN';

  @override
  String get settingsLocalNetwork => 'Red local';

  @override
  String get settingsCensorshipResistance => 'Resistencia a la censura';

  @override
  String get settingsNetwork => 'Red';

  @override
  String get settingsProxyTunnels => 'Proxy y túneles';

  @override
  String get settingsTurnServers => 'Servidores TURN';

  @override
  String get settingsProviderTitle => 'Proveedor';

  @override
  String get settingsLanFallback => 'Respaldo LAN';

  @override
  String get settingsLanFallbackSubtitle =>
      'Difundir presencia y entregar mensajes en la red local cuando no hay internet. Desactívalo en redes no confiables (Wi-Fi público).';

  @override
  String get settingsBgDelivery => 'Entrega en segundo plano';

  @override
  String get settingsBgDeliverySubtitle =>
      'Seguir recibiendo mensajes cuando la app está minimizada. Muestra una notificación persistente.';

  @override
  String get settingsYourInboxProvider => 'Tu proveedor de buzón';

  @override
  String get settingsConnectionDetails => 'Detalles de conexión';

  @override
  String get settingsSaveAndConnect => 'Guardar y conectar';

  @override
  String get settingsSecondaryInboxes => 'Buzones secundarios';

  @override
  String get settingsAddSecondaryInbox => 'Agregar buzón secundario';

  @override
  String get settingsAdvanced => 'Avanzado';

  @override
  String get settingsDiscover => 'Descubrir';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsPrivacyPolicySubtitle => 'Cómo Pulse protege tus datos';

  @override
  String get settingsCrashReporting => 'Informes de errores';

  @override
  String get settingsCrashReportingSubtitle =>
      'Enviar informes de errores anónimos para ayudar a mejorar Pulse. Nunca se envía contenido de mensajes ni contactos.';

  @override
  String get settingsCrashReportingEnabled =>
      'Informes de errores activados — reinicia la app para aplicar';

  @override
  String get settingsCrashReportingDisabled =>
      'Informes de errores desactivados — reinicia la app para aplicar';

  @override
  String get settingsSensitiveOperation => 'Operación sensible';

  @override
  String get settingsSensitiveOperationBody =>
      'Estas claves son tu identidad. Cualquier persona con este archivo puede hacerse pasar por ti. Guárdalo de forma segura y bórralo después de la transferencia.';

  @override
  String get settingsIUnderstandContinue => 'Entiendo, continuar';

  @override
  String get settingsReplaceIdentity => '¿Reemplazar identidad?';

  @override
  String get settingsReplaceIdentityBody =>
      'Esto sobrescribirá tus claves de identidad actuales. Tus sesiones de Signal existentes quedarán invalidadas y los contactos necesitarán restablecer el cifrado. La app necesitará reiniciarse.';

  @override
  String get settingsReplaceKeys => 'Reemplazar claves';

  @override
  String get settingsKeysImported => 'Claves importadas';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count claves importadas exitosamente. Reinicia la app para reinicializar con la nueva identidad.';
  }

  @override
  String get settingsRestartNow => 'Reiniciar ahora';

  @override
  String get settingsLater => 'Más tarde';

  @override
  String get profileGroupLabel => 'Grupo';

  @override
  String get profileAddButton => 'Agregar';

  @override
  String get profileKickButton => 'Expulsar';

  @override
  String get dataSectionTitle => 'Datos';

  @override
  String get dataBackupMessages => 'Respaldar mensajes';

  @override
  String get dataBackupPasswordSubtitle =>
      'Elige una contraseña para cifrar tu respaldo de mensajes.';

  @override
  String get dataBackupConfirmLabel => 'Crear respaldo';

  @override
  String get dataCreatingBackup => 'Creando respaldo';

  @override
  String get dataBackupPreparing => 'Preparando...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Exportando mensaje $done de $total...';
  }

  @override
  String get dataBackupSavingFile => 'Guardando archivo...';

  @override
  String get dataSaveMessageBackupDialog => 'Guardar respaldo de mensajes';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Respaldo guardado ($count mensajes)\n$path';
  }

  @override
  String get dataBackupFailed => 'El respaldo falló — no se exportaron datos';

  @override
  String dataBackupFailedError(String error) {
    return 'El respaldo falló: $error';
  }

  @override
  String get dataSelectMessageBackupDialog =>
      'Seleccionar respaldo de mensajes';

  @override
  String get dataInvalidBackupFile =>
      'Archivo de respaldo inválido (demasiado pequeño)';

  @override
  String get dataNotValidBackupFile =>
      'No es un archivo de respaldo válido de Pulse';

  @override
  String get dataRestoreMessages => 'Restaurar mensajes';

  @override
  String get dataRestorePasswordSubtitle =>
      'Introduce la contraseña usada para crear este respaldo.';

  @override
  String get dataRestoreConfirmLabel => 'Restaurar';

  @override
  String get dataRestoringMessages => 'Restaurando mensajes';

  @override
  String get dataRestoreDecrypting => 'Descifrando...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Importando mensaje $done de $total...';
  }

  @override
  String get dataRestoreFailed =>
      'La restauración falló — contraseña incorrecta o archivo corrupto';

  @override
  String dataRestoreSuccess(int count) {
    return '$count mensajes nuevos restaurados';
  }

  @override
  String get dataRestoreNothingNew =>
      'No hay mensajes nuevos para importar (todos ya existen)';

  @override
  String dataRestoreFailedError(String error) {
    return 'La restauración falló: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Seleccionar exportación de claves';

  @override
  String get dataNotValidKeyFile =>
      'No es un archivo válido de exportación de claves de Pulse';

  @override
  String get dataExportKeys => 'Exportar claves';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Elige una contraseña para cifrar tu exportación de claves.';

  @override
  String get dataExportKeysConfirmLabel => 'Exportar';

  @override
  String get dataExportingKeys => 'Exportando claves';

  @override
  String get dataExportingKeysStatus => 'Cifrando claves de identidad...';

  @override
  String get dataSaveKeyExportDialog => 'Guardar exportación de claves';

  @override
  String dataKeysExportedTo(String path) {
    return 'Claves exportadas a:\n$path';
  }

  @override
  String get dataExportFailed =>
      'La exportación falló — no se encontraron claves';

  @override
  String dataExportFailedError(String error) {
    return 'La exportación falló: $error';
  }

  @override
  String get dataImportKeys => 'Importar claves';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Introduce la contraseña usada para cifrar esta exportación de claves.';

  @override
  String get dataImportKeysConfirmLabel => 'Importar';

  @override
  String get dataImportingKeys => 'Importando claves';

  @override
  String get dataImportingKeysStatus => 'Descifrando claves de identidad...';

  @override
  String get dataImportFailed =>
      'La importación falló — contraseña incorrecta o archivo corrupto';

  @override
  String dataImportFailedError(String error) {
    return 'La importación falló: $error';
  }

  @override
  String get securitySectionTitle => 'Seguridad';

  @override
  String get securityIncorrectPassword => 'Contraseña incorrecta';

  @override
  String get securityPasswordUpdated => 'Contraseña actualizada';

  @override
  String get appearanceSectionTitle => 'Apariencia';

  @override
  String appearanceExportFailed(String error) {
    return 'La exportación falló: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Guardado en $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'La importación falló: $error';
  }

  @override
  String get aboutSectionTitle => 'Acerca de';

  @override
  String get providerPublicKey => 'Clave pública';

  @override
  String get providerRelay => 'Retransmisor';

  @override
  String get providerAutoConfigured =>
      'Autoconfigurado desde tu contraseña de recuperación. Retransmisor descubierto automáticamente.';

  @override
  String get providerKeyStoredLocally =>
      'Tu clave se almacena localmente en almacenamiento seguro — nunca se envía a ningún servidor.';

  @override
  String get providerSessionInfo =>
      'Session Network — E2EE con enrutamiento cebolla. Su ID de Session se genera automáticamente y se almacena de forma segura. Los nodos se descubren automáticamente desde nodos semilla integrados.';

  @override
  String get providerAdvanced => 'Avanzado';

  @override
  String get providerSaveAndConnect => 'Guardar y conectar';

  @override
  String get providerAddSecondaryInbox => 'Agregar buzón secundario';

  @override
  String get providerSecondaryInboxes => 'Buzones secundarios';

  @override
  String get providerYourInboxProvider => 'Tu proveedor de buzón';

  @override
  String get providerConnectionDetails => 'Detalles de conexión';

  @override
  String get addContactTitle => 'Agregar contacto';

  @override
  String get addContactInviteLinkLabel => 'Enlace de invitación o dirección';

  @override
  String get addContactTapToPaste => 'Toca para pegar enlace de invitación';

  @override
  String get addContactPasteTooltip => 'Pegar del portapapeles';

  @override
  String get addContactAddressDetected => 'Dirección de contacto detectada';

  @override
  String addContactRoutesDetected(int count) {
    return '$count rutas detectadas — SmartRouter elige la más rápida';
  }

  @override
  String get addContactFetchingProfile => 'Obteniendo perfil…';

  @override
  String addContactProfileFound(String name) {
    return 'Encontrado: $name';
  }

  @override
  String get addContactNoProfileFound => 'No se encontró perfil';

  @override
  String get addContactDisplayNameLabel => 'Nombre para mostrar';

  @override
  String get addContactDisplayNameHint => '¿Cómo quieres llamarle?';

  @override
  String get addContactAddManually => 'Agregar dirección manualmente';

  @override
  String get addContactButton => 'Agregar contacto';

  @override
  String get networkDiagnosticsTitle => 'Diagnóstico de red';

  @override
  String get networkDiagnosticsNostrRelays => 'Retransmisores Nostr';

  @override
  String get networkDiagnosticsDirect => 'Directos';

  @override
  String get networkDiagnosticsTorOnly => 'Solo Tor';

  @override
  String get networkDiagnosticsBest => 'Mejor';

  @override
  String get networkDiagnosticsNone => 'ninguno';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Estado';

  @override
  String get networkDiagnosticsConnected => 'Conectado';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Conectando $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Apagado';

  @override
  String get networkDiagnosticsTransport => 'Transporte';

  @override
  String get networkDiagnosticsInfrastructure => 'Infraestructura';

  @override
  String get networkDiagnosticsSessionNodes => 'Nodos de Session';

  @override
  String get networkDiagnosticsTurnServers => 'Servidores TURN';

  @override
  String get networkDiagnosticsLastProbe => 'Último sondeo';

  @override
  String get networkDiagnosticsRunning => 'Ejecutando...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Ejecutar diagnóstico';

  @override
  String get networkDiagnosticsForceReprobe => 'Forzar resondeo completo';

  @override
  String get networkDiagnosticsJustNow => 'ahora mismo';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'hace ${minutes}m';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'hace ${hours}h';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'hace ${days}d';
  }

  @override
  String get homeNoEch => 'Sin ECH';

  @override
  String get homeNoEchTooltip =>
      'Proxy uTLS no disponible — ECH desactivado.\nLa huella TLS es visible para DPI.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Guardado y conectado a $provider';
  }

  @override
  String get settingsTorFailedToStart => 'El Tor integrado no pudo iniciarse';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon no pudo iniciarse';

  @override
  String get verifyTitle => 'Verificar número de seguridad';

  @override
  String get verifyIdentityVerified => 'Identidad verificada';

  @override
  String get verifyNotYetVerified => 'Aún no verificado';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Has verificado el número de seguridad de $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Compara estos números con $name en persona o por un canal de confianza.';
  }

  @override
  String get verifyExplanation =>
      'Cada conversación tiene un número de seguridad único. Si ambos ven los mismos números en sus dispositivos, la conexión está verificada de extremo a extremo.';

  @override
  String verifyContactKey(String name) {
    return 'Clave de $name';
  }

  @override
  String get verifyYourKey => 'Tu clave';

  @override
  String get verifyRemoveVerification => 'Eliminar verificación';

  @override
  String get verifyMarkAsVerified => 'Marcar como verificado';

  @override
  String verifyAfterReinstall(String name) {
    return 'Si $name reinstala la app, el número de seguridad cambiará y la verificación se eliminará automáticamente.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Solo marca como verificado después de comparar los números con $name en una llamada de voz o en persona.';
  }

  @override
  String get verifyNoSession =>
      'Aún no se ha establecido sesión de cifrado. Envía un mensaje primero para generar los números de seguridad.';

  @override
  String get verifyNoKeyAvailable => 'Clave no disponible';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Huella digital de $label copiada';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL de la base de datos';

  @override
  String get providerOptionalHint => 'Opcional';

  @override
  String get providerWebApiKeyLabel => 'Clave API Web';

  @override
  String get providerOptionalForPublicDb => 'Opcional para BD pública';

  @override
  String get providerRelayUrlLabel => 'URL del retransmisor';

  @override
  String get providerPrivateKeyLabel => 'Clave privada';

  @override
  String get providerPrivateKeyNsecLabel => 'Clave privada (nsec)';

  @override
  String get providerStorageNodeLabel =>
      'URL del nodo de almacenamiento (opcional)';

  @override
  String get providerStorageNodeHint =>
      'Dejar vacío para nodos semilla integrados';

  @override
  String get transferInvalidCodeFormat =>
      'Formato de código no reconocido — debe empezar con LAN: o NOS:';

  @override
  String get profileCardFingerprintCopied => 'Huella digital copiada';

  @override
  String get profileCardAboutHint => 'Privacidad ante todo 🔒';

  @override
  String get profileCardSaveButton => 'Guardar perfil';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Exportar mensajes cifrados, contactos y avatares a un archivo';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Audio';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Entregado a $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Entregado a $count';
  }

  @override
  String get groupStatusDialogTitle => 'Info del mensaje';

  @override
  String get groupStatusRead => 'Leído';

  @override
  String get groupStatusDelivered => 'Entregado';

  @override
  String get groupStatusPending => 'Pendiente';

  @override
  String get groupStatusNoData => 'Aún no hay información de entrega';

  @override
  String get profileTransferAdmin => 'Hacer administrador';

  @override
  String profileTransferAdminConfirm(String name) {
    return '¿Hacer a $name el nuevo administrador?';
  }

  @override
  String get profileTransferAdminBody =>
      'Perderás los privilegios de administrador. Esto no se puede deshacer.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name ahora es el administrador';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Política de privacidad';

  @override
  String get privacyOverviewHeading => 'Resumen';

  @override
  String get privacyOverviewBody =>
      'Pulse es un mensajero sin servidor con cifrado de extremo a extremo. Tu privacidad no es solo una función — es la arquitectura. No hay servidores de Pulse. No se almacenan cuentas en ninguna parte. Los desarrolladores no recopilan, transmiten ni almacenan ningún dato.';

  @override
  String get privacyDataCollectionHeading => 'Recolección de datos';

  @override
  String get privacyDataCollectionBody =>
      'Pulse no recopila ningún dato personal. Específicamente:\n\n- No se requiere correo electrónico, número de teléfono ni nombre real\n- Sin analíticas, rastreo ni telemetría\n- Sin identificadores publicitarios\n- Sin acceso a la lista de contactos\n- Sin respaldos en la nube (los mensajes solo existen en tu dispositivo)\n- No se envían metadatos a ningún servidor de Pulse (no hay ninguno)';

  @override
  String get privacyEncryptionHeading => 'Cifrado';

  @override
  String get privacyEncryptionBody =>
      'Todos los mensajes se cifran usando el Protocolo Signal (Double Ratchet con acuerdo de claves X3DH). Las claves de cifrado se generan y almacenan exclusivamente en tu dispositivo. Nadie — incluidos los desarrolladores — puede leer tus mensajes.';

  @override
  String get privacyNetworkHeading => 'Arquitectura de red';

  @override
  String get privacyNetworkBody =>
      'Pulse usa adaptadores de transporte federados (retransmisores Nostr, nodos de servicio Session/Oxen, Firebase Realtime Database, LAN). Estos transportes solo llevan texto cifrado. Los operadores de retransmisores pueden ver tu dirección IP y volumen de tráfico, pero no pueden descifrar el contenido de los mensajes.\n\nCuando Tor está activado, tu dirección IP también se oculta de los operadores de retransmisores.';

  @override
  String get privacyStunHeading => 'Servidores STUN/TURN';

  @override
  String get privacyStunBody =>
      'Las llamadas de voz y video usan WebRTC con cifrado DTLS-SRTP. Los servidores STUN (usados para descubrir tu IP pública para conexiones punto a punto) y los servidores TURN (usados para retransmitir medios cuando falla la conexión directa) pueden ver tu dirección IP y duración de la llamada, pero no pueden descifrar el contenido.\n\nPuedes configurar tu propio servidor TURN en Ajustes para máxima privacidad.';

  @override
  String get privacyCrashHeading => 'Informes de errores';

  @override
  String get privacyCrashBody =>
      'Si los informes de errores de Sentry están activados (vía SENTRY_DSN en tiempo de compilación), se pueden enviar informes de errores anónimos. Estos no contienen contenido de mensajes, información de contactos ni datos personales identificables. Los informes de errores se pueden desactivar en tiempo de compilación omitiendo el DSN.';

  @override
  String get privacyPasswordHeading => 'Contraseña y claves';

  @override
  String get privacyPasswordBody =>
      'Tu contraseña de recuperación se usa para derivar claves criptográficas vía Argon2id (KDF con uso intensivo de memoria). La contraseña nunca se transmite a ninguna parte. Si pierdes tu contraseña, tu cuenta no se puede recuperar — no hay servidor para restablecerla.';

  @override
  String get privacyFontsHeading => 'Fuentes';

  @override
  String get privacyFontsBody =>
      'Pulse incluye todas las fuentes localmente. No se hacen solicitudes a Google Fonts ni a ningún servicio de fuentes externo.';

  @override
  String get privacyThirdPartyHeading => 'Servicios de terceros';

  @override
  String get privacyThirdPartyBody =>
      'Pulse no se integra con ninguna red publicitaria, proveedor de analíticas, plataforma de redes sociales ni intermediario de datos. Las únicas conexiones de red son a los retransmisores de transporte que configures.';

  @override
  String get privacyOpenSourceHeading => 'Código abierto';

  @override
  String get privacyOpenSourceBody =>
      'Pulse es software de código abierto. Puedes auditar el código fuente completo para verificar estas afirmaciones de privacidad.';

  @override
  String get privacyContactHeading => 'Contacto';

  @override
  String get privacyContactBody =>
      'Para preguntas relacionadas con la privacidad, abre un issue en el repositorio del proyecto.';

  @override
  String get privacyLastUpdated => 'Última actualización: marzo 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Error al guardar: $error';
  }

  @override
  String get themeEngineTitle => 'Motor de temas';

  @override
  String get torBuiltInTitle => 'Tor integrado';

  @override
  String get torConnectedSubtitle =>
      'Conectado — Nostr enrutado vía 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Conectando… $pct%';
  }

  @override
  String get torNotRunning =>
      'No está ejecutándose — toca el interruptor para reiniciar';

  @override
  String get torDescription =>
      'Enruta Nostr vía Tor (Snowflake para redes censuradas)';

  @override
  String get torNetworkDiagnostics => 'Diagnóstico de red';

  @override
  String get torTransportLabel => 'Transporte: ';

  @override
  String get torPtAuto => 'Auto';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Plain';

  @override
  String get torTimeoutLabel => 'Tiempo límite: ';

  @override
  String get torInfoDescription =>
      'Cuando está activado, las conexiones WebSocket de Nostr se enrutan a través de Tor (SOCKS5). Tor Browser escucha en 127.0.0.1:9150. El demonio tor independiente usa el puerto 9050. Las conexiones de Firebase no se ven afectadas.';

  @override
  String get torRouteNostrTitle => 'Enrutar Nostr vía Tor';

  @override
  String get torManagedByBuiltin => 'Gestionado por Tor integrado';

  @override
  String get torActiveRouting => 'Activo — Tráfico de Nostr enrutado por Tor';

  @override
  String get torDisabled => 'Desactivado';

  @override
  String get torProxySocks5 => 'Proxy Tor (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Host del proxy';

  @override
  String get torProxyPortLabel => 'Puerto';

  @override
  String get torPortInfo =>
      'Tor Browser: puerto 9150  •  demonio tor: puerto 9050';

  @override
  String get torForceNostrTitle => 'Enrutar mensajes a través de Tor';

  @override
  String get torForceNostrSubtitle =>
      'Todas las conexiones de Nostr relay pasarán por Tor. Más lento pero oculta tu IP de los relays.';

  @override
  String get torForceNostrDisabled => 'Tor debe estar activado primero';

  @override
  String get torForcePulseTitle => 'Enrutar Pulse relay a través de Tor';

  @override
  String get torForcePulseSubtitle =>
      'Todas las conexiones de Pulse relay pasarán por Tor. Más lento pero oculta tu IP del servidor.';

  @override
  String get torForcePulseDisabled => 'Tor debe estar activado primero';

  @override
  String get i2pProxySocks5 => 'Proxy I2P (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P usa SOCKS5 en el puerto 4447 por defecto. Conéctate a un retransmisor Nostr vía outproxy de I2P (ej. relay.damus.i2p) para comunicarte con usuarios en cualquier transporte. Tor tiene prioridad cuando ambos están activados.';

  @override
  String get i2pRouteNostrTitle => 'Enrutar Nostr vía I2P';

  @override
  String get i2pActiveRouting => 'Activo — Tráfico de Nostr enrutado por I2P';

  @override
  String get i2pDisabled => 'Desactivado';

  @override
  String get i2pProxyHostLabel => 'Host del proxy';

  @override
  String get i2pProxyPortLabel => 'Puerto';

  @override
  String get i2pPortInfo => 'Puerto SOCKS5 predeterminado del router I2P: 4447';

  @override
  String get customProxySocks5 => 'Proxy personalizado (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'Retransmisor CF Worker';

  @override
  String get customProxyInfoDescription =>
      'El proxy personalizado enruta el tráfico a través de tu V2Ray/Xray/Shadowsocks. CF Worker actúa como un proxy de retransmisor personal en Cloudflare CDN — GFW ve *.workers.dev, no el retransmisor real.';

  @override
  String get customSocks5ProxyTitle => 'Proxy SOCKS5 personalizado';

  @override
  String get customProxyActive => 'Activo — tráfico enrutado vía SOCKS5';

  @override
  String get customProxyDisabled => 'Desactivado';

  @override
  String get customProxyHostLabel => 'Host del proxy';

  @override
  String get customProxyPortLabel => 'Puerto';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Dominio del Worker (opcional)';

  @override
  String get customWorkerHelpTitle =>
      'Cómo desplegar un CF Worker relay (gratis)';

  @override
  String get customWorkerScriptCopied => '¡Script copiado!';

  @override
  String get customWorkerStep1 =>
      '1. Ve a dash.cloudflare.com → Workers & Pages\n2. Create Worker → pega este script:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → copia el dominio (ej. my-relay.user.workers.dev)\n4. Pega el dominio arriba → Guardar\n\nLa app se conecta automáticamente: wss://domain/?r=relay_url\nGFW ve: conexión a *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Conectado — SOCKS5 en 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Conectando…';

  @override
  String get psiphonNotRunning =>
      'No está ejecutándose — toca el interruptor para reiniciar';

  @override
  String get psiphonDescription =>
      'Túnel rápido (~3s de arranque, 2000+ VPS rotativos)';

  @override
  String get turnCommunityServers => 'Servidores TURN de la comunidad';

  @override
  String get turnCustomServer => 'Servidor TURN personalizado (BYOD)';

  @override
  String get turnInfoDescription =>
      'Los servidores TURN solo retransmiten flujos ya cifrados (DTLS-SRTP). Un operador de retransmisor ve tu IP y volumen de tráfico, pero no puede descifrar las llamadas. TURN solo se usa cuando falla la conexión P2P directa (~15–20% de las conexiones).';

  @override
  String get turnFreeLabel => 'GRATIS';

  @override
  String get turnServerUrlLabel => 'URL del servidor TURN';

  @override
  String get turnServerUrlHint => 'turn:tu-servidor.com:3478 o turns:...';

  @override
  String get turnUsernameLabel => 'Usuario';

  @override
  String get turnPasswordLabel => 'Contraseña';

  @override
  String get turnOptionalHint => 'Opcional';

  @override
  String get turnCustomInfo =>
      'Autoaloja coturn en cualquier VPS de \$5/mes para máximo control. Las credenciales se almacenan localmente.';

  @override
  String get themePickerAppearance => 'Apariencia';

  @override
  String get themePickerAccentColor => 'Color de acento';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Oscuro';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeDynamicPresets => 'Preajustes';

  @override
  String get themeDynamicPrimaryColor => 'Color primario';

  @override
  String get themeDynamicBorderRadius => 'Radio de borde';

  @override
  String get themeDynamicFont => 'Fuente';

  @override
  String get themeDynamicAppearance => 'Apariencia';

  @override
  String get themeDynamicUiStyle => 'Estilo de UI';

  @override
  String get themeDynamicUiStyleDescription =>
      'Controla cómo se ven los diálogos, interruptores e indicadores.';

  @override
  String get themeDynamicSharp => 'Angular';

  @override
  String get themeDynamicRound => 'Redondeado';

  @override
  String get themeDynamicModeDark => 'Oscuro';

  @override
  String get themeDynamicModeLight => 'Claro';

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
      'URL de Firebase inválida. Se espera https://proyecto.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'URL de retransmisor inválida. Se espera wss://relay.ejemplo.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'URL de servidor Pulse inválida. Se espera https://servidor:puerto';

  @override
  String get providerPulseServerUrlLabel => 'URL del servidor';

  @override
  String get providerPulseServerUrlHint => 'https://tu-servidor:8443';

  @override
  String get providerPulseInviteLabel => 'Código de invitación';

  @override
  String get providerPulseInviteHint =>
      'Código de invitación (si es requerido)';

  @override
  String get providerPulseInfo =>
      'Retransmisor autoalojado. Claves derivadas de tu contraseña de recuperación.';

  @override
  String get providerScreenTitle => 'Buzones';

  @override
  String get providerSecondaryInboxesHeader => 'BUZONES SECUNDARIOS';

  @override
  String get providerSecondaryInboxesInfo =>
      'Los buzones secundarios reciben mensajes simultáneamente para redundancia.';

  @override
  String get providerRemoveTooltip => 'Eliminar';

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
  String get emojiNoRecent => 'No hay emojis recientes';

  @override
  String get emojiSearchHint => 'Buscar emoji...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Toca para chatear';

  @override
  String get imageViewerSaveToDownloads => 'Guardar en Descargas';

  @override
  String imageViewerSavedTo(String path) {
    return 'Guardado en $path';
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
  String get settingsLanguageSubtitle => 'Idioma de visualización de la app';

  @override
  String get settingsLanguageSystem => 'Predeterminado del sistema';

  @override
  String get onboardingLanguageTitle => 'Elige tu idioma';

  @override
  String get onboardingLanguageSubtitle =>
      'Puedes cambiar esto más tarde en Configuración';

  @override
  String get videoNoteRecord => 'Grabar mensaje de vídeo';

  @override
  String get videoNoteTapToRecord => 'Toca para grabar';

  @override
  String get videoNoteTapToStop => 'Toca para detener';

  @override
  String get videoNoteCameraPermission => 'Permiso de cámara denegado';

  @override
  String get videoNoteMaxDuration => 'Máximo 30 segundos';

  @override
  String get videoNoteNotSupported =>
      'Las notas de vídeo no son compatibles con esta plataforma';

  @override
  String get navChats => 'Chats';

  @override
  String get navUpdates => 'Actualizaciones';

  @override
  String get navCalls => 'Llamadas';

  @override
  String get filterAll => 'Todo';

  @override
  String get filterUnread => 'No leídos';

  @override
  String get filterGroups => 'Grupos';

  @override
  String get callsNoRecent => 'Sin llamadas recientes';

  @override
  String get callsEmptySubtitle => 'Tu historial de llamadas aparecerá aquí';

  @override
  String get appBarEncrypted => 'cifrado de extremo a extremo';

  @override
  String get newStatus => 'Nuevo estado';

  @override
  String get newCall => 'Nueva llamada';

  @override
  String get joinChannelTitle => 'Unirse al canal';

  @override
  String get joinChannelDescription => 'URL DEL CANAL';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'Obteniendo información del canal…';

  @override
  String get joinChannelNotFound => 'No se encontró canal en esta URL';

  @override
  String get joinChannelNetworkError => 'No se pudo conectar al servidor';

  @override
  String get joinChannelAlreadyJoined => 'Ya unido';

  @override
  String get joinChannelButton => 'Unirse';

  @override
  String get channelFeedEmpty => 'Aún no hay publicaciones';

  @override
  String get channelLeave => 'Salir del canal';

  @override
  String get channelLeaveConfirm =>
      '¿Salir de este canal? Las publicaciones en caché se eliminarán.';

  @override
  String get channelInfo => 'Info del canal';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'editado';

  @override
  String get channelLoadMore => 'Cargar más';

  @override
  String get channelSearchPosts => 'Buscar publicaciones…';

  @override
  String get channelNoResults => 'Sin publicaciones coincidentes';

  @override
  String get channelUrl => 'URL del canal';

  @override
  String get channelCreated => 'Unido';

  @override
  String channelPostCount(int count) {
    return '$count publicaciones';
  }

  @override
  String get channelCopyUrl => 'Copiar URL';

  @override
  String get setupNext => 'Next';

  @override
  String get setupKeyWarning =>
      'A recovery key will be generated for you. It is the only way to restore your account — there is no server, no password reset.';

  @override
  String get setupKeyTitle => 'Your Recovery Key';

  @override
  String get setupKeySubtitle =>
      'Write this key down and store it in a safe place. You will need it to restore your account on a new device.';

  @override
  String get setupKeyCopied => 'Copied!';

  @override
  String get setupKeyWroteItDown => 'I wrote it down';

  @override
  String get setupKeyWarnBody =>
      'This key is NOT stored anywhere. If you lose it, your account cannot be recovered.';

  @override
  String get setupVerifyTitle => 'Verify Recovery Key';

  @override
  String get setupVerifySubtitle =>
      'Re-enter your recovery key to confirm you saved it correctly.';

  @override
  String get setupVerifyButton => 'Verify';

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
  String get setupPinSet => 'Set a PIN';

  @override
  String get setupPinConfirm => 'Confirm PIN';

  @override
  String get setupPinHint =>
      'This PIN unlocks the app. Your recovery key is used only to restore your account.';

  @override
  String get setupPinMismatch => 'PINs do not match. Try again.';

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
  String get lockPinSubtitle => 'Enter your PIN to continue';

  @override
  String get lockWrongPin => 'Wrong PIN';

  @override
  String get settingsChangePin => 'Change PIN';

  @override
  String get settingsChangePinSubtitle => 'Update your app unlock PIN';

  @override
  String get settingsEnterCurrentPin => 'Enter your current PIN to continue';

  @override
  String get settingsPinChanged => 'PIN updated';

  @override
  String get settingsPinEnabled => 'PIN lock enabled';

  @override
  String get settingsRecoveryKeyInfo => 'Recovery Key';

  @override
  String get settingsRecoveryKeyInfoSubtitle =>
      'Your recovery key is not stored — keep your written copy safe';

  @override
  String get replaceIdentityTitle => 'Replace existing identity?';

  @override
  String get replaceIdentityBodyRestore =>
      'An identity already exists on this device. Restoring will permanently replace your current Nostr key and Oxen seed. All contacts will lose the ability to reach your current address.\n\nThis cannot be undone.';

  @override
  String get replaceIdentityBodyCreate =>
      'An identity already exists on this device. Creating a new one will permanently replace your current Nostr key and Oxen seed. All contacts will lose the ability to reach your current address.\n\nThis cannot be undone.';

  @override
  String get replace => 'Replace';

  @override
  String get callNoScreenSources => 'No screen sources available';

  @override
  String get callScreenShareQuality => 'Screen Share Quality';

  @override
  String get callFrameRate => 'Frame rate';

  @override
  String get callResolution => 'Resolution';

  @override
  String get callAutoResolution => 'Auto = native screen resolution';

  @override
  String get callStartSharing => 'Start sharing';

  @override
  String get callCameraUnavailable =>
      'Camera unavailable — may be in use by another app';

  @override
  String get themeResetToDefaults => 'Reset to defaults';

  @override
  String get backupSaveToDownloadsTitle => 'Save backup to Downloads?';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'No file picker available. The backup will be saved to:\n$path';
  }

  @override
  String get systemLabel => 'System';

  @override
  String get next => 'Next';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return '$remaining more taps to enable developer mode';
  }

  @override
  String get devModeEnabled => 'Developer mode enabled';

  @override
  String get devTools => 'Developer Tools';

  @override
  String get devAdapterDiagnostics => 'Adapter toggles & diagnostics';

  @override
  String get devEnableAll => 'Enable all';

  @override
  String get devDisableAll => 'Disable all';

  @override
  String get turnUrlValidation =>
      'TURN URL must start with turn: or turns: (max 512 chars)';

  @override
  String get callMissedCall => 'Missed call';

  @override
  String get callOutgoingCall => 'Outgoing call';

  @override
  String get callIncomingCall => 'Incoming call';

  @override
  String get mediaMissingData => 'Missing media data';

  @override
  String get mediaDownloadFailed => 'Download failed';

  @override
  String get mediaDecryptFailed => 'Decrypt failed';

  @override
  String get callEndCallBanner => 'End call';

  @override
  String get meFallback => 'Me';

  @override
  String get imageSaveToDownloads => 'Save to Downloads';

  @override
  String imageSavedToPath(String path) {
    return 'Saved to $path';
  }

  @override
  String get callScreenShareRequiresPermission =>
      'Screen sharing requires permission';

  @override
  String get callScreenShareUnavailable => 'Screen sharing unavailable';

  @override
  String get statusJustNow => 'Just now';

  @override
  String statusMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String statusHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count routes',
      one: '1 route',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => 'Ready to add';

  @override
  String groupSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get paste => 'Paste';

  @override
  String get sfuAudioOnly => 'Audio only';

  @override
  String sfuParticipants(int count) {
    return '$count participants';
  }

  @override
  String get dataUnencryptedBackup => 'Unencrypted backup';

  @override
  String get dataUnencryptedBackupBody =>
      'This file is an unencrypted identity backup and will overwrite your current keys. Only import files you created yourself. Proceed?';

  @override
  String get dataImportAnyway => 'Import anyway';

  @override
  String get securityStorageError => 'Security storage error — restart the app';

  @override
  String get aboutDevModeActive => 'Developer mode active';

  @override
  String get themeColors => 'Colors';

  @override
  String get themePrimaryAccent => 'Primary accent';

  @override
  String get themeSecondaryAccent => 'Secondary accent';

  @override
  String get themeBackground => 'Background';

  @override
  String get themeSurface => 'Surface';

  @override
  String get themeChatBubbles => 'Chat Bubbles';

  @override
  String get themeOutgoingMessage => 'Outgoing message';

  @override
  String get themeIncomingMessage => 'Incoming message';

  @override
  String get themeShape => 'Shape';

  @override
  String get devSectionDeveloper => 'Developer';

  @override
  String get devAdapterChannelsHint =>
      'Adapter channels — disable to test specific transports.';

  @override
  String get devNostrRelays => 'Nostr relays (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Session Network';

  @override
  String get devPulseRelay => 'Pulse self-hosted relay';

  @override
  String get devLanNetwork => 'Local network (UDP/TCP)';

  @override
  String get devSectionCalls => 'Calls';

  @override
  String get devForceTurnRelay => 'Force TURN relay';

  @override
  String get devForceTurnRelaySubtitle =>
      'Disable P2P — all calls via TURN servers only';

  @override
  String get devRestartWarning =>
      '⚠ Changes take effect on next send/call. Restart app to apply to incoming.';
}
