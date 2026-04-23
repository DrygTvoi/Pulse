// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'البحث في الرسائل...';

  @override
  String get search => 'بحث';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get closeSearch => 'إغلاق البحث';

  @override
  String get moreOptions => 'خيارات إضافية';

  @override
  String get back => 'رجوع';

  @override
  String get cancel => 'إلغاء';

  @override
  String get close => 'إغلاق';

  @override
  String get confirm => 'تأكيد';

  @override
  String get remove => 'إزالة';

  @override
  String get save => 'حفظ';

  @override
  String get add => 'إضافة';

  @override
  String get copy => 'نسخ';

  @override
  String get skip => 'تخطّي';

  @override
  String get done => 'تم';

  @override
  String get apply => 'تطبيق';

  @override
  String get export => 'تصدير';

  @override
  String get import => 'استيراد';

  @override
  String get homeNewGroup => 'مجموعة جديدة';

  @override
  String get homeSettings => 'الإعدادات';

  @override
  String get homeSearching => 'جارٍ البحث في الرسائل...';

  @override
  String get homeNoResults => 'لا توجد نتائج';

  @override
  String get homeNoChatHistory => 'لا يوجد سجل محادثات بعد';

  @override
  String homeTransportSwitched(String address) {
    return 'تم تبديل النقل → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name يتصل بك...';
  }

  @override
  String get homeAccept => 'قبول';

  @override
  String get homeDecline => 'رفض';

  @override
  String get homeLoadEarlier => 'تحميل رسائل سابقة';

  @override
  String get homeChats => 'المحادثات';

  @override
  String get homeSelectConversation => 'اختر محادثة';

  @override
  String get homeNoChatsYet => 'لا توجد محادثات بعد';

  @override
  String get homeAddContactToStart => 'أضف جهة اتصال لبدء المحادثة';

  @override
  String get homeNewChat => 'محادثة جديدة';

  @override
  String get homeNewChatTooltip => 'محادثة جديدة';

  @override
  String get homeIncomingCallTitle => 'مكالمة واردة';

  @override
  String get homeIncomingGroupCallTitle => 'مكالمة جماعية واردة';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — مكالمة جماعية واردة';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'لا توجد محادثات مطابقة لـ \"$query\"';
  }

  @override
  String get homeSectionChats => 'المحادثات';

  @override
  String get homeSectionMessages => 'الرسائل';

  @override
  String get homeDbEncryptionUnavailable =>
      'تشفير قاعدة البيانات غير متاح — ثبّت SQLCipher للحماية الكاملة';

  @override
  String get chatFileTooLargeGroup =>
      'الملفات التي تزيد عن 512 كيلوبايت غير مدعومة في المحادثات الجماعية';

  @override
  String get chatLargeFile => 'ملف كبير';

  @override
  String get chatCancel => 'إلغاء';

  @override
  String get chatSend => 'إرسال';

  @override
  String get chatFileTooLarge => 'الملف كبير جدًا — الحد الأقصى 100 ميغابايت';

  @override
  String get chatMicDenied => 'تم رفض إذن الميكروفون';

  @override
  String get chatVoiceFailed =>
      'فشل حفظ الرسالة الصوتية — تحقق من مساحة التخزين المتاحة';

  @override
  String get chatScheduleFuture => 'يجب أن يكون الوقت المجدول في المستقبل';

  @override
  String get chatToday => 'اليوم';

  @override
  String get chatYesterday => 'أمس';

  @override
  String get chatEdited => 'مُعدَّل';

  @override
  String get chatYou => 'أنت';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'حجم هذا الملف $size ميغابايت. قد يكون إرسال الملفات الكبيرة بطيئًا على بعض الشبكات. هل تريد المتابعة؟';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'تغيّر مفتاح الأمان الخاص بـ $name. اضغط للتحقق.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'تعذّر تشفير الرسالة إلى $name — لم يتم إرسال الرسالة.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'تغيّر رقم الأمان الخاص بـ $name. اضغط للتحقق.';
  }

  @override
  String get chatNoMessagesFound => 'لا توجد رسائل';

  @override
  String get chatMessagesE2ee => 'الرسائل مشفّرة من طرف إلى طرف';

  @override
  String get chatSayHello => 'قل مرحبًا';

  @override
  String get appBarOnline => 'متصل';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'يكتب';

  @override
  String get appBarSearchMessages => 'البحث في الرسائل...';

  @override
  String get appBarMute => 'كتم';

  @override
  String get appBarUnmute => 'إلغاء الكتم';

  @override
  String get appBarMedia => 'الوسائط';

  @override
  String get appBarDisappearing => 'الرسائل المختفية';

  @override
  String get appBarDisappearingOn => 'الاختفاء: مفعّل';

  @override
  String get appBarGroupSettings => 'إعدادات المجموعة';

  @override
  String get appBarSearchTooltip => 'البحث في الرسائل';

  @override
  String get appBarVoiceCall => 'مكالمة صوتية';

  @override
  String get appBarVideoCall => 'مكالمة فيديو';

  @override
  String get inputMessage => 'رسالة...';

  @override
  String get inputAttachFile => 'إرفاق ملف';

  @override
  String get inputSendMessage => 'إرسال رسالة';

  @override
  String get inputRecordVoice => 'تسجيل رسالة صوتية';

  @override
  String get inputSendVoice => 'إرسال رسالة صوتية';

  @override
  String get inputCancelReply => 'إلغاء الرد';

  @override
  String get inputCancelEdit => 'إلغاء التعديل';

  @override
  String get inputCancelRecording => 'إلغاء التسجيل';

  @override
  String get inputRecording => 'جارٍ التسجيل…';

  @override
  String get inputEditingMessage => 'تعديل الرسالة';

  @override
  String get inputPhoto => 'صورة';

  @override
  String get inputVoiceMessage => 'رسالة صوتية';

  @override
  String get inputFile => 'ملف';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رسالة مجدولة',
      many: '$count رسالة مجدولة',
      few: '$count رسائل مجدولة',
      two: 'رسالتان مجدولتان',
      one: 'رسالة مجدولة واحدة',
      zero: 'لا توجد رسائل مجدولة',
    );
    return '$_temp0';
  }

  @override
  String get callInitializing => 'جارٍ تهيئة المكالمة…';

  @override
  String get callConnecting => 'جارٍ الاتصال…';

  @override
  String get callConnectingRelay => 'جارٍ الاتصال (عبر الوسيط)…';

  @override
  String get callSwitchingRelay => 'جارٍ التحويل إلى وضع الوسيط…';

  @override
  String get callConnectionFailed => 'فشل الاتصال';

  @override
  String get callReconnecting => 'جارٍ إعادة الاتصال…';

  @override
  String get callEnded => 'انتهت المكالمة';

  @override
  String get callLive => 'مباشر';

  @override
  String get callEnd => 'إنهاء';

  @override
  String get callEndCall => 'إنهاء المكالمة';

  @override
  String get callMute => 'كتم';

  @override
  String get callUnmute => 'إلغاء الكتم';

  @override
  String get callSpeaker => 'مكبر الصوت';

  @override
  String get callCameraOn => 'تشغيل الكاميرا';

  @override
  String get callCameraOff => 'إيقاف الكاميرا';

  @override
  String get callShareScreen => 'مشاركة الشاشة';

  @override
  String get callStopShare => 'إيقاف المشاركة';

  @override
  String callTorBackup(String duration) {
    return 'نسخة Tor احتياطية · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'نسخة Tor الاحتياطية نشطة — المسار الأساسي غير متاح';

  @override
  String get callDirectFailed =>
      'فشل الاتصال المباشر — جارٍ التحويل إلى وضع الوسيط…';

  @override
  String get callTurnUnreachable =>
      'خوادم TURN غير قابلة للوصول. أضف خادم TURN مخصصًا في الإعدادات → متقدم.';

  @override
  String get callRelayMode => 'وضع الوسيط نشط (شبكة مقيّدة)';

  @override
  String get callStarting => 'جارٍ بدء المكالمة…';

  @override
  String get callConnectingToGroup => 'جارٍ الاتصال بالمجموعة…';

  @override
  String get callGroupOpenedInBrowser => 'تم فتح المكالمة الجماعية في المتصفح';

  @override
  String get callCouldNotOpenBrowser => 'تعذّر فتح المتصفح';

  @override
  String get callInviteLinkSent =>
      'تم إرسال رابط الدعوة إلى جميع أعضاء المجموعة.';

  @override
  String get callOpenLinkManually =>
      'افتح الرابط أعلاه يدويًا أو اضغط لإعادة المحاولة.';

  @override
  String get callJitsiNotE2ee => 'مكالمات Jitsi ليست مشفّرة من طرف إلى طرف';

  @override
  String get callRetryOpenBrowser => 'إعادة فتح المتصفح';

  @override
  String get callClose => 'إغلاق';

  @override
  String get callCamOn => 'تشغيل الكاميرا';

  @override
  String get callCamOff => 'إيقاف الكاميرا';

  @override
  String get noConnection =>
      'لا يوجد اتصال — سيتم وضع الرسائل في قائمة الانتظار';

  @override
  String get connected => 'متصل';

  @override
  String get connecting => 'جارٍ الاتصال…';

  @override
  String get disconnected => 'غير متصل';

  @override
  String get offlineBanner =>
      'لا يوجد اتصال — سيتم إرسال الرسائل عند العودة للاتصال';

  @override
  String get lanModeBanner =>
      'وضع الشبكة المحلية — بدون إنترنت · شبكة محلية فقط';

  @override
  String get probeCheckingNetwork => 'جارٍ فحص الاتصال بالشبكة…';

  @override
  String get probeDiscoveringRelays => 'جارٍ اكتشاف الوسطاء عبر أدلة المجتمع…';

  @override
  String get probeStartingTor => 'جارٍ تشغيل Tor للتمهيد…';

  @override
  String get probeFindingRelaysTor => 'جارٍ البحث عن وسطاء متاحين عبر Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وسيط',
      many: '$count وسيطًا',
      few: '$count وسطاء',
      two: 'وسيطين',
      one: 'وسيط واحد',
      zero: 'لا وسطاء',
    );
    return 'الشبكة جاهزة — تم العثور على $_temp0';
  }

  @override
  String get probeNoRelaysFound =>
      'لم يتم العثور على وسطاء متاحين — قد تتأخر الرسائل';

  @override
  String get jitsiWarningTitle => 'غير مشفّر من طرف إلى طرف';

  @override
  String get jitsiWarningBody =>
      'مكالمات Jitsi Meet غير مشفّرة بواسطة Pulse. استخدمها فقط للمحادثات غير الحساسة.';

  @override
  String get jitsiConfirm => 'الانضمام على أي حال';

  @override
  String get jitsiGroupWarningTitle => 'غير مشفّر من طرف إلى طرف';

  @override
  String get jitsiGroupWarningBody =>
      'تحتوي هذه المكالمة على عدد كبير من المشاركين لا يدعمه التشفير المدمج.\n\nسيتم فتح رابط Jitsi Meet في متصفحك. Jitsi ليس مشفّرًا من طرف إلى طرف — يمكن للخادم رؤية مكالمتك.';

  @override
  String get jitsiContinueAnyway => 'المتابعة على أي حال';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get setupCreateAnonymousAccount => 'إنشاء حساب مجهول';

  @override
  String get setupTapToChangeColor => 'اضغط لتغيير اللون';

  @override
  String get setupReqMinLength => '16 حرفًا على الأقل';

  @override
  String get setupReqVariety => '3 من 4: أحرف كبيرة، صغيرة، أرقام، رموز';

  @override
  String get setupReqMatch => 'كلمتا المرور متطابقتان';

  @override
  String get setupYourNickname => 'اسمك المستعار';

  @override
  String get setupRecoveryPassword =>
      'كلمة مرور الاسترداد (16 حرفًا على الأقل)';

  @override
  String get setupConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get setupMin16Chars => '16 حرفًا على الأقل';

  @override
  String get setupPasswordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get setupEntropyWeak => 'ضعيف';

  @override
  String get setupEntropyOk => 'مقبول';

  @override
  String get setupEntropyStrong => 'قوي';

  @override
  String get setupEntropyWeakNeedsVariety => 'ضعيف (يلزم 3 أنواع من الأحرف)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits بت)';
  }

  @override
  String get setupPasswordWarning =>
      'كلمة المرور هذه هي الطريقة الوحيدة لاسترداد حسابك. لا يوجد خادم — لا يمكن إعادة تعيين كلمة المرور. احفظها أو دوّنها.';

  @override
  String get setupCreateAccount => 'إنشاء الحساب';

  @override
  String get setupAlreadyHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get setupRestore => 'استرداد →';

  @override
  String get restoreTitle => 'استرداد الحساب';

  @override
  String get restoreInfoBanner =>
      'أدخل كلمة مرور الاسترداد — سيتم استعادة عنوانك (Nostr + Session) تلقائيًا. جهات الاتصال والرسائل كانت مخزّنة محليًا فقط.';

  @override
  String get restoreNewNickname => 'اسم مستعار جديد (يمكن تغييره لاحقًا)';

  @override
  String get restoreButton => 'استرداد الحساب';

  @override
  String get lockTitle => 'Pulse مقفل';

  @override
  String get lockSubtitle => 'أدخل كلمة المرور للمتابعة';

  @override
  String get lockPasswordHint => 'كلمة المرور';

  @override
  String get lockUnlock => 'فتح القفل';

  @override
  String get lockPanicHint =>
      'نسيت كلمة المرور؟ أدخل مفتاح الطوارئ لمسح جميع البيانات.';

  @override
  String get lockTooManyAttempts =>
      'محاولات كثيرة جدًا. جارٍ مسح جميع البيانات…';

  @override
  String get lockWrongPassword => 'كلمة مرور خاطئة';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'كلمة مرور خاطئة — $attempts/$max محاولات';
  }

  @override
  String get onboardingSkip => 'تخطّي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingGetStarted => 'إنشاء حساب';

  @override
  String get onboardingWelcomeTitle => 'مرحبًا بك في Pulse';

  @override
  String get onboardingWelcomeBody =>
      'تطبيق مراسلة لامركزي ومشفّر من طرف إلى طرف.\n\nلا خوادم مركزية. لا جمع بيانات. لا أبواب خلفية.\nمحادثاتك ملك لك وحدك.';

  @override
  String get onboardingTransportTitle => 'مستقل عن وسيلة النقل';

  @override
  String get onboardingTransportBody =>
      'استخدم Firebase أو Nostr أو كليهما في الوقت نفسه.\n\nيتم توجيه الرسائل عبر الشبكات تلقائيًا. دعم مدمج لـ Tor و I2P لمقاومة الرقابة.';

  @override
  String get onboardingSignalTitle => 'Signal + ما بعد الكمّ';

  @override
  String get onboardingSignalBody =>
      'كل رسالة مشفّرة ببروتوكول Signal (Double Ratchet + X3DH) لضمان السرية الأمامية.\n\nمغلّفة إضافيًا بـ Kyber-1024 — خوارزمية معيار NIST لما بعد الكمّ — للحماية من الحواسيب الكمّية المستقبلية.';

  @override
  String get onboardingKeysTitle => 'مفاتيحك بيدك';

  @override
  String get onboardingKeysBody =>
      'مفاتيح هويتك لا تغادر جهازك أبدًا.\n\nبصمات Signal تتيح لك التحقق من جهات الاتصال خارج النطاق. TOFU (الثقة عند الاستخدام الأول) يكتشف تغييرات المفاتيح تلقائيًا.';

  @override
  String get onboardingThemeTitle => 'اختر مظهرك';

  @override
  String get onboardingThemeBody =>
      'اختر سمة ولونًا مميزًا. يمكنك تغيير ذلك لاحقًا من الإعدادات.';

  @override
  String get contactsNewChat => 'محادثة جديدة';

  @override
  String get contactsAddContact => 'إضافة جهة اتصال';

  @override
  String get contactsSearchHint => 'بحث...';

  @override
  String get contactsNewGroup => 'مجموعة جديدة';

  @override
  String get contactsNoContactsYet => 'لا توجد جهات اتصال بعد';

  @override
  String get contactsAddHint => 'اضغط + لإضافة عنوان شخص ما';

  @override
  String get contactsNoMatch => 'لا توجد جهات اتصال مطابقة';

  @override
  String get contactsRemoveTitle => 'إزالة جهة الاتصال';

  @override
  String contactsRemoveMessage(String name) {
    return 'إزالة $name؟';
  }

  @override
  String get contactsRemove => 'إزالة';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جهة اتصال',
      many: '$count جهة اتصال',
      few: '$count جهات اتصال',
      two: 'جهتا اتصال',
      one: 'جهة اتصال واحدة',
      zero: 'لا توجد جهات اتصال',
    );
    return '$_temp0';
  }

  @override
  String get bubbleOpenLink => 'فتح الرابط';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'فتح هذا الرابط في المتصفح؟\n\n$url';
  }

  @override
  String get bubbleOpen => 'فتح';

  @override
  String get bubbleSecurityWarning => 'تحذير أمني';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" هو ملف قابل للتنفيذ. حفظه وتشغيله قد يضر بجهازك. هل تريد الحفظ على أي حال؟';
  }

  @override
  String get bubbleSaveAnyway => 'حفظ على أي حال';

  @override
  String bubbleSavedTo(String path) {
    return 'تم الحفظ في $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'فشل الحفظ: $error';
  }

  @override
  String get bubbleNotEncrypted => 'غير مشفّر';

  @override
  String get bubbleCorruptedImage => '[صورة تالفة]';

  @override
  String get bubbleReplyPhoto => 'صورة';

  @override
  String get bubbleReplyVoice => 'رسالة صوتية';

  @override
  String get bubbleReplyVideo => 'رسالة فيديو';

  @override
  String bubbleReadBy(String names) {
    return 'قرأها $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'قرأها $count';
  }

  @override
  String get chatTileTapToStart => 'اضغط لبدء المحادثة';

  @override
  String get chatTileMessageSent => 'تم إرسال الرسالة';

  @override
  String get chatTileEncryptedMessage => 'رسالة مشفّرة';

  @override
  String chatTileYouPrefix(String text) {
    return 'أنت: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 رسالة صوتية';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 رسالة صوتية ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'رسالة مشفّرة';

  @override
  String get groupNewGroup => 'مجموعة جديدة';

  @override
  String get groupGroupName => 'اسم المجموعة';

  @override
  String get groupSelectMembers => 'اختر الأعضاء (2 على الأقل)';

  @override
  String get groupNoContactsYet =>
      'لا توجد جهات اتصال بعد. أضف جهات اتصال أولاً.';

  @override
  String get groupCreate => 'إنشاء';

  @override
  String get groupLabel => 'مجموعة';

  @override
  String get profileVerifyIdentity => 'التحقق من الهوية';

  @override
  String profileVerifyInstructions(String name) {
    return 'قارن بصمات الأصابع هذه مع $name عبر مكالمة صوتية أو شخصيًا. إذا تطابقت القيمتان على كلا الجهازين، اضغط \"تمييز كموثّق\".';
  }

  @override
  String get profileTheirKey => 'مفتاحهم';

  @override
  String get profileYourKey => 'مفتاحك';

  @override
  String get profileRemoveVerification => 'إزالة التحقق';

  @override
  String get profileMarkAsVerified => 'تمييز كموثّق';

  @override
  String get profileAddressCopied => 'تم نسخ العنوان';

  @override
  String get profileNoContactsToAdd =>
      'لا توجد جهات اتصال للإضافة — جميعها أعضاء بالفعل';

  @override
  String get profileAddMembers => 'إضافة أعضاء';

  @override
  String profileAddCount(int count) {
    return 'إضافة ($count)';
  }

  @override
  String get profileRenameGroup => 'إعادة تسمية المجموعة';

  @override
  String get profileRename => 'إعادة التسمية';

  @override
  String get profileRemoveMember => 'إزالة العضو؟';

  @override
  String profileRemoveMemberBody(String name) {
    return 'إزالة $name من هذه المجموعة؟';
  }

  @override
  String get profileKick => 'طرد';

  @override
  String get profileSignalFingerprints => 'بصمات Signal';

  @override
  String get profileVerified => 'موثّق';

  @override
  String get profileVerify => 'تحقّق';

  @override
  String get profileEdit => 'تعديل';

  @override
  String get profileNoSession => 'لم يتم إنشاء جلسة بعد — أرسل رسالة أولاً.';

  @override
  String get profileFingerprintCopied => 'تم نسخ البصمة';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو',
      many: '$count عضوًا',
      few: '$count أعضاء',
      two: 'عضوان',
      one: 'عضو واحد',
      zero: 'لا أعضاء',
    );
    return '$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'التحقق من رقم الأمان';

  @override
  String get profileShowContactQr => 'عرض رمز QR لجهة الاتصال';

  @override
  String profileContactAddress(String name) {
    return 'عنوان $name';
  }

  @override
  String get profileExportChatHistory => 'تصدير سجل المحادثات';

  @override
  String profileSavedTo(String path) {
    return 'تم الحفظ في $path';
  }

  @override
  String get profileExportFailed => 'فشل التصدير';

  @override
  String get profileClearChatHistory => 'مسح سجل المحادثات';

  @override
  String get profileDeleteGroup => 'حذف المجموعة';

  @override
  String get profileDeleteContact => 'حذف جهة الاتصال';

  @override
  String get profileLeaveGroup => 'مغادرة المجموعة';

  @override
  String get profileLeaveGroupBody =>
      'سيتم إزالتك من هذه المجموعة وحذفها من جهات اتصالك.';

  @override
  String get groupInviteTitle => 'دعوة للمجموعة';

  @override
  String groupInviteBody(String from, String group) {
    return '$from دعاك للانضمام إلى \"$group\"';
  }

  @override
  String get groupInviteAccept => 'قبول';

  @override
  String get groupInviteDecline => 'رفض';

  @override
  String get groupMemberLimitTitle => 'عدد كبير من المشاركين';

  @override
  String groupMemberLimitBody(int count) {
    return 'ستضم هذه المجموعة $count مشاركًا. المكالمات المشفّرة تدعم حتى 6 مشاركين. المجموعات الأكبر تستخدم Jitsi (غير مشفّر من طرف إلى طرف).';
  }

  @override
  String get groupMemberLimitContinue => 'إضافة على أي حال';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return 'رفض $name الانضمام إلى \"$group\"';
  }

  @override
  String get transferTitle => 'النقل إلى جهاز آخر';

  @override
  String get transferInfoBox =>
      'انقل هوية Signal ومفاتيح Nostr إلى جهاز جديد.\nجلسات المحادثة لا يتم نقلها — للحفاظ على السرية الأمامية.';

  @override
  String get transferSendFromThis => 'الإرسال من هذا الجهاز';

  @override
  String get transferSendSubtitle =>
      'هذا الجهاز يحتوي على المفاتيح. شارك رمزًا مع الجهاز الجديد.';

  @override
  String get transferReceiveOnThis => 'الاستقبال على هذا الجهاز';

  @override
  String get transferReceiveSubtitle =>
      'هذا هو الجهاز الجديد. أدخل الرمز من الجهاز القديم.';

  @override
  String get transferChooseMethod => 'اختر طريقة النقل';

  @override
  String get transferLan => 'الشبكة المحلية (نفس الشبكة)';

  @override
  String get transferLanSubtitle =>
      'سريع ومباشر. يجب أن يكون الجهازان على نفس شبكة Wi-Fi.';

  @override
  String get transferNostrRelay => 'وسيط Nostr';

  @override
  String get transferNostrRelaySubtitle =>
      'يعمل عبر أي شبكة باستخدام وسيط Nostr موجود.';

  @override
  String get transferRelayUrl => 'رابط الوسيط';

  @override
  String get transferEnterCode => 'أدخل رمز النقل';

  @override
  String get transferPasteCode => 'الصق رمز LAN:... أو NOS:... هنا';

  @override
  String get transferConnect => 'اتصال';

  @override
  String get transferGenerating => 'جارٍ إنشاء رمز النقل…';

  @override
  String get transferShareCode => 'شارك هذا الرمز مع المستقبل:';

  @override
  String get transferCopyCode => 'نسخ الرمز';

  @override
  String get transferCodeCopied => 'تم نسخ الرمز إلى الحافظة';

  @override
  String get transferWaitingReceiver => 'في انتظار اتصال المستقبل…';

  @override
  String get transferConnectingSender => 'جارٍ الاتصال بالمرسل…';

  @override
  String get transferVerifyBoth =>
      'قارن هذا الرمز على كلا الجهازين.\nإذا تطابقا، فالنقل آمن.';

  @override
  String get transferComplete => 'اكتمل النقل';

  @override
  String get transferKeysImported => 'تم استيراد المفاتيح';

  @override
  String get transferCompleteSenderBody =>
      'تبقى مفاتيحك نشطة على هذا الجهاز.\nيمكن للمستقبل الآن استخدام هويتك.';

  @override
  String get transferCompleteReceiverBody =>
      'تم استيراد المفاتيح بنجاح.\nأعد تشغيل التطبيق لتطبيق الهوية الجديدة.';

  @override
  String get transferRestartApp => 'إعادة تشغيل التطبيق';

  @override
  String get transferFailed => 'فشل النقل';

  @override
  String get transferTryAgain => 'حاول مجددًا';

  @override
  String get transferEnterRelayFirst => 'أدخل رابط الوسيط أولاً';

  @override
  String get transferPasteCodeFromSender => 'الصق رمز النقل من المرسل';

  @override
  String get menuReply => 'رد';

  @override
  String get menuForward => 'إعادة توجيه';

  @override
  String get menuReact => 'تفاعل';

  @override
  String get menuCopy => 'نسخ';

  @override
  String get menuEdit => 'تعديل';

  @override
  String get menuRetry => 'إعادة المحاولة';

  @override
  String get menuCancelScheduled => 'إلغاء المجدول';

  @override
  String get menuDelete => 'حذف';

  @override
  String get menuForwardTo => 'إعادة التوجيه إلى…';

  @override
  String menuForwardedTo(String name) {
    return 'تمت إعادة التوجيه إلى $name';
  }

  @override
  String get menuScheduledMessages => 'الرسائل المجدولة';

  @override
  String get menuNoScheduledMessages => 'لا توجد رسائل مجدولة';

  @override
  String menuSendsOn(String date) {
    return 'سيتم الإرسال في $date';
  }

  @override
  String get menuDisappearingMessages => 'الرسائل المختفية';

  @override
  String get menuDisappearingSubtitle =>
      'يتم حذف الرسائل تلقائيًا بعد الوقت المحدد.';

  @override
  String get menuTtlOff => 'إيقاف';

  @override
  String get menuTtl1h => 'ساعة واحدة';

  @override
  String get menuTtl24h => '24 ساعة';

  @override
  String get menuTtl7d => '7 أيام';

  @override
  String get menuAttachPhoto => 'صورة';

  @override
  String get menuAttachFile => 'ملف';

  @override
  String get menuAttachVideo => 'فيديو';

  @override
  String get mediaTitle => 'الوسائط';

  @override
  String get mediaFileLabel => 'ملف';

  @override
  String mediaPhotosTab(int count) {
    return 'الصور ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'الملفات ($count)';
  }

  @override
  String get mediaNoPhotos => 'لا توجد صور بعد';

  @override
  String get mediaNoFiles => 'لا توجد ملفات بعد';

  @override
  String mediaSavedToDownloads(String name) {
    return 'تم الحفظ في التنزيلات/$name';
  }

  @override
  String get mediaFailedToSave => 'فشل حفظ الملف';

  @override
  String get statusNewStatus => 'حالة جديدة';

  @override
  String get statusPublish => 'نشر';

  @override
  String get statusExpiresIn24h => 'تنتهي صلاحية الحالة خلال 24 ساعة';

  @override
  String get statusWhatsOnYourMind => 'بمَ تفكر؟';

  @override
  String get statusPhotoAttached => 'تم إرفاق صورة';

  @override
  String get statusAttachPhoto => 'إرفاق صورة (اختياري)';

  @override
  String get statusEnterText => 'يرجى إدخال نص للحالة.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'فشل اختيار الصورة: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'فشل النشر: $error';
  }

  @override
  String get panicSetPanicKey => 'تعيين مفتاح الطوارئ';

  @override
  String get panicEmergencySelfDestruct => 'التدمير الذاتي الطارئ';

  @override
  String get panicIrreversible => 'هذا الإجراء لا رجعة فيه';

  @override
  String get panicWarningBody =>
      'إدخال هذا المفتاح في شاشة القفل يمسح فورًا جميع البيانات — الرسائل وجهات الاتصال والمفاتيح والهوية. استخدم مفتاحًا مختلفًا عن كلمة مرورك العادية.';

  @override
  String get panicKeyHint => 'مفتاح الطوارئ';

  @override
  String get panicConfirmHint => 'تأكيد مفتاح الطوارئ';

  @override
  String get panicMinChars => 'يجب أن يكون مفتاح الطوارئ 8 أحرف على الأقل';

  @override
  String get panicKeysDoNotMatch => 'المفتاحان غير متطابقين';

  @override
  String get panicSetFailed => 'فشل حفظ مفتاح الطوارئ — يرجى المحاولة مجددًا';

  @override
  String get passwordSetAppPassword => 'تعيين كلمة مرور التطبيق';

  @override
  String get passwordProtectsMessages => 'تحمي رسائلك أثناء التخزين';

  @override
  String get passwordInfoBanner =>
      'مطلوبة في كل مرة تفتح فيها Pulse. إذا نسيتها، لا يمكن استرداد بياناتك.';

  @override
  String get passwordHint => 'كلمة المرور';

  @override
  String get passwordConfirmHint => 'تأكيد كلمة المرور';

  @override
  String get passwordSetButton => 'تعيين كلمة المرور';

  @override
  String get passwordSkipForNow => 'تخطّي الآن';

  @override
  String get passwordMinChars => 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';

  @override
  String get passwordNeedsVariety =>
      'يجب أن تتضمن حروفًا وأرقامًا ورموزًا خاصة';

  @override
  String get passwordRequirements => '8 أحرف كحد أدنى مع حروف وأرقام ورمز خاص';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get profileCardSaved => 'تم حفظ الملف الشخصي!';

  @override
  String get profileCardE2eeIdentity => 'E2EE Identity';

  @override
  String get profileCardDisplayName => 'اسم العرض';

  @override
  String get profileCardDisplayNameHint => 'مثال: أحمد محمد';

  @override
  String get profileCardAbout => 'نبذة';

  @override
  String get profileCardSaveProfile => 'حفظ الملف الشخصي';

  @override
  String get profileCardYourName => 'اسمك';

  @override
  String get profileCardAddressCopied => 'تم نسخ العنوان!';

  @override
  String get profileCardInboxAddress => 'عنوان صندوق الوارد';

  @override
  String get profileCardInboxAddresses => 'عناوين صندوق الوارد';

  @override
  String get profileCardShareAllAddresses =>
      'مشاركة جميع العناوين (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'شاركها مع جهات اتصالك ليتمكنوا من مراسلتك.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'تم نسخ جميع العناوين ($count) كرابط واحد!';
  }

  @override
  String get settingsMyProfile => 'ملفي الشخصي';

  @override
  String get settingsYourInboxAddress => 'عنوان صندوق الوارد';

  @override
  String get settingsMyQrCode => 'مشاركة جهة اتصال';

  @override
  String get settingsMyQrSubtitle => 'رمز QR ورابط دعوة لعنوانك';

  @override
  String get settingsShareMyAddress => 'مشاركة عنواني';

  @override
  String get settingsNoAddressYet => 'لا يوجد عنوان بعد — احفظ الإعدادات أولاً';

  @override
  String get settingsInviteLink => 'رابط الدعوة';

  @override
  String get settingsRawAddress => 'العنوان الخام';

  @override
  String get settingsCopyLink => 'نسخ الرابط';

  @override
  String get settingsCopyAddress => 'نسخ العنوان';

  @override
  String get settingsInviteLinkCopied => 'تم نسخ رابط الدعوة';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsThemeEngine => 'محرك السمات';

  @override
  String get settingsThemeEngineSubtitle => 'تخصيص الألوان والخطوط';

  @override
  String get settingsSignalProtocol => 'بروتوكول Signal';

  @override
  String get settingsSignalProtocolSubtitle => 'مفاتيح E2EE مخزّنة بأمان';

  @override
  String get settingsActive => 'نشط';

  @override
  String get settingsIdentityBackup => 'نسخ احتياطي للهوية';

  @override
  String get settingsIdentityBackupSubtitle => 'تصدير أو استيراد هوية Signal';

  @override
  String get settingsIdentityBackupBody =>
      'صدّر مفاتيح هوية Signal إلى رمز نسخ احتياطي، أو استعدها من رمز موجود.';

  @override
  String get settingsTransferDevice => 'النقل إلى جهاز آخر';

  @override
  String get settingsTransferDeviceSubtitle =>
      'انقل هويتك عبر الشبكة المحلية أو وسيط Nostr';

  @override
  String get settingsExportIdentity => 'تصدير الهوية';

  @override
  String get settingsExportIdentityBody =>
      'انسخ رمز النسخ الاحتياطي واحفظه بأمان:';

  @override
  String get settingsSaveFile => 'حفظ الملف';

  @override
  String get settingsImportIdentity => 'استيراد الهوية';

  @override
  String get settingsImportIdentityBody =>
      'الصق رمز النسخ الاحتياطي أدناه. سيؤدي هذا إلى استبدال هويتك الحالية.';

  @override
  String get settingsPasteBackupCode => 'الصق رمز النسخ الاحتياطي هنا…';

  @override
  String get settingsIdentityImported =>
      'تم استيراد الهوية + جهات الاتصال! أعد تشغيل التطبيق للتطبيق.';

  @override
  String get settingsSecurity => 'الأمان';

  @override
  String get settingsAppPassword => 'كلمة مرور التطبيق';

  @override
  String get settingsPasswordEnabled => 'مفعّل — مطلوبة عند كل تشغيل';

  @override
  String get settingsPasswordDisabled => 'معطّل — يفتح التطبيق بدون كلمة مرور';

  @override
  String get settingsChangePassword => 'تغيير كلمة المرور';

  @override
  String get settingsChangePasswordSubtitle => 'تحديث كلمة مرور قفل التطبيق';

  @override
  String get settingsSetPanicKey => 'تعيين مفتاح الطوارئ';

  @override
  String get settingsChangePanicKey => 'تغيير مفتاح الطوارئ';

  @override
  String get settingsPanicKeySetSubtitle => 'تحديث مفتاح المسح الطارئ';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'مفتاح واحد يمسح جميع البيانات فورًا';

  @override
  String get settingsRemovePanicKey => 'إزالة مفتاح الطوارئ';

  @override
  String get settingsRemovePanicKeySubtitle => 'تعطيل التدمير الذاتي الطارئ';

  @override
  String get settingsRemovePanicKeyBody =>
      'سيتم تعطيل التدمير الذاتي الطارئ. يمكنك إعادة تفعيله في أي وقت.';

  @override
  String get settingsDisableAppPassword => 'تعطيل كلمة مرور التطبيق';

  @override
  String get settingsEnterCurrentPassword => 'أدخل كلمة المرور الحالية للتأكيد';

  @override
  String get settingsCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get settingsIncorrectPassword => 'كلمة مرور غير صحيحة';

  @override
  String get settingsPasswordUpdated => 'تم تحديث كلمة المرور';

  @override
  String get settingsChangePasswordProceed =>
      'أدخل كلمة المرور الحالية للمتابعة';

  @override
  String get settingsData => 'البيانات';

  @override
  String get settingsBackupMessages => 'نسخ احتياطي للرسائل';

  @override
  String get settingsBackupMessagesSubtitle =>
      'تصدير سجل الرسائل المشفّر إلى ملف';

  @override
  String get settingsRestoreMessages => 'استعادة الرسائل';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'استيراد الرسائل من ملف نسخ احتياطي';

  @override
  String get settingsExportKeys => 'تصدير المفاتيح';

  @override
  String get settingsExportKeysSubtitle => 'حفظ مفاتيح الهوية في ملف مشفّر';

  @override
  String get settingsImportKeys => 'استيراد المفاتيح';

  @override
  String get settingsImportKeysSubtitle => 'استعادة مفاتيح الهوية من ملف مصدّر';

  @override
  String get settingsBackupPassword => 'كلمة مرور النسخ الاحتياطي';

  @override
  String get settingsPasswordCannotBeEmpty =>
      'كلمة المرور لا يمكن أن تكون فارغة';

  @override
  String get settingsPasswordMin4Chars =>
      'يجب أن تكون كلمة المرور 4 أحرف على الأقل';

  @override
  String get settingsCallsTurn => 'المكالمات و TURN';

  @override
  String get settingsLocalNetwork => 'الشبكة المحلية';

  @override
  String get settingsCensorshipResistance => 'مقاومة الرقابة';

  @override
  String get settingsNetwork => 'الشبكة';

  @override
  String get settingsProxyTunnels => 'الوكيل والأنفاق';

  @override
  String get settingsTurnServers => 'خوادم TURN';

  @override
  String get settingsProviderTitle => 'المزوّد';

  @override
  String get settingsLanFallback => 'الرجوع إلى الشبكة المحلية';

  @override
  String get settingsLanFallbackSubtitle =>
      'بث التواجد وتسليم الرسائل عبر الشبكة المحلية عند عدم توفر الإنترنت. عطّله على الشبكات غير الموثوقة (Wi-Fi العامة).';

  @override
  String get settingsBgDelivery => 'التسليم في الخلفية';

  @override
  String get settingsBgDeliverySubtitle =>
      'استمر في استقبال الرسائل عند تصغير التطبيق. يعرض إشعارًا دائمًا.';

  @override
  String get settingsYourInboxProvider => 'مزوّد صندوق الوارد';

  @override
  String get settingsConnectionDetails => 'تفاصيل الاتصال';

  @override
  String get settingsSaveAndConnect => 'حفظ والاتصال';

  @override
  String get settingsSecondaryInboxes => 'صناديق وارد ثانوية';

  @override
  String get settingsAddSecondaryInbox => 'إضافة صندوق وارد ثانوي';

  @override
  String get settingsAdvanced => 'متقدم';

  @override
  String get settingsDiscover => 'اكتشاف';

  @override
  String get settingsAbout => 'حول';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get settingsPrivacyPolicySubtitle => 'كيف يحمي Pulse بياناتك';

  @override
  String get settingsCrashReporting => 'تقارير الأعطال';

  @override
  String get settingsCrashReportingSubtitle =>
      'إرسال تقارير أعطال مجهولة لتحسين Pulse. لا يتم إرسال محتوى الرسائل أو جهات الاتصال أبدًا.';

  @override
  String get settingsCrashReportingEnabled =>
      'تم تفعيل تقارير الأعطال — أعد تشغيل التطبيق للتطبيق';

  @override
  String get settingsCrashReportingDisabled =>
      'تم تعطيل تقارير الأعطال — أعد تشغيل التطبيق للتطبيق';

  @override
  String get settingsSensitiveOperation => 'عملية حساسة';

  @override
  String get settingsSensitiveOperationBody =>
      'هذه المفاتيح هي هويتك. أي شخص يملك هذا الملف يمكنه انتحال شخصيتك. احفظه بأمان واحذفه بعد النقل.';

  @override
  String get settingsIUnderstandContinue => 'أفهم، متابعة';

  @override
  String get settingsReplaceIdentity => 'استبدال الهوية؟';

  @override
  String get settingsReplaceIdentityBody =>
      'سيؤدي هذا إلى استبدال مفاتيح هويتك الحالية. ستصبح جلسات Signal الحالية غير صالحة وسيحتاج جهات الاتصال إلى إعادة إنشاء التشفير. سيحتاج التطبيق إلى إعادة التشغيل.';

  @override
  String get settingsReplaceKeys => 'استبدال المفاتيح';

  @override
  String get settingsKeysImported => 'تم استيراد المفاتيح';

  @override
  String settingsKeysImportedBody(int count) {
    return 'تم استيراد $count مفتاح بنجاح. يرجى إعادة تشغيل التطبيق لإعادة التهيئة بالهوية الجديدة.';
  }

  @override
  String get settingsRestartNow => 'إعادة التشغيل الآن';

  @override
  String get settingsLater => 'لاحقًا';

  @override
  String get profileGroupLabel => 'مجموعة';

  @override
  String get profileAddButton => 'إضافة';

  @override
  String get profileKickButton => 'طرد';

  @override
  String get dataSectionTitle => 'البيانات';

  @override
  String get dataBackupMessages => 'نسخ احتياطي للرسائل';

  @override
  String get dataBackupPasswordSubtitle =>
      'اختر كلمة مرور لتشفير نسخة الرسائل الاحتياطية.';

  @override
  String get dataBackupConfirmLabel => 'إنشاء نسخة احتياطية';

  @override
  String get dataCreatingBackup => 'جارٍ إنشاء نسخة احتياطية';

  @override
  String get dataBackupPreparing => 'جارٍ التحضير...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'جارٍ تصدير الرسالة $done من $total...';
  }

  @override
  String get dataBackupSavingFile => 'جارٍ حفظ الملف...';

  @override
  String get dataSaveMessageBackupDialog => 'حفظ نسخة الرسائل الاحتياطية';

  @override
  String dataBackupSaved(int count, String path) {
    return 'تم حفظ النسخة الاحتياطية ($count رسالة)\n$path';
  }

  @override
  String get dataBackupFailed => 'فشل النسخ الاحتياطي — لم يتم تصدير بيانات';

  @override
  String dataBackupFailedError(String error) {
    return 'فشل النسخ الاحتياطي: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'اختر نسخة الرسائل الاحتياطية';

  @override
  String get dataInvalidBackupFile => 'ملف نسخ احتياطي غير صالح (صغير جدًا)';

  @override
  String get dataNotValidBackupFile => 'ليس ملف نسخ احتياطي صالح لـ Pulse';

  @override
  String get dataRestoreMessages => 'استعادة الرسائل';

  @override
  String get dataRestorePasswordSubtitle =>
      'أدخل كلمة المرور المستخدمة لإنشاء هذه النسخة الاحتياطية.';

  @override
  String get dataRestoreConfirmLabel => 'استعادة';

  @override
  String get dataRestoringMessages => 'جارٍ استعادة الرسائل';

  @override
  String get dataRestoreDecrypting => 'جارٍ فك التشفير...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'جارٍ استيراد الرسالة $done من $total...';
  }

  @override
  String get dataRestoreFailed =>
      'فشلت الاستعادة — كلمة مرور خاطئة أو ملف تالف';

  @override
  String dataRestoreSuccess(int count) {
    return 'تم استعادة $count رسالة جديدة';
  }

  @override
  String get dataRestoreNothingNew =>
      'لا توجد رسائل جديدة للاستيراد (جميعها موجودة بالفعل)';

  @override
  String dataRestoreFailedError(String error) {
    return 'فشلت الاستعادة: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'اختر ملف تصدير المفاتيح';

  @override
  String get dataNotValidKeyFile => 'ليس ملف تصدير مفاتيح صالح لـ Pulse';

  @override
  String get dataExportKeys => 'تصدير المفاتيح';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'اختر كلمة مرور لتشفير تصدير المفاتيح.';

  @override
  String get dataExportKeysConfirmLabel => 'تصدير';

  @override
  String get dataExportingKeys => 'جارٍ تصدير المفاتيح';

  @override
  String get dataExportingKeysStatus => 'جارٍ تشفير مفاتيح الهوية...';

  @override
  String get dataSaveKeyExportDialog => 'حفظ تصدير المفاتيح';

  @override
  String dataKeysExportedTo(String path) {
    return 'تم تصدير المفاتيح إلى:\n$path';
  }

  @override
  String get dataExportFailed => 'فشل التصدير — لم يتم العثور على مفاتيح';

  @override
  String dataExportFailedError(String error) {
    return 'فشل التصدير: $error';
  }

  @override
  String get dataImportKeys => 'استيراد المفاتيح';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'أدخل كلمة المرور المستخدمة لتشفير تصدير المفاتيح.';

  @override
  String get dataImportKeysConfirmLabel => 'استيراد';

  @override
  String get dataImportingKeys => 'جارٍ استيراد المفاتيح';

  @override
  String get dataImportingKeysStatus => 'جارٍ فك تشفير مفاتيح الهوية...';

  @override
  String get dataImportFailed => 'فشل الاستيراد — كلمة مرور خاطئة أو ملف تالف';

  @override
  String dataImportFailedError(String error) {
    return 'فشل الاستيراد: $error';
  }

  @override
  String get securitySectionTitle => 'الأمان';

  @override
  String get securityIncorrectPassword => 'كلمة مرور غير صحيحة';

  @override
  String get securityPasswordUpdated => 'تم تحديث كلمة المرور';

  @override
  String get appearanceSectionTitle => 'المظهر';

  @override
  String appearanceExportFailed(String error) {
    return 'فشل التصدير: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'تم الحفظ في $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'فشل الحفظ: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'فشل الاستيراد: $error';
  }

  @override
  String get aboutSectionTitle => 'حول';

  @override
  String get providerPublicKey => 'المفتاح العام';

  @override
  String get providerRelay => 'الوسيط';

  @override
  String get providerAutoConfigured =>
      'تم الإعداد تلقائيًا من كلمة مرور الاسترداد. تم اكتشاف الوسيط تلقائيًا.';

  @override
  String get providerKeyStoredLocally =>
      'مفتاحك مخزّن محليًا في التخزين الآمن — لا يُرسل أبدًا إلى أي خادم.';

  @override
  String get providerSessionInfo =>
      'Session Network — تشفير E2EE بالتوجيه البصلي. يتم إنشاء معرف Session تلقائيًا وتخزينه بأمان. يتم اكتشاف العقد تلقائيًا من عقد البذور المدمجة.';

  @override
  String get providerAdvanced => 'متقدم';

  @override
  String get providerSaveAndConnect => 'حفظ والاتصال';

  @override
  String get providerAddSecondaryInbox => 'إضافة صندوق وارد ثانوي';

  @override
  String get providerSecondaryInboxes => 'صناديق وارد ثانوية';

  @override
  String get providerYourInboxProvider => 'مزوّد صندوق الوارد';

  @override
  String get providerConnectionDetails => 'تفاصيل الاتصال';

  @override
  String get addContactTitle => 'إضافة جهة اتصال';

  @override
  String get addContactInviteLinkLabel => 'رابط الدعوة أو العنوان';

  @override
  String get addContactTapToPaste => 'اضغط للصق رابط الدعوة';

  @override
  String get addContactPasteTooltip => 'لصق من الحافظة';

  @override
  String get addContactAddressDetected => 'تم اكتشاف عنوان جهة الاتصال';

  @override
  String addContactRoutesDetected(int count) {
    return 'تم اكتشاف $count مسارات — SmartRouter يختار الأسرع';
  }

  @override
  String get addContactFetchingProfile => 'جارٍ جلب الملف الشخصي…';

  @override
  String addContactProfileFound(String name) {
    return 'تم العثور على: $name';
  }

  @override
  String get addContactNoProfileFound => 'لم يتم العثور على ملف شخصي';

  @override
  String get addContactDisplayNameLabel => 'اسم العرض';

  @override
  String get addContactDisplayNameHint => 'ماذا تريد أن تسميهم؟';

  @override
  String get addContactAddManually => 'إضافة العنوان يدويًا';

  @override
  String get addContactButton => 'إضافة جهة اتصال';

  @override
  String get networkDiagnosticsTitle => 'تشخيصات الشبكة';

  @override
  String get networkDiagnosticsNostrRelays => 'وسطاء Nostr';

  @override
  String get networkDiagnosticsDirect => 'مباشر';

  @override
  String get networkDiagnosticsTorOnly => 'عبر Tor فقط';

  @override
  String get networkDiagnosticsBest => 'الأفضل';

  @override
  String get networkDiagnosticsNone => 'لا شيء';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'الحالة';

  @override
  String get networkDiagnosticsConnected => 'متصل';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'جارٍ الاتصال $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'متوقف';

  @override
  String get networkDiagnosticsTransport => 'النقل';

  @override
  String get networkDiagnosticsInfrastructure => 'البنية التحتية';

  @override
  String get networkDiagnosticsSessionNodes => 'عقد Session';

  @override
  String get networkDiagnosticsTurnServers => 'خوادم TURN';

  @override
  String get networkDiagnosticsLastProbe => 'آخر فحص';

  @override
  String get networkDiagnosticsRunning => 'جارٍ التشغيل...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'تشغيل التشخيصات';

  @override
  String get networkDiagnosticsForceReprobe => 'فرض إعادة فحص كامل';

  @override
  String get networkDiagnosticsJustNow => 'الآن';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'منذ $minutes دقيقة';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'منذ $hours ساعة';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'منذ $days يوم';
  }

  @override
  String get homeNoEch => 'No ECH';

  @override
  String get homeNoEchTooltip =>
      'وكيل uTLS غير متاح — ECH معطّل.\nبصمة TLS مرئية لـ DPI.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'تم الحفظ والاتصال بـ $provider';
  }

  @override
  String get settingsTorFailedToStart => 'فشل تشغيل Tor المدمج';

  @override
  String get settingsPsiphonFailedToStart => 'فشل تشغيل Psiphon';

  @override
  String get verifyTitle => 'التحقق من رقم الأمان';

  @override
  String get verifyIdentityVerified => 'تم التحقق من الهوية';

  @override
  String get verifyNotYetVerified => 'لم يتم التحقق بعد';

  @override
  String verifyVerifiedDescription(String name) {
    return 'لقد تحققت من رقم أمان $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'قارن هذه الأرقام مع $name شخصيًا أو عبر قناة موثوقة.';
  }

  @override
  String get verifyExplanation =>
      'لكل محادثة رقم أمان فريد. إذا رأى كلاكما نفس الأرقام على أجهزتكما، فاتصالكما محقق من طرف إلى طرف.';

  @override
  String verifyContactKey(String name) {
    return 'مفتاح $name';
  }

  @override
  String get verifyYourKey => 'مفتاحك';

  @override
  String get verifyRemoveVerification => 'إزالة التحقق';

  @override
  String get verifyMarkAsVerified => 'تمييز كموثّق';

  @override
  String verifyAfterReinstall(String name) {
    return 'إذا أعاد $name تثبيت التطبيق، سيتغير رقم الأمان وسيتم إزالة التحقق تلقائيًا.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'ميّز كموثّق فقط بعد مقارنة الأرقام مع $name عبر مكالمة صوتية أو شخصيًا.';
  }

  @override
  String get verifyNoSession =>
      'لم يتم إنشاء جلسة تشفير بعد. أرسل رسالة أولاً لإنشاء أرقام الأمان.';

  @override
  String get verifyNoKeyAvailable => 'لا يوجد مفتاح متاح';

  @override
  String verifyFingerprintCopied(String label) {
    return 'تم نسخ بصمة $label';
  }

  @override
  String get providerDatabaseUrlLabel => 'رابط قاعدة البيانات';

  @override
  String get providerOptionalHint => 'اختياري';

  @override
  String get providerWebApiKeyLabel => 'مفتاح Web API';

  @override
  String get providerOptionalForPublicDb => 'اختياري لقاعدة البيانات العامة';

  @override
  String get providerRelayUrlLabel => 'رابط الوسيط';

  @override
  String get providerPrivateKeyLabel => 'المفتاح الخاص';

  @override
  String get providerPrivateKeyNsecLabel => 'المفتاح الخاص (nsec)';

  @override
  String get providerStorageNodeLabel => 'رابط عقدة التخزين (اختياري)';

  @override
  String get providerStorageNodeHint =>
      'اتركه فارغًا لاستخدام العقد الأولية المدمجة';

  @override
  String get transferInvalidCodeFormat =>
      'صيغة رمز غير معروفة — يجب أن يبدأ بـ LAN: أو NOS:';

  @override
  String get profileCardFingerprintCopied => 'تم نسخ البصمة';

  @override
  String get profileCardAboutHint => 'الخصوصية أولاً 🔒';

  @override
  String get profileCardSaveButton => 'حفظ الملف الشخصي';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'تصدير الرسائل المشفّرة وجهات الاتصال والصور الرمزية إلى ملف';

  @override
  String get callVideo => 'فيديو';

  @override
  String get callAudio => 'صوت';

  @override
  String bubbleDeliveredTo(String names) {
    return 'تم التسليم إلى $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'تم التسليم إلى $count';
  }

  @override
  String get groupStatusDialogTitle => 'معلومات الرسالة';

  @override
  String get groupStatusRead => 'مقروءة';

  @override
  String get groupStatusDelivered => 'تم التسليم';

  @override
  String get groupStatusPending => 'قيد الانتظار';

  @override
  String get groupStatusNoData => 'لا توجد معلومات تسليم بعد';

  @override
  String get profileTransferAdmin => 'تعيين كمشرف';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'تعيين $name كمشرف جديد؟';
  }

  @override
  String get profileTransferAdminBody =>
      'ستفقد صلاحيات المشرف. لا يمكن التراجع عن هذا.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name أصبح المشرف الآن';
  }

  @override
  String get profileAdminBadge => 'مشرف';

  @override
  String get privacyPolicyTitle => 'سياسة الخصوصية';

  @override
  String get privacyOverviewHeading => 'نظرة عامة';

  @override
  String get privacyOverviewBody =>
      'Pulse هو تطبيق مراسلة بدون خوادم ومشفّر من طرف إلى طرف. خصوصيتك ليست مجرد ميزة — إنها البنية. لا توجد خوادم Pulse. لا يتم تخزين أي حسابات في أي مكان. لا يتم جمع أو نقل أو تخزين أي بيانات بواسطة المطورين.';

  @override
  String get privacyDataCollectionHeading => 'جمع البيانات';

  @override
  String get privacyDataCollectionBody =>
      'Pulse لا يجمع أي بيانات شخصية. تحديدًا:\n\n- لا يُطلب بريد إلكتروني أو رقم هاتف أو اسم حقيقي\n- لا تحليلات أو تتبع أو قياس\n- لا معرّفات إعلانية\n- لا وصول لقائمة جهات الاتصال\n- لا نسخ احتياطي سحابي (الرسائل موجودة فقط على جهازك)\n- لا يتم إرسال بيانات وصفية إلى أي خادم Pulse (لا توجد خوادم)';

  @override
  String get privacyEncryptionHeading => 'التشفير';

  @override
  String get privacyEncryptionBody =>
      'جميع الرسائل مشفّرة باستخدام بروتوكول Signal (Double Ratchet مع اتفاقية مفاتيح X3DH). يتم إنشاء مفاتيح التشفير وتخزينها حصريًا على جهازك. لا أحد — بما في ذلك المطورون — يمكنه قراءة رسائلك.';

  @override
  String get privacyNetworkHeading => 'بنية الشبكة';

  @override
  String get privacyNetworkBody =>
      'يستخدم Pulse محوّلات نقل فيدرالية (وسطاء Nostr، عقد خدمة Session/Oxen، قاعدة بيانات Firebase Realtime، الشبكة المحلية). هذه الوسائط تحمل فقط نصًا مشفّرًا. يمكن لمشغلي الوسطاء رؤية عنوان IP الخاص بك وحجم الحركة، لكن لا يمكنهم فك تشفير محتوى الرسائل.\n\nعند تفعيل Tor، يتم إخفاء عنوان IP الخاص بك أيضًا عن مشغلي الوسطاء.';

  @override
  String get privacyStunHeading => 'خوادم STUN/TURN';

  @override
  String get privacyStunBody =>
      'تستخدم المكالمات الصوتية والمرئية WebRTC مع تشفير DTLS-SRTP. خوادم STUN (المستخدمة لاكتشاف عنوان IP العام للاتصال المباشر) وخوادم TURN (المستخدمة لترحيل الوسائط عند فشل الاتصال المباشر) يمكنها رؤية عنوان IP الخاص بك ومدة المكالمة، لكن لا يمكنها فك تشفير محتوى المكالمة.\n\nيمكنك إعداد خادم TURN خاص بك في الإعدادات لأقصى خصوصية.';

  @override
  String get privacyCrashHeading => 'تقارير الأعطال';

  @override
  String get privacyCrashBody =>
      'إذا تم تفعيل تقارير أعطال Sentry (عبر SENTRY_DSN في وقت البناء)، قد يتم إرسال تقارير أعطال مجهولة. لا تحتوي على محتوى رسائل أو معلومات جهات اتصال أو معلومات شخصية. يمكن تعطيل تقارير الأعطال في وقت البناء بحذف DSN.';

  @override
  String get privacyPasswordHeading => 'كلمة المرور والمفاتيح';

  @override
  String get privacyPasswordBody =>
      'تُستخدم كلمة مرور الاسترداد لاشتقاق مفاتيح التشفير عبر Argon2id (دالة اشتقاق مفاتيح مقاومة للذاكرة). لا يتم نقل كلمة المرور أبدًا. إذا فقدت كلمة المرور، لا يمكن استرداد حسابك — لا يوجد خادم لإعادة تعيينها.';

  @override
  String get privacyFontsHeading => 'الخطوط';

  @override
  String get privacyFontsBody =>
      'Pulse يتضمن جميع الخطوط محليًا. لا يتم إرسال طلبات إلى Google Fonts أو أي خدمة خطوط خارجية.';

  @override
  String get privacyThirdPartyHeading => 'خدمات الطرف الثالث';

  @override
  String get privacyThirdPartyBody =>
      'Pulse لا يتكامل مع أي شبكات إعلانية أو مزوّدي تحليلات أو منصات تواصل اجتماعي أو وسطاء بيانات. الاتصالات الوحيدة هي بوسطاء النقل التي تقوم بإعدادها.';

  @override
  String get privacyOpenSourceHeading => 'مفتوح المصدر';

  @override
  String get privacyOpenSourceBody =>
      'Pulse هو برنامج مفتوح المصدر. يمكنك مراجعة الشفرة المصدرية الكاملة للتحقق من مزاعم الخصوصية هذه.';

  @override
  String get privacyContactHeading => 'التواصل';

  @override
  String get privacyContactBody =>
      'للأسئلة المتعلقة بالخصوصية، افتح مشكلة في مستودع المشروع.';

  @override
  String get privacyLastUpdated => 'آخر تحديث: مارس 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'فشل الحفظ: $error';
  }

  @override
  String get themeEngineTitle => 'محرك السمات';

  @override
  String get torBuiltInTitle => 'Tor المدمج';

  @override
  String get torConnectedSubtitle => 'متصل — Nostr موجّه عبر 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'جارٍ الاتصال… $pct%';
  }

  @override
  String get torNotRunning => 'متوقف — اضغط المفتاح لإعادة التشغيل';

  @override
  String get torDescription =>
      'توجيه Nostr عبر Tor (Snowflake للشبكات الخاضعة للرقابة)';

  @override
  String get torNetworkDiagnostics => 'تشخيصات الشبكة';

  @override
  String get torTransportLabel => 'النقل: ';

  @override
  String get torPtAuto => 'تلقائي';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'عادي';

  @override
  String get torTimeoutLabel => 'المهلة: ';

  @override
  String get torInfoDescription =>
      'عند التفعيل، يتم توجيه اتصالات Nostr WebSocket عبر Tor (SOCKS5). متصفح Tor يستمع على 127.0.0.1:9150. خدمة tor المستقلة تستخدم المنفذ 9050. اتصالات Firebase لا تتأثر.';

  @override
  String get torRouteNostrTitle => 'توجيه Nostr عبر Tor';

  @override
  String get torManagedByBuiltin => 'يُدار بواسطة Tor المدمج';

  @override
  String get torActiveRouting => 'نشط — حركة Nostr موجّهة عبر Tor';

  @override
  String get torDisabled => 'معطّل';

  @override
  String get torProxySocks5 => 'وكيل Tor (SOCKS5)';

  @override
  String get torProxyHostLabel => 'عنوان الوكيل';

  @override
  String get torProxyPortLabel => 'المنفذ';

  @override
  String get torPortInfo => 'متصفح Tor: المنفذ 9150  •  خدمة tor: المنفذ 9050';

  @override
  String get torForceNostrTitle => 'توجيه الرسائل عبر Tor';

  @override
  String get torForceNostrSubtitle =>
      'جميع اتصالات Nostr relay ستمر عبر Tor. أبطأ لكنه يخفي عنوان IP الخاص بك من الـ relay.';

  @override
  String get torForceNostrDisabled => 'يجب تفعيل Tor أولاً';

  @override
  String get torForcePulseTitle => 'توجيه Pulse relay عبر Tor';

  @override
  String get torForcePulseSubtitle =>
      'جميع اتصالات Pulse relay ستمر عبر Tor. أبطأ لكنه يخفي عنوان IP الخاص بك من الخادم.';

  @override
  String get torForcePulseDisabled => 'يجب تفعيل Tor أولاً';

  @override
  String get i2pProxySocks5 => 'وكيل I2P (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'يستخدم I2P منفذ SOCKS5 رقم 4447 افتراضيًا. اتصل بوسيط Nostr عبر وكيل I2P الخارجي (مثل relay.damus.i2p) للتواصل مع المستخدمين على أي وسيلة نقل. Tor له الأولوية عند تفعيل كليهما.';

  @override
  String get i2pRouteNostrTitle => 'توجيه Nostr عبر I2P';

  @override
  String get i2pActiveRouting => 'نشط — حركة Nostr موجّهة عبر I2P';

  @override
  String get i2pDisabled => 'معطّل';

  @override
  String get i2pProxyHostLabel => 'عنوان الوكيل';

  @override
  String get i2pProxyPortLabel => 'المنفذ';

  @override
  String get i2pPortInfo => 'المنفذ الافتراضي لـ SOCKS5 في موجّه I2P: 4447';

  @override
  String get customProxySocks5 => 'وكيل مخصص (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'وسيط CF Worker';

  @override
  String get customProxyInfoDescription =>
      'الوكيل المخصص يوجّه الحركة عبر V2Ray/Xray/Shadowsocks. CF Worker يعمل كوكيل وسيط شخصي على Cloudflare CDN — يرى GFW *.workers.dev وليس الوسيط الحقيقي.';

  @override
  String get customSocks5ProxyTitle => 'وكيل SOCKS5 مخصص';

  @override
  String get customProxyActive => 'نشط — الحركة موجّهة عبر SOCKS5';

  @override
  String get customProxyDisabled => 'معطّل';

  @override
  String get customProxyHostLabel => 'عنوان الوكيل';

  @override
  String get customProxyPortLabel => 'المنفذ';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'نطاق Worker (اختياري)';

  @override
  String get customWorkerHelpTitle => 'كيفية نشر وسيط CF Worker (مجاني)';

  @override
  String get customWorkerScriptCopied => 'تم نسخ السكريبت!';

  @override
  String get customWorkerStep1 =>
      '1. اذهب إلى dash.cloudflare.com → Workers & Pages\n2. أنشئ Worker → الصق هذا السكريبت:\n';

  @override
  String get customWorkerStep2 =>
      '3. انشر → انسخ النطاق (مثال: my-relay.user.workers.dev)\n4. الصق النطاق أعلاه → احفظ\n\nالتطبيق يتصل تلقائيًا: wss://domain/?r=relay_url\nيرى GFW: اتصال بـ *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'متصل — SOCKS5 على 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'جارٍ الاتصال…';

  @override
  String get psiphonNotRunning => 'متوقف — اضغط المفتاح لإعادة التشغيل';

  @override
  String get psiphonDescription =>
      'نفق سريع (~3 ثوانٍ للتمهيد، أكثر من 2000 VPS متناوب)';

  @override
  String get turnCommunityServers => 'خوادم TURN المجتمعية';

  @override
  String get turnCustomServer => 'خادم TURN مخصص (BYOD)';

  @override
  String get turnInfoDescription =>
      'خوادم TURN تنقل فقط التدفقات المشفّرة بالفعل (DTLS-SRTP). يرى مشغل الوسيط عنوان IP الخاص بك وحجم الحركة، لكن لا يمكنه فك تشفير المكالمات. يُستخدم TURN فقط عند فشل الاتصال المباشر (~15–20% من الاتصالات).';

  @override
  String get turnFreeLabel => 'مجاني';

  @override
  String get turnServerUrlLabel => 'رابط خادم TURN';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 أو turns:...';

  @override
  String get turnUsernameLabel => 'اسم المستخدم';

  @override
  String get turnPasswordLabel => 'كلمة المرور';

  @override
  String get turnOptionalHint => 'اختياري';

  @override
  String get turnCustomInfo =>
      'استضف coturn ذاتيًا على أي VPS بسعر \$5/شهر للتحكم الكامل. يتم تخزين بيانات الاعتماد محليًا.';

  @override
  String get themePickerAppearance => 'المظهر';

  @override
  String get themePickerAccentColor => 'اللون المميز';

  @override
  String get themeModeLight => 'فاتح';

  @override
  String get themeModeDark => 'داكن';

  @override
  String get themeModeSystem => 'النظام';

  @override
  String get themeDynamicPresets => 'القوالب';

  @override
  String get themeDynamicPrimaryColor => 'اللون الأساسي';

  @override
  String get themeDynamicBorderRadius => 'نصف قطر الحدود';

  @override
  String get themeDynamicFont => 'الخط';

  @override
  String get themeDynamicAppearance => 'المظهر';

  @override
  String get themeDynamicUiStyle => 'نمط الواجهة';

  @override
  String get themeDynamicUiStyleDescription =>
      'يتحكم في مظهر الحوارات والمفاتيح والمؤشرات.';

  @override
  String get themeDynamicSharp => 'حاد';

  @override
  String get themeDynamicRound => 'مستدير';

  @override
  String get themeDynamicModeDark => 'داكن';

  @override
  String get themeDynamicModeLight => 'فاتح';

  @override
  String get themeDynamicModeAuto => 'تلقائي';

  @override
  String get themeDynamicPlatformAuto => 'تلقائي';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'رابط Firebase غير صالح. المتوقع https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'رابط الوسيط غير صالح. المتوقع wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'رابط خادم Pulse غير صالح. المتوقع https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'رابط الخادم';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'رمز الدعوة';

  @override
  String get providerPulseInviteHint => 'رمز الدعوة (إن وجد)';

  @override
  String get providerPulseInfo =>
      'وسيط مستضاف ذاتيًا. المفاتيح مشتقة من كلمة مرور الاسترداد.';

  @override
  String get providerScreenTitle => 'صناديق الوارد';

  @override
  String get providerSecondaryInboxesHeader => 'صناديق الوارد الثانوية';

  @override
  String get providerSecondaryInboxesInfo =>
      'صناديق الوارد الثانوية تستقبل الرسائل بالتوازي للتكرار.';

  @override
  String get providerRemoveTooltip => 'إزالة';

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
  String get emojiNoRecent => 'لا توجد رموز تعبيرية حديثة';

  @override
  String get emojiSearchHint => 'البحث عن رمز تعبيري...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'اضغط للمحادثة';

  @override
  String get imageViewerSaveToDownloads => 'حفظ في التنزيلات';

  @override
  String imageViewerSavedTo(String path) {
    return 'تم الحفظ في $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'حسنًا';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageSubtitle => 'لغة عرض التطبيق';

  @override
  String get settingsLanguageSystem => 'افتراضي النظام';

  @override
  String get onboardingLanguageTitle => 'اختر لغتك';

  @override
  String get onboardingLanguageSubtitle =>
      'يمكنك تغيير هذا لاحقًا في الإعدادات';

  @override
  String get videoNoteRecord => 'تسجيل رسالة فيديو';

  @override
  String get videoNoteTapToRecord => 'اضغط للتسجيل';

  @override
  String get videoNoteTapToStop => 'اضغط للإيقاف';

  @override
  String get videoNoteCameraPermission => 'تم رفض إذن الكاميرا';

  @override
  String get videoNoteMaxDuration => 'الحد الأقصى 30 ثانية';

  @override
  String get videoNoteNotSupported => 'رسائل الفيديو غير مدعومة على هذه المنصة';

  @override
  String get navChats => 'المحادثات';

  @override
  String get navUpdates => 'التحديثات';

  @override
  String get navCalls => 'المكالمات';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterUnread => 'غير مقروء';

  @override
  String get filterGroups => 'المجموعات';

  @override
  String get callsNoRecent => 'لا توجد مكالمات حديثة';

  @override
  String get callsEmptySubtitle => 'سيظهر سجل مكالماتك هنا';

  @override
  String get appBarEncrypted => 'مشفر من طرف إلى طرف';

  @override
  String get newStatus => 'حالة جديدة';

  @override
  String get newCall => 'مكالمة جديدة';

  @override
  String get joinChannelTitle => 'انضم إلى القناة';

  @override
  String get joinChannelDescription => 'رابط القناة';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'جارٍ جلب معلومات القناة…';

  @override
  String get joinChannelNotFound => 'لم يتم العثور على قناة في هذا الرابط';

  @override
  String get joinChannelNetworkError => 'تعذّر الوصول إلى الخادم';

  @override
  String get joinChannelAlreadyJoined => 'منضم بالفعل';

  @override
  String get joinChannelButton => 'انضمام';

  @override
  String get channelFeedEmpty => 'لا توجد منشورات بعد';

  @override
  String get channelLeave => 'مغادرة القناة';

  @override
  String get channelLeaveConfirm =>
      'مغادرة هذه القناة؟ ستُحذف المنشورات المخزنة مؤقتاً.';

  @override
  String get channelInfo => 'معلومات القناة';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'معدّل';

  @override
  String get channelLoadMore => 'تحميل المزيد';

  @override
  String get channelSearchPosts => 'بحث في المنشورات…';

  @override
  String get channelNoResults => 'لا توجد منشورات مطابقة';

  @override
  String get channelUrl => 'رابط القناة';

  @override
  String get channelCreated => 'انضممت';

  @override
  String channelPostCount(int count) {
    return '$count منشور';
  }

  @override
  String get channelCopyUrl => 'نسخ الرابط';

  @override
  String get setupNext => 'التالي';

  @override
  String get setupKeyWarning =>
      'سيتم إنشاء مفتاح استرداد لك. هذه هي الطريقة الوحيدة لاستعادة حسابك على جهاز جديد — لا يوجد خادم، لا يوجد إعادة تعيين كلمة مرور.';

  @override
  String get setupKeyTitle => 'مفتاح الاسترداد الخاص بك';

  @override
  String get setupKeySubtitle =>
      'اكتب هذا المفتاح واحفظه في مكان آمن. ستحتاجه لاستعادة حسابك على جهاز جديد.';

  @override
  String get setupKeyCopied => 'تم النسخ!';

  @override
  String get setupKeyWroteItDown => 'لقد كتبته';

  @override
  String get setupKeyWarnBody =>
      'اكتب هذا المفتاح كنسخة احتياطية. يمكنك أيضًا عرضه لاحقًا في الإعدادات → الأمان.';

  @override
  String get setupVerifyTitle => 'التحقق من مفتاح الاسترداد';

  @override
  String get setupVerifySubtitle =>
      'أعد إدخال مفتاح الاسترداد للتأكد من أنك حفظته بشكل صحيح.';

  @override
  String get setupVerifyButton => 'تحقق';

  @override
  String get setupKeyMismatch => 'المفتاح غير متطابق. تحقق وحاول مرة أخرى.';

  @override
  String get setupSkipVerify => 'تخطي التحقق';

  @override
  String get setupSkipVerifyTitle => 'تخطي التحقق؟';

  @override
  String get setupSkipVerifyBody =>
      'إذا فقدت مفتاح الاسترداد، لا يمكن استعادة حسابك. هل أنت متأكد؟';

  @override
  String get setupCreatingAccount => 'جارٍ إنشاء الحساب…';

  @override
  String get setupRestoringAccount => 'جارٍ استعادة الحساب…';

  @override
  String get restoreKeyInfoBanner =>
      'أدخل مفتاح الاسترداد — سيتم استعادة عنوانك (Nostr + Session) تلقائيًا. جهات الاتصال والرسائل كانت مخزنة محليًا فقط.';

  @override
  String get restoreKeyHint => 'مفتاح الاسترداد';

  @override
  String get settingsViewRecoveryKey => 'عرض مفتاح الاسترداد';

  @override
  String get settingsViewRecoveryKeySubtitle => 'عرض مفتاح استرداد الحساب';

  @override
  String get settingsRecoveryKeyNotStored =>
      'مفتاح الاسترداد غير متاح (تم إنشاؤه قبل هذه الميزة)';

  @override
  String get settingsRecoveryKeyWarning =>
      'احتفظ بهذا المفتاح في مكان آمن. أي شخص يملكه يمكنه استعادة حسابك على جهاز آخر.';

  @override
  String get replaceIdentityTitle => 'استبدال الهوية الحالية؟';

  @override
  String get replaceIdentityBodyRestore =>
      'توجد هوية بالفعل على هذا الجهاز. الاستعادة ستستبدل نهائيًا مفتاح Nostr الحالي وبذرة Oxen. ستفقد جميع جهات الاتصال القدرة على الوصول إلى عنوانك الحالي.\n\nلا يمكن التراجع عن هذا.';

  @override
  String get replaceIdentityBodyCreate =>
      'توجد هوية بالفعل على هذا الجهاز. إنشاء هوية جديدة سيستبدل نهائيًا مفتاح Nostr الحالي وبذرة Oxen. ستفقد جميع جهات الاتصال القدرة على الوصول إلى عنوانك الحالي.\n\nلا يمكن التراجع عن هذا.';

  @override
  String get replace => 'استبدال';

  @override
  String get callNoScreenSources => 'لا توجد مصادر شاشة متاحة';

  @override
  String get callScreenShareQuality => 'جودة مشاركة الشاشة';

  @override
  String get callFrameRate => 'معدل الإطارات';

  @override
  String get callResolution => 'الدقة';

  @override
  String get callAutoResolution => 'تلقائي = دقة الشاشة الأصلية';

  @override
  String get callStartSharing => 'بدء المشاركة';

  @override
  String get callCameraUnavailable =>
      'الكاميرا غير متاحة — قد تكون قيد الاستخدام من تطبيق آخر';

  @override
  String get themeResetToDefaults => 'إعادة التعيين إلى الافتراضي';

  @override
  String get backupSaveToDownloadsTitle =>
      'حفظ النسخة الاحتياطية في التنزيلات؟';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'لا يتوفر منتقي ملفات. سيتم حفظ النسخة الاحتياطية في:\n$path';
  }

  @override
  String get systemLabel => 'النظام';

  @override
  String get next => 'التالي';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return '$remaining نقرات أخرى لتفعيل وضع المطور';
  }

  @override
  String get devModeEnabled => 'تم تفعيل وضع المطور';

  @override
  String get devTools => 'أدوات المطور';

  @override
  String get devAdapterDiagnostics => 'تبديلات المحول والتشخيصات';

  @override
  String get devEnableAll => 'تمكين الكل';

  @override
  String get devDisableAll => 'تعطيل الكل';

  @override
  String get turnUrlValidation =>
      'يجب أن يبدأ عنوان TURN بـ turn: أو turns: (512 حرفًا كحد أقصى)';

  @override
  String get callMissedCall => 'مكالمة فائتة';

  @override
  String get callOutgoingCall => 'مكالمة صادرة';

  @override
  String get callIncomingCall => 'مكالمة واردة';

  @override
  String get mediaMissingData => 'بيانات الوسائط مفقودة';

  @override
  String get mediaDownloadFailed => 'فشل التنزيل';

  @override
  String get mediaDecryptFailed => 'فشل فك التشفير';

  @override
  String get callEndCallBanner => 'إنهاء المكالمة';

  @override
  String get meFallback => 'أنا';

  @override
  String get imageSaveToDownloads => 'حفظ في التنزيلات';

  @override
  String imageSavedToPath(String path) {
    return 'تم الحفظ في $path';
  }

  @override
  String get callScreenShareRequiresPermission => 'مشاركة الشاشة تتطلب إذنًا';

  @override
  String get callScreenShareUnavailable => 'مشاركة الشاشة غير متاحة';

  @override
  String get statusJustNow => 'الآن';

  @override
  String statusMinutesAgo(int minutes) {
    return 'قبل $minutes دقيقة';
  }

  @override
  String statusHoursAgo(int hours) {
    return 'قبل $hours ساعة';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مسارات',
      one: 'مسار واحد',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => 'جاهز للإضافة';

  @override
  String groupSelectedCount(int count) {
    return '$count محدد';
  }

  @override
  String get paste => 'لصق';

  @override
  String get sfuAudioOnly => 'صوت فقط';

  @override
  String sfuParticipants(int count) {
    return '$count مشاركين';
  }

  @override
  String get dataUnencryptedBackup => 'نسخة احتياطية غير مشفرة';

  @override
  String get dataUnencryptedBackupBody =>
      'هذا الملف هو نسخة احتياطية غير مشفرة للهوية وسيحل محل مفاتيحك الحالية. استورد فقط الملفات التي أنشأتها بنفسك. هل تريد المتابعة؟';

  @override
  String get dataImportAnyway => 'استيراد على أي حال';

  @override
  String get securityStorageError => 'خطأ في التخزين الآمن — أعد تشغيل التطبيق';

  @override
  String get aboutDevModeActive => 'وضع المطور نشط';

  @override
  String get themeColors => 'الألوان';

  @override
  String get themePrimaryAccent => 'اللون الأساسي';

  @override
  String get themeSecondaryAccent => 'اللون الثانوي';

  @override
  String get themeBackground => 'الخلفية';

  @override
  String get themeSurface => 'السطح';

  @override
  String get themeChatBubbles => 'فقاعات المحادثة';

  @override
  String get themeOutgoingMessage => 'رسالة صادرة';

  @override
  String get themeIncomingMessage => 'رسالة واردة';

  @override
  String get themeShape => 'الشكل';

  @override
  String get devSectionDeveloper => 'المطور';

  @override
  String get devAdapterChannelsHint =>
      'قنوات المحول — عطّل لاختبار وسائل نقل محددة.';

  @override
  String get devNostrRelays => 'Nostr relays (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Session Network';

  @override
  String get devPulseRelay => 'Pulse relay مستضاف ذاتيًا';

  @override
  String get devLanNetwork => 'الشبكة المحلية (UDP/TCP)';

  @override
  String get devSectionCalls => 'المكالمات';

  @override
  String get devForceTurnRelay => 'فرض TURN relay';

  @override
  String get devForceTurnRelaySubtitle =>
      'تعطيل P2P — جميع المكالمات عبر خوادم TURN فقط';

  @override
  String get devRestartWarning =>
      '⚠ تسري التغييرات عند الإرسال/الاتصال التالي. أعد تشغيل التطبيق لتطبيقها على الوارد.';

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
  String get pulseUseServerTitle => 'استخدام خادم Pulse؟';

  @override
  String pulseUseServerBody(String name, String host) {
    return 'يستخدم $name خادم Pulse $host. الانضمام للدردشة بشكل أسرع معه (ومع آخرين على نفس الخادم)؟';
  }

  @override
  String pulseContactUsesPulse(String name) {
    return '$name يستخدم Pulse';
  }

  @override
  String pulseJoinForFaster(String host) {
    return 'انضم إلى $host لدردشة أسرع';
  }

  @override
  String get pulseNotNow => 'ليس الآن';

  @override
  String get pulseJoin => 'انضمام';

  @override
  String get pulseDismiss => 'إغلاق';

  @override
  String get pulseHide7Days => 'إخفاء لمدة 7 أيام';

  @override
  String get pulseNeverAskAgain => 'عدم السؤال مجددًا';

  @override
  String get groupSearchContactsHint => 'البحث في جهات الاتصال…';

  @override
  String get systemActorYou => 'أنت';

  @override
  String get systemActorPeer => 'جهة الاتصال';

  @override
  String systemTtlEnabled(String actor, String duration) {
    return '$actor فعَّل الرسائل المختفية: $duration';
  }

  @override
  String systemTtlDisabled(String actor) {
    return '$actor عطَّل الرسائل المختفية';
  }

  @override
  String get menuClearChatHistory => 'مسح محفوظات الدردشة';

  @override
  String get clearChatTitle => 'مسح محفوظات الدردشة؟';

  @override
  String get clearChatBody =>
      'ستُحذف جميع رسائل هذه الدردشة من هذا الجهاز. سيحتفظ الطرف الآخر بنسخته.';

  @override
  String get clearChatAction => 'مسح';

  @override
  String systemGroupRenamed(String actor, String name) {
    return '$actor غيَّر اسم المجموعة إلى «$name»';
  }

  @override
  String systemGroupAvatarChanged(String actor) {
    return '$actor غيَّر صورة المجموعة';
  }

  @override
  String systemGroupMetaChanged(String actor, String name) {
    return '$actor غيَّر اسم المجموعة إلى «$name» وغيَّر الصورة';
  }

  @override
  String get profileInviteLink => 'رابط الدعوة';

  @override
  String get profileInviteLinkSubtitle => 'يمكن لأي شخص لديه الرابط الانضمام';

  @override
  String get profileInviteLinkCopied => 'تم نسخ رابط الدعوة';

  @override
  String get groupInviteLinkTitle => 'الانضمام إلى المجموعة؟';

  @override
  String groupInviteLinkBody(String name, int count) {
    return 'تمت دعوتك للانضمام إلى «$name» ($count أعضاء).';
  }

  @override
  String get groupInviteLinkJoin => 'انضمام';

  @override
  String get drawerCreateGroup => 'إنشاء مجموعة';

  @override
  String get drawerJoinGroup => 'الانضمام إلى المجموعة';

  @override
  String get drawerJoinGroupByLinkInvalid => 'لا يبدو هذا رابط دعوة Pulse';

  @override
  String get groupModeMeshTitle => 'عادي';

  @override
  String groupModeMeshSubtitle(int n) {
    return 'بدون خادم، حتى $n أشخاص';
  }

  @override
  String get groupModeSfuTitle => 'مع خادم Pulse';

  @override
  String groupModeSfuSubtitle(int n) {
    return 'عبر الخادم، حتى $n أشخاص';
  }

  @override
  String get groupPulseServerHint => 'https://خادم-pulse-الخاص-بك';

  @override
  String get groupPulseServerClosed => 'خادم مغلق (يتطلب رمز دعوة)';

  @override
  String get groupPulseInviteHint => 'رمز الدعوة';

  @override
  String groupMeshLimitReached(int n) {
    return 'هذا النوع من المكالمات محدود بـ $n أشخاص';
  }
}
