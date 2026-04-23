// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'संदेश खोजें...';

  @override
  String get search => 'खोजें';

  @override
  String get clearSearch => 'खोज साफ़ करें';

  @override
  String get closeSearch => 'खोज बंद करें';

  @override
  String get moreOptions => 'अन्य विकल्प';

  @override
  String get back => 'वापस';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get close => 'बंद करें';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get remove => 'हटाएँ';

  @override
  String get save => 'सहेजें';

  @override
  String get add => 'जोड़ें';

  @override
  String get copy => 'कॉपी करें';

  @override
  String get skip => 'छोड़ें';

  @override
  String get done => 'हो गया';

  @override
  String get apply => 'लागू करें';

  @override
  String get export => 'निर्यात';

  @override
  String get import => 'आयात';

  @override
  String get homeNewGroup => 'नया समूह';

  @override
  String get homeSettings => 'सेटिंग्स';

  @override
  String get homeSearching => 'संदेश खोज रहे हैं...';

  @override
  String get homeNoResults => 'कोई परिणाम नहीं मिला';

  @override
  String get homeNoChatHistory => 'अभी तक कोई चैट इतिहास नहीं';

  @override
  String homeTransportSwitched(String address) {
    return 'ट्रांसपोर्ट बदला → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name कॉल कर रहा है...';
  }

  @override
  String get homeAccept => 'स्वीकार करें';

  @override
  String get homeDecline => 'अस्वीकार करें';

  @override
  String get homeLoadEarlier => 'पुराने संदेश लोड करें';

  @override
  String get homeChats => 'चैट्स';

  @override
  String get homeSelectConversation => 'एक वार्तालाप चुनें';

  @override
  String get homeNoChatsYet => 'अभी तक कोई चैट नहीं';

  @override
  String get homeAddContactToStart => 'चैट शुरू करने के लिए एक संपर्क जोड़ें';

  @override
  String get homeNewChat => 'नई चैट';

  @override
  String get homeNewChatTooltip => 'नई चैट';

  @override
  String get homeIncomingCallTitle => 'इनकमिंग कॉल';

  @override
  String get homeIncomingGroupCallTitle => 'इनकमिंग ग्रुप कॉल';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — ग्रुप कॉल आ रही है';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return '\"$query\" से मेल खाने वाली कोई चैट नहीं';
  }

  @override
  String get homeSectionChats => 'चैट्स';

  @override
  String get homeSectionMessages => 'संदेश';

  @override
  String get homeDbEncryptionUnavailable =>
      'डेटाबेस एन्क्रिप्शन उपलब्ध नहीं — पूर्ण सुरक्षा के लिए SQLCipher इंस्टॉल करें';

  @override
  String get chatFileTooLargeGroup =>
      'ग्रुप चैट में 512 KB से बड़ी फ़ाइलें समर्थित नहीं हैं';

  @override
  String get chatLargeFile => 'बड़ी फ़ाइल';

  @override
  String get chatCancel => 'रद्द करें';

  @override
  String get chatSend => 'भेजें';

  @override
  String get chatFileTooLarge => 'फ़ाइल बहुत बड़ी है — अधिकतम आकार 100 MB है';

  @override
  String get chatMicDenied => 'माइक्रोफ़ोन अनुमति अस्वीकृत';

  @override
  String get chatVoiceFailed =>
      'वॉइस संदेश सहेजने में विफल — उपलब्ध स्टोरेज जाँचें';

  @override
  String get chatScheduleFuture => 'निर्धारित समय भविष्य में होना चाहिए';

  @override
  String get chatToday => 'आज';

  @override
  String get chatYesterday => 'कल';

  @override
  String get chatEdited => 'संपादित';

  @override
  String get chatYou => 'आप';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'यह फ़ाइल $size MB है। कुछ नेटवर्क पर बड़ी फ़ाइलें भेजना धीमा हो सकता है। जारी रखें?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return '$name की सुरक्षा कुंजी बदल गई है। सत्यापित करने के लिए टैप करें।';
  }

  @override
  String chatEncryptionFailed(String name) {
    return '$name को संदेश एन्क्रिप्ट नहीं किया जा सका — संदेश नहीं भेजा गया।';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return '$name के लिए सुरक्षा नंबर बदल गया। सत्यापित करने के लिए टैप करें।';
  }

  @override
  String get chatNoMessagesFound => 'कोई संदेश नहीं मिला';

  @override
  String get chatMessagesE2ee => 'संदेश एंड-टू-एंड एन्क्रिप्टेड हैं';

  @override
  String get chatSayHello => 'नमस्ते कहें';

  @override
  String get appBarOnline => 'ऑनलाइन';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'टाइप कर रहा है';

  @override
  String get appBarSearchMessages => 'संदेश खोजें...';

  @override
  String get appBarMute => 'म्यूट करें';

  @override
  String get appBarUnmute => 'अनम्यूट करें';

  @override
  String get appBarMedia => 'मीडिया';

  @override
  String get appBarDisappearing => 'गायब होने वाले संदेश';

  @override
  String get appBarDisappearingOn => 'गायब होना: चालू';

  @override
  String get appBarGroupSettings => 'ग्रुप सेटिंग्स';

  @override
  String get appBarSearchTooltip => 'संदेश खोजें';

  @override
  String get appBarVoiceCall => 'वॉइस कॉल';

  @override
  String get appBarVideoCall => 'वीडियो कॉल';

  @override
  String get inputMessage => 'संदेश...';

  @override
  String get inputAttachFile => 'फ़ाइल संलग्न करें';

  @override
  String get inputSendMessage => 'संदेश भेजें';

  @override
  String get inputRecordVoice => 'वॉइस संदेश रिकॉर्ड करें';

  @override
  String get inputSendVoice => 'वॉइस संदेश भेजें';

  @override
  String get inputCancelReply => 'उत्तर रद्द करें';

  @override
  String get inputCancelEdit => 'संपादन रद्द करें';

  @override
  String get inputCancelRecording => 'रिकॉर्डिंग रद्द करें';

  @override
  String get inputRecording => 'रिकॉर्डिंग…';

  @override
  String get inputEditingMessage => 'संदेश संपादित कर रहे हैं';

  @override
  String get inputPhoto => 'फ़ोटो';

  @override
  String get inputVoiceMessage => 'वॉइस संदेश';

  @override
  String get inputFile => 'फ़ाइल';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count निर्धारित संदेश',
      one: '$count निर्धारित संदेश',
    );
    return '$_temp0';
  }

  @override
  String get callInitializing => 'कॉल शुरू हो रही है…';

  @override
  String get callConnecting => 'कनेक्ट हो रहा है…';

  @override
  String get callConnectingRelay => 'कनेक्ट हो रहा है (रिले)…';

  @override
  String get callSwitchingRelay => 'रिले मोड में स्विच हो रहा है…';

  @override
  String get callConnectionFailed => 'कनेक्शन विफल';

  @override
  String get callReconnecting => 'पुनः कनेक्ट हो रहा है…';

  @override
  String get callEnded => 'कॉल समाप्त';

  @override
  String get callLive => 'लाइव';

  @override
  String get callEnd => 'समाप्त';

  @override
  String get callEndCall => 'कॉल समाप्त करें';

  @override
  String get callMute => 'म्यूट करें';

  @override
  String get callUnmute => 'अनम्यूट करें';

  @override
  String get callSpeaker => 'स्पीकर';

  @override
  String get callCameraOn => 'कैमरा चालू';

  @override
  String get callCameraOff => 'कैमरा बंद';

  @override
  String get callShareScreen => 'स्क्रीन शेयर करें';

  @override
  String get callStopShare => 'शेयरिंग बंद करें';

  @override
  String callTorBackup(String duration) {
    return 'Tor बैकअप · $duration';
  }

  @override
  String get callTorBackupBanner => 'Tor बैकअप सक्रिय — प्राथमिक पथ अनुपलब्ध';

  @override
  String get callDirectFailed =>
      'सीधा कनेक्शन विफल — रिले मोड में स्विच हो रहा है…';

  @override
  String get callTurnUnreachable =>
      'TURN सर्वर पहुँच योग्य नहीं हैं। सेटिंग्स → उन्नत में कस्टम TURN जोड़ें।';

  @override
  String get callRelayMode => 'रिले मोड सक्रिय (प्रतिबंधित नेटवर्क)';

  @override
  String get callStarting => 'कॉल शुरू हो रही है…';

  @override
  String get callConnectingToGroup => 'ग्रुप से कनेक्ट हो रहा है…';

  @override
  String get callGroupOpenedInBrowser => 'ग्रुप कॉल ब्राउज़र में खोली गई';

  @override
  String get callCouldNotOpenBrowser => 'ब्राउज़र नहीं खोल सका';

  @override
  String get callInviteLinkSent =>
      'सभी ग्रुप सदस्यों को आमंत्रण लिंक भेजा गया।';

  @override
  String get callOpenLinkManually =>
      'ऊपर दिए गए लिंक को मैन्युअल रूप से खोलें या पुनः प्रयास करने के लिए टैप करें।';

  @override
  String get callJitsiNotE2ee => 'Jitsi कॉल एंड-टू-एंड एन्क्रिप्टेड नहीं हैं';

  @override
  String get callRetryOpenBrowser => 'ब्राउज़र फिर से खोलें';

  @override
  String get callClose => 'बंद करें';

  @override
  String get callCamOn => 'कैमरा चालू';

  @override
  String get callCamOff => 'कैमरा बंद';

  @override
  String get noConnection => 'कनेक्शन नहीं — संदेश कतार में जाएँगे';

  @override
  String get connected => 'कनेक्टेड';

  @override
  String get connecting => 'कनेक्ट हो रहा है…';

  @override
  String get disconnected => 'डिस्कनेक्टेड';

  @override
  String get offlineBanner =>
      'कनेक्शन नहीं — संदेश कतार में जाएँगे और ऑनलाइन होने पर भेजे जाएँगे';

  @override
  String get lanModeBanner =>
      'LAN मोड — कोई इंटरनेट नहीं · केवल स्थानीय नेटवर्क';

  @override
  String get probeCheckingNetwork => 'नेटवर्क कनेक्टिविटी जाँच रहे हैं…';

  @override
  String get probeDiscoveringRelays =>
      'सामुदायिक निर्देशिकाओं से रिले खोज रहे हैं…';

  @override
  String get probeStartingTor => 'बूटस्ट्रैप के लिए Tor शुरू हो रहा है…';

  @override
  String get probeFindingRelaysTor =>
      'Tor के माध्यम से पहुँच योग्य रिले खोज रहे हैं…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिले',
      one: '$count रिले',
    );
    return 'नेटवर्क तैयार — $_temp0 मिले';
  }

  @override
  String get probeNoRelaysFound =>
      'कोई पहुँच योग्य रिले नहीं मिला — संदेश विलंबित हो सकते हैं';

  @override
  String get jitsiWarningTitle => 'एंड-टू-एंड एन्क्रिप्टेड नहीं';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet कॉल Pulse द्वारा एन्क्रिप्ट नहीं होतीं। केवल गैर-संवेदनशील बातचीत के लिए उपयोग करें।';

  @override
  String get jitsiConfirm => 'फिर भी जुड़ें';

  @override
  String get jitsiGroupWarningTitle => 'एंड-टू-एंड एन्क्रिप्टेड नहीं';

  @override
  String get jitsiGroupWarningBody =>
      'इस कॉल में बिल्ट-इन एन्क्रिप्टेड मेश के लिए बहुत अधिक प्रतिभागी हैं।\n\nआपके ब्राउज़र में एक Jitsi Meet लिंक खोला जाएगा। Jitsi एंड-टू-एंड एन्क्रिप्टेड नहीं है — सर्वर आपकी कॉल देख सकता है।';

  @override
  String get jitsiContinueAnyway => 'फिर भी जारी रखें';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get setupCreateAnonymousAccount => 'गुमनाम खाता बनाएँ';

  @override
  String get setupTapToChangeColor => 'रंग बदलने के लिए टैप करें';

  @override
  String get setupReqMinLength => 'कम से कम 16 अक्षर';

  @override
  String get setupReqVariety =>
      '4 में से 3: बड़े अक्षर, छोटे अक्षर, अंक, प्रतीक';

  @override
  String get setupReqMatch => 'पासवर्ड मेल खाते हैं';

  @override
  String get setupYourNickname => 'आपका उपनाम';

  @override
  String get setupRecoveryPassword => 'रिकवरी पासवर्ड (न्यूनतम 16)';

  @override
  String get setupConfirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get setupMin16Chars => 'न्यूनतम 16 अक्षर';

  @override
  String get setupPasswordsDoNotMatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get setupEntropyWeak => 'कमज़ोर';

  @override
  String get setupEntropyOk => 'ठीक';

  @override
  String get setupEntropyStrong => 'मज़बूत';

  @override
  String get setupEntropyWeakNeedsVariety => 'कमज़ोर (3 प्रकार के अक्षर चाहिए)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits बिट्स)';
  }

  @override
  String get setupPasswordWarning =>
      'यह पासवर्ड आपके खाते को पुनर्स्थापित करने का एकमात्र तरीका है। कोई सर्वर नहीं — पासवर्ड रीसेट नहीं। इसे याद रखें या लिख लें।';

  @override
  String get setupCreateAccount => 'खाता बनाएँ';

  @override
  String get setupAlreadyHaveAccount => 'पहले से खाता है? ';

  @override
  String get setupRestore => 'पुनर्स्थापित करें →';

  @override
  String get restoreTitle => 'खाता पुनर्स्थापित करें';

  @override
  String get restoreInfoBanner =>
      'अपना रिकवरी पासवर्ड दर्ज करें — आपका पता (Nostr + Session) स्वचालित रूप से पुनर्स्थापित होगा। संपर्क और संदेश केवल स्थानीय रूप से संग्रहीत थे।';

  @override
  String get restoreNewNickname => 'नया उपनाम (बाद में बदल सकते हैं)';

  @override
  String get restoreButton => 'खाता पुनर्स्थापित करें';

  @override
  String get lockTitle => 'Pulse लॉक है';

  @override
  String get lockSubtitle => 'जारी रखने के लिए अपना पासवर्ड दर्ज करें';

  @override
  String get lockPasswordHint => 'पासवर्ड';

  @override
  String get lockUnlock => 'अनलॉक करें';

  @override
  String get lockPanicHint =>
      'पासवर्ड भूल गए? सभी डेटा मिटाने के लिए अपनी पैनिक कुंजी दर्ज करें।';

  @override
  String get lockTooManyAttempts => 'बहुत अधिक प्रयास। सारा डेटा मिट रहा है…';

  @override
  String get lockWrongPassword => 'गलत पासवर्ड';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'गलत पासवर्ड — $attempts/$max प्रयास';
  }

  @override
  String get onboardingSkip => 'छोड़ें';

  @override
  String get onboardingNext => 'अगला';

  @override
  String get onboardingGetStarted => 'खाता बनाएं';

  @override
  String get onboardingWelcomeTitle => 'Pulse में आपका स्वागत है';

  @override
  String get onboardingWelcomeBody =>
      'एक विकेंद्रीकृत, एंड-टू-एंड एन्क्रिप्टेड मैसेंजर।\n\nकोई केंद्रीय सर्वर नहीं। कोई डेटा संग्रह नहीं। कोई बैकडोर नहीं।\nआपकी बातचीत केवल आपकी है।';

  @override
  String get onboardingTransportTitle => 'ट्रांसपोर्ट-अज्ञेयवादी';

  @override
  String get onboardingTransportBody =>
      'Firebase, Nostr, या दोनों एक साथ उपयोग करें।\n\nसंदेश स्वचालित रूप से नेटवर्क पर रूट होते हैं। सेंसरशिप प्रतिरोध के लिए बिल्ट-इन Tor और I2P सपोर्ट।';

  @override
  String get onboardingSignalTitle => 'Signal + पोस्ट-क्वांटम';

  @override
  String get onboardingSignalBody =>
      'हर संदेश Signal Protocol (Double Ratchet + X3DH) से फॉरवर्ड सीक्रेसी के लिए एन्क्रिप्ट किया जाता है।\n\nइसके अतिरिक्त Kyber-1024 — एक NIST-मानक पोस्ट-क्वांटम एल्गोरिदम — से लिपटा हुआ, जो भविष्य के क्वांटम कंप्यूटरों से सुरक्षा करता है।';

  @override
  String get onboardingKeysTitle => 'आपकी कुंजियाँ आपकी हैं';

  @override
  String get onboardingKeysBody =>
      'आपकी पहचान कुंजियाँ कभी आपके डिवाइस से बाहर नहीं जातीं।\n\nSignal फ़िंगरप्रिंट आपको आउट-ऑफ़-बैंड संपर्कों को सत्यापित करने देते हैं। TOFU (Trust On First Use) स्वचालित रूप से कुंजी परिवर्तनों का पता लगाता है।';

  @override
  String get onboardingThemeTitle => 'अपना रूप चुनें';

  @override
  String get onboardingThemeBody =>
      'एक थीम और एक्सेंट रंग चुनें। आप इसे बाद में सेटिंग्स में कभी भी बदल सकते हैं।';

  @override
  String get contactsNewChat => 'नई चैट';

  @override
  String get contactsAddContact => 'संपर्क जोड़ें';

  @override
  String get contactsSearchHint => 'खोजें...';

  @override
  String get contactsNewGroup => 'नया समूह';

  @override
  String get contactsNoContactsYet => 'अभी तक कोई संपर्क नहीं';

  @override
  String get contactsAddHint => 'किसी का पता जोड़ने के लिए + टैप करें';

  @override
  String get contactsNoMatch => 'कोई संपर्क मेल नहीं खाता';

  @override
  String get contactsRemoveTitle => 'संपर्क हटाएँ';

  @override
  String contactsRemoveMessage(String name) {
    return '$name को हटाएँ?';
  }

  @override
  String get contactsRemove => 'हटाएँ';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count संपर्क',
      one: '$count संपर्क',
    );
    return '$_temp0';
  }

  @override
  String get bubbleOpenLink => 'लिंक खोलें';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'इस URL को अपने ब्राउज़र में खोलें?\n\n$url';
  }

  @override
  String get bubbleOpen => 'खोलें';

  @override
  String get bubbleSecurityWarning => 'सुरक्षा चेतावनी';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" एक एक्ज़ीक्यूटेबल फ़ाइल प्रकार है। इसे सहेजना और चलाना आपके डिवाइस को नुकसान पहुँचा सकता है। फिर भी सहेजें?';
  }

  @override
  String get bubbleSaveAnyway => 'फिर भी सहेजें';

  @override
  String bubbleSavedTo(String path) {
    return '$path में सहेजा गया';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'सहेजना विफल: $error';
  }

  @override
  String get bubbleNotEncrypted => 'एन्क्रिप्टेड नहीं';

  @override
  String get bubbleCorruptedImage => '[दूषित चित्र]';

  @override
  String get bubbleReplyPhoto => 'फ़ोटो';

  @override
  String get bubbleReplyVoice => 'वॉइस संदेश';

  @override
  String get bubbleReplyVideo => 'वीडियो संदेश';

  @override
  String bubbleReadBy(String names) {
    return '$names द्वारा पढ़ा गया';
  }

  @override
  String bubbleReadByCount(int count) {
    return '$count द्वारा पढ़ा गया';
  }

  @override
  String get chatTileTapToStart => 'चैट शुरू करने के लिए टैप करें';

  @override
  String get chatTileMessageSent => 'संदेश भेजा गया';

  @override
  String get chatTileEncryptedMessage => 'एन्क्रिप्टेड संदेश';

  @override
  String chatTileYouPrefix(String text) {
    return 'आप: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 वॉइस मैसेज';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 वॉइस मैसेज ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'एन्क्रिप्टेड संदेश';

  @override
  String get groupNewGroup => 'नया समूह';

  @override
  String get groupGroupName => 'समूह का नाम';

  @override
  String get groupSelectMembers => 'सदस्य चुनें (न्यूनतम 2)';

  @override
  String get groupNoContactsYet =>
      'अभी तक कोई संपर्क नहीं। पहले संपर्क जोड़ें।';

  @override
  String get groupCreate => 'बनाएँ';

  @override
  String get groupLabel => 'समूह';

  @override
  String get profileVerifyIdentity => 'पहचान सत्यापित करें';

  @override
  String profileVerifyInstructions(String name) {
    return 'इन फ़िंगरप्रिंट्स की तुलना $name से वॉइस कॉल पर या व्यक्तिगत रूप से करें। यदि दोनों मान दोनों डिवाइस पर मेल खाते हैं, तो \"सत्यापित के रूप में चिह्नित करें\" टैप करें।';
  }

  @override
  String get profileTheirKey => 'उनकी कुंजी';

  @override
  String get profileYourKey => 'आपकी कुंजी';

  @override
  String get profileRemoveVerification => 'सत्यापन हटाएँ';

  @override
  String get profileMarkAsVerified => 'सत्यापित के रूप में चिह्नित करें';

  @override
  String get profileAddressCopied => 'पता कॉपी किया गया';

  @override
  String get profileNoContactsToAdd =>
      'जोड़ने के लिए कोई संपर्क नहीं — सभी पहले से सदस्य हैं';

  @override
  String get profileAddMembers => 'सदस्य जोड़ें';

  @override
  String profileAddCount(int count) {
    return 'जोड़ें ($count)';
  }

  @override
  String get profileRenameGroup => 'समूह का नाम बदलें';

  @override
  String get profileRename => 'नाम बदलें';

  @override
  String get profileRemoveMember => 'सदस्य हटाएँ?';

  @override
  String profileRemoveMemberBody(String name) {
    return '$name को इस समूह से हटाएँ?';
  }

  @override
  String get profileKick => 'निकालें';

  @override
  String get profileSignalFingerprints => 'Signal फ़िंगरप्रिंट्स';

  @override
  String get profileVerified => 'सत्यापित';

  @override
  String get profileVerify => 'सत्यापित करें';

  @override
  String get profileEdit => 'संपादित करें';

  @override
  String get profileNoSession =>
      'अभी तक कोई सत्र स्थापित नहीं हुआ — पहले एक संदेश भेजें।';

  @override
  String get profileFingerprintCopied => 'फ़िंगरप्रिंट कॉपी किया गया';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सदस्य',
      one: '$count सदस्य',
    );
    return '$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'सुरक्षा नंबर सत्यापित करें';

  @override
  String get profileShowContactQr => 'संपर्क QR दिखाएँ';

  @override
  String profileContactAddress(String name) {
    return '$name का पता';
  }

  @override
  String get profileExportChatHistory => 'चैट इतिहास निर्यात करें';

  @override
  String profileSavedTo(String path) {
    return '$path में सहेजा गया';
  }

  @override
  String get profileExportFailed => 'निर्यात विफल';

  @override
  String get profileClearChatHistory => 'चैट इतिहास साफ़ करें';

  @override
  String get profileDeleteGroup => 'समूह हटाएँ';

  @override
  String get profileDeleteContact => 'संपर्क हटाएँ';

  @override
  String get profileLeaveGroup => 'समूह छोड़ें';

  @override
  String get profileLeaveGroupBody =>
      'आपको इस समूह से हटा दिया जाएगा और यह आपके संपर्कों से हटा दिया जाएगा।';

  @override
  String get groupInviteTitle => 'समूह आमंत्रण';

  @override
  String groupInviteBody(String from, String group) {
    return '$from ने आपको \"$group\" में शामिल होने के लिए आमंत्रित किया';
  }

  @override
  String get groupInviteAccept => 'स्वीकार करें';

  @override
  String get groupInviteDecline => 'अस्वीकार करें';

  @override
  String get groupMemberLimitTitle => 'बहुत अधिक प्रतिभागी';

  @override
  String groupMemberLimitBody(int count) {
    return 'इस समूह में $count प्रतिभागी होंगे। एन्क्रिप्टेड मेश कॉल अधिकतम 6 का समर्थन करती हैं। बड़े समूह Jitsi (E2EE नहीं) पर स्विच होंगे।';
  }

  @override
  String get groupMemberLimitContinue => 'फिर भी जोड़ें';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name ने \"$group\" में शामिल होने से मना कर दिया';
  }

  @override
  String get transferTitle => 'दूसरे डिवाइस में स्थानांतरित करें';

  @override
  String get transferInfoBox =>
      'अपनी Signal पहचान और Nostr कुंजियों को नए डिवाइस में ले जाएँ।\nचैट सत्र स्थानांतरित नहीं होते — फॉरवर्ड सीक्रेसी सुरक्षित रहती है।';

  @override
  String get transferSendFromThis => 'इस डिवाइस से भेजें';

  @override
  String get transferSendSubtitle =>
      'इस डिवाइस में कुंजियाँ हैं। नए डिवाइस के साथ एक कोड साझा करें।';

  @override
  String get transferReceiveOnThis => 'इस डिवाइस पर प्राप्त करें';

  @override
  String get transferReceiveSubtitle =>
      'यह नया डिवाइस है। पुराने डिवाइस से कोड दर्ज करें।';

  @override
  String get transferChooseMethod => 'स्थानांतरण विधि चुनें';

  @override
  String get transferLan => 'LAN (एक ही नेटवर्क)';

  @override
  String get transferLanSubtitle =>
      'तेज़, सीधा। दोनों डिवाइस एक ही Wi-Fi पर होने चाहिए।';

  @override
  String get transferNostrRelay => 'Nostr रिले';

  @override
  String get transferNostrRelaySubtitle =>
      'मौजूदा Nostr रिले का उपयोग करके किसी भी नेटवर्क पर काम करता है।';

  @override
  String get transferRelayUrl => 'रिले URL';

  @override
  String get transferEnterCode => 'स्थानांतरण कोड दर्ज करें';

  @override
  String get transferPasteCode => 'LAN:... या NOS:... कोड यहाँ पेस्ट करें';

  @override
  String get transferConnect => 'कनेक्ट करें';

  @override
  String get transferGenerating => 'स्थानांतरण कोड बना रहे हैं…';

  @override
  String get transferShareCode => 'यह कोड प्राप्तकर्ता के साथ साझा करें:';

  @override
  String get transferCopyCode => 'कोड कॉपी करें';

  @override
  String get transferCodeCopied => 'कोड क्लिपबोर्ड पर कॉपी किया गया';

  @override
  String get transferWaitingReceiver =>
      'प्राप्तकर्ता के कनेक्ट होने की प्रतीक्षा…';

  @override
  String get transferConnectingSender => 'भेजने वाले से कनेक्ट हो रहा है…';

  @override
  String get transferVerifyBoth =>
      'दोनों डिवाइस पर इस कोड की तुलना करें।\nयदि वे मेल खाते हैं, तो स्थानांतरण सुरक्षित है।';

  @override
  String get transferComplete => 'स्थानांतरण पूर्ण';

  @override
  String get transferKeysImported => 'कुंजियाँ आयातित';

  @override
  String get transferCompleteSenderBody =>
      'आपकी कुंजियाँ इस डिवाइस पर सक्रिय रहेंगी।\nप्राप्तकर्ता अब आपकी पहचान का उपयोग कर सकता है।';

  @override
  String get transferCompleteReceiverBody =>
      'कुंजियाँ सफलतापूर्वक आयातित।\nनई पहचान लागू करने के लिए ऐप पुनः आरंभ करें।';

  @override
  String get transferRestartApp => 'ऐप पुनः आरंभ करें';

  @override
  String get transferFailed => 'स्थानांतरण विफल';

  @override
  String get transferTryAgain => 'पुनः प्रयास करें';

  @override
  String get transferEnterRelayFirst => 'पहले एक रिले URL दर्ज करें';

  @override
  String get transferPasteCodeFromSender =>
      'भेजने वाले से स्थानांतरण कोड पेस्ट करें';

  @override
  String get menuReply => 'उत्तर दें';

  @override
  String get menuForward => 'अग्रेषित करें';

  @override
  String get menuReact => 'प्रतिक्रिया दें';

  @override
  String get menuCopy => 'कॉपी करें';

  @override
  String get menuEdit => 'संपादित करें';

  @override
  String get menuRetry => 'पुनः प्रयास करें';

  @override
  String get menuCancelScheduled => 'निर्धारित रद्द करें';

  @override
  String get menuDelete => 'हटाएँ';

  @override
  String get menuForwardTo => 'अग्रेषित करें…';

  @override
  String menuForwardedTo(String name) {
    return '$name को अग्रेषित किया गया';
  }

  @override
  String get menuScheduledMessages => 'निर्धारित संदेश';

  @override
  String get menuNoScheduledMessages => 'कोई निर्धारित संदेश नहीं';

  @override
  String menuSendsOn(String date) {
    return '$date को भेजा जाएगा';
  }

  @override
  String get menuDisappearingMessages => 'गायब होने वाले संदेश';

  @override
  String get menuDisappearingSubtitle =>
      'संदेश चयनित समय के बाद स्वचालित रूप से हट जाते हैं।';

  @override
  String get menuTtlOff => 'बंद';

  @override
  String get menuTtl1h => '1 घंटा';

  @override
  String get menuTtl24h => '24 घंटे';

  @override
  String get menuTtl7d => '7 दिन';

  @override
  String get menuAttachPhoto => 'फ़ोटो';

  @override
  String get menuAttachFile => 'फ़ाइल';

  @override
  String get menuAttachVideo => 'वीडियो';

  @override
  String get mediaTitle => 'मीडिया';

  @override
  String get mediaFileLabel => 'फ़ाइल';

  @override
  String mediaPhotosTab(int count) {
    return 'फ़ोटो ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'फ़ाइलें ($count)';
  }

  @override
  String get mediaNoPhotos => 'अभी तक कोई फ़ोटो नहीं';

  @override
  String get mediaNoFiles => 'अभी तक कोई फ़ाइल नहीं';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Downloads/$name में सहेजा गया';
  }

  @override
  String get mediaFailedToSave => 'फ़ाइल सहेजने में विफल';

  @override
  String get statusNewStatus => 'नई स्थिति';

  @override
  String get statusPublish => 'प्रकाशित करें';

  @override
  String get statusExpiresIn24h => 'स्थिति 24 घंटे में समाप्त हो जाएगी';

  @override
  String get statusWhatsOnYourMind => 'आपके मन में क्या है?';

  @override
  String get statusPhotoAttached => 'फ़ोटो संलग्न';

  @override
  String get statusAttachPhoto => 'फ़ोटो संलग्न करें (वैकल्पिक)';

  @override
  String get statusEnterText =>
      'कृपया अपनी स्थिति के लिए कुछ टेक्स्ट दर्ज करें।';

  @override
  String statusPickPhotoFailed(String error) {
    return 'फ़ोटो चुनने में विफल: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'प्रकाशित करने में विफल: $error';
  }

  @override
  String get panicSetPanicKey => 'पैनिक कुंजी सेट करें';

  @override
  String get panicEmergencySelfDestruct => 'आपातकालीन आत्म-विनाश';

  @override
  String get panicIrreversible => 'यह क्रिया अपरिवर्तनीय है';

  @override
  String get panicWarningBody =>
      'लॉक स्क्रीन पर यह कुंजी दर्ज करने से सारा डेटा तुरंत मिट जाता है — संदेश, संपर्क, कुंजियाँ, पहचान। अपने सामान्य पासवर्ड से अलग कुंजी का उपयोग करें।';

  @override
  String get panicKeyHint => 'पैनिक कुंजी';

  @override
  String get panicConfirmHint => 'पैनिक कुंजी की पुष्टि करें';

  @override
  String get panicMinChars => 'पैनिक कुंजी कम से कम 8 अक्षर की होनी चाहिए';

  @override
  String get panicKeysDoNotMatch => 'कुंजियाँ मेल नहीं खातीं';

  @override
  String get panicSetFailed =>
      'पैनिक कुंजी सहेजने में विफल — कृपया पुनः प्रयास करें';

  @override
  String get passwordSetAppPassword => 'ऐप पासवर्ड सेट करें';

  @override
  String get passwordProtectsMessages =>
      'आपके संदेशों को निष्क्रिय अवस्था में सुरक्षित करता है';

  @override
  String get passwordInfoBanner =>
      'हर बार Pulse खोलते समय आवश्यक। भूलने पर आपका डेटा पुनर्प्राप्त नहीं किया जा सकता।';

  @override
  String get passwordHint => 'पासवर्ड';

  @override
  String get passwordConfirmHint => 'पासवर्ड की पुष्टि करें';

  @override
  String get passwordSetButton => 'पासवर्ड सेट करें';

  @override
  String get passwordSkipForNow => 'अभी छोड़ें';

  @override
  String get passwordMinChars => 'पासवर्ड कम से कम 8 अक्षर का होना चाहिए';

  @override
  String get passwordNeedsVariety =>
      'अक्षर, संख्याएं और विशेष वर्ण शामिल होने चाहिए';

  @override
  String get passwordRequirements =>
      'न्यूनतम 8 अक्षर अक्षरों, संख्याओं और एक विशेष वर्ण के साथ';

  @override
  String get passwordsDoNotMatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get profileCardSaved => 'प्रोफ़ाइल सहेजी गई!';

  @override
  String get profileCardE2eeIdentity => 'E2EE पहचान';

  @override
  String get profileCardDisplayName => 'प्रदर्शन नाम';

  @override
  String get profileCardDisplayNameHint => 'जैसे अमित शर्मा';

  @override
  String get profileCardAbout => 'परिचय';

  @override
  String get profileCardSaveProfile => 'प्रोफ़ाइल सहेजें';

  @override
  String get profileCardYourName => 'आपका नाम';

  @override
  String get profileCardAddressCopied => 'पता कॉपी किया गया!';

  @override
  String get profileCardInboxAddress => 'आपका इनबॉक्स पता';

  @override
  String get profileCardInboxAddresses => 'आपके इनबॉक्स पते';

  @override
  String get profileCardShareAllAddresses => 'सभी पते साझा करें (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'संपर्कों के साथ साझा करें ताकि वे आपको संदेश भेज सकें।';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'सभी $count पते एक लिंक के रूप में कॉपी किए गए!';
  }

  @override
  String get settingsMyProfile => 'मेरी प्रोफ़ाइल';

  @override
  String get settingsYourInboxAddress => 'आपका इनबॉक्स पता';

  @override
  String get settingsMyQrCode => 'संपर्क साझा करें';

  @override
  String get settingsMyQrSubtitle => 'आपके पते के लिए QR कोड और आमंत्रण लिंक';

  @override
  String get settingsShareMyAddress => 'मेरा पता साझा करें';

  @override
  String get settingsNoAddressYet =>
      'अभी तक कोई पता नहीं — पहले सेटिंग्स सहेजें';

  @override
  String get settingsInviteLink => 'आमंत्रण लिंक';

  @override
  String get settingsRawAddress => 'मूल पता';

  @override
  String get settingsCopyLink => 'लिंक कॉपी करें';

  @override
  String get settingsCopyAddress => 'पता कॉपी करें';

  @override
  String get settingsInviteLinkCopied => 'आमंत्रण लिंक कॉपी किया गया';

  @override
  String get settingsAppearance => 'दिखावट';

  @override
  String get settingsThemeEngine => 'थीम इंजन';

  @override
  String get settingsThemeEngineSubtitle => 'रंग और फ़ॉन्ट अनुकूलित करें';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle =>
      'E2EE कुंजियाँ सुरक्षित रूप से संग्रहीत हैं';

  @override
  String get settingsActive => 'सक्रिय';

  @override
  String get settingsIdentityBackup => 'पहचान बैकअप';

  @override
  String get settingsIdentityBackupSubtitle =>
      'अपनी Signal पहचान निर्यात या आयात करें';

  @override
  String get settingsIdentityBackupBody =>
      'अपनी Signal पहचान कुंजियों को बैकअप कोड में निर्यात करें, या किसी मौजूदा कोड से पुनर्स्थापित करें।';

  @override
  String get settingsTransferDevice => 'दूसरे डिवाइस में स्थानांतरित करें';

  @override
  String get settingsTransferDeviceSubtitle =>
      'LAN या Nostr रिले के माध्यम से अपनी पहचान ले जाएँ';

  @override
  String get settingsExportIdentity => 'पहचान निर्यात करें';

  @override
  String get settingsExportIdentityBody =>
      'इस बैकअप कोड को कॉपी करें और सुरक्षित रखें:';

  @override
  String get settingsSaveFile => 'फ़ाइल सहेजें';

  @override
  String get settingsImportIdentity => 'पहचान आयात करें';

  @override
  String get settingsImportIdentityBody =>
      'अपना बैकअप कोड नीचे पेस्ट करें। यह आपकी वर्तमान पहचान को बदल देगा।';

  @override
  String get settingsPasteBackupCode => 'बैकअप कोड यहाँ पेस्ट करें…';

  @override
  String get settingsIdentityImported =>
      'पहचान + संपर्क आयातित! लागू करने के लिए ऐप पुनः आरंभ करें।';

  @override
  String get settingsSecurity => 'सुरक्षा';

  @override
  String get settingsAppPassword => 'ऐप पासवर्ड';

  @override
  String get settingsPasswordEnabled => 'सक्षम — हर लॉन्च पर आवश्यक';

  @override
  String get settingsPasswordDisabled => 'अक्षम — ऐप बिना पासवर्ड के खुलता है';

  @override
  String get settingsChangePassword => 'पासवर्ड बदलें';

  @override
  String get settingsChangePasswordSubtitle => 'अपना ऐप लॉक पासवर्ड अपडेट करें';

  @override
  String get settingsSetPanicKey => 'पैनिक कुंजी सेट करें';

  @override
  String get settingsChangePanicKey => 'पैनिक कुंजी बदलें';

  @override
  String get settingsPanicKeySetSubtitle => 'आपातकालीन वाइप कुंजी अपडेट करें';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'एक कुंजी जो तुरंत सारा डेटा मिटा दे';

  @override
  String get settingsRemovePanicKey => 'पैनिक कुंजी हटाएँ';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'आपातकालीन आत्म-विनाश अक्षम करें';

  @override
  String get settingsRemovePanicKeyBody =>
      'आपातकालीन आत्म-विनाश अक्षम हो जाएगा। आप इसे कभी भी पुनः सक्षम कर सकते हैं।';

  @override
  String get settingsDisableAppPassword => 'ऐप पासवर्ड अक्षम करें';

  @override
  String get settingsEnterCurrentPassword =>
      'पुष्टि के लिए अपना वर्तमान पासवर्ड दर्ज करें';

  @override
  String get settingsCurrentPassword => 'वर्तमान पासवर्ड';

  @override
  String get settingsIncorrectPassword => 'गलत पासवर्ड';

  @override
  String get settingsPasswordUpdated => 'पासवर्ड अपडेट किया गया';

  @override
  String get settingsChangePasswordProceed =>
      'आगे बढ़ने के लिए अपना वर्तमान पासवर्ड दर्ज करें';

  @override
  String get settingsData => 'डेटा';

  @override
  String get settingsBackupMessages => 'संदेश बैकअप';

  @override
  String get settingsBackupMessagesSubtitle =>
      'एन्क्रिप्टेड संदेश इतिहास को फ़ाइल में निर्यात करें';

  @override
  String get settingsRestoreMessages => 'संदेश पुनर्स्थापित करें';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'बैकअप फ़ाइल से संदेश आयात करें';

  @override
  String get settingsExportKeys => 'कुंजियाँ निर्यात करें';

  @override
  String get settingsExportKeysSubtitle =>
      'पहचान कुंजियों को एन्क्रिप्टेड फ़ाइल में सहेजें';

  @override
  String get settingsImportKeys => 'कुंजियाँ आयात करें';

  @override
  String get settingsImportKeysSubtitle =>
      'निर्यातित फ़ाइल से पहचान कुंजियाँ पुनर्स्थापित करें';

  @override
  String get settingsBackupPassword => 'बैकअप पासवर्ड';

  @override
  String get settingsPasswordCannotBeEmpty => 'पासवर्ड खाली नहीं हो सकता';

  @override
  String get settingsPasswordMin4Chars =>
      'पासवर्ड कम से कम 4 अक्षर का होना चाहिए';

  @override
  String get settingsCallsTurn => 'कॉल्स और TURN';

  @override
  String get settingsLocalNetwork => 'स्थानीय नेटवर्क';

  @override
  String get settingsCensorshipResistance => 'सेंसरशिप प्रतिरोध';

  @override
  String get settingsNetwork => 'नेटवर्क';

  @override
  String get settingsProxyTunnels => 'प्रॉक्सी और टनल';

  @override
  String get settingsTurnServers => 'TURN सर्वर';

  @override
  String get settingsProviderTitle => 'प्रदाता';

  @override
  String get settingsLanFallback => 'LAN फ़ॉलबैक';

  @override
  String get settingsLanFallbackSubtitle =>
      'इंटरनेट अनुपलब्ध होने पर स्थानीय नेटवर्क पर उपस्थिति प्रसारित करें और संदेश वितरित करें। अविश्वसनीय नेटवर्क (सार्वजनिक Wi-Fi) पर अक्षम करें।';

  @override
  String get settingsBgDelivery => 'बैकग्राउंड डिलीवरी';

  @override
  String get settingsBgDeliverySubtitle =>
      'ऐप मिनिमाइज़ होने पर भी संदेश प्राप्त करते रहें। एक स्थायी सूचना दिखाता है।';

  @override
  String get settingsYourInboxProvider => 'आपका इनबॉक्स प्रदाता';

  @override
  String get settingsConnectionDetails => 'कनेक्शन विवरण';

  @override
  String get settingsSaveAndConnect => 'सहेजें और कनेक्ट करें';

  @override
  String get settingsSecondaryInboxes => 'द्वितीयक इनबॉक्स';

  @override
  String get settingsAddSecondaryInbox => 'द्वितीयक इनबॉक्स जोड़ें';

  @override
  String get settingsAdvanced => 'उन्नत';

  @override
  String get settingsDiscover => 'खोजें';

  @override
  String get settingsAbout => 'परिचय';

  @override
  String get settingsPrivacyPolicy => 'गोपनीयता नीति';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Pulse आपके डेटा की सुरक्षा कैसे करता है';

  @override
  String get settingsCrashReporting => 'क्रैश रिपोर्टिंग';

  @override
  String get settingsCrashReportingSubtitle =>
      'Pulse को बेहतर बनाने के लिए गुमनाम क्रैश रिपोर्ट भेजें। संदेश सामग्री या संपर्क कभी नहीं भेजे जाते।';

  @override
  String get settingsCrashReportingEnabled =>
      'क्रैश रिपोर्टिंग सक्षम — लागू करने के लिए ऐप पुनः आरंभ करें';

  @override
  String get settingsCrashReportingDisabled =>
      'क्रैश रिपोर्टिंग अक्षम — लागू करने के लिए ऐप पुनः आरंभ करें';

  @override
  String get settingsSensitiveOperation => 'संवेदनशील कार्रवाई';

  @override
  String get settingsSensitiveOperationBody =>
      'ये कुंजियाँ आपकी पहचान हैं। इस फ़ाइल वाला कोई भी व्यक्ति आपका रूप धारण कर सकता है। इसे सुरक्षित रूप से संग्रहीत करें और स्थानांतरण के बाद हटा दें।';

  @override
  String get settingsIUnderstandContinue => 'मैं समझता/समझती हूँ, जारी रखें';

  @override
  String get settingsReplaceIdentity => 'पहचान बदलें?';

  @override
  String get settingsReplaceIdentityBody =>
      'यह आपकी वर्तमान पहचान कुंजियों को बदल देगा। आपके मौजूदा Signal सत्र अमान्य हो जाएँगे और संपर्कों को पुनः एन्क्रिप्शन स्थापित करना होगा। ऐप को पुनः आरंभ करना होगा।';

  @override
  String get settingsReplaceKeys => 'कुंजियाँ बदलें';

  @override
  String get settingsKeysImported => 'कुंजियाँ आयातित';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count कुंजियाँ सफलतापूर्वक आयातित। नई पहचान के साथ पुनः आरंभ करने के लिए कृपया ऐप पुनः शुरू करें।';
  }

  @override
  String get settingsRestartNow => 'अभी पुनः आरंभ करें';

  @override
  String get settingsLater => 'बाद में';

  @override
  String get profileGroupLabel => 'समूह';

  @override
  String get profileAddButton => 'जोड़ें';

  @override
  String get profileKickButton => 'निकालें';

  @override
  String get dataSectionTitle => 'डेटा';

  @override
  String get dataBackupMessages => 'संदेश बैकअप';

  @override
  String get dataBackupPasswordSubtitle =>
      'अपने संदेश बैकअप को एन्क्रिप्ट करने के लिए एक पासवर्ड चुनें।';

  @override
  String get dataBackupConfirmLabel => 'बैकअप बनाएँ';

  @override
  String get dataCreatingBackup => 'बैकअप बना रहे हैं';

  @override
  String get dataBackupPreparing => 'तैयार हो रहा है...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'संदेश $done / $total निर्यात हो रहा है...';
  }

  @override
  String get dataBackupSavingFile => 'फ़ाइल सहेज रहे हैं...';

  @override
  String get dataSaveMessageBackupDialog => 'संदेश बैकअप सहेजें';

  @override
  String dataBackupSaved(int count, String path) {
    return 'बैकअप सहेजा गया ($count संदेश)\n$path';
  }

  @override
  String get dataBackupFailed => 'बैकअप विफल — कोई डेटा निर्यात नहीं हुआ';

  @override
  String dataBackupFailedError(String error) {
    return 'बैकअप विफल: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'संदेश बैकअप चुनें';

  @override
  String get dataInvalidBackupFile => 'अमान्य बैकअप फ़ाइल (बहुत छोटी)';

  @override
  String get dataNotValidBackupFile => 'मान्य Pulse बैकअप फ़ाइल नहीं है';

  @override
  String get dataRestoreMessages => 'संदेश पुनर्स्थापित करें';

  @override
  String get dataRestorePasswordSubtitle =>
      'इस बैकअप को बनाते समय उपयोग किया गया पासवर्ड दर्ज करें।';

  @override
  String get dataRestoreConfirmLabel => 'पुनर्स्थापित करें';

  @override
  String get dataRestoringMessages => 'संदेश पुनर्स्थापित हो रहे हैं';

  @override
  String get dataRestoreDecrypting => 'डिक्रिप्ट हो रहा है...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'संदेश $done / $total आयात हो रहा है...';
  }

  @override
  String get dataRestoreFailed =>
      'पुनर्स्थापना विफल — गलत पासवर्ड या दूषित फ़ाइल';

  @override
  String dataRestoreSuccess(int count) {
    return '$count नए संदेश पुनर्स्थापित किए गए';
  }

  @override
  String get dataRestoreNothingNew =>
      'आयात के लिए कोई नया संदेश नहीं (सभी पहले से मौजूद हैं)';

  @override
  String dataRestoreFailedError(String error) {
    return 'पुनर्स्थापना विफल: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'कुंजी निर्यात चुनें';

  @override
  String get dataNotValidKeyFile => 'मान्य Pulse कुंजी निर्यात फ़ाइल नहीं है';

  @override
  String get dataExportKeys => 'कुंजियाँ निर्यात करें';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'अपने कुंजी निर्यात को एन्क्रिप्ट करने के लिए एक पासवर्ड चुनें।';

  @override
  String get dataExportKeysConfirmLabel => 'निर्यात करें';

  @override
  String get dataExportingKeys => 'कुंजियाँ निर्यात हो रही हैं';

  @override
  String get dataExportingKeysStatus =>
      'पहचान कुंजियाँ एन्क्रिप्ट हो रही हैं...';

  @override
  String get dataSaveKeyExportDialog => 'कुंजी निर्यात सहेजें';

  @override
  String dataKeysExportedTo(String path) {
    return 'कुंजियाँ यहाँ निर्यात की गईं:\n$path';
  }

  @override
  String get dataExportFailed => 'निर्यात विफल — कोई कुंजी नहीं मिली';

  @override
  String dataExportFailedError(String error) {
    return 'निर्यात विफल: $error';
  }

  @override
  String get dataImportKeys => 'कुंजियाँ आयात करें';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'इस कुंजी निर्यात को एन्क्रिप्ट करने के लिए उपयोग किया गया पासवर्ड दर्ज करें।';

  @override
  String get dataImportKeysConfirmLabel => 'आयात करें';

  @override
  String get dataImportingKeys => 'कुंजियाँ आयात हो रही हैं';

  @override
  String get dataImportingKeysStatus =>
      'पहचान कुंजियाँ डिक्रिप्ट हो रही हैं...';

  @override
  String get dataImportFailed => 'आयात विफल — गलत पासवर्ड या दूषित फ़ाइल';

  @override
  String dataImportFailedError(String error) {
    return 'आयात विफल: $error';
  }

  @override
  String get securitySectionTitle => 'सुरक्षा';

  @override
  String get securityIncorrectPassword => 'गलत पासवर्ड';

  @override
  String get securityPasswordUpdated => 'पासवर्ड अपडेट किया गया';

  @override
  String get appearanceSectionTitle => 'दिखावट';

  @override
  String appearanceExportFailed(String error) {
    return 'निर्यात विफल: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return '$path में सहेजा गया';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'सहेजना विफल: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'आयात विफल: $error';
  }

  @override
  String get aboutSectionTitle => 'परिचय';

  @override
  String get providerPublicKey => 'सार्वजनिक कुंजी';

  @override
  String get providerRelay => 'रिले';

  @override
  String get providerAutoConfigured =>
      'आपके रिकवरी पासवर्ड से स्वचालित रूप से कॉन्फ़िगर किया गया। रिले स्वतः खोजा गया।';

  @override
  String get providerKeyStoredLocally =>
      'आपकी कुंजी सुरक्षित स्टोरेज में स्थानीय रूप से संग्रहीत है — कभी किसी सर्वर को नहीं भेजी जाती।';

  @override
  String get providerSessionInfo =>
      'Session Network — प्याज-रूटेड E2EE। आपकी Session ID स्वचालित रूप से उत्पन्न होती है और सुरक्षित रूप से संग्रहीत होती है। नोड्स बिल्ट-इन सीड नोड्स से स्वचालित रूप से खोजे जाते हैं।';

  @override
  String get providerAdvanced => 'उन्नत';

  @override
  String get providerSaveAndConnect => 'सहेजें और कनेक्ट करें';

  @override
  String get providerAddSecondaryInbox => 'द्वितीयक इनबॉक्स जोड़ें';

  @override
  String get providerSecondaryInboxes => 'द्वितीयक इनबॉक्स';

  @override
  String get providerYourInboxProvider => 'आपका इनबॉक्स प्रदाता';

  @override
  String get providerConnectionDetails => 'कनेक्शन विवरण';

  @override
  String get addContactTitle => 'संपर्क जोड़ें';

  @override
  String get addContactInviteLinkLabel => 'आमंत्रण लिंक या पता';

  @override
  String get addContactTapToPaste => 'आमंत्रण लिंक पेस्ट करने के लिए टैप करें';

  @override
  String get addContactPasteTooltip => 'क्लिपबोर्ड से पेस्ट करें';

  @override
  String get addContactAddressDetected => 'संपर्क पता पहचाना गया';

  @override
  String addContactRoutesDetected(int count) {
    return '$count मार्ग पहचाने गए — SmartRouter सबसे तेज़ चुनता है';
  }

  @override
  String get addContactFetchingProfile => 'प्रोफ़ाइल प्राप्त हो रही है…';

  @override
  String addContactProfileFound(String name) {
    return 'मिला: $name';
  }

  @override
  String get addContactNoProfileFound => 'कोई प्रोफ़ाइल नहीं मिली';

  @override
  String get addContactDisplayNameLabel => 'प्रदर्शन नाम';

  @override
  String get addContactDisplayNameHint => 'आप उन्हें क्या बुलाना चाहते हैं?';

  @override
  String get addContactAddManually => 'पता मैन्युअल रूप से जोड़ें';

  @override
  String get addContactButton => 'संपर्क जोड़ें';

  @override
  String get networkDiagnosticsTitle => 'नेटवर्क निदान';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr रिले';

  @override
  String get networkDiagnosticsDirect => 'सीधे';

  @override
  String get networkDiagnosticsTorOnly => 'केवल Tor';

  @override
  String get networkDiagnosticsBest => 'सर्वश्रेष्ठ';

  @override
  String get networkDiagnosticsNone => 'कोई नहीं';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'स्थिति';

  @override
  String get networkDiagnosticsConnected => 'कनेक्टेड';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'कनेक्ट हो रहा है $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'बंद';

  @override
  String get networkDiagnosticsTransport => 'ट्रांसपोर्ट';

  @override
  String get networkDiagnosticsInfrastructure => 'अवसंरचना';

  @override
  String get networkDiagnosticsSessionNodes => 'Session नोड्स';

  @override
  String get networkDiagnosticsTurnServers => 'TURN सर्वर';

  @override
  String get networkDiagnosticsLastProbe => 'अंतिम जाँच';

  @override
  String get networkDiagnosticsRunning => 'चल रहा है...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'निदान चलाएँ';

  @override
  String get networkDiagnosticsForceReprobe => 'पूर्ण पुनः जाँच करें';

  @override
  String get networkDiagnosticsJustNow => 'अभी';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes मिनट पहले';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours घंटे पहले';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days दिन पहले';
  }

  @override
  String get homeNoEch => 'ECH नहीं';

  @override
  String get homeNoEchTooltip =>
      'uTLS प्रॉक्सी अनुपलब्ध — ECH अक्षम।\nTLS फ़िंगरप्रिंट DPI को दिखाई देता है।';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String settingsSavedConnectedTo(String provider) {
    return '$provider से सहेजा और कनेक्ट किया गया';
  }

  @override
  String get settingsTorFailedToStart => 'बिल्ट-इन Tor शुरू होने में विफल';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon शुरू होने में विफल';

  @override
  String get verifyTitle => 'सुरक्षा नंबर सत्यापित करें';

  @override
  String get verifyIdentityVerified => 'पहचान सत्यापित';

  @override
  String get verifyNotYetVerified => 'अभी तक सत्यापित नहीं';

  @override
  String verifyVerifiedDescription(String name) {
    return 'आपने $name का सुरक्षा नंबर सत्यापित किया है।';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'इन नंबरों की तुलना $name से व्यक्तिगत रूप से या विश्वसनीय चैनल पर करें।';
  }

  @override
  String get verifyExplanation =>
      'प्रत्येक वार्तालाप का एक अद्वितीय सुरक्षा नंबर होता है। यदि आप दोनों अपने डिवाइस पर समान नंबर देखते हैं, तो आपका कनेक्शन एंड-टू-एंड सत्यापित है।';

  @override
  String verifyContactKey(String name) {
    return '$name की कुंजी';
  }

  @override
  String get verifyYourKey => 'आपकी कुंजी';

  @override
  String get verifyRemoveVerification => 'सत्यापन हटाएँ';

  @override
  String get verifyMarkAsVerified => 'सत्यापित के रूप में चिह्नित करें';

  @override
  String verifyAfterReinstall(String name) {
    return 'यदि $name ऐप पुनः इंस्टॉल करता है, तो सुरक्षा नंबर बदल जाएगा और सत्यापन स्वचालित रूप से हटा दिया जाएगा।';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'केवल $name से वॉइस कॉल पर या व्यक्तिगत रूप से नंबर तुलना करने के बाद ही सत्यापित के रूप में चिह्नित करें।';
  }

  @override
  String get verifyNoSession =>
      'अभी तक कोई एन्क्रिप्शन सत्र स्थापित नहीं हुआ। सुरक्षा नंबर बनाने के लिए पहले एक संदेश भेजें।';

  @override
  String get verifyNoKeyAvailable => 'कोई कुंजी उपलब्ध नहीं';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label फ़िंगरप्रिंट कॉपी किया गया';
  }

  @override
  String get providerDatabaseUrlLabel => 'डेटाबेस URL';

  @override
  String get providerOptionalHint => 'वैकल्पिक';

  @override
  String get providerWebApiKeyLabel => 'वेब API कुंजी';

  @override
  String get providerOptionalForPublicDb => 'सार्वजनिक DB के लिए वैकल्पिक';

  @override
  String get providerRelayUrlLabel => 'रिले URL';

  @override
  String get providerPrivateKeyLabel => 'निजी कुंजी';

  @override
  String get providerPrivateKeyNsecLabel => 'निजी कुंजी (nsec)';

  @override
  String get providerStorageNodeLabel => 'स्टोरेज नोड URL (वैकल्पिक)';

  @override
  String get providerStorageNodeHint => 'बिल्ट-इन सीड नोड्स के लिए खाली छोड़ें';

  @override
  String get transferInvalidCodeFormat =>
      'अपरिचित कोड प्रारूप — LAN: या NOS: से शुरू होना चाहिए';

  @override
  String get profileCardFingerprintCopied => 'फ़िंगरप्रिंट कॉपी किया गया';

  @override
  String get profileCardAboutHint => 'गोपनीयता सबसे पहले 🔒';

  @override
  String get profileCardSaveButton => 'प्रोफ़ाइल सहेजें';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'एन्क्रिप्टेड संदेश, संपर्क और अवतार फ़ाइल में निर्यात करें';

  @override
  String get callVideo => 'वीडियो';

  @override
  String get callAudio => 'ऑडियो';

  @override
  String bubbleDeliveredTo(String names) {
    return '$names को वितरित किया गया';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return '$count को वितरित किया गया';
  }

  @override
  String get groupStatusDialogTitle => 'संदेश जानकारी';

  @override
  String get groupStatusRead => 'पढ़ा गया';

  @override
  String get groupStatusDelivered => 'वितरित';

  @override
  String get groupStatusPending => 'लंबित';

  @override
  String get groupStatusNoData => 'अभी तक कोई वितरण जानकारी नहीं';

  @override
  String get profileTransferAdmin => 'एडमिन बनाएँ';

  @override
  String profileTransferAdminConfirm(String name) {
    return '$name को नया एडमिन बनाएँ?';
  }

  @override
  String get profileTransferAdminBody =>
      'आप एडमिन अधिकार खो देंगे। यह पूर्ववत नहीं किया जा सकता।';

  @override
  String profileTransferAdminDone(String name) {
    return '$name अब एडमिन है';
  }

  @override
  String get profileAdminBadge => 'एडमिन';

  @override
  String get privacyPolicyTitle => 'गोपनीयता नीति';

  @override
  String get privacyOverviewHeading => 'अवलोकन';

  @override
  String get privacyOverviewBody =>
      'Pulse एक सर्वरलेस, एंड-टू-एंड एन्क्रिप्टेड मैसेंजर है। आपकी गोपनीयता केवल एक सुविधा नहीं — यह आर्किटेक्चर है। कोई Pulse सर्वर नहीं हैं। कोई खाता कहीं भी संग्रहीत नहीं है। डेवलपर्स द्वारा कोई डेटा एकत्रित, प्रेषित या संग्रहीत नहीं किया जाता।';

  @override
  String get privacyDataCollectionHeading => 'डेटा संग्रह';

  @override
  String get privacyDataCollectionBody =>
      'Pulse शून्य व्यक्तिगत डेटा एकत्र करता है। विशेष रूप से:\n\n- कोई ईमेल, फ़ोन नंबर, या असली नाम आवश्यक नहीं\n- कोई एनालिटिक्स, ट्रैकिंग, या टेलीमेट्री नहीं\n- कोई विज्ञापन पहचानकर्ता नहीं\n- कोई संपर्क सूची एक्सेस नहीं\n- कोई क्लाउड बैकअप नहीं (संदेश केवल आपके डिवाइस पर हैं)\n- कोई मेटाडेटा किसी Pulse सर्वर को नहीं भेजा जाता (कोई सर्वर नहीं है)';

  @override
  String get privacyEncryptionHeading => 'एन्क्रिप्शन';

  @override
  String get privacyEncryptionBody =>
      'सभी संदेश Signal Protocol (X3DH कुंजी सहमति के साथ Double Ratchet) का उपयोग करके एन्क्रिप्ट किए जाते हैं। एन्क्रिप्शन कुंजियाँ विशेष रूप से आपके डिवाइस पर बनाई और संग्रहीत होती हैं। कोई भी — डेवलपर्स सहित — आपके संदेश नहीं पढ़ सकता।';

  @override
  String get privacyNetworkHeading => 'नेटवर्क आर्किटेक्चर';

  @override
  String get privacyNetworkBody =>
      'Pulse फ़ेडरेटेड ट्रांसपोर्ट एडाप्टर (Nostr रिले, Session/Oxen सर्विस नोड्स, Firebase Realtime Database, LAN) का उपयोग करता है। ये ट्रांसपोर्ट केवल एन्क्रिप्टेड सिफ़रटेक्स्ट ले जाते हैं। रिले ऑपरेटर आपका IP पता और ट्रैफ़िक वॉल्यूम देख सकते हैं, लेकिन संदेश सामग्री को डिक्रिप्ट नहीं कर सकते।\n\nजब Tor सक्षम है, तो आपका IP पता रिले ऑपरेटरों से भी छिपा रहता है।';

  @override
  String get privacyStunHeading => 'STUN/TURN सर्वर';

  @override
  String get privacyStunBody =>
      'वॉइस और वीडियो कॉल DTLS-SRTP एन्क्रिप्शन के साथ WebRTC का उपयोग करते हैं। STUN सर्वर (पीयर-टू-पीयर कनेक्शन के लिए आपके सार्वजनिक IP की खोज के लिए) और TURN सर्वर (सीधे कनेक्शन विफल होने पर मीडिया रिले करने के लिए) आपका IP पता और कॉल अवधि देख सकते हैं, लेकिन कॉल सामग्री को डिक्रिप्ट नहीं कर सकते।\n\nअधिकतम गोपनीयता के लिए आप सेटिंग्स में अपना TURN सर्वर कॉन्फ़िगर कर सकते हैं।';

  @override
  String get privacyCrashHeading => 'क्रैश रिपोर्टिंग';

  @override
  String get privacyCrashBody =>
      'यदि Sentry क्रैश रिपोर्टिंग सक्षम है (बिल्ड-टाइम SENTRY_DSN के माध्यम से), तो गुमनाम क्रैश रिपोर्ट भेजी जा सकती हैं। इनमें कोई संदेश सामग्री, कोई संपर्क जानकारी और कोई व्यक्तिगत पहचान योग्य जानकारी नहीं होती। DSN हटाकर बिल्ड समय पर क्रैश रिपोर्टिंग अक्षम की जा सकती है।';

  @override
  String get privacyPasswordHeading => 'पासवर्ड और कुंजियाँ';

  @override
  String get privacyPasswordBody =>
      'आपका रिकवरी पासवर्ड Argon2id (मेमोरी-हार्ड KDF) के माध्यम से क्रिप्टोग्राफ़िक कुंजियाँ प्राप्त करने के लिए उपयोग किया जाता है। पासवर्ड कभी कहीं प्रेषित नहीं होता। यदि आप अपना पासवर्ड खो देते हैं, तो आपका खाता पुनर्प्राप्त नहीं किया जा सकता — इसे रीसेट करने के लिए कोई सर्वर नहीं है।';

  @override
  String get privacyFontsHeading => 'फ़ॉन्ट्स';

  @override
  String get privacyFontsBody =>
      'Pulse सभी फ़ॉन्ट्स स्थानीय रूप से बंडल करता है। Google Fonts या किसी बाहरी फ़ॉन्ट सेवा को कोई अनुरोध नहीं किया जाता।';

  @override
  String get privacyThirdPartyHeading => 'तृतीय-पक्ष सेवाएँ';

  @override
  String get privacyThirdPartyBody =>
      'Pulse किसी भी विज्ञापन नेटवर्क, एनालिटिक्स प्रदाता, सोशल मीडिया प्लेटफ़ॉर्म या डेटा ब्रोकर के साथ एकीकृत नहीं होता। एकमात्र नेटवर्क कनेक्शन आपके कॉन्फ़िगर किए गए ट्रांसपोर्ट रिले के लिए हैं।';

  @override
  String get privacyOpenSourceHeading => 'ओपन सोर्स';

  @override
  String get privacyOpenSourceBody =>
      'Pulse ओपन-सोर्स सॉफ़्टवेयर है। इन गोपनीयता दावों को सत्यापित करने के लिए आप पूरा स्रोत कोड ऑडिट कर सकते हैं।';

  @override
  String get privacyContactHeading => 'संपर्क';

  @override
  String get privacyContactBody =>
      'गोपनीयता संबंधी प्रश्नों के लिए, प्रोजेक्ट रिपॉज़िटरी पर एक इश्यू खोलें।';

  @override
  String get privacyLastUpdated => 'अंतिम अपडेट: मार्च 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'सहेजना विफल: $error';
  }

  @override
  String get themeEngineTitle => 'थीम इंजन';

  @override
  String get torBuiltInTitle => 'बिल्ट-इन Tor';

  @override
  String get torConnectedSubtitle =>
      'कनेक्टेड — Nostr 127.0.0.1:9250 के माध्यम से रूट हो रहा है';

  @override
  String torConnectingSubtitle(int pct) {
    return 'कनेक्ट हो रहा है… $pct%';
  }

  @override
  String get torNotRunning =>
      'चल नहीं रहा — पुनः शुरू करने के लिए स्विच टैप करें';

  @override
  String get torDescription =>
      'Nostr को Tor के माध्यम से रूट करता है (सेंसर्ड नेटवर्क के लिए Snowflake)';

  @override
  String get torNetworkDiagnostics => 'नेटवर्क निदान';

  @override
  String get torTransportLabel => 'ट्रांसपोर्ट: ';

  @override
  String get torPtAuto => 'स्वचालित';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'सादा';

  @override
  String get torTimeoutLabel => 'टाइमआउट: ';

  @override
  String get torInfoDescription =>
      'सक्षम होने पर, Nostr WebSocket कनेक्शन Tor (SOCKS5) के माध्यम से रूट होते हैं। Tor Browser 127.0.0.1:9150 पर सुनता है। स्टैंडअलोन tor डेमॉन पोर्ट 9050 का उपयोग करता है। Firebase कनेक्शन प्रभावित नहीं होते।';

  @override
  String get torRouteNostrTitle => 'Nostr को Tor के माध्यम से रूट करें';

  @override
  String get torManagedByBuiltin => 'बिल्ट-इन Tor द्वारा प्रबंधित';

  @override
  String get torActiveRouting =>
      'सक्रिय — Nostr ट्रैफ़िक Tor के माध्यम से रूट हो रहा है';

  @override
  String get torDisabled => 'अक्षम';

  @override
  String get torProxySocks5 => 'Tor प्रॉक्सी (SOCKS5)';

  @override
  String get torProxyHostLabel => 'प्रॉक्सी होस्ट';

  @override
  String get torProxyPortLabel => 'पोर्ट';

  @override
  String get torPortInfo => 'Tor Browser: पोर्ट 9150  •  tor डेमॉन: पोर्ट 9050';

  @override
  String get torForceNostrTitle => 'Tor के माध्यम से संदेश भेजें';

  @override
  String get torForceNostrSubtitle =>
      'सभी Nostr relay कनेक्शन Tor के माध्यम से जाएंगे। धीमा लेकिन relay से आपका IP छुपाता है।';

  @override
  String get torForceNostrDisabled => 'पहले Tor सक्षम करना होगा';

  @override
  String get torForcePulseTitle => 'Pulse relay को Tor के माध्यम से भेजें';

  @override
  String get torForcePulseSubtitle =>
      'सभी Pulse relay कनेक्शन Tor के माध्यम से जाएंगे। धीमा लेकिन सर्वर से आपका IP छुपाता है।';

  @override
  String get torForcePulseDisabled => 'पहले Tor सक्षम करना होगा';

  @override
  String get i2pProxySocks5 => 'I2P प्रॉक्सी (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P डिफ़ॉल्ट रूप से पोर्ट 4447 पर SOCKS5 का उपयोग करता है। किसी भी ट्रांसपोर्ट पर उपयोगकर्ताओं के साथ संवाद करने के लिए I2P आउटप्रॉक्सी (जैसे relay.damus.i2p) के माध्यम से Nostr रिले से कनेक्ट करें। दोनों सक्षम होने पर Tor को प्राथमिकता मिलती है।';

  @override
  String get i2pRouteNostrTitle => 'Nostr को I2P के माध्यम से रूट करें';

  @override
  String get i2pActiveRouting =>
      'सक्रिय — Nostr ट्रैफ़िक I2P के माध्यम से रूट हो रहा है';

  @override
  String get i2pDisabled => 'अक्षम';

  @override
  String get i2pProxyHostLabel => 'प्रॉक्सी होस्ट';

  @override
  String get i2pProxyPortLabel => 'पोर्ट';

  @override
  String get i2pPortInfo => 'I2P राउटर डिफ़ॉल्ट SOCKS5 पोर्ट: 4447';

  @override
  String get customProxySocks5 => 'कस्टम प्रॉक्सी (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker रिले';

  @override
  String get customProxyInfoDescription =>
      'कस्टम प्रॉक्सी ट्रैफ़िक को आपके V2Ray/Xray/Shadowsocks के माध्यम से रूट करता है। CF Worker Cloudflare CDN पर व्यक्तिगत रिले प्रॉक्सी के रूप में कार्य करता है — GFW को *.workers.dev दिखता है, वास्तविक रिले नहीं।';

  @override
  String get customSocks5ProxyTitle => 'कस्टम SOCKS5 प्रॉक्सी';

  @override
  String get customProxyActive =>
      'सक्रिय — ट्रैफ़िक SOCKS5 के माध्यम से रूट हो रहा है';

  @override
  String get customProxyDisabled => 'अक्षम';

  @override
  String get customProxyHostLabel => 'प्रॉक्सी होस्ट';

  @override
  String get customProxyPortLabel => 'पोर्ट';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker डोमेन (वैकल्पिक)';

  @override
  String get customWorkerHelpTitle =>
      'CF Worker रिले कैसे डिप्लॉय करें (मुफ़्त)';

  @override
  String get customWorkerScriptCopied => 'स्क्रिप्ट कॉपी की गई!';

  @override
  String get customWorkerStep1 =>
      '1. dash.cloudflare.com → Workers & Pages पर जाएँ\n2. Worker बनाएँ → यह स्क्रिप्ट पेस्ट करें:\n';

  @override
  String get customWorkerStep2 =>
      '3. डिप्लॉय करें → डोमेन कॉपी करें (जैसे my-relay.user.workers.dev)\n4. ऊपर डोमेन पेस्ट करें → सहेजें\n\nऐप स्वतः कनेक्ट: wss://domain/?r=relay_url\nGFW देखता है: *.workers.dev (CF CDN) से कनेक्शन';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'कनेक्टेड — SOCKS5 127.0.0.1:$port पर';
  }

  @override
  String get psiphonConnecting => 'कनेक्ट हो रहा है…';

  @override
  String get psiphonNotRunning =>
      'चल नहीं रहा — पुनः शुरू करने के लिए स्विच टैप करें';

  @override
  String get psiphonDescription =>
      'तेज़ टनल (~3 सेकंड बूटस्ट्रैप, 2000+ रोटेटिंग VPS)';

  @override
  String get turnCommunityServers => 'सामुदायिक TURN सर्वर';

  @override
  String get turnCustomServer => 'कस्टम TURN सर्वर (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN सर्वर केवल पहले से एन्क्रिप्टेड स्ट्रीम (DTLS-SRTP) को रिले करते हैं। रिले ऑपरेटर आपका IP और ट्रैफ़िक वॉल्यूम देख सकता है, लेकिन कॉल डिक्रिप्ट नहीं कर सकता। TURN केवल तब उपयोग होता है जब सीधा P2P विफल होता है (~15–20% कनेक्शन)।';

  @override
  String get turnFreeLabel => 'मुफ़्त';

  @override
  String get turnServerUrlLabel => 'TURN सर्वर URL';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 या turns:...';

  @override
  String get turnUsernameLabel => 'उपयोगकर्ता नाम';

  @override
  String get turnPasswordLabel => 'पासवर्ड';

  @override
  String get turnOptionalHint => 'वैकल्पिक';

  @override
  String get turnCustomInfo =>
      'अधिकतम नियंत्रण के लिए किसी भी \$5/माह VPS पर coturn स्वयं होस्ट करें। क्रेडेंशियल स्थानीय रूप से संग्रहीत होते हैं।';

  @override
  String get themePickerAppearance => 'दिखावट';

  @override
  String get themePickerAccentColor => 'एक्सेंट रंग';

  @override
  String get themeModeLight => 'लाइट';

  @override
  String get themeModeDark => 'डार्क';

  @override
  String get themeModeSystem => 'सिस्टम';

  @override
  String get themeDynamicPresets => 'प्रीसेट';

  @override
  String get themeDynamicPrimaryColor => 'प्राथमिक रंग';

  @override
  String get themeDynamicBorderRadius => 'बॉर्डर रेडियस';

  @override
  String get themeDynamicFont => 'फ़ॉन्ट';

  @override
  String get themeDynamicAppearance => 'दिखावट';

  @override
  String get themeDynamicUiStyle => 'UI शैली';

  @override
  String get themeDynamicUiStyleDescription =>
      'नियंत्रित करता है कि डायलॉग, स्विच और इंडिकेटर कैसे दिखते हैं।';

  @override
  String get themeDynamicSharp => 'तीखा';

  @override
  String get themeDynamicRound => 'गोल';

  @override
  String get themeDynamicModeDark => 'डार्क';

  @override
  String get themeDynamicModeLight => 'लाइट';

  @override
  String get themeDynamicModeAuto => 'स्वचालित';

  @override
  String get themeDynamicPlatformAuto => 'स्वचालित';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'अमान्य Firebase URL। अपेक्षित https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'अमान्य रिले URL। अपेक्षित wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'अमान्य Pulse सर्वर URL। अपेक्षित https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'सर्वर URL';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'आमंत्रण कोड';

  @override
  String get providerPulseInviteHint => 'आमंत्रण कोड (यदि आवश्यक हो)';

  @override
  String get providerPulseInfo =>
      'स्व-होस्टेड रिले। कुंजियाँ आपके रिकवरी पासवर्ड से प्राप्त होती हैं।';

  @override
  String get providerScreenTitle => 'इनबॉक्स';

  @override
  String get providerSecondaryInboxesHeader => 'द्वितीयक इनबॉक्स';

  @override
  String get providerSecondaryInboxesInfo =>
      'द्वितीयक इनबॉक्स रिडंडेंसी के लिए एक साथ संदेश प्राप्त करते हैं।';

  @override
  String get providerRemoveTooltip => 'हटाएँ';

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
  String get emojiNoRecent => 'कोई हाल की इमोजी नहीं';

  @override
  String get emojiSearchHint => 'इमोजी खोजें...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'चैट करने के लिए टैप करें';

  @override
  String get imageViewerSaveToDownloads => 'Downloads में सहेजें';

  @override
  String imageViewerSavedTo(String path) {
    return '$path में सहेजा गया';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'ठीक है';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsLanguageSubtitle => 'ऐप प्रदर्शन भाषा';

  @override
  String get settingsLanguageSystem => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get onboardingLanguageTitle => 'अपनी भाषा चुनें';

  @override
  String get onboardingLanguageSubtitle =>
      'आप इसे बाद में सेटिंग्स में बदल सकते हैं';

  @override
  String get videoNoteRecord => 'वीडियो संदेश रिकॉर्ड करें';

  @override
  String get videoNoteTapToRecord => 'रिकॉर्ड करने के लिए टैप करें';

  @override
  String get videoNoteTapToStop => 'रोकने के लिए टैप करें';

  @override
  String get videoNoteCameraPermission => 'कैमरा अनुमति अस्वीकृत';

  @override
  String get videoNoteMaxDuration => 'अधिकतम 30 सेकंड';

  @override
  String get videoNoteNotSupported =>
      'इस प्लेटफ़ॉर्म पर वीडियो नोट समर्थित नहीं हैं';

  @override
  String get navChats => 'चैट';

  @override
  String get navUpdates => 'अपडेट';

  @override
  String get navCalls => 'कॉल';

  @override
  String get filterAll => 'सभी';

  @override
  String get filterUnread => 'अपठित';

  @override
  String get filterGroups => 'समूह';

  @override
  String get callsNoRecent => 'कोई हाल का कॉल नहीं';

  @override
  String get callsEmptySubtitle => 'आपका कॉल इतिहास यहां दिखाई देगा';

  @override
  String get appBarEncrypted => 'एंड-टू-एंड एन्क्रिप्टेड';

  @override
  String get newStatus => 'नया स्टेटस';

  @override
  String get newCall => 'नया कॉल';

  @override
  String get joinChannelTitle => 'चैनल से जुड़ें';

  @override
  String get joinChannelDescription => 'चैनल URL';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'चैनल जानकारी प्राप्त हो रही है…';

  @override
  String get joinChannelNotFound => 'इस URL पर कोई चैनल नहीं मिला';

  @override
  String get joinChannelNetworkError => 'सर्वर तक नहीं पहुँच सके';

  @override
  String get joinChannelAlreadyJoined => 'पहले से जुड़े हुए';

  @override
  String get joinChannelButton => 'जुड़ें';

  @override
  String get channelFeedEmpty => 'अभी तक कोई पोस्ट नहीं';

  @override
  String get channelLeave => 'चैनल छोड़ें';

  @override
  String get channelLeaveConfirm =>
      'इस चैनल को छोड़ें? कैश्ड पोस्ट हटा दी जाएँगी।';

  @override
  String get channelInfo => 'चैनल जानकारी';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'संपादित';

  @override
  String get channelLoadMore => 'और लोड करें';

  @override
  String get channelSearchPosts => 'पोस्ट खोजें…';

  @override
  String get channelNoResults => 'कोई मेल खाते पोस्ट नहीं';

  @override
  String get channelUrl => 'चैनल URL';

  @override
  String get channelCreated => 'जुड़े';

  @override
  String channelPostCount(int count) {
    return '$count पोस्ट';
  }

  @override
  String get channelCopyUrl => 'URL कॉपी करें';

  @override
  String get setupNext => 'अगला';

  @override
  String get setupKeyWarning =>
      'आपके लिए एक रिकवरी कुंजी बनाई जाएगी। यह नए डिवाइस पर अपना खाता पुनर्स्थापित करने का एकमात्र तरीका है — कोई सर्वर नहीं, कोई पासवर्ड रीसेट नहीं।';

  @override
  String get setupKeyTitle => 'आपकी रिकवरी कुंजी';

  @override
  String get setupKeySubtitle =>
      'इस कुंजी को लिख लें और सुरक्षित स्थान पर रखें। नए डिवाइस पर अपना खाता पुनर्स्थापित करने के लिए आपको इसकी आवश्यकता होगी।';

  @override
  String get setupKeyCopied => 'कॉपी किया!';

  @override
  String get setupKeyWroteItDown => 'मैंने लिख लिया';

  @override
  String get setupKeyWarnBody =>
      'इस कुंजी को बैकअप के रूप में लिख लें। आप इसे बाद में सेटिंग्स → सुरक्षा में भी देख सकते हैं।';

  @override
  String get setupVerifyTitle => 'रिकवरी कुंजी सत्यापित करें';

  @override
  String get setupVerifySubtitle =>
      'यह पुष्टि करने के लिए कि आपने इसे सही ढंग से सहेजा है, अपनी रिकवरी कुंजी दोबारा दर्ज करें।';

  @override
  String get setupVerifyButton => 'सत्यापित करें';

  @override
  String get setupKeyMismatch =>
      'कुंजी मेल नहीं खाती। जांचें और पुनः प्रयास करें।';

  @override
  String get setupSkipVerify => 'सत्यापन छोड़ें';

  @override
  String get setupSkipVerifyTitle => 'सत्यापन छोड़ें?';

  @override
  String get setupSkipVerifyBody =>
      'यदि आप अपनी रिकवरी कुंजी खो देते हैं, तो आपका खाता पुनर्स्थापित नहीं किया जा सकता। क्या आप वाकई छोड़ना चाहते हैं?';

  @override
  String get setupCreatingAccount => 'खाता बनाया जा रहा है…';

  @override
  String get setupRestoringAccount => 'खाता पुनर्स्थापित किया जा रहा है…';

  @override
  String get restoreKeyInfoBanner =>
      'अपनी रिकवरी कुंजी दर्ज करें — आपका पता (Nostr + Session) स्वचालित रूप से पुनर्स्थापित हो जाएगा। संपर्क और संदेश केवल स्थानीय रूप से संग्रहीत थे।';

  @override
  String get restoreKeyHint => 'रिकवरी कुंजी';

  @override
  String get settingsViewRecoveryKey => 'रिकवरी कुंजी देखें';

  @override
  String get settingsViewRecoveryKeySubtitle => 'अपनी खाता रिकवरी कुंजी दिखाएं';

  @override
  String get settingsRecoveryKeyNotStored =>
      'रिकवरी कुंजी उपलब्ध नहीं है (इस सुविधा से पहले बनाया गया)';

  @override
  String get settingsRecoveryKeyWarning =>
      'इस कुंजी को सुरक्षित रखें। जिसके पास भी यह है वह दूसरे डिवाइस पर आपका खाता पुनर्स्थापित कर सकता है।';

  @override
  String get replaceIdentityTitle => 'मौजूदा पहचान बदलें?';

  @override
  String get replaceIdentityBodyRestore =>
      'इस डिवाइस पर पहले से एक पहचान मौजूद है। पुनर्स्थापना से आपकी वर्तमान Nostr कुंजी और Oxen seed स्थायी रूप से बदल जाएगी। सभी संपर्क आपके वर्तमान पते तक पहुँचने की क्षमता खो देंगे।\n\nइसे पूर्ववत नहीं किया जा सकता।';

  @override
  String get replaceIdentityBodyCreate =>
      'इस डिवाइस पर पहले से एक पहचान मौजूद है। नई बनाने से आपकी वर्तमान Nostr कुंजी और Oxen seed स्थायी रूप से बदल जाएगी। सभी संपर्क आपके वर्तमान पते तक पहुँचने की क्षमता खो देंगे।\n\nइसे पूर्ववत नहीं किया जा सकता।';

  @override
  String get replace => 'बदलें';

  @override
  String get callNoScreenSources => 'कोई स्क्रीन स्रोत उपलब्ध नहीं';

  @override
  String get callScreenShareQuality => 'स्क्रीन शेयर गुणवत्ता';

  @override
  String get callFrameRate => 'फ़्रेम दर';

  @override
  String get callResolution => 'रिज़ॉल्यूशन';

  @override
  String get callAutoResolution => 'ऑटो = मूल स्क्रीन रिज़ॉल्यूशन';

  @override
  String get callStartSharing => 'शेयर शुरू करें';

  @override
  String get callCameraUnavailable =>
      'कैमरा अनुपलब्ध — किसी अन्य ऐप द्वारा उपयोग में हो सकता है';

  @override
  String get themeResetToDefaults => 'डिफ़ॉल्ट पर रीसेट';

  @override
  String get backupSaveToDownloadsTitle => 'बैकअप डाउनलोड में सहेजें?';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'फ़ाइल पिकर उपलब्ध नहीं है। बैकअप यहाँ सहेजा जाएगा:\n$path';
  }

  @override
  String get systemLabel => 'सिस्टम';

  @override
  String get next => 'अगला';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return 'डेवलपर मोड सक्षम करने के लिए $remaining और टैप';
  }

  @override
  String get devModeEnabled => 'डेवलपर मोड सक्षम';

  @override
  String get devTools => 'डेवलपर टूल्स';

  @override
  String get devAdapterDiagnostics => 'एडेप्टर टॉगल और डायग्नोस्टिक्स';

  @override
  String get devEnableAll => 'सभी सक्षम करें';

  @override
  String get devDisableAll => 'सभी अक्षम करें';

  @override
  String get turnUrlValidation =>
      'TURN URL turn: या turns: से शुरू होना चाहिए (अधिकतम 512 अक्षर)';

  @override
  String get callMissedCall => 'मिस्ड कॉल';

  @override
  String get callOutgoingCall => 'आउटगोइंग कॉल';

  @override
  String get callIncomingCall => 'इनकमिंग कॉल';

  @override
  String get mediaMissingData => 'मीडिया डेटा गायब';

  @override
  String get mediaDownloadFailed => 'डाउनलोड विफल';

  @override
  String get mediaDecryptFailed => 'डिक्रिप्ट विफल';

  @override
  String get callEndCallBanner => 'कॉल समाप्त करें';

  @override
  String get meFallback => 'मैं';

  @override
  String get imageSaveToDownloads => 'डाउनलोड में सहेजें';

  @override
  String imageSavedToPath(String path) {
    return '$path में सहेजा गया';
  }

  @override
  String get callScreenShareRequiresPermission =>
      'स्क्रीन शेयर के लिए अनुमति आवश्यक';

  @override
  String get callScreenShareUnavailable => 'स्क्रीन शेयर अनुपलब्ध';

  @override
  String get statusJustNow => 'अभी';

  @override
  String statusMinutesAgo(int minutes) {
    return '$minutesमि पहले';
  }

  @override
  String statusHoursAgo(int hours) {
    return '$hoursघं पहले';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रूट',
      one: '1 रूट',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => 'जोड़ने के लिए तैयार';

  @override
  String groupSelectedCount(int count) {
    return '$count चयनित';
  }

  @override
  String get paste => 'पेस्ट करें';

  @override
  String get sfuAudioOnly => 'केवल ऑडियो';

  @override
  String sfuParticipants(int count) {
    return '$count प्रतिभागी';
  }

  @override
  String get dataUnencryptedBackup => 'अनएन्क्रिप्टेड बैकअप';

  @override
  String get dataUnencryptedBackupBody =>
      'यह फ़ाइल एक अनएन्क्रिप्टेड पहचान बैकअप है और आपकी वर्तमान कुंजियों को ओवरराइट कर देगी। केवल अपने द्वारा बनाई गई फ़ाइलें आयात करें। जारी रखें?';

  @override
  String get dataImportAnyway => 'फिर भी आयात करें';

  @override
  String get securityStorageError =>
      'सुरक्षा भंडारण त्रुटि — ऐप पुनः शुरू करें';

  @override
  String get aboutDevModeActive => 'डेवलपर मोड सक्रिय';

  @override
  String get themeColors => 'रंग';

  @override
  String get themePrimaryAccent => 'प्राथमिक एक्सेंट';

  @override
  String get themeSecondaryAccent => 'द्वितीयक एक्सेंट';

  @override
  String get themeBackground => 'पृष्ठभूमि';

  @override
  String get themeSurface => 'सतह';

  @override
  String get themeChatBubbles => 'चैट बबल';

  @override
  String get themeOutgoingMessage => 'आउटगोइंग संदेश';

  @override
  String get themeIncomingMessage => 'इनकमिंग संदेश';

  @override
  String get themeShape => 'आकार';

  @override
  String get devSectionDeveloper => 'डेवलपर';

  @override
  String get devAdapterChannelsHint =>
      'एडेप्टर चैनल — विशिष्ट ट्रांसपोर्ट का परीक्षण करने के लिए अक्षम करें।';

  @override
  String get devNostrRelays => 'Nostr रिले (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Session नेटवर्क';

  @override
  String get devPulseRelay => 'Pulse स्व-होस्टेड रिले';

  @override
  String get devLanNetwork => 'स्थानीय नेटवर्क (UDP/TCP)';

  @override
  String get devSectionCalls => 'कॉल';

  @override
  String get devForceTurnRelay => 'TURN relay बाध्य करें';

  @override
  String get devForceTurnRelaySubtitle =>
      'P2P अक्षम करें — सभी कॉल केवल TURN सर्वर के माध्यम से';

  @override
  String get devRestartWarning =>
      '⚠ परिवर्तन अगले भेजने/कॉल पर प्रभावी होंगे। इनकमिंग के लिए ऐप पुनः शुरू करें।';

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
  String get pulseUseServerTitle => 'Pulse सर्वर उपयोग करें?';

  @override
  String pulseUseServerBody(String name, String host) {
    return '$name Pulse सर्वर $host का उपयोग करता है। उनके साथ (और उसी सर्वर पर अन्य लोगों के साथ) तेज़ चैट के लिए शामिल हों?';
  }

  @override
  String pulseContactUsesPulse(String name) {
    return '$name Pulse का उपयोग कर रहा है';
  }

  @override
  String pulseJoinForFaster(String host) {
    return 'तेज़ चैट के लिए $host से जुड़ें';
  }

  @override
  String get pulseNotNow => 'अभी नहीं';

  @override
  String get pulseJoin => 'शामिल हों';

  @override
  String get pulseDismiss => 'खारिज करें';

  @override
  String get pulseHide7Days => '7 दिनों के लिए छुपाएं';

  @override
  String get pulseNeverAskAgain => 'फिर से न पूछें';

  @override
  String get groupSearchContactsHint => 'संपर्क खोजें…';

  @override
  String get systemActorYou => 'आप';

  @override
  String get systemActorPeer => 'संपर्क';

  @override
  String systemTtlEnabled(String actor, String duration) {
    return '$actor ने ग़ायब होने वाले संदेश चालू किए: $duration';
  }

  @override
  String systemTtlDisabled(String actor) {
    return '$actor ने ग़ायब होने वाले संदेश बंद किए';
  }

  @override
  String get menuClearChatHistory => 'चैट इतिहास साफ़ करें';

  @override
  String get clearChatTitle => 'चैट इतिहास साफ़ करें?';

  @override
  String get clearChatBody =>
      'इस चैट के सभी संदेश इस डिवाइस से हटा दिए जाएंगे। दूसरा व्यक्ति अपनी प्रति बनाए रखेगा।';

  @override
  String get clearChatAction => 'साफ़ करें';

  @override
  String systemGroupRenamed(String actor, String name) {
    return '$actor ने समूह का नाम बदलकर \"$name\" कर दिया';
  }

  @override
  String systemGroupAvatarChanged(String actor) {
    return '$actor ने समूह की फोटो बदली';
  }

  @override
  String systemGroupMetaChanged(String actor, String name) {
    return '$actor ने समूह का नाम बदलकर \"$name\" किया और फोटो बदली';
  }

  @override
  String get profileInviteLink => 'आमंत्रण लिंक';

  @override
  String get profileInviteLinkSubtitle =>
      'लिंक वाला कोई भी व्यक्ति शामिल हो सकता है';

  @override
  String get profileInviteLinkCopied => 'आमंत्रण लिंक कॉपी किया गया';

  @override
  String get groupInviteLinkTitle => 'समूह में शामिल हों?';

  @override
  String groupInviteLinkBody(String name, int count) {
    return 'आपको \"$name\" में आमंत्रित किया गया है ($count सदस्य)।';
  }

  @override
  String get groupInviteLinkJoin => 'शामिल हों';

  @override
  String get drawerCreateGroup => 'समूह बनाएं';

  @override
  String get drawerJoinGroup => 'समूह में शामिल हों';

  @override
  String get drawerJoinGroupByLinkInvalid =>
      'यह Pulse आमंत्रण लिंक जैसा नहीं लगता';

  @override
  String get groupModeMeshTitle => 'सामान्य';

  @override
  String groupModeMeshSubtitle(int n) {
    return 'सर्वर के बिना, $n लोगों तक';
  }

  @override
  String get groupModeSfuTitle => 'Pulse सर्वर के साथ';

  @override
  String groupModeSfuSubtitle(int n) {
    return 'सर्वर के माध्यम से, $n लोगों तक';
  }

  @override
  String get groupPulseServerHint => 'https://आपका-pulse-सर्वर';

  @override
  String get groupPulseServerClosed => 'बंद सर्वर (आमंत्रण कोड आवश्यक)';

  @override
  String get groupPulseInviteHint => 'आमंत्रण कोड';

  @override
  String groupMeshLimitReached(int n) {
    return 'इस कॉल प्रकार की सीमा $n लोग है';
  }
}
