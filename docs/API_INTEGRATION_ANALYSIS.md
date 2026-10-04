# ASTRA Mobile App — API Integration Analysis

**Backend:** `https://hamsatech-api.onrender.com` — OpenAPI 3.1, title "HamsaTech Auth API" v1.0.0
**Source of truth used:** live `GET /openapi.json` fetched during this analysis (88 schemas, 58 operations), cross-referenced against the Flutter source on branch `feature/api-integration`.
**Scope:** read-only analysis. No backend or Flutter code was modified to produce this document.

---

## 1. Executive summary

The backend exposes **two unrelated authentication subsystems** under the same host:

| | **Subsystem A — Portal Auth** | **Subsystem B — Mobile Athlete Auth** |
|---|---|---|
| Identity | email + password | phone number + OTP |
| Session | `hamsai_session` cookie | none (no token is ever issued) |
| Primary entity | `AuthenticatedUser` (role: `student` \| `coach`) | `athleteId` (e.g. `ATH1001`) |
| Endpoints | `/api/auth/*`, `/api/coach/*`, `/api/admin/*`, `/api/student/*`, `/api/v1/assignments/*`, `/api/v1/coaches/*`, `/api/intake/*` | `/api/v1/auth/phone/*`, `/api/mobile/athletes/*` |
| Used by Flutter app today? | **No — zero references anywhere in `lib/`** | **Yes — this is the app's actual auth flow** |

The API body you pasted (`POST /api/auth/signup` with a nested `"user": {...}` containing `role`, `coachCode`, `assignmentStatus`, etc.) is **not the request schema** — it is the shape of `AuthenticatedUser`, the *response* object returned inside `AuthResponse.user`. The real request body for `/api/auth/signup` is flat and much smaller (see §7.1). This distinction matters a lot for the rest of this document, so it's called out again in §11.1.

The Flutter app's real, working (mostly) OTP flow lives entirely in Subsystem B, and it never touches `/api/auth/signup` / `/api/auth/login` at all. Several of Subsystem B's own calls are also broken against the live schema (wrong field names, wrong paths, wrong response envelopes) — cataloged in §11.

---

## 2. Every backend endpoint, grouped, with purpose

### 2.1 Subsystem A — Portal / session auth (email+password, cookie-based)

| Method | Path | Purpose |
|---|---|---|
| POST | `/api/auth/signup` | Register a new **student** account (email+password). `role` is hardcoded to `"student"` server-side — there is no way to self-register as `coach` here. |
| POST | `/api/auth/login` | Authenticate with email+password. Returns the same `AuthResponse` shape as signup. |
| GET | `/api/auth/me` | "Who am I" — reads the `hamsai_session` cookie, returns the current `AuthenticatedUser`. |
| POST | `/api/auth/logout` | Invalidates the session cookie. |
| GET/PATCH | `/api/coach/profile` | Coach reads/edits their own profile (session-gated). |
| GET/POST | `/api/admin/coaches` | Admin lists / creates coach accounts. **This is the only place a `coach` account with a `coachCode` is actually created.** |
| PATCH | `/api/admin/coaches/{coach_email}` | Admin edits a coach profile. |
| POST | `/api/admin/assignments` | Admin manually assigns an athlete (by `athleteId`) to a coach (by email). |
| GET | `/api/v1/coaches/available` | List coaches a student can request. |
| POST | `/api/student/coach-request` | Student requests a specific coach by code — sets `requestedCoachCode/Email/Name` on their `AuthenticatedUser`. |
| GET | `/api/coach/assignment-requests` | Coach views pending student requests. |
| POST | `/api/coach/assignment-requests/{student_email}/approve` | Coach approves a request by re-entering their own `coachCode`. |
| GET | `/api/v1/coaches/{coach_id}/pending_assignments` | V1 variant of the pending-request list, keyed by `coach_id` not email. |
| POST | `/api/v1/assignments/assign` | V1 variant of assignment approval (`requestId`, `athleteId`, `assignedCoachId`). |
| GET | `/api/v1/athletes/{athlete_id}/assignment_status` | Status of one athlete's coach assignment (`PENDING/ASSIGNED/REJECTED/UNASSIGNED`). |
| GET | `/api/students` | Lists all `StudentProfile` records (admin/coach view). |
| GET | `/api/coach/dashboard-summary`, `/api/coach/athletes`, `/api/coach/athletes/{id}`, `/{id}/home`, `/{id}/widget`, `/{id}/sessions-widget`, `/{id}/insights-widget`, `/{id}/profile-widget`, `/{id}/scores`, `/{id}/feedback` | Coach's web dashboard views into their assigned athletes. |
| GET | `/api/v1/coaches/{coach_id}/dashboard` | V1 alternate coach dashboard payload. |
| GET/POST/PATCH | `/api/notifications*`, `/api/v1/coaches/{coach_id}/notifications`, `/api/v1/notifications/{id}/mark_read` | Two parallel notification systems (legacy `/api/notifications` + newer `/api/v1/...`). |
| POST | `/api/v1/feedback_requests`, `/api/v1/coach_feedback`, `/api/coach/athletes/{id}/feedback` | Coach feedback creation (again, legacy + v1 variants coexist). |
| GET | `/api/coach/athletes/{id}/feedback`, `/api/student/feedback` | Feedback reads, from each side. |
| GET | `/api/intake/questions` | Fetches the psychology questionnaire (used by the *rich* intake form, see below). |
| POST | `/api/intake/submit` | Submits a **complete** athlete intake: master bio-data, family details, school/lifestyle profile, one physiology snapshot, and psychology answers — all in one call (`AthleteIntakeRequest`, §7.4). This looks like the **coach/academy-side onboarding form**, not the mobile app's step-by-step onboarding. |
| GET | `/api/health` | Healthcheck. |

### 2.2 Subsystem B — Mobile athlete app (phone + OTP, no session token)

| Method | Path | Purpose |
|---|---|---|
| POST | `/api/v1/auth/phone/send-otp` | Sends a 6-digit OTP (Twilio Verify) to a phone number. |
| POST | `/api/v1/auth/phone/verify-otp` | Verifies the OTP **and** looks up/creates the athlete record in one step. Returns only `{athleteId, success}` — nothing else. This is the single most important endpoint in the whole app: it is verify, existence-check, and (implicitly) account-creation combined. |
| POST | `/api/mobile/athletes/register` | Creates/enriches an athlete profile with `fullName, email, age, gender, phone` (all required) plus optional `sport`, `focusArea`, coach-assignment fields. `athleteId` is an *optional* input — omit it to let the server mint one, or pass an existing one. |
| GET/PUT | `/api/mobile/athletes/{athlete_id}/profile` | Full profile read/upsert (discipline, experience, academy, scores, goals, Polar linkage, `onboardingStatus`, `profileCompletionStatus`). |
| POST | `/api/mobile/athletes/{athlete_id}/baseline` | Saves resting HR / HRV baseline captured from a Polar device. |
| POST/GET | `/api/mobile/athletes/{athlete_id}/daily-checkins`, `/daily-checkins/latest` | Daily mood/energy/sleep check-in. |
| GET | `/api/mobile/athletes/{athlete_id}/home` | Dashboard home payload (free-form object). |
| POST/GET | `/api/mobile/athletes/{athlete_id}/sessions`, `/sessions/{id}/series`, `/sessions/{id}/reflection`, `/sessions/{id}/complete`, `/sessions/{id}/summary` | Full training-session lifecycle. |

**Not in the spec at all**, despite being called by the Flutter app: `/api/v1/onboarding/personal-details`, `/api/v1/onboarding/shooting-profile`, `/api/v1/onboarding/current-performance`, `/api/v1/onboarding/goals`, `/api/v1/onboarding/summary/{id}`, `/api/v1/checkin/daily`, `/api/v1/intake/questions`, `/api/v1/intake/submit`. See §11.

---

## 3. Complete authentication flow (as documented by the backend)

### 3.1 Subsystem A (email + password)

```
Client                              Backend
  |--- POST /api/auth/signup ------->|  {fullName,email,password,sport?,focusArea?,dateOfBirth?}
  |<-- 201 AuthResponse{user} -------|  role is forced to "student"
  |                                  |  (session cookie set — mechanism undocumented in schema)
  |--- POST /api/auth/login -------->|  {email,password}
  |<-- 200 AuthResponse{user} -------|
  |--- GET /api/auth/me ------------>|  cookie: hamsai_session
  |<-- 200 AuthResponse{user} -------|
  |--- POST /api/auth/logout ------->|  cookie: hamsai_session
  |<-- 200 StatusResponse -----------|
```

No endpoint in this subsystem returns a bearer/JWT token. `GET /api/auth/me` and every `/api/coach/*`, `/api/admin/*`, `/api/student/*`, `/api/intake/*` endpoint declares an **optional** `hamsai_session` cookie parameter — session state is carried purely via cookie, which means the HTTP client must have a cookie jar.

Coach accounts (`role: "coach"`, `coachCode`) are **only** created by an admin via `POST /api/admin/coaches` — never through public signup.

### 3.2 Subsystem B (phone + OTP) — this is what the mobile app actually uses

```
Client                                        Backend
  |--- POST /api/v1/auth/phone/send-otp ------->|  {phone}
  |<-- 200 {success, message} ------------------|  (Twilio Verify SMS sent)
  |--- POST /api/v1/auth/phone/verify-otp ------>|  {phone, otp}
  |<-- 200 {athleteId, success} ----------------|  backend upserts users+athletes row
```

That's the entire contract. There is **no field telling the client whether this athleteId is brand-new or pre-existing**, and **no token of any kind is returned**. Every subsequent `/api/mobile/athletes/{athleteId}/*` call is authorized by nothing but knowing the `athleteId` string — the OpenAPI spec declares zero security requirement on any of these paths (confirmed: `components.securitySchemes` is empty and no path lists an `Authorization` header or bearer requirement).

---

## 4. Complete onboarding flow (as documented by the backend)

The backend has **no dedicated step-by-step "onboarding" endpoint family**. Profile completeness is represented as data, not as a wizard:

1. `verify-otp` returns an `athleteId`.
2. `POST /api/mobile/athletes/register` (or `PUT /api/mobile/athletes/{id}/profile`) fills in identity fields and sets `profileCompletionStatus` (`incomplete` / `partial` / `complete`).
3. `PUT /api/mobile/athletes/{id}/profile` is called again (any number of times) to progressively fill discipline, experience, academy, goals, etc. — the record also carries a free-text `onboardingStatus` string.
4. `POST /api/mobile/athletes/{id}/baseline` records the Polar HR baseline once a device is paired.
5. From then on the athlete is "onboarded" in the sense that `home`, `sessions`, `daily-checkins` become meaningful.

Separately, Subsystem A has its own, much heavier onboarding capture: `POST /api/intake/submit`, which takes one big payload covering bio-data, family, school/lifestyle, one physiology snapshot, and all psychology answers at once (`AthleteIntakeRequest`). This is structurally nothing like the mobile app's multi-step wizard (academic profile / lifestyle / mental-social / baseline screens) and doesn't appear to be wired for step-by-step partial submission.

---

## 5/6 — Which endpoint creates the athlete / returns `athleteId`

- **Creates the athlete (first time):** `POST /api/v1/auth/phone/verify-otp` — this is the true creation point; it "creates/updates hamsatech.users + hamsatech.athletes" per the endpoint's own docstring in the Flutter code comments, and is confirmed as the only Subsystem-B call that can run with nothing but a phone number.
- **Also creates/updates an athlete:** `POST /api/mobile/athletes/register` — takes a richer payload (name/email/age/gender/phone) and can either create a new row (if `athleteId` omitted) or attach to an existing one (if passed). Whether the backend actually reconciles this against the row `verify-otp` already created, or can produce a duplicate, is **not verifiable from the OpenAPI spec alone** — flagged as an open question in §13.
- **Returns `athleteId`:** `PhoneOtpVerifyResponse.athleteId` (verify-otp) and `MobileAthleteRegistrationResponse.athleteId` (register). All other `/api/mobile/athletes/{athlete_id}/*` endpoints take it as a path parameter rather than returning it.

## 7. Which endpoint returns authentication tokens

**None do.** This is worth stating plainly because the Flutter code behaves as if one does:

- `PhoneOtpVerifyResponse` = `{athleteId: string, success: bool}` — no token field, no `isNewUser` field.
- `AuthResponse` (signup/login/me) = `{user: AuthenticatedUser}` — no token field either; that subsystem's "token" is the `hamsai_session` cookie, set out-of-band.

---

## 7. Request/response models (verbatim from the live schema)

### 7.1 `SignUpRequest` — POST `/api/auth/signup`
```jsonc
{
  "fullName": "string (2-80 chars)",     // required
  "email": "user@example.com",           // required
  "password": "string (8-128 chars)",    // required
  "sport": "string (2-50 chars) | null",       // optional
  "focusArea": "string (2-80 chars) | null",   // optional
  "dateOfBirth": "YYYY-MM-DD | null"           // optional
}
```
No `role`, no `coachCode`, no assignment fields, no `user` wrapper. `role` defaults to the fixed value `"student"` server-side (Pydantic `const`).

### 7.2 `AuthResponse` / `AuthenticatedUser` — response of signup/login/me
```jsonc
{
  "user": {
    "email": "...", "fullName": "...",
    "role": "coach" | "student",                    // required
    "coachCode": "string | null",
    "assignmentStatus": "unassigned" | "pending" | "assigned",  // default "unassigned"
    "assignedCoachCode/Email/Name": "string | null",
    "requestedCoachCode/Email/Name": "string | null",
    "sport": "string | null", "focusArea": "string | null",
    "dateOfBirth": "date | null", "performanceScore": "int | null"
  }
}
```
**This is the object the user-pasted example actually describes** — it's the shape returned to the client, not the shape sent to `/signup`.

### 7.3 Subsystem B — phone/OTP + athlete
```jsonc
// POST /api/v1/auth/phone/send-otp
{ "phone": "string (7-20 chars)" }                      → { "success": bool, "message": "string" }

// POST /api/v1/auth/phone/verify-otp
{ "phone": "string", "otp": "^\\d{6}$" }                 → { "athleteId": "string", "success": bool }

// POST /api/mobile/athletes/register
{
  "athleteId": "string | null",           // optional — omit to auto-generate
  "fullName": "string (2-100)",           // required
  "email": "email",                       // required
  "age": "int 5-80",                      // required
  "gender": "Male" | "Female" | "Other",  // required
  "phone": "string (7-20)",               // required
  "sport": "string | null", "focusArea": "string | null",
  "assignedCoachEmail/Id": "string | null", "selectedCoachId": "string | null",
  "profileCompletionStatus": "incomplete" | "partial" | "complete"  // default "partial"
}
→ 201 { "athleteId": "...", "assignedCoachEmail": "string|null", "notificationCreated": bool, "success": bool }

// GET/PUT /api/mobile/athletes/{athlete_id}/profile
// PUT body (all optional, MobileAthleteProfileUpsertInput):
{
  "fullName", "age", "gender", "city", "discipline", "experienceLevel" ("Beginner"|"Intermediate"|"Advanced"),
  "yearsShooting", "academyClub", "averagePracticeScore", "targetScore",
  "performanceFactors": ["..."], "goal30Days", "goal6Months",
  "polarLinked", "polarDeviceId"
}
// GET/PUT response envelope: { "profile": { ...MobileAthleteProfileRecord..., "onboardingStatus", "profileCompletionStatus", "createdAt", "updatedAt" } }
```

### 7.4 `AthleteIntakeRequest` — POST `/api/intake/submit` (Subsystem A)
Five nested required objects, none of which resemble the mobile app's step data:
- `athleteMaster`: name, age, gender, heightCm, weightKg, academyId, coachId, contactNumber, email
- `familyDetails`: motherName/fatherName/occupations, educationLevel, siblingDetails, familyConservative, disciplineLevel, healthConditions, parent contact/email, comments
- `athleteProfile`: class, schoolName, dietType, outsideFoodFrequency, sleepTime, wakeTime, friendCircle, angerPattern, sadnessPattern, academicPerformance, reasonForShooting, athleteGoal
- `sessionsLog` / `physiologyData` (restingHeartRate, avgHeartRate, spo2, breathingRate, sleepHours, recoveryScore, stressScore, fatigueLevel, remarks)
- `psychologyResponses[]`: `{questionId, answerText, answerScore?}` (min 1 item)

---

## 8. Dependency graph between endpoints

```
send-otp ──► verify-otp ──► athleteId ──┬──► register (optional enrich/attach)
                                          ├──► profile GET/PUT   (needs athleteId)
                                          ├──► baseline POST     (needs athleteId)
                                          ├──► daily-checkins    (needs athleteId)
                                          ├──► sessions/*        (needs athleteId)
                                          └──► home              (needs athleteId)

signup/login ──► hamsai_session cookie ──┬──► me / logout
                                          ├──► coach/profile, coach/athletes/*   (role=coach)
                                          ├──► student/coach-request             (role=student)
                                          ├──► intake/questions, intake/submit
                                          └──► admin/* (separate elevated role, not modeled in AuthenticatedUser.role enum)

admin/coaches (create coach) ──► coachCode ──► student/coach-request { coachCode } ──► coach/assignment-requests/{email}/approve { coachCode }
                                                                                    (or v1: assignments/assign { requestId, athleteId, assignedCoachId })
```

The two graphs never intersect anywhere in the OpenAPI spec — nothing links an `athleteId` (Subsystem B) to an `AuthenticatedUser.email` (Subsystem A). If the product intends one human to have both a mobile athlete profile *and* a portal account, that link does not exist in the backend today.

---

## 9. Sequence diagrams

### 9.1 Intended flow you described ("OTP → check exists → create profile / sign in"), mapped onto what actually exists

```
User            Flutter App                          Backend
 |--- phone --->|                                        |
 |              |--POST /api/v1/auth/phone/send-otp----->|
 |              |<--------------{success}-----------------|
 |--- otp ----->|                                        |
 |              |--POST /api/v1/auth/phone/verify-otp--->|
 |              |<---------{athleteId, success}-----------|   ⚠ no "isNewUser" — this is
 |              |                                          |     the step your desired
 |              |   [step you want: "check if exists"]     |     branch point doesn't exist
 |              |   ⚠ NOT POSSIBLE from this response alone
 |              |
 |              |-- (new user)  PUT profile / POST register --> creates/fills profile
 |              |-- (existing)  GET profile -------------------> reads existing profile
 |              |   ⚠ app currently decides "new vs existing" by reading a LOCAL
 |              |     SharedPreferences flag (isOnboardingComplete()), not backend truth
```

### 9.2 Current, actual Flutter implementation (annotated with breakage)

```
OtpScreen._submit()
  └─► AuthBloc(AuthVerifyOtpRequested)
        └─► AuthRepositoryImpl.verifyOtp()
              ├─► ApiService.verifyOtpAndRegister()  POST /api/v1/auth/phone/verify-otp   ✅ correct path
              │      response parsed by AuthResponseModel:
              │        .isNewUser  ⚠ backend never sends this — always false
              │        .token      ⚠ backend never sends this — falls back to athleteId
              ├─► SecureStorageService / StorageService persist athleteId + fake "token"
              ├─► ApiService.setMobileAuthToken(token)   (Bearer header — not checked by backend at all)
              └─► ApiService.registerAthlete(athleteId, phone, sport)  fire-and-forget
                     POST /api/mobile/athletes/register
                     body: {athlete_id, phone, sport}   ⚠ wrong keys + missing required
                                                            fullName/email/age/gender → 422 every time
                                                            (swallowed as "non-fatal")

OtpScreen (on AuthAuthenticated)
  └─► if StorageService.isOnboardingComplete() → /home
      else → resume local onboarding step                 ⚠ purely local; ignores backend state
```

---

## 10. Comparison: API design vs. current Flutter implementation

| Aspect | Backend (live schema) | Flutter implementation | Match? |
|---|---|---|---|
| OTP send/verify path | `/api/v1/auth/phone/send-otp`, `/verify-otp` | same paths | ✅ |
| verify-otp response fields | `{athleteId, success}` | expects/parses `isNewUser`, `token`, `data` envelope | ❌ |
| Athlete registration payload | camelCase, requires `fullName/email/age/gender/phone` | snake_case, sends only `athlete_id/phone/sport` | ❌ |
| Profile upsert payload | camelCase (`discipline`, `experienceLevel`, `goal30Days`...) | snake_case (`sport_domain`, `family_support`, `pressure_sources`, `goal_30`...) — none exist server-side | ❌ |
| Profile read envelope | `{ "profile": {...} }` | code reads `raw['data']` | ❌ |
| Onboarding step endpoints | do not exist | 5 methods call them (`api_service.dart` L78-150) | ❌ |
| Daily check-in path | `/api/mobile/athletes/{id}/daily-checkins` | calls flat `/api/v1/checkin/daily` | ❌ |
| Intake questions/submit | `/api/intake/questions`, `/api/intake/submit`, nested 5-object body | calls `/api/v1/intake/*`, flat `{athlete_id, answers, scores}` | ❌ |
| Auth transport | Subsystem B: none; Subsystem A: cookie | app sends `Authorization: Bearer <athleteId>` on `_mobileDio`, no cookie jar anywhere | ⚠ decorative, not enforced either way |
| `/api/auth/signup` / `/login` / `/me` / `/logout` | fully specified, email+password+cookie | **not called anywhere in `lib/`** | ❌ (unintegrated) |
| Coach role / `coachCode` / assignment fields | modeled on `AuthenticatedUser`, created via admin only | no `role` concept anywhere in `UserEntity`/`UserModel` | ❌ (not modeled) |

---

## 11. Every mismatch, in detail

### 11.1 The pasted signup payload is the response schema, not the request schema
- **Not a code defect** — a documentation-reading issue worth fixing before any implementation starts.
- The real request body for `POST /api/auth/signup` is `SignUpRequest` (§7.1): `fullName`, `email`, `password`, optional `sport/focusArea/dateOfBirth`. No `user` wrapper, no `role`, no coach/assignment fields.
- **Why it matters:** any implementation built against the pasted example would send a body the backend's Pydantic validator rejects with 422 (unknown/missing fields), and would assume coach self-signup is possible when it isn't.

### 11.2 `isNewUser` is parsed but never sent by the backend
- **File:** `lib/features/auth/data/models/auth_response_model.dart`, lines ~30-33 (`isNewUser` parse) and lines ~24-28 (`token` parse).
- **File:** `lib/features/auth/data/repositories/auth_repository_impl.dart`, function `verifyOtp`, lines ~30-45.
- **Why incorrect:** `PhoneOtpVerifyResponse` (live schema) is `{athleteId: string, success: bool}` only — no `isNewUser`, `is_new_user`, `token`, `session_token`, `access_token`, or `jwt` field exists anywhere in the response. `parsed.isNewUser` is always `false`; `parsed.token` is always `null`, silently falling back to `token = athleteId`.
- **Failure scenario:** any code path that ever branches on `isNewUser` (there isn't one today, but this is exactly the gap blocking the flow you want) will always take the "existing user" branch, even for a brand-new phone number.

### 11.3 `registerAthlete()` sends a payload that will always fail validation
- **File:** `lib/core/services/api_service.dart`, function `registerAthlete`, lines 180-194.
- **File:** caller in `lib/features/auth/data/repositories/auth_repository_impl.dart`, lines ~62-72 (fire-and-forget block inside `verifyOtp`).
- **Why incorrect:** sends `{athlete_id, phone, sport}` (snake_case). `MobileAthleteRegistrationInput` requires `fullName`, `email`, `age`, `gender`, `phone` (camelCase) — `fullName/email/age/gender` are absent. FastAPI/Pydantic will return **422** on every single call.
- **Failure scenario:** the call fails every time it runs (it always has, since these three fields are all it's ever been given); the failure is caught and only `debugPrint`'d as "non-fatal," so nobody has noticed the athlete-enrichment step has never once succeeded.

### 11.4 `updateMobileAthleteProfile()` sends field names that don't exist server-side
- **File:** `lib/core/services/api_service.dart`, function `updateMobileAthleteProfile`, lines 752-782.
- **Why incorrect:** sends `sport_domain`, `experience_level`, `family_support`, `pressure_sources`, `goal_30`, `goal_6_month`. `MobileAthleteProfileUpsertInput` has `discipline`, `experienceLevel`, `academyClub`, `goal30Days`, `goal6Months` — and has **no** `family_support` or `pressure_sources` field at all, under any name.
- **Failure scenario:** depending on FastAPI's extra-field handling, this either 422s or (more likely, since Pydantic v2 default is to ignore unknown fields) silently accepts the request and writes nothing, because none of the submitted keys match a real column. Either way, athlete profile edits from the onboarding flow (`onboarding_repository_impl.dart` line 40) never actually reach the backend.

### 11.5 `getAthleteProfile()` reads the wrong response envelope
- **File:** `lib/features/auth/data/repositories/auth_repository_impl.dart`, function `getAthleteProfile`, lines ~104-116.
- **Why incorrect:** unwraps `raw['data']`; the live `MobileAthleteProfileResponse` wraps the record under `raw['profile']`.
- **Failure scenario:** even a fully successful `GET` returns `{}` to every caller, because the key it looks for is never present.

### 11.6 Five onboarding-step endpoints don't exist in the backend
- **Files / call sites:**
  - `lib/core/services/api_service.dart` — `saveOnboardingPersonalDetails` (L78-95), `saveOnboardingShootingProfile` (L97-114), `saveOnboardingCurrentPerformance` (L116-131), `saveOnboardingGoals` (L133-146), `getOnboardingSummary` (L148-150)
  - Called from `onboarding_step1_bloc.dart:68`, `onboarding_step2_bloc.dart:84`, `onboarding_step3_bloc.dart:69`, `onboarding_step4_bloc.dart:57`, `alex_summary_bloc.dart:25`
- **Why incorrect:** none of `/api/v1/onboarding/personal-details`, `/shooting-profile`, `/current-performance`, `/goals`, `/summary/{id}` appear anywhere in the 58-operation OpenAPI spec.
- **Failure scenario:** every one of these calls 404s. Whether this is currently masked depends on how each bloc handles the error (worth checking per-bloc if these paths are believed to be "working" today).

### 11.7 Daily check-in path is wrong
- **File:** `lib/core/services/api_service.dart`, function `saveDailyCheckin`, lines 154-173.
- **Why incorrect:** posts to flat `/api/v1/checkin/daily`. Real endpoint is `POST /api/mobile/athletes/{athlete_id}/daily-checkins` — path-scoped by athlete, different shape.

### 11.8 Intake endpoints — wrong path *and* wrong shape
- **File:** `lib/core/services/api_service.dart`, functions `getIntakeQuestions` (L801-806) and `submitIntakeAnswers` (L808-824).
- **Called from:** `onboarding_bloc.dart` lines 61 and 156.
- **Why incorrect:** calls `/api/v1/intake/questions` and `/api/v1/intake/submit` — real paths drop `v1` (`/api/intake/questions`, `/api/intake/submit`). Even after fixing the path, the body shape is wrong: the app sends `{athlete_id, answers: [...], scores: {...}}`; the backend requires the five-object `AthleteIntakeRequest` (§7.4) — an entirely different, much larger form (school, family, physiology, per-question psychology answers) that belongs to Subsystem A, not the mobile baseline assessment.

### 11.9 Bearer token is sent but never validated
- **File:** `lib/core/services/api_service.dart`, class `_MobileAuthInterceptor`, lines 860-872; enabled via `setMobileAuthToken`, lines 48-52.
- **Why worth flagging (not a "bug" exactly):** the OpenAPI spec declares no security scheme anywhere, and no `/api/mobile/*` or `/api/v1/auth/phone/*` path lists an auth header parameter. The `Authorization: Bearer <athleteId-or-nothing>` header the app sends is not checked. This means any client that can guess/enumerate an `athleteId` can currently call any mobile endpoint for that athlete — a real gap if this backend is production-facing, independent of the signup/login question.

### 11.10 `/api/auth/signup`, `/login`, `/me`, `/logout` are completely unintegrated
- **Evidence:** `grep -rn "api/auth/signup\|api/auth/login\|api/auth/me\|api/auth/logout" lib/` returns nothing.
- **File:** `lib/features/auth/presentation/screens/sign_up_screen.dart` — "Continue" button navigates straight to `/login` (phone entry) with no email/password fields anywhere on screen; Google/Apple buttons call `SignUpRepositoryImpl.initiateGoogleSignUp/initiateAppleSignUp` (`lib/features/auth/data/repositories/sign_up_repository_impl.dart`), both literal `// TODO: integrate ... SDK` stubs.
- **File:** `lib/features/auth/presentation/screens/login_screen.dart` — despite the name, this is the **phone-number entry** screen; it dispatches `AuthSendOtpRequested`, i.e. it's part of Subsystem B, not Subsystem A.
- **Why it matters:** the naming in the UI ("Sign Up" / "Log In") suggests it corresponds to `/api/auth/signup` / `/api/auth/login`, but it doesn't — both screens are front doors into the *phone-OTP* flow. There is currently no code path, screen, or Dio configuration for email+password auth at all.

### 11.11 No cookie jar on the Dio client used for the mobile backend
- **File:** `lib/core/services/api_service.dart`, `_buildMobileDio()`, lines 54-74.
- **Why it matters:** if `/api/auth/login`/`/signup` were wired up as-is, the `hamsai_session` cookie returned by the backend would never be captured or replayed — `_mobileDio` has no `CookieManager`/`PersistCookieJar` interceptor. `GET /api/auth/me` and any `/api/coach/*`, `/api/intake/*`, `/api/student/*` call would immediately fail authorization on the very next request.

### 11.12 No `role` concept anywhere in the client's data model
- **Files:** `lib/features/auth/domain/entities/user_entity.dart`, `lib/features/auth/data/models/user_model.dart`.
- **Why it matters:** `UserEntity` is `{id, phoneOrEmail, token}` only. If any part of the product intends to model coach vs. student/athlete accounts in this app, `role`, `coachCode`, and the assignment-status fields from `AuthenticatedUser` have nowhere to live today.

### 11.13 `AppRouter.initialLocation` bypasses the entire auth flow
- **File:** `lib/core/router/app_router.dart`, line 108: `initialLocation: '/onboarding/step1'`.
- **Why worth noting:** the router's own header comment (lines 48-59) documents `/splash → /welcome → /signup or /login → /otp` as the required flow, but the app currently boots straight into onboarding. Almost certainly an intentional dev-time shortcut, but it means none of the auth screens are reachable as "screen one" in the current build — worth confirming before this is handed off as an implementation guide.

---

## 12. What currently *does* work

To keep this balanced: `send-otp` → `verify-otp` hits the correct path/shape and does return a usable `athleteId`. Session lifecycle (`createMobileSession`, `saveSeries`, `completeMobileSession`, `getSessionSummary`) and dashboard home (`getDashboardHome`) all call real, correctly-shaped endpoints. The mismatches are concentrated almost entirely in **registration, profile sync, and onboarding/intake** — precisely the area the user's original question was about.

---

## 13. Open questions for the backend team

These cannot be answered from the OpenAPI spec alone and should be confirmed before implementation:

1. When `POST /api/auth/signup` is called with an email that already has an account, what status/body is returned (409? 400? something inside `HTTPValidationError`)? Not documented as a response in the spec.
2. Same question for `POST /api/mobile/athletes/register` called twice for the same phone/email.
3. Does `POST /api/mobile/athletes/register`, when given the `athleteId` returned by `verify-otp`, attach to that same row — or can it create a duplicate athlete if `athleteId` is omitted after a phone that already went through `verify-otp`?
4. Is `PhoneOtpVerifyResponse` expected to gain an `isNewUser`/`profileCompletionStatus` field, or is the client expected to infer newness by calling `GET /api/mobile/athletes/{id}/profile` and checking `profileCompletionStatus == "incomplete"`?
5. Is `/api/auth/*` (Subsystem A) intended for this mobile app at all, or is it exclusively for a separate coach/admin web portal? If it is in scope for mobile, is coach self-signup planned, or will `role` remain permanently locked to `"student"` here?
6. What is the actual cookie/session mechanism behind `hamsai_session` (Set-Cookie attributes — `SameSite`, `Secure`, `HttpOnly`, TTL) so the Flutter cookie-jar configuration can be set up correctly?
7. Is there any authentication/authorization actually enforced on `/api/mobile/*` server-side that isn't visible in the OpenAPI spec (e.g., a reverse-proxy layer), or is it genuinely open given only an `athleteId`?

---

## 14. Final integration strategy

**Recommendation: build the "verify → check exists → create profile / sign in" flow entirely inside Subsystem B (phone/OTP), not Subsystem A.** Subsystem A is presently zero-integrated, has no OTP step of its own, hardcodes `role: "student"`, and requires infrastructure (cookie jar) the app doesn't have. Subsystem B is 80% built and only needs its existing wiring fixed. Two paths forward, in order of preference:

### Option 1 (recommended): fix Subsystem B, ask backend for one field
1. Ask backend to add `isNewUser` (or equivalent, e.g. expose `profileCompletionStatus` on the verify-otp response) to `PhoneOtpVerifyResponse` — this is the one server-side change that unblocks the exact flow described in the original request. Until then, the client can approximate it by calling `GET /api/mobile/athletes/{athleteId}/profile` immediately after verify-otp and branching on `profileCompletionStatus == "incomplete"`.
2. Fix `registerAthlete()` to send the correct camelCase, complete payload (`fullName/email/age/gender/phone`) matching `MobileAthleteRegistrationInput`.
3. Fix `updateMobileAthleteProfile()` field names to match `MobileAthleteProfileUpsertInput` (drop `sport_domain`/`family_support`/`pressure_sources`, which have no backend equivalent; add `discipline`/`academyClub`/etc.).
4. Fix `getAthleteProfile()` to unwrap `raw['profile']` instead of `raw['data']`.
5. Repoint/reshape the five onboarding-step calls and the two intake calls, or confirm with backend whether equivalent endpoints exist under different names/versions than currently assumed.
6. Decide whether the Bearer-token interceptor is worth keeping given it's not enforced anywhere — either get backend to add real auth to `/api/mobile/*`, or drop the pretense.

### Option 2: bring Subsystem A into the mobile app as a second, explicit flow
Only pursue this if product actually wants coach accounts or portal-style login inside this same mobile app. Requires: an email+password UI (doesn't exist), a cookie jar on `_mobileDio` (or a separate Dio instance), and backend confirmation on conflict-status codes (§13.1). Given `role` is hardcoded to `student` at signup, this would still need an admin-created coach account for any coach flow — self-service coach signup isn't possible against the current schema regardless of client changes.

Either way, the very first step — before writing any Dart — should be closing the open questions in §13 with the backend team, since two of them (duplicate-athlete risk, and whether `isNewUser` can be added) directly determine which of the two options above is even viable.
