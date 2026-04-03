// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Khmer Central Khmer (`km`).
class AppLocalizationsKm extends AppLocalizations {
  AppLocalizationsKm([String locale = 'km']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'ស្វែងរកសារ...';

  @override
  String get search => 'ស្វែងរក';

  @override
  String get clearSearch => 'សម្អាតការស្វែងរក';

  @override
  String get closeSearch => 'បិទការស្វែងរក';

  @override
  String get moreOptions => 'ជម្រើសបន្ថែម';

  @override
  String get back => 'ថយក្រោយ';

  @override
  String get cancel => 'បោះបង់';

  @override
  String get close => 'បិទ';

  @override
  String get confirm => 'បញ្ជាក់';

  @override
  String get remove => 'លុបចេញ';

  @override
  String get save => 'រក្សាទុក';

  @override
  String get add => 'បន្ថែម';

  @override
  String get copy => 'ចម្លង';

  @override
  String get skip => 'រំលង';

  @override
  String get done => 'រួចរាល់';

  @override
  String get apply => 'អនុវត្ត';

  @override
  String get export => 'នាំចេញ';

  @override
  String get import => 'នាំចូល';

  @override
  String get homeNewGroup => 'ក្រុមថ្មី';

  @override
  String get homeSettings => 'ការកំណត់';

  @override
  String get homeSearching => 'កំពុងស្វែងរកសារ...';

  @override
  String get homeNoResults => 'រកមិនឃើញលទ្ធផល';

  @override
  String get homeNoChatHistory => 'មិនទាន់មានប្រវត្តិជជែក';

  @override
  String homeTransportSwitched(String address) {
    return 'ប្តូរផ្លូវដឹកជញ្ជូន → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name កំពុងហៅ...';
  }

  @override
  String get homeAccept => 'ទទួល';

  @override
  String get homeDecline => 'បដិសេធ';

  @override
  String get homeLoadEarlier => 'ផ្ទុកសារមុនៗ';

  @override
  String get homeChats => 'ជជែក';

  @override
  String get homeSelectConversation => 'ជ្រើសរើសការសន្ទនា';

  @override
  String get homeNoChatsYet => 'មិនទាន់មានការជជែក';

  @override
  String get homeAddContactToStart => 'បន្ថែមទំនាក់ទំនងដើម្បីចាប់ផ្តើមជជែក';

  @override
  String get homeNewChat => 'ជជែកថ្មី';

  @override
  String get homeNewChatTooltip => 'ជជែកថ្មី';

  @override
  String get homeIncomingCallTitle => 'ការហៅចូល';

  @override
  String get homeIncomingGroupCallTitle => 'ការហៅក្រុមចូល';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — ការហៅក្រុមចូល';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'គ្មានការជជែកត្រូវនឹង \"$query\"';
  }

  @override
  String get homeSectionChats => 'ជជែក';

  @override
  String get homeSectionMessages => 'សារ';

  @override
  String get homeDbEncryptionUnavailable =>
      'ការអ៊ិនគ្រីបមូលដ្ឋានទិន្នន័យមិនអាចប្រើបាន — ដំឡើង SQLCipher ដើម្បីការពារពេញលេញ';

  @override
  String get chatFileTooLargeGroup =>
      'ឯកសារលើសពី 512 KB មិនអាចប្រើក្នុងជជែកក្រុមបានទេ';

  @override
  String get chatLargeFile => 'ឯកសារធំ';

  @override
  String get chatCancel => 'បោះបង់';

  @override
  String get chatSend => 'ផ្ញើ';

  @override
  String get chatFileTooLarge => 'ឯកសារធំពេក — ទំហំអតិបរមា 100 MB';

  @override
  String get chatMicDenied => 'ការអនុញ្ញាតមីក្រូហ្វូនត្រូវបានបដិសេធ';

  @override
  String get chatVoiceFailed =>
      'មិនអាចរក្សាទុកសារសម្លេងបាន — សូមពិនិត្យទំហំផ្ទុកដែលមាន';

  @override
  String get chatScheduleFuture => 'ពេលវេលាកំណត់ត្រូវតែនៅអនាគត';

  @override
  String get chatToday => 'ថ្ងៃនេះ';

  @override
  String get chatYesterday => 'ម្សិលមិញ';

  @override
  String get chatEdited => 'បានកែសម្រួល';

  @override
  String get chatYou => 'អ្នក';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'ឯកសារនេះមានទំហំ $size MB។ ការផ្ញើឯកសារធំអាចយឺតលើបណ្តាញមួយចំនួន។ បន្ត?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'សោសុវត្ថិភាពរបស់ $name បានផ្លាស់ប្តូរ។ ចុចដើម្បីផ្ទៀងផ្ទាត់។';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'មិនអាចអ៊ិនគ្រីបសារទៅ $name បាន — សារមិនត្រូវបានផ្ញើ។';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'លេខសុវត្ថិភាពបានផ្លាស់ប្តូរសម្រាប់ $name។ ចុចដើម្បីផ្ទៀងផ្ទាត់។';
  }

  @override
  String get chatNoMessagesFound => 'រកមិនឃើញសារ';

  @override
  String get chatMessagesE2ee => 'សារត្រូវបានអ៊ិនគ្រីបពីចុងដល់ចុង';

  @override
  String get chatSayHello => 'សួស្តី';

  @override
  String get appBarOnline => 'អនឡាញ';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'កំពុងវាយ';

  @override
  String get appBarSearchMessages => 'ស្វែងរកសារ...';

  @override
  String get appBarMute => 'បិទសម្លេង';

  @override
  String get appBarUnmute => 'បើកសម្លេង';

  @override
  String get appBarMedia => 'មេឌៀ';

  @override
  String get appBarDisappearing => 'សារបាត់ខ្លួន';

  @override
  String get appBarDisappearingOn => 'បាត់ខ្លួន: បើក';

  @override
  String get appBarGroupSettings => 'ការកំណត់ក្រុម';

  @override
  String get appBarSearchTooltip => 'ស្វែងរកសារ';

  @override
  String get appBarVoiceCall => 'ហៅសម្លេង';

  @override
  String get appBarVideoCall => 'ហៅវីដេអូ';

  @override
  String get inputMessage => 'សារ...';

  @override
  String get inputAttachFile => 'ភ្ជាប់ឯកសារ';

  @override
  String get inputSendMessage => 'ផ្ញើសារ';

  @override
  String get inputRecordVoice => 'ថតសារសម្លេង';

  @override
  String get inputSendVoice => 'ផ្ញើសារសម្លេង';

  @override
  String get inputCancelReply => 'បោះបង់ការឆ្លើយ';

  @override
  String get inputCancelEdit => 'បោះបង់ការកែសម្រួល';

  @override
  String get inputCancelRecording => 'បោះបង់ការថត';

  @override
  String get inputRecording => 'កំពុងថត…';

  @override
  String get inputEditingMessage => 'កំពុងកែសម្រួលសារ';

  @override
  String get inputPhoto => 'រូបថត';

  @override
  String get inputVoiceMessage => 'សារសម្លេង';

  @override
  String get inputFile => 'ឯកសារ';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count សារដែលបានកំណត់ពេល$_temp0';
  }

  @override
  String get callInitializing => 'កំពុងចាប់ផ្តើមការហៅ…';

  @override
  String get callConnecting => 'កំពុងតភ្ជាប់…';

  @override
  String get callConnectingRelay => 'កំពុងតភ្ជាប់ (relay)…';

  @override
  String get callSwitchingRelay => 'កំពុងប្តូរទៅរបៀប relay…';

  @override
  String get callConnectionFailed => 'ការតភ្ជាប់បានបរាជ័យ';

  @override
  String get callReconnecting => 'កំពុងតភ្ជាប់ឡើងវិញ…';

  @override
  String get callEnded => 'ការហៅបានបញ្ចប់';

  @override
  String get callLive => 'ផ្ទាល់';

  @override
  String get callEnd => 'ចប់';

  @override
  String get callEndCall => 'បញ្ចប់ការហៅ';

  @override
  String get callMute => 'បិទសម្លេង';

  @override
  String get callUnmute => 'បើកសម្លេង';

  @override
  String get callSpeaker => 'អូប៉ាល័រ';

  @override
  String get callCameraOn => 'បើកកាមេរ៉ា';

  @override
  String get callCameraOff => 'បិទកាមេរ៉ា';

  @override
  String get callShareScreen => 'ចែករំលែកអេក្រង់';

  @override
  String get callStopShare => 'បញ្ឈប់ការចែករំលែក';

  @override
  String callTorBackup(String duration) {
    return 'Tor បម្រុង · $duration';
  }

  @override
  String get callTorBackupBanner => 'Tor បម្រុងសកម្ម — ផ្លូវចម្បងមិនអាចប្រើបាន';

  @override
  String get callDirectFailed =>
      'ការតភ្ជាប់ផ្ទាល់បានបរាជ័យ — កំពុងប្តូរទៅរបៀប relay…';

  @override
  String get callTurnUnreachable =>
      'មិនអាចភ្ជាប់ TURN servers បាន។ បន្ថែម TURN ផ្ទាល់ខ្លួនក្នុងការកំណត់ → កម្រិតខ្ពស់។';

  @override
  String get callRelayMode => 'របៀប relay សកម្ម (បណ្តាញដែលត្រូវបានដាក់កម្រិត)';

  @override
  String get callStarting => 'កំពុងចាប់ផ្តើមការហៅ…';

  @override
  String get callConnectingToGroup => 'កំពុងតភ្ជាប់ទៅក្រុម…';

  @override
  String get callGroupOpenedInBrowser => 'ការហៅក្រុមបានបើកក្នុងកម្មវិធីរុករក';

  @override
  String get callCouldNotOpenBrowser => 'មិនអាចបើកកម្មវិធីរុករកបាន';

  @override
  String get callInviteLinkSent => 'តំណអញ្ជើញត្រូវបានផ្ញើទៅសមាជិកក្រុមទាំងអស់។';

  @override
  String get callOpenLinkManually =>
      'បើកតំណខាងលើដោយដៃ ឬចុចដើម្បីព្យាយាមម្តងទៀត។';

  @override
  String get callJitsiNotE2ee =>
      'ការហៅ Jitsi មិនត្រូវបានអ៊ិនគ្រីបពីចុងដល់ចុងទេ';

  @override
  String get callRetryOpenBrowser => 'ព្យាយាមបើកកម្មវិធីរុករកម្តងទៀត';

  @override
  String get callClose => 'បិទ';

  @override
  String get callCamOn => 'បើកកាមេរ៉ា';

  @override
  String get callCamOff => 'បិទកាមេរ៉ា';

  @override
  String get noConnection => 'គ្មានការតភ្ជាប់ — សារនឹងត្រូវបានដាក់ជាជួរ';

  @override
  String get connected => 'បានតភ្ជាប់';

  @override
  String get connecting => 'កំពុងតភ្ជាប់…';

  @override
  String get disconnected => 'បានផ្តាច់';

  @override
  String get offlineBanner =>
      'គ្មានការតភ្ជាប់ — សារនឹងត្រូវបានផ្ញើនៅពេលភ្ជាប់អ៊ីនធឺណិតវិញ';

  @override
  String get lanModeBanner =>
      'របៀប LAN — គ្មានអ៊ីនធឺណិត · បណ្តាញមូលដ្ឋានប៉ុណ្ណោះ';

  @override
  String get probeCheckingNetwork => 'កំពុងពិនិត្យការតភ្ជាប់បណ្តាញ…';

  @override
  String get probeDiscoveringRelays => 'កំពុងស្វែងរក relays តាមរយៈថតសហគមន៍…';

  @override
  String get probeStartingTor => 'កំពុងចាប់ផ្តើម Tor សម្រាប់ bootstrap…';

  @override
  String get probeFindingRelaysTor =>
      'កំពុងស្វែងរក relays ដែលអាចភ្ជាប់បានតាមរយៈ Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'បណ្តាញរួចរាល់ — រកឃើញ $count relay$_temp0';
  }

  @override
  String get probeNoRelaysFound =>
      'រកមិនឃើញ relays ដែលអាចភ្ជាប់បាន — សារអាចមានការពន្យឺត';

  @override
  String get jitsiWarningTitle => 'មិនត្រូវបានអ៊ិនគ្រីបពីចុងដល់ចុង';

  @override
  String get jitsiWarningBody =>
      'ការហៅ Jitsi Meet មិនត្រូវបានអ៊ិនគ្រីបដោយ Pulse ទេ។ ប្រើសម្រាប់ការសន្ទនាមិនសម្ងាត់ប៉ុណ្ណោះ។';

  @override
  String get jitsiConfirm => 'ចូលរួមទោះបីជាយ៉ាងណា';

  @override
  String get jitsiGroupWarningTitle => 'មិនត្រូវបានអ៊ិនគ្រីបពីចុងដល់ចុង';

  @override
  String get jitsiGroupWarningBody =>
      'ការហៅនេះមានអ្នកចូលរួមច្រើនពេកសម្រាប់ mesh អ៊ិនគ្រីបដែលមានស្រាប់។\n\nតំណ Jitsi Meet នឹងត្រូវបានបើកក្នុងកម្មវិធីរុករករបស់អ្នក។ Jitsi មិនអ៊ិនគ្រីបពីចុងដល់ចុងទេ — ម៉ាស៊ីនមេអាចមើលឃើញការហៅរបស់អ្នក។';

  @override
  String get jitsiContinueAnyway => 'បន្តទោះបីជាយ៉ាងណា';

  @override
  String get retry => 'ព្យាយាមម្តងទៀត';

  @override
  String get setupCreateAnonymousAccount => 'បង្កើតគណនីអនាមិក';

  @override
  String get setupTapToChangeColor => 'ចុចដើម្បីប្តូរពណ៌';

  @override
  String get setupReqMinLength => 'យ៉ាងហោចណាស់ 16 តួអក្សរ';

  @override
  String get setupReqVariety =>
      '3 ក្នុងចំណោម 4: អក្សរធំ តូច លេខ និងនិមិត្តសញ្ញា';

  @override
  String get setupReqMatch => 'ពាក្យសម្ងាត់ត្រូវគ្នា';

  @override
  String get setupYourNickname => 'ឈ្មោះហៅក្រៅរបស់អ្នក';

  @override
  String get setupRecoveryPassword => 'ពាក្យសម្ងាត់សង្គ្រោះ (អប្បបរមា 16)';

  @override
  String get setupConfirmPassword => 'បញ្ជាក់ពាក្យសម្ងាត់';

  @override
  String get setupMin16Chars => 'អប្បបរមា 16 តួអក្សរ';

  @override
  String get setupPasswordsDoNotMatch => 'ពាក្យសម្ងាត់មិនត្រូវគ្នា';

  @override
  String get setupEntropyWeak => 'ខ្សោយ';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'រឹងមាំ';

  @override
  String get setupEntropyWeakNeedsVariety => 'ខ្សោយ (ត្រូវការ 3 ប្រភេទតួអក្សរ)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bits)';
  }

  @override
  String get setupPasswordWarning =>
      'ពាក្យសម្ងាត់នេះជាមធ្យោបាយតែមួយគត់ដើម្បីស្ដារគណនីរបស់អ្នក។ គ្មានម៉ាស៊ីនមេ — គ្មានការកំណត់ពាក្យសម្ងាត់ឡើងវិញ។ ចងចាំវា ឬសរសេរវាចុះ។';

  @override
  String get setupCreateAccount => 'បង្កើតគណនី';

  @override
  String get setupAlreadyHaveAccount => 'មានគណនីរួចហើយ? ';

  @override
  String get setupRestore => 'ស្ដារ →';

  @override
  String get restoreTitle => 'ស្ដារគណនី';

  @override
  String get restoreInfoBanner =>
      'បញ្ចូលពាក្យសម្ងាត់សង្គ្រោះរបស់អ្នក — អាសយដ្ឋានរបស់អ្នក (Nostr + Session) នឹងត្រូវបានស្ដារដោយស្វ័យប្រវត្តិ។ ទំនាក់ទំនង និងសារត្រូវបានរក្សាទុកក្នុងម៉ាស៊ីនប៉ុណ្ណោះ។';

  @override
  String get restoreNewNickname => 'ឈ្មោះហៅក្រៅថ្មី (អាចផ្លាស់ប្តូរពេលក្រោយ)';

  @override
  String get restoreButton => 'ស្ដារគណនី';

  @override
  String get lockTitle => 'Pulse ត្រូវបានចាក់សោ';

  @override
  String get lockSubtitle => 'បញ្ចូលពាក្យសម្ងាត់របស់អ្នកដើម្បីបន្ត';

  @override
  String get lockPasswordHint => 'ពាក្យសម្ងាត់';

  @override
  String get lockUnlock => 'ដោះសោ';

  @override
  String get lockPanicHint =>
      'ភ្លេចពាក្យសម្ងាត់? បញ្ចូលសោបន្ទាន់របស់អ្នកដើម្បីលុបទិន្នន័យទាំងអស់។';

  @override
  String get lockTooManyAttempts => 'ព្យាយាមច្រើនពេក។ កំពុងលុបទិន្នន័យទាំងអស់…';

  @override
  String get lockWrongPassword => 'ពាក្យសម្ងាត់មិនត្រឹមត្រូវ';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'ពាក្យសម្ងាត់មិនត្រឹមត្រូវ — $attempts/$max ការព្យាយាម';
  }

  @override
  String get onboardingSkip => 'រំលង';

  @override
  String get onboardingNext => 'បន្ទាប់';

  @override
  String get onboardingGetStarted => 'ចាប់ផ្តើម';

  @override
  String get onboardingWelcomeTitle => 'សូមស្វាគមន៍មកកាន់ Pulse';

  @override
  String get onboardingWelcomeBody =>
      'កម្មវិធីផ្ញើសារអ៊ិនគ្រីបពីចុងដល់ចុងដែលវិមជ្ឈការ។\n\nគ្មានម៉ាស៊ីនមេកណ្តាល។ គ្មានការប្រមូលទិន្នន័យ។ គ្មានទ្វារក្រោយ។\nការសន្ទនារបស់អ្នកជាកម្មសិទ្ធិរបស់អ្នកតែម្នាក់។';

  @override
  String get onboardingTransportTitle => 'មិនជាប់នឹងការដឹកជញ្ជូន';

  @override
  String get onboardingTransportBody =>
      'ប្រើ Firebase, Nostr ឬទាំងពីរក្នុងពេលតែមួយ។\n\nសារត្រូវបានបញ្ជូនឆ្លងកាត់បណ្តាញដោយស្វ័យប្រវត្តិ។ ការគាំទ្រ Tor និង I2P ដែលមានស្រាប់សម្រាប់ការប្រឆាំងការត្រួតពិនិត្យ។';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'រាល់សារត្រូវបានអ៊ិនគ្រីបដោយ Signal Protocol (Double Ratchet + X3DH) សម្រាប់ forward secrecy។\n\nបន្ថែមទៀតដោយរុំជាមួយ Kyber-1024 — ក្បួនដោះស្រាយ post-quantum ស្តង់ដារ NIST — ការពារប្រឆាំងនឹងកុំព្យូទ័រក្វាន់ទុមនាពេលអនាគត។';

  @override
  String get onboardingKeysTitle => 'សោរបស់អ្នក ជារបស់អ្នក';

  @override
  String get onboardingKeysBody =>
      'សោអត្តសញ្ញាណរបស់អ្នកមិនដែលចេញពីឧបករណ៍របស់អ្នកទេ។\n\nស្នាមម្រាមដៃ Signal អនុញ្ញាតឱ្យអ្នកផ្ទៀងផ្ទាត់ទំនាក់ទំនងក្រៅផ្លូវ។ TOFU (Trust On First Use) រកឃើញការផ្លាស់ប្តូរសោដោយស្វ័យប្រវត្តិ។';

  @override
  String get onboardingThemeTitle => 'ជ្រើសរើសរចនាប័ទ្មរបស់អ្នក';

  @override
  String get onboardingThemeBody =>
      'ជ្រើសរើសធីម និងពណ៌បន្លិច។ អ្នកអាចផ្លាស់ប្តូរនេះនៅពេលណាក៏បានក្នុងការកំណត់។';

  @override
  String get contactsNewChat => 'ជជែកថ្មី';

  @override
  String get contactsAddContact => 'បន្ថែមទំនាក់ទំនង';

  @override
  String get contactsSearchHint => 'ស្វែងរក...';

  @override
  String get contactsNewGroup => 'ក្រុមថ្មី';

  @override
  String get contactsNoContactsYet => 'មិនទាន់មានទំនាក់ទំនង';

  @override
  String get contactsAddHint => 'ចុច + ដើម្បីបន្ថែមអាសយដ្ឋានរបស់នរណាម្នាក់';

  @override
  String get contactsNoMatch => 'គ្មានទំនាក់ទំនងដែលត្រូវគ្នា';

  @override
  String get contactsRemoveTitle => 'លុបទំនាក់ទំនង';

  @override
  String contactsRemoveMessage(String name) {
    return 'លុប $name?';
  }

  @override
  String get contactsRemove => 'លុបចេញ';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count ទំនាក់ទំនង$_temp0';
  }

  @override
  String get bubbleOpenLink => 'បើកតំណ';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'បើក URL នេះក្នុងកម្មវិធីរុករករបស់អ្នក?\n\n$url';
  }

  @override
  String get bubbleOpen => 'បើក';

  @override
  String get bubbleSecurityWarning => 'ការព្រមានសុវត្ថិភាព';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" ជាប្រភេទឯកសារដែលអាចដំណើរការបាន។ ការរក្សាទុក និងដំណើរការវាអាចបង្កគ្រោះថ្នាក់ដល់ឧបករណ៍របស់អ្នក។ រក្សាទុកទោះបីជាយ៉ាងណា?';
  }

  @override
  String get bubbleSaveAnyway => 'រក្សាទុកទោះបីជាយ៉ាងណា';

  @override
  String bubbleSavedTo(String path) {
    return 'បានរក្សាទុកនៅ $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'ការរក្សាទុកបានបរាជ័យ: $error';
  }

  @override
  String get bubbleNotEncrypted => 'មិនត្រូវបានអ៊ិនគ្រីប';

  @override
  String get bubbleCorruptedImage => '[រូបភាពខូច]';

  @override
  String get bubbleReplyPhoto => 'រូបថត';

  @override
  String get bubbleReplyVoice => 'សារសម្លេង';

  @override
  String get bubbleReplyVideo => 'សារវីដេអូ';

  @override
  String bubbleReadBy(String names) {
    return 'បានអានដោយ $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'បានអានដោយ $count';
  }

  @override
  String get chatTileTapToStart => 'ចុចដើម្បីចាប់ផ្តើមជជែក';

  @override
  String get chatTileMessageSent => 'សារត្រូវបានផ្ញើ';

  @override
  String get chatTileEncryptedMessage => 'សារអ៊ិនគ្រីប';

  @override
  String chatTileYouPrefix(String text) {
    return 'អ្នក: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 សារជាសំឡេង';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 សារជាសំឡេង ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'សារអ៊ិនគ្រីប';

  @override
  String get groupNewGroup => 'ក្រុមថ្មី';

  @override
  String get groupGroupName => 'ឈ្មោះក្រុម';

  @override
  String get groupSelectMembers => 'ជ្រើសរើសសមាជិក (អប្បបរមា 2)';

  @override
  String get groupNoContactsYet =>
      'មិនទាន់មានទំនាក់ទំនង។ បន្ថែមទំនាក់ទំនងជាមុនសិន។';

  @override
  String get groupCreate => 'បង្កើត';

  @override
  String get groupLabel => 'ក្រុម';

  @override
  String get profileVerifyIdentity => 'ផ្ទៀងផ្ទាត់អត្តសញ្ញាណ';

  @override
  String profileVerifyInstructions(String name) {
    return 'ប្រៀបធៀបស្នាមម្រាមដៃទាំងនេះជាមួយ $name តាមរយៈការហៅសម្លេង ឬដោយផ្ទាល់។ ប្រសិនបើតម្លៃទាំងពីរត្រូវគ្នានៅលើឧបករណ៍ទាំងពីរ សូមចុច \"សម្គាល់ថាបានផ្ទៀងផ្ទាត់\"។';
  }

  @override
  String get profileTheirKey => 'សោរបស់គេ';

  @override
  String get profileYourKey => 'សោរបស់អ្នក';

  @override
  String get profileRemoveVerification => 'លុបការផ្ទៀងផ្ទាត់';

  @override
  String get profileMarkAsVerified => 'សម្គាល់ថាបានផ្ទៀងផ្ទាត់';

  @override
  String get profileAddressCopied => 'បានចម្លងអាសយដ្ឋាន';

  @override
  String get profileNoContactsToAdd =>
      'គ្មានទំនាក់ទំនងដើម្បីបន្ថែម — ទាំងអស់គឺជាសមាជិករួចហើយ';

  @override
  String get profileAddMembers => 'បន្ថែមសមាជិក';

  @override
  String profileAddCount(int count) {
    return 'បន្ថែម ($count)';
  }

  @override
  String get profileRenameGroup => 'ប្តូរឈ្មោះក្រុម';

  @override
  String get profileRename => 'ប្តូរឈ្មោះ';

  @override
  String get profileRemoveMember => 'លុបសមាជិក?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'លុប $name ចេញពីក្រុមនេះ?';
  }

  @override
  String get profileKick => 'បណ្តេញ';

  @override
  String get profileSignalFingerprints => 'ស្នាមម្រាមដៃ Signal';

  @override
  String get profileVerified => 'បានផ្ទៀងផ្ទាត់';

  @override
  String get profileVerify => 'ផ្ទៀងផ្ទាត់';

  @override
  String get profileEdit => 'កែសម្រួល';

  @override
  String get profileNoSession => 'មិនទាន់មានវគ្គភ្ជាប់ — ផ្ញើសារជាមុនសិន។';

  @override
  String get profileFingerprintCopied => 'បានចម្លងស្នាមម្រាមដៃ';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count សមាជិក$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'ផ្ទៀងផ្ទាត់លេខសុវត្ថិភាព';

  @override
  String get profileShowContactQr => 'បង្ហាញ QR ទំនាក់ទំនង';

  @override
  String profileContactAddress(String name) {
    return 'អាសយដ្ឋានរបស់ $name';
  }

  @override
  String get profileExportChatHistory => 'នាំចេញប្រវត្តិជជែក';

  @override
  String profileSavedTo(String path) {
    return 'បានរក្សាទុកនៅ $path';
  }

  @override
  String get profileExportFailed => 'ការនាំចេញបានបរាជ័យ';

  @override
  String get profileClearChatHistory => 'សម្អាតប្រវត្តិជជែក';

  @override
  String get profileDeleteGroup => 'លុបក្រុម';

  @override
  String get profileDeleteContact => 'លុបទំនាក់ទំនង';

  @override
  String get profileLeaveGroup => 'ចាកចេញពីក្រុម';

  @override
  String get profileLeaveGroupBody =>
      'អ្នកនឹងត្រូវបានលុបចេញពីក្រុមនេះ ហើយវានឹងត្រូវបានលុបចេញពីទំនាក់ទំនងរបស់អ្នក។';

  @override
  String get groupInviteTitle => 'ការអញ្ជើញចូលក្រុម';

  @override
  String groupInviteBody(String from, String group) {
    return '$from បានអញ្ជើញអ្នកឱ្យចូលរួម \"$group\"';
  }

  @override
  String get groupInviteAccept => 'ទទួល';

  @override
  String get groupInviteDecline => 'បដិសេធ';

  @override
  String get groupMemberLimitTitle => 'អ្នកចូលរួមច្រើនពេក';

  @override
  String groupMemberLimitBody(int count) {
    return 'ក្រុមនេះនឹងមាន $count អ្នកចូលរួម។ ការហៅ mesh អ៊ិនគ្រីបគាំទ្រអតិបរមា 6។ ក្រុមធំជាងនេះនឹងប្តូរទៅ Jitsi (មិន E2EE)។';
  }

  @override
  String get groupMemberLimitContinue => 'បន្ថែមទោះបីជាយ៉ាងណា';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name បានបដិសេធការចូលរួម \"$group\"';
  }

  @override
  String get transferTitle => 'ផ្ទេរទៅឧបករណ៍ផ្សេង';

  @override
  String get transferInfoBox =>
      'ផ្លាស់ទីអត្តសញ្ញាណ Signal និងសោ Nostr របស់អ្នកទៅឧបករណ៍ថ្មី។\nវគ្គជជែកមិនត្រូវបានផ្ទេរទេ — forward secrecy ត្រូវបានរក្សា។';

  @override
  String get transferSendFromThis => 'ផ្ញើពីឧបករណ៍នេះ';

  @override
  String get transferSendSubtitle =>
      'ឧបករណ៍នេះមានសោ។ ចែករំលែកកូដជាមួយឧបករណ៍ថ្មី។';

  @override
  String get transferReceiveOnThis => 'ទទួលនៅលើឧបករណ៍នេះ';

  @override
  String get transferReceiveSubtitle =>
      'នេះជាឧបករណ៍ថ្មី។ បញ្ចូលកូដពីឧបករណ៍ចាស់។';

  @override
  String get transferChooseMethod => 'ជ្រើសរើសវិធីផ្ទេរ';

  @override
  String get transferLan => 'LAN (បណ្តាញដូចគ្នា)';

  @override
  String get transferLanSubtitle =>
      'លឿន ផ្ទាល់។ ឧបករណ៍ទាំងពីរត្រូវតែនៅលើ Wi-Fi ដូចគ្នា។';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'ដំណើរការលើបណ្តាញណាមួយដោយប្រើ Nostr relay ដែលមានស្រាប់។';

  @override
  String get transferRelayUrl => 'URL របស់ Relay';

  @override
  String get transferEnterCode => 'បញ្ចូលកូដផ្ទេរ';

  @override
  String get transferPasteCode => 'បិទភ្ជាប់កូដ LAN:... ឬ NOS:... នៅទីនេះ';

  @override
  String get transferConnect => 'តភ្ជាប់';

  @override
  String get transferGenerating => 'កំពុងបង្កើតកូដផ្ទេរ…';

  @override
  String get transferShareCode => 'ចែករំលែកកូដនេះជាមួយអ្នកទទួល:';

  @override
  String get transferCopyCode => 'ចម្លងកូដ';

  @override
  String get transferCodeCopied => 'កូដត្រូវបានចម្លងទៅក្ដារតម្បៀតខ្ទាស់';

  @override
  String get transferWaitingReceiver => 'កំពុងរង់ចាំអ្នកទទួលភ្ជាប់…';

  @override
  String get transferConnectingSender => 'កំពុងភ្ជាប់ទៅអ្នកផ្ញើ…';

  @override
  String get transferVerifyBoth =>
      'ប្រៀបធៀបកូដនេះនៅលើឧបករណ៍ទាំងពីរ។\nប្រសិនបើវាត្រូវគ្នា ការផ្ទេរមានសុវត្ថិភាព។';

  @override
  String get transferComplete => 'ការផ្ទេរបានបញ្ចប់';

  @override
  String get transferKeysImported => 'សោត្រូវបាននាំចូល';

  @override
  String get transferCompleteSenderBody =>
      'សោរបស់អ្នកនៅតែសកម្មនៅលើឧបករណ៍នេះ។\nអ្នកទទួលអាចប្រើអត្តសញ្ញាណរបស់អ្នកឥឡូវនេះ។';

  @override
  String get transferCompleteReceiverBody =>
      'សោត្រូវបាននាំចូលដោយជោគជ័យ។\nចាប់ផ្តើមកម្មវិធីឡើងវិញដើម្បីអនុវត្តអត្តសញ្ញាណថ្មី។';

  @override
  String get transferRestartApp => 'ចាប់ផ្តើមកម្មវិធីឡើងវិញ';

  @override
  String get transferFailed => 'ការផ្ទេរបានបរាជ័យ';

  @override
  String get transferTryAgain => 'ព្យាយាមម្តងទៀត';

  @override
  String get transferEnterRelayFirst => 'បញ្ចូល URL របស់ relay ជាមុនសិន';

  @override
  String get transferPasteCodeFromSender => 'បិទភ្ជាប់កូដផ្ទេរពីអ្នកផ្ញើ';

  @override
  String get menuReply => 'ឆ្លើយ';

  @override
  String get menuForward => 'បញ្ជូនបន្ត';

  @override
  String get menuReact => 'ប្រតិកម្ម';

  @override
  String get menuCopy => 'ចម្លង';

  @override
  String get menuEdit => 'កែសម្រួល';

  @override
  String get menuRetry => 'ព្យាយាមម្តងទៀត';

  @override
  String get menuCancelScheduled => 'បោះបង់ការកំណត់ពេល';

  @override
  String get menuDelete => 'លុប';

  @override
  String get menuForwardTo => 'បញ្ជូនបន្តទៅ…';

  @override
  String menuForwardedTo(String name) {
    return 'បានបញ្ជូនបន្តទៅ $name';
  }

  @override
  String get menuScheduledMessages => 'សារដែលបានកំណត់ពេល';

  @override
  String get menuNoScheduledMessages => 'គ្មានសារដែលបានកំណត់ពេល';

  @override
  String menuSendsOn(String date) {
    return 'ផ្ញើនៅ $date';
  }

  @override
  String get menuDisappearingMessages => 'សារបាត់ខ្លួន';

  @override
  String get menuDisappearingSubtitle =>
      'សារនឹងត្រូវបានលុបដោយស្វ័យប្រវត្តិបន្ទាប់ពីពេលដែលបានជ្រើសរើស។';

  @override
  String get menuTtlOff => 'បិទ';

  @override
  String get menuTtl1h => '1 ម៉ោង';

  @override
  String get menuTtl24h => '24 ម៉ោង';

  @override
  String get menuTtl7d => '7 ថ្ងៃ';

  @override
  String get menuAttachPhoto => 'រូបថត';

  @override
  String get menuAttachFile => 'ឯកសារ';

  @override
  String get menuAttachVideo => 'វីដេអូ';

  @override
  String get mediaTitle => 'មេឌៀ';

  @override
  String get mediaFileLabel => 'ឯកសារ';

  @override
  String mediaPhotosTab(int count) {
    return 'រូបថត ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'ឯកសារ ($count)';
  }

  @override
  String get mediaNoPhotos => 'មិនទាន់មានរូបថត';

  @override
  String get mediaNoFiles => 'មិនទាន់មានឯកសារ';

  @override
  String mediaSavedToDownloads(String name) {
    return 'បានរក្សាទុកនៅ Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'មិនអាចរក្សាទុកឯកសារបាន';

  @override
  String get statusNewStatus => 'ស្ថានភាពថ្មី';

  @override
  String get statusPublish => 'ផ្សព្វផ្សាយ';

  @override
  String get statusExpiresIn24h => 'ស្ថានភាពផុតកំណត់ក្នុង 24 ម៉ោង';

  @override
  String get statusWhatsOnYourMind => 'អ្នកកំពុងគិតអ្វី?';

  @override
  String get statusPhotoAttached => 'បានភ្ជាប់រូបថត';

  @override
  String get statusAttachPhoto => 'ភ្ជាប់រូបថត (ជម្រើស)';

  @override
  String get statusEnterText => 'សូមបញ្ចូលអត្ថបទខ្លះសម្រាប់ស្ថានភាពរបស់អ្នក។';

  @override
  String statusPickPhotoFailed(String error) {
    return 'មិនអាចជ្រើសរើសរូបថតបាន: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'ការផ្សព្វផ្សាយបានបរាជ័យ: $error';
  }

  @override
  String get panicSetPanicKey => 'កំណត់សោបន្ទាន់';

  @override
  String get panicEmergencySelfDestruct => 'ការបំផ្លាញខ្លួនឯងពេលមានអាសន្ន';

  @override
  String get panicIrreversible => 'សកម្មភាពនេះមិនអាចត្រឡប់វិញបាន';

  @override
  String get panicWarningBody =>
      'ការបញ្ចូលសោនេះនៅអេក្រង់ចាក់សោនឹងលុបទិន្នន័យទាំងអស់ភ្លាមៗ — សារ ទំនាក់ទំនង សោ អត្តសញ្ញាណ។ ប្រើសោដែលខុសពីពាក្យសម្ងាត់ធម្មតារបស់អ្នក។';

  @override
  String get panicKeyHint => 'សោបន្ទាន់';

  @override
  String get panicConfirmHint => 'បញ្ជាក់សោបន្ទាន់';

  @override
  String get panicMinChars => 'សោបន្ទាន់ត្រូវតែមានយ៉ាងហោចណាស់ 8 តួអក្សរ';

  @override
  String get panicKeysDoNotMatch => 'សោមិនត្រូវគ្នា';

  @override
  String get panicSetFailed => 'មិនអាចរក្សាទុកសោបន្ទាន់បាន — សូមព្យាយាមម្តងទៀត';

  @override
  String get passwordSetAppPassword => 'កំណត់ពាក្យសម្ងាត់កម្មវិធី';

  @override
  String get passwordProtectsMessages => 'ការពារសាររបស់អ្នកពេលឈប់ដំណើរការ';

  @override
  String get passwordInfoBanner =>
      'ត្រូវការរាល់ពេលអ្នកបើក Pulse។ ប្រសិនបើភ្លេច ទិន្នន័យរបស់អ្នកមិនអាចស្ដារបានទេ។';

  @override
  String get passwordHint => 'ពាក្យសម្ងាត់';

  @override
  String get passwordConfirmHint => 'បញ្ជាក់ពាក្យសម្ងាត់';

  @override
  String get passwordSetButton => 'កំណត់ពាក្យសម្ងាត់';

  @override
  String get passwordSkipForNow => 'រំលងសម្រាប់ពេលនេះ';

  @override
  String get passwordMinChars => 'ពាក្យសម្ងាត់ត្រូវតែមានយ៉ាងហោចណាស់ 6 តួអក្សរ';

  @override
  String get passwordsDoNotMatch => 'ពាក្យសម្ងាត់មិនត្រូវគ្នា';

  @override
  String get profileCardSaved => 'បានរក្សាទុកប្រវត្តិរូប!';

  @override
  String get profileCardE2eeIdentity => 'អត្តសញ្ញាណ E2EE';

  @override
  String get profileCardDisplayName => 'ឈ្មោះបង្ហាញ';

  @override
  String get profileCardDisplayNameHint => 'ឧ. សុខ ចាន់ដារា';

  @override
  String get profileCardAbout => 'អំពី';

  @override
  String get profileCardSaveProfile => 'រក្សាទុកប្រវត្តិរូប';

  @override
  String get profileCardYourName => 'ឈ្មោះរបស់អ្នក';

  @override
  String get profileCardAddressCopied => 'បានចម្លងអាសយដ្ឋាន!';

  @override
  String get profileCardInboxAddress => 'អាសយដ្ឋានប្រអប់សំបុត្រចូលរបស់អ្នក';

  @override
  String get profileCardInboxAddresses => 'អាសយដ្ឋានប្រអប់សំបុត្រចូលរបស់អ្នក';

  @override
  String get profileCardShareAllAddresses =>
      'ចែករំលែកអាសយដ្ឋានទាំងអស់ (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'ចែករំលែកជាមួយទំនាក់ទំនងដើម្បីឱ្យពួកគេអាចផ្ញើសារមកអ្នក។';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'បានចម្លងអាសយដ្ឋានទាំង $count ជាតំណមួយ!';
  }

  @override
  String get settingsMyProfile => 'ប្រវត្តិរូបរបស់ខ្ញុំ';

  @override
  String get settingsYourInboxAddress => 'អាសយដ្ឋានប្រអប់សំបុត្រចូលរបស់អ្នក';

  @override
  String get settingsMyQrCode => 'កូដ QR របស់ខ្ញុំ';

  @override
  String get settingsMyQrSubtitle =>
      'ចែករំលែកអាសយដ្ឋានរបស់អ្នកជា QR ដែលអាចស្កែនបាន';

  @override
  String get settingsShareMyAddress => 'ចែករំលែកអាសយដ្ឋានរបស់ខ្ញុំ';

  @override
  String get settingsNoAddressYet =>
      'មិនទាន់មានអាសយដ្ឋាន — រក្សាទុកការកំណត់ជាមុនសិន';

  @override
  String get settingsInviteLink => 'តំណអញ្ជើញ';

  @override
  String get settingsRawAddress => 'អាសយដ្ឋានឆៅ';

  @override
  String get settingsCopyLink => 'ចម្លងតំណ';

  @override
  String get settingsCopyAddress => 'ចម្លងអាសយដ្ឋាន';

  @override
  String get settingsInviteLinkCopied => 'បានចម្លងតំណអញ្ជើញ';

  @override
  String get settingsAppearance => 'រូបរាង';

  @override
  String get settingsThemeEngine => 'ម៉ាស៊ីនធីម';

  @override
  String get settingsThemeEngineSubtitle => 'ប្ដូរពណ៌ និងពុម្ពអក្សរតាមបំណង';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle =>
      'សោ E2EE ត្រូវបានរក្សាទុកដោយសុវត្ថិភាព';

  @override
  String get settingsActive => 'សកម្ម';

  @override
  String get settingsIdentityBackup => 'បម្រុងទុកអត្តសញ្ញាណ';

  @override
  String get settingsIdentityBackupSubtitle =>
      'នាំចេញ ឬនាំចូលអត្តសញ្ញាណ Signal របស់អ្នក';

  @override
  String get settingsIdentityBackupBody =>
      'នាំចេញសោអត្តសញ្ញាណ Signal របស់អ្នកទៅកូដបម្រុង ឬស្ដារពីកូដដែលមានស្រាប់។';

  @override
  String get settingsTransferDevice => 'ផ្ទេរទៅឧបករណ៍ផ្សេង';

  @override
  String get settingsTransferDeviceSubtitle =>
      'ផ្លាស់ទីអត្តសញ្ញាណតាមរយៈ LAN ឬ Nostr relay';

  @override
  String get settingsExportIdentity => 'នាំចេញអត្តសញ្ញាណ';

  @override
  String get settingsExportIdentityBody =>
      'ចម្លងកូដបម្រុងនេះ ហើយរក្សាទុកវាដោយសុវត្ថិភាព:';

  @override
  String get settingsSaveFile => 'រក្សាទុកឯកសារ';

  @override
  String get settingsImportIdentity => 'នាំចូលអត្តសញ្ញាណ';

  @override
  String get settingsImportIdentityBody =>
      'បិទភ្ជាប់កូដបម្រុងរបស់អ្នកខាងក្រោម។ នេះនឹងសរសេរជាន់លើអត្តសញ្ញាណបច្ចុប្បន្នរបស់អ្នក។';

  @override
  String get settingsPasteBackupCode => 'បិទភ្ជាប់កូដបម្រុងនៅទីនេះ…';

  @override
  String get settingsIdentityImported =>
      'បាននាំចូលអត្តសញ្ញាណ + ទំនាក់ទំនង! ចាប់ផ្តើមកម្មវិធីឡើងវិញដើម្បីអនុវត្ត។';

  @override
  String get settingsSecurity => 'សុវត្ថិភាព';

  @override
  String get settingsAppPassword => 'ពាក្យសម្ងាត់កម្មវិធី';

  @override
  String get settingsPasswordEnabled => 'បានបើក — ត្រូវការរាល់ពេលចាប់ផ្តើម';

  @override
  String get settingsPasswordDisabled =>
      'បានបិទ — កម្មវិធីបើកដោយមិនមានពាក្យសម្ងាត់';

  @override
  String get settingsChangePassword => 'ប្តូរពាក្យសម្ងាត់';

  @override
  String get settingsChangePasswordSubtitle =>
      'ធ្វើបច្ចុប្បន្នភាពពាក្យសម្ងាត់ចាក់សោកម្មវិធី';

  @override
  String get settingsSetPanicKey => 'កំណត់សោបន្ទាន់';

  @override
  String get settingsChangePanicKey => 'ប្តូរសោបន្ទាន់';

  @override
  String get settingsPanicKeySetSubtitle => 'ធ្វើបច្ចុប្បន្នភាពសោលុបបន្ទាន់';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'សោមួយដែលលុបទិន្នន័យទាំងអស់ភ្លាមៗ';

  @override
  String get settingsRemovePanicKey => 'លុបសោបន្ទាន់';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'បិទការបំផ្លាញខ្លួនឯងពេលមានអាសន្ន';

  @override
  String get settingsRemovePanicKeyBody =>
      'ការបំផ្លាញខ្លួនឯងពេលមានអាសន្ននឹងត្រូវបានបិទ។ អ្នកអាចបើកវាឡើងវិញនៅពេលណាក៏បាន។';

  @override
  String get settingsDisableAppPassword => 'បិទពាក្យសម្ងាត់កម្មវិធី';

  @override
  String get settingsEnterCurrentPassword =>
      'បញ្ចូលពាក្យសម្ងាត់បច្ចុប្បន្នរបស់អ្នកដើម្បីបញ្ជាក់';

  @override
  String get settingsCurrentPassword => 'ពាក្យសម្ងាត់បច្ចុប្បន្ន';

  @override
  String get settingsIncorrectPassword => 'ពាក្យសម្ងាត់មិនត្រឹមត្រូវ';

  @override
  String get settingsPasswordUpdated => 'បានធ្វើបច្ចុប្បន្នភាពពាក្យសម្ងាត់';

  @override
  String get settingsChangePasswordProceed =>
      'បញ្ចូលពាក្យសម្ងាត់បច្ចុប្បន្នរបស់អ្នកដើម្បីបន្ត';

  @override
  String get settingsData => 'ទិន្នន័យ';

  @override
  String get settingsBackupMessages => 'បម្រុងទុកសារ';

  @override
  String get settingsBackupMessagesSubtitle =>
      'នាំចេញប្រវត្តិសារដែលបានអ៊ិនគ្រីបទៅឯកសារ';

  @override
  String get settingsRestoreMessages => 'ស្ដារសារ';

  @override
  String get settingsRestoreMessagesSubtitle => 'នាំចូលសារពីឯកសារបម្រុង';

  @override
  String get settingsExportKeys => 'នាំចេញសោ';

  @override
  String get settingsExportKeysSubtitle =>
      'រក្សាទុកសោអត្តសញ្ញាណទៅឯកសារអ៊ិនគ្រីប';

  @override
  String get settingsImportKeys => 'នាំចូលសោ';

  @override
  String get settingsImportKeysSubtitle =>
      'ស្ដារសោអត្តសញ្ញាណពីឯកសារដែលបាននាំចេញ';

  @override
  String get settingsBackupPassword => 'ពាក្យសម្ងាត់បម្រុង';

  @override
  String get settingsPasswordCannotBeEmpty => 'ពាក្យសម្ងាត់មិនអាចទទេបាន';

  @override
  String get settingsPasswordMin4Chars =>
      'ពាក្យសម្ងាត់ត្រូវតែមានយ៉ាងហោចណាស់ 4 តួអក្សរ';

  @override
  String get settingsCallsTurn => 'ការហៅ & TURN';

  @override
  String get settingsLocalNetwork => 'បណ្តាញមូលដ្ឋាន';

  @override
  String get settingsCensorshipResistance => 'ការប្រឆាំងការត្រួតពិនិត្យ';

  @override
  String get settingsNetwork => 'បណ្តាញ';

  @override
  String get settingsProxyTunnels => 'Proxy & Tunnels';

  @override
  String get settingsTurnServers => 'TURN Servers';

  @override
  String get settingsProviderTitle => 'អ្នកផ្គត់ផ្គង់';

  @override
  String get settingsLanFallback => 'LAN បម្រុង';

  @override
  String get settingsLanFallbackSubtitle =>
      'ផ្សាយវត្តមាន និងបញ្ជូនសារក្នុងបណ្តាញមូលដ្ឋានពេលគ្មានអ៊ីនធឺណិត។ បិទនៅលើបណ្តាញដែលមិនគួរឱ្យទុកចិត្ត (Wi-Fi សាធារណៈ)។';

  @override
  String get settingsBgDelivery => 'ការបញ្ជូនផ្ទៃខាងក្រោយ';

  @override
  String get settingsBgDeliverySubtitle =>
      'បន្តទទួលសារនៅពេលកម្មវិធីត្រូវបានបង្រួម។ បង្ហាញការជូនដំណឹងអចិន្ត្រៃយ៍។';

  @override
  String get settingsYourInboxProvider =>
      'អ្នកផ្គត់ផ្គង់ប្រអប់សំបុត្រចូលរបស់អ្នក';

  @override
  String get settingsConnectionDetails => 'ព័ត៌មានលម្អិតការតភ្ជាប់';

  @override
  String get settingsSaveAndConnect => 'រក្សាទុក & តភ្ជាប់';

  @override
  String get settingsSecondaryInboxes => 'ប្រអប់សំបុត្រចូលបន្ទាប់បន្សំ';

  @override
  String get settingsAddSecondaryInbox => 'បន្ថែមប្រអប់សំបុត្រចូលបន្ទាប់បន្សំ';

  @override
  String get settingsAdvanced => 'កម្រិតខ្ពស់';

  @override
  String get settingsDiscover => 'ស្វែងរក';

  @override
  String get settingsAbout => 'អំពី';

  @override
  String get settingsPrivacyPolicy => 'គោលការណ៍ឯកជនភាព';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'របៀបដែល Pulse ការពារទិន្នន័យរបស់អ្នក';

  @override
  String get settingsCrashReporting => 'របាយការណ៍គាំង';

  @override
  String get settingsCrashReportingSubtitle =>
      'ផ្ញើរបាយការណ៍គាំងអនាមិកដើម្បីជួយកែលម្អ Pulse។ គ្មានខ្លឹមសារសារ ឬទំនាក់ទំនងណាមួយត្រូវបានផ្ញើទេ។';

  @override
  String get settingsCrashReportingEnabled =>
      'បានបើករបាយការណ៍គាំង — ចាប់ផ្តើមកម្មវិធីឡើងវិញដើម្បីអនុវត្ត';

  @override
  String get settingsCrashReportingDisabled =>
      'បានបិទរបាយការណ៍គាំង — ចាប់ផ្តើមកម្មវិធីឡើងវិញដើម្បីអនុវត្ត';

  @override
  String get settingsSensitiveOperation => 'ប្រតិបត្តិការរសើប';

  @override
  String get settingsSensitiveOperationBody =>
      'សោទាំងនេះជាអត្តសញ្ញាណរបស់អ្នក។ អ្នកណាដែលមានឯកសារនេះអាចក្លែងធ្វើជាអ្នកបាន។ រក្សាទុកវាដោយសុវត្ថិភាព ហើយលុបវាបន្ទាប់ពីផ្ទេរ។';

  @override
  String get settingsIUnderstandContinue => 'ខ្ញុំយល់ បន្ត';

  @override
  String get settingsReplaceIdentity => 'ជំនួសអត្តសញ្ញាណ?';

  @override
  String get settingsReplaceIdentityBody =>
      'នេះនឹងសរសេរជាន់លើសោអត្តសញ្ញាណបច្ចុប្បន្នរបស់អ្នក។ វគ្គ Signal ដែលមានស្រាប់របស់អ្នកនឹងមិនមានសុពលភាព ហើយទំនាក់ទំនងនឹងត្រូវបង្កើតការអ៊ិនគ្រីបឡើងវិញ។ កម្មវិធីត្រូវចាប់ផ្តើមឡើងវិញ។';

  @override
  String get settingsReplaceKeys => 'ជំនួសសោ';

  @override
  String get settingsKeysImported => 'សោត្រូវបាននាំចូល';

  @override
  String settingsKeysImportedBody(int count) {
    return 'បាននាំចូល $count សោដោយជោគជ័យ។ សូមចាប់ផ្តើមកម្មវិធីឡើងវិញដើម្បីចាប់ផ្តើមឡើងវិញជាមួយអត្តសញ្ញាណថ្មី។';
  }

  @override
  String get settingsRestartNow => 'ចាប់ផ្តើមឡើងវិញឥឡូវនេះ';

  @override
  String get settingsLater => 'ពេលក្រោយ';

  @override
  String get profileGroupLabel => 'ក្រុម';

  @override
  String get profileAddButton => 'បន្ថែម';

  @override
  String get profileKickButton => 'បណ្តេញ';

  @override
  String get dataSectionTitle => 'ទិន្នន័យ';

  @override
  String get dataBackupMessages => 'បម្រុងទុកសារ';

  @override
  String get dataBackupPasswordSubtitle =>
      'ជ្រើសរើសពាក្យសម្ងាត់ដើម្បីអ៊ិនគ្រីបការបម្រុងទុកសាររបស់អ្នក។';

  @override
  String get dataBackupConfirmLabel => 'បង្កើតការបម្រុង';

  @override
  String get dataCreatingBackup => 'កំពុងបង្កើតការបម្រុង';

  @override
  String get dataBackupPreparing => 'កំពុងរៀបចំ...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'កំពុងនាំចេញសារ $done ពី $total...';
  }

  @override
  String get dataBackupSavingFile => 'កំពុងរក្សាទុកឯកសារ...';

  @override
  String get dataSaveMessageBackupDialog => 'រក្សាទុកការបម្រុងសារ';

  @override
  String dataBackupSaved(int count, String path) {
    return 'បានរក្សាទុកការបម្រុង ($count សារ)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'ការបម្រុងបានបរាជ័យ — គ្មានទិន្នន័យត្រូវបាននាំចេញ';

  @override
  String dataBackupFailedError(String error) {
    return 'ការបម្រុងបានបរាជ័យ: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'ជ្រើសរើសការបម្រុងសារ';

  @override
  String get dataInvalidBackupFile => 'ឯកសារបម្រុងមិនត្រឹមត្រូវ (តូចពេក)';

  @override
  String get dataNotValidBackupFile => 'មិនមែនជាឯកសារបម្រុង Pulse ត្រឹមត្រូវទេ';

  @override
  String get dataRestoreMessages => 'ស្ដារសារ';

  @override
  String get dataRestorePasswordSubtitle =>
      'បញ្ចូលពាក្យសម្ងាត់ដែលបានប្រើដើម្បីបង្កើតការបម្រុងនេះ។';

  @override
  String get dataRestoreConfirmLabel => 'ស្ដារ';

  @override
  String get dataRestoringMessages => 'កំពុងស្ដារសារ';

  @override
  String get dataRestoreDecrypting => 'កំពុងឌិគ្រីប...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'កំពុងនាំចូលសារ $done ពី $total...';
  }

  @override
  String get dataRestoreFailed =>
      'ការស្ដារបានបរាជ័យ — ពាក្យសម្ងាត់ខុស ឬឯកសារខូច';

  @override
  String dataRestoreSuccess(int count) {
    return 'បានស្ដារ $count សារថ្មី';
  }

  @override
  String get dataRestoreNothingNew =>
      'គ្មានសារថ្មីដើម្បីនាំចូល (ទាំងអស់មានស្រាប់រួចហើយ)';

  @override
  String dataRestoreFailedError(String error) {
    return 'ការស្ដារបានបរាជ័យ: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'ជ្រើសរើសការនាំចេញសោ';

  @override
  String get dataNotValidKeyFile => 'មិនមែនជាឯកសារនាំចេញសោ Pulse ត្រឹមត្រូវទេ';

  @override
  String get dataExportKeys => 'នាំចេញសោ';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'ជ្រើសរើសពាក្យសម្ងាត់ដើម្បីអ៊ិនគ្រីបការនាំចេញសោរបស់អ្នក។';

  @override
  String get dataExportKeysConfirmLabel => 'នាំចេញ';

  @override
  String get dataExportingKeys => 'កំពុងនាំចេញសោ';

  @override
  String get dataExportingKeysStatus => 'កំពុងអ៊ិនគ្រីបសោអត្តសញ្ញាណ...';

  @override
  String get dataSaveKeyExportDialog => 'រក្សាទុកការនាំចេញសោ';

  @override
  String dataKeysExportedTo(String path) {
    return 'សោត្រូវបាននាំចេញទៅ:\n$path';
  }

  @override
  String get dataExportFailed => 'ការនាំចេញបានបរាជ័យ — រកមិនឃើញសោ';

  @override
  String dataExportFailedError(String error) {
    return 'ការនាំចេញបានបរាជ័យ: $error';
  }

  @override
  String get dataImportKeys => 'នាំចូលសោ';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'បញ្ចូលពាក្យសម្ងាត់ដែលបានប្រើដើម្បីអ៊ិនគ្រីបការនាំចេញសោនេះ។';

  @override
  String get dataImportKeysConfirmLabel => 'នាំចូល';

  @override
  String get dataImportingKeys => 'កំពុងនាំចូលសោ';

  @override
  String get dataImportingKeysStatus => 'កំពុងឌិគ្រីបសោអត្តសញ្ញាណ...';

  @override
  String get dataImportFailed =>
      'ការនាំចូលបានបរាជ័យ — ពាក្យសម្ងាត់ខុស ឬឯកសារខូច';

  @override
  String dataImportFailedError(String error) {
    return 'ការនាំចូលបានបរាជ័យ: $error';
  }

  @override
  String get securitySectionTitle => 'សុវត្ថិភាព';

  @override
  String get securityIncorrectPassword => 'ពាក្យសម្ងាត់មិនត្រឹមត្រូវ';

  @override
  String get securityPasswordUpdated => 'បានធ្វើបច្ចុប្បន្នភាពពាក្យសម្ងាត់';

  @override
  String get appearanceSectionTitle => 'រូបរាង';

  @override
  String appearanceExportFailed(String error) {
    return 'ការនាំចេញបានបរាជ័យ: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'បានរក្សាទុកនៅ $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'ការរក្សាទុកបានបរាជ័យ: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'ការនាំចូលបានបរាជ័យ: $error';
  }

  @override
  String get aboutSectionTitle => 'អំពី';

  @override
  String get providerPublicKey => 'សោសាធារណៈ';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'កំណត់រចនាសម្ព័ន្ធដោយស្វ័យប្រវត្តិពីពាក្យសម្ងាត់សង្គ្រោះរបស់អ្នក។ Relay ត្រូវបានរកឃើញដោយស្វ័យប្រវត្តិ។';

  @override
  String get providerKeyStoredLocally =>
      'សោរបស់អ្នកត្រូវបានរក្សាទុកក្នុងម៉ាស៊ីនក្នុងការផ្ទុកសុវត្ថិភាព — មិនដែលផ្ញើទៅម៉ាស៊ីនមេណាមួយ។';

  @override
  String get providerSessionInfo =>
      'Session Network — E2EE ដែលផ្ញើតាមផ្លូវវង្វែង។ Session ID របស់អ្នកត្រូវបានបង្កើតដោយស្វ័យប្រវត្តិ និងរក្សាទុកដោយសុវត្ថិភាព។ ថ្នាំងត្រូវបានស្វែងរកដោយស្វ័យប្រវត្តិពីថ្នាំង seed ដែលភ្ជាប់មកជាមួយ។';

  @override
  String get providerAdvanced => 'កម្រិតខ្ពស់';

  @override
  String get providerSaveAndConnect => 'រក្សាទុក & តភ្ជាប់';

  @override
  String get providerAddSecondaryInbox => 'បន្ថែមប្រអប់សំបុត្រចូលបន្ទាប់បន្សំ';

  @override
  String get providerSecondaryInboxes => 'ប្រអប់សំបុត្រចូលបន្ទាប់បន្សំ';

  @override
  String get providerYourInboxProvider =>
      'អ្នកផ្គត់ផ្គង់ប្រអប់សំបុត្រចូលរបស់អ្នក';

  @override
  String get providerConnectionDetails => 'ព័ត៌មានលម្អិតការតភ្ជាប់';

  @override
  String get addContactTitle => 'បន្ថែមទំនាក់ទំនង';

  @override
  String get addContactInviteLinkLabel => 'តំណអញ្ជើញ ឬអាសយដ្ឋាន';

  @override
  String get addContactTapToPaste => 'ចុចដើម្បីបិទភ្ជាប់តំណអញ្ជើញ';

  @override
  String get addContactPasteTooltip => 'បិទភ្ជាប់ពីក្ដារតម្បៀតខ្ទាស់';

  @override
  String get addContactAddressDetected => 'បានរកឃើញអាសយដ្ឋានទំនាក់ទំនង';

  @override
  String addContactRoutesDetected(int count) {
    return 'បានរកឃើញ $count ផ្លូវ — SmartRouter ជ្រើសរើសផ្លូវលឿនបំផុត';
  }

  @override
  String get addContactFetchingProfile => 'កំពុងទាញយកប្រវត្តិរូប…';

  @override
  String addContactProfileFound(String name) {
    return 'រកឃើញ: $name';
  }

  @override
  String get addContactNoProfileFound => 'រកមិនឃើញប្រវត្តិរូប';

  @override
  String get addContactDisplayNameLabel => 'ឈ្មោះបង្ហាញ';

  @override
  String get addContactDisplayNameHint => 'អ្នកចង់ហៅពួកគេថាអ្វី?';

  @override
  String get addContactAddManually => 'បន្ថែមអាសយដ្ឋានដោយដៃ';

  @override
  String get addContactButton => 'បន្ថែមទំនាក់ទំនង';

  @override
  String get networkDiagnosticsTitle => 'ការវិនិច្ឆ័យបណ្តាញ';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr Relays';

  @override
  String get networkDiagnosticsDirect => 'ផ្ទាល់';

  @override
  String get networkDiagnosticsTorOnly => 'Tor ប៉ុណ្ណោះ';

  @override
  String get networkDiagnosticsBest => 'ល្អបំផុត';

  @override
  String get networkDiagnosticsNone => 'គ្មាន';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'ស្ថានភាព';

  @override
  String get networkDiagnosticsConnected => 'បានតភ្ជាប់';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'កំពុងតភ្ជាប់ $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'បិទ';

  @override
  String get networkDiagnosticsTransport => 'ការដឹកជញ្ជូន';

  @override
  String get networkDiagnosticsInfrastructure => 'ហេដ្ឋារចនាសម្ព័ន្ធ';

  @override
  String get networkDiagnosticsSessionNodes => 'ថ្នាំង Session';

  @override
  String get networkDiagnosticsTurnServers => 'TURN servers';

  @override
  String get networkDiagnosticsLastProbe => 'ការពិនិត្យចុងក្រោយ';

  @override
  String get networkDiagnosticsRunning => 'កំពុងដំណើរការ...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'ដំណើរការការវិនិច្ឆ័យ';

  @override
  String get networkDiagnosticsForceReprobe => 'បង្ខំការពិនិត្យឡើងវិញពេញលេញ';

  @override
  String get networkDiagnosticsJustNow => 'ទើបតែ';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'មុន $minutes នាទី';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'មុន $hours ម៉ោង';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'មុន $days ថ្ងៃ';
  }

  @override
  String get homeNoEch => 'គ្មាន ECH';

  @override
  String get homeNoEchTooltip =>
      'uTLS proxy មិនអាចប្រើបាន — ECH បានបិទ។\nស្នាមម្រាមដៃ TLS អាចមើលឃើញដោយ DPI។';

  @override
  String get settingsTitle => 'ការកំណត់';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'បានរក្សាទុក & តភ្ជាប់ទៅ $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Tor ដែលមានស្រាប់មិនអាចចាប់ផ្តើមបាន';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon មិនអាចចាប់ផ្តើមបាន';

  @override
  String get verifyTitle => 'ផ្ទៀងផ្ទាត់លេខសុវត្ថិភាព';

  @override
  String get verifyIdentityVerified => 'អត្តសញ្ញាណបានផ្ទៀងផ្ទាត់';

  @override
  String get verifyNotYetVerified => 'មិនទាន់បានផ្ទៀងផ្ទាត់';

  @override
  String verifyVerifiedDescription(String name) {
    return 'អ្នកបានផ្ទៀងផ្ទាត់លេខសុវត្ថិភាពរបស់ $name។';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'ប្រៀបធៀបលេខទាំងនេះជាមួយ $name ដោយផ្ទាល់ ឬតាមរយៈបណ្តាញដែលគួរឱ្យទុកចិត្ត។';
  }

  @override
  String get verifyExplanation =>
      'រាល់ការសន្ទនាមានលេខសុវត្ថិភាពតែមួយគត់។ ប្រសិនបើអ្នកទាំងពីរឃើញលេខដូចគ្នានៅលើឧបករណ៍របស់អ្នក ការតភ្ជាប់របស់អ្នកត្រូវបានផ្ទៀងផ្ទាត់ពីចុងដល់ចុង។';

  @override
  String verifyContactKey(String name) {
    return 'សោរបស់ $name';
  }

  @override
  String get verifyYourKey => 'សោរបស់អ្នក';

  @override
  String get verifyRemoveVerification => 'លុបការផ្ទៀងផ្ទាត់';

  @override
  String get verifyMarkAsVerified => 'សម្គាល់ថាបានផ្ទៀងផ្ទាត់';

  @override
  String verifyAfterReinstall(String name) {
    return 'ប្រសិនបើ $name ដំឡើងកម្មវិធីឡើងវិញ លេខសុវត្ថិភាពនឹងផ្លាស់ប្តូរ ហើយការផ្ទៀងផ្ទាត់នឹងត្រូវបានលុបដោយស្វ័យប្រវត្តិ។';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'សម្គាល់ថាបានផ្ទៀងផ្ទាត់បន្ទាប់ពីប្រៀបធៀបលេខជាមួយ $name តាមរយៈការហៅសម្លេង ឬដោយផ្ទាល់តែប៉ុណ្ណោះ។';
  }

  @override
  String get verifyNoSession =>
      'មិនទាន់មានវគ្គអ៊ិនគ្រីប។ ផ្ញើសារជាមុនសិនដើម្បីបង្កើតលេខសុវត្ថិភាព។';

  @override
  String get verifyNoKeyAvailable => 'គ្មានសោអាចប្រើបាន';

  @override
  String verifyFingerprintCopied(String label) {
    return 'បានចម្លងស្នាមម្រាមដៃ $label';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL មូលដ្ឋានទិន្នន័យ';

  @override
  String get providerOptionalHint => 'ជម្រើស';

  @override
  String get providerWebApiKeyLabel => 'សោ Web API';

  @override
  String get providerOptionalForPublicDb => 'ជម្រើសសម្រាប់ DB សាធារណៈ';

  @override
  String get providerRelayUrlLabel => 'URL របស់ Relay';

  @override
  String get providerPrivateKeyLabel => 'សោឯកជន';

  @override
  String get providerPrivateKeyNsecLabel => 'សោឯកជន (nsec)';

  @override
  String get providerStorageNodeLabel => 'URL ថ្នាំងផ្ទុក (ជម្រើស)';

  @override
  String get providerStorageNodeHint => 'ទុកទទេសម្រាប់ថ្នាំង seed ដែលមានស្រាប់';

  @override
  String get transferInvalidCodeFormat =>
      'ទម្រង់កូដមិនស្គាល់ — ត្រូវតែចាប់ផ្តើមដោយ LAN: ឬ NOS:';

  @override
  String get profileCardFingerprintCopied => 'បានចម្លងស្នាមម្រាមដៃ';

  @override
  String get profileCardAboutHint => 'ឯកជនភាពមុន 🔒';

  @override
  String get profileCardSaveButton => 'រក្សាទុកប្រវត្តិរូប';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'នាំចេញសារអ៊ិនគ្រីប ទំនាក់ទំនង និង avatar ទៅឯកសារ';

  @override
  String get callVideo => 'វីដេអូ';

  @override
  String get callAudio => 'អូឌីយ៉ូ';

  @override
  String bubbleDeliveredTo(String names) {
    return 'បានបញ្ជូនទៅ $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'បានបញ្ជូនទៅ $count';
  }

  @override
  String get groupStatusDialogTitle => 'ព័ត៌មានសារ';

  @override
  String get groupStatusRead => 'បានអាន';

  @override
  String get groupStatusDelivered => 'បានបញ្ជូន';

  @override
  String get groupStatusPending => 'កំពុងរង់ចាំ';

  @override
  String get groupStatusNoData => 'មិនទាន់មានព័ត៌មានការបញ្ជូន';

  @override
  String get profileTransferAdmin => 'កំណត់ជា Admin';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'កំណត់ $name ជា admin ថ្មី?';
  }

  @override
  String get profileTransferAdminBody =>
      'អ្នកនឹងបាត់បង់សិទ្ធិ admin។ នេះមិនអាចត្រឡប់វិញបានទេ។';

  @override
  String profileTransferAdminDone(String name) {
    return '$name ឥឡូវជា admin';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'គោលការណ៍ឯកជនភាព';

  @override
  String get privacyOverviewHeading => 'ទិដ្ឋភាពទូទៅ';

  @override
  String get privacyOverviewBody =>
      'Pulse គឺជាកម្មវិធីផ្ញើសារអ៊ិនគ្រីបពីចុងដល់ចុងដែលគ្មានម៉ាស៊ីនមេ។ ឯកជនភាពរបស់អ្នកមិនមែនគ្រាន់តែជាមុខងារទេ — វាជាស្ថាបត្យកម្ម។ គ្មានម៉ាស៊ីនមេ Pulse ទេ។ គ្មានគណនីត្រូវបានរក្សាទុកទីកន្លែងណាទេ។ គ្មានទិន្នន័យត្រូវបានប្រមូល បញ្ជូនទៅ ឬរក្សាទុកដោយអ្នកអភិវឌ្ឍន៍ទេ។';

  @override
  String get privacyDataCollectionHeading => 'ការប្រមូលទិន្នន័យ';

  @override
  String get privacyDataCollectionBody =>
      'Pulse មិនប្រមូលទិន្នន័យផ្ទាល់ខ្លួនណាមួយទេ។ ជាពិសេស:\n\n- មិនត្រូវការអ៊ីមែល លេខទូរស័ព្ទ ឬឈ្មោះពិតទេ\n- គ្មានការវិភាគ ការតាមដាន ឬការប្រមូលទិន្នន័យ\n- គ្មានអត្តសញ្ញាណផ្សាយពាណិជ្ជកម្ម\n- គ្មានការចូលប្រើបញ្ជីទំនាក់ទំនង\n- គ្មានការបម្រុងទុកពពក (សារមាននៅលើឧបករណ៍របស់អ្នកតែប៉ុណ្ណោះ)\n- គ្មានទិន្នន័យមេតាត្រូវបានផ្ញើទៅម៉ាស៊ីនមេ Pulse ណាមួយ (គ្មានទេ)';

  @override
  String get privacyEncryptionHeading => 'ការអ៊ិនគ្រីប';

  @override
  String get privacyEncryptionBody =>
      'សារទាំងអស់ត្រូវបានអ៊ិនគ្រីបដោយប្រើ Signal Protocol (Double Ratchet ជាមួយកិច្ចព្រមព្រៀងសោ X3DH)។ សោអ៊ិនគ្រីបត្រូវបានបង្កើត និងរក្សាទុកផ្តាច់មុខនៅលើឧបករណ៍របស់អ្នក។ គ្មាននរណា — រួមទាំងអ្នកអភិវឌ្ឍន៍ — អាចអានសាររបស់អ្នកបានទេ។';

  @override
  String get privacyNetworkHeading => 'ស្ថាបត្យកម្មបណ្តាញ';

  @override
  String get privacyNetworkBody =>
      'Pulse ប្រើអាដាប់ទ័រដឹកជញ្ជូនសហព័ន្ធ (Nostr relays, ថ្នាំងសេវា Session/Oxen, Firebase Realtime Database, LAN)។ ការដឹកជញ្ជូនទាំងនេះនាំតែអក្សរកូដអ៊ិនគ្រីបប៉ុណ្ណោះ។ ប្រតិបត្តិករ Relay អាចមើលឃើញអាសយដ្ឋាន IP និងបរិមាណចរាចរណ៍របស់អ្នក ប៉ុន្តែមិនអាចឌិគ្រីបខ្លឹមសារសារបានទេ។\n\nពេល Tor ត្រូវបានបើក អាសយដ្ឋាន IP របស់អ្នកក៏ត្រូវបានលាក់ពីប្រតិបត្តិករ relay ផងដែរ។';

  @override
  String get privacyStunHeading => 'STUN/TURN Servers';

  @override
  String get privacyStunBody =>
      'ការហៅសម្លេង និងវីដេអូប្រើ WebRTC ជាមួយការអ៊ិនគ្រីប DTLS-SRTP។ STUN servers (ប្រើដើម្បីស្វែងរកអាសយដ្ឋាន IP សាធារណៈរបស់អ្នកសម្រាប់ការតភ្ជាប់ peer-to-peer) និង TURN servers (ប្រើដើម្បីបញ្ជូនមេឌៀពេលការតភ្ជាប់ផ្ទាល់បរាជ័យ) អាចមើលឃើញអាសយដ្ឋាន IP និងរយៈពេលហៅរបស់អ្នក ប៉ុន្តែមិនអាចឌិគ្រីបខ្លឹមសារការហៅបានទេ។\n\nអ្នកអាចកំណត់រចនាសម្ព័ន្ធ TURN server ផ្ទាល់ខ្លួនក្នុងការកំណត់សម្រាប់ឯកជនភាពអតិបរមា។';

  @override
  String get privacyCrashHeading => 'របាយការណ៍គាំង';

  @override
  String get privacyCrashBody =>
      'ប្រសិនបើរបាយការណ៍គាំង Sentry ត្រូវបានបើក (តាមរយៈ SENTRY_DSN ពេលកសាង) របាយការណ៍គាំងអនាមិកអាចត្រូវបានផ្ញើ។ ទាំងនេះមិនមានខ្លឹមសារសារ ព័ត៌មានទំនាក់ទំនង និងព័ត៌មានដែលអាចកំណត់អត្តសញ្ញាណផ្ទាល់ខ្លួនណាមួយទេ។ របាយការណ៍គាំងអាចត្រូវបានបិទពេលកសាងដោយលុប DSN។';

  @override
  String get privacyPasswordHeading => 'ពាក្យសម្ងាត់ & សោ';

  @override
  String get privacyPasswordBody =>
      'ពាក្យសម្ងាត់សង្គ្រោះរបស់អ្នកត្រូវបានប្រើដើម្បីទាញយកសោគ្រីបតូក្រាហ្វិកតាមរយៈ Argon2id (KDF ដែលត្រូវការអង្គចងចាំច្រើន)។ ពាក្យសម្ងាត់មិនដែលត្រូវបានបញ្ជូនទៅកន្លែងណាទេ។ ប្រសិនបើអ្នកបាត់បង់ពាក្យសម្ងាត់ គណនីរបស់អ្នកមិនអាចស្ដារបានទេ — គ្មានម៉ាស៊ីនមេដើម្បីកំណត់វាឡើងវិញ។';

  @override
  String get privacyFontsHeading => 'ពុម្ពអក្សរ';

  @override
  String get privacyFontsBody =>
      'Pulse រួមបញ្ចូលពុម្ពអក្សរទាំងអស់ក្នុងម៉ាស៊ីន។ គ្មានសំណើត្រូវបានធ្វើទៅ Google Fonts ឬសេវាពុម្ពអក្សរខាងក្រៅណាមួយទេ។';

  @override
  String get privacyThirdPartyHeading => 'សេវាភាគីទីបី';

  @override
  String get privacyThirdPartyBody =>
      'Pulse មិនរួមបញ្ចូលជាមួយបណ្តាញផ្សាយពាណិជ្ជកម្ម អ្នកផ្គត់ផ្គង់ការវិភាគ វេទិកាប្រព័ន្ធផ្សព្វផ្សាយសង្គម ឬអ្នកកែវែកទិន្នន័យណាមួយទេ។ ការតភ្ជាប់បណ្តាញតែមួយគត់គឺទៅ relays ដឹកជញ្ជូនដែលអ្នកកំណត់រចនាសម្ព័ន្ធ។';

  @override
  String get privacyOpenSourceHeading => 'កូដបើកចំហ';

  @override
  String get privacyOpenSourceBody =>
      'Pulse គឺជាកម្មវិធីកូដបើកចំហ។ អ្នកអាចត្រួតពិនិត្យកូដប្រភពពេញលេញដើម្បីផ្ទៀងផ្ទាត់ការអះអាងឯកជនភាពទាំងនេះ។';

  @override
  String get privacyContactHeading => 'ទំនាក់ទំនង';

  @override
  String get privacyContactBody =>
      'សម្រាប់សំណួរទាក់ទងនឹងឯកជនភាព សូមបើក issue នៅលើឃ្លាំងគម្រោង។';

  @override
  String get privacyLastUpdated => 'បានធ្វើបច្ចុប្បន្នភាពចុងក្រោយ: មីនា 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'ការរក្សាទុកបានបរាជ័យ: $error';
  }

  @override
  String get themeEngineTitle => 'ម៉ាស៊ីនធីម';

  @override
  String get torBuiltInTitle => 'Tor ដែលមានស្រាប់';

  @override
  String get torConnectedSubtitle =>
      'បានតភ្ជាប់ — Nostr បញ្ជូនតាមរយៈ 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'កំពុងតភ្ជាប់… $pct%';
  }

  @override
  String get torNotRunning =>
      'មិនកំពុងដំណើរការ — ចុចប៊ូតុងដើម្បីចាប់ផ្តើមឡើងវិញ';

  @override
  String get torDescription =>
      'បញ្ជូន Nostr តាមរយៈ Tor (Snowflake សម្រាប់បណ្តាញដែលត្រូវបានត្រួតពិនិត្យ)';

  @override
  String get torNetworkDiagnostics => 'ការវិនិច្ឆ័យបណ្តាញ';

  @override
  String get torTransportLabel => 'ការដឹកជញ្ជូន: ';

  @override
  String get torPtAuto => 'ស្វ័យប្រវត្តិ';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'ធម្មតា';

  @override
  String get torTimeoutLabel => 'ពេលវេលាផុត: ';

  @override
  String get torInfoDescription =>
      'នៅពេលបើក ការតភ្ជាប់ WebSocket របស់ Nostr ត្រូវបានបញ្ជូនតាមរយៈ Tor (SOCKS5)។ Tor Browser ស្តាប់នៅ 127.0.0.1:9150។ ដេមិន tor ឯករាជ្យប្រើ port 9050។ ការតភ្ជាប់ Firebase មិនត្រូវបានប៉ះពាល់ទេ។';

  @override
  String get torRouteNostrTitle => 'បញ្ជូន Nostr តាមរយៈ Tor';

  @override
  String get torManagedByBuiltin => 'គ្រប់គ្រងដោយ Tor ដែលមានស្រាប់';

  @override
  String get torActiveRouting =>
      'សកម្ម — ចរាចរណ៍ Nostr ត្រូវបានបញ្ជូនតាមរយៈ Tor';

  @override
  String get torDisabled => 'បានបិទ';

  @override
  String get torProxySocks5 => 'Tor Proxy (SOCKS5)';

  @override
  String get torProxyHostLabel => 'ម៉ាស៊ីន Proxy';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser: port 9150  •  ដេមិន tor: port 9050';

  @override
  String get i2pProxySocks5 => 'I2P Proxy (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P ប្រើ SOCKS5 នៅ port 4447 ជាលំនាំដើម។ តភ្ជាប់ទៅ Nostr relay តាមរយៈ I2P outproxy (ឧ. relay.damus.i2p) ដើម្បីទំនាក់ទំនងជាមួយអ្នកប្រើនៅលើការដឹកជញ្ជូនណាមួយ។ Tor មានអាទិភាពពេលទាំងពីរត្រូវបានបើក។';

  @override
  String get i2pRouteNostrTitle => 'បញ្ជូន Nostr តាមរយៈ I2P';

  @override
  String get i2pActiveRouting =>
      'សកម្ម — ចរាចរណ៍ Nostr ត្រូវបានបញ្ជូនតាមរយៈ I2P';

  @override
  String get i2pDisabled => 'បានបិទ';

  @override
  String get i2pProxyHostLabel => 'ម៉ាស៊ីន Proxy';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'I2P Router SOCKS5 port លំនាំដើម: 4447';

  @override
  String get customProxySocks5 => 'Proxy ផ្ទាល់ខ្លួន (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Proxy ផ្ទាល់ខ្លួនបញ្ជូនចរាចរណ៍តាមរយៈ V2Ray/Xray/Shadowsocks របស់អ្នក។ CF Worker ដើរតួជា relay proxy ផ្ទាល់ខ្លួនលើ Cloudflare CDN — GFW ឃើញ *.workers.dev មិនមែន relay ពិត។';

  @override
  String get customSocks5ProxyTitle => 'Proxy SOCKS5 ផ្ទាល់ខ្លួន';

  @override
  String get customProxyActive => 'សកម្ម — ចរាចរណ៍ត្រូវបានបញ្ជូនតាមរយៈ SOCKS5';

  @override
  String get customProxyDisabled => 'បានបិទ';

  @override
  String get customProxyHostLabel => 'ម៉ាស៊ីន Proxy';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'ដែន Worker (ជម្រើស)';

  @override
  String get customWorkerHelpTitle =>
      'របៀបដាក់ពង្រាយ CF Worker relay (ឥតគិតថ្លៃ)';

  @override
  String get customWorkerScriptCopied => 'បានចម្លងស្គ្រីប!';

  @override
  String get customWorkerStep1 =>
      '1. ទៅ dash.cloudflare.com → Workers & Pages\n2. Create Worker → បិទភ្ជាប់ស្គ្រីបនេះ:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → ចម្លងដែន (ឧ. my-relay.user.workers.dev)\n4. បិទភ្ជាប់ដែនខាងលើ → រក្សាទុក\n\nកម្មវិធីតភ្ជាប់ស្វ័យប្រវត្តិ: wss://domain/?r=relay_url\nGFW ឃើញ: ការតភ្ជាប់ទៅ *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'បានតភ្ជាប់ — SOCKS5 នៅ 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'កំពុងតភ្ជាប់…';

  @override
  String get psiphonNotRunning =>
      'មិនកំពុងដំណើរការ — ចុចប៊ូតុងដើម្បីចាប់ផ្តើមឡើងវិញ';

  @override
  String get psiphonDescription =>
      'ផ្លូវរូងក្រោមដីលឿន (~3s bootstrap, 2000+ VPS វិលជុំ)';

  @override
  String get turnCommunityServers => 'TURN Servers សហគមន៍';

  @override
  String get turnCustomServer => 'TURN Server ផ្ទាល់ខ្លួន (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN servers បញ្ជូនតែស្ទ្រីមដែលបានអ៊ិនគ្រីបរួចរាល់ប៉ុណ្ណោះ (DTLS-SRTP)។ ប្រតិបត្តិករ relay អាចមើលឃើញ IP និងបរិមាណចរាចរណ៍របស់អ្នក ប៉ុន្តែមិនអាចឌិគ្រីបការហៅបានទេ។ TURN ត្រូវបានប្រើតែពេលការតភ្ជាប់ P2P ផ្ទាល់បរាជ័យ (~15–20% នៃការតភ្ជាប់)។';

  @override
  String get turnFreeLabel => 'ឥតគិតថ្លៃ';

  @override
  String get turnServerUrlLabel => 'URL របស់ TURN Server';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 or turns:...';

  @override
  String get turnUsernameLabel => 'ឈ្មោះអ្នកប្រើ';

  @override
  String get turnPasswordLabel => 'ពាក្យសម្ងាត់';

  @override
  String get turnOptionalHint => 'ជម្រើស';

  @override
  String get turnCustomInfo =>
      'ដំឡើង coturn នៅលើ VPS \$5/ខែណាមួយសម្រាប់ការគ្រប់គ្រងអតិបរមា។ ព័ត៌មានសម្ងាត់ត្រូវបានរក្សាទុកក្នុងម៉ាស៊ីន។';

  @override
  String get themePickerAppearance => 'រូបរាង';

  @override
  String get themePickerAccentColor => 'ពណ៌បន្លិច';

  @override
  String get themeModeLight => 'ភ្លឺ';

  @override
  String get themeModeDark => 'ងងឹត';

  @override
  String get themeModeSystem => 'ប្រព័ន្ធ';

  @override
  String get themeDynamicPresets => 'ការកំណត់ជាមុន';

  @override
  String get themeDynamicPrimaryColor => 'ពណ៌ចម្បង';

  @override
  String get themeDynamicBorderRadius => 'កោនស៊ុម';

  @override
  String get themeDynamicFont => 'ពុម្ពអក្សរ';

  @override
  String get themeDynamicAppearance => 'រូបរាង';

  @override
  String get themeDynamicUiStyle => 'រចនាប័ទ្ម UI';

  @override
  String get themeDynamicUiStyleDescription =>
      'គ្រប់គ្រងរបៀបដែលប្រអប់ ប៊ូតុងបិទបើក និងសូចនាករមើលទៅ។';

  @override
  String get themeDynamicSharp => 'មុតស្រួច';

  @override
  String get themeDynamicRound => 'មូល';

  @override
  String get themeDynamicModeDark => 'ងងឹត';

  @override
  String get themeDynamicModeLight => 'ភ្លឺ';

  @override
  String get themeDynamicModeAuto => 'ស្វ័យប្រវត្តិ';

  @override
  String get themeDynamicPlatformAuto => 'ស្វ័យប្រវត្តិ';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'URL Firebase មិនត្រឹមត្រូវ។ រំពឹងថា https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'URL Relay មិនត្រឹមត្រូវ។ រំពឹងថា wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'URL ម៉ាស៊ីនមេ Pulse មិនត្រឹមត្រូវ។ រំពឹងថា https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'URL ម៉ាស៊ីនមេ';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'កូដអញ្ជើញ';

  @override
  String get providerPulseInviteHint => 'កូដអញ្ជើញ (ប្រសិនបើត្រូវការ)';

  @override
  String get providerPulseInfo =>
      'Relay ដែលដំឡើងដោយខ្លួនឯង។ សោទាញយកពីពាក្យសម្ងាត់សង្គ្រោះរបស់អ្នក។';

  @override
  String get providerScreenTitle => 'ប្រអប់សំបុត្រចូល';

  @override
  String get providerSecondaryInboxesHeader => 'ប្រអប់សំបុត្រចូលបន្ទាប់បន្សំ';

  @override
  String get providerSecondaryInboxesInfo =>
      'ប្រអប់សំបុត្រចូលបន្ទាប់បន្សំទទួលសារក្នុងពេលតែមួយសម្រាប់ភាពស្ទួន។';

  @override
  String get providerRemoveTooltip => 'លុបចេញ';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... ឬ hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... ឬសោឯកជន hex';

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
  String get emojiNoRecent => 'គ្មានអ៊ីមូជីថ្មីៗ';

  @override
  String get emojiSearchHint => 'ស្វែងរកអ៊ីមូជី...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'ចុចដើម្បីជជែក';

  @override
  String get imageViewerSaveToDownloads => 'រក្សាទុកទៅ Downloads';

  @override
  String imageViewerSavedTo(String path) {
    return 'បានរក្សាទុកនៅ $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'ភាសា';

  @override
  String get settingsLanguageSubtitle => 'ភាសាបង្ហាញកម្មវិធី';

  @override
  String get settingsLanguageSystem => 'លំនាំដើមប្រព័ន្ធ';

  @override
  String get onboardingLanguageTitle => 'ជ្រើសរើសភាសារបស់អ្នក';

  @override
  String get onboardingLanguageSubtitle =>
      'អ្នកអាចផ្លាស់ប្តូរនេះពេលក្រោយក្នុងការកំណត់';

  @override
  String get videoNoteRecord => 'ថតសារវីដេអូ';

  @override
  String get videoNoteTapToRecord => 'ចុចដើម្បីថត';

  @override
  String get videoNoteTapToStop => 'ចុចដើម្បីឈប់';

  @override
  String get videoNoteCameraPermission => 'បានបដិសេធការអនុញ្ញាតកាមេរ៉ា';

  @override
  String get videoNoteMaxDuration => 'អតិបរមា 30 វិនាទី';

  @override
  String get videoNoteNotSupported =>
      'កំណត់ចំណាំវីដេអូមិនត្រូវបានគាំទ្រនៅលើវេទិកានេះទេ';

  @override
  String get navChats => 'ការជជែក';

  @override
  String get navUpdates => 'បច្ចុប្បន្នភាព';

  @override
  String get navCalls => 'ការហៅ';

  @override
  String get filterAll => 'ទាំងអស់';

  @override
  String get filterUnread => 'មិនទាន់អាន';

  @override
  String get filterGroups => 'ក្រុម';

  @override
  String get callsNoRecent => 'គ្មានការហៅថ្មីៗ';

  @override
  String get callsEmptySubtitle => 'ប្រវត្តិការហៅរបស់អ្នកនឹងបង្ហាញនៅទីនេះ';

  @override
  String get appBarEncrypted => 'ការអ៊ិនគ្រីបពីចុងដល់ចុង';

  @override
  String get newStatus => 'ស្ថានភាពថ្មី';

  @override
  String get newCall => 'ការហៅថ្មី';
}
