// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Cari mesej...';

  @override
  String get search => 'Cari';

  @override
  String get clearSearch => 'Kosongkan carian';

  @override
  String get closeSearch => 'Tutup carian';

  @override
  String get moreOptions => 'Lagi pilihan';

  @override
  String get back => 'Kembali';

  @override
  String get cancel => 'Batal';

  @override
  String get close => 'Tutup';

  @override
  String get confirm => 'Sahkan';

  @override
  String get remove => 'Buang';

  @override
  String get save => 'Simpan';

  @override
  String get add => 'Tambah';

  @override
  String get copy => 'Salin';

  @override
  String get skip => 'Langkau';

  @override
  String get done => 'Selesai';

  @override
  String get apply => 'Gunakan';

  @override
  String get export => 'Eksport';

  @override
  String get import => 'Import';

  @override
  String get homeNewGroup => 'Kumpulan baharu';

  @override
  String get homeSettings => 'Tetapan';

  @override
  String get homeSearching => 'Mencari mesej...';

  @override
  String get homeNoResults => 'Tiada hasil ditemui';

  @override
  String get homeNoChatHistory => 'Tiada sejarah perbualan lagi';

  @override
  String homeTransportSwitched(String address) {
    return 'Pengangkutan bertukar → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name sedang memanggil...';
  }

  @override
  String get homeAccept => 'Terima';

  @override
  String get homeDecline => 'Tolak';

  @override
  String get homeLoadEarlier => 'Muat mesej terdahulu';

  @override
  String get homeChats => 'Perbualan';

  @override
  String get homeSelectConversation => 'Pilih perbualan';

  @override
  String get homeNoChatsYet => 'Tiada perbualan lagi';

  @override
  String get homeAddContactToStart => 'Tambah kenalan untuk mula berbual';

  @override
  String get homeNewChat => 'Perbualan Baharu';

  @override
  String get homeNewChatTooltip => 'Perbualan baharu';

  @override
  String get homeIncomingCallTitle => 'Panggilan Masuk';

  @override
  String get homeIncomingGroupCallTitle => 'Panggilan Kumpulan Masuk';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — panggilan kumpulan masuk';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Tiada perbualan sepadan dengan \"$query\"';
  }

  @override
  String get homeSectionChats => 'Perbualan';

  @override
  String get homeSectionMessages => 'Mesej';

  @override
  String get homeDbEncryptionUnavailable =>
      'Penyulitan pangkalan data tidak tersedia — pasang SQLCipher untuk perlindungan penuh';

  @override
  String get chatFileTooLargeGroup =>
      'Fail melebihi 512 KB tidak disokong dalam perbualan kumpulan';

  @override
  String get chatLargeFile => 'Fail Besar';

  @override
  String get chatCancel => 'Batal';

  @override
  String get chatSend => 'Hantar';

  @override
  String get chatFileTooLarge =>
      'Fail terlalu besar — saiz maksimum ialah 100 MB';

  @override
  String get chatMicDenied => 'Kebenaran mikrofon ditolak';

  @override
  String get chatVoiceFailed =>
      'Gagal menyimpan mesej suara — semak storan yang tersedia';

  @override
  String get chatScheduleFuture =>
      'Masa yang dijadualkan mestilah pada masa hadapan';

  @override
  String get chatToday => 'Hari ini';

  @override
  String get chatYesterday => 'Semalam';

  @override
  String get chatEdited => 'disunting';

  @override
  String get chatYou => 'Anda';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Fail ini bersaiz $size MB. Menghantar fail besar mungkin lambat pada sesetengah rangkaian. Teruskan?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Kunci keselamatan $name telah berubah. Ketik untuk mengesahkan.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Tidak dapat menyulitkan mesej kepada $name — mesej tidak dihantar.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Nombor keselamatan untuk $name telah berubah. Ketik untuk mengesahkan.';
  }

  @override
  String get chatNoMessagesFound => 'Tiada mesej ditemui';

  @override
  String get chatMessagesE2ee => 'Mesej disulitkan hujung-ke-hujung';

  @override
  String get chatSayHello => 'Ucapkan salam';

  @override
  String get appBarOnline => 'dalam talian';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'sedang menaip';

  @override
  String get appBarSearchMessages => 'Cari mesej...';

  @override
  String get appBarMute => 'Senyapkan';

  @override
  String get appBarUnmute => 'Nyahsenyap';

  @override
  String get appBarMedia => 'Media';

  @override
  String get appBarDisappearing => 'Mesej hilang';

  @override
  String get appBarDisappearingOn => 'Hilang: hidup';

  @override
  String get appBarGroupSettings => 'Tetapan kumpulan';

  @override
  String get appBarSearchTooltip => 'Cari mesej';

  @override
  String get appBarVoiceCall => 'Panggilan suara';

  @override
  String get appBarVideoCall => 'Panggilan video';

  @override
  String get inputMessage => 'Mesej...';

  @override
  String get inputAttachFile => 'Lampirkan fail';

  @override
  String get inputSendMessage => 'Hantar mesej';

  @override
  String get inputRecordVoice => 'Rakam mesej suara';

  @override
  String get inputSendVoice => 'Hantar mesej suara';

  @override
  String get inputCancelReply => 'Batal balasan';

  @override
  String get inputCancelEdit => 'Batal suntingan';

  @override
  String get inputCancelRecording => 'Batal rakaman';

  @override
  String get inputRecording => 'Merakam…';

  @override
  String get inputEditingMessage => 'Menyunting mesej';

  @override
  String get inputPhoto => 'Foto';

  @override
  String get inputVoiceMessage => 'Mesej suara';

  @override
  String get inputFile => 'Fail';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count mesej dijadualkan$_temp0';
  }

  @override
  String get callInitializing => 'Memulakan panggilan…';

  @override
  String get callConnecting => 'Menyambung…';

  @override
  String get callConnectingRelay => 'Menyambung (geganti)…';

  @override
  String get callSwitchingRelay => 'Bertukar ke mod geganti…';

  @override
  String get callConnectionFailed => 'Sambungan gagal';

  @override
  String get callReconnecting => 'Menyambung semula…';

  @override
  String get callEnded => 'Panggilan tamat';

  @override
  String get callLive => 'Langsung';

  @override
  String get callEnd => 'Tamat';

  @override
  String get callEndCall => 'Tamatkan panggilan';

  @override
  String get callMute => 'Senyap';

  @override
  String get callUnmute => 'Nyahsenyap';

  @override
  String get callSpeaker => 'Pembesar suara';

  @override
  String get callCameraOn => 'Kamera Hidup';

  @override
  String get callCameraOff => 'Kamera Mati';

  @override
  String get callShareScreen => 'Kongsi Skrin';

  @override
  String get callStopShare => 'Henti Kongsi';

  @override
  String callTorBackup(String duration) {
    return 'Sandaran Tor · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Sandaran Tor aktif — laluan utama tidak tersedia';

  @override
  String get callDirectFailed =>
      'Sambungan langsung gagal — bertukar ke mod geganti…';

  @override
  String get callTurnUnreachable =>
      'Pelayan TURN tidak dapat dicapai. Tambah TURN tersuai di Tetapan → Lanjutan.';

  @override
  String get callRelayMode => 'Mod geganti aktif (rangkaian terhad)';

  @override
  String get callStarting => 'Memulakan panggilan…';

  @override
  String get callConnectingToGroup => 'Menyambung ke kumpulan…';

  @override
  String get callGroupOpenedInBrowser =>
      'Panggilan kumpulan dibuka dalam pelayar';

  @override
  String get callCouldNotOpenBrowser => 'Tidak dapat membuka pelayar';

  @override
  String get callInviteLinkSent =>
      'Pautan jemputan dihantar kepada semua ahli kumpulan.';

  @override
  String get callOpenLinkManually =>
      'Buka pautan di atas secara manual atau ketik untuk cuba semula.';

  @override
  String get callJitsiNotE2ee =>
      'Panggilan Jitsi TIDAK disulitkan hujung-ke-hujung';

  @override
  String get callRetryOpenBrowser => 'Cuba buka pelayar semula';

  @override
  String get callClose => 'Tutup';

  @override
  String get callCamOn => 'Kamera hidup';

  @override
  String get callCamOff => 'Kamera mati';

  @override
  String get noConnection => 'Tiada sambungan — mesej akan beratur';

  @override
  String get connected => 'Disambungkan';

  @override
  String get connecting => 'Menyambung…';

  @override
  String get disconnected => 'Terputus';

  @override
  String get offlineBanner =>
      'Tiada sambungan — mesej akan beratur dan dihantar apabila kembali dalam talian';

  @override
  String get lanModeBanner =>
      'Mod LAN — Tiada internet · Rangkaian tempatan sahaja';

  @override
  String get probeCheckingNetwork => 'Memeriksa sambungan rangkaian…';

  @override
  String get probeDiscoveringRelays =>
      'Menemui geganti melalui direktori komuniti…';

  @override
  String get probeStartingTor => 'Memulakan Tor untuk bootstrap…';

  @override
  String get probeFindingRelaysTor =>
      'Mencari geganti yang boleh dicapai melalui Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'Rangkaian sedia — $count geganti$_temp0 ditemui';
  }

  @override
  String get probeNoRelaysFound =>
      'Tiada geganti yang boleh dicapai ditemui — mesej mungkin tertangguh';

  @override
  String get jitsiWarningTitle => 'Tidak disulitkan hujung-ke-hujung';

  @override
  String get jitsiWarningBody =>
      'Panggilan Jitsi Meet tidak disulitkan oleh Pulse. Gunakan hanya untuk perbualan tidak sensitif.';

  @override
  String get jitsiConfirm => 'Sertai juga';

  @override
  String get jitsiGroupWarningTitle => 'Tidak disulitkan hujung-ke-hujung';

  @override
  String get jitsiGroupWarningBody =>
      'Panggilan ini mempunyai terlalu ramai peserta untuk mesh tersulit terbina dalam.\n\nPautan Jitsi Meet akan dibuka dalam pelayar anda. Jitsi TIDAK disulitkan hujung-ke-hujung — pelayan boleh melihat panggilan anda.';

  @override
  String get jitsiContinueAnyway => 'Teruskan juga';

  @override
  String get retry => 'Cuba semula';

  @override
  String get setupCreateAnonymousAccount => 'Cipta akaun tanpa nama';

  @override
  String get setupTapToChangeColor => 'Ketik untuk tukar warna';

  @override
  String get setupReqMinLength => 'Sekurang-kurangnya 16 aksara';

  @override
  String get setupReqVariety =>
      '3 daripada 4: huruf besar, kecil, digit, simbol';

  @override
  String get setupReqMatch => 'Kata laluan sepadan';

  @override
  String get setupYourNickname => 'Nama panggilan anda';

  @override
  String get setupRecoveryPassword => 'Kata laluan pemulihan (min. 16)';

  @override
  String get setupConfirmPassword => 'Sahkan kata laluan';

  @override
  String get setupMin16Chars => 'Minimum 16 aksara';

  @override
  String get setupPasswordsDoNotMatch => 'Kata laluan tidak sepadan';

  @override
  String get setupEntropyWeak => 'Lemah';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Kuat';

  @override
  String get setupEntropyWeakNeedsVariety => 'Lemah (perlu 3 jenis aksara)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bit)';
  }

  @override
  String get setupPasswordWarning =>
      'Kata laluan ini adalah satu-satunya cara untuk memulihkan akaun anda. Tiada pelayan — tiada tetapan semula kata laluan. Ingat atau catatkannya.';

  @override
  String get setupCreateAccount => 'Cipta akaun';

  @override
  String get setupAlreadyHaveAccount => 'Sudah ada akaun? ';

  @override
  String get setupRestore => 'Pulihkan →';

  @override
  String get restoreTitle => 'Pulihkan akaun';

  @override
  String get restoreInfoBanner =>
      'Masukkan kata laluan pemulihan anda — alamat anda (Nostr + Session) akan dipulihkan secara automatik. Kenalan dan mesej disimpan secara tempatan sahaja.';

  @override
  String get restoreNewNickname =>
      'Nama panggilan baharu (boleh tukar kemudian)';

  @override
  String get restoreButton => 'Pulihkan akaun';

  @override
  String get lockTitle => 'Pulse dikunci';

  @override
  String get lockSubtitle => 'Masukkan kata laluan anda untuk meneruskan';

  @override
  String get lockPasswordHint => 'Kata laluan';

  @override
  String get lockUnlock => 'Buka kunci';

  @override
  String get lockPanicHint =>
      'Lupa kata laluan? Masukkan kunci panik anda untuk padam semua data.';

  @override
  String get lockTooManyAttempts =>
      'Terlalu banyak percubaan. Memadam semua data…';

  @override
  String get lockWrongPassword => 'Kata laluan salah';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Kata laluan salah — $attempts/$max percubaan';
  }

  @override
  String get onboardingSkip => 'Langkau';

  @override
  String get onboardingNext => 'Seterusnya';

  @override
  String get onboardingGetStarted => 'Cipta Akaun';

  @override
  String get onboardingWelcomeTitle => 'Selamat datang ke Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Penghantar mesej terdesentralisasi dengan penyulitan hujung-ke-hujung.\n\nTiada pelayan pusat. Tiada pengumpulan data. Tiada pintu belakang.\nPerbualan anda hanya milik anda.';

  @override
  String get onboardingTransportTitle => 'Agnostik Pengangkutan';

  @override
  String get onboardingTransportBody =>
      'Gunakan Firebase, Nostr, atau kedua-duanya serentak.\n\nMesej dihalakan merentasi rangkaian secara automatik. Sokongan Tor dan I2P terbina dalam untuk rintangan penapisan.';

  @override
  String get onboardingSignalTitle => 'Signal + Pasca-Kuantum';

  @override
  String get onboardingSignalBody =>
      'Setiap mesej disulitkan dengan Protokol Signal (Double Ratchet + X3DH) untuk kerahsiaan hadapan.\n\nTambahan pula dibalut dengan Kyber-1024 — algoritma pasca-kuantum standard NIST — melindungi daripada komputer kuantum masa hadapan.';

  @override
  String get onboardingKeysTitle => 'Anda Memiliki Kunci Anda';

  @override
  String get onboardingKeysBody =>
      'Kunci identiti anda tidak pernah meninggalkan peranti anda.\n\nCap jari Signal membolehkan anda mengesahkan kenalan di luar jalur. TOFU (Trust On First Use) mengesan perubahan kunci secara automatik.';

  @override
  String get onboardingThemeTitle => 'Pilih Penampilan Anda';

  @override
  String get onboardingThemeBody =>
      'Pilih tema dan warna aksen. Anda sentiasa boleh menukar ini kemudian di Tetapan.';

  @override
  String get contactsNewChat => 'Perbualan baharu';

  @override
  String get contactsAddContact => 'Tambah kenalan';

  @override
  String get contactsSearchHint => 'Cari...';

  @override
  String get contactsNewGroup => 'Kumpulan baharu';

  @override
  String get contactsNoContactsYet => 'Tiada kenalan lagi';

  @override
  String get contactsAddHint => 'Ketik + untuk menambah alamat seseorang';

  @override
  String get contactsNoMatch => 'Tiada kenalan sepadan';

  @override
  String get contactsRemoveTitle => 'Buang kenalan';

  @override
  String contactsRemoveMessage(String name) {
    return 'Buang $name?';
  }

  @override
  String get contactsRemove => 'Buang';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count kenalan$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Buka Pautan';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Buka URL ini dalam pelayar anda?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Buka';

  @override
  String get bubbleSecurityWarning => 'Amaran Keselamatan';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" adalah jenis fail boleh laku. Menyimpan dan menjalankannya boleh merosakkan peranti anda. Simpan juga?';
  }

  @override
  String get bubbleSaveAnyway => 'Simpan Juga';

  @override
  String bubbleSavedTo(String path) {
    return 'Disimpan ke $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Gagal menyimpan: $error';
  }

  @override
  String get bubbleNotEncrypted => 'TIDAK DISULITKAN';

  @override
  String get bubbleCorruptedImage => '[Imej rosak]';

  @override
  String get bubbleReplyPhoto => 'Foto';

  @override
  String get bubbleReplyVoice => 'Mesej suara';

  @override
  String get bubbleReplyVideo => 'Mesej video';

  @override
  String bubbleReadBy(String names) {
    return 'Dibaca oleh $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Dibaca oleh $count';
  }

  @override
  String get chatTileTapToStart => 'Ketik untuk mula berbual';

  @override
  String get chatTileMessageSent => 'Mesej dihantar';

  @override
  String get chatTileEncryptedMessage => 'Mesej yang disulitkan';

  @override
  String chatTileYouPrefix(String text) {
    return 'Anda: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Mesej suara';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Mesej suara ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Mesej yang disulitkan';

  @override
  String get groupNewGroup => 'Kumpulan Baharu';

  @override
  String get groupGroupName => 'Nama kumpulan';

  @override
  String get groupSelectMembers => 'Pilih ahli (min 2)';

  @override
  String get groupNoContactsYet => 'Tiada kenalan lagi. Tambah kenalan dahulu.';

  @override
  String get groupCreate => 'Cipta';

  @override
  String get groupLabel => 'Kumpulan';

  @override
  String get profileVerifyIdentity => 'Sahkan Identiti';

  @override
  String profileVerifyInstructions(String name) {
    return 'Bandingkan cap jari ini dengan $name melalui panggilan suara atau secara bersemuka. Jika kedua-dua nilai sepadan pada kedua-dua peranti, ketik \"Tandakan Sebagai Disahkan\".';
  }

  @override
  String get profileTheirKey => 'Kunci mereka';

  @override
  String get profileYourKey => 'Kunci anda';

  @override
  String get profileRemoveVerification => 'Buang Pengesahan';

  @override
  String get profileMarkAsVerified => 'Tandakan Sebagai Disahkan';

  @override
  String get profileAddressCopied => 'Alamat disalin';

  @override
  String get profileNoContactsToAdd =>
      'Tiada kenalan untuk ditambah — semua sudah menjadi ahli';

  @override
  String get profileAddMembers => 'Tambah Ahli';

  @override
  String profileAddCount(int count) {
    return 'Tambah ($count)';
  }

  @override
  String get profileRenameGroup => 'Namakan Semula Kumpulan';

  @override
  String get profileRename => 'Namakan Semula';

  @override
  String get profileRemoveMember => 'Buang ahli?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Buang $name daripada kumpulan ini?';
  }

  @override
  String get profileKick => 'Buang';

  @override
  String get profileSignalFingerprints => 'Cap Jari Signal';

  @override
  String get profileVerified => 'DISAHKAN';

  @override
  String get profileVerify => 'Sahkan';

  @override
  String get profileEdit => 'Sunting';

  @override
  String get profileNoSession =>
      'Tiada sesi ditubuhkan lagi — hantar mesej dahulu.';

  @override
  String get profileFingerprintCopied => 'Cap jari disalin';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count ahli$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Sahkan Nombor Keselamatan';

  @override
  String get profileShowContactQr => 'Tunjuk QR Kenalan';

  @override
  String profileContactAddress(String name) {
    return 'Alamat $name';
  }

  @override
  String get profileExportChatHistory => 'Eksport Sejarah Perbualan';

  @override
  String profileSavedTo(String path) {
    return 'Disimpan ke $path';
  }

  @override
  String get profileExportFailed => 'Eksport gagal';

  @override
  String get profileClearChatHistory => 'Kosongkan sejarah perbualan';

  @override
  String get profileDeleteGroup => 'Padam kumpulan';

  @override
  String get profileDeleteContact => 'Padam kenalan';

  @override
  String get profileLeaveGroup => 'Tinggalkan kumpulan';

  @override
  String get profileLeaveGroupBody =>
      'Anda akan dikeluarkan daripada kumpulan ini dan ia akan dipadam daripada kenalan anda.';

  @override
  String get groupInviteTitle => 'Jemputan kumpulan';

  @override
  String groupInviteBody(String from, String group) {
    return '$from menjemput anda untuk menyertai \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Terima';

  @override
  String get groupInviteDecline => 'Tolak';

  @override
  String get groupMemberLimitTitle => 'Terlalu ramai peserta';

  @override
  String groupMemberLimitBody(int count) {
    return 'Kumpulan ini akan mempunyai $count peserta. Panggilan mesh tersulit menyokong sehingga 6. Kumpulan yang lebih besar akan menggunakan Jitsi (bukan E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Tambah juga';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name menolak untuk menyertai \"$group\"';
  }

  @override
  String get transferTitle => 'Pindah ke Peranti Lain';

  @override
  String get transferInfoBox =>
      'Pindahkan identiti Signal dan kunci Nostr anda ke peranti baharu.\nSesi perbualan TIDAK dipindahkan — kerahsiaan hadapan dikekalkan.';

  @override
  String get transferSendFromThis => 'Hantar dari peranti ini';

  @override
  String get transferSendSubtitle =>
      'Peranti ini mempunyai kunci. Kongsi kod dengan peranti baharu.';

  @override
  String get transferReceiveOnThis => 'Terima pada peranti ini';

  @override
  String get transferReceiveSubtitle =>
      'Ini adalah peranti baharu. Masukkan kod dari peranti lama.';

  @override
  String get transferChooseMethod => 'Pilih Kaedah Pemindahan';

  @override
  String get transferLan => 'LAN (Rangkaian Sama)';

  @override
  String get transferLanSubtitle =>
      'Pantas dan terus. Kedua-dua peranti mesti berada pada Wi-Fi yang sama.';

  @override
  String get transferNostrRelay => 'Geganti Nostr';

  @override
  String get transferNostrRelaySubtitle =>
      'Berfungsi melalui sebarang rangkaian menggunakan geganti Nostr sedia ada.';

  @override
  String get transferRelayUrl => 'URL Geganti';

  @override
  String get transferEnterCode => 'Masukkan Kod Pemindahan';

  @override
  String get transferPasteCode => 'Tampal kod LAN:... atau NOS:... di sini';

  @override
  String get transferConnect => 'Sambung';

  @override
  String get transferGenerating => 'Menjana kod pemindahan…';

  @override
  String get transferShareCode => 'Kongsi kod ini dengan penerima:';

  @override
  String get transferCopyCode => 'Salin Kod';

  @override
  String get transferCodeCopied => 'Kod disalin ke papan keratan';

  @override
  String get transferWaitingReceiver => 'Menunggu penerima untuk menyambung…';

  @override
  String get transferConnectingSender => 'Menyambung ke penghantar…';

  @override
  String get transferVerifyBoth =>
      'Bandingkan kod ini pada kedua-dua peranti.\nJika ia sepadan, pemindahan adalah selamat.';

  @override
  String get transferComplete => 'Pemindahan Selesai';

  @override
  String get transferKeysImported => 'Kunci Diimport';

  @override
  String get transferCompleteSenderBody =>
      'Kunci anda kekal aktif pada peranti ini.\nPenerima kini boleh menggunakan identiti anda.';

  @override
  String get transferCompleteReceiverBody =>
      'Kunci berjaya diimport.\nMulakan semula aplikasi untuk menggunakan identiti baharu.';

  @override
  String get transferRestartApp => 'Mulakan Semula Aplikasi';

  @override
  String get transferFailed => 'Pemindahan Gagal';

  @override
  String get transferTryAgain => 'Cuba Semula';

  @override
  String get transferEnterRelayFirst => 'Masukkan URL geganti dahulu';

  @override
  String get transferPasteCodeFromSender =>
      'Tampal kod pemindahan daripada penghantar';

  @override
  String get menuReply => 'Balas';

  @override
  String get menuForward => 'Majukan';

  @override
  String get menuReact => 'Reaksi';

  @override
  String get menuCopy => 'Salin';

  @override
  String get menuEdit => 'Sunting';

  @override
  String get menuRetry => 'Cuba semula';

  @override
  String get menuCancelScheduled => 'Batal jadual';

  @override
  String get menuDelete => 'Padam';

  @override
  String get menuForwardTo => 'Majukan kepada…';

  @override
  String menuForwardedTo(String name) {
    return 'Dimajukan kepada $name';
  }

  @override
  String get menuScheduledMessages => 'Mesej dijadualkan';

  @override
  String get menuNoScheduledMessages => 'Tiada mesej dijadualkan';

  @override
  String menuSendsOn(String date) {
    return 'Akan dihantar pada $date';
  }

  @override
  String get menuDisappearingMessages => 'Mesej Hilang';

  @override
  String get menuDisappearingSubtitle =>
      'Mesej dipadam secara automatik selepas masa yang dipilih.';

  @override
  String get menuTtlOff => 'Mati';

  @override
  String get menuTtl1h => '1 jam';

  @override
  String get menuTtl24h => '24 jam';

  @override
  String get menuTtl7d => '7 hari';

  @override
  String get menuAttachPhoto => 'Foto';

  @override
  String get menuAttachFile => 'Fail';

  @override
  String get menuAttachVideo => 'Video';

  @override
  String get mediaTitle => 'Media';

  @override
  String get mediaFileLabel => 'FAIL';

  @override
  String mediaPhotosTab(int count) {
    return 'Foto ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Fail ($count)';
  }

  @override
  String get mediaNoPhotos => 'Tiada foto lagi';

  @override
  String get mediaNoFiles => 'Tiada fail lagi';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Disimpan ke Muat Turun/$name';
  }

  @override
  String get mediaFailedToSave => 'Gagal menyimpan fail';

  @override
  String get statusNewStatus => 'Status Baharu';

  @override
  String get statusPublish => 'Terbitkan';

  @override
  String get statusExpiresIn24h => 'Status tamat tempoh dalam 24 jam';

  @override
  String get statusWhatsOnYourMind => 'Apa yang anda fikirkan?';

  @override
  String get statusPhotoAttached => 'Foto dilampirkan';

  @override
  String get statusAttachPhoto => 'Lampirkan foto (pilihan)';

  @override
  String get statusEnterText => 'Sila masukkan teks untuk status anda.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Gagal memilih foto: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Gagal menerbitkan: $error';
  }

  @override
  String get panicSetPanicKey => 'Tetapkan Kunci Panik';

  @override
  String get panicEmergencySelfDestruct => 'Pemusnahan sendiri kecemasan';

  @override
  String get panicIrreversible => 'Tindakan ini tidak boleh dibatalkan';

  @override
  String get panicWarningBody =>
      'Memasukkan kunci ini di skrin kunci akan memadam SEMUA data dengan serta-merta — mesej, kenalan, kunci, identiti. Gunakan kunci yang berbeza daripada kata laluan biasa anda.';

  @override
  String get panicKeyHint => 'Kunci panik';

  @override
  String get panicConfirmHint => 'Sahkan kunci panik';

  @override
  String get panicMinChars =>
      'Kunci panik mestilah sekurang-kurangnya 8 aksara';

  @override
  String get panicKeysDoNotMatch => 'Kunci tidak sepadan';

  @override
  String get panicSetFailed => 'Gagal menyimpan kunci panik — sila cuba semula';

  @override
  String get passwordSetAppPassword => 'Tetapkan Kata Laluan Aplikasi';

  @override
  String get passwordProtectsMessages => 'Melindungi mesej anda semasa rehat';

  @override
  String get passwordInfoBanner =>
      'Diperlukan setiap kali anda membuka Pulse. Jika terlupa, data anda tidak boleh dipulihkan.';

  @override
  String get passwordHint => 'Kata laluan';

  @override
  String get passwordConfirmHint => 'Sahkan kata laluan';

  @override
  String get passwordSetButton => 'Tetapkan Kata Laluan';

  @override
  String get passwordSkipForNow => 'Langkau buat masa ini';

  @override
  String get passwordMinChars =>
      'Kata laluan mestilah sekurang-kurangnya 8 aksara';

  @override
  String get passwordNeedsVariety =>
      'Mesti mengandungi huruf, nombor dan aksara khas';

  @override
  String get passwordRequirements =>
      'Min. 8 aksara dengan huruf, nombor dan aksara khas';

  @override
  String get passwordsDoNotMatch => 'Kata laluan tidak sepadan';

  @override
  String get profileCardSaved => 'Profil disimpan!';

  @override
  String get profileCardE2eeIdentity => 'Identiti E2EE';

  @override
  String get profileCardDisplayName => 'Nama Paparan';

  @override
  String get profileCardDisplayNameHint => 'cth. Ahmad Ismail';

  @override
  String get profileCardAbout => 'Tentang';

  @override
  String get profileCardSaveProfile => 'Simpan Profil';

  @override
  String get profileCardYourName => 'Nama Anda';

  @override
  String get profileCardAddressCopied => 'Alamat disalin!';

  @override
  String get profileCardInboxAddress => 'Alamat Peti Masuk Anda';

  @override
  String get profileCardInboxAddresses => 'Alamat Peti Masuk Anda';

  @override
  String get profileCardShareAllAddresses =>
      'Kongsi Semua Alamat (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Kongsi dengan kenalan supaya mereka boleh menghantar mesej kepada anda.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Semua $count alamat disalin sebagai satu pautan!';
  }

  @override
  String get settingsMyProfile => 'Profil Saya';

  @override
  String get settingsYourInboxAddress => 'Alamat Peti Masuk Anda';

  @override
  String get settingsMyQrCode => 'Kongsi kenalan';

  @override
  String get settingsMyQrSubtitle =>
      'Kod QR dan pautan jemputan untuk alamat anda';

  @override
  String get settingsShareMyAddress => 'Kongsi Alamat Saya';

  @override
  String get settingsNoAddressYet =>
      'Tiada alamat lagi — simpan tetapan dahulu';

  @override
  String get settingsInviteLink => 'Pautan Jemputan';

  @override
  String get settingsRawAddress => 'Alamat Mentah';

  @override
  String get settingsCopyLink => 'Salin Pautan';

  @override
  String get settingsCopyAddress => 'Salin Alamat';

  @override
  String get settingsInviteLinkCopied => 'Pautan jemputan disalin';

  @override
  String get settingsAppearance => 'Penampilan';

  @override
  String get settingsThemeEngine => 'Enjin Tema';

  @override
  String get settingsThemeEngineSubtitle => 'Ubah suai warna & fon';

  @override
  String get settingsSignalProtocol => 'Protokol Signal';

  @override
  String get settingsSignalProtocolSubtitle =>
      'Kunci E2EE disimpan dengan selamat';

  @override
  String get settingsActive => 'AKTIF';

  @override
  String get settingsIdentityBackup => 'Sandaran Identiti';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Eksport atau import identiti Signal anda';

  @override
  String get settingsIdentityBackupBody =>
      'Eksport kunci identiti Signal anda ke kod sandaran, atau pulihkan daripada kod sedia ada.';

  @override
  String get settingsTransferDevice => 'Pindah ke Peranti Lain';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Pindahkan identiti anda melalui LAN atau geganti Nostr';

  @override
  String get settingsExportIdentity => 'Eksport Identiti';

  @override
  String get settingsExportIdentityBody =>
      'Salin kod sandaran ini dan simpan dengan selamat:';

  @override
  String get settingsSaveFile => 'Simpan Fail';

  @override
  String get settingsImportIdentity => 'Import Identiti';

  @override
  String get settingsImportIdentityBody =>
      'Tampal kod sandaran anda di bawah. Ini akan menimpa identiti semasa anda.';

  @override
  String get settingsPasteBackupCode => 'Tampal kod sandaran di sini…';

  @override
  String get settingsIdentityImported =>
      'Identiti + kenalan diimport! Mulakan semula aplikasi untuk menggunakannya.';

  @override
  String get settingsSecurity => 'Keselamatan';

  @override
  String get settingsAppPassword => 'Kata Laluan Aplikasi';

  @override
  String get settingsPasswordEnabled =>
      'Diaktifkan — diperlukan setiap kali membuka';

  @override
  String get settingsPasswordDisabled =>
      'Dinyahaktifkan — aplikasi dibuka tanpa kata laluan';

  @override
  String get settingsChangePassword => 'Tukar Kata Laluan';

  @override
  String get settingsChangePasswordSubtitle =>
      'Kemas kini kata laluan kunci aplikasi anda';

  @override
  String get settingsSetPanicKey => 'Tetapkan Kunci Panik';

  @override
  String get settingsChangePanicKey => 'Tukar Kunci Panik';

  @override
  String get settingsPanicKeySetSubtitle => 'Kemas kini kunci padam kecemasan';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Satu kunci yang memadam semua data dengan serta-merta';

  @override
  String get settingsRemovePanicKey => 'Buang Kunci Panik';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Nyahaktifkan pemusnahan sendiri kecemasan';

  @override
  String get settingsRemovePanicKeyBody =>
      'Pemusnahan sendiri kecemasan akan dinyahaktifkan. Anda boleh mengaktifkannya semula pada bila-bila masa.';

  @override
  String get settingsDisableAppPassword => 'Nyahaktifkan Kata Laluan Aplikasi';

  @override
  String get settingsEnterCurrentPassword =>
      'Masukkan kata laluan semasa anda untuk mengesahkan';

  @override
  String get settingsCurrentPassword => 'Kata laluan semasa';

  @override
  String get settingsIncorrectPassword => 'Kata laluan salah';

  @override
  String get settingsPasswordUpdated => 'Kata laluan dikemas kini';

  @override
  String get settingsChangePasswordProceed =>
      'Masukkan kata laluan semasa anda untuk meneruskan';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsBackupMessages => 'Sandaran Mesej';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Eksport sejarah mesej yang disulitkan ke fail';

  @override
  String get settingsRestoreMessages => 'Pulihkan Mesej';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Import mesej daripada fail sandaran';

  @override
  String get settingsExportKeys => 'Eksport Kunci';

  @override
  String get settingsExportKeysSubtitle =>
      'Simpan kunci identiti ke fail yang disulitkan';

  @override
  String get settingsImportKeys => 'Import Kunci';

  @override
  String get settingsImportKeysSubtitle =>
      'Pulihkan kunci identiti daripada fail yang dieksport';

  @override
  String get settingsBackupPassword => 'Kata laluan sandaran';

  @override
  String get settingsPasswordCannotBeEmpty => 'Kata laluan tidak boleh kosong';

  @override
  String get settingsPasswordMin4Chars =>
      'Kata laluan mestilah sekurang-kurangnya 4 aksara';

  @override
  String get settingsCallsTurn => 'Panggilan & TURN';

  @override
  String get settingsLocalNetwork => 'Rangkaian Tempatan';

  @override
  String get settingsCensorshipResistance => 'Rintangan Penapisan';

  @override
  String get settingsNetwork => 'Rangkaian';

  @override
  String get settingsProxyTunnels => 'Proksi & Terowong';

  @override
  String get settingsTurnServers => 'Pelayan TURN';

  @override
  String get settingsProviderTitle => 'Pembekal';

  @override
  String get settingsLanFallback => 'Pengganti LAN';

  @override
  String get settingsLanFallbackSubtitle =>
      'Siarkan kehadiran dan hantar mesej pada rangkaian tempatan apabila internet tidak tersedia. Nyahaktifkan pada rangkaian tidak dipercayai (Wi-Fi awam).';

  @override
  String get settingsBgDelivery => 'Penghantaran Latar Belakang';

  @override
  String get settingsBgDeliverySubtitle =>
      'Terus menerima mesej apabila aplikasi diminimumkan. Menunjukkan pemberitahuan berterusan.';

  @override
  String get settingsYourInboxProvider => 'Pembekal Peti Masuk Anda';

  @override
  String get settingsConnectionDetails => 'Butiran Sambungan';

  @override
  String get settingsSaveAndConnect => 'Simpan & Sambung';

  @override
  String get settingsSecondaryInboxes => 'Peti Masuk Sekunder';

  @override
  String get settingsAddSecondaryInbox => 'Tambah Peti Masuk Sekunder';

  @override
  String get settingsAdvanced => 'Lanjutan';

  @override
  String get settingsDiscover => 'Cari';

  @override
  String get settingsAbout => 'Tentang';

  @override
  String get settingsPrivacyPolicy => 'Dasar Privasi';

  @override
  String get settingsPrivacyPolicySubtitle => 'Cara Pulse melindungi data anda';

  @override
  String get settingsCrashReporting => 'Laporan ranap';

  @override
  String get settingsCrashReportingSubtitle =>
      'Hantar laporan ranap tanpa nama untuk membantu menambah baik Pulse. Tiada kandungan mesej atau kenalan yang dihantar.';

  @override
  String get settingsCrashReportingEnabled =>
      'Laporan ranap diaktifkan — mulakan semula aplikasi untuk menggunakan';

  @override
  String get settingsCrashReportingDisabled =>
      'Laporan ranap dinyahaktifkan — mulakan semula aplikasi untuk menggunakan';

  @override
  String get settingsSensitiveOperation => 'Operasi Sensitif';

  @override
  String get settingsSensitiveOperationBody =>
      'Kunci ini adalah identiti anda. Sesiapa yang mempunyai fail ini boleh menyamar sebagai anda. Simpan dengan selamat dan padamkan selepas pemindahan.';

  @override
  String get settingsIUnderstandContinue => 'Saya Faham, Teruskan';

  @override
  String get settingsReplaceIdentity => 'Ganti Identiti?';

  @override
  String get settingsReplaceIdentityBody =>
      'Ini akan menimpa kunci identiti semasa anda. Sesi Signal sedia ada anda akan menjadi tidak sah dan kenalan perlu menubuhkan semula penyulitan. Aplikasi perlu dimulakan semula.';

  @override
  String get settingsReplaceKeys => 'Ganti Kunci';

  @override
  String get settingsKeysImported => 'Kunci Diimport';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count kunci berjaya diimport. Sila mulakan semula aplikasi untuk menggunakan identiti baharu.';
  }

  @override
  String get settingsRestartNow => 'Mulakan Semula Sekarang';

  @override
  String get settingsLater => 'Kemudian';

  @override
  String get profileGroupLabel => 'Kumpulan';

  @override
  String get profileAddButton => 'Tambah';

  @override
  String get profileKickButton => 'Buang';

  @override
  String get dataSectionTitle => 'Data';

  @override
  String get dataBackupMessages => 'Sandaran Mesej';

  @override
  String get dataBackupPasswordSubtitle =>
      'Pilih kata laluan untuk menyulitkan sandaran mesej anda.';

  @override
  String get dataBackupConfirmLabel => 'Cipta Sandaran';

  @override
  String get dataCreatingBackup => 'Mencipta Sandaran';

  @override
  String get dataBackupPreparing => 'Menyediakan...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Mengeksport mesej $done daripada $total...';
  }

  @override
  String get dataBackupSavingFile => 'Menyimpan fail...';

  @override
  String get dataSaveMessageBackupDialog => 'Simpan Sandaran Mesej';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Sandaran disimpan ($count mesej)\n$path';
  }

  @override
  String get dataBackupFailed => 'Sandaran gagal — tiada data dieksport';

  @override
  String dataBackupFailedError(String error) {
    return 'Sandaran gagal: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Pilih Sandaran Mesej';

  @override
  String get dataInvalidBackupFile => 'Fail sandaran tidak sah (terlalu kecil)';

  @override
  String get dataNotValidBackupFile => 'Bukan fail sandaran Pulse yang sah';

  @override
  String get dataRestoreMessages => 'Pulihkan Mesej';

  @override
  String get dataRestorePasswordSubtitle =>
      'Masukkan kata laluan yang digunakan untuk mencipta sandaran ini.';

  @override
  String get dataRestoreConfirmLabel => 'Pulihkan';

  @override
  String get dataRestoringMessages => 'Memulihkan Mesej';

  @override
  String get dataRestoreDecrypting => 'Menyahsulit...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Mengimport mesej $done daripada $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Pemulihan gagal — kata laluan salah atau fail rosak';

  @override
  String dataRestoreSuccess(int count) {
    return '$count mesej baharu dipulihkan';
  }

  @override
  String get dataRestoreNothingNew =>
      'Tiada mesej baharu untuk diimport (semua sudah wujud)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Pemulihan gagal: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Pilih Eksport Kunci';

  @override
  String get dataNotValidKeyFile => 'Bukan fail eksport kunci Pulse yang sah';

  @override
  String get dataExportKeys => 'Eksport Kunci';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Pilih kata laluan untuk menyulitkan eksport kunci anda.';

  @override
  String get dataExportKeysConfirmLabel => 'Eksport';

  @override
  String get dataExportingKeys => 'Mengeksport Kunci';

  @override
  String get dataExportingKeysStatus => 'Menyulitkan kunci identiti...';

  @override
  String get dataSaveKeyExportDialog => 'Simpan Eksport Kunci';

  @override
  String dataKeysExportedTo(String path) {
    return 'Kunci dieksport ke:\n$path';
  }

  @override
  String get dataExportFailed => 'Eksport gagal — tiada kunci ditemui';

  @override
  String dataExportFailedError(String error) {
    return 'Eksport gagal: $error';
  }

  @override
  String get dataImportKeys => 'Import Kunci';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Masukkan kata laluan yang digunakan untuk menyulitkan eksport kunci ini.';

  @override
  String get dataImportKeysConfirmLabel => 'Import';

  @override
  String get dataImportingKeys => 'Mengimport Kunci';

  @override
  String get dataImportingKeysStatus => 'Menyahsulit kunci identiti...';

  @override
  String get dataImportFailed =>
      'Import gagal — kata laluan salah atau fail rosak';

  @override
  String dataImportFailedError(String error) {
    return 'Import gagal: $error';
  }

  @override
  String get securitySectionTitle => 'Keselamatan';

  @override
  String get securityIncorrectPassword => 'Kata laluan salah';

  @override
  String get securityPasswordUpdated => 'Kata laluan dikemas kini';

  @override
  String get appearanceSectionTitle => 'Penampilan';

  @override
  String appearanceExportFailed(String error) {
    return 'Eksport gagal: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Disimpan ke $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Gagal menyimpan: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Import gagal: $error';
  }

  @override
  String get aboutSectionTitle => 'Tentang';

  @override
  String get providerPublicKey => 'Kunci Awam';

  @override
  String get providerRelay => 'Geganti';

  @override
  String get providerAutoConfigured =>
      'Dikonfigurasi secara automatik daripada kata laluan pemulihan anda. Geganti ditemui secara automatik.';

  @override
  String get providerKeyStoredLocally =>
      'Kunci anda disimpan secara tempatan dalam storan selamat — tidak pernah dihantar ke mana-mana pelayan.';

  @override
  String get providerSessionInfo =>
      'Session Network — E2EE dengan penghalaan bawang. ID Session anda dijana secara automatik dan disimpan dengan selamat. Nod ditemui secara automatik daripada nod benih terbina dalam.';

  @override
  String get providerAdvanced => 'Lanjutan';

  @override
  String get providerSaveAndConnect => 'Simpan & Sambung';

  @override
  String get providerAddSecondaryInbox => 'Tambah Peti Masuk Sekunder';

  @override
  String get providerSecondaryInboxes => 'Peti Masuk Sekunder';

  @override
  String get providerYourInboxProvider => 'Pembekal Peti Masuk Anda';

  @override
  String get providerConnectionDetails => 'Butiran Sambungan';

  @override
  String get addContactTitle => 'Tambah Kenalan';

  @override
  String get addContactInviteLinkLabel => 'Pautan Jemputan atau Alamat';

  @override
  String get addContactTapToPaste => 'Ketik untuk tampal pautan jemputan';

  @override
  String get addContactPasteTooltip => 'Tampal dari papan keratan';

  @override
  String get addContactAddressDetected => 'Alamat kenalan dikesan';

  @override
  String addContactRoutesDetected(int count) {
    return '$count laluan dikesan — SmartRouter memilih yang terpantas';
  }

  @override
  String get addContactFetchingProfile => 'Mendapatkan profil…';

  @override
  String addContactProfileFound(String name) {
    return 'Ditemui: $name';
  }

  @override
  String get addContactNoProfileFound => 'Tiada profil ditemui';

  @override
  String get addContactDisplayNameLabel => 'Nama Paparan';

  @override
  String get addContactDisplayNameHint => 'Apa yang anda mahu panggil mereka?';

  @override
  String get addContactAddManually => 'Tambah alamat secara manual';

  @override
  String get addContactButton => 'Tambah Kenalan';

  @override
  String get networkDiagnosticsTitle => 'Diagnostik Rangkaian';

  @override
  String get networkDiagnosticsNostrRelays => 'Geganti Nostr';

  @override
  String get networkDiagnosticsDirect => 'Langsung';

  @override
  String get networkDiagnosticsTorOnly => 'Tor sahaja';

  @override
  String get networkDiagnosticsBest => 'Terbaik';

  @override
  String get networkDiagnosticsNone => 'tiada';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Status';

  @override
  String get networkDiagnosticsConnected => 'Disambungkan';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Menyambung $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Mati';

  @override
  String get networkDiagnosticsTransport => 'Pengangkutan';

  @override
  String get networkDiagnosticsInfrastructure => 'Infrastruktur';

  @override
  String get networkDiagnosticsSessionNodes => 'Nod Session';

  @override
  String get networkDiagnosticsTurnServers => 'Pelayan TURN';

  @override
  String get networkDiagnosticsLastProbe => 'Siasatan terakhir';

  @override
  String get networkDiagnosticsRunning => 'Berjalan...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Jalankan Diagnostik';

  @override
  String get networkDiagnosticsForceReprobe => 'Paksa Siasatan Semula Penuh';

  @override
  String get networkDiagnosticsJustNow => 'baru sahaja';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '${minutes}m lalu';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '${hours}j lalu';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '${days}h lalu';
  }

  @override
  String get homeNoEch => 'Tiada ECH';

  @override
  String get homeNoEchTooltip =>
      'Proksi uTLS tidak tersedia — ECH dinyahaktifkan.\nCap jari TLS boleh dilihat oleh DPI.';

  @override
  String get settingsTitle => 'Tetapan';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Disimpan & disambungkan ke $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Tor terbina dalam gagal dimulakan';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon gagal dimulakan';

  @override
  String get verifyTitle => 'Sahkan Nombor Keselamatan';

  @override
  String get verifyIdentityVerified => 'Identiti Disahkan';

  @override
  String get verifyNotYetVerified => 'Belum Disahkan';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Anda telah mengesahkan nombor keselamatan $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Bandingkan nombor ini dengan $name secara bersemuka atau melalui saluran yang dipercayai.';
  }

  @override
  String get verifyExplanation =>
      'Setiap perbualan mempunyai nombor keselamatan yang unik. Jika anda berdua melihat nombor yang sama pada peranti anda, sambungan anda disahkan hujung-ke-hujung.';

  @override
  String verifyContactKey(String name) {
    return 'Kunci $name';
  }

  @override
  String get verifyYourKey => 'Kunci Anda';

  @override
  String get verifyRemoveVerification => 'Buang Pengesahan';

  @override
  String get verifyMarkAsVerified => 'Tandakan Sebagai Disahkan';

  @override
  String verifyAfterReinstall(String name) {
    return 'Jika $name memasang semula aplikasi, nombor keselamatan akan berubah dan pengesahan akan dibuang secara automatik.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Hanya tandakan sebagai disahkan selepas membandingkan nombor dengan $name melalui panggilan suara atau secara bersemuka.';
  }

  @override
  String get verifyNoSession =>
      'Tiada sesi penyulitan ditubuhkan lagi. Hantar mesej dahulu untuk menjana nombor keselamatan.';

  @override
  String get verifyNoKeyAvailable => 'Tiada kunci tersedia';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Cap jari $label disalin';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL Pangkalan Data';

  @override
  String get providerOptionalHint => 'Pilihan';

  @override
  String get providerWebApiKeyLabel => 'Kunci API Web';

  @override
  String get providerOptionalForPublicDb => 'Pilihan untuk pangkalan data awam';

  @override
  String get providerRelayUrlLabel => 'URL Geganti';

  @override
  String get providerPrivateKeyLabel => 'Kunci Peribadi';

  @override
  String get providerPrivateKeyNsecLabel => 'Kunci Peribadi (nsec)';

  @override
  String get providerStorageNodeLabel => 'URL Nod Storan (pilihan)';

  @override
  String get providerStorageNodeHint =>
      'Biarkan kosong untuk nod benih terbina dalam';

  @override
  String get transferInvalidCodeFormat =>
      'Format kod tidak dikenali — mesti bermula dengan LAN: atau NOS:';

  @override
  String get profileCardFingerprintCopied => 'Cap jari disalin';

  @override
  String get profileCardAboutHint => 'Privasi diutamakan 🔒';

  @override
  String get profileCardSaveButton => 'Simpan Profil';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Eksport mesej, kenalan dan avatar yang disulitkan ke fail';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Audio';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Dihantar kepada $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Dihantar kepada $count';
  }

  @override
  String get groupStatusDialogTitle => 'Maklumat Mesej';

  @override
  String get groupStatusRead => 'Dibaca';

  @override
  String get groupStatusDelivered => 'Dihantar';

  @override
  String get groupStatusPending => 'Belum selesai';

  @override
  String get groupStatusNoData => 'Tiada maklumat penghantaran lagi';

  @override
  String get profileTransferAdmin => 'Jadikan Admin';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Jadikan $name admin baharu?';
  }

  @override
  String get profileTransferAdminBody =>
      'Anda akan kehilangan keistimewaan admin. Ini tidak boleh dibatalkan.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name kini adalah admin';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Dasar Privasi';

  @override
  String get privacyOverviewHeading => 'Gambaran Keseluruhan';

  @override
  String get privacyOverviewBody =>
      'Pulse ialah penghantar mesej tanpa pelayan dengan penyulitan hujung-ke-hujung. Privasi anda bukan sekadar ciri — ia adalah seni bina. Tiada pelayan Pulse. Tiada akaun disimpan di mana-mana. Tiada data dikumpul, dihantar kepada, atau disimpan oleh pembangun.';

  @override
  String get privacyDataCollectionHeading => 'Pengumpulan Data';

  @override
  String get privacyDataCollectionBody =>
      'Pulse mengumpul sifar data peribadi. Secara khusus:\n\n- Tiada e-mel, nombor telefon, atau nama sebenar diperlukan\n- Tiada analitik, penjejakan, atau telemetri\n- Tiada pengecam pengiklanan\n- Tiada akses senarai kenalan\n- Tiada sandaran awan (mesej hanya wujud pada peranti anda)\n- Tiada metadata dihantar ke mana-mana pelayan Pulse (tiada satu pun)';

  @override
  String get privacyEncryptionHeading => 'Penyulitan';

  @override
  String get privacyEncryptionBody =>
      'Semua mesej disulitkan menggunakan Protokol Signal (Double Ratchet dengan persetujuan kunci X3DH). Kunci penyulitan dijana dan disimpan secara eksklusif pada peranti anda. Tiada sesiapa — termasuk pembangun — boleh membaca mesej anda.';

  @override
  String get privacyNetworkHeading => 'Seni Bina Rangkaian';

  @override
  String get privacyNetworkBody =>
      'Pulse menggunakan penyesuai pengangkutan berfederasi (geganti Nostr, nod perkhidmatan Session/Oxen, Firebase Realtime Database, LAN). Pengangkutan ini hanya membawa teks sifir yang disulitkan. Pengendali geganti boleh melihat alamat IP dan jumlah trafik anda, tetapi tidak boleh menyahsulit kandungan mesej.\n\nApabila Tor diaktifkan, alamat IP anda juga tersembunyi daripada pengendali geganti.';

  @override
  String get privacyStunHeading => 'Pelayan STUN/TURN';

  @override
  String get privacyStunBody =>
      'Panggilan suara dan video menggunakan WebRTC dengan penyulitan DTLS-SRTP. Pelayan STUN (untuk menemui IP awam anda untuk sambungan rakan-ke-rakan) dan pelayan TURN (untuk mengalirkan media apabila sambungan langsung gagal) boleh melihat alamat IP dan tempoh panggilan anda, tetapi tidak boleh menyahsulit kandungan panggilan.\n\nAnda boleh mengkonfigurasi pelayan TURN anda sendiri di Tetapan untuk privasi maksimum.';

  @override
  String get privacyCrashHeading => 'Laporan Ranap';

  @override
  String get privacyCrashBody =>
      'Jika laporan ranap Sentry diaktifkan (melalui SENTRY_DSN masa binaan), laporan ranap tanpa nama mungkin dihantar. Ini tidak mengandungi kandungan mesej, maklumat kenalan, atau maklumat pengenalan peribadi. Laporan ranap boleh dinyahaktifkan pada masa binaan dengan menghilangkan DSN.';

  @override
  String get privacyPasswordHeading => 'Kata Laluan & Kunci';

  @override
  String get privacyPasswordBody =>
      'Kata laluan pemulihan anda digunakan untuk menghasilkan kunci kriptografi melalui Argon2id (KDF memori keras). Kata laluan tidak pernah dihantar ke mana-mana. Jika anda kehilangan kata laluan, akaun anda tidak boleh dipulihkan — tiada pelayan untuk menetapkan semula.';

  @override
  String get privacyFontsHeading => 'Fon';

  @override
  String get privacyFontsBody =>
      'Pulse membungkus semua fon secara tempatan. Tiada permintaan dibuat kepada Google Fonts atau mana-mana perkhidmatan fon luaran.';

  @override
  String get privacyThirdPartyHeading => 'Perkhidmatan Pihak Ketiga';

  @override
  String get privacyThirdPartyBody =>
      'Pulse tidak berintegrasi dengan mana-mana rangkaian pengiklanan, penyedia analitik, platform media sosial, atau broker data. Satu-satunya sambungan rangkaian adalah ke geganti pengangkutan yang anda konfigurasikan.';

  @override
  String get privacyOpenSourceHeading => 'Sumber Terbuka';

  @override
  String get privacyOpenSourceBody =>
      'Pulse ialah perisian sumber terbuka. Anda boleh mengaudit kod sumber lengkap untuk mengesahkan tuntutan privasi ini.';

  @override
  String get privacyContactHeading => 'Hubungi';

  @override
  String get privacyContactBody =>
      'Untuk soalan berkaitan privasi, buka isu di repositori projek.';

  @override
  String get privacyLastUpdated => 'Kemas kini terakhir: Mac 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Gagal menyimpan: $error';
  }

  @override
  String get themeEngineTitle => 'Enjin Tema';

  @override
  String get torBuiltInTitle => 'Tor Terbina Dalam';

  @override
  String get torConnectedSubtitle =>
      'Disambungkan — Nostr dialirkan melalui 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Menyambung… $pct%';
  }

  @override
  String get torNotRunning =>
      'Tidak berjalan — ketik suis untuk memulakan semula';

  @override
  String get torDescription =>
      'Mengalirkan Nostr melalui Tor (Snowflake untuk rangkaian ditapis)';

  @override
  String get torNetworkDiagnostics => 'Diagnostik Rangkaian';

  @override
  String get torTransportLabel => 'Pengangkutan: ';

  @override
  String get torPtAuto => 'Auto';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Biasa';

  @override
  String get torTimeoutLabel => 'Had masa: ';

  @override
  String get torInfoDescription =>
      'Apabila diaktifkan, sambungan Nostr WebSocket dialirkan melalui Tor (SOCKS5). Tor Browser mendengar pada 127.0.0.1:9150. Daemon tor kendiri menggunakan port 9050. Sambungan Firebase tidak terjejas.';

  @override
  String get torRouteNostrTitle => 'Alirkan Nostr melalui Tor';

  @override
  String get torManagedByBuiltin => 'Diurus oleh Tor Terbina Dalam';

  @override
  String get torActiveRouting => 'Aktif — trafik Nostr dialirkan melalui Tor';

  @override
  String get torDisabled => 'Dinyahaktifkan';

  @override
  String get torProxySocks5 => 'Proksi Tor (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Hos Proksi';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser: port 9150  •  daemon tor: port 9050';

  @override
  String get torForceNostrTitle => 'Halakan mesej melalui Tor';

  @override
  String get torForceNostrSubtitle =>
      'Semua sambungan Nostr relay akan melalui Tor. Lebih perlahan tetapi menyembunyikan IP anda daripada relay.';

  @override
  String get torForceNostrDisabled => 'Tor perlu diaktifkan terlebih dahulu';

  @override
  String get torForcePulseTitle => 'Halakan Pulse relay melalui Tor';

  @override
  String get torForcePulseSubtitle =>
      'Semua sambungan Pulse relay akan melalui Tor. Lebih perlahan tetapi menyembunyikan IP anda daripada pelayan.';

  @override
  String get torForcePulseDisabled => 'Tor perlu diaktifkan terlebih dahulu';

  @override
  String get i2pProxySocks5 => 'Proksi I2P (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P menggunakan SOCKS5 pada port 4447 secara lalai. Sambung ke geganti Nostr melalui I2P outproxy (cth. relay.damus.i2p) untuk berkomunikasi dengan pengguna di mana-mana pengangkutan. Tor diutamakan apabila kedua-duanya diaktifkan.';

  @override
  String get i2pRouteNostrTitle => 'Alirkan Nostr melalui I2P';

  @override
  String get i2pActiveRouting => 'Aktif — trafik Nostr dialirkan melalui I2P';

  @override
  String get i2pDisabled => 'Dinyahaktifkan';

  @override
  String get i2pProxyHostLabel => 'Hos Proksi';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'Port SOCKS5 lalai penghala I2P: 4447';

  @override
  String get customProxySocks5 => 'Proksi Tersuai (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Proksi tersuai mengalirkan trafik melalui V2Ray/Xray/Shadowsocks anda. CF Worker bertindak sebagai proksi geganti peribadi pada Cloudflare CDN — GFW melihat *.workers.dev, bukan geganti sebenar.';

  @override
  String get customSocks5ProxyTitle => 'Proksi SOCKS5 Tersuai';

  @override
  String get customProxyActive => 'Aktif — trafik dialirkan melalui SOCKS5';

  @override
  String get customProxyDisabled => 'Dinyahaktifkan';

  @override
  String get customProxyHostLabel => 'Hos Proksi';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Domain Worker (pilihan)';

  @override
  String get customWorkerHelpTitle =>
      'Cara menyebarkan CF Worker relay (percuma)';

  @override
  String get customWorkerScriptCopied => 'Skrip disalin!';

  @override
  String get customWorkerStep1 =>
      '1. Pergi ke dash.cloudflare.com → Workers & Pages\n2. Create Worker → tampal skrip ini:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → salin domain (cth. my-relay.user.workers.dev)\n4. Tampal domain di atas → Simpan\n\nAplikasi menyambung secara automatik: wss://domain/?r=relay_url\nGFW melihat: sambungan ke *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Disambungkan — SOCKS5 pada 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Menyambung…';

  @override
  String get psiphonNotRunning =>
      'Tidak berjalan — ketik suis untuk memulakan semula';

  @override
  String get psiphonDescription =>
      'Terowong pantas (~3s bootstrap, 2000+ VPS berputar)';

  @override
  String get turnCommunityServers => 'Pelayan TURN Komuniti';

  @override
  String get turnCustomServer => 'Pelayan TURN Tersuai (BYOD)';

  @override
  String get turnInfoDescription =>
      'Pelayan TURN hanya mengalirkan strim yang sudah disulitkan (DTLS-SRTP). Pengendali geganti melihat IP dan jumlah trafik anda, tetapi tidak boleh menyahsulit panggilan. TURN hanya digunakan apabila P2P langsung gagal (~15–20% sambungan).';

  @override
  String get turnFreeLabel => 'PERCUMA';

  @override
  String get turnServerUrlLabel => 'URL Pelayan TURN';

  @override
  String get turnServerUrlHint => 'turn:pelayan-anda.com:3478 atau turns:...';

  @override
  String get turnUsernameLabel => 'Nama pengguna';

  @override
  String get turnPasswordLabel => 'Kata laluan';

  @override
  String get turnOptionalHint => 'Pilihan';

  @override
  String get turnCustomInfo =>
      'Hos sendiri coturn pada mana-mana VPS \$5/bulan untuk kawalan maksimum. Kelayakan disimpan secara tempatan.';

  @override
  String get themePickerAppearance => 'Penampilan';

  @override
  String get themePickerAccentColor => 'Warna Aksen';

  @override
  String get themeModeLight => 'Cerah';

  @override
  String get themeModeDark => 'Gelap';

  @override
  String get themeModeSystem => 'Sistem';

  @override
  String get themeDynamicPresets => 'Pratetap';

  @override
  String get themeDynamicPrimaryColor => 'Warna Utama';

  @override
  String get themeDynamicBorderRadius => 'Jejari Sempadan';

  @override
  String get themeDynamicFont => 'Fon';

  @override
  String get themeDynamicAppearance => 'Penampilan';

  @override
  String get themeDynamicUiStyle => 'Gaya UI';

  @override
  String get themeDynamicUiStyleDescription =>
      'Mengawal rupa dialog, suis dan penunjuk.';

  @override
  String get themeDynamicSharp => 'Tajam';

  @override
  String get themeDynamicRound => 'Bulat';

  @override
  String get themeDynamicModeDark => 'Gelap';

  @override
  String get themeDynamicModeLight => 'Cerah';

  @override
  String get themeDynamicModeAuto => 'Auto';

  @override
  String get themeDynamicPlatformAuto => 'Auto';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'URL Firebase tidak sah. Dijangkakan https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'URL geganti tidak sah. Dijangkakan wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'URL pelayan Pulse tidak sah. Dijangkakan https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'URL Pelayan';

  @override
  String get providerPulseServerUrlHint => 'https://pelayan-anda:8443';

  @override
  String get providerPulseInviteLabel => 'Kod Jemputan';

  @override
  String get providerPulseInviteHint => 'Kod jemputan (jika diperlukan)';

  @override
  String get providerPulseInfo =>
      'Geganti hos sendiri. Kunci dihasilkan daripada kata laluan pemulihan anda.';

  @override
  String get providerScreenTitle => 'Peti Masuk';

  @override
  String get providerSecondaryInboxesHeader => 'PETI MASUK SEKUNDER';

  @override
  String get providerSecondaryInboxesInfo =>
      'Peti masuk sekunder menerima mesej serentak untuk redundansi.';

  @override
  String get providerRemoveTooltip => 'Buang';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... atau hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... atau kunci peribadi hex';

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
  String get emojiNoRecent => 'Tiada emoji terkini';

  @override
  String get emojiSearchHint => 'Cari emoji...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Ketik untuk berbual';

  @override
  String get imageViewerSaveToDownloads => 'Simpan ke Muat Turun';

  @override
  String imageViewerSavedTo(String path) {
    return 'Disimpan ke $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsLanguageSubtitle => 'Bahasa paparan aplikasi';

  @override
  String get settingsLanguageSystem => 'Lalai sistem';

  @override
  String get onboardingLanguageTitle => 'Pilih bahasa anda';

  @override
  String get onboardingLanguageSubtitle =>
      'Anda boleh menukar ini kemudian di Tetapan';

  @override
  String get videoNoteRecord => 'Rakam mesej video';

  @override
  String get videoNoteTapToRecord => 'Ketuk untuk merakam';

  @override
  String get videoNoteTapToStop => 'Ketuk untuk berhenti';

  @override
  String get videoNoteCameraPermission => 'Kebenaran kamera ditolak';

  @override
  String get videoNoteMaxDuration => 'Maksimum 30 saat';

  @override
  String get videoNoteNotSupported =>
      'Nota video tidak disokong pada platform ini';

  @override
  String get navChats => 'Sembang';

  @override
  String get navUpdates => 'Kemaskini';

  @override
  String get navCalls => 'Panggilan';

  @override
  String get filterAll => 'Semua';

  @override
  String get filterUnread => 'Belum dibaca';

  @override
  String get filterGroups => 'Kumpulan';

  @override
  String get callsNoRecent => 'Tiada panggilan terkini';

  @override
  String get callsEmptySubtitle => 'Sejarah panggilan anda akan muncul di sini';

  @override
  String get appBarEncrypted => 'disulitkan hujung ke hujung';

  @override
  String get newStatus => 'Status baharu';

  @override
  String get newCall => 'Panggilan baharu';

  @override
  String get joinChannelTitle => 'Sertai Saluran';

  @override
  String get joinChannelDescription => 'URL SALURAN';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'Mendapatkan maklumat saluran…';

  @override
  String get joinChannelNotFound => 'Saluran tidak ditemui di URL ini';

  @override
  String get joinChannelNetworkError => 'Tidak dapat menghubungi pelayan';

  @override
  String get joinChannelAlreadyJoined => 'Sudah menyertai';

  @override
  String get joinChannelButton => 'Sertai';

  @override
  String get channelFeedEmpty => 'Belum ada siaran';

  @override
  String get channelLeave => 'Tinggalkan Saluran';

  @override
  String get channelLeaveConfirm =>
      'Tinggalkan saluran ini? Siaran yang di-cache akan dipadam.';

  @override
  String get channelInfo => 'Maklumat Saluran';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'disunting';

  @override
  String get channelLoadMore => 'Muat lagi';

  @override
  String get channelSearchPosts => 'Cari siaran…';

  @override
  String get channelNoResults => 'Tiada siaran sepadan';

  @override
  String get channelUrl => 'URL saluran';

  @override
  String get channelCreated => 'Disertai';

  @override
  String channelPostCount(int count) {
    return '$count siaran';
  }

  @override
  String get channelCopyUrl => 'Salin URL';

  @override
  String get setupNext => 'Seterusnya';

  @override
  String get setupKeyWarning =>
      'A recovery key will be generated for you. It is the only way to restore your account on a new device — there is no server, no password reset.';

  @override
  String get setupKeyTitle => 'Your Recovery Key';

  @override
  String get setupKeySubtitle =>
      'Write this key down and store it in a safe place. You will need it to restore your account on a new device.';

  @override
  String get setupKeyCopied => 'Disalin!';

  @override
  String get setupKeyWroteItDown => 'Sudah saya catat';

  @override
  String get setupKeyWarnBody =>
      'Write this key down as a backup. You can also view it later in Settings → Security.';

  @override
  String get setupVerifyTitle => 'Verify Recovery Key';

  @override
  String get setupVerifySubtitle =>
      'Re-enter your recovery key to confirm you saved it correctly.';

  @override
  String get setupVerifyButton => 'Sahkan';

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
  String get settingsViewRecoveryKey => 'Lihat kunci pemulihan';

  @override
  String get settingsViewRecoveryKeySubtitle =>
      'Tunjukkan kunci pemulihan akaun anda';

  @override
  String get settingsRecoveryKeyNotStored =>
      'Kunci pemulihan tidak tersedia (dicipta sebelum ciri ini)';

  @override
  String get settingsRecoveryKeyWarning =>
      'Simpan kunci ini dengan selamat. Sesiapa yang memilikinya boleh memulihkan akaun anda pada peranti lain.';

  @override
  String get replaceIdentityTitle => 'Replace existing identity?';

  @override
  String get replaceIdentityBodyRestore =>
      'An identity already exists on this device. Restoring will permanently replace your current Nostr key and Oxen seed. All contacts will lose the ability to reach your current address.\n\nThis cannot be undone.';

  @override
  String get replaceIdentityBodyCreate =>
      'An identity already exists on this device. Creating a new one will permanently replace your current Nostr key and Oxen seed. All contacts will lose the ability to reach your current address.\n\nThis cannot be undone.';

  @override
  String get replace => 'Replace';

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
