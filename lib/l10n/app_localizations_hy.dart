// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Armenian (`hy`).
class AppLocalizationsHy extends AppLocalizations {
  AppLocalizationsHy([String locale = 'hy']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Որոնել հաղորդագրություններ...';

  @override
  String get search => 'Որոնել';

  @override
  String get clearSearch => 'Մաքրել որոնումը';

  @override
  String get closeSearch => 'Փակել որոնումը';

  @override
  String get moreOptions => 'Լրացուցիչ ընդունելիներ';

  @override
  String get back => 'Հետ';

  @override
  String get cancel => 'Չեղարկել';

  @override
  String get close => 'Փակել';

  @override
  String get confirm => 'Հաստատել';

  @override
  String get remove => 'Հեռացնել';

  @override
  String get save => 'Պահել';

  @override
  String get add => 'Ավելացնել';

  @override
  String get copy => 'Պատճենել';

  @override
  String get skip => 'Բաց թողնել';

  @override
  String get done => 'Պատրաստ';

  @override
  String get apply => 'Կիրառել';

  @override
  String get export => 'Արտահանել';

  @override
  String get import => 'Ներմուծել';

  @override
  String get homeNewGroup => 'Նոր խումբ';

  @override
  String get homeSettings => 'Կարգավորումներ';

  @override
  String get homeSearching => 'Հաղորդագրությունների որոնում...';

  @override
  String get homeNoResults => 'Արդյունքներ չեն գտնվել';

  @override
  String get homeNoChatHistory => 'Զրույցների պատմություն դեռ չկա';

  @override
  String homeTransportSwitched(String address) {
    return 'Տրանսպորտը փոխվել է → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$nameը զանգում է...';
  }

  @override
  String get homeAccept => 'Ընդունել';

  @override
  String get homeDecline => 'Մերժել';

  @override
  String get homeLoadEarlier => 'Բեռնել նախորդ հաղորդագրությունները';

  @override
  String get homeChats => 'Զրույցներ';

  @override
  String get homeSelectConversation => 'Ընտրեք զրույց';

  @override
  String get homeNoChatsYet => 'Զրույցներ դեռ չկան';

  @override
  String get homeAddContactToStart =>
      'Ավելացրեք կոնտակտ՝ որպեսզի սկսեք զրույցը';

  @override
  String get homeNewChat => 'Նոր զրույց';

  @override
  String get homeNewChatTooltip => 'Նոր զրույց';

  @override
  String get homeIncomingCallTitle => 'Մուտքային զանգ';

  @override
  String get homeIncomingGroupCallTitle => 'Մուտքային խմբակային զանգ';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — մուտքային խմբակային զանգ';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Զրույցներ չեն գտնվել «$query» հարցմանով';
  }

  @override
  String get homeSectionChats => 'Զրույցներ';

  @override
  String get homeSectionMessages => 'Հաղորդագրություններ';

  @override
  String get homeDbEncryptionUnavailable =>
      'Տվյալների բազայի գաղտնագրումը անհասանելի է — տեղադրեք SQLCipher լիարժեք պաշտպանության համար';

  @override
  String get chatFileTooLargeGroup =>
      '512 ԿԲ-ից մեծ ֆայլերը չեն աջակցվում խմբակային զրույցներում';

  @override
  String get chatLargeFile => 'Մեծ ֆայլ';

  @override
  String get chatCancel => 'Չեղարկել';

  @override
  String get chatSend => 'Ուղարկել';

  @override
  String get chatFileTooLarge => 'Ֆայլը չափ մեծ է — առավելագույնը 100 ՄԲ է';

  @override
  String get chatMicDenied => 'Միկրոֆոնի թույլտվությունը մերժվել է';

  @override
  String get chatVoiceFailed =>
      'Ձայնային հաղորդագրությունը չստացվեց պահել — ստուգեք հասանելի հիշողությունը';

  @override
  String get chatScheduleFuture => 'Պլանավորված ժամանակը պետք է լինի ապագայում';

  @override
  String get chatToday => 'Այսօր';

  @override
  String get chatYesterday => 'Երեկ';

  @override
  String get chatEdited => 'խմբագրված';

  @override
  String get chatYou => 'Դուք';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Այս ֆայլը $size ՄԲ է։ Մեծ ֆայլերի ուղարկումը կարող է դանդաղ լինել որոշ ցանցերում։ Շարունակե՞լ';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return '$nameի անվտանգության բանալիը փոխվել է։ Սեղմեք՝ որպեսզի ստուգեք։';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Հնարավոր չէր գաղտնագրել հաղորդագրությունը $nameին — հաղորդագրությունը չի ուղարկվել։';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Անվտանգության համարը փոխվել է $nameի համար։ Սեղմեք՝ որպեսզի ստուգեք։';
  }

  @override
  String get chatNoMessagesFound => 'Հաղորդագրություններ չեն գտնվել';

  @override
  String get chatMessagesE2ee =>
      'Հաղորդագրությունները ծայրից-ծայր գաղտնագրված են';

  @override
  String get chatSayHello => 'Ասեք բարեւ';

  @override
  String get appBarOnline => 'առցանց';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'գրում է';

  @override
  String get appBarSearchMessages => 'Որոնել հաղորդագրություններ...';

  @override
  String get appBarMute => 'Լռեցնել';

  @override
  String get appBarUnmute => 'Միացնել';

  @override
  String get appBarMedia => 'Մեդիա';

  @override
  String get appBarDisappearing => 'Ինքնավերացող հաղորդագրություններ';

  @override
  String get appBarDisappearingOn => 'Ինքնավերացող՝ միացված';

  @override
  String get appBarGroupSettings => 'Խմբի կարգավորումներ';

  @override
  String get appBarSearchTooltip => 'Որոնել հաղորդագրություններ';

  @override
  String get appBarVoiceCall => 'Ձայնային զանգ';

  @override
  String get appBarVideoCall => 'Տեսազանգ';

  @override
  String get inputMessage => 'Հաղորդագրություն...';

  @override
  String get inputAttachFile => 'Կցել ֆայլ';

  @override
  String get inputSendMessage => 'Ուղարկել հաղորդագրություն';

  @override
  String get inputRecordVoice => 'Ձայնագրել ձայնային հաղորդագրություն';

  @override
  String get inputSendVoice => 'Ուղարկել ձայնային հաղորդագրություն';

  @override
  String get inputCancelReply => 'Չեղարկել պատասխանը';

  @override
  String get inputCancelEdit => 'Չեղարկել խմբագրումը';

  @override
  String get inputCancelRecording => 'Չեղարկել ձայնագրումը';

  @override
  String get inputRecording => 'Ձայնագրում…';

  @override
  String get inputEditingMessage => 'Հաղորդագրության խմբագրում';

  @override
  String get inputPhoto => 'Լուսանկար';

  @override
  String get inputVoiceMessage => 'Ձայնային հաղորդագրություն';

  @override
  String get inputFile => 'Ֆայլ';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count պլանավորված հաղորդագրություն$_temp0';
  }

  @override
  String get callInitializing => 'Զանգի նախապատրաստում…';

  @override
  String get callConnecting => 'Միանում…';

  @override
  String get callConnectingRelay => 'Միանում (ռելե)…';

  @override
  String get callSwitchingRelay => 'Անցում ռելեյի ռեժիմի…';

  @override
  String get callConnectionFailed => 'Միացումը ձախողվեց';

  @override
  String get callReconnecting => 'Վերամիանում…';

  @override
  String get callEnded => 'Զանգը ավարտվեց';

  @override
  String get callLive => 'Ընթացքում';

  @override
  String get callEnd => 'Ավարտ';

  @override
  String get callEndCall => 'Ավարտել զանգը';

  @override
  String get callMute => 'Լռեցնել';

  @override
  String get callUnmute => 'Միացնել';

  @override
  String get callSpeaker => 'Բարձրախոս';

  @override
  String get callCameraOn => 'Տեսախցիկ միացված';

  @override
  String get callCameraOff => 'Տեսախցիկ անջատված';

  @override
  String get callShareScreen => 'Կիսել էկրանը';

  @override
  String get callStopShare => 'Դադարեցնել կիսումը';

  @override
  String callTorBackup(String duration) {
    return 'Tor պահուստ · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor պահուստը ակտիվ է — հիմնական ուղին անհասանելի է';

  @override
  String get callDirectFailed =>
      'Ուղիղ միացումը ձախողվեց — անցում ռելեյի ռեժիմի…';

  @override
  String get callTurnUnreachable =>
      'TURN սերվերները անհասանելի են։ Ավելացրեք հատուկ TURN կարգավորումներում → Ընդլայնված։';

  @override
  String get callRelayMode => 'Ռելեյի ռեժիմը ակտիվ է (սահմանափակ ցանց)';

  @override
  String get callStarting => 'Զանգը սկսվում է…';

  @override
  String get callConnectingToGroup => 'Միանում խմբին…';

  @override
  String get callGroupOpenedInBrowser => 'Խմբակային զանգը բացվեց բրաուզերում';

  @override
  String get callCouldNotOpenBrowser => 'Բրաուզերը չստացվեց բացել';

  @override
  String get callInviteLinkSent =>
      'Հրավերի հղումը ուղարկվեց խմբի բոլոր անդամներին։';

  @override
  String get callOpenLinkManually =>
      'Բացեք վերևի հղումը ձեռքով կամ սեղմեք կրկնելու համար։';

  @override
  String get callJitsiNotE2ee => 'Jitsi զանգերը ծայրից-ծայր գաղտնագրված ՉԵՆ';

  @override
  String get callRetryOpenBrowser => 'Կրկին բացել բրաուզերը';

  @override
  String get callClose => 'Փակել';

  @override
  String get callCamOn => 'Տեսախցիկ միաց';

  @override
  String get callCamOff => 'Տեսախցիկ անջատ';

  @override
  String get noConnection => 'Կապ չկա — հաղորդագրությունները կհերթագրվեն';

  @override
  String get connected => 'Միացված';

  @override
  String get connecting => 'Միանում…';

  @override
  String get disconnected => 'Անջատված';

  @override
  String get offlineBanner =>
      'Կապ չկա — հաղորդագրությունները կուտակվեն և կուղարկվեն վերամիանալուց հետո';

  @override
  String get lanModeBanner => 'LAN ռեժիմ — Ինտերնետ չկա · Միայն տեղական ցանց';

  @override
  String get probeCheckingNetwork => 'Ցանցի կապի ստուգում…';

  @override
  String get probeDiscoveringRelays =>
      'Ռելեների հայտնաբերում համայնքի գրադարաններով…';

  @override
  String get probeStartingTor => 'Torի գործարկում…';

  @override
  String get probeFindingRelaysTor => 'Հասանելի ռելեների որոնում Torով…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'Ցանցը պատրաստ է — $count ռելե$_temp0 գտնվել';
  }

  @override
  String get probeNoRelaysFound =>
      'Հասանելի ռելեներ չեն գտնվել — հաղորդագրությունները կարող են ուշանալ';

  @override
  String get jitsiWarningTitle => 'Չի ծայրից-ծայր գաղտնագրված';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet զանգերը չեն գաղտնագրվում Pulseի կողմից։ Օգտագործեք միայն ոչ գաղտնի զրույցների համար։';

  @override
  String get jitsiConfirm => 'Միանալ ամեն դեպս';

  @override
  String get jitsiGroupWarningTitle => 'Չի ծայրից-ծայր գաղտնագրված';

  @override
  String get jitsiGroupWarningBody =>
      'Այս զանգն ունի չափ շատ մասնակիցներ ներկառուցված գաղտնագրված ցանցի համար։\n\nJitsi Meet հղումը կբացվի ձեր բրաուզերում։ Jitsiն ծայրից-ծայր գաղտնագրված ՉԷ — սերվերը կարող է տեսնել ձեր զանգը։';

  @override
  String get jitsiContinueAnyway => 'Շարունակել ամեն դեպս';

  @override
  String get retry => 'Կրկնել';

  @override
  String get setupCreateAnonymousAccount => 'Ստեղծել անանուն հաշիվ';

  @override
  String get setupTapToChangeColor => 'Սեղմեք գույնը փոխելու համար';

  @override
  String get setupReqMinLength => 'Առնվազն 16 նիշ';

  @override
  String get setupReqVariety =>
      '4-ից 3: մեծատառ, փոքրատառ, թվեր, խորհրդանիշներ';

  @override
  String get setupReqMatch => 'Գաղտնաբառերը համընկնում են';

  @override
  String get setupYourNickname => 'Ձեր մականունը';

  @override
  String get setupRecoveryPassword => 'Վերականգնման գաղտնաբառ (նվազագույնը 16)';

  @override
  String get setupConfirmPassword => 'Հաստատեք գաղտնաբառը';

  @override
  String get setupMin16Chars => 'Նվազագույնը 16 նիշ';

  @override
  String get setupPasswordsDoNotMatch => 'Գաղտնաբառերը չեն համընկնում';

  @override
  String get setupEntropyWeak => 'Թույլ';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Ուժեղ';

  @override
  String get setupEntropyWeakNeedsVariety =>
      'Թույլ (3 նիշերի տեսակ անհրաժեշտ է)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits բիտ)';
  }

  @override
  String get setupPasswordWarning =>
      'Այս գաղտնաբառը ձեր հաշիվը վերականգնելու միակ միջոցն է։ Սերվեր չկա — գաղտնաբառի վերականգնում չկա։ Հիշեք կամ գրեք։';

  @override
  String get setupCreateAccount => 'Ստեղծել հաշիվ';

  @override
  String get setupAlreadyHaveAccount => 'Արդեն ունեք հաշիվ՞ ';

  @override
  String get setupRestore => 'Վերականգնել →';

  @override
  String get restoreTitle => 'Վերականգնել հաշիվը';

  @override
  String get restoreInfoBanner =>
      'Մուտքագրեք վերականգնման գաղտնաբառը — ձեր հասցեը (Nostr + Session) կվերականգնվի ինքնաբերաբար։ Կոնտակտները և հաղորդագրությունները պահվում էին միայն տեղականորեն։';

  @override
  String get restoreNewNickname => 'Նոր մականուն (կարելի է փոխել հետո)';

  @override
  String get restoreButton => 'Վերականգնել հաշիվը';

  @override
  String get lockTitle => 'Pulseը կողպված է';

  @override
  String get lockSubtitle => 'Մուտքագրեք գաղտնաբառը շարունակելու համար';

  @override
  String get lockPasswordHint => 'Գաղտնաբառ';

  @override
  String get lockUnlock => 'Բացել';

  @override
  String get lockPanicHint =>
      'Մոռացե՞լ գաղտնաբառը՞ Մուտքագրեք տագնապահի բանալիը՝ որպեսզի ջնջեք բոլոր տվյալները։';

  @override
  String get lockTooManyAttempts =>
      'Չափ շատ փորձեր։ Բոլոր տվյալները ջնջվում են…';

  @override
  String get lockWrongPassword => 'Սխալ գաղտնաբառ';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Սխալ գաղտնաբառ — $attempts/$max փորձ';
  }

  @override
  String get onboardingSkip => 'Բաց թողնել';

  @override
  String get onboardingNext => 'Հաջորդ';

  @override
  String get onboardingGetStarted => 'Ստեղծել հաշիվ';

  @override
  String get onboardingWelcomeTitle => 'Բարի գալուստ Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Ապակենտրոն մեսենջեր՝ ծայրից-ծայր գաղտնագրմանով։\n\nԿենտրոնացված սերվերներ չկան։ Տվյալների հավաքում չկա։ Հետնադռներ չկան։\nՁեր զրույցները պատկանում են միայն ձեզ։';

  @override
  String get onboardingTransportTitle => 'Տրանսպորտի անկախ';

  @override
  String get onboardingTransportBody =>
      'Օգտագործեք Firebase, Nostr կամ երկուսը միաժամանակ։\n\nՀաղորդագրությունները ինքնաբերաբար ուղղվում են ցանցերով։ Ներկառուցված Tor և I2P աջակցություն գրաքննության դեմ կայունության համար։';

  @override
  String get onboardingSignalTitle => 'Signal + Պոստ-քվանտային';

  @override
  String get onboardingSignalBody =>
      'Երբեք հաղորդագրություն գաղտնագրվում է Signal պրոտոկոլով (Double Ratchet + X3DH)՝ forward secrecyի համար։\n\nԼրացուցիչ պատված Kyber-1024ով — NIST ստանդարտ պոստ-քվանտային ալգորիթմ — պաշտպանություն ապագայի քվանտային համակարգիչներից։';

  @override
  String get onboardingKeysTitle => 'Բանալիները ձերն են';

  @override
  String get onboardingKeysBody =>
      'Ձեր ինքնության բանալիները երբեք չեն լքնում ձեր սարքը։\n\nSignal մատնահետքերը թույլ են տալիս կոնտակտների ստուգումը արտաքին ալիքով։ TOFU (Trust On First Use) ինքնաբերաբար հայտնաբերում է բանալիների փոփոխությունները։';

  @override
  String get onboardingThemeTitle => 'Ընտրեք ձեր ոճը';

  @override
  String get onboardingThemeBody =>
      'Ընտրեք թեմա և շեշտագույն։ Դուք միշտ կարող եք փոխել կարգավորումներում։';

  @override
  String get contactsNewChat => 'Նոր զրույց';

  @override
  String get contactsAddContact => 'Ավելացնել կոնտակտ';

  @override
  String get contactsSearchHint => 'Որոնել...';

  @override
  String get contactsNewGroup => 'Նոր խումբ';

  @override
  String get contactsNoContactsYet => 'Կոնտակտներ դեռ չկան';

  @override
  String get contactsAddHint => 'Սեղմեք +՝ որպեսզի ավելացնեք հասցե';

  @override
  String get contactsNoMatch => 'Կոնտակտներ չեն համընկնում';

  @override
  String get contactsRemoveTitle => 'Հեռացնել կոնտակտը';

  @override
  String contactsRemoveMessage(String name) {
    return 'Հեռացնե՞լ $nameին՞';
  }

  @override
  String get contactsRemove => 'Հեռացնել';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count կոնտակտ$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Բացել հղումը';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Բացե՞լ այս URLը բրաուզերում՞\n\n$url';
  }

  @override
  String get bubbleOpen => 'Բացել';

  @override
  String get bubbleSecurityWarning => 'Անվտանգության զգուշացում';

  @override
  String bubbleExecutableWarning(String name) {
    return '«$name»ը գործարկվող ֆայլի տեսակ է։ Պահելը և գործարկելը կարող է վնասել ձեր սարքին։ Պահե՞լ ամեն դեպս՞';
  }

  @override
  String get bubbleSaveAnyway => 'Պահել ամեն դեպս';

  @override
  String bubbleSavedTo(String path) {
    return 'Պահվել է՝ $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Պահման սխալ՝ $error';
  }

  @override
  String get bubbleNotEncrypted => 'ԳԱՂՏՆԱԳՌՎԱԾ ՉԷ';

  @override
  String get bubbleCorruptedImage => '[Վնասված նկար]';

  @override
  String get bubbleReplyPhoto => 'Լուսանկար';

  @override
  String get bubbleReplyVoice => 'Ձայնային հաղորդագրություն';

  @override
  String get bubbleReplyVideo => 'Տեսահաղորդագրություն';

  @override
  String bubbleReadBy(String names) {
    return 'Կարդացել է՝ $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Կարդացել է՝ $count';
  }

  @override
  String get chatTileTapToStart => 'Սեղմեք՝ որպեսզի սկսեք զրույցը';

  @override
  String get chatTileMessageSent => 'Հաղորդագրությունը ուղարկվեց';

  @override
  String get chatTileEncryptedMessage => 'Գաղտնագրված հաղորդագրություն';

  @override
  String chatTileYouPrefix(String text) {
    return 'Դուք՝ $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Ձայնային հաղորդագրություն';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Ձայնային հաղորդագրություն ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Գաղտնագրված հաղորդագրություն';

  @override
  String get groupNewGroup => 'Նոր խումբ';

  @override
  String get groupGroupName => 'Խմբի անունը';

  @override
  String get groupSelectMembers => 'Ընտրեք անդամներ (նվազագույնը 2)';

  @override
  String get groupNoContactsYet =>
      'Կոնտակտներ դեռ չկան։ Նախ ավելացրեք կոնտակտներ։';

  @override
  String get groupCreate => 'Ստեղծել';

  @override
  String get groupLabel => 'Խումբ';

  @override
  String get profileVerifyIdentity => 'Ստուգել ինքնությունը';

  @override
  String profileVerifyInstructions(String name) {
    return 'Համեմատեք այս մատնահետքերը $nameի հետ ձայնային զանգով կամ անձամբ։ Եթե երկու արժեքները համընկնում են երկու սարքերում՝ սեղմեք «Նշել որպես ստուգված»։';
  }

  @override
  String get profileTheirKey => 'Նրանց բանալիը';

  @override
  String get profileYourKey => 'Ձեր բանալիը';

  @override
  String get profileRemoveVerification => 'Հեռացնել ստուգումը';

  @override
  String get profileMarkAsVerified => 'Նշել որպես ստուգված';

  @override
  String get profileAddressCopied => 'Հասցեը պատճենվեց';

  @override
  String get profileNoContactsToAdd =>
      'Ավելացնելու կոնտակտներ չկան — բոլորն արդեն անդամ են';

  @override
  String get profileAddMembers => 'Ավելացնել անդամներ';

  @override
  String profileAddCount(int count) {
    return 'Ավելացնել ($count)';
  }

  @override
  String get profileRenameGroup => 'Վերանվանել խումբը';

  @override
  String get profileRename => 'Վերանվանել';

  @override
  String get profileRemoveMember => 'Հեռացնե՞լ անդամին՞';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Հեռացնե՞լ $nameին այս խմբից՞';
  }

  @override
  String get profileKick => 'Հեռացնել';

  @override
  String get profileSignalFingerprints => 'Signal մատնահետքեր';

  @override
  String get profileVerified => 'ՍՏՈՈԳՎԱԾ';

  @override
  String get profileVerify => 'Ստուգել';

  @override
  String get profileEdit => 'Խմբագրել';

  @override
  String get profileNoSession =>
      'Նստաշը դեռ հաստատված չէ — նախ ուղարկեք հաղորդագրություն։';

  @override
  String get profileFingerprintCopied => 'Մատնահետքը պատճենվեց';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count անդամ$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Ստուգել անվտանգության համարը';

  @override
  String get profileShowContactQr => 'Ցույց տալ կոնտակտի QRը';

  @override
  String profileContactAddress(String name) {
    return '$nameի հասցեը';
  }

  @override
  String get profileExportChatHistory => 'Արտահանել զրույցի պատմությունը';

  @override
  String profileSavedTo(String path) {
    return 'Պահվել է՝ $path';
  }

  @override
  String get profileExportFailed => 'Արտահանումը ձախողվեց';

  @override
  String get profileClearChatHistory => 'Մաքրել զրույցի պատմությունը';

  @override
  String get profileDeleteGroup => 'Ջնջել խումբը';

  @override
  String get profileDeleteContact => 'Ջնջել կոնտակտը';

  @override
  String get profileLeaveGroup => 'Լքել խումբը';

  @override
  String get profileLeaveGroupBody =>
      'Դուք կհեռացվեք այս խմբից և այն կջնջվի ձեր կոնտակտներից։';

  @override
  String get groupInviteTitle => 'Խմբի հրավեր';

  @override
  String groupInviteBody(String from, String group) {
    return '$fromը ձեզ հրավիրեց միանալ «$group» խմբին';
  }

  @override
  String get groupInviteAccept => 'Ընդունել';

  @override
  String get groupInviteDecline => 'Մերժել';

  @override
  String get groupMemberLimitTitle => 'Չափ շատ մասնակիցներ';

  @override
  String groupMemberLimitBody(int count) {
    return 'Այս խումբը կունենա $count մասնակից։ Գաղտնագրված ցանցային զանգերը աջակցում են մինչև 6։ Ավելի մեծ խմբերն անցնում են Jitsiի (ոչ E2EE)։';
  }

  @override
  String get groupMemberLimitContinue => 'Ավելացնել ամեն դեպս';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$nameը մերժեց միանալ «$group» խմբին';
  }

  @override
  String get transferTitle => 'Փոխանցել այլ սարքի';

  @override
  String get transferInfoBox =>
      'Տեղափոխեք ձեր Signal ինքնությունը և Nostr բանալիները նոր սարք։\nԶրույցի նստաշները ՉԵՆ փոխանցվում — forward secrecyն պահպանվում է։';

  @override
  String get transferSendFromThis => 'Ուղարկել այս սարքից';

  @override
  String get transferSendSubtitle =>
      'Այս սարքը պարունակում է բանալիները։ Կիսեք կոդը նոր սարքի հետ։';

  @override
  String get transferReceiveOnThis => 'Ստանալ այս սարքում';

  @override
  String get transferReceiveSubtitle =>
      'Սա նոր սարքն է։ Մուտքագրեք կոդը հին սարքից։';

  @override
  String get transferChooseMethod => 'Ընտրեք փոխանցման եղանակը';

  @override
  String get transferLan => 'LAN (նույն ցանց)';

  @override
  String get transferLanSubtitle =>
      'Արագ՝ ուղիղ։ Երկու սարքերը պետք է լինեն նույն Wi-Fiում։';

  @override
  String get transferNostrRelay => 'Nostr ռելե';

  @override
  String get transferNostrRelaySubtitle =>
      'Աշխատում է ցանկացած ցանցով՝ գոյություն ունեցող Nostr ռելեի միջոցով։';

  @override
  String get transferRelayUrl => 'Ռելեյի URL';

  @override
  String get transferEnterCode => 'Մուտքագրեք փոխանցման կոդը';

  @override
  String get transferPasteCode => 'Տեղադրեք LAN:... կամ NOS:... կոդը այստեղ';

  @override
  String get transferConnect => 'Միանալ';

  @override
  String get transferGenerating => 'Փոխանցման կոդի ստեղում…';

  @override
  String get transferShareCode => 'Կիսեք այս կոդը ստացողին՝';

  @override
  String get transferCopyCode => 'Պատճենել կոդը';

  @override
  String get transferCodeCopied => 'Կոդը պատճենվեց սեղմատախտակին';

  @override
  String get transferWaitingReceiver => 'Սպասում ստացողի միացմանը…';

  @override
  String get transferConnectingSender => 'Միանում ուղարկողին…';

  @override
  String get transferVerifyBoth =>
      'Համեմատեք այս կոդը երկու սարքերում։\nԵթե համընկնում են՝ փոխանցումը ապահով է։';

  @override
  String get transferComplete => 'Փոխանցումը ավարտվեց';

  @override
  String get transferKeysImported => 'Բանալիները ներմուծվեցին';

  @override
  String get transferCompleteSenderBody =>
      'Ձեր բանալիները մնում են ակտիվ այս սարքում։\nՍտացողն այժմ կարող է օգտագործել ձեր ինքնությունը։';

  @override
  String get transferCompleteReceiverBody =>
      'Բանալիները հաջողությամբ ներմուծվեցին։\nՎերագործարկեք հավելվածը՝ նոր ինքնությունը կիրառելու համար։';

  @override
  String get transferRestartApp => 'Վերագործարկել հավելվածը';

  @override
  String get transferFailed => 'Փոխանցումը ձախողվեց';

  @override
  String get transferTryAgain => 'Կրկնել';

  @override
  String get transferEnterRelayFirst => 'Նախ մուտքագրեք ռելեյի URLը';

  @override
  String get transferPasteCodeFromSender =>
      'Տեղադրեք փոխանցման կոդը ուղարկողից';

  @override
  String get menuReply => 'Պատասխանել';

  @override
  String get menuForward => 'Վերաուղղել';

  @override
  String get menuReact => 'Ռեակցիա';

  @override
  String get menuCopy => 'Պատճենել';

  @override
  String get menuEdit => 'Խմբագրել';

  @override
  String get menuRetry => 'Կրկնել';

  @override
  String get menuCancelScheduled => 'Չեղարկել պլանավորվածը';

  @override
  String get menuDelete => 'Ջնջել';

  @override
  String get menuForwardTo => 'Վերաուղղել…';

  @override
  String menuForwardedTo(String name) {
    return 'Վերաուղղվեց $nameին';
  }

  @override
  String get menuScheduledMessages => 'Պլանավորված հաղորդագրություններ';

  @override
  String get menuNoScheduledMessages => 'Պլանավորված հաղորդագրություններ չկան';

  @override
  String menuSendsOn(String date) {
    return 'Կուղարկվի՝ $date';
  }

  @override
  String get menuDisappearingMessages => 'Ինքնավերացող հաղորդագրություններ';

  @override
  String get menuDisappearingSubtitle =>
      'Հաղորդագրությունները ինքնաբերաբար ջնջվում են ընտրված ժամանակից հետո։';

  @override
  String get menuTtlOff => 'Անջատված';

  @override
  String get menuTtl1h => '1 ժամ';

  @override
  String get menuTtl24h => '24 ժամ';

  @override
  String get menuTtl7d => '7 օր';

  @override
  String get menuAttachPhoto => 'Լուսանկար';

  @override
  String get menuAttachFile => 'Ֆայլ';

  @override
  String get menuAttachVideo => 'Տեսանյութ';

  @override
  String get mediaTitle => 'Մեդիա';

  @override
  String get mediaFileLabel => 'ՖԱՅԼ';

  @override
  String mediaPhotosTab(int count) {
    return 'Լուսանկարներ ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Ֆայլեր ($count)';
  }

  @override
  String get mediaNoPhotos => 'Լուսանկարներ դեռ չկան';

  @override
  String get mediaNoFiles => 'Ֆայլեր դեռ չկան';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Պահվել է Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'Ֆայլի պահմանը ձախողվեց';

  @override
  String get statusNewStatus => 'Նոր կարգավիճակ';

  @override
  String get statusPublish => 'Հրապարակել';

  @override
  String get statusExpiresIn24h => 'Կարգավիճակը գործում է 24 ժամ';

  @override
  String get statusWhatsOnYourMind => 'Ինչ՞ եք մտածում՞';

  @override
  String get statusPhotoAttached => 'Լուսանկարը կցված է';

  @override
  String get statusAttachPhoto => 'Կցել լուսանկար (կամընտրական)';

  @override
  String get statusEnterText =>
      'Խնդրում ենք՝ մուտքագրեք տեքստ ձեր կարգավիճակի համար։';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Լուսանկարի ընտրումը ձախողվեց՝ $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Հրապարակումը ձախողվեց՝ $error';
  }

  @override
  String get panicSetPanicKey => 'Սահմանել տագնապահի բանալի';

  @override
  String get panicEmergencySelfDestruct => 'Արտակարգ ինքնաոչնչացում';

  @override
  String get panicIrreversible => 'Այս գործողությունը անդառելի է';

  @override
  String get panicWarningBody =>
      'Այս բանալին մուտքագրելով կողպման էկրանին անհապաղ կջնջվում է ԲՈԼՈՌ տվյալները — հաղորդագրություններ՝ կոնտակտներ՝ բանալիներ՝ ինքնություն։ Օգտագործեք սովորական գաղտնաբառից տարբեր բանալի։';

  @override
  String get panicKeyHint => 'Տագնապահի բանալի';

  @override
  String get panicConfirmHint => 'Հաստատեք տագնապահի բանալիը';

  @override
  String get panicMinChars => 'Տագնապահի բանալիը պետք է լինի առնվազնը 8 նիշ';

  @override
  String get panicKeysDoNotMatch => 'Բանալիները չեն համընկնում';

  @override
  String get panicSetFailed =>
      'Տագնապահի բանալին չստացվեց պահել — խնդրում ենք՝ փորձեք կրկին';

  @override
  String get passwordSetAppPassword => 'Սահմանել հավելվածի գաղտնաբառ';

  @override
  String get passwordProtectsMessages =>
      'Պաշտպանում է ձեր հաղորդագրությունները պահման վիճակում';

  @override
  String get passwordInfoBanner =>
      'Պահանջվում է ամեն անգամ՝ երբ բացում եք Pulseը։ Եթե մոռանաք՝ ձեր տվյալները հնարավոր չէ վերականգնել։';

  @override
  String get passwordHint => 'Գաղտնաբառ';

  @override
  String get passwordConfirmHint => 'Հաստատեք գաղտնաբառը';

  @override
  String get passwordSetButton => 'Սահմանել գաղտնաբառ';

  @override
  String get passwordSkipForNow => 'Բաց թողնել առայժմ';

  @override
  String get passwordMinChars => 'Գաղտնաբառը պետք է լինի առնվազնը 8 նիշ';

  @override
  String get passwordNeedsVariety => 'Պետք է ներառի տառեր, թվեր և հատուկ նիշեր';

  @override
  String get passwordRequirements =>
      'Նվազ. 8 նիշ տառերով, թվերով և հատուկ նիշով';

  @override
  String get passwordsDoNotMatch => 'Գաղտնաբառերը չեն համընկնում';

  @override
  String get profileCardSaved => 'Պրոֆիլը պահվեց։';

  @override
  String get profileCardE2eeIdentity => 'E2EE ինքնություն';

  @override
  String get profileCardDisplayName => 'Ցուցադրվող անուն';

  @override
  String get profileCardDisplayNameHint => 'օրինակ՝ Ալեք Սարգսյան';

  @override
  String get profileCardAbout => 'Մասին';

  @override
  String get profileCardSaveProfile => 'Պահել պրոֆիլը';

  @override
  String get profileCardYourName => 'Ձեր անունը';

  @override
  String get profileCardAddressCopied => 'Հասցեը պատճենվեց։';

  @override
  String get profileCardInboxAddress => 'Ձեր մուտքային հասցեը';

  @override
  String get profileCardInboxAddresses => 'Ձեր մուտքային հասցեները';

  @override
  String get profileCardShareAllAddresses =>
      'Կիսել բոլոր հասցեները (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Կիսեք կոնտակտների հետ՝ որպեսզի նրանք կարողանան ձեզ գրել։';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Բոլոր $count հասցեները պատճենվեցին մեկ հղումով։';
  }

  @override
  String get settingsMyProfile => 'Իմ պրոֆիլը';

  @override
  String get settingsYourInboxAddress => 'Ձեր մուտքային հասցեը';

  @override
  String get settingsMyQrCode => 'Կիսել կոնտակտը';

  @override
  String get settingsMyQrSubtitle => 'QR կոդ և հրավերի հղում ձեր հասցեի համար';

  @override
  String get settingsShareMyAddress => 'Կիսել իմ հասցեը';

  @override
  String get settingsNoAddressYet =>
      'Հասցե դեռ չկա — նախ պահեք կարգավորումները';

  @override
  String get settingsInviteLink => 'Հրավերի հղում';

  @override
  String get settingsRawAddress => 'Հասցե';

  @override
  String get settingsCopyLink => 'Պատճենել հղումը';

  @override
  String get settingsCopyAddress => 'Պատճենել հասցեը';

  @override
  String get settingsInviteLinkCopied => 'Հրավերի հղումը պատճենվեց';

  @override
  String get settingsAppearance => 'Տեսք';

  @override
  String get settingsThemeEngine => 'Թեմայի շարժիչ';

  @override
  String get settingsThemeEngineSubtitle => 'Հարմարեք գույները և տառատեսակները';

  @override
  String get settingsSignalProtocol => 'Signal պրոտոկոլ';

  @override
  String get settingsSignalProtocolSubtitle =>
      'E2EE բանալիները ապահով պահված են';

  @override
  String get settingsActive => 'ԱԿՏԻՎ';

  @override
  String get settingsIdentityBackup => 'Ինքնության պահուստ';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Արտահանել կամ ներմուծել ձեր Signal ինքնությունը';

  @override
  String get settingsIdentityBackupBody =>
      'Արտահանեք ձեր Signal ինքնության բանալիները պահուստային կոդի մեջ կամ վերականգնեք գոյություն ունեցողից։';

  @override
  String get settingsTransferDevice => 'Փոխանցել այլ սարքի';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Տեղափոխեք ինքնությունը LANով կամ Nostr ռելեով';

  @override
  String get settingsExportIdentity => 'Արտահանել ինքնությունը';

  @override
  String get settingsExportIdentityBody =>
      'Պատճենեք այս պահուստային կոդը և պահեք ապահով՝';

  @override
  String get settingsSaveFile => 'Պահել ֆայլը';

  @override
  String get settingsImportIdentity => 'Ներմուծել ինքնությունը';

  @override
  String get settingsImportIdentityBody =>
      'Տեղադրեք պահուստային կոդը ներքևում։ Սա կփոխարինի ձեր ընթացիկ ինքնությունը։';

  @override
  String get settingsPasteBackupCode => 'Տեղադրեք պահուստային կոդը այստեղ…';

  @override
  String get settingsIdentityImported =>
      'Ինքնությունը + կոնտակտները ներմուծվեցին։ Վերագործարկեք հավելվածը կիրառելու համար։';

  @override
  String get settingsSecurity => 'Անվտանգություն';

  @override
  String get settingsAppPassword => 'Հավելվածի գաղտնաբառ';

  @override
  String get settingsPasswordEnabled =>
      'Միացված — պահանջվում է ամեն գործարկման ժամանակ';

  @override
  String get settingsPasswordDisabled =>
      'Անջատված — հավելվածը բացվում է առանց գաղտնաբառի';

  @override
  String get settingsChangePassword => 'Փոխել գաղտնաբառը';

  @override
  String get settingsChangePasswordSubtitle =>
      'Թարմացնել հավելվածի կողպման գաղտնաբառը';

  @override
  String get settingsSetPanicKey => 'Սահմանել տագնապահի բանալի';

  @override
  String get settingsChangePanicKey => 'Փոխել տագնապահի բանալիը';

  @override
  String get settingsPanicKeySetSubtitle => 'Թարմացնել արտակարգ ջնջման բանալիը';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Մեկ բանալի՝ որը անհապաղ ջնջում է բոլոր տվյալները';

  @override
  String get settingsRemovePanicKey => 'Հեռացնել տագնապահի բանալիը';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Անջատել արտակարգ ինքնաոչնչացումը';

  @override
  String get settingsRemovePanicKeyBody =>
      'Արտակարգ ինքնաոչնչացումը կանջատվի։ Դուք կարող եք նորից միացնել ցանկացած պահին։';

  @override
  String get settingsDisableAppPassword => 'Անջատել հավելվածի գաղտնաբառը';

  @override
  String get settingsEnterCurrentPassword =>
      'Մուտքագրեք ընթացիկ գաղտնաբառը հաստատելու համար';

  @override
  String get settingsCurrentPassword => 'Ընթացիկ գաղտնաբառ';

  @override
  String get settingsIncorrectPassword => 'Սխալ գաղտնաբառ';

  @override
  String get settingsPasswordUpdated => 'Գաղտնաբառը թարմացվեց';

  @override
  String get settingsChangePasswordProceed =>
      'Մուտքագրեք ընթացիկ գաղտնաբառը շարունակելու համար';

  @override
  String get settingsData => 'Տվյալներ';

  @override
  String get settingsBackupMessages => 'Պահուստավորել հաղորդագրությունները';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Արտահանել գաղտնագրված հաղորդագրությունների պատմությունը ֆայլ';

  @override
  String get settingsRestoreMessages => 'Վերականգնել հաղորդագրությունները';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Ներմուծել հաղորդագրությունները պահուստային ֆայլից';

  @override
  String get settingsExportKeys => 'Արտահանել բանալիները';

  @override
  String get settingsExportKeysSubtitle =>
      'Պահել ինքնության բանալիները գաղտնագրված ֆայլի մեջ';

  @override
  String get settingsImportKeys => 'Ներմուծել բանալիները';

  @override
  String get settingsImportKeysSubtitle =>
      'Վերականգնել ինքնության բանալիները արտահանված ֆայլից';

  @override
  String get settingsBackupPassword => 'Պահուստի գաղտնաբառ';

  @override
  String get settingsPasswordCannotBeEmpty =>
      'Գաղտնաբառը չի կարող դատարկ լինել';

  @override
  String get settingsPasswordMin4Chars =>
      'Գաղտնաբառը պետք է լինի առնվազնը 4 նիշ';

  @override
  String get settingsCallsTurn => 'Զանգեր և TURN';

  @override
  String get settingsLocalNetwork => 'Տեղական ցանց';

  @override
  String get settingsCensorshipResistance => 'Գրաքննության դիմակայունություն';

  @override
  String get settingsNetwork => 'Ցանց';

  @override
  String get settingsProxyTunnels => 'Պրոքսի և թունելներ';

  @override
  String get settingsTurnServers => 'TURN սերվերներ';

  @override
  String get settingsProviderTitle => 'Մատակարար';

  @override
  String get settingsLanFallback => 'LAN պահուստ';

  @override
  String get settingsLanFallbackSubtitle =>
      'Հեռարձակել ներկայությունը և հաղորդագրությունները առաքել տեղական ցանցով՝ երբ ինտերնետը անհասանելի է։ Անջատեք անվստահ ցանցերում (հանրային Wi-Fi)։';

  @override
  String get settingsBgDelivery => 'Հետնապլանային առաքում';

  @override
  String get settingsBgDeliverySubtitle =>
      'Շարունակել հաղորդագրություններ ստանալ՝ երբ հավելվածը թաքնված է։ Ցույց է տալիս մշտական ծանուցում։';

  @override
  String get settingsYourInboxProvider => 'Ձեր մուտքային մատակարարը';

  @override
  String get settingsConnectionDetails => 'Միացման մանրամասներ';

  @override
  String get settingsSaveAndConnect => 'Պահել և միանալ';

  @override
  String get settingsSecondaryInboxes => 'Երկրորդական մուտքարկղեր';

  @override
  String get settingsAddSecondaryInbox => 'Ավելացնել երկրորդական մուտքարկղ';

  @override
  String get settingsAdvanced => 'Ընդլայնված';

  @override
  String get settingsDiscover => 'Հայտնաբերել';

  @override
  String get settingsAbout => 'Հավելվածի մասին';

  @override
  String get settingsPrivacyPolicy => 'Գաղտնիության քաղաքականություն';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Ինչպես է Pulseը պաշտպանում ձեր տվյալները';

  @override
  String get settingsCrashReporting => 'Սխալների հաշվետվություն';

  @override
  String get settingsCrashReportingSubtitle =>
      'Ուղարկել անանուն սխալների հաշվետվություններ՝ Pulseը բարելավելու համար։ Հաղորդագրությունների բովանդակությունը կամ կոնտակտները երբեք չեն ուղարկվում։';

  @override
  String get settingsCrashReportingEnabled =>
      'Սխալների հաշվետվությունը միացված է — վերագործարկեք հավելվածը';

  @override
  String get settingsCrashReportingDisabled =>
      'Սխալների հաշվետվությունը անջատված է — վերագործարկեք հավելվածը';

  @override
  String get settingsSensitiveOperation => 'Զգայուն գործողություն';

  @override
  String get settingsSensitiveOperationBody =>
      'Այս բանալիները ձեր ինքնությունն են։ Այս ֆայլը ունեցող ցանկացած անձ կարող է ներկայանալ ձեզ։ Պահեք ապահով և փոխանցմանից հետո ջնջեք։';

  @override
  String get settingsIUnderstandContinue => 'Հասկանում եմ՝ շարունակել';

  @override
  String get settingsReplaceIdentity => 'Փոխարինե՞լ ինքնությունը՞';

  @override
  String get settingsReplaceIdentityBody =>
      'Սա կփոխարինի ձեր ընթացիկ ինքնության բանալիները։ Ձեր գոյություն ունեցող Signal նստաշները կանվավերացվեն և կոնտակտները պետք է նորից հաստատեն գաղտնագրումը։ Հավելվածը պետք է վերագործարկվի։';

  @override
  String get settingsReplaceKeys => 'Փոխարինել բանալիները';

  @override
  String get settingsKeysImported => 'Բանալիները ներմուծվեցին';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count բանալի հաջողությամբ ներմուծվեց։ Խնդրում ենք՝ վերագործարկեք հավելվածը՝ նոր ինքնությամբ սկսելու համար։';
  }

  @override
  String get settingsRestartNow => 'Վերագործարկել հիմա';

  @override
  String get settingsLater => 'Հետո';

  @override
  String get profileGroupLabel => 'Խումբ';

  @override
  String get profileAddButton => 'Ավելացնել';

  @override
  String get profileKickButton => 'Հեռացնել';

  @override
  String get dataSectionTitle => 'Տվյալներ';

  @override
  String get dataBackupMessages => 'Պահուստավորել հաղորդագրությունները';

  @override
  String get dataBackupPasswordSubtitle =>
      'Ընտրեք գաղտնաբառ՝ հաղորդագրությունների պահուստը գաղտնագրելու համար։';

  @override
  String get dataBackupConfirmLabel => 'Ստեղծել պահուստ';

  @override
  String get dataCreatingBackup => 'Պահուստի ստեղում';

  @override
  String get dataBackupPreparing => 'Պատրաստվում...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Արտահանում հաղորդագրություն $done / $total...';
  }

  @override
  String get dataBackupSavingFile => 'Ֆայլի պահում...';

  @override
  String get dataSaveMessageBackupDialog =>
      'Պահել հաղորդագրությունների պահուստը';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Պահուստը պահվեց ($count հաղորդագրություն)\n$path';
  }

  @override
  String get dataBackupFailed => 'Պահուստը ձախողվեց — տվյալներ չեն արտահանվել';

  @override
  String dataBackupFailedError(String error) {
    return 'Պահուստը ձախողվեց՝ $error';
  }

  @override
  String get dataSelectMessageBackupDialog =>
      'Ընտրեք հաղորդագրությունների պահուստ';

  @override
  String get dataInvalidBackupFile => 'Անվավեր պահուստային ֆայլ (չափ փոքր է)';

  @override
  String get dataNotValidBackupFile => 'Սա վավեր Pulse պահուստային ֆայլ չէ';

  @override
  String get dataRestoreMessages => 'Վերականգնել հաղորդագրությունները';

  @override
  String get dataRestorePasswordSubtitle =>
      'Մուտքագրեք գաղտնաբառը՝ որով ստեղծվել էր այս պահուստը։';

  @override
  String get dataRestoreConfirmLabel => 'Վերականգնել';

  @override
  String get dataRestoringMessages => 'Հաղորդագրությունների վերականգնում';

  @override
  String get dataRestoreDecrypting => 'Վերծակավորում...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Ներմուծում հաղորդագրություն $done / $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Վերականգնումը ձախողվեց — սխալ գաղտնաբառ կամ վնասված ֆայլ';

  @override
  String dataRestoreSuccess(int count) {
    return 'Վերականգնվեց $count նոր հաղորդագրություն';
  }

  @override
  String get dataRestoreNothingNew =>
      'Նոր հաղորդագրություններ ներմուծելու չկան (բոլորն արդեն գոյություն ունեն)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Վերականգնումը ձախողվեց՝ $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Ընտրեք բանալիների արտահանում';

  @override
  String get dataNotValidKeyFile =>
      'Սա վավեր Pulse բանալիների արտահանման ֆայլ չէ';

  @override
  String get dataExportKeys => 'Արտահանել բանալիները';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Ընտրեք գաղտնաբառ՝ բանալիների արտահանումը գաղտնագրելու համար։';

  @override
  String get dataExportKeysConfirmLabel => 'Արտահանել';

  @override
  String get dataExportingKeys => 'Բանալիների արտահանում';

  @override
  String get dataExportingKeysStatus => 'Ինքնության բանալիների գաղտնագրում...';

  @override
  String get dataSaveKeyExportDialog => 'Պահել բանալիների արտահանումը';

  @override
  String dataKeysExportedTo(String path) {
    return 'Բանալիները արտահանվեց՝\n$path';
  }

  @override
  String get dataExportFailed => 'Արտահանումը ձախողվեց — բանալիներ չեն գտնվել';

  @override
  String dataExportFailedError(String error) {
    return 'Արտահանումը ձախողվեց՝ $error';
  }

  @override
  String get dataImportKeys => 'Ներմուծել բանալիները';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Մուտքագրեք գաղտնաբառը՝ որով գաղտնագրվել էր բանալիների արտահանումը։';

  @override
  String get dataImportKeysConfirmLabel => 'Ներմուծել';

  @override
  String get dataImportingKeys => 'Բանալիների ներմուծում';

  @override
  String get dataImportingKeysStatus =>
      'Ինքնության բանալիների վերծակավորում...';

  @override
  String get dataImportFailed =>
      'Ներմուծումը ձախողվեց — սխալ գաղտնաբառ կամ վնասված ֆայլ';

  @override
  String dataImportFailedError(String error) {
    return 'Ներմուծումը ձախողվեց՝ $error';
  }

  @override
  String get securitySectionTitle => 'Անվտանգություն';

  @override
  String get securityIncorrectPassword => 'Սխալ գաղտնաբառ';

  @override
  String get securityPasswordUpdated => 'Գաղտնաբառը թարմացվեց';

  @override
  String get appearanceSectionTitle => 'Տեսք';

  @override
  String appearanceExportFailed(String error) {
    return 'Արտահանումը ձախողվեց՝ $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Պահվել է՝ $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Պահմանը ձախողվեց՝ $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Ներմուծումը ձախողվեց՝ $error';
  }

  @override
  String get aboutSectionTitle => 'Հավելվածի մասին';

  @override
  String get providerPublicKey => 'Հանրային բանալի';

  @override
  String get providerRelay => 'Ռելե';

  @override
  String get providerAutoConfigured =>
      'Ինքնաբերաբար կարգավորված ձեր վերականգնման գաղտնաբառից։ Ռելեն ինքնաբերաբար հայտնաբերված։';

  @override
  String get providerKeyStoredLocally =>
      'Ձեր բանալիը պահվում է տեղականորեն ապահով պահոցում — երբեք չի ուղարկվում սերվերի։';

  @override
  String get providerSessionInfo =>
      'Session Network — սոխ-երթուղիչ E2EE: Ձեր Session ID-ն ավտոմատ կերպով ստեղծվում և ապահով կերպով պահվում է: Հանգույցներն ավտոմատ կերպով հայտնաբերվում են ներկառուցված seed հանգույցներից:';

  @override
  String get providerAdvanced => 'Ընդլայնված';

  @override
  String get providerSaveAndConnect => 'Պահել և միանալ';

  @override
  String get providerAddSecondaryInbox => 'Ավելացնել երկրորդական մուտքարկղ';

  @override
  String get providerSecondaryInboxes => 'Երկրորդական մուտքարկղեր';

  @override
  String get providerYourInboxProvider => 'Ձեր մուտքային մատակարարը';

  @override
  String get providerConnectionDetails => 'Միացման մանրամասներ';

  @override
  String get addContactTitle => 'Ավելացնել կոնտակտ';

  @override
  String get addContactInviteLinkLabel => 'Հրավերի հղում կամ հասցե';

  @override
  String get addContactTapToPaste => 'Սեղմեք՝ որպեսզի տեղադրեք հրավերի հղումը';

  @override
  String get addContactPasteTooltip => 'Տեղադրել սեղմատախտակից';

  @override
  String get addContactAddressDetected => 'Կոնտակտի հասցեն հայտնաբերվեց';

  @override
  String addContactRoutesDetected(int count) {
    return '$count երթուղի հայտնաբերվեց — SmartRouterը ընտրում է ամենաարագը';
  }

  @override
  String get addContactFetchingProfile => 'Պրոֆիլի բեռնում…';

  @override
  String addContactProfileFound(String name) {
    return 'Գտնվել՝ $name';
  }

  @override
  String get addContactNoProfileFound => 'Պրոֆիլ չի գտնվել';

  @override
  String get addContactDisplayNameLabel => 'Ցուցադրվող անուն';

  @override
  String get addContactDisplayNameHint => 'Ինչպե՞ս եք ուզում նրան անվանել՞';

  @override
  String get addContactAddManually => 'Ավելացնել հասցեն ձեռքով';

  @override
  String get addContactButton => 'Ավելացնել կոնտակտ';

  @override
  String get networkDiagnosticsTitle => 'Ցանցի ախտորոշում';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr ռելեներ';

  @override
  String get networkDiagnosticsDirect => 'Ուղիղ';

  @override
  String get networkDiagnosticsTorOnly => 'Միայն Torով';

  @override
  String get networkDiagnosticsBest => 'Լավագույնը';

  @override
  String get networkDiagnosticsNone => 'չկա';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Կարգավիճակ';

  @override
  String get networkDiagnosticsConnected => 'Միացված';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Միանում $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Անջատված';

  @override
  String get networkDiagnosticsTransport => 'Տրանսպորտ';

  @override
  String get networkDiagnosticsInfrastructure => 'Ենթակառուցվածք';

  @override
  String get networkDiagnosticsSessionNodes => 'Session հանգույցներ';

  @override
  String get networkDiagnosticsTurnServers => 'TURN սերվերներ';

  @override
  String get networkDiagnosticsLastProbe => 'Վերջին ստուգումը';

  @override
  String get networkDiagnosticsRunning => 'Գործում է...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Գործարկել ախտորոշումը';

  @override
  String get networkDiagnosticsForceReprobe => 'Ստիպել լիարժեք վերստուգում';

  @override
  String get networkDiagnosticsJustNow => 'հենց հիմա';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutesր առաջ';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hoursժ առաջ';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$daysօր առաջ';
  }

  @override
  String get homeNoEch => 'Առանց ECH';

  @override
  String get homeNoEchTooltip =>
      'uTLS պրոքսին անհասանելի է — ECH անջատված է։\nTLS մատնահետքը տեսանելի է DPIին։';

  @override
  String get settingsTitle => 'Կարգավորումներ';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Պահվեց և միացվեց $providerին';
  }

  @override
  String get settingsTorFailedToStart => 'Ներկառուցված Torը չստացվեց գործարկել';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphonը չստացվեց գործարկել';

  @override
  String get verifyTitle => 'Ստուգել անվտանգության համարը';

  @override
  String get verifyIdentityVerified => 'Ինքնությունը ստուգված է';

  @override
  String get verifyNotYetVerified => 'Դեռ ստուգված չէ';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Դուք ստուգել եք $nameի անվտանգության համարը։';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Համեմատեք այս թվերը $nameի հետ անձամբ կամ վստահելի ալիքով։';
  }

  @override
  String get verifyExplanation =>
      'Երբեք զրույց ունի եզակի անվտանգության համար։ Եթե երկուսդ տեսնում եք նույն թվերը ձեր սարքերում, ձեր կապը ստուգված է ծայրից-ծայր։';

  @override
  String verifyContactKey(String name) {
    return '$nameի բանալիը';
  }

  @override
  String get verifyYourKey => 'Ձեր բանալիը';

  @override
  String get verifyRemoveVerification => 'Հեռացնել ստուգումը';

  @override
  String get verifyMarkAsVerified => 'Նշել որպես ստուգված';

  @override
  String verifyAfterReinstall(String name) {
    return 'Եթե $nameը վերատեղադրի հավելվածը, անվտանգության համարը կփոխվի և ստուգումը ինքնաբերաբար կհեռացվի։';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Նշեք որպես ստուգված միայն $nameի հետ ձայնային զանգով կամ անձամբ համարները համեմատելուց հետո։';
  }

  @override
  String get verifyNoSession =>
      'Գաղտնագրման նստաշ դեռ հաստատված չէ։ Նախ ուղարկեք հաղորդագրություն՝ անվտանգության համարները ստեղծելու համար։';

  @override
  String get verifyNoKeyAvailable => 'Բանալին հասանելի չէ';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label մատնահետքը պատճենվեց';
  }

  @override
  String get providerDatabaseUrlLabel => 'Տվյալների բազայի URL';

  @override
  String get providerOptionalHint => 'Կամընտրական';

  @override
  String get providerWebApiKeyLabel => 'Web API բանալի';

  @override
  String get providerOptionalForPublicDb =>
      'Կամընտրական հանրային տվյալների բազայի համար';

  @override
  String get providerRelayUrlLabel => 'Ռելեյի URL';

  @override
  String get providerPrivateKeyLabel => 'Գաղտնի բանալի';

  @override
  String get providerPrivateKeyNsecLabel => 'Գաղտնի բանալի (nsec)';

  @override
  String get providerStorageNodeLabel => 'Պահման հանգույցի URL (կամընտրական)';

  @override
  String get providerStorageNodeHint =>
      'Թողեք դատարկ՝ ներկառուցված սերմերի հանգույցների համար';

  @override
  String get transferInvalidCodeFormat =>
      'Անճանաչելի կոդի ձևաչափ — պետք է սկսվի LAN: կամ NOS:ով';

  @override
  String get profileCardFingerprintCopied => 'Մատնահետքը պատճենվեց';

  @override
  String get profileCardAboutHint => 'Գաղտնիությունը առաջին 🔒';

  @override
  String get profileCardSaveButton => 'Պահել պրոֆիլը';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Արտահանել գաղտնագրված հաղորդագրություններ, կոնտակտներ և ավատարներ ֆայլի մեջ';

  @override
  String get callVideo => 'Տեսանյութ';

  @override
  String get callAudio => 'Աուդիո';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Առաքվել է՝ $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Առաքվել է՝ $count';
  }

  @override
  String get groupStatusDialogTitle => 'Հաղորդագրության տեղեկություն';

  @override
  String get groupStatusRead => 'Կարդացած';

  @override
  String get groupStatusDelivered => 'Առաքված';

  @override
  String get groupStatusPending => 'Սպասվում';

  @override
  String get groupStatusNoData => 'Առաքման տեղեկություն դեռ չկա';

  @override
  String get profileTransferAdmin => 'Նշանակել ադմին';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Նշանակե՞լ $nameին նոր ադմին՞';
  }

  @override
  String get profileTransferAdminBody =>
      'Դուք կկորցնեք ադմինի իրավունքները։ Սա հետ չի կարելի վերացնել։';

  @override
  String profileTransferAdminDone(String name) {
    return '$nameն այժմ ադմինն է';
  }

  @override
  String get profileAdminBadge => 'Ադմին';

  @override
  String get privacyPolicyTitle => 'Գաղտնիության քաղաքականություն';

  @override
  String get privacyOverviewHeading => 'Ընդհանուր տեսք';

  @override
  String get privacyOverviewBody =>
      'Pulseը առանց սերվերների՝ ծայրից-ծայր գաղտնագրված մեսենջեր է։ Ձեր գաղտնիությունը ոչ թե հնարավորություն է, այլ ճարտարապետություն։ Pulse սերվերներ չկան։ Հաշիվներ ոչ մի տեղ չեն պահվում։ Տվյալներ չեն հավաքվում, փոխանցվում կամ պահվում մշակողների կողմից։';

  @override
  String get privacyDataCollectionHeading => 'Տվյալների հավաքում';

  @override
  String get privacyDataCollectionBody =>
      'Pulseը չի հավաքում ոչ մեկ անձնական տվյալ։ Մասնավորապես՝\n\n- Էլ. հասցե, հեռախոսահամար կամ իսկական անուն չեն պահանջվում\n- Վերլուծական, հետևիչ կամ հեռաչափություն չկա\n- Գովազդային նույնականացիչներ չկան\n- Կոնտակտների ցուցակի հասանելիություն չկա\n- Ամպային պահուստավորում չկա (հաղորդագրությունները գոյություն ունեն միայն ձեր սարքում)\n- Մետատվյալներ չեն ուղարկվում ոչ մեկ Pulse սերվերի (դրանք չկան)';

  @override
  String get privacyEncryptionHeading => 'Գաղտնագրում';

  @override
  String get privacyEncryptionBody =>
      'Բոլոր հաղորդագրությունները գաղտնագրվում են Signal պրոտոկոլով (Double Ratchet X3DH բանալիների համաձայնությամբ)։ Գաղտնագրման բանալիները ստեղճվում և պահվում են բացառապես ձեր սարքում։ Ոչ ոք — ներառյալ մշակողները — չի կարող կարդալ ձեր հաղորդագրությունները։';

  @override
  String get privacyNetworkHeading => 'Ցանցի ճարտարապետություն';

  @override
  String get privacyNetworkBody =>
      'Pulseը օգտագործում է դաշնային տրանսպորտային ադապտերներ (Nostr ռելեներ, Session/Oxen ծառայության հանգույցներ, Firebase Realtime Database, LAN)։ Այս տրանսպորտները փոխանցում են միայն գաղտնագրված տեքստ։ Ռելեների օպերատորները կարող են տեսնել ձեր IP հասցեն և թրաֆիկի ծավալը, բայց չեն կարող վերծակավորել հաղորդագրությունների բովանդակությունը։\n\nԵրբ Torը միացված է, ձեր IP հասցեն նույնպես թաքնված է ռելեների օպերատորներից։';

  @override
  String get privacyStunHeading => 'STUN/TURN սերվերներ';

  @override
  String get privacyStunBody =>
      'Ձայնային և տեսազանգերը օգտագործում են WebRTC DTLS-SRTP գաղտնագրմամբ։ STUN սերվերները (օգտագործվում են ձեր հանրային IPն հասակակիցների միջև P2P միացման համար) և TURN սերվերները (մեդիան փոխանցում են՝ երբ ուղիղ միացումը ձախողվում է) կարող են տեսնել ձեր IP հասցեն և զանգի տևողությունը, բայց չեն կարող վերծակավորել զանգի բովանդակությունը։\n\nԴուք կարող եք կարգավորել ձեր սեփական TURN սերվերը Կարգավորումներում՝ առավելագույն գաղտնիության համար։';

  @override
  String get privacyCrashHeading => 'Սխալների հաշվետվություն';

  @override
  String get privacyCrashBody =>
      'Եթե Sentry սխալների հաշվետվությունը միացված է (կառուցման ժամանակյա SENTRY_DSNով), կարող են ուղարկվել անանուն սխալների հաշվետվություններ։ Դրանք չեն պարունակում հաղորդագրությունների բովանդակություն, կոնտակտների տեղեկություն կամ անձնական նույնականացման տեղեկություն։ Սխալների հաշվետվությունը կարելի է անջատել կառուցման ժամանակյա՝ DSNը բաց թողնելով։';

  @override
  String get privacyPasswordHeading => 'Գաղտնաբառ և բանալիներ';

  @override
  String get privacyPasswordBody =>
      'Ձեր վերականգնման գաղտնաբառը օգտագործվում է կրիպտոգրաֆիկ բանալիներ ստեղծելու համար Argon2idով (հիշողության պահանջող KDF)։ Գաղտնաբառը երբեք չի փոխանցվում ոչ մի տեղ։ Եթե կորցնեք գաղտնաբառը, ձեր հաշիվը հնարավոր չէ վերականգնել — սերվեր չկա՝ որը զրոյացնի։';

  @override
  String get privacyFontsHeading => 'Տառատեսակներ';

  @override
  String get privacyFontsBody =>
      'Pulseը ներառում է բոլոր տառատեսակները տեղականորեն։ Google Fontsի կամ այլ արտաքին տառատեսակի ծառայության հարցումներ չեն կատարվում։';

  @override
  String get privacyThirdPartyHeading => 'Երրորդ կողմի ծառայություններ';

  @override
  String get privacyThirdPartyBody =>
      'Pulseը չի ինտեգրվում ոչ մի գովազդային ցանցի, վերլուծական հարթակի, սոցիալական մեդիայի կամ տվյալների բրոքերի հետ։ Միակ ցանցային միացումները ձեր կարգավորած տրանսպորտային ռելեներին են։';

  @override
  String get privacyOpenSourceHeading => 'Բաց կոդ';

  @override
  String get privacyOpenSourceBody =>
      'Pulseը բաց կոդով ծրագային ապահովում է։ Դուք կարող եք ստուգել լիարժեք նախագծի կոդը՝ այս գաղտնիության հայտարարությունները ստուգելու համար։';

  @override
  String get privacyContactHeading => 'Կապ';

  @override
  String get privacyContactBody =>
      'Գաղտնիության հետ կապված հարցերի համար բացեք խնդիր նախագծի պահոցում։';

  @override
  String get privacyLastUpdated => 'Վերջին թարմացում՝ 2026 թ. մարտ';

  @override
  String imageSaveFailed(Object error) {
    return 'Պահմանը ձախողվեց՝ $error';
  }

  @override
  String get themeEngineTitle => 'Թեմայի շարժիչ';

  @override
  String get torBuiltInTitle => 'Ներկառուցված Tor';

  @override
  String get torConnectedSubtitle =>
      'Միացված — Nostrը ուղղվում է 127.0.0.1:9250ով';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Միանում… $pct%';
  }

  @override
  String get torNotRunning =>
      'Չի աշխատում — սեղմեք անջատիչը՝ վերագործարկելու համար';

  @override
  String get torDescription =>
      'Ուղղում է Nostrը Torով (Snowflake գրաքննված ցանցերի համար)';

  @override
  String get torNetworkDiagnostics => 'Ցանցի ախտորոշում';

  @override
  String get torTransportLabel => 'Տրանսպորտ՝ ';

  @override
  String get torPtAuto => 'Ինքնաբերաբար';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Սովորական';

  @override
  String get torTimeoutLabel => 'Սպասման ժամկետ՝ ';

  @override
  String get torInfoDescription =>
      'Երբ միացված է, Nostr WebSocket միացումները ուղղվում են Torով (SOCKS5)։ Tor Browserը լսնում է 127.0.0.1:9150ով։ Ինքնուրույն tor daemonը օգտագործում է պորտ 9050։ Firebase միացումները չեն ազդվում։';

  @override
  String get torRouteNostrTitle => 'Ուղղել Nostrը Torով';

  @override
  String get torManagedByBuiltin => 'Կառավարվում է ներկառուցված Torով';

  @override
  String get torActiveRouting => 'Ակտիվ — Nostr թրաֆիկը ուղղվում է Torով';

  @override
  String get torDisabled => 'Անջատված';

  @override
  String get torProxySocks5 => 'Tor պրոքսի (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Պրոքսիի հոստ';

  @override
  String get torProxyPortLabel => 'Պորտ';

  @override
  String get torPortInfo => 'Tor Browser՝ պորտ 9150  •  tor daemon՝ պորտ 9050';

  @override
  String get torForceNostrTitle =>
      'Հաղորդագրությունները ուղարկել Tor-ի միջոցով';

  @override
  String get torForceNostrSubtitle =>
      'Nostr relay-ի բոլոր կապակցությունները կանցնեն Tor-ի միջոցով։ Ավելի դանդաղ, բայց թաքցնում է ձեր IP-ն relay-ներից։';

  @override
  String get torForceNostrDisabled => 'Tor-ը նախ պետք է միացնել';

  @override
  String get torForcePulseTitle => 'Pulse relay-ը ուղարկել Tor-ի միջոցով';

  @override
  String get torForcePulseSubtitle =>
      'Pulse relay-ի բոլոր կապակցությունները կանցնեն Tor-ի միջոցով։ Ավելի դանդաղ, բայց թաքցնում է ձեր IP-ն սերվերից։';

  @override
  String get torForcePulseDisabled => 'Tor-ը նախ պետք է միացնել';

  @override
  String get i2pProxySocks5 => 'I2P պրոքսի (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2Pն օգտագործում է SOCKS5 պորտ 4447ով լիպելյանով։ Միացեք Nostr ռելեին I2P outproxyով (օրինակ՝ relay.damus.i2p)՝ որպեսզի շփվեք ցանկացած տրանսպորտի օգտատերերի հետ։ Երկուսը միացված լինելու դեպքում Torը առաջնահերթ է։';

  @override
  String get i2pRouteNostrTitle => 'Ուղղել Nostrը I2Pով';

  @override
  String get i2pActiveRouting => 'Ակտիվ — Nostr թրաֆիկը ուղղվում է I2Pով';

  @override
  String get i2pDisabled => 'Անջատված';

  @override
  String get i2pProxyHostLabel => 'Պրոքսիի հոստ';

  @override
  String get i2pProxyPortLabel => 'Պորտ';

  @override
  String get i2pPortInfo => 'I2P Router լիպելյան SOCKS5 պորտ՝ 4447';

  @override
  String get customProxySocks5 => 'Հատուկ պրոքսի (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker ռելե';

  @override
  String get customProxyInfoDescription =>
      'Հատուկ պրոքսին ուղղորդում է թրաֆիկը ձեր V2Ray/Xray/Shadowsocksով։ CF Workerը հանդիսանում է անձնական ռելեյի պրոքսի Cloudflare CDNում — GFWն տեսնում է *.workers.dev, ոչ թե իրական ռելեն։';

  @override
  String get customSocks5ProxyTitle => 'Հատուկ SOCKS5 պրոքսի';

  @override
  String get customProxyActive => 'Ակտիվ — թրաֆիկը ուղղվում է SOCKS5ով';

  @override
  String get customProxyDisabled => 'Անջատված';

  @override
  String get customProxyHostLabel => 'Պրոքսիի հոստ';

  @override
  String get customProxyPortLabel => 'Պորտ';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker դոմեն (կամընտրական)';

  @override
  String get customWorkerHelpTitle => 'Ինչպես տեղադրել CF Worker ռելե (անվճար)';

  @override
  String get customWorkerScriptCopied => 'Սկրիպտը պատճենվեց։';

  @override
  String get customWorkerStep1 =>
      '1. Գնացեք dash.cloudflare.com → Workers & Pages\n2. Create Worker → տեղադրեք այս սկրիպտը՝\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → պատճենեք դոմենը (օրինակ՝ my-relay.user.workers.dev)\n4. Տեղադրեք դոմենը վերևում → Պահել\n\nՀավելվածը ինքնամիանում է՝ wss://domain/?r=relay_url\nGFWն տեսնում է՝ միացում *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Միացված — SOCKS5 127.0.0.1:$portով';
  }

  @override
  String get psiphonConnecting => 'Միանում…';

  @override
  String get psiphonNotRunning =>
      'Չի աշխատում — սեղմեք անջատիչը՝ վերագործարկելու համար';

  @override
  String get psiphonDescription =>
      'Արագ թունել (~3վ գործարկում, 2000+ ռոտացվող VPS)';

  @override
  String get turnCommunityServers => 'Համայնքի TURN սերվերներ';

  @override
  String get turnCustomServer => 'Հատուկ TURN սերվեր (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN սերվերները փոխանցում են միայն արդեն գաղտնագրված հոսքեր (DTLS-SRTP)։ Ռելեյի օպերատորը տեսնում է ձեր IPն և թրաֆիկի ծավալը, բայց չի կարող վերծակավորել զանգերը։ TURNը օգտագործվում է միայն երբ ուղիղ P2Pն ձախողվում է (~15–20% միացումների)։';

  @override
  String get turnFreeLabel => 'ԱՆՎՃԱՌ';

  @override
  String get turnServerUrlLabel => 'TURN սերվերի URL';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 կամ turns:...';

  @override
  String get turnUsernameLabel => 'Օգտատերի անուն';

  @override
  String get turnPasswordLabel => 'Գաղտնաբառ';

  @override
  String get turnOptionalHint => 'Կամընտրական';

  @override
  String get turnCustomInfo =>
      'Տեղադրեք coturn ցանկացած \$5/ամս. VPSում՝ առավելագույն կառավարման համար։ Տվյալները պահվում են տեղականորեն։';

  @override
  String get themePickerAppearance => 'Տեսք';

  @override
  String get themePickerAccentColor => 'Շեշտագույն';

  @override
  String get themeModeLight => 'Լուսավոր';

  @override
  String get themeModeDark => 'Մուգ';

  @override
  String get themeModeSystem => 'Համակարգի';

  @override
  String get themeDynamicPresets => 'Նախադրվածներ';

  @override
  String get themeDynamicPrimaryColor => 'Հիմնական գույն';

  @override
  String get themeDynamicBorderRadius => 'Եզրագծի կլորացում';

  @override
  String get themeDynamicFont => 'Տառատեսակ';

  @override
  String get themeDynamicAppearance => 'Տեսք';

  @override
  String get themeDynamicUiStyle => 'Միջերեսի ոճ';

  @override
  String get themeDynamicUiStyleDescription =>
      'Կառավարում է երկխոսությունների, անջատիչների և ցուցիչների տեսքը։';

  @override
  String get themeDynamicSharp => 'Սուր';

  @override
  String get themeDynamicRound => 'Կլոր';

  @override
  String get themeDynamicModeDark => 'Մուգ';

  @override
  String get themeDynamicModeLight => 'Լուսավոր';

  @override
  String get themeDynamicModeAuto => 'Ինքնաբերաբար';

  @override
  String get themeDynamicPlatformAuto => 'Ինքնաբերաբար';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'Անվավեր Firebase URL։ Սպասվում է՝ https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Անվավեր ռելեյի URL։ Սպասվում է՝ wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Անվավեր Pulse սերվերի URL։ Սպասվում է՝ https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'Սերվերի URL';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'Հրավերի կոդ';

  @override
  String get providerPulseInviteHint => 'Հրավերի կոդ (եթե պահանջվում է)';

  @override
  String get providerPulseInfo =>
      'Սեփական հոստով ռելե։ Բանալիները ստացվում են վերականգնման գաղտնաբառից։';

  @override
  String get providerScreenTitle => 'Մուտքարկղեր';

  @override
  String get providerSecondaryInboxesHeader => 'ԵՌԿՌՈՌԴԱԿԱՆ ՄՈՈՏՔԱՌԿՂԵՌ';

  @override
  String get providerSecondaryInboxesInfo =>
      'Երկրորդական մուտքարկղերը ստանում են հաղորդագրություններ միաժամանակ՝ հուսալիության համար։';

  @override
  String get providerRemoveTooltip => 'Հեռացնել';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... կամ hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... կամ hex գաղտնի բանալի';

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
  String get emojiNoRecent => 'Վերջին էմոջիներ չկան';

  @override
  String get emojiSearchHint => 'Որոնել էմոջի...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Սեղմեք՝ որպեսզի զրուցեք';

  @override
  String get imageViewerSaveToDownloads => 'Պահել Downloadsում';

  @override
  String imageViewerSavedTo(String path) {
    return 'Պահվել է՝ $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Լեզու';

  @override
  String get settingsLanguageSubtitle => 'Հավելվածի ցուցադրման լեզուը';

  @override
  String get settingsLanguageSystem => 'Համակարգի լիպելյան';

  @override
  String get onboardingLanguageTitle => 'Ընտրեք ձեր լեզուը';

  @override
  String get onboardingLanguageSubtitle =>
      'Դուք կարող եք փոխել հետո կարգավորումներում';

  @override
  String get videoNoteRecord => 'Ձայնագրել վիդեո հաղորդագրություն';

  @override
  String get videoNoteTapToRecord => 'Հпեք ձայнагрелու համար';

  @override
  String get videoNoteTapToStop => 'Հпեք կангнецнелու համар';

  @override
  String get videoNoteCameraPermission => 'Тեсахцикի тհуйлтвутһюнը мерждвад է';

  @override
  String get videoNoteMaxDuration => 'Аռавелагуйнը 30 вайркян';

  @override
  String get videoNoteNotSupported =>
      'Видео ншумнерը чен аджакцвум айс հарդакум';

  @override
  String get navChats => 'Զրույցներ';

  @override
  String get navUpdates => 'Թարմացումներ';

  @override
  String get navCalls => 'Զանգեր';

  @override
  String get filterAll => 'Բոլոր';

  @override
  String get filterUnread => 'Չկարդացված';

  @override
  String get filterGroups => 'Խմբեր';

  @override
  String get callsNoRecent => 'Վերջին զանգեր չկան';

  @override
  String get callsEmptySubtitle => 'Ձեր զանգերի պատմությունը կհայտնվի այստեղ';

  @override
  String get appBarEncrypted => 'ծայրից ծայր կոդավորված';

  @override
  String get newStatus => 'Նոր կարգավիճակ';

  @override
  String get newCall => 'Նոր զանգ';

  @override
  String get joinChannelTitle => 'Միանալ ալիքին';

  @override
  String get joinChannelDescription => 'ԱԼԻՔԻ URL';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'Ալիքի տեղեկություն ստանալու է…';

  @override
  String get joinChannelNotFound => 'Այս URL-ում ալիք չի գտնվել';

  @override
  String get joinChannelNetworkError => 'Հնարավոր չէ կապվել սերվերին';

  @override
  String get joinChannelAlreadyJoined => 'Արդեն միանալ է';

  @override
  String get joinChannelButton => 'Միանալ';

  @override
  String get channelFeedEmpty => 'Դեռ գրառումներ չկան';

  @override
  String get channelLeave => 'Լքել ալիքը';

  @override
  String get channelLeaveConfirm =>
      'Լքե՞լ այս ալիքը։ Պահված գրառումները կջնվեն։';

  @override
  String get channelInfo => 'Ալիքի տեղեկություն';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'խմբագրված';

  @override
  String get channelLoadMore => 'Բեռնել ավելին';

  @override
  String get channelSearchPosts => 'Փնտրել գրառումները…';

  @override
  String get channelNoResults => 'Համապատասխան գրառումներ չկան';

  @override
  String get channelUrl => 'Ալիքի URL';

  @override
  String get channelCreated => 'Միացած';

  @override
  String channelPostCount(int count) {
    return '$count գրառում';
  }

  @override
  String get channelCopyUrl => 'URL պատճենել';

  @override
  String get setupNext => 'Հաջորդ';

  @override
  String get setupKeyWarning =>
      'A recovery key will be generated for you. It is the only way to restore your account on a new device — there is no server, no password reset.';

  @override
  String get setupKeyTitle => 'Your Recovery Key';

  @override
  String get setupKeySubtitle =>
      'Write this key down and store it in a safe place. You will need it to restore your account on a new device.';

  @override
  String get setupKeyCopied => 'Պատճենված!';

  @override
  String get setupKeyWroteItDown => 'Գdelays';

  @override
  String get setupKeyWarnBody =>
      'Write this key down as a backup. You can also view it later in Settings → Security.';

  @override
  String get setupVerifyTitle => 'Verify Recovery Key';

  @override
  String get setupVerifySubtitle =>
      'Re-enter your recovery key to confirm you saved it correctly.';

  @override
  String get setupVerifyButton => 'Ստուգել';

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
  String get replaceIdentityTitle =>
      'Փոխարինե՞լ գոյություն ունեցող ինքնությունը՟';

  @override
  String get replaceIdentityBodyRestore =>
      'Այս սարքի վրա արդեն ինքնություն կա։ Վերականգնելը ընդմիշտ կփոխարինի ձեր ընթացիկ Nostr բանալին և Oxen seed-ը։ Բոլոր կոնտակտները կկորցնեն ձեր ընթացիկ հասցեին հասնելու հնարավորությունը։\n\nՍա հետ չի կարելի վերացնել։';

  @override
  String get replaceIdentityBodyCreate =>
      'Այս սարքի վրա արդեն ինքնություն կա։ Նորի ստեղծելը ընդմիշտ կփոխարինի ձեր ընթացիկ Nostr բանալին և Oxen seed-ը։ Բոլոր կոնտակտները կկորցնեն ձեր ընթացիկ հասցեին հասնելու հնարավորությունը։\n\nՍա հետ չի կարելի վերացնել։';

  @override
  String get replace => 'Փոխարինել';

  @override
  String get callNoScreenSources => 'Էկրանի աղբյուրներ հասանելի չեն';

  @override
  String get callScreenShareQuality => 'Էկրանի համաօգտագործման որակը';

  @override
  String get callFrameRate => 'Կադրի արագություն';

  @override
  String get callResolution => 'Լուծականակություն';

  @override
  String get callAutoResolution =>
      'Ինքնաբերական = էկրանի բնական լուծականակություն';

  @override
  String get callStartSharing => 'Սկսել համաօգտագործումը';

  @override
  String get callCameraUnavailable =>
      'Տեսախցիկը հասանելի չէ — հնարավոր է օգտագործվում է այլ հավելվածի կողմից';

  @override
  String get themeResetToDefaults => 'Վերականգնել լրիվ արժեքները';

  @override
  String get backupSaveToDownloadsTitle =>
      'Պահե՞լ պահուստային պատճենը Ներբեռնումներում՟';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'Ֆայլերի ընտրիչը հասանելի չէ։ Պահուստային պատճենը կպահպանվի հետևյալ տեղում՝\n$path';
  }

  @override
  String get systemLabel => 'Համակարգ';

  @override
  String get next => 'Հաջորդ';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return 'Եվս $remaining հպում մշակողի ռեժիմը միացնելու համար';
  }

  @override
  String get devModeEnabled => 'Մշակողի ռեժիմը միացված է';

  @override
  String get devTools => 'Մշակողի գործիքներ';

  @override
  String get devAdapterDiagnostics => 'Ադապտերի անջատիչներ և ախտորոշում';

  @override
  String get devEnableAll => 'Միացնել բոլորը';

  @override
  String get devDisableAll => 'Անջատել բոլորը';

  @override
  String get turnUrlValidation =>
      'TURN URL-ը պետք է սկսվի turn: կամ turns: (առավելագույնը 512 նիշ)';

  @override
  String get callMissedCall => 'Բաց թողնված զանգ';

  @override
  String get callOutgoingCall => 'Ելքային զանգ';

  @override
  String get callIncomingCall => 'Մուտքային զանգ';

  @override
  String get mediaMissingData => 'Մեդիա տվյալները բացակայում են';

  @override
  String get mediaDownloadFailed => 'Ներբեռնումը ձախողվեց';

  @override
  String get mediaDecryptFailed => 'Վերծակոդավորումը ձախողվեց';

  @override
  String get callEndCallBanner => 'Ավարտել զանգը';

  @override
  String get meFallback => 'Ես';

  @override
  String get imageSaveToDownloads => 'Պահել Ներբեռնումներում';

  @override
  String imageSavedToPath(String path) {
    return 'Պահված է $path տեղում';
  }

  @override
  String get callScreenShareRequiresPermission =>
      'Էկրանի համաօգտագործումը թույլտվություն է պահանջում';

  @override
  String get callScreenShareUnavailable =>
      'Էկրանի համաօգտագործումը հասանելի չէ';

  @override
  String get statusJustNow => 'Հենց հիմա';

  @override
  String statusMinutesAgo(int minutes) {
    return '$minutesր առաջ';
  }

  @override
  String statusHoursAgo(int hours) {
    return '$hoursժ առաջ';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count երթուղի',
      one: '1 երթուղի',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => 'Պատրաստ է ավելացնելու';

  @override
  String groupSelectedCount(int count) {
    return '$count ընտրված';
  }

  @override
  String get paste => 'Տեղադրել';

  @override
  String get sfuAudioOnly => 'Միայն ձայն';

  @override
  String sfuParticipants(int count) {
    return '$count մասնակից';
  }

  @override
  String get dataUnencryptedBackup => 'Չգաղտնագրված պահուստային պատճեն';

  @override
  String get dataUnencryptedBackupBody =>
      'Այս ֆայլը չգաղտնագրված ինքնության պահուստային պատճեն է և կվերագրի ձեր ընթացիկ բանալիները։ Ներմուծեք միայն ձեր իսկ ստեղծած ֆայլերը։ Շարունակե՞լ:';

  @override
  String get dataImportAnyway => 'Ամեն դեպքում ներմուծել';

  @override
  String get securityStorageError =>
      'Անվտանգ պահպանման սխալ — վերագործեք հավելվածը';

  @override
  String get aboutDevModeActive => 'Մշակողի ռեժիմ ակտիվ է';

  @override
  String get themeColors => 'Գույներ';

  @override
  String get themePrimaryAccent => 'Հիմնական շեշտ';

  @override
  String get themeSecondaryAccent => 'Երկրորդային շեշտ';

  @override
  String get themeBackground => 'Հետնապատկեր';

  @override
  String get themeSurface => 'Մակերևույթ';

  @override
  String get themeChatBubbles => 'Զրույցի պմպուկներ';

  @override
  String get themeOutgoingMessage => 'Ելքային հաղորդագրություն';

  @override
  String get themeIncomingMessage => 'Մուտքային հաղորդագրություն';

  @override
  String get themeShape => 'Ձև';

  @override
  String get devSectionDeveloper => 'Մշակող';

  @override
  String get devAdapterChannelsHint =>
      'Ադապտերի ալիքներ — անջատեք որոշակի տրանսպորտներ փորձարկելու համար։';

  @override
  String get devNostrRelays => 'Nostr հանգույցներ (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Session ցանց';

  @override
  String get devPulseRelay => 'Pulse ինքնասպասարկվող relay';

  @override
  String get devLanNetwork => 'Տեղական ցանց (UDP/TCP)';

  @override
  String get devSectionCalls => 'Զանգեր';

  @override
  String get devForceTurnRelay => 'Ստիպել TURN relay';

  @override
  String get devForceTurnRelaySubtitle =>
      'Անջատել P2P — բոլոր զանգերը միայն TURN սերվերների միջոցով';

  @override
  String get devRestartWarning =>
      '⚠ Փոփոխությունները կիրառվեն հաջորդ ուղարկման/զանգի ժամանակ։ Վերագործեք հավելվածը մուտքայինների համար։';

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
  String get pulseUseServerTitle => 'Օգտագործե՞լ Pulse սերվերը:';

  @override
  String pulseUseServerBody(String name, String host) {
    return '$name-ը օգտագործում է Pulse սերվեր $host-ը: Միացե՞ք՝ արագ զրույցի համար (և նույն սերվերի ուրիշների հետ):';
  }

  @override
  String pulseContactUsesPulse(String name) {
    return '$name-ը օգտագործում է Pulse-ը';
  }

  @override
  String pulseJoinForFaster(String host) {
    return 'Միացեք $host-ին՝ ավելի արագ զրույցի համար';
  }

  @override
  String get pulseNotNow => 'Ոչ հիմա';

  @override
  String get pulseJoin => 'Միանալ';

  @override
  String get pulseDismiss => 'Փակել';

  @override
  String get pulseHide7Days => 'Թաքցնել 7 օրով';

  @override
  String get pulseNeverAskAgain => 'Այլևս չհարցնել';

  @override
  String get groupSearchContactsHint => 'Որոնել կոնտակտներ…';

  @override
  String get systemActorYou => 'Դուք';

  @override
  String get systemActorPeer => 'Կոնտակտ';

  @override
  String systemTtlEnabled(String actor, String duration) {
    return '$actor-ը միացրեց անհետացող հաղորդագրությունները՝ $duration';
  }

  @override
  String systemTtlDisabled(String actor) {
    return '$actor-ը անջատեց անհետացող հաղորդագրությունները';
  }

  @override
  String get menuClearChatHistory => 'Մաքրել զրույցի պատմությունը';

  @override
  String get clearChatTitle => 'Մաքրե՞լ զրույցի պատմությունը:';

  @override
  String get clearChatBody =>
      'Այս զրույցի բոլոր հաղորդագրությունները կջնջվեն այս սարքից։ Մյուս անձը կպահպանի իր պատճենը։';

  @override
  String get clearChatAction => 'Մաքրել';

  @override
  String systemGroupRenamed(String actor, String name) {
    return '$actor-ը խումբը վերանվանեց «$name»';
  }

  @override
  String systemGroupAvatarChanged(String actor) {
    return '$actor-ը փոխեց խմբի լուսանկարը';
  }

  @override
  String systemGroupMetaChanged(String actor, String name) {
    return '$actor-ը խումբը վերանվանեց «$name» և փոխեց լուսանկարը';
  }

  @override
  String get profileInviteLink => 'Հրավերի հղում';

  @override
  String get profileInviteLinkSubtitle =>
      'Հղումն ունեցող ցանկացած մարդ կարող է միանալ';

  @override
  String get profileInviteLinkCopied => 'Հրավերի հղումը պատճենվեց';

  @override
  String get groupInviteLinkTitle => 'Միանա՞լ խմբին:';

  @override
  String groupInviteLinkBody(String name, int count) {
    return 'Դուք հրավիրված եք «$name» խմբին ($count անդամ):';
  }

  @override
  String get groupInviteLinkJoin => 'Միանալ';

  @override
  String get drawerCreateGroup => 'Ստեղծել խումբ';

  @override
  String get drawerJoinGroup => 'Միանալ խմբին';

  @override
  String get drawerJoinGroupByLinkInvalid =>
      'Սա չի թվում Pulse-ի հրավիրյալ հղում';

  @override
  String get groupModeMeshTitle => 'Սովորական';

  @override
  String groupModeMeshSubtitle(int n) {
    return 'Առանց սերվերի, մինչև $n մարդ';
  }

  @override
  String get groupModePulseTitle => 'Pulse սերվեր';

  @override
  String groupModePulseSubtitle(int n) {
    return 'Սերվերի միջոցով, մինչև $n մարդ';
  }

  @override
  String get groupPulseServerHint => 'https://dzer-pulse-server';

  @override
  String get groupPulseServerClosed => 'Փակ սերվեր (պահանջում է հրավերի կոդ)';

  @override
  String get groupPulseInviteHint => 'Հրավերի կոդ';

  @override
  String pulseGroupForeignServerBanner(String host) {
    return 'Հաղորդագրությունները ուղարկվում են $host միջոցով';
  }

  @override
  String groupMeshLimitReached(int n) {
    return 'Այս զանգի տեսակը սահմանափակված է $n մարդով';
  }
}
