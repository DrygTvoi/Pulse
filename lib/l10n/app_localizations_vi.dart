// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Tìm kiếm tin nhắn...';

  @override
  String get search => 'Tìm kiếm';

  @override
  String get clearSearch => 'Xóa tìm kiếm';

  @override
  String get closeSearch => 'Đóng tìm kiếm';

  @override
  String get moreOptions => 'Tùy chọn khác';

  @override
  String get back => 'Quay lại';

  @override
  String get cancel => 'Hủy';

  @override
  String get close => 'Đóng';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get remove => 'Xóa';

  @override
  String get save => 'Lưu';

  @override
  String get add => 'Thêm';

  @override
  String get copy => 'Sao chép';

  @override
  String get skip => 'Bỏ qua';

  @override
  String get done => 'Xong';

  @override
  String get apply => 'Áp dụng';

  @override
  String get export => 'Xuất';

  @override
  String get import => 'Nhập';

  @override
  String get homeNewGroup => 'Nhóm mới';

  @override
  String get homeSettings => 'Cài đặt';

  @override
  String get homeSearching => 'Đang tìm kiếm tin nhắn...';

  @override
  String get homeNoResults => 'Không tìm thấy kết quả';

  @override
  String get homeNoChatHistory => 'Chưa có lịch sử trò chuyện';

  @override
  String homeTransportSwitched(String address) {
    return 'Đã chuyển kênh truyền tải → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name đang gọi...';
  }

  @override
  String get homeAccept => 'Chấp nhận';

  @override
  String get homeDecline => 'Từ chối';

  @override
  String get homeLoadEarlier => 'Tải tin nhắn cũ hơn';

  @override
  String get homeChats => 'Trò chuyện';

  @override
  String get homeSelectConversation => 'Chọn cuộc hội thoại';

  @override
  String get homeNoChatsYet => 'Chưa có cuộc trò chuyện nào';

  @override
  String get homeAddContactToStart => 'Thêm liên hệ để bắt đầu trò chuyện';

  @override
  String get homeNewChat => 'Trò chuyện mới';

  @override
  String get homeNewChatTooltip => 'Trò chuyện mới';

  @override
  String get homeIncomingCallTitle => 'Cuộc gọi đến';

  @override
  String get homeIncomingGroupCallTitle => 'Cuộc gọi nhóm đến';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — cuộc gọi nhóm đến';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Không có cuộc trò chuyện nào khớp với \"$query\"';
  }

  @override
  String get homeSectionChats => 'Trò chuyện';

  @override
  String get homeSectionMessages => 'Tin nhắn';

  @override
  String get homeDbEncryptionUnavailable =>
      'Không thể mã hóa cơ sở dữ liệu — cài đặt SQLCipher để bảo vệ đầy đủ';

  @override
  String get chatFileTooLargeGroup =>
      'Không hỗ trợ tệp lớn hơn 512 KB trong nhóm';

  @override
  String get chatLargeFile => 'Tệp lớn';

  @override
  String get chatCancel => 'Hủy';

  @override
  String get chatSend => 'Gửi';

  @override
  String get chatFileTooLarge => 'Tệp quá lớn — kích thước tối đa là 100 MB';

  @override
  String get chatMicDenied => 'Quyền truy cập micro bị từ chối';

  @override
  String get chatVoiceFailed =>
      'Không thể lưu tin nhắn thoại — kiểm tra dung lượng lưu trữ';

  @override
  String get chatScheduleFuture => 'Thời gian hẹn phải ở trong tương lai';

  @override
  String get chatToday => 'Hôm nay';

  @override
  String get chatYesterday => 'Hôm qua';

  @override
  String get chatEdited => 'đã chỉnh sửa';

  @override
  String get chatYou => 'Bạn';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Tệp này có dung lượng $size MB. Gửi tệp lớn có thể chậm trên một số mạng. Tiếp tục?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Khóa bảo mật của $name đã thay đổi. Nhấn để xác minh.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Không thể mã hóa tin nhắn cho $name — tin nhắn chưa được gửi.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Số an toàn của $name đã thay đổi. Nhấn để xác minh.';
  }

  @override
  String get chatNoMessagesFound => 'Không tìm thấy tin nhắn';

  @override
  String get chatMessagesE2ee => 'Tin nhắn được mã hóa đầu cuối';

  @override
  String get chatSayHello => 'Gửi lời chào';

  @override
  String get appBarOnline => 'trực tuyến';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'đang nhập';

  @override
  String get appBarSearchMessages => 'Tìm kiếm tin nhắn...';

  @override
  String get appBarMute => 'Tắt tiếng';

  @override
  String get appBarUnmute => 'Bật tiếng';

  @override
  String get appBarMedia => 'Phương tiện';

  @override
  String get appBarDisappearing => 'Tin nhắn tự hủy';

  @override
  String get appBarDisappearingOn => 'Tự hủy: bật';

  @override
  String get appBarGroupSettings => 'Cài đặt nhóm';

  @override
  String get appBarSearchTooltip => 'Tìm kiếm tin nhắn';

  @override
  String get appBarVoiceCall => 'Gọi thoại';

  @override
  String get appBarVideoCall => 'Gọi video';

  @override
  String get inputMessage => 'Tin nhắn...';

  @override
  String get inputAttachFile => 'Đính kèm tệp';

  @override
  String get inputSendMessage => 'Gửi tin nhắn';

  @override
  String get inputRecordVoice => 'Ghi âm tin nhắn thoại';

  @override
  String get inputSendVoice => 'Gửi tin nhắn thoại';

  @override
  String get inputCancelReply => 'Hủy trả lời';

  @override
  String get inputCancelEdit => 'Hủy chỉnh sửa';

  @override
  String get inputCancelRecording => 'Hủy ghi âm';

  @override
  String get inputRecording => 'Đang ghi âm…';

  @override
  String get inputEditingMessage => 'Đang chỉnh sửa tin nhắn';

  @override
  String get inputPhoto => 'Ảnh';

  @override
  String get inputVoiceMessage => 'Tin nhắn thoại';

  @override
  String get inputFile => 'Tệp';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count tin nhắn hẹn giờ$_temp0';
  }

  @override
  String get callInitializing => 'Đang khởi tạo cuộc gọi…';

  @override
  String get callConnecting => 'Đang kết nối…';

  @override
  String get callConnectingRelay => 'Đang kết nối (relay)…';

  @override
  String get callSwitchingRelay => 'Đang chuyển sang chế độ relay…';

  @override
  String get callConnectionFailed => 'Kết nối thất bại';

  @override
  String get callReconnecting => 'Đang kết nối lại…';

  @override
  String get callEnded => 'Cuộc gọi đã kết thúc';

  @override
  String get callLive => 'Trực tiếp';

  @override
  String get callEnd => 'Kết thúc';

  @override
  String get callEndCall => 'Kết thúc cuộc gọi';

  @override
  String get callMute => 'Tắt tiếng';

  @override
  String get callUnmute => 'Bật tiếng';

  @override
  String get callSpeaker => 'Loa ngoài';

  @override
  String get callCameraOn => 'Bật camera';

  @override
  String get callCameraOff => 'Tắt camera';

  @override
  String get callShareScreen => 'Chia sẻ màn hình';

  @override
  String get callStopShare => 'Dừng chia sẻ';

  @override
  String callTorBackup(String duration) {
    return 'Tor dự phòng · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor dự phòng đang hoạt động — đường truyền chính không khả dụng';

  @override
  String get callDirectFailed =>
      'Kết nối trực tiếp thất bại — đang chuyển sang chế độ relay…';

  @override
  String get callTurnUnreachable =>
      'Không thể kết nối TURN. Thêm TURN tùy chỉnh trong Cài đặt → Nâng cao.';

  @override
  String get callRelayMode => 'Chế độ relay đang hoạt động (mạng bị hạn chế)';

  @override
  String get callStarting => 'Đang bắt đầu cuộc gọi…';

  @override
  String get callConnectingToGroup => 'Đang kết nối đến nhóm…';

  @override
  String get callGroupOpenedInBrowser =>
      'Cuộc gọi nhóm đã mở trong trình duyệt';

  @override
  String get callCouldNotOpenBrowser => 'Không thể mở trình duyệt';

  @override
  String get callInviteLinkSent =>
      'Đã gửi liên kết mời đến tất cả thành viên nhóm.';

  @override
  String get callOpenLinkManually =>
      'Mở liên kết ở trên theo cách thủ công hoặc nhấn để thử lại.';

  @override
  String get callJitsiNotE2ee => 'Cuộc gọi Jitsi KHÔNG được mã hóa đầu cuối';

  @override
  String get callRetryOpenBrowser => 'Thử mở lại trình duyệt';

  @override
  String get callClose => 'Đóng';

  @override
  String get callCamOn => 'Bật cam';

  @override
  String get callCamOff => 'Tắt cam';

  @override
  String get noConnection => 'Không có kết nối — tin nhắn sẽ được xếp hàng';

  @override
  String get connected => 'Đã kết nối';

  @override
  String get connecting => 'Đang kết nối…';

  @override
  String get disconnected => 'Đã ngắt kết nối';

  @override
  String get offlineBanner =>
      'Không có kết nối — tin nhắn sẽ được xếp hàng và gửi khi có mạng trở lại';

  @override
  String get lanModeBanner =>
      'Chế độ LAN — Không có internet · Chỉ mạng nội bộ';

  @override
  String get probeCheckingNetwork => 'Đang kiểm tra kết nối mạng…';

  @override
  String get probeDiscoveringRelays => 'Đang tìm relay qua thư mục cộng đồng…';

  @override
  String get probeStartingTor => 'Đang khởi động Tor…';

  @override
  String get probeFindingRelaysTor => 'Đang tìm relay có thể truy cập qua Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'Mạng sẵn sàng — tìm thấy $count relay$_temp0';
  }

  @override
  String get probeNoRelaysFound =>
      'Không tìm thấy relay nào — tin nhắn có thể bị chậm';

  @override
  String get jitsiWarningTitle => 'Không được mã hóa đầu cuối';

  @override
  String get jitsiWarningBody =>
      'Cuộc gọi Jitsi Meet không được Pulse mã hóa. Chỉ sử dụng cho cuộc hội thoại không nhạy cảm.';

  @override
  String get jitsiConfirm => 'Vẫn tham gia';

  @override
  String get jitsiGroupWarningTitle => 'Không được mã hóa đầu cuối';

  @override
  String get jitsiGroupWarningBody =>
      'Cuộc gọi này có quá nhiều người tham gia cho mesh mã hóa tích hợp.\n\nMột liên kết Jitsi Meet sẽ được mở trong trình duyệt. Jitsi KHÔNG được mã hóa đầu cuối — máy chủ có thể thấy cuộc gọi của bạn.';

  @override
  String get jitsiContinueAnyway => 'Vẫn tiếp tục';

  @override
  String get retry => 'Thử lại';

  @override
  String get setupCreateAnonymousAccount => 'Tạo tài khoản ẩn danh';

  @override
  String get setupTapToChangeColor => 'Nhấn để đổi màu';

  @override
  String get setupReqMinLength => 'At least 16 characters';

  @override
  String get setupReqVariety => '3 of 4: uppercase, lowercase, digits, symbols';

  @override
  String get setupReqMatch => 'Passwords match';

  @override
  String get setupYourNickname => 'Biệt danh của bạn';

  @override
  String get setupRecoveryPassword => 'Mật khẩu khôi phục (tối thiểu 16)';

  @override
  String get setupConfirmPassword => 'Xác nhận mật khẩu';

  @override
  String get setupMin16Chars => 'Tối thiểu 16 ký tự';

  @override
  String get setupPasswordsDoNotMatch => 'Mật khẩu không khớp';

  @override
  String get setupEntropyWeak => 'Yếu';

  @override
  String get setupEntropyOk => 'Tạm được';

  @override
  String get setupEntropyStrong => 'Mạnh';

  @override
  String get setupEntropyWeakNeedsVariety => 'Yếu (cần 3 loại ký tự)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bit)';
  }

  @override
  String get setupPasswordWarning =>
      'Mật khẩu này là cách duy nhất để khôi phục tài khoản. Không có máy chủ — không thể đặt lại mật khẩu. Hãy ghi nhớ hoặc viết ra.';

  @override
  String get setupCreateAccount => 'Tạo tài khoản';

  @override
  String get setupAlreadyHaveAccount => 'Đã có tài khoản? ';

  @override
  String get setupRestore => 'Khôi phục →';

  @override
  String get restoreTitle => 'Khôi phục tài khoản';

  @override
  String get restoreInfoBanner =>
      'Nhập mật khẩu khôi phục — địa chỉ của bạn (Nostr + Session) sẽ được khôi phục tự động. Liên hệ và tin nhắn chỉ được lưu trên thiết bị.';

  @override
  String get restoreNewNickname => 'Biệt danh mới (có thể đổi sau)';

  @override
  String get restoreButton => 'Khôi phục tài khoản';

  @override
  String get lockTitle => 'Pulse đã khóa';

  @override
  String get lockSubtitle => 'Nhập mật khẩu để tiếp tục';

  @override
  String get lockPasswordHint => 'Mật khẩu';

  @override
  String get lockUnlock => 'Mở khóa';

  @override
  String get lockPanicHint =>
      'Quên mật khẩu? Nhập khóa khẩn cấp để xóa tất cả dữ liệu.';

  @override
  String get lockTooManyAttempts =>
      'Quá nhiều lần thử. Đang xóa toàn bộ dữ liệu…';

  @override
  String get lockWrongPassword => 'Sai mật khẩu';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Sai mật khẩu — $attempts/$max lần thử';
  }

  @override
  String get onboardingSkip => 'Bỏ qua';

  @override
  String get onboardingNext => 'Tiếp theo';

  @override
  String get onboardingGetStarted => 'Bắt đầu';

  @override
  String get onboardingWelcomeTitle => 'Chào mừng đến với Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Ứng dụng nhắn tin mã hóa đầu cuối phi tập trung.\n\nKhông có máy chủ trung tâm. Không thu thập dữ liệu. Không có cửa hậu.\nCuộc trò chuyện của bạn chỉ thuộc về bạn.';

  @override
  String get onboardingTransportTitle => 'Không phụ thuộc kênh truyền';

  @override
  String get onboardingTransportBody =>
      'Sử dụng Firebase, Nostr hoặc cả hai cùng lúc.\n\nTin nhắn được định tuyến tự động qua các mạng. Tích hợp sẵn Tor và I2P để chống kiểm duyệt.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Mỗi tin nhắn được mã hóa bằng Signal Protocol (Double Ratchet + X3DH) để đảm bảo forward secrecy.\n\nThêm lớp bảo vệ Kyber-1024 — thuật toán post-quantum chuẩn NIST — bảo vệ trước máy tính lượng tử tương lai.';

  @override
  String get onboardingKeysTitle => 'Bạn sở hữu khóa của mình';

  @override
  String get onboardingKeysBody =>
      'Khóa danh tính không bao giờ rời khỏi thiết bị.\n\nVân tay Signal cho phép xác minh liên hệ ngoài kênh. TOFU (Trust On First Use) tự động phát hiện thay đổi khóa.';

  @override
  String get onboardingThemeTitle => 'Chọn giao diện';

  @override
  String get onboardingThemeBody =>
      'Chọn theme và màu nhấn. Bạn có thể thay đổi bất cứ lúc nào trong Cài đặt.';

  @override
  String get contactsNewChat => 'Trò chuyện mới';

  @override
  String get contactsAddContact => 'Thêm liên hệ';

  @override
  String get contactsSearchHint => 'Tìm kiếm...';

  @override
  String get contactsNewGroup => 'Nhóm mới';

  @override
  String get contactsNoContactsYet => 'Chưa có liên hệ nào';

  @override
  String get contactsAddHint => 'Nhấn + để thêm địa chỉ của ai đó';

  @override
  String get contactsNoMatch => 'Không có liên hệ nào khớp';

  @override
  String get contactsRemoveTitle => 'Xóa liên hệ';

  @override
  String contactsRemoveMessage(String name) {
    return 'Xóa $name?';
  }

  @override
  String get contactsRemove => 'Xóa';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count liên hệ$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Mở liên kết';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Mở URL này trong trình duyệt?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Mở';

  @override
  String get bubbleSecurityWarning => 'Cảnh báo bảo mật';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" là tệp thực thi. Lưu và chạy có thể gây hại cho thiết bị. Vẫn lưu?';
  }

  @override
  String get bubbleSaveAnyway => 'Vẫn lưu';

  @override
  String bubbleSavedTo(String path) {
    return 'Đã lưu tại $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Lưu thất bại: $error';
  }

  @override
  String get bubbleNotEncrypted => 'KHÔNG MÃ HÓA';

  @override
  String get bubbleCorruptedImage => '[Ảnh bị hỏng]';

  @override
  String get bubbleReplyPhoto => 'Ảnh';

  @override
  String get bubbleReplyVoice => 'Tin nhắn thoại';

  @override
  String get bubbleReplyVideo => 'Tin nhắn video';

  @override
  String bubbleReadBy(String names) {
    return 'Đã đọc bởi $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Đã đọc bởi $count người';
  }

  @override
  String get chatTileTapToStart => 'Nhấn để bắt đầu trò chuyện';

  @override
  String get chatTileMessageSent => 'Tin nhắn đã gửi';

  @override
  String get chatTileEncryptedMessage => 'Tin nhắn mã hóa';

  @override
  String chatTileYouPrefix(String text) {
    return 'Bạn: $text';
  }

  @override
  String get bannerEncryptedMessage => 'Tin nhắn mã hóa';

  @override
  String get groupNewGroup => 'Nhóm mới';

  @override
  String get groupGroupName => 'Tên nhóm';

  @override
  String get groupSelectMembers => 'Chọn thành viên (tối thiểu 2)';

  @override
  String get groupNoContactsYet => 'Chưa có liên hệ. Thêm liên hệ trước.';

  @override
  String get groupCreate => 'Tạo';

  @override
  String get groupLabel => 'Nhóm';

  @override
  String get profileVerifyIdentity => 'Xác minh danh tính';

  @override
  String profileVerifyInstructions(String name) {
    return 'So sánh các vân tay này với $name qua cuộc gọi thoại hoặc gặp trực tiếp. Nếu cả hai giá trị đều khớp trên cả hai thiết bị, nhấn \"Đánh dấu đã xác minh\".';
  }

  @override
  String get profileTheirKey => 'Khóa của họ';

  @override
  String get profileYourKey => 'Khóa của bạn';

  @override
  String get profileRemoveVerification => 'Xóa xác minh';

  @override
  String get profileMarkAsVerified => 'Đánh dấu đã xác minh';

  @override
  String get profileAddressCopied => 'Đã sao chép địa chỉ';

  @override
  String get profileNoContactsToAdd =>
      'Không có liên hệ để thêm — tất cả đã là thành viên';

  @override
  String get profileAddMembers => 'Thêm thành viên';

  @override
  String profileAddCount(int count) {
    return 'Thêm ($count)';
  }

  @override
  String get profileRenameGroup => 'Đổi tên nhóm';

  @override
  String get profileRename => 'Đổi tên';

  @override
  String get profileRemoveMember => 'Xóa thành viên?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Xóa $name khỏi nhóm này?';
  }

  @override
  String get profileKick => 'Loại';

  @override
  String get profileSignalFingerprints => 'Vân tay Signal';

  @override
  String get profileVerified => 'ĐÃ XÁC MINH';

  @override
  String get profileVerify => 'Xác minh';

  @override
  String get profileEdit => 'Chỉnh sửa';

  @override
  String get profileNoSession => 'Chưa có phiên nào — gửi tin nhắn trước.';

  @override
  String get profileFingerprintCopied => 'Đã sao chép vân tay';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count thành viên$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Xác minh số an toàn';

  @override
  String get profileShowContactQr => 'Hiển thị QR liên hệ';

  @override
  String profileContactAddress(String name) {
    return 'Địa chỉ của $name';
  }

  @override
  String get profileExportChatHistory => 'Xuất lịch sử trò chuyện';

  @override
  String profileSavedTo(String path) {
    return 'Đã lưu tại $path';
  }

  @override
  String get profileExportFailed => 'Xuất thất bại';

  @override
  String get profileClearChatHistory => 'Xóa lịch sử trò chuyện';

  @override
  String get profileDeleteGroup => 'Xóa nhóm';

  @override
  String get profileDeleteContact => 'Xóa liên hệ';

  @override
  String get profileLeaveGroup => 'Rời nhóm';

  @override
  String get profileLeaveGroupBody =>
      'Bạn sẽ bị xóa khỏi nhóm này và nhóm sẽ bị xóa khỏi danh bạ.';

  @override
  String get groupInviteTitle => 'Lời mời nhóm';

  @override
  String groupInviteBody(String from, String group) {
    return '$from đã mời bạn tham gia \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Chấp nhận';

  @override
  String get groupInviteDecline => 'Từ chối';

  @override
  String get groupMemberLimitTitle => 'Quá nhiều người tham gia';

  @override
  String groupMemberLimitBody(int count) {
    return 'Nhóm này sẽ có $count người tham gia. Cuộc gọi mesh mã hóa hỗ trợ tối đa 6. Nhóm lớn hơn sẽ dùng Jitsi (không có E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Vẫn thêm';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name đã từ chối tham gia \"$group\"';
  }

  @override
  String get transferTitle => 'Chuyển sang thiết bị khác';

  @override
  String get transferInfoBox =>
      'Di chuyển danh tính Signal và khóa Nostr sang thiết bị mới.\nPhiên trò chuyện KHÔNG được chuyển — forward secrecy được bảo toàn.';

  @override
  String get transferSendFromThis => 'Gửi từ thiết bị này';

  @override
  String get transferSendSubtitle =>
      'Thiết bị này có các khóa. Chia sẻ mã với thiết bị mới.';

  @override
  String get transferReceiveOnThis => 'Nhận trên thiết bị này';

  @override
  String get transferReceiveSubtitle =>
      'Đây là thiết bị mới. Nhập mã từ thiết bị cũ.';

  @override
  String get transferChooseMethod => 'Chọn phương thức chuyển';

  @override
  String get transferLan => 'LAN (Cùng mạng)';

  @override
  String get transferLanSubtitle =>
      'Nhanh và trực tiếp. Cả hai thiết bị phải cùng Wi-Fi.';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'Hoạt động qua bất kỳ mạng nào bằng Nostr relay có sẵn.';

  @override
  String get transferRelayUrl => 'URL Relay';

  @override
  String get transferEnterCode => 'Nhập mã chuyển';

  @override
  String get transferPasteCode => 'Dán mã LAN:... hoặc NOS:... tại đây';

  @override
  String get transferConnect => 'Kết nối';

  @override
  String get transferGenerating => 'Đang tạo mã chuyển…';

  @override
  String get transferShareCode => 'Chia sẻ mã này với người nhận:';

  @override
  String get transferCopyCode => 'Sao chép mã';

  @override
  String get transferCodeCopied => 'Đã sao chép mã vào clipboard';

  @override
  String get transferWaitingReceiver => 'Đang chờ người nhận kết nối…';

  @override
  String get transferConnectingSender => 'Đang kết nối đến người gửi…';

  @override
  String get transferVerifyBoth =>
      'So sánh mã này trên cả hai thiết bị.\nNếu khớp, việc chuyển là an toàn.';

  @override
  String get transferComplete => 'Chuyển hoàn tất';

  @override
  String get transferKeysImported => 'Đã nhập khóa';

  @override
  String get transferCompleteSenderBody =>
      'Các khóa vẫn hoạt động trên thiết bị này.\nNgười nhận giờ có thể sử dụng danh tính của bạn.';

  @override
  String get transferCompleteReceiverBody =>
      'Nhập khóa thành công.\nKhởi động lại ứng dụng để áp dụng danh tính mới.';

  @override
  String get transferRestartApp => 'Khởi động lại ứng dụng';

  @override
  String get transferFailed => 'Chuyển thất bại';

  @override
  String get transferTryAgain => 'Thử lại';

  @override
  String get transferEnterRelayFirst => 'Nhập URL relay trước';

  @override
  String get transferPasteCodeFromSender => 'Dán mã chuyển từ người gửi';

  @override
  String get menuReply => 'Trả lời';

  @override
  String get menuForward => 'Chuyển tiếp';

  @override
  String get menuReact => 'Biểu cảm';

  @override
  String get menuCopy => 'Sao chép';

  @override
  String get menuEdit => 'Chỉnh sửa';

  @override
  String get menuRetry => 'Thử lại';

  @override
  String get menuCancelScheduled => 'Hủy hẹn giờ';

  @override
  String get menuDelete => 'Xóa';

  @override
  String get menuForwardTo => 'Chuyển tiếp đến…';

  @override
  String menuForwardedTo(String name) {
    return 'Đã chuyển tiếp đến $name';
  }

  @override
  String get menuScheduledMessages => 'Tin nhắn hẹn giờ';

  @override
  String get menuNoScheduledMessages => 'Không có tin nhắn hẹn giờ';

  @override
  String menuSendsOn(String date) {
    return 'Gửi vào $date';
  }

  @override
  String get menuDisappearingMessages => 'Tin nhắn tự hủy';

  @override
  String get menuDisappearingSubtitle =>
      'Tin nhắn tự động xóa sau thời gian đã chọn.';

  @override
  String get menuTtlOff => 'Tắt';

  @override
  String get menuTtl1h => '1 giờ';

  @override
  String get menuTtl24h => '24 giờ';

  @override
  String get menuTtl7d => '7 ngày';

  @override
  String get menuAttachPhoto => 'Ảnh';

  @override
  String get menuAttachFile => 'Tệp';

  @override
  String get menuAttachVideo => 'Video';

  @override
  String get mediaTitle => 'Phương tiện';

  @override
  String get mediaFileLabel => 'TỆP';

  @override
  String mediaPhotosTab(int count) {
    return 'Ảnh ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Tệp ($count)';
  }

  @override
  String get mediaNoPhotos => 'Chưa có ảnh';

  @override
  String get mediaNoFiles => 'Chưa có tệp';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Đã lưu tại Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'Không thể lưu tệp';

  @override
  String get statusNewStatus => 'Trạng thái mới';

  @override
  String get statusPublish => 'Đăng';

  @override
  String get statusExpiresIn24h => 'Trạng thái hết hạn sau 24 giờ';

  @override
  String get statusWhatsOnYourMind => 'Bạn đang nghĩ gì?';

  @override
  String get statusPhotoAttached => 'Đã đính kèm ảnh';

  @override
  String get statusAttachPhoto => 'Đính kèm ảnh (tùy chọn)';

  @override
  String get statusEnterText => 'Vui lòng nhập nội dung cho trạng thái.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Không thể chọn ảnh: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Đăng thất bại: $error';
  }

  @override
  String get panicSetPanicKey => 'Đặt khóa khẩn cấp';

  @override
  String get panicEmergencySelfDestruct => 'Tự hủy khẩn cấp';

  @override
  String get panicIrreversible => 'Hành động này không thể hoàn tác';

  @override
  String get panicWarningBody =>
      'Nhập khóa này tại màn hình khóa sẽ xóa ngay TẤT CẢ dữ liệu — tin nhắn, liên hệ, khóa, danh tính. Sử dụng khóa khác với mật khẩu thường.';

  @override
  String get panicKeyHint => 'Khóa khẩn cấp';

  @override
  String get panicConfirmHint => 'Xác nhận khóa khẩn cấp';

  @override
  String get panicMinChars => 'Khóa khẩn cấp phải có ít nhất 8 ký tự';

  @override
  String get panicKeysDoNotMatch => 'Khóa không khớp';

  @override
  String get panicSetFailed => 'Không thể lưu khóa khẩn cấp — vui lòng thử lại';

  @override
  String get passwordSetAppPassword => 'Đặt mật khẩu ứng dụng';

  @override
  String get passwordProtectsMessages => 'Bảo vệ tin nhắn khi không sử dụng';

  @override
  String get passwordInfoBanner =>
      'Yêu cầu mỗi lần mở Pulse. Nếu quên, dữ liệu không thể khôi phục.';

  @override
  String get passwordHint => 'Mật khẩu';

  @override
  String get passwordConfirmHint => 'Xác nhận mật khẩu';

  @override
  String get passwordSetButton => 'Đặt mật khẩu';

  @override
  String get passwordSkipForNow => 'Bỏ qua';

  @override
  String get passwordMinChars => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get passwordsDoNotMatch => 'Mật khẩu không khớp';

  @override
  String get profileCardSaved => 'Đã lưu hồ sơ!';

  @override
  String get profileCardE2eeIdentity => 'Danh tính E2EE';

  @override
  String get profileCardDisplayName => 'Tên hiển thị';

  @override
  String get profileCardDisplayNameHint => 'VD: Nguyễn Văn A';

  @override
  String get profileCardAbout => 'Giới thiệu';

  @override
  String get profileCardSaveProfile => 'Lưu hồ sơ';

  @override
  String get profileCardYourName => 'Tên của bạn';

  @override
  String get profileCardAddressCopied => 'Đã sao chép địa chỉ!';

  @override
  String get profileCardInboxAddress => 'Địa chỉ hộp thư của bạn';

  @override
  String get profileCardInboxAddresses => 'Các địa chỉ hộp thư của bạn';

  @override
  String get profileCardShareAllAddresses =>
      'Chia sẻ tất cả địa chỉ (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Chia sẻ với liên hệ để họ có thể nhắn tin cho bạn.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Đã sao chép tất cả $count địa chỉ thành một liên kết!';
  }

  @override
  String get settingsMyProfile => 'Hồ sơ của tôi';

  @override
  String get settingsYourInboxAddress => 'Địa chỉ hộp thư của bạn';

  @override
  String get settingsMyQrCode => 'Mã QR của tôi';

  @override
  String get settingsMyQrSubtitle => 'Chia sẻ địa chỉ dưới dạng QR có thể quét';

  @override
  String get settingsShareMyAddress => 'Chia sẻ địa chỉ';

  @override
  String get settingsNoAddressYet => 'Chưa có địa chỉ — lưu cài đặt trước';

  @override
  String get settingsInviteLink => 'Liên kết mời';

  @override
  String get settingsRawAddress => 'Địa chỉ thô';

  @override
  String get settingsCopyLink => 'Sao chép liên kết';

  @override
  String get settingsCopyAddress => 'Sao chép địa chỉ';

  @override
  String get settingsInviteLinkCopied => 'Đã sao chép liên kết mời';

  @override
  String get settingsAppearance => 'Giao diện';

  @override
  String get settingsThemeEngine => 'Trình theme';

  @override
  String get settingsThemeEngineSubtitle => 'Tùy chỉnh màu sắc & phông chữ';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle => 'Khóa E2EE được lưu trữ an toàn';

  @override
  String get settingsActive => 'HOẠT ĐỘNG';

  @override
  String get settingsIdentityBackup => 'Sao lưu danh tính';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Xuất hoặc nhập danh tính Signal';

  @override
  String get settingsIdentityBackupBody =>
      'Xuất khóa danh tính Signal thành mã sao lưu, hoặc khôi phục từ mã có sẵn.';

  @override
  String get settingsTransferDevice => 'Chuyển sang thiết bị khác';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Di chuyển danh tính qua LAN hoặc Nostr relay';

  @override
  String get settingsExportIdentity => 'Xuất danh tính';

  @override
  String get settingsExportIdentityBody =>
      'Sao chép mã sao lưu này và lưu trữ an toàn:';

  @override
  String get settingsSaveFile => 'Lưu tệp';

  @override
  String get settingsImportIdentity => 'Nhập danh tính';

  @override
  String get settingsImportIdentityBody =>
      'Dán mã sao lưu bên dưới. Thao tác này sẽ ghi đè danh tính hiện tại.';

  @override
  String get settingsPasteBackupCode => 'Dán mã sao lưu tại đây…';

  @override
  String get settingsIdentityImported =>
      'Đã nhập danh tính + liên hệ! Khởi động lại ứng dụng để áp dụng.';

  @override
  String get settingsSecurity => 'Bảo mật';

  @override
  String get settingsAppPassword => 'Mật khẩu ứng dụng';

  @override
  String get settingsPasswordEnabled => 'Đã bật — yêu cầu mỗi lần khởi động';

  @override
  String get settingsPasswordDisabled =>
      'Đã tắt — mở ứng dụng không cần mật khẩu';

  @override
  String get settingsChangePassword => 'Đổi mật khẩu';

  @override
  String get settingsChangePasswordSubtitle =>
      'Cập nhật mật khẩu khóa ứng dụng';

  @override
  String get settingsSetPanicKey => 'Đặt khóa khẩn cấp';

  @override
  String get settingsChangePanicKey => 'Đổi khóa khẩn cấp';

  @override
  String get settingsPanicKeySetSubtitle => 'Cập nhật khóa xóa khẩn cấp';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Một khóa xóa ngay toàn bộ dữ liệu';

  @override
  String get settingsRemovePanicKey => 'Xóa khóa khẩn cấp';

  @override
  String get settingsRemovePanicKeySubtitle => 'Tắt chế độ tự hủy khẩn cấp';

  @override
  String get settingsRemovePanicKeyBody =>
      'Chế độ tự hủy khẩn cấp sẽ bị tắt. Bạn có thể bật lại bất cứ lúc nào.';

  @override
  String get settingsDisableAppPassword => 'Tắt mật khẩu ứng dụng';

  @override
  String get settingsEnterCurrentPassword =>
      'Nhập mật khẩu hiện tại để xác nhận';

  @override
  String get settingsCurrentPassword => 'Mật khẩu hiện tại';

  @override
  String get settingsIncorrectPassword => 'Sai mật khẩu';

  @override
  String get settingsPasswordUpdated => 'Đã cập nhật mật khẩu';

  @override
  String get settingsChangePasswordProceed =>
      'Nhập mật khẩu hiện tại để tiếp tục';

  @override
  String get settingsData => 'Dữ liệu';

  @override
  String get settingsBackupMessages => 'Sao lưu tin nhắn';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Xuất lịch sử tin nhắn đã mã hóa ra tệp';

  @override
  String get settingsRestoreMessages => 'Khôi phục tin nhắn';

  @override
  String get settingsRestoreMessagesSubtitle => 'Nhập tin nhắn từ tệp sao lưu';

  @override
  String get settingsExportKeys => 'Xuất khóa';

  @override
  String get settingsExportKeysSubtitle => 'Lưu khóa danh tính ra tệp mã hóa';

  @override
  String get settingsImportKeys => 'Nhập khóa';

  @override
  String get settingsImportKeysSubtitle =>
      'Khôi phục khóa danh tính từ tệp đã xuất';

  @override
  String get settingsBackupPassword => 'Mật khẩu sao lưu';

  @override
  String get settingsPasswordCannotBeEmpty => 'Mật khẩu không được để trống';

  @override
  String get settingsPasswordMin4Chars => 'Mật khẩu phải có ít nhất 4 ký tự';

  @override
  String get settingsCallsTurn => 'Cuộc gọi & TURN';

  @override
  String get settingsLocalNetwork => 'Mạng nội bộ';

  @override
  String get settingsCensorshipResistance => 'Chống kiểm duyệt';

  @override
  String get settingsNetwork => 'Mạng';

  @override
  String get settingsProxyTunnels => 'Proxy & Đường hầm';

  @override
  String get settingsTurnServers => 'Máy chủ TURN';

  @override
  String get settingsProviderTitle => 'Nhà cung cấp';

  @override
  String get settingsLanFallback => 'LAN dự phòng';

  @override
  String get settingsLanFallbackSubtitle =>
      'Phát hiện trạng thái và gửi tin nhắn qua mạng nội bộ khi không có internet. Tắt trên mạng không đáng tin cậy (Wi-Fi công cộng).';

  @override
  String get settingsBgDelivery => 'Nhận tin nền';

  @override
  String get settingsBgDeliverySubtitle =>
      'Tiếp tục nhận tin nhắn khi ứng dụng thu nhỏ. Hiển thị thông báo cố định.';

  @override
  String get settingsYourInboxProvider => 'Nhà cung cấp hộp thư';

  @override
  String get settingsConnectionDetails => 'Chi tiết kết nối';

  @override
  String get settingsSaveAndConnect => 'Lưu & Kết nối';

  @override
  String get settingsSecondaryInboxes => 'Hộp thư phụ';

  @override
  String get settingsAddSecondaryInbox => 'Thêm hộp thư phụ';

  @override
  String get settingsAdvanced => 'Nâng cao';

  @override
  String get settingsDiscover => 'Khám phá';

  @override
  String get settingsAbout => 'Giới thiệu';

  @override
  String get settingsPrivacyPolicy => 'Chính sách bảo mật';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Cách Pulse bảo vệ dữ liệu của bạn';

  @override
  String get settingsCrashReporting => 'Báo lỗi';

  @override
  String get settingsCrashReportingSubtitle =>
      'Gửi báo cáo lỗi ẩn danh để cải thiện Pulse. Không bao giờ gửi nội dung tin nhắn hay liên hệ.';

  @override
  String get settingsCrashReportingEnabled =>
      'Đã bật báo lỗi — khởi động lại ứng dụng để áp dụng';

  @override
  String get settingsCrashReportingDisabled =>
      'Đã tắt báo lỗi — khởi động lại ứng dụng để áp dụng';

  @override
  String get settingsSensitiveOperation => 'Thao tác nhạy cảm';

  @override
  String get settingsSensitiveOperationBody =>
      'Các khóa này là danh tính của bạn. Bất kỳ ai có tệp này đều có thể mạo danh bạn. Lưu trữ an toàn và xóa sau khi chuyển.';

  @override
  String get settingsIUnderstandContinue => 'Tôi hiểu, tiếp tục';

  @override
  String get settingsReplaceIdentity => 'Thay thế danh tính?';

  @override
  String get settingsReplaceIdentityBody =>
      'Thao tác này sẽ ghi đè khóa danh tính hiện tại. Các phiên Signal hiện có sẽ bị vô hiệu và liên hệ cần thiết lập lại mã hóa. Ứng dụng cần khởi động lại.';

  @override
  String get settingsReplaceKeys => 'Thay thế khóa';

  @override
  String get settingsKeysImported => 'Đã nhập khóa';

  @override
  String settingsKeysImportedBody(int count) {
    return 'Đã nhập thành công $count khóa. Vui lòng khởi động lại ứng dụng để khởi tạo với danh tính mới.';
  }

  @override
  String get settingsRestartNow => 'Khởi động lại ngay';

  @override
  String get settingsLater => 'Sau';

  @override
  String get profileGroupLabel => 'Nhóm';

  @override
  String get profileAddButton => 'Thêm';

  @override
  String get profileKickButton => 'Loại';

  @override
  String get dataSectionTitle => 'Dữ liệu';

  @override
  String get dataBackupMessages => 'Sao lưu tin nhắn';

  @override
  String get dataBackupPasswordSubtitle =>
      'Chọn mật khẩu để mã hóa bản sao lưu.';

  @override
  String get dataBackupConfirmLabel => 'Tạo bản sao lưu';

  @override
  String get dataCreatingBackup => 'Đang tạo bản sao lưu';

  @override
  String get dataBackupPreparing => 'Đang chuẩn bị...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Đang xuất tin nhắn $done / $total...';
  }

  @override
  String get dataBackupSavingFile => 'Đang lưu tệp...';

  @override
  String get dataSaveMessageBackupDialog => 'Lưu bản sao lưu tin nhắn';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Đã lưu bản sao lưu ($count tin nhắn)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Sao lưu thất bại — không có dữ liệu được xuất';

  @override
  String dataBackupFailedError(String error) {
    return 'Sao lưu thất bại: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Chọn bản sao lưu tin nhắn';

  @override
  String get dataInvalidBackupFile => 'Tệp sao lưu không hợp lệ (quá nhỏ)';

  @override
  String get dataNotValidBackupFile => 'Không phải tệp sao lưu Pulse hợp lệ';

  @override
  String get dataRestoreMessages => 'Khôi phục tin nhắn';

  @override
  String get dataRestorePasswordSubtitle =>
      'Nhập mật khẩu đã dùng để tạo bản sao lưu này.';

  @override
  String get dataRestoreConfirmLabel => 'Khôi phục';

  @override
  String get dataRestoringMessages => 'Đang khôi phục tin nhắn';

  @override
  String get dataRestoreDecrypting => 'Đang giải mã...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Đang nhập tin nhắn $done / $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Khôi phục thất bại — sai mật khẩu hoặc tệp bị hỏng';

  @override
  String dataRestoreSuccess(int count) {
    return 'Đã khôi phục $count tin nhắn mới';
  }

  @override
  String get dataRestoreNothingNew =>
      'Không có tin nhắn mới để nhập (tất cả đã tồn tại)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Khôi phục thất bại: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Chọn tệp xuất khóa';

  @override
  String get dataNotValidKeyFile => 'Không phải tệp xuất khóa Pulse hợp lệ';

  @override
  String get dataExportKeys => 'Xuất khóa';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Chọn mật khẩu để mã hóa tệp xuất khóa.';

  @override
  String get dataExportKeysConfirmLabel => 'Xuất';

  @override
  String get dataExportingKeys => 'Đang xuất khóa';

  @override
  String get dataExportingKeysStatus => 'Đang mã hóa khóa danh tính...';

  @override
  String get dataSaveKeyExportDialog => 'Lưu tệp xuất khóa';

  @override
  String dataKeysExportedTo(String path) {
    return 'Đã xuất khóa tại:\n$path';
  }

  @override
  String get dataExportFailed => 'Xuất thất bại — không tìm thấy khóa';

  @override
  String dataExportFailedError(String error) {
    return 'Xuất thất bại: $error';
  }

  @override
  String get dataImportKeys => 'Nhập khóa';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Nhập mật khẩu đã dùng để mã hóa tệp xuất khóa này.';

  @override
  String get dataImportKeysConfirmLabel => 'Nhập';

  @override
  String get dataImportingKeys => 'Đang nhập khóa';

  @override
  String get dataImportingKeysStatus => 'Đang giải mã khóa danh tính...';

  @override
  String get dataImportFailed =>
      'Nhập thất bại — sai mật khẩu hoặc tệp bị hỏng';

  @override
  String dataImportFailedError(String error) {
    return 'Nhập thất bại: $error';
  }

  @override
  String get securitySectionTitle => 'Bảo mật';

  @override
  String get securityIncorrectPassword => 'Sai mật khẩu';

  @override
  String get securityPasswordUpdated => 'Đã cập nhật mật khẩu';

  @override
  String get appearanceSectionTitle => 'Giao diện';

  @override
  String appearanceExportFailed(String error) {
    return 'Xuất thất bại: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Đã lưu tại $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Lưu thất bại: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Nhập thất bại: $error';
  }

  @override
  String get aboutSectionTitle => 'Giới thiệu';

  @override
  String get providerPublicKey => 'Khóa công khai';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Tự động cấu hình từ mật khẩu khôi phục. Relay được tìm tự động.';

  @override
  String get providerKeyStoredLocally =>
      'Khóa được lưu cục bộ trong bộ nhớ an toàn — không bao giờ gửi đến máy chủ nào.';

  @override
  String get providerOxenInfo =>
      'Mạng Oxen/Session — E2EE qua định tuyến onion. Session ID được tạo tự động và lưu trữ an toàn. Các node được tìm tự động từ seed node tích hợp.';

  @override
  String get providerAdvanced => 'Nâng cao';

  @override
  String get providerSaveAndConnect => 'Lưu & Kết nối';

  @override
  String get providerAddSecondaryInbox => 'Thêm hộp thư phụ';

  @override
  String get providerSecondaryInboxes => 'Hộp thư phụ';

  @override
  String get providerYourInboxProvider => 'Nhà cung cấp hộp thư';

  @override
  String get providerConnectionDetails => 'Chi tiết kết nối';

  @override
  String get addContactTitle => 'Thêm liên hệ';

  @override
  String get addContactInviteLinkLabel => 'Liên kết mời hoặc địa chỉ';

  @override
  String get addContactTapToPaste => 'Nhấn để dán liên kết mời';

  @override
  String get addContactPasteTooltip => 'Dán từ clipboard';

  @override
  String get addContactAddressDetected => 'Đã phát hiện địa chỉ liên hệ';

  @override
  String addContactRoutesDetected(int count) {
    return 'Phát hiện $count tuyến — SmartRouter chọn nhanh nhất';
  }

  @override
  String get addContactFetchingProfile => 'Đang tải hồ sơ…';

  @override
  String addContactProfileFound(String name) {
    return 'Tìm thấy: $name';
  }

  @override
  String get addContactNoProfileFound => 'Không tìm thấy hồ sơ';

  @override
  String get addContactDisplayNameLabel => 'Tên hiển thị';

  @override
  String get addContactDisplayNameHint => 'Bạn muốn gọi họ là gì?';

  @override
  String get addContactAddManually => 'Nhập địa chỉ thủ công';

  @override
  String get addContactButton => 'Thêm liên hệ';

  @override
  String get networkDiagnosticsTitle => 'Chẩn đoán mạng';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr Relay';

  @override
  String get networkDiagnosticsDirect => 'Trực tiếp';

  @override
  String get networkDiagnosticsTorOnly => 'Chỉ Tor';

  @override
  String get networkDiagnosticsBest => 'Tốt nhất';

  @override
  String get networkDiagnosticsNone => 'không có';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Trạng thái';

  @override
  String get networkDiagnosticsConnected => 'Đã kết nối';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Đang kết nối $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Tắt';

  @override
  String get networkDiagnosticsTransport => 'Kênh truyền';

  @override
  String get networkDiagnosticsInfrastructure => 'Hạ tầng';

  @override
  String get networkDiagnosticsOxenNodes => 'Node Oxen';

  @override
  String get networkDiagnosticsTurnServers => 'Máy chủ TURN';

  @override
  String get networkDiagnosticsLastProbe => 'Kiểm tra gần nhất';

  @override
  String get networkDiagnosticsRunning => 'Đang chạy...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Chạy chẩn đoán';

  @override
  String get networkDiagnosticsForceReprobe => 'Kiểm tra lại toàn bộ';

  @override
  String get networkDiagnosticsJustNow => 'vừa xong';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes phút trước';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours giờ trước';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days ngày trước';
  }

  @override
  String get homeNoEch => 'Không có ECH';

  @override
  String get homeNoEchTooltip =>
      'Proxy uTLS không khả dụng — ECH bị tắt.\nVân tay TLS có thể bị DPI phát hiện.';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Đã lưu & kết nối đến $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Tor tích hợp không khởi động được';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon không khởi động được';

  @override
  String get verifyTitle => 'Xác minh số an toàn';

  @override
  String get verifyIdentityVerified => 'Đã xác minh danh tính';

  @override
  String get verifyNotYetVerified => 'Chưa xác minh';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Bạn đã xác minh số an toàn của $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'So sánh các số này với $name trực tiếp hoặc qua kênh đáng tin cậy.';
  }

  @override
  String get verifyExplanation =>
      'Mỗi cuộc hội thoại có một số an toàn duy nhất. Nếu cả hai cùng thấy các số giống nhau trên thiết bị, kết nối đã được xác minh đầu cuối.';

  @override
  String verifyContactKey(String name) {
    return 'Khóa của $name';
  }

  @override
  String get verifyYourKey => 'Khóa của bạn';

  @override
  String get verifyRemoveVerification => 'Xóa xác minh';

  @override
  String get verifyMarkAsVerified => 'Đánh dấu đã xác minh';

  @override
  String verifyAfterReinstall(String name) {
    return 'Nếu $name cài lại ứng dụng, số an toàn sẽ thay đổi và xác minh sẽ bị xóa tự động.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Chỉ đánh dấu đã xác minh sau khi so sánh số với $name qua cuộc gọi thoại hoặc gặp trực tiếp.';
  }

  @override
  String get verifyNoSession =>
      'Chưa có phiên mã hóa. Gửi tin nhắn trước để tạo số an toàn.';

  @override
  String get verifyNoKeyAvailable => 'Không có khóa';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Đã sao chép vân tay $label';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL cơ sở dữ liệu';

  @override
  String get providerOptionalHint => 'Tùy chọn';

  @override
  String get providerWebApiKeyLabel => 'Web API Key';

  @override
  String get providerOptionalForPublicDb => 'Tùy chọn cho DB công khai';

  @override
  String get providerRelayUrlLabel => 'URL Relay';

  @override
  String get providerPrivateKeyLabel => 'Khóa riêng tư';

  @override
  String get providerPrivateKeyNsecLabel => 'Khóa riêng tư (nsec)';

  @override
  String get providerStorageNodeLabel => 'URL node lưu trữ (tùy chọn)';

  @override
  String get providerStorageNodeHint => 'Để trống để dùng seed node tích hợp';

  @override
  String get transferInvalidCodeFormat =>
      'Định dạng mã không nhận diện được — phải bắt đầu bằng LAN: hoặc NOS:';

  @override
  String get profileCardFingerprintCopied => 'Đã sao chép vân tay';

  @override
  String get profileCardAboutHint => 'Bảo mật là trên hết 🔒';

  @override
  String get profileCardSaveButton => 'Lưu hồ sơ';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Xuất tin nhắn mã hóa, liên hệ và ảnh đại diện ra tệp';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Âm thanh';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Đã gửi đến $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Đã gửi đến $count người';
  }

  @override
  String get groupStatusDialogTitle => 'Thông tin tin nhắn';

  @override
  String get groupStatusRead => 'Đã đọc';

  @override
  String get groupStatusDelivered => 'Đã gửi';

  @override
  String get groupStatusPending => 'Đang chờ';

  @override
  String get groupStatusNoData => 'Chưa có thông tin gửi';

  @override
  String get profileTransferAdmin => 'Chuyển quyền quản trị';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Chuyển $name làm quản trị viên mới?';
  }

  @override
  String get profileTransferAdminBody =>
      'Bạn sẽ mất quyền quản trị. Không thể hoàn tác.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name giờ là quản trị viên';
  }

  @override
  String get profileAdminBadge => 'Quản trị';

  @override
  String get privacyPolicyTitle => 'Chính sách bảo mật';

  @override
  String get privacyOverviewHeading => 'Tổng quan';

  @override
  String get privacyOverviewBody =>
      'Pulse là ứng dụng nhắn tin mã hóa đầu cuối không có máy chủ. Sự riêng tư của bạn không chỉ là tính năng — đó là kiến trúc. Không có máy chủ Pulse. Không có tài khoản được lưu ở đâu cả. Không có dữ liệu nào được thu thập, truyền hoặc lưu trữ bởi nhà phát triển.';

  @override
  String get privacyDataCollectionHeading => 'Thu thập dữ liệu';

  @override
  String get privacyDataCollectionBody =>
      'Pulse không thu thập bất kỳ dữ liệu cá nhân nào. Cụ thể:\n\n- Không yêu cầu email, số điện thoại hay tên thật\n- Không phân tích, theo dõi hay thu thập dữ liệu sử dụng\n- Không có mã nhận dạng quảng cáo\n- Không truy cập danh bạ\n- Không sao lưu đám mây (tin nhắn chỉ tồn tại trên thiết bị)\n- Không gửi siêu dữ liệu đến máy chủ Pulse nào (vì không có)';

  @override
  String get privacyEncryptionHeading => 'Mã hóa';

  @override
  String get privacyEncryptionBody =>
      'Tất cả tin nhắn được mã hóa bằng Signal Protocol (Double Ratchet với X3DH key agreement). Khóa mã hóa được tạo và lưu trữ hoàn toàn trên thiết bị. Không ai — kể cả nhà phát triển — có thể đọc tin nhắn của bạn.';

  @override
  String get privacyNetworkHeading => 'Kiến trúc mạng';

  @override
  String get privacyNetworkBody =>
      'Pulse sử dụng bộ điều hợp truyền tải liên hợp (Nostr relay, Session/Oxen service node, Firebase Realtime Database, LAN). Các kênh này chỉ truyền bản mã đã mã hóa. Người vận hành relay có thể thấy IP và lưu lượng, nhưng không thể giải mã nội dung.\n\nKhi bật Tor, địa chỉ IP cũng được ẩn khỏi người vận hành relay.';

  @override
  String get privacyStunHeading => 'Máy chủ STUN/TURN';

  @override
  String get privacyStunBody =>
      'Cuộc gọi thoại và video sử dụng WebRTC với mã hóa DTLS-SRTP. Máy chủ STUN (dùng để tìm IP công khai cho kết nối P2P) và máy chủ TURN (dùng để chuyển tiếp phương tiện khi kết nối trực tiếp thất bại) có thể thấy IP và thời lượng cuộc gọi, nhưng không thể giải mã nội dung.\n\nBạn có thể cấu hình máy chủ TURN riêng trong Cài đặt để đảm bảo quyền riêng tư tối đa.';

  @override
  String get privacyCrashHeading => 'Báo lỗi';

  @override
  String get privacyCrashBody =>
      'Nếu bật báo lỗi Sentry (qua SENTRY_DSN lúc build), báo cáo lỗi ẩn danh có thể được gửi. Không chứa nội dung tin nhắn, thông tin liên hệ hay dữ liệu nhận dạng cá nhân. Có thể tắt lúc build bằng cách bỏ DSN.';

  @override
  String get privacyPasswordHeading => 'Mật khẩu & Khóa';

  @override
  String get privacyPasswordBody =>
      'Mật khẩu khôi phục dùng để tạo khóa mật mã qua Argon2id (memory-hard KDF). Mật khẩu không bao giờ được truyền đi đâu. Nếu mất mật khẩu, tài khoản không thể khôi phục — không có máy chủ để đặt lại.';

  @override
  String get privacyFontsHeading => 'Phông chữ';

  @override
  String get privacyFontsBody =>
      'Pulse đóng gói tất cả phông chữ cục bộ. Không gửi yêu cầu đến Google Fonts hay dịch vụ phông chữ bên ngoài.';

  @override
  String get privacyThirdPartyHeading => 'Dịch vụ bên thứ ba';

  @override
  String get privacyThirdPartyBody =>
      'Pulse không tích hợp với bất kỳ mạng quảng cáo, nhà cung cấp phân tích, nền tảng mạng xã hội hay môi giới dữ liệu nào. Kết nối mạng duy nhất là đến các relay mà bạn cấu hình.';

  @override
  String get privacyOpenSourceHeading => 'Mã nguồn mở';

  @override
  String get privacyOpenSourceBody =>
      'Pulse là phần mềm mã nguồn mở. Bạn có thể kiểm tra toàn bộ mã nguồn để xác minh các cam kết bảo mật này.';

  @override
  String get privacyContactHeading => 'Liên hệ';

  @override
  String get privacyContactBody =>
      'Với câu hỏi về quyền riêng tư, hãy mở issue trên kho mã nguồn dự án.';

  @override
  String get privacyLastUpdated => 'Cập nhật lần cuối: Tháng 3, 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Lưu thất bại: $error';
  }

  @override
  String get themeEngineTitle => 'Trình theme';

  @override
  String get torBuiltInTitle => 'Tor tích hợp';

  @override
  String get torConnectedSubtitle => 'Đã kết nối — Nostr qua 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Đang kết nối… $pct%';
  }

  @override
  String get torNotRunning => 'Không chạy — nhấn công tắc để khởi động lại';

  @override
  String get torDescription =>
      'Định tuyến Nostr qua Tor (Snowflake cho mạng bị kiểm duyệt)';

  @override
  String get torNetworkDiagnostics => 'Chẩn đoán mạng';

  @override
  String get torTransportLabel => 'Kênh truyền: ';

  @override
  String get torPtAuto => 'Tự động';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Thường';

  @override
  String get torTimeoutLabel => 'Thời gian chờ: ';

  @override
  String get torInfoDescription =>
      'Khi bật, kết nối WebSocket của Nostr được định tuyến qua Tor (SOCKS5). Tor Browser nghe trên 127.0.0.1:9150. Tor daemon dùng cổng 9050. Kết nối Firebase không bị ảnh hưởng.';

  @override
  String get torRouteNostrTitle => 'Định tuyến Nostr qua Tor';

  @override
  String get torManagedByBuiltin => 'Quản lý bởi Tor tích hợp';

  @override
  String get torActiveRouting => 'Hoạt động — lưu lượng Nostr qua Tor';

  @override
  String get torDisabled => 'Đã tắt';

  @override
  String get torProxySocks5 => 'Proxy Tor (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Host proxy';

  @override
  String get torProxyPortLabel => 'Cổng';

  @override
  String get torPortInfo => 'Tor Browser: cổng 9150  •  Tor daemon: cổng 9050';

  @override
  String get i2pProxySocks5 => 'Proxy I2P (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P sử dụng SOCKS5 trên cổng 4447 mặc định. Kết nối với Nostr relay qua I2P outproxy (VD: relay.damus.i2p) để giao tiếp với người dùng trên bất kỳ kênh nào. Tor ưu tiên khi cả hai đều bật.';

  @override
  String get i2pRouteNostrTitle => 'Định tuyến Nostr qua I2P';

  @override
  String get i2pActiveRouting => 'Hoạt động — lưu lượng Nostr qua I2P';

  @override
  String get i2pDisabled => 'Đã tắt';

  @override
  String get i2pProxyHostLabel => 'Host proxy';

  @override
  String get i2pProxyPortLabel => 'Cổng';

  @override
  String get i2pPortInfo => 'Cổng SOCKS5 mặc định I2P Router: 4447';

  @override
  String get customProxySocks5 => 'Proxy tùy chỉnh (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Proxy tùy chỉnh định tuyến lưu lượng qua V2Ray/Xray/Shadowsocks. CF Worker hoạt động như relay proxy cá nhân trên Cloudflare CDN — GFW thấy *.workers.dev, không phải relay thật.';

  @override
  String get customSocks5ProxyTitle => 'Proxy SOCKS5 tùy chỉnh';

  @override
  String get customProxyActive => 'Hoạt động — lưu lượng qua SOCKS5';

  @override
  String get customProxyDisabled => 'Đã tắt';

  @override
  String get customProxyHostLabel => 'Host proxy';

  @override
  String get customProxyPortLabel => 'Cổng';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Tên miền Worker (tùy chọn)';

  @override
  String get customWorkerHelpTitle =>
      'Cách triển khai CF Worker relay (miễn phí)';

  @override
  String get customWorkerScriptCopied => 'Đã sao chép script!';

  @override
  String get customWorkerStep1 =>
      '1. Vào dash.cloudflare.com → Workers & Pages\n2. Create Worker → dán script này:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → sao chép tên miền (VD: my-relay.user.workers.dev)\n4. Dán tên miền ở trên → Lưu\n\nỨng dụng tự kết nối: wss://domain/?r=relay_url\nGFW thấy: kết nối đến *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Đã kết nối — SOCKS5 trên 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Đang kết nối…';

  @override
  String get psiphonNotRunning => 'Không chạy — nhấn công tắc để khởi động lại';

  @override
  String get psiphonDescription =>
      'Đường hầm nhanh (~3s bootstrap, 2000+ VPS xoay vòng)';

  @override
  String get turnCommunityServers => 'Máy chủ TURN cộng đồng';

  @override
  String get turnCustomServer => 'Máy chủ TURN tùy chỉnh (BYOD)';

  @override
  String get turnInfoDescription =>
      'Máy chủ TURN chỉ chuyển tiếp luồng đã mã hóa (DTLS-SRTP). Người vận hành relay thấy IP và lưu lượng, nhưng không thể giải mã cuộc gọi. TURN chỉ dùng khi P2P trực tiếp thất bại (~15–20% kết nối).';

  @override
  String get turnFreeLabel => 'MIỄN PHÍ';

  @override
  String get turnServerUrlLabel => 'URL máy chủ TURN';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 hoặc turns:...';

  @override
  String get turnUsernameLabel => 'Tên người dùng';

  @override
  String get turnPasswordLabel => 'Mật khẩu';

  @override
  String get turnOptionalHint => 'Tùy chọn';

  @override
  String get turnCustomInfo =>
      'Tự host coturn trên VPS \$5/tháng để kiểm soát tối đa. Thông tin đăng nhập lưu cục bộ.';

  @override
  String get themePickerAppearance => 'Giao diện';

  @override
  String get themePickerAccentColor => 'Màu nhấn';

  @override
  String get themeModeLight => 'Sáng';

  @override
  String get themeModeDark => 'Tối';

  @override
  String get themeModeSystem => 'Hệ thống';

  @override
  String get themeDynamicPresets => 'Mẫu có sẵn';

  @override
  String get themeDynamicPrimaryColor => 'Màu chính';

  @override
  String get themeDynamicBorderRadius => 'Bo góc';

  @override
  String get themeDynamicFont => 'Phông chữ';

  @override
  String get themeDynamicAppearance => 'Giao diện';

  @override
  String get themeDynamicUiStyle => 'Kiểu UI';

  @override
  String get themeDynamicUiStyleDescription =>
      'Kiểm soát giao diện hộp thoại, công tắc và chỉ báo.';

  @override
  String get themeDynamicSharp => 'Sắc nét';

  @override
  String get themeDynamicRound => 'Bo tròn';

  @override
  String get themeDynamicModeDark => 'Tối';

  @override
  String get themeDynamicModeLight => 'Sáng';

  @override
  String get themeDynamicModeAuto => 'Tự động';

  @override
  String get themeDynamicPlatformAuto => 'Tự động';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'URL Firebase không hợp lệ. Yêu cầu https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'URL relay không hợp lệ. Yêu cầu wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'URL máy chủ Pulse không hợp lệ. Yêu cầu https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'URL máy chủ';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'Mã mời';

  @override
  String get providerPulseInviteHint => 'Mã mời (nếu cần)';

  @override
  String get providerPulseInfo =>
      'Relay tự host. Khóa được tạo từ mật khẩu khôi phục.';

  @override
  String get providerScreenTitle => 'Hộp thư';

  @override
  String get providerSecondaryInboxesHeader => 'HỘP THƯ PHỤ';

  @override
  String get providerSecondaryInboxesInfo =>
      'Hộp thư phụ nhận tin nhắn đồng thời để dự phòng.';

  @override
  String get providerRemoveTooltip => 'Xóa';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... hoặc hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... hoặc hex private key';

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
  String get emojiNoRecent => 'Không có emoji gần đây';

  @override
  String get emojiSearchHint => 'Tìm emoji...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Nhấn để trò chuyện';

  @override
  String get imageViewerSaveToDownloads => 'Lưu vào Downloads';

  @override
  String imageViewerSavedTo(String path) {
    return 'Đã lưu tại $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsLanguageSubtitle => 'Ngôn ngữ hiển thị ứng dụng';

  @override
  String get settingsLanguageSystem => 'Mặc định hệ thống';

  @override
  String get onboardingLanguageTitle => 'Chọn ngôn ngữ của bạn';

  @override
  String get onboardingLanguageSubtitle =>
      'Bạn có thể thay đổi sau trong Cài đặt';

  @override
  String get videoNoteRecord => 'Ghi tin nhắn video';

  @override
  String get videoNoteTapToRecord => 'Nhấn để ghi';

  @override
  String get videoNoteTapToStop => 'Nhấn để dừng';

  @override
  String get videoNoteCameraPermission => 'Quyền truy cập camera bị từ chối';

  @override
  String get videoNoteMaxDuration => 'Tối đa 30 giây';

  @override
  String get videoNoteNotSupported =>
      'Ghi chú video không được hỗ trợ trên nền tảng này';

  @override
  String get navChats => 'Chats';

  @override
  String get navUpdates => 'Updates';

  @override
  String get navCalls => 'Calls';

  @override
  String get filterAll => 'All';

  @override
  String get filterUnread => 'Unread';

  @override
  String get filterGroups => 'Groups';

  @override
  String get callsNoRecent => 'No recent calls';

  @override
  String get callsEmptySubtitle => 'Your call history will appear here';

  @override
  String get appBarEncrypted => 'end-to-end encrypted';

  @override
  String get newStatus => 'New status';

  @override
  String get newCall => 'New call';
}
