// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class AppLocalizationsAz extends AppLocalizations {
  AppLocalizationsAz([String locale = 'az']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Mesajlarda axtar...';

  @override
  String get search => 'Axtar';

  @override
  String get clearSearch => 'Axtarışı təmizlə';

  @override
  String get closeSearch => 'Axtarışı bağla';

  @override
  String get moreOptions => 'Daha çox seçim';

  @override
  String get back => 'Geri';

  @override
  String get cancel => 'Ləğv et';

  @override
  String get close => 'Bağla';

  @override
  String get confirm => 'Təsdiqlə';

  @override
  String get remove => 'Sil';

  @override
  String get save => 'Saxla';

  @override
  String get add => 'Əlavə et';

  @override
  String get copy => 'Kopyala';

  @override
  String get skip => 'Keç';

  @override
  String get done => 'Hazır';

  @override
  String get apply => 'Tətbiq et';

  @override
  String get export => 'İxrac et';

  @override
  String get import => 'İdxal et';

  @override
  String get homeNewGroup => 'Yeni qrup';

  @override
  String get homeSettings => 'Parametrlər';

  @override
  String get homeSearching => 'Mesajlar axtarılır...';

  @override
  String get homeNoResults => 'Heç bir nəticə tapılmadı';

  @override
  String get homeNoChatHistory => 'Hələ söhbət tarixçəsi yoxdur';

  @override
  String homeTransportSwitched(String address) {
    return 'Nəqliyyat dəyişdirildi → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name zəng edir...';
  }

  @override
  String get homeAccept => 'Qəbul et';

  @override
  String get homeDecline => 'Rədd et';

  @override
  String get homeLoadEarlier => 'Əvvəlki mesajları yüklə';

  @override
  String get homeChats => 'Söhbətlər';

  @override
  String get homeSelectConversation => 'Söhbət seçin';

  @override
  String get homeNoChatsYet => 'Hələ söhbət yoxdur';

  @override
  String get homeAddContactToStart =>
      'Söhbətə başlamaq üçün kontakt əlavə edin';

  @override
  String get homeNewChat => 'Yeni söhbət';

  @override
  String get homeNewChatTooltip => 'Yeni söhbət';

  @override
  String get homeIncomingCallTitle => 'Gələn zəng';

  @override
  String get homeIncomingGroupCallTitle => 'Gələn qrup zəngi';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — gələn qrup zəngi';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return '\"$query\" ilə uyğun söhbət yoxdur';
  }

  @override
  String get homeSectionChats => 'Söhbətlər';

  @override
  String get homeSectionMessages => 'Mesajlar';

  @override
  String get homeDbEncryptionUnavailable =>
      'Verilənlər bazası şifrələməsi əlçatan deyil — tam qoruma üçün SQLCipher quraşdırın';

  @override
  String get chatFileTooLargeGroup =>
      'Qrup söhbətlərində 512 KB-dan böyük fayllar dəstəklənmir';

  @override
  String get chatLargeFile => 'Böyük fayl';

  @override
  String get chatCancel => 'Ləğv et';

  @override
  String get chatSend => 'Göndər';

  @override
  String get chatFileTooLarge => 'Fayl çox böyükdür — maksimum ölçü 100 MB-dır';

  @override
  String get chatMicDenied => 'Mikrofon icazəsi rədd edildi';

  @override
  String get chatVoiceFailed =>
      'Səs mesajı saxlanıla bilmədi — mövcud yaddaşı yoxlayın';

  @override
  String get chatScheduleFuture => 'Planlaşdırılmış vaxt gələcəkdə olmalıdır';

  @override
  String get chatToday => 'Bu gün';

  @override
  String get chatYesterday => 'Dünən';

  @override
  String get chatEdited => 'redaktə edilib';

  @override
  String get chatYou => 'Siz';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Bu fayl $size MB-dır. Böyük faylların göndərilməsi bəzi şəbəkələrdə yavaş ola bilər. Davam edilsin?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return '$name adlı kontaktın təhlükəsizlik açarı dəyişdi. Yoxlamaq üçün toxunun.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return '$name üçün mesaj şifrələnə bilmədi — mesaj göndərilmədi.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return '$name üçün təhlükəsizlik nömrəsi dəyişdi. Yoxlamaq üçün toxunun.';
  }

  @override
  String get chatNoMessagesFound => 'Heç bir mesaj tapılmadı';

  @override
  String get chatMessagesE2ee => 'Mesajlar uçdan uca şifrələnib';

  @override
  String get chatSayHello => 'Salam deyin';

  @override
  String get appBarOnline => 'onlayn';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'yazır';

  @override
  String get appBarSearchMessages => 'Mesajlarda axtar...';

  @override
  String get appBarMute => 'Səssiz et';

  @override
  String get appBarUnmute => 'Səsi aç';

  @override
  String get appBarMedia => 'Media';

  @override
  String get appBarDisappearing => 'Yox olan mesajlar';

  @override
  String get appBarDisappearingOn => 'Yox olan: aktiv';

  @override
  String get appBarGroupSettings => 'Qrup parametrləri';

  @override
  String get appBarSearchTooltip => 'Mesajlarda axtar';

  @override
  String get appBarVoiceCall => 'Səsli zəng';

  @override
  String get appBarVideoCall => 'Video zəng';

  @override
  String get inputMessage => 'Mesaj...';

  @override
  String get inputAttachFile => 'Fayl əlavə et';

  @override
  String get inputSendMessage => 'Mesaj göndər';

  @override
  String get inputRecordVoice => 'Səs mesajı yaz';

  @override
  String get inputSendVoice => 'Səs mesajı göndər';

  @override
  String get inputCancelReply => 'Cavabı ləğv et';

  @override
  String get inputCancelEdit => 'Redaktəni ləğv et';

  @override
  String get inputCancelRecording => 'Yazmanı ləğv et';

  @override
  String get inputRecording => 'Yazılır…';

  @override
  String get inputEditingMessage => 'Mesaj redaktə olunur';

  @override
  String get inputPhoto => 'Foto';

  @override
  String get inputVoiceMessage => 'Səs mesajı';

  @override
  String get inputFile => 'Fayl';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count planlaşdırılmış mesaj$_temp0';
  }

  @override
  String get callInitializing => 'Zəng başladılır…';

  @override
  String get callConnecting => 'Qoşulur…';

  @override
  String get callConnectingRelay => 'Qoşulur (relay)…';

  @override
  String get callSwitchingRelay => 'Relay rejiminə keçilir…';

  @override
  String get callConnectionFailed => 'Əlaqə uğursuz oldu';

  @override
  String get callReconnecting => 'Yenidən qoşulur…';

  @override
  String get callEnded => 'Zəng bitdi';

  @override
  String get callLive => 'Canlı';

  @override
  String get callEnd => 'Son';

  @override
  String get callEndCall => 'Zəngi bitir';

  @override
  String get callMute => 'Səssiz et';

  @override
  String get callUnmute => 'Səsi aç';

  @override
  String get callSpeaker => 'Dinamik';

  @override
  String get callCameraOn => 'Kamera açıq';

  @override
  String get callCameraOff => 'Kamera bağlı';

  @override
  String get callShareScreen => 'Ekranı paylaş';

  @override
  String get callStopShare => 'Paylaşımı dayandır';

  @override
  String callTorBackup(String duration) {
    return 'Tor ehtiyat · $duration';
  }

  @override
  String get callTorBackupBanner => 'Tor ehtiyat aktiv — əsas yol əlçatmazdır';

  @override
  String get callDirectFailed =>
      'Birbaşa əlaqə uğursuz oldu — relay rejiminə keçilir…';

  @override
  String get callTurnUnreachable =>
      'TURN serverləri əlçatmazdır. Parametrlər → Ətraflı bölməsində fərdi TURN əlavə edin.';

  @override
  String get callRelayMode => 'Relay rejimi aktiv (məhdud şəbəkə)';

  @override
  String get callStarting => 'Zəng başladılır…';

  @override
  String get callConnectingToGroup => 'Qrupa qoşulur…';

  @override
  String get callGroupOpenedInBrowser => 'Qrup zəngi brauzerdə açıldı';

  @override
  String get callCouldNotOpenBrowser => 'Brauzer açıla bilmədi';

  @override
  String get callInviteLinkSent =>
      'Dəvət linki bütün qrup üzvlərinə göndərildi.';

  @override
  String get callOpenLinkManually =>
      'Yuxarıdakı linki əl ilə açın və ya yenidən cəhd etmək üçün toxunun.';

  @override
  String get callJitsiNotE2ee => 'Jitsi zəngləri uçdan uca şifrələnmir';

  @override
  String get callRetryOpenBrowser => 'Brauzeri yenidən aç';

  @override
  String get callClose => 'Bağla';

  @override
  String get callCamOn => 'Kamera açıq';

  @override
  String get callCamOff => 'Kamera bağlı';

  @override
  String get noConnection => 'Əlaqə yoxdur — mesajlar növbəyə alınacaq';

  @override
  String get connected => 'Qoşuldu';

  @override
  String get connecting => 'Qoşulur…';

  @override
  String get disconnected => 'Əlaqə kəsildi';

  @override
  String get offlineBanner =>
      'Əlaqə yoxdur — mesajlar yenidən onlayn olduqda göndəriləcək';

  @override
  String get lanModeBanner =>
      'LAN rejimi — İnternet yoxdur · Yalnız yerli şəbəkə';

  @override
  String get probeCheckingNetwork => 'Şəbəkə bağlantısı yoxlanılır…';

  @override
  String get probeDiscoveringRelays =>
      'İcma qovluqları vasitəsilə relay-lər aşkar edilir…';

  @override
  String get probeStartingTor => 'Tor başladılır…';

  @override
  String get probeFindingRelaysTor =>
      'Tor vasitəsilə əlçatan relay-lər axtarılır…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'Şəbəkə hazırdır — $count relay$_temp0 tapıldı';
  }

  @override
  String get probeNoRelaysFound =>
      'Əlçatan relay tapılmadı — mesajlar gecikə bilər';

  @override
  String get jitsiWarningTitle => 'Uçdan uca şifrələnməyib';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet zəngləri Pulse tərəfindən şifrələnmir. Yalnız həssas olmayan söhbətlər üçün istifadə edin.';

  @override
  String get jitsiConfirm => 'Yenə də qoşul';

  @override
  String get jitsiGroupWarningTitle => 'Uçdan uca şifrələnməyib';

  @override
  String get jitsiGroupWarningBody =>
      'Bu zəngdə daxili şifrələnmiş mesh üçün çox iştirakçı var.\n\nBrauzerinizdə Jitsi Meet linki açılacaq. Jitsi uçdan uca şifrələnmir — server zənginizi görə bilər.';

  @override
  String get jitsiContinueAnyway => 'Yenə də davam et';

  @override
  String get retry => 'Yenidən cəhd et';

  @override
  String get setupCreateAnonymousAccount => 'Anonim hesab yarat';

  @override
  String get setupTapToChangeColor => 'Rəngi dəyişmək üçün toxunun';

  @override
  String get setupReqMinLength => 'Ən azı 16 simvol';

  @override
  String get setupReqVariety =>
      '4-dən 3-ü: böyük, kiçik hərflər, rəqəmlər, simvollar';

  @override
  String get setupReqMatch => 'Şifrələr uyğun gəlir';

  @override
  String get setupYourNickname => 'Ləqəbiniz';

  @override
  String get setupRecoveryPassword => 'Bərpa parolu (min. 16)';

  @override
  String get setupConfirmPassword => 'Parolu təsdiqlə';

  @override
  String get setupMin16Chars => 'Minimum 16 simvol';

  @override
  String get setupPasswordsDoNotMatch => 'Parollar uyğun gəlmir';

  @override
  String get setupEntropyWeak => 'Zəif';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Güclü';

  @override
  String get setupEntropyWeakNeedsVariety => 'Zəif (3 simvol növü lazımdır)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bit)';
  }

  @override
  String get setupPasswordWarning =>
      'Bu parol hesabınızı bərpa etməyin yeganə yoludur. Server yoxdur — parol sıfırlama yoxdur. Yadda saxlayın və ya yazın.';

  @override
  String get setupCreateAccount => 'Hesab yarat';

  @override
  String get setupAlreadyHaveAccount => 'Artıq hesabınız var? ';

  @override
  String get setupRestore => 'Bərpa et →';

  @override
  String get restoreTitle => 'Hesabı bərpa et';

  @override
  String get restoreInfoBanner =>
      'Bərpa parolunuzu daxil edin — ünvanınız (Nostr + Session) avtomatik bərpa olunacaq. Kontaktlar və mesajlar yalnız yerli olaraq saxlanılıb.';

  @override
  String get restoreNewNickname => 'Yeni ləqəb (sonra dəyişdirilə bilər)';

  @override
  String get restoreButton => 'Hesabı bərpa et';

  @override
  String get lockTitle => 'Pulse kilidlənib';

  @override
  String get lockSubtitle => 'Davam etmək üçün parolunuzu daxil edin';

  @override
  String get lockPasswordHint => 'Parol';

  @override
  String get lockUnlock => 'Kilidi aç';

  @override
  String get lockPanicHint =>
      'Parolunuzu unutmusunuz? Bütün məlumatları silmək üçün təcili açarı daxil edin.';

  @override
  String get lockTooManyAttempts => 'Çox sayda cəhd. Bütün məlumatlar silinir…';

  @override
  String get lockWrongPassword => 'Yanlış parol';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Yanlış parol — $attempts/$max cəhd';
  }

  @override
  String get onboardingSkip => 'Keç';

  @override
  String get onboardingNext => 'Növbəti';

  @override
  String get onboardingGetStarted => 'Hesab Yarat';

  @override
  String get onboardingWelcomeTitle => 'Pulse-a xoş gəlmisiniz';

  @override
  String get onboardingWelcomeBody =>
      'Mərkəzləşdirilməmiş, uçdan uca şifrələnmiş messencer.\n\nMərkəzi server yoxdur. Məlumat toplama yoxdur. Arxa qapılar yoxdur.\nSöhbətləriniz yalnız sizə məxsusdur.';

  @override
  String get onboardingTransportTitle => 'Nəqliyyatdan asılı olmayan';

  @override
  String get onboardingTransportBody =>
      'Firebase, Nostr və ya hər ikisini eyni anda istifadə edin.\n\nMesajlar şəbəkələr arasında avtomatik yönləndirilir. Senzura müqavimə üçün daxili Tor və I2P dəstəyi.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Kvant';

  @override
  String get onboardingSignalBody =>
      'Hər mesaj irəli məxfilik üçün Signal Protokolu (Double Ratchet + X3DH) ilə şifrələnir.\n\nƏlavə olaraq Kyber-1024 ilə sarılır — gələcək kvant kompüterlərinə qarşı qoruma üçün NIST standart post-kvant alqoritmi.';

  @override
  String get onboardingKeysTitle => 'Açarlarınız sizindir';

  @override
  String get onboardingKeysBody =>
      'Şəxsiyyət açarlarınız heç vaxt cihazınızı tərk etmir.\n\nSignal barmaq izləri kontaktları kənar kanaldan yoxlamağa imkan verir. TOFU (Trust On First Use) açar dəyişikliklərini avtomatik aşkar edir.';

  @override
  String get onboardingThemeTitle => 'Görünüşünüzü seçin';

  @override
  String get onboardingThemeBody =>
      'Tema və vurğu rəngi seçin. Bunu hər zaman Parametrlərdən dəyişə bilərsiniz.';

  @override
  String get contactsNewChat => 'Yeni söhbət';

  @override
  String get contactsAddContact => 'Kontakt əlavə et';

  @override
  String get contactsSearchHint => 'Axtar...';

  @override
  String get contactsNewGroup => 'Yeni qrup';

  @override
  String get contactsNoContactsYet => 'Hələ kontakt yoxdur';

  @override
  String get contactsAddHint =>
      'Birinin ünvanını əlavə etmək üçün + düyməsinə toxunun';

  @override
  String get contactsNoMatch => 'Uyğun kontakt yoxdur';

  @override
  String get contactsRemoveTitle => 'Kontaktı sil';

  @override
  String contactsRemoveMessage(String name) {
    return '$name silinsin?';
  }

  @override
  String get contactsRemove => 'Sil';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count kontakt$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Linki aç';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Bu URL brauzerdə açılsın?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Aç';

  @override
  String get bubbleSecurityWarning => 'Təhlükəsizlik xəbərdarlığı';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" icra edilə bilən fayl növüdür. Saxlamaq və işə salmaq cihazınıza zərər verə bilər. Yenə də saxlansın?';
  }

  @override
  String get bubbleSaveAnyway => 'Yenə də saxla';

  @override
  String bubbleSavedTo(String path) {
    return '$path ünvanına saxlanıldı';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Saxlama uğursuz oldu: $error';
  }

  @override
  String get bubbleNotEncrypted => 'ŞİFRƏLƏNMƏYİB';

  @override
  String get bubbleCorruptedImage => '[Zədələnmiş şəkil]';

  @override
  String get bubbleReplyPhoto => 'Foto';

  @override
  String get bubbleReplyVoice => 'Səs mesajı';

  @override
  String get bubbleReplyVideo => 'Video mesaj';

  @override
  String bubbleReadBy(String names) {
    return '$names tərəfindən oxunub';
  }

  @override
  String bubbleReadByCount(int count) {
    return '$count nəfər tərəfindən oxunub';
  }

  @override
  String get chatTileTapToStart => 'Söhbətə başlamaq üçün toxunun';

  @override
  String get chatTileMessageSent => 'Mesaj göndərildi';

  @override
  String get chatTileEncryptedMessage => 'Şifrələnmiş mesaj';

  @override
  String chatTileYouPrefix(String text) {
    return 'Siz: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Səs mesajı';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Səs mesajı ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Şifrələnmiş mesaj';

  @override
  String get groupNewGroup => 'Yeni qrup';

  @override
  String get groupGroupName => 'Qrup adı';

  @override
  String get groupSelectMembers => 'Üzvləri seçin (min 2)';

  @override
  String get groupNoContactsYet =>
      'Hələ kontakt yoxdur. Əvvəlcə kontakt əlavə edin.';

  @override
  String get groupCreate => 'Yarat';

  @override
  String get groupLabel => 'Qrup';

  @override
  String get profileVerifyIdentity => 'Şəxsiyyəti yoxla';

  @override
  String profileVerifyInstructions(String name) {
    return 'Bu barmaq izlərini $name ilə səsli zəng və ya şəxsən müqayisə edin. Hər iki dəyər hər iki cihazda uyğun gəlirsə, \"Təsdiqlənmiş olaraq işarələ\" düyməsinə toxunun.';
  }

  @override
  String get profileTheirKey => 'Onların açarı';

  @override
  String get profileYourKey => 'Sizin açarınız';

  @override
  String get profileRemoveVerification => 'Təsdiqləməni sil';

  @override
  String get profileMarkAsVerified => 'Təsdiqlənmiş olaraq işarələ';

  @override
  String get profileAddressCopied => 'Ünvan kopyalandı';

  @override
  String get profileNoContactsToAdd =>
      'Əlavə ediləcək kontakt yoxdur — hamısı artıq üzvdür';

  @override
  String get profileAddMembers => 'Üzv əlavə et';

  @override
  String profileAddCount(int count) {
    return 'Əlavə et ($count)';
  }

  @override
  String get profileRenameGroup => 'Qrupun adını dəyiş';

  @override
  String get profileRename => 'Adını dəyiş';

  @override
  String get profileRemoveMember => 'Üzv silinsin?';

  @override
  String profileRemoveMemberBody(String name) {
    return '$name bu qrupdan silinsin?';
  }

  @override
  String get profileKick => 'Çıxar';

  @override
  String get profileSignalFingerprints => 'Signal barmaq izləri';

  @override
  String get profileVerified => 'TƏSDİQLƏNİB';

  @override
  String get profileVerify => 'Yoxla';

  @override
  String get profileEdit => 'Redaktə et';

  @override
  String get profileNoSession =>
      'Hələ sessiya qurulmayıb — əvvəlcə mesaj göndərin.';

  @override
  String get profileFingerprintCopied => 'Barmaq izi kopyalandı';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count üzv$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Təhlükəsizlik nömrəsini yoxla';

  @override
  String get profileShowContactQr => 'Kontakt QR-nu göstər';

  @override
  String profileContactAddress(String name) {
    return '$name ünvanı';
  }

  @override
  String get profileExportChatHistory => 'Söhbət tarixçəsini ixrac et';

  @override
  String profileSavedTo(String path) {
    return '$path ünvanına saxlanıldı';
  }

  @override
  String get profileExportFailed => 'İxrac uğursuz oldu';

  @override
  String get profileClearChatHistory => 'Söhbət tarixçəsini təmizlə';

  @override
  String get profileDeleteGroup => 'Qrupu sil';

  @override
  String get profileDeleteContact => 'Kontaktı sil';

  @override
  String get profileLeaveGroup => 'Qrupdan çıx';

  @override
  String get profileLeaveGroupBody =>
      'Bu qrupdan çıxarılacaq və kontaktlarınızdan silinəcəksiniz.';

  @override
  String get groupInviteTitle => 'Qrup dəvəti';

  @override
  String groupInviteBody(String from, String group) {
    return '$from sizi \"$group\" qrupuna qoşulmağa dəvət etdi';
  }

  @override
  String get groupInviteAccept => 'Qəbul et';

  @override
  String get groupInviteDecline => 'Rədd et';

  @override
  String get groupMemberLimitTitle => 'Çox sayda iştirakçı';

  @override
  String groupMemberLimitBody(int count) {
    return 'Bu qrupda $count iştirakçı olacaq. Şifrələnmiş mesh zəngləri maksimum 6 nəfəri dəstəkləyir. Daha böyük qruplar Jitsi-yə keçir (E2EE deyil).';
  }

  @override
  String get groupMemberLimitContinue => 'Yenə də əlavə et';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name \"$group\" qrupuna qoşulmağı rədd etdi';
  }

  @override
  String get transferTitle => 'Başqa cihaza köçür';

  @override
  String get transferInfoBox =>
      'Signal şəxsiyyətinizi və Nostr açarlarınızı yeni cihaza köçürün.\nSöhbət sessiyaları köçürülmür — irəli məxfilik qorunur.';

  @override
  String get transferSendFromThis => 'Bu cihazdan göndər';

  @override
  String get transferSendSubtitle =>
      'Bu cihazda açarlar var. Yeni cihazla kod paylaşın.';

  @override
  String get transferReceiveOnThis => 'Bu cihazda qəbul et';

  @override
  String get transferReceiveSubtitle =>
      'Bu yeni cihazdır. Köhnə cihazdan kodu daxil edin.';

  @override
  String get transferChooseMethod => 'Köçürmə üsulunu seçin';

  @override
  String get transferLan => 'LAN (Eyni şəbəkə)';

  @override
  String get transferLanSubtitle =>
      'Sürətli və birbaşa. Hər iki cihaz eyni Wi-Fi-da olmalıdır.';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'Mövcud Nostr relay vasitəsilə istənilən şəbəkə üzərindən işləyir.';

  @override
  String get transferRelayUrl => 'Relay URL';

  @override
  String get transferEnterCode => 'Köçürmə kodunu daxil edin';

  @override
  String get transferPasteCode =>
      'LAN:... və ya NOS:... kodunu bura yapışdırın';

  @override
  String get transferConnect => 'Qoşul';

  @override
  String get transferGenerating => 'Köçürmə kodu yaradılır…';

  @override
  String get transferShareCode => 'Bu kodu alıcı ilə paylaşın:';

  @override
  String get transferCopyCode => 'Kodu kopyala';

  @override
  String get transferCodeCopied => 'Kod buferə kopyalandı';

  @override
  String get transferWaitingReceiver => 'Alıcının qoşulması gözlənilir…';

  @override
  String get transferConnectingSender => 'Göndəriciyə qoşulur…';

  @override
  String get transferVerifyBoth =>
      'Bu kodu hər iki cihazda müqayisə edin.\nUyğun gəlirsə, köçürmə təhlükəsizdir.';

  @override
  String get transferComplete => 'Köçürmə tamamlandı';

  @override
  String get transferKeysImported => 'Açarlar idxal edildi';

  @override
  String get transferCompleteSenderBody =>
      'Açarlarınız bu cihazda aktiv qalır.\nAlıcı indi şəxsiyyətinizi istifadə edə bilər.';

  @override
  String get transferCompleteReceiverBody =>
      'Açarlar uğurla idxal edildi.\nYeni şəxsiyyəti tətbiq etmək üçün tətbiqi yenidən başladın.';

  @override
  String get transferRestartApp => 'Tətbiqi yenidən başlat';

  @override
  String get transferFailed => 'Köçürmə uğursuz oldu';

  @override
  String get transferTryAgain => 'Yenidən cəhd et';

  @override
  String get transferEnterRelayFirst => 'Əvvəlcə relay URL daxil edin';

  @override
  String get transferPasteCodeFromSender =>
      'Göndəricinin köçürmə kodunu yapışdırın';

  @override
  String get menuReply => 'Cavab ver';

  @override
  String get menuForward => 'Yönləndir';

  @override
  String get menuReact => 'Reaksiya ver';

  @override
  String get menuCopy => 'Kopyala';

  @override
  String get menuEdit => 'Redaktə et';

  @override
  String get menuRetry => 'Yenidən cəhd et';

  @override
  String get menuCancelScheduled => 'Planlaşdırılmışı ləğv et';

  @override
  String get menuDelete => 'Sil';

  @override
  String get menuForwardTo => 'Yönləndir…';

  @override
  String menuForwardedTo(String name) {
    return '$name adlı kontakta yönləndirildi';
  }

  @override
  String get menuScheduledMessages => 'Planlaşdırılmış mesajlar';

  @override
  String get menuNoScheduledMessages => 'Planlaşdırılmış mesaj yoxdur';

  @override
  String menuSendsOn(String date) {
    return '$date tarixində göndəriləcək';
  }

  @override
  String get menuDisappearingMessages => 'Yox olan mesajlar';

  @override
  String get menuDisappearingSubtitle =>
      'Mesajlar seçilmiş vaxtdan sonra avtomatik silinir.';

  @override
  String get menuTtlOff => 'Söndürülüb';

  @override
  String get menuTtl1h => '1 saat';

  @override
  String get menuTtl24h => '24 saat';

  @override
  String get menuTtl7d => '7 gün';

  @override
  String get menuAttachPhoto => 'Foto';

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
    return 'Fotolar ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Fayllar ($count)';
  }

  @override
  String get mediaNoPhotos => 'Hələ foto yoxdur';

  @override
  String get mediaNoFiles => 'Hələ fayl yoxdur';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Downloads/$name ünvanına saxlanıldı';
  }

  @override
  String get mediaFailedToSave => 'Fayl saxlanıla bilmədi';

  @override
  String get statusNewStatus => 'Yeni status';

  @override
  String get statusPublish => 'Dərc et';

  @override
  String get statusExpiresIn24h => 'Status 24 saatdan sonra bitir';

  @override
  String get statusWhatsOnYourMind => 'Nə düşünürsünüz?';

  @override
  String get statusPhotoAttached => 'Foto əlavə edildi';

  @override
  String get statusAttachPhoto => 'Foto əlavə et (isteğe bağlı)';

  @override
  String get statusEnterText =>
      'Zəhmət olmasa statusunuz üçün mətn daxil edin.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Foto seçilə bilmədi: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Dərc uğursuz oldu: $error';
  }

  @override
  String get panicSetPanicKey => 'Təcili açar təyin et';

  @override
  String get panicEmergencySelfDestruct => 'Təcili özünüməhv';

  @override
  String get panicIrreversible => 'Bu əməliyyat geri qaytarıla bilməz';

  @override
  String get panicWarningBody =>
      'Bu açarı kilid ekranında daxil etmək BÜTÜN məlumatları dərhal silir — mesajlar, kontaktlar, açarlar, şəxsiyyət. Adi parolunuzdan fərqli bir açar istifadə edin.';

  @override
  String get panicKeyHint => 'Təcili açar';

  @override
  String get panicConfirmHint => 'Təcili açarı təsdiqlə';

  @override
  String get panicMinChars => 'Təcili açar ən azı 8 simvol olmalıdır';

  @override
  String get panicKeysDoNotMatch => 'Açarlar uyğun gəlmir';

  @override
  String get panicSetFailed =>
      'Təcili açar saxlanıla bilmədi — zəhmət olmasa yenidən cəhd edin';

  @override
  String get passwordSetAppPassword => 'Tətbiq parolu təyin et';

  @override
  String get passwordProtectsMessages =>
      'Mesajlarınızı qeyri-aktiv vəziyyətdə qoruyur';

  @override
  String get passwordInfoBanner =>
      'Pulse-u hər dəfə açdığınızda tələb olunur. Unudulduqda məlumatlarınız bərpa edilə bilməz.';

  @override
  String get passwordHint => 'Parol';

  @override
  String get passwordConfirmHint => 'Parolu təsdiqlə';

  @override
  String get passwordSetButton => 'Parol təyin et';

  @override
  String get passwordSkipForNow => 'Hələlik keç';

  @override
  String get passwordMinChars => 'Parol ən azı 8 simvol olmalıdır';

  @override
  String get passwordNeedsVariety =>
      'Hərflər, rəqəmlər və xüsusi simvollar daxil olmalıdır';

  @override
  String get passwordRequirements =>
      'Minimum 8 simvol hərflər, rəqəmlər və xüsusi simvolla';

  @override
  String get passwordsDoNotMatch => 'Parollar uyğun gəlmir';

  @override
  String get profileCardSaved => 'Profil saxlanıldı!';

  @override
  String get profileCardE2eeIdentity => 'E2EE şəxsiyyəti';

  @override
  String get profileCardDisplayName => 'Görünən ad';

  @override
  String get profileCardDisplayNameHint => 'məs. Əli Əliyev';

  @override
  String get profileCardAbout => 'Haqqında';

  @override
  String get profileCardSaveProfile => 'Profili saxla';

  @override
  String get profileCardYourName => 'Adınız';

  @override
  String get profileCardAddressCopied => 'Ünvan kopyalandı!';

  @override
  String get profileCardInboxAddress => 'Gələn qutusu ünvanınız';

  @override
  String get profileCardInboxAddresses => 'Gələn qutusu ünvanlarınız';

  @override
  String get profileCardShareAllAddresses =>
      'Bütün ünvanları paylaş (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Sizə mesaj yaza bilmələri üçün kontaktlarla paylaşın.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Bütün $count ünvan bir link olaraq kopyalandı!';
  }

  @override
  String get settingsMyProfile => 'Profilim';

  @override
  String get settingsYourInboxAddress => 'Gələn qutusu ünvanınız';

  @override
  String get settingsMyQrCode => 'Kontaktı paylaş';

  @override
  String get settingsMyQrSubtitle => 'Ünvanınız üçün QR kod və dəvət linki';

  @override
  String get settingsShareMyAddress => 'Ünvanımı paylaş';

  @override
  String get settingsNoAddressYet =>
      'Hələ ünvan yoxdur — əvvəlcə parametrləri saxlayın';

  @override
  String get settingsInviteLink => 'Dəvət linki';

  @override
  String get settingsRawAddress => 'Xam ünvan';

  @override
  String get settingsCopyLink => 'Linki kopyala';

  @override
  String get settingsCopyAddress => 'Ünvanı kopyala';

  @override
  String get settingsInviteLinkCopied => 'Dəvət linki kopyalandı';

  @override
  String get settingsAppearance => 'Görünüş';

  @override
  String get settingsThemeEngine => 'Tema mühərriki';

  @override
  String get settingsThemeEngineSubtitle => 'Rəngləri və şriftləri fərdiləşdir';

  @override
  String get settingsSignalProtocol => 'Signal Protokolu';

  @override
  String get settingsSignalProtocolSubtitle =>
      'E2EE açarları təhlükəsiz saxlanılır';

  @override
  String get settingsActive => 'AKTİV';

  @override
  String get settingsIdentityBackup => 'Şəxsiyyət ehtiyat nüsxəsi';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Signal şəxsiyyətinizi ixrac edin və ya idxal edin';

  @override
  String get settingsIdentityBackupBody =>
      'Signal şəxsiyyət açarlarınızı ehtiyat koduna ixrac edin və ya mövcud olandan bərpa edin.';

  @override
  String get settingsTransferDevice => 'Başqa cihaza köçür';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Şəxsiyyətinizi LAN və ya Nostr relay vasitəsilə köçürün';

  @override
  String get settingsExportIdentity => 'Şəxsiyyəti ixrac et';

  @override
  String get settingsExportIdentityBody =>
      'Bu ehtiyat kodunu kopyalayın və təhlükəsiz saxlayın:';

  @override
  String get settingsSaveFile => 'Faylı saxla';

  @override
  String get settingsImportIdentity => 'Şəxsiyyəti idxal et';

  @override
  String get settingsImportIdentityBody =>
      'Ehtiyat kodunuzu aşağıya yapışdırın. Bu, cari şəxsiyyətinizi əvəz edəcək.';

  @override
  String get settingsPasteBackupCode => 'Ehtiyat kodunu bura yapışdırın…';

  @override
  String get settingsIdentityImported =>
      'Şəxsiyyət + kontaktlar idxal edildi! Tətbiq etmək üçün tətbiqi yenidən başladın.';

  @override
  String get settingsSecurity => 'Təhlükəsizlik';

  @override
  String get settingsAppPassword => 'Tətbiq parolu';

  @override
  String get settingsPasswordEnabled => 'Aktiv — hər başlanğıcda tələb olunur';

  @override
  String get settingsPasswordDisabled => 'Deaktiv — tətbiq parolsuz açılır';

  @override
  String get settingsChangePassword => 'Parolu dəyiş';

  @override
  String get settingsChangePasswordSubtitle =>
      'Tətbiq kilid parolunu yeniləyin';

  @override
  String get settingsSetPanicKey => 'Təcili açar təyin et';

  @override
  String get settingsChangePanicKey => 'Təcili açarı dəyiş';

  @override
  String get settingsPanicKeySetSubtitle => 'Təcili silmə açarını yeniləyin';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Bütün məlumatları dərhal silən bir açar';

  @override
  String get settingsRemovePanicKey => 'Təcili açarı sil';

  @override
  String get settingsRemovePanicKeySubtitle => 'Təcili özünüməhvi deaktiv et';

  @override
  String get settingsRemovePanicKeyBody =>
      'Təcili özünüməhv deaktiv olunacaq. İstənilən vaxt yenidən aktivləşdirə bilərsiniz.';

  @override
  String get settingsDisableAppPassword => 'Tətbiq parolunu deaktiv et';

  @override
  String get settingsEnterCurrentPassword =>
      'Təsdiqləmək üçün cari parolunuzu daxil edin';

  @override
  String get settingsCurrentPassword => 'Cari parol';

  @override
  String get settingsIncorrectPassword => 'Yanlış parol';

  @override
  String get settingsPasswordUpdated => 'Parol yeniləndi';

  @override
  String get settingsChangePasswordProceed =>
      'Davam etmək üçün cari parolunuzu daxil edin';

  @override
  String get settingsData => 'Məlumatlar';

  @override
  String get settingsBackupMessages => 'Mesajların ehtiyat nüsxəsi';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Şifrələnmiş mesaj tarixçəsini fayla ixrac edin';

  @override
  String get settingsRestoreMessages => 'Mesajları bərpa et';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Ehtiyat faylından mesajları idxal edin';

  @override
  String get settingsExportKeys => 'Açarları ixrac et';

  @override
  String get settingsExportKeysSubtitle =>
      'Şəxsiyyət açarlarını şifrələnmiş fayla saxlayın';

  @override
  String get settingsImportKeys => 'Açarları idxal et';

  @override
  String get settingsImportKeysSubtitle =>
      'İxrac edilmiş fayldan şəxsiyyət açarlarını bərpa edin';

  @override
  String get settingsBackupPassword => 'Ehtiyat parolu';

  @override
  String get settingsPasswordCannotBeEmpty => 'Parol boş ola bilməz';

  @override
  String get settingsPasswordMin4Chars => 'Parol ən azı 4 simvol olmalıdır';

  @override
  String get settingsCallsTurn => 'Zənglər və TURN';

  @override
  String get settingsLocalNetwork => 'Yerli şəbəkə';

  @override
  String get settingsCensorshipResistance => 'Senzura müqaviməti';

  @override
  String get settingsNetwork => 'Şəbəkə';

  @override
  String get settingsProxyTunnels => 'Proksi və tunellər';

  @override
  String get settingsTurnServers => 'TURN serverləri';

  @override
  String get settingsProviderTitle => 'Provayder';

  @override
  String get settingsLanFallback => 'LAN ehtiyat';

  @override
  String get settingsLanFallbackSubtitle =>
      'İnternet əlçatan olmadıqda yerli şəbəkədə mövcudluğu yayımlayın və mesajları çatdırın. Etibarsız şəbəkələrdə (ictimai Wi-Fi) deaktiv edin.';

  @override
  String get settingsBgDelivery => 'Arxa plan çatdırılması';

  @override
  String get settingsBgDeliverySubtitle =>
      'Tətbiq kiçildildikdə mesajları almağa davam edin. Daimi bildiriş göstərir.';

  @override
  String get settingsYourInboxProvider => 'Gələn qutusu provayderiniz';

  @override
  String get settingsConnectionDetails => 'Əlaqə detalları';

  @override
  String get settingsSaveAndConnect => 'Saxla və qoşul';

  @override
  String get settingsSecondaryInboxes => 'İkinci dərəcəli gələn qutuları';

  @override
  String get settingsAddSecondaryInbox =>
      'İkinci dərəcəli gələn qutusu əlavə et';

  @override
  String get settingsAdvanced => 'Ətraflı';

  @override
  String get settingsDiscover => 'Kəşf et';

  @override
  String get settingsAbout => 'Haqqında';

  @override
  String get settingsPrivacyPolicy => 'Məxfilik siyasəti';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Pulse məlumatlarınızı necə qoruyur';

  @override
  String get settingsCrashReporting => 'Qəza hesabatları';

  @override
  String get settingsCrashReportingSubtitle =>
      'Pulse-u təkmilləşdirmək üçün anonim qəza hesabatları göndərin. Heç vaxt mesaj məzmunu və ya kontaktlar göndərilmir.';

  @override
  String get settingsCrashReportingEnabled =>
      'Qəza hesabatları aktiv edildi — tətbiq etmək üçün tətbiqi yenidən başladın';

  @override
  String get settingsCrashReportingDisabled =>
      'Qəza hesabatları deaktiv edildi — tətbiq etmək üçün tətbiqi yenidən başladın';

  @override
  String get settingsSensitiveOperation => 'Həssas əməliyyat';

  @override
  String get settingsSensitiveOperationBody =>
      'Bu açarlar sizin şəxsiyyətinizdir. Bu fayla sahib olan hər kəs sizi təqlid edə bilər. Təhlükəsiz saxlayın və köçürmədən sonra silin.';

  @override
  String get settingsIUnderstandContinue => 'Başa düşürəm, davam et';

  @override
  String get settingsReplaceIdentity => 'Şəxsiyyət əvəz edilsin?';

  @override
  String get settingsReplaceIdentityBody =>
      'Bu, cari şəxsiyyət açarlarınızı əvəz edəcək. Mövcud Signal sessiyalarınız etibarsız olacaq və kontaktlar şifrələməni yenidən qurmalı olacaq. Tətbiqi yenidən başlatmaq lazımdır.';

  @override
  String get settingsReplaceKeys => 'Açarları əvəz et';

  @override
  String get settingsKeysImported => 'Açarlar idxal edildi';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count açar uğurla idxal edildi. Zəhmət olmasa yeni şəxsiyyətlə başlamaq üçün tətbiqi yenidən başladın.';
  }

  @override
  String get settingsRestartNow => 'İndi yenidən başlat';

  @override
  String get settingsLater => 'Sonra';

  @override
  String get profileGroupLabel => 'Qrup';

  @override
  String get profileAddButton => 'Əlavə et';

  @override
  String get profileKickButton => 'Çıxar';

  @override
  String get dataSectionTitle => 'Məlumatlar';

  @override
  String get dataBackupMessages => 'Mesajların ehtiyat nüsxəsi';

  @override
  String get dataBackupPasswordSubtitle =>
      'Mesaj ehtiyat nüsxənizi şifrələmək üçün parol seçin.';

  @override
  String get dataBackupConfirmLabel => 'Ehtiyat nüsxəsi yarat';

  @override
  String get dataCreatingBackup => 'Ehtiyat nüsxəsi yaradılır';

  @override
  String get dataBackupPreparing => 'Hazırlanır...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Mesaj $done/$total ixrac edilir...';
  }

  @override
  String get dataBackupSavingFile => 'Fayl saxlanılır...';

  @override
  String get dataSaveMessageBackupDialog => 'Mesaj ehtiyat nüsxəsini saxla';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Ehtiyat nüsxəsi saxlanıldı ($count mesaj)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Ehtiyat nüsxəsi uğursuz oldu — heç bir məlumat ixrac edilmədi';

  @override
  String dataBackupFailedError(String error) {
    return 'Ehtiyat nüsxəsi uğursuz oldu: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Mesaj ehtiyat nüsxəsini seç';

  @override
  String get dataInvalidBackupFile => 'Etibarsız ehtiyat faylı (çox kiçikdir)';

  @override
  String get dataNotValidBackupFile => 'Etibarlı Pulse ehtiyat faylı deyil';

  @override
  String get dataRestoreMessages => 'Mesajları bərpa et';

  @override
  String get dataRestorePasswordSubtitle =>
      'Bu ehtiyat nüsxəsini yaratmaq üçün istifadə edilən parolu daxil edin.';

  @override
  String get dataRestoreConfirmLabel => 'Bərpa et';

  @override
  String get dataRestoringMessages => 'Mesajlar bərpa edilir';

  @override
  String get dataRestoreDecrypting => 'Şifrə açılır...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Mesaj $done/$total idxal edilir...';
  }

  @override
  String get dataRestoreFailed =>
      'Bərpa uğursuz oldu — yanlış parol və ya zədələnmiş fayl';

  @override
  String dataRestoreSuccess(int count) {
    return '$count yeni mesaj bərpa edildi';
  }

  @override
  String get dataRestoreNothingNew =>
      'İdxal ediləcək yeni mesaj yoxdur (hamısı artıq mövcuddur)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Bərpa uğursuz oldu: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Açar ixracını seç';

  @override
  String get dataNotValidKeyFile => 'Etibarlı Pulse açar ixrac faylı deyil';

  @override
  String get dataExportKeys => 'Açarları ixrac et';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Açar ixracınızı şifrələmək üçün parol seçin.';

  @override
  String get dataExportKeysConfirmLabel => 'İxrac et';

  @override
  String get dataExportingKeys => 'Açarlar ixrac edilir';

  @override
  String get dataExportingKeysStatus => 'Şəxsiyyət açarları şifrələnir...';

  @override
  String get dataSaveKeyExportDialog => 'Açar ixracını saxla';

  @override
  String dataKeysExportedTo(String path) {
    return 'Açarlar ixrac edildi:\n$path';
  }

  @override
  String get dataExportFailed => 'İxrac uğursuz oldu — açar tapılmadı';

  @override
  String dataExportFailedError(String error) {
    return 'İxrac uğursuz oldu: $error';
  }

  @override
  String get dataImportKeys => 'Açarları idxal et';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Bu açar ixracını şifrələmək üçün istifadə edilən parolu daxil edin.';

  @override
  String get dataImportKeysConfirmLabel => 'İdxal et';

  @override
  String get dataImportingKeys => 'Açarlar idxal edilir';

  @override
  String get dataImportingKeysStatus =>
      'Şəxsiyyət açarlarının şifrəsi açılır...';

  @override
  String get dataImportFailed =>
      'İdxal uğursuz oldu — yanlış parol və ya zədələnmiş fayl';

  @override
  String dataImportFailedError(String error) {
    return 'İdxal uğursuz oldu: $error';
  }

  @override
  String get securitySectionTitle => 'Təhlükəsizlik';

  @override
  String get securityIncorrectPassword => 'Yanlış parol';

  @override
  String get securityPasswordUpdated => 'Parol yeniləndi';

  @override
  String get appearanceSectionTitle => 'Görünüş';

  @override
  String appearanceExportFailed(String error) {
    return 'İxrac uğursuz oldu: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return '$path ünvanına saxlanıldı';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Saxlama uğursuz oldu: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'İdxal uğursuz oldu: $error';
  }

  @override
  String get aboutSectionTitle => 'Haqqında';

  @override
  String get providerPublicKey => 'Açıq açar';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Bərpa parolunuzdan avtomatik konfiqurasiya edilib. Relay avtomatik aşkar edilib.';

  @override
  String get providerKeyStoredLocally =>
      'Açarınız yerli təhlükəsiz yaddaşda saxlanılır — heç vaxt heç bir serverə göndərilmir.';

  @override
  String get providerSessionInfo =>
      'Session Network — soğan yönləndirilmiş E2EE. Session ID-niz avtomatik yaradılır və təhlükəsiz saxlanılır. Qovşaqlar daxili toxum qovşaqlarından avtomatik kəşf edilir.';

  @override
  String get providerAdvanced => 'Ətraflı';

  @override
  String get providerSaveAndConnect => 'Saxla və qoşul';

  @override
  String get providerAddSecondaryInbox =>
      'İkinci dərəcəli gələn qutusu əlavə et';

  @override
  String get providerSecondaryInboxes => 'İkinci dərəcəli gələn qutuları';

  @override
  String get providerYourInboxProvider => 'Gələn qutusu provayderiniz';

  @override
  String get providerConnectionDetails => 'Əlaqə detalları';

  @override
  String get addContactTitle => 'Kontakt əlavə et';

  @override
  String get addContactInviteLinkLabel => 'Dəvət linki və ya ünvan';

  @override
  String get addContactTapToPaste => 'Dəvət linkini yapışdırmaq üçün toxunun';

  @override
  String get addContactPasteTooltip => 'Buferdən yapışdır';

  @override
  String get addContactAddressDetected => 'Kontakt ünvanı aşkar edildi';

  @override
  String addContactRoutesDetected(int count) {
    return '$count marşrut aşkar edildi — SmartRouter ən sürətlisini seçir';
  }

  @override
  String get addContactFetchingProfile => 'Profil yüklənir…';

  @override
  String addContactProfileFound(String name) {
    return 'Tapıldı: $name';
  }

  @override
  String get addContactNoProfileFound => 'Profil tapılmadı';

  @override
  String get addContactDisplayNameLabel => 'Görünən ad';

  @override
  String get addContactDisplayNameHint =>
      'Onları necə adlandırmaq istəyirsiniz?';

  @override
  String get addContactAddManually => 'Ünvanı əl ilə daxil edin';

  @override
  String get addContactButton => 'Kontakt əlavə et';

  @override
  String get networkDiagnosticsTitle => 'Şəbəkə diaqnostikası';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr relay-ləri';

  @override
  String get networkDiagnosticsDirect => 'Birbaşa';

  @override
  String get networkDiagnosticsTorOnly => 'Yalnız Tor';

  @override
  String get networkDiagnosticsBest => 'Ən yaxşı';

  @override
  String get networkDiagnosticsNone => 'yoxdur';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Status';

  @override
  String get networkDiagnosticsConnected => 'Qoşuldu';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Qoşulur $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Söndürülüb';

  @override
  String get networkDiagnosticsTransport => 'Nəqliyyat';

  @override
  String get networkDiagnosticsInfrastructure => 'İnfrastruktur';

  @override
  String get networkDiagnosticsSessionNodes => 'Session qovşaqları';

  @override
  String get networkDiagnosticsTurnServers => 'TURN serverləri';

  @override
  String get networkDiagnosticsLastProbe => 'Son yoxlama';

  @override
  String get networkDiagnosticsRunning => 'İşləyir...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Diaqnostikanı başlat';

  @override
  String get networkDiagnosticsForceReprobe =>
      'Tam yenidən yoxlamanı məcbur et';

  @override
  String get networkDiagnosticsJustNow => 'indicə';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes dəq. əvvəl';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours saat əvvəl';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days gün əvvəl';
  }

  @override
  String get homeNoEch => 'ECH yoxdur';

  @override
  String get homeNoEchTooltip =>
      'uTLS proksi əlçatan deyil — ECH deaktivdir.\nTLS barmaq izi DPI üçün görünürdür.';

  @override
  String get settingsTitle => 'Parametrlər';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Saxlanıldı və $provider ilə qoşuldu';
  }

  @override
  String get settingsTorFailedToStart => 'Daxili Tor başlaya bilmədi';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon başlaya bilmədi';

  @override
  String get verifyTitle => 'Təhlükəsizlik nömrəsini yoxla';

  @override
  String get verifyIdentityVerified => 'Şəxsiyyət təsdiqləndi';

  @override
  String get verifyNotYetVerified => 'Hələ təsdiqlənməyib';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Siz $name adlı kontaktın təhlükəsizlik nömrəsini təsdiqlədiniz.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Bu nömrələri $name ilə şəxsən və ya etibarlı kanal vasitəsilə müqayisə edin.';
  }

  @override
  String get verifyExplanation =>
      'Hər söhbətin unikal təhlükəsizlik nömrəsi var. Hər ikiniz cihazlarınızda eyni nömrələri görürsünüzsə, əlaqəniz uçdan uca təsdiqlənib.';

  @override
  String verifyContactKey(String name) {
    return '$name açarı';
  }

  @override
  String get verifyYourKey => 'Sizin açarınız';

  @override
  String get verifyRemoveVerification => 'Təsdiqləməni sil';

  @override
  String get verifyMarkAsVerified => 'Təsdiqlənmiş olaraq işarələ';

  @override
  String verifyAfterReinstall(String name) {
    return '$name tətbiqi yenidən quraşdırarsa, təhlükəsizlik nömrəsi dəyişəcək və təsdiqləmə avtomatik silinəcək.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Yalnız $name ilə səsli zəng və ya şəxsən nömrələri müqayisə etdikdən sonra təsdiqlənmiş olaraq işarələyin.';
  }

  @override
  String get verifyNoSession =>
      'Hələ şifrələmə sessiyası qurulmayıb. Təhlükəsizlik nömrələri yaratmaq üçün əvvəlcə mesaj göndərin.';

  @override
  String get verifyNoKeyAvailable => 'Açar əlçatan deyil';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label barmaq izi kopyalandı';
  }

  @override
  String get providerDatabaseUrlLabel => 'Verilənlər bazası URL';

  @override
  String get providerOptionalHint => 'İsteğe bağlı';

  @override
  String get providerWebApiKeyLabel => 'Web API açarı';

  @override
  String get providerOptionalForPublicDb =>
      'İctimai verilənlər bazası üçün isteğe bağlı';

  @override
  String get providerRelayUrlLabel => 'Relay URL';

  @override
  String get providerPrivateKeyLabel => 'Gizli açar';

  @override
  String get providerPrivateKeyNsecLabel => 'Gizli açar (nsec)';

  @override
  String get providerStorageNodeLabel => 'Saxlama düyünü URL (isteğe bağlı)';

  @override
  String get providerStorageNodeHint =>
      'Daxili başlanğıc düyünləri üçün boş buraxın';

  @override
  String get transferInvalidCodeFormat =>
      'Tanınmayan kod formatı — LAN: və ya NOS: ilə başlamalıdır';

  @override
  String get profileCardFingerprintCopied => 'Barmaq izi kopyalandı';

  @override
  String get profileCardAboutHint => 'Əvvəlcə məxfilik 🔒';

  @override
  String get profileCardSaveButton => 'Profili saxla';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Şifrələnmiş mesajları, kontaktları və avatarları fayla ixrac edin';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Səs';

  @override
  String bubbleDeliveredTo(String names) {
    return '$names kontaktına çatdırıldı';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return '$count nəfərə çatdırıldı';
  }

  @override
  String get groupStatusDialogTitle => 'Mesaj məlumatı';

  @override
  String get groupStatusRead => 'Oxunub';

  @override
  String get groupStatusDelivered => 'Çatdırılıb';

  @override
  String get groupStatusPending => 'Gözləyir';

  @override
  String get groupStatusNoData => 'Hələ çatdırılma məlumatı yoxdur';

  @override
  String get profileTransferAdmin => 'Admin et';

  @override
  String profileTransferAdminConfirm(String name) {
    return '$name yeni admin edilsin?';
  }

  @override
  String get profileTransferAdminBody =>
      'Admin hüquqlarınızı itirəcəksiniz. Bu geri qaytarıla bilməz.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name indi admindir';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Məxfilik siyasəti';

  @override
  String get privacyOverviewHeading => 'İcmal';

  @override
  String get privacyOverviewBody =>
      'Pulse serversiz, uçdan uca şifrələnmiş messengerdir. Məxfiliyiniz sadəcə bir xüsusiyyət deyil — arxitekturadır. Pulse serverləri yoxdur. Heç bir hesab heç bir yerdə saxlanmır. Tərtibatçılar tərəfindən heç bir məlumat toplanmır, ötürülmür və ya saxlanmır.';

  @override
  String get privacyDataCollectionHeading => 'Məlumat toplama';

  @override
  String get privacyDataCollectionBody =>
      'Pulse sıfır şəxsi məlumat toplayır. Xüsusən:\n\n- Heç bir e-poçt, telefon nömrəsi və ya həqiqi ad tələb olunmur\n- Heç bir analitika, izləmə və ya telemetriya yoxdur\n- Heç bir reklam identifikatoru yoxdur\n- Kontakt siyahısına giriş yoxdur\n- Bulud ehtiyat nüsxələri yoxdur (mesajlar yalnız cihazınızda mövcuddur)\n- Heç bir Pulse serverinə metadata göndərilmir (heç biri yoxdur)';

  @override
  String get privacyEncryptionHeading => 'Şifrələmə';

  @override
  String get privacyEncryptionBody =>
      'Bütün mesajlar Signal Protokolu (X3DH açar razılaşması ilə Double Ratchet) istifadə edərək şifrələnir. Şifrələmə açarları yalnız cihazınızda yaradılır və saxlanılır. Heç kim — o cümlədən tərtibatçılar — mesajlarınızı oxuya bilməz.';

  @override
  String get privacyNetworkHeading => 'Şəbəkə arxitekturası';

  @override
  String get privacyNetworkBody =>
      'Pulse federativ nəqliyyat adapterləri istifadə edir (Nostr relay-ləri, Session/Oxen xidmət düyünləri, Firebase Realtime Database, LAN). Bu nəqliyyatlar yalnız şifrələnmiş mətn daşıyır. Relay operatorları IP ünvanınızı və trafik həcmini görə bilər, lakin mesaj məzmununu deşifrə edə bilməzlər.\n\nTor aktiv olduqda, IP ünvanınız relay operatorlarından da gizlədilir.';

  @override
  String get privacyStunHeading => 'STUN/TURN serverləri';

  @override
  String get privacyStunBody =>
      'Səsli və video zənglər DTLS-SRTP şifrələməsi ilə WebRTC istifadə edir. STUN serverləri (peer-to-peer əlaqələr üçün açıq IP-nizi aşkar etmək üçün istifadə olunur) və TURN serverləri (birbaşa əlaqə uğursuz olduqda medianı relay etmək üçün istifadə olunur) IP ünvanınızı və zəng müddətini görə bilər, lakin zəng məzmununu deşifrə edə bilməz.\n\nMaksimum məxfilik üçün Parametrlərdə öz TURN serverinizi konfiqurasiya edə bilərsiniz.';

  @override
  String get privacyCrashHeading => 'Qəza hesabatları';

  @override
  String get privacyCrashBody =>
      'Sentry qəza hesabatları aktiv edilibsə (inşaat vaxtı SENTRY_DSN vasitəsilə), anonim qəza hesabatları göndərilə bilər. Bunlarda mesaj məzmunu, kontakt məlumatı və şəxsi identifikasiya məlumatı yoxdur. Qəza hesabatları DSN-i çıxarmaqla inşaat vaxtı deaktiv edilə bilər.';

  @override
  String get privacyPasswordHeading => 'Parol və açarlar';

  @override
  String get privacyPasswordBody =>
      'Bərpa parolunuz Argon2id (yaddaş-çətin KDF) vasitəsilə kriptoqrafik açarları əldə etmək üçün istifadə olunur. Parol heç bir yerə ötürülmür. Parolunuzu itirsəniz, hesabınız bərpa edilə bilməz — onu sıfırlamaq üçün server yoxdur.';

  @override
  String get privacyFontsHeading => 'Şriftlər';

  @override
  String get privacyFontsBody =>
      'Pulse bütün şriftləri yerli olaraq daxil edir. Google Fonts və ya hər hansı xarici şrift xidmətinə sorğu göndərilmir.';

  @override
  String get privacyThirdPartyHeading => 'Üçüncü tərəf xidmətləri';

  @override
  String get privacyThirdPartyBody =>
      'Pulse heç bir reklam şəbəkəsi, analitika provayderi, sosial media platforması və ya məlumat brokeri ilə inteqrasiya etmir. Yeganə şəbəkə əlaqələri konfiqurasiya etdiyiniz nəqliyyat relay-lərinədir.';

  @override
  String get privacyOpenSourceHeading => 'Açıq mənbə';

  @override
  String get privacyOpenSourceBody =>
      'Pulse açıq mənbəli proqramdır. Bu məxfilik iddialarını yoxlamaq üçün tam mənbə kodunu yoxlaya bilərsiniz.';

  @override
  String get privacyContactHeading => 'Əlaqə';

  @override
  String get privacyContactBody =>
      'Məxfiliklə bağlı suallar üçün layihə repozitoriyasında issue açın.';

  @override
  String get privacyLastUpdated => 'Son yenilənmə: Mart 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Saxlama uğursuz oldu: $error';
  }

  @override
  String get themeEngineTitle => 'Tema mühərriki';

  @override
  String get torBuiltInTitle => 'Daxili Tor';

  @override
  String get torConnectedSubtitle =>
      'Qoşuldu — Nostr 127.0.0.1:9250 vasitəsilə yönləndirilir';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Qoşulur… $pct%';
  }

  @override
  String get torNotRunning =>
      'İşləmir — yenidən başlatmaq üçün keçidiciyə toxunun';

  @override
  String get torDescription =>
      'Nostr-u Tor vasitəsilə yönləndirir (senzura edilmiş şəbəkələr üçün Snowflake)';

  @override
  String get torNetworkDiagnostics => 'Şəbəkə diaqnostikası';

  @override
  String get torTransportLabel => 'Nəqliyyat: ';

  @override
  String get torPtAuto => 'Avto';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Adi';

  @override
  String get torTimeoutLabel => 'Vaxt limiti: ';

  @override
  String get torInfoDescription =>
      'Aktiv olduqda, Nostr WebSocket əlaqələri Tor (SOCKS5) vasitəsilə yönləndirilir. Tor Browser 127.0.0.1:9150 portunda dinləyir. Müstəqil tor daemon 9050 portunu istifadə edir. Firebase əlaqələrinə təsir etmir.';

  @override
  String get torRouteNostrTitle => 'Nostr-u Tor vasitəsilə yönləndir';

  @override
  String get torManagedByBuiltin => 'Daxili Tor tərəfindən idarə olunur';

  @override
  String get torActiveRouting =>
      'Aktiv — Nostr trafiki Tor vasitəsilə yönləndirilir';

  @override
  String get torDisabled => 'Deaktiv';

  @override
  String get torProxySocks5 => 'Tor proksi (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Proksi host';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser: port 9150  •  tor daemon: port 9050';

  @override
  String get torForceNostrTitle => 'Mesajları Tor vasitəsilə yönləndir';

  @override
  String get torForceNostrSubtitle =>
      'Bütün Nostr relay bağlantıları Tor vasitəsilə keçəcək. Daha yavaş, lakin IP ünvanınızı relay-lərdən gizlədir.';

  @override
  String get torForceNostrDisabled => 'Əvvəlcə Tor aktivləşdirilməlidir';

  @override
  String get torForcePulseTitle => 'Pulse relay-i Tor vasitəsilə yönləndir';

  @override
  String get torForcePulseSubtitle =>
      'Bütün Pulse relay bağlantıları Tor vasitəsilə keçəcək. Daha yavaş, lakin IP ünvanınızı serverdən gizlədir.';

  @override
  String get torForcePulseDisabled => 'Əvvəlcə Tor aktivləşdirilməlidir';

  @override
  String get i2pProxySocks5 => 'I2P proksi (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P standart olaraq 4447 portunda SOCKS5 istifadə edir. İstənilən nəqliyyatdakı istifadəçilərlə ünsiyyət qurmaq üçün I2P outproxy vasitəsilə Nostr relay-ə qoşulun (məs. relay.damus.i2p). Hər ikisi aktiv olduqda Tor üstünlük alır.';

  @override
  String get i2pRouteNostrTitle => 'Nostr-u I2P vasitəsilə yönləndir';

  @override
  String get i2pActiveRouting =>
      'Aktiv — Nostr trafiki I2P vasitəsilə yönləndirilir';

  @override
  String get i2pDisabled => 'Deaktiv';

  @override
  String get i2pProxyHostLabel => 'Proksi host';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'I2P Router standart SOCKS5 portu: 4447';

  @override
  String get customProxySocks5 => 'Fərdi proksi (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Fərdi proksi trafiki V2Ray/Xray/Shadowsocks vasitəsilə yönləndirir. CF Worker Cloudflare CDN-də şəxsi relay proksi kimi işləyir — GFW *.workers.dev görür, həqiqi relay-i yox.';

  @override
  String get customSocks5ProxyTitle => 'Fərdi SOCKS5 proksi';

  @override
  String get customProxyActive =>
      'Aktiv — trafik SOCKS5 vasitəsilə yönləndirilir';

  @override
  String get customProxyDisabled => 'Deaktiv';

  @override
  String get customProxyHostLabel => 'Proksi host';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker domeni (isteğe bağlı)';

  @override
  String get customWorkerHelpTitle =>
      'CF Worker relay-ni necə yerləşdirmək olar (pulsuz)';

  @override
  String get customWorkerScriptCopied => 'Skript kopyalandı!';

  @override
  String get customWorkerStep1 =>
      '1. dash.cloudflare.com → Workers & Pages bölməsinə keçin\n2. Create Worker → bu skripti yapışdırın:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → domeni kopyalayın (məs. my-relay.user.workers.dev)\n4. Yuxarıda domeni yapışdırın → Saxla\n\nTətbiq avtomatik qoşulur: wss://domain/?r=relay_url\nGFW görür: *.workers.dev (CF CDN) ilə əlaqə';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Qoşuldu — SOCKS5 127.0.0.1:$port ünvanında';
  }

  @override
  String get psiphonConnecting => 'Qoşulur…';

  @override
  String get psiphonNotRunning =>
      'İşləmir — yenidən başlatmaq üçün keçidiciyə toxunun';

  @override
  String get psiphonDescription =>
      'Sürətli tunel (~3 san. yükləmə, 2000+ dövri VPS)';

  @override
  String get turnCommunityServers => 'İcma TURN serverləri';

  @override
  String get turnCustomServer => 'Fərdi TURN server (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN serverləri yalnız artıq şifrələnmiş axınları relay edir (DTLS-SRTP). Relay operatoru IP-nizi və trafik həcmini görür, lakin zəngləri deşifrə edə bilməz. TURN yalnız birbaşa P2P uğursuz olduqda istifadə olunur (əlaqələrin ~15–20%-i).';

  @override
  String get turnFreeLabel => 'PULSUZ';

  @override
  String get turnServerUrlLabel => 'TURN server URL';

  @override
  String get turnServerUrlHint => 'turn:serveriniz.com:3478 və ya turns:...';

  @override
  String get turnUsernameLabel => 'İstifadəçi adı';

  @override
  String get turnPasswordLabel => 'Parol';

  @override
  String get turnOptionalHint => 'İsteğe bağlı';

  @override
  String get turnCustomInfo =>
      'Maksimum nəzarət üçün istənilən aylıq 5\$ VPS-də coturn yerləşdirin. Əlaqə məlumatları yerli olaraq saxlanılır.';

  @override
  String get themePickerAppearance => 'Görünüş';

  @override
  String get themePickerAccentColor => 'Vurğu rəngi';

  @override
  String get themeModeLight => 'Açıq';

  @override
  String get themeModeDark => 'Tünd';

  @override
  String get themeModeSystem => 'Sistem';

  @override
  String get themeDynamicPresets => 'Hazır parametrlər';

  @override
  String get themeDynamicPrimaryColor => 'Əsas rəng';

  @override
  String get themeDynamicBorderRadius => 'Haşiyə radiusu';

  @override
  String get themeDynamicFont => 'Şrift';

  @override
  String get themeDynamicAppearance => 'Görünüş';

  @override
  String get themeDynamicUiStyle => 'UI üslubu';

  @override
  String get themeDynamicUiStyleDescription =>
      'Dialoqun, keçidlərin və göstəricilərin görünüşünü idarə edir.';

  @override
  String get themeDynamicSharp => 'Kəskin';

  @override
  String get themeDynamicRound => 'Yuvarlaq';

  @override
  String get themeDynamicModeDark => 'Tünd';

  @override
  String get themeDynamicModeLight => 'Açıq';

  @override
  String get themeDynamicModeAuto => 'Avto';

  @override
  String get themeDynamicPlatformAuto => 'Avto';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'Etibarsız Firebase URL. Gözlənilən: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Etibarsız relay URL. Gözlənilən: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Etibarsız Pulse server URL. Gözlənilən: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'Server URL';

  @override
  String get providerPulseServerUrlHint => 'https://serveriniz:8443';

  @override
  String get providerPulseInviteLabel => 'Dəvət kodu';

  @override
  String get providerPulseInviteHint => 'Dəvət kodu (tələb olunarsa)';

  @override
  String get providerPulseInfo =>
      'Özünüz yerləşdirdiyiniz relay. Açarlar bərpa parolunuzdan əldə edilir.';

  @override
  String get providerScreenTitle => 'Gələn qutuları';

  @override
  String get providerSecondaryInboxesHeader => 'İKİNCİ DƏRƏCƏLİ GƏLƏN QUTULARI';

  @override
  String get providerSecondaryInboxesInfo =>
      'İkinci dərəcəli gələn qutuları ehtiyat üçün mesajları eyni vaxtda qəbul edir.';

  @override
  String get providerRemoveTooltip => 'Sil';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... və ya hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... və ya hex gizli açar';

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
  String get emojiNoRecent => 'Son istifadə edilən emoji yoxdur';

  @override
  String get emojiSearchHint => 'Emoji axtar...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Söhbət üçün toxunun';

  @override
  String get imageViewerSaveToDownloads => 'Downloads-a saxla';

  @override
  String imageViewerSavedTo(String path) {
    return '$path ünvanına saxlanıldı';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsLanguageSubtitle => 'Tətbiq interfeys dili';

  @override
  String get settingsLanguageSystem => 'Sistem standartı';

  @override
  String get onboardingLanguageTitle => 'Dilinizi seçin';

  @override
  String get onboardingLanguageSubtitle =>
      'Bunu sonra Parametrlərdən dəyişə bilərsiniz';

  @override
  String get videoNoteRecord => 'Video mesaj yaz';

  @override
  String get videoNoteTapToRecord => 'Yazmaq üçün toxunun';

  @override
  String get videoNoteTapToStop => 'Dayandırmaq üçün toxunun';

  @override
  String get videoNoteCameraPermission => 'Kamera icazəsi rədd edildi';

  @override
  String get videoNoteMaxDuration => 'Maksimum 30 saniyə';

  @override
  String get videoNoteNotSupported =>
      'Video qeydlər bu platformada dəstəklənmir';

  @override
  String get navChats => 'Söhbətlər';

  @override
  String get navUpdates => 'Yeniləmələr';

  @override
  String get navCalls => 'Zənglər';

  @override
  String get filterAll => 'Hamısı';

  @override
  String get filterUnread => 'Oxunmamış';

  @override
  String get filterGroups => 'Qruplar';

  @override
  String get callsNoRecent => 'Son zənglər yoxdur';

  @override
  String get callsEmptySubtitle => 'Zəng tarixçəniz burada görünəcək';

  @override
  String get appBarEncrypted => 'başdan-başa şifrələnmiş';

  @override
  String get newStatus => 'Yeni status';

  @override
  String get newCall => 'Yeni zəng';

  @override
  String get joinChannelTitle => 'Kanala qoşul';

  @override
  String get joinChannelDescription => 'KANAL URL';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'Kanal məlumatları alınır…';

  @override
  String get joinChannelNotFound => 'Bu URL-də kanal tapılmadı';

  @override
  String get joinChannelNetworkError => 'Serverə qoşulmaq mümkün olmadı';

  @override
  String get joinChannelAlreadyJoined => 'Artıq qoşulub';

  @override
  String get joinChannelButton => 'Qoşul';

  @override
  String get channelFeedEmpty => 'Hələ göndəriş yoxdur';

  @override
  String get channelLeave => 'Kanaldan çıx';

  @override
  String get channelLeaveConfirm =>
      'Bu kanaldan çıxmaq istəyirsiniz? Keşlənmiş göndərişlər silinəcək.';

  @override
  String get channelInfo => 'Kanal məlumatı';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'redaktə edilib';

  @override
  String get channelLoadMore => 'Daha çox yüklə';

  @override
  String get channelSearchPosts => 'Yazıları axtar…';

  @override
  String get channelNoResults => 'Uyğun yazı yoxdur';

  @override
  String get channelUrl => 'Kanal URL';

  @override
  String get channelCreated => 'Qoşulub';

  @override
  String channelPostCount(int count) {
    return '$count yazı';
  }

  @override
  String get channelCopyUrl => 'URL kopyala';

  @override
  String get setupNext => 'Növbəti';

  @override
  String get setupKeyWarning =>
      'Sizin üçün bərpa açarı yaradılacaq. Bu, hesabınızı yeni cihazda bərpa etməyin yeganə yoludur — server yoxdur, parol sıfırlama yoxdur.';

  @override
  String get setupKeyTitle => 'Bərpa Açarınız';

  @override
  String get setupKeySubtitle =>
      'Bu açarı yazın və təhlükəsiz yerdə saxlayın. Hesabınızı yeni cihazda bərpa etmək üçün lazım olacaq.';

  @override
  String get setupKeyCopied => 'Kopyalandı!';

  @override
  String get setupKeyWroteItDown => 'Yazdım';

  @override
  String get setupKeyWarnBody =>
      'Bu açarı ehtiyat nüsxə olaraq yazın. Daha sonra Parametrlər → Təhlükəsizlik bölməsində də görə bilərsiniz.';

  @override
  String get setupVerifyTitle => 'Bərpa Açarını Təsdiqlə';

  @override
  String get setupVerifySubtitle =>
      'Düzgün saxladığınızı təsdiqləmək üçün bərpa açarınızı yenidən daxil edin.';

  @override
  String get setupVerifyButton => 'Təsdiqlə';

  @override
  String get setupKeyMismatch =>
      'Açar uyğun gəlmir. Yoxlayın və yenidən cəhd edin.';

  @override
  String get setupSkipVerify => 'Təsdiqləməni keç';

  @override
  String get setupSkipVerifyTitle => 'Təsdiqləmə keçilsin?';

  @override
  String get setupSkipVerifyBody =>
      'Bərpa açarınızı itirsəniz, hesabınız bərpa edilə bilməz. Keçmək istədiyinizə əminsiniz?';

  @override
  String get setupCreatingAccount => 'Hesab yaradılır…';

  @override
  String get setupRestoringAccount => 'Hesab bərpa edilir…';

  @override
  String get restoreKeyInfoBanner =>
      'Bərpa açarınızı daxil edin — ünvanınız (Nostr + Session) avtomatik bərpa ediləcək. Kontaktlar və mesajlar yalnız yerli olaraq saxlanılıb.';

  @override
  String get restoreKeyHint => 'Bərpa açarı';

  @override
  String get settingsViewRecoveryKey => 'Bərpa Açarına Bax';

  @override
  String get settingsViewRecoveryKeySubtitle =>
      'Hesab bərpa açarınızı göstərin';

  @override
  String get settingsRecoveryKeyNotStored =>
      'Bərpa açarı mövcud deyil (bu funksiyadan əvvəl yaradılıb)';

  @override
  String get settingsRecoveryKeyWarning =>
      'Bu açarı təhlükəsiz saxlayın. Onu əldə edən hər kəs hesabınızı başqa cihazda bərpa edə bilər.';

  @override
  String get replaceIdentityTitle => 'Mövcud kimlik əvəzlənsin?';

  @override
  String get replaceIdentityBodyRestore =>
      'Bu cihazda artıq kimlik mövcuddur. Bərpa cari Nostr açarınızı və Oxen toxumunuzu qalıcı olaraq əvəzləyəcək. Bütün kontaktlar cari ünvanınıza çatma qabiliyyətini itirəcək.\n\nBu geri qaytarıla bilməz.';

  @override
  String get replaceIdentityBodyCreate =>
      'Bu cihazda artıq kimlik mövcuddur. Yenisini yaratmaq cari Nostr açarınızı və Oxen toxumunuzu qalıcı olaraq əvəzləyəcək. Bütün kontaktlar cari ünvanınıza çatma qabiliyyətini itirəcək.\n\nBu geri qaytarıla bilməz.';

  @override
  String get replace => 'Əvəzlə';

  @override
  String get callNoScreenSources => 'Mövcud ekran mənbəyi yoxdur';

  @override
  String get callScreenShareQuality => 'Ekran paylaşımı keyfiyyəti';

  @override
  String get callFrameRate => 'Kadr sürəti';

  @override
  String get callResolution => 'Həlletmə';

  @override
  String get callAutoResolution => 'Avto = yerli ekran həlletmə';

  @override
  String get callStartSharing => 'Paylaşmağa başla';

  @override
  String get callCameraUnavailable =>
      'Kamera mövcud deyil — başqa tətbiq tərəfindən istifadə oluna bilər';

  @override
  String get themeResetToDefaults => 'Standartlara sıfırla';

  @override
  String get backupSaveToDownloadsTitle => 'Ehtiyat nüsxəni Yükləmələrə saxla?';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'Fayl seçici mövcud deyil. Ehtiyat nüsxə saxlanılacaq:\n$path';
  }

  @override
  String get systemLabel => 'Sistem';

  @override
  String get next => 'Növbəti';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return 'Tərtibatçı rejimini aktivləşdirmək üçün daha $remaining toxunuş';
  }

  @override
  String get devModeEnabled => 'Tərtibatçı rejimi aktivləşdirildi';

  @override
  String get devTools => 'Tərtibatçı Alətləri';

  @override
  String get devAdapterDiagnostics => 'Adapter açarları və diaqnostika';

  @override
  String get devEnableAll => 'Hamısını aktivləşdir';

  @override
  String get devDisableAll => 'Hamısını söndür';

  @override
  String get turnUrlValidation =>
      'TURN URL turn: və ya turns: ilə başlamalıdır (maks. 512 simvol)';

  @override
  String get callMissedCall => 'Buraxılmış zəng';

  @override
  String get callOutgoingCall => 'Gedən zəng';

  @override
  String get callIncomingCall => 'Gələn zəng';

  @override
  String get mediaMissingData => 'Media məlumatları çatışmır';

  @override
  String get mediaDownloadFailed => 'Yükləmə uğursuz';

  @override
  String get mediaDecryptFailed => 'Deşifrə uğursuz';

  @override
  String get callEndCallBanner => 'Zəngi bitir';

  @override
  String get meFallback => 'Mən';

  @override
  String get imageSaveToDownloads => 'Yükləmələrə saxla';

  @override
  String imageSavedToPath(String path) {
    return '$path ünvanına saxlanıldı';
  }

  @override
  String get callScreenShareRequiresPermission =>
      'Ekran paylaşımı icazə tələb edir';

  @override
  String get callScreenShareUnavailable => 'Ekran paylaşımı mövcud deyil';

  @override
  String get statusJustNow => 'İndicə';

  @override
  String statusMinutesAgo(int minutes) {
    return '${minutes}d əvvəl';
  }

  @override
  String statusHoursAgo(int hours) {
    return '${hours}s əvvəl';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count marşrut',
      one: '1 marşrut',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => 'Əlavə etməyə hazır';

  @override
  String groupSelectedCount(int count) {
    return '$count seçilib';
  }

  @override
  String get paste => 'Yapışdır';

  @override
  String get sfuAudioOnly => 'Yalnız audio';

  @override
  String sfuParticipants(int count) {
    return '$count iştirakçı';
  }

  @override
  String get dataUnencryptedBackup => 'Şifrələnməmiş ehtiyat nüsxə';

  @override
  String get dataUnencryptedBackupBody =>
      'Bu fayl şifrələnməmiş kimlik ehtiyat nüsxəsidir və cari açarlarınızı əvəzləyəcək. Yalnız özünüz yaratdığınız faylları idxal edin. Davam edilsin?';

  @override
  String get dataImportAnyway => 'Hər halda idxal et';

  @override
  String get securityStorageError =>
      'Təhlükəsiz saxlama xətası — tətbiqi yenidən başladın';

  @override
  String get aboutDevModeActive => 'Tərtibatçı rejimi aktiv';

  @override
  String get themeColors => 'Rənglər';

  @override
  String get themePrimaryAccent => 'Əsas vurğu';

  @override
  String get themeSecondaryAccent => 'İkinci vurğu';

  @override
  String get themeBackground => 'Arxa plan';

  @override
  String get themeSurface => 'Səth';

  @override
  String get themeChatBubbles => 'Söhbət baloncukları';

  @override
  String get themeOutgoingMessage => 'Gedən mesaj';

  @override
  String get themeIncomingMessage => 'Gələn mesaj';

  @override
  String get themeShape => 'Forma';

  @override
  String get devSectionDeveloper => 'Tərtibatçı';

  @override
  String get devAdapterChannelsHint =>
      'Adapter kanalları — müəyyən nəqliyyatları test etmək üçün söndürün.';

  @override
  String get devNostrRelays => 'Nostr relay-ləri (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Session Şəbəkəsi';

  @override
  String get devPulseRelay => 'Pulse öz-hostinqli relay';

  @override
  String get devLanNetwork => 'Yerli şəbəkə (UDP/TCP)';

  @override
  String get devSectionCalls => 'Zənglər';

  @override
  String get devForceTurnRelay => 'TURN relay məcbur et';

  @override
  String get devForceTurnRelaySubtitle =>
      'P2P söndür — bütün zənglər yalnız TURN serverləri ilə';

  @override
  String get devRestartWarning =>
      '⚠ Dəyişikliklər növbəti göndərmə/zəngdə tətbiq olunacaq. Gələn üçün tətbiqi yenidən başladın.';

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
  String get pulseUseServerTitle => 'Pulse serveri istifadə edilsin?';

  @override
  String pulseUseServerBody(String name, String host) {
    return '$name $host Pulse serverindən istifadə edir. Daha sürətli söhbət üçün qoşulun (və eyni serverdəki digərləri ilə)?';
  }

  @override
  String pulseContactUsesPulse(String name) {
    return '$name Pulse istifadə edir';
  }

  @override
  String pulseJoinForFaster(String host) {
    return 'Daha sürətli söhbət üçün $host serverinə qoşulun';
  }

  @override
  String get pulseNotNow => 'İndi yox';

  @override
  String get pulseJoin => 'Qoşul';

  @override
  String get pulseDismiss => 'Bağla';

  @override
  String get pulseHide7Days => '7 gün gizlət';

  @override
  String get pulseNeverAskAgain => 'Daha soruşma';

  @override
  String get groupSearchContactsHint => 'Kontaktları axtar…';

  @override
  String get systemActorYou => 'Siz';

  @override
  String get systemActorPeer => 'Kontakt';

  @override
  String systemTtlEnabled(String actor, String duration) {
    return '$actor yox olan mesajları aktivləşdirdi: $duration';
  }

  @override
  String systemTtlDisabled(String actor) {
    return '$actor yox olan mesajları söndürdü';
  }

  @override
  String get menuClearChatHistory => 'Söhbət tarixçəsini təmizlə';

  @override
  String get clearChatTitle => 'Söhbət tarixçəsi təmizlənsin?';

  @override
  String get clearChatBody =>
      'Bu söhbətdəki bütün mesajlar bu cihazdan silinəcək. Digər şəxs öz nüsxəsini saxlayacaq.';

  @override
  String get clearChatAction => 'Təmizlə';

  @override
  String systemGroupRenamed(String actor, String name) {
    return '$actor qrupun adını \"$name\" olaraq dəyişdi';
  }

  @override
  String systemGroupAvatarChanged(String actor) {
    return '$actor qrupun şəklini dəyişdi';
  }

  @override
  String systemGroupMetaChanged(String actor, String name) {
    return '$actor qrupun adını \"$name\" olaraq dəyişdi və şəkli də dəyişdi';
  }

  @override
  String get profileInviteLink => 'Dəvət linki';

  @override
  String get profileInviteLinkSubtitle => 'Linki olan hər kəs qoşula bilər';

  @override
  String get profileInviteLinkCopied => 'Dəvət linki kopyalandı';

  @override
  String get groupInviteLinkTitle => 'Qrupa qoşulasınız?';

  @override
  String groupInviteLinkBody(String name, int count) {
    return '\"$name\" qrupuna ($count üzv) dəvət olunmusunuz.';
  }

  @override
  String get groupInviteLinkJoin => 'Qoşul';

  @override
  String get drawerCreateGroup => 'Qrup yarat';

  @override
  String get drawerJoinGroup => 'Qrupa qoşul';

  @override
  String get drawerJoinGroupByLinkInvalid => 'Bu Pulse dəvət linkinə bənzəmir';

  @override
  String get groupModeMeshTitle => 'Adi';

  @override
  String groupModeMeshSubtitle(int n) {
    return 'Serversiz, $n nəfərə qədər';
  }

  @override
  String get groupModePulseTitle => 'Pulse serveri';

  @override
  String groupModePulseSubtitle(int n) {
    return 'Server vasitəsilə, $n nəfərə qədər';
  }

  @override
  String get groupPulseServerHint => 'https://sizin-pulse-serveriniz';

  @override
  String get groupPulseServerClosed => 'Bağlı server (dəvət kodu lazımdır)';

  @override
  String get groupPulseInviteHint => 'Dəvət kodu';

  @override
  String pulseGroupForeignServerBanner(String host) {
    return 'Mesajlar $host vasitəsilə yönləndirilir (sizin Pulse serveriniz deyil)';
  }

  @override
  String groupMeshLimitReached(int n) {
    return 'Bu zəng növü $n iştirakçıya qədər məhduddur';
  }
}
