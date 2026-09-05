# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **This document has two parts, and they do not describe the same thing.**
> **Part 1 — Current state** is what the code actually is today; verified against the repo.
> **Part 2 — Target architecture** is where the project is headed. It is now **partly built** — the migration checklist marks what landed.
> Never run a command or follow a pattern from Part 2 until the corresponding migration step is done. If the two parts conflict, Part 1 wins for any change you make right now.

## Project identity

Flutter e-commerce **seller app**, duplicated from `markas-app-member` on 2026-09-05 and rebranded. Both projects descend from the same purchased UI kit, so the sample code under `lib/features/` is identical in the two trees.

- Directory: `markas-app-seller` (sibling of `markas-app-member` on the Desktop)
- Dart package name (`pubspec.yaml`): **`navy_wear`** — absolute imports are `package:navy_wear/...`. Renaming this breaks every absolute import plus `test/widget_test.dart`. **Deliberately left identical to `markas-app-member`** so a widget or cubit can be copied between member and seller without rewriting imports. Do not rename it in only one of the two projects.
- Product name / bundle id: **Markas Seller** / `com.markas.seller` (Android `namespace` + `applicationId`, iOS + macOS `PRODUCT_BUNDLE_IDENTIFIER`), and `MaterialApp.title`. The member app keeps its own id, so both can be installed on one device.
- Android `MainActivity.kt` lives at `android/app/src/main/kotlin/com/markas/seller/` and declares `package com.markas.seller` — this must stay in sync with the gradle `namespace`, because `AndroidManifest.xml` refers to the activity as the relative `.MainActivity`.

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
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost/markas/api/v1
flutter run -d chrome --dart-define=LOG_HTTP=false      # silence the request log
```

`intl` is pinned to `^0.20.2`. Flutter 3.41's bundled `flutter_localizations` requires exactly `0.20.2`, and the kit's original `^0.19.0` made `flutter pub get` fail outright.

## Architecture

**Two architectures coexist in `lib/` right now, on purpose.**

- The **UI kit** (`lib/features/auth`, `home`, `my_cart`, `favorites`, `trending`, `onboarding`, `profile`, `spalsh`, `notifications&messages`, `shared`) still has no backend. `HomePageCubit.productsTShirt` and friends are hardcoded lists. Nothing about it changed.
- The **seller app** (`lib/config`, `lib/core/data`, `lib/core/domain`, `lib/di`, `lib/features/seller_*`) talks to the real Markas Bangunan API and follows the Part 2 layering. New seller work goes here.

When the two conflict, follow the seller-app conventions for anything touching the API, and the kit's conventions for anything touching its screens. Do not retrofit one onto the other file by file.

### Seller API integration

Backend: CodeIgniter 3 + MySQL + JWT at `http://localhost/markas/api/v1` (**port 80, not 8080**). The contract lives in `docs/API-SELLER-APP.md` — read it before touching anything in `lib/core/data`.

**Target platform is Flutter web in Chrome.** Never import `dart:io` in shared code. The dev server and the API sit on different ports, so every call is cross-origin; the backend answers preflight `OPTIONS` with 204 and open CORS headers, which is the only reason this works. A failed request on web cannot distinguish "server down" from "CORS blocked" — `ApiException` says both in one message rather than guessing.

Layering, bottom up:

```
lib/config/env/app_config.dart          # base URL via String.fromEnvironment
lib/config/network/                     # dio_client, auth_interceptor, api_envelope,
                                        #   api_exception, api_endpoints
lib/config/route/app_route_seller.dart  # SellerRoutes + appRouterSeller
lib/core/data_state.dart                # DataState<T> + DataError + DataErrorCode
lib/core/data/local/session_store.dart  # token / seller_id / role, over CachedHelper
lib/core/data/datasources/remote/service/   # *Service — owns Dio, throws ApiException
lib/core/data/repositories/                 # *RepositoryImpl — never throws
lib/core/domain/model/                      # hand-written models
lib/core/domain/repositories/               # abstract interfaces cubits depend on
lib/di/                                     # injector, injector_service, injector_repository
lib/features/seller_auth/ + seller_onboarding/ + seller_shell/
```

Rules that are load-bearing:

- **Never cast a JSON value directly.** The backend hands MySQL columns to `json_encode`, so `"id": "1"`, `"score": "100.00"` and `"is_official_store": "0"` are normal. Every model reads through `lib/core/utils/json_parse.dart` (`asInt`, `asDouble`, `asBool`, `asStringOrNull`, `asDateTime`, `asMapList`). `test/core/json_parse_test.dart` pins this behaviour.
- **Timestamps are server wall clock with no timezone.** `asDateTime` parses them as local and does not convert — converting would shift every displayed deadline.
- **Models are hand-written, not `freezed`.** Chosen deliberately over Part 2's codegen so editing a model does not require a `build_runner` round trip, and so the tolerant parsing above needs no custom `JsonConverter`. Cubit states are hand-written sealed classes, which give the same exhaustive `switch` as a freezed union.
- **`seller_id` is never sent to the server.** The backend reads it from the JWT claim and rejects a mismatched path segment with 403. `SessionStore.sellerId` exists only to build URLs; `SellerRepositoryImpl` throws `NO_SELLER_CONTEXT` locally when it is missing so the UI has one code path for "this account is not a store".
- **Services throw, repositories don't.** A `*Service` catches `DioException` and rethrows `ApiException`; `RepositoryGuard.guard` turns that into `DataFailed(DataError)`. An empty collection becomes `DataEmpty`, which cubits must treat as an empty list, not a failure.
- **Surface `error.code` and `error.details` to the user.** For `GATES_NOT_PASSED` and `VALIDATION_ERROR` the details block is the only statement of which gate or field failed. `ErrorStateView` and `showErrorSnackBar` already render both.
- **Cubits pull repositories with `injector<XRepository>()`**, not constructor injection, and expose `static XCubit get(context)` like the kit's cubits. Action methods (`login`, `add`, `create`, `signAgreement`) **return `DataError?`** rather than emitting an error state — the view shows a snackbar and keeps the typed form intact.
- **Token refresh is automatic.** `AuthInterceptor` is a `QueuedInterceptor`, so parallel 401s produce one refresh, not four. `POST /auth/register` returns no refresh token, so `AuthRepositoryImpl.register` logs in immediately afterwards to get one. **The refresh request body shape (`{"refresh_token": ...}`) is an assumption** — the API doc specifies the response but not the request. It is isolated in `AuthInterceptor._refreshAccessToken`.
- **Adding an endpoint** means: path constant in `api_endpoints.dart` -> method on a `*Service` -> method on the abstract repository -> implementation via `guard` -> registration in `injector_service.dart` / `injector_repository.dart` **in that dependency order**.

What is implemented: auth (register/login/refresh/me) and the whole of onboarding — the four activation gates, KYC document submission, bank accounts, the agreement, warehouses, and shipping tariffs. Catalogue, orders, shipments, finance, returns, disputes, RFQ, chat, vouchers and reports are **not** started.

`SellerRoutes.bootstrap` (`/`) is the router's `initialLocation`, not the kit's splash — see *Known rough edges*.

### Feature-first layout

```
lib/core/       # cross-cutting: routes, theme, styles, constants, cached prefs, shared widgets
lib/features/<feature>/data/models/
lib/features/<feature>/presentation/{cubits,views,views/widgets}
lib/generated/  # Flutter Intl output — DO NOT EDIT
lib/l10n/       # .arb translation sources
```

The seller features (`seller_auth`, `seller_onboarding`, `seller_shell`) use the same `presentation/{cubits,views,views/widgets}` shape but keep **no** `data/` subtree — their models and repositories are centralised under `lib/core/domain` and `lib/core/data`, per the target architecture.

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
- **Note**: `CustomTextFormField`'s default validator returns Arabic text (`'هذا الحقل مطلوب'`). Always pass an explicit `validator`.

### Localization

Generated by the **Flutter Intl IDE plugin** (Localizely), not `flutter gen-l10n`. `lib/generated/l10n.dart` and `lib/generated/intl/*` are generated — edit `lib/l10n/*.arb` and regenerate. Usage in views: `final l = S.of(context); ... l.home`.

Adding a language: add `lib/l10n/intl_<code>.arb`, regenerate, then add a `LanguageModel` to `supportedLanguages` in [language_model.dart](lib/features/shared/models/language_model.dart) (this list drives the settings picker and RTL direction, and is separate from `S.delegate.supportedLocales`).

Current state: `en` and `ar` are complete (284 keys) and selectable. `fr` appears in `S.delegate.supportedLocales` but `intl_fr.arb` is **empty** and `fr` is not in `supportedLanguages` — so device-locale French resolves to a locale with no translations. Either fill it in or drop it.

## Known rough edges

- **Assets are still missing, and the app renders wrong because of it.** `assets/images/` and `assets/icon/` now exist but contain only a `.gitkeep` — the UI kit's real files were never copied over from `markas-app-member`. Any kit screen that renders an `AppImages` path shows a missing-asset error. The seller screens are asset-free by design and are unaffected.
- **The kit's custom font is disabled.** `assets/fonts/Hanimation_Arabic_Regular.otf` is not in the repo, and a declared-but-missing font file fails asset bundling and blocks `flutter build` entirely, so the `fonts:` block in `pubspec.yaml` is commented out. `kFontFamily = 'Hanimation'` is still referenced in the theme; an unregistered family falls back to the platform default silently. Restore the `.otf` and uncomment to get the kit's typography back.
- **The router's `initialLocation` is `SellerRoutes.bootstrap` (`/`), not `AppRoutes.splash`.** The kit's animated splash renders four SVGs from the missing `assets/images/`, so it cannot be the entry point. `SellerBootstrapView` decides between the seller login and the onboarding dashboard based on the stored session. Every kit route stays registered and reachable.
- `test/widget_test.dart` (the Flutter counter template, which failed) has been **replaced**. `flutter test` now runs 32 real tests covering the tolerant JSON parsers, `SellerModel`/`ActivationGates`/`BankAccount` parsing against the payload printed in the API doc, and envelope/error handling. It is a genuine signal — keep it green.
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

`docs/API-SELLER-APP.md` covers roughly 80 endpoints; onboarding is one of sixteen groups. Build the rest in this order, since each depends on the last: catalogue (SKU requests, offers, price tiers, activation gates, inventory) -> orders (sub-orders, shipments, POD) -> finance (balance, ledger, withdrawals) -> returns and disputes -> RFQ, chat, vouchers, reports.

Traps documented in the API reference that must be handled when those land — each one fails silently or confusingly otherwise:

- `photos_json` must be objects `{url, width, height}`, not URL strings, and the app must measure the images itself. A bare string array makes `width` read as 0 and offer activation fails with no clear reason. Minimum 3 photos, each ≥ 800×800.
- `POST /offers/{id}/price_tiers` is a **replace**, not an append. Read the current tiers, edit locally, send the complete list back.
- `POST /sku-requests` answers **HTTP 200** when it did *not* create anything — branch on `data.similar_found`, never on the status code.
- `GET /returns/{id}` and `GET /disputes/{id}` do not exist; use `/returns/{id}/detail` and `/disputes/{id}/detail`.
- `strikethrough_price` is silently dropped if unproven; compare the response against what was sent and tell the store why it vanished.
- Deadlines are in *working hours* and skip weekends and holidays. Never compute them client-side — use the server's `*_deadline` / `*_at` fields.
- There is no file upload endpoint anywhere. Every `file_url` / `photo_url` / `photos_json` field takes a URL the app must have uploaded elsewhere first.

## Follow-ups when starting a new project from this base

- **Firebase**: this repo has no Firebase at all today. If it is adopted (or if this project is duplicated from one that has it), run `flutterfire configure` rather than inheriting another project's `firebase.json`, `lib/firebase_options.dart`, and platform config files — a copied config points at the origin project.
- **App identifier**: already done for this project — Android `applicationId`/`namespace`, iOS/macOS `PRODUCT_BUNDLE_IDENTIFIER`, `android:label`, `CFBundleDisplayName`, `MaterialApp.title` and the desktop/web names all say `com.markas.seller` / "Markas Seller". `name:` in `pubspec.yaml` is intentionally still `navy_wear` — see Project identity.
- **In-app brand text is still "Shopapay"** and was deliberately left alone during the rebrand, because the strings live in `lib/l10n/*.arb` and changing them requires regenerating `lib/generated/` (`dart run intl_utils:generate`, which needs `dart pub global activate intl_utils` first — it is not a declared dev_dependency). What remains: the `appName` and `aboutShopapay` keys in `intl_en.arb` / `intl_ar.arb`, the `AppImages.Shopapay` constant in [app_images.dart](lib/core/utils/app_images.dart), and its use in `about_app_view.dart`, `profile_view.dart`, `settings_view.dart` and `splash_screen.dart`. Never hand-edit `lib/generated/`.
- **Missing assets**: see *Known rough edges*. The directories now exist so the build succeeds, but the files themselves are still absent.
