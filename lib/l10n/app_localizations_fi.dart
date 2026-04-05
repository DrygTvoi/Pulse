// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appTitle => 'Pulse';

  @override
  String get searchMessages => 'Hae viestejä...';

  @override
  String get search => 'Haku';

  @override
  String get clearSearch => 'Tyhjennä haku';

  @override
  String get closeSearch => 'Sulje haku';

  @override
  String get moreOptions => 'Lisää vaihtoehtoja';

  @override
  String get back => 'Takaisin';

  @override
  String get cancel => 'Peruuta';

  @override
  String get close => 'Sulje';

  @override
  String get confirm => 'Vahvista';

  @override
  String get remove => 'Poista';

  @override
  String get save => 'Tallenna';

  @override
  String get add => 'Lisää';

  @override
  String get copy => 'Kopioi';

  @override
  String get skip => 'Ohita';

  @override
  String get done => 'Valmis';

  @override
  String get apply => 'Käytä';

  @override
  String get export => 'Vie';

  @override
  String get import => 'Tuo';

  @override
  String get homeNewGroup => 'Uusi ryhmä';

  @override
  String get homeSettings => 'Asetukset';

  @override
  String get homeSearching => 'Haetaan viestejä...';

  @override
  String get homeNoResults => 'Tuloksia ei löytynyt';

  @override
  String get homeNoChatHistory => 'Ei vielä keskusteluhistoriaa';

  @override
  String homeTransportSwitched(String address) {
    return 'Kuljetustapa vaihdettu → $address';
  }

  @override
  String homeIncomingCall(String name) {
    return '$name soittaa...';
  }

  @override
  String get homeAccept => 'Hyväksy';

  @override
  String get homeDecline => 'Hylkää';

  @override
  String get homeLoadEarlier => 'Lataa aiemmat viestit';

  @override
  String get homeChats => 'Keskustelut';

  @override
  String get homeSelectConversation => 'Valitse keskustelu';

  @override
  String get homeNoChatsYet => 'Ei vielä keskusteluja';

  @override
  String get homeAddContactToStart =>
      'Lisää yhteystieto aloittaaksesi keskustelun';

  @override
  String get homeNewChat => 'Uusi keskustelu';

  @override
  String get homeNewChatTooltip => 'Uusi keskustelu';

  @override
  String get homeIncomingCallTitle => 'Saapuva puhelu';

  @override
  String get homeIncomingGroupCallTitle => 'Saapuva ryhmäpuhelu';

  @override
  String homeGroupCallIncoming(String name) {
    return '$name — ryhmäpuhelu saapuu';
  }

  @override
  String homeNoChatsMatchingQuery(String query) {
    return 'Ei keskusteluja hakusanalla \"$query\"';
  }

  @override
  String get homeSectionChats => 'Keskustelut';

  @override
  String get homeSectionMessages => 'Viestit';

  @override
  String get homeDbEncryptionUnavailable =>
      'Tietokannan salaus ei ole käytettävissä — asenna SQLCipher täyttä suojausta varten';

  @override
  String get chatFileTooLargeGroup =>
      'Yli 512 kt tiedostoja ei tueta ryhmäkeskusteluissa';

  @override
  String get chatLargeFile => 'Suuri tiedosto';

  @override
  String get chatCancel => 'Peruuta';

  @override
  String get chatSend => 'Lähetä';

  @override
  String get chatFileTooLarge =>
      'Tiedosto liian suuri — enimmäiskoko on 100 Mt';

  @override
  String get chatMicDenied => 'Mikrofonin käyttöoikeus evätty';

  @override
  String get chatVoiceFailed =>
      'Ääniviestiä ei voitu tallentaa — tarkista vapaa tallennustila';

  @override
  String get chatScheduleFuture => 'Ajastetun ajan on oltava tulevaisuudessa';

  @override
  String get chatToday => 'Tänään';

  @override
  String get chatYesterday => 'Eilen';

  @override
  String get chatEdited => 'muokattu';

  @override
  String get chatYou => 'Sinä';

  @override
  String chatLargeFileSizeWarning(String size) {
    return 'Tiedosto on $size Mt. Suurten tiedostojen lähettäminen voi olla hidasta joissain verkoissa. Jatketaanko?';
  }

  @override
  String chatKeyChangedSnackbar(String name) {
    return 'Henkilön $name suojausavain on muuttunut. Napauta varmistaaksesi.';
  }

  @override
  String chatEncryptionFailed(String name) {
    return 'Viestiä ei voitu salata henkilölle $name — viestiä ei lähetetty.';
  }

  @override
  String chatSafetyNumberChanged(String name) {
    return 'Turvaluku henkilölle $name on muuttunut. Napauta varmistaaksesi.';
  }

  @override
  String get chatNoMessagesFound => 'Viestejä ei löytynyt';

  @override
  String get chatMessagesE2ee => 'Viestit ovat päästä päähän salattuja';

  @override
  String get chatSayHello => 'Sano hei';

  @override
  String get appBarOnline => 'paikalla';

  @override
  String get appBarSignalE2ee => 'Signal E2EE';

  @override
  String get appBarKyber => '+ Kyber';

  @override
  String get appBarTyping => 'kirjoittaa';

  @override
  String get appBarSearchMessages => 'Hae viestejä...';

  @override
  String get appBarMute => 'Mykistä';

  @override
  String get appBarUnmute => 'Poista mykistys';

  @override
  String get appBarMedia => 'Media';

  @override
  String get appBarDisappearing => 'Katoavat viestit';

  @override
  String get appBarDisappearingOn => 'Katoavat: päällä';

  @override
  String get appBarGroupSettings => 'Ryhmäasetukset';

  @override
  String get appBarSearchTooltip => 'Hae viestejä';

  @override
  String get appBarVoiceCall => 'Äänipuhelu';

  @override
  String get appBarVideoCall => 'Videopuhelu';

  @override
  String get inputMessage => 'Viesti...';

  @override
  String get inputAttachFile => 'Liitä tiedosto';

  @override
  String get inputSendMessage => 'Lähetä viesti';

  @override
  String get inputRecordVoice => 'Nauhoita ääniviesti';

  @override
  String get inputSendVoice => 'Lähetä ääniviesti';

  @override
  String get inputCancelReply => 'Peruuta vastaus';

  @override
  String get inputCancelEdit => 'Peruuta muokkaus';

  @override
  String get inputCancelRecording => 'Peruuta nauhoitus';

  @override
  String get inputRecording => 'Nauhoitetaan…';

  @override
  String get inputEditingMessage => 'Muokataan viestiä';

  @override
  String get inputPhoto => 'Kuva';

  @override
  String get inputVoiceMessage => 'Ääniviesti';

  @override
  String get inputFile => 'Tiedosto';

  @override
  String inputScheduledMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ä',
      one: '',
    );
    return '$count ajastettu viesti$_temp0';
  }

  @override
  String get callInitializing => 'Alustetaan puhelua…';

  @override
  String get callConnecting => 'Yhdistetään…';

  @override
  String get callConnectingRelay => 'Yhdistetään (välitys)…';

  @override
  String get callSwitchingRelay => 'Vaihdetaan välitystilaan…';

  @override
  String get callConnectionFailed => 'Yhteys epäonnistui';

  @override
  String get callReconnecting => 'Yhdistetään uudelleen…';

  @override
  String get callEnded => 'Puhelu päättyi';

  @override
  String get callLive => 'Live';

  @override
  String get callEnd => 'Lopeta';

  @override
  String get callEndCall => 'Lopeta puhelu';

  @override
  String get callMute => 'Mykistä';

  @override
  String get callUnmute => 'Poista mykistys';

  @override
  String get callSpeaker => 'Kaiutin';

  @override
  String get callCameraOn => 'Kamera päällä';

  @override
  String get callCameraOff => 'Kamera pois';

  @override
  String get callShareScreen => 'Jaa näyttö';

  @override
  String get callStopShare => 'Lopeta jakaminen';

  @override
  String callTorBackup(String duration) {
    return 'Tor-varmuus · $duration';
  }

  @override
  String get callTorBackupBanner =>
      'Tor-varayhteys käytössä — ensisijainen reitti ei käytettävissä';

  @override
  String get callDirectFailed =>
      'Suora yhteys epäonnistui — vaihdetaan välitystilaan…';

  @override
  String get callTurnUnreachable =>
      'TURN-palvelimet eivät ole tavoitettavissa. Lisää mukautettu TURN kohdassa Asetukset → Lisäasetukset.';

  @override
  String get callRelayMode => 'Välitystila käytössä (rajoitettu verkko)';

  @override
  String get callStarting => 'Puhelu käynnistyy…';

  @override
  String get callConnectingToGroup => 'Yhdistetään ryhmään…';

  @override
  String get callGroupOpenedInBrowser => 'Ryhmäpuhelu avattiin selaimessa';

  @override
  String get callCouldNotOpenBrowser => 'Selainta ei voitu avata';

  @override
  String get callInviteLinkSent =>
      'Kutsulinkki lähetetty kaikille ryhmän jäsenille.';

  @override
  String get callOpenLinkManually =>
      'Avaa yllä oleva linkki manuaalisesti tai napauta yrittääksesi uudelleen.';

  @override
  String get callJitsiNotE2ee =>
      'Jitsi-puhelut EIVÄT ole päästä päähän salattuja';

  @override
  String get callRetryOpenBrowser => 'Yritä avata selain uudelleen';

  @override
  String get callClose => 'Sulje';

  @override
  String get callCamOn => 'Kamera päällä';

  @override
  String get callCamOff => 'Kamera pois';

  @override
  String get noConnection => 'Ei yhteyttä — viestit jonottavat';

  @override
  String get connected => 'Yhdistetty';

  @override
  String get connecting => 'Yhdistetään…';

  @override
  String get disconnected => 'Yhteys katkennut';

  @override
  String get offlineBanner =>
      'Ei yhteyttä — viestit lähetetään kun olet taas verkossa';

  @override
  String get lanModeBanner => 'LAN-tila — Ei internetiä · Vain lähiverkko';

  @override
  String get probeCheckingNetwork => 'Tarkistetaan verkkoyhteyttä…';

  @override
  String get probeDiscoveringRelays =>
      'Etsitään välityspalvelimia yhteisöhakemistoista…';

  @override
  String get probeStartingTor => 'Käynnistetään Tor…';

  @override
  String get probeFindingRelaysTor =>
      'Etsitään tavoitettavia välityspalvelimia Torin kautta…';

  @override
  String probeNetworkReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ta',
      one: '',
    );
    return 'Verkko valmis — $count välityspalvelin$_temp0 löydetty';
  }

  @override
  String get probeNoRelaysFound =>
      'Tavoitettavia välityspalvelimia ei löytynyt — viestit voivat viivästyä';

  @override
  String get jitsiWarningTitle => 'Ei päästä päähän salattua';

  @override
  String get jitsiWarningBody =>
      'Jitsi Meet -puheluita ei salaa Pulse. Käytä vain ei-arkaluonteisiin keskusteluihin.';

  @override
  String get jitsiConfirm => 'Liity silti';

  @override
  String get jitsiGroupWarningTitle => 'Ei päästä päähän salattua';

  @override
  String get jitsiGroupWarningBody =>
      'Tässä puhelussa on liian monta osallistujaa sisäänrakennetulle salatulle mesh-verkolle.\n\nJitsi Meet -linkki avataan selaimessasi. Jitsi EI ole päästä päähän salattu — palvelin voi nähdä puhelusi.';

  @override
  String get jitsiContinueAnyway => 'Jatka silti';

  @override
  String get retry => 'Yritä uudelleen';

  @override
  String get setupCreateAnonymousAccount => 'Luo anonyymi tili';

  @override
  String get setupTapToChangeColor => 'Napauta vaihtaaksesi väriä';

  @override
  String get setupReqMinLength => 'Vähintään 16 merkkiä';

  @override
  String get setupReqVariety =>
      '3/4: isot, pienet kirjaimet, numerot, symbolit';

  @override
  String get setupReqMatch => 'Salasanat täsmäävät';

  @override
  String get setupYourNickname => 'Lempinimesi';

  @override
  String get setupRecoveryPassword => 'Palautussalasana (väh. 16)';

  @override
  String get setupConfirmPassword => 'Vahvista salasana';

  @override
  String get setupMin16Chars => 'Vähintään 16 merkkiä';

  @override
  String get setupPasswordsDoNotMatch => 'Salasanat eivät täsmää';

  @override
  String get setupEntropyWeak => 'Heikko';

  @override
  String get setupEntropyOk => 'OK';

  @override
  String get setupEntropyStrong => 'Vahva';

  @override
  String get setupEntropyWeakNeedsVariety =>
      'Heikko (tarvitaan 3 merkkityyppiä)';

  @override
  String setupEntropyBits(String label, int bits) {
    return '$label ($bits bittiä)';
  }

  @override
  String get setupPasswordWarning =>
      'Tämä salasana on ainoa tapa palauttaa tilisi. Palvelinta ei ole — salasanaa ei voi nollata. Muista se tai kirjoita ylös.';

  @override
  String get setupCreateAccount => 'Luo tili';

  @override
  String get setupAlreadyHaveAccount => 'Onko sinulla jo tili? ';

  @override
  String get setupRestore => 'Palauta →';

  @override
  String get restoreTitle => 'Palauta tili';

  @override
  String get restoreInfoBanner =>
      'Syötä palautussalasanasi — osoitteesi (Nostr + Session) palautetaan automaattisesti. Yhteystiedot ja viestit tallennettiin vain paikallisesti.';

  @override
  String get restoreNewNickname => 'Uusi lempinimi (voi muuttaa myöhemmin)';

  @override
  String get restoreButton => 'Palauta tili';

  @override
  String get lockTitle => 'Pulse on lukittu';

  @override
  String get lockSubtitle => 'Syötä salasanasi jatkaaksesi';

  @override
  String get lockPasswordHint => 'Salasana';

  @override
  String get lockUnlock => 'Avaa';

  @override
  String get lockPanicHint =>
      'Unohditko salasanasi? Syötä paniikkinäppäimesi tyhjentääksesi kaikki tiedot.';

  @override
  String get lockTooManyAttempts =>
      'Liian monta yritystä. Kaikki tiedot poistetaan…';

  @override
  String get lockWrongPassword => 'Väärä salasana';

  @override
  String lockWrongPasswordAttempts(int attempts, int max) {
    return 'Väärä salasana — $attempts/$max yritystä';
  }

  @override
  String get onboardingSkip => 'Ohita';

  @override
  String get onboardingNext => 'Seuraava';

  @override
  String get onboardingGetStarted => 'Aloita';

  @override
  String get onboardingWelcomeTitle => 'Tervetuloa Pulseen';

  @override
  String get onboardingWelcomeBody =>
      'Hajautettu, päästä päähän salattu pikaviestisovellus.\n\nEi keskuspalvelimia. Ei tiedonkeruuta. Ei takaovia.\nKeskustelusi kuuluvat vain sinulle.';

  @override
  String get onboardingTransportTitle => 'Kuljetusriippumaton';

  @override
  String get onboardingTransportBody =>
      'Käytä Firebasea, Nostria tai molempia samanaikaisesti.\n\nViestit reititetään automaattisesti verkkojen välillä. Sisäänrakennettu Tor- ja I2P-tuki sensuurinkestävyyteen.';

  @override
  String get onboardingSignalTitle => 'Signal + jälkikvantti';

  @override
  String get onboardingSignalBody =>
      'Jokainen viesti salataan Signal-protokollalla (Double Ratchet + X3DH) eteenpäinsalauksen takaamiseksi.\n\nLisäksi kääritty Kyber-1024:lla — NIST-standardoitu jälkikvanttialgoritmilla — suojaten tulevilta kvanttitietokoneilta.';

  @override
  String get onboardingKeysTitle => 'Avaimesi ovat sinun';

  @override
  String get onboardingKeysBody =>
      'Identiteettiavaimesi eivät koskaan poistu laitteeltasi.\n\nSignal-sormenjälkien avulla voit varmentaa yhteystiedot kaistan ulkopuolella. TOFU (Trust On First Use) havaitsee avainmuutokset automaattisesti.';

  @override
  String get onboardingThemeTitle => 'Valitse ulkoasusi';

  @override
  String get onboardingThemeBody =>
      'Valitse teema ja korostusväri. Voit aina muuttaa tämän myöhemmin Asetuksista.';

  @override
  String get contactsNewChat => 'Uusi keskustelu';

  @override
  String get contactsAddContact => 'Lisää yhteystieto';

  @override
  String get contactsSearchHint => 'Hae...';

  @override
  String get contactsNewGroup => 'Uusi ryhmä';

  @override
  String get contactsNoContactsYet => 'Ei vielä yhteystietoja';

  @override
  String get contactsAddHint => 'Napauta + lisätäksesi jonkun osoitteen';

  @override
  String get contactsNoMatch => 'Ei vastaavia yhteystietoja';

  @override
  String get contactsRemoveTitle => 'Poista yhteystieto';

  @override
  String contactsRemoveMessage(String name) {
    return 'Poista $name?';
  }

  @override
  String get contactsRemove => 'Poista';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'a',
      one: '',
    );
    return '$count yhteystieto$_temp0';
  }

  @override
  String get bubbleOpenLink => 'Avaa linkki';

  @override
  String bubbleOpenLinkBody(String url) {
    return 'Avaa tämä URL selaimessa?\n\n$url';
  }

  @override
  String get bubbleOpen => 'Avaa';

  @override
  String get bubbleSecurityWarning => 'Turvallisuusvaroitus';

  @override
  String bubbleExecutableWarning(String name) {
    return '\"$name\" on suoritettava tiedostotyyppi. Tallentaminen ja suorittaminen voi vahingoittaa laitettasi. Tallennetaanko silti?';
  }

  @override
  String get bubbleSaveAnyway => 'Tallenna silti';

  @override
  String bubbleSavedTo(String path) {
    return 'Tallennettu kohteeseen $path';
  }

  @override
  String bubbleSaveFailed(String error) {
    return 'Tallennus epäonnistui: $error';
  }

  @override
  String get bubbleNotEncrypted => 'EI SALATTU';

  @override
  String get bubbleCorruptedImage => '[Vioittunut kuva]';

  @override
  String get bubbleReplyPhoto => 'Kuva';

  @override
  String get bubbleReplyVoice => 'Ääniviesti';

  @override
  String get bubbleReplyVideo => 'Videoviesti';

  @override
  String bubbleReadBy(String names) {
    return 'Lukenut: $names';
  }

  @override
  String bubbleReadByCount(int count) {
    return '$count lukenut';
  }

  @override
  String get chatTileTapToStart => 'Aloita keskustelu napauttamalla';

  @override
  String get chatTileMessageSent => 'Viesti lähetetty';

  @override
  String get chatTileEncryptedMessage => 'Salattu viesti';

  @override
  String chatTileYouPrefix(String text) {
    return 'Sinä: $text';
  }

  @override
  String get chatTileVoiceMessage => '🎤 Ääniviesti';

  @override
  String chatTileVoiceMessageDuration(String duration) {
    return '🎤 Ääniviesti ($duration)';
  }

  @override
  String get bannerEncryptedMessage => 'Salattu viesti';

  @override
  String get groupNewGroup => 'Uusi ryhmä';

  @override
  String get groupGroupName => 'Ryhmän nimi';

  @override
  String get groupSelectMembers => 'Valitse jäsenet (väh. 2)';

  @override
  String get groupNoContactsYet =>
      'Ei vielä yhteystietoja. Lisää yhteystietoja ensin.';

  @override
  String get groupCreate => 'Luo';

  @override
  String get groupLabel => 'Ryhmä';

  @override
  String get profileVerifyIdentity => 'Vahvista identiteetti';

  @override
  String profileVerifyInstructions(String name) {
    return 'Vertaa näitä sormenjälkiä henkilön $name kanssa äänipuhelussa tai henkilökohtaisesti. Jos molemmat arvot täsmäävät molemmissa laitteissa, napauta \"Merkitse vahvistetuksi\".';
  }

  @override
  String get profileTheirKey => 'Heidän avaimensa';

  @override
  String get profileYourKey => 'Sinun avaimesi';

  @override
  String get profileRemoveVerification => 'Poista vahvistus';

  @override
  String get profileMarkAsVerified => 'Merkitse vahvistetuksi';

  @override
  String get profileAddressCopied => 'Osoite kopioitu';

  @override
  String get profileNoContactsToAdd =>
      'Ei lisättäviä yhteystietoja — kaikki ovat jo jäseniä';

  @override
  String get profileAddMembers => 'Lisää jäseniä';

  @override
  String profileAddCount(int count) {
    return 'Lisää ($count)';
  }

  @override
  String get profileRenameGroup => 'Nimeä ryhmä uudelleen';

  @override
  String get profileRename => 'Nimeä uudelleen';

  @override
  String get profileRemoveMember => 'Poista jäsen?';

  @override
  String profileRemoveMemberBody(String name) {
    return 'Poista $name tästä ryhmästä?';
  }

  @override
  String get profileKick => 'Poista';

  @override
  String get profileSignalFingerprints => 'Signal-sormenjäljet';

  @override
  String get profileVerified => 'VAHVISTETTU';

  @override
  String get profileVerify => 'Vahvista';

  @override
  String get profileEdit => 'Muokkaa';

  @override
  String get profileNoSession =>
      'Istuntoa ei ole vielä muodostettu — lähetä ensin viesti.';

  @override
  String get profileFingerprintCopied => 'Sormenjälki kopioitu';

  @override
  String profileMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tä',
      one: '',
    );
    return '$count jäsen$_temp0';
  }

  @override
  String get profileVerifySafetyNumber => 'Vahvista turvaluku';

  @override
  String get profileShowContactQr => 'Näytä yhteystiedon QR';

  @override
  String profileContactAddress(String name) {
    return '$name osoite';
  }

  @override
  String get profileExportChatHistory => 'Vie keskusteluhistoria';

  @override
  String profileSavedTo(String path) {
    return 'Tallennettu kohteeseen $path';
  }

  @override
  String get profileExportFailed => 'Vienti epäonnistui';

  @override
  String get profileClearChatHistory => 'Tyhjennä keskusteluhistoria';

  @override
  String get profileDeleteGroup => 'Poista ryhmä';

  @override
  String get profileDeleteContact => 'Poista yhteystieto';

  @override
  String get profileLeaveGroup => 'Poistu ryhmästä';

  @override
  String get profileLeaveGroupBody =>
      'Sinut poistetaan tästä ryhmästä ja se poistetaan yhteystiedoistasi.';

  @override
  String get groupInviteTitle => 'Ryhmäkutsu';

  @override
  String groupInviteBody(String from, String group) {
    return '$from kutsui sinut ryhmään \"$group\"';
  }

  @override
  String get groupInviteAccept => 'Hyväksy';

  @override
  String get groupInviteDecline => 'Hylkää';

  @override
  String get groupMemberLimitTitle => 'Liian monta osallistujaa';

  @override
  String groupMemberLimitBody(int count) {
    return 'Tässä ryhmässä on $count osallistujaa. Salatut mesh-puhelut tukevat enintään 6 osallistujaa. Suuremmat ryhmät siirtyvät Jitsiin (ei E2EE).';
  }

  @override
  String get groupMemberLimitContinue => 'Lisää silti';

  @override
  String groupInviteDeclinedSnackbar(String name, String group) {
    return '$name hylkäsi kutsun ryhmään \"$group\"';
  }

  @override
  String get transferTitle => 'Siirrä toiseen laitteeseen';

  @override
  String get transferInfoBox =>
      'Siirrä Signal-identiteettisi ja Nostr-avaimesi uuteen laitteeseen.\nKeskusteluistuntoja EI siirretä — eteenpäinsalaus säilyy.';

  @override
  String get transferSendFromThis => 'Lähetä tästä laitteesta';

  @override
  String get transferSendSubtitle =>
      'Tällä laitteella on avaimet. Jaa koodi uuden laitteen kanssa.';

  @override
  String get transferReceiveOnThis => 'Vastaanota tällä laitteella';

  @override
  String get transferReceiveSubtitle =>
      'Tämä on uusi laite. Syötä koodi vanhasta laitteesta.';

  @override
  String get transferChooseMethod => 'Valitse siirtotapa';

  @override
  String get transferLan => 'LAN (sama verkko)';

  @override
  String get transferLanSubtitle =>
      'Nopea, suora. Molempien laitteiden on oltava samassa Wi-Fi-verkossa.';

  @override
  String get transferNostrRelay => 'Nostr-välityspalvelin';

  @override
  String get transferNostrRelaySubtitle =>
      'Toimii missä tahansa verkossa olemassa olevan Nostr-välityspalvelimen kautta.';

  @override
  String get transferRelayUrl => 'Välityspalvelimen URL';

  @override
  String get transferEnterCode => 'Syötä siirtokoodi';

  @override
  String get transferPasteCode => 'Liitä LAN:... tai NOS:... koodi tähän';

  @override
  String get transferConnect => 'Yhdistä';

  @override
  String get transferGenerating => 'Luodaan siirtokoodia…';

  @override
  String get transferShareCode => 'Jaa tämä koodi vastaanottajalle:';

  @override
  String get transferCopyCode => 'Kopioi koodi';

  @override
  String get transferCodeCopied => 'Koodi kopioitu leikepöydälle';

  @override
  String get transferWaitingReceiver => 'Odotetaan vastaanottajan yhteyttä…';

  @override
  String get transferConnectingSender => 'Yhdistetään lähettäjään…';

  @override
  String get transferVerifyBoth =>
      'Vertaa tätä koodia molemmissa laitteissa.\nJos ne täsmäävät, siirto on turvallinen.';

  @override
  String get transferComplete => 'Siirto valmis';

  @override
  String get transferKeysImported => 'Avaimet tuotu';

  @override
  String get transferCompleteSenderBody =>
      'Avaimesi pysyvät aktiivisina tässä laitteessa.\nVastaanottaja voi nyt käyttää identiteettiäsi.';

  @override
  String get transferCompleteReceiverBody =>
      'Avaimet tuotu onnistuneesti.\nKäynnistä sovellus uudelleen ottaaksesi uuden identiteetin käyttöön.';

  @override
  String get transferRestartApp => 'Käynnistä sovellus uudelleen';

  @override
  String get transferFailed => 'Siirto epäonnistui';

  @override
  String get transferTryAgain => 'Yritä uudelleen';

  @override
  String get transferEnterRelayFirst => 'Syötä ensin välityspalvelimen URL';

  @override
  String get transferPasteCodeFromSender => 'Liitä lähettäjän siirtokoodi';

  @override
  String get menuReply => 'Vastaa';

  @override
  String get menuForward => 'Välitä';

  @override
  String get menuReact => 'Reagoi';

  @override
  String get menuCopy => 'Kopioi';

  @override
  String get menuEdit => 'Muokkaa';

  @override
  String get menuRetry => 'Yritä uudelleen';

  @override
  String get menuCancelScheduled => 'Peruuta ajastettu';

  @override
  String get menuDelete => 'Poista';

  @override
  String get menuForwardTo => 'Välitä…';

  @override
  String menuForwardedTo(String name) {
    return 'Välitetty henkilölle $name';
  }

  @override
  String get menuScheduledMessages => 'Ajastetut viestit';

  @override
  String get menuNoScheduledMessages => 'Ei ajastettuja viestejä';

  @override
  String menuSendsOn(String date) {
    return 'Lähetetään $date';
  }

  @override
  String get menuDisappearingMessages => 'Katoavat viestit';

  @override
  String get menuDisappearingSubtitle =>
      'Viestit poistetaan automaattisesti valitun ajan jälkeen.';

  @override
  String get menuTtlOff => 'Pois';

  @override
  String get menuTtl1h => '1 tunti';

  @override
  String get menuTtl24h => '24 tuntia';

  @override
  String get menuTtl7d => '7 päivää';

  @override
  String get menuAttachPhoto => 'Kuva';

  @override
  String get menuAttachFile => 'Tiedosto';

  @override
  String get menuAttachVideo => 'Video';

  @override
  String get mediaTitle => 'Media';

  @override
  String get mediaFileLabel => 'TIEDOSTO';

  @override
  String mediaPhotosTab(int count) {
    return 'Kuvat ($count)';
  }

  @override
  String mediaFilesTab(int count) {
    return 'Tiedostot ($count)';
  }

  @override
  String get mediaNoPhotos => 'Ei vielä kuvia';

  @override
  String get mediaNoFiles => 'Ei vielä tiedostoja';

  @override
  String mediaSavedToDownloads(String name) {
    return 'Tallennettu Lataukset/$name';
  }

  @override
  String get mediaFailedToSave => 'Tiedoston tallennus epäonnistui';

  @override
  String get statusNewStatus => 'Uusi tila';

  @override
  String get statusPublish => 'Julkaise';

  @override
  String get statusExpiresIn24h => 'Tila vanhenee 24 tunnissa';

  @override
  String get statusWhatsOnYourMind => 'Mitä mietit?';

  @override
  String get statusPhotoAttached => 'Kuva liitetty';

  @override
  String get statusAttachPhoto => 'Liitä kuva (valinnainen)';

  @override
  String get statusEnterText => 'Syötä tekstiä tilaasi varten.';

  @override
  String statusPickPhotoFailed(String error) {
    return 'Kuvan valinta epäonnistui: $error';
  }

  @override
  String statusPublishFailed(String error) {
    return 'Julkaisu epäonnistui: $error';
  }

  @override
  String get panicSetPanicKey => 'Aseta paniikkinäppäin';

  @override
  String get panicEmergencySelfDestruct => 'Hätätuhoutuminen';

  @override
  String get panicIrreversible => 'Tämä toiminto on peruuttamaton';

  @override
  String get panicWarningBody =>
      'Tämän avaimen syöttäminen lukitusnäytöllä pyyhkii välittömästi KAIKKI tiedot — viestit, yhteystiedot, avaimet, identiteetin. Käytä eri avainta kuin normaali salasanasi.';

  @override
  String get panicKeyHint => 'Paniikkinäppäin';

  @override
  String get panicConfirmHint => 'Vahvista paniikkinäppäin';

  @override
  String get panicMinChars => 'Paniikkinäppäimen on oltava vähintään 8 merkkiä';

  @override
  String get panicKeysDoNotMatch => 'Avaimet eivät täsmää';

  @override
  String get panicSetFailed =>
      'Paniikkinäppäimen tallennus epäonnistui — yritä uudelleen';

  @override
  String get passwordSetAppPassword => 'Aseta sovelluksen salasana';

  @override
  String get passwordProtectsMessages => 'Suojaa viestisi levossa';

  @override
  String get passwordInfoBanner =>
      'Vaaditaan joka kerta kun avaat Pulsen. Jos unohdat, tietojasi ei voi palauttaa.';

  @override
  String get passwordHint => 'Salasana';

  @override
  String get passwordConfirmHint => 'Vahvista salasana';

  @override
  String get passwordSetButton => 'Aseta salasana';

  @override
  String get passwordSkipForNow => 'Ohita toistaiseksi';

  @override
  String get passwordMinChars => 'Salasanan on oltava vähintään 6 merkkiä';

  @override
  String get passwordsDoNotMatch => 'Salasanat eivät täsmää';

  @override
  String get profileCardSaved => 'Profiili tallennettu!';

  @override
  String get profileCardE2eeIdentity => 'E2EE-identiteetti';

  @override
  String get profileCardDisplayName => 'Näyttönimi';

  @override
  String get profileCardDisplayNameHint => 'esim. Matti Meikäläinen';

  @override
  String get profileCardAbout => 'Tietoja';

  @override
  String get profileCardSaveProfile => 'Tallenna profiili';

  @override
  String get profileCardYourName => 'Nimesi';

  @override
  String get profileCardAddressCopied => 'Osoite kopioitu!';

  @override
  String get profileCardInboxAddress => 'Saapuvien osoitteesi';

  @override
  String get profileCardInboxAddresses => 'Saapuvien osoitteesi';

  @override
  String get profileCardShareAllAddresses =>
      'Jaa kaikki osoitteet (SmartRouter)';

  @override
  String get profileCardShareHint =>
      'Jaa yhteystiedoillesi, jotta he voivat lähettää sinulle viestejä.';

  @override
  String profileCardAllAddressesCopied(int count) {
    return 'Kaikki $count osoitetta kopioitu yhdeksi linkiksi!';
  }

  @override
  String get settingsMyProfile => 'Oma profiili';

  @override
  String get settingsYourInboxAddress => 'Saapuvien osoitteesi';

  @override
  String get settingsMyQrCode => 'QR-koodini';

  @override
  String get settingsMyQrSubtitle => 'Jaa osoitteesi skannattavana QR-koodina';

  @override
  String get settingsShareMyAddress => 'Jaa osoitteeni';

  @override
  String get settingsNoAddressYet =>
      'Ei vielä osoitetta — tallenna asetukset ensin';

  @override
  String get settingsInviteLink => 'Kutsulinkki';

  @override
  String get settingsRawAddress => 'Raakaosoite';

  @override
  String get settingsCopyLink => 'Kopioi linkki';

  @override
  String get settingsCopyAddress => 'Kopioi osoite';

  @override
  String get settingsInviteLinkCopied => 'Kutsulinkki kopioitu';

  @override
  String get settingsAppearance => 'Ulkoasu';

  @override
  String get settingsThemeEngine => 'Teemamoottori';

  @override
  String get settingsThemeEngineSubtitle => 'Mukauta värejä ja fontteja';

  @override
  String get settingsSignalProtocol => 'Signal Protocol';

  @override
  String get settingsSignalProtocolSubtitle =>
      'E2EE-avaimet tallennettu turvallisesti';

  @override
  String get settingsActive => 'AKTIIVINEN';

  @override
  String get settingsIdentityBackup => 'Identiteetin varmuuskopio';

  @override
  String get settingsIdentityBackupSubtitle =>
      'Vie tai tuo Signal-identiteettisi';

  @override
  String get settingsIdentityBackupBody =>
      'Vie Signal-identiteettiavaimesi varmuuskoodiksi tai palauta olemassa olevasta.';

  @override
  String get settingsTransferDevice => 'Siirrä toiseen laitteeseen';

  @override
  String get settingsTransferDeviceSubtitle =>
      'Siirrä identiteetti LANin tai Nostr-välityspalvelimen kautta';

  @override
  String get settingsExportIdentity => 'Vie identiteetti';

  @override
  String get settingsExportIdentityBody =>
      'Kopioi tämä varmuuskoodi ja tallenna se turvallisesti:';

  @override
  String get settingsSaveFile => 'Tallenna tiedosto';

  @override
  String get settingsImportIdentity => 'Tuo identiteetti';

  @override
  String get settingsImportIdentityBody =>
      'Liitä varmuuskoodisi alle. Tämä korvaa nykyisen identiteettisi.';

  @override
  String get settingsPasteBackupCode => 'Liitä varmuuskoodi tähän…';

  @override
  String get settingsIdentityImported =>
      'Identiteetti + yhteystiedot tuotu! Käynnistä sovellus uudelleen.';

  @override
  String get settingsSecurity => 'Turvallisuus';

  @override
  String get settingsAppPassword => 'Sovelluksen salasana';

  @override
  String get settingsPasswordEnabled =>
      'Käytössä — vaaditaan joka käynnistyksellä';

  @override
  String get settingsPasswordDisabled =>
      'Pois käytöstä — sovellus avautuu ilman salasanaa';

  @override
  String get settingsChangePassword => 'Vaihda salasana';

  @override
  String get settingsChangePasswordSubtitle =>
      'Päivitä sovelluksen lukitussalasana';

  @override
  String get settingsSetPanicKey => 'Aseta paniikkinäppäin';

  @override
  String get settingsChangePanicKey => 'Vaihda paniikkinäppäin';

  @override
  String get settingsPanicKeySetSubtitle => 'Päivitä hätäpyyhkäisyavain';

  @override
  String get settingsPanicKeyUnsetSubtitle =>
      'Yksi avain joka pyyhkii kaikki tiedot välittömästi';

  @override
  String get settingsRemovePanicKey => 'Poista paniikkinäppäin';

  @override
  String get settingsRemovePanicKeySubtitle =>
      'Poista hätätuhoutuminen käytöstä';

  @override
  String get settingsRemovePanicKeyBody =>
      'Hätätuhoutuminen poistetaan käytöstä. Voit ottaa sen uudelleen käyttöön milloin tahansa.';

  @override
  String get settingsDisableAppPassword =>
      'Poista sovelluksen salasana käytöstä';

  @override
  String get settingsEnterCurrentPassword =>
      'Syötä nykyinen salasanasi vahvistaaksesi';

  @override
  String get settingsCurrentPassword => 'Nykyinen salasana';

  @override
  String get settingsIncorrectPassword => 'Väärä salasana';

  @override
  String get settingsPasswordUpdated => 'Salasana päivitetty';

  @override
  String get settingsChangePasswordProceed =>
      'Syötä nykyinen salasanasi jatkaaksesi';

  @override
  String get settingsData => 'Tiedot';

  @override
  String get settingsBackupMessages => 'Varmuuskopioi viestit';

  @override
  String get settingsBackupMessagesSubtitle =>
      'Vie salattu viestihistoria tiedostoon';

  @override
  String get settingsRestoreMessages => 'Palauta viestit';

  @override
  String get settingsRestoreMessagesSubtitle =>
      'Tuo viestit varmuuskopiotiedostosta';

  @override
  String get settingsExportKeys => 'Vie avaimet';

  @override
  String get settingsExportKeysSubtitle =>
      'Tallenna identiteettiavaimet salattuun tiedostoon';

  @override
  String get settingsImportKeys => 'Tuo avaimet';

  @override
  String get settingsImportKeysSubtitle =>
      'Palauta identiteettiavaimet viedystä tiedostosta';

  @override
  String get settingsBackupPassword => 'Varmuuskopion salasana';

  @override
  String get settingsPasswordCannotBeEmpty => 'Salasana ei voi olla tyhjä';

  @override
  String get settingsPasswordMin4Chars =>
      'Salasanan on oltava vähintään 4 merkkiä';

  @override
  String get settingsCallsTurn => 'Puhelut ja TURN';

  @override
  String get settingsLocalNetwork => 'Lähiverkko';

  @override
  String get settingsCensorshipResistance => 'Sensuurinkestävyys';

  @override
  String get settingsNetwork => 'Verkko';

  @override
  String get settingsProxyTunnels => 'Välityspalvelin ja tunnelit';

  @override
  String get settingsTurnServers => 'TURN-palvelimet';

  @override
  String get settingsProviderTitle => 'Palveluntarjoaja';

  @override
  String get settingsLanFallback => 'LAN-varayhteys';

  @override
  String get settingsLanFallbackSubtitle =>
      'Lähetä läsnäolotieto ja viestit lähiverkossa kun internet ei ole käytettävissä. Poista käytöstä epäluotettavissa verkoissa (julkinen Wi-Fi).';

  @override
  String get settingsBgDelivery => 'Taustalla toimitus';

  @override
  String get settingsBgDeliverySubtitle =>
      'Vastaanota viestejä kun sovellus on pienennetty. Näyttää pysyvän ilmoituksen.';

  @override
  String get settingsYourInboxProvider => 'Saapuvien palveluntarjoajasi';

  @override
  String get settingsConnectionDetails => 'Yhteystiedot';

  @override
  String get settingsSaveAndConnect => 'Tallenna ja yhdistä';

  @override
  String get settingsSecondaryInboxes => 'Toissijaiset saapuvat';

  @override
  String get settingsAddSecondaryInbox => 'Lisää toissijainen saapuvat';

  @override
  String get settingsAdvanced => 'Lisäasetukset';

  @override
  String get settingsDiscover => 'Etsi';

  @override
  String get settingsAbout => 'Tietoja';

  @override
  String get settingsPrivacyPolicy => 'Tietosuojakäytäntö';

  @override
  String get settingsPrivacyPolicySubtitle => 'Miten Pulse suojaa tietojasi';

  @override
  String get settingsCrashReporting => 'Kaatumisraportointi';

  @override
  String get settingsCrashReportingSubtitle =>
      'Lähetä nimettömiä kaatumisraportteja Pulsen parantamiseksi. Viestisisältöä tai yhteystietoja ei koskaan lähetetä.';

  @override
  String get settingsCrashReportingEnabled =>
      'Kaatumisraportointi käytössä — käynnistä sovellus uudelleen';

  @override
  String get settingsCrashReportingDisabled =>
      'Kaatumisraportointi pois käytöstä — käynnistä sovellus uudelleen';

  @override
  String get settingsSensitiveOperation => 'Arkaluonteinen toiminto';

  @override
  String get settingsSensitiveOperationBody =>
      'Nämä avaimet ovat identiteettisi. Kuka tahansa tämän tiedoston haltija voi esiintyä sinuna. Tallenna turvallisesti ja poista siirron jälkeen.';

  @override
  String get settingsIUnderstandContinue => 'Ymmärrän, jatka';

  @override
  String get settingsReplaceIdentity => 'Korvaa identiteetti?';

  @override
  String get settingsReplaceIdentityBody =>
      'Tämä korvaa nykyiset identiteettiavaimesi. Olemassa olevat Signal-istunnot mitätöidään ja yhteystietojen on muodostettava salaus uudelleen. Sovellus on käynnistettävä uudelleen.';

  @override
  String get settingsReplaceKeys => 'Korvaa avaimet';

  @override
  String get settingsKeysImported => 'Avaimet tuotu';

  @override
  String settingsKeysImportedBody(int count) {
    return '$count avainta tuotu onnistuneesti. Käynnistä sovellus uudelleen alustaaksesi uudella identiteetillä.';
  }

  @override
  String get settingsRestartNow => 'Käynnistä nyt uudelleen';

  @override
  String get settingsLater => 'Myöhemmin';

  @override
  String get profileGroupLabel => 'Ryhmä';

  @override
  String get profileAddButton => 'Lisää';

  @override
  String get profileKickButton => 'Poista';

  @override
  String get dataSectionTitle => 'Tiedot';

  @override
  String get dataBackupMessages => 'Varmuuskopioi viestit';

  @override
  String get dataBackupPasswordSubtitle =>
      'Valitse salasana viestivarmuuskopion salaamiseen.';

  @override
  String get dataBackupConfirmLabel => 'Luo varmuuskopio';

  @override
  String get dataCreatingBackup => 'Luodaan varmuuskopiota';

  @override
  String get dataBackupPreparing => 'Valmistellaan...';

  @override
  String dataBackupExporting(int done, int total) {
    return 'Viedään viestiä $done/$total...';
  }

  @override
  String get dataBackupSavingFile => 'Tallennetaan tiedostoa...';

  @override
  String get dataSaveMessageBackupDialog => 'Tallenna viestivarmuuskopio';

  @override
  String dataBackupSaved(int count, String path) {
    return 'Varmuuskopio tallennettu ($count viestiä)\n$path';
  }

  @override
  String get dataBackupFailed =>
      'Varmuuskopiointi epäonnistui — tietoja ei viety';

  @override
  String dataBackupFailedError(String error) {
    return 'Varmuuskopiointi epäonnistui: $error';
  }

  @override
  String get dataSelectMessageBackupDialog => 'Valitse viestivarmuuskopio';

  @override
  String get dataInvalidBackupFile =>
      'Virheellinen varmuuskopiotiedosto (liian pieni)';

  @override
  String get dataNotValidBackupFile =>
      'Ei kelvollinen Pulse-varmuuskopiotiedosto';

  @override
  String get dataRestoreMessages => 'Palauta viestit';

  @override
  String get dataRestorePasswordSubtitle =>
      'Syötä salasana jolla tämä varmuuskopio luotiin.';

  @override
  String get dataRestoreConfirmLabel => 'Palauta';

  @override
  String get dataRestoringMessages => 'Palautetaan viestejä';

  @override
  String get dataRestoreDecrypting => 'Puretaan salausta...';

  @override
  String dataRestoreImporting(int done, int total) {
    return 'Tuodaan viestiä $done/$total...';
  }

  @override
  String get dataRestoreFailed =>
      'Palautus epäonnistui — väärä salasana tai vioittunut tiedosto';

  @override
  String dataRestoreSuccess(int count) {
    return '$count uutta viestiä palautettu';
  }

  @override
  String get dataRestoreNothingNew =>
      'Ei uusia viestejä tuotavaksi (kaikki ovat jo olemassa)';

  @override
  String dataRestoreFailedError(String error) {
    return 'Palautus epäonnistui: $error';
  }

  @override
  String get dataSelectKeyExportDialog => 'Valitse avainvienti';

  @override
  String get dataNotValidKeyFile => 'Ei kelvollinen Pulse-avainvientitiedosto';

  @override
  String get dataExportKeys => 'Vie avaimet';

  @override
  String get dataExportKeysPasswordSubtitle =>
      'Valitse salasana avainviennin salaamiseen.';

  @override
  String get dataExportKeysConfirmLabel => 'Vie';

  @override
  String get dataExportingKeys => 'Viedään avaimia';

  @override
  String get dataExportingKeysStatus => 'Salataan identiteettiavaimia...';

  @override
  String get dataSaveKeyExportDialog => 'Tallenna avainvienti';

  @override
  String dataKeysExportedTo(String path) {
    return 'Avaimet viety:\n$path';
  }

  @override
  String get dataExportFailed => 'Vienti epäonnistui — avaimia ei löytynyt';

  @override
  String dataExportFailedError(String error) {
    return 'Vienti epäonnistui: $error';
  }

  @override
  String get dataImportKeys => 'Tuo avaimet';

  @override
  String get dataImportKeysPasswordSubtitle =>
      'Syötä salasana jolla tämä avainvienti salattiin.';

  @override
  String get dataImportKeysConfirmLabel => 'Tuo';

  @override
  String get dataImportingKeys => 'Tuodaan avaimia';

  @override
  String get dataImportingKeysStatus =>
      'Puretaan identiteettiavainten salausta...';

  @override
  String get dataImportFailed =>
      'Tuonti epäonnistui — väärä salasana tai vioittunut tiedosto';

  @override
  String dataImportFailedError(String error) {
    return 'Tuonti epäonnistui: $error';
  }

  @override
  String get securitySectionTitle => 'Turvallisuus';

  @override
  String get securityIncorrectPassword => 'Väärä salasana';

  @override
  String get securityPasswordUpdated => 'Salasana päivitetty';

  @override
  String get appearanceSectionTitle => 'Ulkoasu';

  @override
  String appearanceExportFailed(String error) {
    return 'Vienti epäonnistui: $error';
  }

  @override
  String appearanceSavedTo(String path) {
    return 'Tallennettu kohteeseen $path';
  }

  @override
  String appearanceSaveFailed(String error) {
    return 'Tallennus epäonnistui: $error';
  }

  @override
  String appearanceImportFailed(String error) {
    return 'Tuonti epäonnistui: $error';
  }

  @override
  String get aboutSectionTitle => 'Tietoja';

  @override
  String get providerPublicKey => 'Julkinen avain';

  @override
  String get providerRelay => 'Välityspalvelin';

  @override
  String get providerAutoConfigured =>
      'Automaattisesti määritetty palautussalasanastasi. Välityspalvelin löydetty automaattisesti.';

  @override
  String get providerKeyStoredLocally =>
      'Avaimesi tallennetaan paikallisesti turvalliseen tallennustilaan — sitä ei koskaan lähetetä palvelimelle.';

  @override
  String get providerSessionInfo =>
      'Session Network — sipulireititys E2EE. Session ID:si luodaan automaattisesti ja tallennetaan turvallisesti. Solmut löydetään automaattisesti sisäisistä seed-solmuista.';

  @override
  String get providerAdvanced => 'Lisäasetukset';

  @override
  String get providerSaveAndConnect => 'Tallenna ja yhdistä';

  @override
  String get providerAddSecondaryInbox => 'Lisää toissijainen saapuvat';

  @override
  String get providerSecondaryInboxes => 'Toissijaiset saapuvat';

  @override
  String get providerYourInboxProvider => 'Saapuvien palveluntarjoajasi';

  @override
  String get providerConnectionDetails => 'Yhteystiedot';

  @override
  String get addContactTitle => 'Lisää yhteystieto';

  @override
  String get addContactInviteLinkLabel => 'Kutsulinkki tai osoite';

  @override
  String get addContactTapToPaste => 'Napauta liittääksesi kutsulinkin';

  @override
  String get addContactPasteTooltip => 'Liitä leikepöydältä';

  @override
  String get addContactAddressDetected => 'Yhteystiedon osoite tunnistettu';

  @override
  String addContactRoutesDetected(int count) {
    return '$count reittiä tunnistettu — SmartRouter valitsee nopeimman';
  }

  @override
  String get addContactFetchingProfile => 'Haetaan profiilia…';

  @override
  String addContactProfileFound(String name) {
    return 'Löydetty: $name';
  }

  @override
  String get addContactNoProfileFound => 'Profiilia ei löytynyt';

  @override
  String get addContactDisplayNameLabel => 'Näyttönimi';

  @override
  String get addContactDisplayNameHint => 'Mitä haluat kutsua heitä?';

  @override
  String get addContactAddManually => 'Lisää osoite manuaalisesti';

  @override
  String get addContactButton => 'Lisää yhteystieto';

  @override
  String get networkDiagnosticsTitle => 'Verkkodiagnostiikka';

  @override
  String get networkDiagnosticsNostrRelays => 'Nostr-välityspalvelimet';

  @override
  String get networkDiagnosticsDirect => 'Suora';

  @override
  String get networkDiagnosticsTorOnly => 'Vain Tor';

  @override
  String get networkDiagnosticsBest => 'Paras';

  @override
  String get networkDiagnosticsNone => 'ei mitään';

  @override
  String get networkDiagnosticsTor => 'Tor';

  @override
  String get networkDiagnosticsStatus => 'Tila';

  @override
  String get networkDiagnosticsConnected => 'Yhdistetty';

  @override
  String networkDiagnosticsConnecting(int percent) {
    return 'Yhdistetään $percent%';
  }

  @override
  String get networkDiagnosticsOff => 'Pois';

  @override
  String get networkDiagnosticsTransport => 'Kuljetus';

  @override
  String get networkDiagnosticsInfrastructure => 'Infrastruktuuri';

  @override
  String get networkDiagnosticsSessionNodes => 'Session-solmut';

  @override
  String get networkDiagnosticsTurnServers => 'TURN-palvelimet';

  @override
  String get networkDiagnosticsLastProbe => 'Viimeisin testi';

  @override
  String get networkDiagnosticsRunning => 'Käynnissä...';

  @override
  String get networkDiagnosticsRunDiagnostics => 'Suorita diagnostiikka';

  @override
  String get networkDiagnosticsForceReprobe => 'Pakota uudelleentestaus';

  @override
  String get networkDiagnosticsJustNow => 'juuri nyt';

  @override
  String networkDiagnosticsMinutesAgo(int minutes) {
    return '$minutes min sitten';
  }

  @override
  String networkDiagnosticsHoursAgo(int hours) {
    return '$hours h sitten';
  }

  @override
  String networkDiagnosticsDaysAgo(int days) {
    return '$days pv sitten';
  }

  @override
  String get homeNoEch => 'Ei ECH:tä';

  @override
  String get homeNoEchTooltip =>
      'uTLS-välityspalvelin ei käytettävissä — ECH pois käytöstä.\nTLS-sormenjälki näkyy DPI:lle.';

  @override
  String get settingsTitle => 'Asetukset';

  @override
  String settingsSavedConnectedTo(String provider) {
    return 'Tallennettu ja yhdistetty palveluun $provider';
  }

  @override
  String get settingsTorFailedToStart => 'Sisäänrakennettu Tor ei käynnistynyt';

  @override
  String get settingsPsiphonFailedToStart => 'Psiphon ei käynnistynyt';

  @override
  String get verifyTitle => 'Vahvista turvaluku';

  @override
  String get verifyIdentityVerified => 'Identiteetti vahvistettu';

  @override
  String get verifyNotYetVerified => 'Ei vielä vahvistettu';

  @override
  String verifyVerifiedDescription(String name) {
    return 'Olet vahvistanut henkilön $name turvaluvun.';
  }

  @override
  String verifyUnverifiedDescription(String name) {
    return 'Vertaa näitä lukuja henkilön $name kanssa henkilökohtaisesti tai luotettavan kanavan kautta.';
  }

  @override
  String get verifyExplanation =>
      'Jokaisella keskustelulla on ainutlaatuinen turvaluku. Jos molemmat näette samat luvut molemmissa laitteissa, yhteytenne on vahvistettu päästä päähän.';

  @override
  String verifyContactKey(String name) {
    return '$name avain';
  }

  @override
  String get verifyYourKey => 'Sinun avaimesi';

  @override
  String get verifyRemoveVerification => 'Poista vahvistus';

  @override
  String get verifyMarkAsVerified => 'Merkitse vahvistetuksi';

  @override
  String verifyAfterReinstall(String name) {
    return 'Jos $name asentaa sovelluksen uudelleen, turvaluku muuttuu ja vahvistus poistetaan automaattisesti.';
  }

  @override
  String verifyOnlyMarkAfterCompare(String name) {
    return 'Merkitse vahvistetuksi vasta vertailtuasi lukuja henkilön $name kanssa äänipuhelussa tai henkilökohtaisesti.';
  }

  @override
  String get verifyNoSession =>
      'Salausistuntoa ei ole vielä muodostettu. Lähetä ensin viesti turvalukujen luomiseksi.';

  @override
  String get verifyNoKeyAvailable => 'Avainta ei saatavilla';

  @override
  String verifyFingerprintCopied(String label) {
    return '$label-sormenjälki kopioitu';
  }

  @override
  String get providerDatabaseUrlLabel => 'Tietokannan URL';

  @override
  String get providerOptionalHint => 'Valinnainen';

  @override
  String get providerWebApiKeyLabel => 'Web API -avain';

  @override
  String get providerOptionalForPublicDb =>
      'Valinnainen julkiselle tietokannalle';

  @override
  String get providerRelayUrlLabel => 'Välityspalvelimen URL';

  @override
  String get providerPrivateKeyLabel => 'Yksityinen avain';

  @override
  String get providerPrivateKeyNsecLabel => 'Yksityinen avain (nsec)';

  @override
  String get providerStorageNodeLabel => 'Tallennussolmun URL (valinnainen)';

  @override
  String get providerStorageNodeHint =>
      'Jätä tyhjäksi sisäänrakennetuille siemensolmuille';

  @override
  String get transferInvalidCodeFormat =>
      'Tuntematon koodimuoto — täytyy alkaa LAN: tai NOS:';

  @override
  String get profileCardFingerprintCopied => 'Sormenjälki kopioitu';

  @override
  String get profileCardAboutHint => 'Yksityisyys ensin 🔒';

  @override
  String get profileCardSaveButton => 'Tallenna profiili';

  @override
  String get settingsBackupMessagesSubtitleV2 =>
      'Vie salatut viestit, yhteystiedot ja avatarit tiedostoon';

  @override
  String get callVideo => 'Video';

  @override
  String get callAudio => 'Ääni';

  @override
  String bubbleDeliveredTo(String names) {
    return 'Toimitettu: $names';
  }

  @override
  String bubbleDeliveredToCount(int count) {
    return 'Toimitettu $count:lle';
  }

  @override
  String get groupStatusDialogTitle => 'Viestitiedot';

  @override
  String get groupStatusRead => 'Luettu';

  @override
  String get groupStatusDelivered => 'Toimitettu';

  @override
  String get groupStatusPending => 'Odottaa';

  @override
  String get groupStatusNoData => 'Ei vielä toimitustietoja';

  @override
  String get profileTransferAdmin => 'Tee ylläpitäjäksi';

  @override
  String profileTransferAdminConfirm(String name) {
    return 'Tee $name uudeksi ylläpitäjäksi?';
  }

  @override
  String get profileTransferAdminBody =>
      'Menetät ylläpitäjän oikeudet. Tätä ei voi perua.';

  @override
  String profileTransferAdminDone(String name) {
    return '$name on nyt ylläpitäjä';
  }

  @override
  String get profileAdminBadge => 'Ylläpitäjä';

  @override
  String get privacyPolicyTitle => 'Tietosuojakäytäntö';

  @override
  String get privacyOverviewHeading => 'Yleiskatsaus';

  @override
  String get privacyOverviewBody =>
      'Pulse on palvelimeton, päästä päähän salattu pikaviestisovellus. Yksityisyytesi ei ole vain ominaisuus — se on arkkitehtuuri. Pulse-palvelimia ei ole. Tilejä ei tallenneta mihinkään. Kehittäjät eivät kerää, välitä tai tallenna mitään tietoja.';

  @override
  String get privacyDataCollectionHeading => 'Tiedonkeruu';

  @override
  String get privacyDataCollectionBody =>
      'Pulse ei kerää mitään henkilötietoja. Erityisesti:\n\n- Sähköpostia, puhelinnumeroa tai oikeaa nimeä ei vaadita\n- Ei analytiikkaa, seurantaa tai telemetriaa\n- Ei mainostunnisteita\n- Ei yhteystietoluettelon käyttöoikeutta\n- Ei pilvivarmuuskopioita (viestit ovat vain laitteellasi)\n- Metatietoja ei lähetetä Pulse-palvelimelle (niitä ei ole)';

  @override
  String get privacyEncryptionHeading => 'Salaus';

  @override
  String get privacyEncryptionBody =>
      'Kaikki viestit salataan Signal-protokollalla (Double Ratchet X3DH-avainsopimuksella). Salausavaimet luodaan ja tallennetaan yksinomaan laitteellesi. Kukaan — kehittäjät mukaan lukien — ei voi lukea viestejäsi.';

  @override
  String get privacyNetworkHeading => 'Verkkoarkkitehtuuri';

  @override
  String get privacyNetworkBody =>
      'Pulse käyttää yhdistettyjä kuljetusadaptereita (Nostr-välityspalvelimet, Session/Oxen-palvelusolmut, Firebase Realtime Database, LAN). Nämä kuljetukset kuljettavat vain salattua salatekstiä. Välityspalvelinoperaattorit voivat nähdä IP-osoitteesi ja liikennemäärän, mutta eivät voi purkaa viestien sisältöä.\n\nKun Tor on käytössä, IP-osoitteesi on piilotettu myös välityspalvelinoperaattoreilta.';

  @override
  String get privacyStunHeading => 'STUN/TURN-palvelimet';

  @override
  String get privacyStunBody =>
      'Ääni- ja videopuhelut käyttävät WebRTC:tä DTLS-SRTP-salauksella. STUN-palvelimet (julkisen IP:n löytämiseen vertaisyhteyksille) ja TURN-palvelimet (median välittämiseen kun suora yhteys epäonnistuu) voivat nähdä IP-osoitteesi ja puhelun keston, mutta eivät voi purkaa puhelun sisältöä.\n\nVoit määrittää oman TURN-palvelimen Asetuksissa maksimaalista yksityisyyttä varten.';

  @override
  String get privacyCrashHeading => 'Kaatumisraportointi';

  @override
  String get privacyCrashBody =>
      'Jos Sentry-kaatumisraportointi on käytössä (käännösajan SENTRY_DSN kautta), nimettömiä kaatumisraportteja saatetaan lähettää. Ne eivät sisällä viestisisältöä, yhteystietoja tai henkilökohtaisesti tunnistettavia tietoja. Kaatumisraportoinnin voi poistaa käytöstä jättämällä DSN:n pois.';

  @override
  String get privacyPasswordHeading => 'Salasana ja avaimet';

  @override
  String get privacyPasswordBody =>
      'Palautussalasanaasi käytetään kryptografisten avainten johtamiseen Argon2id:n (muistikova KDF) kautta. Salasanaa ei koskaan lähetetä minnekään. Jos menetät salasanasi, tiliäsi ei voi palauttaa — palvelinta sen nollaamiseen ei ole.';

  @override
  String get privacyFontsHeading => 'Fontit';

  @override
  String get privacyFontsBody =>
      'Pulse sisältää kaikki fontit paikallisesti. Google Fontsiin tai muuhun ulkoiseen fonttipalveluun ei tehdä pyyntöjä.';

  @override
  String get privacyThirdPartyHeading => 'Kolmannen osapuolen palvelut';

  @override
  String get privacyThirdPartyBody =>
      'Pulse ei integroidu mihinkään mainosverkostoon, analytiikkapalveluun, sosiaalisen median alustaan tai tietovälittäjään. Ainoat verkkoyhteydet ovat määrittämiisi kuljetusvälityspalvelimiin.';

  @override
  String get privacyOpenSourceHeading => 'Avoin lähdekoodi';

  @override
  String get privacyOpenSourceBody =>
      'Pulse on avoimen lähdekoodin ohjelmisto. Voit auditoida täydellisen lähdekoodin näiden tietosuojaväitteiden todentamiseksi.';

  @override
  String get privacyContactHeading => 'Yhteystiedot';

  @override
  String get privacyContactBody =>
      'Tietosuojaan liittyvissä kysymyksissä avaa issue projektin repositoriossa.';

  @override
  String get privacyLastUpdated => 'Viimeksi päivitetty: maaliskuu 2026';

  @override
  String imageSaveFailed(Object error) {
    return 'Tallennus epäonnistui: $error';
  }

  @override
  String get themeEngineTitle => 'Teemamoottori';

  @override
  String get torBuiltInTitle => 'Sisäänrakennettu Tor';

  @override
  String get torConnectedSubtitle =>
      'Yhdistetty — Nostr reititetään osoitteen 127.0.0.1:9250 kautta';

  @override
  String torConnectingSubtitle(int pct) {
    return 'Yhdistetään… $pct%';
  }

  @override
  String get torNotRunning =>
      'Ei käynnissä — napauta kytkintä käynnistääksesi uudelleen';

  @override
  String get torDescription =>
      'Reitittää Nostrin Torin kautta (Snowflake sensuroiduille verkoille)';

  @override
  String get torNetworkDiagnostics => 'Verkkodiagnostiikka';

  @override
  String get torTransportLabel => 'Kuljetus: ';

  @override
  String get torPtAuto => 'Automaattinen';

  @override
  String get torPtObfs4 => 'obfs4';

  @override
  String get torPtWebTunnel => 'WebTunnel';

  @override
  String get torPtSnowflake => 'Snowflake';

  @override
  String get torPtPlain => 'Tavallinen';

  @override
  String get torTimeoutLabel => 'Aikakatkaisu: ';

  @override
  String get torInfoDescription =>
      'Kun käytössä, Nostr WebSocket -yhteydet reititetään Torin (SOCKS5) kautta. Tor Browser kuuntelee osoitteessa 127.0.0.1:9150. Itsenäinen tor-daemon käyttää porttia 9050. Firebase-yhteyksiin ei vaikuteta.';

  @override
  String get torRouteNostrTitle => 'Reititä Nostr Torin kautta';

  @override
  String get torManagedByBuiltin => 'Hallinnoi sisäänrakennettu Tor';

  @override
  String get torActiveRouting =>
      'Aktiivinen — Nostr-liikenne reititetään Torin kautta';

  @override
  String get torDisabled => 'Pois käytöstä';

  @override
  String get torProxySocks5 => 'Tor-välityspalvelin (SOCKS5)';

  @override
  String get torProxyHostLabel => 'Välityspalvelimen osoite';

  @override
  String get torProxyPortLabel => 'Portti';

  @override
  String get torPortInfo =>
      'Tor Browser: portti 9150  •  tor-daemon: portti 9050';

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
  String get i2pProxySocks5 => 'I2P-välityspalvelin (SOCKS5)';

  @override
  String get i2pInfoDescription =>
      'I2P käyttää oletuksena SOCKS5:tä portissa 4447. Yhdistä Nostr-välityspalvelimeen I2P-outproxyn kautta (esim. relay.damus.i2p) kommunikoidaksesi kaikkien kuljetusten käyttäjien kanssa. Tor on etusijalla kun molemmat ovat käytössä.';

  @override
  String get i2pRouteNostrTitle => 'Reititä Nostr I2P:n kautta';

  @override
  String get i2pActiveRouting =>
      'Aktiivinen — Nostr-liikenne reititetään I2P:n kautta';

  @override
  String get i2pDisabled => 'Pois käytöstä';

  @override
  String get i2pProxyHostLabel => 'Välityspalvelimen osoite';

  @override
  String get i2pProxyPortLabel => 'Portti';

  @override
  String get i2pPortInfo => 'I2P Router oletus-SOCKS5-portti: 4447';

  @override
  String get customProxySocks5 => 'Mukautettu välityspalvelin (SOCKS5)';

  @override
  String get customCfWorkerRelay => 'CF Worker -välityspalvelin';

  @override
  String get customProxyInfoDescription =>
      'Mukautettu välityspalvelin reitittää liikenteen V2Ray/Xray/Shadowsocksin kautta. CF Worker toimii henkilökohtaisena välityspalvelimena Cloudflare CDN:ssä — GFW näkee *.workers.dev, ei oikeaa välityspalvelinta.';

  @override
  String get customSocks5ProxyTitle => 'Mukautettu SOCKS5-välityspalvelin';

  @override
  String get customProxyActive =>
      'Aktiivinen — liikenne reititetään SOCKS5:n kautta';

  @override
  String get customProxyDisabled => 'Pois käytöstä';

  @override
  String get customProxyHostLabel => 'Välityspalvelimen osoite';

  @override
  String get customProxyPortLabel => 'Portti';

  @override
  String get customProxyHint =>
      'V2Ray/Xray: 127.0.0.1:10808  •  Shadowsocks: 127.0.0.1:1080';

  @override
  String get customWorkerLabel => 'Worker-verkkotunnus (valinnainen)';

  @override
  String get customWorkerHelpTitle =>
      'CF Worker -välityspalvelimen käyttöönotto (ilmainen)';

  @override
  String get customWorkerScriptCopied => 'Skripti kopioitu!';

  @override
  String get customWorkerStep1 =>
      '1. Siirry osoitteeseen dash.cloudflare.com → Workers & Pages\n2. Create Worker → liitä tämä skripti:\n';

  @override
  String get customWorkerStep2 =>
      '3. Deploy → kopioi verkkotunnus (esim. my-relay.user.workers.dev)\n4. Liitä verkkotunnus yllä → Tallenna\n\nSovellus yhdistää automaattisesti: wss://domain/?r=relay_url\nGFW näkee: yhteys osoitteeseen *.workers.dev (CF CDN)';

  @override
  String get psiphonTitle => 'Psiphon';

  @override
  String psiphonConnectedSubtitle(int port) {
    return 'Yhdistetty — SOCKS5 osoitteessa 127.0.0.1:$port';
  }

  @override
  String get psiphonConnecting => 'Yhdistetään…';

  @override
  String get psiphonNotRunning =>
      'Ei käynnissä — napauta kytkintä käynnistääksesi uudelleen';

  @override
  String get psiphonDescription =>
      'Nopea tunneli (~3 s käynnistys, 2000+ kiertävää VPS:ää)';

  @override
  String get turnCommunityServers => 'Yhteisön TURN-palvelimet';

  @override
  String get turnCustomServer => 'Mukautettu TURN-palvelin (BYOD)';

  @override
  String get turnInfoDescription =>
      'TURN-palvelimet välittävät vain jo salattuja virtoja (DTLS-SRTP). Välitysoperaattori näkee IP-osoitteesi ja liikennemäärän, mutta ei voi purkaa puheluita. TURN:ia käytetään vain kun suora P2P epäonnistuu (~15–20 % yhteyksistä).';

  @override
  String get turnFreeLabel => 'ILMAINEN';

  @override
  String get turnServerUrlLabel => 'TURN-palvelimen URL';

  @override
  String get turnServerUrlHint => 'turn:your-server.com:3478 tai turns:...';

  @override
  String get turnUsernameLabel => 'Käyttäjätunnus';

  @override
  String get turnPasswordLabel => 'Salasana';

  @override
  String get turnOptionalHint => 'Valinnainen';

  @override
  String get turnCustomInfo =>
      'Aja coturn millä tahansa 5 \$/kk VPS:llä maksimaalista hallintaa varten. Tunnukset tallennetaan paikallisesti.';

  @override
  String get themePickerAppearance => 'Ulkoasu';

  @override
  String get themePickerAccentColor => 'Korostusväri';

  @override
  String get themeModeLight => 'Vaalea';

  @override
  String get themeModeDark => 'Tumma';

  @override
  String get themeModeSystem => 'Järjestelmä';

  @override
  String get themeDynamicPresets => 'Esiasetukset';

  @override
  String get themeDynamicPrimaryColor => 'Ensisijainen väri';

  @override
  String get themeDynamicBorderRadius => 'Reunan pyöristys';

  @override
  String get themeDynamicFont => 'Fontti';

  @override
  String get themeDynamicAppearance => 'Ulkoasu';

  @override
  String get themeDynamicUiStyle => 'Käyttöliittymän tyyli';

  @override
  String get themeDynamicUiStyleDescription =>
      'Ohjaa miltä dialogit, kytkimet ja ilmaisimet näyttävät.';

  @override
  String get themeDynamicSharp => 'Terävä';

  @override
  String get themeDynamicRound => 'Pyöreä';

  @override
  String get themeDynamicModeDark => 'Tumma';

  @override
  String get themeDynamicModeLight => 'Vaalea';

  @override
  String get themeDynamicModeAuto => 'Automaattinen';

  @override
  String get themeDynamicPlatformAuto => 'Automaattinen';

  @override
  String get themeDynamicPlatformAndroid => 'Android';

  @override
  String get themeDynamicPlatformIos => 'iOS';

  @override
  String get providerErrorInvalidFirebaseUrl =>
      'Virheellinen Firebase-URL. Odotettu muoto: https://project.firebaseio.com';

  @override
  String get providerErrorInvalidRelayUrl =>
      'Virheellinen välityspalvelimen URL. Odotettu muoto: wss://relay.example.com';

  @override
  String get providerErrorInvalidPulseUrl =>
      'Virheellinen Pulse-palvelimen URL. Odotettu muoto: https://server:port';

  @override
  String get providerPulseServerUrlLabel => 'Palvelimen URL';

  @override
  String get providerPulseServerUrlHint => 'https://your-server:8443';

  @override
  String get providerPulseInviteLabel => 'Kutsukoodi';

  @override
  String get providerPulseInviteHint => 'Kutsukoodi (jos vaaditaan)';

  @override
  String get providerPulseInfo =>
      'Itse isännöity välityspalvelin. Avaimet johdetaan palautussalasanastasi.';

  @override
  String get providerScreenTitle => 'Saapuvat';

  @override
  String get providerSecondaryInboxesHeader => 'TOISSIJAISET SAAPUVAT';

  @override
  String get providerSecondaryInboxesInfo =>
      'Toissijaiset saapuvat vastaanottavat viestejä samanaikaisesti redundanssia varten.';

  @override
  String get providerRemoveTooltip => 'Poista';

  @override
  String get providerFirebaseUrlHint => 'https://project.firebaseio.com';

  @override
  String get providerNostrRelayHint => 'wss://relay.damus.io';

  @override
  String get providerNostrPrivkeyHint => 'nsec1... tai hex';

  @override
  String get providerNostrPrivkeyHintFull =>
      'nsec1... tai hex yksityinen avain';

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
  String get emojiNoRecent => 'Ei viimeaikaisia emojeja';

  @override
  String get emojiSearchHint => 'Hae emojia...';

  @override
  String get contactTileE2ee => 'E2EE';

  @override
  String get contactTileTapToChat => 'Napauta keskustellaksesi';

  @override
  String get imageViewerSaveToDownloads => 'Tallenna Latauksiin';

  @override
  String imageViewerSavedTo(String path) {
    return 'Tallennettu kohteeseen $path';
  }

  @override
  String get addContactManualHint =>
      'pubkey@wss://relay  ·  05hex…  ·  id@https://...';

  @override
  String get chatOk => 'OK';

  @override
  String get bubbleGifBadge => 'GIF';

  @override
  String get settingsLanguage => 'Kieli';

  @override
  String get settingsLanguageSubtitle => 'Sovelluksen näyttökieli';

  @override
  String get settingsLanguageSystem => 'Järjestelmän oletus';

  @override
  String get onboardingLanguageTitle => 'Valitse kielesi';

  @override
  String get onboardingLanguageSubtitle =>
      'Voit muuttaa tämän myöhemmin Asetuksista';

  @override
  String get videoNoteRecord => 'Tallenna videoviesti';

  @override
  String get videoNoteTapToRecord => 'Napauta tallentaaksesi';

  @override
  String get videoNoteTapToStop => 'Napauta lopettaaksesi';

  @override
  String get videoNoteCameraPermission => 'Kameran käyttöoikeus evätty';

  @override
  String get videoNoteMaxDuration => 'Enintään 30 sekuntia';

  @override
  String get videoNoteNotSupported =>
      'Videomuistiinpanoja ei tueta tällä alustalla';

  @override
  String get navChats => 'Keskustelut';

  @override
  String get navUpdates => 'Päivitykset';

  @override
  String get navCalls => 'Puhelut';

  @override
  String get filterAll => 'Kaikki';

  @override
  String get filterUnread => 'Lukematon';

  @override
  String get filterGroups => 'Ryhmät';

  @override
  String get callsNoRecent => 'Ei viimeaikaisia puheluita';

  @override
  String get callsEmptySubtitle => 'Puheluhistoriasi näkyy täällä';

  @override
  String get appBarEncrypted => 'päästä päähän salattu';

  @override
  String get newStatus => 'Uusi tila';

  @override
  String get newCall => 'Uusi puhelu';
}
