# Changelog — StoryForce.AI

All notable changes to this project. Format loosely follows Keep a Changelog.

---

## [Unreleased] — 2026-07-02

Autonomous 5-phase build-out session (Claude Opus 4.8, local-first routing).
Pushed to `github.com/smagnacca/storyforce-ai.git` @ `6313c86`.

### Added
- **iOS Xcode project** — `code/ios/project.yml` (XcodeGen spec) + generated
  `StoryForce.xcodeproj`. Bundle `ai.storyforce.app`, iOS 16 target, mic-usage
  permission, local-networking ATS. (`d9b52f7`)
- **`IOS_BUILD_READY.md`** — verified build-readiness report + build steps.
- **`EXECUTION_SUMMARY.md`** — 5-phase session summary. (`6313c86`)
- **This CHANGELOG.**

### Fixed
- **Terraform: duplicate output definitions** — `main.tf` redefined 5 outputs
  already declared in `outputs.tf`, causing a hard `terraform validate` failure.
  Removed the block from `main.tf`; `outputs.tf` is now canonical. (`4687aa2`)
- **Terraform: invalid ElastiCache arguments** — `at_rest_encryption_enabled`,
  `auth_token`, and `automatic_failover_enabled` are not valid on
  `aws_elasticache_cluster`. Converted to `aws_elasticache_replication_group`
  and updated endpoint references to `primary_endpoint_address`. (`4687aa2`)

### Verified (local, $0)
- `terraform validate` (v1.15.7) → **Success! Configuration is valid.**
- `swiftc -parse` (Swift 6.1.2) → all 9 SwiftUI files, 0 errors.
- Secret scan → 0 `sk-ant` matches in git history; `.env` untracked.
- Push → local/remote hashes match (`6313c86`).

### Tooling installed
- Terraform 1.15.7 (HashiCorp tap), XcodeGen 2.45.4.

---

## Earlier (pre-session, on `master`)

- `8a511f0` — Phase 1 complete: local backend testing + Fable LLM integration verified.
- `3318734` — Phase 1: Fable LLM integration (story generation, cost tracking,
  error handling, retry logic).
- `6721500` — Sprint hours 0–10: 32 production files.
- `84af995` — Initial commit: repo setup, specs, operational docs.

---

# 🚀 Road to App Store — Open Items

Nothing below is done yet. Grouped by track, roughly in dependency order.

## A. Backend must be live (blocks the app working at all)
- [ ] **AWS account + credentials** configured locally (`aws configure`).
- [ ] **`terraform apply`** — provision VPC, RDS Aurora PG, ElastiCache Redis, S3.
      (Config validates offline; needs creds + a real `plan` review first.)
- [ ] **Deploy backend container** (Dockerfile exists) to ECS Fargate per
      `deployment_checklist` output; run DB migrations.
- [ ] **Real secrets** — replace all test placeholders in production env
      (JWT_SECRET, DB creds, Redis auth token, SendGrid, Google/Gemini keys).
      Keep the real `FABLE_API_KEY` out of git (currently gitignored — good).
- [ ] **HTTPS domain** for the API (ALB + ACM cert).

## B. iOS app — build & wire-up
- [ ] **Install full Xcode.app** (needs ~40 GB free; only 15 GB available now).
- [ ] **Point `apiBaseURL` at the deployed HTTPS backend** — currently
      `http://localhost:3000/api` in `App.swift` (and remove local-networking
      ATS exception once off localhost).
- [ ] **App icon + launch screen** assets (project currently has a blank launch).
- [ ] Build & run on simulator, then a physical device.

## C. Apple Developer / signing
- [ ] **Apple Developer Program** membership ($99/yr).
- [ ] Register **App ID** `ai.storyforce.app`; set `DEVELOPMENT_TEAM` in
      `project.yml` (currently empty).
- [ ] Signing certificate + provisioning profile (automatic signing is set).

## D. App Store Connect + submission
- [ ] Create the app record in **App Store Connect**.
- [ ] **Privacy** — privacy policy URL + App Privacy "nutrition label"
      (declare microphone use and any data collection).
- [ ] Marketing assets — screenshots (all required device sizes), description,
      keywords, support URL, category.
- [ ] **TestFlight** beta round.
- [ ] Archive → upload → **submit for review**.

## E. Pre-launch quality (recommended, not gating)
- [ ] Backend test coverage meets the 70% Jest threshold in CI (`.github/` exists).
- [ ] End-to-end test: signup → generate story → audio record against live API.
- [ ] Error/crash reporting wired (Sentry DSN is a placeholder today).
- [ ] Load/cost check on Fable usage vs `LLM_BUDGET_LIMIT`.
