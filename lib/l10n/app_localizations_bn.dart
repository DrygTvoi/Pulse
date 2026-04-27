// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'বার্তা অনুসন্ধান করুন...';

  @override
  String get search => 'অনুসন্ধান';

  @override
  String get clearSearch => 'অনুসন্ধান মুছুন';

  @override
  String get closeSearch => 'অনুসন্ধান বন্ধ করুন';

  @override
  String get moreOptions => 'আরও বিকল্প';

  @override
  String get back => 'পিছনে';

  @override
  String get cancel => 'বাতিল';

  @override
  String get close => 'বন্ধ';

  @override
  String get confirm => 'নিশ্চিত করুন';

  @override
  String get remove => 'সরান';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get add => 'যোগ করুন';

  @override
  String get copy => 'কপি';

  @override
  String get skip => 'এড়িয়ে যান';

  @override
  String get done => 'সম্পন্ন';

  @override
  String get apply => 'প্রয়োগ করুন';

  @override
  String get export => 'রপ্তানি';

  @override
  String get import => 'আমদানি';

  @override
  String get homeNewGroup => 'নতুন গ্রুপ';

  @override
  String get homeSettings => 'সেটিংস';

  @override
  String get homeSearching => 'বার্তা অনুসন্ধান হচ্ছে...';

  @override
  String get homeNoResults => 'কোনো ফলাফল পাওয়া যায়নি';

  @override
  String get homeNoChatHistory => 'এখনও কোনো চ্যাট ইতিহাস নেই';

  @override
  String homeTransportSwitched(String address) {
    return 'ট্রান্সপোর্ট পরিবর্তিত হয়েছে → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name কল করছে...';
  }

  @override
  String get homeAccept => 'গ্রহণ করুন';

  @override
  String get homeDecline => 'প্রত্যাখ্যান';

  @override
  String get homeLoadEarlier => 'আগের বার্তা লোড করুন';

  @override
  String get homeChats => 'চ্যাট';

  @override
  String get homeSelectConversation => 'একটি কথোপকথন নির্বাচন করুন';

  @override
  String get homeNoChatsYet => 'এখনও কোনো চ্যাট নেই';

  @override
  String get homeAddContactToStart => 'চ্যাট শুরু করতে একটি পরিচিতি যোগ করুন';

  @override
  String get homeNewChat => 'নতুন চ্যাট';

  @override
  String get homeNewChatTooltip => 'নতুন চ্যাট';

  @override
  String get homeIncomingCallTitle => 'ইনকামিং কল';

  @override
  String get homeIncomingGroupCallTitle => 'ইনকামিং গ্রুপ কল';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — গ্রুপ কল আসছে';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return '\"$query\"-এর সাথে কোনো চ্যাট মেলেনি';
  }

  @override
  String get homeSectionChats => 'চ্যাট';

  @override
  String get homeSectionMessages => 'বার্তা';

  @override
  String get homeDbEncryptionUnavailable =>
      'ডাটাবেস এনক্রিপশন অনুপলব্ধ — সম্পূর্ণ সুরক্ষার জন্য SQLCipher ইনস্টল করুন';

  @override
  String get chatFileTooLargeGroup =>
      'গ্রুপ চ্যাটে 512 KB-এর বেশি ফাইল সমর্থিত নয়';

  @override
  String get chatLargeFile => 'বড় ফাইল';

  @override
  String get chatCancel => 'বাতিল';

  @override
  String get chatSend => 'পাঠান';

  @override
  String get chatFileTooLarge => 'ফাইল অত্যন্ত বড় — সর্বোচ্চ আকার 100 MB';

  @override
  String get chatMicDenied => 'মাইক্রোফোন অনুমতি প্রত্যাখ্যাত';

  @override
  String get chatVoiceFailed =>
      'ভয়েস বার্তা সংরক্ষণ করা যায়নি — উপলব্ধ স্টোরেজ পরীক্ষা করুন';

  @override
  String get chatScheduleFuture => 'নির্ধারিত সময় ভবিষ্যতে হতে হবে';

  @override
  String get chatToday => 'আজ';

  @override
  String get chatYesterday => 'গতকাল';

  @override
  String get chatEdited => 'সম্পাদিত';

  @override
  String get chatYou => 'আপনি';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'এই ফাইলটি $size MB। বড় ফাইল পাঠানো কিছু নেটওয়ার্কে ধীর হতে পারে। চালিয়ে যেতে চান?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return '$name-এর নিরাপত্তা কী পরিবর্তিত হয়েছে। যাচাই করতে ট্যাপ করুন।';
  }

  @override
  String chatEncryptionFailed(String name) {
    return '$name-কে বার্তা এনক্রিপ্ট করা যায়নি — বার্তা পাঠানো হয়নি।';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return '$name-এর নিরাপত্তা নম্বর পরিবর্তিত হয়েছে। যাচাই করতে ট্যাপ করুন।';
  }

  @override
  String get chatNoMessagesFound => 'কোনো বার্তা পাওয়া যায়নি';

  @override
  String get chatMessagesE2ee => 'বার্তাগুলি এন্ড-টু-এন্ড এনক্রিপ্টেড';

  @override
  String get chatSayHello => 'হ্যালো বলুন';

  @override
  String get appBarOnline => 'অনলাইন';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'টাইপ করছে';

  @override
  String get appBarSearchMessages => 'বার্তা অনুসন্ধান করুন...';

  @override
  String get appBarMute => 'নিঃশব্দ';

  @override
  String get appBarUnmute => 'শব্দ চালু';

  @override
  String get appBarMedia => 'মিডিয়া';

  @override
  String get appBarDisappearing => 'অদৃশ্য বার্তা';

  @override
  String get appBarDisappearingOn => 'অদৃশ্য: চালু';

  @override
  String get appBarGroupSettings => 'গ্রুপ সেটিংস';

  @override
  String get appBarSearchTooltip => 'বার্তা অনুসন্ধান';

  @override
  String get appBarVoiceCall => 'ভয়েস কল';

  @override
  String get appBarVideoCall => 'ভিডিও কল';

  @override
  String get inputMessage => 'বার্তা...';

  @override
  String get inputAttachFile => 'ফাইল সংযুক্ত করুন';

  @override
  String get inputSendMessage => 'বার্তা পাঠান';

  @override
  String get inputRecordVoice => 'ভয়েস বার্তা রেকর্ড করুন';

  @override
  String get inputSendVoice => 'ভয়েস বার্তা পাঠান';

  @override
  String get inputCancelReply => 'উত্তর বাতিল';

  @override
  String get inputCancelEdit => 'সম্পাদনা বাতিল';

  @override
  String get inputCancelRecording => 'রেকর্ডিং বাতিল';

  @override
  String get inputRecording => 'রেকর্ড হচ্ছে…';

  @override
  String get inputEditingMessage => 'বার্তা সম্পাদনা হচ্ছে';

  @override
  String get inputPhoto => 'ছবি';

  @override
  String get inputVoiceMessage => 'ভয়েস বার্তা';

  @override
  String get inputFile => 'ফাইল';

  @override
  String inputScheduledMessages(int count) {
    return '$countটি নির্ধারিত বার্তা';
  }

  @override
  String get callInitializing => 'কল আরম্ভ হচ্ছে…';

  @override
  String get callConnecting => 'সংযুক্ত হচ্ছে…';

  @override
  String get callConnectingRelay => 'সংযুক্ত হচ্ছে (রিলে)…';

  @override
  String get callSwitchingRelay => 'রিলে মোডে স্যুইচ হচ্ছে…';

  @override
  String get callConnectionFailed => 'সংযোগ ব্যর্থ';

  @override
  String get callReconnecting => 'পুনরায় সংযুক্ত হচ্ছে…';

  @override
  String get callEnded => 'কল শেষ';

  @override
  String get callLive => 'লাইভ';

  @override
  String get callEnd => 'শেষ';

  @override
  String get callEndCall => 'কল শেষ করুন';

  @override
  String get callMute => 'নিঃশব্দ';

  @override
  String get callUnmute => 'শব্দ চালু';

  @override
  String get callSpeaker => 'স্পিকার';

  @override
  String get callCameraOn => 'ক্যামেরা চালু';

  @override
  String get callCameraOff => 'ক্যামেরা বন্ধ';

  @override
  String get callShareScreen => 'স্ক্রিন শেয়ার';

  @override
  String get callStopShare => 'শেয়ার বন্ধ';

  @override
  String callTorBackup(String duration) {
    return 'Tor ব্যাকআপ · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor ব্যাকআপ সক্রিয় — প্রাথমিক পথ অনুপলব্ধ';

  @override
  String get callDirectFailed =>
      'সরাসরি সংযোগ ব্যর্থ — রিলে মোডে স্যুইচ হচ্ছে…';

  @override
  String get callTurnUnreachable =>
      'TURN সার্ভার অনুপলব্ধ। সেটিংস → উন্নত-এ একটি কাস্টম TURN যোগ করুন।';

  @override
  String get callRelayMode => 'রিলে মোড সক্রিয় (সীমাবদ্ধ নেটওয়ার্ক)';

  @override
  String get callStarting => 'কল শুরু হচ্ছে…';

  @override
  String get callConnectingToGroup => 'গ্রুপে সংযুক্ত হচ্ছে…';

  @override
  String get callGroupOpenedInBrowser => 'গ্রুপ কল ব্রাউজারে খোলা হয়েছে';

  @override
  String get callCouldNotOpenBrowser => 'ব্রাউজার খোলা যায়নি';

  @override
  String get callInviteLinkSent =>
      'সমস্ত গ্রুপ সদস্যদের আমন্ত্রণ লিঙ্ক পাঠানো হয়েছে।';

  @override
  String get callOpenLinkManually =>
      'উপরের লিঙ্কটি নিজে খুলুন অথবা পুনরায় চেষ্টা করতে ট্যাপ করুন।';

  @override
  String get callJitsiNotE2ee => 'Jitsi কলগুলি এন্ড-টু-এন্ড এনক্রিপ্টেড নয়';

  @override
  String get callRetryOpenBrowser => 'ব্রাউজার আবার খুলুন';

  @override
  String get callClose => 'বন্ধ';

  @override
  String get callCamOn => 'ক্যাম চালু';

  @override
  String get callCamOff => 'ক্যাম বন্ধ';

  @override
  String get noConnection => 'সংযোগ নেই — বার্তা কিউতে থাকবে';

  @override
  String get connected => 'সংযুক্ত';

  @override
  String get connecting => 'সংযুক্ত হচ্ছে…';

  @override
  String get disconnected => 'সংযোগ বিচ্ছিন্ন';

  @override
  String get offlineBanner => 'সংযোগ নেই — অনলাইনে ফিরলে বার্তা পাঠানো হবে';

  @override
  String get lanModeBanner =>
      'LAN মোড — ইন্টারনেট নেই · শুধুমাত্র স্থানীয় নেটওয়ার্ক';

  @override
  String get probeCheckingNetwork => 'নেটওয়ার্ক সংযোগ পরীক্ষা করা হচ্ছে…';

  @override
  String get probeDiscoveringRelays =>
      'কমিউনিটি ডিরেক্টরির মাধ্যমে রিলে খোঁজা হচ্ছে…';

  @override
  String get probeStartingTor => 'বুটস্ট্র্যাপের জন্য Tor শুরু হচ্ছে…';

  @override
  String get probeFindingRelaysTor =>
      'Tor-এর মাধ্যমে অ্যাক্সেসযোগ্য রিলে খোঁজা হচ্ছে…';

  @override
  String probeNetworkReady(int count) {
    return 'নেটওয়ার্ক প্রস্তুত — $countটি রিলে পাওয়া গেছে';
  }

  @override
  String get probeNoRelaysFound =>
      'কোনো অ্যাক্সেসযোগ্য রিলে পাওয়া যায়নি — বার্তা বিলম্বিত হতে পারে';

  @override
  String get jitsiWarningTitle => 'এন্ড-টু-এন্ড এনক্রিপ্টেড নয়';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet কলগুলি Pulse দ্বারা এনক্রিপ্ট করা হয় না। শুধুমাত্র অসংবেদনশীল কথোপকথনে ব্যবহার করুন।';

  @override
  String get jitsiConfirm => 'তবুও যোগ দিন';

  @override
  String get jitsiGroupWarningTitle => 'এন্ড-টু-এন্ড এনক্রিপ্টেড নয়';

  @override
  String get jitsiGroupWarningBody =>
      'এই কলে অনেক বেশি অংশগ্রহণকারী রয়েছে বিল্ট-ইন এনক্রিপ্টেড মেশের জন্য।\n\nআপনার ব্রাউজারে একটি Jitsi Meet লিঙ্ক খোলা হবে। Jitsi এন্ড-টু-এন্ড এনক্রিপ্টেড নয় — সার্ভার আপনার কল দেখতে পারে।';

  @override
  String get jitsiContinueAnyway => 'তবুও চালিয়ে যান';

  @override
  String get retry => 'পুনরায় চেষ্টা';

  @override
  String get setupCreateAnonymousAccount => 'একটি বেনামী অ্যাকাউন্ট তৈরি করুন';

  @override
  String get setupTapToChangeColor => 'রং পরিবর্তন করতে ট্যাপ করুন';

  @override
  String get setupReqMinLength => 'কমপক্ষে ১৬টি অক্ষর';

  @override
  String get setupReqVariety =>
      '৪টির মধ্যে ৩টি: বড় হাতের, ছোট হাতের, সংখ্যা, চিহ্ন';

  @override
  String get setupReqMatch => 'পাসওয়ার্ড মিলেছে';

  @override
  String get setupYourNickname => 'আপনার ডাকনাম';

  @override
  String get setupRecoveryPassword => 'পুনরুদ্ধার পাসওয়ার্ড (ন্যূনতম ১৬)';

  @override
  String get setupConfirmPassword => 'পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get setupMin16Chars => 'ন্যূনতম ১৬ অক্ষর';

  @override
  String get setupPasswordsDoNotMatch => 'পাসওয়ার্ড মেলেনি';

  @override
  String get setupEntropyWeak => 'দুর্বল';

  @override
  String get setupEntropyOk => 'ঠিক আছে';

  @override
  String get setupEntropyStrong => 'শক্তিশালী';

  @override
  String get setupEntropyWeakNeedsVariety => 'দুর্বল (৩ ধরনের অক্ষর প্রয়োজন)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits বিট)';
  }

  @override
  String get setupPasswordWarning =>
      'এই পাসওয়ার্ডই আপনার অ্যাকাউন্ট পুনরুদ্ধারের একমাত্র উপায়। কোনো সার্ভার নেই — পাসওয়ার্ড রিসেট নেই। মনে রাখুন বা লিখে রাখুন।';

  @override
  String get setupCreateAccount => 'অ্যাকাউন্ট তৈরি করুন';

  @override
  String get setupAlreadyHaveAccount => 'ইতিমধ্যে অ্যাকাউন্ট আছে? ';

  @override
  String get setupRestore => 'পুনরুদ্ধার →';

  @override
  String get restoreTitle => 'অ্যাকাউন্ট পুনরুদ্ধার';

  @override
  String get restoreInfoBanner =>
      'আপনার পুনরুদ্ধার পাসওয়ার্ড দিন — আপনার ঠিকানা (Nostr + Session) স্বয়ংক্রিয়ভাবে পুনরুদ্ধার হবে। পরিচিতি এবং বার্তা শুধুমাত্র স্থানীয়ভাবে সংরক্ষিত ছিল।';

  @override
  String get restoreNewNickname => 'নতুন ডাকনাম (পরে পরিবর্তন করা যাবে)';

  @override
  String get restoreButton => 'অ্যাকাউন্ট পুনরুদ্ধার করুন';

  @override
  String get lockTitle => 'Pulse লক করা আছে';

  @override
  String get lockSubtitle => 'চালিয়ে যেতে আপনার পাসওয়ার্ড দিন';

  @override
  String get lockPasswordHint => 'পাসওয়ার্ড';

  @override
  String get lockUnlock => 'আনলক';

  @override
  String get lockPanicHint =>
      'পাসওয়ার্ড ভুলে গেছেন? সমস্ত ডেটা মুছে ফেলতে আপনার প্যানিক কী দিন।';

  @override
  String get lockTooManyAttempts =>
      'অনেক বেশি চেষ্টা। সমস্ত ডেটা মুছে ফেলা হচ্ছে…';

  @override
  String get lockWrongPassword => 'ভুল পাসওয়ার্ড';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'ভুল পাসওয়ার্ড — $attempts/$max চেষ্টা';
  }

  @override
  String get onboardingSkip => 'এড়িয়ে যান';

  @override
  String get onboardingNext => 'পরবর্তী';

  @override
  String get onboardingGetStarted => 'অ্যাকাউন্ট তৈরি করুন';

  @override
  String get onboardingWelcomeTitle => 'Pulse-এ স্বাগতম';

  @override
  String get onboardingWelcomeBody =>
      'একটি বিকেন্দ্রীভূত, এন্ড-টু-এন্ড এনক্রিপ্টেড মেসেঞ্জার।\n\nকোনো কেন্দ্রীয় সার্ভার নেই। কোনো ডেটা সংগ্রহ নেই। কোনো পিছনের দরজা নেই।\nআপনার কথোপকথন শুধুমাত্র আপনার।';

  @override
  String get onboardingTransportTitle => 'ট্রান্সপোর্ট-অজ্ঞেয়';

  @override
  String get onboardingTransportBody =>
      'Firebase, Nostr, বা একই সাথে উভয় ব্যবহার করুন।\n\nবার্তা স্বয়ংক্রিয়ভাবে নেটওয়ার্কের মধ্য দিয়ে রুট হয়। সেন্সরশিপ প্রতিরোধের জন্য বিল্ট-ইন Tor এবং I2P সাপোর্ট।';

  @override
  String get onboardingSignalTitle => 'Signal + পোস্ট-কোয়ান্টাম';

  @override
  String get onboardingSignalBody =>
      'প্রতিটি বার্তা Signal Protocol (Double Ratchet + X3DH) দিয়ে ফরওয়ার্ড সিক্রেসির জন্য এনক্রিপ্ট করা হয়।\n\nঅতিরিক্তভাবে Kyber-1024 দিয়ে মোড়ানো — একটি NIST-মানক পোস্ট-কোয়ান্টাম অ্যালগরিদম — ভবিষ্যতের কোয়ান্টাম কম্পিউটার থেকে সুরক্ষা।';

  @override
  String get onboardingKeysTitle => 'আপনার কী আপনার নিজের';

  @override
  String get onboardingKeysBody =>
      'আপনার পরিচয় কী কখনো আপনার ডিভাইস ছেড়ে যায় না।\n\nSignal ফিঙ্গারপ্রিন্ট আপনাকে আউট-অফ-ব্যান্ড পরিচিতি যাচাই করতে দেয়। TOFU (Trust On First Use) স্বয়ংক্রিয়ভাবে কী পরিবর্তন শনাক্ত করে।';

  @override
  String get onboardingThemeTitle => 'আপনার চেহারা বেছে নিন';

  @override
  String get onboardingThemeBody =>
      'একটি থিম এবং অ্যাকসেন্ট রং বেছে নিন। সেটিংসে পরে যেকোনো সময় পরিবর্তন করতে পারবেন।';

  @override
  String get contactsNewChat => 'নতুন চ্যাট';

  @override
  String get contactsAddContact => 'পরিচিতি যোগ করুন';

  @override
  String get contactsSearchHint => 'অনুসন্ধান...';

  @override
  String get contactsNewGroup => 'নতুন গ্রুপ';

  @override
  String get contactsNoContactsYet => 'এখনও কোনো পরিচিতি নেই';

  @override
  String get contactsAddHint => 'কারো ঠিকানা যোগ করতে + ট্যাপ করুন';

  @override
  String get contactsNoMatch => 'কোনো পরিচিতি মেলেনি';

  @override
  String get contactsRemoveTitle => 'পরিচিতি সরান';

  @override
  String contactsRemoveMessage(String name) {
    return '$name সরাতে চান?';
  }

  @override
  String get contactsRemove => 'সরান';

  @override
  String contactsCount(int count) {
    return '$countটি পরিচিতি';
  }

  @override
  String get bubbleOpenLink => 'লিঙ্ক খুলুন';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'এই URL ব্রাউজারে খুলবেন?\n\n$url';
  }

  @override
  String get bubbleOpen => 'খুলুন';

  @override
  String get bubbleSecurityWarning => 'নিরাপত্তা সতর্কতা';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" একটি এক্সিকিউটেবল ফাইল। সংরক্ষণ এবং চালানো আপনার ডিভাইসের ক্ষতি করতে পারে। তবুও সংরক্ষণ করবেন?';
  }

  @override
  String get bubbleSaveAnyway => 'তবুও সংরক্ষণ করুন';

  @override
  String bubbleSavedTo(String path) {
    return '$path-এ সংরক্ষিত';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'সংরক্ষণ ব্যর্থ: $error';
  }

  @override
  String get bubbleNotEncrypted => 'এনক্রিপ্ট করা হয়নি';

  @override
  String get bubbleCorruptedImage => '[ক্ষতিগ্রস্ত ছবি]';

  @override
  String get bubbleReplyPhoto => 'ছবি';

  @override
  String get bubbleReplyVoice => 'ভয়েস বার্তা';

  @override
  String get bubbleReplyVideo => 'ভিডিও বার্তা';

  @override
  String bubbleReadBy(String names) {
    return '$names দ্বারা পঠিত';
  }

  @override
  String bubbleReadByCount(int count) {
    return '$count জন পড়েছে';
  }

  @override
  String get chatTileTapToStart => 'চ্যাট শুরু করতে ট্যাপ করুন';

  @override
  String get chatTileMessageSent => 'বার্তা পাঠানো হয়েছে';

  @override
  String get chatTileEncryptedMessage => 'এনক্রিপ্টেড বার্তা';

  @override
  String chatTileYouPrefix(String text) {
    return 'আপনি: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 ভয়েস বার্তা';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 ভয়েস বার্তা ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'এনক্রিপ্টেড বার্তা';

  @override
  String get groupNewGroup => 'নতুন গ্রুপ';

  @override
  String get groupGroupName => 'গ্রুপের নাম';

  @override
  String get groupSelectMembers => 'সদস্য নির্বাচন করুন (ন্যূনতম ২)';

  @override
  String get groupNoContactsYet =>
      'এখনও কোনো পরিচিতি নেই। প্রথমে পরিচিতি যোগ করুন।';

  @override
  String get groupCreate => 'তৈরি করুন';

  @override
  String get groupLabel => 'গ্রুপ';

  @override
  String get profileVerifyIdentity => 'পরিচয় যাচাই';

  @override
  String profileVerifyInstructions(String name) {
    return '$name-এর সাথে ভয়েস কল বা সামনাসামনি এই ফিঙ্গারপ্রিন্ট তুলনা করুন। যদি উভয় ডিভাইসে মান মেলে, \"যাচাইকৃত হিসেবে চিহ্নিত করুন\" ট্যাপ করুন।';
  }

  @override
  String get profileTheirKey => 'তাদের কী';

  @override
  String get profileYourKey => 'আপনার কী';

  @override
  String get profileRemoveVerification => 'যাচাই সরান';

  @override
  String get profileMarkAsVerified => 'যাচাইকৃত হিসেবে চিহ্নিত করুন';

  @override
  String get profileAddressCopied => 'ঠিকানা কপি হয়েছে';

  @override
  String get profileNoContactsToAdd =>
      'যোগ করার মতো কোনো পরিচিতি নেই — সবাই ইতিমধ্যে সদস্য';

  @override
  String get profileAddMembers => 'সদস্য যোগ করুন';

  @override
  String profileAddCount(int count) {
    return 'যোগ করুন ($count)';
  }

  @override
  String get profileRenameGroup => 'গ্রুপের নাম পরিবর্তন';

  @override
  String get profileRename => 'নাম পরিবর্তন';

  @override
  String get profileRemoveMember => 'সদস্য সরাবেন?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'এই গ্রুপ থেকে $name-কে সরাবেন?';
  }

  @override
  String get profileKick => 'বহিষ্কার';

  @override
  String get profileSignalFingerprints => 'Signal ফিঙ্গারপ্রিন্ট';

  @override
  String get profileVerified => 'যাচাইকৃত';

  @override
  String get profileVerify => 'যাচাই';

  @override
  String get profileEdit => 'সম্পাদনা';

  @override
  String get profileNoSession =>
      'এখনও কোনো সেশন স্থাপিত হয়নি — প্রথমে একটি বার্তা পাঠান।';

  @override
  String get profileFingerprintCopied => 'ফিঙ্গারপ্রিন্ট কপি হয়েছে';

  @override
  String profileMemberCount(int count) {
    return '$count জন সদস্য';
  }

  @override
  String get profileVerifySafetyNumber => 'নিরাপত্তা নম্বর যাচাই করুন';

  @override
  String get profileShowContactQr => 'পরিচিতির QR দেখান';

  @override
  String profileContactAddress(String name) {
    return '$name-এর ঠিকানা';
  }

  @override
  String get profileExportChatHistory => 'চ্যাট ইতিহাস রপ্তানি';

  @override
  String profileSavedTo(String path) {
    return '$path-এ সংরক্ষিত';
  }

  @override
  String get profileExportFailed => 'রপ্তানি ব্যর্থ';

  @override
  String get profileClearChatHistory => 'চ্যাট ইতিহাস মুছুন';

  @override
  String get profileDeleteGroup => 'গ্রুপ মুছুন';

  @override
  String get profileDeleteContact => 'পরিচিতি মুছুন';

  @override
  String get profileLeaveGroup => 'গ্রুপ ছাড়ুন';

  @override
  String get profileLeaveGroupBody =>
      'আপনাকে এই গ্রুপ থেকে সরানো হবে এবং এটি আপনার পরিচিতি থেকে মুছে যাবে।';

  @override
  String get groupInviteTitle => 'গ্রুপে আমন্ত্রণ';

  @override
  String groupInviteBody(String from, String group) {
    return '$from আপনাকে \"$group\"-এ যোগ দিতে আমন্ত্রণ জানিয়েছে';
  }

  @override
  String get groupInviteAccept => 'গ্রহণ';

  @override
  String get groupInviteDecline => 'প্রত্যাখ্যান';

  @override
  String get groupMemberLimitTitle => 'অতিরিক্ত অংশগ্রহণকারী';

  @override
  String groupMemberLimitBody(int count) {
    return 'এই গ্রুপে $count জন অংশগ্রহণকারী থাকবে। এনক্রিপ্টেড মেশ কল সর্বোচ্চ ৬ জন সমর্থন করে। বড় গ্রুপে Jitsi-তে ফলব্যাক হবে (E2EE নয়)।';
  }

  @override
  String get groupMemberLimitContinue => 'তবুও যোগ করুন';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name \"$group\"-এ যোগ দিতে অস্বীকার করেছে';
  }

  @override
  String get transferTitle => 'অন্য ডিভাইসে স্থানান্তর';

  @override
  String get transferInfoBox =>
      'আপনার Signal পরিচয় এবং Nostr কী একটি নতুন ডিভাইসে স্থানান্তর করুন।\nচ্যাট সেশন স্থানান্তর হবে না — ফরওয়ার্ড সিক্রেসি সংরক্ষিত থাকে।';

  @override
  String get transferSendFromThis => 'এই ডিভাইস থেকে পাঠান';

  @override
  String get transferSendSubtitle =>
      'এই ডিভাইসে কী আছে। নতুন ডিভাইসের সাথে একটি কোড শেয়ার করুন।';

  @override
  String get transferReceiveOnThis => 'এই ডিভাইসে গ্রহণ করুন';

  @override
  String get transferReceiveSubtitle =>
      'এটি নতুন ডিভাইস। পুরোনো ডিভাইস থেকে কোড দিন।';

  @override
  String get transferChooseMethod => 'স্থানান্তর পদ্ধতি বেছে নিন';

  @override
  String get transferLan => 'LAN (একই নেটওয়ার্ক)';

  @override
  String get transferLanSubtitle =>
      'দ্রুত, সরাসরি। উভয় ডিভাইস একই Wi-Fi-তে থাকতে হবে।';

  @override
  String get transferNostrRelay => 'Nostr রিলে';

  @override
  String get transferNostrRelaySubtitle =>
      'বিদ্যমান Nostr রিলে ব্যবহার করে যেকোনো নেটওয়ার্কে কাজ করে।';

  @override
  String get transferRelayUrl => 'রিলে URL';

  @override
  String get transferEnterCode => 'ট্রান্সফার কোড দিন';

  @override
  String get transferPasteCode => 'এখানে LAN:... বা NOS:... কোড পেস্ট করুন';

  @override
  String get transferConnect => 'সংযুক্ত করুন';

  @override
  String get transferGenerating => 'ট্রান্সফার কোড তৈরি হচ্ছে…';

  @override
  String get transferShareCode => 'এই কোডটি রিসিভারের সাথে শেয়ার করুন:';

  @override
  String get transferCopyCode => 'কোড কপি';

  @override
  String get transferCodeCopied => 'কোড ক্লিপবোর্ডে কপি হয়েছে';

  @override
  String get transferWaitingReceiver =>
      'রিসিভারের সংযোগের জন্য অপেক্ষা করা হচ্ছে…';

  @override
  String get transferConnectingSender => 'সেন্ডারের সাথে সংযুক্ত হচ্ছে…';

  @override
  String get transferVerifyBoth =>
      'উভয় ডিভাইসে এই কোড তুলনা করুন।\nমিললে, স্থানান্তর নিরাপদ।';

  @override
  String get transferComplete => 'স্থানান্তর সম্পন্ন';

  @override
  String get transferKeysImported => 'কী আমদানি হয়েছে';

  @override
  String get transferCompleteSenderBody =>
      'আপনার কী এই ডিভাইসে সক্রিয় থাকবে।\nরিসিভার এখন আপনার পরিচয় ব্যবহার করতে পারবে।';

  @override
  String get transferCompleteReceiverBody =>
      'কী সফলভাবে আমদানি হয়েছে।\nনতুন পরিচয় প্রয়োগ করতে অ্যাপ রিস্টার্ট করুন।';

  @override
  String get transferRestartApp => 'অ্যাপ রিস্টার্ট';

  @override
  String get transferFailed => 'স্থানান্তর ব্যর্থ';

  @override
  String get transferTryAgain => 'আবার চেষ্টা করুন';

  @override
  String get transferEnterRelayFirst => 'প্রথমে একটি রিলে URL দিন';

  @override
  String get transferPasteCodeFromSender =>
      'সেন্ডারের ট্রান্সফার কোড পেস্ট করুন';

  @override
  String get menuReply => 'উত্তর';

  @override
  String get menuForward => 'ফরওয়ার্ড';

  @override
  String get menuReact => 'প্রতিক্রিয়া';

  @override
  String get menuCopy => 'কপি';

  @override
  String get menuEdit => 'সম্পাদনা';

  @override
  String get menuRetry => 'পুনরায় চেষ্টা';

  @override
  String get menuCancelScheduled => 'নির্ধারিত বাতিল';

  @override
  String get menuDelete => 'মুছুন';

  @override
  String get menuForwardTo => 'ফরওয়ার্ড করুন…';

  @override
  String menuForwardedTo(String name) {
    return '$name-কে ফরওয়ার্ড করা হয়েছে';
  }

  @override
  String get menuScheduledMessages => 'নির্ধারিত বার্তা';

  @override
  String get menuNoScheduledMessages => 'কোনো নির্ধারিত বার্তা নেই';

  @override
  String menuSendsOn(String date) {
    return '$date-এ পাঠানো হবে';
  }

  @override
  String get menuDisappearingMessages => 'অদৃশ্য বার্তা';

  @override
  String get menuDisappearingSubtitle =>
      'নির্বাচিত সময়ের পর বার্তা স্বয়ংক্রিয়ভাবে মুছে যায়।';

  @override
  String get menuTtlOff => 'বন্ধ';

  @override
  String get menuTtl1h => '১ ঘণ্টা';

  @override
  String get menuTtl24h => '২৪ ঘণ্টা';

  @override
  String get menuTtl7d => '৭ দিন';

  @override
  String get menuAttachPhoto => 'ছবি';

  @override
  String get menuAttachFile => 'ফাইল';

  @override
  String get menuAttachVideo => 'ভিডিও';

  @override
  String get mediaTitle => 'মিডিয়া';

  @override
  String get mediaFileLabel => 'ফাইল';

  @override
  String mediaPhotosTab(int count) {
    return 'ছবি ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'ফাইল ($count)';
  }

  @override
  String get mediaNoPhotos => 'এখনও কোনো ছবি নেই';

  @override
  String get mediaNoFiles => 'এখনও কোনো ফাইল নেই';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Downloads/$name-এ সংরক্ষিত';
  }

  @override
  String get mediaFailedToSave => 'ফাইল সংরক্ষণ ব্যর্থ';

  @override
  String get statusNewStatus => 'নতুন স্ট্যাটাস';

  @override
  String get statusPublish => 'প্রকাশ';

  @override
  String get statusExpiresIn24h => 'স্ট্যাটাস ২৪ ঘণ্টায় মেয়াদ শেষ হবে';

  @override
  String get statusWhatsOnYourMind => 'কী ভাবছেন?';

  @override
  String get statusPhotoAttached => 'ছবি সংযুক্ত';

  @override
  String get statusAttachPhoto => 'ছবি সংযুক্ত করুন (ঐচ্ছিক)';

  @override
  String get statusEnterText => 'আপনার স্ট্যাটাসের জন্য কিছু লেখা দিন।';

  @override
  String statusPickPhotoFailed(String error) {
    return 'ছবি বাছাই ব্যর্থ: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'প্রকাশ ব্যর্থ: $error';
  }

  @override
  String get panicSetPanicKey => 'প্যানিক কী সেট করুন';

  @override
  String get panicEmergencySelfDestruct => 'জরুরি আত্ম-ধ্বংস';

  @override
  String get panicIrreversible => 'এই ক্রিয়া অপরিবর্তনীয়';

  @override
  String get panicWarningBody =>
      'লক স্ক্রিনে এই কী দিলে সমস্ত ডেটা তাৎক্ষণিক মুছে যাবে — বার্তা, পরিচিতি, কী, পরিচয়। আপনার নিয়মিত পাসওয়ার্ড থেকে ভিন্ন কী ব্যবহার করুন।';

  @override
  String get panicKeyHint => 'প্যানিক কী';

  @override
  String get panicConfirmHint => 'প্যানিক কী নিশ্চিত করুন';

  @override
  String get panicMinChars => 'প্যানিক কী কমপক্ষে ৮ অক্ষরের হতে হবে';

  @override
  String get panicKeysDoNotMatch => 'কী মেলেনি';

  @override
  String get panicSetFailed => 'প্যানিক কী সংরক্ষণ ব্যর্থ — আবার চেষ্টা করুন';

  @override
  String get passwordSetAppPassword => 'অ্যাপ পাসওয়ার্ড সেট করুন';

  @override
  String get passwordProtectsMessages => 'আপনার বার্তা বিশ্রামে সুরক্ষিত রাখে';

  @override
  String get passwordInfoBanner =>
      'প্রতিবার Pulse খুলতে প্রয়োজন। ভুলে গেলে আপনার ডেটা পুনরুদ্ধার করা যাবে না।';

  @override
  String get passwordHint => 'পাসওয়ার্ড';

  @override
  String get passwordConfirmHint => 'পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get passwordSetButton => 'পাসওয়ার্ড সেট করুন';

  @override
  String get passwordSkipForNow => 'আপাতত এড়িয়ে যান';

  @override
  String get passwordMinChars => 'পাসওয়ার্ড কমপক্ষে ৮ অক্ষরের হতে হবে';

  @override
  String get passwordNeedsVariety =>
      'অক্ষর, সংখ্যা এবং বিশেষ চিহ্ন অন্তর্ভুক্ত করতে হবে';

  @override
  String get passwordRequirements =>
      'ন্যূনতম ৮ অক্ষর, অক্ষর, সংখ্যা এবং একটি বিশেষ চিহ্ন সহ';

  @override
  String get passwordsDoNotMatch => 'পাসওয়ার্ড মেলেনি';

  @override
  String get profileCardSaved => 'প্রোফাইল সংরক্ষিত!';

  @override
  String get profileCardE2eeIdentity => 'E2EE পরিচয়';

  @override
  String get profileCardDisplayName => 'প্রদর্শন নাম';

  @override
  String get profileCardDisplayNameHint => 'যেমন রহিম করিম';

  @override
  String get profileCardAbout => 'সম্পর্কে';

  @override
  String get profileCardSaveProfile => 'প্রোফাইল সংরক্ষণ';

  @override
  String get profileCardYourName => 'আপনার নাম';

  @override
  String get profileCardAddressCopied => 'ঠিকানা কপি হয়েছে!';

  @override
  String get profileCardInboxAddress => 'আপনার ইনবক্স ঠিকানা';

  @override
  String get profileCardInboxAddresses => 'আপনার ইনবক্স ঠিকানাসমূহ';

  @override
  String get profileCardShareAllAddresses =>
      'সমস্ত ঠিকানা শেয়ার করুন (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'পরিচিতিদের সাথে শেয়ার করুন যাতে তারা আপনাকে বার্তা পাঠাতে পারে।';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'সমস্ত $countটি ঠিকানা একটি লিঙ্ক হিসেবে কপি হয়েছে!';
  }

  @override
  String get settingsMyProfile => 'আমার প্রোফাইল';

  @override
  String get settingsYourInboxAddress => 'আপনার ইনবক্স ঠিকানা';

  @override
  String get settingsMyQrCode => 'পরিচিতি শেয়ার করুন';

  @override
  String get settingsMyQrSubtitle =>
      'আপনার ঠিকানার জন্য QR কোড ও আমন্ত্রণ লিঙ্ক';

  @override
  String get settingsShareMyAddress => 'আমার ঠিকানা শেয়ার করুন';

  @override
  String get settingsNoAddressYet =>
      'এখনও কোনো ঠিকানা নেই — প্রথমে সেটিংস সংরক্ষণ করুন';

  @override
  String get settingsInviteLink => 'আমন্ত্রণ লিঙ্ক';

  @override
  String get settingsRawAddress => 'কাঁচা ঠিকানা';

  @override
  String get settingsCopyLink => 'লিঙ্ক কপি';

  @override
  String get settingsCopyAddress => 'ঠিকানা কপি';

  @override
  String get settingsInviteLinkCopied => 'আমন্ত্রণ লিঙ্ক কপি হয়েছে';

  @override
  String get settingsAppearance => 'চেহারা';

  @override
  String get settingsThemeEngine => 'থিম ইঞ্জিন';

  @override
  String get settingsThemeEngineSubtitle => 'রং এবং ফন্ট কাস্টমাইজ করুন';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle => 'E2EE কী নিরাপদে সংরক্ষিত';

  @override
  String get settingsActive => 'সক্রিয়';

  @override
  String get settingsIdentityBackup => 'পরিচয় ব্যাকআপ';

  @override
  String get settingsIdentityBackupSubtitle =>
      'আপনার Signal পরিচয় রপ্তানি বা আমদানি করুন';

  @override
  String get settingsIdentityBackupBody =>
      'আপনার Signal পরিচয় কী একটি ব্যাকআপ কোডে রপ্তানি করুন, বা বিদ্যমান কোড থেকে পুনরুদ্ধার করুন।';

  @override
  String get settingsTransferDevice => 'অন্য ডিভাইসে স্থানান্তর';

  @override
  String get settingsTransferDeviceSubtitle =>
      'LAN বা Nostr রিলে-র মাধ্যমে পরিচয় স্থানান্তর';

  @override
  String get settingsExportIdentity => 'পরিচয় রপ্তানি';

  @override
  String get settingsExportIdentityBody =>
      'এই ব্যাকআপ কোড কপি করে নিরাপদে রাখুন:';

  @override
  String get settingsSaveFile => 'ফাইল সংরক্ষণ';

  @override
  String get settingsImportIdentity => 'পরিচয় আমদানি';

  @override
  String get settingsImportIdentityBody =>
      'নিচে আপনার ব্যাকআপ কোড পেস্ট করুন। এটি আপনার বর্তমান পরিচয় ওভাররাইট করবে।';

  @override
  String get settingsPasteBackupCode => 'এখানে ব্যাকআপ কোড পেস্ট করুন…';

  @override
  String get settingsIdentityImported =>
      'পরিচয় + পরিচিতি আমদানি হয়েছে! প্রয়োগ করতে অ্যাপ রিস্টার্ট করুন।';

  @override
  String get settingsSecurity => 'নিরাপত্তা';

  @override
  String get settingsAppPassword => 'অ্যাপ পাসওয়ার্ড';

  @override
  String get settingsPasswordEnabled =>
      'সক্রিয় — প্রতিবার খোলার সময় প্রয়োজন';

  @override
  String get settingsPasswordDisabled =>
      'নিষ্ক্রিয় — পাসওয়ার্ড ছাড়া অ্যাপ খুলবে';

  @override
  String get settingsChangePassword => 'পাসওয়ার্ড পরিবর্তন';

  @override
  String get settingsChangePasswordSubtitle =>
      'আপনার অ্যাপ লক পাসওয়ার্ড আপডেট করুন';

  @override
  String get settingsSetPanicKey => 'প্যানিক কী সেট করুন';

  @override
  String get settingsChangePanicKey => 'প্যানিক কী পরিবর্তন';

  @override
  String get settingsPanicKeySetSubtitle => 'জরুরি মোছার কী আপডেট করুন';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'একটি কী যা তাৎক্ষণিক সমস্ত ডেটা মুছে দেয়';

  @override
  String get settingsRemovePanicKey => 'প্যানিক কী সরান';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'জরুরি আত্ম-ধ্বংস নিষ্ক্রিয় করুন';

  @override
  String get settingsRemovePanicKeyBody =>
      'জরুরি আত্ম-ধ্বংস নিষ্ক্রিয় হবে। যেকোনো সময় পুনরায় সক্রিয় করতে পারবেন।';

  @override
  String get settingsDisableAppPassword => 'অ্যাপ পাসওয়ার্ড নিষ্ক্রিয় করুন';

  @override
  String get settingsEnterCurrentPassword =>
      'নিশ্চিত করতে আপনার বর্তমান পাসওয়ার্ড দিন';

  @override
  String get settingsCurrentPassword => 'বর্তমান পাসওয়ার্ড';

  @override
  String get settingsIncorrectPassword => 'ভুল পাসওয়ার্ড';

  @override
  String get settingsPasswordUpdated => 'পাসওয়ার্ড আপডেট হয়েছে';

  @override
  String get settingsChangePasswordProceed =>
      'এগিয়ে যেতে আপনার বর্তমান পাসওয়ার্ড দিন';

  @override
  String get settingsData => 'ডেটা';

  @override
  String get settingsBackupMessages => 'বার্তা ব্যাকআপ';

  @override
  String get settingsBackupMessagesSubtitle =>
      'এনক্রিপ্টেড বার্তা ইতিহাস একটি ফাইলে রপ্তানি করুন';

  @override
  String get settingsRestoreMessages => 'বার্তা পুনরুদ্ধার';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'একটি ব্যাকআপ ফাইল থেকে বার্তা আমদানি করুন';

  @override
  String get settingsExportKeys => 'কী রপ্তানি';

  @override
  String get settingsExportKeysSubtitle =>
      'পরিচয় কী একটি এনক্রিপ্টেড ফাইলে সংরক্ষণ করুন';

  @override
  String get settingsImportKeys => 'কী আমদানি';

  @override
  String get settingsImportKeysSubtitle =>
      'রপ্তানি করা ফাইল থেকে পরিচয় কী পুনরুদ্ধার করুন';

  @override
  String get settingsBackupPassword => 'ব্যাকআপ পাসওয়ার্ড';

  @override
  String get settingsPasswordCannotBeEmpty => 'পাসওয়ার্ড খালি রাখা যাবে না';

  @override
  String get settingsPasswordMin4Chars =>
      'পাসওয়ার্ড কমপক্ষে ৪ অক্ষরের হতে হবে';

  @override
  String get settingsCallsTurn => 'কল ও TURN';

  @override
  String get settingsLocalNetwork => 'স্থানীয় নেটওয়ার্ক';

  @override
  String get settingsCensorshipResistance => 'সেন্সরশিপ প্রতিরোধ';

  @override
  String get settingsNetwork => 'নেটওয়ার্ক';

  @override
  String get settingsProxyTunnels => 'প্রক্সি ও টানেল';

  @override
  String get settingsTurnServers => 'TURN সার্ভার';

  @override
  String get settingsProviderTitle => 'প্রদানকারী';

  @override
  String get settingsLanFallback => 'LAN ফলব্যাক';

  @override
  String get settingsLanFallbackSubtitle =>
      'ইন্টারনেট অনুপলব্ধ হলে স্থানীয় নেটওয়ার্কে উপস্থিতি সম্প্রচার এবং বার্তা সরবরাহ করুন। অবিশ্বস্ত নেটওয়ার্কে (পাবলিক Wi-Fi) নিষ্ক্রিয় করুন।';

  @override
  String get settingsBgDelivery => 'ব্যাকগ্রাউন্ড ডেলিভারি';

  @override
  String get settingsBgDeliverySubtitle =>
      'অ্যাপ মিনিমাইজ থাকলেও বার্তা গ্রহণ চালু রাখুন। একটি স্থায়ী বিজ্ঞপ্তি দেখায়।';

  @override
  String get settingsYourInboxProvider => 'আপনার ইনবক্স প্রদানকারী';

  @override
  String get settingsConnectionDetails => 'সংযোগের বিবরণ';

  @override
  String get settingsSaveAndConnect => 'সংরক্ষণ ও সংযুক্ত করুন';

  @override
  String get settingsSecondaryInboxes => 'সেকেন্ডারি ইনবক্স';

  @override
  String get settingsAddSecondaryInbox => 'সেকেন্ডারি ইনবক্স যোগ করুন';

  @override
  String get settingsAdvanced => 'উন্নত';

  @override
  String get settingsDiscover => 'আবিষ্কার';

  @override
  String get settingsAbout => 'সম্পর্কে';

  @override
  String get settingsPrivacyPolicy => 'গোপনীয়তা নীতি';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Pulse কীভাবে আপনার ডেটা সুরক্ষিত করে';

  @override
  String get settingsCrashReporting => 'ক্র্যাশ রিপোর্টিং';

  @override
  String get settingsCrashReportingSubtitle =>
      'Pulse উন্নত করতে বেনামী ক্র্যাশ রিপোর্ট পাঠান। কোনো বার্তা বিষয়বস্তু বা পরিচিতি কখনো পাঠানো হয় না।';

  @override
  String get settingsCrashReportingEnabled =>
      'ক্র্যাশ রিপোর্টিং সক্রিয় — প্রয়োগ করতে অ্যাপ রিস্টার্ট করুন';

  @override
  String get settingsCrashReportingDisabled =>
      'ক্র্যাশ রিপোর্টিং নিষ্ক্রিয় — প্রয়োগ করতে অ্যাপ রিস্টার্ট করুন';

  @override
  String get settingsSensitiveOperation => 'সংবেদনশীল অপারেশন';

  @override
  String get settingsSensitiveOperationBody =>
      'এই কীগুলি আপনার পরিচয়। এই ফাইলটি যে কারো কাছে থাকলে তারা আপনার ছদ্মবেশ ধারণ করতে পারে। নিরাপদে সংরক্ষণ করুন এবং স্থানান্তরের পর মুছে ফেলুন।';

  @override
  String get settingsIUnderstandContinue => 'আমি বুঝেছি, চালিয়ে যান';

  @override
  String get settingsReplaceIdentity => 'পরিচয় প্রতিস্থাপন?';

  @override
  String get settingsReplaceIdentityBody =>
      'এটি আপনার বর্তমান পরিচয় কী ওভাররাইট করবে। আপনার বিদ্যমান Signal সেশন অবৈধ হয়ে যাবে এবং পরিচিতিদের পুনরায় এনক্রিপশন স্থাপন করতে হবে। অ্যাপ রিস্টার্ট করতে হবে।';

  @override
  String get settingsReplaceKeys => 'কী প্রতিস্থাপন';

  @override
  String get settingsKeysImported => 'কী আমদানি হয়েছে';

  @override
  String settingsKeysImportedBody(int count) {
    return '$countটি কী সফলভাবে আমদানি হয়েছে। নতুন পরিচয়ে পুনঃআরম্ভ করতে অ্যাপ রিস্টার্ট করুন।';
  }

  @override
  String get settingsRestartNow => 'এখনই রিস্টার্ট';

  @override
  String get settingsLater => 'পরে';

  @override
  String get profileGroupLabel => 'গ্রুপ';

  @override
  String get profileAddButton => 'যোগ করুন';

  @override
  String get profileKickButton => 'বহিষ্কার';

  @override
  String get dataSectionTitle => 'ডেটা';

  @override
  String get dataBackupMessages => 'বার্তা ব্যাকআপ';

  @override
  String get dataBackupPasswordSubtitle =>
      'আপনার বার্তা ব্যাকআপ এনক্রিপ্ট করতে একটি পাসওয়ার্ড বেছে নিন।';

  @override
  String get dataBackupConfirmLabel => 'ব্যাকআপ তৈরি করুন';

  @override
  String get dataCreatingBackup => 'ব্যাকআপ তৈরি হচ্ছে';

  @override
  String get dataBackupPreparing => 'প্রস্তুত হচ্ছে...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'বার্তা $done/$total রপ্তানি হচ্ছে...';
  }

  @override
  String get dataBackupSavingFile => 'ফাইল সংরক্ষণ হচ্ছে...';

  @override
  String get dataSaveMessageBackupDialog => 'বার্তা ব্যাকআপ সংরক্ষণ করুন';

  @override
  String dataBackupSaved(int count, String path) {
    return 'ব্যাকআপ সংরক্ষিত ($count বার্তা)\n$path';
  }

  @override
  String get dataBackupFailed => 'ব্যাকআপ ব্যর্থ — কোনো ডেটা রপ্তানি হয়নি';

  @override
  String dataBackupFailedError(String error) {
    return 'ব্যাকআপ ব্যর্থ: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'বার্তা ব্যাকআপ নির্বাচন করুন';

  @override
  String get dataInvalidBackupFile => 'অবৈধ ব্যাকআপ ফাইল (অত্যন্ত ছোট)';

  @override
  String get dataNotValidBackupFile => 'বৈধ Pulse ব্যাকআপ ফাইল নয়';

  @override
  String get dataRestoreMessages => 'বার্তা পুনরুদ্ধার';

  @override
  String get dataRestorePasswordSubtitle =>
      'এই ব্যাকআপ তৈরি করতে ব্যবহৃত পাসওয়ার্ড দিন।';

  @override
  String get dataRestoreConfirmLabel => 'পুনরুদ্ধার';

  @override
  String get dataRestoringMessages => 'বার্তা পুনরুদ্ধার হচ্ছে';

  @override
  String get dataRestoreDecrypting => 'ডিক্রিপ্ট হচ্ছে...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'বার্তা $done/$total আমদানি হচ্ছে...';
  }

  @override
  String get dataRestoreFailed =>
      'পুনরুদ্ধার ব্যর্থ — ভুল পাসওয়ার্ড বা ক্ষতিগ্রস্ত ফাইল';

  @override
  String dataRestoreSuccess(int count) {
    return '$countটি নতুন বার্তা পুনরুদ্ধার হয়েছে';
  }

  @override
  String get dataRestoreNothingNew =>
      'আমদানির জন্য কোনো নতুন বার্তা নেই (সবই ইতিমধ্যে আছে)';

  @override
  String dataRestoreFailedError(String error) {
    return 'পুনরুদ্ধার ব্যর্থ: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'কী এক্সপোর্ট নির্বাচন করুন';

  @override
  String get dataNotValidKeyFile => 'বৈধ Pulse কী এক্সপোর্ট ফাইল নয়';

  @override
  String get dataExportKeys => 'কী রপ্তানি';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'আপনার কী এক্সপোর্ট এনক্রিপ্ট করতে একটি পাসওয়ার্ড বেছে নিন।';

  @override
  String get dataExportKeysConfirmLabel => 'রপ্তানি';

  @override
  String get dataExportingKeys => 'কী রপ্তানি হচ্ছে';

  @override
  String get dataExportingKeysStatus => 'পরিচয় কী এনক্রিপ্ট হচ্ছে...';

  @override
  String get dataSaveKeyExportDialog => 'কী এক্সপোর্ট সংরক্ষণ করুন';

  @override
  String dataKeysExportedTo(String path) {
    return 'কী রপ্তানি হয়েছে:\n$path';
  }

  @override
  String get dataExportFailed => 'রপ্তানি ব্যর্থ — কোনো কী পাওয়া যায়নি';

  @override
  String dataExportFailedError(String error) {
    return 'রপ্তানি ব্যর্থ: $error';
  }

  @override
  String get dataImportKeys => 'কী আমদানি';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'এই কী এক্সপোর্ট এনক্রিপ্ট করতে ব্যবহৃত পাসওয়ার্ড দিন।';

  @override
  String get dataImportKeysConfirmLabel => 'আমদানি';

  @override
  String get dataImportingKeys => 'কী আমদানি হচ্ছে';

  @override
  String get dataImportingKeysStatus => 'পরিচয় কী ডিক্রিপ্ট হচ্ছে...';

  @override
  String get dataImportFailed =>
      'আমদানি ব্যর্থ — ভুল পাসওয়ার্ড বা ক্ষতিগ্রস্ত ফাইল';

  @override
  String dataImportFailedError(String error) {
    return 'আমদানি ব্যর্থ: $error';
  }

  @override
  String get securitySectionTitle => 'নিরাপত্তা';

  @override
  String get securityIncorrectPassword => 'ভুল পাসওয়ার্ড';

  @override
  String get securityPasswordUpdated => 'পাসওয়ার্ড আপডেট হয়েছে';

  @override
  String get appearanceSectionTitle => 'চেহারা';

  @override
  String appearanceExportFailed(String error) {
    return 'রপ্তানি ব্যর্থ: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return '$path-এ সংরক্ষিত';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'সংরক্ষণ ব্যর্থ: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'আমদানি ব্যর্থ: $error';
  }

  @override
  String get aboutSectionTitle => 'সম্পর্কে';

  @override
  String get providerPublicKey => 'পাবলিক কী';

  @override
  String get providerRelay => 'রিলে';

  @override
  String get providerAutoConfigured =>
      'আপনার পুনরুদ্ধার পাসওয়ার্ড থেকে স্বয়ংক্রিয়ভাবে কনফিগার করা হয়েছে। রিলে স্বয়ংক্রিয়ভাবে আবিষ্কৃত।';

  @override
  String get providerKeyStoredLocally =>
      'আপনার কী স্থানীয়ভাবে সিকিউর স্টোরেজে সংরক্ষিত — কোনো সার্ভারে কখনো পাঠানো হয় না।';

  @override
  String get providerSessionInfo =>
      'Session Network — পেঁয়াজ-রুটেড E2EE। আপনার Session ID স্বয়ংক্রিয়ভাবে তৈরি হয় এবং নিরাপদে সংরক্ষিত হয়। নোডগুলো বিল্ট-ইন সিড নোড থেকে স্বয়ংক্রিয়ভাবে আবিষ্কৃত হয়।';

  @override
  String get providerAdvanced => 'উন্নত';

  @override
  String get providerSaveAndConnect => 'সংরক্ষণ ও সংযুক্ত করুন';

  @override
  String get providerAddSecondaryInbox => 'সেকেন্ডারি ইনবক্স যোগ করুন';

  @override
  String get providerSecondaryInboxes => 'সেকেন্ডারি ইনবক্স';

  @override
  String get providerYourInboxProvider => 'আপনার ইনবক্স প্রদানকারী';

  @override
  String get providerConnectionDetails => 'সংযোগের বিবরণ';

  @override
  String get addContactTitle => 'পরিচিতি যোগ করুন';

  @override
  String get addContactInviteLinkLabel => 'আমন্ত্রণ লিঙ্ক বা ঠিকানা';

  @override
  String get addContactTapToPaste => 'আমন্ত্রণ লিঙ্ক পেস্ট করতে ট্যাপ করুন';

  @override
  String get addContactPasteTooltip => 'ক্লিপবোর্ড থেকে পেস্ট করুন';

  @override
  String get addContactAddressDetected => 'পরিচিতির ঠিকানা শনাক্ত হয়েছে';

  @override
  String addContactRoutesDetected(int count) {
    return '$countটি রুট শনাক্ত — SmartRouter দ্রুততম বেছে নেয়';
  }

  @override
  String get addContactFetchingProfile => 'প্রোফাইল আনা হচ্ছে…';

  @override
  String addContactProfileFound(String name) {
    return 'পাওয়া গেছে: $name';
  }

  @override
  String get addContactNoProfileFound => 'কোনো প্রোফাইল পাওয়া যায়নি';

  @override
  String get addContactDisplayNameLabel => 'প্রদর্শন নাম';

  @override
  String get addContactDisplayNameHint => 'আপনি তাদের কী ডাকতে চান?';

  @override
  String get addContactAddManually => 'নিজে ঠিকানা যোগ করুন';

  @override
  String get addContactButton => 'পরিচিতি যোগ করুন';

  @override
  String get networkDiagnosticsTitle => 'নেটওয়ার্ক ডায়াগনস্টিকস';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr রিলে';

  @override
  String get networkDiagnosticsDirect => 'সরাসরি';

  @override
  String get networkDiagnosticsTorOnly => 'শুধু Tor';

  @override
  String get networkDiagnosticsBest => 'সেরা';

  @override
  String get networkDiagnosticsNone => 'নেই';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'অবস্থা';

  @override
  String get networkDiagnosticsConnected => 'সংযুক্ত';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'সংযুক্ত হচ্ছে $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'বন্ধ';

  @override
  String get networkDiagnosticsTransport => 'ট্রান্সপোর্ট';

  @override
  String get networkDiagnosticsInfrastructure => 'অবকাঠামো';

  @override
  String get networkDiagnosticsSessionNodes => 'Session নোড';

  @override
  String get networkDiagnosticsTurnServers => 'TURN সার্ভার';

  @override
  String get networkDiagnosticsLastProbe => 'শেষ প্রোব';

  @override
  String get networkDiagnosticsRunning => 'চলছে...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'ডায়াগনস্টিকস চালান';

  @override
  String get networkDiagnosticsForceReprobe => 'সম্পূর্ণ পুনঃপরীক্ষা';

  @override
  String get networkDiagnosticsJustNow => 'এইমাত্র';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes মিনিট আগে';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours ঘণ্টা আগে';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days দিন আগে';
  }

  @override
  String get homeNoEch => 'ECH নেই';

  @override
  String get homeNoEchTooltip =>
      'uTLS প্রক্সি অনুপলব্ধ — ECH নিষ্ক্রিয়।\nTLS ফিঙ্গারপ্রিন্ট DPI-তে দৃশ্যমান।';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'সংরক্ষিত ও $provider-এ সংযুক্ত';
  }

  @override
  String get settingsTorFailedToStart => 'বিল্ট-ইন Tor শুরু করা যায়নি';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon শুরু করা যায়নি';

  @override
  String get verifyTitle => 'নিরাপত্তা নম্বর যাচাই';

  @override
  String get verifyIdentityVerified => 'পরিচয় যাচাইকৃত';

  @override
  String get verifyNotYetVerified => 'এখনও যাচাই হয়নি';

  @override
  String verifyVerifiedDescription(String name) {
    return 'আপনি $name-এর নিরাপত্তা নম্বর যাচাই করেছেন।';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return '$name-এর সাথে ব্যক্তিগতভাবে বা বিশ্বস্ত চ্যানেলে এই নম্বরগুলি তুলনা করুন।';
  }

  @override
  String get verifyExplanation =>
      'প্রতিটি কথোপকথনের একটি অনন্য নিরাপত্তা নম্বর আছে। যদি আপনারা দুজনই উভয় ডিভাইসে একই নম্বর দেখেন, আপনার সংযোগ এন্ড-টু-এন্ড যাচাইকৃত।';

  @override
  String verifyContactKey(String name) {
    return '$name-এর কী';
  }

  @override
  String get verifyYourKey => 'আপনার কী';

  @override
  String get verifyRemoveVerification => 'যাচাই সরান';

  @override
  String get verifyMarkAsVerified => 'যাচাইকৃত হিসেবে চিহ্নিত করুন';

  @override
  String verifyAfterReinstall(String name) {
    return '$name অ্যাপ পুনরায় ইনস্টল করলে নিরাপত্তা নম্বর পরিবর্তিত হবে এবং যাচাই স্বয়ংক্রিয়ভাবে সরানো হবে।';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'শুধুমাত্র $name-এর সাথে ভয়েস কল বা সামনাসামনি নম্বর তুলনা করার পরে যাচাইকৃত হিসেবে চিহ্নিত করুন।';
  }

  @override
  String get verifyNoSession =>
      'এখনও কোনো এনক্রিপশন সেশন স্থাপিত হয়নি। নিরাপত্তা নম্বর তৈরি করতে প্রথমে একটি বার্তা পাঠান।';

  @override
  String get verifyNoKeyAvailable => 'কোনো কী উপলব্ধ নেই';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label ফিঙ্গারপ্রিন্ট কপি হয়েছে';
  }

  @override
  String get providerDatabaseUrlLabel => 'ডাটাবেস URL';

  @override
  String get providerOptionalHint => 'ঐচ্ছিক';

  @override
  String get providerWebApiKeyLabel => 'Web API কী';

  @override
  String get providerOptionalForPublicDb => 'পাবলিক DB-র জন্য ঐচ্ছিক';

  @override
  String get providerRelayUrlLabel => 'রিলে URL';

  @override
  String get providerPrivateKeyLabel => 'প্রাইভেট কী';

  @override
  String get providerPrivateKeyNsecLabel => 'প্রাইভেট কী (nsec)';

  @override
  String get providerStorageNodeLabel => 'স্টোরেজ নোড URL (ঐচ্ছিক)';

  @override
  String get providerStorageNodeHint => 'বিল্ট-ইন সিড নোডের জন্য খালি রাখুন';

  @override
  String get transferInvalidCodeFormat =>
      'অচেনা কোড ফরম্যাট — LAN: বা NOS: দিয়ে শুরু হতে হবে';

  @override
  String get profileCardFingerprintCopied => 'ফিঙ্গারপ্রিন্ট কপি হয়েছে';

  @override
  String get profileCardAboutHint => 'গোপনীয়তা প্রথম 🔒';

  @override
  String get profileCardSaveButton => 'প্রোফাইল সংরক্ষণ';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'এনক্রিপ্টেড বার্তা, পরিচিতি এবং অবতার একটি ফাইলে রপ্তানি করুন';

  @override
  String get callVideo => 'ভিডিও';

  @override
  String get callAudio => 'অডিও';

  @override
  String bubbleDeliveredTo(String names) {
    return '$names-কে ডেলিভারি হয়েছে';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return '$count জনকে ডেলিভারি হয়েছে';
  }

  @override
  String get groupStatusDialogTitle => 'বার্তার তথ্য';

  @override
  String get groupStatusRead => 'পড়েছে';

  @override
  String get groupStatusDelivered => 'ডেলিভারি হয়েছে';

  @override
  String get groupStatusPending => 'অপেক্ষমাণ';

  @override
  String get groupStatusNoData => 'এখনও কোনো ডেলিভারি তথ্য নেই';

  @override
  String get profileTransferAdmin => 'অ্যাডমিন করুন';

  @override
  String profileTransferAdminConfirm(String name) {
    return '$name-কে নতুন অ্যাডমিন করবেন?';
  }

  @override
  String get profileTransferAdminBody =>
      'আপনি অ্যাডমিন সুবিধা হারাবেন। এটি পূর্বাবস্থায় ফেরানো যায় না।';

  @override
  String profileTransferAdminDone(String name) {
    return '$name এখন অ্যাডমিন';
  }

  @override
  String get profileAdminBadge => 'অ্যাডমিন';

  @override
  String get privacyPolicyTitle => 'গোপনীয়তা নীতি';

  @override
  String get privacyOverviewHeading => 'সারসংক্ষেপ';

  @override
  String get privacyOverviewBody =>
      'Pulse একটি সার্ভারবিহীন, এন্ড-টু-এন্ড এনক্রিপ্টেড মেসেঞ্জার। আপনার গোপনীয়তা শুধু একটি বৈশিষ্ট্য নয় — এটি স্থাপত্য। কোনো Pulse সার্ভার নেই। কোনো অ্যাকাউন্ট কোথাও সংরক্ষিত নয়। ডেভেলপারদের কাছে কোনো ডেটা সংগ্রহ, প্রেরণ বা সংরক্ষণ করা হয় না।';

  @override
  String get privacyDataCollectionHeading => 'ডেটা সংগ্রহ';

  @override
  String get privacyDataCollectionBody =>
      'Pulse শূন্য ব্যক্তিগত ডেটা সংগ্রহ করে। বিশেষভাবে:\n\n- কোনো ইমেল, ফোন নম্বর বা আসল নাম প্রয়োজন নেই\n- কোনো অ্যানালিটিক্স, ট্র্যাকিং বা টেলিমেট্রি নেই\n- কোনো বিজ্ঞাপন শনাক্তকারী নেই\n- কোনো পরিচিতি তালিকা অ্যাক্সেস নেই\n- কোনো ক্লাউড ব্যাকআপ নেই (বার্তা শুধুমাত্র আপনার ডিভাইসে থাকে)\n- কোনো Pulse সার্ভারে কোনো মেটাডেটা পাঠানো হয় না (কোনো সার্ভার নেই)';

  @override
  String get privacyEncryptionHeading => 'এনক্রিপশন';

  @override
  String get privacyEncryptionBody =>
      'সমস্ত বার্তা Signal Protocol (X3DH কী সমঝোতা সহ Double Ratchet) ব্যবহার করে এনক্রিপ্ট করা হয়। এনক্রিপশন কী শুধুমাত্র আপনার ডিভাইসে তৈরি এবং সংরক্ষিত। কেউ — ডেভেলপার সহ — আপনার বার্তা পড়তে পারে না।';

  @override
  String get privacyNetworkHeading => 'নেটওয়ার্ক স্থাপত্য';

  @override
  String get privacyNetworkBody =>
      'Pulse ফেডারেটেড ট্রান্সপোর্ট অ্যাডাপ্টার ব্যবহার করে (Nostr রিলে, Session/Oxen সার্ভিস নোড, Firebase Realtime Database, LAN)। এই ট্রান্সপোর্ট শুধুমাত্র এনক্রিপ্টেড সাইফারটেক্সট বহন করে। রিলে অপারেটর আপনার IP ঠিকানা এবং ট্রাফিক পরিমাণ দেখতে পারে, কিন্তু বার্তা বিষয়বস্তু ডিক্রিপ্ট করতে পারে না।\n\nTor সক্রিয় থাকলে, আপনার IP ঠিকানা রিলে অপারেটর থেকেও গোপন থাকে।';

  @override
  String get privacyStunHeading => 'STUN/TURN সার্ভার';

  @override
  String get privacyStunBody =>
      'ভয়েস এবং ভিডিও কল DTLS-SRTP এনক্রিপশন সহ WebRTC ব্যবহার করে। STUN সার্ভার (পিয়ার-টু-পিয়ার সংযোগের জন্য আপনার পাবলিক IP আবিষ্কার করতে) এবং TURN সার্ভার (সরাসরি সংযোগ ব্যর্থ হলে মিডিয়া রিলে করতে) আপনার IP ঠিকানা এবং কল সময়কাল দেখতে পারে, কিন্তু কল বিষয়বস্তু ডিক্রিপ্ট করতে পারে না।\n\nসর্বোচ্চ গোপনীয়তার জন্য সেটিংসে আপনার নিজের TURN সার্ভার কনফিগার করতে পারেন।';

  @override
  String get privacyCrashHeading => 'ক্র্যাশ রিপোর্টিং';

  @override
  String get privacyCrashBody =>
      'Sentry ক্র্যাশ রিপোর্টিং সক্রিয় থাকলে (বিল্ড-টাইম SENTRY_DSN এর মাধ্যমে), বেনামী ক্র্যাশ রিপোর্ট পাঠানো হতে পারে। এতে কোনো বার্তা বিষয়বস্তু, পরিচিতি তথ্য বা ব্যক্তিগত শনাক্তযোগ্য তথ্য থাকে না। DSN বাদ দিয়ে বিল্ড-টাইমে ক্র্যাশ রিপোর্টিং নিষ্ক্রিয় করা যায়।';

  @override
  String get privacyPasswordHeading => 'পাসওয়ার্ড ও কী';

  @override
  String get privacyPasswordBody =>
      'আপনার পুনরুদ্ধার পাসওয়ার্ড Argon2id (মেমরি-হার্ড KDF) এর মাধ্যমে ক্রিপ্টোগ্রাফিক কী তৈরি করতে ব্যবহৃত হয়। পাসওয়ার্ড কোথাও প্রেরিত হয় না। পাসওয়ার্ড হারালে আপনার অ্যাকাউন্ট পুনরুদ্ধার করা যাবে না — রিসেট করার মতো কোনো সার্ভার নেই।';

  @override
  String get privacyFontsHeading => 'ফন্ট';

  @override
  String get privacyFontsBody =>
      'Pulse সমস্ত ফন্ট স্থানীয়ভাবে বান্ডেল করে। Google Fonts বা কোনো বাহ্যিক ফন্ট পরিষেবায় কোনো অনুরোধ করা হয় না।';

  @override
  String get privacyThirdPartyHeading => 'তৃতীয় পক্ষের পরিষেবা';

  @override
  String get privacyThirdPartyBody =>
      'Pulse কোনো বিজ্ঞাপন নেটওয়ার্ক, অ্যানালিটিক্স প্রদানকারী, সোশ্যাল মিডিয়া প্ল্যাটফর্ম বা ডেটা ব্রোকারের সাথে সংযুক্ত নয়। শুধুমাত্র আপনার কনফিগার করা ট্রান্সপোর্ট রিলেতেই নেটওয়ার্ক সংযোগ হয়।';

  @override
  String get privacyOpenSourceHeading => 'ওপেন সোর্স';

  @override
  String get privacyOpenSourceBody =>
      'Pulse ওপেন-সোর্স সফটওয়্যার। এই গোপনীয়তা দাবিগুলি যাচাই করতে আপনি সম্পূর্ণ সোর্স কোড অডিট করতে পারেন।';

  @override
  String get privacyContactHeading => 'যোগাযোগ';

  @override
  String get privacyContactBody =>
      'গোপনীয়তা-সম্পর্কিত প্রশ্নের জন্য, প্রজেক্ট রিপোজিটরিতে একটি ইস্যু খুলুন।';

  @override
  String get privacyLastUpdated => 'শেষ আপডেট: মার্চ ২০২৬';

  @override
  String imageSaveFailed(Object error) {
    return 'সংরক্ষণ ব্যর্থ: $error';
  }

  @override
  String get themeEngineTitle => 'থিম ইঞ্জিন';

  @override
  String get torBuiltInTitle => 'বিল্ট-ইন Tor';

  @override
  String get torConnectedSubtitle =>
      'সংযুক্ত — Nostr 127.0.0.1:9250 এর মাধ্যমে রুট হচ্ছে';

  @override
  String torConnectingSubtitle(int pct) {
    return 'সংযুক্ত হচ্ছে… $pct%';
  }

  @override
  String get torNotRunning => 'চলছে না — পুনরায় চালু করতে সুইচ ট্যাপ করুন';

  @override
  String get torDescription =>
      'Nostr-কে Tor-এর মাধ্যমে রুট করে (সেন্সরড নেটওয়ার্কের জন্য Snowflake)';

  @override
  String get torNetworkDiagnostics => 'নেটওয়ার্ক ডায়াগনস্টিকস';

  @override
  String get torTransportLabel => 'ট্রান্সপোর্ট: ';

  @override
  String get torPtAuto => 'স্বয়ংক্রিয়';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'সাধারণ';

  @override
  String get torTimeoutLabel => 'টাইমআউট: ';

  @override
  String get torInfoDescription =>
      'সক্রিয় থাকলে, Nostr WebSocket সংযোগ Tor (SOCKS5) এর মাধ্যমে রুট হয়। Tor Browser 127.0.0.1:9150 তে শোনে। স্ট্যান্ডঅ্যালোন tor ডেমন পোর্ট 9050 ব্যবহার করে। Firebase সংযোগ প্রভাবিত হয় না।';

  @override
  String get torRouteNostrTitle => 'Nostr-কে Tor-এর মাধ্যমে রুট করুন';

  @override
  String get torManagedByBuiltin => 'বিল্ট-ইন Tor দ্বারা পরিচালিত';

  @override
  String get torActiveRouting =>
      'সক্রিয় — Nostr ট্রাফিক Tor-এর মাধ্যমে রুট হচ্ছে';

  @override
  String get torDisabled => 'নিষ্ক্রিয়';

  @override
  String get torProxySocks5 => 'Tor প্রক্সি (SOCKS5)';

  @override
  String get torProxyHostLabel => 'প্রক্সি হোস্ট';

  @override
  String get torProxyPortLabel => 'পোর্ট';

  @override
  String get torPortInfo => 'Tor Browser: পোর্ট 9150  •  tor ডেমন: পোর্ট 9050';

  @override
  String get torForceNostrTitle => 'Tor এর মাধ্যমে বার্তা পাঠান';

  @override
  String get torForceNostrSubtitle =>
      'সমস্ত Nostr relay সংযোগ Tor এর মাধ্যমে যাবে। ধীর কিন্তু relay থেকে আপনার IP লুকায়।';

  @override
  String get torForceNostrDisabled => 'প্রথমে Tor সক্রিয় করতে হবে';

  @override
  String get torForcePulseTitle => 'Pulse relay Tor এর মাধ্যমে পাঠান';

  @override
  String get torForcePulseSubtitle =>
      'সমস্ত Pulse relay সংযোগ Tor এর মাধ্যমে যাবে। ধীর কিন্তু সার্ভার থেকে আপনার IP লুকায়।';

  @override
  String get torForcePulseDisabled => 'প্রথমে Tor সক্রিয় করতে হবে';

  @override
  String get i2pProxySocks5 => 'I2P প্রক্সি (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P ডিফল্টভাবে পোর্ট 4447-এ SOCKS5 ব্যবহার করে। I2P আউটপ্রক্সির মাধ্যমে Nostr রিলেতে সংযুক্ত হন (যেমন relay.damus.i2p) যেকোনো ট্রান্সপোর্টের ব্যবহারকারীদের সাথে যোগাযোগ করতে। উভয় সক্রিয় থাকলে Tor অগ্রাধিকার পায়।';

  @override
  String get i2pRouteNostrTitle => 'I2P-এর মাধ্যমে Nostr রুট করুন';

  @override
  String get i2pActiveRouting =>
      'সক্রিয় — Nostr ট্রাফিক I2P-এর মাধ্যমে রুট হচ্ছে';

  @override
  String get i2pDisabled => 'নিষ্ক্রিয়';

  @override
  String get i2pProxyHostLabel => 'প্রক্সি হোস্ট';

  @override
  String get i2pProxyPortLabel => 'পোর্ট';

  @override
  String get i2pPortInfo => 'I2P Router ডিফল্ট SOCKS5 পোর্ট: 4447';

  @override
  String get customProxySocks5 => 'কাস্টম প্রক্সি (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker রিলে';

  @override
  String get customProxyInfoDescription =>
      'কাস্টম প্রক্সি আপনার V2Ray/Xray/Shadowsocks এর মাধ্যমে ট্রাফিক রুট করে। CF Worker Cloudflare CDN-এ ব্যক্তিগত রিলে প্রক্সি হিসেবে কাজ করে — GFW দেখে *.workers.dev, আসল রিলে নয়।';

  @override
  String get customSocks5ProxyTitle => 'কাস্টম SOCKS5 প্রক্সি';

  @override
  String get customProxyActive =>
      'সক্রিয় — ট্রাফিক SOCKS5 এর মাধ্যমে রুট হচ্ছে';

  @override
  String get customProxyDisabled => 'নিষ্ক্রিয়';

  @override
  String get customProxyHostLabel => 'প্রক্সি হোস্ট';

  @override
  String get customProxyPortLabel => 'পোর্ট';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker ডোমেইন (ঐচ্ছিক)';

  @override
  String get customWorkerHelpTitle =>
      'কীভাবে CF Worker রিলে ডিপ্লয় করবেন (বিনামূল্যে)';

  @override
  String get customWorkerScriptCopied => 'স্ক্রিপ্ট কপি হয়েছে!';

  @override
  String get customWorkerStep1 =>
      '1. dash.cloudflare.com → Workers & Pages এ যান\n2. Create Worker → এই স্ক্রিপ্ট পেস্ট করুন:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → ডোমেইন কপি করুন (যেমন my-relay.user.workers.dev)\n4. উপরে ডোমেইন পেস্ট করুন → সংরক্ষণ\n\nঅ্যাপ স্বয়ংক্রিয় সংযুক্ত হয়: wss://domain/?r=relay_url\nGFW দেখে: *.workers.dev (CF CDN) এ সংযোগ';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'সংযুক্ত — 127.0.0.1:$port-এ SOCKS5';
  }

  @override
  String get psiphonConnecting => 'সংযুক্ত হচ্ছে…';

  @override
  String get psiphonNotRunning => 'চলছে না — পুনরায় চালু করতে সুইচ ট্যাপ করুন';

  @override
  String get psiphonDescription =>
      'দ্রুত টানেল (~৩ সেকেন্ড বুটস্ট্র্যাপ, ২০০০+ ঘূর্ণায়মান VPS)';

  @override
  String get turnCommunityServers => 'কমিউনিটি TURN সার্ভার';

  @override
  String get turnCustomServer => 'কাস্টম TURN সার্ভার (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN সার্ভার শুধুমাত্র ইতিমধ্যে-এনক্রিপ্টেড স্ট্রিম (DTLS-SRTP) রিলে করে। রিলে অপারেটর আপনার IP এবং ট্রাফিক পরিমাণ দেখে, কিন্তু কল ডিক্রিপ্ট করতে পারে না। TURN শুধুমাত্র তখনই ব্যবহৃত হয় যখন সরাসরি P2P ব্যর্থ হয় (~১৫–20% সংযোগ)।';

  @override
  String get turnFreeLabel => 'বিনামূল্যে';

  @override
  String get turnServerUrlLabel => 'TURN সার্ভার URL';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 বা turns:...';

  @override
  String get turnUsernameLabel => 'ব্যবহারকারীর নাম';

  @override
  String get turnPasswordLabel => 'পাসওয়ার্ড';

  @override
  String get turnOptionalHint => 'ঐচ্ছিক';

  @override
  String get turnCustomInfo =>
      'সর্বোচ্চ নিয়ন্ত্রণের জন্য যেকোনো \$5/মাস VPS-এ coturn সেলফ-হোস্ট করুন। শংসাপত্র স্থানীয়ভাবে সংরক্ষিত।';

  @override
  String get themePickerAppearance => 'চেহারা';

  @override
  String get themePickerAccentColor => 'অ্যাকসেন্ট রং';

  @override
  String get themeModeLight => 'লাইট';

  @override
  String get themeModeDark => 'ডার্ক';

  @override
  String get themeModeSystem => 'সিস্টেম';

  @override
  String get themeDynamicPresets => 'প্রিসেট';

  @override
  String get themeDynamicPrimaryColor => 'প্রাইমারি রং';

  @override
  String get themeDynamicBorderRadius => 'বর্ডার ব্যাসার্ধ';

  @override
  String get themeDynamicFont => 'ফন্ট';

  @override
  String get themeDynamicAppearance => 'চেহারা';

  @override
  String get themeDynamicUiStyle => 'UI স্টাইল';

  @override
  String get themeDynamicUiStyleDescription =>
      'ডায়ালগ, সুইচ এবং ইন্ডিকেটর কীভাবে দেখায় তা নিয়ন্ত্রণ করে।';

  @override
  String get themeDynamicSharp => 'তীক্ষ্ণ';

  @override
  String get themeDynamicRound => 'গোল';

  @override
  String get themeDynamicModeDark => 'ডার্ক';

  @override
  String get themeDynamicModeLight => 'লাইট';

  @override
  String get themeDynamicModeAuto => 'স্বয়ংক্রিয়';

  @override
  String get themeDynamicPlatformAuto => 'স্বয়ংক্রিয়';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'অবৈধ Firebase URL। https://project.firebaseio.com প্রত্যাশিত';

  @override
  String get providerErrorInvalidRelayUrl =>
      'অবৈধ রিলে URL। wss://relay.example.com প্রত্যাশিত';

  @override
  String get providerErrorInvalidPulseUrl =>
      'অবৈধ Pulse সার্ভার URL। https://server:port প্রত্যাশিত';

  @override
  String get providerPulseServerUrlLabel => 'সার্ভার URL';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'আমন্ত্রণ কোড';

  @override
  String get providerPulseInviteHint => 'আমন্ত্রণ কোড (প্রয়োজন হলে)';

  @override
  String get providerPulseInfo =>
      'সেলফ-হোস্টেড রিলে। কী আপনার পুনরুদ্ধার পাসওয়ার্ড থেকে তৈরি।';

  @override
  String get providerScreenTitle => 'ইনবক্স';

  @override
  String get providerSecondaryInboxesHeader => 'সেকেন্ডারি ইনবক্স';

  @override
  String get providerSecondaryInboxesInfo =>
      'সেকেন্ডারি ইনবক্স রিডান্ডেন্সির জন্য একসাথে বার্তা গ্রহণ করে।';

  @override
  String get providerRemoveTooltip => 'সরান';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... বা hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... বা hex প্রাইভেট কী';

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
  String get emojiNoRecent => 'সাম্প্রতিক ইমোজি নেই';

  @override
  String get emojiSearchHint => 'ইমোজি অনুসন্ধান...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'চ্যাট করতে ট্যাপ করুন';

  @override
  String get imageViewerSaveToDownloads => 'Downloads-এ সংরক্ষণ';

  @override
  String imageViewerSavedTo(String path) {
    return '$path-এ সংরক্ষিত';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'ঠিক আছে';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'ভাষা';

  @override
  String get settingsLanguageSubtitle => 'অ্যাপের প্রদর্শন ভাষা';

  @override
  String get settingsLanguageSystem => 'সিস্টেম ডিফল্ট';

  @override
  String get onboardingLanguageTitle => 'আপনার ভাষা বেছে নিন';

  @override
  String get onboardingLanguageSubtitle => 'পরে সেটিংসে পরিবর্তন করতে পারবেন';

  @override
  String get videoNoteRecord => 'ভিডিও বার্তা রেকর্ড করুন';

  @override
  String get videoNoteTapToRecord => 'রেকর্ড করতে ট্যাপ করুন';

  @override
  String get videoNoteTapToStop => 'থামাতে ট্যাপ করুন';

  @override
  String get videoNoteCameraPermission => 'ক্যামেরার অনুমতি অস্বীকৃত';

  @override
  String get videoNoteMaxDuration => 'সর্বোচ্চ ৩০ সেকেন্ড';

  @override
  String get videoNoteNotSupported => 'এই প্ল্যাটফর্মে ভিডিও নোট সমর্থিত নয়';

  @override
  String get navChats => 'চ্যাট';

  @override
  String get navUpdates => 'আপডেট';

  @override
  String get navCalls => 'কল';

  @override
  String get filterAll => 'সব';

  @override
  String get filterUnread => 'অপঠিত';

  @override
  String get filterGroups => 'গ্রুপ';

  @override
  String get callsNoRecent => 'সাম্প্রতিক কল নেই';

  @override
  String get callsEmptySubtitle => 'আপনার কল ইতিহাস এখানে দেখা যাবে';

  @override
  String get appBarEncrypted => 'এন্ড-টু-এন্ড এনক্রিপ্টেড';

  @override
  String get newStatus => 'নতুন স্ট্যাটাস';

  @override
  String get newCall => 'নতুন কল';

  @override
  String get joinChannelTitle => 'চ্যানেলে যোগ দিন';

  @override
  String get joinChannelDescription => 'চ্যানেল URL';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'চ্যানেলের তথ্য আনা হচ্ছে…';

  @override
  String get joinChannelNotFound => 'এই URL-এ কোনো চ্যানেল পাওয়া যায়নি';

  @override
  String get joinChannelNetworkError => 'সার্ভারে পৌঁছানো যায়নি';

  @override
  String get joinChannelAlreadyJoined => 'ইতিমধ্যে যোগদান করেছেন';

  @override
  String get joinChannelButton => 'যোগ দিন';

  @override
  String get channelFeedEmpty => 'এখনো কোনো পোস্ট নেই';

  @override
  String get channelLeave => 'চ্যানেল ছাড়ুন';

  @override
  String get channelLeaveConfirm =>
      'এই চ্যানেল ছাড়বেন? ক্যাশ করা পোস্ট মুছে ফেলা হবে।';

  @override
  String get channelInfo => 'চ্যানেল তথ্য';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'সম্পাদিত';

  @override
  String get channelLoadMore => 'আরো লোড করুন';

  @override
  String get channelSearchPosts => 'পোস্ট খুঁজুন…';

  @override
  String get channelNoResults => 'কোনো মিলে যাওয়া পোস্ট নেই';

  @override
  String get channelUrl => 'চ্যানেল URL';

  @override
  String get channelCreated => 'যোগদান';

  @override
  String channelPostCount(int count) {
    return '$count পোস্ট';
  }

  @override
  String get channelCopyUrl => 'URL কপি করুন';

  @override
  String get setupNext => 'পরবর্তী';

  @override
  String get setupKeyWarning =>
      'আপনার জন্য একটি রিকভারি কী তৈরি করা হবে। এটি নতুন ডিভাইসে আপনার অ্যাকাউন্ট পুনরুদ্ধারের একমাত্র উপায় — কোনো সার্ভার নেই, কোনো পাসওয়ার্ড রিসেট নেই।';

  @override
  String get setupKeyTitle => 'আপনার রিকভারি কী';

  @override
  String get setupKeySubtitle =>
      'এই কীটি লিখে রাখুন এবং নিরাপদ জায়গায় সংরক্ষণ করুন। নতুন ডিভাইসে আপনার অ্যাকাউন্ট পুনরুদ্ধার করতে এটি প্রয়োজন হবে।';

  @override
  String get setupKeyCopied => 'কপি হয়েছে!';

  @override
  String get setupKeyWroteItDown => 'আমি লিখে রেখেছি';

  @override
  String get setupKeyWarnBody =>
      'ব্যাকআপ হিসেবে এই কীটি লিখে রাখুন। আপনি পরে সেটিংস → সিকিউরিটিতেও দেখতে পারবেন।';

  @override
  String get setupVerifyTitle => 'রিকভারি কী যাচাই করুন';

  @override
  String get setupVerifySubtitle =>
      'আপনি সঠিকভাবে সংরক্ষণ করেছেন তা নিশ্চিত করতে আপনার রিকভারি কী পুনরায় লিখুন।';

  @override
  String get setupVerifyButton => 'যাচাই করুন';

  @override
  String get setupKeyMismatch =>
      'কী মিলছে না। পরীক্ষা করুন এবং আবার চেষ্টা করুন।';

  @override
  String get setupSkipVerify => 'যাচাই এড়িয়ে যান';

  @override
  String get setupSkipVerifyTitle => 'যাচাই এড়িয়ে যাবেন?';

  @override
  String get setupSkipVerifyBody =>
      'আপনি যদি আপনার রিকভারি কী হারান, তাহলে আপনার অ্যাকাউন্ট পুনরুদ্ধার করা যাবে না। আপনি কি এড়িয়ে যেতে চান?';

  @override
  String get setupCreatingAccount => 'অ্যাকাউন্ট তৈরি হচ্ছে…';

  @override
  String get setupRestoringAccount => 'অ্যাকাউন্ট পুনরুদ্ধার হচ্ছে…';

  @override
  String get restoreKeyInfoBanner =>
      'আপনার রিকভারি কী লিখুন — আপনার ঠিকানা (Nostr + Session) স্বয়ংক্রিয়ভাবে পুনরুদ্ধার হবে। পরিচিতি এবং বার্তা শুধুমাত্র স্থানীয়ভাবে সংরক্ষিত ছিল।';

  @override
  String get restoreKeyHint => 'রিকভারি কী';

  @override
  String get settingsViewRecoveryKey => 'রিকভারি কী দেখুন';

  @override
  String get settingsViewRecoveryKeySubtitle =>
      'আপনার অ্যাকাউন্ট রিকভারি কী দেখান';

  @override
  String get settingsRecoveryKeyNotStored =>
      'রিকভারি কী উপলব্ধ নেই (এই ফিচারের আগে তৈরি)';

  @override
  String get settingsRecoveryKeyWarning =>
      'এই কীটি নিরাপদ রাখুন। যার কাছে এটি আছে সে অন্য ডিভাইসে আপনার অ্যাকাউন্ট পুনরুদ্ধার করতে পারে।';

  @override
  String get replaceIdentityTitle => 'বিদ্যমান পরিচয় প্রতিস্থাপন করবেন?';

  @override
  String get replaceIdentityBodyRestore =>
      'এই ডিভাইসে ইতিমধ্যে একটি পরিচয় আছে। পুনরুদ্ধার করলে আপনার বর্তমান Nostr কী এবং Oxen seed স্থায়ীভাবে প্রতিস্থাপিত হবে। সব পরিচিতি আপনার বর্তমান ঠিকানায় যোগাযোগ করার ক্ষমতা হারাবে।\n\nএটি পূর্বাবস্থায় ফেরানো যাবে না।';

  @override
  String get replaceIdentityBodyCreate =>
      'এই ডিভাইসে ইতিমধ্যে একটি পরিচয় আছে। নতুন একটি তৈরি করলে আপনার বর্তমান Nostr কী এবং Oxen seed স্থায়ীভাবে প্রতিস্থাপিত হবে। সব পরিচিতি আপনার বর্তমান ঠিকানায় যোগাযোগ করার ক্ষমতা হারাবে।\n\nএটি পূর্বাবস্থায় ফেরানো যাবে না।';

  @override
  String get replace => 'প্রতিস্থাপন';

  @override
  String get callNoScreenSources => 'কোনো স্ক্রিন উৎস উপলব্ধ নেই';

  @override
  String get callScreenShareQuality => 'স্ক্রিন শেয়ার গুণমান';

  @override
  String get callFrameRate => 'ফ্রেম রেট';

  @override
  String get callResolution => 'রেজোলিউশন';

  @override
  String get callAutoResolution => 'স্বয়ংক্রিয় = নেটিভ স্ক্রিন রেজোলিউশন';

  @override
  String get callStartSharing => 'শেয়ার শুরু করুন';

  @override
  String get callCameraUnavailable =>
      'ক্যামেরা অনুপলব্ধ — অন্য অ্যাপে ব্যবহৃত হতে পারে';

  @override
  String get themeResetToDefaults => 'ডিফল্টে রিসেট';

  @override
  String get backupSaveToDownloadsTitle => 'ডাউনলোডে ব্যাকআপ সংরক্ষণ করবেন?';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'ফাইল পিকার উপলব্ধ নেই। ব্যাকআপ সংরক্ষিত হবে:\n$path';
  }

  @override
  String get systemLabel => 'সিস্টেম';

  @override
  String get next => 'পরবর্তী';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return 'ডেভেলপার মোড সক্রিয় করতে আরো $remaining ট্যাপ';
  }

  @override
  String get devModeEnabled => 'ডেভেলপার মোড সক্রিয় করা হয়েছে';

  @override
  String get devTools => 'ডেভেলপার টুলস';

  @override
  String get devAdapterDiagnostics => 'অ্যাডাপ্টার টগল ও ডায়াগনস্টিক';

  @override
  String get devEnableAll => 'সব সক্রিয় করুন';

  @override
  String get devDisableAll => 'সব নিষ্ক্রিয় করুন';

  @override
  String get turnUrlValidation =>
      'TURN URL অবশ্যই turn: বা turns: দিয়ে শুরু হতে হবে (সর্বোচ্চ 512 অক্ষর)';

  @override
  String get callMissedCall => 'মিসড কল';

  @override
  String get callOutgoingCall => 'আউটগোয়িং কল';

  @override
  String get callIncomingCall => 'ইনকামিং কল';

  @override
  String get mediaMissingData => 'মিডিয়া ডেটা অনুপস্থিত';

  @override
  String get mediaDownloadFailed => 'ডাউনলোড ব্যর্থ';

  @override
  String get mediaDecryptFailed => 'ডিক্রিপ্ট ব্যর্থ';

  @override
  String get callEndCallBanner => 'কল শেষ করুন';

  @override
  String get meFallback => 'আমি';

  @override
  String get imageSaveToDownloads => 'ডাউনলোডে সংরক্ষণ করুন';

  @override
  String imageSavedToPath(String path) {
    return '$path-এ সংরক্ষিত';
  }

  @override
  String get callScreenShareRequiresPermission =>
      'স্ক্রিন শেয়ারের জন্য অনুমতি প্রয়োজন';

  @override
  String get callScreenShareUnavailable => 'স্ক্রিন শেয়ার অনুপলব্ধ';

  @override
  String get statusJustNow => 'এইমাত্র';

  @override
  String statusMinutesAgo(int minutes) {
    return '$minutesমি আগে';
  }

  @override
  String statusHoursAgo(int hours) {
    return '$hoursঘ আগে';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি রুট',
      one: '1টি রুট',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => 'যোগ করতে প্রস্তুত';

  @override
  String groupSelectedCount(int count) {
    return '$count নির্বাচিত';
  }

  @override
  String get paste => 'পেস্ট';

  @override
  String get sfuAudioOnly => 'শুধু অডিও';

  @override
  String sfuParticipants(int count) {
    return '$count অংশগ্রহণকারী';
  }

  @override
  String get dataUnencryptedBackup => 'এনক্রিপ্ট না করা ব্যাকআপ';

  @override
  String get dataUnencryptedBackupBody =>
      'এই ফাইলটি একটি এনক্রিপ্ট না করা পরিচয় ব্যাকআপ এবং আপনার বর্তমান কীগুলি ওভাররাইট করবে। শুধুমাত্র আপনার তৈরি করা ফাইল আমদানি করুন। চালিয়ে যাবেন?';

  @override
  String get dataImportAnyway => 'যাই হোক আমদানি করুন';

  @override
  String get securityStorageError =>
      'নিরাপদ সঞ্চয়স্থান ত্রুটি — অ্যাপ রিস্টার্ট করুন';

  @override
  String get aboutDevModeActive => 'ডেভেলপার মোড সক্রিয়';

  @override
  String get themeColors => 'রং';

  @override
  String get themePrimaryAccent => 'প্রাথমিক অ্যাকসেন্ট';

  @override
  String get themeSecondaryAccent => 'দ্বিতীয় অ্যাকসেন্ট';

  @override
  String get themeBackground => 'পটভূমি';

  @override
  String get themeSurface => 'পৃষ্ঠতল';

  @override
  String get themeChatBubbles => 'চ্যাট বাবল';

  @override
  String get themeOutgoingMessage => 'আউটগোয়িং বার্তা';

  @override
  String get themeIncomingMessage => 'ইনকামিং বার্তা';

  @override
  String get themeShape => 'আকৃতি';

  @override
  String get devSectionDeveloper => 'ডেভেলপার';

  @override
  String get devAdapterChannelsHint =>
      'অ্যাডাপ্টার চ্যানেল — নির্দিষ্ট পরিবহন পরীক্ষা করতে নিষ্ক্রিয় করুন।';

  @override
  String get devNostrRelays => 'Nostr রিলে (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Session নেটওয়ার্ক';

  @override
  String get devPulseRelay => 'Pulse স্ব-হোস্টেড রিলে';

  @override
  String get devLanNetwork => 'স্থানীয় নেটওয়ার্ক (UDP/TCP)';

  @override
  String get devSectionCalls => 'কল';

  @override
  String get devForceTurnRelay => 'TURN relay বাধ্যতামূলক';

  @override
  String get devForceTurnRelaySubtitle =>
      'P2P নিষ্ক্রিয় করুন — সব কল শুধুমাত্র TURN সার্ভারের মাধ্যমে';

  @override
  String get devRestartWarning =>
      '⚠ পরবর্তী পাঠানো/কলে পরিবর্তন কার্যকর হবে। ইনকামিংয়ে প্রয়োগ করতে অ্যাপ রিস্টার্ট করুন।';

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
  String get pulseUseServerTitle => 'Pulse সার্ভার ব্যবহার করবেন?';

  @override
  String pulseUseServerBody(String name, String host) {
    return '$name $host Pulse সার্ভার ব্যবহার করেন। তাঁর সাথে (এবং একই সার্ভারে অন্যদের সাথে) দ্রুত চ্যাটের জন্য যোগ দিতে চান?';
  }

  @override
  String pulseContactUsesPulse(String name) {
    return '$name Pulse ব্যবহার করছেন';
  }

  @override
  String pulseJoinForFaster(String host) {
    return 'দ্রুত চ্যাটের জন্য $host এ যোগ দিন';
  }

  @override
  String get pulseNotNow => 'এখন নয়';

  @override
  String get pulseJoin => 'যোগ দিন';

  @override
  String get pulseDismiss => 'বন্ধ করুন';

  @override
  String get pulseHide7Days => '7 দিনের জন্য লুকান';

  @override
  String get pulseNeverAskAgain => 'আর জিজ্ঞাসা করবেন না';

  @override
  String get groupSearchContactsHint => 'পরিচিতি খুঁজুন…';

  @override
  String get systemActorYou => 'আপনি';

  @override
  String get systemActorPeer => 'যোগাযোগ';

  @override
  String systemTtlEnabled(String actor, String duration) {
    return '$actor অদৃশ্যকারী বার্তা চালু করেছেন: $duration';
  }

  @override
  String systemTtlDisabled(String actor) {
    return '$actor অদৃশ্যকারী বার্তা বন্ধ করেছেন';
  }

  @override
  String get menuClearChatHistory => 'চ্যাটের ইতিহাস পরিষ্কার করুন';

  @override
  String get clearChatTitle => 'চ্যাটের ইতিহাস পরিষ্কার করবেন?';

  @override
  String get clearChatBody =>
      'এই চ্যাটের সমস্ত বার্তা এই ডিভাইস থেকে মুছে ফেলা হবে। অপর ব্যক্তি তাদের কপি রাখবেন।';

  @override
  String get clearChatAction => 'পরিষ্কার করুন';

  @override
  String systemGroupRenamed(String actor, String name) {
    return '$actor গ্রুপের নাম পরিবর্তন করে \"$name\" করেছেন';
  }

  @override
  String systemGroupAvatarChanged(String actor) {
    return '$actor গ্রুপের ছবি পরিবর্তন করেছেন';
  }

  @override
  String systemGroupMetaChanged(String actor, String name) {
    return '$actor গ্রুপের নাম পরিবর্তন করে \"$name\" করেছেন এবং ছবিও পরিবর্তন করেছেন';
  }

  @override
  String get profileInviteLink => 'আমন্ত্রণ লিঙ্ক';

  @override
  String get profileInviteLinkSubtitle => 'যে কেউ লিঙ্ক দিয়ে যোগ দিতে পারেন';

  @override
  String get profileInviteLinkCopied => 'আমন্ত্রণ লিঙ্ক কপি করা হয়েছে';

  @override
  String get groupInviteLinkTitle => 'গ্রুপে যোগ দেবেন?';

  @override
  String groupInviteLinkBody(String name, int count) {
    return 'আপনাকে \"$name\" এ আমন্ত্রণ জানানো হয়েছে ($count জন সদস্য)।';
  }

  @override
  String get groupInviteLinkJoin => 'যোগ দিন';

  @override
  String get drawerCreateGroup => 'গ্রুপ তৈরি করুন';

  @override
  String get drawerJoinGroup => 'গ্রুপে যোগ দিন';

  @override
  String get drawerJoinGroupByLinkInvalid =>
      'এটা Pulse আমন্ত্রণ লিঙ্কের মতো দেখাচ্ছে না';

  @override
  String get groupModeMeshTitle => 'সাধারণ';

  @override
  String groupModeMeshSubtitle(int n) {
    return 'সার্ভার ছাড়া, $n জন পর্যন্ত';
  }

  @override
  String get groupModePulseTitle => 'Pulse সার্ভার';

  @override
  String groupModePulseSubtitle(int n) {
    return 'সার্ভারের মাধ্যমে, $n জন পর্যন্ত';
  }

  @override
  String get groupPulseServerHint => 'https://আপনার-pulse-সার্ভার';

  @override
  String get groupPulseServerClosed => 'বন্ধ সার্ভার (আমন্ত্রণ কোড প্রয়োজন)';

  @override
  String get groupPulseInviteHint => 'আমন্ত্রণ কোড';

  @override
  String pulseGroupForeignServerBanner(String host) {
    return 'বার্তা $host এর মাধ্যমে পাঠানো হয়';
  }

  @override
  String groupMeshLimitReached(int n) {
    return 'এই কল প্রকার $n জনে সীমাবদ্ধ';
  }
}
