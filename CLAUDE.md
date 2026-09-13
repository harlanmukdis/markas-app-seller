# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **This document has two parts, and they do not describe the same thing.**
> **Part 1 — Current state** is what the code actually is today; verified against the repo.
> **Part 2 — Target architecture** is where the project is headed. It is now **partly built** — the migration checklist marks what landed.
> Never run a command or follow a pattern from Part 2 until the corresponding migration step is done. If the two parts conflict, Part 1 wins for any change you make right now.

## Project identity

Flutter e-commerce **seller app**, duplicated from `markas-app-member` on 2026-09-05 and rebranded. Both projects descend from the same purchased UI kit, so the sample code under `lib/features/` is identical in the two trees.

- Directory: `marketplace-app-seller` (renamed from `markas-app-seller` on 2026-09-13, when the backend was replaced)
- Dart package name (`pubspec.yaml`): **`navy_wear`** — absolute imports are `package:navy_wear/...`. Renaming this breaks every absolute import plus `test/widget_test.dart`. **Deliberately left identical to `markas-app-member`** so a widget or cubit can be copied between member and seller without rewriting imports. Do not rename it in only one of the two projects.
- Product name / bundle id: **Marketplace Seller** / `com.marketplace.seller` (Android `namespace` + `applicationId`, iOS + macOS `PRODUCT_BUNDLE_IDENTIFIER`), and `MaterialApp.title`. The member app keeps its own id, so both can be installed on one device.
- Android `MainActivity.kt` lives at `android/app/src/main/kotlin/com/marketplace/seller/` and declares `package com.marketplace.seller` — this must stay in sync with the gradle `namespace`, because `AndroidManifest.xml` refers to the activity as the relative `.MainActivity`.

---

# Part 1 — Current state

## Commands

```bash
flutter pub get                       # install dependencies
flutter run -d chrome                 # the target platform for this app (see below)
flutter run                           # run on connected device/emulator
flutter analyze                       # static analysis (flutter_lints 4.0.0 via analysis_options.yaml)
flutter test                          # run all tests
flutter test test/widget_test.dart    # run a single test file
flutter test test/widget_test.dart --plain-name 'Counter increments smoke test'   # single test case
flutter build apk --release           # Android
flutter build ios --release           # iOS
```

Regenerate localizations after editing `lib/l10n/*.arb`:

```bash
dart run intl_utils:generate          # requires: dart pub global activate intl_utils (not a declared dev_dependency)
```

There is **no `build_runner` step in this repo** — no `freezed`, `json_serializable`, or `envied` is installed. This is deliberate, not merely unfinished: see *Seller API integration* below.

Point the app at a different backend without editing code:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api/v1
flutter run -d chrome --dart-define=LOG_HTTP=false      # silence the request log
```

`intl` is pinned to `^0.20.2`. Flutter 3.41's bundled `flutter_localizations` requires exactly `0.20.2`, and the kit's original `^0.19.0` made `flutter pub get` fail outright.

## Architecture

**Two architectures coexist in `lib/` right now, on purpose.**

- The **UI kit** (`lib/features/auth`, `home`, `my_cart`, `favorites`, `trending`, `onboarding`, `profile`, `spalsh`, `notifications&messages`, `shared`) still has no backend. `HomePageCubit.productsTShirt` and friends are hardcoded lists. Nothing about it changed.
- The **seller app** (`lib/config`, `lib/core/data`, `lib/core/domain`, `lib/di`, `lib/features/seller_*`) talks to the marketplace API and follows the Part 2 layering. New seller work goes here.

When the two conflict, follow the seller-app conventions for anything touching the API, and the kit's conventions for anything touching its screens. Do not retrofit one onto the other file by file.

### Marketplace API integration

Backend: CodeIgniter 3 + MySQL + JWT at **`http://localhost:8000/api/v1`**. The contract lives in `~/Desktop/Harlan/marketplace-api` — `docs/03-api-documentation.md` for the endpoint map and `postman/Marketplace-API.postman_collection.json` for real request bodies, which is the more reliable of the two.

**This replaced a completely different backend on 2026-09-13.** The app previously talked to Markas Bangunan, a building-material marketplace with one store per account. Everything domain-specific to that — SKU master, price tiers, zone/fleet shipping tariffs, proof of delivery, returns and disputes, the four activation gates — was deleted rather than adapted, because none of it has a counterpart here. Git history before that date is the reference if any of it is ever needed.

What changed conceptually, and why it touches everything:

- **An account is not a store.** Every account registers as a buyer and becomes a seller by opening a store, and it can own several. `SessionStore.activeStoreId` is a UI choice, not an identity — losing it logs nobody out, it just means the app has to ask which store to open. `StoreCubit` is provided **above the router** in `main.dart` for exactly this reason: go_router reuses the home page, so a cubit owned by that page would never reload and a newly created store would stay invisible.
- **`X-Store-Id` accompanies the bearer token** on every store-scoped call. `AuthInterceptor` adds it from the stored active store unless the caller set it explicitly. Forgetting it produces a 403 that reads like a permission bug.
- **The session response carries no identity at all** — no user id, no role, no store. `GET /me` is the only source of all three, so `AuthRepositoryImpl.login` follows a successful login with a profile read and caches it.
- **The access token lives 15 minutes** (`expires_in: 900`), not two hours. Refresh is routine rather than rare, which is why `AuthInterceptor` stays a `QueuedInterceptor`.
- **Registration does not log you in.** It creates the account and returns `dev_verification_token` in a dev build; the email has to be verified before login works. `SellerAuthCubit.register` chains register → verify → login so the flow completes without a mailbox.
- **There is a file upload endpoint** — `POST /media/upload`, multipart with a single `file` part. The previous backend had none, which blocked every document and photo feature.

Rules that carry over unchanged, because they were never about that backend:

- **Never cast a JSON value directly.** This backend also hands MySQL columns to `json_encode`, so `"id": "2"`, `"rating_avg": "0.00"` and `"email_verified": "0"` are normal. Every model reads through `lib/core/utils/json_parse.dart`; `test/core/json_parse_test.dart` pins the behaviour.
- **Services throw, repositories don't.** `RepositoryGuard.guard` turns an `ApiException` into `DataFailed`, and an empty collection into `DataEmpty`.
- **Cubits pull repositories with `injector<XRepository>()`** and expose `static XCubit get(context)`. Action methods return `DataError?` rather than emitting an error state, so a form keeps what was typed.
- **Adding an endpoint** means: path constant in `api_endpoints.dart` -> method on a `*Service` -> method on the abstract repository -> implementation via `guard` -> registration in `injector_service.dart` / `injector_repository.dart`, **in that dependency order**.

**Where the docs and the server disagree, the server wins.** Found by testing against the running backend:

- 🔴 **The backend sends no CORS headers at all, and answers `OPTIONS` with 405.** A browser cannot call it cross-origin, which blocks the web build outright — the previous backend answered preflight with 204 and open headers. Until the backend adds CORS (including `X-Store-Id` in `Access-Control-Allow-Headers`), the web build has to be served from the same origin as the API. There is a dev proxy for this in the session scratchpad; production needs either CORS or same-origin hosting.
- **`POST /media/upload` returns a URL on a host that does not serve.** It builds `http://localhost:8080/marketplace-api/uploads/...` from its own config while the file is actually served by the API host. `normaliseUploadUrl` in `media_service.dart` rewrites it; the test pins both the rewrite and the no-op cases.
- **`GET /stores/{id}` answers `STORE_NOT_FOUND` for an inactive store, even to its owner.** It is the public profile. An owner's own store is only visible through `GET /stores`, which is why `StoreService.getMyStores` exists.
- **A store opens `inactive`** and cannot sell until verified. `POST /stores` answers `{ "id": N }`, not the created row.
- **The slug is assigned, not requested** — the server appends a uniqueness suffix, so the address that exists differs from the name that was typed.
- **The database is being actively rebuilt by the backend team.** It was reset mid-session: accounts that worked minutes earlier started failing with `INVALID_CREDENTIALS`, and a fresh registration came back with `user_id: 2` after previously reaching 35. Before concluding the app broke something, register a new account and see whether that works.

What is implemented: auth (register → verify → login, refresh, logout), the account profile, store list/create/settings and the active-store context, and file upload. Products, inventory, orders, wallet, chat, promotions and the rest of the 32 modules are **not** started.
### Feature-first layout

```
lib/core/       # cross-cutting: routes, theme, styles, constants, cached prefs, shared widgets
lib/features/<feature>/data/models/
lib/features/<feature>/presentation/{cubits,views,views/widgets}
lib/generated/  # Flutter Intl output — DO NOT EDIT
lib/l10n/       # .arb translation sources
```

The seller features (`seller_auth`, `seller_store`, `seller_home`, `seller_shell`) use the same `presentation/{cubits,views,views/widgets}` shape but keep **no** `data/` subtree — their models and repositories are centralised under `lib/core/domain` and `lib/core/data`, per the target architecture.

The convention is applied loosely: `favorites`, `trending`, and `spalsh` are single files with no `presentation/` layer. Directory names contain typos that are part of the real paths — `spalsh` (splash), `presentaion` (profile only), and `notifications&messages` (literal `&`). Match the existing spelling rather than "fixing" it, or every import breaks.

### State: Cubits with mutable fields, not immutable state

`flutter_bloc` cubits are created **locally** — each view wraps its own body in `BlocProvider(create: ...)` inside `build()`. There is no global provider and no DI container.

Cubits hold **public mutable fields** (`currentIndex`, `products`, controllers) and emit **marker states** that carry no data (`class HomeChangeBottomNav extends HomeLayoutState {}`). `BlocBuilder` reacts to the emit, then reads the field off the cubit. Follow this pattern; do not convert to data-carrying states piecemeal. (Part 2 replaces this with freezed sealed unions — a deliberate, project-wide migration, not a per-file change.)

Every cubit exposes `static XCubit get(context) => BlocProvider.of(context);` — used as `HomePageCubit.get(context)`.

**The seller cubits do not follow the marker-state pattern.** They emit hand-written sealed states that carry their data (`OnboardingLoadSuccess`, `ShippingRateLoadFailure`, …) and are consumed with an exhaustive `switch`. That is the intended end state for the whole app; the kit's cubits are simply not migrated yet.

`MyBlocObserver` (`lib/core/utils/bloc_observer.dart`) logs all cubit lifecycle in debug.

`lib/core/cubits/app_cubit.dart` (`AppCubit`) is **dead code** — never provided or referenced. The live theme toggle is the top-level function in `components.dart` (below).

### Navigation: go_router, one flat table

All routes live in one file, [app_routes.dart](lib/core/utils/app_routes.dart): an `AppRoutes` class of path string constants plus a single flat `GoRouter` route list. Every route uses `FadeThroughTransitionPageWrapper` for a consistent transition. Arguments are passed untyped via `state.extra` and cast (`state.extra! as String`).

The `router` object is global and often called directly (`router.go(AppRoutes.onboarding)` in the splash screen) rather than through `context.go`. Adding a screen = add a constant to `AppRoutes` + a `GoRoute` entry with the wrapper.

Note: `AppRoutes.contactUs` is registered twice; the first entry wins.

### Theming: preferences-driven, not `Theme.of(context)`

This is the most important convention to get right. `lightTheme`/`darkTheme` exist in [app_theme.dart](lib/core/utils/app_theme.dart), but **widgets almost never read `Theme.of(context)`**. Instead every color decision is written inline as:

```dart
color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
```

`isAppDarkMode()` reads SharedPreferences **synchronously** via `CachedHelper.getData(kAppTheme)`. Colors are `k`-prefixed constants in [constant.dart](lib/core/utils/constant.dart). New UI should use these constants + `isAppDarkMode()`, not theme lookups.

**Theme and language changes restart the app.** `toggleAppTheme()` / `changeAppLanguage()` in [components.dart](lib/core/function/components.dart) persist the value then call `Phoenix.rebirth(context)`. This is why `CachedHelper.init()` must complete before `runApp` in [main.dart](lib/main.dart) — the whole app reads prefs synchronously at build time.

### Text and spacing helpers

- **Text**: `AppStyles.styleSemiBold16(context)` etc. in [app_styles.dart](lib/core/utils/app_styles.dart). Every style takes `context` because font size is scaled by `getResponsiveFontSize()` against a 375pt base width, clamped to ±20%. Never hardcode a `TextStyle` with a raw `fontSize`.
- **Spacing**: extensions in [extensions.dart](lib/core/utils/extensions.dart) — `16.pa`, `16.ps`/`.pe` (start/end), `.pt`/`.pb`, `.psh`/`.psv` all return **`EdgeInsetsDirectional`** (RTL-aware — important, Arabic is supported). Gaps use `12.sbh` / `12.sbw` for `SizedBox`. Screen size via `context.screenWidth` / `context.screenHeight`.
- **Assets**: referenced through `AppImages` constants; `assets/images/` and `assets/icon/` are glob-registered in `pubspec.yaml`, so new files need only an `AppImages` entry.
- **App bar**: `customAppBar(context, title, action: ...)` in [custom_app_bar.dart](lib/core/function/custom_app_bar.dart).
- **States**: `LoadingIndicatorView`, `ErrorStateView`, `EmptyStateView`, `showErrorSnackBar`, `showSuccessSnackBar` in [state_widgets.dart](lib/core/widgets/state_widgets.dart). Use these rather than hand-rolling a spinner, so every API failure is reported the same way.
- **Forms**: `AppDropdownField<T>` in [app_dropdown_field.dart](lib/core/widgets/app_dropdown_field.dart) for closed-list fields, and `Validators` in [validators.dart](lib/core/utils/validators.dart). Several backend fields accept only a fixed list (doc types, fleet codes, cancellation reasons) — a free-text box just produces 422s.
- **Numbers and dates**: `formatRupiah`, `formatThousands`, `formatDate`, `formatDateTime`, `parseRupiahInput` in [format_helper.dart](lib/core/utils/format_helper.dart). These avoid `intl`'s locale-aware formatters on purpose — a missing `id_ID` dataset throws at runtime on web. Amounts are whole rupiah; the server rounds and there are no cents.
- **Note**: `CustomTextFormField`'s default validator returns Arabic text (`'هذا الحقل مطلوب'`). Always pass an explicit `validator` — pass `Validators.optional` for a field that is genuinely optional or is a helper input (a search box, a URL box consumed by a button). Any such field inside a `Form` blocks submission when empty, and the message is unreadable to the user: it is what silently broke the first build of the product-create screen.

### Localization

Generated by the **Flutter Intl IDE plugin** (Localizely), not `flutter gen-l10n`. `lib/generated/l10n.dart` and `lib/generated/intl/*` are generated — edit `lib/l10n/*.arb` and regenerate. Usage in views: `final l = S.of(context); ... l.home`.

Adding a language: add `lib/l10n/intl_<code>.arb`, regenerate, then add a `LanguageModel` to `supportedLanguages` in [language_model.dart](lib/features/shared/models/language_model.dart) (this list drives the settings picker and RTL direction, and is separate from `S.delegate.supportedLocales`).

Current state: `en` and `ar` are complete (284 keys) and selectable. `fr` appears in `S.delegate.supportedLocales` but `intl_fr.arb` is **empty** and `fr` is not in `supportedLanguages` — so device-locale French resolves to a locale with no translations. Either fill it in or drop it.

## Known rough edges

- **Assets are still missing, and the app renders wrong because of it.** `assets/images/` and `assets/icon/` now exist but contain only a `.gitkeep` — the UI kit's real files were never copied over from `markas-app-member`. Any kit screen that renders an `AppImages` path shows a missing-asset error. The seller screens are asset-free by design and are unaffected.
- **The kit's custom font is disabled.** `assets/fonts/Hanimation_Arabic_Regular.otf` is not in the repo, and a declared-but-missing font file fails asset bundling and blocks `flutter build` entirely, so the `fonts:` block in `pubspec.yaml` is commented out. `kFontFamily = 'Hanimation'` is still referenced in the theme; an unregistered family falls back to the platform default silently. Restore the `.otf` and uncomment to get the kit's typography back.
- **The router's `initialLocation` is `SellerRoutes.bootstrap` (`/`), not `AppRoutes.splash`.** The kit's animated splash renders four SVGs from the missing `assets/images/`, so it cannot be the entry point. `SellerBootstrapView` decides between the seller login and the onboarding dashboard based on the stored session. Every kit route stays registered and reachable.
- `test/widget_test.dart` (the Flutter counter template, which failed) has been **replaced**. `flutter test` now runs 42 real tests covering the tolerant JSON parsers, model parsing against payloads captured from the live server, zone-hierarchy labelling, and envelope/error handling. It is a genuine signal — keep it green.
- `lib/features/my_cart/presentation/views/map_screen.dart` is 100% commented out, and the `com.google.android.geo.API_KEY` meta-data in `android/app/src/main/AndroidManifest.xml` is commented out too. Restoring the map needs both, plus an iOS key. Location permissions are already declared in the manifest.
- `DevicePreview` wraps the app when `kDebugMode`, so debug builds render inside a simulated device frame — layout that looks wrong in debug may be the preview frame, not the code.
- Orientation is locked to portrait in `main()`.
- `flutter_launcher_icons` and `flutter_native_splash` config blocks in `pubspec.yaml` are commented out, though `flutter_launcher_icons.yaml` / `flutter_native_splash.yaml` exist at the root.

---

# Part 2 — Target architecture

**Status: partly implemented.** The layering, DI and result-wrapper landed with the seller API integration; the codegen did not, deliberately.

Present: `lib/config/`, `lib/di/`, `lib/core/data/`, `lib/core/domain/`, `lib/core/data_state.dart`, the named `"api"` Dio singleton, `lib/config/route/app_route_seller.dart`.

Still absent, by choice: `freezed` / `json_serializable` / `build_runner` / `envied` and any `*.freezed.dart` / `*.g.dart`. Models and cubit states are hand-written; env config is `String.fromEnvironment` rather than `.env` + `envied`, which needs no build step and works identically on web.

Still absent, not yet done: `lib/ui/`, and any migration of the UI kit's own features. No Firebase, no `.env`, no `lib/firebase_options.dart`.

This is the layering the project is being moved toward: **data → domain → presentation** per feature, wired with `get_it` for DI and `go_router` for navigation.

## Additional commands (only if codegen is adopted later)

**Not applicable today** — there is no `build_runner` in this project and the seller integration was built without one. If `freezed` + `json_serializable` are adopted later, every change to a model or cubit state file gains a regeneration step:

```bash
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs   # while iterating
```

Env config today is `lib/config/env/app_config.dart` reading `String.fromEnvironment` — override with `--dart-define`, no `.env` and no `envied`. Add a new constant there per base URL / API key as feature domains are added.

## Target layout

```
lib/
  config/         # env, network (Dio), routing, theming
  core/
    data/
      datasources/remote/service/   # Dio-based *Service classes, one per API
      repositories/                 # *RepositoryImpl — calls Service, wraps result in DataState<T>
    domain/
      model/        # freezed/json_serializable models, grouped per API
      repositories/ # abstract repository interfaces consumed by cubits
    data_state.dart # DataState<T> result wrapper: DataLoading/DataSuccess/DataEmpty/DataFailed(DataError)
  di/               # get_it registration, split into injector (Dio client) / injector_service / injector_repository
  ui/
    main/           # shared shell: splash, login, register, home, profile + their cubits
    <feature>/<subfeature>/{cubit,screens,widgets}/   # new feature domains use this layout
  util/             # format_helper, list_slice_extension
```

## Conventions to preserve once migrated

**DI wiring order matters.** `lib/di/injector.dart` registers one **named** `Dio` singleton (`"api"` — see `DioClient` in `lib/config/network/dio_client.dart`), then calls `initializeService()` (services take the named Dio instance), then `initializeRepository()` (repositories take the services). New services/repositories must be registered in `injector_service.dart` / `injector_repository.dart` **in that same dependency order**, and `initialize()` must run before `runApp` in `main.dart`. When adding a feature domain that calls its own API, register another named `Dio` singleton here (see the example comments in `dio_client.dart` / `injector.dart`).

**Repositories never throw.** Every repository method wraps its service call in try/catch and returns `DataState<T>` (`DataSuccess` / `DataFailed(DataError(...))`), so cubits pattern-match on state instead of using try/catch for control flow. Follow this for every new repository method.

**Services own caching and raw HTTP errors.** `*Service` classes are the layer that catches `DioException` and rethrows a plain `Exception` with context. For expensive per-ID lookups, keep an in-memory `Map<int, Model>` cache (see the `PokemonService` pattern in the origin GameHub project) and chunk calls into `Future.wait` batches rather than firing unbounded concurrent requests.

**Cubits use freezed sealed state.** Each feature's `*_state.dart` is an `@freezed` union (initial/loading/loaded/error or similar), declared via `part 'x_state.dart'; part 'x_cubit.freezed.dart';` in the cubit file. Cubits pull their repository directly with `injector<XRepository>()` — **not** constructor injection — and are provided to widgets via `BlocProvider`/`BlocBuilder` from `flutter_bloc`.

**Routes split per domain, combined into one `GoRouter`.** `lib/config/route/app_route.dart` holds the shared shell routes; spread a new `appRouterMyFeature` from its own `app_route_myfeature.dart`, following the marked example pattern. Add new feature routes to that domain file, **not** directly into `app_route.dart`.

## Migration checklist (current → target)

1. ~~Add `freezed_annotation`, `json_annotation`, `envied` + generators.~~ **Dropped deliberately.** Models and states are hand-written; see *Seller API integration*. Revisit only if `copyWith`/equality boilerplate becomes the bottleneck.
2. ~~Create `lib/config/env/env.dart` + `.env`.~~ **Done differently** — `lib/config/env/app_config.dart` with `String.fromEnvironment`, overridable via `--dart-define`. No `.env` file exists or is needed.
3. ~~Create `lib/config/network/dio_client.dart` with the named `"api"` Dio singleton.~~ **Done**, plus `auth_interceptor.dart` (queued, auto-refresh), `api_envelope.dart`, `api_exception.dart`, `api_endpoints.dart`.
4. ~~Add `lib/core/data_state.dart` with the `DataState<T>` union.~~ **Done**, with `DataError` and `DataErrorCode` alongside it.
5. ~~Build `lib/di/{injector,injector_service,injector_repository}.dart` and call `initialize()` before `runApp`.~~ **Done** — `main()` runs `CachedHelper.init()` then `initialize(onSessionExpired: …)`.
6. **Partly done.** The *seller* domain is fully behind `*Service` + `*RepositoryImpl` (auth, seller, shipping rates). The UI kit's hardcoded lists (`HomePageCubit.productsTShirt` and friends) are untouched — and note the kit sells fashion, so most of it has no counterpart in the seller API and will likely be deleted rather than wired up.
7. **Partly done.** Seller cubits emit hand-written sealed states carrying data. The kit's marker states are unchanged.
8. **Started.** `lib/config/route/app_route_seller.dart` holds `SellerRoutes` + `appRouterSeller`, spread into the single `GoRouter` in [app_routes.dart](lib/core/utils/app_routes.dart). The kit's routes are still a flat table in that file.
9. **Not started.** `lib/features/` vs `lib/ui/` is still undecided. Seller features currently live under `lib/features/seller_*`.

### Remaining API surface

The marketplace API exposes 32 modules and roughly 223 endpoints; the seller app needs a fraction of them. Build in this order, since each depends on the last: **store verification** (submit + documents, using `/media/upload`) -> **product catalog** (categories, products, variants, images) -> **warehouses & inventory** (stock-in/out, adjustments, movements) -> **orders** (accept, pack, ship, cancel, tracking, refund requests) -> **store wallet** (balance, withdraw) -> chat, promotions, reviews, and the advanced modules.

Traps already confirmed against the running server, which will bite when those land:

- `POST /media/upload` is `multipart/form-data` with a single `file` part, and the returned URL needs `normaliseUploadUrl`. Verification documents take an extra `doc_type` part plus `X-Store-Id`.
- `GET /products` and `GET /stores/{id}/products` paginate properly and return `meta: {page, per_page, total}` — unlike the previous backend, this one can be paged.
- `/categories` is empty on a fresh database. Products need a category, so seeding one through `POST /admin/categories` is a prerequisite for testing the catalogue at all.
- There is no seller-side order list separate from `/stores/{id}/orders`; the buyer's `/orders` is a different scope.

## Follow-ups when starting a new project from this base

- **Firebase**: this repo has no Firebase at all today. If it is adopted (or if this project is duplicated from one that has it), run `flutterfire configure` rather than inheriting another project's `firebase.json`, `lib/firebase_options.dart`, and platform config files — a copied config points at the origin project.
- **App identifier**: already done for this project — Android `applicationId`/`namespace`, iOS/macOS `PRODUCT_BUNDLE_IDENTIFIER`, `android:label`, `CFBundleDisplayName`, `MaterialApp.title` and the desktop/web names all say `com.marketplace.seller` / "Marketplace Seller". `name:` in `pubspec.yaml` is intentionally still `navy_wear` — see Project identity.
- **In-app brand text is still "Shopapay"** and was deliberately left alone during the rebrand, because the strings live in `lib/l10n/*.arb` and changing them requires regenerating `lib/generated/` (`dart run intl_utils:generate`, which needs `dart pub global activate intl_utils` first — it is not a declared dev_dependency). What remains: the `appName` and `aboutShopapay` keys in `intl_en.arb` / `intl_ar.arb`, the `AppImages.Shopapay` constant in [app_images.dart](lib/core/utils/app_images.dart), and its use in `about_app_view.dart`, `profile_view.dart`, `settings_view.dart` and `splash_screen.dart`. Never hand-edit `lib/generated/`.
- **Missing assets**: see *Known rough edges*. The directories now exist so the build succeeds, but the files themselves are still absent.
