# VIB PM — Flutter Web

Internal project management UI. API base URL is set at **build time** via `--dart-define=API_URL=...` (see `lib/core/api/api_client.dart`).

## GitHub Pages (free)

1. Push to `main`.
2. In the GitHub repo: **Settings → Pages → Build and deployment → Source: GitHub Actions**.
3. **API URL (build-time):** The workflow bakes in `API_URL` with this priority: secret **`API_URL`** → variable **`PUBLIC_API_URL`** → default **`http://vib-pm-flutter-backend.us-east-1.elasticbeanstalk.com/api`** (see `.github/workflows/deploy_web.yml`).
4. On your API server, set **`CORS_ORIGIN`** to `https://dangkhoaow.github.io` (or `*` for demos only).

App URL (project pages): `https://dangkhoaow.github.io/flutter_app/`

### HTTPS / mixed content

GitHub Pages is served over **HTTPS**. Browsers **block** `fetch`/XHR from that page to an **HTTP** API (mixed content). The default Elastic Beanstalk URL is **HTTP only**. If login still fails after a rebuild, open DevTools → Console and look for **mixed content** errors.

**Fix:** expose the API on **HTTPS** (e.g. Elastic Beanstalk **load balancer + ACM certificate**, **CloudFront** in front of EB, or **Cloudflare** “Flexible” SSL to the origin), then set repository secret **`API_URL`** to `https://your-host/api` and run the Pages workflow again.

**Quick HTTPS shim:** deploy **`infra/cloudflare-worker-proxy.js`** as a [Cloudflare Worker](https://developers.cloudflare.com/workers/) (free tier), then set secret **`API_URL`** to `https://<your-worker>.<account>.workers.dev/api` and re-run the workflow. The worker forwards to the HTTP EB origin and adds CORS for `https://dangkhoaow.github.io`.

The `web/` folder includes **`manifest.json`**, **`favicon.png`**, and **`icons/`** so PWA assets are not 404 on Pages.

## Backend + database (low cost)

This app expects the **Node/Express + PostgreSQL** API from the monorepo `backend/` folder.

- **Same VM (e.g. AWS Lightsail)**: Yes — you can install PostgreSQL and Node on one instance; point `DB_HOST=localhost` and run `npm run migrate && npm start`. That is a common demo setup.
- **Elastic Beanstalk**: The free tier applies to **EC2 hours** (12 months for new accounts), not a permanent $0 Beanstalk stack. Beanstalk runs your app on EC2; **RDS is separate**. For minimum cost, use **one Lightsail/EC2 instance** with Postgres installed locally, or **RDS free tier** if still eligible — not both required on one “Beanstalk box” unless you install Postgres on the same EC2 (advanced; snapshots/backups are your responsibility).

## Local web build

```bash
flutter pub get
flutter build web --release --base-href / --dart-define=API_URL=http://localhost:3000/api
```

Serve `build/web` with any static host.
