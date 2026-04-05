// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'መልዕክቶችን ፈልግ...';

  @override
  String get search => 'ፈልግ';

  @override
  String get clearSearch => 'ፍለጋን አጽዳ';

  @override
  String get closeSearch => 'ፍለጋን ዝጋ';

  @override
  String get moreOptions => 'ተጨማሪ አማራጮች';

  @override
  String get back => 'ተመለስ';

  @override
  String get cancel => 'ሰርዝ';

  @override
  String get close => 'ዝጋ';

  @override
  String get confirm => 'አረጋግጥ';

  @override
  String get remove => 'አስወግድ';

  @override
  String get save => 'አስቀምጥ';

  @override
  String get add => 'አክል';

  @override
  String get copy => 'ቅዳ';

  @override
  String get skip => 'ዝለል';

  @override
  String get done => 'ተጠናቋል';

  @override
  String get apply => 'ተግብር';

  @override
  String get export => 'ላክ';

  @override
  String get import => 'አስገባ';

  @override
  String get homeNewGroup => 'አዲስ ቡድን';

  @override
  String get homeSettings => 'ቅንብሮች';

  @override
  String get homeSearching => 'መልዕክቶችን በመፈለግ ላይ...';

  @override
  String get homeNoResults => 'ምንም ውጤት አልተገኘም';

  @override
  String get homeNoChatHistory => 'እስካሁን የውይይት ታሪክ የለም';

  @override
  String homeTransportSwitched(String address) {
    return 'ትራንስፖርት ተቀይሯል → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name እየደወለ/ች ነው...';
  }

  @override
  String get homeAccept => 'ቀበል';

  @override
  String get homeDecline => 'ውድቅ አድርግ';

  @override
  String get homeLoadEarlier => 'ቀደም ያሉ መልዕክቶችን ጫን';

  @override
  String get homeChats => 'ውይይቶች';

  @override
  String get homeSelectConversation => 'ውይይት ይምረጡ';

  @override
  String get homeNoChatsYet => 'እስካሁን ውይይቶች የሉም';

  @override
  String get homeAddContactToStart => 'ውይይት ለመጀመር እውቂያ ያክሉ';

  @override
  String get homeNewChat => 'አዲስ ውይይት';

  @override
  String get homeNewChatTooltip => 'አዲስ ውይይት';

  @override
  String get homeIncomingCallTitle => 'ገቢ ጥሪ';

  @override
  String get homeIncomingGroupCallTitle => 'ገቢ የቡድን ጥሪ';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — የቡድን ጥሪ ገቢ';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'ከ\"$query\" ጋር የሚዛመዱ ውይይቶች የሉም';
  }

  @override
  String get homeSectionChats => 'ውይይቶች';

  @override
  String get homeSectionMessages => 'መልዕክቶች';

  @override
  String get homeDbEncryptionUnavailable =>
      'የመረጃ ቋት ምስጠራ አይገኝም — ሙሉ ጥበቃ ለማግኘት SQLCipher ይጫኑ';

  @override
  String get chatFileTooLargeGroup =>
      'ከ512 KB በላይ ያሉ ፋይሎች በቡድን ውይይቶች ውስጥ አይደገፉም';

  @override
  String get chatLargeFile => 'ትልቅ ፋይል';

  @override
  String get chatCancel => 'ሰርዝ';

  @override
  String get chatSend => 'ላክ';

  @override
  String get chatFileTooLarge => 'ፋይል በጣም ትልቅ ነው — ከፍተኛ መጠን 100 MB ነው';

  @override
  String get chatMicDenied => 'የማይክሮፎን ፈቃድ ተከልክሏል';

  @override
  String get chatVoiceFailed => 'የድምጽ መልዕክት ማስቀመጥ አልተሳካም — ያለውን ማከማቻ ያረጋግጡ';

  @override
  String get chatScheduleFuture => 'የታቀደው ጊዜ ወደፊት መሆን አለበት';

  @override
  String get chatToday => 'ዛሬ';

  @override
  String get chatYesterday => 'ትናንት';

  @override
  String get chatEdited => 'ተስተካክሏል';

  @override
  String get chatYou => 'እርስዎ';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'ይህ ፋይል $size MB ነው። ትላልቅ ፋይሎችን መላክ በአንዳንድ አውታረ መረቦች ላይ ቀርፋፋ ሊሆን ይችላል። ይቀጥሉ?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'የ$name የደኅንነት ቁልፍ ተቀይሯል። ለማረጋገጥ መታ ያድርጉ።';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'መልዕክትን ወደ $name ማመስጠር አልተቻለም — መልዕክት አልተላከም።';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'የ$name የደኅንነት ቁጥር ተቀይሯል። ለማረጋገጥ መታ ያድርጉ።';
  }

  @override
  String get chatNoMessagesFound => 'ምንም መልዕክቶች አልተገኙም';

  @override
  String get chatMessagesE2ee => 'መልዕክቶች ከጫፍ-ወደ-ጫፍ የተመሰጠሩ ናቸው';

  @override
  String get chatSayHello => 'ሰላም በሉ';

  @override
  String get appBarOnline => 'በመስመር ላይ';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'በመጻፍ ላይ';

  @override
  String get appBarSearchMessages => 'መልዕክቶችን ፈልግ...';

  @override
  String get appBarMute => 'ድምጽ ዝጋ';

  @override
  String get appBarUnmute => 'ድምጽ ክፈት';

  @override
  String get appBarMedia => 'ሚዲያ';

  @override
  String get appBarDisappearing => 'የሚጠፉ መልዕክቶች';

  @override
  String get appBarDisappearingOn => 'የሚጠፉ: በርቷል';

  @override
  String get appBarGroupSettings => 'የቡድን ቅንብሮች';

  @override
  String get appBarSearchTooltip => 'መልዕክቶችን ፈልግ';

  @override
  String get appBarVoiceCall => 'የድምጽ ጥሪ';

  @override
  String get appBarVideoCall => 'የቪዲዮ ጥሪ';

  @override
  String get inputMessage => 'መልዕክት...';

  @override
  String get inputAttachFile => 'ፋይል አያይዝ';

  @override
  String get inputSendMessage => 'መልዕክት ላክ';

  @override
  String get inputRecordVoice => 'የድምጽ መልዕክት ቅዳ';

  @override
  String get inputSendVoice => 'የድምጽ መልዕክት ላክ';

  @override
  String get inputCancelReply => 'መልስን ሰርዝ';

  @override
  String get inputCancelEdit => 'ማስተካከያን ሰርዝ';

  @override
  String get inputCancelRecording => 'ቅጂን ሰርዝ';

  @override
  String get inputRecording => 'በመቅዳት ላይ…';

  @override
  String get inputEditingMessage => 'መልዕክት በማስተካከል ላይ';

  @override
  String get inputPhoto => 'ፎቶ';

  @override
  String get inputVoiceMessage => 'የድምጽ መልዕክት';

  @override
  String get inputFile => 'ፋይል';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ቶች',
      one: '',
    );
    return '$count የታቀደ መልዕክት$_temp0';
  }

  @override
  String get callInitializing => 'ጥሪን በማዘጋጀት ላይ…';

  @override
  String get callConnecting => 'በማገናኘት ላይ…';

  @override
  String get callConnectingRelay => 'በማገናኘት ላይ (ሪሌይ)…';

  @override
  String get callSwitchingRelay => 'ወደ ሪሌይ ሁነታ በመቀየር ላይ…';

  @override
  String get callConnectionFailed => 'ግንኙነት ተሳክቶ አልተገኘም';

  @override
  String get callReconnecting => 'እንደገና በማገናኘት ላይ…';

  @override
  String get callEnded => 'ጥሪ ተጠናቀቀ';

  @override
  String get callLive => 'በቀጥታ';

  @override
  String get callEnd => 'ጨርስ';

  @override
  String get callEndCall => 'ጥሪን ጨርስ';

  @override
  String get callMute => 'ድምጽ ዝጋ';

  @override
  String get callUnmute => 'ድምጽ ክፈት';

  @override
  String get callSpeaker => 'ድምጽ ማጉያ';

  @override
  String get callCameraOn => 'ካሜራ በርቷል';

  @override
  String get callCameraOff => 'ካሜራ ጠፍቷል';

  @override
  String get callShareScreen => 'ማያ ገጽ አጋራ';

  @override
  String get callStopShare => 'ማጋራት አቁም';

  @override
  String callTorBackup(String duration) {
    return 'Tor ምትኬ · $duration';
  }

  @override
  String get callTorBackupBanner => 'Tor ምትኬ ንቁ ነው — ዋና መንገድ አይገኝም';

  @override
  String get callDirectFailed => 'ቀጥተኛ ግንኙነት አልተሳካም — ወደ ሪሌይ ሁነታ በመቀየር ላይ…';

  @override
  String get callTurnUnreachable =>
      'TURN አገልጋዮች ሊደረሱ አልቻሉም። በቅንብሮች → የላቀ ውስጥ ብጁ TURN ያክሉ።';

  @override
  String get callRelayMode => 'የሪሌይ ሁነታ ንቁ ነው (የተገደበ አውታረ መረብ)';

  @override
  String get callStarting => 'ጥሪን በመጀመር ላይ…';

  @override
  String get callConnectingToGroup => 'ወደ ቡድን በማገናኘት ላይ…';

  @override
  String get callGroupOpenedInBrowser => 'የቡድን ጥሪ በአሳሽ ውስጥ ተከፈተ';

  @override
  String get callCouldNotOpenBrowser => 'አሳሹን መክፈት አልተቻለም';

  @override
  String get callInviteLinkSent => 'የግብዣ ማስፈንጠሪያ ለሁሉም የቡድን አባላት ተልኳል።';

  @override
  String get callOpenLinkManually =>
      'ከላይ ያለውን ማስፈንጠሪያ በእጅ ይክፈቱ ወይም እንደገና ለመሞከር መታ ያድርጉ።';

  @override
  String get callJitsiNotE2ee => 'Jitsi ጥሪዎች ከጫፍ-ወደ-ጫፍ የተመሰጠሩ አይደሉም';

  @override
  String get callRetryOpenBrowser => 'አሳሽ እንደገና ክፈት';

  @override
  String get callClose => 'ዝጋ';

  @override
  String get callCamOn => 'ካሜራ በርቷል';

  @override
  String get callCamOff => 'ካሜራ ጠፍቷል';

  @override
  String get noConnection => 'ግንኙነት የለም — መልዕክቶች ተራ ይጠብቃሉ';

  @override
  String get connected => 'ተገናኝቷል';

  @override
  String get connecting => 'በማገናኘት ላይ…';

  @override
  String get disconnected => 'ተቋርጧል';

  @override
  String get offlineBanner =>
      'ግንኙነት የለም — መልዕክቶች ተራ ውስጥ ይቆያሉ እና እንደገና ሲገናኙ ይላካሉ';

  @override
  String get lanModeBanner => 'LAN ሁነታ — ኢንተርኔት የለም · የአካባቢ አውታረ መረብ ብቻ';

  @override
  String get probeCheckingNetwork => 'የአውታረ መረብ ግንኙነትን በመፈተሽ ላይ…';

  @override
  String get probeDiscoveringRelays => 'በማህበረሰብ ማውጫዎች በኩል ሪሌይዎችን በማግኘት ላይ…';

  @override
  String get probeStartingTor => 'Tor ለማስጀመር በማዘጋጀት ላይ…';

  @override
  String get probeFindingRelaysTor => 'በTor በኩል ሊደረሱ የሚችሉ ሪሌይዎችን በመፈለግ ላይ…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ዎች',
      one: '',
    );
    return 'አውታረ መረብ ዝግጁ ነው — $count ሪሌይ$_temp0 ተገኝቷል';
  }

  @override
  String get probeNoRelaysFound => 'ሊደረሱ የሚችሉ ሪሌይዎች አልተገኙም — መልዕክቶች ሊዘገዩ ይችላሉ';

  @override
  String get jitsiWarningTitle => 'ከጫፍ-ወደ-ጫፍ የተመሰጠረ አይደለም';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet ጥሪዎች በPulse አይመሰጠሩም። ለሚስጥራዊ ያልሆኑ ውይይቶች ብቻ ይጠቀሙ።';

  @override
  String get jitsiConfirm => 'ቢሆንም ተቀላቀል';

  @override
  String get jitsiGroupWarningTitle => 'ከጫፍ-ወደ-ጫፍ የተመሰጠረ አይደለም';

  @override
  String get jitsiGroupWarningBody =>
      'ይህ ጥሪ ለአብሮ የተገነባው የተመሰጠረ mesh ከሚችለው በላይ ተሳታፊዎች አሉት።\n\nየJitsi Meet ማስፈንጠሪያ በአሳሽዎ ውስጥ ይከፈታል። Jitsi ከጫፍ-ወደ-ጫፍ የተመሰጠረ አይደለም — አገልጋዩ ጥሪዎን ማየት ይችላል።';

  @override
  String get jitsiContinueAnyway => 'ቢሆንም ቀጥል';

  @override
  String get retry => 'እንደገና ሞክር';

  @override
  String get setupCreateAnonymousAccount => 'ማንነት-አልባ መለያ ፍጠር';

  @override
  String get setupTapToChangeColor => 'ቀለም ለመቀየር መታ ያድርጉ';

  @override
  String get setupReqMinLength => 'ቢያንስ 16 ቁምፊዎች';

  @override
  String get setupReqVariety => 'ከ4 ውስጥ 3፡ ትልቅ፣ ትንሽ ፊደሎች፣ ቁጥሮች፣ ምልክቶች';

  @override
  String get setupReqMatch => 'የይለፍ ቃሎቹ ይዛመዳሉ';

  @override
  String get setupYourNickname => 'ቅጽል ስምዎ';

  @override
  String get setupRecoveryPassword => 'የማገገሚያ የይለፍ ቃል (ዝቅተኛ 16)';

  @override
  String get setupConfirmPassword => 'የይለፍ ቃል ያረጋግጡ';

  @override
  String get setupMin16Chars => 'ቢያንስ 16 ቁምፊዎች';

  @override
  String get setupPasswordsDoNotMatch => 'የይለፍ ቃሎች አይዛመዱም';

  @override
  String get setupEntropyWeak => 'ደካማ';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'ጠንካራ';

  @override
  String get setupEntropyWeakNeedsVariety => 'ደካማ (3 የቁምፊ ዓይነቶች ያስፈልጋሉ)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits ቢት)';
  }

  @override
  String get setupPasswordWarning =>
      'ይህ የይለፍ ቃል መለያዎን ለመመለስ ብቸኛው መንገድ ነው። ምንም አገልጋይ የለም — የይለፍ ቃል ዳግም ማስጀመር የለም። ያስታውሱት ወይም ይጻፉት።';

  @override
  String get setupCreateAccount => 'መለያ ፍጠር';

  @override
  String get setupAlreadyHaveAccount => 'መለያ አለዎት? ';

  @override
  String get setupRestore => 'መልስ →';

  @override
  String get restoreTitle => 'መለያ መልስ';

  @override
  String get restoreInfoBanner =>
      'የማገገሚያ የይለፍ ቃልዎን ያስገቡ — አድራሻዎ (Nostr + Session) በራስ-ሰር ይመለሳል። እውቂያዎች እና መልዕክቶች በአካባቢው ብቻ ተከማችተው ነበር።';

  @override
  String get restoreNewNickname => 'አዲስ ቅጽል ስም (በኋላ ሊቀየር ይችላል)';

  @override
  String get restoreButton => 'መለያ መልስ';

  @override
  String get lockTitle => 'Pulse ተቆልፏል';

  @override
  String get lockSubtitle => 'ለመቀጠል የይለፍ ቃልዎን ያስገቡ';

  @override
  String get lockPasswordHint => 'የይለፍ ቃል';

  @override
  String get lockUnlock => 'ክፈት';

  @override
  String get lockPanicHint => 'የይለፍ ቃልዎን ረሱ? ሁሉንም ውሂብ ለመደምሰስ የድንጋጤ ቁልፍዎን ያስገቡ።';

  @override
  String get lockTooManyAttempts => 'በጣም ብዙ ሙከራዎች። ሁሉንም ውሂብ በመደምሰስ ላይ…';

  @override
  String get lockWrongPassword => 'ትክክል ያልሆነ የይለፍ ቃል';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'ትክክል ያልሆነ የይለፍ ቃል — $attempts/$max ሙከራዎች';
  }

  @override
  String get onboardingSkip => 'ዝለል';

  @override
  String get onboardingNext => 'ቀጣይ';

  @override
  String get onboardingGetStarted => 'ጀምር';

  @override
  String get onboardingWelcomeTitle => 'እንኳን ወደ Pulse በደህና መጡ';

  @override
  String get onboardingWelcomeBody =>
      'ያልተማከለ፣ ከጫፍ-ወደ-ጫፍ የተመሰጠረ መልዕክት ላኪ።\n\nምንም ማዕከላዊ አገልጋዮች። ምንም የውሂብ ማሰባሰብ። ምንም የጀርባ በሮች።\nውይይቶችዎ የእርስዎ ብቻ ናቸው።';

  @override
  String get onboardingTransportTitle => 'ትራንስፖርት-ገለልተኛ';

  @override
  String get onboardingTransportBody =>
      'Firebase፣ Nostr ወይም ሁለቱንም በአንድ ጊዜ ይጠቀሙ።\n\nመልዕክቶች በራስ-ሰር በአውታረ መረቦች ውስጥ ይዘዋወራሉ። አብሮ የተገነባ Tor እና I2P ድጋፍ ለሳንሱር መቋቋም።';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'እያንዳንዱ መልዕክት በSignal Protocol (Double Ratchet + X3DH) ለፎርዋርድ ሚስጥራዊነት ይመሰጠራል።\n\nበተጨማሪ በKyber-1024 ተሸፍኗል — የNIST-ስታንዳርድ post-quantum ስልተ-ቀመር — ከወደፊት የኳንተም ኮምፒውተሮች ለመጠበቅ።';

  @override
  String get onboardingKeysTitle => 'ቁልፎችዎ የእርስዎ ናቸው';

  @override
  String get onboardingKeysBody =>
      'የማንነት ቁልፎችዎ ከመሳሪያዎ ፈጽሞ አይወጡም።\n\nSignal ፊንገርፕሪንቶች እውቂያዎችን ከመስመር ውጭ እንዲያረጋግጡ ያስችላሉ። TOFU (Trust On First Use) የቁልፍ ለውጦችን በራስ-ሰር ያገኛል።';

  @override
  String get onboardingThemeTitle => 'መልክዎን ይምረጡ';

  @override
  String get onboardingThemeBody =>
      'ገጽታ እና የአጽንዖት ቀለም ይምረጡ። ይህን በማንኛውም ጊዜ በቅንብሮች ውስጥ ሊቀይሩት ይችላሉ።';

  @override
  String get contactsNewChat => 'አዲስ ውይይት';

  @override
  String get contactsAddContact => 'እውቂያ አክል';

  @override
  String get contactsSearchHint => 'ፈልግ...';

  @override
  String get contactsNewGroup => 'አዲስ ቡድን';

  @override
  String get contactsNoContactsYet => 'እስካሁን እውቂያዎች የሉም';

  @override
  String get contactsAddHint => 'የሰው አድራሻ ለማከል + ን መታ ያድርጉ';

  @override
  String get contactsNoMatch => 'የሚዛመዱ እውቂያዎች የሉም';

  @override
  String get contactsRemoveTitle => 'እውቂያን አስወግድ';

  @override
  String contactsRemoveMessage(String name) {
    return '$nameን ያስወግዱ?';
  }

  @override
  String get contactsRemove => 'አስወግድ';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ዎች',
      one: '',
    );
    return '$count እውቂያ$_temp0';
  }

  @override
  String get bubbleOpenLink => 'ማስፈንጠሪያ ክፈት';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'ይህን URL በአሳሽዎ ውስጥ ይክፈቱ?\n\n$url';
  }

  @override
  String get bubbleOpen => 'ክፈት';

  @override
  String get bubbleSecurityWarning => 'የደኅንነት ማስጠንቀቂያ';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" ሊፈጸም የሚችል ፋይል ዓይነት ነው። ማስቀመጥ እና ማስኬድ መሳሪያዎን ሊጎዳ ይችላል። ቢሆንም ያስቀምጡ?';
  }

  @override
  String get bubbleSaveAnyway => 'ቢሆንም አስቀምጥ';

  @override
  String bubbleSavedTo(String path) {
    return 'ወደ $path ተቀምጧል';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'ማስቀመጥ አልተሳካም: $error';
  }

  @override
  String get bubbleNotEncrypted => 'አልተመሰጠረም';

  @override
  String get bubbleCorruptedImage => '[የተበላሸ ምስል]';

  @override
  String get bubbleReplyPhoto => 'ፎቶ';

  @override
  String get bubbleReplyVoice => 'የድምጽ መልዕክት';

  @override
  String get bubbleReplyVideo => 'የቪዲዮ መልዕክት';

  @override
  String bubbleReadBy(String names) {
    return 'በ$names ተነብቧል';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'በ$count ተነብቧል';
  }

  @override
  String get chatTileTapToStart => 'ውይይት ለመጀመር መታ ያድርጉ';

  @override
  String get chatTileMessageSent => 'መልዕክት ተልኳል';

  @override
  String get chatTileEncryptedMessage => 'የተመሰጠረ መልዕክት';

  @override
  String chatTileYouPrefix(String text) {
    return 'እርስዎ: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 የድምፅ መልዕክት';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 የድምፅ መልዕክት ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'የተመሰጠረ መልዕክት';

  @override
  String get groupNewGroup => 'አዲስ ቡድን';

  @override
  String get groupGroupName => 'የቡድን ስም';

  @override
  String get groupSelectMembers => 'አባላትን ይምረጡ (ዝቅተኛ 2)';

  @override
  String get groupNoContactsYet => 'እስካሁን እውቂያዎች የሉም። መጀመሪያ እውቂያዎችን ያክሉ።';

  @override
  String get groupCreate => 'ፍጠር';

  @override
  String get groupLabel => 'ቡድን';

  @override
  String get profileVerifyIdentity => 'ማንነት አረጋግጥ';

  @override
  String profileVerifyInstructions(String name) {
    return 'እነዚህን ፊንገርፕሪንቶች ከ$name ጋር በድምጽ ጥሪ ወይም በአካል ያነጻጽሩ። ሁለቱም ዋጋዎች በሁለቱም መሳሪያዎች ላይ ከተዛመዱ \"እንደተረጋገጠ ምልክት አድርግ\" ን መታ ያድርጉ።';
  }

  @override
  String get profileTheirKey => 'የእነርሱ ቁልፍ';

  @override
  String get profileYourKey => 'የእርስዎ ቁልፍ';

  @override
  String get profileRemoveVerification => 'ማረጋገጫን አስወግድ';

  @override
  String get profileMarkAsVerified => 'እንደተረጋገጠ ምልክት አድርግ';

  @override
  String get profileAddressCopied => 'አድራሻ ተቀድቷል';

  @override
  String get profileNoContactsToAdd => 'የሚታከሉ እውቂያዎች የሉም — ሁሉም ቀድሞውኑ አባላት ናቸው';

  @override
  String get profileAddMembers => 'አባላት አክል';

  @override
  String profileAddCount(int count) {
    return 'አክል ($count)';
  }

  @override
  String get profileRenameGroup => 'ቡድን ዳግም ሰይም';

  @override
  String get profileRename => 'ዳግም ሰይም';

  @override
  String get profileRemoveMember => 'አባልን ያስወግዱ?';

  @override
  String profileRemoveMemberBody(String name) {
    return '$nameን ከዚህ ቡድን ያስወግዱ?';
  }

  @override
  String get profileKick => 'አስወጣ';

  @override
  String get profileSignalFingerprints => 'Signal ፊንገርፕሪንቶች';

  @override
  String get profileVerified => 'ተረጋግጧል';

  @override
  String get profileVerify => 'አረጋግጥ';

  @override
  String get profileEdit => 'አስተካክል';

  @override
  String get profileNoSession => 'እስካሁን ምንም ክፍለ ጊዜ አልተቋቋመም — መጀመሪያ መልዕክት ይላኩ።';

  @override
  String get profileFingerprintCopied => 'ፊንገርፕሪንት ተቀድቷል';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ዎች',
      one: '',
    );
    return '$count አባል$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'የደኅንነት ቁጥር አረጋግጥ';

  @override
  String get profileShowContactQr => 'የእውቂያ QR አሳይ';

  @override
  String profileContactAddress(String name) {
    return 'የ$name አድራሻ';
  }

  @override
  String get profileExportChatHistory => 'የውይይት ታሪክ ላክ';

  @override
  String profileSavedTo(String path) {
    return 'ወደ $path ተቀምጧል';
  }

  @override
  String get profileExportFailed => 'መላክ አልተሳካም';

  @override
  String get profileClearChatHistory => 'የውይይት ታሪክ አጽዳ';

  @override
  String get profileDeleteGroup => 'ቡድን ሰርዝ';

  @override
  String get profileDeleteContact => 'እውቂያ ሰርዝ';

  @override
  String get profileLeaveGroup => 'ቡድን ልቀቅ';

  @override
  String get profileLeaveGroupBody => 'ከዚህ ቡድን ይወገዳሉ እና ከእውቂያዎችዎ ይሰረዛል።';

  @override
  String get groupInviteTitle => 'የቡድን ግብዣ';

  @override
  String groupInviteBody(String from, String group) {
    return '$from ወደ \"$group\" እንዲቀላቀሉ ጋብዘዎታል';
  }

  @override
  String get groupInviteAccept => 'ቀበል';

  @override
  String get groupInviteDecline => 'ውድቅ አድርግ';

  @override
  String get groupMemberLimitTitle => 'በጣም ብዙ ተሳታፊዎች';

  @override
  String groupMemberLimitBody(int count) {
    return 'ይህ ቡድን $count ተሳታፊዎች ይኖሩታል። የተመሰጠሩ mesh ጥሪዎች እስከ 6 ይደግፋሉ። ትልቅ ቡድኖች ወደ Jitsi ይቀየራሉ (E2EE አይደለም)።';
  }

  @override
  String get groupMemberLimitContinue => 'ቢሆንም አክል';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name ወደ \"$group\" መቀላቀልን ውድቅ አድርጓል/ጋል';
  }

  @override
  String get transferTitle => 'ወደ ሌላ መሳሪያ ያስተላልፉ';

  @override
  String get transferInfoBox =>
      'የSignal ማንነትዎን እና Nostr ቁልፎችዎን ወደ አዲስ መሳሪያ ያንቀሳቅሱ።\nየውይይት ክፍለ ጊዜዎች አይተላለፉም — ፎርዋርድ ሚስጥራዊነት ይጠበቃል።';

  @override
  String get transferSendFromThis => 'ከዚህ መሳሪያ ላክ';

  @override
  String get transferSendSubtitle => 'ይህ መሳሪያ ቁልፎቹን ይይዛል። ከአዲሱ መሳሪያ ጋር ኮድ ያጋሩ።';

  @override
  String get transferReceiveOnThis => 'በዚህ መሳሪያ ላይ ተቀበል';

  @override
  String get transferReceiveSubtitle => 'ይህ አዲሱ መሳሪያ ነው። ከድሮው መሳሪያ ኮዱን ያስገቡ።';

  @override
  String get transferChooseMethod => 'የማስተላለፊያ ዘዴ ይምረጡ';

  @override
  String get transferLan => 'LAN (ተመሳሳይ አውታረ መረብ)';

  @override
  String get transferLanSubtitle =>
      'ፈጣን እና ቀጥተኛ። ሁለቱም መሳሪያዎች በተመሳሳይ Wi-Fi ላይ መሆን አለባቸው።';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'ያለውን Nostr relay በመጠቀም በማንኛውም አውታረ መረብ ላይ ይሰራል።';

  @override
  String get transferRelayUrl => 'Relay URL';

  @override
  String get transferEnterCode => 'የማስተላለፊያ ኮድ ያስገቡ';

  @override
  String get transferPasteCode => 'LAN:... ወይም NOS:... ኮድ እዚህ ይለጥፉ';

  @override
  String get transferConnect => 'አገናኝ';

  @override
  String get transferGenerating => 'የማስተላለፊያ ኮድ በማመንጨት ላይ…';

  @override
  String get transferShareCode => 'ይህን ኮድ ከተቀባዩ ጋር ያጋሩ:';

  @override
  String get transferCopyCode => 'ኮድ ቅዳ';

  @override
  String get transferCodeCopied => 'ኮድ ወደ ቅንጥብ ሰሌዳ ተቀድቷል';

  @override
  String get transferWaitingReceiver => 'ተቀባይ እስኪገናኝ በመጠበቅ ላይ…';

  @override
  String get transferConnectingSender => 'ወደ ላኪ በማገናኘት ላይ…';

  @override
  String get transferVerifyBoth =>
      'ይህን ኮድ በሁለቱም መሳሪያዎች ላይ ያነጻጽሩ።\nከተዛመዱ ማስተላለፊያው ደኅነኛ ነው።';

  @override
  String get transferComplete => 'ማስተላለፊያ ተጠናቀቀ';

  @override
  String get transferKeysImported => 'ቁልፎች ተስገብተዋል';

  @override
  String get transferCompleteSenderBody =>
      'ቁልፎችዎ በዚህ መሳሪያ ላይ ንቁ ሆነው ይቆያሉ።\nተቀባዩ አሁን ማንነትዎን ሊጠቀም ይችላል።';

  @override
  String get transferCompleteReceiverBody =>
      'ቁልፎች በተሳካ ሁኔታ ተስገብተዋል።\nአዲሱን ማንነት ለመተግበር መተግበሪያውን እንደገና ያስጀምሩ።';

  @override
  String get transferRestartApp => 'መተግበሪያውን እንደገና አስጀምር';

  @override
  String get transferFailed => 'ማስተላለፊያ አልተሳካም';

  @override
  String get transferTryAgain => 'እንደገና ሞክር';

  @override
  String get transferEnterRelayFirst => 'መጀመሪያ relay URL ያስገቡ';

  @override
  String get transferPasteCodeFromSender => 'የላኪውን የማስተላለፊያ ኮድ ይለጥፉ';

  @override
  String get menuReply => 'መልስ';

  @override
  String get menuForward => 'አስተላልፍ';

  @override
  String get menuReact => 'ምላሽ ስጥ';

  @override
  String get menuCopy => 'ቅዳ';

  @override
  String get menuEdit => 'አስተካክል';

  @override
  String get menuRetry => 'እንደገና ሞክር';

  @override
  String get menuCancelScheduled => 'የታቀደውን ሰርዝ';

  @override
  String get menuDelete => 'ሰርዝ';

  @override
  String get menuForwardTo => 'ወደ… አስተላልፍ';

  @override
  String menuForwardedTo(String name) {
    return 'ወደ $name ተላልፏል';
  }

  @override
  String get menuScheduledMessages => 'የታቀዱ መልዕክቶች';

  @override
  String get menuNoScheduledMessages => 'የታቀዱ መልዕክቶች የሉም';

  @override
  String menuSendsOn(String date) {
    return 'በ$date ይላካል';
  }

  @override
  String get menuDisappearingMessages => 'የሚጠፉ መልዕክቶች';

  @override
  String get menuDisappearingSubtitle => 'መልዕክቶች ከተመረጠው ጊዜ በኋላ በራስ-ሰር ይሰረዛሉ።';

  @override
  String get menuTtlOff => 'ጠፍቷል';

  @override
  String get menuTtl1h => '1 ሰዓት';

  @override
  String get menuTtl24h => '24 ሰዓታት';

  @override
  String get menuTtl7d => '7 ቀናት';

  @override
  String get menuAttachPhoto => 'ፎቶ';

  @override
  String get menuAttachFile => 'ፋይል';

  @override
  String get menuAttachVideo => 'ቪዲዮ';

  @override
  String get mediaTitle => 'ሚዲያ';

  @override
  String get mediaFileLabel => 'ፋይል';

  @override
  String mediaPhotosTab(int count) {
    return 'ፎቶዎች ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'ፋይሎች ($count)';
  }

  @override
  String get mediaNoPhotos => 'እስካሁን ፎቶዎች የሉም';

  @override
  String get mediaNoFiles => 'እስካሁን ፋይሎች የሉም';

  @override
  String mediaSavedToDownloads(String name) {
    return 'ወደ Downloads/$name ተቀምጧል';
  }

  @override
  String get mediaFailedToSave => 'ፋይልን ማስቀመጥ አልተሳካም';

  @override
  String get statusNewStatus => 'አዲስ ሁኔታ';

  @override
  String get statusPublish => 'አትም';

  @override
  String get statusExpiresIn24h => 'ሁኔታ በ24 ሰዓታት ውስጥ ያበቃል';

  @override
  String get statusWhatsOnYourMind => 'ምን እያሰቡ ነው?';

  @override
  String get statusPhotoAttached => 'ፎቶ ተያይዟል';

  @override
  String get statusAttachPhoto => 'ፎቶ አያይዝ (አማራጭ)';

  @override
  String get statusEnterText => 'እባክዎ ለሁኔታዎ ጽሑፍ ያስገቡ።';

  @override
  String statusPickPhotoFailed(String error) {
    return 'ፎቶ መምረጥ አልተሳካም: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'ማተም አልተሳካም: $error';
  }

  @override
  String get panicSetPanicKey => 'የድንጋጤ ቁልፍ አስቀምጥ';

  @override
  String get panicEmergencySelfDestruct => 'የአደጋ ጊዜ ራስ-ማጥፋት';

  @override
  String get panicIrreversible => 'ይህ ተግባር የማይቀለበስ ነው';

  @override
  String get panicWarningBody =>
      'ይህን ቁልፍ በመቆለፊያ ማያ ገጹ ላይ ማስገባት ሁሉንም ውሂብ ወዲያውኑ ይደመስሳል — መልዕክቶች፣ እውቂያዎች፣ ቁልፎች፣ ማንነት። ከመደበኛ የይለፍ ቃልዎ የተለየ ቁልፍ ይጠቀሙ።';

  @override
  String get panicKeyHint => 'የድንጋጤ ቁልፍ';

  @override
  String get panicConfirmHint => 'የድንጋጤ ቁልፍ ያረጋግጡ';

  @override
  String get panicMinChars => 'የድንጋጤ ቁልፍ ቢያንስ 8 ቁምፊዎች መሆን አለበት';

  @override
  String get panicKeysDoNotMatch => 'ቁልፎች አይዛመዱም';

  @override
  String get panicSetFailed => 'የድንጋጤ ቁልፍን ማስቀመጥ አልተሳካም — እባክዎ እንደገና ይሞክሩ';

  @override
  String get passwordSetAppPassword => 'የመተግበሪያ የይለፍ ቃል አስቀምጥ';

  @override
  String get passwordProtectsMessages => 'መልዕክቶችዎን በእረፍት ጊዜ ይጠብቃል';

  @override
  String get passwordInfoBanner =>
      'Pulse ን በሚከፍቱ ቁጥር ያስፈልጋል። ከረሱት ውሂብዎ ሊመለስ አይችልም።';

  @override
  String get passwordHint => 'የይለፍ ቃል';

  @override
  String get passwordConfirmHint => 'የይለፍ ቃል ያረጋግጡ';

  @override
  String get passwordSetButton => 'የይለፍ ቃል አስቀምጥ';

  @override
  String get passwordSkipForNow => 'ለአሁን ዝለል';

  @override
  String get passwordMinChars => 'የይለፍ ቃል ቢያንስ 6 ቁምፊዎች መሆን አለበት';

  @override
  String get passwordsDoNotMatch => 'የይለፍ ቃሎች አይዛመዱም';

  @override
  String get profileCardSaved => 'ፕሮፋይል ተቀምጧል!';

  @override
  String get profileCardE2eeIdentity => 'E2EE ማንነት';

  @override
  String get profileCardDisplayName => 'ማሳያ ስም';

  @override
  String get profileCardDisplayNameHint => 'ለምሳሌ አበበ በቀለ';

  @override
  String get profileCardAbout => 'ስለ';

  @override
  String get profileCardSaveProfile => 'ፕሮፋይል አስቀምጥ';

  @override
  String get profileCardYourName => 'ስምዎ';

  @override
  String get profileCardAddressCopied => 'አድራሻ ተቀድቷል!';

  @override
  String get profileCardInboxAddress => 'የገቢ መልዕክት አድራሻዎ';

  @override
  String get profileCardInboxAddresses => 'የገቢ መልዕክት አድራሻዎችዎ';

  @override
  String get profileCardShareAllAddresses => 'ሁሉንም አድራሻዎች አጋራ (SmartRouter)';

  @override
  String get profileCardShareHint => 'እውቂያዎች መልዕክት እንዲልኩልዎ ይህንን ያጋሩ።';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'ሁሉም $count አድራሻዎች እንደ አንድ ማስፈንጠሪያ ተቀድተዋል!';
  }

  @override
  String get settingsMyProfile => 'ፕሮፋይሌ';

  @override
  String get settingsYourInboxAddress => 'የገቢ መልዕክት አድራሻዎ';

  @override
  String get settingsMyQrCode => 'የእኔ QR ኮድ';

  @override
  String get settingsMyQrSubtitle => 'አድራሻዎን እንደ ሊቃኝ QR ያጋሩ';

  @override
  String get settingsShareMyAddress => 'አድራሻዬን አጋራ';

  @override
  String get settingsNoAddressYet => 'እስካሁን አድራሻ የለም — መጀመሪያ ቅንብሮችን ያስቀምጡ';

  @override
  String get settingsInviteLink => 'የግብዣ ማስፈንጠሪያ';

  @override
  String get settingsRawAddress => 'ጥሬ አድራሻ';

  @override
  String get settingsCopyLink => 'ማስፈንጠሪያ ቅዳ';

  @override
  String get settingsCopyAddress => 'አድራሻ ቅዳ';

  @override
  String get settingsInviteLinkCopied => 'የግብዣ ማስፈንጠሪያ ተቀድቷል';

  @override
  String get settingsAppearance => 'መልክ';

  @override
  String get settingsThemeEngine => 'ገጽታ ሞተር';

  @override
  String get settingsThemeEngineSubtitle => 'ቀለሞችን እና ቅርጸ-ቁምፊዎችን ያብጁ';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle => 'E2EE ቁልፎች በደኅንነት ተከማችተዋል';

  @override
  String get settingsActive => 'ንቁ';

  @override
  String get settingsIdentityBackup => 'የማንነት ምትኬ';

  @override
  String get settingsIdentityBackupSubtitle => 'የSignal ማንነትዎን ይላኩ ወይም ያስገቡ';

  @override
  String get settingsIdentityBackupBody =>
      'የSignal ማንነት ቁልፎችዎን ወደ ምትኬ ኮድ ይላኩ ወይም ካለ ምትኬ ይመልሱ።';

  @override
  String get settingsTransferDevice => 'ወደ ሌላ መሳሪያ ያስተላልፉ';

  @override
  String get settingsTransferDeviceSubtitle =>
      'ማንነትዎን በLAN ወይም Nostr relay ያስተላልፉ';

  @override
  String get settingsExportIdentity => 'ማንነት ላክ';

  @override
  String get settingsExportIdentityBody => 'ይህን ምትኬ ኮድ ቅዳ እና በደኅንነት ያስቀምጡ:';

  @override
  String get settingsSaveFile => 'ፋይል አስቀምጥ';

  @override
  String get settingsImportIdentity => 'ማንነት አስገባ';

  @override
  String get settingsImportIdentityBody =>
      'ምትኬ ኮድዎን ከዚህ በታች ይለጥፉ። ይህ የአሁኑን ማንነትዎን ይተካል።';

  @override
  String get settingsPasteBackupCode => 'ምትኬ ኮድ እዚህ ይለጥፉ…';

  @override
  String get settingsIdentityImported =>
      'ማንነት + እውቂያዎች ተስገብተዋል! ለመተግበር መተግበሪያውን እንደገና ያስጀምሩ።';

  @override
  String get settingsSecurity => 'ደኅንነት';

  @override
  String get settingsAppPassword => 'የመተግበሪያ የይለፍ ቃል';

  @override
  String get settingsPasswordEnabled => 'ነቅቷል — በእያንዳንዱ ማስጀመሪያ ያስፈልጋል';

  @override
  String get settingsPasswordDisabled => 'ጠፍቷል — መተግበሪያ ያለ የይለፍ ቃል ይከፈታል';

  @override
  String get settingsChangePassword => 'የይለፍ ቃል ቀይር';

  @override
  String get settingsChangePasswordSubtitle => 'የመተግበሪያ መቆለፊያ የይለፍ ቃል ያዘምኑ';

  @override
  String get settingsSetPanicKey => 'የድንጋጤ ቁልፍ አስቀምጥ';

  @override
  String get settingsChangePanicKey => 'የድንጋጤ ቁልፍ ቀይር';

  @override
  String get settingsPanicKeySetSubtitle => 'የአደጋ ጊዜ ማጥፊያ ቁልፍ ያዘምኑ';

  @override
  String get settingsPanicKeyUnsetSubtitle => 'ሁሉንም ውሂብ ወዲያውኑ የሚደመስስ አንድ ቁልፍ';

  @override
  String get settingsRemovePanicKey => 'የድንጋጤ ቁልፍ አስወግድ';

  @override
  String get settingsRemovePanicKeySubtitle => 'የአደጋ ጊዜ ራስ-ማጥፋት ያሰናክሉ';

  @override
  String get settingsRemovePanicKeyBody =>
      'የአደጋ ጊዜ ራስ-ማጥፋት ይሰናከላል። በማንኛውም ጊዜ እንደገና ማንቃት ይችላሉ።';

  @override
  String get settingsDisableAppPassword => 'የመተግበሪያ የይለፍ ቃል ያሰናክሉ';

  @override
  String get settingsEnterCurrentPassword => 'ለማረጋገጥ የአሁኑን የይለፍ ቃልዎን ያስገቡ';

  @override
  String get settingsCurrentPassword => 'የአሁኑ የይለፍ ቃል';

  @override
  String get settingsIncorrectPassword => 'ትክክል ያልሆነ የይለፍ ቃል';

  @override
  String get settingsPasswordUpdated => 'የይለፍ ቃል ተዘምኗል';

  @override
  String get settingsChangePasswordProceed => 'ለመቀጠል የአሁኑን የይለፍ ቃልዎን ያስገቡ';

  @override
  String get settingsData => 'ውሂብ';

  @override
  String get settingsBackupMessages => 'መልዕክቶችን ምትኬ ውሰድ';

  @override
  String get settingsBackupMessagesSubtitle => 'የተመሰጠረ የመልዕክት ታሪክ ወደ ፋይል ላክ';

  @override
  String get settingsRestoreMessages => 'መልዕክቶችን መልስ';

  @override
  String get settingsRestoreMessagesSubtitle => 'መልዕክቶችን ከምትኬ ፋይል አስገባ';

  @override
  String get settingsExportKeys => 'ቁልፎችን ላክ';

  @override
  String get settingsExportKeysSubtitle => 'የማንነት ቁልፎችን ወደ የተመሰጠረ ፋይል አስቀምጥ';

  @override
  String get settingsImportKeys => 'ቁልፎችን አስገባ';

  @override
  String get settingsImportKeysSubtitle => 'የማንነት ቁልፎችን ከተላከ ፋይል መልስ';

  @override
  String get settingsBackupPassword => 'የምትኬ የይለፍ ቃል';

  @override
  String get settingsPasswordCannotBeEmpty => 'የይለፍ ቃል ባዶ ሊሆን አይችልም';

  @override
  String get settingsPasswordMin4Chars => 'የይለፍ ቃል ቢያንስ 4 ቁምፊዎች መሆን አለበት';

  @override
  String get settingsCallsTurn => 'ጥሪዎች እና TURN';

  @override
  String get settingsLocalNetwork => 'የአካባቢ አውታረ መረብ';

  @override
  String get settingsCensorshipResistance => 'ሳንሱር መቋቋም';

  @override
  String get settingsNetwork => 'አውታረ መረብ';

  @override
  String get settingsProxyTunnels => 'ፕሮክሲ እና ዋሻዎች';

  @override
  String get settingsTurnServers => 'TURN አገልጋዮች';

  @override
  String get settingsProviderTitle => 'አቅራቢ';

  @override
  String get settingsLanFallback => 'LAN ተተኪ';

  @override
  String get settingsLanFallbackSubtitle =>
      'ኢንተርኔት በማይገኝበት ጊዜ በአካባቢ አውታረ መረብ ላይ ተገኝነትን ያሰራጩ እና መልዕክቶችን ያድርሱ። በማይታመኑ አውታረ መረቦች (የሕዝብ Wi-Fi) ላይ ያሰናክሉ።';

  @override
  String get settingsBgDelivery => 'የበስተ ጀርባ ማድረስ';

  @override
  String get settingsBgDeliverySubtitle =>
      'መተግበሪያው ሲቀንስ መልዕክቶችን መቀበል ይቀጥሉ። ቋሚ ማሳወቂያ ያሳያል።';

  @override
  String get settingsYourInboxProvider => 'የገቢ መልዕክት አቅራቢዎ';

  @override
  String get settingsConnectionDetails => 'የግንኙነት ዝርዝሮች';

  @override
  String get settingsSaveAndConnect => 'አስቀምጥ እና አገናኝ';

  @override
  String get settingsSecondaryInboxes => 'ሁለተኛ ደረጃ ገቢ ሳጥኖች';

  @override
  String get settingsAddSecondaryInbox => 'ሁለተኛ ደረጃ ገቢ ሳጥን አክል';

  @override
  String get settingsAdvanced => 'የላቀ';

  @override
  String get settingsDiscover => 'አግኝ';

  @override
  String get settingsAbout => 'ስለ';

  @override
  String get settingsPrivacyPolicy => 'የግለኝነት ፖሊሲ';

  @override
  String get settingsPrivacyPolicySubtitle => 'Pulse ውሂብዎን እንዴት እንደሚጠብቅ';

  @override
  String get settingsCrashReporting => 'የብልሽት ሪፖርት';

  @override
  String get settingsCrashReportingSubtitle =>
      'Pulse ን ለማሻሻል ማንነት-አልባ የብልሽት ሪፖርቶችን ይላኩ። ምንም የመልዕክት ይዘት ወይም እውቂያዎች ፈጽሞ አይላኩም።';

  @override
  String get settingsCrashReportingEnabled =>
      'የብልሽት ሪፖርት ነቅቷል — ለመተግበር መተግበሪያውን እንደገና ያስጀምሩ';

  @override
  String get settingsCrashReportingDisabled =>
      'የብልሽት ሪፖርት ጠፍቷል — ለመተግበር መተግበሪያውን እንደገና ያስጀምሩ';

  @override
  String get settingsSensitiveOperation => 'ስሱ ተግባር';

  @override
  String get settingsSensitiveOperationBody =>
      'እነዚህ ቁልፎች ማንነትዎ ናቸው። ይህ ፋይል ያለው ማንኛውም ሰው እርስዎን ሊመስል ይችላል። በደኅንነት ያስቀምጡት እና ከማስተላለፊያ በኋላ ይሰርዙት።';

  @override
  String get settingsIUnderstandContinue => 'ተረድቻለሁ፣ ቀጥል';

  @override
  String get settingsReplaceIdentity => 'ማንነት ይተኩ?';

  @override
  String get settingsReplaceIdentityBody =>
      'ይህ የአሁኑን የማንነት ቁልፎችዎን ይተካል። ያሉ Signal ክፍለ ጊዜዎች ባዶ ይሆናሉ እና እውቂያዎች ምስጠራን እንደገና ማቋቋም ያስፈልጋቸዋል። መተግበሪያው እንደገና መጀመር ያስፈልጋል።';

  @override
  String get settingsReplaceKeys => 'ቁልፎችን ተካ';

  @override
  String get settingsKeysImported => 'ቁልፎች ተስገብተዋል';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count ቁልፎች በተሳካ ሁኔታ ተስገብተዋል። እባክዎ በአዲሱ ማንነት ለማስጀመር መተግበሪያውን እንደገና ያስጀምሩ።';
  }

  @override
  String get settingsRestartNow => 'አሁን እንደገና አስጀምር';

  @override
  String get settingsLater => 'በኋላ';

  @override
  String get profileGroupLabel => 'ቡድን';

  @override
  String get profileAddButton => 'አክል';

  @override
  String get profileKickButton => 'አስወጣ';

  @override
  String get dataSectionTitle => 'ውሂብ';

  @override
  String get dataBackupMessages => 'መልዕክቶችን ምትኬ ውሰድ';

  @override
  String get dataBackupPasswordSubtitle => 'የመልዕክት ምትኬዎን ለማመስጠር የይለፍ ቃል ይምረጡ።';

  @override
  String get dataBackupConfirmLabel => 'ምትኬ ፍጠር';

  @override
  String get dataCreatingBackup => 'ምትኬ በመፍጠር ላይ';

  @override
  String get dataBackupPreparing => 'በማዘጋጀት ላይ...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'መልዕክት $done ከ$total በመላክ ላይ...';
  }

  @override
  String get dataBackupSavingFile => 'ፋይል በማስቀመጥ ላይ...';

  @override
  String get dataSaveMessageBackupDialog => 'የመልዕክት ምትኬ አስቀምጥ';

  @override
  String dataBackupSaved(int count, String path) {
    return 'ምትኬ ተቀምጧል ($count መልዕክቶች)\n$path';
  }

  @override
  String get dataBackupFailed => 'ምትኬ አልተሳካም — ምንም ውሂብ አልተላከም';

  @override
  String dataBackupFailedError(String error) {
    return 'ምትኬ አልተሳካም: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'የመልዕክት ምትኬ ይምረጡ';

  @override
  String get dataInvalidBackupFile => 'ልክ ያልሆነ የምትኬ ፋይል (በጣም ትንሽ)';

  @override
  String get dataNotValidBackupFile => 'ልክ የሆነ የPulse ምትኬ ፋይል አይደለም';

  @override
  String get dataRestoreMessages => 'መልዕክቶችን መልስ';

  @override
  String get dataRestorePasswordSubtitle =>
      'ይህን ምትኬ ለመፍጠር የተጠቀሙበትን የይለፍ ቃል ያስገቡ።';

  @override
  String get dataRestoreConfirmLabel => 'መልስ';

  @override
  String get dataRestoringMessages => 'መልዕክቶችን በመመለስ ላይ';

  @override
  String get dataRestoreDecrypting => 'በማግለጥ ላይ...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'መልዕክት $done ከ$total በማስገባት ላይ...';
  }

  @override
  String get dataRestoreFailed =>
      'መመለስ አልተሳካም — ትክክል ያልሆነ የይለፍ ቃል ወይም የተበላሸ ፋይል';

  @override
  String dataRestoreSuccess(int count) {
    return '$count አዳዲስ መልዕክቶች ተመልሰዋል';
  }

  @override
  String get dataRestoreNothingNew => 'የሚስገቡ አዳዲስ መልዕክቶች የሉም (ሁሉም ቀድሞውኑ አሉ)';

  @override
  String dataRestoreFailedError(String error) {
    return 'መመለስ አልተሳካም: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'የቁልፍ ላኪ ይምረጡ';

  @override
  String get dataNotValidKeyFile => 'ልክ የሆነ የPulse ቁልፍ ላኪ ፋይል አይደለም';

  @override
  String get dataExportKeys => 'ቁልፎችን ላክ';

  @override
  String get dataExportKeysPasswordSubtitle => 'የቁልፍ ላኪዎን ለማመስጠር የይለፍ ቃል ይምረጡ።';

  @override
  String get dataExportKeysConfirmLabel => 'ላክ';

  @override
  String get dataExportingKeys => 'ቁልፎችን በመላክ ላይ';

  @override
  String get dataExportingKeysStatus => 'የማንነት ቁልፎችን በማመስጠር ላይ...';

  @override
  String get dataSaveKeyExportDialog => 'የቁልፍ ላኪ አስቀምጥ';

  @override
  String dataKeysExportedTo(String path) {
    return 'ቁልፎች ተልከዋል ወደ:\n$path';
  }

  @override
  String get dataExportFailed => 'መላክ አልተሳካም — ምንም ቁልፎች አልተገኙም';

  @override
  String dataExportFailedError(String error) {
    return 'መላክ አልተሳካም: $error';
  }

  @override
  String get dataImportKeys => 'ቁልፎችን አስገባ';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'ይህን ቁልፍ ላኪ ለማመስጠር የተጠቀሙበትን የይለፍ ቃል ያስገቡ።';

  @override
  String get dataImportKeysConfirmLabel => 'አስገባ';

  @override
  String get dataImportingKeys => 'ቁልፎችን በማስገባት ላይ';

  @override
  String get dataImportingKeysStatus => 'የማንነት ቁልፎችን በማግለጥ ላይ...';

  @override
  String get dataImportFailed =>
      'ማስገባት አልተሳካም — ትክክል ያልሆነ የይለፍ ቃል ወይም የተበላሸ ፋይል';

  @override
  String dataImportFailedError(String error) {
    return 'ማስገባት አልተሳካም: $error';
  }

  @override
  String get securitySectionTitle => 'ደኅንነት';

  @override
  String get securityIncorrectPassword => 'ትክክል ያልሆነ የይለፍ ቃል';

  @override
  String get securityPasswordUpdated => 'የይለፍ ቃል ተዘምኗል';

  @override
  String get appearanceSectionTitle => 'መልክ';

  @override
  String appearanceExportFailed(String error) {
    return 'መላክ አልተሳካም: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'ወደ $path ተቀምጧል';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'ማስቀመጥ አልተሳካም: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'ማስገባት አልተሳካም: $error';
  }

  @override
  String get aboutSectionTitle => 'ስለ';

  @override
  String get providerPublicKey => 'ይፋዊ ቁልፍ';

  @override
  String get providerRelay => 'ሪሌይ';

  @override
  String get providerAutoConfigured =>
      'ከማገገሚያ የይለፍ ቃልዎ በራስ-ሰር ተዋቅሯል። ሪሌይ በራስ-ሰር ተገኝቷል።';

  @override
  String get providerKeyStoredLocally =>
      'ቁልፍዎ በአካባቢው ደኅንነቱ በተጠበቀ ማከማቻ ውስጥ ተቀምጧል — ፈጽሞ ወደ ማንኛውም አገልጋይ አይላክም።';

  @override
  String get providerSessionInfo =>
      'Session Network — ሽንኩርት-ተዘዋዋሪ E2EE። የእርስዎ Session ID አውቶማቲክ ተፈጥሮ ደህንነቱ በተጠበቀ ሁኔታ ይቀመጣል። ኖዶች ከውስጣዊ ዘር ኖዶች አውቶማቲክ ይፈሰሳሉ።';

  @override
  String get providerAdvanced => 'የላቀ';

  @override
  String get providerSaveAndConnect => 'አስቀምጥ እና አገናኝ';

  @override
  String get providerAddSecondaryInbox => 'ሁለተኛ ደረጃ ገቢ ሳጥን አክል';

  @override
  String get providerSecondaryInboxes => 'ሁለተኛ ደረጃ ገቢ ሳጥኖች';

  @override
  String get providerYourInboxProvider => 'የገቢ መልዕክት አቅራቢዎ';

  @override
  String get providerConnectionDetails => 'የግንኙነት ዝርዝሮች';

  @override
  String get addContactTitle => 'እውቂያ አክል';

  @override
  String get addContactInviteLinkLabel => 'የግብዣ ማስፈንጠሪያ ወይም አድራሻ';

  @override
  String get addContactTapToPaste => 'የግብዣ ማስፈንጠሪያ ለመለጠፍ መታ ያድርጉ';

  @override
  String get addContactPasteTooltip => 'ከቅንጥብ ሰሌዳ ለጥፍ';

  @override
  String get addContactAddressDetected => 'የእውቂያ አድራሻ ተገኝቷል';

  @override
  String addContactRoutesDetected(int count) {
    return '$count መንገዶች ተገኝተዋል — SmartRouter ፈጣኑን ይመርጣል';
  }

  @override
  String get addContactFetchingProfile => 'ፕሮፋይል በማምጣት ላይ…';

  @override
  String addContactProfileFound(String name) {
    return 'ተገኝቷል: $name';
  }

  @override
  String get addContactNoProfileFound => 'ፕሮፋይል አልተገኘም';

  @override
  String get addContactDisplayNameLabel => 'ማሳያ ስም';

  @override
  String get addContactDisplayNameHint => 'ምን ብለው ሊጠሯቸው ይፈልጋሉ?';

  @override
  String get addContactAddManually => 'አድራሻ በእጅ ያስገቡ';

  @override
  String get addContactButton => 'እውቂያ አክል';

  @override
  String get networkDiagnosticsTitle => 'የአውታረ መረብ ምርመራ';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr ሪሌይዎች';

  @override
  String get networkDiagnosticsDirect => 'ቀጥተኛ';

  @override
  String get networkDiagnosticsTorOnly => 'Tor ብቻ';

  @override
  String get networkDiagnosticsBest => 'ምርጥ';

  @override
  String get networkDiagnosticsNone => 'ምንም';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'ሁኔታ';

  @override
  String get networkDiagnosticsConnected => 'ተገናኝቷል';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'በማገናኘት ላይ $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'ጠፍቷል';

  @override
  String get networkDiagnosticsTransport => 'ትራንስፖርት';

  @override
  String get networkDiagnosticsInfrastructure => 'መሠረተ ልማት';

  @override
  String get networkDiagnosticsSessionNodes => 'Session ኖዶች';

  @override
  String get networkDiagnosticsTurnServers => 'TURN አገልጋዮች';

  @override
  String get networkDiagnosticsLastProbe => 'የመጨረሻ ፍተሻ';

  @override
  String get networkDiagnosticsRunning => 'በሂድ ላይ...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'ምርመራ አስጀምር';

  @override
  String get networkDiagnosticsForceReprobe => 'ሙሉ ድጋሚ ፍተሻ አስገድድ';

  @override
  String get networkDiagnosticsJustNow => 'አሁን';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'ከ$minutes ደቂቃ በፊት';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'ከ$hours ሰዓት በፊት';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'ከ$days ቀን በፊት';
  }

  @override
  String get homeNoEch => 'ECH የለም';

  @override
  String get homeNoEchTooltip =>
      'uTLS proxy አይገኝም — ECH ጠፍቷል።\nTLS ፊንገርፕሪንት ለDPI ይታያል።';

  @override
  String get settingsTitle => 'ቅንብሮች';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'ተቀምጧል እና ከ$provider ጋር ተገናኝቷል';
  }

  @override
  String get settingsTorFailedToStart => 'አብሮ-የተገነባ Tor ማስጀመር አልተሳካም';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon ማስጀመር አልተሳካም';

  @override
  String get verifyTitle => 'የደኅንነት ቁጥር አረጋግጥ';

  @override
  String get verifyIdentityVerified => 'ማንነት ተረጋግጧል';

  @override
  String get verifyNotYetVerified => 'እስካሁን አልተረጋገጠም';

  @override
  String verifyVerifiedDescription(String name) {
    return 'የ$nameን የደኅንነት ቁጥር አረጋግጠዋል።';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'እነዚህን ቁጥሮች ከ$name ጋር በአካል ወይም በታመነ ሰርጥ ያነጻጽሩ።';
  }

  @override
  String get verifyExplanation =>
      'እያንዳንዱ ውይይት ልዩ የደኅንነት ቁጥር አለው። ሁለታችሁም በመሳሪያዎቻችሁ ላይ ተመሳሳይ ቁጥሮች ካያችሁ ግንኙነታችሁ ከጫፍ-ወደ-ጫፍ ተረጋግጧል።';

  @override
  String verifyContactKey(String name) {
    return 'የ$name ቁልፍ';
  }

  @override
  String get verifyYourKey => 'የእርስዎ ቁልፍ';

  @override
  String get verifyRemoveVerification => 'ማረጋገጫን አስወግድ';

  @override
  String get verifyMarkAsVerified => 'እንደተረጋገጠ ምልክት አድርግ';

  @override
  String verifyAfterReinstall(String name) {
    return '$name መተግበሪያውን እንደገና ከጫነ/ች የደኅንነት ቁጥር ይቀየራል እና ማረጋገጫው በራስ-ሰር ይወገዳል።';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'ከ$name ጋር በድምጽ ጥሪ ወይም በአካል ቁጥሮችን ካነጻጸሩ በኋላ ብቻ እንደተረጋገጠ ምልክት ያድርጉ።';
  }

  @override
  String get verifyNoSession =>
      'እስካሁን ምንም የምስጠራ ክፍለ ጊዜ አልተቋቋመም። የደኅንነት ቁጥሮችን ለማመንጨት መጀመሪያ መልዕክት ይላኩ።';

  @override
  String get verifyNoKeyAvailable => 'ቁልፍ አይገኝም';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label ፊንገርፕሪንት ተቀድቷል';
  }

  @override
  String get providerDatabaseUrlLabel => 'የመረጃ ቋት URL';

  @override
  String get providerOptionalHint => 'አማራጭ';

  @override
  String get providerWebApiKeyLabel => 'Web API ቁልፍ';

  @override
  String get providerOptionalForPublicDb => 'ለሕዝባዊ DB አማራጭ';

  @override
  String get providerRelayUrlLabel => 'Relay URL';

  @override
  String get providerPrivateKeyLabel => 'የግል ቁልፍ';

  @override
  String get providerPrivateKeyNsecLabel => 'የግል ቁልፍ (nsec)';

  @override
  String get providerStorageNodeLabel => 'የማከማቻ ኖድ URL (አማራጭ)';

  @override
  String get providerStorageNodeHint => 'ለአብሮ-የተገነቡ ዘር ኖዶች ባዶ ይተዉ';

  @override
  String get transferInvalidCodeFormat =>
      'ያልታወቀ ኮድ ቅርጸት — በLAN: ወይም NOS: መጀመር አለበት';

  @override
  String get profileCardFingerprintCopied => 'ፊንገርፕሪንት ተቀድቷል';

  @override
  String get profileCardAboutHint => 'ግለኝነት ቅድሚያ 🔒';

  @override
  String get profileCardSaveButton => 'ፕሮፋይል አስቀምጥ';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'የተመሰጠሩ መልዕክቶችን፣ እውቂያዎችን እና አቫታሮችን ወደ ፋይል ላክ';

  @override
  String get callVideo => 'ቪዲዮ';

  @override
  String get callAudio => 'ኦዲዮ';

  @override
  String bubbleDeliveredTo(String names) {
    return 'ወደ $names ደርሷል';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'ወደ $count ደርሷል';
  }

  @override
  String get groupStatusDialogTitle => 'የመልዕክት መረጃ';

  @override
  String get groupStatusRead => 'ተነብቧል';

  @override
  String get groupStatusDelivered => 'ደርሷል';

  @override
  String get groupStatusPending => 'በመጠባበቅ ላይ';

  @override
  String get groupStatusNoData => 'እስካሁን የማድረስ መረጃ የለም';

  @override
  String get profileTransferAdmin => 'አስተዳዳሪ አድርግ';

  @override
  String profileTransferAdminConfirm(String name) {
    return '$nameን አዲስ አስተዳዳሪ ያድርጉ?';
  }

  @override
  String get profileTransferAdminBody => 'የአስተዳዳሪ መብቶችዎን ያጣሉ። ይህ ሊቀለበስ አይችልም።';

  @override
  String profileTransferAdminDone(String name) {
    return '$name አሁን አስተዳዳሪው ነው';
  }

  @override
  String get profileAdminBadge => 'አስተዳዳሪ';

  @override
  String get privacyPolicyTitle => 'የግለኝነት ፖሊሲ';

  @override
  String get privacyOverviewHeading => 'አጠቃላይ';

  @override
  String get privacyOverviewBody =>
      'Pulse አገልጋይ-አልባ፣ ከጫፍ-ወደ-ጫፍ የተመሰጠረ መልዕክት ላኪ ነው። ግለኝነትዎ ባህሪ ብቻ አይደለም — ሥነ-ሕንፃው ነው። ምንም Pulse አገልጋዮች የሉም። ምንም መለያዎች በማንኛውም ቦታ አይከማቹም። ምንም ውሂብ በገንቢዎች አይሰበሰብም፣ አይተላለፍም ወይም አይከማችም።';

  @override
  String get privacyDataCollectionHeading => 'ውሂብ ማሰባሰብ';

  @override
  String get privacyDataCollectionBody =>
      'Pulse ምንም የግል ውሂብ አይሰበስብም። በተለይ:\n\n- ኢሜይል፣ ስልክ ቁጥር ወይም እውነተኛ ስም አያስፈልግም\n- ትንታኔዎች፣ ክትትል ወይም ቴሌሜትሪ የለም\n- የማስታወቂያ መለያዎች የሉም\n- የእውቂያ ዝርዝር ተደራሽነት የለም\n- የደመና ምትኬዎች የሉም (መልዕክቶች በመሳሪያዎ ላይ ብቻ ናቸው)\n- ምንም ሜታዳታ ወደ ማንኛውም Pulse አገልጋይ አይላክም (ምንም የሉም)';

  @override
  String get privacyEncryptionHeading => 'ምስጠራ';

  @override
  String get privacyEncryptionBody =>
      'ሁሉም መልዕክቶች በSignal Protocol (Double Ratchet ከX3DH ቁልፍ ስምምነት ጋር) ይመሰጠራሉ። የምስጠራ ቁልፎች በመሳሪያዎ ላይ ብቻ ይመነጫሉ እና ይከማቻሉ። ማንም — ገንቢዎችን ጨምሮ — መልዕክቶችዎን ማንበብ አይችልም።';

  @override
  String get privacyNetworkHeading => 'የአውታረ መረብ ሥነ-ሕንፃ';

  @override
  String get privacyNetworkBody =>
      'Pulse የተዋሀዱ ትራንስፖርት አስማሚዎችን ይጠቀማል (Nostr ሪሌይዎች፣ Session/Oxen የአገልግሎት ኖዶች፣ Firebase Realtime Database፣ LAN)። እነዚህ ትራንስፖርቶች የተመሰጠረ ጽሑፍ ብቻ ይሸከማሉ። ሪሌይ ኦፐሬተሮች IP አድራሻዎን እና የትራፊክ መጠን ማየት ይችላሉ፣ ግን የመልዕክት ይዘትን ማግለጥ አይችሉም።\n\nTor ሲነቃ IP አድራሻዎ ከሪሌይ ኦፐሬተሮችም ይደበቃል።';

  @override
  String get privacyStunHeading => 'STUN/TURN አገልጋዮች';

  @override
  String get privacyStunBody =>
      'የድምጽ እና ቪዲዮ ጥሪዎች WebRTC ከDTLS-SRTP ምስጠራ ጋር ይጠቀማሉ። STUN አገልጋዮች (ለእኩያ-ወደ-እኩያ ግንኙነቶች ይፋዊ IP ዎን ለማግኘት የሚጠቀሙ) እና TURN አገልጋዮች (ቀጥተኛ ግንኙነት ሲሳነው ሚዲያ ለማስተላለፍ የሚጠቀሙ) IP አድራሻዎን እና የጥሪ ቆይታ ማየት ይችላሉ፣ ግን የጥሪ ይዘትን ማግለጥ አይችሉም።\n\nለከፍተኛ ግለኝነት በቅንብሮች ውስጥ የራስዎን TURN አገልጋይ ማዋቀር ይችላሉ።';

  @override
  String get privacyCrashHeading => 'የብልሽት ሪፖርት';

  @override
  String get privacyCrashBody =>
      'Sentry የብልሽት ሪፖርት ከነቃ (በግንባታ ጊዜ SENTRY_DSN በኩል)፣ ማንነት-አልባ የብልሽት ሪፖርቶች ሊላኩ ይችላሉ። እነዚህ ምንም የመልዕክት ይዘት፣ ምንም የእውቂያ መረጃ እና ምንም በግል ሊለዩ የሚችሉ መረጃዎች አያካትቱም። የብልሽት ሪፖርት DSN ን በመተው በግንባታ ጊዜ ሊሰናከል ይችላል።';

  @override
  String get privacyPasswordHeading => 'የይለፍ ቃል እና ቁልፎች';

  @override
  String get privacyPasswordBody =>
      'የማገገሚያ የይለፍ ቃልዎ በArgon2id (ማህደረ ትውስታ-ጠንካራ KDF) ክሪፕቶግራፊክ ቁልፎችን ለማመንጨት ይጠቀማል። የይለፍ ቃሉ ወደ ማንኛውም ቦታ ፈጽሞ አይተላለፍም። የይለፍ ቃልዎን ካጡ መለያዎ ሊመለስ አይችልም — ዳግም ለማስጀመር ምንም አገልጋይ የለም።';

  @override
  String get privacyFontsHeading => 'ቅርጸ-ቁምፊዎች';

  @override
  String get privacyFontsBody =>
      'Pulse ሁሉንም ቅርጸ-ቁምፊዎች በአካባቢው ያሳስራል። ወደ Google Fonts ወይም ማንኛውም ውጫዊ ቅርጸ-ቁምፊ አገልግሎት ምንም ጥያቄዎች አይቀርቡም።';

  @override
  String get privacyThirdPartyHeading => 'የሶስተኛ ወገን አገልግሎቶች';

  @override
  String get privacyThirdPartyBody =>
      'Pulse ከማንኛውም የማስታወቂያ አውታረ መረቦች፣ የትንታኔ አቅራቢዎች፣ ማኅበራዊ ሚዲያ መድረኮች ወይም ውሂብ ደላላዎች ጋር አይዋሃድም። ብቸኛዎቹ የአውታረ መረብ ግንኙነቶች እርስዎ ወደሚያዋቅሯቸው ትራንስፖርት ሪሌይዎች ናቸው።';

  @override
  String get privacyOpenSourceHeading => 'ክፍት ምንጭ';

  @override
  String get privacyOpenSourceBody =>
      'Pulse ክፍት-ምንጭ ሶፍትዌር ነው። እነዚህን የግለኝነት ማረጋገጫዎች ለማጣራት ሙሉውን ምንጭ ኮድ ማጣራት ይችላሉ።';

  @override
  String get privacyContactHeading => 'እውቂያ';

  @override
  String get privacyContactBody =>
      'ከግለኝነት ጋር የተያያዙ ጥያቄዎች ካሉ በፕሮጀክቱ ማከማቻ ላይ ችግር ይክፈቱ።';

  @override
  String get privacyLastUpdated => 'መጨረሻ ያዘመኑት: መጋቢት 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'ማስቀመጥ አልተሳካም: $error';
  }

  @override
  String get themeEngineTitle => 'ገጽታ ሞተር';

  @override
  String get torBuiltInTitle => 'አብሮ-የተገነባ Tor';

  @override
  String get torConnectedSubtitle =>
      'ተገናኝቷል — Nostr በ127.0.0.1:9250 በኩል ይዘዋወራል';

  @override
  String torConnectingSubtitle(int pct) {
    return 'በማገናኘት ላይ… $pct%';
  }

  @override
  String get torNotRunning => 'አይሰራም — እንደገና ለማስጀመር ማብሪያ/ማጥፊያውን ይጫኑ';

  @override
  String get torDescription =>
      'Nostr ን በTor በኩል ያዘዋውራል (ለታገዱ አውታረ መረቦች Snowflake)';

  @override
  String get torNetworkDiagnostics => 'የአውታረ መረብ ምርመራ';

  @override
  String get torTransportLabel => 'ትራንስፖርት: ';

  @override
  String get torPtAuto => 'ራስ-ሰር';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'ተራ';

  @override
  String get torTimeoutLabel => 'ጊዜ ገደብ: ';

  @override
  String get torInfoDescription =>
      'ሲነቃ Nostr WebSocket ግንኙነቶች በTor (SOCKS5) በኩል ይዘዋወራሉ። Tor Browser በ127.0.0.1:9150 ላይ ያዳምጣል። ነጠላ tor daemon ፖርት 9050 ይጠቀማል። Firebase ግንኙነቶች አይጎዱም።';

  @override
  String get torRouteNostrTitle => 'Nostr ን በTor በኩል አዘዋውር';

  @override
  String get torManagedByBuiltin => 'በአብሮ-የተገነባ Tor ይተዳደራል';

  @override
  String get torActiveRouting => 'ንቁ — Nostr ትራፊክ በTor በኩል ይዘዋወራል';

  @override
  String get torDisabled => 'ጠፍቷል';

  @override
  String get torProxySocks5 => 'Tor ፕሮክሲ (SOCKS5)';

  @override
  String get torProxyHostLabel => 'የፕሮክሲ አስተናጋጅ';

  @override
  String get torProxyPortLabel => 'ፖርት';

  @override
  String get torPortInfo => 'Tor Browser: ፖርት 9150  •  tor daemon: ፖርት 9050';

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
  String get i2pProxySocks5 => 'I2P ፕሮክሲ (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P በነባሪ በፖርት 4447 ላይ SOCKS5 ይጠቀማል። በማንኛውም ትራንስፖርት ላይ ካሉ ተጠቃሚዎች ጋር ለመገናኘት በI2P outproxy (ለምሳሌ relay.damus.i2p) በኩል ከNostr relay ጋር ይገናኙ። ሁለቱም ሲነቁ Tor ቅድሚያ ይወስዳል።';

  @override
  String get i2pRouteNostrTitle => 'Nostr ን በI2P በኩል አዘዋውር';

  @override
  String get i2pActiveRouting => 'ንቁ — Nostr ትራፊክ በI2P በኩል ይዘዋወራል';

  @override
  String get i2pDisabled => 'ጠፍቷል';

  @override
  String get i2pProxyHostLabel => 'የፕሮክሲ አስተናጋጅ';

  @override
  String get i2pProxyPortLabel => 'ፖርት';

  @override
  String get i2pPortInfo => 'I2P ራውተር ነባሪ SOCKS5 ፖርት: 4447';

  @override
  String get customProxySocks5 => 'ብጁ ፕሮክሲ (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'ብጁ ፕሮክሲ ትራፊክን በV2Ray/Xray/Shadowsocks ዎ በኩል ያዘዋውራል። CF Worker በCloudflare CDN ላይ እንደ ግል ሪሌይ ፕሮክሲ ሆኖ ያገለግላል — GFW *.workers.dev ን ያያል፣ እውነተኛውን ሪሌይ አይደለም።';

  @override
  String get customSocks5ProxyTitle => 'ብጁ SOCKS5 ፕሮክሲ';

  @override
  String get customProxyActive => 'ንቁ — ትራፊክ በSOCKS5 በኩል ይዘዋወራል';

  @override
  String get customProxyDisabled => 'ጠፍቷል';

  @override
  String get customProxyHostLabel => 'የፕሮክሲ አስተናጋጅ';

  @override
  String get customProxyPortLabel => 'ፖርት';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker ዶሜይን (አማራጭ)';

  @override
  String get customWorkerHelpTitle => 'CF Worker relay እንዴት እንደሚዘረጋ (ነፃ)';

  @override
  String get customWorkerScriptCopied => 'ስክሪፕት ተቀድቷል!';

  @override
  String get customWorkerStep1 =>
      '1. ወደ dash.cloudflare.com → Workers & Pages ይሂዱ\n2. Create Worker → ይህን ስክሪፕት ይለጥፉ:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → ዶሜይን ይቅዱ (ለምሳሌ my-relay.user.workers.dev)\n4. ዶሜይኑን ከላይ ይለጥፉ → ያስቀምጡ\n\nመተግበሪያ በራስ-ሰር ያገናኛል: wss://domain/?r=relay_url\nGFW ያየዋል: ግንኙነት ወደ *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'ተገናኝቷል — SOCKS5 በ127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'በማገናኘት ላይ…';

  @override
  String get psiphonNotRunning => 'አይሰራም — እንደገና ለማስጀመር ማብሪያ/ማጥፊያውን ይጫኑ';

  @override
  String get psiphonDescription => 'ፈጣን ዋሻ (~3 ሰከንድ ማስጀመር፣ 2000+ ተዟዟሪ VPS)';

  @override
  String get turnCommunityServers => 'የማህበረሰብ TURN አገልጋዮች';

  @override
  String get turnCustomServer => 'ብጁ TURN አገልጋይ (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN አገልጋዮች ቀድሞውኑ የተመሰጠሩ ዥረቶችን (DTLS-SRTP) ብቻ ያስተላልፋሉ። ሪሌይ ኦፐሬተር IP ዎን እና የትራፊክ መጠን ያያል፣ ግን ጥሪዎችን ማግለጥ አይችልም። TURN ቀጥተኛ P2P ሲሳነው ብቻ ጥቅም ላይ ይውላል (~15–20% ግንኙነቶች)።';

  @override
  String get turnFreeLabel => 'ነፃ';

  @override
  String get turnServerUrlLabel => 'TURN አገልጋይ URL';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 ወይም turns:...';

  @override
  String get turnUsernameLabel => 'የተጠቃሚ ስም';

  @override
  String get turnPasswordLabel => 'የይለፍ ቃል';

  @override
  String get turnOptionalHint => 'አማራጭ';

  @override
  String get turnCustomInfo =>
      'ለከፍተኛ ቁጥጥር coturn ን በማንኛውም \$5/ወር VPS ላይ ያስተናግዱ። ምስክርነቶች በአካባቢው ይከማቻሉ።';

  @override
  String get themePickerAppearance => 'መልክ';

  @override
  String get themePickerAccentColor => 'የአጽንዖት ቀለም';

  @override
  String get themeModeLight => 'ብርሃን';

  @override
  String get themeModeDark => 'ጨለማ';

  @override
  String get themeModeSystem => 'ሲስተም';

  @override
  String get themeDynamicPresets => 'ቅድመ-ቅንብሮች';

  @override
  String get themeDynamicPrimaryColor => 'ዋና ቀለም';

  @override
  String get themeDynamicBorderRadius => 'የድንበር ራዲየስ';

  @override
  String get themeDynamicFont => 'ቅርጸ-ቁምፊ';

  @override
  String get themeDynamicAppearance => 'መልክ';

  @override
  String get themeDynamicUiStyle => 'UI ዘይቤ';

  @override
  String get themeDynamicUiStyleDescription =>
      'ውይይቶች፣ ማብሪያ/ማጥፊያዎች እና ጠቋሚዎች እንዴት እንደሚታዩ ይቆጣጠራል።';

  @override
  String get themeDynamicSharp => 'ሹል';

  @override
  String get themeDynamicRound => 'ክብ';

  @override
  String get themeDynamicModeDark => 'ጨለማ';

  @override
  String get themeDynamicModeLight => 'ብርሃን';

  @override
  String get themeDynamicModeAuto => 'ራስ-ሰር';

  @override
  String get themeDynamicPlatformAuto => 'ራስ-ሰር';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'ልክ ያልሆነ Firebase URL። የሚጠበቅ: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'ልክ ያልሆነ relay URL። የሚጠበቅ: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'ልክ ያልሆነ Pulse አገልጋይ URL። የሚጠበቅ: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'አገልጋይ URL';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'የግብዣ ኮድ';

  @override
  String get providerPulseInviteHint => 'የግብዣ ኮድ (ካስፈለገ)';

  @override
  String get providerPulseInfo => 'ራስ-ያስተናገደ ሪሌይ። ቁልፎች ከማገገሚያ የይለፍ ቃልዎ ይመነጫሉ።';

  @override
  String get providerScreenTitle => 'ገቢ ሳጥኖች';

  @override
  String get providerSecondaryInboxesHeader => 'ሁለተኛ ደረጃ ገቢ ሳጥኖች';

  @override
  String get providerSecondaryInboxesInfo =>
      'ሁለተኛ ደረጃ ገቢ ሳጥኖች ለጥንካሬ መልዕክቶችን በአንድ ጊዜ ይቀበላሉ።';

  @override
  String get providerRemoveTooltip => 'አስወግድ';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... ወይም hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... ወይም hex የግል ቁልፍ';

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
  String get emojiNoRecent => 'የቅርብ ጊዜ ኢሞጂዎች የሉም';

  @override
  String get emojiSearchHint => 'ኢሞጂ ፈልግ...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'ለመወያየት መታ ያድርጉ';

  @override
  String get imageViewerSaveToDownloads => 'ወደ Downloads አስቀምጥ';

  @override
  String imageViewerSavedTo(String path) {
    return 'ወደ $path ተቀምጧል';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'ቋንቋ';

  @override
  String get settingsLanguageSubtitle => 'የመተግበሪያ ማሳያ ቋንቋ';

  @override
  String get settingsLanguageSystem => 'የሲስተም ነባሪ';

  @override
  String get onboardingLanguageTitle => 'ቋንቋዎን ይምረጡ';

  @override
  String get onboardingLanguageSubtitle => 'ይህንን በኋላ በቅንብሮች ውስጥ ሊቀይሩት ይችላሉ';

  @override
  String get videoNoteRecord => 'ቪዲዮ መልዕክት ቅዳ';

  @override
  String get videoNoteTapToRecord => 'ለመቅዳት መታ ያድርጉ';

  @override
  String get videoNoteTapToStop => 'ለማቆም መታ ያድርጉ';

  @override
  String get videoNoteCameraPermission => 'የካሜራ ፈቃድ ተከልክሏል';

  @override
  String get videoNoteMaxDuration => 'ከፍተኛ 30 ሰከንዶች';

  @override
  String get videoNoteNotSupported => 'ቪዲዮ ማስታወሻዎች በዚህ መድረክ አይደገፉም';

  @override
  String get navChats => 'ውይይቶች';

  @override
  String get navUpdates => 'ዝማኔዎች';

  @override
  String get navCalls => 'ጥሪዎች';

  @override
  String get filterAll => 'ሁሉም';

  @override
  String get filterUnread => 'ያልተነበቡ';

  @override
  String get filterGroups => 'ቡድኖች';

  @override
  String get callsNoRecent => 'የቅርብ ጊዜ ጥሪዎች የሉም';

  @override
  String get callsEmptySubtitle => 'የጥሪ ታሪክዎ እዚህ ይታያል';

  @override
  String get appBarEncrypted => 'ከጫፍ-እስከ-ጫፍ ምስጢር';

  @override
  String get newStatus => 'አዲስ ሁኔታ';

  @override
  String get newCall => 'አዲስ ጥሪ';
}
