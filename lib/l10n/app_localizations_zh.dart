// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => '搜索消息...';

  @override
  String get search => '搜索';

  @override
  String get clearSearch => '清除搜索';

  @override
  String get closeSearch => '关闭搜索';

  @override
  String get moreOptions => '更多选项';

  @override
  String get back => '返回';

  @override
  String get cancel => '取消';

  @override
  String get close => '关闭';

  @override
  String get confirm => '确认';

  @override
  String get remove => '移除';

  @override
  String get save => '保存';

  @override
  String get add => '添加';

  @override
  String get copy => '复制';

  @override
  String get skip => '跳过';

  @override
  String get done => '完成';

  @override
  String get apply => '应用';

  @override
  String get export => '导出';

  @override
  String get import => '导入';

  @override
  String get homeNewGroup => '新建群组';

  @override
  String get homeSettings => '设置';

  @override
  String get homeSearching => '正在搜索消息...';

  @override
  String get homeNoResults => '未找到结果';

  @override
  String get homeNoChatHistory => '暂无聊天记录';

  @override
  String homeTransportSwitched(String address) {
    return '传输已切换 → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name 正在呼叫...';
  }

  @override
  String get homeAccept => '接听';

  @override
  String get homeDecline => '拒绝';

  @override
  String get homeLoadEarlier => '加载更早的消息';

  @override
  String get homeChats => '聊天';

  @override
  String get homeSelectConversation => '选择一个对话';

  @override
  String get homeNoChatsYet => '暂无聊天';

  @override
  String get homeAddContactToStart => '添加联系人开始聊天';

  @override
  String get homeNewChat => '新建聊天';

  @override
  String get homeNewChatTooltip => '新建聊天';

  @override
  String get homeIncomingCallTitle => '来电';

  @override
  String get homeIncomingGroupCallTitle => '群组来电';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — 群组来电';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return '没有匹配\"$query\"的聊天';
  }

  @override
  String get homeSectionChats => '聊天';

  @override
  String get homeSectionMessages => '消息';

  @override
  String get homeDbEncryptionUnavailable => '数据库加密不可用 — 安装 SQLCipher 以获得完整保护';

  @override
  String get chatFileTooLargeGroup => '群聊不支持超过 512 KB 的文件';

  @override
  String get chatLargeFile => '大文件';

  @override
  String get chatCancel => '取消';

  @override
  String get chatSend => '发送';

  @override
  String get chatFileTooLarge => '文件过大 — 最大限制为 100 MB';

  @override
  String get chatMicDenied => '麦克风权限被拒绝';

  @override
  String get chatVoiceFailed => '保存语音消息失败 — 请检查可用存储空间';

  @override
  String get chatScheduleFuture => '定时发送时间必须在未来';

  @override
  String get chatToday => '今天';

  @override
  String get chatYesterday => '昨天';

  @override
  String get chatEdited => '已编辑';

  @override
  String get chatYou => '你';

  @override
  String chatLargeFileSizeWarning(String size) {
    return '此文件大小为 $size MB。在某些网络上发送大文件可能较慢。是否继续？';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return '$name 的安全密钥已更改。点击以验证。';
  }

  @override
  String chatEncryptionFailed(String name) {
    return '无法加密发送给 $name 的消息 — 消息未发送。';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return '$name 的安全号码已更改。点击以验证。';
  }

  @override
  String get chatNoMessagesFound => '未找到消息';

  @override
  String get chatMessagesE2ee => '消息已端到端加密';

  @override
  String get chatSayHello => '打个招呼';

  @override
  String get appBarOnline => '在线';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => '正在输入';

  @override
  String get appBarSearchMessages => '搜索消息...';

  @override
  String get appBarMute => '静音';

  @override
  String get appBarUnmute => '取消静音';

  @override
  String get appBarMedia => '媒体';

  @override
  String get appBarDisappearing => '阅后即焚';

  @override
  String get appBarDisappearingOn => '阅后即焚：已开启';

  @override
  String get appBarGroupSettings => '群组设置';

  @override
  String get appBarSearchTooltip => '搜索消息';

  @override
  String get appBarVoiceCall => '语音通话';

  @override
  String get appBarVideoCall => '视频通话';

  @override
  String get inputMessage => '消息...';

  @override
  String get inputAttachFile => '添加附件';

  @override
  String get inputSendMessage => '发送消息';

  @override
  String get inputRecordVoice => '录制语音消息';

  @override
  String get inputSendVoice => '发送语音消息';

  @override
  String get inputCancelReply => '取消回复';

  @override
  String get inputCancelEdit => '取消编辑';

  @override
  String get inputCancelRecording => '取消录音';

  @override
  String get inputRecording => '正在录音…';

  @override
  String get inputEditingMessage => '编辑消息';

  @override
  String get inputPhoto => '图片';

  @override
  String get inputVoiceMessage => '语音消息';

  @override
  String get inputFile => '文件';

  @override
  String inputScheduledMessages(int count) {
    return '$count 条定时消息';
  }

  @override
  String get callInitializing => '正在初始化通话…';

  @override
  String get callConnecting => '正在连接…';

  @override
  String get callConnectingRelay => '正在连接（中继）…';

  @override
  String get callSwitchingRelay => '正在切换到中继模式…';

  @override
  String get callConnectionFailed => '连接失败';

  @override
  String get callReconnecting => '正在重新连接…';

  @override
  String get callEnded => '通话已结束';

  @override
  String get callLive => '通话中';

  @override
  String get callEnd => '结束';

  @override
  String get callEndCall => '结束通话';

  @override
  String get callMute => '静音';

  @override
  String get callUnmute => '取消静音';

  @override
  String get callSpeaker => '扬声器';

  @override
  String get callCameraOn => '开启摄像头';

  @override
  String get callCameraOff => '关闭摄像头';

  @override
  String get callShareScreen => '共享屏幕';

  @override
  String get callStopShare => '停止共享';

  @override
  String callTorBackup(String duration) {
    return 'Tor 备用 · $duration';
  }

  @override
  String get callTorBackupBanner => 'Tor 备用线路已激活 — 主线路不可用';

  @override
  String get callDirectFailed => '直连失败 — 正在切换到中继模式…';

  @override
  String get callTurnUnreachable => 'TURN 服务器不可达。请在设置 → 高级中添加自定义 TURN 服务器。';

  @override
  String get callRelayMode => '中继模式已激活（受限网络）';

  @override
  String get callStarting => '正在发起通话…';

  @override
  String get callConnectingToGroup => '正在连接群组…';

  @override
  String get callGroupOpenedInBrowser => '群组通话已在浏览器中打开';

  @override
  String get callCouldNotOpenBrowser => '无法打开浏览器';

  @override
  String get callInviteLinkSent => '邀请链接已发送给所有群成员。';

  @override
  String get callOpenLinkManually => '请手动打开上方链接，或点击重试。';

  @override
  String get callJitsiNotE2ee => 'Jitsi 通话不是端到端加密的';

  @override
  String get callRetryOpenBrowser => '重新打开浏览器';

  @override
  String get callClose => '关闭';

  @override
  String get callCamOn => '开启摄像头';

  @override
  String get callCamOff => '关闭摄像头';

  @override
  String get noConnection => '无网络连接 — 消息将排队发送';

  @override
  String get connected => '已连接';

  @override
  String get connecting => '正在连接…';

  @override
  String get disconnected => '已断开连接';

  @override
  String get offlineBanner => '无网络连接 — 消息将在恢复在线后发送';

  @override
  String get lanModeBanner => '局域网模式 — 无互联网 · 仅限本地网络';

  @override
  String get probeCheckingNetwork => '正在检查网络连接…';

  @override
  String get probeDiscoveringRelays => '正在通过社区目录发现中继…';

  @override
  String get probeStartingTor => '正在启动 Tor 进行引导…';

  @override
  String get probeFindingRelaysTor => '正在通过 Tor 查找可用中继…';

  @override
  String probeNetworkReady(int count) {
    return '网络就绪 — 已找到 $count 个中继';
  }

  @override
  String get probeNoRelaysFound => '未找到可用中继 — 消息可能会延迟';

  @override
  String get jitsiWarningTitle => '非端到端加密';

  @override
  String get jitsiWarningBody => 'Jitsi Meet 通话不受 Pulse 加密保护。请仅用于非敏感对话。';

  @override
  String get jitsiConfirm => '仍然加入';

  @override
  String get jitsiGroupWarningTitle => '非端到端加密';

  @override
  String get jitsiGroupWarningBody =>
      '此通话参与人数过多，无法使用内置加密网格。\n\n将在浏览器中打开 Jitsi Meet 链接。Jitsi 不是端到端加密的 — 服务器可以查看您的通话。';

  @override
  String get jitsiContinueAnyway => '仍然继续';

  @override
  String get retry => '重试';

  @override
  String get setupCreateAnonymousAccount => '创建匿名账户';

  @override
  String get setupTapToChangeColor => '点击更换颜色';

  @override
  String get setupReqMinLength => '至少16个字符';

  @override
  String get setupReqVariety => '4选3：大写、小写、数字、符号';

  @override
  String get setupReqMatch => '密码匹配';

  @override
  String get setupYourNickname => '你的昵称';

  @override
  String get setupRecoveryPassword => '恢复密码（至少16位）';

  @override
  String get setupConfirmPassword => '确认密码';

  @override
  String get setupMin16Chars => '最少16个字符';

  @override
  String get setupPasswordsDoNotMatch => '密码不匹配';

  @override
  String get setupEntropyWeak => '弱';

  @override
  String get setupEntropyOk => '一般';

  @override
  String get setupEntropyStrong => '强';

  @override
  String get setupEntropyWeakNeedsVariety => '弱（需要3种字符类型）';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label（$bits 位）';
  }

  @override
  String get setupPasswordWarning => '此密码是恢复账户的唯一方式。没有服务器 — 无法重置密码。请牢记或写下来。';

  @override
  String get setupCreateAccount => '创建账户';

  @override
  String get setupAlreadyHaveAccount => '已有账户？';

  @override
  String get setupRestore => '恢复 →';

  @override
  String get restoreTitle => '恢复账户';

  @override
  String get restoreInfoBanner =>
      '输入您的恢复密码 — 您的地址（Nostr + Session）将自动恢复。联系人和消息仅存储在本地。';

  @override
  String get restoreNewNickname => '新昵称（可稍后更改）';

  @override
  String get restoreButton => '恢复账户';

  @override
  String get lockTitle => 'Pulse 已锁定';

  @override
  String get lockSubtitle => '输入密码以继续';

  @override
  String get lockPasswordHint => '密码';

  @override
  String get lockUnlock => '解锁';

  @override
  String get lockPanicHint => '忘记密码？输入紧急销毁密钥以清除所有数据。';

  @override
  String get lockTooManyAttempts => '尝试次数过多。正在清除所有数据…';

  @override
  String get lockWrongPassword => '密码错误';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return '密码错误 — $attempts/$max 次尝试';
  }

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingGetStarted => '创建账户';

  @override
  String get onboardingWelcomeTitle => '欢迎使用 Pulse';

  @override
  String get onboardingWelcomeBody =>
      '去中心化、端到端加密的通讯工具。\n\n没有中央服务器。不收集数据。没有后门。\n您的对话只属于您自己。';

  @override
  String get onboardingTransportTitle => '传输无关性';

  @override
  String get onboardingTransportBody =>
      '同时使用 Firebase、Nostr 或两者兼用。\n\n消息自动跨网络路由。内置 Tor 和 I2P 支持，抵抗审查。';

  @override
  String get onboardingSignalTitle => 'Signal + 后量子加密';

  @override
  String get onboardingSignalBody =>
      '每条消息都使用 Signal 协议（Double Ratchet + X3DH）加密，提供前向保密。\n\n此外还使用 Kyber-1024 — NIST 标准的后量子算法 — 抵御未来量子计算机的威胁。';

  @override
  String get onboardingKeysTitle => '密钥由你掌控';

  @override
  String get onboardingKeysBody =>
      '您的身份密钥永远不会离开您的设备。\n\nSignal 指纹可让您通过带外方式验证联系人。TOFU（首次使用即信任）自动检测密钥变更。';

  @override
  String get onboardingThemeTitle => '选择您的外观';

  @override
  String get onboardingThemeBody => '选择主题和强调色。您随时可以在设置中更改。';

  @override
  String get contactsNewChat => '新建聊天';

  @override
  String get contactsAddContact => '添加联系人';

  @override
  String get contactsSearchHint => '搜索...';

  @override
  String get contactsNewGroup => '新建群组';

  @override
  String get contactsNoContactsYet => '暂无联系人';

  @override
  String get contactsAddHint => '点击 + 添加联系人地址';

  @override
  String get contactsNoMatch => '没有匹配的联系人';

  @override
  String get contactsRemoveTitle => '移除联系人';

  @override
  String contactsRemoveMessage(String name) {
    return '确定移除 $name？';
  }

  @override
  String get contactsRemove => '移除';

  @override
  String contactsCount(int count) {
    return '$count 个联系人';
  }

  @override
  String get bubbleOpenLink => '打开链接';

  @override
  String bubbleOpenLinkBody(String url) {
    return '是否在浏览器中打开此网址？\n\n$url';
  }

  @override
  String get bubbleOpen => '打开';

  @override
  String get bubbleSecurityWarning => '安全警告';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" 是一个可执行文件类型。保存并运行它可能会损害您的设备。是否仍然保存？';
  }

  @override
  String get bubbleSaveAnyway => '仍然保存';

  @override
  String bubbleSavedTo(String path) {
    return '已保存到 $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return '保存失败：$error';
  }

  @override
  String get bubbleNotEncrypted => '未加密';

  @override
  String get bubbleCorruptedImage => '[损坏的图片]';

  @override
  String get bubbleReplyPhoto => '图片';

  @override
  String get bubbleReplyVoice => '语音消息';

  @override
  String get bubbleReplyVideo => '视频消息';

  @override
  String bubbleReadBy(String names) {
    return '已读：$names';
  }

  @override
  String bubbleReadByCount(int count) {
    return '$count 人已读';
  }

  @override
  String get chatTileTapToStart => '点击开始聊天';

  @override
  String get chatTileMessageSent => '消息已发送';

  @override
  String get chatTileEncryptedMessage => '加密消息';

  @override
  String chatTileYouPrefix(String text) {
    return '你：$text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 语音消息';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 语音消息 ($duration)';
  }

  @override
  String get bannerEncryptedMessage => '加密消息';

  @override
  String get groupNewGroup => '新建群组';

  @override
  String get groupGroupName => '群组名称';

  @override
  String get groupSelectMembers => '选择成员（至少2人）';

  @override
  String get groupNoContactsYet => '暂无联系人。请先添加联系人。';

  @override
  String get groupCreate => '创建';

  @override
  String get groupLabel => '群组';

  @override
  String get profileVerifyIdentity => '验证身份';

  @override
  String profileVerifyInstructions(String name) {
    return '请通过语音通话或当面与 $name 比较这些指纹。如果两台设备上的值都匹配，请点击「标记为已验证」。';
  }

  @override
  String get profileTheirKey => '对方的密钥';

  @override
  String get profileYourKey => '您的密钥';

  @override
  String get profileRemoveVerification => '取消验证';

  @override
  String get profileMarkAsVerified => '标记为已验证';

  @override
  String get profileAddressCopied => '地址已复制';

  @override
  String get profileNoContactsToAdd => '没有可添加的联系人 — 所有人都已是成员';

  @override
  String get profileAddMembers => '添加成员';

  @override
  String profileAddCount(int count) {
    return '添加（$count）';
  }

  @override
  String get profileRenameGroup => '重命名群组';

  @override
  String get profileRename => '重命名';

  @override
  String get profileRemoveMember => '移除成员？';

  @override
  String profileRemoveMemberBody(String name) {
    return '确定将 $name 从此群组中移除？';
  }

  @override
  String get profileKick => '移除';

  @override
  String get profileSignalFingerprints => 'Signal 指纹';

  @override
  String get profileVerified => '已验证';

  @override
  String get profileVerify => '验证';

  @override
  String get profileEdit => '编辑';

  @override
  String get profileNoSession => '尚未建立会话 — 请先发送一条消息。';

  @override
  String get profileFingerprintCopied => '指纹已复制';

  @override
  String profileMemberCount(int count) {
    return '$count 个成员';
  }

  @override
  String get profileVerifySafetyNumber => '验证安全号码';

  @override
  String get profileShowContactQr => '显示联系人二维码';

  @override
  String profileContactAddress(String name) {
    return '$name 的地址';
  }

  @override
  String get profileExportChatHistory => '导出聊天记录';

  @override
  String profileSavedTo(String path) {
    return '已保存到 $path';
  }

  @override
  String get profileExportFailed => '导出失败';

  @override
  String get profileClearChatHistory => '清除聊天记录';

  @override
  String get profileDeleteGroup => '删除群组';

  @override
  String get profileDeleteContact => '删除联系人';

  @override
  String get profileLeaveGroup => '退出群组';

  @override
  String get profileLeaveGroupBody => '您将被移出此群组，群组也将从您的联系人中删除。';

  @override
  String get groupInviteTitle => '群组邀请';

  @override
  String groupInviteBody(String from, String group) {
    return '$from 邀请您加入\"$group\"';
  }

  @override
  String get groupInviteAccept => '接受';

  @override
  String get groupInviteDecline => '拒绝';

  @override
  String get groupMemberLimitTitle => '参与人数过多';

  @override
  String groupMemberLimitBody(int count) {
    return '此群组将有 $count 名参与者。加密网格通话最多支持 6 人。更大的群组将退回使用 Jitsi（非端到端加密）。';
  }

  @override
  String get groupMemberLimitContinue => '仍然添加';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name 拒绝加入\"$group\"';
  }

  @override
  String get transferTitle => '转移到另一台设备';

  @override
  String get transferInfoBox =>
      '将您的 Signal 身份和 Nostr 密钥转移到新设备。\n聊天会话不会转移 — 前向保密得以保留。';

  @override
  String get transferSendFromThis => '从此设备发送';

  @override
  String get transferSendSubtitle => '此设备拥有密钥。将代码分享给新设备。';

  @override
  String get transferReceiveOnThis => '在此设备接收';

  @override
  String get transferReceiveSubtitle => '这是新设备。输入旧设备上的代码。';

  @override
  String get transferChooseMethod => '选择转移方式';

  @override
  String get transferLan => '局域网（同一网络）';

  @override
  String get transferLanSubtitle => '快速、直连。两台设备必须在同一 Wi-Fi 下。';

  @override
  String get transferNostrRelay => 'Nostr 中继';

  @override
  String get transferNostrRelaySubtitle => '通过现有 Nostr 中继在任何网络上传输。';

  @override
  String get transferRelayUrl => '中继 URL';

  @override
  String get transferEnterCode => '输入转移代码';

  @override
  String get transferPasteCode => '在此粘贴 LAN:... 或 NOS:... 代码';

  @override
  String get transferConnect => '连接';

  @override
  String get transferGenerating => '正在生成转移代码…';

  @override
  String get transferShareCode => '将此代码分享给接收者：';

  @override
  String get transferCopyCode => '复制代码';

  @override
  String get transferCodeCopied => '代码已复制到剪贴板';

  @override
  String get transferWaitingReceiver => '等待接收者连接…';

  @override
  String get transferConnectingSender => '正在连接发送者…';

  @override
  String get transferVerifyBoth => '在两台设备上比较此代码。\n如果匹配，则转移是安全的。';

  @override
  String get transferComplete => '转移完成';

  @override
  String get transferKeysImported => '密钥已导入';

  @override
  String get transferCompleteSenderBody => '您的密钥在此设备上仍然有效。\n接收者现在可以使用您的身份。';

  @override
  String get transferCompleteReceiverBody => '密钥导入成功。\n请重启应用以应用新身份。';

  @override
  String get transferRestartApp => '重启应用';

  @override
  String get transferFailed => '转移失败';

  @override
  String get transferTryAgain => '重试';

  @override
  String get transferEnterRelayFirst => '请先输入中继 URL';

  @override
  String get transferPasteCodeFromSender => '请粘贴发送者的转移代码';

  @override
  String get menuReply => '回复';

  @override
  String get menuForward => '转发';

  @override
  String get menuReact => '表情回应';

  @override
  String get menuCopy => '复制';

  @override
  String get menuEdit => '编辑';

  @override
  String get menuRetry => '重试';

  @override
  String get menuCancelScheduled => '取消定时发送';

  @override
  String get menuDelete => '删除';

  @override
  String get menuForwardTo => '转发给…';

  @override
  String menuForwardedTo(String name) {
    return '已转发给 $name';
  }

  @override
  String get menuScheduledMessages => '定时消息';

  @override
  String get menuNoScheduledMessages => '没有定时消息';

  @override
  String menuSendsOn(String date) {
    return '将于 $date 发送';
  }

  @override
  String get menuDisappearingMessages => '阅后即焚消息';

  @override
  String get menuDisappearingSubtitle => '消息在指定时间后自动删除。';

  @override
  String get menuTtlOff => '关闭';

  @override
  String get menuTtl1h => '1 小时';

  @override
  String get menuTtl24h => '24 小时';

  @override
  String get menuTtl7d => '7 天';

  @override
  String get menuAttachPhoto => '图片';

  @override
  String get menuAttachFile => '文件';

  @override
  String get menuAttachVideo => '视频';

  @override
  String get mediaTitle => '媒体';

  @override
  String get mediaFileLabel => '文件';

  @override
  String mediaPhotosTab(int count) {
    return '图片（$count）';
  }

  @override
  String mediaFilesTab(int count) {
    return '文件（$count）';
  }

  @override
  String get mediaNoPhotos => '暂无图片';

  @override
  String get mediaNoFiles => '暂无文件';

  @override
  String mediaSavedToDownloads(String name) {
    return '已保存到 Downloads/$name';
  }

  @override
  String get mediaFailedToSave => '保存文件失败';

  @override
  String get statusNewStatus => '新动态';

  @override
  String get statusPublish => '发布';

  @override
  String get statusExpiresIn24h => '动态将在 24 小时后过期';

  @override
  String get statusWhatsOnYourMind => '在想什么？';

  @override
  String get statusPhotoAttached => '已附加图片';

  @override
  String get statusAttachPhoto => '附加图片（可选）';

  @override
  String get statusEnterText => '请输入动态文字内容。';

  @override
  String statusPickPhotoFailed(String error) {
    return '选择图片失败：$error';
  }

  @override
  String statusPublishFailed(String error) {
    return '发布失败：$error';
  }

  @override
  String get panicSetPanicKey => '设置紧急销毁密钥';

  @override
  String get panicEmergencySelfDestruct => '紧急自毁';

  @override
  String get panicIrreversible => '此操作不可撤销';

  @override
  String get panicWarningBody =>
      '在锁屏界面输入此密钥将立即清除所有数据 — 消息、联系人、密钥、身份。请使用与常规密码不同的密钥。';

  @override
  String get panicKeyHint => '紧急销毁密钥';

  @override
  String get panicConfirmHint => '确认紧急销毁密钥';

  @override
  String get panicMinChars => '紧急销毁密钥至少需要 8 个字符';

  @override
  String get panicKeysDoNotMatch => '密钥不匹配';

  @override
  String get panicSetFailed => '保存紧急销毁密钥失败 — 请重试';

  @override
  String get passwordSetAppPassword => '设置应用密码';

  @override
  String get passwordProtectsMessages => '保护您的离线消息安全';

  @override
  String get passwordInfoBanner => '每次打开 Pulse 时都需要输入此密码。如果忘记，您的数据将无法恢复。';

  @override
  String get passwordHint => '密码';

  @override
  String get passwordConfirmHint => '确认密码';

  @override
  String get passwordSetButton => '设置密码';

  @override
  String get passwordSkipForNow => '暂时跳过';

  @override
  String get passwordMinChars => '密码至少需要 8 个字符';

  @override
  String get passwordNeedsVariety => '必须包含字母、数字和特殊字符';

  @override
  String get passwordRequirements => '至少 8 个字符，包含字母、数字和特殊字符';

  @override
  String get passwordsDoNotMatch => '密码不匹配';

  @override
  String get profileCardSaved => '个人资料已保存！';

  @override
  String get profileCardE2eeIdentity => 'E2EE 身份';

  @override
  String get profileCardDisplayName => '显示名称';

  @override
  String get profileCardDisplayNameHint => '例如 张三';

  @override
  String get profileCardAbout => '关于';

  @override
  String get profileCardSaveProfile => '保存个人资料';

  @override
  String get profileCardYourName => '您的名字';

  @override
  String get profileCardAddressCopied => '地址已复制！';

  @override
  String get profileCardInboxAddress => '您的收件地址';

  @override
  String get profileCardInboxAddresses => '您的收件地址';

  @override
  String get profileCardShareAllAddresses => '分享所有地址（SmartRouter）';

  @override
  String get profileCardShareHint => '分享给联系人，以便他们给您发消息。';

  @override
  String profileCardAllAddressesCopied(int count) {
    return '已复制全部 $count 个地址为一个链接！';
  }

  @override
  String get settingsMyProfile => '我的资料';

  @override
  String get settingsYourInboxAddress => '您的收件地址';

  @override
  String get settingsMyQrCode => '分享联系方式';

  @override
  String get settingsMyQrSubtitle => '您地址的二维码和邀请链接';

  @override
  String get settingsShareMyAddress => '分享我的地址';

  @override
  String get settingsNoAddressYet => '暂无地址 — 请先保存设置';

  @override
  String get settingsInviteLink => '邀请链接';

  @override
  String get settingsRawAddress => '原始地址';

  @override
  String get settingsCopyLink => '复制链接';

  @override
  String get settingsCopyAddress => '复制地址';

  @override
  String get settingsInviteLinkCopied => '邀请链接已复制';

  @override
  String get settingsAppearance => '外观';

  @override
  String get settingsThemeEngine => '主题引擎';

  @override
  String get settingsThemeEngineSubtitle => '自定义颜色和字体';

  @override
  String get settingsSignalProtocol => 'Signal 协议';

  @override
  String get settingsSignalProtocolSubtitle => 'E2EE 密钥安全存储';

  @override
  String get settingsActive => '已启用';

  @override
  String get settingsIdentityBackup => '身份备份';

  @override
  String get settingsIdentityBackupSubtitle => '导出或导入您的 Signal 身份';

  @override
  String get settingsIdentityBackupBody => '将您的 Signal 身份密钥导出为备份码，或从现有备份恢复。';

  @override
  String get settingsTransferDevice => '转移到另一台设备';

  @override
  String get settingsTransferDeviceSubtitle => '通过局域网或 Nostr 中继转移身份';

  @override
  String get settingsExportIdentity => '导出身份';

  @override
  String get settingsExportIdentityBody => '复制此备份码并安全保存：';

  @override
  String get settingsSaveFile => '保存文件';

  @override
  String get settingsImportIdentity => '导入身份';

  @override
  String get settingsImportIdentityBody => '在下方粘贴您的备份码。这将覆盖您当前的身份。';

  @override
  String get settingsPasteBackupCode => '在此粘贴备份码…';

  @override
  String get settingsIdentityImported => '身份和联系人已导入！请重启应用以生效。';

  @override
  String get settingsSecurity => '安全';

  @override
  String get settingsAppPassword => '应用密码';

  @override
  String get settingsPasswordEnabled => '已启用 — 每次启动时需要输入';

  @override
  String get settingsPasswordDisabled => '已禁用 — 无需密码即可打开应用';

  @override
  String get settingsChangePassword => '修改密码';

  @override
  String get settingsChangePasswordSubtitle => '更新应用锁定密码';

  @override
  String get settingsSetPanicKey => '设置紧急销毁密钥';

  @override
  String get settingsChangePanicKey => '修改紧急销毁密钥';

  @override
  String get settingsPanicKeySetSubtitle => '更新紧急清除密钥';

  @override
  String get settingsPanicKeyUnsetSubtitle => '一键立即清除所有数据';

  @override
  String get settingsRemovePanicKey => '移除紧急销毁密钥';

  @override
  String get settingsRemovePanicKeySubtitle => '禁用紧急自毁功能';

  @override
  String get settingsRemovePanicKeyBody => '紧急自毁功能将被禁用。您可以随时重新启用。';

  @override
  String get settingsDisableAppPassword => '禁用应用密码';

  @override
  String get settingsEnterCurrentPassword => '输入当前密码以确认';

  @override
  String get settingsCurrentPassword => '当前密码';

  @override
  String get settingsIncorrectPassword => '密码错误';

  @override
  String get settingsPasswordUpdated => '密码已更新';

  @override
  String get settingsChangePasswordProceed => '输入当前密码以继续';

  @override
  String get settingsData => '数据';

  @override
  String get settingsBackupMessages => '备份消息';

  @override
  String get settingsBackupMessagesSubtitle => '将加密的消息记录导出到文件';

  @override
  String get settingsRestoreMessages => '恢复消息';

  @override
  String get settingsRestoreMessagesSubtitle => '从备份文件导入消息';

  @override
  String get settingsExportKeys => '导出密钥';

  @override
  String get settingsExportKeysSubtitle => '将身份密钥保存到加密文件';

  @override
  String get settingsImportKeys => '导入密钥';

  @override
  String get settingsImportKeysSubtitle => '从导出文件恢复身份密钥';

  @override
  String get settingsBackupPassword => '备份密码';

  @override
  String get settingsPasswordCannotBeEmpty => '密码不能为空';

  @override
  String get settingsPasswordMin4Chars => '密码至少需要 4 个字符';

  @override
  String get settingsCallsTurn => '通话与 TURN';

  @override
  String get settingsLocalNetwork => '本地网络';

  @override
  String get settingsCensorshipResistance => '抗审查';

  @override
  String get settingsNetwork => '网络';

  @override
  String get settingsProxyTunnels => '代理与隧道';

  @override
  String get settingsTurnServers => 'TURN 服务器';

  @override
  String get settingsProviderTitle => '提供商';

  @override
  String get settingsLanFallback => '局域网回退';

  @override
  String get settingsLanFallbackSubtitle =>
      '在没有互联网时，通过本地网络广播状态并传递消息。在不可信网络（公共 Wi-Fi）上请禁用。';

  @override
  String get settingsBgDelivery => '后台消息接收';

  @override
  String get settingsBgDeliverySubtitle => '在应用最小化时继续接收消息。会显示常驻通知。';

  @override
  String get settingsYourInboxProvider => '您的收件箱提供商';

  @override
  String get settingsConnectionDetails => '连接详情';

  @override
  String get settingsSaveAndConnect => '保存并连接';

  @override
  String get settingsSecondaryInboxes => '备用收件箱';

  @override
  String get settingsAddSecondaryInbox => '添加备用收件箱';

  @override
  String get settingsAdvanced => '高级';

  @override
  String get settingsDiscover => '发现';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsPrivacyPolicy => '隐私政策';

  @override
  String get settingsPrivacyPolicySubtitle => 'Pulse 如何保护您的数据';

  @override
  String get settingsCrashReporting => '崩溃报告';

  @override
  String get settingsCrashReportingSubtitle =>
      '发送匿名崩溃报告以帮助改进 Pulse。不会发送任何消息内容或联系人信息。';

  @override
  String get settingsCrashReportingEnabled => '崩溃报告已启用 — 重启应用以生效';

  @override
  String get settingsCrashReportingDisabled => '崩溃报告已禁用 — 重启应用以生效';

  @override
  String get settingsSensitiveOperation => '敏感操作';

  @override
  String get settingsSensitiveOperationBody =>
      '这些密钥是您的身份。任何拥有此文件的人都可以冒充您。请安全存储并在转移后删除。';

  @override
  String get settingsIUnderstandContinue => '我已了解，继续';

  @override
  String get settingsReplaceIdentity => '替换身份？';

  @override
  String get settingsReplaceIdentityBody =>
      '这将覆盖您当前的身份密钥。现有的 Signal 会话将失效，联系人需要重新建立加密。应用需要重启。';

  @override
  String get settingsReplaceKeys => '替换密钥';

  @override
  String get settingsKeysImported => '密钥已导入';

  @override
  String settingsKeysImportedBody(int count) {
    return '成功导入 $count 个密钥。请重启应用以使用新身份。';
  }

  @override
  String get settingsRestartNow => '立即重启';

  @override
  String get settingsLater => '稍后';

  @override
  String get profileGroupLabel => '群组';

  @override
  String get profileAddButton => '添加';

  @override
  String get profileKickButton => '移除';

  @override
  String get dataSectionTitle => '数据';

  @override
  String get dataBackupMessages => '备份消息';

  @override
  String get dataBackupPasswordSubtitle => '选择一个密码来加密您的消息备份。';

  @override
  String get dataBackupConfirmLabel => '创建备份';

  @override
  String get dataCreatingBackup => '正在创建备份';

  @override
  String get dataBackupPreparing => '准备中...';

  @override
  String dataBackupExporting(int done, int total) {
    return '正在导出第 $done 条消息，共 $total 条...';
  }

  @override
  String get dataBackupSavingFile => '正在保存文件...';

  @override
  String get dataSaveMessageBackupDialog => '保存消息备份';

  @override
  String dataBackupSaved(int count, String path) {
    return '备份已保存（$count 条消息）\n$path';
  }

  @override
  String get dataBackupFailed => '备份失败 — 没有数据可导出';

  @override
  String dataBackupFailedError(String error) {
    return '备份失败：$error';
  }

  @override
  String get dataSelectMessageBackupDialog => '选择消息备份';

  @override
  String get dataInvalidBackupFile => '无效的备份文件（文件太小）';

  @override
  String get dataNotValidBackupFile => '不是有效的 Pulse 备份文件';

  @override
  String get dataRestoreMessages => '恢复消息';

  @override
  String get dataRestorePasswordSubtitle => '输入创建此备份时使用的密码。';

  @override
  String get dataRestoreConfirmLabel => '恢复';

  @override
  String get dataRestoringMessages => '正在恢复消息';

  @override
  String get dataRestoreDecrypting => '正在解密...';

  @override
  String dataRestoreImporting(int done, int total) {
    return '正在导入第 $done 条消息，共 $total 条...';
  }

  @override
  String get dataRestoreFailed => '恢复失败 — 密码错误或文件损坏';

  @override
  String dataRestoreSuccess(int count) {
    return '已恢复 $count 条新消息';
  }

  @override
  String get dataRestoreNothingNew => '没有新消息可导入（所有消息已存在）';

  @override
  String dataRestoreFailedError(String error) {
    return '恢复失败：$error';
  }

  @override
  String get dataSelectKeyExportDialog => '选择密钥导出文件';

  @override
  String get dataNotValidKeyFile => '不是有效的 Pulse 密钥导出文件';

  @override
  String get dataExportKeys => '导出密钥';

  @override
  String get dataExportKeysPasswordSubtitle => '选择一个密码来加密您的密钥导出。';

  @override
  String get dataExportKeysConfirmLabel => '导出';

  @override
  String get dataExportingKeys => '正在导出密钥';

  @override
  String get dataExportingKeysStatus => '正在加密身份密钥...';

  @override
  String get dataSaveKeyExportDialog => '保存密钥导出';

  @override
  String dataKeysExportedTo(String path) {
    return '密钥已导出到：\n$path';
  }

  @override
  String get dataExportFailed => '导出失败 — 未找到密钥';

  @override
  String dataExportFailedError(String error) {
    return '导出失败：$error';
  }

  @override
  String get dataImportKeys => '导入密钥';

  @override
  String get dataImportKeysPasswordSubtitle => '输入加密此密钥导出时使用的密码。';

  @override
  String get dataImportKeysConfirmLabel => '导入';

  @override
  String get dataImportingKeys => '正在导入密钥';

  @override
  String get dataImportingKeysStatus => '正在解密身份密钥...';

  @override
  String get dataImportFailed => '导入失败 — 密码错误或文件损坏';

  @override
  String dataImportFailedError(String error) {
    return '导入失败：$error';
  }

  @override
  String get securitySectionTitle => '安全';

  @override
  String get securityIncorrectPassword => '密码错误';

  @override
  String get securityPasswordUpdated => '密码已更新';

  @override
  String get appearanceSectionTitle => '外观';

  @override
  String appearanceExportFailed(String error) {
    return '导出失败：$error';
  }

  @override
  String appearanceSavedTo(String path) {
    return '已保存到 $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return '保存失败：$error';
  }

  @override
  String appearanceImportFailed(String error) {
    return '导入失败：$error';
  }

  @override
  String get aboutSectionTitle => '关于';

  @override
  String get providerPublicKey => '公钥';

  @override
  String get providerRelay => '中继';

  @override
  String get providerAutoConfigured => '已从恢复密码自动配置。中继自动发现。';

  @override
  String get providerKeyStoredLocally => '您的密钥存储在本地安全存储中 — 从不发送到任何服务器。';

  @override
  String get providerSessionInfo =>
      'Session Network — 洋葱路由E2EE。您的Session ID自动生成并安全存储。节点从内置种子节点自动发现。';

  @override
  String get providerAdvanced => '高级';

  @override
  String get providerSaveAndConnect => '保存并连接';

  @override
  String get providerAddSecondaryInbox => '添加备用收件箱';

  @override
  String get providerSecondaryInboxes => '备用收件箱';

  @override
  String get providerYourInboxProvider => '您的收件箱提供商';

  @override
  String get providerConnectionDetails => '连接详情';

  @override
  String get addContactTitle => '添加联系人';

  @override
  String get addContactInviteLinkLabel => '邀请链接或地址';

  @override
  String get addContactTapToPaste => '点击粘贴邀请链接';

  @override
  String get addContactPasteTooltip => '从剪贴板粘贴';

  @override
  String get addContactAddressDetected => '已检测到联系人地址';

  @override
  String addContactRoutesDetected(int count) {
    return '已检测到 $count 条路由 — SmartRouter 将选择最快的';
  }

  @override
  String get addContactFetchingProfile => '正在获取资料…';

  @override
  String addContactProfileFound(String name) {
    return '已找到：$name';
  }

  @override
  String get addContactNoProfileFound => '未找到资料';

  @override
  String get addContactDisplayNameLabel => '显示名称';

  @override
  String get addContactDisplayNameHint => '您想怎么称呼对方？';

  @override
  String get addContactAddManually => '手动添加地址';

  @override
  String get addContactButton => '添加联系人';

  @override
  String get networkDiagnosticsTitle => '网络诊断';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr 中继';

  @override
  String get networkDiagnosticsDirect => '直连';

  @override
  String get networkDiagnosticsTorOnly => '仅 Tor';

  @override
  String get networkDiagnosticsBest => '最佳';

  @override
  String get networkDiagnosticsNone => '无';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => '状态';

  @override
  String get networkDiagnosticsConnected => '已连接';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return '连接中 $percent%';
  }

  @override
  String get networkDiagnosticsOff => '关闭';

  @override
  String get networkDiagnosticsTransport => '传输方式';

  @override
  String get networkDiagnosticsInfrastructure => '基础设施';

  @override
  String get networkDiagnosticsSessionNodes => 'Session 节点';

  @override
  String get networkDiagnosticsTurnServers => 'TURN 服务器';

  @override
  String get networkDiagnosticsLastProbe => '上次探测';

  @override
  String get networkDiagnosticsRunning => '运行中...';

  @override
  String get networkDiagnosticsRunDiagnostics => '运行诊断';

  @override
  String get networkDiagnosticsForceReprobe => '强制完整重新探测';

  @override
  String get networkDiagnosticsJustNow => '刚刚';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes 分钟前';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours 小时前';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days 天前';
  }

  @override
  String get homeNoEch => '无 ECH';

  @override
  String get homeNoEchTooltip => 'uTLS 代理不可用 — ECH 已禁用。\nTLS 指纹对 DPI 可见。';

  @override
  String get settingsTitle => '设置';

  @override
  String settingsSavedConnectedTo(String provider) {
    return '已保存并连接到 $provider';
  }

  @override
  String get settingsTorFailedToStart => '内置 Tor 启动失败';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon 启动失败';

  @override
  String get verifyTitle => '验证安全号码';

  @override
  String get verifyIdentityVerified => '身份已验证';

  @override
  String get verifyNotYetVerified => '尚未验证';

  @override
  String verifyVerifiedDescription(String name) {
    return '您已验证了 $name 的安全号码。';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return '请与 $name 当面或通过可信渠道比较这些数字。';
  }

  @override
  String get verifyExplanation =>
      '每个对话都有唯一的安全号码。如果您和对方在各自的设备上看到相同的数字，则您的连接已通过端到端验证。';

  @override
  String verifyContactKey(String name) {
    return '$name 的密钥';
  }

  @override
  String get verifyYourKey => '您的密钥';

  @override
  String get verifyRemoveVerification => '取消验证';

  @override
  String get verifyMarkAsVerified => '标记为已验证';

  @override
  String verifyAfterReinstall(String name) {
    return '如果 $name 重新安装应用，安全号码将更改，验证将自动取消。';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return '请仅在通过语音通话或当面与 $name 比较数字后才标记为已验证。';
  }

  @override
  String get verifyNoSession => '尚未建立加密会话。请先发送一条消息以生成安全号码。';

  @override
  String get verifyNoKeyAvailable => '无可用密钥';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label 指纹已复制';
  }

  @override
  String get providerDatabaseUrlLabel => '数据库 URL';

  @override
  String get providerOptionalHint => '可选';

  @override
  String get providerWebApiKeyLabel => 'Web API 密钥';

  @override
  String get providerOptionalForPublicDb => '公开数据库可选';

  @override
  String get providerRelayUrlLabel => '中继 URL';

  @override
  String get providerPrivateKeyLabel => '私钥';

  @override
  String get providerPrivateKeyNsecLabel => '私钥（nsec）';

  @override
  String get providerStorageNodeLabel => '存储节点 URL（可选）';

  @override
  String get providerStorageNodeHint => '留空以使用内置种子节点';

  @override
  String get transferInvalidCodeFormat => '无法识别的代码格式 — 必须以 LAN: 或 NOS: 开头';

  @override
  String get profileCardFingerprintCopied => '指纹已复制';

  @override
  String get profileCardAboutHint => '隐私至上 🔒';

  @override
  String get profileCardSaveButton => '保存个人资料';

  @override
  String get settingsBackupMessagesSubtitleV2 => '将加密的消息、联系人和头像导出到文件';

  @override
  String get callVideo => '视频';

  @override
  String get callAudio => '音频';

  @override
  String bubbleDeliveredTo(String names) {
    return '已送达：$names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return '已送达 $count 人';
  }

  @override
  String get groupStatusDialogTitle => '消息详情';

  @override
  String get groupStatusRead => '已读';

  @override
  String get groupStatusDelivered => '已送达';

  @override
  String get groupStatusPending => '待发送';

  @override
  String get groupStatusNoData => '暂无送达信息';

  @override
  String get profileTransferAdmin => '设为管理员';

  @override
  String profileTransferAdminConfirm(String name) {
    return '确定将 $name 设为新管理员？';
  }

  @override
  String get profileTransferAdminBody => '您将失去管理员权限。此操作无法撤销。';

  @override
  String profileTransferAdminDone(String name) {
    return '$name 已成为管理员';
  }

  @override
  String get profileAdminBadge => '管理员';

  @override
  String get privacyPolicyTitle => '隐私政策';

  @override
  String get privacyOverviewHeading => '概述';

  @override
  String get privacyOverviewBody =>
      'Pulse 是一款无服务器、端到端加密的通讯工具。隐私不仅仅是一项功能 — 它是架构设计。没有 Pulse 服务器。不存储任何账户。开发者不收集、传输或存储任何数据。';

  @override
  String get privacyDataCollectionHeading => '数据收集';

  @override
  String get privacyDataCollectionBody =>
      'Pulse 不收集任何个人数据。具体而言：\n\n- 不需要邮箱、手机号或真实姓名\n- 没有分析、追踪或遥测\n- 没有广告标识符\n- 不访问通讯录\n- 没有云备份（消息仅存在于您的设备上）\n- 不向任何 Pulse 服务器发送元数据（因为没有服务器）';

  @override
  String get privacyEncryptionHeading => '加密';

  @override
  String get privacyEncryptionBody =>
      '所有消息都使用 Signal 协议（Double Ratchet + X3DH 密钥协商）加密。加密密钥仅在您的设备上生成和存储。任何人 — 包括开发者 — 都无法阅读您的消息。';

  @override
  String get privacyNetworkHeading => '网络架构';

  @override
  String get privacyNetworkBody =>
      'Pulse 使用联邦传输适配器（Nostr 中继、Session/Oxen 服务节点、Firebase 实时数据库、局域网）。这些传输层只承载加密密文。中继运营者可以看到您的 IP 地址和流量大小，但无法解密消息内容。\n\n启用 Tor 后，您的 IP 地址对中继运营者也是隐藏的。';

  @override
  String get privacyStunHeading => 'STUN/TURN 服务器';

  @override
  String get privacyStunBody =>
      '语音和视频通话使用带有 DTLS-SRTP 加密的 WebRTC。STUN 服务器（用于发现公网 IP 以建立点对点连接）和 TURN 服务器（在直连失败时中转媒体）可以看到您的 IP 地址和通话时长，但无法解密通话内容。\n\n您可以在设置中配置自己的 TURN 服务器以获得最大隐私。';

  @override
  String get privacyCrashHeading => '崩溃报告';

  @override
  String get privacyCrashBody =>
      '如果启用了 Sentry 崩溃报告（通过构建时 SENTRY_DSN），可能会发送匿名崩溃报告。这些报告不包含消息内容、联系人信息或任何个人身份信息。可以在构建时通过省略 DSN 来禁用崩溃报告。';

  @override
  String get privacyPasswordHeading => '密码与密钥';

  @override
  String get privacyPasswordBody =>
      '您的恢复密码通过 Argon2id（内存密集型 KDF）用于派生加密密钥。密码永远不会被传输到任何地方。如果您丢失密码，账户将无法恢复 — 没有服务器可以重置密码。';

  @override
  String get privacyFontsHeading => '字体';

  @override
  String get privacyFontsBody =>
      'Pulse 在本地打包所有字体。不会向 Google Fonts 或任何外部字体服务发送请求。';

  @override
  String get privacyThirdPartyHeading => '第三方服务';

  @override
  String get privacyThirdPartyBody =>
      'Pulse 不集成任何广告网络、分析提供商、社交媒体平台或数据经纪商。唯一的网络连接是连接到您配置的传输中继。';

  @override
  String get privacyOpenSourceHeading => '开源';

  @override
  String get privacyOpenSourceBody => 'Pulse 是开源软件。您可以审计完整的源代码来验证这些隐私声明。';

  @override
  String get privacyContactHeading => '联系方式';

  @override
  String get privacyContactBody => '如有隐私相关问题，请在项目仓库提交 issue。';

  @override
  String get privacyLastUpdated => '最后更新：2026 年 3 月';

  @override
  String imageSaveFailed(Object error) {
    return '保存失败：$error';
  }

  @override
  String get themeEngineTitle => '主题引擎';

  @override
  String get torBuiltInTitle => '内置 Tor';

  @override
  String get torConnectedSubtitle => '已连接 — Nostr 通过 127.0.0.1:9250 路由';

  @override
  String torConnectingSubtitle(int pct) {
    return '连接中… $pct%';
  }

  @override
  String get torNotRunning => '未运行 — 点击开关以重启';

  @override
  String get torDescription => '通过 Tor 路由 Nostr（受审查网络使用 Snowflake）';

  @override
  String get torNetworkDiagnostics => '网络诊断';

  @override
  String get torTransportLabel => '传输方式：';

  @override
  String get torPtAuto => '自动';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => '直连';

  @override
  String get torTimeoutLabel => '超时：';

  @override
  String get torInfoDescription =>
      '启用后，Nostr WebSocket 连接将通过 Tor（SOCKS5）路由。Tor Browser 监听 127.0.0.1:9150。独立 tor 守护进程使用端口 9050。Firebase 连接不受影响。';

  @override
  String get torRouteNostrTitle => '通过 Tor 路由 Nostr';

  @override
  String get torManagedByBuiltin => '由内置 Tor 管理';

  @override
  String get torActiveRouting => '已激活 — Nostr 流量通过 Tor 路由';

  @override
  String get torDisabled => '已禁用';

  @override
  String get torProxySocks5 => 'Tor 代理（SOCKS5）';

  @override
  String get torProxyHostLabel => '代理主机';

  @override
  String get torProxyPortLabel => '端口';

  @override
  String get torPortInfo => 'Tor Browser：端口 9150  •  tor 守护进程：端口 9050';

  @override
  String get torForceNostrTitle => '通过 Tor 路由消息';

  @override
  String get torForceNostrSubtitle =>
      '所有 Nostr 中继连接将通过 Tor 传输。速度较慢，但可向中继隐藏您的 IP 地址。';

  @override
  String get torForceNostrDisabled => '必须先启用 Tor';

  @override
  String get torForcePulseTitle => '通过 Tor 路由 Pulse 中继';

  @override
  String get torForcePulseSubtitle =>
      '所有 Pulse 中继连接将通过 Tor 传输。速度较慢，但可向服务器隐藏您的 IP 地址。';

  @override
  String get torForcePulseDisabled => '必须先启用 Tor';

  @override
  String get i2pProxySocks5 => 'I2P 代理（SOCKS5）';

  @override
  String get i2pInfoDescription =>
      'I2P 默认使用端口 4447 的 SOCKS5。通过 I2P 出口代理（如 relay.damus.i2p）连接 Nostr 中继，与任何传输层的用户通信。同时启用时，Tor 优先级更高。';

  @override
  String get i2pRouteNostrTitle => '通过 I2P 路由 Nostr';

  @override
  String get i2pActiveRouting => '已激活 — Nostr 流量通过 I2P 路由';

  @override
  String get i2pDisabled => '已禁用';

  @override
  String get i2pProxyHostLabel => '代理主机';

  @override
  String get i2pProxyPortLabel => '端口';

  @override
  String get i2pPortInfo => 'I2P 路由器默认 SOCKS5 端口：4447';

  @override
  String get customProxySocks5 => '自定义代理（SOCKS5）';

  @override
  String get customCfWorkerRelay => 'CF Worker 中继';

  @override
  String get customProxyInfoDescription =>
      '自定义代理通过您的 V2Ray/Xray/Shadowsocks 路由流量。CF Worker 作为 Cloudflare CDN 上的个人中继代理 — GFW 看到的是 *.workers.dev，而非真实中继。';

  @override
  String get customSocks5ProxyTitle => '自定义 SOCKS5 代理';

  @override
  String get customProxyActive => '已激活 — 流量通过 SOCKS5 路由';

  @override
  String get customProxyDisabled => '已禁用';

  @override
  String get customProxyHostLabel => '代理主机';

  @override
  String get customProxyPortLabel => '端口';

  @override
  String get customProxyHint =>
      'V2Ray/Xray：127.0.0.1:10808  •  Shadowsocks：127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker 域名（可选）';

  @override
  String get customWorkerHelpTitle => '如何部署 CF Worker 中继（免费）';

  @override
  String get customWorkerScriptCopied => '脚本已复制！';

  @override
  String get customWorkerStep1 =>
      '1. 前往 dash.cloudflare.com → Workers & Pages\n2. 创建 Worker → 粘贴此脚本：\n';

  @override
  String get customWorkerStep2 =>
      '3. 部署 → 复制域名（如 my-relay.user.workers.dev）\n4. 在上方粘贴域名 → 保存\n\n应用自动连接：wss://domain/?r=relay_url\nGFW 看到的是：连接到 *.workers.dev（CF CDN）';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return '已连接 — SOCKS5 监听 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => '连接中…';

  @override
  String get psiphonNotRunning => '未运行 — 点击开关以重启';

  @override
  String get psiphonDescription => '快速隧道（约 3 秒引导，2000+ 轮换 VPS）';

  @override
  String get turnCommunityServers => '社区 TURN 服务器';

  @override
  String get turnCustomServer => '自定义 TURN 服务器（BYOD）';

  @override
  String get turnInfoDescription =>
      'TURN 服务器只中转已加密的流（DTLS-SRTP）。中继运营者可以看到您的 IP 和流量大小，但无法解密通话。TURN 仅在直连 P2P 失败时使用（约 15–20% 的连接）。';

  @override
  String get turnFreeLabel => '免费';

  @override
  String get turnServerUrlLabel => 'TURN 服务器 URL';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 或 turns:...';

  @override
  String get turnUsernameLabel => '用户名';

  @override
  String get turnPasswordLabel => '密码';

  @override
  String get turnOptionalHint => '可选';

  @override
  String get turnCustomInfo => '在任何每月 \$5 的 VPS 上自建 coturn 以获得最大控制权。凭证存储在本地。';

  @override
  String get themePickerAppearance => '外观';

  @override
  String get themePickerAccentColor => '强调色';

  @override
  String get themeModeLight => '浅色';

  @override
  String get themeModeDark => '深色';

  @override
  String get themeModeSystem => '跟随系统';

  @override
  String get themeDynamicPresets => '预设';

  @override
  String get themeDynamicPrimaryColor => '主色调';

  @override
  String get themeDynamicBorderRadius => '圆角半径';

  @override
  String get themeDynamicFont => '字体';

  @override
  String get themeDynamicAppearance => '外观';

  @override
  String get themeDynamicUiStyle => 'UI 风格';

  @override
  String get themeDynamicUiStyleDescription => '控制对话框、开关和指示器的外观。';

  @override
  String get themeDynamicSharp => '棱角';

  @override
  String get themeDynamicRound => '圆润';

  @override
  String get themeDynamicModeDark => '深色';

  @override
  String get themeDynamicModeLight => '浅色';

  @override
  String get themeDynamicModeAuto => '自动';

  @override
  String get themeDynamicPlatformAuto => '自动';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      '无效的 Firebase URL。应为 https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      '无效的中继 URL。应为 wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      '无效的 Pulse 服务器 URL。应为 https://server:port';

  @override
  String get providerPulseServerUrlLabel => '服务器 URL';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => '邀请码';

  @override
  String get providerPulseInviteHint => '邀请码（如需要）';

  @override
  String get providerPulseInfo => '自建中继。密钥从恢复密码派生。';

  @override
  String get providerScreenTitle => '收件箱';

  @override
  String get providerSecondaryInboxesHeader => '备用收件箱';

  @override
  String get providerSecondaryInboxesInfo => '备用收件箱同时接收消息，提供冗余保障。';

  @override
  String get providerRemoveTooltip => '移除';

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
  String get emojiNoRecent => '没有最近使用的表情';

  @override
  String get emojiSearchHint => '搜索表情...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => '点击聊天';

  @override
  String get imageViewerSaveToDownloads => '保存到下载';

  @override
  String imageViewerSavedTo(String path) {
    return '已保存到 $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => '确定';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSubtitle => '应用显示语言';

  @override
  String get settingsLanguageSystem => '系统默认';

  @override
  String get onboardingLanguageTitle => '选择您的语言';

  @override
  String get onboardingLanguageSubtitle => '您可以稍后在设置中更改';

  @override
  String get videoNoteRecord => '录制视频消息';

  @override
  String get videoNoteTapToRecord => '点击开始录制';

  @override
  String get videoNoteTapToStop => '点击停止';

  @override
  String get videoNoteCameraPermission => '相机权限被拒绝';

  @override
  String get videoNoteMaxDuration => '最长30秒';

  @override
  String get videoNoteNotSupported => '此平台不支持视频备注';

  @override
  String get navChats => '聊天';

  @override
  String get navUpdates => '动态';

  @override
  String get navCalls => '通话';

  @override
  String get filterAll => '全部';

  @override
  String get filterUnread => '未读';

  @override
  String get filterGroups => '群组';

  @override
  String get callsNoRecent => '没有最近通话';

  @override
  String get callsEmptySubtitle => '您的通话记录将显示在这里';

  @override
  String get appBarEncrypted => '端对端加密';

  @override
  String get newStatus => '新状态';

  @override
  String get newCall => '新通话';

  @override
  String get joinChannelTitle => '加入频道';

  @override
  String get joinChannelDescription => '频道 URL';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => '正在获取频道信息…';

  @override
  String get joinChannelNotFound => '在此 URL 未找到频道';

  @override
  String get joinChannelNetworkError => '无法连接到服务器';

  @override
  String get joinChannelAlreadyJoined => '已加入';

  @override
  String get joinChannelButton => '加入';

  @override
  String get channelFeedEmpty => '暂无帖子';

  @override
  String get channelLeave => '退出频道';

  @override
  String get channelLeaveConfirm => '退出此频道？缓存的帖子将被删除。';

  @override
  String get channelInfo => '频道信息';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => '已编辑';

  @override
  String get channelLoadMore => '加载更多';

  @override
  String get channelSearchPosts => '搜索帖子…';

  @override
  String get channelNoResults => '没有匹配的帖子';

  @override
  String get channelUrl => '频道 URL';

  @override
  String get channelCreated => '已加入';

  @override
  String channelPostCount(int count) {
    return '$count 篇帖子';
  }

  @override
  String get channelCopyUrl => '复制 URL';

  @override
  String get setupNext => '下一步';

  @override
  String get setupKeyWarning => '将为您生成恢复密钥。这是在新设备上恢复账户的唯一方式 — 没有服务器，没有密码重置。';

  @override
  String get setupKeyTitle => '您的恢复密钥';

  @override
  String get setupKeySubtitle => '写下此密钥并存放在安全的地方。在新设备上恢复账户时需要它。';

  @override
  String get setupKeyCopied => '已复制！';

  @override
  String get setupKeyWroteItDown => '我已记下';

  @override
  String get setupKeyWarnBody => '请记下此密钥作为备份。您也可以稍后在设置 → 安全中查看。';

  @override
  String get setupVerifyTitle => '验证恢复密钥';

  @override
  String get setupVerifySubtitle => '重新输入恢复密钥以确认您已正确保存。';

  @override
  String get setupVerifyButton => '验证';

  @override
  String get setupKeyMismatch => '密钥不匹配。请检查后重试。';

  @override
  String get setupSkipVerify => '跳过验证';

  @override
  String get setupSkipVerifyTitle => '跳过验证？';

  @override
  String get setupSkipVerifyBody => '如果您丢失恢复密钥，将无法恢复账户。确定吗？';

  @override
  String get setupCreatingAccount => '正在创建账户…';

  @override
  String get setupRestoringAccount => '正在恢复账户…';

  @override
  String get restoreKeyInfoBanner =>
      '输入恢复密钥 — 您的地址（Nostr + Session）将自动恢复。联系人和消息仅存储在本地。';

  @override
  String get restoreKeyHint => '恢复密钥';

  @override
  String get settingsViewRecoveryKey => '查看恢复密钥';

  @override
  String get settingsViewRecoveryKeySubtitle => '显示您的账户恢复密钥';

  @override
  String get settingsRecoveryKeyNotStored => '恢复密钥不可用（在此功能之前创建）';

  @override
  String get settingsRecoveryKeyWarning => '请妥善保管此密钥。任何拥有它的人都可以在其他设备上恢复您的账户。';

  @override
  String get replaceIdentityTitle => '替换现有身份？';

  @override
  String get replaceIdentityBodyRestore =>
      '此设备上已存在身份。恢复将永久替换您当前的 Nostr 密钥和 Oxen 种子。所有联系人将无法联系您的当前地址。\n\n此操作无法撤销。';

  @override
  String get replaceIdentityBodyCreate =>
      '此设备上已存在身份。创建新身份将永久替换您当前的 Nostr 密钥和 Oxen 种子。所有联系人将无法联系您的当前地址。\n\n此操作无法撤销。';

  @override
  String get replace => '替换';

  @override
  String get callNoScreenSources => '没有可用的屏幕源';

  @override
  String get callScreenShareQuality => '屏幕共享质量';

  @override
  String get callFrameRate => '帧率';

  @override
  String get callResolution => '分辨率';

  @override
  String get callAutoResolution => '自动 = 原生屏幕分辨率';

  @override
  String get callStartSharing => '开始共享';

  @override
  String get callCameraUnavailable => '摄像头不可用 — 可能正被其他应用使用';

  @override
  String get themeResetToDefaults => '重置为默认';

  @override
  String get backupSaveToDownloadsTitle => '将备份保存到下载？';

  @override
  String backupSaveToDownloadsBody(String path) {
    return '没有可用的文件选择器。备份将保存到：\n$path';
  }

  @override
  String get systemLabel => '系统';

  @override
  String get next => '下一步';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return '再点击 $remaining 次以启用开发者模式';
  }

  @override
  String get devModeEnabled => '开发者模式已启用';

  @override
  String get devTools => '开发者工具';

  @override
  String get devAdapterDiagnostics => '适配器开关与诊断';

  @override
  String get devEnableAll => '全部启用';

  @override
  String get devDisableAll => '全部禁用';

  @override
  String get turnUrlValidation => 'TURN URL 必须以 turn: 或 turns: 开头（最多 512 个字符）';

  @override
  String get callMissedCall => '未接来电';

  @override
  String get callOutgoingCall => '去电';

  @override
  String get callIncomingCall => '来电';

  @override
  String get mediaMissingData => '缺少媒体数据';

  @override
  String get mediaDownloadFailed => '下载失败';

  @override
  String get mediaDecryptFailed => '解密失败';

  @override
  String get callEndCallBanner => '结束通话';

  @override
  String get meFallback => '我';

  @override
  String get imageSaveToDownloads => '保存到下载';

  @override
  String imageSavedToPath(String path) {
    return '已保存到 $path';
  }

  @override
  String get callScreenShareRequiresPermission => '屏幕共享需要权限';

  @override
  String get callScreenShareUnavailable => '屏幕共享不可用';

  @override
  String get statusJustNow => '刚刚';

  @override
  String statusMinutesAgo(int minutes) {
    return '$minutes分钟前';
  }

  @override
  String statusHoursAgo(int hours) {
    return '$hours小时前';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条路由',
      one: '1 条路由',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => '准备添加';

  @override
  String groupSelectedCount(int count) {
    return '已选择 $count 个';
  }

  @override
  String get paste => '粘贴';

  @override
  String get sfuAudioOnly => '仅音频';

  @override
  String sfuParticipants(int count) {
    return '$count 位参与者';
  }

  @override
  String get dataUnencryptedBackup => '未加密备份';

  @override
  String get dataUnencryptedBackupBody =>
      '此文件是未加密的身份备份，将覆盖您当前的密钥。仅导入您自己创建的文件。是否继续？';

  @override
  String get dataImportAnyway => '仍然导入';

  @override
  String get securityStorageError => '安全存储错误 — 请重启应用';

  @override
  String get aboutDevModeActive => '开发者模式已激活';

  @override
  String get themeColors => '颜色';

  @override
  String get themePrimaryAccent => '主要强调色';

  @override
  String get themeSecondaryAccent => '次要强调色';

  @override
  String get themeBackground => '背景';

  @override
  String get themeSurface => '表面';

  @override
  String get themeChatBubbles => '聊天气泡';

  @override
  String get themeOutgoingMessage => '发送消息';

  @override
  String get themeIncomingMessage => '接收消息';

  @override
  String get themeShape => '形状';

  @override
  String get devSectionDeveloper => '开发者';

  @override
  String get devAdapterChannelsHint => '适配器通道 — 禁用以测试特定传输。';

  @override
  String get devNostrRelays => 'Nostr 中继 (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Session 网络';

  @override
  String get devPulseRelay => 'Pulse 自托管中继';

  @override
  String get devLanNetwork => '本地网络 (UDP/TCP)';

  @override
  String get devSectionCalls => '通话';

  @override
  String get devForceTurnRelay => '强制 TURN 中继';

  @override
  String get devForceTurnRelaySubtitle => '禁用 P2P — 所有通话仅通过 TURN 服务器';

  @override
  String get devRestartWarning => '⚠ 更改将在下次发送/通话时生效。重启应用以应用于传入连接。';

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
}
