# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **This document has two parts, and they do not describe the same thing.**
> **Part 1 — Current state** is what the code actually is today; verified against the repo.
> **Part 2 — Target architecture** is where the project is headed. None of it exists in this repo yet.
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

There is **no `build_runner` step in this repo** — no `freezed`, `json_serializable`, or `envied` is installed. See Part 2.

## Architecture

There is **no backend**. `dio` and `get_it` are declared in `pubspec.yaml` but never imported; all product/review/cart data is hardcoded as fields inside cubits (e.g. `HomePageCubit.productsTShirt`). Models like `ProductModel` already carry `fromJson` factories, so wiring a real API means replacing the cubit's literal lists, not restructuring.

### Feature-first layout

```
lib/core/       # cross-cutting: routes, theme, styles, constants, cached prefs, shared widgets
lib/features/<feature>/data/models/
lib/features/<feature>/presentation/{cubits,views,views/widgets}
lib/generated/  # Flutter Intl output — DO NOT EDIT
lib/l10n/       # .arb translation sources
```

The convention is applied loosely: `favorites`, `trending`, and `spalsh` are single files with no `presentation/` layer. Directory names contain typos that are part of the real paths — `spalsh` (splash), `presentaion` (profile only), and `notifications&messages` (literal `&`). Match the existing spelling rather than "fixing" it, or every import breaks.

### State: Cubits with mutable fields, not immutable state

`flutter_bloc` cubits are created **locally** — each view wraps its own body in `BlocProvider(create: ...)` inside `build()`. There is no global provider and no DI container.

Cubits hold **public mutable fields** (`currentIndex`, `products`, controllers) and emit **marker states** that carry no data (`class HomeChangeBottomNav extends HomeLayoutState {}`). `BlocBuilder` reacts to the emit, then reads the field off the cubit. Follow this pattern; do not convert to data-carrying states piecemeal. (Part 2 replaces this with freezed sealed unions — a deliberate, project-wide migration, not a per-file change.)

Every cubit exposes `static XCubit get(context) => BlocProvider.of(context);` — used as `HomePageCubit.get(context)`.

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

### Localization

Generated by the **Flutter Intl IDE plugin** (Localizely), not `flutter gen-l10n`. `lib/generated/l10n.dart` and `lib/generated/intl/*` are generated — edit `lib/l10n/*.arb` and regenerate. Usage in views: `final l = S.of(context); ... l.home`.

Adding a language: add `lib/l10n/intl_<code>.arb`, regenerate, then add a `LanguageModel` to `supportedLanguages` in [language_model.dart](lib/features/shared/models/language_model.dart) (this list drives the settings picker and RTL direction, and is separate from `S.delegate.supportedLocales`).

Current state: `en` and `ar` are complete (284 keys) and selectable. `fr` appears in `S.delegate.supportedLocales` but `intl_fr.arb` is **empty** and `fr` is not in `supportedLanguages` — so device-locale French resolves to a locale with no translations. Either fill it in or drop it.

## Known rough edges

- `test/widget_test.dart` is still the unmodified Flutter counter template and **fails** — it pumps `MyApp` and looks for a `+` icon. Replace it before treating `flutter test` as a signal.
- Stale `*.dart~` backup files litter `lib/` (and `android/`). They are not compiled but **do show up in grep results** — always confirm a hit isn't in a `~` file before editing.
- `lib/features/my_cart/presentation/views/map_screen.dart` is 100% commented out, and the `com.google.android.geo.API_KEY` meta-data in `android/app/src/main/AndroidManifest.xml` is commented out too. Restoring the map needs both, plus an iOS key. Location permissions are already declared in the manifest.
- `DevicePreview` wraps the app when `kDebugMode`, so debug builds render inside a simulated device frame — layout that looks wrong in debug may be the preview frame, not the code.
- Orientation is locked to portrait in `main()`.
- `flutter_launcher_icons` and `flutter_native_splash` config blocks in `pubspec.yaml` are commented out, though `flutter_launcher_icons.yaml` / `flutter_native_splash.yaml` exist at the root.

---

# Part 2 — Target architecture

**Status: not implemented.** Nothing below exists in this repo yet — verified: no `freezed`/`json_serializable`/`build_runner`/`envied` in `pubspec.yaml`; no `lib/config/`, `lib/di/`, `lib/ui/`, `lib/core/data/`, `lib/core/domain/`; no `.env`, `firebase.json`, or `lib/firebase_options.dart`; zero `*.freezed.dart` / `*.g.dart` files. `dio` and `get_it` are declared but unimported.

This is the layering the project is being moved toward: **data → domain → presentation** per feature, wired with `get_it` for DI and `go_router` for navigation.

## Additional commands (only after the deps below are added)

Models use `freezed` + `json_serializable`; env vars use `envied`. Changes to `*_model.dart`, `*_state.dart`, `*_cubit.dart` (freezed part files), or `.env` require regenerating the related `*.freezed.dart` / `*.g.dart`:

```bash
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs   # while iterating
```

`lib/config/env/env.dart` reads `.env` (the gitignored key names are listed in `.gitignore`) and produces `env.g.dart` via `envied`. It starts with a single `API_BASE_URL` placeholder — add one `EnviedField` per new base URL / API key as feature domains are added.

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

Derived from the gap between Part 1 and Part 2; no step is started yet.

1. Add `freezed_annotation`, `json_annotation`, `envied` to dependencies and `build_runner`, `freezed`, `json_serializable`, `envied_generator` to dev_dependencies.
2. Create `lib/config/env/env.dart` + `.env` with `API_BASE_URL`; add `.env` to `.gitignore`.
3. Create `lib/config/network/dio_client.dart` with the named `"api"` Dio singleton — `dio` is already in `pubspec.yaml`, just unused.
4. Add `lib/core/data_state.dart` with the `DataState<T>` union.
5. Build `lib/di/{injector,injector_service,injector_repository}.dart` and call `initialize()` before `runApp` in [main.dart](lib/main.dart), where `CachedHelper.init()` already runs — `get_it` is already in `pubspec.yaml`, just unused.
6. Move the hardcoded lists out of cubits (`HomePageCubit.productsTShirt` and friends) behind a `*Service` + `*RepositoryImpl` pair. `ProductModel.fromJson` already exists as a starting point.
7. Convert marker states to `@freezed` unions, one feature at a time, and switch cubits from public mutable fields to emitted state data.
8. Split [app_routes.dart](lib/core/utils/app_routes.dart) into per-domain route files under `lib/config/route/`.
9. Decide the fate of `lib/features/` vs `lib/ui/` — the target names the presentation root `ui/`, which is a rename of the existing tree, not a second one.

## Follow-ups when starting a new project from this base

- **Firebase**: this repo has no Firebase at all today. If it is adopted (or if this project is duplicated from one that has it), run `flutterfire configure` rather than inheriting another project's `firebase.json`, `lib/firebase_options.dart`, and platform config files — a copied config points at the origin project.
- **App identifier**: already done for this project — Android `applicationId`/`namespace`, iOS/macOS `PRODUCT_BUNDLE_IDENTIFIER`, `android:label`, `CFBundleDisplayName`, `MaterialApp.title` and the desktop/web names all say `com.markas.seller` / "Markas Seller". `name:` in `pubspec.yaml` is intentionally still `navy_wear` — see Project identity.
- **In-app brand text is still "Shopapay"** and was deliberately left alone during the rebrand, because the strings live in `lib/l10n/*.arb` and changing them requires regenerating `lib/generated/` (`dart run intl_utils:generate`, which needs `dart pub global activate intl_utils` first — it is not a declared dev_dependency). What remains: the `appName` and `aboutShopapay` keys in `intl_en.arb` / `intl_ar.arb`, the `AppImages.Shopapay` constant in [app_images.dart](lib/core/utils/app_images.dart), and its use in `about_app_view.dart`, `profile_view.dart`, `settings_view.dart` and `splash_screen.dart`. Never hand-edit `lib/generated/`.
- **Missing assets**: `assets/images/` and `assets/icon/` are registered in `pubspec.yaml` and referenced throughout `AppImages`, but neither directory exists on disk — inherited from `markas-app-member`, where the UI kit's asset folders were never copied in. The app cannot render until they are restored.
