# VIB PM — Flutter Web

Internal project management UI. API base URL is set at **build time** via `--dart-define=API_URL=...` (see `lib/core/api/api_client.dart`).

## GitHub Pages (free)

1. Push to `main`.
2. In the GitHub repo: **Settings → Pages → Build and deployment → Source: GitHub Actions**.
3. **API URL (build-time):** The workflow bakes in `API_URL` with this priority: secret **`API_URL`** → variable **`PUBLIC_API_URL`** → default **`https://d37sgtpogq8cml.cloudfront.net/api`** (CloudFront in front of the API; see `.github/workflows/deploy_web.yml`).
4. On your API / CloudFront origin, allow **`CORS_ORIGIN`** = `https://dangkhoaow.github.io` (or `*` for demos only).

App URL (project pages): `https://dangkhoaow.github.io/flutter_app/`

**E2E check:** API health should respond at [https://d37sgtpogq8cml.cloudfront.net/health](https://d37sgtpogq8cml.cloudfront.net/health) (`{"ok":true}`). After a workflow run, the Flutter app calls **`/api/...`** on that same host.

### HTTPS / overrides

GitHub Pages is **HTTPS**; the default API URL is **HTTPS (CloudFront)**, so browsers allow `fetch`/XHR for normal E2E. To point at another host, set secret **`API_URL`** or variable **`PUBLIC_API_URL`** to `https://your-host/api` and re-run the workflow.

**Optional:** **`infra/cloudflare-worker-proxy.js`** is only needed if you still serve the browser from HTTPS but the API is HTTP-only without CloudFront.

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
