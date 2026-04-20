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
// Only relays known to accept kind:1059 (gift-wrap DMs). Profile-only relays
// like purplepag.es and aggregators like relay.nostr.band reject writes and
// would cause undelivered messages if picked as primary.
const kBootstrapRelays = [
  'wss://relay.nostr.wirednet.jp',
  'wss://nostr-relay.nokotaro.com',
  'wss://nostr.mom',
  'wss://offchain.pub',
  'wss://nos.lol',
  'wss://nostr.wine',
  'wss://relay.snort.social',
  'wss://nostr.oxtr.dev',
  'wss://relay.nos.social',
  'wss://relay.current.fyi',
  'wss://nostr.fmt.wired.mn',
  'wss://relay.damus.io',
];

/// Provider string for the self-hosted Pulse relay transport.
const kPulseProvider = 'Pulse';
