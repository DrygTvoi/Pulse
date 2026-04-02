// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Pretraži poruke...';

  @override
  String get search => 'Pretraži';

  @override
  String get clearSearch => 'Obriši pretragu';

  @override
  String get closeSearch => 'Zatvori pretragu';

  @override
  String get moreOptions => 'Više opcija';

  @override
  String get back => 'Natrag';

  @override
  String get cancel => 'Odustani';

  @override
  String get close => 'Zatvori';

  @override
  String get confirm => 'Potvrdi';

  @override
  String get remove => 'Ukloni';

  @override
  String get save => 'Spremi';

  @override
  String get add => 'Dodaj';

  @override
  String get copy => 'Kopiraj';

  @override
  String get skip => 'Preskoči';

  @override
  String get done => 'Gotovo';

  @override
  String get apply => 'Primijeni';

  @override
  String get export => 'Izvezi';

  @override
  String get import => 'Uvezi';

  @override
  String get homeNewGroup => 'Nova grupa';

  @override
  String get homeSettings => 'Postavke';

  @override
  String get homeSearching => 'Pretraživanje poruka...';

  @override
  String get homeNoResults => 'Nema rezultata';

  @override
  String get homeNoChatHistory => 'Nema povijesti razgovora';

  @override
  String homeTransportSwitched(String address) {
    return 'Transport prebačen → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name zove...';
  }

  @override
  String get homeAccept => 'Prihvati';

  @override
  String get homeDecline => 'Odbij';

  @override
  String get homeLoadEarlier => 'Učitaj starije poruke';

  @override
  String get homeChats => 'Razgovori';

  @override
  String get homeSelectConversation => 'Odaberite razgovor';

  @override
  String get homeNoChatsYet => 'Još nema razgovora';

  @override
  String get homeAddContactToStart =>
      'Dodajte kontakt da biste započeli razgovor';

  @override
  String get homeNewChat => 'Novi razgovor';

  @override
  String get homeNewChatTooltip => 'Novi razgovor';

  @override
  String get homeIncomingCallTitle => 'Dolazni poziv';

  @override
  String get homeIncomingGroupCallTitle => 'Dolazni grupni poziv';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — dolazni grupni poziv';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Nema razgovora koji odgovaraju \"$query\"';
  }

  @override
  String get homeSectionChats => 'Razgovori';

  @override
  String get homeSectionMessages => 'Poruke';

  @override
  String get homeDbEncryptionUnavailable =>
      'Enkripcija baze podataka nije dostupna — instalirajte SQLCipher za potpunu zaštitu';

  @override
  String get chatFileTooLargeGroup =>
      'Datoteke veće od 512 KB nisu podržane u grupnim razgovorima';

  @override
  String get chatLargeFile => 'Velika datoteka';

  @override
  String get chatCancel => 'Odustani';

  @override
  String get chatSend => 'Pošalji';

  @override
  String get chatFileTooLarge =>
      'Datoteka je prevelika — maksimalna veličina je 100 MB';

  @override
  String get chatMicDenied => 'Dozvola za mikrofon je odbijena';

  @override
  String get chatVoiceFailed =>
      'Glasovna poruka se nije mogla spremiti — provjerite dostupnu memoriju';

  @override
  String get chatScheduleFuture => 'Zakazano vrijeme mora biti u budućnosti';

  @override
  String get chatToday => 'Danas';

  @override
  String get chatYesterday => 'Jučer';

  @override
  String get chatEdited => 'uređeno';

  @override
  String get chatYou => 'Vi';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Ova datoteka ima $size MB. Slanje velikih datoteka može biti sporo na nekim mrežama. Nastaviti?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Sigurnosni ključ korisnika $name se promijenio. Dodirnite za provjeru.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Nije moguće šifrirati poruku za $name — poruka nije poslana.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Sigurnosni broj za $name se promijenio. Dodirnite za provjeru.';
  }

  @override
  String get chatNoMessagesFound => 'Poruke nisu pronađene';

  @override
  String get chatMessagesE2ee => 'Poruke su end-to-end šifrirane';

  @override
  String get chatSayHello => 'Recite bok';

  @override
  String get appBarOnline => 'online';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'tipka';

  @override
  String get appBarSearchMessages => 'Pretraži poruke...';

  @override
  String get appBarMute => 'Utišaj';

  @override
  String get appBarUnmute => 'Uključi zvuk';

  @override
  String get appBarMedia => 'Mediji';

  @override
  String get appBarDisappearing => 'Nestajuće poruke';

  @override
  String get appBarDisappearingOn => 'Nestajanje: uključeno';

  @override
  String get appBarGroupSettings => 'Postavke grupe';

  @override
  String get appBarSearchTooltip => 'Pretraži poruke';

  @override
  String get appBarVoiceCall => 'Glasovni poziv';

  @override
  String get appBarVideoCall => 'Videopoziv';

  @override
  String get inputMessage => 'Poruka...';

  @override
  String get inputAttachFile => 'Priloži datoteku';

  @override
  String get inputSendMessage => 'Pošalji poruku';

  @override
  String get inputRecordVoice => 'Snimi glasovnu poruku';

  @override
  String get inputSendVoice => 'Pošalji glasovnu poruku';

  @override
  String get inputCancelReply => 'Otkaži odgovor';

  @override
  String get inputCancelEdit => 'Otkaži uređivanje';

  @override
  String get inputCancelRecording => 'Otkaži snimanje';

  @override
  String get inputRecording => 'Snimanje…';

  @override
  String get inputEditingMessage => 'Uređivanje poruke';

  @override
  String get inputPhoto => 'Fotografija';

  @override
  String get inputVoiceMessage => 'Glasovna poruka';

  @override
  String get inputFile => 'Datoteka';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'e',
      one: '',
    );
    return '$count zakazana poruka$_temp0';
  }

  @override
  String get callInitializing => 'Pokretanje poziva…';

  @override
  String get callConnecting => 'Povezivanje…';

  @override
  String get callConnectingRelay => 'Povezivanje (relay)…';

  @override
  String get callSwitchingRelay => 'Prebacivanje na relay način…';

  @override
  String get callConnectionFailed => 'Povezivanje neuspješno';

  @override
  String get callReconnecting => 'Ponovno povezivanje…';

  @override
  String get callEnded => 'Poziv završen';

  @override
  String get callLive => 'Uživo';

  @override
  String get callEnd => 'Kraj';

  @override
  String get callEndCall => 'Završi poziv';

  @override
  String get callMute => 'Utišaj';

  @override
  String get callUnmute => 'Uključi zvuk';

  @override
  String get callSpeaker => 'Zvučnik';

  @override
  String get callCameraOn => 'Kamera uklj.';

  @override
  String get callCameraOff => 'Kamera isklj.';

  @override
  String get callShareScreen => 'Dijeli zaslon';

  @override
  String get callStopShare => 'Zaustavi dijeljenje';

  @override
  String callTorBackup(String duration) {
    return 'Tor rezerva · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor rezerva aktivna — primarni put nedostupan';

  @override
  String get callDirectFailed =>
      'Izravna veza neuspješna — prebacivanje na relay način…';

  @override
  String get callTurnUnreachable =>
      'TURN poslužitelji nedostupni. Dodajte prilagođeni TURN u Postavke → Napredno.';

  @override
  String get callRelayMode => 'Relay način aktivan (ograničena mreža)';

  @override
  String get callStarting => 'Pokretanje poziva…';

  @override
  String get callConnectingToGroup => 'Povezivanje s grupom…';

  @override
  String get callGroupOpenedInBrowser => 'Grupni poziv otvoren u pregledniku';

  @override
  String get callCouldNotOpenBrowser => 'Preglednik se nije mogao otvoriti';

  @override
  String get callInviteLinkSent => 'Pozivni link poslan svim članovima grupe.';

  @override
  String get callOpenLinkManually =>
      'Otvorite gornji link ručno ili dodirnite za ponovni pokušaj.';

  @override
  String get callJitsiNotE2ee => 'Jitsi pozivi NISU end-to-end šifrirani';

  @override
  String get callRetryOpenBrowser => 'Ponovno otvori preglednik';

  @override
  String get callClose => 'Zatvori';

  @override
  String get callCamOn => 'Kamera uklj.';

  @override
  String get callCamOff => 'Kamera isklj.';

  @override
  String get noConnection => 'Nema veze — poruke će se staviti u red';

  @override
  String get connected => 'Povezano';

  @override
  String get connecting => 'Povezivanje…';

  @override
  String get disconnected => 'Odspojeno';

  @override
  String get offlineBanner =>
      'Nema veze — poruke će se poslati kad budete ponovno online';

  @override
  String get lanModeBanner => 'LAN način — Nema interneta · Samo lokalna mreža';

  @override
  String get probeCheckingNetwork => 'Provjera mrežne povezanosti…';

  @override
  String get probeDiscoveringRelays =>
      'Otkrivanje relaya putem javnih direktorija…';

  @override
  String get probeStartingTor => 'Pokretanje Tor za pokretanje…';

  @override
  String get probeFindingRelaysTor => 'Traženje dostupnih relaya putem Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'a',
      one: '',
    );
    return 'Mreža spremna — $count relay$_temp0 pronađeno';
  }

  @override
  String get probeNoRelaysFound =>
      'Nema dostupnih relaya — poruke mogu kasniti';

  @override
  String get jitsiWarningTitle => 'Nije end-to-end šifrirano';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet pozivi nisu šifrirani od strane Pulse. Koristite samo za neosjetljive razgovore.';

  @override
  String get jitsiConfirm => 'Pridruži se svejedno';

  @override
  String get jitsiGroupWarningTitle => 'Nije end-to-end šifrirano';

  @override
  String get jitsiGroupWarningBody =>
      'Ovaj poziv ima previše sudionika za ugrađenu šifriranu mrežu.\n\nJitsi Meet link će se otvoriti u vašem pregledniku. Jitsi NIJE end-to-end šifriran — poslužitelj može vidjeti vaš poziv.';

  @override
  String get jitsiContinueAnyway => 'Nastavi svejedno';

  @override
  String get retry => 'Pokušaj ponovno';

  @override
  String get setupCreateAnonymousAccount => 'Kreiraj anonimni račun';

  @override
  String get setupTapToChangeColor => 'Dodirnite za promjenu boje';

  @override
  String get setupReqMinLength => 'At least 16 characters';

  @override
  String get setupReqVariety => '3 of 4: uppercase, lowercase, digits, symbols';

  @override
  String get setupReqMatch => 'Passwords match';

  @override
  String get setupYourNickname => 'Vaš nadimak';

  @override
  String get setupRecoveryPassword => 'Lozinka za oporavak (min. 16)';

  @override
  String get setupConfirmPassword => 'Potvrdite lozinku';

  @override
  String get setupMin16Chars => 'Najmanje 16 znakova';

  @override
  String get setupPasswordsDoNotMatch => 'Lozinke se ne podudaraju';

  @override
  String get setupEntropyWeak => 'Slaba';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Jaka';

  @override
  String get setupEntropyWeakNeedsVariety => 'Slaba (potrebne 3 vrste znakova)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bitova)';
  }

  @override
  String get setupPasswordWarning =>
      'Ova lozinka je jedini način za oporavak vašeg računa. Nema poslužitelja — nema ponovnog postavljanja lozinke. Zapamtite je ili zapišite.';

  @override
  String get setupCreateAccount => 'Kreiraj račun';

  @override
  String get setupAlreadyHaveAccount => 'Već imate račun? ';

  @override
  String get setupRestore => 'Oporavi →';

  @override
  String get restoreTitle => 'Oporavak računa';

  @override
  String get restoreInfoBanner =>
      'Unesite svoju lozinku za oporavak — vaša adresa (Nostr + Session) će se automatski obnoviti. Kontakti i poruke bili su pohranjeni samo lokalno.';

  @override
  String get restoreNewNickname => 'Novi nadimak (može se kasnije promijeniti)';

  @override
  String get restoreButton => 'Oporavi račun';

  @override
  String get lockTitle => 'Pulse je zaključan';

  @override
  String get lockSubtitle => 'Unesite lozinku za nastavak';

  @override
  String get lockPasswordHint => 'Lozinka';

  @override
  String get lockUnlock => 'Otključaj';

  @override
  String get lockPanicHint =>
      'Zaboravili ste lozinku? Unesite panik ključ za brisanje svih podataka.';

  @override
  String get lockTooManyAttempts => 'Previše pokušaja. Brisanje svih podataka…';

  @override
  String get lockWrongPassword => 'Pogrešna lozinka';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Pogrešna lozinka — $attempts/$max pokušaja';
  }

  @override
  String get onboardingSkip => 'Preskoči';

  @override
  String get onboardingNext => 'Dalje';

  @override
  String get onboardingGetStarted => 'Započni';

  @override
  String get onboardingWelcomeTitle => 'Dobrodošli u Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Decentralizirani, end-to-end šifrirani messenger.\n\nNema centralnih poslužitelja. Nema prikupljanja podataka. Nema stražnjih vrata.\nVaši razgovori pripadaju samo vama.';

  @override
  String get onboardingTransportTitle => 'Neovisnost o transportu';

  @override
  String get onboardingTransportBody =>
      'Koristite Firebase, Nostr ili oboje istovremeno.\n\nPoruke se automatski usmjeravaju preko mreža. Ugrađena Tor i I2P podrška za otpornost na cenzuru.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Svaka poruka je šifrirana Signal protokolom (Double Ratchet + X3DH) za forward secrecy.\n\nDodatno omotana s Kyber-1024 — NIST standardnim post-kvantnim algoritmom — za zaštitu od budućih kvantnih računala.';

  @override
  String get onboardingKeysTitle => 'Vaši ključevi su vaši';

  @override
  String get onboardingKeysBody =>
      'Vaši identitetski ključevi nikad ne napuštaju vaš uređaj.\n\nSignal otisci omogućuju provjeru kontakata izvan kanala. TOFU (Trust On First Use) automatski otkriva promjene ključeva.';

  @override
  String get onboardingThemeTitle => 'Odaberite svoj stil';

  @override
  String get onboardingThemeBody =>
      'Odaberite temu i boju akcenta. Uvijek to možete promijeniti kasnije u Postavkama.';

  @override
  String get contactsNewChat => 'Novi razgovor';

  @override
  String get contactsAddContact => 'Dodaj kontakt';

  @override
  String get contactsSearchHint => 'Pretraži...';

  @override
  String get contactsNewGroup => 'Nova grupa';

  @override
  String get contactsNoContactsYet => 'Još nema kontakata';

  @override
  String get contactsAddHint => 'Dodirnite + da biste dodali nečiju adresu';

  @override
  String get contactsNoMatch => 'Nema odgovarajućih kontakata';

  @override
  String get contactsRemoveTitle => 'Ukloni kontakt';

  @override
  String contactsRemoveMessage(String name) {
    return 'Ukloniti $name?';
  }

  @override
  String get contactsRemove => 'Ukloni';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'a',
      one: '',
    );
    return '$count kontakt$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Otvori link';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Otvoriti ovaj URL u pregledniku?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Otvori';

  @override
  String get bubbleSecurityWarning => 'Sigurnosno upozorenje';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" je izvršna datoteka. Spremanje i pokretanje može oštetiti vaš uređaj. Ipak spremiti?';
  }

  @override
  String get bubbleSaveAnyway => 'Ipak spremi';

  @override
  String bubbleSavedTo(String path) {
    return 'Spremljeno u $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Spremanje neuspješno: $error';
  }

  @override
  String get bubbleNotEncrypted => 'NIJE ŠIFRIRANO';

  @override
  String get bubbleCorruptedImage => '[Oštećena slika]';

  @override
  String get bubbleReplyPhoto => 'Fotografija';

  @override
  String get bubbleReplyVoice => 'Glasovna poruka';

  @override
  String get bubbleReplyVideo => 'Videoporuka';

  @override
  String bubbleReadBy(String names) {
    return 'Pročitao/la $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Pročitalo $count';
  }

  @override
  String get chatTileTapToStart => 'Dodirnite za početak razgovora';

  @override
  String get chatTileMessageSent => 'Poruka poslana';

  @override
  String get chatTileEncryptedMessage => 'Šifrirana poruka';

  @override
  String chatTileYouPrefix(String text) {
    return 'Vi: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Voice message';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Voice message ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Šifrirana poruka';

  @override
  String get groupNewGroup => 'Nova grupa';

  @override
  String get groupGroupName => 'Naziv grupe';

  @override
  String get groupSelectMembers => 'Odaberite članove (min. 2)';

  @override
  String get groupNoContactsYet => 'Još nema kontakata. Prvo dodajte kontakte.';

  @override
  String get groupCreate => 'Kreiraj';

  @override
  String get groupLabel => 'Grupa';

  @override
  String get profileVerifyIdentity => 'Provjeri identitet';

  @override
  String profileVerifyInstructions(String name) {
    return 'Usporedite ove otiske s kontaktom $name putem glasovnog poziva ili osobno. Ako se obje vrijednosti podudaraju na oba uređaja, dodirnite „Označi kao provjereno“.';
  }

  @override
  String get profileTheirKey => 'Njihov ključ';

  @override
  String get profileYourKey => 'Vaš ključ';

  @override
  String get profileRemoveVerification => 'Ukloni provjeru';

  @override
  String get profileMarkAsVerified => 'Označi kao provjereno';

  @override
  String get profileAddressCopied => 'Adresa kopirana';

  @override
  String get profileNoContactsToAdd =>
      'Nema kontakata za dodavanje — svi su već članovi';

  @override
  String get profileAddMembers => 'Dodaj članove';

  @override
  String profileAddCount(int count) {
    return 'Dodaj ($count)';
  }

  @override
  String get profileRenameGroup => 'Preimenuj grupu';

  @override
  String get profileRename => 'Preimenuj';

  @override
  String get profileRemoveMember => 'Ukloniti člana?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Ukloniti $name iz ove grupe?';
  }

  @override
  String get profileKick => 'Izbaci';

  @override
  String get profileSignalFingerprints => 'Signal otisci';

  @override
  String get profileVerified => 'PROVJERENO';

  @override
  String get profileVerify => 'Provjeri';

  @override
  String get profileEdit => 'Uredi';

  @override
  String get profileNoSession =>
      'Sesija još nije uspostavljena — prvo pošaljite poruku.';

  @override
  String get profileFingerprintCopied => 'Otisak kopiran';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ova',
      one: '',
    );
    return '$count član$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Provjeri sigurnosni broj';

  @override
  String get profileShowContactQr => 'Prikaži QR kontakta';

  @override
  String profileContactAddress(String name) {
    return 'Adresa korisnika $name';
  }

  @override
  String get profileExportChatHistory => 'Izvezi povijest razgovora';

  @override
  String profileSavedTo(String path) {
    return 'Spremljeno u $path';
  }

  @override
  String get profileExportFailed => 'Izvoz neuspješan';

  @override
  String get profileClearChatHistory => 'Obriši povijest razgovora';

  @override
  String get profileDeleteGroup => 'Obriši grupu';

  @override
  String get profileDeleteContact => 'Obriši kontakt';

  @override
  String get profileLeaveGroup => 'Napusti grupu';

  @override
  String get profileLeaveGroupBody =>
      'Bit ćete uklonjeni iz ove grupe i ona će biti obrisana iz vaših kontakata.';

  @override
  String get groupInviteTitle => 'Pozivnica za grupu';

  @override
  String groupInviteBody(String from, String group) {
    return '$from vas je pozvao/la da se pridružite grupi \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Prihvati';

  @override
  String get groupInviteDecline => 'Odbij';

  @override
  String get groupMemberLimitTitle => 'Previše sudionika';

  @override
  String groupMemberLimitBody(int count) {
    return 'Ova grupa će imati $count sudionika. Šifrirani mesh pozivi podržavaju do 6. Veće grupe koriste Jitsi (nije E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Ipak dodaj';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name je odbio/la pridruživanje grupi \"$group\"';
  }

  @override
  String get transferTitle => 'Prijenos na drugi uređaj';

  @override
  String get transferInfoBox =>
      'Premjestite svoj Signal identitet i Nostr ključeve na novi uređaj.\nSesije razgovora se NE prenose — forward secrecy je očuvan.';

  @override
  String get transferSendFromThis => 'Pošalji s ovog uređaja';

  @override
  String get transferSendSubtitle =>
      'Ovaj uređaj ima ključeve. Podijelite kod s novim uređajem.';

  @override
  String get transferReceiveOnThis => 'Primi na ovom uređaju';

  @override
  String get transferReceiveSubtitle =>
      'Ovo je novi uređaj. Unesite kod sa starog uređaja.';

  @override
  String get transferChooseMethod => 'Odaberite način prijenosa';

  @override
  String get transferLan => 'LAN (Ista mreža)';

  @override
  String get transferLanSubtitle =>
      'Brzo i izravno. Oba uređaja moraju biti na istom Wi-Fi.';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'Radi preko bilo koje mreže koristeći postojeći Nostr relay.';

  @override
  String get transferRelayUrl => 'URL relaya';

  @override
  String get transferEnterCode => 'Unesite kod za prijenos';

  @override
  String get transferPasteCode => 'Zalijepite LAN:... ili NOS:... kod ovdje';

  @override
  String get transferConnect => 'Poveži';

  @override
  String get transferGenerating => 'Generiranje koda za prijenos…';

  @override
  String get transferShareCode => 'Podijelite ovaj kod s primateljem:';

  @override
  String get transferCopyCode => 'Kopiraj kod';

  @override
  String get transferCodeCopied => 'Kod kopiran u međuspremnik';

  @override
  String get transferWaitingReceiver => 'Čekanje da se primatelj poveže…';

  @override
  String get transferConnectingSender => 'Povezivanje s pošiljateljem…';

  @override
  String get transferVerifyBoth =>
      'Usporedite ovaj kod na oba uređaja.\nAko se podudaraju, prijenos je siguran.';

  @override
  String get transferComplete => 'Prijenos dovršen';

  @override
  String get transferKeysImported => 'Ključevi uvezeni';

  @override
  String get transferCompleteSenderBody =>
      'Vaši ključevi ostaju aktivni na ovom uređaju.\nPrimatelj sada može koristiti vaš identitet.';

  @override
  String get transferCompleteReceiverBody =>
      'Ključevi uspješno uvezeni.\nPonovno pokrenite aplikaciju za primjenu novog identiteta.';

  @override
  String get transferRestartApp => 'Ponovno pokreni aplikaciju';

  @override
  String get transferFailed => 'Prijenos neuspješan';

  @override
  String get transferTryAgain => 'Pokušaj ponovno';

  @override
  String get transferEnterRelayFirst => 'Prvo unesite URL relaya';

  @override
  String get transferPasteCodeFromSender =>
      'Zalijepite kod za prijenos od pošiljatelja';

  @override
  String get menuReply => 'Odgovori';

  @override
  String get menuForward => 'Proslijedi';

  @override
  String get menuReact => 'Reagiraj';

  @override
  String get menuCopy => 'Kopiraj';

  @override
  String get menuEdit => 'Uredi';

  @override
  String get menuRetry => 'Pokušaj ponovno';

  @override
  String get menuCancelScheduled => 'Otkaži zakazano';

  @override
  String get menuDelete => 'Obriši';

  @override
  String get menuForwardTo => 'Proslijedi…';

  @override
  String menuForwardedTo(String name) {
    return 'Proslijeđeno kontaktu $name';
  }

  @override
  String get menuScheduledMessages => 'Zakazane poruke';

  @override
  String get menuNoScheduledMessages => 'Nema zakazanih poruka';

  @override
  String menuSendsOn(String date) {
    return 'Šalje se $date';
  }

  @override
  String get menuDisappearingMessages => 'Nestajuće poruke';

  @override
  String get menuDisappearingSubtitle =>
      'Poruke se automatski brišu nakon odabranog vremena.';

  @override
  String get menuTtlOff => 'Isključeno';

  @override
  String get menuTtl1h => '1 sat';

  @override
  String get menuTtl24h => '24 sata';

  @override
  String get menuTtl7d => '7 dana';

  @override
  String get menuAttachPhoto => 'Fotografija';

  @override
  String get menuAttachFile => 'Datoteka';

  @override
  String get menuAttachVideo => 'Video';

  @override
  String get mediaTitle => 'Mediji';

  @override
  String get mediaFileLabel => 'DATOTEKA';

  @override
  String mediaPhotosTab(int count) {
    return 'Fotografije ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Datoteke ($count)';
  }

  @override
  String get mediaNoPhotos => 'Još nema fotografija';

  @override
  String get mediaNoFiles => 'Još nema datoteka';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Spremljeno u Preuzimanja/$name';
  }

  @override
  String get mediaFailedToSave => 'Spremanje datoteke neuspješno';

  @override
  String get statusNewStatus => 'Novi status';

  @override
  String get statusPublish => 'Objavi';

  @override
  String get statusExpiresIn24h => 'Status ističe za 24 sata';

  @override
  String get statusWhatsOnYourMind => 'Što vam je na umu?';

  @override
  String get statusPhotoAttached => 'Fotografija priložena';

  @override
  String get statusAttachPhoto => 'Priloži fotografiju (opcionalno)';

  @override
  String get statusEnterText => 'Unesite tekst za svoj status.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Odabir fotografije neuspješan: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Objava neuspješna: $error';
  }

  @override
  String get panicSetPanicKey => 'Postavi panik ključ';

  @override
  String get panicEmergencySelfDestruct => 'Hitno samouništenje';

  @override
  String get panicIrreversible => 'Ova radnja je nepovratna';

  @override
  String get panicWarningBody =>
      'Unosom ovog ključa na zaključanom zaslonu trenutno se brišu SVI podaci — poruke, kontakti, ključevi, identitet. Koristite ključ različit od vaše redovne lozinke.';

  @override
  String get panicKeyHint => 'Panik ključ';

  @override
  String get panicConfirmHint => 'Potvrdite panik ključ';

  @override
  String get panicMinChars => 'Panik ključ mora imati najmanje 8 znakova';

  @override
  String get panicKeysDoNotMatch => 'Ključevi se ne podudaraju';

  @override
  String get panicSetFailed =>
      'Spremanje panik ključa neuspješno — pokušajte ponovno';

  @override
  String get passwordSetAppPassword => 'Postavi lozinku aplikacije';

  @override
  String get passwordProtectsMessages => 'Štiti vaše poruke u mirovanju';

  @override
  String get passwordInfoBanner =>
      'Potrebna svaki put kad otvorite Pulse. Ako je zaboravite, vaši podaci ne mogu biti obnovljeni.';

  @override
  String get passwordHint => 'Lozinka';

  @override
  String get passwordConfirmHint => 'Potvrdite lozinku';

  @override
  String get passwordSetButton => 'Postavi lozinku';

  @override
  String get passwordSkipForNow => 'Preskoči za sada';

  @override
  String get passwordMinChars => 'Lozinka mora imati najmanje 6 znakova';

  @override
  String get passwordsDoNotMatch => 'Lozinke se ne podudaraju';

  @override
  String get profileCardSaved => 'Profil spremljen!';

  @override
  String get profileCardE2eeIdentity => 'E2EE identitet';

  @override
  String get profileCardDisplayName => 'Ime za prikaz';

  @override
  String get profileCardDisplayNameHint => 'npr. Ivan Horvat';

  @override
  String get profileCardAbout => 'O meni';

  @override
  String get profileCardSaveProfile => 'Spremi profil';

  @override
  String get profileCardYourName => 'Vaše ime';

  @override
  String get profileCardAddressCopied => 'Adresa kopirana!';

  @override
  String get profileCardInboxAddress => 'Vaša adresa sandučića';

  @override
  String get profileCardInboxAddresses => 'Vaše adrese sandučića';

  @override
  String get profileCardShareAllAddresses =>
      'Podijeli sve adrese (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Podijelite s kontaktima kako bi vam mogli slati poruke.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Svih $count adresa kopirano kao jedan link!';
  }

  @override
  String get settingsMyProfile => 'Moj profil';

  @override
  String get settingsYourInboxAddress => 'Vaša adresa sandučića';

  @override
  String get settingsMyQrCode => 'Moj QR kod';

  @override
  String get settingsMyQrSubtitle =>
      'Podijelite svoju adresu kao QR kod za skeniranje';

  @override
  String get settingsShareMyAddress => 'Podijeli moju adresu';

  @override
  String get settingsNoAddressYet => 'Još nema adrese — prvo spremite postavke';

  @override
  String get settingsInviteLink => 'Pozivni link';

  @override
  String get settingsRawAddress => 'Neobrađena adresa';

  @override
  String get settingsCopyLink => 'Kopiraj link';

  @override
  String get settingsCopyAddress => 'Kopiraj adresu';

  @override
  String get settingsInviteLinkCopied => 'Pozivni link kopiran';

  @override
  String get settingsAppearance => 'Izgled';

  @override
  String get settingsThemeEngine => 'Pokretač tema';

  @override
  String get settingsThemeEngineSubtitle => 'Prilagodite boje i fontove';

  @override
  String get settingsSignalProtocol => 'Signal protokol';

  @override
  String get settingsSignalProtocolSubtitle =>
      'E2EE ključevi su sigurno pohranjeni';

  @override
  String get settingsActive => 'AKTIVNO';

  @override
  String get settingsIdentityBackup => 'Sigurnosna kopija identiteta';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Izvezite ili uvezite svoj Signal identitet';

  @override
  String get settingsIdentityBackupBody =>
      'Izvezite svoje Signal identitetske ključeve u sigurnosni kod ili ih obnovite iz postojećeg.';

  @override
  String get settingsTransferDevice => 'Prijenos na drugi uređaj';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Premjestite identitet putem LAN ili Nostr relaya';

  @override
  String get settingsExportIdentity => 'Izvezi identitet';

  @override
  String get settingsExportIdentityBody =>
      'Kopirajte ovaj sigurnosni kod i spremite ga na sigurno:';

  @override
  String get settingsSaveFile => 'Spremi datoteku';

  @override
  String get settingsImportIdentity => 'Uvezi identitet';

  @override
  String get settingsImportIdentityBody =>
      'Zalijepite svoj sigurnosni kod ispod. Ovo će prebrisati vaš trenutačni identitet.';

  @override
  String get settingsPasteBackupCode => 'Zalijepite sigurnosni kod ovdje…';

  @override
  String get settingsIdentityImported =>
      'Identitet + kontakti uvezeni! Ponovo pokrenite aplikaciju za primjenu.';

  @override
  String get settingsSecurity => 'Sigurnost';

  @override
  String get settingsAppPassword => 'Lozinka aplikacije';

  @override
  String get settingsPasswordEnabled =>
      'Omogućeno — potrebno pri svakom pokretanju';

  @override
  String get settingsPasswordDisabled =>
      'Onemogućeno — aplikacija se otvara bez lozinke';

  @override
  String get settingsChangePassword => 'Promijeni lozinku';

  @override
  String get settingsChangePasswordSubtitle =>
      'Ažurirajte lozinku za zaključavanje aplikacije';

  @override
  String get settingsSetPanicKey => 'Postavi panik ključ';

  @override
  String get settingsChangePanicKey => 'Promijeni panik ključ';

  @override
  String get settingsPanicKeySetSubtitle =>
      'Ažurirajte ključ za hitno brisanje';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Jedan ključ koji trenutno briše sve podatke';

  @override
  String get settingsRemovePanicKey => 'Ukloni panik ključ';

  @override
  String get settingsRemovePanicKeySubtitle => 'Onemogući hitno samouništenje';

  @override
  String get settingsRemovePanicKeyBody =>
      'Hitno samouništenje će biti onemogućeno. Možete ga ponovno omogućiti u bilo kojem trenutku.';

  @override
  String get settingsDisableAppPassword => 'Onemogući lozinku aplikacije';

  @override
  String get settingsEnterCurrentPassword =>
      'Unesite trenutačnu lozinku za potvrdu';

  @override
  String get settingsCurrentPassword => 'Trenutačna lozinka';

  @override
  String get settingsIncorrectPassword => 'Pogrešna lozinka';

  @override
  String get settingsPasswordUpdated => 'Lozinka ažurirana';

  @override
  String get settingsChangePasswordProceed =>
      'Unesite trenutačnu lozinku za nastavak';

  @override
  String get settingsData => 'Podaci';

  @override
  String get settingsBackupMessages => 'Sigurnosna kopija poruka';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Izvezite šifrirani povijest poruka u datoteku';

  @override
  String get settingsRestoreMessages => 'Obnovi poruke';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Uvezite poruke iz datoteke sigurnosne kopije';

  @override
  String get settingsExportKeys => 'Izvezi ključeve';

  @override
  String get settingsExportKeysSubtitle =>
      'Spremite identitetske ključeve u šifriranu datoteku';

  @override
  String get settingsImportKeys => 'Uvezi ključeve';

  @override
  String get settingsImportKeysSubtitle =>
      'Obnovite identitetske ključeve iz izvezene datoteke';

  @override
  String get settingsBackupPassword => 'Lozinka sigurnosne kopije';

  @override
  String get settingsPasswordCannotBeEmpty => 'Lozinka ne može biti prazna';

  @override
  String get settingsPasswordMin4Chars => 'Lozinka mora imati najmanje 4 znaka';

  @override
  String get settingsCallsTurn => 'Pozivi i TURN';

  @override
  String get settingsLocalNetwork => 'Lokalna mreža';

  @override
  String get settingsCensorshipResistance => 'Otpornost na cenzuru';

  @override
  String get settingsNetwork => 'Mreža';

  @override
  String get settingsProxyTunnels => 'Proxy i tuneli';

  @override
  String get settingsTurnServers => 'TURN poslužitelji';

  @override
  String get settingsProviderTitle => 'Pružatelj';

  @override
  String get settingsLanFallback => 'LAN rezerva';

  @override
  String get settingsLanFallbackSubtitle =>
      'Emitirajte prisutnost i dostavljajte poruke na lokalnoj mreži kad internet nije dostupan. Onemogućite na nepouzdanim mrežama (javni Wi-Fi).';

  @override
  String get settingsBgDelivery => 'Dostava u pozadini';

  @override
  String get settingsBgDeliverySubtitle =>
      'Nastavite primati poruke kad je aplikacija minimizirana. Prikazuje stalnu obavijest.';

  @override
  String get settingsYourInboxProvider => 'Vaš pružatelj sandučića';

  @override
  String get settingsConnectionDetails => 'Detalji veze';

  @override
  String get settingsSaveAndConnect => 'Spremi i poveži';

  @override
  String get settingsSecondaryInboxes => 'Sekundarni sandučići';

  @override
  String get settingsAddSecondaryInbox => 'Dodaj sekundarni sandučić';

  @override
  String get settingsAdvanced => 'Napredno';

  @override
  String get settingsDiscover => 'Otkrij';

  @override
  String get settingsAbout => 'O aplikaciji';

  @override
  String get settingsPrivacyPolicy => 'Pravila privatnosti';

  @override
  String get settingsPrivacyPolicySubtitle => 'Kako Pulse štiti vaše podatke';

  @override
  String get settingsCrashReporting => 'Izvješćivanje o rušenjima';

  @override
  String get settingsCrashReportingSubtitle =>
      'Šaljite anonimna izvješća o rušenjima za poboljšanje Pulse. Nikad se ne šalje sadržaj poruka ili kontakti.';

  @override
  String get settingsCrashReportingEnabled =>
      'Izvješćivanje o rušenjima omogućeno — ponovo pokrenite aplikaciju za primjenu';

  @override
  String get settingsCrashReportingDisabled =>
      'Izvješćivanje o rušenjima onemogućeno — ponovo pokrenite aplikaciju za primjenu';

  @override
  String get settingsSensitiveOperation => 'Osjetljiva operacija';

  @override
  String get settingsSensitiveOperationBody =>
      'Ovi ključevi su vaš identitet. Svatko s ovom datotekom vas može lažno predstavljati. Pohranite je sigurno i obrišite nakon prijenosa.';

  @override
  String get settingsIUnderstandContinue => 'Razumijem, nastavi';

  @override
  String get settingsReplaceIdentity => 'Zamijeniti identitet?';

  @override
  String get settingsReplaceIdentityBody =>
      'Ovo će prebrisati vaše trenutačne identitetske ključeve. Vaše postojeće Signal sesije će biti poništene i kontakti će morati ponovno uspostaviti šifriranje. Aplikaciju je potrebno ponovo pokrenuti.';

  @override
  String get settingsReplaceKeys => 'Zamijeni ključeve';

  @override
  String get settingsKeysImported => 'Ključevi uvezeni';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count ključeva uspješno uvezeno. Molimo ponovo pokrenite aplikaciju za inicijalizaciju s novim identitetom.';
  }

  @override
  String get settingsRestartNow => 'Ponovo pokreni sada';

  @override
  String get settingsLater => 'Kasnije';

  @override
  String get profileGroupLabel => 'Grupa';

  @override
  String get profileAddButton => 'Dodaj';

  @override
  String get profileKickButton => 'Izbaci';

  @override
  String get dataSectionTitle => 'Podaci';

  @override
  String get dataBackupMessages => 'Sigurnosna kopija poruka';

  @override
  String get dataBackupPasswordSubtitle =>
      'Odaberite lozinku za šifriranje sigurnosne kopije poruka.';

  @override
  String get dataBackupConfirmLabel => 'Kreiraj sigurnosnu kopiju';

  @override
  String get dataCreatingBackup => 'Kreiranje sigurnosne kopije';

  @override
  String get dataBackupPreparing => 'Priprema...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Izvoz poruke $done od $total...';
  }

  @override
  String get dataBackupSavingFile => 'Spremanje datoteke...';

  @override
  String get dataSaveMessageBackupDialog => 'Spremi sigurnosnu kopiju poruka';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Sigurnosna kopija spremljena ($count poruka)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Sigurnosna kopija neuspješna — nema izvezenih podataka';

  @override
  String dataBackupFailedError(String error) {
    return 'Sigurnosna kopija neuspješna: $error';
  }

  @override
  String get dataSelectMessageBackupDialog =>
      'Odaberi sigurnosnu kopiju poruka';

  @override
  String get dataInvalidBackupFile =>
      'Neispravna datoteka sigurnosne kopije (premala)';

  @override
  String get dataNotValidBackupFile =>
      'Nije ispravna Pulse datoteka sigurnosne kopije';

  @override
  String get dataRestoreMessages => 'Obnovi poruke';

  @override
  String get dataRestorePasswordSubtitle =>
      'Unesite lozinku korištenu za kreiranje ove sigurnosne kopije.';

  @override
  String get dataRestoreConfirmLabel => 'Obnovi';

  @override
  String get dataRestoringMessages => 'Obnavljanje poruka';

  @override
  String get dataRestoreDecrypting => 'Dešifriranje...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Uvoz poruke $done od $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Obnova neuspješna — pogrešna lozinka ili oštećena datoteka';

  @override
  String dataRestoreSuccess(int count) {
    return 'Obnovljeno $count novih poruka';
  }

  @override
  String get dataRestoreNothingNew =>
      'Nema novih poruka za uvoz (sve već postoje)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Obnova neuspješna: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Odaberi izvoz ključeva';

  @override
  String get dataNotValidKeyFile =>
      'Nije ispravna Pulse datoteka izvoza ključeva';

  @override
  String get dataExportKeys => 'Izvezi ključeve';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Odaberite lozinku za šifriranje izvoza ključeva.';

  @override
  String get dataExportKeysConfirmLabel => 'Izvezi';

  @override
  String get dataExportingKeys => 'Izvoz ključeva';

  @override
  String get dataExportingKeysStatus => 'Šifriranje identitetskih ključeva...';

  @override
  String get dataSaveKeyExportDialog => 'Spremi izvoz ključeva';

  @override
  String dataKeysExportedTo(String path) {
    return 'Ključevi izvezeni u:\n$path';
  }

  @override
  String get dataExportFailed => 'Izvoz neuspješan — ključevi nisu pronađeni';

  @override
  String dataExportFailedError(String error) {
    return 'Izvoz neuspješan: $error';
  }

  @override
  String get dataImportKeys => 'Uvezi ključeve';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Unesite lozinku korištenu za šifriranje ovog izvoza ključeva.';

  @override
  String get dataImportKeysConfirmLabel => 'Uvezi';

  @override
  String get dataImportingKeys => 'Uvoz ključeva';

  @override
  String get dataImportingKeysStatus =>
      'Dešifriranje identitetskih ključeva...';

  @override
  String get dataImportFailed =>
      'Uvoz neuspješan — pogrešna lozinka ili oštećena datoteka';

  @override
  String dataImportFailedError(String error) {
    return 'Uvoz neuspješan: $error';
  }

  @override
  String get securitySectionTitle => 'Sigurnost';

  @override
  String get securityIncorrectPassword => 'Pogrešna lozinka';

  @override
  String get securityPasswordUpdated => 'Lozinka ažurirana';

  @override
  String get appearanceSectionTitle => 'Izgled';

  @override
  String appearanceExportFailed(String error) {
    return 'Izvoz neuspješan: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Spremljeno u $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Spremanje neuspješno: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Uvoz neuspješan: $error';
  }

  @override
  String get aboutSectionTitle => 'O aplikaciji';

  @override
  String get providerPublicKey => 'Javni ključ';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Automatski konfigurirano iz vaše lozinke za oporavak. Relay automatski otkriven.';

  @override
  String get providerKeyStoredLocally =>
      'Vaš ključ je pohranjen lokalno u sigurnoj pohrani — nikad se ne šalje na poslužitelj.';

  @override
  String get providerSessionInfo =>
      'Session Network — onion-routed E2EE. Your Session ID is auto-generated and stored securely. Nodes auto-discovered from built-in seed nodes.';

  @override
  String get providerAdvanced => 'Napredno';

  @override
  String get providerSaveAndConnect => 'Spremi i poveži';

  @override
  String get providerAddSecondaryInbox => 'Dodaj sekundarni sandučić';

  @override
  String get providerSecondaryInboxes => 'Sekundarni sandučići';

  @override
  String get providerYourInboxProvider => 'Vaš pružatelj sandučića';

  @override
  String get providerConnectionDetails => 'Detalji veze';

  @override
  String get addContactTitle => 'Dodaj kontakt';

  @override
  String get addContactInviteLinkLabel => 'Pozivni link ili adresa';

  @override
  String get addContactTapToPaste => 'Dodirnite za lijepljenje pozivnog linka';

  @override
  String get addContactPasteTooltip => 'Zalijepi iz međuspremnika';

  @override
  String get addContactAddressDetected => 'Adresa kontakta otkrivena';

  @override
  String addContactRoutesDetected(int count) {
    return '$count ruta otkriveno — SmartRouter odabire najbrži';
  }

  @override
  String get addContactFetchingProfile => 'Dohvaćanje profila…';

  @override
  String addContactProfileFound(String name) {
    return 'Pronađeno: $name';
  }

  @override
  String get addContactNoProfileFound => 'Profil nije pronađen';

  @override
  String get addContactDisplayNameLabel => 'Ime za prikaz';

  @override
  String get addContactDisplayNameHint => 'Kako ih želite nazvati?';

  @override
  String get addContactAddManually => 'Ručno unesi adresu';

  @override
  String get addContactButton => 'Dodaj kontakt';

  @override
  String get networkDiagnosticsTitle => 'Dijagnostika mreže';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr relayi';

  @override
  String get networkDiagnosticsDirect => 'Izravno';

  @override
  String get networkDiagnosticsTorOnly => 'Samo Tor';

  @override
  String get networkDiagnosticsBest => 'Najbolji';

  @override
  String get networkDiagnosticsNone => 'nijedan';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Status';

  @override
  String get networkDiagnosticsConnected => 'Povezano';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Povezivanje $percent %';
  }

  @override
  String get networkDiagnosticsOff => 'Isključeno';

  @override
  String get networkDiagnosticsTransport => 'Transport';

  @override
  String get networkDiagnosticsInfrastructure => 'Infrastruktura';

  @override
  String get networkDiagnosticsSessionNodes => 'Session nodes';

  @override
  String get networkDiagnosticsTurnServers => 'TURN poslužitelji';

  @override
  String get networkDiagnosticsLastProbe => 'Zadnja provjera';

  @override
  String get networkDiagnosticsRunning => 'Pokrenuto...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Pokreni dijagnostiku';

  @override
  String get networkDiagnosticsForceReprobe =>
      'Prisili potpunu ponovnu provjeru';

  @override
  String get networkDiagnosticsJustNow => 'upravo sada';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'prije $minutes min';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'prije $hours h';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'prije $days d';
  }

  @override
  String get homeNoEch => 'Nema ECH';

  @override
  String get homeNoEchTooltip =>
      'uTLS proxy nedostupan — ECH onemogućen.\nTLS otisak je vidljiv za DPI.';

  @override
  String get settingsTitle => 'Postavke';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Spremljeno i povezano s $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Ugrađeni Tor se nije uspio pokrenuti';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon se nije uspio pokrenuti';

  @override
  String get verifyTitle => 'Provjeri sigurnosni broj';

  @override
  String get verifyIdentityVerified => 'Identitet provjeren';

  @override
  String get verifyNotYetVerified => 'Još nije provjereno';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Provjerili ste sigurnosni broj korisnika $name.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Usporedite ove brojeve s kontaktom $name osobno ili putem pouzdanog kanala.';
  }

  @override
  String get verifyExplanation =>
      'Svaki razgovor ima jedinstveni sigurnosni broj. Ako oboje vidite iste brojeve na svojim uređajima, vaša veza je end-to-end provjerena.';

  @override
  String verifyContactKey(String name) {
    return 'Ključ korisnika $name';
  }

  @override
  String get verifyYourKey => 'Vaš ključ';

  @override
  String get verifyRemoveVerification => 'Ukloni provjeru';

  @override
  String get verifyMarkAsVerified => 'Označi kao provjereno';

  @override
  String verifyAfterReinstall(String name) {
    return 'Ako $name ponovno instalira aplikaciju, sigurnosni broj će se promijeniti i provjera će biti automatski uklonjena.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Označite kao provjereno tek nakon usporedbe brojeva s kontaktom $name putem glasovnog poziva ili osobno.';
  }

  @override
  String get verifyNoSession =>
      'Sesija šifriranja još nije uspostavljena. Prvo pošaljite poruku za generiranje sigurnosnih brojeva.';

  @override
  String get verifyNoKeyAvailable => 'Ključ nije dostupan';

  @override
  String verifyFingerprintCopied(String label) {
    return 'Otisak $label kopiran';
  }

  @override
  String get providerDatabaseUrlLabel => 'URL baze podataka';

  @override
  String get providerOptionalHint => 'Opcionalno';

  @override
  String get providerWebApiKeyLabel => 'Web API ključ';

  @override
  String get providerOptionalForPublicDb => 'Opcionalno za javnu bazu podataka';

  @override
  String get providerRelayUrlLabel => 'URL relaya';

  @override
  String get providerPrivateKeyLabel => 'Privatni ključ';

  @override
  String get providerPrivateKeyNsecLabel => 'Privatni ključ (nsec)';

  @override
  String get providerStorageNodeLabel => 'URL čvora za pohranu (opcionalno)';

  @override
  String get providerStorageNodeHint =>
      'Ostavite prazno za ugrađene seed čvorove';

  @override
  String get transferInvalidCodeFormat =>
      'Neprepoznat format koda — mora počinjati s LAN: ili NOS:';

  @override
  String get profileCardFingerprintCopied => 'Otisak kopiran';

  @override
  String get profileCardAboutHint => 'Privatnost na prvom mjestu 🔒';

  @override
  String get profileCardSaveButton => 'Spremi profil';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Izvezite šifrirane poruke, kontakte i avatare u datoteku';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Audio';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Dostavljeno kontaktu $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Dostavljeno: $count';
  }

  @override
  String get groupStatusDialogTitle => 'Informacije o poruci';

  @override
  String get groupStatusRead => 'Pročitano';

  @override
  String get groupStatusDelivered => 'Dostavljeno';

  @override
  String get groupStatusPending => 'Na čekanju';

  @override
  String get groupStatusNoData => 'Još nema informacija o dostavi';

  @override
  String get profileTransferAdmin => 'Postavi kao admina';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Postaviti $name kao novog admina?';
  }

  @override
  String get profileTransferAdminBody =>
      'Izgubit ćete administratorske ovlasti. Ovo se ne može poništiti.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name je sada admin';
  }

  @override
  String get profileAdminBadge => 'Admin';

  @override
  String get privacyPolicyTitle => 'Pravila privatnosti';

  @override
  String get privacyOverviewHeading => 'Pregled';

  @override
  String get privacyOverviewBody =>
      'Pulse je messenger bez poslužitelja s end-to-end šifriranjem. Vaša privatnost nije samo značajka — to je arhitektura. Nema Pulse poslužitelja. Nikakvi računi se nigdje ne pohranjuju. Nikakvi podaci se ne prikupljaju, ne prenose niti pohranjuju od strane razvojnih programera.';

  @override
  String get privacyDataCollectionHeading => 'Prikupljanje podataka';

  @override
  String get privacyDataCollectionBody =>
      'Pulse ne prikuplja nikakve osobne podatke. Konkretno:\n\n- Nije potrebna e-pošta, telefonski broj ili pravo ime\n- Nema analitike, praćenja ili telemetrije\n- Nema identifikatora za oglašavanje\n- Nema pristupa popisu kontakata\n- Nema sigurnosnih kopija u oblaku (poruke postoje samo na vašem uređaju)\n- Nikakvi metapodaci se ne šalju na bilo koji Pulse poslužitelj (ne postoje)';

  @override
  String get privacyEncryptionHeading => 'Šifriranje';

  @override
  String get privacyEncryptionBody =>
      'Sve poruke su šifrirane Signal protokolom (Double Ratchet s X3DH dogovorom ključeva). Ključevi za šifriranje se generiraju i pohranjuju isključivo na vašem uređaju. Nitko — uključujući razvojne programere — ne može čitati vaše poruke.';

  @override
  String get privacyNetworkHeading => 'Mrežna arhitektura';

  @override
  String get privacyNetworkBody =>
      'Pulse koristi federalizirane transportne adaptere (Nostr relayi, Session/Oxen servisni čvorovi, Firebase Realtime Database, LAN). Ti transporti prenose samo šifrirani tekst. Operatori relaya mogu vidjeti vašu IP adresu i obujam prometa, ali ne mogu dešifrirati sadržaj poruka.\n\nKad je Tor omogućen, vaša IP adresa je također skrivena od operatora relaya.';

  @override
  String get privacyStunHeading => 'STUN/TURN poslužitelji';

  @override
  String get privacyStunBody =>
      'Glasovni i videopozivi koriste WebRTC s DTLS-SRTP šifriranjem. STUN poslužitelji (za otkrivanje vaše javne IP za peer-to-peer veze) i TURN poslužitelji (za preusmjeravanje medija kad izravna veza ne uspije) mogu vidjeti vašu IP adresu i trajanje poziva, ali ne mogu dešifrirati sadržaj poziva.\n\nMožete konfigurirati vlastiti TURN poslužitelj u Postavkama za maksimalnu privatnost.';

  @override
  String get privacyCrashHeading => 'Izvješćivanje o rušenjima';

  @override
  String get privacyCrashBody =>
      'Ako je Sentry izvješćivanje o rušenjima omogućeno (putem SENTRY_DSN u vrijeme izgradnje), mogu se slati anonimna izvješća o rušenjima. Ona ne sadrže sadržaj poruka, podatke o kontaktima niti osobno identificirajuće informacije. Izvješćivanje o rušenjima se može onemogućiti u vrijeme izgradnje izostavljanjem DSN.';

  @override
  String get privacyPasswordHeading => 'Lozinka i ključevi';

  @override
  String get privacyPasswordBody =>
      'Vaša lozinka za oporavak koristi se za izvođenje kriptografskih ključeva putem Argon2id (memorijski zahtjevna KDF). Lozinka se nikad nigdje ne prenosi. Ako izgubite lozinku, vaš račun se ne može oporaviti — nema poslužitelja za njeno ponovni postavljanje.';

  @override
  String get privacyFontsHeading => 'Fontovi';

  @override
  String get privacyFontsBody =>
      'Pulse sadrži sve fontove lokalno. Ne šalju se zahtjevi prema Google Fonts ili bilo kojem vanjskom servisu za fontove.';

  @override
  String get privacyThirdPartyHeading => 'Usluge trećih strana';

  @override
  String get privacyThirdPartyBody =>
      'Pulse se ne integrira s nijednom mrežom za oglašavanje, pružateljima analitike, platformama društvenih medija niti posrednicima podataka. Jedine mrežne veze su prema transportnim relayima koje konfigurirate.';

  @override
  String get privacyOpenSourceHeading => 'Otvoreni kod';

  @override
  String get privacyOpenSourceBody =>
      'Pulse je softver otvorenog koda. Možete pregledati kompletan izvorni kod kako biste potvrdili ove izjave o privatnosti.';

  @override
  String get privacyContactHeading => 'Kontakt';

  @override
  String get privacyContactBody =>
      'Za pitanja vezana uz privatnost, otvorite zahtjev u repozitoriju projekta.';

  @override
  String get privacyLastUpdated => 'Zadnje ažuriranje: ožujak 2026.';

  @override
  String imageSaveFailed(Object error) {
    return 'Spremanje neuspješno: $error';
  }

  @override
  String get themeEngineTitle => 'Pokretač tema';

  @override
  String get torBuiltInTitle => 'Ugrađeni Tor';

  @override
  String get torConnectedSubtitle =>
      'Povezano — Nostr usmjeren putem 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Povezivanje… $pct%';
  }

  @override
  String get torNotRunning => 'Nije aktivno — dodirnite prekidač za pokretanje';

  @override
  String get torDescription =>
      'Usmjerava Nostr putem Tor (Snowflake za censurirane mreže)';

  @override
  String get torNetworkDiagnostics => 'Dijagnostika mreže';

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
  String get torPtPlain => 'Obično';

  @override
  String get torTimeoutLabel => 'Vremensko ograničenje: ';

  @override
  String get torInfoDescription =>
      'Kad je omogućeno, Nostr WebSocket veze se usmjeravaju putem Tor (SOCKS5). Tor Browser sluša na 127.0.0.1:9150. Samostalni tor daemon koristi port 9050. Firebase veze nisu pogođene.';

  @override
  String get torRouteNostrTitle => 'Usmjeri Nostr putem Tor';

  @override
  String get torManagedByBuiltin => 'Upravljano ugrađenim Tor';

  @override
  String get torActiveRouting =>
      'Aktivno — Nostr promet se usmjerava putem Tor';

  @override
  String get torDisabled => 'Onemogućeno';

  @override
  String get torProxySocks5 => 'Tor Proxy (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Proxy host';

  @override
  String get torProxyPortLabel => 'Port';

  @override
  String get torPortInfo => 'Tor Browser: port 9150  •  tor daemon: port 9050';

  @override
  String get i2pProxySocks5 => 'I2P Proxy (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P koristi SOCKS5 na portu 4447 prema zadanim postavkama. Povežite se na Nostr relay putem I2P outproxyja (npr. relay.damus.i2p) za komunikaciju s korisnicima na bilo kojem transportu. Tor ima prednost kad su oba omogućena.';

  @override
  String get i2pRouteNostrTitle => 'Usmjeri Nostr putem I2P';

  @override
  String get i2pActiveRouting =>
      'Aktivno — Nostr promet se usmjerava putem I2P';

  @override
  String get i2pDisabled => 'Onemogućeno';

  @override
  String get i2pProxyHostLabel => 'Proxy host';

  @override
  String get i2pProxyPortLabel => 'Port';

  @override
  String get i2pPortInfo => 'I2P Router zadani SOCKS5 port: 4447';

  @override
  String get customProxySocks5 => 'Prilagođeni Proxy (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Prilagođeni proxy usmjerava promet putem vašeg V2Ray/Xray/Shadowsocks. CF Worker djeluje kao osobni relay proxy na Cloudflare CDN — GFW vidi *.workers.dev, ne pravi relay.';

  @override
  String get customSocks5ProxyTitle => 'Prilagođeni SOCKS5 Proxy';

  @override
  String get customProxyActive => 'Aktivno — promet se usmjerava putem SOCKS5';

  @override
  String get customProxyDisabled => 'Onemogućeno';

  @override
  String get customProxyHostLabel => 'Proxy host';

  @override
  String get customProxyPortLabel => 'Port';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker domena (opcionalno)';

  @override
  String get customWorkerHelpTitle =>
      'Kako postaviti CF Worker relay (besplatno)';

  @override
  String get customWorkerScriptCopied => 'Skripta kopirana!';

  @override
  String get customWorkerStep1 =>
      '1. Idite na dash.cloudflare.com → Workers & Pages\n2. Create Worker → zalijepite ovu skriptu:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → kopirajte domenu (npr. my-relay.user.workers.dev)\n4. Zalijepite domenu gore → Spremi\n\nAplikacija se automatski povezuje: wss://domain/?r=relay_url\nGFW vidi: vezu na *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Povezano — SOCKS5 na 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Povezivanje…';

  @override
  String get psiphonNotRunning =>
      'Nije aktivno — dodirnite prekidač za pokretanje';

  @override
  String get psiphonDescription =>
      'Brzi tunel (~3s pokretanje, 2000+ rotirajućih VPS)';

  @override
  String get turnCommunityServers => 'Zajednički TURN poslužitelji';

  @override
  String get turnCustomServer => 'Prilagođeni TURN poslužitelj (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN poslužitelji samo preusmjeravaju već šifrirane tokove (DTLS-SRTP). Operator relaya vidi vašu IP i obujam prometa, ali ne može dešifrirati pozive. TURN se koristi samo kad izravni P2P ne uspije (~15–20% veza).';

  @override
  String get turnFreeLabel => 'BESPLATNO';

  @override
  String get turnServerUrlLabel => 'URL TURN poslužitelja';

  @override
  String get turnServerUrlHint => 'turn:vaš-poslužitelj.com:3478 ili turns:...';

  @override
  String get turnUsernameLabel => 'Korisničko ime';

  @override
  String get turnPasswordLabel => 'Lozinka';

  @override
  String get turnOptionalHint => 'Opcionalno';

  @override
  String get turnCustomInfo =>
      'Pokrenite coturn na bilo kojem VPS za 5\$/mj za maksimalnu kontrolu. Vjerodajnice se pohranjuju lokalno.';

  @override
  String get themePickerAppearance => 'Izgled';

  @override
  String get themePickerAccentColor => 'Boja akcenta';

  @override
  String get themeModeLight => 'Svijetlo';

  @override
  String get themeModeDark => 'Tamno';

  @override
  String get themeModeSystem => 'Sustav';

  @override
  String get themeDynamicPresets => 'Predlošci';

  @override
  String get themeDynamicPrimaryColor => 'Primarna boja';

  @override
  String get themeDynamicBorderRadius => 'Radijus obruba';

  @override
  String get themeDynamicFont => 'Font';

  @override
  String get themeDynamicAppearance => 'Izgled';

  @override
  String get themeDynamicUiStyle => 'UI stil';

  @override
  String get themeDynamicUiStyleDescription =>
      'Kontrolira izgled dijaloga, prekidača i indikatora.';

  @override
  String get themeDynamicSharp => 'Oštro';

  @override
  String get themeDynamicRound => 'Zaobljeno';

  @override
  String get themeDynamicModeDark => 'Tamno';

  @override
  String get themeDynamicModeLight => 'Svijetlo';

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
      'Neispravna Firebase URL. Očekivano: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Neispravna URL relaya. Očekivano: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Neispravna URL Pulse poslužitelja. Očekivano: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'URL poslužitelja';

  @override
  String get providerPulseServerUrlHint => 'https://vaš-poslužitelj:8443';

  @override
  String get providerPulseInviteLabel => 'Pozivni kod';

  @override
  String get providerPulseInviteHint => 'Pozivni kod (ako je potreban)';

  @override
  String get providerPulseInfo =>
      'Vlastiti relay. Ključevi izvedeni iz vaše lozinke za oporavak.';

  @override
  String get providerScreenTitle => 'Sandučići';

  @override
  String get providerSecondaryInboxesHeader => 'SEKUNDARNI SANDUČIĆI';

  @override
  String get providerSecondaryInboxesInfo =>
      'Sekundarni sandučići primaju poruke istovremeno za redundanciju.';

  @override
  String get providerRemoveTooltip => 'Ukloni';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... ili hex';

  @override
  String get providerNostrPrivkeyHintFull => 'nsec1... ili hex privatni ključ';

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
  String get emojiNoRecent => 'Nema nedavnih emojija';

  @override
  String get emojiSearchHint => 'Pretraži emojije...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Dodirnite za razgovor';

  @override
  String get imageViewerSaveToDownloads => 'Spremi u Preuzimanja';

  @override
  String imageViewerSavedTo(String path) {
    return 'Spremljeno u $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Jezik';

  @override
  String get settingsLanguageSubtitle => 'Jezik prikaza aplikacije';

  @override
  String get settingsLanguageSystem => 'Zadano sustava';

  @override
  String get onboardingLanguageTitle => 'Odaberite svoj jezik';

  @override
  String get onboardingLanguageSubtitle =>
      'Ovo možete promijeniti kasnije u Postavkama';

  @override
  String get videoNoteRecord => 'Snimi video poruku';

  @override
  String get videoNoteTapToRecord => 'Dodirnite za snimanje';

  @override
  String get videoNoteTapToStop => 'Dodirnite za zaustavljanje';

  @override
  String get videoNoteCameraPermission => 'Pristup kameri odbijen';

  @override
  String get videoNoteMaxDuration => 'Maksimalno 30 sekundi';

  @override
  String get videoNoteNotSupported =>
      'Video bilješke nisu podržane na ovoj platformi';

  @override
  String get navChats => 'Chats';

  @override
  String get navUpdates => 'Updates';

  @override
  String get navCalls => 'Calls';

  @override
  String get filterAll => 'All';

  @override
  String get filterUnread => 'Unread';

  @override
  String get filterGroups => 'Groups';

  @override
  String get callsNoRecent => 'No recent calls';

  @override
  String get callsEmptySubtitle => 'Your call history will appear here';

  @override
  String get appBarEncrypted => 'end-to-end encrypted';

  @override
  String get newStatus => 'New status';

  @override
  String get newCall => 'New call';
}
