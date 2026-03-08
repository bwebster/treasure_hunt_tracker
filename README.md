# Treasure Hunt Tracker

Treasure Hunt Tracker is a Rails 8 app for RFID-based scavenger hunt events.  
It ingests scanner events, maps them to configured event locations, computes scores, and powers live registration and display experiences.

## Setup

### Prerequisites

- Ruby `3.3.5` (from `.ruby-version`)
- Node.js `20.11.0` (from `.node-version`)
- PostgreSQL (Postgres 16 is used in `docker-compose.yml`)
- Yarn

### 1) Start Postgres

If you already have local Postgres, ensure it is running and reachable with the defaults in `config/database.yml`.

If not, start Postgres with Docker:

```bash
docker compose up -d db
```

### 2) Install dependencies and prepare the app

```bash
bin/setup --skip-server
```

`bin/setup` installs gems, installs JS dependencies, and runs `bin/rails db:prepare`.

### 3) Start the app (web, CSS watcher, and queue workers)

```bash
bin/dev
```

This starts processes defined in `Procfile.dev`:

- Rails server
- CSS watcher (`yarn watch:css`)
- Solid Queue worker process

### 4) Open key pages

- Leaderboard: `http://localhost:3000/progress`
- Admin dashboard: `http://localhost:3000/admin`
- Jobs dashboard (Mission Control): `http://localhost:3000/jobs`

### Optional: reset database

```bash
bin/rails db:drop db:prepare db:migrate
```

### Optional: seed sample data

```bash
bin/rails db:seed
```

## High-Level Architecture

### Core flow

1. RFID scanners post events to `POST /api/tracking_events`.
2. The API persists a `TrackingEvent`, auto-creates unknown `RfidTag` records, and enqueues `ProcessTrackingEventJob`.
3. The job maps the scan to the correct `Event` and `Location` (Chicago timezone-aware date mapping).
4. `ScoringService` computes and persists score entries in `scores` (with advisory locks for tag-level concurrency safety).
5. UI surfaces (leaderboard, reports, scores, status) query the persisted model state.

### Realtime behavior

- The API broadcasts to Action Cable channels for station behavior.
- `register_channel` handles registration station scan events.
- `display_channel` handles display station scan events.
- Browser channel subscribers redirect station UIs to the right page when matching location events arrive.

### Main domain entities

- `Event`: dated treasure hunt event.
- `Location`: numbered event location; can be marked registration/display.
- `RfidTag`: physical tag identity, optionally associated to a `User`.
- `TrackingEvent`: raw scan payload and mapped location.
- `Score`: computed scoring records with type and source.
- `VoiceSetting` and `WelcomeLine`: TTS behavior and templates.
- `HealthCheck`: scanner heartbeat records by location.

## Features

- Event and location management (including location copy between events).
- RFID tag lifecycle: auto-create on first scan, registration workflow to bind tags to users, and ad-hoc user creation during registration.
- Scoring engine: first scan vs repeat scan behavior, repeat-location bonuses, multi-event bonuses, and test-event support.
- Leaderboard with rank and level titles.
- Public/projection display page with optional spoken score announcements.
- Admin dashboards for tracking events, scores, reports, location/scanner health status, and scan activity charts by time bucket.
- Mission Control Jobs UI for queue introspection.
- Production-only HTTP Basic auth protection for admin routes.

## Third-Party Integrations

- ElevenLabs API for registration/progress speech generation with configurable voice and model settings.
- PostgreSQL as the primary datastore for Rails models, queue DB, and cable DB.
- Action Cable for WebSocket-based realtime station workflows.
- Mission Control Jobs for queue/job administration at `/jobs`.
- DigitalOcean, Terraform, and Kamal for infrastructure/deployment workflows (see `infra/` and `config/deploy.yml`).

## API and Important Routes

- `POST /api/tracking_events`: ingest RFID scan events.
- `GET /api/health_checks?l=<location_number>`: scanner heartbeat endpoint.
- `GET /progress`: leaderboard.
- `GET /display`: station display view.
- `GET /register`: registration station view.
- `GET /status`: system/scanner health status.
- `GET /admin`: admin landing page.
- `GET /jobs`: Mission Control Jobs UI.

## Developer Workflow

### Run tests

```bash
bin/rspec
```

### Simulate traffic and devices

```bash
bin/rake simulate:one
bin/rake simulate:many COUNT=50
bin/rake simulate:display_scan
bin/rake simulate:health_checks
```

### Send a single tracking event manually

```bash
bin/send_event <RFID_ID> <LOCATION_NUMBER> <SCANNED_AT_ISO8601>
```

Note: the helper script targets `http://localhost:5000/api/tracking_events` by default.  
If your Rails server is on port 3000, update the script or use the rake simulation tasks.

## Configuration Notes

- `DATABASE_*` env vars can override DB defaults in `config/database.yml`.
- `SCORING_*` env vars control scoring constants in `ScoringService`.
- `BASIC_AUTH_USERNAME` and `BASIC_AUTH_PASSWORD` are used for admin auth in production.
- ElevenLabs API key is managed via `VoiceSetting` in the app UI.
