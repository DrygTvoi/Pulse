// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Szukaj wiadomości...';

  @override
  String get search => 'Szukaj';

  @override
  String get clearSearch => 'Wyczyść wyszukiwanie';

  @override
  String get closeSearch => 'Zamknij wyszukiwanie';

  @override
  String get moreOptions => 'Więcej opcji';

  @override
  String get back => 'Wstecz';

  @override
  String get cancel => 'Anuluj';

  @override
  String get close => 'Zamknij';

  @override
  String get confirm => 'Potwierdź';

  @override
  String get remove => 'Usuń';

  @override
  String get save => 'Zapisz';

  @override
  String get add => 'Dodaj';

  @override
  String get copy => 'Kopiuj';

  @override
  String get skip => 'Pomiń';

  @override
  String get done => 'Gotowe';

  @override
  String get apply => 'Zastosuj';

  @override
  String get export => 'Eksportuj';

  @override
  String get import => 'Importuj';

  @override
  String get homeNewGroup => 'Nowa grupa';

  @override
  String get homeSettings => 'Ustawienia';

  @override
  String get homeSearching => 'Wyszukiwanie wiadomości...';

  @override
  String get homeNoResults => 'Brak wyników';

  @override
  String get homeNoChatHistory => 'Brak historii czatów';

  @override
  String homeTransportSwitched(String address) {
    return 'Transport przełączony → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name dzwoni...';
  }

  @override
  String get homeAccept => 'Odbierz';

  @override
  String get homeDecline => 'Odrzuć';

  @override
  String get homeLoadEarlier => 'Załaduj wcześniejsze wiadomości';

  @override
  String get homeChats => 'Czaty';

  @override
  String get homeSelectConversation => 'Wybierz rozmowę';

  @override
  String get homeNoChatsYet => 'Brak czatów';

  @override
  String get homeAddContactToStart => 'Dodaj kontakt, aby rozpocząć';

  @override
  String get homeNewChat => 'Nowy czat';

  @override
  String get homeNewChatTooltip => 'Nowy czat';

  @override
  String get homeIncomingCallTitle => 'Połączenie przychodzące';

  @override
  String get homeIncomingGroupCallTitle => 'Przychodzące połączenie grupowe';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — przychodzące połączenie grupowe';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Brak czatów pasujących do „$query”';
  }

  @override
  String get homeSectionChats => 'Czaty';

  @override
  String get homeSectionMessages => 'Wiadomości';

  @override
  String get homeDbEncryptionUnavailable =>
      'Szyfrowanie bazy danych niedostępne — zainstaluj SQLCipher dla pełnej ochrony';

  @override
  String get chatFileTooLargeGroup =>
      'Pliki powyżej 512 KB nie są obsługiwane w czatach grupowych';

  @override
  String get chatLargeFile => 'Duży plik';

  @override
  String get chatCancel => 'Anuluj';

  @override
  String get chatSend => 'Wyślij';

  @override
  String get chatFileTooLarge => 'Plik za duży — maksymalny rozmiar to 100 MB';

  @override
  String get chatMicDenied => 'Odmowa dostępu do mikrofonu';

  @override
  String get chatVoiceFailed =>
      'Nie udało się zapisać wiadomości głosowej — sprawdź dostępną pamięć';

  @override
  String get chatScheduleFuture => 'Zaplanowany czas musi być w przyszłości';

  @override
  String get chatToday => 'Dziś';

  @override
  String get chatYesterday => 'Wczoraj';

  @override
  String get chatEdited => 'edytowano';

  @override
  String get chatYou => 'Ty';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Ten plik ma $size MB. Wysyłanie dużych plików może być wolne w niektórych sieciach. Kontynuować?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Klucz bezpieczeństwa $name został zmieniony. Kliknij, aby zweryfikować.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Nie udało się zaszyfrować wiadomości do $name — wiadomość nie została wysłana.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Numer bezpieczeństwa zmienił się dla $name. Kliknij, aby zweryfikować.';
  }

  @override
  String get chatNoMessagesFound => 'Nie znaleziono wiadomości';

  @override
  String get chatMessagesE2ee => 'Wiadomości są szyfrowane end-to-end';

  @override
  String get chatSayHello => 'Przywitaj się';

  @override
  String get appBarOnline => 'online';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'pisze';

  @override
  String get appBarSearchMessages => 'Szukaj wiadomości...';

  @override
  String get appBarMute => 'Wycisz';

  @override
  String get appBarUnmute => 'Wyłącz wyciszenie';

  @override
  String get appBarMedia => 'Media';

  @override
  String get appBarDisappearing => 'Znikające wiadomości';

  @override
  String get appBarDisappearingOn => 'Znikające: włączone';

  @override
  String get appBarGroupSettings => 'Ustawienia grupy';

  @override
  String get appBarSearchTooltip => 'Szukaj wiadomości';

  @override
  String get appBarVoiceCall => 'Połączenie głosowe';

  @override
  String get appBarVideoCall => 'Połączenie wideo';

  @override
  String get inputMessage => 'Wiadomość...';

  @override
  String get inputAttachFile => 'Załącz plik';

  @override
  String get inputSendMessage => 'Wyślij wiadomość';

  @override
  String get inputRecordVoice => 'Nagraj wiadomość głosową';

  @override
  String get inputSendVoice => 'Wyślij wiadomość głosową';

  @override
  String get inputCancelReply => 'Anuluj odpowiedź';

  @override
  String get inputCancelEdit => 'Anuluj edycję';

  @override
  String get inputCancelRecording => 'Anuluj nagrywanie';

  @override
  String get inputRecording => 'Nagrywanie…';

  @override
  String get inputEditingMessage => 'Edytowanie wiadomości';

  @override
  String get inputPhoto => 'Zdjęcie';

  @override
  String get inputVoiceMessage => 'Wiadomość głosowa';

  @override
  String get inputFile => 'Plik';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zaplanowanych wiadomości',
      few: '$count zaplanowane wiadomości',
      one: '1 zaplanowana wiadomość',
    );
    return '$_temp0';
  }

  @override
  String get callInitializing => 'Inicjalizowanie połączenia…';

  @override
  String get callConnecting => 'Łączenie…';

  @override
  String get callConnectingRelay => 'Łączenie (przekaźnik)…';

  @override
  String get callSwitchingRelay => 'Przełączanie na tryb przekaźnika…';

  @override
  String get callConnectionFailed => 'Połączenie nie powiodło się';

  @override
  String get callReconnecting => 'Ponowne łączenie…';

  @override
  String get callEnded => 'Połączenie zakończone';

  @override
  String get callLive => 'Na żywo';

  @override
  String get callEnd => 'Zakończ';

  @override
  String get callEndCall => 'Zakończ połączenie';

  @override
  String get callMute => 'Wycisz';

  @override
  String get callUnmute => 'Wyłącz wyciszenie';

  @override
  String get callSpeaker => 'Głośnik';

  @override
  String get callCameraOn => 'Kamera wł.';

  @override
  String get callCameraOff => 'Kamera wył.';

  @override
  String get callShareScreen => 'Udostępnij ekran';

  @override
  String get callStopShare => 'Zatrzymaj udostępnianie';

  @override
  String callTorBackup(String duration) {
    return 'Tor zapasowy · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor zapasowy aktywny — ścieżka główna niedostępna';

  @override
  String get callDirectFailed =>
      'Bezpośrednie połączenie nie powiodło się — przełączanie na tryb przekaźnika…';

  @override
  String get callTurnUnreachable =>
      'Serwery TURN nieosiągalne. Dodaj własny TURN w Ustawienia → Zaawansowane.';

  @override
  String get callRelayMode => 'Tryb przekaźnika aktywny (ograniczona sieć)';

  @override
  String get callStarting => 'Rozpoczynanie połączenia…';

  @override
  String get callConnectingToGroup => 'Łączenie z grupą…';

  @override
  String get callGroupOpenedInBrowser =>
      'Połączenie grupowe otwarte w przeglądarce';

  @override
  String get callCouldNotOpenBrowser => 'Nie udało się otworzyć przeglądarki';

  @override
  String get callInviteLinkSent =>
      'Link zaproszenia wysłany do wszystkich członków grupy.';

  @override
  String get callOpenLinkManually =>
      'Otwórz powyższy link ręcznie lub kliknij, aby ponowić.';

  @override
  String get callJitsiNotE2ee =>
      'Połączenia Jitsi NIE są szyfrowane end-to-end';

  @override
  String get callRetryOpenBrowser => 'Ponów otwarcie przeglądarki';

  @override
  String get callClose => 'Zamknij';

  @override
  String get callCamOn => 'Kamera wł.';

  @override
  String get callCamOff => 'Kamera wył.';

  @override
  String get noConnection =>
      'Brak połączenia — wiadomości zostaną zakolejkowane';

  @override
  String get connected => 'Połączono';

  @override
  String get connecting => 'Łączenie…';

  @override
  String get disconnected => 'Rozłączono';

  @override
  String get offlineBanner =>
      'Brak połączenia — wiadomości zostaną zakolejkowane i wysłane po przywróceniu połączenia';

  @override
  String get lanModeBanner => 'Tryb LAN — Brak internetu · Tylko sieć lokalna';

  @override
  String get probeCheckingNetwork => 'Sprawdzanie łączności sieciowej…';

  @override
  String get probeDiscoveringRelays =>
      'Odkrywanie przekaźników przez katalogi społeczności…';

  @override
  String get probeStartingTor => 'Uruchamianie Tor do bootstrapu…';

  @override
  String get probeFindingRelaysTor =>
      'Szukanie dostępnych przekaźników przez Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sieć gotowa — znaleziono $count przekaźników',
      few: 'Sieć gotowa — znaleziono $count przekaźniki',
      one: 'Sieć gotowa — znaleziono 1 przekaźnik',
    );
    return '$_temp0';
  }

  @override
  String get probeNoRelaysFound =>
      'Nie znaleziono osiągalnych przekaźników — wiadomości mogą być opóźnione';

  @override
  String get jitsiWarningTitle => 'Brak szyfrowania end-to-end';

  @override
  String get jitsiWarningBody =>
      'Połączenia Jitsi Meet nie są szyfrowane przez Pulse. Używaj tylko do niezajmujących rozmów.';

  @override
  String get jitsiConfirm => 'Dołącz mimo to';

  @override
  String get jitsiGroupWarningTitle => 'Brak szyfrowania end-to-end';

  @override
  String get jitsiGroupWarningBody =>
      'To połączenie ma zbyt wielu uczestników dla wbudowanej siatki szyfrowanej.\n\nLink do Jitsi Meet zostanie otwarty w przeglądarce. Jitsi NIE jest szyfrowane end-to-end — serwer widzi Twoje połączenie.';

  @override
  String get jitsiContinueAnyway => 'Kontynuuj mimo to';

  @override
  String get retry => 'Ponów';

  @override
  String get setupCreateAnonymousAccount => 'Utwórz anonimowe konto';

  @override
  String get setupTapToChangeColor => 'Kliknij, aby zmienić kolor';

  @override
  String get setupReqMinLength => 'Co najmniej 16 znaków';

  @override
  String get setupReqVariety => '3 z 4: wielkie, małe litery, cyfry, symbole';

  @override
  String get setupReqMatch => 'Hasła są zgodne';

  @override
  String get setupYourNickname => 'Twój pseudonim';

  @override
  String get setupRecoveryPassword => 'Hasło odzyskiwania (min. 16)';

  @override
  String get setupConfirmPassword => 'Potwierdź hasło';

  @override
  String get setupMin16Chars => 'Minimum 16 znaków';

  @override
  String get setupPasswordsDoNotMatch => 'Hasła nie pasują do siebie';

  @override
  String get setupEntropyWeak => 'Słabe';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Silne';

  @override
  String get setupEntropyWeakNeedsVariety => 'Słabe (potrzeba 3 typów znaków)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bitów)';
  }

  @override
  String get setupPasswordWarning =>
      'To hasło jest jedynym sposobem na przywrócenie konta. Nie ma serwera — nie ma resetowania hasła. Zapamiętaj je lub zapisz.';

  @override
  String get setupCreateAccount => 'Utwórz konto';

  @override
  String get setupAlreadyHaveAccount => 'Masz już konto? ';

  @override
  String get setupRestore => 'Przywróć →';

  @override
  String get restoreTitle => 'Przywróć konto';

  @override
  String get restoreInfoBanner =>
      'Wpisz hasło odzyskiwania — Twój adres (Nostr + Session) zostanie przywrócony automatycznie. Kontakty i wiadomości były przechowywane tylko lokalnie.';

  @override
  String get restoreNewNickname => 'Nowy pseudonim (można zmienić później)';

  @override
  String get restoreButton => 'Przywróć konto';

  @override
  String get lockTitle => 'Pulse jest zablokowany';

  @override
  String get lockSubtitle => 'Wpisz hasło, aby kontynuować';

  @override
  String get lockPasswordHint => 'Hasło';

  @override
  String get lockUnlock => 'Odblokuj';

  @override
  String get lockPanicHint =>
      'Zapomniałeś hasła? Wpisz klucz paniki, aby wymazać wszystkie dane.';

  @override
  String get lockTooManyAttempts =>
      'Zbyt wiele prób. Usuwanie wszystkich danych…';

  @override
  String get lockWrongPassword => 'Błędne hasło';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Błędne hasło — $attempts/$max prób';
  }

  @override
  String get onboardingSkip => 'Pomiń';

  @override
  String get onboardingNext => 'Dalej';

  @override
  String get onboardingGetStarted => 'Utwórz konto';

  @override
  String get onboardingWelcomeTitle => 'Witaj w Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Zdecentralizowany komunikator z szyfrowaniem end-to-end.\n\nBrak centralnych serwerów. Brak zbierania danych. Brak tylnych drzwi.\nTwoje rozmowy należą tylko do Ciebie.';

  @override
  String get onboardingTransportTitle => 'Niezależny od transportu';

  @override
  String get onboardingTransportBody =>
      'Używaj Firebase, Nostr lub obu jednocześnie.\n\nWiadomości są automatycznie kierowane przez sieci. Wbudowana obsługa Tor i I2P dla odporności na cenzurę.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Każda wiadomość jest szyfrowana protokołem Signal (Double Ratchet + X3DH) zapewniającym forward secrecy.\n\nDodatkowo owinięta Kyber-1024 — algorytmem postkwantowym standardu NIST — chroniącym przed przyszłymi komputerami kwantowymi.';

  @override
  String get onboardingKeysTitle => 'Twoje klucze należą do Ciebie';

  @override
  String get onboardingKeysBody =>
      'Twoje klucze tożsamości nigdy nie opuszczają urządzenia.\n\nOdciski palców Signal pozwalają weryfikować kontakty pozapasmowo. TOFU (Trust On First Use) automatycznie wykrywa zmiany kluczy.';

  @override
  String get onboardingThemeTitle => 'Wybierz swój styl';

  @override
  String get onboardingThemeBody =>
      'Wybierz motyw i kolor akcentu. Możesz to zmienić później w Ustawieniach.';

  @override
  String get contactsNewChat => 'Nowy czat';

  @override
  String get contactsAddContact => 'Dodaj kontakt';

  @override
  String get contactsSearchHint => 'Szukaj...';

  @override
  String get contactsNewGroup => 'Nowa grupa';

  @override
  String get contactsNoContactsYet => 'Brak kontaktów';

  @override
  String get contactsAddHint => 'Kliknij +, aby dodać czyjś adres';

  @override
  String get contactsNoMatch => 'Brak pasujących kontaktów';

  @override
  String get contactsRemoveTitle => 'Usuń kontakt';

  @override
  String contactsRemoveMessage(String name) {
    return 'Usunąć $name?';
  }

  @override
  String get contactsRemove => 'Usuń';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kontaktów',
      few: '$count kontakty',
      one: '1 kontakt',
    );
    return '$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Otwórz link';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Otworzyć ten URL w przeglądarce?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Otwórz';

  @override
  String get bubbleSecurityWarning => 'Ostrzeżenie bezpieczeństwa';

  @override
  String bubbleExecutableWarning(String name) {
    return '„$name” jest plikiem wykonywalnym. Zapisanie i uruchomienie go może zaszkodzić urządzeniu. Zapisać mimo to?';
  }

  @override
  String get bubbleSaveAnyway => 'Zapisz mimo to';

  @override
  String bubbleSavedTo(String path) {
    return 'Zapisano w $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Zapis nie powiódł się: $error';
  }

  @override
  String get bubbleNotEncrypted => 'NIEZASZYFROWANE';

  @override
  String get bubbleCorruptedImage => '[Uszkodzony obraz]';

  @override
  String get bubbleReplyPhoto => 'Zdjęcie';

  @override
  String get bubbleReplyVoice => 'Wiadomość głosowa';

  @override
  String get bubbleReplyVideo => 'Wiadomość wideo';

  @override
  String bubbleReadBy(String names) {
    return 'Przeczytane przez $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Przeczytane przez $count';
  }

  @override
  String get chatTileTapToStart => 'Kliknij, aby rozpocząć rozmowę';

  @override
  String get chatTileMessageSent => 'Wiadomość wysłana';

  @override
  String get chatTileEncryptedMessage => 'Zaszyfrowana wiadomość';

  @override
  String chatTileYouPrefix(String text) {
    return 'Ty: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Wiadomość głosowa';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Wiadomość głosowa ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Zaszyfrowana wiadomość';

  @override
  String get groupNewGroup => 'Nowa grupa';

  @override
  String get groupGroupName => 'Nazwa grupy';

  @override
  String get groupSelectMembers => 'Wybierz członków (min. 2)';

  @override
  String get groupNoContactsYet => 'Brak kontaktów. Najpierw dodaj kontakty.';

  @override
  String get groupCreate => 'Utwórz';

  @override
  String get groupLabel => 'Grupa';

  @override
  String get profileVerifyIdentity => 'Zweryfikuj tożsamość';

  @override
  String profileVerifyInstructions(String name) {
    return 'Porównaj te odciski palców z $name podczas rozmowy głosowej lub osobiście. Jeśli obie wartości się zgadzają na obu urządzeniach, kliknij „Oznacz jako zweryfikowane”.';
  }

  @override
  String get profileTheirKey => 'Ich klucz';

  @override
  String get profileYourKey => 'Twój klucz';

  @override
  String get profileRemoveVerification => 'Usuń weryfikację';

  @override
  String get profileMarkAsVerified => 'Oznacz jako zweryfikowane';

  @override
  String get profileAddressCopied => 'Adres skopiowany';

  @override
  String get profileNoContactsToAdd =>
      'Brak kontaktów do dodania — wszyscy są już członkami';

  @override
  String get profileAddMembers => 'Dodaj członków';

  @override
  String profileAddCount(int count) {
    return 'Dodaj ($count)';
  }

  @override
  String get profileRenameGroup => 'Zmień nazwę grupy';

  @override
  String get profileRename => 'Zmień nazwę';

  @override
  String get profileRemoveMember => 'Usunąć członka?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Usunąć $name z tej grupy?';
  }

  @override
  String get profileKick => 'Wyrzuć';

  @override
  String get profileSignalFingerprints => 'Odciski palców Signal';

  @override
  String get profileVerified => 'ZWERYFIKOWANE';

  @override
  String get profileVerify => 'Zweryfikuj';

  @override
  String get profileEdit => 'Edytuj';

  @override
  String get profileNoSession =>
      'Sesja nie została jeszcze nawiązana — wyślij najpierw wiadomość.';

  @override
  String get profileFingerprintCopied => 'Odcisk palca skopiowany';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count członków',
      few: '$count członków',
      one: '1 członek',
    );
    return '$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Zweryfikuj numer bezpieczeństwa';

  @override
  String get profileShowContactQr => 'Pokaż QR kontaktu';

  @override
  String profileContactAddress(String name) {
    return 'Adres $name';
  }

  @override
  String get profileExportChatHistory => 'Eksportuj historię czatu';

  @override
  String profileSavedTo(String path) {
    return 'Zapisano w $path';
  }

  @override
  String get profileExportFailed => 'Eksport nie powiódł się';

  @override
  String get profileClearChatHistory => 'Wyczyść historię czatu';

  @override
  String get profileDeleteGroup => 'Usuń grupę';

  @override
  String get profileDeleteContact => 'Usuń kontakt';

  @override
  String get profileLeaveGroup => 'Opuść grupę';

  @override
  String get profileLeaveGroupBody =>
      'Zostaniesz usunięty z tej grupy i zostanie ona usunięta z Twoich kontaktów.';

  @override
  String get groupInviteTitle => 'Zaproszenie do grupy';

  @override
  String groupInviteBody(String from, String group) {
    return '$from zaprasza Cię do grupy „$group”';
  }

  @override
  String get groupInviteAccept => 'Akceptuj';

  @override
  String get groupInviteDecline => 'Odrzuć';

  @override
  String get groupMemberLimitTitle => 'Zbyt wielu uczestników';

  @override
  String groupMemberLimitBody(int count) {
    return 'Ta grupa będzie mieć $count uczestników. Szyfrowane połączenia siatkowe obsługują do 6 osób. Większe grupy przechodzą na Jitsi (bez E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Dodaj mimo to';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name odmówił dołączenia do „$group”';
  }

  @override
  String get transferTitle => 'Transfer na inne urządzenie';

  @override
  String get transferInfoBox =>
      'Przenieś swoją tożsamość Signal i klucze Nostr na nowe urządzenie.\nSesje czatu NIE są przenoszone — forward secrecy jest zachowany.';

  @override
  String get transferSendFromThis => 'Wyślij z tego urządzenia';

  @override
  String get transferSendSubtitle =>
      'To urządzenie posiada klucze. Udostępnij kod nowemu urządzeniu.';

  @override
  String get transferReceiveOnThis => 'Odbierz na tym urządzeniu';

  @override
  String get transferReceiveSubtitle =>
      'To jest nowe urządzenie. Wpisz kod ze starego urządzenia.';

  @override
  String get transferChooseMethod => 'Wybierz metodę transferu';

  @override
  String get transferLan => 'LAN (ta sama sieć)';

  @override
  String get transferLanSubtitle =>
      'Szybki, bezpośredni. Oba urządzenia muszą być w tej samej sieci Wi-Fi.';

  @override
  String get transferNostrRelay => 'Przekaźnik Nostr';

  @override
  String get transferNostrRelaySubtitle =>
      'Działa przez dowolną sieć przy użyciu istniejącego przekaźnika Nostr.';

  @override
  String get transferRelayUrl => 'URL przekaźnika';

  @override
  String get transferEnterCode => 'Wpisz kod transferu';

  @override
  String get transferPasteCode => 'Wklej tutaj kod LAN:... lub NOS:...';

  @override
  String get transferConnect => 'Połącz';

  @override
  String get transferGenerating => 'Generowanie kodu transferu…';

  @override
  String get transferShareCode => 'Udostępnij ten kod odbiorcy:';

  @override
  String get transferCopyCode => 'Kopiuj kod';

  @override
  String get transferCodeCopied => 'Kod skopiowany do schowka';

  @override
  String get transferWaitingReceiver => 'Oczekiwanie na połączenie odbiorcy…';

  @override
  String get transferConnectingSender => 'Łączenie z nadawcą…';

  @override
  String get transferVerifyBoth =>
      'Porównaj ten kod na obu urządzeniach.\nJeśli się zgadzają, transfer jest bezpieczny.';

  @override
  String get transferComplete => 'Transfer zakończony';

  @override
  String get transferKeysImported => 'Klucze zaimportowane';

  @override
  String get transferCompleteSenderBody =>
      'Twoje klucze pozostają aktywne na tym urządzeniu.\nOdbiorca może teraz korzystać z Twojej tożsamości.';

  @override
  String get transferCompleteReceiverBody =>
      'Klucze zaimportowane pomyślnie.\nUruchom ponownie aplikację, aby zastosować nową tożsamość.';

  @override
  String get transferRestartApp => 'Uruchom ponownie';

  @override
  String get transferFailed => 'Transfer nie powiódł się';

  @override
  String get transferTryAgain => 'Spróbuj ponownie';

  @override
  String get transferEnterRelayFirst => 'Najpierw wpisz URL przekaźnika';

  @override
  String get transferPasteCodeFromSender => 'Wklej kod transferu od nadawcy';

  @override
  String get menuReply => 'Odpowiedz';

  @override
  String get menuForward => 'Przekaż dalej';

  @override
  String get menuReact => 'Reaguj';

  @override
  String get menuCopy => 'Kopiuj';

  @override
  String get menuEdit => 'Edytuj';

  @override
  String get menuRetry => 'Ponów';

  @override
  String get menuCancelScheduled => 'Anuluj zaplanowane';

  @override
  String get menuDelete => 'Usuń';

  @override
  String get menuForwardTo => 'Przekaż do…';

  @override
  String menuForwardedTo(String name) {
    return 'Przekazano do $name';
  }

  @override
  String get menuScheduledMessages => 'Zaplanowane wiadomości';

  @override
  String get menuNoScheduledMessages => 'Brak zaplanowanych wiadomości';

  @override
  String menuSendsOn(String date) {
    return 'Wysłanie $date';
  }

  @override
  String get menuDisappearingMessages => 'Znikające wiadomości';

  @override
  String get menuDisappearingSubtitle =>
      'Wiadomości usuwają się automatycznie po wybranym czasie.';

  @override
  String get menuTtlOff => 'Wyłączone';

  @override
  String get menuTtl1h => '1 godzina';

  @override
  String get menuTtl24h => '24 godziny';

  @override
  String get menuTtl7d => '7 dni';

  @override
  String get menuAttachPhoto => 'Zdjęcie';

  @override
  String get menuAttachFile => 'Plik';

  @override
  String get menuAttachVideo => 'Wideo';

  @override
  String get mediaTitle => 'Media';

  @override
  String get mediaFileLabel => 'PLIK';

  @override
  String mediaPhotosTab(int count) {
    return 'Zdjęcia ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Pliki ($count)';
  }

  @override
  String get mediaNoPhotos => 'Brak zdjęć';

  @override
  String get mediaNoFiles => 'Brak plików';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Zapisano w Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'Nie udało się zapisać pliku';

  @override
  String get statusNewStatus => 'Nowy status';

  @override
  String get statusPublish => 'Opublikuj';

  @override
  String get statusExpiresIn24h => 'Status wygasa po 24 godzinach';

  @override
  String get statusWhatsOnYourMind => 'Co masz na myśli?';

  @override
  String get statusPhotoAttached => 'Zdjęcie załączone';

  @override
  String get statusAttachPhoto => 'Załącz zdjęcie (opcjonalnie)';

  @override
  String get statusEnterText => 'Wpisz tekst dla swojego statusu.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Nie udało się wybrać zdjęcia: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Nie udało się opublikować: $error';
  }

  @override
  String get panicSetPanicKey => 'Ustaw klucz paniki';

  @override
  String get panicEmergencySelfDestruct => 'Awaryjne samozniszczenie';

  @override
  String get panicIrreversible => 'Ta czynność jest nieodwracalna';

  @override
  String get panicWarningBody =>
      'Wpisanie tego klucza na ekranie blokady natychmiast usuwa WSZYSTKIE dane — wiadomości, kontakty, klucze, tożsamość. Użyj klucza innego niż zwykłe hasło.';

  @override
  String get panicKeyHint => 'Klucz paniki';

  @override
  String get panicConfirmHint => 'Potwierdź klucz paniki';

  @override
  String get panicMinChars => 'Klucz paniki musi mieć co najmniej 8 znaków';

  @override
  String get panicKeysDoNotMatch => 'Klucze nie pasują do siebie';

  @override
  String get panicSetFailed =>
      'Nie udało się zapisać klucza paniki — spróbuj ponownie';

  @override
  String get passwordSetAppPassword => 'Ustaw hasło aplikacji';

  @override
  String get passwordProtectsMessages => 'Chroni Twoje wiadomości w spoczynku';

  @override
  String get passwordInfoBanner =>
      'Wymagane przy każdym otwarciu Pulse. Jeśli je zapomnisz, Twoich danych nie da się odzyskać.';

  @override
  String get passwordHint => 'Hasło';

  @override
  String get passwordConfirmHint => 'Potwierdź hasło';

  @override
  String get passwordSetButton => 'Ustaw hasło';

  @override
  String get passwordSkipForNow => 'Pomiń na razie';

  @override
  String get passwordMinChars => 'Hasło musi mieć co najmniej 8 znaków';

  @override
  String get passwordNeedsVariety =>
      'Musi zawierać litery, cyfry i znaki specjalne';

  @override
  String get passwordRequirements =>
      'Min. 8 znaków z literami, cyframi i znakiem specjalnym';

  @override
  String get passwordsDoNotMatch => 'Hasła nie pasują do siebie';

  @override
  String get profileCardSaved => 'Profil zapisany!';

  @override
  String get profileCardE2eeIdentity => 'Tożsamość E2EE';

  @override
  String get profileCardDisplayName => 'Nazwa wyświetlana';

  @override
  String get profileCardDisplayNameHint => 'np. Jan Kowalski';

  @override
  String get profileCardAbout => 'O mnie';

  @override
  String get profileCardSaveProfile => 'Zapisz profil';

  @override
  String get profileCardYourName => 'Twoje imię';

  @override
  String get profileCardAddressCopied => 'Adres skopiowany!';

  @override
  String get profileCardInboxAddress => 'Twój adres skrzynki';

  @override
  String get profileCardInboxAddresses => 'Twoje adresy skrzynki';

  @override
  String get profileCardShareAllAddresses =>
      'Udostępnij wszystkie adresy (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Udostępnij kontaktom, aby mogli do Ciebie pisać.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Wszystkie $count adresów skopiowane jako jeden link!';
  }

  @override
  String get settingsMyProfile => 'Mój profil';

  @override
  String get settingsYourInboxAddress => 'Twój adres skrzynki';

  @override
  String get settingsMyQrCode => 'Udostępnij kontakt';

  @override
  String get settingsMyQrSubtitle =>
      'Kod QR i link zaproszenia do twojego adresu';

  @override
  String get settingsShareMyAddress => 'Udostępnij mój adres';

  @override
  String get settingsNoAddressYet => 'Brak adresu — najpierw zapisz ustawienia';

  @override
  String get settingsInviteLink => 'Link zaproszenia';

  @override
  String get settingsRawAddress => 'Surowy adres';

  @override
  String get settingsCopyLink => 'Kopiuj link';

  @override
  String get settingsCopyAddress => 'Kopiuj adres';

  @override
  String get settingsInviteLinkCopied => 'Link zaproszenia skopiowany';

  @override
  String get settingsAppearance => 'Wygląd';

  @override
  String get settingsThemeEngine => 'Silnik motywów';

  @override
  String get settingsThemeEngineSubtitle => 'Dostosuj kolory i czcionki';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle =>
      'Klucze E2EE są bezpiecznie przechowywane';

  @override
  String get settingsActive => 'AKTYWNY';

  @override
  String get settingsIdentityBackup => 'Kopia zapasowa tożsamości';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Eksportuj lub importuj swoją tożsamość Signal';

  @override
  String get settingsIdentityBackupBody =>
      'Eksportuj swoje klucze tożsamości Signal do kodu zapasowego lub przywróć z istniejącego.';

  @override
  String get settingsTransferDevice => 'Transfer na inne urządzenie';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Przenieś swoją tożsamość przez LAN lub przekaźnik Nostr';

  @override
  String get settingsExportIdentity => 'Eksportuj tożsamość';

  @override
  String get settingsExportIdentityBody =>
      'Skopiuj ten kod zapasowy i przechowuj go bezpiecznie:';

  @override
  String get settingsSaveFile => 'Zapisz plik';

  @override
  String get settingsImportIdentity => 'Importuj tożsamość';

  @override
  String get settingsImportIdentityBody =>
      'Wklej poniżej swój kod zapasowy. Spowoduje to nadpisanie bieżącej tożsamości.';

  @override
  String get settingsPasteBackupCode => 'Wklej tutaj kod zapasowy…';

  @override
  String get settingsIdentityImported =>
      'Tożsamość + kontakty zaimportowane! Uruchom ponownie aplikację, aby zastosować.';

  @override
  String get settingsSecurity => 'Bezpieczeństwo';

  @override
  String get settingsAppPassword => 'Hasło aplikacji';

  @override
  String get settingsPasswordEnabled =>
      'Włączone — wymagane przy każdym uruchomieniu';

  @override
  String get settingsPasswordDisabled =>
      'Wyłączone — aplikacja otwiera się bez hasła';

  @override
  String get settingsChangePassword => 'Zmień hasło';

  @override
  String get settingsChangePasswordSubtitle =>
      'Zaktualizuj hasło blokady aplikacji';

  @override
  String get settingsSetPanicKey => 'Ustaw klucz paniki';

  @override
  String get settingsChangePanicKey => 'Zmień klucz paniki';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Zaktualizuj awaryjny klucz wymazywania';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Jeden klucz, który natychmiast usuwa wszystkie dane';

  @override
  String get settingsRemovePanicKey => 'Usuń klucz paniki';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Wyłącz awaryjne samozniszczenie';

  @override
  String get settingsRemovePanicKeyBody =>
      'Awaryjne samozniszczenie zostanie wyłączone. Możesz je ponownie włączyć w dowolnym momencie.';

  @override
  String get settingsDisableAppPassword => 'Wyłącz hasło aplikacji';

  @override
  String get settingsEnterCurrentPassword =>
      'Wpisz obecne hasło, aby potwierdzić';

  @override
  String get settingsCurrentPassword => 'Obecne hasło';

  @override
  String get settingsIncorrectPassword => 'Nieprawidłowe hasło';

  @override
  String get settingsPasswordUpdated => 'Hasło zaktualizowane';

  @override
  String get settingsChangePasswordProceed =>
      'Wpisz obecne hasło, aby kontynuować';

  @override
  String get settingsData => 'Dane';

  @override
  String get settingsBackupMessages => 'Kopia zapasowa wiadomości';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Eksportuj zaszyfrowaną historię wiadomości do pliku';

  @override
  String get settingsRestoreMessages => 'Przywróć wiadomości';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Importuj wiadomości z pliku kopii zapasowej';

  @override
  String get settingsExportKeys => 'Eksportuj klucze';

  @override
  String get settingsExportKeysSubtitle =>
      'Zapisz klucze tożsamości do zaszyfrowanego pliku';

  @override
  String get settingsImportKeys => 'Importuj klucze';

  @override
  String get settingsImportKeysSubtitle =>
      'Przywróć klucze tożsamości z wyeksportowanego pliku';

  @override
  String get settingsBackupPassword => 'Hasło kopii zapasowej';

  @override
  String get settingsPasswordCannotBeEmpty => 'Hasło nie może być puste';

  @override
  String get settingsPasswordMin4Chars => 'Hasło musi mieć co najmniej 4 znaki';

  @override
  String get settingsCallsTurn => 'Połączenia i TURN';

  @override
  String get settingsLocalNetwork => 'Sieć lokalna';

  @override
  String get settingsCensorshipResistance => 'Odporność na cenzurę';

  @override
  String get settingsNetwork => 'Sieć';

  @override
  String get settingsProxyTunnels => 'Proxy i tunele';

  @override
  String get settingsTurnServers => 'Serwery TURN';

  @override
  String get settingsProviderTitle => 'Dostawca';

  @override
  String get settingsLanFallback => 'Awaryjny LAN';

  @override
  String get settingsLanFallbackSubtitle =>
      'Rozgłaszaj obecność i dostarczaj wiadomości w sieci lokalnej, gdy internet jest niedostępny. Wyłącz w niezaufanych sieciach (publiczne Wi-Fi).';

  @override
  String get settingsBgDelivery => 'Dostarczanie w tle';

  @override
  String get settingsBgDeliverySubtitle =>
      'Kontynuuj odbieranie wiadomości po zminimalizowaniu aplikacji. Wyświetla stałe powiadomienie.';

  @override
  String get settingsYourInboxProvider => 'Twój dostawca skrzynki';

  @override
  String get settingsConnectionDetails => 'Szczegóły połączenia';

  @override
  String get settingsSaveAndConnect => 'Zapisz i połącz';

  @override
  String get settingsSecondaryInboxes => 'Dodatkowe skrzynki';

  @override
  String get settingsAddSecondaryInbox => 'Dodaj dodatkową skrzynkę';

  @override
  String get settingsAdvanced => 'Zaawansowane';

  @override
  String get settingsDiscover => 'Odkryj';

  @override
  String get settingsAbout => 'O aplikacji';

  @override
  String get settingsPrivacyPolicy => 'Polityka prywatności';

  @override
  String get settingsPrivacyPolicySubtitle => 'Jak Pulse chroni Twoje dane';

  @override
  String get settingsCrashReporting => 'Raportowanie awarii';

  @override
  String get settingsCrashReportingSubtitle =>
      'Wysyłaj anonimowe raporty o awariach, aby pomóc ulepszać Pulse. Żadna treść wiadomości ani kontakty nigdy nie są wysyłane.';

  @override
  String get settingsCrashReportingEnabled =>
      'Raportowanie awarii włączone — uruchom ponownie aplikację, aby zastosować';

  @override
  String get settingsCrashReportingDisabled =>
      'Raportowanie awarii wyłączone — uruchom ponownie aplikację, aby zastosować';

  @override
  String get settingsSensitiveOperation => 'Wrażliwa operacja';

  @override
  String get settingsSensitiveOperationBody =>
      'Te klucze to Twoja tożsamość. Każdy z tym plikiem może podszywać się pod Ciebie. Przechowuj go bezpiecznie i usuń po transferze.';

  @override
  String get settingsIUnderstandContinue => 'Rozumiem, kontynuuj';

  @override
  String get settingsReplaceIdentity => 'Zastąpić tożsamość?';

  @override
  String get settingsReplaceIdentityBody =>
      'Spowoduje to nadpisanie bieżących kluczy tożsamości. Istniejące sesje Signal zostaną unieważnione, a kontakty będą musiały ponownie nawiązać szyfrowanie. Wymagane będzie ponowne uruchomienie aplikacji.';

  @override
  String get settingsReplaceKeys => 'Zastąp klucze';

  @override
  String get settingsKeysImported => 'Klucze zaimportowane';

  @override
  String settingsKeysImportedBody(int count) {
    return 'Pomyślnie zaimportowano $count kluczy. Uruchom ponownie aplikację, aby zainicjalizować z nową tożsamością.';
  }

  @override
  String get settingsRestartNow => 'Uruchom ponownie teraz';

  @override
  String get settingsLater => 'Później';

  @override
  String get profileGroupLabel => 'Grupa';

  @override
  String get profileAddButton => 'Dodaj';

  @override
  String get profileKickButton => 'Wyrzuć';

  @override
  String get dataSectionTitle => 'Dane';

  @override
  String get dataBackupMessages => 'Kopia zapasowa wiadomości';

  @override
  String get dataBackupPasswordSubtitle =>
      'Wybierz hasło do zaszyfrowania kopii zapasowej wiadomości.';

  @override
  String get dataBackupConfirmLabel => 'Utwórz kopię';

  @override
  String get dataCreatingBackup => 'Tworzenie kopii zapasowej';

  @override
  String get dataBackupPreparing => 'Przygotowywanie...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Eksportowanie wiadomości $done z $total...';
  }

  @override
  String get dataBackupSavingFile => 'Zapisywanie pliku...';

  @override
  String get dataSaveMessageBackupDialog => 'Zapisz kopię wiadomości';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Kopia zapisana ($count wiadomości)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Kopia nie powiodła się — brak danych do eksportu';

  @override
  String dataBackupFailedError(String error) {
    return 'Kopia nie powiodła się: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Wybierz kopię wiadomości';

  @override
  String get dataInvalidBackupFile => 'Nieprawidłowy plik kopii (za mały)';

  @override
  String get dataNotValidBackupFile =>
      'To nie jest prawidłowy plik kopii Pulse';

  @override
  String get dataRestoreMessages => 'Przywróć wiadomości';

  @override
  String get dataRestorePasswordSubtitle =>
      'Wpisz hasło użyte do utworzenia tej kopii.';

  @override
  String get dataRestoreConfirmLabel => 'Przywróć';

  @override
  String get dataRestoringMessages => 'Przywracanie wiadomości';

  @override
  String get dataRestoreDecrypting => 'Deszyfrowanie...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Importowanie wiadomości $done z $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Przywracanie nie powiodło się — błędne hasło lub uszkodzony plik';

  @override
  String dataRestoreSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Przywrócono $count nowych wiadomości',
      few: 'Przywrócono $count nowe wiadomości',
      one: 'Przywrócono 1 nową wiadomość',
    );
    return '$_temp0';
  }

  @override
  String get dataRestoreNothingNew =>
      'Brak nowych wiadomości do zaimportowania (wszystkie już istnieją)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Przywracanie nie powiodło się: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Wybierz eksport kluczy';

  @override
  String get dataNotValidKeyFile =>
      'To nie jest prawidłowy plik eksportu kluczy Pulse';

  @override
  String get dataExportKeys => 'Eksportuj klucze';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Wybierz hasło do zaszyfrowania eksportu kluczy.';

  @override
  String get dataExportKeysConfirmLabel => 'Eksportuj';

  @override
  String get dataExportingKeys => 'Eksportowanie kluczy';

  @override
  String get dataExportingKeysStatus => 'Szyfrowanie kluczy tożsamości...';

  @override
  String get dataSaveKeyExportDialog => 'Zapisz eksport kluczy';

  @override
  String dataKeysExportedTo(String path) {
    return 'Klucze wyeksportowane do:\n$path';
  }

  @override
  String get dataExportFailed =>
      'Eksport nie powiódł się — nie znaleziono kluczy';

  @override
  String dataExportFailedError(String error) {
    return 'Eksport nie powiódł się: $error';
  }

  @override
  String get dataImportKeys => 'Importuj klucze';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Wpisz hasło użyte do zaszyfrowania tego eksportu kluczy.';

  @override
  String get dataImportKeysConfirmLabel => 'Importuj';

  @override
  String get dataImportingKeys => 'Importowanie kluczy';

  @override
  String get dataImportingKeysStatus => 'Deszyfrowanie kluczy tożsamości...';

  @override
  String get dataImportFailed =>
      'Import nie powiódł się — błędne hasło lub uszkodzony plik';

  @override
  String dataImportFailedError(String error) {
    return 'Import nie powiódł się: $error';
  }

  @override
  String get securitySectionTitle => 'Bezpieczeństwo';

  @override
  String get securityIncorrectPassword => 'Nieprawidłowe hasło';

  @override
  String get securityPasswordUpdated => 'Hasło zaktualizowane';

  @override
  String get appearanceSectionTitle => 'Wygląd';

  @override
  String appearanceExportFailed(String error) {
    return 'Eksport nie powiódł się: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Zapisano w $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Zapis nie powiódł się: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Import nie powiódł się: $error';
  }

  @override
  String get aboutSectionTitle => 'O aplikacji';

  @override
  String get providerPublicKey => 'Klucz publiczny';

  @override
  String get providerRelay => 'Przekaźnik';

  @override
  String get providerAutoConfigured =>
      'Automatycznie skonfigurowane z hasła odzyskiwania. Przekaźnik odkryty automatycznie.';

  @override
  String get providerKeyStoredLocally =>
      'Twój klucz jest przechowywany lokalnie w bezpiecznym magazynie — nigdy nie jest wysyłany na żaden serwer.';

  @override
  String get providerSessionInfo =>
      'Session Network — E2EE z routingiem cebulowym. Twój Session ID jest generowany automatycznie i przechowywany bezpiecznie. Węzły są automatycznie wykrywane z wbudowanych węzłów bazowych.';

  @override
  String get providerAdvanced => 'Zaawansowane';

  @override
  String get providerSaveAndConnect => 'Zapisz i połącz';

  @override
  String get providerAddSecondaryInbox => 'Dodaj dodatkową skrzynkę';

  @override
  String get providerSecondaryInboxes => 'Dodatkowe skrzynki';

  @override
  String get providerYourInboxProvider => 'Twój dostawca skrzynki';

  @override
  String get providerConnectionDetails => 'Szczegóły połączenia';

  @override
  String get addContactTitle => 'Dodaj kontakt';

  @override
  String get addContactInviteLinkLabel => 'Link zaproszenia lub adres';

  @override
  String get addContactTapToPaste => 'Kliknij, aby wkleić link zaproszenia';

  @override
  String get addContactPasteTooltip => 'Wklej ze schowka';

  @override
  String get addContactAddressDetected => 'Wykryto adres kontaktu';

  @override
  String addContactRoutesDetected(int count) {
    return 'Wykryto $count tras — SmartRouter wybierze najszybszą';
  }

  @override
  String get addContactFetchingProfile => 'Pobieranie profilu…';

  @override
  String addContactProfileFound(String name) {
    return 'Znaleziono: $name';
  }

  @override
  String get addContactNoProfileFound => 'Nie znaleziono profilu';

  @override
  String get addContactDisplayNameLabel => 'Nazwa wyświetlana';

  @override
  String get addContactDisplayNameHint => 'Jak chcesz ich nazywać?';

  @override
  String get addContactAddManually => 'Dodaj adres ręcznie';

  @override
  String get addContactButton => 'Dodaj kontakt';

  @override
  String get networkDiagnosticsTitle => 'Diagnostyka sieci';

  @override
  String get networkDiagnosticsNostrRelays => 'Przekaźniki Nostr';

  @override
  String get networkDiagnosticsDirect => 'Bezpośrednie';

  @override
  String get networkDiagnosticsTorOnly => 'Tylko Tor';

  @override
  String get networkDiagnosticsBest => 'Najlepszy';

  @override
  String get networkDiagnosticsNone => 'brak';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Status';

  @override
  String get networkDiagnosticsConnected => 'Połączono';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Łączenie $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Wyłączony';

  @override
  String get networkDiagnosticsTransport => 'Transport';

  @override
  String get networkDiagnosticsInfrastructure => 'Infrastruktura';

  @override
  String get networkDiagnosticsSessionNodes => 'Węzły Session';

  @override
  String get networkDiagnosticsTurnServers => 'Serwery TURN';

  @override
  String get networkDiagnosticsLastProbe => 'Ostatni test';

  @override
  String get networkDiagnosticsRunning => 'Trwa...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Uruchom diagnostykę';

  @override
  String get networkDiagnosticsForceReprobe => 'Wymuś pełny ponowny test';

  @override
  String get networkDiagnosticsJustNow => 'właśnie teraz';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes min temu';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours godz. temu';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days dn. temu';
  }

  @override
  String get homeNoEch => 'Brak ECH';

  @override
  String get homeNoEchTooltip =>
      'Proxy uTLS niedostępne — ECH wyłączone.\nOdcisk TLS jest widoczny dla DPI.';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Zapisano i połączono z $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Wbudowany Tor nie uruchomił się';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon nie uruchomił się';

  @override
  String get verifyTitle => 'Zweryfikuj numer bezpieczeństwa';

  @override
  String get verifyIdentityVerified => 'Tożsamość zweryfikowana';

  @override
  String get verifyNotYetVerified => 'Jeszcze nie zweryfikowane';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Zweryfikowałeś numer bezpieczeństwa $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Porównaj te numery z $name osobiście lub przez zaufany kanał.';
  }

  @override
  String get verifyExplanation =>
      'Każda rozmowa ma unikalny numer bezpieczeństwa. Jeśli oboje widzicie te same numery na swoich urządzeniach, Wasze połączenie jest zweryfikowane end-to-end.';

  @override
  String verifyContactKey(String name) {
    return 'Klucz $name';
  }

  @override
  String get verifyYourKey => 'Twój klucz';

  @override
  String get verifyRemoveVerification => 'Usuń weryfikację';

  @override
  String get verifyMarkAsVerified => 'Oznacz jako zweryfikowane';

  @override
  String verifyAfterReinstall(String name) {
    return 'Jeśli $name przeinstaluje aplikację, numer bezpieczeństwa zmieni się i weryfikacja zostanie automatycznie usunięta.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Oznacz jako zweryfikowane dopiero po porównaniu numerów z $name podczas rozmowy głosowej lub osobiście.';
  }

  @override
  String get verifyNoSession =>
      'Sesja szyfrowania nie została jeszcze nawiązana. Wyślij wiadomość, aby wygenerować numery bezpieczeństwa.';

  @override
  String get verifyNoKeyAvailable => 'Klucz niedostępny';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Odcisk palca $label skopiowany';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL bazy danych';

  @override
  String get providerOptionalHint => 'Opcjonalnie';

  @override
  String get providerWebApiKeyLabel => 'Klucz Web API';

  @override
  String get providerOptionalForPublicDb => 'Opcjonalny dla publicznej bazy';

  @override
  String get providerRelayUrlLabel => 'URL przekaźnika';

  @override
  String get providerPrivateKeyLabel => 'Klucz prywatny';

  @override
  String get providerPrivateKeyNsecLabel => 'Klucz prywatny (nsec)';

  @override
  String get providerStorageNodeLabel =>
      'URL węzła przechowywania (opcjonalnie)';

  @override
  String get providerStorageNodeHint =>
      'Pozostaw puste dla wbudowanych węzłów początkowych';

  @override
  String get transferInvalidCodeFormat =>
      'Nierozpoznany format kodu — musi zaczynać się od LAN: lub NOS:';

  @override
  String get profileCardFingerprintCopied => 'Odcisk palca skopiowany';

  @override
  String get profileCardAboutHint => 'Prywatność przede wszystkim 🔒';

  @override
  String get profileCardSaveButton => 'Zapisz profil';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Eksportuj zaszyfrowane wiadomości, kontakty i awatary do pliku';

  @override
  String get callVideo => 'Wideo';

  @override
  String get callAudio => 'Audio';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Dostarczono do $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Dostarczono do $count';
  }

  @override
  String get groupStatusDialogTitle => 'Informacje o wiadomości';

  @override
  String get groupStatusRead => 'Przeczytane';

  @override
  String get groupStatusDelivered => 'Dostarczone';

  @override
  String get groupStatusPending => 'Oczekujące';

  @override
  String get groupStatusNoData => 'Brak informacji o dostarczeniu';

  @override
  String get profileTransferAdmin => 'Ustaw jako admina';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Ustanowić $name nowym adminem?';
  }

  @override
  String get profileTransferAdminBody =>
      'Utracisz uprawnienia administratora. Tej operacji nie można cofnąć.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name jest teraz adminem';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Polityka prywatności';

  @override
  String get privacyOverviewHeading => 'Przegląd';

  @override
  String get privacyOverviewBody =>
      'Pulse to bezserwerowy komunikator z szyfrowaniem end-to-end. Twoja prywatność to nie tylko funkcja — to architektura. Nie ma serwerów Pulse. Żadne konta nie są nigdzie przechowywane. Żadne dane nie są zbierane, przesyłane ani przechowywane przez twórców.';

  @override
  String get privacyDataCollectionHeading => 'Zbieranie danych';

  @override
  String get privacyDataCollectionBody =>
      'Pulse nie zbiera żadnych danych osobowych. W szczególności:\n\n- Nie wymaga adresu e-mail, numeru telefonu ani prawdziwego imienia\n- Brak analityki, śledzenia ani telemetrii\n- Brak identyfikatorów reklamowych\n- Brak dostępu do listy kontaktów\n- Brak kopii zapasowych w chmurze (wiadomości istnieją tylko na Twoim urządzeniu)\n- Żadne metadane nie są wysyłane na serwer Pulse (bo nie ma żadnych serwerów)';

  @override
  String get privacyEncryptionHeading => 'Szyfrowanie';

  @override
  String get privacyEncryptionBody =>
      'Wszystkie wiadomości są szyfrowane przy użyciu protokołu Signal (Double Ratchet z uzgadnianiem kluczy X3DH). Klucze szyfrowania są generowane i przechowywane wyłącznie na Twoim urządzeniu. Nikt — w tym twórcy — nie może odczytać Twoich wiadomości.';

  @override
  String get privacyNetworkHeading => 'Architektura sieci';

  @override
  String get privacyNetworkBody =>
      'Pulse korzysta z federacyjnych adapterów transportu (przekaźniki Nostr, węzły Oxen/Session, Firebase Realtime Database, LAN). Transporty te przenoszą tylko zaszyfrowany tekst. Operatorzy przekaźników mogą widzieć Twój adres IP i wolumen ruchu, ale nie mogą odszyfrować treści wiadomości.\n\nGdy włączony jest Tor, Twój adres IP jest również ukryty przed operatorami przekaźników.';

  @override
  String get privacyStunHeading => 'Serwery STUN/TURN';

  @override
  String get privacyStunBody =>
      'Połączenia głosowe i wideo korzystają z WebRTC z szyfrowaniem DTLS-SRTP. Serwery STUN (używane do odkrywania publicznego IP dla połączeń peer-to-peer) oraz serwery TURN (używane do przekazywania mediów gdy bezpośrednie połączenie się nie powiedzie) mogą widzieć Twój adres IP i czas trwania połączenia, ale nie mogą odszyfrować treści połączenia.\n\nMożesz skonfigurować własny serwer TURN w Ustawieniach dla maksymalnej prywatności.';

  @override
  String get privacyCrashHeading => 'Raportowanie awarii';

  @override
  String get privacyCrashBody =>
      'Jeśli raportowanie awarii Sentry jest włączone (poprzez build-time SENTRY_DSN), anonimowe raporty o awariach mogą być wysyłane. Nie zawierają one treści wiadomości, informacji o kontaktach ani danych umożliwiających identyfikację osoby. Raportowanie awarii można wyłączyć w czasie kompilacji, pomijając DSN.';

  @override
  String get privacyPasswordHeading => 'Hasło i klucze';

  @override
  String get privacyPasswordBody =>
      'Twoje hasło odzyskiwania jest używane do wyprowadzania kluczy kryptograficznych przez Argon2id (KDF odporny na pamięć). Hasło nigdy nie jest nigdzie przesyłane. Jeśli stracisz hasło, Twojego konta nie da się odzyskać — nie ma serwera do zresetowania.';

  @override
  String get privacyFontsHeading => 'Czcionki';

  @override
  String get privacyFontsBody =>
      'Pulse zawiera wszystkie czcionki lokalnie. Żadne żądania nie są wysyłane do Google Fonts ani żadnej zewnętrznej usługi czcionek.';

  @override
  String get privacyThirdPartyHeading => 'Usługi zewnętrzne';

  @override
  String get privacyThirdPartyBody =>
      'Pulse nie integruje się z żadnymi sieciami reklamowymi, dostawcami analityki, platformami społecznościowymi ani brokerami danych. Jedyne połączenia sieciowe to połączenia z przekaźnikami transportu, które skonfigurujesz.';

  @override
  String get privacyOpenSourceHeading => 'Otwarte źródło';

  @override
  String get privacyOpenSourceBody =>
      'Pulse jest oprogramowaniem open source. Możesz skontrolować pełny kod źródłowy, aby zweryfikować te zapewnienia dotyczące prywatności.';

  @override
  String get privacyContactHeading => 'Kontakt';

  @override
  String get privacyContactBody =>
      'W przypadku pytań dotyczących prywatności otwórz zgłoszenie w repozytorium projektu.';

  @override
  String get privacyLastUpdated => 'Ostatnia aktualizacja: marzec 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Zapis nie powiódł się: $error';
  }

  @override
  String get themeEngineTitle => 'Silnik motywów';

  @override
  String get torBuiltInTitle => 'Wbudowany Tor';

  @override
  String get torConnectedSubtitle =>
      'Połączono — Nostr kierowany przez 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Łączenie… $pct%';
  }

  @override
  String get torNotRunning =>
      'Nie działa — kliknij przełącznik, aby uruchomić ponownie';

  @override
  String get torDescription =>
      'Kieruje Nostr przez Tor (Snowflake dla cenzurowanych sieci)';

  @override
  String get torNetworkDiagnostics => 'Diagnostyka sieci';

  @override
  String get torTransportLabel => 'Transport: ';

  @override
  String get torPtAuto => 'Auto';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Bez zaciemniania';

  @override
  String get torTimeoutLabel => 'Limit czasu: ';

  @override
  String get torInfoDescription =>
      'Gdy włączony, połączenia Nostr WebSocket są kierowane przez Tor (SOCKS5). Tor Browser nasłuchuje na 127.0.0.1:9150. Samodzielny demon tor używa portu 9050. Połączenia Firebase nie są dotknięte.';

  @override
  String get torRouteNostrTitle => 'Kieruj Nostr przez Tor';

  @override
  String get torManagedByBuiltin => 'Zarządzane przez wbudowany Tor';

  @override
  String get torActiveRouting => 'Aktywne — ruch Nostr kierowany przez Tor';

  @override
  String get torDisabled => 'Wyłączony';

  @override
  String get torProxySocks5 => 'Proxy Tor (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Host proxy';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser: port 9150  •  demon tor: port 9050';

  @override
  String get torForceNostrTitle => 'Kieruj wiadomości przez Tor';

  @override
  String get torForceNostrSubtitle =>
      'Wszystkie połączenia z przekaźnikami Nostr będą przechodzić przez Tor. Wolniejsze, ale ukrywa Twój IP przed przekaźnikami.';

  @override
  String get torForceNostrDisabled => 'Najpierw należy włączyć Tor';

  @override
  String get torForcePulseTitle => 'Kieruj przekaźnik Pulse przez Tor';

  @override
  String get torForcePulseSubtitle =>
      'Wszystkie połączenia z przekaźnikiem Pulse będą przechodzić przez Tor. Wolniejsze, ale ukrywa Twój IP przed serwerem.';

  @override
  String get torForcePulseDisabled => 'Najpierw należy włączyć Tor';

  @override
  String get i2pProxySocks5 => 'Proxy I2P (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P domyślnie używa SOCKS5 na porcie 4447. Połącz się z przekaźnikiem Nostr przez outproxy I2P (np. relay.damus.i2p), aby komunikować się z użytkownikami na dowolnym transporcie. Tor ma priorytet, gdy oba są włączone.';

  @override
  String get i2pRouteNostrTitle => 'Kieruj Nostr przez I2P';

  @override
  String get i2pActiveRouting => 'Aktywne — ruch Nostr kierowany przez I2P';

  @override
  String get i2pDisabled => 'Wyłączony';

  @override
  String get i2pProxyHostLabel => 'Host proxy';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'Domyślny port SOCKS5 routera I2P: 4447';

  @override
  String get customProxySocks5 => 'Niestandardowe proxy (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'Przekaźnik CF Worker';

  @override
  String get customProxyInfoDescription =>
      'Niestandardowe proxy kieruje ruch przez V2Ray/Xray/Shadowsocks. CF Worker działa jako osobisty przekaźnik proxy na Cloudflare CDN — GFW widzi *.workers.dev, nie prawdziwy przekaźnik.';

  @override
  String get customSocks5ProxyTitle => 'Niestandardowe proxy SOCKS5';

  @override
  String get customProxyActive => 'Aktywne — ruch kierowany przez SOCKS5';

  @override
  String get customProxyDisabled => 'Wyłączone';

  @override
  String get customProxyHostLabel => 'Host proxy';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Domena Worker (opcjonalnie)';

  @override
  String get customWorkerHelpTitle =>
      'Jak wdrożyć przekaźnik CF Worker (bezpłatnie)';

  @override
  String get customWorkerScriptCopied => 'Skrypt skopiowany!';

  @override
  String get customWorkerStep1 =>
      '1. Przejdź do dash.cloudflare.com → Workers & Pages\n2. Utwórz Worker → wklej ten skrypt:\n';

  @override
  String get customWorkerStep2 =>
      '3. Wdróż → skopiuj domenę (np. my-relay.user.workers.dev)\n4. Wklej domenę powyżej → Zapisz\n\nAplikacja automatycznie łączy się: wss://domena/?r=relay_url\nGFW widzi: połączenie z *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Połączono — SOCKS5 na 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Łączenie…';

  @override
  String get psiphonNotRunning =>
      'Nie działa — kliknij przełącznik, aby uruchomić ponownie';

  @override
  String get psiphonDescription =>
      'Szybki tunel (~3s bootstrap, ponad 2000 rotacyjnych VPS)';

  @override
  String get turnCommunityServers => 'Wspólnotowe serwery TURN';

  @override
  String get turnCustomServer => 'Niestandardowy serwer TURN (BYOD)';

  @override
  String get turnInfoDescription =>
      'Serwery TURN przekazują tylko już zaszyfrowane strumienie (DTLS-SRTP). Operator przekaźnika widzi Twój IP i wolumen ruchu, ale nie może odszyfrować połączeń. TURN jest używany tylko wtedy, gdy bezpośrednie P2P nie powiedzie się (~15–20% połączeń).';

  @override
  String get turnFreeLabel => 'BEZPŁATNY';

  @override
  String get turnServerUrlLabel => 'URL serwera TURN';

  @override
  String get turnServerUrlHint => 'turn:twoj-serwer.com:3478 lub turns:...';

  @override
  String get turnUsernameLabel => 'Nazwa użytkownika';

  @override
  String get turnPasswordLabel => 'Hasło';

  @override
  String get turnOptionalHint => 'Opcjonalnie';

  @override
  String get turnCustomInfo =>
      'Uruchom coturn na dowolnym VPS za ~5\$/mies. dla maksymalnej kontroli. Poświadczenia przechowywane lokalnie.';

  @override
  String get themePickerAppearance => 'Wygląd';

  @override
  String get themePickerAccentColor => 'Kolor akcentu';

  @override
  String get themeModeLight => 'Jasny';

  @override
  String get themeModeDark => 'Ciemny';

  @override
  String get themeModeSystem => 'Systemowy';

  @override
  String get themeDynamicPresets => 'Szablony';

  @override
  String get themeDynamicPrimaryColor => 'Kolor główny';

  @override
  String get themeDynamicBorderRadius => 'Zaokrąglenie krawędzi';

  @override
  String get themeDynamicFont => 'Czcionka';

  @override
  String get themeDynamicAppearance => 'Wygląd';

  @override
  String get themeDynamicUiStyle => 'Styl interfejsu';

  @override
  String get themeDynamicUiStyleDescription =>
      'Kontroluje wygląd okien dialogowych, przełączników i wskaźników.';

  @override
  String get themeDynamicSharp => 'Ostry';

  @override
  String get themeDynamicRound => 'Zaokrąglony';

  @override
  String get themeDynamicModeDark => 'Ciemny';

  @override
  String get themeDynamicModeLight => 'Jasny';

  @override
  String get themeDynamicModeAuto => 'Auto';

  @override
  String get themeDynamicPlatformAuto => 'Auto';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'Nieprawidłowy URL Firebase. Oczekiwano https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Nieprawidłowy URL przekaźnika. Oczekiwano wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Nieprawidłowy URL serwera Pulse. Oczekiwano https://serwer:port';

  @override
  String get providerPulseServerUrlLabel => 'URL serwera';

  @override
  String get providerPulseServerUrlHint => 'https://twoj-serwer:8443';

  @override
  String get providerPulseInviteLabel => 'Kod zaproszenia';

  @override
  String get providerPulseInviteHint => 'Kod zaproszenia (jeśli wymagany)';

  @override
  String get providerPulseInfo =>
      'Własny przekaźnik. Klucze wyprowadzone z hasła odzyskiwania.';

  @override
  String get providerScreenTitle => 'Skrzynki';

  @override
  String get providerSecondaryInboxesHeader => 'DODATKOWE SKRZYNKI';

  @override
  String get providerSecondaryInboxesInfo =>
      'Dodatkowe skrzynki odbierają wiadomości jednocześnie dla redundancji.';

  @override
  String get providerRemoveTooltip => 'Usuń';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... or hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... or hex private key';

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
  String get emojiNoRecent => 'Brak ostatnich emoji';

  @override
  String get emojiSearchHint => 'Szukaj emoji...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Kliknij, aby czatować';

  @override
  String get imageViewerSaveToDownloads => 'Zapisz do Pobranych';

  @override
  String imageViewerSavedTo(String path) {
    return 'Zapisano w $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get settingsLanguageSubtitle => 'Język wyświetlania aplikacji';

  @override
  String get settingsLanguageSystem => 'Domyślny systemowy';

  @override
  String get onboardingLanguageTitle => 'Wybierz język';

  @override
  String get onboardingLanguageSubtitle =>
      'Możesz to zmienić później w Ustawieniach';

  @override
  String get videoNoteRecord => 'Nagraj wiadomość wideo';

  @override
  String get videoNoteTapToRecord => 'Dotknij, aby nagrać';

  @override
  String get videoNoteTapToStop => 'Dotknij, aby zatrzymać';

  @override
  String get videoNoteCameraPermission => 'Odmówiono dostępu do kamery';

  @override
  String get videoNoteMaxDuration => 'Maksymalnie 30 sekund';

  @override
  String get videoNoteNotSupported =>
      'Notatki wideo nie są obsługiwane na tej platformie';

  @override
  String get navChats => 'Czaty';

  @override
  String get navUpdates => 'Aktualizacje';

  @override
  String get navCalls => 'Połączenia';

  @override
  String get filterAll => 'Wszystkie';

  @override
  String get filterUnread => 'Nieprzeczytane';

  @override
  String get filterGroups => 'Grupy';

  @override
  String get callsNoRecent => 'Brak ostatnich połączeń';

  @override
  String get callsEmptySubtitle => 'Twoja historia połączeń pojawi się tutaj';

  @override
  String get appBarEncrypted => 'szyfrowanie end-to-end';

  @override
  String get newStatus => 'Nowy status';

  @override
  String get newCall => 'Nowe połączenie';

  @override
  String get joinChannelTitle => 'Dołącz do kanału';

  @override
  String get joinChannelDescription => 'ADRES KANAŁU';

  @override
  String get joinChannelUrlHint => 'https://channel.example.com';

  @override
  String get joinChannelFetching => 'Pobieranie informacji o kanale…';

  @override
  String get joinChannelNotFound => 'Nie znaleziono kanału pod tym adresem';

  @override
  String get joinChannelNetworkError => 'Nie udało się połączyć z serwerem';

  @override
  String get joinChannelAlreadyJoined => 'Już dołączono';

  @override
  String get joinChannelButton => 'Dołącz';

  @override
  String get channelFeedEmpty => 'Brak postów';

  @override
  String get channelLeave => 'Opuść kanał';

  @override
  String get channelLeaveConfirm =>
      'Opuścić ten kanał? Zapisane posty zostaną usunięte.';

  @override
  String get channelInfo => 'Informacje o kanale';

  @override
  String channelViews(String count) {
    return '$count';
  }

  @override
  String get channelEdited => 'edytowano';

  @override
  String get channelLoadMore => 'Załaduj więcej';

  @override
  String get channelSearchPosts => 'Szukaj postów…';

  @override
  String get channelNoResults => 'Brak pasujących postów';

  @override
  String get channelUrl => 'URL kanału';

  @override
  String get channelCreated => 'Dołączono';

  @override
  String channelPostCount(int count) {
    return '$count postów';
  }

  @override
  String get channelCopyUrl => 'Kopiuj URL';

  @override
  String get setupNext => 'Dalej';

  @override
  String get setupKeyWarning =>
      'Zostanie wygenerowany klucz odzyskiwania. To jedyny sposób na odzyskanie konta na nowym urządzeniu — nie ma serwera, nie ma resetowania hasła.';

  @override
  String get setupKeyTitle => 'Twój klucz odzyskiwania';

  @override
  String get setupKeySubtitle =>
      'Zapisz ten klucz i przechowaj go w bezpiecznym miejscu. Będziesz go potrzebować do odzyskania konta na nowym urządzeniu.';

  @override
  String get setupKeyCopied => 'Skopiowano!';

  @override
  String get setupKeyWroteItDown => 'Zapisałem';

  @override
  String get setupKeyWarnBody =>
      'Zapisz ten klucz jako kopię zapasową. Możesz go też zobaczyć później w Ustawienia → Bezpieczeństwo.';

  @override
  String get setupVerifyTitle => 'Zweryfikuj klucz odzyskiwania';

  @override
  String get setupVerifySubtitle =>
      'Wprowadź ponownie klucz odzyskiwania, aby potwierdzić, że go poprawnie zapisałeś.';

  @override
  String get setupVerifyButton => 'Zweryfikuj';

  @override
  String get setupKeyMismatch =>
      'Klucz nie pasuje. Sprawdź i spróbuj ponownie.';

  @override
  String get setupSkipVerify => 'Pomiń weryfikację';

  @override
  String get setupSkipVerifyTitle => 'Pominąć weryfikację?';

  @override
  String get setupSkipVerifyBody =>
      'Jeśli stracisz klucz odzyskiwania, Twoje konto nie będzie mogło być odzyskane. Czy na pewno?';

  @override
  String get setupCreatingAccount => 'Tworzenie konta…';

  @override
  String get setupRestoringAccount => 'Odzyskiwanie konta…';

  @override
  String get restoreKeyInfoBanner =>
      'Wprowadź klucz odzyskiwania — Twój adres (Nostr + Session) zostanie przywrócony automatycznie. Kontakty i wiadomości były przechowywane tylko lokalnie.';

  @override
  String get restoreKeyHint => 'Klucz odzyskiwania';

  @override
  String get settingsViewRecoveryKey => 'Pokaż klucz odzyskiwania';

  @override
  String get settingsViewRecoveryKeySubtitle =>
      'Wyświetl klucz odzyskiwania konta';

  @override
  String get settingsRecoveryKeyNotStored =>
      'Klucz odzyskiwania niedostępny (utworzony przed tą funkcją)';

  @override
  String get settingsRecoveryKeyWarning =>
      'Przechowuj ten klucz bezpiecznie. Każdy, kto go ma, może przywrócić Twoje konto na innym urządzeniu.';

  @override
  String get replaceIdentityTitle => 'Zastąpić istniejącą tożsamość?';

  @override
  String get replaceIdentityBodyRestore =>
      'Na tym urządzeniu istnieje już tożsamość. Przywrócenie trwale zastąpi Twój obecny klucz Nostr i seed Oxen. Wszyscy kontakci stracą możliwość skontaktowania się z Twoim obecnym adresem.\n\nTego nie można cofnąć.';

  @override
  String get replaceIdentityBodyCreate =>
      'Na tym urządzeniu istnieje już tożsamość. Utworzenie nowej trwale zastąpi Twój obecny klucz Nostr i seed Oxen. Wszyscy kontakci stracą możliwość skontaktowania się z Twoim obecnym adresem.\n\nTego nie można cofnąć.';

  @override
  String get replace => 'Zastąp';

  @override
  String get callNoScreenSources => 'Brak dostępnych źródeł ekranu';

  @override
  String get callScreenShareQuality => 'Jakość udostępniania ekranu';

  @override
  String get callFrameRate => 'Liczba klatek';

  @override
  String get callResolution => 'Rozdzielczość';

  @override
  String get callAutoResolution => 'Auto = natywna rozdzielczość ekranu';

  @override
  String get callStartSharing => 'Rozpocznij udostępnianie';

  @override
  String get callCameraUnavailable =>
      'Kamera niedostępna — może być używana przez inną aplikację';

  @override
  String get themeResetToDefaults => 'Przywróć domyślne';

  @override
  String get backupSaveToDownloadsTitle => 'Zapisać kopię zapasową w Pobrane?';

  @override
  String backupSaveToDownloadsBody(String path) {
    return 'Brak dostępnego selektora plików. Kopia zapasowa zostanie zapisana w:\n$path';
  }

  @override
  String get systemLabel => 'System';

  @override
  String get next => 'Dalej';

  @override
  String get gifLabel => 'GIF';

  @override
  String devTapsRemaining(int remaining) {
    return 'Jeszcze $remaining dotknięć, aby włączyć tryb programisty';
  }

  @override
  String get devModeEnabled => 'Tryb programisty włączony';

  @override
  String get devTools => 'Narzędzia programisty';

  @override
  String get devAdapterDiagnostics => 'Przełączniki adapterów i diagnostyka';

  @override
  String get devEnableAll => 'Włącz wszystkie';

  @override
  String get devDisableAll => 'Wyłącz wszystkie';

  @override
  String get turnUrlValidation =>
      'URL TURN musi zaczynać się od turn: lub turns: (maks. 512 znaków)';

  @override
  String get callMissedCall => 'Nieodebrane połączenie';

  @override
  String get callOutgoingCall => 'Połączenie wychodzące';

  @override
  String get callIncomingCall => 'Połączenie przychodzące';

  @override
  String get mediaMissingData => 'Brak danych multimedialnych';

  @override
  String get mediaDownloadFailed => 'Pobieranie nieudane';

  @override
  String get mediaDecryptFailed => 'Deszyfrowanie nieudane';

  @override
  String get callEndCallBanner => 'Zakończ połączenie';

  @override
  String get meFallback => 'Ja';

  @override
  String get imageSaveToDownloads => 'Zapisz w Pobrane';

  @override
  String imageSavedToPath(String path) {
    return 'Zapisano w $path';
  }

  @override
  String get callScreenShareRequiresPermission =>
      'Udostępnianie ekranu wymaga uprawnień';

  @override
  String get callScreenShareUnavailable => 'Udostępnianie ekranu niedostępne';

  @override
  String get statusJustNow => 'Właśnie teraz';

  @override
  String statusMinutesAgo(int minutes) {
    return '${minutes}min temu';
  }

  @override
  String statusHoursAgo(int hours) {
    return '${hours}godz. temu';
  }

  @override
  String addContactRoutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tras',
      one: '1 trasa',
    );
    return '$_temp0';
  }

  @override
  String get addContactReadyToAdd => 'Gotowy do dodania';

  @override
  String groupSelectedCount(int count) {
    return '$count wybranych';
  }

  @override
  String get paste => 'Wklej';

  @override
  String get sfuAudioOnly => 'Tylko dźwięk';

  @override
  String sfuParticipants(int count) {
    return '$count uczestników';
  }

  @override
  String get dataUnencryptedBackup => 'Niezaszyfrowana kopia zapasowa';

  @override
  String get dataUnencryptedBackupBody =>
      'Ten plik to niezaszyfrowana kopia zapasowa tożsamości, która nadpisze Twoje obecne klucze. Importuj tylko pliki utworzone przez siebie. Kontynuować?';

  @override
  String get dataImportAnyway => 'Importuj mimo to';

  @override
  String get securityStorageError =>
      'Błąd bezpiecznego przechowywania — uruchom ponownie aplikację';

  @override
  String get aboutDevModeActive => 'Tryb programisty aktywny';

  @override
  String get themeColors => 'Kolory';

  @override
  String get themePrimaryAccent => 'Główny akcent';

  @override
  String get themeSecondaryAccent => 'Drugi akcent';

  @override
  String get themeBackground => 'Tło';

  @override
  String get themeSurface => 'Powierzchnia';

  @override
  String get themeChatBubbles => 'Dymki czatu';

  @override
  String get themeOutgoingMessage => 'Wiadomość wychodząca';

  @override
  String get themeIncomingMessage => 'Wiadomość przychodząca';

  @override
  String get themeShape => 'Kształt';

  @override
  String get devSectionDeveloper => 'Programista';

  @override
  String get devAdapterChannelsHint =>
      'Kanały adapterów — wyłącz, aby testować określone transporty.';

  @override
  String get devNostrRelays => 'Przekaźniki Nostr (wss://)';

  @override
  String get devFirebaseDb => 'Firebase Realtime DB';

  @override
  String get devSessionNetwork => 'Sieć Session';

  @override
  String get devPulseRelay => 'Pulse relay samodzielnie hostowany';

  @override
  String get devLanNetwork => 'Sieć lokalna (UDP/TCP)';

  @override
  String get devSectionCalls => 'Połączenia';

  @override
  String get devForceTurnRelay => 'Wymuś relay TURN';

  @override
  String get devForceTurnRelaySubtitle =>
      'Wyłącz P2P — wszystkie połączenia tylko przez serwery TURN';

  @override
  String get devRestartWarning =>
      '⚠ Zmiany zaczną obowiązywać przy następnym wysyłaniu/połączeniu. Uruchom ponownie aplikację, aby zastosować do przychodzących.';

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
}
