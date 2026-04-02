// Pulse CF Worker — probe-resistant WebSocket relay proxy
//
// Normal HTTP requests → reverse-proxies COVER_URL (a real website)
// WebSocket + correct secret path → proxies to the target relay
//
// Environment variables (set in Cloudflare dashboard → Settings → Variables):
//   COVER_URL  — real website to proxy (e.g. "https://cooking-blog.com")
//   SECRET     — secret path segment (e.g. "a8f3e2b1") → wss://domain/a8f3e2b1?r=relay_url
//
// GFW sees: normal website on GET, nothing suspicious.
// Only Pulse app knows the SECRET and sends WebSocket upgrade to the right path.

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const secret = env.SECRET || 'change-me';
    const coverUrl = env.COVER_URL || 'https://example.com';

    // ── WebSocket relay ────────────────────────────────────────────────
    // Path must be /<SECRET> and request must be WebSocket upgrade
    if (url.pathname === `/${secret}`) {
      const upgrade = request.headers.get('Upgrade') || '';
      if (upgrade.toLowerCase() !== 'websocket') {
        // Not a WebSocket request on secret path → serve cover site
        return proxyCover(coverUrl, url, request);
      }

      const relay = url.searchParams.get('r');
      if (!relay) {
        // No relay target → serve cover site (don't leak error)
        return proxyCover(coverUrl, url, request);
      }

      // Validate relay URL — must be wss:// or ws://
      let relayUrl;
      try {
        relayUrl = new URL(relay);
        if (relayUrl.protocol !== 'wss:' && relayUrl.protocol !== 'ws:') {
          return proxyCover(coverUrl, url, request);
        }
      } catch {
        return proxyCover(coverUrl, url, request);
      }

      // Proxy WebSocket to target relay
      return proxyWebSocket(relayUrl.toString(), request);
    }

    // ── Cover site ─────────────────────────────────────────────────────
    // Everything else → reverse proxy the cover website
    return proxyCover(coverUrl, url, request);
  }
};

// Reverse-proxy a real website (cover site for probe resistance)
async function proxyCover(coverUrl, originalUrl, request) {
  try {
    const cover = new URL(coverUrl);
    // Preserve the original path and query (so subpages work too)
    const target = new URL(originalUrl.pathname + originalUrl.search, cover);

    const headers = new Headers(request.headers);
    headers.set('Host', cover.host);
    // Remove CF-specific headers that might confuse the origin
    headers.delete('cf-connecting-ip');
    headers.delete('cf-ray');
    headers.delete('cf-visitor');

    const resp = await fetch(target.toString(), {
      method: request.method,
      headers,
      body: request.method !== 'GET' && request.method !== 'HEAD'
        ? request.body
        : undefined,
      redirect: 'follow',
    });

    // Return response with cleaned headers
    const respHeaders = new Headers(resp.headers);
    // Remove CSP/X-Frame-Options that might break the cover site
    respHeaders.delete('content-security-policy');
    respHeaders.delete('x-frame-options');

    return new Response(resp.body, {
      status: resp.status,
      headers: respHeaders,
    });
  } catch {
    // If cover site is down, return a minimal plausible page
    return new Response('<!DOCTYPE html><html><head><title>Welcome</title></head>'
      + '<body><h1>Welcome</h1><p>Page is temporarily unavailable.</p></body></html>', {
      status: 200,
      headers: { 'Content-Type': 'text/html; charset=utf-8' },
    });
  }
}

// Proxy WebSocket connection to relay
async function proxyWebSocket(relayUrl, request) {
  // Create a WebSocket pair — client side goes to the caller, server side we control
  const [client, server] = Object.values(new WebSocketPair());

  // Connect to the upstream relay
  const upstreamResp = await fetch(relayUrl, {
    headers: {
      'Upgrade': 'websocket',
      'Connection': 'Upgrade',
    },
  });

  const upstream = upstreamResp.webSocket;
  if (!upstream) {
    server.close(1011, 'Upstream connection failed');
    return new Response(null, { status: 101, webSocket: client });
  }

  // Accept both sides
  server.accept();
  upstream.accept();

  // Bidirectional relay
  server.addEventListener('message', (event) => {
    try { upstream.send(event.data); } catch { server.close(); }
  });
  upstream.addEventListener('message', (event) => {
    try { server.send(event.data); } catch { upstream.close(); }
  });

  server.addEventListener('close', () => {
    try { upstream.close(); } catch {}
  });
  upstream.addEventListener('close', () => {
    try { server.close(); } catch {}
  });

  server.addEventListener('error', () => {
    try { upstream.close(); } catch {}
  });
  upstream.addEventListener('error', () => {
    try { server.close(); } catch {}
  });

  return new Response(null, { status: 101, webSocket: client });
}
