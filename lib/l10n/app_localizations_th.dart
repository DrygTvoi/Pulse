// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'ค้นหาข้อความ...';

  @override
  String get search => 'ค้นหา';

  @override
  String get clearSearch => 'ล้างการค้นหา';

  @override
  String get closeSearch => 'ปิดการค้นหา';

  @override
  String get moreOptions => 'ตัวเลือกเพิ่มเติม';

  @override
  String get back => 'ย้อนกลับ';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get close => 'ปิด';

  @override
  String get confirm => 'ยืนยัน';

  @override
  String get remove => 'ลบออก';

  @override
  String get save => 'บันทึก';

  @override
  String get add => 'เพิ่ม';

  @override
  String get copy => 'คัดลอก';

  @override
  String get skip => 'ข้าม';

  @override
  String get done => 'เสร็จสิ้น';

  @override
  String get apply => 'ใช้งาน';

  @override
  String get export => 'ส่งออก';

  @override
  String get import => 'นำเข้า';

  @override
  String get homeNewGroup => 'กลุ่มใหม่';

  @override
  String get homeSettings => 'การตั้งค่า';

  @override
  String get homeSearching => 'กำลังค้นหาข้อความ...';

  @override
  String get homeNoResults => 'ไม่พบผลลัพธ์';

  @override
  String get homeNoChatHistory => 'ยังไม่มีประวัติแชท';

  @override
  String homeTransportSwitched(String address) {
    return 'เปลี่ยนช่องทางส่งแล้ว → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name กำลังโทร...';
  }

  @override
  String get homeAccept => 'รับสาย';

  @override
  String get homeDecline => 'ปฏิเสธ';

  @override
  String get homeLoadEarlier => 'โหลดข้อความก่อนหน้า';

  @override
  String get homeChats => 'แชท';

  @override
  String get homeSelectConversation => 'เลือกบทสนทนา';

  @override
  String get homeNoChatsYet => 'ยังไม่มีแชท';

  @override
  String get homeAddContactToStart => 'เพิ่มผู้ติดต่อเพื่อเริ่มแชท';

  @override
  String get homeNewChat => 'แชทใหม่';

  @override
  String get homeNewChatTooltip => 'แชทใหม่';

  @override
  String get homeIncomingCallTitle => 'สายเรียกเข้า';

  @override
  String get homeIncomingGroupCallTitle => 'สายเรียกเข้ากลุ่ม';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — สายเรียกเข้ากลุ่ม';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'ไม่พบแชทที่ตรงกับ \"$query\"';
  }

  @override
  String get homeSectionChats => 'แชท';

  @override
  String get homeSectionMessages => 'ข้อความ';

  @override
  String get homeDbEncryptionUnavailable =>
      'ไม่สามารถเข้ารหัสฐานข้อมูลได้ — ติดตั้ง SQLCipher เพื่อการป้องกันเต็มรูปแบบ';

  @override
  String get chatFileTooLargeGroup =>
      'ไม่รองรับไฟล์ที่มีขนาดเกิน 512 KB ในแชทกลุ่ม';

  @override
  String get chatLargeFile => 'ไฟล์ขนาดใหญ่';

  @override
  String get chatCancel => 'ยกเลิก';

  @override
  String get chatSend => 'ส่ง';

  @override
  String get chatFileTooLarge => 'ไฟล์ใหญ่เกินไป — ขนาดสูงสุดคือ 100 MB';

  @override
  String get chatMicDenied => 'ไม่ได้รับอนุญาตให้ใช้ไมโครโฟน';

  @override
  String get chatVoiceFailed =>
      'ไม่สามารถบันทึกข้อความเสียงได้ — ตรวจสอบพื้นที่จัดเก็บ';

  @override
  String get chatScheduleFuture => 'เวลาที่กำหนดต้องเป็นเวลาในอนาคต';

  @override
  String get chatToday => 'วันนี้';

  @override
  String get chatYesterday => 'เมื่อวาน';

  @override
  String get chatEdited => 'แก้ไขแล้ว';

  @override
  String get chatYou => 'คุณ';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'ไฟล์นี้มีขนาด $size MB การส่งไฟล์ขนาดใหญ่อาจช้าในบางเครือข่าย ดำเนินการต่อหรือไม่?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'คีย์ความปลอดภัยของ $name เปลี่ยนแปลงแล้ว แตะเพื่อยืนยัน';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'ไม่สามารถเข้ารหัสข้อความถึง $name ได้ — ข้อความไม่ถูกส่ง';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'หมายเลขความปลอดภัยของ $name เปลี่ยนแปลงแล้ว แตะเพื่อยืนยัน';
  }

  @override
  String get chatNoMessagesFound => 'ไม่พบข้อความ';

  @override
  String get chatMessagesE2ee => 'ข้อความถูกเข้ารหัสแบบต้นทางถึงปลายทาง';

  @override
  String get chatSayHello => 'ทักทาย';

  @override
  String get appBarOnline => 'ออนไลน์';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'กำลังพิมพ์';

  @override
  String get appBarSearchMessages => 'ค้นหาข้อความ...';

  @override
  String get appBarMute => 'ปิดเสียง';

  @override
  String get appBarUnmute => 'เปิดเสียง';

  @override
  String get appBarMedia => 'สื่อ';

  @override
  String get appBarDisappearing => 'ข้อความที่หายไป';

  @override
  String get appBarDisappearingOn => 'หายไป: เปิด';

  @override
  String get appBarGroupSettings => 'การตั้งค่ากลุ่ม';

  @override
  String get appBarSearchTooltip => 'ค้นหาข้อความ';

  @override
  String get appBarVoiceCall => 'โทรด้วยเสียง';

  @override
  String get appBarVideoCall => 'วิดีโอคอล';

  @override
  String get inputMessage => 'ข้อความ...';

  @override
  String get inputAttachFile => 'แนบไฟล์';

  @override
  String get inputSendMessage => 'ส่งข้อความ';

  @override
  String get inputRecordVoice => 'บันทึกข้อความเสียง';

  @override
  String get inputSendVoice => 'ส่งข้อความเสียง';

  @override
  String get inputCancelReply => 'ยกเลิกการตอบกลับ';

  @override
  String get inputCancelEdit => 'ยกเลิกการแก้ไข';

  @override
  String get inputCancelRecording => 'ยกเลิกการบันทึก';

  @override
  String get inputRecording => 'กำลังบันทึก…';

  @override
  String get inputEditingMessage => 'กำลังแก้ไขข้อความ';

  @override
  String get inputPhoto => 'รูปภาพ';

  @override
  String get inputVoiceMessage => 'ข้อความเสียง';

  @override
  String get inputFile => 'ไฟล์';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count ข้อความตั้งเวลา$_temp0';
  }

  @override
  String get callInitializing => 'กำลังเริ่มต้นการโทร…';

  @override
  String get callConnecting => 'กำลังเชื่อมต่อ…';

  @override
  String get callConnectingRelay => 'กำลังเชื่อมต่อ (รีเลย์)…';

  @override
  String get callSwitchingRelay => 'กำลังเปลี่ยนเป็นโหมดรีเลย์…';

  @override
  String get callConnectionFailed => 'การเชื่อมต่อล้มเหลว';

  @override
  String get callReconnecting => 'กำลังเชื่อมต่อใหม่…';

  @override
  String get callEnded => 'สิ้นสุดการโทร';

  @override
  String get callLive => 'ถ่ายทอดสด';

  @override
  String get callEnd => 'จบ';

  @override
  String get callEndCall => 'วางสาย';

  @override
  String get callMute => 'ปิดเสียง';

  @override
  String get callUnmute => 'เปิดเสียง';

  @override
  String get callSpeaker => 'ลำโพง';

  @override
  String get callCameraOn => 'เปิดกล้อง';

  @override
  String get callCameraOff => 'ปิดกล้อง';

  @override
  String get callShareScreen => 'แชร์หน้าจอ';

  @override
  String get callStopShare => 'หยุดแชร์';

  @override
  String callTorBackup(String duration) {
    return 'Tor สำรอง · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor สำรองทำงานอยู่ — เส้นทางหลักใช้งานไม่ได้';

  @override
  String get callDirectFailed =>
      'การเชื่อมต่อโดยตรงล้มเหลว — กำลังเปลี่ยนเป็นโหมดรีเลย์…';

  @override
  String get callTurnUnreachable =>
      'เข้าถึง TURN เซิร์ฟเวอร์ไม่ได้ เพิ่ม TURN เองในการตั้งค่า → ขั้นสูง';

  @override
  String get callRelayMode => 'โหมดรีเลย์ทำงานอยู่ (เครือข่ายจำกัด)';

  @override
  String get callStarting => 'กำลังเริ่มการโทร…';

  @override
  String get callConnectingToGroup => 'กำลังเชื่อมต่อกับกลุ่ม…';

  @override
  String get callGroupOpenedInBrowser => 'เปิดการโทรกลุ่มในเบราว์เซอร์แล้ว';

  @override
  String get callCouldNotOpenBrowser => 'ไม่สามารถเปิดเบราว์เซอร์ได้';

  @override
  String get callInviteLinkSent => 'ส่งลิงก์เชิญไปยังสมาชิกกลุ่มทั้งหมดแล้ว';

  @override
  String get callOpenLinkManually =>
      'เปิดลิงก์ด้านบนด้วยตนเองหรือแตะเพื่อลองใหม่';

  @override
  String get callJitsiNotE2ee =>
      'การโทร Jitsi ไม่ได้เข้ารหัสแบบต้นทางถึงปลายทาง';

  @override
  String get callRetryOpenBrowser => 'ลองเปิดเบราว์เซอร์ใหม่';

  @override
  String get callClose => 'ปิด';

  @override
  String get callCamOn => 'เปิดกล้อง';

  @override
  String get callCamOff => 'ปิดกล้อง';

  @override
  String get noConnection => 'ไม่มีการเชื่อมต่อ — ข้อความจะเข้าคิว';

  @override
  String get connected => 'เชื่อมต่อแล้ว';

  @override
  String get connecting => 'กำลังเชื่อมต่อ…';

  @override
  String get disconnected => 'ขาดการเชื่อมต่อ';

  @override
  String get offlineBanner =>
      'ไม่มีการเชื่อมต่อ — ข้อความจะเข้าคิวและส่งเมื่อกลับมาออนไลน์';

  @override
  String get lanModeBanner =>
      'โหมด LAN — ไม่มีอินเทอร์เน็ต · เครือข่ายท้องถิ่นเท่านั้น';

  @override
  String get probeCheckingNetwork => 'กำลังตรวจสอบการเชื่อมต่อเครือข่าย…';

  @override
  String get probeDiscoveringRelays => 'กำลังค้นหารีเลย์ผ่านไดเรกทอรีชุมชน…';

  @override
  String get probeStartingTor => 'กำลังเริ่ม Tor สำหรับ bootstrap…';

  @override
  String get probeFindingRelaysTor => 'กำลังค้นหารีเลย์ที่เข้าถึงได้ผ่าน Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'เครือข่ายพร้อม — พบ $count รีเลย์$_temp0';
  }

  @override
  String get probeNoRelaysFound =>
      'ไม่พบรีเลย์ที่เข้าถึงได้ — ข้อความอาจล่าช้า';

  @override
  String get jitsiWarningTitle => 'ไม่ได้เข้ารหัสแบบต้นทางถึงปลายทาง';

  @override
  String get jitsiWarningBody =>
      'การโทร Jitsi Meet ไม่ได้เข้ารหัสโดย Pulse ใช้สำหรับการสนทนาที่ไม่อ่อนไหวเท่านั้น';

  @override
  String get jitsiConfirm => 'เข้าร่วมต่อไป';

  @override
  String get jitsiGroupWarningTitle => 'ไม่ได้เข้ารหัสแบบต้นทางถึงปลายทาง';

  @override
  String get jitsiGroupWarningBody =>
      'การโทรนี้มีผู้เข้าร่วมมากเกินไปสำหรับ mesh เข้ารหัสในตัว\n\nลิงก์ Jitsi Meet จะถูกเปิดในเบราว์เซอร์ของคุณ Jitsi ไม่ได้เข้ารหัสแบบต้นทางถึงปลายทาง — เซิร์ฟเวอร์สามารถเห็นการโทรของคุณ';

  @override
  String get jitsiContinueAnyway => 'ดำเนินการต่อ';

  @override
  String get retry => 'ลองใหม่';

  @override
  String get setupCreateAnonymousAccount => 'สร้างบัญชีนิรนาม';

  @override
  String get setupTapToChangeColor => 'แตะเพื่อเปลี่ยนสี';

  @override
  String get setupReqMinLength => 'อย่างน้อย 16 ตัวอักษร';

  @override
  String get setupReqVariety => '3 ใน 4: ตัวพิมพ์ใหญ่ เล็ก ตัวเลข สัญลักษณ์';

  @override
  String get setupReqMatch => 'รหัสผ่านตรงกัน';

  @override
  String get setupYourNickname => 'ชื่อเล่นของคุณ';

  @override
  String get setupRecoveryPassword => 'รหัสผ่านกู้คืน (อย่างน้อย 16)';

  @override
  String get setupConfirmPassword => 'ยืนยันรหัสผ่าน';

  @override
  String get setupMin16Chars => 'อย่างน้อย 16 ตัวอักษร';

  @override
  String get setupPasswordsDoNotMatch => 'รหัสผ่านไม่ตรงกัน';

  @override
  String get setupEntropyWeak => 'อ่อน';

  @override
  String get setupEntropyOk => 'พอใช้';

  @override
  String get setupEntropyStrong => 'แข็งแกร่ง';

  @override
  String get setupEntropyWeakNeedsVariety => 'อ่อน (ต้องมีอักขระ 3 ประเภท)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits บิต)';
  }

  @override
  String get setupPasswordWarning =>
      'รหัสผ่านนี้เป็นทางเดียวในการกู้คืนบัญชีของคุณ ไม่มีเซิร์ฟเวอร์ — ไม่สามารถรีเซ็ตรหัสผ่านได้ จำไว้หรือจดไว้';

  @override
  String get setupCreateAccount => 'สร้างบัญชี';

  @override
  String get setupAlreadyHaveAccount => 'มีบัญชีอยู่แล้ว? ';

  @override
  String get setupRestore => 'กู้คืน →';

  @override
  String get restoreTitle => 'กู้คืนบัญชี';

  @override
  String get restoreInfoBanner =>
      'ป้อนรหัสผ่านกู้คืนของคุณ — ที่อยู่ของคุณ (Nostr + Session) จะถูกกู้คืนโดยอัตโนมัติ ผู้ติดต่อและข้อความถูกจัดเก็บไว้ในเครื่องเท่านั้น';

  @override
  String get restoreNewNickname => 'ชื่อเล่นใหม่ (เปลี่ยนภายหลังได้)';

  @override
  String get restoreButton => 'กู้คืนบัญชี';

  @override
  String get lockTitle => 'Pulse ถูกล็อค';

  @override
  String get lockSubtitle => 'ป้อนรหัสผ่านเพื่อดำเนินการต่อ';

  @override
  String get lockPasswordHint => 'รหัสผ่าน';

  @override
  String get lockUnlock => 'ปลดล็อค';

  @override
  String get lockPanicHint =>
      'ลืมรหัสผ่าน? ป้อนคีย์ฉุกเฉินเพื่อลบข้อมูลทั้งหมด';

  @override
  String get lockTooManyAttempts => 'ลองมากเกินไป กำลังลบข้อมูลทั้งหมด…';

  @override
  String get lockWrongPassword => 'รหัสผ่านผิด';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'รหัสผ่านผิด — $attempts/$max ครั้ง';
  }

  @override
  String get onboardingSkip => 'ข้าม';

  @override
  String get onboardingNext => 'ถัดไป';

  @override
  String get onboardingGetStarted => 'สร้างบัญชี';

  @override
  String get onboardingWelcomeTitle => 'ยินดีต้อนรับสู่ Pulse';

  @override
  String get onboardingWelcomeBody =>
      'แอปแชทเข้ารหัสแบบต้นทางถึงปลายทางแบบกระจายศูนย์\n\nไม่มีเซิร์ฟเวอร์กลาง ไม่มีการเก็บข้อมูล ไม่มีแบ็คดอร์\nการสนทนาของคุณเป็นของคุณเท่านั้น';

  @override
  String get onboardingTransportTitle => 'ไม่ผูกกับช่องทางส่ง';

  @override
  String get onboardingTransportBody =>
      'ใช้ Firebase, Nostr หรือทั้งสองอย่างพร้อมกัน\n\nข้อความถูกส่งผ่านเครือข่ายต่างๆ โดยอัตโนมัติ รองรับ Tor และ I2P ในตัวสำหรับการต่อต้านการเซ็นเซอร์';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'ทุกข้อความถูกเข้ารหัสด้วย Signal Protocol (Double Ratchet + X3DH) เพื่อ forward secrecy\n\nเสริมด้วย Kyber-1024 — อัลกอริทึม post-quantum มาตรฐาน NIST — ป้องกันคอมพิวเตอร์ควอนตัมในอนาคต';

  @override
  String get onboardingKeysTitle => 'คุณเป็นเจ้าของคีย์ของคุณ';

  @override
  String get onboardingKeysBody =>
      'คีย์ระบุตัวตนของคุณไม่เคยออกจากอุปกรณ์\n\nลายนิ้วมือ Signal ช่วยให้คุณยืนยันผู้ติดต่อแบบ out-of-band TOFU (Trust On First Use) ตรวจจับการเปลี่ยนแปลงคีย์โดยอัตโนมัติ';

  @override
  String get onboardingThemeTitle => 'เลือกรูปลักษณ์ของคุณ';

  @override
  String get onboardingThemeBody =>
      'เลือกธีมและสีเน้น คุณสามารถเปลี่ยนได้ทุกเมื่อในการตั้งค่า';

  @override
  String get contactsNewChat => 'แชทใหม่';

  @override
  String get contactsAddContact => 'เพิ่มผู้ติดต่อ';

  @override
  String get contactsSearchHint => 'ค้นหา...';

  @override
  String get contactsNewGroup => 'กลุ่มใหม่';

  @override
  String get contactsNoContactsYet => 'ยังไม่มีผู้ติดต่อ';

  @override
  String get contactsAddHint => 'แตะ + เพื่อเพิ่มที่อยู่ของใครสักคน';

  @override
  String get contactsNoMatch => 'ไม่มีผู้ติดต่อที่ตรงกัน';

  @override
  String get contactsRemoveTitle => 'ลบผู้ติดต่อ';

  @override
  String contactsRemoveMessage(String name) {
    return 'ลบ $name หรือไม่?';
  }

  @override
  String get contactsRemove => 'ลบออก';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count ผู้ติดต่อ$_temp0';
  }

  @override
  String get bubbleOpenLink => 'เปิดลิงก์';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'เปิด URL นี้ในเบราว์เซอร์หรือไม่?\n\n$url';
  }

  @override
  String get bubbleOpen => 'เปิด';

  @override
  String get bubbleSecurityWarning => 'คำเตือนด้านความปลอดภัย';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" เป็นไฟล์ที่สามารถเรียกใช้ได้ การบันทึกและเรียกใช้อาจเป็นอันตรายต่ออุปกรณ์ของคุณ บันทึกต่อไปหรือไม่?';
  }

  @override
  String get bubbleSaveAnyway => 'บันทึกต่อไป';

  @override
  String bubbleSavedTo(String path) {
    return 'บันทึกไปยัง $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'บันทึกล้มเหลว: $error';
  }

  @override
  String get bubbleNotEncrypted => 'ไม่ได้เข้ารหัส';

  @override
  String get bubbleCorruptedImage => '[รูปภาพเสียหาย]';

  @override
  String get bubbleReplyPhoto => 'รูปภาพ';

  @override
  String get bubbleReplyVoice => 'ข้อความเสียง';

  @override
  String get bubbleReplyVideo => 'ข้อความวิดีโอ';

  @override
  String bubbleReadBy(String names) {
    return 'อ่านโดย $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'อ่านโดย $count คน';
  }

  @override
  String get chatTileTapToStart => 'แตะเพื่อเริ่มแชท';

  @override
  String get chatTileMessageSent => 'ส่งข้อความแล้ว';

  @override
  String get chatTileEncryptedMessage => 'ข้อความเข้ารหัส';

  @override
  String chatTileYouPrefix(String text) {
    return 'คุณ: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 ข้อความเสียง';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 ข้อความเสียง ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'ข้อความเข้ารหัส';

  @override
  String get groupNewGroup => 'กลุ่มใหม่';

  @override
  String get groupGroupName => 'ชื่อกลุ่ม';

  @override
  String get groupSelectMembers => 'เลือกสมาชิก (อย่างน้อย 2)';

  @override
  String get groupNoContactsYet => 'ยังไม่มีผู้ติดต่อ เพิ่มผู้ติดต่อก่อน';

  @override
  String get groupCreate => 'สร้าง';

  @override
  String get groupLabel => 'กลุ่ม';

  @override
  String get profileVerifyIdentity => 'ยืนยันตัวตน';

  @override
  String profileVerifyInstructions(String name) {
    return 'เปรียบเทียบลายนิ้วมือเหล่านี้กับ $name ผ่านการโทรด้วยเสียงหรือพบกันตัวต่อตัว หากค่าทั้งสองตรงกันบนทั้งสองอุปกรณ์ ให้แตะ \"ทำเครื่องหมายว่ายืนยันแล้ว\"';
  }

  @override
  String get profileTheirKey => 'คีย์ของพวกเขา';

  @override
  String get profileYourKey => 'คีย์ของคุณ';

  @override
  String get profileRemoveVerification => 'ลบการยืนยัน';

  @override
  String get profileMarkAsVerified => 'ทำเครื่องหมายว่ายืนยันแล้ว';

  @override
  String get profileAddressCopied => 'คัดลอกที่อยู่แล้ว';

  @override
  String get profileNoContactsToAdd =>
      'ไม่มีผู้ติดต่อให้เพิ่ม — ทั้งหมดเป็นสมาชิกอยู่แล้ว';

  @override
  String get profileAddMembers => 'เพิ่มสมาชิก';

  @override
  String profileAddCount(int count) {
    return 'เพิ่ม ($count)';
  }

  @override
  String get profileRenameGroup => 'เปลี่ยนชื่อกลุ่ม';

  @override
  String get profileRename => 'เปลี่ยนชื่อ';

  @override
  String get profileRemoveMember => 'ลบสมาชิก?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'ลบ $name ออกจากกลุ่มนี้?';
  }

  @override
  String get profileKick => 'เตะออก';

  @override
  String get profileSignalFingerprints => 'ลายนิ้วมือ Signal';

  @override
  String get profileVerified => 'ยืนยันแล้ว';

  @override
  String get profileVerify => 'ยืนยัน';

  @override
  String get profileEdit => 'แก้ไข';

  @override
  String get profileNoSession => 'ยังไม่มีเซสชัน — ส่งข้อความก่อน';

  @override
  String get profileFingerprintCopied => 'คัดลอกลายนิ้วมือแล้ว';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count สมาชิก$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'ยืนยันหมายเลขความปลอดภัย';

  @override
  String get profileShowContactQr => 'แสดง QR ผู้ติดต่อ';

  @override
  String profileContactAddress(String name) {
    return 'ที่อยู่ของ $name';
  }

  @override
  String get profileExportChatHistory => 'ส่งออกประวัติแชท';

  @override
  String profileSavedTo(String path) {
    return 'บันทึกไปยัง $path';
  }

  @override
  String get profileExportFailed => 'ส่งออกล้มเหลว';

  @override
  String get profileClearChatHistory => 'ล้างประวัติแชท';

  @override
  String get profileDeleteGroup => 'ลบกลุ่ม';

  @override
  String get profileDeleteContact => 'ลบผู้ติดต่อ';

  @override
  String get profileLeaveGroup => 'ออกจากกลุ่ม';

  @override
  String get profileLeaveGroupBody =>
      'คุณจะถูกลบออกจากกลุ่มนี้และจะถูกลบออกจากรายชื่อผู้ติดต่อของคุณ';

  @override
  String get groupInviteTitle => 'คำเชิญเข้ากลุ่ม';

  @override
  String groupInviteBody(String from, String group) {
    return '$from เชิญคุณเข้าร่วม \"$group\"';
  }

  @override
  String get groupInviteAccept => 'ยอมรับ';

  @override
  String get groupInviteDecline => 'ปฏิเสธ';

  @override
  String get groupMemberLimitTitle => 'ผู้เข้าร่วมมากเกินไป';

  @override
  String groupMemberLimitBody(int count) {
    return 'กลุ่มนี้จะมีผู้เข้าร่วม $count คน การโทรแบบ mesh เข้ารหัสรองรับสูงสุด 6 คน กลุ่มที่ใหญ่กว่าจะใช้ Jitsi (ไม่ใช่ E2EE)';
  }

  @override
  String get groupMemberLimitContinue => 'เพิ่มต่อไป';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name ปฏิเสธที่จะเข้าร่วม \"$group\"';
  }

  @override
  String get transferTitle => 'โอนไปยังอุปกรณ์อื่น';

  @override
  String get transferInfoBox =>
      'ย้ายข้อมูลตัวตน Signal และคีย์ Nostr ไปยังอุปกรณ์ใหม่\nเซสชันแชทจะไม่ถูกโอน — forward secrecy จะถูกรักษาไว้';

  @override
  String get transferSendFromThis => 'ส่งจากอุปกรณ์นี้';

  @override
  String get transferSendSubtitle => 'อุปกรณ์นี้มีคีย์ แชร์รหัสกับอุปกรณ์ใหม่';

  @override
  String get transferReceiveOnThis => 'รับบนอุปกรณ์นี้';

  @override
  String get transferReceiveSubtitle =>
      'นี่คืออุปกรณ์ใหม่ ป้อนรหัสจากอุปกรณ์เก่า';

  @override
  String get transferChooseMethod => 'เลือกวิธีการโอน';

  @override
  String get transferLan => 'LAN (เครือข่ายเดียวกัน)';

  @override
  String get transferLanSubtitle =>
      'เร็วและตรง อุปกรณ์ทั้งสองต้องอยู่บน Wi-Fi เดียวกัน';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'ใช้ได้ผ่านเครือข่ายใดก็ได้โดยใช้ Nostr relay ที่มีอยู่';

  @override
  String get transferRelayUrl => 'URL ของ Relay';

  @override
  String get transferEnterCode => 'ป้อนรหัสการโอน';

  @override
  String get transferPasteCode => 'วางรหัส LAN:... หรือ NOS:... ที่นี่';

  @override
  String get transferConnect => 'เชื่อมต่อ';

  @override
  String get transferGenerating => 'กำลังสร้างรหัสการโอน…';

  @override
  String get transferShareCode => 'แชร์รหัสนี้กับผู้รับ:';

  @override
  String get transferCopyCode => 'คัดลอกรหัส';

  @override
  String get transferCodeCopied => 'คัดลอกรหัสไปยังคลิปบอร์ดแล้ว';

  @override
  String get transferWaitingReceiver => 'กำลังรอผู้รับเชื่อมต่อ…';

  @override
  String get transferConnectingSender => 'กำลังเชื่อมต่อกับผู้ส่ง…';

  @override
  String get transferVerifyBoth =>
      'เปรียบเทียบรหัสนี้บนอุปกรณ์ทั้งสอง\nหากตรงกัน การโอนจะปลอดภัย';

  @override
  String get transferComplete => 'โอนเสร็จสมบูรณ์';

  @override
  String get transferKeysImported => 'นำเข้าคีย์แล้ว';

  @override
  String get transferCompleteSenderBody =>
      'คีย์ของคุณยังคงใช้งานได้บนอุปกรณ์นี้\nผู้รับสามารถใช้ตัวตนของคุณได้แล้ว';

  @override
  String get transferCompleteReceiverBody =>
      'นำเข้าคีย์สำเร็จ\nรีสตาร์ทแอปเพื่อใช้ตัวตนใหม่';

  @override
  String get transferRestartApp => 'รีสตาร์ทแอป';

  @override
  String get transferFailed => 'การโอนล้มเหลว';

  @override
  String get transferTryAgain => 'ลองใหม่';

  @override
  String get transferEnterRelayFirst => 'ป้อน URL ของ relay ก่อน';

  @override
  String get transferPasteCodeFromSender => 'วางรหัสการโอนจากผู้ส่ง';

  @override
  String get menuReply => 'ตอบกลับ';

  @override
  String get menuForward => 'ส่งต่อ';

  @override
  String get menuReact => 'รีแอค';

  @override
  String get menuCopy => 'คัดลอก';

  @override
  String get menuEdit => 'แก้ไข';

  @override
  String get menuRetry => 'ลองใหม่';

  @override
  String get menuCancelScheduled => 'ยกเลิกการตั้งเวลา';

  @override
  String get menuDelete => 'ลบ';

  @override
  String get menuForwardTo => 'ส่งต่อไปยัง…';

  @override
  String menuForwardedTo(String name) {
    return 'ส่งต่อไปยัง $name';
  }

  @override
  String get menuScheduledMessages => 'ข้อความตั้งเวลา';

  @override
  String get menuNoScheduledMessages => 'ไม่มีข้อความตั้งเวลา';

  @override
  String menuSendsOn(String date) {
    return 'ส่งเมื่อ $date';
  }

  @override
  String get menuDisappearingMessages => 'ข้อความที่หายไป';

  @override
  String get menuDisappearingSubtitle =>
      'ข้อความจะถูกลบโดยอัตโนมัติหลังจากเวลาที่เลือก';

  @override
  String get menuTtlOff => 'ปิด';

  @override
  String get menuTtl1h => '1 ชั่วโมง';

  @override
  String get menuTtl24h => '24 ชั่วโมง';

  @override
  String get menuTtl7d => '7 วัน';

  @override
  String get menuAttachPhoto => 'รูปภาพ';

  @override
  String get menuAttachFile => 'ไฟล์';

  @override
  String get menuAttachVideo => 'วิดีโอ';

  @override
  String get mediaTitle => 'สื่อ';

  @override
  String get mediaFileLabel => 'ไฟล์';

  @override
  String mediaPhotosTab(int count) {
    return 'รูปภาพ ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'ไฟล์ ($count)';
  }

  @override
  String get mediaNoPhotos => 'ยังไม่มีรูปภาพ';

  @override
  String get mediaNoFiles => 'ยังไม่มีไฟล์';

  @override
  String mediaSavedToDownloads(String name) {
    return 'บันทึกไปยัง Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'ไม่สามารถบันทึกไฟล์ได้';

  @override
  String get statusNewStatus => 'สถานะใหม่';

  @override
  String get statusPublish => 'เผยแพร่';

  @override
  String get statusExpiresIn24h => 'สถานะหมดอายุใน 24 ชั่วโมง';

  @override
  String get statusWhatsOnYourMind => 'คุณกำลังคิดอะไรอยู่?';

  @override
  String get statusPhotoAttached => 'แนบรูปภาพแล้ว';

  @override
  String get statusAttachPhoto => 'แนบรูปภาพ (ไม่บังคับ)';

  @override
  String get statusEnterText => 'กรุณาป้อนข้อความสำหรับสถานะของคุณ';

  @override
  String statusPickPhotoFailed(String error) {
    return 'ไม่สามารถเลือกรูปภาพได้: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'เผยแพร่ล้มเหลว: $error';
  }

  @override
  String get panicSetPanicKey => 'ตั้งคีย์ฉุกเฉิน';

  @override
  String get panicEmergencySelfDestruct => 'ทำลายตัวเองฉุกเฉิน';

  @override
  String get panicIrreversible => 'การกระทำนี้ไม่สามารถย้อนกลับได้';

  @override
  String get panicWarningBody =>
      'การป้อนคีย์นี้ที่หน้าจอล็อคจะลบข้อมูลทั้งหมดทันที — ข้อความ ผู้ติดต่อ คีย์ ตัวตน ใช้คีย์ที่แตกต่างจากรหัสผ่านปกติของคุณ';

  @override
  String get panicKeyHint => 'คีย์ฉุกเฉิน';

  @override
  String get panicConfirmHint => 'ยืนยันคีย์ฉุกเฉิน';

  @override
  String get panicMinChars => 'คีย์ฉุกเฉินต้องมีอย่างน้อย 8 ตัวอักษร';

  @override
  String get panicKeysDoNotMatch => 'คีย์ไม่ตรงกัน';

  @override
  String get panicSetFailed => 'ไม่สามารถบันทึกคีย์ฉุกเฉินได้ — กรุณาลองใหม่';

  @override
  String get passwordSetAppPassword => 'ตั้งรหัสผ่านแอป';

  @override
  String get passwordProtectsMessages => 'ปกป้องข้อความของคุณขณะพักเครื่อง';

  @override
  String get passwordInfoBanner =>
      'ต้องใช้ทุกครั้งที่เปิด Pulse หากลืม ข้อมูลจะไม่สามารถกู้คืนได้';

  @override
  String get passwordHint => 'รหัสผ่าน';

  @override
  String get passwordConfirmHint => 'ยืนยันรหัสผ่าน';

  @override
  String get passwordSetButton => 'ตั้งรหัสผ่าน';

  @override
  String get passwordSkipForNow => 'ข้ามไปก่อน';

  @override
  String get passwordMinChars => 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';

  @override
  String get passwordNeedsVariety => 'ต้องมีตัวอักษร ตัวเลข และอักขระพิเศษ';

  @override
  String get passwordRequirements =>
      'ขั้นต่ำ 8 ตัวอักษร มีตัวอักษร ตัวเลข และอักขระพิเศษ';

  @override
  String get passwordsDoNotMatch => 'รหัสผ่านไม่ตรงกัน';

  @override
  String get profileCardSaved => 'บันทึกโปรไฟล์แล้ว!';

  @override
  String get profileCardE2eeIdentity => 'ตัวตน E2EE';

  @override
  String get profileCardDisplayName => 'ชื่อที่แสดง';

  @override
  String get profileCardDisplayNameHint => 'เช่น สมชาย ใจดี';

  @override
  String get profileCardAbout => 'เกี่ยวกับ';

  @override
  String get profileCardSaveProfile => 'บันทึกโปรไฟล์';

  @override
  String get profileCardYourName => 'ชื่อของคุณ';

  @override
  String get profileCardAddressCopied => 'คัดลอกที่อยู่แล้ว!';

  @override
  String get profileCardInboxAddress => 'ที่อยู่กล่องข้อความของคุณ';

  @override
  String get profileCardInboxAddresses => 'ที่อยู่กล่องข้อความของคุณ';

  @override
  String get profileCardShareAllAddresses => 'แชร์ที่อยู่ทั้งหมด (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'แชร์กับผู้ติดต่อเพื่อให้พวกเขาส่งข้อความถึงคุณได้';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'คัดลอกที่อยู่ทั้ง $count รายการเป็นลิงก์เดียวแล้ว!';
  }

  @override
  String get settingsMyProfile => 'โปรไฟล์ของฉัน';

  @override
  String get settingsYourInboxAddress => 'ที่อยู่กล่องข้อความของคุณ';

  @override
  String get settingsMyQrCode => 'แชร์ผู้ติดต่อ';

  @override
  String get settingsMyQrSubtitle => 'QR Code และลิงก์เชิญสำหรับที่อยู่ของคุณ';

  @override
  String get settingsShareMyAddress => 'แชร์ที่อยู่ของฉัน';

  @override
  String get settingsNoAddressYet => 'ยังไม่มีที่อยู่ — บันทึกการตั้งค่าก่อน';

  @override
  String get settingsInviteLink => 'ลิงก์เชิญ';

  @override
  String get settingsRawAddress => 'ที่อยู่ดิบ';

  @override
  String get settingsCopyLink => 'คัดลอกลิงก์';

  @override
  String get settingsCopyAddress => 'คัดลอกที่อยู่';

  @override
  String get settingsInviteLinkCopied => 'คัดลอกลิงก์เชิญแล้ว';

  @override
  String get settingsAppearance => 'รูปลักษณ์';

  @override
  String get settingsThemeEngine => 'เอ็นจินธีม';

  @override
  String get settingsThemeEngineSubtitle => 'ปรับแต่งสีและฟอนต์';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle =>
      'คีย์ E2EE ถูกจัดเก็บอย่างปลอดภัย';

  @override
  String get settingsActive => 'ใช้งานอยู่';

  @override
  String get settingsIdentityBackup => 'สำรองข้อมูลตัวตน';

  @override
  String get settingsIdentityBackupSubtitle => 'ส่งออกหรือนำเข้าตัวตน Signal';

  @override
  String get settingsIdentityBackupBody =>
      'ส่งออกคีย์ตัวตน Signal ไปยังรหัสสำรอง หรือกู้คืนจากรหัสที่มีอยู่';

  @override
  String get settingsTransferDevice => 'โอนไปยังอุปกรณ์อื่น';

  @override
  String get settingsTransferDeviceSubtitle =>
      'ย้ายตัวตนผ่าน LAN หรือ Nostr relay';

  @override
  String get settingsExportIdentity => 'ส่งออกตัวตน';

  @override
  String get settingsExportIdentityBody =>
      'คัดลอกรหัสสำรองนี้และเก็บไว้อย่างปลอดภัย:';

  @override
  String get settingsSaveFile => 'บันทึกไฟล์';

  @override
  String get settingsImportIdentity => 'นำเข้าตัวตน';

  @override
  String get settingsImportIdentityBody =>
      'วางรหัสสำรองด้านล่าง ข้อมูลนี้จะเขียนทับตัวตนปัจจุบันของคุณ';

  @override
  String get settingsPasteBackupCode => 'วางรหัสสำรองที่นี่…';

  @override
  String get settingsIdentityImported =>
      'นำเข้าตัวตน + ผู้ติดต่อแล้ว! รีสตาร์ทแอปเพื่อใช้งาน';

  @override
  String get settingsSecurity => 'ความปลอดภัย';

  @override
  String get settingsAppPassword => 'รหัสผ่านแอป';

  @override
  String get settingsPasswordEnabled =>
      'เปิดใช้งาน — ต้องใช้ทุกครั้งที่เปิดแอป';

  @override
  String get settingsPasswordDisabled =>
      'ปิดใช้งาน — เปิดแอปโดยไม่ต้องใช้รหัสผ่าน';

  @override
  String get settingsChangePassword => 'เปลี่ยนรหัสผ่าน';

  @override
  String get settingsChangePasswordSubtitle => 'อัปเดตรหัสผ่านล็อคแอป';

  @override
  String get settingsSetPanicKey => 'ตั้งคีย์ฉุกเฉิน';

  @override
  String get settingsChangePanicKey => 'เปลี่ยนคีย์ฉุกเฉิน';

  @override
  String get settingsPanicKeySetSubtitle => 'อัปเดตคีย์ลบข้อมูลฉุกเฉิน';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'คีย์เดียวที่ลบข้อมูลทั้งหมดทันที';

  @override
  String get settingsRemovePanicKey => 'ลบคีย์ฉุกเฉิน';

  @override
  String get settingsRemovePanicKeySubtitle => 'ปิดการทำลายตัวเองฉุกเฉิน';

  @override
  String get settingsRemovePanicKeyBody =>
      'การทำลายตัวเองฉุกเฉินจะถูกปิดใช้งาน คุณสามารถเปิดใช้งานใหม่ได้ทุกเมื่อ';

  @override
  String get settingsDisableAppPassword => 'ปิดรหัสผ่านแอป';

  @override
  String get settingsEnterCurrentPassword => 'ป้อนรหัสผ่านปัจจุบันเพื่อยืนยัน';

  @override
  String get settingsCurrentPassword => 'รหัสผ่านปัจจุบัน';

  @override
  String get settingsIncorrectPassword => 'รหัสผ่านไม่ถูกต้อง';

  @override
  String get settingsPasswordUpdated => 'อัปเดตรหัสผ่านแล้ว';

  @override
  String get settingsChangePasswordProceed =>
      'ป้อนรหัสผ่านปัจจุบันเพื่อดำเนินการต่อ';

  @override
  String get settingsData => 'ข้อมูล';

  @override
  String get settingsBackupMessages => 'สำรองข้อความ';

  @override
  String get settingsBackupMessagesSubtitle =>
      'ส่งออกประวัติข้อความเข้ารหัสเป็นไฟล์';

  @override
  String get settingsRestoreMessages => 'กู้คืนข้อความ';

  @override
  String get settingsRestoreMessagesSubtitle => 'นำเข้าข้อความจากไฟล์สำรอง';

  @override
  String get settingsExportKeys => 'ส่งออกคีย์';

  @override
  String get settingsExportKeysSubtitle => 'บันทึกคีย์ตัวตนเป็นไฟล์เข้ารหัส';

  @override
  String get settingsImportKeys => 'นำเข้าคีย์';

  @override
  String get settingsImportKeysSubtitle => 'กู้คืนคีย์ตัวตนจากไฟล์ที่ส่งออก';

  @override
  String get settingsBackupPassword => 'รหัสผ่านสำรอง';

  @override
  String get settingsPasswordCannotBeEmpty => 'รหัสผ่านต้องไม่เว้นว่าง';

  @override
  String get settingsPasswordMin4Chars => 'รหัสผ่านต้องมีอย่างน้อย 4 ตัวอักษร';

  @override
  String get settingsCallsTurn => 'การโทร & TURN';

  @override
  String get settingsLocalNetwork => 'เครือข่ายท้องถิ่น';

  @override
  String get settingsCensorshipResistance => 'การต่อต้านการเซ็นเซอร์';

  @override
  String get settingsNetwork => 'เครือข่าย';

  @override
  String get settingsProxyTunnels => 'พร็อกซี & อุโมงค์';

  @override
  String get settingsTurnServers => 'เซิร์ฟเวอร์ TURN';

  @override
  String get settingsProviderTitle => 'ผู้ให้บริการ';

  @override
  String get settingsLanFallback => 'LAN สำรอง';

  @override
  String get settingsLanFallbackSubtitle =>
      'ส่งข้อมูลการออนไลน์และส่งข้อความผ่านเครือข่ายท้องถิ่นเมื่อไม่มีอินเทอร์เน็ต ปิดในเครือข่ายที่ไม่น่าเชื่อถือ (Wi-Fi สาธารณะ)';

  @override
  String get settingsBgDelivery => 'ส่งข้อความในพื้นหลัง';

  @override
  String get settingsBgDeliverySubtitle =>
      'รับข้อความต่อเมื่อแอปถูกย่อ แสดงการแจ้งเตือนถาวร';

  @override
  String get settingsYourInboxProvider => 'ผู้ให้บริการกล่องข้อความ';

  @override
  String get settingsConnectionDetails => 'รายละเอียดการเชื่อมต่อ';

  @override
  String get settingsSaveAndConnect => 'บันทึก & เชื่อมต่อ';

  @override
  String get settingsSecondaryInboxes => 'กล่องข้อความรอง';

  @override
  String get settingsAddSecondaryInbox => 'เพิ่มกล่องข้อความรอง';

  @override
  String get settingsAdvanced => 'ขั้นสูง';

  @override
  String get settingsDiscover => 'ค้นพบ';

  @override
  String get settingsAbout => 'เกี่ยวกับ';

  @override
  String get settingsPrivacyPolicy => 'นโยบายความเป็นส่วนตัว';

  @override
  String get settingsPrivacyPolicySubtitle => 'Pulse ปกป้องข้อมูลของคุณอย่างไร';

  @override
  String get settingsCrashReporting => 'รายงานข้อขัดข้อง';

  @override
  String get settingsCrashReportingSubtitle =>
      'ส่งรายงานข้อขัดข้องที่ไม่ระบุตัวตนเพื่อช่วยปรับปรุง Pulse ไม่มีเนื้อหาข้อความหรือผู้ติดต่อถูกส่งไป';

  @override
  String get settingsCrashReportingEnabled =>
      'เปิดรายงานข้อขัดข้องแล้ว — รีสตาร์ทแอปเพื่อใช้งาน';

  @override
  String get settingsCrashReportingDisabled =>
      'ปิดรายงานข้อขัดข้องแล้ว — รีสตาร์ทแอปเพื่อใช้งาน';

  @override
  String get settingsSensitiveOperation => 'การดำเนินการที่ละเอียดอ่อน';

  @override
  String get settingsSensitiveOperationBody =>
      'คีย์เหล่านี้คือตัวตนของคุณ ใครก็ตามที่มีไฟล์นี้สามารถปลอมตัวเป็นคุณได้ จัดเก็บอย่างปลอดภัยและลบหลังจากโอนแล้ว';

  @override
  String get settingsIUnderstandContinue => 'ฉันเข้าใจ ดำเนินการต่อ';

  @override
  String get settingsReplaceIdentity => 'แทนที่ตัวตน?';

  @override
  String get settingsReplaceIdentityBody =>
      'ข้อมูลนี้จะเขียนทับคีย์ตัวตนปัจจุบันของคุณ เซสชัน Signal ที่มีอยู่จะใช้งานไม่ได้และผู้ติดต่อต้องสร้างการเข้ารหัสใหม่ แอปจะต้องรีสตาร์ท';

  @override
  String get settingsReplaceKeys => 'แทนที่คีย์';

  @override
  String get settingsKeysImported => 'นำเข้าคีย์แล้ว';

  @override
  String settingsKeysImportedBody(int count) {
    return 'นำเข้า $count คีย์สำเร็จ กรุณารีสตาร์ทแอปเพื่อเริ่มต้นด้วยตัวตนใหม่';
  }

  @override
  String get settingsRestartNow => 'รีสตาร์ทเดี๋ยวนี้';

  @override
  String get settingsLater => 'ภายหลัง';

  @override
  String get profileGroupLabel => 'กลุ่ม';

  @override
  String get profileAddButton => 'เพิ่ม';

  @override
  String get profileKickButton => 'เตะออก';

  @override
  String get dataSectionTitle => 'ข้อมูล';

  @override
  String get dataBackupMessages => 'สำรองข้อความ';

  @override
  String get dataBackupPasswordSubtitle =>
      'เลือกรหัสผ่านเพื่อเข้ารหัสข้อมูลสำรองของคุณ';

  @override
  String get dataBackupConfirmLabel => 'สร้างข้อมูลสำรอง';

  @override
  String get dataCreatingBackup => 'กำลังสร้างข้อมูลสำรอง';

  @override
  String get dataBackupPreparing => 'กำลังเตรียมการ...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'กำลังส่งออกข้อความ $done จาก $total...';
  }

  @override
  String get dataBackupSavingFile => 'กำลังบันทึกไฟล์...';

  @override
  String get dataSaveMessageBackupDialog => 'บันทึกข้อมูลสำรองข้อความ';

  @override
  String dataBackupSaved(int count, String path) {
    return 'บันทึกข้อมูลสำรองแล้ว ($count ข้อความ)\n$path';
  }

  @override
  String get dataBackupFailed => 'การสำรองข้อมูลล้มเหลว — ไม่มีข้อมูลถูกส่งออก';

  @override
  String dataBackupFailedError(String error) {
    return 'การสำรองข้อมูลล้มเหลว: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'เลือกข้อมูลสำรองข้อความ';

  @override
  String get dataInvalidBackupFile => 'ไฟล์สำรองไม่ถูกต้อง (ขนาดเล็กเกินไป)';

  @override
  String get dataNotValidBackupFile => 'ไม่ใช่ไฟล์สำรอง Pulse ที่ถูกต้อง';

  @override
  String get dataRestoreMessages => 'กู้คืนข้อความ';

  @override
  String get dataRestorePasswordSubtitle =>
      'ป้อนรหัสผ่านที่ใช้สร้างข้อมูลสำรองนี้';

  @override
  String get dataRestoreConfirmLabel => 'กู้คืน';

  @override
  String get dataRestoringMessages => 'กำลังกู้คืนข้อความ';

  @override
  String get dataRestoreDecrypting => 'กำลังถอดรหัส...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'กำลังนำเข้าข้อความ $done จาก $total...';
  }

  @override
  String get dataRestoreFailed =>
      'การกู้คืนล้มเหลว — รหัสผ่านผิดหรือไฟล์เสียหาย';

  @override
  String dataRestoreSuccess(int count) {
    return 'กู้คืน $count ข้อความใหม่แล้ว';
  }

  @override
  String get dataRestoreNothingNew =>
      'ไม่มีข้อความใหม่ให้นำเข้า (มีทั้งหมดอยู่แล้ว)';

  @override
  String dataRestoreFailedError(String error) {
    return 'การกู้คืนล้มเหลว: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'เลือกไฟล์ส่งออกคีย์';

  @override
  String get dataNotValidKeyFile => 'ไม่ใช่ไฟล์ส่งออกคีย์ Pulse ที่ถูกต้อง';

  @override
  String get dataExportKeys => 'ส่งออกคีย์';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'เลือกรหัสผ่านเพื่อเข้ารหัสไฟล์ส่งออกคีย์';

  @override
  String get dataExportKeysConfirmLabel => 'ส่งออก';

  @override
  String get dataExportingKeys => 'กำลังส่งออกคีย์';

  @override
  String get dataExportingKeysStatus => 'กำลังเข้ารหัสคีย์ตัวตน...';

  @override
  String get dataSaveKeyExportDialog => 'บันทึกไฟล์ส่งออกคีย์';

  @override
  String dataKeysExportedTo(String path) {
    return 'ส่งออกคีย์ไปยัง:\n$path';
  }

  @override
  String get dataExportFailed => 'การส่งออกล้มเหลว — ไม่พบคีย์';

  @override
  String dataExportFailedError(String error) {
    return 'การส่งออกล้มเหลว: $error';
  }

  @override
  String get dataImportKeys => 'นำเข้าคีย์';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'ป้อนรหัสผ่านที่ใช้เข้ารหัสไฟล์ส่งออกคีย์นี้';

  @override
  String get dataImportKeysConfirmLabel => 'นำเข้า';

  @override
  String get dataImportingKeys => 'กำลังนำเข้าคีย์';

  @override
  String get dataImportingKeysStatus => 'กำลังถอดรหัสคีย์ตัวตน...';

  @override
  String get dataImportFailed =>
      'การนำเข้าล้มเหลว — รหัสผ่านผิดหรือไฟล์เสียหาย';

  @override
  String dataImportFailedError(String error) {
    return 'การนำเข้าล้มเหลว: $error';
  }

  @override
  String get securitySectionTitle => 'ความปลอดภัย';

  @override
  String get securityIncorrectPassword => 'รหัสผ่านไม่ถูกต้อง';

  @override
  String get securityPasswordUpdated => 'อัปเดตรหัสผ่านแล้ว';

  @override
  String get appearanceSectionTitle => 'รูปลักษณ์';

  @override
  String appearanceExportFailed(String error) {
    return 'การส่งออกล้มเหลว: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'บันทึกไปยัง $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'การบันทึกล้มเหลว: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'การนำเข้าล้มเหลว: $error';
  }

  @override
  String get aboutSectionTitle => 'เกี่ยวกับ';

  @override
  String get providerPublicKey => 'คีย์สาธารณะ';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'กำหนดค่าอัตโนมัติจากรหัสผ่านกู้คืนของคุณ Relay ค้นพบอัตโนมัติ';

  @override
  String get providerKeyStoredLocally =>
      'คีย์ของคุณถูกจัดเก็บในเครื่องอย่างปลอดภัย — ไม่เคยถูกส่งไปยังเซิร์ฟเวอร์ใดๆ';

  @override
  String get providerSessionInfo =>
      'Session Network — E2EE แบบ onion routing รหัส Session ของคุณถูกสร้างโดยอัตโนมัติและเก็บไว้อย่างปลอดภัย โหนดถูกค้นพบโดยอัตโนมัติจาก seed nodes ที่ฝังไว้';

  @override
  String get providerAdvanced => 'ขั้นสูง';

  @override
  String get providerSaveAndConnect => 'บันทึก & เชื่อมต่อ';

  @override
  String get providerAddSecondaryInbox => 'เพิ่มกล่องข้อความรอง';

  @override
  String get providerSecondaryInboxes => 'กล่องข้อความรอง';

  @override
  String get providerYourInboxProvider => 'ผู้ให้บริการกล่องข้อความ';

  @override
  String get providerConnectionDetails => 'รายละเอียดการเชื่อมต่อ';

  @override
  String get addContactTitle => 'เพิ่มผู้ติดต่อ';

  @override
  String get addContactInviteLinkLabel => 'ลิงก์เชิญหรือที่อยู่';

  @override
  String get addContactTapToPaste => 'แตะเพื่อวางลิงก์เชิญ';

  @override
  String get addContactPasteTooltip => 'วางจากคลิปบอร์ด';

  @override
  String get addContactAddressDetected => 'ตรวจพบที่อยู่ผู้ติดต่อ';

  @override
  String addContactRoutesDetected(int count) {
    return 'ตรวจพบ $count เส้นทาง — SmartRouter เลือกเส้นทางเร็วที่สุด';
  }

  @override
  String get addContactFetchingProfile => 'กำลังดึงข้อมูลโปรไฟล์…';

  @override
  String addContactProfileFound(String name) {
    return 'พบ: $name';
  }

  @override
  String get addContactNoProfileFound => 'ไม่พบโปรไฟล์';

  @override
  String get addContactDisplayNameLabel => 'ชื่อที่แสดง';

  @override
  String get addContactDisplayNameHint => 'คุณต้องการเรียกพวกเขาว่าอะไร?';

  @override
  String get addContactAddManually => 'เพิ่มที่อยู่ด้วยตนเอง';

  @override
  String get addContactButton => 'เพิ่มผู้ติดต่อ';

  @override
  String get networkDiagnosticsTitle => 'การวินิจฉัยเครือข่าย';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr Relay';

  @override
  String get networkDiagnosticsDirect => 'ตรง';

  @override
  String get networkDiagnosticsTorOnly => 'Tor เท่านั้น';

  @override
  String get networkDiagnosticsBest => 'ดีที่สุด';

  @override
  String get networkDiagnosticsNone => 'ไม่มี';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'สถานะ';

  @override
  String get networkDiagnosticsConnected => 'เชื่อมต่อแล้ว';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'กำลังเชื่อมต่อ $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'ปิด';

  @override
  String get networkDiagnosticsTransport => 'ช่องทางส่ง';

  @override
  String get networkDiagnosticsInfrastructure => 'โครงสร้างพื้นฐาน';

  @override
  String get networkDiagnosticsSessionNodes => 'โหนด Session';

  @override
  String get networkDiagnosticsTurnServers => 'เซิร์ฟเวอร์ TURN';

  @override
  String get networkDiagnosticsLastProbe => 'การตรวจสอบล่าสุด';

  @override
  String get networkDiagnosticsRunning => 'กำลังทำงาน...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'เริ่มการวินิจฉัย';

  @override
  String get networkDiagnosticsForceReprobe => 'บังคับตรวจสอบใหม่ทั้งหมด';

  @override
  String get networkDiagnosticsJustNow => 'เมื่อสักครู่';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes นาทีที่แล้ว';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours ชั่วโมงที่แล้ว';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days วันที่แล้ว';
  }

  @override
  String get homeNoEch => 'ไม่มี ECH';

  @override
  String get homeNoEchTooltip =>
      'พร็อกซี uTLS ใช้งานไม่ได้ — ECH ปิดอยู่\nลายนิ้วมือ TLS มองเห็นได้โดย DPI';

  @override
  String get settingsTitle => 'การตั้งค่า';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'บันทึกแล้ว & เชื่อมต่อกับ $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Tor ในตัวเริ่มต้นไม่สำเร็จ';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon เริ่มต้นไม่สำเร็จ';

  @override
  String get verifyTitle => 'ยืนยันหมายเลขความปลอดภัย';

  @override
  String get verifyIdentityVerified => 'ยืนยันตัวตนแล้ว';

  @override
  String get verifyNotYetVerified => 'ยังไม่ได้ยืนยัน';

  @override
  String verifyVerifiedDescription(String name) {
    return 'คุณได้ยืนยันหมายเลขความปลอดภัยของ $name แล้ว';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'เปรียบเทียบตัวเลขเหล่านี้กับ $name ด้วยตนเองหรือผ่านช่องทางที่เชื่อถือได้';
  }

  @override
  String get verifyExplanation =>
      'ทุกบทสนทนามีหมายเลขความปลอดภัยที่ไม่ซ้ำกัน หากทั้งสองคนเห็นตัวเลขเดียวกันบนอุปกรณ์ของตน การเชื่อมต่อจะได้รับการยืนยันแบบต้นทางถึงปลายทาง';

  @override
  String verifyContactKey(String name) {
    return 'คีย์ของ $name';
  }

  @override
  String get verifyYourKey => 'คีย์ของคุณ';

  @override
  String get verifyRemoveVerification => 'ลบการยืนยัน';

  @override
  String get verifyMarkAsVerified => 'ทำเครื่องหมายว่ายืนยันแล้ว';

  @override
  String verifyAfterReinstall(String name) {
    return 'หาก $name ติดตั้งแอปใหม่ หมายเลขความปลอดภัยจะเปลี่ยนและการยืนยันจะถูกลบโดยอัตโนมัติ';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'ทำเครื่องหมายว่ายืนยันแล้วเฉพาะหลังจากเปรียบเทียบตัวเลขกับ $name ผ่านการโทรด้วยเสียงหรือพบกันตัวต่อตัว';
  }

  @override
  String get verifyNoSession =>
      'ยังไม่มีเซสชันการเข้ารหัส ส่งข้อความก่อนเพื่อสร้างหมายเลขความปลอดภัย';

  @override
  String get verifyNoKeyAvailable => 'ไม่มีคีย์';

  @override
  String verifyFingerprintCopied(String label) {
    return 'คัดลอกลายนิ้วมือ $label แล้ว';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL ฐานข้อมูล';

  @override
  String get providerOptionalHint => 'ไม่บังคับ';

  @override
  String get providerWebApiKeyLabel => 'Web API Key';

  @override
  String get providerOptionalForPublicDb => 'ไม่บังคับสำหรับ DB สาธารณะ';

  @override
  String get providerRelayUrlLabel => 'URL ของ Relay';

  @override
  String get providerPrivateKeyLabel => 'คีย์ส่วนตัว';

  @override
  String get providerPrivateKeyNsecLabel => 'คีย์ส่วนตัว (nsec)';

  @override
  String get providerStorageNodeLabel => 'URL โหนดจัดเก็บ (ไม่บังคับ)';

  @override
  String get providerStorageNodeHint => 'ปล่อยว่างเพื่อใช้ seed nodes ในตัว';

  @override
  String get transferInvalidCodeFormat =>
      'รูปแบบรหัสไม่รู้จัก — ต้องเริ่มต้นด้วย LAN: หรือ NOS:';

  @override
  String get profileCardFingerprintCopied => 'คัดลอกลายนิ้วมือแล้ว';

  @override
  String get profileCardAboutHint => 'ความเป็นส่วนตัวมาก่อน 🔒';

  @override
  String get profileCardSaveButton => 'บันทึกโปรไฟล์';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'ส่งออกข้อความเข้ารหัส ผู้ติดต่อ และอวาตาร์เป็นไฟล์';

  @override
  String get callVideo => 'วิดีโอ';

  @override
  String get callAudio => 'เสียง';

  @override
  String bubbleDeliveredTo(String names) {
    return 'ส่งถึง $names แล้ว';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'ส่งถึง $count คนแล้ว';
  }

  @override
  String get groupStatusDialogTitle => 'ข้อมูลข้อความ';

  @override
  String get groupStatusRead => 'อ่านแล้ว';

  @override
  String get groupStatusDelivered => 'ส่งถึงแล้ว';

  @override
  String get groupStatusPending => 'รอดำเนินการ';

  @override
  String get groupStatusNoData => 'ยังไม่มีข้อมูลการส่ง';

  @override
  String get profileTransferAdmin => 'ตั้งเป็นแอดมิน';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'ตั้ง $name เป็นแอดมินใหม่?';
  }

  @override
  String get profileTransferAdminBody =>
      'คุณจะสูญเสียสิทธิ์แอดมิน ไม่สามารถย้อนกลับได้';

  @override
  String profileTransferAdminDone(String name) {
    return '$name เป็นแอดมินแล้ว';
  }

  @override
  String get profileAdminBadge => 'แอดมิน';

  @override
  String get privacyPolicyTitle => 'นโยบายความเป็นส่วนตัว';

  @override
  String get privacyOverviewHeading => 'ภาพรวม';

  @override
  String get privacyOverviewBody =>
      'Pulse เป็นแอปแชทเข้ารหัสแบบต้นทางถึงปลายทางที่ไม่มีเซิร์ฟเวอร์ ความเป็นส่วนตัวของคุณไม่ใช่แค่ฟีเจอร์ — มันคือสถาปัตยกรรม ไม่มีเซิร์ฟเวอร์ Pulse ไม่มีบัญชีถูกจัดเก็บที่ไหน ไม่มีข้อมูลถูกรวบรวม ส่ง หรือจัดเก็บโดยนักพัฒนา';

  @override
  String get privacyDataCollectionHeading => 'การเก็บรวบรวมข้อมูล';

  @override
  String get privacyDataCollectionBody =>
      'Pulse ไม่เก็บข้อมูลส่วนบุคคลใดๆ โดยเฉพาะ:\n\n- ไม่ต้องใช้อีเมล หมายเลขโทรศัพท์ หรือชื่อจริง\n- ไม่มีการวิเคราะห์ ติดตาม หรือเก็บข้อมูลการใช้งาน\n- ไม่มีตัวระบุโฆษณา\n- ไม่เข้าถึงรายชื่อผู้ติดต่อ\n- ไม่มีการสำรองข้อมูลบนคลาวด์ (ข้อความอยู่ในอุปกรณ์ของคุณเท่านั้น)\n- ไม่มีข้อมูลเมตาถูกส่งไปยังเซิร์ฟเวอร์ Pulse ใดๆ (เพราะไม่มี)';

  @override
  String get privacyEncryptionHeading => 'การเข้ารหัส';

  @override
  String get privacyEncryptionBody =>
      'ข้อความทั้งหมดถูกเข้ารหัสด้วย Signal Protocol (Double Ratchet กับ X3DH key agreement) คีย์เข้ารหัสถูกสร้างและจัดเก็บบนอุปกรณ์ของคุณเท่านั้น ไม่มีใคร — รวมถึงนักพัฒนา — สามารถอ่านข้อความของคุณได้';

  @override
  String get privacyNetworkHeading => 'สถาปัตยกรรมเครือข่าย';

  @override
  String get privacyNetworkBody =>
      'Pulse ใช้อะแดปเตอร์ช่องทางส่งแบบกระจาย (Nostr relay, Session/Oxen service node, Firebase Realtime Database, LAN) ช่องทางเหล่านี้ส่งเฉพาะข้อความเข้ารหัสเท่านั้น ผู้ดูแล relay สามารถเห็น IP และปริมาณการใช้งานของคุณ แต่ไม่สามารถถอดรหัสเนื้อหาข้อความได้\n\nเมื่อเปิดใช้ Tor ที่อยู่ IP ของคุณจะถูกซ่อนจากผู้ดูแล relay ด้วย';

  @override
  String get privacyStunHeading => 'เซิร์ฟเวอร์ STUN/TURN';

  @override
  String get privacyStunBody =>
      'การโทรด้วยเสียงและวิดีโอใช้ WebRTC กับการเข้ารหัส DTLS-SRTP เซิร์ฟเวอร์ STUN (ใช้ค้นหา IP สาธารณะสำหรับการเชื่อมต่อ P2P) และเซิร์ฟเวอร์ TURN (ใช้ถ่ายทอดสื่อเมื่อเชื่อมต่อตรงไม่ได้) สามารถเห็น IP และระยะเวลาการโทร แต่ไม่สามารถถอดรหัสเนื้อหาการโทรได้\n\nคุณสามารถตั้งค่าเซิร์ฟเวอร์ TURN ของคุณเองในการตั้งค่าเพื่อความเป็นส่วนตัวสูงสุด';

  @override
  String get privacyCrashHeading => 'รายงานข้อขัดข้อง';

  @override
  String get privacyCrashBody =>
      'หากเปิดใช้การรายงานข้อขัดข้อง Sentry (ผ่าน SENTRY_DSN ตอน build) อาจมีการส่งรายงานข้อขัดข้องที่ไม่ระบุตัวตน ซึ่งไม่มีเนื้อหาข้อความ ข้อมูลผู้ติดต่อ หรือข้อมูลระบุตัวบุคคลใดๆ การรายงานข้อขัดข้องสามารถปิดได้ตอน build โดยไม่ใส่ DSN';

  @override
  String get privacyPasswordHeading => 'รหัสผ่าน & คีย์';

  @override
  String get privacyPasswordBody =>
      'รหัสผ่านกู้คืนของคุณใช้เพื่อสร้างคีย์เข้ารหัสผ่าน Argon2id (memory-hard KDF) รหัสผ่านไม่เคยถูกส่งไปที่ไหน หากคุณสูญเสียรหัสผ่าน บัญชีจะไม่สามารถกู้คืนได้ — ไม่มีเซิร์ฟเวอร์ให้รีเซ็ต';

  @override
  String get privacyFontsHeading => 'ฟอนต์';

  @override
  String get privacyFontsBody =>
      'Pulse รวมฟอนต์ทั้งหมดไว้ในเครื่อง ไม่มีการร้องขอไปยัง Google Fonts หรือบริการฟอนต์ภายนอกใดๆ';

  @override
  String get privacyThirdPartyHeading => 'บริการของบุคคลที่สาม';

  @override
  String get privacyThirdPartyBody =>
      'Pulse ไม่เชื่อมต่อกับเครือข่ายโฆษณา ผู้ให้บริการวิเคราะห์ แพลตฟอร์มโซเชียลมีเดีย หรือนายหน้าข้อมูลใดๆ การเชื่อมต่อเครือข่ายเดียวคือไปยัง relay ที่คุณกำหนดค่าเอง';

  @override
  String get privacyOpenSourceHeading => 'โอเพนซอร์ส';

  @override
  String get privacyOpenSourceBody =>
      'Pulse เป็นซอฟต์แวร์โอเพนซอร์ส คุณสามารถตรวจสอบซอร์สโค้ดทั้งหมดเพื่อยืนยันข้อกล่าวอ้างด้านความเป็นส่วนตัวเหล่านี้';

  @override
  String get privacyContactHeading => 'ติดต่อ';

  @override
  String get privacyContactBody =>
      'สำหรับคำถามเกี่ยวกับความเป็นส่วนตัว เปิด issue บนที่เก็บโปรเจกต์';

  @override
  String get privacyLastUpdated => 'อัปเดตล่าสุด: มีนาคม 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'บันทึกล้มเหลว: $error';
  }

  @override
  String get themeEngineTitle => 'เอ็นจินธีม';

  @override
  String get torBuiltInTitle => 'Tor ในตัว';

  @override
  String get torConnectedSubtitle =>
      'เชื่อมต่อแล้ว — Nostr ถูกส่งผ่าน 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'กำลังเชื่อมต่อ… $pct%';
  }

  @override
  String get torNotRunning => 'ไม่ทำงาน — แตะสวิตช์เพื่อรีสตาร์ท';

  @override
  String get torDescription =>
      'ส่ง Nostr ผ่าน Tor (Snowflake สำหรับเครือข่ายที่ถูกเซ็นเซอร์)';

  @override
  String get torNetworkDiagnostics => 'การวินิจฉัยเครือข่าย';

  @override
  String get torTransportLabel => 'ช่องทางส่ง: ';

  @override
  String get torPtAuto => 'อัตโนมัติ';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'ธรรมดา';

  @override
  String get torTimeoutLabel => 'หมดเวลา: ';

  @override
  String get torInfoDescription =>
      'เมื่อเปิดใช้ การเชื่อมต่อ WebSocket ของ Nostr จะถูกส่งผ่าน Tor (SOCKS5) Tor Browser ฟังที่ 127.0.0.1:9150 Tor daemon ใช้พอร์ต 9050 การเชื่อมต่อ Firebase ไม่ได้รับผลกระทบ';

  @override
  String get torRouteNostrTitle => 'ส่ง Nostr ผ่าน Tor';

  @override
  String get torManagedByBuiltin => 'จัดการโดย Tor ในตัว';

  @override
  String get torActiveRouting => 'เปิดใช้งาน — ทราฟฟิก Nostr ถูกส่งผ่าน Tor';

  @override
  String get torDisabled => 'ปิดใช้งาน';

  @override
  String get torProxySocks5 => 'พร็อกซี Tor (SOCKS5)';

  @override
  String get torProxyHostLabel => 'โฮสต์พร็อกซี';

  @override
  String get torProxyPortLabel => 'พอร์ต';

  @override
  String get torPortInfo =>
      'Tor Browser: พอร์ต 9150  •  Tor daemon: พอร์ต 9050';

  @override
  String get torForceNostrTitle => 'ส่งข้อความผ่าน Tor';

  @override
  String get torForceNostrSubtitle =>
      'การเชื่อมต่อ Nostr relay ทั้งหมดจะผ่าน Tor ช้าลงแต่ซ่อน IP ของคุณจาก relay';

  @override
  String get torForceNostrDisabled => 'ต้องเปิดใช้งาน Tor ก่อน';

  @override
  String get torForcePulseTitle => 'ส่ง Pulse relay ผ่าน Tor';

  @override
  String get torForcePulseSubtitle =>
      'การเชื่อมต่อ Pulse relay ทั้งหมดจะผ่าน Tor ช้าลงแต่ซ่อน IP ของคุณจากเซิร์ฟเวอร์';

  @override
  String get torForcePulseDisabled => 'ต้องเปิดใช้งาน Tor ก่อน';

  @override
  String get i2pProxySocks5 => 'พร็อกซี I2P (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P ใช้ SOCKS5 บนพอร์ต 4447 โดยค่าเริ่มต้น เชื่อมต่อกับ Nostr relay ผ่าน I2P outproxy (เช่น relay.damus.i2p) เพื่อสื่อสารกับผู้ใช้บนช่องทางส่งใดก็ได้ Tor มีความสำคัญมากกว่าเมื่อเปิดทั้งสอง';

  @override
  String get i2pRouteNostrTitle => 'ส่ง Nostr ผ่าน I2P';

  @override
  String get i2pActiveRouting => 'เปิดใช้งาน — ทราฟฟิก Nostr ถูกส่งผ่าน I2P';

  @override
  String get i2pDisabled => 'ปิดใช้งาน';

  @override
  String get i2pProxyHostLabel => 'โฮสต์พร็อกซี';

  @override
  String get i2pProxyPortLabel => 'พอร์ต';

  @override
  String get i2pPortInfo => 'พอร์ต SOCKS5 เริ่มต้นของ I2P Router: 4447';

  @override
  String get customProxySocks5 => 'พร็อกซีกำหนดเอง (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'พร็อกซีกำหนดเองส่งทราฟฟิกผ่าน V2Ray/Xray/Shadowsocks ของคุณ CF Worker ทำหน้าที่เป็น relay proxy ส่วนตัวบน Cloudflare CDN — GFW เห็น *.workers.dev ไม่ใช่ relay จริง';

  @override
  String get customSocks5ProxyTitle => 'พร็อกซี SOCKS5 กำหนดเอง';

  @override
  String get customProxyActive => 'เปิดใช้งาน — ทราฟฟิกถูกส่งผ่าน SOCKS5';

  @override
  String get customProxyDisabled => 'ปิดใช้งาน';

  @override
  String get customProxyHostLabel => 'โฮสต์พร็อกซี';

  @override
  String get customProxyPortLabel => 'พอร์ต';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'โดเมน Worker (ไม่บังคับ)';

  @override
  String get customWorkerHelpTitle => 'วิธีติดตั้ง CF Worker relay (ฟรี)';

  @override
  String get customWorkerScriptCopied => 'คัดลอกสคริปต์แล้ว!';

  @override
  String get customWorkerStep1 =>
      '1. ไปที่ dash.cloudflare.com → Workers & Pages\n2. Create Worker → วางสคริปต์นี้:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → คัดลอกโดเมน (เช่น my-relay.user.workers.dev)\n4. วางโดเมนด้านบน → บันทึก\n\nแอปเชื่อมต่ออัตโนมัติ: wss://domain/?r=relay_url\nGFW เห็น: การเชื่อมต่อกับ *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'เชื่อมต่อแล้ว — SOCKS5 บน 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'กำลังเชื่อมต่อ…';

  @override
  String get psiphonNotRunning => 'ไม่ทำงาน — แตะสวิตช์เพื่อรีสตาร์ท';

  @override
  String get psiphonDescription =>
      'อุโมงค์เร็ว (~3 วินาที bootstrap, VPS หมุนเวียน 2000+)';

  @override
  String get turnCommunityServers => 'เซิร์ฟเวอร์ TURN ชุมชน';

  @override
  String get turnCustomServer => 'เซิร์ฟเวอร์ TURN กำหนดเอง (BYOD)';

  @override
  String get turnInfoDescription =>
      'เซิร์ฟเวอร์ TURN ส่งต่อเฉพาะสตรีมที่เข้ารหัสแล้ว (DTLS-SRTP) ผู้ดูแล relay เห็น IP และปริมาณทราฟฟิกของคุณ แต่ไม่สามารถถอดรหัสการโทรได้ TURN ใช้เฉพาะเมื่อ P2P โดยตรงล้มเหลว (~15–20% ของการเชื่อมต่อ)';

  @override
  String get turnFreeLabel => 'ฟรี';

  @override
  String get turnServerUrlLabel => 'URL เซิร์ฟเวอร์ TURN';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 หรือ turns:...';

  @override
  String get turnUsernameLabel => 'ชื่อผู้ใช้';

  @override
  String get turnPasswordLabel => 'รหัสผ่าน';

  @override
  String get turnOptionalHint => 'ไม่บังคับ';

  @override
  String get turnCustomInfo =>
      'โฮสต์ coturn บน VPS ราคา \$5/เดือน เพื่อควบคุมสูงสุด ข้อมูลประจำตัวจัดเก็บในเครื่อง';

  @override
  String get themePickerAppearance => 'รูปลักษณ์';

  @override
  String get themePickerAccentColor => 'สีเน้น';

  @override
  String get themeModeLight => 'สว่าง';

  @override
  String get themeModeDark => 'มืด';

  @override
  String get themeModeSystem => 'ระบบ';

  @override
  String get themeDynamicPresets => 'ธีมสำเร็จรูป';

  @override
  String get themeDynamicPrimaryColor => 'สีหลัก';

  @override
  String get themeDynamicBorderRadius => 'รัศมีขอบ';

  @override
  String get themeDynamicFont => 'ฟอนต์';

  @override
  String get themeDynamicAppearance => 'รูปลักษณ์';

  @override
  String get themeDynamicUiStyle => 'รูปแบบ UI';

  @override
  String get themeDynamicUiStyleDescription =>
      'ควบคุมรูปลักษณ์ของกล่องโต้ตอบ สวิตช์ และตัวบ่งชี้';

  @override
  String get themeDynamicSharp => 'เหลี่ยม';

  @override
  String get themeDynamicRound => 'มน';

  @override
  String get themeDynamicModeDark => 'มืด';

  @override
  String get themeDynamicModeLight => 'สว่าง';

  @override
  String get themeDynamicModeAuto => 'อัตโนมัติ';

  @override
  String get themeDynamicPlatformAuto => 'อัตโนมัติ';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'URL Firebase ไม่ถูกต้อง ต้องเป็น https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'URL relay ไม่ถูกต้อง ต้องเป็น wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'URL เซิร์ฟเวอร์ Pulse ไม่ถูกต้อง ต้องเป็น https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'URL เซิร์ฟเวอร์';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'รหัสเชิญ';

  @override
  String get providerPulseInviteHint => 'รหัสเชิญ (ถ้าจำเป็น)';

  @override
  String get providerPulseInfo =>
      'Relay ที่โฮสต์เอง คีย์ได้มาจากรหัสผ่านกู้คืนของคุณ';

  @override
  String get providerScreenTitle => 'กล่องข้อความ';

  @override
  String get providerSecondaryInboxesHeader => 'กล่องข้อความรอง';

  @override
  String get providerSecondaryInboxesInfo =>
      'กล่องข้อความรองรับข้อความพร้อมกันเพื่อความซ้ำซ้อน';

  @override
  String get providerRemoveTooltip => 'ลบออก';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... หรือ hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... หรือ hex private key';

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
  String get emojiNoRecent => 'ไม่มีอิโมจิล่าสุด';

  @override
  String get emojiSearchHint => 'ค้นหาอิโมจิ...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'แตะเพื่อแชท';

  @override
  String get imageViewerSaveToDownloads => 'บันทึกไปยัง Downloads';

  @override
  String imageViewerSavedTo(String path) {
    return 'บันทึกไปยัง $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'ตกลง';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'ภาษา';

  @override
  String get settingsLanguageSubtitle => 'ภาษาแสดงผลของแอป';

  @override
  String get settingsLanguageSystem => 'ค่าเริ่มต้นของระบบ';

  @override
  String get onboardingLanguageTitle => 'เลือกภาษาของคุณ';

  @override
  String get onboardingLanguageSubtitle =>
      'คุณสามารถเปลี่ยนได้ภายหลังในการตั้งค่า';

  @override
  String get videoNoteRecord => 'บันทึกข้อความวิดีโอ';

  @override
  String get videoNoteTapToRecord => 'แตะเพื่อบันทึก';

  @override
  String get videoNoteTapToStop => 'แตะเพื่อหยุด';

  @override
  String get videoNoteCameraPermission => 'การอนุญาตใช้กล้องถูกปฏิเสธ';

  @override
  String get videoNoteMaxDuration => 'สูงสุด 30 วินาที';

  @override
  String get videoNoteNotSupported => 'ไม่รองรับบันทึกวิดีโอบนแพลตฟอร์มนี้';

  @override
  String get navChats => 'แชท';

  @override
  String get navUpdates => 'อัปเดต';

  @override
  String get navCalls => 'การโทร';

  @override
  String get filterAll => 'ทั้งหมด';

  @override
  String get filterUnread => 'ยังไม่ได้อ่าน';

  @override
  String get filterGroups => 'กลุ่ม';

  @override
  String get callsNoRecent => 'ไม่มีการโทรล่าสุด';

  @override
  String get callsEmptySubtitle => 'ประวัติการโทรของคุณจะแสดงที่นี่';

  @override
  String get appBarEncrypted => 'เข้ารหัสจากต้นทางถึงปลายทาง';

  @override
  String get newStatus => 'สถานะใหม่';

  @override
  String get newCall => 'การโทรใหม่';

  @override
  String get joinChannelTitle => 'เข้าร่วมช่อง';

  @override
  String get joinChannelDescription => 'URL ช่อง';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'กำลังดึงข้อมูลช่อง…';

  @override
  String get joinChannelNotFound => 'ไม่พบช่องที่ URL นี้';

  @override
  String get joinChannelNetworkError => 'ไม่สามารถติดต่อเซิร์ฟเวอร์ได้';

  @override
  String get joinChannelAlreadyJoined => 'เข้าร่วมแล้ว';

  @override
  String get joinChannelButton => 'เข้าร่วม';

  @override
  String get channelFeedEmpty => 'ยังไม่มีโพสต์';

  @override
  String get channelLeave => 'ออกจากช่อง';

  @override
  String get channelLeaveConfirm => 'ออกจากช่องนี้? โพสต์ที่แคชไว้จะถูกลบ';

  @override
  String get channelInfo => 'ข้อมูลช่อง';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'แก้ไขแล้ว';

  @override
  String get channelLoadMore => 'โหลดเพิ่มเติม';

  @override
  String get channelSearchPosts => 'ค้นหาโพสต์…';

  @override
  String get channelNoResults => 'ไม่พบโพสต์ที่ตรงกัน';

  @override
  String get channelUrl => 'URL ช่อง';

  @override
  String get channelCreated => 'เข้าร่วมแล้ว';

  @override
  String channelPostCount(int count) {
    return '$count โพสต์';
  }

  @override
  String get channelCopyUrl => 'คัดลอก URL';

  @override
  String get setupNext => 'ถัดไป';

  @override
  String get setupKeyWarning =>
      'A recovery key will be generated for you. It is the only way to restore your account on a new device — there is no server, no password reset.';

  @override
  String get setupKeyTitle => 'Your Recovery Key';

  @override
  String get setupKeySubtitle =>
      'Write this key down and store it in a safe place. You will need it to restore your account on a new device.';

  @override
  String get setupKeyCopied => 'คัดลอกแล้ว!';

  @override
  String get setupKeyWroteItDown => 'จดไว้แล้ว';

  @override
  String get setupKeyWarnBody =>
      'Write this key down as a backup. You can also view it later in Settings → Security.';

  @override
  String get setupVerifyTitle => 'Verify Recovery Key';

  @override
  String get setupVerifySubtitle =>
      'Re-enter your recovery key to confirm you saved it correctly.';

  @override
  String get setupVerifyButton => 'ยืนยัน';

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
  String get settingsViewRecoveryKey => 'ดูคีย์กู้คืน';

  @override
  String get settingsViewRecoveryKeySubtitle => 'แสดงคีย์กู้คืนบัญชีของคุณ';

  @override
  String get settingsRecoveryKeyNotStored =>
      'คีย์กู้คืนไม่พร้อมใช้งาน (สร้างก่อนฟีเจอร์นี้)';

  @override
  String get settingsRecoveryKeyWarning =>
      'เก็บคีย์นี้ไว้อย่างปลอดภัย ใครก็ตามที่มีมันสามารถกู้คืนบัญชีของคุณบนอุปกรณ์อื่นได้';

  @override
  String get replaceIdentityTitle => 'แทนที่ตัวตนที่มีอยู่?';

  @override
  String get replaceIdentityBodyRestore =>
      'มีตัวตนอยู่แล้วบนอุปกรณ์นี้ การกู้คืนจะแทนที่คีย์ Nostr และ seed ของ Oxen ปัจจุบันอย่างถาวร ผู้ติดต่อทั้งหมดจะไม่สามารถเข้าถึงที่อยู่ปัจจุบันของคุณได้\n\nไม่สามารถเลิกทำได้';

  @override
  String get replaceIdentityBodyCreate =>
      'มีตัวตนอยู่แล้วบนอุปกรณ์นี้ การสร้างใหม่จะแทนที่คีย์ Nostr และ seed ของ Oxen ปัจจุบันอย่างถาวร ผู้ติดต่อทั้งหมดจะไม่สามารถเข้าถึงที่อยู่ปัจจุบันของคุณได้\n\nไม่สามารถเลิกทำได้';

  @override
  String get replace => 'แทนที่';

  @override
  String get callNoScreenSources => 'ไม่มีแหล่งหน้าจอที่ใช้ได้';

  @override
  String get callScreenShareQuality => 'คุณภาพการแชร์หน้าจอ';

  @override
  String get callFrameRate => 'อัตราเฟรม';

  @override
  String get callResolution => 'ความละเอียด';

  @override
  String get callAutoResolution => 'อัตโนมัติ = ความละเอียดหน้าจอดั้งเดิม';

  @override
  String get callStartSharing => 'เริ่มแชร์';

  @override
  String get callCameraUnavailable =>
      'กล้องไม่พร้อมใช้งาน — อาจถูกใช้โดยแอปอื่น';

  @override
  String get themeResetToDefaults => 'รีเซ็ตเป็นค่าเริ่มต้น';

  @override
  String get backupSaveToDownloadsTitle => 'บันทึกข้อมูลสำรองไปยังดาวน์โหลด?';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'ตัวเลือกไฟล์ไม่พร้อมใช้งาน ข้อมูลสำรองจะถูกบันทึกไปที่:\n$path';
  }

  @override
  String get systemLabel => 'ระบบ';

  @override
  String get next => 'ถัดไป';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return 'แตะอีก $remaining ครั้งเพื่อเปิดโหมดนักพัฒนา';
  }

  @override
  String get devModeEnabled => 'เปิดใช้งานโหมดนักพัฒนาแล้ว';

  @override
  String get devTools => 'เครื่องมือนักพัฒนา';

  @override
  String get devAdapterDiagnostics => 'สวิตช์อะแดปเตอร์และการวินิจฉัย';

  @override
  String get devEnableAll => 'เปิดทั้งหมด';

  @override
  String get devDisableAll => 'ปิดทั้งหมด';

  @override
  String get turnUrlValidation =>
      'TURN URL ต้องเริ่มต้นด้วย turn: หรือ turns: (สูงสุด 512 ตัวอักษร)';

  @override
  String get callMissedCall => 'สายที่ไม่ได้รับ';

  @override
  String get callOutgoingCall => 'สายโทรออก';

  @override
  String get callIncomingCall => 'สายเรียกเข้า';

  @override
  String get mediaMissingData => 'ข้อมูลสื่อหายไป';

  @override
  String get mediaDownloadFailed => 'ดาวน์โหลดล้มเหลว';

  @override
  String get mediaDecryptFailed => 'ถอดรหัสล้มเหลว';

  @override
  String get callEndCallBanner => 'วางสาย';

  @override
  String get meFallback => 'ฉัน';

  @override
  String get imageSaveToDownloads => 'บันทึกไปยังดาวน์โหลด';

  @override
  String imageSavedToPath(String path) {
    return 'บันทึกไปที่ $path';
  }

  @override
  String get callScreenShareRequiresPermission =>
      'การแชร์หน้าจอต้องการสิทธิ์อนุญาต';

  @override
  String get callScreenShareUnavailable => 'การแชร์หน้าจอไม่พร้อมใช้งาน';

  @override
  String get statusJustNow => 'เมื่อสักครู่';

  @override
  String statusMinutesAgo(int minutes) {
    return '$minutes นาทีที่แล้ว';
  }

  @override
  String statusHoursAgo(int hours) {
    return '$hours ชม. ที่แล้ว';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count เส้นทาง',
      one: '1 เส้นทาง',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => 'พร้อมที่จะเพิ่ม';

  @override
  String groupSelectedCount(int count) {
    return 'เลือก $count รายการ';
  }

  @override
  String get paste => 'วาง';

  @override
  String get sfuAudioOnly => 'เสียงเท่านั้น';

  @override
  String sfuParticipants(int count) {
    return 'ผู้เข้าร่วม $count คน';
  }

  @override
  String get dataUnencryptedBackup => 'ข้อมูลสำรองที่ไม่ได้เข้ารหัส';

  @override
  String get dataUnencryptedBackupBody =>
      'ไฟล์นี้เป็นข้อมูลสำรองตัวตนที่ไม่ได้เข้ารหัสและจะเขียนทับคีย์ปัจจุบันของคุณ นำเข้าเฉพาะไฟล์ที่คุณสร้างเองเท่านั้น ดำเนินการต่อ?';

  @override
  String get dataImportAnyway => 'นำเข้าอยู่ดี';

  @override
  String get securityStorageError =>
      'ข้อผิดพลาดที่เก็บข้อมูลความปลอดภัย — รีสตาร์ทแอป';

  @override
  String get aboutDevModeActive => 'โหมดนักพัฒนาเปิดใช้งานอยู่';

  @override
  String get themeColors => 'สี';

  @override
  String get themePrimaryAccent => 'สีเน้นหลัก';

  @override
  String get themeSecondaryAccent => 'สีเน้นรอง';

  @override
  String get themeBackground => 'พื้นหลัง';

  @override
  String get themeSurface => 'พื้นผิว';

  @override
  String get themeChatBubbles => 'บับเบิลแชท';

  @override
  String get themeOutgoingMessage => 'ข้อความออก';

  @override
  String get themeIncomingMessage => 'ข้อความเข้า';

  @override
  String get themeShape => 'รูปร่าง';

  @override
  String get devSectionDeveloper => 'นักพัฒนา';

  @override
  String get devAdapterChannelsHint =>
      'ช่องอะแดปเตอร์ — ปิดเพื่อทดสอบการส่งข้อมูลเฉพาะ';

  @override
  String get devNostrRelays => 'Nostr relays (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'เครือข่าย Session';

  @override
  String get devPulseRelay => 'Pulse relay โฮสต์เอง';

  @override
  String get devLanNetwork => 'เครือข่ายท้องถิ่น (UDP/TCP)';

  @override
  String get devSectionCalls => 'การโทร';

  @override
  String get devForceTurnRelay => 'บังคับใช้ TURN relay';

  @override
  String get devForceTurnRelaySubtitle =>
      'ปิด P2P — สายทั้งหมดผ่านเซิร์ฟเวอร์ TURN เท่านั้น';

  @override
  String get devRestartWarning =>
      '⚠ การเปลี่ยนแปลงจะมีผลในการส่ง/โทรครั้งถัดไป รีสตาร์ทแอปเพื่อใช้กับสายเข้า';

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
  String get pulseUseServerTitle => 'ใช้เซิร์ฟเวอร์ Pulse หรือไม่?';

  @override
  String pulseUseServerBody(String name, String host) {
    return '$name ใช้เซิร์ฟเวอร์ Pulse $host เข้าร่วมเพื่อแชทได้เร็วขึ้น (และกับผู้อื่นบนเซิร์ฟเวอร์เดียวกัน)?';
  }

  @override
  String pulseContactUsesPulse(String name) {
    return '$name ใช้ Pulse';
  }

  @override
  String pulseJoinForFaster(String host) {
    return 'เข้าร่วม $host เพื่อแชทได้เร็วขึ้น';
  }

  @override
  String get pulseNotNow => 'ไม่ใช่ตอนนี้';

  @override
  String get pulseJoin => 'เข้าร่วม';

  @override
  String get pulseDismiss => 'ปิด';

  @override
  String get pulseHide7Days => 'ซ่อน 7 วัน';

  @override
  String get pulseNeverAskAgain => 'อย่าถามอีก';

  @override
  String get groupSearchContactsHint => 'ค้นหาผู้ติดต่อ…';

  @override
  String get systemActorYou => 'คุณ';

  @override
  String get systemActorPeer => 'ผู้ติดต่อ';

  @override
  String systemTtlEnabled(String actor, String duration) {
    return '$actor เปิดใช้ข้อความที่หายไป: $duration';
  }

  @override
  String systemTtlDisabled(String actor) {
    return '$actor ปิดข้อความที่หายไป';
  }

  @override
  String get menuClearChatHistory => 'ล้างประวัติการแชท';

  @override
  String get clearChatTitle => 'ล้างประวัติการแชท?';

  @override
  String get clearChatBody =>
      'ข้อความทั้งหมดในแชทนี้จะถูกลบออกจากอุปกรณ์นี้ อีกฝ่ายจะเก็บสำเนาของตน';

  @override
  String get clearChatAction => 'ล้าง';

  @override
  String systemGroupRenamed(String actor, String name) {
    return '$actor เปลี่ยนชื่อกลุ่มเป็น \"$name\"';
  }

  @override
  String systemGroupAvatarChanged(String actor) {
    return '$actor เปลี่ยนรูปกลุ่ม';
  }

  @override
  String systemGroupMetaChanged(String actor, String name) {
    return '$actor เปลี่ยนชื่อกลุ่มเป็น \"$name\" และเปลี่ยนรูป';
  }

  @override
  String get profileInviteLink => 'ลิงก์เชิญ';

  @override
  String get profileInviteLinkSubtitle => 'ใครก็ตามที่มีลิงก์สามารถเข้าร่วมได้';

  @override
  String get profileInviteLinkCopied => 'คัดลอกลิงก์เชิญแล้ว';

  @override
  String get groupInviteLinkTitle => 'เข้าร่วมกลุ่ม?';

  @override
  String groupInviteLinkBody(String name, int count) {
    return 'คุณได้รับเชิญให้เข้าร่วม \"$name\" ($count สมาชิก)';
  }

  @override
  String get groupInviteLinkJoin => 'เข้าร่วม';

  @override
  String get drawerJoinGroupByLink => 'เข้าร่วมกลุ่มผ่านลิงก์';

  @override
  String get drawerJoinGroupByLinkInvalid => 'นี่ไม่ใช่ลิงก์เชิญของ Pulse';
}
