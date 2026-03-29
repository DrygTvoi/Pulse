// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Filipino Pilipino (`fil`).
class AppLocalizationsFil extends AppLocalizations {
  AppLocalizationsFil([String locale = 'fil']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Maghanap ng mga mensahe...';

  @override
  String get search => 'Hanapin';

  @override
  String get clearSearch => 'Burahin ang paghahanap';

  @override
  String get closeSearch => 'Isara ang paghahanap';

  @override
  String get moreOptions => 'Iba pang mga opsyon';

  @override
  String get back => 'Bumalik';

  @override
  String get cancel => 'Kanselahin';

  @override
  String get close => 'Isara';

  @override
  String get confirm => 'Kumpirmahin';

  @override
  String get remove => 'Alisin';

  @override
  String get save => 'I-save';

  @override
  String get add => 'Idagdag';

  @override
  String get copy => 'Kopyahin';

  @override
  String get skip => 'Laktawan';

  @override
  String get done => 'Tapos na';

  @override
  String get apply => 'Ilapat';

  @override
  String get export => 'I-export';

  @override
  String get import => 'I-import';

  @override
  String get homeNewGroup => 'Bagong grupo';

  @override
  String get homeSettings => 'Mga setting';

  @override
  String get homeSearching => 'Naghahanap ng mga mensahe...';

  @override
  String get homeNoResults => 'Walang resulta';

  @override
  String get homeNoChatHistory => 'Wala pang history ng chat';

  @override
  String homeTransportSwitched(String address) {
    return 'Lumipat ang transport → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return 'Tumatawag si $name...';
  }

  @override
  String get homeAccept => 'Tanggapin';

  @override
  String get homeDecline => 'Tanggihan';

  @override
  String get homeLoadEarlier => 'I-load ang mga naunang mensahe';

  @override
  String get homeChats => 'Mga chat';

  @override
  String get homeSelectConversation => 'Pumili ng usapan';

  @override
  String get homeNoChatsYet => 'Wala pang mga chat';

  @override
  String get homeAddContactToStart =>
      'Magdagdag ng contact para magsimulang mag-chat';

  @override
  String get homeNewChat => 'Bagong Chat';

  @override
  String get homeNewChatTooltip => 'Bagong chat';

  @override
  String get homeIncomingCallTitle => 'Papasok na Tawag';

  @override
  String get homeIncomingGroupCallTitle => 'Papasok na Group Call';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — papasok na group call';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Walang chat na tumutugma sa \"$query\"';
  }

  @override
  String get homeSectionChats => 'Mga Chat';

  @override
  String get homeSectionMessages => 'Mga Mensahe';

  @override
  String get homeDbEncryptionUnavailable =>
      'Hindi available ang database encryption — i-install ang SQLCipher para sa kumpletong proteksyon';

  @override
  String get chatFileTooLargeGroup =>
      'Ang mga file na higit sa 512 KB ay hindi sinusuportahan sa group chat';

  @override
  String get chatLargeFile => 'Malaking File';

  @override
  String get chatCancel => 'Kanselahin';

  @override
  String get chatSend => 'Ipadala';

  @override
  String get chatFileTooLarge =>
      'Masyadong malaki ang file — maximum na laki ay 100 MB';

  @override
  String get chatMicDenied => 'Tinanggihan ang pahintulot sa mikropono';

  @override
  String get chatVoiceFailed =>
      'Hindi nai-save ang voice message — suriin ang available na storage';

  @override
  String get chatScheduleFuture =>
      'Ang naka-schedule na oras ay dapat sa hinaharap';

  @override
  String get chatToday => 'Ngayon';

  @override
  String get chatYesterday => 'Kahapon';

  @override
  String get chatEdited => 'in-edit';

  @override
  String get chatYou => 'Ikaw';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Ang file na ito ay $size MB. Maaaring mabagal ang pagpapadala ng malalaking file sa ilang network. Ipagpatuloy?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Nagbago ang security key ni $name. I-tap para i-verify.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Hindi na-encrypt ang mensahe kay $name — hindi naipadala ang mensahe.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Nagbago ang safety number para kay $name. I-tap para i-verify.';
  }

  @override
  String get chatNoMessagesFound => 'Walang nahanap na mensahe';

  @override
  String get chatMessagesE2ee => 'Ang mga mensahe ay end-to-end encrypted';

  @override
  String get chatSayHello => 'Kumusta';

  @override
  String get appBarOnline => 'online';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'nagta-type';

  @override
  String get appBarSearchMessages => 'Maghanap ng mga mensahe...';

  @override
  String get appBarMute => 'I-mute';

  @override
  String get appBarUnmute => 'I-unmute';

  @override
  String get appBarMedia => 'Media';

  @override
  String get appBarDisappearing => 'Nawawalang mga mensahe';

  @override
  String get appBarDisappearingOn => 'Nawawala: naka-on';

  @override
  String get appBarGroupSettings => 'Mga setting ng grupo';

  @override
  String get appBarSearchTooltip => 'Maghanap ng mga mensahe';

  @override
  String get appBarVoiceCall => 'Voice call';

  @override
  String get appBarVideoCall => 'Video call';

  @override
  String get inputMessage => 'Mensahe...';

  @override
  String get inputAttachFile => 'Mag-attach ng file';

  @override
  String get inputSendMessage => 'Ipadala ang mensahe';

  @override
  String get inputRecordVoice => 'Mag-record ng voice message';

  @override
  String get inputSendVoice => 'Ipadala ang voice message';

  @override
  String get inputCancelReply => 'Kanselahin ang reply';

  @override
  String get inputCancelEdit => 'Kanselahin ang pag-edit';

  @override
  String get inputCancelRecording => 'Kanselahin ang recording';

  @override
  String get inputRecording => 'Nagre-record…';

  @override
  String get inputEditingMessage => 'Ine-edit ang mensahe';

  @override
  String get inputPhoto => 'Litrato';

  @override
  String get inputVoiceMessage => 'Voice message';

  @override
  String get inputFile => 'File';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count naka-schedule na mensahe$_temp0';
  }

  @override
  String get callInitializing => 'Sinisimulan ang tawag…';

  @override
  String get callConnecting => 'Kumokonekta…';

  @override
  String get callConnectingRelay => 'Kumokonekta (relay)…';

  @override
  String get callSwitchingRelay => 'Lumilipat sa relay mode…';

  @override
  String get callConnectionFailed => 'Nabigo ang koneksyon';

  @override
  String get callReconnecting => 'Muling kumokonekta…';

  @override
  String get callEnded => 'Natapos ang tawag';

  @override
  String get callLive => 'Live';

  @override
  String get callEnd => 'Tapusin';

  @override
  String get callEndCall => 'Tapusin ang tawag';

  @override
  String get callMute => 'I-mute';

  @override
  String get callUnmute => 'I-unmute';

  @override
  String get callSpeaker => 'Speaker';

  @override
  String get callCameraOn => 'Camera Naka-on';

  @override
  String get callCameraOff => 'Camera Naka-off';

  @override
  String get callShareScreen => 'Ibahagi ang Screen';

  @override
  String get callStopShare => 'Itigil ang Pagbahagi';

  @override
  String callTorBackup(String duration) {
    return 'Tor backup · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Aktibo ang Tor backup — hindi available ang pangunahing path';

  @override
  String get callDirectFailed =>
      'Nabigo ang direktang koneksyon — lumilipat sa relay mode…';

  @override
  String get callTurnUnreachable =>
      'Hindi maabot ang TURN servers. Magdagdag ng custom na TURN sa Settings → Advanced.';

  @override
  String get callRelayMode => 'Aktibo ang relay mode (restricted network)';

  @override
  String get callStarting => 'Sinisimulan ang tawag…';

  @override
  String get callConnectingToGroup => 'Kumokonekta sa grupo…';

  @override
  String get callGroupOpenedInBrowser => 'Binuksan ang group call sa browser';

  @override
  String get callCouldNotOpenBrowser => 'Hindi mabuksan ang browser';

  @override
  String get callInviteLinkSent =>
      'Naipadala ang invite link sa lahat ng miyembro ng grupo.';

  @override
  String get callOpenLinkManually =>
      'Buksan ang link sa itaas nang manu-mano o i-tap para subukang muli.';

  @override
  String get callJitsiNotE2ee =>
      'Ang mga Jitsi call ay HINDI end-to-end encrypted';

  @override
  String get callRetryOpenBrowser => 'Subukang muli ang pagbukas ng browser';

  @override
  String get callClose => 'Isara';

  @override
  String get callCamOn => 'Cam naka-on';

  @override
  String get callCamOff => 'Cam naka-off';

  @override
  String get noConnection => 'Walang koneksyon — makapila ang mga mensahe';

  @override
  String get connected => 'Konektado';

  @override
  String get connecting => 'Kumokonekta…';

  @override
  String get disconnected => 'Hindi konektado';

  @override
  String get offlineBanner =>
      'Walang koneksyon — ipapadala ang mga mensahe kapag bumalik online';

  @override
  String get lanModeBanner =>
      'LAN Mode — Walang internet · Lokal na network lamang';

  @override
  String get probeCheckingNetwork => 'Sinusuri ang koneksyon sa network…';

  @override
  String get probeDiscoveringRelays =>
      'Naghahanap ng mga relay sa pamamagitan ng community directory…';

  @override
  String get probeStartingTor => 'Sinisimulan ang Tor para sa bootstrap…';

  @override
  String get probeFindingRelaysTor =>
      'Naghahanap ng mga maabot na relay sa pamamagitan ng Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'Handa na ang network — $count relay$_temp0 ang nahanap';
  }

  @override
  String get probeNoRelaysFound =>
      'Walang nahanap na maabot na relay — maaaring madelay ang mga mensahe';

  @override
  String get jitsiWarningTitle => 'Hindi end-to-end encrypted';

  @override
  String get jitsiWarningBody =>
      'Ang mga Jitsi Meet call ay hindi naka-encrypt ng Pulse. Gamitin lamang para sa hindi sensitibong usapan.';

  @override
  String get jitsiConfirm => 'Sumali pa rin';

  @override
  String get jitsiGroupWarningTitle => 'Hindi end-to-end encrypted';

  @override
  String get jitsiGroupWarningBody =>
      'Masyadong maraming kalahok ang call na ito para sa built-in na encrypted mesh.\n\nIsang Jitsi Meet link ang bubuksan sa iyong browser. Ang Jitsi ay HINDI end-to-end encrypted — makikita ng server ang iyong tawag.';

  @override
  String get jitsiContinueAnyway => 'Ipagpatuloy pa rin';

  @override
  String get retry => 'Subukang muli';

  @override
  String get setupCreateAnonymousAccount => 'Gumawa ng anonymous na account';

  @override
  String get setupTapToChangeColor => 'I-tap para palitan ang kulay';

  @override
  String get setupReqMinLength => 'At least 16 characters';

  @override
  String get setupReqVariety => '3 of 4: uppercase, lowercase, digits, symbols';

  @override
  String get setupReqMatch => 'Passwords match';

  @override
  String get setupYourNickname => 'Ang iyong palayaw';

  @override
  String get setupRecoveryPassword => 'Recovery password (min. 16)';

  @override
  String get setupConfirmPassword => 'Kumpirmahin ang password';

  @override
  String get setupMin16Chars => 'Minimum na 16 na karakter';

  @override
  String get setupPasswordsDoNotMatch => 'Hindi magkatugma ang mga password';

  @override
  String get setupEntropyWeak => 'Mahina';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Malakas';

  @override
  String get setupEntropyWeakNeedsVariety =>
      'Mahina (kailangan ng 3 uri ng karakter)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bits)';
  }

  @override
  String get setupPasswordWarning =>
      'Ang password na ito ang tanging paraan para maibalik ang iyong account. Walang server — walang password reset. Tandaan ito o isulat.';

  @override
  String get setupCreateAccount => 'Gumawa ng account';

  @override
  String get setupAlreadyHaveAccount => 'Mayroon nang account? ';

  @override
  String get setupRestore => 'Ibalik →';

  @override
  String get restoreTitle => 'Ibalik ang account';

  @override
  String get restoreInfoBanner =>
      'Ilagay ang iyong recovery password — awtomatikong maibabalik ang iyong address (Nostr + Session). Ang mga contact at mensahe ay lokal lamang na naka-store.';

  @override
  String get restoreNewNickname => 'Bagong palayaw (mababago mamaya)';

  @override
  String get restoreButton => 'Ibalik ang account';

  @override
  String get lockTitle => 'Naka-lock ang Pulse';

  @override
  String get lockSubtitle => 'Ilagay ang iyong password para magpatuloy';

  @override
  String get lockPasswordHint => 'Password';

  @override
  String get lockUnlock => 'I-unlock';

  @override
  String get lockPanicHint =>
      'Nakalimutan ang password? Ilagay ang iyong panic key para burahin ang lahat ng data.';

  @override
  String get lockTooManyAttempts =>
      'Masyadong maraming pagsubok. Binubura ang lahat ng data…';

  @override
  String get lockWrongPassword => 'Maling password';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Maling password — $attempts/$max na pagsubok';
  }

  @override
  String get onboardingSkip => 'Laktawan';

  @override
  String get onboardingNext => 'Susunod';

  @override
  String get onboardingGetStarted => 'Magsimula';

  @override
  String get onboardingWelcomeTitle => 'Maligayang pagdating sa Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Isang desentralisado at end-to-end encrypted na messenger.\n\nWalang sentral na server. Walang pangongolekta ng data. Walang backdoor.\nAng iyong mga usapan ay sa iyo lamang.';

  @override
  String get onboardingTransportTitle => 'Transport-Agnostic';

  @override
  String get onboardingTransportBody =>
      'Gamitin ang Firebase, Nostr, o pareho nang sabay.\n\nAwtomatikong nire-route ang mga mensahe sa mga network. May built-in na Tor at I2P na suporta para sa censorship resistance.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Ang bawat mensahe ay naka-encrypt gamit ang Signal Protocol (Double Ratchet + X3DH) para sa forward secrecy.\n\nDagdag pa, binalot ng Kyber-1024 — isang NIST-standard na post-quantum algorithm — na nagpoprotekta laban sa mga quantum computer sa hinaharap.';

  @override
  String get onboardingKeysTitle => 'Ikaw ang May-ari ng Iyong mga Key';

  @override
  String get onboardingKeysBody =>
      'Ang iyong mga identity key ay hindi kailanman aalis sa iyong device.\n\nAng Signal fingerprint ay nagbibigay-daan para i-verify ang mga contact nang out-of-band. Awtomatikong nadedetect ng TOFU (Trust On First Use) ang mga pagbabago ng key.';

  @override
  String get onboardingThemeTitle => 'Piliin ang Iyong Hitsura';

  @override
  String get onboardingThemeBody =>
      'Pumili ng tema at accent color. Mababago mo ito anumang oras sa Settings.';

  @override
  String get contactsNewChat => 'Bagong chat';

  @override
  String get contactsAddContact => 'Magdagdag ng contact';

  @override
  String get contactsSearchHint => 'Hanapin...';

  @override
  String get contactsNewGroup => 'Bagong grupo';

  @override
  String get contactsNoContactsYet => 'Wala pang mga contact';

  @override
  String get contactsAddHint => 'I-tap ang + para magdagdag ng address';

  @override
  String get contactsNoMatch => 'Walang tumutugmang contact';

  @override
  String get contactsRemoveTitle => 'Alisin ang contact';

  @override
  String contactsRemoveMessage(String name) {
    return 'Alisin si $name?';
  }

  @override
  String get contactsRemove => 'Alisin';

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
  String get bubbleOpenLink => 'Buksan ang Link';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Buksan ang URL na ito sa iyong browser?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Buksan';

  @override
  String get bubbleSecurityWarning => 'Babala sa Seguridad';

  @override
  String bubbleExecutableWarning(String name) {
    return 'Ang \"$name\" ay isang executable file type. Ang pag-save at pagpapatakbo nito ay maaaring makapinsala sa iyong device. I-save pa rin?';
  }

  @override
  String get bubbleSaveAnyway => 'I-save Pa Rin';

  @override
  String bubbleSavedTo(String path) {
    return 'Na-save sa $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Nabigo ang pag-save: $error';
  }

  @override
  String get bubbleNotEncrypted => 'HINDI ENCRYPTED';

  @override
  String get bubbleCorruptedImage => '[Sirang imahe]';

  @override
  String get bubbleReplyPhoto => 'Litrato';

  @override
  String get bubbleReplyVoice => 'Voice message';

  @override
  String get bubbleReplyVideo => 'Video message';

  @override
  String bubbleReadBy(String names) {
    return 'Nabasa ni $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Nabasa ng $count';
  }

  @override
  String get chatTileTapToStart => 'I-tap para magsimulang mag-chat';

  @override
  String get chatTileMessageSent => 'Naipadala ang mensahe';

  @override
  String get chatTileEncryptedMessage => 'Encrypted na mensahe';

  @override
  String chatTileYouPrefix(String text) {
    return 'Ikaw: $text';
  }

  @override
  String get bannerEncryptedMessage => 'Encrypted na mensahe';

  @override
  String get groupNewGroup => 'Bagong Grupo';

  @override
  String get groupGroupName => 'Pangalan ng grupo';

  @override
  String get groupSelectMembers => 'Pumili ng mga miyembro (min 2)';

  @override
  String get groupNoContactsYet =>
      'Wala pang mga contact. Magdagdag muna ng mga contact.';

  @override
  String get groupCreate => 'Gumawa';

  @override
  String get groupLabel => 'Grupo';

  @override
  String get profileVerifyIdentity => 'I-verify ang Pagkakakilanlan';

  @override
  String profileVerifyInstructions(String name) {
    return 'Ikumpara ang mga fingerprint na ito kay $name sa isang voice call o nang personal. Kung magkatugma ang parehong halaga sa parehong device, i-tap ang \"Markahan bilang Verified\".';
  }

  @override
  String get profileTheirKey => 'Kanilang key';

  @override
  String get profileYourKey => 'Iyong key';

  @override
  String get profileRemoveVerification => 'Alisin ang Verification';

  @override
  String get profileMarkAsVerified => 'Markahan bilang Verified';

  @override
  String get profileAddressCopied => 'Nakopya ang address';

  @override
  String get profileNoContactsToAdd =>
      'Walang contact na maidadagdag — lahat ay miyembro na';

  @override
  String get profileAddMembers => 'Magdagdag ng mga Miyembro';

  @override
  String profileAddCount(int count) {
    return 'Idagdag ($count)';
  }

  @override
  String get profileRenameGroup => 'Palitan ang Pangalan ng Grupo';

  @override
  String get profileRename => 'Palitan ang pangalan';

  @override
  String get profileRemoveMember => 'Alisin ang miyembro?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Alisin si $name sa grupong ito?';
  }

  @override
  String get profileKick => 'Paalisin';

  @override
  String get profileSignalFingerprints => 'Signal Fingerprints';

  @override
  String get profileVerified => 'VERIFIED';

  @override
  String get profileVerify => 'I-verify';

  @override
  String get profileEdit => 'I-edit';

  @override
  String get profileNoSession =>
      'Wala pang session na naitatag — magpadala muna ng mensahe.';

  @override
  String get profileFingerprintCopied => 'Nakopya ang fingerprint';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count miyembro$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'I-verify ang Safety Number';

  @override
  String get profileShowContactQr => 'Ipakita ang Contact QR';

  @override
  String profileContactAddress(String name) {
    return 'Address ni $name';
  }

  @override
  String get profileExportChatHistory => 'I-export ang Chat History';

  @override
  String profileSavedTo(String path) {
    return 'Na-save sa $path';
  }

  @override
  String get profileExportFailed => 'Nabigo ang pag-export';

  @override
  String get profileClearChatHistory => 'Burahin ang chat history';

  @override
  String get profileDeleteGroup => 'Burahin ang grupo';

  @override
  String get profileDeleteContact => 'Burahin ang contact';

  @override
  String get profileLeaveGroup => 'Umalis sa grupo';

  @override
  String get profileLeaveGroupBody =>
      'Aalisin ka sa grupong ito at mabubura ito sa iyong mga contact.';

  @override
  String get groupInviteTitle => 'Imbitasyon sa grupo';

  @override
  String groupInviteBody(String from, String group) {
    return 'Inimbitahan ka ni $from na sumali sa \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Tanggapin';

  @override
  String get groupInviteDecline => 'Tanggihan';

  @override
  String get groupMemberLimitTitle => 'Masyadong maraming kalahok';

  @override
  String groupMemberLimitBody(int count) {
    return 'Ang grupong ito ay magkakaroon ng $count na kalahok. Ang encrypted mesh call ay sumusuporta ng hanggang 6. Ang mas malalaking grupo ay lilipat sa Jitsi (hindi E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Idagdag pa rin';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return 'Tinanggihan ni $name ang pagsali sa \"$group\"';
  }

  @override
  String get transferTitle => 'Ilipat sa Ibang Device';

  @override
  String get transferInfoBox =>
      'Ilipat ang iyong Signal identity at Nostr key sa bagong device.\nAng mga chat session ay HINDI ililipat — nananatili ang forward secrecy.';

  @override
  String get transferSendFromThis => 'Ipadala mula sa device na ito';

  @override
  String get transferSendSubtitle =>
      'Ang device na ito ang may mga key. Ibahagi ang code sa bagong device.';

  @override
  String get transferReceiveOnThis => 'Tanggapin sa device na ito';

  @override
  String get transferReceiveSubtitle =>
      'Ito ang bagong device. Ilagay ang code mula sa lumang device.';

  @override
  String get transferChooseMethod => 'Pumili ng Paraan ng Paglilipat';

  @override
  String get transferLan => 'LAN (Parehong Network)';

  @override
  String get transferLanSubtitle =>
      'Mabilis at direkta. Ang parehong device ay dapat nasa parehong Wi-Fi.';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'Gumagana sa anumang network gamit ang isang umiiral na Nostr relay.';

  @override
  String get transferRelayUrl => 'Relay URL';

  @override
  String get transferEnterCode => 'Ilagay ang Transfer Code';

  @override
  String get transferPasteCode => 'I-paste ang LAN:... o NOS:... code dito';

  @override
  String get transferConnect => 'Kumonekta';

  @override
  String get transferGenerating => 'Ginagawa ang transfer code…';

  @override
  String get transferShareCode => 'Ibahagi ang code na ito sa tatanggap:';

  @override
  String get transferCopyCode => 'Kopyahin ang Code';

  @override
  String get transferCodeCopied => 'Nakopya ang code sa clipboard';

  @override
  String get transferWaitingReceiver =>
      'Naghihintay na kumonekta ang tatanggap…';

  @override
  String get transferConnectingSender => 'Kumokonekta sa nagpadala…';

  @override
  String get transferVerifyBoth =>
      'Ikumpara ang code na ito sa parehong device.\nKung magkatugma, ligtas ang paglilipat.';

  @override
  String get transferComplete => 'Kumpleto na ang Paglilipat';

  @override
  String get transferKeysImported => 'Na-import ang mga Key';

  @override
  String get transferCompleteSenderBody =>
      'Nananatiling aktibo ang iyong mga key sa device na ito.\nMaaari nang gamitin ng tatanggap ang iyong pagkakakilanlan.';

  @override
  String get transferCompleteReceiverBody =>
      'Matagumpay na na-import ang mga key.\nI-restart ang app para ilapat ang bagong pagkakakilanlan.';

  @override
  String get transferRestartApp => 'I-restart ang App';

  @override
  String get transferFailed => 'Nabigo ang Paglilipat';

  @override
  String get transferTryAgain => 'Subukang Muli';

  @override
  String get transferEnterRelayFirst => 'Maglagay muna ng relay URL';

  @override
  String get transferPasteCodeFromSender =>
      'I-paste ang transfer code mula sa nagpadala';

  @override
  String get menuReply => 'Sagutin';

  @override
  String get menuForward => 'I-forward';

  @override
  String get menuReact => 'Mag-react';

  @override
  String get menuCopy => 'Kopyahin';

  @override
  String get menuEdit => 'I-edit';

  @override
  String get menuRetry => 'Subukang muli';

  @override
  String get menuCancelScheduled => 'Kanselahin ang naka-schedule';

  @override
  String get menuDelete => 'Burahin';

  @override
  String get menuForwardTo => 'I-forward sa…';

  @override
  String menuForwardedTo(String name) {
    return 'Na-forward kay $name';
  }

  @override
  String get menuScheduledMessages => 'Mga naka-schedule na mensahe';

  @override
  String get menuNoScheduledMessages => 'Walang naka-schedule na mensahe';

  @override
  String menuSendsOn(String date) {
    return 'Ipapadala sa $date';
  }

  @override
  String get menuDisappearingMessages => 'Nawawalang mga Mensahe';

  @override
  String get menuDisappearingSubtitle =>
      'Awtomatikong nababura ang mga mensahe pagkatapos ng napiling oras.';

  @override
  String get menuTtlOff => 'Off';

  @override
  String get menuTtl1h => '1 oras';

  @override
  String get menuTtl24h => '24 na oras';

  @override
  String get menuTtl7d => '7 araw';

  @override
  String get menuAttachPhoto => 'Litrato';

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
    return 'Mga Litrato ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Mga File ($count)';
  }

  @override
  String get mediaNoPhotos => 'Wala pang mga litrato';

  @override
  String get mediaNoFiles => 'Wala pang mga file';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Na-save sa Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'Hindi nai-save ang file';

  @override
  String get statusNewStatus => 'Bagong Status';

  @override
  String get statusPublish => 'I-publish';

  @override
  String get statusExpiresIn24h =>
      'Mag-e-expire ang status sa loob ng 24 na oras';

  @override
  String get statusWhatsOnYourMind => 'Ano ang iniisip mo?';

  @override
  String get statusPhotoAttached => 'May nakakabit na litrato';

  @override
  String get statusAttachPhoto => 'Mag-attach ng litrato (opsyonal)';

  @override
  String get statusEnterText =>
      'Mangyaring maglagay ng teksto para sa iyong status.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Hindi napili ang litrato: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Nabigo ang pag-publish: $error';
  }

  @override
  String get panicSetPanicKey => 'Itakda ang Panic Key';

  @override
  String get panicEmergencySelfDestruct => 'Emergency self-destruct';

  @override
  String get panicIrreversible => 'Ang aksyong ito ay hindi na mababawi';

  @override
  String get panicWarningBody =>
      'Ang paglalagay ng key na ito sa lock screen ay agad na magbubura ng LAHAT ng data — mga mensahe, contact, key, pagkakakilanlan. Gumamit ng key na iba sa iyong regular na password.';

  @override
  String get panicKeyHint => 'Panic key';

  @override
  String get panicConfirmHint => 'Kumpirmahin ang panic key';

  @override
  String get panicMinChars =>
      'Ang panic key ay dapat hindi bababa sa 8 karakter';

  @override
  String get panicKeysDoNotMatch => 'Hindi magkatugma ang mga key';

  @override
  String get panicSetFailed =>
      'Hindi nai-save ang panic key — pakisubukang muli';

  @override
  String get passwordSetAppPassword => 'Itakda ang App Password';

  @override
  String get passwordProtectsMessages =>
      'Pinoprotektahan ang iyong mga mensahe habang nakatago';

  @override
  String get passwordInfoBanner =>
      'Kinakailangan sa tuwing bubuksan mo ang Pulse. Kung makalimutan, hindi na maibabalik ang iyong data.';

  @override
  String get passwordHint => 'Password';

  @override
  String get passwordConfirmHint => 'Kumpirmahin ang password';

  @override
  String get passwordSetButton => 'Itakda ang Password';

  @override
  String get passwordSkipForNow => 'Laktawan muna';

  @override
  String get passwordMinChars =>
      'Ang password ay dapat hindi bababa sa 6 na karakter';

  @override
  String get passwordsDoNotMatch => 'Hindi magkatugma ang mga password';

  @override
  String get profileCardSaved => 'Na-save ang profile!';

  @override
  String get profileCardE2eeIdentity => 'E2EE Identity';

  @override
  String get profileCardDisplayName => 'Display Name';

  @override
  String get profileCardDisplayNameHint => 'hal. Juan dela Cruz';

  @override
  String get profileCardAbout => 'Tungkol';

  @override
  String get profileCardSaveProfile => 'I-save ang Profile';

  @override
  String get profileCardYourName => 'Ang Iyong Pangalan';

  @override
  String get profileCardAddressCopied => 'Nakopya ang address!';

  @override
  String get profileCardInboxAddress => 'Ang Iyong Inbox Address';

  @override
  String get profileCardInboxAddresses => 'Ang Iyong mga Inbox Address';

  @override
  String get profileCardShareAllAddresses =>
      'Ibahagi ang Lahat ng Address (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Ibahagi sa mga contact para maka-message ka nila.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Lahat ng $count address ay nakopya bilang isang link!';
  }

  @override
  String get settingsMyProfile => 'Aking Profile';

  @override
  String get settingsYourInboxAddress => 'Ang Iyong Inbox Address';

  @override
  String get settingsMyQrCode => 'Aking QR Code';

  @override
  String get settingsMyQrSubtitle =>
      'Ibahagi ang iyong address bilang naka-scan na QR';

  @override
  String get settingsShareMyAddress => 'Ibahagi ang Aking Address';

  @override
  String get settingsNoAddressYet =>
      'Wala pang address — i-save muna ang mga setting';

  @override
  String get settingsInviteLink => 'Invite Link';

  @override
  String get settingsRawAddress => 'Raw Address';

  @override
  String get settingsCopyLink => 'Kopyahin ang Link';

  @override
  String get settingsCopyAddress => 'Kopyahin ang Address';

  @override
  String get settingsInviteLinkCopied => 'Nakopya ang invite link';

  @override
  String get settingsAppearance => 'Hitsura';

  @override
  String get settingsThemeEngine => 'Theme Engine';

  @override
  String get settingsThemeEngineSubtitle => 'I-customize ang mga kulay at font';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle =>
      'Ang mga E2EE key ay ligtas na naka-store';

  @override
  String get settingsActive => 'AKTIBO';

  @override
  String get settingsIdentityBackup => 'Identity Backup';

  @override
  String get settingsIdentityBackupSubtitle =>
      'I-export o i-import ang iyong Signal identity';

  @override
  String get settingsIdentityBackupBody =>
      'I-export ang iyong Signal identity key sa backup code, o i-restore mula sa umiiral na isa.';

  @override
  String get settingsTransferDevice => 'Ilipat sa Ibang Device';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Ilipat ang iyong pagkakakilanlan sa pamamagitan ng LAN o Nostr relay';

  @override
  String get settingsExportIdentity => 'I-export ang Identity';

  @override
  String get settingsExportIdentityBody =>
      'Kopyahin ang backup code na ito at itago nang ligtas:';

  @override
  String get settingsSaveFile => 'I-save ang File';

  @override
  String get settingsImportIdentity => 'I-import ang Identity';

  @override
  String get settingsImportIdentityBody =>
      'I-paste ang iyong backup code sa ibaba. Papalitan nito ang iyong kasalukuyang pagkakakilanlan.';

  @override
  String get settingsPasteBackupCode => 'I-paste ang backup code dito…';

  @override
  String get settingsIdentityImported =>
      'Na-import ang identity + mga contact! I-restart ang app para ilapat.';

  @override
  String get settingsSecurity => 'Seguridad';

  @override
  String get settingsAppPassword => 'App Password';

  @override
  String get settingsPasswordEnabled =>
      'Naka-enable — kinakailangan sa bawat pagsisimula';

  @override
  String get settingsPasswordDisabled =>
      'Naka-disable — bubukas ang app nang walang password';

  @override
  String get settingsChangePassword => 'Palitan ang Password';

  @override
  String get settingsChangePasswordSubtitle =>
      'I-update ang iyong app lock password';

  @override
  String get settingsSetPanicKey => 'Itakda ang Panic Key';

  @override
  String get settingsChangePanicKey => 'Palitan ang Panic Key';

  @override
  String get settingsPanicKeySetSubtitle => 'I-update ang emergency wipe key';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Isang key na agad na nagbubura ng lahat ng data';

  @override
  String get settingsRemovePanicKey => 'Alisin ang Panic Key';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'I-disable ang emergency self-destruct';

  @override
  String get settingsRemovePanicKeyBody =>
      'Idi-disable ang emergency self-destruct. Maaari mong i-enable muli ito anumang oras.';

  @override
  String get settingsDisableAppPassword => 'I-disable ang App Password';

  @override
  String get settingsEnterCurrentPassword =>
      'Ilagay ang iyong kasalukuyang password para kumpirmahin';

  @override
  String get settingsCurrentPassword => 'Kasalukuyang password';

  @override
  String get settingsIncorrectPassword => 'Maling password';

  @override
  String get settingsPasswordUpdated => 'Na-update ang password';

  @override
  String get settingsChangePasswordProceed =>
      'Ilagay ang iyong kasalukuyang password para magpatuloy';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsBackupMessages => 'I-backup ang mga Mensahe';

  @override
  String get settingsBackupMessagesSubtitle =>
      'I-export ang encrypted na message history sa isang file';

  @override
  String get settingsRestoreMessages => 'I-restore ang mga Mensahe';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'I-import ang mga mensahe mula sa backup file';

  @override
  String get settingsExportKeys => 'I-export ang mga Key';

  @override
  String get settingsExportKeysSubtitle =>
      'I-save ang mga identity key sa encrypted na file';

  @override
  String get settingsImportKeys => 'I-import ang mga Key';

  @override
  String get settingsImportKeysSubtitle =>
      'I-restore ang mga identity key mula sa na-export na file';

  @override
  String get settingsBackupPassword => 'Backup password';

  @override
  String get settingsPasswordCannotBeEmpty =>
      'Hindi maaaring walang laman ang password';

  @override
  String get settingsPasswordMin4Chars =>
      'Ang password ay dapat hindi bababa sa 4 na karakter';

  @override
  String get settingsCallsTurn => 'Mga Tawag at TURN';

  @override
  String get settingsLocalNetwork => 'Lokal na Network';

  @override
  String get settingsCensorshipResistance => 'Censorship Resistance';

  @override
  String get settingsNetwork => 'Network';

  @override
  String get settingsProxyTunnels => 'Proxy at Tunnel';

  @override
  String get settingsTurnServers => 'TURN Servers';

  @override
  String get settingsProviderTitle => 'Provider';

  @override
  String get settingsLanFallback => 'LAN Fallback';

  @override
  String get settingsLanFallbackSubtitle =>
      'Mag-broadcast ng presensya at maghatid ng mga mensahe sa lokal na network kapag walang internet. I-disable sa mga hindi pinagkakatiwalaang network (pampublikong Wi-Fi).';

  @override
  String get settingsBgDelivery => 'Background Delivery';

  @override
  String get settingsBgDeliverySubtitle =>
      'Patuloy na tumanggap ng mga mensahe kapag naka-minimize ang app. Nagpapakita ng persistent na notification.';

  @override
  String get settingsYourInboxProvider => 'Ang Iyong Inbox Provider';

  @override
  String get settingsConnectionDetails => 'Mga Detalye ng Koneksyon';

  @override
  String get settingsSaveAndConnect => 'I-save at Kumonekta';

  @override
  String get settingsSecondaryInboxes => 'Mga Pangalawang Inbox';

  @override
  String get settingsAddSecondaryInbox => 'Magdagdag ng Pangalawang Inbox';

  @override
  String get settingsAdvanced => 'Advanced';

  @override
  String get settingsDiscover => 'Tuklasin';

  @override
  String get settingsAbout => 'Tungkol';

  @override
  String get settingsPrivacyPolicy => 'Patakaran sa Privacy';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Paano pinoprotektahan ng Pulse ang iyong data';

  @override
  String get settingsCrashReporting => 'Crash reporting';

  @override
  String get settingsCrashReportingSubtitle =>
      'Magpadala ng anonymous na crash report para makatulong na mapabuti ang Pulse. Walang nilalaman ng mensahe o contact ang ipinapadala kailanman.';

  @override
  String get settingsCrashReportingEnabled =>
      'Na-enable ang crash reporting — i-restart ang app para ilapat';

  @override
  String get settingsCrashReportingDisabled =>
      'Na-disable ang crash reporting — i-restart ang app para ilapat';

  @override
  String get settingsSensitiveOperation => 'Sensitibong Operasyon';

  @override
  String get settingsSensitiveOperationBody =>
      'Ang mga key na ito ang iyong pagkakakilanlan. Sinumang may hawak ng file na ito ay maaaring magpanggap bilang ikaw. Itago ito nang ligtas at burahin pagkatapos ng paglilipat.';

  @override
  String get settingsIUnderstandContinue => 'Naiintindihan Ko, Ipagpatuloy';

  @override
  String get settingsReplaceIdentity => 'Palitan ang Identity?';

  @override
  String get settingsReplaceIdentityBody =>
      'Papalitan nito ang iyong kasalukuyang mga identity key. Ang iyong mga umiiral na Signal session ay magiging invalid at kakailanganin ng mga contact na muling mag-establish ng encryption. Kailangang i-restart ang app.';

  @override
  String get settingsReplaceKeys => 'Palitan ang mga Key';

  @override
  String get settingsKeysImported => 'Na-import ang mga Key';

  @override
  String settingsKeysImportedBody(int count) {
    return 'Matagumpay na na-import ang $count key. Mangyaring i-restart ang app para mag-initialize gamit ang bagong identity.';
  }

  @override
  String get settingsRestartNow => 'I-restart Ngayon';

  @override
  String get settingsLater => 'Mamaya';

  @override
  String get profileGroupLabel => 'Grupo';

  @override
  String get profileAddButton => 'Idagdag';

  @override
  String get profileKickButton => 'Paalisin';

  @override
  String get dataSectionTitle => 'Data';

  @override
  String get dataBackupMessages => 'I-backup ang mga Mensahe';

  @override
  String get dataBackupPasswordSubtitle =>
      'Pumili ng password para i-encrypt ang iyong message backup.';

  @override
  String get dataBackupConfirmLabel => 'Gumawa ng Backup';

  @override
  String get dataCreatingBackup => 'Gumagawa ng Backup';

  @override
  String get dataBackupPreparing => 'Naghahanda...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Ine-export ang mensahe $done ng $total...';
  }

  @override
  String get dataBackupSavingFile => 'Sine-save ang file...';

  @override
  String get dataSaveMessageBackupDialog => 'I-save ang Message Backup';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Na-save ang backup ($count mensahe)\n$path';
  }

  @override
  String get dataBackupFailed => 'Nabigo ang backup — walang na-export na data';

  @override
  String dataBackupFailedError(String error) {
    return 'Nabigo ang backup: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Pumili ng Message Backup';

  @override
  String get dataInvalidBackupFile =>
      'Invalid na backup file (masyadong maliit)';

  @override
  String get dataNotValidBackupFile => 'Hindi valid na Pulse backup file';

  @override
  String get dataRestoreMessages => 'I-restore ang mga Mensahe';

  @override
  String get dataRestorePasswordSubtitle =>
      'Ilagay ang password na ginamit sa paggawa ng backup na ito.';

  @override
  String get dataRestoreConfirmLabel => 'I-restore';

  @override
  String get dataRestoringMessages => 'Nire-restore ang mga Mensahe';

  @override
  String get dataRestoreDecrypting => 'Dine-decrypt...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Ini-import ang mensahe $done ng $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Nabigo ang pag-restore — maling password o sirang file';

  @override
  String dataRestoreSuccess(int count) {
    return 'Na-restore ang $count bagong mensahe';
  }

  @override
  String get dataRestoreNothingNew =>
      'Walang bagong mensahe na mai-import (lahat ay umiiral na)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Nabigo ang pag-restore: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Pumili ng Key Export';

  @override
  String get dataNotValidKeyFile => 'Hindi valid na Pulse key export file';

  @override
  String get dataExportKeys => 'I-export ang mga Key';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Pumili ng password para i-encrypt ang iyong key export.';

  @override
  String get dataExportKeysConfirmLabel => 'I-export';

  @override
  String get dataExportingKeys => 'Ine-export ang mga Key';

  @override
  String get dataExportingKeysStatus => 'Ine-encrypt ang mga identity key...';

  @override
  String get dataSaveKeyExportDialog => 'I-save ang Key Export';

  @override
  String dataKeysExportedTo(String path) {
    return 'Na-export ang mga key sa:\n$path';
  }

  @override
  String get dataExportFailed =>
      'Nabigo ang pag-export — walang nahanap na key';

  @override
  String dataExportFailedError(String error) {
    return 'Nabigo ang pag-export: $error';
  }

  @override
  String get dataImportKeys => 'I-import ang mga Key';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Ilagay ang password na ginamit sa pag-encrypt ng key export na ito.';

  @override
  String get dataImportKeysConfirmLabel => 'I-import';

  @override
  String get dataImportingKeys => 'Ini-import ang mga Key';

  @override
  String get dataImportingKeysStatus => 'Dine-decrypt ang mga identity key...';

  @override
  String get dataImportFailed =>
      'Nabigo ang pag-import — maling password o sirang file';

  @override
  String dataImportFailedError(String error) {
    return 'Nabigo ang pag-import: $error';
  }

  @override
  String get securitySectionTitle => 'Seguridad';

  @override
  String get securityIncorrectPassword => 'Maling password';

  @override
  String get securityPasswordUpdated => 'Na-update ang password';

  @override
  String get appearanceSectionTitle => 'Hitsura';

  @override
  String appearanceExportFailed(String error) {
    return 'Nabigo ang pag-export: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Na-save sa $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Nabigo ang pag-save: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Nabigo ang pag-import: $error';
  }

  @override
  String get aboutSectionTitle => 'Tungkol';

  @override
  String get providerPublicKey => 'Public Key';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Awtomatikong na-configure mula sa iyong recovery password. Awtomatikong nadiskubre ang relay.';

  @override
  String get providerKeyStoredLocally =>
      'Ang iyong key ay lokal na naka-store sa secure storage — hindi kailanman ipinapadala sa anumang server.';

  @override
  String get providerOxenInfo =>
      'Oxen/Session network — onion-routed E2EE. Ang iyong Session ID ay awtomatikong nage-generate at ligtas na naka-store. Awtomatikong nadidiskubre ang mga node mula sa built-in na seed node.';

  @override
  String get providerAdvanced => 'Advanced';

  @override
  String get providerSaveAndConnect => 'I-save at Kumonekta';

  @override
  String get providerAddSecondaryInbox => 'Magdagdag ng Pangalawang Inbox';

  @override
  String get providerSecondaryInboxes => 'Mga Pangalawang Inbox';

  @override
  String get providerYourInboxProvider => 'Ang Iyong Inbox Provider';

  @override
  String get providerConnectionDetails => 'Mga Detalye ng Koneksyon';

  @override
  String get addContactTitle => 'Magdagdag ng Contact';

  @override
  String get addContactInviteLinkLabel => 'Invite Link o Address';

  @override
  String get addContactTapToPaste => 'I-tap para i-paste ang invite link';

  @override
  String get addContactPasteTooltip => 'I-paste mula sa clipboard';

  @override
  String get addContactAddressDetected => 'Nadetect ang contact address';

  @override
  String addContactRoutesDetected(int count) {
    return '$count ruta ang nadetect — pipiliin ng SmartRouter ang pinakamabilis';
  }

  @override
  String get addContactFetchingProfile => 'Kinukuha ang profile…';

  @override
  String addContactProfileFound(String name) {
    return 'Nahanap: $name';
  }

  @override
  String get addContactNoProfileFound => 'Walang nahanap na profile';

  @override
  String get addContactDisplayNameLabel => 'Display Name';

  @override
  String get addContactDisplayNameHint =>
      'Ano ang gusto mong itawag sa kanila?';

  @override
  String get addContactAddManually => 'Manu-manong magdagdag ng address';

  @override
  String get addContactButton => 'Magdagdag ng Contact';

  @override
  String get networkDiagnosticsTitle => 'Network Diagnostics';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr Relays';

  @override
  String get networkDiagnosticsDirect => 'Direkta';

  @override
  String get networkDiagnosticsTorOnly => 'Tor lamang';

  @override
  String get networkDiagnosticsBest => 'Pinakamabuti';

  @override
  String get networkDiagnosticsNone => 'wala';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Status';

  @override
  String get networkDiagnosticsConnected => 'Konektado';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Kumokonekta $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Off';

  @override
  String get networkDiagnosticsTransport => 'Transport';

  @override
  String get networkDiagnosticsInfrastructure => 'Imprastruktura';

  @override
  String get networkDiagnosticsOxenNodes => 'Mga Oxen node';

  @override
  String get networkDiagnosticsTurnServers => 'Mga TURN server';

  @override
  String get networkDiagnosticsLastProbe => 'Huling probe';

  @override
  String get networkDiagnosticsRunning => 'Tumatakbo...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Magpatakbo ng Diagnostics';

  @override
  String get networkDiagnosticsForceReprobe => 'Pilitin ang Buong Re-probe';

  @override
  String get networkDiagnosticsJustNow => 'kanina lang';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '${minutes}m ang nakakaraan';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '${hours}h ang nakakaraan';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '${days}d ang nakakaraan';
  }

  @override
  String get homeNoEch => 'Walang ECH';

  @override
  String get homeNoEchTooltip =>
      'Hindi available ang uTLS proxy — naka-disable ang ECH.\nNakikita ng DPI ang TLS fingerprint.';

  @override
  String get settingsTitle => 'Mga Setting';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Na-save at nakakonekta sa $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Hindi nasimulan ang built-in na Tor';

  @override
  String get settingsPsiphonFailedToStart => 'Hindi nasimulan ang Psiphon';

  @override
  String get verifyTitle => 'I-verify ang Safety Number';

  @override
  String get verifyIdentityVerified => 'Na-verify ang Pagkakakilanlan';

  @override
  String get verifyNotYetVerified => 'Hindi Pa Na-verify';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Na-verify mo na ang safety number ni $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Ikumpara ang mga numerong ito kay $name nang personal o sa pamamagitan ng pinagkakatiwalaang channel.';
  }

  @override
  String get verifyExplanation =>
      'Ang bawat usapan ay may natatanging safety number. Kung pareho kayong nakakakita ng parehong mga numero sa inyong mga device, na-verify ang inyong koneksyon nang end-to-end.';

  @override
  String verifyContactKey(String name) {
    return 'Key ni $name';
  }

  @override
  String get verifyYourKey => 'Ang Iyong Key';

  @override
  String get verifyRemoveVerification => 'Alisin ang Verification';

  @override
  String get verifyMarkAsVerified => 'Markahan bilang Verified';

  @override
  String verifyAfterReinstall(String name) {
    return 'Kung muling i-install ni $name ang app, magbabago ang safety number at awtomatikong maaalis ang verification.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Markahan lamang bilang verified pagkatapos ikumpara ang mga numero kay $name sa isang voice call o nang personal.';
  }

  @override
  String get verifyNoSession =>
      'Wala pang naitatag na encryption session. Magpadala muna ng mensahe para ma-generate ang mga safety number.';

  @override
  String get verifyNoKeyAvailable => 'Walang available na key';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Nakopya ang $label fingerprint';
  }

  @override
  String get providerDatabaseUrlLabel => 'Database URL';

  @override
  String get providerOptionalHint => 'Opsyonal';

  @override
  String get providerWebApiKeyLabel => 'Web API Key';

  @override
  String get providerOptionalForPublicDb => 'Opsyonal para sa pampublikong DB';

  @override
  String get providerRelayUrlLabel => 'Relay URL';

  @override
  String get providerPrivateKeyLabel => 'Private Key';

  @override
  String get providerPrivateKeyNsecLabel => 'Private Key (nsec)';

  @override
  String get providerStorageNodeLabel => 'Storage Node URL (opsyonal)';

  @override
  String get providerStorageNodeHint =>
      'Iwanang walang laman para sa built-in na seed node';

  @override
  String get transferInvalidCodeFormat =>
      'Hindi kilalang format ng code — dapat magsimula sa LAN: o NOS:';

  @override
  String get profileCardFingerprintCopied => 'Nakopya ang fingerprint';

  @override
  String get profileCardAboutHint => 'Privacy muna 🔒';

  @override
  String get profileCardSaveButton => 'I-save ang Profile';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'I-export ang encrypted na mga mensahe, contact at avatar sa isang file';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Audio';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Naihatid kay $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Naihatid sa $count';
  }

  @override
  String get groupStatusDialogTitle => 'Impormasyon ng Mensahe';

  @override
  String get groupStatusRead => 'Nabasa';

  @override
  String get groupStatusDelivered => 'Naihatid';

  @override
  String get groupStatusPending => 'Naghihintay';

  @override
  String get groupStatusNoData => 'Wala pang impormasyon sa paghahatid';

  @override
  String get profileTransferAdmin => 'Gawing Admin';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Gawing bagong admin si $name?';
  }

  @override
  String get profileTransferAdminBody =>
      'Mawawala ang iyong mga admin privilege. Hindi na ito mababawi.';

  @override
  String profileTransferAdminDone(String name) {
    return 'Si $name na ngayon ang admin';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Patakaran sa Privacy';

  @override
  String get privacyOverviewHeading => 'Pangkalahatang-ideya';

  @override
  String get privacyOverviewBody =>
      'Ang Pulse ay isang serverless at end-to-end encrypted na messenger. Ang iyong privacy ay hindi lamang isang feature — ito ang arkitektura. Walang Pulse server. Walang mga account na naka-store kahit saan. Walang data na kinokolekta, ipinapadala, o iniimbak ng mga developer.';

  @override
  String get privacyDataCollectionHeading => 'Pangongolekta ng Data';

  @override
  String get privacyDataCollectionBody =>
      'Walang anumang personal na data na kinokolekta ang Pulse. Partikular:\n\n- Walang kinakailangang email, numero ng telepono, o totoong pangalan\n- Walang analytics, tracking, o telemetry\n- Walang advertising identifier\n- Walang access sa contact list\n- Walang cloud backup (ang mga mensahe ay nasa iyong device lamang)\n- Walang metadata na ipinapadala sa anumang Pulse server (wala naman)';

  @override
  String get privacyEncryptionHeading => 'Encryption';

  @override
  String get privacyEncryptionBody =>
      'Lahat ng mensahe ay naka-encrypt gamit ang Signal Protocol (Double Ratchet na may X3DH key agreement). Ang mga encryption key ay ginagawa at ini-store nang eksklusibo sa iyong device. Walang sinuman — kabilang ang mga developer — ang makakabasa ng iyong mga mensahe.';

  @override
  String get privacyNetworkHeading => 'Arkitektura ng Network';

  @override
  String get privacyNetworkBody =>
      'Gumagamit ang Pulse ng federated na transport adapter (Nostr relay, Session/Oxen service node, Firebase Realtime Database, LAN). Ang mga transport na ito ay nagdadala lamang ng encrypted na ciphertext. Makikita ng mga relay operator ang iyong IP address at dami ng traffic, ngunit hindi madedesifra ang nilalaman ng mensahe.\n\nKapag naka-enable ang Tor, natatago rin ang iyong IP address mula sa mga relay operator.';

  @override
  String get privacyStunHeading => 'Mga STUN/TURN Server';

  @override
  String get privacyStunBody =>
      'Ang mga voice at video call ay gumagamit ng WebRTC na may DTLS-SRTP encryption. Ang mga STUN server (ginagamit para malaman ang iyong public IP para sa peer-to-peer connection) at TURN server (ginagamit para mag-relay ng media kapag nabigo ang direktang koneksyon) ay makakakita ng iyong IP address at tagal ng tawag, ngunit hindi madedesifra ang nilalaman ng tawag.\n\nMaaari kang mag-configure ng sarili mong TURN server sa Settings para sa pinakamataas na privacy.';

  @override
  String get privacyCrashHeading => 'Crash Reporting';

  @override
  String get privacyCrashBody =>
      'Kung naka-enable ang Sentry crash reporting (sa pamamagitan ng build-time SENTRY_DSN), maaaring magpadala ng anonymous na crash report. Ang mga ito ay walang nilalaman ng mensahe, walang impormasyon ng contact, at walang personal na nakakapagpakilalang impormasyon. Maaaring i-disable ang crash reporting sa build time sa pamamagitan ng pag-alis ng DSN.';

  @override
  String get privacyPasswordHeading => 'Password at mga Key';

  @override
  String get privacyPasswordBody =>
      'Ang iyong recovery password ay ginagamit para mag-derive ng mga cryptographic key sa pamamagitan ng Argon2id (memory-hard KDF). Ang password ay hindi kailanman ipinapadala kahit saan. Kung mawala ang iyong password, hindi na maibabalik ang iyong account — walang server para i-reset ito.';

  @override
  String get privacyFontsHeading => 'Mga Font';

  @override
  String get privacyFontsBody =>
      'Kasama na ng Pulse ang lahat ng font nang lokal. Walang mga request na ginagawa sa Google Fonts o anumang external na font service.';

  @override
  String get privacyThirdPartyHeading => 'Mga Third-Party Service';

  @override
  String get privacyThirdPartyBody =>
      'Hindi nag-i-integrate ang Pulse sa anumang advertising network, analytics provider, social media platform, o data broker. Ang tanging network connection ay sa mga transport relay na iyong na-configure.';

  @override
  String get privacyOpenSourceHeading => 'Open Source';

  @override
  String get privacyOpenSourceBody =>
      'Ang Pulse ay open-source software. Maaari mong suriin ang kumpletong source code para i-verify ang mga privacy claim na ito.';

  @override
  String get privacyContactHeading => 'Makipag-ugnayan';

  @override
  String get privacyContactBody =>
      'Para sa mga tanong tungkol sa privacy, magbukas ng issue sa project repository.';

  @override
  String get privacyLastUpdated => 'Huling na-update: Marso 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Nabigo ang pag-save: $error';
  }

  @override
  String get themeEngineTitle => 'Theme Engine';

  @override
  String get torBuiltInTitle => 'Built-in na Tor';

  @override
  String get torConnectedSubtitle =>
      'Konektado — Nostr naka-route sa pamamagitan ng 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Kumokonekta… $pct%';
  }

  @override
  String get torNotRunning =>
      'Hindi tumatakbo — i-tap ang switch para i-restart';

  @override
  String get torDescription =>
      'Nire-route ang Nostr sa pamamagitan ng Tor (Snowflake para sa mga censored na network)';

  @override
  String get torNetworkDiagnostics => 'Network Diagnostics';

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
  String get torPtPlain => 'Plain';

  @override
  String get torTimeoutLabel => 'Timeout: ';

  @override
  String get torInfoDescription =>
      'Kapag naka-enable, ang mga Nostr WebSocket connection ay nire-route sa pamamagitan ng Tor (SOCKS5). Ang Tor Browser ay nakikinig sa 127.0.0.1:9150. Ang standalone na tor daemon ay gumagamit ng port 9050. Hindi apektado ang mga Firebase connection.';

  @override
  String get torRouteNostrTitle => 'I-route ang Nostr sa pamamagitan ng Tor';

  @override
  String get torManagedByBuiltin => 'Pinamamahalaan ng Built-in na Tor';

  @override
  String get torActiveRouting =>
      'Aktibo — Nostr traffic ay nire-route sa pamamagitan ng Tor';

  @override
  String get torDisabled => 'Naka-disable';

  @override
  String get torProxySocks5 => 'Tor Proxy (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Proxy Host';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser: port 9150  •  tor daemon: port 9050';

  @override
  String get i2pProxySocks5 => 'I2P Proxy (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'Gumagamit ang I2P ng SOCKS5 sa port 4447 bilang default. Kumonekta sa isang Nostr relay sa pamamagitan ng I2P outproxy (hal. relay.damus.i2p) para makipag-ugnayan sa mga user sa anumang transport. May prayoridad ang Tor kapag pareho ay naka-enable.';

  @override
  String get i2pRouteNostrTitle => 'I-route ang Nostr sa pamamagitan ng I2P';

  @override
  String get i2pActiveRouting =>
      'Aktibo — Nostr traffic ay nire-route sa pamamagitan ng I2P';

  @override
  String get i2pDisabled => 'Naka-disable';

  @override
  String get i2pProxyHostLabel => 'Proxy Host';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'Default na SOCKS5 port ng I2P Router: 4447';

  @override
  String get customProxySocks5 => 'Custom Proxy (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Ang custom proxy ay nire-route ang traffic sa pamamagitan ng iyong V2Ray/Xray/Shadowsocks. Ang CF Worker ay gumaganap bilang personal na relay proxy sa Cloudflare CDN — nakikita ng GFW ang *.workers.dev, hindi ang totoong relay.';

  @override
  String get customSocks5ProxyTitle => 'Custom SOCKS5 Proxy';

  @override
  String get customProxyActive =>
      'Aktibo — traffic ay nire-route sa pamamagitan ng SOCKS5';

  @override
  String get customProxyDisabled => 'Naka-disable';

  @override
  String get customProxyHostLabel => 'Proxy Host';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker Domain (opsyonal)';

  @override
  String get customWorkerHelpTitle =>
      'Paano mag-deploy ng CF Worker relay (libre)';

  @override
  String get customWorkerScriptCopied => 'Nakopya ang script!';

  @override
  String get customWorkerStep1 =>
      '1. Pumunta sa dash.cloudflare.com → Workers & Pages\n2. Create Worker → i-paste ang script na ito:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → kopyahin ang domain (hal. my-relay.user.workers.dev)\n4. I-paste ang domain sa itaas → I-save\n\nAwtomatikong kumokonekta ang app: wss://domain/?r=relay_url\nNakikita ng GFW: koneksyon sa *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Konektado — SOCKS5 sa 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Kumokonekta…';

  @override
  String get psiphonNotRunning =>
      'Hindi tumatakbo — i-tap ang switch para i-restart';

  @override
  String get psiphonDescription =>
      'Mabilis na tunnel (~3s bootstrap, 2000+ umiikot na VPS)';

  @override
  String get turnCommunityServers => 'Community TURN Servers';

  @override
  String get turnCustomServer => 'Custom TURN Server (BYOD)';

  @override
  String get turnInfoDescription =>
      'Ang mga TURN server ay nagre-relay lamang ng naka-encrypt nang mga stream (DTLS-SRTP). Ang relay operator ay makakakita ng iyong IP at dami ng traffic, ngunit hindi madedesifra ang mga tawag. Ginagamit lamang ang TURN kapag nabigo ang direktang P2P (~15–20% ng mga koneksyon).';

  @override
  String get turnFreeLabel => 'LIBRE';

  @override
  String get turnServerUrlLabel => 'TURN Server URL';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 o turns:...';

  @override
  String get turnUsernameLabel => 'Username';

  @override
  String get turnPasswordLabel => 'Password';

  @override
  String get turnOptionalHint => 'Opsyonal';

  @override
  String get turnCustomInfo =>
      'Mag-self-host ng coturn sa anumang \$5/buwan VPS para sa pinakamataas na kontrol. Ang mga credential ay lokal na naka-store.';

  @override
  String get themePickerAppearance => 'Hitsura';

  @override
  String get themePickerAccentColor => 'Accent Color';

  @override
  String get themeModeLight => 'Maliwanag';

  @override
  String get themeModeDark => 'Madilim';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeDynamicPresets => 'Mga Preset';

  @override
  String get themeDynamicPrimaryColor => 'Primary Color';

  @override
  String get themeDynamicBorderRadius => 'Border Radius';

  @override
  String get themeDynamicFont => 'Font';

  @override
  String get themeDynamicAppearance => 'Hitsura';

  @override
  String get themeDynamicUiStyle => 'UI Style';

  @override
  String get themeDynamicUiStyleDescription =>
      'Kinokontrol kung paano ang hitsura ng mga dialog, switch at indicator.';

  @override
  String get themeDynamicSharp => 'Matulis';

  @override
  String get themeDynamicRound => 'Bilog';

  @override
  String get themeDynamicModeDark => 'Madilim';

  @override
  String get themeDynamicModeLight => 'Maliwanag';

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
      'Invalid na Firebase URL. Inaasahan: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Invalid na relay URL. Inaasahan: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Invalid na Pulse server URL. Inaasahan: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'Server URL';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'Invite Code';

  @override
  String get providerPulseInviteHint => 'Invite code (kung kinakailangan)';

  @override
  String get providerPulseInfo =>
      'Self-hosted na relay. Ang mga key ay hinango mula sa iyong recovery password.';

  @override
  String get providerScreenTitle => 'Mga Inbox';

  @override
  String get providerSecondaryInboxesHeader => 'MGA PANGALAWANG INBOX';

  @override
  String get providerSecondaryInboxesInfo =>
      'Ang mga pangalawang inbox ay tumatanggap ng mga mensahe nang sabay para sa redundancy.';

  @override
  String get providerRemoveTooltip => 'Alisin';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... o hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... o hex private key';

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
  String get emojiNoRecent => 'Walang kamakailang emoji';

  @override
  String get emojiSearchHint => 'Maghanap ng emoji...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'I-tap para mag-chat';

  @override
  String get imageViewerSaveToDownloads => 'I-save sa Downloads';

  @override
  String imageViewerSavedTo(String path) {
    return 'Na-save sa $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Wika';

  @override
  String get settingsLanguageSubtitle => 'Wika ng app display';

  @override
  String get settingsLanguageSystem => 'Default ng system';

  @override
  String get onboardingLanguageTitle => 'Piliin ang iyong wika';

  @override
  String get onboardingLanguageSubtitle => 'Mababago mo ito mamaya sa Settings';
}
