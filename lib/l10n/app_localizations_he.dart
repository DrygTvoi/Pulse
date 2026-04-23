// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'חיפוש הודעות...';

  @override
  String get search => 'חיפוש';

  @override
  String get clearSearch => 'נקה חיפוש';

  @override
  String get closeSearch => 'סגור חיפוש';

  @override
  String get moreOptions => 'אפשרויות נוספות';

  @override
  String get back => 'חזרה';

  @override
  String get cancel => 'ביטול';

  @override
  String get close => 'סגור';

  @override
  String get confirm => 'אישור';

  @override
  String get remove => 'הסרה';

  @override
  String get save => 'שמירה';

  @override
  String get add => 'הוספה';

  @override
  String get copy => 'העתקה';

  @override
  String get skip => 'דלג';

  @override
  String get done => 'סיום';

  @override
  String get apply => 'החל';

  @override
  String get export => 'ייצוא';

  @override
  String get import => 'ייבוא';

  @override
  String get homeNewGroup => 'קבוצה חדשה';

  @override
  String get homeSettings => 'הגדרות';

  @override
  String get homeSearching => 'מחפש הודעות...';

  @override
  String get homeNoResults => 'לא נמצאו תוצאות';

  @override
  String get homeNoChatHistory => 'אין עדיין היסטוריית צ׳אט';

  @override
  String homeTransportSwitched(String address) {
    return 'התחבורה הוחלפה → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name מתקשר/ת...';
  }

  @override
  String get homeAccept => 'קבל';

  @override
  String get homeDecline => 'דחה';

  @override
  String get homeLoadEarlier => 'טען הודעות קודמות';

  @override
  String get homeChats => 'צ׳אטים';

  @override
  String get homeSelectConversation => 'בחר שיחה';

  @override
  String get homeNoChatsYet => 'אין עדיין צ׳אטים';

  @override
  String get homeAddContactToStart => 'הוסף איש קשר כדי להתחיל לשוחח';

  @override
  String get homeNewChat => 'צ׳אט חדש';

  @override
  String get homeNewChatTooltip => 'צ׳אט חדש';

  @override
  String get homeIncomingCallTitle => 'שיחה נכנסת';

  @override
  String get homeIncomingGroupCallTitle => 'שיחה קבוצתית נכנסת';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — שיחה קבוצתית נכנסת';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'אין צ׳אטים התואמים ל\"$query\"';
  }

  @override
  String get homeSectionChats => 'צ׳אטים';

  @override
  String get homeSectionMessages => 'הודעות';

  @override
  String get homeDbEncryptionUnavailable =>
      'הצפנת מסד נתונים אינה זמינה — התקן SQLCipher להגנה מלאה';

  @override
  String get chatFileTooLargeGroup =>
      'קבצים מעל 512 KB אינם נתמכים בצ׳אטים קבוצתיים';

  @override
  String get chatLargeFile => 'קובץ גדול';

  @override
  String get chatCancel => 'ביטול';

  @override
  String get chatSend => 'שלח';

  @override
  String get chatFileTooLarge => 'הקובץ גדול מדי — הגודל המרבי הוא 100 MB';

  @override
  String get chatMicDenied => 'הרשאת מיקרופון נדחתה';

  @override
  String get chatVoiceFailed =>
      'לא ניתן לשמור הודעה קולית — בדוק את שטח האחסון הזמין';

  @override
  String get chatScheduleFuture => 'הזמן המתוזמן חייב להיות בעתיד';

  @override
  String get chatToday => 'היום';

  @override
  String get chatYesterday => 'אתמול';

  @override
  String get chatEdited => 'נערך';

  @override
  String get chatYou => 'את/ה';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'קובץ זה הוא $size MB. שליחת קבצים גדולים עלולה להיות איטית ברשתות מסוימות. להמשיך?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'מפתח האבטחה של $name השתנה. הקש/י לאימות.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'לא ניתן להצפין הודעה אל $name — ההודעה לא נשלחה.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'מספר הבטיחות השתנה עבור $name. הקש/י לאימות.';
  }

  @override
  String get chatNoMessagesFound => 'לא נמצאו הודעות';

  @override
  String get chatMessagesE2ee => 'ההודעות מוצפנות מקצה לקצה';

  @override
  String get chatSayHello => 'אמור שלום';

  @override
  String get appBarOnline => 'מחובר';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'מקליד/ה';

  @override
  String get appBarSearchMessages => 'חיפוש הודעות...';

  @override
  String get appBarMute => 'השתק';

  @override
  String get appBarUnmute => 'בטל השתקה';

  @override
  String get appBarMedia => 'מדיה';

  @override
  String get appBarDisappearing => 'הודעות נעלמות';

  @override
  String get appBarDisappearingOn => 'נעלמות: פעיל';

  @override
  String get appBarGroupSettings => 'הגדרות קבוצה';

  @override
  String get appBarSearchTooltip => 'חיפוש הודעות';

  @override
  String get appBarVoiceCall => 'שיחה קולית';

  @override
  String get appBarVideoCall => 'שיחת וידאו';

  @override
  String get inputMessage => 'הודעה...';

  @override
  String get inputAttachFile => 'צרף קובץ';

  @override
  String get inputSendMessage => 'שלח הודעה';

  @override
  String get inputRecordVoice => 'הקלט הודעה קולית';

  @override
  String get inputSendVoice => 'שלח הודעה קולית';

  @override
  String get inputCancelReply => 'בטל תשובה';

  @override
  String get inputCancelEdit => 'בטל עריכה';

  @override
  String get inputCancelRecording => 'בטל הקלטה';

  @override
  String get inputRecording => 'מקליט…';

  @override
  String get inputEditingMessage => 'עורך הודעה';

  @override
  String get inputPhoto => 'תמונה';

  @override
  String get inputVoiceMessage => 'הודעה קולית';

  @override
  String get inputFile => 'קובץ';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'הודעות מתוזמנות',
      one: 'הודעה מתוזמנת',
    );
    return '$count $_temp0';
  }

  @override
  String get callInitializing => 'מאתחל שיחה…';

  @override
  String get callConnecting => 'מתחבר…';

  @override
  String get callConnectingRelay => 'מתחבר (ממסר)…';

  @override
  String get callSwitchingRelay => 'עובר למצב ממסר…';

  @override
  String get callConnectionFailed => 'החיבור נכשל';

  @override
  String get callReconnecting => 'מתחבר מחדש…';

  @override
  String get callEnded => 'השיחה הסתיימה';

  @override
  String get callLive => 'שידור חי';

  @override
  String get callEnd => 'סיום';

  @override
  String get callEndCall => 'סיים שיחה';

  @override
  String get callMute => 'השתק';

  @override
  String get callUnmute => 'בטל השתקה';

  @override
  String get callSpeaker => 'רמקול';

  @override
  String get callCameraOn => 'מצלמה דלוקה';

  @override
  String get callCameraOff => 'מצלמה כבויה';

  @override
  String get callShareScreen => 'שתף מסך';

  @override
  String get callStopShare => 'הפסק שיתוף';

  @override
  String callTorBackup(String duration) {
    return 'גיבוי Tor · $duration';
  }

  @override
  String get callTorBackupBanner => 'גיבוי Tor פעיל — הנתיב הראשי אינו זמין';

  @override
  String get callDirectFailed => 'חיבור ישיר נכשל — עובר למצב ממסר…';

  @override
  String get callTurnUnreachable =>
      'שרתי TURN אינם נגישים. הוסף שרת TURN מותאם אישית בהגדרות → מתקדם.';

  @override
  String get callRelayMode => 'מצב ממסר פעיל (רשת מוגבלת)';

  @override
  String get callStarting => 'מתחיל שיחה…';

  @override
  String get callConnectingToGroup => 'מתחבר לקבוצה…';

  @override
  String get callGroupOpenedInBrowser => 'שיחה קבוצתית נפתחה בדפדפן';

  @override
  String get callCouldNotOpenBrowser => 'לא ניתן לפתוח דפדפן';

  @override
  String get callInviteLinkSent => 'קישור הזמנה נשלח לכל חברי הקבוצה.';

  @override
  String get callOpenLinkManually =>
      'פתח את הקישור למעלה ידנית או הקש לניסיון חוזר.';

  @override
  String get callJitsiNotE2ee => 'שיחות Jitsi אינן מוצפנות מקצה לקצה';

  @override
  String get callRetryOpenBrowser => 'נסה שוב לפתוח דפדפן';

  @override
  String get callClose => 'סגור';

  @override
  String get callCamOn => 'מצלמה דלוקה';

  @override
  String get callCamOff => 'מצלמה כבויה';

  @override
  String get noConnection => 'אין חיבור — ההודעות יעמדו בתור';

  @override
  String get connected => 'מחובר';

  @override
  String get connecting => 'מתחבר…';

  @override
  String get disconnected => 'מנותק';

  @override
  String get offlineBanner => 'אין חיבור — ההודעות יישלחו כשתחזור/י לרשת';

  @override
  String get lanModeBanner => 'מצב LAN — אין אינטרנט · רשת מקומית בלבד';

  @override
  String get probeCheckingNetwork => 'בודק קישוריות רשת…';

  @override
  String get probeDiscoveringRelays => 'מגלה ממסרים דרך ספריות קהילתיות…';

  @override
  String get probeStartingTor => 'מפעיל Tor לאתחול…';

  @override
  String get probeFindingRelaysTor => 'מחפש ממסרים נגישים דרך Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ממסרים',
      one: 'ממסר אחד',
    );
    return 'הרשת מוכנה — נמצא $_temp0';
  }

  @override
  String get probeNoRelaysFound =>
      'לא נמצאו ממסרים נגישים — ייתכן עיכוב בהודעות';

  @override
  String get jitsiWarningTitle => 'לא מוצפן מקצה לקצה';

  @override
  String get jitsiWarningBody =>
      'שיחות Jitsi Meet אינן מוצפנות על ידי Pulse. השתמש/י רק לשיחות שאינן רגישות.';

  @override
  String get jitsiConfirm => 'הצטרף בכל זאת';

  @override
  String get jitsiGroupWarningTitle => 'לא מוצפן מקצה לקצה';

  @override
  String get jitsiGroupWarningBody =>
      'לשיחה זו יש יותר מדי משתתפים עבור רשת מוצפנת מובנית.\n\nקישור Jitsi Meet ייפתח בדפדפן שלך. Jitsi אינו מוצפן מקצה לקצה — השרת יכול לראות את השיחה שלך.';

  @override
  String get jitsiContinueAnyway => 'המשך בכל זאת';

  @override
  String get retry => 'נסה שוב';

  @override
  String get setupCreateAnonymousAccount => 'צור חשבון אנונימי';

  @override
  String get setupTapToChangeColor => 'הקש לשינוי צבע';

  @override
  String get setupReqMinLength => 'לפחות 16 תווים';

  @override
  String get setupReqVariety => '3 מתוך 4: אותיות גדולות, קטנות, ספרות, סמלים';

  @override
  String get setupReqMatch => 'הסיסמאות תואמות';

  @override
  String get setupYourNickname => 'הכינוי שלך';

  @override
  String get setupRecoveryPassword => 'סיסמת שחזור (מינ׳ 16)';

  @override
  String get setupConfirmPassword => 'אשר סיסמה';

  @override
  String get setupMin16Chars => '16 תווים לפחות';

  @override
  String get setupPasswordsDoNotMatch => 'הסיסמאות אינן תואמות';

  @override
  String get setupEntropyWeak => 'חלש';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'חזק';

  @override
  String get setupEntropyWeakNeedsVariety => 'חלש (נדרשים 3 סוגי תווים)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits ביטים)';
  }

  @override
  String get setupPasswordWarning =>
      'סיסמה זו היא הדרך היחידה לשחזר את חשבונך. אין שרת — אין איפוס סיסמה. זכור אותה או רשום אותה.';

  @override
  String get setupCreateAccount => 'צור חשבון';

  @override
  String get setupAlreadyHaveAccount => 'כבר יש לך חשבון? ';

  @override
  String get setupRestore => 'שחזור →';

  @override
  String get restoreTitle => 'שחזור חשבון';

  @override
  String get restoreInfoBanner =>
      'הזן את סיסמת השחזור שלך — הכתובת שלך (Nostr + Session) תשוחזר אוטומטית. אנשי קשר והודעות אוחסנו מקומית בלבד.';

  @override
  String get restoreNewNickname => 'כינוי חדש (ניתן לשנות מאוחר יותר)';

  @override
  String get restoreButton => 'שחזר חשבון';

  @override
  String get lockTitle => 'Pulse נעול';

  @override
  String get lockSubtitle => 'הזן את הסיסמה כדי להמשיך';

  @override
  String get lockPasswordHint => 'סיסמה';

  @override
  String get lockUnlock => 'פתח נעילה';

  @override
  String get lockPanicHint =>
      'שכחת את הסיסמה? הזן את מפתח החירום כדי למחוק את כל הנתונים.';

  @override
  String get lockTooManyAttempts => 'יותר מדי ניסיונות. מוחק את כל הנתונים…';

  @override
  String get lockWrongPassword => 'סיסמה שגויה';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'סיסמה שגויה — $attempts/$max ניסיונות';
  }

  @override
  String get onboardingSkip => 'דלג';

  @override
  String get onboardingNext => 'הבא';

  @override
  String get onboardingGetStarted => 'צור חשבון';

  @override
  String get onboardingWelcomeTitle => 'ברוכים הבאים ל-Pulse';

  @override
  String get onboardingWelcomeBody =>
      'מסנג׳ר מבוזר ומוצפן מקצה לקצה.\n\nללא שרתים מרכזיים. ללא איסוף נתונים. ללא דלתות אחוריות.\nהשיחות שלך שייכות רק לך.';

  @override
  String get onboardingTransportTitle => 'אגנוסטי תחבורה';

  @override
  String get onboardingTransportBody =>
      'השתמש/י ב-Firebase, Nostr, או בשניהם בו-זמנית.\n\nהודעות מנותבות בין רשתות אוטומטית. תמיכה מובנית ב-Tor וב-I2P לעמידות בפני צנזורה.';

  @override
  String get onboardingSignalTitle => 'Signal + פוסט-קוונטום';

  @override
  String get onboardingSignalBody =>
      'כל הודעה מוצפנת עם פרוטוקול Signal (Double Ratchet + X3DH) עבור סודיות קדימה.\n\nבנוסף עטופה ב-Kyber-1024 — אלגוריתם פוסט-קוונטי בתקן NIST — להגנה מפני מחשבים קוונטיים עתידיים.';

  @override
  String get onboardingKeysTitle => 'המפתחות שלך בידיך';

  @override
  String get onboardingKeysBody =>
      'מפתחות הזהות שלך לעולם אינם עוזבים את המכשיר.\n\nטביעות אצבע של Signal מאפשרות אימות אנשי קשר מחוץ לערוץ. TOFU (אמון בשימוש ראשון) מזהה שינויי מפתח אוטומטית.';

  @override
  String get onboardingThemeTitle => 'בחר את הסגנון שלך';

  @override
  String get onboardingThemeBody =>
      'בחר ערכת נושא וצבע הדגשה. תוכל תמיד לשנות זאת מאוחר יותר בהגדרות.';

  @override
  String get contactsNewChat => 'צ׳אט חדש';

  @override
  String get contactsAddContact => 'הוסף איש קשר';

  @override
  String get contactsSearchHint => 'חיפוש...';

  @override
  String get contactsNewGroup => 'קבוצה חדשה';

  @override
  String get contactsNoContactsYet => 'אין עדיין אנשי קשר';

  @override
  String get contactsAddHint => 'הקש על + כדי להוסיף כתובת';

  @override
  String get contactsNoMatch => 'אין אנשי קשר תואמים';

  @override
  String get contactsRemoveTitle => 'הסר איש קשר';

  @override
  String contactsRemoveMessage(String name) {
    return 'להסיר את $name?';
  }

  @override
  String get contactsRemove => 'הסר';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count אנשי קשר',
      one: 'איש קשר אחד',
    );
    return '$_temp0';
  }

  @override
  String get bubbleOpenLink => 'פתח קישור';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'לפתוח כתובת URL זו בדפדפן?\n\n$url';
  }

  @override
  String get bubbleOpen => 'פתח';

  @override
  String get bubbleSecurityWarning => 'אזהרת אבטחה';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" הוא סוג קובץ הפעלה. שמירתו והרצתו עלולות להזיק למכשיר שלך. לשמור בכל זאת?';
  }

  @override
  String get bubbleSaveAnyway => 'שמור בכל זאת';

  @override
  String bubbleSavedTo(String path) {
    return 'נשמר ב-$path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'השמירה נכשלה: $error';
  }

  @override
  String get bubbleNotEncrypted => 'לא מוצפן';

  @override
  String get bubbleCorruptedImage => '[תמונה פגומה]';

  @override
  String get bubbleReplyPhoto => 'תמונה';

  @override
  String get bubbleReplyVoice => 'הודעה קולית';

  @override
  String get bubbleReplyVideo => 'הודעת וידאו';

  @override
  String bubbleReadBy(String names) {
    return 'נקרא על ידי $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'נקרא על ידי $count';
  }

  @override
  String get chatTileTapToStart => 'הקש כדי להתחיל לשוחח';

  @override
  String get chatTileMessageSent => 'ההודעה נשלחה';

  @override
  String get chatTileEncryptedMessage => 'הודעה מוצפנת';

  @override
  String chatTileYouPrefix(String text) {
    return 'את/ה: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 הודעה קולית';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 הודעה קולית ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'הודעה מוצפנת';

  @override
  String get groupNewGroup => 'קבוצה חדשה';

  @override
  String get groupGroupName => 'שם הקבוצה';

  @override
  String get groupSelectMembers => 'בחר חברים (מינ׳ 2)';

  @override
  String get groupNoContactsYet => 'אין עדיין אנשי קשר. הוסף אנשי קשר קודם.';

  @override
  String get groupCreate => 'צור';

  @override
  String get groupLabel => 'קבוצה';

  @override
  String get profileVerifyIdentity => 'אמת זהות';

  @override
  String profileVerifyInstructions(String name) {
    return 'השווה טביעות אצבע אלו עם $name בשיחה קולית או באופן אישי. אם שני הערכים תואמים בשני המכשירים, הקש על „סמן כמאומת“.';
  }

  @override
  String get profileTheirKey => 'המפתח שלהם';

  @override
  String get profileYourKey => 'המפתח שלך';

  @override
  String get profileRemoveVerification => 'הסר אימות';

  @override
  String get profileMarkAsVerified => 'סמן כמאומת';

  @override
  String get profileAddressCopied => 'הכתובת הועתקה';

  @override
  String get profileNoContactsToAdd => 'אין אנשי קשר להוספה — כולם כבר חברים';

  @override
  String get profileAddMembers => 'הוסף חברים';

  @override
  String profileAddCount(int count) {
    return 'הוסף ($count)';
  }

  @override
  String get profileRenameGroup => 'שנה שם קבוצה';

  @override
  String get profileRename => 'שנה שם';

  @override
  String get profileRemoveMember => 'להסיר חבר?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'להסיר את $name מקבוצה זו?';
  }

  @override
  String get profileKick => 'הסר';

  @override
  String get profileSignalFingerprints => 'טביעות אצבע של Signal';

  @override
  String get profileVerified => 'מאומת';

  @override
  String get profileVerify => 'אמת';

  @override
  String get profileEdit => 'ערוך';

  @override
  String get profileNoSession => 'עדיין לא הוקמה סשן — שלח הודעה קודם.';

  @override
  String get profileFingerprintCopied => 'טביעת האצבע הועתקה';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count חברים',
      one: 'חבר אחד',
    );
    return '$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'אמת מספר בטיחות';

  @override
  String get profileShowContactQr => 'הצג QR של איש קשר';

  @override
  String profileContactAddress(String name) {
    return 'הכתובת של $name';
  }

  @override
  String get profileExportChatHistory => 'ייצוא היסטוריית צ׳אט';

  @override
  String profileSavedTo(String path) {
    return 'נשמר ב-$path';
  }

  @override
  String get profileExportFailed => 'הייצוא נכשל';

  @override
  String get profileClearChatHistory => 'נקה היסטוריית צ׳אט';

  @override
  String get profileDeleteGroup => 'מחק קבוצה';

  @override
  String get profileDeleteContact => 'מחק איש קשר';

  @override
  String get profileLeaveGroup => 'עזוב קבוצה';

  @override
  String get profileLeaveGroupBody =>
      'תוסר מקבוצה זו והיא תימחק מאנשי הקשר שלך.';

  @override
  String get groupInviteTitle => 'הזמנה לקבוצה';

  @override
  String groupInviteBody(String from, String group) {
    return '$from הזמין אותך להצטרף ל\"$group\"';
  }

  @override
  String get groupInviteAccept => 'קבל';

  @override
  String get groupInviteDecline => 'דחה';

  @override
  String get groupMemberLimitTitle => 'יותר מדי משתתפים';

  @override
  String groupMemberLimitBody(int count) {
    return 'לקבוצה זו יהיו $count משתתפים. שיחות רשת מוצפנות תומכות בעד 6. קבוצות גדולות יותר עוברות ל-Jitsi (לא E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'הוסף בכל זאת';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name דחה את ההזמנה ל\"$group\"';
  }

  @override
  String get transferTitle => 'העברה למכשיר אחר';

  @override
  String get transferInfoBox =>
      'העבר את זהות ה-Signal ומפתחות Nostr שלך למכשיר חדש.\nסשנים של צ׳אט לא מועברים — סודיות קדימה נשמרת.';

  @override
  String get transferSendFromThis => 'שלח ממכשיר זה';

  @override
  String get transferSendSubtitle =>
      'למכשיר זה יש את המפתחות. שתף קוד עם המכשיר החדש.';

  @override
  String get transferReceiveOnThis => 'קבל במכשיר זה';

  @override
  String get transferReceiveSubtitle =>
      'זהו המכשיר החדש. הזן את הקוד מהמכשיר הישן.';

  @override
  String get transferChooseMethod => 'בחר שיטת העברה';

  @override
  String get transferLan => 'LAN (אותה רשת)';

  @override
  String get transferLanSubtitle =>
      'מהיר וישיר. שני המכשירים חייבים להיות באותה רשת Wi-Fi.';

  @override
  String get transferNostrRelay => 'ממסר Nostr';

  @override
  String get transferNostrRelaySubtitle =>
      'עובד על כל רשת באמצעות ממסר Nostr קיים.';

  @override
  String get transferRelayUrl => 'כתובת ממסר';

  @override
  String get transferEnterCode => 'הזן קוד העברה';

  @override
  String get transferPasteCode => 'הדבק את הקוד LAN:... או NOS:... כאן';

  @override
  String get transferConnect => 'התחבר';

  @override
  String get transferGenerating => 'מייצר קוד העברה…';

  @override
  String get transferShareCode => 'שתף קוד זה עם המקבל:';

  @override
  String get transferCopyCode => 'העתק קוד';

  @override
  String get transferCodeCopied => 'הקוד הועתק ללוח';

  @override
  String get transferWaitingReceiver => 'ממתין לחיבור המקבל…';

  @override
  String get transferConnectingSender => 'מתחבר לשולח…';

  @override
  String get transferVerifyBoth =>
      'השווה קוד זה בשני המכשירים.\nאם הם תואמים, ההעברה מאובטחת.';

  @override
  String get transferComplete => 'ההעברה הושלמה';

  @override
  String get transferKeysImported => 'המפתחות יובאו';

  @override
  String get transferCompleteSenderBody =>
      'המפתחות שלך נשארים פעילים במכשיר זה.\nהמקבל יכול כעת להשתמש בזהות שלך.';

  @override
  String get transferCompleteReceiverBody =>
      'המפתחות יובאו בהצלחה.\nהפעל מחדש את האפליקציה להחלת הזהות החדשה.';

  @override
  String get transferRestartApp => 'הפעל מחדש';

  @override
  String get transferFailed => 'ההעברה נכשלה';

  @override
  String get transferTryAgain => 'נסה שוב';

  @override
  String get transferEnterRelayFirst => 'הזן כתובת ממסר קודם';

  @override
  String get transferPasteCodeFromSender => 'הדבק את קוד ההעברה מהשולח';

  @override
  String get menuReply => 'תשובה';

  @override
  String get menuForward => 'העבר';

  @override
  String get menuReact => 'הגב';

  @override
  String get menuCopy => 'העתק';

  @override
  String get menuEdit => 'ערוך';

  @override
  String get menuRetry => 'נסה שוב';

  @override
  String get menuCancelScheduled => 'בטל מתוזמן';

  @override
  String get menuDelete => 'מחק';

  @override
  String get menuForwardTo => 'העבר אל…';

  @override
  String menuForwardedTo(String name) {
    return 'הועבר אל $name';
  }

  @override
  String get menuScheduledMessages => 'הודעות מתוזמנות';

  @override
  String get menuNoScheduledMessages => 'אין הודעות מתוזמנות';

  @override
  String menuSendsOn(String date) {
    return 'יישלח ב-$date';
  }

  @override
  String get menuDisappearingMessages => 'הודעות נעלמות';

  @override
  String get menuDisappearingSubtitle =>
      'ההודעות יימחקו אוטומטית לאחר הזמן שנבחר.';

  @override
  String get menuTtlOff => 'כבוי';

  @override
  String get menuTtl1h => 'שעה אחת';

  @override
  String get menuTtl24h => '24 שעות';

  @override
  String get menuTtl7d => '7 ימים';

  @override
  String get menuAttachPhoto => 'תמונה';

  @override
  String get menuAttachFile => 'קובץ';

  @override
  String get menuAttachVideo => 'וידאו';

  @override
  String get mediaTitle => 'מדיה';

  @override
  String get mediaFileLabel => 'קובץ';

  @override
  String mediaPhotosTab(int count) {
    return 'תמונות ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'קבצים ($count)';
  }

  @override
  String get mediaNoPhotos => 'אין עדיין תמונות';

  @override
  String get mediaNoFiles => 'אין עדיין קבצים';

  @override
  String mediaSavedToDownloads(String name) {
    return 'נשמר בהורדות/$name';
  }

  @override
  String get mediaFailedToSave => 'שמירת הקובץ נכשלה';

  @override
  String get statusNewStatus => 'סטטוס חדש';

  @override
  String get statusPublish => 'פרסם';

  @override
  String get statusExpiresIn24h => 'הסטטוס פג תוקף תוך 24 שעות';

  @override
  String get statusWhatsOnYourMind => 'מה עובר לך בראש?';

  @override
  String get statusPhotoAttached => 'תמונה צורפה';

  @override
  String get statusAttachPhoto => 'צרף תמונה (אופציונלי)';

  @override
  String get statusEnterText => 'אנא הזן טקסט לסטטוס שלך.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'בחירת תמונה נכשלה: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'הפרסום נכשל: $error';
  }

  @override
  String get panicSetPanicKey => 'הגדר מפתח חירום';

  @override
  String get panicEmergencySelfDestruct => 'השמדה עצמית חירום';

  @override
  String get panicIrreversible => 'פעולה זו בלתי הפיכה';

  @override
  String get panicWarningBody =>
      'הזנת מפתח זה במסך הנעילה תמחק מיידית את כל הנתונים — הודעות, אנשי קשר, מפתחות, זהות. השתמש במפתח שונה מהסיסמה הרגילה שלך.';

  @override
  String get panicKeyHint => 'מפתח חירום';

  @override
  String get panicConfirmHint => 'אשר מפתח חירום';

  @override
  String get panicMinChars => 'מפתח החירום חייב להכיל לפחות 8 תווים';

  @override
  String get panicKeysDoNotMatch => 'המפתחות אינם תואמים';

  @override
  String get panicSetFailed => 'שמירת מפתח החירום נכשלה — נסה שוב';

  @override
  String get passwordSetAppPassword => 'הגדר סיסמת אפליקציה';

  @override
  String get passwordProtectsMessages => 'מגן על ההודעות שלך במנוחה';

  @override
  String get passwordInfoBanner =>
      'נדרש בכל פתיחה של Pulse. אם תשכח, לא ניתן יהיה לשחזר את הנתונים שלך.';

  @override
  String get passwordHint => 'סיסמה';

  @override
  String get passwordConfirmHint => 'אשר סיסמה';

  @override
  String get passwordSetButton => 'הגדר סיסמה';

  @override
  String get passwordSkipForNow => 'דלג לעת עתה';

  @override
  String get passwordMinChars => 'הסיסמה חייבת להכיל לפחות 8 תווים';

  @override
  String get passwordNeedsVariety => 'חייב לכלול אותיות, מספרים ותווים מיוחדים';

  @override
  String get passwordRequirements => 'מינ. 8 תווים עם אותיות, מספרים ותו מיוחד';

  @override
  String get passwordsDoNotMatch => 'הסיסמאות אינן תואמות';

  @override
  String get profileCardSaved => 'הפרופיל נשמר!';

  @override
  String get profileCardE2eeIdentity => 'זהות E2EE';

  @override
  String get profileCardDisplayName => 'שם תצוגה';

  @override
  String get profileCardDisplayNameHint => 'למשל ישראל ישראלי';

  @override
  String get profileCardAbout => 'אודות';

  @override
  String get profileCardSaveProfile => 'שמור פרופיל';

  @override
  String get profileCardYourName => 'השם שלך';

  @override
  String get profileCardAddressCopied => 'הכתובת הועתקה!';

  @override
  String get profileCardInboxAddress => 'כתובת תיבת הדואר הנכנס שלך';

  @override
  String get profileCardInboxAddresses => 'כתובות תיבות הדואר הנכנס שלך';

  @override
  String get profileCardShareAllAddresses => 'שתף את כל הכתובות (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'שתף עם אנשי קשר כדי שיוכלו לשלוח לך הודעות.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'כל $count הכתובות הועתקו כקישור אחד!';
  }

  @override
  String get settingsMyProfile => 'הפרופיל שלי';

  @override
  String get settingsYourInboxAddress => 'כתובת תיבת הדואר הנכנס שלך';

  @override
  String get settingsMyQrCode => 'שיתוף איש קשר';

  @override
  String get settingsMyQrSubtitle => 'קוד QR וקישור הזמנה לכתובת שלך';

  @override
  String get settingsShareMyAddress => 'שתף את הכתובת שלי';

  @override
  String get settingsNoAddressYet => 'אין עדיין כתובת — שמור תחילה את ההגדרות';

  @override
  String get settingsInviteLink => 'קישור הזמנה';

  @override
  String get settingsRawAddress => 'כתובת גולמית';

  @override
  String get settingsCopyLink => 'העתק קישור';

  @override
  String get settingsCopyAddress => 'העתק כתובת';

  @override
  String get settingsInviteLinkCopied => 'קישור ההזמנה הועתק';

  @override
  String get settingsAppearance => 'מראה';

  @override
  String get settingsThemeEngine => 'מנוע ערכת נושא';

  @override
  String get settingsThemeEngineSubtitle => 'התאם צבעים וגופנים';

  @override
  String get settingsSignalProtocol => 'פרוטוקול Signal';

  @override
  String get settingsSignalProtocolSubtitle =>
      'מפתחות E2EE מאוחסנים בצורה מאובטחת';

  @override
  String get settingsActive => 'פעיל';

  @override
  String get settingsIdentityBackup => 'גיבוי זהות';

  @override
  String get settingsIdentityBackupSubtitle => 'ייצוא או ייבוא זהות Signal שלך';

  @override
  String get settingsIdentityBackupBody =>
      'ייצא את מפתחות זהות ה-Signal שלך לקוד גיבוי, או שחזר מקוד קיים.';

  @override
  String get settingsTransferDevice => 'העברה למכשיר אחר';

  @override
  String get settingsTransferDeviceSubtitle =>
      'העבר את הזהות שלך דרך LAN או ממסר Nostr';

  @override
  String get settingsExportIdentity => 'ייצוא זהות';

  @override
  String get settingsExportIdentityBody =>
      'העתק קוד גיבוי זה ושמור אותו במקום בטוח:';

  @override
  String get settingsSaveFile => 'שמור קובץ';

  @override
  String get settingsImportIdentity => 'ייבוא זהות';

  @override
  String get settingsImportIdentityBody =>
      'הדבק את קוד הגיבוי למטה. פעולה זו תדרוס את הזהות הנוכחית שלך.';

  @override
  String get settingsPasteBackupCode => 'הדבק קוד גיבוי כאן…';

  @override
  String get settingsIdentityImported =>
      'זהות + אנשי קשר יובאו! הפעל מחדש את האפליקציה להחלה.';

  @override
  String get settingsSecurity => 'אבטחה';

  @override
  String get settingsAppPassword => 'סיסמת אפליקציה';

  @override
  String get settingsPasswordEnabled => 'מופעל — נדרש בכל הפעלה';

  @override
  String get settingsPasswordDisabled => 'מושבת — האפליקציה נפתחת ללא סיסמה';

  @override
  String get settingsChangePassword => 'שנה סיסמה';

  @override
  String get settingsChangePasswordSubtitle => 'עדכן את סיסמת נעילת האפליקציה';

  @override
  String get settingsSetPanicKey => 'הגדר מפתח חירום';

  @override
  String get settingsChangePanicKey => 'שנה מפתח חירום';

  @override
  String get settingsPanicKeySetSubtitle => 'עדכן מפתח מחיקת חירום';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'מפתח אחד שמוחק מיידית את כל הנתונים';

  @override
  String get settingsRemovePanicKey => 'הסר מפתח חירום';

  @override
  String get settingsRemovePanicKeySubtitle => 'השבת השמדה עצמית חירום';

  @override
  String get settingsRemovePanicKeyBody =>
      'ההשמדה העצמית החירומית תושבת. תוכל להפעיל אותה מחדש בכל עת.';

  @override
  String get settingsDisableAppPassword => 'השבת סיסמת אפליקציה';

  @override
  String get settingsEnterCurrentPassword => 'הזן את הסיסמה הנוכחית שלך לאישור';

  @override
  String get settingsCurrentPassword => 'סיסמה נוכחית';

  @override
  String get settingsIncorrectPassword => 'סיסמה שגויה';

  @override
  String get settingsPasswordUpdated => 'הסיסמה עודכנה';

  @override
  String get settingsChangePasswordProceed =>
      'הזן את הסיסמה הנוכחית שלך כדי להמשיך';

  @override
  String get settingsData => 'נתונים';

  @override
  String get settingsBackupMessages => 'גבה הודעות';

  @override
  String get settingsBackupMessagesSubtitle =>
      'ייצא היסטוריית הודעות מוצפנת לקובץ';

  @override
  String get settingsRestoreMessages => 'שחזר הודעות';

  @override
  String get settingsRestoreMessagesSubtitle => 'ייבא הודעות מקובץ גיבוי';

  @override
  String get settingsExportKeys => 'ייצא מפתחות';

  @override
  String get settingsExportKeysSubtitle => 'שמור מפתחות זהות בקובץ מוצפן';

  @override
  String get settingsImportKeys => 'ייבא מפתחות';

  @override
  String get settingsImportKeysSubtitle => 'שחזר מפתחות זהות מקובץ מיוצא';

  @override
  String get settingsBackupPassword => 'סיסמת גיבוי';

  @override
  String get settingsPasswordCannotBeEmpty => 'הסיסמה לא יכולה להיות ריקה';

  @override
  String get settingsPasswordMin4Chars => 'הסיסמה חייבת להכיל לפחות 4 תווים';

  @override
  String get settingsCallsTurn => 'שיחות & TURN';

  @override
  String get settingsLocalNetwork => 'רשת מקומית';

  @override
  String get settingsCensorshipResistance => 'עמידות בפני צנזורה';

  @override
  String get settingsNetwork => 'רשת';

  @override
  String get settingsProxyTunnels => 'Proxy ומנהרות';

  @override
  String get settingsTurnServers => 'שרתי TURN';

  @override
  String get settingsProviderTitle => 'ספק';

  @override
  String get settingsLanFallback => 'חלופת LAN';

  @override
  String get settingsLanFallbackSubtitle =>
      'שדר נוכחות ומסור הודעות ברשת המקומית כאשר אין אינטרנט. השבת ברשתות לא מהימנות (Wi-Fi ציבורי).';

  @override
  String get settingsBgDelivery => 'מסירה ברקע';

  @override
  String get settingsBgDeliverySubtitle =>
      'המשך לקבל הודעות כאשר האפליקציה ממוזערת. מציג התראה קבועה.';

  @override
  String get settingsYourInboxProvider => 'ספק תיבת הדואר הנכנס שלך';

  @override
  String get settingsConnectionDetails => 'פרטי חיבור';

  @override
  String get settingsSaveAndConnect => 'שמור והתחבר';

  @override
  String get settingsSecondaryInboxes => 'תיבות דואר משניות';

  @override
  String get settingsAddSecondaryInbox => 'הוסף תיבת דואר משנית';

  @override
  String get settingsAdvanced => 'מתקדם';

  @override
  String get settingsDiscover => 'גלה';

  @override
  String get settingsAbout => 'אודות';

  @override
  String get settingsPrivacyPolicy => 'מדיניות פרטיות';

  @override
  String get settingsPrivacyPolicySubtitle => 'כיצד Pulse מגן על הנתונים שלך';

  @override
  String get settingsCrashReporting => 'דיווח קריסות';

  @override
  String get settingsCrashReportingSubtitle =>
      'שלח דוחות קריסה אנונימיים כדי לעזור לשפר את Pulse. תוכן הודעות או אנשי קשר לעולם אינם נשלחים.';

  @override
  String get settingsCrashReportingEnabled =>
      'דיווח קריסות הופעל — הפעל מחדש את האפליקציה להחלה';

  @override
  String get settingsCrashReportingDisabled =>
      'דיווח קריסות הושבת — הפעל מחדש את האפליקציה להחלה';

  @override
  String get settingsSensitiveOperation => 'פעולה רגישה';

  @override
  String get settingsSensitiveOperationBody =>
      'מפתחות אלו הם הזהות שלך. כל מי שיש לו קובץ זה יכול להתחזות לך. שמור אותו במקום בטוח ומחק אותו לאחר ההעברה.';

  @override
  String get settingsIUnderstandContinue => 'אני מבין, המשך';

  @override
  String get settingsReplaceIdentity => 'להחליף זהות?';

  @override
  String get settingsReplaceIdentityBody =>
      'פעולה זו תדרוס את מפתחות הזהות הנוכחיים שלך. סשני ה-Signal הקיימים שלך יבוטלו ואנשי קשר יצטרכו להקים מחדש הצפנה. האפליקציה תצטרך להפעיל מחדש.';

  @override
  String get settingsReplaceKeys => 'החלף מפתחות';

  @override
  String get settingsKeysImported => 'המפתחות יובאו';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count מפתחות יובאו בהצלחה. אנא הפעל מחדש את האפליקציה לאתחול עם הזהות החדשה.';
  }

  @override
  String get settingsRestartNow => 'הפעל מחדש כעת';

  @override
  String get settingsLater => 'מאוחר יותר';

  @override
  String get profileGroupLabel => 'קבוצה';

  @override
  String get profileAddButton => 'הוסף';

  @override
  String get profileKickButton => 'הסר';

  @override
  String get dataSectionTitle => 'נתונים';

  @override
  String get dataBackupMessages => 'גבה הודעות';

  @override
  String get dataBackupPasswordSubtitle =>
      'בחר סיסמה כדי להצפין את הגיבוי שלך.';

  @override
  String get dataBackupConfirmLabel => 'צור גיבוי';

  @override
  String get dataCreatingBackup => 'יוצר גיבוי';

  @override
  String get dataBackupPreparing => 'מכין...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'מייצא הודעה $done מתוך $total...';
  }

  @override
  String get dataBackupSavingFile => 'שומר קובץ...';

  @override
  String get dataSaveMessageBackupDialog => 'שמור גיבוי הודעות';

  @override
  String dataBackupSaved(int count, String path) {
    return 'הגיבוי נשמר ($count הודעות)\n$path';
  }

  @override
  String get dataBackupFailed => 'הגיבוי נכשל — לא יוצאו נתונים';

  @override
  String dataBackupFailedError(String error) {
    return 'הגיבוי נכשל: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'בחר גיבוי הודעות';

  @override
  String get dataInvalidBackupFile => 'קובץ גיבוי לא תקין (קטן מדי)';

  @override
  String get dataNotValidBackupFile => 'לא קובץ גיבוי תקף של Pulse';

  @override
  String get dataRestoreMessages => 'שחזר הודעות';

  @override
  String get dataRestorePasswordSubtitle =>
      'הזן את הסיסמה ששימשה ליצירת גיבוי זה.';

  @override
  String get dataRestoreConfirmLabel => 'שחזר';

  @override
  String get dataRestoringMessages => 'משחזר הודעות';

  @override
  String get dataRestoreDecrypting => 'מפענח...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'מייבא הודעה $done מתוך $total...';
  }

  @override
  String get dataRestoreFailed => 'השחזור נכשל — סיסמה שגויה או קובץ פגום';

  @override
  String dataRestoreSuccess(int count) {
    return 'שוחזרו $count הודעות חדשות';
  }

  @override
  String get dataRestoreNothingNew =>
      'אין הודעות חדשות לייבוא (כולן כבר קיימות)';

  @override
  String dataRestoreFailedError(String error) {
    return 'השחזור נכשל: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'בחר ייצוא מפתחות';

  @override
  String get dataNotValidKeyFile => 'לא קובץ ייצוא מפתחות תקף של Pulse';

  @override
  String get dataExportKeys => 'ייצא מפתחות';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'בחר סיסמה כדי להצפין את ייצוא המפתחות שלך.';

  @override
  String get dataExportKeysConfirmLabel => 'ייצא';

  @override
  String get dataExportingKeys => 'מייצא מפתחות';

  @override
  String get dataExportingKeysStatus => 'מצפין מפתחות זהות...';

  @override
  String get dataSaveKeyExportDialog => 'שמור ייצוא מפתחות';

  @override
  String dataKeysExportedTo(String path) {
    return 'המפתחות יוצאו אל:\n$path';
  }

  @override
  String get dataExportFailed => 'הייצוא נכשל — לא נמצאו מפתחות';

  @override
  String dataExportFailedError(String error) {
    return 'הייצוא נכשל: $error';
  }

  @override
  String get dataImportKeys => 'ייבא מפתחות';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'הזן את הסיסמה ששימשה להצפנת ייצוא מפתחות זה.';

  @override
  String get dataImportKeysConfirmLabel => 'ייבא';

  @override
  String get dataImportingKeys => 'מייבא מפתחות';

  @override
  String get dataImportingKeysStatus => 'מפענח מפתחות זהות...';

  @override
  String get dataImportFailed => 'הייבוא נכשל — סיסמה שגויה או קובץ פגום';

  @override
  String dataImportFailedError(String error) {
    return 'הייבוא נכשל: $error';
  }

  @override
  String get securitySectionTitle => 'אבטחה';

  @override
  String get securityIncorrectPassword => 'סיסמה שגויה';

  @override
  String get securityPasswordUpdated => 'הסיסמה עודכנה';

  @override
  String get appearanceSectionTitle => 'מראה';

  @override
  String appearanceExportFailed(String error) {
    return 'הייצוא נכשל: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'נשמר ב-$path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'השמירה נכשלה: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'הייבוא נכשל: $error';
  }

  @override
  String get aboutSectionTitle => 'אודות';

  @override
  String get providerPublicKey => 'מפתח ציבורי';

  @override
  String get providerRelay => 'ממסר';

  @override
  String get providerAutoConfigured =>
      'הוגדר אוטומטית מסיסמת השחזור שלך. הממסר התגלה אוטומטית.';

  @override
  String get providerKeyStoredLocally =>
      'המפתח שלך מאוחסן מקומית באחסון מאובטח — לא נשלח לשום שרת.';

  @override
  String get providerSessionInfo =>
      'Session Network — E2EE עם ניתוב שכבות. מזהה ה-Session שלך נוצר אוטומטית ומאוחסן בצורה מאובטחת. הצמתים מתגלים אוטומטית מצמתי הגרעין המובנים.';

  @override
  String get providerAdvanced => 'מתקדם';

  @override
  String get providerSaveAndConnect => 'שמור והתחבר';

  @override
  String get providerAddSecondaryInbox => 'הוסף תיבת דואר משנית';

  @override
  String get providerSecondaryInboxes => 'תיבות דואר משניות';

  @override
  String get providerYourInboxProvider => 'ספק תיבת הדואר הנכנס שלך';

  @override
  String get providerConnectionDetails => 'פרטי חיבור';

  @override
  String get addContactTitle => 'הוסף איש קשר';

  @override
  String get addContactInviteLinkLabel => 'קישור הזמנה או כתובת';

  @override
  String get addContactTapToPaste => 'הקש להדבקת קישור הזמנה';

  @override
  String get addContactPasteTooltip => 'הדבק מהלוח';

  @override
  String get addContactAddressDetected => 'כתובת איש קשר זוהתה';

  @override
  String addContactRoutesDetected(int count) {
    return '$count נתיבים זוהו — SmartRouter בוחר את המהיר ביותר';
  }

  @override
  String get addContactFetchingProfile => 'מביא פרופיל…';

  @override
  String addContactProfileFound(String name) {
    return 'נמצא: $name';
  }

  @override
  String get addContactNoProfileFound => 'לא נמצא פרופיל';

  @override
  String get addContactDisplayNameLabel => 'שם תצוגה';

  @override
  String get addContactDisplayNameHint => 'איך לקרוא להם?';

  @override
  String get addContactAddManually => 'הוסף כתובת ידנית';

  @override
  String get addContactButton => 'הוסף איש קשר';

  @override
  String get networkDiagnosticsTitle => 'אבחון רשת';

  @override
  String get networkDiagnosticsNostrRelays => 'ממסרי Nostr';

  @override
  String get networkDiagnosticsDirect => 'ישיר';

  @override
  String get networkDiagnosticsTorOnly => 'Tor בלבד';

  @override
  String get networkDiagnosticsBest => 'הטוב ביותר';

  @override
  String get networkDiagnosticsNone => 'אין';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'מצב';

  @override
  String get networkDiagnosticsConnected => 'מחובר';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'מתחבר $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'כבוי';

  @override
  String get networkDiagnosticsTransport => 'תחבורה';

  @override
  String get networkDiagnosticsInfrastructure => 'תשתית';

  @override
  String get networkDiagnosticsSessionNodes => 'צמתי Session';

  @override
  String get networkDiagnosticsTurnServers => 'שרתי TURN';

  @override
  String get networkDiagnosticsLastProbe => 'בדיקה אחרונה';

  @override
  String get networkDiagnosticsRunning => 'פועל...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'הפעל אבחון';

  @override
  String get networkDiagnosticsForceReprobe => 'כפה בדיקה מחדש מלאה';

  @override
  String get networkDiagnosticsJustNow => 'ממש עכשיו';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'לפני $minutes דק׳';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'לפני $hours שע׳';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'לפני $days ימים';
  }

  @override
  String get homeNoEch => 'אין ECH';

  @override
  String get homeNoEchTooltip =>
      'פרוקסי uTLS לא זמין — ECH מושבת.\nטביעת אצבע TLS גלויה ל-DPI.';

  @override
  String get settingsTitle => 'הגדרות';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'נשמר ומחובר אל $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Tor המובנה נכשל בהפעלה';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon נכשל בהפעלה';

  @override
  String get verifyTitle => 'אמת מספר בטיחות';

  @override
  String get verifyIdentityVerified => 'הזהות אומתה';

  @override
  String get verifyNotYetVerified => 'עדיין לא אומת';

  @override
  String verifyVerifiedDescription(String name) {
    return 'אימתת את מספר הבטיחות של $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'השווה מספרים אלו עם $name באופן אישי או דרך ערוץ מהימן.';
  }

  @override
  String get verifyExplanation =>
      'לכל שיחה יש מספר בטיחות ייחודי. אם שניכם רואים את אותם מספרים במכשירים שלכם, החיבור שלכם מאומת מקצה לקצה.';

  @override
  String verifyContactKey(String name) {
    return 'המפתח של $name';
  }

  @override
  String get verifyYourKey => 'המפתח שלך';

  @override
  String get verifyRemoveVerification => 'הסר אימות';

  @override
  String get verifyMarkAsVerified => 'סמן כמאומת';

  @override
  String verifyAfterReinstall(String name) {
    return 'אם $name יתקין מחדש את האפליקציה, מספר הבטיחות ישתנה והאימות יוסר אוטומטית.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'סמן כמאומת רק לאחר השוואת המספרים עם $name בשיחה קולית או באופן אישי.';
  }

  @override
  String get verifyNoSession =>
      'עדיין לא הוקם סשן הצפנה. שלח הודעה קודם כדי ליצור מספרי בטיחות.';

  @override
  String get verifyNoKeyAvailable => 'אין מפתח זמין';

  @override
  String verifyFingerprintCopied(String label) {
    return 'טביעת אצבע $label הועתקה';
  }

  @override
  String get providerDatabaseUrlLabel => 'כתובת מסד נתונים';

  @override
  String get providerOptionalHint => 'אופציונלי';

  @override
  String get providerWebApiKeyLabel => 'מפתח Web API';

  @override
  String get providerOptionalForPublicDb => 'אופציונלי עבור מסד נתונים ציבורי';

  @override
  String get providerRelayUrlLabel => 'כתובת ממסר';

  @override
  String get providerPrivateKeyLabel => 'מפתח פרטי';

  @override
  String get providerPrivateKeyNsecLabel => 'מפתח פרטי (nsec)';

  @override
  String get providerStorageNodeLabel => 'כתובת צומת אחסון (אופציונלי)';

  @override
  String get providerStorageNodeHint => 'השאר ריק עבור צמתי זרע מובנים';

  @override
  String get transferInvalidCodeFormat =>
      'פורמט קוד לא מזוהה — חייב להתחיל ב-LAN: או NOS:';

  @override
  String get profileCardFingerprintCopied => 'טביעת האצבע הועתקה';

  @override
  String get profileCardAboutHint => 'פרטיות קודמת 🔒';

  @override
  String get profileCardSaveButton => 'שמור פרופיל';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'ייצא הודעות מוצפנות, אנשי קשר ואווטרים לקובץ';

  @override
  String get callVideo => 'וידאו';

  @override
  String get callAudio => 'שמע';

  @override
  String bubbleDeliveredTo(String names) {
    return 'נמסר אל $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'נמסר אל $count';
  }

  @override
  String get groupStatusDialogTitle => 'מידע על ההודעה';

  @override
  String get groupStatusRead => 'נקרא';

  @override
  String get groupStatusDelivered => 'נמסר';

  @override
  String get groupStatusPending => 'ממתין';

  @override
  String get groupStatusNoData => 'אין עדיין מידע מסירה';

  @override
  String get profileTransferAdmin => 'הפוך למנהל';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'להפוך את $name למנהל החדש?';
  }

  @override
  String get profileTransferAdminBody =>
      'תאבד את הרשאות המנהל. לא ניתן לבטל פעולה זו.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name הוא כעת המנהל';
  }

  @override
  String get profileAdminBadge => 'מנהל';

  @override
  String get privacyPolicyTitle => 'מדיניות פרטיות';

  @override
  String get privacyOverviewHeading => 'סקירה כללית';

  @override
  String get privacyOverviewBody =>
      'Pulse הוא מסנג׳ר ללא שרת ומוצפן מקצה לקצה. הפרטיות שלך אינה רק תכונה — היא הארכיטקטורה. אין שרתי Pulse. אין חשבונות המאוחסנים באף מקום. אין נתונים הנאספים, מועברים או מאוחסנים על ידי המפתחים.';

  @override
  String get privacyDataCollectionHeading => 'איסוף נתונים';

  @override
  String get privacyDataCollectionBody =>
      'Pulse אינו אוסף נתונים אישיים כלל. בפרט:\n\n- לא נדרשים דוא״ל, מספר טלפון או שם אמיתי\n- אין אנליטיקה, מעקב או טלמטריה\n- אין מזהי פרסום\n- אין גישה לרשימת אנשי הקשר\n- אין גיבויי ענן (הודעות קיימות רק במכשיר שלך)\n- אין מטא-נתונים הנשלחים לשרת Pulse כלשהו (אין כאלה)';

  @override
  String get privacyEncryptionHeading => 'הצפנה';

  @override
  String get privacyEncryptionBody =>
      'כל ההודעות מוצפנות באמצעות פרוטוקול Signal (Double Ratchet עם הסכמת מפתחות X3DH). מפתחות ההצפנה נוצרים ומאוחסנים אך ורק במכשיר שלך. אף אחד — כולל המפתחים — לא יכול לקרוא את ההודעות שלך.';

  @override
  String get privacyNetworkHeading => 'ארכיטקטורת רשת';

  @override
  String get privacyNetworkBody =>
      'Pulse משתמש במתאמי תחבורה מאוחדים (ממסרי Nostr, צמתי שירות Session/Oxen, Firebase Realtime Database, LAN). תחבורות אלו נושאות רק טקסט מוצפן. מפעילי ממסרים יכולים לראות את כתובת ה-IP שלך ונפח התנועה, אך לא יכולים לפענח תוכן הודעות.\n\nכאשר Tor מופעל, כתובת ה-IP שלך מוסתרת גם ממפעילי הממסרים.';

  @override
  String get privacyStunHeading => 'שרתי STUN/TURN';

  @override
  String get privacyStunBody =>
      'שיחות קול ווידאו משתמשות ב-WebRTC עם הצפנת DTLS-SRTP. שרתי STUN (לגילוי ה-IP הציבורי שלך לחיבורי עמית-לעמית) ושרתי TURN (להעברת מדיה כאשר חיבור ישיר נכשל) יכולים לראות את כתובת ה-IP שלך ומשך השיחה, אך לא יכולים לפענח תוכן השיחה.\n\nתוכל להגדיר שרת TURN משלך בהגדרות לפרטיות מרבית.';

  @override
  String get privacyCrashHeading => 'דיווח קריסות';

  @override
  String get privacyCrashBody =>
      'אם דיווח קריסות Sentry מופעל (באמצעות SENTRY_DSN בזמן הבנייה), עשויים להישלח דוחות קריסה אנונימיים. אלו אינם מכילים תוכן הודעות, מידע על אנשי קשר או מידע מזהה אישי. ניתן להשבית דיווח קריסות בזמן הבנייה על ידי השמטת ה-DSN.';

  @override
  String get privacyPasswordHeading => 'סיסמה ומפתחות';

  @override
  String get privacyPasswordBody =>
      'סיסמת השחזור שלך משמשת לגזירת מפתחות קריפטוגרפיים באמצעות Argon2id (KDF קשיח-זיכרון). הסיסמה לעולם אינה מועברת לשום מקום. אם תאבד את הסיסמה, לא ניתן יהיה לשחזר את החשבון — אין שרת שיאפס אותה.';

  @override
  String get privacyFontsHeading => 'גופנים';

  @override
  String get privacyFontsBody =>
      'Pulse כולל את כל הגופנים מקומית. לא נשלחות בקשות ל-Google Fonts או לשירות גופנים חיצוני כלשהו.';

  @override
  String get privacyThirdPartyHeading => 'שירותי צד שלישי';

  @override
  String get privacyThirdPartyBody =>
      'Pulse אינו משתלב עם רשתות פרסום, ספקי אנליטיקה, פלטפורמות מדיה חברתית או סוחרי נתונים. החיבורים היחידים לרשת הם אל ממסרי התחבורה שאתה מגדיר.';

  @override
  String get privacyOpenSourceHeading => 'קוד פתוח';

  @override
  String get privacyOpenSourceBody =>
      'Pulse הוא תוכנת קוד פתוח. תוכל לבדוק את קוד המקור המלא כדי לאמת טענות פרטיות אלו.';

  @override
  String get privacyContactHeading => 'יצירת קשר';

  @override
  String get privacyContactBody =>
      'לשאלות הקשורות לפרטיות, פתח issue במאגר הפרויקט.';

  @override
  String get privacyLastUpdated => 'עודכן לאחרונה: מרץ 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'השמירה נכשלה: $error';
  }

  @override
  String get themeEngineTitle => 'מנוע ערכת נושא';

  @override
  String get torBuiltInTitle => 'Tor מובנה';

  @override
  String get torConnectedSubtitle => 'מחובר — Nostr מנותב דרך 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'מתחבר… $pct%';
  }

  @override
  String get torNotRunning => 'לא פועל — הקש על המתג להפעלה מחדש';

  @override
  String get torDescription => 'מנתב Nostr דרך Tor (Snowflake לרשתות מצונזרות)';

  @override
  String get torNetworkDiagnostics => 'אבחון רשת';

  @override
  String get torTransportLabel => 'תחבורה: ';

  @override
  String get torPtAuto => 'אוטומטי';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'רגיל';

  @override
  String get torTimeoutLabel => 'זמן קצוב: ';

  @override
  String get torInfoDescription =>
      'כאשר מופעל, חיבורי WebSocket של Nostr מנותבים דרך Tor (SOCKS5). דפדפן Tor מאזין ב-127.0.0.1:9150. שירות Tor העצמאי משתמש בפורט 9050. חיבורי Firebase אינם מושפעים.';

  @override
  String get torRouteNostrTitle => 'נתב Nostr דרך Tor';

  @override
  String get torManagedByBuiltin => 'מנוהל על ידי Tor מובנה';

  @override
  String get torActiveRouting => 'פעיל — תנועת Nostr מנותבת דרך Tor';

  @override
  String get torDisabled => 'מושבת';

  @override
  String get torProxySocks5 => 'פרוקסי Tor (SOCKS5)';

  @override
  String get torProxyHostLabel => 'מארח פרוקסי';

  @override
  String get torProxyPortLabel => 'פורט';

  @override
  String get torPortInfo => 'דפדפן Tor: פורט 9150  •  שירות Tor: פורט 9050';

  @override
  String get torForceNostrTitle => 'נתב הודעות דרך Tor';

  @override
  String get torForceNostrSubtitle =>
      'כל חיבורי Nostr relay יעברו דרך Tor. איטי יותר אך מסתיר את כתובת ה-IP שלך מה-relay.';

  @override
  String get torForceNostrDisabled => 'יש להפעיל את Tor קודם';

  @override
  String get torForcePulseTitle => 'נתב Pulse relay דרך Tor';

  @override
  String get torForcePulseSubtitle =>
      'כל חיבורי Pulse relay יעברו דרך Tor. איטי יותר אך מסתיר את כתובת ה-IP שלך מהשרת.';

  @override
  String get torForcePulseDisabled => 'יש להפעיל את Tor קודם';

  @override
  String get i2pProxySocks5 => 'פרוקסי I2P (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P משתמש ב-SOCKS5 על פורט 4447 כברירת מחדל. התחבר לממסר Nostr דרך I2P outproxy (למשל relay.damus.i2p) כדי לתקשר עם משתמשים בכל תחבורה. Tor מקבל עדיפות כששניהם מופעלים.';

  @override
  String get i2pRouteNostrTitle => 'נתב Nostr דרך I2P';

  @override
  String get i2pActiveRouting => 'פעיל — תנועת Nostr מנותבת דרך I2P';

  @override
  String get i2pDisabled => 'מושבת';

  @override
  String get i2pProxyHostLabel => 'מארח פרוקסי';

  @override
  String get i2pProxyPortLabel => 'פורט';

  @override
  String get i2pPortInfo => 'פורט SOCKS5 ברירת מחדל של נתב I2P: 4447';

  @override
  String get customProxySocks5 => 'פרוקסי מותאם אישית (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'ממסר CF Worker';

  @override
  String get customProxyInfoDescription =>
      'הפרוקסי המותאם אישית מנתב תנועה דרך V2Ray/Xray/Shadowsocks שלך. CF Worker פועל כפרוקסי ממסר אישי ב-CDN של Cloudflare — ה-GFW רואה *.workers.dev, לא את הממסר האמיתי.';

  @override
  String get customSocks5ProxyTitle => 'פרוקסי SOCKS5 מותאם אישית';

  @override
  String get customProxyActive => 'פעיל — תנועה מנותבת דרך SOCKS5';

  @override
  String get customProxyDisabled => 'מושבת';

  @override
  String get customProxyHostLabel => 'מארח פרוקסי';

  @override
  String get customProxyPortLabel => 'פורט';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'דומיין Worker (אופציונלי)';

  @override
  String get customWorkerHelpTitle => 'כיצד לפרוס ממסר CF Worker (חינם)';

  @override
  String get customWorkerScriptCopied => 'הסקריפט הועתק!';

  @override
  String get customWorkerStep1 =>
      '1. עבור אל dash.cloudflare.com → Workers & Pages\n2. Create Worker → הדבק סקריפט זה:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → העתק דומיין (למשל my-relay.user.workers.dev)\n4. הדבק דומיין למעלה → שמור\n\nהאפליקציה מתחברת אוטומטית: wss://domain/?r=relay_url\nה-GFW רואה: חיבור אל *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'מחובר — SOCKS5 על 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'מתחבר…';

  @override
  String get psiphonNotRunning => 'לא פועל — הקש על המתג להפעלה מחדש';

  @override
  String get psiphonDescription =>
      'מנהרה מהירה (~3 שניות אתחול, 2000+ שרתי VPS מתחלפים)';

  @override
  String get turnCommunityServers => 'שרתי TURN קהילתיים';

  @override
  String get turnCustomServer => 'שרת TURN מותאם אישית (BYOD)';

  @override
  String get turnInfoDescription =>
      'שרתי TURN מעבירים רק זרמים מוצפנים מראש (DTLS-SRTP). מפעיל ממסר רואה את ה-IP שלך ונפח התנועה, אך לא יכול לפענח שיחות. TURN משמש רק כאשר P2P ישיר נכשל (~15–20% מהחיבורים).';

  @override
  String get turnFreeLabel => 'חינם';

  @override
  String get turnServerUrlLabel => 'כתובת שרת TURN';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 או turns:...';

  @override
  String get turnUsernameLabel => 'שם משתמש';

  @override
  String get turnPasswordLabel => 'סיסמה';

  @override
  String get turnOptionalHint => 'אופציונלי';

  @override
  String get turnCustomInfo =>
      'הרץ coturn על כל VPS ב-\$5/חודש לשליטה מרבית. פרטי ההתחברות מאוחסנים מקומית.';

  @override
  String get themePickerAppearance => 'מראה';

  @override
  String get themePickerAccentColor => 'צבע הדגשה';

  @override
  String get themeModeLight => 'בהיר';

  @override
  String get themeModeDark => 'כהה';

  @override
  String get themeModeSystem => 'מערכת';

  @override
  String get themeDynamicPresets => 'הגדרות מוכנות';

  @override
  String get themeDynamicPrimaryColor => 'צבע ראשי';

  @override
  String get themeDynamicBorderRadius => 'רדיוס גבול';

  @override
  String get themeDynamicFont => 'גופן';

  @override
  String get themeDynamicAppearance => 'מראה';

  @override
  String get themeDynamicUiStyle => 'סגנון ממשק';

  @override
  String get themeDynamicUiStyleDescription =>
      'שולט במראה של דיאלוגים, מתגים ומחוונים.';

  @override
  String get themeDynamicSharp => 'חד';

  @override
  String get themeDynamicRound => 'עגול';

  @override
  String get themeDynamicModeDark => 'כהה';

  @override
  String get themeDynamicModeLight => 'בהיר';

  @override
  String get themeDynamicModeAuto => 'אוטומטי';

  @override
  String get themeDynamicPlatformAuto => 'אוטומטי';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'כתובת Firebase לא תקינה. צפוי: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'כתובת ממסר לא תקינה. צפוי: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'כתובת שרת Pulse לא תקינה. צפוי: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'כתובת שרת';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'קוד הזמנה';

  @override
  String get providerPulseInviteHint => 'קוד הזמנה (אם נדרש)';

  @override
  String get providerPulseInfo =>
      'ממסר עצמאי. מפתחות נגזרים מסיסמת השחזור שלך.';

  @override
  String get providerScreenTitle => 'תיבות דואר';

  @override
  String get providerSecondaryInboxesHeader => 'תיבות דואר משניות';

  @override
  String get providerSecondaryInboxesInfo =>
      'תיבות דואר משניות מקבלות הודעות בו-זמנית ליתירות.';

  @override
  String get providerRemoveTooltip => 'הסר';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... או hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... או מפתח פרטי hex';

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
  String get emojiNoRecent => 'אין אמוג׳י אחרונים';

  @override
  String get emojiSearchHint => 'חיפוש אמוג׳י...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'הקש לצ׳אט';

  @override
  String get imageViewerSaveToDownloads => 'שמור בהורדות';

  @override
  String imageViewerSavedTo(String path) {
    return 'נשמר ב-$path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'שפה';

  @override
  String get settingsLanguageSubtitle => 'שפת תצוגת האפליקציה';

  @override
  String get settingsLanguageSystem => 'ברירת מחדל של המערכת';

  @override
  String get onboardingLanguageTitle => 'בחר את השפה שלך';

  @override
  String get onboardingLanguageSubtitle => 'ניתן לשנות זאת מאוחר יותר בהגדרות';

  @override
  String get videoNoteRecord => 'הקלט הודעת וידאו';

  @override
  String get videoNoteTapToRecord => 'הקש להקלטה';

  @override
  String get videoNoteTapToStop => 'הקש לעצירה';

  @override
  String get videoNoteCameraPermission => 'הרשאת המצלמה נדחתה';

  @override
  String get videoNoteMaxDuration => 'מקסימום 30 שניות';

  @override
  String get videoNoteNotSupported => 'הערות וידאו אינן נתמכות בפלטפורמה זו';

  @override
  String get navChats => 'צ\'אטים';

  @override
  String get navUpdates => 'עדכונים';

  @override
  String get navCalls => 'שיחות';

  @override
  String get filterAll => 'הכל';

  @override
  String get filterUnread => 'לא נקרא';

  @override
  String get filterGroups => 'קבוצות';

  @override
  String get callsNoRecent => 'אין שיחות אחרונות';

  @override
  String get callsEmptySubtitle => 'היסטוריית השיחות שלך תופיע כאן';

  @override
  String get appBarEncrypted => 'מוצפן מקצה לקצה';

  @override
  String get newStatus => 'סטטוס חדש';

  @override
  String get newCall => 'שיחה חדשה';

  @override
  String get joinChannelTitle => 'הצטרף לערוץ';

  @override
  String get joinChannelDescription => 'כתובת הערוץ';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'מביא מידע על הערוץ…';

  @override
  String get joinChannelNotFound => 'לא נמצא ערוץ בכתובת זו';

  @override
  String get joinChannelNetworkError => 'לא ניתן להגיע לשרת';

  @override
  String get joinChannelAlreadyJoined => 'כבר הצטרפת';

  @override
  String get joinChannelButton => 'הצטרף';

  @override
  String get channelFeedEmpty => 'אין פרסומים עדיין';

  @override
  String get channelLeave => 'עזוב ערוץ';

  @override
  String get channelLeaveConfirm => 'לעזוב ערוץ זה? פרסומים שמורים יימחקו.';

  @override
  String get channelInfo => 'מידע על הערוץ';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'נערך';

  @override
  String get channelLoadMore => 'טען עוד';

  @override
  String get channelSearchPosts => 'חיפוש פוסטים…';

  @override
  String get channelNoResults => 'אין פוסטים תואמים';

  @override
  String get channelUrl => 'URL הערוץ';

  @override
  String get channelCreated => 'הצטרף';

  @override
  String channelPostCount(int count) {
    return '$count פוסטים';
  }

  @override
  String get channelCopyUrl => 'העתק URL';

  @override
  String get setupNext => 'הבא';

  @override
  String get setupKeyWarning =>
      'מפתח שחזור ייוצר עבורך. זו הדרך היחידה לשחזר את החשבון שלך במכשיר חדש — אין שרת, אין איפוס סיסמה.';

  @override
  String get setupKeyTitle => 'מפתח השחזור שלך';

  @override
  String get setupKeySubtitle =>
      'רשום את המפתח הזה ושמור אותו במקום בטוח. תצטרך אותו כדי לשחזר את החשבון שלך במכשיר חדש.';

  @override
  String get setupKeyCopied => 'הועתק!';

  @override
  String get setupKeyWroteItDown => 'רשמתי את זה';

  @override
  String get setupKeyWarnBody =>
      'רשום את המפתח הזה כגיבוי. תוכל גם לצפות בו מאוחר יותר בהגדרות → אבטחה.';

  @override
  String get setupVerifyTitle => 'אמת את מפתח השחזור';

  @override
  String get setupVerifySubtitle =>
      'הזן מחדש את מפתח השחזור שלך כדי לאשר ששמרת אותו נכון.';

  @override
  String get setupVerifyButton => 'אמת';

  @override
  String get setupKeyMismatch => 'המפתח לא תואם. בדוק ונסה שוב.';

  @override
  String get setupSkipVerify => 'דלג על אימות';

  @override
  String get setupSkipVerifyTitle => 'לדלג על אימות?';

  @override
  String get setupSkipVerifyBody =>
      'אם תאבד את מפתח השחזור שלך, לא ניתן יהיה לשחזר את החשבון. בטוח שברצונך לדלג?';

  @override
  String get setupCreatingAccount => 'יוצר חשבון…';

  @override
  String get setupRestoringAccount => 'משחזר חשבון…';

  @override
  String get restoreKeyInfoBanner =>
      'הזן את מפתח השחזור שלך — הכתובת שלך (Nostr + Session) תשוחזר אוטומטית. אנשי קשר והודעות אוחסנו מקומית בלבד.';

  @override
  String get restoreKeyHint => 'מפתח שחזור';

  @override
  String get settingsViewRecoveryKey => 'הצג מפתח שחזור';

  @override
  String get settingsViewRecoveryKeySubtitle => 'הצג את מפתח השחזור של החשבון';

  @override
  String get settingsRecoveryKeyNotStored =>
      'מפתח שחזור לא זמין (נוצר לפני תכונה זו)';

  @override
  String get settingsRecoveryKeyWarning =>
      'שמור על המפתח הזה במקום בטוח. כל מי שמחזיק בו יכול לשחזר את החשבון שלך במכשיר אחר.';

  @override
  String get replaceIdentityTitle => 'להחליף זהות קיימת?';

  @override
  String get replaceIdentityBodyRestore =>
      'כבר קיימת זהות במכשיר זה. שחזור יחליף לצמיתות את מפתח ה-Nostr ו-seed ה-Oxen הנוכחיים שלך. כל אנשי הקשר יאבדו את היכולת להגיע לכתובת הנוכחית שלך.\n\nלא ניתן לבטל פעולה זו.';

  @override
  String get replaceIdentityBodyCreate =>
      'כבר קיימת זהות במכשיר זה. יצירת חדשה תחליף לצמיתות את מפתח ה-Nostr ו-seed ה-Oxen הנוכחיים שלך. כל אנשי הקשר יאבדו את היכולת להגיע לכתובת הנוכחית שלך.\n\nלא ניתן לבטל פעולה זו.';

  @override
  String get replace => 'החלף';

  @override
  String get callNoScreenSources => 'אין מקורות מסך זמינים';

  @override
  String get callScreenShareQuality => 'איכות שיתוף מסך';

  @override
  String get callFrameRate => 'קצב פריימים';

  @override
  String get callResolution => 'רזולוציה';

  @override
  String get callAutoResolution => 'אוטומטי = רזולוציית מסך מקורית';

  @override
  String get callStartSharing => 'התחל שיתוף';

  @override
  String get callCameraUnavailable =>
      'המצלמה לא זמינה — ייתכן שנמצאת בשימוש על ידי אפליקציה אחרת';

  @override
  String get themeResetToDefaults => 'אפס לברירת מחדל';

  @override
  String get backupSaveToDownloadsTitle => 'לשמור גיבוי בהורדות?';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'בוחר קבצים לא זמין. הגיבוי יישמר ב:\n$path';
  }

  @override
  String get systemLabel => 'מערכת';

  @override
  String get next => 'הבא';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return 'עוד $remaining הקשות להפעלת מצב מפתח';
  }

  @override
  String get devModeEnabled => 'מצב מפתח הופעל';

  @override
  String get devTools => 'כלי מפתח';

  @override
  String get devAdapterDiagnostics => 'מתגי מתאם ואבחון';

  @override
  String get devEnableAll => 'הפעל הכל';

  @override
  String get devDisableAll => 'השבת הכל';

  @override
  String get turnUrlValidation =>
      'כתובת TURN חייבת להתחיל ב-turn: או turns: (מקסימום 512 תווים)';

  @override
  String get callMissedCall => 'שיחה שלא נענתה';

  @override
  String get callOutgoingCall => 'שיחה יוצאת';

  @override
  String get callIncomingCall => 'שיחה נכנסת';

  @override
  String get mediaMissingData => 'נתוני מדיה חסרים';

  @override
  String get mediaDownloadFailed => 'הורדה נכשלה';

  @override
  String get mediaDecryptFailed => 'פענוח נכשל';

  @override
  String get callEndCallBanner => 'סיים שיחה';

  @override
  String get meFallback => 'אני';

  @override
  String get imageSaveToDownloads => 'שמור בהורדות';

  @override
  String imageSavedToPath(String path) {
    return 'נשמר ב-$path';
  }

  @override
  String get callScreenShareRequiresPermission => 'שיתוף מסך דורש הרשאה';

  @override
  String get callScreenShareUnavailable => 'שיתוף מסך לא זמין';

  @override
  String get statusJustNow => 'הרגע';

  @override
  String statusMinutesAgo(int minutes) {
    return 'לפני $minutesד';
  }

  @override
  String statusHoursAgo(int hours) {
    return 'לפני $hoursש';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count נתיבים',
      one: 'נתיב אחד',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => 'מוכן להוספה';

  @override
  String groupSelectedCount(int count) {
    return '$count נבחרו';
  }

  @override
  String get paste => 'הדבק';

  @override
  String get sfuAudioOnly => 'שמע בלבד';

  @override
  String sfuParticipants(int count) {
    return '$count משתתפים';
  }

  @override
  String get dataUnencryptedBackup => 'גיבוי לא מוצפן';

  @override
  String get dataUnencryptedBackupBody =>
      'קובץ זה הוא גיבוי זהות לא מוצפן וידרוס את המפתחות הנוכחיים שלך. ייבא רק קבצים שיצרת בעצמך. להמשיך?';

  @override
  String get dataImportAnyway => 'ייבא בכל זאת';

  @override
  String get securityStorageError =>
      'שגיאת אחסון מאובטח — הפעל מחדש את האפליקציה';

  @override
  String get aboutDevModeActive => 'מצב מפתח פעיל';

  @override
  String get themeColors => 'צבעים';

  @override
  String get themePrimaryAccent => 'הדגשה ראשית';

  @override
  String get themeSecondaryAccent => 'הדגשה משנית';

  @override
  String get themeBackground => 'רקע';

  @override
  String get themeSurface => 'משטח';

  @override
  String get themeChatBubbles => 'בועות צ\'אט';

  @override
  String get themeOutgoingMessage => 'הודעה יוצאת';

  @override
  String get themeIncomingMessage => 'הודעה נכנסת';

  @override
  String get themeShape => 'צורה';

  @override
  String get devSectionDeveloper => 'מפתח';

  @override
  String get devAdapterChannelsHint =>
      'ערוצי מתאם — השבת כדי לבדוק תעבורות ספציפיות.';

  @override
  String get devNostrRelays => 'ממסרי Nostr (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'רשת Session';

  @override
  String get devPulseRelay => 'Pulse relay באירוח עצמי';

  @override
  String get devLanNetwork => 'רשת מקומית (UDP/TCP)';

  @override
  String get devSectionCalls => 'שיחות';

  @override
  String get devForceTurnRelay => 'כפה TURN relay';

  @override
  String get devForceTurnRelaySubtitle =>
      'השבת P2P — כל השיחות דרך שרתי TURN בלבד';

  @override
  String get devRestartWarning =>
      '⚠ השינויים ייכנסו לתוקף בשליחה/שיחה הבאה. הפעל מחדש את האפליקציה להחלה על נכנסות.';

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
  String get pulseUseServerTitle => 'להשתמש בשרת Pulse?';

  @override
  String pulseUseServerBody(String name, String host) {
    return '$name משתמש בשרת Pulse $host. להצטרף כדי לשוחח מהר יותר (וגם עם אחרים באותו שרת)?';
  }

  @override
  String pulseContactUsesPulse(String name) {
    return '$name משתמש ב-Pulse';
  }

  @override
  String pulseJoinForFaster(String host) {
    return 'הצטרף ל-$host לשיחה מהירה יותר';
  }

  @override
  String get pulseNotNow => 'לא עכשיו';

  @override
  String get pulseJoin => 'הצטרפות';

  @override
  String get pulseDismiss => 'סגור';

  @override
  String get pulseHide7Days => 'הסתר ל-7 ימים';

  @override
  String get pulseNeverAskAgain => 'אל תשאל שוב';

  @override
  String get groupSearchContactsHint => 'חיפוש אנשי קשר…';

  @override
  String get systemActorYou => 'אתה';

  @override
  String get systemActorPeer => 'איש קשר';

  @override
  String systemTtlEnabled(String actor, String duration) {
    return '$actor הפעיל הודעות נעלמות: $duration';
  }

  @override
  String systemTtlDisabled(String actor) {
    return '$actor השבית הודעות נעלמות';
  }

  @override
  String get menuClearChatHistory => 'נקה היסטוריית צ\'אט';

  @override
  String get clearChatTitle => 'לנקות את היסטוריית הצ\'אט?';

  @override
  String get clearChatBody =>
      'כל ההודעות בצ\'אט זה יימחקו מהמכשיר הזה. הצד השני ישמור את העותק שלו.';

  @override
  String get clearChatAction => 'נקה';

  @override
  String systemGroupRenamed(String actor, String name) {
    return '$actor שינה את שם הקבוצה ל-\"$name\"';
  }

  @override
  String systemGroupAvatarChanged(String actor) {
    return '$actor שינה את תמונת הקבוצה';
  }

  @override
  String systemGroupMetaChanged(String actor, String name) {
    return '$actor שינה את שם הקבוצה ל-\"$name\" ושינה את התמונה';
  }

  @override
  String get profileInviteLink => 'קישור הזמנה';

  @override
  String get profileInviteLinkSubtitle => 'כל אחד עם הקישור יכול להצטרף';

  @override
  String get profileInviteLinkCopied => 'קישור ההזמנה הועתק';

  @override
  String get groupInviteLinkTitle => 'להצטרף לקבוצה?';

  @override
  String groupInviteLinkBody(String name, int count) {
    return 'הוזמנת ל-\"$name\" ($count חברים).';
  }

  @override
  String get groupInviteLinkJoin => 'הצטרף';

  @override
  String get drawerCreateGroup => 'יצירת קבוצה';

  @override
  String get drawerJoinGroup => 'הצטרפות לקבוצה';

  @override
  String get drawerJoinGroupByLinkInvalid =>
      'זה לא נראה כמו קישור הזמנה של Pulse';

  @override
  String get groupModeMeshTitle => 'רגיל';

  @override
  String groupModeMeshSubtitle(int n) {
    return 'ללא שרת, עד $n אנשים';
  }

  @override
  String get groupModeSfuTitle => 'עם שרת Pulse';

  @override
  String groupModeSfuSubtitle(int n) {
    return 'דרך שרת, עד $n אנשים';
  }

  @override
  String get groupPulseServerHint => 'https://שרת-pulse-שלך';

  @override
  String get groupPulseServerClosed => 'שרת סגור (דורש קוד הזמנה)';

  @override
  String get groupPulseInviteHint => 'קוד הזמנה';

  @override
  String groupMeshLimitReached(int n) {
    return 'סוג שיחה זה מוגבל ל-$n אנשים';
  }
}
