// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Lithuanian (`lt`).
class AppLocalizationsLt extends AppLocalizations {
  AppLocalizationsLt([String locale = 'lt']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Ieškoti žinučių...';

  @override
  String get search => 'Ieškoti';

  @override
  String get clearSearch => 'Išvalyti paiešką';

  @override
  String get closeSearch => 'Uždaryti paiešką';

  @override
  String get moreOptions => 'Daugiau parinkčių';

  @override
  String get back => 'Atgal';

  @override
  String get cancel => 'Atšaukti';

  @override
  String get close => 'Uždaryti';

  @override
  String get confirm => 'Patvirtinti';

  @override
  String get remove => 'Pašalinti';

  @override
  String get save => 'Išsaugoti';

  @override
  String get add => 'Pridėti';

  @override
  String get copy => 'Kopijuoti';

  @override
  String get skip => 'Praleisti';

  @override
  String get done => 'Atlikta';

  @override
  String get apply => 'Taikyti';

  @override
  String get export => 'Eksportuoti';

  @override
  String get import => 'Importuoti';

  @override
  String get homeNewGroup => 'Nauja grupė';

  @override
  String get homeSettings => 'Nustatymai';

  @override
  String get homeSearching => 'Ieškoma žinučių...';

  @override
  String get homeNoResults => 'Rezultatų nerasta';

  @override
  String get homeNoChatHistory => 'Pokalbių istorijos dar nėra';

  @override
  String homeTransportSwitched(String address) {
    return 'Transportas perjungtas → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name skambina...';
  }

  @override
  String get homeAccept => 'Priimti';

  @override
  String get homeDecline => 'Atmesti';

  @override
  String get homeLoadEarlier => 'Įkelti ankstesnes žinutes';

  @override
  String get homeChats => 'Pokalbiai';

  @override
  String get homeSelectConversation => 'Pasirinkite pokalbį';

  @override
  String get homeNoChatsYet => 'Pokalbių dar nėra';

  @override
  String get homeAddContactToStart =>
      'Pridėkite kontaktą, kad pradėtumėte bendrauti';

  @override
  String get homeNewChat => 'Naujas pokalbis';

  @override
  String get homeNewChatTooltip => 'Naujas pokalbis';

  @override
  String get homeIncomingCallTitle => 'Įeinantis skambutis';

  @override
  String get homeIncomingGroupCallTitle => 'Įeinantis grupinis skambutis';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — įeinantis grupinis skambutis';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Pokalbių, atitinkančių \"$query\", nerasta';
  }

  @override
  String get homeSectionChats => 'Pokalbiai';

  @override
  String get homeSectionMessages => 'Žinutės';

  @override
  String get homeDbEncryptionUnavailable =>
      'Duomenų bazės šifravimas neprieinamas — įdiekite SQLCipher pilnai apsaugai';

  @override
  String get chatFileTooLargeGroup =>
      'Failai didesni nei 512 KB nėra palaikomi grupiniuose pokalbiuose';

  @override
  String get chatLargeFile => 'Didelis failas';

  @override
  String get chatCancel => 'Atšaukti';

  @override
  String get chatSend => 'Siųsti';

  @override
  String get chatFileTooLarge =>
      'Failas per didelis — didžiausias dydis yra 100 MB';

  @override
  String get chatMicDenied => 'Mikrofono leidimas atmestas';

  @override
  String get chatVoiceFailed =>
      'Nepavyko išsaugoti balso žinutės — patikrinkite laisvą vietą';

  @override
  String get chatScheduleFuture => 'Suplanuotas laikas turi būti ateityje';

  @override
  String get chatToday => 'Šiandien';

  @override
  String get chatYesterday => 'Vakar';

  @override
  String get chatEdited => 'redaguota';

  @override
  String get chatYou => 'Jūs';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Šis failas yra $size MB. Didelių failų siuntimas kai kuriuose tinkluose gali būti lėtas. Tęsti?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return '$name saugumo raktas pasikeitė. Bakstelėkite, kad patikrintumėte.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Nepavyko užšifruoti žinutės gavėjui $name — žinutė neišsiųsta.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Saugumo numeris pasikeitė kontaktui $name. Bakstelėkite, kad patikrintumėte.';
  }

  @override
  String get chatNoMessagesFound => 'Žinučių nerasta';

  @override
  String get chatMessagesE2ee => 'Žinutės yra ištisai užšifruotos';

  @override
  String get chatSayHello => 'Pasakykite „sveiki“';

  @override
  String get appBarOnline => 'prisijungęs';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'rašo';

  @override
  String get appBarSearchMessages => 'Ieškoti žinučių...';

  @override
  String get appBarMute => 'Nutildyti';

  @override
  String get appBarUnmute => 'Įjungti garsą';

  @override
  String get appBarMedia => 'Medija';

  @override
  String get appBarDisappearing => 'Nykstančios žinutės';

  @override
  String get appBarDisappearingOn => 'Nykstančios: įjungta';

  @override
  String get appBarGroupSettings => 'Grupės nustatymai';

  @override
  String get appBarSearchTooltip => 'Ieškoti žinučių';

  @override
  String get appBarVoiceCall => 'Balso skambutis';

  @override
  String get appBarVideoCall => 'Vaizdo skambutis';

  @override
  String get inputMessage => 'Žinutė...';

  @override
  String get inputAttachFile => 'Pridėti failą';

  @override
  String get inputSendMessage => 'Siųsti žinutę';

  @override
  String get inputRecordVoice => 'Įrašyti balso žinutę';

  @override
  String get inputSendVoice => 'Siųsti balso žinutę';

  @override
  String get inputCancelReply => 'Atšaukti atsakymą';

  @override
  String get inputCancelEdit => 'Atšaukti redagavimą';

  @override
  String get inputCancelRecording => 'Atšaukti įrašymą';

  @override
  String get inputRecording => 'Įrašoma…';

  @override
  String get inputEditingMessage => 'Žinutė redaguojama';

  @override
  String get inputPhoto => 'Nuotrauka';

  @override
  String get inputVoiceMessage => 'Balso žinutė';

  @override
  String get inputFile => 'Failas';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suplanuotų žinučių',
      few: '$count suplanuotos žinutės',
      one: '1 suplanuota žinutė',
    );
    return '$_temp0';
  }

  @override
  String get callInitializing => 'Skambutis inicializuojamas…';

  @override
  String get callConnecting => 'Jungiamasi…';

  @override
  String get callConnectingRelay => 'Jungiamasi (relay)…';

  @override
  String get callSwitchingRelay => 'Perjungiama į relay režimą…';

  @override
  String get callConnectionFailed => 'Ryšys nepavyko';

  @override
  String get callReconnecting => 'Jungiamasi iš naujo…';

  @override
  String get callEnded => 'Skambutis baigtas';

  @override
  String get callLive => 'Gyvas';

  @override
  String get callEnd => 'Baigti';

  @override
  String get callEndCall => 'Baigti skambutį';

  @override
  String get callMute => 'Nutildyti';

  @override
  String get callUnmute => 'Įjungti garsą';

  @override
  String get callSpeaker => 'Garsiakalbis';

  @override
  String get callCameraOn => 'Kamera įjungta';

  @override
  String get callCameraOff => 'Kamera išjungta';

  @override
  String get callShareScreen => 'Bendrinti ekraną';

  @override
  String get callStopShare => 'Sustabdyti bendrinimą';

  @override
  String callTorBackup(String duration) {
    return 'Tor atsarginė kopija · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor atsarginė kopija aktyvi — pagrindinis kelias neprieinamas';

  @override
  String get callDirectFailed =>
      'Tiesioginis ryšys nepavyko — perjungiama į relay režimą…';

  @override
  String get callTurnUnreachable =>
      'TURN serveriai nepasiekiami. Pridėkite pasirinktinį TURN Nustatymai → Išplėstiniai.';

  @override
  String get callRelayMode => 'Relay režimas aktyvus (apribotas tinklas)';

  @override
  String get callStarting => 'Skambutis pradedamas…';

  @override
  String get callConnectingToGroup => 'Jungiamasi prie grupės…';

  @override
  String get callGroupOpenedInBrowser =>
      'Grupinis skambutis atidarytas naršyklėje';

  @override
  String get callCouldNotOpenBrowser => 'Nepavyko atidaryti naršyklės';

  @override
  String get callInviteLinkSent =>
      'Kvietimo nuoroda išsiųsta visiems grupės nariams.';

  @override
  String get callOpenLinkManually =>
      'Atidarykite aukščiau esančią nuorodą rankiniu būdu arba bakstelėkite, kad bandytumėte iš naujo.';

  @override
  String get callJitsiNotE2ee => 'Jitsi skambučiai NĖRA ištisai užšifruoti';

  @override
  String get callRetryOpenBrowser => 'Bandyti atidaryti naršyklę iš naujo';

  @override
  String get callClose => 'Uždaryti';

  @override
  String get callCamOn => 'Kamera įjungta';

  @override
  String get callCamOff => 'Kamera išjungta';

  @override
  String get noConnection => 'Nėra ryšio — žinutės bus eilėje';

  @override
  String get connected => 'Prisijungta';

  @override
  String get connecting => 'Jungiamasi…';

  @override
  String get disconnected => 'Atjungta';

  @override
  String get offlineBanner =>
      'Nėra ryšio — žinutės bus išsiųstos, kai vėl prisijungsite';

  @override
  String get lanModeBanner =>
      'LAN režimas — Nėra interneto · Tik vietinis tinklas';

  @override
  String get probeCheckingNetwork => 'Tikrinamas tinklo ryšys…';

  @override
  String get probeDiscoveringRelays =>
      'Ieškoma relay per bendruomenės katalogus…';

  @override
  String get probeStartingTor => 'Paleidžiamas Tor…';

  @override
  String get probeFindingRelaysTor => 'Ieškoma pasiekiamų relay per Tor…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'rasta $count relay',
      few: 'rasti $count relay',
      one: 'rastas 1 relay',
    );
    return 'Tinklas paruoštas — $_temp0';
  }

  @override
  String get probeNoRelaysFound =>
      'Pasiekiamų relay nerasta — žinutės gali vėluoti';

  @override
  String get jitsiWarningTitle => 'Ne ištisai užšifruota';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet skambučiai nėra šifruojami Pulse. Naudokite tik nekonfidencialiems pokalbiams.';

  @override
  String get jitsiConfirm => 'Prisijungti vis tiek';

  @override
  String get jitsiGroupWarningTitle => 'Ne ištisai užšifruota';

  @override
  String get jitsiGroupWarningBody =>
      'Šiame skambutyje per daug dalyvių įtaisytajam šifruotam tinklui.\n\nJitsi Meet nuoroda bus atidaryta jūsų naršyklėje. Jitsi NĖRA ištisai užšifruotas — serveris gali matyti jūsų skambutį.';

  @override
  String get jitsiContinueAnyway => 'Tęsti vis tiek';

  @override
  String get retry => 'Bandyti iš naujo';

  @override
  String get setupCreateAnonymousAccount => 'Sukurti anonimišką paskyrą';

  @override
  String get setupTapToChangeColor => 'Bakstelėkite, kad pakeistumėte spalvą';

  @override
  String get setupReqMinLength => 'At least 16 characters';

  @override
  String get setupReqVariety => '3 of 4: uppercase, lowercase, digits, symbols';

  @override
  String get setupReqMatch => 'Passwords match';

  @override
  String get setupYourNickname => 'Jūsų slapyvardis';

  @override
  String get setupRecoveryPassword => 'Atkūrimo slaptažodis (min. 16)';

  @override
  String get setupConfirmPassword => 'Patvirtinkite slaptažodį';

  @override
  String get setupMin16Chars => 'Mažiausiai 16 simbolių';

  @override
  String get setupPasswordsDoNotMatch => 'Slaptažodžiai nesutampa';

  @override
  String get setupEntropyWeak => 'Silpnas';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Stiprus';

  @override
  String get setupEntropyWeakNeedsVariety => 'Silpnas (reikia 3 simbolių tipų)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bitai)';
  }

  @override
  String get setupPasswordWarning =>
      'Šis slaptažodis yra vienintelis būdas atkurti jūsų paskyrą. Nėra jokio serverio — jokio slaptažodžio atstatymo. Įsiminkite jį arba užsirašykite.';

  @override
  String get setupCreateAccount => 'Sukurti paskyrą';

  @override
  String get setupAlreadyHaveAccount => 'Jau turite paskyrą? ';

  @override
  String get setupRestore => 'Atkurti →';

  @override
  String get restoreTitle => 'Atkurti paskyrą';

  @override
  String get restoreInfoBanner =>
      'Įveskite savo atkūrimo slaptažodį — jūsų adresas (Nostr + Session) bus atkurtas automatiškai. Kontaktai ir žinutės buvo saugomi tik vietinėje.';

  @override
  String get restoreNewNickname =>
      'Naujas slapyvardis (galima pakeisti vėliau)';

  @override
  String get restoreButton => 'Atkurti paskyrą';

  @override
  String get lockTitle => 'Pulse yra užrakinta';

  @override
  String get lockSubtitle => 'Įveskite slaptažodį, kad tęstumėte';

  @override
  String get lockPasswordHint => 'Slaptažodis';

  @override
  String get lockUnlock => 'Atrakinti';

  @override
  String get lockPanicHint =>
      'Pamiršote slaptažodį? Įveskite panikos raktą, kad ištrintumėte visus duomenis.';

  @override
  String get lockTooManyAttempts => 'Per daug bandymų. Trinami visi duomenys…';

  @override
  String get lockWrongPassword => 'Neteisingas slaptažodis';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Neteisingas slaptažodis — $attempts/$max bandymai';
  }

  @override
  String get onboardingSkip => 'Praleisti';

  @override
  String get onboardingNext => 'Toliau';

  @override
  String get onboardingGetStarted => 'Pradėti';

  @override
  String get onboardingWelcomeTitle => 'Sveiki atvykę į Pulse';

  @override
  String get onboardingWelcomeBody =>
      'Decentralizuotas, ištisai užšifruotas žinučių siuntimo programa.\n\nJokių centrinių serverių. Jokio duomenų rinkimo. Jokių galinių durų.\nJūsų pokalbiai priklauso tik jums.';

  @override
  String get onboardingTransportTitle => 'Transporto agnostinis';

  @override
  String get onboardingTransportBody =>
      'Naudokite Firebase, Nostr arba abu vienu metu.\n\nŽinutės automatiškai nukreipiamos per tinklus. Įtaisyta Tor ir I2P palaikymas cenzūros atsparumui.';

  @override
  String get onboardingSignalTitle => 'Signal + Post-Quantum';

  @override
  String get onboardingSignalBody =>
      'Kiekviena žinutė užšifruota Signal protokolu (Double Ratchet + X3DH) siekiant persiunčiamo slaptumo.\n\nPapildomai apgaubta Kyber-1024 — NIST standartizuotu post-kvantiniu algoritmu — apsaugai nuo ateities kvantinių kompiuterių.';

  @override
  String get onboardingKeysTitle => 'Jūsų raktai priklauso jums';

  @override
  String get onboardingKeysBody =>
      'Jūsų tapatybės raktai niekada nepalieka jūsų įrenginio.\n\nSignal pirštų atspaudai leidžia patikrinti kontaktus ne per tinklą. TOFU (Trust On First Use) automatiškai aptinka raktų pasikeitimus.';

  @override
  String get onboardingThemeTitle => 'Pasirinkite savo stilių';

  @override
  String get onboardingThemeBody =>
      'Pasirinkite temą ir akcentinę spalvą. Visada galite tai pakeisti vėliau Nustatymuose.';

  @override
  String get contactsNewChat => 'Naujas pokalbis';

  @override
  String get contactsAddContact => 'Pridėti kontaktą';

  @override
  String get contactsSearchHint => 'Ieškoti...';

  @override
  String get contactsNewGroup => 'Nauja grupė';

  @override
  String get contactsNoContactsYet => 'Kontaktų dar nėra';

  @override
  String get contactsAddHint => 'Bakstelėkite +, kad pridėtumėte adresą';

  @override
  String get contactsNoMatch => 'Nėra atitinkančių kontaktų';

  @override
  String get contactsRemoveTitle => 'Pašalinti kontaktą';

  @override
  String contactsRemoveMessage(String name) {
    return 'Pašalinti $name?';
  }

  @override
  String get contactsRemove => 'Pašalinti';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kontaktų',
      few: '$count kontaktai',
      one: '1 kontaktas',
    );
    return '$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Atidaryti nuorodą';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Atidaryti šią URL naršyklėje?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Atidaryti';

  @override
  String get bubbleSecurityWarning => 'Saugumo įspėjimas';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" yra vykdomojo tipo failas. Išsaugojimas ir paleidimas gali pakenkti jūsų įrenginiui. Vis tiek išsaugoti?';
  }

  @override
  String get bubbleSaveAnyway => 'Vis tiek išsaugoti';

  @override
  String bubbleSavedTo(String path) {
    return 'Išsaugota į $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Išsaugoti nepavyko: $error';
  }

  @override
  String get bubbleNotEncrypted => 'NEUŽŠIFRUOTA';

  @override
  String get bubbleCorruptedImage => '[Sugadintas paveikslėlis]';

  @override
  String get bubbleReplyPhoto => 'Nuotrauka';

  @override
  String get bubbleReplyVoice => 'Balso žinutė';

  @override
  String get bubbleReplyVideo => 'Vaizdo žinutė';

  @override
  String bubbleReadBy(String names) {
    return 'Perskaitė $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return 'Perskaitė $count';
  }

  @override
  String get chatTileTapToStart => 'Bakstelėkite, kad pradėtumėte pokalbį';

  @override
  String get chatTileMessageSent => 'Žinutė išsiųsta';

  @override
  String get chatTileEncryptedMessage => 'Užšifruota žinutė';

  @override
  String chatTileYouPrefix(String text) {
    return 'Jūs: $text';
  }

  @override
  String get bannerEncryptedMessage => 'Užšifruota žinutė';

  @override
  String get groupNewGroup => 'Nauja grupė';

  @override
  String get groupGroupName => 'Grupės pavadinimas';

  @override
  String get groupSelectMembers => 'Pasirinkite narius (min. 2)';

  @override
  String get groupNoContactsYet =>
      'Kontaktų dar nėra. Pirmiausia pridėkite kontaktų.';

  @override
  String get groupCreate => 'Sukurti';

  @override
  String get groupLabel => 'Grupė';

  @override
  String get profileVerifyIdentity => 'Patikrinti tapatybę';

  @override
  String profileVerifyInstructions(String name) {
    return 'Palyginkite šiuos pirštų atspaudus su $name per balso skambutį arba asmeniškai. Jei abu reikšmės sutampa abiejuose įrenginiuose, bakstelėkite „Pažymėti kaip patikrintą“.';
  }

  @override
  String get profileTheirKey => 'Jų raktas';

  @override
  String get profileYourKey => 'Jūsų raktas';

  @override
  String get profileRemoveVerification => 'Pašalinti patvirtinimą';

  @override
  String get profileMarkAsVerified => 'Pažymėti kaip patikrintą';

  @override
  String get profileAddressCopied => 'Adresas nukopijuotas';

  @override
  String get profileNoContactsToAdd =>
      'Nėra kontaktų, kuriuos pridėti — visi jau yra nariai';

  @override
  String get profileAddMembers => 'Pridėti narius';

  @override
  String profileAddCount(int count) {
    return 'Pridėti ($count)';
  }

  @override
  String get profileRenameGroup => 'Pervadinti grupę';

  @override
  String get profileRename => 'Pervadinti';

  @override
  String get profileRemoveMember => 'Pašalinti narį?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Pašalinti $name iš šios grupės?';
  }

  @override
  String get profileKick => 'Pašalinti';

  @override
  String get profileSignalFingerprints => 'Signal pirštų atspaudai';

  @override
  String get profileVerified => 'PATIKRINTA';

  @override
  String get profileVerify => 'Patikrinti';

  @override
  String get profileEdit => 'Redaguoti';

  @override
  String get profileNoSession =>
      'Sesija dar nesukurta — pirmiausia išsiųskite žinutę.';

  @override
  String get profileFingerprintCopied => 'Pirštų atspaudas nukopijuotas';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count narių',
      few: '$count nariai',
      one: '1 narys',
    );
    return '$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Patikrinti saugumo numerį';

  @override
  String get profileShowContactQr => 'Rodyti kontakto QR';

  @override
  String profileContactAddress(String name) {
    return '$name adresas';
  }

  @override
  String get profileExportChatHistory => 'Eksportuoti pokalbių istoriją';

  @override
  String profileSavedTo(String path) {
    return 'Išsaugota į $path';
  }

  @override
  String get profileExportFailed => 'Eksportas nepavyko';

  @override
  String get profileClearChatHistory => 'Išvalyti pokalbių istoriją';

  @override
  String get profileDeleteGroup => 'Ištrinti grupę';

  @override
  String get profileDeleteContact => 'Ištrinti kontaktą';

  @override
  String get profileLeaveGroup => 'Palikti grupę';

  @override
  String get profileLeaveGroupBody =>
      'Būsite pašalinti iš šios grupės ir ji bus ištrinta iš jūsų kontaktų.';

  @override
  String get groupInviteTitle => 'Grupės kvietimas';

  @override
  String groupInviteBody(String from, String group) {
    return '$from pakvietė jus prisijungti prie \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Priimti';

  @override
  String get groupInviteDecline => 'Atmesti';

  @override
  String get groupMemberLimitTitle => 'Per daug dalyvių';

  @override
  String groupMemberLimitBody(int count) {
    return 'Šioje grupėje bus $count dalyvių. Šifruoti tinkliniai skambučiai palaiko iki 6. Didesnėse grupėse naudojamas Jitsi (ne E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Vis tiek pridėti';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name atmetė kvietimą prisijungti prie \"$group\"';
  }

  @override
  String get transferTitle => 'Perkelti į kitą įrenginį';

  @override
  String get transferInfoBox =>
      'Perkelkite savo Signal tapatybę ir Nostr raktus į naują įrenginį.\nPokalbių sesijos NĖRA perkeliamos — persiunčiamas slaptumas išsaugomas.';

  @override
  String get transferSendFromThis => 'Siųsti iš šio įrenginio';

  @override
  String get transferSendSubtitle =>
      'Šis įrenginys turi raktus. Pasidalinkite kodu su nauju įrenginiu.';

  @override
  String get transferReceiveOnThis => 'Gauti šiame įrenginyje';

  @override
  String get transferReceiveSubtitle =>
      'Tai yra naujas įrenginys. Įveskite kodą iš senojo įrenginio.';

  @override
  String get transferChooseMethod => 'Pasirinkite perkėlimo metodą';

  @override
  String get transferLan => 'LAN (Tas pats tinklas)';

  @override
  String get transferLanSubtitle =>
      'Greitas ir tiesioginis. Abu įrenginiai turi būti tame pačiame Wi-Fi.';

  @override
  String get transferNostrRelay => 'Nostr Relay';

  @override
  String get transferNostrRelaySubtitle =>
      'Veikia per bet kurį tinklą naudojant esamą Nostr relay.';

  @override
  String get transferRelayUrl => 'Relay URL';

  @override
  String get transferEnterCode => 'Įveskite perkėlimo kodą';

  @override
  String get transferPasteCode => 'Įklijuokite LAN:... arba NOS:... kodą čia';

  @override
  String get transferConnect => 'Prisijungti';

  @override
  String get transferGenerating => 'Generuojamas perkėlimo kodas…';

  @override
  String get transferShareCode => 'Pasidalinkite šiuo kodu su gavėju:';

  @override
  String get transferCopyCode => 'Kopijuoti kodą';

  @override
  String get transferCodeCopied => 'Kodas nukopijuotas į iškarpinę';

  @override
  String get transferWaitingReceiver => 'Laukiama gavėjo prisijungimo…';

  @override
  String get transferConnectingSender => 'Jungiamasi prie siuntėjo…';

  @override
  String get transferVerifyBoth =>
      'Palyginkite šį kodą abiejuose įrenginiuose.\nJei jie sutampa, perkėlimas yra saugus.';

  @override
  String get transferComplete => 'Perkėlimas baigtas';

  @override
  String get transferKeysImported => 'Raktai importuoti';

  @override
  String get transferCompleteSenderBody =>
      'Jūsų raktai lieka aktyvūs šiame įrenginyje.\nGavėjas dabar gali naudoti jūsų tapatybę.';

  @override
  String get transferCompleteReceiverBody =>
      'Raktai sėkmingai importuoti.\nPaleiskite programą iš naujo, kad pritaikytumėte naują tapatybę.';

  @override
  String get transferRestartApp => 'Paleisti iš naujo';

  @override
  String get transferFailed => 'Perkėlimas nepavyko';

  @override
  String get transferTryAgain => 'Bandyti iš naujo';

  @override
  String get transferEnterRelayFirst => 'Pirmiausia įveskite relay URL';

  @override
  String get transferPasteCodeFromSender =>
      'Įklijuokite siuntėjo perkėlimo kodą';

  @override
  String get menuReply => 'Atsakyti';

  @override
  String get menuForward => 'Persiųsti';

  @override
  String get menuReact => 'Reaguoti';

  @override
  String get menuCopy => 'Kopijuoti';

  @override
  String get menuEdit => 'Redaguoti';

  @override
  String get menuRetry => 'Bandyti iš naujo';

  @override
  String get menuCancelScheduled => 'Atšaukti suplanuotą';

  @override
  String get menuDelete => 'Ištrinti';

  @override
  String get menuForwardTo => 'Persiųsti…';

  @override
  String menuForwardedTo(String name) {
    return 'Persiųsta kontaktui $name';
  }

  @override
  String get menuScheduledMessages => 'Suplanuotos žinutės';

  @override
  String get menuNoScheduledMessages => 'Suplanuotų žinučių nėra';

  @override
  String menuSendsOn(String date) {
    return 'Bus išsiųsta $date';
  }

  @override
  String get menuDisappearingMessages => 'Nykstančios žinutės';

  @override
  String get menuDisappearingSubtitle =>
      'Žinutės automatiškai ištrinamos po pasirinkto laiko.';

  @override
  String get menuTtlOff => 'Išjungta';

  @override
  String get menuTtl1h => '1 valanda';

  @override
  String get menuTtl24h => '24 valandos';

  @override
  String get menuTtl7d => '7 dienos';

  @override
  String get menuAttachPhoto => 'Nuotrauka';

  @override
  String get menuAttachFile => 'Failas';

  @override
  String get menuAttachVideo => 'Vaizdo įrašas';

  @override
  String get mediaTitle => 'Medija';

  @override
  String get mediaFileLabel => 'FAILAS';

  @override
  String mediaPhotosTab(int count) {
    return 'Nuotraukos ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Failai ($count)';
  }

  @override
  String get mediaNoPhotos => 'Nuotraukų dar nėra';

  @override
  String get mediaNoFiles => 'Failų dar nėra';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Išsaugota į Downloads/$name';
  }

  @override
  String get mediaFailedToSave => 'Nepavyko išsaugoti failo';

  @override
  String get statusNewStatus => 'Naujas statusas';

  @override
  String get statusPublish => 'Paskelbti';

  @override
  String get statusExpiresIn24h => 'Statusas baigia galioti po 24 valandų';

  @override
  String get statusWhatsOnYourMind => 'Apie ką galvojate?';

  @override
  String get statusPhotoAttached => 'Nuotrauka pridėta';

  @override
  String get statusAttachPhoto => 'Pridėti nuotrauką (neprivaloma)';

  @override
  String get statusEnterText => 'Įveskite tekstą savo statusui.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Nepavyko pasirinkti nuotraukos: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Nepavyko paskelbti: $error';
  }

  @override
  String get panicSetPanicKey => 'Nustatyti panikos raktą';

  @override
  String get panicEmergencySelfDestruct => 'Avarinis savaiminis sunaikinimas';

  @override
  String get panicIrreversible => 'Šis veiksmas yra negrįžtamas';

  @override
  String get panicWarningBody =>
      'Įvedus šį raktą užrakinimo ekrane, iš karto ištrinami VISI duomenys — žinutės, kontaktai, raktai, tapatybė. Naudokite kitokį raktą nei įprastą slaptažodį.';

  @override
  String get panicKeyHint => 'Panikos raktas';

  @override
  String get panicConfirmHint => 'Patvirtinkite panikos raktą';

  @override
  String get panicMinChars => 'Panikos raktas turi būti bent 8 simbolių';

  @override
  String get panicKeysDoNotMatch => 'Raktai nesutampa';

  @override
  String get panicSetFailed =>
      'Nepavyko išsaugoti panikos rakto — bandykite dar kartą';

  @override
  String get passwordSetAppPassword => 'Nustatyti programos slaptažodį';

  @override
  String get passwordProtectsMessages =>
      'Apsaugo jūsų žinutes ramybės būsenoje';

  @override
  String get passwordInfoBanner =>
      'Reikalingas kiekvieną kartą atidarius Pulse. Jei pamiršite, jūsų duomenų nebus įmanoma atkurti.';

  @override
  String get passwordHint => 'Slaptažodis';

  @override
  String get passwordConfirmHint => 'Patvirtinkite slaptažodį';

  @override
  String get passwordSetButton => 'Nustatyti slaptažodį';

  @override
  String get passwordSkipForNow => 'Praleisti kol kas';

  @override
  String get passwordMinChars => 'Slaptažodis turi būti bent 6 simbolių';

  @override
  String get passwordsDoNotMatch => 'Slaptažodžiai nesutampa';

  @override
  String get profileCardSaved => 'Profilis išsaugotas!';

  @override
  String get profileCardE2eeIdentity => 'E2EE tapatybė';

  @override
  String get profileCardDisplayName => 'Rodomas vardas';

  @override
  String get profileCardDisplayNameHint => 'pvz., Jonas Jonaitis';

  @override
  String get profileCardAbout => 'Apie';

  @override
  String get profileCardSaveProfile => 'Išsaugoti profilį';

  @override
  String get profileCardYourName => 'Jūsų vardas';

  @override
  String get profileCardAddressCopied => 'Adresas nukopijuotas!';

  @override
  String get profileCardInboxAddress => 'Jūsų gautųjų adresas';

  @override
  String get profileCardInboxAddresses => 'Jūsų gautųjų adresai';

  @override
  String get profileCardShareAllAddresses =>
      'Bendrinti visus adresus (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Pasidalinkite su kontaktais, kad jie galėtų jums parašyti.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Visi $count adresai nukopijuoti kaip viena nuoroda!';
  }

  @override
  String get settingsMyProfile => 'Mano profilis';

  @override
  String get settingsYourInboxAddress => 'Jūsų gautųjų adresas';

  @override
  String get settingsMyQrCode => 'Mano QR kodas';

  @override
  String get settingsMyQrSubtitle => 'Bendrinti adresą kaip nuskaitomą QR kodą';

  @override
  String get settingsShareMyAddress => 'Bendrinti mano adresą';

  @override
  String get settingsNoAddressYet =>
      'Adreso dar nėra — pirmiausia išsaugokite nustatymus';

  @override
  String get settingsInviteLink => 'Kvietimo nuoroda';

  @override
  String get settingsRawAddress => 'Neapdorotas adresas';

  @override
  String get settingsCopyLink => 'Kopijuoti nuorodą';

  @override
  String get settingsCopyAddress => 'Kopijuoti adresą';

  @override
  String get settingsInviteLinkCopied => 'Kvietimo nuoroda nukopijuota';

  @override
  String get settingsAppearance => 'Išvaizda';

  @override
  String get settingsThemeEngine => 'Temų variklis';

  @override
  String get settingsThemeEngineSubtitle => 'Tinkinti spalvas ir šriftus';

  @override
  String get settingsSignalProtocol => 'Signal protokolas';

  @override
  String get settingsSignalProtocolSubtitle => 'E2EE raktai saugomi saugiai';

  @override
  String get settingsActive => 'AKTYVUS';

  @override
  String get settingsIdentityBackup => 'Tapatybės atsarginė kopija';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Eksportuoti arba importuoti savo Signal tapatybę';

  @override
  String get settingsIdentityBackupBody =>
      'Eksportuokite savo Signal tapatybės raktus į atsarginį kodą arba atkurkite iš esamo.';

  @override
  String get settingsTransferDevice => 'Perkelti į kitą įrenginį';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Perkelti tapatybę per LAN arba Nostr relay';

  @override
  String get settingsExportIdentity => 'Eksportuoti tapatybę';

  @override
  String get settingsExportIdentityBody =>
      'Nukopijuokite šį atsarginį kodą ir saugokite jį saugiai:';

  @override
  String get settingsSaveFile => 'Išsaugoti failą';

  @override
  String get settingsImportIdentity => 'Importuoti tapatybę';

  @override
  String get settingsImportIdentityBody =>
      'Įklijuokite atsarginį kodą žemiau. Tai perrašys jūsų dabartinę tapatybę.';

  @override
  String get settingsPasteBackupCode => 'Įklijuokite atsarginį kodą čia…';

  @override
  String get settingsIdentityImported =>
      'Tapatybė + kontaktai importuoti! Paleiskite programą iš naujo, kad pritaikytumėte.';

  @override
  String get settingsSecurity => 'Saugumas';

  @override
  String get settingsAppPassword => 'Programos slaptažodis';

  @override
  String get settingsPasswordEnabled =>
      'Įjungtas — reikalingas kiekvieną paleidimą';

  @override
  String get settingsPasswordDisabled =>
      'Išjungtas — programa atidaroma be slaptažodžio';

  @override
  String get settingsChangePassword => 'Keisti slaptažodį';

  @override
  String get settingsChangePasswordSubtitle =>
      'Atnaujinti programos užrakinimo slaptažodį';

  @override
  String get settingsSetPanicKey => 'Nustatyti panikos raktą';

  @override
  String get settingsChangePanicKey => 'Keisti panikos raktą';

  @override
  String get settingsPanicKeySetSubtitle => 'Atnaujinti avarinį trynimo raktą';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Vienas raktas, kuris iš karto ištrina visus duomenis';

  @override
  String get settingsRemovePanicKey => 'Pašalinti panikos raktą';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Išjungti avarinį savaiminį sunaikinimą';

  @override
  String get settingsRemovePanicKeyBody =>
      'Avarinis savaiminis sunaikinimas bus išjungtas. Galite jį bet kada vėl įjungti.';

  @override
  String get settingsDisableAppPassword => 'Išjungti programos slaptažodį';

  @override
  String get settingsEnterCurrentPassword =>
      'Įveskite dabartinį slaptažodį, kad patvirtintumėte';

  @override
  String get settingsCurrentPassword => 'Dabartinis slaptažodis';

  @override
  String get settingsIncorrectPassword => 'Neteisingas slaptažodis';

  @override
  String get settingsPasswordUpdated => 'Slaptažodis atnaujintas';

  @override
  String get settingsChangePasswordProceed =>
      'Įveskite dabartinį slaptažodį, kad tęstumėte';

  @override
  String get settingsData => 'Duomenys';

  @override
  String get settingsBackupMessages => 'Atsarginė žinučių kopija';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Eksportuoti šifruotą žinučių istoriją į failą';

  @override
  String get settingsRestoreMessages => 'Atkurti žinutes';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Importuoti žinutes iš atsarginės kopijos failo';

  @override
  String get settingsExportKeys => 'Eksportuoti raktus';

  @override
  String get settingsExportKeysSubtitle =>
      'Išsaugoti tapatybės raktus į šifruotą failą';

  @override
  String get settingsImportKeys => 'Importuoti raktus';

  @override
  String get settingsImportKeysSubtitle =>
      'Atkurti tapatybės raktus iš eksportuoto failo';

  @override
  String get settingsBackupPassword => 'Atsarginės kopijos slaptažodis';

  @override
  String get settingsPasswordCannotBeEmpty => 'Slaptažodis negali būti tuščias';

  @override
  String get settingsPasswordMin4Chars =>
      'Slaptažodis turi būti bent 4 simbolių';

  @override
  String get settingsCallsTurn => 'Skambučiai ir TURN';

  @override
  String get settingsLocalNetwork => 'Vietinis tinklas';

  @override
  String get settingsCensorshipResistance => 'Atsparumas cenzūrai';

  @override
  String get settingsNetwork => 'Tinklas';

  @override
  String get settingsProxyTunnels => 'Proxy ir tuneliai';

  @override
  String get settingsTurnServers => 'TURN serveriai';

  @override
  String get settingsProviderTitle => 'Teikėjas';

  @override
  String get settingsLanFallback => 'LAN atsarginis režimas';

  @override
  String get settingsLanFallbackSubtitle =>
      'Skleisti buvimą ir pristatyti žinutes vietiniame tinkle, kai nėra interneto. Išjunkite nepatikimuose tinkluose (viešas Wi-Fi).';

  @override
  String get settingsBgDelivery => 'Fono pristatymas';

  @override
  String get settingsBgDeliverySubtitle =>
      'Toliau gauti žinutes, kai programa sumažinta. Rodo nuolatinį pranešimą.';

  @override
  String get settingsYourInboxProvider => 'Jūsų gautųjų teikėjas';

  @override
  String get settingsConnectionDetails => 'Ryšio informacija';

  @override
  String get settingsSaveAndConnect => 'Išsaugoti ir prisijungti';

  @override
  String get settingsSecondaryInboxes => 'Antriniai gautieji';

  @override
  String get settingsAddSecondaryInbox => 'Pridėti antrinį gautąjį';

  @override
  String get settingsAdvanced => 'Išplėstiniai';

  @override
  String get settingsDiscover => 'Atrasti';

  @override
  String get settingsAbout => 'Apie';

  @override
  String get settingsPrivacyPolicy => 'Privatumo politika';

  @override
  String get settingsPrivacyPolicySubtitle => 'Kaip Pulse saugo jūsų duomenis';

  @override
  String get settingsCrashReporting => 'Strigčių ataskaitos';

  @override
  String get settingsCrashReportingSubtitle =>
      'Siųsti anonimines strigčių ataskaitas, kad padėtumėte tobulinti Pulse. Joks žinučių turinys ar kontaktai niekada nesiunčiami.';

  @override
  String get settingsCrashReportingEnabled =>
      'Strigčių ataskaitos įjungtos — paleiskite programą iš naujo, kad pritaikytumėte';

  @override
  String get settingsCrashReportingDisabled =>
      'Strigčių ataskaitos išjungtos — paleiskite programą iš naujo, kad pritaikytumėte';

  @override
  String get settingsSensitiveOperation => 'Jautri operacija';

  @override
  String get settingsSensitiveOperationBody =>
      'Šie raktai yra jūsų tapatybė. Bet kas, turintis šį failą, gali apsimesti jumis. Saugokite jį saugiai ir ištrinkite po perkėlimo.';

  @override
  String get settingsIUnderstandContinue => 'Suprantu, tęsti';

  @override
  String get settingsReplaceIdentity => 'Pakeisti tapatybę?';

  @override
  String get settingsReplaceIdentityBody =>
      'Tai perrašys jūsų dabartinius tapatybės raktus. Jūsų esamos Signal sesijos bus anuliuotos ir kontaktai turės iš naujo sukurti šifravimą. Programą reikės paleisti iš naujo.';

  @override
  String get settingsReplaceKeys => 'Pakeisti raktus';

  @override
  String get settingsKeysImported => 'Raktai importuoti';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count raktai sėkmingai importuoti. Paleiskite programą iš naujo, kad inicializuotumėte su nauja tapatybe.';
  }

  @override
  String get settingsRestartNow => 'Paleisti iš naujo dabar';

  @override
  String get settingsLater => 'Vėliau';

  @override
  String get profileGroupLabel => 'Grupė';

  @override
  String get profileAddButton => 'Pridėti';

  @override
  String get profileKickButton => 'Pašalinti';

  @override
  String get dataSectionTitle => 'Duomenys';

  @override
  String get dataBackupMessages => 'Atsarginė žinučių kopija';

  @override
  String get dataBackupPasswordSubtitle =>
      'Pasirinkite slaptažodį, kad užšifruotumėte atsarginę kopiją.';

  @override
  String get dataBackupConfirmLabel => 'Sukurti atsarginę kopiją';

  @override
  String get dataCreatingBackup => 'Kuriama atsarginė kopija';

  @override
  String get dataBackupPreparing => 'Ruošiama...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Eksportuojama žinutė $done iš $total...';
  }

  @override
  String get dataBackupSavingFile => 'Išsaugomas failas...';

  @override
  String get dataSaveMessageBackupDialog =>
      'Išsaugoti žinučių atsarginę kopiją';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Atsarginė kopija išsaugota ($count žinučių)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Atsarginė kopija nepavyko — jokie duomenys neeksportuoti';

  @override
  String dataBackupFailedError(String error) {
    return 'Atsarginė kopija nepavyko: $error';
  }

  @override
  String get dataSelectMessageBackupDialog =>
      'Pasirinkti žinučių atsarginę kopiją';

  @override
  String get dataInvalidBackupFile =>
      'Netinkamas atsarginės kopijos failas (per mažas)';

  @override
  String get dataNotValidBackupFile =>
      'Tai nėra tinkamas Pulse atsarginės kopijos failas';

  @override
  String get dataRestoreMessages => 'Atkurti žinutes';

  @override
  String get dataRestorePasswordSubtitle =>
      'Įveskite slaptažodį, kuris buvo naudotas kuriant šią atsarginę kopiją.';

  @override
  String get dataRestoreConfirmLabel => 'Atkurti';

  @override
  String get dataRestoringMessages => 'Žinutės atkuriamos';

  @override
  String get dataRestoreDecrypting => 'Iššifruojama...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Importuojama žinutė $done iš $total...';
  }

  @override
  String get dataRestoreFailed =>
      'Atkūrimas nepavyko — neteisingas slaptažodis arba pažeistas failas';

  @override
  String dataRestoreSuccess(int count) {
    return 'Atkurta $count naujų žinučių';
  }

  @override
  String get dataRestoreNothingNew =>
      'Nėra naujų žinučių importavimui (visos jau egzistuoja)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Atkūrimas nepavyko: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Pasirinkti raktų eksportą';

  @override
  String get dataNotValidKeyFile =>
      'Tai nėra tinkamas Pulse raktų eksporto failas';

  @override
  String get dataExportKeys => 'Eksportuoti raktus';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Pasirinkite slaptažodį, kad užšifruotumėte raktų eksportą.';

  @override
  String get dataExportKeysConfirmLabel => 'Eksportuoti';

  @override
  String get dataExportingKeys => 'Raktai eksportuojami';

  @override
  String get dataExportingKeysStatus => 'Tapatybės raktai šifruojami...';

  @override
  String get dataSaveKeyExportDialog => 'Išsaugoti raktų eksportą';

  @override
  String dataKeysExportedTo(String path) {
    return 'Raktai eksportuoti į:\n$path';
  }

  @override
  String get dataExportFailed => 'Eksportas nepavyko — raktų nerasta';

  @override
  String dataExportFailedError(String error) {
    return 'Eksportas nepavyko: $error';
  }

  @override
  String get dataImportKeys => 'Importuoti raktus';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Įveskite slaptažodį, kuris buvo naudotas šifruojant šį raktų eksportą.';

  @override
  String get dataImportKeysConfirmLabel => 'Importuoti';

  @override
  String get dataImportingKeys => 'Raktai importuojami';

  @override
  String get dataImportingKeysStatus => 'Tapatybės raktai iššifruojami...';

  @override
  String get dataImportFailed =>
      'Importas nepavyko — neteisingas slaptažodis arba pažeistas failas';

  @override
  String dataImportFailedError(String error) {
    return 'Importas nepavyko: $error';
  }

  @override
  String get securitySectionTitle => 'Saugumas';

  @override
  String get securityIncorrectPassword => 'Neteisingas slaptažodis';

  @override
  String get securityPasswordUpdated => 'Slaptažodis atnaujintas';

  @override
  String get appearanceSectionTitle => 'Išvaizda';

  @override
  String appearanceExportFailed(String error) {
    return 'Eksportas nepavyko: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Išsaugota į $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Išsaugoti nepavyko: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Importas nepavyko: $error';
  }

  @override
  String get aboutSectionTitle => 'Apie';

  @override
  String get providerPublicKey => 'Viešasis raktas';

  @override
  String get providerRelay => 'Relay';

  @override
  String get providerAutoConfigured =>
      'Automatiškai sukonfigūruota iš jūsų atkūrimo slaptažodžio. Relay aptiktas automatiškai.';

  @override
  String get providerKeyStoredLocally =>
      'Jūsų raktas saugomas vietinėje saugioje saugykloje — niekada nesiunčiamas jokiam serveriui.';

  @override
  String get providerSessionInfo =>
      'Session Network — onion-routed E2EE. Your Session ID is auto-generated and stored securely. Nodes auto-discovered from built-in seed nodes.';

  @override
  String get providerAdvanced => 'Išplėstiniai';

  @override
  String get providerSaveAndConnect => 'Išsaugoti ir prisijungti';

  @override
  String get providerAddSecondaryInbox => 'Pridėti antrinį gautąjį';

  @override
  String get providerSecondaryInboxes => 'Antriniai gautieji';

  @override
  String get providerYourInboxProvider => 'Jūsų gautųjų teikėjas';

  @override
  String get providerConnectionDetails => 'Ryšio informacija';

  @override
  String get addContactTitle => 'Pridėti kontaktą';

  @override
  String get addContactInviteLinkLabel => 'Kvietimo nuoroda arba adresas';

  @override
  String get addContactTapToPaste =>
      'Bakstelėkite, kad įklijuotumėte kvietimo nuorodą';

  @override
  String get addContactPasteTooltip => 'Įklijuoti iš iškarpinės';

  @override
  String get addContactAddressDetected => 'Kontakto adresas aptiktas';

  @override
  String addContactRoutesDetected(int count) {
    return '$count maršrutai aptikti — SmartRouter pasirenka greičiausią';
  }

  @override
  String get addContactFetchingProfile => 'Gaunamas profilis…';

  @override
  String addContactProfileFound(String name) {
    return 'Rastas: $name';
  }

  @override
  String get addContactNoProfileFound => 'Profilis nerastas';

  @override
  String get addContactDisplayNameLabel => 'Rodomas vardas';

  @override
  String get addContactDisplayNameHint => 'Kaip norite juos vadinti?';

  @override
  String get addContactAddManually => 'Įvesti adresą rankiniu būdu';

  @override
  String get addContactButton => 'Pridėti kontaktą';

  @override
  String get networkDiagnosticsTitle => 'Tinklo diagnostika';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr relay';

  @override
  String get networkDiagnosticsDirect => 'Tiesioginis';

  @override
  String get networkDiagnosticsTorOnly => 'Tik Tor';

  @override
  String get networkDiagnosticsBest => 'Geriausias';

  @override
  String get networkDiagnosticsNone => 'nėra';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Būsena';

  @override
  String get networkDiagnosticsConnected => 'Prisijungta';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Jungiamasi $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Išjungta';

  @override
  String get networkDiagnosticsTransport => 'Transportas';

  @override
  String get networkDiagnosticsInfrastructure => 'Infrastruktūra';

  @override
  String get networkDiagnosticsSessionNodes => 'Session nodes';

  @override
  String get networkDiagnosticsTurnServers => 'TURN serveriai';

  @override
  String get networkDiagnosticsLastProbe => 'Paskutinis tikrinimas';

  @override
  String get networkDiagnosticsRunning => 'Vykdoma...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Vykdyti diagnostiką';

  @override
  String get networkDiagnosticsForceReprobe =>
      'Priverstinai pilnai pertikrinti';

  @override
  String get networkDiagnosticsJustNow => 'ką tik';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return 'prieš $minutes min.';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return 'prieš $hours val.';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return 'prieš $days d.';
  }

  @override
  String get homeNoEch => 'Nėra ECH';

  @override
  String get homeNoEchTooltip =>
      'uTLS proxy neprieinamas — ECH išjungtas.\nTLS pirštų atspaudas matomas DPI.';

  @override
  String get settingsTitle => 'Nustatymai';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Išsaugota ir prisijungta prie $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Įtaisytas Tor nepavyko paleisti';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon nepavyko paleisti';

  @override
  String get verifyTitle => 'Patikrinti saugumo numerį';

  @override
  String get verifyIdentityVerified => 'Tapatybė patikrinta';

  @override
  String get verifyNotYetVerified => 'Dar nepatikrinta';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Jūs patikrinote $name saugumo numerį.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Palyginkite šiuos numerius su $name asmeniškai arba per patikimą kanalą.';
  }

  @override
  String get verifyExplanation =>
      'Kiekvienas pokalbis turi unikalų saugumo numerį. Jei abu matote tuos pačius numerius savo įrenginiuose, jūsų ryšys yra ištisai patikrintas.';

  @override
  String verifyContactKey(String name) {
    return '$name raktas';
  }

  @override
  String get verifyYourKey => 'Jūsų raktas';

  @override
  String get verifyRemoveVerification => 'Pašalinti patvirtinimą';

  @override
  String get verifyMarkAsVerified => 'Pažymėti kaip patikrintą';

  @override
  String verifyAfterReinstall(String name) {
    return 'Jei $name iš naujo įdiegs programą, saugumo numeris pasikeis ir patvirtinimas bus automatiškai pašalintas.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Pažymėkite tapatybę kaip patikrintą tik po to, kai palyginsite numerius su $name per balso skambutį arba asmeniškai.';
  }

  @override
  String get verifyNoSession =>
      'Šifravimo sesija dar nesukurta. Pirmiausia išsiųskite žinutę, kad sugeneruotumėte saugumo numerius.';

  @override
  String get verifyNoKeyAvailable => 'Raktas neprieinamas';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label pirštų atspaudas nukopijuotas';
  }

  @override
  String get providerDatabaseUrlLabel => 'Duomenų bazės URL';

  @override
  String get providerOptionalHint => 'Neprivaloma';

  @override
  String get providerWebApiKeyLabel => 'Web API raktas';

  @override
  String get providerOptionalForPublicDb => 'Neprivaloma viešai duomenų bazei';

  @override
  String get providerRelayUrlLabel => 'Relay URL';

  @override
  String get providerPrivateKeyLabel => 'Privatus raktas';

  @override
  String get providerPrivateKeyNsecLabel => 'Privatus raktas (nsec)';

  @override
  String get providerStorageNodeLabel => 'Saugojimo mazgo URL (neprivaloma)';

  @override
  String get providerStorageNodeHint =>
      'Palikite tuščią, kad naudotumėte įtaisytus pradinius mazgus';

  @override
  String get transferInvalidCodeFormat =>
      'Neatpažintas kodo formatas — turi prasidėti LAN: arba NOS:';

  @override
  String get profileCardFingerprintCopied => 'Pirštų atspaudas nukopijuotas';

  @override
  String get profileCardAboutHint => 'Privatumas pirmiausia 🔒';

  @override
  String get profileCardSaveButton => 'Išsaugoti profilį';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Eksportuoti šifruotas žinutes, kontaktus ir avataras į failą';

  @override
  String get callVideo => 'Vaizdo įrašas';

  @override
  String get callAudio => 'Garsas';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Pristatyta $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Pristatyta $count';
  }

  @override
  String get groupStatusDialogTitle => 'Žinutės informacija';

  @override
  String get groupStatusRead => 'Perskaityta';

  @override
  String get groupStatusDelivered => 'Pristatyta';

  @override
  String get groupStatusPending => 'Laukiama';

  @override
  String get groupStatusNoData => 'Pristatymo informacijos dar nėra';

  @override
  String get profileTransferAdmin => 'Padaryti administratoriumi';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Padaryti $name nauju administratoriumi?';
  }

  @override
  String get profileTransferAdminBody =>
      'Prarasite administratoriaus teises. Tai negalima atšaukti.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name dabar yra administratorius';
  }

  @override
  String get profileAdminBadge => 'Administratorius';

  @override
  String get privacyPolicyTitle => 'Privatumo politika';

  @override
  String get privacyOverviewHeading => 'Apžvalga';

  @override
  String get privacyOverviewBody =>
      'Pulse yra begalinis, ištisai užšifruotas žinučių siuntimo programa. Jūsų privatumas nėra tik funkcija — tai architektūra. Nėra jokių Pulse serverių. Jokios paskyros niekur nesaugomos. Jokie duomenys nėra renkami, perduodami ar saugomi kūrėjų.';

  @override
  String get privacyDataCollectionHeading => 'Duomenų rinkimas';

  @override
  String get privacyDataCollectionBody =>
      'Pulse nerenka jokių asmeninių duomenų. Konkrečiai:\n\n- Nereikia el. pašto, telefono numerio ar tikro vardo\n- Jokios analitikos, sekimo ar telemetrijos\n- Jokių reklaminių identifikatorių\n- Jokios prieigos prie kontaktų sąrašo\n- Jokių debesijos atsarginių kopijų (žinutės egzistuoja tik jūsų įrenginyje)\n- Jokie metaduomenys nesiunčiami jokiam Pulse serveriui (jų nėra)';

  @override
  String get privacyEncryptionHeading => 'Šifravimas';

  @override
  String get privacyEncryptionBody =>
      'Visos žinutės yra šifruojamos naudojant Signal protokolą (Double Ratchet su X3DH raktų susitarimu). Šifravimo raktai generuojami ir saugomi tik jūsų įrenginyje. Niekas — net kūrėjai — negali perskaityti jūsų žinučių.';

  @override
  String get privacyNetworkHeading => 'Tinklo architektūra';

  @override
  String get privacyNetworkBody =>
      'Pulse naudoja federacinius transporto adapterius (Nostr relay, Session/Oxen paslaugų mazgus, Firebase Realtime Database, LAN). Šie transportai perneša tik šifruotą šifrotekstą. Relay operatoriai gali matyti jūsų IP adresą ir duomenų srautą, bet negali iššifruoti žinučių turinio.\n\nKai Tor įjungtas, jūsų IP adresas taip pat paslėptas nuo relay operatorių.';

  @override
  String get privacyStunHeading => 'STUN/TURN serveriai';

  @override
  String get privacyStunBody =>
      'Balso ir vaizdo skambučiai naudoja WebRTC su DTLS-SRTP šifravimu. STUN serveriai (naudojami jūsų viešam IP adresui nustatyti lygiaverčiam ryšiui) ir TURN serveriai (naudojami medijos perdavimui, kai tiesioginis ryšys nepavyksta) gali matyti jūsų IP adresą ir skambučio trukmę, bet negali iššifruoti skambučio turinio.\n\nNustatymuose galite sukonfigūruoti savo TURN serverį maksimaliam privatumui.';

  @override
  String get privacyCrashHeading => 'Strigčių ataskaitos';

  @override
  String get privacyCrashBody =>
      'Jei Sentry strigčių ataskaitos yra įjungtos (per SENTRY_DSN kompiliavimo metu), gali būti siunčiamos anoniminės strigčių ataskaitos. Jose nėra jokio žinučių turinio, kontaktinės informacijos ar asmenį identifikuojančios informacijos. Strigčių ataskaitas galima išjungti kompiliavimo metu praleidžiant DSN.';

  @override
  String get privacyPasswordHeading => 'Slaptažodis ir raktai';

  @override
  String get privacyPasswordBody =>
      'Jūsų atkūrimo slaptažodis naudojamas kriptografiniams raktams generuoti per Argon2id (atminčiai reiklus KDF). Slaptažodis niekada niekur nesiunčiamas. Jei prarasite slaptažodį, jūsų paskyros negalima atkurti — nėra jokio serverio jam atstatyti.';

  @override
  String get privacyFontsHeading => 'Šriftai';

  @override
  String get privacyFontsBody =>
      'Pulse įtraukia visus šriftus vietinėje. Jokie užklausos nesiunčiamos Google Fonts ar kitoms išorinėms šriftų tarnyboms.';

  @override
  String get privacyThirdPartyHeading => 'Trečiųjų šalių paslaugos';

  @override
  String get privacyThirdPartyBody =>
      'Pulse neintegruojasi su jokiais reklamos tinklais, analitikos teikėjais, socialinės žiniasklaidos platformomis ar duomenų tarpininkais. Vieninteliai tinklo ryšiai yra prie transporto relay, kuriuos jūs sukonfigūruojate.';

  @override
  String get privacyOpenSourceHeading => 'Atvirasis kodas';

  @override
  String get privacyOpenSourceBody =>
      'Pulse yra atvirojo kodo programinė įranga. Galite audituoti visą pirminį kodą, kad patikrintumėte šiuos privatumo teiginius.';

  @override
  String get privacyContactHeading => 'Kontaktai';

  @override
  String get privacyContactBody =>
      'Su privatumu susijusiais klausimais atidarykite pranešimą projekto saugykloje.';

  @override
  String get privacyLastUpdated => 'Paskutinis atnaujinimas: 2026 m. kovas';

  @override
  String imageSaveFailed(Object error) {
    return 'Išsaugoti nepavyko: $error';
  }

  @override
  String get themeEngineTitle => 'Temų variklis';

  @override
  String get torBuiltInTitle => 'Įtaisytas Tor';

  @override
  String get torConnectedSubtitle =>
      'Prisijungta — Nostr nukreiptas per 127.0.0.1:9250';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Jungiamasi… $pct%';
  }

  @override
  String get torNotRunning =>
      'Neveikia — bakstelėkite jungiklį, kad paleistumėte iš naujo';

  @override
  String get torDescription =>
      'Nukreipia Nostr per Tor (Snowflake cenzūruotiems tinklams)';

  @override
  String get torNetworkDiagnostics => 'Tinklo diagnostika';

  @override
  String get torTransportLabel => 'Transportas: ';

  @override
  String get torPtAuto => 'Automatinis';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Paprastas';

  @override
  String get torTimeoutLabel => 'Laikas: ';

  @override
  String get torInfoDescription =>
      'Kai įjungta, Nostr WebSocket ryšiai nukreipiami per Tor (SOCKS5). Tor Browser klausosi 127.0.0.1:9150. Atskiras Tor demonas naudoja portą 9050. Firebase ryšiai nėra paveikiami.';

  @override
  String get torRouteNostrTitle => 'Nukreipti Nostr per Tor';

  @override
  String get torManagedByBuiltin => 'Valdomas įtaisyto Tor';

  @override
  String get torActiveRouting => 'Aktyvus — Nostr srautas nukreipiamas per Tor';

  @override
  String get torDisabled => 'Išjungtas';

  @override
  String get torProxySocks5 => 'Tor Proxy (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Proxy serveris';

  @override
  String get torProxyPortLabel => 'Prievadas';

  @override
  String get torPortInfo =>
      'Tor Browser: prievadas 9150  •  Tor demonas: prievadas 9050';

  @override
  String get i2pProxySocks5 => 'I2P Proxy (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P pagal numatytuosius nustatymus naudoja SOCKS5, prievadas 4447. Prisijunkite prie Nostr relay per I2P outproxy (pvz., relay.damus.i2p), kad bendrautumėte su naudotojais bet kuriame transporte. Tor turi prioritetą, kai abu įjungti.';

  @override
  String get i2pRouteNostrTitle => 'Nukreipti Nostr per I2P';

  @override
  String get i2pActiveRouting => 'Aktyvus — Nostr srautas nukreipiamas per I2P';

  @override
  String get i2pDisabled => 'Išjungtas';

  @override
  String get i2pProxyHostLabel => 'Proxy serveris';

  @override
  String get i2pProxyPortLabel => 'Prievadas';

  @override
  String get i2pPortInfo =>
      'I2P maršrutizatoriaus numatytasis SOCKS5 prievadas: 4447';

  @override
  String get customProxySocks5 => 'Pasirinktinis Proxy (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker Relay';

  @override
  String get customProxyInfoDescription =>
      'Pasirinktinis proxy nukreipia srautą per jūsų V2Ray/Xray/Shadowsocks. CF Worker veikia kaip asmeninis relay proxy Cloudflare CDN — GFW mato *.workers.dev, o ne tikrąjį relay.';

  @override
  String get customSocks5ProxyTitle => 'Pasirinktinis SOCKS5 Proxy';

  @override
  String get customProxyActive => 'Aktyvus — srautas nukreipiamas per SOCKS5';

  @override
  String get customProxyDisabled => 'Išjungtas';

  @override
  String get customProxyHostLabel => 'Proxy serveris';

  @override
  String get customProxyPortLabel => 'Prievadas';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker domenas (neprivaloma)';

  @override
  String get customWorkerHelpTitle => 'Kaip įdiegti CF Worker relay (nemokama)';

  @override
  String get customWorkerScriptCopied => 'Skriptas nukopijuotas!';

  @override
  String get customWorkerStep1 =>
      '1. Eikite į dash.cloudflare.com → Workers & Pages\n2. Create Worker → įklijuokite šį skriptą:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → nukopijuokite domeną (pvz., my-relay.user.workers.dev)\n4. Įklijuokite domeną aukščiau → Išsaugoti\n\nPrograma prisijungia automatiškai: wss://domain/?r=relay_url\nGFW mato: prisijungimą prie *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Prisijungta — SOCKS5, 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Jungiamasi…';

  @override
  String get psiphonNotRunning =>
      'Neveikia — bakstelėkite jungiklį, kad paleistumėte iš naujo';

  @override
  String get psiphonDescription =>
      'Greitas tunelis (~3s paleidimas, 2000+ rotacinių VPS)';

  @override
  String get turnCommunityServers => 'Bendruomenės TURN serveriai';

  @override
  String get turnCustomServer => 'Pasirinktinis TURN serveris (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN serveriai perduoda tik jau užšifruotus srautus (DTLS-SRTP). Relay operatorius mato jūsų IP ir srauto apimtį, bet negali iššifruoti skambučių. TURN naudojamas tik kai tiesioginis P2P nepavyksta (~15–20% ryšių).';

  @override
  String get turnFreeLabel => 'NEMOKAMA';

  @override
  String get turnServerUrlLabel => 'TURN serverio URL';

  @override
  String get turnServerUrlHint => 'turn:jusu-serveris.com:3478 arba turns:...';

  @override
  String get turnUsernameLabel => 'Naudotojo vardas';

  @override
  String get turnPasswordLabel => 'Slaptažodis';

  @override
  String get turnOptionalHint => 'Neprivaloma';

  @override
  String get turnCustomInfo =>
      'Paleiskite coturn bet kuriame 5\$/mėn. VPS maksimaliai kontrolei. Prisijungimo duomenys saugomi vietinėje.';

  @override
  String get themePickerAppearance => 'Išvaizda';

  @override
  String get themePickerAccentColor => 'Akcentinė spalva';

  @override
  String get themeModeLight => 'Šviesi';

  @override
  String get themeModeDark => 'Tamsi';

  @override
  String get themeModeSystem => 'Sisteminė';

  @override
  String get themeDynamicPresets => 'Šablonai';

  @override
  String get themeDynamicPrimaryColor => 'Pagrindinė spalva';

  @override
  String get themeDynamicBorderRadius => 'Kraštinės spindulys';

  @override
  String get themeDynamicFont => 'Šriftas';

  @override
  String get themeDynamicAppearance => 'Išvaizda';

  @override
  String get themeDynamicUiStyle => 'Sąsajos stilius';

  @override
  String get themeDynamicUiStyleDescription =>
      'Valdo, kaip atrodo dialogai, jungikliai ir indikatoriai.';

  @override
  String get themeDynamicSharp => 'Aštrus';

  @override
  String get themeDynamicRound => 'Apvalus';

  @override
  String get themeDynamicModeDark => 'Tamsi';

  @override
  String get themeDynamicModeLight => 'Šviesi';

  @override
  String get themeDynamicModeAuto => 'Automatinis';

  @override
  String get themeDynamicPlatformAuto => 'Automatinis';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'Netinkamas Firebase URL. Tikimasi: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Netinkamas relay URL. Tikimasi: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Netinkamas Pulse serverio URL. Tikimasi: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'Serverio URL';

  @override
  String get providerPulseServerUrlHint => 'https://jusu-serveris:8443';

  @override
  String get providerPulseInviteLabel => 'Kvietimo kodas';

  @override
  String get providerPulseInviteHint => 'Kvietimo kodas (jei reikia)';

  @override
  String get providerPulseInfo =>
      'Savarankiškai talpinamas relay. Raktai generuojami iš jūsų atkūrimo slaptažodžio.';

  @override
  String get providerScreenTitle => 'Gautieji';

  @override
  String get providerSecondaryInboxesHeader => 'ANTRINIAI GAUTIEJI';

  @override
  String get providerSecondaryInboxesInfo =>
      'Antriniai gautieji gauna žinutes vienu metu dėl pertekliškumo.';

  @override
  String get providerRemoveTooltip => 'Pašalinti';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... arba hex';

  @override
  String get providerNostrPrivkeyHintFull =>
      'nsec1... arba hex privatus raktas';

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
  String get emojiNoRecent => 'Nėra naujausių jaustukų';

  @override
  String get emojiSearchHint => 'Ieškoti jaustuko...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Bakstelėkite, kad pradėtumėte pokalbį';

  @override
  String get imageViewerSaveToDownloads => 'Išsaugoti į atsisiuntimus';

  @override
  String imageViewerSavedTo(String path) {
    return 'Išsaugota į $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'Gerai';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Kalba';

  @override
  String get settingsLanguageSubtitle => 'Programos rodymo kalba';

  @override
  String get settingsLanguageSystem => 'Sistemos numatytoji';

  @override
  String get onboardingLanguageTitle => 'Pasirinkite savo kalbą';

  @override
  String get onboardingLanguageSubtitle =>
      'Tai galite pakeisti vėliau Nustatymuose';

  @override
  String get videoNoteRecord => 'Įrašyti vaizdo žinutę';

  @override
  String get videoNoteTapToRecord => 'Bakstelėkite, kad įrašytumėte';

  @override
  String get videoNoteTapToStop => 'Bakstelėkite, kad sustabdytumėte';

  @override
  String get videoNoteCameraPermission => 'Prieiga prie kameros uždrausta';

  @override
  String get videoNoteMaxDuration => 'Daugiausiai 30 sekundžių';

  @override
  String get videoNoteNotSupported =>
      'Vaizdo įrašų pastabos nepalaikomos šioje platformoje';

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
