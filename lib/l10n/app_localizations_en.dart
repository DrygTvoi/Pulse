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
  String get onboardingGetStarted => 'Get Started';

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
  String get mediaTitle => 'Media';

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
  String get panicMinChars => 'Panic key must be at least 4 characters';

  @override
  String get panicKeysDoNotMatch => 'Keys do not match';

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
  String get passwordMinChars => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get profileCardSaved => 'Profile saved!';

  @override
  String get profileCardE2eeIdentity => 'E2EE Identity';

  @override
  String get profileCardDisplayName => 'Display Name';

  @override
  String get profileCardDisplayNameHint => 'e.g. Ivan Ivanov';

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
  String get settingsMyQrCode => 'My QR Code';

  @override
  String get settingsMyQrSubtitle => 'Share your address as a scannable QR';

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
}
