// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Georgian (`ka`).
class AppLocalizationsKa extends AppLocalizations {
  AppLocalizationsKa([String locale = 'ka']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'შეტყობინებების ძიება...';

  @override
  String get search => 'ძიება';

  @override
  String get clearSearch => 'ძიების გასუფთავება';

  @override
  String get closeSearch => 'ძიების დახურვა';

  @override
  String get moreOptions => 'მეტი პარამეტრები';

  @override
  String get back => 'უკან';

  @override
  String get cancel => 'გაუქმება';

  @override
  String get close => 'დახურვა';

  @override
  String get confirm => 'დადასტურება';

  @override
  String get remove => 'წაშლა';

  @override
  String get save => 'შენახვა';

  @override
  String get add => 'დამატება';

  @override
  String get copy => 'კოპირება';

  @override
  String get skip => 'გამოტოვება';

  @override
  String get done => 'მზადაა';

  @override
  String get apply => 'გამოყენება';

  @override
  String get export => 'ექსპორტი';

  @override
  String get import => 'იმპორტი';

  @override
  String get homeNewGroup => 'ახალი ჯგუფი';

  @override
  String get homeSettings => 'პარამეტრები';

  @override
  String get homeSearching => 'შეტყობინებების ძიება...';

  @override
  String get homeNoResults => 'შედეგები ვერ მოიძებნა';

  @override
  String get homeNoChatHistory => 'ჩატის ისტორია ჯერ არ არის';

  @override
  String homeTransportSwitched(String address) {
    return 'ტრანსპორტი შეიცვალა → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name გიძახისთ...';
  }

  @override
  String get homeAccept => 'მიღება';

  @override
  String get homeDecline => 'უარყოფა';

  @override
  String get homeLoadEarlier => 'ადრინდელი შეტყობინებების ჩატვირთვა';

  @override
  String get homeChats => 'ჩატები';

  @override
  String get homeSelectConversation => 'აირჩიეთ საუბარი';

  @override
  String get homeNoChatsYet => 'ჩატები ჯერ არ არის';

  @override
  String get homeAddContactToStart => 'დაამატეთ კონტაქტი ჩატის დასაწყებად';

  @override
  String get homeNewChat => 'ახალი ჩატი';

  @override
  String get homeNewChatTooltip => 'ახალი ჩატი';

  @override
  String get homeIncomingCallTitle => 'შემომავალი ზარი';

  @override
  String get homeIncomingGroupCallTitle => 'შემომავალი ჯგუფური ზარი';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — შემომავალი ჯგუფური ზარი';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'ჩატები ვერ მოიძებნა \"$query\"-ისთვის';
  }

  @override
  String get homeSectionChats => 'ჩატები';

  @override
  String get homeSectionMessages => 'შეტყობინებები';

  @override
  String get homeDbEncryptionUnavailable =>
      'მონაცემთა ბაზის დაშიფვრა მიუწვდომელია — სრული დაცვისთვის დააინსტალირეთ SQLCipher';

  @override
  String get chatFileTooLargeGroup =>
      '512 KB-ზე მეტი ზომის ფაილები ჯგუფურ ჩატებში არ არის მხარდაჭერილი';

  @override
  String get chatLargeFile => 'დიდი ფაილი';

  @override
  String get chatCancel => 'გაუქმება';

  @override
  String get chatSend => 'გაგზავნა';

  @override
  String get chatFileTooLarge => 'ფაილი ძალიან დიდია — მაქსიმალური ზომა 100 MB';

  @override
  String get chatMicDenied => 'მიკროფონის ნებართვა უარყოფილია';

  @override
  String get chatVoiceFailed =>
      'ხმოვანი შეტყობინების შენახვა ვერ მოხერხდა — შეამოწმეთ ხელმისაწვდომი მეხსიერება';

  @override
  String get chatScheduleFuture => 'დაგეგმილი დრო უნდა იყოს მომავალში';

  @override
  String get chatToday => 'დღეს';

  @override
  String get chatYesterday => 'გუშინ';

  @override
  String get chatEdited => 'შესწორებული';

  @override
  String get chatYou => 'თქვენ';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'ეს ფაილი $size MB-ია. დიდი ფაილების გაგზავნა ზოგიერთ ქსელში ნელი შეიძლება იყოს. გაგრძელება?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return '$name-ის უსაფრთხოების გასაღები შეიცვალა. შეეხეთ დასადასტურებლად.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return '$name-ისთვის შეტყობინების დაშიფვრა ვერ მოხერხდა — შეტყობინება არ გაიგზავნა.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'უსაფრთხოების ნომერი შეიცვალა $name-ისთვის. შეეხეთ დასადასტურებლად.';
  }

  @override
  String get chatNoMessagesFound => 'შეტყობინებები ვერ მოიძებნა';

  @override
  String get chatMessagesE2ee => 'შეტყობინებები ბოლოდან ბოლომდე დაშიფრულია';

  @override
  String get chatSayHello => 'მიესალმეთ';

  @override
  String get appBarOnline => 'ონლაინ';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'წერს';

  @override
  String get appBarSearchMessages => 'შეტყობინებების ძიება...';

  @override
  String get appBarMute => 'დადუმება';

  @override
  String get appBarUnmute => 'ხმის ჩართვა';

  @override
  String get appBarMedia => 'მედია';

  @override
  String get appBarDisappearing => 'ქრებადი შეტყობინებები';

  @override
  String get appBarDisappearingOn => 'ქრებადი: ჩართული';

  @override
  String get appBarGroupSettings => 'ჯგუფის პარამეტრები';

  @override
  String get appBarSearchTooltip => 'შეტყობინებების ძიება';

  @override
  String get appBarVoiceCall => 'ხმოვანი ზარი';

  @override
  String get appBarVideoCall => 'ვიდეოზარი';

  @override
  String get inputMessage => 'შეტყობინება...';

  @override
  String get inputAttachFile => 'ფაილის მიმაგრება';

  @override
  String get inputSendMessage => 'შეტყობინების გაგზავნა';

  @override
  String get inputRecordVoice => 'ხმოვანი შეტყობინების ჩაწერა';

  @override
  String get inputSendVoice => 'ხმოვანი შეტყობინების გაგზავნა';

  @override
  String get inputCancelReply => 'პასუხის გაუქმება';

  @override
  String get inputCancelEdit => 'რედაქტირების გაუქმება';

  @override
  String get inputCancelRecording => 'ჩაწერის გაუქმება';

  @override
  String get inputRecording => 'იწერება…';

  @override
  String get inputEditingMessage => 'შეტყობინების რედაქტირება';

  @override
  String get inputPhoto => 'ფოტო';

  @override
  String get inputVoiceMessage => 'ხმოვანი შეტყობინება';

  @override
  String get inputFile => 'ფაილი';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count დაგეგმილი შეტყობინება$_temp0';
  }

  @override
  String get callInitializing => 'ზარის ინიციალიზაცია…';

  @override
  String get callConnecting => 'დაკავშირება…';

  @override
  String get callConnectingRelay => 'დაკავშირება (რელე)…';

  @override
  String get callSwitchingRelay => 'რელეს რეჟიმზე გადართვა…';

  @override
  String get callConnectionFailed => 'კავშირი ვერ მოხერხდა';

  @override
  String get callReconnecting => 'ხელახალი დაკავშირება…';

  @override
  String get callEnded => 'ზარი დასრულდა';

  @override
  String get callLive => 'პირდაპირ';

  @override
  String get callEnd => 'დასრულება';

  @override
  String get callEndCall => 'ზარის დასრულება';

  @override
  String get callMute => 'დადუმება';

  @override
  String get callUnmute => 'ხმის ჩართვა';

  @override
  String get callSpeaker => 'დინამიკი';

  @override
  String get callCameraOn => 'კამერა ჩართ.';

  @override
  String get callCameraOff => 'კამერა გამორთ.';

  @override
  String get callShareScreen => 'ეკრანის გაზიარება';

  @override
  String get callStopShare => 'გაზიარების შეწყვეტა';

  @override
  String callTorBackup(String duration) {
    return 'Tor სარეზერვო · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor სარეზერვო აქტიურია — ძირითადი გზა მიუწვდომელია';

  @override
  String get callDirectFailed =>
      'პირდაპირი კავშირი ვერ მოხერხდა — რელეს რეჟიმზე გადართვა…';

  @override
  String get callTurnUnreachable =>
      'TURN სერვერები მიუწვდომელია. დაამატეთ საკუთარი TURN პარამეტრებში → გაფართოებული.';

  @override
  String get callRelayMode => 'რელეს რეჟიმი აქტიურია (შეზღუდული ქსელი)';

  @override
  String get callStarting => 'ზარი იწყება…';

  @override
  String get callConnectingToGroup => 'ჯგუფთან დაკავშირება…';

  @override
  String get callGroupOpenedInBrowser => 'ჯგუფური ზარი ბრაუზერში გაიხსნა';

  @override
  String get callCouldNotOpenBrowser => 'ბრაუზერის გახსნა ვერ მოხერხდა';

  @override
  String get callInviteLinkSent =>
      'მოწვევის ბმული გაეგზავნა ჯგუფის ყველა წევრს.';

  @override
  String get callOpenLinkManually =>
      'გახსენით ზემოთ მოცემული ბმული ხელით ან შეეხეთ ხელახლა საცდელად.';

  @override
  String get callJitsiNotE2ee =>
      'Jitsi ზარები არ არის ბოლოდან ბოლომდე დაშიფრული';

  @override
  String get callRetryOpenBrowser => 'ბრაუზერის ხელახლა გახსნა';

  @override
  String get callClose => 'დახურვა';

  @override
  String get callCamOn => 'კამერა ჩართ.';

  @override
  String get callCamOff => 'კამერა გამორთ.';

  @override
  String get noConnection => 'კავშირი არ არის — შეტყობინებები რიგში დადგება';

  @override
  String get connected => 'დაკავშირებული';

  @override
  String get connecting => 'დაკავშირება…';

  @override
  String get disconnected => 'გათიშული';

  @override
  String get offlineBanner =>
      'კავშირი არ არის — შეტყობინებები გაიგზავნება ონლაინ დაბრუნებისას';

  @override
  String get lanModeBanner =>
      'LAN რეჟიმი — ინტერნეტის გარეშე · მხოლოდ ლოკალური ქსელი';

  @override
  String get probeCheckingNetwork => 'ქსელის კავშირის შემოწმება…';

  @override
  String get probeDiscoveringRelays =>
      'რელეების აღმოჩენა საზოგადოების დირექტორიებით…';

  @override
  String get probeStartingTor => 'Tor იწყება ჩატვირთვისთვის…';

  @override
  String get probeFindingRelaysTor => 'ხელმისაწვდომი რელეების პოვნა Tor-ით…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'ქსელი მზადაა — ნაპოვნია $count რელე$_temp0';
  }

  @override
  String get probeNoRelaysFound =>
      'ხელმისაწვდომი რელეები ვერ მოიძებნა — შეტყობინებები შეიძლება დაგვიანდეს';

  @override
  String get jitsiWarningTitle => 'ბოლოდან ბოლომდე დაშიფრული არ არის';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet ზარები Pulse-ით არ არის დაშიფრული. გამოიყენეთ მხოლოდ არაკონფიდენციალური საუბრებისთვის.';

  @override
  String get jitsiConfirm => 'მაინც შესვლა';

  @override
  String get jitsiGroupWarningTitle => 'ბოლოდან ბოლომდე დაშიფრული არ არის';

  @override
  String get jitsiGroupWarningBody =>
      'ამ ზარში ძალიან ბევრი მონაწილეა ჩაშენებული დაშიფრული მეში-სთვის.\n\nJitsi Meet ბმული გაიხსნება თქვენს ბრაუზერში. Jitsi არ არის ბოლოდან ბოლომდე დაშიფრული — სერვერს შეუძლია თქვენი ზარის ნახვა.';

  @override
  String get jitsiContinueAnyway => 'მაინც გაგრძელება';

  @override
  String get retry => 'ხელახლა ცდა';

  @override
  String get setupCreateAnonymousAccount => 'ანონიმური ანგარიშის შექმნა';

  @override
  String get setupTapToChangeColor => 'შეეხეთ ფერის შესაცვლელად';

  @override
  String get setupReqMinLength => 'მინიმუმ 16 სიმბოლო';

  @override
  String get setupReqVariety =>
      '4-დან 3: დიდი, პატარა ასოები, ციფრები, სიმბოლოები';

  @override
  String get setupReqMatch => 'პაროლები ემთხვევა';

  @override
  String get setupYourNickname => 'თქვენი მეტსახელი';

  @override
  String get setupRecoveryPassword => 'აღდგენის პაროლი (მინ. 16)';

  @override
  String get setupConfirmPassword => 'პაროლის დადასტურება';

  @override
  String get setupMin16Chars => 'მინიმუმ 16 სიმბოლო';

  @override
  String get setupPasswordsDoNotMatch => 'პაროლები არ ემთხვევა';

  @override
  String get setupEntropyWeak => 'სუსტი';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'ძლიერი';

  @override
  String get setupEntropyWeakNeedsVariety => 'სუსტი (საჭიროა 3 ტიპის სიმბოლო)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits ბიტი)';
  }

  @override
  String get setupPasswordWarning =>
      'ეს პაროლი არის თქვენი ანგარიშის აღდგენის ერთადერთი საშუალება. სერვერი არ არსებობს — პაროლის აღდგენა შეუძლებელია. დაიმახსოვრეთ ან ჩაინიშნეთ.';

  @override
  String get setupCreateAccount => 'ანგარიშის შექმნა';

  @override
  String get setupAlreadyHaveAccount => 'უკვე გაქვთ ანგარიში? ';

  @override
  String get setupRestore => 'აღდგენა →';

  @override
  String get restoreTitle => 'ანგარიშის აღდგენა';

  @override
  String get restoreInfoBanner =>
      'შეიყვანეთ თქვენი აღდგენის პაროლი — თქვენი მისამართი (Nostr + Session) ავტომატურად აღდგება. კონტაქტები და შეტყობინებები მხოლოდ ლოკალურად იყო შენახული.';

  @override
  String get restoreNewNickname =>
      'ახალი მეტსახელი (მოგვიანებით შეცვლა შეიძლება)';

  @override
  String get restoreButton => 'ანგარიშის აღდგენა';

  @override
  String get lockTitle => 'Pulse დაბლოკილია';

  @override
  String get lockSubtitle => 'შეიყვანეთ პაროლი გასაგრძელებლად';

  @override
  String get lockPasswordHint => 'პაროლი';

  @override
  String get lockUnlock => 'განბლოკვა';

  @override
  String get lockPanicHint =>
      'დაგავიწყდათ პაროლი? შეიყვანეთ პანიკის გასაღები ყველა მონაცემის წასაშლელად.';

  @override
  String get lockTooManyAttempts =>
      'ძალიან ბევრი მცდელობა. ყველა მონაცემი იშლება…';

  @override
  String get lockWrongPassword => 'არასწორი პაროლი';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'არასწორი პაროლი — $attempts/$max მცდელობა';
  }

  @override
  String get onboardingSkip => 'გამოტოვება';

  @override
  String get onboardingNext => 'შემდეგი';

  @override
  String get onboardingGetStarted => 'დაწყება';

  @override
  String get onboardingWelcomeTitle => 'კეთილი იყოს თქვენი მობრძანება Pulse-ში';

  @override
  String get onboardingWelcomeBody =>
      'დეცენტრალიზებული, ბოლოდან ბოლომდე დაშიფრული მესენჯერი.\n\nცენტრალური სერვერების გარეშე. მონაცემთა შეგროვების გარეშე. უკანა კარების გარეშე.\nთქვენი საუბრები მხოლოდ თქვენია.';

  @override
  String get onboardingTransportTitle => 'ტრანსპორტ-აგნოსტიკური';

  @override
  String get onboardingTransportBody =>
      'გამოიყენეთ Firebase, Nostr ან ორივე ერთდროულად.\n\nშეტყობინებები ქსელებს შორის ავტომატურად მარშრუტდება. ჩაშენებული Tor და I2P მხარდაჭერა ცენზურის წინააღმდეგ.';

  @override
  String get onboardingSignalTitle => 'Signal + პოსტკვანტური';

  @override
  String get onboardingSignalBody =>
      'ყველა შეტყობინება დაშიფრულია Signal პროტოკოლით (Double Ratchet + X3DH) წინმსვლელი საიდუმლოებისთვის.\n\nდამატებით შეფუთული Kyber-1024-ით — NIST სტანდარტის პოსტკვანტური ალგორითმი — მომავლის კვანტური კომპიუტერებისგან დაცვისთვის.';

  @override
  String get onboardingKeysTitle => 'თქვენი გასაღებები თქვენია';

  @override
  String get onboardingKeysBody =>
      'თქვენი იდენტიფიკაციის გასაღებები მოწყობილობას არასოდეს ტოვებს.\n\nSignal თითის ანაბეჭდები კონტაქტების ოფლაინ ვერიფიკაციას საშუალებას იძლევა. TOFU (Trust On First Use) გასაღებების ცვლილებებს ავტომატურად ამოიცნობს.';

  @override
  String get onboardingThemeTitle => 'აირჩიეთ თქვენი სტილი';

  @override
  String get onboardingThemeBody =>
      'აირჩიეთ თემა და აქცენტის ფერი. ამის შეცვლა ნებისმიერ დროს შეგიძლიათ პარამეტრებში.';

  @override
  String get contactsNewChat => 'ახალი ჩატი';

  @override
  String get contactsAddContact => 'კონტაქტის დამატება';

  @override
  String get contactsSearchHint => 'ძიება...';

  @override
  String get contactsNewGroup => 'ახალი ჯგუფი';

  @override
  String get contactsNoContactsYet => 'კონტაქტები ჯერ არ არის';

  @override
  String get contactsAddHint => 'შეეხეთ +-ს მისამართის დასამატებლად';

  @override
  String get contactsNoMatch => 'შესაბამისი კონტაქტები არ არის';

  @override
  String get contactsRemoveTitle => 'კონტაქტის წაშლა';

  @override
  String contactsRemoveMessage(String name) {
    return 'წაშალოთ $name?';
  }

  @override
  String get contactsRemove => 'წაშლა';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ი',
      one: 'ი',
    );
    return '$count კონტაქტ$_temp0';
  }

  @override
  String get bubbleOpenLink => 'ბმულის გახსნა';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'გახსნათ ეს URL ბრაუზერში?\n\n$url';
  }

  @override
  String get bubbleOpen => 'გახსნა';

  @override
  String get bubbleSecurityWarning => 'უსაფრთხოების გაფრთხილება';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" არის შესრულებადი ფაილის ტიპი. მისი შენახვა და გაშვება შეიძლება ზიანი მიაყენოს თქვენს მოწყობილობას. მაინც შეინახოთ?';
  }

  @override
  String get bubbleSaveAnyway => 'მაინც შენახვა';

  @override
  String bubbleSavedTo(String path) {
    return 'შენახულია $path-ში';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'შენახვა ვერ მოხერხდა: $error';
  }

  @override
  String get bubbleNotEncrypted => 'არ არის დაშიფრული';

  @override
  String get bubbleCorruptedImage => '[დაზიანებული სურათი]';

  @override
  String get bubbleReplyPhoto => 'ფოტო';

  @override
  String get bubbleReplyVoice => 'ხმოვანი შეტყობინება';

  @override
  String get bubbleReplyVideo => 'ვიდეო შეტყობინება';

  @override
  String bubbleReadBy(String names) {
    return 'წაკითხულია $names-ის მიერ';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'წაკითხულია $count-ის მიერ';
  }

  @override
  String get chatTileTapToStart => 'შეეხეთ ჩატის დასაწყებად';

  @override
  String get chatTileMessageSent => 'შეტყობინება გაგზავნილია';

  @override
  String get chatTileEncryptedMessage => 'დაშიფრული შეტყობინება';

  @override
  String chatTileYouPrefix(String text) {
    return 'თქვენ: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 ხმოვანი შეტყობინება';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 ხმოვანი შეტყობინება ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'დაშიფრული შეტყობინება';

  @override
  String get groupNewGroup => 'ახალი ჯგუფი';

  @override
  String get groupGroupName => 'ჯგუფის სახელი';

  @override
  String get groupSelectMembers => 'აირჩიეთ წევრები (მინ. 2)';

  @override
  String get groupNoContactsYet =>
      'კონტაქტები ჯერ არ არის. ჯერ დაამატეთ კონტაქტები.';

  @override
  String get groupCreate => 'შექმნა';

  @override
  String get groupLabel => 'ჯგუფი';

  @override
  String get profileVerifyIdentity => 'იდენტობის დადასტურება';

  @override
  String profileVerifyInstructions(String name) {
    return 'შეადარეთ ეს თითის ანაბეჭდები $name-თან ხმოვანი ზარით ან პირადად. თუ ორივე მნიშვნელობა ორივე მოწყობილობაზე ემთხვევა, შეეხეთ \"დადასტურებულად მონიშვნა\"-ს.';
  }

  @override
  String get profileTheirKey => 'მათი გასაღები';

  @override
  String get profileYourKey => 'თქვენი გასაღები';

  @override
  String get profileRemoveVerification => 'ვერიფიკაციის წაშლა';

  @override
  String get profileMarkAsVerified => 'დადასტურებულად მონიშვნა';

  @override
  String get profileAddressCopied => 'მისამართი კოპირებულია';

  @override
  String get profileNoContactsToAdd =>
      'დასამატებელი კონტაქტები არ არის — ყველა უკვე წევრია';

  @override
  String get profileAddMembers => 'წევრების დამატება';

  @override
  String profileAddCount(int count) {
    return 'დამატება ($count)';
  }

  @override
  String get profileRenameGroup => 'ჯგუფის გადარქმევა';

  @override
  String get profileRename => 'გადარქმევა';

  @override
  String get profileRemoveMember => 'წევრის წაშლა?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'წაშალოთ $name ამ ჯგუფიდან?';
  }

  @override
  String get profileKick => 'წაშლა';

  @override
  String get profileSignalFingerprints => 'Signal თითის ანაბეჭდები';

  @override
  String get profileVerified => 'დადასტურებული';

  @override
  String get profileVerify => 'დადასტურება';

  @override
  String get profileEdit => 'რედაქტირება';

  @override
  String get profileNoSession =>
      'სესია ჯერ არ არის დამყარებული — ჯერ გაგზავნეთ შეტყობინება.';

  @override
  String get profileFingerprintCopied => 'თითის ანაბეჭდი კოპირებულია';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ი',
      one: 'ი',
    );
    return '$count წევრ$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'უსაფრთხოების ნომრის დადასტურება';

  @override
  String get profileShowContactQr => 'კონტაქტის QR ჩვენება';

  @override
  String profileContactAddress(String name) {
    return '$name-ის მისამართი';
  }

  @override
  String get profileExportChatHistory => 'ჩატის ისტორიის ექსპორტი';

  @override
  String profileSavedTo(String path) {
    return 'შენახულია $path-ში';
  }

  @override
  String get profileExportFailed => 'ექსპორტი ვერ მოხერხდა';

  @override
  String get profileClearChatHistory => 'ჩატის ისტორიის გასუფთავება';

  @override
  String get profileDeleteGroup => 'ჯგუფის წაშლა';

  @override
  String get profileDeleteContact => 'კონტაქტის წაშლა';

  @override
  String get profileLeaveGroup => 'ჯგუფიდან გასვლა';

  @override
  String get profileLeaveGroupBody =>
      'თქვენ წაიშლებით ამ ჯგუფიდან და ის წაიშლება თქვენი კონტაქტებიდან.';

  @override
  String get groupInviteTitle => 'ჯგუფური მოწვევა';

  @override
  String groupInviteBody(String from, String group) {
    return '$from მოგიწვიათ \"$group\"-ში შესასვლელად';
  }

  @override
  String get groupInviteAccept => 'მიღება';

  @override
  String get groupInviteDecline => 'უარყოფა';

  @override
  String get groupMemberLimitTitle => 'ძალიან ბევრი მონაწილე';

  @override
  String groupMemberLimitBody(int count) {
    return 'ამ ჯგუფში იქნება $count მონაწილე. დაშიფრული მეში ზარები 6-მდე მხარს უჭერს. უფრო დიდი ჯგუფები Jitsi-ზე გადადის (არა E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'მაინც დამატება';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name-მ უარყო \"$group\"-ში შესვლის მოწვევა';
  }

  @override
  String get transferTitle => 'სხვა მოწყობილობაზე გადატანა';

  @override
  String get transferInfoBox =>
      'გადაიტანეთ თქვენი Signal იდენტობა და Nostr გასაღებები ახალ მოწყობილობაზე.\nჩატის სესიები არ გადაიტანება — წინმსვლელი საიდუმლოება დაცულია.';

  @override
  String get transferSendFromThis => 'ამ მოწყობილობიდან გაგზავნა';

  @override
  String get transferSendSubtitle =>
      'ამ მოწყობილობას აქვს გასაღებები. გაუზიარეთ კოდი ახალ მოწყობილობას.';

  @override
  String get transferReceiveOnThis => 'ამ მოწყობილობაზე მიღება';

  @override
  String get transferReceiveSubtitle =>
      'ეს ახალი მოწყობილობაა. შეიყვანეთ კოდი ძველი მოწყობილობიდან.';

  @override
  String get transferChooseMethod => 'გადატანის მეთოდის არჩევა';

  @override
  String get transferLan => 'LAN (იგივე ქსელი)';

  @override
  String get transferLanSubtitle =>
      'სწრაფი, პირდაპირი. ორივე მოწყობილობა ერთ Wi-Fi-ში უნდა იყოს.';

  @override
  String get transferNostrRelay => 'Nostr რელე';

  @override
  String get transferNostrRelaySubtitle =>
      'მუშაობს ნებისმიერ ქსელში არსებული Nostr რელეს მეშვეობით.';

  @override
  String get transferRelayUrl => 'რელეს URL';

  @override
  String get transferEnterCode => 'გადატანის კოდის შეყვანა';

  @override
  String get transferPasteCode => 'ჩასვით LAN:... ან NOS:... კოდი აქ';

  @override
  String get transferConnect => 'დაკავშირება';

  @override
  String get transferGenerating => 'გადატანის კოდის გენერაცია…';

  @override
  String get transferShareCode => 'გაუზიარეთ ეს კოდი მიმღებს:';

  @override
  String get transferCopyCode => 'კოდის კოპირება';

  @override
  String get transferCodeCopied => 'კოდი ბუფერში კოპირებულია';

  @override
  String get transferWaitingReceiver => 'მიმღების დაკავშირების მოლოდინში…';

  @override
  String get transferConnectingSender => 'გამგზავნთან დაკავშირება…';

  @override
  String get transferVerifyBoth =>
      'შეადარეთ ეს კოდი ორივე მოწყობილობაზე.\nთუ ემთხვევა, გადატანა უსაფრთხოა.';

  @override
  String get transferComplete => 'გადატანა დასრულებულია';

  @override
  String get transferKeysImported => 'გასაღებები იმპორტირებულია';

  @override
  String get transferCompleteSenderBody =>
      'თქვენი გასაღებები აქტიური რჩება ამ მოწყობილობაზე.\nმიმღებს ახლა შეუძლია თქვენი იდენტობის გამოყენება.';

  @override
  String get transferCompleteReceiverBody =>
      'გასაღებები წარმატებით იმპორტირდა.\nგადატვირთეთ აპლიკაცია ახალი იდენტობის გამოსაყენებლად.';

  @override
  String get transferRestartApp => 'აპლიკაციის გადატვირთვა';

  @override
  String get transferFailed => 'გადატანა ვერ მოხერხდა';

  @override
  String get transferTryAgain => 'ხელახლა ცდა';

  @override
  String get transferEnterRelayFirst => 'ჯერ შეიყვანეთ რელეს URL';

  @override
  String get transferPasteCodeFromSender => 'ჩასვით გამგზავნის გადატანის კოდი';

  @override
  String get menuReply => 'პასუხი';

  @override
  String get menuForward => 'გადაგზავნა';

  @override
  String get menuReact => 'რეაქცია';

  @override
  String get menuCopy => 'კოპირება';

  @override
  String get menuEdit => 'რედაქტირება';

  @override
  String get menuRetry => 'ხელახლა ცდა';

  @override
  String get menuCancelScheduled => 'დაგეგმილის გაუქმება';

  @override
  String get menuDelete => 'წაშლა';

  @override
  String get menuForwardTo => 'გადაგზავნა…';

  @override
  String menuForwardedTo(String name) {
    return 'გადაგზავნილია $name-ისთვის';
  }

  @override
  String get menuScheduledMessages => 'დაგეგმილი შეტყობინებები';

  @override
  String get menuNoScheduledMessages => 'დაგეგმილი შეტყობინებები არ არის';

  @override
  String menuSendsOn(String date) {
    return 'გაიგზავნება $date-ს';
  }

  @override
  String get menuDisappearingMessages => 'ქრებადი შეტყობინებები';

  @override
  String get menuDisappearingSubtitle =>
      'შეტყობინებები ავტომატურად წაიშლება არჩეული დროის შემდეგ.';

  @override
  String get menuTtlOff => 'გამორთული';

  @override
  String get menuTtl1h => '1 საათი';

  @override
  String get menuTtl24h => '24 საათი';

  @override
  String get menuTtl7d => '7 დღე';

  @override
  String get menuAttachPhoto => 'ფოტო';

  @override
  String get menuAttachFile => 'ფაილი';

  @override
  String get menuAttachVideo => 'ვიდეო';

  @override
  String get mediaTitle => 'მედია';

  @override
  String get mediaFileLabel => 'ფაილი';

  @override
  String mediaPhotosTab(int count) {
    return 'ფოტოები ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'ფაილები ($count)';
  }

  @override
  String get mediaNoPhotos => 'ფოტოები ჯერ არ არის';

  @override
  String get mediaNoFiles => 'ფაილები ჯერ არ არის';

  @override
  String mediaSavedToDownloads(String name) {
    return 'შენახულია ჩამოტვირთვებში/$name';
  }

  @override
  String get mediaFailedToSave => 'ფაილის შენახვა ვერ მოხერხდა';

  @override
  String get statusNewStatus => 'ახალი სტატუსი';

  @override
  String get statusPublish => 'გამოქვეყნება';

  @override
  String get statusExpiresIn24h => 'სტატუსი 24 საათში ამოიწურება';

  @override
  String get statusWhatsOnYourMind => 'რას ფიქრობთ?';

  @override
  String get statusPhotoAttached => 'ფოტო მიმაგრებულია';

  @override
  String get statusAttachPhoto => 'ფოტოს მიმაგრება (არასავალდებულო)';

  @override
  String get statusEnterText => 'გთხოვთ, შეიყვანეთ ტექსტი თქვენი სტატუსისთვის.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'ფოტოს არჩევა ვერ მოხერხდა: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'გამოქვეყნება ვერ მოხერხდა: $error';
  }

  @override
  String get panicSetPanicKey => 'პანიკის გასაღების დაყენება';

  @override
  String get panicEmergencySelfDestruct => 'საგანგებო თვითგანადგურება';

  @override
  String get panicIrreversible => 'ეს მოქმედება შეუქცევადია';

  @override
  String get panicWarningBody =>
      'ამ გასაღების შეყვანა ბლოკირების ეკრანზე დაუყოვნებლივ წაშლის ყველა მონაცემს — შეტყობინებებს, კონტაქტებს, გასაღებებს, იდენტობას. გამოიყენეთ თქვენი ჩვეულებრივი პაროლისგან განსხვავებული გასაღები.';

  @override
  String get panicKeyHint => 'პანიკის გასაღები';

  @override
  String get panicConfirmHint => 'პანიკის გასაღების დადასტურება';

  @override
  String get panicMinChars => 'პანიკის გასაღები მინიმუმ 8 სიმბოლო უნდა იყოს';

  @override
  String get panicKeysDoNotMatch => 'გასაღებები არ ემთხვევა';

  @override
  String get panicSetFailed =>
      'პანიკის გასაღების შენახვა ვერ მოხერხდა — გთხოვთ, ხელახლა სცადოთ';

  @override
  String get passwordSetAppPassword => 'აპლიკაციის პაროლის დაყენება';

  @override
  String get passwordProtectsMessages =>
      'იცავს თქვენს შეტყობინებებს უმოქმედობისას';

  @override
  String get passwordInfoBanner =>
      'საჭიროა Pulse-ის ყოველ გახსნაზე. დავიწყების შემთხვევაში თქვენი მონაცემები აღდგენადი არ იქნება.';

  @override
  String get passwordHint => 'პაროლი';

  @override
  String get passwordConfirmHint => 'პაროლის დადასტურება';

  @override
  String get passwordSetButton => 'პაროლის დაყენება';

  @override
  String get passwordSkipForNow => 'ჯერ გამოტოვება';

  @override
  String get passwordMinChars => 'პაროლი მინიმუმ 6 სიმბოლო უნდა იყოს';

  @override
  String get passwordsDoNotMatch => 'პაროლები არ ემთხვევა';

  @override
  String get profileCardSaved => 'პროფილი შენახულია!';

  @override
  String get profileCardE2eeIdentity => 'E2EE იდენტობა';

  @override
  String get profileCardDisplayName => 'საჩვენებელი სახელი';

  @override
  String get profileCardDisplayNameHint => 'მაგ. გიორგი ბერიძე';

  @override
  String get profileCardAbout => 'შესახებ';

  @override
  String get profileCardSaveProfile => 'პროფილის შენახვა';

  @override
  String get profileCardYourName => 'თქვენი სახელი';

  @override
  String get profileCardAddressCopied => 'მისამართი კოპირებულია!';

  @override
  String get profileCardInboxAddress => 'თქვენი შემომავალი მისამართი';

  @override
  String get profileCardInboxAddresses => 'თქვენი შემომავალი მისამართები';

  @override
  String get profileCardShareAllAddresses =>
      'ყველა მისამართის გაზიარება (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'გაუზიარეთ კონტაქტებს, რომ შეძლონ თქვენთვის წერა.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'ყველა $count მისამართი კოპირებულია ერთ ბმულად!';
  }

  @override
  String get settingsMyProfile => 'ჩემი პროფილი';

  @override
  String get settingsYourInboxAddress => 'თქვენი შემომავალი მისამართი';

  @override
  String get settingsMyQrCode => 'ჩემი QR კოდი';

  @override
  String get settingsMyQrSubtitle => 'მისამართის გაზიარება სკანირებადი QR-ით';

  @override
  String get settingsShareMyAddress => 'ჩემი მისამართის გაზიარება';

  @override
  String get settingsNoAddressYet =>
      'მისამართი ჯერ არ არის — ჯერ შეინახეთ პარამეტრები';

  @override
  String get settingsInviteLink => 'მოწვევის ბმული';

  @override
  String get settingsRawAddress => 'ნედლი მისამართი';

  @override
  String get settingsCopyLink => 'ბმულის კოპირება';

  @override
  String get settingsCopyAddress => 'მისამართის კოპირება';

  @override
  String get settingsInviteLinkCopied => 'მოწვევის ბმული კოპირებულია';

  @override
  String get settingsAppearance => 'გარეგნობა';

  @override
  String get settingsThemeEngine => 'თემის ძრავა';

  @override
  String get settingsThemeEngineSubtitle => 'ფერების და შრიფტების მორგება';

  @override
  String get settingsSignalProtocol => 'Signal პროტოკოლი';

  @override
  String get settingsSignalProtocolSubtitle =>
      'E2EE გასაღებები უსაფრთხოდ ინახება';

  @override
  String get settingsActive => 'აქტიური';

  @override
  String get settingsIdentityBackup => 'იდენტობის სარეზერვო ასლი';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Signal იდენტობის ექსპორტი ან იმპორტი';

  @override
  String get settingsIdentityBackupBody =>
      'გაიტანეთ თქვენი Signal იდენტობის გასაღებები სარეზერვო კოდში, ან აღადგინეთ არსებულიდან.';

  @override
  String get settingsTransferDevice => 'სხვა მოწყობილობაზე გადატანა';

  @override
  String get settingsTransferDeviceSubtitle =>
      'იდენტობის გადატანა LAN-ით ან Nostr რელეთი';

  @override
  String get settingsExportIdentity => 'იდენტობის ექსპორტი';

  @override
  String get settingsExportIdentityBody =>
      'კოპირეთ ეს სარეზერვო კოდი და შეინახეთ უსაფრთხოდ:';

  @override
  String get settingsSaveFile => 'ფაილის შენახვა';

  @override
  String get settingsImportIdentity => 'იდენტობის იმპორტი';

  @override
  String get settingsImportIdentityBody =>
      'ჩასვით თქვენი სარეზერვო კოდი ქვემოთ. ეს გადაწერს თქვენს ამჟამინდელ იდენტობას.';

  @override
  String get settingsPasteBackupCode => 'ჩასვით სარეზერვო კოდი აქ…';

  @override
  String get settingsIdentityImported =>
      'იდენტობა + კონტაქტები იმპორტირებულია! გადატვირთეთ აპლიკაცია გამოსაყენებლად.';

  @override
  String get settingsSecurity => 'უსაფრთხოება';

  @override
  String get settingsAppPassword => 'აპლიკაციის პაროლი';

  @override
  String get settingsPasswordEnabled => 'ჩართულია — საჭიროა ყოველ გაშვებაზე';

  @override
  String get settingsPasswordDisabled =>
      'გამორთულია — აპლიკაცია პაროლის გარეშე იხსნება';

  @override
  String get settingsChangePassword => 'პაროლის შეცვლა';

  @override
  String get settingsChangePasswordSubtitle =>
      'აპლიკაციის ბლოკირების პაროლის განახლება';

  @override
  String get settingsSetPanicKey => 'პანიკის გასაღების დაყენება';

  @override
  String get settingsChangePanicKey => 'პანიკის გასაღების შეცვლა';

  @override
  String get settingsPanicKeySetSubtitle =>
      'საგანგებო წაშლის გასაღების განახლება';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'ერთი გასაღები, რომელიც მყისიერად წაშლის ყველა მონაცემს';

  @override
  String get settingsRemovePanicKey => 'პანიკის გასაღების წაშლა';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'საგანგებო თვითგანადგურების გამორთვა';

  @override
  String get settingsRemovePanicKeyBody =>
      'საგანგებო თვითგანადგურება გამოირთვება. ნებისმიერ დროს შეგიძლიათ ხელახლა ჩართვა.';

  @override
  String get settingsDisableAppPassword => 'აპლიკაციის პაროლის გამორთვა';

  @override
  String get settingsEnterCurrentPassword =>
      'დადასტურებისთვის შეიყვანეთ ამჟამინდელი პაროლი';

  @override
  String get settingsCurrentPassword => 'ამჟამინდელი პაროლი';

  @override
  String get settingsIncorrectPassword => 'არასწორი პაროლი';

  @override
  String get settingsPasswordUpdated => 'პაროლი განახლებულია';

  @override
  String get settingsChangePasswordProceed =>
      'გასაგრძელებლად შეიყვანეთ ამჟამინდელი პაროლი';

  @override
  String get settingsData => 'მონაცემები';

  @override
  String get settingsBackupMessages => 'შეტყობინებების სარეზერვო ასლი';

  @override
  String get settingsBackupMessagesSubtitle =>
      'დაშიფრული შეტყობინებების ისტორიის ექსპორტი ფაილში';

  @override
  String get settingsRestoreMessages => 'შეტყობინებების აღდგენა';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'შეტყობინებების იმპორტი სარეზერვო ფაილიდან';

  @override
  String get settingsExportKeys => 'გასაღებების ექსპორტი';

  @override
  String get settingsExportKeysSubtitle =>
      'იდენტობის გასაღებების შენახვა დაშიფრულ ფაილში';

  @override
  String get settingsImportKeys => 'გასაღებების იმპორტი';

  @override
  String get settingsImportKeysSubtitle =>
      'იდენტობის გასაღებების აღდგენა ექსპორტირებული ფაილიდან';

  @override
  String get settingsBackupPassword => 'სარეზერვო პაროლი';

  @override
  String get settingsPasswordCannotBeEmpty => 'პაროლი ცარიელი არ შეიძლება იყოს';

  @override
  String get settingsPasswordMin4Chars => 'პაროლი მინიმუმ 4 სიმბოლო უნდა იყოს';

  @override
  String get settingsCallsTurn => 'ზარები & TURN';

  @override
  String get settingsLocalNetwork => 'ლოკალური ქსელი';

  @override
  String get settingsCensorshipResistance => 'ცენზურის წინააღმდეგობა';

  @override
  String get settingsNetwork => 'ქსელი';

  @override
  String get settingsProxyTunnels => 'პროქსი & ტუნელები';

  @override
  String get settingsTurnServers => 'TURN სერვერები';

  @override
  String get settingsProviderTitle => 'პროვაიდერი';

  @override
  String get settingsLanFallback => 'LAN სარეზერვო';

  @override
  String get settingsLanFallbackSubtitle =>
      'ინტერნეტის არარსებობისას ლოკალურ ქსელში პრეზენციის გავრცელება და შეტყობინებების მიწოდება. არანდობილ ქსელებში (საჯარო Wi-Fi) გამორთეთ.';

  @override
  String get settingsBgDelivery => 'ფონური მიწოდება';

  @override
  String get settingsBgDeliverySubtitle =>
      'აპლიკაციის მინიმიზებისას შეტყობინებების მიღების გაგრძელება. აჩვენებს მუდმივ შეტყობინებას.';

  @override
  String get settingsYourInboxProvider => 'თქვენი შემომავალი პროვაიდერი';

  @override
  String get settingsConnectionDetails => 'კავშირის დეტალები';

  @override
  String get settingsSaveAndConnect => 'შენახვა & დაკავშირება';

  @override
  String get settingsSecondaryInboxes => 'მეორადი შემომავალი';

  @override
  String get settingsAddSecondaryInbox => 'მეორადი შემომავალის დამატება';

  @override
  String get settingsAdvanced => 'გაფართოებული';

  @override
  String get settingsDiscover => 'აღმოჩენა';

  @override
  String get settingsAbout => 'შესახებ';

  @override
  String get settingsPrivacyPolicy => 'კონფიდენციალურობის პოლიტიკა';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'როგორ იცავს Pulse თქვენს მონაცემებს';

  @override
  String get settingsCrashReporting => 'ავარიის ანგარიშგება';

  @override
  String get settingsCrashReportingSubtitle =>
      'ანონიმური ავარიის ანგარიშების გაგზავნა Pulse-ის გასაუმჯობესებლად. შეტყობინებების შინაარსი ან კონტაქტები არასოდეს იგზავნება.';

  @override
  String get settingsCrashReportingEnabled =>
      'ავარიის ანგარიშგება ჩართულია — გადატვირთეთ აპლიკაცია გამოსაყენებლად';

  @override
  String get settingsCrashReportingDisabled =>
      'ავარიის ანგარიშგება გამორთულია — გადატვირთეთ აპლიკაცია გამოსაყენებლად';

  @override
  String get settingsSensitiveOperation => 'მგრძნობიარე ოპერაცია';

  @override
  String get settingsSensitiveOperationBody =>
      'ეს გასაღებები თქვენი იდენტობაა. ამ ფაილის მფლობელს შეუძლია თქვენი იმპერსონაცია. შეინახეთ უსაფრთხოდ და გადატანის შემდეგ წაშალეთ.';

  @override
  String get settingsIUnderstandContinue => 'მესმის, გაგრძელება';

  @override
  String get settingsReplaceIdentity => 'იდენტობის ჩანაცვლება?';

  @override
  String get settingsReplaceIdentityBody =>
      'ეს გადაწერს თქვენს ამჟამინდელ იდენტობის გასაღებებს. თქვენი არსებული Signal სესიები გაუქმდება და კონტაქტებს დაშიფვრის ხელახლა დამყარება დასჭირდებათ. აპლიკაციის გადატვირთვა საჭირო იქნება.';

  @override
  String get settingsReplaceKeys => 'გასაღებების ჩანაცვლება';

  @override
  String get settingsKeysImported => 'გასაღებები იმპორტირებულია';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count გასაღები წარმატებით იმპორტირდა. გთხოვთ, გადატვირთოთ აპლიკაცია ახალი იდენტობით ინიციალიზაციისთვის.';
  }

  @override
  String get settingsRestartNow => 'ახლავე გადატვირთვა';

  @override
  String get settingsLater => 'მოგვიანებით';

  @override
  String get profileGroupLabel => 'ჯგუფი';

  @override
  String get profileAddButton => 'დამატება';

  @override
  String get profileKickButton => 'წაშლა';

  @override
  String get dataSectionTitle => 'მონაცემები';

  @override
  String get dataBackupMessages => 'შეტყობინებების სარეზერვო ასლი';

  @override
  String get dataBackupPasswordSubtitle =>
      'აირჩიეთ პაროლი თქვენი სარეზერვო ასლის დასაშიფრად.';

  @override
  String get dataBackupConfirmLabel => 'სარეზერვო ასლის შექმნა';

  @override
  String get dataCreatingBackup => 'სარეზერვო ასლი იქმნება';

  @override
  String get dataBackupPreparing => 'მომზადება...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'შეტყობინება $done / $total ექსპორტდება...';
  }

  @override
  String get dataBackupSavingFile => 'ფაილი ინახება...';

  @override
  String get dataSaveMessageBackupDialog =>
      'შეტყობინებების სარეზერვო ასლის შენახვა';

  @override
  String dataBackupSaved(int count, String path) {
    return 'სარეზერვო ასლი შენახულია ($count შეტყობინება)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'სარეზერვო ასლი ვერ შეიქმნა — მონაცემები არ ექსპორტდა';

  @override
  String dataBackupFailedError(String error) {
    return 'სარეზერვო ასლი ვერ შეიქმნა: $error';
  }

  @override
  String get dataSelectMessageBackupDialog =>
      'შეტყობინებების სარეზერვო ასლის არჩევა';

  @override
  String get dataInvalidBackupFile =>
      'არასწორი სარეზერვო ფაილი (ძალიან პატარა)';

  @override
  String get dataNotValidBackupFile => 'არავალიდური Pulse სარეზერვო ფაილი';

  @override
  String get dataRestoreMessages => 'შეტყობინებების აღდგენა';

  @override
  String get dataRestorePasswordSubtitle =>
      'შეიყვანეთ პაროლი, რომელიც ამ სარეზერვო ასლის შექმნისას გამოიყენეთ.';

  @override
  String get dataRestoreConfirmLabel => 'აღდგენა';

  @override
  String get dataRestoringMessages => 'შეტყობინებები აღდგება';

  @override
  String get dataRestoreDecrypting => 'გაშიფვრა...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'შეტყობინება $done / $total იმპორტდება...';
  }

  @override
  String get dataRestoreFailed =>
      'აღდგენა ვერ მოხერხდა — არასწორი პაროლი ან დაზიანებული ფაილი';

  @override
  String dataRestoreSuccess(int count) {
    return 'აღდგენილია $count ახალი შეტყობინება';
  }

  @override
  String get dataRestoreNothingNew =>
      'ახალი შეტყობინებები იმპორტისთვის არ არის (ყველა უკვე არსებობს)';

  @override
  String dataRestoreFailedError(String error) {
    return 'აღდგენა ვერ მოხერხდა: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'გასაღებების ექსპორტის არჩევა';

  @override
  String get dataNotValidKeyFile =>
      'არავალიდური Pulse გასაღებების ექსპორტის ფაილი';

  @override
  String get dataExportKeys => 'გასაღებების ექსპორტი';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'აირჩიეთ პაროლი თქვენი გასაღებების ექსპორტის დასაშიფრად.';

  @override
  String get dataExportKeysConfirmLabel => 'ექსპორტი';

  @override
  String get dataExportingKeys => 'გასაღებები ექსპორტდება';

  @override
  String get dataExportingKeysStatus => 'იდენტობის გასაღებების დაშიფვრა...';

  @override
  String get dataSaveKeyExportDialog => 'გასაღებების ექსპორტის შენახვა';

  @override
  String dataKeysExportedTo(String path) {
    return 'გასაღებები ექსპორტირებულია:\n$path';
  }

  @override
  String get dataExportFailed =>
      'ექსპორტი ვერ მოხერხდა — გასაღებები ვერ მოიძებნა';

  @override
  String dataExportFailedError(String error) {
    return 'ექსპორტი ვერ მოხერხდა: $error';
  }

  @override
  String get dataImportKeys => 'გასაღებების იმპორტი';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'შეიყვანეთ პაროლი, რომელიც ამ გასაღებების ექსპორტის დასაშიფრად გამოიყენეთ.';

  @override
  String get dataImportKeysConfirmLabel => 'იმპორტი';

  @override
  String get dataImportingKeys => 'გასაღებები იმპორტდება';

  @override
  String get dataImportingKeysStatus => 'იდენტობის გასაღებების გაშიფვრა...';

  @override
  String get dataImportFailed =>
      'იმპორტი ვერ მოხერხდა — არასწორი პაროლი ან დაზიანებული ფაილი';

  @override
  String dataImportFailedError(String error) {
    return 'იმპორტი ვერ მოხერხდა: $error';
  }

  @override
  String get securitySectionTitle => 'უსაფრთხოება';

  @override
  String get securityIncorrectPassword => 'არასწორი პაროლი';

  @override
  String get securityPasswordUpdated => 'პაროლი განახლებულია';

  @override
  String get appearanceSectionTitle => 'გარეგნობა';

  @override
  String appearanceExportFailed(String error) {
    return 'ექსპორტი ვერ მოხერხდა: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'შენახულია $path-ში';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'შენახვა ვერ მოხერხდა: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'იმპორტი ვერ მოხერხდა: $error';
  }

  @override
  String get aboutSectionTitle => 'შესახებ';

  @override
  String get providerPublicKey => 'საჯარო გასაღები';

  @override
  String get providerRelay => 'რელე';

  @override
  String get providerAutoConfigured =>
      'ავტომატურად კონფიგურირებული თქვენი აღდგენის პაროლიდან. რელე ავტომატურად აღმოჩენილია.';

  @override
  String get providerKeyStoredLocally =>
      'თქვენი გასაღები ლოკალურად ინახება უსაფრთხო საცავში — არასოდეს იგზავნება სერვერზე.';

  @override
  String get providerSessionInfo =>
      'Session Network — ხახვის მარშრუტიზაციით E2EE. თქვენი Session ID ავტომატურად იქმნება და უსაფრთხოდ ინახება. კვანძები ავტომატურად აღმოჩენილია ჩაშენებული seed კვანძებიდან.';

  @override
  String get providerAdvanced => 'გაფართოებული';

  @override
  String get providerSaveAndConnect => 'შენახვა & დაკავშირება';

  @override
  String get providerAddSecondaryInbox => 'მეორადი შემომავალის დამატება';

  @override
  String get providerSecondaryInboxes => 'მეორადი შემომავალი';

  @override
  String get providerYourInboxProvider => 'თქვენი შემომავალი პროვაიდერი';

  @override
  String get providerConnectionDetails => 'კავშირის დეტალები';

  @override
  String get addContactTitle => 'კონტაქტის დამატება';

  @override
  String get addContactInviteLinkLabel => 'მოწვევის ბმული ან მისამართი';

  @override
  String get addContactTapToPaste => 'შეეხეთ მოწვევის ბმულის ჩასასვლელად';

  @override
  String get addContactPasteTooltip => 'ბუფერიდან ჩასმა';

  @override
  String get addContactAddressDetected => 'კონტაქტის მისამართი ამოცნობილია';

  @override
  String addContactRoutesDetected(int count) {
    return '$count მარშრუტი ამოცნობილია — SmartRouter ყველაზე სწრაფს ირჩევს';
  }

  @override
  String get addContactFetchingProfile => 'პროფილის მოძიება…';

  @override
  String addContactProfileFound(String name) {
    return 'ნაპოვნია: $name';
  }

  @override
  String get addContactNoProfileFound => 'პროფილი ვერ მოიძებნა';

  @override
  String get addContactDisplayNameLabel => 'საჩვენებელი სახელი';

  @override
  String get addContactDisplayNameHint => 'როგორ გინდათ მას დაუძახოთ?';

  @override
  String get addContactAddManually => 'მისამართის ხელით შეყვანა';

  @override
  String get addContactButton => 'კონტაქტის დამატება';

  @override
  String get networkDiagnosticsTitle => 'ქსელის დიაგნოსტიკა';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr რელეები';

  @override
  String get networkDiagnosticsDirect => 'პირდაპირი';

  @override
  String get networkDiagnosticsTorOnly => 'მხოლოდ Tor';

  @override
  String get networkDiagnosticsBest => 'საუკეთესო';

  @override
  String get networkDiagnosticsNone => 'არცერთი';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'სტატუსი';

  @override
  String get networkDiagnosticsConnected => 'დაკავშირებული';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'დაკავშირება $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'გამორთული';

  @override
  String get networkDiagnosticsTransport => 'ტრანსპორტი';

  @override
  String get networkDiagnosticsInfrastructure => 'ინფრასტრუქტურა';

  @override
  String get networkDiagnosticsSessionNodes => 'Session კვანძები';

  @override
  String get networkDiagnosticsTurnServers => 'TURN სერვერები';

  @override
  String get networkDiagnosticsLastProbe => 'ბოლო შემოწმება';

  @override
  String get networkDiagnosticsRunning => 'მიმდინარეობს...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'დიაგნოსტიკის გაშვება';

  @override
  String get networkDiagnosticsForceReprobe =>
      'სრული ხელახალი შემოწმების იძულება';

  @override
  String get networkDiagnosticsJustNow => 'ახლახანს';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes წთ-ის წინ';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours სთ-ის წინ';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days დღ-ის წინ';
  }

  @override
  String get homeNoEch => 'ECH არ არის';

  @override
  String get homeNoEchTooltip =>
      'uTLS პროქსი მიუწვდომელია — ECH გამორთულია.\nTLS თითის ანაბეჭდი DPI-სთვის ხილულია.';

  @override
  String get settingsTitle => 'პარამეტრები';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'შენახულია & დაკავშირებულია $provider-თან';
  }

  @override
  String get settingsTorFailedToStart => 'ჩაშენებულმა Tor-მა ვერ ჩაირთო';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon-მა ვერ ჩაირთო';

  @override
  String get verifyTitle => 'უსაფრთხოების ნომრის დადასტურება';

  @override
  String get verifyIdentityVerified => 'იდენტობა დადასტურებულია';

  @override
  String get verifyNotYetVerified => 'ჯერ არ არის დადასტურებული';

  @override
  String verifyVerifiedDescription(String name) {
    return 'თქვენ დაადასტურეთ $name-ის უსაფრთხოების ნომერი.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'შეადარეთ ეს ნომრები $name-თან პირადად ან სანდო არხით.';
  }

  @override
  String get verifyExplanation =>
      'ყველა საუბარს აქვს უნიკალური უსაფრთხოების ნომერი. თუ ორივე თქვენგანი ერთნაირ ნომრებს ხედავთ თქვენს მოწყობილობებზე, თქვენი კავშირი ბოლოდან ბოლომდე ვერიფიცირებულია.';

  @override
  String verifyContactKey(String name) {
    return '$name-ის გასაღები';
  }

  @override
  String get verifyYourKey => 'თქვენი გასაღები';

  @override
  String get verifyRemoveVerification => 'ვერიფიკაციის წაშლა';

  @override
  String get verifyMarkAsVerified => 'დადასტურებულად მონიშვნა';

  @override
  String verifyAfterReinstall(String name) {
    return 'თუ $name აპლიკაციას ხელახლა დააინსტალირებს, უსაფრთხოების ნომერი შეიცვლება და ვერიფიკაცია ავტომატურად წაიშლება.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'მონიშნეთ როგორც დადასტურებული მხოლოდ $name-თან ნომრების შედარების შემდეგ ხმოვანი ზარით ან პირადად.';
  }

  @override
  String get verifyNoSession =>
      'დაშიფვრის სესია ჯერ არ არის დამყარებული. ჯერ გაგზავნეთ შეტყობინება უსაფრთხოების ნომრების გენერაციისთვის.';

  @override
  String get verifyNoKeyAvailable => 'გასაღები არ არის ხელმისაწვდომი';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label თითის ანაბეჭდი კოპირებულია';
  }

  @override
  String get providerDatabaseUrlLabel => 'მონაცემთა ბაზის URL';

  @override
  String get providerOptionalHint => 'არასავალდებულო';

  @override
  String get providerWebApiKeyLabel => 'Web API გასაღები';

  @override
  String get providerOptionalForPublicDb =>
      'არასავალდებულო საჯარო მონაცემთა ბაზისთვის';

  @override
  String get providerRelayUrlLabel => 'რელეს URL';

  @override
  String get providerPrivateKeyLabel => 'პირადი გასაღები';

  @override
  String get providerPrivateKeyNsecLabel => 'პირადი გასაღები (nsec)';

  @override
  String get providerStorageNodeLabel => 'საცავის კვანძის URL (არასავალდებულო)';

  @override
  String get providerStorageNodeHint =>
      'დატოვეთ ცარიელი ჩაშენებული seed კვანძებისთვის';

  @override
  String get transferInvalidCodeFormat =>
      'უცნობი კოდის ფორმატი — უნდა იწყებოდეს LAN: ან NOS:-ით';

  @override
  String get profileCardFingerprintCopied => 'თითის ანაბეჭდი კოპირებულია';

  @override
  String get profileCardAboutHint => 'კონფიდენციალურობა უპირველეს ყოვლისა 🔒';

  @override
  String get profileCardSaveButton => 'პროფილის შენახვა';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'დაშიფრული შეტყობინებების, კონტაქტების და ავატარების ექსპორტი ფაილში';

  @override
  String get callVideo => 'ვიდეო';

  @override
  String get callAudio => 'აუდიო';

  @override
  String bubbleDeliveredTo(String names) {
    return 'მიწოდებულია $names-ისთვის';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'მიწოდებულია $count-ისთვის';
  }

  @override
  String get groupStatusDialogTitle => 'შეტყობინების ინფო';

  @override
  String get groupStatusRead => 'წაკითხული';

  @override
  String get groupStatusDelivered => 'მიწოდებული';

  @override
  String get groupStatusPending => 'მოლოდინში';

  @override
  String get groupStatusNoData => 'მიწოდების ინფორმაცია ჯერ არ არის';

  @override
  String get profileTransferAdmin => 'ადმინად დანიშვნა';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'დანიშნოთ $name ახალ ადმინად?';
  }

  @override
  String get profileTransferAdminBody =>
      'თქვენ დაკარგავთ ადმინის უფლებებს. ეს შეუქცევადია.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name ახლა ადმინია';
  }

  @override
  String get profileAdminBadge => 'ადმინი';

  @override
  String get privacyPolicyTitle => 'კონფიდენციალურობის პოლიტიკა';

  @override
  String get privacyOverviewHeading => 'მიმოხილვა';

  @override
  String get privacyOverviewBody =>
      'Pulse არის უსერვერო, ბოლოდან ბოლომდე დაშიფრული მესენჯერი. თქვენი კონფიდენციალურობა არ არის მხოლოდ ფუნქცია — ეს არის არქიტექტურა. Pulse სერვერები არ არსებობს. ანგარიშები არსად ინახება. მონაცემები დეველოპერების მიერ არ გროვდება, არ გადაიცემა და არ ინახება.';

  @override
  String get privacyDataCollectionHeading => 'მონაცემთა შეგროვება';

  @override
  String get privacyDataCollectionBody =>
      'Pulse ნულოვან პერსონალურ მონაცემებს აგროვებს. კონკრეტულად:\n\n- ელფოსტა, ტელეფონის ნომერი ან ნამდვილი სახელი არ არის საჭირო\n- ანალიტიკა, თვალთვალი ან ტელემეტრია არ არის\n- სარეკლამო იდენტიფიკატორები არ არის\n- კონტაქტების სიაზე წვდომა არ არის\n- ღრუბლოვანი სარეზერვო ასლები არ არის (შეტყობინებები მხოლოდ თქვენს მოწყობილობაზე არსებობს)\n- მეტამონაცემები Pulse სერვერზე არ იგზავნება (ისინი არ არსებობს)';

  @override
  String get privacyEncryptionHeading => 'დაშიფვრა';

  @override
  String get privacyEncryptionBody =>
      'ყველა შეტყობინება დაშიფრულია Signal პროტოკოლით (Double Ratchet X3DH გასაღებების შეთანხმებით). დაშიფვრის გასაღებები ექსკლუზიურად თქვენს მოწყობილობაზე გენერირდება და ინახება. ვერავინ — დეველოპერების ჩათვლით — ვერ წაიკითხავს თქვენს შეტყობინებებს.';

  @override
  String get privacyNetworkHeading => 'ქსელის არქიტექტურა';

  @override
  String get privacyNetworkBody =>
      'Pulse იყენებს ფედერალურ ტრანსპორტის ადაპტერებს (Nostr რელეები, Session/Oxen სერვის კვანძები, Firebase Realtime Database, LAN). ეს ტრანსპორტები მხოლოდ დაშიფრულ შიფრტექსტს ატარებს. რელეს ოპერატორებს შეუძლიათ თქვენი IP მისამართისა და ტრაფიკის მოცულობის ნახვა, მაგრამ შეტყობინების შინაარსის გაშიფვრა არ შეუძლიათ.\n\nTor-ის ჩართვისას, თქვენი IP მისამართი რელეს ოპერატორებისგანაც იმალება.';

  @override
  String get privacyStunHeading => 'STUN/TURN სერვერები';

  @override
  String get privacyStunBody =>
      'ხმოვანი და ვიდეოზარები იყენებს WebRTC-ს DTLS-SRTP დაშიფვრით. STUN სერვერები (თქვენი საჯარო IP-ის აღმოჩენისთვის P2P კავშირებისთვის) და TURN სერვერები (მედიის რელეისთვის პირდაპირი კავშირის წარუმატებლობისას) ხედავენ თქვენს IP მისამართსა და ზარის ხანგრძლივობას, მაგრამ ზარის შინაარსის გაშიფვრა არ შეუძლიათ.\n\nმაქსიმალური კონფიდენციალურობისთვის პარამეტრებში შეგიძლიათ საკუთარი TURN სერვერის კონფიგურაცია.';

  @override
  String get privacyCrashHeading => 'ავარიის ანგარიშგება';

  @override
  String get privacyCrashBody =>
      'თუ Sentry ავარიის ანგარიშგება ჩართულია (SENTRY_DSN-ით აწყობის დროს), ანონიმური ავარიის ანგარიშები შეიძლება გაიგზავნოს. ისინი არ შეიცავს შეტყობინების შინაარსს, კონტაქტის ინფორმაციას ან პერსონალურად ამოცნობად ინფორმაციას. ავარიის ანგარიშგების გამორთვა შესაძლებელია აწყობის დროს DSN-ის გამოტოვებით.';

  @override
  String get privacyPasswordHeading => 'პაროლი & გასაღებები';

  @override
  String get privacyPasswordBody =>
      'თქვენი აღდგენის პაროლი გამოიყენება კრიპტოგრაფიული გასაღებების გამოსათვლელად Argon2id-ის (მეხსიერება-მძიმე KDF) მეშვეობით. პაროლი არასოდეს გადადის არსად. პაროლის დაკარგვის შემთხვევაში ანგარიშის აღდგენა შეუძლებელია — სერვერი არ არსებობს მის აღსადგენად.';

  @override
  String get privacyFontsHeading => 'შრიფტები';

  @override
  String get privacyFontsBody =>
      'Pulse ყველა შრიფტს ლოკალურად შეიცავს. Google Fonts-ზე ან გარე შრიფტის სერვისებზე მოთხოვნები არ იგზავნება.';

  @override
  String get privacyThirdPartyHeading => 'მესამე მხარის სერვისები';

  @override
  String get privacyThirdPartyBody =>
      'Pulse არ ინტეგრირდება სარეკლამო ქსელებთან, ანალიტიკის პროვაიდერებთან, სოციალური მედიის პლატფორმებთან ან მონაცემთა ბროკერებთან. ერთადერთი ქსელის კავშირები არის თქვენ მიერ კონფიგურირებულ ტრანსპორტის რელეებთან.';

  @override
  String get privacyOpenSourceHeading => 'ღია კოდი';

  @override
  String get privacyOpenSourceBody =>
      'Pulse არის ღია კოდის პროგრამა. შეგიძლიათ სრული წყარო კოდის აუდიტი ამ კონფიდენციალურობის განცხადებების შესამოწმებლად.';

  @override
  String get privacyContactHeading => 'კონტაქტი';

  @override
  String get privacyContactBody =>
      'კონფიდენციალურობასთან დაკავშირებული კითხვებისთვის გახსენით issue პროექტის რეპოზიტორიაში.';

  @override
  String get privacyLastUpdated => 'ბოლო განახლება: მარტი 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'შენახვა ვერ მოხერხდა: $error';
  }

  @override
  String get themeEngineTitle => 'თემის ძრავა';

  @override
  String get torBuiltInTitle => 'ჩაშენებული Tor';

  @override
  String get torConnectedSubtitle =>
      'დაკავშირებული — Nostr მარშრუტდება 127.0.0.1:9250-ით';

  @override
  String torConnectingSubtitle(int pct) {
    return 'დაკავშირება… $pct%';
  }

  @override
  String get torNotRunning => 'არ მუშაობს — შეეხეთ გადამრთველს გადასატვირთად';

  @override
  String get torDescription =>
      'Nostr-ის მარშრუტიზაცია Tor-ით (Snowflake ცენზურირებული ქსელებისთვის)';

  @override
  String get torNetworkDiagnostics => 'ქსელის დიაგნოსტიკა';

  @override
  String get torTransportLabel => 'ტრანსპორტი: ';

  @override
  String get torPtAuto => 'ავტო';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'ჩვეულებრივი';

  @override
  String get torTimeoutLabel => 'დროის ლიმიტი: ';

  @override
  String get torInfoDescription =>
      'ჩართვისას, Nostr WebSocket კავშირები Tor-ით (SOCKS5) მარშრუტდება. Tor Browser უსმენს 127.0.0.1:9150-ზე. დამოუკიდებელი Tor დემონი იყენებს პორტ 9050-ს. Firebase კავშირებზე არ მოქმედებს.';

  @override
  String get torRouteNostrTitle => 'Nostr-ის მარშრუტიზაცია Tor-ით';

  @override
  String get torManagedByBuiltin => 'იმართება ჩაშენებული Tor-ით';

  @override
  String get torActiveRouting => 'აქტიურია — Nostr ტრაფიკი Tor-ით მარშრუტდება';

  @override
  String get torDisabled => 'გამორთულია';

  @override
  String get torProxySocks5 => 'Tor პროქსი (SOCKS5)';

  @override
  String get torProxyHostLabel => 'პროქსის ჰოსტი';

  @override
  String get torProxyPortLabel => 'პორტი';

  @override
  String get torPortInfo =>
      'Tor Browser: პორტი 9150  •  Tor დემონი: პორტი 9050';

  @override
  String get i2pProxySocks5 => 'I2P პროქსი (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P ნაგულისხმევად იყენებს SOCKS5-ს პორტ 4447-ზე. დაუკავშირდით Nostr რელეს I2P outproxy-ით (მაგ. relay.damus.i2p) ნებისმიერ ტრანსპორტზე მომხმარებლებთან კომუნიკაციისთვის. Tor-ს აქვს პრიორიტეტი, როცა ორივე ჩართულია.';

  @override
  String get i2pRouteNostrTitle => 'Nostr-ის მარშრუტიზაცია I2P-ით';

  @override
  String get i2pActiveRouting => 'აქტიურია — Nostr ტრაფიკი I2P-ით მარშრუტდება';

  @override
  String get i2pDisabled => 'გამორთულია';

  @override
  String get i2pProxyHostLabel => 'პროქსის ჰოსტი';

  @override
  String get i2pProxyPortLabel => 'პორტი';

  @override
  String get i2pPortInfo => 'I2P როუტერის ნაგულისხმევი SOCKS5 პორტი: 4447';

  @override
  String get customProxySocks5 => 'საბაჟო პროქსი (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker რელე';

  @override
  String get customProxyInfoDescription =>
      'საბაჟო პროქსი ტრაფიკს თქვენი V2Ray/Xray/Shadowsocks-ით ამისამართებს. CF Worker მოქმედებს როგორც პერსონალური რელე პროქსი Cloudflare CDN-ზე — GFW ხედავს *.workers.dev-ს, არა ნამდვილ რელეს.';

  @override
  String get customSocks5ProxyTitle => 'საბაჟო SOCKS5 პროქსი';

  @override
  String get customProxyActive => 'აქტიურია — ტრაფიკი SOCKS5-ით მარშრუტდება';

  @override
  String get customProxyDisabled => 'გამორთულია';

  @override
  String get customProxyHostLabel => 'პროქსის ჰოსტი';

  @override
  String get customProxyPortLabel => 'პორტი';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker დომენი (არასავალდებულო)';

  @override
  String get customWorkerHelpTitle => 'როგორ განათავსოთ CF Worker რელე (უფასო)';

  @override
  String get customWorkerScriptCopied => 'სკრიპტი კოპირებულია!';

  @override
  String get customWorkerStep1 =>
      '1. გადადით dash.cloudflare.com → Workers & Pages\n2. Create Worker → ჩასვით ეს სკრიპტი:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → კოპირეთ დომენი (მაგ. my-relay.user.workers.dev)\n4. ჩასვით დომენი ზემოთ → შენახვა\n\nაპლიკაცია ავტომატურად უკავშირდება: wss://domain/?r=relay_url\nGFW ხედავს: კავშირი *.workers.dev-თან (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'დაკავშირებული — SOCKS5 127.0.0.1:$port-ზე';
  }

  @override
  String get psiphonConnecting => 'დაკავშირება…';

  @override
  String get psiphonNotRunning =>
      'არ მუშაობს — შეეხეთ გადამრთველს გადასატვირთად';

  @override
  String get psiphonDescription =>
      'სწრაფი ტუნელი (~3წმ ჩატვირთვა, 2000+ მბრუნავი VPS)';

  @override
  String get turnCommunityServers => 'საზოგადოების TURN სერვერები';

  @override
  String get turnCustomServer => 'საბაჟო TURN სერვერი (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN სერვერები მხოლოდ უკვე დაშიფრულ ნაკადებს ამისამართებს (DTLS-SRTP). რელეს ოპერატორი ხედავს თქვენს IP-ს და ტრაფიკის მოცულობას, მაგრამ ზარების გაშიფვრა არ შეუძლია. TURN გამოიყენება მხოლოდ პირდაპირი P2P-ის წარუმატებლობისას (კავშირების ~15–20%).';

  @override
  String get turnFreeLabel => 'უფასო';

  @override
  String get turnServerUrlLabel => 'TURN სერვერის URL';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 ან turns:...';

  @override
  String get turnUsernameLabel => 'მომხმარებლის სახელი';

  @override
  String get turnPasswordLabel => 'პაროლი';

  @override
  String get turnOptionalHint => 'არასავალდებულო';

  @override
  String get turnCustomInfo =>
      'გაუშვით coturn ნებისმიერ \$5/თვე VPS-ზე მაქსიმალური კონტროლისთვის. მონაცემები ლოკალურად ინახება.';

  @override
  String get themePickerAppearance => 'გარეგნობა';

  @override
  String get themePickerAccentColor => 'აქცენტის ფერი';

  @override
  String get themeModeLight => 'ნათელი';

  @override
  String get themeModeDark => 'მუქი';

  @override
  String get themeModeSystem => 'სისტემური';

  @override
  String get themeDynamicPresets => 'შაბლონები';

  @override
  String get themeDynamicPrimaryColor => 'ძირითადი ფერი';

  @override
  String get themeDynamicBorderRadius => 'საზღვრის რადიუსი';

  @override
  String get themeDynamicFont => 'შრიფტი';

  @override
  String get themeDynamicAppearance => 'გარეგნობა';

  @override
  String get themeDynamicUiStyle => 'UI სტილი';

  @override
  String get themeDynamicUiStyleDescription =>
      'აკონტროლებს დიალოგების, გადამრთველების და ინდიკატორების გარეგნობას.';

  @override
  String get themeDynamicSharp => 'მკვეთრი';

  @override
  String get themeDynamicRound => 'მრგვალი';

  @override
  String get themeDynamicModeDark => 'მუქი';

  @override
  String get themeDynamicModeLight => 'ნათელი';

  @override
  String get themeDynamicModeAuto => 'ავტო';

  @override
  String get themeDynamicPlatformAuto => 'ავტო';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'არასწორი Firebase URL. მოსალოდნელია https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'არასწორი რელეს URL. მოსალოდნელია wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'არასწორი Pulse სერვერის URL. მოსალოდნელია https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'სერვერის URL';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'მოწვევის კოდი';

  @override
  String get providerPulseInviteHint =>
      'მოწვევის კოდი (საჭიროების შემთხვევაში)';

  @override
  String get providerPulseInfo =>
      'თვით-ჰოსტინგის რელე. გასაღებები გამოთვლილია თქვენი აღდგენის პაროლიდან.';

  @override
  String get providerScreenTitle => 'შემომავალი';

  @override
  String get providerSecondaryInboxesHeader => 'მეორადი შემომავალი';

  @override
  String get providerSecondaryInboxesInfo =>
      'მეორადი შემომავალი ერთდროულად იღებს შეტყობინებებს სარეზერვოსთვის.';

  @override
  String get providerRemoveTooltip => 'წაშლა';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... ან hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... ან hex პირადი გასაღები';

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
  String get emojiNoRecent => 'ბოლოს გამოყენებული ემოჯი არ არის';

  @override
  String get emojiSearchHint => 'ემოჯის ძიება...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'შეეხეთ ჩატისთვის';

  @override
  String get imageViewerSaveToDownloads => 'ჩამოტვირთვებში შენახვა';

  @override
  String imageViewerSavedTo(String path) {
    return 'შენახულია $path-ში';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'ენა';

  @override
  String get settingsLanguageSubtitle => 'აპლიკაციის ჩვენების ენა';

  @override
  String get settingsLanguageSystem => 'სისტემის ნაგულისხმევი';

  @override
  String get onboardingLanguageTitle => 'აირჩიეთ თქვენი ენა';

  @override
  String get onboardingLanguageSubtitle =>
      'ამის შეცვლა მოგვიანებით შეგიძლიათ პარამეტრებში';

  @override
  String get videoNoteRecord => 'ვიდეო შეტყობინების ჩაწერა';

  @override
  String get videoNoteTapToRecord => 'ჩასაწერად შეეხეთ';

  @override
  String get videoNoteTapToStop => 'გასაჩერებლად შეეხეთ';

  @override
  String get videoNoteCameraPermission => 'კამერის ნებართვა უარყოფილია';

  @override
  String get videoNoteMaxDuration => 'მაქსიმუმ 30 წამი';

  @override
  String get videoNoteNotSupported =>
      'ვიდეო შენიშვნები არ არის მხარდაჭერილი ამ პლატფორმაზე';

  @override
  String get navChats => 'ჩატები';

  @override
  String get navUpdates => 'განახლებები';

  @override
  String get navCalls => 'ზარები';

  @override
  String get filterAll => 'ყველა';

  @override
  String get filterUnread => 'წაუკითხავი';

  @override
  String get filterGroups => 'ჯგუფები';

  @override
  String get callsNoRecent => 'ბოლო ზარები არ არის';

  @override
  String get callsEmptySubtitle => 'თქვენი ზარების ისტორია გამოჩნდება აქ';

  @override
  String get appBarEncrypted => 'ბოლო-ბოლო დაშიფრული';

  @override
  String get newStatus => 'ახალი სტატუსი';

  @override
  String get newCall => 'ახალი ზარი';
}
