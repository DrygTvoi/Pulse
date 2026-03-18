/// Default Nostr relay used as fallback when no relay is configured or discovered.
///
/// This is the initial relay for new accounts and the fallback when
/// SharedPreferences 'nostr_relay' is not set.  AdaptiveRelayService and
/// RelayDirectoryService may replace it at runtime with a faster/closer relay.
const kDefaultNostrRelay = 'wss://relay.damus.io';
