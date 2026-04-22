// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Search messages...';

  @override
  String get search => 'Search';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get closeSearch => 'Close search';

  @override
  String get moreOptions => 'More options';

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get remove => 'Remove';

  @override
  String get save => 'Save';

  @override
  String get add => 'Add';

  @override
  String get copy => 'Copy';

  @override
  String get skip => 'Skip';

  @override
  String get done => 'Done';

  @override
  String get apply => 'Apply';

  @override
  String get export => 'Export';

  @override
  String get import => 'Import';

  @override
  String get homeNewGroup => 'New group';

  @override
  String get homeSettings => 'Settings';

  @override
  String get homeSearching => 'Searching messages...';

  @override
  String get homeNoResults => 'No results found';

  @override
  String get homeNoChatHistory => 'No chat history yet';

  @override
  String homeTransportSwitched(String address) {
    return 'Transport switched → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name is calling...';
  }

  @override
  String get homeAccept => 'Accept';

  @override
  String get homeDecline => 'Decline';

  @override
  String get homeLoadEarlier => 'Load earlier messages';

  @override
  String get homeChats => 'Chats';

  @override
  String get homeSelectConversation => 'Select a conversation';

  @override
  String get homeNoChatsYet => 'No chats yet';

  @override
  String get homeAddContactToStart => 'Add a contact to start chatting';

  @override
  String get homeNewChat => 'New Chat';

  @override
  String get homeNewChatTooltip => 'New chat';

  @override
  String get homeIncomingCallTitle => 'Incoming Call';

  @override
  String get homeIncomingGroupCallTitle => 'Incoming Group Call';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — group call incoming';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'No chats matching \"$query\"';
  }

  @override
  String get homeSectionChats => 'Chats';

  @override
  String get homeSectionMessages => 'Messages';

  @override
  String get homeDbEncryptionUnavailable =>
      'Database encryption unavailable — install SQLCipher for full protection';

  @override
  String get chatFileTooLargeGroup =>
      'Files over 512 KB are not supported in group chats';

  @override
  String get chatLargeFile => 'Large File';

  @override
  String get chatCancel => 'Cancel';

  @override
  String get chatSend => 'Send';

  @override
  String get chatFileTooLarge => 'File too large — maximum size is 100 MB';

  @override
  String get chatMicDenied => 'Microphone permission denied';

  @override
  String get chatVoiceFailed =>
      'Failed to save voice message — check available storage';

  @override
  String get chatScheduleFuture => 'Scheduled time must be in the future';

  @override
  String get chatToday => 'Today';

  @override
  String get chatYesterday => 'Yesterday';

  @override
  String get chatEdited => 'edited';

  @override
  String get chatYou => 'You';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'This file is $size MB. Sending large files may be slow on some networks. Continue?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return '$name\'s security key changed. Tap to verify.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Could not encrypt message to $name — message not sent.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Safety number changed for $name. Tap to verify.';
  }

  @override
  String get chatNoMessagesFound => 'No messages found';

  @override
  String get chatMessagesE2ee => 'Messages are end-to-end encrypted';

  @override
  String get chatSayHello => 'Say hello';

  @override
  String get appBarOnline => 'online';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'typing';

  @override
  String get appBarSearchMessages => 'Search messages...';

  @override
  String get appBarMute => 'Mute';

  @override
  String get appBarUnmute => 'Unmute';

  @override
  String get appBarMedia => 'Media';

  @override
  String get appBarDisappearing => 'Disappearing messages';

  @override
  String get appBarDisappearingOn => 'Disappearing: on';

  @override
  String get appBarGroupSettings => 'Group settings';

  @override
  String get appBarSearchTooltip => 'Search messages';

  @override
  String get appBarVoiceCall => 'Voice call';

  @override
  String get appBarVideoCall => 'Video call';

  @override
  String get inputMessage => 'Message...';

  @override
  String get inputAttachFile => 'Attach file';

  @override
  String get inputSendMessage => 'Send message';

  @override
  String get inputRecordVoice => 'Record voice message';

  @override
  String get inputSendVoice => 'Send voice message';

  @override
  String get inputCancelReply => 'Cancel reply';

  @override
  String get inputCancelEdit => 'Cancel edit';

  @override
  String get inputCancelRecording => 'Cancel recording';

  @override
  String get inputRecording => 'Recording…';

  @override
  String get inputEditingMessage => 'Editing message';

  @override
  String get inputPhoto => 'Photo';

  @override
  String get inputVoiceMessage => 'Voice message';

  @override
  String get inputFile => 'File';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count scheduled message$_temp0';
  }

  @override
  String get callInitializing => 'Initializing call…';

  @override
  String get callConnecting => 'Connecting…';

  @override
  String get callConnectingRelay => 'Connecting (relay)…';

  @override
  String get callSwitchingRelay => 'Switching to relay mode…';

  @override
  String get callConnectionFailed => 'Connection failed';

  @override
  String get callReconnecting => 'Reconnecting…';

  @override
  String get callEnded => 'Call ended';

  @override
  String get callLive => 'Live';

  @override
  String get callEnd => 'End';

  @override
  String get callEndCall => 'End call';

  @override
  String get callMute => 'Mute';

  @override
  String get callUnmute => 'Unmute';

  @override
  String get callSpeaker => 'Speaker';

  @override
  String get callCameraOn => 'Camera On';

  @override
  String get callCameraOff => 'Camera Off';

  @override
  String get callShareScreen => 'Share Screen';

  @override
  String get callStopShare => 'Stop Share';

  @override
  String callTorBackup(String duration) {
    return 'Tor backup · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor backup active — primary path unavailable';

  @override
  String get callDirectFailed =>
      'Direct connection failed — switching to relay mode…';

  @override
  String get callTurnUnreachable =>
      'TURN servers unreachable. Add a custom TURN in Settings → Advanced.';

  @override
  String get callRelayMode => 'Relay mode active (restricted network)';

  @override
  String get callStarting => 'Starting call…';

  @override
  String get callConnectingToGroup => 'Connecting to group…';

  @override
  String get callGroupOpenedInBrowser => 'Group call opened in browser';

  @override
  String get callCouldNotOpenBrowser => 'Could not open browser';

  @override
  String get callInviteLinkSent => 'Invite link sent to all group members.';

  @override
  String get callOpenLinkManually =>
      'Open the link above manually or tap to retry.';

  @override
  String get callJitsiNotE2ee => 'Jitsi calls are NOT end-to-end encrypted';

  @override
  String get callRetryOpenBrowser => 'Retry open browser';

  @override
  String get callClose => 'Close';

  @override
  String get callCamOn => 'Cam on';

  @override
  String get callCamOff => 'Cam off';

  @override
  String get noConnection => 'No connection — messages will queue';

  @override
  String get connected => 'Connected';

  @override
  String get connecting => 'Connecting…';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get offlineBanner =>
      'No connection — messages will queue and send when back online';

  @override
  String get lanModeBanner => 'LAN Mode — No internet · Local network only';

  @override
  String get probeCheckingNetwork => 'Checking network connectivity…';

  @override
  String get probeDiscoveringRelays =>
      'Discovering relays via community directories…';

  @override
  String get probeStartingTor => 'Starting Tor for bootstrap…';

  @override
  String get probeFindingRelaysTor => 'Finding reachable relays via Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'Network ready — $count relay$_temp0 found';
  }

  @override
  String get probeNoRelaysFound =>
      'No reachable relays found — messages may be delayed';

  @override
  String get jitsiWarningTitle => 'Not end-to-end encrypted';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet calls are not encrypted by Pulse. Only use for non-sensitive conversations.';

  @override
  String get jitsiConfirm => 'Join anyway';

  @override
  String get jitsiGroupWarningTitle => 'Not end-to-end encrypted';

  @override
  String get jitsiGroupWarningBody =>
      'This call has too many participants for the built-in encrypted mesh.\n\nA Jitsi Meet link will be opened in your browser. Jitsi is NOT end-to-end encrypted — the server can see your call.';

  @override
  String get jitsiContinueAnyway => 'Continue anyway';

  @override
  String get retry => 'Retry';

  @override
  String get setupCreateAnonymousAccount => 'Create an anonymous account';

  @override
  String get setupTapToChangeColor => 'Tap to change color';

  @override
  String get setupReqMinLength => 'At least 16 characters';

  @override
  String get setupReqVariety => '3 of 4: uppercase, lowercase, digits, symbols';

  @override
  String get setupReqMatch => 'Passwords match';

  @override
  String get setupYourNickname => 'Your nickname';

  @override
  String get setupRecoveryPassword => 'Recovery password (min. 16)';

  @override
  String get setupConfirmPassword => 'Confirm password';

  @override
  String get setupMin16Chars => 'Minimum 16 characters';

  @override
  String get setupPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get setupEntropyWeak => 'Weak';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Strong';

  @override
  String get setupEntropyWeakNeedsVariety => 'Weak (need 3 char types)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bits)';
  }

  @override
  String get setupPasswordWarning =>
      'This password is the only way to restore your account. There is no server — no password reset. Remember it or write it down.';

  @override
  String get setupCreateAccount => 'Create account';

  @override
  String get setupAlreadyHaveAccount => 'Already have an account? ';

  @override
  String get setupRestore => 'Restore →';

  @override
  String get restoreTitle => 'Restore account';

  @override
  String get restoreInfoBanner =>
      'Enter your recovery password — your address (Nostr + Session) will be restored automatically. Contacts and messages were stored locally only.';

  @override
  String get restoreNewNickname => 'New nickname (can change later)';

  @override
  String get restoreButton => 'Restore account';

  @override
  String get lockTitle => 'Pulse is locked';

  @override
  String get lockSubtitle => 'Enter your password to continue';

  @override
  String get lockPasswordHint => 'Password';

  @override
  String get lockUnlock => 'Unlock';

  @override
  String get lockPanicHint =>
      'Forgot your password? Enter your panic key to wipe all data.';

  @override
  String get lockTooManyAttempts => 'Too many attempts. Erasing all data…';

  @override
  String get lockWrongPassword => 'Wrong password';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Wrong password — $attempts/$max attempts';
  }

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Create Account';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Pulse';

  @override
  String get onboardingWelcomeBody =>
      'A decentralized, end-to-end encrypted messenger.\n\nNo central servers. No data collection. No backdoors.\nYour conversations belong only to you.';

  @override
  String get onboardingTransportTitle => 'Transport-Agnostic';

  @override
  String get onboardingTransportBody =>
      'Use Firebase, Nostr, or both at the same time.\n\nMessages route across networks automatically. Built-in Tor and I2P support for censorship resistance.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Every message is encrypted with the Signal Protocol (Double Ratchet + X3DH) for forward secrecy.\n\nAdditionally wrapped with Kyber-1024 — a NIST-standard post-quantum algorithm — protecting against future quantum computers.';

  @override
  String get onboardingKeysTitle => 'You Own Your Keys';

  @override
  String get onboardingKeysBody =>
      'Your identity keys never leave your device.\n\nSignal fingerprints let you verify contacts out-of-band. TOFU (Trust On First Use) detects key changes automatically.';

  @override
  String get onboardingThemeTitle => 'Choose Your Look';

  @override
  String get onboardingThemeBody =>
      'Pick a theme and accent colour. You can always change this later in Settings.';

  @override
  String get contactsNewChat => 'New chat';

  @override
  String get contactsAddContact => 'Add contact';

  @override
  String get contactsSearchHint => 'Search...';

  @override
  String get contactsNewGroup => 'New group';

  @override
  String get contactsNoContactsYet => 'No contacts yet';

  @override
  String get contactsAddHint => 'Tap + to add someone\'s address';

  @override
  String get contactsNoMatch => 'No contacts match';

  @override
  String get contactsRemoveTitle => 'Remove contact';

  @override
  String contactsRemoveMessage(String name) {
    return 'Remove $name?';
  }

  @override
  String get contactsRemove => 'Remove';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count contact$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Open Link';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Open this URL in your browser?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Open';

  @override
  String get bubbleSecurityWarning => 'Security Warning';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" is an executable file type. Saving and running it could harm your device. Save anyway?';
  }

  @override
  String get bubbleSaveAnyway => 'Save Anyway';

  @override
  String bubbleSavedTo(String path) {
    return 'Saved to $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get bubbleNotEncrypted => 'NOT ENCRYPTED';

  @override
  String get bubbleCorruptedImage => '[Corrupted image]';

  @override
  String get bubbleReplyPhoto => 'Photo';

  @override
  String get bubbleReplyVoice => 'Voice message';

  @override
  String get bubbleReplyVideo => 'Video message';

  @override
  String bubbleReadBy(String names) {
    return 'Read by $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Read by $count';
  }

  @override
  String get chatTileTapToStart => 'Tap to start chatting';

  @override
  String get chatTileMessageSent => 'Message sent';

  @override
  String get chatTileEncryptedMessage => 'Encrypted message';

  @override
  String chatTileYouPrefix(String text) {
    return 'You: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Voice message';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Voice message ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Encrypted message';

  @override
  String get groupNewGroup => 'New Group';

  @override
  String get groupGroupName => 'Group name';

  @override
  String get groupSelectMembers => 'Select members (min 2)';

  @override
  String get groupNoContactsYet => 'No contacts yet. Add contacts first.';

  @override
  String get groupCreate => 'Create';

  @override
  String get groupLabel => 'Group';

  @override
  String get profileVerifyIdentity => 'Verify Identity';

  @override
  String profileVerifyInstructions(String name) {
    return 'Compare these fingerprints with $name over a voice call or in person. If both values match on both devices, tap \"Mark as Verified\".';
  }

  @override
  String get profileTheirKey => 'Their key';

  @override
  String get profileYourKey => 'Your key';

  @override
  String get profileRemoveVerification => 'Remove Verification';

  @override
  String get profileMarkAsVerified => 'Mark as Verified';

  @override
  String get profileAddressCopied => 'Address copied';

  @override
  String get profileNoContactsToAdd =>
      'No contacts to add — all are already members';

  @override
  String get profileAddMembers => 'Add Members';

  @override
  String profileAddCount(int count) {
    return 'Add ($count)';
  }

  @override
  String get profileRenameGroup => 'Rename Group';

  @override
  String get profileRename => 'Rename';

  @override
  String get profileRemoveMember => 'Remove member?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Remove $name from this group?';
  }

  @override
  String get profileKick => 'Kick';

  @override
  String get profileSignalFingerprints => 'Signal Fingerprints';

  @override
  String get profileVerified => 'VERIFIED';

  @override
  String get profileVerify => 'Verify';

  @override
  String get profileEdit => 'Edit';

  @override
  String get profileNoSession =>
      'No session established yet — send a message first.';

  @override
  String get profileFingerprintCopied => 'Fingerprint copied';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count member$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Verify Safety Number';

  @override
  String get profileShowContactQr => 'Show Contact QR';

  @override
  String profileContactAddress(String name) {
    return '$name\'s Address';
  }

  @override
  String get profileExportChatHistory => 'Export Chat History';

  @override
  String profileSavedTo(String path) {
    return 'Saved to $path';
  }

  @override
  String get profileExportFailed => 'Export failed';

  @override
  String get profileClearChatHistory => 'Clear chat history';

  @override
  String get profileDeleteGroup => 'Delete group';

  @override
  String get profileDeleteContact => 'Delete contact';

  @override
  String get profileLeaveGroup => 'Leave group';

  @override
  String get profileLeaveGroupBody =>
      'You will be removed from this group and it will be deleted from your contacts.';

  @override
  String get groupInviteTitle => 'Group invitation';

  @override
  String groupInviteBody(String from, String group) {
    return '$from invited you to join \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Accept';

  @override
  String get groupInviteDecline => 'Decline';

  @override
  String get groupMemberLimitTitle => 'Too many participants';

  @override
  String groupMemberLimitBody(int count) {
    return 'This group will have $count participants. Encrypted mesh calls support up to 6. Larger groups fall back to Jitsi (not E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Add anyway';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name declined to join \"$group\"';
  }

  @override
  String get transferTitle => 'Transfer to Another Device';

  @override
  String get transferInfoBox =>
      'Move your Signal identity and Nostr keys to a new device.\nChat sessions are NOT transferred — forward secrecy is preserved.';

  @override
  String get transferSendFromThis => 'Send from this device';

  @override
  String get transferSendSubtitle =>
      'This device has the keys. Share a code with the new device.';

  @override
  String get transferReceiveOnThis => 'Receive on this device';

  @override
  String get transferReceiveSubtitle =>
      'This is the new device. Enter the code from the old device.';

  @override
  String get transferChooseMethod => 'Choose Transfer Method';

  @override
  String get transferLan => 'LAN (Same Network)';

  @override
  String get transferLanSubtitle =>
      'Fast, direct. Both devices must be on the same Wi-Fi.';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'Works over any network using an existing Nostr relay.';

  @override
  String get transferRelayUrl => 'Relay URL';

  @override
  String get transferEnterCode => 'Enter Transfer Code';

  @override
  String get transferPasteCode => 'Paste the LAN:... or NOS:... code here';

  @override
  String get transferConnect => 'Connect';

  @override
  String get transferGenerating => 'Generating transfer code…';

  @override
  String get transferShareCode => 'Share this code with the receiver:';

  @override
  String get transferCopyCode => 'Copy Code';

  @override
  String get transferCodeCopied => 'Code copied to clipboard';

  @override
  String get transferWaitingReceiver => 'Waiting for receiver to connect…';

  @override
  String get transferConnectingSender => 'Connecting to sender…';

  @override
  String get transferVerifyBoth =>
      'Compare this code on both devices.\nIf they match, the transfer is secure.';

  @override
  String get transferComplete => 'Transfer Complete';

  @override
  String get transferKeysImported => 'Keys Imported';

  @override
  String get transferCompleteSenderBody =>
      'Your keys remain active on this device.\nThe receiver can now use your identity.';

  @override
  String get transferCompleteReceiverBody =>
      'Keys imported successfully.\nRestart the app to apply the new identity.';

  @override
  String get transferRestartApp => 'Restart App';

  @override
  String get transferFailed => 'Transfer Failed';

  @override
  String get transferTryAgain => 'Try Again';

  @override
  String get transferEnterRelayFirst => 'Enter a relay URL first';

  @override
  String get transferPasteCodeFromSender =>
      'Paste the transfer code from the sender';

  @override
  String get menuReply => 'Reply';

  @override
  String get menuForward => 'Forward';

  @override
  String get menuReact => 'React';

  @override
  String get menuCopy => 'Copy';

  @override
  String get menuEdit => 'Edit';

  @override
  String get menuRetry => 'Retry';

  @override
  String get menuCancelScheduled => 'Cancel scheduled';

  @override
  String get menuDelete => 'Delete';

  @override
  String get menuForwardTo => 'Forward to…';

  @override
  String menuForwardedTo(String name) {
    return 'Forwarded to $name';
  }

  @override
  String get menuScheduledMessages => 'Scheduled messages';

  @override
  String get menuNoScheduledMessages => 'No scheduled messages';

  @override
  String menuSendsOn(String date) {
    return 'Sends on $date';
  }

  @override
  String get menuDisappearingMessages => 'Disappearing Messages';

  @override
  String get menuDisappearingSubtitle =>
      'Messages delete automatically after the selected time.';

  @override
  String get menuTtlOff => 'Off';

  @override
  String get menuTtl1h => '1 hour';

  @override
  String get menuTtl24h => '24 hours';

  @override
  String get menuTtl7d => '7 days';

  @override
  String get menuAttachPhoto => 'Photo';

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
    return 'Photos ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Files ($count)';
  }

  @override
  String get mediaNoPhotos => 'No photos yet';

  @override
  String get mediaNoFiles => 'No files yet';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Saved to Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'Failed to save file';

  @override
  String get statusNewStatus => 'New Status';

  @override
  String get statusPublish => 'Publish';

  @override
  String get statusExpiresIn24h => 'Status expires in 24 hours';

  @override
  String get statusWhatsOnYourMind => 'What\'s on your mind?';

  @override
  String get statusPhotoAttached => 'Photo attached';

  @override
  String get statusAttachPhoto => 'Attach photo (optional)';

  @override
  String get statusEnterText => 'Please enter some text for your status.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Failed to pick photo: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Failed to publish: $error';
  }

  @override
  String get panicSetPanicKey => 'Set Panic Key';

  @override
  String get panicEmergencySelfDestruct => 'Emergency self-destruct';

  @override
  String get panicIrreversible => 'This action is irreversible';

  @override
  String get panicWarningBody =>
      'Entering this key at the lock screen instantly wipes ALL data — messages, contacts, keys, identity. Use a key different from your regular password.';

  @override
  String get panicKeyHint => 'Panic key';

  @override
  String get panicConfirmHint => 'Confirm panic key';

  @override
  String get panicMinChars => 'Panic key must be at least 8 characters';

  @override
  String get panicKeysDoNotMatch => 'Keys do not match';

  @override
  String get panicSetFailed => 'Failed to save panic key — please try again';

  @override
  String get passwordSetAppPassword => 'Set App Password';

  @override
  String get passwordProtectsMessages => 'Protects your messages at rest';

  @override
  String get passwordInfoBanner =>
      'Required every time you open Pulse. If forgotten, your data cannot be recovered.';

  @override
  String get passwordHint => 'Password';

  @override
  String get passwordConfirmHint => 'Confirm password';

  @override
  String get passwordSetButton => 'Set Password';

  @override
  String get passwordSkipForNow => 'Skip for now';

  @override
  String get passwordMinChars => 'Password must be at least 8 characters';

  @override
  String get passwordNeedsVariety =>
      'Must include letters, numbers, and special characters';

  @override
  String get passwordRequirements =>
      'Min. 8 characters with letters, numbers, and a special character';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get profileCardSaved => 'Profile saved!';

  @override
  String get profileCardE2eeIdentity => 'E2EE Identity';

  @override
  String get profileCardDisplayName => 'Display Name';

  @override
  String get profileCardDisplayNameHint => 'e.g. Alex Smith';

  @override
  String get profileCardAbout => 'About';

  @override
  String get profileCardSaveProfile => 'Save Profile';

  @override
  String get profileCardYourName => 'Your Name';

  @override
  String get profileCardAddressCopied => 'Address copied!';

  @override
  String get profileCardInboxAddress => 'Your Inbox Address';

  @override
  String get profileCardInboxAddresses => 'Your Inbox Addresses';

  @override
  String get profileCardShareAllAddresses =>
      'Share All Addresses (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Share with contacts so they can message you.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'All $count addresses copied as one link!';
  }

  @override
  String get settingsMyProfile => 'My Profile';

  @override
  String get settingsYourInboxAddress => 'Your Inbox Address';

  @override
  String get settingsMyQrCode => 'Share Contact';

  @override
  String get settingsMyQrSubtitle => 'QR code & invite link for your address';

  @override
  String get settingsShareMyAddress => 'Share My Address';

  @override
  String get settingsNoAddressYet => 'No address yet — save settings first';

  @override
  String get settingsInviteLink => 'Invite Link';

  @override
  String get settingsRawAddress => 'Raw Address';

  @override
  String get settingsCopyLink => 'Copy Link';

  @override
  String get settingsCopyAddress => 'Copy Address';

  @override
  String get settingsInviteLinkCopied => 'Invite link copied';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeEngine => 'Theme Engine';

  @override
  String get settingsThemeEngineSubtitle => 'Customize colors & fonts';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle => 'E2EE keys are stored securely';

  @override
  String get settingsActive => 'ACTIVE';

  @override
  String get settingsIdentityBackup => 'Identity Backup';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Export or import your Signal identity';

  @override
  String get settingsIdentityBackupBody =>
      'Export your Signal identity keys to a backup code, or restore from an existing one.';

  @override
  String get settingsTransferDevice => 'Transfer to Another Device';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Move your identity via LAN or Nostr relay';

  @override
  String get settingsExportIdentity => 'Export Identity';

  @override
  String get settingsExportIdentityBody =>
      'Copy this backup code and store it safely:';

  @override
  String get settingsSaveFile => 'Save File';

  @override
  String get settingsImportIdentity => 'Import Identity';

  @override
  String get settingsImportIdentityBody =>
      'Paste your backup code below. This will overwrite your current identity.';

  @override
  String get settingsPasteBackupCode => 'Paste backup code here…';

  @override
  String get settingsIdentityImported =>
      'Identity + contacts imported! Restart the app to apply.';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsAppPassword => 'App Password';

  @override
  String get settingsPasswordEnabled => 'Enabled — required on every launch';

  @override
  String get settingsPasswordDisabled =>
      'Disabled — app opens without password';

  @override
  String get settingsChangePassword => 'Change Password';

  @override
  String get settingsChangePasswordSubtitle => 'Update your app lock password';

  @override
  String get settingsSetPanicKey => 'Set Panic Key';

  @override
  String get settingsChangePanicKey => 'Change Panic Key';

  @override
  String get settingsPanicKeySetSubtitle => 'Update emergency wipe key';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'One key that instantly erases all data';

  @override
  String get settingsRemovePanicKey => 'Remove Panic Key';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Disable emergency self-destruct';

  @override
  String get settingsRemovePanicKeyBody =>
      'Emergency self-destruct will be disabled. You can re-enable it at any time.';

  @override
  String get settingsDisableAppPassword => 'Disable App Password';

  @override
  String get settingsEnterCurrentPassword =>
      'Enter your current password to confirm';

  @override
  String get settingsCurrentPassword => 'Current password';

  @override
  String get settingsIncorrectPassword => 'Incorrect password';

  @override
  String get settingsPasswordUpdated => 'Password updated';

  @override
  String get settingsChangePasswordProceed =>
      'Enter your current password to proceed';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsBackupMessages => 'Backup Messages';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Export encrypted message history to a file';

  @override
  String get settingsRestoreMessages => 'Restore Messages';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Import messages from a backup file';

  @override
  String get settingsExportKeys => 'Export Keys';

  @override
  String get settingsExportKeysSubtitle =>
      'Save identity keys to an encrypted file';

  @override
  String get settingsImportKeys => 'Import Keys';

  @override
  String get settingsImportKeysSubtitle =>
      'Restore identity keys from an exported file';

  @override
  String get settingsBackupPassword => 'Backup password';

  @override
  String get settingsPasswordCannotBeEmpty => 'Password cannot be empty';

  @override
  String get settingsPasswordMin4Chars =>
      'Password must be at least 4 characters';

  @override
  String get settingsCallsTurn => 'Calls & TURN';

  @override
  String get settingsLocalNetwork => 'Local Network';

  @override
  String get settingsCensorshipResistance => 'Censorship Resistance';

  @override
  String get settingsNetwork => 'Network';

  @override
  String get settingsProxyTunnels => 'Proxy & Tunnels';

  @override
  String get settingsTurnServers => 'TURN Servers';

  @override
  String get settingsProviderTitle => 'Provider';

  @override
  String get settingsLanFallback => 'LAN Fallback';

  @override
  String get settingsLanFallbackSubtitle =>
      'Broadcast presence and deliver messages on the local network when internet is unavailable. Disable on untrusted networks (public Wi-Fi).';

  @override
  String get settingsBgDelivery => 'Background Delivery';

  @override
  String get settingsBgDeliverySubtitle =>
      'Keep receiving messages when the app is minimized. Shows a persistent notification.';

  @override
  String get settingsYourInboxProvider => 'Your Inbox Provider';

  @override
  String get settingsConnectionDetails => 'Connection Details';

  @override
  String get settingsSaveAndConnect => 'Save & Connect';

  @override
  String get settingsSecondaryInboxes => 'Secondary Inboxes';

  @override
  String get settingsAddSecondaryInbox => 'Add Secondary Inbox';

  @override
  String get settingsAdvanced => 'Advanced';

  @override
  String get settingsDiscover => 'Discover';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsPrivacyPolicySubtitle => 'How Pulse protects your data';

  @override
  String get settingsCrashReporting => 'Crash reporting';

  @override
  String get settingsCrashReportingSubtitle =>
      'Send anonymous crash reports to help improve Pulse. No message content or contacts are ever sent.';

  @override
  String get settingsCrashReportingEnabled =>
      'Crash reporting enabled — restart app to apply';

  @override
  String get settingsCrashReportingDisabled =>
      'Crash reporting disabled — restart app to apply';

  @override
  String get settingsSensitiveOperation => 'Sensitive Operation';

  @override
  String get settingsSensitiveOperationBody =>
      'These keys are your identity. Anyone with this file can impersonate you. Store it securely and delete it after transfer.';

  @override
  String get settingsIUnderstandContinue => 'I Understand, Continue';

  @override
  String get settingsReplaceIdentity => 'Replace Identity?';

  @override
  String get settingsReplaceIdentityBody =>
      'This will overwrite your current identity keys. Your existing Signal sessions will be invalidated and contacts will need to re-establish encryption. The app will need to restart.';

  @override
  String get settingsReplaceKeys => 'Replace Keys';

  @override
  String get settingsKeysImported => 'Keys Imported';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count keys imported successfully. Please restart the app to reinitialize with the new identity.';
  }

  @override
  String get settingsRestartNow => 'Restart Now';

  @override
  String get settingsLater => 'Later';

  @override
  String get profileGroupLabel => 'Group';

  @override
  String get profileAddButton => 'Add';

  @override
  String get profileKickButton => 'Kick';

  @override
  String get dataSectionTitle => 'Data';

  @override
  String get dataBackupMessages => 'Backup Messages';

  @override
  String get dataBackupPasswordSubtitle =>
      'Choose a password to encrypt your message backup.';

  @override
  String get dataBackupConfirmLabel => 'Create Backup';

  @override
  String get dataCreatingBackup => 'Creating Backup';

  @override
  String get dataBackupPreparing => 'Preparing...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Exporting message $done of $total...';
  }

  @override
  String get dataBackupSavingFile => 'Saving file...';

  @override
  String get dataSaveMessageBackupDialog => 'Save Message Backup';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Backup saved ($count messages)\n$path';
  }

  @override
  String get dataBackupFailed => 'Backup failed — no data exported';

  @override
  String dataBackupFailedError(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Select Message Backup';

  @override
  String get dataInvalidBackupFile => 'Invalid backup file (too small)';

  @override
  String get dataNotValidBackupFile => 'Not a valid Pulse backup file';

  @override
  String get dataRestoreMessages => 'Restore Messages';

  @override
  String get dataRestorePasswordSubtitle =>
      'Enter the password used to create this backup.';

  @override
  String get dataRestoreConfirmLabel => 'Restore';

  @override
  String get dataRestoringMessages => 'Restoring Messages';

  @override
  String get dataRestoreDecrypting => 'Decrypting...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Importing message $done of $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Restore failed — wrong password or corrupt file';

  @override
  String dataRestoreSuccess(int count) {
    return 'Restored $count new messages';
  }

  @override
  String get dataRestoreNothingNew =>
      'No new messages to import (all already exist)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Select Key Export';

  @override
  String get dataNotValidKeyFile => 'Not a valid Pulse key export file';

  @override
  String get dataExportKeys => 'Export Keys';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Choose a password to encrypt your key export.';

  @override
  String get dataExportKeysConfirmLabel => 'Export';

  @override
  String get dataExportingKeys => 'Exporting Keys';

  @override
  String get dataExportingKeysStatus => 'Encrypting identity keys...';

  @override
  String get dataSaveKeyExportDialog => 'Save Key Export';

  @override
  String dataKeysExportedTo(String path) {
    return 'Keys exported to:\n$path';
  }

  @override
  String get dataExportFailed => 'Export failed — no keys found';

  @override
  String dataExportFailedError(String error) {
    return 'Export failed: $error';
  }

  @override
  String get dataImportKeys => 'Import Keys';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Enter the password used to encrypt this key export.';

  @override
  String get dataImportKeysConfirmLabel => 'Import';

  @override
  String get dataImportingKeys => 'Importing Keys';

  @override
  String get dataImportingKeysStatus => 'Decrypting identity keys...';

  @override
  String get dataImportFailed =>
      'Import failed — wrong password or corrupt file';

  @override
  String dataImportFailedError(String error) {
    return 'Import failed: $error';
  }

  @override
  String get securitySectionTitle => 'Security';

  @override
  String get securityIncorrectPassword => 'Incorrect password';

  @override
  String get securityPasswordUpdated => 'Password updated';

  @override
  String get appearanceSectionTitle => 'Appearance';

  @override
  String appearanceExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Saved to $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get aboutSectionTitle => 'About';

  @override
  String get providerPublicKey => 'Public Key';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Auto-configured from your recovery password. Relay auto-discovered.';

  @override
  String get providerKeyStoredLocally =>
      'Your key is stored locally in secure storage — never sent to any server.';

  @override
  String get providerSessionInfo =>
      'Session Network — onion-routed E2EE. Your Session ID is auto-generated and stored securely. Nodes auto-discovered from built-in seed nodes.';

  @override
  String get providerAdvanced => 'Advanced';

  @override
  String get providerSaveAndConnect => 'Save & Connect';

  @override
  String get providerAddSecondaryInbox => 'Add Secondary Inbox';

  @override
  String get providerSecondaryInboxes => 'Secondary Inboxes';

  @override
  String get providerYourInboxProvider => 'Your Inbox Provider';

  @override
  String get providerConnectionDetails => 'Connection Details';

  @override
  String get addContactTitle => 'Add Contact';

  @override
  String get addContactInviteLinkLabel => 'Invite Link or Address';

  @override
  String get addContactTapToPaste => 'Tap to paste invite link';

  @override
  String get addContactPasteTooltip => 'Paste from clipboard';

  @override
  String get addContactAddressDetected => 'Contact address detected';

  @override
  String addContactRoutesDetected(int count) {
    return '$count routes detected — SmartRouter picks the fastest';
  }

  @override
  String get addContactFetchingProfile => 'Fetching profile…';

  @override
  String addContactProfileFound(String name) {
    return 'Found: $name';
  }

  @override
  String get addContactNoProfileFound => 'No profile found';

  @override
  String get addContactDisplayNameLabel => 'Display Name';

  @override
  String get addContactDisplayNameHint => 'What do you want to call them?';

  @override
  String get addContactAddManually => 'Add address manually';

  @override
  String get addContactButton => 'Add Contact';

  @override
  String get networkDiagnosticsTitle => 'Network Diagnostics';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr Relays';

  @override
  String get networkDiagnosticsDirect => 'Direct';

  @override
  String get networkDiagnosticsTorOnly => 'Tor-only';

  @override
  String get networkDiagnosticsBest => 'Best';

  @override
  String get networkDiagnosticsNone => 'none';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Status';

  @override
  String get networkDiagnosticsConnected => 'Connected';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Connecting $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Off';

  @override
  String get networkDiagnosticsTransport => 'Transport';

  @override
  String get networkDiagnosticsInfrastructure => 'Infrastructure';

  @override
  String get networkDiagnosticsSessionNodes => 'Session nodes';

  @override
  String get networkDiagnosticsTurnServers => 'TURN servers';

  @override
  String get networkDiagnosticsLastProbe => 'Last probe';

  @override
  String get networkDiagnosticsRunning => 'Running...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Run Diagnostics';

  @override
  String get networkDiagnosticsForceReprobe => 'Force Full Re-probe';

  @override
  String get networkDiagnosticsJustNow => 'just now';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get homeNoEch => 'No ECH';

  @override
  String get homeNoEchTooltip =>
      'uTLS proxy unavailable — ECH disabled.\nTLS fingerprint is visible to DPI.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Saved & connected to $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Built-in Tor failed to start';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon failed to start';

  @override
  String get verifyTitle => 'Verify Safety Number';

  @override
  String get verifyIdentityVerified => 'Identity Verified';

  @override
  String get verifyNotYetVerified => 'Not Yet Verified';

  @override
  String verifyVerifiedDescription(String name) {
    return 'You have verified $name\'s safety number.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Compare these numbers with $name in person or over a trusted channel.';
  }

  @override
  String get verifyExplanation =>
      'Each conversation has a unique safety number. If both of you see the same numbers on your devices, your connection is verified end-to-end.';

  @override
  String verifyContactKey(String name) {
    return '$name\'s Key';
  }

  @override
  String get verifyYourKey => 'Your Key';

  @override
  String get verifyRemoveVerification => 'Remove Verification';

  @override
  String get verifyMarkAsVerified => 'Mark as Verified';

  @override
  String verifyAfterReinstall(String name) {
    return 'If $name reinstalls the app, the safety number will change and verification will be removed automatically.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Only mark as verified after comparing numbers with $name over a voice call or in person.';
  }

  @override
  String get verifyNoSession =>
      'No encryption session established yet. Send a message first to generate safety numbers.';

  @override
  String get verifyNoKeyAvailable => 'No key available';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label fingerprint copied';
  }

  @override
  String get providerDatabaseUrlLabel => 'Database URL';

  @override
  String get providerOptionalHint => 'Optional';

  @override
  String get providerWebApiKeyLabel => 'Web API Key';

  @override
  String get providerOptionalForPublicDb => 'Optional for public DB';

  @override
  String get providerRelayUrlLabel => 'Relay URL';

  @override
  String get providerPrivateKeyLabel => 'Private Key';

  @override
  String get providerPrivateKeyNsecLabel => 'Private Key (nsec)';

  @override
  String get providerStorageNodeLabel => 'Storage Node URL (optional)';

  @override
  String get providerStorageNodeHint => 'Leave empty for built-in seed nodes';

  @override
  String get transferInvalidCodeFormat =>
      'Unrecognised code format — must start with LAN: or NOS:';

  @override
  String get profileCardFingerprintCopied => 'Fingerprint copied';

  @override
  String get profileCardAboutHint => 'Privacy first 🔒';

  @override
  String get profileCardSaveButton => 'Save Profile';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Export encrypted messages, contacts and avatars to a file';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Audio';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Delivered to $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Delivered to $count';
  }

  @override
  String get groupStatusDialogTitle => 'Message Info';

  @override
  String get groupStatusRead => 'Read';

  @override
  String get groupStatusDelivered => 'Delivered';

  @override
  String get groupStatusPending => 'Pending';

  @override
  String get groupStatusNoData => 'No delivery information yet';

  @override
  String get profileTransferAdmin => 'Make Admin';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Make $name the new admin?';
  }

  @override
  String get profileTransferAdminBody =>
      'You will lose admin privileges. This cannot be undone.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name is now the admin';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyOverviewHeading => 'Overview';

  @override
  String get privacyOverviewBody =>
      'Pulse is a serverless, end-to-end encrypted messenger. Your privacy is not just a feature — it is the architecture. There are no Pulse servers. No accounts are stored anywhere. No data is collected, transmitted to, or stored by the developers.';

  @override
  String get privacyDataCollectionHeading => 'Data Collection';

  @override
  String get privacyDataCollectionBody =>
      'Pulse collects zero personal data. Specifically:\n\n- No email, phone number, or real name is required\n- No analytics, tracking, or telemetry\n- No advertising identifiers\n- No contact list access\n- No cloud backups (messages exist only on your device)\n- No metadata is sent to any Pulse server (there are none)';

  @override
  String get privacyEncryptionHeading => 'Encryption';

  @override
  String get privacyEncryptionBody =>
      'All messages are encrypted using the Signal Protocol (Double Ratchet with X3DH key agreement). Encryption keys are generated and stored exclusively on your device. No one — including the developers — can read your messages.';

  @override
  String get privacyNetworkHeading => 'Network Architecture';

  @override
  String get privacyNetworkBody =>
      'Pulse uses federated transport adapters (Nostr relays, Session/Oxen service nodes, Firebase Realtime Database, LAN). These transports carry only encrypted ciphertext. Relay operators can see your IP address and traffic volume, but cannot decrypt message content.\n\nWhen Tor is enabled, your IP address is also hidden from relay operators.';

  @override
  String get privacyStunHeading => 'STUN/TURN Servers';

  @override
  String get privacyStunBody =>
      'Voice and video calls use WebRTC with DTLS-SRTP encryption. STUN servers (used to discover your public IP for peer-to-peer connections) and TURN servers (used to relay media when direct connection fails) can see your IP address and call duration, but cannot decrypt call content.\n\nYou can configure your own TURN server in Settings for maximum privacy.';

  @override
  String get privacyCrashHeading => 'Crash Reporting';

  @override
  String get privacyCrashBody =>
      'If Sentry crash reporting is enabled (via build-time SENTRY_DSN), anonymous crash reports may be sent. These contain no message content, no contact information, and no personally identifiable information. Crash reporting can be disabled at build time by omitting the DSN.';

  @override
  String get privacyPasswordHeading => 'Password & Keys';

  @override
  String get privacyPasswordBody =>
      'Your recovery password is used to derive cryptographic keys via Argon2id (memory-hard KDF). The password is never transmitted anywhere. If you lose your password, your account cannot be recovered — there is no server to reset it.';

  @override
  String get privacyFontsHeading => 'Fonts';

  @override
  String get privacyFontsBody =>
      'Pulse bundles all fonts locally. No requests are made to Google Fonts or any external font service.';

  @override
  String get privacyThirdPartyHeading => 'Third-Party Services';

  @override
  String get privacyThirdPartyBody =>
      'Pulse does not integrate with any advertising networks, analytics providers, social media platforms, or data brokers. The only network connections are to the transport relays you configure.';

  @override
  String get privacyOpenSourceHeading => 'Open Source';

  @override
  String get privacyOpenSourceBody =>
      'Pulse is open-source software. You can audit the complete source code to verify these privacy claims.';

  @override
  String get privacyContactHeading => 'Contact';

  @override
  String get privacyContactBody =>
      'For privacy-related questions, open an issue on the project repository.';

  @override
  String get privacyLastUpdated => 'Last updated: March 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Save failed: $error';
  }

  @override
  String get themeEngineTitle => 'Theme Engine';

  @override
  String get torBuiltInTitle => 'Built-in Tor';

  @override
  String get torConnectedSubtitle =>
      'Connected — Nostr routed via 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Connecting… $pct%';
  }

  @override
  String get torNotRunning => 'Not running — tap switch to restart';

  @override
  String get torDescription =>
      'Routes Nostr via Tor (Snowflake for censored networks)';

  @override
  String get torNetworkDiagnostics => 'Network Diagnostics';

  @override
  String get torTransportLabel => 'Transport: ';

  @override
  String get torPtAuto => 'Auto';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Plain';

  @override
  String get torTimeoutLabel => 'Timeout: ';

  @override
  String get torInfoDescription =>
      'When enabled, Nostr WebSocket connections are routed through Tor (SOCKS5). Tor Browser listens on 127.0.0.1:9150. The standalone tor daemon uses port 9050. Firebase connections are not affected.';

  @override
  String get torRouteNostrTitle => 'Route Nostr via Tor';

  @override
  String get torManagedByBuiltin => 'Managed by Built-in Tor';

  @override
  String get torActiveRouting => 'Active — Nostr traffic routed through Tor';

  @override
  String get torDisabled => 'Disabled';

  @override
  String get torProxySocks5 => 'Tor Proxy (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Proxy Host';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser: port 9150  •  tor daemon: port 9050';

  @override
  String get torForceNostrTitle => 'Route messages through Tor';

  @override
  String get torForceNostrSubtitle =>
      'All Nostr relay connections will go through Tor. Slower but hides your IP from relays.';

  @override
  String get torForceNostrDisabled => 'Tor must be enabled first';

  @override
  String get torForcePulseTitle => 'Route Pulse relay through Tor';

  @override
  String get torForcePulseSubtitle =>
      'All Pulse relay connections will go through Tor. Slower but hides your IP from the server.';

  @override
  String get torForcePulseDisabled => 'Tor must be enabled first';

  @override
  String get i2pProxySocks5 => 'I2P Proxy (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P uses SOCKS5 on port 4447 by default. Connect to a Nostr relay via I2P outproxy (e.g. relay.damus.i2p) to communicate with users on any transport. Tor takes priority when both are enabled.';

  @override
  String get i2pRouteNostrTitle => 'Route Nostr via I2P';

  @override
  String get i2pActiveRouting => 'Active — Nostr traffic routed through I2P';

  @override
  String get i2pDisabled => 'Disabled';

  @override
  String get i2pProxyHostLabel => 'Proxy Host';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'I2P Router default SOCKS5 port: 4447';

  @override
  String get customProxySocks5 => 'Custom Proxy (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Custom proxy routes traffic through your V2Ray/Xray/Shadowsocks. CF Worker acts as a personal relay proxy on Cloudflare CDN — GFW sees *.workers.dev, not the real relay.';

  @override
  String get customSocks5ProxyTitle => 'Custom SOCKS5 Proxy';

  @override
  String get customProxyActive => 'Active — traffic routed via SOCKS5';

  @override
  String get customProxyDisabled => 'Disabled';

  @override
  String get customProxyHostLabel => 'Proxy Host';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker Domain (optional)';

  @override
  String get customWorkerHelpTitle => 'How to deploy a CF Worker relay (free)';

  @override
  String get customWorkerScriptCopied => 'Script copied!';

  @override
  String get customWorkerStep1 =>
      '1. Go to dash.cloudflare.com → Workers & Pages\n2. Create Worker → paste this script:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → copy domain (e.g. my-relay.user.workers.dev)\n4. Paste domain above → Save\n\nApp auto-connects: wss://domain/?r=relay_url\nGFW sees: connection to *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Connected — SOCKS5 on 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Connecting…';

  @override
  String get psiphonNotRunning => 'Not running — tap switch to restart';

  @override
  String get psiphonDescription =>
      'Fast tunnel (~3s bootstrap, 2000+ rotating VPS)';

  @override
  String get turnCommunityServers => 'Community TURN Servers';

  @override
  String get turnCustomServer => 'Custom TURN Server (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN servers only relay already-encrypted streams (DTLS-SRTP). A relay operator sees your IP and traffic volume, but cannot decrypt calls. TURN is only used when direct P2P fails (~15–20% of connections).';

  @override
  String get turnFreeLabel => 'FREE';

  @override
  String get turnServerUrlLabel => 'TURN Server URL';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 or turns:...';

  @override
  String get turnUsernameLabel => 'Username';

  @override
  String get turnPasswordLabel => 'Password';

  @override
  String get turnOptionalHint => 'Optional';

  @override
  String get turnCustomInfo =>
      'Self-host coturn on any \$5/mo VPS for maximum control. Credentials are stored locally.';

  @override
  String get themePickerAppearance => 'Appearance';

  @override
  String get themePickerAccentColor => 'Accent Color';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeDynamicPresets => 'Presets';

  @override
  String get themeDynamicPrimaryColor => 'Primary Color';

  @override
  String get themeDynamicBorderRadius => 'Border Radius';

  @override
  String get themeDynamicFont => 'Font';

  @override
  String get themeDynamicAppearance => 'Appearance';

  @override
  String get themeDynamicUiStyle => 'UI Style';

  @override
  String get themeDynamicUiStyleDescription =>
      'Controls how dialogs, switches and indicators look.';

  @override
  String get themeDynamicSharp => 'Sharp';

  @override
  String get themeDynamicRound => 'Round';

  @override
  String get themeDynamicModeDark => 'Dark';

  @override
  String get themeDynamicModeLight => 'Light';

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
      'Invalid Firebase URL. Expected https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Invalid relay URL. Expected wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Invalid Pulse server URL. Expected https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'Server URL';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'Invite Code';

  @override
  String get providerPulseInviteHint => 'Invite code (if required)';

  @override
  String get providerPulseInfo =>
      'Self-hosted relay. Keys derived from your recovery password.';

  @override
  String get providerScreenTitle => 'Inboxes';

  @override
  String get providerSecondaryInboxesHeader => 'SECONDARY INBOXES';

  @override
  String get providerSecondaryInboxesInfo =>
      'Secondary inboxes receive messages simultaneously for redundancy.';

  @override
  String get providerRemoveTooltip => 'Remove';

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
  String get emojiNoRecent => 'No recent emojis';

  @override
  String get emojiSearchHint => 'Search emoji...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Tap to chat';

  @override
  String get imageViewerSaveToDownloads => 'Save to Downloads';

  @override
  String imageViewerSavedTo(String path) {
    return 'Saved to $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'App display language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get onboardingLanguageTitle => 'Choose your language';

  @override
  String get onboardingLanguageSubtitle =>
      'You can change this later in Settings';

  @override
  String get videoNoteRecord => 'Record video message';

  @override
  String get videoNoteTapToRecord => 'Tap to record';

  @override
  String get videoNoteTapToStop => 'Tap to stop';

  @override
  String get videoNoteCameraPermission => 'Camera permission denied';

  @override
  String get videoNoteMaxDuration => 'Maximum 30 seconds';

  @override
  String get videoNoteNotSupported =>
      'Video notes not supported on this platform';

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

  @override
  String get joinChannelTitle => 'Join Channel';

  @override
  String get joinChannelDescription => 'CHANNEL URL';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'Fetching channel info…';

  @override
  String get joinChannelNotFound => 'Channel not found at this URL';

  @override
  String get joinChannelNetworkError => 'Could not reach server';

  @override
  String get joinChannelAlreadyJoined => 'Already joined';

  @override
  String get joinChannelButton => 'Join';

  @override
  String get channelFeedEmpty => 'No posts yet';

  @override
  String get channelLeave => 'Leave Channel';

  @override
  String get channelLeaveConfirm =>
      'Leave this channel? Cached posts will be deleted.';

  @override
  String get channelInfo => 'Channel Info';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'edited';

  @override
  String get channelLoadMore => 'Load more';

  @override
  String get channelSearchPosts => 'Search posts…';

  @override
  String get channelNoResults => 'No matching posts';

  @override
  String get channelUrl => 'Channel URL';

  @override
  String get channelCreated => 'Joined';

  @override
  String channelPostCount(int count) {
    return '$count posts';
  }

  @override
  String get channelCopyUrl => 'Copy URL';

  @override
  String get setupNext => 'Next';

  @override
  String get setupKeyWarning =>
      'A recovery key will be generated for you. It is the only way to restore your account on a new device — there is no server, no password reset.';

  @override
  String get setupKeyTitle => 'Your Recovery Key';

  @override
  String get setupKeySubtitle =>
      'Write this key down and store it in a safe place. You will need it to restore your account on a new device.';

  @override
  String get setupKeyCopied => 'Copied!';

  @override
  String get setupKeyWroteItDown => 'I wrote it down';

  @override
  String get setupKeyWarnBody =>
      'Write this key down as a backup. You can also view it later in Settings → Security.';

  @override
  String get setupVerifyTitle => 'Verify Recovery Key';

  @override
  String get setupVerifySubtitle =>
      'Re-enter your recovery key to confirm you saved it correctly.';

  @override
  String get setupVerifyButton => 'Verify';

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
  String get settingsViewRecoveryKey => 'View Recovery Key';

  @override
  String get settingsViewRecoveryKeySubtitle =>
      'Show your account recovery key';

  @override
  String get settingsRecoveryKeyNotStored =>
      'Recovery key not available (created before this feature)';

  @override
  String get settingsRecoveryKeyWarning =>
      'Keep this key safe. Anyone with it can restore your account on another device.';

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
  String get pulseUseServerTitle => 'Use Pulse server?';

  @override
  String pulseUseServerBody(String name, String host) {
    return '$name uses the Pulse server $host. Join it to chat faster with them (and anyone else on the same server)?';
  }

  @override
  String pulseContactUsesPulse(String name) {
    return '$name uses Pulse';
  }

  @override
  String pulseJoinForFaster(String host) {
    return 'Join $host for faster chat';
  }

  @override
  String get pulseNotNow => 'Not now';

  @override
  String get pulseJoin => 'Join';

  @override
  String get pulseDismiss => 'Dismiss';

  @override
  String get pulseHide7Days => 'Hide for 7 days';

  @override
  String get pulseNeverAskAgain => 'Never ask again';

  @override
  String get groupSearchContactsHint => 'Search contacts…';
}
