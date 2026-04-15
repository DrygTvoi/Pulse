// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Burmese (`my`).
class AppLocalizationsMy extends AppLocalizations {
  AppLocalizationsMy([String locale = 'my']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'မက်ဆက်များတွင် ရှာဖွေ...';

  @override
  String get search => 'ရှာဖွေ';

  @override
  String get clearSearch => 'ရှာဖွေမှတ်တမ်း ရှင်းရန်';

  @override
  String get closeSearch => 'ရှာဖွေမှတ်တမ်း ပိတ်ရန်';

  @override
  String get moreOptions => 'နောက်ထပ်ရွေးချက်များ';

  @override
  String get back => 'နောက်သို့';

  @override
  String get cancel => 'ဖျက်သိမ်း';

  @override
  String get close => 'ပိတ်';

  @override
  String get confirm => 'အတည်ပြု';

  @override
  String get remove => 'ဖယ်ရှား';

  @override
  String get save => 'သိမ်း';

  @override
  String get add => 'ထည့်';

  @override
  String get copy => 'ကူးယူ';

  @override
  String get skip => 'ကျော်သွား';

  @override
  String get done => 'ပြီးဆုံး';

  @override
  String get apply => 'အသုံးချ';

  @override
  String get export => 'တင်ပို့';

  @override
  String get import => 'တင်သွင်း';

  @override
  String get homeNewGroup => 'အဖွဲ့အသစ်';

  @override
  String get homeSettings => 'ဆက်တင်များ';

  @override
  String get homeSearching => 'မက်ဆက်များ ရှာဖွေနေသည်...';

  @override
  String get homeNoResults => 'ရွေးချက်များ မတွေ့ပါ';

  @override
  String get homeNoChatHistory => 'ချက်တင်မှတ်တမ်း မရှိသေးပါ';

  @override
  String homeTransportSwitched(String address) {
    return 'ပို့ဆောင်ရေး ပြောင်းသွားပြီ → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name ဖုန်းခေါ်နေသည်...';
  }

  @override
  String get homeAccept => 'လက်ခံ';

  @override
  String get homeDecline => 'ပယ်ကျ';

  @override
  String get homeLoadEarlier => 'အရင်မက်ဆက်များ ဖော်ပြ';

  @override
  String get homeChats => 'ချက်တင်များ';

  @override
  String get homeSelectConversation => 'စကားသွားချက်တစ်ခု ရွေးပါ';

  @override
  String get homeNoChatsYet => 'ချက်တင်များ မရှိသေးပါ';

  @override
  String get homeAddContactToStart => 'စကားသွားလို အဆက်အသွယ်ထည့်ပါ';

  @override
  String get homeNewChat => 'ချက်တင်အသစ်';

  @override
  String get homeNewChatTooltip => 'ချက်တင်အသစ်';

  @override
  String get homeIncomingCallTitle => 'အဝင်ဖုန်းခေါ်ဆိုမှု';

  @override
  String get homeIncomingGroupCallTitle => 'အဖွဲ့ဖုန်းခေါ်ဆိုမှု';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — အဖွဲ့ဖုန်းခေါ်ဆိုမှု';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return '\"$query\" နှင့်ကိုက်ညီသည့် ချက်တင် မရှိပါ';
  }

  @override
  String get homeSectionChats => 'ချက်တင်များ';

  @override
  String get homeSectionMessages => 'မက်ဆက်များ';

  @override
  String get homeDbEncryptionUnavailable =>
      'ဒေတာဘေ့စ် ကုဒ်ဝှက်ခြင်း မရရှိပါ — အပြည့်အဝ ကာကွယ်မှုအတွက် SQLCipher ထည့်သွင်းပါ';

  @override
  String get chatFileTooLargeGroup =>
      'အဖွဲ့ချက်တင်များတွင် 512 KB ထက်ကြီးသည့် ဖိုင်များကို ပံ့ပိုးမပေးပါ';

  @override
  String get chatLargeFile => 'ဖိုင်အကြီး';

  @override
  String get chatCancel => 'ဖျက်သိမ်း';

  @override
  String get chatSend => 'ပို့';

  @override
  String get chatFileTooLarge => 'ဖိုင်အရွယ်အစားကြီးလွန်း — အများဆုံး 100 MB';

  @override
  String get chatMicDenied => 'မိုက်ကရိုဖုန်း ခွင့်ပြုချက် ပယ်ကျခံရရှိသည်';

  @override
  String get chatVoiceFailed =>
      'အသံမက်ဆက် သိမ်းဆည်းလို့မရပါ — သိုလှေညှာကို စစ်ဆေးပါ';

  @override
  String get chatScheduleFuture => 'အချိန်သတ်မှတ်ချိန်သည် အနာဂတ်တွင် ဖြစ်ရမည်';

  @override
  String get chatToday => 'ယနေ့';

  @override
  String get chatYesterday => 'မနေ့က';

  @override
  String get chatEdited => 'တည်းဖြတ်ပြီး';

  @override
  String get chatYou => 'သင်';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'ဤဖိုင်သည် $size MB ဖြစ်သည်။ ဖိုင်အကြီးများ ပို့ခြင်းသည် အချို့ကွန်ရက်များတွင် နှေးကွေးနိုင်သည်။ ဆက်လုပ်မည်လား?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return '$name ရဲ့ လုံခြုံရေးသော့ချက် ပြောင်းသွားပြီ။ အတည်ပြုရန် နှိပ်ပါ။';
  }

  @override
  String chatEncryptionFailed(String name) {
    return '$name ဆီသို့ မက်ဆက်ကို ကုဒ်ဝှက်လို့မရပါ — မက်ဆက်မပို့ရပါ။';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return '$name အတွက် လုံခြုံရေးနံပါတ် ပြောင်းသွားပြီ။ အတည်ပြုရန် နှိပ်ပါ။';
  }

  @override
  String get chatNoMessagesFound => 'မက်ဆက်များ မတွေ့ပါ';

  @override
  String get chatMessagesE2ee => 'မက်ဆက်များသည် အစမှအဆုံးအထိ ကုဒ်ဝှက်ထားသည်';

  @override
  String get chatSayHello => 'နှုတ်ဆက်လိုက်ပါ';

  @override
  String get appBarOnline => 'အွန်လိုင်း';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'ရိုက်နေသည်';

  @override
  String get appBarSearchMessages => 'မက်ဆက်များတွင် ရှာဖွေ...';

  @override
  String get appBarMute => 'အသံပိတ်';

  @override
  String get appBarUnmute => 'အသံဖွင့်';

  @override
  String get appBarMedia => 'မီဒီယာ';

  @override
  String get appBarDisappearing => 'ပျောက်ကွယ်သည့် မက်ဆက်များ';

  @override
  String get appBarDisappearingOn => 'ပျောက်ကွယ်ခြင်း: ဖွင့်ထား';

  @override
  String get appBarGroupSettings => 'အဖွဲ့ဆက်တင်များ';

  @override
  String get appBarSearchTooltip => 'မက်ဆက်များတွင် ရှာဖွေ';

  @override
  String get appBarVoiceCall => 'အသံဖုန်းခေါ်';

  @override
  String get appBarVideoCall => 'ဗီဒီယိုဖုန်းခေါ်';

  @override
  String get inputMessage => 'မက်ဆက်...';

  @override
  String get inputAttachFile => 'ဖိုင်ပူးတွဲ';

  @override
  String get inputSendMessage => 'မက်ဆက်ပို့';

  @override
  String get inputRecordVoice => 'အသံမက်ဆက်ဖမ်း';

  @override
  String get inputSendVoice => 'အသံမက်ဆက်ပို့';

  @override
  String get inputCancelReply => 'ပြန်စာကို ဖျက်သိမ်း';

  @override
  String get inputCancelEdit => 'တည်းဖြတ်ခြင်းကို ဖျက်သိမ်း';

  @override
  String get inputCancelRecording => 'အသံဖမ်းခြင်းကို ဖျက်သိမ်း';

  @override
  String get inputRecording => 'အသံဖမ်းနေသည်…';

  @override
  String get inputEditingMessage => 'မက်ဆက်တည်းဖြတ်နေသည်';

  @override
  String get inputPhoto => 'ဓာတ်ပုံ';

  @override
  String get inputVoiceMessage => 'အသံမက်ဆက်';

  @override
  String get inputFile => 'ဖိုင်';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'အချိန်သတ်မှတ်ထားသည့် မက်ဆက် $count ခု',
      one: 'အချိန်သတ်မှတ်ထားသည့် မက်ဆက် $count ခု',
    );
    return '$_temp0';
  }

  @override
  String get callInitializing => 'ဖုန်းခေါ်ဆိုမှု စတင်နေသည်…';

  @override
  String get callConnecting => 'ချိတ်ဆက်နေသည်…';

  @override
  String get callConnectingRelay => 'ချိတ်ဆက်နေသည် (relay)…';

  @override
  String get callSwitchingRelay => 'Relay မုဒ်သို့ ပြောင်းနေသည်…';

  @override
  String get callConnectionFailed => 'ချိတ်ဆက်မှု မအောင်မြင်ပါ';

  @override
  String get callReconnecting => 'ပြန်ချိတ်ဆက်နေသည်…';

  @override
  String get callEnded => 'ဖုန်းခေါ်ဆိုမှု ပြီးဆုံးပြီ';

  @override
  String get callLive => 'တိုက်ရိုက်';

  @override
  String get callEnd => 'အဆုံး';

  @override
  String get callEndCall => 'ဖုန်းချ';

  @override
  String get callMute => 'အသံပိတ်';

  @override
  String get callUnmute => 'အသံဖွင့်';

  @override
  String get callSpeaker => 'စပီကာ';

  @override
  String get callCameraOn => 'ကင်မရာဖွင့်';

  @override
  String get callCameraOff => 'ကင်မရာပိတ်';

  @override
  String get callShareScreen => 'မျက်နှာပြင် မျှဝေပါ';

  @override
  String get callStopShare => 'မျှဝေခြင်းရပ်';

  @override
  String callTorBackup(String duration) {
    return 'Tor အရန်သင် · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor အရန်သင် အသုံးပြုနေသည် — ပင်မလမ်း မရရှိပါ';

  @override
  String get callDirectFailed =>
      'တိုက်ရိုက်ချိတ်ဆက်မှု မအောင်မြင်ပါ — relay မုဒ်သို့ ပြောင်းနေသည်…';

  @override
  String get callTurnUnreachable =>
      'TURN ဆာဗာများ ဆက်သွယ်လို့မရပါ။ ဆက်တင်များ → အဆင့်မြင့်တွင် စိတ်ကြိုက် TURN ထည့်ပါ။';

  @override
  String get callRelayMode =>
      'Relay မုဒ် အသုံးပြုနေသည် (ကန့်သတ်ထားသည့် ကွန်ရက်)';

  @override
  String get callStarting => 'ဖုန်းခေါ်ဆိုမှု စတင်နေသည်…';

  @override
  String get callConnectingToGroup => 'အဖွဲ့သို့ ချိတ်ဆက်နေသည်…';

  @override
  String get callGroupOpenedInBrowser =>
      'အဖွဲ့ဖုန်းခေါ်ဆိုမှုကို ဘရာက်ဆာတွင် ဖွင့်လိုက်ပြီ';

  @override
  String get callCouldNotOpenBrowser => 'ဘရာက်ဆာကို ဖွင့်လို့မရပါ';

  @override
  String get callInviteLinkSent =>
      'ဖိတ်ခေါ်လင့်ခ်ကို အဖွဲ့သားများအားလုံးသို့ ပို့ပြီ။';

  @override
  String get callOpenLinkManually =>
      'အထက်ပါလင့်ခ်ကို ကိုယ်တိုင်ဖွင့်ပါ သို့မဟုတ် ပြန်ကြိုးစားရန် နှိပ်ပါ။';

  @override
  String get callJitsiNotE2ee =>
      'Jitsi ဖုန်းခေါ်ဆိုမှုများသည် အစမှအဆုံးအထိ ကုဒ်ဝှက်မထားပါ';

  @override
  String get callRetryOpenBrowser => 'ဘရာက်ဆာကို ပြန်ဖွင့်';

  @override
  String get callClose => 'ပိတ်';

  @override
  String get callCamOn => 'ကင်မရာဖွင့်';

  @override
  String get callCamOff => 'ကင်မရာပိတ်';

  @override
  String get noConnection => 'ချိတ်ဆက်မှုမရှိပါ — မက်ဆက်များ တန်းစီထားမည်';

  @override
  String get connected => 'ချိတ်ဆက်ပြီး';

  @override
  String get connecting => 'ချိတ်ဆက်နေသည်…';

  @override
  String get disconnected => 'ချိတ်ဆက်မှု ဖြုတ်သွားပြီ';

  @override
  String get offlineBanner =>
      'ချိတ်ဆက်မှုမရှိပါ — မက်ဆက်များသည် ပြန်အွန်လိုင်းဖြစ်သည့်အခါ ပို့မည်';

  @override
  String get lanModeBanner => 'LAN မုဒ် — အင်တာနက်မရှိပါ · ပြည်တွင်းကွန်ရက်သာ';

  @override
  String get probeCheckingNetwork => 'ကွန်ရက်ချိတ်ဆက်မှုကို စစ်ဆေးနေသည်…';

  @override
  String get probeDiscoveringRelays =>
      'အသိုင်းအဝိုင်း လမ်းညွှန်များမှတစ်ဆင့် relay များရှာဖွေနေသည်…';

  @override
  String get probeStartingTor => 'Tor စတင်နေသည်…';

  @override
  String get probeFindingRelaysTor =>
      'Tor မှတစ်ဆင့် ချိတ်ဆက်နိုင်သည့် relay များရှာနေသည်…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ခု',
      one: '$count ခု',
    );
    return 'ကွန်ရက် အသင့်ပြီ — relay $_temp0 တွေ့ပြီ';
  }

  @override
  String get probeNoRelaysFound =>
      'ချိတ်ဆက်နိုင်သည့် relay မတွေ့ပါ — မက်ဆက်များ နှောင့်ကွေးနိုင်သည်';

  @override
  String get jitsiWarningTitle => 'အစမှအဆုံးအထိ ကုဒ်ဝှက်မထားပါ';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet ဖုန်းခေါ်ဆိုမှုများသည် Pulse မှ ကုဒ်ဝှက်မထားပါ။ အရေးမကြီးသည့် စကားသွားများအတွက်သာ အသုံးပြုပါ။';

  @override
  String get jitsiConfirm => 'မည်သို့ ဝင်မည်';

  @override
  String get jitsiGroupWarningTitle => 'အစမှအဆုံးအထိ ကုဒ်ဝှက်မထားပါ';

  @override
  String get jitsiGroupWarningBody =>
      'ဤဖုန်းခေါ်ဆိုမှုတွင် ပါဝင်သူအရေအတွက်သည် တွဲလှောက်ကုဒ်ဝှက်ခြင်းအတွက် များလွန်းသည်။\n\nသင့်ဘရာက်ဆာတွင် Jitsi Meet လင့်ခ်ဖွင့်မည်။ Jitsi သည် အစမှအဆုံးအထိ ကုဒ်ဝှက်မထားပါ — ဆာဗာမှ သင့်ဖုန်းခေါ်ဆိုမှုကို မြင်နိုင်သည်။';

  @override
  String get jitsiContinueAnyway => 'မည်သို့ ဆက်လုပ်';

  @override
  String get retry => 'ပြန်ကြိုးစား';

  @override
  String get setupCreateAnonymousAccount => 'အမည်မသိ အကောင့်ဖန်တီး';

  @override
  String get setupTapToChangeColor => 'အရောင်ပြောင်းရန် နှိပ်ပါ';

  @override
  String get setupReqMinLength => 'အနည်းဆုံး ၁၆ လုံး';

  @override
  String get setupReqVariety =>
      '၄ ထဲမှ ၃ ခု: စာလုံးကြီး၊ ငယ်၊ ကိန်းဂဏန်း၊ သင်္ကေတ';

  @override
  String get setupReqMatch => 'စကားဝှက်များ ကိုက်ညီသည်';

  @override
  String get setupYourNickname => 'သင့်အမည်';

  @override
  String get setupRecoveryPassword => 'ပြန်ရယူစကားလုံး (အနည်းဆုံး 16)';

  @override
  String get setupConfirmPassword => 'စကားလုံး အတည်ပြု';

  @override
  String get setupMin16Chars => 'အနည်းဆုံး စလုံး 16 လုံး';

  @override
  String get setupPasswordsDoNotMatch => 'စကားလုံးများ ကိုက်ညီမှု မရှိပါ';

  @override
  String get setupEntropyWeak => 'အားနည်း';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'ခိုင်မာ';

  @override
  String get setupEntropyWeakNeedsVariety =>
      'အားနည်း (စလုံးအမျိုးအစား 3 မျိုး လိုအပ်)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bits)';
  }

  @override
  String get setupPasswordWarning =>
      'ဤစကားလုံးသည် သင့်အကောင့်ကို ပြန်ရယူရန် တစ်ခုတည်းလမ်း ဖြစ်သည်။ ဆာဗာမရှိပါ — စကားလုံး ပြန်သတ်မှတ်လို့မရပါ။ မှတ်ထားပါ သို့မဟုတ် ရေးမှတ်ထားပါ။';

  @override
  String get setupCreateAccount => 'အကောင့်ဖန်တီး';

  @override
  String get setupAlreadyHaveAccount => 'အကောင့်ရှိပြီးသားလား? ';

  @override
  String get setupRestore => 'ပြန်ရယူ →';

  @override
  String get restoreTitle => 'အကောင့် ပြန်ရယူ';

  @override
  String get restoreInfoBanner =>
      'ပြန်ရယူစကားလုံးကို ထည့်ပါ — သင့်လိပ်စာ (Nostr + Session) အလိုအလျောက် ပြန်လည်ပါမည်။ အဆက်အသွယ်များနှင့် မက်ဆက်များသည် စက်ပစ္စည်းတွင်သာ သိမ်းဆည်းခဲ့သည်။';

  @override
  String get restoreNewNickname => 'အမည်အသစ် (နောက်မှပြောင်းနိုင်)';

  @override
  String get restoreButton => 'အကောင့် ပြန်ရယူ';

  @override
  String get lockTitle => 'Pulse လော့ချထားသည်';

  @override
  String get lockSubtitle => 'ဆက်လုပ်ရန် စကားလုံးထည့်ပါ';

  @override
  String get lockPasswordHint => 'စကားလုံး';

  @override
  String get lockUnlock => 'လော့ချဖွင့်';

  @override
  String get lockPanicHint =>
      'စကားလုံးမေ့သွားလား? ဒေတာအားလုံး ဖျက်သိမ်းရန် အရေးပေါက်သော့ချကို ထည့်ပါ။';

  @override
  String get lockTooManyAttempts =>
      'ကြိုးစာမှု များလွန်းသည်။ ဒေတာအားလုံး ဖျက်သိမ်းနေသည်…';

  @override
  String get lockWrongPassword => 'စကားလုံးမှား';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'စကားလုံးမှား — $attempts/$max ကြိုးစာမှု';
  }

  @override
  String get onboardingSkip => 'ကျော်သွား';

  @override
  String get onboardingNext => 'နောက်';

  @override
  String get onboardingGetStarted => 'အကောင့်ဖန်တီးပါ';

  @override
  String get onboardingWelcomeTitle => 'Pulse မှ ကြိုဆိုပါသည်';

  @override
  String get onboardingWelcomeBody =>
      'ဗက်မှတ်စီမဖြန့်ချထားသည့်၌ အစမှအဆုံးအထိ ကုဒ်ဝှက်ထားသည့် မက်ဆက်ပို့ဆော့ဝ်။\n\nဗက်မှတ်ဆာဗာမရှိပါ။ ဒေတာစုဆောင်းခြင်းမရှိပါ။ နောက်တံခါးများမရှိပါ။\nသင့်စကားသွားများသည် သင့်အပိုင်သာ ဖြစ်သည်။';

  @override
  String get onboardingTransportTitle => 'ပို့ဆောင်ရေးနည်းပညာ မျိုးစုံမမှီခို';

  @override
  String get onboardingTransportBody =>
      'Firebase၌ Nostr သို့မဟုတ် နှစ်ခုလုံးကို တစ်ပြိုင်နက် အသုံးပြုပါ။\n\nမက်ဆက်များသည် ကွန်ရက်များကြားတွင် အလိုအလျောက် လမ်းကြောင်းသည်။ ဆင်ဆာခြင်းခုခံနိုင်ရန် Tor နှင့် I2P ပါဝင်သည်။';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'မက်ဆက်တိုင်းကို Signal Protocol (Double Ratchet + X3DH) ဖြင့် forward secrecy အတွက် ကုဒ်ဝှက်ထားသည်။\n\nထပ်ပို့ပြီး Kyber-1024 ဖြင့် ထပ်ရုံထားသည် — အနာဂတ် ကွမ်တမ်ကွန်ပျူတာများမှ ကာကွယ်ရန် NIST စံနှုန်း post-quantum algorithm။';

  @override
  String get onboardingKeysTitle => 'သင့်သော့ချက်များသည် သင့်ပိုင်';

  @override
  String get onboardingKeysBody =>
      'သင့်ရဲ့ အထောက်အထားပြုသော့ချက်များသည် သင့်စက်ပစ္စည်းကို ဘယ်သော့မှ ထွက်မသွားပါ။\n\nSignal လက်နှိပ်များဖြင့် အဆက်အသွယ်များကို အပြင်ဘက်ချနယ်မှ အတည်ပြုနိုင်သည်။ TOFU သည် သော့ချက်ပြောင်းလဲမှုများကို အလိုအလျောက်ရှာဖွေသည်။';

  @override
  String get onboardingThemeTitle => 'သင့်အသွင်အပြင်ကို ရွေးပါ';

  @override
  String get onboardingThemeBody =>
      'အခင်းအနှာနှင့် အရောင်အဆင်းသတ်ကို ရွေးပါ။ ဆက်တင်များတွင် အချိန်မဆို ပြောင်းနိုင်သည်။';

  @override
  String get contactsNewChat => 'ချက်တင်အသစ်';

  @override
  String get contactsAddContact => 'အဆက်အသွယ်ထည့်';

  @override
  String get contactsSearchHint => 'ရှာဖွေ...';

  @override
  String get contactsNewGroup => 'အဖွဲ့အသစ်';

  @override
  String get contactsNoContactsYet => 'အဆက်အသွယ်များ မရှိသေးပါ';

  @override
  String get contactsAddHint =>
      'တစ်စုံတစ်ယောက်ရဲ့ လိပ်စာကိုထည့်ရန် + ကိုနှိပ်ပါ';

  @override
  String get contactsNoMatch => 'ကိုက်ညီသည့် အဆက်အသွယ် မရှိပါ';

  @override
  String get contactsRemoveTitle => 'အဆက်အသွယ် ဖယ်ရှား';

  @override
  String contactsRemoveMessage(String name) {
    return '$name ကို ဖယ်ရှားမည်လား?';
  }

  @override
  String get contactsRemove => 'ဖယ်ရှား';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'အဆက်အသွယ် $count ဦး',
      one: 'အဆက်အသွယ် $count ဦး',
    );
    return '$_temp0';
  }

  @override
  String get bubbleOpenLink => 'လင့်ခ်ဖွင့်';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'ဤ URL ကို ဘရာက်ဆာတွင် ဖွင့်မည်လား?\n\n$url';
  }

  @override
  String get bubbleOpen => 'ဖွင့်';

  @override
  String get bubbleSecurityWarning => 'လုံခြုံရေး သတိပေးချက်';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" သည် အလုပ်လုပ်နိုင်သည့် ဖိုင်အမျိုးအစား ဖြစ်သည်။ သိမ်းဆည်းပြီး အလုပ်လုပ်ခြင်းသည် သင့်စက်ပစ္စည်းကို ထိခိုက်နိုင်သည်။ သိမ်းမည်လား?';
  }

  @override
  String get bubbleSaveAnyway => 'မည်သို့ သိမ်း';

  @override
  String bubbleSavedTo(String path) {
    return '$path သို့ သိမ်းပြီး';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'သိမ်းခြင်း မအောင်မြင်ပါ: $error';
  }

  @override
  String get bubbleNotEncrypted => 'ကုဒ်ဝှက်မထားပါ';

  @override
  String get bubbleCorruptedImage => '[ပျက်စီးသည့် ပုံ]';

  @override
  String get bubbleReplyPhoto => 'ဓာတ်ပုံ';

  @override
  String get bubbleReplyVoice => 'အသံမက်ဆက်';

  @override
  String get bubbleReplyVideo => 'ဗီဒီယိုမက်ဆက်';

  @override
  String bubbleReadBy(String names) {
    return '$names ဖတ်ပြီး';
  }

  @override
  String bubbleReadByCount(int count) {
    return '$count ဦး ဖတ်ပြီး';
  }

  @override
  String get chatTileTapToStart => 'ချက်တင်စရန် နှိပ်ပါ';

  @override
  String get chatTileMessageSent => 'မက်ဆက်ပို့ပြီး';

  @override
  String get chatTileEncryptedMessage => 'ကုဒ်ဝှက်ထားသည့် မက်ဆက်';

  @override
  String chatTileYouPrefix(String text) {
    return 'သင်: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 အသံမက်ဆေ့ဂျ်';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 အသံမက်ဆေ့ဂျ် ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'ကုဒ်ဝှက်ထားသည့် မက်ဆက်';

  @override
  String get groupNewGroup => 'အဖွဲ့အသစ်';

  @override
  String get groupGroupName => 'အဖွဲ့အမည်';

  @override
  String get groupSelectMembers => 'အဖွဲ့ဝင်များ ရွေးပါ (အနည်းဆုံး 2)';

  @override
  String get groupNoContactsYet =>
      'အဆက်အသွယ်များ မရှိသေးပါ။ အရင် အဆက်အသွယ်များ ထည့်ပါ။';

  @override
  String get groupCreate => 'ဖန်တီး';

  @override
  String get groupLabel => 'အဖွဲ့';

  @override
  String get profileVerifyIdentity => 'အထောက်အထား အတည်ပြု';

  @override
  String profileVerifyInstructions(String name) {
    return 'ဤလက်နှိပ်များကို $name နှင့် အသံဖုန်းခေါ်ဆိုမှု သို့မဟုတ် လူကိုယ်တွဲ့တွင် နှိုင်းယှဥ်ပါ။ တန်ဖိုးနှစ်ခုလုံးတွင် တူညီလျှင် “အတည်ပြုပြီးအဖြစ် အမှတ်အသားပြု” ကို နှိပ်ပါ။';
  }

  @override
  String get profileTheirKey => 'သူတို့ရဲ့သော့ချက်';

  @override
  String get profileYourKey => 'သင့်သော့ချက်';

  @override
  String get profileRemoveVerification => 'အတည်ပြုခြင်း ဖယ်ရှား';

  @override
  String get profileMarkAsVerified => 'အတည်ပြုပြီးအဖြစ် အမှတ်အသားပြု';

  @override
  String get profileAddressCopied => 'လိပ်စာ ကူးယူပြီး';

  @override
  String get profileNoContactsToAdd =>
      'ထည့်ရန် အဆက်အသွယ် မရှိပါ — အားလုံး အဖွဲ့ဝင်များ ဖြစ်ပြီး';

  @override
  String get profileAddMembers => 'အဖွဲ့ဝင်များ ထည့်';

  @override
  String profileAddCount(int count) {
    return 'ထည့် ($count)';
  }

  @override
  String get profileRenameGroup => 'အဖွဲ့အမည် ပြောင်း';

  @override
  String get profileRename => 'အမည်ပြောင်း';

  @override
  String get profileRemoveMember => 'အဖွဲ့ဝင် ဖယ်ရှားမည်လား?';

  @override
  String profileRemoveMemberBody(String name) {
    return '$name ကို ဤအဖွဲ့မှ ဖယ်ရှားမည်လား?';
  }

  @override
  String get profileKick => 'ထုတ်';

  @override
  String get profileSignalFingerprints => 'Signal လက်နှိပ်များ';

  @override
  String get profileVerified => 'အတည်ပြုပြီး';

  @override
  String get profileVerify => 'အတည်ပြု';

  @override
  String get profileEdit => 'တည်းဖြတ်';

  @override
  String get profileNoSession => 'စက်ရှင် မတည်ထားရသေးပါ — အရင်မက်ဆက်ပို့ပါ။';

  @override
  String get profileFingerprintCopied => 'လက်နှိပ် ကူးယူပြီး';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'အဖွဲ့ဝင် $count ဦး',
      one: 'အဖွဲ့ဝင် $count ဦး',
    );
    return '$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'လုံခြုံရေးနံပါတ် အတည်ပြု';

  @override
  String get profileShowContactQr => 'အဆက်အသွယ် QR ပြ';

  @override
  String profileContactAddress(String name) {
    return '$name ရဲ့လိပ်စာ';
  }

  @override
  String get profileExportChatHistory => 'ချက်တင်မှတ်တမ်း တင်ပို့';

  @override
  String profileSavedTo(String path) {
    return '$path သို့ သိမ်းပြီး';
  }

  @override
  String get profileExportFailed => 'တင်ပို့ခြင်း မအောင်မြင်ပါ';

  @override
  String get profileClearChatHistory => 'ချက်တင်မှတ်တမ်း ရှင်းလင်း';

  @override
  String get profileDeleteGroup => 'အဖွဲ့ဖျက်သိမ်း';

  @override
  String get profileDeleteContact => 'အဆက်အသွယ်ဖျက်သိမ်း';

  @override
  String get profileLeaveGroup => 'အဖွဲ့မှ ထွက်ခွာ';

  @override
  String get profileLeaveGroupBody =>
      'သင့်ကို ဤအဖွဲ့မှ ဖယ်ရှားမည်ဖြစ်ပြီး သင့်အဆက်အသွယ်များမှ ဖျက်သိမ်းမည်။';

  @override
  String get groupInviteTitle => 'အဖွဲ့ဖိတ်ခေါ်စာ';

  @override
  String groupInviteBody(String from, String group) {
    return '$from မှ သင့်ကို \"$group\" သို့ ဝင်ရန် ဖိတ်ခေါ်ထားသည်';
  }

  @override
  String get groupInviteAccept => 'လက်ခံ';

  @override
  String get groupInviteDecline => 'ပယ်ကျ';

  @override
  String get groupMemberLimitTitle => 'ပါဝင်သူများလွန်း';

  @override
  String groupMemberLimitBody(int count) {
    return 'ဤအဖွဲ့တွင် ပါဝင်သူ $count ဦး ရှိမည်။ ကုဒ်ဝှက်ထားသည့် mesh ဖုန်းခေါ်ဆိုမှုများသည် အများဆုံး 6 ဦး ပံ့ပိုးသည်။ ပိုများသည့်အဖွဲ့များသည် Jitsi (E2EE မဟုတ်) သို့ ပြောင်းမည်။';
  }

  @override
  String get groupMemberLimitContinue => 'မည်သို့ ထည့်';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name သည် \"$group\" သို့ ဝင်ရန် ပယ်ကျခဲ့သည်';
  }

  @override
  String get transferTitle => 'အခြားစက်ပစ္စည်းသို့ လွှေပြောင်း';

  @override
  String get transferInfoBox =>
      'သင့်ရဲ့ Signal အထောက်အထားနှင့် Nostr သော့ချက်များကို စက်ပစ္စည်းအသစ်သို့ ရွှေပါ။\nချက်တင်စက်ရှင်များကို လွှေမပြောင်းပါ — forward secrecy ကို ထိန်းသိမ်းထားသည်။';

  @override
  String get transferSendFromThis => 'ဤစက်ပစ္စည်းမှ ပို့';

  @override
  String get transferSendSubtitle =>
      'ဤစက်ပစ္စည်းတွင် သော့ချက်များရှိသည်။ စက်ပစ္စည်းအသစ်နှင့် ကုဒ်မျှဝေပါ။';

  @override
  String get transferReceiveOnThis => 'ဤစက်ပစ္စည်းတွင် လက်ခံ';

  @override
  String get transferReceiveSubtitle =>
      'ဤသည် စက်ပစ္စည်းအသစ်ဖြစ်သည်။ စက်ပစ္စည်းအဟောင်းမှ ကုဒ်ကို ထည့်ပါ။';

  @override
  String get transferChooseMethod => 'လွှေပြောင်းနည်းလမ်း ရွေးပါ';

  @override
  String get transferLan => 'LAN (ကွန်ရက်တူညီ)';

  @override
  String get transferLanSubtitle =>
      'မြန်ပြီး တိုက်ရိုက်။ စက်ပစ္စည်းနှစ်ခုလုံး Wi-Fi တူညီတွင် ရှိရမည်။';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'ရှိပြီးသား Nostr relay မှတစ်ဆင့် ကွန်ရက်မဆို အသုံးပြုနိုင်သည်။';

  @override
  String get transferRelayUrl => 'Relay URL';

  @override
  String get transferEnterCode => 'လွှေပြောင်းကုဒ် ထည့်ပါ';

  @override
  String get transferPasteCode =>
      'LAN:... သို့မဟုတ် NOS:... ကုဒ်ကို ဤနေရာတွင် ကူးယူထည့်ပါ';

  @override
  String get transferConnect => 'ချိတ်ဆက်';

  @override
  String get transferGenerating => 'လွှေပြောင်းကုဒ် ဖန်တီးနေသည်…';

  @override
  String get transferShareCode => 'ဤကုဒ်ကို လက်ခံသူနှင့် မျှဝေပါ:';

  @override
  String get transferCopyCode => 'ကုဒ်ကူးယူ';

  @override
  String get transferCodeCopied => 'ကုဒ်ကို clipboard သို့ ကူးယူပြီး';

  @override
  String get transferWaitingReceiver => 'လက်ခံသူ ချိတ်ဆက်လာရန် စောင့်နေသည်…';

  @override
  String get transferConnectingSender => 'ပို့သူသို့ ချိတ်ဆက်နေသည်…';

  @override
  String get transferVerifyBoth =>
      'ဤကုဒ်ကို စက်ပစ္စည်းနှစ်ခုလုံးတွင် နှိုင်းယှဥ်ပါ။\nကိုက်ညီပါက လွှေပြောင်းသည် လုံခြုံပါသည်။';

  @override
  String get transferComplete => 'လွှေပြောင်း ပြီးဆုံးပြီ';

  @override
  String get transferKeysImported => 'သော့ချက်များ တင်သွင်းပြီး';

  @override
  String get transferCompleteSenderBody =>
      'သင့်သော့ချက်များသည် ဤစက်ပစ္စည်းတွင် အသုံးပြုဆဲ ရှိနေသည်။\nလက်ခံသူသည် ယခု သင့်အထောက်အထားကို အသုံးပြုနိုင်ပြီ။';

  @override
  String get transferCompleteReceiverBody =>
      'သော့ချက်များ အောင်မြင်စွာ တင်သွင်းပြီး။\nအထောက်အထားအသစ်ကို အသုံးချရန် အပ်ကို ပြန်စတင်ပါ။';

  @override
  String get transferRestartApp => 'အပ်ကို ပြန်စတင်';

  @override
  String get transferFailed => 'လွှေပြောင်း မအောင်မြင်ပါ';

  @override
  String get transferTryAgain => 'ပြန်ကြိုးစား';

  @override
  String get transferEnterRelayFirst => 'Relay URL အရင် ထည့်ပါ';

  @override
  String get transferPasteCodeFromSender =>
      'ပို့သူရဲ့ လွှေပြောင်းကုဒ်ကို ကူးယူထည့်ပါ';

  @override
  String get menuReply => 'ပြန်စာ';

  @override
  String get menuForward => 'ဖော်ဝါဒ်';

  @override
  String get menuReact => 'တုံ့ပြန်';

  @override
  String get menuCopy => 'ကူးယူ';

  @override
  String get menuEdit => 'တည်းဖြတ်';

  @override
  String get menuRetry => 'ပြန်ကြိုးစား';

  @override
  String get menuCancelScheduled => 'အချိန်သတ်မှတ်ခြင်း ဖျက်သိမ်း';

  @override
  String get menuDelete => 'ဖျက်သိမ်း';

  @override
  String get menuForwardTo => 'ဖော်ဝါဒ်ရန်…';

  @override
  String menuForwardedTo(String name) {
    return '$name သို့ ဖော်ဝါဒ်ပြီး';
  }

  @override
  String get menuScheduledMessages => 'အချိန်သတ်မှတ်ထားသည့် မက်ဆက်များ';

  @override
  String get menuNoScheduledMessages => 'အချိန်သတ်မှတ်ထားသည့် မက်ဆက် မရှိပါ';

  @override
  String menuSendsOn(String date) {
    return '$date တွင် ပို့မည်';
  }

  @override
  String get menuDisappearingMessages => 'ပျောက်ကွယ်သည့် မက်ဆက်များ';

  @override
  String get menuDisappearingSubtitle =>
      'မက်ဆက်များသည် ရွေးချယ်ထားသည့်အချိန်ပြီးသည့်အခါ အလိုအလျောက် ဖျက်သိမ်းမည်။';

  @override
  String get menuTtlOff => 'ပိတ်';

  @override
  String get menuTtl1h => '1 နာရီ';

  @override
  String get menuTtl24h => '24 နာရီ';

  @override
  String get menuTtl7d => '7 ရက်';

  @override
  String get menuAttachPhoto => 'ဓာတ်ပုံ';

  @override
  String get menuAttachFile => 'ဖိုင်';

  @override
  String get menuAttachVideo => 'ဗီဒီယို';

  @override
  String get mediaTitle => 'မီဒီယာ';

  @override
  String get mediaFileLabel => 'ဖိုင်';

  @override
  String mediaPhotosTab(int count) {
    return 'ဓာတ်ပုံများ ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'ဖိုင်များ ($count)';
  }

  @override
  String get mediaNoPhotos => 'ဓာတ်ပုံများ မရှိသေးပါ';

  @override
  String get mediaNoFiles => 'ဖိုင်များ မရှိသေးပါ';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Downloads/$name သို့ သိမ်းပြီး';
  }

  @override
  String get mediaFailedToSave => 'ဖိုင်သိမ်းခြင်း မအောင်မြင်ပါ';

  @override
  String get statusNewStatus => 'အခြေအနေအသစ်';

  @override
  String get statusPublish => 'ထုတ်လွှင့်';

  @override
  String get statusExpiresIn24h => 'အခြေအနေသည် 24 နာရီအတွင်း သက်တမ်းကုန်မည်';

  @override
  String get statusWhatsOnYourMind => 'ဘာသတိပြုနေလဲ?';

  @override
  String get statusPhotoAttached => 'ဓာတ်ပုံပူးတွဲပြီး';

  @override
  String get statusAttachPhoto => 'ဓာတ်ပုံပူးတွဲ (ရွေးချယ်ချက်)';

  @override
  String get statusEnterText => 'သင့်အခြေအနေအတွက် စာသား ထည့်ပါ။';

  @override
  String statusPickPhotoFailed(String error) {
    return 'ဓာတ်ပုံရွေးချယ်ခြင်း မအောင်မြင်ပါ: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'ထုတ်လွှင့်ခြင်း မအောင်မြင်ပါ: $error';
  }

  @override
  String get panicSetPanicKey => 'အရေးပေါက်သော့ချ သတ်မှတ်';

  @override
  String get panicEmergencySelfDestruct => 'အရေးပေါက် ကိုယ်တိုင်ဖျက်သိမ်းခြင်း';

  @override
  String get panicIrreversible => 'ဤလုပ်ဆောင်ချက်ကို ပြန်ဖျက်လို့မရပါ';

  @override
  String get panicWarningBody =>
      'ဤသော့ချကို လော့ချမျက်နှာပြင်တွင် ထည့်လိုက်လျှင် ဒေတာအားလုံးကို ချက်ချင်း ဖျက်သိမ်းပါမည် — မက်ဆက်များ၌ အဆက်အသွယ်များ၌ သော့ချက်များ၌ အထောက်အထား။ သင့်ပုံမှန် စကားလုံးနှင့် မတူညီသည့် သော့ချကို အသုံးပြုပါ။';

  @override
  String get panicKeyHint => 'အရေးပေါက်သော့ချ';

  @override
  String get panicConfirmHint => 'အရေးပေါက်သော့ချ အတည်ပြု';

  @override
  String get panicMinChars =>
      'အရေးပေါက်သော့ချသည် အနည်းဆုံး စလုံး 8 လုံး ရှိရမည်';

  @override
  String get panicKeysDoNotMatch => 'သော့ချများ ကိုက်ညီမှုမရှိပါ';

  @override
  String get panicSetFailed => 'အရေးပေါက်သော့ချ သိမ်းလို့မရပါ — ပြန်ကြိုးစားပါ';

  @override
  String get passwordSetAppPassword => 'အပ်စကားလုံး သတ်မှတ်';

  @override
  String get passwordProtectsMessages =>
      'သင့်မက်ဆက်များကို အနားယူချိန် ကာကွယ်ပါသည်';

  @override
  String get passwordInfoBanner =>
      'Pulse ကို ဖွင့်တိုင်း လိုအပ်သည်။ မေ့သွားပါက သင့်ဒေတာကို ပြန်ရယူလို့မရပါ။';

  @override
  String get passwordHint => 'စကားလုံး';

  @override
  String get passwordConfirmHint => 'စကားလုံး အတည်ပြု';

  @override
  String get passwordSetButton => 'စကားလုံး သတ်မှတ်';

  @override
  String get passwordSkipForNow => 'ယခုကျော်သွား';

  @override
  String get passwordMinChars => 'စကားလုံးသည် အနည်းဆုံး စလုံး 8 လုံး ရှိရမည်';

  @override
  String get passwordNeedsVariety =>
      'စာလုံး၊ ဂဏန်းနှင့် အထူးအက္ခရာများ ပါဝင်ရမည်';

  @override
  String get passwordRequirements =>
      'အနည်းဆုံး 8 လုံး စာလုံး၊ ဂဏန်းနှင့် အထူးအက္ခရာ ပါဝင်ရမည်';

  @override
  String get passwordsDoNotMatch => 'စကားလုံးများ ကိုက်ညီမှုမရှိပါ';

  @override
  String get profileCardSaved => 'ပရိုဖိုင် သိမ်းပြီး!';

  @override
  String get profileCardE2eeIdentity => 'E2EE အထောက်အထား';

  @override
  String get profileCardDisplayName => 'ပြသည့်အမည်';

  @override
  String get profileCardDisplayNameHint => 'ဥပမာ - မင်းမင်း';

  @override
  String get profileCardAbout => 'အကြောင်း';

  @override
  String get profileCardSaveProfile => 'ပရိုဖိုင်သိမ်း';

  @override
  String get profileCardYourName => 'သင့်အမည်';

  @override
  String get profileCardAddressCopied => 'လိပ်စာ ကူးယူပြီး!';

  @override
  String get profileCardInboxAddress => 'သင့်ရဲ့ ဝင်စာလိပ်စာ';

  @override
  String get profileCardInboxAddresses => 'သင့်ရဲ့ ဝင်စာလိပ်စာများ';

  @override
  String get profileCardShareAllAddresses =>
      'လိပ်စာအားလုံး မျှဝေ (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'အဆက်အသွယ်များနှင့် မျှဝေပါ သူတို့မှ သင့်ကို မက်ဆက်ပို့နိုင်သည်။';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'လိပ်စာ $count ခုအားလုံးကို လင့်ခ်တစ်ခုအဖြစ် ကူးယူပြီး!';
  }

  @override
  String get settingsMyProfile => 'ကျွန်ုပ်ပရိုဖိုင်';

  @override
  String get settingsYourInboxAddress => 'သင့်ရဲ့ ဝင်စာလိပ်စာ';

  @override
  String get settingsMyQrCode => 'အဆက်အသွယ် မျှဝေပါ';

  @override
  String get settingsMyQrSubtitle =>
      'သင့်လိပ်စာအတွက် QR ကုဒ်နှင့် ဖိတ်ခေါ်လင့်ခ်';

  @override
  String get settingsShareMyAddress => 'ကျွန်ုပ်လိပ်စာ မျှဝေ';

  @override
  String get settingsNoAddressYet => 'လိပ်စာမရှိသေးပါ — အရင်ဆက်တင်များ သိမ်းပါ';

  @override
  String get settingsInviteLink => 'ဖိတ်ခေါ်လင့်ခ်';

  @override
  String get settingsRawAddress => 'မူလလိပ်စာ';

  @override
  String get settingsCopyLink => 'လင့်ခ်ကူးယူ';

  @override
  String get settingsCopyAddress => 'လိပ်စာကူးယူ';

  @override
  String get settingsInviteLinkCopied => 'ဖိတ်ခေါ်လင့်ခ် ကူးယူပြီး';

  @override
  String get settingsAppearance => 'အသွင်အပြင်';

  @override
  String get settingsThemeEngine => 'အခင်းအနှာ အင်ဂျင်';

  @override
  String get settingsThemeEngineSubtitle =>
      'အရောင်များနှင့် ဖောင့်များ စိတ်ကြိုက်ပြင်ဆင်';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle =>
      'E2EE သော့ချက်များကို လုံခြုံစွာ သိမ်းဆည်းထားသည်';

  @override
  String get settingsActive => 'အသုံးပြုနေ';

  @override
  String get settingsIdentityBackup => 'အထောက်အထား အရန်သင်';

  @override
  String get settingsIdentityBackupSubtitle =>
      'သင့်ရဲ့ Signal အထောက်အထားကို တင်ပို့ သို့မဟုတ် တင်သွင်း';

  @override
  String get settingsIdentityBackupBody =>
      'သင့်ရဲ့ Signal အထောက်အထားသော့ချက်များကို အရန်သင်ကုဒ်သို့ တင်ပို့ပါ သို့မဟုတ် ရှိပြီးသားမှ ပြန်လည်ပါ။';

  @override
  String get settingsTransferDevice => 'အခြားစက်ပစ္စည်းသို့ လွှေပြောင်း';

  @override
  String get settingsTransferDeviceSubtitle =>
      'သင့်အထောက်အထားကို LAN သို့မဟုတ် Nostr relay မှတစ်ဆင့် ရွှေပါ';

  @override
  String get settingsExportIdentity => 'အထောက်အထား တင်ပို့';

  @override
  String get settingsExportIdentityBody =>
      'ဤအရန်သင်ကုဒ်ကို ကူးယူပြီး လုံခြုံစွာ သိမ်းပါ:';

  @override
  String get settingsSaveFile => 'ဖိုင်သိမ်း';

  @override
  String get settingsImportIdentity => 'အထောက်အထား တင်သွင်း';

  @override
  String get settingsImportIdentityBody =>
      'သင့်ရဲ့ အရန်သင်ကုဒ်ကို အောက်တွင် ကူးယူထည့်ပါ။ ဤသည် သင့်လက်ရှိအထောက်အထားကို အစားထိုးမည်။';

  @override
  String get settingsPasteBackupCode => 'အရန်သင်ကုဒ်ကို ဤနေရာတွင် ကူးယူထည့်ပါ…';

  @override
  String get settingsIdentityImported =>
      'အထောက်အထား + အဆက်အသွယ်များ တင်သွင်းပြီး! အသုံးချရန် အပ်ကို ပြန်စတင်ပါ။';

  @override
  String get settingsSecurity => 'လုံခြုံရေး';

  @override
  String get settingsAppPassword => 'အပ်စကားလုံး';

  @override
  String get settingsPasswordEnabled => 'ဖွင့်ထား — ဖွင့်တိုင်း လိုအပ်သည်';

  @override
  String get settingsPasswordDisabled => 'ပိတ်ထား — စကားလုံးမပါဘဲ အပ်ဖွင့်သည်';

  @override
  String get settingsChangePassword => 'စကားလုံးပြောင်း';

  @override
  String get settingsChangePasswordSubtitle =>
      'အပ်လော့ချစကားလုံးကို အပ်ဒေတ်လုပ်';

  @override
  String get settingsSetPanicKey => 'အရေးပေါက်သော့ချ သတ်မှတ်';

  @override
  String get settingsChangePanicKey => 'အရေးပေါက်သော့ချ ပြောင်း';

  @override
  String get settingsPanicKeySetSubtitle =>
      'အရေးပေါက်ဖျက်သိမ်းသော့ချကို အပ်ဒေတ်လုပ်';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'ဒေတာအားလုံးကို ချက်ချင်းဖျက်သိမ်းသည့် သော့ချတစ်ခု';

  @override
  String get settingsRemovePanicKey => 'အရေးပေါက်သော့ချ ဖယ်ရှား';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'အရေးပေါက် ကိုယ်တိုင်ဖျက်သိမ်းခြင်း ပိတ်';

  @override
  String get settingsRemovePanicKeyBody =>
      'အရေးပေါက် ကိုယ်တိုင်ဖျက်သိမ်းခြင်းကို ပိတ်မည်။ အချိန်မဆို ပြန်ဖွင့်နိုင်သည်။';

  @override
  String get settingsDisableAppPassword => 'အပ်စကားလုံး ပိတ်';

  @override
  String get settingsEnterCurrentPassword =>
      'အတည်ပြုရန် လက်ရှိစကားလုံးကို ထည့်ပါ';

  @override
  String get settingsCurrentPassword => 'လက်ရှိစကားလုံး';

  @override
  String get settingsIncorrectPassword => 'စကားလုံးမှား';

  @override
  String get settingsPasswordUpdated => 'စကားလုံး အပ်ဒေတ်ပြီး';

  @override
  String get settingsChangePasswordProceed =>
      'ဆက်လုပ်ရန် လက်ရှိစကားလုံးကို ထည့်ပါ';

  @override
  String get settingsData => 'ဒေတာ';

  @override
  String get settingsBackupMessages => 'မက်ဆက်များ အရန်သင်';

  @override
  String get settingsBackupMessagesSubtitle =>
      'ကုဒ်ဝှက်ထားသည့် မက်ဆက်မှတ်တမ်းကို ဖိုင်သို့ တင်ပို့';

  @override
  String get settingsRestoreMessages => 'မက်ဆက်များ ပြန်ရယူ';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'အရန်သင်ဖိုင်မှ မက်ဆက်များ တင်သွင်း';

  @override
  String get settingsExportKeys => 'သော့ချက်များ တင်ပို့';

  @override
  String get settingsExportKeysSubtitle =>
      'အထောက်အထားသော့ချက်များကို ကုဒ်ဝှက်ထားသည့်ဖိုင်တွင် သိမ်း';

  @override
  String get settingsImportKeys => 'သော့ချက်များ တင်သွင်း';

  @override
  String get settingsImportKeysSubtitle =>
      'တင်ပို့ထားသည့်ဖိုင်မှ အထောက်အထားသော့ချက်များ ပြန်ရယူ';

  @override
  String get settingsBackupPassword => 'အရန်သင်စကားလုံး';

  @override
  String get settingsPasswordCannotBeEmpty => 'စကားလုံး အလွတ်မဖြစ်ရ';

  @override
  String get settingsPasswordMin4Chars =>
      'စကားလုံးသည် အနည်းဆုံး စလုံး 4 လုံး ရှိရမည်';

  @override
  String get settingsCallsTurn => 'ဖုန်းခေါ်ဆိုမှုနှင့် TURN';

  @override
  String get settingsLocalNetwork => 'ပြည်တွင်းကွန်ရက်';

  @override
  String get settingsCensorshipResistance => 'ဆင်ဆာခြင်း ခုခံနိုင်မှု';

  @override
  String get settingsNetwork => 'ကွန်ရက်';

  @override
  String get settingsProxyTunnels => 'ပရောက်ဆီနှင့် တူည်နလ်များ';

  @override
  String get settingsTurnServers => 'TURN ဆာဗာများ';

  @override
  String get settingsProviderTitle => 'ဝန်ဆောင်မှုပေးသူ';

  @override
  String get settingsLanFallback => 'LAN အရန်သင်';

  @override
  String get settingsLanFallbackSubtitle =>
      'အင်တာနက်မရရှိသည့်အခါ ပြည်တွင်းကွန်ရက်တွင် တည်ရှိမှုကို ထုတ်လွှင့်ပြီး မက်ဆက်များ ပို့သည်။ ယုံကြည်မရသည့် ကွန်ရက်များ (အများပြည်သူံး Wi-Fi) တွင် ပိတ်ပါ။';

  @override
  String get settingsBgDelivery => 'နောက်ခံပို့ဆောင်ခြင်း';

  @override
  String get settingsBgDeliverySubtitle =>
      'အပ်ကို ချုံ့ထားသည့်အခါ မက်ဆက်များ ဆက်လက်ခံပါ။ အမြဲတမ်း အကြောင်းကား ပြသည်။';

  @override
  String get settingsYourInboxProvider => 'သင့်ရဲ့ ဝင်စာဝန်ဆောင်မှုပေးသူ';

  @override
  String get settingsConnectionDetails => 'ချိတ်ဆက်မှု အသေးစိတ်';

  @override
  String get settingsSaveAndConnect => 'သိမ်းပြီး ချိတ်ဆက်';

  @override
  String get settingsSecondaryInboxes => 'ဒုတိယ ဝင်စာများ';

  @override
  String get settingsAddSecondaryInbox => 'ဒုတိယ ဝင်စာထည့်';

  @override
  String get settingsAdvanced => 'အဆင့်မြင့်';

  @override
  String get settingsDiscover => 'ရှာဖွေ';

  @override
  String get settingsAbout => 'အကြောင်း';

  @override
  String get settingsPrivacyPolicy => 'ကိုယ်ရေးလုံခြုံရေး မူဝါဒ';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Pulse မှ သင့်ဒေတာကို ဘယ်လို ကာကွယ်သလဲ';

  @override
  String get settingsCrashReporting => 'ပျက်ကျမှု အစီရင်ခံ';

  @override
  String get settingsCrashReportingSubtitle =>
      'Pulse ကို တိုးတက်ရန် အမည်မသိ ပျက်ကျမှုအစီရင်ခံများ ပို့ပါ။ မက်ဆက်အကြောင်းအရာ သို့မဟုတ် အဆက်အသွယ်များကို ဘယ်သော့မှ မပို့ပါ။';

  @override
  String get settingsCrashReportingEnabled =>
      'ပျက်ကျမှုအစီရင်ခံ ဖွင့်ပြီး — အသုံးချရန် အပ်ကို ပြန်စတင်ပါ';

  @override
  String get settingsCrashReportingDisabled =>
      'ပျက်ကျမှုအစီရင်ခံ ပိတ်ပြီး — အသုံးချရန် အပ်ကို ပြန်စတင်ပါ';

  @override
  String get settingsSensitiveOperation => 'အရေးကြီးသည့် လုပ်ဆောင်ချက်';

  @override
  String get settingsSensitiveOperationBody =>
      'ဤသော့ချက်များသည် သင့်အထောက်အထားဖြစ်သည်။ ဤဖိုင်ရှိသူမည်သူမဆို သင့်ကို အယောင်ဆောင်နိုင်သည်။ လုံခြုံစွာ သိမ်းပြီး လွှေပြောင်းပြီးနောက် ဖျက်သိမ်းပါ။';

  @override
  String get settingsIUnderstandContinue => 'နားလည်ပါသည်၌ ဆက်လုပ်';

  @override
  String get settingsReplaceIdentity => 'အထောက်အထား အစားထိုးမည်လား?';

  @override
  String get settingsReplaceIdentityBody =>
      'ဤသည် သင့်လက်ရှိအထောက်အထားသော့ချက်များကို အစားထိုးမည်။ ရှိပြီးသား Signal စက်ရှင်များသည် ပယ်ဖျက်မည်ဖြစ်ပြီး အဆက်အသွယ်များမှ ကုဒ်ဝှက်ခြင်း ပြန်တည်ရမည်။ အပ်ကို ပြန်စတင်ရမည်။';

  @override
  String get settingsReplaceKeys => 'သော့ချက်များ အစားထိုး';

  @override
  String get settingsKeysImported => 'သော့ချက်များ တင်သွင်းပြီး';

  @override
  String settingsKeysImportedBody(int count) {
    return 'သော့ချက် $count ခု အောင်မြင်စွာ တင်သွင်းပြီး။ အထောက်အထားအသစ်ဖြင့် ပြန်စတင်ရန် အပ်ကို ပြန်စတင်ပါ။';
  }

  @override
  String get settingsRestartNow => 'ယခုပြန်စတင်';

  @override
  String get settingsLater => 'နောက်မှ';

  @override
  String get profileGroupLabel => 'အဖွဲ့';

  @override
  String get profileAddButton => 'ထည့်';

  @override
  String get profileKickButton => 'ထုတ်';

  @override
  String get dataSectionTitle => 'ဒေတာ';

  @override
  String get dataBackupMessages => 'မက်ဆက်များ အရန်သင်';

  @override
  String get dataBackupPasswordSubtitle =>
      'သင့်မက်ဆက်အရန်သင်ကို ကုဒ်ဝှက်ရန် စကားလုံးရွေးပါ။';

  @override
  String get dataBackupConfirmLabel => 'အရန်သင်ဖန်တီး';

  @override
  String get dataCreatingBackup => 'အရန်သင်ဖန်တီးနေသည်';

  @override
  String get dataBackupPreparing => 'ပြင်ဆင်နေသည်...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'မက်ဆက် $done/$total တင်ပို့နေသည်...';
  }

  @override
  String get dataBackupSavingFile => 'ဖိုင်သိမ်းနေသည်...';

  @override
  String get dataSaveMessageBackupDialog => 'မက်ဆက်အရန်သင် သိမ်း';

  @override
  String dataBackupSaved(int count, String path) {
    return 'အရန်သင် သိမ်းပြီး (မက်ဆက် $count ခု)\n$path';
  }

  @override
  String get dataBackupFailed => 'အရန်သင် မအောင်မြင်ပါ — ဒေတာမတင်ပို့ရပါ';

  @override
  String dataBackupFailedError(String error) {
    return 'အရန်သင် မအောင်မြင်ပါ: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'မက်ဆက်အရန်သင် ရွေး';

  @override
  String get dataInvalidBackupFile =>
      'အရန်သင်ဖိုင် မမှန်ပါ (အရွယ်အစားငယ်လွန်း)';

  @override
  String get dataNotValidBackupFile => 'မှန်ကန်သည့် Pulse အရန်သင်ဖိုင် မဟုတ်ပါ';

  @override
  String get dataRestoreMessages => 'မက်ဆက်များ ပြန်ရယူ';

  @override
  String get dataRestorePasswordSubtitle =>
      'ဤအရန်သင်ကို ဖန်တီးရန် အသုံးပြုခဲ့သည့် စကားလုံးကို ထည့်ပါ။';

  @override
  String get dataRestoreConfirmLabel => 'ပြန်ရယူ';

  @override
  String get dataRestoringMessages => 'မက်ဆက်များ ပြန်ရယူနေသည်';

  @override
  String get dataRestoreDecrypting => 'ကုဒ်ဖော်နေသည်...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'မက်ဆက် $done/$total တင်သွင်းနေသည်...';
  }

  @override
  String get dataRestoreFailed =>
      'ပြန်ရယူခြင်း မအောင်မြင်ပါ — စကားလုံးမှား သို့မဟုတ် ဖိုင်ပျက်စီး';

  @override
  String dataRestoreSuccess(int count) {
    return 'မက်ဆက်အသစ် $count ခု ပြန်ရယူပြီး';
  }

  @override
  String get dataRestoreNothingNew =>
      'တင်သွင်းရန် မက်ဆက်အသစ်များ မရှိပါ (အားလုံး ရှိပြီးသား)';

  @override
  String dataRestoreFailedError(String error) {
    return 'ပြန်ရယူခြင်း မအောင်မြင်ပါ: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'သော့ချက်တင်ပို့ဖိုင် ရွေး';

  @override
  String get dataNotValidKeyFile =>
      'မှန်ကန်သည့် Pulse သော့ချက်တင်ပို့ဖိုင် မဟုတ်ပါ';

  @override
  String get dataExportKeys => 'သော့ချက်များ တင်ပို့';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'သော့ချက်တင်ပို့ကို ကုဒ်ဝှက်ရန် စကားလုံးရွေးပါ။';

  @override
  String get dataExportKeysConfirmLabel => 'တင်ပို့';

  @override
  String get dataExportingKeys => 'သော့ချက်များ တင်ပို့နေသည်';

  @override
  String get dataExportingKeysStatus =>
      'အထောက်အထားသော့ချက်များ ကုဒ်ဝှက်နေသည်...';

  @override
  String get dataSaveKeyExportDialog => 'သော့ချက်တင်ပို့ သိမ်း';

  @override
  String dataKeysExportedTo(String path) {
    return 'သော့ချက်များ တင်ပို့ပြီး:\n$path';
  }

  @override
  String get dataExportFailed => 'တင်ပို့ခြင်း မအောင်မြင်ပါ — သော့ချက်မတွေ့ပါ';

  @override
  String dataExportFailedError(String error) {
    return 'တင်ပို့ခြင်း မအောင်မြင်ပါ: $error';
  }

  @override
  String get dataImportKeys => 'သော့ချက်များ တင်သွင်း';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'ဤသော့ချက်တင်ပို့ကို ကုဒ်ဝှက်ရန် အသုံးပြုခဲ့သည့် စကားလုံးကို ထည့်ပါ။';

  @override
  String get dataImportKeysConfirmLabel => 'တင်သွင်း';

  @override
  String get dataImportingKeys => 'သော့ချက်များ တင်သွင်းနေသည်';

  @override
  String get dataImportingKeysStatus =>
      'အထောက်အထားသော့ချက်များ ကုဒ်ဖော်နေသည်...';

  @override
  String get dataImportFailed =>
      'တင်သွင်းခြင်း မအောင်မြင်ပါ — စကားလုံးမှား သို့မဟုတ် ဖိုင်ပျက်စီး';

  @override
  String dataImportFailedError(String error) {
    return 'တင်သွင်းခြင်း မအောင်မြင်ပါ: $error';
  }

  @override
  String get securitySectionTitle => 'လုံခြုံရေး';

  @override
  String get securityIncorrectPassword => 'စကားလုံးမှား';

  @override
  String get securityPasswordUpdated => 'စကားလုံး အပ်ဒေတ်ပြီး';

  @override
  String get appearanceSectionTitle => 'အသွင်အပြင်';

  @override
  String appearanceExportFailed(String error) {
    return 'တင်ပို့ခြင်း မအောင်မြင်ပါ: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return '$path သို့ သိမ်းပြီး';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'သိမ်းခြင်း မအောင်မြင်ပါ: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'တင်သွင်းခြင်း မအောင်မြင်ပါ: $error';
  }

  @override
  String get aboutSectionTitle => 'အကြောင်း';

  @override
  String get providerPublicKey => 'အများသုံးသော့ချက်';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'သင့်ပြန်ရယူစကားလုံးမှ အလိုအလျောက်ပြင်ဆင်ထားသည်။ Relay အလိုအလျောက်ရှာဖွေပြီး။';

  @override
  String get providerKeyStoredLocally =>
      'သင့်သော့ချက်ကို စက်တွင်း လုံခြုံရေးသိုလှေညှာတွင် သိမ်းထားသည် — ဆာဗာမည်သည့်သို့မျှ မပို့ပါ။';

  @override
  String get providerSessionInfo =>
      'Session Network — ကြက်သွန်-လမ်းကြောင်းညွှန် E2EE။ သင်၏ Session ID ကို အလိုအလျောက် ဖန်တီးကာ လုံခြုံစွာ သိမ်းဆည်းသည်။ Node များကို ကြိုတင်ထည့်သွင်းထားသော seed node များမှ အလိုအလျောက် ရှာဖွေတွေ့ရှိသည်။';

  @override
  String get providerAdvanced => 'အဆင့်မြင့်';

  @override
  String get providerSaveAndConnect => 'သိမ်းပြီး ချိတ်ဆက်';

  @override
  String get providerAddSecondaryInbox => 'ဒုတိယ ဝင်စာထည့်';

  @override
  String get providerSecondaryInboxes => 'ဒုတိယ ဝင်စာများ';

  @override
  String get providerYourInboxProvider => 'သင့်ရဲ့ ဝင်စာဝန်ဆောင်မှုပေးသူ';

  @override
  String get providerConnectionDetails => 'ချိတ်ဆက်မှု အသေးစိတ်';

  @override
  String get addContactTitle => 'အဆက်အသွယ်ထည့်';

  @override
  String get addContactInviteLinkLabel => 'ဖိတ်ခေါ်လင့်ခ် သို့မဟုတ် လိပ်စာ';

  @override
  String get addContactTapToPaste => 'ဖိတ်ခေါ်လင့်ခ်ကို ကူးယူထည့်ရန် နှိပ်ပါ';

  @override
  String get addContactPasteTooltip => 'clipboard မှ ကူးယူထည့်';

  @override
  String get addContactAddressDetected => 'အဆက်အသွယ်လိပ်စာ တွေ့ရှိပြီ';

  @override
  String addContactRoutesDetected(int count) {
    return 'လမ်းကြောင်း $count ခု တွေ့ရှိပြီ — SmartRouter သည် အမြန်ဆုံးကို ရွေးသည်';
  }

  @override
  String get addContactFetchingProfile => 'ပရိုဖိုင် ရယူနေသည်…';

  @override
  String addContactProfileFound(String name) {
    return 'တွေ့ရှိပြီ: $name';
  }

  @override
  String get addContactNoProfileFound => 'ပရိုဖိုင် မတွေ့ပါ';

  @override
  String get addContactDisplayNameLabel => 'ပြသည့်အမည်';

  @override
  String get addContactDisplayNameHint => 'သူတို့ကို ဘယ်လိုခေါ်ချင်လဲ?';

  @override
  String get addContactAddManually => 'လိပ်စာကို ကိုယ်တိုင်ထည့်';

  @override
  String get addContactButton => 'အဆက်အသွယ်ထည့်';

  @override
  String get networkDiagnosticsTitle => 'ကွန်ရက်စစ်ဆေးခြင်း';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr Relay များ';

  @override
  String get networkDiagnosticsDirect => 'တိုက်ရိုက်';

  @override
  String get networkDiagnosticsTorOnly => 'Tor သာ';

  @override
  String get networkDiagnosticsBest => 'အကောင်းဆုံး';

  @override
  String get networkDiagnosticsNone => 'မရှိ';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'အခြေအနေ';

  @override
  String get networkDiagnosticsConnected => 'ချိတ်ဆက်ပြီ';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'ချိတ်ဆက်နေသည် $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'ပိတ်';

  @override
  String get networkDiagnosticsTransport => 'ပို့ဆောင်ရေး';

  @override
  String get networkDiagnosticsInfrastructure => 'အခြေခံအဆောက်အအုံ';

  @override
  String get networkDiagnosticsSessionNodes => 'Session နှိုင်ဆိုင်ရာ';

  @override
  String get networkDiagnosticsTurnServers => 'TURN ဆာဗာများ';

  @override
  String get networkDiagnosticsLastProbe => 'နောက်ဆုံးစစ်ဆေးချိန်';

  @override
  String get networkDiagnosticsRunning => 'လုပ်ဆောင်နေသည်...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'စစ်ဆေးခြင်း စတင်';

  @override
  String get networkDiagnosticsForceReprobe => 'အပြည့်အဝ ပြန်စစ်ဆေး';

  @override
  String get networkDiagnosticsJustNow => 'ယခုလေးတင်';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'မိနစ် $minutes ခု အကြာ';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'နာရီ $hours ခု အကြာ';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'ရက် $days ခု အကြာ';
  }

  @override
  String get homeNoEch => 'ECH မရှိ';

  @override
  String get homeNoEchTooltip =>
      'uTLS proxy မရရှိပါ — ECH ပိတ်ထားသည်။\nTLS လက်နှိပ်သည် DPI မှ မြင်နိုင်သည်။';

  @override
  String get settingsTitle => 'ဆက်တင်များ';

  @override
  String settingsSavedConnectedTo(String provider) {
    return '$provider သို့ သိမ်းပြီး ချိတ်ဆက်ပြီ';
  }

  @override
  String get settingsTorFailedToStart => 'ပါဝင်သော Tor စတင်လို့မရပါ';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon စတင်လို့မရပါ';

  @override
  String get verifyTitle => 'လုံခြုံရေးနံပါတ် အတည်ပြု';

  @override
  String get verifyIdentityVerified => 'အထောက်အထား အတည်ပြုပြီ';

  @override
  String get verifyNotYetVerified => 'မအတည်ပြုရသေးပါ';

  @override
  String verifyVerifiedDescription(String name) {
    return '$name ၏ လုံခြုံရေးနံပါတ်ကို သင် အတည်ပြုပြီးပါပြီ။';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'ဤနံပါတ်များကို $name နှင့် လူကိုယ်တွဲ့တွင် သို့မဟုတ် ယုံကြည်ရသည့်ချနယ်မှ နှိုင်းယှဥ်ပါ။';
  }

  @override
  String get verifyExplanation =>
      'စကားသွားတစ်ခုစီတွင် ထူးခြားသည့် လုံခြုံရေးနံပါတ် ရှိသည်။ သင့်စက်ပစ္စည်းများတွင် နံပါတ်များတူညီလျှင် သင့်ချိတ်ဆက်မှုသည် အစမှအဆုံးအထိ အတည်ပြုပြီးဖြစ်သည်။';

  @override
  String verifyContactKey(String name) {
    return '$name ၏ သော့ချက်';
  }

  @override
  String get verifyYourKey => 'သင့်သော့ချက်';

  @override
  String get verifyRemoveVerification => 'အတည်ပြုခြင်း ဖယ်ရှား';

  @override
  String get verifyMarkAsVerified => 'အတည်ပြုပြီးအဖြစ် အမှတ်အသားပြု';

  @override
  String verifyAfterReinstall(String name) {
    return '$name သည် အပ်ကို ပြန်တင်လျှင် လုံခြုံရေးနံပါတ် ပြောင်းမည်ဖြစ်ပြီး အတည်ပြုခြင်းကို အလိုအလျောက် ဖယ်ရှားမည်။';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return '$name နှင့် အသံဖုန်းခေါ်ဆိုမှု သို့မဟုတ် လူကိုယ်တွဲ့တွင် နံပါတ်များ နှိုင်းယှဥ်ပြီးမှသာ အတည်ပြုပြီးအဖြစ် အမှတ်အသားပြုပါ။';
  }

  @override
  String get verifyNoSession =>
      'ကုဒ်ဝှက်ခြင်းစက်ရှင် မတည်ထားရသေးပါ။ လုံခြုံရေးနံပါတ်များ ဖန်တီးရန် အရင် မက်ဆက်ပို့ပါ။';

  @override
  String get verifyNoKeyAvailable => 'သော့ချက် မရရှိပါ';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label လက်နှိပ် ကူးယူပြီ';
  }

  @override
  String get providerDatabaseUrlLabel => 'ဒေတာဘေ့စ် URL';

  @override
  String get providerOptionalHint => 'ရွေးချယ်ချက်';

  @override
  String get providerWebApiKeyLabel => 'Web API Key';

  @override
  String get providerOptionalForPublicDb => 'အများသုံး DB အတွက် ရွေးချယ်ချက်';

  @override
  String get providerRelayUrlLabel => 'Relay URL';

  @override
  String get providerPrivateKeyLabel => 'ကိုယ်ပိုင်သော့ချက်';

  @override
  String get providerPrivateKeyNsecLabel => 'ကိုယ်ပိုင်သော့ချက် (nsec)';

  @override
  String get providerStorageNodeLabel => 'Storage Node URL (ရွေးချယ်ချက်)';

  @override
  String get providerStorageNodeHint =>
      'ပါဝင်သော seed node များအတွက် အလွတ်ထားပါ';

  @override
  String get transferInvalidCodeFormat =>
      'ကုဒ်ပုံစံ မသိပါ — LAN: သို့မဟုတ် NOS: ဖြင့် စရမည်';

  @override
  String get profileCardFingerprintCopied => 'လက်နှိပ် ကူးယူပြီ';

  @override
  String get profileCardAboutHint => 'ကိုယ်ရေးလုံခြုံရေး ဦးစားပေး';

  @override
  String get profileCardSaveButton => 'ပရိုဖိုင်သိမ်း';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'ကုဒ်ဝှက်ထားသည့် မက်ဆက်များ၊ အဆက်အသွယ်များနှင့် ပရိုဖိုင်ပုံများကို ဖိုင်သို့ တင်ပို့';

  @override
  String get callVideo => 'ဗီဒီယို';

  @override
  String get callAudio => 'အသံ';

  @override
  String bubbleDeliveredTo(String names) {
    return '$names ထံ ပို့ပြီ';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return '$count ဦးထံ ပို့ပြီ';
  }

  @override
  String get groupStatusDialogTitle => 'မက်ဆက်အချက်အလက်';

  @override
  String get groupStatusRead => 'ဖတ်ပြီ';

  @override
  String get groupStatusDelivered => 'ပို့ပြီ';

  @override
  String get groupStatusPending => 'စောင့်ဆိုင်းနေ';

  @override
  String get groupStatusNoData => 'ပို့ဆောင်မှု အချက်အလက် မရှိသေးပါ';

  @override
  String get profileTransferAdmin => 'စီမံခန့်ခွဲသူ ဖြစ်စေ';

  @override
  String profileTransferAdminConfirm(String name) {
    return '$name ကို စီမံခန့်ခွဲသူအသစ် ဖြစ်စေမည်လား?';
  }

  @override
  String get profileTransferAdminBody =>
      'သင့် စီမံခန့်ခွဲသူ အခွင့်အရေးများ ဆုံးရှုံးမည်။ ပြန်ဖျက်လို့မရပါ။';

  @override
  String profileTransferAdminDone(String name) {
    return '$name သည် ယခု စီမံခန့်ခွဲသူ ဖြစ်သွားပြီ';
  }

  @override
  String get profileAdminBadge => 'စီမံခန့်ခွဲသူ';

  @override
  String get privacyPolicyTitle => 'ကိုယ်ရေးလုံခြုံရေး မူဝါဒ';

  @override
  String get privacyOverviewHeading => 'ခြုံငုံသုံးသပ်ချက်';

  @override
  String get privacyOverviewBody =>
      'Pulse သည် ဆာဗာမရှိ၊ အစမှအဆုံးအထိ ကုဒ်ဝှက်ထားသည့် မက်ဆက်ပို့ဆော့ဝ်ဖြစ်သည်။ သင့်ကိုယ်ရေးလုံခြုံရေးသည် လုပ်ဆောင်ချက်တစ်ခုသာမက — ဗိသုကာပင်ဖြစ်သည်။ Pulse ဆာဗာများ မရှိပါ။ အကောင့်များကို မည်သည့်နေရာတွင်မျှ သိမ်းမထားပါ။ ဒေတာကို developer များမှ စုဆောင်း၊ ပို့ဆောင် သို့မဟုတ် သိမ်းဆည်းခြင်း မပြုပါ။';

  @override
  String get privacyDataCollectionHeading => 'ဒေတာစုဆောင်းခြင်း';

  @override
  String get privacyDataCollectionBody =>
      'Pulse သည် ကိုယ်ရေးဒေတာ လုံးဝ မစုဆောင်းပါ။ အထူးသဖြင့်:\n\n- အီးမေးလ်၊ ဖုန်းနံပါတ် သို့မဟုတ် တကယ့်အမည် မလိုအပ်ပါ\n- ခွဲခြမ်းစိတ်ဖြာခြင်း၊ ခြေရာခံခြင်း သို့မဟုတ် telemetry မရှိပါ\n- ကြော်ညာ identifier များ မရှိပါ\n- အဆက်အသွယ်စာရင်း ဝင်ရောက်ခြင်း မရှိပါ\n- cloud အရန်သင် မရှိပါ (မက်ဆက်များသည် သင့်စက်ပစ္စည်းတွင်သာ ရှိသည်)\n- Pulse ဆာဗာမည်သည့်သို့မျှ metadata မပို့ပါ (ဆာဗာများ မရှိပါ)';

  @override
  String get privacyEncryptionHeading => 'ကုဒ်ဝှက်ခြင်း';

  @override
  String get privacyEncryptionBody =>
      'မက်ဆက်အားလုံးကို Signal Protocol (X3DH သော့ချက်သဘောတူညီချက်ဖြင့် Double Ratchet) သုံး၍ ကုဒ်ဝှက်ထားသည်။ ကုဒ်ဝှက်သော့ချက်များကို သင့်စက်ပစ္စည်းတွင်သာ ဖန်တီးပြီး သိမ်းထားသည်။ developer များအပါအဝင် မည်သူမျှ သင့်မက်ဆက်များကို ဖတ်လို့မရပါ။';

  @override
  String get privacyNetworkHeading => 'ကွန်ရက်ဗိသုကာ';

  @override
  String get privacyNetworkBody =>
      'Pulse သည် ဖက်ဒရေးရှင်း ပို့ဆောင်ရေး adapter များ (Nostr relay များ၊ Session/Oxen service node များ၊ Firebase Realtime Database၊ LAN) ကို အသုံးပြုသည်။ ဤပို့ဆောင်ရေးများသည် ကုဒ်ဝှက်ထားသည့် ciphertext ကိုသာ သယ်ဆောင်သည်။ Relay operator များသည် သင့် IP လိပ်စာနှင့် traffic ပမာဏကို မြင်နိုင်သော်လည်း မက်ဆက်အကြောင်းအရာကို ကုဒ်ဖော်လို့မရပါ။\n\nTor ဖွင့်ထားသည့်အခါ သင့် IP လိပ်စာကို relay operator များမှလည်း ဝှက်ထားသည်။';

  @override
  String get privacyStunHeading => 'STUN/TURN ဆာဗာများ';

  @override
  String get privacyStunBody =>
      'အသံနှင့် ဗီဒီယိုဖုန်းခေါ်ဆိုမှုများသည် DTLS-SRTP ကုဒ်ဝှက်ခြင်းဖြင့် WebRTC ကို အသုံးပြုသည်။ STUN ဆာဗာများ (peer-to-peer ချိတ်ဆက်မှုများအတွက် သင့် public IP ကို ရှာဖွေရန်) နှင့် TURN ဆာဗာများ (တိုက်ရိုက်ချိတ်ဆက်မှု မအောင်မြင်သည့်အခါ media relay လုပ်ရန်) သည် သင့် IP လိပ်စာနှင့် ဖုန်းခေါ်ဆိုမှုကြာချိန်ကို မြင်နိုင်သော်လည်း ဖုန်းခေါ်ဆိုမှုအကြောင်းအရာကို ကုဒ်ဖော်လို့မရပါ။\n\nအများဆုံး ကိုယ်ရေးလုံခြုံရေးအတွက် ဆက်တင်များတွင် သင့်ကိုယ်ပိုင် TURN ဆာဗာ ပြင်ဆင်နိုင်သည်။';

  @override
  String get privacyCrashHeading => 'ပျက်ကျမှု အစီရင်ခံခြင်း';

  @override
  String get privacyCrashBody =>
      'Sentry ပျက်ကျမှုအစီရင်ခံကို ဖွင့်ထားလျှင် (build-time SENTRY_DSN မှတစ်ဆင့်) အမည်မသိ ပျက်ကျမှုအစီရင်ခံများ ပို့နိုင်သည်။ ဤအစီရင်ခံများတွင် မက်ဆက်အကြောင်းအရာ၊ အဆက်အသွယ်အချက်အလက် သို့မဟုတ် ကိုယ်ပိုင်သတင်းအချက်အလက် မပါဝင်ပါ။ DSN ကို ချန်ထားခြင်းဖြင့် build time တွင် ပျက်ကျမှုအစီရင်ခံကို ပိတ်နိုင်သည်။';

  @override
  String get privacyPasswordHeading => 'စကားလုံးနှင့် သော့ချက်များ';

  @override
  String get privacyPasswordBody =>
      'သင့်ပြန်ရယူစကားလုံးကို Argon2id (memory-hard KDF) မှတစ်ဆင့် ကုဒ်ဝှက်သော့ချက်များ ထုတ်ယူရန် အသုံးပြုသည်။ စကားလုံးကို မည်သည့်နေရာသို့မျှ မပို့ပါ။ စကားလုံးပျောက်သွားပါက သင့်အကောင့်ကို ပြန်ရယူလို့မရပါ — ပြန်သတ်မှတ်ရန် ဆာဗာမရှိပါ။';

  @override
  String get privacyFontsHeading => 'ဖောင့်များ';

  @override
  String get privacyFontsBody =>
      'Pulse သည် ဖောင့်အားလုံးကို စက်တွင်း ထည့်သွင်းထားသည်။ Google Fonts သို့မဟုတ် ပြင်ပဖောင့်ဝန်ဆောင်မှု မည်သည့်သို့မျှ request မပို့ပါ။';

  @override
  String get privacyThirdPartyHeading => 'ပြင်ပဝန်ဆောင်မှုများ';

  @override
  String get privacyThirdPartyBody =>
      'Pulse သည် ကြော်ညာကွန်ရက်များ၊ ခွဲခြမ်းစိတ်ဖြာသူများ၊ လူမှုမီဒီယာ platform များ သို့မဟုတ် ဒေတာအရောင်းအဝယ်သူများနှင့် ပေါင်းစည်းခြင်း မရှိပါ။ တစ်ခုတည်းသော ကွန်ရက်ချိတ်ဆက်မှုများသည် သင်ပြင်ဆင်ထားသော ပို့ဆောင်ရေး relay များသို့သာ ဖြစ်သည်။';

  @override
  String get privacyOpenSourceHeading => 'Open Source';

  @override
  String get privacyOpenSourceBody =>
      'Pulse သည် open-source ဆော့ဖ်ဝဲ ဖြစ်သည်။ ဤကိုယ်ရေးလုံခြုံရေး ကတိကဝတ်များကို အတည်ပြုရန် source code အပြည့်အစုံကို စစ်ဆေးနိုင်သည်။';

  @override
  String get privacyContactHeading => 'ဆက်သွယ်ရန်';

  @override
  String get privacyContactBody =>
      'ကိုယ်ရေးလုံခြုံရေးဆိုင်ရာ မေးခွန်းများအတွက် project repository တွင် issue ဖွင့်ပါ။';

  @override
  String get privacyLastUpdated => 'နောက်ဆုံး အပ်ဒေတ်: မတ်လ ၂၀၂၆';

  @override
  String imageSaveFailed(Object error) {
    return 'သိမ်းခြင်း မအောင်မြင်ပါ: $error';
  }

  @override
  String get themeEngineTitle => 'အခင်းအနှာ အင်ဂျင်';

  @override
  String get torBuiltInTitle => 'ပါဝင်သော Tor';

  @override
  String get torConnectedSubtitle =>
      'ချိတ်ဆက်ပြီ — Nostr ကို 127.0.0.1:9250 မှတစ်ဆင့် လမ်းကြောင်းသည်';

  @override
  String torConnectingSubtitle(int pct) {
    return 'ချိတ်ဆက်နေသည်… $pct%';
  }

  @override
  String get torNotRunning => 'မလည်ပတ်ပါ — ပြန်စတင်ရန် ခလုတ်နှိပ်ပါ';

  @override
  String get torDescription =>
      'Nostr ကို Tor မှတစ်ဆင့် လမ်းကြောင်းသည် (ဆင်ဆာခံ ကွန်ရက်များအတွက် Snowflake)';

  @override
  String get torNetworkDiagnostics => 'ကွန်ရက်စစ်ဆေးခြင်း';

  @override
  String get torTransportLabel => 'ပို့ဆောင်ရေး: ';

  @override
  String get torPtAuto => 'အလိုအလျောက်';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'ရိုးရိုး';

  @override
  String get torTimeoutLabel => 'အချိန်ကန့်သတ်: ';

  @override
  String get torInfoDescription =>
      'ဖွင့်ထားသည့်အခါ Nostr WebSocket ချိတ်ဆက်မှုများကို Tor (SOCKS5) မှတစ်ဆင့် လမ်းကြောင်းသည်။ Tor Browser သည် 127.0.0.1:9150 တွင် နားထောင်သည်။ standalone tor daemon သည် port 9050 ကို အသုံးပြုသည်။ Firebase ချိတ်ဆက်မှုများကို မထိခိုက်ပါ။';

  @override
  String get torRouteNostrTitle => 'Nostr ကို Tor မှတစ်ဆင့် လမ်းကြောင်း';

  @override
  String get torManagedByBuiltin => 'ပါဝင်သော Tor မှ စီမံသည်';

  @override
  String get torActiveRouting =>
      'အသုံးပြုနေသည် — Nostr လမ်းကြောင်းကို Tor မှတစ်ဆင့် ပို့နေသည်';

  @override
  String get torDisabled => 'ပိတ်ထားသည်';

  @override
  String get torProxySocks5 => 'Tor Proxy (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Proxy Host';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser: port 9150  •  tor daemon: port 9050';

  @override
  String get torForceNostrTitle => 'မက်ဆေ့ချ်များကို Tor မှတဆင့် ပို့ပါ';

  @override
  String get torForceNostrSubtitle =>
      'Nostr relay ချိတ်ဆက်မှုအားလုံး Tor မှတဆင့် သွားပါမည်။ ပိုနှေးသော်လည်း relay များမှ သင်၏ IP ကို ဝှက်ထားသည်။';

  @override
  String get torForceNostrDisabled => 'Tor ကို အရင်ဖွင့်ရန် လိုအပ်သည်';

  @override
  String get torForcePulseTitle => 'Pulse relay ကို Tor မှတဆင့် ချိတ်ဆက်ပါ';

  @override
  String get torForcePulseSubtitle =>
      'Pulse relay ချိတ်ဆက်မှုအားလုံး Tor မှတဆင့် သွားပါမည်။ ပိုနှေးသော်လည်း ဆာဗာမှ သင်၏ IP ကို ဝှက်ထားသည်။';

  @override
  String get torForcePulseDisabled => 'Tor ကို အရင်ဖွင့်ရန် လိုအပ်သည်';

  @override
  String get i2pProxySocks5 => 'I2P Proxy (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P သည် ပုံသေအားဖြင့် port 4447 တွင် SOCKS5 ကို အသုံးပြုသည်။ မည်သည့်ပို့ဆောင်ရေးတွင်မဆို အသုံးပြုသူများနှင့် ဆက်သွယ်ရန် I2P outproxy (ဥပမာ relay.damus.i2p) မှတစ်ဆင့် Nostr relay သို့ ချိတ်ဆက်ပါ။ နှစ်ခုလုံးဖွင့်ထားသည့်အခါ Tor သည် ဦးစားပေးသည်။';

  @override
  String get i2pRouteNostrTitle => 'Nostr ကို I2P မှတစ်ဆင့် လမ်းကြောင်း';

  @override
  String get i2pActiveRouting =>
      'အသုံးပြုနေသည် — Nostr လမ်းကြောင်းကို I2P မှတစ်ဆင့် ပို့နေသည်';

  @override
  String get i2pDisabled => 'ပိတ်ထားသည်';

  @override
  String get i2pProxyHostLabel => 'Proxy Host';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'I2P Router ပုံသေ SOCKS5 port: 4447';

  @override
  String get customProxySocks5 => 'စိတ်ကြိုက် Proxy (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'စိတ်ကြိုက် proxy သည် သင့် V2Ray/Xray/Shadowsocks မှတစ်ဆင့် လမ်းကြောင်းပို့သည်။ CF Worker သည် Cloudflare CDN တွင် ကိုယ်ပိုင် relay proxy အဖြစ် ဆောင်ရွက်သည် — GFW သည် *.workers.dev ကိုသာ မြင်သည်၊ တကယ့် relay ကို မမြင်ပါ။';

  @override
  String get customSocks5ProxyTitle => 'စိတ်ကြိုက် SOCKS5 Proxy';

  @override
  String get customProxyActive =>
      'အသုံးပြုနေသည် — SOCKS5 မှတစ်ဆင့် လမ်းကြောင်းပို့နေသည်';

  @override
  String get customProxyDisabled => 'ပိတ်ထားသည်';

  @override
  String get customProxyHostLabel => 'Proxy Host';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker Domain (ရွေးချယ်ချက်)';

  @override
  String get customWorkerHelpTitle => 'CF Worker relay အခမဲ့ တပ်ဆင်နည်း';

  @override
  String get customWorkerScriptCopied => 'Script ကူးယူပြီ!';

  @override
  String get customWorkerStep1 =>
      '1. dash.cloudflare.com → Workers & Pages သို့ သွားပါ\n2. Worker ဖန်တီး → ဤ script ကို ကူးယူထည့်ပါ:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → domain ကူးယူ (ဥပမာ my-relay.user.workers.dev)\n4. အထက်တွင် domain ကူးယူထည့် → သိမ်း\n\nအပ် အလိုအလျောက်ချိတ်ဆက်: wss://domain/?r=relay_url\nGFW မြင်သည်: *.workers.dev (CF CDN) သို့ ချိတ်ဆက်မှု';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'ချိတ်ဆက်ပြီ — SOCKS5 127.0.0.1:$port တွင်';
  }

  @override
  String get psiphonConnecting => 'ချိတ်ဆက်နေသည်…';

  @override
  String get psiphonNotRunning => 'မလည်ပတ်ပါ — ပြန်စတင်ရန် ခလုတ်နှိပ်ပါ';

  @override
  String get psiphonDescription =>
      'မြန်ဆန်သော tunnel (~3 စက္ကန့် bootstrap၊ VPS 2000+ ခု လှည့်ပတ်)';

  @override
  String get turnCommunityServers => 'အသိုင်းအဝိုင်း TURN ဆာဗာများ';

  @override
  String get turnCustomServer => 'စိတ်ကြိုက် TURN ဆာဗာ (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN ဆာဗာများသည် ကုဒ်ဝှက်ပြီးသား stream များကိုသာ relay လုပ်သည် (DTLS-SRTP)။ relay operator သည် သင့် IP နှင့် traffic ပမာဏကို မြင်နိုင်သော်လည်း ဖုန်းခေါ်ဆိုမှုများကို ကုဒ်ဖော်လို့မရပါ။ TURN သည် P2P တိုက်ရိုက် မအောင်မြင်သည့်အခါမှသာ အသုံးပြုသည် (ချိတ်ဆက်မှု ~15–20%)။';

  @override
  String get turnFreeLabel => 'အခမဲ့';

  @override
  String get turnServerUrlLabel => 'TURN ဆာဗာ URL';

  @override
  String get turnServerUrlHint =>
      'turn:your-server.com:3478 သို့မဟုတ် turns:...';

  @override
  String get turnUsernameLabel => 'အသုံးပြုသူအမည်';

  @override
  String get turnPasswordLabel => 'စကားလုံး';

  @override
  String get turnOptionalHint => 'ရွေးချယ်ချက်';

  @override
  String get turnCustomInfo =>
      'အများဆုံးထိန်းချုပ်မှုအတွက် \$5/လ VPS မည်သည့်တွင်မဆို coturn ကိုယ်တိုင်လှောင်ပါ။ အထောက်အထားများကို စက်တွင်းတွင်သာ သိမ်းထားသည်။';

  @override
  String get themePickerAppearance => 'အသွင်အပြင်';

  @override
  String get themePickerAccentColor => 'အဓိကအရောင်';

  @override
  String get themeModeLight => 'အလင်း';

  @override
  String get themeModeDark => 'အမှောင်';

  @override
  String get themeModeSystem => 'စနစ်';

  @override
  String get themeDynamicPresets => 'ကြိုတင်သတ်မှတ်များ';

  @override
  String get themeDynamicPrimaryColor => 'ပင်မအရောင်';

  @override
  String get themeDynamicBorderRadius => 'ဘောင်အကွေ့';

  @override
  String get themeDynamicFont => 'ဖောင့်';

  @override
  String get themeDynamicAppearance => 'အသွင်အပြင်';

  @override
  String get themeDynamicUiStyle => 'UI ပုံစံ';

  @override
  String get themeDynamicUiStyleDescription =>
      'dialog များ၊ ခလုတ်များနှင့် ညွှန်ပြစက်များ ဘယ်လိုပုံစံ ပြသည်ကို ထိန်းချုပ်သည်။';

  @override
  String get themeDynamicSharp => 'ထောင့်ချွန်';

  @override
  String get themeDynamicRound => 'အဝိုင်း';

  @override
  String get themeDynamicModeDark => 'အမှောင်';

  @override
  String get themeDynamicModeLight => 'အလင်း';

  @override
  String get themeDynamicModeAuto => 'အလိုအလျောက်';

  @override
  String get themeDynamicPlatformAuto => 'အလိုအလျောက်';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'Firebase URL မမှန်ပါ။ https://project.firebaseio.com ဟု မျှော်လင့်ထားသည်';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Relay URL မမှန်ပါ။ wss://relay.example.com ဟု မျှော်လင့်ထားသည်';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Pulse ဆာဗာ URL မမှန်ပါ။ https://server:port ဟု မျှော်လင့်ထားသည်';

  @override
  String get providerPulseServerUrlLabel => 'ဆာဗာ URL';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'ဖိတ်ခေါ်ကုဒ်';

  @override
  String get providerPulseInviteHint => 'ဖိတ်ခေါ်ကုဒ် (လိုအပ်ပါက)';

  @override
  String get providerPulseInfo =>
      'ကိုယ်တိုင်လှောင်ထားသော relay။ သော့ချက်များကို သင့်ပြန်ရယူစကားလုံးမှ ထုတ်ယူသည်။';

  @override
  String get providerScreenTitle => 'ဝင်စာများ';

  @override
  String get providerSecondaryInboxesHeader => 'ဒုတိယ ဝင်စာများ';

  @override
  String get providerSecondaryInboxesInfo =>
      'ဒုတိယ ဝင်စာများသည် ထပ်လောင်းကြံ့ခိုင်မှုအတွက် မက်ဆက်များကို တစ်ပြိုင်နက် လက်ခံသည်။';

  @override
  String get providerRemoveTooltip => 'ဖယ်ရှား';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... သို့မဟုတ် hex';

  @override
  String get providerNostrPrivkeyHintFull =>
      'nsec1... သို့မဟုတ် hex ကိုယ်ပိုင်သော့ချက်';

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
  String get emojiNoRecent => 'မကြာသေးမှီ emoji များ မရှိပါ';

  @override
  String get emojiSearchHint => 'emoji ရှာဖွေ...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'ချက်တင်ရန် နှိပ်ပါ';

  @override
  String get imageViewerSaveToDownloads => 'Downloads သို့ သိမ်း';

  @override
  String imageViewerSavedTo(String path) {
    return '$path သို့ သိမ်းပြီ';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'ဘာသာစကား';

  @override
  String get settingsLanguageSubtitle => 'အပ်ပြသသည့် ဘာသာစကား';

  @override
  String get settingsLanguageSystem => 'စနစ်ပုံသေ';

  @override
  String get onboardingLanguageTitle => 'သင့်ဘာသာစကား ရွေးပါ';

  @override
  String get onboardingLanguageSubtitle =>
      'ဆက်တင်များတွင် နောက်မှ ပြောင်းနိုင်သည်';

  @override
  String get videoNoteRecord => 'ဗီဒီယိုမက်ဆေ့ချ် ရိုက်ကူးရန်';

  @override
  String get videoNoteTapToRecord => 'ရိုက်ကူးရန် တို့ပါ';

  @override
  String get videoNoteTapToStop => 'ရပ်ရန် တို့ပါ';

  @override
  String get videoNoteCameraPermission => 'ကင်မရာ ခွင့်ပြုချက် ငြင်းပယ်ခြင်း';

  @override
  String get videoNoteMaxDuration => 'အများဆုံး ၃၀ စက္ကန့်';

  @override
  String get videoNoteNotSupported =>
      'ဤပလက်ဖောင်းတွင် ဗီဒီယိုမှတ်ချက်များ ပံ့ပိုးမထားပါ';

  @override
  String get navChats => 'ချတ်များ';

  @override
  String get navUpdates => 'မွန်းမံချက်များ';

  @override
  String get navCalls => 'ခေါ်ဆိုမှုများ';

  @override
  String get filterAll => 'အားလုံး';

  @override
  String get filterUnread => 'မဖတ်ရသေး';

  @override
  String get filterGroups => 'အုပ်စုများ';

  @override
  String get callsNoRecent => 'မကြာသေးမီ ခေါ်ဆိုမှု မရှိ';

  @override
  String get callsEmptySubtitle =>
      'သင်၏ ခေါ်ဆိုမှု မှတ်တမ်းသည် ဤနေရာတွင် ပေါ်လာမည်';

  @override
  String get appBarEncrypted => 'အဆုံး-မှ-အဆုံး ကုဒ်ဝှက်';

  @override
  String get newStatus => 'အသစ် အခြေအနေ';

  @override
  String get newCall => 'ခေါ်ဆိုမှု အသစ်';

  @override
  String get joinChannelTitle => 'ချန်နယ်သို့ ပူးပေါင်းပါ';

  @override
  String get joinChannelDescription => 'ချန်နယ် URL';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'ချန်နယ်အချက်အလက် ရယူနေသည်…';

  @override
  String get joinChannelNotFound => 'ဤ URL တွင် ချန်နယ်မတွေ့ပါ';

  @override
  String get joinChannelNetworkError => 'ဆာဗာသို့ ဆက်သွယ်မရပါ';

  @override
  String get joinChannelAlreadyJoined => 'ပူးပေါင်းပြီးသားဖြစ်သည်';

  @override
  String get joinChannelButton => 'ပူးပေါင်းမည်';

  @override
  String get channelFeedEmpty => 'ပို့စ်များ မရှိသေးပါ';

  @override
  String get channelLeave => 'ချန်နယ်မှ ထွက်ခွာမည်';

  @override
  String get channelLeaveConfirm =>
      'ဤချန်နယ်မှ ထွက်ခွာမည်လား? သိမ်းဆည်းထားသော ပို့စ်များ ဖျက်ပစ်မည်။';

  @override
  String get channelInfo => 'ချန်နယ်အချက်အလက်';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'ပြင်ဆင်ပြီး';

  @override
  String get channelLoadMore => 'နောက်ထပ်ဖတ်ရန်';

  @override
  String get channelSearchPosts => 'ပို့စ်များ ရှာပါ…';

  @override
  String get channelNoResults => 'ကိုက်ညီသော ပို့စ်မရှိပါ';

  @override
  String get channelUrl => 'ချန်နယ် URL';

  @override
  String get channelCreated => 'ပါဝင်ပြီး';

  @override
  String channelPostCount(int count) {
    return '$count ပို့စ်';
  }

  @override
  String get channelCopyUrl => 'URL ကူးယူပါ';

  @override
  String get setupNext => 'ရှေ့ဆက်';

  @override
  String get setupKeyWarning =>
      'A recovery key will be generated for you. It is the only way to restore your account on a new device — there is no server, no password reset.';

  @override
  String get setupKeyTitle => 'Your Recovery Key';

  @override
  String get setupKeySubtitle =>
      'Write this key down and store it in a safe place. You will need it to restore your account on a new device.';

  @override
  String get setupKeyCopied => 'ကူးယူပြီး!';

  @override
  String get setupKeyWroteItDown => 'ရေးမှတ်ပြီးပါပြီ';

  @override
  String get setupKeyWarnBody =>
      'Write this key down as a backup. You can also view it later in Settings → Security.';

  @override
  String get setupVerifyTitle => 'Verify Recovery Key';

  @override
  String get setupVerifySubtitle =>
      'Re-enter your recovery key to confirm you saved it correctly.';

  @override
  String get setupVerifyButton => 'အတည်ပြု';

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
  String get settingsViewRecoveryKey => 'ပြန်လည်ရယူရေးသော့ကို ကြည့်ရန်';

  @override
  String get settingsViewRecoveryKeySubtitle =>
      'သင့်အကောင့် ပြန်လည်ရယူရေးသော့ကို ပြသရန်';

  @override
  String get settingsRecoveryKeyNotStored =>
      'ပြန်လည်ရယူရေးသော့ မရနိုင်ပါ (ဤလုပ်ဆောင်ချက်မတိုင်မီ ဖန်တီးခဲ့သည်)';

  @override
  String get settingsRecoveryKeyWarning =>
      'ဤသော့ကို လုံခြုံစွာ သိမ်းဆည်းပါ။ ၎င်းကို ရသူမည်သူမဆို အခြားစက်တွင် သင့်အကောင့်ကို ပြန်လည်ရယူနိုင်ပါသည်။';

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
