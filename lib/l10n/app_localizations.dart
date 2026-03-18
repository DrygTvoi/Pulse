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

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;
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
