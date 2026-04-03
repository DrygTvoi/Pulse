// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Xabarlarni qidirish...';

  @override
  String get search => 'Qidirish';

  @override
  String get clearSearch => 'Qidiruvni tozalash';

  @override
  String get closeSearch => 'Qidiruvni yopish';

  @override
  String get moreOptions => 'Boshqa variantlar';

  @override
  String get back => 'Orqaga';

  @override
  String get cancel => 'Bekor qilish';

  @override
  String get close => 'Yopish';

  @override
  String get confirm => 'Tasdiqlash';

  @override
  String get remove => 'Oʻchirish';

  @override
  String get save => 'Saqlash';

  @override
  String get add => 'Qoʻshish';

  @override
  String get copy => 'Nusxalash';

  @override
  String get skip => 'Oʻtkazib yuborish';

  @override
  String get done => 'Tayyor';

  @override
  String get apply => 'Qoʻllash';

  @override
  String get export => 'Eksport';

  @override
  String get import => 'Import';

  @override
  String get homeNewGroup => 'Yangi guruh';

  @override
  String get homeSettings => 'Sozlamalar';

  @override
  String get homeSearching => 'Xabarlar qidirilmoqda...';

  @override
  String get homeNoResults => 'Natija topilmadi';

  @override
  String get homeNoChatHistory => 'Chat tarixi hali yoʻq';

  @override
  String homeTransportSwitched(String address) {
    return 'Transport almashtirildi → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name qoʻngʻiroq qilmoqda...';
  }

  @override
  String get homeAccept => 'Qabul qilish';

  @override
  String get homeDecline => 'Rad etish';

  @override
  String get homeLoadEarlier => 'Oldingi xabarlarni yuklash';

  @override
  String get homeChats => 'Chatlar';

  @override
  String get homeSelectConversation => 'Suhbatni tanlang';

  @override
  String get homeNoChatsYet => 'Hali chatlar yoʻq';

  @override
  String get homeAddContactToStart =>
      'Yozishma boshlash uchun kontakt qoʻshing';

  @override
  String get homeNewChat => 'Yangi chat';

  @override
  String get homeNewChatTooltip => 'Yangi chat';

  @override
  String get homeIncomingCallTitle => 'Kiruvchi qoʻngʻiroq';

  @override
  String get homeIncomingGroupCallTitle => 'Kiruvchi guruh qoʻngʻirogʻi';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — kiruvchi guruh qoʻngʻirogʻi';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return '\"$query\" boʻyicha chatlar topilmadi';
  }

  @override
  String get homeSectionChats => 'Chatlar';

  @override
  String get homeSectionMessages => 'Xabarlar';

  @override
  String get homeDbEncryptionUnavailable =>
      'Maʼlumotlar bazasi shifrlash mavjud emas — toʻliq himoya uchun SQLCipher oʻrnating';

  @override
  String get chatFileTooLargeGroup =>
      '512 KB dan ortiq fayllar guruh chatlarida qoʻllab-quvvatlanmaydi';

  @override
  String get chatLargeFile => 'Katta fayl';

  @override
  String get chatCancel => 'Bekor qilish';

  @override
  String get chatSend => 'Yuborish';

  @override
  String get chatFileTooLarge => 'Fayl juda katta — maksimal hajm 100 MB';

  @override
  String get chatMicDenied => 'Mikrofonga ruxsat berilmadi';

  @override
  String get chatVoiceFailed =>
      'Ovozli xabarni saqlashda xatolik — mavjud xotirani tekshiring';

  @override
  String get chatScheduleFuture =>
      'Rejalashtirilgan vaqt kelajakda boʻlishi kerak';

  @override
  String get chatToday => 'Bugun';

  @override
  String get chatYesterday => 'Kecha';

  @override
  String get chatEdited => 'tahrirlangan';

  @override
  String get chatYou => 'Siz';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Bu fayl hajmi $size MB. Katta fayllarni yuborish baʼzi tarmoqlarda sekin boʻlishi mumkin. Davom etsinmi?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return '$name xavfsizlik kaliti oʻzgardi. Tasdiqlash uchun bosing.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return '$name ga xabarni shifrlab boʻlmadi — xabar yuborilmadi.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return '$name uchun xavfsizlik raqami oʻzgardi. Tasdiqlash uchun bosing.';
  }

  @override
  String get chatNoMessagesFound => 'Xabarlar topilmadi';

  @override
  String get chatMessagesE2ee => 'Xabarlar oxirigacha shifrlangan';

  @override
  String get chatSayHello => 'Salom ayting';

  @override
  String get appBarOnline => 'onlayn';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'yozmoqda';

  @override
  String get appBarSearchMessages => 'Xabarlarni qidirish...';

  @override
  String get appBarMute => 'Ovozni oʻchirish';

  @override
  String get appBarUnmute => 'Ovozni yoqish';

  @override
  String get appBarMedia => 'Media';

  @override
  String get appBarDisappearing => 'Yoʻqoladigan xabarlar';

  @override
  String get appBarDisappearingOn => 'Yoʻqolish: yoniq';

  @override
  String get appBarGroupSettings => 'Guruh sozlamalari';

  @override
  String get appBarSearchTooltip => 'Xabarlarni qidirish';

  @override
  String get appBarVoiceCall => 'Ovozli qoʻngʻiroq';

  @override
  String get appBarVideoCall => 'Video qoʻngʻiroq';

  @override
  String get inputMessage => 'Xabar...';

  @override
  String get inputAttachFile => 'Fayl biriktirish';

  @override
  String get inputSendMessage => 'Xabar yuborish';

  @override
  String get inputRecordVoice => 'Ovozli xabar yozish';

  @override
  String get inputSendVoice => 'Ovozli xabarni yuborish';

  @override
  String get inputCancelReply => 'Javobni bekor qilish';

  @override
  String get inputCancelEdit => 'Tahrirlashni bekor qilish';

  @override
  String get inputCancelRecording => 'Yozishni bekor qilish';

  @override
  String get inputRecording => 'Yozilmoqda…';

  @override
  String get inputEditingMessage => 'Xabar tahrirlanmoqda';

  @override
  String get inputPhoto => 'Rasm';

  @override
  String get inputVoiceMessage => 'Ovozli xabar';

  @override
  String get inputFile => 'Fayl';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'lar',
      one: '',
    );
    return '$count rejalashtirilgan xabar$_temp0';
  }

  @override
  String get callInitializing => 'Qoʻngʻiroq boshlanmoqda…';

  @override
  String get callConnecting => 'Ulanmoqda…';

  @override
  String get callConnectingRelay => 'Ulanmoqda (relay)…';

  @override
  String get callSwitchingRelay => 'Relay rejimiga oʻtilmoqda…';

  @override
  String get callConnectionFailed => 'Ulanish muvaffaqiyatsiz';

  @override
  String get callReconnecting => 'Qayta ulanmoqda…';

  @override
  String get callEnded => 'Qoʻngʻiroq tugadi';

  @override
  String get callLive => 'Jonli';

  @override
  String get callEnd => 'Tugatish';

  @override
  String get callEndCall => 'Qoʻngʻiroqni tugatish';

  @override
  String get callMute => 'Ovozni oʻchirish';

  @override
  String get callUnmute => 'Ovozni yoqish';

  @override
  String get callSpeaker => 'Karnay';

  @override
  String get callCameraOn => 'Kamera yoniq';

  @override
  String get callCameraOff => 'Kamera oʻchiq';

  @override
  String get callShareScreen => 'Ekranni ulashish';

  @override
  String get callStopShare => 'Ulashishni toʻxtatish';

  @override
  String callTorBackup(String duration) {
    return 'Tor zaxira · $duration';
  }

  @override
  String get callTorBackupBanner => 'Tor zaxira faol — asosiy yoʻl mavjud emas';

  @override
  String get callDirectFailed =>
      'Toʻgʻridan-toʻgʻri ulanish muvaffaqiyatsiz — relay rejimiga oʻtilmoqda…';

  @override
  String get callTurnUnreachable =>
      'TURN serverlariga ulanib boʻlmadi. Sozlamalar → Kengaytirilgan boʻlimiga maxsus TURN qoʻshing.';

  @override
  String get callRelayMode => 'Relay rejimi faol (cheklangan tarmoq)';

  @override
  String get callStarting => 'Qoʻngʻiroq boshlanmoqda…';

  @override
  String get callConnectingToGroup => 'Guruhga ulanmoqda…';

  @override
  String get callGroupOpenedInBrowser => 'Guruh qoʻngʻirogʻi brauzerda ochildi';

  @override
  String get callCouldNotOpenBrowser => 'Brauzerni ochib boʻlmadi';

  @override
  String get callInviteLinkSent =>
      'Taklif havolasi barcha guruh aʼzolariga yuborildi.';

  @override
  String get callOpenLinkManually =>
      'Yuqoridagi havolani qoʻlda oching yoki qayta urinish uchun bosing.';

  @override
  String get callJitsiNotE2ee =>
      'Jitsi qoʻngʻiroqlari oxirigacha shifrlangan EMAS';

  @override
  String get callRetryOpenBrowser => 'Brauzerni qayta ochish';

  @override
  String get callClose => 'Yopish';

  @override
  String get callCamOn => 'Kamera yoniq';

  @override
  String get callCamOff => 'Kamera oʻchiq';

  @override
  String get noConnection => 'Aloqa yoʻq — xabarlar navbatga qoʻyiladi';

  @override
  String get connected => 'Ulangan';

  @override
  String get connecting => 'Ulanmoqda…';

  @override
  String get disconnected => 'Uzilgan';

  @override
  String get offlineBanner =>
      'Aloqa yoʻq — xabarlar qayta onlayn boʻlganda yuboriladi';

  @override
  String get lanModeBanner =>
      'LAN rejimi — Internet yoʻq · Faqat mahalliy tarmoq';

  @override
  String get probeCheckingNetwork => 'Tarmoq aloqasi tekshirilmoqda…';

  @override
  String get probeDiscoveringRelays =>
      'Jamiyat kataloglari orqali relaylar topilmoqda…';

  @override
  String get probeStartingTor => 'Tor ishga tushirilmoqda…';

  @override
  String get probeFindingRelaysTor => 'Tor orqali mavjud relaylar topilmoqda…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'lar',
      one: '',
    );
    return 'Tarmoq tayyor — $count relay$_temp0 topildi';
  }

  @override
  String get probeNoRelaysFound =>
      'Mavjud relaylar topilmadi — xabarlar kechikishi mumkin';

  @override
  String get jitsiWarningTitle => 'Oxirigacha shifrlangan emas';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet qoʻngʻiroqlari Pulse tomonidan shifrlanmaydi. Faqat maxfiy boʻlmagan suhbatlar uchun foydalaning.';

  @override
  String get jitsiConfirm => 'Baribir qoʻshilish';

  @override
  String get jitsiGroupWarningTitle => 'Oxirigacha shifrlangan emas';

  @override
  String get jitsiGroupWarningBody =>
      'Bu qoʻngʻiroqda ichki shifrlangan mesh uchun juda koʻp ishtirokchi bor.\n\nJitsi Meet havolasi brauzeringizda ochiladi. Jitsi oxirigacha shifrlangan EMAS — server sizning qoʻngʻirogʻingizni koʻrishi mumkin.';

  @override
  String get jitsiContinueAnyway => 'Baribir davom etish';

  @override
  String get retry => 'Qayta urinish';

  @override
  String get setupCreateAnonymousAccount => 'Anonim hisob yaratish';

  @override
  String get setupTapToChangeColor => 'Rangni oʻzgartirish uchun bosing';

  @override
  String get setupReqMinLength => 'Kamida 16 ta belgi';

  @override
  String get setupReqVariety =>
      '4 tadan 3: katta, kichik harflar, raqamlar, belgilar';

  @override
  String get setupReqMatch => 'Parollar mos keladi';

  @override
  String get setupYourNickname => 'Sizning taxallusingiz';

  @override
  String get setupRecoveryPassword => 'Tiklash paroli (min. 16)';

  @override
  String get setupConfirmPassword => 'Parolni tasdiqlash';

  @override
  String get setupMin16Chars => 'Kamida 16 belgi';

  @override
  String get setupPasswordsDoNotMatch => 'Parollar mos kelmaydi';

  @override
  String get setupEntropyWeak => 'Zaif';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Kuchli';

  @override
  String get setupEntropyWeakNeedsVariety => 'Zaif (3 tur belgi kerak)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bit)';
  }

  @override
  String get setupPasswordWarning =>
      'Bu parol hisobingizni tiklashning yagona yoʻli. Server yoʻq — parolni tiklash imkoni yoʻq. Eslab qoling yoki yozib oling.';

  @override
  String get setupCreateAccount => 'Hisob yaratish';

  @override
  String get setupAlreadyHaveAccount => 'Hisobingiz bormi? ';

  @override
  String get setupRestore => 'Tiklash →';

  @override
  String get restoreTitle => 'Hisobni tiklash';

  @override
  String get restoreInfoBanner =>
      'Tiklash parolingizni kiriting — manzilingiz (Nostr + Session) avtomatik tiklanadi. Kontaktlar va xabarlar faqat mahalliy saqlangan edi.';

  @override
  String get restoreNewNickname =>
      'Yangi taxallus (keyinroq oʻzgartirish mumkin)';

  @override
  String get restoreButton => 'Hisobni tiklash';

  @override
  String get lockTitle => 'Pulse qulflangan';

  @override
  String get lockSubtitle => 'Davom etish uchun parolingizni kiriting';

  @override
  String get lockPasswordHint => 'Parol';

  @override
  String get lockUnlock => 'Qulfdan chiqarish';

  @override
  String get lockPanicHint =>
      'Parolni unutdingizmi? Barcha maʼlumotlarni oʻchirish uchun favqulodda kalitni kiriting.';

  @override
  String get lockTooManyAttempts =>
      'Juda koʻp urinishlar. Barcha maʼlumotlar oʻchirilmoqda…';

  @override
  String get lockWrongPassword => 'Notoʻgʻri parol';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Notoʻgʻri parol — $attempts/$max urinish';
  }

  @override
  String get onboardingSkip => 'Oʻtkazib yuborish';

  @override
  String get onboardingNext => 'Keyingi';

  @override
  String get onboardingGetStarted => 'Boshlash';

  @override
  String get onboardingWelcomeTitle => 'Pulse ga xush kelibsiz';

  @override
  String get onboardingWelcomeBody =>
      'Markazlashmagan, oxirigacha shifrlangan messenjer.\n\nMarkaziy serverlar yoʻq. Maʼlumot yigʻish yoʻq. Yashirin eshiklar yoʻq.\nSuhbatlaringiz faqat sizga tegishli.';

  @override
  String get onboardingTransportTitle => 'Transportga bogʻliq emas';

  @override
  String get onboardingTransportBody =>
      'Firebase, Nostr yoki ikkalasini bir vaqtda ishlating.\n\nXabarlar tarmoqlar boʻylab avtomatik yoʻnaltiriladi. Senzuraga qarshilik uchun ichki Tor va I2P qoʻllab-quvvatlash.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Kvant';

  @override
  String get onboardingSignalBody =>
      'Har bir xabar Signal Protocol (Double Ratchet + X3DH) bilan forward secrecy uchun shifrlanadi.\n\nQoʻshimcha ravishda Kyber-1024 — NIST standart post-kvant algoritmi — bilan oʻralgan, kelajakdagi kvant kompyuterlardan himoya.';

  @override
  String get onboardingKeysTitle => 'Kalitlaringiz sizniki';

  @override
  String get onboardingKeysBody =>
      'Identifikatsiya kalitlaringiz qurilmangizdan hech qachon chiqmaydi.\n\nSignal barmoq izlari kontaktlarni tashqi kanal orqali tasdiqlashga imkon beradi. TOFU (Trust On First Use) kalit oʻzgarishlarini avtomatik aniqlaydi.';

  @override
  String get onboardingThemeTitle => 'Koʻrinishni tanlang';

  @override
  String get onboardingThemeBody =>
      'Mavzu va urg\'u rangini tanlang. Buni istalgan vaqt Sozlamalarda oʻzgartirishingiz mumkin.';

  @override
  String get contactsNewChat => 'Yangi chat';

  @override
  String get contactsAddContact => 'Kontakt qoʻshish';

  @override
  String get contactsSearchHint => 'Qidirish...';

  @override
  String get contactsNewGroup => 'Yangi guruh';

  @override
  String get contactsNoContactsYet => 'Hali kontaktlar yoʻq';

  @override
  String get contactsAddHint => 'Manzil qoʻshish uchun + bosing';

  @override
  String get contactsNoMatch => 'Mos kontaktlar yoʻq';

  @override
  String get contactsRemoveTitle => 'Kontaktni oʻchirish';

  @override
  String contactsRemoveMessage(String name) {
    return '$name oʻchirilsinmi?';
  }

  @override
  String get contactsRemove => 'Oʻchirish';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'lar',
      one: '',
    );
    return '$count kontakt$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Havolani ochish';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Bu URL brauzerda ochilsinmi?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Ochish';

  @override
  String get bubbleSecurityWarning => 'Xavfsizlik ogohlantirishi';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" bajariladigan fayl turi. Saqlash va ishga tushirish qurilmangizga zarar yetkazishi mumkin. Baribir saqlansinmi?';
  }

  @override
  String get bubbleSaveAnyway => 'Baribir saqlash';

  @override
  String bubbleSavedTo(String path) {
    return '$path ga saqlandi';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Saqlash muvaffaqiyatsiz: $error';
  }

  @override
  String get bubbleNotEncrypted => 'SHIFRLANMAGAN';

  @override
  String get bubbleCorruptedImage => '[Buzilgan rasm]';

  @override
  String get bubbleReplyPhoto => 'Rasm';

  @override
  String get bubbleReplyVoice => 'Ovozli xabar';

  @override
  String get bubbleReplyVideo => 'Video xabar';

  @override
  String bubbleReadBy(String names) {
    return '$names oʻqidi';
  }

  @override
  String bubbleReadByCount(int count) {
    return '$count kishi oʻqidi';
  }

  @override
  String get chatTileTapToStart => 'Yozishma boshlash uchun bosing';

  @override
  String get chatTileMessageSent => 'Xabar yuborildi';

  @override
  String get chatTileEncryptedMessage => 'Shifrlangan xabar';

  @override
  String chatTileYouPrefix(String text) {
    return 'Siz: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Ovozli xabar';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Ovozli xabar ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Shifrlangan xabar';

  @override
  String get groupNewGroup => 'Yangi guruh';

  @override
  String get groupGroupName => 'Guruh nomi';

  @override
  String get groupSelectMembers => 'Aʼzolarni tanlang (min 2)';

  @override
  String get groupNoContactsYet =>
      'Hali kontaktlar yoʻq. Avval kontaktlarni qoʻshing.';

  @override
  String get groupCreate => 'Yaratish';

  @override
  String get groupLabel => 'Guruh';

  @override
  String get profileVerifyIdentity => 'Identifikatsiyani tasdiqlash';

  @override
  String profileVerifyInstructions(String name) {
    return 'Bu barmoq izlarini $name bilan ovozli qoʻngʻiroq yoki shaxsan solishtiring. Agar ikkala qurilmada qiymatlar mos kelsa, \"Tasdiqlangan deb belgilash\" tugmasini bosing.';
  }

  @override
  String get profileTheirKey => 'Ularning kaliti';

  @override
  String get profileYourKey => 'Sizning kalitingiz';

  @override
  String get profileRemoveVerification => 'Tasdiqlashni olib tashlash';

  @override
  String get profileMarkAsVerified => 'Tasdiqlangan deb belgilash';

  @override
  String get profileAddressCopied => 'Manzil nusxalandi';

  @override
  String get profileNoContactsToAdd =>
      'Qoʻshish uchun kontaktlar yoʻq — hammasi allaqachon aʼzo';

  @override
  String get profileAddMembers => 'Aʼzolarni qoʻshish';

  @override
  String profileAddCount(int count) {
    return 'Qoʻshish ($count)';
  }

  @override
  String get profileRenameGroup => 'Guruhni qayta nomlash';

  @override
  String get profileRename => 'Qayta nomlash';

  @override
  String get profileRemoveMember => 'Aʼzo olib tashlansinmi?';

  @override
  String profileRemoveMemberBody(String name) {
    return '$name bu guruhdan olib tashlansinmi?';
  }

  @override
  String get profileKick => 'Chiqarish';

  @override
  String get profileSignalFingerprints => 'Signal barmoq izlari';

  @override
  String get profileVerified => 'TASDIQLANGAN';

  @override
  String get profileVerify => 'Tasdiqlash';

  @override
  String get profileEdit => 'Tahrirlash';

  @override
  String get profileNoSession =>
      'Hali seans oʻrnatilmagan — avval xabar yuboring.';

  @override
  String get profileFingerprintCopied => 'Barmoq izi nusxalandi';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'lar',
      one: '',
    );
    return '$count aʼzo$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Xavfsizlik raqamini tasdiqlash';

  @override
  String get profileShowContactQr => 'Kontakt QR koʻrsatish';

  @override
  String profileContactAddress(String name) {
    return '$name manzili';
  }

  @override
  String get profileExportChatHistory => 'Chat tarixini eksport qilish';

  @override
  String profileSavedTo(String path) {
    return '$path ga saqlandi';
  }

  @override
  String get profileExportFailed => 'Eksport muvaffaqiyatsiz';

  @override
  String get profileClearChatHistory => 'Chat tarixini tozalash';

  @override
  String get profileDeleteGroup => 'Guruhni oʻchirish';

  @override
  String get profileDeleteContact => 'Kontaktni oʻchirish';

  @override
  String get profileLeaveGroup => 'Guruhni tark etish';

  @override
  String get profileLeaveGroupBody =>
      'Siz bu guruhdan olib tashlanasiz va u kontaktlaringizdan oʻchiriladi.';

  @override
  String get groupInviteTitle => 'Guruhga taklif';

  @override
  String groupInviteBody(String from, String group) {
    return '$from sizni \"$group\" ga qoʻshilishga taklif qildi';
  }

  @override
  String get groupInviteAccept => 'Qabul qilish';

  @override
  String get groupInviteDecline => 'Rad etish';

  @override
  String get groupMemberLimitTitle => 'Juda koʻp ishtirokchi';

  @override
  String groupMemberLimitBody(int count) {
    return 'Bu guruhda $count ta ishtirokchi boʻladi. Shifrlangan mesh qoʻngʻiroqlar 6 tagacha qoʻllab-quvvatlaydi. Kattaroq guruhlar Jitsi ga oʻtadi (E2EE emas).';
  }

  @override
  String get groupMemberLimitContinue => 'Baribir qoʻshish';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name \"$group\" ga qoʻshilishni rad etdi';
  }

  @override
  String get transferTitle => 'Boshqa qurilmaga koʻchirish';

  @override
  String get transferInfoBox =>
      'Signal identifikatsiyasi va Nostr kalitlaringizni yangi qurilmaga koʻchiring.\nChat seanslar koʻchirilMAYDI — forward secrecy saqlanadi.';

  @override
  String get transferSendFromThis => 'Bu qurilmadan yuborish';

  @override
  String get transferSendSubtitle =>
      'Bu qurilmada kalitlar bor. Yangi qurilma bilan kod ulashing.';

  @override
  String get transferReceiveOnThis => 'Bu qurilmada qabul qilish';

  @override
  String get transferReceiveSubtitle =>
      'Bu yangi qurilma. Eski qurilmadan kodni kiriting.';

  @override
  String get transferChooseMethod => 'Koʻchirish usulini tanlang';

  @override
  String get transferLan => 'LAN (Bir tarmoqda)';

  @override
  String get transferLanSubtitle =>
      'Tez va toʻgʻridan-toʻgʻri. Ikkala qurilma bir Wi-Fi da boʻlishi kerak.';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'Mavjud Nostr relay orqali istalgan tarmoqda ishlaydi.';

  @override
  String get transferRelayUrl => 'Relay URL';

  @override
  String get transferEnterCode => 'Koʻchirish kodini kiriting';

  @override
  String get transferPasteCode =>
      'LAN:... yoki NOS:... kodni shu yerga joylashtiring';

  @override
  String get transferConnect => 'Ulanish';

  @override
  String get transferGenerating => 'Koʻchirish kodi yaratilmoqda…';

  @override
  String get transferShareCode => 'Bu kodni qabul qiluvchi bilan ulashing:';

  @override
  String get transferCopyCode => 'Kodni nusxalash';

  @override
  String get transferCodeCopied => 'Kod vaqtinchalik xotiraga nusxalandi';

  @override
  String get transferWaitingReceiver => 'Qabul qiluvchi ulanishini kutilmoqda…';

  @override
  String get transferConnectingSender => 'Yuboruvchiga ulanmoqda…';

  @override
  String get transferVerifyBoth =>
      'Bu kodni ikkala qurilmada solishtiring.\nAgar mos kelsa, koʻchirish xavfsiz.';

  @override
  String get transferComplete => 'Koʻchirish yakunlandi';

  @override
  String get transferKeysImported => 'Kalitlar import qilindi';

  @override
  String get transferCompleteSenderBody =>
      'Kalitlaringiz bu qurilmada faol qoladi.\nQabul qiluvchi endi sizning identifikatsiyangizdan foydalanishi mumkin.';

  @override
  String get transferCompleteReceiverBody =>
      'Kalitlar muvaffaqiyatli import qilindi.\nYangi identifikatsiyani qoʻllash uchun ilovani qayta ishga tushiring.';

  @override
  String get transferRestartApp => 'Ilovani qayta ishga tushirish';

  @override
  String get transferFailed => 'Koʻchirish muvaffaqiyatsiz';

  @override
  String get transferTryAgain => 'Qayta urinish';

  @override
  String get transferEnterRelayFirst => 'Avval relay URL kiriting';

  @override
  String get transferPasteCodeFromSender =>
      'Yuboruvchidan koʻchirish kodini joylashtiring';

  @override
  String get menuReply => 'Javob berish';

  @override
  String get menuForward => 'Yuborish';

  @override
  String get menuReact => 'Reaksiya';

  @override
  String get menuCopy => 'Nusxalash';

  @override
  String get menuEdit => 'Tahrirlash';

  @override
  String get menuRetry => 'Qayta urinish';

  @override
  String get menuCancelScheduled => 'Rejalashtirilganni bekor qilish';

  @override
  String get menuDelete => 'Oʻchirish';

  @override
  String get menuForwardTo => 'Ga yuborish…';

  @override
  String menuForwardedTo(String name) {
    return '$name ga yuborildi';
  }

  @override
  String get menuScheduledMessages => 'Rejalashtirilgan xabarlar';

  @override
  String get menuNoScheduledMessages => 'Rejalashtirilgan xabarlar yoʻq';

  @override
  String menuSendsOn(String date) {
    return '$date da yuboriladi';
  }

  @override
  String get menuDisappearingMessages => 'Yoʻqoladigan xabarlar';

  @override
  String get menuDisappearingSubtitle =>
      'Xabarlar tanlangan vaqtdan keyin avtomatik oʻchiriladi.';

  @override
  String get menuTtlOff => 'Oʻchiq';

  @override
  String get menuTtl1h => '1 soat';

  @override
  String get menuTtl24h => '24 soat';

  @override
  String get menuTtl7d => '7 kun';

  @override
  String get menuAttachPhoto => 'Rasm';

  @override
  String get menuAttachFile => 'Fayl';

  @override
  String get menuAttachVideo => 'Video';

  @override
  String get mediaTitle => 'Media';

  @override
  String get mediaFileLabel => 'FAYL';

  @override
  String mediaPhotosTab(int count) {
    return 'Rasmlar ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Fayllar ($count)';
  }

  @override
  String get mediaNoPhotos => 'Hali rasmlar yoʻq';

  @override
  String get mediaNoFiles => 'Hali fayllar yoʻq';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Downloads/$name ga saqlandi';
  }

  @override
  String get mediaFailedToSave => 'Faylni saqlashda xatolik';

  @override
  String get statusNewStatus => 'Yangi holat';

  @override
  String get statusPublish => 'Eʼlon qilish';

  @override
  String get statusExpiresIn24h => 'Holat 24 soatda tugaydi';

  @override
  String get statusWhatsOnYourMind => 'Nima haqida oʻylayapsiz?';

  @override
  String get statusPhotoAttached => 'Rasm biriktirildi';

  @override
  String get statusAttachPhoto => 'Rasm biriktirish (ixtiyoriy)';

  @override
  String get statusEnterText => 'Holatingiz uchun matn kiriting.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Rasm tanlashda xatolik: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Eʼlon qilishda xatolik: $error';
  }

  @override
  String get panicSetPanicKey => 'Favqulodda kalit oʻrnatish';

  @override
  String get panicEmergencySelfDestruct => 'Favqulodda oʻz-oʻzini yoʻq qilish';

  @override
  String get panicIrreversible => 'Bu amal qaytarilmas';

  @override
  String get panicWarningBody =>
      'Bu kalitni qulf ekranida kiritish barcha maʼlumotlarni darhol oʻchiradi — xabarlar, kontaktlar, kalitlar, identifikatsiya. Oddiy parolingizdan boshqa kalit ishlating.';

  @override
  String get panicKeyHint => 'Favqulodda kalit';

  @override
  String get panicConfirmHint => 'Favqulodda kalitni tasdiqlash';

  @override
  String get panicMinChars =>
      'Favqulodda kalit kamida 8 belgidan iborat boʻlishi kerak';

  @override
  String get panicKeysDoNotMatch => 'Kalitlar mos kelmaydi';

  @override
  String get panicSetFailed =>
      'Favqulodda kalitni saqlashda xatolik — qayta urinib koʻring';

  @override
  String get passwordSetAppPassword => 'Ilova paroli oʻrnatish';

  @override
  String get passwordProtectsMessages =>
      'Xabarlaringizni tinch holatda himoyalaydi';

  @override
  String get passwordInfoBanner =>
      'Pulse ni har ochganingizda talab qilinadi. Agar unutsangiz, maʼlumotlaringizni tiklash mumkin emas.';

  @override
  String get passwordHint => 'Parol';

  @override
  String get passwordConfirmHint => 'Parolni tasdiqlash';

  @override
  String get passwordSetButton => 'Parol oʻrnatish';

  @override
  String get passwordSkipForNow => 'Hozircha oʻtkazib yuborish';

  @override
  String get passwordMinChars =>
      'Parol kamida 6 belgidan iborat boʻlishi kerak';

  @override
  String get passwordsDoNotMatch => 'Parollar mos kelmaydi';

  @override
  String get profileCardSaved => 'Profil saqlandi!';

  @override
  String get profileCardE2eeIdentity => 'E2EE identifikatsiya';

  @override
  String get profileCardDisplayName => 'Koʻrsatiladigan ism';

  @override
  String get profileCardDisplayNameHint => 'masalan, Ali Valiyev';

  @override
  String get profileCardAbout => 'Haqida';

  @override
  String get profileCardSaveProfile => 'Profilni saqlash';

  @override
  String get profileCardYourName => 'Ismingiz';

  @override
  String get profileCardAddressCopied => 'Manzil nusxalandi!';

  @override
  String get profileCardInboxAddress => 'Kiruvchi manzil';

  @override
  String get profileCardInboxAddresses => 'Kiruvchi manzillar';

  @override
  String get profileCardShareAllAddresses =>
      'Barcha manzillarni ulashish (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Kontaktlar bilan ulashing, ular sizga xabar yubora olsin.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Barcha $count manzil bitta havola sifatida nusxalandi!';
  }

  @override
  String get settingsMyProfile => 'Mening profilim';

  @override
  String get settingsYourInboxAddress => 'Kiruvchi manzilingiz';

  @override
  String get settingsMyQrCode => 'Mening QR kodom';

  @override
  String get settingsMyQrSubtitle =>
      'Manzilingizni skanerlanadigan QR sifatida ulashing';

  @override
  String get settingsShareMyAddress => 'Manzilimni ulashish';

  @override
  String get settingsNoAddressYet =>
      'Hali manzil yoʻq — avval sozlamalarni saqlang';

  @override
  String get settingsInviteLink => 'Taklif havolasi';

  @override
  String get settingsRawAddress => 'Xom manzil';

  @override
  String get settingsCopyLink => 'Havolani nusxalash';

  @override
  String get settingsCopyAddress => 'Manzilni nusxalash';

  @override
  String get settingsInviteLinkCopied => 'Taklif havolasi nusxalandi';

  @override
  String get settingsAppearance => 'Koʻrinish';

  @override
  String get settingsThemeEngine => 'Mavzu mexanizmi';

  @override
  String get settingsThemeEngineSubtitle => 'Ranglar va shriftlarni sozlash';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle =>
      'E2EE kalitlar xavfsiz saqlangan';

  @override
  String get settingsActive => 'FAOL';

  @override
  String get settingsIdentityBackup => 'Identifikatsiya zaxirasi';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Signal identifikatsiyangizni eksport yoki import qilish';

  @override
  String get settingsIdentityBackupBody =>
      'Signal identifikatsiya kalitlaringizni zaxira kodga eksport qiling yoki mavjudidan tiklang.';

  @override
  String get settingsTransferDevice => 'Boshqa qurilmaga koʻchirish';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Identifikatsiyangizni LAN yoki Nostr relay orqali koʻchiring';

  @override
  String get settingsExportIdentity => 'Identifikatsiyani eksport qilish';

  @override
  String get settingsExportIdentityBody =>
      'Bu zaxira kodini nusxalab xavfsiz joyda saqlang:';

  @override
  String get settingsSaveFile => 'Faylni saqlash';

  @override
  String get settingsImportIdentity => 'Identifikatsiyani import qilish';

  @override
  String get settingsImportIdentityBody =>
      'Zaxira kodingizni quyiga joylashtiring. Bu joriy identifikatsiyangizni qayta yozadi.';

  @override
  String get settingsPasteBackupCode =>
      'Zaxira kodini shu yerga joylashtiring…';

  @override
  String get settingsIdentityImported =>
      'Identifikatsiya + kontaktlar import qilindi! Qoʻllash uchun ilovani qayta ishga tushiring.';

  @override
  String get settingsSecurity => 'Xavfsizlik';

  @override
  String get settingsAppPassword => 'Ilova paroli';

  @override
  String get settingsPasswordEnabled =>
      'Yoniq — har ishga tushirishda talab qilinadi';

  @override
  String get settingsPasswordDisabled => 'Oʻchiq — ilova parolsiz ochiladi';

  @override
  String get settingsChangePassword => 'Parolni oʻzgartirish';

  @override
  String get settingsChangePasswordSubtitle =>
      'Ilova qulflash parolini yangilash';

  @override
  String get settingsSetPanicKey => 'Favqulodda kalit oʻrnatish';

  @override
  String get settingsChangePanicKey => 'Favqulodda kalitni oʻzgartirish';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Favqulodda oʻchirish kalitini yangilash';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Barcha maʼlumotlarni bir zumda oʻchiradigan kalit';

  @override
  String get settingsRemovePanicKey => 'Favqulodda kalitni olib tashlash';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Favqulodda oʻz-oʻzini yoʻq qilishni oʻchirish';

  @override
  String get settingsRemovePanicKeyBody =>
      'Favqulodda oʻz-oʻzini yoʻq qilish oʻchiriladi. Istalgan vaqtda qayta yoqishingiz mumkin.';

  @override
  String get settingsDisableAppPassword => 'Ilova parolini oʻchirish';

  @override
  String get settingsEnterCurrentPassword =>
      'Tasdiqlash uchun joriy parolingizni kiriting';

  @override
  String get settingsCurrentPassword => 'Joriy parol';

  @override
  String get settingsIncorrectPassword => 'Notoʻgʻri parol';

  @override
  String get settingsPasswordUpdated => 'Parol yangilandi';

  @override
  String get settingsChangePasswordProceed =>
      'Davom etish uchun joriy parolingizni kiriting';

  @override
  String get settingsData => 'Maʼlumotlar';

  @override
  String get settingsBackupMessages => 'Xabarlarni zaxiralash';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Shifrlangan xabarlar tarixini faylga eksport qilish';

  @override
  String get settingsRestoreMessages => 'Xabarlarni tiklash';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Zaxira fayldan xabarlarni import qilish';

  @override
  String get settingsExportKeys => 'Kalitlarni eksport qilish';

  @override
  String get settingsExportKeysSubtitle =>
      'Identifikatsiya kalitlarini shifrlangan faylga saqlash';

  @override
  String get settingsImportKeys => 'Kalitlarni import qilish';

  @override
  String get settingsImportKeysSubtitle =>
      'Eksport qilingan fayldan identifikatsiya kalitlarini tiklash';

  @override
  String get settingsBackupPassword => 'Zaxira paroli';

  @override
  String get settingsPasswordCannotBeEmpty =>
      'Parol boʻsh boʻlishi mumkin emas';

  @override
  String get settingsPasswordMin4Chars =>
      'Parol kamida 4 belgidan iborat boʻlishi kerak';

  @override
  String get settingsCallsTurn => 'Qoʻngʻiroqlar va TURN';

  @override
  String get settingsLocalNetwork => 'Mahalliy tarmoq';

  @override
  String get settingsCensorshipResistance => 'Senzuraga qarshilik';

  @override
  String get settingsNetwork => 'Tarmoq';

  @override
  String get settingsProxyTunnels => 'Proksi va tunnellar';

  @override
  String get settingsTurnServers => 'TURN serverlar';

  @override
  String get settingsProviderTitle => 'Provayder';

  @override
  String get settingsLanFallback => 'LAN zaxira';

  @override
  String get settingsLanFallbackSubtitle =>
      'Internet mavjud boʻlmaganda mahalliy tarmoqda mavjudlik va xabarlarni uzatish. Ishonchsiz tarmoqlarda (ommaviy Wi-Fi) oʻchiring.';

  @override
  String get settingsBgDelivery => 'Fon rejimida yetkazish';

  @override
  String get settingsBgDeliverySubtitle =>
      'Ilova minimallashtirilganda xabarlarni qabul qilishda davom etish. Doimiy bildirishnoma koʻrsatiladi.';

  @override
  String get settingsYourInboxProvider => 'Kiruvchi provayder';

  @override
  String get settingsConnectionDetails => 'Ulanish tafsilotlari';

  @override
  String get settingsSaveAndConnect => 'Saqlash va ulanish';

  @override
  String get settingsSecondaryInboxes => 'Ikkilamchi pochta qutilari';

  @override
  String get settingsAddSecondaryInbox => 'Ikkilamchi pochta qutisi qoʻshish';

  @override
  String get settingsAdvanced => 'Kengaytirilgan';

  @override
  String get settingsDiscover => 'Topish';

  @override
  String get settingsAbout => 'Haqida';

  @override
  String get settingsPrivacyPolicy => 'Maxfiylik siyosati';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Pulse maʼlumotlaringizni qanday himoya qiladi';

  @override
  String get settingsCrashReporting => 'Nosozlik hisobotlari';

  @override
  String get settingsCrashReportingSubtitle =>
      'Pulse ni yaxshilash uchun anonim nosozlik hisobotlari yuborish. Hech qachon xabar mazmuni yoki kontaktlar yuborilmaydi.';

  @override
  String get settingsCrashReportingEnabled =>
      'Nosozlik hisobotlari yoniq — qoʻllash uchun ilovani qayta ishga tushiring';

  @override
  String get settingsCrashReportingDisabled =>
      'Nosozlik hisobotlari oʻchiq — qoʻllash uchun ilovani qayta ishga tushiring';

  @override
  String get settingsSensitiveOperation => 'Sezgir amal';

  @override
  String get settingsSensitiveOperationBody =>
      'Bu kalitlar sizning identifikatsiyangiz. Bu faylga ega boʻlgan har bir kishi sizning nomingizdan harakat qilishi mumkin. Xavfsiz saqlang va koʻchirganingizdan keyin oʻchirib tashlang.';

  @override
  String get settingsIUnderstandContinue => 'Tushundim, davom etish';

  @override
  String get settingsReplaceIdentity => 'Identifikatsiya almashtirilsinmi?';

  @override
  String get settingsReplaceIdentityBody =>
      'Bu joriy identifikatsiya kalitlaringizni qayta yozadi. Mavjud Signal seanslar bekor boʻladi va kontaktlar shifrlashni qayta oʻrnatishlari kerak. Ilova qayta ishga tushirilishi kerak.';

  @override
  String get settingsReplaceKeys => 'Kalitlarni almashtirish';

  @override
  String get settingsKeysImported => 'Kalitlar import qilindi';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count ta kalit muvaffaqiyatli import qilindi. Yangi identifikatsiya bilan qayta ishga tushirish uchun ilovani qayta yoqing.';
  }

  @override
  String get settingsRestartNow => 'Hozir qayta ishga tushirish';

  @override
  String get settingsLater => 'Keyinroq';

  @override
  String get profileGroupLabel => 'Guruh';

  @override
  String get profileAddButton => 'Qoʻshish';

  @override
  String get profileKickButton => 'Chiqarish';

  @override
  String get dataSectionTitle => 'Maʼlumotlar';

  @override
  String get dataBackupMessages => 'Xabarlarni zaxiralash';

  @override
  String get dataBackupPasswordSubtitle =>
      'Xabarlar zaxirangizni shifrlash uchun parol tanlang.';

  @override
  String get dataBackupConfirmLabel => 'Zaxira yaratish';

  @override
  String get dataCreatingBackup => 'Zaxira yaratilmoqda';

  @override
  String get dataBackupPreparing => 'Tayyorlanmoqda...';

  @override
  String dataBackupExporting(int done, int total) {
    return '$total dan $done-xabar eksport qilinmoqda...';
  }

  @override
  String get dataBackupSavingFile => 'Fayl saqlanmoqda...';

  @override
  String get dataSaveMessageBackupDialog => 'Xabarlar zaxirasini saqlash';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Zaxira saqlandi ($count xabar)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Zaxiralash muvaffaqiyatsiz — maʼlumot eksport qilinmadi';

  @override
  String dataBackupFailedError(String error) {
    return 'Zaxiralash muvaffaqiyatsiz: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Xabarlar zaxirasini tanlash';

  @override
  String get dataInvalidBackupFile => 'Notoʻgʻri zaxira fayl (juda kichik)';

  @override
  String get dataNotValidBackupFile => 'Haqiqiy Pulse zaxira fayli emas';

  @override
  String get dataRestoreMessages => 'Xabarlarni tiklash';

  @override
  String get dataRestorePasswordSubtitle =>
      'Bu zaxirani yaratish uchun ishlatilgan parolni kiriting.';

  @override
  String get dataRestoreConfirmLabel => 'Tiklash';

  @override
  String get dataRestoringMessages => 'Xabarlar tiklanmoqda';

  @override
  String get dataRestoreDecrypting => 'Shifr ochilmoqda...';

  @override
  String dataRestoreImporting(int done, int total) {
    return '$total dan $done-xabar import qilinmoqda...';
  }

  @override
  String get dataRestoreFailed =>
      'Tiklash muvaffaqiyatsiz — notoʻgʻri parol yoki buzilgan fayl';

  @override
  String dataRestoreSuccess(int count) {
    return '$count ta yangi xabar tiklandi';
  }

  @override
  String get dataRestoreNothingNew =>
      'Import qilish uchun yangi xabarlar yoʻq (hammasi allaqachon mavjud)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Tiklash muvaffaqiyatsiz: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Kalit eksportini tanlash';

  @override
  String get dataNotValidKeyFile => 'Haqiqiy Pulse kalit eksport fayli emas';

  @override
  String get dataExportKeys => 'Kalitlarni eksport qilish';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Kalit eksportingizni shifrlash uchun parol tanlang.';

  @override
  String get dataExportKeysConfirmLabel => 'Eksport';

  @override
  String get dataExportingKeys => 'Kalitlar eksport qilinmoqda';

  @override
  String get dataExportingKeysStatus =>
      'Identifikatsiya kalitlari shifrlanmoqda...';

  @override
  String get dataSaveKeyExportDialog => 'Kalit eksportini saqlash';

  @override
  String dataKeysExportedTo(String path) {
    return 'Kalitlar eksport qilindi:\n$path';
  }

  @override
  String get dataExportFailed => 'Eksport muvaffaqiyatsiz — kalitlar topilmadi';

  @override
  String dataExportFailedError(String error) {
    return 'Eksport muvaffaqiyatsiz: $error';
  }

  @override
  String get dataImportKeys => 'Kalitlarni import qilish';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Bu kalit eksportini shifrlash uchun ishlatilgan parolni kiriting.';

  @override
  String get dataImportKeysConfirmLabel => 'Import';

  @override
  String get dataImportingKeys => 'Kalitlar import qilinmoqda';

  @override
  String get dataImportingKeysStatus =>
      'Identifikatsiya kalitlari shifr ochilmoqda...';

  @override
  String get dataImportFailed =>
      'Import muvaffaqiyatsiz — notoʻgʻri parol yoki buzilgan fayl';

  @override
  String dataImportFailedError(String error) {
    return 'Import muvaffaqiyatsiz: $error';
  }

  @override
  String get securitySectionTitle => 'Xavfsizlik';

  @override
  String get securityIncorrectPassword => 'Notoʻgʻri parol';

  @override
  String get securityPasswordUpdated => 'Parol yangilandi';

  @override
  String get appearanceSectionTitle => 'Koʻrinish';

  @override
  String appearanceExportFailed(String error) {
    return 'Eksport muvaffaqiyatsiz: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return '$path ga saqlandi';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Saqlash muvaffaqiyatsiz: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Import muvaffaqiyatsiz: $error';
  }

  @override
  String get aboutSectionTitle => 'Haqida';

  @override
  String get providerPublicKey => 'Ochiq kalit';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Tiklash parolingizdan avtomatik sozlangan. Relay avtomatik topildi.';

  @override
  String get providerKeyStoredLocally =>
      'Kalitingiz mahalliy xavfsiz xotirada saqlanadi — hech qachon serverga yuborilmaydi.';

  @override
  String get providerSessionInfo =>
      'Session Network — piyoz-yo\'naltirish E2EE. Session ID\'ingiz avtomatik ravishda yaratiladi va xavfsiz saqlanadi. Tugunlar o\'rnatilgan seed tugunlardan avtomatik ravishda kashf etiladi.';

  @override
  String get providerAdvanced => 'Kengaytirilgan';

  @override
  String get providerSaveAndConnect => 'Saqlash va ulanish';

  @override
  String get providerAddSecondaryInbox => 'Ikkilamchi pochta qutisi qoʻshish';

  @override
  String get providerSecondaryInboxes => 'Ikkilamchi pochta qutilari';

  @override
  String get providerYourInboxProvider => 'Kiruvchi provayder';

  @override
  String get providerConnectionDetails => 'Ulanish tafsilotlari';

  @override
  String get addContactTitle => 'Kontakt qoʻshish';

  @override
  String get addContactInviteLinkLabel => 'Taklif havolasi yoki manzil';

  @override
  String get addContactTapToPaste =>
      'Taklif havolasini joylashtirish uchun bosing';

  @override
  String get addContactPasteTooltip => 'Vaqtinchalik xotiradan joylashtirish';

  @override
  String get addContactAddressDetected => 'Kontakt manzili aniqlandi';

  @override
  String addContactRoutesDetected(int count) {
    return '$count ta marshrut aniqlandi — SmartRouter eng tezini tanlaydi';
  }

  @override
  String get addContactFetchingProfile => 'Profil olinmoqda…';

  @override
  String addContactProfileFound(String name) {
    return 'Topildi: $name';
  }

  @override
  String get addContactNoProfileFound => 'Profil topilmadi';

  @override
  String get addContactDisplayNameLabel => 'Koʻrsatiladigan ism';

  @override
  String get addContactDisplayNameHint => 'Ularni nima deb atamoqchisiz?';

  @override
  String get addContactAddManually => 'Manzilni qoʻlda kiritish';

  @override
  String get addContactButton => 'Kontakt qoʻshish';

  @override
  String get networkDiagnosticsTitle => 'Tarmoq diagnostikasi';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr Relaylar';

  @override
  String get networkDiagnosticsDirect => 'Toʻgʻridan-toʻgʻri';

  @override
  String get networkDiagnosticsTorOnly => 'Faqat Tor';

  @override
  String get networkDiagnosticsBest => 'Eng yaxshi';

  @override
  String get networkDiagnosticsNone => 'yoʻq';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Holat';

  @override
  String get networkDiagnosticsConnected => 'Ulangan';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Ulanmoqda $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Oʻchiq';

  @override
  String get networkDiagnosticsTransport => 'Transport';

  @override
  String get networkDiagnosticsInfrastructure => 'Infratuzilma';

  @override
  String get networkDiagnosticsSessionNodes => 'Session tugunlari';

  @override
  String get networkDiagnosticsTurnServers => 'TURN serverlar';

  @override
  String get networkDiagnosticsLastProbe => 'Oxirgi tekshiruv';

  @override
  String get networkDiagnosticsRunning => 'Ishlayapti...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Diagnostikani boshlash';

  @override
  String get networkDiagnosticsForceReprobe =>
      'Toʻliq qayta tekshirishni majburlash';

  @override
  String get networkDiagnosticsJustNow => 'hozirgina';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes daqiqa oldin';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours soat oldin';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days kun oldin';
  }

  @override
  String get homeNoEch => 'ECH yoʻq';

  @override
  String get homeNoEchTooltip =>
      'uTLS proksi mavjud emas — ECH oʻchirilgan.\nTLS barmoq izi DPI uchun koʻrinadi.';

  @override
  String get settingsTitle => 'Sozlamalar';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Saqlandi va $provider ga ulandi';
  }

  @override
  String get settingsTorFailedToStart => 'Ichki Tor ishga tushmadi';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon ishga tushmadi';

  @override
  String get verifyTitle => 'Xavfsizlik raqamini tasdiqlash';

  @override
  String get verifyIdentityVerified => 'Identifikatsiya tasdiqlandi';

  @override
  String get verifyNotYetVerified => 'Hali tasdiqlanmagan';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Siz $name ning xavfsizlik raqamini tasdiqladingiz.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Bu raqamlarni $name bilan shaxsan yoki ishonchli kanal orqali solishtiring.';
  }

  @override
  String get verifyExplanation =>
      'Har bir suhbatning noyob xavfsizlik raqami bor. Agar ikkalangiz ham qurilmalaringizda bir xil raqamlarni koʻrsangiz, ulanishingiz oxirigacha tasdiqlangan.';

  @override
  String verifyContactKey(String name) {
    return '$name kaliti';
  }

  @override
  String get verifyYourKey => 'Sizning kalitingiz';

  @override
  String get verifyRemoveVerification => 'Tasdiqlashni olib tashlash';

  @override
  String get verifyMarkAsVerified => 'Tasdiqlangan deb belgilash';

  @override
  String verifyAfterReinstall(String name) {
    return 'Agar $name ilovani qayta oʻrnatsa, xavfsizlik raqami oʻzgaradi va tasdiqlash avtomatik olib tashlanadi.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Faqat $name bilan ovozli qoʻngʻiroq yoki shaxsan raqamlarni solishtirgandan keyin tasdiqlangan deb belgilang.';
  }

  @override
  String get verifyNoSession =>
      'Shifrlash seansi hali oʻrnatilmagan. Xavfsizlik raqamlarini yaratish uchun avval xabar yuboring.';

  @override
  String get verifyNoKeyAvailable => 'Kalit mavjud emas';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label barmoq izi nusxalandi';
  }

  @override
  String get providerDatabaseUrlLabel => 'Maʼlumotlar bazasi URL';

  @override
  String get providerOptionalHint => 'Ixtiyoriy';

  @override
  String get providerWebApiKeyLabel => 'Web API kaliti';

  @override
  String get providerOptionalForPublicDb =>
      'Ommaviy maʼlumotlar bazasi uchun ixtiyoriy';

  @override
  String get providerRelayUrlLabel => 'Relay URL';

  @override
  String get providerPrivateKeyLabel => 'Maxfiy kalit';

  @override
  String get providerPrivateKeyNsecLabel => 'Maxfiy kalit (nsec)';

  @override
  String get providerStorageNodeLabel => 'Saqlash tuguni URL (ixtiyoriy)';

  @override
  String get providerStorageNodeHint =>
      'Ichki seed tugunlar uchun boʻsh qoldiring';

  @override
  String get transferInvalidCodeFormat =>
      'Nomaʼlum kod formati — LAN: yoki NOS: bilan boshlanishi kerak';

  @override
  String get profileCardFingerprintCopied => 'Barmoq izi nusxalandi';

  @override
  String get profileCardAboutHint => 'Maxfiylik birinchi 🔒';

  @override
  String get profileCardSaveButton => 'Profilni saqlash';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Shifrlangan xabarlar, kontaktlar va avatarlarni faylga eksport qilish';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Audio';

  @override
  String bubbleDeliveredTo(String names) {
    return '$names ga yetkazildi';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return '$count ga yetkazildi';
  }

  @override
  String get groupStatusDialogTitle => 'Xabar maʼlumoti';

  @override
  String get groupStatusRead => 'Oʻqildi';

  @override
  String get groupStatusDelivered => 'Yetkazildi';

  @override
  String get groupStatusPending => 'Kutilmoqda';

  @override
  String get groupStatusNoData => 'Yetkazish maʼlumoti hali yoʻq';

  @override
  String get profileTransferAdmin => 'Admin qilish';

  @override
  String profileTransferAdminConfirm(String name) {
    return '$name yangi admin qilinsinmi?';
  }

  @override
  String get profileTransferAdminBody =>
      'Admin huquqlaringizni yoʻqotasiz. Bu qaytarilmas.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name endi admin';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Maxfiylik siyosati';

  @override
  String get privacyOverviewHeading => 'Umumiy koʻrinish';

  @override
  String get privacyOverviewBody =>
      'Pulse serversiz, oxirigacha shifrlangan messenjer. Maxfiyligingiz shunchaki funksiya emas — bu arxitektura. Pulse serverlari yoʻq. Hech qayerda hisob saqlanmaydi. Hech qanday maʼlumot dasturchilar tomonidan yigʻilmaydi, uzatilmaydi yoki saqlanmaydi.';

  @override
  String get privacyDataCollectionHeading => 'Maʼlumot yigʻish';

  @override
  String get privacyDataCollectionBody =>
      'Pulse hech qanday shaxsiy maʼlumot yigʻmaydi. Xususan:\n\n- Elektron pochta, telefon raqami yoki haqiqiy ism talab qilinmaydi\n- Analitika, kuzatish yoki telemetriya yoʻq\n- Reklama identifikatorlari yoʻq\n- Kontaktlar roʻyxatiga kirish yoʻq\n- Bulutli zaxiralar yoʻq (xabarlar faqat qurilmangizda mavjud)\n- Hech qanday metadata Pulse serveriga yuborilmaydi (ular mavjud emas)';

  @override
  String get privacyEncryptionHeading => 'Shifrlash';

  @override
  String get privacyEncryptionBody =>
      'Barcha xabarlar Signal Protocol (X3DH kalit kelishuvi bilan Double Ratchet) yordamida shifrlanadi. Shifrlash kalitlari faqat qurilmangizda yaratiladi va saqlanadi. Hech kim — shu jumladan dasturchilar — xabarlaringizni oʻqiy olmaydi.';

  @override
  String get privacyNetworkHeading => 'Tarmoq arxitekturasi';

  @override
  String get privacyNetworkBody =>
      'Pulse federatsiyalangan transport adapterlardan foydalanadi (Nostr relaylar, Session/Oxen xizmat tugunlari, Firebase Realtime Database, LAN). Bu transportlar faqat shifrlangan matnni uzatadi. Relay operatorlari sizning IP manzilingiz va trafik hajmini koʻrishi mumkin, lekin xabar mazmunini shifrini ocha olmaydi.\n\nTor yoqilganda, IP manzilingiz relay operatorlaridan ham yashirinadi.';

  @override
  String get privacyStunHeading => 'STUN/TURN serverlar';

  @override
  String get privacyStunBody =>
      'Ovozli va video qoʻngʻiroqlar DTLS-SRTP shifrlash bilan WebRTC dan foydalanadi. STUN serverlar (peer-to-peer ulanishlar uchun ommaviy IP ni aniqlash uchun) va TURN serverlar (toʻgʻridan-toʻgʻri ulanish muvaffaqiyatsiz boʻlganda mediани uzatish uchun) sizning IP manzilingiz va qoʻngʻiroq davomiyligini koʻrishi mumkin, lekin qoʻngʻiroq mazmunini shifrini ocha olmaydi.\n\nMaksimal maxfiylik uchun Sozlamalarda oʻz TURN serveringizni sozlashingiz mumkin.';

  @override
  String get privacyCrashHeading => 'Nosozlik hisobotlari';

  @override
  String get privacyCrashBody =>
      'Sentry nosozlik hisobotlari yoqilgan boʻlsa (build-vaqt SENTRY_DSN orqali), anonim nosozlik hisobotlari yuborilishi mumkin. Ular xabar mazmuni, kontakt maʼlumoti yoki shaxsiy maʼlumotlarni oʻz ichiga olmaydi. Nosozlik hisobotlari DSN ni olib tashlash orqali build vaqtida oʻchirilishi mumkin.';

  @override
  String get privacyPasswordHeading => 'Parol va kalitlar';

  @override
  String get privacyPasswordBody =>
      'Tiklash parolingiz Argon2id (xotira-qattiq KDF) orqali kriptografik kalitlarni chiqarish uchun ishlatiladi. Parol hech qayerga uzatilmaydi. Parolingizni yoʻqotsangiz, hisobingizni tiklash mumkin emas — uni tiklash uchun server yoʻq.';

  @override
  String get privacyFontsHeading => 'Shriftlar';

  @override
  String get privacyFontsBody =>
      'Pulse barcha shriftlarni mahalliy joylashtiradi. Google Fonts yoki boshqa tashqi shrift xizmatlariga soʻrovlar yuborilmaydi.';

  @override
  String get privacyThirdPartyHeading => 'Uchinchi tomon xizmatlari';

  @override
  String get privacyThirdPartyBody =>
      'Pulse hech qanday reklama tarmoqlari, analitika provayderlari, ijtimoiy tarmoq platformalari yoki maʼlumot brokerlari bilan integratsiya qilmaydi. Yagona tarmoq ulanishlari siz sozlagan transport relaylarga.';

  @override
  String get privacyOpenSourceHeading => 'Ochiq manba';

  @override
  String get privacyOpenSourceBody =>
      'Pulse ochiq manba dasturiy taʼminot. Ushbu maxfiylik daʼvolarini tasdiqlash uchun toʻliq manba kodini tekshirishingiz mumkin.';

  @override
  String get privacyContactHeading => 'Aloqa';

  @override
  String get privacyContactBody =>
      'Maxfiylikka oid savollar uchun loyiha omborida issue oching.';

  @override
  String get privacyLastUpdated => 'Oxirgi yangilanish: 2026-yil mart';

  @override
  String imageSaveFailed(Object error) {
    return 'Saqlash muvaffaqiyatsiz: $error';
  }

  @override
  String get themeEngineTitle => 'Mavzu mexanizmi';

  @override
  String get torBuiltInTitle => 'Ichki Tor';

  @override
  String get torConnectedSubtitle =>
      'Ulangan — Nostr 127.0.0.1:9250 orqali yoʻnaltirilgan';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Ulanmoqda… $pct%';
  }

  @override
  String get torNotRunning =>
      'Ishlamayapti — qayta ishga tushirish uchun bosing';

  @override
  String get torDescription =>
      'Nostr ni Tor orqali yoʻnaltiradi (senzuralangan tarmoqlar uchun Snowflake)';

  @override
  String get torNetworkDiagnostics => 'Tarmoq diagnostikasi';

  @override
  String get torTransportLabel => 'Transport: ';

  @override
  String get torPtAuto => 'Avtomatik';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Oddiy';

  @override
  String get torTimeoutLabel => 'Vaqt chegarasi: ';

  @override
  String get torInfoDescription =>
      'Yoqilganda, Nostr WebSocket ulanishlari Tor (SOCKS5) orqali yoʻnaltiriladi. Tor Browser 127.0.0.1:9150 da tinglaydi. Mustaqil tor daemon 9050 portdan foydalanadi. Firebase ulanishlarga taʼsir qilmaydi.';

  @override
  String get torRouteNostrTitle => 'Nostr ni Tor orqali yoʻnaltirish';

  @override
  String get torManagedByBuiltin => 'Ichki Tor tomonidan boshqariladi';

  @override
  String get torActiveRouting =>
      'Faol — Nostr trafik Tor orqali yoʻnaltirilgan';

  @override
  String get torDisabled => 'Oʻchirilgan';

  @override
  String get torProxySocks5 => 'Tor proksi (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Proksi host';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser: port 9150  •  tor daemon: port 9050';

  @override
  String get i2pProxySocks5 => 'I2P proksi (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P sukut boʻyicha 4447 portda SOCKS5 dan foydalanadi. Har qanday transportdagi foydalanuvchilar bilan aloqa qilish uchun I2P outproxy orqali Nostr relay ga ulaning (masalan relay.damus.i2p). Ikkalasi yoqilganda Tor ustunlik oladi.';

  @override
  String get i2pRouteNostrTitle => 'Nostr ni I2P orqali yoʻnaltirish';

  @override
  String get i2pActiveRouting =>
      'Faol — Nostr trafik I2P orqali yoʻnaltirilgan';

  @override
  String get i2pDisabled => 'Oʻchirilgan';

  @override
  String get i2pProxyHostLabel => 'Proksi host';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'I2P Router sukut SOCKS5 porti: 4447';

  @override
  String get customProxySocks5 => 'Maxsus proksi (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Maxsus proksi trafikni V2Ray/Xray/Shadowsocks orqali yoʻnaltiradi. CF Worker Cloudflare CDN da shaxsiy relay proksi vazifasini bajaradi — GFW *.workers.dev ni koʻradi, haqiqiy relay ni emas.';

  @override
  String get customSocks5ProxyTitle => 'Maxsus SOCKS5 proksi';

  @override
  String get customProxyActive => 'Faol — trafik SOCKS5 orqali yoʻnaltirilgan';

  @override
  String get customProxyDisabled => 'Oʻchirilgan';

  @override
  String get customProxyHostLabel => 'Proksi host';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker domeni (ixtiyoriy)';

  @override
  String get customWorkerHelpTitle =>
      'CF Worker relay ni qanday joylashtirish (bepul)';

  @override
  String get customWorkerScriptCopied => 'Skript nusxalandi!';

  @override
  String get customWorkerStep1 =>
      '1. dash.cloudflare.com → Workers & Pages ga oʻting\n2. Create Worker → bu skriptni joylashtiring:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → domenni nusxalang (masalan my-relay.user.workers.dev)\n4. Domenni yuqoriga joylashtiring → Saqlang\n\nIlova avtomatik ulanadi: wss://domain/?r=relay_url\nGFW koʻradi: *.workers.dev (CF CDN) ga ulanish';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Ulangan — SOCKS5 127.0.0.1:$port da';
  }

  @override
  String get psiphonConnecting => 'Ulanmoqda…';

  @override
  String get psiphonNotRunning =>
      'Ishlamayapti — qayta ishga tushirish uchun bosing';

  @override
  String get psiphonDescription =>
      'Tez tunnel (~3s ishga tushirish, 2000+ aylanma VPS)';

  @override
  String get turnCommunityServers => 'Jamiyat TURN serverlari';

  @override
  String get turnCustomServer => 'Maxsus TURN server (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN serverlar faqat allaqachon shifrlangan oqimlarni (DTLS-SRTP) uzatadi. Relay operatori sizning IP va trafik hajmini koʻradi, lekin qoʻngʻiroqlarni shifrini ocha olmaydi. TURN faqat toʻgʻridan-toʻgʻri P2P muvaffaqiyatsiz boʻlganda ishlatiladi (ulanishlarning ~15–20%).';

  @override
  String get turnFreeLabel => 'BEPUL';

  @override
  String get turnServerUrlLabel => 'TURN server URL';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 yoki turns:...';

  @override
  String get turnUsernameLabel => 'Foydalanuvchi nomi';

  @override
  String get turnPasswordLabel => 'Parol';

  @override
  String get turnOptionalHint => 'Ixtiyoriy';

  @override
  String get turnCustomInfo =>
      'Maksimal nazorat uchun istalgan 5\$/oy VPS da coturn oʻrnating. Hisob maʼlumotlari mahalliy saqlanadi.';

  @override
  String get themePickerAppearance => 'Koʻrinish';

  @override
  String get themePickerAccentColor => 'Urg\'u rangi';

  @override
  String get themeModeLight => 'Yorug\'';

  @override
  String get themeModeDark => 'Qorongʻu';

  @override
  String get themeModeSystem => 'Tizim';

  @override
  String get themeDynamicPresets => 'Tayyorlamalar';

  @override
  String get themeDynamicPrimaryColor => 'Asosiy rang';

  @override
  String get themeDynamicBorderRadius => 'Chegara radiusi';

  @override
  String get themeDynamicFont => 'Shrift';

  @override
  String get themeDynamicAppearance => 'Koʻrinish';

  @override
  String get themeDynamicUiStyle => 'UI uslubi';

  @override
  String get themeDynamicUiStyleDescription =>
      'Dialoglar, tugmalar va indikatorlarning koʻrinishini boshqaradi.';

  @override
  String get themeDynamicSharp => 'Keskin';

  @override
  String get themeDynamicRound => 'Yumaloq';

  @override
  String get themeDynamicModeDark => 'Qorongʻu';

  @override
  String get themeDynamicModeLight => 'Yorug\'';

  @override
  String get themeDynamicModeAuto => 'Avtomatik';

  @override
  String get themeDynamicPlatformAuto => 'Avtomatik';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'Notoʻgʻri Firebase URL. Kutilmoqda: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Notoʻgʻri relay URL. Kutilmoqda: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Notoʻgʻri Pulse server URL. Kutilmoqda: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'Server URL';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'Taklif kodi';

  @override
  String get providerPulseInviteHint => 'Taklif kodi (agar kerak boʻlsa)';

  @override
  String get providerPulseInfo =>
      'Oʻz-oʻzini xosting relay. Kalitlar tiklash parolingizdan chiqariladi.';

  @override
  String get providerScreenTitle => 'Pochta qutilari';

  @override
  String get providerSecondaryInboxesHeader => 'IKKILAMCHI POCHTA QUTILARI';

  @override
  String get providerSecondaryInboxesInfo =>
      'Ikkilamchi pochta qutilari zaxira uchun xabarlarni bir vaqtda qabul qiladi.';

  @override
  String get providerRemoveTooltip => 'Olib tashlash';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... yoki hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... yoki hex maxfiy kalit';

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
  String get emojiNoRecent => 'Soʻnggi emojilar yoʻq';

  @override
  String get emojiSearchHint => 'Emoji qidirish...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Yozishma uchun bosing';

  @override
  String get imageViewerSaveToDownloads => 'Yuklanmalarga saqlash';

  @override
  String imageViewerSavedTo(String path) {
    return '$path ga saqlandi';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Til';

  @override
  String get settingsLanguageSubtitle => 'Ilova koʻrsatish tili';

  @override
  String get settingsLanguageSystem => 'Tizim sukut qiymati';

  @override
  String get onboardingLanguageTitle => 'Tilni tanlang';

  @override
  String get onboardingLanguageSubtitle =>
      'Buni keyinroq Sozlamalarda oʻzgartirishingiz mumkin';

  @override
  String get videoNoteRecord => 'Video xabar yozish';

  @override
  String get videoNoteTapToRecord => 'Yozish uchun bosing';

  @override
  String get videoNoteTapToStop => 'To\'xtatish uchun bosing';

  @override
  String get videoNoteCameraPermission => 'Kameraga ruxsat rad etildi';

  @override
  String get videoNoteMaxDuration => 'Maksimal 30 soniya';

  @override
  String get videoNoteNotSupported =>
      'Video eslatmalar ushbu platformada qo\'llab-quvvatlanmaydi';

  @override
  String get navChats => 'Chatlar';

  @override
  String get navUpdates => 'Yangilanishlar';

  @override
  String get navCalls => 'Qo\'ng\'iroqlar';

  @override
  String get filterAll => 'Barchasi';

  @override
  String get filterUnread => 'O\'qilmagan';

  @override
  String get filterGroups => 'Guruhlar';

  @override
  String get callsNoRecent => 'So\'nggi qo\'ng\'iroqlar yo\'q';

  @override
  String get callsEmptySubtitle =>
      'Qo\'ng\'iroqlar tarixingiz bu yerda ko\'rinadi';

  @override
  String get appBarEncrypted => 'uchdan-uchga shifrlangan';

  @override
  String get newStatus => 'Yangi holat';

  @override
  String get newCall => 'Yangi qo\'ng\'iroq';
}
