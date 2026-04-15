// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sinhala Sinhalese (`si`).
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([String locale = 'si']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'පණිවිඩ සොයන්න...';

  @override
  String get search => 'සොයන්න';

  @override
  String get clearSearch => 'සෙවුම හිස් කරන්න';

  @override
  String get closeSearch => 'සෙවුම වසන්න';

  @override
  String get moreOptions => 'තවත් විකල්ප';

  @override
  String get back => 'ආපසු';

  @override
  String get cancel => 'අවලංගු කරන්න';

  @override
  String get close => 'වසන්න';

  @override
  String get confirm => 'තහවුරු කරන්න';

  @override
  String get remove => 'ඉවත් කරන්න';

  @override
  String get save => 'සුරකින්න';

  @override
  String get add => 'එක් කරන්න';

  @override
  String get copy => 'පිටපත් කරන්න';

  @override
  String get skip => 'මඟ හරින්න';

  @override
  String get done => 'අවසන්';

  @override
  String get apply => 'යොදන්න';

  @override
  String get export => 'අපනයනය';

  @override
  String get import => 'ආනයනය';

  @override
  String get homeNewGroup => 'නව සමූහය';

  @override
  String get homeSettings => 'සැකසුම්';

  @override
  String get homeSearching => 'පණිවිඩ සොයමින්...';

  @override
  String get homeNoResults => 'ප්‍රතිඵල හමු නොවීය';

  @override
  String get homeNoChatHistory => 'කතාබහ ඉතිහාසයක් තවම නැත';

  @override
  String homeTransportSwitched(String address) {
    return 'ප්‍රවාහනය මාරු විය → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name ඇමතුමක් ලබයි...';
  }

  @override
  String get homeAccept => 'පිළිගන්න';

  @override
  String get homeDecline => 'ප්‍රතික්ෂේප කරන්න';

  @override
  String get homeLoadEarlier => 'පෙර පණිවිඩ පූරණය කරන්න';

  @override
  String get homeChats => 'කතාබහ';

  @override
  String get homeSelectConversation => 'සංවාදයක් තෝරන්න';

  @override
  String get homeNoChatsYet => 'තවම කතාබහ නැත';

  @override
  String get homeAddContactToStart =>
      'කතාබහ ආරම්භ කිරීමට සම්බන්ධතාවක් එක් කරන්න';

  @override
  String get homeNewChat => 'නව කතාබහ';

  @override
  String get homeNewChatTooltip => 'නව කතාබහ';

  @override
  String get homeIncomingCallTitle => 'පැමිණෙන ඇමතුම';

  @override
  String get homeIncomingGroupCallTitle => 'පැමිණෙන සමූහ ඇමතුම';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — සමූහ ඇමතුමක් පැමිණෙයි';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return '\"$query\" සමඟ ගැළපෙන කතාබහ නැත';
  }

  @override
  String get homeSectionChats => 'කතාබහ';

  @override
  String get homeSectionMessages => 'පණිවිඩ';

  @override
  String get homeDbEncryptionUnavailable =>
      'දත්ත සමුදාය සංකේතනය නොමැත — සම්පූර්ණ ආරක්ෂාව සඳහා SQLCipher ස්ථාපනය කරන්න';

  @override
  String get chatFileTooLargeGroup =>
      'සමූහ කතාබහවල 512 KB ට වැඩි ගොනු සහය නොදක්වයි';

  @override
  String get chatLargeFile => 'විශාල ගොනුව';

  @override
  String get chatCancel => 'අවලංගු කරන්න';

  @override
  String get chatSend => 'යවන්න';

  @override
  String get chatFileTooLarge => 'ගොනුව ඉතා විශාලයි — උපරිම ප්‍රමාණය 100 MB';

  @override
  String get chatMicDenied => 'මයික්‍රෆෝන අවසරය ප්‍රතික්ෂේප විය';

  @override
  String get chatVoiceFailed =>
      'හඬ පණිවිඩය සුරැකීමට අසමත් විය — ලබා ගත හැකි ගබඩාව පරීක්ෂා කරන්න';

  @override
  String get chatScheduleFuture => 'නියමිත වේලාව අනාගතයේ විය යුතුය';

  @override
  String get chatToday => 'අද';

  @override
  String get chatYesterday => 'ඊයේ';

  @override
  String get chatEdited => 'සංස්කරණය කළ';

  @override
  String get chatYou => 'ඔබ';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'මෙම ගොනුව $size MB වේ. සමහර ජාල වල විශාල ගොනු යැවීම මන්දගාමී විය හැක. ඉදිරියට යන්නද?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return '$nameගේ ආරක්ෂක යතුර වෙනස් විය. සත්‍යාපනය සඳහා තට්ටු කරන්න.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return '$nameට පණිවිඩය සංකේතනය කළ නොහැකි විය — පණිවිඩය යවා නැත.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return '$name සඳහා ආරක්ෂක අංකය වෙනස් විය. සත්‍යාපනය සඳහා තට්ටු කරන්න.';
  }

  @override
  String get chatNoMessagesFound => 'පණිවිඩ හමු නොවීය';

  @override
  String get chatMessagesE2ee => 'පණිවිඩ අන්තයේ සිට අන්තය දක්වා සංකේතනය කර ඇත';

  @override
  String get chatSayHello => 'ආයුබෝවන් කියන්න';

  @override
  String get appBarOnline => 'සබැඳි';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'ටයිප් කරමින්';

  @override
  String get appBarSearchMessages => 'පණිවිඩ සොයන්න...';

  @override
  String get appBarMute => 'නිහඬ කරන්න';

  @override
  String get appBarUnmute => 'නිහඬ ඉවත් කරන්න';

  @override
  String get appBarMedia => 'මාධ්‍ය';

  @override
  String get appBarDisappearing => 'අතුරුදහන් වන පණිවිඩ';

  @override
  String get appBarDisappearingOn => 'අතුරුදහන්: සක්‍රිය';

  @override
  String get appBarGroupSettings => 'සමූහ සැකසුම්';

  @override
  String get appBarSearchTooltip => 'පණිවිඩ සොයන්න';

  @override
  String get appBarVoiceCall => 'හඬ ඇමතුම';

  @override
  String get appBarVideoCall => 'වීඩියෝ ඇමතුම';

  @override
  String get inputMessage => 'පණිවිඩය...';

  @override
  String get inputAttachFile => 'ගොනුවක් අමුණන්න';

  @override
  String get inputSendMessage => 'පණිවිඩය යවන්න';

  @override
  String get inputRecordVoice => 'හඬ පණිවිඩයක් පටිගත කරන්න';

  @override
  String get inputSendVoice => 'හඬ පණිවිඩය යවන්න';

  @override
  String get inputCancelReply => 'පිළිතුර අවලංගු කරන්න';

  @override
  String get inputCancelEdit => 'සංස්කරණය අවලංගු කරන්න';

  @override
  String get inputCancelRecording => 'පටිගත කිරීම අවලංගු කරන්න';

  @override
  String get inputRecording => 'පටිගත කරමින්…';

  @override
  String get inputEditingMessage => 'පණිවිඩය සංස්කරණය කරමින්';

  @override
  String get inputPhoto => 'ඡායාරූපය';

  @override
  String get inputVoiceMessage => 'හඬ පණිවිඩය';

  @override
  String get inputFile => 'ගොනුව';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ක්',
      one: 'ක්',
    );
    return 'නියමිත පණිවිඩ $count$_temp0';
  }

  @override
  String get callInitializing => 'ඇමතුම ආරම්භ කරමින්…';

  @override
  String get callConnecting => 'සම්බන්ධ වෙමින්…';

  @override
  String get callConnectingRelay => 'සම්බන්ධ වෙමින් (relay)…';

  @override
  String get callSwitchingRelay => 'Relay මාදිලියට මාරු වෙමින්…';

  @override
  String get callConnectionFailed => 'සම්බන්ධතාවය අසාර්ථක විය';

  @override
  String get callReconnecting => 'නැවත සම්බන්ධ වෙමින්…';

  @override
  String get callEnded => 'ඇමතුම අවසන් විය';

  @override
  String get callLive => 'සජීව';

  @override
  String get callEnd => 'අවසන්';

  @override
  String get callEndCall => 'ඇමතුම අවසන් කරන්න';

  @override
  String get callMute => 'නිහඬ කරන්න';

  @override
  String get callUnmute => 'නිහඬ ඉවත් කරන්න';

  @override
  String get callSpeaker => 'ස්පීකරය';

  @override
  String get callCameraOn => 'කැමරාව සක්‍රිය';

  @override
  String get callCameraOff => 'කැමරාව අක්‍රිය';

  @override
  String get callShareScreen => 'තිරය බෙදා ගන්න';

  @override
  String get callStopShare => 'බෙදාගැනීම නවත්වන්න';

  @override
  String callTorBackup(String duration) {
    return 'Tor උපස්ථ · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor උපස්ථය සක්‍රියයි — ප්‍රාථමික මාර්ගය නොමැත';

  @override
  String get callDirectFailed =>
      'සෘජු සම්බන්ධතාවය අසාර්ථක විය — relay මාදිලියට මාරු වෙමින්…';

  @override
  String get callTurnUnreachable =>
      'TURN සේවාදායක වෙත ළඟා විය නොහැක. සැකසුම් → උසස් තුළ අභිරුචි TURN එක් කරන්න.';

  @override
  String get callRelayMode => 'Relay මාදිලිය සක්‍රියයි (සීමිත ජාලය)';

  @override
  String get callStarting => 'ඇමතුම ආරම්භ කරමින්…';

  @override
  String get callConnectingToGroup => 'සමූහයට සම්බන්ධ වෙමින්…';

  @override
  String get callGroupOpenedInBrowser => 'සමූහ ඇමතුම බ්‍රවුසරයේ විවෘත විය';

  @override
  String get callCouldNotOpenBrowser => 'බ්‍රවුසරය විවෘත කළ නොහැකි විය';

  @override
  String get callInviteLinkSent =>
      'ආරාධනා සබැඳිය සියලුම සමූහ සාමාජිකයින්ට යවන ලදී.';

  @override
  String get callOpenLinkManually =>
      'ඉහත සබැඳිය අතින් විවෘත කරන්න හෝ නැවත උත්සාහ කිරීමට තට්ටු කරන්න.';

  @override
  String get callJitsiNotE2ee =>
      'Jitsi ඇමතුම් අන්තයේ සිට අන්තය දක්වා සංකේතනය කර නැත';

  @override
  String get callRetryOpenBrowser => 'බ්‍රවුසරය නැවත විවෘත කරන්න';

  @override
  String get callClose => 'වසන්න';

  @override
  String get callCamOn => 'කැමරාව සක්‍රිය';

  @override
  String get callCamOff => 'කැමරාව අක්‍රිය';

  @override
  String get noConnection => 'සම්බන්ධතාවයක් නැත — පණිවිඩ පෝලිම්ගත වේ';

  @override
  String get connected => 'සම්බන්ධයි';

  @override
  String get connecting => 'සම්බන්ධ වෙමින්…';

  @override
  String get disconnected => 'විසන්ධි වී ඇත';

  @override
  String get offlineBanner =>
      'සම්බන්ධතාවයක් නැත — නැවත සබැඳි වූ විට පණිවිඩ යවනු ලැබේ';

  @override
  String get lanModeBanner => 'LAN මාදිලිය — අන්තර්ජාලය නැත · දේශීය ජාලය පමණි';

  @override
  String get probeCheckingNetwork => 'ජාල සම්බන්ධතාවය පරීක්ෂා කරමින්…';

  @override
  String get probeDiscoveringRelays => 'ප්‍රජා නාමාවලි හරහා relay සොයමින්…';

  @override
  String get probeStartingTor => 'Bootstrap සඳහා Tor ආරම්භ කරමින්…';

  @override
  String get probeFindingRelaysTor => 'Tor හරහා ළඟා විය හැකි relay සොයමින්…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ක්',
      one: 'ක්',
    );
    return 'ජාලය සූදානම් — relay $count$_temp0 හමු විය';
  }

  @override
  String get probeNoRelaysFound =>
      'ළඟා විය හැකි relay හමු නොවීය — පණිවිඩ ප්‍රමාද විය හැක';

  @override
  String get jitsiWarningTitle => 'අන්තයේ සිට අන්තය දක්වා සංකේතනය කර නැත';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet ඇමතුම් Pulse මඟින් සංකේතනය කරනු නොලැබේ. සංවේදී නොවන සංවාද සඳහා පමණක් භාවිතා කරන්න.';

  @override
  String get jitsiConfirm => 'කෙසේ වෙතත් සම්බන්ධ වන්න';

  @override
  String get jitsiGroupWarningTitle => 'අන්තයේ සිට අන්තය දක්වා සංකේතනය කර නැත';

  @override
  String get jitsiGroupWarningBody =>
      'මෙම ඇමතුමට ගොඩනඟන ලද සංකේතිත mesh සඳහා සහභාගිවන්නන් වැඩිය.\n\nJitsi Meet සබැඳියක් ඔබේ බ්‍රවුසරයේ විවෘත වේ. Jitsi අන්තයේ සිට අන්තය දක්වා සංකේතනය කර නැත — සේවාදායකයට ඔබේ ඇමතුම දැක ගත හැක.';

  @override
  String get jitsiContinueAnyway => 'කෙසේ වෙතත් ඉදිරියට යන්න';

  @override
  String get retry => 'නැවත උත්සාහ කරන්න';

  @override
  String get setupCreateAnonymousAccount => 'නිර්නාමික ගිණුමක් සාදන්න';

  @override
  String get setupTapToChangeColor => 'වර්ණය වෙනස් කිරීමට තට්ටු කරන්න';

  @override
  String get setupReqMinLength => 'අවම වශයෙන් අකුරු 16ක්';

  @override
  String get setupReqVariety => '4 න් 3: කැපිටල්, කුඩා අකුරු, ඉලක්කම්, සංකේත';

  @override
  String get setupReqMatch => 'මුරපද ගැළපේ';

  @override
  String get setupYourNickname => 'ඔබේ අන්වර්ථ නාමය';

  @override
  String get setupRecoveryPassword => 'ප්‍රතිසාධන මුරපදය (අවම 16)';

  @override
  String get setupConfirmPassword => 'මුරපදය තහවුරු කරන්න';

  @override
  String get setupMin16Chars => 'අවම අක්ෂර 16ක්';

  @override
  String get setupPasswordsDoNotMatch => 'මුරපද නොගැලපේ';

  @override
  String get setupEntropyWeak => 'දුර්වල';

  @override
  String get setupEntropyOk => 'හරි';

  @override
  String get setupEntropyStrong => 'ශක්තිමත්';

  @override
  String get setupEntropyWeakNeedsVariety => 'දුර්වල (අක්ෂර වර්ග 3ක් අවශ්‍යයි)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits බිට්)';
  }

  @override
  String get setupPasswordWarning =>
      'මෙම මුරපදය ඔබේ ගිණුම ප්‍රතිසාධනය කිරීමට ඇති එකම ක්‍රමයයි. සේවාදායකයක් නැත — මුරපද යළි පිහිටුවීමක් නැත. මතක තබා ගන්න හෝ ලියා තබන්න.';

  @override
  String get setupCreateAccount => 'ගිණුම සාදන්න';

  @override
  String get setupAlreadyHaveAccount => 'දැනටමත් ගිණුමක් තිබේද? ';

  @override
  String get setupRestore => 'ප්‍රතිසාධනය →';

  @override
  String get restoreTitle => 'ගිණුම ප්‍රතිසාධනය කරන්න';

  @override
  String get restoreInfoBanner =>
      'ඔබේ ප්‍රතිසාධන මුරපදය ඇතුළත් කරන්න — ඔබේ ලිපිනය (Nostr + Session) ස්වයංක්‍රීයව ප්‍රතිසාධනය වේ. සම්බන්ධතා සහ පණිවිඩ දේශීයව පමණක් ගබඩා කර තිබුණි.';

  @override
  String get restoreNewNickname => 'නව අන්වර්ථ නාමය (පසුව වෙනස් කළ හැක)';

  @override
  String get restoreButton => 'ගිණුම ප්‍රතිසාධනය කරන්න';

  @override
  String get lockTitle => 'Pulse අගුලු දමා ඇත';

  @override
  String get lockSubtitle => 'ඉදිරියට යාමට ඔබේ මුරපදය ඇතුළත් කරන්න';

  @override
  String get lockPasswordHint => 'මුරපදය';

  @override
  String get lockUnlock => 'අගුලු හරින්න';

  @override
  String get lockPanicHint =>
      'මුරපදය අමතක ද? සියලුම දත්ත මකා දැමීමට ඔබේ භීති යතුර ඇතුළත් කරන්න.';

  @override
  String get lockTooManyAttempts => 'උත්සාහයන් වැඩියි. සියලුම දත්ත මකා දමමින්…';

  @override
  String get lockWrongPassword => 'වැරදි මුරපදය';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'වැරදි මුරපදය — $attempts/$max උත්සාහයන්';
  }

  @override
  String get onboardingSkip => 'මඟ හරින්න';

  @override
  String get onboardingNext => 'ඊළඟ';

  @override
  String get onboardingGetStarted => 'ගිණුම සාදන්න';

  @override
  String get onboardingWelcomeTitle => 'Pulse වෙත සාදරයෙන් පිළිගනිමු';

  @override
  String get onboardingWelcomeBody =>
      'විමධ්‍යගත, අන්තයේ සිට අන්තය දක්වා සංකේතනය කළ පණිවිඩකරුවෙකි.\n\nමධ්‍යම සේවාදායක නැත. දත්ත එකතු කිරීම නැත. පසුබිම් දොරවල් නැත.\nඔබේ සංවාද ඔබට පමණක් අයත් වේ.';

  @override
  String get onboardingTransportTitle => 'ප්‍රවාහන-අද්විතීය';

  @override
  String get onboardingTransportBody =>
      'Firebase, Nostr, හෝ දෙකම එකවර භාවිතා කරන්න.\n\nපණිවිඩ ස්වයංක්‍රීයව ජාල හරහා මාර්ගගත වේ. වාරණ ප්‍රතිරෝධය සඳහා Tor සහ I2P සහාය ගොඩනඟා ඇත.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'සෑම පණිවිඩයක්ම Signal Protocol (Double Ratchet + X3DH) මඟින් forward secrecy සඳහා සංකේතනය කරයි.\n\nමීට අමතරව Kyber-1024 — NIST-ප්‍රමිත post-quantum ඇල්ගොරිතමයක් — මඟින් ආවරණය කරනු ලබයි, අනාගත ක්වොන්ටම් පරිගණක වලින් ආරක්ෂා කරයි.';

  @override
  String get onboardingKeysTitle => 'ඔබේ යතුරු ඔබටම අයිතියි';

  @override
  String get onboardingKeysBody =>
      'ඔබේ හැඳුනුම් යතුරු කිසිවිටක ඔබේ උපාංගයෙන් පිටතට නොයයි.\n\nSignal ඇඟිලි සලකුණු මඟින් සම්බන්ධතා පිටත-කලාපයෙන් සත්‍යාපනය කිරීමට ඉඩ දෙයි. TOFU (Trust On First Use) ස්වයංක්‍රීයව යතුරු වෙනස්වීම් හඳුනා ගනී.';

  @override
  String get onboardingThemeTitle => 'ඔබේ පෙනුම තෝරන්න';

  @override
  String get onboardingThemeBody =>
      'තේමාවක් සහ උච්චාරණ වර්ණයක් තෝරන්න. ඔබට මෙය සැකසුම් වලින් ඕනෑම වේලාවක වෙනස් කළ හැක.';

  @override
  String get contactsNewChat => 'නව කතාබහ';

  @override
  String get contactsAddContact => 'සම්බන්ධතාවක් එක් කරන්න';

  @override
  String get contactsSearchHint => 'සොයන්න...';

  @override
  String get contactsNewGroup => 'නව සමූහය';

  @override
  String get contactsNoContactsYet => 'තවම සම්බන්ධතා නැත';

  @override
  String get contactsAddHint => 'යමෙකුගේ ලිපිනය එක් කිරීමට + තට්ටු කරන්න';

  @override
  String get contactsNoMatch => 'ගැළපෙන සම්බන්ධතා නැත';

  @override
  String get contactsRemoveTitle => 'සම්බන්ධතාවය ඉවත් කරන්න';

  @override
  String contactsRemoveMessage(String name) {
    return '$name ඉවත් කරන්නද?';
  }

  @override
  String get contactsRemove => 'ඉවත් කරන්න';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ක්',
      one: 'ක්',
    );
    return 'සම්බන්ධතා $count$_temp0';
  }

  @override
  String get bubbleOpenLink => 'සබැඳිය විවෘත කරන්න';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'මෙම URL ඔබේ බ්‍රවුසරයේ විවෘත කරන්නද?\n\n$url';
  }

  @override
  String get bubbleOpen => 'විවෘත කරන්න';

  @override
  String get bubbleSecurityWarning => 'ආරක්ෂක අනතුරු ඇඟවීම';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" ක්‍රියාත්මක කළ හැකි ගොනු වර්ගයකි. සුරැකීම සහ ක්‍රියාත්මක කිරීම ඔබේ උපාංගයට හානි කළ හැක. කෙසේ වෙතත් සුරකින්නද?';
  }

  @override
  String get bubbleSaveAnyway => 'කෙසේ වෙතත් සුරකින්න';

  @override
  String bubbleSavedTo(String path) {
    return '$path වෙත සුරකින ලදී';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'සුරැකීම අසාර්ථක විය: $error';
  }

  @override
  String get bubbleNotEncrypted => 'සංකේතනය කර නැත';

  @override
  String get bubbleCorruptedImage => '[දූෂිත රූපය]';

  @override
  String get bubbleReplyPhoto => 'ඡායාරූපය';

  @override
  String get bubbleReplyVoice => 'හඬ පණිවිඩය';

  @override
  String get bubbleReplyVideo => 'වීඩියෝ පණිවිඩය';

  @override
  String bubbleReadBy(String names) {
    return '$names විසින් කියවන ලදී';
  }

  @override
  String bubbleReadByCount(int count) {
    return '$count දෙනා කියවා ඇත';
  }

  @override
  String get chatTileTapToStart => 'කතාබහ ආරම්භ කිරීමට තට්ටු කරන්න';

  @override
  String get chatTileMessageSent => 'පණිවිඩය යවන ලදී';

  @override
  String get chatTileEncryptedMessage => 'සංකේතනය කළ පණිවිඩය';

  @override
  String chatTileYouPrefix(String text) {
    return 'ඔබ: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 හඬ පණිවිඩය';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 හඬ පණිවිඩය ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'සංකේතනය කළ පණිවිඩය';

  @override
  String get groupNewGroup => 'නව සමූහය';

  @override
  String get groupGroupName => 'සමූහ නාමය';

  @override
  String get groupSelectMembers => 'සාමාජිකයන් තෝරන්න (අවම 2)';

  @override
  String get groupNoContactsYet =>
      'තවම සම්බන්ධතා නැත. පළමුව සම්බන්ධතා එක් කරන්න.';

  @override
  String get groupCreate => 'සාදන්න';

  @override
  String get groupLabel => 'සමූහය';

  @override
  String get profileVerifyIdentity => 'අනන්‍යතාවය සත්‍යාපනය කරන්න';

  @override
  String profileVerifyInstructions(String name) {
    return 'මෙම ඇඟිලි සලකුණු $name සමඟ හඬ ඇමතුමකින් හෝ පුද්ගලිකව සංසන්දනය කරන්න. දෙකම දෙපාර්ශ්වයේම උපාංගවල ගැළපෙන්නේ නම්, \"සත්‍යාපිත ලෙස සලකුණු කරන්න\" තට්ටු කරන්න.';
  }

  @override
  String get profileTheirKey => 'ඔවුන්ගේ යතුර';

  @override
  String get profileYourKey => 'ඔබේ යතුර';

  @override
  String get profileRemoveVerification => 'සත්‍යාපනය ඉවත් කරන්න';

  @override
  String get profileMarkAsVerified => 'සත්‍යාපිත ලෙස සලකුණු කරන්න';

  @override
  String get profileAddressCopied => 'ලිපිනය පිටපත් කරන ලදී';

  @override
  String get profileNoContactsToAdd =>
      'එක් කිරීමට සම්බන්ධතා නැත — සියල්ල දැනටමත් සාමාජිකයන් වේ';

  @override
  String get profileAddMembers => 'සාමාජිකයන් එක් කරන්න';

  @override
  String profileAddCount(int count) {
    return 'එක් කරන්න ($count)';
  }

  @override
  String get profileRenameGroup => 'සමූහය නැවත නම් කරන්න';

  @override
  String get profileRename => 'නැවත නම් කරන්න';

  @override
  String get profileRemoveMember => 'සාමාජිකයා ඉවත් කරන්නද?';

  @override
  String profileRemoveMemberBody(String name) {
    return '$name මෙම සමූහයෙන් ඉවත් කරන්නද?';
  }

  @override
  String get profileKick => 'පිටකරන්න';

  @override
  String get profileSignalFingerprints => 'Signal ඇඟිලි සලකුණු';

  @override
  String get profileVerified => 'සත්‍යාපිතයි';

  @override
  String get profileVerify => 'සත්‍යාපනය කරන්න';

  @override
  String get profileEdit => 'සංස්කරණය';

  @override
  String get profileNoSession =>
      'තවම සැසියක් පිහිටුවා නැත — පළමුව පණිවිඩයක් යවන්න.';

  @override
  String get profileFingerprintCopied => 'ඇඟිලි සලකුණ පිටපත් කරන ලදී';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'යන්',
      one: 'යා',
    );
    return 'සාමාජික$_temp0 $count';
  }

  @override
  String get profileVerifySafetyNumber => 'ආරක්ෂක අංකය සත්‍යාපනය කරන්න';

  @override
  String get profileShowContactQr => 'සම්බන්ධතා QR පෙන්වන්න';

  @override
  String profileContactAddress(String name) {
    return '$nameගේ ලිපිනය';
  }

  @override
  String get profileExportChatHistory => 'කතාබහ ඉතිහාසය අපනයනය කරන්න';

  @override
  String profileSavedTo(String path) {
    return '$path වෙත සුරකින ලදී';
  }

  @override
  String get profileExportFailed => 'අපනයනය අසාර්ථක විය';

  @override
  String get profileClearChatHistory => 'කතාබහ ඉතිහාසය හිස් කරන්න';

  @override
  String get profileDeleteGroup => 'සමූහය මකන්න';

  @override
  String get profileDeleteContact => 'සම්බන්ධතාවය මකන්න';

  @override
  String get profileLeaveGroup => 'සමූහය හැර යන්න';

  @override
  String get profileLeaveGroupBody =>
      'ඔබ මෙම සමූහයෙන් ඉවත් කරනු ලබන අතර එය ඔබේ සම්බන්ධතා වලින් මකා දමනු ලැබේ.';

  @override
  String get groupInviteTitle => 'සමූහ ආරාධනාව';

  @override
  String groupInviteBody(String from, String group) {
    return '$from ඔබව \"$group\" හට සම්බන්ධ වීමට ආරාධනා කළේය';
  }

  @override
  String get groupInviteAccept => 'පිළිගන්න';

  @override
  String get groupInviteDecline => 'ප්‍රතික්ෂේප කරන්න';

  @override
  String get groupMemberLimitTitle => 'සහභාගිවන්නන් වැඩියි';

  @override
  String groupMemberLimitBody(int count) {
    return 'මෙම සමූහයේ සහභාගිවන්නන් $count දෙනෙක් සිටී. සංකේතිත mesh ඇමතුම් 6 දක්වා සහාය දක්වයි. විශාල සමූහ Jitsi (E2EE නොවේ) වෙත මාරු වේ.';
  }

  @override
  String get groupMemberLimitContinue => 'කෙසේ වෙතත් එක් කරන්න';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name \"$group\" හට සම්බන්ධ වීම ප්‍රතික්ෂේප කළේය';
  }

  @override
  String get transferTitle => 'වෙනත් උපාංගයකට මාරු කරන්න';

  @override
  String get transferInfoBox =>
      'ඔබේ Signal හැඳුනුම සහ Nostr යතුරු නව උපාංගයකට ගෙනයන්න.\nකතාබහ සැසි මාරු නොකෙරේ — forward secrecy ආරක්ෂා කෙරේ.';

  @override
  String get transferSendFromThis => 'මෙම උපාංගයෙන් යවන්න';

  @override
  String get transferSendSubtitle =>
      'මෙම උපාංගයේ යතුරු ඇත. නව උපාංගය සමඟ කේතයක් බෙදා ගන්න.';

  @override
  String get transferReceiveOnThis => 'මෙම උපාංගයේ ලබා ගන්න';

  @override
  String get transferReceiveSubtitle =>
      'මෙය නව උපාංගයයි. පැරණි උපාංගයෙන් කේතය ඇතුළත් කරන්න.';

  @override
  String get transferChooseMethod => 'මාරු කිරීමේ ක්‍රමය තෝරන්න';

  @override
  String get transferLan => 'LAN (එකම ජාලය)';

  @override
  String get transferLanSubtitle =>
      'වේගවත්, සෘජු. උපාංග දෙකම එකම Wi-Fi එකේ විය යුතුය.';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'පවතින Nostr relay එකක් භාවිතයෙන් ඕනෑම ජාලයක් හරහා ක්‍රියා කරයි.';

  @override
  String get transferRelayUrl => 'Relay URL';

  @override
  String get transferEnterCode => 'මාරු කිරීමේ කේතය ඇතුළත් කරන්න';

  @override
  String get transferPasteCode => 'LAN:... හෝ NOS:... කේතය මෙහි අලවන්න';

  @override
  String get transferConnect => 'සම්බන්ධ වන්න';

  @override
  String get transferGenerating => 'මාරු කිරීමේ කේතය ජනනය කරමින්…';

  @override
  String get transferShareCode => 'මෙම කේතය ලබන්නා සමඟ බෙදා ගන්න:';

  @override
  String get transferCopyCode => 'කේතය පිටපත් කරන්න';

  @override
  String get transferCodeCopied => 'කේතය පසුරු පුවරුවට පිටපත් කරන ලදී';

  @override
  String get transferWaitingReceiver => 'ලබන්නා සම්බන්ධ වන තෙක් බලා සිටිමින්…';

  @override
  String get transferConnectingSender => 'යවන්නා සමඟ සම්බන්ධ වෙමින්…';

  @override
  String get transferVerifyBoth =>
      'මෙම කේතය උපාංග දෙකේම සංසන්දනය කරන්න.\nඒවා ගැළපෙන්නේ නම්, මාරු කිරීම ආරක්ෂිතයි.';

  @override
  String get transferComplete => 'මාරු කිරීම සම්පූර්ණයි';

  @override
  String get transferKeysImported => 'යතුරු ආනයනය කරන ලදී';

  @override
  String get transferCompleteSenderBody =>
      'ඔබේ යතුරු මෙම උපාංගයේ සක්‍රීයව පවතී.\nලබන්නාට දැන් ඔබේ අනන්‍යතාවය භාවිතා කළ හැක.';

  @override
  String get transferCompleteReceiverBody =>
      'යතුරු සාර්ථකව ආනයනය කරන ලදී.\nනව අනන්‍යතාවය යෙදීමට යෙදුම නැවත ආරම්භ කරන්න.';

  @override
  String get transferRestartApp => 'යෙදුම නැවත ආරම්භ කරන්න';

  @override
  String get transferFailed => 'මාරු කිරීම අසාර්ථක විය';

  @override
  String get transferTryAgain => 'නැවත උත්සාහ කරන්න';

  @override
  String get transferEnterRelayFirst => 'පළමුව relay URL එකක් ඇතුළත් කරන්න';

  @override
  String get transferPasteCodeFromSender => 'යවන්නාගේ මාරු කිරීමේ කේතය අලවන්න';

  @override
  String get menuReply => 'පිළිතුරු දෙන්න';

  @override
  String get menuForward => 'ඉදිරියට යවන්න';

  @override
  String get menuReact => 'ප්‍රතිචාර දක්වන්න';

  @override
  String get menuCopy => 'පිටපත් කරන්න';

  @override
  String get menuEdit => 'සංස්කරණය කරන්න';

  @override
  String get menuRetry => 'නැවත උත්සාහ කරන්න';

  @override
  String get menuCancelScheduled => 'නියමිත එක අවලංගු කරන්න';

  @override
  String get menuDelete => 'මකන්න';

  @override
  String get menuForwardTo => 'ඉදිරියට යවන්න…';

  @override
  String menuForwardedTo(String name) {
    return '$name වෙත ඉදිරියට යවන ලදී';
  }

  @override
  String get menuScheduledMessages => 'නියමිත පණිවිඩ';

  @override
  String get menuNoScheduledMessages => 'නියමිත පණිවිඩ නැත';

  @override
  String menuSendsOn(String date) {
    return '$date දින යැවේ';
  }

  @override
  String get menuDisappearingMessages => 'අතුරුදහන් වන පණිවිඩ';

  @override
  String get menuDisappearingSubtitle =>
      'තෝරාගත් කාලය ඉක්මවූ පසු පණිවිඩ ස්වයංක්‍රීයව මකා දැමේ.';

  @override
  String get menuTtlOff => 'අක්‍රිය';

  @override
  String get menuTtl1h => 'පැය 1';

  @override
  String get menuTtl24h => 'පැය 24';

  @override
  String get menuTtl7d => 'දින 7';

  @override
  String get menuAttachPhoto => 'ඡායාරූපය';

  @override
  String get menuAttachFile => 'ගොනුව';

  @override
  String get menuAttachVideo => 'වීඩියෝව';

  @override
  String get mediaTitle => 'මාධ්‍ය';

  @override
  String get mediaFileLabel => 'ගොනුව';

  @override
  String mediaPhotosTab(int count) {
    return 'ඡායාරූප ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'ගොනු ($count)';
  }

  @override
  String get mediaNoPhotos => 'තවම ඡායාරූප නැත';

  @override
  String get mediaNoFiles => 'තවම ගොනු නැත';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Downloads/$name වෙත සුරකින ලදී';
  }

  @override
  String get mediaFailedToSave => 'ගොනුව සුරැකීමට අසමත් විය';

  @override
  String get statusNewStatus => 'නව තත්ත්වය';

  @override
  String get statusPublish => 'ප්‍රකාශ කරන්න';

  @override
  String get statusExpiresIn24h => 'තත්ත්වය පැය 24කින් කල් ඉකුත් වේ';

  @override
  String get statusWhatsOnYourMind => 'ඔබේ මනසේ ඇත්තේ කුමක්ද?';

  @override
  String get statusPhotoAttached => 'ඡායාරූපය අමුණා ඇත';

  @override
  String get statusAttachPhoto => 'ඡායාරූපය අමුණන්න (විකල්ප)';

  @override
  String get statusEnterText => 'කරුණාකර ඔබේ තත්ත්වය සඳහා පෙළක් ඇතුළත් කරන්න.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'ඡායාරූපය තේරීමට අසමත් විය: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'ප්‍රකාශ කිරීම අසාර්ථක විය: $error';
  }

  @override
  String get panicSetPanicKey => 'භීති යතුර සකසන්න';

  @override
  String get panicEmergencySelfDestruct => 'හදිසි ස්වයං-විනාශය';

  @override
  String get panicIrreversible => 'මෙම ක්‍රියාව ආපසු හැරවිය නොහැක';

  @override
  String get panicWarningBody =>
      'අගුලු තිරයේ මෙම යතුර ඇතුළත් කිරීම ක්ෂණිකව සියලුම දත්ත මකා දමයි — පණිවිඩ, සම්බන්ධතා, යතුරු, අනන්‍යතාවය. ඔබේ සාමාන්‍ය මුරපදයට වෙනස් යතුරක් භාවිතා කරන්න.';

  @override
  String get panicKeyHint => 'භීති යතුර';

  @override
  String get panicConfirmHint => 'භීති යතුර තහවුරු කරන්න';

  @override
  String get panicMinChars => 'භීති යතුර අවම වශයෙන් අක්ෂර 8ක් විය යුතුය';

  @override
  String get panicKeysDoNotMatch => 'යතුරු නොගැලපේ';

  @override
  String get panicSetFailed =>
      'භීති යතුර සුරැකීමට අසමත් විය — කරුණාකර නැවත උත්සාහ කරන්න';

  @override
  String get passwordSetAppPassword => 'යෙදුම් මුරපදය සකසන්න';

  @override
  String get passwordProtectsMessages => 'ඔබේ පණිවිඩ නිශ්චලව ආරක්ෂා කරයි';

  @override
  String get passwordInfoBanner =>
      'ඔබ Pulse විවෘත කරන සෑම විටම අවශ්‍යයි. අමතක වුවහොත්, ඔබේ දත්ත ප්‍රතිසාධනය කළ නොහැක.';

  @override
  String get passwordHint => 'මුරපදය';

  @override
  String get passwordConfirmHint => 'මුරපදය තහවුරු කරන්න';

  @override
  String get passwordSetButton => 'මුරපදය සකසන්න';

  @override
  String get passwordSkipForNow => 'දැනට මඟ හරින්න';

  @override
  String get passwordMinChars => 'මුරපදය අවම වශයෙන් අක්ෂර 8ක් විය යුතුය';

  @override
  String get passwordNeedsVariety =>
      'අකුරු, ඉලක්කම් සහ විශේෂ අක්ෂර ඇතුළත් විය යුතුය';

  @override
  String get passwordRequirements =>
      'අවම 8 අක්ෂර අකුරු, ඉලක්කම් සහ විශේෂ අක්ෂරයක් සමග';

  @override
  String get passwordsDoNotMatch => 'මුරපද නොගැලපේ';

  @override
  String get profileCardSaved => 'පැතිකඩ සුරකින ලදී!';

  @override
  String get profileCardE2eeIdentity => 'E2EE අනන්‍යතාවය';

  @override
  String get profileCardDisplayName => 'දර්ශන නාමය';

  @override
  String get profileCardDisplayNameHint => 'උදා. කමල් පෙරේරා';

  @override
  String get profileCardAbout => 'ගැන';

  @override
  String get profileCardSaveProfile => 'පැතිකඩ සුරකින්න';

  @override
  String get profileCardYourName => 'ඔබේ නම';

  @override
  String get profileCardAddressCopied => 'ලිපිනය පිටපත් කරන ලදී!';

  @override
  String get profileCardInboxAddress => 'ඔබේ ලැබෙන ලිපිනය';

  @override
  String get profileCardInboxAddresses => 'ඔබේ ලැබෙන ලිපින';

  @override
  String get profileCardShareAllAddresses =>
      'සියලුම ලිපින බෙදා ගන්න (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'ඔවුන්ට ඔබට පණිවිඩ යැවිය හැකි වන පරිදි සම්බන්ධතා සමඟ බෙදා ගන්න.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'සියලුම $count ලිපින එක සබැඳියක් ලෙස පිටපත් කරන ලදී!';
  }

  @override
  String get settingsMyProfile => 'මගේ පැතිකඩ';

  @override
  String get settingsYourInboxAddress => 'ඔබේ ලැබෙන ලිපිනය';

  @override
  String get settingsMyQrCode => 'සම්බන්ධතාව බෙදා ගන්න';

  @override
  String get settingsMyQrSubtitle => 'ඔබේ ලිපිනය සඳහා QR කේතය සහ ආරාධනා සබැඳිය';

  @override
  String get settingsShareMyAddress => 'මගේ ලිපිනය බෙදා ගන්න';

  @override
  String get settingsNoAddressYet =>
      'තවම ලිපිනයක් නැත — පළමුව සැකසුම් සුරකින්න';

  @override
  String get settingsInviteLink => 'ආරාධනා සබැඳිය';

  @override
  String get settingsRawAddress => 'අමු ලිපිනය';

  @override
  String get settingsCopyLink => 'සබැඳිය පිටපත් කරන්න';

  @override
  String get settingsCopyAddress => 'ලිපිනය පිටපත් කරන්න';

  @override
  String get settingsInviteLinkCopied => 'ආරාධනා සබැඳිය පිටපත් කරන ලදී';

  @override
  String get settingsAppearance => 'පෙනුම';

  @override
  String get settingsThemeEngine => 'තේමා එන්ජිම';

  @override
  String get settingsThemeEngineSubtitle => 'වර්ණ සහ අකුරු අභිරුචිකරණය කරන්න';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle => 'E2EE යතුරු ආරක්ෂිතව ගබඩා කර ඇත';

  @override
  String get settingsActive => 'සක්‍රිය';

  @override
  String get settingsIdentityBackup => 'අනන්‍යතා උපස්ථය';

  @override
  String get settingsIdentityBackupSubtitle =>
      'ඔබේ Signal අනන්‍යතාවය අපනයනය හෝ ආනයනය කරන්න';

  @override
  String get settingsIdentityBackupBody =>
      'ඔබේ Signal අනන්‍යතා යතුරු උපස්ථ කේතයකට අපනයනය කරන්න, හෝ පවතින එකක් වෙතින් ප්‍රතිසාධනය කරන්න.';

  @override
  String get settingsTransferDevice => 'වෙනත් උපාංගයකට මාරු කරන්න';

  @override
  String get settingsTransferDeviceSubtitle =>
      'LAN හෝ Nostr relay හරහා ඔබේ අනන්‍යතාවය ගෙනයන්න';

  @override
  String get settingsExportIdentity => 'අනන්‍යතාවය අපනයනය කරන්න';

  @override
  String get settingsExportIdentityBody =>
      'මෙම උපස්ථ කේතය පිටපත් කර ආරක්ෂිතව තබන්න:';

  @override
  String get settingsSaveFile => 'ගොනුව සුරකින්න';

  @override
  String get settingsImportIdentity => 'අනන්‍යතාවය ආනයනය කරන්න';

  @override
  String get settingsImportIdentityBody =>
      'ඔබේ උපස්ථ කේතය පහත අලවන්න. මෙය ඔබේ වත්මන් අනන්‍යතාවය උඩින් ලියනු ඇත.';

  @override
  String get settingsPasteBackupCode => 'උපස්ථ කේතය මෙහි අලවන්න…';

  @override
  String get settingsIdentityImported =>
      'අනන්‍යතාවය + සම්බන්ධතා ආනයනය කරන ලදී! යෙදීමට යෙදුම නැවත ආරම්භ කරන්න.';

  @override
  String get settingsSecurity => 'ආරක්ෂාව';

  @override
  String get settingsAppPassword => 'යෙදුම් මුරපදය';

  @override
  String get settingsPasswordEnabled => 'සක්‍රීයයි — සෑම ආරම්භයකදීම අවශ්‍යයි';

  @override
  String get settingsPasswordDisabled =>
      'අක්‍රීයයි — මුරපදයකින් තොරව යෙදුම විවෘත වේ';

  @override
  String get settingsChangePassword => 'මුරපදය වෙනස් කරන්න';

  @override
  String get settingsChangePasswordSubtitle =>
      'ඔබේ යෙදුම් අගුලු මුරපදය යාවත්කාලීන කරන්න';

  @override
  String get settingsSetPanicKey => 'භීති යතුර සකසන්න';

  @override
  String get settingsChangePanicKey => 'භීති යතුර වෙනස් කරන්න';

  @override
  String get settingsPanicKeySetSubtitle =>
      'හදිසි මකාදැමීමේ යතුර යාවත්කාලීන කරන්න';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'සියලුම දත්ත ක්ෂණිකව මකා දමන යතුරක්';

  @override
  String get settingsRemovePanicKey => 'භීති යතුර ඉවත් කරන්න';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'හදිසි ස්වයං-විනාශය අක්‍රිය කරන්න';

  @override
  String get settingsRemovePanicKeyBody =>
      'හදිසි ස්වයං-විනාශය අක්‍රිය කෙරේ. ඔබට ඕනෑම වේලාවක එය නැවත සක්‍රිය කළ හැක.';

  @override
  String get settingsDisableAppPassword => 'යෙදුම් මුරපදය අක්‍රිය කරන්න';

  @override
  String get settingsEnterCurrentPassword =>
      'තහවුරු කිරීමට ඔබේ වත්මන් මුරපදය ඇතුළත් කරන්න';

  @override
  String get settingsCurrentPassword => 'වත්මන් මුරපදය';

  @override
  String get settingsIncorrectPassword => 'වැරදි මුරපදය';

  @override
  String get settingsPasswordUpdated => 'මුරපදය යාවත්කාලීන කරන ලදී';

  @override
  String get settingsChangePasswordProceed =>
      'ඉදිරියට යාමට ඔබේ වත්මන් මුරපදය ඇතුළත් කරන්න';

  @override
  String get settingsData => 'දත්ත';

  @override
  String get settingsBackupMessages => 'පණිවිඩ උපස්ථ කරන්න';

  @override
  String get settingsBackupMessagesSubtitle =>
      'සංකේතනය කළ පණිවිඩ ඉතිහාසය ගොනුවකට අපනයනය කරන්න';

  @override
  String get settingsRestoreMessages => 'පණිවිඩ ප්‍රතිසාධනය කරන්න';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'උපස්ථ ගොනුවකින් පණිවිඩ ආනයනය කරන්න';

  @override
  String get settingsExportKeys => 'යතුරු අපනයනය කරන්න';

  @override
  String get settingsExportKeysSubtitle =>
      'අනන්‍යතා යතුරු සංකේතනය කළ ගොනුවකට සුරකින්න';

  @override
  String get settingsImportKeys => 'යතුරු ආනයනය කරන්න';

  @override
  String get settingsImportKeysSubtitle =>
      'අපනයනය කළ ගොනුවකින් අනන්‍යතා යතුරු ප්‍රතිසාධනය කරන්න';

  @override
  String get settingsBackupPassword => 'උපස්ථ මුරපදය';

  @override
  String get settingsPasswordCannotBeEmpty => 'මුරපදය හිස් විය නොහැක';

  @override
  String get settingsPasswordMin4Chars =>
      'මුරපදය අවම වශයෙන් අක්ෂර 4ක් විය යුතුය';

  @override
  String get settingsCallsTurn => 'ඇමතුම් සහ TURN';

  @override
  String get settingsLocalNetwork => 'දේශීය ජාලය';

  @override
  String get settingsCensorshipResistance => 'වාරණ ප්‍රතිරෝධය';

  @override
  String get settingsNetwork => 'ජාලය';

  @override
  String get settingsProxyTunnels => 'Proxy සහ Tunnels';

  @override
  String get settingsTurnServers => 'TURN සේවාදායක';

  @override
  String get settingsProviderTitle => 'සැපයුම්කරු';

  @override
  String get settingsLanFallback => 'LAN ආපසු හැරීම';

  @override
  String get settingsLanFallbackSubtitle =>
      'අන්තර්ජාලය නොමැති විට දේශීය ජාලයේ පැවැත්ම විකාශනය කර පණිවිඩ බෙදා හරින්න. විශ්වාස නොකරන ජාලවල (පොදු Wi-Fi) අක්‍රිය කරන්න.';

  @override
  String get settingsBgDelivery => 'පසුබිම් බෙදාහැරීම';

  @override
  String get settingsBgDeliverySubtitle =>
      'යෙදුම කුඩා කළ විට පණිවිඩ ලබා ගැනීම දිගටම කරගෙන යන්න. ස්ථිර දැනුම්දීමක් පෙන්වයි.';

  @override
  String get settingsYourInboxProvider => 'ඔබේ ලැබෙන සැපයුම්කරු';

  @override
  String get settingsConnectionDetails => 'සම්බන්ධතා විස්තර';

  @override
  String get settingsSaveAndConnect => 'සුරකින්න සහ සම්බන්ධ වන්න';

  @override
  String get settingsSecondaryInboxes => 'ද්වීතීයික ලැබෙන පෙට්ටි';

  @override
  String get settingsAddSecondaryInbox => 'ද්වීතීයික ලැබෙන පෙට්ටියක් එක් කරන්න';

  @override
  String get settingsAdvanced => 'උසස්';

  @override
  String get settingsDiscover => 'සොයාගන්න';

  @override
  String get settingsAbout => 'ගැන';

  @override
  String get settingsPrivacyPolicy => 'රහස්‍යතා ප්‍රතිපත්තිය';

  @override
  String get settingsPrivacyPolicySubtitle => 'Pulse ඔබේ දත්ත ආරක්ෂා කරන ආකාරය';

  @override
  String get settingsCrashReporting => 'බිඳ වැටීම් වාර්තාකරණය';

  @override
  String get settingsCrashReportingSubtitle =>
      'Pulse වැඩිදියුණු කිරීමට නිර්නාමික බිඳ වැටීම් වාර්තා යවන්න. පණිවිඩ අන්තර්ගතය හෝ සම්බන්ධතා කිසිවිටක යවනු නොලැබේ.';

  @override
  String get settingsCrashReportingEnabled =>
      'බිඳ වැටීම් වාර්තාකරණය සක්‍රීය කරන ලදී — යෙදීමට යෙදුම නැවත ආරම්භ කරන්න';

  @override
  String get settingsCrashReportingDisabled =>
      'බිඳ වැටීම් වාර්තාකරණය අක්‍රීය කරන ලදී — යෙදීමට යෙදුම නැවත ආරම්භ කරන්න';

  @override
  String get settingsSensitiveOperation => 'සංවේදී ක්‍රියාව';

  @override
  String get settingsSensitiveOperationBody =>
      'මෙම යතුරු ඔබේ අනන්‍යතාවයයි. මෙම ගොනුව ඇති ඕනෑම කෙනෙකුට ඔබ ලෙස පෙනී සිටිය හැක. එය ආරක්ෂිතව ගබඩා කර මාරු කිරීමෙන් පසු මකා දමන්න.';

  @override
  String get settingsIUnderstandContinue => 'මට තේරෙනවා, ඉදිරියට යන්න';

  @override
  String get settingsReplaceIdentity => 'අනන්‍යතාවය ප්‍රතිස්ථාපනය කරන්නද?';

  @override
  String get settingsReplaceIdentityBody =>
      'මෙය ඔබේ වත්මන් අනන්‍යතා යතුරු උඩින් ලියනු ඇත. ඔබේ පවතින Signal සැසි අවලංගු වන අතර සම්බන්ධතා නැවත සංකේතනය පිහිටුවිය යුතුය. යෙදුම නැවත ආරම්භ කළ යුතුය.';

  @override
  String get settingsReplaceKeys => 'යතුරු ප්‍රතිස්ථාපනය කරන්න';

  @override
  String get settingsKeysImported => 'යතුරු ආනයනය කරන ලදී';

  @override
  String settingsKeysImportedBody(int count) {
    return 'යතුරු $countක් සාර්ථකව ආනයනය කරන ලදී. නව අනන්‍යතාවය සමඟ නැවත ආරම්භ කිරීමට කරුණාකර යෙදුම නැවත ආරම්භ කරන්න.';
  }

  @override
  String get settingsRestartNow => 'දැන් නැවත ආරම්භ කරන්න';

  @override
  String get settingsLater => 'පසුව';

  @override
  String get profileGroupLabel => 'සමූහය';

  @override
  String get profileAddButton => 'එක් කරන්න';

  @override
  String get profileKickButton => 'පිටකරන්න';

  @override
  String get dataSectionTitle => 'දත්ත';

  @override
  String get dataBackupMessages => 'පණිවිඩ උපස්ථ කරන්න';

  @override
  String get dataBackupPasswordSubtitle =>
      'ඔබේ පණිවිඩ උපස්ථය සංකේතනය කිරීමට මුරපදයක් තෝරන්න.';

  @override
  String get dataBackupConfirmLabel => 'උපස්ථය සාදන්න';

  @override
  String get dataCreatingBackup => 'උපස්ථය සාදමින්';

  @override
  String get dataBackupPreparing => 'සූදානම් වෙමින්...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'පණිවිඩය $done / $total අපනයනය කරමින්...';
  }

  @override
  String get dataBackupSavingFile => 'ගොනුව සුරකිමින්...';

  @override
  String get dataSaveMessageBackupDialog => 'පණිවිඩ උපස්ථය සුරකින්න';

  @override
  String dataBackupSaved(int count, String path) {
    return 'උපස්ථය සුරකින ලදී (පණිවිඩ $count)\n$path';
  }

  @override
  String get dataBackupFailed => 'උපස්ථය අසාර්ථක විය — දත්ත අපනයනය නොකරන ලදී';

  @override
  String dataBackupFailedError(String error) {
    return 'උපස්ථය අසාර්ථක විය: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'පණිවිඩ උපස්ථය තෝරන්න';

  @override
  String get dataInvalidBackupFile => 'අවලංගු උපස්ථ ගොනුව (ඉතා කුඩාය)';

  @override
  String get dataNotValidBackupFile => 'වලංගු Pulse උපස්ථ ගොනුවක් නොවේ';

  @override
  String get dataRestoreMessages => 'පණිවිඩ ප්‍රතිසාධනය කරන්න';

  @override
  String get dataRestorePasswordSubtitle =>
      'මෙම උපස්ථය සෑදීමට භාවිතා කළ මුරපදය ඇතුළත් කරන්න.';

  @override
  String get dataRestoreConfirmLabel => 'ප්‍රතිසාධනය';

  @override
  String get dataRestoringMessages => 'පණිවිඩ ප්‍රතිසාධනය කරමින්';

  @override
  String get dataRestoreDecrypting => 'විකේතනය කරමින්...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'පණිවිඩය $done / $total ආනයනය කරමින්...';
  }

  @override
  String get dataRestoreFailed =>
      'ප්‍රතිසාධනය අසාර්ථක විය — වැරදි මුරපදය හෝ දූෂිත ගොනුව';

  @override
  String dataRestoreSuccess(int count) {
    return 'නව පණිවිඩ $countක් ප්‍රතිසාධනය කරන ලදී';
  }

  @override
  String get dataRestoreNothingNew =>
      'ආනයනය කිරීමට නව පණිවිඩ නැත (සියල්ල දැනටමත් පවතී)';

  @override
  String dataRestoreFailedError(String error) {
    return 'ප්‍රතිසාධනය අසාර්ථක විය: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'යතුරු අපනයනය තෝරන්න';

  @override
  String get dataNotValidKeyFile => 'වලංගු Pulse යතුරු අපනයන ගොනුවක් නොවේ';

  @override
  String get dataExportKeys => 'යතුරු අපනයනය කරන්න';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'ඔබේ යතුරු අපනයනය සංකේතනය කිරීමට මුරපදයක් තෝරන්න.';

  @override
  String get dataExportKeysConfirmLabel => 'අපනයනය';

  @override
  String get dataExportingKeys => 'යතුරු අපනයනය කරමින්';

  @override
  String get dataExportingKeysStatus => 'අනන්‍යතා යතුරු සංකේතනය කරමින්...';

  @override
  String get dataSaveKeyExportDialog => 'යතුරු අපනයනය සුරකින්න';

  @override
  String dataKeysExportedTo(String path) {
    return 'යතුරු අපනයනය කරන ලදී:\n$path';
  }

  @override
  String get dataExportFailed => 'අපනයනය අසාර්ථක විය — යතුරු හමු නොවීය';

  @override
  String dataExportFailedError(String error) {
    return 'අපනයනය අසාර්ථක විය: $error';
  }

  @override
  String get dataImportKeys => 'යතුරු ආනයනය කරන්න';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'මෙම යතුරු අපනයනය සංකේතනය කිරීමට භාවිතා කළ මුරපදය ඇතුළත් කරන්න.';

  @override
  String get dataImportKeysConfirmLabel => 'ආනයනය';

  @override
  String get dataImportingKeys => 'යතුරු ආනයනය කරමින්';

  @override
  String get dataImportingKeysStatus => 'අනන්‍යතා යතුරු විකේතනය කරමින්...';

  @override
  String get dataImportFailed =>
      'ආනයනය අසාර්ථක විය — වැරදි මුරපදය හෝ දූෂිත ගොනුව';

  @override
  String dataImportFailedError(String error) {
    return 'ආනයනය අසාර්ථක විය: $error';
  }

  @override
  String get securitySectionTitle => 'ආරක්ෂාව';

  @override
  String get securityIncorrectPassword => 'වැරදි මුරපදය';

  @override
  String get securityPasswordUpdated => 'මුරපදය යාවත්කාලීන කරන ලදී';

  @override
  String get appearanceSectionTitle => 'පෙනුම';

  @override
  String appearanceExportFailed(String error) {
    return 'අපනයනය අසාර්ථක විය: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return '$path වෙත සුරකින ලදී';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'සුරැකීම අසාර්ථක විය: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'ආනයනය අසාර්ථක විය: $error';
  }

  @override
  String get aboutSectionTitle => 'ගැන';

  @override
  String get providerPublicKey => 'පොදු යතුර';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'ඔබේ ප්‍රතිසාධන මුරපදයෙන් ස්වයංක්‍රීයව වින්‍යාස කර ඇත. Relay ස්වයංක්‍රීයව සොයා ගන්නා ලදී.';

  @override
  String get providerKeyStoredLocally =>
      'ඔබේ යතුර ආරක්ෂිත ගබඩාවේ දේශීයව ගබඩා කර ඇත — කිසිදු සේවාදායකයකට යවනු නොලැබේ.';

  @override
  String get providerSessionInfo =>
      'Session Network — ළූනු-මාර්ගගත E2EE. ඔබේ Session ID ස්වයංක්‍රීයව ජනනය වී ආරක්ෂිතව ගබඩා කෙරේ. Node ස්වයංක්‍රීයව ගොඩනඟන ලද seed nodes වලින් සොයා ගැනේ.';

  @override
  String get providerAdvanced => 'උසස්';

  @override
  String get providerSaveAndConnect => 'සුරකින්න සහ සම්බන්ධ වන්න';

  @override
  String get providerAddSecondaryInbox => 'ද්වීතීයික ලැබෙන පෙට්ටියක් එක් කරන්න';

  @override
  String get providerSecondaryInboxes => 'ද්වීතීයික ලැබෙන පෙට්ටි';

  @override
  String get providerYourInboxProvider => 'ඔබේ ලැබෙන සැපයුම්කරු';

  @override
  String get providerConnectionDetails => 'සම්බන්ධතා විස්තර';

  @override
  String get addContactTitle => 'සම්බන්ධතාවක් එක් කරන්න';

  @override
  String get addContactInviteLinkLabel => 'ආරාධනා සබැඳිය හෝ ලිපිනය';

  @override
  String get addContactTapToPaste => 'ආරාධනා සබැඳිය අලවීමට තට්ටු කරන්න';

  @override
  String get addContactPasteTooltip => 'පසුරු පුවරුවෙන් අලවන්න';

  @override
  String get addContactAddressDetected => 'සම්බන්ධතා ලිපිනය හඳුනා ගන්නා ලදී';

  @override
  String addContactRoutesDetected(int count) {
    return 'මාර්ග $countක් හඳුනා ගන්නා ලදී — SmartRouter වේගවත්ම එක තෝරයි';
  }

  @override
  String get addContactFetchingProfile => 'පැතිකඩ ලබා ගනිමින්…';

  @override
  String addContactProfileFound(String name) {
    return 'හමු විය: $name';
  }

  @override
  String get addContactNoProfileFound => 'පැතිකඩක් හමු නොවීය';

  @override
  String get addContactDisplayNameLabel => 'දර්ශන නාමය';

  @override
  String get addContactDisplayNameHint => 'ඔවුන්ට ඔබ කුමක් කියන්නද?';

  @override
  String get addContactAddManually => 'ලිපිනය අතින් එක් කරන්න';

  @override
  String get addContactButton => 'සම්බන්ධතාවක් එක් කරන්න';

  @override
  String get networkDiagnosticsTitle => 'ජාල රෝග විනිශ්චය';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr Relay';

  @override
  String get networkDiagnosticsDirect => 'සෘජු';

  @override
  String get networkDiagnosticsTorOnly => 'Tor පමණි';

  @override
  String get networkDiagnosticsBest => 'හොඳම';

  @override
  String get networkDiagnosticsNone => 'නැත';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'තත්ත්වය';

  @override
  String get networkDiagnosticsConnected => 'සම්බන්ධයි';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'සම්බන්ධ වෙමින් $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'අක්‍රිය';

  @override
  String get networkDiagnosticsTransport => 'ප්‍රවාහනය';

  @override
  String get networkDiagnosticsInfrastructure => 'යටිතල පහසුකම්';

  @override
  String get networkDiagnosticsSessionNodes => 'Session නෝඩ්';

  @override
  String get networkDiagnosticsTurnServers => 'TURN සේවාදායක';

  @override
  String get networkDiagnosticsLastProbe => 'අවසන් පරීක්ෂාව';

  @override
  String get networkDiagnosticsRunning => 'ක්‍රියාත්මක වෙමින්...';

  @override
  String get networkDiagnosticsRunDiagnostics =>
      'රෝග විනිශ්චය ක්‍රියාත්මක කරන්න';

  @override
  String get networkDiagnosticsForceReprobe =>
      'සම්පූර්ණ නැවත පරීක්ෂාව බල කරන්න';

  @override
  String get networkDiagnosticsJustNow => 'මේ දැන්';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'මිනිත්තු $minutesකට පෙර';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'පැය $hoursකට පෙර';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'දින $daysකට පෙර';
  }

  @override
  String get homeNoEch => 'ECH නැත';

  @override
  String get homeNoEchTooltip =>
      'uTLS proxy නොමැත — ECH අක්‍රියයි.\nTLS ඇඟිලි සලකුණ DPI ට දෘශ්‍යයි.';

  @override
  String get settingsTitle => 'සැකසුම්';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'සුරැකි සහ $provider වෙත සම්බන්ධයි';
  }

  @override
  String get settingsTorFailedToStart => 'ගොඩනඟන ලද Tor ආරම්භ කිරීමට අසමත් විය';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon ආරම්භ කිරීමට අසමත් විය';

  @override
  String get verifyTitle => 'ආරක්ෂක අංකය සත්‍යාපනය කරන්න';

  @override
  String get verifyIdentityVerified => 'අනන්‍යතාවය සත්‍යාපනය කරන ලදී';

  @override
  String get verifyNotYetVerified => 'තවම සත්‍යාපනය කර නැත';

  @override
  String verifyVerifiedDescription(String name) {
    return 'ඔබ $nameගේ ආරක්ෂක අංකය සත්‍යාපනය කර ඇත.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'මෙම අංක $name සමඟ පුද්ගලිකව හෝ විශ්වාසදායක නාලිකාවක් හරහා සංසන්දනය කරන්න.';
  }

  @override
  String get verifyExplanation =>
      'සෑම සංවාදයකටම අනන්‍ය ආරක්ෂක අංකයක් ඇත. ඔබ දෙදෙනාම ඔබේ උපාංගවල එකම අංක දකින්නේ නම්, ඔබේ සම්බන්ධතාවය අන්තයේ සිට අන්තය දක්වා සත්‍යාපනය කර ඇත.';

  @override
  String verifyContactKey(String name) {
    return '$nameගේ යතුර';
  }

  @override
  String get verifyYourKey => 'ඔබේ යතුර';

  @override
  String get verifyRemoveVerification => 'සත්‍යාපනය ඉවත් කරන්න';

  @override
  String get verifyMarkAsVerified => 'සත්‍යාපිත ලෙස සලකුණු කරන්න';

  @override
  String verifyAfterReinstall(String name) {
    return '$name යෙදුම නැවත ස්ථාපනය කළහොත්, ආරක්ෂක අංකය වෙනස් වන අතර සත්‍යාපනය ස්වයංක්‍රීයව ඉවත් කෙරේ.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'හඬ ඇමතුමකින් හෝ පුද්ගලිකව $name සමඟ අංක සංසන්දනය කිරීමෙන් පසුව පමණක් සත්‍යාපිත ලෙස සලකුණු කරන්න.';
  }

  @override
  String get verifyNoSession =>
      'තවම සංකේතන සැසියක් පිහිටුවා නැත. ආරක්ෂක අංක ජනනය කිරීමට පළමුව පණිවිඩයක් යවන්න.';

  @override
  String get verifyNoKeyAvailable => 'යතුරක් නොමැත';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label ඇඟිලි සලකුණ පිටපත් කරන ලදී';
  }

  @override
  String get providerDatabaseUrlLabel => 'දත්ත සමුදාය URL';

  @override
  String get providerOptionalHint => 'විකල්ප';

  @override
  String get providerWebApiKeyLabel => 'Web API යතුර';

  @override
  String get providerOptionalForPublicDb => 'පොදු DB සඳහා විකල්ප';

  @override
  String get providerRelayUrlLabel => 'Relay URL';

  @override
  String get providerPrivateKeyLabel => 'පුද්ගලික යතුර';

  @override
  String get providerPrivateKeyNsecLabel => 'පුද්ගලික යතුර (nsec)';

  @override
  String get providerStorageNodeLabel => 'ගබඩා node URL (විකල්ප)';

  @override
  String get providerStorageNodeHint => 'ගොඩනඟන ලද seed node සඳහා හිස්ව තබන්න';

  @override
  String get transferInvalidCodeFormat =>
      'හඳුනා නොගත් කේත ආකෘතිය — LAN: හෝ NOS: වලින් ආරම්භ විය යුතුය';

  @override
  String get profileCardFingerprintCopied => 'ඇඟිලි සලකුණ පිටපත් කරන ලදී';

  @override
  String get profileCardAboutHint => 'රහස්‍යතාව පළමුව 🔒';

  @override
  String get profileCardSaveButton => 'පැතිකඩ සුරකින්න';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'සංකේතනය කළ පණිවිඩ, සම්බන්ධතා සහ අවතාර ගොනුවකට අපනයනය කරන්න';

  @override
  String get callVideo => 'වීඩියෝ';

  @override
  String get callAudio => 'ශ්‍රව්‍ය';

  @override
  String bubbleDeliveredTo(String names) {
    return '$names වෙත බෙදා හරින ලදී';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return '$count දෙනෙකුට බෙදා හරින ලදී';
  }

  @override
  String get groupStatusDialogTitle => 'පණිවිඩ තොරතුරු';

  @override
  String get groupStatusRead => 'කියවා ඇත';

  @override
  String get groupStatusDelivered => 'බෙදා හරින ලදී';

  @override
  String get groupStatusPending => 'බලාපොරොත්තුවෙන්';

  @override
  String get groupStatusNoData => 'තවම බෙදාහැරීම් තොරතුරු නැත';

  @override
  String get profileTransferAdmin => 'පරිපාලක කරන්න';

  @override
  String profileTransferAdminConfirm(String name) {
    return '$name නව පරිපාලකයා කරන්නද?';
  }

  @override
  String get profileTransferAdminBody =>
      'ඔබ පරිපාලක වරප්‍රසාද අහිමි වනු ඇත. මෙය ආපසු හැරවිය නොහැක.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name දැන් පරිපාලකයාය';
  }

  @override
  String get profileAdminBadge => 'පරිපාලක';

  @override
  String get privacyPolicyTitle => 'රහස්‍යතා ප්‍රතිපත්තිය';

  @override
  String get privacyOverviewHeading => 'දළ විసුරුම';

  @override
  String get privacyOverviewBody =>
      'Pulse සේවාදායක-රහිත, අන්තයේ සිට අන්තය දක්වා සංකේතනය කළ පණිවිඩකරුවෙකි. ඔබේ රහස්‍යතාවය ලක්ෂණයක් පමණක් නොවේ — එය ගෘහ නිර්මාණ ශිල්පයයි. Pulse සේවාදායක නැත. ගිණුම් කොතැනකවත් ගබඩා නොවේ. සංවර්ධකයන් විසින් කිසිදු දත්තයක් එකතු, සම්ප්‍රේෂණ හෝ ගබඩා නොකෙරේ.';

  @override
  String get privacyDataCollectionHeading => 'දත්ත එකතු කිරීම';

  @override
  String get privacyDataCollectionBody =>
      'Pulse පෞද්ගලික දත්ත ශුන්‍ය ප්‍රමාණයක් එකතු කරයි. විශේෂයෙන්:\n\n- විද්‍යුත් තැපෑල, දුරකථන අංකය, හෝ සැබෑ නම අවශ්‍ය නැත\n- විශ්ලේෂණ, ලුහුබැඳීම හෝ ටෙලිමෙට්‍රි නැත\n- දැන්වීම් හඳුනා ගැනීම් නැත\n- සම්බන්ධතා ලැයිස්තුවට ප්‍රවේශය නැත\n- වලාකුළු උපස්ථ නැත (පණිවිඩ ඔබේ උපාංගයේ පමණක් පවතී)\n- කිසිදු Pulse සේවාදායකයකට metadata යවනු නොලැබේ (ඒවා නොමැත)';

  @override
  String get privacyEncryptionHeading => 'සංකේතනය';

  @override
  String get privacyEncryptionBody =>
      'සියලුම පණිවිඩ Signal Protocol (X3DH යතුරු ගිවිසුම සමඟ Double Ratchet) භාවිතයෙන් සංකේතනය කෙරේ. සංකේතන යතුරු ඔබේ උපාංගයේ පමණක් ජනනය සහ ගබඩා කෙරේ. කිසිවෙකුට — සංවර්ධකයන්ටද — ඔබේ පණිවිඩ කියවිය නොහැක.';

  @override
  String get privacyNetworkHeading => 'ජාල ගෘහ නිර්මාණ ශිල්පය';

  @override
  String get privacyNetworkBody =>
      'Pulse ෆෙඩරේටඩ් ප්‍රවාහන අනුවර්තක භාවිතා කරයි (Nostr relay, Session/Oxen සේවා node, Firebase Realtime Database, LAN). මෙම ප්‍රවාහන සංකේතනය කළ ciphertext පමණක් ගෙන යනු ලබයි. Relay ක්‍රියාකරුවන්ට ඔබේ IP ලිපිනය සහ ගමනාගමන පරිමාව දැක ගත හැක, නමුත් පණිවිඩ අන්තර්ගතය විකේතනය කළ නොහැක.\n\nTor සක්‍රිය කළ විට, ඔබේ IP ලිපිනය relay ක්‍රියාකරුවන්ගෙන්ද සැඟවේ.';

  @override
  String get privacyStunHeading => 'STUN/TURN සේවාදායක';

  @override
  String get privacyStunBody =>
      'හඬ සහ වීඩියෝ ඇමතුම් DTLS-SRTP සංකේතනය සමඟ WebRTC භාවිතා කරයි. STUN සේවාදායක (peer-to-peer සම්බන්ධතා සඳහා ඔබේ පොදු IP සොයා ගැනීමට භාවිතා කෙරේ) සහ TURN සේවාදායක (සෘජු සම්බන්ධතාව අසාර්ථක වූ විට මාධ්‍ය relay කිරීමට භාවිතා කෙරේ) ඔබේ IP ලිපිනය සහ ඇමතුම් කාලය දැක ගත හැක, නමුත් ඇමතුම් අන්තර්ගතය විකේතනය කළ නොහැක.\n\nඋපරිම රහස්‍යතාව සඳහා සැකසුම් වලින් ඔබේම TURN සේවාදායකය වින්‍යාස කළ හැක.';

  @override
  String get privacyCrashHeading => 'බිඳ වැටීම් වාර්තාකරණය';

  @override
  String get privacyCrashBody =>
      'Sentry බිඳ වැටීම් වාර්තාකරණය සක්‍රිය නම් (build-time SENTRY_DSN හරහා), නිර්නාමික බිඳ වැටීම් වාර්තා යවනු ලැබිය හැක. මේවාට පණිවිඩ අන්තර්ගතය, සම්බන්ධතා තොරතුරු, හෝ පුද්ගලිකව හඳුනාගත හැකි තොරතුරු අඩංගු නොවේ. DSN අත්හරින ලෙස build-time එකේදී බිඳ වැටීම් වාර්තාකරණය අක්‍රිය කළ හැක.';

  @override
  String get privacyPasswordHeading => 'මුරපදය සහ යතුරු';

  @override
  String get privacyPasswordBody =>
      'ඔබේ ප්‍රතිසාධන මුරපදය Argon2id (මතක-දෘඪ KDF) හරහා ගුප්තලේඛන යතුරු ව්‍යුත්පන්න කිරීමට භාවිතා කරයි. මුරපදය කිසිතැනකට සම්ප්‍රේෂණය නොකෙරේ. ඔබේ මුරපදය නැති වුවහොත්, ඔබේ ගිණුම ප්‍රතිසාධනය කළ නොහැක — එය යළි පිහිටුවීමට සේවාදායකයක් නැත.';

  @override
  String get privacyFontsHeading => 'අකුරු';

  @override
  String get privacyFontsBody =>
      'Pulse සියලුම අකුරු දේශීයව ඇතුළත් කරයි. Google Fonts හෝ වෙනත් බාහිර අකුරු සේවාවකට ඉල්ලීම් කරනු නොලැබේ.';

  @override
  String get privacyThirdPartyHeading => 'තෙවන පාර්ශ්ව සේවා';

  @override
  String get privacyThirdPartyBody =>
      'Pulse කිසිදු දැන්වීම් ජාලයක්, විශ්ලේෂණ සැපයුම්කරුවෙකු, සමාජ මාධ්‍ය වේදිකාවක්, හෝ දත්ත තැරැව්කරුවෙකු සමඟ ඒකාබද්ධ නොවේ. එකම ජාල සම්බන්ධතා ඔබ වින්‍යාස කරන ප්‍රවාහන relay වෙතය.';

  @override
  String get privacyOpenSourceHeading => 'විවෘත මූලාශ්‍ර';

  @override
  String get privacyOpenSourceBody =>
      'Pulse විවෘත-මූලාශ්‍ර මෘදුකාංගයකි. මෙම රහස්‍යතා ප්‍රකාශ සත්‍යාපනය කිරීමට ඔබට සම්පූර්ණ මූලාශ්‍ර කේතය විගණනය කළ හැක.';

  @override
  String get privacyContactHeading => 'සම්බන්ධ වන්න';

  @override
  String get privacyContactBody =>
      'රහස්‍යතාවයට අදාළ ප්‍රශ්න සඳහා, ව්‍යාපෘති ගබඩාවේ ගැටලුවක් විවෘත කරන්න.';

  @override
  String get privacyLastUpdated => 'අවසන් යාවත්කාලීනය: 2026 මාර්තු';

  @override
  String imageSaveFailed(Object error) {
    return 'සුරැකීම අසාර්ථක විය: $error';
  }

  @override
  String get themeEngineTitle => 'තේමා එන්ජිම';

  @override
  String get torBuiltInTitle => 'ගොඩනඟන ලද Tor';

  @override
  String get torConnectedSubtitle =>
      'සම්බන්ධයි — Nostr මාර්ගගත 127.0.0.1:9250 හරහා';

  @override
  String torConnectingSubtitle(int pct) {
    return 'සම්බන්ධ වෙමින්… $pct%';
  }

  @override
  String get torNotRunning =>
      'ක්‍රියාත්මක නැත — නැවත ආරම්භ කිරීමට ස්විචය තට්ටු කරන්න';

  @override
  String get torDescription =>
      'Nostr Tor හරහා මාර්ගගත කරයි (වාරණය කළ ජාල සඳහා Snowflake)';

  @override
  String get torNetworkDiagnostics => 'ජාල රෝග විනිශ්චය';

  @override
  String get torTransportLabel => 'ප්‍රවාහනය: ';

  @override
  String get torPtAuto => 'ස්වයංක්‍රීය';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'සාමාන්‍ය';

  @override
  String get torTimeoutLabel => 'කාල සීමාව: ';

  @override
  String get torInfoDescription =>
      'සක්‍රිය කළ විට, Nostr WebSocket සම්බන්ධතා Tor (SOCKS5) හරහා මාර්ගගත කෙරේ. Tor Browser 127.0.0.1:9150 මත සවන් දෙයි. ස්වාධීන tor daemon port 9050 භාවිතා කරයි. Firebase සම්බන්ධතාවලට බලපෑමක් නැත.';

  @override
  String get torRouteNostrTitle => 'Nostr Tor හරහා මාර්ගගත කරන්න';

  @override
  String get torManagedByBuiltin => 'ගොඩනඟන ලද Tor මඟින් කළමනාකරණය කෙරේ';

  @override
  String get torActiveRouting =>
      'සක්‍රිය — Nostr ගමනාගමනය Tor හරහා මාර්ගගත කෙරේ';

  @override
  String get torDisabled => 'අක්‍රිය';

  @override
  String get torProxySocks5 => 'Tor Proxy (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Proxy ධාරකය';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser: port 9150  •  tor daemon: port 9050';

  @override
  String get torForceNostrTitle => 'පණිවිඩ Tor හරහා යොමු කරන්න';

  @override
  String get torForceNostrSubtitle =>
      'සියලුම Nostr relay සම්බන්ධතා Tor හරහා යනු ඇත. මන්දගාමී නමුත් relay වලින් ඔබේ IP සඟවයි.';

  @override
  String get torForceNostrDisabled => 'පළමුව Tor සක්‍රිය කළ යුතුය';

  @override
  String get torForcePulseTitle => 'Pulse relay Tor හරහා යොමු කරන්න';

  @override
  String get torForcePulseSubtitle =>
      'සියලුම Pulse relay සම්බන්ධතා Tor හරහා යනු ඇත. මන්දගාමී නමුත් සේවාදායකයෙන් ඔබේ IP සඟවයි.';

  @override
  String get torForcePulseDisabled => 'පළමුව Tor සක්‍රිය කළ යුතුය';

  @override
  String get i2pProxySocks5 => 'I2P Proxy (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P පෙරනිමියෙන් port 4447 මත SOCKS5 භාවිතා කරයි. ඕනෑම ප්‍රවාහනයක පරිශීලකයන් සමඟ සන්නිවේදනය කිරීමට I2P outproxy (උදා. relay.damus.i2p) හරහා Nostr relay එකකට සම්බන්ධ වන්න. දෙකම සක්‍රිය විට Tor ප්‍රමුඛතාවය ගනී.';

  @override
  String get i2pRouteNostrTitle => 'Nostr I2P හරහා මාර්ගගත කරන්න';

  @override
  String get i2pActiveRouting =>
      'සක්‍රිය — Nostr ගමනාගමනය I2P හරහා මාර්ගගත කෙරේ';

  @override
  String get i2pDisabled => 'අක්‍රිය';

  @override
  String get i2pProxyHostLabel => 'Proxy ධාරකය';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'I2P Router පෙරනිමි SOCKS5 port: 4447';

  @override
  String get customProxySocks5 => 'අභිරුචි Proxy (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'අභිරුචි proxy ඔබේ V2Ray/Xray/Shadowsocks හරහා ගමනාගමනය මාර්ගගත කරයි. CF Worker Cloudflare CDN මත පුද්ගලික relay proxy ලෙස ක්‍රියා කරයි — GFW ට *.workers.dev පෙනේ, සැබෑ relay නොවේ.';

  @override
  String get customSocks5ProxyTitle => 'අභිරුචි SOCKS5 Proxy';

  @override
  String get customProxyActive => 'සක්‍රිය — ගමනාගමනය SOCKS5 හරහා මාර්ගගත කෙරේ';

  @override
  String get customProxyDisabled => 'අක්‍රිය';

  @override
  String get customProxyHostLabel => 'Proxy ධාරකය';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker Domain (විකල්ප)';

  @override
  String get customWorkerHelpTitle =>
      'CF Worker relay එකක් deploy කරන ආකාරය (නොමිලේ)';

  @override
  String get customWorkerScriptCopied => 'ස්ක්‍රිප්ටය පිටපත් කරන ලදී!';

  @override
  String get customWorkerStep1 =>
      '1. dash.cloudflare.com → Workers & Pages වෙත යන්න\n2. Create Worker → මෙම ස්ක්‍රිප්ටය අලවන්න:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → domain පිටපත් කරන්න (උදා. my-relay.user.workers.dev)\n4. ඉහත domain අලවන්න → සුරකින්න\n\nයෙදුම ස්වයංක්‍රීයව සම්බන්ධ වේ: wss://domain/?r=relay_url\nGFW ට පෙනේ: *.workers.dev (CF CDN) වෙත සම්බන්ධතාවය';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'සම්බන්ධයි — SOCKS5 127.0.0.1:$port මත';
  }

  @override
  String get psiphonConnecting => 'සම්බන්ධ වෙමින්…';

  @override
  String get psiphonNotRunning =>
      'ක්‍රියාත්මක නැත — නැවත ආරම්භ කිරීමට ස්විචය තට්ටු කරන්න';

  @override
  String get psiphonDescription =>
      'වේගවත් tunnel (~3s bootstrap, 2000+ කරකැවෙන VPS)';

  @override
  String get turnCommunityServers => 'ප්‍රජා TURN සේවාදායක';

  @override
  String get turnCustomServer => 'අභිරුචි TURN සේවාදායකය (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN සේවාදායක දැනටමත් සංකේතනය කළ ප්‍රවාහ (DTLS-SRTP) පමණක් relay කරයි. Relay ක්‍රියාකරුවෙකුට ඔබේ IP සහ ගමනාගමන පරිමාව දැක ගත හැක, නමුත් ඇමතුම් විකේතනය කළ නොහැක. සෘජු P2P අසාර්ථක වූ විට පමණක් TURN භාවිතා කෙරේ (සම්බන්ධතාවල ~15–20%).';

  @override
  String get turnFreeLabel => 'නොමිලේ';

  @override
  String get turnServerUrlLabel => 'TURN සේවාදායක URL';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 හෝ turns:...';

  @override
  String get turnUsernameLabel => 'පරිශීලක නාමය';

  @override
  String get turnPasswordLabel => 'මුරපදය';

  @override
  String get turnOptionalHint => 'විකල්ප';

  @override
  String get turnCustomInfo =>
      'උපරිම පාලනය සඳහා ඕනෑම \$5/මස VPS එකක coturn ස්වයං-ධාරකත්වය කරන්න. අක්තපත්‍ර දේශීයව ගබඩා කෙරේ.';

  @override
  String get themePickerAppearance => 'පෙනුම';

  @override
  String get themePickerAccentColor => 'උච්චාරණ වර්ණය';

  @override
  String get themeModeLight => 'ආලෝක';

  @override
  String get themeModeDark => 'අඳුරු';

  @override
  String get themeModeSystem => 'පද්ධතිය';

  @override
  String get themeDynamicPresets => 'පෙර සැකසුම්';

  @override
  String get themeDynamicPrimaryColor => 'ප්‍රාථමික වර්ණය';

  @override
  String get themeDynamicBorderRadius => 'මායිම් අරය';

  @override
  String get themeDynamicFont => 'අකුර';

  @override
  String get themeDynamicAppearance => 'පෙනුම';

  @override
  String get themeDynamicUiStyle => 'UI මෝස්තරය';

  @override
  String get themeDynamicUiStyleDescription =>
      'සංවාද, ස්විච සහ දර්ශක පෙනෙන ආකාරය පාලනය කරයි.';

  @override
  String get themeDynamicSharp => 'තියුණු';

  @override
  String get themeDynamicRound => 'වටකුරු';

  @override
  String get themeDynamicModeDark => 'අඳුරු';

  @override
  String get themeDynamicModeLight => 'ආලෝක';

  @override
  String get themeDynamicModeAuto => 'ස්වයංක්‍රීය';

  @override
  String get themeDynamicPlatformAuto => 'ස්වයංක්‍රීය';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'අවලංගු Firebase URL. අපේක්ෂිත: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'අවලංගු relay URL. අපේක්ෂිත: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'අවලංගු Pulse සේවාදායක URL. අපේක්ෂිත: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'සේවාදායක URL';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'ආරාධනා කේතය';

  @override
  String get providerPulseInviteHint => 'ආරාධනා කේතය (අවශ්‍ය නම්)';

  @override
  String get providerPulseInfo =>
      'ස්වයං-ධාරකත්ව relay. ඔබේ ප්‍රතිසාධන මුරපදයෙන් යතුරු ව්‍යුත්පන්න කෙරේ.';

  @override
  String get providerScreenTitle => 'ලැබෙන පෙට්ටි';

  @override
  String get providerSecondaryInboxesHeader => 'ද්වීතීයික ලැබෙන පෙට්ටි';

  @override
  String get providerSecondaryInboxesInfo =>
      'ද්වීතීයික ලැබෙන පෙට්ටි අතිරික්තභාවය සඳහා එකවරම පණිවිඩ ලබා ගනී.';

  @override
  String get providerRemoveTooltip => 'ඉවත් කරන්න';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... හෝ hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... හෝ hex පුද්ගලික යතුර';

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
  String get emojiNoRecent => 'මෑතකාලීන emoji නැත';

  @override
  String get emojiSearchHint => 'Emoji සොයන්න...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'කතාබහ කිරීමට තට්ටු කරන්න';

  @override
  String get imageViewerSaveToDownloads => 'Downloads වෙත සුරකින්න';

  @override
  String imageViewerSavedTo(String path) {
    return '$path වෙත සුරකින ලදී';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'හරි';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'භාෂාව';

  @override
  String get settingsLanguageSubtitle => 'යෙදුම් දර්ශන භාෂාව';

  @override
  String get settingsLanguageSystem => 'පද්ධති පෙරනිමිය';

  @override
  String get onboardingLanguageTitle => 'ඔබේ භාෂාව තෝරන්න';

  @override
  String get onboardingLanguageSubtitle =>
      'ඔබට මෙය පසුව සැකසුම් වලින් වෙනස් කළ හැක';

  @override
  String get videoNoteRecord => 'වීඩියෝ පණිවිඩය පටිගත කරන්න';

  @override
  String get videoNoteTapToRecord => 'පටිගත කිරීමට තට්ටු කරන්න';

  @override
  String get videoNoteTapToStop => 'නතර කිරීමට තට්ටු කරන්න';

  @override
  String get videoNoteCameraPermission => 'කැමරා අවසරය ප්‍රතික්ෂේප විය';

  @override
  String get videoNoteMaxDuration => 'උපරිම තත්පර 30';

  @override
  String get videoNoteNotSupported =>
      'මෙම වේදිකාවේ වීඩියෝ සටහන් සඳහා සහාය නොමැත';

  @override
  String get navChats => 'කතාබස්';

  @override
  String get navUpdates => 'යාවත්කාලීන';

  @override
  String get navCalls => 'ඇමතුම්';

  @override
  String get filterAll => 'සියල්ල';

  @override
  String get filterUnread => 'නොකියවූ';

  @override
  String get filterGroups => 'කණ්ඩායම්';

  @override
  String get callsNoRecent => 'මෑත ඇමතුම් නැත';

  @override
  String get callsEmptySubtitle => 'ඔබේ ඇමතුම් ඉතිහාසය මෙහි දිස්වේ';

  @override
  String get appBarEncrypted => 'අවසාන-සිට-අවසාන ගුප්තකේතනය';

  @override
  String get newStatus => 'නව තත්වය';

  @override
  String get newCall => 'නව ඇමතුම';

  @override
  String get joinChannelTitle => 'නාලිකාවට සම්බන්ධ වන්න';

  @override
  String get joinChannelDescription => 'නාලිකා URL';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'නාලිකා තොරතුරු ලබා ගනිමින්…';

  @override
  String get joinChannelNotFound => 'මෙම URL හි නාලිකාවක් හමු නොවීය';

  @override
  String get joinChannelNetworkError => 'සේවාදායකයට සම්බන්ධ විය නොහැක';

  @override
  String get joinChannelAlreadyJoined => 'දැනටමත් සම්බන්ධයි';

  @override
  String get joinChannelButton => 'සම්බන්ධ වන්න';

  @override
  String get channelFeedEmpty => 'තවම පළ කිරීම් නැත';

  @override
  String get channelLeave => 'නාලිකාව අත්හරින්න';

  @override
  String get channelLeaveConfirm =>
      'මෙම නාලිකාව අත්හරිනවාද? සුරැකි පළ කිරීම් මකනු ලැබේ.';

  @override
  String get channelInfo => 'නාලිකා තොරතුරු';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'සංස්කරණය කළ';

  @override
  String get channelLoadMore => 'තව පූරණය කරන්න';

  @override
  String get channelSearchPosts => 'පොස්ට් සොයන්න…';

  @override
  String get channelNoResults => 'ගැලඵිය පොස්ට් නැත';

  @override
  String get channelUrl => 'චැනල් URL';

  @override
  String get channelCreated => 'එක් වූ';

  @override
  String channelPostCount(int count) {
    return '$count පොස්ට්';
  }

  @override
  String get channelCopyUrl => 'URL පිටපත් කරන්න';

  @override
  String get setupNext => 'ඊළඟ';

  @override
  String get setupKeyWarning =>
      'A recovery key will be generated for you. It is the only way to restore your account on a new device — there is no server, no password reset.';

  @override
  String get setupKeyTitle => 'Your Recovery Key';

  @override
  String get setupKeySubtitle =>
      'Write this key down and store it in a safe place. You will need it to restore your account on a new device.';

  @override
  String get setupKeyCopied => 'පිටපත් කළා!';

  @override
  String get setupKeyWroteItDown => 'ලියා තැබුවා';

  @override
  String get setupKeyWarnBody =>
      'Write this key down as a backup. You can also view it later in Settings → Security.';

  @override
  String get setupVerifyTitle => 'Verify Recovery Key';

  @override
  String get setupVerifySubtitle =>
      'Re-enter your recovery key to confirm you saved it correctly.';

  @override
  String get setupVerifyButton => 'සත්‍යාපනය';

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
  String get settingsViewRecoveryKey => 'ප්‍රතිසාධන යතුර බලන්න';

  @override
  String get settingsViewRecoveryKeySubtitle =>
      'ඔබගේ ගිණුම් ප්‍රතිසාධන යතුර පෙන්වන්න';

  @override
  String get settingsRecoveryKeyNotStored =>
      'ප්‍රතිසාධන යතුර ලබා ගත නොහැක (මෙම විශේෂාංගයට පෙර නිර්මාණය කරන ලදී)';

  @override
  String get settingsRecoveryKeyWarning =>
      'මෙම යතුර ආරක්ෂිතව තබන්න. එය ඇති ඕනෑම කෙනෙකුට වෙනත් උපාංගයක ඔබගේ ගිණුම ප්‍රතිසාධනය කළ හැක.';

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
}
