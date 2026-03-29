// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Tafuta ujumbe...';

  @override
  String get search => 'Tafuta';

  @override
  String get clearSearch => 'Futa utafutaji';

  @override
  String get closeSearch => 'Funga utafutaji';

  @override
  String get moreOptions => 'Chaguo zaidi';

  @override
  String get back => 'Rudi';

  @override
  String get cancel => 'Ghairi';

  @override
  String get close => 'Funga';

  @override
  String get confirm => 'Thibitisha';

  @override
  String get remove => 'Ondoa';

  @override
  String get save => 'Hifadhi';

  @override
  String get add => 'Ongeza';

  @override
  String get copy => 'Nakili';

  @override
  String get skip => 'Ruka';

  @override
  String get done => 'Imekamilika';

  @override
  String get apply => 'Tekeleza';

  @override
  String get export => 'Hamisha nje';

  @override
  String get import => 'Hamisha ndani';

  @override
  String get homeNewGroup => 'Kikundi kipya';

  @override
  String get homeSettings => 'Mipangilio';

  @override
  String get homeSearching => 'Inatafuta ujumbe...';

  @override
  String get homeNoResults => 'Hakuna matokeo yaliyopatikana';

  @override
  String get homeNoChatHistory => 'Hakuna historia ya mazungumzo bado';

  @override
  String homeTransportSwitched(String address) {
    return 'Usafiri umebadilishwa → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name anapiga simu...';
  }

  @override
  String get homeAccept => 'Kubali';

  @override
  String get homeDecline => 'Kataa';

  @override
  String get homeLoadEarlier => 'Pakia ujumbe wa awali';

  @override
  String get homeChats => 'Mazungumzo';

  @override
  String get homeSelectConversation => 'Chagua mazungumzo';

  @override
  String get homeNoChatsYet => 'Hakuna mazungumzo bado';

  @override
  String get homeAddContactToStart => 'Ongeza anwani ili kuanza kuzungumza';

  @override
  String get homeNewChat => 'Mazungumzo Mapya';

  @override
  String get homeNewChatTooltip => 'Mazungumzo mapya';

  @override
  String get homeIncomingCallTitle => 'Simu Inayoingia';

  @override
  String get homeIncomingGroupCallTitle => 'Simu ya Kikundi Inayoingia';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — simu ya kikundi inaingia';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Hakuna mazungumzo yanayolingana na \"$query\"';
  }

  @override
  String get homeSectionChats => 'Mazungumzo';

  @override
  String get homeSectionMessages => 'Ujumbe';

  @override
  String get homeDbEncryptionUnavailable =>
      'Usimbaji wa hifadhidata haupatikani — sakinisha SQLCipher kwa ulinzi kamili';

  @override
  String get chatFileTooLargeGroup =>
      'Faili zaidi ya 512 KB hazitumiki katika mazungumzo ya kikundi';

  @override
  String get chatLargeFile => 'Faili Kubwa';

  @override
  String get chatCancel => 'Ghairi';

  @override
  String get chatSend => 'Tuma';

  @override
  String get chatFileTooLarge => 'Faili kubwa sana — ukubwa wa juu ni 100 MB';

  @override
  String get chatMicDenied => 'Ruhusa ya kipaza sauti imekataliwa';

  @override
  String get chatVoiceFailed =>
      'Imeshindwa kuhifadhi ujumbe wa sauti — angalia hifadhi inayopatikana';

  @override
  String get chatScheduleFuture => 'Muda uliopangwa lazima uwe wakati ujao';

  @override
  String get chatToday => 'Leo';

  @override
  String get chatYesterday => 'Jana';

  @override
  String get chatEdited => 'imehaririwa';

  @override
  String get chatYou => 'Wewe';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Faili hii ni $size MB. Kutuma faili kubwa kunaweza kuwa polepole kwenye mitandao mingine. Endelea?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Ufunguo wa usalama wa $name umebadilika. Gusa kuthibitisha.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Imeshindwa kusimba ujumbe kwa $name — ujumbe haujatumwa.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Nambari ya usalama imebadilika kwa $name. Gusa kuthibitisha.';
  }

  @override
  String get chatNoMessagesFound => 'Hakuna ujumbe uliopatikana';

  @override
  String get chatMessagesE2ee => 'Ujumbe umesimbwa mwisho-hadi-mwisho';

  @override
  String get chatSayHello => 'Sema habari';

  @override
  String get appBarOnline => 'mtandaoni';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'anaandika';

  @override
  String get appBarSearchMessages => 'Tafuta ujumbe...';

  @override
  String get appBarMute => 'Nyamazisha';

  @override
  String get appBarUnmute => 'Rudisha sauti';

  @override
  String get appBarMedia => 'Midia';

  @override
  String get appBarDisappearing => 'Ujumbe unaopotea';

  @override
  String get appBarDisappearingOn => 'Kupotea: imewashwa';

  @override
  String get appBarGroupSettings => 'Mipangilio ya kikundi';

  @override
  String get appBarSearchTooltip => 'Tafuta ujumbe';

  @override
  String get appBarVoiceCall => 'Simu ya sauti';

  @override
  String get appBarVideoCall => 'Simu ya video';

  @override
  String get inputMessage => 'Ujumbe...';

  @override
  String get inputAttachFile => 'Ambatisha faili';

  @override
  String get inputSendMessage => 'Tuma ujumbe';

  @override
  String get inputRecordVoice => 'Rekodi ujumbe wa sauti';

  @override
  String get inputSendVoice => 'Tuma ujumbe wa sauti';

  @override
  String get inputCancelReply => 'Ghairi jibu';

  @override
  String get inputCancelEdit => 'Ghairi kuhariri';

  @override
  String get inputCancelRecording => 'Ghairi kurekodi';

  @override
  String get inputRecording => 'Inarekodi…';

  @override
  String get inputEditingMessage => 'Inahariri ujumbe';

  @override
  String get inputPhoto => 'Picha';

  @override
  String get inputVoiceMessage => 'Ujumbe wa sauti';

  @override
  String get inputFile => 'Faili';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count ujumbe uliopangwa$_temp0';
  }

  @override
  String get callInitializing => 'Inaanzisha simu…';

  @override
  String get callConnecting => 'Inaunganisha…';

  @override
  String get callConnectingRelay => 'Inaunganisha (relay)…';

  @override
  String get callSwitchingRelay => 'Inabadilisha hadi hali ya relay…';

  @override
  String get callConnectionFailed => 'Muunganisho umeshindwa';

  @override
  String get callReconnecting => 'Inaunganisha tena…';

  @override
  String get callEnded => 'Simu imeisha';

  @override
  String get callLive => 'Moja kwa moja';

  @override
  String get callEnd => 'Mwisho';

  @override
  String get callEndCall => 'Maliza simu';

  @override
  String get callMute => 'Nyamazisha';

  @override
  String get callUnmute => 'Rudisha sauti';

  @override
  String get callSpeaker => 'Spika';

  @override
  String get callCameraOn => 'Kamera Imewashwa';

  @override
  String get callCameraOff => 'Kamera Imezimwa';

  @override
  String get callShareScreen => 'Shiriki Skrini';

  @override
  String get callStopShare => 'Acha Kushiriki';

  @override
  String callTorBackup(String duration) {
    return 'Tor akiba · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor akiba inatumika — njia ya msingi haipatikani';

  @override
  String get callDirectFailed =>
      'Muunganisho wa moja kwa moja umeshindwa — inabadilisha hadi hali ya relay…';

  @override
  String get callTurnUnreachable =>
      'Seva za TURN hazipatikani. Ongeza TURN maalum katika Mipangilio → Ya Juu.';

  @override
  String get callRelayMode => 'Hali ya relay inatumika (mtandao uliozuiliwa)';

  @override
  String get callStarting => 'Inaanza simu…';

  @override
  String get callConnectingToGroup => 'Inaunganisha na kikundi…';

  @override
  String get callGroupOpenedInBrowser =>
      'Simu ya kikundi imefunguliwa kwenye kivinjari';

  @override
  String get callCouldNotOpenBrowser => 'Imeshindwa kufungua kivinjari';

  @override
  String get callInviteLinkSent =>
      'Kiungo cha mwaliko kimetumwa kwa wanachama wote wa kikundi.';

  @override
  String get callOpenLinkManually =>
      'Fungua kiungo hapo juu kwa mikono au gusa kujaribu tena.';

  @override
  String get callJitsiNotE2ee =>
      'Simu za Jitsi HAZIJASIMBWA mwisho-hadi-mwisho';

  @override
  String get callRetryOpenBrowser => 'Jaribu tena kufungua kivinjari';

  @override
  String get callClose => 'Funga';

  @override
  String get callCamOn => 'Kamera imewashwa';

  @override
  String get callCamOff => 'Kamera imezimwa';

  @override
  String get noConnection => 'Hakuna muunganisho — ujumbe utapangwa foleni';

  @override
  String get connected => 'Imeunganishwa';

  @override
  String get connecting => 'Inaunganisha…';

  @override
  String get disconnected => 'Imekatika';

  @override
  String get offlineBanner =>
      'Hakuna muunganisho — ujumbe utapangwa foleni na kutumwa ukiwa mtandaoni tena';

  @override
  String get lanModeBanner =>
      'Hali ya LAN — Hakuna mtandao · Mtandao wa ndani tu';

  @override
  String get probeCheckingNetwork => 'Inakagua muunganisho wa mtandao…';

  @override
  String get probeDiscoveringRelays =>
      'Inagundua relay kupitia saraka za jamii…';

  @override
  String get probeStartingTor => 'Inaanzisha Tor kwa bootstrap…';

  @override
  String get probeFindingRelaysTor =>
      'Inatafuta relay zinazofikika kupitia Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'Mtandao tayari — relay $count$_temp0 zimepatikana';
  }

  @override
  String get probeNoRelaysFound =>
      'Hakuna relay zinazofikika zilizopatikana — ujumbe unaweza kuchelewa';

  @override
  String get jitsiWarningTitle => 'Haijasimbwa mwisho-hadi-mwisho';

  @override
  String get jitsiWarningBody =>
      'Simu za Jitsi Meet hazijasimbwa na Pulse. Tumia tu kwa mazungumzo yasiyo ya siri.';

  @override
  String get jitsiConfirm => 'Jiunge hata hivyo';

  @override
  String get jitsiGroupWarningTitle => 'Haijasimbwa mwisho-hadi-mwisho';

  @override
  String get jitsiGroupWarningBody =>
      'Simu hii ina washiriki wengi sana kwa mesh iliyosimbwa.\n\nKiungo cha Jitsi Meet kitafunguliwa kwenye kivinjari chako. Jitsi HAIJASIMBWA mwisho-hadi-mwisho — seva inaweza kuona simu yako.';

  @override
  String get jitsiContinueAnyway => 'Endelea hata hivyo';

  @override
  String get retry => 'Jaribu tena';

  @override
  String get setupCreateAnonymousAccount => 'Unda akaunti isiyojulikana';

  @override
  String get setupTapToChangeColor => 'Gusa kubadilisha rangi';

  @override
  String get setupReqMinLength => 'At least 16 characters';

  @override
  String get setupReqVariety => '3 of 4: uppercase, lowercase, digits, symbols';

  @override
  String get setupReqMatch => 'Passwords match';

  @override
  String get setupYourNickname => 'Jina lako la utani';

  @override
  String get setupRecoveryPassword => 'Nenosiri la kurejesha (angalau 16)';

  @override
  String get setupConfirmPassword => 'Thibitisha nenosiri';

  @override
  String get setupMin16Chars => 'Angalau herufi 16';

  @override
  String get setupPasswordsDoNotMatch => 'Manenosiri hayalingani';

  @override
  String get setupEntropyWeak => 'Dhaifu';

  @override
  String get setupEntropyOk => 'Sawa';

  @override
  String get setupEntropyStrong => 'Imara';

  @override
  String get setupEntropyWeakNeedsVariety =>
      'Dhaifu (aina 3 za herufi zinahitajika)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label (biti $bits)';
  }

  @override
  String get setupPasswordWarning =>
      'Nenosiri hili ni njia pekee ya kurejesha akaunti yako. Hakuna seva — hakuna upya wa nenosiri. Likumbuke au uliandike.';

  @override
  String get setupCreateAccount => 'Unda akaunti';

  @override
  String get setupAlreadyHaveAccount => 'Tayari una akaunti? ';

  @override
  String get setupRestore => 'Rejesha →';

  @override
  String get restoreTitle => 'Rejesha akaunti';

  @override
  String get restoreInfoBanner =>
      'Weka nenosiri lako la kurejesha — anwani yako (Nostr + Session) itarejeshwa kiotomatiki. Anwani na ujumbe vilihifadhiwa ndani ya kifaa pekee.';

  @override
  String get restoreNewNickname =>
      'Jina jipya la utani (linaweza kubadilishwa baadaye)';

  @override
  String get restoreButton => 'Rejesha akaunti';

  @override
  String get lockTitle => 'Pulse imefungwa';

  @override
  String get lockSubtitle => 'Weka nenosiri lako kuendelea';

  @override
  String get lockPasswordHint => 'Nenosiri';

  @override
  String get lockUnlock => 'Fungua';

  @override
  String get lockPanicHint =>
      'Umesahau nenosiri lako? Weka ufunguo wako wa dharura kufuta data yote.';

  @override
  String get lockTooManyAttempts => 'Majaribio mengi sana. Inafuta data yote…';

  @override
  String get lockWrongPassword => 'Nenosiri lisilo sahihi';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Nenosiri lisilo sahihi — majaribio $attempts/$max';
  }

  @override
  String get onboardingSkip => 'Ruka';

  @override
  String get onboardingNext => 'Ifuatayo';

  @override
  String get onboardingGetStarted => 'Anza';

  @override
  String get onboardingWelcomeTitle => 'Karibu kwenye Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Mjumbe uliosimbwa mwisho-hadi-mwisho, usio na kituo.\n\nHakuna seva kuu. Hakuna ukusanyaji wa data. Hakuna milango ya siri.\nMazungumzo yako ni yako pekee.';

  @override
  String get onboardingTransportTitle => 'Huru ya Usafiri';

  @override
  String get onboardingTransportBody =>
      'Tumia Firebase, Nostr, au zote kwa wakati mmoja.\n\nUjumbe unasafiri kati ya mitandao kiotomatiki. Msaada wa Tor na I2P uliojengwa ndani kwa kupinga udhibiti.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Kila ujumbe umesimbwa na Signal Protocol (Double Ratchet + X3DH) kwa usiri wa mbele.\n\nPia umefungwa na Kyber-1024 — kanuni ya post-quantum ya kiwango cha NIST — inalinda dhidi ya kompyuta za quantum za siku zijazo.';

  @override
  String get onboardingKeysTitle => 'Funguo Zako Ni Zako';

  @override
  String get onboardingKeysBody =>
      'Funguo zako za utambulisho hazitoki kwenye kifaa chako kamwe.\n\nAlama za vidole za Signal zinakuwezesha kuthibitisha anwani nje ya mkondo. TOFU (Trust On First Use) inagundua mabadiliko ya funguo kiotomatiki.';

  @override
  String get onboardingThemeTitle => 'Chagua Muonekano Wako';

  @override
  String get onboardingThemeBody =>
      'Chagua mandhari na rangi ya lafudhi. Unaweza kubadilisha hii wakati wowote katika Mipangilio.';

  @override
  String get contactsNewChat => 'Mazungumzo mapya';

  @override
  String get contactsAddContact => 'Ongeza anwani';

  @override
  String get contactsSearchHint => 'Tafuta...';

  @override
  String get contactsNewGroup => 'Kikundi kipya';

  @override
  String get contactsNoContactsYet => 'Hakuna anwani bado';

  @override
  String get contactsAddHint => 'Gusa + kuongeza anwani ya mtu';

  @override
  String get contactsNoMatch => 'Hakuna anwani zinazolingana';

  @override
  String get contactsRemoveTitle => 'Ondoa anwani';

  @override
  String contactsRemoveMessage(String name) {
    return 'Ondoa $name?';
  }

  @override
  String get contactsRemove => 'Ondoa';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'anwani $count$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Fungua Kiungo';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Fungua URL hii kwenye kivinjari chako?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Fungua';

  @override
  String get bubbleSecurityWarning => 'Onyo la Usalama';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" ni aina ya faili inayoweza kutekelezwa. Kuhifadhi na kuiendesha kunaweza kudhuru kifaa chako. Hifadhi hata hivyo?';
  }

  @override
  String get bubbleSaveAnyway => 'Hifadhi Hata Hivyo';

  @override
  String bubbleSavedTo(String path) {
    return 'Imehifadhiwa kwenye $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Kuhifadhi kumeshindwa: $error';
  }

  @override
  String get bubbleNotEncrypted => 'HAIJASIMBWA';

  @override
  String get bubbleCorruptedImage => '[Picha iliyoharibika]';

  @override
  String get bubbleReplyPhoto => 'Picha';

  @override
  String get bubbleReplyVoice => 'Ujumbe wa sauti';

  @override
  String get bubbleReplyVideo => 'Ujumbe wa video';

  @override
  String bubbleReadBy(String names) {
    return 'Imesomwa na $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Imesomwa na $count';
  }

  @override
  String get chatTileTapToStart => 'Gusa kuanza kuzungumza';

  @override
  String get chatTileMessageSent => 'Ujumbe umetumwa';

  @override
  String get chatTileEncryptedMessage => 'Ujumbe uliosimbwa';

  @override
  String chatTileYouPrefix(String text) {
    return 'Wewe: $text';
  }

  @override
  String get bannerEncryptedMessage => 'Ujumbe uliosimbwa';

  @override
  String get groupNewGroup => 'Kikundi Kipya';

  @override
  String get groupGroupName => 'Jina la kikundi';

  @override
  String get groupSelectMembers => 'Chagua wanachama (angalau 2)';

  @override
  String get groupNoContactsYet => 'Hakuna anwani bado. Ongeza anwani kwanza.';

  @override
  String get groupCreate => 'Unda';

  @override
  String get groupLabel => 'Kikundi';

  @override
  String get profileVerifyIdentity => 'Thibitisha Utambulisho';

  @override
  String profileVerifyInstructions(String name) {
    return 'Linganisha alama hizi za vidole na $name kupitia simu ya sauti au ana kwa ana. Ikiwa thamani zote mbili zinalingana kwenye vifaa vyote viwili, gusa \"Weka kama Imethibitishwa\".';
  }

  @override
  String get profileTheirKey => 'Ufunguo wao';

  @override
  String get profileYourKey => 'Ufunguo wako';

  @override
  String get profileRemoveVerification => 'Ondoa Uthibitisho';

  @override
  String get profileMarkAsVerified => 'Weka kama Imethibitishwa';

  @override
  String get profileAddressCopied => 'Anwani imenakiliwa';

  @override
  String get profileNoContactsToAdd =>
      'Hakuna anwani za kuongeza — zote tayari ni wanachama';

  @override
  String get profileAddMembers => 'Ongeza Wanachama';

  @override
  String profileAddCount(int count) {
    return 'Ongeza ($count)';
  }

  @override
  String get profileRenameGroup => 'Badilisha Jina la Kikundi';

  @override
  String get profileRename => 'Badilisha jina';

  @override
  String get profileRemoveMember => 'Ondoa mwanachama?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Ondoa $name kutoka kikundi hiki?';
  }

  @override
  String get profileKick => 'Fukuza';

  @override
  String get profileSignalFingerprints => 'Alama za Vidole za Signal';

  @override
  String get profileVerified => 'IMETHIBITISHWA';

  @override
  String get profileVerify => 'Thibitisha';

  @override
  String get profileEdit => 'Hariri';

  @override
  String get profileNoSession =>
      'Hakuna kikao kilichoanzishwa bado — tuma ujumbe kwanza.';

  @override
  String get profileFingerprintCopied => 'Alama ya kidole imenakiliwa';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'mwanachama $count$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Thibitisha Nambari ya Usalama';

  @override
  String get profileShowContactQr => 'Onyesha QR ya Anwani';

  @override
  String profileContactAddress(String name) {
    return 'Anwani ya $name';
  }

  @override
  String get profileExportChatHistory => 'Hamisha Historia ya Mazungumzo';

  @override
  String profileSavedTo(String path) {
    return 'Imehifadhiwa kwenye $path';
  }

  @override
  String get profileExportFailed => 'Kuhamisha kumeshindwa';

  @override
  String get profileClearChatHistory => 'Futa historia ya mazungumzo';

  @override
  String get profileDeleteGroup => 'Futa kikundi';

  @override
  String get profileDeleteContact => 'Futa anwani';

  @override
  String get profileLeaveGroup => 'Ondoka kikundi';

  @override
  String get profileLeaveGroupBody =>
      'Utaondolewa kutoka kikundi hiki na kitafutwa kutoka anwani zako.';

  @override
  String get groupInviteTitle => 'Mwaliko wa kikundi';

  @override
  String groupInviteBody(String from, String group) {
    return '$from amekualika kujiunga na \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Kubali';

  @override
  String get groupInviteDecline => 'Kataa';

  @override
  String get groupMemberLimitTitle => 'Washiriki wengi sana';

  @override
  String groupMemberLimitBody(int count) {
    return 'Kikundi hiki kitakuwa na washiriki $count. Simu za mesh zilizosimbwa zinasaidia hadi 6. Vikundi vikubwa vinatumia Jitsi (si E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Ongeza hata hivyo';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name amekataa kujiunga na \"$group\"';
  }

  @override
  String get transferTitle => 'Hamisha hadi Kifaa Kingine';

  @override
  String get transferInfoBox =>
      'Hamisha utambulisho wako wa Signal na funguo za Nostr hadi kifaa kipya.\nVikao vya mazungumzo HAVIHAMISHWI — usiri wa mbele umehifadhiwa.';

  @override
  String get transferSendFromThis => 'Tuma kutoka kifaa hiki';

  @override
  String get transferSendSubtitle =>
      'Kifaa hiki kina funguo. Shiriki msimbo na kifaa kipya.';

  @override
  String get transferReceiveOnThis => 'Pokea kwenye kifaa hiki';

  @override
  String get transferReceiveSubtitle =>
      'Hiki ni kifaa kipya. Weka msimbo kutoka kifaa cha zamani.';

  @override
  String get transferChooseMethod => 'Chagua Njia ya Kuhamisha';

  @override
  String get transferLan => 'LAN (Mtandao Mmoja)';

  @override
  String get transferLanSubtitle =>
      'Haraka, moja kwa moja. Vifaa vyote lazima viwe kwenye Wi-Fi sawa.';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'Inafanya kazi kupitia mtandao wowote kwa kutumia Nostr relay iliyopo.';

  @override
  String get transferRelayUrl => 'URL ya Relay';

  @override
  String get transferEnterCode => 'Weka Msimbo wa Kuhamisha';

  @override
  String get transferPasteCode => 'Bandika msimbo wa LAN:... au NOS:... hapa';

  @override
  String get transferConnect => 'Unganisha';

  @override
  String get transferGenerating => 'Inaunda msimbo wa kuhamisha…';

  @override
  String get transferShareCode => 'Shiriki msimbo huu na mpokeaji:';

  @override
  String get transferCopyCode => 'Nakili Msimbo';

  @override
  String get transferCodeCopied => 'Msimbo umenakiliwa kwenye ubao wa kunakili';

  @override
  String get transferWaitingReceiver => 'Inasubiri mpokeaji aunganishe…';

  @override
  String get transferConnectingSender => 'Inaunganisha na mtumaji…';

  @override
  String get transferVerifyBoth =>
      'Linganisha msimbo huu kwenye vifaa vyote viwili.\nIkizingatiana, uhamishaji ni salama.';

  @override
  String get transferComplete => 'Uhamishaji Umekamilika';

  @override
  String get transferKeysImported => 'Funguo Zimehamishwa Ndani';

  @override
  String get transferCompleteSenderBody =>
      'Funguo zako zinabaki hai kwenye kifaa hiki.\nMpokeaji sasa anaweza kutumia utambulisho wako.';

  @override
  String get transferCompleteReceiverBody =>
      'Funguo zimehamishwa ndani kwa mafanikio.\nAnzisha upya programu kutumia utambulisho mpya.';

  @override
  String get transferRestartApp => 'Anzisha Upya Programu';

  @override
  String get transferFailed => 'Uhamishaji Umeshindwa';

  @override
  String get transferTryAgain => 'Jaribu Tena';

  @override
  String get transferEnterRelayFirst => 'Weka URL ya relay kwanza';

  @override
  String get transferPasteCodeFromSender =>
      'Bandika msimbo wa kuhamisha kutoka kwa mtumaji';

  @override
  String get menuReply => 'Jibu';

  @override
  String get menuForward => 'Sambaza';

  @override
  String get menuReact => 'Itikia';

  @override
  String get menuCopy => 'Nakili';

  @override
  String get menuEdit => 'Hariri';

  @override
  String get menuRetry => 'Jaribu tena';

  @override
  String get menuCancelScheduled => 'Ghairi iliyopangwa';

  @override
  String get menuDelete => 'Futa';

  @override
  String get menuForwardTo => 'Sambaza kwa…';

  @override
  String menuForwardedTo(String name) {
    return 'Imesambazwa kwa $name';
  }

  @override
  String get menuScheduledMessages => 'Ujumbe uliopangwa';

  @override
  String get menuNoScheduledMessages => 'Hakuna ujumbe uliopangwa';

  @override
  String menuSendsOn(String date) {
    return 'Inatuma tarehe $date';
  }

  @override
  String get menuDisappearingMessages => 'Ujumbe Unaopotea';

  @override
  String get menuDisappearingSubtitle =>
      'Ujumbe unafutwa kiotomatiki baada ya muda uliochaguliwa.';

  @override
  String get menuTtlOff => 'Zimwe';

  @override
  String get menuTtl1h => 'Saa 1';

  @override
  String get menuTtl24h => 'Saa 24';

  @override
  String get menuTtl7d => 'Siku 7';

  @override
  String get menuAttachPhoto => 'Picha';

  @override
  String get menuAttachFile => 'Faili';

  @override
  String get menuAttachVideo => 'Video';

  @override
  String get mediaTitle => 'Midia';

  @override
  String get mediaFileLabel => 'FAILI';

  @override
  String mediaPhotosTab(int count) {
    return 'Picha ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Faili ($count)';
  }

  @override
  String get mediaNoPhotos => 'Hakuna picha bado';

  @override
  String get mediaNoFiles => 'Hakuna faili bado';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Imehifadhiwa kwenye Vipakuliwa/$name';
  }

  @override
  String get mediaFailedToSave => 'Imeshindwa kuhifadhi faili';

  @override
  String get statusNewStatus => 'Hali Mpya';

  @override
  String get statusPublish => 'Chapisha';

  @override
  String get statusExpiresIn24h => 'Hali inaisha baada ya saa 24';

  @override
  String get statusWhatsOnYourMind => 'Unafikiri nini?';

  @override
  String get statusPhotoAttached => 'Picha imeambatishwa';

  @override
  String get statusAttachPhoto => 'Ambatisha picha (si lazima)';

  @override
  String get statusEnterText => 'Tafadhali weka maandishi kwa hali yako.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Imeshindwa kuchagua picha: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Imeshindwa kuchapisha: $error';
  }

  @override
  String get panicSetPanicKey => 'Weka Ufunguo wa Dharura';

  @override
  String get panicEmergencySelfDestruct => 'Kujiharibu kwa dharura';

  @override
  String get panicIrreversible => 'Kitendo hiki hakiwezi kutenduliwa';

  @override
  String get panicWarningBody =>
      'Kuweka ufunguo huu kwenye skrini ya kufunga kunafuta MARA MOJA data YOTE — ujumbe, anwani, funguo, utambulisho. Tumia ufunguo tofauti na nenosiri lako la kawaida.';

  @override
  String get panicKeyHint => 'Ufunguo wa dharura';

  @override
  String get panicConfirmHint => 'Thibitisha ufunguo wa dharura';

  @override
  String get panicMinChars =>
      'Ufunguo wa dharura lazima uwe na angalau herufi 8';

  @override
  String get panicKeysDoNotMatch => 'Funguo hazilingani';

  @override
  String get panicSetFailed =>
      'Imeshindwa kuhifadhi ufunguo wa dharura — tafadhali jaribu tena';

  @override
  String get passwordSetAppPassword => 'Weka Nenosiri la Programu';

  @override
  String get passwordProtectsMessages =>
      'Inalinda ujumbe wako ukiwa haujatumika';

  @override
  String get passwordInfoBanner =>
      'Inahitajika kila wakati unapofungua Pulse. Ikiwa utaisahau, data yako haiwezi kurejeshwa.';

  @override
  String get passwordHint => 'Nenosiri';

  @override
  String get passwordConfirmHint => 'Thibitisha nenosiri';

  @override
  String get passwordSetButton => 'Weka Nenosiri';

  @override
  String get passwordSkipForNow => 'Ruka kwa sasa';

  @override
  String get passwordMinChars => 'Nenosiri lazima liwe na angalau herufi 6';

  @override
  String get passwordsDoNotMatch => 'Manenosiri hayalingani';

  @override
  String get profileCardSaved => 'Wasifu umehifadhiwa!';

  @override
  String get profileCardE2eeIdentity => 'Utambulisho wa E2EE';

  @override
  String get profileCardDisplayName => 'Jina la Kuonyesha';

  @override
  String get profileCardDisplayNameHint => 'k.m. Juma Ali';

  @override
  String get profileCardAbout => 'Kuhusu';

  @override
  String get profileCardSaveProfile => 'Hifadhi Wasifu';

  @override
  String get profileCardYourName => 'Jina Lako';

  @override
  String get profileCardAddressCopied => 'Anwani imenakiliwa!';

  @override
  String get profileCardInboxAddress => 'Anwani Yako ya Kikasha';

  @override
  String get profileCardInboxAddresses => 'Anwani Zako za Kikasha';

  @override
  String get profileCardShareAllAddresses =>
      'Shiriki Anwani Zote (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Shiriki na anwani ili waweze kukutumia ujumbe.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Anwani zote $count zimenakiliwa kama kiungo kimoja!';
  }

  @override
  String get settingsMyProfile => 'Wasifu Wangu';

  @override
  String get settingsYourInboxAddress => 'Anwani Yako ya Kikasha';

  @override
  String get settingsMyQrCode => 'Msimbo Wangu wa QR';

  @override
  String get settingsMyQrSubtitle => 'Shiriki anwani yako kama QR inayoskaniwa';

  @override
  String get settingsShareMyAddress => 'Shiriki Anwani Yangu';

  @override
  String get settingsNoAddressYet =>
      'Hakuna anwani bado — hifadhi mipangilio kwanza';

  @override
  String get settingsInviteLink => 'Kiungo cha Mwaliko';

  @override
  String get settingsRawAddress => 'Anwani Ghafi';

  @override
  String get settingsCopyLink => 'Nakili Kiungo';

  @override
  String get settingsCopyAddress => 'Nakili Anwani';

  @override
  String get settingsInviteLinkCopied => 'Kiungo cha mwaliko kimenakiliwa';

  @override
  String get settingsAppearance => 'Muonekano';

  @override
  String get settingsThemeEngine => 'Injini ya Mandhari';

  @override
  String get settingsThemeEngineSubtitle => 'Binafsisha rangi na fonti';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle =>
      'Funguo za E2EE zimehifadhiwa kwa usalama';

  @override
  String get settingsActive => 'INATUMIKA';

  @override
  String get settingsIdentityBackup => 'Nakala ya Utambulisho';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Hamisha nje au ndani utambulisho wako wa Signal';

  @override
  String get settingsIdentityBackupBody =>
      'Hamisha nje funguo zako za utambulisho wa Signal hadi msimbo wa nakala, au rejesha kutoka iliyopo.';

  @override
  String get settingsTransferDevice => 'Hamisha hadi Kifaa Kingine';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Hamisha utambulisho wako kupitia LAN au Nostr relay';

  @override
  String get settingsExportIdentity => 'Hamisha Nje Utambulisho';

  @override
  String get settingsExportIdentityBody =>
      'Nakili msimbo huu wa nakala na uhifadhi kwa usalama:';

  @override
  String get settingsSaveFile => 'Hifadhi Faili';

  @override
  String get settingsImportIdentity => 'Hamisha Ndani Utambulisho';

  @override
  String get settingsImportIdentityBody =>
      'Bandika msimbo wako wa nakala hapa chini. Hii itaandika juu ya utambulisho wako wa sasa.';

  @override
  String get settingsPasteBackupCode => 'Bandika msimbo wa nakala hapa…';

  @override
  String get settingsIdentityImported =>
      'Utambulisho + anwani zimehamishwa ndani! Anzisha upya programu kutekeleza.';

  @override
  String get settingsSecurity => 'Usalama';

  @override
  String get settingsAppPassword => 'Nenosiri la Programu';

  @override
  String get settingsPasswordEnabled =>
      'Imewezeshwa — inahitajika kila unapoanzisha';

  @override
  String get settingsPasswordDisabled =>
      'Imezimwa — programu inafunguka bila nenosiri';

  @override
  String get settingsChangePassword => 'Badilisha Nenosiri';

  @override
  String get settingsChangePasswordSubtitle =>
      'Sasisha nenosiri lako la kufunga programu';

  @override
  String get settingsSetPanicKey => 'Weka Ufunguo wa Dharura';

  @override
  String get settingsChangePanicKey => 'Badilisha Ufunguo wa Dharura';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Sasisha ufunguo wa kufuta kwa dharura';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Ufunguo mmoja unaofuta data yote mara moja';

  @override
  String get settingsRemovePanicKey => 'Ondoa Ufunguo wa Dharura';

  @override
  String get settingsRemovePanicKeySubtitle => 'Zima kujiharibu kwa dharura';

  @override
  String get settingsRemovePanicKeyBody =>
      'Kujiharibu kwa dharura kutazimwa. Unaweza kuiwasha tena wakati wowote.';

  @override
  String get settingsDisableAppPassword => 'Zima Nenosiri la Programu';

  @override
  String get settingsEnterCurrentPassword =>
      'Weka nenosiri lako la sasa kuthibitisha';

  @override
  String get settingsCurrentPassword => 'Nenosiri la sasa';

  @override
  String get settingsIncorrectPassword => 'Nenosiri lisilo sahihi';

  @override
  String get settingsPasswordUpdated => 'Nenosiri limesasishwa';

  @override
  String get settingsChangePasswordProceed =>
      'Weka nenosiri lako la sasa kuendelea';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsBackupMessages => 'Nakala ya Ujumbe';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Hamisha nje historia ya ujumbe iliyosimbwa hadi faili';

  @override
  String get settingsRestoreMessages => 'Rejesha Ujumbe';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Hamisha ndani ujumbe kutoka faili ya nakala';

  @override
  String get settingsExportKeys => 'Hamisha Nje Funguo';

  @override
  String get settingsExportKeysSubtitle =>
      'Hifadhi funguo za utambulisho kwenye faili iliyosimbwa';

  @override
  String get settingsImportKeys => 'Hamisha Ndani Funguo';

  @override
  String get settingsImportKeysSubtitle =>
      'Rejesha funguo za utambulisho kutoka faili iliyohamishwa nje';

  @override
  String get settingsBackupPassword => 'Nenosiri la nakala';

  @override
  String get settingsPasswordCannotBeEmpty => 'Nenosiri haliwezi kuwa tupu';

  @override
  String get settingsPasswordMin4Chars =>
      'Nenosiri lazima liwe na angalau herufi 4';

  @override
  String get settingsCallsTurn => 'Simu & TURN';

  @override
  String get settingsLocalNetwork => 'Mtandao wa Ndani';

  @override
  String get settingsCensorshipResistance => 'Kupinga Udhibiti';

  @override
  String get settingsNetwork => 'Mtandao';

  @override
  String get settingsProxyTunnels => 'Proksi & Handaki';

  @override
  String get settingsTurnServers => 'Seva za TURN';

  @override
  String get settingsProviderTitle => 'Mtoa Huduma';

  @override
  String get settingsLanFallback => 'Hifadhi ya LAN';

  @override
  String get settingsLanFallbackSubtitle =>
      'Tangaza uwepo na peleka ujumbe kwenye mtandao wa ndani wakati mtandao haupatikani. Zima kwenye mitandao isiyoaminika (Wi-Fi ya umma).';

  @override
  String get settingsBgDelivery => 'Utoaji wa Usuli';

  @override
  String get settingsBgDeliverySubtitle =>
      'Endelea kupokea ujumbe wakati programu imepunguzwa. Inaonyesha arifa ya kudumu.';

  @override
  String get settingsYourInboxProvider => 'Mtoa Huduma Wako wa Kikasha';

  @override
  String get settingsConnectionDetails => 'Maelezo ya Muunganisho';

  @override
  String get settingsSaveAndConnect => 'Hifadhi & Unganisha';

  @override
  String get settingsSecondaryInboxes => 'Vikasha vya Pili';

  @override
  String get settingsAddSecondaryInbox => 'Ongeza Kikasha cha Pili';

  @override
  String get settingsAdvanced => 'Ya Juu';

  @override
  String get settingsDiscover => 'Gundua';

  @override
  String get settingsAbout => 'Kuhusu';

  @override
  String get settingsPrivacyPolicy => 'Sera ya Faragha';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Jinsi Pulse inavyolinda data yako';

  @override
  String get settingsCrashReporting => 'Ripoti za kuanguka';

  @override
  String get settingsCrashReportingSubtitle =>
      'Tuma ripoti za kuanguka zisizojulikana kusaidia kuboresha Pulse. Hakuna maudhui ya ujumbe au anwani yanayotumwa kamwe.';

  @override
  String get settingsCrashReportingEnabled =>
      'Ripoti za kuanguka zimewezeshwa — anzisha upya programu kutekeleza';

  @override
  String get settingsCrashReportingDisabled =>
      'Ripoti za kuanguka zimezimwa — anzisha upya programu kutekeleza';

  @override
  String get settingsSensitiveOperation => 'Operesheni Nyeti';

  @override
  String get settingsSensitiveOperationBody =>
      'Funguo hizi ni utambulisho wako. Mtu yeyote mwenye faili hii anaweza kujifanya kuwa wewe. Ihifadhi kwa usalama na uifute baada ya kuhamisha.';

  @override
  String get settingsIUnderstandContinue => 'Ninaelewa, Endelea';

  @override
  String get settingsReplaceIdentity => 'Badilisha Utambulisho?';

  @override
  String get settingsReplaceIdentityBody =>
      'Hii itaandika juu ya funguo zako za utambulisho za sasa. Vikao vyako vya Signal vilivyopo vitabatilishwa na anwani zitahitaji kuanzisha tena usimbaji. Programu itahitaji kuanzishwa upya.';

  @override
  String get settingsReplaceKeys => 'Badilisha Funguo';

  @override
  String get settingsKeysImported => 'Funguo Zimehamishwa Ndani';

  @override
  String settingsKeysImportedBody(int count) {
    return 'Funguo $count zimehamishwa ndani kwa mafanikio. Tafadhali anzisha upya programu kuanzisha na utambulisho mpya.';
  }

  @override
  String get settingsRestartNow => 'Anzisha Upya Sasa';

  @override
  String get settingsLater => 'Baadaye';

  @override
  String get profileGroupLabel => 'Kikundi';

  @override
  String get profileAddButton => 'Ongeza';

  @override
  String get profileKickButton => 'Fukuza';

  @override
  String get dataSectionTitle => 'Data';

  @override
  String get dataBackupMessages => 'Nakala ya Ujumbe';

  @override
  String get dataBackupPasswordSubtitle =>
      'Chagua nenosiri kwa kusimba nakala yako ya ujumbe.';

  @override
  String get dataBackupConfirmLabel => 'Unda Nakala';

  @override
  String get dataCreatingBackup => 'Inaunda Nakala';

  @override
  String get dataBackupPreparing => 'Inaandaa...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Inahamisha nje ujumbe $done kati ya $total...';
  }

  @override
  String get dataBackupSavingFile => 'Inahifadhi faili...';

  @override
  String get dataSaveMessageBackupDialog => 'Hifadhi Nakala ya Ujumbe';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Nakala imehifadhiwa (ujumbe $count)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Nakala imeshindwa — hakuna data iliyohamishwa nje';

  @override
  String dataBackupFailedError(String error) {
    return 'Nakala imeshindwa: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Chagua Nakala ya Ujumbe';

  @override
  String get dataInvalidBackupFile => 'Faili ya nakala si sahihi (ndogo sana)';

  @override
  String get dataNotValidBackupFile => 'Si faili halali ya nakala ya Pulse';

  @override
  String get dataRestoreMessages => 'Rejesha Ujumbe';

  @override
  String get dataRestorePasswordSubtitle =>
      'Weka nenosiri lililotumika kuunda nakala hii.';

  @override
  String get dataRestoreConfirmLabel => 'Rejesha';

  @override
  String get dataRestoringMessages => 'Inarejeshea Ujumbe';

  @override
  String get dataRestoreDecrypting => 'Inasimbua...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Inahamisha ndani ujumbe $done kati ya $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Kurejesha kumeshindwa — nenosiri lisilo sahihi au faili iliyoharibika';

  @override
  String dataRestoreSuccess(int count) {
    return 'Ujumbe $count mpya umerejeshwa';
  }

  @override
  String get dataRestoreNothingNew =>
      'Hakuna ujumbe mpya wa kuhamisha ndani (wote tayari wapo)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Kurejesha kumeshindwa: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Chagua Uhamishaji wa Funguo';

  @override
  String get dataNotValidKeyFile =>
      'Si faili halali ya uhamishaji wa funguo ya Pulse';

  @override
  String get dataExportKeys => 'Hamisha Nje Funguo';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Chagua nenosiri kwa kusimba uhamishaji wako wa funguo.';

  @override
  String get dataExportKeysConfirmLabel => 'Hamisha Nje';

  @override
  String get dataExportingKeys => 'Inahamisha Nje Funguo';

  @override
  String get dataExportingKeysStatus => 'Inasimba funguo za utambulisho...';

  @override
  String get dataSaveKeyExportDialog => 'Hifadhi Uhamishaji wa Funguo';

  @override
  String dataKeysExportedTo(String path) {
    return 'Funguo zimehamishwa nje hadi:\n$path';
  }

  @override
  String get dataExportFailed =>
      'Kuhamisha nje kumeshindwa — hakuna funguo zilizopatikana';

  @override
  String dataExportFailedError(String error) {
    return 'Kuhamisha nje kumeshindwa: $error';
  }

  @override
  String get dataImportKeys => 'Hamisha Ndani Funguo';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Weka nenosiri lililotumika kusimba uhamishaji huu wa funguo.';

  @override
  String get dataImportKeysConfirmLabel => 'Hamisha Ndani';

  @override
  String get dataImportingKeys => 'Inahamisha Ndani Funguo';

  @override
  String get dataImportingKeysStatus => 'Inasimbua funguo za utambulisho...';

  @override
  String get dataImportFailed =>
      'Kuhamisha ndani kumeshindwa — nenosiri lisilo sahihi au faili iliyoharibika';

  @override
  String dataImportFailedError(String error) {
    return 'Kuhamisha ndani kumeshindwa: $error';
  }

  @override
  String get securitySectionTitle => 'Usalama';

  @override
  String get securityIncorrectPassword => 'Nenosiri lisilo sahihi';

  @override
  String get securityPasswordUpdated => 'Nenosiri limesasishwa';

  @override
  String get appearanceSectionTitle => 'Muonekano';

  @override
  String appearanceExportFailed(String error) {
    return 'Kuhamisha nje kumeshindwa: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Imehifadhiwa kwenye $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Kuhifadhi kumeshindwa: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Kuhamisha ndani kumeshindwa: $error';
  }

  @override
  String get aboutSectionTitle => 'Kuhusu';

  @override
  String get providerPublicKey => 'Ufunguo wa Umma';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Imesanidiwa kiotomatiki kutoka nenosiri lako la kurejesha. Relay imegunduliwa kiotomatiki.';

  @override
  String get providerKeyStoredLocally =>
      'Ufunguo wako umehifadhiwa ndani ya kifaa kwenye hifadhi salama — haujatumwa kamwe kwa seva yoyote.';

  @override
  String get providerOxenInfo =>
      'Mtandao wa Oxen/Session — E2EE kupitia njia za vitunguu. Kitambulisho chako cha Session kimeundwa kiotomatiki na kuhifadhiwa kwa usalama. Nodi zimegunduliwa kiotomatiki kutoka nodi za mbegu zilizojengwa ndani.';

  @override
  String get providerAdvanced => 'Ya Juu';

  @override
  String get providerSaveAndConnect => 'Hifadhi & Unganisha';

  @override
  String get providerAddSecondaryInbox => 'Ongeza Kikasha cha Pili';

  @override
  String get providerSecondaryInboxes => 'Vikasha vya Pili';

  @override
  String get providerYourInboxProvider => 'Mtoa Huduma Wako wa Kikasha';

  @override
  String get providerConnectionDetails => 'Maelezo ya Muunganisho';

  @override
  String get addContactTitle => 'Ongeza Anwani';

  @override
  String get addContactInviteLinkLabel => 'Kiungo cha Mwaliko au Anwani';

  @override
  String get addContactTapToPaste => 'Gusa kubandika kiungo cha mwaliko';

  @override
  String get addContactPasteTooltip => 'Bandika kutoka ubao wa kunakili';

  @override
  String get addContactAddressDetected => 'Anwani ya mawasiliano imegunduliwa';

  @override
  String addContactRoutesDetected(int count) {
    return 'Njia $count zimegunduliwa — SmartRouter inachagua ya haraka zaidi';
  }

  @override
  String get addContactFetchingProfile => 'Inapata wasifu…';

  @override
  String addContactProfileFound(String name) {
    return 'Imepatikana: $name';
  }

  @override
  String get addContactNoProfileFound => 'Hakuna wasifu uliopatikana';

  @override
  String get addContactDisplayNameLabel => 'Jina la Kuonyesha';

  @override
  String get addContactDisplayNameHint => 'Unataka kuwaita nini?';

  @override
  String get addContactAddManually => 'Ongeza anwani kwa mikono';

  @override
  String get addContactButton => 'Ongeza Anwani';

  @override
  String get networkDiagnosticsTitle => 'Uchunguzi wa Mtandao';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr Relay';

  @override
  String get networkDiagnosticsDirect => 'Moja kwa moja';

  @override
  String get networkDiagnosticsTorOnly => 'Tor pekee';

  @override
  String get networkDiagnosticsBest => 'Bora';

  @override
  String get networkDiagnosticsNone => 'hakuna';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Hali';

  @override
  String get networkDiagnosticsConnected => 'Imeunganishwa';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Inaunganisha $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Imezimwa';

  @override
  String get networkDiagnosticsTransport => 'Usafiri';

  @override
  String get networkDiagnosticsInfrastructure => 'Miundombinu';

  @override
  String get networkDiagnosticsOxenNodes => 'Nodi za Oxen';

  @override
  String get networkDiagnosticsTurnServers => 'Seva za TURN';

  @override
  String get networkDiagnosticsLastProbe => 'Uchunguzi wa mwisho';

  @override
  String get networkDiagnosticsRunning => 'Inaendesha...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Endesha Uchunguzi';

  @override
  String get networkDiagnosticsForceReprobe =>
      'Lazimisha Uchunguzi Kamili Upya';

  @override
  String get networkDiagnosticsJustNow => 'sasa hivi';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'dakika $minutes zilizopita';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'saa $hours zilizopita';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'siku $days zilizopita';
  }

  @override
  String get homeNoEch => 'Hakuna ECH';

  @override
  String get homeNoEchTooltip =>
      'uTLS proxy haipatikani — ECH imezimwa.\nAlama ya TLS inaonekana kwa DPI.';

  @override
  String get settingsTitle => 'Mipangilio';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Imehifadhiwa & imeunganishwa na $provider';
  }

  @override
  String get settingsTorFailedToStart =>
      'Tor iliyojengwa ndani imeshindwa kuanza';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon imeshindwa kuanza';

  @override
  String get verifyTitle => 'Thibitisha Nambari ya Usalama';

  @override
  String get verifyIdentityVerified => 'Utambulisho Umethibitishwa';

  @override
  String get verifyNotYetVerified => 'Bado Haijathibitishwa';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Umethibitisha nambari ya usalama ya $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Linganisha nambari hizi na $name ana kwa ana au kupitia njia ya kuaminika.';
  }

  @override
  String get verifyExplanation =>
      'Kila mazungumzo yana nambari ya usalama ya kipekee. Ikiwa nyinyi wote mnaona nambari sawa kwenye vifaa vyenu, muunganisho wenu umethibitishwa mwisho-hadi-mwisho.';

  @override
  String verifyContactKey(String name) {
    return 'Ufunguo wa $name';
  }

  @override
  String get verifyYourKey => 'Ufunguo Wako';

  @override
  String get verifyRemoveVerification => 'Ondoa Uthibitisho';

  @override
  String get verifyMarkAsVerified => 'Weka kama Imethibitishwa';

  @override
  String verifyAfterReinstall(String name) {
    return 'Ikiwa $name atasakinisha upya programu, nambari ya usalama itabadilika na uthibitisho utaondolewa kiotomatiki.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Weka kama imethibitishwa tu baada ya kulinganisha nambari na $name kupitia simu ya sauti au ana kwa ana.';
  }

  @override
  String get verifyNoSession =>
      'Hakuna kikao cha usimbaji kilichoanzishwa bado. Tuma ujumbe kwanza kutengeneza nambari za usalama.';

  @override
  String get verifyNoKeyAvailable => 'Hakuna ufunguo unaopatikana';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Alama ya kidole ya $label imenakiliwa';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL ya Hifadhidata';

  @override
  String get providerOptionalHint => 'Si lazima';

  @override
  String get providerWebApiKeyLabel => 'Ufunguo wa Web API';

  @override
  String get providerOptionalForPublicDb => 'Si lazima kwa hifadhidata ya umma';

  @override
  String get providerRelayUrlLabel => 'URL ya Relay';

  @override
  String get providerPrivateKeyLabel => 'Ufunguo wa Siri';

  @override
  String get providerPrivateKeyNsecLabel => 'Ufunguo wa Siri (nsec)';

  @override
  String get providerStorageNodeLabel => 'URL ya Nodi ya Hifadhi (si lazima)';

  @override
  String get providerStorageNodeHint =>
      'Acha tupu kwa nodi za mbegu zilizojengwa ndani';

  @override
  String get transferInvalidCodeFormat =>
      'Umbizo la msimbo halijatambuliwa — lazima lianze na LAN: au NOS:';

  @override
  String get profileCardFingerprintCopied => 'Alama ya kidole imenakiliwa';

  @override
  String get profileCardAboutHint => 'Faragha kwanza 🔒';

  @override
  String get profileCardSaveButton => 'Hifadhi Wasifu';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Hamisha nje ujumbe uliosimbwa, anwani na picha za wasifu hadi faili';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Sauti';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Imepelekwa kwa $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Imepelekwa kwa $count';
  }

  @override
  String get groupStatusDialogTitle => 'Maelezo ya Ujumbe';

  @override
  String get groupStatusRead => 'Imesomwa';

  @override
  String get groupStatusDelivered => 'Imepelekwa';

  @override
  String get groupStatusPending => 'Inasubiri';

  @override
  String get groupStatusNoData => 'Hakuna taarifa za uwasilishaji bado';

  @override
  String get profileTransferAdmin => 'Fanya Msimamizi';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Fanya $name msimamizi mpya?';
  }

  @override
  String get profileTransferAdminBody =>
      'Utapoteza haki za msimamizi. Hii haiwezi kutenduliwa.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name sasa ndiye msimamizi';
  }

  @override
  String get profileAdminBadge => 'Msimamizi';

  @override
  String get privacyPolicyTitle => 'Sera ya Faragha';

  @override
  String get privacyOverviewHeading => 'Muhtasari';

  @override
  String get privacyOverviewBody =>
      'Pulse ni mjumbe usio na seva, uliosimbwa mwisho-hadi-mwisho. Faragha yako si kipengele tu — ni usanifu. Hakuna seva za Pulse. Hakuna akaunti zinazohifadhiwa popote. Hakuna data inayokusanywa, kupelekwa, au kuhifadhiwa na wasanidi.';

  @override
  String get privacyDataCollectionHeading => 'Ukusanyaji wa Data';

  @override
  String get privacyDataCollectionBody =>
      'Pulse haikuchanyi data yoyote ya kibinafsi. Hasa:\n\n- Hakuna barua pepe, nambari ya simu, au jina halisi linalohitajika\n- Hakuna uchambuzi, ufuatiliaji, au telemitria\n- Hakuna vitambulisho vya matangazo\n- Hakuna ufikio wa orodha ya anwani\n- Hakuna nakala za wingu (ujumbe upo kwenye kifaa chako pekee)\n- Hakuna metadata inayotumwa kwa seva yoyote ya Pulse (hakuna zozote)';

  @override
  String get privacyEncryptionHeading => 'Usimbaji';

  @override
  String get privacyEncryptionBody =>
      'Ujumbe wote umesimbwa kwa kutumia Signal Protocol (Double Ratchet na makubaliano ya funguo ya X3DH). Funguo za usimbaji zinatengenezwa na kuhifadhiwa kwenye kifaa chako pekee. Hakuna mtu — ikiwa ni pamoja na wasanidi — anayeweza kusoma ujumbe wako.';

  @override
  String get privacyNetworkHeading => 'Usanifu wa Mtandao';

  @override
  String get privacyNetworkBody =>
      'Pulse inatumia adapta za usafiri zilizoshirikiana (Nostr relay, nodi za huduma za Session/Oxen, Firebase Realtime Database, LAN). Usafiri huu unabeba maandishi yaliyosimbwa tu. Waendeshaji wa relay wanaweza kuona anwani yako ya IP na kiasi cha trafiki, lakini hawawezi kusimbua maudhui ya ujumbe.\n\nWakati Tor imewezeshwa, anwani yako ya IP pia imefichwa kutoka kwa waendeshaji wa relay.';

  @override
  String get privacyStunHeading => 'Seva za STUN/TURN';

  @override
  String get privacyStunBody =>
      'Simu za sauti na video zinatumia WebRTC na usimbaji wa DTLS-SRTP. Seva za STUN (zinazotumiwa kugundua IP yako ya umma kwa muunganisho wa P2P) na seva za TURN (zinazotumiwa kupeleka midia wakati muunganisho wa moja kwa moja unashindwa) zinaweza kuona anwani yako ya IP na muda wa simu, lakini haziwezi kusimbua maudhui ya simu.\n\nUnaweza kusanidi seva yako ya TURN katika Mipangilio kwa faragha ya juu zaidi.';

  @override
  String get privacyCrashHeading => 'Ripoti za Kuanguka';

  @override
  String get privacyCrashBody =>
      'Ikiwa ripoti za kuanguka za Sentry zimewezeshwa (kupitia SENTRY_DSN wakati wa kujenga), ripoti za kuanguka zisizojulikana zinaweza kutumwa. Hizi hazina maudhui ya ujumbe, taarifa za anwani, au taarifa za kutambulisha mtu. Ripoti za kuanguka zinaweza kuzimwa wakati wa kujenga kwa kuondoa DSN.';

  @override
  String get privacyPasswordHeading => 'Nenosiri & Funguo';

  @override
  String get privacyPasswordBody =>
      'Nenosiri lako la kurejesha linatumika kupata funguo za kisiri kupitia Argon2id (KDF ngumu ya kumbukumbu). Nenosiri halitumwi popote. Ukipoteza nenosiri lako, akaunti yako haiwezi kurejeshwa — hakuna seva ya kuiweka upya.';

  @override
  String get privacyFontsHeading => 'Fonti';

  @override
  String get privacyFontsBody =>
      'Pulse inajumuisha fonti zote ndani ya kifaa. Hakuna maombi yanayotumwa kwa Google Fonts au huduma yoyote ya fonti ya nje.';

  @override
  String get privacyThirdPartyHeading => 'Huduma za Wahusika Wengine';

  @override
  String get privacyThirdPartyBody =>
      'Pulse haishirikiani na mitandao yoyote ya matangazo, watoa uchambuzi, majukwaa ya mitandao ya kijamii, au madalali wa data. Muunganisho pekee wa mtandao ni kwa relay za usafiri unazosanidi.';

  @override
  String get privacyOpenSourceHeading => 'Chanzo Huria';

  @override
  String get privacyOpenSourceBody =>
      'Pulse ni programu ya chanzo huria. Unaweza kukagua msimbo kamili wa chanzo kuthibitisha madai haya ya faragha.';

  @override
  String get privacyContactHeading => 'Mawasiliano';

  @override
  String get privacyContactBody =>
      'Kwa maswali yanayohusiana na faragha, fungua suala kwenye hazina ya mradi.';

  @override
  String get privacyLastUpdated => 'Ilisasishwa mwisho: Machi 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Kuhifadhi kumeshindwa: $error';
  }

  @override
  String get themeEngineTitle => 'Injini ya Mandhari';

  @override
  String get torBuiltInTitle => 'Tor Iliyojengwa Ndani';

  @override
  String get torConnectedSubtitle =>
      'Imeunganishwa — Nostr inapitia 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Inaunganisha… $pct%';
  }

  @override
  String get torNotRunning => 'Haifanyi kazi — gusa kubonyeza kuanzisha upya';

  @override
  String get torDescription =>
      'Inapitisha Nostr kupitia Tor (Snowflake kwa mitandao iliyodhibitiwa)';

  @override
  String get torNetworkDiagnostics => 'Uchunguzi wa Mtandao';

  @override
  String get torTransportLabel => 'Usafiri: ';

  @override
  String get torPtAuto => 'Otomatiki';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Kawaida';

  @override
  String get torTimeoutLabel => 'Muda wa kuisha: ';

  @override
  String get torInfoDescription =>
      'Ikiwa imewezeshwa, muunganisho wa Nostr WebSocket unapitishwa kupitia Tor (SOCKS5). Tor Browser inasikiliza kwenye 127.0.0.1:9150. Daemon ya tor inayojitegemea inatumia bandari 9050. Muunganisho wa Firebase hauathiriki.';

  @override
  String get torRouteNostrTitle => 'Pitisha Nostr kupitia Tor';

  @override
  String get torManagedByBuiltin => 'Inadhibitiwa na Tor Iliyojengwa Ndani';

  @override
  String get torActiveRouting =>
      'Inatumika — trafiki ya Nostr inapitishwa kupitia Tor';

  @override
  String get torDisabled => 'Imezimwa';

  @override
  String get torProxySocks5 => 'Proksi ya Tor (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Mwenyeji wa Proksi';

  @override
  String get torProxyPortLabel => 'Bandari';

  @override
  String get torPortInfo =>
      'Tor Browser: bandari 9150  •  tor daemon: bandari 9050';

  @override
  String get i2pProxySocks5 => 'Proksi ya I2P (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P inatumia SOCKS5 kwenye bandari 4447 kwa chaguo-msingi. Unganisha na Nostr relay kupitia outproxy ya I2P (k.m. relay.damus.i2p) kuwasiliana na watumiaji kwenye usafiri wowote. Tor ina kipaumbele wakati zote mbili zimewezeshwa.';

  @override
  String get i2pRouteNostrTitle => 'Pitisha Nostr kupitia I2P';

  @override
  String get i2pActiveRouting =>
      'Inatumika — trafiki ya Nostr inapitishwa kupitia I2P';

  @override
  String get i2pDisabled => 'Imezimwa';

  @override
  String get i2pProxyHostLabel => 'Mwenyeji wa Proksi';

  @override
  String get i2pProxyPortLabel => 'Bandari';

  @override
  String get i2pPortInfo =>
      'Bandari ya chaguo-msingi ya SOCKS5 ya Router ya I2P: 4447';

  @override
  String get customProxySocks5 => 'Proksi Maalum (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Proksi maalum inapitisha trafiki kupitia V2Ray/Xray/Shadowsocks yako. CF Worker inafanya kazi kama proksi ya relay binafsi kwenye Cloudflare CDN — GFW inaona *.workers.dev, si relay halisi.';

  @override
  String get customSocks5ProxyTitle => 'Proksi Maalum ya SOCKS5';

  @override
  String get customProxyActive =>
      'Inatumika — trafiki inapitishwa kupitia SOCKS5';

  @override
  String get customProxyDisabled => 'Imezimwa';

  @override
  String get customProxyHostLabel => 'Mwenyeji wa Proksi';

  @override
  String get customProxyPortLabel => 'Bandari';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Kikoa cha Worker (si lazima)';

  @override
  String get customWorkerHelpTitle =>
      'Jinsi ya kusambaza CF Worker relay (bure)';

  @override
  String get customWorkerScriptCopied => 'Hati imenakiliwa!';

  @override
  String get customWorkerStep1 =>
      '1. Nenda dash.cloudflare.com → Workers & Pages\n2. Create Worker → bandika hati hii:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → nakili kikoa (k.m. my-relay.user.workers.dev)\n4. Bandika kikoa hapo juu → Hifadhi\n\nProgramu inaunganisha kiotomatiki: wss://domain/?r=relay_url\nGFW inaona: muunganisho kwa *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Imeunganishwa — SOCKS5 kwenye 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Inaunganisha…';

  @override
  String get psiphonNotRunning =>
      'Haifanyi kazi — gusa kubonyeza kuanzisha upya';

  @override
  String get psiphonDescription =>
      'Handaki ya haraka (~sekunde 3 kuanzisha, VPS 2000+ zinazozunguka)';

  @override
  String get turnCommunityServers => 'Seva za TURN za Jamii';

  @override
  String get turnCustomServer => 'Seva Maalum ya TURN (BYOD)';

  @override
  String get turnInfoDescription =>
      'Seva za TURN zinapeleka tu mtiririko uliosimbwa tayari (DTLS-SRTP). Mwendeshaji wa relay anaona IP yako na kiasi cha trafiki, lakini hawezi kusimbua simu. TURN inatumika tu wakati P2P ya moja kwa moja inashindwa (~15–20% ya muunganisho).';

  @override
  String get turnFreeLabel => 'BURE';

  @override
  String get turnServerUrlLabel => 'URL ya Seva ya TURN';

  @override
  String get turnServerUrlHint => 'turn:seva-yako.com:3478 au turns:...';

  @override
  String get turnUsernameLabel => 'Jina la mtumiaji';

  @override
  String get turnPasswordLabel => 'Nenosiri';

  @override
  String get turnOptionalHint => 'Si lazima';

  @override
  String get turnCustomInfo =>
      'Endesha coturn kwenye VPS yoyote ya \$5/mwezi kwa udhibiti wa juu. Hati tambulishi zinahifadhiwa ndani ya kifaa.';

  @override
  String get themePickerAppearance => 'Muonekano';

  @override
  String get themePickerAccentColor => 'Rangi ya Lafudhi';

  @override
  String get themeModeLight => 'Mwanga';

  @override
  String get themeModeDark => 'Giza';

  @override
  String get themeModeSystem => 'Mfumo';

  @override
  String get themeDynamicPresets => 'Mipangilio Tayari';

  @override
  String get themeDynamicPrimaryColor => 'Rangi ya Msingi';

  @override
  String get themeDynamicBorderRadius => 'Eneo la Pembeni';

  @override
  String get themeDynamicFont => 'Fonti';

  @override
  String get themeDynamicAppearance => 'Muonekano';

  @override
  String get themeDynamicUiStyle => 'Mtindo wa UI';

  @override
  String get themeDynamicUiStyleDescription =>
      'Inadhibiti jinsi mazungumzo, swichi na viashiria vinavyoonekana.';

  @override
  String get themeDynamicSharp => 'Mkali';

  @override
  String get themeDynamicRound => 'Duara';

  @override
  String get themeDynamicModeDark => 'Giza';

  @override
  String get themeDynamicModeLight => 'Mwanga';

  @override
  String get themeDynamicModeAuto => 'Otomatiki';

  @override
  String get themeDynamicPlatformAuto => 'Otomatiki';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'URL ya Firebase si sahihi. Inatarajiwa https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'URL ya relay si sahihi. Inatarajiwa wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'URL ya seva ya Pulse si sahihi. Inatarajiwa https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'URL ya Seva';

  @override
  String get providerPulseServerUrlHint => 'https://seva-yako:8443';

  @override
  String get providerPulseInviteLabel => 'Msimbo wa Mwaliko';

  @override
  String get providerPulseInviteHint => 'Msimbo wa mwaliko (ikiwa unahitajika)';

  @override
  String get providerPulseInfo =>
      'Relay iliyoendeshwa binafsi. Funguo zinatolewa kutoka nenosiri lako la kurejesha.';

  @override
  String get providerScreenTitle => 'Vikasha';

  @override
  String get providerSecondaryInboxesHeader => 'VIKASHA VYA PILI';

  @override
  String get providerSecondaryInboxesInfo =>
      'Vikasha vya pili vinapokea ujumbe kwa wakati mmoja kwa urudufisho.';

  @override
  String get providerRemoveTooltip => 'Ondoa';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... au hex';

  @override
  String get providerNostrPrivkeyHintFull =>
      'nsec1... au ufunguo wa siri wa hex';

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
  String get emojiNoRecent => 'Hakuna emoji za hivi karibuni';

  @override
  String get emojiSearchHint => 'Tafuta emoji...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Gusa kuzungumza';

  @override
  String get imageViewerSaveToDownloads => 'Hifadhi kwenye Vipakuliwa';

  @override
  String imageViewerSavedTo(String path) {
    return 'Imehifadhiwa kwenye $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'Sawa';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Lugha';

  @override
  String get settingsLanguageSubtitle => 'Lugha ya kuonyesha programu';

  @override
  String get settingsLanguageSystem => 'Chaguo-msingi la mfumo';

  @override
  String get onboardingLanguageTitle => 'Chagua lugha yako';

  @override
  String get onboardingLanguageSubtitle =>
      'Unaweza kubadilisha hii baadaye katika Mipangilio';
}
