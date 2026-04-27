// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Cari pesan...';

  @override
  String get search => 'Cari';

  @override
  String get clearSearch => 'Hapus pencarian';

  @override
  String get closeSearch => 'Tutup pencarian';

  @override
  String get moreOptions => 'Opsi lainnya';

  @override
  String get back => 'Kembali';

  @override
  String get cancel => 'Batal';

  @override
  String get close => 'Tutup';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get remove => 'Hapus';

  @override
  String get save => 'Simpan';

  @override
  String get add => 'Tambah';

  @override
  String get copy => 'Salin';

  @override
  String get skip => 'Lewati';

  @override
  String get done => 'Selesai';

  @override
  String get apply => 'Terapkan';

  @override
  String get export => 'Ekspor';

  @override
  String get import => 'Impor';

  @override
  String get homeNewGroup => 'Grup baru';

  @override
  String get homeSettings => 'Pengaturan';

  @override
  String get homeSearching => 'Mencari pesan...';

  @override
  String get homeNoResults => 'Tidak ada hasil';

  @override
  String get homeNoChatHistory => 'Belum ada riwayat chat';

  @override
  String homeTransportSwitched(String address) {
    return 'Kanal pengiriman dialihkan → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name sedang menelepon...';
  }

  @override
  String get homeAccept => 'Terima';

  @override
  String get homeDecline => 'Tolak';

  @override
  String get homeLoadEarlier => 'Muat pesan sebelumnya';

  @override
  String get homeChats => 'Chat';

  @override
  String get homeSelectConversation => 'Pilih percakapan';

  @override
  String get homeNoChatsYet => 'Belum ada chat';

  @override
  String get homeAddContactToStart => 'Tambahkan kontak untuk mulai chat';

  @override
  String get homeNewChat => 'Chat Baru';

  @override
  String get homeNewChatTooltip => 'Chat baru';

  @override
  String get homeIncomingCallTitle => 'Panggilan Masuk';

  @override
  String get homeIncomingGroupCallTitle => 'Panggilan Grup Masuk';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — panggilan grup masuk';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Tidak ada chat yang cocok dengan \"$query\"';
  }

  @override
  String get homeSectionChats => 'Chat';

  @override
  String get homeSectionMessages => 'Pesan';

  @override
  String get homeDbEncryptionUnavailable =>
      'Enkripsi database tidak tersedia — instal SQLCipher untuk perlindungan penuh';

  @override
  String get chatFileTooLargeGroup =>
      'File di atas 512 KB tidak didukung di chat grup';

  @override
  String get chatLargeFile => 'File Besar';

  @override
  String get chatCancel => 'Batal';

  @override
  String get chatSend => 'Kirim';

  @override
  String get chatFileTooLarge => 'File terlalu besar — ukuran maksimum 100 MB';

  @override
  String get chatMicDenied => 'Izin mikrofon ditolak';

  @override
  String get chatVoiceFailed =>
      'Gagal menyimpan pesan suara — periksa penyimpanan';

  @override
  String get chatScheduleFuture => 'Waktu terjadwal harus di masa depan';

  @override
  String get chatToday => 'Hari ini';

  @override
  String get chatYesterday => 'Kemarin';

  @override
  String get chatEdited => 'diedit';

  @override
  String get chatYou => 'Anda';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'File ini berukuran $size MB. Mengirim file besar mungkin lambat di beberapa jaringan. Lanjutkan?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Kunci keamanan $name telah berubah. Ketuk untuk memverifikasi.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Tidak dapat mengenkripsi pesan ke $name — pesan tidak terkirim.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Nomor keamanan $name telah berubah. Ketuk untuk memverifikasi.';
  }

  @override
  String get chatNoMessagesFound => 'Tidak ada pesan ditemukan';

  @override
  String get chatMessagesE2ee => 'Pesan dienkripsi ujung-ke-ujung';

  @override
  String get chatSayHello => 'Ucapkan halo';

  @override
  String get appBarOnline => 'daring';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'mengetik';

  @override
  String get appBarSearchMessages => 'Cari pesan...';

  @override
  String get appBarMute => 'Bisukan';

  @override
  String get appBarUnmute => 'Bunyikan';

  @override
  String get appBarMedia => 'Media';

  @override
  String get appBarDisappearing => 'Pesan sementara';

  @override
  String get appBarDisappearingOn => 'Sementara: aktif';

  @override
  String get appBarGroupSettings => 'Pengaturan grup';

  @override
  String get appBarSearchTooltip => 'Cari pesan';

  @override
  String get appBarVoiceCall => 'Panggilan suara';

  @override
  String get appBarVideoCall => 'Panggilan video';

  @override
  String get inputMessage => 'Pesan...';

  @override
  String get inputAttachFile => 'Lampirkan file';

  @override
  String get inputSendMessage => 'Kirim pesan';

  @override
  String get inputRecordVoice => 'Rekam pesan suara';

  @override
  String get inputSendVoice => 'Kirim pesan suara';

  @override
  String get inputCancelReply => 'Batalkan balasan';

  @override
  String get inputCancelEdit => 'Batalkan edit';

  @override
  String get inputCancelRecording => 'Batalkan rekaman';

  @override
  String get inputRecording => 'Merekam…';

  @override
  String get inputEditingMessage => 'Mengedit pesan';

  @override
  String get inputPhoto => 'Foto';

  @override
  String get inputVoiceMessage => 'Pesan suara';

  @override
  String get inputFile => 'File';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count pesan terjadwal$_temp0';
  }

  @override
  String get callInitializing => 'Memulai panggilan…';

  @override
  String get callConnecting => 'Menghubungkan…';

  @override
  String get callConnectingRelay => 'Menghubungkan (relay)…';

  @override
  String get callSwitchingRelay => 'Beralih ke mode relay…';

  @override
  String get callConnectionFailed => 'Koneksi gagal';

  @override
  String get callReconnecting => 'Menghubungkan ulang…';

  @override
  String get callEnded => 'Panggilan berakhir';

  @override
  String get callLive => 'Langsung';

  @override
  String get callEnd => 'Akhiri';

  @override
  String get callEndCall => 'Akhiri panggilan';

  @override
  String get callMute => 'Bisukan';

  @override
  String get callUnmute => 'Bunyikan';

  @override
  String get callSpeaker => 'Pengeras suara';

  @override
  String get callCameraOn => 'Kamera Nyala';

  @override
  String get callCameraOff => 'Kamera Mati';

  @override
  String get callShareScreen => 'Bagikan Layar';

  @override
  String get callStopShare => 'Hentikan Berbagi';

  @override
  String callTorBackup(String duration) {
    return 'Tor cadangan · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor cadangan aktif — jalur utama tidak tersedia';

  @override
  String get callDirectFailed =>
      'Koneksi langsung gagal — beralih ke mode relay…';

  @override
  String get callTurnUnreachable =>
      'Server TURN tidak dapat dijangkau. Tambahkan TURN kustom di Pengaturan → Lanjutan.';

  @override
  String get callRelayMode => 'Mode relay aktif (jaringan terbatas)';

  @override
  String get callStarting => 'Memulai panggilan…';

  @override
  String get callConnectingToGroup => 'Menghubungkan ke grup…';

  @override
  String get callGroupOpenedInBrowser => 'Panggilan grup dibuka di browser';

  @override
  String get callCouldNotOpenBrowser => 'Tidak dapat membuka browser';

  @override
  String get callInviteLinkSent =>
      'Tautan undangan dikirim ke semua anggota grup.';

  @override
  String get callOpenLinkManually =>
      'Buka tautan di atas secara manual atau ketuk untuk mencoba lagi.';

  @override
  String get callJitsiNotE2ee =>
      'Panggilan Jitsi TIDAK dienkripsi ujung-ke-ujung';

  @override
  String get callRetryOpenBrowser => 'Coba buka browser lagi';

  @override
  String get callClose => 'Tutup';

  @override
  String get callCamOn => 'Kamera nyala';

  @override
  String get callCamOff => 'Kamera mati';

  @override
  String get noConnection => 'Tidak ada koneksi — pesan akan diantrekan';

  @override
  String get connected => 'Terhubung';

  @override
  String get connecting => 'Menghubungkan…';

  @override
  String get disconnected => 'Terputus';

  @override
  String get offlineBanner =>
      'Tidak ada koneksi — pesan akan diantrekan dan dikirim saat online kembali';

  @override
  String get lanModeBanner => 'Mode LAN — Tanpa internet · Jaringan lokal saja';

  @override
  String get probeCheckingNetwork => 'Memeriksa koneksi jaringan…';

  @override
  String get probeDiscoveringRelays =>
      'Mencari relay melalui direktori komunitas…';

  @override
  String get probeStartingTor => 'Memulai Tor untuk bootstrap…';

  @override
  String get probeFindingRelaysTor =>
      'Mencari relay yang dapat dijangkau melalui Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'Jaringan siap — ditemukan $count relay$_temp0';
  }

  @override
  String get probeNoRelaysFound =>
      'Tidak ditemukan relay yang dapat dijangkau — pesan mungkin tertunda';

  @override
  String get jitsiWarningTitle => 'Tidak dienkripsi ujung-ke-ujung';

  @override
  String get jitsiWarningBody =>
      'Panggilan Jitsi Meet tidak dienkripsi oleh Pulse. Gunakan hanya untuk percakapan tidak sensitif.';

  @override
  String get jitsiConfirm => 'Tetap gabung';

  @override
  String get jitsiGroupWarningTitle => 'Tidak dienkripsi ujung-ke-ujung';

  @override
  String get jitsiGroupWarningBody =>
      'Panggilan ini memiliki terlalu banyak peserta untuk mesh terenkripsi bawaan.\n\nTautan Jitsi Meet akan dibuka di browser Anda. Jitsi TIDAK dienkripsi ujung-ke-ujung — server dapat melihat panggilan Anda.';

  @override
  String get jitsiContinueAnyway => 'Tetap lanjutkan';

  @override
  String get retry => 'Coba lagi';

  @override
  String get setupCreateAnonymousAccount => 'Buat akun anonim';

  @override
  String get setupTapToChangeColor => 'Ketuk untuk ganti warna';

  @override
  String get setupReqMinLength => 'Minimal 16 karakter';

  @override
  String get setupReqVariety => '3 dari 4: huruf besar, kecil, angka, simbol';

  @override
  String get setupReqMatch => 'Kata sandi cocok';

  @override
  String get setupYourNickname => 'Nama panggilan Anda';

  @override
  String get setupRecoveryPassword => 'Kata sandi pemulihan (min. 16)';

  @override
  String get setupConfirmPassword => 'Konfirmasi kata sandi';

  @override
  String get setupMin16Chars => 'Minimal 16 karakter';

  @override
  String get setupPasswordsDoNotMatch => 'Kata sandi tidak cocok';

  @override
  String get setupEntropyWeak => 'Lemah';

  @override
  String get setupEntropyOk => 'Cukup';

  @override
  String get setupEntropyStrong => 'Kuat';

  @override
  String get setupEntropyWeakNeedsVariety => 'Lemah (perlu 3 jenis karakter)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bit)';
  }

  @override
  String get setupPasswordWarning =>
      'Kata sandi ini adalah satu-satunya cara untuk memulihkan akun Anda. Tidak ada server — tidak bisa reset kata sandi. Ingat atau catat.';

  @override
  String get setupCreateAccount => 'Buat akun';

  @override
  String get setupAlreadyHaveAccount => 'Sudah punya akun? ';

  @override
  String get setupRestore => 'Pulihkan →';

  @override
  String get restoreTitle => 'Pulihkan akun';

  @override
  String get restoreInfoBanner =>
      'Masukkan kata sandi pemulihan — alamat Anda (Nostr + Session) akan dipulihkan otomatis. Kontak dan pesan hanya disimpan secara lokal.';

  @override
  String get restoreNewNickname => 'Nama panggilan baru (bisa diubah nanti)';

  @override
  String get restoreButton => 'Pulihkan akun';

  @override
  String get lockTitle => 'Pulse terkunci';

  @override
  String get lockSubtitle => 'Masukkan kata sandi untuk melanjutkan';

  @override
  String get lockPasswordHint => 'Kata sandi';

  @override
  String get lockUnlock => 'Buka kunci';

  @override
  String get lockPanicHint =>
      'Lupa kata sandi? Masukkan kunci darurat untuk menghapus semua data.';

  @override
  String get lockTooManyAttempts =>
      'Terlalu banyak percobaan. Menghapus semua data…';

  @override
  String get lockWrongPassword => 'Kata sandi salah';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Kata sandi salah — $attempts/$max percobaan';
  }

  @override
  String get onboardingSkip => 'Lewati';

  @override
  String get onboardingNext => 'Berikutnya';

  @override
  String get onboardingGetStarted => 'Buat Akun';

  @override
  String get onboardingWelcomeTitle => 'Selamat datang di Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Aplikasi pesan terdesentralisasi dengan enkripsi ujung-ke-ujung.\n\nTanpa server pusat. Tanpa pengumpulan data. Tanpa pintu belakang.\nPercakapan Anda hanya milik Anda.';

  @override
  String get onboardingTransportTitle => 'Tidak Terikat Kanal';

  @override
  String get onboardingTransportBody =>
      'Gunakan Firebase, Nostr, atau keduanya sekaligus.\n\nPesan dikirim otomatis melalui berbagai jaringan. Dukungan Tor dan I2P bawaan untuk ketahanan sensor.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Setiap pesan dienkripsi dengan Signal Protocol (Double Ratchet + X3DH) untuk forward secrecy.\n\nDitambah lapisan Kyber-1024 — algoritma post-quantum standar NIST — melindungi dari komputer kuantum masa depan.';

  @override
  String get onboardingKeysTitle => 'Anda Pemilik Kunci Anda';

  @override
  String get onboardingKeysBody =>
      'Kunci identitas Anda tidak pernah meninggalkan perangkat.\n\nSidik jari Signal memungkinkan verifikasi kontak secara out-of-band. TOFU (Trust On First Use) mendeteksi perubahan kunci secara otomatis.';

  @override
  String get onboardingThemeTitle => 'Pilih Tampilan Anda';

  @override
  String get onboardingThemeBody =>
      'Pilih tema dan warna aksen. Anda bisa mengubahnya kapan saja di Pengaturan.';

  @override
  String get contactsNewChat => 'Chat baru';

  @override
  String get contactsAddContact => 'Tambah kontak';

  @override
  String get contactsSearchHint => 'Cari...';

  @override
  String get contactsNewGroup => 'Grup baru';

  @override
  String get contactsNoContactsYet => 'Belum ada kontak';

  @override
  String get contactsAddHint => 'Ketuk + untuk menambahkan alamat seseorang';

  @override
  String get contactsNoMatch => 'Tidak ada kontak yang cocok';

  @override
  String get contactsRemoveTitle => 'Hapus kontak';

  @override
  String contactsRemoveMessage(String name) {
    return 'Hapus $name?';
  }

  @override
  String get contactsRemove => 'Hapus';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count kontak$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Buka Tautan';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Buka URL ini di browser?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Buka';

  @override
  String get bubbleSecurityWarning => 'Peringatan Keamanan';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" adalah file yang dapat dieksekusi. Menyimpan dan menjalankannya bisa membahayakan perangkat. Tetap simpan?';
  }

  @override
  String get bubbleSaveAnyway => 'Tetap Simpan';

  @override
  String bubbleSavedTo(String path) {
    return 'Disimpan ke $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Gagal menyimpan: $error';
  }

  @override
  String get bubbleNotEncrypted => 'TIDAK TERENKRIPSI';

  @override
  String get bubbleCorruptedImage => '[Gambar rusak]';

  @override
  String get bubbleReplyPhoto => 'Foto';

  @override
  String get bubbleReplyVoice => 'Pesan suara';

  @override
  String get bubbleReplyVideo => 'Pesan video';

  @override
  String bubbleReadBy(String names) {
    return 'Dibaca oleh $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Dibaca oleh $count orang';
  }

  @override
  String get chatTileTapToStart => 'Ketuk untuk mulai chat';

  @override
  String get chatTileMessageSent => 'Pesan terkirim';

  @override
  String get chatTileEncryptedMessage => 'Pesan terenkripsi';

  @override
  String chatTileYouPrefix(String text) {
    return 'Anda: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Pesan suara';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Pesan suara ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Pesan terenkripsi';

  @override
  String get groupNewGroup => 'Grup Baru';

  @override
  String get groupGroupName => 'Nama grup';

  @override
  String get groupSelectMembers => 'Pilih anggota (min. 2)';

  @override
  String get groupNoContactsYet =>
      'Belum ada kontak. Tambahkan kontak terlebih dahulu.';

  @override
  String get groupCreate => 'Buat';

  @override
  String get groupLabel => 'Grup';

  @override
  String get profileVerifyIdentity => 'Verifikasi Identitas';

  @override
  String profileVerifyInstructions(String name) {
    return 'Bandingkan sidik jari ini dengan $name melalui panggilan suara atau secara langsung. Jika kedua nilai cocok di kedua perangkat, ketuk \"Tandai Terverifikasi\".';
  }

  @override
  String get profileTheirKey => 'Kunci mereka';

  @override
  String get profileYourKey => 'Kunci Anda';

  @override
  String get profileRemoveVerification => 'Hapus Verifikasi';

  @override
  String get profileMarkAsVerified => 'Tandai Terverifikasi';

  @override
  String get profileAddressCopied => 'Alamat disalin';

  @override
  String get profileNoContactsToAdd =>
      'Tidak ada kontak untuk ditambahkan — semua sudah menjadi anggota';

  @override
  String get profileAddMembers => 'Tambah Anggota';

  @override
  String profileAddCount(int count) {
    return 'Tambah ($count)';
  }

  @override
  String get profileRenameGroup => 'Ganti Nama Grup';

  @override
  String get profileRename => 'Ganti nama';

  @override
  String get profileRemoveMember => 'Hapus anggota?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Hapus $name dari grup ini?';
  }

  @override
  String get profileKick => 'Keluarkan';

  @override
  String get profileSignalFingerprints => 'Sidik Jari Signal';

  @override
  String get profileVerified => 'TERVERIFIKASI';

  @override
  String get profileVerify => 'Verifikasi';

  @override
  String get profileEdit => 'Edit';

  @override
  String get profileNoSession =>
      'Belum ada sesi — kirim pesan terlebih dahulu.';

  @override
  String get profileFingerprintCopied => 'Sidik jari disalin';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count anggota$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Verifikasi Nomor Keamanan';

  @override
  String get profileShowContactQr => 'Tampilkan QR Kontak';

  @override
  String profileContactAddress(String name) {
    return 'Alamat $name';
  }

  @override
  String get profileExportChatHistory => 'Ekspor Riwayat Chat';

  @override
  String profileSavedTo(String path) {
    return 'Disimpan ke $path';
  }

  @override
  String get profileExportFailed => 'Ekspor gagal';

  @override
  String get profileClearChatHistory => 'Hapus riwayat chat';

  @override
  String get profileDeleteGroup => 'Hapus grup';

  @override
  String get profileDeleteContact => 'Hapus kontak';

  @override
  String get profileLeaveGroup => 'Keluar dari grup';

  @override
  String get profileLeaveGroupBody =>
      'Anda akan dihapus dari grup ini dan grup akan dihapus dari kontak Anda.';

  @override
  String get groupInviteTitle => 'Undangan grup';

  @override
  String groupInviteBody(String from, String group) {
    return '$from mengundang Anda untuk bergabung ke \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Terima';

  @override
  String get groupInviteDecline => 'Tolak';

  @override
  String get groupMemberLimitTitle => 'Terlalu banyak peserta';

  @override
  String groupMemberLimitBody(int count) {
    return 'Grup ini akan memiliki $count peserta. Panggilan mesh terenkripsi mendukung hingga 6. Grup lebih besar akan menggunakan Jitsi (tanpa E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Tetap tambahkan';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name menolak bergabung ke \"$group\"';
  }

  @override
  String get transferTitle => 'Transfer ke Perangkat Lain';

  @override
  String get transferInfoBox =>
      'Pindahkan identitas Signal dan kunci Nostr ke perangkat baru.\nSesi chat TIDAK ditransfer — forward secrecy dipertahankan.';

  @override
  String get transferSendFromThis => 'Kirim dari perangkat ini';

  @override
  String get transferSendSubtitle =>
      'Perangkat ini memiliki kunci. Bagikan kode dengan perangkat baru.';

  @override
  String get transferReceiveOnThis => 'Terima di perangkat ini';

  @override
  String get transferReceiveSubtitle =>
      'Ini adalah perangkat baru. Masukkan kode dari perangkat lama.';

  @override
  String get transferChooseMethod => 'Pilih Metode Transfer';

  @override
  String get transferLan => 'LAN (Jaringan yang Sama)';

  @override
  String get transferLanSubtitle =>
      'Cepat dan langsung. Kedua perangkat harus di Wi-Fi yang sama.';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'Berfungsi melalui jaringan apa pun menggunakan Nostr relay yang ada.';

  @override
  String get transferRelayUrl => 'URL Relay';

  @override
  String get transferEnterCode => 'Masukkan Kode Transfer';

  @override
  String get transferPasteCode => 'Tempel kode LAN:... atau NOS:... di sini';

  @override
  String get transferConnect => 'Hubungkan';

  @override
  String get transferGenerating => 'Membuat kode transfer…';

  @override
  String get transferShareCode => 'Bagikan kode ini dengan penerima:';

  @override
  String get transferCopyCode => 'Salin Kode';

  @override
  String get transferCodeCopied => 'Kode disalin ke clipboard';

  @override
  String get transferWaitingReceiver => 'Menunggu penerima terhubung…';

  @override
  String get transferConnectingSender => 'Menghubungkan ke pengirim…';

  @override
  String get transferVerifyBoth =>
      'Bandingkan kode ini di kedua perangkat.\nJika cocok, transfer aman.';

  @override
  String get transferComplete => 'Transfer Selesai';

  @override
  String get transferKeysImported => 'Kunci Diimpor';

  @override
  String get transferCompleteSenderBody =>
      'Kunci Anda tetap aktif di perangkat ini.\nPenerima sekarang bisa menggunakan identitas Anda.';

  @override
  String get transferCompleteReceiverBody =>
      'Kunci berhasil diimpor.\nMulai ulang aplikasi untuk menerapkan identitas baru.';

  @override
  String get transferRestartApp => 'Mulai Ulang Aplikasi';

  @override
  String get transferFailed => 'Transfer Gagal';

  @override
  String get transferTryAgain => 'Coba Lagi';

  @override
  String get transferEnterRelayFirst => 'Masukkan URL relay terlebih dahulu';

  @override
  String get transferPasteCodeFromSender =>
      'Tempel kode transfer dari pengirim';

  @override
  String get menuReply => 'Balas';

  @override
  String get menuForward => 'Teruskan';

  @override
  String get menuReact => 'Reaksi';

  @override
  String get menuCopy => 'Salin';

  @override
  String get menuEdit => 'Edit';

  @override
  String get menuRetry => 'Coba lagi';

  @override
  String get menuCancelScheduled => 'Batalkan jadwal';

  @override
  String get menuDelete => 'Hapus';

  @override
  String get menuForwardTo => 'Teruskan ke…';

  @override
  String menuForwardedTo(String name) {
    return 'Diteruskan ke $name';
  }

  @override
  String get menuScheduledMessages => 'Pesan terjadwal';

  @override
  String get menuNoScheduledMessages => 'Tidak ada pesan terjadwal';

  @override
  String menuSendsOn(String date) {
    return 'Dikirim pada $date';
  }

  @override
  String get menuDisappearingMessages => 'Pesan Sementara';

  @override
  String get menuDisappearingSubtitle =>
      'Pesan otomatis terhapus setelah waktu yang dipilih.';

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
  String get menuAttachFile => 'File';

  @override
  String get menuAttachVideo => 'Video';

  @override
  String get mediaTitle => 'Media';

  @override
  String get mediaFileLabel => 'FILE';

  @override
  String mediaPhotosTab(int count) {
    return 'Foto ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'File ($count)';
  }

  @override
  String get mediaNoPhotos => 'Belum ada foto';

  @override
  String get mediaNoFiles => 'Belum ada file';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Disimpan ke Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'Gagal menyimpan file';

  @override
  String get statusNewStatus => 'Status Baru';

  @override
  String get statusPublish => 'Publikasikan';

  @override
  String get statusExpiresIn24h => 'Status kedaluwarsa dalam 24 jam';

  @override
  String get statusWhatsOnYourMind => 'Apa yang Anda pikirkan?';

  @override
  String get statusPhotoAttached => 'Foto terlampir';

  @override
  String get statusAttachPhoto => 'Lampirkan foto (opsional)';

  @override
  String get statusEnterText => 'Silakan masukkan teks untuk status Anda.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Gagal memilih foto: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Gagal mempublikasikan: $error';
  }

  @override
  String get panicSetPanicKey => 'Atur Kunci Darurat';

  @override
  String get panicEmergencySelfDestruct => 'Penghancuran diri darurat';

  @override
  String get panicIrreversible => 'Tindakan ini tidak dapat dibatalkan';

  @override
  String get panicWarningBody =>
      'Memasukkan kunci ini di layar kunci akan langsung menghapus SEMUA data — pesan, kontak, kunci, identitas. Gunakan kunci yang berbeda dari kata sandi biasa.';

  @override
  String get panicKeyHint => 'Kunci darurat';

  @override
  String get panicConfirmHint => 'Konfirmasi kunci darurat';

  @override
  String get panicMinChars => 'Kunci darurat minimal 8 karakter';

  @override
  String get panicKeysDoNotMatch => 'Kunci tidak cocok';

  @override
  String get panicSetFailed =>
      'Gagal menyimpan kunci darurat — silakan coba lagi';

  @override
  String get passwordSetAppPassword => 'Atur Kata Sandi Aplikasi';

  @override
  String get passwordProtectsMessages =>
      'Melindungi pesan Anda saat tidak digunakan';

  @override
  String get passwordInfoBanner =>
      'Diperlukan setiap kali membuka Pulse. Jika lupa, data tidak dapat dipulihkan.';

  @override
  String get passwordHint => 'Kata sandi';

  @override
  String get passwordConfirmHint => 'Konfirmasi kata sandi';

  @override
  String get passwordSetButton => 'Atur Kata Sandi';

  @override
  String get passwordSkipForNow => 'Lewati untuk sekarang';

  @override
  String get passwordMinChars => 'Kata sandi minimal 8 karakter';

  @override
  String get passwordNeedsVariety =>
      'Harus menyertakan huruf, angka, dan karakter khusus';

  @override
  String get passwordRequirements =>
      'Min. 8 karakter dengan huruf, angka, dan karakter khusus';

  @override
  String get passwordsDoNotMatch => 'Kata sandi tidak cocok';

  @override
  String get profileCardSaved => 'Profil tersimpan!';

  @override
  String get profileCardE2eeIdentity => 'Identitas E2EE';

  @override
  String get profileCardDisplayName => 'Nama Tampilan';

  @override
  String get profileCardDisplayNameHint => 'Mis. Budi Santoso';

  @override
  String get profileCardAbout => 'Tentang';

  @override
  String get profileCardSaveProfile => 'Simpan Profil';

  @override
  String get profileCardYourName => 'Nama Anda';

  @override
  String get profileCardAddressCopied => 'Alamat disalin!';

  @override
  String get profileCardInboxAddress => 'Alamat Kotak Masuk Anda';

  @override
  String get profileCardInboxAddresses => 'Alamat Kotak Masuk Anda';

  @override
  String get profileCardShareAllAddresses =>
      'Bagikan Semua Alamat (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Bagikan dengan kontak agar mereka bisa mengirim pesan kepada Anda.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Semua $count alamat disalin sebagai satu tautan!';
  }

  @override
  String get settingsMyProfile => 'Profil Saya';

  @override
  String get settingsYourInboxAddress => 'Alamat Kotak Masuk Anda';

  @override
  String get settingsMyQrCode => 'Bagikan kontak';

  @override
  String get settingsMyQrSubtitle =>
      'Kode QR dan tautan undangan untuk alamat Anda';

  @override
  String get settingsShareMyAddress => 'Bagikan Alamat Saya';

  @override
  String get settingsNoAddressYet =>
      'Belum ada alamat — simpan pengaturan terlebih dahulu';

  @override
  String get settingsInviteLink => 'Tautan Undangan';

  @override
  String get settingsRawAddress => 'Alamat Mentah';

  @override
  String get settingsCopyLink => 'Salin Tautan';

  @override
  String get settingsCopyAddress => 'Salin Alamat';

  @override
  String get settingsInviteLinkCopied => 'Tautan undangan disalin';

  @override
  String get settingsAppearance => 'Tampilan';

  @override
  String get settingsThemeEngine => 'Mesin Tema';

  @override
  String get settingsThemeEngineSubtitle => 'Sesuaikan warna & font';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle =>
      'Kunci E2EE disimpan dengan aman';

  @override
  String get settingsActive => 'AKTIF';

  @override
  String get settingsIdentityBackup => 'Cadangan Identitas';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Ekspor atau impor identitas Signal';

  @override
  String get settingsIdentityBackupBody =>
      'Ekspor kunci identitas Signal ke kode cadangan, atau pulihkan dari yang sudah ada.';

  @override
  String get settingsTransferDevice => 'Transfer ke Perangkat Lain';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Pindahkan identitas melalui LAN atau Nostr relay';

  @override
  String get settingsExportIdentity => 'Ekspor Identitas';

  @override
  String get settingsExportIdentityBody =>
      'Salin kode cadangan ini dan simpan dengan aman:';

  @override
  String get settingsSaveFile => 'Simpan File';

  @override
  String get settingsImportIdentity => 'Impor Identitas';

  @override
  String get settingsImportIdentityBody =>
      'Tempel kode cadangan di bawah. Ini akan menimpa identitas Anda saat ini.';

  @override
  String get settingsPasteBackupCode => 'Tempel kode cadangan di sini…';

  @override
  String get settingsIdentityImported =>
      'Identitas + kontak diimpor! Mulai ulang aplikasi untuk menerapkan.';

  @override
  String get settingsSecurity => 'Keamanan';

  @override
  String get settingsAppPassword => 'Kata Sandi Aplikasi';

  @override
  String get settingsPasswordEnabled =>
      'Diaktifkan — diperlukan setiap peluncuran';

  @override
  String get settingsPasswordDisabled =>
      'Dinonaktifkan — aplikasi terbuka tanpa kata sandi';

  @override
  String get settingsChangePassword => 'Ubah Kata Sandi';

  @override
  String get settingsChangePasswordSubtitle =>
      'Perbarui kata sandi kunci aplikasi';

  @override
  String get settingsSetPanicKey => 'Atur Kunci Darurat';

  @override
  String get settingsChangePanicKey => 'Ubah Kunci Darurat';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Perbarui kunci penghapusan darurat';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Satu kunci yang langsung menghapus semua data';

  @override
  String get settingsRemovePanicKey => 'Hapus Kunci Darurat';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Nonaktifkan penghancuran diri darurat';

  @override
  String get settingsRemovePanicKeyBody =>
      'Penghancuran diri darurat akan dinonaktifkan. Anda bisa mengaktifkannya kembali kapan saja.';

  @override
  String get settingsDisableAppPassword => 'Nonaktifkan Kata Sandi Aplikasi';

  @override
  String get settingsEnterCurrentPassword =>
      'Masukkan kata sandi saat ini untuk mengonfirmasi';

  @override
  String get settingsCurrentPassword => 'Kata sandi saat ini';

  @override
  String get settingsIncorrectPassword => 'Kata sandi salah';

  @override
  String get settingsPasswordUpdated => 'Kata sandi diperbarui';

  @override
  String get settingsChangePasswordProceed =>
      'Masukkan kata sandi saat ini untuk melanjutkan';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsBackupMessages => 'Cadangkan Pesan';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Ekspor riwayat pesan terenkripsi ke file';

  @override
  String get settingsRestoreMessages => 'Pulihkan Pesan';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Impor pesan dari file cadangan';

  @override
  String get settingsExportKeys => 'Ekspor Kunci';

  @override
  String get settingsExportKeysSubtitle =>
      'Simpan kunci identitas ke file terenkripsi';

  @override
  String get settingsImportKeys => 'Impor Kunci';

  @override
  String get settingsImportKeysSubtitle =>
      'Pulihkan kunci identitas dari file yang diekspor';

  @override
  String get settingsBackupPassword => 'Kata sandi cadangan';

  @override
  String get settingsPasswordCannotBeEmpty => 'Kata sandi tidak boleh kosong';

  @override
  String get settingsPasswordMin4Chars => 'Kata sandi minimal 4 karakter';

  @override
  String get settingsCallsTurn => 'Panggilan & TURN';

  @override
  String get settingsLocalNetwork => 'Jaringan Lokal';

  @override
  String get settingsCensorshipResistance => 'Ketahanan Sensor';

  @override
  String get settingsNetwork => 'Jaringan';

  @override
  String get settingsProxyTunnels => 'Proxy & Terowongan';

  @override
  String get settingsTurnServers => 'Server TURN';

  @override
  String get settingsProviderTitle => 'Penyedia';

  @override
  String get settingsLanFallback => 'LAN Cadangan';

  @override
  String get settingsLanFallbackSubtitle =>
      'Siarkan kehadiran dan kirim pesan melalui jaringan lokal saat internet tidak tersedia. Nonaktifkan di jaringan tidak tepercaya (Wi-Fi publik).';

  @override
  String get settingsBgDelivery => 'Pengiriman Latar Belakang';

  @override
  String get settingsBgDeliverySubtitle =>
      'Tetap menerima pesan saat aplikasi diminimalkan. Menampilkan notifikasi permanen.';

  @override
  String get settingsYourInboxProvider => 'Penyedia Kotak Masuk Anda';

  @override
  String get settingsConnectionDetails => 'Detail Koneksi';

  @override
  String get settingsSaveAndConnect => 'Simpan & Hubungkan';

  @override
  String get settingsSecondaryInboxes => 'Kotak Masuk Sekunder';

  @override
  String get settingsAddSecondaryInbox => 'Tambah Kotak Masuk Sekunder';

  @override
  String get settingsAdvanced => 'Lanjutan';

  @override
  String get settingsDiscover => 'Temukan';

  @override
  String get settingsAbout => 'Tentang';

  @override
  String get settingsPrivacyPolicy => 'Kebijakan Privasi';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Bagaimana Pulse melindungi data Anda';

  @override
  String get settingsCrashReporting => 'Laporan kerusakan';

  @override
  String get settingsCrashReportingSubtitle =>
      'Kirim laporan kerusakan anonim untuk membantu meningkatkan Pulse. Tidak ada konten pesan atau kontak yang dikirim.';

  @override
  String get settingsCrashReportingEnabled =>
      'Laporan kerusakan diaktifkan — mulai ulang aplikasi untuk menerapkan';

  @override
  String get settingsCrashReportingDisabled =>
      'Laporan kerusakan dinonaktifkan — mulai ulang aplikasi untuk menerapkan';

  @override
  String get settingsSensitiveOperation => 'Operasi Sensitif';

  @override
  String get settingsSensitiveOperationBody =>
      'Kunci-kunci ini adalah identitas Anda. Siapa pun yang memiliki file ini bisa menyamar sebagai Anda. Simpan dengan aman dan hapus setelah transfer.';

  @override
  String get settingsIUnderstandContinue => 'Saya Mengerti, Lanjutkan';

  @override
  String get settingsReplaceIdentity => 'Ganti Identitas?';

  @override
  String get settingsReplaceIdentityBody =>
      'Ini akan menimpa kunci identitas Anda saat ini. Sesi Signal yang ada akan dibatalkan dan kontak perlu membangun ulang enkripsi. Aplikasi perlu dimulai ulang.';

  @override
  String get settingsReplaceKeys => 'Ganti Kunci';

  @override
  String get settingsKeysImported => 'Kunci Diimpor';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count kunci berhasil diimpor. Silakan mulai ulang aplikasi untuk menginisialisasi dengan identitas baru.';
  }

  @override
  String get settingsRestartNow => 'Mulai Ulang Sekarang';

  @override
  String get settingsLater => 'Nanti';

  @override
  String get profileGroupLabel => 'Grup';

  @override
  String get profileAddButton => 'Tambah';

  @override
  String get profileKickButton => 'Keluarkan';

  @override
  String get dataSectionTitle => 'Data';

  @override
  String get dataBackupMessages => 'Cadangkan Pesan';

  @override
  String get dataBackupPasswordSubtitle =>
      'Pilih kata sandi untuk mengenkripsi cadangan Anda.';

  @override
  String get dataBackupConfirmLabel => 'Buat Cadangan';

  @override
  String get dataCreatingBackup => 'Membuat Cadangan';

  @override
  String get dataBackupPreparing => 'Mempersiapkan...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Mengekspor pesan $done dari $total...';
  }

  @override
  String get dataBackupSavingFile => 'Menyimpan file...';

  @override
  String get dataSaveMessageBackupDialog => 'Simpan Cadangan Pesan';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Cadangan tersimpan ($count pesan)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Pencadangan gagal — tidak ada data yang diekspor';

  @override
  String dataBackupFailedError(String error) {
    return 'Pencadangan gagal: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Pilih Cadangan Pesan';

  @override
  String get dataInvalidBackupFile =>
      'File cadangan tidak valid (terlalu kecil)';

  @override
  String get dataNotValidBackupFile => 'Bukan file cadangan Pulse yang valid';

  @override
  String get dataRestoreMessages => 'Pulihkan Pesan';

  @override
  String get dataRestorePasswordSubtitle =>
      'Masukkan kata sandi yang digunakan untuk membuat cadangan ini.';

  @override
  String get dataRestoreConfirmLabel => 'Pulihkan';

  @override
  String get dataRestoringMessages => 'Memulihkan Pesan';

  @override
  String get dataRestoreDecrypting => 'Mendekripsi...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Mengimpor pesan $done dari $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Pemulihan gagal — kata sandi salah atau file rusak';

  @override
  String dataRestoreSuccess(int count) {
    return 'Berhasil memulihkan $count pesan baru';
  }

  @override
  String get dataRestoreNothingNew =>
      'Tidak ada pesan baru untuk diimpor (semua sudah ada)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Pemulihan gagal: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Pilih Ekspor Kunci';

  @override
  String get dataNotValidKeyFile => 'Bukan file ekspor kunci Pulse yang valid';

  @override
  String get dataExportKeys => 'Ekspor Kunci';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Pilih kata sandi untuk mengenkripsi ekspor kunci.';

  @override
  String get dataExportKeysConfirmLabel => 'Ekspor';

  @override
  String get dataExportingKeys => 'Mengekspor Kunci';

  @override
  String get dataExportingKeysStatus => 'Mengenkripsi kunci identitas...';

  @override
  String get dataSaveKeyExportDialog => 'Simpan Ekspor Kunci';

  @override
  String dataKeysExportedTo(String path) {
    return 'Kunci diekspor ke:\n$path';
  }

  @override
  String get dataExportFailed => 'Ekspor gagal — tidak ada kunci ditemukan';

  @override
  String dataExportFailedError(String error) {
    return 'Ekspor gagal: $error';
  }

  @override
  String get dataImportKeys => 'Impor Kunci';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Masukkan kata sandi yang digunakan untuk mengenkripsi ekspor kunci ini.';

  @override
  String get dataImportKeysConfirmLabel => 'Impor';

  @override
  String get dataImportingKeys => 'Mengimpor Kunci';

  @override
  String get dataImportingKeysStatus => 'Mendekripsi kunci identitas...';

  @override
  String get dataImportFailed =>
      'Impor gagal — kata sandi salah atau file rusak';

  @override
  String dataImportFailedError(String error) {
    return 'Impor gagal: $error';
  }

  @override
  String get securitySectionTitle => 'Keamanan';

  @override
  String get securityIncorrectPassword => 'Kata sandi salah';

  @override
  String get securityPasswordUpdated => 'Kata sandi diperbarui';

  @override
  String get appearanceSectionTitle => 'Tampilan';

  @override
  String appearanceExportFailed(String error) {
    return 'Ekspor gagal: $error';
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
    return 'Impor gagal: $error';
  }

  @override
  String get aboutSectionTitle => 'Tentang';

  @override
  String get providerPublicKey => 'Kunci Publik';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Dikonfigurasi otomatis dari kata sandi pemulihan Anda. Relay ditemukan otomatis.';

  @override
  String get providerKeyStoredLocally =>
      'Kunci Anda disimpan secara lokal di penyimpanan aman — tidak pernah dikirim ke server mana pun.';

  @override
  String get providerSessionInfo =>
      'Session Network — E2EE dengan onion routing. ID Session Anda dibuat secara otomatis dan disimpan dengan aman. Node ditemukan secara otomatis dari node seed bawaan.';

  @override
  String get providerAdvanced => 'Lanjutan';

  @override
  String get providerSaveAndConnect => 'Simpan & Hubungkan';

  @override
  String get providerAddSecondaryInbox => 'Tambah Kotak Masuk Sekunder';

  @override
  String get providerSecondaryInboxes => 'Kotak Masuk Sekunder';

  @override
  String get providerYourInboxProvider => 'Penyedia Kotak Masuk Anda';

  @override
  String get providerConnectionDetails => 'Detail Koneksi';

  @override
  String get addContactTitle => 'Tambah Kontak';

  @override
  String get addContactInviteLinkLabel => 'Tautan Undangan atau Alamat';

  @override
  String get addContactTapToPaste => 'Ketuk untuk menempel tautan undangan';

  @override
  String get addContactPasteTooltip => 'Tempel dari clipboard';

  @override
  String get addContactAddressDetected => 'Alamat kontak terdeteksi';

  @override
  String addContactRoutesDetected(int count) {
    return '$count rute terdeteksi — SmartRouter memilih yang tercepat';
  }

  @override
  String get addContactFetchingProfile => 'Mengambil profil…';

  @override
  String addContactProfileFound(String name) {
    return 'Ditemukan: $name';
  }

  @override
  String get addContactNoProfileFound => 'Profil tidak ditemukan';

  @override
  String get addContactDisplayNameLabel => 'Nama Tampilan';

  @override
  String get addContactDisplayNameHint => 'Anda ingin memanggil mereka apa?';

  @override
  String get addContactAddManually => 'Tambahkan alamat secara manual';

  @override
  String get addContactButton => 'Tambah Kontak';

  @override
  String get networkDiagnosticsTitle => 'Diagnostik Jaringan';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr Relay';

  @override
  String get networkDiagnosticsDirect => 'Langsung';

  @override
  String get networkDiagnosticsTorOnly => 'Hanya Tor';

  @override
  String get networkDiagnosticsBest => 'Terbaik';

  @override
  String get networkDiagnosticsNone => 'tidak ada';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Status';

  @override
  String get networkDiagnosticsConnected => 'Terhubung';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Menghubungkan $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Mati';

  @override
  String get networkDiagnosticsTransport => 'Kanal';

  @override
  String get networkDiagnosticsInfrastructure => 'Infrastruktur';

  @override
  String get networkDiagnosticsSessionNodes => 'Node Session';

  @override
  String get networkDiagnosticsTurnServers => 'Server TURN';

  @override
  String get networkDiagnosticsLastProbe => 'Pemeriksaan terakhir';

  @override
  String get networkDiagnosticsRunning => 'Berjalan...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Jalankan Diagnostik';

  @override
  String get networkDiagnosticsForceReprobe => 'Paksa Pemeriksaan Ulang';

  @override
  String get networkDiagnosticsJustNow => 'baru saja';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes menit lalu';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours jam lalu';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days hari lalu';
  }

  @override
  String get homeNoEch => 'Tanpa ECH';

  @override
  String get homeNoEchTooltip =>
      'Proxy uTLS tidak tersedia — ECH dinonaktifkan.\nSidik jari TLS terlihat oleh DPI.';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Tersimpan & terhubung ke $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Tor bawaan gagal memulai';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon gagal memulai';

  @override
  String get verifyTitle => 'Verifikasi Nomor Keamanan';

  @override
  String get verifyIdentityVerified => 'Identitas Terverifikasi';

  @override
  String get verifyNotYetVerified => 'Belum Terverifikasi';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Anda telah memverifikasi nomor keamanan $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Bandingkan angka-angka ini dengan $name secara langsung atau melalui saluran tepercaya.';
  }

  @override
  String get verifyExplanation =>
      'Setiap percakapan memiliki nomor keamanan unik. Jika keduanya melihat angka yang sama di perangkat masing-masing, koneksi terverifikasi ujung-ke-ujung.';

  @override
  String verifyContactKey(String name) {
    return 'Kunci $name';
  }

  @override
  String get verifyYourKey => 'Kunci Anda';

  @override
  String get verifyRemoveVerification => 'Hapus Verifikasi';

  @override
  String get verifyMarkAsVerified => 'Tandai Terverifikasi';

  @override
  String verifyAfterReinstall(String name) {
    return 'Jika $name menginstal ulang aplikasi, nomor keamanan akan berubah dan verifikasi akan dihapus otomatis.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Tandai terverifikasi hanya setelah membandingkan angka dengan $name melalui panggilan suara atau secara langsung.';
  }

  @override
  String get verifyNoSession =>
      'Belum ada sesi enkripsi. Kirim pesan terlebih dahulu untuk membuat nomor keamanan.';

  @override
  String get verifyNoKeyAvailable => 'Tidak ada kunci tersedia';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Sidik jari $label disalin';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL Database';

  @override
  String get providerOptionalHint => 'Opsional';

  @override
  String get providerWebApiKeyLabel => 'Web API Key';

  @override
  String get providerOptionalForPublicDb => 'Opsional untuk DB publik';

  @override
  String get providerRelayUrlLabel => 'URL Relay';

  @override
  String get providerPrivateKeyLabel => 'Kunci Privat';

  @override
  String get providerPrivateKeyNsecLabel => 'Kunci Privat (nsec)';

  @override
  String get providerStorageNodeLabel => 'URL Node Penyimpanan (opsional)';

  @override
  String get providerStorageNodeHint => 'Kosongkan untuk seed node bawaan';

  @override
  String get transferInvalidCodeFormat =>
      'Format kode tidak dikenali — harus dimulai dengan LAN: atau NOS:';

  @override
  String get profileCardFingerprintCopied => 'Sidik jari disalin';

  @override
  String get profileCardAboutHint => 'Privasi yang utama 🔒';

  @override
  String get profileCardSaveButton => 'Simpan Profil';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Ekspor pesan terenkripsi, kontak, dan avatar ke file';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Audio';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Terkirim ke $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Terkirim ke $count orang';
  }

  @override
  String get groupStatusDialogTitle => 'Info Pesan';

  @override
  String get groupStatusRead => 'Dibaca';

  @override
  String get groupStatusDelivered => 'Terkirim';

  @override
  String get groupStatusPending => 'Tertunda';

  @override
  String get groupStatusNoData => 'Belum ada informasi pengiriman';

  @override
  String get profileTransferAdmin => 'Jadikan Admin';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Jadikan $name admin baru?';
  }

  @override
  String get profileTransferAdminBody =>
      'Anda akan kehilangan hak admin. Tidak bisa dibatalkan.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name sekarang adalah admin';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Kebijakan Privasi';

  @override
  String get privacyOverviewHeading => 'Ringkasan';

  @override
  String get privacyOverviewBody =>
      'Pulse adalah aplikasi pesan terenkripsi ujung-ke-ujung tanpa server. Privasi Anda bukan sekadar fitur — ini adalah arsitekturnya. Tidak ada server Pulse. Tidak ada akun yang disimpan di mana pun. Tidak ada data yang dikumpulkan, dikirim, atau disimpan oleh pengembang.';

  @override
  String get privacyDataCollectionHeading => 'Pengumpulan Data';

  @override
  String get privacyDataCollectionBody =>
      'Pulse tidak mengumpulkan data pribadi apa pun. Secara spesifik:\n\n- Tidak perlu email, nomor telepon, atau nama asli\n- Tidak ada analitik, pelacakan, atau telemetri\n- Tidak ada pengenal iklan\n- Tidak ada akses daftar kontak\n- Tidak ada cadangan cloud (pesan hanya ada di perangkat Anda)\n- Tidak ada metadata yang dikirim ke server Pulse mana pun (karena tidak ada)';

  @override
  String get privacyEncryptionHeading => 'Enkripsi';

  @override
  String get privacyEncryptionBody =>
      'Semua pesan dienkripsi menggunakan Signal Protocol (Double Ratchet dengan X3DH key agreement). Kunci enkripsi dibuat dan disimpan secara eksklusif di perangkat Anda. Tidak ada siapa pun — termasuk pengembang — yang bisa membaca pesan Anda.';

  @override
  String get privacyNetworkHeading => 'Arsitektur Jaringan';

  @override
  String get privacyNetworkBody =>
      'Pulse menggunakan adapter transportasi terfederasi (Nostr relay, Session/Oxen service node, Firebase Realtime Database, LAN). Transportasi ini hanya membawa ciphertext terenkripsi. Operator relay bisa melihat alamat IP dan volume lalu lintas, tetapi tidak bisa mendekripsi konten pesan.\n\nSaat Tor diaktifkan, alamat IP Anda juga tersembunyi dari operator relay.';

  @override
  String get privacyStunHeading => 'Server STUN/TURN';

  @override
  String get privacyStunBody =>
      'Panggilan suara dan video menggunakan WebRTC dengan enkripsi DTLS-SRTP. Server STUN (untuk menemukan IP publik untuk koneksi P2P) dan server TURN (untuk merelay media saat koneksi langsung gagal) bisa melihat alamat IP dan durasi panggilan, tetapi tidak bisa mendekripsi konten panggilan.\n\nAnda bisa mengonfigurasi server TURN sendiri di Pengaturan untuk privasi maksimal.';

  @override
  String get privacyCrashHeading => 'Laporan Kerusakan';

  @override
  String get privacyCrashBody =>
      'Jika laporan kerusakan Sentry diaktifkan (melalui SENTRY_DSN saat build), laporan kerusakan anonim mungkin dikirim. Ini tidak mengandung konten pesan, informasi kontak, atau data identitas pribadi. Laporan kerusakan bisa dinonaktifkan saat build dengan menghilangkan DSN.';

  @override
  String get privacyPasswordHeading => 'Kata Sandi & Kunci';

  @override
  String get privacyPasswordBody =>
      'Kata sandi pemulihan Anda digunakan untuk menurunkan kunci kriptografi melalui Argon2id (memory-hard KDF). Kata sandi tidak pernah dikirimkan ke mana pun. Jika Anda kehilangan kata sandi, akun tidak bisa dipulihkan — tidak ada server untuk meresetnya.';

  @override
  String get privacyFontsHeading => 'Font';

  @override
  String get privacyFontsBody =>
      'Pulse menyertakan semua font secara lokal. Tidak ada permintaan ke Google Fonts atau layanan font eksternal mana pun.';

  @override
  String get privacyThirdPartyHeading => 'Layanan Pihak Ketiga';

  @override
  String get privacyThirdPartyBody =>
      'Pulse tidak terintegrasi dengan jaringan iklan, penyedia analitik, platform media sosial, atau broker data mana pun. Satu-satunya koneksi jaringan adalah ke relay transportasi yang Anda konfigurasi.';

  @override
  String get privacyOpenSourceHeading => 'Sumber Terbuka';

  @override
  String get privacyOpenSourceBody =>
      'Pulse adalah perangkat lunak sumber terbuka. Anda bisa mengaudit kode sumber lengkap untuk memverifikasi klaim privasi ini.';

  @override
  String get privacyContactHeading => 'Kontak';

  @override
  String get privacyContactBody =>
      'Untuk pertanyaan terkait privasi, buka issue di repositori proyek.';

  @override
  String get privacyLastUpdated => 'Terakhir diperbarui: Maret 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Gagal menyimpan: $error';
  }

  @override
  String get themeEngineTitle => 'Mesin Tema';

  @override
  String get torBuiltInTitle => 'Tor Bawaan';

  @override
  String get torConnectedSubtitle => 'Terhubung — Nostr melalui 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Menghubungkan… $pct%';
  }

  @override
  String get torNotRunning =>
      'Tidak berjalan — ketuk sakelar untuk memulai ulang';

  @override
  String get torDescription =>
      'Rutekan Nostr melalui Tor (Snowflake untuk jaringan tersensor)';

  @override
  String get torNetworkDiagnostics => 'Diagnostik Jaringan';

  @override
  String get torTransportLabel => 'Kanal: ';

  @override
  String get torPtAuto => 'Otomatis';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Biasa';

  @override
  String get torTimeoutLabel => 'Batas waktu: ';

  @override
  String get torInfoDescription =>
      'Saat diaktifkan, koneksi WebSocket Nostr dirutekan melalui Tor (SOCKS5). Tor Browser mendengarkan di 127.0.0.1:9150. Daemon tor menggunakan port 9050. Koneksi Firebase tidak terpengaruh.';

  @override
  String get torRouteNostrTitle => 'Rutekan Nostr via Tor';

  @override
  String get torManagedByBuiltin => 'Dikelola oleh Tor Bawaan';

  @override
  String get torActiveRouting => 'Aktif — lalu lintas Nostr melalui Tor';

  @override
  String get torDisabled => 'Dinonaktifkan';

  @override
  String get torProxySocks5 => 'Proxy Tor (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Host Proxy';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser: port 9150  •  Tor daemon: port 9050';

  @override
  String get torForceNostrTitle => 'Kirim pesan melalui Tor';

  @override
  String get torForceNostrSubtitle =>
      'Semua koneksi Nostr relay akan melalui Tor. Lebih lambat tetapi menyembunyikan IP Anda dari relay.';

  @override
  String get torForceNostrDisabled => 'Tor harus diaktifkan terlebih dahulu';

  @override
  String get torForcePulseTitle => 'Kirim Pulse relay melalui Tor';

  @override
  String get torForcePulseSubtitle =>
      'Semua koneksi Pulse relay akan melalui Tor. Lebih lambat tetapi menyembunyikan IP Anda dari server.';

  @override
  String get torForcePulseDisabled => 'Tor harus diaktifkan terlebih dahulu';

  @override
  String get i2pProxySocks5 => 'Proxy I2P (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P menggunakan SOCKS5 di port 4447 secara default. Hubungkan ke Nostr relay melalui I2P outproxy (mis. relay.damus.i2p) untuk berkomunikasi dengan pengguna di kanal apa pun. Tor diprioritaskan saat keduanya diaktifkan.';

  @override
  String get i2pRouteNostrTitle => 'Rutekan Nostr via I2P';

  @override
  String get i2pActiveRouting => 'Aktif — lalu lintas Nostr melalui I2P';

  @override
  String get i2pDisabled => 'Dinonaktifkan';

  @override
  String get i2pProxyHostLabel => 'Host Proxy';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'Port SOCKS5 default I2P Router: 4447';

  @override
  String get customProxySocks5 => 'Proxy Kustom (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Proxy kustom merutekan lalu lintas melalui V2Ray/Xray/Shadowsocks Anda. CF Worker berfungsi sebagai relay proxy pribadi di Cloudflare CDN — GFW melihat *.workers.dev, bukan relay asli.';

  @override
  String get customSocks5ProxyTitle => 'Proxy SOCKS5 Kustom';

  @override
  String get customProxyActive => 'Aktif — lalu lintas melalui SOCKS5';

  @override
  String get customProxyDisabled => 'Dinonaktifkan';

  @override
  String get customProxyHostLabel => 'Host Proxy';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Domain Worker (opsional)';

  @override
  String get customWorkerHelpTitle => 'Cara deploy CF Worker relay (gratis)';

  @override
  String get customWorkerScriptCopied => 'Script disalin!';

  @override
  String get customWorkerStep1 =>
      '1. Buka dash.cloudflare.com → Workers & Pages\n2. Create Worker → tempel script ini:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → salin domain (mis. my-relay.user.workers.dev)\n4. Tempel domain di atas → Simpan\n\nAplikasi terhubung otomatis: wss://domain/?r=relay_url\nGFW melihat: koneksi ke *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Terhubung — SOCKS5 di 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Menghubungkan…';

  @override
  String get psiphonNotRunning =>
      'Tidak berjalan — ketuk sakelar untuk memulai ulang';

  @override
  String get psiphonDescription =>
      'Terowongan cepat (~3 detik bootstrap, 2000+ VPS berputar)';

  @override
  String get turnCommunityServers => 'Server TURN Komunitas';

  @override
  String get turnCustomServer => 'Server TURN Kustom (BYOD)';

  @override
  String get turnInfoDescription =>
      'Server TURN hanya merelay stream yang sudah terenkripsi (DTLS-SRTP). Operator relay melihat IP dan volume lalu lintas, tetapi tidak bisa mendekripsi panggilan. TURN hanya digunakan saat P2P langsung gagal (~15–20% koneksi).';

  @override
  String get turnFreeLabel => 'GRATIS';

  @override
  String get turnServerUrlLabel => 'URL Server TURN';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 atau turns:...';

  @override
  String get turnUsernameLabel => 'Nama Pengguna';

  @override
  String get turnPasswordLabel => 'Kata Sandi';

  @override
  String get turnOptionalHint => 'Opsional';

  @override
  String get turnCustomInfo =>
      'Host coturn di VPS \$5/bulan untuk kontrol maksimal. Kredensial disimpan secara lokal.';

  @override
  String get themePickerAppearance => 'Tampilan';

  @override
  String get themePickerAccentColor => 'Warna Aksen';

  @override
  String get themeModeLight => 'Terang';

  @override
  String get themeModeDark => 'Gelap';

  @override
  String get themeModeSystem => 'Sistem';

  @override
  String get themeDynamicPresets => 'Preset';

  @override
  String get themeDynamicPrimaryColor => 'Warna Utama';

  @override
  String get themeDynamicBorderRadius => 'Radius Batas';

  @override
  String get themeDynamicFont => 'Font';

  @override
  String get themeDynamicAppearance => 'Tampilan';

  @override
  String get themeDynamicUiStyle => 'Gaya UI';

  @override
  String get themeDynamicUiStyleDescription =>
      'Mengontrol tampilan dialog, sakelar, dan indikator.';

  @override
  String get themeDynamicSharp => 'Tajam';

  @override
  String get themeDynamicRound => 'Bulat';

  @override
  String get themeDynamicModeDark => 'Gelap';

  @override
  String get themeDynamicModeLight => 'Terang';

  @override
  String get themeDynamicModeAuto => 'Otomatis';

  @override
  String get themeDynamicPlatformAuto => 'Otomatis';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'URL Firebase tidak valid. Harus https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'URL relay tidak valid. Harus wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'URL server Pulse tidak valid. Harus https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'URL Server';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'Kode Undangan';

  @override
  String get providerPulseInviteHint => 'Kode undangan (jika diperlukan)';

  @override
  String get providerPulseInfo =>
      'Relay yang dihost sendiri. Kunci diturunkan dari kata sandi pemulihan.';

  @override
  String get providerScreenTitle => 'Kotak Masuk';

  @override
  String get providerSecondaryInboxesHeader => 'KOTAK MASUK SEKUNDER';

  @override
  String get providerSecondaryInboxesInfo =>
      'Kotak masuk sekunder menerima pesan secara bersamaan untuk redundansi.';

  @override
  String get providerRemoveTooltip => 'Hapus';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... atau hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... atau hex private key';

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
  String get emojiNoRecent => 'Tidak ada emoji terbaru';

  @override
  String get emojiSearchHint => 'Cari emoji...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Ketuk untuk chat';

  @override
  String get imageViewerSaveToDownloads => 'Simpan ke Downloads';

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
  String get settingsLanguageSubtitle => 'Bahasa tampilan aplikasi';

  @override
  String get settingsLanguageSystem => 'Default sistem';

  @override
  String get onboardingLanguageTitle => 'Pilih bahasa Anda';

  @override
  String get onboardingLanguageSubtitle =>
      'Anda bisa mengubahnya nanti di Pengaturan';

  @override
  String get videoNoteRecord => 'Rekam pesan video';

  @override
  String get videoNoteTapToRecord => 'Ketuk untuk merekam';

  @override
  String get videoNoteTapToStop => 'Ketuk untuk berhenti';

  @override
  String get videoNoteCameraPermission => 'Izin kamera ditolak';

  @override
  String get videoNoteMaxDuration => 'Maksimal 30 detik';

  @override
  String get videoNoteNotSupported =>
      'Catatan video tidak didukung di platform ini';

  @override
  String get navChats => 'Obrolan';

  @override
  String get navUpdates => 'Pembaruan';

  @override
  String get navCalls => 'Panggilan';

  @override
  String get filterAll => 'Semua';

  @override
  String get filterUnread => 'Belum dibaca';

  @override
  String get filterGroups => 'Grup';

  @override
  String get callsNoRecent => 'Tidak ada panggilan terbaru';

  @override
  String get callsEmptySubtitle => 'Riwayat panggilan Anda akan muncul di sini';

  @override
  String get appBarEncrypted => 'dienkripsi ujung-ke-ujung';

  @override
  String get newStatus => 'Status baru';

  @override
  String get newCall => 'Panggilan baru';

  @override
  String get joinChannelTitle => 'Gabung Saluran';

  @override
  String get joinChannelDescription => 'URL SALURAN';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'Mengambil info saluran…';

  @override
  String get joinChannelNotFound => 'Saluran tidak ditemukan di URL ini';

  @override
  String get joinChannelNetworkError => 'Tidak dapat menjangkau server';

  @override
  String get joinChannelAlreadyJoined => 'Sudah bergabung';

  @override
  String get joinChannelButton => 'Gabung';

  @override
  String get channelFeedEmpty => 'Belum ada postingan';

  @override
  String get channelLeave => 'Tinggalkan Saluran';

  @override
  String get channelLeaveConfirm =>
      'Tinggalkan saluran ini? Postingan yang di-cache akan dihapus.';

  @override
  String get channelInfo => 'Info Saluran';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'diedit';

  @override
  String get channelLoadMore => 'Muat lagi';

  @override
  String get channelSearchPosts => 'Cari postingan…';

  @override
  String get channelNoResults => 'Tidak ada postingan yang cocok';

  @override
  String get channelUrl => 'URL saluran';

  @override
  String get channelCreated => 'Bergabung';

  @override
  String channelPostCount(int count) {
    return '$count postingan';
  }

  @override
  String get channelCopyUrl => 'Salin URL';

  @override
  String get setupNext => 'Berikutnya';

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
  String get setupVerifyButton => 'Verifikasi';

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
      'Tampilkan kunci pemulihan akun Anda';

  @override
  String get settingsRecoveryKeyNotStored =>
      'Kunci pemulihan tidak tersedia (dibuat sebelum fitur ini)';

  @override
  String get settingsRecoveryKeyWarning =>
      'Simpan kunci ini dengan aman. Siapa pun yang memilikinya dapat memulihkan akun Anda di perangkat lain.';

  @override
  String get replaceIdentityTitle => 'Ganti identitas yang ada?';

  @override
  String get replaceIdentityBodyRestore =>
      'Identitas sudah ada di perangkat ini. Memulihkan akan mengganti kunci Nostr dan seed Oxen Anda secara permanen. Semua kontak akan kehilangan kemampuan untuk menghubungi alamat Anda saat ini.\n\nTindakan ini tidak dapat dibatalkan.';

  @override
  String get replaceIdentityBodyCreate =>
      'Identitas sudah ada di perangkat ini. Membuat yang baru akan mengganti kunci Nostr dan seed Oxen Anda secara permanen. Semua kontak akan kehilangan kemampuan untuk menghubungi alamat Anda saat ini.\n\nTindakan ini tidak dapat dibatalkan.';

  @override
  String get replace => 'Ganti';

  @override
  String get callNoScreenSources => 'Tidak ada sumber layar yang tersedia';

  @override
  String get callScreenShareQuality => 'Kualitas Berbagi Layar';

  @override
  String get callFrameRate => 'Laju bingkai';

  @override
  String get callResolution => 'Resolusi';

  @override
  String get callAutoResolution => 'Otomatis = resolusi layar asli';

  @override
  String get callStartSharing => 'Mulai berbagi';

  @override
  String get callCameraUnavailable =>
      'Kamera tidak tersedia — mungkin sedang digunakan oleh aplikasi lain';

  @override
  String get themeResetToDefaults => 'Atur ulang ke default';

  @override
  String get backupSaveToDownloadsTitle => 'Simpan cadangan ke Unduhan?';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'Pemilih file tidak tersedia. Cadangan akan disimpan ke:\n$path';
  }

  @override
  String get systemLabel => 'Sistem';

  @override
  String get next => 'Berikutnya';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return '$remaining ketukan lagi untuk mengaktifkan mode pengembang';
  }

  @override
  String get devModeEnabled => 'Mode pengembang diaktifkan';

  @override
  String get devTools => 'Alat Pengembang';

  @override
  String get devAdapterDiagnostics => 'Pengaturan & diagnostik adapter';

  @override
  String get devEnableAll => 'Aktifkan semua';

  @override
  String get devDisableAll => 'Nonaktifkan semua';

  @override
  String get turnUrlValidation =>
      'URL TURN harus dimulai dengan turn: atau turns: (maks 512 karakter)';

  @override
  String get callMissedCall => 'Panggilan tidak terjawab';

  @override
  String get callOutgoingCall => 'Panggilan keluar';

  @override
  String get callIncomingCall => 'Panggilan masuk';

  @override
  String get mediaMissingData => 'Data media tidak ada';

  @override
  String get mediaDownloadFailed => 'Gagal mengunduh';

  @override
  String get mediaDecryptFailed => 'Gagal mendekripsi';

  @override
  String get callEndCallBanner => 'Akhiri panggilan';

  @override
  String get meFallback => 'Saya';

  @override
  String get imageSaveToDownloads => 'Simpan ke Unduhan';

  @override
  String imageSavedToPath(String path) {
    return 'Disimpan ke $path';
  }

  @override
  String get callScreenShareRequiresPermission =>
      'Berbagi layar memerlukan izin';

  @override
  String get callScreenShareUnavailable => 'Berbagi layar tidak tersedia';

  @override
  String get statusJustNow => 'Baru saja';

  @override
  String statusMinutesAgo(int minutes) {
    return '$minutes menit lalu';
  }

  @override
  String statusHoursAgo(int hours) {
    return '$hours jam lalu';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rute',
      one: '1 rute',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => 'Siap ditambahkan';

  @override
  String groupSelectedCount(int count) {
    return '$count dipilih';
  }

  @override
  String get paste => 'Tempel';

  @override
  String get sfuAudioOnly => 'Hanya audio';

  @override
  String sfuParticipants(int count) {
    return '$count peserta';
  }

  @override
  String get dataUnencryptedBackup => 'Cadangan tidak terenkripsi';

  @override
  String get dataUnencryptedBackupBody =>
      'File ini adalah cadangan identitas yang tidak terenkripsi dan akan menimpa kunci Anda saat ini. Hanya impor file yang Anda buat sendiri. Lanjutkan?';

  @override
  String get dataImportAnyway => 'Impor saja';

  @override
  String get securityStorageError =>
      'Kesalahan penyimpanan keamanan — mulai ulang aplikasi';

  @override
  String get aboutDevModeActive => 'Mode pengembang aktif';

  @override
  String get themeColors => 'Warna';

  @override
  String get themePrimaryAccent => 'Aksen primer';

  @override
  String get themeSecondaryAccent => 'Aksen sekunder';

  @override
  String get themeBackground => 'Latar belakang';

  @override
  String get themeSurface => 'Permukaan';

  @override
  String get themeChatBubbles => 'Gelembung Chat';

  @override
  String get themeOutgoingMessage => 'Pesan keluar';

  @override
  String get themeIncomingMessage => 'Pesan masuk';

  @override
  String get themeShape => 'Bentuk';

  @override
  String get devSectionDeveloper => 'Pengembang';

  @override
  String get devAdapterChannelsHint =>
      'Kanal adapter — nonaktifkan untuk menguji transport tertentu.';

  @override
  String get devNostrRelays => 'Nostr relay (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Session Network';

  @override
  String get devPulseRelay => 'Pulse relay mandiri';

  @override
  String get devLanNetwork => 'Jaringan lokal (UDP/TCP)';

  @override
  String get devSectionCalls => 'Panggilan';

  @override
  String get devForceTurnRelay => 'Paksa TURN relay';

  @override
  String get devForceTurnRelaySubtitle =>
      'Nonaktifkan P2P — semua panggilan hanya melalui server TURN';

  @override
  String get devRestartWarning =>
      '⚠ Perubahan berlaku pada pengiriman/panggilan berikutnya. Mulai ulang aplikasi untuk menerapkan ke pesan masuk.';

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
  String get pulseUseServerTitle => 'Gunakan server Pulse?';

  @override
  String pulseUseServerBody(String name, String host) {
    return '$name menggunakan server Pulse $host. Gabung untuk mengobrol lebih cepat dengannya (dan dengan orang lain di server yang sama)?';
  }

  @override
  String pulseContactUsesPulse(String name) {
    return '$name menggunakan Pulse';
  }

  @override
  String pulseJoinForFaster(String host) {
    return 'Gabung ke $host untuk obrolan lebih cepat';
  }

  @override
  String get pulseNotNow => 'Nanti saja';

  @override
  String get pulseJoin => 'Gabung';

  @override
  String get pulseDismiss => 'Tutup';

  @override
  String get pulseHide7Days => 'Sembunyikan 7 hari';

  @override
  String get pulseNeverAskAgain => 'Jangan tanya lagi';

  @override
  String get groupSearchContactsHint => 'Cari kontak…';

  @override
  String get systemActorYou => 'Kamu';

  @override
  String get systemActorPeer => 'Kontak';

  @override
  String systemTtlEnabled(String actor, String duration) {
    return '$actor mengaktifkan pesan menghilang: $duration';
  }

  @override
  String systemTtlDisabled(String actor) {
    return '$actor menonaktifkan pesan menghilang';
  }

  @override
  String get menuClearChatHistory => 'Hapus riwayat obrolan';

  @override
  String get clearChatTitle => 'Hapus riwayat obrolan?';

  @override
  String get clearChatBody =>
      'Semua pesan dalam obrolan ini akan dihapus dari perangkat ini. Orang lain akan menyimpan salinannya.';

  @override
  String get clearChatAction => 'Hapus';

  @override
  String systemGroupRenamed(String actor, String name) {
    return '$actor mengganti nama grup menjadi \"$name\"';
  }

  @override
  String systemGroupAvatarChanged(String actor) {
    return '$actor mengubah foto grup';
  }

  @override
  String systemGroupMetaChanged(String actor, String name) {
    return '$actor mengganti nama grup menjadi \"$name\" dan mengubah foto';
  }

  @override
  String get profileInviteLink => 'Tautan undangan';

  @override
  String get profileInviteLinkSubtitle =>
      'Siapa pun dengan tautan dapat bergabung';

  @override
  String get profileInviteLinkCopied => 'Tautan undangan disalin';

  @override
  String get groupInviteLinkTitle => 'Bergabung dengan grup?';

  @override
  String groupInviteLinkBody(String name, int count) {
    return 'Anda diundang untuk bergabung dengan \"$name\" ($count anggota).';
  }

  @override
  String get groupInviteLinkJoin => 'Bergabung';

  @override
  String get drawerCreateGroup => 'Buat grup';

  @override
  String get drawerJoinGroup => 'Gabung grup';

  @override
  String get drawerJoinGroupByLinkInvalid =>
      'Itu tidak terlihat seperti tautan undangan Pulse';

  @override
  String get groupModeMeshTitle => 'Biasa';

  @override
  String groupModeMeshSubtitle(int n) {
    return 'Tanpa server, hingga $n orang';
  }

  @override
  String get groupModePulseTitle => 'Server Pulse';

  @override
  String groupModePulseSubtitle(int n) {
    return 'Melalui server, hingga $n orang';
  }

  @override
  String get groupPulseServerHint => 'https://server-pulse-anda';

  @override
  String get groupPulseServerClosed => 'Server tertutup (perlu kode undangan)';

  @override
  String get groupPulseInviteHint => 'Kode undangan';

  @override
  String pulseGroupForeignServerBanner(String host) {
    return 'Pesan dirutekan melalui $host';
  }

  @override
  String groupMeshLimitReached(int n) {
    return 'Jenis panggilan ini dibatasi hingga $n orang';
  }
}
