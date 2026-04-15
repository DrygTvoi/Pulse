// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Mesajlarda ara...';

  @override
  String get search => 'Ara';

  @override
  String get clearSearch => 'Aramayı temizle';

  @override
  String get closeSearch => 'Aramayı kapat';

  @override
  String get moreOptions => 'Daha fazla seçenek';

  @override
  String get back => 'Geri';

  @override
  String get cancel => 'İptal';

  @override
  String get close => 'Kapat';

  @override
  String get confirm => 'Onayla';

  @override
  String get remove => 'Kaldır';

  @override
  String get save => 'Kaydet';

  @override
  String get add => 'Ekle';

  @override
  String get copy => 'Kopyala';

  @override
  String get skip => 'Atla';

  @override
  String get done => 'Tamam';

  @override
  String get apply => 'Uygula';

  @override
  String get export => 'Dışa Aktar';

  @override
  String get import => 'İçe Aktar';

  @override
  String get homeNewGroup => 'Yeni grup';

  @override
  String get homeSettings => 'Ayarlar';

  @override
  String get homeSearching => 'Mesajlar aranıyor...';

  @override
  String get homeNoResults => 'Sonuç bulunamadı';

  @override
  String get homeNoChatHistory => 'Henüz sohbet geçmişi yok';

  @override
  String homeTransportSwitched(String address) {
    return 'Taşıyıcı değiştirildi → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name arıyor...';
  }

  @override
  String get homeAccept => 'Kabul Et';

  @override
  String get homeDecline => 'Reddet';

  @override
  String get homeLoadEarlier => 'Önceki mesajları yükle';

  @override
  String get homeChats => 'Sohbetler';

  @override
  String get homeSelectConversation => 'Bir sohbet seçin';

  @override
  String get homeNoChatsYet => 'Henüz sohbet yok';

  @override
  String get homeAddContactToStart => 'Sohbet başlatmak için bir kişi ekleyin';

  @override
  String get homeNewChat => 'Yeni Sohbet';

  @override
  String get homeNewChatTooltip => 'Yeni sohbet';

  @override
  String get homeIncomingCallTitle => 'Gelen Arama';

  @override
  String get homeIncomingGroupCallTitle => 'Gelen Grup Araması';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — gelen grup araması';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return '\"$query\" ile eşleşen sohbet yok';
  }

  @override
  String get homeSectionChats => 'Sohbetler';

  @override
  String get homeSectionMessages => 'Mesajlar';

  @override
  String get homeDbEncryptionUnavailable =>
      'Veritabanı şifreleme kullanılamıyor — tam koruma için SQLCipher yükleyin';

  @override
  String get chatFileTooLargeGroup =>
      '512 KB\'den büyük dosyalar grup sohbetlerinde desteklenmiyor';

  @override
  String get chatLargeFile => 'Büyük Dosya';

  @override
  String get chatCancel => 'İptal';

  @override
  String get chatSend => 'Gönder';

  @override
  String get chatFileTooLarge => 'Dosya çok büyük — maksimum boyut 100 MB';

  @override
  String get chatMicDenied => 'Mikrofon izni reddedildi';

  @override
  String get chatVoiceFailed =>
      'Sesli mesaj kaydedilemedi — kullanılabilir depolamayı kontrol edin';

  @override
  String get chatScheduleFuture => 'Zamanlanan saat gelecekte olmalıdır';

  @override
  String get chatToday => 'Bugün';

  @override
  String get chatYesterday => 'Dün';

  @override
  String get chatEdited => 'düzenlendi';

  @override
  String get chatYou => 'Sen';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Bu dosya $size MB. Büyük dosyalar bazı ağlarda yavaş gönderilebilir. Devam edilsin mi?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return '$name adlı kişinin güvenlik anahtarı değişti. Doğrulamak için dokunun.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return '$name için mesaj şifrelenemedi — mesaj gönderilmedi.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return '$name için güvenlik numarası değişti. Doğrulamak için dokunun.';
  }

  @override
  String get chatNoMessagesFound => 'Mesaj bulunamadı';

  @override
  String get chatMessagesE2ee => 'Mesajlar uçtan uca şifrelenmiştir';

  @override
  String get chatSayHello => 'Merhaba de';

  @override
  String get appBarOnline => 'çevrimiçi';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'yazıyor';

  @override
  String get appBarSearchMessages => 'Mesajlarda ara...';

  @override
  String get appBarMute => 'Sessize Al';

  @override
  String get appBarUnmute => 'Sesi Aç';

  @override
  String get appBarMedia => 'Medya';

  @override
  String get appBarDisappearing => 'Kaybolan mesajlar';

  @override
  String get appBarDisappearingOn => 'Kaybolan: açık';

  @override
  String get appBarGroupSettings => 'Grup ayarları';

  @override
  String get appBarSearchTooltip => 'Mesajlarda ara';

  @override
  String get appBarVoiceCall => 'Sesli arama';

  @override
  String get appBarVideoCall => 'Görüntülü arama';

  @override
  String get inputMessage => 'Mesaj...';

  @override
  String get inputAttachFile => 'Dosya ekle';

  @override
  String get inputSendMessage => 'Mesaj gönder';

  @override
  String get inputRecordVoice => 'Sesli mesaj kaydet';

  @override
  String get inputSendVoice => 'Sesli mesaj gönder';

  @override
  String get inputCancelReply => 'Yanıtı iptal et';

  @override
  String get inputCancelEdit => 'Düzenlemeyi iptal et';

  @override
  String get inputCancelRecording => 'Kaydı iptal et';

  @override
  String get inputRecording => 'Kaydediliyor…';

  @override
  String get inputEditingMessage => 'Mesaj düzenleniyor';

  @override
  String get inputPhoto => 'Fotoğraf';

  @override
  String get inputVoiceMessage => 'Sesli mesaj';

  @override
  String get inputFile => 'Dosya';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zamanlanmış mesaj',
      one: '$count zamanlanmış mesaj',
    );
    return '$_temp0';
  }

  @override
  String get callInitializing => 'Arama başlatılıyor…';

  @override
  String get callConnecting => 'Bağlanıyor…';

  @override
  String get callConnectingRelay => 'Bağlanıyor (aktarma)…';

  @override
  String get callSwitchingRelay => 'Aktarma moduna geçiliyor…';

  @override
  String get callConnectionFailed => 'Bağlantı başarısız';

  @override
  String get callReconnecting => 'Yeniden bağlanıyor…';

  @override
  String get callEnded => 'Arama sona erdi';

  @override
  String get callLive => 'Canlı';

  @override
  String get callEnd => 'Bitir';

  @override
  String get callEndCall => 'Aramayı bitir';

  @override
  String get callMute => 'Sessize Al';

  @override
  String get callUnmute => 'Sesi Aç';

  @override
  String get callSpeaker => 'Hoparlör';

  @override
  String get callCameraOn => 'Kamera Açık';

  @override
  String get callCameraOff => 'Kamera Kapalı';

  @override
  String get callShareScreen => 'Ekran Paylaş';

  @override
  String get callStopShare => 'Paylaşımı Durdur';

  @override
  String callTorBackup(String duration) {
    return 'Tor yedek · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor yedek aktif — birincil yol kullanılamıyor';

  @override
  String get callDirectFailed =>
      'Doğrudan bağlantı başarısız — aktarma moduna geçiliyor…';

  @override
  String get callTurnUnreachable =>
      'TURN sunucularına ulaşılamıyor. Ayarlar → Gelişmiş bölümünden özel bir TURN ekleyin.';

  @override
  String get callRelayMode => 'Aktarma modu aktif (kısıtlı ağ)';

  @override
  String get callStarting => 'Arama başlatılıyor…';

  @override
  String get callConnectingToGroup => 'Gruba bağlanılıyor…';

  @override
  String get callGroupOpenedInBrowser => 'Grup araması tarayıcıda açıldı';

  @override
  String get callCouldNotOpenBrowser => 'Tarayıcı açılamadı';

  @override
  String get callInviteLinkSent =>
      'Davet bağlantısı tüm grup üyelerine gönderildi.';

  @override
  String get callOpenLinkManually =>
      'Yukarıdaki bağlantıyı elle açın veya tekrar denemek için dokunun.';

  @override
  String get callJitsiNotE2ee => 'Jitsi aramaları uçtan uca şifreli DEĞİLDİR';

  @override
  String get callRetryOpenBrowser => 'Tarayıcıyı tekrar aç';

  @override
  String get callClose => 'Kapat';

  @override
  String get callCamOn => 'Kamera açık';

  @override
  String get callCamOff => 'Kamera kapalı';

  @override
  String get noConnection => 'Bağlantı yok — mesajlar kuyruğa alınacak';

  @override
  String get connected => 'Bağlı';

  @override
  String get connecting => 'Bağlanıyor…';

  @override
  String get disconnected => 'Bağlantı kesildi';

  @override
  String get offlineBanner =>
      'Bağlantı yok — mesajlar kuyruğa alınacak ve çevrimiçi olunca gönderilecek';

  @override
  String get lanModeBanner => 'LAN Modu — İnternet yok · Yalnızca yerel ağ';

  @override
  String get probeCheckingNetwork => 'Ağ bağlantısı kontrol ediliyor…';

  @override
  String get probeDiscoveringRelays =>
      'Topluluk dizinleri aracılığıyla aktarıcılar keşfediliyor…';

  @override
  String get probeStartingTor => 'Tor başlatılıyor…';

  @override
  String get probeFindingRelaysTor =>
      'Tor üzerinden erişilebilir aktarıcılar aranıyor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktarıcı',
      one: '$count aktarıcı',
    );
    return 'Ağ hazır — $_temp0 bulundu';
  }

  @override
  String get probeNoRelaysFound =>
      'Erişilebilir aktarıcı bulunamadı — mesajlar gecikebilir';

  @override
  String get jitsiWarningTitle => 'Uçtan uca şifreli değil';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet aramaları Pulse tarafından şifrelenmez. Yalnızca hassas olmayan görüşmeler için kullanın.';

  @override
  String get jitsiConfirm => 'Yine de katıl';

  @override
  String get jitsiGroupWarningTitle => 'Uçtan uca şifreli değil';

  @override
  String get jitsiGroupWarningBody =>
      'Bu aramanın katılımcı sayısı yerleşik şifreli ağ için çok fazla.\n\nTarayıcınızda bir Jitsi Meet bağlantısı açılacak. Jitsi uçtan uca şifreli DEĞİLDİR — sunucu aramanızı görebilir.';

  @override
  String get jitsiContinueAnyway => 'Yine de devam et';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get setupCreateAnonymousAccount => 'Anonim hesap oluştur';

  @override
  String get setupTapToChangeColor => 'Renk değiştirmek için dokunun';

  @override
  String get setupReqMinLength => 'En az 16 karakter';

  @override
  String get setupReqVariety =>
      '4\'ten 3\'ü: büyük harf, küçük harf, rakam, sembol';

  @override
  String get setupReqMatch => 'Parolalar eşleşiyor';

  @override
  String get setupYourNickname => 'Takma adınız';

  @override
  String get setupRecoveryPassword => 'Kurtarma parolası (min. 16)';

  @override
  String get setupConfirmPassword => 'Parolayı onayla';

  @override
  String get setupMin16Chars => 'En az 16 karakter';

  @override
  String get setupPasswordsDoNotMatch => 'Parolalar eşleşmiyor';

  @override
  String get setupEntropyWeak => 'Zayıf';

  @override
  String get setupEntropyOk => 'İyi';

  @override
  String get setupEntropyStrong => 'Güçlü';

  @override
  String get setupEntropyWeakNeedsVariety => 'Zayıf (3 karakter türü gerekli)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bit)';
  }

  @override
  String get setupPasswordWarning =>
      'Bu parola hesabınızı kurtarmanın tek yoludur. Sunucu yok — parola sıfırlama yok. Hatırlayın veya yazın.';

  @override
  String get setupCreateAccount => 'Hesap oluştur';

  @override
  String get setupAlreadyHaveAccount => 'Zaten bir hesabınız var mı? ';

  @override
  String get setupRestore => 'Kurtar →';

  @override
  String get restoreTitle => 'Hesabı kurtar';

  @override
  String get restoreInfoBanner =>
      'Kurtarma parolanızı girin — adresiniz (Nostr + Session) otomatik olarak geri yüklenecek. Kişiler ve mesajlar yalnızca yerel olarak saklanmıştı.';

  @override
  String get restoreNewNickname =>
      'Yeni takma ad (daha sonra değiştirilebilir)';

  @override
  String get restoreButton => 'Hesabı kurtar';

  @override
  String get lockTitle => 'Pulse kilitli';

  @override
  String get lockSubtitle => 'Devam etmek için parolanızı girin';

  @override
  String get lockPasswordHint => 'Parola';

  @override
  String get lockUnlock => 'Kilidi Aç';

  @override
  String get lockPanicHint =>
      'Parolanızı mı unuttunuz? Tüm verileri silmek için panik anahtarınızı girin.';

  @override
  String get lockTooManyAttempts => 'Çok fazla deneme. Tüm veriler siliniyor…';

  @override
  String get lockWrongPassword => 'Yanlış parola';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Yanlış parola — $attempts/$max deneme';
  }

  @override
  String get onboardingSkip => 'Atla';

  @override
  String get onboardingNext => 'İleri';

  @override
  String get onboardingGetStarted => 'Hesap Oluştur';

  @override
  String get onboardingWelcomeTitle => 'Pulse\'a Hoş Geldiniz';

  @override
  String get onboardingWelcomeBody =>
      'Merkezi olmayan, uçtan uca şifreli bir mesajlaşma uygulaması.\n\nMerkezi sunucu yok. Veri toplama yok. Arka kapı yok.\nKonuşmalarınız yalnızca size aittir.';

  @override
  String get onboardingTransportTitle => 'Taşıyıcı Bağımsız';

  @override
  String get onboardingTransportBody =>
      'Firebase, Nostr veya her ikisini aynı anda kullanın.\n\nMesajlar ağlar arasında otomatik olarak yönlendirilir. Sansür direnci için yerleşik Tor ve I2P desteği.';

  @override
  String get onboardingSignalTitle => 'Signal + Kuantum Sonrası';

  @override
  String get onboardingSignalBody =>
      'Her mesaj, ileri gizlilik için Signal Protocol (Double Ratchet + X3DH) ile şifrelenir.\n\nAyrıca Kyber-1024 — NIST standardı kuantum sonrası algoritma — ile sarılır ve gelecekteki kuantum bilgisayarlara karşı koruma sağlar.';

  @override
  String get onboardingKeysTitle => 'Anahtarlarınız Sizin';

  @override
  String get onboardingKeysBody =>
      'Kimlik anahtarlarınız cihazınızdan asla ayrılmaz.\n\nSignal parmak izleri, kişileri bant dışı doğrulamanıza olanak tanır. TOFU (İlk Kullanımda Güven) anahtar değişikliklerini otomatik olarak algılar.';

  @override
  String get onboardingThemeTitle => 'Görünümünüzü Seçin';

  @override
  String get onboardingThemeBody =>
      'Bir tema ve vurgu rengi seçin. Bunu daha sonra Ayarlar\'dan değiştirebilirsiniz.';

  @override
  String get contactsNewChat => 'Yeni sohbet';

  @override
  String get contactsAddContact => 'Kişi ekle';

  @override
  String get contactsSearchHint => 'Ara...';

  @override
  String get contactsNewGroup => 'Yeni grup';

  @override
  String get contactsNoContactsYet => 'Henüz kişi yok';

  @override
  String get contactsAddHint =>
      'Birinin adresini eklemek için + düğmesine dokunun';

  @override
  String get contactsNoMatch => 'Eşleşen kişi yok';

  @override
  String get contactsRemoveTitle => 'Kişiyi kaldır';

  @override
  String contactsRemoveMessage(String name) {
    return '$name kaldırılsın mı?';
  }

  @override
  String get contactsRemove => 'Kaldır';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kişi',
      one: '$count kişi',
    );
    return '$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Bağlantıyı Aç';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Bu URL tarayıcınızda açılsın mı?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Aç';

  @override
  String get bubbleSecurityWarning => 'Güvenlik Uyarısı';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" çalıştırılabilir bir dosya türüdür. Kaydetmek ve çalıştırmak cihazınıza zarar verebilir. Yine de kaydedilsin mi?';
  }

  @override
  String get bubbleSaveAnyway => 'Yine de Kaydet';

  @override
  String bubbleSavedTo(String path) {
    return '$path konumuna kaydedildi';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Kaydetme başarısız: $error';
  }

  @override
  String get bubbleNotEncrypted => 'ŞİFRELENMEMİŞ';

  @override
  String get bubbleCorruptedImage => '[Bozuk görüntü]';

  @override
  String get bubbleReplyPhoto => 'Fotoğraf';

  @override
  String get bubbleReplyVoice => 'Sesli mesaj';

  @override
  String get bubbleReplyVideo => 'Görüntülü mesaj';

  @override
  String bubbleReadBy(String names) {
    return '$names tarafından okundu';
  }

  @override
  String bubbleReadByCount(int count) {
    return '$count kişi tarafından okundu';
  }

  @override
  String get chatTileTapToStart => 'Sohbet başlatmak için dokunun';

  @override
  String get chatTileMessageSent => 'Mesaj gönderildi';

  @override
  String get chatTileEncryptedMessage => 'Şifreli mesaj';

  @override
  String chatTileYouPrefix(String text) {
    return 'Sen: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Sesli mesaj';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Sesli mesaj ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Şifreli mesaj';

  @override
  String get groupNewGroup => 'Yeni Grup';

  @override
  String get groupGroupName => 'Grup adı';

  @override
  String get groupSelectMembers => 'Üye seçin (min 2)';

  @override
  String get groupNoContactsYet => 'Henüz kişi yok. Önce kişi ekleyin.';

  @override
  String get groupCreate => 'Oluştur';

  @override
  String get groupLabel => 'Grup';

  @override
  String get profileVerifyIdentity => 'Kimliği Doğrula';

  @override
  String profileVerifyInstructions(String name) {
    return 'Bu parmak izlerini $name ile sesli arama veya yüz yüze karşılaştırın. Her iki değer de her iki cihazda eşleşiyorsa \"Doğrulanmış Olarak İşaretle\"ye dokunun.';
  }

  @override
  String get profileTheirKey => 'Onların anahtarı';

  @override
  String get profileYourKey => 'Sizin anahtarınız';

  @override
  String get profileRemoveVerification => 'Doğrulamayı Kaldır';

  @override
  String get profileMarkAsVerified => 'Doğrulanmış Olarak İşaretle';

  @override
  String get profileAddressCopied => 'Adres kopyalandı';

  @override
  String get profileNoContactsToAdd => 'Eklenecek kişi yok — tümü zaten üye';

  @override
  String get profileAddMembers => 'Üye Ekle';

  @override
  String profileAddCount(int count) {
    return 'Ekle ($count)';
  }

  @override
  String get profileRenameGroup => 'Grubu Yeniden Adlandır';

  @override
  String get profileRename => 'Yeniden Adlandır';

  @override
  String get profileRemoveMember => 'Üye kaldırılsın mı?';

  @override
  String profileRemoveMemberBody(String name) {
    return '$name bu gruptan kaldırılsın mı?';
  }

  @override
  String get profileKick => 'Çıkar';

  @override
  String get profileSignalFingerprints => 'Signal Parmak İzleri';

  @override
  String get profileVerified => 'DOĞRULANDI';

  @override
  String get profileVerify => 'Doğrula';

  @override
  String get profileEdit => 'Düzenle';

  @override
  String get profileNoSession =>
      'Henüz oturum kurulmadı — önce bir mesaj gönderin.';

  @override
  String get profileFingerprintCopied => 'Parmak izi kopyalandı';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count üye',
      one: '$count üye',
    );
    return '$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Güvenlik Numarasını Doğrula';

  @override
  String get profileShowContactQr => 'Kişi QR\'ını Göster';

  @override
  String profileContactAddress(String name) {
    return '$name Adresi';
  }

  @override
  String get profileExportChatHistory => 'Sohbet Geçmişini Dışa Aktar';

  @override
  String profileSavedTo(String path) {
    return '$path konumuna kaydedildi';
  }

  @override
  String get profileExportFailed => 'Dışa aktarma başarısız';

  @override
  String get profileClearChatHistory => 'Sohbet geçmişini temizle';

  @override
  String get profileDeleteGroup => 'Grubu sil';

  @override
  String get profileDeleteContact => 'Kişiyi sil';

  @override
  String get profileLeaveGroup => 'Gruptan ayrıl';

  @override
  String get profileLeaveGroupBody =>
      'Bu gruptan çıkarılacaksınız ve kişilerinizden silinecektir.';

  @override
  String get groupInviteTitle => 'Grup daveti';

  @override
  String groupInviteBody(String from, String group) {
    return '$from sizi \"$group\" grubuna katılmaya davet etti';
  }

  @override
  String get groupInviteAccept => 'Kabul Et';

  @override
  String get groupInviteDecline => 'Reddet';

  @override
  String get groupMemberLimitTitle => 'Çok fazla katılımcı';

  @override
  String groupMemberLimitBody(int count) {
    return 'Bu grupta $count katılımcı olacak. Şifreli ağ aramaları en fazla 6 kişiyi destekler. Daha büyük gruplar Jitsi\'ye (E2EE değil) geçer.';
  }

  @override
  String get groupMemberLimitContinue => 'Yine de ekle';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name, \"$group\" grubuna katılmayı reddetti';
  }

  @override
  String get transferTitle => 'Başka Bir Cihaza Aktar';

  @override
  String get transferInfoBox =>
      'Signal kimliğinizi ve Nostr anahtarlarınızı yeni bir cihaza taşıyın.\nSohbet oturumları aktarılmaz — ileri gizlilik korunur.';

  @override
  String get transferSendFromThis => 'Bu cihazdan gönder';

  @override
  String get transferSendSubtitle =>
      'Bu cihazda anahtarlar var. Yeni cihazla bir kod paylaşın.';

  @override
  String get transferReceiveOnThis => 'Bu cihazda al';

  @override
  String get transferReceiveSubtitle =>
      'Bu yeni cihaz. Eski cihazdan kodu girin.';

  @override
  String get transferChooseMethod => 'Aktarma Yöntemini Seçin';

  @override
  String get transferLan => 'LAN (Aynı Ağ)';

  @override
  String get transferLanSubtitle =>
      'Hızlı, doğrudan. Her iki cihaz da aynı Wi-Fi\'da olmalıdır.';

  @override
  String get transferNostrRelay => 'Nostr Aktarıcı';

  @override
  String get transferNostrRelaySubtitle =>
      'Mevcut bir Nostr aktarıcısı kullanarak herhangi bir ağ üzerinden çalışır.';

  @override
  String get transferRelayUrl => 'Aktarıcı URL\'si';

  @override
  String get transferEnterCode => 'Aktarma Kodunu Girin';

  @override
  String get transferPasteCode =>
      'LAN:... veya NOS:... kodunu buraya yapıştırın';

  @override
  String get transferConnect => 'Bağlan';

  @override
  String get transferGenerating => 'Aktarma kodu oluşturuluyor…';

  @override
  String get transferShareCode => 'Bu kodu alıcıyla paylaşın:';

  @override
  String get transferCopyCode => 'Kodu Kopyala';

  @override
  String get transferCodeCopied => 'Kod panoya kopyalandı';

  @override
  String get transferWaitingReceiver => 'Alıcının bağlanması bekleniyor…';

  @override
  String get transferConnectingSender => 'Gönderene bağlanılıyor…';

  @override
  String get transferVerifyBoth =>
      'Bu kodu her iki cihazda karşılaştırın.\nEşleşiyorsa aktarma güvenlidir.';

  @override
  String get transferComplete => 'Aktarma Tamamlandı';

  @override
  String get transferKeysImported => 'Anahtarlar İçe Aktarıldı';

  @override
  String get transferCompleteSenderBody =>
      'Anahtarlarınız bu cihazda aktif kalmaya devam ediyor.\nAlıcı artık kimliğinizi kullanabilir.';

  @override
  String get transferCompleteReceiverBody =>
      'Anahtarlar başarıyla içe aktarıldı.\nYeni kimliği uygulamak için uygulamayı yeniden başlatın.';

  @override
  String get transferRestartApp => 'Uygulamayı Yeniden Başlat';

  @override
  String get transferFailed => 'Aktarma Başarısız';

  @override
  String get transferTryAgain => 'Tekrar Dene';

  @override
  String get transferEnterRelayFirst => 'Önce bir aktarıcı URL\'si girin';

  @override
  String get transferPasteCodeFromSender =>
      'Gönderenin aktarma kodunu yapıştırın';

  @override
  String get menuReply => 'Yanıtla';

  @override
  String get menuForward => 'İlet';

  @override
  String get menuReact => 'Tepki Ver';

  @override
  String get menuCopy => 'Kopyala';

  @override
  String get menuEdit => 'Düzenle';

  @override
  String get menuRetry => 'Tekrar Dene';

  @override
  String get menuCancelScheduled => 'Zamanlanmışı iptal et';

  @override
  String get menuDelete => 'Sil';

  @override
  String get menuForwardTo => 'İlet…';

  @override
  String menuForwardedTo(String name) {
    return '$name adlı kişiye iletildi';
  }

  @override
  String get menuScheduledMessages => 'Zamanlanmış mesajlar';

  @override
  String get menuNoScheduledMessages => 'Zamanlanmış mesaj yok';

  @override
  String menuSendsOn(String date) {
    return '$date tarihinde gönderilecek';
  }

  @override
  String get menuDisappearingMessages => 'Kaybolan Mesajlar';

  @override
  String get menuDisappearingSubtitle =>
      'Mesajlar seçilen süreden sonra otomatik olarak silinir.';

  @override
  String get menuTtlOff => 'Kapalı';

  @override
  String get menuTtl1h => '1 saat';

  @override
  String get menuTtl24h => '24 saat';

  @override
  String get menuTtl7d => '7 gün';

  @override
  String get menuAttachPhoto => 'Fotoğraf';

  @override
  String get menuAttachFile => 'Dosya';

  @override
  String get menuAttachVideo => 'Video';

  @override
  String get mediaTitle => 'Medya';

  @override
  String get mediaFileLabel => 'DOSYA';

  @override
  String mediaPhotosTab(int count) {
    return 'Fotoğraflar ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Dosyalar ($count)';
  }

  @override
  String get mediaNoPhotos => 'Henüz fotoğraf yok';

  @override
  String get mediaNoFiles => 'Henüz dosya yok';

  @override
  String mediaSavedToDownloads(String name) {
    return 'İndirilenler/$name konumuna kaydedildi';
  }

  @override
  String get mediaFailedToSave => 'Dosya kaydedilemedi';

  @override
  String get statusNewStatus => 'Yeni Durum';

  @override
  String get statusPublish => 'Yayınla';

  @override
  String get statusExpiresIn24h => 'Durum 24 saat içinde sona erer';

  @override
  String get statusWhatsOnYourMind => 'Aklınızdan ne geçiyor?';

  @override
  String get statusPhotoAttached => 'Fotoğraf eklendi';

  @override
  String get statusAttachPhoto => 'Fotoğraf ekle (isteğe bağlı)';

  @override
  String get statusEnterText => 'Lütfen durumunuz için bir metin girin.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Fotoğraf seçilemedi: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Yayınlama başarısız: $error';
  }

  @override
  String get panicSetPanicKey => 'Panik Anahtarı Ayarla';

  @override
  String get panicEmergencySelfDestruct => 'Acil durum kendini imha';

  @override
  String get panicIrreversible => 'Bu işlem geri alınamaz';

  @override
  String get panicWarningBody =>
      'Bu anahtarı kilit ekranında girmek TÜM verileri anında siler — mesajlar, kişiler, anahtarlar, kimlik. Normal parolanızdan farklı bir anahtar kullanın.';

  @override
  String get panicKeyHint => 'Panik anahtarı';

  @override
  String get panicConfirmHint => 'Panik anahtarını onayla';

  @override
  String get panicMinChars => 'Panik anahtarı en az 8 karakter olmalıdır';

  @override
  String get panicKeysDoNotMatch => 'Anahtarlar eşleşmiyor';

  @override
  String get panicSetFailed =>
      'Panik anahtarı kaydedilemedi — lütfen tekrar deneyin';

  @override
  String get passwordSetAppPassword => 'Uygulama Parolası Ayarla';

  @override
  String get passwordProtectsMessages => 'Mesajlarınızı korur';

  @override
  String get passwordInfoBanner =>
      'Pulse\'u her açtığınızda gereklidir. Unutursanız verileriniz kurtarılamaz.';

  @override
  String get passwordHint => 'Parola';

  @override
  String get passwordConfirmHint => 'Parolayı onayla';

  @override
  String get passwordSetButton => 'Parolayı Ayarla';

  @override
  String get passwordSkipForNow => 'Şimdilik atla';

  @override
  String get passwordMinChars => 'Parola en az 8 karakter olmalıdır';

  @override
  String get passwordNeedsVariety => 'Harf, rakam ve özel karakter içermelidir';

  @override
  String get passwordRequirements =>
      'Min. 8 karakter harf, rakam ve özel karakter ile';

  @override
  String get passwordsDoNotMatch => 'Parolalar eşleşmiyor';

  @override
  String get profileCardSaved => 'Profil kaydedildi!';

  @override
  String get profileCardE2eeIdentity => 'E2EE Kimliği';

  @override
  String get profileCardDisplayName => 'Görünen Ad';

  @override
  String get profileCardDisplayNameHint => 'örn. Ahmet Yılmaz';

  @override
  String get profileCardAbout => 'Hakkında';

  @override
  String get profileCardSaveProfile => 'Profili Kaydet';

  @override
  String get profileCardYourName => 'Adınız';

  @override
  String get profileCardAddressCopied => 'Adres kopyalandı!';

  @override
  String get profileCardInboxAddress => 'Gelen Kutusu Adresiniz';

  @override
  String get profileCardInboxAddresses => 'Gelen Kutusu Adresleriniz';

  @override
  String get profileCardShareAllAddresses =>
      'Tüm Adresleri Paylaş (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Kişilerle paylaşın, size mesaj atabilsinler.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Tüm $count adres tek bağlantı olarak kopyalandı!';
  }

  @override
  String get settingsMyProfile => 'Profilim';

  @override
  String get settingsYourInboxAddress => 'Gelen Kutusu Adresiniz';

  @override
  String get settingsMyQrCode => 'Kişiyi paylaş';

  @override
  String get settingsMyQrSubtitle =>
      'Adresiniz için QR kodu ve davet bağlantısı';

  @override
  String get settingsShareMyAddress => 'Adresimi Paylaş';

  @override
  String get settingsNoAddressYet => 'Henüz adres yok — önce ayarları kaydedin';

  @override
  String get settingsInviteLink => 'Davet Bağlantısı';

  @override
  String get settingsRawAddress => 'Ham Adres';

  @override
  String get settingsCopyLink => 'Bağlantıyı Kopyala';

  @override
  String get settingsCopyAddress => 'Adresi Kopyala';

  @override
  String get settingsInviteLinkCopied => 'Davet bağlantısı kopyalandı';

  @override
  String get settingsAppearance => 'Görünüm';

  @override
  String get settingsThemeEngine => 'Tema Motoru';

  @override
  String get settingsThemeEngineSubtitle =>
      'Renkleri ve yazı tiplerini özelleştirin';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle =>
      'E2EE anahtarları güvenli şekilde saklanır';

  @override
  String get settingsActive => 'AKTİF';

  @override
  String get settingsIdentityBackup => 'Kimlik Yedeği';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Signal kimliğinizi dışa veya içe aktarın';

  @override
  String get settingsIdentityBackupBody =>
      'Signal kimlik anahtarlarınızı bir yedek koda aktarın veya mevcut birinden geri yükleyin.';

  @override
  String get settingsTransferDevice => 'Başka Bir Cihaza Aktar';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Kimliğinizi LAN veya Nostr aktarıcı üzerinden taşıyın';

  @override
  String get settingsExportIdentity => 'Kimliği Dışa Aktar';

  @override
  String get settingsExportIdentityBody =>
      'Bu yedek kodu kopyalayın ve güvenli bir yerde saklayın:';

  @override
  String get settingsSaveFile => 'Dosyayı Kaydet';

  @override
  String get settingsImportIdentity => 'Kimliği İçe Aktar';

  @override
  String get settingsImportIdentityBody =>
      'Yedek kodunuzu aşağıya yapıştırın. Bu, mevcut kimliğinizin üzerine yazacaktır.';

  @override
  String get settingsPasteBackupCode => 'Yedek kodu buraya yapıştırın…';

  @override
  String get settingsIdentityImported =>
      'Kimlik + kişiler içe aktarıldı! Uygulamak için uygulamayı yeniden başlatın.';

  @override
  String get settingsSecurity => 'Güvenlik';

  @override
  String get settingsAppPassword => 'Uygulama Parolası';

  @override
  String get settingsPasswordEnabled => 'Etkin — her başlatmada gerekli';

  @override
  String get settingsPasswordDisabled =>
      'Devre dışı — uygulama parolasız açılır';

  @override
  String get settingsChangePassword => 'Parolayı Değiştir';

  @override
  String get settingsChangePasswordSubtitle =>
      'Uygulama kilidi parolanızı güncelleyin';

  @override
  String get settingsSetPanicKey => 'Panik Anahtarı Ayarla';

  @override
  String get settingsChangePanicKey => 'Panik Anahtarını Değiştir';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Acil durum silme anahtarını güncelle';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Tüm verileri anında silen bir anahtar';

  @override
  String get settingsRemovePanicKey => 'Panik Anahtarını Kaldır';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Acil durum kendini imhayı devre dışı bırak';

  @override
  String get settingsRemovePanicKeyBody =>
      'Acil durum kendini imha devre dışı bırakılacak. İstediğiniz zaman tekrar etkinleştirebilirsiniz.';

  @override
  String get settingsDisableAppPassword =>
      'Uygulama Parolasını Devre Dışı Bırak';

  @override
  String get settingsEnterCurrentPassword =>
      'Onaylamak için mevcut parolanızı girin';

  @override
  String get settingsCurrentPassword => 'Mevcut parola';

  @override
  String get settingsIncorrectPassword => 'Yanlış parola';

  @override
  String get settingsPasswordUpdated => 'Parola güncellendi';

  @override
  String get settingsChangePasswordProceed =>
      'Devam etmek için mevcut parolanızı girin';

  @override
  String get settingsData => 'Veri';

  @override
  String get settingsBackupMessages => 'Mesajları Yedekle';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Şifreli mesaj geçmişini bir dosyaya aktar';

  @override
  String get settingsRestoreMessages => 'Mesajları Geri Yükle';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Bir yedek dosyasından mesajları içe aktar';

  @override
  String get settingsExportKeys => 'Anahtarları Dışa Aktar';

  @override
  String get settingsExportKeysSubtitle =>
      'Kimlik anahtarlarını şifreli bir dosyaya kaydet';

  @override
  String get settingsImportKeys => 'Anahtarları İçe Aktar';

  @override
  String get settingsImportKeysSubtitle =>
      'Dışa aktarılmış dosyadan kimlik anahtarlarını geri yükle';

  @override
  String get settingsBackupPassword => 'Yedek parolası';

  @override
  String get settingsPasswordCannotBeEmpty => 'Parola boş olamaz';

  @override
  String get settingsPasswordMin4Chars => 'Parola en az 4 karakter olmalıdır';

  @override
  String get settingsCallsTurn => 'Aramalar ve TURN';

  @override
  String get settingsLocalNetwork => 'Yerel Ağ';

  @override
  String get settingsCensorshipResistance => 'Sansür Direnci';

  @override
  String get settingsNetwork => 'Ağ';

  @override
  String get settingsProxyTunnels => 'Proxy ve Tüneller';

  @override
  String get settingsTurnServers => 'TURN Sunucuları';

  @override
  String get settingsProviderTitle => 'Sağlayıcı';

  @override
  String get settingsLanFallback => 'LAN Yedek';

  @override
  String get settingsLanFallbackSubtitle =>
      'İnternet kullanılamadığında yerel ağda varlık yayınla ve mesajları ilet. Güvenilmeyen ağlarda (herkese açık Wi-Fi) devre dışı bırakın.';

  @override
  String get settingsBgDelivery => 'Arka Plan Teslimi';

  @override
  String get settingsBgDeliverySubtitle =>
      'Uygulama simge durumuna küçültüldüğünde mesaj almaya devam edin. Kalıcı bir bildirim gösterir.';

  @override
  String get settingsYourInboxProvider => 'Gelen Kutusu Sağlayıcınız';

  @override
  String get settingsConnectionDetails => 'Bağlantı Detayları';

  @override
  String get settingsSaveAndConnect => 'Kaydet ve Bağlan';

  @override
  String get settingsSecondaryInboxes => 'İkincil Gelen Kutuları';

  @override
  String get settingsAddSecondaryInbox => 'İkincil Gelen Kutusu Ekle';

  @override
  String get settingsAdvanced => 'Gelişmiş';

  @override
  String get settingsDiscover => 'Keşfet';

  @override
  String get settingsAbout => 'Hakkında';

  @override
  String get settingsPrivacyPolicy => 'Gizlilik Politikası';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Pulse verilerinizi nasıl koruyor';

  @override
  String get settingsCrashReporting => 'Çökme raporlama';

  @override
  String get settingsCrashReportingSubtitle =>
      'Pulse\'u iyileştirmek için anonim çökme raporları gönderin. Mesaj içeriği veya kişiler asla gönderilmez.';

  @override
  String get settingsCrashReportingEnabled =>
      'Çökme raporlama etkinleştirildi — uygulamak için uygulamayı yeniden başlatın';

  @override
  String get settingsCrashReportingDisabled =>
      'Çökme raporlama devre dışı bırakıldı — uygulamak için uygulamayı yeniden başlatın';

  @override
  String get settingsSensitiveOperation => 'Hassas İşlem';

  @override
  String get settingsSensitiveOperationBody =>
      'Bu anahtarlar kimliğinizdir. Bu dosyaya sahip olan herkes sizi taklit edebilir. Güvenli bir yerde saklayın ve aktarımdan sonra silin.';

  @override
  String get settingsIUnderstandContinue => 'Anlıyorum, Devam Et';

  @override
  String get settingsReplaceIdentity => 'Kimlik Değiştirilsin mi?';

  @override
  String get settingsReplaceIdentityBody =>
      'Bu, mevcut kimlik anahtarlarınızın üzerine yazacaktır. Mevcut Signal oturumlarınız geçersiz olacak ve kişilerin şifrelemeyi yeniden kurması gerekecek. Uygulamanın yeniden başlatılması gerekir.';

  @override
  String get settingsReplaceKeys => 'Anahtarları Değiştir';

  @override
  String get settingsKeysImported => 'Anahtarlar İçe Aktarıldı';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count anahtar başarıyla içe aktarıldı. Yeni kimlikle başlatmak için lütfen uygulamayı yeniden başlatın.';
  }

  @override
  String get settingsRestartNow => 'Şimdi Yeniden Başlat';

  @override
  String get settingsLater => 'Daha Sonra';

  @override
  String get profileGroupLabel => 'Grup';

  @override
  String get profileAddButton => 'Ekle';

  @override
  String get profileKickButton => 'Çıkar';

  @override
  String get dataSectionTitle => 'Veri';

  @override
  String get dataBackupMessages => 'Mesajları Yedekle';

  @override
  String get dataBackupPasswordSubtitle =>
      'Mesaj yedeğinizi şifrelemek için bir parola seçin.';

  @override
  String get dataBackupConfirmLabel => 'Yedek Oluştur';

  @override
  String get dataCreatingBackup => 'Yedek Oluşturuluyor';

  @override
  String get dataBackupPreparing => 'Hazırlanıyor...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Mesaj $done/$total dışa aktarılıyor...';
  }

  @override
  String get dataBackupSavingFile => 'Dosya kaydediliyor...';

  @override
  String get dataSaveMessageBackupDialog => 'Mesaj Yedeğini Kaydet';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Yedek kaydedildi ($count mesaj)\n$path';
  }

  @override
  String get dataBackupFailed => 'Yedekleme başarısız — veri dışa aktarılamadı';

  @override
  String dataBackupFailedError(String error) {
    return 'Yedekleme başarısız: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Mesaj Yedeğini Seç';

  @override
  String get dataInvalidBackupFile => 'Geçersiz yedek dosyası (çok küçük)';

  @override
  String get dataNotValidBackupFile => 'Geçerli bir Pulse yedek dosyası değil';

  @override
  String get dataRestoreMessages => 'Mesajları Geri Yükle';

  @override
  String get dataRestorePasswordSubtitle =>
      'Bu yedeği oluşturmak için kullanılan parolayı girin.';

  @override
  String get dataRestoreConfirmLabel => 'Geri Yükle';

  @override
  String get dataRestoringMessages => 'Mesajlar Geri Yükleniyor';

  @override
  String get dataRestoreDecrypting => 'Şifre çözülüyor...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Mesaj $done/$total içe aktarılıyor...';
  }

  @override
  String get dataRestoreFailed =>
      'Geri yükleme başarısız — yanlış parola veya bozuk dosya';

  @override
  String dataRestoreSuccess(int count) {
    return '$count yeni mesaj geri yüklendi';
  }

  @override
  String get dataRestoreNothingNew =>
      'İçe aktarılacak yeni mesaj yok (tümü zaten mevcut)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Geri yükleme başarısız: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Anahtar Dışa Aktarımını Seç';

  @override
  String get dataNotValidKeyFile =>
      'Geçerli bir Pulse anahtar dışa aktarım dosyası değil';

  @override
  String get dataExportKeys => 'Anahtarları Dışa Aktar';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Anahtar dışa aktarımınızı şifrelemek için bir parola seçin.';

  @override
  String get dataExportKeysConfirmLabel => 'Dışa Aktar';

  @override
  String get dataExportingKeys => 'Anahtarlar Dışa Aktarılıyor';

  @override
  String get dataExportingKeysStatus => 'Kimlik anahtarları şifreleniyor...';

  @override
  String get dataSaveKeyExportDialog => 'Anahtar Dışa Aktarımını Kaydet';

  @override
  String dataKeysExportedTo(String path) {
    return 'Anahtarlar şuraya aktarıldı:\n$path';
  }

  @override
  String get dataExportFailed => 'Dışa aktarma başarısız — anahtar bulunamadı';

  @override
  String dataExportFailedError(String error) {
    return 'Dışa aktarma başarısız: $error';
  }

  @override
  String get dataImportKeys => 'Anahtarları İçe Aktar';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Bu anahtar dışa aktarımını şifrelemek için kullanılan parolayı girin.';

  @override
  String get dataImportKeysConfirmLabel => 'İçe Aktar';

  @override
  String get dataImportingKeys => 'Anahtarlar İçe Aktarılıyor';

  @override
  String get dataImportingKeysStatus => 'Kimlik anahtarları şifre çözülüyor...';

  @override
  String get dataImportFailed =>
      'İçe aktarma başarısız — yanlış parola veya bozuk dosya';

  @override
  String dataImportFailedError(String error) {
    return 'İçe aktarma başarısız: $error';
  }

  @override
  String get securitySectionTitle => 'Güvenlik';

  @override
  String get securityIncorrectPassword => 'Yanlış parola';

  @override
  String get securityPasswordUpdated => 'Parola güncellendi';

  @override
  String get appearanceSectionTitle => 'Görünüm';

  @override
  String appearanceExportFailed(String error) {
    return 'Dışa aktarma başarısız: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return '$path konumuna kaydedildi';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Kaydetme başarısız: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'İçe aktarma başarısız: $error';
  }

  @override
  String get aboutSectionTitle => 'Hakkında';

  @override
  String get providerPublicKey => 'Genel Anahtar';

  @override
  String get providerRelay => 'Aktarıcı';

  @override
  String get providerAutoConfigured =>
      'Kurtarma parolanızdan otomatik yapılandırıldı. Aktarıcı otomatik keşfedildi.';

  @override
  String get providerKeyStoredLocally =>
      'Anahtarınız güvenli depolamada yerel olarak saklanır — hiçbir sunucuya gönderilmez.';

  @override
  String get providerSessionInfo =>
      'Session Network — soğan yönlendirmeli E2EE. Session ID\'niz otomatik olarak oluşturulur ve güvenli şekilde saklanır. Düğümler, yerleşik seed düğümlerinden otomatik olarak keşfedilir.';

  @override
  String get providerAdvanced => 'Gelişmiş';

  @override
  String get providerSaveAndConnect => 'Kaydet ve Bağlan';

  @override
  String get providerAddSecondaryInbox => 'İkincil Gelen Kutusu Ekle';

  @override
  String get providerSecondaryInboxes => 'İkincil Gelen Kutuları';

  @override
  String get providerYourInboxProvider => 'Gelen Kutusu Sağlayıcınız';

  @override
  String get providerConnectionDetails => 'Bağlantı Detayları';

  @override
  String get addContactTitle => 'Kişi Ekle';

  @override
  String get addContactInviteLinkLabel => 'Davet Bağlantısı veya Adres';

  @override
  String get addContactTapToPaste =>
      'Davet bağlantısını yapıştırmak için dokunun';

  @override
  String get addContactPasteTooltip => 'Panodan yapıştır';

  @override
  String get addContactAddressDetected => 'Kişi adresi algılandı';

  @override
  String addContactRoutesDetected(int count) {
    return '$count rota algılandı — SmartRouter en hızlısını seçer';
  }

  @override
  String get addContactFetchingProfile => 'Profil getiriliyor…';

  @override
  String addContactProfileFound(String name) {
    return 'Bulundu: $name';
  }

  @override
  String get addContactNoProfileFound => 'Profil bulunamadı';

  @override
  String get addContactDisplayNameLabel => 'Görünen Ad';

  @override
  String get addContactDisplayNameHint => 'Onlara ne ad vermek istiyorsunuz?';

  @override
  String get addContactAddManually => 'Adresi elle ekle';

  @override
  String get addContactButton => 'Kişi Ekle';

  @override
  String get networkDiagnosticsTitle => 'Ağ Tanılama';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr Aktarıcıları';

  @override
  String get networkDiagnosticsDirect => 'Doğrudan';

  @override
  String get networkDiagnosticsTorOnly => 'Yalnızca Tor';

  @override
  String get networkDiagnosticsBest => 'En İyi';

  @override
  String get networkDiagnosticsNone => 'yok';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Durum';

  @override
  String get networkDiagnosticsConnected => 'Bağlı';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Bağlanıyor %$percent';
  }

  @override
  String get networkDiagnosticsOff => 'Kapalı';

  @override
  String get networkDiagnosticsTransport => 'Taşıyıcı';

  @override
  String get networkDiagnosticsInfrastructure => 'Altyapı';

  @override
  String get networkDiagnosticsSessionNodes => 'Session düğümleri';

  @override
  String get networkDiagnosticsTurnServers => 'TURN sunucuları';

  @override
  String get networkDiagnosticsLastProbe => 'Son yoklama';

  @override
  String get networkDiagnosticsRunning => 'Çalışıyor...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Tanılama Çalıştır';

  @override
  String get networkDiagnosticsForceReprobe => 'Tam Yeniden Yoklama';

  @override
  String get networkDiagnosticsJustNow => 'az önce';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '${minutes}dk önce';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '${hours}sa önce';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '${days}g önce';
  }

  @override
  String get homeNoEch => 'ECH Yok';

  @override
  String get homeNoEchTooltip =>
      'uTLS proxy kullanılamıyor — ECH devre dışı.\nTLS parmak izi DPI tarafından görünür.';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Kaydedildi ve $provider sağlayıcısına bağlanıldı';
  }

  @override
  String get settingsTorFailedToStart => 'Yerleşik Tor başlatılamadı';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon başlatılamadı';

  @override
  String get verifyTitle => 'Güvenlik Numarasını Doğrula';

  @override
  String get verifyIdentityVerified => 'Kimlik Doğrulandı';

  @override
  String get verifyNotYetVerified => 'Henüz Doğrulanmadı';

  @override
  String verifyVerifiedDescription(String name) {
    return '$name adlı kişinin güvenlik numarasını doğruladınız.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Bu numaraları $name ile yüz yüze veya güvenilir bir kanal üzerinden karşılaştırın.';
  }

  @override
  String get verifyExplanation =>
      'Her konuşmanın benzersiz bir güvenlik numarası vardır. Her ikiniz de cihazlarınızda aynı numaraları görüyorsanız, bağlantınız uçtan uca doğrulanmıştır.';

  @override
  String verifyContactKey(String name) {
    return '$name Anahtarı';
  }

  @override
  String get verifyYourKey => 'Sizin Anahtarınız';

  @override
  String get verifyRemoveVerification => 'Doğrulamayı Kaldır';

  @override
  String get verifyMarkAsVerified => 'Doğrulanmış Olarak İşaretle';

  @override
  String verifyAfterReinstall(String name) {
    return '$name uygulamayı yeniden yüklerse güvenlik numarası değişecek ve doğrulama otomatik olarak kaldırılacaktır.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Yalnızca numaraları $name ile sesli arama veya yüz yüze karşılaştırdıktan sonra doğrulanmış olarak işaretleyin.';
  }

  @override
  String get verifyNoSession =>
      'Henüz şifreleme oturumu kurulmadı. Güvenlik numaralarını oluşturmak için önce bir mesaj gönderin.';

  @override
  String get verifyNoKeyAvailable => 'Anahtar mevcut değil';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label parmak izi kopyalandı';
  }

  @override
  String get providerDatabaseUrlLabel => 'Veritabanı URL\'si';

  @override
  String get providerOptionalHint => 'İsteğe bağlı';

  @override
  String get providerWebApiKeyLabel => 'Web API Anahtarı';

  @override
  String get providerOptionalForPublicDb =>
      'Genel veritabanı için isteğe bağlı';

  @override
  String get providerRelayUrlLabel => 'Aktarıcı URL\'si';

  @override
  String get providerPrivateKeyLabel => 'Özel Anahtar';

  @override
  String get providerPrivateKeyNsecLabel => 'Özel Anahtar (nsec)';

  @override
  String get providerStorageNodeLabel =>
      'Depolama Düğümü URL\'si (isteğe bağlı)';

  @override
  String get providerStorageNodeHint =>
      'Yerleşik tohum düğümleri için boş bırakın';

  @override
  String get transferInvalidCodeFormat =>
      'Tanınmayan kod biçimi — LAN: veya NOS: ile başlamalıdır';

  @override
  String get profileCardFingerprintCopied => 'Parmak izi kopyalandı';

  @override
  String get profileCardAboutHint => 'Gizlilik öncelikli 🔒';

  @override
  String get profileCardSaveButton => 'Profili Kaydet';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Şifreli mesajları, kişileri ve avatarları bir dosyaya aktar';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Ses';

  @override
  String bubbleDeliveredTo(String names) {
    return '$names adlı kişilere teslim edildi';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return '$count kişiye teslim edildi';
  }

  @override
  String get groupStatusDialogTitle => 'Mesaj Bilgisi';

  @override
  String get groupStatusRead => 'Okundu';

  @override
  String get groupStatusDelivered => 'Teslim Edildi';

  @override
  String get groupStatusPending => 'Beklemede';

  @override
  String get groupStatusNoData => 'Henüz teslimat bilgisi yok';

  @override
  String get profileTransferAdmin => 'Yönetici Yap';

  @override
  String profileTransferAdminConfirm(String name) {
    return '$name yeni yönetici yapılsın mı?';
  }

  @override
  String get profileTransferAdminBody =>
      'Yönetici ayrıcalıklarınızı kaybedeceksiniz. Bu geri alınamaz.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name artık yönetici';
  }

  @override
  String get profileAdminBadge => 'Yönetici';

  @override
  String get privacyPolicyTitle => 'Gizlilik Politikası';

  @override
  String get privacyOverviewHeading => 'Genel Bakış';

  @override
  String get privacyOverviewBody =>
      'Pulse sunucusuz, uçtan uca şifreli bir mesajlaşma uygulamasıdır. Gizliliğiniz yalnızca bir özellik değil — mimarinin ta kendisidir. Pulse sunucuları yoktur. Hiçbir yerde hesap saklanmaz. Geliştiriciler tarafından hiçbir veri toplanmaz, iletilmez veya saklanmaz.';

  @override
  String get privacyDataCollectionHeading => 'Veri Toplama';

  @override
  String get privacyDataCollectionBody =>
      'Pulse sıfır kişisel veri toplar. Özellikle:\n\n- E-posta, telefon numarası veya gerçek ad gerekmez\n- Analitik, izleme veya telemetri yoktur\n- Reklam tanımlayıcıları yoktur\n- Kişi listesi erişimi yoktur\n- Bulut yedeklemeleri yoktur (mesajlar yalnızca cihazınızda bulunur)\n- Hiçbir Pulse sunucusuna meta veri gönderilmez (sunucu yoktur)';

  @override
  String get privacyEncryptionHeading => 'Şifreleme';

  @override
  String get privacyEncryptionBody =>
      'Tüm mesajlar Signal Protocol (X3DH anahtar anlaşması ile Double Ratchet) kullanılarak şifrelenir. Şifreleme anahtarları yalnızca cihazınızda oluşturulur ve saklanır. Geliştiriciler dahil hiç kimse mesajlarınızı okuyamaz.';

  @override
  String get privacyNetworkHeading => 'Ağ Mimarisi';

  @override
  String get privacyNetworkBody =>
      'Pulse federasyon taşıyıcı bağdaştırıcıları kullanır (Nostr aktarıcıları, Session/Oxen hizmet düğümleri, Firebase Realtime Database, LAN). Bu taşıyıcılar yalnızca şifreli metin taşır. Aktarıcı operatörleri IP adresinizi ve trafik hacminizi görebilir ancak mesaj içeriğini çözemez.\n\nTor etkinleştirildiğinde IP adresiniz aktarıcı operatörlerinden de gizlenir.';

  @override
  String get privacyStunHeading => 'STUN/TURN Sunucuları';

  @override
  String get privacyStunBody =>
      'Sesli ve görüntülü aramalar DTLS-SRTP şifrelemesi ile WebRTC kullanır. STUN sunucuları (eşler arası bağlantılar için genel IP\'nizi keşfetmek için) ve TURN sunucuları (doğrudan bağlantı başarısız olduğunda medyayı aktarmak için) IP adresinizi ve arama süresini görebilir ancak arama içeriğini çözemez.\n\nMaksimum gizlilik için Ayarlar\'dan kendi TURN sunucunuzu yapılandırabilirsiniz.';

  @override
  String get privacyCrashHeading => 'Çökme Raporlama';

  @override
  String get privacyCrashBody =>
      'Sentry çökme raporlama etkinse (derleme zamanı SENTRY_DSN ile), anonim çökme raporları gönderilebilir. Bunlar mesaj içeriği, kişi bilgisi veya kişisel tanımlayıcı bilgi içermez. Çökme raporlama, DSN çıkarılarak derleme zamanında devre dışı bırakılabilir.';

  @override
  String get privacyPasswordHeading => 'Parola ve Anahtarlar';

  @override
  String get privacyPasswordBody =>
      'Kurtarma parolanız Argon2id (bellek-yoğun KDF) aracılığıyla kriptografik anahtarlar türetmek için kullanılır. Parola hiçbir yere iletilmez. Parolanızı kaybederseniz hesabınız kurtarılamaz — sıfırlayacak bir sunucu yoktur.';

  @override
  String get privacyFontsHeading => 'Yazı Tipleri';

  @override
  String get privacyFontsBody =>
      'Pulse tüm yazı tiplerini yerel olarak içerir. Google Fonts veya herhangi bir harici yazı tipi servisine istek yapılmaz.';

  @override
  String get privacyThirdPartyHeading => 'Üçüncü Taraf Hizmetleri';

  @override
  String get privacyThirdPartyBody =>
      'Pulse herhangi bir reklam ağı, analitik sağlayıcısı, sosyal medya platformu veya veri komisyoncusu ile entegre değildir. Tek ağ bağlantıları yapılandırdığınız taşıyıcı aktarıcılarınadır.';

  @override
  String get privacyOpenSourceHeading => 'Açık Kaynak';

  @override
  String get privacyOpenSourceBody =>
      'Pulse açık kaynaklı bir yazılımdır. Bu gizlilik iddialarını doğrulamak için kaynak kodun tamamını denetleyebilirsiniz.';

  @override
  String get privacyContactHeading => 'İletişim';

  @override
  String get privacyContactBody =>
      'Gizlilikle ilgili sorular için proje deposunda bir sorun bildirin.';

  @override
  String get privacyLastUpdated => 'Son güncelleme: Mart 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Kaydetme başarısız: $error';
  }

  @override
  String get themeEngineTitle => 'Tema Motoru';

  @override
  String get torBuiltInTitle => 'Yerleşik Tor';

  @override
  String get torConnectedSubtitle =>
      'Bağlı — Nostr 127.0.0.1:9250 üzerinden yönlendiriliyor';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Bağlanıyor… %$pct';
  }

  @override
  String get torNotRunning =>
      'Çalışmıyor — yeniden başlatmak için düğmeye dokunun';

  @override
  String get torDescription =>
      'Nostr\'u Tor üzerinden yönlendirir (sansürlü ağlar için Snowflake)';

  @override
  String get torNetworkDiagnostics => 'Ağ Tanılama';

  @override
  String get torTransportLabel => 'Taşıyıcı: ';

  @override
  String get torPtAuto => 'Otomatik';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Düz';

  @override
  String get torTimeoutLabel => 'Zaman Aşımı: ';

  @override
  String get torInfoDescription =>
      'Etkinleştirildiğinde Nostr WebSocket bağlantıları Tor (SOCKS5) üzerinden yönlendirilir. Tor Browser 127.0.0.1:9150\'de dinler. Bağımsız tor arka plan süreci 9050 portunu kullanır. Firebase bağlantıları etkilenmez.';

  @override
  String get torRouteNostrTitle => 'Nostr\'u Tor Üzerinden Yönlendir';

  @override
  String get torManagedByBuiltin => 'Yerleşik Tor Tarafından Yönetiliyor';

  @override
  String get torActiveRouting =>
      'Aktif — Nostr trafiği Tor üzerinden yönlendiriliyor';

  @override
  String get torDisabled => 'Devre dışı';

  @override
  String get torProxySocks5 => 'Tor Proxy (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Proxy Ana Bilgisayar';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo =>
      'Tor Browser: port 9150  •  tor arka plan süreci: port 9050';

  @override
  String get torForceNostrTitle => 'Mesajları Tor üzerinden yönlendir';

  @override
  String get torForceNostrSubtitle =>
      'Tüm Nostr relay bağlantıları Tor üzerinden geçecek. Daha yavaş ama IP adresinizi relay\'lerden gizler.';

  @override
  String get torForceNostrDisabled => 'Önce Tor etkinleştirilmelidir';

  @override
  String get torForcePulseTitle => 'Pulse relay\'i Tor üzerinden yönlendir';

  @override
  String get torForcePulseSubtitle =>
      'Tüm Pulse relay bağlantıları Tor üzerinden geçecek. Daha yavaş ama IP adresinizi sunucudan gizler.';

  @override
  String get torForcePulseDisabled => 'Önce Tor etkinleştirilmelidir';

  @override
  String get i2pProxySocks5 => 'I2P Proxy (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P varsayılan olarak 4447 portunda SOCKS5 kullanır. Herhangi bir taşıyıcıdaki kullanıcılarla iletişim kurmak için I2P outproxy üzerinden bir Nostr aktarıcısına bağlanın (örn. relay.damus.i2p). Her ikisi de etkinleştirildiğinde Tor önceliklidir.';

  @override
  String get i2pRouteNostrTitle => 'Nostr\'u I2P Üzerinden Yönlendir';

  @override
  String get i2pActiveRouting =>
      'Aktif — Nostr trafiği I2P üzerinden yönlendiriliyor';

  @override
  String get i2pDisabled => 'Devre dışı';

  @override
  String get i2pProxyHostLabel => 'Proxy Ana Bilgisayar';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'I2P Router varsayılan SOCKS5 portu: 4447';

  @override
  String get customProxySocks5 => 'Özel Proxy (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Aktarıcı';

  @override
  String get customProxyInfoDescription =>
      'Özel proxy trafiği V2Ray/Xray/Shadowsocks üzerinden yönlendirir. CF Worker, Cloudflare CDN üzerinde kişisel aktarıcı proxy görevi görür — GFW gerçek aktarıcıyı değil *.workers.dev\'i görür.';

  @override
  String get customSocks5ProxyTitle => 'Özel SOCKS5 Proxy';

  @override
  String get customProxyActive =>
      'Aktif — trafik SOCKS5 üzerinden yönlendiriliyor';

  @override
  String get customProxyDisabled => 'Devre dışı';

  @override
  String get customProxyHostLabel => 'Proxy Ana Bilgisayar';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker Alan Adı (isteğe bağlı)';

  @override
  String get customWorkerHelpTitle =>
      'CF Worker aktarıcısı nasıl dağıtılır (ücretsiz)';

  @override
  String get customWorkerScriptCopied => 'Betik kopyalandı!';

  @override
  String get customWorkerStep1 =>
      '1. dash.cloudflare.com → Workers & Pages\'e gidin\n2. Worker Oluştur → bu betiği yapıştırın:\n';

  @override
  String get customWorkerStep2 =>
      '3. Dağıt → alan adını kopyalayın (örn. my-relay.user.workers.dev)\n4. Yukarıya alan adını yapıştırın → Kaydet\n\nUygulama otomatik bağlanır: wss://domain/?r=relay_url\nGFW görür: *.workers.dev\'e bağlantı (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Bağlı — SOCKS5 127.0.0.1:$port üzerinde';
  }

  @override
  String get psiphonConnecting => 'Bağlanıyor…';

  @override
  String get psiphonNotRunning =>
      'Çalışmıyor — yeniden başlatmak için düğmeye dokunun';

  @override
  String get psiphonDescription =>
      'Hızlı tünel (~3sn başlatma, 2000+ dönen VPS)';

  @override
  String get turnCommunityServers => 'Topluluk TURN Sunucuları';

  @override
  String get turnCustomServer => 'Özel TURN Sunucusu (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN sunucuları yalnızca önceden şifrelenmiş akışları (DTLS-SRTP) aktarır. Aktarıcı operatörü IP\'nizi ve trafik hacminizi görür ancak aramaları çözemez. TURN yalnızca doğrudan P2P başarısız olduğunda kullanılır (bağlantıların ~%15–20\'si).';

  @override
  String get turnFreeLabel => 'ÜCRETSİZ';

  @override
  String get turnServerUrlLabel => 'TURN Sunucu URL\'si';

  @override
  String get turnServerUrlHint => 'turn:sunucunuz.com:3478 veya turns:...';

  @override
  String get turnUsernameLabel => 'Kullanıcı Adı';

  @override
  String get turnPasswordLabel => 'Parola';

  @override
  String get turnOptionalHint => 'İsteğe bağlı';

  @override
  String get turnCustomInfo =>
      'Maksimum kontrol için herhangi bir 5\$/ay VPS üzerinde coturn barındırın. Kimlik bilgileri yerel olarak saklanır.';

  @override
  String get themePickerAppearance => 'Görünüm';

  @override
  String get themePickerAccentColor => 'Vurgu Rengi';

  @override
  String get themeModeLight => 'Açık';

  @override
  String get themeModeDark => 'Koyu';

  @override
  String get themeModeSystem => 'Sistem';

  @override
  String get themeDynamicPresets => 'Ön Ayarlar';

  @override
  String get themeDynamicPrimaryColor => 'Ana Renk';

  @override
  String get themeDynamicBorderRadius => 'Kenar Yuvarlaklığı';

  @override
  String get themeDynamicFont => 'Yazı Tipi';

  @override
  String get themeDynamicAppearance => 'Görünüm';

  @override
  String get themeDynamicUiStyle => 'Arayüz Stili';

  @override
  String get themeDynamicUiStyleDescription =>
      'Diyalogların, anahtarların ve göstergelerin görünümünü kontrol eder.';

  @override
  String get themeDynamicSharp => 'Keskin';

  @override
  String get themeDynamicRound => 'Yuvarlak';

  @override
  String get themeDynamicModeDark => 'Koyu';

  @override
  String get themeDynamicModeLight => 'Açık';

  @override
  String get themeDynamicModeAuto => 'Otomatik';

  @override
  String get themeDynamicPlatformAuto => 'Otomatik';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'Geçersiz Firebase URL\'si. Beklenen: https://proje.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Geçersiz aktarıcı URL\'si. Beklenen: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Geçersiz Pulse sunucu URL\'si. Beklenen: https://sunucu:port';

  @override
  String get providerPulseServerUrlLabel => 'Sunucu URL\'si';

  @override
  String get providerPulseServerUrlHint => 'https://sunucunuz:8443';

  @override
  String get providerPulseInviteLabel => 'Davet Kodu';

  @override
  String get providerPulseInviteHint => 'Davet kodu (gerekiyorsa)';

  @override
  String get providerPulseInfo =>
      'Kendi barındırdığınız aktarıcı. Anahtarlar kurtarma parolanızdan türetilir.';

  @override
  String get providerScreenTitle => 'Gelen Kutuları';

  @override
  String get providerSecondaryInboxesHeader => 'İKİNCİL GELEN KUTULARI';

  @override
  String get providerSecondaryInboxesInfo =>
      'İkincil gelen kutuları yedeklilik için mesajları eşzamanlı olarak alır.';

  @override
  String get providerRemoveTooltip => 'Kaldır';

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
  String get emojiNoRecent => 'Son kullanılan emoji yok';

  @override
  String get emojiSearchHint => 'Emoji ara...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Sohbet etmek için dokunun';

  @override
  String get imageViewerSaveToDownloads => 'İndirilenler\'e Kaydet';

  @override
  String imageViewerSavedTo(String path) {
    return '$path konumuna kaydedildi';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'Tamam';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsLanguageSubtitle => 'Uygulama görüntüleme dili';

  @override
  String get settingsLanguageSystem => 'Sistem varsayılanı';

  @override
  String get onboardingLanguageTitle => 'Dilinizi seçin';

  @override
  String get onboardingLanguageSubtitle =>
      'Bunu daha sonra Ayarlar\'dan değiştirebilirsiniz';

  @override
  String get videoNoteRecord => 'Video mesajı kaydet';

  @override
  String get videoNoteTapToRecord => 'Kaydetmek için dokunun';

  @override
  String get videoNoteTapToStop => 'Durdurmak için dokunun';

  @override
  String get videoNoteCameraPermission => 'Kamera izni reddedildi';

  @override
  String get videoNoteMaxDuration => 'Maksimum 30 saniye';

  @override
  String get videoNoteNotSupported =>
      'Video notlar bu platformda desteklenmiyor';

  @override
  String get navChats => 'Sohbetler';

  @override
  String get navUpdates => 'Güncellemeler';

  @override
  String get navCalls => 'Aramalar';

  @override
  String get filterAll => 'Tümü';

  @override
  String get filterUnread => 'Okunmamış';

  @override
  String get filterGroups => 'Gruplar';

  @override
  String get callsNoRecent => 'Son arama yok';

  @override
  String get callsEmptySubtitle => 'Arama geçmişiniz burada görünecek';

  @override
  String get appBarEncrypted => 'uçtan uca şifreli';

  @override
  String get newStatus => 'Yeni durum';

  @override
  String get newCall => 'Yeni arama';

  @override
  String get joinChannelTitle => 'Kanala Katıl';

  @override
  String get joinChannelDescription => 'KANAL URL\'Sİ';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'Kanal bilgileri alınıyor…';

  @override
  String get joinChannelNotFound => 'Bu URL\'de kanal bulunamadı';

  @override
  String get joinChannelNetworkError => 'Sunucuya ulaşılamadı';

  @override
  String get joinChannelAlreadyJoined => 'Zaten katıldınız';

  @override
  String get joinChannelButton => 'Katıl';

  @override
  String get channelFeedEmpty => 'Henüz gönderi yok';

  @override
  String get channelLeave => 'Kanaldan Ayrıl';

  @override
  String get channelLeaveConfirm =>
      'Bu kanaldan ayrılsın mı? Önbelleğe alınan gönderiler silinecek.';

  @override
  String get channelInfo => 'Kanal Bilgisi';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'düzenlendi';

  @override
  String get channelLoadMore => 'Daha fazla yükle';

  @override
  String get channelSearchPosts => 'Gönderileri ara…';

  @override
  String get channelNoResults => 'Eşleşen gönderi yok';

  @override
  String get channelUrl => 'Kanal URL';

  @override
  String get channelCreated => 'Katıldı';

  @override
  String channelPostCount(int count) {
    return '$count gönderi';
  }

  @override
  String get channelCopyUrl => 'URL kopyala';

  @override
  String get setupNext => 'İleri';

  @override
  String get setupKeyWarning =>
      'Sizin için bir kurtarma anahtarı oluşturulacak. Hesabınızı yeni bir cihazda kurtarmanın tek yolu budur — sunucu yok, şifre sıfırlama yok.';

  @override
  String get setupKeyTitle => 'Kurtarma Anahtarınız';

  @override
  String get setupKeySubtitle =>
      'Bu anahtarı yazın ve güvenli bir yerde saklayın. Hesabınızı yeni bir cihazda kurtarmak için gerekecek.';

  @override
  String get setupKeyCopied => 'Kopyalandı!';

  @override
  String get setupKeyWroteItDown => 'Yazdım';

  @override
  String get setupKeyWarnBody =>
      'Bu anahtarı yedek olarak yazın. Ayrıca daha sonra Ayarlar → Güvenlik bölümünden görüntüleyebilirsiniz.';

  @override
  String get setupVerifyTitle => 'Kurtarma anahtarını doğrula';

  @override
  String get setupVerifySubtitle =>
      'Doğru kaydettiğinizi onaylamak için kurtarma anahtarınızı tekrar girin.';

  @override
  String get setupVerifyButton => 'Doğrula';

  @override
  String get setupKeyMismatch =>
      'Anahtar eşleşmiyor. Kontrol edip tekrar deneyin.';

  @override
  String get setupSkipVerify => 'Doğrulamayı atla';

  @override
  String get setupSkipVerifyTitle => 'Doğrulamayı atla?';

  @override
  String get setupSkipVerifyBody =>
      'Kurtarma anahtarınızı kaybederseniz hesabınız kurtarılamaz. Emin misiniz?';

  @override
  String get setupCreatingAccount => 'Hesap oluşturuluyor…';

  @override
  String get setupRestoringAccount => 'Hesap kurtarılıyor…';

  @override
  String get restoreKeyInfoBanner =>
      'Kurtarma anahtarınızı girin — adresiniz (Nostr + Session) otomatik olarak kurtarılacak. Kişiler ve mesajlar yalnızca yerel olarak depolanmıştı.';

  @override
  String get restoreKeyHint => 'Kurtarma anahtarı';

  @override
  String get settingsViewRecoveryKey => 'Kurtarma anahtarını görüntüle';

  @override
  String get settingsViewRecoveryKeySubtitle =>
      'Hesap kurtarma anahtarınızı gösterin';

  @override
  String get settingsRecoveryKeyNotStored =>
      'Kurtarma anahtarı mevcut değil (bu özellikten önce oluşturulmuş)';

  @override
  String get settingsRecoveryKeyWarning =>
      'Bu anahtarı güvenli tutun. Anahtara sahip herkes hesabınızı başka bir cihazda kurtarabilir.';

  @override
  String get replaceIdentityTitle => 'Mevcut kimlik değiştirilsin mi?';

  @override
  String get replaceIdentityBodyRestore =>
      'Bu cihazda zaten bir kimlik var. Kurtarma, mevcut Nostr anahtarınızı ve Oxen tohumunuzu kalıcı olarak değiştirecek. Tüm kişiler mevcut adresinize ulaşma yeteneğini kaybedecek.\n\nBu geri alınamaz.';

  @override
  String get replaceIdentityBodyCreate =>
      'Bu cihazda zaten bir kimlik var. Yeni bir tane oluşturmak, mevcut Nostr anahtarınızı ve Oxen tohumunuzu kalıcı olarak değiştirecek. Tüm kişiler mevcut adresinize ulaşma yeteneğini kaybedecek.\n\nBu geri alınamaz.';

  @override
  String get replace => 'Değiştir';

  @override
  String get callNoScreenSources => 'No screen sources available';

  @override
  String get callScreenShareQuality => 'Screen Share Quality';

  @override
  String get callFrameRate => 'Frame rate';

  @override
  String get callResolution => 'Resolution';

  @override
  String get callAutoResolution => 'Auto = native screen resolution';

  @override
  String get callStartSharing => 'Start sharing';

  @override
  String get callCameraUnavailable =>
      'Camera unavailable — may be in use by another app';

  @override
  String get themeResetToDefaults => 'Reset to defaults';

  @override
  String get backupSaveToDownloadsTitle => 'Save backup to Downloads?';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'No file picker available. The backup will be saved to:\n$path';
  }

  @override
  String get systemLabel => 'System';

  @override
  String get next => 'Next';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return '$remaining more taps to enable developer mode';
  }

  @override
  String get devModeEnabled => 'Developer mode enabled';

  @override
  String get devTools => 'Developer Tools';

  @override
  String get devAdapterDiagnostics => 'Adapter toggles & diagnostics';

  @override
  String get devEnableAll => 'Enable all';

  @override
  String get devDisableAll => 'Disable all';

  @override
  String get turnUrlValidation =>
      'TURN URL must start with turn: or turns: (max 512 chars)';

  @override
  String get callMissedCall => 'Missed call';

  @override
  String get callOutgoingCall => 'Outgoing call';

  @override
  String get callIncomingCall => 'Incoming call';

  @override
  String get mediaMissingData => 'Missing media data';

  @override
  String get mediaDownloadFailed => 'Download failed';

  @override
  String get mediaDecryptFailed => 'Decrypt failed';

  @override
  String get callEndCallBanner => 'End call';

  @override
  String get meFallback => 'Me';

  @override
  String get imageSaveToDownloads => 'Save to Downloads';

  @override
  String imageSavedToPath(String path) {
    return 'Saved to $path';
  }

  @override
  String get callScreenShareRequiresPermission =>
      'Screen sharing requires permission';

  @override
  String get callScreenShareUnavailable => 'Screen sharing unavailable';

  @override
  String get statusJustNow => 'Just now';

  @override
  String statusMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String statusHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count routes',
      one: '1 route',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => 'Ready to add';

  @override
  String groupSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get paste => 'Paste';

  @override
  String get sfuAudioOnly => 'Audio only';

  @override
  String sfuParticipants(int count) {
    return '$count participants';
  }

  @override
  String get dataUnencryptedBackup => 'Unencrypted backup';

  @override
  String get dataUnencryptedBackupBody =>
      'This file is an unencrypted identity backup and will overwrite your current keys. Only import files you created yourself. Proceed?';

  @override
  String get dataImportAnyway => 'Import anyway';

  @override
  String get securityStorageError => 'Security storage error — restart the app';

  @override
  String get aboutDevModeActive => 'Developer mode active';

  @override
  String get themeColors => 'Colors';

  @override
  String get themePrimaryAccent => 'Primary accent';

  @override
  String get themeSecondaryAccent => 'Secondary accent';

  @override
  String get themeBackground => 'Background';

  @override
  String get themeSurface => 'Surface';

  @override
  String get themeChatBubbles => 'Chat Bubbles';

  @override
  String get themeOutgoingMessage => 'Outgoing message';

  @override
  String get themeIncomingMessage => 'Incoming message';

  @override
  String get themeShape => 'Shape';

  @override
  String get devSectionDeveloper => 'Developer';

  @override
  String get devAdapterChannelsHint =>
      'Adapter channels — disable to test specific transports.';

  @override
  String get devNostrRelays => 'Nostr relays (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Session Network';

  @override
  String get devPulseRelay => 'Pulse self-hosted relay';

  @override
  String get devLanNetwork => 'Local network (UDP/TCP)';

  @override
  String get devSectionCalls => 'Calls';

  @override
  String get devForceTurnRelay => 'Force TURN relay';

  @override
  String get devForceTurnRelaySubtitle =>
      'Disable P2P — all calls via TURN servers only';

  @override
  String get devRestartWarning =>
      '⚠ Changes take effect on next send/call. Restart app to apply to incoming.';
}
