/// Default Nostr relay used as fallback when no relay is configured or discovered.
///
/// This is the initial relay for new accounts and the fallback when
/// SharedPreferences 'nostr_relay' is not set.  AdaptiveRelayService and
/// RelayDirectoryService may replace it at runtime with a faster/closer relay.
const kDefaultNostrRelay = 'wss://relay.nostr.wirednet.jp';

/// Bootstrap relay list for first-launch probing.  Geographically diverse,
/// sorted roughly by censorship-resistance and uptime.  The setup screen
/// races these in parallel and picks the first to respond — no single relay
/// dependency.
const kBootstrapRelays = [
  'wss://relay.nostr.wirednet.jp',
  'wss://nostr-relay.nokotaro.com',
  'wss://nostr.mom',
  'wss://offchain.pub',
  'wss://nos.lol',
  'wss://relay.nostr.band',
  'wss://nostr.wine',
  'wss://relay.snort.social',
  'wss://purplepag.es',
  'wss://nostr.oxtr.dev',
  'wss://relay.nos.social',
  'wss://relay.current.fyi',
  'wss://strfry.iris.to',
  'wss://nostr.fmt.wired.mn',
  'wss://relay.damus.io',
];

/// Provider string for the self-hosted Pulse relay transport.
const kPulseProvider = 'Pulse';
