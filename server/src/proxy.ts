import { setGlobalDispatcher, EnvHttpProxyAgent, fetch as undiciFetch } from 'undici';

const proxyUrl =
  process.env.HTTP_PROXY || process.env.http_proxy ||
  process.env.HTTPS_PROXY || process.env.https_proxy;

if (proxyUrl) {
  // EnvHttpProxyAgent reads HTTP_PROXY / HTTPS_PROXY / NO_PROXY automatically
  setGlobalDispatcher(new EnvHttpProxyAgent());
  globalThis.fetch = undiciFetch;
  console.log(`[proxy] Enabled (${proxyUrl})`);
}
