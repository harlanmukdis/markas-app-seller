# docs

## `API-SELLER-APP.md` — **missing, please add**

The seller API contract (CodeIgniter 3 + MySQL + JWT, ~80 endpoints across 16
groups) belongs here as `docs/API-SELLER-APP.md`. `CLAUDE.md` points at that
path.

The copy used to build the current integration arrived pasted into a chat and
its characters were mangled in transit (UTF-8 read as CP1252 — em dashes became
`â€”`, emoji became `ðŸ"„`). Rather than commit a corrupted reference, drop the
original file here.

Its companion document, `API-MEMBER-APP.md`, covers the buyer side and lives in
the `markas-app-member` repo.

## What was built from it

Section 1 (conventions), section 2 (seller data scoping), section 3 (the four
activation gates) and sections 5.1–5.3 (auth, seller profile and onboarding,
shipping rates) are implemented. See *Seller API integration* in `CLAUDE.md`.
