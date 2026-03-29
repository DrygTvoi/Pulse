// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Buscar mensagens...';

  @override
  String get search => 'Buscar';

  @override
  String get clearSearch => 'Limpar busca';

  @override
  String get closeSearch => 'Fechar busca';

  @override
  String get moreOptions => 'Mais opções';

  @override
  String get back => 'Voltar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Fechar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get remove => 'Remover';

  @override
  String get save => 'Salvar';

  @override
  String get add => 'Adicionar';

  @override
  String get copy => 'Copiar';

  @override
  String get skip => 'Pular';

  @override
  String get done => 'Pronto';

  @override
  String get apply => 'Aplicar';

  @override
  String get export => 'Exportar';

  @override
  String get import => 'Importar';

  @override
  String get homeNewGroup => 'Novo grupo';

  @override
  String get homeSettings => 'Configurações';

  @override
  String get homeSearching => 'Buscando mensagens...';

  @override
  String get homeNoResults => 'Nenhum resultado encontrado';

  @override
  String get homeNoChatHistory => 'Sem histórico de conversas ainda';

  @override
  String homeTransportSwitched(String address) {
    return 'Transporte alterado → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name está ligando...';
  }

  @override
  String get homeAccept => 'Aceitar';

  @override
  String get homeDecline => 'Recusar';

  @override
  String get homeLoadEarlier => 'Carregar mensagens anteriores';

  @override
  String get homeChats => 'Conversas';

  @override
  String get homeSelectConversation => 'Selecione uma conversa';

  @override
  String get homeNoChatsYet => 'Sem conversas ainda';

  @override
  String get homeAddContactToStart =>
      'Adicione um contato para começar a conversar';

  @override
  String get homeNewChat => 'Nova conversa';

  @override
  String get homeNewChatTooltip => 'Nova conversa';

  @override
  String get homeIncomingCallTitle => 'Chamada recebida';

  @override
  String get homeIncomingGroupCallTitle => 'Chamada em grupo recebida';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — chamada em grupo recebida';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Nenhuma conversa corresponde a \"$query\"';
  }

  @override
  String get homeSectionChats => 'Conversas';

  @override
  String get homeSectionMessages => 'Mensagens';

  @override
  String get homeDbEncryptionUnavailable =>
      'Criptografia do banco de dados indisponível — instale o SQLCipher para proteção completa';

  @override
  String get chatFileTooLargeGroup =>
      'Arquivos acima de 512 KB não são suportados em conversas de grupo';

  @override
  String get chatLargeFile => 'Arquivo grande';

  @override
  String get chatCancel => 'Cancelar';

  @override
  String get chatSend => 'Enviar';

  @override
  String get chatFileTooLarge =>
      'Arquivo muito grande — o tamanho máximo é 100 MB';

  @override
  String get chatMicDenied => 'Permissão de microfone negada';

  @override
  String get chatVoiceFailed =>
      'Não foi possível salvar a mensagem de voz — verifique o armazenamento disponível';

  @override
  String get chatScheduleFuture => 'O horário agendado deve ser no futuro';

  @override
  String get chatToday => 'Hoje';

  @override
  String get chatYesterday => 'Ontem';

  @override
  String get chatEdited => 'editado';

  @override
  String get chatYou => 'Você';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Este arquivo tem $size MB. Enviar arquivos grandes pode ser lento em algumas redes. Continuar?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'A chave de segurança de $name mudou. Toque para verificar.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Não foi possível criptografar a mensagem para $name — mensagem não enviada.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'O número de segurança mudou para $name. Toque para verificar.';
  }

  @override
  String get chatNoMessagesFound => 'Nenhuma mensagem encontrada';

  @override
  String get chatMessagesE2ee =>
      'As mensagens são criptografadas de ponta a ponta';

  @override
  String get chatSayHello => 'Diga olá';

  @override
  String get appBarOnline => 'online';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'digitando';

  @override
  String get appBarSearchMessages => 'Buscar mensagens...';

  @override
  String get appBarMute => 'Silenciar';

  @override
  String get appBarUnmute => 'Ativar som';

  @override
  String get appBarMedia => 'Mídia';

  @override
  String get appBarDisappearing => 'Mensagens temporárias';

  @override
  String get appBarDisappearingOn => 'Temporárias: ativadas';

  @override
  String get appBarGroupSettings => 'Configurações do grupo';

  @override
  String get appBarSearchTooltip => 'Buscar mensagens';

  @override
  String get appBarVoiceCall => 'Chamada de voz';

  @override
  String get appBarVideoCall => 'Chamada de vídeo';

  @override
  String get inputMessage => 'Mensagem...';

  @override
  String get inputAttachFile => 'Anexar arquivo';

  @override
  String get inputSendMessage => 'Enviar mensagem';

  @override
  String get inputRecordVoice => 'Gravar mensagem de voz';

  @override
  String get inputSendVoice => 'Enviar mensagem de voz';

  @override
  String get inputCancelReply => 'Cancelar resposta';

  @override
  String get inputCancelEdit => 'Cancelar edição';

  @override
  String get inputCancelRecording => 'Cancelar gravação';

  @override
  String get inputRecording => 'Gravando…';

  @override
  String get inputEditingMessage => 'Editando mensagem';

  @override
  String get inputPhoto => 'Foto';

  @override
  String get inputVoiceMessage => 'Mensagem de voz';

  @override
  String get inputFile => 'Arquivo';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensagens agendadas',
      one: '$count mensagem agendada',
    );
    return '$_temp0';
  }

  @override
  String get callInitializing => 'Iniciando chamada…';

  @override
  String get callConnecting => 'Conectando…';

  @override
  String get callConnectingRelay => 'Conectando (retransmissor)…';

  @override
  String get callSwitchingRelay => 'Alternando para modo retransmissor…';

  @override
  String get callConnectionFailed => 'A conexão falhou';

  @override
  String get callReconnecting => 'Reconectando…';

  @override
  String get callEnded => 'Chamada encerrada';

  @override
  String get callLive => 'Ao vivo';

  @override
  String get callEnd => 'Fim';

  @override
  String get callEndCall => 'Encerrar chamada';

  @override
  String get callMute => 'Silenciar';

  @override
  String get callUnmute => 'Ativar som';

  @override
  String get callSpeaker => 'Alto-falante';

  @override
  String get callCameraOn => 'Câmera ligada';

  @override
  String get callCameraOff => 'Câmera desligada';

  @override
  String get callShareScreen => 'Compartilhar tela';

  @override
  String get callStopShare => 'Parar compartilhamento';

  @override
  String callTorBackup(String duration) {
    return 'Backup Tor · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Backup Tor ativo — caminho principal indisponível';

  @override
  String get callDirectFailed =>
      'Conexão direta falhou — alternando para modo retransmissor…';

  @override
  String get callTurnUnreachable =>
      'Servidores TURN inacessíveis. Adicione um TURN personalizado em Configurações → Avançado.';

  @override
  String get callRelayMode => 'Modo retransmissor ativo (rede restrita)';

  @override
  String get callStarting => 'Iniciando chamada…';

  @override
  String get callConnectingToGroup => 'Conectando ao grupo…';

  @override
  String get callGroupOpenedInBrowser => 'Chamada em grupo aberta no navegador';

  @override
  String get callCouldNotOpenBrowser => 'Não foi possível abrir o navegador';

  @override
  String get callInviteLinkSent =>
      'Link de convite enviado a todos os membros do grupo.';

  @override
  String get callOpenLinkManually =>
      'Abra o link acima manualmente ou toque para tentar novamente.';

  @override
  String get callJitsiNotE2ee =>
      'As chamadas Jitsi NÃO são criptografadas de ponta a ponta';

  @override
  String get callRetryOpenBrowser => 'Tentar abrir navegador novamente';

  @override
  String get callClose => 'Fechar';

  @override
  String get callCamOn => 'Câmera on';

  @override
  String get callCamOff => 'Câmera off';

  @override
  String get noConnection => 'Sem conexão — as mensagens ficarão na fila';

  @override
  String get connected => 'Conectado';

  @override
  String get connecting => 'Conectando…';

  @override
  String get disconnected => 'Desconectado';

  @override
  String get offlineBanner =>
      'Sem conexão — as mensagens serão enviadas quando voltar a ficar online';

  @override
  String get lanModeBanner => 'Modo LAN — Sem internet · Apenas rede local';

  @override
  String get probeCheckingNetwork => 'Verificando conectividade de rede…';

  @override
  String get probeDiscoveringRelays =>
      'Descobrindo retransmissores em diretórios comunitários…';

  @override
  String get probeStartingTor => 'Iniciando Tor para bootstrap…';

  @override
  String get probeFindingRelaysTor =>
      'Encontrando retransmissores acessíveis via Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rede pronta — $count relays encontrados',
      one: 'Rede pronta — $count relay encontrado',
    );
    return '$_temp0';
  }

  @override
  String get probeNoRelaysFound =>
      'Nenhum retransmissor acessível encontrado — as mensagens podem atrasar';

  @override
  String get jitsiWarningTitle => 'Sem criptografia de ponta a ponta';

  @override
  String get jitsiWarningBody =>
      'As chamadas do Jitsi Meet não são criptografadas pelo Pulse. Use apenas para conversas não sensíveis.';

  @override
  String get jitsiConfirm => 'Entrar mesmo assim';

  @override
  String get jitsiGroupWarningTitle => 'Sem criptografia de ponta a ponta';

  @override
  String get jitsiGroupWarningBody =>
      'Esta chamada tem participantes demais para a malha criptografada integrada.\n\nUm link do Jitsi Meet será aberto no seu navegador. O Jitsi NÃO tem criptografia de ponta a ponta — o servidor pode ver sua chamada.';

  @override
  String get jitsiContinueAnyway => 'Continuar mesmo assim';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get setupCreateAnonymousAccount => 'Criar uma conta anônima';

  @override
  String get setupTapToChangeColor => 'Toque para mudar a cor';

  @override
  String get setupReqMinLength => 'At least 16 characters';

  @override
  String get setupReqVariety => '3 of 4: uppercase, lowercase, digits, symbols';

  @override
  String get setupReqMatch => 'Passwords match';

  @override
  String get setupYourNickname => 'Seu apelido';

  @override
  String get setupRecoveryPassword => 'Senha de recuperação (mín. 16)';

  @override
  String get setupConfirmPassword => 'Confirmar senha';

  @override
  String get setupMin16Chars => 'Mínimo de 16 caracteres';

  @override
  String get setupPasswordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get setupEntropyWeak => 'Fraca';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Forte';

  @override
  String get setupEntropyWeakNeedsVariety =>
      'Fraca (precisa de 3 tipos de caracteres)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bits)';
  }

  @override
  String get setupPasswordWarning =>
      'Esta senha é a única forma de restaurar sua conta. Não há servidor — sem recuperação de senha. Lembre-se dela ou anote.';

  @override
  String get setupCreateAccount => 'Criar conta';

  @override
  String get setupAlreadyHaveAccount => 'Já tem uma conta? ';

  @override
  String get setupRestore => 'Restaurar →';

  @override
  String get restoreTitle => 'Restaurar conta';

  @override
  String get restoreInfoBanner =>
      'Digite sua senha de recuperação — seu endereço (Nostr + Session) será restaurado automaticamente. Contatos e mensagens foram armazenados apenas localmente.';

  @override
  String get restoreNewNickname => 'Novo apelido (pode mudar depois)';

  @override
  String get restoreButton => 'Restaurar conta';

  @override
  String get lockTitle => 'Pulse está bloqueado';

  @override
  String get lockSubtitle => 'Digite sua senha para continuar';

  @override
  String get lockPasswordHint => 'Senha';

  @override
  String get lockUnlock => 'Desbloquear';

  @override
  String get lockPanicHint =>
      'Esqueceu sua senha? Digite sua chave de pânico para apagar todos os dados.';

  @override
  String get lockTooManyAttempts =>
      'Muitas tentativas. Apagando todos os dados…';

  @override
  String get lockWrongPassword => 'Senha incorreta';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Senha incorreta — $attempts/$max tentativas';
  }

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get onboardingNext => 'Próximo';

  @override
  String get onboardingGetStarted => 'Começar';

  @override
  String get onboardingWelcomeTitle => 'Bem-vindo ao Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Um mensageiro descentralizado com criptografia de ponta a ponta.\n\nSem servidores centrais. Sem coleta de dados. Sem portas dos fundos.\nSuas conversas pertencem apenas a você.';

  @override
  String get onboardingTransportTitle => 'Independente de transporte';

  @override
  String get onboardingTransportBody =>
      'Use Firebase, Nostr ou ambos ao mesmo tempo.\n\nAs mensagens são roteadas entre redes automaticamente. Suporte integrado a Tor e I2P para resistência à censura.';

  @override
  String get onboardingSignalTitle => 'Signal + Pós-Quântico';

  @override
  String get onboardingSignalBody =>
      'Cada mensagem é criptografada com o Protocolo Signal (Double Ratchet + X3DH) para sigilo perfeito.\n\nAlém disso, é envolvida com Kyber-1024 — um algoritmo pós-quântico padrão do NIST — protegendo contra futuros computadores quânticos.';

  @override
  String get onboardingKeysTitle => 'Você controla suas chaves';

  @override
  String get onboardingKeysBody =>
      'Suas chaves de identidade nunca saem do seu dispositivo.\n\nAs impressões digitais do Signal permitem verificar contatos fora de banda. TOFU (Confiança no Primeiro Uso) detecta mudanças de chaves automaticamente.';

  @override
  String get onboardingThemeTitle => 'Escolha seu visual';

  @override
  String get onboardingThemeBody =>
      'Escolha um tema e cor de destaque. Você sempre pode mudar depois em Configurações.';

  @override
  String get contactsNewChat => 'Nova conversa';

  @override
  String get contactsAddContact => 'Adicionar contato';

  @override
  String get contactsSearchHint => 'Buscar...';

  @override
  String get contactsNewGroup => 'Novo grupo';

  @override
  String get contactsNoContactsYet => 'Sem contatos ainda';

  @override
  String get contactsAddHint =>
      'Toque em + para adicionar o endereço de alguém';

  @override
  String get contactsNoMatch => 'Nenhum contato corresponde';

  @override
  String get contactsRemoveTitle => 'Remover contato';

  @override
  String contactsRemoveMessage(String name) {
    return 'Remover $name?';
  }

  @override
  String get contactsRemove => 'Remover';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contatos',
      one: '$count contato',
    );
    return '$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Abrir link';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Abrir esta URL no seu navegador?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Abrir';

  @override
  String get bubbleSecurityWarning => 'Aviso de segurança';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" é um tipo de arquivo executável. Salvar e executá-lo pode danificar seu dispositivo. Salvar mesmo assim?';
  }

  @override
  String get bubbleSaveAnyway => 'Salvar mesmo assim';

  @override
  String bubbleSavedTo(String path) {
    return 'Salvo em $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Falha ao salvar: $error';
  }

  @override
  String get bubbleNotEncrypted => 'SEM CRIPTOGRAFIA';

  @override
  String get bubbleCorruptedImage => '[Imagem corrompida]';

  @override
  String get bubbleReplyPhoto => 'Foto';

  @override
  String get bubbleReplyVoice => 'Mensagem de voz';

  @override
  String get bubbleReplyVideo => 'Mensagem de vídeo';

  @override
  String bubbleReadBy(String names) {
    return 'Lido por $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Lido por $count';
  }

  @override
  String get chatTileTapToStart => 'Toque para começar a conversar';

  @override
  String get chatTileMessageSent => 'Mensagem enviada';

  @override
  String get chatTileEncryptedMessage => 'Mensagem criptografada';

  @override
  String chatTileYouPrefix(String text) {
    return 'Você: $text';
  }

  @override
  String get bannerEncryptedMessage => 'Mensagem criptografada';

  @override
  String get groupNewGroup => 'Novo grupo';

  @override
  String get groupGroupName => 'Nome do grupo';

  @override
  String get groupSelectMembers => 'Selecionar membros (mín. 2)';

  @override
  String get groupNoContactsYet =>
      'Sem contatos ainda. Adicione contatos primeiro.';

  @override
  String get groupCreate => 'Criar';

  @override
  String get groupLabel => 'Grupo';

  @override
  String get profileVerifyIdentity => 'Verificar identidade';

  @override
  String profileVerifyInstructions(String name) {
    return 'Compare estas impressões digitais com $name em uma chamada de voz ou pessoalmente. Se ambos os valores coincidirem em ambos os dispositivos, toque em \"Marcar como verificado\".';
  }

  @override
  String get profileTheirKey => 'Chave dele(a)';

  @override
  String get profileYourKey => 'Sua chave';

  @override
  String get profileRemoveVerification => 'Remover verificação';

  @override
  String get profileMarkAsVerified => 'Marcar como verificado';

  @override
  String get profileAddressCopied => 'Endereço copiado';

  @override
  String get profileNoContactsToAdd =>
      'Sem contatos para adicionar — todos já são membros';

  @override
  String get profileAddMembers => 'Adicionar membros';

  @override
  String profileAddCount(int count) {
    return 'Adicionar ($count)';
  }

  @override
  String get profileRenameGroup => 'Renomear grupo';

  @override
  String get profileRename => 'Renomear';

  @override
  String get profileRemoveMember => 'Remover membro?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Remover $name deste grupo?';
  }

  @override
  String get profileKick => 'Expulsar';

  @override
  String get profileSignalFingerprints => 'Impressões digitais do Signal';

  @override
  String get profileVerified => 'VERIFICADO';

  @override
  String get profileVerify => 'Verificar';

  @override
  String get profileEdit => 'Editar';

  @override
  String get profileNoSession =>
      'Nenhuma sessão estabelecida ainda — envie uma mensagem primeiro.';

  @override
  String get profileFingerprintCopied => 'Impressão digital copiada';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros',
      one: '$count membro',
    );
    return '$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Verificar número de segurança';

  @override
  String get profileShowContactQr => 'Mostrar QR do contato';

  @override
  String profileContactAddress(String name) {
    return 'Endereço de $name';
  }

  @override
  String get profileExportChatHistory => 'Exportar histórico de conversas';

  @override
  String profileSavedTo(String path) {
    return 'Salvo em $path';
  }

  @override
  String get profileExportFailed => 'A exportação falhou';

  @override
  String get profileClearChatHistory => 'Limpar histórico de conversas';

  @override
  String get profileDeleteGroup => 'Excluir grupo';

  @override
  String get profileDeleteContact => 'Excluir contato';

  @override
  String get profileLeaveGroup => 'Sair do grupo';

  @override
  String get profileLeaveGroupBody =>
      'Você será removido deste grupo e ele será excluído dos seus contatos.';

  @override
  String get groupInviteTitle => 'Convite para grupo';

  @override
  String groupInviteBody(String from, String group) {
    return '$from convidou você para participar de \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Aceitar';

  @override
  String get groupInviteDecline => 'Recusar';

  @override
  String get groupMemberLimitTitle => 'Participantes demais';

  @override
  String groupMemberLimitBody(int count) {
    return 'Este grupo terá $count participantes. Chamadas criptografadas em malha suportam até 6. Grupos maiores recorrem ao Jitsi (sem E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Adicionar mesmo assim';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name recusou participar de \"$group\"';
  }

  @override
  String get transferTitle => 'Transferir para outro dispositivo';

  @override
  String get transferInfoBox =>
      'Mova sua identidade Signal e chaves Nostr para um novo dispositivo.\nAs sessões de conversa NÃO são transferidas — o sigilo perfeito é preservado.';

  @override
  String get transferSendFromThis => 'Enviar deste dispositivo';

  @override
  String get transferSendSubtitle =>
      'Este dispositivo tem as chaves. Compartilhe um código com o novo dispositivo.';

  @override
  String get transferReceiveOnThis => 'Receber neste dispositivo';

  @override
  String get transferReceiveSubtitle =>
      'Este é o novo dispositivo. Digite o código do dispositivo antigo.';

  @override
  String get transferChooseMethod => 'Escolher método de transferência';

  @override
  String get transferLan => 'LAN (mesma rede)';

  @override
  String get transferLanSubtitle =>
      'Rápido e direto. Ambos os dispositivos devem estar na mesma Wi-Fi.';

  @override
  String get transferNostrRelay => 'Retransmissor Nostr';

  @override
  String get transferNostrRelaySubtitle =>
      'Funciona em qualquer rede usando um retransmissor Nostr existente.';

  @override
  String get transferRelayUrl => 'URL do retransmissor';

  @override
  String get transferEnterCode => 'Digitar código de transferência';

  @override
  String get transferPasteCode => 'Cole o código LAN:... ou NOS:... aqui';

  @override
  String get transferConnect => 'Conectar';

  @override
  String get transferGenerating => 'Gerando código de transferência…';

  @override
  String get transferShareCode => 'Compartilhe este código com o receptor:';

  @override
  String get transferCopyCode => 'Copiar código';

  @override
  String get transferCodeCopied =>
      'Código copiado para a área de transferência';

  @override
  String get transferWaitingReceiver => 'Aguardando o receptor conectar…';

  @override
  String get transferConnectingSender => 'Conectando ao emissor…';

  @override
  String get transferVerifyBoth =>
      'Compare este código em ambos os dispositivos.\nSe coincidirem, a transferência é segura.';

  @override
  String get transferComplete => 'Transferência concluída';

  @override
  String get transferKeysImported => 'Chaves importadas';

  @override
  String get transferCompleteSenderBody =>
      'Suas chaves permanecem ativas neste dispositivo.\nO receptor agora pode usar sua identidade.';

  @override
  String get transferCompleteReceiverBody =>
      'Chaves importadas com sucesso.\nReinicie o app para aplicar a nova identidade.';

  @override
  String get transferRestartApp => 'Reiniciar app';

  @override
  String get transferFailed => 'A transferência falhou';

  @override
  String get transferTryAgain => 'Tentar novamente';

  @override
  String get transferEnterRelayFirst =>
      'Digite uma URL de retransmissor primeiro';

  @override
  String get transferPasteCodeFromSender =>
      'Cole o código de transferência do emissor';

  @override
  String get menuReply => 'Responder';

  @override
  String get menuForward => 'Encaminhar';

  @override
  String get menuReact => 'Reagir';

  @override
  String get menuCopy => 'Copiar';

  @override
  String get menuEdit => 'Editar';

  @override
  String get menuRetry => 'Tentar novamente';

  @override
  String get menuCancelScheduled => 'Cancelar agendado';

  @override
  String get menuDelete => 'Excluir';

  @override
  String get menuForwardTo => 'Encaminhar para…';

  @override
  String menuForwardedTo(String name) {
    return 'Encaminhado para $name';
  }

  @override
  String get menuScheduledMessages => 'Mensagens agendadas';

  @override
  String get menuNoScheduledMessages => 'Sem mensagens agendadas';

  @override
  String menuSendsOn(String date) {
    return 'Envio em $date';
  }

  @override
  String get menuDisappearingMessages => 'Mensagens temporárias';

  @override
  String get menuDisappearingSubtitle =>
      'As mensagens são excluídas automaticamente após o tempo selecionado.';

  @override
  String get menuTtlOff => 'Desativado';

  @override
  String get menuTtl1h => '1 hora';

  @override
  String get menuTtl24h => '24 horas';

  @override
  String get menuTtl7d => '7 dias';

  @override
  String get menuAttachPhoto => 'Foto';

  @override
  String get menuAttachFile => 'Arquivo';

  @override
  String get menuAttachVideo => 'Vídeo';

  @override
  String get mediaTitle => 'Mídia';

  @override
  String get mediaFileLabel => 'ARQUIVO';

  @override
  String mediaPhotosTab(int count) {
    return 'Fotos ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Arquivos ($count)';
  }

  @override
  String get mediaNoPhotos => 'Sem fotos ainda';

  @override
  String get mediaNoFiles => 'Sem arquivos ainda';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Salvo em Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'Falha ao salvar o arquivo';

  @override
  String get statusNewStatus => 'Novo status';

  @override
  String get statusPublish => 'Publicar';

  @override
  String get statusExpiresIn24h => 'O status expira em 24 horas';

  @override
  String get statusWhatsOnYourMind => 'No que você está pensando?';

  @override
  String get statusPhotoAttached => 'Foto anexada';

  @override
  String get statusAttachPhoto => 'Anexar foto (opcional)';

  @override
  String get statusEnterText => 'Por favor, escreva algo para o seu status.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Falha ao selecionar foto: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Falha ao publicar: $error';
  }

  @override
  String get panicSetPanicKey => 'Definir chave de pânico';

  @override
  String get panicEmergencySelfDestruct => 'Autodestruição de emergência';

  @override
  String get panicIrreversible => 'Esta ação é irreversível';

  @override
  String get panicWarningBody =>
      'Digitar esta chave na tela de bloqueio apaga instantaneamente TODOS os dados — mensagens, contatos, chaves, identidade. Use uma chave diferente da sua senha normal.';

  @override
  String get panicKeyHint => 'Chave de pânico';

  @override
  String get panicConfirmHint => 'Confirmar chave de pânico';

  @override
  String get panicMinChars =>
      'A chave de pânico deve ter pelo menos 8 caracteres';

  @override
  String get panicKeysDoNotMatch => 'As chaves não coincidem';

  @override
  String get panicSetFailed =>
      'Falha ao salvar a chave de pânico — tente novamente';

  @override
  String get passwordSetAppPassword => 'Definir senha do app';

  @override
  String get passwordProtectsMessages => 'Protege suas mensagens em repouso';

  @override
  String get passwordInfoBanner =>
      'Necessária toda vez que você abrir o Pulse. Se esquecê-la, seus dados não poderão ser recuperados.';

  @override
  String get passwordHint => 'Senha';

  @override
  String get passwordConfirmHint => 'Confirmar senha';

  @override
  String get passwordSetButton => 'Definir senha';

  @override
  String get passwordSkipForNow => 'Pular por enquanto';

  @override
  String get passwordMinChars => 'A senha deve ter pelo menos 6 caracteres';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get profileCardSaved => 'Perfil salvo!';

  @override
  String get profileCardE2eeIdentity => 'Identidade E2EE';

  @override
  String get profileCardDisplayName => 'Nome de exibição';

  @override
  String get profileCardDisplayNameHint => 'ex. João Silva';

  @override
  String get profileCardAbout => 'Sobre';

  @override
  String get profileCardSaveProfile => 'Salvar perfil';

  @override
  String get profileCardYourName => 'Seu nome';

  @override
  String get profileCardAddressCopied => 'Endereço copiado!';

  @override
  String get profileCardInboxAddress => 'Seu endereço de caixa de entrada';

  @override
  String get profileCardInboxAddresses => 'Seus endereços de caixa de entrada';

  @override
  String get profileCardShareAllAddresses =>
      'Compartilhar todos os endereços (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Compartilhe com contatos para que possam te enviar mensagens.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Todos os $count endereços copiados como um único link!';
  }

  @override
  String get settingsMyProfile => 'Meu perfil';

  @override
  String get settingsYourInboxAddress => 'Seu endereço de caixa de entrada';

  @override
  String get settingsMyQrCode => 'Meu código QR';

  @override
  String get settingsMyQrSubtitle =>
      'Compartilhe seu endereço como um QR escaneável';

  @override
  String get settingsShareMyAddress => 'Compartilhar meu endereço';

  @override
  String get settingsNoAddressYet =>
      'Sem endereço ainda — salve as configurações primeiro';

  @override
  String get settingsInviteLink => 'Link de convite';

  @override
  String get settingsRawAddress => 'Endereço bruto';

  @override
  String get settingsCopyLink => 'Copiar link';

  @override
  String get settingsCopyAddress => 'Copiar endereço';

  @override
  String get settingsInviteLinkCopied => 'Link de convite copiado';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsThemeEngine => 'Motor de temas';

  @override
  String get settingsThemeEngineSubtitle => 'Personalizar cores e fontes';

  @override
  String get settingsSignalProtocol => 'Protocolo Signal';

  @override
  String get settingsSignalProtocolSubtitle =>
      'As chaves E2EE são armazenadas com segurança';

  @override
  String get settingsActive => 'ATIVO';

  @override
  String get settingsIdentityBackup => 'Backup de identidade';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Exportar ou importar sua identidade Signal';

  @override
  String get settingsIdentityBackupBody =>
      'Exporte suas chaves de identidade Signal para um código de backup, ou restaure a partir de um existente.';

  @override
  String get settingsTransferDevice => 'Transferir para outro dispositivo';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Mover sua identidade via LAN ou retransmissor Nostr';

  @override
  String get settingsExportIdentity => 'Exportar identidade';

  @override
  String get settingsExportIdentityBody =>
      'Copie este código de backup e guarde-o com segurança:';

  @override
  String get settingsSaveFile => 'Salvar arquivo';

  @override
  String get settingsImportIdentity => 'Importar identidade';

  @override
  String get settingsImportIdentityBody =>
      'Cole seu código de backup abaixo. Isso sobrescreverá sua identidade atual.';

  @override
  String get settingsPasteBackupCode => 'Cole o código de backup aqui…';

  @override
  String get settingsIdentityImported =>
      'Identidade + contatos importados! Reinicie o app para aplicar.';

  @override
  String get settingsSecurity => 'Segurança';

  @override
  String get settingsAppPassword => 'Senha do app';

  @override
  String get settingsPasswordEnabled => 'Ativada — necessária a cada início';

  @override
  String get settingsPasswordDisabled => 'Desativada — o app abre sem senha';

  @override
  String get settingsChangePassword => 'Alterar senha';

  @override
  String get settingsChangePasswordSubtitle =>
      'Atualizar a senha de bloqueio do app';

  @override
  String get settingsSetPanicKey => 'Definir chave de pânico';

  @override
  String get settingsChangePanicKey => 'Alterar chave de pânico';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Atualizar chave de limpeza de emergência';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Uma chave que apaga todos os dados instantaneamente';

  @override
  String get settingsRemovePanicKey => 'Remover chave de pânico';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Desativar autodestruição de emergência';

  @override
  String get settingsRemovePanicKeyBody =>
      'A autodestruição de emergência será desativada. Você pode reativá-la a qualquer momento.';

  @override
  String get settingsDisableAppPassword => 'Desativar senha do app';

  @override
  String get settingsEnterCurrentPassword =>
      'Digite sua senha atual para confirmar';

  @override
  String get settingsCurrentPassword => 'Senha atual';

  @override
  String get settingsIncorrectPassword => 'Senha incorreta';

  @override
  String get settingsPasswordUpdated => 'Senha atualizada';

  @override
  String get settingsChangePasswordProceed =>
      'Digite sua senha atual para prosseguir';

  @override
  String get settingsData => 'Dados';

  @override
  String get settingsBackupMessages => 'Backup de mensagens';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Exportar histórico criptografado de mensagens para um arquivo';

  @override
  String get settingsRestoreMessages => 'Restaurar mensagens';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Importar mensagens de um arquivo de backup';

  @override
  String get settingsExportKeys => 'Exportar chaves';

  @override
  String get settingsExportKeysSubtitle =>
      'Salvar chaves de identidade em um arquivo criptografado';

  @override
  String get settingsImportKeys => 'Importar chaves';

  @override
  String get settingsImportKeysSubtitle =>
      'Restaurar chaves de identidade de um arquivo exportado';

  @override
  String get settingsBackupPassword => 'Senha de backup';

  @override
  String get settingsPasswordCannotBeEmpty => 'A senha não pode estar vazia';

  @override
  String get settingsPasswordMin4Chars =>
      'A senha deve ter pelo menos 4 caracteres';

  @override
  String get settingsCallsTurn => 'Chamadas e TURN';

  @override
  String get settingsLocalNetwork => 'Rede local';

  @override
  String get settingsCensorshipResistance => 'Resistência à censura';

  @override
  String get settingsNetwork => 'Rede';

  @override
  String get settingsProxyTunnels => 'Proxy e túneis';

  @override
  String get settingsTurnServers => 'Servidores TURN';

  @override
  String get settingsProviderTitle => 'Provedor';

  @override
  String get settingsLanFallback => 'Fallback LAN';

  @override
  String get settingsLanFallbackSubtitle =>
      'Transmitir presença e entregar mensagens na rede local quando não há internet. Desative em redes não confiáveis (Wi-Fi público).';

  @override
  String get settingsBgDelivery => 'Entrega em segundo plano';

  @override
  String get settingsBgDeliverySubtitle =>
      'Continuar recebendo mensagens quando o app está minimizado. Mostra uma notificação persistente.';

  @override
  String get settingsYourInboxProvider => 'Seu provedor de caixa de entrada';

  @override
  String get settingsConnectionDetails => 'Detalhes da conexão';

  @override
  String get settingsSaveAndConnect => 'Salvar e conectar';

  @override
  String get settingsSecondaryInboxes => 'Caixas de entrada secundárias';

  @override
  String get settingsAddSecondaryInbox =>
      'Adicionar caixa de entrada secundária';

  @override
  String get settingsAdvanced => 'Avançado';

  @override
  String get settingsDiscover => 'Descobrir';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidade';

  @override
  String get settingsPrivacyPolicySubtitle => 'Como o Pulse protege seus dados';

  @override
  String get settingsCrashReporting => 'Relatórios de falhas';

  @override
  String get settingsCrashReportingSubtitle =>
      'Enviar relatórios de falhas anônimos para ajudar a melhorar o Pulse. Nenhum conteúdo de mensagens ou contatos é enviado.';

  @override
  String get settingsCrashReportingEnabled =>
      'Relatórios de falhas ativados — reinicie o app para aplicar';

  @override
  String get settingsCrashReportingDisabled =>
      'Relatórios de falhas desativados — reinicie o app para aplicar';

  @override
  String get settingsSensitiveOperation => 'Operação sensível';

  @override
  String get settingsSensitiveOperationBody =>
      'Estas chaves são sua identidade. Qualquer pessoa com este arquivo pode se passar por você. Guarde-o com segurança e exclua-o após a transferência.';

  @override
  String get settingsIUnderstandContinue => 'Entendo, continuar';

  @override
  String get settingsReplaceIdentity => 'Substituir identidade?';

  @override
  String get settingsReplaceIdentityBody =>
      'Isso sobrescreverá suas chaves de identidade atuais. Suas sessões Signal existentes serão invalidadas e os contatos precisarão restabelecer a criptografia. O app precisará ser reiniciado.';

  @override
  String get settingsReplaceKeys => 'Substituir chaves';

  @override
  String get settingsKeysImported => 'Chaves importadas';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count chaves importadas com sucesso. Reinicie o app para reinicializar com a nova identidade.';
  }

  @override
  String get settingsRestartNow => 'Reiniciar agora';

  @override
  String get settingsLater => 'Mais tarde';

  @override
  String get profileGroupLabel => 'Grupo';

  @override
  String get profileAddButton => 'Adicionar';

  @override
  String get profileKickButton => 'Expulsar';

  @override
  String get dataSectionTitle => 'Dados';

  @override
  String get dataBackupMessages => 'Backup de mensagens';

  @override
  String get dataBackupPasswordSubtitle =>
      'Escolha uma senha para criptografar o backup de mensagens.';

  @override
  String get dataBackupConfirmLabel => 'Criar backup';

  @override
  String get dataCreatingBackup => 'Criando backup';

  @override
  String get dataBackupPreparing => 'Preparando...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Exportando mensagem $done de $total...';
  }

  @override
  String get dataBackupSavingFile => 'Salvando arquivo...';

  @override
  String get dataSaveMessageBackupDialog => 'Salvar backup de mensagens';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Backup salvo ($count mensagens)\n$path';
  }

  @override
  String get dataBackupFailed => 'O backup falhou — nenhum dado exportado';

  @override
  String dataBackupFailedError(String error) {
    return 'O backup falhou: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Selecionar backup de mensagens';

  @override
  String get dataInvalidBackupFile =>
      'Arquivo de backup inválido (muito pequeno)';

  @override
  String get dataNotValidBackupFile =>
      'Não é um arquivo de backup válido do Pulse';

  @override
  String get dataRestoreMessages => 'Restaurar mensagens';

  @override
  String get dataRestorePasswordSubtitle =>
      'Digite a senha usada para criar este backup.';

  @override
  String get dataRestoreConfirmLabel => 'Restaurar';

  @override
  String get dataRestoringMessages => 'Restaurando mensagens';

  @override
  String get dataRestoreDecrypting => 'Descriptografando...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Importando mensagem $done de $total...';
  }

  @override
  String get dataRestoreFailed =>
      'A restauração falhou — senha incorreta ou arquivo corrompido';

  @override
  String dataRestoreSuccess(int count) {
    return '$count novas mensagens restauradas';
  }

  @override
  String get dataRestoreNothingNew =>
      'Sem novas mensagens para importar (todas já existem)';

  @override
  String dataRestoreFailedError(String error) {
    return 'A restauração falhou: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Selecionar exportação de chaves';

  @override
  String get dataNotValidKeyFile =>
      'Não é um arquivo válido de exportação de chaves do Pulse';

  @override
  String get dataExportKeys => 'Exportar chaves';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Escolha uma senha para criptografar a exportação de chaves.';

  @override
  String get dataExportKeysConfirmLabel => 'Exportar';

  @override
  String get dataExportingKeys => 'Exportando chaves';

  @override
  String get dataExportingKeysStatus =>
      'Criptografando chaves de identidade...';

  @override
  String get dataSaveKeyExportDialog => 'Salvar exportação de chaves';

  @override
  String dataKeysExportedTo(String path) {
    return 'Chaves exportadas para:\n$path';
  }

  @override
  String get dataExportFailed =>
      'A exportação falhou — nenhuma chave encontrada';

  @override
  String dataExportFailedError(String error) {
    return 'A exportação falhou: $error';
  }

  @override
  String get dataImportKeys => 'Importar chaves';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Digite a senha usada para criptografar esta exportação de chaves.';

  @override
  String get dataImportKeysConfirmLabel => 'Importar';

  @override
  String get dataImportingKeys => 'Importando chaves';

  @override
  String get dataImportingKeysStatus =>
      'Descriptografando chaves de identidade...';

  @override
  String get dataImportFailed =>
      'A importação falhou — senha incorreta ou arquivo corrompido';

  @override
  String dataImportFailedError(String error) {
    return 'A importação falhou: $error';
  }

  @override
  String get securitySectionTitle => 'Segurança';

  @override
  String get securityIncorrectPassword => 'Senha incorreta';

  @override
  String get securityPasswordUpdated => 'Senha atualizada';

  @override
  String get appearanceSectionTitle => 'Aparência';

  @override
  String appearanceExportFailed(String error) {
    return 'A exportação falhou: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Salvo em $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Falha ao salvar: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'A importação falhou: $error';
  }

  @override
  String get aboutSectionTitle => 'Sobre';

  @override
  String get providerPublicKey => 'Chave pública';

  @override
  String get providerRelay => 'Retransmissor';

  @override
  String get providerAutoConfigured =>
      'Autoconfigurado a partir da sua senha de recuperação. Retransmissor descoberto automaticamente.';

  @override
  String get providerKeyStoredLocally =>
      'Sua chave é armazenada localmente em armazenamento seguro — nunca enviada a nenhum servidor.';

  @override
  String get providerOxenInfo =>
      'Rede Oxen/Session — E2EE roteado por cebola. Seu ID de Session é gerado automaticamente e armazenado com segurança. Os nós são descobertos automaticamente a partir dos nós semente integrados.';

  @override
  String get providerAdvanced => 'Avançado';

  @override
  String get providerSaveAndConnect => 'Salvar e conectar';

  @override
  String get providerAddSecondaryInbox =>
      'Adicionar caixa de entrada secundária';

  @override
  String get providerSecondaryInboxes => 'Caixas de entrada secundárias';

  @override
  String get providerYourInboxProvider => 'Seu provedor de caixa de entrada';

  @override
  String get providerConnectionDetails => 'Detalhes da conexão';

  @override
  String get addContactTitle => 'Adicionar contato';

  @override
  String get addContactInviteLinkLabel => 'Link de convite ou endereço';

  @override
  String get addContactTapToPaste => 'Toque para colar link de convite';

  @override
  String get addContactPasteTooltip => 'Colar da área de transferência';

  @override
  String get addContactAddressDetected => 'Endereço de contato detectado';

  @override
  String addContactRoutesDetected(int count) {
    return '$count rotas detectadas — SmartRouter escolhe a mais rápida';
  }

  @override
  String get addContactFetchingProfile => 'Buscando perfil…';

  @override
  String addContactProfileFound(String name) {
    return 'Encontrado: $name';
  }

  @override
  String get addContactNoProfileFound => 'Nenhum perfil encontrado';

  @override
  String get addContactDisplayNameLabel => 'Nome de exibição';

  @override
  String get addContactDisplayNameHint => 'Como você quer chamá-lo(a)?';

  @override
  String get addContactAddManually => 'Adicionar endereço manualmente';

  @override
  String get addContactButton => 'Adicionar contato';

  @override
  String get networkDiagnosticsTitle => 'Diagnóstico de rede';

  @override
  String get networkDiagnosticsNostrRelays => 'Retransmissores Nostr';

  @override
  String get networkDiagnosticsDirect => 'Diretos';

  @override
  String get networkDiagnosticsTorOnly => 'Apenas Tor';

  @override
  String get networkDiagnosticsBest => 'Melhor';

  @override
  String get networkDiagnosticsNone => 'nenhum';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Status';

  @override
  String get networkDiagnosticsConnected => 'Conectado';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Conectando $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Desligado';

  @override
  String get networkDiagnosticsTransport => 'Transporte';

  @override
  String get networkDiagnosticsInfrastructure => 'Infraestrutura';

  @override
  String get networkDiagnosticsOxenNodes => 'Nós Oxen';

  @override
  String get networkDiagnosticsTurnServers => 'Servidores TURN';

  @override
  String get networkDiagnosticsLastProbe => 'Última sondagem';

  @override
  String get networkDiagnosticsRunning => 'Executando...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Executar diagnóstico';

  @override
  String get networkDiagnosticsForceReprobe => 'Forçar resondagem completa';

  @override
  String get networkDiagnosticsJustNow => 'agora mesmo';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'há ${minutes}m';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'há ${hours}h';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'há ${days}d';
  }

  @override
  String get homeNoEch => 'Sem ECH';

  @override
  String get homeNoEchTooltip =>
      'Proxy uTLS indisponível — ECH desativado.\nA impressão digital TLS é visível para DPI.';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Salvo e conectado a $provider';
  }

  @override
  String get settingsTorFailedToStart =>
      'O Tor integrado não pôde ser iniciado';

  @override
  String get settingsPsiphonFailedToStart => 'O Psiphon não pôde ser iniciado';

  @override
  String get verifyTitle => 'Verificar número de segurança';

  @override
  String get verifyIdentityVerified => 'Identidade verificada';

  @override
  String get verifyNotYetVerified => 'Ainda não verificado';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Você verificou o número de segurança de $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Compare estes números com $name pessoalmente ou por um canal confiável.';
  }

  @override
  String get verifyExplanation =>
      'Cada conversa tem um número de segurança único. Se ambos virem os mesmos números em seus dispositivos, a conexão está verificada de ponta a ponta.';

  @override
  String verifyContactKey(String name) {
    return 'Chave de $name';
  }

  @override
  String get verifyYourKey => 'Sua chave';

  @override
  String get verifyRemoveVerification => 'Remover verificação';

  @override
  String get verifyMarkAsVerified => 'Marcar como verificado';

  @override
  String verifyAfterReinstall(String name) {
    return 'Se $name reinstalar o app, o número de segurança mudará e a verificação será removida automaticamente.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Só marque como verificado após comparar os números com $name em uma chamada de voz ou pessoalmente.';
  }

  @override
  String get verifyNoSession =>
      'Nenhuma sessão de criptografia estabelecida ainda. Envie uma mensagem primeiro para gerar os números de segurança.';

  @override
  String get verifyNoKeyAvailable => 'Chave não disponível';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Impressão digital de $label copiada';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL do banco de dados';

  @override
  String get providerOptionalHint => 'Opcional';

  @override
  String get providerWebApiKeyLabel => 'Chave API Web';

  @override
  String get providerOptionalForPublicDb => 'Opcional para BD público';

  @override
  String get providerRelayUrlLabel => 'URL do retransmissor';

  @override
  String get providerPrivateKeyLabel => 'Chave privada';

  @override
  String get providerPrivateKeyNsecLabel => 'Chave privada (nsec)';

  @override
  String get providerStorageNodeLabel =>
      'URL do nó de armazenamento (opcional)';

  @override
  String get providerStorageNodeHint =>
      'Deixe vazio para nós semente integrados';

  @override
  String get transferInvalidCodeFormat =>
      'Formato de código não reconhecido — deve começar com LAN: ou NOS:';

  @override
  String get profileCardFingerprintCopied => 'Impressão digital copiada';

  @override
  String get profileCardAboutHint => 'Privacidade em primeiro lugar 🔒';

  @override
  String get profileCardSaveButton => 'Salvar perfil';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Exportar mensagens criptografadas, contatos e avatares para um arquivo';

  @override
  String get callVideo => 'Vídeo';

  @override
  String get callAudio => 'Áudio';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Entregue a $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Entregue a $count';
  }

  @override
  String get groupStatusDialogTitle => 'Info da mensagem';

  @override
  String get groupStatusRead => 'Lido';

  @override
  String get groupStatusDelivered => 'Entregue';

  @override
  String get groupStatusPending => 'Pendente';

  @override
  String get groupStatusNoData => 'Sem informações de entrega ainda';

  @override
  String get profileTransferAdmin => 'Tornar administrador';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Tornar $name o novo administrador?';
  }

  @override
  String get profileTransferAdminBody =>
      'Você perderá os privilégios de administrador. Isso não pode ser desfeito.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name agora é o administrador';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Política de privacidade';

  @override
  String get privacyOverviewHeading => 'Visão geral';

  @override
  String get privacyOverviewBody =>
      'Pulse é um mensageiro sem servidor com criptografia de ponta a ponta. Sua privacidade não é apenas um recurso — é a arquitetura. Não há servidores do Pulse. Nenhuma conta é armazenada em lugar algum. Nenhum dado é coletado, transmitido ou armazenado pelos desenvolvedores.';

  @override
  String get privacyDataCollectionHeading => 'Coleta de dados';

  @override
  String get privacyDataCollectionBody =>
      'Pulse não coleta nenhum dado pessoal. Especificamente:\n\n- Não é necessário e-mail, número de telefone ou nome real\n- Sem análises, rastreamento ou telemetria\n- Sem identificadores de publicidade\n- Sem acesso à lista de contatos\n- Sem backups na nuvem (as mensagens existem apenas no seu dispositivo)\n- Nenhum metadado é enviado a qualquer servidor do Pulse (não há nenhum)';

  @override
  String get privacyEncryptionHeading => 'Criptografia';

  @override
  String get privacyEncryptionBody =>
      'Todas as mensagens são criptografadas usando o Protocolo Signal (Double Ratchet com acordo de chaves X3DH). As chaves de criptografia são geradas e armazenadas exclusivamente no seu dispositivo. Ninguém — incluindo os desenvolvedores — pode ler suas mensagens.';

  @override
  String get privacyNetworkHeading => 'Arquitetura de rede';

  @override
  String get privacyNetworkBody =>
      'Pulse usa adaptadores de transporte federados (retransmissores Nostr, nós de serviço Session/Oxen, Firebase Realtime Database, LAN). Esses transportes carregam apenas texto cifrado. Os operadores de retransmissores podem ver seu endereço IP e volume de tráfego, mas não podem descriptografar o conteúdo das mensagens.\n\nQuando o Tor está ativado, seu endereço IP também fica oculto dos operadores de retransmissores.';

  @override
  String get privacyStunHeading => 'Servidores STUN/TURN';

  @override
  String get privacyStunBody =>
      'As chamadas de voz e vídeo usam WebRTC com criptografia DTLS-SRTP. Os servidores STUN (usados para descobrir seu IP público para conexões ponto a ponto) e servidores TURN (usados para retransmitir mídia quando a conexão direta falha) podem ver seu endereço IP e duração da chamada, mas não podem descriptografar o conteúdo.\n\nVocê pode configurar seu próprio servidor TURN em Configurações para máxima privacidade.';

  @override
  String get privacyCrashHeading => 'Relatórios de falhas';

  @override
  String get privacyCrashBody =>
      'Se os relatórios de falhas do Sentry estiverem ativados (via SENTRY_DSN em tempo de compilação), relatórios anônimos de falhas podem ser enviados. Eles não contêm conteúdo de mensagens, informações de contatos ou dados pessoalmente identificáveis. Os relatórios de falhas podem ser desativados em tempo de compilação omitindo o DSN.';

  @override
  String get privacyPasswordHeading => 'Senha e chaves';

  @override
  String get privacyPasswordBody =>
      'Sua senha de recuperação é usada para derivar chaves criptográficas via Argon2id (KDF com uso intensivo de memória). A senha nunca é transmitida para lugar algum. Se você perder sua senha, sua conta não poderá ser recuperada — não há servidor para redefini-la.';

  @override
  String get privacyFontsHeading => 'Fontes';

  @override
  String get privacyFontsBody =>
      'Pulse inclui todas as fontes localmente. Nenhuma solicitação é feita ao Google Fonts ou a qualquer serviço de fontes externo.';

  @override
  String get privacyThirdPartyHeading => 'Serviços de terceiros';

  @override
  String get privacyThirdPartyBody =>
      'Pulse não se integra com nenhuma rede de publicidade, provedor de análises, plataforma de mídia social ou intermediador de dados. As únicas conexões de rede são com os retransmissores de transporte que você configurar.';

  @override
  String get privacyOpenSourceHeading => 'Código aberto';

  @override
  String get privacyOpenSourceBody =>
      'Pulse é um software de código aberto. Você pode auditar o código-fonte completo para verificar estas alegações de privacidade.';

  @override
  String get privacyContactHeading => 'Contato';

  @override
  String get privacyContactBody =>
      'Para perguntas relacionadas à privacidade, abra uma issue no repositório do projeto.';

  @override
  String get privacyLastUpdated => 'Última atualização: março de 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Falha ao salvar: $error';
  }

  @override
  String get themeEngineTitle => 'Motor de temas';

  @override
  String get torBuiltInTitle => 'Tor integrado';

  @override
  String get torConnectedSubtitle =>
      'Conectado — Nostr roteado via 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Conectando… $pct%';
  }

  @override
  String get torNotRunning =>
      'Não está executando — toque no interruptor para reiniciar';

  @override
  String get torDescription =>
      'Roteia Nostr via Tor (Snowflake para redes censuradas)';

  @override
  String get torNetworkDiagnostics => 'Diagnóstico de rede';

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
  String get torTimeoutLabel => 'Tempo limite: ';

  @override
  String get torInfoDescription =>
      'Quando ativado, as conexões WebSocket do Nostr são roteadas pelo Tor (SOCKS5). O Tor Browser escuta em 127.0.0.1:9150. O daemon tor independente usa a porta 9050. As conexões do Firebase não são afetadas.';

  @override
  String get torRouteNostrTitle => 'Rotear Nostr via Tor';

  @override
  String get torManagedByBuiltin => 'Gerenciado pelo Tor integrado';

  @override
  String get torActiveRouting => 'Ativo — Tráfego Nostr roteado pelo Tor';

  @override
  String get torDisabled => 'Desativado';

  @override
  String get torProxySocks5 => 'Proxy Tor (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Host do proxy';

  @override
  String get torProxyPortLabel => 'Porta';

  @override
  String get torPortInfo =>
      'Tor Browser: porta 9150  •  daemon tor: porta 9050';

  @override
  String get i2pProxySocks5 => 'Proxy I2P (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P usa SOCKS5 na porta 4447 por padrão. Conecte-se a um retransmissor Nostr via outproxy I2P (ex. relay.damus.i2p) para se comunicar com usuários em qualquer transporte. Tor tem prioridade quando ambos estão ativados.';

  @override
  String get i2pRouteNostrTitle => 'Rotear Nostr via I2P';

  @override
  String get i2pActiveRouting => 'Ativo — Tráfego Nostr roteado pelo I2P';

  @override
  String get i2pDisabled => 'Desativado';

  @override
  String get i2pProxyHostLabel => 'Host do proxy';

  @override
  String get i2pProxyPortLabel => 'Porta';

  @override
  String get i2pPortInfo => 'Porta SOCKS5 padrão do roteador I2P: 4447';

  @override
  String get customProxySocks5 => 'Proxy personalizado (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'Retransmissor CF Worker';

  @override
  String get customProxyInfoDescription =>
      'O proxy personalizado roteia o tráfego pelo seu V2Ray/Xray/Shadowsocks. CF Worker atua como um proxy de retransmissor pessoal no Cloudflare CDN — GFW vê *.workers.dev, não o retransmissor real.';

  @override
  String get customSocks5ProxyTitle => 'Proxy SOCKS5 personalizado';

  @override
  String get customProxyActive => 'Ativo — tráfego roteado via SOCKS5';

  @override
  String get customProxyDisabled => 'Desativado';

  @override
  String get customProxyHostLabel => 'Host do proxy';

  @override
  String get customProxyPortLabel => 'Porta';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Domínio do Worker (opcional)';

  @override
  String get customWorkerHelpTitle =>
      'Como implantar um CF Worker relay (grátis)';

  @override
  String get customWorkerScriptCopied => 'Script copiado!';

  @override
  String get customWorkerStep1 =>
      '1. Vá para dash.cloudflare.com → Workers & Pages\n2. Create Worker → cole este script:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → copie o domínio (ex. my-relay.user.workers.dev)\n4. Cole o domínio acima → Salvar\n\nO app conecta automaticamente: wss://domain/?r=relay_url\nGFW vê: conexão com *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Conectado — SOCKS5 em 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Conectando…';

  @override
  String get psiphonNotRunning =>
      'Não está executando — toque no interruptor para reiniciar';

  @override
  String get psiphonDescription =>
      'Túnel rápido (~3s de bootstrap, 2000+ VPS rotativos)';

  @override
  String get turnCommunityServers => 'Servidores TURN da comunidade';

  @override
  String get turnCustomServer => 'Servidor TURN personalizado (BYOD)';

  @override
  String get turnInfoDescription =>
      'Os servidores TURN apenas retransmitem fluxos já criptografados (DTLS-SRTP). Um operador de retransmissor vê seu IP e volume de tráfego, mas não pode descriptografar as chamadas. TURN só é usado quando a conexão P2P direta falha (~15–20% das conexões).';

  @override
  String get turnFreeLabel => 'GRÁTIS';

  @override
  String get turnServerUrlLabel => 'URL do servidor TURN';

  @override
  String get turnServerUrlHint => 'turn:seu-servidor.com:3478 ou turns:...';

  @override
  String get turnUsernameLabel => 'Usuário';

  @override
  String get turnPasswordLabel => 'Senha';

  @override
  String get turnOptionalHint => 'Opcional';

  @override
  String get turnCustomInfo =>
      'Hospede coturn em qualquer VPS de \$5/mês para máximo controle. As credenciais são armazenadas localmente.';

  @override
  String get themePickerAppearance => 'Aparência';

  @override
  String get themePickerAccentColor => 'Cor de destaque';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Escuro';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeDynamicPresets => 'Predefinições';

  @override
  String get themeDynamicPrimaryColor => 'Cor primária';

  @override
  String get themeDynamicBorderRadius => 'Raio da borda';

  @override
  String get themeDynamicFont => 'Fonte';

  @override
  String get themeDynamicAppearance => 'Aparência';

  @override
  String get themeDynamicUiStyle => 'Estilo de UI';

  @override
  String get themeDynamicUiStyleDescription =>
      'Controla a aparência de diálogos, interruptores e indicadores.';

  @override
  String get themeDynamicSharp => 'Angular';

  @override
  String get themeDynamicRound => 'Arredondado';

  @override
  String get themeDynamicModeDark => 'Escuro';

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
      'URL do Firebase inválida. Esperado https://projeto.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'URL do retransmissor inválida. Esperado wss://relay.exemplo.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'URL do servidor Pulse inválida. Esperado https://servidor:porta';

  @override
  String get providerPulseServerUrlLabel => 'URL do servidor';

  @override
  String get providerPulseServerUrlHint => 'https://seu-servidor:8443';

  @override
  String get providerPulseInviteLabel => 'Código de convite';

  @override
  String get providerPulseInviteHint => 'Código de convite (se necessário)';

  @override
  String get providerPulseInfo =>
      'Retransmissor auto-hospedado. Chaves derivadas da sua senha de recuperação.';

  @override
  String get providerScreenTitle => 'Caixas de entrada';

  @override
  String get providerSecondaryInboxesHeader => 'CAIXAS DE ENTRADA SECUNDÁRIAS';

  @override
  String get providerSecondaryInboxesInfo =>
      'As caixas de entrada secundárias recebem mensagens simultaneamente para redundância.';

  @override
  String get providerRemoveTooltip => 'Remover';

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
  String get emojiNoRecent => 'Sem emojis recentes';

  @override
  String get emojiSearchHint => 'Buscar emoji...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Toque para conversar';

  @override
  String get imageViewerSaveToDownloads => 'Salvar em Downloads';

  @override
  String imageViewerSavedTo(String path) {
    return 'Salvo em $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'App display language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get onboardingLanguageTitle => 'Choose your language';

  @override
  String get onboardingLanguageSubtitle =>
      'You can change this later in Settings';
}
