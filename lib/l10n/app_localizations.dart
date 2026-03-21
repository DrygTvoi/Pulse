import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get appTitle;

  /// No description provided for @searchMessages.
  ///
  /// In en, this message translates to:
  /// **'Search messages...'**
  String get searchMessages;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @closeSearch.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get closeSearch;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @homeNewGroup.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get homeNewGroup;

  /// No description provided for @homeSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettings;

  /// No description provided for @homeSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching messages...'**
  String get homeSearching;

  /// No description provided for @homeNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get homeNoResults;

  /// No description provided for @homeNoChatHistory.
  ///
  /// In en, this message translates to:
  /// **'No chat history yet'**
  String get homeNoChatHistory;

  /// No description provided for @homeTransportSwitched.
  ///
  /// In en, this message translates to:
  /// **'Transport switched → {address}'**
  String homeTransportSwitched(String address);

  /// No description provided for @homeIncomingCall.
  ///
  /// In en, this message translates to:
  /// **'{name} is calling...'**
  String homeIncomingCall(String name);

  /// No description provided for @homeAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get homeAccept;

  /// No description provided for @homeDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get homeDecline;

  /// No description provided for @homeLoadEarlier.
  ///
  /// In en, this message translates to:
  /// **'Load earlier messages'**
  String get homeLoadEarlier;

  /// No description provided for @homeChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get homeChats;

  /// No description provided for @homeSelectConversation.
  ///
  /// In en, this message translates to:
  /// **'Select a conversation'**
  String get homeSelectConversation;

  /// No description provided for @homeNoChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get homeNoChatsYet;

  /// No description provided for @homeAddContactToStart.
  ///
  /// In en, this message translates to:
  /// **'Add a contact to start chatting'**
  String get homeAddContactToStart;

  /// No description provided for @homeNewChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get homeNewChat;

  /// No description provided for @homeNewChatTooltip.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get homeNewChatTooltip;

  /// No description provided for @homeIncomingCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Incoming Call'**
  String get homeIncomingCallTitle;

  /// No description provided for @homeIncomingGroupCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Incoming Group Call'**
  String get homeIncomingGroupCallTitle;

  /// No description provided for @homeGroupCallIncoming.
  ///
  /// In en, this message translates to:
  /// **'{name} — group call incoming'**
  String homeGroupCallIncoming(String name);

  /// No description provided for @homeNoChatsMatchingQuery.
  ///
  /// In en, this message translates to:
  /// **'No chats matching \"{query}\"'**
  String homeNoChatsMatchingQuery(String query);

  /// No description provided for @homeSectionChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get homeSectionChats;

  /// No description provided for @homeSectionMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get homeSectionMessages;

  /// No description provided for @homeDbEncryptionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Database encryption unavailable — install SQLCipher for full protection'**
  String get homeDbEncryptionUnavailable;

  /// No description provided for @chatFileTooLargeGroup.
  ///
  /// In en, this message translates to:
  /// **'Files over 512 KB are not supported in group chats'**
  String get chatFileTooLargeGroup;

  /// No description provided for @chatLargeFile.
  ///
  /// In en, this message translates to:
  /// **'Large File'**
  String get chatLargeFile;

  /// No description provided for @chatCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get chatCancel;

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// No description provided for @chatFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File too large — maximum size is 100 MB'**
  String get chatFileTooLarge;

  /// No description provided for @chatMicDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied'**
  String get chatMicDenied;

  /// No description provided for @chatVoiceFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save voice message — check available storage'**
  String get chatVoiceFailed;

  /// No description provided for @chatScheduleFuture.
  ///
  /// In en, this message translates to:
  /// **'Scheduled time must be in the future'**
  String get chatScheduleFuture;

  /// No description provided for @chatToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get chatToday;

  /// No description provided for @chatYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get chatYesterday;

  /// No description provided for @chatEdited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get chatEdited;

  /// No description provided for @chatYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get chatYou;

  /// No description provided for @chatLargeFileSizeWarning.
  ///
  /// In en, this message translates to:
  /// **'This file is {size} MB. Sending large files may be slow on some networks. Continue?'**
  String chatLargeFileSizeWarning(String size);

  /// No description provided for @chatKeyChangedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s security key changed. Tap to verify.'**
  String chatKeyChangedSnackbar(String name);

  /// No description provided for @chatEncryptionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not encrypt message to {name} — message not sent.'**
  String chatEncryptionFailed(String name);

  /// No description provided for @chatSafetyNumberChanged.
  ///
  /// In en, this message translates to:
  /// **'Safety number changed for {name}. Tap to verify.'**
  String chatSafetyNumberChanged(String name);

  /// No description provided for @chatNoMessagesFound.
  ///
  /// In en, this message translates to:
  /// **'No messages found'**
  String get chatNoMessagesFound;

  /// No description provided for @chatMessagesE2ee.
  ///
  /// In en, this message translates to:
  /// **'Messages are end-to-end encrypted'**
  String get chatMessagesE2ee;

  /// No description provided for @chatSayHello.
  ///
  /// In en, this message translates to:
  /// **'Say hello'**
  String get chatSayHello;

  /// No description provided for @appBarOnline.
  ///
  /// In en, this message translates to:
  /// **'online'**
  String get appBarOnline;

  /// No description provided for @appBarSignalE2ee.
  ///
  /// In en, this message translates to:
  /// **'Signal E2EE'**
  String get appBarSignalE2ee;

  /// No description provided for @appBarKyber.
  ///
  /// In en, this message translates to:
  /// **'+ Kyber'**
  String get appBarKyber;

  /// No description provided for @appBarTyping.
  ///
  /// In en, this message translates to:
  /// **'typing'**
  String get appBarTyping;

  /// No description provided for @appBarSearchMessages.
  ///
  /// In en, this message translates to:
  /// **'Search messages...'**
  String get appBarSearchMessages;

  /// No description provided for @appBarMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get appBarMute;

  /// No description provided for @appBarUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get appBarUnmute;

  /// No description provided for @appBarMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get appBarMedia;

  /// No description provided for @appBarDisappearing.
  ///
  /// In en, this message translates to:
  /// **'Disappearing messages'**
  String get appBarDisappearing;

  /// No description provided for @appBarDisappearingOn.
  ///
  /// In en, this message translates to:
  /// **'Disappearing: on'**
  String get appBarDisappearingOn;

  /// No description provided for @appBarGroupSettings.
  ///
  /// In en, this message translates to:
  /// **'Group settings'**
  String get appBarGroupSettings;

  /// No description provided for @appBarSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search messages'**
  String get appBarSearchTooltip;

  /// No description provided for @appBarVoiceCall.
  ///
  /// In en, this message translates to:
  /// **'Voice call'**
  String get appBarVoiceCall;

  /// No description provided for @appBarVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Video call'**
  String get appBarVideoCall;

  /// No description provided for @inputMessage.
  ///
  /// In en, this message translates to:
  /// **'Message...'**
  String get inputMessage;

  /// No description provided for @inputAttachFile.
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get inputAttachFile;

  /// No description provided for @inputSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get inputSendMessage;

  /// No description provided for @inputRecordVoice.
  ///
  /// In en, this message translates to:
  /// **'Record voice message'**
  String get inputRecordVoice;

  /// No description provided for @inputSendVoice.
  ///
  /// In en, this message translates to:
  /// **'Send voice message'**
  String get inputSendVoice;

  /// No description provided for @inputCancelReply.
  ///
  /// In en, this message translates to:
  /// **'Cancel reply'**
  String get inputCancelReply;

  /// No description provided for @inputCancelEdit.
  ///
  /// In en, this message translates to:
  /// **'Cancel edit'**
  String get inputCancelEdit;

  /// No description provided for @inputCancelRecording.
  ///
  /// In en, this message translates to:
  /// **'Cancel recording'**
  String get inputCancelRecording;

  /// No description provided for @inputRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording…'**
  String get inputRecording;

  /// No description provided for @inputEditingMessage.
  ///
  /// In en, this message translates to:
  /// **'Editing message'**
  String get inputEditingMessage;

  /// No description provided for @inputPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get inputPhoto;

  /// No description provided for @inputVoiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Voice message'**
  String get inputVoiceMessage;

  /// No description provided for @inputFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get inputFile;

  /// No description provided for @inputScheduledMessages.
  ///
  /// In en, this message translates to:
  /// **'{count} scheduled message{count, plural, =1{} other{s}}'**
  String inputScheduledMessages(int count);

  /// No description provided for @callInitializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing call…'**
  String get callInitializing;

  /// No description provided for @callConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get callConnecting;

  /// No description provided for @callConnectingRelay.
  ///
  /// In en, this message translates to:
  /// **'Connecting (relay)…'**
  String get callConnectingRelay;

  /// No description provided for @callSwitchingRelay.
  ///
  /// In en, this message translates to:
  /// **'Switching to relay mode…'**
  String get callSwitchingRelay;

  /// No description provided for @callConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get callConnectionFailed;

  /// No description provided for @callReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get callReconnecting;

  /// No description provided for @callEnded.
  ///
  /// In en, this message translates to:
  /// **'Call ended'**
  String get callEnded;

  /// No description provided for @callLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get callLive;

  /// No description provided for @callEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get callEnd;

  /// No description provided for @callEndCall.
  ///
  /// In en, this message translates to:
  /// **'End call'**
  String get callEndCall;

  /// No description provided for @callMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get callMute;

  /// No description provided for @callUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get callUnmute;

  /// No description provided for @callSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get callSpeaker;

  /// No description provided for @callCameraOn.
  ///
  /// In en, this message translates to:
  /// **'Camera On'**
  String get callCameraOn;

  /// No description provided for @callCameraOff.
  ///
  /// In en, this message translates to:
  /// **'Camera Off'**
  String get callCameraOff;

  /// No description provided for @callShareScreen.
  ///
  /// In en, this message translates to:
  /// **'Share Screen'**
  String get callShareScreen;

  /// No description provided for @callStopShare.
  ///
  /// In en, this message translates to:
  /// **'Stop Share'**
  String get callStopShare;

  /// No description provided for @callTorBackup.
  ///
  /// In en, this message translates to:
  /// **'Tor backup · {duration}'**
  String callTorBackup(String duration);

  /// No description provided for @callTorBackupBanner.
  ///
  /// In en, this message translates to:
  /// **'Tor backup active — primary path unavailable'**
  String get callTorBackupBanner;

  /// No description provided for @callDirectFailed.
  ///
  /// In en, this message translates to:
  /// **'Direct connection failed — switching to relay mode…'**
  String get callDirectFailed;

  /// No description provided for @callTurnUnreachable.
  ///
  /// In en, this message translates to:
  /// **'TURN servers unreachable. Add a custom TURN in Settings → Advanced.'**
  String get callTurnUnreachable;

  /// No description provided for @callRelayMode.
  ///
  /// In en, this message translates to:
  /// **'Relay mode active (restricted network)'**
  String get callRelayMode;

  /// No description provided for @callStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting call…'**
  String get callStarting;

  /// No description provided for @callConnectingToGroup.
  ///
  /// In en, this message translates to:
  /// **'Connecting to group…'**
  String get callConnectingToGroup;

  /// No description provided for @callGroupOpenedInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Group call opened in browser'**
  String get callGroupOpenedInBrowser;

  /// No description provided for @callCouldNotOpenBrowser.
  ///
  /// In en, this message translates to:
  /// **'Could not open browser'**
  String get callCouldNotOpenBrowser;

  /// No description provided for @callInviteLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Invite link sent to all group members.'**
  String get callInviteLinkSent;

  /// No description provided for @callOpenLinkManually.
  ///
  /// In en, this message translates to:
  /// **'Open the link above manually or tap to retry.'**
  String get callOpenLinkManually;

  /// No description provided for @callJitsiNotE2ee.
  ///
  /// In en, this message translates to:
  /// **'Jitsi calls are NOT end-to-end encrypted'**
  String get callJitsiNotE2ee;

  /// No description provided for @callRetryOpenBrowser.
  ///
  /// In en, this message translates to:
  /// **'Retry open browser'**
  String get callRetryOpenBrowser;

  /// No description provided for @callClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get callClose;

  /// No description provided for @callCamOn.
  ///
  /// In en, this message translates to:
  /// **'Cam on'**
  String get callCamOn;

  /// No description provided for @callCamOff.
  ///
  /// In en, this message translates to:
  /// **'Cam off'**
  String get callCamOff;

  /// No description provided for @noConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection — messages will queue'**
  String get noConnection;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connecting;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'No connection — messages will queue and send when back online'**
  String get offlineBanner;

  /// No description provided for @lanModeBanner.
  ///
  /// In en, this message translates to:
  /// **'LAN Mode — No internet · Local network only'**
  String get lanModeBanner;

  /// No description provided for @probeCheckingNetwork.
  ///
  /// In en, this message translates to:
  /// **'Checking network connectivity…'**
  String get probeCheckingNetwork;

  /// No description provided for @probeDiscoveringRelays.
  ///
  /// In en, this message translates to:
  /// **'Discovering relays via community directories…'**
  String get probeDiscoveringRelays;

  /// No description provided for @probeStartingTor.
  ///
  /// In en, this message translates to:
  /// **'Starting Tor for bootstrap…'**
  String get probeStartingTor;

  /// No description provided for @probeFindingRelaysTor.
  ///
  /// In en, this message translates to:
  /// **'Finding reachable relays via Tor…'**
  String get probeFindingRelaysTor;

  /// No description provided for @probeNetworkReady.
  ///
  /// In en, this message translates to:
  /// **'Network ready — {count} relay{count, plural, =1{} other{s}} found'**
  String probeNetworkReady(int count);

  /// No description provided for @probeNoRelaysFound.
  ///
  /// In en, this message translates to:
  /// **'No reachable relays found — messages may be delayed'**
  String get probeNoRelaysFound;

  /// No description provided for @jitsiWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Not end-to-end encrypted'**
  String get jitsiWarningTitle;

  /// No description provided for @jitsiWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Jitsi Meet calls are not encrypted by Pulse. Only use for non-sensitive conversations.'**
  String get jitsiWarningBody;

  /// No description provided for @jitsiConfirm.
  ///
  /// In en, this message translates to:
  /// **'Join anyway'**
  String get jitsiConfirm;

  /// No description provided for @jitsiGroupWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Not end-to-end encrypted'**
  String get jitsiGroupWarningTitle;

  /// No description provided for @jitsiGroupWarningBody.
  ///
  /// In en, this message translates to:
  /// **'This call has too many participants for the built-in encrypted mesh.\n\nA Jitsi Meet link will be opened in your browser. Jitsi is NOT end-to-end encrypted — the server can see your call.'**
  String get jitsiGroupWarningBody;

  /// No description provided for @jitsiContinueAnyway.
  ///
  /// In en, this message translates to:
  /// **'Continue anyway'**
  String get jitsiContinueAnyway;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @setupCreateAnonymousAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an anonymous account'**
  String get setupCreateAnonymousAccount;

  /// No description provided for @setupTapToChangeColor.
  ///
  /// In en, this message translates to:
  /// **'Tap to change color'**
  String get setupTapToChangeColor;

  /// No description provided for @setupYourNickname.
  ///
  /// In en, this message translates to:
  /// **'Your nickname'**
  String get setupYourNickname;

  /// No description provided for @setupRecoveryPassword.
  ///
  /// In en, this message translates to:
  /// **'Recovery password (min. 16)'**
  String get setupRecoveryPassword;

  /// No description provided for @setupConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get setupConfirmPassword;

  /// No description provided for @setupMin16Chars.
  ///
  /// In en, this message translates to:
  /// **'Minimum 16 characters'**
  String get setupMin16Chars;

  /// No description provided for @setupPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get setupPasswordsDoNotMatch;

  /// No description provided for @setupEntropyWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get setupEntropyWeak;

  /// No description provided for @setupEntropyOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get setupEntropyOk;

  /// No description provided for @setupEntropyStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get setupEntropyStrong;

  /// No description provided for @setupEntropyWeakNeedsVariety.
  ///
  /// In en, this message translates to:
  /// **'Weak (need 3 char types)'**
  String get setupEntropyWeakNeedsVariety;

  /// No description provided for @setupEntropyBits.
  ///
  /// In en, this message translates to:
  /// **'{label} ({bits} bits)'**
  String setupEntropyBits(String label, int bits);

  /// No description provided for @setupPasswordWarning.
  ///
  /// In en, this message translates to:
  /// **'This password is the only way to restore your account. There is no server — no password reset. Remember it or write it down.'**
  String get setupPasswordWarning;

  /// No description provided for @setupCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get setupCreateAccount;

  /// No description provided for @setupAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get setupAlreadyHaveAccount;

  /// No description provided for @setupRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore →'**
  String get setupRestore;

  /// No description provided for @restoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore account'**
  String get restoreTitle;

  /// No description provided for @restoreInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'Enter your recovery password — your address (Nostr + Session) will be restored automatically. Contacts and messages were stored locally only.'**
  String get restoreInfoBanner;

  /// No description provided for @restoreNewNickname.
  ///
  /// In en, this message translates to:
  /// **'New nickname (can change later)'**
  String get restoreNewNickname;

  /// No description provided for @restoreButton.
  ///
  /// In en, this message translates to:
  /// **'Restore account'**
  String get restoreButton;

  /// No description provided for @lockTitle.
  ///
  /// In en, this message translates to:
  /// **'Pulse is locked'**
  String get lockTitle;

  /// No description provided for @lockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to continue'**
  String get lockSubtitle;

  /// No description provided for @lockPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get lockPasswordHint;

  /// No description provided for @lockUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get lockUnlock;

  /// No description provided for @lockPanicHint.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password? Enter your panic key to wipe all data.'**
  String get lockPanicHint;

  /// No description provided for @lockTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Erasing all data…'**
  String get lockTooManyAttempts;

  /// No description provided for @lockWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get lockWrongPassword;

  /// No description provided for @lockWrongPasswordAttempts.
  ///
  /// In en, this message translates to:
  /// **'Wrong password — {attempts}/{max} attempts'**
  String lockWrongPasswordAttempts(int attempts, int max);

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Pulse'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'A decentralized, end-to-end encrypted messenger.\n\nNo central servers. No data collection. No backdoors.\nYour conversations belong only to you.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingTransportTitle.
  ///
  /// In en, this message translates to:
  /// **'Transport-Agnostic'**
  String get onboardingTransportTitle;

  /// No description provided for @onboardingTransportBody.
  ///
  /// In en, this message translates to:
  /// **'Use Firebase, Nostr, or both at the same time.\n\nMessages route across networks automatically. Built-in Tor and I2P support for censorship resistance.'**
  String get onboardingTransportBody;

  /// No description provided for @onboardingSignalTitle.
  ///
  /// In en, this message translates to:
  /// **'Signal + Post-Quantum'**
  String get onboardingSignalTitle;

  /// No description provided for @onboardingSignalBody.
  ///
  /// In en, this message translates to:
  /// **'Every message is encrypted with the Signal Protocol (Double Ratchet + X3DH) for forward secrecy.\n\nAdditionally wrapped with Kyber-1024 — a NIST-standard post-quantum algorithm — protecting against future quantum computers.'**
  String get onboardingSignalBody;

  /// No description provided for @onboardingKeysTitle.
  ///
  /// In en, this message translates to:
  /// **'You Own Your Keys'**
  String get onboardingKeysTitle;

  /// No description provided for @onboardingKeysBody.
  ///
  /// In en, this message translates to:
  /// **'Your identity keys never leave your device.\n\nSignal fingerprints let you verify contacts out-of-band. TOFU (Trust On First Use) detects key changes automatically.'**
  String get onboardingKeysBody;

  /// No description provided for @onboardingThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Look'**
  String get onboardingThemeTitle;

  /// No description provided for @onboardingThemeBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a theme and accent colour. You can always change this later in Settings.'**
  String get onboardingThemeBody;

  /// No description provided for @contactsNewChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get contactsNewChat;

  /// No description provided for @contactsAddContact.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get contactsAddContact;

  /// No description provided for @contactsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get contactsSearchHint;

  /// No description provided for @contactsNewGroup.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get contactsNewGroup;

  /// No description provided for @contactsNoContactsYet.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet'**
  String get contactsNoContactsYet;

  /// No description provided for @contactsAddHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add someone\'s address'**
  String get contactsAddHint;

  /// No description provided for @contactsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No contacts match'**
  String get contactsNoMatch;

  /// No description provided for @contactsRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove contact'**
  String get contactsRemoveTitle;

  /// No description provided for @contactsRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String contactsRemoveMessage(String name);

  /// No description provided for @contactsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get contactsRemove;

  /// No description provided for @contactsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} contact{count, plural, =1{} other{s}}'**
  String contactsCount(int count);

  /// No description provided for @bubbleOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Open Link'**
  String get bubbleOpenLink;

  /// No description provided for @bubbleOpenLinkBody.
  ///
  /// In en, this message translates to:
  /// **'Open this URL in your browser?\n\n{url}'**
  String bubbleOpenLinkBody(String url);

  /// No description provided for @bubbleOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get bubbleOpen;

  /// No description provided for @bubbleSecurityWarning.
  ///
  /// In en, this message translates to:
  /// **'Security Warning'**
  String get bubbleSecurityWarning;

  /// No description provided for @bubbleExecutableWarning.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is an executable file type. Saving and running it could harm your device. Save anyway?'**
  String bubbleExecutableWarning(String name);

  /// No description provided for @bubbleSaveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save Anyway'**
  String get bubbleSaveAnyway;

  /// No description provided for @bubbleSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String bubbleSavedTo(String path);

  /// No description provided for @bubbleSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String bubbleSaveFailed(String error);

  /// No description provided for @bubbleNotEncrypted.
  ///
  /// In en, this message translates to:
  /// **'NOT ENCRYPTED'**
  String get bubbleNotEncrypted;

  /// No description provided for @bubbleCorruptedImage.
  ///
  /// In en, this message translates to:
  /// **'[Corrupted image]'**
  String get bubbleCorruptedImage;

  /// No description provided for @bubbleReplyPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get bubbleReplyPhoto;

  /// No description provided for @bubbleReplyVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice message'**
  String get bubbleReplyVoice;

  /// No description provided for @bubbleReadBy.
  ///
  /// In en, this message translates to:
  /// **'Read by {names}'**
  String bubbleReadBy(String names);

  /// No description provided for @bubbleReadByCount.
  ///
  /// In en, this message translates to:
  /// **'Read by {count}'**
  String bubbleReadByCount(int count);

  /// No description provided for @chatTileTapToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap to start chatting'**
  String get chatTileTapToStart;

  /// No description provided for @chatTileMessageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent'**
  String get chatTileMessageSent;

  /// No description provided for @chatTileEncryptedMessage.
  ///
  /// In en, this message translates to:
  /// **'Encrypted message'**
  String get chatTileEncryptedMessage;

  /// No description provided for @chatTileYouPrefix.
  ///
  /// In en, this message translates to:
  /// **'You: {text}'**
  String chatTileYouPrefix(String text);

  /// No description provided for @bannerEncryptedMessage.
  ///
  /// In en, this message translates to:
  /// **'Encrypted message'**
  String get bannerEncryptedMessage;

  /// Title for the create group dialog
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get groupNewGroup;

  /// Hint text for group name input
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupGroupName;

  /// Label above member selection list
  ///
  /// In en, this message translates to:
  /// **'Select members (min 2)'**
  String get groupSelectMembers;

  /// Shown when no contacts available for group creation
  ///
  /// In en, this message translates to:
  /// **'No contacts yet. Add contacts first.'**
  String get groupNoContactsYet;

  /// Create group button text
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get groupCreate;

  /// Badge label for group contacts
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupLabel;

  /// Title for the verify identity dialog
  ///
  /// In en, this message translates to:
  /// **'Verify Identity'**
  String get profileVerifyIdentity;

  /// Instructions in the verify identity dialog
  ///
  /// In en, this message translates to:
  /// **'Compare these fingerprints with {name} over a voice call or in person. If both values match on both devices, tap \"Mark as Verified\".'**
  String profileVerifyInstructions(String name);

  /// Label for contact's fingerprint
  ///
  /// In en, this message translates to:
  /// **'Their key'**
  String get profileTheirKey;

  /// Label for own fingerprint
  ///
  /// In en, this message translates to:
  /// **'Your key'**
  String get profileYourKey;

  /// Button to remove identity verification
  ///
  /// In en, this message translates to:
  /// **'Remove Verification'**
  String get profileRemoveVerification;

  /// Button to mark identity as verified
  ///
  /// In en, this message translates to:
  /// **'Mark as Verified'**
  String get profileMarkAsVerified;

  /// Snackbar text when address is copied
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get profileAddressCopied;

  /// Snackbar when all contacts are already group members
  ///
  /// In en, this message translates to:
  /// **'No contacts to add — all are already members'**
  String get profileNoContactsToAdd;

  /// Title for the add members bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Add Members'**
  String get profileAddMembers;

  /// Button text for adding selected members
  ///
  /// In en, this message translates to:
  /// **'Add ({count})'**
  String profileAddCount(int count);

  /// Title for the rename group dialog
  ///
  /// In en, this message translates to:
  /// **'Rename Group'**
  String get profileRenameGroup;

  /// Rename button text
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get profileRename;

  /// Title for the kick member confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Remove member?'**
  String get profileRemoveMember;

  /// Body for the kick member confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from this group?'**
  String profileRemoveMemberBody(String name);

  /// Button to remove a member from group
  ///
  /// In en, this message translates to:
  /// **'Kick'**
  String get profileKick;

  /// Label for Signal fingerprints section
  ///
  /// In en, this message translates to:
  /// **'Signal Fingerprints'**
  String get profileSignalFingerprints;

  /// Badge text for verified identity
  ///
  /// In en, this message translates to:
  /// **'VERIFIED'**
  String get profileVerified;

  /// Button to open verify dialog
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get profileVerify;

  /// Button to edit verification
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get profileEdit;

  /// Shown when no Signal session exists
  ///
  /// In en, this message translates to:
  /// **'No session established yet — send a message first.'**
  String get profileNoSession;

  /// Snackbar when fingerprint is copied
  ///
  /// In en, this message translates to:
  /// **'Fingerprint copied'**
  String get profileFingerprintCopied;

  /// Shows the number of group members
  ///
  /// In en, this message translates to:
  /// **'{count} member{count, plural, =1{} other{s}}'**
  String profileMemberCount(int count);

  /// Button to verify safety number
  ///
  /// In en, this message translates to:
  /// **'Verify Safety Number'**
  String get profileVerifySafetyNumber;

  /// Button to show contact QR code
  ///
  /// In en, this message translates to:
  /// **'Show Contact QR'**
  String get profileShowContactQr;

  /// QR dialog title showing contact address
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Address'**
  String profileContactAddress(String name);

  /// Button to export chat history
  ///
  /// In en, this message translates to:
  /// **'Export Chat History'**
  String get profileExportChatHistory;

  /// Snackbar text after successful export
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String profileSavedTo(String path);

  /// Snackbar text when export fails
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get profileExportFailed;

  /// Button to clear chat history
  ///
  /// In en, this message translates to:
  /// **'Clear chat history'**
  String get profileClearChatHistory;

  /// Button to delete a group
  ///
  /// In en, this message translates to:
  /// **'Delete group'**
  String get profileDeleteGroup;

  /// Button to delete a contact
  ///
  /// In en, this message translates to:
  /// **'Delete contact'**
  String get profileDeleteContact;

  /// Button to leave a group
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get profileLeaveGroup;

  /// Confirmation body for leaving a group
  ///
  /// In en, this message translates to:
  /// **'You will be removed from this group and it will be deleted from your contacts.'**
  String get profileLeaveGroupBody;

  /// Title for the incoming group invite dialog
  ///
  /// In en, this message translates to:
  /// **'Group invitation'**
  String get groupInviteTitle;

  /// Body text for group invite dialog
  ///
  /// In en, this message translates to:
  /// **'{from} invited you to join \"{group}\"'**
  String groupInviteBody(String from, String group);

  /// Accept group invite button
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get groupInviteAccept;

  /// Decline group invite button
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get groupInviteDecline;

  /// Title for dialog when group exceeds mesh call limit
  ///
  /// In en, this message translates to:
  /// **'Too many participants'**
  String get groupMemberLimitTitle;

  /// Body for dialog when group exceeds mesh call limit
  ///
  /// In en, this message translates to:
  /// **'This group will have {count} participants. Encrypted mesh calls support up to 6. Larger groups fall back to Jitsi (not E2EE).'**
  String groupMemberLimitBody(int count);

  /// Button to add members despite the call limit warning
  ///
  /// In en, this message translates to:
  /// **'Add anyway'**
  String get groupMemberLimitContinue;

  /// Snackbar shown to inviter when someone declines a group invite
  ///
  /// In en, this message translates to:
  /// **'{name} declined to join \"{group}\"'**
  String groupInviteDeclinedSnackbar(String name, String group);

  /// Title for the device transfer screen
  ///
  /// In en, this message translates to:
  /// **'Transfer to Another Device'**
  String get transferTitle;

  /// Info box explaining transfer
  ///
  /// In en, this message translates to:
  /// **'Move your Signal identity and Nostr keys to a new device.\nChat sessions are NOT transferred — forward secrecy is preserved.'**
  String get transferInfoBox;

  /// Role card title for sender
  ///
  /// In en, this message translates to:
  /// **'Send from this device'**
  String get transferSendFromThis;

  /// Role card subtitle for sender
  ///
  /// In en, this message translates to:
  /// **'This device has the keys. Share a code with the new device.'**
  String get transferSendSubtitle;

  /// Role card title for receiver
  ///
  /// In en, this message translates to:
  /// **'Receive on this device'**
  String get transferReceiveOnThis;

  /// Role card subtitle for receiver
  ///
  /// In en, this message translates to:
  /// **'This is the new device. Enter the code from the old device.'**
  String get transferReceiveSubtitle;

  /// Section label for transfer method selection
  ///
  /// In en, this message translates to:
  /// **'Choose Transfer Method'**
  String get transferChooseMethod;

  /// LAN transfer method title
  ///
  /// In en, this message translates to:
  /// **'LAN (Same Network)'**
  String get transferLan;

  /// LAN transfer method subtitle
  ///
  /// In en, this message translates to:
  /// **'Fast, direct. Both devices must be on the same Wi-Fi.'**
  String get transferLanSubtitle;

  /// Nostr relay transfer method title
  ///
  /// In en, this message translates to:
  /// **'Nostr Relay'**
  String get transferNostrRelay;

  /// Nostr relay transfer subtitle
  ///
  /// In en, this message translates to:
  /// **'Works over any network using an existing Nostr relay.'**
  String get transferNostrRelaySubtitle;

  /// Label for relay URL field
  ///
  /// In en, this message translates to:
  /// **'Relay URL'**
  String get transferRelayUrl;

  /// Section label for receiver code input
  ///
  /// In en, this message translates to:
  /// **'Enter Transfer Code'**
  String get transferEnterCode;

  /// Hint for code input field
  ///
  /// In en, this message translates to:
  /// **'Paste the LAN:... or NOS:... code here'**
  String get transferPasteCode;

  /// Connect button text
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get transferConnect;

  /// Shown while generating transfer code
  ///
  /// In en, this message translates to:
  /// **'Generating transfer code…'**
  String get transferGenerating;

  /// Label above the transfer code
  ///
  /// In en, this message translates to:
  /// **'Share this code with the receiver:'**
  String get transferShareCode;

  /// Button to copy transfer code
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get transferCopyCode;

  /// Snackbar when code is copied
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get transferCodeCopied;

  /// Status while waiting for receiver
  ///
  /// In en, this message translates to:
  /// **'Waiting for receiver to connect…'**
  String get transferWaitingReceiver;

  /// Status while connecting to sender
  ///
  /// In en, this message translates to:
  /// **'Connecting to sender…'**
  String get transferConnectingSender;

  /// Verification instructions
  ///
  /// In en, this message translates to:
  /// **'Compare this code on both devices.\nIf they match, the transfer is secure.'**
  String get transferVerifyBoth;

  /// Title when transfer is done (sender)
  ///
  /// In en, this message translates to:
  /// **'Transfer Complete'**
  String get transferComplete;

  /// Title when keys are imported (receiver)
  ///
  /// In en, this message translates to:
  /// **'Keys Imported'**
  String get transferKeysImported;

  /// Body text for sender after transfer
  ///
  /// In en, this message translates to:
  /// **'Your keys remain active on this device.\nThe receiver can now use your identity.'**
  String get transferCompleteSenderBody;

  /// Body text for receiver after transfer
  ///
  /// In en, this message translates to:
  /// **'Keys imported successfully.\nRestart the app to apply the new identity.'**
  String get transferCompleteReceiverBody;

  /// Button to restart the app
  ///
  /// In en, this message translates to:
  /// **'Restart App'**
  String get transferRestartApp;

  /// Title when transfer fails
  ///
  /// In en, this message translates to:
  /// **'Transfer Failed'**
  String get transferFailed;

  /// Button to retry transfer
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get transferTryAgain;

  /// Snackbar when relay URL is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a relay URL first'**
  String get transferEnterRelayFirst;

  /// Snackbar when code field is empty
  ///
  /// In en, this message translates to:
  /// **'Paste the transfer code from the sender'**
  String get transferPasteCodeFromSender;

  /// Message menu item to reply
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get menuReply;

  /// Message menu item to forward
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get menuForward;

  /// Message menu item to react
  ///
  /// In en, this message translates to:
  /// **'React'**
  String get menuReact;

  /// Message menu item to copy
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get menuCopy;

  /// Message menu item to edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get menuEdit;

  /// Message menu item to retry sending
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get menuRetry;

  /// Message menu item to cancel scheduled message
  ///
  /// In en, this message translates to:
  /// **'Cancel scheduled'**
  String get menuCancelScheduled;

  /// Message menu item to delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get menuDelete;

  /// Title for forward picker sheet
  ///
  /// In en, this message translates to:
  /// **'Forward to…'**
  String get menuForwardTo;

  /// Snackbar after forwarding a message
  ///
  /// In en, this message translates to:
  /// **'Forwarded to {name}'**
  String menuForwardedTo(String name);

  /// Title for the scheduled messages panel
  ///
  /// In en, this message translates to:
  /// **'Scheduled messages'**
  String get menuScheduledMessages;

  /// Shown when no scheduled messages exist
  ///
  /// In en, this message translates to:
  /// **'No scheduled messages'**
  String get menuNoScheduledMessages;

  /// Subtitle showing scheduled send time
  ///
  /// In en, this message translates to:
  /// **'Sends on {date}'**
  String menuSendsOn(String date);

  /// Title for disappearing messages dialog
  ///
  /// In en, this message translates to:
  /// **'Disappearing Messages'**
  String get menuDisappearingMessages;

  /// Subtitle for disappearing messages dialog
  ///
  /// In en, this message translates to:
  /// **'Messages delete automatically after the selected time.'**
  String get menuDisappearingSubtitle;

  /// TTL option: disabled
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get menuTtlOff;

  /// TTL option: 1 hour
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get menuTtl1h;

  /// TTL option: 24 hours
  ///
  /// In en, this message translates to:
  /// **'24 hours'**
  String get menuTtl24h;

  /// TTL option: 7 days
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get menuTtl7d;

  /// Attach menu photo option
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get menuAttachPhoto;

  /// Attach menu file option
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get menuAttachFile;

  /// Title for media gallery screen
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get mediaTitle;

  /// Fallback file type label when extension is unavailable
  ///
  /// In en, this message translates to:
  /// **'FILE'**
  String get mediaFileLabel;

  /// Tab label for photos with count
  ///
  /// In en, this message translates to:
  /// **'Photos ({count})'**
  String mediaPhotosTab(int count);

  /// Tab label for files with count
  ///
  /// In en, this message translates to:
  /// **'Files ({count})'**
  String mediaFilesTab(int count);

  /// Empty state for photos tab
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get mediaNoPhotos;

  /// Empty state for files tab
  ///
  /// In en, this message translates to:
  /// **'No files yet'**
  String get mediaNoFiles;

  /// Snackbar after saving a file
  ///
  /// In en, this message translates to:
  /// **'Saved to Downloads/{name}'**
  String mediaSavedToDownloads(String name);

  /// Snackbar when file save fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save file'**
  String get mediaFailedToSave;

  /// Title for status creator screen
  ///
  /// In en, this message translates to:
  /// **'New Status'**
  String get statusNewStatus;

  /// Button to publish a status
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get statusPublish;

  /// Info text about status expiry
  ///
  /// In en, this message translates to:
  /// **'Status expires in 24 hours'**
  String get statusExpiresIn24h;

  /// Hint text for status text input
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get statusWhatsOnYourMind;

  /// Label when photo is attached to status
  ///
  /// In en, this message translates to:
  /// **'Photo attached'**
  String get statusPhotoAttached;

  /// Button to attach photo to status
  ///
  /// In en, this message translates to:
  /// **'Attach photo (optional)'**
  String get statusAttachPhoto;

  /// Validation message when status text is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter some text for your status.'**
  String get statusEnterText;

  /// Snackbar when picking a photo fails
  ///
  /// In en, this message translates to:
  /// **'Failed to pick photo: {error}'**
  String statusPickPhotoFailed(String error);

  /// Snackbar when publishing a status fails
  ///
  /// In en, this message translates to:
  /// **'Failed to publish: {error}'**
  String statusPublishFailed(String error);

  /// Title and button for panic key setup
  ///
  /// In en, this message translates to:
  /// **'Set Panic Key'**
  String get panicSetPanicKey;

  /// Subtitle for panic key dialog
  ///
  /// In en, this message translates to:
  /// **'Emergency self-destruct'**
  String get panicEmergencySelfDestruct;

  /// Warning label in panic key dialog
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible'**
  String get panicIrreversible;

  /// Warning body text in panic key dialog
  ///
  /// In en, this message translates to:
  /// **'Entering this key at the lock screen instantly wipes ALL data — messages, contacts, keys, identity. Use a key different from your regular password.'**
  String get panicWarningBody;

  /// Hint for panic key input field
  ///
  /// In en, this message translates to:
  /// **'Panic key'**
  String get panicKeyHint;

  /// Hint for panic key confirmation field
  ///
  /// In en, this message translates to:
  /// **'Confirm panic key'**
  String get panicConfirmHint;

  /// Validation: key too short
  ///
  /// In en, this message translates to:
  /// **'Panic key must be at least 8 characters'**
  String get panicMinChars;

  /// Validation: keys don't match
  ///
  /// In en, this message translates to:
  /// **'Keys do not match'**
  String get panicKeysDoNotMatch;

  /// Error shown when panic key storage fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save panic key — please try again'**
  String get panicSetFailed;

  /// Title for password setup dialog
  ///
  /// In en, this message translates to:
  /// **'Set App Password'**
  String get passwordSetAppPassword;

  /// Subtitle for password setup
  ///
  /// In en, this message translates to:
  /// **'Protects your messages at rest'**
  String get passwordProtectsMessages;

  /// Info banner in password setup
  ///
  /// In en, this message translates to:
  /// **'Required every time you open Pulse. If forgotten, your data cannot be recovered.'**
  String get passwordInfoBanner;

  /// Hint for password input
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// Hint for password confirmation
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get passwordConfirmHint;

  /// Button to set the password
  ///
  /// In en, this message translates to:
  /// **'Set Password'**
  String get passwordSetButton;

  /// Button to skip password setup
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get passwordSkipForNow;

  /// Validation: password too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinChars;

  /// Validation: passwords don't match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Snackbar shown after saving profile
  ///
  /// In en, this message translates to:
  /// **'Profile saved!'**
  String get profileCardSaved;

  /// Badge label indicating end-to-end encrypted identity
  ///
  /// In en, this message translates to:
  /// **'E2EE Identity'**
  String get profileCardE2eeIdentity;

  /// Label for display name input field
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get profileCardDisplayName;

  /// Hint for display name input field
  ///
  /// In en, this message translates to:
  /// **'e.g. Alex Smith'**
  String get profileCardDisplayNameHint;

  /// Label for about/bio input field
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileCardAbout;

  /// Button to save profile
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get profileCardSaveProfile;

  /// Placeholder shown when display name is empty
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get profileCardYourName;

  /// Snackbar when inbox address is copied
  ///
  /// In en, this message translates to:
  /// **'Address copied!'**
  String get profileCardAddressCopied;

  /// Label for single inbox address
  ///
  /// In en, this message translates to:
  /// **'Your Inbox Address'**
  String get profileCardInboxAddress;

  /// Label for multiple inbox addresses
  ///
  /// In en, this message translates to:
  /// **'Your Inbox Addresses'**
  String get profileCardInboxAddresses;

  /// Button to share all addresses
  ///
  /// In en, this message translates to:
  /// **'Share All Addresses (SmartRouter)'**
  String get profileCardShareAllAddresses;

  /// Hint text below address card
  ///
  /// In en, this message translates to:
  /// **'Share with contacts so they can message you.'**
  String get profileCardShareHint;

  /// Snackbar after copying all addresses
  ///
  /// In en, this message translates to:
  /// **'All {count} addresses copied as one link!'**
  String profileCardAllAddressesCopied(int count);

  /// Settings section label
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get settingsMyProfile;

  /// Settings section label
  ///
  /// In en, this message translates to:
  /// **'Your Inbox Address'**
  String get settingsYourInboxAddress;

  /// Settings row title
  ///
  /// In en, this message translates to:
  /// **'My QR Code'**
  String get settingsMyQrCode;

  /// Settings row subtitle
  ///
  /// In en, this message translates to:
  /// **'Share your address as a scannable QR'**
  String get settingsMyQrSubtitle;

  /// QR dialog title
  ///
  /// In en, this message translates to:
  /// **'Share My Address'**
  String get settingsShareMyAddress;

  /// Snackbar when no address available
  ///
  /// In en, this message translates to:
  /// **'No address yet — save settings first'**
  String get settingsNoAddressYet;

  /// Label in QR dialog
  ///
  /// In en, this message translates to:
  /// **'Invite Link'**
  String get settingsInviteLink;

  /// Label in QR dialog
  ///
  /// In en, this message translates to:
  /// **'Raw Address'**
  String get settingsRawAddress;

  /// Button to copy invite link
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get settingsCopyLink;

  /// Button to copy raw address
  ///
  /// In en, this message translates to:
  /// **'Copy Address'**
  String get settingsCopyAddress;

  /// Snackbar after copying invite link
  ///
  /// In en, this message translates to:
  /// **'Invite link copied'**
  String get settingsInviteLinkCopied;

  /// Settings section label
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// Settings row title
  ///
  /// In en, this message translates to:
  /// **'Theme Engine'**
  String get settingsThemeEngine;

  /// Settings row subtitle
  ///
  /// In en, this message translates to:
  /// **'Customize colors & fonts'**
  String get settingsThemeEngineSubtitle;

  /// Settings row title
  ///
  /// In en, this message translates to:
  /// **'Signal Protocol'**
  String get settingsSignalProtocol;

  /// Settings row subtitle
  ///
  /// In en, this message translates to:
  /// **'E2EE keys are stored securely'**
  String get settingsSignalProtocolSubtitle;

  /// Badge text for active protocol
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get settingsActive;

  /// Settings row and dialog title
  ///
  /// In en, this message translates to:
  /// **'Identity Backup'**
  String get settingsIdentityBackup;

  /// Settings row subtitle
  ///
  /// In en, this message translates to:
  /// **'Export or import your Signal identity'**
  String get settingsIdentityBackupSubtitle;

  /// Identity backup dialog body
  ///
  /// In en, this message translates to:
  /// **'Export your Signal identity keys to a backup code, or restore from an existing one.'**
  String get settingsIdentityBackupBody;

  /// Settings row title
  ///
  /// In en, this message translates to:
  /// **'Transfer to Another Device'**
  String get settingsTransferDevice;

  /// Settings row subtitle
  ///
  /// In en, this message translates to:
  /// **'Move your identity via LAN or Nostr relay'**
  String get settingsTransferDeviceSubtitle;

  /// Dialog title
  ///
  /// In en, this message translates to:
  /// **'Export Identity'**
  String get settingsExportIdentity;

  /// Dialog body for export
  ///
  /// In en, this message translates to:
  /// **'Copy this backup code and store it safely:'**
  String get settingsExportIdentityBody;

  /// Button to save file
  ///
  /// In en, this message translates to:
  /// **'Save File'**
  String get settingsSaveFile;

  /// Dialog title
  ///
  /// In en, this message translates to:
  /// **'Import Identity'**
  String get settingsImportIdentity;

  /// Dialog body for import
  ///
  /// In en, this message translates to:
  /// **'Paste your backup code below. This will overwrite your current identity.'**
  String get settingsImportIdentityBody;

  /// Hint for import field
  ///
  /// In en, this message translates to:
  /// **'Paste backup code here…'**
  String get settingsPasteBackupCode;

  /// Snackbar after successful import
  ///
  /// In en, this message translates to:
  /// **'Identity + contacts imported! Restart the app to apply.'**
  String get settingsIdentityImported;

  /// Settings section label
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// Settings row title
  ///
  /// In en, this message translates to:
  /// **'App Password'**
  String get settingsAppPassword;

  /// Subtitle when password is enabled
  ///
  /// In en, this message translates to:
  /// **'Enabled — required on every launch'**
  String get settingsPasswordEnabled;

  /// Subtitle when password is disabled
  ///
  /// In en, this message translates to:
  /// **'Disabled — app opens without password'**
  String get settingsPasswordDisabled;

  /// Settings row title
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePassword;

  /// Settings row subtitle
  ///
  /// In en, this message translates to:
  /// **'Update your app lock password'**
  String get settingsChangePasswordSubtitle;

  /// Settings row title
  ///
  /// In en, this message translates to:
  /// **'Set Panic Key'**
  String get settingsSetPanicKey;

  /// Settings row title
  ///
  /// In en, this message translates to:
  /// **'Change Panic Key'**
  String get settingsChangePanicKey;

  /// Subtitle when panic key is set
  ///
  /// In en, this message translates to:
  /// **'Update emergency wipe key'**
  String get settingsPanicKeySetSubtitle;

  /// Subtitle when panic key is not set
  ///
  /// In en, this message translates to:
  /// **'One key that instantly erases all data'**
  String get settingsPanicKeyUnsetSubtitle;

  /// Settings row title
  ///
  /// In en, this message translates to:
  /// **'Remove Panic Key'**
  String get settingsRemovePanicKey;

  /// Settings row subtitle
  ///
  /// In en, this message translates to:
  /// **'Disable emergency self-destruct'**
  String get settingsRemovePanicKeySubtitle;

  /// Confirmation dialog body
  ///
  /// In en, this message translates to:
  /// **'Emergency self-destruct will be disabled. You can re-enable it at any time.'**
  String get settingsRemovePanicKeyBody;

  /// Dialog title
  ///
  /// In en, this message translates to:
  /// **'Disable App Password'**
  String get settingsDisableAppPassword;

  /// Dialog subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your current password to confirm'**
  String get settingsEnterCurrentPassword;

  /// Hint for current password field
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get settingsCurrentPassword;

  /// Error when password is wrong
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get settingsIncorrectPassword;

  /// Snackbar after password change
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get settingsPasswordUpdated;

  /// Dialog subtitle for password change
  ///
  /// In en, this message translates to:
  /// **'Enter your current password to proceed'**
  String get settingsChangePasswordProceed;

  /// Settings section label
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// Settings row title
  ///
  /// In en, this message translates to:
  /// **'Backup Messages'**
  String get settingsBackupMessages;

  /// Settings row subtitle
  ///
  /// In en, this message translates to:
  /// **'Export encrypted message history to a file'**
  String get settingsBackupMessagesSubtitle;

  /// Settings row title
  ///
  /// In en, this message translates to:
  /// **'Restore Messages'**
  String get settingsRestoreMessages;

  /// Settings row subtitle
  ///
  /// In en, this message translates to:
  /// **'Import messages from a backup file'**
  String get settingsRestoreMessagesSubtitle;

  /// Settings row title
  ///
  /// In en, this message translates to:
  /// **'Export Keys'**
  String get settingsExportKeys;

  /// Settings row subtitle
  ///
  /// In en, this message translates to:
  /// **'Save identity keys to an encrypted file'**
  String get settingsExportKeysSubtitle;

  /// Settings row title
  ///
  /// In en, this message translates to:
  /// **'Import Keys'**
  String get settingsImportKeys;

  /// Settings row subtitle
  ///
  /// In en, this message translates to:
  /// **'Restore identity keys from an exported file'**
  String get settingsImportKeysSubtitle;

  /// Hint for backup password field
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get settingsBackupPassword;

  /// Validation error
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get settingsPasswordCannotBeEmpty;

  /// Validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 4 characters'**
  String get settingsPasswordMin4Chars;

  /// Settings section label
  ///
  /// In en, this message translates to:
  /// **'Calls & TURN'**
  String get settingsCallsTurn;

  /// Settings section label
  ///
  /// In en, this message translates to:
  /// **'Local Network'**
  String get settingsLocalNetwork;

  /// Settings section label
  ///
  /// In en, this message translates to:
  /// **'Censorship Resistance'**
  String get settingsCensorshipResistance;

  /// Settings section label
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get settingsNetwork;

  /// Proxy/Tor/I2P screen title
  ///
  /// In en, this message translates to:
  /// **'Proxy & Tunnels'**
  String get settingsProxyTunnels;

  /// TURN config screen title
  ///
  /// In en, this message translates to:
  /// **'TURN Servers'**
  String get settingsTurnServers;

  /// Provider screen title
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get settingsProviderTitle;

  /// Settings toggle title
  ///
  /// In en, this message translates to:
  /// **'LAN Fallback'**
  String get settingsLanFallback;

  /// Settings toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Broadcast presence and deliver messages on the local network when internet is unavailable. Disable on untrusted networks (public Wi-Fi).'**
  String get settingsLanFallbackSubtitle;

  /// Settings toggle title
  ///
  /// In en, this message translates to:
  /// **'Background Delivery'**
  String get settingsBgDelivery;

  /// Settings toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Keep receiving messages when the app is minimized. Shows a persistent notification.'**
  String get settingsBgDeliverySubtitle;

  /// Settings section label
  ///
  /// In en, this message translates to:
  /// **'Your Inbox Provider'**
  String get settingsYourInboxProvider;

  /// Settings section label
  ///
  /// In en, this message translates to:
  /// **'Connection Details'**
  String get settingsConnectionDetails;

  /// Main save button text
  ///
  /// In en, this message translates to:
  /// **'Save & Connect'**
  String get settingsSaveAndConnect;

  /// Settings section label
  ///
  /// In en, this message translates to:
  /// **'Secondary Inboxes'**
  String get settingsSecondaryInboxes;

  /// Button and dialog title
  ///
  /// In en, this message translates to:
  /// **'Add Secondary Inbox'**
  String get settingsAddSecondaryInbox;

  /// Expandable advanced section label
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get settingsAdvanced;

  /// Button to discover Waku nodes
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get settingsDiscover;

  /// Settings section label
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// Settings row title
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// Settings row subtitle
  ///
  /// In en, this message translates to:
  /// **'How Pulse protects your data'**
  String get settingsPrivacyPolicySubtitle;

  /// Settings toggle title
  ///
  /// In en, this message translates to:
  /// **'Crash reporting'**
  String get settingsCrashReporting;

  /// Settings toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Send anonymous crash reports to help improve Pulse. No message content or contacts are ever sent.'**
  String get settingsCrashReportingSubtitle;

  /// Snackbar when enabled
  ///
  /// In en, this message translates to:
  /// **'Crash reporting enabled — restart app to apply'**
  String get settingsCrashReportingEnabled;

  /// Snackbar when disabled
  ///
  /// In en, this message translates to:
  /// **'Crash reporting disabled — restart app to apply'**
  String get settingsCrashReportingDisabled;

  /// Dialog title for key export warning
  ///
  /// In en, this message translates to:
  /// **'Sensitive Operation'**
  String get settingsSensitiveOperation;

  /// Dialog body for key export warning
  ///
  /// In en, this message translates to:
  /// **'These keys are your identity. Anyone with this file can impersonate you. Store it securely and delete it after transfer.'**
  String get settingsSensitiveOperationBody;

  /// Confirmation button for sensitive operation
  ///
  /// In en, this message translates to:
  /// **'I Understand, Continue'**
  String get settingsIUnderstandContinue;

  /// Dialog title for key import
  ///
  /// In en, this message translates to:
  /// **'Replace Identity?'**
  String get settingsReplaceIdentity;

  /// Dialog body for key import
  ///
  /// In en, this message translates to:
  /// **'This will overwrite your current identity keys. Your existing Signal sessions will be invalidated and contacts will need to re-establish encryption. The app will need to restart.'**
  String get settingsReplaceIdentityBody;

  /// Button to confirm key replacement
  ///
  /// In en, this message translates to:
  /// **'Replace Keys'**
  String get settingsReplaceKeys;

  /// Dialog title after successful import
  ///
  /// In en, this message translates to:
  /// **'Keys Imported'**
  String get settingsKeysImported;

  /// Dialog body after successful import
  ///
  /// In en, this message translates to:
  /// **'{count} keys imported successfully. Please restart the app to reinitialize with the new identity.'**
  String settingsKeysImportedBody(int count);

  /// Button to restart app now
  ///
  /// In en, this message translates to:
  /// **'Restart Now'**
  String get settingsRestartNow;

  /// Button to restart later
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get settingsLater;

  /// Badge label shown for group contacts in profile sheet
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get profileGroupLabel;

  /// Button to add members to a group
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get profileAddButton;

  /// Button to kick a member from the group
  ///
  /// In en, this message translates to:
  /// **'Kick'**
  String get profileKickButton;

  /// Section divider label for Data section
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataSectionTitle;

  /// Title of backup messages dialog
  ///
  /// In en, this message translates to:
  /// **'Backup Messages'**
  String get dataBackupMessages;

  /// Subtitle in backup messages password dialog
  ///
  /// In en, this message translates to:
  /// **'Choose a password to encrypt your message backup.'**
  String get dataBackupPasswordSubtitle;

  /// Confirm button in backup messages dialog
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get dataBackupConfirmLabel;

  /// Progress dialog title when creating backup
  ///
  /// In en, this message translates to:
  /// **'Creating Backup'**
  String get dataCreatingBackup;

  /// Initial status in backup progress dialog
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get dataBackupPreparing;

  /// Progress status while exporting messages
  ///
  /// In en, this message translates to:
  /// **'Exporting message {done} of {total}...'**
  String dataBackupExporting(int done, int total);

  /// Status when saving the backup file
  ///
  /// In en, this message translates to:
  /// **'Saving file...'**
  String get dataBackupSavingFile;

  /// FilePicker dialog title for saving backup
  ///
  /// In en, this message translates to:
  /// **'Save Message Backup'**
  String get dataSaveMessageBackupDialog;

  /// Snackbar after successful backup
  ///
  /// In en, this message translates to:
  /// **'Backup saved ({count} messages)\n{path}'**
  String dataBackupSaved(int count, String path);

  /// Snackbar when backup has no data
  ///
  /// In en, this message translates to:
  /// **'Backup failed — no data exported'**
  String get dataBackupFailed;

  /// Snackbar when backup throws an error
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String dataBackupFailedError(String error);

  /// FilePicker dialog title for selecting backup
  ///
  /// In en, this message translates to:
  /// **'Select Message Backup'**
  String get dataSelectMessageBackupDialog;

  /// Snackbar when backup file is too small
  ///
  /// In en, this message translates to:
  /// **'Invalid backup file (too small)'**
  String get dataInvalidBackupFile;

  /// Snackbar when backup file magic bytes are wrong
  ///
  /// In en, this message translates to:
  /// **'Not a valid Pulse backup file'**
  String get dataNotValidBackupFile;

  /// Title of restore messages password dialog
  ///
  /// In en, this message translates to:
  /// **'Restore Messages'**
  String get dataRestoreMessages;

  /// Subtitle in restore messages password dialog
  ///
  /// In en, this message translates to:
  /// **'Enter the password used to create this backup.'**
  String get dataRestorePasswordSubtitle;

  /// Confirm button in restore dialog
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get dataRestoreConfirmLabel;

  /// Progress dialog title when restoring
  ///
  /// In en, this message translates to:
  /// **'Restoring Messages'**
  String get dataRestoringMessages;

  /// Initial status in restore progress dialog
  ///
  /// In en, this message translates to:
  /// **'Decrypting...'**
  String get dataRestoreDecrypting;

  /// Progress status while importing messages
  ///
  /// In en, this message translates to:
  /// **'Importing message {done} of {total}...'**
  String dataRestoreImporting(int done, int total);

  /// Snackbar when restore fails due to wrong password
  ///
  /// In en, this message translates to:
  /// **'Restore failed — wrong password or corrupt file'**
  String get dataRestoreFailed;

  /// Snackbar after successful restore with new messages
  ///
  /// In en, this message translates to:
  /// **'Restored {count} new messages'**
  String dataRestoreSuccess(int count);

  /// Snackbar when restore finds no new messages
  ///
  /// In en, this message translates to:
  /// **'No new messages to import (all already exist)'**
  String get dataRestoreNothingNew;

  /// Snackbar when restore throws an error
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String dataRestoreFailedError(String error);

  /// FilePicker dialog title for selecting key export
  ///
  /// In en, this message translates to:
  /// **'Select Key Export'**
  String get dataSelectKeyExportDialog;

  /// Snackbar when key file is invalid
  ///
  /// In en, this message translates to:
  /// **'Not a valid Pulse key export file'**
  String get dataNotValidKeyFile;

  /// Title of export keys password dialog
  ///
  /// In en, this message translates to:
  /// **'Export Keys'**
  String get dataExportKeys;

  /// Subtitle in export keys password dialog
  ///
  /// In en, this message translates to:
  /// **'Choose a password to encrypt your key export.'**
  String get dataExportKeysPasswordSubtitle;

  /// Confirm button in export keys dialog
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get dataExportKeysConfirmLabel;

  /// Progress dialog title when exporting keys
  ///
  /// In en, this message translates to:
  /// **'Exporting Keys'**
  String get dataExportingKeys;

  /// Initial status in export keys progress dialog
  ///
  /// In en, this message translates to:
  /// **'Encrypting identity keys...'**
  String get dataExportingKeysStatus;

  /// FilePicker dialog title for saving key export
  ///
  /// In en, this message translates to:
  /// **'Save Key Export'**
  String get dataSaveKeyExportDialog;

  /// Snackbar after successful key export
  ///
  /// In en, this message translates to:
  /// **'Keys exported to:\n{path}'**
  String dataKeysExportedTo(String path);

  /// Snackbar when key export finds no keys
  ///
  /// In en, this message translates to:
  /// **'Export failed — no keys found'**
  String get dataExportFailed;

  /// Snackbar when key export throws an error
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String dataExportFailedError(String error);

  /// Title of import keys password dialog
  ///
  /// In en, this message translates to:
  /// **'Import Keys'**
  String get dataImportKeys;

  /// Subtitle in import keys password dialog
  ///
  /// In en, this message translates to:
  /// **'Enter the password used to encrypt this key export.'**
  String get dataImportKeysPasswordSubtitle;

  /// Confirm button in import keys dialog
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get dataImportKeysConfirmLabel;

  /// Progress dialog title when importing keys
  ///
  /// In en, this message translates to:
  /// **'Importing Keys'**
  String get dataImportingKeys;

  /// Initial status in import keys progress dialog
  ///
  /// In en, this message translates to:
  /// **'Decrypting identity keys...'**
  String get dataImportingKeysStatus;

  /// Snackbar when import fails due to wrong password
  ///
  /// In en, this message translates to:
  /// **'Import failed — wrong password or corrupt file'**
  String get dataImportFailed;

  /// Snackbar when key import throws an error
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String dataImportFailedError(String error);

  /// Section divider label for Security section
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securitySectionTitle;

  /// Error shown in confirm password dialog
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get securityIncorrectPassword;

  /// Snackbar after password change
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get securityPasswordUpdated;

  /// Section divider label for Appearance section
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSectionTitle;

  /// Snackbar when identity export throws an error
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String appearanceExportFailed(String error);

  /// Snackbar after saving identity backup file
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String appearanceSavedTo(String path);

  /// Snackbar when saving identity backup file fails
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String appearanceSaveFailed(String error);

  /// Snackbar when identity import throws an error
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String appearanceImportFailed(String error);

  /// Section divider label for About section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSectionTitle;

  /// Label for public key in Nostr info card
  ///
  /// In en, this message translates to:
  /// **'Public Key'**
  String get providerPublicKey;

  /// Label for relay in Nostr info card
  ///
  /// In en, this message translates to:
  /// **'Relay'**
  String get providerRelay;

  /// Info text for Nostr auto configuration
  ///
  /// In en, this message translates to:
  /// **'Auto-configured from your recovery password. Relay auto-discovered.'**
  String get providerAutoConfigured;

  /// Info text about key storage for Nostr
  ///
  /// In en, this message translates to:
  /// **'Your key is stored locally in secure storage — never sent to any server.'**
  String get providerKeyStoredLocally;

  /// Info text for Waku auto discovery
  ///
  /// In en, this message translates to:
  /// **'Leave URL empty to auto-discover the fastest public node. Or run nwaku locally (port 8645) for maximum privacy.'**
  String get providerWakuAutoDiscovery;

  /// Tooltip on Waku discover button
  ///
  /// In en, this message translates to:
  /// **'Probe all known public nodes'**
  String get providerWakuProbeTooltip;

  /// Info text for Oxen provider
  ///
  /// In en, this message translates to:
  /// **'Oxen/Session network — onion-routed E2EE. Your Session ID is auto-generated and stored securely. Nodes auto-discovered from built-in seed nodes.'**
  String get providerOxenInfo;

  /// Expandable advanced label in provider config
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get providerAdvanced;

  /// Main save button text in provider section
  ///
  /// In en, this message translates to:
  /// **'Save & Connect'**
  String get providerSaveAndConnect;

  /// Button and dialog title for secondary inbox
  ///
  /// In en, this message translates to:
  /// **'Add Secondary Inbox'**
  String get providerAddSecondaryInbox;

  /// Section label for secondary inboxes
  ///
  /// In en, this message translates to:
  /// **'Secondary Inboxes'**
  String get providerSecondaryInboxes;

  /// Section label for inbox provider
  ///
  /// In en, this message translates to:
  /// **'Your Inbox Provider'**
  String get providerYourInboxProvider;

  /// Section label for connection details
  ///
  /// In en, this message translates to:
  /// **'Connection Details'**
  String get providerConnectionDetails;

  /// Title of the Add Contact dialog
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get addContactTitle;

  /// Label above paste area in add contact dialog
  ///
  /// In en, this message translates to:
  /// **'Invite Link or Address'**
  String get addContactInviteLinkLabel;

  /// Placeholder text in paste area
  ///
  /// In en, this message translates to:
  /// **'Tap to paste invite link'**
  String get addContactTapToPaste;

  /// Tooltip on paste button
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get addContactPasteTooltip;

  /// Status when single address is detected
  ///
  /// In en, this message translates to:
  /// **'Contact address detected'**
  String get addContactAddressDetected;

  /// Status when multiple routes are detected
  ///
  /// In en, this message translates to:
  /// **'{count} routes detected — SmartRouter picks the fastest'**
  String addContactRoutesDetected(int count);

  /// Status while fetching Nostr profile
  ///
  /// In en, this message translates to:
  /// **'Fetching profile…'**
  String get addContactFetchingProfile;

  /// Status when Nostr profile is found
  ///
  /// In en, this message translates to:
  /// **'Found: {name}'**
  String addContactProfileFound(String name);

  /// Status when no Nostr profile is found
  ///
  /// In en, this message translates to:
  /// **'No profile found'**
  String get addContactNoProfileFound;

  /// Label above name field in add contact dialog
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get addContactDisplayNameLabel;

  /// Hint text in name field
  ///
  /// In en, this message translates to:
  /// **'What do you want to call them?'**
  String get addContactDisplayNameHint;

  /// Toggle to show manual address entry
  ///
  /// In en, this message translates to:
  /// **'Add address manually'**
  String get addContactAddManually;

  /// Submit button text in add contact dialog
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get addContactButton;

  /// AppBar title for network diagnostics screen
  ///
  /// In en, this message translates to:
  /// **'Network Diagnostics'**
  String get networkDiagnosticsTitle;

  /// Card title for Nostr relays section
  ///
  /// In en, this message translates to:
  /// **'Nostr Relays'**
  String get networkDiagnosticsNostrRelays;

  /// Label for direct relay count
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get networkDiagnosticsDirect;

  /// Label for Tor-only relay count
  ///
  /// In en, this message translates to:
  /// **'Tor-only'**
  String get networkDiagnosticsTorOnly;

  /// Label for best relay
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get networkDiagnosticsBest;

  /// Fallback value when no relay/transport is active
  ///
  /// In en, this message translates to:
  /// **'none'**
  String get networkDiagnosticsNone;

  /// Card title for Tor section
  ///
  /// In en, this message translates to:
  /// **'Tor'**
  String get networkDiagnosticsTor;

  /// Label for Tor connection status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get networkDiagnosticsStatus;

  /// Tor status: connected
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get networkDiagnosticsConnected;

  /// Tor status: connecting with bootstrap percent
  ///
  /// In en, this message translates to:
  /// **'Connecting {percent}%'**
  String networkDiagnosticsConnecting(int percent);

  /// Tor status: off
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get networkDiagnosticsOff;

  /// Label for pluggable transport
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get networkDiagnosticsTransport;

  /// Card title for infrastructure section
  ///
  /// In en, this message translates to:
  /// **'Infrastructure'**
  String get networkDiagnosticsInfrastructure;

  /// Label for Oxen node count
  ///
  /// In en, this message translates to:
  /// **'Oxen nodes'**
  String get networkDiagnosticsOxenNodes;

  /// Label for TURN server count
  ///
  /// In en, this message translates to:
  /// **'TURN servers'**
  String get networkDiagnosticsTurnServers;

  /// Label for last probe timestamp
  ///
  /// In en, this message translates to:
  /// **'Last probe'**
  String get networkDiagnosticsLastProbe;

  /// Button label while diagnostics are running
  ///
  /// In en, this message translates to:
  /// **'Running...'**
  String get networkDiagnosticsRunning;

  /// Button to run network diagnostics
  ///
  /// In en, this message translates to:
  /// **'Run Diagnostics'**
  String get networkDiagnosticsRunDiagnostics;

  /// Button to force a full relay re-probe
  ///
  /// In en, this message translates to:
  /// **'Force Full Re-probe'**
  String get networkDiagnosticsForceReprobe;

  /// Age label when probe was just completed
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get networkDiagnosticsJustNow;

  /// Age label in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String networkDiagnosticsMinutesAgo(int minutes);

  /// Age label in hours
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String networkDiagnosticsHoursAgo(int hours);

  /// Age label in days
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String networkDiagnosticsDaysAgo(int days);

  /// Chip label when uTLS proxy is unavailable (ECH disabled)
  ///
  /// In en, this message translates to:
  /// **'No ECH'**
  String get homeNoEch;

  /// Tooltip for the No ECH chip
  ///
  /// In en, this message translates to:
  /// **'uTLS proxy unavailable — ECH disabled.\nTLS fingerprint is visible to DPI.'**
  String get homeNoEchTooltip;

  /// AppBar title for the settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Snackbar after saving settings and connecting
  ///
  /// In en, this message translates to:
  /// **'Saved & connected to {provider}'**
  String settingsSavedConnectedTo(String provider);

  /// Snackbar when bundled Tor fails to start
  ///
  /// In en, this message translates to:
  /// **'Built-in Tor failed to start'**
  String get settingsTorFailedToStart;

  /// Snackbar when Psiphon fails to start
  ///
  /// In en, this message translates to:
  /// **'Psiphon failed to start'**
  String get settingsPsiphonFailedToStart;

  /// AppBar title for verify identity screen
  ///
  /// In en, this message translates to:
  /// **'Verify Safety Number'**
  String get verifyTitle;

  /// Status label when identity is verified
  ///
  /// In en, this message translates to:
  /// **'Identity Verified'**
  String get verifyIdentityVerified;

  /// Status label when identity is not yet verified
  ///
  /// In en, this message translates to:
  /// **'Not Yet Verified'**
  String get verifyNotYetVerified;

  /// Description shown when identity is verified
  ///
  /// In en, this message translates to:
  /// **'You have verified {name}\'s safety number.'**
  String verifyVerifiedDescription(String name);

  /// Description shown when identity is not yet verified
  ///
  /// In en, this message translates to:
  /// **'Compare these numbers with {name} in person or over a trusted channel.'**
  String verifyUnverifiedDescription(String name);

  /// Explanation paragraph on verify identity screen
  ///
  /// In en, this message translates to:
  /// **'Each conversation has a unique safety number. If both of you see the same numbers on your devices, your connection is verified end-to-end.'**
  String get verifyExplanation;

  /// Label for contact's fingerprint card
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Key'**
  String verifyContactKey(String name);

  /// Label for own fingerprint card on verify screen
  ///
  /// In en, this message translates to:
  /// **'Your Key'**
  String get verifyYourKey;

  /// Button to remove identity verification on verify screen
  ///
  /// In en, this message translates to:
  /// **'Remove Verification'**
  String get verifyRemoveVerification;

  /// Button to mark identity as verified on verify screen
  ///
  /// In en, this message translates to:
  /// **'Mark as Verified'**
  String get verifyMarkAsVerified;

  /// Hint shown after verifying, warning about reinstall
  ///
  /// In en, this message translates to:
  /// **'If {name} reinstalls the app, the safety number will change and verification will be removed automatically.'**
  String verifyAfterReinstall(String name);

  /// Hint shown before verifying, instruction to compare
  ///
  /// In en, this message translates to:
  /// **'Only mark as verified after comparing numbers with {name} over a voice call or in person.'**
  String verifyOnlyMarkAfterCompare(String name);

  /// Shown when no Signal session exists on verify screen
  ///
  /// In en, this message translates to:
  /// **'No encryption session established yet. Send a message first to generate safety numbers.'**
  String get verifyNoSession;

  /// Shown in fingerprint card when key is absent
  ///
  /// In en, this message translates to:
  /// **'No key available'**
  String get verifyNoKeyAvailable;

  /// Snackbar when a fingerprint is copied
  ///
  /// In en, this message translates to:
  /// **'{label} fingerprint copied'**
  String verifyFingerprintCopied(String label);

  /// Label for Firebase database URL field
  ///
  /// In en, this message translates to:
  /// **'Database URL'**
  String get providerDatabaseUrlLabel;

  /// Hint for optional fields
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get providerOptionalHint;

  /// Label for Firebase web API key field
  ///
  /// In en, this message translates to:
  /// **'Web API Key'**
  String get providerWebApiKeyLabel;

  /// Hint for optional Firebase API key field
  ///
  /// In en, this message translates to:
  /// **'Optional for public DB'**
  String get providerOptionalForPublicDb;

  /// Label for Nostr relay URL field in provider config
  ///
  /// In en, this message translates to:
  /// **'Relay URL'**
  String get providerRelayUrlLabel;

  /// Label for Nostr private key field
  ///
  /// In en, this message translates to:
  /// **'Private Key'**
  String get providerPrivateKeyLabel;

  /// Label for Nostr private key (nsec) field in advanced config
  ///
  /// In en, this message translates to:
  /// **'Private Key (nsec)'**
  String get providerPrivateKeyNsecLabel;

  /// Label for Waku node URL field
  ///
  /// In en, this message translates to:
  /// **'nwaku Node URL (optional)'**
  String get providerWakuUrlLabel;

  /// Hint for Waku node URL field
  ///
  /// In en, this message translates to:
  /// **'Leave empty for auto-discovery'**
  String get providerWakuUrlHint;

  /// Label for Oxen storage node URL field
  ///
  /// In en, this message translates to:
  /// **'Storage Node URL (optional)'**
  String get providerStorageNodeLabel;

  /// Hint for Oxen storage node URL field
  ///
  /// In en, this message translates to:
  /// **'Leave empty for built-in seed nodes'**
  String get providerStorageNodeHint;

  /// Error when transfer code format is not recognised
  ///
  /// In en, this message translates to:
  /// **'Unrecognised code format — must start with LAN: or NOS:'**
  String get transferInvalidCodeFormat;

  /// Snackbar shown after copying E2EE fingerprint
  ///
  /// In en, this message translates to:
  /// **'Fingerprint copied'**
  String get profileCardFingerprintCopied;

  /// Hint for about/bio input field
  ///
  /// In en, this message translates to:
  /// **'Privacy first 🔒'**
  String get profileCardAboutHint;

  /// Save button label on profile card
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get profileCardSaveButton;

  /// Updated backup subtitle mentioning contacts and avatars
  ///
  /// In en, this message translates to:
  /// **'Export encrypted messages, contacts and avatars to a file'**
  String get settingsBackupMessagesSubtitleV2;

  /// Label for video call type
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get callVideo;

  /// Label for audio call type
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get callAudio;

  /// Shows delivery status to named members
  ///
  /// In en, this message translates to:
  /// **'Delivered to {names}'**
  String bubbleDeliveredTo(String names);

  /// Shows delivery status to N members
  ///
  /// In en, this message translates to:
  /// **'Delivered to {count}'**
  String bubbleDeliveredToCount(int count);

  /// Title for per-member delivery/read status dialog
  ///
  /// In en, this message translates to:
  /// **'Message Info'**
  String get groupStatusDialogTitle;

  /// Section header for members who read the message
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get groupStatusRead;

  /// Section header for members who received but haven't read
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get groupStatusDelivered;

  /// Section header for members who haven't received the message
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get groupStatusPending;

  /// Shown when no delivery data is available
  ///
  /// In en, this message translates to:
  /// **'No delivery information yet'**
  String get groupStatusNoData;

  /// Button label to transfer admin role to a member
  ///
  /// In en, this message translates to:
  /// **'Make Admin'**
  String get profileTransferAdmin;

  /// Confirmation question for admin transfer
  ///
  /// In en, this message translates to:
  /// **'Make {name} the new admin?'**
  String profileTransferAdminConfirm(String name);

  /// Warning in admin transfer confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'You will lose admin privileges. This cannot be undone.'**
  String get profileTransferAdminBody;

  /// Snackbar shown after successful admin transfer
  ///
  /// In en, this message translates to:
  /// **'{name} is now the admin'**
  String profileTransferAdminDone(String name);

  /// Badge shown on the current group admin's tile
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get profileAdminBadge;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyOverviewHeading.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get privacyOverviewHeading;

  /// No description provided for @privacyOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'Pulse is a serverless, end-to-end encrypted messenger. Your privacy is not just a feature — it is the architecture. There are no Pulse servers. No accounts are stored anywhere. No data is collected, transmitted to, or stored by the developers.'**
  String get privacyOverviewBody;

  /// No description provided for @privacyDataCollectionHeading.
  ///
  /// In en, this message translates to:
  /// **'Data Collection'**
  String get privacyDataCollectionHeading;

  /// No description provided for @privacyDataCollectionBody.
  ///
  /// In en, this message translates to:
  /// **'Pulse collects zero personal data. Specifically:\n\n- No email, phone number, or real name is required\n- No analytics, tracking, or telemetry\n- No advertising identifiers\n- No contact list access\n- No cloud backups (messages exist only on your device)\n- No metadata is sent to any Pulse server (there are none)'**
  String get privacyDataCollectionBody;

  /// No description provided for @privacyEncryptionHeading.
  ///
  /// In en, this message translates to:
  /// **'Encryption'**
  String get privacyEncryptionHeading;

  /// No description provided for @privacyEncryptionBody.
  ///
  /// In en, this message translates to:
  /// **'All messages are encrypted using the Signal Protocol (Double Ratchet with X3DH key agreement). Encryption keys are generated and stored exclusively on your device. No one — including the developers — can read your messages.'**
  String get privacyEncryptionBody;

  /// No description provided for @privacyNetworkHeading.
  ///
  /// In en, this message translates to:
  /// **'Network Architecture'**
  String get privacyNetworkHeading;

  /// No description provided for @privacyNetworkBody.
  ///
  /// In en, this message translates to:
  /// **'Pulse uses federated transport adapters (Nostr relays, Session/Oxen service nodes, Waku nodes, Firebase Realtime Database, LAN). These transports carry only encrypted ciphertext. Relay operators can see your IP address and traffic volume, but cannot decrypt message content.\n\nWhen Tor is enabled, your IP address is also hidden from relay operators.'**
  String get privacyNetworkBody;

  /// No description provided for @privacyStunHeading.
  ///
  /// In en, this message translates to:
  /// **'STUN/TURN Servers'**
  String get privacyStunHeading;

  /// No description provided for @privacyStunBody.
  ///
  /// In en, this message translates to:
  /// **'Voice and video calls use WebRTC with DTLS-SRTP encryption. STUN servers (used to discover your public IP for peer-to-peer connections) and TURN servers (used to relay media when direct connection fails) can see your IP address and call duration, but cannot decrypt call content.\n\nYou can configure your own TURN server in Settings for maximum privacy.'**
  String get privacyStunBody;

  /// No description provided for @privacyCrashHeading.
  ///
  /// In en, this message translates to:
  /// **'Crash Reporting'**
  String get privacyCrashHeading;

  /// No description provided for @privacyCrashBody.
  ///
  /// In en, this message translates to:
  /// **'If Sentry crash reporting is enabled (via build-time SENTRY_DSN), anonymous crash reports may be sent. These contain no message content, no contact information, and no personally identifiable information. Crash reporting can be disabled at build time by omitting the DSN.'**
  String get privacyCrashBody;

  /// No description provided for @privacyPasswordHeading.
  ///
  /// In en, this message translates to:
  /// **'Password & Keys'**
  String get privacyPasswordHeading;

  /// No description provided for @privacyPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Your recovery password is used to derive cryptographic keys via Argon2id (memory-hard KDF). The password is never transmitted anywhere. If you lose your password, your account cannot be recovered — there is no server to reset it.'**
  String get privacyPasswordBody;

  /// No description provided for @privacyFontsHeading.
  ///
  /// In en, this message translates to:
  /// **'Fonts'**
  String get privacyFontsHeading;

  /// No description provided for @privacyFontsBody.
  ///
  /// In en, this message translates to:
  /// **'Pulse bundles all fonts locally. No requests are made to Google Fonts or any external font service.'**
  String get privacyFontsBody;

  /// No description provided for @privacyThirdPartyHeading.
  ///
  /// In en, this message translates to:
  /// **'Third-Party Services'**
  String get privacyThirdPartyHeading;

  /// No description provided for @privacyThirdPartyBody.
  ///
  /// In en, this message translates to:
  /// **'Pulse does not integrate with any advertising networks, analytics providers, social media platforms, or data brokers. The only network connections are to the transport relays you configure.'**
  String get privacyThirdPartyBody;

  /// No description provided for @privacyOpenSourceHeading.
  ///
  /// In en, this message translates to:
  /// **'Open Source'**
  String get privacyOpenSourceHeading;

  /// No description provided for @privacyOpenSourceBody.
  ///
  /// In en, this message translates to:
  /// **'Pulse is open-source software. You can audit the complete source code to verify these privacy claims.'**
  String get privacyOpenSourceBody;

  /// No description provided for @privacyContactHeading.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get privacyContactHeading;

  /// No description provided for @privacyContactBody.
  ///
  /// In en, this message translates to:
  /// **'For privacy-related questions, open an issue on the project repository.'**
  String get privacyContactBody;

  /// No description provided for @privacyLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: March 2026'**
  String get privacyLastUpdated;

  /// No description provided for @imageSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String imageSaveFailed(Object error);

  /// No description provided for @themeEngineTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Engine'**
  String get themeEngineTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
