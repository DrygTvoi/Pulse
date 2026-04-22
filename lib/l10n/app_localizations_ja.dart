// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'メッセージを検索...';

  @override
  String get search => '検索';

  @override
  String get clearSearch => '検索をクリア';

  @override
  String get closeSearch => '検索を閉じる';

  @override
  String get moreOptions => 'その他のオプション';

  @override
  String get back => '戻る';

  @override
  String get cancel => 'キャンセル';

  @override
  String get close => '閉じる';

  @override
  String get confirm => '確認';

  @override
  String get remove => '削除';

  @override
  String get save => '保存';

  @override
  String get add => '追加';

  @override
  String get copy => 'コピー';

  @override
  String get skip => 'スキップ';

  @override
  String get done => '完了';

  @override
  String get apply => '適用';

  @override
  String get export => 'エクスポート';

  @override
  String get import => 'インポート';

  @override
  String get homeNewGroup => '新しいグループ';

  @override
  String get homeSettings => '設定';

  @override
  String get homeSearching => 'メッセージを検索中...';

  @override
  String get homeNoResults => '結果が見つかりません';

  @override
  String get homeNoChatHistory => 'チャット履歴はまだありません';

  @override
  String homeTransportSwitched(String address) {
    return 'トランスポートが切り替わりました → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name から着信中...';
  }

  @override
  String get homeAccept => '応答';

  @override
  String get homeDecline => '拒否';

  @override
  String get homeLoadEarlier => '以前のメッセージを読み込む';

  @override
  String get homeChats => 'チャット';

  @override
  String get homeSelectConversation => '会話を選択してください';

  @override
  String get homeNoChatsYet => 'チャットはまだありません';

  @override
  String get homeAddContactToStart => '連絡先を追加してチャットを始めましょう';

  @override
  String get homeNewChat => '新しいチャット';

  @override
  String get homeNewChatTooltip => '新しいチャット';

  @override
  String get homeIncomingCallTitle => '着信';

  @override
  String get homeIncomingGroupCallTitle => 'グループ着信';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — グループ通話の着信';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return '\"$query\"に一致するチャットはありません';
  }

  @override
  String get homeSectionChats => 'チャット';

  @override
  String get homeSectionMessages => 'メッセージ';

  @override
  String get homeDbEncryptionUnavailable =>
      'データベース暗号化が利用できません — 完全な保護のためにSQLCipherをインストールしてください';

  @override
  String get chatFileTooLargeGroup => 'グループチャットでは512 KBを超えるファイルはサポートされていません';

  @override
  String get chatLargeFile => '大きなファイル';

  @override
  String get chatCancel => 'キャンセル';

  @override
  String get chatSend => '送信';

  @override
  String get chatFileTooLarge => 'ファイルが大きすぎます — 最大サイズは100 MBです';

  @override
  String get chatMicDenied => 'マイクの権限が拒否されました';

  @override
  String get chatVoiceFailed => 'ボイスメッセージの保存に失敗しました — 空き容量を確認してください';

  @override
  String get chatScheduleFuture => '予約送信の時刻は未来でなければなりません';

  @override
  String get chatToday => '今日';

  @override
  String get chatYesterday => '昨日';

  @override
  String get chatEdited => '編集済み';

  @override
  String get chatYou => 'あなた';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'このファイルは$size MBです。一部のネットワークでは大きなファイルの送信に時間がかかる場合があります。続行しますか？';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return '$nameのセキュリティキーが変更されました。タップして確認してください。';
  }

  @override
  String chatEncryptionFailed(String name) {
    return '$nameへのメッセージを暗号化できませんでした — メッセージは送信されませんでした。';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return '$nameの安全番号が変更されました。タップして確認してください。';
  }

  @override
  String get chatNoMessagesFound => 'メッセージが見つかりません';

  @override
  String get chatMessagesE2ee => 'メッセージはエンドツーエンド暗号化されています';

  @override
  String get chatSayHello => '挨拶を送りましょう';

  @override
  String get appBarOnline => 'オンライン';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => '入力中';

  @override
  String get appBarSearchMessages => 'メッセージを検索...';

  @override
  String get appBarMute => 'ミュート';

  @override
  String get appBarUnmute => 'ミュート解除';

  @override
  String get appBarMedia => 'メディア';

  @override
  String get appBarDisappearing => '消えるメッセージ';

  @override
  String get appBarDisappearingOn => '消えるメッセージ：オン';

  @override
  String get appBarGroupSettings => 'グループ設定';

  @override
  String get appBarSearchTooltip => 'メッセージを検索';

  @override
  String get appBarVoiceCall => '音声通話';

  @override
  String get appBarVideoCall => 'ビデオ通話';

  @override
  String get inputMessage => 'メッセージ...';

  @override
  String get inputAttachFile => 'ファイルを添付';

  @override
  String get inputSendMessage => 'メッセージを送信';

  @override
  String get inputRecordVoice => 'ボイスメッセージを録音';

  @override
  String get inputSendVoice => 'ボイスメッセージを送信';

  @override
  String get inputCancelReply => '返信をキャンセル';

  @override
  String get inputCancelEdit => '編集をキャンセル';

  @override
  String get inputCancelRecording => '録音をキャンセル';

  @override
  String get inputRecording => '録音中…';

  @override
  String get inputEditingMessage => 'メッセージを編集中';

  @override
  String get inputPhoto => '写真';

  @override
  String get inputVoiceMessage => 'ボイスメッセージ';

  @override
  String get inputFile => 'ファイル';

  @override
  String inputScheduledMessages(int count) {
    return '予約メッセージ $count件';
  }

  @override
  String get callInitializing => '通話を初期化中…';

  @override
  String get callConnecting => '接続中…';

  @override
  String get callConnectingRelay => '接続中（リレー）…';

  @override
  String get callSwitchingRelay => 'リレーモードに切り替え中…';

  @override
  String get callConnectionFailed => '接続に失敗しました';

  @override
  String get callReconnecting => '再接続中…';

  @override
  String get callEnded => '通話が終了しました';

  @override
  String get callLive => '通話中';

  @override
  String get callEnd => '終了';

  @override
  String get callEndCall => '通話を終了';

  @override
  String get callMute => 'ミュート';

  @override
  String get callUnmute => 'ミュート解除';

  @override
  String get callSpeaker => 'スピーカー';

  @override
  String get callCameraOn => 'カメラオン';

  @override
  String get callCameraOff => 'カメラオフ';

  @override
  String get callShareScreen => '画面共有';

  @override
  String get callStopShare => '共有を停止';

  @override
  String callTorBackup(String duration) {
    return 'Torバックアップ · $duration';
  }

  @override
  String get callTorBackupBanner => 'Torバックアップがアクティブ — プライマリ経路が利用不可';

  @override
  String get callDirectFailed => '直接接続に失敗しました — リレーモードに切り替え中…';

  @override
  String get callTurnUnreachable =>
      'TURNサーバーに到達できません。設定 → 詳細設定でカスタムTURNサーバーを追加してください。';

  @override
  String get callRelayMode => 'リレーモードがアクティブ（制限されたネットワーク）';

  @override
  String get callStarting => '通話を開始中…';

  @override
  String get callConnectingToGroup => 'グループに接続中…';

  @override
  String get callGroupOpenedInBrowser => 'グループ通話がブラウザで開かれました';

  @override
  String get callCouldNotOpenBrowser => 'ブラウザを開けませんでした';

  @override
  String get callInviteLinkSent => '招待リンクがすべてのグループメンバーに送信されました。';

  @override
  String get callOpenLinkManually => '上のリンクを手動で開くか、タップしてリトライしてください。';

  @override
  String get callJitsiNotE2ee => 'Jitsi通話はエンドツーエンド暗号化されていません';

  @override
  String get callRetryOpenBrowser => 'ブラウザを再度開く';

  @override
  String get callClose => '閉じる';

  @override
  String get callCamOn => 'カメラオン';

  @override
  String get callCamOff => 'カメラオフ';

  @override
  String get noConnection => '接続なし — メッセージはキューに入ります';

  @override
  String get connected => '接続済み';

  @override
  String get connecting => '接続中…';

  @override
  String get disconnected => '切断済み';

  @override
  String get offlineBanner => '接続なし — オンラインに戻った際にメッセージが送信されます';

  @override
  String get lanModeBanner => 'LANモード — インターネットなし · ローカルネットワークのみ';

  @override
  String get probeCheckingNetwork => 'ネットワーク接続を確認中…';

  @override
  String get probeDiscoveringRelays => 'コミュニティディレクトリからリレーを検出中…';

  @override
  String get probeStartingTor => 'ブートストラップ用にTorを起動中…';

  @override
  String get probeFindingRelaysTor => 'Tor経由で到達可能なリレーを検索中…';

  @override
  String probeNetworkReady(int count) {
    return 'ネットワーク準備完了 — $count個のリレーが見つかりました';
  }

  @override
  String get probeNoRelaysFound => '到達可能なリレーが見つかりません — メッセージが遅延する可能性があります';

  @override
  String get jitsiWarningTitle => 'エンドツーエンド暗号化されていません';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet通話はPulseによる暗号化の対象外です。機密性の低い会話にのみ使用してください。';

  @override
  String get jitsiConfirm => 'それでも参加';

  @override
  String get jitsiGroupWarningTitle => 'エンドツーエンド暗号化されていません';

  @override
  String get jitsiGroupWarningBody =>
      'この通話は参加者が多すぎるため、内蔵の暗号化メッシュを使用できません。\n\nJitsi Meetのリンクがブラウザで開かれます。Jitsiはエンドツーエンド暗号化されていません — サーバーが通話を閲覧できます。';

  @override
  String get jitsiContinueAnyway => 'それでも続行';

  @override
  String get retry => 'リトライ';

  @override
  String get setupCreateAnonymousAccount => '匿名アカウントを作成';

  @override
  String get setupTapToChangeColor => 'タップして色を変更';

  @override
  String get setupReqMinLength => '16文字以上';

  @override
  String get setupReqVariety => '4種類中3種類: 大文字、小文字、数字、記号';

  @override
  String get setupReqMatch => 'パスワードが一致';

  @override
  String get setupYourNickname => 'ニックネーム';

  @override
  String get setupRecoveryPassword => '復元パスワード（16文字以上）';

  @override
  String get setupConfirmPassword => 'パスワードを確認';

  @override
  String get setupMin16Chars => '16文字以上必要です';

  @override
  String get setupPasswordsDoNotMatch => 'パスワードが一致しません';

  @override
  String get setupEntropyWeak => '弱い';

  @override
  String get setupEntropyOk => '普通';

  @override
  String get setupEntropyStrong => '強い';

  @override
  String get setupEntropyWeakNeedsVariety => '弱い（3種類以上の文字が必要）';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label（$bitsビット）';
  }

  @override
  String get setupPasswordWarning =>
      'このパスワードはアカウントを復元する唯一の方法です。サーバーはありません — パスワードのリセットはできません。覚えておくか、書き留めてください。';

  @override
  String get setupCreateAccount => 'アカウントを作成';

  @override
  String get setupAlreadyHaveAccount => 'すでにアカウントをお持ちですか？';

  @override
  String get setupRestore => '復元 →';

  @override
  String get restoreTitle => 'アカウントを復元';

  @override
  String get restoreInfoBanner =>
      '復元パスワードを入力してください — アドレス（Nostr + Session）が自動的に復元されます。連絡先とメッセージはローカルにのみ保存されていました。';

  @override
  String get restoreNewNickname => '新しいニックネーム（後で変更可能）';

  @override
  String get restoreButton => 'アカウントを復元';

  @override
  String get lockTitle => 'Pulseはロックされています';

  @override
  String get lockSubtitle => 'パスワードを入力して続行';

  @override
  String get lockPasswordHint => 'パスワード';

  @override
  String get lockUnlock => 'ロック解除';

  @override
  String get lockPanicHint => 'パスワードを忘れましたか？パニックキーを入力するとすべてのデータが消去されます。';

  @override
  String get lockTooManyAttempts => '試行回数が多すぎます。すべてのデータを消去中…';

  @override
  String get lockWrongPassword => 'パスワードが正しくありません';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'パスワードが正しくありません — $attempts/$max回目';
  }

  @override
  String get onboardingSkip => 'スキップ';

  @override
  String get onboardingNext => '次へ';

  @override
  String get onboardingGetStarted => 'アカウントを作成';

  @override
  String get onboardingWelcomeTitle => 'Pulseへようこそ';

  @override
  String get onboardingWelcomeBody =>
      '分散型でエンドツーエンド暗号化されたメッセンジャーです。\n\n中央サーバーなし。データ収集なし。バックドアなし。\nあなたの会話はあなただけのものです。';

  @override
  String get onboardingTransportTitle => 'トランスポート非依存';

  @override
  String get onboardingTransportBody =>
      'Firebase、Nostr、またはその両方を同時に使用できます。\n\nメッセージはネットワーク間で自動ルーティングされます。検閲耐性のためのTorとI2Pサポートを内蔵。';

  @override
  String get onboardingSignalTitle => 'Signal + ポスト量子暗号';

  @override
  String get onboardingSignalBody =>
      'すべてのメッセージはSignalプロトコル（Double Ratchet + X3DH）で暗号化され、前方秘匿性を提供します。\n\nさらにKyber-1024 — NISTの標準ポスト量子アルゴリズム — で包み、将来の量子コンピュータから保護します。';

  @override
  String get onboardingKeysTitle => '鍵はあなたの手に';

  @override
  String get onboardingKeysBody =>
      'あなたのID鍵はデバイスの外に出ることはありません。\n\nSignalフィンガープリントにより、帯域外で連絡先を確認できます。TOFU（初回信頼）が鍵の変更を自動検出します。';

  @override
  String get onboardingThemeTitle => '外観を選択';

  @override
  String get onboardingThemeBody => 'テーマとアクセントカラーを選んでください。設定からいつでも変更できます。';

  @override
  String get contactsNewChat => '新しいチャット';

  @override
  String get contactsAddContact => '連絡先を追加';

  @override
  String get contactsSearchHint => '検索...';

  @override
  String get contactsNewGroup => '新しいグループ';

  @override
  String get contactsNoContactsYet => '連絡先はまだありません';

  @override
  String get contactsAddHint => '+ をタップしてアドレスを追加';

  @override
  String get contactsNoMatch => '一致する連絡先がありません';

  @override
  String get contactsRemoveTitle => '連絡先を削除';

  @override
  String contactsRemoveMessage(String name) {
    return '$nameを削除しますか？';
  }

  @override
  String get contactsRemove => '削除';

  @override
  String contactsCount(int count) {
    return '$count件の連絡先';
  }

  @override
  String get bubbleOpenLink => 'リンクを開く';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'このURLをブラウザで開きますか？\n\n$url';
  }

  @override
  String get bubbleOpen => '開く';

  @override
  String get bubbleSecurityWarning => 'セキュリティ警告';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\"は実行可能なファイルです。保存して実行するとデバイスに害を及ぼす可能性があります。それでも保存しますか？';
  }

  @override
  String get bubbleSaveAnyway => 'それでも保存';

  @override
  String bubbleSavedTo(String path) {
    return '$pathに保存しました';
  }

  @override
  String bubbleSaveFailed(String error) {
    return '保存に失敗しました：$error';
  }

  @override
  String get bubbleNotEncrypted => '暗号化されていません';

  @override
  String get bubbleCorruptedImage => '[破損した画像]';

  @override
  String get bubbleReplyPhoto => '写真';

  @override
  String get bubbleReplyVoice => 'ボイスメッセージ';

  @override
  String get bubbleReplyVideo => 'ビデオメッセージ';

  @override
  String bubbleReadBy(String names) {
    return '既読：$names';
  }

  @override
  String bubbleReadByCount(int count) {
    return '$count人が既読';
  }

  @override
  String get chatTileTapToStart => 'タップしてチャットを開始';

  @override
  String get chatTileMessageSent => 'メッセージ送信済み';

  @override
  String get chatTileEncryptedMessage => '暗号化されたメッセージ';

  @override
  String chatTileYouPrefix(String text) {
    return 'あなた：$text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 音声メッセージ';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 音声メッセージ ($duration)';
  }

  @override
  String get bannerEncryptedMessage => '暗号化されたメッセージ';

  @override
  String get groupNewGroup => '新しいグループ';

  @override
  String get groupGroupName => 'グループ名';

  @override
  String get groupSelectMembers => 'メンバーを選択（2人以上）';

  @override
  String get groupNoContactsYet => '連絡先がありません。先に連絡先を追加してください。';

  @override
  String get groupCreate => '作成';

  @override
  String get groupLabel => 'グループ';

  @override
  String get profileVerifyIdentity => '本人確認';

  @override
  String profileVerifyInstructions(String name) {
    return '音声通話または直接会って、$nameとこれらのフィンガープリントを比較してください。両方のデバイスで値が一致したら、「確認済みにする」をタップしてください。';
  }

  @override
  String get profileTheirKey => '相手の鍵';

  @override
  String get profileYourKey => 'あなたの鍵';

  @override
  String get profileRemoveVerification => '確認を解除';

  @override
  String get profileMarkAsVerified => '確認済みにする';

  @override
  String get profileAddressCopied => 'アドレスをコピーしました';

  @override
  String get profileNoContactsToAdd => '追加できる連絡先がありません — 全員がすでにメンバーです';

  @override
  String get profileAddMembers => 'メンバーを追加';

  @override
  String profileAddCount(int count) {
    return '追加（$count）';
  }

  @override
  String get profileRenameGroup => 'グループ名を変更';

  @override
  String get profileRename => '名前を変更';

  @override
  String get profileRemoveMember => 'メンバーを削除しますか？';

  @override
  String profileRemoveMemberBody(String name) {
    return '$nameをこのグループから削除しますか？';
  }

  @override
  String get profileKick => '削除';

  @override
  String get profileSignalFingerprints => 'Signalフィンガープリント';

  @override
  String get profileVerified => '確認済み';

  @override
  String get profileVerify => '確認';

  @override
  String get profileEdit => '編集';

  @override
  String get profileNoSession => 'セッションがまだ確立されていません — まずメッセージを送信してください。';

  @override
  String get profileFingerprintCopied => 'フィンガープリントをコピーしました';

  @override
  String profileMemberCount(int count) {
    return '$count人のメンバー';
  }

  @override
  String get profileVerifySafetyNumber => '安全番号を確認';

  @override
  String get profileShowContactQr => '連絡先のQRを表示';

  @override
  String profileContactAddress(String name) {
    return '$nameのアドレス';
  }

  @override
  String get profileExportChatHistory => 'チャット履歴をエクスポート';

  @override
  String profileSavedTo(String path) {
    return '$pathに保存しました';
  }

  @override
  String get profileExportFailed => 'エクスポートに失敗しました';

  @override
  String get profileClearChatHistory => 'チャット履歴を消去';

  @override
  String get profileDeleteGroup => 'グループを削除';

  @override
  String get profileDeleteContact => '連絡先を削除';

  @override
  String get profileLeaveGroup => 'グループを退出';

  @override
  String get profileLeaveGroupBody => 'このグループから退出し、連絡先からも削除されます。';

  @override
  String get groupInviteTitle => 'グループ招待';

  @override
  String groupInviteBody(String from, String group) {
    return '$fromがあなたを\"$group\"に招待しました';
  }

  @override
  String get groupInviteAccept => '承諾';

  @override
  String get groupInviteDecline => '拒否';

  @override
  String get groupMemberLimitTitle => '参加者が多すぎます';

  @override
  String groupMemberLimitBody(int count) {
    return 'このグループは$count人の参加者になります。暗号化メッシュ通話は最大6人をサポートします。それ以上のグループはJitsi（E2EEではない）にフォールバックします。';
  }

  @override
  String get groupMemberLimitContinue => 'それでも追加';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$nameが\"$group\"への参加を辞退しました';
  }

  @override
  String get transferTitle => '別のデバイスに転送';

  @override
  String get transferInfoBox =>
      'SignalのIDとNostrの鍵を新しいデバイスに転送します。\nチャットセッションは転送されません — 前方秘匿性が保持されます。';

  @override
  String get transferSendFromThis => 'このデバイスから送信';

  @override
  String get transferSendSubtitle => 'このデバイスに鍵があります。新しいデバイスとコードを共有してください。';

  @override
  String get transferReceiveOnThis => 'このデバイスで受信';

  @override
  String get transferReceiveSubtitle => 'これは新しいデバイスです。古いデバイスのコードを入力してください。';

  @override
  String get transferChooseMethod => '転送方法を選択';

  @override
  String get transferLan => 'LAN（同一ネットワーク）';

  @override
  String get transferLanSubtitle => '高速で直接的。両方のデバイスが同じWi-Fiに接続されている必要があります。';

  @override
  String get transferNostrRelay => 'Nostrリレー';

  @override
  String get transferNostrRelaySubtitle =>
      '既存のNostrリレーを使用して、任意のネットワーク経由で転送します。';

  @override
  String get transferRelayUrl => 'リレーURL';

  @override
  String get transferEnterCode => '転送コードを入力';

  @override
  String get transferPasteCode => 'LAN:... または NOS:... のコードをここに貼り付け';

  @override
  String get transferConnect => '接続';

  @override
  String get transferGenerating => '転送コードを生成中…';

  @override
  String get transferShareCode => 'このコードを受信者と共有してください：';

  @override
  String get transferCopyCode => 'コードをコピー';

  @override
  String get transferCodeCopied => 'コードがクリップボードにコピーされました';

  @override
  String get transferWaitingReceiver => '受信者の接続を待機中…';

  @override
  String get transferConnectingSender => '送信者に接続中…';

  @override
  String get transferVerifyBoth => '両方のデバイスでこのコードを比較してください。\n一致すれば、転送は安全です。';

  @override
  String get transferComplete => '転送完了';

  @override
  String get transferKeysImported => '鍵がインポートされました';

  @override
  String get transferCompleteSenderBody =>
      'このデバイスの鍵は引き続き有効です。\n受信者があなたのIDを使用できるようになりました。';

  @override
  String get transferCompleteReceiverBody =>
      '鍵のインポートが成功しました。\n新しいIDを適用するにはアプリを再起動してください。';

  @override
  String get transferRestartApp => 'アプリを再起動';

  @override
  String get transferFailed => '転送に失敗しました';

  @override
  String get transferTryAgain => '再試行';

  @override
  String get transferEnterRelayFirst => 'まずリレーURLを入力してください';

  @override
  String get transferPasteCodeFromSender => '送信者の転送コードを貼り付けてください';

  @override
  String get menuReply => '返信';

  @override
  String get menuForward => '転送';

  @override
  String get menuReact => 'リアクション';

  @override
  String get menuCopy => 'コピー';

  @override
  String get menuEdit => '編集';

  @override
  String get menuRetry => '再試行';

  @override
  String get menuCancelScheduled => '予約を取消';

  @override
  String get menuDelete => '削除';

  @override
  String get menuForwardTo => '転送先…';

  @override
  String menuForwardedTo(String name) {
    return '$nameに転送しました';
  }

  @override
  String get menuScheduledMessages => '予約メッセージ';

  @override
  String get menuNoScheduledMessages => '予約メッセージはありません';

  @override
  String menuSendsOn(String date) {
    return '$dateに送信予定';
  }

  @override
  String get menuDisappearingMessages => '消えるメッセージ';

  @override
  String get menuDisappearingSubtitle => '指定した時間が経過するとメッセージが自動的に削除されます。';

  @override
  String get menuTtlOff => 'オフ';

  @override
  String get menuTtl1h => '1時間';

  @override
  String get menuTtl24h => '24時間';

  @override
  String get menuTtl7d => '7日間';

  @override
  String get menuAttachPhoto => '写真';

  @override
  String get menuAttachFile => 'ファイル';

  @override
  String get menuAttachVideo => '動画';

  @override
  String get mediaTitle => 'メディア';

  @override
  String get mediaFileLabel => 'ファイル';

  @override
  String mediaPhotosTab(int count) {
    return '写真（$count）';
  }

  @override
  String mediaFilesTab(int count) {
    return 'ファイル（$count）';
  }

  @override
  String get mediaNoPhotos => '写真はまだありません';

  @override
  String get mediaNoFiles => 'ファイルはまだありません';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Downloads/$nameに保存しました';
  }

  @override
  String get mediaFailedToSave => 'ファイルの保存に失敗しました';

  @override
  String get statusNewStatus => '新しいステータス';

  @override
  String get statusPublish => '公開';

  @override
  String get statusExpiresIn24h => 'ステータスは24時間で期限切れになります';

  @override
  String get statusWhatsOnYourMind => '今何を考えていますか？';

  @override
  String get statusPhotoAttached => '写真を添付済み';

  @override
  String get statusAttachPhoto => '写真を添付（任意）';

  @override
  String get statusEnterText => 'ステータスのテキストを入力してください。';

  @override
  String statusPickPhotoFailed(String error) {
    return '写真の選択に失敗しました：$error';
  }

  @override
  String statusPublishFailed(String error) {
    return '公開に失敗しました：$error';
  }

  @override
  String get panicSetPanicKey => 'パニックキーを設定';

  @override
  String get panicEmergencySelfDestruct => '緊急自己消去';

  @override
  String get panicIrreversible => 'この操作は元に戻せません';

  @override
  String get panicWarningBody =>
      'ロック画面でこのキーを入力すると、すべてのデータが即座に消去されます — メッセージ、連絡先、鍵、ID。通常のパスワードとは異なるキーを使用してください。';

  @override
  String get panicKeyHint => 'パニックキー';

  @override
  String get panicConfirmHint => 'パニックキーを確認';

  @override
  String get panicMinChars => 'パニックキーは8文字以上必要です';

  @override
  String get panicKeysDoNotMatch => 'キーが一致しません';

  @override
  String get panicSetFailed => 'パニックキーの保存に失敗しました — 再試行してください';

  @override
  String get passwordSetAppPassword => 'アプリパスワードを設定';

  @override
  String get passwordProtectsMessages => '保存されたメッセージを保護します';

  @override
  String get passwordInfoBanner => 'Pulseを開くたびに必要になります。忘れた場合、データは復元できません。';

  @override
  String get passwordHint => 'パスワード';

  @override
  String get passwordConfirmHint => 'パスワードを確認';

  @override
  String get passwordSetButton => 'パスワードを設定';

  @override
  String get passwordSkipForNow => '今はスキップ';

  @override
  String get passwordMinChars => 'パスワードは8文字以上必要です';

  @override
  String get passwordNeedsVariety => '英字、数字、特殊文字を含める必要があります';

  @override
  String get passwordRequirements => '8文字以上、英字・数字・特殊文字を含む';

  @override
  String get passwordsDoNotMatch => 'パスワードが一致しません';

  @override
  String get profileCardSaved => 'プロフィールを保存しました！';

  @override
  String get profileCardE2eeIdentity => 'E2EE ID';

  @override
  String get profileCardDisplayName => '表示名';

  @override
  String get profileCardDisplayNameHint => '例：田中太郎';

  @override
  String get profileCardAbout => '自己紹介';

  @override
  String get profileCardSaveProfile => 'プロフィールを保存';

  @override
  String get profileCardYourName => 'あなたの名前';

  @override
  String get profileCardAddressCopied => 'アドレスをコピーしました！';

  @override
  String get profileCardInboxAddress => 'あなたの受信アドレス';

  @override
  String get profileCardInboxAddresses => 'あなたの受信アドレス';

  @override
  String get profileCardShareAllAddresses => 'すべてのアドレスを共有（SmartRouter）';

  @override
  String get profileCardShareHint => '連絡先に共有して、メッセージを受け取れるようにしましょう。';

  @override
  String profileCardAllAddressesCopied(int count) {
    return '$count件すべてのアドレスを1つのリンクとしてコピーしました！';
  }

  @override
  String get settingsMyProfile => 'マイプロフィール';

  @override
  String get settingsYourInboxAddress => 'あなたの受信アドレス';

  @override
  String get settingsMyQrCode => '連絡先を共有';

  @override
  String get settingsMyQrSubtitle => 'アドレスのQRコードと招待リンク';

  @override
  String get settingsShareMyAddress => 'アドレスを共有';

  @override
  String get settingsNoAddressYet => 'アドレスがまだありません — まず設定を保存してください';

  @override
  String get settingsInviteLink => '招待リンク';

  @override
  String get settingsRawAddress => '生のアドレス';

  @override
  String get settingsCopyLink => 'リンクをコピー';

  @override
  String get settingsCopyAddress => 'アドレスをコピー';

  @override
  String get settingsInviteLinkCopied => '招待リンクをコピーしました';

  @override
  String get settingsAppearance => '外観';

  @override
  String get settingsThemeEngine => 'テーマエンジン';

  @override
  String get settingsThemeEngineSubtitle => '色とフォントをカスタマイズ';

  @override
  String get settingsSignalProtocol => 'Signalプロトコル';

  @override
  String get settingsSignalProtocolSubtitle => 'E2EE鍵は安全に保存されています';

  @override
  String get settingsActive => '有効';

  @override
  String get settingsIdentityBackup => 'IDバックアップ';

  @override
  String get settingsIdentityBackupSubtitle => 'SignalのIDをエクスポートまたはインポート';

  @override
  String get settingsIdentityBackupBody =>
      'SignalのID鍵をバックアップコードにエクスポート、または既存のコードから復元します。';

  @override
  String get settingsTransferDevice => '別のデバイスに転送';

  @override
  String get settingsTransferDeviceSubtitle => 'LANまたはNostrリレー経由でIDを移動';

  @override
  String get settingsExportIdentity => 'IDをエクスポート';

  @override
  String get settingsExportIdentityBody => 'このバックアップコードをコピーして安全に保管してください：';

  @override
  String get settingsSaveFile => 'ファイルを保存';

  @override
  String get settingsImportIdentity => 'IDをインポート';

  @override
  String get settingsImportIdentityBody =>
      '下にバックアップコードを貼り付けてください。現在のIDが上書きされます。';

  @override
  String get settingsPasteBackupCode => 'バックアップコードをここに貼り付け…';

  @override
  String get settingsIdentityImported => 'IDと連絡先がインポートされました！アプリを再起動して適用してください。';

  @override
  String get settingsSecurity => 'セキュリティ';

  @override
  String get settingsAppPassword => 'アプリパスワード';

  @override
  String get settingsPasswordEnabled => '有効 — 毎回起動時に必要';

  @override
  String get settingsPasswordDisabled => '無効 — パスワードなしで開けます';

  @override
  String get settingsChangePassword => 'パスワードを変更';

  @override
  String get settingsChangePasswordSubtitle => 'アプリロックのパスワードを更新';

  @override
  String get settingsSetPanicKey => 'パニックキーを設定';

  @override
  String get settingsChangePanicKey => 'パニックキーを変更';

  @override
  String get settingsPanicKeySetSubtitle => '緊急消去キーを更新';

  @override
  String get settingsPanicKeyUnsetSubtitle => 'すべてのデータを即座に消去するキー';

  @override
  String get settingsRemovePanicKey => 'パニックキーを削除';

  @override
  String get settingsRemovePanicKeySubtitle => '緊急自己消去機能を無効化';

  @override
  String get settingsRemovePanicKeyBody => '緊急自己消去機能が無効になります。いつでも再度有効にできます。';

  @override
  String get settingsDisableAppPassword => 'アプリパスワードを無効にする';

  @override
  String get settingsEnterCurrentPassword => '現在のパスワードを入力して確認';

  @override
  String get settingsCurrentPassword => '現在のパスワード';

  @override
  String get settingsIncorrectPassword => 'パスワードが正しくありません';

  @override
  String get settingsPasswordUpdated => 'パスワードを更新しました';

  @override
  String get settingsChangePasswordProceed => '現在のパスワードを入力して続行';

  @override
  String get settingsData => 'データ';

  @override
  String get settingsBackupMessages => 'メッセージをバックアップ';

  @override
  String get settingsBackupMessagesSubtitle => '暗号化されたメッセージ履歴をファイルにエクスポート';

  @override
  String get settingsRestoreMessages => 'メッセージを復元';

  @override
  String get settingsRestoreMessagesSubtitle => 'バックアップファイルからメッセージをインポート';

  @override
  String get settingsExportKeys => '鍵をエクスポート';

  @override
  String get settingsExportKeysSubtitle => 'ID鍵を暗号化ファイルに保存';

  @override
  String get settingsImportKeys => '鍵をインポート';

  @override
  String get settingsImportKeysSubtitle => 'エクスポートしたファイルからID鍵を復元';

  @override
  String get settingsBackupPassword => 'バックアップパスワード';

  @override
  String get settingsPasswordCannotBeEmpty => 'パスワードは空にできません';

  @override
  String get settingsPasswordMin4Chars => 'パスワードは4文字以上必要です';

  @override
  String get settingsCallsTurn => '通話とTURN';

  @override
  String get settingsLocalNetwork => 'ローカルネットワーク';

  @override
  String get settingsCensorshipResistance => '検閲耐性';

  @override
  String get settingsNetwork => 'ネットワーク';

  @override
  String get settingsProxyTunnels => 'プロキシとトンネル';

  @override
  String get settingsTurnServers => 'TURNサーバー';

  @override
  String get settingsProviderTitle => 'プロバイダー';

  @override
  String get settingsLanFallback => 'LANフォールバック';

  @override
  String get settingsLanFallbackSubtitle =>
      'インターネットが利用できない場合に、ローカルネットワークでプレゼンスをブロードキャストしメッセージを配信します。信頼できないネットワーク（公共Wi-Fi）では無効にしてください。';

  @override
  String get settingsBgDelivery => 'バックグラウンド配信';

  @override
  String get settingsBgDeliverySubtitle =>
      'アプリが最小化されていてもメッセージを受信し続けます。常駐通知が表示されます。';

  @override
  String get settingsYourInboxProvider => '受信プロバイダー';

  @override
  String get settingsConnectionDetails => '接続の詳細';

  @override
  String get settingsSaveAndConnect => '保存して接続';

  @override
  String get settingsSecondaryInboxes => 'セカンダリ受信ボックス';

  @override
  String get settingsAddSecondaryInbox => 'セカンダリ受信ボックスを追加';

  @override
  String get settingsAdvanced => '詳細設定';

  @override
  String get settingsDiscover => '探索';

  @override
  String get settingsAbout => '情報';

  @override
  String get settingsPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get settingsPrivacyPolicySubtitle => 'Pulseがどのようにデータを保護するか';

  @override
  String get settingsCrashReporting => 'クラッシュレポート';

  @override
  String get settingsCrashReportingSubtitle =>
      '匿名のクラッシュレポートを送信してPulseの改善に役立てます。メッセージの内容や連絡先は一切送信されません。';

  @override
  String get settingsCrashReportingEnabled =>
      'クラッシュレポートが有効になりました — アプリを再起動して適用';

  @override
  String get settingsCrashReportingDisabled =>
      'クラッシュレポートが無効になりました — アプリを再起動して適用';

  @override
  String get settingsSensitiveOperation => '機密操作';

  @override
  String get settingsSensitiveOperationBody =>
      'これらの鍵はあなたのIDです。このファイルを持つ人は誰でもあなたになりすますことができます。安全に保管し、転送後は削除してください。';

  @override
  String get settingsIUnderstandContinue => '理解しました、続行';

  @override
  String get settingsReplaceIdentity => 'IDを置き換えますか？';

  @override
  String get settingsReplaceIdentityBody =>
      '現在のID鍵が上書きされます。既存のSignalセッションは無効になり、連絡先は暗号化を再確立する必要があります。アプリの再起動が必要です。';

  @override
  String get settingsReplaceKeys => '鍵を置き換え';

  @override
  String get settingsKeysImported => '鍵がインポートされました';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count個の鍵がインポートされました。新しいIDで再初期化するためにアプリを再起動してください。';
  }

  @override
  String get settingsRestartNow => '今すぐ再起動';

  @override
  String get settingsLater => '後で';

  @override
  String get profileGroupLabel => 'グループ';

  @override
  String get profileAddButton => '追加';

  @override
  String get profileKickButton => '削除';

  @override
  String get dataSectionTitle => 'データ';

  @override
  String get dataBackupMessages => 'メッセージをバックアップ';

  @override
  String get dataBackupPasswordSubtitle => 'メッセージバックアップを暗号化するパスワードを選んでください。';

  @override
  String get dataBackupConfirmLabel => 'バックアップを作成';

  @override
  String get dataCreatingBackup => 'バックアップを作成中';

  @override
  String get dataBackupPreparing => '準備中...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'メッセージをエクスポート中 $done/$total...';
  }

  @override
  String get dataBackupSavingFile => 'ファイルを保存中...';

  @override
  String get dataSaveMessageBackupDialog => 'メッセージバックアップを保存';

  @override
  String dataBackupSaved(int count, String path) {
    return 'バックアップを保存しました（$count件のメッセージ）\n$path';
  }

  @override
  String get dataBackupFailed => 'バックアップに失敗しました — エクスポートするデータがありません';

  @override
  String dataBackupFailedError(String error) {
    return 'バックアップに失敗しました：$error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'メッセージバックアップを選択';

  @override
  String get dataInvalidBackupFile => '無効なバックアップファイルです（ファイルが小さすぎます）';

  @override
  String get dataNotValidBackupFile => '有効なPulseバックアップファイルではありません';

  @override
  String get dataRestoreMessages => 'メッセージを復元';

  @override
  String get dataRestorePasswordSubtitle => 'このバックアップの作成時に使用したパスワードを入力してください。';

  @override
  String get dataRestoreConfirmLabel => '復元';

  @override
  String get dataRestoringMessages => 'メッセージを復元中';

  @override
  String get dataRestoreDecrypting => '復号中...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'メッセージをインポート中 $done/$total...';
  }

  @override
  String get dataRestoreFailed => '復元に失敗しました — パスワードが間違っているか、ファイルが破損しています';

  @override
  String dataRestoreSuccess(int count) {
    return '$count件の新しいメッセージを復元しました';
  }

  @override
  String get dataRestoreNothingNew => 'インポートする新しいメッセージはありません（すべて既に存在します）';

  @override
  String dataRestoreFailedError(String error) {
    return '復元に失敗しました：$error';
  }

  @override
  String get dataSelectKeyExportDialog => '鍵のエクスポートファイルを選択';

  @override
  String get dataNotValidKeyFile => '有効なPulse鍵エクスポートファイルではありません';

  @override
  String get dataExportKeys => '鍵をエクスポート';

  @override
  String get dataExportKeysPasswordSubtitle => '鍵のエクスポートを暗号化するパスワードを選んでください。';

  @override
  String get dataExportKeysConfirmLabel => 'エクスポート';

  @override
  String get dataExportingKeys => '鍵をエクスポート中';

  @override
  String get dataExportingKeysStatus => 'ID鍵を暗号化中...';

  @override
  String get dataSaveKeyExportDialog => '鍵のエクスポートを保存';

  @override
  String dataKeysExportedTo(String path) {
    return '鍵をエクスポートしました：\n$path';
  }

  @override
  String get dataExportFailed => 'エクスポートに失敗しました — 鍵が見つかりません';

  @override
  String dataExportFailedError(String error) {
    return 'エクスポートに失敗しました：$error';
  }

  @override
  String get dataImportKeys => '鍵をインポート';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'この鍵エクスポートの暗号化に使用したパスワードを入力してください。';

  @override
  String get dataImportKeysConfirmLabel => 'インポート';

  @override
  String get dataImportingKeys => '鍵をインポート中';

  @override
  String get dataImportingKeysStatus => 'ID鍵を復号中...';

  @override
  String get dataImportFailed => 'インポートに失敗しました — パスワードが間違っているか、ファイルが破損しています';

  @override
  String dataImportFailedError(String error) {
    return 'インポートに失敗しました：$error';
  }

  @override
  String get securitySectionTitle => 'セキュリティ';

  @override
  String get securityIncorrectPassword => 'パスワードが正しくありません';

  @override
  String get securityPasswordUpdated => 'パスワードを更新しました';

  @override
  String get appearanceSectionTitle => '外観';

  @override
  String appearanceExportFailed(String error) {
    return 'エクスポートに失敗しました：$error';
  }

  @override
  String appearanceSavedTo(String path) {
    return '$pathに保存しました';
  }

  @override
  String appearanceSaveFailed(String error) {
    return '保存に失敗しました：$error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'インポートに失敗しました：$error';
  }

  @override
  String get aboutSectionTitle => '情報';

  @override
  String get providerPublicKey => '公開鍵';

  @override
  String get providerRelay => 'リレー';

  @override
  String get providerAutoConfigured => '復元パスワードから自動設定されました。リレーは自動検出されます。';

  @override
  String get providerKeyStoredLocally =>
      '鍵はローカルのセキュアストレージに保存されています — サーバーには一切送信されません。';

  @override
  String get providerSessionInfo =>
      'Session Network — オニオンルーティングE2EE。Session IDは自動生成され、安全に保存されます。ノードは組み込みシードノードから自動的に検出されます。';

  @override
  String get providerAdvanced => '詳細設定';

  @override
  String get providerSaveAndConnect => '保存して接続';

  @override
  String get providerAddSecondaryInbox => 'セカンダリ受信ボックスを追加';

  @override
  String get providerSecondaryInboxes => 'セカンダリ受信ボックス';

  @override
  String get providerYourInboxProvider => '受信プロバイダー';

  @override
  String get providerConnectionDetails => '接続の詳細';

  @override
  String get addContactTitle => '連絡先を追加';

  @override
  String get addContactInviteLinkLabel => '招待リンクまたはアドレス';

  @override
  String get addContactTapToPaste => 'タップして招待リンクを貼り付け';

  @override
  String get addContactPasteTooltip => 'クリップボードから貼り付け';

  @override
  String get addContactAddressDetected => '連絡先アドレスを検出しました';

  @override
  String addContactRoutesDetected(int count) {
    return '$countつのルートを検出 — SmartRouterが最速を選択します';
  }

  @override
  String get addContactFetchingProfile => 'プロフィールを取得中…';

  @override
  String addContactProfileFound(String name) {
    return '見つかりました：$name';
  }

  @override
  String get addContactNoProfileFound => 'プロフィールが見つかりません';

  @override
  String get addContactDisplayNameLabel => '表示名';

  @override
  String get addContactDisplayNameHint => 'どのように呼びますか？';

  @override
  String get addContactAddManually => 'アドレスを手動で追加';

  @override
  String get addContactButton => '連絡先を追加';

  @override
  String get networkDiagnosticsTitle => 'ネットワーク診断';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostrリレー';

  @override
  String get networkDiagnosticsDirect => '直接';

  @override
  String get networkDiagnosticsTorOnly => 'Torのみ';

  @override
  String get networkDiagnosticsBest => '最良';

  @override
  String get networkDiagnosticsNone => 'なし';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'ステータス';

  @override
  String get networkDiagnosticsConnected => '接続済み';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return '接続中 $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'オフ';

  @override
  String get networkDiagnosticsTransport => 'トランスポート';

  @override
  String get networkDiagnosticsInfrastructure => 'インフラストラクチャ';

  @override
  String get networkDiagnosticsSessionNodes => 'Sessionノード';

  @override
  String get networkDiagnosticsTurnServers => 'TURNサーバー';

  @override
  String get networkDiagnosticsLastProbe => '最終探索';

  @override
  String get networkDiagnosticsRunning => '実行中...';

  @override
  String get networkDiagnosticsRunDiagnostics => '診断を実行';

  @override
  String get networkDiagnosticsForceReprobe => '完全な再探索を強制';

  @override
  String get networkDiagnosticsJustNow => 'たった今';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes分前';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours時間前';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days日前';
  }

  @override
  String get homeNoEch => 'ECHなし';

  @override
  String get homeNoEchTooltip => 'uTLSプロキシが利用不可 — ECH無効。\nTLSフィンガープリントがDPIに可視。';

  @override
  String get settingsTitle => '設定';

  @override
  String settingsSavedConnectedTo(String provider) {
    return '保存して$providerに接続しました';
  }

  @override
  String get settingsTorFailedToStart => '内蔵Torの起動に失敗しました';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphonの起動に失敗しました';

  @override
  String get verifyTitle => '安全番号を確認';

  @override
  String get verifyIdentityVerified => '本人確認済み';

  @override
  String get verifyNotYetVerified => '未確認';

  @override
  String verifyVerifiedDescription(String name) {
    return '$nameの安全番号を確認しました。';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return '直接会うか、信頼できるチャネルで$nameとこれらの番号を比較してください。';
  }

  @override
  String get verifyExplanation =>
      '各会話には固有の安全番号があります。両方のデバイスで同じ番号が表示されていれば、接続はエンドツーエンドで確認されています。';

  @override
  String verifyContactKey(String name) {
    return '$nameの鍵';
  }

  @override
  String get verifyYourKey => 'あなたの鍵';

  @override
  String get verifyRemoveVerification => '確認を解除';

  @override
  String get verifyMarkAsVerified => '確認済みにする';

  @override
  String verifyAfterReinstall(String name) {
    return '$nameがアプリを再インストールすると、安全番号が変わり、確認は自動的に解除されます。';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return '音声通話または直接会って$nameと番号を比較した後にのみ、確認済みにしてください。';
  }

  @override
  String get verifyNoSession =>
      '暗号化セッションがまだ確立されていません。安全番号を生成するには、まずメッセージを送信してください。';

  @override
  String get verifyNoKeyAvailable => '利用可能な鍵がありません';

  @override
  String verifyFingerprintCopied(String label) {
    return '$labelのフィンガープリントをコピーしました';
  }

  @override
  String get providerDatabaseUrlLabel => 'データベースURL';

  @override
  String get providerOptionalHint => '任意';

  @override
  String get providerWebApiKeyLabel => 'Web APIキー';

  @override
  String get providerOptionalForPublicDb => '公開DBの場合は任意';

  @override
  String get providerRelayUrlLabel => 'リレーURL';

  @override
  String get providerPrivateKeyLabel => '秘密鍵';

  @override
  String get providerPrivateKeyNsecLabel => '秘密鍵（nsec）';

  @override
  String get providerStorageNodeLabel => 'ストレージノードURL（任意）';

  @override
  String get providerStorageNodeHint => '組み込みシードノードを使う場合は空にする';

  @override
  String get transferInvalidCodeFormat =>
      '認識できないコード形式です — LAN: または NOS: で始まる必要があります';

  @override
  String get profileCardFingerprintCopied => 'フィンガープリントをコピーしました';

  @override
  String get profileCardAboutHint => 'プライバシー第一 🔒';

  @override
  String get profileCardSaveButton => 'プロフィールを保存';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      '暗号化されたメッセージ、連絡先、アバターをファイルにエクスポート';

  @override
  String get callVideo => 'ビデオ';

  @override
  String get callAudio => '音声';

  @override
  String bubbleDeliveredTo(String names) {
    return '配信済み：$names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return '$count人に配信済み';
  }

  @override
  String get groupStatusDialogTitle => 'メッセージ情報';

  @override
  String get groupStatusRead => '既読';

  @override
  String get groupStatusDelivered => '配信済み';

  @override
  String get groupStatusPending => '送信待ち';

  @override
  String get groupStatusNoData => '配信情報はまだありません';

  @override
  String get profileTransferAdmin => '管理者にする';

  @override
  String profileTransferAdminConfirm(String name) {
    return '$nameを新しい管理者にしますか？';
  }

  @override
  String get profileTransferAdminBody => '管理者権限を失います。この操作は元に戻せません。';

  @override
  String profileTransferAdminDone(String name) {
    return '$nameが管理者になりました';
  }

  @override
  String get profileAdminBadge => '管理者';

  @override
  String get privacyPolicyTitle => 'プライバシーポリシー';

  @override
  String get privacyOverviewHeading => '概要';

  @override
  String get privacyOverviewBody =>
      'Pulseはサーバーレスでエンドツーエンド暗号化されたメッセンジャーです。プライバシーは単なる機能ではなく、アーキテクチャそのものです。Pulseサーバーは存在しません。アカウントはどこにも保存されません。開発者がデータを収集、送信、保存することはありません。';

  @override
  String get privacyDataCollectionHeading => 'データ収集';

  @override
  String get privacyDataCollectionBody =>
      'Pulseは個人データを一切収集しません。具体的には：\n\n- メール、電話番号、実名は不要\n- アナリティクス、トラッキング、テレメトリーなし\n- 広告識別子なし\n- 連絡先リストへのアクセスなし\n- クラウドバックアップなし（メッセージはデバイスにのみ存在）\n- Pulseサーバーへのメタデータ送信なし（サーバーが存在しないため）';

  @override
  String get privacyEncryptionHeading => '暗号化';

  @override
  String get privacyEncryptionBody =>
      'すべてのメッセージはSignalプロトコル（X3DH鍵合意によるDouble Ratchet）で暗号化されます。暗号鍵はデバイス上でのみ生成・保存されます。開発者を含め、誰もあなたのメッセージを読むことはできません。';

  @override
  String get privacyNetworkHeading => 'ネットワークアーキテクチャ';

  @override
  String get privacyNetworkBody =>
      'Pulseは連合型トランスポートアダプター（Nostrリレー、Session/Oxenサービスノード、Firebase Realtime Database、LAN）を使用します。これらのトランスポートは暗号化された暗号文のみを転送します。リレー運営者はIPアドレスとトラフィック量を確認できますが、メッセージの内容を復号することはできません。\n\nTorを有効にすると、リレー運営者からIPアドレスも隠されます。';

  @override
  String get privacyStunHeading => 'STUN/TURNサーバー';

  @override
  String get privacyStunBody =>
      '音声・ビデオ通話はDTLS-SRTP暗号化を用いたWebRTCを使用します。STUNサーバー（P2P接続のための公開IP検出に使用）とTURNサーバー（直接接続失敗時のメディアリレーに使用）はIPアドレスと通話時間を確認できますが、通話内容を復号することはできません。\n\n最大限のプライバシーのため、設定で独自のTURNサーバーを構成できます。';

  @override
  String get privacyCrashHeading => 'クラッシュレポート';

  @override
  String get privacyCrashBody =>
      'Sentryクラッシュレポートが有効な場合（ビルド時のSENTRY_DSN経由）、匿名のクラッシュレポートが送信されることがあります。これらにはメッセージ内容、連絡先情報、個人を特定する情報は含まれません。クラッシュレポートはDSNを省略することでビルド時に無効にできます。';

  @override
  String get privacyPasswordHeading => 'パスワードと鍵';

  @override
  String get privacyPasswordBody =>
      '復元パスワードはArgon2id（メモリハードKDF）を通じて暗号鍵を導出するために使用されます。パスワードはどこにも送信されません。パスワードを紛失した場合、アカウントは復元できません — リセットするためのサーバーは存在しません。';

  @override
  String get privacyFontsHeading => 'フォント';

  @override
  String get privacyFontsBody =>
      'Pulseはすべてのフォントをローカルにバンドルしています。Google Fontsやその他の外部フォントサービスへのリクエストは行われません。';

  @override
  String get privacyThirdPartyHeading => 'サードパーティサービス';

  @override
  String get privacyThirdPartyBody =>
      'Pulseは広告ネットワーク、アナリティクスプロバイダー、ソーシャルメディアプラットフォーム、データブローカーとは一切統合していません。唯一のネットワーク接続は、設定したトランスポートリレーへの接続のみです。';

  @override
  String get privacyOpenSourceHeading => 'オープンソース';

  @override
  String get privacyOpenSourceBody =>
      'Pulseはオープンソースソフトウェアです。これらのプライバシーに関する主張を確認するため、完全なソースコードを監査できます。';

  @override
  String get privacyContactHeading => 'お問い合わせ';

  @override
  String get privacyContactBody => 'プライバシーに関する質問は、プロジェクトリポジトリにissueを作成してください。';

  @override
  String get privacyLastUpdated => '最終更新：2026年3月';

  @override
  String imageSaveFailed(Object error) {
    return '保存に失敗しました：$error';
  }

  @override
  String get themeEngineTitle => 'テーマエンジン';

  @override
  String get torBuiltInTitle => '内蔵Tor';

  @override
  String get torConnectedSubtitle => '接続済み — Nostrは127.0.0.1:9250経由でルーティング';

  @override
  String torConnectingSubtitle(int pct) {
    return '接続中… $pct%';
  }

  @override
  String get torNotRunning => '停止中 — スイッチをタップして再起動';

  @override
  String get torDescription => 'Tor経由でNostrをルーティング（検閲されたネットワークではSnowflakeを使用）';

  @override
  String get torNetworkDiagnostics => 'ネットワーク診断';

  @override
  String get torTransportLabel => 'トランスポート：';

  @override
  String get torPtAuto => '自動';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'プレーン';

  @override
  String get torTimeoutLabel => 'タイムアウト：';

  @override
  String get torInfoDescription =>
      '有効にすると、Nostr WebSocket接続がTor（SOCKS5）経由でルーティングされます。Tor Browserは127.0.0.1:9150でリッスンします。スタンドアロンtorデーモンはポート9050を使用します。Firebase接続は影響を受けません。';

  @override
  String get torRouteNostrTitle => 'Tor経由でNostrをルーティング';

  @override
  String get torManagedByBuiltin => '内蔵Torで管理';

  @override
  String get torActiveRouting => 'アクティブ — NostrトラフィックがTor経由でルーティング中';

  @override
  String get torDisabled => '無効';

  @override
  String get torProxySocks5 => 'Torプロキシ（SOCKS5）';

  @override
  String get torProxyHostLabel => 'プロキシホスト';

  @override
  String get torProxyPortLabel => 'ポート';

  @override
  String get torPortInfo => 'Tor Browser：ポート9150  •  torデーモン：ポート9050';

  @override
  String get torForceNostrTitle => 'メッセージをTor経由で送信';

  @override
  String get torForceNostrSubtitle =>
      'すべてのNostrリレー接続がTor経由になります。速度は低下しますが、リレーからIPアドレスを隠します。';

  @override
  String get torForceNostrDisabled => '先にTorを有効にしてください';

  @override
  String get torForcePulseTitle => 'PulseリレーをTor経由で接続';

  @override
  String get torForcePulseSubtitle =>
      'すべてのPulseリレー接続がTor経由になります。速度は低下しますが、サーバーからIPアドレスを隠します。';

  @override
  String get torForcePulseDisabled => '先にTorを有効にしてください';

  @override
  String get i2pProxySocks5 => 'I2Pプロキシ（SOCKS5）';

  @override
  String get i2pInfoDescription =>
      'I2PはデフォルトでポートI4447のSOCKS5を使用します。I2Pアウトプロキシ（例：relay.damus.i2p）経由でNostrリレーに接続し、任意のトランスポートのユーザーと通信できます。両方が有効な場合、Torが優先されます。';

  @override
  String get i2pRouteNostrTitle => 'I2P経由でNostrをルーティング';

  @override
  String get i2pActiveRouting => 'アクティブ — NostrトラフィックがI2P経由でルーティング中';

  @override
  String get i2pDisabled => '無効';

  @override
  String get i2pProxyHostLabel => 'プロキシホスト';

  @override
  String get i2pProxyPortLabel => 'ポート';

  @override
  String get i2pPortInfo => 'I2PルーターのデフォルトSOCKS5ポート：4447';

  @override
  String get customProxySocks5 => 'カスタムプロキシ（SOCKS5）';

  @override
  String get customCfWorkerRelay => 'CF Workerリレー';

  @override
  String get customProxyInfoDescription =>
      'カスタムプロキシはV2Ray/Xray/Shadowsocks経由でトラフィックをルーティングします。CF WorkerはCloudflare CDN上のパーソナルリレープロキシとして機能し — GFWからは*.workers.devに見え、実際のリレーは見えません。';

  @override
  String get customSocks5ProxyTitle => 'カスタムSOCKS5プロキシ';

  @override
  String get customProxyActive => 'アクティブ — SOCKS5経由でルーティング中';

  @override
  String get customProxyDisabled => '無効';

  @override
  String get customProxyHostLabel => 'プロキシホスト';

  @override
  String get customProxyPortLabel => 'ポート';

  @override
  String get customProxyHint =>
      'V2Ray/Xray：127.0.0.1:10808  •  Shadowsocks：127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Workerドメイン（任意）';

  @override
  String get customWorkerHelpTitle => 'CF Workerリレーのデプロイ方法（無料）';

  @override
  String get customWorkerScriptCopied => 'スクリプトをコピーしました！';

  @override
  String get customWorkerStep1 =>
      '1. dash.cloudflare.com → Workers & Pagesにアクセス\n2. Workerを作成 → このスクリプトを貼り付け：\n';

  @override
  String get customWorkerStep2 =>
      '3. デプロイ → ドメインをコピー（例：my-relay.user.workers.dev）\n4. 上にドメインを貼り付け → 保存\n\nアプリが自動接続：wss://domain/?r=relay_url\nGFWから見える：*.workers.dev（CF CDN）への接続';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return '接続済み — SOCKS5は127.0.0.1:$portでリッスン中';
  }

  @override
  String get psiphonConnecting => '接続中…';

  @override
  String get psiphonNotRunning => '停止中 — スイッチをタップして再起動';

  @override
  String get psiphonDescription => '高速トンネル（約3秒でブートストラップ、2000以上のローテーションVPS）';

  @override
  String get turnCommunityServers => 'コミュニティTURNサーバー';

  @override
  String get turnCustomServer => 'カスタムTURNサーバー（BYOD）';

  @override
  String get turnInfoDescription =>
      'TURNサーバーは既に暗号化されたストリーム（DTLS-SRTP）のみをリレーします。リレー運営者はIPアドレスとトラフィック量を確認できますが、通話を復号することはできません。TURNは直接P2Pが失敗した場合にのみ使用されます（接続の約15–20%）。';

  @override
  String get turnFreeLabel => '無料';

  @override
  String get turnServerUrlLabel => 'TURNサーバーURL';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 または turns:...';

  @override
  String get turnUsernameLabel => 'ユーザー名';

  @override
  String get turnPasswordLabel => 'パスワード';

  @override
  String get turnOptionalHint => '任意';

  @override
  String get turnCustomInfo =>
      '月額\$5のVPSにcoturnをセルフホストして最大限のコントロールを。認証情報はローカルに保存されます。';

  @override
  String get themePickerAppearance => '外観';

  @override
  String get themePickerAccentColor => 'アクセントカラー';

  @override
  String get themeModeLight => 'ライト';

  @override
  String get themeModeDark => 'ダーク';

  @override
  String get themeModeSystem => 'システム';

  @override
  String get themeDynamicPresets => 'プリセット';

  @override
  String get themeDynamicPrimaryColor => 'プライマリカラー';

  @override
  String get themeDynamicBorderRadius => 'ボーダー半径';

  @override
  String get themeDynamicFont => 'フォント';

  @override
  String get themeDynamicAppearance => '外観';

  @override
  String get themeDynamicUiStyle => 'UIスタイル';

  @override
  String get themeDynamicUiStyleDescription => 'ダイアログ、スイッチ、インジケーターの見た目を制御します。';

  @override
  String get themeDynamicSharp => 'シャープ';

  @override
  String get themeDynamicRound => 'ラウンド';

  @override
  String get themeDynamicModeDark => 'ダーク';

  @override
  String get themeDynamicModeLight => 'ライト';

  @override
  String get themeDynamicModeAuto => '自動';

  @override
  String get themeDynamicPlatformAuto => '自動';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      '無効なFirebase URLです。https://project.firebaseio.com の形式が必要です';

  @override
  String get providerErrorInvalidRelayUrl =>
      '無効なリレーURLです。wss://relay.example.com の形式が必要です';

  @override
  String get providerErrorInvalidPulseUrl =>
      '無効なPulseサーバーURLです。https://server:port の形式が必要です';

  @override
  String get providerPulseServerUrlLabel => 'サーバーURL';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => '招待コード';

  @override
  String get providerPulseInviteHint => '招待コード（必要な場合）';

  @override
  String get providerPulseInfo => 'セルフホストリレー。鍵は復元パスワードから導出されます。';

  @override
  String get providerScreenTitle => '受信ボックス';

  @override
  String get providerSecondaryInboxesHeader => 'セカンダリ受信ボックス';

  @override
  String get providerSecondaryInboxesInfo =>
      'セカンダリ受信ボックスは冗長性のためにメッセージを同時受信します。';

  @override
  String get providerRemoveTooltip => '削除';

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
  String get emojiNoRecent => '最近使用した絵文字はありません';

  @override
  String get emojiSearchHint => '絵文字を検索...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'タップしてチャット';

  @override
  String get imageViewerSaveToDownloads => 'ダウンロードに保存';

  @override
  String imageViewerSavedTo(String path) {
    return '$pathに保存しました';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageSubtitle => 'アプリの表示言語';

  @override
  String get settingsLanguageSystem => 'システムデフォルト';

  @override
  String get onboardingLanguageTitle => '言語を選択';

  @override
  String get onboardingLanguageSubtitle => '後で設定から変更できます';

  @override
  String get videoNoteRecord => 'ビデオメッセージを録画';

  @override
  String get videoNoteTapToRecord => 'タップして録画開始';

  @override
  String get videoNoteTapToStop => 'タップして停止';

  @override
  String get videoNoteCameraPermission => 'カメラのアクセスが拒否されました';

  @override
  String get videoNoteMaxDuration => '最大30秒';

  @override
  String get videoNoteNotSupported => 'このプラットフォームではビデオノートはサポートされていません';

  @override
  String get navChats => 'チャット';

  @override
  String get navUpdates => 'アップデート';

  @override
  String get navCalls => '通話';

  @override
  String get filterAll => 'すべて';

  @override
  String get filterUnread => '未読';

  @override
  String get filterGroups => 'グループ';

  @override
  String get callsNoRecent => '最近の通話なし';

  @override
  String get callsEmptySubtitle => '通話履歴がここに表示されます';

  @override
  String get appBarEncrypted => 'エンドツーエンド暗号化';

  @override
  String get newStatus => '新しいステータス';

  @override
  String get newCall => '新しい通話';

  @override
  String get joinChannelTitle => 'チャンネルに参加';

  @override
  String get joinChannelDescription => 'チャンネルURL';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'チャンネル情報を取得中…';

  @override
  String get joinChannelNotFound => 'このURLにチャンネルが見つかりません';

  @override
  String get joinChannelNetworkError => 'サーバーに接続できません';

  @override
  String get joinChannelAlreadyJoined => '参加済み';

  @override
  String get joinChannelButton => '参加';

  @override
  String get channelFeedEmpty => 'まだ投稿がありません';

  @override
  String get channelLeave => 'チャンネルを退出';

  @override
  String get channelLeaveConfirm => 'このチャンネルを退出しますか？キャッシュされた投稿は削除されます。';

  @override
  String get channelInfo => 'チャンネル情報';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => '編集済み';

  @override
  String get channelLoadMore => 'もっと読み込む';

  @override
  String get channelSearchPosts => '投稿を検索…';

  @override
  String get channelNoResults => '一致する投稿なし';

  @override
  String get channelUrl => 'チャンネルURL';

  @override
  String get channelCreated => '参加済み';

  @override
  String channelPostCount(int count) {
    return '$count件の投稿';
  }

  @override
  String get channelCopyUrl => 'URLをコピー';

  @override
  String get setupNext => '次へ';

  @override
  String get setupKeyWarning =>
      'リカバリーキーが生成されます。新しいデバイスでアカウントを復元する唯一の方法です — サーバーもパスワードリセットもありません。';

  @override
  String get setupKeyTitle => 'あなたのリカバリーキー';

  @override
  String get setupKeySubtitle =>
      'このキーを書き留めて安全な場所に保管してください。新しいデバイスでアカウントを復元するのに必要です。';

  @override
  String get setupKeyCopied => 'コピーしました！';

  @override
  String get setupKeyWroteItDown => '書き留めました';

  @override
  String get setupKeyWarnBody =>
      'このキーをバックアップとして書き留めてください。設定 → セキュリティでも後から確認できます。';

  @override
  String get setupVerifyTitle => 'リカバリーキーの確認';

  @override
  String get setupVerifySubtitle => 'リカバリーキーを再入力して正しく保存したことを確認してください。';

  @override
  String get setupVerifyButton => '確認';

  @override
  String get setupKeyMismatch => 'キーが一致しません。確認してやり直してください。';

  @override
  String get setupSkipVerify => '確認をスキップ';

  @override
  String get setupSkipVerifyTitle => '確認をスキップしますか？';

  @override
  String get setupSkipVerifyBody => 'リカバリーキーを紛失すると、アカウントを復元できなくなります。よろしいですか？';

  @override
  String get setupCreatingAccount => 'アカウント作成中…';

  @override
  String get setupRestoringAccount => 'アカウント復元中…';

  @override
  String get restoreKeyInfoBanner =>
      'リカバリーキーを入力 — アドレス（Nostr + Session）は自動的に復元されます。連絡先とメッセージはローカルにのみ保存されていました。';

  @override
  String get restoreKeyHint => 'リカバリーキー';

  @override
  String get settingsViewRecoveryKey => 'リカバリーキーを表示';

  @override
  String get settingsViewRecoveryKeySubtitle => 'アカウントのリカバリーキーを表示';

  @override
  String get settingsRecoveryKeyNotStored => 'リカバリーキーが利用できません（この機能の前に作成されました）';

  @override
  String get settingsRecoveryKeyWarning =>
      'このキーを安全に保管してください。持っている人は別のデバイスであなたのアカウントを復元できます。';

  @override
  String get replaceIdentityTitle => '既存のIDを置き換えますか？';

  @override
  String get replaceIdentityBodyRestore =>
      'このデバイスにはすでにIDが存在します。復元すると、現在のNostrキーとOxenシードが永久に置き換えられます。すべての連絡先は現在のアドレスに連絡できなくなります。\n\nこの操作は元に戻せません。';

  @override
  String get replaceIdentityBodyCreate =>
      'このデバイスにはすでにIDが存在します。新しいIDを作成すると、現在のNostrキーとOxenシードが永久に置き換えられます。すべての連絡先は現在のアドレスに連絡できなくなります。\n\nこの操作は元に戻せません。';

  @override
  String get replace => '置き換え';

  @override
  String get callNoScreenSources => '利用可能な画面ソースがありません';

  @override
  String get callScreenShareQuality => '画面共有の品質';

  @override
  String get callFrameRate => 'フレームレート';

  @override
  String get callResolution => '解像度';

  @override
  String get callAutoResolution => '自動 = ネイティブ画面解像度';

  @override
  String get callStartSharing => '共有を開始';

  @override
  String get callCameraUnavailable => 'カメラが利用できません — 別のアプリで使用中の可能性があります';

  @override
  String get themeResetToDefaults => 'デフォルトにリセット';

  @override
  String get backupSaveToDownloadsTitle => 'ダウンロードにバックアップを保存しますか？';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'ファイルピッカーが利用できません。バックアップは以下に保存されます:\n$path';
  }

  @override
  String get systemLabel => 'システム';

  @override
  String get next => '次へ';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return '開発者モードを有効にするにはあと$remaining回タップ';
  }

  @override
  String get devModeEnabled => '開発者モードが有効になりました';

  @override
  String get devTools => '開発者ツール';

  @override
  String get devAdapterDiagnostics => 'アダプター切り替えと診断';

  @override
  String get devEnableAll => 'すべて有効';

  @override
  String get devDisableAll => 'すべて無効';

  @override
  String get turnUrlValidation => 'TURN URLはturn:またはturns:で始まる必要があります（最大512文字）';

  @override
  String get callMissedCall => '不在着信';

  @override
  String get callOutgoingCall => '発信';

  @override
  String get callIncomingCall => '着信';

  @override
  String get mediaMissingData => 'メディアデータがありません';

  @override
  String get mediaDownloadFailed => 'ダウンロードに失敗';

  @override
  String get mediaDecryptFailed => '復号に失敗';

  @override
  String get callEndCallBanner => '通話終了';

  @override
  String get meFallback => '自分';

  @override
  String get imageSaveToDownloads => 'ダウンロードに保存';

  @override
  String imageSavedToPath(String path) {
    return '$pathに保存しました';
  }

  @override
  String get callScreenShareRequiresPermission => '画面共有には許可が必要です';

  @override
  String get callScreenShareUnavailable => '画面共有は利用できません';

  @override
  String get statusJustNow => 'たった今';

  @override
  String statusMinutesAgo(int minutes) {
    return '$minutes分前';
  }

  @override
  String statusHoursAgo(int hours) {
    return '$hours時間前';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ルート',
      one: '1 ルート',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => '追加準備完了';

  @override
  String groupSelectedCount(int count) {
    return '$count件選択';
  }

  @override
  String get paste => '貼り付け';

  @override
  String get sfuAudioOnly => '音声のみ';

  @override
  String sfuParticipants(int count) {
    return '$count人の参加者';
  }

  @override
  String get dataUnencryptedBackup => '暗号化されていないバックアップ';

  @override
  String get dataUnencryptedBackupBody =>
      'このファイルは暗号化されていないIDバックアップで、現在のキーを上書きします。自分で作成したファイルのみをインポートしてください。続行しますか？';

  @override
  String get dataImportAnyway => 'とにかくインポート';

  @override
  String get securityStorageError => 'セキュリティストレージエラー — アプリを再起動してください';

  @override
  String get aboutDevModeActive => '開発者モード有効';

  @override
  String get themeColors => 'カラー';

  @override
  String get themePrimaryAccent => 'プライマリアクセント';

  @override
  String get themeSecondaryAccent => 'セカンダリアクセント';

  @override
  String get themeBackground => '背景';

  @override
  String get themeSurface => 'サーフェス';

  @override
  String get themeChatBubbles => 'チャットバブル';

  @override
  String get themeOutgoingMessage => '送信メッセージ';

  @override
  String get themeIncomingMessage => '受信メッセージ';

  @override
  String get themeShape => '形状';

  @override
  String get devSectionDeveloper => '開発者';

  @override
  String get devAdapterChannelsHint =>
      'アダプターチャンネル — 特定のトランスポートをテストするには無効にしてください。';

  @override
  String get devNostrRelays => 'Nostrリレー (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Sessionネットワーク';

  @override
  String get devPulseRelay => 'Pulseセルフホストリレー';

  @override
  String get devLanNetwork => 'ローカルネットワーク (UDP/TCP)';

  @override
  String get devSectionCalls => '通話';

  @override
  String get devForceTurnRelay => 'TURNリレーを強制';

  @override
  String get devForceTurnRelaySubtitle => 'P2Pを無効化 — すべての通話をTURNサーバー経由のみ';

  @override
  String get devRestartWarning =>
      '⚠ 変更は次回の送信/通話時に適用されます。受信に適用するにはアプリを再起動してください。';

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
  String get pulseUseServerTitle => 'Pulse サーバーを使用しますか？';

  @override
  String pulseUseServerBody(String name, String host) {
    return '$name は Pulse サーバー $host を使用しています。参加して、より速くチャットしますか？（同じサーバー上の他のユーザーとも）';
  }

  @override
  String pulseContactUsesPulse(String name) {
    return '$name は Pulse を使用中';
  }

  @override
  String pulseJoinForFaster(String host) {
    return '$host に参加してより速くチャット';
  }

  @override
  String get pulseNotNow => '後で';

  @override
  String get pulseJoin => '参加';

  @override
  String get pulseDismiss => '閉じる';

  @override
  String get pulseHide7Days => '7 日間非表示';

  @override
  String get pulseNeverAskAgain => '今後表示しない';

  @override
  String get groupSearchContactsHint => '連絡先を検索…';
}
