// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'پیغامات تلاش کریں...';

  @override
  String get search => 'تلاش';

  @override
  String get clearSearch => 'تلاش صاف کریں';

  @override
  String get closeSearch => 'تلاش بند کریں';

  @override
  String get moreOptions => 'مزید اختیارات';

  @override
  String get back => 'واپس';

  @override
  String get cancel => 'منسوخ';

  @override
  String get close => 'بند کریں';

  @override
  String get confirm => 'تصدیق';

  @override
  String get remove => 'ہٹائیں';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get add => 'شامل کریں';

  @override
  String get copy => 'کاپی';

  @override
  String get skip => 'چھوڑیں';

  @override
  String get done => 'ہو گیا';

  @override
  String get apply => 'لاگو کریں';

  @override
  String get export => 'برآمد';

  @override
  String get import => 'درآمد';

  @override
  String get homeNewGroup => 'نیا گروپ';

  @override
  String get homeSettings => 'ترتیبات';

  @override
  String get homeSearching => 'پیغامات تلاش ہو رہے ہیں...';

  @override
  String get homeNoResults => 'کوئی نتائج نہیں ملے';

  @override
  String get homeNoChatHistory => 'ابھی تک کوئی چیٹ سابقہ نہیں';

  @override
  String homeTransportSwitched(String address) {
    return 'ٹرانسپورٹ تبدیل ہوا → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name کال کر رہا ہے...';
  }

  @override
  String get homeAccept => 'قبول کریں';

  @override
  String get homeDecline => 'رد کریں';

  @override
  String get homeLoadEarlier => 'پرانے پیغامات لوڈ کریں';

  @override
  String get homeChats => 'چیٹس';

  @override
  String get homeSelectConversation => 'ایک گفتگو منتخب کریں';

  @override
  String get homeNoChatsYet => 'ابھی تک کوئی چیٹ نہیں';

  @override
  String get homeAddContactToStart =>
      'چیٹ شروع کرنے کے لیے ایک رابطہ شامل کریں';

  @override
  String get homeNewChat => 'نئی چیٹ';

  @override
  String get homeNewChatTooltip => 'نئی چیٹ';

  @override
  String get homeIncomingCallTitle => 'آنے والی کال';

  @override
  String get homeIncomingGroupCallTitle => 'آنے والی گروپ کال';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — گروپ کال آ رہی ہے';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return '\"$query\" سے مماثل کوئی چیٹ نہیں';
  }

  @override
  String get homeSectionChats => 'چیٹس';

  @override
  String get homeSectionMessages => 'پیغامات';

  @override
  String get homeDbEncryptionUnavailable =>
      'ڈیٹابیس انکرپشن دستیاب نہیں — مکمل تحفظ کے لیے SQLCipher انسٹال کریں';

  @override
  String get chatFileTooLargeGroup =>
      'گروپ چیٹس میں 512 KB سے بڑی فائلیں معاونت یافتہ نہیں ہیں';

  @override
  String get chatLargeFile => 'بڑی فائل';

  @override
  String get chatCancel => 'منسوخ';

  @override
  String get chatSend => 'بھیجیں';

  @override
  String get chatFileTooLarge =>
      'فائل بہت بڑی ہے — زیادہ سے زیادہ سائز 100 MB ہے';

  @override
  String get chatMicDenied => 'مائیکروفون کی اجازت مسترد';

  @override
  String get chatVoiceFailed =>
      'صوتی پیغام محفوظ نہیں ہو سکا — دستیاب اسٹوریج چیک کریں';

  @override
  String get chatScheduleFuture => 'شیڈول وقت مستقبل میں ہونا چاہیے';

  @override
  String get chatToday => 'آج';

  @override
  String get chatYesterday => 'کل';

  @override
  String get chatEdited => 'ترمیم شدہ';

  @override
  String get chatYou => 'آپ';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'یہ فائل $size MB ہے۔ بڑی فائلیں بھیجنا بعض نیٹ ورکس پر سست ہو سکتا ہے۔ جاری رکھیں؟';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return '$name کی سیکیورٹی کلید تبدیل ہو گئی ہے۔ تصدیق کے لیے ٹیپ کریں۔';
  }

  @override
  String chatEncryptionFailed(String name) {
    return '$name کو پیغام انکرپٹ نہیں ہو سکا — پیغام نہیں بھیجا گیا۔';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return '$name کے لیے سیفٹی نمبر تبدیل ہو گیا۔ تصدیق کے لیے ٹیپ کریں۔';
  }

  @override
  String get chatNoMessagesFound => 'کوئی پیغامات نہیں ملے';

  @override
  String get chatMessagesE2ee => 'پیغامات اینڈ ٹو اینڈ انکرپٹڈ ہیں';

  @override
  String get chatSayHello => 'ہیلو کہیں';

  @override
  String get appBarOnline => 'آن لائن';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'لکھ رہا ہے';

  @override
  String get appBarSearchMessages => 'پیغامات تلاش کریں...';

  @override
  String get appBarMute => 'خاموش';

  @override
  String get appBarUnmute => 'غیر خاموش';

  @override
  String get appBarMedia => 'میڈیا';

  @override
  String get appBarDisappearing => 'غائب ہونے والے پیغامات';

  @override
  String get appBarDisappearingOn => 'غائب ہونا: آن';

  @override
  String get appBarGroupSettings => 'گروپ ترتیبات';

  @override
  String get appBarSearchTooltip => 'پیغامات تلاش کریں';

  @override
  String get appBarVoiceCall => 'صوتی کال';

  @override
  String get appBarVideoCall => 'ویڈیو کال';

  @override
  String get inputMessage => 'پیغام...';

  @override
  String get inputAttachFile => 'فائل منسلک کریں';

  @override
  String get inputSendMessage => 'پیغام بھیجیں';

  @override
  String get inputRecordVoice => 'صوتی پیغام ریکارڈ کریں';

  @override
  String get inputSendVoice => 'صوتی پیغام بھیجیں';

  @override
  String get inputCancelReply => 'جواب منسوخ کریں';

  @override
  String get inputCancelEdit => 'ترمیم منسوخ کریں';

  @override
  String get inputCancelRecording => 'ریکارڈنگ منسوخ کریں';

  @override
  String get inputRecording => 'ریکارڈنگ…';

  @override
  String get inputEditingMessage => 'پیغام میں ترمیم';

  @override
  String get inputPhoto => 'تصویر';

  @override
  String get inputVoiceMessage => 'صوتی پیغام';

  @override
  String get inputFile => 'فائل';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ات',
      one: '',
    );
    return '$count شیڈول شدہ پیغام$_temp0';
  }

  @override
  String get callInitializing => 'کال شروع ہو رہی ہے…';

  @override
  String get callConnecting => 'جڑ رہا ہے…';

  @override
  String get callConnectingRelay => 'جڑ رہا ہے (ریلے)…';

  @override
  String get callSwitchingRelay => 'ریلے موڈ پر سوئچ ہو رہا ہے…';

  @override
  String get callConnectionFailed => 'کنکشن ناکام';

  @override
  String get callReconnecting => 'دوبارہ جڑ رہا ہے…';

  @override
  String get callEnded => 'کال ختم';

  @override
  String get callLive => 'لائیو';

  @override
  String get callEnd => 'ختم';

  @override
  String get callEndCall => 'کال ختم کریں';

  @override
  String get callMute => 'خاموش';

  @override
  String get callUnmute => 'غیر خاموش';

  @override
  String get callSpeaker => 'اسپیکر';

  @override
  String get callCameraOn => 'کیمرا آن';

  @override
  String get callCameraOff => 'کیمرا آف';

  @override
  String get callShareScreen => 'اسکرین شیئر کریں';

  @override
  String get callStopShare => 'شیئرنگ بند کریں';

  @override
  String callTorBackup(String duration) {
    return 'Tor بیک اپ · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor بیک اپ فعال — بنیادی راستہ دستیاب نہیں';

  @override
  String get callDirectFailed =>
      'براہ راست کنکشن ناکام — ریلے موڈ پر سوئچ ہو رہا ہے…';

  @override
  String get callTurnUnreachable =>
      'TURN سرورز تک رسائی نہیں ہو سکی۔ ترتیبات → ایڈوانسڈ میں اپنا TURN شامل کریں۔';

  @override
  String get callRelayMode => 'ریلے موڈ فعال (محدود نیٹ ورک)';

  @override
  String get callStarting => 'کال شروع ہو رہی ہے…';

  @override
  String get callConnectingToGroup => 'گروپ سے جڑ رہا ہے…';

  @override
  String get callGroupOpenedInBrowser => 'گروپ کال براؤزر میں کھل گئی';

  @override
  String get callCouldNotOpenBrowser => 'براؤزر نہیں کھل سکا';

  @override
  String get callInviteLinkSent =>
      'دعوتی لنک تمام گروپ اراکین کو بھیج دیا گیا۔';

  @override
  String get callOpenLinkManually =>
      'اوپر والا لنک دستی طور پر کھولیں یا دوبارہ کوشش کے لیے ٹیپ کریں۔';

  @override
  String get callJitsiNotE2ee => 'Jitsi کالز اینڈ ٹو اینڈ انکرپٹڈ نہیں ہیں';

  @override
  String get callRetryOpenBrowser => 'براؤزر دوبارہ کھولیں';

  @override
  String get callClose => 'بند کریں';

  @override
  String get callCamOn => 'کیمرا آن';

  @override
  String get callCamOff => 'کیمرا آف';

  @override
  String get noConnection => 'کوئی کنکشن نہیں — پیغامات قطار میں لگیں گے';

  @override
  String get connected => 'جڑا ہوا';

  @override
  String get connecting => 'جڑ رہا ہے…';

  @override
  String get disconnected => 'منقطع';

  @override
  String get offlineBanner =>
      'کوئی کنکشن نہیں — پیغامات دوبارہ آن لائن ہونے پر بھیجے جائیں گے';

  @override
  String get lanModeBanner => 'LAN موڈ — انٹرنیٹ نہیں · صرف مقامی نیٹ ورک';

  @override
  String get probeCheckingNetwork => 'نیٹ ورک کنیکٹیویٹی چیک ہو رہی ہے…';

  @override
  String get probeDiscoveringRelays =>
      'کمیونٹی ڈائریکٹریز سے ریلے دریافت ہو رہے ہیں…';

  @override
  String get probeStartingTor => 'بوٹسٹریپ کے لیے Tor شروع ہو رہا ہے…';

  @override
  String get probeFindingRelaysTor =>
      'Tor کے ذریعے قابل رسائی ریلے تلاش ہو رہے ہیں…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ز',
      one: '',
    );
    return 'نیٹ ورک تیار — $count ریلے$_temp0 ملے';
  }

  @override
  String get probeNoRelaysFound =>
      'کوئی قابل رسائی ریلے نہیں ملے — پیغامات میں تاخیر ہو سکتی ہے';

  @override
  String get jitsiWarningTitle => 'اینڈ ٹو اینڈ انکرپٹڈ نہیں';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet کالز Pulse کے ذریعے انکرپٹ نہیں ہوتیں۔ صرف غیر حساس گفتگو کے لیے استعمال کریں۔';

  @override
  String get jitsiConfirm => 'بہرحال شامل ہوں';

  @override
  String get jitsiGroupWarningTitle => 'اینڈ ٹو اینڈ انکرپٹڈ نہیں';

  @override
  String get jitsiGroupWarningBody =>
      'اس کال میں بلٹ ان انکرپٹڈ میش کے لیے بہت زیادہ شرکاء ہیں۔\n\nآپ کے براؤزر میں ایک Jitsi Meet لنک کھلے گا۔ Jitsi اینڈ ٹو اینڈ انکرپٹڈ نہیں ہے — سرور آپ کی کال دیکھ سکتا ہے۔';

  @override
  String get jitsiContinueAnyway => 'بہرحال جاری رکھیں';

  @override
  String get retry => 'دوبارہ کوشش';

  @override
  String get setupCreateAnonymousAccount => 'گمنام اکاؤنٹ بنائیں';

  @override
  String get setupTapToChangeColor => 'رنگ بدلنے کے لیے ٹیپ کریں';

  @override
  String get setupReqMinLength => 'کم از کم 16 حروف';

  @override
  String get setupReqVariety => '4 میں سے 3: بڑے، چھوٹے حروف، اعداد، علامات';

  @override
  String get setupReqMatch => 'پاس ورڈ ملتے ہیں';

  @override
  String get setupYourNickname => 'آپ کا عرفی نام';

  @override
  String get setupRecoveryPassword => 'بازیابی پاس ورڈ (کم از کم 16)';

  @override
  String get setupConfirmPassword => 'پاس ورڈ کی تصدیق کریں';

  @override
  String get setupMin16Chars => 'کم از کم 16 حروف';

  @override
  String get setupPasswordsDoNotMatch => 'پاس ورڈ مماثل نہیں ہیں';

  @override
  String get setupEntropyWeak => 'کمزور';

  @override
  String get setupEntropyOk => 'ٹھیک';

  @override
  String get setupEntropyStrong => 'مضبوط';

  @override
  String get setupEntropyWeakNeedsVariety => 'کمزور (3 قسم کے حروف درکار ہیں)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits بٹس)';
  }

  @override
  String get setupPasswordWarning =>
      'یہ پاس ورڈ آپ کے اکاؤنٹ کو بحال کرنے کا واحد طریقہ ہے۔ کوئی سرور نہیں — کوئی پاس ورڈ ری سیٹ نہیں۔ اسے یاد رکھیں یا لکھ لیں۔';

  @override
  String get setupCreateAccount => 'اکاؤنٹ بنائیں';

  @override
  String get setupAlreadyHaveAccount => 'پہلے سے اکاؤنٹ ہے؟ ';

  @override
  String get setupRestore => 'بحال کریں →';

  @override
  String get restoreTitle => 'اکاؤنٹ بحال کریں';

  @override
  String get restoreInfoBanner =>
      'اپنا بازیابی پاس ورڈ درج کریں — آپ کا پتہ (Nostr + Session) خودکار طور پر بحال ہو جائے گا۔ رابطے اور پیغامات صرف مقامی طور پر محفوظ تھے۔';

  @override
  String get restoreNewNickname => 'نیا عرفی نام (بعد میں تبدیل ہو سکتا ہے)';

  @override
  String get restoreButton => 'اکاؤنٹ بحال کریں';

  @override
  String get lockTitle => 'Pulse مقفل ہے';

  @override
  String get lockSubtitle => 'جاری رکھنے کے لیے اپنا پاس ورڈ درج کریں';

  @override
  String get lockPasswordHint => 'پاس ورڈ';

  @override
  String get lockUnlock => 'غیر مقفل کریں';

  @override
  String get lockPanicHint =>
      'پاس ورڈ بھول گئے؟ تمام ڈیٹا مٹانے کے لیے اپنا پینک کلید درج کریں۔';

  @override
  String get lockTooManyAttempts =>
      'بہت زیادہ کوششیں۔ تمام ڈیٹا مٹایا جا رہا ہے…';

  @override
  String get lockWrongPassword => 'غلط پاس ورڈ';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'غلط پاس ورڈ — $attempts/$max کوششیں';
  }

  @override
  String get onboardingSkip => 'چھوڑیں';

  @override
  String get onboardingNext => 'اگلا';

  @override
  String get onboardingGetStarted => 'اکاؤنٹ بنائیں';

  @override
  String get onboardingWelcomeTitle => 'Pulse میں خوش آمدید';

  @override
  String get onboardingWelcomeBody =>
      'ایک غیر مرکزی، اینڈ ٹو اینڈ انکرپٹڈ میسنجر۔\n\nکوئی مرکزی سرورز نہیں۔ کوئی ڈیٹا اکٹھا نہیں ہوتا۔ کوئی خفیہ دروازے نہیں۔\nآپ کی گفتگو صرف آپ کی ہے۔';

  @override
  String get onboardingTransportTitle => 'ٹرانسپورٹ اگناسٹک';

  @override
  String get onboardingTransportBody =>
      'Firebase، Nostr، یا دونوں ایک ساتھ استعمال کریں۔\n\nپیغامات خودکار طور پر نیٹ ورکس کے ذریعے روٹ ہوتے ہیں۔ سنسرشپ مزاحمت کے لیے بلٹ ان Tor اور I2P معاونت۔';

  @override
  String get onboardingSignalTitle => 'Signal + پوسٹ کوانٹم';

  @override
  String get onboardingSignalBody =>
      'ہر پیغام Signal پروٹوکول (Double Ratchet + X3DH) کے ساتھ فارورڈ سیکریسی کے لیے انکرپٹ ہوتا ہے۔\n\nمزید Kyber-1024 سے لپیٹا گیا — ایک NIST معیاری پوسٹ کوانٹم الگورتھم — مستقبل کے کوانٹم کمپیوٹرز سے تحفظ۔';

  @override
  String get onboardingKeysTitle => 'آپ کی کلیدیں آپ کی ہیں';

  @override
  String get onboardingKeysBody =>
      'آپ کی شناختی کلیدیں کبھی آپ کے آلے سے باہر نہیں جاتیں۔\n\nSignal فنگر پرنٹس آپ کو آؤٹ آف بینڈ رابطوں کی تصدیق کرنے دیتے ہیں۔ TOFU (Trust On First Use) خودکار طور پر کلیدی تبدیلیاں پکڑتا ہے۔';

  @override
  String get onboardingThemeTitle => 'اپنی شکل منتخب کریں';

  @override
  String get onboardingThemeBody =>
      'ایک تھیم اور ایکسنٹ رنگ منتخب کریں۔ آپ اسے بعد میں ترتیبات سے تبدیل کر سکتے ہیں۔';

  @override
  String get contactsNewChat => 'نئی چیٹ';

  @override
  String get contactsAddContact => 'رابطہ شامل کریں';

  @override
  String get contactsSearchHint => 'تلاش...';

  @override
  String get contactsNewGroup => 'نیا گروپ';

  @override
  String get contactsNoContactsYet => 'ابھی تک کوئی رابطے نہیں';

  @override
  String get contactsAddHint => 'کسی کا پتہ شامل کرنے کے لیے + ٹیپ کریں';

  @override
  String get contactsNoMatch => 'کوئی مماثل رابطے نہیں';

  @override
  String get contactsRemoveTitle => 'رابطہ ہٹائیں';

  @override
  String contactsRemoveMessage(String name) {
    return '$name کو ہٹائیں؟';
  }

  @override
  String get contactsRemove => 'ہٹائیں';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ے',
      one: '',
    );
    return '$count رابطہ$_temp0';
  }

  @override
  String get bubbleOpenLink => 'لنک کھولیں';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'یہ URL اپنے براؤزر میں کھولیں؟\n\n$url';
  }

  @override
  String get bubbleOpen => 'کھولیں';

  @override
  String get bubbleSecurityWarning => 'سیکیورٹی وارننگ';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" ایک قابل عمل فائل قسم ہے۔ اسے محفوظ کرنا اور چلانا آپ کے آلے کو نقصان پہنچا سکتا ہے۔ بہرحال محفوظ کریں؟';
  }

  @override
  String get bubbleSaveAnyway => 'بہرحال محفوظ کریں';

  @override
  String bubbleSavedTo(String path) {
    return '$path میں محفوظ ہو گیا';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'محفوظ کرنا ناکام: $error';
  }

  @override
  String get bubbleNotEncrypted => 'انکرپٹڈ نہیں';

  @override
  String get bubbleCorruptedImage => '[خراب تصویر]';

  @override
  String get bubbleReplyPhoto => 'تصویر';

  @override
  String get bubbleReplyVoice => 'صوتی پیغام';

  @override
  String get bubbleReplyVideo => 'ویڈیو پیغام';

  @override
  String bubbleReadBy(String names) {
    return '$names نے پڑھا';
  }

  @override
  String bubbleReadByCount(int count) {
    return '$count نے پڑھا';
  }

  @override
  String get chatTileTapToStart => 'چیٹ شروع کرنے کے لیے ٹیپ کریں';

  @override
  String get chatTileMessageSent => 'پیغام بھیجا گیا';

  @override
  String get chatTileEncryptedMessage => 'انکرپٹڈ پیغام';

  @override
  String chatTileYouPrefix(String text) {
    return 'آپ: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 وائس میسج';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 وائس میسج ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'انکرپٹڈ پیغام';

  @override
  String get groupNewGroup => 'نیا گروپ';

  @override
  String get groupGroupName => 'گروپ کا نام';

  @override
  String get groupSelectMembers => 'اراکین منتخب کریں (کم از کم 2)';

  @override
  String get groupNoContactsYet =>
      'ابھی تک کوئی رابطے نہیں۔ پہلے رابطے شامل کریں۔';

  @override
  String get groupCreate => 'بنائیں';

  @override
  String get groupLabel => 'گروپ';

  @override
  String get profileVerifyIdentity => 'شناخت کی تصدیق کریں';

  @override
  String profileVerifyInstructions(String name) {
    return 'ان فنگر پرنٹس کا $name سے صوتی کال یا ذاتی طور پر موازنہ کریں۔ اگر دونوں آلات پر دونوں قدریں مماثل ہوں تو \"تصدیق شدہ کے طور پر نشان زد کریں\" ٹیپ کریں۔';
  }

  @override
  String get profileTheirKey => 'ان کی کلید';

  @override
  String get profileYourKey => 'آپ کی کلید';

  @override
  String get profileRemoveVerification => 'تصدیق ہٹائیں';

  @override
  String get profileMarkAsVerified => 'تصدیق شدہ کے طور پر نشان زد کریں';

  @override
  String get profileAddressCopied => 'پتہ کاپی ہو گیا';

  @override
  String get profileNoContactsToAdd =>
      'شامل کرنے کے لیے کوئی رابطے نہیں — سب پہلے سے ارکان ہیں';

  @override
  String get profileAddMembers => 'اراکین شامل کریں';

  @override
  String profileAddCount(int count) {
    return 'شامل کریں ($count)';
  }

  @override
  String get profileRenameGroup => 'گروپ کا نام تبدیل کریں';

  @override
  String get profileRename => 'نام تبدیل کریں';

  @override
  String get profileRemoveMember => 'رکن ہٹائیں؟';

  @override
  String profileRemoveMemberBody(String name) {
    return '$name کو اس گروپ سے ہٹائیں؟';
  }

  @override
  String get profileKick => 'نکالیں';

  @override
  String get profileSignalFingerprints => 'Signal فنگر پرنٹس';

  @override
  String get profileVerified => 'تصدیق شدہ';

  @override
  String get profileVerify => 'تصدیق کریں';

  @override
  String get profileEdit => 'ترمیم';

  @override
  String get profileNoSession =>
      'ابھی تک کوئی سیشن قائم نہیں — پہلے ایک پیغام بھیجیں۔';

  @override
  String get profileFingerprintCopied => 'فنگر پرنٹ کاپی ہو گیا';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ان',
      one: '',
    );
    return '$count رکن$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'سیفٹی نمبر کی تصدیق کریں';

  @override
  String get profileShowContactQr => 'رابطے کا QR دکھائیں';

  @override
  String profileContactAddress(String name) {
    return '$name کا پتہ';
  }

  @override
  String get profileExportChatHistory => 'چیٹ سابقہ برآمد کریں';

  @override
  String profileSavedTo(String path) {
    return '$path میں محفوظ ہو گیا';
  }

  @override
  String get profileExportFailed => 'برآمد ناکام';

  @override
  String get profileClearChatHistory => 'چیٹ سابقہ صاف کریں';

  @override
  String get profileDeleteGroup => 'گروپ حذف کریں';

  @override
  String get profileDeleteContact => 'رابطہ حذف کریں';

  @override
  String get profileLeaveGroup => 'گروپ چھوڑیں';

  @override
  String get profileLeaveGroupBody =>
      'آپ کو اس گروپ سے ہٹا دیا جائے گا اور یہ آپ کے رابطوں سے حذف ہو جائے گا۔';

  @override
  String get groupInviteTitle => 'گروپ دعوت';

  @override
  String groupInviteBody(String from, String group) {
    return '$from نے آپ کو \"$group\" میں شامل ہونے کی دعوت دی';
  }

  @override
  String get groupInviteAccept => 'قبول کریں';

  @override
  String get groupInviteDecline => 'رد کریں';

  @override
  String get groupMemberLimitTitle => 'بہت زیادہ شرکاء';

  @override
  String groupMemberLimitBody(int count) {
    return 'اس گروپ میں $count شرکاء ہوں گے۔ انکرپٹڈ میش کالز 6 تک معاونت کرتی ہیں۔ بڑے گروپس Jitsi (E2EE نہیں) پر آ جاتے ہیں۔';
  }

  @override
  String get groupMemberLimitContinue => 'بہرحال شامل کریں';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name نے \"$group\" میں شامل ہونے سے انکار کر دیا';
  }

  @override
  String get transferTitle => 'دوسرے آلے میں منتقل کریں';

  @override
  String get transferInfoBox =>
      'اپنی Signal شناخت اور Nostr کلیدیں نئے آلے میں منتقل کریں۔\nچیٹ سیشنز منتقل نہیں ہوتے — فارورڈ سیکریسی محفوظ رہتی ہے۔';

  @override
  String get transferSendFromThis => 'اس آلے سے بھیجیں';

  @override
  String get transferSendSubtitle =>
      'اس آلے میں کلیدیں ہیں۔ نئے آلے کے ساتھ کوڈ شیئر کریں۔';

  @override
  String get transferReceiveOnThis => 'اس آلے پر وصول کریں';

  @override
  String get transferReceiveSubtitle =>
      'یہ نیا آلہ ہے۔ پرانے آلے سے کوڈ درج کریں۔';

  @override
  String get transferChooseMethod => 'منتقلی کا طریقہ منتخب کریں';

  @override
  String get transferLan => 'LAN (ایک ہی نیٹ ورک)';

  @override
  String get transferLanSubtitle =>
      'تیز، براہ راست۔ دونوں آلات ایک ہی Wi-Fi پر ہونے چاہئیں۔';

  @override
  String get transferNostrRelay => 'Nostr ریلے';

  @override
  String get transferNostrRelaySubtitle =>
      'موجودہ Nostr ریلے کے ذریعے کسی بھی نیٹ ورک پر کام کرتا ہے۔';

  @override
  String get transferRelayUrl => 'ریلے URL';

  @override
  String get transferEnterCode => 'منتقلی کوڈ درج کریں';

  @override
  String get transferPasteCode => 'LAN:... یا NOS:... کوڈ یہاں چسپاں کریں';

  @override
  String get transferConnect => 'جڑیں';

  @override
  String get transferGenerating => 'منتقلی کوڈ بنایا جا رہا ہے…';

  @override
  String get transferShareCode => 'یہ کوڈ وصول کنندہ کے ساتھ شیئر کریں:';

  @override
  String get transferCopyCode => 'کوڈ کاپی کریں';

  @override
  String get transferCodeCopied => 'کوڈ کلپ بورڈ میں کاپی ہو گیا';

  @override
  String get transferWaitingReceiver => 'وصول کنندہ کے جڑنے کا انتظار…';

  @override
  String get transferConnectingSender => 'بھیجنے والے سے جڑ رہا ہے…';

  @override
  String get transferVerifyBoth =>
      'دونوں آلات پر اس کوڈ کا موازنہ کریں۔\nاگر وہ مماثل ہیں تو منتقلی محفوظ ہے۔';

  @override
  String get transferComplete => 'منتقلی مکمل';

  @override
  String get transferKeysImported => 'کلیدیں درآمد ہو گئیں';

  @override
  String get transferCompleteSenderBody =>
      'آپ کی کلیدیں اس آلے پر فعال رہیں گی۔\nوصول کنندہ اب آپ کی شناخت استعمال کر سکتا ہے۔';

  @override
  String get transferCompleteReceiverBody =>
      'کلیدیں کامیابی سے درآمد ہوئیں۔\nنئی شناخت لاگو کرنے کے لیے ایپ دوبارہ شروع کریں۔';

  @override
  String get transferRestartApp => 'ایپ دوبارہ شروع کریں';

  @override
  String get transferFailed => 'منتقلی ناکام';

  @override
  String get transferTryAgain => 'دوبارہ کوشش کریں';

  @override
  String get transferEnterRelayFirst => 'پہلے ریلے URL درج کریں';

  @override
  String get transferPasteCodeFromSender =>
      'بھیجنے والے سے منتقلی کوڈ چسپاں کریں';

  @override
  String get menuReply => 'جواب دیں';

  @override
  String get menuForward => 'آگے بھیجیں';

  @override
  String get menuReact => 'ردعمل';

  @override
  String get menuCopy => 'کاپی';

  @override
  String get menuEdit => 'ترمیم';

  @override
  String get menuRetry => 'دوبارہ کوشش';

  @override
  String get menuCancelScheduled => 'شیڈول منسوخ کریں';

  @override
  String get menuDelete => 'حذف کریں';

  @override
  String get menuForwardTo => 'آگے بھیجیں…';

  @override
  String menuForwardedTo(String name) {
    return '$name کو بھیج دیا گیا';
  }

  @override
  String get menuScheduledMessages => 'شیڈول شدہ پیغامات';

  @override
  String get menuNoScheduledMessages => 'کوئی شیڈول شدہ پیغامات نہیں';

  @override
  String menuSendsOn(String date) {
    return '$date کو بھیجا جائے گا';
  }

  @override
  String get menuDisappearingMessages => 'غائب ہونے والے پیغامات';

  @override
  String get menuDisappearingSubtitle =>
      'پیغامات منتخب وقت کے بعد خودکار طور پر حذف ہو جاتے ہیں۔';

  @override
  String get menuTtlOff => 'بند';

  @override
  String get menuTtl1h => '1 گھنٹہ';

  @override
  String get menuTtl24h => '24 گھنٹے';

  @override
  String get menuTtl7d => '7 دن';

  @override
  String get menuAttachPhoto => 'تصویر';

  @override
  String get menuAttachFile => 'فائل';

  @override
  String get menuAttachVideo => 'ویڈیو';

  @override
  String get mediaTitle => 'میڈیا';

  @override
  String get mediaFileLabel => 'فائل';

  @override
  String mediaPhotosTab(int count) {
    return 'تصاویر ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'فائلیں ($count)';
  }

  @override
  String get mediaNoPhotos => 'ابھی تک کوئی تصاویر نہیں';

  @override
  String get mediaNoFiles => 'ابھی تک کوئی فائلیں نہیں';

  @override
  String mediaSavedToDownloads(String name) {
    return 'ڈاؤن لوڈز/$name میں محفوظ ہو گیا';
  }

  @override
  String get mediaFailedToSave => 'فائل محفوظ نہیں ہو سکی';

  @override
  String get statusNewStatus => 'نیا اسٹیٹس';

  @override
  String get statusPublish => 'شائع کریں';

  @override
  String get statusExpiresIn24h => 'اسٹیٹس 24 گھنٹوں میں ختم ہو جائے گا';

  @override
  String get statusWhatsOnYourMind => 'آپ کے ذہن میں کیا ہے؟';

  @override
  String get statusPhotoAttached => 'تصویر منسلک';

  @override
  String get statusAttachPhoto => 'تصویر منسلک کریں (اختیاری)';

  @override
  String get statusEnterText => 'براہ کرم اپنے اسٹیٹس کے لیے کچھ متن درج کریں۔';

  @override
  String statusPickPhotoFailed(String error) {
    return 'تصویر منتخب نہیں ہو سکی: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'شائع نہیں ہو سکا: $error';
  }

  @override
  String get panicSetPanicKey => 'پینک کلید مقرر کریں';

  @override
  String get panicEmergencySelfDestruct => 'ہنگامی خود تباہی';

  @override
  String get panicIrreversible => 'یہ عمل ناقابل واپسی ہے';

  @override
  String get panicWarningBody =>
      'لاک اسکرین پر یہ کلید داخل کرنا فوری طور پر تمام ڈیٹا مٹا دے گا — پیغامات، رابطے، کلیدیں، شناخت۔ اپنے عام پاس ورڈ سے مختلف کلید استعمال کریں۔';

  @override
  String get panicKeyHint => 'پینک کلید';

  @override
  String get panicConfirmHint => 'پینک کلید کی تصدیق کریں';

  @override
  String get panicMinChars => 'پینک کلید کم از کم 8 حروف کی ہونی چاہیے';

  @override
  String get panicKeysDoNotMatch => 'کلیدیں مماثل نہیں ہیں';

  @override
  String get panicSetFailed =>
      'پینک کلید محفوظ نہیں ہو سکی — براہ کرم دوبارہ کوشش کریں';

  @override
  String get passwordSetAppPassword => 'ایپ پاس ورڈ مقرر کریں';

  @override
  String get passwordProtectsMessages =>
      'آپ کے پیغامات کو آرام میں محفوظ کرتا ہے';

  @override
  String get passwordInfoBanner =>
      'ہر بار Pulse کھولنے پر درکار ہے۔ اگر بھول گئے تو آپ کا ڈیٹا بحال نہیں ہو سکتا۔';

  @override
  String get passwordHint => 'پاس ورڈ';

  @override
  String get passwordConfirmHint => 'پاس ورڈ کی تصدیق کریں';

  @override
  String get passwordSetButton => 'پاس ورڈ مقرر کریں';

  @override
  String get passwordSkipForNow => 'ابھی کے لیے چھوڑیں';

  @override
  String get passwordMinChars => 'پاس ورڈ کم از کم 8 حروف کا ہونا چاہیے';

  @override
  String get passwordNeedsVariety =>
      'حروف، اعداد اور خصوصی حروف شامل ہونے چاہئیں';

  @override
  String get passwordRequirements =>
      'کم از کم 8 حروف بشمول حروف، اعداد اور ایک خصوصی حرف';

  @override
  String get passwordsDoNotMatch => 'پاس ورڈ مماثل نہیں ہیں';

  @override
  String get profileCardSaved => 'پروفائل محفوظ ہو گیا!';

  @override
  String get profileCardE2eeIdentity => 'E2EE شناخت';

  @override
  String get profileCardDisplayName => 'ظاہری نام';

  @override
  String get profileCardDisplayNameHint => 'مثلاً احمد خان';

  @override
  String get profileCardAbout => 'تعارف';

  @override
  String get profileCardSaveProfile => 'پروفائل محفوظ کریں';

  @override
  String get profileCardYourName => 'آپ کا نام';

  @override
  String get profileCardAddressCopied => 'پتہ کاپی ہو گیا!';

  @override
  String get profileCardInboxAddress => 'آپ کا ان باکس پتہ';

  @override
  String get profileCardInboxAddresses => 'آپ کے ان باکس پتے';

  @override
  String get profileCardShareAllAddresses => 'تمام پتے شیئر کریں (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'رابطوں کے ساتھ شیئر کریں تاکہ وہ آپ کو پیغام بھیج سکیں۔';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'تمام $count پتے ایک لنک کے طور پر کاپی ہو گئے!';
  }

  @override
  String get settingsMyProfile => 'میرا پروفائل';

  @override
  String get settingsYourInboxAddress => 'آپ کا ان باکس پتہ';

  @override
  String get settingsMyQrCode => 'رابطہ شیئر کریں';

  @override
  String get settingsMyQrSubtitle => 'آپ کے پتے کے لیے QR کوڈ اور دعوتی لنک';

  @override
  String get settingsShareMyAddress => 'میرا پتہ شیئر کریں';

  @override
  String get settingsNoAddressYet =>
      'ابھی تک کوئی پتہ نہیں — پہلے ترتیبات محفوظ کریں';

  @override
  String get settingsInviteLink => 'دعوتی لنک';

  @override
  String get settingsRawAddress => 'خام پتہ';

  @override
  String get settingsCopyLink => 'لنک کاپی کریں';

  @override
  String get settingsCopyAddress => 'پتہ کاپی کریں';

  @override
  String get settingsInviteLinkCopied => 'دعوتی لنک کاپی ہو گیا';

  @override
  String get settingsAppearance => 'ظاہری شکل';

  @override
  String get settingsThemeEngine => 'تھیم انجن';

  @override
  String get settingsThemeEngineSubtitle => 'رنگ اور فانٹس کو حسب ضرورت بنائیں';

  @override
  String get settingsSignalProtocol => 'Signal پروٹوکول';

  @override
  String get settingsSignalProtocolSubtitle =>
      'E2EE کلیدیں محفوظ طریقے سے محفوظ ہیں';

  @override
  String get settingsActive => 'فعال';

  @override
  String get settingsIdentityBackup => 'شناخت کا بیک اپ';

  @override
  String get settingsIdentityBackupSubtitle =>
      'اپنی Signal شناخت برآمد یا درآمد کریں';

  @override
  String get settingsIdentityBackupBody =>
      'اپنی Signal شناختی کلیدیں بیک اپ کوڈ میں برآمد کریں، یا موجودہ سے بحال کریں۔';

  @override
  String get settingsTransferDevice => 'دوسرے آلے میں منتقل کریں';

  @override
  String get settingsTransferDeviceSubtitle =>
      'LAN یا Nostr ریلے کے ذریعے شناخت منتقل کریں';

  @override
  String get settingsExportIdentity => 'شناخت برآمد کریں';

  @override
  String get settingsExportIdentityBody =>
      'یہ بیک اپ کوڈ کاپی کریں اور محفوظ رکھیں:';

  @override
  String get settingsSaveFile => 'فائل محفوظ کریں';

  @override
  String get settingsImportIdentity => 'شناخت درآمد کریں';

  @override
  String get settingsImportIdentityBody =>
      'اپنا بیک اپ کوڈ نیچے چسپاں کریں۔ یہ آپ کی موجودہ شناخت کو اوور رائٹ کر دے گا۔';

  @override
  String get settingsPasteBackupCode => 'بیک اپ کوڈ یہاں چسپاں کریں…';

  @override
  String get settingsIdentityImported =>
      'شناخت + رابطے درآمد ہو گئے! لاگو کرنے کے لیے ایپ دوبارہ شروع کریں۔';

  @override
  String get settingsSecurity => 'سیکیورٹی';

  @override
  String get settingsAppPassword => 'ایپ پاس ورڈ';

  @override
  String get settingsPasswordEnabled => 'فعال — ہر شروع پر درکار ہے';

  @override
  String get settingsPasswordDisabled => 'غیر فعال — ایپ بغیر پاس ورڈ کھلتی ہے';

  @override
  String get settingsChangePassword => 'پاس ورڈ تبدیل کریں';

  @override
  String get settingsChangePasswordSubtitle =>
      'اپنا ایپ لاک پاس ورڈ اپ ڈیٹ کریں';

  @override
  String get settingsSetPanicKey => 'پینک کلید مقرر کریں';

  @override
  String get settingsChangePanicKey => 'پینک کلید تبدیل کریں';

  @override
  String get settingsPanicKeySetSubtitle => 'ہنگامی مٹانے کی کلید اپ ڈیٹ کریں';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'ایک کلید جو فوری طور پر تمام ڈیٹا مٹا دیتی ہے';

  @override
  String get settingsRemovePanicKey => 'پینک کلید ہٹائیں';

  @override
  String get settingsRemovePanicKeySubtitle => 'ہنگامی خود تباہی غیر فعال کریں';

  @override
  String get settingsRemovePanicKeyBody =>
      'ہنگامی خود تباہی غیر فعال ہو جائے گی۔ آپ اسے کسی بھی وقت دوبارہ فعال کر سکتے ہیں۔';

  @override
  String get settingsDisableAppPassword => 'ایپ پاس ورڈ غیر فعال کریں';

  @override
  String get settingsEnterCurrentPassword =>
      'تصدیق کے لیے اپنا موجودہ پاس ورڈ درج کریں';

  @override
  String get settingsCurrentPassword => 'موجودہ پاس ورڈ';

  @override
  String get settingsIncorrectPassword => 'غلط پاس ورڈ';

  @override
  String get settingsPasswordUpdated => 'پاس ورڈ اپ ڈیٹ ہو گیا';

  @override
  String get settingsChangePasswordProceed =>
      'آگے بڑھنے کے لیے اپنا موجودہ پاس ورڈ درج کریں';

  @override
  String get settingsData => 'ڈیٹا';

  @override
  String get settingsBackupMessages => 'پیغامات کا بیک اپ';

  @override
  String get settingsBackupMessagesSubtitle =>
      'انکرپٹڈ پیغامات کی تاریخ فائل میں برآمد کریں';

  @override
  String get settingsRestoreMessages => 'پیغامات بحال کریں';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'بیک اپ فائل سے پیغامات درآمد کریں';

  @override
  String get settingsExportKeys => 'کلیدیں برآمد کریں';

  @override
  String get settingsExportKeysSubtitle =>
      'شناختی کلیدیں انکرپٹڈ فائل میں محفوظ کریں';

  @override
  String get settingsImportKeys => 'کلیدیں درآمد کریں';

  @override
  String get settingsImportKeysSubtitle =>
      'برآمد شدہ فائل سے شناختی کلیدیں بحال کریں';

  @override
  String get settingsBackupPassword => 'بیک اپ پاس ورڈ';

  @override
  String get settingsPasswordCannotBeEmpty => 'پاس ورڈ خالی نہیں ہو سکتا';

  @override
  String get settingsPasswordMin4Chars =>
      'پاس ورڈ کم از کم 4 حروف کا ہونا چاہیے';

  @override
  String get settingsCallsTurn => 'کالز اور TURN';

  @override
  String get settingsLocalNetwork => 'مقامی نیٹ ورک';

  @override
  String get settingsCensorshipResistance => 'سنسرشپ مزاحمت';

  @override
  String get settingsNetwork => 'نیٹ ورک';

  @override
  String get settingsProxyTunnels => 'پراکسی اور ٹنلز';

  @override
  String get settingsTurnServers => 'TURN سرورز';

  @override
  String get settingsProviderTitle => 'فراہم کنندہ';

  @override
  String get settingsLanFallback => 'LAN فال بیک';

  @override
  String get settingsLanFallbackSubtitle =>
      'انٹرنیٹ دستیاب نہ ہونے پر مقامی نیٹ ورک پر موجودگی نشر کریں اور پیغامات پہنچائیں۔ غیر قابل اعتماد نیٹ ورکس (عوامی Wi-Fi) پر غیر فعال کریں۔';

  @override
  String get settingsBgDelivery => 'پس منظر ترسیل';

  @override
  String get settingsBgDeliverySubtitle =>
      'ایپ کم سے کم ہونے پر پیغامات موصول کرتے رہیں۔ ایک مستقل اطلاع دکھاتا ہے۔';

  @override
  String get settingsYourInboxProvider => 'آپ کا ان باکس فراہم کنندہ';

  @override
  String get settingsConnectionDetails => 'کنکشن کی تفصیلات';

  @override
  String get settingsSaveAndConnect => 'محفوظ کریں اور جڑیں';

  @override
  String get settingsSecondaryInboxes => 'ثانوی ان باکسز';

  @override
  String get settingsAddSecondaryInbox => 'ثانوی ان باکس شامل کریں';

  @override
  String get settingsAdvanced => 'ایڈوانسڈ';

  @override
  String get settingsDiscover => 'دریافت کریں';

  @override
  String get settingsAbout => 'کے بارے میں';

  @override
  String get settingsPrivacyPolicy => 'رازداری کی پالیسی';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Pulse آپ کے ڈیٹا کی حفاظت کیسے کرتا ہے';

  @override
  String get settingsCrashReporting => 'کریش رپورٹنگ';

  @override
  String get settingsCrashReportingSubtitle =>
      'Pulse کو بہتر بنانے کے لیے گمنام کریش رپورٹس بھیجیں۔ کوئی پیغام مواد یا رابطے کبھی نہیں بھیجے جاتے۔';

  @override
  String get settingsCrashReportingEnabled =>
      'کریش رپورٹنگ فعال — لاگو کرنے کے لیے ایپ دوبارہ شروع کریں';

  @override
  String get settingsCrashReportingDisabled =>
      'کریش رپورٹنگ غیر فعال — لاگو کرنے کے لیے ایپ دوبارہ شروع کریں';

  @override
  String get settingsSensitiveOperation => 'حساس عمل';

  @override
  String get settingsSensitiveOperationBody =>
      'یہ کلیدیں آپ کی شناخت ہیں۔ اس فائل والا کوئی بھی آپ کی نقالی کر سکتا ہے۔ اسے محفوظ رکھیں اور منتقلی کے بعد حذف کر دیں۔';

  @override
  String get settingsIUnderstandContinue => 'میں سمجھتا ہوں، جاری رکھیں';

  @override
  String get settingsReplaceIdentity => 'شناخت تبدیل کریں؟';

  @override
  String get settingsReplaceIdentityBody =>
      'یہ آپ کی موجودہ شناختی کلیدوں کو اوور رائٹ کر دے گا۔ آپ کے موجودہ Signal سیشنز باطل ہو جائیں گے اور رابطوں کو دوبارہ انکرپشن قائم کرنا ہوگا۔ ایپ کو دوبارہ شروع کرنا ہوگا۔';

  @override
  String get settingsReplaceKeys => 'کلیدیں تبدیل کریں';

  @override
  String get settingsKeysImported => 'کلیدیں درآمد ہو گئیں';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count کلیدیں کامیابی سے درآمد ہوئیں۔ نئی شناخت سے دوبارہ شروع کرنے کے لیے براہ کرم ایپ دوبارہ شروع کریں۔';
  }

  @override
  String get settingsRestartNow => 'ابھی دوبارہ شروع کریں';

  @override
  String get settingsLater => 'بعد میں';

  @override
  String get profileGroupLabel => 'گروپ';

  @override
  String get profileAddButton => 'شامل کریں';

  @override
  String get profileKickButton => 'نکالیں';

  @override
  String get dataSectionTitle => 'ڈیٹا';

  @override
  String get dataBackupMessages => 'پیغامات کا بیک اپ';

  @override
  String get dataBackupPasswordSubtitle =>
      'اپنے پیغام بیک اپ کو انکرپٹ کرنے کے لیے پاس ورڈ منتخب کریں۔';

  @override
  String get dataBackupConfirmLabel => 'بیک اپ بنائیں';

  @override
  String get dataCreatingBackup => 'بیک اپ بنایا جا رہا ہے';

  @override
  String get dataBackupPreparing => 'تیاری...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'پیغام $done از $total برآمد ہو رہا ہے...';
  }

  @override
  String get dataBackupSavingFile => 'فائل محفوظ ہو رہی ہے...';

  @override
  String get dataSaveMessageBackupDialog => 'پیغام بیک اپ محفوظ کریں';

  @override
  String dataBackupSaved(int count, String path) {
    return 'بیک اپ محفوظ ہو گیا ($count پیغامات)\n$path';
  }

  @override
  String get dataBackupFailed => 'بیک اپ ناکام — کوئی ڈیٹا برآمد نہیں ہوا';

  @override
  String dataBackupFailedError(String error) {
    return 'بیک اپ ناکام: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'پیغام بیک اپ منتخب کریں';

  @override
  String get dataInvalidBackupFile => 'غلط بیک اپ فائل (بہت چھوٹی)';

  @override
  String get dataNotValidBackupFile => 'یہ درست Pulse بیک اپ فائل نہیں ہے';

  @override
  String get dataRestoreMessages => 'پیغامات بحال کریں';

  @override
  String get dataRestorePasswordSubtitle =>
      'اس بیک اپ کو بنانے کے لیے استعمال ہونے والا پاس ورڈ درج کریں۔';

  @override
  String get dataRestoreConfirmLabel => 'بحال کریں';

  @override
  String get dataRestoringMessages => 'پیغامات بحال ہو رہے ہیں';

  @override
  String get dataRestoreDecrypting => 'ڈکرپٹنگ...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'پیغام $done از $total درآمد ہو رہا ہے...';
  }

  @override
  String get dataRestoreFailed => 'بحالی ناکام — غلط پاس ورڈ یا خراب فائل';

  @override
  String dataRestoreSuccess(int count) {
    return '$count نئے پیغامات بحال ہو گئے';
  }

  @override
  String get dataRestoreNothingNew =>
      'درآمد کے لیے کوئی نئے پیغامات نہیں (سب پہلے سے موجود ہیں)';

  @override
  String dataRestoreFailedError(String error) {
    return 'بحالی ناکام: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'کلیدی برآمد منتخب کریں';

  @override
  String get dataNotValidKeyFile => 'یہ درست Pulse کلیدی برآمد فائل نہیں ہے';

  @override
  String get dataExportKeys => 'کلیدیں برآمد کریں';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'اپنی کلیدی برآمد کو انکرپٹ کرنے کے لیے پاس ورڈ منتخب کریں۔';

  @override
  String get dataExportKeysConfirmLabel => 'برآمد کریں';

  @override
  String get dataExportingKeys => 'کلیدیں برآمد ہو رہی ہیں';

  @override
  String get dataExportingKeysStatus => 'شناختی کلیدیں انکرپٹ ہو رہی ہیں...';

  @override
  String get dataSaveKeyExportDialog => 'کلیدی برآمد محفوظ کریں';

  @override
  String dataKeysExportedTo(String path) {
    return 'کلیدیں برآمد ہوئیں:\n$path';
  }

  @override
  String get dataExportFailed => 'برآمد ناکام — کوئی کلیدیں نہیں ملیں';

  @override
  String dataExportFailedError(String error) {
    return 'برآمد ناکام: $error';
  }

  @override
  String get dataImportKeys => 'کلیدیں درآمد کریں';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'اس کلیدی برآمد کو انکرپٹ کرنے کے لیے استعمال ہونے والا پاس ورڈ درج کریں۔';

  @override
  String get dataImportKeysConfirmLabel => 'درآمد کریں';

  @override
  String get dataImportingKeys => 'کلیدیں درآمد ہو رہی ہیں';

  @override
  String get dataImportingKeysStatus => 'شناختی کلیدیں ڈکرپٹ ہو رہی ہیں...';

  @override
  String get dataImportFailed => 'درآمد ناکام — غلط پاس ورڈ یا خراب فائل';

  @override
  String dataImportFailedError(String error) {
    return 'درآمد ناکام: $error';
  }

  @override
  String get securitySectionTitle => 'سیکیورٹی';

  @override
  String get securityIncorrectPassword => 'غلط پاس ورڈ';

  @override
  String get securityPasswordUpdated => 'پاس ورڈ اپ ڈیٹ ہو گیا';

  @override
  String get appearanceSectionTitle => 'ظاہری شکل';

  @override
  String appearanceExportFailed(String error) {
    return 'برآمد ناکام: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return '$path میں محفوظ ہو گیا';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'محفوظ کرنا ناکام: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'درآمد ناکام: $error';
  }

  @override
  String get aboutSectionTitle => 'کے بارے میں';

  @override
  String get providerPublicKey => 'عوامی کلید';

  @override
  String get providerRelay => 'ریلے';

  @override
  String get providerAutoConfigured =>
      'آپ کے بازیابی پاس ورڈ سے خودکار ترتیب۔ ریلے خودکار دریافت۔';

  @override
  String get providerKeyStoredLocally =>
      'آپ کی کلید مقامی طور پر محفوظ اسٹوریج میں محفوظ ہے — کبھی کسی سرور کو نہیں بھیجی جاتی۔';

  @override
  String get providerSessionInfo =>
      'Session Network — پیاز-روٹڈ E2EE۔ آپ کا Session ID خودبخود بنایا جاتا ہے اور محفوظ طریقے سے ذخیرہ کیا جاتا ہے۔ نوڈز خودبخود بلٹ-ان سیڈ نوڈز سے دریافت ہوتے ہیں۔';

  @override
  String get providerAdvanced => 'ایڈوانسڈ';

  @override
  String get providerSaveAndConnect => 'محفوظ کریں اور جڑیں';

  @override
  String get providerAddSecondaryInbox => 'ثانوی ان باکس شامل کریں';

  @override
  String get providerSecondaryInboxes => 'ثانوی ان باکسز';

  @override
  String get providerYourInboxProvider => 'آپ کا ان باکس فراہم کنندہ';

  @override
  String get providerConnectionDetails => 'کنکشن کی تفصیلات';

  @override
  String get addContactTitle => 'رابطہ شامل کریں';

  @override
  String get addContactInviteLinkLabel => 'دعوتی لنک یا پتہ';

  @override
  String get addContactTapToPaste => 'دعوتی لنک چسپاں کرنے کے لیے ٹیپ کریں';

  @override
  String get addContactPasteTooltip => 'کلپ بورڈ سے چسپاں کریں';

  @override
  String get addContactAddressDetected => 'رابطے کا پتہ پکڑا گیا';

  @override
  String addContactRoutesDetected(int count) {
    return '$count راستے پکڑے گئے — SmartRouter تیز ترین منتخب کرتا ہے';
  }

  @override
  String get addContactFetchingProfile => 'پروفائل حاصل ہو رہا ہے…';

  @override
  String addContactProfileFound(String name) {
    return 'ملا: $name';
  }

  @override
  String get addContactNoProfileFound => 'کوئی پروفائل نہیں ملا';

  @override
  String get addContactDisplayNameLabel => 'ظاہری نام';

  @override
  String get addContactDisplayNameHint => 'آپ انہیں کیا کہنا چاہتے ہیں؟';

  @override
  String get addContactAddManually => 'پتہ دستی طور پر شامل کریں';

  @override
  String get addContactButton => 'رابطہ شامل کریں';

  @override
  String get networkDiagnosticsTitle => 'نیٹ ورک تشخیص';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr ریلے';

  @override
  String get networkDiagnosticsDirect => 'براہ راست';

  @override
  String get networkDiagnosticsTorOnly => 'صرف Tor';

  @override
  String get networkDiagnosticsBest => 'بہترین';

  @override
  String get networkDiagnosticsNone => 'کوئی نہیں';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'حالت';

  @override
  String get networkDiagnosticsConnected => 'جڑا ہوا';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'جڑ رہا ہے $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'بند';

  @override
  String get networkDiagnosticsTransport => 'ٹرانسپورٹ';

  @override
  String get networkDiagnosticsInfrastructure => 'بنیادی ڈھانچہ';

  @override
  String get networkDiagnosticsSessionNodes => 'Session نوڈز';

  @override
  String get networkDiagnosticsTurnServers => 'TURN سرورز';

  @override
  String get networkDiagnosticsLastProbe => 'آخری پروب';

  @override
  String get networkDiagnosticsRunning => 'چل رہا ہے...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'تشخیص چلائیں';

  @override
  String get networkDiagnosticsForceReprobe => 'مکمل دوبارہ پروب کریں';

  @override
  String get networkDiagnosticsJustNow => 'ابھی ابھی';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes منٹ پہلے';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours گھنٹے پہلے';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days دن پہلے';
  }

  @override
  String get homeNoEch => 'ECH نہیں';

  @override
  String get homeNoEchTooltip =>
      'uTLS پراکسی دستیاب نہیں — ECH غیر فعال۔\nTLS فنگر پرنٹ DPI کو نظر آتا ہے۔';

  @override
  String get settingsTitle => 'ترتیبات';

  @override
  String settingsSavedConnectedTo(String provider) {
    return '$provider سے محفوظ اور جڑا ہوا';
  }

  @override
  String get settingsTorFailedToStart => 'بلٹ ان Tor شروع نہیں ہو سکا';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon شروع نہیں ہو سکا';

  @override
  String get verifyTitle => 'سیفٹی نمبر کی تصدیق کریں';

  @override
  String get verifyIdentityVerified => 'شناخت تصدیق شدہ';

  @override
  String get verifyNotYetVerified => 'ابھی تک تصدیق نہیں ہوئی';

  @override
  String verifyVerifiedDescription(String name) {
    return 'آپ نے $name کے سیفٹی نمبر کی تصدیق کر لی ہے۔';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'ان نمبروں کا $name سے ذاتی طور پر یا قابل اعتماد چینل پر موازنہ کریں۔';
  }

  @override
  String get verifyExplanation =>
      'ہر گفتگو کا ایک منفرد سیفٹی نمبر ہوتا ہے۔ اگر آپ دونوں اپنے آلات پر ایک ہی نمبر دیکھتے ہیں تو آپ کا کنکشن اینڈ ٹو اینڈ تصدیق شدہ ہے۔';

  @override
  String verifyContactKey(String name) {
    return '$name کی کلید';
  }

  @override
  String get verifyYourKey => 'آپ کی کلید';

  @override
  String get verifyRemoveVerification => 'تصدیق ہٹائیں';

  @override
  String get verifyMarkAsVerified => 'تصدیق شدہ کے طور پر نشان زد کریں';

  @override
  String verifyAfterReinstall(String name) {
    return 'اگر $name ایپ دوبارہ انسٹال کرتا ہے تو سیفٹی نمبر تبدیل ہو جائے گا اور تصدیق خودکار طور پر ہٹ جائے گی۔';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'صرف $name سے صوتی کال یا ذاتی طور پر نمبروں کا موازنہ کرنے کے بعد تصدیق شدہ کے طور پر نشان زد کریں۔';
  }

  @override
  String get verifyNoSession =>
      'ابھی تک کوئی انکرپشن سیشن قائم نہیں ہوا۔ سیفٹی نمبرز بنانے کے لیے پہلے ایک پیغام بھیجیں۔';

  @override
  String get verifyNoKeyAvailable => 'کوئی کلید دستیاب نہیں';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label فنگر پرنٹ کاپی ہو گیا';
  }

  @override
  String get providerDatabaseUrlLabel => 'ڈیٹابیس URL';

  @override
  String get providerOptionalHint => 'اختیاری';

  @override
  String get providerWebApiKeyLabel => 'Web API کلید';

  @override
  String get providerOptionalForPublicDb => 'عوامی ڈیٹابیس کے لیے اختیاری';

  @override
  String get providerRelayUrlLabel => 'ریلے URL';

  @override
  String get providerPrivateKeyLabel => 'نجی کلید';

  @override
  String get providerPrivateKeyNsecLabel => 'نجی کلید (nsec)';

  @override
  String get providerStorageNodeLabel => 'اسٹوریج نوڈ URL (اختیاری)';

  @override
  String get providerStorageNodeHint => 'بلٹ ان سیڈ نوڈز کے لیے خالی چھوڑیں';

  @override
  String get transferInvalidCodeFormat =>
      'نامعلوم کوڈ فارمیٹ — LAN: یا NOS: سے شروع ہونا چاہیے';

  @override
  String get profileCardFingerprintCopied => 'فنگر پرنٹ کاپی ہو گیا';

  @override
  String get profileCardAboutHint => 'رازداری سب سے پہلے 🔒';

  @override
  String get profileCardSaveButton => 'پروفائل محفوظ کریں';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'انکرپٹڈ پیغامات، رابطے اور اوتار فائل میں برآمد کریں';

  @override
  String get callVideo => 'ویڈیو';

  @override
  String get callAudio => 'آڈیو';

  @override
  String bubbleDeliveredTo(String names) {
    return '$names کو پہنچا دیا گیا';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return '$count کو پہنچا دیا گیا';
  }

  @override
  String get groupStatusDialogTitle => 'پیغام کی معلومات';

  @override
  String get groupStatusRead => 'پڑھا گیا';

  @override
  String get groupStatusDelivered => 'پہنچا دیا گیا';

  @override
  String get groupStatusPending => 'زیر التوا';

  @override
  String get groupStatusNoData => 'ابھی تک کوئی ترسیل کی معلومات نہیں';

  @override
  String get profileTransferAdmin => 'ایڈمن بنائیں';

  @override
  String profileTransferAdminConfirm(String name) {
    return '$name کو نیا ایڈمن بنائیں؟';
  }

  @override
  String get profileTransferAdminBody =>
      'آپ ایڈمن اختیارات کھو دیں گے۔ یہ واپس نہیں ہو سکتا۔';

  @override
  String profileTransferAdminDone(String name) {
    return '$name اب ایڈمن ہے';
  }

  @override
  String get profileAdminBadge => 'ایڈمن';

  @override
  String get privacyPolicyTitle => 'رازداری کی پالیسی';

  @override
  String get privacyOverviewHeading => 'جائزہ';

  @override
  String get privacyOverviewBody =>
      'Pulse ایک سرور لیس، اینڈ ٹو اینڈ انکرپٹڈ میسنجر ہے۔ آپ کی رازداری صرف ایک خصوصیت نہیں — یہ فن تعمیر ہے۔ کوئی Pulse سرورز نہیں ہیں۔ کوئی اکاؤنٹس کہیں محفوظ نہیں ہیں۔ ڈیولپرز کوئی ڈیٹا اکٹھا، منتقل یا محفوظ نہیں کرتے۔';

  @override
  String get privacyDataCollectionHeading => 'ڈیٹا اکٹھا کرنا';

  @override
  String get privacyDataCollectionBody =>
      'Pulse صفر ذاتی ڈیٹا اکٹھا کرتا ہے۔ خاص طور پر:\n\n- کوئی ای میل، فون نمبر، یا اصلی نام درکار نہیں\n- کوئی تجزیات، ٹریکنگ، یا ٹیلی میٹری نہیں\n- کوئی اشتہاری شناخت کنندے نہیں\n- رابطہ فہرست تک کوئی رسائی نہیں\n- کوئی کلاؤڈ بیک اپ نہیں (پیغامات صرف آپ کے آلے پر موجود ہیں)\n- کوئی میٹا ڈیٹا کسی Pulse سرور کو نہیں بھیجا جاتا (کوئی ہے ہی نہیں)';

  @override
  String get privacyEncryptionHeading => 'انکرپشن';

  @override
  String get privacyEncryptionBody =>
      'تمام پیغامات Signal پروٹوکول (X3DH کلیدی معاہدے کے ساتھ Double Ratchet) سے انکرپٹ ہوتے ہیں۔ انکرپشن کلیدیں خصوصی طور پر آپ کے آلے پر بنائی اور محفوظ کی جاتی ہیں۔ کوئی بھی — ڈیولپرز بھی — آپ کے پیغامات نہیں پڑھ سکتا۔';

  @override
  String get privacyNetworkHeading => 'نیٹ ورک فن تعمیر';

  @override
  String get privacyNetworkBody =>
      'Pulse فیڈریٹڈ ٹرانسپورٹ اڈاپٹرز (Nostr ریلے، Session/Oxen سروس نوڈز، Firebase Realtime Database، LAN) استعمال کرتا ہے۔ یہ ٹرانسپورٹس صرف انکرپٹڈ سائفر ٹیکسٹ لے کر جاتے ہیں۔ ریلے آپریٹرز آپ کا IP پتہ اور ٹریفک حجم دیکھ سکتے ہیں، لیکن پیغام مواد ڈکرپٹ نہیں کر سکتے۔\n\nجب Tor فعال ہو تو آپ کا IP پتہ ریلے آپریٹرز سے بھی پوشیدہ رہتا ہے۔';

  @override
  String get privacyStunHeading => 'STUN/TURN سرورز';

  @override
  String get privacyStunBody =>
      'صوتی اور ویڈیو کالز DTLS-SRTP انکرپشن کے ساتھ WebRTC استعمال کرتی ہیں۔ STUN سرورز (پیئر ٹو پیئر کنکشنز کے لیے آپ کا عوامی IP دریافت کرنے کے لیے) اور TURN سرورز (براہ راست کنکشن ناکام ہونے پر میڈیا ریلے کرنے کے لیے) آپ کا IP پتہ اور کال مدت دیکھ سکتے ہیں، لیکن کال مواد ڈکرپٹ نہیں کر سکتے۔\n\nآپ زیادہ سے زیادہ رازداری کے لیے ترتیبات میں اپنا TURN سرور ترتیب دے سکتے ہیں۔';

  @override
  String get privacyCrashHeading => 'کریش رپورٹنگ';

  @override
  String get privacyCrashBody =>
      'اگر Sentry کریش رپورٹنگ فعال ہو (بلڈ ٹائم SENTRY_DSN کے ذریعے) تو گمنام کریش رپورٹس بھیجی جا سکتی ہیں۔ ان میں کوئی پیغام مواد، کوئی رابطہ معلومات، اور کوئی ذاتی طور پر قابل شناخت معلومات نہیں ہوتیں۔ DSN کو ہٹا کر بلڈ ٹائم پر کریش رپورٹنگ غیر فعال کی جا سکتی ہے۔';

  @override
  String get privacyPasswordHeading => 'پاس ورڈ اور کلیدیں';

  @override
  String get privacyPasswordBody =>
      'آپ کا بازیابی پاس ورڈ Argon2id (میموری ہارڈ KDF) کے ذریعے خفیہ کلیدیں اخذ کرنے کے لیے استعمال ہوتا ہے۔ پاس ورڈ کبھی کہیں منتقل نہیں ہوتا۔ اگر آپ اپنا پاس ورڈ کھو دیں تو آپ کا اکاؤنٹ بحال نہیں ہو سکتا — اسے ری سیٹ کرنے کے لیے کوئی سرور نہیں ہے۔';

  @override
  String get privacyFontsHeading => 'فانٹس';

  @override
  String get privacyFontsBody =>
      'Pulse تمام فانٹس مقامی طور پر بنڈل کرتا ہے۔ Google Fonts یا کسی خارجی فانٹ سروس کو کوئی درخواستیں نہیں بھیجی جاتیں۔';

  @override
  String get privacyThirdPartyHeading => 'فریق ثالث خدمات';

  @override
  String get privacyThirdPartyBody =>
      'Pulse کسی بھی اشتہاری نیٹ ورکس، تجزیاتی فراہم کنندگان، سوشل میڈیا پلیٹ فارمز، یا ڈیٹا بروکرز سے مربوط نہیں ہے۔ صرف نیٹ ورک کنکشنز وہ ٹرانسپورٹ ریلے ہیں جو آپ ترتیب دیتے ہیں۔';

  @override
  String get privacyOpenSourceHeading => 'اوپن سورس';

  @override
  String get privacyOpenSourceBody =>
      'Pulse اوپن سورس سافٹ ویئر ہے۔ آپ ان رازداری کے دعووں کی تصدیق کے لیے مکمل سورس کوڈ کا معائنہ کر سکتے ہیں۔';

  @override
  String get privacyContactHeading => 'رابطہ';

  @override
  String get privacyContactBody =>
      'رازداری سے متعلق سوالات کے لیے پراجیکٹ ریپوزٹری پر ایشو کھولیں۔';

  @override
  String get privacyLastUpdated => 'آخری تازہ کاری: مارچ 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'محفوظ کرنا ناکام: $error';
  }

  @override
  String get themeEngineTitle => 'تھیم انجن';

  @override
  String get torBuiltInTitle => 'بلٹ ان Tor';

  @override
  String get torConnectedSubtitle =>
      'جڑا ہوا — Nostr 127.0.0.1:9250 سے روٹ ہو رہا ہے';

  @override
  String torConnectingSubtitle(int pct) {
    return 'جڑ رہا ہے… $pct%';
  }

  @override
  String get torNotRunning =>
      'نہیں چل رہا — دوبارہ شروع کرنے کے لیے سوئچ ٹیپ کریں';

  @override
  String get torDescription =>
      'Nostr کو Tor سے روٹ کرتا ہے (سنسر شدہ نیٹ ورکس کے لیے Snowflake)';

  @override
  String get torNetworkDiagnostics => 'نیٹ ورک تشخیص';

  @override
  String get torTransportLabel => 'ٹرانسپورٹ: ';

  @override
  String get torPtAuto => 'آٹو';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'سادہ';

  @override
  String get torTimeoutLabel => 'ٹائم آؤٹ: ';

  @override
  String get torInfoDescription =>
      'فعال ہونے پر Nostr WebSocket کنکشنز Tor (SOCKS5) سے روٹ ہوتے ہیں۔ Tor Browser 127.0.0.1:9150 پر سنتا ہے۔ اسٹینڈ الون tor ڈیمن پورٹ 9050 استعمال کرتا ہے۔ Firebase کنکشنز متاثر نہیں ہوتے۔';

  @override
  String get torRouteNostrTitle => 'Nostr کو Tor سے روٹ کریں';

  @override
  String get torManagedByBuiltin => 'بلٹ ان Tor کے زیر انتظام';

  @override
  String get torActiveRouting => 'فعال — Nostr ٹریفک Tor سے روٹ ہو رہی ہے';

  @override
  String get torDisabled => 'غیر فعال';

  @override
  String get torProxySocks5 => 'Tor پراکسی (SOCKS5)';

  @override
  String get torProxyHostLabel => 'پراکسی ہوسٹ';

  @override
  String get torProxyPortLabel => 'پورٹ';

  @override
  String get torPortInfo => 'Tor Browser: پورٹ 9150  •  tor ڈیمن: پورٹ 9050';

  @override
  String get torForceNostrTitle => 'پیغامات Tor کے ذریعے بھیجیں';

  @override
  String get torForceNostrSubtitle =>
      'تمام Nostr relay کنکشنز Tor سے گزریں گے۔ سست لیکن relay سے آپ کا IP چھپاتا ہے۔';

  @override
  String get torForceNostrDisabled => 'پہلے Tor فعال ہونا ضروری ہے';

  @override
  String get torForcePulseTitle => 'Pulse relay کو Tor کے ذریعے بھیجیں';

  @override
  String get torForcePulseSubtitle =>
      'تمام Pulse relay کنکشنز Tor سے گزریں گے۔ سست لیکن سرور سے آپ کا IP چھپاتا ہے۔';

  @override
  String get torForcePulseDisabled => 'پہلے Tor فعال ہونا ضروری ہے';

  @override
  String get i2pProxySocks5 => 'I2P پراکسی (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P بطور ڈیفالٹ پورٹ 4447 پر SOCKS5 استعمال کرتا ہے۔ کسی بھی ٹرانسپورٹ کے صارفین سے بات کرنے کے لیے I2P آؤٹ پراکسی (مثلاً relay.damus.i2p) کے ذریعے Nostr ریلے سے جڑیں۔ دونوں فعال ہونے پر Tor کو ترجیح ملتی ہے۔';

  @override
  String get i2pRouteNostrTitle => 'Nostr کو I2P سے روٹ کریں';

  @override
  String get i2pActiveRouting => 'فعال — Nostr ٹریفک I2P سے روٹ ہو رہی ہے';

  @override
  String get i2pDisabled => 'غیر فعال';

  @override
  String get i2pProxyHostLabel => 'پراکسی ہوسٹ';

  @override
  String get i2pProxyPortLabel => 'پورٹ';

  @override
  String get i2pPortInfo => 'I2P راؤٹر ڈیفالٹ SOCKS5 پورٹ: 4447';

  @override
  String get customProxySocks5 => 'حسب ضرورت پراکسی (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker ریلے';

  @override
  String get customProxyInfoDescription =>
      'حسب ضرورت پراکسی ٹریفک آپ کے V2Ray/Xray/Shadowsocks سے روٹ کرتی ہے۔ CF Worker Cloudflare CDN پر ذاتی ریلے پراکسی کے طور پر کام کرتا ہے — GFW *.workers.dev دیکھتا ہے، اصل ریلے نہیں۔';

  @override
  String get customSocks5ProxyTitle => 'حسب ضرورت SOCKS5 پراکسی';

  @override
  String get customProxyActive => 'فعال — ٹریفک SOCKS5 سے روٹ ہو رہی ہے';

  @override
  String get customProxyDisabled => 'غیر فعال';

  @override
  String get customProxyHostLabel => 'پراکسی ہوسٹ';

  @override
  String get customProxyPortLabel => 'پورٹ';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker ڈومین (اختیاری)';

  @override
  String get customWorkerHelpTitle => 'CF Worker ریلے کیسے ڈیپلائے کریں (مفت)';

  @override
  String get customWorkerScriptCopied => 'اسکرپٹ کاپی ہو گیا!';

  @override
  String get customWorkerStep1 =>
      '1. dash.cloudflare.com → Workers & Pages پر جائیں\n2. Create Worker → یہ اسکرپٹ چسپاں کریں:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → ڈومین کاپی کریں (مثلاً my-relay.user.workers.dev)\n4. اوپر ڈومین چسپاں کریں → محفوظ کریں\n\nایپ خودکار جڑتی ہے: wss://domain/?r=relay_url\nGFW دیکھتا ہے: *.workers.dev (CF CDN) سے کنکشن';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'جڑا ہوا — SOCKS5 127.0.0.1:$port پر';
  }

  @override
  String get psiphonConnecting => 'جڑ رہا ہے…';

  @override
  String get psiphonNotRunning =>
      'نہیں چل رہا — دوبارہ شروع کرنے کے لیے سوئچ ٹیپ کریں';

  @override
  String get psiphonDescription =>
      'تیز ٹنل (~3 سیکنڈ بوٹسٹریپ، 2000+ گھومنے والے VPS)';

  @override
  String get turnCommunityServers => 'کمیونٹی TURN سرورز';

  @override
  String get turnCustomServer => 'حسب ضرورت TURN سرور (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN سرورز صرف پہلے سے انکرپٹ شدہ اسٹریمز (DTLS-SRTP) ریلے کرتے ہیں۔ ریلے آپریٹر آپ کا IP اور ٹریفک حجم دیکھ سکتا ہے، لیکن کالز ڈکرپٹ نہیں کر سکتا۔ TURN صرف اس وقت استعمال ہوتا ہے جب براہ راست P2P ناکام ہو (~15–20% کنکشنز)۔';

  @override
  String get turnFreeLabel => 'مفت';

  @override
  String get turnServerUrlLabel => 'TURN سرور URL';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 یا turns:...';

  @override
  String get turnUsernameLabel => 'صارف نام';

  @override
  String get turnPasswordLabel => 'پاس ورڈ';

  @override
  String get turnOptionalHint => 'اختیاری';

  @override
  String get turnCustomInfo =>
      'زیادہ سے زیادہ کنٹرول کے لیے کسی بھی \$5/ماہ VPS پر coturn چلائیں۔ اسناد مقامی طور پر محفوظ ہوتی ہیں۔';

  @override
  String get themePickerAppearance => 'ظاہری شکل';

  @override
  String get themePickerAccentColor => 'ایکسنٹ رنگ';

  @override
  String get themeModeLight => 'ہلکا';

  @override
  String get themeModeDark => 'گہرا';

  @override
  String get themeModeSystem => 'سسٹم';

  @override
  String get themeDynamicPresets => 'پری سیٹس';

  @override
  String get themeDynamicPrimaryColor => 'بنیادی رنگ';

  @override
  String get themeDynamicBorderRadius => 'بارڈر ریڈیئس';

  @override
  String get themeDynamicFont => 'فانٹ';

  @override
  String get themeDynamicAppearance => 'ظاہری شکل';

  @override
  String get themeDynamicUiStyle => 'UI طرز';

  @override
  String get themeDynamicUiStyleDescription =>
      'ڈائیلاگز، سوئچز اور اشاریوں کی شکل کنٹرول کرتا ہے۔';

  @override
  String get themeDynamicSharp => 'تیز';

  @override
  String get themeDynamicRound => 'گول';

  @override
  String get themeDynamicModeDark => 'گہرا';

  @override
  String get themeDynamicModeLight => 'ہلکا';

  @override
  String get themeDynamicModeAuto => 'آٹو';

  @override
  String get themeDynamicPlatformAuto => 'آٹو';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'غلط Firebase URL۔ متوقع: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'غلط ریلے URL۔ متوقع: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'غلط Pulse سرور URL۔ متوقع: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'سرور URL';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'دعوتی کوڈ';

  @override
  String get providerPulseInviteHint => 'دعوتی کوڈ (اگر درکار ہو)';

  @override
  String get providerPulseInfo =>
      'سیلف ہوسٹڈ ریلے۔ آپ کے بازیابی پاس ورڈ سے کلیدیں اخذ کی گئیں۔';

  @override
  String get providerScreenTitle => 'ان باکسز';

  @override
  String get providerSecondaryInboxesHeader => 'ثانوی ان باکسز';

  @override
  String get providerSecondaryInboxesInfo =>
      'ثانوی ان باکسز بیک وقت پیغامات وصول کرتے ہیں ریڈنڈنسی کے لیے۔';

  @override
  String get providerRemoveTooltip => 'ہٹائیں';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... یا hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... یا hex نجی کلید';

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
  String get emojiNoRecent => 'کوئی حالیہ ایموجی نہیں';

  @override
  String get emojiSearchHint => 'ایموجی تلاش کریں...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'چیٹ کے لیے ٹیپ کریں';

  @override
  String get imageViewerSaveToDownloads => 'ڈاؤن لوڈز میں محفوظ کریں';

  @override
  String imageViewerSavedTo(String path) {
    return '$path میں محفوظ ہو گیا';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'ٹھیک ہے';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get settingsLanguageSubtitle => 'ایپ کی ظاہری زبان';

  @override
  String get settingsLanguageSystem => 'سسٹم ڈیفالٹ';

  @override
  String get onboardingLanguageTitle => 'اپنی زبان منتخب کریں';

  @override
  String get onboardingLanguageSubtitle =>
      'آپ بعد میں ترتیبات سے تبدیل کر سکتے ہیں';

  @override
  String get videoNoteRecord => 'ویڈیو پیغام ریکارڈ کریں';

  @override
  String get videoNoteTapToRecord => 'ریکارڈ کرنے کے لیے ٹیپ کریں';

  @override
  String get videoNoteTapToStop => 'روکنے کے لیے ٹیپ کریں';

  @override
  String get videoNoteCameraPermission => 'کیمرے کی اجازت سے انکار';

  @override
  String get videoNoteMaxDuration => 'زیادہ سے زیادہ 30 سیکنڈ';

  @override
  String get videoNoteNotSupported =>
      'اس پلیٹ فارم پر ویڈیو نوٹس سپورٹ نہیں ہیں';

  @override
  String get navChats => 'چیٹس';

  @override
  String get navUpdates => 'اپ ڈیٹس';

  @override
  String get navCalls => 'کالز';

  @override
  String get filterAll => 'سب';

  @override
  String get filterUnread => 'غیر پڑھا';

  @override
  String get filterGroups => 'گروپس';

  @override
  String get callsNoRecent => 'کوئی حالیہ کال نہیں';

  @override
  String get callsEmptySubtitle => 'آپ کی کال ہسٹری یہاں ظاہر ہوگی';

  @override
  String get appBarEncrypted => 'اینڈ-ٹو-اینڈ انکرپٹڈ';

  @override
  String get newStatus => 'نیا اسٹیٹس';

  @override
  String get newCall => 'نئی کال';

  @override
  String get joinChannelTitle => 'چینل میں شامل ہوں';

  @override
  String get joinChannelDescription => 'چینل URL';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'چینل کی معلومات حاصل ہو رہی ہیں…';

  @override
  String get joinChannelNotFound => 'اس URL پر کوئی چینل نہیں ملا';

  @override
  String get joinChannelNetworkError => 'سرور سے رابطہ نہیں ہو سکا';

  @override
  String get joinChannelAlreadyJoined => 'پہلے سے شامل';

  @override
  String get joinChannelButton => 'شامل ہوں';

  @override
  String get channelFeedEmpty => 'ابھی تک کوئی پوسٹ نہیں';

  @override
  String get channelLeave => 'چینل چھوڑیں';

  @override
  String get channelLeaveConfirm =>
      'یہ چینل چھوڑیں؟ محفوظ پوسٹس حذف ہو جائیں گی۔';

  @override
  String get channelInfo => 'چینل کی معلومات';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'ترمیم شدہ';

  @override
  String get channelLoadMore => 'مزید لوڈ کریں';

  @override
  String get channelSearchPosts => 'پوسٹس تلاش کریں…';

  @override
  String get channelNoResults => 'کوئی ملتی جلتی پوسٹ نهیں';

  @override
  String get channelUrl => 'چینل URL';

  @override
  String get channelCreated => 'شامل ہوئے';

  @override
  String channelPostCount(int count) {
    return '$count پوسٹس';
  }

  @override
  String get channelCopyUrl => 'URL کاپی کریں';

  @override
  String get setupNext => 'اگلا';

  @override
  String get setupKeyWarning =>
      'A recovery key will be generated for you. It is the only way to restore your account on a new device — there is no server, no password reset.';

  @override
  String get setupKeyTitle => 'Your Recovery Key';

  @override
  String get setupKeySubtitle =>
      'Write this key down and store it in a safe place. You will need it to restore your account on a new device.';

  @override
  String get setupKeyCopied => 'کاپی ہوگیا!';

  @override
  String get setupKeyWroteItDown => 'میں نے لکھ لیا';

  @override
  String get setupKeyWarnBody =>
      'Write this key down as a backup. You can also view it later in Settings → Security.';

  @override
  String get setupVerifyTitle => 'Verify Recovery Key';

  @override
  String get setupVerifySubtitle =>
      'Re-enter your recovery key to confirm you saved it correctly.';

  @override
  String get setupVerifyButton => 'تصدیق';

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
  String get settingsViewRecoveryKey => 'ریکوری کلید دیکھیں';

  @override
  String get settingsViewRecoveryKeySubtitle =>
      'اپنے اکاؤنٹ کی ریکوری کلید دکھائیں';

  @override
  String get settingsRecoveryKeyNotStored =>
      'ریکوری کلید دستیاب نہیں (اس فیچر سے پہلے بنائی گئی)';

  @override
  String get settingsRecoveryKeyWarning =>
      'اس کلید کو محفوظ رکھیں۔ جس کے پاس بھی یہ ہو وہ دوسرے آلے پر آپ کا اکاؤنٹ بحال کر سکتا ہے۔';

  @override
  String get replaceIdentityTitle => 'موجودہ شناخت تبدیل کریں؟';

  @override
  String get replaceIdentityBodyRestore =>
      'اس آلے پر پہلے سے ایک شناخت موجود ہے۔ بحال کرنے سے آپ کی موجودہ Nostr کلید اور Oxen سیڈ مستقل طور پر تبدیل ہو جائے گی۔ تمام رابطے آپ کے موجودہ پتے تک رسائی کھو دیں گے۔\n\nیہ واپس نہیں کیا جا سکتا۔';

  @override
  String get replaceIdentityBodyCreate =>
      'اس آلے پر پہلے سے ایک شناخت موجود ہے۔ نئی بنانے سے آپ کی موجودہ Nostr کلید اور Oxen سیڈ مستقل طور پر تبدیل ہو جائے گی۔ تمام رابطے آپ کے موجودہ پتے تک رسائی کھو دیں گے۔\n\nیہ واپس نہیں کیا جا سکتا۔';

  @override
  String get replace => 'تبدیل کریں';

  @override
  String get callNoScreenSources => 'اسکرین کے ذرائع دستیاب نہیں';

  @override
  String get callScreenShareQuality => 'اسکرین شیئرنگ کوالٹی';

  @override
  String get callFrameRate => 'فریم ریٹ';

  @override
  String get callResolution => 'ریزولیوشن';

  @override
  String get callAutoResolution => 'خودکار = اسکرین کی اصل ریزولیوشن';

  @override
  String get callStartSharing => 'شیئرنگ شروع کریں';

  @override
  String get callCameraUnavailable =>
      'کیمرا دستیاب نہیں — شاید کسی اور ایپ میں استعمال ہو رہا ہے';

  @override
  String get themeResetToDefaults => 'ڈیفالٹ پر ری سیٹ کریں';

  @override
  String get backupSaveToDownloadsTitle => 'بیک اپ ڈاؤن لوڈز میں محفوظ کریں؟';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'فائل پکر دستیاب نہیں۔ بیک اپ یہاں محفوظ ہوگا:\n$path';
  }

  @override
  String get systemLabel => 'سسٹم';

  @override
  String get next => 'اگلا';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return 'ڈویلپر موڈ فعال کرنے کے لیے مزید $remaining ٹیپ';
  }

  @override
  String get devModeEnabled => 'ڈویلپر موڈ فعال ہو گیا';

  @override
  String get devTools => 'ڈویلپر ٹولز';

  @override
  String get devAdapterDiagnostics => 'اڈاپٹر ٹوگلز اور تشخیص';

  @override
  String get devEnableAll => 'سب فعال کریں';

  @override
  String get devDisableAll => 'سب غیر فعال کریں';

  @override
  String get turnUrlValidation =>
      'TURN URL کو turn: یا turns: سے شروع ہونا چاہیے (زیادہ سے زیادہ 512 حروف)';

  @override
  String get callMissedCall => 'چھوٹی ہوئی کال';

  @override
  String get callOutgoingCall => 'جانے والی کال';

  @override
  String get callIncomingCall => 'آنے والی کال';

  @override
  String get mediaMissingData => 'میڈیا ڈیٹا غائب ہے';

  @override
  String get mediaDownloadFailed => 'ڈاؤن لوڈ ناکام';

  @override
  String get mediaDecryptFailed => 'ڈکرپٹ ناکام';

  @override
  String get callEndCallBanner => 'کال ختم کریں';

  @override
  String get meFallback => 'میں';

  @override
  String get imageSaveToDownloads => 'ڈاؤن لوڈز میں محفوظ کریں';

  @override
  String imageSavedToPath(String path) {
    return '$path میں محفوظ ہو گیا';
  }

  @override
  String get callScreenShareRequiresPermission =>
      'اسکرین شیئرنگ کے لیے اجازت درکار ہے';

  @override
  String get callScreenShareUnavailable => 'اسکرین شیئرنگ دستیاب نہیں';

  @override
  String get statusJustNow => 'ابھی ابھی';

  @override
  String statusMinutesAgo(int minutes) {
    return '$minutes منٹ پہلے';
  }

  @override
  String statusHoursAgo(int hours) {
    return '$hours گھنٹے پہلے';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count راستے',
      one: '1 راستہ',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => 'شامل کرنے کے لیے تیار';

  @override
  String groupSelectedCount(int count) {
    return '$count منتخب';
  }

  @override
  String get paste => 'پیسٹ کریں';

  @override
  String get sfuAudioOnly => 'صرف آڈیو';

  @override
  String sfuParticipants(int count) {
    return '$count شرکاء';
  }

  @override
  String get dataUnencryptedBackup => 'غیر خفیہ بیک اپ';

  @override
  String get dataUnencryptedBackupBody =>
      'یہ فائل ایک غیر خفیہ شناخت بیک اپ ہے اور آپ کی موجودہ کلیدوں کو اوور رائٹ کر دے گی۔ صرف وہ فائلیں درآمد کریں جو آپ نے خود بنائی ہیں۔ جاری رکھیں؟';

  @override
  String get dataImportAnyway => 'پھر بھی درآمد کریں';

  @override
  String get securityStorageError =>
      'سیکیورٹی اسٹوریج ایرر — ایپ دوبارہ شروع کریں';

  @override
  String get aboutDevModeActive => 'ڈویلپر موڈ فعال ہے';

  @override
  String get themeColors => 'رنگ';

  @override
  String get themePrimaryAccent => 'بنیادی ایکسنٹ';

  @override
  String get themeSecondaryAccent => 'ثانوی ایکسنٹ';

  @override
  String get themeBackground => 'پس منظر';

  @override
  String get themeSurface => 'سطح';

  @override
  String get themeChatBubbles => 'چیٹ ببلز';

  @override
  String get themeOutgoingMessage => 'جانے والا پیغام';

  @override
  String get themeIncomingMessage => 'آنے والا پیغام';

  @override
  String get themeShape => 'شکل';

  @override
  String get devSectionDeveloper => 'ڈویلپر';

  @override
  String get devAdapterChannelsHint =>
      'اڈاپٹر چینلز — مخصوص ٹرانسپورٹ ٹیسٹ کرنے کے لیے غیر فعال کریں۔';

  @override
  String get devNostrRelays => 'Nostr relays (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Session نیٹ ورک';

  @override
  String get devPulseRelay => 'Pulse سیلف ہوسٹڈ relay';

  @override
  String get devLanNetwork => 'مقامی نیٹ ورک (UDP/TCP)';

  @override
  String get devSectionCalls => 'کالز';

  @override
  String get devForceTurnRelay => 'TURN relay زبردستی استعمال کریں';

  @override
  String get devForceTurnRelaySubtitle =>
      'P2P غیر فعال کریں — تمام کالز صرف TURN سرورز کے ذریعے';

  @override
  String get devRestartWarning =>
      '⚠ تبدیلیاں اگلی بھیجنے/کال پر لاگو ہوں گی۔ آنے والی کالز کے لیے ایپ دوبارہ شروع کریں۔';

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
  String get pulseUseServerTitle => 'کیا Pulse سرور استعمال کرنا ہے؟';

  @override
  String pulseUseServerBody(String name, String host) {
    return '$name Pulse سرور $host استعمال کرتا ہے۔ ان سے (اور اسی سرور پر دوسروں سے) تیز تر بات چیت کے لیے شامل ہوں؟';
  }

  @override
  String pulseContactUsesPulse(String name) {
    return '$name Pulse استعمال کر رہا ہے';
  }

  @override
  String pulseJoinForFaster(String host) {
    return 'تیز تر چیٹ کے لیے $host میں شامل ہوں';
  }

  @override
  String get pulseNotNow => 'ابھی نہیں';

  @override
  String get pulseJoin => 'شامل ہوں';

  @override
  String get pulseDismiss => 'بند کریں';

  @override
  String get pulseHide7Days => '7 دن کے لیے چھپائیں';

  @override
  String get pulseNeverAskAgain => 'دوبارہ نہ پوچھیں';

  @override
  String get groupSearchContactsHint => 'رابطے تلاش کریں…';

  @override
  String get systemActorYou => 'آپ';

  @override
  String get systemActorPeer => 'رابطہ';

  @override
  String systemTtlEnabled(String actor, String duration) {
    return '$actor نے غائب ہونے والے پیغامات کو فعال کر دیا: $duration';
  }

  @override
  String systemTtlDisabled(String actor) {
    return '$actor نے غائب ہونے والے پیغامات کو غیر فعال کر دیا';
  }

  @override
  String get menuClearChatHistory => 'چیٹ کی تاریخ صاف کریں';

  @override
  String get clearChatTitle => 'چیٹ کی تاریخ صاف کریں؟';

  @override
  String get clearChatBody =>
      'اس چیٹ کے تمام پیغامات اس ڈیوائس سے حذف ہو جائیں گے۔ دوسرا شخص اپنی کاپی برقرار رکھے گا۔';

  @override
  String get clearChatAction => 'صاف کریں';
}
