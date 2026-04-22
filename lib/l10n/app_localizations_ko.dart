// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => '메시지 검색...';

  @override
  String get search => '검색';

  @override
  String get clearSearch => '검색 지우기';

  @override
  String get closeSearch => '검색 닫기';

  @override
  String get moreOptions => '더보기';

  @override
  String get back => '뒤로';

  @override
  String get cancel => '취소';

  @override
  String get close => '닫기';

  @override
  String get confirm => '확인';

  @override
  String get remove => '삭제';

  @override
  String get save => '저장';

  @override
  String get add => '추가';

  @override
  String get copy => '복사';

  @override
  String get skip => '건너뛰기';

  @override
  String get done => '완료';

  @override
  String get apply => '적용';

  @override
  String get export => '내보내기';

  @override
  String get import => '가져오기';

  @override
  String get homeNewGroup => '새 그룹';

  @override
  String get homeSettings => '설정';

  @override
  String get homeSearching => '메시지 검색 중...';

  @override
  String get homeNoResults => '결과 없음';

  @override
  String get homeNoChatHistory => '대화 기록이 없습니다';

  @override
  String homeTransportSwitched(String address) {
    return '전송 경로 변경 → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name님이 전화 중...';
  }

  @override
  String get homeAccept => '수락';

  @override
  String get homeDecline => '거절';

  @override
  String get homeLoadEarlier => '이전 메시지 불러오기';

  @override
  String get homeChats => '대화';

  @override
  String get homeSelectConversation => '대화를 선택하세요';

  @override
  String get homeNoChatsYet => '아직 대화가 없습니다';

  @override
  String get homeAddContactToStart => '연락처를 추가하여 대화를 시작하세요';

  @override
  String get homeNewChat => '새 대화';

  @override
  String get homeNewChatTooltip => '새 대화';

  @override
  String get homeIncomingCallTitle => '수신 전화';

  @override
  String get homeIncomingGroupCallTitle => '수신 그룹 통화';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — 그룹 통화 수신 중';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return '\"$query\"에 일치하는 대화 없음';
  }

  @override
  String get homeSectionChats => '대화';

  @override
  String get homeSectionMessages => '메시지';

  @override
  String get homeDbEncryptionUnavailable =>
      '데이터베이스 암호화를 사용할 수 없습니다 — 완전한 보호를 위해 SQLCipher를 설치하세요';

  @override
  String get chatFileTooLargeGroup => '그룹 대화에서는 512 KB를 초과하는 파일을 지원하지 않습니다';

  @override
  String get chatLargeFile => '대용량 파일';

  @override
  String get chatCancel => '취소';

  @override
  String get chatSend => '보내기';

  @override
  String get chatFileTooLarge => '파일이 너무 큽니다 — 최대 크기는 100 MB입니다';

  @override
  String get chatMicDenied => '마이크 권한이 거부되었습니다';

  @override
  String get chatVoiceFailed => '음성 메시지 저장 실패 — 저장 공간을 확인하세요';

  @override
  String get chatScheduleFuture => '예약 시간은 미래여야 합니다';

  @override
  String get chatToday => '오늘';

  @override
  String get chatYesterday => '어제';

  @override
  String get chatEdited => '수정됨';

  @override
  String get chatYou => '나';

  @override
  String chatLargeFileSizeWarning(String size) {
    return '이 파일은 $size MB입니다. 일부 네트워크에서 대용량 파일 전송이 느릴 수 있습니다. 계속하시겠습니까?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return '$name님의 보안 키가 변경되었습니다. 탭하여 확인하세요.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return '$name님에게 메시지를 암호화할 수 없습니다 — 메시지가 전송되지 않았습니다.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return '$name님의 안전 번호가 변경되었습니다. 탭하여 확인하세요.';
  }

  @override
  String get chatNoMessagesFound => '메시지를 찾을 수 없습니다';

  @override
  String get chatMessagesE2ee => '메시지는 종단 간 암호화되어 있습니다';

  @override
  String get chatSayHello => '인사하기';

  @override
  String get appBarOnline => '온라인';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => '입력 중';

  @override
  String get appBarSearchMessages => '메시지 검색...';

  @override
  String get appBarMute => '음소거';

  @override
  String get appBarUnmute => '음소거 해제';

  @override
  String get appBarMedia => '미디어';

  @override
  String get appBarDisappearing => '사라지는 메시지';

  @override
  String get appBarDisappearingOn => '사라지는 메시지: 켜짐';

  @override
  String get appBarGroupSettings => '그룹 설정';

  @override
  String get appBarSearchTooltip => '메시지 검색';

  @override
  String get appBarVoiceCall => '음성 통화';

  @override
  String get appBarVideoCall => '영상 통화';

  @override
  String get inputMessage => '메시지...';

  @override
  String get inputAttachFile => '파일 첨부';

  @override
  String get inputSendMessage => '메시지 보내기';

  @override
  String get inputRecordVoice => '음성 메시지 녹음';

  @override
  String get inputSendVoice => '음성 메시지 보내기';

  @override
  String get inputCancelReply => '답장 취소';

  @override
  String get inputCancelEdit => '수정 취소';

  @override
  String get inputCancelRecording => '녹음 취소';

  @override
  String get inputRecording => '녹음 중…';

  @override
  String get inputEditingMessage => '메시지 수정 중';

  @override
  String get inputPhoto => '사진';

  @override
  String get inputVoiceMessage => '음성 메시지';

  @override
  String get inputFile => '파일';

  @override
  String inputScheduledMessages(int count) {
    return '예약된 메시지 $count개';
  }

  @override
  String get callInitializing => '통화 초기화 중…';

  @override
  String get callConnecting => '연결 중…';

  @override
  String get callConnectingRelay => '연결 중 (릴레이)…';

  @override
  String get callSwitchingRelay => '릴레이 모드로 전환 중…';

  @override
  String get callConnectionFailed => '연결 실패';

  @override
  String get callReconnecting => '재연결 중…';

  @override
  String get callEnded => '통화 종료';

  @override
  String get callLive => '실시간';

  @override
  String get callEnd => '종료';

  @override
  String get callEndCall => '통화 종료';

  @override
  String get callMute => '음소거';

  @override
  String get callUnmute => '음소거 해제';

  @override
  String get callSpeaker => '스피커';

  @override
  String get callCameraOn => '카메라 켜기';

  @override
  String get callCameraOff => '카메라 끄기';

  @override
  String get callShareScreen => '화면 공유';

  @override
  String get callStopShare => '공유 중지';

  @override
  String callTorBackup(String duration) {
    return 'Tor 백업 · $duration';
  }

  @override
  String get callTorBackupBanner => 'Tor 백업 활성 — 기본 경로 사용 불가';

  @override
  String get callDirectFailed => '직접 연결 실패 — 릴레이 모드로 전환 중…';

  @override
  String get callTurnUnreachable =>
      'TURN 서버에 연결할 수 없습니다. 설정 → 고급에서 사용자 정의 TURN을 추가하세요.';

  @override
  String get callRelayMode => '릴레이 모드 활성 (제한된 네트워크)';

  @override
  String get callStarting => '통화 시작 중…';

  @override
  String get callConnectingToGroup => '그룹에 연결 중…';

  @override
  String get callGroupOpenedInBrowser => '그룹 통화가 브라우저에서 열렸습니다';

  @override
  String get callCouldNotOpenBrowser => '브라우저를 열 수 없습니다';

  @override
  String get callInviteLinkSent => '초대 링크가 모든 그룹 구성원에게 전송되었습니다.';

  @override
  String get callOpenLinkManually => '위 링크를 수동으로 열거나 탭하여 다시 시도하세요.';

  @override
  String get callJitsiNotE2ee => 'Jitsi 통화는 종단 간 암호화되지 않습니다';

  @override
  String get callRetryOpenBrowser => '브라우저 다시 열기';

  @override
  String get callClose => '닫기';

  @override
  String get callCamOn => '카메라 켜기';

  @override
  String get callCamOff => '카메라 끄기';

  @override
  String get noConnection => '연결 없음 — 메시지가 대기열에 추가됩니다';

  @override
  String get connected => '연결됨';

  @override
  String get connecting => '연결 중…';

  @override
  String get disconnected => '연결 끊김';

  @override
  String get offlineBanner => '연결 없음 — 온라인이 되면 메시지가 전송됩니다';

  @override
  String get lanModeBanner => 'LAN 모드 — 인터넷 없음 · 로컬 네트워크만';

  @override
  String get probeCheckingNetwork => '네트워크 연결 확인 중…';

  @override
  String get probeDiscoveringRelays => '커뮤니티 디렉토리에서 릴레이 검색 중…';

  @override
  String get probeStartingTor => '부트스트랩을 위해 Tor 시작 중…';

  @override
  String get probeFindingRelaysTor => 'Tor를 통해 사용 가능한 릴레이 검색 중…';

  @override
  String probeNetworkReady(int count) {
    return '네트워크 준비 완료 — 릴레이 $count개 발견';
  }

  @override
  String get probeNoRelaysFound => '사용 가능한 릴레이를 찾을 수 없습니다 — 메시지가 지연될 수 있습니다';

  @override
  String get jitsiWarningTitle => '종단 간 암호화되지 않음';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet 통화는 Pulse에 의해 암호화되지 않습니다. 민감하지 않은 대화에만 사용하세요.';

  @override
  String get jitsiConfirm => '그래도 참여';

  @override
  String get jitsiGroupWarningTitle => '종단 간 암호화되지 않음';

  @override
  String get jitsiGroupWarningBody =>
      '이 통화는 내장 암호화 메시에 참가자가 너무 많습니다.\n\nJitsi Meet 링크가 브라우저에서 열립니다. Jitsi는 종단 간 암호화되지 않습니다 — 서버가 통화를 볼 수 있습니다.';

  @override
  String get jitsiContinueAnyway => '그래도 계속';

  @override
  String get retry => '다시 시도';

  @override
  String get setupCreateAnonymousAccount => '익명 계정 만들기';

  @override
  String get setupTapToChangeColor => '탭하여 색상 변경';

  @override
  String get setupReqMinLength => '최소 16자';

  @override
  String get setupReqVariety => '4가지 중 3가지: 대문자, 소문자, 숫자, 기호';

  @override
  String get setupReqMatch => '비밀번호 일치';

  @override
  String get setupYourNickname => '닉네임';

  @override
  String get setupRecoveryPassword => '복구 비밀번호 (최소 16자)';

  @override
  String get setupConfirmPassword => '비밀번호 확인';

  @override
  String get setupMin16Chars => '최소 16자';

  @override
  String get setupPasswordsDoNotMatch => '비밀번호가 일치하지 않습니다';

  @override
  String get setupEntropyWeak => '약함';

  @override
  String get setupEntropyOk => '보통';

  @override
  String get setupEntropyStrong => '강함';

  @override
  String get setupEntropyWeakNeedsVariety => '약함 (3가지 문자 유형 필요)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits비트)';
  }

  @override
  String get setupPasswordWarning =>
      '이 비밀번호는 계정을 복구하는 유일한 방법입니다. 서버가 없으므로 비밀번호를 재설정할 수 없습니다. 기억하거나 적어 두세요.';

  @override
  String get setupCreateAccount => '계정 만들기';

  @override
  String get setupAlreadyHaveAccount => '이미 계정이 있으신가요? ';

  @override
  String get setupRestore => '복구 →';

  @override
  String get restoreTitle => '계정 복구';

  @override
  String get restoreInfoBanner =>
      '복구 비밀번호를 입력하세요 — 주소(Nostr + Session)가 자동으로 복원됩니다. 연락처와 메시지는 기기에만 저장되어 있었습니다.';

  @override
  String get restoreNewNickname => '새 닉네임 (나중에 변경 가능)';

  @override
  String get restoreButton => '계정 복구';

  @override
  String get lockTitle => 'Pulse가 잠겨 있습니다';

  @override
  String get lockSubtitle => '계속하려면 비밀번호를 입력하세요';

  @override
  String get lockPasswordHint => '비밀번호';

  @override
  String get lockUnlock => '잠금 해제';

  @override
  String get lockPanicHint => '비밀번호를 잊으셨나요? 비상 키를 입력하면 모든 데이터가 삭제됩니다.';

  @override
  String get lockTooManyAttempts => '시도 횟수 초과. 모든 데이터를 삭제합니다…';

  @override
  String get lockWrongPassword => '잘못된 비밀번호';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return '잘못된 비밀번호 — $attempts/$max회 시도';
  }

  @override
  String get onboardingSkip => '건너뛰기';

  @override
  String get onboardingNext => '다음';

  @override
  String get onboardingGetStarted => '계정 만들기';

  @override
  String get onboardingWelcomeTitle => 'Pulse에 오신 것을 환영합니다';

  @override
  String get onboardingWelcomeBody =>
      '탈중앙화, 종단 간 암호화 메신저.\n\n중앙 서버 없음. 데이터 수집 없음. 백도어 없음.\n당신의 대화는 오직 당신의 것입니다.';

  @override
  String get onboardingTransportTitle => '전송 경로 독립적';

  @override
  String get onboardingTransportBody =>
      'Firebase, Nostr 또는 둘 다 동시에 사용하세요.\n\n메시지가 네트워크 간에 자동으로 라우팅됩니다. 검열 저항을 위한 Tor 및 I2P 지원이 내장되어 있습니다.';

  @override
  String get onboardingSignalTitle => 'Signal + 포스트 양자';

  @override
  String get onboardingSignalBody =>
      '모든 메시지는 순방향 비밀성을 위해 Signal 프로토콜(Double Ratchet + X3DH)로 암호화됩니다.\n\n추가로 NIST 표준 포스트 양자 알고리즘인 Kyber-1024로 래핑되어 미래의 양자 컴퓨터로부터 보호합니다.';

  @override
  String get onboardingKeysTitle => '당신이 키를 소유합니다';

  @override
  String get onboardingKeysBody =>
      '신원 키는 절대 기기를 떠나지 않습니다.\n\nSignal 지문을 통해 대역 외에서 연락처를 확인할 수 있습니다. TOFU(최초 사용 시 신뢰)가 키 변경을 자동으로 감지합니다.';

  @override
  String get onboardingThemeTitle => '테마를 선택하세요';

  @override
  String get onboardingThemeBody =>
      '테마와 강조 색상을 선택하세요. 나중에 설정에서 언제든지 변경할 수 있습니다.';

  @override
  String get contactsNewChat => '새 대화';

  @override
  String get contactsAddContact => '연락처 추가';

  @override
  String get contactsSearchHint => '검색...';

  @override
  String get contactsNewGroup => '새 그룹';

  @override
  String get contactsNoContactsYet => '아직 연락처가 없습니다';

  @override
  String get contactsAddHint => '+를 탭하여 주소를 추가하세요';

  @override
  String get contactsNoMatch => '일치하는 연락처 없음';

  @override
  String get contactsRemoveTitle => '연락처 삭제';

  @override
  String contactsRemoveMessage(String name) {
    return '$name님을 삭제하시겠습니까?';
  }

  @override
  String get contactsRemove => '삭제';

  @override
  String contactsCount(int count) {
    return '연락처 $count명';
  }

  @override
  String get bubbleOpenLink => '링크 열기';

  @override
  String bubbleOpenLinkBody(String url) {
    return '이 URL을 브라우저에서 여시겠습니까?\n\n$url';
  }

  @override
  String get bubbleOpen => '열기';

  @override
  String get bubbleSecurityWarning => '보안 경고';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\"은(는) 실행 파일입니다. 저장 후 실행하면 기기에 해를 끼칠 수 있습니다. 그래도 저장하시겠습니까?';
  }

  @override
  String get bubbleSaveAnyway => '그래도 저장';

  @override
  String bubbleSavedTo(String path) {
    return '$path에 저장됨';
  }

  @override
  String bubbleSaveFailed(String error) {
    return '저장 실패: $error';
  }

  @override
  String get bubbleNotEncrypted => '암호화되지 않음';

  @override
  String get bubbleCorruptedImage => '[손상된 이미지]';

  @override
  String get bubbleReplyPhoto => '사진';

  @override
  String get bubbleReplyVoice => '음성 메시지';

  @override
  String get bubbleReplyVideo => '영상 메시지';

  @override
  String bubbleReadBy(String names) {
    return '$names이(가) 읽음';
  }

  @override
  String bubbleReadByCount(int count) {
    return '$count명이 읽음';
  }

  @override
  String get chatTileTapToStart => '탭하여 대화 시작';

  @override
  String get chatTileMessageSent => '메시지 전송됨';

  @override
  String get chatTileEncryptedMessage => '암호화된 메시지';

  @override
  String chatTileYouPrefix(String text) {
    return '나: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 음성 메시지';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 음성 메시지 ($duration)';
  }

  @override
  String get bannerEncryptedMessage => '암호화된 메시지';

  @override
  String get groupNewGroup => '새 그룹';

  @override
  String get groupGroupName => '그룹 이름';

  @override
  String get groupSelectMembers => '구성원 선택 (최소 2명)';

  @override
  String get groupNoContactsYet => '아직 연락처가 없습니다. 먼저 연락처를 추가하세요.';

  @override
  String get groupCreate => '만들기';

  @override
  String get groupLabel => '그룹';

  @override
  String get profileVerifyIdentity => '신원 확인';

  @override
  String profileVerifyInstructions(String name) {
    return '$name님과 음성 통화 또는 직접 만나서 이 지문을 비교하세요. 양쪽 기기에서 값이 일치하면 \"확인됨으로 표시\"를 탭하세요.';
  }

  @override
  String get profileTheirKey => '상대방의 키';

  @override
  String get profileYourKey => '나의 키';

  @override
  String get profileRemoveVerification => '확인 제거';

  @override
  String get profileMarkAsVerified => '확인됨으로 표시';

  @override
  String get profileAddressCopied => '주소가 복사됨';

  @override
  String get profileNoContactsToAdd => '추가할 연락처 없음 — 모두 이미 구성원입니다';

  @override
  String get profileAddMembers => '구성원 추가';

  @override
  String profileAddCount(int count) {
    return '추가 ($count)';
  }

  @override
  String get profileRenameGroup => '그룹 이름 변경';

  @override
  String get profileRename => '이름 변경';

  @override
  String get profileRemoveMember => '구성원을 삭제하시겠습니까?';

  @override
  String profileRemoveMemberBody(String name) {
    return '이 그룹에서 $name님을 삭제하시겠습니까?';
  }

  @override
  String get profileKick => '추방';

  @override
  String get profileSignalFingerprints => 'Signal 지문';

  @override
  String get profileVerified => '확인됨';

  @override
  String get profileVerify => '확인';

  @override
  String get profileEdit => '편집';

  @override
  String get profileNoSession => '아직 세션이 설정되지 않았습니다 — 먼저 메시지를 보내세요.';

  @override
  String get profileFingerprintCopied => '지문이 복사됨';

  @override
  String profileMemberCount(int count) {
    return '구성원 $count명';
  }

  @override
  String get profileVerifySafetyNumber => '안전 번호 확인';

  @override
  String get profileShowContactQr => '연락처 QR 보기';

  @override
  String profileContactAddress(String name) {
    return '$name님의 주소';
  }

  @override
  String get profileExportChatHistory => '대화 기록 내보내기';

  @override
  String profileSavedTo(String path) {
    return '$path에 저장됨';
  }

  @override
  String get profileExportFailed => '내보내기 실패';

  @override
  String get profileClearChatHistory => '대화 기록 삭제';

  @override
  String get profileDeleteGroup => '그룹 삭제';

  @override
  String get profileDeleteContact => '연락처 삭제';

  @override
  String get profileLeaveGroup => '그룹 나가기';

  @override
  String get profileLeaveGroupBody => '이 그룹에서 나가며 연락처에서 삭제됩니다.';

  @override
  String get groupInviteTitle => '그룹 초대';

  @override
  String groupInviteBody(String from, String group) {
    return '$from님이 \"$group\"에 초대했습니다';
  }

  @override
  String get groupInviteAccept => '수락';

  @override
  String get groupInviteDecline => '거절';

  @override
  String get groupMemberLimitTitle => '참가자가 너무 많습니다';

  @override
  String groupMemberLimitBody(int count) {
    return '이 그룹에는 $count명의 참가자가 있습니다. 암호화 메시 통화는 최대 6명까지 지원됩니다. 더 큰 그룹은 Jitsi로 대체됩니다(종단 간 암호화되지 않음).';
  }

  @override
  String get groupMemberLimitContinue => '그래도 추가';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name님이 \"$group\" 참여를 거절했습니다';
  }

  @override
  String get transferTitle => '다른 기기로 전송';

  @override
  String get transferInfoBox =>
      'Signal 신원과 Nostr 키를 새 기기로 이동합니다.\n대화 세션은 전송되지 않습니다 — 순방향 비밀성이 보존됩니다.';

  @override
  String get transferSendFromThis => '이 기기에서 보내기';

  @override
  String get transferSendSubtitle => '이 기기에 키가 있습니다. 새 기기와 코드를 공유하세요.';

  @override
  String get transferReceiveOnThis => '이 기기에서 받기';

  @override
  String get transferReceiveSubtitle => '이것은 새 기기입니다. 이전 기기에서 코드를 입력하세요.';

  @override
  String get transferChooseMethod => '전송 방법 선택';

  @override
  String get transferLan => 'LAN (같은 네트워크)';

  @override
  String get transferLanSubtitle => '빠르고 직접적입니다. 두 기기가 같은 Wi-Fi에 있어야 합니다.';

  @override
  String get transferNostrRelay => 'Nostr 릴레이';

  @override
  String get transferNostrRelaySubtitle =>
      '기존 Nostr 릴레이를 사용하여 모든 네트워크에서 작동합니다.';

  @override
  String get transferRelayUrl => '릴레이 URL';

  @override
  String get transferEnterCode => '전송 코드 입력';

  @override
  String get transferPasteCode => 'LAN:... 또는 NOS:... 코드를 여기에 붙여넣으세요';

  @override
  String get transferConnect => '연결';

  @override
  String get transferGenerating => '전송 코드 생성 중…';

  @override
  String get transferShareCode => '이 코드를 수신자에게 공유하세요:';

  @override
  String get transferCopyCode => '코드 복사';

  @override
  String get transferCodeCopied => '코드가 클립보드에 복사됨';

  @override
  String get transferWaitingReceiver => '수신자 연결 대기 중…';

  @override
  String get transferConnectingSender => '발신자에 연결 중…';

  @override
  String get transferVerifyBoth => '양쪽 기기에서 이 코드를 비교하세요.\n일치하면 전송이 안전합니다.';

  @override
  String get transferComplete => '전송 완료';

  @override
  String get transferKeysImported => '키 가져오기 완료';

  @override
  String get transferCompleteSenderBody =>
      '이 기기에서 키가 계속 활성 상태입니다.\n수신자가 이제 당신의 신원을 사용할 수 있습니다.';

  @override
  String get transferCompleteReceiverBody =>
      '키를 성공적으로 가져왔습니다.\n새 신원을 적용하려면 앱을 다시 시작하세요.';

  @override
  String get transferRestartApp => '앱 다시 시작';

  @override
  String get transferFailed => '전송 실패';

  @override
  String get transferTryAgain => '다시 시도';

  @override
  String get transferEnterRelayFirst => '먼저 릴레이 URL을 입력하세요';

  @override
  String get transferPasteCodeFromSender => '발신자의 전송 코드를 붙여넣으세요';

  @override
  String get menuReply => '답장';

  @override
  String get menuForward => '전달';

  @override
  String get menuReact => '반응';

  @override
  String get menuCopy => '복사';

  @override
  String get menuEdit => '수정';

  @override
  String get menuRetry => '다시 시도';

  @override
  String get menuCancelScheduled => '예약 취소';

  @override
  String get menuDelete => '삭제';

  @override
  String get menuForwardTo => '전달 대상…';

  @override
  String menuForwardedTo(String name) {
    return '$name님에게 전달됨';
  }

  @override
  String get menuScheduledMessages => '예약된 메시지';

  @override
  String get menuNoScheduledMessages => '예약된 메시지 없음';

  @override
  String menuSendsOn(String date) {
    return '$date에 전송 예정';
  }

  @override
  String get menuDisappearingMessages => '사라지는 메시지';

  @override
  String get menuDisappearingSubtitle => '선택한 시간이 지나면 메시지가 자동으로 삭제됩니다.';

  @override
  String get menuTtlOff => '끄기';

  @override
  String get menuTtl1h => '1시간';

  @override
  String get menuTtl24h => '24시간';

  @override
  String get menuTtl7d => '7일';

  @override
  String get menuAttachPhoto => '사진';

  @override
  String get menuAttachFile => '파일';

  @override
  String get menuAttachVideo => '동영상';

  @override
  String get mediaTitle => '미디어';

  @override
  String get mediaFileLabel => '파일';

  @override
  String mediaPhotosTab(int count) {
    return '사진 ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return '파일 ($count)';
  }

  @override
  String get mediaNoPhotos => '아직 사진이 없습니다';

  @override
  String get mediaNoFiles => '아직 파일이 없습니다';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Downloads/$name에 저장됨';
  }

  @override
  String get mediaFailedToSave => '파일 저장 실패';

  @override
  String get statusNewStatus => '새 상태';

  @override
  String get statusPublish => '게시';

  @override
  String get statusExpiresIn24h => '상태는 24시간 후 만료됩니다';

  @override
  String get statusWhatsOnYourMind => '무슨 생각을 하고 계신가요?';

  @override
  String get statusPhotoAttached => '사진 첨부됨';

  @override
  String get statusAttachPhoto => '사진 첨부 (선택 사항)';

  @override
  String get statusEnterText => '상태에 텍스트를 입력하세요.';

  @override
  String statusPickPhotoFailed(String error) {
    return '사진 선택 실패: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return '게시 실패: $error';
  }

  @override
  String get panicSetPanicKey => '비상 키 설정';

  @override
  String get panicEmergencySelfDestruct => '긴급 자가 파괴';

  @override
  String get panicIrreversible => '이 작업은 되돌릴 수 없습니다';

  @override
  String get panicWarningBody =>
      '잠금 화면에서 이 키를 입력하면 모든 데이터가 즉시 삭제됩니다 — 메시지, 연락처, 키, 신원. 일반 비밀번호와 다른 키를 사용하세요.';

  @override
  String get panicKeyHint => '비상 키';

  @override
  String get panicConfirmHint => '비상 키 확인';

  @override
  String get panicMinChars => '비상 키는 최소 8자 이상이어야 합니다';

  @override
  String get panicKeysDoNotMatch => '키가 일치하지 않습니다';

  @override
  String get panicSetFailed => '비상 키 저장 실패 — 다시 시도하세요';

  @override
  String get passwordSetAppPassword => '앱 비밀번호 설정';

  @override
  String get passwordProtectsMessages => '저장된 메시지를 보호합니다';

  @override
  String get passwordInfoBanner => 'Pulse를 열 때마다 필요합니다. 분실 시 데이터를 복구할 수 없습니다.';

  @override
  String get passwordHint => '비밀번호';

  @override
  String get passwordConfirmHint => '비밀번호 확인';

  @override
  String get passwordSetButton => '비밀번호 설정';

  @override
  String get passwordSkipForNow => '지금은 건너뛰기';

  @override
  String get passwordMinChars => '비밀번호는 최소 8자 이상이어야 합니다';

  @override
  String get passwordNeedsVariety => '문자, 숫자, 특수 문자를 포함해야 합니다';

  @override
  String get passwordRequirements => '최소 8자, 문자·숫자·특수 문자 포함';

  @override
  String get passwordsDoNotMatch => '비밀번호가 일치하지 않습니다';

  @override
  String get profileCardSaved => '프로필이 저장되었습니다!';

  @override
  String get profileCardE2eeIdentity => 'E2EE 신원';

  @override
  String get profileCardDisplayName => '표시 이름';

  @override
  String get profileCardDisplayNameHint => '예: 홍길동';

  @override
  String get profileCardAbout => '소개';

  @override
  String get profileCardSaveProfile => '프로필 저장';

  @override
  String get profileCardYourName => '이름';

  @override
  String get profileCardAddressCopied => '주소가 복사되었습니다!';

  @override
  String get profileCardInboxAddress => '수신 주소';

  @override
  String get profileCardInboxAddresses => '수신 주소 목록';

  @override
  String get profileCardShareAllAddresses => '모든 주소 공유 (SmartRouter)';

  @override
  String get profileCardShareHint => '연락처에게 공유하면 메시지를 보낼 수 있습니다.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return '모든 $count개 주소가 하나의 링크로 복사되었습니다!';
  }

  @override
  String get settingsMyProfile => '내 프로필';

  @override
  String get settingsYourInboxAddress => '수신 주소';

  @override
  String get settingsMyQrCode => '연락처 공유';

  @override
  String get settingsMyQrSubtitle => '주소의 QR 코드 및 초대 링크';

  @override
  String get settingsShareMyAddress => '내 주소 공유';

  @override
  String get settingsNoAddressYet => '아직 주소가 없습니다 — 먼저 설정을 저장하세요';

  @override
  String get settingsInviteLink => '초대 링크';

  @override
  String get settingsRawAddress => '원본 주소';

  @override
  String get settingsCopyLink => '링크 복사';

  @override
  String get settingsCopyAddress => '주소 복사';

  @override
  String get settingsInviteLinkCopied => '초대 링크가 복사됨';

  @override
  String get settingsAppearance => '외관';

  @override
  String get settingsThemeEngine => '테마 엔진';

  @override
  String get settingsThemeEngineSubtitle => '색상 및 글꼴 사용자 정의';

  @override
  String get settingsSignalProtocol => 'Signal 프로토콜';

  @override
  String get settingsSignalProtocolSubtitle => 'E2EE 키가 안전하게 저장됨';

  @override
  String get settingsActive => '활성';

  @override
  String get settingsIdentityBackup => '신원 백업';

  @override
  String get settingsIdentityBackupSubtitle => 'Signal 신원 내보내기 또는 가져오기';

  @override
  String get settingsIdentityBackupBody =>
      'Signal 신원 키를 백업 코드로 내보내거나 기존 코드에서 복원합니다.';

  @override
  String get settingsTransferDevice => '다른 기기로 전송';

  @override
  String get settingsTransferDeviceSubtitle => 'LAN 또는 Nostr 릴레이를 통해 신원 이동';

  @override
  String get settingsExportIdentity => '신원 내보내기';

  @override
  String get settingsExportIdentityBody => '이 백업 코드를 복사하고 안전하게 보관하세요:';

  @override
  String get settingsSaveFile => '파일 저장';

  @override
  String get settingsImportIdentity => '신원 가져오기';

  @override
  String get settingsImportIdentityBody => '아래에 백업 코드를 붙여넣으세요. 현재 신원을 덮어씁니다.';

  @override
  String get settingsPasteBackupCode => '백업 코드를 여기에 붙여넣으세요…';

  @override
  String get settingsIdentityImported => '신원 + 연락처를 가져왔습니다! 앱을 다시 시작하여 적용하세요.';

  @override
  String get settingsSecurity => '보안';

  @override
  String get settingsAppPassword => '앱 비밀번호';

  @override
  String get settingsPasswordEnabled => '활성화됨 — 실행 시마다 필요';

  @override
  String get settingsPasswordDisabled => '비활성화됨 — 비밀번호 없이 열림';

  @override
  String get settingsChangePassword => '비밀번호 변경';

  @override
  String get settingsChangePasswordSubtitle => '앱 잠금 비밀번호 업데이트';

  @override
  String get settingsSetPanicKey => '비상 키 설정';

  @override
  String get settingsChangePanicKey => '비상 키 변경';

  @override
  String get settingsPanicKeySetSubtitle => '긴급 삭제 키 업데이트';

  @override
  String get settingsPanicKeyUnsetSubtitle => '모든 데이터를 즉시 삭제하는 키';

  @override
  String get settingsRemovePanicKey => '비상 키 제거';

  @override
  String get settingsRemovePanicKeySubtitle => '긴급 자가 파괴 비활성화';

  @override
  String get settingsRemovePanicKeyBody =>
      '긴급 자가 파괴가 비활성화됩니다. 언제든지 다시 활성화할 수 있습니다.';

  @override
  String get settingsDisableAppPassword => '앱 비밀번호 비활성화';

  @override
  String get settingsEnterCurrentPassword => '현재 비밀번호를 입력하여 확인하세요';

  @override
  String get settingsCurrentPassword => '현재 비밀번호';

  @override
  String get settingsIncorrectPassword => '잘못된 비밀번호';

  @override
  String get settingsPasswordUpdated => '비밀번호가 업데이트됨';

  @override
  String get settingsChangePasswordProceed => '계속하려면 현재 비밀번호를 입력하세요';

  @override
  String get settingsData => '데이터';

  @override
  String get settingsBackupMessages => '메시지 백업';

  @override
  String get settingsBackupMessagesSubtitle => '암호화된 메시지 기록을 파일로 내보내기';

  @override
  String get settingsRestoreMessages => '메시지 복원';

  @override
  String get settingsRestoreMessagesSubtitle => '백업 파일에서 메시지 가져오기';

  @override
  String get settingsExportKeys => '키 내보내기';

  @override
  String get settingsExportKeysSubtitle => '신원 키를 암호화된 파일로 저장';

  @override
  String get settingsImportKeys => '키 가져오기';

  @override
  String get settingsImportKeysSubtitle => '내보낸 파일에서 신원 키 복원';

  @override
  String get settingsBackupPassword => '백업 비밀번호';

  @override
  String get settingsPasswordCannotBeEmpty => '비밀번호는 비워둘 수 없습니다';

  @override
  String get settingsPasswordMin4Chars => '비밀번호는 최소 4자 이상이어야 합니다';

  @override
  String get settingsCallsTurn => '통화 및 TURN';

  @override
  String get settingsLocalNetwork => '로컬 네트워크';

  @override
  String get settingsCensorshipResistance => '검열 저항';

  @override
  String get settingsNetwork => '네트워크';

  @override
  String get settingsProxyTunnels => '프록시 및 터널';

  @override
  String get settingsTurnServers => 'TURN 서버';

  @override
  String get settingsProviderTitle => '제공자';

  @override
  String get settingsLanFallback => 'LAN 대체';

  @override
  String get settingsLanFallbackSubtitle =>
      '인터넷을 사용할 수 없을 때 로컬 네트워크에서 메시지를 전송합니다. 신뢰할 수 없는 네트워크(공용 Wi-Fi)에서는 비활성화하세요.';

  @override
  String get settingsBgDelivery => '백그라운드 전달';

  @override
  String get settingsBgDeliverySubtitle =>
      '앱이 최소화되어 있을 때도 메시지를 수신합니다. 지속적인 알림이 표시됩니다.';

  @override
  String get settingsYourInboxProvider => '수신 제공자';

  @override
  String get settingsConnectionDetails => '연결 세부 정보';

  @override
  String get settingsSaveAndConnect => '저장 및 연결';

  @override
  String get settingsSecondaryInboxes => '보조 수신함';

  @override
  String get settingsAddSecondaryInbox => '보조 수신함 추가';

  @override
  String get settingsAdvanced => '고급';

  @override
  String get settingsDiscover => '검색';

  @override
  String get settingsAbout => '정보';

  @override
  String get settingsPrivacyPolicy => '개인정보 처리방침';

  @override
  String get settingsPrivacyPolicySubtitle => 'Pulse가 데이터를 보호하는 방법';

  @override
  String get settingsCrashReporting => '충돌 보고';

  @override
  String get settingsCrashReportingSubtitle =>
      'Pulse 개선을 위해 익명 충돌 보고서를 전송합니다. 메시지 내용이나 연락처는 전송되지 않습니다.';

  @override
  String get settingsCrashReportingEnabled => '충돌 보고 활성화됨 — 앱을 다시 시작하여 적용';

  @override
  String get settingsCrashReportingDisabled => '충돌 보고 비활성화됨 — 앱을 다시 시작하여 적용';

  @override
  String get settingsSensitiveOperation => '민감한 작업';

  @override
  String get settingsSensitiveOperationBody =>
      '이 키는 당신의 신원입니다. 이 파일을 가진 사람은 당신을 사칭할 수 있습니다. 안전하게 보관하고 전송 후 삭제하세요.';

  @override
  String get settingsIUnderstandContinue => '이해했습니다, 계속';

  @override
  String get settingsReplaceIdentity => '신원을 교체하시겠습니까?';

  @override
  String get settingsReplaceIdentityBody =>
      '현재 신원 키를 덮어씁니다. 기존 Signal 세션이 무효화되며 연락처가 암호화를 다시 설정해야 합니다. 앱을 다시 시작해야 합니다.';

  @override
  String get settingsReplaceKeys => '키 교체';

  @override
  String get settingsKeysImported => '키 가져오기 완료';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count개의 키를 성공적으로 가져왔습니다. 새 신원으로 다시 초기화하려면 앱을 다시 시작하세요.';
  }

  @override
  String get settingsRestartNow => '지금 다시 시작';

  @override
  String get settingsLater => '나중에';

  @override
  String get profileGroupLabel => '그룹';

  @override
  String get profileAddButton => '추가';

  @override
  String get profileKickButton => '추방';

  @override
  String get dataSectionTitle => '데이터';

  @override
  String get dataBackupMessages => '메시지 백업';

  @override
  String get dataBackupPasswordSubtitle => '메시지 백업을 암호화할 비밀번호를 선택하세요.';

  @override
  String get dataBackupConfirmLabel => '백업 생성';

  @override
  String get dataCreatingBackup => '백업 생성 중';

  @override
  String get dataBackupPreparing => '준비 중...';

  @override
  String dataBackupExporting(int done, int total) {
    return '메시지 $done/$total 내보내는 중...';
  }

  @override
  String get dataBackupSavingFile => '파일 저장 중...';

  @override
  String get dataSaveMessageBackupDialog => '메시지 백업 저장';

  @override
  String dataBackupSaved(int count, String path) {
    return '백업 저장 완료 (메시지 $count개)\n$path';
  }

  @override
  String get dataBackupFailed => '백업 실패 — 내보낸 데이터 없음';

  @override
  String dataBackupFailedError(String error) {
    return '백업 실패: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => '메시지 백업 선택';

  @override
  String get dataInvalidBackupFile => '유효하지 않은 백업 파일 (너무 작음)';

  @override
  String get dataNotValidBackupFile => '유효한 Pulse 백업 파일이 아닙니다';

  @override
  String get dataRestoreMessages => '메시지 복원';

  @override
  String get dataRestorePasswordSubtitle => '이 백업을 생성할 때 사용한 비밀번호를 입력하세요.';

  @override
  String get dataRestoreConfirmLabel => '복원';

  @override
  String get dataRestoringMessages => '메시지 복원 중';

  @override
  String get dataRestoreDecrypting => '복호화 중...';

  @override
  String dataRestoreImporting(int done, int total) {
    return '메시지 $done/$total 가져오는 중...';
  }

  @override
  String get dataRestoreFailed => '복원 실패 — 잘못된 비밀번호 또는 손상된 파일';

  @override
  String dataRestoreSuccess(int count) {
    return '$count개의 새 메시지를 복원했습니다';
  }

  @override
  String get dataRestoreNothingNew => '가져올 새 메시지가 없습니다 (모두 이미 존재)';

  @override
  String dataRestoreFailedError(String error) {
    return '복원 실패: $error';
  }

  @override
  String get dataSelectKeyExportDialog => '키 내보내기 선택';

  @override
  String get dataNotValidKeyFile => '유효한 Pulse 키 내보내기 파일이 아닙니다';

  @override
  String get dataExportKeys => '키 내보내기';

  @override
  String get dataExportKeysPasswordSubtitle => '키 내보내기를 암호화할 비밀번호를 선택하세요.';

  @override
  String get dataExportKeysConfirmLabel => '내보내기';

  @override
  String get dataExportingKeys => '키 내보내기 중';

  @override
  String get dataExportingKeysStatus => '신원 키 암호화 중...';

  @override
  String get dataSaveKeyExportDialog => '키 내보내기 저장';

  @override
  String dataKeysExportedTo(String path) {
    return '키를 다음 위치에 내보냈습니다:\n$path';
  }

  @override
  String get dataExportFailed => '내보내기 실패 — 키를 찾을 수 없음';

  @override
  String dataExportFailedError(String error) {
    return '내보내기 실패: $error';
  }

  @override
  String get dataImportKeys => '키 가져오기';

  @override
  String get dataImportKeysPasswordSubtitle =>
      '이 키 내보내기를 암호화할 때 사용한 비밀번호를 입력하세요.';

  @override
  String get dataImportKeysConfirmLabel => '가져오기';

  @override
  String get dataImportingKeys => '키 가져오기 중';

  @override
  String get dataImportingKeysStatus => '신원 키 복호화 중...';

  @override
  String get dataImportFailed => '가져오기 실패 — 잘못된 비밀번호 또는 손상된 파일';

  @override
  String dataImportFailedError(String error) {
    return '가져오기 실패: $error';
  }

  @override
  String get securitySectionTitle => '보안';

  @override
  String get securityIncorrectPassword => '잘못된 비밀번호';

  @override
  String get securityPasswordUpdated => '비밀번호가 업데이트됨';

  @override
  String get appearanceSectionTitle => '외관';

  @override
  String appearanceExportFailed(String error) {
    return '내보내기 실패: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return '$path에 저장됨';
  }

  @override
  String appearanceSaveFailed(String error) {
    return '저장 실패: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return '가져오기 실패: $error';
  }

  @override
  String get aboutSectionTitle => '정보';

  @override
  String get providerPublicKey => '공개 키';

  @override
  String get providerRelay => '릴레이';

  @override
  String get providerAutoConfigured => '복구 비밀번호에서 자동 구성됨. 릴레이 자동 검색됨.';

  @override
  String get providerKeyStoredLocally =>
      '키는 안전한 저장소에 로컬로 저장됩니다 — 어떤 서버로도 전송되지 않습니다.';

  @override
  String get providerSessionInfo =>
      'Session Network — 양파 라우팅 E2EE. 귀하의 Session ID는 자동으로 생성되어 안전하게 저장됩니다. 노드는 내장된 시드 노드에서 자동으로 검색됩니다.';

  @override
  String get providerAdvanced => '고급';

  @override
  String get providerSaveAndConnect => '저장 및 연결';

  @override
  String get providerAddSecondaryInbox => '보조 수신함 추가';

  @override
  String get providerSecondaryInboxes => '보조 수신함';

  @override
  String get providerYourInboxProvider => '수신 제공자';

  @override
  String get providerConnectionDetails => '연결 세부 정보';

  @override
  String get addContactTitle => '연락처 추가';

  @override
  String get addContactInviteLinkLabel => '초대 링크 또는 주소';

  @override
  String get addContactTapToPaste => '탭하여 초대 링크 붙여넣기';

  @override
  String get addContactPasteTooltip => '클립보드에서 붙여넣기';

  @override
  String get addContactAddressDetected => '연락처 주소 감지됨';

  @override
  String addContactRoutesDetected(int count) {
    return '$count개의 경로 감지됨 — SmartRouter가 가장 빠른 경로를 선택합니다';
  }

  @override
  String get addContactFetchingProfile => '프로필 가져오는 중…';

  @override
  String addContactProfileFound(String name) {
    return '발견: $name';
  }

  @override
  String get addContactNoProfileFound => '프로필을 찾을 수 없음';

  @override
  String get addContactDisplayNameLabel => '표시 이름';

  @override
  String get addContactDisplayNameHint => '어떻게 부르시겠습니까?';

  @override
  String get addContactAddManually => '주소를 수동으로 추가';

  @override
  String get addContactButton => '연락처 추가';

  @override
  String get networkDiagnosticsTitle => '네트워크 진단';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr 릴레이';

  @override
  String get networkDiagnosticsDirect => '직접';

  @override
  String get networkDiagnosticsTorOnly => 'Tor 전용';

  @override
  String get networkDiagnosticsBest => '최적';

  @override
  String get networkDiagnosticsNone => '없음';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => '상태';

  @override
  String get networkDiagnosticsConnected => '연결됨';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return '연결 중 $percent%';
  }

  @override
  String get networkDiagnosticsOff => '꺼짐';

  @override
  String get networkDiagnosticsTransport => '전송 방식';

  @override
  String get networkDiagnosticsInfrastructure => '인프라';

  @override
  String get networkDiagnosticsSessionNodes => 'Session 노드';

  @override
  String get networkDiagnosticsTurnServers => 'TURN 서버';

  @override
  String get networkDiagnosticsLastProbe => '마지막 탐색';

  @override
  String get networkDiagnosticsRunning => '실행 중...';

  @override
  String get networkDiagnosticsRunDiagnostics => '진단 실행';

  @override
  String get networkDiagnosticsForceReprobe => '전체 재탐색 강제 실행';

  @override
  String get networkDiagnosticsJustNow => '방금';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes분 전';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours시간 전';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days일 전';
  }

  @override
  String get homeNoEch => 'ECH 없음';

  @override
  String get homeNoEchTooltip =>
      'uTLS 프록시를 사용할 수 없습니다 — ECH 비활성화됨.\nTLS 지문이 DPI에 노출됩니다.';

  @override
  String get settingsTitle => '설정';

  @override
  String settingsSavedConnectedTo(String provider) {
    return '$provider에 저장 및 연결됨';
  }

  @override
  String get settingsTorFailedToStart => '내장 Tor 시작 실패';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon 시작 실패';

  @override
  String get verifyTitle => '안전 번호 확인';

  @override
  String get verifyIdentityVerified => '신원 확인됨';

  @override
  String get verifyNotYetVerified => '아직 확인되지 않음';

  @override
  String verifyVerifiedDescription(String name) {
    return '$name님의 안전 번호를 확인했습니다.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return '$name님과 직접 만나거나 신뢰할 수 있는 채널을 통해 이 번호를 비교하세요.';
  }

  @override
  String get verifyExplanation =>
      '각 대화에는 고유한 안전 번호가 있습니다. 양쪽 기기에서 같은 번호가 표시되면 연결이 종단 간으로 확인된 것입니다.';

  @override
  String verifyContactKey(String name) {
    return '$name님의 키';
  }

  @override
  String get verifyYourKey => '나의 키';

  @override
  String get verifyRemoveVerification => '확인 제거';

  @override
  String get verifyMarkAsVerified => '확인됨으로 표시';

  @override
  String verifyAfterReinstall(String name) {
    return '$name님이 앱을 다시 설치하면 안전 번호가 변경되고 확인이 자동으로 제거됩니다.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return '$name님과 음성 통화 또는 직접 만나서 번호를 비교한 후에만 확인됨으로 표시하세요.';
  }

  @override
  String get verifyNoSession =>
      '아직 암호화 세션이 설정되지 않았습니다. 먼저 메시지를 보내서 안전 번호를 생성하세요.';

  @override
  String get verifyNoKeyAvailable => '사용 가능한 키 없음';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label 지문이 복사됨';
  }

  @override
  String get providerDatabaseUrlLabel => '데이터베이스 URL';

  @override
  String get providerOptionalHint => '선택 사항';

  @override
  String get providerWebApiKeyLabel => 'Web API 키';

  @override
  String get providerOptionalForPublicDb => '공개 DB에는 선택 사항';

  @override
  String get providerRelayUrlLabel => '릴레이 URL';

  @override
  String get providerPrivateKeyLabel => '개인 키';

  @override
  String get providerPrivateKeyNsecLabel => '개인 키 (nsec)';

  @override
  String get providerStorageNodeLabel => '스토리지 노드 URL (선택 사항)';

  @override
  String get providerStorageNodeHint => '내장 시드 노드를 위해 비워두세요';

  @override
  String get transferInvalidCodeFormat =>
      '인식할 수 없는 코드 형식 — LAN: 또는 NOS:로 시작해야 합니다';

  @override
  String get profileCardFingerprintCopied => '지문이 복사됨';

  @override
  String get profileCardAboutHint => '프라이버시 우선 🔒';

  @override
  String get profileCardSaveButton => '프로필 저장';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      '암호화된 메시지, 연락처 및 아바타를 파일로 내보내기';

  @override
  String get callVideo => '영상';

  @override
  String get callAudio => '음성';

  @override
  String bubbleDeliveredTo(String names) {
    return '$names에게 전달됨';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return '$count명에게 전달됨';
  }

  @override
  String get groupStatusDialogTitle => '메시지 정보';

  @override
  String get groupStatusRead => '읽음';

  @override
  String get groupStatusDelivered => '전달됨';

  @override
  String get groupStatusPending => '대기 중';

  @override
  String get groupStatusNoData => '아직 전달 정보가 없습니다';

  @override
  String get profileTransferAdmin => '관리자 지정';

  @override
  String profileTransferAdminConfirm(String name) {
    return '$name님을 새 관리자로 지정하시겠습니까?';
  }

  @override
  String get profileTransferAdminBody => '관리자 권한을 잃게 됩니다. 이 작업은 되돌릴 수 없습니다.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name님이 이제 관리자입니다';
  }

  @override
  String get profileAdminBadge => '관리자';

  @override
  String get privacyPolicyTitle => '개인정보 처리방침';

  @override
  String get privacyOverviewHeading => '개요';

  @override
  String get privacyOverviewBody =>
      'Pulse는 서버 없는 종단 간 암호화 메신저입니다. 프라이버시는 단순한 기능이 아니라 아키텍처입니다. Pulse 서버는 없습니다. 어디에도 계정이 저장되지 않습니다. 개발자가 어떤 데이터도 수집, 전송 또는 저장하지 않습니다.';

  @override
  String get privacyDataCollectionHeading => '데이터 수집';

  @override
  String get privacyDataCollectionBody =>
      'Pulse는 개인 데이터를 전혀 수집하지 않습니다. 구체적으로:\n\n- 이메일, 전화번호 또는 실명이 필요하지 않습니다\n- 분석, 추적 또는 원격 측정이 없습니다\n- 광고 식별자가 없습니다\n- 연락처 목록에 접근하지 않습니다\n- 클라우드 백업이 없습니다(메시지는 기기에만 존재)\n- Pulse 서버로 메타데이터가 전송되지 않습니다(서버가 없음)';

  @override
  String get privacyEncryptionHeading => '암호화';

  @override
  String get privacyEncryptionBody =>
      '모든 메시지는 Signal 프로토콜(X3DH 키 합의를 사용한 Double Ratchet)로 암호화됩니다. 암호화 키는 기기에서만 생성되고 저장됩니다. 개발자를 포함하여 아무도 메시지를 읽을 수 없습니다.';

  @override
  String get privacyNetworkHeading => '네트워크 아키텍처';

  @override
  String get privacyNetworkBody =>
      'Pulse는 연합 전송 어댑터(Nostr 릴레이, Session/Oxen 서비스 노드, Firebase Realtime Database, LAN)를 사용합니다. 이 전송 수단은 암호화된 암호문만 전달합니다. 릴레이 운영자는 IP 주소와 트래픽 양을 볼 수 있지만 메시지 내용을 복호화할 수 없습니다.\n\nTor가 활성화되면 릴레이 운영자에게 IP 주소도 숨겨집니다.';

  @override
  String get privacyStunHeading => 'STUN/TURN 서버';

  @override
  String get privacyStunBody =>
      '음성 및 영상 통화는 DTLS-SRTP 암호화를 사용하는 WebRTC를 사용합니다. STUN 서버(P2P 연결을 위한 공인 IP 검색)와 TURN 서버(직접 연결 실패 시 미디어 릴레이)는 IP 주소와 통화 시간을 볼 수 있지만 통화 내용을 복호화할 수 없습니다.\n\n최대 프라이버시를 위해 설정에서 자체 TURN 서버를 구성할 수 있습니다.';

  @override
  String get privacyCrashHeading => '충돌 보고';

  @override
  String get privacyCrashBody =>
      'Sentry 충돌 보고가 활성화되면(빌드 시 SENTRY_DSN을 통해) 익명 충돌 보고서가 전송될 수 있습니다. 메시지 내용, 연락처 정보 또는 개인 식별 정보는 포함되지 않습니다. 충돌 보고는 DSN을 생략하여 빌드 시 비활성화할 수 있습니다.';

  @override
  String get privacyPasswordHeading => '비밀번호 및 키';

  @override
  String get privacyPasswordBody =>
      '복구 비밀번호는 Argon2id(메모리-하드 KDF)를 통해 암호화 키를 파생하는 데 사용됩니다. 비밀번호는 어디로도 전송되지 않습니다. 비밀번호를 분실하면 계정을 복구할 수 없습니다 — 재설정할 서버가 없습니다.';

  @override
  String get privacyFontsHeading => '글꼴';

  @override
  String get privacyFontsBody =>
      'Pulse는 모든 글꼴을 로컬에 번들합니다. Google Fonts나 외부 글꼴 서비스에 요청하지 않습니다.';

  @override
  String get privacyThirdPartyHeading => '서드파티 서비스';

  @override
  String get privacyThirdPartyBody =>
      'Pulse는 광고 네트워크, 분석 제공업체, 소셜 미디어 플랫폼 또는 데이터 브로커와 통합되지 않습니다. 유일한 네트워크 연결은 사용자가 구성한 전송 릴레이뿐입니다.';

  @override
  String get privacyOpenSourceHeading => '오픈 소스';

  @override
  String get privacyOpenSourceBody =>
      'Pulse는 오픈 소스 소프트웨어입니다. 전체 소스 코드를 감사하여 이 프라이버시 주장을 확인할 수 있습니다.';

  @override
  String get privacyContactHeading => '연락처';

  @override
  String get privacyContactBody => '프라이버시 관련 질문은 프로젝트 저장소에 이슈를 등록하세요.';

  @override
  String get privacyLastUpdated => '최종 업데이트: 2026년 3월';

  @override
  String imageSaveFailed(Object error) {
    return '저장 실패: $error';
  }

  @override
  String get themeEngineTitle => '테마 엔진';

  @override
  String get torBuiltInTitle => '내장 Tor';

  @override
  String get torConnectedSubtitle => '연결됨 — Nostr가 127.0.0.1:9250을 통해 라우팅됨';

  @override
  String torConnectingSubtitle(int pct) {
    return '연결 중… $pct%';
  }

  @override
  String get torNotRunning => '실행되지 않음 — 스위치를 탭하여 재시작';

  @override
  String get torDescription => 'Tor를 통해 Nostr를 라우팅합니다 (검열된 네트워크용 Snowflake)';

  @override
  String get torNetworkDiagnostics => '네트워크 진단';

  @override
  String get torTransportLabel => '전송 방식: ';

  @override
  String get torPtAuto => '자동';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => '일반';

  @override
  String get torTimeoutLabel => '시간 초과: ';

  @override
  String get torInfoDescription =>
      '활성화하면 Nostr WebSocket 연결이 Tor(SOCKS5)를 통해 라우팅됩니다. Tor Browser는 127.0.0.1:9150에서 수신합니다. 독립 실행형 tor 데몬은 포트 9050을 사용합니다. Firebase 연결은 영향을 받지 않습니다.';

  @override
  String get torRouteNostrTitle => 'Tor를 통해 Nostr 라우팅';

  @override
  String get torManagedByBuiltin => '내장 Tor에 의해 관리됨';

  @override
  String get torActiveRouting => '활성 — Nostr 트래픽이 Tor를 통해 라우팅됨';

  @override
  String get torDisabled => '비활성화됨';

  @override
  String get torProxySocks5 => 'Tor 프록시 (SOCKS5)';

  @override
  String get torProxyHostLabel => '프록시 호스트';

  @override
  String get torProxyPortLabel => '포트';

  @override
  String get torPortInfo => 'Tor Browser: 포트 9150  •  tor 데몬: 포트 9050';

  @override
  String get torForceNostrTitle => '메시지를 Tor를 통해 전송';

  @override
  String get torForceNostrSubtitle =>
      '모든 Nostr 릴레이 연결이 Tor를 통해 이루어집니다. 느리지만 릴레이로부터 IP를 숨깁니다.';

  @override
  String get torForceNostrDisabled => '먼저 Tor를 활성화해야 합니다';

  @override
  String get torForcePulseTitle => 'Pulse 릴레이를 Tor를 통해 연결';

  @override
  String get torForcePulseSubtitle =>
      '모든 Pulse 릴레이 연결이 Tor를 통해 이루어집니다. 느리지만 서버로부터 IP를 숨깁니다.';

  @override
  String get torForcePulseDisabled => '먼저 Tor를 활성화해야 합니다';

  @override
  String get i2pProxySocks5 => 'I2P 프록시 (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P는 기본적으로 포트 4447에서 SOCKS5를 사용합니다. I2P 아웃프록시(예: relay.damus.i2p)를 통해 Nostr 릴레이에 연결하여 모든 전송 수단의 사용자와 통신합니다. 둘 다 활성화되면 Tor가 우선합니다.';

  @override
  String get i2pRouteNostrTitle => 'I2P를 통해 Nostr 라우팅';

  @override
  String get i2pActiveRouting => '활성 — Nostr 트래픽이 I2P를 통해 라우팅됨';

  @override
  String get i2pDisabled => '비활성화됨';

  @override
  String get i2pProxyHostLabel => '프록시 호스트';

  @override
  String get i2pProxyPortLabel => '포트';

  @override
  String get i2pPortInfo => 'I2P 라우터 기본 SOCKS5 포트: 4447';

  @override
  String get customProxySocks5 => '사용자 정의 프록시 (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker 릴레이';

  @override
  String get customProxyInfoDescription =>
      '사용자 정의 프록시는 V2Ray/Xray/Shadowsocks를 통해 트래픽을 라우팅합니다. CF Worker는 Cloudflare CDN에서 개인 릴레이 프록시 역할을 합니다 — GFW는 실제 릴레이가 아닌 *.workers.dev를 봅니다.';

  @override
  String get customSocks5ProxyTitle => '사용자 정의 SOCKS5 프록시';

  @override
  String get customProxyActive => '활성 — SOCKS5를 통해 트래픽 라우팅됨';

  @override
  String get customProxyDisabled => '비활성화됨';

  @override
  String get customProxyHostLabel => '프록시 호스트';

  @override
  String get customProxyPortLabel => '포트';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker 도메인 (선택 사항)';

  @override
  String get customWorkerHelpTitle => 'CF Worker 릴레이 배포 방법 (무료)';

  @override
  String get customWorkerScriptCopied => '스크립트가 복사되었습니다!';

  @override
  String get customWorkerStep1 =>
      '1. dash.cloudflare.com → Workers & Pages로 이동\n2. Worker 만들기 → 이 스크립트를 붙여넣기:\n';

  @override
  String get customWorkerStep2 =>
      '3. 배포 → 도메인 복사 (예: my-relay.user.workers.dev)\n4. 위에 도메인 붙여넣기 → 저장\n\n앱 자동 연결: wss://domain/?r=relay_url\nGFW가 보는 것: *.workers.dev(CF CDN)로의 연결';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return '연결됨 — SOCKS5 on 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => '연결 중…';

  @override
  String get psiphonNotRunning => '실행되지 않음 — 스위치를 탭하여 재시작';

  @override
  String get psiphonDescription => '빠른 터널 (~3초 부트스트랩, 2000개 이상의 순환 VPS)';

  @override
  String get turnCommunityServers => '커뮤니티 TURN 서버';

  @override
  String get turnCustomServer => '사용자 정의 TURN 서버 (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN 서버는 이미 암호화된 스트림(DTLS-SRTP)만 릴레이합니다. 릴레이 운영자는 IP와 트래픽 양을 볼 수 있지만 통화를 복호화할 수 없습니다. TURN은 직접 P2P가 실패할 때만 사용됩니다(연결의 약 15–20%).';

  @override
  String get turnFreeLabel => '무료';

  @override
  String get turnServerUrlLabel => 'TURN 서버 URL';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 또는 turns:...';

  @override
  String get turnUsernameLabel => '사용자 이름';

  @override
  String get turnPasswordLabel => '비밀번호';

  @override
  String get turnOptionalHint => '선택 사항';

  @override
  String get turnCustomInfo =>
      '최대 제어를 위해 \$5/월 VPS에 coturn을 자체 호스팅하세요. 자격 증명은 로컬에 저장됩니다.';

  @override
  String get themePickerAppearance => '외관';

  @override
  String get themePickerAccentColor => '강조 색상';

  @override
  String get themeModeLight => '밝게';

  @override
  String get themeModeDark => '어둡게';

  @override
  String get themeModeSystem => '시스템';

  @override
  String get themeDynamicPresets => '프리셋';

  @override
  String get themeDynamicPrimaryColor => '기본 색상';

  @override
  String get themeDynamicBorderRadius => '모서리 반경';

  @override
  String get themeDynamicFont => '글꼴';

  @override
  String get themeDynamicAppearance => '외관';

  @override
  String get themeDynamicUiStyle => 'UI 스타일';

  @override
  String get themeDynamicUiStyleDescription => '대화 상자, 스위치 및 인디케이터의 모양을 제어합니다.';

  @override
  String get themeDynamicSharp => '날카롭게';

  @override
  String get themeDynamicRound => '둥글게';

  @override
  String get themeDynamicModeDark => '어둡게';

  @override
  String get themeDynamicModeLight => '밝게';

  @override
  String get themeDynamicModeAuto => '자동';

  @override
  String get themeDynamicPlatformAuto => '자동';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      '잘못된 Firebase URL입니다. https://project.firebaseio.com 형식이어야 합니다';

  @override
  String get providerErrorInvalidRelayUrl =>
      '잘못된 릴레이 URL입니다. wss://relay.example.com 형식이어야 합니다';

  @override
  String get providerErrorInvalidPulseUrl =>
      '잘못된 Pulse 서버 URL입니다. https://server:port 형식이어야 합니다';

  @override
  String get providerPulseServerUrlLabel => '서버 URL';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => '초대 코드';

  @override
  String get providerPulseInviteHint => '초대 코드 (필요한 경우)';

  @override
  String get providerPulseInfo => '자체 호스팅 릴레이. 복구 비밀번호에서 키가 파생됩니다.';

  @override
  String get providerScreenTitle => '수신함';

  @override
  String get providerSecondaryInboxesHeader => '보조 수신함';

  @override
  String get providerSecondaryInboxesInfo => '보조 수신함은 이중화를 위해 동시에 메시지를 수신합니다.';

  @override
  String get providerRemoveTooltip => '삭제';

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
  String get emojiNoRecent => '최근 이모지 없음';

  @override
  String get emojiSearchHint => '이모지 검색...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => '탭하여 대화';

  @override
  String get imageViewerSaveToDownloads => 'Downloads에 저장';

  @override
  String imageViewerSavedTo(String path) {
    return '$path에 저장됨';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => '확인';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsLanguageSubtitle => '앱 표시 언어';

  @override
  String get settingsLanguageSystem => '시스템 기본값';

  @override
  String get onboardingLanguageTitle => '언어 선택';

  @override
  String get onboardingLanguageSubtitle => '나중에 설정에서 변경할 수 있습니다';

  @override
  String get videoNoteRecord => '동영상 메시지 녹화';

  @override
  String get videoNoteTapToRecord => '탭하여 녹화';

  @override
  String get videoNoteTapToStop => '탭하여 중지';

  @override
  String get videoNoteCameraPermission => '카메라 권한이 거부되었습니다';

  @override
  String get videoNoteMaxDuration => '최대 30초';

  @override
  String get videoNoteNotSupported => '이 플랫폼에서는 동영상 노트를 지원하지 않습니다';

  @override
  String get navChats => '채팅';

  @override
  String get navUpdates => '업데이트';

  @override
  String get navCalls => '통화';

  @override
  String get filterAll => '전체';

  @override
  String get filterUnread => '읽지 않음';

  @override
  String get filterGroups => '그룹';

  @override
  String get callsNoRecent => '최근 통화 없음';

  @override
  String get callsEmptySubtitle => '통화 기록이 여기에 표시됩니다';

  @override
  String get appBarEncrypted => '종단 간 암호화';

  @override
  String get newStatus => '새 상태';

  @override
  String get newCall => '새 통화';

  @override
  String get joinChannelTitle => '채널 참여';

  @override
  String get joinChannelDescription => '채널 URL';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => '채널 정보 가져오는 중…';

  @override
  String get joinChannelNotFound => '이 URL에서 채널을 찾을 수 없습니다';

  @override
  String get joinChannelNetworkError => '서버에 연결할 수 없습니다';

  @override
  String get joinChannelAlreadyJoined => '이미 참여함';

  @override
  String get joinChannelButton => '참여';

  @override
  String get channelFeedEmpty => '아직 게시물이 없습니다';

  @override
  String get channelLeave => '채널 나가기';

  @override
  String get channelLeaveConfirm => '이 채널을 나가시겠습니까? 캐시된 게시물이 삭제됩니다.';

  @override
  String get channelInfo => '채널 정보';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => '수정됨';

  @override
  String get channelLoadMore => '더 불러오기';

  @override
  String get channelSearchPosts => '게시물 검색…';

  @override
  String get channelNoResults => '일치하는 게시물 없음';

  @override
  String get channelUrl => '채널 URL';

  @override
  String get channelCreated => '가입됨';

  @override
  String channelPostCount(int count) {
    return '$count개 게시물';
  }

  @override
  String get channelCopyUrl => 'URL 복사';

  @override
  String get setupNext => '다음';

  @override
  String get setupKeyWarning =>
      '복구 키가 생성됩니다. 새 기기에서 계정을 복원하는 유일한 방법입니다 — 서버도, 비밀번호 재설정도 없습니다.';

  @override
  String get setupKeyTitle => '복구 키';

  @override
  String get setupKeySubtitle =>
      '이 키를 적어서 안전한 곳에 보관하세요. 새 기기에서 계정을 복원할 때 필요합니다.';

  @override
  String get setupKeyCopied => '복사됨!';

  @override
  String get setupKeyWroteItDown => '적어 두었습니다';

  @override
  String get setupKeyWarnBody => '이 키를 백업으로 적어 두세요. 나중에 설정 → 보안에서도 확인할 수 있습니다.';

  @override
  String get setupVerifyTitle => '복구 키 확인';

  @override
  String get setupVerifySubtitle => '올바르게 저장했는지 확인하기 위해 복구 키를 다시 입력하세요.';

  @override
  String get setupVerifyButton => '확인';

  @override
  String get setupKeyMismatch => '키가 일치하지 않습니다. 확인 후 다시 시도하세요.';

  @override
  String get setupSkipVerify => '확인 건너뛰기';

  @override
  String get setupSkipVerifyTitle => '확인을 건너뛸까요?';

  @override
  String get setupSkipVerifyBody => '복구 키를 분실하면 계정을 복원할 수 없습니다. 확실합니까?';

  @override
  String get setupCreatingAccount => '계정 생성 중…';

  @override
  String get setupRestoringAccount => '계정 복원 중…';

  @override
  String get restoreKeyInfoBanner =>
      '복구 키를 입력하세요 — 주소(Nostr + Session)가 자동으로 복원됩니다. 연락처와 메시지는 로컬에만 저장되었습니다.';

  @override
  String get restoreKeyHint => '복구 키';

  @override
  String get settingsViewRecoveryKey => '복구 키 보기';

  @override
  String get settingsViewRecoveryKeySubtitle => '계정 복구 키 표시';

  @override
  String get settingsRecoveryKeyNotStored => '복구 키를 사용할 수 없습니다 (이 기능 이전에 생성됨)';

  @override
  String get settingsRecoveryKeyWarning =>
      '이 키를 안전하게 보관하세요. 이 키를 가진 사람은 다른 기기에서 계정을 복원할 수 있습니다.';

  @override
  String get replaceIdentityTitle => '기존 ID를 교체하시겠습니까?';

  @override
  String get replaceIdentityBodyRestore =>
      '이 기기에 이미 ID가 있습니다. 복원하면 현재 Nostr 키와 Oxen 시드가 영구적으로 교체됩니다. 모든 연락처가 현재 주소로 연락할 수 없게 됩니다.\n\n이 작업은 되돌릴 수 없습니다.';

  @override
  String get replaceIdentityBodyCreate =>
      '이 기기에 이미 ID가 있습니다. 새 ID를 만들면 현재 Nostr 키와 Oxen 시드가 영구적으로 교체됩니다. 모든 연락처가 현재 주소로 연락할 수 없게 됩니다.\n\n이 작업은 되돌릴 수 없습니다.';

  @override
  String get replace => '교체';

  @override
  String get callNoScreenSources => '사용 가능한 화면 소스가 없습니다';

  @override
  String get callScreenShareQuality => '화면 공유 품질';

  @override
  String get callFrameRate => '프레임 속도';

  @override
  String get callResolution => '해상도';

  @override
  String get callAutoResolution => '자동 = 기본 화면 해상도';

  @override
  String get callStartSharing => '공유 시작';

  @override
  String get callCameraUnavailable => '카메라를 사용할 수 없습니다 — 다른 앱에서 사용 중일 수 있습니다';

  @override
  String get themeResetToDefaults => '기본값으로 재설정';

  @override
  String get backupSaveToDownloadsTitle => '다운로드에 백업을 저장하시겠습니까?';

  @override
  String backupSaveToDownloadsBody(String path) {
    return '파일 선택기를 사용할 수 없습니다. 백업이 다음 위치에 저장됩니다:\n$path';
  }

  @override
  String get systemLabel => '시스템';

  @override
  String get next => '다음';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return '개발자 모드를 활성화하려면 $remaining번 더 탭하세요';
  }

  @override
  String get devModeEnabled => '개발자 모드가 활성화되었습니다';

  @override
  String get devTools => '개발자 도구';

  @override
  String get devAdapterDiagnostics => '어댑터 전환 및 진단';

  @override
  String get devEnableAll => '모두 활성화';

  @override
  String get devDisableAll => '모두 비활성화';

  @override
  String get turnUrlValidation =>
      'TURN URL은 turn: 또는 turns:로 시작해야 합니다 (최대 512자)';

  @override
  String get callMissedCall => '부재중 전화';

  @override
  String get callOutgoingCall => '발신 전화';

  @override
  String get callIncomingCall => '수신 전화';

  @override
  String get mediaMissingData => '미디어 데이터 누락';

  @override
  String get mediaDownloadFailed => '다운로드 실패';

  @override
  String get mediaDecryptFailed => '복호화 실패';

  @override
  String get callEndCallBanner => '통화 종료';

  @override
  String get meFallback => '나';

  @override
  String get imageSaveToDownloads => '다운로드에 저장';

  @override
  String imageSavedToPath(String path) {
    return '$path에 저장됨';
  }

  @override
  String get callScreenShareRequiresPermission => '화면 공유에는 권한이 필요합니다';

  @override
  String get callScreenShareUnavailable => '화면 공유를 사용할 수 없습니다';

  @override
  String get statusJustNow => '방금';

  @override
  String statusMinutesAgo(int minutes) {
    return '$minutes분 전';
  }

  @override
  String statusHoursAgo(int hours) {
    return '$hours시간 전';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 경로',
      one: '1개 경로',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => '추가 준비 완료';

  @override
  String groupSelectedCount(int count) {
    return '$count명 선택됨';
  }

  @override
  String get paste => '붙여넣기';

  @override
  String get sfuAudioOnly => '오디오만';

  @override
  String sfuParticipants(int count) {
    return '참가자 $count명';
  }

  @override
  String get dataUnencryptedBackup => '암호화되지 않은 백업';

  @override
  String get dataUnencryptedBackupBody =>
      '이 파일은 암호화되지 않은 ID 백업이며 현재 키를 덮어씁니다. 본인이 만든 파일만 가져오세요. 계속하시겠습니까?';

  @override
  String get dataImportAnyway => '그래도 가져오기';

  @override
  String get securityStorageError => '보안 저장소 오류 — 앱을 재시작하세요';

  @override
  String get aboutDevModeActive => '개발자 모드 활성';

  @override
  String get themeColors => '색상';

  @override
  String get themePrimaryAccent => '기본 강조색';

  @override
  String get themeSecondaryAccent => '보조 강조색';

  @override
  String get themeBackground => '배경';

  @override
  String get themeSurface => '표면';

  @override
  String get themeChatBubbles => '채팅 말풍선';

  @override
  String get themeOutgoingMessage => '발신 메시지';

  @override
  String get themeIncomingMessage => '수신 메시지';

  @override
  String get themeShape => '모양';

  @override
  String get devSectionDeveloper => '개발자';

  @override
  String get devAdapterChannelsHint => '어댑터 채널 — 특정 전송을 테스트하려면 비활성화하세요.';

  @override
  String get devNostrRelays => 'Nostr 릴레이 (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Session 네트워크';

  @override
  String get devPulseRelay => 'Pulse 자체 호스팅 릴레이';

  @override
  String get devLanNetwork => '로컬 네트워크 (UDP/TCP)';

  @override
  String get devSectionCalls => '통화';

  @override
  String get devForceTurnRelay => 'TURN 릴레이 강제';

  @override
  String get devForceTurnRelaySubtitle => 'P2P 비활성화 — 모든 통화를 TURN 서버로만';

  @override
  String get devRestartWarning =>
      '⚠ 변경 사항은 다음 전송/통화 시 적용됩니다. 수신에 적용하려면 앱을 재시작하세요.';

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
  String get pulseUseServerTitle => 'Pulse 서버를 사용하시겠어요?';

  @override
  String pulseUseServerBody(String name, String host) {
    return '$name 님은 Pulse 서버 $host 를 사용합니다. 참가해서 더 빠르게 대화하시겠어요? (같은 서버의 다른 사용자와도)';
  }

  @override
  String pulseContactUsesPulse(String name) {
    return '$name 님이 Pulse 사용 중';
  }

  @override
  String pulseJoinForFaster(String host) {
    return '$host 에 참가하여 더 빠른 채팅';
  }

  @override
  String get pulseNotNow => '나중에';

  @override
  String get pulseJoin => '참가';

  @override
  String get pulseDismiss => '닫기';

  @override
  String get pulseHide7Days => '7일 동안 숨기기';

  @override
  String get pulseNeverAskAgain => '다시 묻지 않기';

  @override
  String get groupSearchContactsHint => '연락처 검색…';

  @override
  String get systemActorYou => '나';

  @override
  String get systemActorPeer => '상대방';

  @override
  String systemTtlEnabled(String actor, String duration) {
    return '$actor님이 사라지는 메시지를 켰습니다: $duration';
  }

  @override
  String systemTtlDisabled(String actor) {
    return '$actor님이 사라지는 메시지를 껐습니다';
  }

  @override
  String get menuClearChatHistory => '채팅 기록 지우기';

  @override
  String get clearChatTitle => '채팅 기록을 지우시겠어요?';

  @override
  String get clearChatBody => '이 채팅의 모든 메시지가 이 기기에서 삭제됩니다. 상대방은 자신의 사본을 유지합니다.';

  @override
  String get clearChatAction => '지우기';

  @override
  String systemGroupRenamed(String actor, String name) {
    return '$actor님이 그룹 이름을 \"$name\"(으)로 변경했습니다';
  }

  @override
  String systemGroupAvatarChanged(String actor) {
    return '$actor님이 그룹 사진을 변경했습니다';
  }

  @override
  String systemGroupMetaChanged(String actor, String name) {
    return '$actor님이 그룹 이름을 \"$name\"(으)로 변경하고 사진도 변경했습니다';
  }

  @override
  String get profileInviteLink => '초대 링크';

  @override
  String get profileInviteLinkSubtitle => '링크가 있는 누구나 참여할 수 있습니다';

  @override
  String get profileInviteLinkCopied => '초대 링크가 클립보드에 복사되었습니다';

  @override
  String get groupInviteLinkTitle => '그룹에 참여하시겠어요?';

  @override
  String groupInviteLinkBody(String name, int count) {
    return '\"$name\" 그룹($count명)에 초대되었습니다.';
  }

  @override
  String get groupInviteLinkJoin => '참여';

  @override
  String get drawerJoinGroupByLink => '링크로 그룹 참여';

  @override
  String get drawerJoinGroupByLinkInvalid => 'Pulse 초대 링크처럼 보이지 않습니다';
}
