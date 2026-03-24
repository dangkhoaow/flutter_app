/**
 * Optional HTTPS front for the HTTP Elastic Beanstalk API (fixes mixed content from GitHub Pages).
 *
 * Deploy (Cloudflare Workers):
 *   npm create cloudflare@latest  # choose Worker, link account
 *   Replace src/index.js with this file (or merge handlers).
 *   wrangler deploy
 *
 * Then set GitHub secret API_URL to: https://<your-worker>.<subdomain>.workers.dev/api
 * (path must end with /api to match the Flutter client.)
 *
 * Upstream: prefer HTTPS CloudFront in CI (see deploy_web.yml). This worker targets the
 * raw EB origin if you still need an HTTPS shim without CloudFront.
 */
const EB_ORIGIN = 'http://vib-pm-flutter-backend.us-east-1.elasticbeanstalk.com';
const ALLOWED_ORIGIN = 'https://dangkhoaow.github.io';

export default {
  async fetch(request) {
    const corsHeaders = {
      'Access-Control-Allow-Origin': ALLOWED_ORIGIN,
      'Access-Control-Allow-Methods': 'GET,POST,PUT,PATCH,DELETE,OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      'Access-Control-Allow-Credentials': 'true',
      'Access-Control-Max-Age': '86400',
    };

    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: corsHeaders });
    }

    const url = new URL(request.url);
    const target = EB_ORIGIN + url.pathname + url.search;

    const headers = new Headers();
    request.headers.forEach((value, key) => {
      const k = key.toLowerCase();
      if (['host', 'connection', 'content-length', 'transfer-encoding', 'keep-alive'].includes(k)) {
        return;
      }
      headers.set(key, value);
    });

    const init = {
      method: request.method,
      headers,
      redirect: 'manual',
    };
    if (request.method !== 'GET' && request.method !== 'HEAD') {
      init.body = request.body;
    }

    const upstream = await fetch(target, init);
    const out = new Response(upstream.body, upstream);
    Object.entries(corsHeaders).forEach(([k, v]) => out.headers.set(k, v));
    return out;
  },
};
