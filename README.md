# VIB PM — Flutter Web

Internal project management UI. API base URL is set at **build time** via `--dart-define=API_URL=...` (see `lib/core/api/api_client.dart`).

## GitHub Pages (free)

1. Push to `main`.
2. In the GitHub repo: **Settings → Pages → Build and deployment → Source: GitHub Actions**.
3. Add a repository secret **`API_URL`** with your public API root, e.g. `https://your-backend.example.com/api`.
4. On your API server, set **`CORS_ORIGIN`** to `https://dangkhoaow.github.io` (or `*` for demos only).

App URL (project pages): `https://dangkhoaow.github.io/flutter_app/`

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
