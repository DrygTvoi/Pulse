// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'جستجوی پیام‌ها...';

  @override
  String get search => 'جستجو';

  @override
  String get clearSearch => 'پاک کردن جستجو';

  @override
  String get closeSearch => 'بستن جستجو';

  @override
  String get moreOptions => 'گزینه‌های بیشتر';

  @override
  String get back => 'بازگشت';

  @override
  String get cancel => 'لغو';

  @override
  String get close => 'بستن';

  @override
  String get confirm => 'تأیید';

  @override
  String get remove => 'حذف';

  @override
  String get save => 'ذخیره';

  @override
  String get add => 'افزودن';

  @override
  String get copy => 'کپی';

  @override
  String get skip => 'رد شدن';

  @override
  String get done => 'انجام شد';

  @override
  String get apply => 'اعمال';

  @override
  String get export => 'خروجی';

  @override
  String get import => 'ورودی';

  @override
  String get homeNewGroup => 'گروه جدید';

  @override
  String get homeSettings => 'تنظیمات';

  @override
  String get homeSearching => 'در حال جستجوی پیام‌ها...';

  @override
  String get homeNoResults => 'نتیجه‌ای یافت نشد';

  @override
  String get homeNoChatHistory => 'هنوز تاریخچه گفتگویی وجود ندارد';

  @override
  String homeTransportSwitched(String address) {
    return 'انتقال تغییر کرد → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name در حال تماس است...';
  }

  @override
  String get homeAccept => 'پذیرش';

  @override
  String get homeDecline => 'رد کردن';

  @override
  String get homeLoadEarlier => 'بارگذاری پیام‌های قبلی';

  @override
  String get homeChats => 'گفتگوها';

  @override
  String get homeSelectConversation => 'یک مکالمه را انتخاب کنید';

  @override
  String get homeNoChatsYet => 'هنوز گفتگویی وجود ندارد';

  @override
  String get homeAddContactToStart => 'یک مخاطب اضافه کنید تا گفتگو شروع شود';

  @override
  String get homeNewChat => 'گفتگوی جدید';

  @override
  String get homeNewChatTooltip => 'گفتگوی جدید';

  @override
  String get homeIncomingCallTitle => 'تماس ورودی';

  @override
  String get homeIncomingGroupCallTitle => 'تماس گروهی ورودی';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — تماس گروهی ورودی';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'گفتگویی مطابق با \"$query\" یافت نشد';
  }

  @override
  String get homeSectionChats => 'گفتگوها';

  @override
  String get homeSectionMessages => 'پیام‌ها';

  @override
  String get homeDbEncryptionUnavailable =>
      'رمزگذاری پایگاه داده در دسترس نیست — برای حفاظت کامل SQLCipher را نصب کنید';

  @override
  String get chatFileTooLargeGroup =>
      'فایل‌های بیش از 512 کیلوبایت در گفتگوهای گروهی پشتیبانی نمی‌شوند';

  @override
  String get chatLargeFile => 'فایل بزرگ';

  @override
  String get chatCancel => 'لغو';

  @override
  String get chatSend => 'ارسال';

  @override
  String get chatFileTooLarge =>
      'فایل بیش از حد بزرگ است — حداکثر اندازه 100 مگابایت';

  @override
  String get chatMicDenied => 'دسترسی به میکروفون رد شد';

  @override
  String get chatVoiceFailed =>
      'ذخیره پیام صوتی ناموفق بود — فضای ذخیره‌سازی را بررسی کنید';

  @override
  String get chatScheduleFuture => 'زمان برنامه‌ریزی‌شده باید در آینده باشد';

  @override
  String get chatToday => 'امروز';

  @override
  String get chatYesterday => 'دیروز';

  @override
  String get chatEdited => 'ویرایش‌شده';

  @override
  String get chatYou => 'شما';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'اندازه این فایل $size مگابایت است. ارسال فایل‌های بزرگ ممکن است در برخی شبکه‌ها کند باشد. ادامه می‌دهید؟';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'کلید امنیتی $name تغییر کرد. برای تأیید ضربه بزنید.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'رمزگذاری پیام برای $name ناموفق بود — پیام ارسال نشد.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'شماره امنیتی $name تغییر کرد. برای تأیید ضربه بزنید.';
  }

  @override
  String get chatNoMessagesFound => 'پیامی یافت نشد';

  @override
  String get chatMessagesE2ee => 'پیام‌ها رمزگذاری سرتاسری شده‌اند';

  @override
  String get chatSayHello => 'سلام بگویید';

  @override
  String get appBarOnline => 'آنلاین';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'در حال نوشتن';

  @override
  String get appBarSearchMessages => 'جستجوی پیام‌ها...';

  @override
  String get appBarMute => 'بی‌صدا';

  @override
  String get appBarUnmute => 'صدادار';

  @override
  String get appBarMedia => 'رسانه';

  @override
  String get appBarDisappearing => 'پیام‌های ناپدیدشونده';

  @override
  String get appBarDisappearingOn => 'ناپدیدشونده: فعال';

  @override
  String get appBarGroupSettings => 'تنظیمات گروه';

  @override
  String get appBarSearchTooltip => 'جستجوی پیام‌ها';

  @override
  String get appBarVoiceCall => 'تماس صوتی';

  @override
  String get appBarVideoCall => 'تماس تصویری';

  @override
  String get inputMessage => 'پیام...';

  @override
  String get inputAttachFile => 'پیوست فایل';

  @override
  String get inputSendMessage => 'ارسال پیام';

  @override
  String get inputRecordVoice => 'ضبط پیام صوتی';

  @override
  String get inputSendVoice => 'ارسال پیام صوتی';

  @override
  String get inputCancelReply => 'لغو پاسخ';

  @override
  String get inputCancelEdit => 'لغو ویرایش';

  @override
  String get inputCancelRecording => 'لغو ضبط';

  @override
  String get inputRecording => 'در حال ضبط…';

  @override
  String get inputEditingMessage => 'ویرایش پیام';

  @override
  String get inputPhoto => 'عکس';

  @override
  String get inputVoiceMessage => 'پیام صوتی';

  @override
  String get inputFile => 'فایل';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count پیام برنامه‌ریزی‌شده$_temp0';
  }

  @override
  String get callInitializing => 'در حال آغاز تماس…';

  @override
  String get callConnecting => 'در حال اتصال…';

  @override
  String get callConnectingRelay => 'در حال اتصال (رله)…';

  @override
  String get callSwitchingRelay => 'تغییر به حالت رله…';

  @override
  String get callConnectionFailed => 'اتصال ناموفق بود';

  @override
  String get callReconnecting => 'اتصال مجدد…';

  @override
  String get callEnded => 'تماس پایان یافت';

  @override
  String get callLive => 'زنده';

  @override
  String get callEnd => 'پایان';

  @override
  String get callEndCall => 'پایان تماس';

  @override
  String get callMute => 'بی‌صدا';

  @override
  String get callUnmute => 'صدادار';

  @override
  String get callSpeaker => 'بلندگو';

  @override
  String get callCameraOn => 'دوربین روشن';

  @override
  String get callCameraOff => 'دوربین خاموش';

  @override
  String get callShareScreen => 'اشتراک صفحه';

  @override
  String get callStopShare => 'توقف اشتراک';

  @override
  String callTorBackup(String duration) {
    return 'پشتیبان Tor · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'پشتیبان Tor فعال — مسیر اصلی در دسترس نیست';

  @override
  String get callDirectFailed => 'اتصال مستقیم ناموفق بود — تغییر به حالت رله…';

  @override
  String get callTurnUnreachable =>
      'سرورهای TURN در دسترس نیستند. یک TURN سفارشی در تنظیمات → پیشرفته اضافه کنید.';

  @override
  String get callRelayMode => 'حالت رله فعال (شبکه محدود)';

  @override
  String get callStarting => 'شروع تماس…';

  @override
  String get callConnectingToGroup => 'اتصال به گروه…';

  @override
  String get callGroupOpenedInBrowser => 'تماس گروهی در مرورگر باز شد';

  @override
  String get callCouldNotOpenBrowser => 'باز کردن مرورگر ممکن نبود';

  @override
  String get callInviteLinkSent => 'لینک دعوت به همه اعضای گروه ارسال شد.';

  @override
  String get callOpenLinkManually =>
      'لینک بالا را به صورت دستی باز کنید یا برای تلاش مجدد ضربه بزنید.';

  @override
  String get callJitsiNotE2ee => 'تماس‌های Jitsi رمزگذاری سرتاسری ندارند';

  @override
  String get callRetryOpenBrowser => 'تلاش مجدد باز کردن مرورگر';

  @override
  String get callClose => 'بستن';

  @override
  String get callCamOn => 'دوربین روشن';

  @override
  String get callCamOff => 'دوربین خاموش';

  @override
  String get noConnection => 'بدون اتصال — پیام‌ها در صف قرار می‌گیرند';

  @override
  String get connected => 'متصل';

  @override
  String get connecting => 'در حال اتصال…';

  @override
  String get disconnected => 'قطع شده';

  @override
  String get offlineBanner =>
      'بدون اتصال — پیام‌ها در صف قرار گرفته و پس از اتصال مجدد ارسال می‌شوند';

  @override
  String get lanModeBanner => 'حالت LAN — بدون اینترنت · فقط شبکه محلی';

  @override
  String get probeCheckingNetwork => 'بررسی اتصال شبکه…';

  @override
  String get probeDiscoveringRelays => 'کشف رله‌ها از طریق فهرست‌های جامعه…';

  @override
  String get probeStartingTor => 'راه‌اندازی Tor برای بوت‌استرپ…';

  @override
  String get probeFindingRelaysTor => 'یافتن رله‌های قابل دسترس از طریق Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'شبکه آماده — $count رله$_temp0 یافت شد';
  }

  @override
  String get probeNoRelaysFound =>
      'هیچ رله قابل دسترسی یافت نشد — ممکن است پیام‌ها با تأخیر ارسال شوند';

  @override
  String get jitsiWarningTitle => 'رمزگذاری سرتاسری ندارد';

  @override
  String get jitsiWarningBody =>
      'تماس‌های Jitsi Meet توسط Pulse رمزگذاری نمی‌شوند. فقط برای مکالمات غیرحساس استفاده کنید.';

  @override
  String get jitsiConfirm => 'به هر حال بپیوندید';

  @override
  String get jitsiGroupWarningTitle => 'رمزگذاری سرتاسری ندارد';

  @override
  String get jitsiGroupWarningBody =>
      'این تماس شرکت‌کنندگان زیادی برای شبکه رمزگذاری‌شده داخلی دارد.\n\nیک لینک Jitsi Meet در مرورگر شما باز خواهد شد. Jitsi رمزگذاری سرتاسری ندارد — سرور می‌تواند تماس شما را ببیند.';

  @override
  String get jitsiContinueAnyway => 'به هر حال ادامه دهید';

  @override
  String get retry => 'تلاش مجدد';

  @override
  String get setupCreateAnonymousAccount => 'ایجاد حساب ناشناس';

  @override
  String get setupTapToChangeColor => 'برای تغییر رنگ ضربه بزنید';

  @override
  String get setupReqMinLength => 'حداقل ۱۶ کاراکتر';

  @override
  String get setupReqVariety => '۳ از ۴: حروف بزرگ، کوچک، اعداد، نمادها';

  @override
  String get setupReqMatch => 'رمزهای عبور مطابقت دارند';

  @override
  String get setupYourNickname => 'نام مستعار شما';

  @override
  String get setupRecoveryPassword => 'رمز عبور بازیابی (حداقل 16)';

  @override
  String get setupConfirmPassword => 'تأیید رمز عبور';

  @override
  String get setupMin16Chars => 'حداقل 16 کاراکتر';

  @override
  String get setupPasswordsDoNotMatch => 'رمزهای عبور مطابقت ندارند';

  @override
  String get setupEntropyWeak => 'ضعیف';

  @override
  String get setupEntropyOk => 'قابل قبول';

  @override
  String get setupEntropyStrong => 'قوی';

  @override
  String get setupEntropyWeakNeedsVariety => 'ضعیف (نیاز به 3 نوع کاراکتر)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits بیت)';
  }

  @override
  String get setupPasswordWarning =>
      'این رمز عبور تنها راه بازیابی حساب شماست. سروری وجود ندارد — بازنشانی رمز ممکن نیست. آن را به خاطر بسپارید یا یادداشت کنید.';

  @override
  String get setupCreateAccount => 'ایجاد حساب';

  @override
  String get setupAlreadyHaveAccount => 'قبلاً حساب دارید؟ ';

  @override
  String get setupRestore => 'بازیابی →';

  @override
  String get restoreTitle => 'بازیابی حساب';

  @override
  String get restoreInfoBanner =>
      'رمز عبور بازیابی خود را وارد کنید — آدرس شما (Nostr + Session) به طور خودکار بازیابی می‌شود. مخاطبین و پیام‌ها فقط به صورت محلی ذخیره شده بودند.';

  @override
  String get restoreNewNickname => 'نام مستعار جدید (بعداً قابل تغییر)';

  @override
  String get restoreButton => 'بازیابی حساب';

  @override
  String get lockTitle => 'Pulse قفل شده است';

  @override
  String get lockSubtitle => 'رمز عبور خود را برای ادامه وارد کنید';

  @override
  String get lockPasswordHint => 'رمز عبور';

  @override
  String get lockUnlock => 'باز کردن قفل';

  @override
  String get lockPanicHint =>
      'رمز عبور خود را فراموش کرده‌اید؟ کلید اضطراری خود را وارد کنید تا همه داده‌ها پاک شوند.';

  @override
  String get lockTooManyAttempts => 'تلاش‌های بیش از حد. پاک کردن همه داده‌ها…';

  @override
  String get lockWrongPassword => 'رمز عبور اشتباه';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'رمز عبور اشتباه — $attempts/$max تلاش';
  }

  @override
  String get onboardingSkip => 'رد شدن';

  @override
  String get onboardingNext => 'بعدی';

  @override
  String get onboardingGetStarted => 'شروع کنید';

  @override
  String get onboardingWelcomeTitle => 'به Pulse خوش آمدید';

  @override
  String get onboardingWelcomeBody =>
      'یک پیام‌رسان غیرمتمرکز با رمزگذاری سرتاسری.\n\nبدون سرور مرکزی. بدون جمع‌آوری داده. بدون درب پشتی.\nمکالمات شما فقط متعلق به شماست.';

  @override
  String get onboardingTransportTitle => 'مستقل از انتقال';

  @override
  String get onboardingTransportBody =>
      'از Firebase، Nostr یا هر دو همزمان استفاده کنید.\n\nپیام‌ها به طور خودکار از طریق شبکه‌ها مسیریابی می‌شوند. پشتیبانی داخلی Tor و I2P برای مقاومت در برابر سانسور.';

  @override
  String get onboardingSignalTitle => 'Signal + پساکوانتومی';

  @override
  String get onboardingSignalBody =>
      'هر پیام با پروتکل Signal (Double Ratchet + X3DH) برای محرمانگی پیشرو رمزگذاری می‌شود.\n\nعلاوه بر آن با Kyber-1024 — یک الگوریتم پساکوانتومی استاندارد NIST — پوشش داده می‌شود تا در برابر رایانه‌های کوانتومی آینده محافظت شود.';

  @override
  String get onboardingKeysTitle => 'کلیدهای شما متعلق به شماست';

  @override
  String get onboardingKeysBody =>
      'کلیدهای هویت شما هرگز دستگاهتان را ترک نمی‌کنند.\n\nاثرانگشت‌های Signal به شما امکان تأیید مخاطبین را به صورت خارج از باند می‌دهند. TOFU (اعتماد در اولین استفاده) تغییرات کلید را به طور خودکار تشخیص می‌دهد.';

  @override
  String get onboardingThemeTitle => 'ظاهر خود را انتخاب کنید';

  @override
  String get onboardingThemeBody =>
      'یک تم و رنگ تأکیدی انتخاب کنید. همیشه می‌توانید بعداً در تنظیمات تغییر دهید.';

  @override
  String get contactsNewChat => 'گفتگوی جدید';

  @override
  String get contactsAddContact => 'افزودن مخاطب';

  @override
  String get contactsSearchHint => 'جستجو...';

  @override
  String get contactsNewGroup => 'گروه جدید';

  @override
  String get contactsNoContactsYet => 'هنوز مخاطبی وجود ندارد';

  @override
  String get contactsAddHint => 'روی + ضربه بزنید تا آدرس کسی را اضافه کنید';

  @override
  String get contactsNoMatch => 'مخاطب مطابقی یافت نشد';

  @override
  String get contactsRemoveTitle => 'حذف مخاطب';

  @override
  String contactsRemoveMessage(String name) {
    return '$name حذف شود؟';
  }

  @override
  String get contactsRemove => 'حذف';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count مخاطب$_temp0';
  }

  @override
  String get bubbleOpenLink => 'باز کردن لینک';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'این آدرس در مرورگر باز شود؟\n\n$url';
  }

  @override
  String get bubbleOpen => 'باز کردن';

  @override
  String get bubbleSecurityWarning => 'هشدار امنیتی';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" یک فایل اجرایی است. ذخیره و اجرای آن ممکن است به دستگاه شما آسیب برساند. باز هم ذخیره شود؟';
  }

  @override
  String get bubbleSaveAnyway => 'به هر حال ذخیره کن';

  @override
  String bubbleSavedTo(String path) {
    return 'ذخیره شد در $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'ذخیره ناموفق: $error';
  }

  @override
  String get bubbleNotEncrypted => 'رمزگذاری نشده';

  @override
  String get bubbleCorruptedImage => '[تصویر خراب]';

  @override
  String get bubbleReplyPhoto => 'عکس';

  @override
  String get bubbleReplyVoice => 'پیام صوتی';

  @override
  String get bubbleReplyVideo => 'پیام ویدیویی';

  @override
  String bubbleReadBy(String names) {
    return 'خوانده‌شده توسط $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'خوانده‌شده توسط $count';
  }

  @override
  String get chatTileTapToStart => 'برای شروع گفتگو ضربه بزنید';

  @override
  String get chatTileMessageSent => 'پیام ارسال شد';

  @override
  String get chatTileEncryptedMessage => 'پیام رمزگذاری‌شده';

  @override
  String chatTileYouPrefix(String text) {
    return 'شما: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 پیام صوتی';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 پیام صوتی ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'پیام رمزگذاری‌شده';

  @override
  String get groupNewGroup => 'گروه جدید';

  @override
  String get groupGroupName => 'نام گروه';

  @override
  String get groupSelectMembers => 'انتخاب اعضا (حداقل 2)';

  @override
  String get groupNoContactsYet => 'هنوز مخاطبی نیست. ابتدا مخاطب اضافه کنید.';

  @override
  String get groupCreate => 'ایجاد';

  @override
  String get groupLabel => 'گروه';

  @override
  String get profileVerifyIdentity => 'تأیید هویت';

  @override
  String profileVerifyInstructions(String name) {
    return 'این اثرانگشت‌ها را با $name از طریق تماس صوتی یا حضوری مقایسه کنید. اگر هر دو مقدار روی هر دو دستگاه یکسان بود، روی «علامت‌گذاری به عنوان تأییدشده» ضربه بزنید.';
  }

  @override
  String get profileTheirKey => 'کلید آن‌ها';

  @override
  String get profileYourKey => 'کلید شما';

  @override
  String get profileRemoveVerification => 'حذف تأیید';

  @override
  String get profileMarkAsVerified => 'علامت‌گذاری به عنوان تأییدشده';

  @override
  String get profileAddressCopied => 'آدرس کپی شد';

  @override
  String get profileNoContactsToAdd =>
      'مخاطبی برای افزودن وجود ندارد — همه از قبل عضو هستند';

  @override
  String get profileAddMembers => 'افزودن اعضا';

  @override
  String profileAddCount(int count) {
    return 'افزودن ($count)';
  }

  @override
  String get profileRenameGroup => 'تغییر نام گروه';

  @override
  String get profileRename => 'تغییر نام';

  @override
  String get profileRemoveMember => 'عضو حذف شود؟';

  @override
  String profileRemoveMemberBody(String name) {
    return '$name از این گروه حذف شود؟';
  }

  @override
  String get profileKick => 'اخراج';

  @override
  String get profileSignalFingerprints => 'اثرانگشت‌های Signal';

  @override
  String get profileVerified => 'تأییدشده';

  @override
  String get profileVerify => 'تأیید';

  @override
  String get profileEdit => 'ویرایش';

  @override
  String get profileNoSession =>
      'هنوز نشست رمزگذاری برقرار نشده — ابتدا یک پیام ارسال کنید.';

  @override
  String get profileFingerprintCopied => 'اثرانگشت کپی شد';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count عضو$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'تأیید شماره امنیتی';

  @override
  String get profileShowContactQr => 'نمایش QR مخاطب';

  @override
  String profileContactAddress(String name) {
    return 'آدرس $name';
  }

  @override
  String get profileExportChatHistory => 'خروجی تاریخچه گفتگو';

  @override
  String profileSavedTo(String path) {
    return 'ذخیره شد در $path';
  }

  @override
  String get profileExportFailed => 'خروجی ناموفق بود';

  @override
  String get profileClearChatHistory => 'پاک کردن تاریخچه گفتگو';

  @override
  String get profileDeleteGroup => 'حذف گروه';

  @override
  String get profileDeleteContact => 'حذف مخاطب';

  @override
  String get profileLeaveGroup => 'ترک گروه';

  @override
  String get profileLeaveGroupBody =>
      'شما از این گروه حذف خواهید شد و گروه از مخاطبین شما پاک می‌شود.';

  @override
  String get groupInviteTitle => 'دعوت گروهی';

  @override
  String groupInviteBody(String from, String group) {
    return '$from شما را به پیوستن به \"$group\" دعوت کرد';
  }

  @override
  String get groupInviteAccept => 'پذیرش';

  @override
  String get groupInviteDecline => 'رد کردن';

  @override
  String get groupMemberLimitTitle => 'شرکت‌کنندگان بیش از حد';

  @override
  String groupMemberLimitBody(int count) {
    return 'این گروه $count شرکت‌کننده خواهد داشت. تماس‌های شبکه‌ای رمزگذاری‌شده تا 6 نفر پشتیبانی می‌کنند. گروه‌های بزرگ‌تر به Jitsi (بدون رمزگذاری سرتاسری) تغییر می‌یابند.';
  }

  @override
  String get groupMemberLimitContinue => 'به هر حال اضافه کن';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name دعوت پیوستن به \"$group\" را رد کرد';
  }

  @override
  String get transferTitle => 'انتقال به دستگاه دیگر';

  @override
  String get transferInfoBox =>
      'هویت Signal و کلیدهای Nostr خود را به دستگاه جدید منتقل کنید.\nنشست‌های گفتگو منتقل نمی‌شوند — محرمانگی پیشرو حفظ می‌شود.';

  @override
  String get transferSendFromThis => 'ارسال از این دستگاه';

  @override
  String get transferSendSubtitle =>
      'کلیدها روی این دستگاه هستند. یک کد با دستگاه جدید به اشتراک بگذارید.';

  @override
  String get transferReceiveOnThis => 'دریافت روی این دستگاه';

  @override
  String get transferReceiveSubtitle =>
      'این دستگاه جدید است. کد را از دستگاه قدیمی وارد کنید.';

  @override
  String get transferChooseMethod => 'انتخاب روش انتقال';

  @override
  String get transferLan => 'LAN (شبکه یکسان)';

  @override
  String get transferLanSubtitle =>
      'سریع و مستقیم. هر دو دستگاه باید در یک Wi-Fi باشند.';

  @override
  String get transferNostrRelay => 'رله Nostr';

  @override
  String get transferNostrRelaySubtitle =>
      'از طریق هر شبکه‌ای با استفاده از رله Nostr موجود کار می‌کند.';

  @override
  String get transferRelayUrl => 'آدرس رله';

  @override
  String get transferEnterCode => 'کد انتقال را وارد کنید';

  @override
  String get transferPasteCode => 'کد LAN:... یا NOS:... را اینجا بچسبانید';

  @override
  String get transferConnect => 'اتصال';

  @override
  String get transferGenerating => 'ایجاد کد انتقال…';

  @override
  String get transferShareCode => 'این کد را با گیرنده به اشتراک بگذارید:';

  @override
  String get transferCopyCode => 'کپی کد';

  @override
  String get transferCodeCopied => 'کد در کلیپ‌بورد کپی شد';

  @override
  String get transferWaitingReceiver => 'در انتظار اتصال گیرنده…';

  @override
  String get transferConnectingSender => 'اتصال به فرستنده…';

  @override
  String get transferVerifyBoth =>
      'این کد را روی هر دو دستگاه مقایسه کنید.\nاگر مطابقت دارند، انتقال امن است.';

  @override
  String get transferComplete => 'انتقال کامل شد';

  @override
  String get transferKeysImported => 'کلیدها وارد شدند';

  @override
  String get transferCompleteSenderBody =>
      'کلیدهای شما روی این دستگاه فعال می‌مانند.\nگیرنده اکنون می‌تواند از هویت شما استفاده کند.';

  @override
  String get transferCompleteReceiverBody =>
      'کلیدها با موفقیت وارد شدند.\nبرنامه را مجدداً راه‌اندازی کنید تا هویت جدید اعمال شود.';

  @override
  String get transferRestartApp => 'راه‌اندازی مجدد برنامه';

  @override
  String get transferFailed => 'انتقال ناموفق بود';

  @override
  String get transferTryAgain => 'تلاش مجدد';

  @override
  String get transferEnterRelayFirst => 'ابتدا آدرس رله را وارد کنید';

  @override
  String get transferPasteCodeFromSender => 'کد انتقال فرستنده را بچسبانید';

  @override
  String get menuReply => 'پاسخ';

  @override
  String get menuForward => 'ارسال مجدد';

  @override
  String get menuReact => 'واکنش';

  @override
  String get menuCopy => 'کپی';

  @override
  String get menuEdit => 'ویرایش';

  @override
  String get menuRetry => 'تلاش مجدد';

  @override
  String get menuCancelScheduled => 'لغو برنامه‌ریزی';

  @override
  String get menuDelete => 'حذف';

  @override
  String get menuForwardTo => 'ارسال مجدد به…';

  @override
  String menuForwardedTo(String name) {
    return 'ارسال مجدد شد به $name';
  }

  @override
  String get menuScheduledMessages => 'پیام‌های برنامه‌ریزی‌شده';

  @override
  String get menuNoScheduledMessages => 'پیام برنامه‌ریزی‌شده‌ای وجود ندارد';

  @override
  String menuSendsOn(String date) {
    return 'ارسال در $date';
  }

  @override
  String get menuDisappearingMessages => 'پیام‌های ناپدیدشونده';

  @override
  String get menuDisappearingSubtitle =>
      'پیام‌ها پس از زمان انتخاب‌شده به طور خودکار حذف می‌شوند.';

  @override
  String get menuTtlOff => 'خاموش';

  @override
  String get menuTtl1h => '1 ساعت';

  @override
  String get menuTtl24h => '24 ساعت';

  @override
  String get menuTtl7d => '7 روز';

  @override
  String get menuAttachPhoto => 'عکس';

  @override
  String get menuAttachFile => 'فایل';

  @override
  String get menuAttachVideo => 'ویدیو';

  @override
  String get mediaTitle => 'رسانه';

  @override
  String get mediaFileLabel => 'فایل';

  @override
  String mediaPhotosTab(int count) {
    return 'عکس‌ها ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'فایل‌ها ($count)';
  }

  @override
  String get mediaNoPhotos => 'هنوز عکسی وجود ندارد';

  @override
  String get mediaNoFiles => 'هنوز فایلی وجود ندارد';

  @override
  String mediaSavedToDownloads(String name) {
    return 'ذخیره شد در Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'ذخیره فایل ناموفق بود';

  @override
  String get statusNewStatus => 'وضعیت جدید';

  @override
  String get statusPublish => 'انتشار';

  @override
  String get statusExpiresIn24h => 'وضعیت پس از 24 ساعت منقضی می‌شود';

  @override
  String get statusWhatsOnYourMind => 'چه چیزی در ذهن شماست؟';

  @override
  String get statusPhotoAttached => 'عکس پیوست شد';

  @override
  String get statusAttachPhoto => 'پیوست عکس (اختیاری)';

  @override
  String get statusEnterText => 'لطفاً متنی برای وضعیت خود وارد کنید.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'انتخاب عکس ناموفق: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'انتشار ناموفق: $error';
  }

  @override
  String get panicSetPanicKey => 'تنظیم کلید اضطراری';

  @override
  String get panicEmergencySelfDestruct => 'خودنابودی اضطراری';

  @override
  String get panicIrreversible => 'این عمل بازگشت‌ناپذیر است';

  @override
  String get panicWarningBody =>
      'وارد کردن این کلید در صفحه قفل فوراً تمام داده‌ها — پیام‌ها، مخاطبین، کلیدها، هویت را پاک می‌کند. از کلیدی متفاوت از رمز عبور معمول خود استفاده کنید.';

  @override
  String get panicKeyHint => 'کلید اضطراری';

  @override
  String get panicConfirmHint => 'تأیید کلید اضطراری';

  @override
  String get panicMinChars => 'کلید اضطراری باید حداقل 8 کاراکتر باشد';

  @override
  String get panicKeysDoNotMatch => 'کلیدها مطابقت ندارند';

  @override
  String get panicSetFailed =>
      'ذخیره کلید اضطراری ناموفق بود — لطفاً دوباره تلاش کنید';

  @override
  String get passwordSetAppPassword => 'تنظیم رمز عبور برنامه';

  @override
  String get passwordProtectsMessages =>
      'از پیام‌های شما در حالت استراحت محافظت می‌کند';

  @override
  String get passwordInfoBanner =>
      'در هر بار باز کردن Pulse لازم است. در صورت فراموشی، داده‌های شما قابل بازیابی نیستند.';

  @override
  String get passwordHint => 'رمز عبور';

  @override
  String get passwordConfirmHint => 'تأیید رمز عبور';

  @override
  String get passwordSetButton => 'تنظیم رمز عبور';

  @override
  String get passwordSkipForNow => 'فعلاً رد شوید';

  @override
  String get passwordMinChars => 'رمز عبور باید حداقل 6 کاراکتر باشد';

  @override
  String get passwordsDoNotMatch => 'رمزهای عبور مطابقت ندارند';

  @override
  String get profileCardSaved => 'پروفایل ذخیره شد!';

  @override
  String get profileCardE2eeIdentity => 'هویت E2EE';

  @override
  String get profileCardDisplayName => 'نام نمایشی';

  @override
  String get profileCardDisplayNameHint => 'مثلاً علی احمدی';

  @override
  String get profileCardAbout => 'درباره';

  @override
  String get profileCardSaveProfile => 'ذخیره پروفایل';

  @override
  String get profileCardYourName => 'نام شما';

  @override
  String get profileCardAddressCopied => 'آدرس کپی شد!';

  @override
  String get profileCardInboxAddress => 'آدرس صندوق ورودی شما';

  @override
  String get profileCardInboxAddresses => 'آدرس‌های صندوق ورودی شما';

  @override
  String get profileCardShareAllAddresses => 'اشتراک همه آدرس‌ها (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'با مخاطبین به اشتراک بگذارید تا بتوانند به شما پیام دهند.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'تمام $count آدرس به عنوان یک لینک کپی شد!';
  }

  @override
  String get settingsMyProfile => 'پروفایل من';

  @override
  String get settingsYourInboxAddress => 'آدرس صندوق ورودی شما';

  @override
  String get settingsMyQrCode => 'کد QR من';

  @override
  String get settingsMyQrSubtitle =>
      'آدرس خود را به عنوان QR قابل اسکن به اشتراک بگذارید';

  @override
  String get settingsShareMyAddress => 'اشتراک آدرس من';

  @override
  String get settingsNoAddressYet =>
      'هنوز آدرسی وجود ندارد — ابتدا تنظیمات را ذخیره کنید';

  @override
  String get settingsInviteLink => 'لینک دعوت';

  @override
  String get settingsRawAddress => 'آدرس خام';

  @override
  String get settingsCopyLink => 'کپی لینک';

  @override
  String get settingsCopyAddress => 'کپی آدرس';

  @override
  String get settingsInviteLinkCopied => 'لینک دعوت کپی شد';

  @override
  String get settingsAppearance => 'ظاهر';

  @override
  String get settingsThemeEngine => 'موتور تم';

  @override
  String get settingsThemeEngineSubtitle => 'سفارشی‌سازی رنگ‌ها و فونت‌ها';

  @override
  String get settingsSignalProtocol => 'پروتکل Signal';

  @override
  String get settingsSignalProtocolSubtitle =>
      'کلیدهای E2EE به صورت امن ذخیره شده‌اند';

  @override
  String get settingsActive => 'فعال';

  @override
  String get settingsIdentityBackup => 'پشتیبان هویت';

  @override
  String get settingsIdentityBackupSubtitle => 'خروجی یا ورودی هویت Signal شما';

  @override
  String get settingsIdentityBackupBody =>
      'کلیدهای هویت Signal خود را به کد پشتیبان خروجی بگیرید، یا از یک کد موجود بازیابی کنید.';

  @override
  String get settingsTransferDevice => 'انتقال به دستگاه دیگر';

  @override
  String get settingsTransferDeviceSubtitle =>
      'انتقال هویت از طریق LAN یا رله Nostr';

  @override
  String get settingsExportIdentity => 'خروجی هویت';

  @override
  String get settingsExportIdentityBody =>
      'این کد پشتیبان را کپی کنید و در مکان امنی ذخیره کنید:';

  @override
  String get settingsSaveFile => 'ذخیره فایل';

  @override
  String get settingsImportIdentity => 'ورودی هویت';

  @override
  String get settingsImportIdentityBody =>
      'کد پشتیبان خود را در زیر بچسبانید. این کار هویت فعلی شما را بازنویسی می‌کند.';

  @override
  String get settingsPasteBackupCode => 'کد پشتیبان را اینجا بچسبانید…';

  @override
  String get settingsIdentityImported =>
      'هویت + مخاطبین وارد شدند! برنامه را مجدداً راه‌اندازی کنید تا اعمال شود.';

  @override
  String get settingsSecurity => 'امنیت';

  @override
  String get settingsAppPassword => 'رمز عبور برنامه';

  @override
  String get settingsPasswordEnabled => 'فعال — در هر بار اجرا لازم است';

  @override
  String get settingsPasswordDisabled =>
      'غیرفعال — برنامه بدون رمز عبور باز می‌شود';

  @override
  String get settingsChangePassword => 'تغییر رمز عبور';

  @override
  String get settingsChangePasswordSubtitle =>
      'به‌روزرسانی رمز عبور قفل برنامه';

  @override
  String get settingsSetPanicKey => 'تنظیم کلید اضطراری';

  @override
  String get settingsChangePanicKey => 'تغییر کلید اضطراری';

  @override
  String get settingsPanicKeySetSubtitle => 'به‌روزرسانی کلید پاک‌سازی اضطراری';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'یک کلید که فوراً همه داده‌ها را پاک می‌کند';

  @override
  String get settingsRemovePanicKey => 'حذف کلید اضطراری';

  @override
  String get settingsRemovePanicKeySubtitle => 'غیرفعال‌سازی خودنابودی اضطراری';

  @override
  String get settingsRemovePanicKeyBody =>
      'خودنابودی اضطراری غیرفعال خواهد شد. هر زمان می‌توانید دوباره فعال کنید.';

  @override
  String get settingsDisableAppPassword => 'غیرفعال‌سازی رمز عبور برنامه';

  @override
  String get settingsEnterCurrentPassword =>
      'رمز عبور فعلی خود را برای تأیید وارد کنید';

  @override
  String get settingsCurrentPassword => 'رمز عبور فعلی';

  @override
  String get settingsIncorrectPassword => 'رمز عبور اشتباه';

  @override
  String get settingsPasswordUpdated => 'رمز عبور به‌روزرسانی شد';

  @override
  String get settingsChangePasswordProceed =>
      'رمز عبور فعلی خود را برای ادامه وارد کنید';

  @override
  String get settingsData => 'داده‌ها';

  @override
  String get settingsBackupMessages => 'پشتیبان‌گیری پیام‌ها';

  @override
  String get settingsBackupMessagesSubtitle =>
      'خروجی تاریخچه پیام‌های رمزگذاری‌شده به فایل';

  @override
  String get settingsRestoreMessages => 'بازیابی پیام‌ها';

  @override
  String get settingsRestoreMessagesSubtitle => 'ورودی پیام‌ها از فایل پشتیبان';

  @override
  String get settingsExportKeys => 'خروجی کلیدها';

  @override
  String get settingsExportKeysSubtitle =>
      'ذخیره کلیدهای هویت در فایل رمزگذاری‌شده';

  @override
  String get settingsImportKeys => 'ورودی کلیدها';

  @override
  String get settingsImportKeysSubtitle =>
      'بازیابی کلیدهای هویت از فایل خروجی‌شده';

  @override
  String get settingsBackupPassword => 'رمز عبور پشتیبان';

  @override
  String get settingsPasswordCannotBeEmpty => 'رمز عبور نمی‌تواند خالی باشد';

  @override
  String get settingsPasswordMin4Chars => 'رمز عبور باید حداقل 4 کاراکتر باشد';

  @override
  String get settingsCallsTurn => 'تماس‌ها و TURN';

  @override
  String get settingsLocalNetwork => 'شبکه محلی';

  @override
  String get settingsCensorshipResistance => 'مقاومت در برابر سانسور';

  @override
  String get settingsNetwork => 'شبکه';

  @override
  String get settingsProxyTunnels => 'پراکسی و تونل‌ها';

  @override
  String get settingsTurnServers => 'سرورهای TURN';

  @override
  String get settingsProviderTitle => 'ارائه‌دهنده';

  @override
  String get settingsLanFallback => 'بازگشت LAN';

  @override
  String get settingsLanFallbackSubtitle =>
      'پخش حضور و تحویل پیام در شبکه محلی هنگام عدم دسترسی به اینترنت. در شبکه‌های نامطمئن (Wi-Fi عمومی) غیرفعال کنید.';

  @override
  String get settingsBgDelivery => 'تحویل در پس‌زمینه';

  @override
  String get settingsBgDeliverySubtitle =>
      'دریافت پیام‌ها هنگام کوچک‌سازی برنامه ادامه می‌یابد. یک اعلان دائمی نمایش داده می‌شود.';

  @override
  String get settingsYourInboxProvider => 'ارائه‌دهنده صندوق ورودی شما';

  @override
  String get settingsConnectionDetails => 'جزئیات اتصال';

  @override
  String get settingsSaveAndConnect => 'ذخیره و اتصال';

  @override
  String get settingsSecondaryInboxes => 'صندوق‌های ورودی ثانویه';

  @override
  String get settingsAddSecondaryInbox => 'افزودن صندوق ورودی ثانویه';

  @override
  String get settingsAdvanced => 'پیشرفته';

  @override
  String get settingsDiscover => 'کشف';

  @override
  String get settingsAbout => 'درباره';

  @override
  String get settingsPrivacyPolicy => 'سیاست حفظ حریم خصوصی';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'نحوه حفاظت Pulse از داده‌های شما';

  @override
  String get settingsCrashReporting => 'گزارش خرابی';

  @override
  String get settingsCrashReportingSubtitle =>
      'ارسال گزارش‌های خرابی ناشناس برای بهبود Pulse. هیچ محتوای پیام یا مخاطبی ارسال نمی‌شود.';

  @override
  String get settingsCrashReportingEnabled =>
      'گزارش خرابی فعال شد — برنامه را مجدداً راه‌اندازی کنید تا اعمال شود';

  @override
  String get settingsCrashReportingDisabled =>
      'گزارش خرابی غیرفعال شد — برنامه را مجدداً راه‌اندازی کنید تا اعمال شود';

  @override
  String get settingsSensitiveOperation => 'عملیات حساس';

  @override
  String get settingsSensitiveOperationBody =>
      'این کلیدها هویت شما هستند. هر کسی که این فایل را داشته باشد می‌تواند جعل هویت شما کند. آن را در مکان امنی ذخیره کنید و پس از انتقال حذف کنید.';

  @override
  String get settingsIUnderstandContinue => 'متوجه هستم، ادامه بده';

  @override
  String get settingsReplaceIdentity => 'جایگزینی هویت؟';

  @override
  String get settingsReplaceIdentityBody =>
      'این کار کلیدهای هویت فعلی شما را بازنویسی می‌کند. نشست‌های Signal موجود نامعتبر می‌شوند و مخاطبین باید رمزگذاری را مجدداً برقرار کنند. برنامه نیاز به راه‌اندازی مجدد دارد.';

  @override
  String get settingsReplaceKeys => 'جایگزینی کلیدها';

  @override
  String get settingsKeysImported => 'کلیدها وارد شدند';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count کلید با موفقیت وارد شد. لطفاً برنامه را مجدداً راه‌اندازی کنید تا با هویت جدید آغاز شود.';
  }

  @override
  String get settingsRestartNow => 'راه‌اندازی مجدد الان';

  @override
  String get settingsLater => 'بعداً';

  @override
  String get profileGroupLabel => 'گروه';

  @override
  String get profileAddButton => 'افزودن';

  @override
  String get profileKickButton => 'اخراج';

  @override
  String get dataSectionTitle => 'داده‌ها';

  @override
  String get dataBackupMessages => 'پشتیبان‌گیری پیام‌ها';

  @override
  String get dataBackupPasswordSubtitle =>
      'یک رمز عبور برای رمزگذاری پشتیبان خود انتخاب کنید.';

  @override
  String get dataBackupConfirmLabel => 'ایجاد پشتیبان';

  @override
  String get dataCreatingBackup => 'ایجاد پشتیبان';

  @override
  String get dataBackupPreparing => 'آماده‌سازی...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'خروجی پیام $done از $total...';
  }

  @override
  String get dataBackupSavingFile => 'ذخیره فایل...';

  @override
  String get dataSaveMessageBackupDialog => 'ذخیره پشتیبان پیام‌ها';

  @override
  String dataBackupSaved(int count, String path) {
    return 'پشتیبان ذخیره شد ($count پیام)\n$path';
  }

  @override
  String get dataBackupFailed => 'پشتیبان‌گیری ناموفق — داده‌ای خروجی نشد';

  @override
  String dataBackupFailedError(String error) {
    return 'پشتیبان‌گیری ناموفق: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'انتخاب پشتیبان پیام‌ها';

  @override
  String get dataInvalidBackupFile => 'فایل پشتیبان نامعتبر (بیش از حد کوچک)';

  @override
  String get dataNotValidBackupFile => 'فایل پشتیبان معتبر Pulse نیست';

  @override
  String get dataRestoreMessages => 'بازیابی پیام‌ها';

  @override
  String get dataRestorePasswordSubtitle =>
      'رمز عبوری که برای ایجاد این پشتیبان استفاده شده را وارد کنید.';

  @override
  String get dataRestoreConfirmLabel => 'بازیابی';

  @override
  String get dataRestoringMessages => 'بازیابی پیام‌ها';

  @override
  String get dataRestoreDecrypting => 'رمزگشایی...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'ورودی پیام $done از $total...';
  }

  @override
  String get dataRestoreFailed =>
      'بازیابی ناموفق — رمز عبور اشتباه یا فایل خراب';

  @override
  String dataRestoreSuccess(int count) {
    return '$count پیام جدید بازیابی شد';
  }

  @override
  String get dataRestoreNothingNew =>
      'پیام جدیدی برای ورودی وجود ندارد (همه از قبل موجود هستند)';

  @override
  String dataRestoreFailedError(String error) {
    return 'بازیابی ناموفق: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'انتخاب خروجی کلید';

  @override
  String get dataNotValidKeyFile => 'فایل خروجی کلید معتبر Pulse نیست';

  @override
  String get dataExportKeys => 'خروجی کلیدها';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'یک رمز عبور برای رمزگذاری خروجی کلید خود انتخاب کنید.';

  @override
  String get dataExportKeysConfirmLabel => 'خروجی';

  @override
  String get dataExportingKeys => 'خروجی کلیدها';

  @override
  String get dataExportingKeysStatus => 'رمزگذاری کلیدهای هویت...';

  @override
  String get dataSaveKeyExportDialog => 'ذخیره خروجی کلید';

  @override
  String dataKeysExportedTo(String path) {
    return 'کلیدها خروجی شدند به:\n$path';
  }

  @override
  String get dataExportFailed => 'خروجی ناموفق — کلیدی یافت نشد';

  @override
  String dataExportFailedError(String error) {
    return 'خروجی ناموفق: $error';
  }

  @override
  String get dataImportKeys => 'ورودی کلیدها';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'رمز عبوری که برای رمزگذاری این خروجی کلید استفاده شده را وارد کنید.';

  @override
  String get dataImportKeysConfirmLabel => 'ورودی';

  @override
  String get dataImportingKeys => 'ورودی کلیدها';

  @override
  String get dataImportingKeysStatus => 'رمزگشایی کلیدهای هویت...';

  @override
  String get dataImportFailed => 'ورودی ناموفق — رمز عبور اشتباه یا فایل خراب';

  @override
  String dataImportFailedError(String error) {
    return 'ورودی ناموفق: $error';
  }

  @override
  String get securitySectionTitle => 'امنیت';

  @override
  String get securityIncorrectPassword => 'رمز عبور اشتباه';

  @override
  String get securityPasswordUpdated => 'رمز عبور به‌روزرسانی شد';

  @override
  String get appearanceSectionTitle => 'ظاهر';

  @override
  String appearanceExportFailed(String error) {
    return 'خروجی ناموفق: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'ذخیره شد در $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'ذخیره ناموفق: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'ورودی ناموفق: $error';
  }

  @override
  String get aboutSectionTitle => 'درباره';

  @override
  String get providerPublicKey => 'کلید عمومی';

  @override
  String get providerRelay => 'رله';

  @override
  String get providerAutoConfigured =>
      'به طور خودکار از رمز عبور بازیابی شما پیکربندی شده. رله به طور خودکار کشف شده.';

  @override
  String get providerKeyStoredLocally =>
      'کلید شما به صورت محلی در حافظه امن ذخیره شده — هرگز به هیچ سروری ارسال نمی‌شود.';

  @override
  String get providerSessionInfo =>
      'Session Network — E2EE با مسیریابی پیازی. شناسه Session شما به طور خودکار تولید و به صورت امن ذخیره می‌شود. گره‌ها به طور خودکار از گره‌های seed داخلی کشف می‌شوند.';

  @override
  String get providerAdvanced => 'پیشرفته';

  @override
  String get providerSaveAndConnect => 'ذخیره و اتصال';

  @override
  String get providerAddSecondaryInbox => 'افزودن صندوق ورودی ثانویه';

  @override
  String get providerSecondaryInboxes => 'صندوق‌های ورودی ثانویه';

  @override
  String get providerYourInboxProvider => 'ارائه‌دهنده صندوق ورودی شما';

  @override
  String get providerConnectionDetails => 'جزئیات اتصال';

  @override
  String get addContactTitle => 'افزودن مخاطب';

  @override
  String get addContactInviteLinkLabel => 'لینک دعوت یا آدرس';

  @override
  String get addContactTapToPaste => 'برای چسباندن لینک دعوت ضربه بزنید';

  @override
  String get addContactPasteTooltip => 'چسباندن از کلیپ‌بورد';

  @override
  String get addContactAddressDetected => 'آدرس مخاطب شناسایی شد';

  @override
  String addContactRoutesDetected(int count) {
    return '$count مسیر شناسایی شد — SmartRouter سریع‌ترین را انتخاب می‌کند';
  }

  @override
  String get addContactFetchingProfile => 'دریافت پروفایل…';

  @override
  String addContactProfileFound(String name) {
    return 'یافت شد: $name';
  }

  @override
  String get addContactNoProfileFound => 'پروفایلی یافت نشد';

  @override
  String get addContactDisplayNameLabel => 'نام نمایشی';

  @override
  String get addContactDisplayNameHint => 'می‌خواهید چه نامی بگذارید؟';

  @override
  String get addContactAddManually => 'وارد کردن آدرس به صورت دستی';

  @override
  String get addContactButton => 'افزودن مخاطب';

  @override
  String get networkDiagnosticsTitle => 'تشخیص شبکه';

  @override
  String get networkDiagnosticsNostrRelays => 'رله‌های Nostr';

  @override
  String get networkDiagnosticsDirect => 'مستقیم';

  @override
  String get networkDiagnosticsTorOnly => 'فقط Tor';

  @override
  String get networkDiagnosticsBest => 'بهترین';

  @override
  String get networkDiagnosticsNone => 'هیچ‌کدام';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'وضعیت';

  @override
  String get networkDiagnosticsConnected => 'متصل';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'اتصال $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'خاموش';

  @override
  String get networkDiagnosticsTransport => 'انتقال';

  @override
  String get networkDiagnosticsInfrastructure => 'زیرساخت';

  @override
  String get networkDiagnosticsSessionNodes => 'گره‌های Session';

  @override
  String get networkDiagnosticsTurnServers => 'سرورهای TURN';

  @override
  String get networkDiagnosticsLastProbe => 'آخرین بررسی';

  @override
  String get networkDiagnosticsRunning => 'در حال اجرا...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'اجرای تشخیص';

  @override
  String get networkDiagnosticsForceReprobe => 'بررسی مجدد کامل اجباری';

  @override
  String get networkDiagnosticsJustNow => 'همین الان';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes دقیقه پیش';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours ساعت پیش';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days روز پیش';
  }

  @override
  String get homeNoEch => 'بدون ECH';

  @override
  String get homeNoEchTooltip =>
      'پراکسی uTLS در دسترس نیست — ECH غیرفعال.\nاثرانگشت TLS برای DPI قابل مشاهده است.';

  @override
  String get settingsTitle => 'تنظیمات';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'ذخیره و متصل به $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Tor داخلی نتوانست راه‌اندازی شود';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon نتوانست راه‌اندازی شود';

  @override
  String get verifyTitle => 'تأیید شماره امنیتی';

  @override
  String get verifyIdentityVerified => 'هویت تأیید شد';

  @override
  String get verifyNotYetVerified => 'هنوز تأیید نشده';

  @override
  String verifyVerifiedDescription(String name) {
    return 'شما شماره امنیتی $name را تأیید کرده‌اید.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'این اعداد را با $name به صورت حضوری یا از طریق کانال مطمئن مقایسه کنید.';
  }

  @override
  String get verifyExplanation =>
      'هر مکالمه یک شماره امنیتی منحصر به فرد دارد. اگر هر دو نفر اعداد یکسانی را روی دستگاه‌های خود ببینید، اتصال شما سرتاسری تأیید شده است.';

  @override
  String verifyContactKey(String name) {
    return 'کلید $name';
  }

  @override
  String get verifyYourKey => 'کلید شما';

  @override
  String get verifyRemoveVerification => 'حذف تأیید';

  @override
  String get verifyMarkAsVerified => 'علامت‌گذاری به عنوان تأییدشده';

  @override
  String verifyAfterReinstall(String name) {
    return 'اگر $name برنامه را مجدداً نصب کند، شماره امنیتی تغییر می‌کند و تأیید به طور خودکار حذف می‌شود.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'فقط پس از مقایسه اعداد با $name از طریق تماس صوتی یا حضوری، به عنوان تأییدشده علامت بزنید.';
  }

  @override
  String get verifyNoSession =>
      'هنوز نشست رمزگذاری برقرار نشده. ابتدا یک پیام ارسال کنید تا شماره‌های امنیتی تولید شوند.';

  @override
  String get verifyNoKeyAvailable => 'کلیدی در دسترس نیست';

  @override
  String verifyFingerprintCopied(String label) {
    return 'اثرانگشت $label کپی شد';
  }

  @override
  String get providerDatabaseUrlLabel => 'آدرس پایگاه داده';

  @override
  String get providerOptionalHint => 'اختیاری';

  @override
  String get providerWebApiKeyLabel => 'کلید Web API';

  @override
  String get providerOptionalForPublicDb => 'اختیاری برای پایگاه داده عمومی';

  @override
  String get providerRelayUrlLabel => 'آدرس رله';

  @override
  String get providerPrivateKeyLabel => 'کلید خصوصی';

  @override
  String get providerPrivateKeyNsecLabel => 'کلید خصوصی (nsec)';

  @override
  String get providerStorageNodeLabel => 'آدرس گره ذخیره‌سازی (اختیاری)';

  @override
  String get providerStorageNodeHint =>
      'برای استفاده از گره‌های بذر داخلی خالی بگذارید';

  @override
  String get transferInvalidCodeFormat =>
      'فرمت کد ناشناخته — باید با LAN: یا NOS: شروع شود';

  @override
  String get profileCardFingerprintCopied => 'اثرانگشت کپی شد';

  @override
  String get profileCardAboutHint => 'حریم خصوصی اول 🔒';

  @override
  String get profileCardSaveButton => 'ذخیره پروفایل';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'خروجی پیام‌های رمزگذاری‌شده، مخاطبین و آواتارها به فایل';

  @override
  String get callVideo => 'ویدیو';

  @override
  String get callAudio => 'صوتی';

  @override
  String bubbleDeliveredTo(String names) {
    return 'تحویل داده شد به $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'تحویل داده شد به $count';
  }

  @override
  String get groupStatusDialogTitle => 'اطلاعات پیام';

  @override
  String get groupStatusRead => 'خوانده‌شده';

  @override
  String get groupStatusDelivered => 'تحویل‌شده';

  @override
  String get groupStatusPending => 'در انتظار';

  @override
  String get groupStatusNoData => 'هنوز اطلاعات تحویلی وجود ندارد';

  @override
  String get profileTransferAdmin => 'مدیر کردن';

  @override
  String profileTransferAdminConfirm(String name) {
    return '$name به عنوان مدیر جدید تعیین شود؟';
  }

  @override
  String get profileTransferAdminBody =>
      'شما اختیارات مدیریتی خود را از دست خواهید داد. این عمل قابل بازگشت نیست.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name اکنون مدیر است';
  }

  @override
  String get profileAdminBadge => 'مدیر';

  @override
  String get privacyPolicyTitle => 'سیاست حفظ حریم خصوصی';

  @override
  String get privacyOverviewHeading => 'نمای کلی';

  @override
  String get privacyOverviewBody =>
      'Pulse یک پیام‌رسان بدون سرور با رمزگذاری سرتاسری است. حریم خصوصی شما فقط یک ویژگی نیست — بلکه معماری است. سرور Pulse وجود ندارد. هیچ حسابی در هیچ جا ذخیره نمی‌شود. هیچ داده‌ای توسط توسعه‌دهندگان جمع‌آوری، منتقل یا ذخیره نمی‌شود.';

  @override
  String get privacyDataCollectionHeading => 'جمع‌آوری داده';

  @override
  String get privacyDataCollectionBody =>
      'Pulse هیچ داده شخصی جمع‌آوری نمی‌کند. به طور خاص:\n\n- نیازی به ایمیل، شماره تلفن یا نام واقعی نیست\n- بدون آنالیتیکس، ردیابی یا تله‌متری\n- بدون شناسه‌های تبلیغاتی\n- بدون دسترسی به لیست مخاطبین\n- بدون پشتیبان ابری (پیام‌ها فقط روی دستگاه شما وجود دارند)\n- هیچ فراداده‌ای به هیچ سرور Pulse ارسال نمی‌شود (سروری وجود ندارد)';

  @override
  String get privacyEncryptionHeading => 'رمزگذاری';

  @override
  String get privacyEncryptionBody =>
      'تمام پیام‌ها با پروتکل Signal (Double Ratchet با توافق کلید X3DH) رمزگذاری می‌شوند. کلیدهای رمزگذاری منحصراً روی دستگاه شما تولید و ذخیره می‌شوند. هیچ‌کس — از جمله توسعه‌دهندگان — نمی‌تواند پیام‌های شما را بخواند.';

  @override
  String get privacyNetworkHeading => 'معماری شبکه';

  @override
  String get privacyNetworkBody =>
      'Pulse از آداپتورهای انتقال فدراسیونی (رله‌های Nostr، گره‌های خدمات Session/Oxen، Firebase Realtime Database، LAN) استفاده می‌کند. این انتقال‌ها فقط متن رمزگذاری‌شده را حمل می‌کنند. اپراتورهای رله می‌توانند آدرس IP و حجم ترافیک شما را ببینند، اما نمی‌توانند محتوای پیام را رمزگشایی کنند.\n\nوقتی Tor فعال است، آدرس IP شما از اپراتورهای رله نیز پنهان می‌شود.';

  @override
  String get privacyStunHeading => 'سرورهای STUN/TURN';

  @override
  String get privacyStunBody =>
      'تماس‌های صوتی و تصویری از WebRTC با رمزگذاری DTLS-SRTP استفاده می‌کنند. سرورهای STUN (برای کشف IP عمومی شما برای اتصالات نظیر به نظیر) و سرورهای TURN (برای رله رسانه هنگام شکست اتصال مستقیم) می‌توانند آدرس IP و مدت تماس شما را ببینند، اما نمی‌توانند محتوای تماس را رمزگشایی کنند.\n\nمی‌توانید سرور TURN خود را در تنظیمات پیکربندی کنید تا حداکثر حریم خصوصی را داشته باشید.';

  @override
  String get privacyCrashHeading => 'گزارش خرابی';

  @override
  String get privacyCrashBody =>
      'اگر گزارش خرابی Sentry فعال باشد (از طریق SENTRY_DSN در زمان ساخت)، ممکن است گزارش‌های خرابی ناشناس ارسال شوند. این گزارش‌ها شامل محتوای پیام، اطلاعات مخاطبین یا اطلاعات شناسایی شخصی نیستند. گزارش خرابی را می‌توان در زمان ساخت با حذف DSN غیرفعال کرد.';

  @override
  String get privacyPasswordHeading => 'رمز عبور و کلیدها';

  @override
  String get privacyPasswordBody =>
      'رمز عبور بازیابی شما برای استخراج کلیدهای رمزنگاری از طریق Argon2id (KDF سخت حافظه‌ای) استفاده می‌شود. رمز عبور هرگز به هیچ جا ارسال نمی‌شود. اگر رمز عبور خود را گم کنید، حساب شما قابل بازیابی نیست — سروری برای بازنشانی وجود ندارد.';

  @override
  String get privacyFontsHeading => 'فونت‌ها';

  @override
  String get privacyFontsBody =>
      'Pulse تمام فونت‌ها را به صورت محلی شامل می‌شود. هیچ درخواستی به Google Fonts یا هیچ سرویس فونت خارجی ارسال نمی‌شود.';

  @override
  String get privacyThirdPartyHeading => 'خدمات شخص ثالث';

  @override
  String get privacyThirdPartyBody =>
      'Pulse با هیچ شبکه تبلیغاتی، ارائه‌دهنده آنالیتیکس، پلتفرم رسانه اجتماعی یا واسطه داده یکپارچه نیست. تنها اتصالات شبکه به رله‌های انتقالی هستند که شما پیکربندی می‌کنید.';

  @override
  String get privacyOpenSourceHeading => 'متن‌باز';

  @override
  String get privacyOpenSourceBody =>
      'Pulse نرم‌افزار متن‌باز است. می‌توانید کد منبع کامل را بررسی کنید تا این ادعاهای حریم خصوصی را تأیید کنید.';

  @override
  String get privacyContactHeading => 'تماس';

  @override
  String get privacyContactBody =>
      'برای سوالات مربوط به حریم خصوصی، یک issue در مخزن پروژه باز کنید.';

  @override
  String get privacyLastUpdated => 'آخرین به‌روزرسانی: مارس 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'ذخیره ناموفق: $error';
  }

  @override
  String get themeEngineTitle => 'موتور تم';

  @override
  String get torBuiltInTitle => 'Tor داخلی';

  @override
  String get torConnectedSubtitle =>
      'متصل — Nostr از طریق 127.0.0.1:9250 مسیریابی می‌شود';

  @override
  String torConnectingSubtitle(int pct) {
    return 'اتصال… $pct%';
  }

  @override
  String get torNotRunning => 'غیرفعال — برای راه‌اندازی مجدد ضربه بزنید';

  @override
  String get torDescription =>
      'مسیریابی Nostr از طریق Tor (Snowflake برای شبکه‌های سانسورشده)';

  @override
  String get torNetworkDiagnostics => 'تشخیص شبکه';

  @override
  String get torTransportLabel => 'انتقال: ';

  @override
  String get torPtAuto => 'خودکار';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'ساده';

  @override
  String get torTimeoutLabel => 'زمان انتظار: ';

  @override
  String get torInfoDescription =>
      'هنگام فعال بودن، اتصالات WebSocket Nostr از طریق Tor (SOCKS5) مسیریابی می‌شوند. Tor Browser روی 127.0.0.1:9150 گوش می‌دهد. دیمن مستقل Tor از پورت 9050 استفاده می‌کند. اتصالات Firebase تحت تأثیر قرار نمی‌گیرند.';

  @override
  String get torRouteNostrTitle => 'مسیریابی Nostr از طریق Tor';

  @override
  String get torManagedByBuiltin => 'مدیریت‌شده توسط Tor داخلی';

  @override
  String get torActiveRouting =>
      'فعال — ترافیک Nostr از طریق Tor مسیریابی می‌شود';

  @override
  String get torDisabled => 'غیرفعال';

  @override
  String get torProxySocks5 => 'پراکسی Tor (SOCKS5)';

  @override
  String get torProxyHostLabel => 'میزبان پراکسی';

  @override
  String get torProxyPortLabel => 'پورت';

  @override
  String get torPortInfo => 'Tor Browser: پورت 9150  •  دیمن Tor: پورت 9050';

  @override
  String get i2pProxySocks5 => 'پراکسی I2P (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P به طور پیش‌فرض از SOCKS5 روی پورت 4447 استفاده می‌کند. به یک رله Nostr از طریق I2P outproxy (مثلاً relay.damus.i2p) متصل شوید تا با کاربران روی هر انتقالی ارتباط برقرار کنید. Tor در صورت فعال بودن هر دو اولویت دارد.';

  @override
  String get i2pRouteNostrTitle => 'مسیریابی Nostr از طریق I2P';

  @override
  String get i2pActiveRouting =>
      'فعال — ترافیک Nostr از طریق I2P مسیریابی می‌شود';

  @override
  String get i2pDisabled => 'غیرفعال';

  @override
  String get i2pProxyHostLabel => 'میزبان پراکسی';

  @override
  String get i2pProxyPortLabel => 'پورت';

  @override
  String get i2pPortInfo => 'پورت پیش‌فرض SOCKS5 روتر I2P: 4447';

  @override
  String get customProxySocks5 => 'پراکسی سفارشی (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'رله CF Worker';

  @override
  String get customProxyInfoDescription =>
      'پراکسی سفارشی ترافیک را از طریق V2Ray/Xray/Shadowsocks شما مسیریابی می‌کند. CF Worker به عنوان پراکسی رله شخصی روی CDN Cloudflare عمل می‌کند — GFW فقط *.workers.dev را می‌بیند، نه رله واقعی.';

  @override
  String get customSocks5ProxyTitle => 'پراکسی سفارشی SOCKS5';

  @override
  String get customProxyActive =>
      'فعال — ترافیک از طریق SOCKS5 مسیریابی می‌شود';

  @override
  String get customProxyDisabled => 'غیرفعال';

  @override
  String get customProxyHostLabel => 'میزبان پراکسی';

  @override
  String get customProxyPortLabel => 'پورت';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'دامنه Worker (اختیاری)';

  @override
  String get customWorkerHelpTitle => 'نحوه استقرار رله CF Worker (رایگان)';

  @override
  String get customWorkerScriptCopied => 'اسکریپت کپی شد!';

  @override
  String get customWorkerStep1 =>
      '1. به dash.cloudflare.com → Workers & Pages بروید\n2. Create Worker → این اسکریپت را بچسبانید:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → دامنه را کپی کنید (مثلاً my-relay.user.workers.dev)\n4. دامنه را در بالا بچسبانید → ذخیره\n\nبرنامه به طور خودکار متصل می‌شود: wss://domain/?r=relay_url\nGFW می‌بیند: اتصال به *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'متصل — SOCKS5 روی 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'اتصال…';

  @override
  String get psiphonNotRunning => 'غیرفعال — برای راه‌اندازی مجدد ضربه بزنید';

  @override
  String get psiphonDescription =>
      'تونل سریع (~3 ثانیه بوت‌استرپ، 2000+ VPS چرخشی)';

  @override
  String get turnCommunityServers => 'سرورهای TURN جامعه';

  @override
  String get turnCustomServer => 'سرور TURN سفارشی (BYOD)';

  @override
  String get turnInfoDescription =>
      'سرورهای TURN فقط جریان‌های از قبل رمزگذاری‌شده (DTLS-SRTP) را رله می‌کنند. اپراتور رله IP و حجم ترافیک شما را می‌بیند، اما نمی‌تواند تماس‌ها را رمزگشایی کند. TURN فقط زمانی استفاده می‌شود که P2P مستقیم شکست بخورد (~15–20% از اتصالات).';

  @override
  String get turnFreeLabel => 'رایگان';

  @override
  String get turnServerUrlLabel => 'آدرس سرور TURN';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 یا turns:...';

  @override
  String get turnUsernameLabel => 'نام کاربری';

  @override
  String get turnPasswordLabel => 'رمز عبور';

  @override
  String get turnOptionalHint => 'اختیاری';

  @override
  String get turnCustomInfo =>
      'coturn را روی هر VPS 5 دلاری/ماهانه میزبانی کنید برای حداکثر کنترل. اعتبارنامه‌ها به صورت محلی ذخیره می‌شوند.';

  @override
  String get themePickerAppearance => 'ظاهر';

  @override
  String get themePickerAccentColor => 'رنگ تأکیدی';

  @override
  String get themeModeLight => 'روشن';

  @override
  String get themeModeDark => 'تاریک';

  @override
  String get themeModeSystem => 'سیستم';

  @override
  String get themeDynamicPresets => 'پیش‌تنظیمات';

  @override
  String get themeDynamicPrimaryColor => 'رنگ اصلی';

  @override
  String get themeDynamicBorderRadius => 'شعاع حاشیه';

  @override
  String get themeDynamicFont => 'فونت';

  @override
  String get themeDynamicAppearance => 'ظاهر';

  @override
  String get themeDynamicUiStyle => 'سبک رابط کاربری';

  @override
  String get themeDynamicUiStyleDescription =>
      'نحوه نمایش دیالوگ‌ها، کلیدها و نشانگرها را کنترل می‌کند.';

  @override
  String get themeDynamicSharp => 'تیز';

  @override
  String get themeDynamicRound => 'گرد';

  @override
  String get themeDynamicModeDark => 'تاریک';

  @override
  String get themeDynamicModeLight => 'روشن';

  @override
  String get themeDynamicModeAuto => 'خودکار';

  @override
  String get themeDynamicPlatformAuto => 'خودکار';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'آدرس Firebase نامعتبر. مورد انتظار: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'آدرس رله نامعتبر. مورد انتظار: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'آدرس سرور Pulse نامعتبر. مورد انتظار: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'آدرس سرور';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'کد دعوت';

  @override
  String get providerPulseInviteHint => 'کد دعوت (در صورت نیاز)';

  @override
  String get providerPulseInfo =>
      'رله خودمیزبان. کلیدها از رمز عبور بازیابی شما استخراج شده‌اند.';

  @override
  String get providerScreenTitle => 'صندوق‌های ورودی';

  @override
  String get providerSecondaryInboxesHeader => 'صندوق‌های ورودی ثانویه';

  @override
  String get providerSecondaryInboxesInfo =>
      'صندوق‌های ورودی ثانویه پیام‌ها را همزمان برای افزونگی دریافت می‌کنند.';

  @override
  String get providerRemoveTooltip => 'حذف';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... یا hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... یا کلید خصوصی hex';

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
  String get emojiNoRecent => 'ایموجی اخیری نیست';

  @override
  String get emojiSearchHint => 'جستجوی ایموجی...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'برای گفتگو ضربه بزنید';

  @override
  String get imageViewerSaveToDownloads => 'ذخیره در Downloads';

  @override
  String imageViewerSavedTo(String path) {
    return 'ذخیره شد در $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'تأیید';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get settingsLanguageSubtitle => 'زبان نمایش برنامه';

  @override
  String get settingsLanguageSystem => 'پیش‌فرض سیستم';

  @override
  String get onboardingLanguageTitle => 'زبان خود را انتخاب کنید';

  @override
  String get onboardingLanguageSubtitle =>
      'بعداً می‌توانید در تنظیمات تغییر دهید';

  @override
  String get videoNoteRecord => 'ضبط پیام ویدیویی';

  @override
  String get videoNoteTapToRecord => 'برای ضبط لمس کنید';

  @override
  String get videoNoteTapToStop => 'برای توقف لمس کنید';

  @override
  String get videoNoteCameraPermission => 'دسترسی به دوربین رد شد';

  @override
  String get videoNoteMaxDuration => 'حداکثر ۳۰ ثانیه';

  @override
  String get videoNoteNotSupported =>
      'یادداشت‌های ویدیویی در این پلتفرم پشتیبانی نمی‌شوند';

  @override
  String get navChats => 'چت‌ها';

  @override
  String get navUpdates => 'به‌روزرسانی‌ها';

  @override
  String get navCalls => 'تماس‌ها';

  @override
  String get filterAll => 'همه';

  @override
  String get filterUnread => 'خوانده نشده';

  @override
  String get filterGroups => 'گروه‌ها';

  @override
  String get callsNoRecent => 'هیچ تماس اخیری وجود ندارد';

  @override
  String get callsEmptySubtitle =>
      'تاریخچه تماس‌های شما اینجا نمایش داده می‌شود';

  @override
  String get appBarEncrypted => 'رمزگذاری سرتاسر';

  @override
  String get newStatus => 'وضعیت جدید';

  @override
  String get newCall => 'تماس جدید';
}
