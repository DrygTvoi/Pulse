// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Rechercher des messages...';

  @override
  String get search => 'Rechercher';

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get closeSearch => 'Fermer la recherche';

  @override
  String get moreOptions => 'Plus d\'options';

  @override
  String get back => 'Retour';

  @override
  String get cancel => 'Annuler';

  @override
  String get close => 'Fermer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get remove => 'Supprimer';

  @override
  String get save => 'Enregistrer';

  @override
  String get add => 'Ajouter';

  @override
  String get copy => 'Copier';

  @override
  String get skip => 'Passer';

  @override
  String get done => 'Terminé';

  @override
  String get apply => 'Appliquer';

  @override
  String get export => 'Exporter';

  @override
  String get import => 'Importer';

  @override
  String get homeNewGroup => 'Nouveau groupe';

  @override
  String get homeSettings => 'Paramètres';

  @override
  String get homeSearching => 'Recherche de messages...';

  @override
  String get homeNoResults => 'Aucun résultat';

  @override
  String get homeNoChatHistory => 'Aucun historique de discussion';

  @override
  String homeTransportSwitched(String address) {
    return 'Transport basculé → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name vous appelle...';
  }

  @override
  String get homeAccept => 'Accepter';

  @override
  String get homeDecline => 'Refuser';

  @override
  String get homeLoadEarlier => 'Charger les messages précédents';

  @override
  String get homeChats => 'Discussions';

  @override
  String get homeSelectConversation => 'Sélectionnez une conversation';

  @override
  String get homeNoChatsYet => 'Aucune discussion';

  @override
  String get homeAddContactToStart => 'Ajoutez un contact pour commencer';

  @override
  String get homeNewChat => 'Nouvelle discussion';

  @override
  String get homeNewChatTooltip => 'Nouvelle discussion';

  @override
  String get homeIncomingCallTitle => 'Appel entrant';

  @override
  String get homeIncomingGroupCallTitle => 'Appel de groupe entrant';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — appel de groupe entrant';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Aucune discussion correspondant à \"$query\"';
  }

  @override
  String get homeSectionChats => 'Discussions';

  @override
  String get homeSectionMessages => 'Messages';

  @override
  String get homeDbEncryptionUnavailable =>
      'Chiffrement de la base de données indisponible — installez SQLCipher pour une protection complète';

  @override
  String get chatFileTooLargeGroup =>
      'Les fichiers de plus de 512 Ko ne sont pas pris en charge dans les discussions de groupe';

  @override
  String get chatLargeFile => 'Fichier volumineux';

  @override
  String get chatCancel => 'Annuler';

  @override
  String get chatSend => 'Envoyer';

  @override
  String get chatFileTooLarge =>
      'Fichier trop volumineux — la taille maximale est de 100 Mo';

  @override
  String get chatMicDenied => 'Autorisation du microphone refusée';

  @override
  String get chatVoiceFailed =>
      'Échec de l\'enregistrement vocal — vérifiez l\'espace de stockage disponible';

  @override
  String get chatScheduleFuture =>
      'L\'heure programmée doit être dans le futur';

  @override
  String get chatToday => 'Aujourd\'hui';

  @override
  String get chatYesterday => 'Hier';

  @override
  String get chatEdited => 'modifié';

  @override
  String get chatYou => 'Vous';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Ce fichier fait $size Mo. L\'envoi de fichiers volumineux peut être lent sur certains réseaux. Continuer ?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'La clé de sécurité de $name a changé. Appuyez pour vérifier.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Impossible de chiffrer le message pour $name — message non envoyé.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Le numéro de sécurité a changé pour $name. Appuyez pour vérifier.';
  }

  @override
  String get chatNoMessagesFound => 'Aucun message trouvé';

  @override
  String get chatMessagesE2ee => 'Les messages sont chiffrés de bout en bout';

  @override
  String get chatSayHello => 'Dites bonjour';

  @override
  String get appBarOnline => 'en ligne';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'en train d\'écrire';

  @override
  String get appBarSearchMessages => 'Rechercher des messages...';

  @override
  String get appBarMute => 'Muet';

  @override
  String get appBarUnmute => 'Son activé';

  @override
  String get appBarMedia => 'Médias';

  @override
  String get appBarDisappearing => 'Messages éphémères';

  @override
  String get appBarDisappearingOn => 'Éphémère : activé';

  @override
  String get appBarGroupSettings => 'Paramètres du groupe';

  @override
  String get appBarSearchTooltip => 'Rechercher des messages';

  @override
  String get appBarVoiceCall => 'Appel vocal';

  @override
  String get appBarVideoCall => 'Appel vidéo';

  @override
  String get inputMessage => 'Message...';

  @override
  String get inputAttachFile => 'Joindre un fichier';

  @override
  String get inputSendMessage => 'Envoyer le message';

  @override
  String get inputRecordVoice => 'Enregistrer un message vocal';

  @override
  String get inputSendVoice => 'Envoyer le message vocal';

  @override
  String get inputCancelReply => 'Annuler la réponse';

  @override
  String get inputCancelEdit => 'Annuler la modification';

  @override
  String get inputCancelRecording => 'Annuler l\'enregistrement';

  @override
  String get inputRecording => 'Enregistrement…';

  @override
  String get inputEditingMessage => 'Modification du message';

  @override
  String get inputPhoto => 'Photo';

  @override
  String get inputVoiceMessage => 'Message vocal';

  @override
  String get inputFile => 'Fichier';

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
    return '$count message$_temp0 programmé$_temp1';
  }

  @override
  String get callInitializing => 'Initialisation de l\'appel…';

  @override
  String get callConnecting => 'Connexion…';

  @override
  String get callConnectingRelay => 'Connexion (relais)…';

  @override
  String get callSwitchingRelay => 'Basculement en mode relais…';

  @override
  String get callConnectionFailed => 'Échec de la connexion';

  @override
  String get callReconnecting => 'Reconnexion…';

  @override
  String get callEnded => 'Appel terminé';

  @override
  String get callLive => 'En cours';

  @override
  String get callEnd => 'Fin';

  @override
  String get callEndCall => 'Raccrocher';

  @override
  String get callMute => 'Muet';

  @override
  String get callUnmute => 'Son activé';

  @override
  String get callSpeaker => 'Haut-parleur';

  @override
  String get callCameraOn => 'Caméra activée';

  @override
  String get callCameraOff => 'Caméra désactivée';

  @override
  String get callShareScreen => 'Partager l\'écran';

  @override
  String get callStopShare => 'Arrêter le partage';

  @override
  String callTorBackup(String duration) {
    return 'Secours Tor · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Secours Tor actif — chemin principal indisponible';

  @override
  String get callDirectFailed =>
      'Connexion directe échouée — basculement en mode relais…';

  @override
  String get callTurnUnreachable =>
      'Serveurs TURN injoignables. Ajoutez un TURN personnalisé dans Paramètres → Avancé.';

  @override
  String get callRelayMode => 'Mode relais actif (réseau restreint)';

  @override
  String get callStarting => 'Démarrage de l\'appel…';

  @override
  String get callConnectingToGroup => 'Connexion au groupe…';

  @override
  String get callGroupOpenedInBrowser =>
      'Appel de groupe ouvert dans le navigateur';

  @override
  String get callCouldNotOpenBrowser => 'Impossible d\'ouvrir le navigateur';

  @override
  String get callInviteLinkSent =>
      'Lien d\'invitation envoyé à tous les membres du groupe.';

  @override
  String get callOpenLinkManually =>
      'Ouvrez le lien ci-dessus manuellement ou appuyez pour réessayer.';

  @override
  String get callJitsiNotE2ee =>
      'Les appels Jitsi ne sont PAS chiffrés de bout en bout';

  @override
  String get callRetryOpenBrowser => 'Réessayer d\'ouvrir le navigateur';

  @override
  String get callClose => 'Fermer';

  @override
  String get callCamOn => 'Caméra on';

  @override
  String get callCamOff => 'Caméra off';

  @override
  String get noConnection =>
      'Pas de connexion — les messages seront mis en file d\'attente';

  @override
  String get connected => 'Connecté';

  @override
  String get connecting => 'Connexion…';

  @override
  String get disconnected => 'Déconnecté';

  @override
  String get offlineBanner =>
      'Pas de connexion — les messages seront envoyés une fois reconnecté';

  @override
  String get lanModeBanner =>
      'Mode LAN — Pas d\'internet · Réseau local uniquement';

  @override
  String get probeCheckingNetwork => 'Vérification de la connectivité réseau…';

  @override
  String get probeDiscoveringRelays =>
      'Découverte des relais via les annuaires communautaires…';

  @override
  String get probeStartingTor => 'Démarrage de Tor pour l\'amorçage…';

  @override
  String get probeFindingRelaysTor =>
      'Recherche de relais accessibles via Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'Réseau prêt — $count relais trouvé$_temp0';
  }

  @override
  String get probeNoRelaysFound =>
      'Aucun relais accessible trouvé — les messages pourraient être retardés';

  @override
  String get jitsiWarningTitle => 'Non chiffré de bout en bout';

  @override
  String get jitsiWarningBody =>
      'Les appels Jitsi Meet ne sont pas chiffrés par Pulse. À utiliser uniquement pour les conversations non sensibles.';

  @override
  String get jitsiConfirm => 'Rejoindre quand même';

  @override
  String get jitsiGroupWarningTitle => 'Non chiffré de bout en bout';

  @override
  String get jitsiGroupWarningBody =>
      'Cet appel a trop de participants pour le maillage chiffré intégré.\n\nUn lien Jitsi Meet sera ouvert dans votre navigateur. Jitsi n\'est PAS chiffré de bout en bout — le serveur peut voir votre appel.';

  @override
  String get jitsiContinueAnyway => 'Continuer quand même';

  @override
  String get retry => 'Réessayer';

  @override
  String get setupCreateAnonymousAccount => 'Créer un compte anonyme';

  @override
  String get setupTapToChangeColor => 'Appuyez pour changer la couleur';

  @override
  String get setupReqMinLength => 'At least 16 characters';

  @override
  String get setupReqVariety => '3 of 4: uppercase, lowercase, digits, symbols';

  @override
  String get setupReqMatch => 'Passwords match';

  @override
  String get setupYourNickname => 'Votre pseudonyme';

  @override
  String get setupRecoveryPassword => 'Mot de passe de récupération (min. 16)';

  @override
  String get setupConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get setupMin16Chars => 'Minimum 16 caractères';

  @override
  String get setupPasswordsDoNotMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get setupEntropyWeak => 'Faible';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Fort';

  @override
  String get setupEntropyWeakNeedsVariety =>
      'Faible (3 types de caractères requis)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bits)';
  }

  @override
  String get setupPasswordWarning =>
      'Ce mot de passe est le seul moyen de restaurer votre compte. Il n\'y a pas de serveur — pas de réinitialisation du mot de passe. Retenez-le ou notez-le.';

  @override
  String get setupCreateAccount => 'Créer un compte';

  @override
  String get setupAlreadyHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get setupRestore => 'Restaurer →';

  @override
  String get restoreTitle => 'Restaurer le compte';

  @override
  String get restoreInfoBanner =>
      'Entrez votre mot de passe de récupération — votre adresse (Nostr + Session) sera restaurée automatiquement. Les contacts et messages étaient stockés localement uniquement.';

  @override
  String get restoreNewNickname => 'Nouveau pseudonyme (modifiable plus tard)';

  @override
  String get restoreButton => 'Restaurer le compte';

  @override
  String get lockTitle => 'Pulse est verrouillé';

  @override
  String get lockSubtitle => 'Entrez votre mot de passe pour continuer';

  @override
  String get lockPasswordHint => 'Mot de passe';

  @override
  String get lockUnlock => 'Déverrouiller';

  @override
  String get lockPanicHint =>
      'Mot de passe oublié ? Entrez votre clé de panique pour effacer toutes les données.';

  @override
  String get lockTooManyAttempts =>
      'Trop de tentatives. Effacement de toutes les données…';

  @override
  String get lockWrongPassword => 'Mot de passe incorrect';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Mot de passe incorrect — $attempts/$max tentatives';
  }

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingGetStarted => 'Commencer';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue sur Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Un messager décentralisé et chiffré de bout en bout.\n\nPas de serveurs centraux. Pas de collecte de données. Pas de portes dérobées.\nVos conversations n\'appartiennent qu\'à vous.';

  @override
  String get onboardingTransportTitle => 'Agnostique en transport';

  @override
  String get onboardingTransportBody =>
      'Utilisez Firebase, Nostr, ou les deux en même temps.\n\nLes messages transitent automatiquement entre les réseaux. Support intégré de Tor et I2P pour résister à la censure.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantique';

  @override
  String get onboardingSignalBody =>
      'Chaque message est chiffré avec le protocole Signal (Double Ratchet + X3DH) pour la confidentialité persistante.\n\nEnveloppé en plus avec Kyber-1024 — un algorithme post-quantique standardisé par le NIST — protégeant contre les futurs ordinateurs quantiques.';

  @override
  String get onboardingKeysTitle => 'Vous possédez vos clés';

  @override
  String get onboardingKeysBody =>
      'Vos clés d\'identité ne quittent jamais votre appareil.\n\nLes empreintes Signal vous permettent de vérifier vos contacts hors bande. TOFU (Trust On First Use) détecte automatiquement les changements de clés.';

  @override
  String get onboardingThemeTitle => 'Choisissez votre style';

  @override
  String get onboardingThemeBody =>
      'Choisissez un thème et une couleur d\'accentuation. Vous pourrez toujours les modifier plus tard dans les Paramètres.';

  @override
  String get contactsNewChat => 'Nouvelle discussion';

  @override
  String get contactsAddContact => 'Ajouter un contact';

  @override
  String get contactsSearchHint => 'Rechercher...';

  @override
  String get contactsNewGroup => 'Nouveau groupe';

  @override
  String get contactsNoContactsYet => 'Aucun contact pour le moment';

  @override
  String get contactsAddHint =>
      'Appuyez sur + pour ajouter l\'adresse de quelqu\'un';

  @override
  String get contactsNoMatch => 'Aucun contact correspondant';

  @override
  String get contactsRemoveTitle => 'Supprimer le contact';

  @override
  String contactsRemoveMessage(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get contactsRemove => 'Supprimer';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count contact$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Ouvrir le lien';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Ouvrir cette URL dans votre navigateur ?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Ouvrir';

  @override
  String get bubbleSecurityWarning => 'Avertissement de sécurité';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" est un type de fichier exécutable. L\'enregistrer et l\'exécuter pourrait endommager votre appareil. Enregistrer quand même ?';
  }

  @override
  String get bubbleSaveAnyway => 'Enregistrer quand même';

  @override
  String bubbleSavedTo(String path) {
    return 'Enregistré dans $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Échec de l\'enregistrement : $error';
  }

  @override
  String get bubbleNotEncrypted => 'NON CHIFFRÉ';

  @override
  String get bubbleCorruptedImage => '[Image corrompue]';

  @override
  String get bubbleReplyPhoto => 'Photo';

  @override
  String get bubbleReplyVoice => 'Message vocal';

  @override
  String get bubbleReplyVideo => 'Message vidéo';

  @override
  String bubbleReadBy(String names) {
    return 'Lu par $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Lu par $count';
  }

  @override
  String get chatTileTapToStart => 'Appuyez pour commencer à discuter';

  @override
  String get chatTileMessageSent => 'Message envoyé';

  @override
  String get chatTileEncryptedMessage => 'Message chiffré';

  @override
  String chatTileYouPrefix(String text) {
    return 'Vous : $text';
  }

  @override
  String get bannerEncryptedMessage => 'Message chiffré';

  @override
  String get groupNewGroup => 'Nouveau groupe';

  @override
  String get groupGroupName => 'Nom du groupe';

  @override
  String get groupSelectMembers => 'Sélectionner les membres (min 2)';

  @override
  String get groupNoContactsYet =>
      'Aucun contact pour le moment. Ajoutez d\'abord des contacts.';

  @override
  String get groupCreate => 'Créer';

  @override
  String get groupLabel => 'Groupe';

  @override
  String get profileVerifyIdentity => 'Vérifier l\'identité';

  @override
  String profileVerifyInstructions(String name) {
    return 'Comparez ces empreintes avec $name lors d\'un appel vocal ou en personne. Si les deux valeurs correspondent sur les deux appareils, appuyez sur « Marquer comme vérifié ».';
  }

  @override
  String get profileTheirKey => 'Sa clé';

  @override
  String get profileYourKey => 'Votre clé';

  @override
  String get profileRemoveVerification => 'Supprimer la vérification';

  @override
  String get profileMarkAsVerified => 'Marquer comme vérifié';

  @override
  String get profileAddressCopied => 'Adresse copiée';

  @override
  String get profileNoContactsToAdd =>
      'Aucun contact à ajouter — tous sont déjà membres';

  @override
  String get profileAddMembers => 'Ajouter des membres';

  @override
  String profileAddCount(int count) {
    return 'Ajouter ($count)';
  }

  @override
  String get profileRenameGroup => 'Renommer le groupe';

  @override
  String get profileRename => 'Renommer';

  @override
  String get profileRemoveMember => 'Supprimer le membre ?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Supprimer $name de ce groupe ?';
  }

  @override
  String get profileKick => 'Exclure';

  @override
  String get profileSignalFingerprints => 'Empreintes Signal';

  @override
  String get profileVerified => 'VÉRIFIÉ';

  @override
  String get profileVerify => 'Vérifier';

  @override
  String get profileEdit => 'Modifier';

  @override
  String get profileNoSession =>
      'Aucune session établie — envoyez d\'abord un message.';

  @override
  String get profileFingerprintCopied => 'Empreinte copiée';

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
  String get profileVerifySafetyNumber => 'Vérifier le numéro de sécurité';

  @override
  String get profileShowContactQr => 'Afficher le QR du contact';

  @override
  String profileContactAddress(String name) {
    return 'Adresse de $name';
  }

  @override
  String get profileExportChatHistory => 'Exporter l\'historique de discussion';

  @override
  String profileSavedTo(String path) {
    return 'Enregistré dans $path';
  }

  @override
  String get profileExportFailed => 'Échec de l\'exportation';

  @override
  String get profileClearChatHistory => 'Effacer l\'historique de discussion';

  @override
  String get profileDeleteGroup => 'Supprimer le groupe';

  @override
  String get profileDeleteContact => 'Supprimer le contact';

  @override
  String get profileLeaveGroup => 'Quitter le groupe';

  @override
  String get profileLeaveGroupBody =>
      'Vous serez retiré de ce groupe et il sera supprimé de vos contacts.';

  @override
  String get groupInviteTitle => 'Invitation au groupe';

  @override
  String groupInviteBody(String from, String group) {
    return '$from vous a invité à rejoindre \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Accepter';

  @override
  String get groupInviteDecline => 'Refuser';

  @override
  String get groupMemberLimitTitle => 'Trop de participants';

  @override
  String groupMemberLimitBody(int count) {
    return 'Ce groupe aura $count participants. Les appels maillés chiffrés prennent en charge jusqu\'à 6 personnes. Les groupes plus grands basculent vers Jitsi (non E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Ajouter quand même';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name a refusé de rejoindre \"$group\"';
  }

  @override
  String get transferTitle => 'Transférer vers un autre appareil';

  @override
  String get transferInfoBox =>
      'Transférez votre identité Signal et vos clés Nostr vers un nouvel appareil.\nLes sessions de discussion ne sont PAS transférées — la confidentialité persistante est préservée.';

  @override
  String get transferSendFromThis => 'Envoyer depuis cet appareil';

  @override
  String get transferSendSubtitle =>
      'Cet appareil possède les clés. Partagez un code avec le nouvel appareil.';

  @override
  String get transferReceiveOnThis => 'Recevoir sur cet appareil';

  @override
  String get transferReceiveSubtitle =>
      'Ceci est le nouvel appareil. Entrez le code de l\'ancien appareil.';

  @override
  String get transferChooseMethod => 'Choisir la méthode de transfert';

  @override
  String get transferLan => 'LAN (Même réseau)';

  @override
  String get transferLanSubtitle =>
      'Rapide et direct. Les deux appareils doivent être sur le même Wi-Fi.';

  @override
  String get transferNostrRelay => 'Relais Nostr';

  @override
  String get transferNostrRelaySubtitle =>
      'Fonctionne sur n\'importe quel réseau via un relais Nostr existant.';

  @override
  String get transferRelayUrl => 'URL du relais';

  @override
  String get transferEnterCode => 'Entrer le code de transfert';

  @override
  String get transferPasteCode => 'Collez le code LAN:... ou NOS:... ici';

  @override
  String get transferConnect => 'Connecter';

  @override
  String get transferGenerating => 'Génération du code de transfert…';

  @override
  String get transferShareCode => 'Partagez ce code avec le destinataire :';

  @override
  String get transferCopyCode => 'Copier le code';

  @override
  String get transferCodeCopied => 'Code copié dans le presse-papiers';

  @override
  String get transferWaitingReceiver =>
      'En attente de la connexion du destinataire…';

  @override
  String get transferConnectingSender => 'Connexion à l\'expéditeur…';

  @override
  String get transferVerifyBoth =>
      'Comparez ce code sur les deux appareils.\nS\'ils correspondent, le transfert est sécurisé.';

  @override
  String get transferComplete => 'Transfert terminé';

  @override
  String get transferKeysImported => 'Clés importées';

  @override
  String get transferCompleteSenderBody =>
      'Vos clés restent actives sur cet appareil.\nLe destinataire peut maintenant utiliser votre identité.';

  @override
  String get transferCompleteReceiverBody =>
      'Clés importées avec succès.\nRedémarrez l\'application pour appliquer la nouvelle identité.';

  @override
  String get transferRestartApp => 'Redémarrer l\'application';

  @override
  String get transferFailed => 'Échec du transfert';

  @override
  String get transferTryAgain => 'Réessayer';

  @override
  String get transferEnterRelayFirst => 'Entrez d\'abord une URL de relais';

  @override
  String get transferPasteCodeFromSender =>
      'Collez le code de transfert de l\'expéditeur';

  @override
  String get menuReply => 'Répondre';

  @override
  String get menuForward => 'Transférer';

  @override
  String get menuReact => 'Réagir';

  @override
  String get menuCopy => 'Copier';

  @override
  String get menuEdit => 'Modifier';

  @override
  String get menuRetry => 'Réessayer';

  @override
  String get menuCancelScheduled => 'Annuler la programmation';

  @override
  String get menuDelete => 'Supprimer';

  @override
  String get menuForwardTo => 'Transférer à…';

  @override
  String menuForwardedTo(String name) {
    return 'Transféré à $name';
  }

  @override
  String get menuScheduledMessages => 'Messages programmés';

  @override
  String get menuNoScheduledMessages => 'Aucun message programmé';

  @override
  String menuSendsOn(String date) {
    return 'Envoi le $date';
  }

  @override
  String get menuDisappearingMessages => 'Messages éphémères';

  @override
  String get menuDisappearingSubtitle =>
      'Les messages sont automatiquement supprimés après le délai sélectionné.';

  @override
  String get menuTtlOff => 'Désactivé';

  @override
  String get menuTtl1h => '1 heure';

  @override
  String get menuTtl24h => '24 heures';

  @override
  String get menuTtl7d => '7 jours';

  @override
  String get menuAttachPhoto => 'Photo';

  @override
  String get menuAttachFile => 'Fichier';

  @override
  String get menuAttachVideo => 'Vidéo';

  @override
  String get mediaTitle => 'Médias';

  @override
  String get mediaFileLabel => 'FICHIER';

  @override
  String mediaPhotosTab(int count) {
    return 'Photos ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Fichiers ($count)';
  }

  @override
  String get mediaNoPhotos => 'Aucune photo pour le moment';

  @override
  String get mediaNoFiles => 'Aucun fichier pour le moment';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Enregistré dans Téléchargements/$name';
  }

  @override
  String get mediaFailedToSave => 'Échec de l\'enregistrement du fichier';

  @override
  String get statusNewStatus => 'Nouveau statut';

  @override
  String get statusPublish => 'Publier';

  @override
  String get statusExpiresIn24h => 'Le statut expire dans 24 heures';

  @override
  String get statusWhatsOnYourMind => 'Qu\'avez-vous en tête ?';

  @override
  String get statusPhotoAttached => 'Photo jointe';

  @override
  String get statusAttachPhoto => 'Joindre une photo (optionnel)';

  @override
  String get statusEnterText => 'Veuillez saisir du texte pour votre statut.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Échec de la sélection de photo : $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Échec de la publication : $error';
  }

  @override
  String get panicSetPanicKey => 'Définir la clé de panique';

  @override
  String get panicEmergencySelfDestruct => 'Autodestruction d\'urgence';

  @override
  String get panicIrreversible => 'Cette action est irréversible';

  @override
  String get panicWarningBody =>
      'Saisir cette clé sur l\'écran de verrouillage efface instantanément TOUTES les données — messages, contacts, clés, identité. Utilisez une clé différente de votre mot de passe habituel.';

  @override
  String get panicKeyHint => 'Clé de panique';

  @override
  String get panicConfirmHint => 'Confirmer la clé de panique';

  @override
  String get panicMinChars =>
      'La clé de panique doit contenir au moins 8 caractères';

  @override
  String get panicKeysDoNotMatch => 'Les clés ne correspondent pas';

  @override
  String get panicSetFailed =>
      'Échec de l\'enregistrement de la clé de panique — veuillez réessayer';

  @override
  String get passwordSetAppPassword =>
      'Définir le mot de passe de l\'application';

  @override
  String get passwordProtectsMessages => 'Protège vos messages au repos';

  @override
  String get passwordInfoBanner =>
      'Requis à chaque ouverture de Pulse. En cas d\'oubli, vos données ne pourront pas être récupérées.';

  @override
  String get passwordHint => 'Mot de passe';

  @override
  String get passwordConfirmHint => 'Confirmer le mot de passe';

  @override
  String get passwordSetButton => 'Définir le mot de passe';

  @override
  String get passwordSkipForNow => 'Passer pour l\'instant';

  @override
  String get passwordMinChars =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get profileCardSaved => 'Profil enregistré !';

  @override
  String get profileCardE2eeIdentity => 'Identité E2EE';

  @override
  String get profileCardDisplayName => 'Nom d\'affichage';

  @override
  String get profileCardDisplayNameHint => 'ex. Jean Dupont';

  @override
  String get profileCardAbout => 'À propos';

  @override
  String get profileCardSaveProfile => 'Enregistrer le profil';

  @override
  String get profileCardYourName => 'Votre nom';

  @override
  String get profileCardAddressCopied => 'Adresse copiée !';

  @override
  String get profileCardInboxAddress => 'Votre adresse de réception';

  @override
  String get profileCardInboxAddresses => 'Vos adresses de réception';

  @override
  String get profileCardShareAllAddresses =>
      'Partager toutes les adresses (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Partagez avec vos contacts pour qu\'ils puissent vous écrire.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Les $count adresses ont été copiées en un seul lien !';
  }

  @override
  String get settingsMyProfile => 'Mon profil';

  @override
  String get settingsYourInboxAddress => 'Votre adresse de réception';

  @override
  String get settingsMyQrCode => 'Mon QR Code';

  @override
  String get settingsMyQrSubtitle =>
      'Partagez votre adresse sous forme de QR scannable';

  @override
  String get settingsShareMyAddress => 'Partager mon adresse';

  @override
  String get settingsNoAddressYet =>
      'Pas encore d\'adresse — enregistrez d\'abord les paramètres';

  @override
  String get settingsInviteLink => 'Lien d\'invitation';

  @override
  String get settingsRawAddress => 'Adresse brute';

  @override
  String get settingsCopyLink => 'Copier le lien';

  @override
  String get settingsCopyAddress => 'Copier l\'adresse';

  @override
  String get settingsInviteLinkCopied => 'Lien d\'invitation copié';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsThemeEngine => 'Moteur de thème';

  @override
  String get settingsThemeEngineSubtitle =>
      'Personnaliser les couleurs et polices';

  @override
  String get settingsSignalProtocol => 'Protocole Signal';

  @override
  String get settingsSignalProtocolSubtitle =>
      'Les clés E2EE sont stockées de manière sécurisée';

  @override
  String get settingsActive => 'ACTIF';

  @override
  String get settingsIdentityBackup => 'Sauvegarde d\'identité';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Exporter ou importer votre identité Signal';

  @override
  String get settingsIdentityBackupBody =>
      'Exportez vos clés d\'identité Signal vers un code de sauvegarde, ou restaurez à partir d\'un code existant.';

  @override
  String get settingsTransferDevice => 'Transférer vers un autre appareil';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Transférer votre identité via LAN ou relais Nostr';

  @override
  String get settingsExportIdentity => 'Exporter l\'identité';

  @override
  String get settingsExportIdentityBody =>
      'Copiez ce code de sauvegarde et conservez-le en lieu sûr :';

  @override
  String get settingsSaveFile => 'Enregistrer le fichier';

  @override
  String get settingsImportIdentity => 'Importer l\'identité';

  @override
  String get settingsImportIdentityBody =>
      'Collez votre code de sauvegarde ci-dessous. Cela écrasera votre identité actuelle.';

  @override
  String get settingsPasteBackupCode => 'Collez le code de sauvegarde ici…';

  @override
  String get settingsIdentityImported =>
      'Identité + contacts importés ! Redémarrez l\'application pour appliquer.';

  @override
  String get settingsSecurity => 'Sécurité';

  @override
  String get settingsAppPassword => 'Mot de passe de l\'application';

  @override
  String get settingsPasswordEnabled => 'Activé — requis à chaque lancement';

  @override
  String get settingsPasswordDisabled =>
      'Désactivé — l\'application s\'ouvre sans mot de passe';

  @override
  String get settingsChangePassword => 'Changer le mot de passe';

  @override
  String get settingsChangePasswordSubtitle =>
      'Mettre à jour votre mot de passe de verrouillage';

  @override
  String get settingsSetPanicKey => 'Définir la clé de panique';

  @override
  String get settingsChangePanicKey => 'Changer la clé de panique';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Mettre à jour la clé d\'effacement d\'urgence';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Une clé qui efface instantanément toutes les données';

  @override
  String get settingsRemovePanicKey => 'Supprimer la clé de panique';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Désactiver l\'autodestruction d\'urgence';

  @override
  String get settingsRemovePanicKeyBody =>
      'L\'autodestruction d\'urgence sera désactivée. Vous pourrez la réactiver à tout moment.';

  @override
  String get settingsDisableAppPassword => 'Désactiver le mot de passe';

  @override
  String get settingsEnterCurrentPassword =>
      'Entrez votre mot de passe actuel pour confirmer';

  @override
  String get settingsCurrentPassword => 'Mot de passe actuel';

  @override
  String get settingsIncorrectPassword => 'Mot de passe incorrect';

  @override
  String get settingsPasswordUpdated => 'Mot de passe mis à jour';

  @override
  String get settingsChangePasswordProceed =>
      'Entrez votre mot de passe actuel pour continuer';

  @override
  String get settingsData => 'Données';

  @override
  String get settingsBackupMessages => 'Sauvegarder les messages';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Exporter l\'historique chiffré des messages vers un fichier';

  @override
  String get settingsRestoreMessages => 'Restaurer les messages';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Importer les messages depuis un fichier de sauvegarde';

  @override
  String get settingsExportKeys => 'Exporter les clés';

  @override
  String get settingsExportKeysSubtitle =>
      'Enregistrer les clés d\'identité dans un fichier chiffré';

  @override
  String get settingsImportKeys => 'Importer les clés';

  @override
  String get settingsImportKeysSubtitle =>
      'Restaurer les clés d\'identité depuis un fichier exporté';

  @override
  String get settingsBackupPassword => 'Mot de passe de sauvegarde';

  @override
  String get settingsPasswordCannotBeEmpty =>
      'Le mot de passe ne peut pas être vide';

  @override
  String get settingsPasswordMin4Chars =>
      'Le mot de passe doit contenir au moins 4 caractères';

  @override
  String get settingsCallsTurn => 'Appels & TURN';

  @override
  String get settingsLocalNetwork => 'Réseau local';

  @override
  String get settingsCensorshipResistance => 'Résistance à la censure';

  @override
  String get settingsNetwork => 'Réseau';

  @override
  String get settingsProxyTunnels => 'Proxy & Tunnels';

  @override
  String get settingsTurnServers => 'Serveurs TURN';

  @override
  String get settingsProviderTitle => 'Fournisseur';

  @override
  String get settingsLanFallback => 'Repli LAN';

  @override
  String get settingsLanFallbackSubtitle =>
      'Diffuser la présence et envoyer les messages sur le réseau local lorsqu\'internet est indisponible. Désactivez sur les réseaux non fiables (Wi-Fi public).';

  @override
  String get settingsBgDelivery => 'Livraison en arrière-plan';

  @override
  String get settingsBgDeliverySubtitle =>
      'Continuer à recevoir les messages lorsque l\'application est réduite. Affiche une notification persistante.';

  @override
  String get settingsYourInboxProvider => 'Votre fournisseur de réception';

  @override
  String get settingsConnectionDetails => 'Détails de connexion';

  @override
  String get settingsSaveAndConnect => 'Enregistrer & Connecter';

  @override
  String get settingsSecondaryInboxes => 'Boîtes de réception secondaires';

  @override
  String get settingsAddSecondaryInbox => 'Ajouter une boîte secondaire';

  @override
  String get settingsAdvanced => 'Avancé';

  @override
  String get settingsDiscover => 'Découvrir';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Comment Pulse protège vos données';

  @override
  String get settingsCrashReporting => 'Rapports de plantage';

  @override
  String get settingsCrashReportingSubtitle =>
      'Envoyer des rapports de plantage anonymes pour améliorer Pulse. Aucun contenu de message ni contact n\'est jamais envoyé.';

  @override
  String get settingsCrashReportingEnabled =>
      'Rapports de plantage activés — redémarrez l\'application pour appliquer';

  @override
  String get settingsCrashReportingDisabled =>
      'Rapports de plantage désactivés — redémarrez l\'application pour appliquer';

  @override
  String get settingsSensitiveOperation => 'Opération sensible';

  @override
  String get settingsSensitiveOperationBody =>
      'Ces clés sont votre identité. Toute personne possédant ce fichier peut se faire passer pour vous. Conservez-le en lieu sûr et supprimez-le après le transfert.';

  @override
  String get settingsIUnderstandContinue => 'Je comprends, continuer';

  @override
  String get settingsReplaceIdentity => 'Remplacer l\'identité ?';

  @override
  String get settingsReplaceIdentityBody =>
      'Cela écrasera vos clés d\'identité actuelles. Vos sessions Signal existantes seront invalidées et vos contacts devront rétablir le chiffrement. L\'application devra redémarrer.';

  @override
  String get settingsReplaceKeys => 'Remplacer les clés';

  @override
  String get settingsKeysImported => 'Clés importées';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count clés importées avec succès. Veuillez redémarrer l\'application pour réinitialiser avec la nouvelle identité.';
  }

  @override
  String get settingsRestartNow => 'Redémarrer maintenant';

  @override
  String get settingsLater => 'Plus tard';

  @override
  String get profileGroupLabel => 'Groupe';

  @override
  String get profileAddButton => 'Ajouter';

  @override
  String get profileKickButton => 'Exclure';

  @override
  String get dataSectionTitle => 'Données';

  @override
  String get dataBackupMessages => 'Sauvegarder les messages';

  @override
  String get dataBackupPasswordSubtitle =>
      'Choisissez un mot de passe pour chiffrer votre sauvegarde.';

  @override
  String get dataBackupConfirmLabel => 'Créer la sauvegarde';

  @override
  String get dataCreatingBackup => 'Création de la sauvegarde';

  @override
  String get dataBackupPreparing => 'Préparation...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Exportation du message $done sur $total...';
  }

  @override
  String get dataBackupSavingFile => 'Enregistrement du fichier...';

  @override
  String get dataSaveMessageBackupDialog =>
      'Enregistrer la sauvegarde des messages';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Sauvegarde enregistrée ($count messages)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Échec de la sauvegarde — aucune donnée exportée';

  @override
  String dataBackupFailedError(String error) {
    return 'Échec de la sauvegarde : $error';
  }

  @override
  String get dataSelectMessageBackupDialog =>
      'Sélectionner la sauvegarde des messages';

  @override
  String get dataInvalidBackupFile =>
      'Fichier de sauvegarde invalide (trop petit)';

  @override
  String get dataNotValidBackupFile =>
      'Ce n\'est pas un fichier de sauvegarde Pulse valide';

  @override
  String get dataRestoreMessages => 'Restaurer les messages';

  @override
  String get dataRestorePasswordSubtitle =>
      'Entrez le mot de passe utilisé pour créer cette sauvegarde.';

  @override
  String get dataRestoreConfirmLabel => 'Restaurer';

  @override
  String get dataRestoringMessages => 'Restauration des messages';

  @override
  String get dataRestoreDecrypting => 'Déchiffrement...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Importation du message $done sur $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Échec de la restauration — mot de passe incorrect ou fichier corrompu';

  @override
  String dataRestoreSuccess(int count) {
    return '$count nouveaux messages restaurés';
  }

  @override
  String get dataRestoreNothingNew =>
      'Aucun nouveau message à importer (tous existent déjà)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Échec de la restauration : $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Sélectionner l\'export de clés';

  @override
  String get dataNotValidKeyFile =>
      'Ce n\'est pas un fichier d\'export de clés Pulse valide';

  @override
  String get dataExportKeys => 'Exporter les clés';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Choisissez un mot de passe pour chiffrer votre export de clés.';

  @override
  String get dataExportKeysConfirmLabel => 'Exporter';

  @override
  String get dataExportingKeys => 'Exportation des clés';

  @override
  String get dataExportingKeysStatus => 'Chiffrement des clés d\'identité...';

  @override
  String get dataSaveKeyExportDialog => 'Enregistrer l\'export de clés';

  @override
  String dataKeysExportedTo(String path) {
    return 'Clés exportées vers :\n$path';
  }

  @override
  String get dataExportFailed => 'Échec de l\'exportation — aucune clé trouvée';

  @override
  String dataExportFailedError(String error) {
    return 'Échec de l\'exportation : $error';
  }

  @override
  String get dataImportKeys => 'Importer les clés';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Entrez le mot de passe utilisé pour chiffrer cet export de clés.';

  @override
  String get dataImportKeysConfirmLabel => 'Importer';

  @override
  String get dataImportingKeys => 'Importation des clés';

  @override
  String get dataImportingKeysStatus => 'Déchiffrement des clés d\'identité...';

  @override
  String get dataImportFailed =>
      'Échec de l\'importation — mot de passe incorrect ou fichier corrompu';

  @override
  String dataImportFailedError(String error) {
    return 'Échec de l\'importation : $error';
  }

  @override
  String get securitySectionTitle => 'Sécurité';

  @override
  String get securityIncorrectPassword => 'Mot de passe incorrect';

  @override
  String get securityPasswordUpdated => 'Mot de passe mis à jour';

  @override
  String get appearanceSectionTitle => 'Apparence';

  @override
  String appearanceExportFailed(String error) {
    return 'Échec de l\'exportation : $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Enregistré dans $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Échec de l\'enregistrement : $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Échec de l\'importation : $error';
  }

  @override
  String get aboutSectionTitle => 'À propos';

  @override
  String get providerPublicKey => 'Clé publique';

  @override
  String get providerRelay => 'Relais';

  @override
  String get providerAutoConfigured =>
      'Configuré automatiquement à partir de votre mot de passe de récupération. Relais découvert automatiquement.';

  @override
  String get providerKeyStoredLocally =>
      'Votre clé est stockée localement dans un stockage sécurisé — jamais envoyée à un serveur.';

  @override
  String get providerSessionInfo =>
      'Session Network — onion-routed E2EE. Your Session ID is auto-generated and stored securely. Nodes auto-discovered from built-in seed nodes.';

  @override
  String get providerAdvanced => 'Avancé';

  @override
  String get providerSaveAndConnect => 'Enregistrer & Connecter';

  @override
  String get providerAddSecondaryInbox => 'Ajouter une boîte secondaire';

  @override
  String get providerSecondaryInboxes => 'Boîtes de réception secondaires';

  @override
  String get providerYourInboxProvider => 'Votre fournisseur de réception';

  @override
  String get providerConnectionDetails => 'Détails de connexion';

  @override
  String get addContactTitle => 'Ajouter un contact';

  @override
  String get addContactInviteLinkLabel => 'Lien d\'invitation ou adresse';

  @override
  String get addContactTapToPaste =>
      'Appuyez pour coller le lien d\'invitation';

  @override
  String get addContactPasteTooltip => 'Coller depuis le presse-papiers';

  @override
  String get addContactAddressDetected => 'Adresse du contact détectée';

  @override
  String addContactRoutesDetected(int count) {
    return '$count routes détectées — SmartRouter choisit la plus rapide';
  }

  @override
  String get addContactFetchingProfile => 'Récupération du profil…';

  @override
  String addContactProfileFound(String name) {
    return 'Trouvé : $name';
  }

  @override
  String get addContactNoProfileFound => 'Aucun profil trouvé';

  @override
  String get addContactDisplayNameLabel => 'Nom d\'affichage';

  @override
  String get addContactDisplayNameHint => 'Comment voulez-vous l\'appeler ?';

  @override
  String get addContactAddManually => 'Ajouter l\'adresse manuellement';

  @override
  String get addContactButton => 'Ajouter le contact';

  @override
  String get networkDiagnosticsTitle => 'Diagnostics réseau';

  @override
  String get networkDiagnosticsNostrRelays => 'Relais Nostr';

  @override
  String get networkDiagnosticsDirect => 'Direct';

  @override
  String get networkDiagnosticsTorOnly => 'Tor uniquement';

  @override
  String get networkDiagnosticsBest => 'Meilleur';

  @override
  String get networkDiagnosticsNone => 'aucun';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Statut';

  @override
  String get networkDiagnosticsConnected => 'Connecté';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Connexion $percent %';
  }

  @override
  String get networkDiagnosticsOff => 'Désactivé';

  @override
  String get networkDiagnosticsTransport => 'Transport';

  @override
  String get networkDiagnosticsInfrastructure => 'Infrastructure';

  @override
  String get networkDiagnosticsSessionNodes => 'Session nodes';

  @override
  String get networkDiagnosticsTurnServers => 'Serveurs TURN';

  @override
  String get networkDiagnosticsLastProbe => 'Dernier sondage';

  @override
  String get networkDiagnosticsRunning => 'En cours...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Lancer les diagnostics';

  @override
  String get networkDiagnosticsForceReprobe => 'Forcer un sondage complet';

  @override
  String get networkDiagnosticsJustNow => 'à l\'instant';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'il y a $minutes min';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'il y a $hours h';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'il y a $days j';
  }

  @override
  String get homeNoEch => 'Pas d\'ECH';

  @override
  String get homeNoEchTooltip =>
      'Proxy uTLS indisponible — ECH désactivé.\nL\'empreinte TLS est visible par le DPI.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Enregistré & connecté à $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Échec du démarrage de Tor intégré';

  @override
  String get settingsPsiphonFailedToStart => 'Échec du démarrage de Psiphon';

  @override
  String get verifyTitle => 'Vérifier le numéro de sécurité';

  @override
  String get verifyIdentityVerified => 'Identité vérifiée';

  @override
  String get verifyNotYetVerified => 'Pas encore vérifié';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Vous avez vérifié le numéro de sécurité de $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Comparez ces numéros avec $name en personne ou via un canal de confiance.';
  }

  @override
  String get verifyExplanation =>
      'Chaque conversation a un numéro de sécurité unique. Si vous voyez tous les deux les mêmes numéros sur vos appareils, votre connexion est vérifiée de bout en bout.';

  @override
  String verifyContactKey(String name) {
    return 'Clé de $name';
  }

  @override
  String get verifyYourKey => 'Votre clé';

  @override
  String get verifyRemoveVerification => 'Supprimer la vérification';

  @override
  String get verifyMarkAsVerified => 'Marquer comme vérifié';

  @override
  String verifyAfterReinstall(String name) {
    return 'Si $name réinstalle l\'application, le numéro de sécurité changera et la vérification sera supprimée automatiquement.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Ne marquez comme vérifié qu\'après avoir comparé les numéros avec $name lors d\'un appel vocal ou en personne.';
  }

  @override
  String get verifyNoSession =>
      'Aucune session de chiffrement établie. Envoyez d\'abord un message pour générer les numéros de sécurité.';

  @override
  String get verifyNoKeyAvailable => 'Aucune clé disponible';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Empreinte $label copiée';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL de la base de données';

  @override
  String get providerOptionalHint => 'Optionnel';

  @override
  String get providerWebApiKeyLabel => 'Clé API Web';

  @override
  String get providerOptionalForPublicDb =>
      'Optionnel pour une base de données publique';

  @override
  String get providerRelayUrlLabel => 'URL du relais';

  @override
  String get providerPrivateKeyLabel => 'Clé privée';

  @override
  String get providerPrivateKeyNsecLabel => 'Clé privée (nsec)';

  @override
  String get providerStorageNodeLabel => 'URL du nœud de stockage (optionnel)';

  @override
  String get providerStorageNodeHint =>
      'Laissez vide pour les nœuds d\'amorçage intégrés';

  @override
  String get transferInvalidCodeFormat =>
      'Format de code non reconnu — doit commencer par LAN: ou NOS:';

  @override
  String get profileCardFingerprintCopied => 'Empreinte copiée';

  @override
  String get profileCardAboutHint => 'Confidentialité avant tout 🔒';

  @override
  String get profileCardSaveButton => 'Enregistrer le profil';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Exporter les messages, contacts et avatars chiffrés vers un fichier';

  @override
  String get callVideo => 'Vidéo';

  @override
  String get callAudio => 'Audio';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Livré à $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Livré à $count';
  }

  @override
  String get groupStatusDialogTitle => 'Info du message';

  @override
  String get groupStatusRead => 'Lu';

  @override
  String get groupStatusDelivered => 'Livré';

  @override
  String get groupStatusPending => 'En attente';

  @override
  String get groupStatusNoData =>
      'Aucune information de livraison pour le moment';

  @override
  String get profileTransferAdmin => 'Nommer administrateur';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Nommer $name comme nouvel administrateur ?';
  }

  @override
  String get profileTransferAdminBody =>
      'Vous perdrez les privilèges d\'administrateur. Cette action est irréversible.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name est maintenant l\'administrateur';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Politique de confidentialité';

  @override
  String get privacyOverviewHeading => 'Aperçu';

  @override
  String get privacyOverviewBody =>
      'Pulse est un messager sans serveur, chiffré de bout en bout. Votre confidentialité n\'est pas simplement une fonctionnalité — c\'est l\'architecture. Il n\'y a pas de serveurs Pulse. Aucun compte n\'est stocké nulle part. Aucune donnée n\'est collectée, transmise ou stockée par les développeurs.';

  @override
  String get privacyDataCollectionHeading => 'Collecte de données';

  @override
  String get privacyDataCollectionBody =>
      'Pulse ne collecte aucune donnée personnelle. Plus précisément :\n\n- Aucun e-mail, numéro de téléphone ou nom réel n\'est requis\n- Aucune analyse, suivi ou télémétrie\n- Aucun identifiant publicitaire\n- Aucun accès à la liste de contacts\n- Aucune sauvegarde cloud (les messages n\'existent que sur votre appareil)\n- Aucune métadonnée n\'est envoyée à un serveur Pulse (il n\'y en a pas)';

  @override
  String get privacyEncryptionHeading => 'Chiffrement';

  @override
  String get privacyEncryptionBody =>
      'Tous les messages sont chiffrés avec le protocole Signal (Double Ratchet avec accord de clés X3DH). Les clés de chiffrement sont générées et stockées exclusivement sur votre appareil. Personne — y compris les développeurs — ne peut lire vos messages.';

  @override
  String get privacyNetworkHeading => 'Architecture réseau';

  @override
  String get privacyNetworkBody =>
      'Pulse utilise des adaptateurs de transport fédérés (relais Nostr, nœuds de service Session/Oxen, Firebase Realtime Database, LAN). Ces transports ne véhiculent que du texte chiffré. Les opérateurs de relais peuvent voir votre adresse IP et le volume de trafic, mais ne peuvent pas déchiffrer le contenu des messages.\n\nLorsque Tor est activé, votre adresse IP est également masquée aux opérateurs de relais.';

  @override
  String get privacyStunHeading => 'Serveurs STUN/TURN';

  @override
  String get privacyStunBody =>
      'Les appels vocaux et vidéo utilisent WebRTC avec chiffrement DTLS-SRTP. Les serveurs STUN (utilisés pour découvrir votre IP publique pour les connexions pair à pair) et les serveurs TURN (utilisés pour relayer les médias quand la connexion directe échoue) peuvent voir votre adresse IP et la durée de l\'appel, mais ne peuvent pas déchiffrer le contenu.\n\nVous pouvez configurer votre propre serveur TURN dans les Paramètres pour une confidentialité maximale.';

  @override
  String get privacyCrashHeading => 'Rapports de plantage';

  @override
  String get privacyCrashBody =>
      'Si les rapports de plantage Sentry sont activés (via SENTRY_DSN à la compilation), des rapports anonymes peuvent être envoyés. Ceux-ci ne contiennent aucun contenu de message, aucune information de contact et aucune donnée personnellement identifiable. Les rapports de plantage peuvent être désactivés à la compilation en omettant le DSN.';

  @override
  String get privacyPasswordHeading => 'Mot de passe & Clés';

  @override
  String get privacyPasswordBody =>
      'Votre mot de passe de récupération est utilisé pour dériver les clés cryptographiques via Argon2id (KDF résistant à la mémoire). Le mot de passe n\'est jamais transmis nulle part. Si vous perdez votre mot de passe, votre compte ne pourra pas être récupéré — il n\'y a pas de serveur pour le réinitialiser.';

  @override
  String get privacyFontsHeading => 'Polices';

  @override
  String get privacyFontsBody =>
      'Pulse inclut toutes les polices localement. Aucune requête n\'est faite à Google Fonts ou à un service de polices externe.';

  @override
  String get privacyThirdPartyHeading => 'Services tiers';

  @override
  String get privacyThirdPartyBody =>
      'Pulse ne s\'intègre à aucun réseau publicitaire, fournisseur d\'analyse, plateforme de médias sociaux ou courtier en données. Les seules connexions réseau sont vers les relais de transport que vous configurez.';

  @override
  String get privacyOpenSourceHeading => 'Open Source';

  @override
  String get privacyOpenSourceBody =>
      'Pulse est un logiciel open source. Vous pouvez auditer le code source complet pour vérifier ces engagements de confidentialité.';

  @override
  String get privacyContactHeading => 'Contact';

  @override
  String get privacyContactBody =>
      'Pour les questions relatives à la confidentialité, ouvrez un ticket sur le dépôt du projet.';

  @override
  String get privacyLastUpdated => 'Dernière mise à jour : mars 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Échec de l\'enregistrement : $error';
  }

  @override
  String get themeEngineTitle => 'Moteur de thème';

  @override
  String get torBuiltInTitle => 'Tor intégré';

  @override
  String get torConnectedSubtitle =>
      'Connecté — Nostr routé via 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Connexion… $pct %';
  }

  @override
  String get torNotRunning => 'Inactif — appuyez pour redémarrer';

  @override
  String get torDescription =>
      'Route Nostr via Tor (Snowflake pour les réseaux censurés)';

  @override
  String get torNetworkDiagnostics => 'Diagnostics réseau';

  @override
  String get torTransportLabel => 'Transport : ';

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
  String get torTimeoutLabel => 'Délai d\'attente : ';

  @override
  String get torInfoDescription =>
      'Lorsqu\'il est activé, les connexions WebSocket Nostr sont routées via Tor (SOCKS5). Tor Browser écoute sur 127.0.0.1:9150. Le démon tor autonome utilise le port 9050. Les connexions Firebase ne sont pas affectées.';

  @override
  String get torRouteNostrTitle => 'Router Nostr via Tor';

  @override
  String get torManagedByBuiltin => 'Géré par Tor intégré';

  @override
  String get torActiveRouting => 'Actif — trafic Nostr routé via Tor';

  @override
  String get torDisabled => 'Désactivé';

  @override
  String get torProxySocks5 => 'Proxy Tor (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Hôte du proxy';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser : port 9150  •  démon tor : port 9050';

  @override
  String get i2pProxySocks5 => 'Proxy I2P (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P utilise SOCKS5 sur le port 4447 par défaut. Connectez-vous à un relais Nostr via le outproxy I2P (ex. relay.damus.i2p) pour communiquer avec des utilisateurs sur n\'importe quel transport. Tor a la priorité quand les deux sont activés.';

  @override
  String get i2pRouteNostrTitle => 'Router Nostr via I2P';

  @override
  String get i2pActiveRouting => 'Actif — trafic Nostr routé via I2P';

  @override
  String get i2pDisabled => 'Désactivé';

  @override
  String get i2pProxyHostLabel => 'Hôte du proxy';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'Port SOCKS5 par défaut du routeur I2P : 4447';

  @override
  String get customProxySocks5 => 'Proxy personnalisé (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'Relais CF Worker';

  @override
  String get customProxyInfoDescription =>
      'Le proxy personnalisé route le trafic via votre V2Ray/Xray/Shadowsocks. Le CF Worker agit comme un relais proxy personnel sur le CDN Cloudflare — le GFW voit *.workers.dev, pas le vrai relais.';

  @override
  String get customSocks5ProxyTitle => 'Proxy SOCKS5 personnalisé';

  @override
  String get customProxyActive => 'Actif — trafic routé via SOCKS5';

  @override
  String get customProxyDisabled => 'Désactivé';

  @override
  String get customProxyHostLabel => 'Hôte du proxy';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray : 127.0.0.1:10808  •  Shadowsocks : 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Domaine Worker (optionnel)';

  @override
  String get customWorkerHelpTitle =>
      'Comment déployer un relais CF Worker (gratuit)';

  @override
  String get customWorkerScriptCopied => 'Script copié !';

  @override
  String get customWorkerStep1 =>
      '1. Allez sur dash.cloudflare.com → Workers & Pages\n2. Create Worker → collez ce script :\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → copiez le domaine (ex. my-relay.user.workers.dev)\n4. Collez le domaine ci-dessus → Enregistrer\n\nL\'application se connecte automatiquement : wss://domain/?r=relay_url\nLe GFW voit : connexion à *.workers.dev (CDN CF)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Connecté — SOCKS5 sur 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Connexion…';

  @override
  String get psiphonNotRunning => 'Inactif — appuyez pour redémarrer';

  @override
  String get psiphonDescription =>
      'Tunnel rapide (~3s d\'amorçage, 2000+ VPS en rotation)';

  @override
  String get turnCommunityServers => 'Serveurs TURN communautaires';

  @override
  String get turnCustomServer => 'Serveur TURN personnalisé (BYOD)';

  @override
  String get turnInfoDescription =>
      'Les serveurs TURN ne relaient que des flux déjà chiffrés (DTLS-SRTP). Un opérateur de relais voit votre IP et le volume de trafic, mais ne peut pas déchiffrer les appels. TURN n\'est utilisé que lorsque le P2P direct échoue (~15–20 % des connexions).';

  @override
  String get turnFreeLabel => 'GRATUIT';

  @override
  String get turnServerUrlLabel => 'URL du serveur TURN';

  @override
  String get turnServerUrlHint => 'turn:votre-serveur.com:3478 ou turns:...';

  @override
  String get turnUsernameLabel => 'Nom d\'utilisateur';

  @override
  String get turnPasswordLabel => 'Mot de passe';

  @override
  String get turnOptionalHint => 'Optionnel';

  @override
  String get turnCustomInfo =>
      'Hébergez coturn sur n\'importe quel VPS à 5\$/mois pour un contrôle maximal. Les identifiants sont stockés localement.';

  @override
  String get themePickerAppearance => 'Apparence';

  @override
  String get themePickerAccentColor => 'Couleur d\'accentuation';

  @override
  String get themeModeLight => 'Clair';

  @override
  String get themeModeDark => 'Sombre';

  @override
  String get themeModeSystem => 'Système';

  @override
  String get themeDynamicPresets => 'Préréglages';

  @override
  String get themeDynamicPrimaryColor => 'Couleur principale';

  @override
  String get themeDynamicBorderRadius => 'Rayon de bordure';

  @override
  String get themeDynamicFont => 'Police';

  @override
  String get themeDynamicAppearance => 'Apparence';

  @override
  String get themeDynamicUiStyle => 'Style d\'interface';

  @override
  String get themeDynamicUiStyleDescription =>
      'Contrôle l\'apparence des dialogues, interrupteurs et indicateurs.';

  @override
  String get themeDynamicSharp => 'Anguleux';

  @override
  String get themeDynamicRound => 'Arrondi';

  @override
  String get themeDynamicModeDark => 'Sombre';

  @override
  String get themeDynamicModeLight => 'Clair';

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
      'URL Firebase invalide. Attendu : https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'URL de relais invalide. Attendu : wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'URL du serveur Pulse invalide. Attendu : https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'URL du serveur';

  @override
  String get providerPulseServerUrlHint => 'https://votre-serveur:8443';

  @override
  String get providerPulseInviteLabel => 'Code d\'invitation';

  @override
  String get providerPulseInviteHint => 'Code d\'invitation (si requis)';

  @override
  String get providerPulseInfo =>
      'Relais auto-hébergé. Clés dérivées de votre mot de passe de récupération.';

  @override
  String get providerScreenTitle => 'Boîtes de réception';

  @override
  String get providerSecondaryInboxesHeader =>
      'BOÎTES DE RÉCEPTION SECONDAIRES';

  @override
  String get providerSecondaryInboxesInfo =>
      'Les boîtes secondaires reçoivent les messages simultanément pour la redondance.';

  @override
  String get providerRemoveTooltip => 'Supprimer';

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
  String get emojiNoRecent => 'Aucun émoji récent';

  @override
  String get emojiSearchHint => 'Rechercher un émoji...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Appuyez pour discuter';

  @override
  String get imageViewerSaveToDownloads => 'Enregistrer dans Téléchargements';

  @override
  String imageViewerSavedTo(String path) {
    return 'Enregistré dans $path';
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

  @override
  String get videoNoteRecord => 'Enregistrer un message vidéo';

  @override
  String get videoNoteTapToRecord => 'Appuyez pour enregistrer';

  @override
  String get videoNoteTapToStop => 'Appuyez pour arrêter';

  @override
  String get videoNoteCameraPermission => 'Permission caméra refusée';

  @override
  String get videoNoteMaxDuration => 'Maximum 30 secondes';

  @override
  String get videoNoteNotSupported =>
      'Les notes vidéo ne sont pas prises en charge sur cette plateforme';

  @override
  String get navChats => 'Chats';

  @override
  String get navUpdates => 'Updates';

  @override
  String get navCalls => 'Calls';

  @override
  String get filterAll => 'All';

  @override
  String get filterUnread => 'Unread';

  @override
  String get filterGroups => 'Groups';

  @override
  String get callsNoRecent => 'No recent calls';

  @override
  String get callsEmptySubtitle => 'Your call history will appear here';

  @override
  String get appBarEncrypted => 'end-to-end encrypted';

  @override
  String get newStatus => 'New status';

  @override
  String get newCall => 'New call';
}
