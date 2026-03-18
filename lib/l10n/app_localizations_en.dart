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
  String get noConnection => 'No connection — messages will queue';

  @override
  String get connected => 'Connected';

  @override
  String get connecting => 'Connecting…';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get jitsiWarningTitle => 'Not end-to-end encrypted';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet calls are not encrypted by Pulse. Only use for non-sensitive conversations.';

  @override
  String get jitsiConfirm => 'Join anyway';

  @override
  String get retry => 'Retry';
}
