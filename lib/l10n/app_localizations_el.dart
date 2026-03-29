// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Αναζήτηση μηνυμάτων...';

  @override
  String get search => 'Αναζήτηση';

  @override
  String get clearSearch => 'Εκκαθάριση αναζήτησης';

  @override
  String get closeSearch => 'Κλείσιμο αναζήτησης';

  @override
  String get moreOptions => 'Περισσότερες επιλογές';

  @override
  String get back => 'Πίσω';

  @override
  String get cancel => 'Ακύρωση';

  @override
  String get close => 'Κλείσιμο';

  @override
  String get confirm => 'Επιβεβαίωση';

  @override
  String get remove => 'Αφαίρεση';

  @override
  String get save => 'Αποθήκευση';

  @override
  String get add => 'Προσθήκη';

  @override
  String get copy => 'Αντιγραφή';

  @override
  String get skip => 'Παράλειψη';

  @override
  String get done => 'Τέλος';

  @override
  String get apply => 'Εφαρμογή';

  @override
  String get export => 'Εξαγωγή';

  @override
  String get import => 'Εισαγωγή';

  @override
  String get homeNewGroup => 'Νέα ομάδα';

  @override
  String get homeSettings => 'Ρυθμίσεις';

  @override
  String get homeSearching => 'Αναζήτηση μηνυμάτων...';

  @override
  String get homeNoResults => 'Δεν βρέθηκαν αποτελέσματα';

  @override
  String get homeNoChatHistory => 'Δεν υπάρχει ακόμα ιστορικό συνομιλιών';

  @override
  String homeTransportSwitched(String address) {
    return 'Η μεταφορά άλλαξε → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name σας καλεί...';
  }

  @override
  String get homeAccept => 'Αποδοχή';

  @override
  String get homeDecline => 'Απόρριψη';

  @override
  String get homeLoadEarlier => 'Φόρτωση παλαιότερων μηνυμάτων';

  @override
  String get homeChats => 'Συνομιλίες';

  @override
  String get homeSelectConversation => 'Επιλέξτε μια συνομιλία';

  @override
  String get homeNoChatsYet => 'Δεν υπάρχουν ακόμα συνομιλίες';

  @override
  String get homeAddContactToStart => 'Προσθέστε μια επαφή για να ξεκινήσετε';

  @override
  String get homeNewChat => 'Νέα συνομιλία';

  @override
  String get homeNewChatTooltip => 'Νέα συνομιλία';

  @override
  String get homeIncomingCallTitle => 'Εισερχόμενη κλήση';

  @override
  String get homeIncomingGroupCallTitle => 'Εισερχόμενη ομαδική κλήση';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — εισερχόμενη ομαδική κλήση';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Δεν βρέθηκαν συνομιλίες για \"$query\"';
  }

  @override
  String get homeSectionChats => 'Συνομιλίες';

  @override
  String get homeSectionMessages => 'Μηνύματα';

  @override
  String get homeDbEncryptionUnavailable =>
      'Η κρυπτογράφηση βάσης δεδομένων δεν είναι διαθέσιμη — εγκαταστήστε το SQLCipher για πλήρη προστασία';

  @override
  String get chatFileTooLargeGroup =>
      'Τα αρχεία πάνω από 512 KB δεν υποστηρίζονται σε ομαδικές συνομιλίες';

  @override
  String get chatLargeFile => 'Μεγάλο αρχείο';

  @override
  String get chatCancel => 'Ακύρωση';

  @override
  String get chatSend => 'Αποστολή';

  @override
  String get chatFileTooLarge =>
      'Το αρχείο είναι πολύ μεγάλο — μέγιστο μέγεθος 100 MB';

  @override
  String get chatMicDenied => 'Η άδεια μικροφώνου απορρίφθηκε';

  @override
  String get chatVoiceFailed =>
      'Αποτυχία αποθήκευσης φωνητικού μηνύματος — ελέγξτε τον διαθέσιμο αποθηκευτικό χώρο';

  @override
  String get chatScheduleFuture =>
      'Ο προγραμματισμένος χρόνος πρέπει να είναι στο μέλλον';

  @override
  String get chatToday => 'Σήμερα';

  @override
  String get chatYesterday => 'Χθες';

  @override
  String get chatEdited => 'επεξεργασμένο';

  @override
  String get chatYou => 'Εσύ';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Αυτό το αρχείο είναι $size MB. Η αποστολή μεγάλων αρχείων μπορεί να είναι αργή σε ορισμένα δίκτυα. Συνέχεια;';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Το κλειδί ασφαλείας του $name άλλαξε. Πατήστε για επαλήθευση.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Αδυναμία κρυπτογράφησης μηνύματος προς $name — το μήνυμα δεν στάλθηκε.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Ο αριθμός ασφαλείας άλλαξε για $name. Πατήστε για επαλήθευση.';
  }

  @override
  String get chatNoMessagesFound => 'Δεν βρέθηκαν μηνύματα';

  @override
  String get chatMessagesE2ee =>
      'Τα μηνύματα είναι κρυπτογραφημένα από άκρο σε άκρο';

  @override
  String get chatSayHello => 'Πείτε γεια';

  @override
  String get appBarOnline => 'σε σύνδεση';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'πληκτρολογεί';

  @override
  String get appBarSearchMessages => 'Αναζήτηση μηνυμάτων...';

  @override
  String get appBarMute => 'Σίγαση';

  @override
  String get appBarUnmute => 'Κατάργηση σίγασης';

  @override
  String get appBarMedia => 'Πολυμέσα';

  @override
  String get appBarDisappearing => 'Εξαφανιζόμενα μηνύματα';

  @override
  String get appBarDisappearingOn => 'Εξαφάνιση: ενεργή';

  @override
  String get appBarGroupSettings => 'Ρυθμίσεις ομάδας';

  @override
  String get appBarSearchTooltip => 'Αναζήτηση μηνυμάτων';

  @override
  String get appBarVoiceCall => 'Φωνητική κλήση';

  @override
  String get appBarVideoCall => 'Βιντεοκλήση';

  @override
  String get inputMessage => 'Μήνυμα...';

  @override
  String get inputAttachFile => 'Επισύναψη αρχείου';

  @override
  String get inputSendMessage => 'Αποστολή μηνύματος';

  @override
  String get inputRecordVoice => 'Εγγραφή φωνητικού μηνύματος';

  @override
  String get inputSendVoice => 'Αποστολή φωνητικού μηνύματος';

  @override
  String get inputCancelReply => 'Ακύρωση απάντησης';

  @override
  String get inputCancelEdit => 'Ακύρωση επεξεργασίας';

  @override
  String get inputCancelRecording => 'Ακύρωση εγγραφής';

  @override
  String get inputRecording => 'Εγγραφή…';

  @override
  String get inputEditingMessage => 'Επεξεργασία μηνύματος';

  @override
  String get inputPhoto => 'Φωτογραφία';

  @override
  String get inputVoiceMessage => 'Φωνητικό μήνυμα';

  @override
  String get inputFile => 'Αρχείο';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'τα',
      one: '',
    );
    return '$count προγραμματισμένο μήνυμα$_temp0';
  }

  @override
  String get callInitializing => 'Αρχικοποίηση κλήσης…';

  @override
  String get callConnecting => 'Σύνδεση…';

  @override
  String get callConnectingRelay => 'Σύνδεση (relay)…';

  @override
  String get callSwitchingRelay => 'Εναλλαγή σε λειτουργία relay…';

  @override
  String get callConnectionFailed => 'Η σύνδεση απέτυχε';

  @override
  String get callReconnecting => 'Επανασύνδεση…';

  @override
  String get callEnded => 'Η κλήση τερματίστηκε';

  @override
  String get callLive => 'Ζωντανά';

  @override
  String get callEnd => 'Τέλος';

  @override
  String get callEndCall => 'Τερματισμός κλήσης';

  @override
  String get callMute => 'Σίγαση';

  @override
  String get callUnmute => 'Κατάργηση σίγασης';

  @override
  String get callSpeaker => 'Ηχείο';

  @override
  String get callCameraOn => 'Κάμερα ενεργή';

  @override
  String get callCameraOff => 'Κάμερα ανενεργή';

  @override
  String get callShareScreen => 'Κοινή χρήση οθόνης';

  @override
  String get callStopShare => 'Διακοπή κοινής χρήσης';

  @override
  String callTorBackup(String duration) {
    return 'Εφεδρικό Tor · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Εφεδρικό Tor ενεργό — η κύρια διαδρομή δεν είναι διαθέσιμη';

  @override
  String get callDirectFailed =>
      'Η άμεση σύνδεση απέτυχε — εναλλαγή σε λειτουργία relay…';

  @override
  String get callTurnUnreachable =>
      'Οι διακομιστές TURN δεν είναι προσβάσιμοι. Προσθέστε έναν προσαρμοσμένο TURN στις Ρυθμίσεις → Για προχωρημένους.';

  @override
  String get callRelayMode => 'Λειτουργία relay ενεργή (περιορισμένο δίκτυο)';

  @override
  String get callStarting => 'Έναρξη κλήσης…';

  @override
  String get callConnectingToGroup => 'Σύνδεση στην ομάδα…';

  @override
  String get callGroupOpenedInBrowser =>
      'Η ομαδική κλήση άνοιξε στον περιηγητή';

  @override
  String get callCouldNotOpenBrowser =>
      'Δεν ήταν δυνατό το άνοιγμα του περιηγητή';

  @override
  String get callInviteLinkSent =>
      'Ο σύνδεσμος πρόσκλησης στάλθηκε σε όλα τα μέλη της ομάδας.';

  @override
  String get callOpenLinkManually =>
      'Ανοίξτε τον παραπάνω σύνδεσμο χειροκίνητα ή πατήστε για επανάληψη.';

  @override
  String get callJitsiNotE2ee =>
      'Οι κλήσεις Jitsi ΔΕΝ είναι κρυπτογραφημένες από άκρο σε άκρο';

  @override
  String get callRetryOpenBrowser => 'Επανάληψη ανοίγματος περιηγητή';

  @override
  String get callClose => 'Κλείσιμο';

  @override
  String get callCamOn => 'Κάμερα ενεργή';

  @override
  String get callCamOff => 'Κάμερα ανενεργή';

  @override
  String get noConnection => 'Χωρίς σύνδεση — τα μηνύματα θα μπουν σε ουρά';

  @override
  String get connected => 'Συνδέθηκε';

  @override
  String get connecting => 'Σύνδεση…';

  @override
  String get disconnected => 'Αποσυνδέθηκε';

  @override
  String get offlineBanner =>
      'Χωρίς σύνδεση — τα μηνύματα θα σταλούν όταν επανέλθετε σε σύνδεση';

  @override
  String get lanModeBanner =>
      'Λειτουργία LAN — Χωρίς internet · Μόνο τοπικό δίκτυο';

  @override
  String get probeCheckingNetwork => 'Έλεγχος συνδεσιμότητας δικτύου…';

  @override
  String get probeDiscoveringRelays =>
      'Ανακάλυψη relay μέσω καταλόγων κοινότητας…';

  @override
  String get probeStartingTor => 'Εκκίνηση Tor για αρχικοποίηση…';

  @override
  String get probeFindingRelaysTor => 'Εύρεση προσβάσιμων relay μέσω Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'αν $count relay',
      one: 'ε 1 relay',
    );
    return 'Δίκτυο έτοιμο — βρέθηκ$_temp0';
  }

  @override
  String get probeNoRelaysFound =>
      'Δεν βρέθηκαν προσβάσιμα relay — τα μηνύματα ενδέχεται να καθυστερήσουν';

  @override
  String get jitsiWarningTitle => 'Χωρίς κρυπτογράφηση από άκρο σε άκρο';

  @override
  String get jitsiWarningBody =>
      'Οι κλήσεις Jitsi Meet δεν κρυπτογραφούνται από το Pulse. Χρησιμοποιήστε τις μόνο για μη ευαίσθητες συνομιλίες.';

  @override
  String get jitsiConfirm => 'Συμμετοχή ούτως ή άλλως';

  @override
  String get jitsiGroupWarningTitle => 'Χωρίς κρυπτογράφηση από άκρο σε άκρο';

  @override
  String get jitsiGroupWarningBody =>
      'Αυτή η κλήση έχει πάρα πολλούς συμμετέχοντες για το ενσωματωμένο κρυπτογραφημένο mesh.\n\nΈνας σύνδεσμος Jitsi Meet θα ανοίξει στον περιηγητή σας. Το Jitsi ΔΕΝ είναι κρυπτογραφημένο από άκρο σε άκρο — ο διακομιστής μπορεί να δει την κλήση σας.';

  @override
  String get jitsiContinueAnyway => 'Συνέχεια ούτως ή άλλως';

  @override
  String get retry => 'Επανάληψη';

  @override
  String get setupCreateAnonymousAccount => 'Δημιουργία ανώνυμου λογαριασμού';

  @override
  String get setupTapToChangeColor => 'Πατήστε για αλλαγή χρώματος';

  @override
  String get setupReqMinLength => 'At least 16 characters';

  @override
  String get setupReqVariety => '3 of 4: uppercase, lowercase, digits, symbols';

  @override
  String get setupReqMatch => 'Passwords match';

  @override
  String get setupYourNickname => 'Το ψευδώνυμό σας';

  @override
  String get setupRecoveryPassword => 'Κωδικός ανάκτησης (ελάχ. 16)';

  @override
  String get setupConfirmPassword => 'Επιβεβαίωση κωδικού';

  @override
  String get setupMin16Chars => 'Τουλάχιστον 16 χαρακτήρες';

  @override
  String get setupPasswordsDoNotMatch => 'Οι κωδικοί δεν ταιριάζουν';

  @override
  String get setupEntropyWeak => 'Αδύναμος';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Ισχυρός';

  @override
  String get setupEntropyWeakNeedsVariety =>
      'Αδύναμος (απαιτούνται 3 τύποι χαρακτήρων)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bits)';
  }

  @override
  String get setupPasswordWarning =>
      'Αυτός ο κωδικός είναι ο μόνος τρόπος να ανακτήσετε τον λογαριασμό σας. Δεν υπάρχει διακομιστής — δεν γίνεται επαναφορά κωδικού. Απομνημονεύστε τον ή σημειώστε τον.';

  @override
  String get setupCreateAccount => 'Δημιουργία λογαριασμού';

  @override
  String get setupAlreadyHaveAccount => 'Έχετε ήδη λογαριασμό; ';

  @override
  String get setupRestore => 'Ανάκτηση →';

  @override
  String get restoreTitle => 'Ανάκτηση λογαριασμού';

  @override
  String get restoreInfoBanner =>
      'Εισαγάγετε τον κωδικό ανάκτησης — η διεύθυνσή σας (Nostr + Session) θα αποκατασταθεί αυτόματα. Οι επαφές και τα μηνύματα αποθηκεύτηκαν μόνο τοπικά.';

  @override
  String get restoreNewNickname => 'Νέο ψευδώνυμο (μπορεί να αλλάξει αργότερα)';

  @override
  String get restoreButton => 'Ανάκτηση λογαριασμού';

  @override
  String get lockTitle => 'Το Pulse είναι κλειδωμένο';

  @override
  String get lockSubtitle => 'Εισαγάγετε τον κωδικό σας για να συνεχίσετε';

  @override
  String get lockPasswordHint => 'Κωδικός';

  @override
  String get lockUnlock => 'Ξεκλείδωμα';

  @override
  String get lockPanicHint =>
      'Ξεχάσατε τον κωδικό σας; Εισαγάγετε το κλειδί πανικού για να διαγράψετε όλα τα δεδομένα.';

  @override
  String get lockTooManyAttempts =>
      'Πάρα πολλές προσπάθειες. Διαγραφή όλων των δεδομένων…';

  @override
  String get lockWrongPassword => 'Λάθος κωδικός';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Λάθος κωδικός — $attempts/$max προσπάθειες';
  }

  @override
  String get onboardingSkip => 'Παράλειψη';

  @override
  String get onboardingNext => 'Επόμενο';

  @override
  String get onboardingGetStarted => 'Ας ξεκινήσουμε';

  @override
  String get onboardingWelcomeTitle => 'Καλώς ήρθατε στο Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Ένας αποκεντρωμένος, κρυπτογραφημένος από άκρο σε άκρο, messenger.\n\nΚανένας κεντρικός διακομιστής. Καμία συλλογή δεδομένων. Καμία κερκόπορτα.\nΟι συνομιλίες σας ανήκουν μόνο σε εσάς.';

  @override
  String get onboardingTransportTitle => 'Ανεξάρτητο μεταφοράς';

  @override
  String get onboardingTransportBody =>
      'Χρησιμοποιήστε Firebase, Nostr ή και τα δύο ταυτόχρονα.\n\nΤα μηνύματα δρομολογούνται αυτόματα μέσω δικτύων. Ενσωματωμένη υποστήριξη Tor και I2P για αντίσταση στη λογοκρισία.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Κάθε μήνυμα κρυπτογραφείται με το Signal Protocol (Double Ratchet + X3DH) για προστασία μελλοντικού απορρήτου.\n\nΕπιπλέον περιτυλίγεται με Kyber-1024 — έναν πρότυπο NIST post-quantum αλγόριθμο — για προστασία από μελλοντικούς κβαντικούς υπολογιστές.';

  @override
  String get onboardingKeysTitle => 'Τα κλειδιά σας ανήκουν σε εσάς';

  @override
  String get onboardingKeysBody =>
      'Τα κλειδιά ταυτότητάς σας δεν εγκαταλείπουν ποτέ τη συσκευή σας.\n\nΤα αποτυπώματα Signal σας επιτρέπουν να επαληθεύσετε τις επαφές εκτός καναλιού. Το TOFU (Trust On First Use) εντοπίζει αλλαγές κλειδιών αυτόματα.';

  @override
  String get onboardingThemeTitle => 'Επιλέξτε την εμφάνισή σας';

  @override
  String get onboardingThemeBody =>
      'Επιλέξτε θέμα και χρώμα έμφασης. Μπορείτε να το αλλάξετε ανά πάσα στιγμή στις Ρυθμίσεις.';

  @override
  String get contactsNewChat => 'Νέα συνομιλία';

  @override
  String get contactsAddContact => 'Προσθήκη επαφής';

  @override
  String get contactsSearchHint => 'Αναζήτηση...';

  @override
  String get contactsNewGroup => 'Νέα ομάδα';

  @override
  String get contactsNoContactsYet => 'Δεν υπάρχουν ακόμα επαφές';

  @override
  String get contactsAddHint => 'Πατήστε + για να προσθέσετε μια διεύθυνση';

  @override
  String get contactsNoMatch => 'Δεν ταιριάζουν επαφές';

  @override
  String get contactsRemoveTitle => 'Αφαίρεση επαφής';

  @override
  String contactsRemoveMessage(String name) {
    return 'Αφαίρεση $name;';
  }

  @override
  String get contactsRemove => 'Αφαίρεση';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ές',
      one: 'ή',
    );
    return '$count επαφ$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Άνοιγμα συνδέσμου';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Άνοιγμα αυτού του URL στον περιηγητή σας;\n\n$url';
  }

  @override
  String get bubbleOpen => 'Άνοιγμα';

  @override
  String get bubbleSecurityWarning => 'Προειδοποίηση ασφαλείας';

  @override
  String bubbleExecutableWarning(String name) {
    return 'Το \"$name\" είναι εκτελέσιμο αρχείο. Η αποθήκευση και εκτέλεσή του μπορεί να βλάψει τη συσκευή σας. Αποθήκευση ούτως ή άλλως;';
  }

  @override
  String get bubbleSaveAnyway => 'Αποθήκευση ούτως ή άλλως';

  @override
  String bubbleSavedTo(String path) {
    return 'Αποθηκεύτηκε στο $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Η αποθήκευση απέτυχε: $error';
  }

  @override
  String get bubbleNotEncrypted => 'ΜΗ ΚΡΥΠΤΟΓΡΑΦΗΜΕΝΟ';

  @override
  String get bubbleCorruptedImage => '[Κατεστραμμένη εικόνα]';

  @override
  String get bubbleReplyPhoto => 'Φωτογραφία';

  @override
  String get bubbleReplyVoice => 'Φωνητικό μήνυμα';

  @override
  String get bubbleReplyVideo => 'Βίντεο μήνυμα';

  @override
  String bubbleReadBy(String names) {
    return 'Αναγνώστηκε από $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Αναγνώστηκε από $count';
  }

  @override
  String get chatTileTapToStart => 'Πατήστε για να ξεκινήσετε τη συνομιλία';

  @override
  String get chatTileMessageSent => 'Το μήνυμα στάλθηκε';

  @override
  String get chatTileEncryptedMessage => 'Κρυπτογραφημένο μήνυμα';

  @override
  String chatTileYouPrefix(String text) {
    return 'Εσύ: $text';
  }

  @override
  String get bannerEncryptedMessage => 'Κρυπτογραφημένο μήνυμα';

  @override
  String get groupNewGroup => 'Νέα ομάδα';

  @override
  String get groupGroupName => 'Όνομα ομάδας';

  @override
  String get groupSelectMembers => 'Επιλογή μελών (ελάχ. 2)';

  @override
  String get groupNoContactsYet =>
      'Δεν υπάρχουν ακόμα επαφές. Προσθέστε πρώτα επαφές.';

  @override
  String get groupCreate => 'Δημιουργία';

  @override
  String get groupLabel => 'Ομάδα';

  @override
  String get profileVerifyIdentity => 'Επαλήθευση ταυτότητας';

  @override
  String profileVerifyInstructions(String name) {
    return 'Συγκρίνετε αυτά τα αποτυπώματα με τον/την $name μέσω φωνητικής κλήσης ή αυτοπροσώπως. Εάν οι τιμές ταιριάζουν και στις δύο συσκευές, πατήστε „Επισήμανση ως επαληθευμένο“.';
  }

  @override
  String get profileTheirKey => 'Το κλειδί τους';

  @override
  String get profileYourKey => 'Το κλειδί σας';

  @override
  String get profileRemoveVerification => 'Αφαίρεση επαλήθευσης';

  @override
  String get profileMarkAsVerified => 'Επισήμανση ως επαληθευμένο';

  @override
  String get profileAddressCopied => 'Η διεύθυνση αντιγράφηκε';

  @override
  String get profileNoContactsToAdd =>
      'Δεν υπάρχουν επαφές για προσθήκη — όλες είναι ήδη μέλη';

  @override
  String get profileAddMembers => 'Προσθήκη μελών';

  @override
  String profileAddCount(int count) {
    return 'Προσθήκη ($count)';
  }

  @override
  String get profileRenameGroup => 'Μετονομασία ομάδας';

  @override
  String get profileRename => 'Μετονομασία';

  @override
  String get profileRemoveMember => 'Αφαίρεση μέλους;';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Αφαίρεση $name από αυτή την ομάδα;';
  }

  @override
  String get profileKick => 'Αφαίρεση';

  @override
  String get profileSignalFingerprints => 'Αποτυπώματα Signal';

  @override
  String get profileVerified => 'ΕΠΑΛΗΘΕΥΜΕΝΟ';

  @override
  String get profileVerify => 'Επαλήθευση';

  @override
  String get profileEdit => 'Επεξεργασία';

  @override
  String get profileNoSession =>
      'Δεν έχει δημιουργηθεί ακόμα συνεδρία — στείλτε πρώτα ένα μήνυμα.';

  @override
  String get profileFingerprintCopied => 'Το αποτύπωμα αντιγράφηκε';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'η',
      one: 'ος',
    );
    return '$count μέλ$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Επαλήθευση αριθμού ασφαλείας';

  @override
  String get profileShowContactQr => 'Εμφάνιση QR επαφής';

  @override
  String profileContactAddress(String name) {
    return 'Διεύθυνση του/της $name';
  }

  @override
  String get profileExportChatHistory => 'Εξαγωγή ιστορικού συνομιλίας';

  @override
  String profileSavedTo(String path) {
    return 'Αποθηκεύτηκε στο $path';
  }

  @override
  String get profileExportFailed => 'Η εξαγωγή απέτυχε';

  @override
  String get profileClearChatHistory => 'Εκκαθάριση ιστορικού συνομιλίας';

  @override
  String get profileDeleteGroup => 'Διαγραφή ομάδας';

  @override
  String get profileDeleteContact => 'Διαγραφή επαφής';

  @override
  String get profileLeaveGroup => 'Αποχώρηση από ομάδα';

  @override
  String get profileLeaveGroupBody =>
      'Θα αφαιρεθείτε από αυτή την ομάδα και θα διαγραφεί από τις επαφές σας.';

  @override
  String get groupInviteTitle => 'Πρόσκληση ομάδας';

  @override
  String groupInviteBody(String from, String group) {
    return 'Ο/Η $from σας προσκάλεσε να συμμετάσχετε στην \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Αποδοχή';

  @override
  String get groupInviteDecline => 'Απόρριψη';

  @override
  String get groupMemberLimitTitle => 'Πάρα πολλοί συμμετέχοντες';

  @override
  String groupMemberLimitBody(int count) {
    return 'Αυτή η ομάδα θα έχει $count συμμετέχοντες. Οι κρυπτογραφημένες κλήσεις mesh υποστηρίζουν έως 6. Μεγαλύτερες ομάδες χρησιμοποιούν Jitsi (χωρίς E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Προσθήκη ούτως ή άλλως';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return 'Ο/Η $name αρνήθηκε να συμμετάσχει στην \"$group\"';
  }

  @override
  String get transferTitle => 'Μεταφορά σε άλλη συσκευή';

  @override
  String get transferInfoBox =>
      'Μεταφέρετε την ταυτότητα Signal και τα κλειδιά Nostr σε μια νέα συσκευή.\nΟι συνεδρίες συνομιλίας ΔΕΝ μεταφέρονται — η forward secrecy διατηρείται.';

  @override
  String get transferSendFromThis => 'Αποστολή από αυτή τη συσκευή';

  @override
  String get transferSendSubtitle =>
      'Αυτή η συσκευή έχει τα κλειδιά. Μοιραστείτε έναν κωδικό με τη νέα συσκευή.';

  @override
  String get transferReceiveOnThis => 'Λήψη σε αυτή τη συσκευή';

  @override
  String get transferReceiveSubtitle =>
      'Αυτή είναι η νέα συσκευή. Εισαγάγετε τον κωδικό από την παλιά συσκευή.';

  @override
  String get transferChooseMethod => 'Επιλογή μεθόδου μεταφοράς';

  @override
  String get transferLan => 'LAN (Ίδιο δίκτυο)';

  @override
  String get transferLanSubtitle =>
      'Γρήγορη, άμεση. Και οι δύο συσκευές πρέπει να είναι στο ίδιο Wi-Fi.';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'Λειτουργεί σε οποιοδήποτε δίκτυο μέσω ενός υπάρχοντος Nostr relay.';

  @override
  String get transferRelayUrl => 'URL Relay';

  @override
  String get transferEnterCode => 'Εισαγωγή κωδικού μεταφοράς';

  @override
  String get transferPasteCode =>
      'Επικολλήστε τον κωδικό LAN:... ή NOS:... εδώ';

  @override
  String get transferConnect => 'Σύνδεση';

  @override
  String get transferGenerating => 'Δημιουργία κωδικού μεταφοράς…';

  @override
  String get transferShareCode =>
      'Μοιραστείτε αυτόν τον κωδικό με τον παραλήπτη:';

  @override
  String get transferCopyCode => 'Αντιγραφή κωδικού';

  @override
  String get transferCodeCopied => 'Ο κωδικός αντιγράφηκε στο πρόχειρο';

  @override
  String get transferWaitingReceiver => 'Αναμονή σύνδεσης παραλήπτη…';

  @override
  String get transferConnectingSender => 'Σύνδεση στον αποστολέα…';

  @override
  String get transferVerifyBoth =>
      'Συγκρίνετε αυτόν τον κωδικό και στις δύο συσκευές.\nΕάν ταιριάζουν, η μεταφορά είναι ασφαλής.';

  @override
  String get transferComplete => 'Η μεταφορά ολοκληρώθηκε';

  @override
  String get transferKeysImported => 'Τα κλειδιά εισήχθησαν';

  @override
  String get transferCompleteSenderBody =>
      'Τα κλειδιά σας παραμένουν ενεργά σε αυτή τη συσκευή.\nΟ παραλήπτης μπορεί τώρα να χρησιμοποιήσει την ταυτότητά σας.';

  @override
  String get transferCompleteReceiverBody =>
      'Τα κλειδιά εισήχθησαν επιτυχώς.\nΕπανεκκινήστε την εφαρμογή για να εφαρμοστεί η νέα ταυτότητα.';

  @override
  String get transferRestartApp => 'Επανεκκίνηση εφαρμογής';

  @override
  String get transferFailed => 'Η μεταφορά απέτυχε';

  @override
  String get transferTryAgain => 'Δοκιμάστε ξανά';

  @override
  String get transferEnterRelayFirst => 'Εισαγάγετε πρώτα ένα URL relay';

  @override
  String get transferPasteCodeFromSender =>
      'Επικολλήστε τον κωδικό μεταφοράς από τον αποστολέα';

  @override
  String get menuReply => 'Απάντηση';

  @override
  String get menuForward => 'Προώθηση';

  @override
  String get menuReact => 'Αντίδραση';

  @override
  String get menuCopy => 'Αντιγραφή';

  @override
  String get menuEdit => 'Επεξεργασία';

  @override
  String get menuRetry => 'Επανάληψη';

  @override
  String get menuCancelScheduled => 'Ακύρωση προγραμματισμένου';

  @override
  String get menuDelete => 'Διαγραφή';

  @override
  String get menuForwardTo => 'Προώθηση σε…';

  @override
  String menuForwardedTo(String name) {
    return 'Προωθήθηκε στον/στην $name';
  }

  @override
  String get menuScheduledMessages => 'Προγραμματισμένα μηνύματα';

  @override
  String get menuNoScheduledMessages =>
      'Δεν υπάρχουν προγραμματισμένα μηνύματα';

  @override
  String menuSendsOn(String date) {
    return 'Αποστολή στις $date';
  }

  @override
  String get menuDisappearingMessages => 'Εξαφανιζόμενα μηνύματα';

  @override
  String get menuDisappearingSubtitle =>
      'Τα μηνύματα διαγράφονται αυτόματα μετά τον επιλεγμένο χρόνο.';

  @override
  String get menuTtlOff => 'Ανενεργό';

  @override
  String get menuTtl1h => '1 ώρα';

  @override
  String get menuTtl24h => '24 ώρες';

  @override
  String get menuTtl7d => '7 ημέρες';

  @override
  String get menuAttachPhoto => 'Φωτογραφία';

  @override
  String get menuAttachFile => 'Αρχείο';

  @override
  String get menuAttachVideo => 'Βίντεο';

  @override
  String get mediaTitle => 'Πολυμέσα';

  @override
  String get mediaFileLabel => 'ΑΡΧΕΙΟ';

  @override
  String mediaPhotosTab(int count) {
    return 'Φωτογραφίες ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Αρχεία ($count)';
  }

  @override
  String get mediaNoPhotos => 'Δεν υπάρχουν ακόμα φωτογραφίες';

  @override
  String get mediaNoFiles => 'Δεν υπάρχουν ακόμα αρχεία';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Αποθηκεύτηκε στο Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'Αποτυχία αποθήκευσης αρχείου';

  @override
  String get statusNewStatus => 'Νέα κατάσταση';

  @override
  String get statusPublish => 'Δημοσίευση';

  @override
  String get statusExpiresIn24h => 'Η κατάσταση λήγει σε 24 ώρες';

  @override
  String get statusWhatsOnYourMind => 'Τι σκέφτεστε;';

  @override
  String get statusPhotoAttached => 'Φωτογραφία επισυνάφθηκε';

  @override
  String get statusAttachPhoto => 'Επισύναψη φωτογραφίας (προαιρετικό)';

  @override
  String get statusEnterText =>
      'Παρακαλώ εισαγάγετε κείμενο για την κατάστασή σας.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Αποτυχία επιλογής φωτογραφίας: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Αποτυχία δημοσίευσης: $error';
  }

  @override
  String get panicSetPanicKey => 'Ορισμός κλειδιού πανικού';

  @override
  String get panicEmergencySelfDestruct => 'Αυτοκαταστροφή έκτακτης ανάγκης';

  @override
  String get panicIrreversible => 'Αυτή η ενέργεια είναι μη αναστρέψιμη';

  @override
  String get panicWarningBody =>
      'Η εισαγωγή αυτού του κλειδιού στην οθόνη κλειδώματος διαγράφει αμέσως ΟΛΑ τα δεδομένα — μηνύματα, επαφές, κλειδιά, ταυτότητα. Χρησιμοποιήστε ένα κλειδί διαφορετικό από τον κανονικό σας κωδικό.';

  @override
  String get panicKeyHint => 'Κλειδί πανικού';

  @override
  String get panicConfirmHint => 'Επιβεβαίωση κλειδιού πανικού';

  @override
  String get panicMinChars =>
      'Το κλειδί πανικού πρέπει να έχει τουλάχιστον 8 χαρακτήρες';

  @override
  String get panicKeysDoNotMatch => 'Τα κλειδιά δεν ταιριάζουν';

  @override
  String get panicSetFailed =>
      'Αποτυχία αποθήκευσης κλειδιού πανικού — παρακαλώ δοκιμάστε ξανά';

  @override
  String get passwordSetAppPassword => 'Ορισμός κωδικού εφαρμογής';

  @override
  String get passwordProtectsMessages =>
      'Προστατεύει τα μηνύματά σας σε αδράνεια';

  @override
  String get passwordInfoBanner =>
      'Απαιτείται κάθε φορά που ανοίγετε το Pulse. Σε περίπτωση απώλειας, τα δεδομένα σας δεν μπορούν να ανακτηθούν.';

  @override
  String get passwordHint => 'Κωδικός';

  @override
  String get passwordConfirmHint => 'Επιβεβαίωση κωδικού';

  @override
  String get passwordSetButton => 'Ορισμός κωδικού';

  @override
  String get passwordSkipForNow => 'Παράλειψη προς το παρόν';

  @override
  String get passwordMinChars =>
      'Ο κωδικός πρέπει να έχει τουλάχιστον 6 χαρακτήρες';

  @override
  String get passwordsDoNotMatch => 'Οι κωδικοί δεν ταιριάζουν';

  @override
  String get profileCardSaved => 'Το προφίλ αποθηκεύτηκε!';

  @override
  String get profileCardE2eeIdentity => 'Ταυτότητα E2EE';

  @override
  String get profileCardDisplayName => 'Εμφανιζόμενο όνομα';

  @override
  String get profileCardDisplayNameHint => 'π.χ. Γιάννης Παπαδόπουλος';

  @override
  String get profileCardAbout => 'Σχετικά';

  @override
  String get profileCardSaveProfile => 'Αποθήκευση προφίλ';

  @override
  String get profileCardYourName => 'Το όνομά σας';

  @override
  String get profileCardAddressCopied => 'Η διεύθυνση αντιγράφηκε!';

  @override
  String get profileCardInboxAddress => 'Η διεύθυνση εισερχομένων σας';

  @override
  String get profileCardInboxAddresses => 'Οι διευθύνσεις εισερχομένων σας';

  @override
  String get profileCardShareAllAddresses =>
      'Κοινή χρήση όλων των διευθύνσεων (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Μοιραστείτε με τις επαφές σας ώστε να μπορούν να σας στείλουν μήνυμα.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Όλες οι $count διευθύνσεις αντιγράφηκαν ως ένας σύνδεσμος!';
  }

  @override
  String get settingsMyProfile => 'Το προφίλ μου';

  @override
  String get settingsYourInboxAddress => 'Η διεύθυνση εισερχομένων σας';

  @override
  String get settingsMyQrCode => 'Ο κωδικός QR μου';

  @override
  String get settingsMyQrSubtitle => 'Κοινή χρήση διεύθυνσης ως σαρώσιμο QR';

  @override
  String get settingsShareMyAddress => 'Κοινή χρήση της διεύθυνσής μου';

  @override
  String get settingsNoAddressYet =>
      'Δεν υπάρχει ακόμα διεύθυνση — αποθηκεύστε πρώτα τις ρυθμίσεις';

  @override
  String get settingsInviteLink => 'Σύνδεσμος πρόσκλησης';

  @override
  String get settingsRawAddress => 'Ακατέργαστη διεύθυνση';

  @override
  String get settingsCopyLink => 'Αντιγραφή συνδέσμου';

  @override
  String get settingsCopyAddress => 'Αντιγραφή διεύθυνσης';

  @override
  String get settingsInviteLinkCopied => 'Ο σύνδεσμος πρόσκλησης αντιγράφηκε';

  @override
  String get settingsAppearance => 'Εμφάνιση';

  @override
  String get settingsThemeEngine => 'Μηχανή θεμάτων';

  @override
  String get settingsThemeEngineSubtitle =>
      'Προσαρμογή χρωμάτων και γραμματοσειρών';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle =>
      'Τα κλειδιά E2EE αποθηκεύονται με ασφάλεια';

  @override
  String get settingsActive => 'ΕΝΕΡΓΟ';

  @override
  String get settingsIdentityBackup => 'Αντίγραφο ασφαλείας ταυτότητας';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Εξαγωγή ή εισαγωγή της ταυτότητας Signal';

  @override
  String get settingsIdentityBackupBody =>
      'Εξαγάγετε τα κλειδιά ταυτότητας Signal σε κωδικό αντιγράφου ασφαλείας ή αποκαταστήστε από υπάρχοντα.';

  @override
  String get settingsTransferDevice => 'Μεταφορά σε άλλη συσκευή';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Μεταφορά ταυτότητας μέσω LAN ή Nostr relay';

  @override
  String get settingsExportIdentity => 'Εξαγωγή ταυτότητας';

  @override
  String get settingsExportIdentityBody =>
      'Αντιγράψτε αυτόν τον κωδικό αντιγράφου ασφαλείας και αποθηκεύστε τον με ασφάλεια:';

  @override
  String get settingsSaveFile => 'Αποθήκευση αρχείου';

  @override
  String get settingsImportIdentity => 'Εισαγωγή ταυτότητας';

  @override
  String get settingsImportIdentityBody =>
      'Επικολλήστε τον κωδικό αντιγράφου ασφαλείας παρακάτω. Αυτό θα αντικαταστήσει την τρέχουσα ταυτότητά σας.';

  @override
  String get settingsPasteBackupCode =>
      'Επικολλήστε τον κωδικό αντιγράφου ασφαλείας εδώ…';

  @override
  String get settingsIdentityImported =>
      'Ταυτότητα + επαφές εισήχθησαν! Επανεκκινήστε την εφαρμογή για εφαρμογή.';

  @override
  String get settingsSecurity => 'Ασφάλεια';

  @override
  String get settingsAppPassword => 'Κωδικός εφαρμογής';

  @override
  String get settingsPasswordEnabled =>
      'Ενεργοποιημένος — απαιτείται σε κάθε εκκίνηση';

  @override
  String get settingsPasswordDisabled =>
      'Απενεργοποιημένος — η εφαρμογή ανοίγει χωρίς κωδικό';

  @override
  String get settingsChangePassword => 'Αλλαγή κωδικού';

  @override
  String get settingsChangePasswordSubtitle =>
      'Ενημέρωση κωδικού κλειδώματος εφαρμογής';

  @override
  String get settingsSetPanicKey => 'Ορισμός κλειδιού πανικού';

  @override
  String get settingsChangePanicKey => 'Αλλαγή κλειδιού πανικού';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Ενημέρωση κλειδιού έκτακτης διαγραφής';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Ένα κλειδί που διαγράφει αμέσως όλα τα δεδομένα';

  @override
  String get settingsRemovePanicKey => 'Αφαίρεση κλειδιού πανικού';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Απενεργοποίηση αυτοκαταστροφής έκτακτης ανάγκης';

  @override
  String get settingsRemovePanicKeyBody =>
      'Η αυτοκαταστροφή έκτακτης ανάγκης θα απενεργοποιηθεί. Μπορείτε να την ενεργοποιήσετε ξανά ανά πάσα στιγμή.';

  @override
  String get settingsDisableAppPassword => 'Απενεργοποίηση κωδικού εφαρμογής';

  @override
  String get settingsEnterCurrentPassword =>
      'Εισαγάγετε τον τρέχοντα κωδικό σας για επιβεβαίωση';

  @override
  String get settingsCurrentPassword => 'Τρέχων κωδικός';

  @override
  String get settingsIncorrectPassword => 'Λανθασμένος κωδικός';

  @override
  String get settingsPasswordUpdated => 'Ο κωδικός ενημερώθηκε';

  @override
  String get settingsChangePasswordProceed =>
      'Εισαγάγετε τον τρέχοντα κωδικό σας για να συνεχίσετε';

  @override
  String get settingsData => 'Δεδομένα';

  @override
  String get settingsBackupMessages => 'Αντίγραφο ασφαλείας μηνυμάτων';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Εξαγωγή κρυπτογραφημένου ιστορικού μηνυμάτων σε αρχείο';

  @override
  String get settingsRestoreMessages => 'Επαναφορά μηνυμάτων';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Εισαγωγή μηνυμάτων από αρχείο αντιγράφου ασφαλείας';

  @override
  String get settingsExportKeys => 'Εξαγωγή κλειδιών';

  @override
  String get settingsExportKeysSubtitle =>
      'Αποθήκευση κλειδιών ταυτότητας σε κρυπτογραφημένο αρχείο';

  @override
  String get settingsImportKeys => 'Εισαγωγή κλειδιών';

  @override
  String get settingsImportKeysSubtitle =>
      'Επαναφορά κλειδιών ταυτότητας από εξαγόμενο αρχείο';

  @override
  String get settingsBackupPassword => 'Κωδικός αντιγράφου ασφαλείας';

  @override
  String get settingsPasswordCannotBeEmpty =>
      'Ο κωδικός δεν μπορεί να είναι κενός';

  @override
  String get settingsPasswordMin4Chars =>
      'Ο κωδικός πρέπει να έχει τουλάχιστον 4 χαρακτήρες';

  @override
  String get settingsCallsTurn => 'Κλήσεις & TURN';

  @override
  String get settingsLocalNetwork => 'Τοπικό δίκτυο';

  @override
  String get settingsCensorshipResistance => 'Αντίσταση στη λογοκρισία';

  @override
  String get settingsNetwork => 'Δίκτυο';

  @override
  String get settingsProxyTunnels => 'Proxy & Σήραγγες';

  @override
  String get settingsTurnServers => 'Διακομιστές TURN';

  @override
  String get settingsProviderTitle => 'Πάροχος';

  @override
  String get settingsLanFallback => 'Εφεδρικό LAN';

  @override
  String get settingsLanFallbackSubtitle =>
      'Αναμετάδοση παρουσίας και παράδοση μηνυμάτων στο τοπικό δίκτυο όταν δεν υπάρχει internet. Απενεργοποιήστε σε μη αξιόπιστα δίκτυα (δημόσιο Wi-Fi).';

  @override
  String get settingsBgDelivery => 'Παράδοση στο παρασκήνιο';

  @override
  String get settingsBgDeliverySubtitle =>
      'Συνεχίστε να λαμβάνετε μηνύματα όταν η εφαρμογή είναι ελαχιστοποιημένη. Εμφανίζει μόνιμη ειδοποίηση.';

  @override
  String get settingsYourInboxProvider => 'Ο πάροχος εισερχομένων σας';

  @override
  String get settingsConnectionDetails => 'Λεπτομέρειες σύνδεσης';

  @override
  String get settingsSaveAndConnect => 'Αποθήκευση & Σύνδεση';

  @override
  String get settingsSecondaryInboxes => 'Δευτερεύοντα εισερχόμενα';

  @override
  String get settingsAddSecondaryInbox => 'Προσθήκη δευτερεύοντος εισερχομένου';

  @override
  String get settingsAdvanced => 'Για προχωρημένους';

  @override
  String get settingsDiscover => 'Ανακάλυψη';

  @override
  String get settingsAbout => 'Σχετικά';

  @override
  String get settingsPrivacyPolicy => 'Πολιτική απορρήτου';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Πώς το Pulse προστατεύει τα δεδομένα σας';

  @override
  String get settingsCrashReporting => 'Αναφορές σφαλμάτων';

  @override
  String get settingsCrashReportingSubtitle =>
      'Αποστολή ανώνυμων αναφορών σφαλμάτων για τη βελτίωση του Pulse. Κανένα περιεχόμενο μηνυμάτων ή επαφών δεν αποστέλλεται ποτέ.';

  @override
  String get settingsCrashReportingEnabled =>
      'Αναφορές σφαλμάτων ενεργοποιημένες — επανεκκινήστε την εφαρμογή για εφαρμογή';

  @override
  String get settingsCrashReportingDisabled =>
      'Αναφορές σφαλμάτων απενεργοποιημένες — επανεκκινήστε την εφαρμογή για εφαρμογή';

  @override
  String get settingsSensitiveOperation => 'Ευαίσθητη λειτουργία';

  @override
  String get settingsSensitiveOperationBody =>
      'Αυτά τα κλειδιά είναι η ταυτότητά σας. Οποιοσδήποτε με αυτό το αρχείο μπορεί να σας υποδυθεί. Αποθηκεύστε το με ασφάλεια και διαγράψτε το μετά τη μεταφορά.';

  @override
  String get settingsIUnderstandContinue => 'Κατανοώ, συνέχεια';

  @override
  String get settingsReplaceIdentity => 'Αντικατάσταση ταυτότητας;';

  @override
  String get settingsReplaceIdentityBody =>
      'Αυτό θα αντικαταστήσει τα τρέχοντα κλειδιά ταυτότητάς σας. Οι υπάρχουσες συνεδρίες Signal θα ακυρωθούν και οι επαφές θα χρειαστεί να επαναδημιουργήσουν την κρυπτογράφηση. Η εφαρμογή θα χρειαστεί επανεκκίνηση.';

  @override
  String get settingsReplaceKeys => 'Αντικατάσταση κλειδιών';

  @override
  String get settingsKeysImported => 'Τα κλειδιά εισήχθησαν';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count κλειδιά εισήχθησαν επιτυχώς. Παρακαλώ επανεκκινήστε την εφαρμογή για αρχικοποίηση με τη νέα ταυτότητα.';
  }

  @override
  String get settingsRestartNow => 'Επανεκκίνηση τώρα';

  @override
  String get settingsLater => 'Αργότερα';

  @override
  String get profileGroupLabel => 'Ομάδα';

  @override
  String get profileAddButton => 'Προσθήκη';

  @override
  String get profileKickButton => 'Αφαίρεση';

  @override
  String get dataSectionTitle => 'Δεδομένα';

  @override
  String get dataBackupMessages => 'Αντίγραφο ασφαλείας μηνυμάτων';

  @override
  String get dataBackupPasswordSubtitle =>
      'Επιλέξτε κωδικό για κρυπτογράφηση του αντιγράφου ασφαλείας.';

  @override
  String get dataBackupConfirmLabel => 'Δημιουργία αντιγράφου ασφαλείας';

  @override
  String get dataCreatingBackup => 'Δημιουργία αντιγράφου ασφαλείας';

  @override
  String get dataBackupPreparing => 'Προετοιμασία...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Εξαγωγή μηνύματος $done από $total...';
  }

  @override
  String get dataBackupSavingFile => 'Αποθήκευση αρχείου...';

  @override
  String get dataSaveMessageBackupDialog => 'Αποθήκευση αντιγράφου μηνυμάτων';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Αντίγραφο αποθηκεύτηκε ($count μηνύματα)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Το αντίγραφο απέτυχε — δεν εξήχθησαν δεδομένα';

  @override
  String dataBackupFailedError(String error) {
    return 'Το αντίγραφο απέτυχε: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Επιλογή αντιγράφου μηνυμάτων';

  @override
  String get dataInvalidBackupFile =>
      'Μη έγκυρο αρχείο αντιγράφου (πολύ μικρό)';

  @override
  String get dataNotValidBackupFile =>
      'Δεν είναι έγκυρο αρχείο αντιγράφου Pulse';

  @override
  String get dataRestoreMessages => 'Επαναφορά μηνυμάτων';

  @override
  String get dataRestorePasswordSubtitle =>
      'Εισαγάγετε τον κωδικό που χρησιμοποιήθηκε για τη δημιουργία αυτού του αντιγράφου.';

  @override
  String get dataRestoreConfirmLabel => 'Επαναφορά';

  @override
  String get dataRestoringMessages => 'Επαναφορά μηνυμάτων';

  @override
  String get dataRestoreDecrypting => 'Αποκρυπτογράφηση...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Εισαγωγή μηνύματος $done από $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Η επαναφορά απέτυχε — λάθος κωδικός ή κατεστραμμένο αρχείο';

  @override
  String dataRestoreSuccess(int count) {
    return 'Επαναφέρθηκαν $count νέα μηνύματα';
  }

  @override
  String get dataRestoreNothingNew =>
      'Δεν υπάρχουν νέα μηνύματα για εισαγωγή (υπάρχουν ήδη όλα)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Η επαναφορά απέτυχε: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Επιλογή εξαγωγής κλειδιών';

  @override
  String get dataNotValidKeyFile =>
      'Δεν είναι έγκυρο αρχείο εξαγωγής κλειδιών Pulse';

  @override
  String get dataExportKeys => 'Εξαγωγή κλειδιών';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Επιλέξτε κωδικό για κρυπτογράφηση της εξαγωγής κλειδιών.';

  @override
  String get dataExportKeysConfirmLabel => 'Εξαγωγή';

  @override
  String get dataExportingKeys => 'Εξαγωγή κλειδιών';

  @override
  String get dataExportingKeysStatus => 'Κρυπτογράφηση κλειδιών ταυτότητας...';

  @override
  String get dataSaveKeyExportDialog => 'Αποθήκευση εξαγωγής κλειδιών';

  @override
  String dataKeysExportedTo(String path) {
    return 'Τα κλειδιά εξήχθησαν σε:\n$path';
  }

  @override
  String get dataExportFailed => 'Η εξαγωγή απέτυχε — δεν βρέθηκαν κλειδιά';

  @override
  String dataExportFailedError(String error) {
    return 'Η εξαγωγή απέτυχε: $error';
  }

  @override
  String get dataImportKeys => 'Εισαγωγή κλειδιών';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Εισαγάγετε τον κωδικό που χρησιμοποιήθηκε για κρυπτογράφηση αυτής της εξαγωγής κλειδιών.';

  @override
  String get dataImportKeysConfirmLabel => 'Εισαγωγή';

  @override
  String get dataImportingKeys => 'Εισαγωγή κλειδιών';

  @override
  String get dataImportingKeysStatus =>
      'Αποκρυπτογράφηση κλειδιών ταυτότητας...';

  @override
  String get dataImportFailed =>
      'Η εισαγωγή απέτυχε — λάθος κωδικός ή κατεστραμμένο αρχείο';

  @override
  String dataImportFailedError(String error) {
    return 'Η εισαγωγή απέτυχε: $error';
  }

  @override
  String get securitySectionTitle => 'Ασφάλεια';

  @override
  String get securityIncorrectPassword => 'Λανθασμένος κωδικός';

  @override
  String get securityPasswordUpdated => 'Ο κωδικός ενημερώθηκε';

  @override
  String get appearanceSectionTitle => 'Εμφάνιση';

  @override
  String appearanceExportFailed(String error) {
    return 'Η εξαγωγή απέτυχε: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Αποθηκεύτηκε στο $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Η αποθήκευση απέτυχε: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Η εισαγωγή απέτυχε: $error';
  }

  @override
  String get aboutSectionTitle => 'Σχετικά';

  @override
  String get providerPublicKey => 'Δημόσιο κλειδί';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Αυτόματη ρύθμιση από τον κωδικό ανάκτησής σας. Το relay ανακαλύφθηκε αυτόματα.';

  @override
  String get providerKeyStoredLocally =>
      'Το κλειδί σας αποθηκεύεται τοπικά σε ασφαλή αποθήκευση — δεν αποστέλλεται ποτέ σε κανέναν διακομιστή.';

  @override
  String get providerOxenInfo =>
      'Δίκτυο Oxen/Session — E2EE δρομολογημένο μέσω onion. Το Session ID σας δημιουργείται αυτόματα και αποθηκεύεται με ασφάλεια. Οι κόμβοι ανακαλύπτονται αυτόματα από τους ενσωματωμένους κόμβους εκκίνησης.';

  @override
  String get providerAdvanced => 'Για προχωρημένους';

  @override
  String get providerSaveAndConnect => 'Αποθήκευση & Σύνδεση';

  @override
  String get providerAddSecondaryInbox => 'Προσθήκη δευτερεύοντος εισερχομένου';

  @override
  String get providerSecondaryInboxes => 'Δευτερεύοντα εισερχόμενα';

  @override
  String get providerYourInboxProvider => 'Ο πάροχος εισερχομένων σας';

  @override
  String get providerConnectionDetails => 'Λεπτομέρειες σύνδεσης';

  @override
  String get addContactTitle => 'Προσθήκη επαφής';

  @override
  String get addContactInviteLinkLabel => 'Σύνδεσμος πρόσκλησης ή διεύθυνση';

  @override
  String get addContactTapToPaste =>
      'Πατήστε για επικόλληση συνδέσμου πρόσκλησης';

  @override
  String get addContactPasteTooltip => 'Επικόλληση από πρόχειρο';

  @override
  String get addContactAddressDetected => 'Εντοπίστηκε διεύθυνση επαφής';

  @override
  String addContactRoutesDetected(int count) {
    return 'Εντοπίστηκαν $count διαδρομές — το SmartRouter επιλέγει την ταχύτερη';
  }

  @override
  String get addContactFetchingProfile => 'Ανάκτηση προφίλ…';

  @override
  String addContactProfileFound(String name) {
    return 'Βρέθηκε: $name';
  }

  @override
  String get addContactNoProfileFound => 'Δεν βρέθηκε προφίλ';

  @override
  String get addContactDisplayNameLabel => 'Εμφανιζόμενο όνομα';

  @override
  String get addContactDisplayNameHint => 'Πώς θέλετε να τους αποκαλείτε;';

  @override
  String get addContactAddManually => 'Μη αυτόματη εισαγωγή διεύθυνσης';

  @override
  String get addContactButton => 'Προσθήκη επαφής';

  @override
  String get networkDiagnosticsTitle => 'Διαγνωστικά δικτύου';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr Relay';

  @override
  String get networkDiagnosticsDirect => 'Άμεσα';

  @override
  String get networkDiagnosticsTorOnly => 'Μόνο Tor';

  @override
  String get networkDiagnosticsBest => 'Καλύτερο';

  @override
  String get networkDiagnosticsNone => 'κανένα';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Κατάσταση';

  @override
  String get networkDiagnosticsConnected => 'Συνδέθηκε';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Σύνδεση $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Ανενεργό';

  @override
  String get networkDiagnosticsTransport => 'Μεταφορά';

  @override
  String get networkDiagnosticsInfrastructure => 'Υποδομή';

  @override
  String get networkDiagnosticsOxenNodes => 'Κόμβοι Oxen';

  @override
  String get networkDiagnosticsTurnServers => 'Διακομιστές TURN';

  @override
  String get networkDiagnosticsLastProbe => 'Τελευταίος έλεγχος';

  @override
  String get networkDiagnosticsRunning => 'Εκτελείται...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Εκτέλεση διαγνωστικών';

  @override
  String get networkDiagnosticsForceReprobe =>
      'Αναγκαστικός πλήρης επανέλεγχος';

  @override
  String get networkDiagnosticsJustNow => 'μόλις τώρα';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'πριν $minutes λεπ.';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'πριν $hours ώρ.';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'πριν $days ημ.';
  }

  @override
  String get homeNoEch => 'Χωρίς ECH';

  @override
  String get homeNoEchTooltip =>
      'Ο uTLS proxy δεν είναι διαθέσιμος — ECH απενεργοποιημένο.\nΤο αποτύπωμα TLS είναι ορατό στο DPI.';

  @override
  String get settingsTitle => 'Ρυθμίσεις';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Αποθηκεύτηκε & συνδέθηκε στο $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Αποτυχία εκκίνησης ενσωματωμένου Tor';

  @override
  String get settingsPsiphonFailedToStart => 'Αποτυχία εκκίνησης Psiphon';

  @override
  String get verifyTitle => 'Επαλήθευση αριθμού ασφαλείας';

  @override
  String get verifyIdentityVerified => 'Ταυτότητα επαληθεύτηκε';

  @override
  String get verifyNotYetVerified => 'Δεν έχει επαληθευτεί ακόμα';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Έχετε επαληθεύσει τον αριθμό ασφαλείας του/της $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Συγκρίνετε αυτούς τους αριθμούς με τον/την $name αυτοπροσώπως ή μέσω αξιόπιστου καναλιού.';
  }

  @override
  String get verifyExplanation =>
      'Κάθε συνομιλία έχει έναν μοναδικό αριθμό ασφαλείας. Εάν βλέπετε και οι δύο τους ίδιους αριθμούς στις συσκευές σας, η σύνδεσή σας είναι επαληθευμένη από άκρο σε άκρο.';

  @override
  String verifyContactKey(String name) {
    return 'Κλειδί του/της $name';
  }

  @override
  String get verifyYourKey => 'Το κλειδί σας';

  @override
  String get verifyRemoveVerification => 'Αφαίρεση επαλήθευσης';

  @override
  String get verifyMarkAsVerified => 'Επισήμανση ως επαληθευμένο';

  @override
  String verifyAfterReinstall(String name) {
    return 'Εάν ο/η $name επανεγκαταστήσει την εφαρμογή, ο αριθμός ασφαλείας θα αλλάξει και η επαλήθευση θα αφαιρεθεί αυτόματα.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Επισημάνετε ως επαληθευμένο μόνο αφού συγκρίνετε τους αριθμούς με τον/την $name μέσω φωνητικής κλήσης ή αυτοπροσώπως.';
  }

  @override
  String get verifyNoSession =>
      'Δεν έχει δημιουργηθεί ακόμα συνεδρία κρυπτογράφησης. Στείλτε πρώτα ένα μήνυμα για να δημιουργηθούν αριθμοί ασφαλείας.';

  @override
  String get verifyNoKeyAvailable => 'Δεν υπάρχει διαθέσιμο κλειδί';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Το αποτύπωμα $label αντιγράφηκε';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL βάσης δεδομένων';

  @override
  String get providerOptionalHint => 'Προαιρετικό';

  @override
  String get providerWebApiKeyLabel => 'Web API Key';

  @override
  String get providerOptionalForPublicDb =>
      'Προαιρετικό για δημόσια βάση δεδομένων';

  @override
  String get providerRelayUrlLabel => 'URL Relay';

  @override
  String get providerPrivateKeyLabel => 'Ιδιωτικό κλειδί';

  @override
  String get providerPrivateKeyNsecLabel => 'Ιδιωτικό κλειδί (nsec)';

  @override
  String get providerStorageNodeLabel => 'URL κόμβου αποθήκευσης (προαιρετικό)';

  @override
  String get providerStorageNodeHint =>
      'Αφήστε κενό για τους ενσωματωμένους κόμβους εκκίνησης';

  @override
  String get transferInvalidCodeFormat =>
      'Μη αναγνωρίσιμη μορφή κωδικού — πρέπει να αρχίζει με LAN: ή NOS:';

  @override
  String get profileCardFingerprintCopied => 'Το αποτύπωμα αντιγράφηκε';

  @override
  String get profileCardAboutHint => 'Πρώτα η ιδιωτικότητα 🔒';

  @override
  String get profileCardSaveButton => 'Αποθήκευση προφίλ';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Εξαγωγή κρυπτογραφημένων μηνυμάτων, επαφών και avatar σε αρχείο';

  @override
  String get callVideo => 'Βίντεο';

  @override
  String get callAudio => 'Ήχος';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Παραδόθηκε σε $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Παραδόθηκε σε $count';
  }

  @override
  String get groupStatusDialogTitle => 'Πληροφορίες μηνύματος';

  @override
  String get groupStatusRead => 'Αναγνώστηκε';

  @override
  String get groupStatusDelivered => 'Παραδόθηκε';

  @override
  String get groupStatusPending => 'Σε εκκρεμότητα';

  @override
  String get groupStatusNoData => 'Δεν υπάρχουν ακόμα πληροφορίες παράδοσης';

  @override
  String get profileTransferAdmin => 'Ορισμός διαχειριστή';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Ορισμός $name ως νέου διαχειριστή;';
  }

  @override
  String get profileTransferAdminBody =>
      'Θα χάσετε τα δικαιώματα διαχειριστή. Αυτό δεν μπορεί να αναιρεθεί.';

  @override
  String profileTransferAdminDone(String name) {
    return 'Ο/Η $name είναι πλέον ο διαχειριστής';
  }

  @override
  String get profileAdminBadge => 'Διαχειριστής';

  @override
  String get privacyPolicyTitle => 'Πολιτική απορρήτου';

  @override
  String get privacyOverviewHeading => 'Επισκόπηση';

  @override
  String get privacyOverviewBody =>
      'Το Pulse είναι ένας messenger χωρίς διακομιστή, κρυπτογραφημένος από άκρο σε άκρο. Η ιδιωτικότητά σας δεν είναι απλώς ένα χαρακτηριστικό — είναι η αρχιτεκτονική. Δεν υπάρχουν διακομιστές Pulse. Κανένας λογαριασμός δεν αποθηκεύεται πουθενά. Κανένα δεδομένο δεν συλλέγεται, μεταδίδεται ή αποθηκεύεται από τους προγραμματιστές.';

  @override
  String get privacyDataCollectionHeading => 'Συλλογή δεδομένων';

  @override
  String get privacyDataCollectionBody =>
      'Το Pulse δεν συλλέγει κανένα προσωπικό δεδομένο. Συγκεκριμένα:\n\n- Δεν απαιτείται email, αριθμός τηλεφώνου ή πραγματικό όνομα\n- Χωρίς αναλυτικά στοιχεία, παρακολούθηση ή τηλεμετρία\n- Χωρίς αναγνωριστικά διαφήμισης\n- Χωρίς πρόσβαση στη λίστα επαφών\n- Χωρίς αντίγραφα στο cloud (τα μηνύματα υπάρχουν μόνο στη συσκευή σας)\n- Κανένα μεταδεδομένο δεν αποστέλλεται σε κανέναν διακομιστή Pulse (δεν υπάρχουν)';

  @override
  String get privacyEncryptionHeading => 'Κρυπτογράφηση';

  @override
  String get privacyEncryptionBody =>
      'Όλα τα μηνύματα κρυπτογραφούνται χρησιμοποιώντας το Signal Protocol (Double Ratchet με συμφωνία κλειδιών X3DH). Τα κλειδιά κρυπτογράφησης δημιουργούνται και αποθηκεύονται αποκλειστικά στη συσκευή σας. Κανείς — συμπεριλαμβανομένων των προγραμματιστών — δεν μπορεί να διαβάσει τα μηνύματά σας.';

  @override
  String get privacyNetworkHeading => 'Αρχιτεκτονική δικτύου';

  @override
  String get privacyNetworkBody =>
      'Το Pulse χρησιμοποιεί ομοσπονδιακούς μεταφορείς (Nostr relay, κόμβοι υπηρεσίας Session/Oxen, Firebase Realtime Database, LAN). Αυτοί οι μεταφορείς μεταφέρουν μόνο κρυπτογραφημένο κείμενο. Οι διαχειριστές relay μπορούν να δουν τη διεύθυνση IP σας και τον όγκο κίνησης, αλλά δεν μπορούν να αποκρυπτογραφήσουν το περιεχόμενο μηνυμάτων.\n\nΌταν είναι ενεργοποιημένο το Tor, η διεύθυνση IP σας είναι επίσης κρυφή από τους διαχειριστές relay.';

  @override
  String get privacyStunHeading => 'Διακομιστές STUN/TURN';

  @override
  String get privacyStunBody =>
      'Οι φωνητικές και βιντεοκλήσεις χρησιμοποιούν WebRTC με κρυπτογράφηση DTLS-SRTP. Οι διακομιστές STUN (για ανακάλυψη δημόσιας IP για συνδέσεις peer-to-peer) και οι διακομιστές TURN (για αναμετάδοση πολυμέσων όταν η άμεση σύνδεση αποτύχει) μπορούν να δουν τη διεύθυνση IP σας και τη διάρκεια κλήσης, αλλά δεν μπορούν να αποκρυπτογραφήσουν το περιεχόμενο κλήσης.\n\nΜπορείτε να ρυθμίσετε τον δικό σας διακομιστή TURN στις Ρυθμίσεις για μέγιστη ιδιωτικότητα.';

  @override
  String get privacyCrashHeading => 'Αναφορές σφαλμάτων';

  @override
  String get privacyCrashBody =>
      'Εάν η αναφορά σφαλμάτων Sentry είναι ενεργοποιημένη (μέσω SENTRY_DSN κατά τη μεταγλώττιση), ενδέχεται να αποσταλούν ανώνυμες αναφορές σφαλμάτων. Αυτές δεν περιέχουν περιεχόμενο μηνυμάτων, πληροφορίες επαφών ή προσωπικά αναγνωρίσιμες πληροφορίες. Οι αναφορές σφαλμάτων μπορούν να απενεργοποιηθούν κατά τη μεταγλώττιση παραλείποντας το DSN.';

  @override
  String get privacyPasswordHeading => 'Κωδικός & Κλειδιά';

  @override
  String get privacyPasswordBody =>
      'Ο κωδικός ανάκτησής σας χρησιμοποιείται για την παραγωγή κρυπτογραφικών κλειδιών μέσω Argon2id (KDF σκληρής μνήμης). Ο κωδικός δεν μεταδίδεται ποτέ πουθενά. Εάν χάσετε τον κωδικό σας, ο λογαριασμός σας δεν μπορεί να ανακτηθεί — δεν υπάρχει διακομιστής για επαναφορά.';

  @override
  String get privacyFontsHeading => 'Γραμματοσειρές';

  @override
  String get privacyFontsBody =>
      'Το Pulse περιλαμβάνει όλες τις γραμματοσειρές τοπικά. Δεν γίνονται αιτήματα στο Google Fonts ή σε οποιαδήποτε εξωτερική υπηρεσία γραμματοσειρών.';

  @override
  String get privacyThirdPartyHeading => 'Υπηρεσίες τρίτων';

  @override
  String get privacyThirdPartyBody =>
      'Το Pulse δεν ενσωματώνεται με κανένα διαφημιστικό δίκτυο, πάροχο αναλυτικών, πλατφόρμα κοινωνικών μέσων ή μεσίτη δεδομένων. Οι μόνες συνδέσεις δικτύου είναι στα relay μεταφοράς που ρυθμίζετε.';

  @override
  String get privacyOpenSourceHeading => 'Ανοικτός κώδικας';

  @override
  String get privacyOpenSourceBody =>
      'Το Pulse είναι λογισμικό ανοικτού κώδικα. Μπορείτε να ελέγξετε τον πλήρη πηγαίο κώδικα για να επαληθεύσετε αυτές τις δηλώσεις απορρήτου.';

  @override
  String get privacyContactHeading => 'Επικοινωνία';

  @override
  String get privacyContactBody =>
      'Για ερωτήσεις σχετικά με το απόρρητο, ανοίξτε ένα issue στο αποθετήριο του έργου.';

  @override
  String get privacyLastUpdated => 'Τελευταία ενημέρωση: Μάρτιος 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Η αποθήκευση απέτυχε: $error';
  }

  @override
  String get themeEngineTitle => 'Μηχανή θεμάτων';

  @override
  String get torBuiltInTitle => 'Ενσωματωμένο Tor';

  @override
  String get torConnectedSubtitle =>
      'Συνδέθηκε — Nostr δρομολογείται μέσω 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Σύνδεση… $pct%';
  }

  @override
  String get torNotRunning =>
      'Δεν εκτελείται — πατήστε τον διακόπτη για επανεκκίνηση';

  @override
  String get torDescription =>
      'Δρομολογεί Nostr μέσω Tor (Snowflake για λογοκριμένα δίκτυα)';

  @override
  String get torNetworkDiagnostics => 'Διαγνωστικά δικτύου';

  @override
  String get torTransportLabel => 'Μεταφορά: ';

  @override
  String get torPtAuto => 'Αυτόματο';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Απλό';

  @override
  String get torTimeoutLabel => 'Χρονικό όριο: ';

  @override
  String get torInfoDescription =>
      'Όταν είναι ενεργοποιημένο, οι συνδέσεις Nostr WebSocket δρομολογούνται μέσω Tor (SOCKS5). Ο Tor Browser ακούει στη 127.0.0.1:9150. Ο αυτόνομος δαίμονας tor χρησιμοποιεί τη θύρα 9050. Οι συνδέσεις Firebase δεν επηρεάζονται.';

  @override
  String get torRouteNostrTitle => 'Δρομολόγηση Nostr μέσω Tor';

  @override
  String get torManagedByBuiltin => 'Διαχείριση από ενσωματωμένο Tor';

  @override
  String get torActiveRouting =>
      'Ενεργό — η κίνηση Nostr δρομολογείται μέσω Tor';

  @override
  String get torDisabled => 'Απενεργοποιημένο';

  @override
  String get torProxySocks5 => 'Tor Proxy (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Κεντρικός υπολογιστής proxy';

  @override
  String get torProxyPortLabel => 'Θύρα';

  @override
  String get torPortInfo =>
      'Tor Browser: θύρα 9150  •  Δαίμονας tor: θύρα 9050';

  @override
  String get i2pProxySocks5 => 'I2P Proxy (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'Το I2P χρησιμοποιεί SOCKS5 στη θύρα 4447 από προεπιλογή. Συνδεθείτε σε ένα Nostr relay μέσω I2P outproxy (π.χ. relay.damus.i2p) για επικοινωνία με χρήστες σε οποιαδήποτε μεταφορά. Το Tor έχει προτεραιότητα όταν είναι ενεργοποιημένα και τα δύο.';

  @override
  String get i2pRouteNostrTitle => 'Δρομολόγηση Nostr μέσω I2P';

  @override
  String get i2pActiveRouting =>
      'Ενεργό — η κίνηση Nostr δρομολογείται μέσω I2P';

  @override
  String get i2pDisabled => 'Απενεργοποιημένο';

  @override
  String get i2pProxyHostLabel => 'Κεντρικός υπολογιστής proxy';

  @override
  String get i2pProxyPortLabel => 'Θύρα';

  @override
  String get i2pPortInfo => 'Προεπιλεγμένη θύρα SOCKS5 δρομολογητή I2P: 4447';

  @override
  String get customProxySocks5 => 'Προσαρμοσμένο Proxy (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Το προσαρμοσμένο proxy δρομολογεί την κίνηση μέσω του V2Ray/Xray/Shadowsocks σας. Το CF Worker λειτουργεί ως προσωπικό relay proxy στο Cloudflare CDN — η GFW βλέπει *.workers.dev, όχι το πραγματικό relay.';

  @override
  String get customSocks5ProxyTitle => 'Προσαρμοσμένο SOCKS5 Proxy';

  @override
  String get customProxyActive => 'Ενεργό — η κίνηση δρομολογείται μέσω SOCKS5';

  @override
  String get customProxyDisabled => 'Απενεργοποιημένο';

  @override
  String get customProxyHostLabel => 'Κεντρικός υπολογιστής proxy';

  @override
  String get customProxyPortLabel => 'Θύρα';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Domain Worker (προαιρετικό)';

  @override
  String get customWorkerHelpTitle =>
      'Πώς να αναπτύξετε ένα CF Worker relay (δωρεάν)';

  @override
  String get customWorkerScriptCopied => 'Το script αντιγράφηκε!';

  @override
  String get customWorkerStep1 =>
      '1. Μεταβείτε στο dash.cloudflare.com → Workers & Pages\n2. Create Worker → επικολλήστε αυτό το script:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → αντιγράψτε το domain (π.χ. my-relay.user.workers.dev)\n4. Επικολλήστε το domain παραπάνω → Αποθήκευση\n\nΗ εφαρμογή συνδέεται αυτόματα: wss://domain/?r=relay_url\nΗ GFW βλέπει: σύνδεση στο *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Συνδέθηκε — SOCKS5 στη 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Σύνδεση…';

  @override
  String get psiphonNotRunning =>
      'Δεν εκτελείται — πατήστε τον διακόπτη για επανεκκίνηση';

  @override
  String get psiphonDescription =>
      'Γρήγορη σήραγγα (~3s εκκίνηση, 2000+ περιστρεφόμενα VPS)';

  @override
  String get turnCommunityServers => 'Κοινοτικοί διακομιστές TURN';

  @override
  String get turnCustomServer => 'Προσαρμοσμένος διακομιστής TURN (BYOD)';

  @override
  String get turnInfoDescription =>
      'Οι διακομιστές TURN αναμεταδίδουν μόνο ήδη κρυπτογραφημένα streams (DTLS-SRTP). Ένας διαχειριστής relay βλέπει τη διεύθυνση IP σας και τον όγκο κίνησης, αλλά δεν μπορεί να αποκρυπτογραφήσει κλήσεις. Το TURN χρησιμοποιείται μόνο όταν αποτυγχάνει η απευθείας P2P σύνδεση (~15–20% των συνδέσεων).';

  @override
  String get turnFreeLabel => 'ΔΩΡΕΑΝ';

  @override
  String get turnServerUrlLabel => 'URL διακομιστή TURN';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 ή turns:...';

  @override
  String get turnUsernameLabel => 'Όνομα χρήστη';

  @override
  String get turnPasswordLabel => 'Κωδικός';

  @override
  String get turnOptionalHint => 'Προαιρετικό';

  @override
  String get turnCustomInfo =>
      'Φιλοξενήστε coturn σε οποιοδήποτε VPS 5\$/μήνα για μέγιστο έλεγχο. Τα διαπιστευτήρια αποθηκεύονται τοπικά.';

  @override
  String get themePickerAppearance => 'Εμφάνιση';

  @override
  String get themePickerAccentColor => 'Χρώμα έμφασης';

  @override
  String get themeModeLight => 'Φωτεινό';

  @override
  String get themeModeDark => 'Σκοτεινό';

  @override
  String get themeModeSystem => 'Σύστημα';

  @override
  String get themeDynamicPresets => 'Προεπιλογές';

  @override
  String get themeDynamicPrimaryColor => 'Κύριο χρώμα';

  @override
  String get themeDynamicBorderRadius => 'Ακτίνα περιγράμματος';

  @override
  String get themeDynamicFont => 'Γραμματοσειρά';

  @override
  String get themeDynamicAppearance => 'Εμφάνιση';

  @override
  String get themeDynamicUiStyle => 'Στυλ UI';

  @override
  String get themeDynamicUiStyleDescription =>
      'Ελέγχει την εμφάνιση διαλόγων, διακοπτών και δεικτών.';

  @override
  String get themeDynamicSharp => 'Αιχμηρό';

  @override
  String get themeDynamicRound => 'Στρογγυλό';

  @override
  String get themeDynamicModeDark => 'Σκοτεινό';

  @override
  String get themeDynamicModeLight => 'Φωτεινό';

  @override
  String get themeDynamicModeAuto => 'Αυτόματο';

  @override
  String get themeDynamicPlatformAuto => 'Αυτόματο';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'Μη έγκυρο Firebase URL. Αναμενόμενο: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Μη έγκυρο URL relay. Αναμενόμενο: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Μη έγκυρο URL διακομιστή Pulse. Αναμενόμενο: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'URL διακομιστή';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'Κωδικός πρόσκλησης';

  @override
  String get providerPulseInviteHint => 'Κωδικός πρόσκλησης (εάν απαιτείται)';

  @override
  String get providerPulseInfo =>
      'Αυτο-φιλοξενούμενο relay. Κλειδιά παραγόμενα από τον κωδικό ανάκτησής σας.';

  @override
  String get providerScreenTitle => 'Εισερχόμενα';

  @override
  String get providerSecondaryInboxesHeader => 'ΔΕΥΤΕΡΕΥΟΝΤΑ ΕΙΣΕΡΧΟΜΕΝΑ';

  @override
  String get providerSecondaryInboxesInfo =>
      'Τα δευτερεύοντα εισερχόμενα λαμβάνουν μηνύματα ταυτόχρονα για πλεονασμό.';

  @override
  String get providerRemoveTooltip => 'Αφαίρεση';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... ή hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... ή hex ιδιωτικό κλειδί';

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
  String get emojiNoRecent => 'Δεν υπάρχουν πρόσφατα emoji';

  @override
  String get emojiSearchHint => 'Αναζήτηση emoji...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Πατήστε για συνομιλία';

  @override
  String get imageViewerSaveToDownloads => 'Αποθήκευση στο Downloads';

  @override
  String imageViewerSavedTo(String path) {
    return 'Αποθηκεύτηκε στο $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Γλώσσα';

  @override
  String get settingsLanguageSubtitle => 'Γλώσσα εμφάνισης εφαρμογής';

  @override
  String get settingsLanguageSystem => 'Προεπιλογή συστήματος';

  @override
  String get onboardingLanguageTitle => 'Επιλέξτε τη γλώσσα σας';

  @override
  String get onboardingLanguageSubtitle =>
      'Μπορείτε να το αλλάξετε αργότερα στις Ρυθμίσεις';

  @override
  String get videoNoteRecord => 'Εγγραφή βιντεομηνύματος';

  @override
  String get videoNoteTapToRecord => 'Πατήστε για εγγραφή';

  @override
  String get videoNoteTapToStop => 'Πατήστε για διακοπή';

  @override
  String get videoNoteCameraPermission => 'Άρνηση πρόσβασης κάμερας';

  @override
  String get videoNoteMaxDuration => 'Μέγιστο 30 δευτερόλεπτα';

  @override
  String get videoNoteNotSupported =>
      'Οι σημειώσεις βίντεο δεν υποστηρίζονται σε αυτή την πλατφόρμα';
}
