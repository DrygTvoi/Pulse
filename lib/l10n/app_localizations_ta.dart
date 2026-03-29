// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'செய்திகளைத் தேடு...';

  @override
  String get search => 'தேடு';

  @override
  String get clearSearch => 'தேடலை அழி';

  @override
  String get closeSearch => 'தேடலை மூடு';

  @override
  String get moreOptions => 'மேலும் விருப்பங்கள்';

  @override
  String get back => 'பின்செல்';

  @override
  String get cancel => 'ரத்து';

  @override
  String get close => 'மூடு';

  @override
  String get confirm => 'உறுதிப்படுத்து';

  @override
  String get remove => 'நீக்கு';

  @override
  String get save => 'சேமி';

  @override
  String get add => 'சேர்';

  @override
  String get copy => 'நகலெடு';

  @override
  String get skip => 'தவிர்';

  @override
  String get done => 'முடிந்தது';

  @override
  String get apply => 'பொருத்து';

  @override
  String get export => 'ஏற்றுமதி';

  @override
  String get import => 'இறக்குமதி';

  @override
  String get homeNewGroup => 'புதிய குழு';

  @override
  String get homeSettings => 'அமைப்புகள்';

  @override
  String get homeSearching => 'செய்திகளைத் தேடுகிறது...';

  @override
  String get homeNoResults => 'முடிவுகள் எதுவும் இல்லை';

  @override
  String get homeNoChatHistory => 'இதுவரை உரையாடல் இல்லை';

  @override
  String homeTransportSwitched(String address) {
    return 'போக்குவரத்து மாற்றப்பட்டது → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name அழைக்கிறார்...';
  }

  @override
  String get homeAccept => 'ஏற்கவும்';

  @override
  String get homeDecline => 'நிராகரி';

  @override
  String get homeLoadEarlier => 'பழைய செய்திகளை ஏற்று';

  @override
  String get homeChats => 'உரையாடல்கள்';

  @override
  String get homeSelectConversation => 'ஒரு உரையாடலைத் தேர்வுசெய்க';

  @override
  String get homeNoChatsYet => 'இதுவரை உரையாடல்கள் இல்லை';

  @override
  String get homeAddContactToStart => 'உரையாட ஒரு தொடர்பைச் சேர்க்கவும்';

  @override
  String get homeNewChat => 'புதிய உரையாடல்';

  @override
  String get homeNewChatTooltip => 'புதிய உரையாடல்';

  @override
  String get homeIncomingCallTitle => 'வரும் அழைப்பு';

  @override
  String get homeIncomingGroupCallTitle => 'வரும் குழு அழைப்பு';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — குழு அழைப்பு வருகிறது';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return '\"$query\" உடன் பொருந்தும் உரையாடல்கள் இல்லை';
  }

  @override
  String get homeSectionChats => 'உரையாடல்கள்';

  @override
  String get homeSectionMessages => 'செய்திகள்';

  @override
  String get homeDbEncryptionUnavailable =>
      'தரவுத்தள குறியாக்கம் கிடைக்கவில்லை — முழு பாதுகாப்பிற்கு SQLCipher நிறுவுக';

  @override
  String get chatFileTooLargeGroup =>
      'குழு உரையாடலில் 512 KB-க்கு மேற்பட்ட கோப்புகள் ஆதரிக்கப்படவில்லை';

  @override
  String get chatLargeFile => 'பெரிய கோப்பு';

  @override
  String get chatCancel => 'ரத்து';

  @override
  String get chatSend => 'அனுப்பு';

  @override
  String get chatFileTooLarge => 'கோப்பு மிகப்பெரியது — அதிகபட்ச அளவு 100 MB';

  @override
  String get chatMicDenied => 'ஒலிவாங்கி அனுமதி மறுக்கப்பட்டது';

  @override
  String get chatVoiceFailed =>
      'குரல் செய்தியைச் சேமிக்க முடியவில்லை — கிடைக்கும் சேமிப்பிடத்தை சரிபார்க்கவும்';

  @override
  String get chatScheduleFuture =>
      'திட்டமிடப்பட்ட நேரம் எதிர்காலத்தில் இருக்க வேண்டும்';

  @override
  String get chatToday => 'இன்று';

  @override
  String get chatYesterday => 'நேற்று';

  @override
  String get chatEdited => 'திருத்தப்பட்டது';

  @override
  String get chatYou => 'நீங்கள்';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'இந்தக் கோப்பு $size MB. பெரிய கோப்புகளை அனுப்புவது சில நெட்வொர்க்குகளில் மெதுவாக இருக்கலாம். தொடரவா?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return '$name-இன் பாதுகாப்பு விசை மாறிவிட்டது. சரிபார்க்க தட்டவும்.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return '$name-க்கு செய்தியை குறியாக்கம் செய்ய முடியவில்லை — செய்தி அனுப்பப்படவில்லை.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return '$name-க்கான பாதுகாப்பு எண் மாறிவிட்டது. சரிபார்க்க தட்டவும்.';
  }

  @override
  String get chatNoMessagesFound => 'செய்திகள் எதுவும் இல்லை';

  @override
  String get chatMessagesE2ee =>
      'செய்திகள் எண்ட்-டு-எண்ட் குறியாக்கம் செய்யப்பட்டுள்ளன';

  @override
  String get chatSayHello => 'வணக்கம் சொல்லுங்கள்';

  @override
  String get appBarOnline => 'ஆன்லைன்';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'தட்டச்சு செய்கிறார்';

  @override
  String get appBarSearchMessages => 'செய்திகளைத் தேடு...';

  @override
  String get appBarMute => 'ஒலியடக்கு';

  @override
  String get appBarUnmute => 'ஒலி இயக்கு';

  @override
  String get appBarMedia => 'மீடியா';

  @override
  String get appBarDisappearing => 'மறையும் செய்திகள்';

  @override
  String get appBarDisappearingOn => 'மறையும்: இயக்கம்';

  @override
  String get appBarGroupSettings => 'குழு அமைப்புகள்';

  @override
  String get appBarSearchTooltip => 'செய்திகளைத் தேடு';

  @override
  String get appBarVoiceCall => 'குரல் அழைப்பு';

  @override
  String get appBarVideoCall => 'காணொலி அழைப்பு';

  @override
  String get inputMessage => 'செய்தி...';

  @override
  String get inputAttachFile => 'கோப்பை இணை';

  @override
  String get inputSendMessage => 'செய்தி அனுப்பு';

  @override
  String get inputRecordVoice => 'குரல் செய்தி பதிவு செய்';

  @override
  String get inputSendVoice => 'குரல் செய்தி அனுப்பு';

  @override
  String get inputCancelReply => 'பதில் ரத்து';

  @override
  String get inputCancelEdit => 'திருத்தம் ரத்து';

  @override
  String get inputCancelRecording => 'பதிவு ரத்து';

  @override
  String get inputRecording => 'பதிவு செய்கிறது…';

  @override
  String get inputEditingMessage => 'செய்தி திருத்தப்படுகிறது';

  @override
  String get inputPhoto => 'புகைப்படம்';

  @override
  String get inputVoiceMessage => 'குரல் செய்தி';

  @override
  String get inputFile => 'கோப்பு';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'கள்',
      one: '',
    );
    return '$count திட்டமிடப்பட்ட செய்தி$_temp0';
  }

  @override
  String get callInitializing => 'அழைப்பு துவக்கப்படுகிறது…';

  @override
  String get callConnecting => 'இணைக்கிறது…';

  @override
  String get callConnectingRelay => 'இணைக்கிறது (ரிலே)…';

  @override
  String get callSwitchingRelay => 'ரிலே பயன்முறைக்கு மாறுகிறது…';

  @override
  String get callConnectionFailed => 'இணைப்பு தோல்வி';

  @override
  String get callReconnecting => 'மீண்டும் இணைக்கிறது…';

  @override
  String get callEnded => 'அழைப்பு முடிந்தது';

  @override
  String get callLive => 'நேரலை';

  @override
  String get callEnd => 'முடி';

  @override
  String get callEndCall => 'அழைப்பை முடி';

  @override
  String get callMute => 'ஒலியடக்கு';

  @override
  String get callUnmute => 'ஒலி இயக்கு';

  @override
  String get callSpeaker => 'ஸ்பீக்கர்';

  @override
  String get callCameraOn => 'கேமரா இயக்கம்';

  @override
  String get callCameraOff => 'கேமரா நிறுத்தம்';

  @override
  String get callShareScreen => 'திரை பகிர்';

  @override
  String get callStopShare => 'பகிர்வு நிறுத்து';

  @override
  String callTorBackup(String duration) {
    return 'Tor காப்புப்பிரதி · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor காப்புப்பிரதி செயலில் — முதன்மை பாதை கிடைக்கவில்லை';

  @override
  String get callDirectFailed =>
      'நேரடி இணைப்பு தோல்வி — ரிலே பயன்முறைக்கு மாறுகிறது…';

  @override
  String get callTurnUnreachable =>
      'TURN சேவையகங்கள் அணுக முடியவில்லை. அமைப்புகள் → மேம்பட்டது-இல் தனிப்பயன் TURN சேர்க்கவும்.';

  @override
  String get callRelayMode =>
      'ரிலே பயன்முறை செயலில் (கட்டுப்படுத்தப்பட்ட நெட்வொர்க்)';

  @override
  String get callStarting => 'அழைப்பு தொடங்குகிறது…';

  @override
  String get callConnectingToGroup => 'குழுவுடன் இணைக்கிறது…';

  @override
  String get callGroupOpenedInBrowser =>
      'குழு அழைப்பு உலாவியில் திறக்கப்பட்டது';

  @override
  String get callCouldNotOpenBrowser => 'உலாவியைத் திறக்க முடியவில்லை';

  @override
  String get callInviteLinkSent =>
      'அழைப்பு இணைப்பு அனைத்து குழு உறுப்பினர்களுக்கும் அனுப்பப்பட்டது.';

  @override
  String get callOpenLinkManually =>
      'மேலே உள்ள இணைப்பை நீங்களே திறக்கவும் அல்லது மீண்டும் முயற்சிக்க தட்டவும்.';

  @override
  String get callJitsiNotE2ee =>
      'Jitsi அழைப்புகள் எண்ட்-டு-எண்ட் குறியாக்கம் செய்யப்படவில்லை';

  @override
  String get callRetryOpenBrowser => 'உலாவியை மீண்டும் திற';

  @override
  String get callClose => 'மூடு';

  @override
  String get callCamOn => 'கேம் இயக்கம்';

  @override
  String get callCamOff => 'கேம் நிறுத்தம்';

  @override
  String get noConnection => 'இணைப்பு இல்லை — செய்திகள் வரிசையில் நிற்கும்';

  @override
  String get connected => 'இணைக்கப்பட்டது';

  @override
  String get connecting => 'இணைக்கிறது…';

  @override
  String get disconnected => 'துண்டிக்கப்பட்டது';

  @override
  String get offlineBanner =>
      'இணைப்பு இல்லை — ஆன்லைனில் திரும்பியவுடன் செய்திகள் அனுப்பப்படும்';

  @override
  String get lanModeBanner =>
      'LAN பயன்முறை — இணையம் இல்லை · உள்ளூர் நெட்வொர்க் மட்டும்';

  @override
  String get probeCheckingNetwork => 'நெட்வொர்க் இணைப்பை சரிபார்க்கிறது…';

  @override
  String get probeDiscoveringRelays =>
      'சமூக கோப்பகங்கள் வழியாக ரிலேக்களைக் கண்டறிகிறது…';

  @override
  String get probeStartingTor => 'பூட்ஸ்டிராப்பிற்கு Tor துவக்கப்படுகிறது…';

  @override
  String get probeFindingRelaysTor =>
      'Tor வழியாக அணுகக்கூடிய ரிலேக்களைக் கண்டறிகிறது…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'கள்',
      one: '',
    );
    return 'நெட்வொர்க் தயார் — $count ரிலே$_temp0 கண்டறியப்பட்டது';
  }

  @override
  String get probeNoRelaysFound =>
      'அணுகக்கூடிய ரிலேக்கள் எதுவும் இல்லை — செய்திகள் தாமதமாகலாம்';

  @override
  String get jitsiWarningTitle => 'எண்ட்-டு-எண்ட் குறியாக்கம் இல்லை';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet அழைப்புகள் Pulse ஆல் குறியாக்கம் செய்யப்படவில்லை. முக்கியமற்ற உரையாடல்களுக்கு மட்டும் பயன்படுத்தவும்.';

  @override
  String get jitsiConfirm => 'எப்படியும் சேர்';

  @override
  String get jitsiGroupWarningTitle => 'எண்ட்-டு-எண்ட் குறியாக்கம் இல்லை';

  @override
  String get jitsiGroupWarningBody =>
      'இந்த அழைப்பில் உள்ளமைக்கப்பட்ட குறியாக்க மெஷ்-க்கு அதிகமான பங்கேற்பாளர்கள் உள்ளனர்.\n\nஒரு Jitsi Meet இணைப்பு உங்கள் உலாவியில் திறக்கப்படும். Jitsi எண்ட்-டு-எண்ட் குறியாக்கம் செய்யப்படவில்லை — சேவையகம் உங்கள் அழைப்பைப் பார்க்க முடியும்.';

  @override
  String get jitsiContinueAnyway => 'எப்படியும் தொடர்';

  @override
  String get retry => 'மீண்டும் முயற்சி';

  @override
  String get setupCreateAnonymousAccount => 'அநாமதேய கணக்கை உருவாக்கு';

  @override
  String get setupTapToChangeColor => 'நிறம் மாற்ற தட்டவும்';

  @override
  String get setupReqMinLength => 'At least 16 characters';

  @override
  String get setupReqVariety => '3 of 4: uppercase, lowercase, digits, symbols';

  @override
  String get setupReqMatch => 'Passwords match';

  @override
  String get setupYourNickname => 'உங்கள் புனைப்பெயர்';

  @override
  String get setupRecoveryPassword => 'மீட்பு கடவுச்சொல் (குறைந்தபட்சம் 16)';

  @override
  String get setupConfirmPassword => 'கடவுச்சொல்லை உறுதிப்படுத்து';

  @override
  String get setupMin16Chars => 'குறைந்தபட்சம் 16 எழுத்துகள்';

  @override
  String get setupPasswordsDoNotMatch => 'கடவுச்சொற்கள் பொருந்தவில்லை';

  @override
  String get setupEntropyWeak => 'பலவீனம்';

  @override
  String get setupEntropyOk => 'சரி';

  @override
  String get setupEntropyStrong => 'வலிமை';

  @override
  String get setupEntropyWeakNeedsVariety => 'பலவீனம் (3 எழுத்து வகைகள் தேவை)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits பிட்கள்)';
  }

  @override
  String get setupPasswordWarning =>
      'இந்தக் கடவுச்சொல் மட்டுமே உங்கள் கணக்கை மீட்க வழி. சேவையகம் இல்லை — கடவுச்சொல் மீட்டமைப்பு இல்லை. நினைவில் கொள்ளுங்கள் அல்லது எழுதி வைக்கவும்.';

  @override
  String get setupCreateAccount => 'கணக்கை உருவாக்கு';

  @override
  String get setupAlreadyHaveAccount => 'ஏற்கனவே கணக்கு உள்ளதா? ';

  @override
  String get setupRestore => 'மீட்டெடு →';

  @override
  String get restoreTitle => 'கணக்கை மீட்டெடு';

  @override
  String get restoreInfoBanner =>
      'உங்கள் மீட்பு கடவுச்சொல்லை உள்ளிடவும் — உங்கள் முகவரி (Nostr + Session) தானாக மீட்கப்படும். தொடர்புகளும் செய்திகளும் உள்ளூரில் மட்டுமே சேமிக்கப்பட்டிருந்தன.';

  @override
  String get restoreNewNickname => 'புதிய புனைப்பெயர் (பின்னர் மாற்றலாம்)';

  @override
  String get restoreButton => 'கணக்கை மீட்டெடு';

  @override
  String get lockTitle => 'Pulse பூட்டப்பட்டுள்ளது';

  @override
  String get lockSubtitle => 'தொடர உங்கள் கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get lockPasswordHint => 'கடவுச்சொல்';

  @override
  String get lockUnlock => 'திற';

  @override
  String get lockPanicHint =>
      'கடவுச்சொல் மறந்துவிட்டதா? அனைத்து தரவையும் அழிக்க உங்கள் பேனிக் கீயை உள்ளிடவும்.';

  @override
  String get lockTooManyAttempts =>
      'அதிக முயற்சிகள். அனைத்து தரவும் அழிக்கப்படுகிறது…';

  @override
  String get lockWrongPassword => 'தவறான கடவுச்சொல்';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'தவறான கடவுச்சொல் — $attempts/$max முயற்சிகள்';
  }

  @override
  String get onboardingSkip => 'தவிர்';

  @override
  String get onboardingNext => 'அடுத்து';

  @override
  String get onboardingGetStarted => 'தொடங்கு';

  @override
  String get onboardingWelcomeTitle => 'Pulse-க்கு வரவேற்கிறோம்';

  @override
  String get onboardingWelcomeBody =>
      'பரவலாக்கப்பட்ட, எண்ட்-டு-எண்ட் குறியாக்கம் செய்யப்பட்ட மெசஞ்சர்.\n\nமைய சேவையகங்கள் இல்லை. தரவு சேகரிப்பு இல்லை. பின்கதவுகள் இல்லை.\nஉங்கள் உரையாடல்கள் உங்களுக்கு மட்டுமே.';

  @override
  String get onboardingTransportTitle => 'போக்குவரத்து-அறியாத';

  @override
  String get onboardingTransportBody =>
      'Firebase, Nostr அல்லது இரண்டையும் ஒரே நேரத்தில் பயன்படுத்துங்கள்.\n\nசெய்திகள் நெட்வொர்க்குகளில் தானாக வழிநடத்தப்படுகின்றன. தணிக்கை எதிர்ப்பிற்கு உள்ளமைக்கப்பட்ட Tor மற்றும் I2P ஆதரவு.';

  @override
  String get onboardingSignalTitle => 'Signal + போஸ்ட்-குவாண்டம்';

  @override
  String get onboardingSignalBody =>
      'ஒவ்வொரு செய்தியும் முன்னோக்கு ரகசியத்திற்காக Signal Protocol (Double Ratchet + X3DH) மூலம் குறியாக்கம் செய்யப்படுகிறது.\n\nகூடுதலாக Kyber-1024 மூலம் மூடப்படுகிறது — NIST-தர போஸ்ட்-குவாண்டம் வழிமுறை — எதிர்கால குவாண்டம் கணினிகளிலிருந்து பாதுகாப்பு.';

  @override
  String get onboardingKeysTitle => 'உங்கள் விசைகள் உங்களுடையவை';

  @override
  String get onboardingKeysBody =>
      'உங்கள் அடையாள விசைகள் உங்கள் சாதனத்தை விட்டு வெளியேறுவதில்லை.\n\nSignal கைரேகைகள் தொடர்புகளை அவுட்-ஆஃப்-பேண்ட் சரிபார்க்க உதவுகின்றன. TOFU (Trust On First Use) விசை மாற்றங்களை தானாக கண்டறியும்.';

  @override
  String get onboardingThemeTitle => 'உங்கள் தோற்றத்தைத் தேர்வுசெய்க';

  @override
  String get onboardingThemeBody =>
      'ஒரு கருப்பொருள் மற்றும் உச்ச நிறத்தைத் தேர்வுசெய்க. பின்னர் அமைப்புகளில் எப்போது வேண்டுமானாலும் மாற்றலாம்.';

  @override
  String get contactsNewChat => 'புதிய உரையாடல்';

  @override
  String get contactsAddContact => 'தொடர்பு சேர்';

  @override
  String get contactsSearchHint => 'தேடு...';

  @override
  String get contactsNewGroup => 'புதிய குழு';

  @override
  String get contactsNoContactsYet => 'இதுவரை தொடர்புகள் இல்லை';

  @override
  String get contactsAddHint => 'யாரோ ஒருவரின் முகவரியைச் சேர்க்க + தட்டவும்';

  @override
  String get contactsNoMatch => 'பொருந்தும் தொடர்புகள் இல்லை';

  @override
  String get contactsRemoveTitle => 'தொடர்பை நீக்கு';

  @override
  String contactsRemoveMessage(String name) {
    return '$name-ஐ நீக்கவா?';
  }

  @override
  String get contactsRemove => 'நீக்கு';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'கள்',
      one: '',
    );
    return '$count தொடர்பு$_temp0';
  }

  @override
  String get bubbleOpenLink => 'இணைப்பைத் திற';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'இந்த URL-ஐ உலாவியில் திறக்கவா?\n\n$url';
  }

  @override
  String get bubbleOpen => 'திற';

  @override
  String get bubbleSecurityWarning => 'பாதுகாப்பு எச்சரிக்கை';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" ஒரு இயக்கக்கூடிய கோப்பு வகை. சேமிப்பதும் இயக்குவதும் உங்கள் சாதனத்திற்கு தீங்கு விளைவிக்கலாம். எப்படியும் சேமிக்கவா?';
  }

  @override
  String get bubbleSaveAnyway => 'எப்படியும் சேமி';

  @override
  String bubbleSavedTo(String path) {
    return '$path-இல் சேமிக்கப்பட்டது';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'சேமிப்பு தோல்வி: $error';
  }

  @override
  String get bubbleNotEncrypted => 'குறியாக்கம் இல்லை';

  @override
  String get bubbleCorruptedImage => '[சிதைந்த படம்]';

  @override
  String get bubbleReplyPhoto => 'புகைப்படம்';

  @override
  String get bubbleReplyVoice => 'குரல் செய்தி';

  @override
  String get bubbleReplyVideo => 'காணொலி செய்தி';

  @override
  String bubbleReadBy(String names) {
    return '$names படித்தது';
  }

  @override
  String bubbleReadByCount(int count) {
    return '$count பேர் படித்தது';
  }

  @override
  String get chatTileTapToStart => 'உரையாட தட்டவும்';

  @override
  String get chatTileMessageSent => 'செய்தி அனுப்பப்பட்டது';

  @override
  String get chatTileEncryptedMessage => 'குறியாக்கம் செய்யப்பட்ட செய்தி';

  @override
  String chatTileYouPrefix(String text) {
    return 'நீங்கள்: $text';
  }

  @override
  String get bannerEncryptedMessage => 'குறியாக்கம் செய்யப்பட்ட செய்தி';

  @override
  String get groupNewGroup => 'புதிய குழு';

  @override
  String get groupGroupName => 'குழு பெயர்';

  @override
  String get groupSelectMembers =>
      'உறுப்பினர்களைத் தேர்வுசெய் (குறைந்தபட்சம் 2)';

  @override
  String get groupNoContactsYet =>
      'இதுவரை தொடர்புகள் இல்லை. முதலில் தொடர்புகளைச் சேர்க்கவும்.';

  @override
  String get groupCreate => 'உருவாக்கு';

  @override
  String get groupLabel => 'குழு';

  @override
  String get profileVerifyIdentity => 'அடையாளத்தை சரிபார்';

  @override
  String profileVerifyInstructions(String name) {
    return '$name-உடன் குரல் அழைப்பு அல்லது நேரில் இந்த கைரேகைகளை ஒப்பிடுங்கள். இரு சாதனங்களிலும் மதிப்புகள் பொருந்தினால், \"சரிபார்க்கப்பட்டதாகக் குறி\" தட்டவும்.';
  }

  @override
  String get profileTheirKey => 'அவர்களின் விசை';

  @override
  String get profileYourKey => 'உங்கள் விசை';

  @override
  String get profileRemoveVerification => 'சரிபார்ப்பை நீக்கு';

  @override
  String get profileMarkAsVerified => 'சரிபார்க்கப்பட்டதாகக் குறி';

  @override
  String get profileAddressCopied => 'முகவரி நகலெடுக்கப்பட்டது';

  @override
  String get profileNoContactsToAdd =>
      'சேர்க்க தொடர்புகள் இல்லை — அனைவரும் ஏற்கனவே உறுப்பினர்கள்';

  @override
  String get profileAddMembers => 'உறுப்பினர்களைச் சேர்';

  @override
  String profileAddCount(int count) {
    return 'சேர் ($count)';
  }

  @override
  String get profileRenameGroup => 'குழு பெயர் மாற்று';

  @override
  String get profileRename => 'பெயர் மாற்று';

  @override
  String get profileRemoveMember => 'உறுப்பினரை நீக்கவா?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'இந்தக் குழுவிலிருந்து $name-ஐ நீக்கவா?';
  }

  @override
  String get profileKick => 'நீக்கு';

  @override
  String get profileSignalFingerprints => 'Signal கைரேகைகள்';

  @override
  String get profileVerified => 'சரிபார்க்கப்பட்டது';

  @override
  String get profileVerify => 'சரிபார்';

  @override
  String get profileEdit => 'திருத்து';

  @override
  String get profileNoSession =>
      'இதுவரை அமர்வு நிறுவப்படவில்லை — முதலில் ஒரு செய்தி அனுப்புங்கள்.';

  @override
  String get profileFingerprintCopied => 'கைரேகை நகலெடுக்கப்பட்டது';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'கள்',
      one: '',
    );
    return '$count உறுப்பினர்$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'பாதுகாப்பு எண்ணைச் சரிபார்';

  @override
  String get profileShowContactQr => 'தொடர்பு QR காட்டு';

  @override
  String profileContactAddress(String name) {
    return '$name-இன் முகவரி';
  }

  @override
  String get profileExportChatHistory => 'உரையாடல் வரலாற்றை ஏற்றுமதி செய்';

  @override
  String profileSavedTo(String path) {
    return '$path-இல் சேமிக்கப்பட்டது';
  }

  @override
  String get profileExportFailed => 'ஏற்றுமதி தோல்வி';

  @override
  String get profileClearChatHistory => 'உரையாடல் வரலாற்றை அழி';

  @override
  String get profileDeleteGroup => 'குழுவை நீக்கு';

  @override
  String get profileDeleteContact => 'தொடர்பை நீக்கு';

  @override
  String get profileLeaveGroup => 'குழுவை விட்டு வெளியேறு';

  @override
  String get profileLeaveGroupBody =>
      'இந்தக் குழுவிலிருந்து நீக்கப்படுவீர்கள், உங்கள் தொடர்புகளிலிருந்தும் நீக்கப்படும்.';

  @override
  String get groupInviteTitle => 'குழு அழைப்பு';

  @override
  String groupInviteBody(String from, String group) {
    return '$from உங்களை \"$group\"-இல் சேர அழைக்கிறார்';
  }

  @override
  String get groupInviteAccept => 'ஏற்கவும்';

  @override
  String get groupInviteDecline => 'நிராகரி';

  @override
  String get groupMemberLimitTitle => 'அதிகமான பங்கேற்பாளர்கள்';

  @override
  String groupMemberLimitBody(int count) {
    return 'இந்தக் குழுவில் $count பங்கேற்பாளர்கள் இருப்பர். குறியாக்கம் செய்யப்பட்ட மெஷ் அழைப்புகள் 6 வரை ஆதரிக்கின்றன. பெரிய குழுக்கள் Jitsi-க்கு மாறும் (E2EE இல்லை).';
  }

  @override
  String get groupMemberLimitContinue => 'எப்படியும் சேர்';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name \"$group\"-இல் சேர மறுத்தார்';
  }

  @override
  String get transferTitle => 'மற்றொரு சாதனத்திற்கு மாற்று';

  @override
  String get transferInfoBox =>
      'உங்கள் Signal அடையாளம் மற்றும் Nostr விசைகளை புதிய சாதனத்திற்கு நகர்த்துங்கள்.\nஉரையாடல் அமர்வுகள் மாற்றப்படாது — முன்னோக்கு ரகசியம் பாதுகாக்கப்படுகிறது.';

  @override
  String get transferSendFromThis => 'இந்த சாதனத்திலிருந்து அனுப்பு';

  @override
  String get transferSendSubtitle =>
      'இந்த சாதனத்தில் விசைகள் உள்ளன. புதிய சாதனத்துடன் குறியீட்டைப் பகிரவும்.';

  @override
  String get transferReceiveOnThis => 'இந்த சாதனத்தில் பெறு';

  @override
  String get transferReceiveSubtitle =>
      'இது புதிய சாதனம். பழைய சாதனத்திலிருந்து குறியீட்டை உள்ளிடவும்.';

  @override
  String get transferChooseMethod => 'மாற்ற முறையைத் தேர்வுசெய்';

  @override
  String get transferLan => 'LAN (அதே நெட்வொர்க்)';

  @override
  String get transferLanSubtitle =>
      'வேகமான, நேரடி. இரு சாதனங்களும் ஒரே Wi-Fi-இல் இருக்க வேண்டும்.';

  @override
  String get transferNostrRelay => 'Nostr ரிலே';

  @override
  String get transferNostrRelaySubtitle =>
      'ஏற்கனவே உள்ள Nostr ரிலே மூலம் எந்த நெட்வொர்க்கிலும் செயல்படும்.';

  @override
  String get transferRelayUrl => 'ரிலே URL';

  @override
  String get transferEnterCode => 'மாற்றக் குறியீட்டை உள்ளிடு';

  @override
  String get transferPasteCode =>
      'இங்கே LAN:... அல்லது NOS:... குறியீட்டை ஒட்டவும்';

  @override
  String get transferConnect => 'இணை';

  @override
  String get transferGenerating => 'மாற்றக் குறியீடு உருவாக்கப்படுகிறது…';

  @override
  String get transferShareCode => 'இந்தக் குறியீட்டை பெறுநருடன் பகிரவும்:';

  @override
  String get transferCopyCode => 'குறியீடு நகலெடு';

  @override
  String get transferCodeCopied =>
      'குறியீடு கிளிப்போர்டுக்கு நகலெடுக்கப்பட்டது';

  @override
  String get transferWaitingReceiver => 'பெறுநர் இணைவதற்காகக் காத்திருக்கிறது…';

  @override
  String get transferConnectingSender => 'அனுப்புநருடன் இணைக்கிறது…';

  @override
  String get transferVerifyBoth =>
      'இரு சாதனங்களிலும் இந்தக் குறியீட்டை ஒப்பிடுங்கள்.\nபொருந்தினால், மாற்றம் பாதுகாப்பானது.';

  @override
  String get transferComplete => 'மாற்றம் நிறைவடைந்தது';

  @override
  String get transferKeysImported => 'விசைகள் இறக்குமதி செய்யப்பட்டன';

  @override
  String get transferCompleteSenderBody =>
      'உங்கள் விசைகள் இந்த சாதனத்தில் செயலில் உள்ளன.\nபெறுநர் இப்போது உங்கள் அடையாளத்தைப் பயன்படுத்தலாம்.';

  @override
  String get transferCompleteReceiverBody =>
      'விசைகள் வெற்றிகரமாக இறக்குமதி செய்யப்பட்டன.\nபுதிய அடையாளத்தைப் பொருத்த பயன்பாட்டை மறுதொடக்கம் செய்யவும்.';

  @override
  String get transferRestartApp => 'பயன்பாட்டை மறுதொடக்கம் செய்';

  @override
  String get transferFailed => 'மாற்றம் தோல்வி';

  @override
  String get transferTryAgain => 'மீண்டும் முயற்சி';

  @override
  String get transferEnterRelayFirst => 'முதலில் ஒரு ரிலே URL உள்ளிடவும்';

  @override
  String get transferPasteCodeFromSender =>
      'அனுப்புநரின் மாற்றக் குறியீட்டை ஒட்டவும்';

  @override
  String get menuReply => 'பதில்';

  @override
  String get menuForward => 'முன்அனுப்பு';

  @override
  String get menuReact => 'எதிர்வினை';

  @override
  String get menuCopy => 'நகலெடு';

  @override
  String get menuEdit => 'திருத்து';

  @override
  String get menuRetry => 'மீண்டும் முயற்சி';

  @override
  String get menuCancelScheduled => 'திட்டமிடப்பட்டதை ரத்து செய்';

  @override
  String get menuDelete => 'நீக்கு';

  @override
  String get menuForwardTo => 'முன்அனுப்பு…';

  @override
  String menuForwardedTo(String name) {
    return '$name-க்கு முன்அனுப்பப்பட்டது';
  }

  @override
  String get menuScheduledMessages => 'திட்டமிடப்பட்ட செய்திகள்';

  @override
  String get menuNoScheduledMessages => 'திட்டமிடப்பட்ட செய்திகள் இல்லை';

  @override
  String menuSendsOn(String date) {
    return '$date அன்று அனுப்பப்படும்';
  }

  @override
  String get menuDisappearingMessages => 'மறையும் செய்திகள்';

  @override
  String get menuDisappearingSubtitle =>
      'தேர்ந்தெடுக்கப்பட்ட நேரத்திற்குப் பிறகு செய்திகள் தானாக நீக்கப்படும்.';

  @override
  String get menuTtlOff => 'நிறுத்தம்';

  @override
  String get menuTtl1h => '1 மணி நேரம்';

  @override
  String get menuTtl24h => '24 மணி நேரம்';

  @override
  String get menuTtl7d => '7 நாட்கள்';

  @override
  String get menuAttachPhoto => 'புகைப்படம்';

  @override
  String get menuAttachFile => 'கோப்பு';

  @override
  String get menuAttachVideo => 'காணொலி';

  @override
  String get mediaTitle => 'மீடியா';

  @override
  String get mediaFileLabel => 'கோப்பு';

  @override
  String mediaPhotosTab(int count) {
    return 'புகைப்படங்கள் ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'கோப்புகள் ($count)';
  }

  @override
  String get mediaNoPhotos => 'இதுவரை புகைப்படங்கள் இல்லை';

  @override
  String get mediaNoFiles => 'இதுவரை கோப்புகள் இல்லை';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Downloads/$name-இல் சேமிக்கப்பட்டது';
  }

  @override
  String get mediaFailedToSave => 'கோப்பைச் சேமிக்க முடியவில்லை';

  @override
  String get statusNewStatus => 'புதிய நிலை';

  @override
  String get statusPublish => 'வெளியிடு';

  @override
  String get statusExpiresIn24h => 'நிலை 24 மணி நேரத்தில் காலாவதியாகும்';

  @override
  String get statusWhatsOnYourMind => 'என்ன நினைக்கிறீர்கள்?';

  @override
  String get statusPhotoAttached => 'புகைப்படம் இணைக்கப்பட்டது';

  @override
  String get statusAttachPhoto => 'புகைப்படம் இணை (விருப்பம்)';

  @override
  String get statusEnterText => 'உங்கள் நிலைக்கு ஏதாவது உரையை உள்ளிடவும்.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'புகைப்படம் தேர்வு தோல்வி: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'வெளியீடு தோல்வி: $error';
  }

  @override
  String get panicSetPanicKey => 'பேனிக் கீயை அமை';

  @override
  String get panicEmergencySelfDestruct => 'அவசர சுய-அழிவு';

  @override
  String get panicIrreversible => 'இந்தச் செயல் மீளமுடியாதது';

  @override
  String get panicWarningBody =>
      'பூட்டுத் திரையில் இந்த விசையை உள்ளிட்டால் அனைத்து தரவும் உடனடியாக அழிக்கப்படும் — செய்திகள், தொடர்புகள், விசைகள், அடையாளம். உங்கள் வழக்கமான கடவுச்சொல்லிலிருந்து வேறுபட்ட விசையைப் பயன்படுத்தவும்.';

  @override
  String get panicKeyHint => 'பேனிக் கீ';

  @override
  String get panicConfirmHint => 'பேனிக் கீயை உறுதிப்படுத்து';

  @override
  String get panicMinChars =>
      'பேனிக் கீ குறைந்தபட்சம் 8 எழுத்துகள் இருக்க வேண்டும்';

  @override
  String get panicKeysDoNotMatch => 'விசைகள் பொருந்தவில்லை';

  @override
  String get panicSetFailed =>
      'பேனிக் கீயைச் சேமிக்க முடியவில்லை — மீண்டும் முயற்சிக்கவும்';

  @override
  String get passwordSetAppPassword => 'பயன்பாட்டு கடவுச்சொல் அமை';

  @override
  String get passwordProtectsMessages =>
      'உங்கள் செய்திகளை நிலையான நிலையில் பாதுகாக்கிறது';

  @override
  String get passwordInfoBanner =>
      'Pulse திறக்கும் ஒவ்வொரு முறையும் தேவை. மறந்தால், உங்கள் தரவை மீட்க முடியாது.';

  @override
  String get passwordHint => 'கடவுச்சொல்';

  @override
  String get passwordConfirmHint => 'கடவுச்சொல்லை உறுதிப்படுத்து';

  @override
  String get passwordSetButton => 'கடவுச்சொல் அமை';

  @override
  String get passwordSkipForNow => 'இப்போதைக்குத் தவிர்';

  @override
  String get passwordMinChars =>
      'கடவுச்சொல் குறைந்தபட்சம் 6 எழுத்துகள் இருக்க வேண்டும்';

  @override
  String get passwordsDoNotMatch => 'கடவுச்சொற்கள் பொருந்தவில்லை';

  @override
  String get profileCardSaved => 'சுயவிவரம் சேமிக்கப்பட்டது!';

  @override
  String get profileCardE2eeIdentity => 'E2EE அடையாளம்';

  @override
  String get profileCardDisplayName => 'காட்சிப் பெயர்';

  @override
  String get profileCardDisplayNameHint => 'எ.கா. குமார் ராஜா';

  @override
  String get profileCardAbout => 'பற்றி';

  @override
  String get profileCardSaveProfile => 'சுயவிவரம் சேமி';

  @override
  String get profileCardYourName => 'உங்கள் பெயர்';

  @override
  String get profileCardAddressCopied => 'முகவரி நகலெடுக்கப்பட்டது!';

  @override
  String get profileCardInboxAddress => 'உங்கள் இன்பாக்ஸ் முகவரி';

  @override
  String get profileCardInboxAddresses => 'உங்கள் இன்பாக்ஸ் முகவரிகள்';

  @override
  String get profileCardShareAllAddresses =>
      'அனைத்து முகவரிகளையும் பகிர் (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'உங்களுக்கு செய்தி அனுப்ப தொடர்புகளுடன் பகிரவும்.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'அனைத்து $count முகவரிகளும் ஒரு இணைப்பாக நகலெடுக்கப்பட்டன!';
  }

  @override
  String get settingsMyProfile => 'எனது சுயவிவரம்';

  @override
  String get settingsYourInboxAddress => 'உங்கள் இன்பாக்ஸ் முகவரி';

  @override
  String get settingsMyQrCode => 'எனது QR குறியீடு';

  @override
  String get settingsMyQrSubtitle =>
      'ஸ்கேன் செய்யக்கூடிய QR ஆக உங்கள் முகவரியைப் பகிரவும்';

  @override
  String get settingsShareMyAddress => 'எனது முகவரியைப் பகிர்';

  @override
  String get settingsNoAddressYet =>
      'இதுவரை முகவரி இல்லை — முதலில் அமைப்புகளைச் சேமிக்கவும்';

  @override
  String get settingsInviteLink => 'அழைப்பு இணைப்பு';

  @override
  String get settingsRawAddress => 'மூல முகவரி';

  @override
  String get settingsCopyLink => 'இணைப்பு நகலெடு';

  @override
  String get settingsCopyAddress => 'முகவரி நகலெடு';

  @override
  String get settingsInviteLinkCopied => 'அழைப்பு இணைப்பு நகலெடுக்கப்பட்டது';

  @override
  String get settingsAppearance => 'தோற்றம்';

  @override
  String get settingsThemeEngine => 'கருப்பொருள் இயந்திரம்';

  @override
  String get settingsThemeEngineSubtitle =>
      'நிறங்கள் மற்றும் எழுத்துருக்களைத் தனிப்பயனாக்கு';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle =>
      'E2EE விசைகள் பாதுகாப்பாகச் சேமிக்கப்பட்டுள்ளன';

  @override
  String get settingsActive => 'செயலில்';

  @override
  String get settingsIdentityBackup => 'அடையாள காப்புப்பிரதி';

  @override
  String get settingsIdentityBackupSubtitle =>
      'உங்கள் Signal அடையாளத்தை ஏற்றுமதி அல்லது இறக்குமதி செய்யவும்';

  @override
  String get settingsIdentityBackupBody =>
      'உங்கள் Signal அடையாள விசைகளை காப்புக் குறியீட்டிற்கு ஏற்றுமதி செய்யவும், அல்லது ஏற்கனவே உள்ளவற்றிலிருந்து மீட்டெடுக்கவும்.';

  @override
  String get settingsTransferDevice => 'மற்றொரு சாதனத்திற்கு மாற்று';

  @override
  String get settingsTransferDeviceSubtitle =>
      'LAN அல்லது Nostr ரிலே வழியாக அடையாளத்தை நகர்த்து';

  @override
  String get settingsExportIdentity => 'அடையாளத்தை ஏற்றுமதி செய்';

  @override
  String get settingsExportIdentityBody =>
      'இந்த காப்புக் குறியீட்டை நகலெடுத்து பாதுகாப்பாக சேமிக்கவும்:';

  @override
  String get settingsSaveFile => 'கோப்பைச் சேமி';

  @override
  String get settingsImportIdentity => 'அடையாளத்தை இறக்குமதி செய்';

  @override
  String get settingsImportIdentityBody =>
      'கீழே உங்கள் காப்புக் குறியீட்டை ஒட்டவும். இது உங்கள் தற்போதைய அடையாளத்தை மேலெழுதும்.';

  @override
  String get settingsPasteBackupCode => 'காப்புக் குறியீட்டை இங்கே ஒட்டவும்…';

  @override
  String get settingsIdentityImported =>
      'அடையாளம் + தொடர்புகள் இறக்குமதி செய்யப்பட்டன! பொருத்த பயன்பாட்டை மறுதொடக்கம் செய்யவும்.';

  @override
  String get settingsSecurity => 'பாதுகாப்பு';

  @override
  String get settingsAppPassword => 'பயன்பாட்டு கடவுச்சொல்';

  @override
  String get settingsPasswordEnabled =>
      'இயக்கப்பட்டது — ஒவ்வொரு தொடக்கத்திலும் தேவை';

  @override
  String get settingsPasswordDisabled =>
      'முடக்கப்பட்டது — கடவுச்சொல் இல்லாமல் பயன்பாடு திறக்கும்';

  @override
  String get settingsChangePassword => 'கடவுச்சொல் மாற்று';

  @override
  String get settingsChangePasswordSubtitle =>
      'பயன்பாட்டுப் பூட்டு கடவுச்சொல்லை புதுப்பி';

  @override
  String get settingsSetPanicKey => 'பேனிக் கீயை அமை';

  @override
  String get settingsChangePanicKey => 'பேனிக் கீயை மாற்று';

  @override
  String get settingsPanicKeySetSubtitle => 'அவசர அழிப்பு விசையைப் புதுப்பி';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'அனைத்து தரவையும் உடனடியாக அழிக்கும் ஒரு விசை';

  @override
  String get settingsRemovePanicKey => 'பேனிக் கீயை நீக்கு';

  @override
  String get settingsRemovePanicKeySubtitle => 'அவசர சுய-அழிவை முடக்கு';

  @override
  String get settingsRemovePanicKeyBody =>
      'அவசர சுய-அழிவு முடக்கப்படும். எப்போது வேண்டுமானாலும் மீண்டும் இயக்கலாம்.';

  @override
  String get settingsDisableAppPassword => 'பயன்பாட்டு கடவுச்சொல்லை முடக்கு';

  @override
  String get settingsEnterCurrentPassword =>
      'உறுதிப்படுத்த உங்கள் தற்போதைய கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get settingsCurrentPassword => 'தற்போதைய கடவுச்சொல்';

  @override
  String get settingsIncorrectPassword => 'தவறான கடவுச்சொல்';

  @override
  String get settingsPasswordUpdated => 'கடவுச்சொல் புதுப்பிக்கப்பட்டது';

  @override
  String get settingsChangePasswordProceed =>
      'தொடர உங்கள் தற்போதைய கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get settingsData => 'தரவு';

  @override
  String get settingsBackupMessages => 'செய்திகளைக் காப்புப்பிரதி எடு';

  @override
  String get settingsBackupMessagesSubtitle =>
      'குறியாக்கம் செய்யப்பட்ட செய்தி வரலாற்றை கோப்பாக ஏற்றுமதி செய்';

  @override
  String get settingsRestoreMessages => 'செய்திகளை மீட்டெடு';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'காப்புக் கோப்பிலிருந்து செய்திகளை இறக்குமதி செய்';

  @override
  String get settingsExportKeys => 'விசைகளை ஏற்றுமதி செய்';

  @override
  String get settingsExportKeysSubtitle =>
      'அடையாள விசைகளை குறியாக்கம் செய்யப்பட்ட கோப்பில் சேமி';

  @override
  String get settingsImportKeys => 'விசைகளை இறக்குமதி செய்';

  @override
  String get settingsImportKeysSubtitle =>
      'ஏற்றுமதி செய்யப்பட்ட கோப்பிலிருந்து அடையாள விசைகளை மீட்டெடு';

  @override
  String get settingsBackupPassword => 'காப்பு கடவுச்சொல்';

  @override
  String get settingsPasswordCannotBeEmpty =>
      'கடவுச்சொல் காலியாக இருக்க முடியாது';

  @override
  String get settingsPasswordMin4Chars =>
      'கடவுச்சொல் குறைந்தபட்சம் 4 எழுத்துகள் இருக்க வேண்டும்';

  @override
  String get settingsCallsTurn => 'அழைப்புகள் & TURN';

  @override
  String get settingsLocalNetwork => 'உள்ளூர் நெட்வொர்க்';

  @override
  String get settingsCensorshipResistance => 'தணிக்கை எதிர்ப்பு';

  @override
  String get settingsNetwork => 'நெட்வொர்க்';

  @override
  String get settingsProxyTunnels => 'ப்ராக்ஸி & சுரங்கங்கள்';

  @override
  String get settingsTurnServers => 'TURN சேவையகங்கள்';

  @override
  String get settingsProviderTitle => 'வழங்குநர்';

  @override
  String get settingsLanFallback => 'LAN ஃபால்பேக்';

  @override
  String get settingsLanFallbackSubtitle =>
      'இணையம் கிடைக்காதபோது உள்ளூர் நெட்வொர்க்கில் செய்திகளை அனுப்பவும் இருப்பை ஒளிபரப்பவும். நம்பகமற்ற நெட்வொர்க்குகளில் (பொது Wi-Fi) முடக்கவும்.';

  @override
  String get settingsBgDelivery => 'பின்னணி விநியோகம்';

  @override
  String get settingsBgDeliverySubtitle =>
      'பயன்பாடு சிறிதாக்கப்பட்டிருக்கும்போதும் செய்திகளைப் பெறுவதைத் தொடரவும். நிரந்தர அறிவிப்பைக் காட்டும்.';

  @override
  String get settingsYourInboxProvider => 'உங்கள் இன்பாக்ஸ் வழங்குநர்';

  @override
  String get settingsConnectionDetails => 'இணைப்பு விவரங்கள்';

  @override
  String get settingsSaveAndConnect => 'சேமி & இணை';

  @override
  String get settingsSecondaryInboxes => 'இரண்டாம் நிலை இன்பாக்ஸ்கள்';

  @override
  String get settingsAddSecondaryInbox => 'இரண்டாம் நிலை இன்பாக்ஸ் சேர்';

  @override
  String get settingsAdvanced => 'மேம்பட்டது';

  @override
  String get settingsDiscover => 'கண்டறி';

  @override
  String get settingsAbout => 'பற்றி';

  @override
  String get settingsPrivacyPolicy => 'தனியுரிமைக் கொள்கை';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Pulse உங்கள் தரவை எவ்வாறு பாதுகாக்கிறது';

  @override
  String get settingsCrashReporting => 'செயலிழப்பு அறிக்கை';

  @override
  String get settingsCrashReportingSubtitle =>
      'Pulse-ஐ மேம்படுத்த அநாமதேய செயலிழப்பு அறிக்கைகளை அனுப்புங்கள். செய்தி உள்ளடக்கம் அல்லது தொடர்புகள் ஒருபோதும் அனுப்பப்படுவதில்லை.';

  @override
  String get settingsCrashReportingEnabled =>
      'செயலிழப்பு அறிக்கை இயக்கப்பட்டது — பொருத்த பயன்பாட்டை மறுதொடக்கம் செய்யவும்';

  @override
  String get settingsCrashReportingDisabled =>
      'செயலிழப்பு அறிக்கை முடக்கப்பட்டது — பொருத்த பயன்பாட்டை மறுதொடக்கம் செய்யவும்';

  @override
  String get settingsSensitiveOperation => 'முக்கிய செயல்பாடு';

  @override
  String get settingsSensitiveOperationBody =>
      'இந்த விசைகள் உங்கள் அடையாளம். இந்தக் கோப்பு உள்ள எவரும் உங்களைப் போல் ஆள்மாறாட்டம் செய்யலாம். பாதுகாப்பாக சேமித்து மாற்றத்திற்குப் பிறகு நீக்கவும்.';

  @override
  String get settingsIUnderstandContinue => 'புரிகிறது, தொடர்';

  @override
  String get settingsReplaceIdentity => 'அடையாளத்தை மாற்றவா?';

  @override
  String get settingsReplaceIdentityBody =>
      'இது உங்கள் தற்போதைய அடையாள விசைகளை மேலெழுதும். உங்கள் ஏற்கனவே உள்ள Signal அமர்வுகள் செல்லாமல் ஆகும், தொடர்புகள் மீண்டும் குறியாக்கத்தை நிறுவ வேண்டும். பயன்பாடு மறுதொடக்கம் செய்ய வேண்டும்.';

  @override
  String get settingsReplaceKeys => 'விசைகளை மாற்று';

  @override
  String get settingsKeysImported => 'விசைகள் இறக்குமதி செய்யப்பட்டன';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count விசைகள் வெற்றிகரமாக இறக்குமதி செய்யப்பட்டன. புதிய அடையாளத்துடன் மீளத்தொடங்க பயன்பாட்டை மறுதொடக்கம் செய்யவும்.';
  }

  @override
  String get settingsRestartNow => 'இப்போது மறுதொடக்கம்';

  @override
  String get settingsLater => 'பின்னர்';

  @override
  String get profileGroupLabel => 'குழு';

  @override
  String get profileAddButton => 'சேர்';

  @override
  String get profileKickButton => 'நீக்கு';

  @override
  String get dataSectionTitle => 'தரவு';

  @override
  String get dataBackupMessages => 'செய்திகளைக் காப்புப்பிரதி எடு';

  @override
  String get dataBackupPasswordSubtitle =>
      'உங்கள் செய்தி காப்புப்பிரதியை குறியாக்கம் செய்ய கடவுச்சொல்லைத் தேர்வுசெய்க.';

  @override
  String get dataBackupConfirmLabel => 'காப்புப்பிரதி உருவாக்கு';

  @override
  String get dataCreatingBackup => 'காப்புப்பிரதி உருவாக்கப்படுகிறது';

  @override
  String get dataBackupPreparing => 'தயாராகிறது...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'செய்தி $done/$total ஏற்றுமதி செய்யப்படுகிறது...';
  }

  @override
  String get dataBackupSavingFile => 'கோப்பு சேமிக்கப்படுகிறது...';

  @override
  String get dataSaveMessageBackupDialog => 'செய்தி காப்புப்பிரதியைச் சேமி';

  @override
  String dataBackupSaved(int count, String path) {
    return 'காப்புப்பிரதி சேமிக்கப்பட்டது ($count செய்திகள்)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'காப்புப்பிரதி தோல்வி — தரவு ஏற்றுமதி செய்யப்படவில்லை';

  @override
  String dataBackupFailedError(String error) {
    return 'காப்புப்பிரதி தோல்வி: $error';
  }

  @override
  String get dataSelectMessageBackupDialog =>
      'செய்தி காப்புப்பிரதியைத் தேர்வுசெய்';

  @override
  String get dataInvalidBackupFile => 'செல்லாத காப்புக் கோப்பு (மிகச்சிறியது)';

  @override
  String get dataNotValidBackupFile =>
      'செல்லுபடியான Pulse காப்புக் கோப்பு அல்ல';

  @override
  String get dataRestoreMessages => 'செய்திகளை மீட்டெடு';

  @override
  String get dataRestorePasswordSubtitle =>
      'இந்த காப்புப்பிரதியை உருவாக்க பயன்படுத்திய கடவுச்சொல்லை உள்ளிடவும்.';

  @override
  String get dataRestoreConfirmLabel => 'மீட்டெடு';

  @override
  String get dataRestoringMessages => 'செய்திகள் மீட்டெடுக்கப்படுகின்றன';

  @override
  String get dataRestoreDecrypting => 'மறையாக்கம் நீக்கப்படுகிறது...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'செய்தி $done/$total இறக்குமதி செய்யப்படுகிறது...';
  }

  @override
  String get dataRestoreFailed =>
      'மீட்டெடுப்பு தோல்வி — தவறான கடவுச்சொல் அல்லது சிதைந்த கோப்பு';

  @override
  String dataRestoreSuccess(int count) {
    return '$count புதிய செய்திகள் மீட்டெடுக்கப்பட்டன';
  }

  @override
  String get dataRestoreNothingNew =>
      'இறக்குமதி செய்ய புதிய செய்திகள் இல்லை (அனைத்தும் ஏற்கனவே உள்ளன)';

  @override
  String dataRestoreFailedError(String error) {
    return 'மீட்டெடுப்பு தோல்வி: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'விசை ஏற்றுமதியைத் தேர்வுசெய்';

  @override
  String get dataNotValidKeyFile =>
      'செல்லுபடியான Pulse விசை ஏற்றுமதிக் கோப்பு அல்ல';

  @override
  String get dataExportKeys => 'விசைகளை ஏற்றுமதி செய்';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'உங்கள் விசை ஏற்றுமதியை குறியாக்கம் செய்ய கடவுச்சொல்லைத் தேர்வுசெய்க.';

  @override
  String get dataExportKeysConfirmLabel => 'ஏற்றுமதி';

  @override
  String get dataExportingKeys => 'விசைகள் ஏற்றுமதி செய்யப்படுகின்றன';

  @override
  String get dataExportingKeysStatus =>
      'அடையாள விசைகள் குறியாக்கம் செய்யப்படுகின்றன...';

  @override
  String get dataSaveKeyExportDialog => 'விசை ஏற்றுமதியைச் சேமி';

  @override
  String dataKeysExportedTo(String path) {
    return 'விசைகள் ஏற்றுமதி செய்யப்பட்டன:\n$path';
  }

  @override
  String get dataExportFailed => 'ஏற்றுமதி தோல்வி — விசைகள் எதுவும் இல்லை';

  @override
  String dataExportFailedError(String error) {
    return 'ஏற்றுமதி தோல்வி: $error';
  }

  @override
  String get dataImportKeys => 'விசைகளை இறக்குமதி செய்';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'இந்த விசை ஏற்றுமதியை குறியாக்கம் செய்யப் பயன்படுத்திய கடவுச்சொல்லை உள்ளிடவும்.';

  @override
  String get dataImportKeysConfirmLabel => 'இறக்குமதி';

  @override
  String get dataImportingKeys => 'விசைகள் இறக்குமதி செய்யப்படுகின்றன';

  @override
  String get dataImportingKeysStatus =>
      'அடையாள விசைகள் மறையாக்கம் நீக்கப்படுகின்றன...';

  @override
  String get dataImportFailed =>
      'இறக்குமதி தோல்வி — தவறான கடவுச்சொல் அல்லது சிதைந்த கோப்பு';

  @override
  String dataImportFailedError(String error) {
    return 'இறக்குமதி தோல்வி: $error';
  }

  @override
  String get securitySectionTitle => 'பாதுகாப்பு';

  @override
  String get securityIncorrectPassword => 'தவறான கடவுச்சொல்';

  @override
  String get securityPasswordUpdated => 'கடவுச்சொல் புதுப்பிக்கப்பட்டது';

  @override
  String get appearanceSectionTitle => 'தோற்றம்';

  @override
  String appearanceExportFailed(String error) {
    return 'ஏற்றுமதி தோல்வி: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return '$path-இல் சேமிக்கப்பட்டது';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'சேமிப்பு தோல்வி: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'இறக்குமதி தோல்வி: $error';
  }

  @override
  String get aboutSectionTitle => 'பற்றி';

  @override
  String get providerPublicKey => 'பொது விசை';

  @override
  String get providerRelay => 'ரிலே';

  @override
  String get providerAutoConfigured =>
      'உங்கள் மீட்பு கடவுச்சொல்லிலிருந்து தானாக உள்ளமைக்கப்பட்டது. ரிலே தானாகக் கண்டறியப்பட்டது.';

  @override
  String get providerKeyStoredLocally =>
      'உங்கள் விசை பாதுகாப்பான சேமிப்பகத்தில் உள்ளூரில் சேமிக்கப்பட்டுள்ளது — எந்த சேவையகத்திற்கும் ஒருபோதும் அனுப்பப்படாது.';

  @override
  String get providerOxenInfo =>
      'Oxen/Session நெட்வொர்க் — ஒனியன்-வழிமுறை E2EE. உங்கள் Session ID தானாக உருவாக்கப்பட்டு பாதுகாப்பாக சேமிக்கப்படுகிறது. நோட்கள் உள்ளமைக்கப்பட்ட விதை நோட்களிலிருந்து தானாகக் கண்டறியப்படுகின்றன.';

  @override
  String get providerAdvanced => 'மேம்பட்டது';

  @override
  String get providerSaveAndConnect => 'சேமி & இணை';

  @override
  String get providerAddSecondaryInbox => 'இரண்டாம் நிலை இன்பாக்ஸ் சேர்';

  @override
  String get providerSecondaryInboxes => 'இரண்டாம் நிலை இன்பாக்ஸ்கள்';

  @override
  String get providerYourInboxProvider => 'உங்கள் இன்பாக்ஸ் வழங்குநர்';

  @override
  String get providerConnectionDetails => 'இணைப்பு விவரங்கள்';

  @override
  String get addContactTitle => 'தொடர்பு சேர்';

  @override
  String get addContactInviteLinkLabel => 'அழைப்பு இணைப்பு அல்லது முகவரி';

  @override
  String get addContactTapToPaste => 'அழைப்பு இணைப்பை ஒட்ட தட்டவும்';

  @override
  String get addContactPasteTooltip => 'கிளிப்போர்டிலிருந்து ஒட்டு';

  @override
  String get addContactAddressDetected => 'தொடர்பு முகவரி கண்டறியப்பட்டது';

  @override
  String addContactRoutesDetected(int count) {
    return '$count வழிகள் கண்டறியப்பட்டன — SmartRouter வேகமானதைத் தேர்வுசெய்யும்';
  }

  @override
  String get addContactFetchingProfile => 'சுயவிவரம் எடுக்கப்படுகிறது…';

  @override
  String addContactProfileFound(String name) {
    return 'கண்டறியப்பட்டது: $name';
  }

  @override
  String get addContactNoProfileFound => 'சுயவிவரம் எதுவும் கிடைக்கவில்லை';

  @override
  String get addContactDisplayNameLabel => 'காட்சிப் பெயர்';

  @override
  String get addContactDisplayNameHint =>
      'அவர்களை என்னவென்று அழைக்க விரும்புகிறீர்கள்?';

  @override
  String get addContactAddManually => 'முகவரியை நேரடியாகச் சேர்';

  @override
  String get addContactButton => 'தொடர்பு சேர்';

  @override
  String get networkDiagnosticsTitle => 'நெட்வொர்க் கண்டறிதல்';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr ரிலேக்கள்';

  @override
  String get networkDiagnosticsDirect => 'நேரடி';

  @override
  String get networkDiagnosticsTorOnly => 'Tor மட்டும்';

  @override
  String get networkDiagnosticsBest => 'சிறந்தது';

  @override
  String get networkDiagnosticsNone => 'ஏதுமில்லை';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'நிலை';

  @override
  String get networkDiagnosticsConnected => 'இணைக்கப்பட்டது';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'இணைக்கிறது $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'நிறுத்தம்';

  @override
  String get networkDiagnosticsTransport => 'போக்குவரத்து';

  @override
  String get networkDiagnosticsInfrastructure => 'உள்கட்டமைப்பு';

  @override
  String get networkDiagnosticsOxenNodes => 'Oxen நோட்கள்';

  @override
  String get networkDiagnosticsTurnServers => 'TURN சேவையகங்கள்';

  @override
  String get networkDiagnosticsLastProbe => 'கடைசி ஆய்வு';

  @override
  String get networkDiagnosticsRunning => 'இயங்குகிறது...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'கண்டறிதல் இயக்கு';

  @override
  String get networkDiagnosticsForceReprobe => 'முழு மறு-ஆய்வு';

  @override
  String get networkDiagnosticsJustNow => 'இப்போது';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes நிமிடங்களுக்கு முன்';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours மணி நேரத்திற்கு முன்';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days நாட்களுக்கு முன்';
  }

  @override
  String get homeNoEch => 'ECH இல்லை';

  @override
  String get homeNoEchTooltip =>
      'uTLS ப்ராக்ஸி கிடைக்கவில்லை — ECH முடக்கப்பட்டது.\nTLS கைரேகை DPI-க்கு தெரியும்.';

  @override
  String get settingsTitle => 'அமைப்புகள்';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'சேமிக்கப்பட்டது & $provider-உடன் இணைக்கப்பட்டது';
  }

  @override
  String get settingsTorFailedToStart =>
      'உள்ளமைக்கப்பட்ட Tor தொடங்க முடியவில்லை';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon தொடங்க முடியவில்லை';

  @override
  String get verifyTitle => 'பாதுகாப்பு எண்ணைச் சரிபார்';

  @override
  String get verifyIdentityVerified => 'அடையாளம் சரிபார்க்கப்பட்டது';

  @override
  String get verifyNotYetVerified => 'இதுவரை சரிபார்க்கப்படவில்லை';

  @override
  String verifyVerifiedDescription(String name) {
    return 'நீங்கள் $name-இன் பாதுகாப்பு எண்ணைச் சரிபார்த்துள்ளீர்கள்.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return '$name-உடன் நேரில் அல்லது நம்பகமான சேனலில் இந்த எண்களை ஒப்பிடுங்கள்.';
  }

  @override
  String get verifyExplanation =>
      'ஒவ்வொரு உரையாடலுக்கும் ஒரு தனித்துவமான பாதுகாப்பு எண் உள்ளது. இருவரும் இரு சாதனங்களிலும் ஒரே எண்களைக் கண்டால், உங்கள் இணைப்பு எண்ட்-டு-எண்ட் சரிபார்க்கப்பட்டது.';

  @override
  String verifyContactKey(String name) {
    return '$name-இன் விசை';
  }

  @override
  String get verifyYourKey => 'உங்கள் விசை';

  @override
  String get verifyRemoveVerification => 'சரிபார்ப்பை நீக்கு';

  @override
  String get verifyMarkAsVerified => 'சரிபார்க்கப்பட்டதாகக் குறி';

  @override
  String verifyAfterReinstall(String name) {
    return '$name பயன்பாட்டை மீண்டும் நிறுவினால், பாதுகாப்பு எண் மாறும் மற்றும் சரிபார்ப்பு தானாக நீக்கப்படும்.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return '$name-உடன் குரல் அழைப்பு அல்லது நேரில் எண்களை ஒப்பிட்ட பிறகே சரிபார்க்கப்பட்டதாகக் குறிக்கவும்.';
  }

  @override
  String get verifyNoSession =>
      'இதுவரை குறியாக்க அமர்வு நிறுவப்படவில்லை. பாதுகாப்பு எண்களை உருவாக்க முதலில் ஒரு செய்தி அனுப்புங்கள்.';

  @override
  String get verifyNoKeyAvailable => 'விசை கிடைக்கவில்லை';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label கைரேகை நகலெடுக்கப்பட்டது';
  }

  @override
  String get providerDatabaseUrlLabel => 'தரவுத்தள URL';

  @override
  String get providerOptionalHint => 'விருப்பம்';

  @override
  String get providerWebApiKeyLabel => 'Web API விசை';

  @override
  String get providerOptionalForPublicDb => 'பொது DB-க்கு விருப்பம்';

  @override
  String get providerRelayUrlLabel => 'ரிலே URL';

  @override
  String get providerPrivateKeyLabel => 'தனிப்பட்ட விசை';

  @override
  String get providerPrivateKeyNsecLabel => 'தனிப்பட்ட விசை (nsec)';

  @override
  String get providerStorageNodeLabel => 'சேமிப்பக நோட் URL (விருப்பம்)';

  @override
  String get providerStorageNodeHint =>
      'உள்ளமைக்கப்பட்ட விதை நோட்களுக்கு காலியாக விடவும்';

  @override
  String get transferInvalidCodeFormat =>
      'அறியப்படாத குறியீடு வடிவம் — LAN: அல்லது NOS: உடன் தொடங்க வேண்டும்';

  @override
  String get profileCardFingerprintCopied => 'கைரேகை நகலெடுக்கப்பட்டது';

  @override
  String get profileCardAboutHint => 'தனியுரிமை முதலில் 🔒';

  @override
  String get profileCardSaveButton => 'சுயவிவரம் சேமி';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'குறியாக்கம் செய்யப்பட்ட செய்திகள், தொடர்புகள் மற்றும் அவதாரங்களை கோப்பாக ஏற்றுமதி செய்';

  @override
  String get callVideo => 'காணொலி';

  @override
  String get callAudio => 'குரல்';

  @override
  String bubbleDeliveredTo(String names) {
    return '$names-க்கு வழங்கப்பட்டது';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return '$count பேருக்கு வழங்கப்பட்டது';
  }

  @override
  String get groupStatusDialogTitle => 'செய்தி தகவல்';

  @override
  String get groupStatusRead => 'படிக்கப்பட்டது';

  @override
  String get groupStatusDelivered => 'வழங்கப்பட்டது';

  @override
  String get groupStatusPending => 'நிலுவை';

  @override
  String get groupStatusNoData => 'இதுவரை வழங்கல் தகவல் இல்லை';

  @override
  String get profileTransferAdmin => 'நிர்வாகி ஆக்கு';

  @override
  String profileTransferAdminConfirm(String name) {
    return '$name-ஐ புதிய நிர்வாகி ஆக்கவா?';
  }

  @override
  String get profileTransferAdminBody =>
      'நிர்வாகி சலுகைகளை இழப்பீர்கள். இதை மாற்ற முடியாது.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name இப்போது நிர்வாகி';
  }

  @override
  String get profileAdminBadge => 'நிர்வாகி';

  @override
  String get privacyPolicyTitle => 'தனியுரிமைக் கொள்கை';

  @override
  String get privacyOverviewHeading => 'கண்ணோட்டம்';

  @override
  String get privacyOverviewBody =>
      'Pulse ஒரு சேவையகமற்ற, எண்ட்-டு-எண்ட் குறியாக்கம் செய்யப்பட்ட மெசஞ்சர். உங்கள் தனியுரிமை ஒரு அம்சம் மட்டுமல்ல — இது கட்டமைப்பு. Pulse சேவையகங்கள் இல்லை. கணக்குகள் எங்கும் சேமிக்கப்படவில்லை. டெவலப்பர்களால் தரவு சேகரிக்கப்படவோ, அனுப்பப்படவோ, சேமிக்கப்படவோ இல்லை.';

  @override
  String get privacyDataCollectionHeading => 'தரவு சேகரிப்பு';

  @override
  String get privacyDataCollectionBody =>
      'Pulse பூஜ்ஜிய தனிப்பட்ட தரவை சேகரிக்கிறது. குறிப்பாக:\n\n- மின்னஞ்சல், தொலைபேசி எண் அல்லது உண்மையான பெயர் தேவையில்லை\n- பகுப்பாய்வு, கண்காணிப்பு அல்லது தொலைமேட்ரி இல்லை\n- விளம்பர அடையாளங்காட்டிகள் இல்லை\n- தொடர்பு பட்டியல் அணுகல் இல்லை\n- மேக காப்புப்பிரதிகள் இல்லை (செய்திகள் உங்கள் சாதனத்தில் மட்டுமே)\n- Pulse சேவையகத்திற்கு மெட்டாடேட்டா அனுப்பப்படுவதில்லை (ஏதும் இல்லை)';

  @override
  String get privacyEncryptionHeading => 'குறியாக்கம்';

  @override
  String get privacyEncryptionBody =>
      'அனைத்து செய்திகளும் Signal Protocol (X3DH விசை ஒப்பந்தத்துடன் Double Ratchet) பயன்படுத்தி குறியாக்கம் செய்யப்படுகின்றன. குறியாக்க விசைகள் உங்கள் சாதனத்தில் மட்டுமே உருவாக்கப்பட்டு சேமிக்கப்படுகின்றன. டெவலப்பர்கள் உட்பட யாரும் உங்கள் செய்திகளைப் படிக்க முடியாது.';

  @override
  String get privacyNetworkHeading => 'நெட்வொர்க் கட்டமைப்பு';

  @override
  String get privacyNetworkBody =>
      'Pulse கூட்டமைப்பு போக்குவரத்து தகவமைப்பிகளைப் பயன்படுத்துகிறது (Nostr ரிலேக்கள், Session/Oxen சேவை நோட்கள், Firebase Realtime Database, LAN). இந்த போக்குவரத்துகள் குறியாக்கம் செய்யப்பட்ட சைபர்டெக்ஸ்ட்டை மட்டுமே கொண்டு செல்கின்றன. ரிலே ஆபரேட்டர்கள் உங்கள் IP முகவரியையும் போக்குவரத்து அளவையும் பார்க்க முடியும், ஆனால் செய்தி உள்ளடக்கத்தை மறையாக்கம் நீக்க முடியாது.\n\nTor இயக்கப்பட்டிருக்கும்போது, உங்கள் IP முகவரி ரிலே ஆபரேட்டர்களிடமிருந்தும் மறைக்கப்படுகிறது.';

  @override
  String get privacyStunHeading => 'STUN/TURN சேவையகங்கள்';

  @override
  String get privacyStunBody =>
      'குரல் மற்றும் காணொலி அழைப்புகள் DTLS-SRTP குறியாக்கத்துடன் WebRTC பயன்படுத்துகின்றன. STUN சேவையகங்கள் (நிகர-நிகர இணைப்புகளுக்கு உங்கள் பொது IP-ஐ கண்டறிய) மற்றும் TURN சேவையகங்கள் (நேரடி இணைப்பு தோல்வியடையும்போது மீடியாவை ரிலே செய்ய) உங்கள் IP முகவரியையும் அழைப்பு நேரத்தையும் பார்க்க முடியும், ஆனால் அழைப்பு உள்ளடக்கத்தை மறையாக்கம் நீக்க முடியாது.\n\nஅதிகபட்ச தனியுரிமைக்கு அமைப்புகளில் உங்கள் சொந்த TURN சேவையகத்தை உள்ளமைக்கலாம்.';

  @override
  String get privacyCrashHeading => 'செயலிழப்பு அறிக்கை';

  @override
  String get privacyCrashBody =>
      'Sentry செயலிழப்பு அறிக்கை இயக்கப்பட்டிருந்தால் (பில்ட்-டைம் SENTRY_DSN மூலம்), அநாமதேய செயலிழப்பு அறிக்கைகள் அனுப்பப்படலாம். இவற்றில் செய்தி உள்ளடக்கம், தொடர்பு தகவல் அல்லது தனிப்பட்ட அடையாளத் தகவல் எதுவும் இல்லை. DSN-ஐ தவிர்ப்பதன் மூலம் பில்ட்-டைமில் செயலிழப்பு அறிக்கையை முடக்கலாம்.';

  @override
  String get privacyPasswordHeading => 'கடவுச்சொல் & விசைகள்';

  @override
  String get privacyPasswordBody =>
      'உங்கள் மீட்பு கடவுச்சொல் Argon2id (நினைவக-கடினமான KDF) மூலம் குறியாக்க விசைகளை உருவாக்க பயன்படுகிறது. கடவுச்சொல் எங்கும் அனுப்பப்படாது. கடவுச்சொல்லை இழந்தால், உங்கள் கணக்கை மீட்க முடியாது — மீட்டமைக்க சேவையகம் இல்லை.';

  @override
  String get privacyFontsHeading => 'எழுத்துருக்கள்';

  @override
  String get privacyFontsBody =>
      'Pulse அனைத்து எழுத்துருக்களையும் உள்ளூரில் தொகுக்கிறது. Google Fonts அல்லது வெளிப்புற எழுத்துரு சேவைக்கு எந்த கோரிக்கையும் செய்யப்படாது.';

  @override
  String get privacyThirdPartyHeading => 'மூன்றாம் தரப்பு சேவைகள்';

  @override
  String get privacyThirdPartyBody =>
      'Pulse எந்த விளம்பர நெட்வொர்க், பகுப்பாய்வு வழங்குநர், சமூக ஊடக தளம் அல்லது தரவு தரகருடனும் ஒருங்கிணைக்கவில்லை. நீங்கள் உள்ளமைக்கும் போக்குவரத்து ரிலேக்களுக்கு மட்டுமே நெட்வொர்க் இணைப்புகள்.';

  @override
  String get privacyOpenSourceHeading => 'ஓப்பன் சோர்ஸ்';

  @override
  String get privacyOpenSourceBody =>
      'Pulse ஓப்பன்-சோர்ஸ் மென்பொருள். இந்த தனியுரிமை கூற்றுக்களை சரிபார்க்க முழு மூலக் குறியீட்டையும் தணிக்கை செய்யலாம்.';

  @override
  String get privacyContactHeading => 'தொடர்பு';

  @override
  String get privacyContactBody =>
      'தனியுரிமை தொடர்பான கேள்விகளுக்கு, திட்ட களஞ்சியத்தில் ஒரு சிக்கலைத் திறக்கவும்.';

  @override
  String get privacyLastUpdated =>
      'கடைசியாகப் புதுப்பிக்கப்பட்டது: மார்ச் 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'சேமிப்பு தோல்வி: $error';
  }

  @override
  String get themeEngineTitle => 'கருப்பொருள் இயந்திரம்';

  @override
  String get torBuiltInTitle => 'உள்ளமைக்கப்பட்ட Tor';

  @override
  String get torConnectedSubtitle =>
      'இணைக்கப்பட்டது — Nostr 127.0.0.1:9250 வழியாக வழிநடத்தப்படுகிறது';

  @override
  String torConnectingSubtitle(int pct) {
    return 'இணைக்கிறது… $pct%';
  }

  @override
  String get torNotRunning =>
      'இயங்கவில்லை — மறுதொடக்கம் செய்ய சுவிட்சை தட்டவும்';

  @override
  String get torDescription =>
      'Nostr-ஐ Tor வழியாக வழிநடத்துகிறது (தணிக்கை செய்யப்பட்ட நெட்வொர்க்குகளுக்கு Snowflake)';

  @override
  String get torNetworkDiagnostics => 'நெட்வொர்க் கண்டறிதல்';

  @override
  String get torTransportLabel => 'போக்குவரத்து: ';

  @override
  String get torPtAuto => 'தானியங்கு';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'சாதாரணம்';

  @override
  String get torTimeoutLabel => 'நேர வரம்பு: ';

  @override
  String get torInfoDescription =>
      'இயக்கப்பட்டிருக்கும்போது, Nostr WebSocket இணைப்புகள் Tor (SOCKS5) வழியாக வழிநடத்தப்படுகின்றன. Tor Browser 127.0.0.1:9150-இல் கேட்கிறது. தனி tor டீமன் போர்ட் 9050 பயன்படுத்துகிறது. Firebase இணைப்புகள் பாதிக்கப்படுவதில்லை.';

  @override
  String get torRouteNostrTitle => 'Nostr-ஐ Tor வழியாக வழிநடத்து';

  @override
  String get torManagedByBuiltin =>
      'உள்ளமைக்கப்பட்ட Tor ஆல் நிர்வகிக்கப்படுகிறது';

  @override
  String get torActiveRouting =>
      'செயலில் — Nostr போக்குவரத்து Tor வழியாக வழிநடத்தப்படுகிறது';

  @override
  String get torDisabled => 'முடக்கப்பட்டது';

  @override
  String get torProxySocks5 => 'Tor ப்ராக்ஸி (SOCKS5)';

  @override
  String get torProxyHostLabel => 'ப்ராக்ஸி ஹோஸ்ட்';

  @override
  String get torProxyPortLabel => 'போர்ட்';

  @override
  String get torPortInfo =>
      'Tor Browser: போர்ட் 9150  •  tor டீமன்: போர்ட் 9050';

  @override
  String get i2pProxySocks5 => 'I2P ப்ராக்ஸி (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P இயல்பாக போர்ட் 4447-இல் SOCKS5 பயன்படுத்துகிறது. I2P அவுட்ப்ராக்ஸி வழியாக Nostr ரிலேயுடன் இணையுங்கள் (எ.கா. relay.damus.i2p) எந்த போக்குவரத்திலும் உள்ள பயனர்களுடன் தொடர்பு கொள்ள. இரண்டும் இயக்கப்பட்டிருக்கும்போது Tor முன்னுரிமை பெறும்.';

  @override
  String get i2pRouteNostrTitle => 'I2P வழியாக Nostr வழிநடத்து';

  @override
  String get i2pActiveRouting =>
      'செயலில் — Nostr போக்குவரத்து I2P வழியாக வழிநடத்தப்படுகிறது';

  @override
  String get i2pDisabled => 'முடக்கப்பட்டது';

  @override
  String get i2pProxyHostLabel => 'ப்ராக்ஸி ஹோஸ்ட்';

  @override
  String get i2pProxyPortLabel => 'போர்ட்';

  @override
  String get i2pPortInfo => 'I2P Router இயல்பு SOCKS5 போர்ட்: 4447';

  @override
  String get customProxySocks5 => 'தனிப்பயன் ப்ராக்ஸி (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker ரிலே';

  @override
  String get customProxyInfoDescription =>
      'தனிப்பயன் ப்ராக்ஸி உங்கள் V2Ray/Xray/Shadowsocks வழியாக போக்குவரத்தை வழிநடத்துகிறது. CF Worker Cloudflare CDN-இல் தனிப்பட்ட ரிலே ப்ராக்ஸியாக செயல்படுகிறது — GFW பார்ப்பது *.workers.dev, உண்மையான ரிலே அல்ல.';

  @override
  String get customSocks5ProxyTitle => 'தனிப்பயன் SOCKS5 ப்ராக்ஸி';

  @override
  String get customProxyActive =>
      'செயலில் — போக்குவரத்து SOCKS5 வழியாக வழிநடத்தப்படுகிறது';

  @override
  String get customProxyDisabled => 'முடக்கப்பட்டது';

  @override
  String get customProxyHostLabel => 'ப்ராக்ஸி ஹோஸ்ட்';

  @override
  String get customProxyPortLabel => 'போர்ட்';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker டொமைன் (விருப்பம்)';

  @override
  String get customWorkerHelpTitle =>
      'CF Worker ரிலே எவ்வாறு வரிசைப்படுத்துவது (இலவசம்)';

  @override
  String get customWorkerScriptCopied => 'ஸ்கிரிப்ட் நகலெடுக்கப்பட்டது!';

  @override
  String get customWorkerStep1 =>
      '1. dash.cloudflare.com → Workers & Pages செல்லவும்\n2. Create Worker → இந்த ஸ்கிரிப்ட்டை ஒட்டவும்:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → டொமைனை நகலெடுக்கவும் (எ.கா. my-relay.user.workers.dev)\n4. மேலே டொமைனை ஒட்டவும் → சேமி\n\nபயன்பாடு தானாக இணைக்கும்: wss://domain/?r=relay_url\nGFW பார்ப்பது: *.workers.dev (CF CDN) இணைப்பு';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'இணைக்கப்பட்டது — 127.0.0.1:$port-இல் SOCKS5';
  }

  @override
  String get psiphonConnecting => 'இணைக்கிறது…';

  @override
  String get psiphonNotRunning =>
      'இயங்கவில்லை — மறுதொடக்கம் செய்ய சுவிட்சை தட்டவும்';

  @override
  String get psiphonDescription =>
      'வேகமான சுரங்கம் (~3 விநாடி பூட்ஸ்டிராப், 2000+ சுழலும் VPS)';

  @override
  String get turnCommunityServers => 'சமூக TURN சேவையகங்கள்';

  @override
  String get turnCustomServer => 'தனிப்பயன் TURN சேவையகம் (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN சேவையகங்கள் ஏற்கனவே குறியாக்கம் செய்யப்பட்ட ஸ்ட்ரீம்களை (DTLS-SRTP) மட்டுமே ரிலே செய்கின்றன. ரிலே ஆபரேட்டர் உங்கள் IP-யையும் போக்குவரத்து அளவையும் பார்ப்பார், ஆனால் அழைப்புகளை மறையாக்கம் நீக்க முடியாது. நேரடி P2P தோல்வியடையும்போது மட்டுமே TURN பயன்படுத்தப்படும் (~15–20% இணைப்புகள்).';

  @override
  String get turnFreeLabel => 'இலவசம்';

  @override
  String get turnServerUrlLabel => 'TURN சேவையக URL';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 அல்லது turns:...';

  @override
  String get turnUsernameLabel => 'பயனர்பெயர்';

  @override
  String get turnPasswordLabel => 'கடவுச்சொல்';

  @override
  String get turnOptionalHint => 'விருப்பம்';

  @override
  String get turnCustomInfo =>
      'அதிகபட்ச கட்டுப்பாட்டிற்கு எந்த \$5/மாத VPS-இலும் coturn சுய-ஹோஸ்ட் செய்யுங்கள். நற்சான்றிதழ்கள் உள்ளூரில் சேமிக்கப்படும்.';

  @override
  String get themePickerAppearance => 'தோற்றம்';

  @override
  String get themePickerAccentColor => 'உச்ச நிறம்';

  @override
  String get themeModeLight => 'ஒளி';

  @override
  String get themeModeDark => 'இருள்';

  @override
  String get themeModeSystem => 'கணினி';

  @override
  String get themeDynamicPresets => 'முன்னமைவுகள்';

  @override
  String get themeDynamicPrimaryColor => 'முதன்மை நிறம்';

  @override
  String get themeDynamicBorderRadius => 'விளிம்பு ஆரம்';

  @override
  String get themeDynamicFont => 'எழுத்துரு';

  @override
  String get themeDynamicAppearance => 'தோற்றம்';

  @override
  String get themeDynamicUiStyle => 'UI பாணி';

  @override
  String get themeDynamicUiStyleDescription =>
      'உரையாடல்கள், சுவிட்சுகள் மற்றும் குறிகாட்டிகள் எவ்வாறு தோன்றும் என்பதைக் கட்டுப்படுத்துகிறது.';

  @override
  String get themeDynamicSharp => 'கூர்மை';

  @override
  String get themeDynamicRound => 'வட்டம்';

  @override
  String get themeDynamicModeDark => 'இருள்';

  @override
  String get themeDynamicModeLight => 'ஒளி';

  @override
  String get themeDynamicModeAuto => 'தானியங்கு';

  @override
  String get themeDynamicPlatformAuto => 'தானியங்கு';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'தவறான Firebase URL. https://project.firebaseio.com எதிர்பார்க்கப்படுகிறது';

  @override
  String get providerErrorInvalidRelayUrl =>
      'தவறான ரிலே URL. wss://relay.example.com எதிர்பார்க்கப்படுகிறது';

  @override
  String get providerErrorInvalidPulseUrl =>
      'தவறான Pulse சேவையக URL. https://server:port எதிர்பார்க்கப்படுகிறது';

  @override
  String get providerPulseServerUrlLabel => 'சேவையக URL';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'அழைப்புக் குறியீடு';

  @override
  String get providerPulseInviteHint => 'அழைப்புக் குறியீடு (தேவைப்பட்டால்)';

  @override
  String get providerPulseInfo =>
      'சுய-ஹோஸ்ட் ரிலே. உங்கள் மீட்பு கடவுச்சொல்லிலிருந்து விசைகள் பெறப்படுகின்றன.';

  @override
  String get providerScreenTitle => 'இன்பாக்ஸ்கள்';

  @override
  String get providerSecondaryInboxesHeader => 'இரண்டாம் நிலை இன்பாக்ஸ்கள்';

  @override
  String get providerSecondaryInboxesInfo =>
      'இரண்டாம் நிலை இன்பாக்ஸ்கள் மிகைநிலைக்காக ஒரே நேரத்தில் செய்திகளைப் பெறுகின்றன.';

  @override
  String get providerRemoveTooltip => 'நீக்கு';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... அல்லது hex';

  @override
  String get providerNostrPrivkeyHintFull =>
      'nsec1... அல்லது hex தனிப்பட்ட விசை';

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
  String get emojiNoRecent => 'சமீபத்திய ஈமோஜிகள் இல்லை';

  @override
  String get emojiSearchHint => 'ஈமோஜி தேடு...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'உரையாட தட்டவும்';

  @override
  String get imageViewerSaveToDownloads => 'Downloads-இல் சேமி';

  @override
  String imageViewerSavedTo(String path) {
    return '$path-இல் சேமிக்கப்பட்டது';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'சரி';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'மொழி';

  @override
  String get settingsLanguageSubtitle => 'பயன்பாட்டின் காட்சி மொழி';

  @override
  String get settingsLanguageSystem => 'கணினி இயல்பு';

  @override
  String get onboardingLanguageTitle => 'உங்கள் மொழியைத் தேர்வுசெய்க';

  @override
  String get onboardingLanguageSubtitle => 'பின்னர் அமைப்புகளில் மாற்றலாம்';
}
