# ASTRA — Complete Technical Product Flow Document

> Version: 1.0 · Date: 2026-05-19 · Status: Engineering Reference  
> Audience: Backend engineers, API contract designers, Flutter developers  
> Source: App screenshots (Polar + Non-Polar flows) + architecture.md

---

## Table of Contents

1. [Screen Inventory](#1-screen-inventory)
2. [Screen-by-Screen Flow Map](#2-screen-by-screen-flow-map)
3. [API Contract Requirements (Per Screen)](#3-api-contract-requirements-per-screen)
4. [Database Mapping (Per Screen)](#4-database-mapping-per-screen)
5. [State Management Flow](#5-state-management-flow)
6. [Polar BLE Flow](#6-polar-ble-flow)
7. [Saarthi AI Flow](#7-saarthi-ai-flow)
8. [Coach / Admin Flow](#8-coach--admin-flow)
9. [Offline Behavior & Sync Strategy](#9-offline-behavior--sync-strategy)
10. [Error States & Edge Cases](#10-error-states--edge-cases)

---

## 1. Screen Inventory

### 1.1 Splash Screen

**Screen Name:** `SplashScreen`  
**Route:** `/` (initial)  
**Purpose:** App entry point. Checks auth state and onboarding completion, then routes appropriately.

| Component | Type | Notes |
|---|---|---|
| ASTRA logo (A) | Image | Centered, teal gradient |
| "ASTRA" wordmark | Text | White, spaced caps |
| "YOUR PERSONAL INTELLIGENCE PLATFORM" | Text | Muted, small caps |
| Progress dots (partial) | Indicator | Loading state |

**Navigation:**
- Auth token valid + onboarding complete → `/home`
- Auth token valid + onboarding incomplete → `/onboarding/step/{n}`
- No auth token → `/welcome`

**State Checks (SharedPreferences):**
- `auth_token` — present → proceed to onboarding check
- `onboarding_complete` — bool
- `onboarding_step` — int (resume partial onboarding)

**Loading State:** Full-screen logo display (minimum 1.5s, then routes)  
**Error State:** Network timeout is ignored — routing decision is local only

---

### 1.2 Welcome / Onboarding Carousel

**Screen Name:** `WelcomeScreen`  
**Route:** `/welcome`  
**Purpose:** Marketing intro with 3 carousel slides. Entry point for Sign Up and Log In.

| Component | Type | Notes |
|---|---|---|
| ASTRA logo | Image | Top center |
| "Mental Performance AI" | Subtitle | Below logo |
| Carousel slide image | Image | Full-width card with rounded corners |
| Slide title "Performance" | Text | Bold, below image |
| Slide subtitle | Text | "Track mental performance, recovery and readiness..." |
| Dot indicators | Row | 3 dots, current page highlighted |
| "Sign Up Now" button | Primary CTA | Teal filled, full width |
| "Log In Here" | Text link | Teal color, below button |

**Carousel Slides (inferred from dots):**
1. Performance — "Track mental performance, recovery and readiness to unlock your full potential in competition."
2. [Needs backend confirmation — slide 2 content not captured]
3. [Needs backend confirmation — slide 3 content not captured]

**Navigation:**
- "Sign Up Now" → `/signup`
- "Log In Here" → `/login` (same flow, different label — **Needs backend confirmation**)

**Empty/Error State:** Static — no API calls on this screen.

---

### 1.3 Sign Up Screen

**Screen Name:** `SignUpScreen`  
**Route:** `/signup`  
**Purpose:** Entry method selection for new user registration.

| Component | Type | Notes |
|---|---|---|
| Back arrow (`<`) | Icon button | → `/welcome` |
| "Sign Up" | AppBar title | |
| "Meet Astra" | Heading | |
| Subtitle | Text | "Understanding what drives outcomes—from performance to relationships to daily life." |
| "Continue" button | Primary | → `/phone-entry` (phone OTP flow) |
| "OR" divider | Text | |
| "Continue with Google" | Outlined button | Google icon + text |
| "Continue with Apple" | Outlined button | Apple icon + text |
| Privacy Policy link | Tap link | External URL |
| Privacy disclaimer | Text | Small, below buttons |

**Navigation:**
- "Continue" → `PhoneEntryScreen`
- "Continue with Google" → Google OAuth flow (**Needs backend confirmation** — Supabase Google OAuth)
- "Continue with Apple" → Apple OAuth flow (**Needs backend confirmation** — Supabase Apple OAuth)

**Validation:** None on this screen (selection only).

---

### 1.4 Phone Number Entry Screen

**Screen Name:** `PhoneEntryScreen`  
**Route:** `/phone-entry`  
**Purpose:** Collect mobile number for OTP-based authentication.

| Component | Type | Notes |
|---|---|---|
| Back arrow | Icon button | → `/signup` |
| "Mobile number verification" | AppBar title | |
| Phone illustration | Image | |
| "Enter your phone number" | Heading | |
| "Mobile number" | Label | |
| Country picker "IN (+91)" | Dropdown | Country code selector |
| Phone input | TextField | Placeholder "123-456-7890", numeric keyboard |
| Hint text | Text | "ASTRA will send you a text..." |
| "What if my number changes?" | Text link | **Needs backend confirmation** |
| "Continue" button | Primary | Disabled until phone entered; → OTP screen |

**Validation:**
- Phone number: 10 digits minimum (post country code strip)
- Country code: must be selected
- Button disabled until valid format

**Loading State:** Button shows spinner while Supabase OTP request is in flight.

**Error States:**
- Invalid phone format → inline error below input
- Supabase OTP failure → toast "Failed to send code. Try again."
- Rate limit hit → toast "Too many attempts. Wait 60 seconds."

**API Call:**
```
POST /auth/v1/otp
Body: { "phone": "+919999999999" }
```

---

### 1.5 OTP Verification Screen

**Screen Name:** `OtpVerificationScreen`  
**Route:** `/otp-verify`  
**Purpose:** Verify 6-digit OTP sent to the user's mobile number.

| Component | Type | Notes |
|---|---|---|
| Back arrow | Icon button | → `/phone-entry` |
| "Mobile number verification" | AppBar title | |
| Envelope illustration | Image | |
| "Enter your verification code" | Heading | |
| 6 OTP input boxes | PinInput | Auto-advance on digit entry |
| "Sent to 911-472-5836. Edit" | Text | "Edit" is a tap link → back to phone entry |
| "Didn't get a code?" | Text link | Triggers resend OTP |
| "Continue" button | Primary | Disabled until 6 digits entered; verifies OTP |

**Validation:**
- Exactly 6 digits
- Auto-submit on 6th digit entry

**Loading State:** Button shows spinner during verification.

**Error States:**
- Wrong OTP → "Invalid code. Please try again."
- Expired OTP → "Code expired. Tap 'Didn't get a code?' to resend."
- Max attempts → "Too many attempts. Request a new code."

**On Success:**
- First-time user → `/onboarding/step/1`
- Returning user (onboarding complete) → `/home`
- Returning user (partial onboarding) → `/onboarding/step/{saved_step}`

**API Calls:**
```
POST /auth/v1/verify
Body: { "phone": "+919999999999", "token": "123456", "type": "sms" }

Response (success):
{
  "access_token": "<jwt>",
  "refresh_token": "<opaque>",
  "user": { "id": "<uuid>", ... }
}
```

**SharedPreferences Written:**
- `auth_token`
- `refresh_token`

---

### 1.6 Onboarding Step 1 — Personal Details

**Screen Name:** `OnboardingStep1Screen`  
**Route:** `/onboarding/step/1`  
**Purpose:** Collect basic personal information to create athlete profile.

| Component | Type | Notes |
|---|---|---|
| Back arrow | Icon button | → previous or Welcome |
| Progress bar | LinearProgress | 1/4 filled |
| "STEP 1 OF 4" | Caption | |
| "Welcome to Astra Performance." | Heading | Bold |
| Subtitle | Text | "Let's build your baseline..." |
| "Full Name" label + input | TextField | Placeholder "e.g. Jane Doe" |
| "Age" label + input | TextField | Numeric, placeholder "Enter your age" |
| "Gender" | Label | |
| Male / Female / Other | Checkboxes | Single-select (radio behavior) |
| "City" label + input | TextField | Placeholder "Where do you live?" |
| "Continue to Step 2" | Primary button | Disabled until all required fields filled |

**Validation:**
- Full Name: required, min 2 chars
- Age: required, numeric, 10–80 range
- Gender: required (one selection)
- City: required, min 2 chars

**Loading State:** None (local step)

**Navigation:** → `/onboarding/step/2`

**SharedPreferences Written:** `onboarding_step` = 1, partial profile data

---

### 1.7 Onboarding Step 2 — Shooting Profile

**Screen Name:** `OnboardingStep2Screen`  
**Route:** `/onboarding/step/2`  
**Purpose:** Collect sport-specific profile to personalize the training dashboard.

| Component | Type | Notes |
|---|---|---|
| Back arrow | Icon button | → Step 1 |
| Progress bar | LinearProgress | 2/4 filled |
| "STEP 2 OF 4" | Caption | |
| "Your shooting profile" | Heading | |
| Subtitle | Text | "Tell us about your current discipline..." |
| "Discipline" dropdown | DropdownButton | Default "Air Pistol"; options: Air Pistol, Air Rifle, 10m, 25m Pistol, 50m Rifle, etc. (**Needs backend confirmation** for full list) |
| Helper text | Text | "select your primary shooting event" |
| "Experience Level" | Label | |
| Beginner / Intermediate / Advance | Segmented control | Single-select |
| "Years shooting" | Label | |
| Stepper (– / value / +) | Counter | Default 0, min 0 |
| "Academy / Club" label | Label | Marked "optional" |
| Academy input | TextField | Placeholder "Enter your academy or club" |
| "Continue to Step 3" | Primary button | |

**Validation:**
- Discipline: required (dropdown selection)
- Experience Level: required
- Years shooting: >= 0
- Academy: optional

**Navigation:** → `/onboarding/step/3`

**SharedPreferences Written:** `onboarding_step` = 2

---

### 1.8 Onboarding Step 3 — Performance Baseline

**Screen Name:** `OnboardingStep3Screen`  
**Route:** `/onboarding/step/3`  
**Purpose:** Capture current performance level and identify mental obstacles.

| Component | Type | Notes |
|---|---|---|
| Back arrow | Icon button | → Step 2 |
| Progress bar | LinearProgress | 3/4 filled |
| "STEP 3 OF 4" | Caption | |
| "Where are you now?" | Heading | |
| Subtitles | Text | "Let's understand your baseline..." |
| "Average practice score:" | Label | |
| Score input | TextField | Numeric, placeholder "150" |
| "Target score:" | Label | |
| Target input | TextField | Numeric, placeholder "580" |
| "What's getting in the way?" | Heading | "Select up to 3" |
| Checkbox list items | Checkboxes | 5 options (multi-select up to 3): |
| • Nervousness in competition | Checkbox | |
| • Overthinking scores | Checkbox | |
| • Poor sleep | Checkbox | |
| • Distractions | Checkbox | |
| • Pressure in big moments | Checkbox | |
| "Continue to Step 4" | Primary button | |

**Validation:**
- Average practice score: numeric, optional
- Target score: numeric, optional
- Obstacles: 0–3 selections (enforce max 3)

**Navigation:** → `/onboarding/step/4`

**SharedPreferences Written:** `baseline_scores`, `onboarding_step` = 3

---

### 1.9 Onboarding Step 4 — Goal Setting

**Screen Name:** `OnboardingStep4Screen`  
**Route:** `/onboarding/step/4`  
**Purpose:** Set 30-day and 6-month performance targets.

| Component | Type | Notes |
|---|---|---|
| Back arrow | Icon button | → Step 3 |
| Progress bar | LinearProgress | 4/4 filled |
| "STEP 4 OF 4" | Caption | |
| "Set your goals" | Heading | |
| Subtitle | Text | "Specific goals give your training direction..." |
| "30-day target" label | Label | |
| Duration chip "Next 30 days" | Chip | Non-interactive label |
| 30-day textarea | TextField multiline | Placeholder "Example: Average 575+ in competition"; mic icon for voice input |
| "6-month target" label | Label | |
| Duration chip "6 months" | Chip | Non-interactive label |
| 6-month textarea | TextField multiline | Placeholder "Example: Compete at nationals with 590+ average"; mic icon |
| Tip box | Card | Yellow border, "Best goals are specific and measurable..." |
| "Continue" button | Primary | |
| "You can update your goals anytime" | Caption | Below button |

**Validation:**
- Both fields: optional but encouraged

**Navigation:** → Psychology Questions (`/psychology/questions`)

**SharedPreferences Written:** `onboarding_step` = 4

**API Call (on Continue):**  
Persist athlete profile to Supabase — all 4 steps batched:
```
POST /rest/v1/athletes
Headers: Prefer: return=representation
Body: { full_name, date_of_birth (inferred from age), gender, ... }

POST /rest/v1/athlete_details
Body: { athlete_id, discipline, experience_years, goals: [goal_30d, goal_6m], ... }
```

---

### 1.10 Psychology Assessment Questions

**Screen Name:** `PsychologyQuestionsScreen`  
**Route:** `/psychology/questions`  
**Purpose:** Collect baseline psychology responses across dimensions (25 questions total).

| Component | Type | Notes |
|---|---|---|
| "Questions" label | AppBar label | Left-aligned |
| "2/25" counter | Chip | Top-right, shows progress |
| Progress bar | LinearProgress | Top of screen, thin |
| Question text | Heading large | Scenario-based question |
| Answer choices | Checkbox list | 4 options, single-select |
| "Explain your answer" label | Text | Teal color |
| Explanation textarea | TextField multiline | Placeholder "Write your message here..." |
| "Back" | Text button | Left |
| "Next" | Primary button | Right; advances to next question |
| "Skip for now" | Text link | Below buttons; skips entire section |

**Sample Question (visible):**  
"You have hit a string of perfect 10s and feel a 'rush' of excitement. How do you handle this sudden surge?"
- Acknowledge the success, exhale, and return to my technical process.
- Enjoy the feeling but try to keep my physical movements steady.
- **Start thinking about the perfect score and feel my heart race.** (selected)
- Get overexcited and rush the next shot to keep the streak going.

**Validation:**
- Selection required before Next (or use Skip)
- Explanation: optional free text

**Navigation:**
- "Next" on last question → Polar Permissions screen
- "Skip for now" → Polar Permissions screen
- Incomplete assessment → shown as "Psychology Assessment Pending" on Home dashboard

**API Call (per answer):**
```
POST /rest/v1/psychology_responses
Body: {
  "athlete_id": "<uuid>",
  "question_id": "<uuid>",
  "response_value": "3",          // option index or text
  "explanation": "optional text"  // if provided
}
```

**Database Read:** `SELECT * FROM psychology_questions ORDER BY display_order`  
**Empty State:** If no questions configured → skip screen (**Needs backend confirmation**)

---

### 1.11 Polar Permissions Screen

**Screen Name:** `PolarPermissionsScreen`  
**Route:** `/polar/permissions`  
**Purpose:** Request required system permissions before Polar BLE setup.

| Component | Type | Notes |
|---|---|---|
| Heart icon | Image | Pink/red square, top-left |
| "Your heart tells the truth" | Heading | |
| Subtitle | Text | "We use your Polar device to measure stress, focus, and recovery..." |
| "To continue, we need" | Divider label | |
| Bluetooth row | ListTile | Bluetooth icon, "To connect to Polar", chevron → system dialog |
| Notifications row | ListTile | Bell icon, "For session reminders", chevron → system dialog |
| Microphone row | ListTile | Mic icon, "Optional" chip, "For session reminders", chevron |
| "Continue & Allow" | Primary button | Triggers permission requests |
| "I don't have a polar yet" | Text link | → skips to `/home` without BLE setup |

**Navigation:**
- "Continue & Allow" → triggers BLE scan → `PolarScanScreen`
- "I don't have a polar yet" → `/home` (Polar-not-connected state)

**Permission Logic (Android/iOS):**
1. Bluetooth scan + connect permissions
2. Push notification permission
3. Microphone (optional, skip if denied)

---

### 1.12 Polar Device Scan Screen

**Screen Name:** `PolarScanScreen`  
**Route:** `/polar/scan`  
**Purpose:** Scan for nearby Polar devices and allow user to select and connect.

| Component | Type | Notes |
|---|---|---|
| WiFi-like scan icon | Image | Teal circle |
| "Can't find your device?" | Text | Above device list when no device found |
| "Try again or continue without Polar for now." | Subtitle | |
| "Having trouble?" | Section heading | |
| "No Polar device was found during this scan." | Body | |
| "Found devices" divider | Label | |
| Device list item | ListTile | Bluetooth icon, "Polar H10 (Demo)", "H10" subtitle, "Connect" button (teal) |
| Warning card | Card | Orange border, "Having trouble?" heading, explanation text, "Troubleshoot / Try again" teal link |
| "Continue without Polar" | Primary button | Bottom → `/polar/baseline` or `/home` |

**States:**
- Scanning: pulsing icon animation, no devices listed yet
- Device found: device list appears with "Connect" buttons
- Device not found after timeout: warning card shown
- Connected: → transition to `PolarConnectedScreen`

**Interactions:**
- "Connect" button on device → initiates `PolarBleApi.connectToDevice(deviceId)`
- "Troubleshoot / Try again" → retriggers scan
- "Continue without Polar" → `/home` (Polar-not-connected state)

---

### 1.13 Polar Connected Confirmation Screen

**Screen Name:** `PolarConnectedScreen`  
**Route:** `/polar/connected`  
**Purpose:** Confirm successful device connection before proceeding to baseline measurement.

| Component | Type | Notes |
|---|---|---|
| Green checkmark circle | Image | Green background |
| "Connected to Polar H10 (Demo)" | Caption | Green text |
| "Device connected" | Heading | Bold |
| Body text | Text | "Your heart rate and HRV data will now be tracked during sessions." |
| "Found devices" divider | Label | (visible but list empty — all connected) |
| "Done Let's go" | Primary button | → `BaselinePromptScreen` |

**SharedPreferences Written:** `polar_device_id` = deviceId

**API Call:**
```
POST /rest/v1/polar_devices
Headers: Prefer: return=representation
Body: {
  "athlete_id": "<uuid>",
  "device_id": "Polar_H10_Demo",
  "model": "H10",
  "last_connected": "<now_utc>",
  "is_primary": true
}
```

---

### 1.14 Baseline Measurement Prompt Screen

**Screen Name:** `BaselinePromptScreen`  
**Route:** `/polar/baseline/prompt`  
**Purpose:** Instruct athlete to sit still for 60-second resting HR baseline measurement.

| Component | Type | Notes |
|---|---|---|
| Heart icon | Image | Pink/red square |
| "Let's measure your baseline" | Heading | |
| Body text | Text | "We need to know your resting heart rate..." |
| "Sit comfortably" row | ListTile | Bluetooth icon (repurposed) |
| "Breathe normally" row | ListTile | Bell icon |
| "Don't move" row | ListTile | Mic icon |
| "Start - 60 sec" | Primary button | → `BaselineCapturingScreen` |

**Navigation:** "Start - 60 sec" → begins 60-second HR capture

---

### 1.15 Baseline Capturing Screen

**Screen Name:** `BaselineCapturingScreen`  
**Route:** `/polar/baseline/capturing`  
**Purpose:** Live 60-second resting HR measurement with countdown and waveform visualization.

| Component | Type | Notes |
|---|---|---|
| "Capturing baseline..." | Body text | Top |
| Heart animation | Pulsing circle | Pink circle with heart icon |
| BPM value "75" | Large text | Teal/brand color, updates live |
| "BPM" label | Caption | |
| HR waveform | Bar chart | Red bars, last ~30 readings |
| "01:00 remaining" | Timer | Clock icon + countdown |
| Progress bar | LinearProgress | Teal, advances as time counts down |
| "Stay still - movement affects accuracy" | Caption | Below progress bar |

**Behavior:**
- Subscribes to HR stream from Polar H10
- Accumulates 60 readings
- Countdown from 60 → 0
- On completion → calculates mean BPM → `BaselineResultScreen`
- If Polar disconnects during capture → show error, offer retry

---

### 1.16 Baseline Result Screen

**Screen Name:** `BaselineResultScreen`  
**Route:** `/polar/baseline/result`  
**Purpose:** Show captured resting HR and confirm baseline saved.

| Component | Type | Notes |
|---|---|---|
| Green checkmark circle | Image | |
| "Your resting heart rate is" | Heading | |
| BPM value "66" | Large text | Green, bold |
| "BPM" label | Caption | |
| "Baseline saved" card | Card | Green border, explanatory text: "This is your personal baseline. We'll use it to detect when stress affects your performance..." |
| "Continue" | Primary button | → `OnboardingCompleteScreen` |

**SharedPreferences Written:** `baseline_hr` = 66 (int)

**API Call:**
```
PATCH /rest/v1/athlete_details?athlete_id=eq.<uuid>
Body: { "resting_hr": 66 }
```

---

### 1.17 Onboarding Complete / You're All Set Screen

**Screen Name:** `OnboardingCompleteScreen`  
**Route:** `/onboarding/complete`  
**Purpose:** Summarize onboarding results and launch into the main app.

| Component | Type | Notes |
|---|---|---|
| WiFi/connected icon | Image | Teal circle |
| "You're all set, {first_name}" | Heading | Personalized |
| "Here's your starting point:" | Subtitle | |
| Summary card | Card | 3 rows: Discipline / Goal / Resting HR |
| Discipline row | Row | "Air Pistol" |
| Goal row | Row | "560 in 30d" |
| Resting HR row | Row | "68 bpm" |
| "Ready to train" | Caption | |
| "Go to Home" | Primary button | → `/home` |

**SharedPreferences Written:**
- `onboarding_complete` = true
- `onboarding_step` = 4

---

### 1.18 Athlete Home Screen (Dashboard)

**Screen Name:** `AthleteHomeScreen`  
**Route:** `/home`  
**Purpose:** Main dashboard showing daily readiness metrics, session CTA, and AI coach summary.

#### TWO STATES:

**State A — Polar Connected:**

| Component | Notes |
|---|---|
| ASTRA logo + "Athlete Home" | Header |
| Bell icon | Notification button, top-right |
| "Polar connected" badge | Green dot + teal chip — Polar connected state |
| Psychology Assessment Pending card | "You have 23 questions remaining" + "Continue" teal button → `/psychology/questions` |
| READINESS card | "60" + "moderate" label |
| RECOVERY card | "48" + "acceptable" label |
| STRESS card | "40" + "moderate" label |
| MENTAL STATE card | "Steady" (text value) + "steady" label |
| Session Action Center card | "Start Training Session" button → SessionSetup |
| Coach Quick Summary card | Numbered 1-2-3 list of coach tips + Saarthi avatar |
| Bottom nav | Home (active) / Sessions / Insight / Profile |

**State B — Polar NOT Connected:**

| Component | Notes |
|---|---|
| "Polar not connected" card | Heart icon, "Connect Polar to unlock BPM, HRV, and physiology insights." + "Connect Polar Device" button → `/polar/scan` |
| All other cards | Same as State A |
| Saarthi avatar | Floating action area, bottom-right |

**Readiness/Recovery/Stress/Mental State Computation:**
- Derived from last `daily_checkins` record
- If no checkin today → values default to 0 or "—"

**API Calls (on mount):**
```
GET /rest/v1/daily_checkins?athlete_id=eq.<uuid>&checkin_date=eq.<today>&limit=1
GET /rest/v1/ai_insights?athlete_id=eq.ATH001&is_read=eq.false&order=priority.desc&limit=3
GET /rest/v1/performance_summary?athlete_id=eq.ATH001&order=created_at.desc&limit=1
POST /rest/v1/rpc/get_dashboard_data   body: { "p_athlete_id": "ATH001" }
```

**Navigation:**
- "Continue" (Psychology pending) → `/psychology/questions`
- "Start Training Session" → `CheckInScreen` (pre-session flow starts with check-in)
- "Connect Polar Device" → `/polar/scan`
- Saarthi avatar → `SaarthiChatScreen`
- Bell → Notifications (**Needs backend confirmation**)
- Bottom nav Sessions → `/sessions`
- Bottom nav Insight → `/insights`
- Bottom nav Profile → `/profile`

---

### 1.19 Saarthi AI Chat Screen

**Screen Name:** `SaarthiChatScreen`  
**Route:** `/saarthi`  
**Purpose:** Conversational AI coaching interface with quick-action shortcuts.

| Component | Type | Notes |
|---|---|---|
| Back arrow | Icon button | |
| Saarthi avatar (circular) | Image | Animated character, blue/teal |
| "Saarthi AI" | Title | |
| "● Online" | Status | Green dot |
| Close (×) | Icon button | Dismiss chat |
| Talk to Saarthi banner | Card | Large animated banner with "Talk to Saarthi, your personal guide" + waveform animation + chevron |
| "Quick actions" | Section label | |
| "Analyze last session" | Quick action card | Icon + title + subtitle "Review shot spread and metrics" |
| "Technique tips" | Quick action card | "Get advice on grip and breathing" |
| "Plan next training" | Quick action card | "Set goals for your upcoming session" |
| "Breathing control" | Quick action card | "Improve your breathing techniques" |
| "Mental focus coaching" | Quick action card | "Build focus and concentration" |
| Attachment icon | Icon button | Message input left |
| "Type your message..." | TextField | Chat input |
| Send button | Icon button | Teal circle → sends message |

**Quick Action Behavior:**  
Each quick action → pre-fills context message and sends automatically to Saarthi Edge Function.

**Message Flow:**
1. User types or taps quick action
2. Message appended to chat history locally
3. POST to Saarthi Edge Function
4. Response appended to chat history
5. INSERT both turns to `athlete_chat` table (non-blocking)

**Empty State:** Banner + Quick actions grid (no chat history)  
**Loading State:** Typing indicator (3 dots animation) while waiting for Saarthi response

**API Call:**
```
POST /functions/v1/saarthi-chat
Headers: Authorization: Bearer <user_jwt>
Body: {
  "athlete_id": "<uuid>",
  "session_id": null,
  "message": "Analyze last session",
  "context_mode": "general"
}
Response: {
  "reply": "...",
  "suggestions": ["..."],
  "mood_flag": null
}
```

---

### 1.20 Daily Check-in Screen

**Screen Name:** `DailyCheckinScreen`  
**Route:** `/checkin`  
**Purpose:** Pre-session emotional and physical readiness check. Feeds dashboard metrics.

| Component | Type | Notes |
|---|---|---|
| Back arrow | Icon button | |
| "Daily Check-in" | AppBar title | |
| "How are you feeling?" | Section heading | |
| 5 emoji options | Row of cards | Trouble / Poor / Okay / Good / Great (single select) |
| "Energy level" | Section heading | |
| Slider | Slider | 1–10, Low → High labels, current value "5" shown below |
| "How did you sleep?" | Section heading | |
| Sleep duration chips | Row | <5h / 5-6h / 6-7h / 7-8h / 8h+ (single select) |
| "Any of these apply?" (optional) | Section heading | |
| Mood tags | Wrap/chips | Anxious / Confident / Focused / Distracted / Motivated / Calm (multi-select) |
| "Save Check-in and Continue" | Primary button | Disabled until feeling + energy + sleep selected |

**Validation:**
- Feeling: required (one emoji)
- Energy level: required (slider, default 5)
- Sleep duration: required (one chip)
- Mood tags: optional

**Mapping (feeling emoji → numeric score):**
- Trouble = 1–2
- Poor = 3–4
- Okay = 5–6
- Good = 7–8
- Great = 9–10

**API Call:**
```
POST /rest/v1/daily_checkins
Headers: Prefer: return=representation
Body: {
  "athlete_id": "<uuid>",
  "checkin_date": "2026-05-19",
  "mood": 7,
  "energy": 5,
  "sleep_quality": 8,
  "sleep_hours": 7.5,    // mapped from chip selection
  "stress_level": null,  // not collected here — Needs backend confirmation
  "soreness": null,
  "notes": "Anxious, Focused"  // comma-joined tags
}
```

**SharedPreferences Written:** `current_checkin` = JSON  
**Navigation:** → `SessionSetupScreen`

---

### 1.21 Session Setup Screen

**Screen Name:** `SessionSetupScreen`  
**Route:** `/session/setup`  
**Purpose:** Configure session parameters before beginning training.

| Component | Type | Notes |
|---|---|---|
| Back arrow | Icon button | |
| "Set up your session" | AppBar title | |
| "New session" | Heading | |
| "Set up your training parameters." | Subtitle | |
| "Range type today" | Label | |
| Paper / Electronic toggle | SegmentedButton | Paper (dark/selected) / Electronic |
| "Session type" | Label | |
| Scoring / Grouping / Dry Fire | Chip selection | Single-select |
| "Planned shots" | Label | |
| Stepper (– / value / +) | Counter | Default 60 |
| Quick-select chips | Row | 20 / 40 / **60** (highlighted) / 80 / 100 / 120 |
| "Discipline" | Label | |
| Discipline dropdown | DropdownButton | Default "Air Pistol" (from profile) |
| "Begin Ritual" | Primary button | Play icon + text → `PreSessionRitualScreen` |

**Validation:**
- Range type: required (default Paper)
- Session type: required (no default — must select)
- Planned shots: required (default 60)
- Discipline: required (defaults from profile)

**SharedPreferences Written:** `session_setup` = JSON {rangeType, sessionType, plannedShots, discipline}

**API Call (non-blocking session creation):**
```
POST /rest/v1/App_Sessions
Headers: Prefer: return=representation
Body: {
  "athlete_id": "ATH001",
  "session_type": "training",
  "range_type": "paper",
  "planned_shots": 60,
  "start_time": "<now_utc>",
  "status": "active"
}
Response: [{ "id": "<session_uuid>", ... }]
```

**SessionMemory Written:** `SessionMemory.sessionId` = response id

---

### 1.22 Pre-Session Ritual Screen

**Screen Name:** `PreSessionRitualScreen`  
**Route:** `/session/ritual`  
**Purpose:** Guided breathing/focus routine before session begins. (**Needs backend confirmation** — content not visible in screenshots; inferred from "Begin Ritual" button)

**Inferred UI (based on button label + app context):**
- Animated breathing guide (expand/contract)
- Timer countdown
- Optional Saarthi voice cue
- "Start Session" button → `LiveTrainingScreen`

---

### 1.23 Live Training Screen (Polar Connected)

**Screen Name:** `LiveTrainingScreen`  
**Route:** `/session/live`  
**Purpose:** Active session monitoring with real-time heart rate display and session controls.

**Polar-Connected State:**

| Component | Type | Notes |
|---|---|---|
| "● Live" badge | Status chip | Green dot + "Live" |
| "Paper Session" | AppBar title | Dynamic (Paper/Electronic) |
| Timer "0:01" | Timer | Session elapsed time, top-right |
| HR card | Card | Heart icon, "72 bpm", "Baseline 65 ↑ +7" |
| HR bar chart | Chart | Red bars, "HR Last 30 Readings" label |
| "Pause" | Secondary button | Suspends session, telemetry pauses |
| "✓ End Session" | Primary button | Ends session → `ScoreEntryScreen` |

**Non-Polar State:**  
No HR card — screen may show timer only or go directly to score entry (**Needs backend confirmation**)

**Telemetry Behavior:**
- HR stream: subscribed → buffered every 10s → bulk POST
- Pause: suspends buffer flush, marks session `paused` in Supabase
- End: flushes remaining buffer, marks session `completed`

**API Calls (continuous, non-blocking):**
```
POST /rest/v1/hr_stream   (every 10s)
Headers: Prefer: return=minimal
Body: [ array of { time, session_id, athlete_id, bpm, rr_interval } ]

PATCH /rest/v1/App_Sessions?id=eq.<session_id>
Body: { "status": "paused" }   // on Pause

PATCH /rest/v1/App_Sessions?id=eq.<session_id>
Body: { "status": "active" }   // on Resume
```

**Navigation:**
- "End Session" → `ScoreEntryScreen` (if paper) or directly to `ReflectionScreen` (if electronic — **Needs backend confirmation**)

---

### 1.24 Score Entry Screen

**Screen Name:** `ScoreEntryScreen`  
**Route:** `/session/score`  
**Purpose:** Enter series totals for paper target sessions. Series count derived from `plannedShots / 10`.

| Component | Type | Notes |
|---|---|---|
| Back arrow | Icon button | |
| "Paper Session" | AppBar title | |
| "Enter your series total score" | Heading | |
| "Enter the total score for this series." | Subtitle | |
| "Series {n} of {total}" | Label | e.g. "Series 2 of 2" |
| Active series card | Card | Series number, "10 shots", "Max score: 109", input field, "Save Score" button |
| Score input | TextField | Large numeric input, placeholder "0" |
| "Save Score ✓" | Button | Inside card, teal |
| "So far in session" | Section label | |
| Past series list | List | Series 1: 65, Series 2: — (pending) |
| "Running total" card | Card | Trend icon, "Running total", "After 1 of 2 series", score "65 / 218" |
| "↩ Undo last entry" | Text link | Bottom, teal |

**Max Score Calculation:**
```
max_per_series = shots_per_series × 10.9   // 10 shots × 10.9 = 109
total_max = series_count × max_per_series
```

**Validation:**
- Score: numeric, 0 ≤ value ≤ max_per_series
- "Save Score" disabled until valid score entered

**"All series entered" State:**

When all series are filled:
- Header changes to "All series entered"
- Subtitle: "Review your scores and continue."
- "Continue to Summary ✓" button appears (primary)
- All series listed with their scores
- "Running total" shows final total / max

**Navigation:** "Continue to Summary" → `ReflectionScreen`

**SharedPreferences Written:** `score_summary` = [{seriesNumber, shots, total}, ...]

**API Calls (non-blocking, after all series saved):**
```
POST /rest/v1/performance_summary
Headers: Prefer: return=representation
Body: {
  "athlete_id": "ATH001",
  "session_id": "<session_uuid>",
  "total_score": 123,
  "max_possible": 218,
  "avg_per_shot": 6.15,
  "score_variance": 0.34,
  "consistency_pct": 62.0,
  "performance_rating": 6,
  "focus_level": "moderate"
}
```

---

### 1.25 Reflection Screen

**Screen Name:** `ReflectionScreen`  
**Route:** `/session/reflection`  
**Purpose:** Post-session debrief with emotional rating and qualitative feedback.

| Component | Type | Notes |
|---|---|---|
| Back arrow | Icon button | |
| "Reflect" | Heading | |
| "A few quick questions to choose the loop" | Subtitle | |
| "How did it feel?" | Section heading | |
| 5 emoji options | Row | Trouble / Poor / Okay / Good / **Great** (selected, circled) |
| "What Worked" | Section heading | |
| Text area | TextField multiline | "Write your message here..." |
| "What Didn't" | Section heading | |
| Text area | TextField multiline | "Write your message here..." |
| "What went well today?" | Section heading | |
| Text area | TextField multiline | "Text area for athlete input" |
| "Save & View Summary" | Primary button | |

**Validation:**
- Emoji rating: required
- Text areas: optional

**API Calls:**
```
POST /rest/v1/session_reflections
Headers: Prefer: return=representation
Body: {
  "session_id": "<session_uuid>",
  "athlete_id": "<uuid>",
  "what_went_well": "...",
  "what_to_improve": "...",
  "key_takeaway": "...",
  "emotion_rating": 5
}

PATCH /rest/v1/App_Sessions?id=eq.<session_uuid>
Body: { "status": "completed", "end_time": "<now_utc>" }
```

**Navigation:** → `SessionSummaryScreen`

---

### 1.26 Session Summary Screen

**Screen Name:** `SessionSummaryScreen`  
**Route:** `/session/summary`  
**Purpose:** Post-session performance overview with metric cards, history, and score analysis.

| Component | Type | Notes |
|---|---|---|
| Back arrow | Icon button | |
| "Astra Performance" | Supertitle | Teal |
| "Sessions" | Heading | |
| "Last session summary, history and score analysis" | Subtitle | |
| PERFORMANCE card | MetricCard | "6.2" + "● last session" |
| READINESS card | MetricCard | "62" + "● warm up slowly" |
| HOLD STABILITY card | MetricCard | "6.5" + "● session best" |
| MENTAL SCORE card | MetricCard | "55" + "● steady focus" |
| "Last Session Summary" card | Card | Teal headline "Stable hold with recovery watch", "Avg 6.2/shot · 20 shots · 0:00", "Best series: S1: 65 · Worst: S2: 58" |
| "Session History" card | Card | Latest row: Score 6.2 / Eff 62% / Best S1:65; Earlier row: Worst S2:58 / Shots 20 / 0:00 |
| "Score Analysis" card | Card | "Avg 6.2/shot · efficiency at 62%.", "Best shot: 6.5 · Worst: 5.8 · Consistency gap: 0.7 pts." |
| "Save & View Full Report" | Primary button | → `SessionReportScreen` |

**Metric Definitions:**
- PERFORMANCE = performance_rating (avg/shot)
- READINESS = from daily_checkins readiness score
- HOLD STABILITY = best avg/shot across series (approximation from ACC if Polar connected; else score-based)
- MENTAL SCORE = psychology composite score

**Data Source:** `performance_summary` table + `session_series` + `psychology_scores`

---

### 1.27 Full Session Report Screen

**Screen Name:** `SessionReportScreen`  
**Route:** `/session/report`  
**Purpose:** Detailed session performance comparison with athlete historical average.

| Component | Type | Notes |
|---|---|---|
| Back arrow | Icon button | |
| "HamsaTech" | Supertitle | |
| "Shooting / Training" | Heading | |
| "Daily session performance and average comparison" | Subtitle | |
| HOLD STABILITY card | MetricCard | "6.5" + "● +0.3 vs avg" |
| CONSISTENCY card | MetricCard | "62%" + "● -9%" |
| MENTAL FOCUS card | MetricCard | "55" + "● steady focus" |
| LATEST SCORE card | MetricCard | "6.2" + "● +0.12" |
| "Today vs Athlete Average" card | Card | "Today: 6.2" vs "Period avg: 6.03" side by side |
| "Latest Session Score Pattern" card | Card | Series bubbles: "65" / "58" circles, "Session score, focus and comparison" caption |
| "Continue to Insights" | Primary button | → `InsightsScreen` |

---

### 1.28 Insights Screen

**Screen Name:** `InsightsScreen`  
**Route:** `/session/insights`  
**Purpose:** Psychology + physiology analysis after session completion.

| Component | Type | Notes |
|---|---|---|
| Back arrow | Icon button | |
| "Today's Sessions" | AppBar title | |
| "Astra Performance" | Supertitle | Teal |
| "Insights" | Heading | |
| "Psychology, physiology and score-vs-HR trust" | Subtitle | |
| SOCIAL card | MetricCard | "60" + "● functional" |
| AROUSAL card | MetricCard | "50" + "● conditioning" (orange) |
| DECISION card | MetricCard | "90" + "● elite" |
| FOCUS card | MetricCard | "80" + "● elite" |
| "Physiology Explained" card | Card | HR badge + HRV badge + ACC badge with text explanations (Polar-connected only) |
| "Performance Recommendation" card | Card | Bold headline + body paragraph + bullet points |
| "Score vs HR Trust" chart | Card | Line chart: Score trust (teal) / Heart rate (red) / Threshold (orange dashed), legend below |
| "Save and Continue" | Primary button | → Back to Home or next flow step |

**Polar-Not-Connected State ("Physiology Insights" card):**  
Shows: "Polar not connected. Connect Polar to unlock BPM, HRV, and physiology insights." + "Connect Polar Device" button

**Psychology Dimension Labels (visible):**
- Social, Arousal, Decision, Focus (from profile psychology_scores)

**Data Source:**
- `psychology_scores` (latest)
- `hr_stream` (session aggregated — if Polar connected)
- `ai_insights` (performance recommendation)
- `performance_summary`

**API Call:**
```
GET /rest/v1/ai_insights?athlete_id=eq.ATH001&session_id=eq.<uuid>&order=priority.desc&limit=3
GET /rest/v1/psychology_scores?athlete_id=eq.<uuid>&session_id=eq.<uuid>
```

---

### 1.29 Profile Screen

**Screen Name:** `ProfileScreen`  
**Route:** `/profile`  
**Purpose:** Athlete identity, performance stats, psychology scores, and goal management.

| Component | Type | Notes |
|---|---|---|
| Back arrow | Icon button | |
| "Profile" | AppBar title | |
| "Astra Performance" | Supertitle | Teal |
| "Athlete Profile" | Heading | |
| "Identity, coach, psychology and score history" | Subtitle | |
| Avatar | CircleAvatar | "A" placeholder (no photo set) |
| Athlete name "Athlete" | Text | Bold |
| "Coach — Not linked" | Caption | |
| Streak counter | Badge | "🔥 1 streak" (with-Polar) / "🔥 0 streak" (without-Polar) |
| Rank badge | Badge | "Lvl 1 rank" |
| Attribute chips | Row | "Right dominant" / "Intermediate" / "Training" |
| BEST AVG card | MetricCard | "—" (30 days) |
| PERIOD AVG card | MetricCard | "—" (2 sessions) |
| BEST SERIES card | MetricCard | "—" (all time) |
| LAST SESSION card | MetricCard | "2" sessions total |
| "Quick Psychology Scores" | Section heading | |
| Score bars | List | Social 72 / Arousal 61 / Decision 80 / Focus 82 / Recovery 66 (colored progress bars) |
| "Goals" section | Section | |
| "Edit Goals →" | Text link | → Goals editing screen (**Needs backend confirmation**) |
| Short-term (30 Days) | GoalRow | "Not set yet" + "0%" progress |
| Long-term (6 Months) | GoalRow | "Not set yet" + "0%" progress |
| Dream Goal | GoalRow | Star icon + "Not set yet" |
| "Sign Out" | Destructive button | Red, full width → logs out, clears tokens, → `/welcome` |

**Navigation (bottom nav):**  
Profile tab is active. Other tabs: Home / Sessions / Insight

**Sign Out Behavior:**
1. Clear `auth_token`, `refresh_token` from SharedPreferences
2. Clear `onboarding_complete` (do NOT clear — user stays onboarded)
3. Navigate → `/welcome`
4. (Non-blocking) Supabase Auth signOut call

---

### 1.30 Sessions List Screen

**Screen Name:** `SessionsScreen`  
**Route:** `/sessions`  
**Purpose:** Browse session history. (**Needs backend confirmation** — screenshots show post-session summary on this tab, not a list)

**Inferred from bottom nav label "Sessions":**  
- May show session history list OR redirect to last session summary
- **Needs backend confirmation** for full list vs. latest-only behavior

---

## 2. Screen-by-Screen Flow Map

### 2.1 First-Time User Flow (With Polar)

```
SplashScreen
  └─ no auth → WelcomeScreen
       ├─ "Sign Up Now" → SignUpScreen
       │    └─ "Continue" → PhoneEntryScreen
       │         └─ (OTP sent) → OtpVerifyScreen
       │              └─ verified → OnboardingStep1
       │                   └─ Step2
       │                        └─ Step3
       │                             └─ Step4
       │                                  └─ PsychologyQuestionsScreen
       │                                       └─ (complete or skip) → PolarPermissionsScreen
       │                                            └─ "Continue & Allow" → PolarScanScreen
       │                                                 └─ (Connect) → PolarConnectedScreen
       │                                                      └─ BaselinePromptScreen
       │                                                           └─ BaselineCapturingScreen
       │                                                                └─ BaselineResultScreen
       │                                                                     └─ OnboardingCompleteScreen
       │                                                                          └─ AthleteHomeScreen
       └─ "Log In Here" → (same as Sign Up — same OTP flow)
```

### 2.2 First-Time User Flow (Without Polar)

```
... (same through PolarPermissionsScreen)
     └─ "I don't have a polar yet" → AthleteHomeScreen (Polar-not-connected state)
```

### 2.3 Session Flow (Full — With Polar)

```
AthleteHomeScreen
  └─ "Start Training Session" → DailyCheckinScreen
       └─ "Save Check-in and Continue" → SessionSetupScreen
            └─ "Begin Ritual" → PreSessionRitualScreen
                 └─ (ritual complete) → LiveTrainingScreen (Polar HR streaming active)
                      └─ "End Session" → ScoreEntryScreen
                           └─ (all series entered) → "Continue to Summary" → ReflectionScreen
                                └─ "Save & View Summary" → SessionSummaryScreen
                                     └─ "Save & View Full Report" → SessionReportScreen
                                          └─ "Continue to Insights" → InsightsScreen
                                               └─ "Save and Continue" → AthleteHomeScreen
```

### 2.4 Session Flow (Without Polar)

```
(Same as above, but:)
- LiveTrainingScreen: no HR display; may be skipped or shows timer only
- InsightsScreen: Physiology card shows "Polar not connected" upsell
```

### 2.5 Returning User Flow

```
SplashScreen
  └─ auth_token valid + onboarding_complete → AthleteHomeScreen
  └─ auth_token valid + onboarding_incomplete → OnboardingStep/{saved_step}
  └─ auth_token expired → refresh → AthleteHomeScreen (or re-auth on refresh failure)
```

### 2.6 Psychology Assessment Flow (Post-Onboarding)

```
AthleteHomeScreen (Psychology Assessment Pending card)
  └─ "Continue" → PsychologyQuestionsScreen (resumes at Q{answered+1})
       └─ All 25 complete → AthleteHomeScreen (card disappears)
```

### 2.7 Saarthi Chat Flow

```
AthleteHomeScreen (Saarthi avatar / Coach Summary)
  └─ tap → SaarthiChatScreen
       ├─ Quick action tap → auto-message → response
       └─ Type message → send → response
```

---

## 3. API Contract Requirements (Per Screen)

### 3.1 Auth Endpoints

| Action | Method | Endpoint | Auth Required |
|---|---|---|---|
| Send OTP | POST | `/auth/v1/otp` | None (anon key) |
| Verify OTP | POST | `/auth/v1/verify` | None (anon key) |
| Refresh token | POST | `/auth/v1/token?grant_type=refresh_token` | refresh_token |
| Sign out | POST | `/auth/v1/logout` | access_token |

**Send OTP Request/Response:**
```json
// Request
{ "phone": "+919876543210" }

// Response 200
{ "message_id": "...", "phone": "+919876543210" }

// Error 429
{ "error": "rate_limit_exceeded", "message": "..." }
```

**Verify OTP Request/Response:**
```json
// Request
{ "phone": "+919876543210", "token": "123456", "type": "sms" }

// Response 200
{
  "access_token": "<jwt>",
  "token_type": "bearer",
  "expires_in": 900,
  "refresh_token": "<opaque>",
  "user": { "id": "<uuid>", "phone": "+919876543210" }
}

// Error 400 (wrong OTP)
{ "error": "otp_expired", "message": "Token has expired or is invalid" }
```

**Retry Logic:**
- OTP send: no auto-retry (manual resend via "Didn't get a code?")
- Verify: 3 attempts before locking

**Offline Behavior:** OTP flows require network. Show "No internet connection" toast and disable submit button.

---

### 3.2 Onboarding Endpoints

**Create Athlete Profile (Step 4 completion):**
```json
// POST /rest/v1/athletes
// Headers: Prefer: return=representation, Authorization: Bearer <jwt>
{
  "user_id": "<App_Users.id>",
  "athlete_id": "ATH{auto_generated}",
  "full_name": "Jane Doe",
  "gender": "female",
  "sport": "shooting",
  "discipline": "air_pistol"
}

// Response 201
[{ "id": "<uuid>", "athlete_id": "ATH001", ... }]
```

**Create Athlete Details:**
```json
// POST /rest/v1/athlete_details
{
  "athlete_id": "<athletes.id>",
  "dominant_hand": null,
  "goals": ["Score 560 in 30 days", "Compete at nationals 590+"]
}
```

**Failure States:**
- 409 Conflict (duplicate athlete_id) → regenerate ID + retry
- 401 Unauthorized → re-authenticate
- 503 Network error → store locally, sync on next app open

**Offline Behavior:** Store all onboarding data in SharedPreferences. Sync to Supabase on next successful network call.

---

### 3.3 Session Lifecycle Endpoints

**Create Session:**
```json
// POST /rest/v1/App_Sessions
// Headers: Prefer: return=representation
{
  "athlete_id": "ATH001",
  "session_type": "training",
  "range_type": "paper",
  "planned_shots": 60,
  "start_time": "2026-05-19T05:00:00Z",
  "status": "active"
}
// Response 201
[{ "id": "<uuid>", "status": "active", ... }]
```

**Pause/Resume Session:**
```json
// PATCH /rest/v1/App_Sessions?id=eq.<session_id>
{ "status": "paused" }   // or "active"
// Response 204
```

**Complete Session:**
```json
// PATCH /rest/v1/App_Sessions?id=eq.<session_id>
{ "status": "completed", "end_time": "2026-05-19T07:00:00Z" }
// Response 204
```

**Failure States:**
- Session create fails → sessionId = null, continue locally, retry on next open
- Session complete fails → retry silently up to 3 times with exponential backoff (2s, 4s, 8s)

**Offline Behavior:** Session data (setup, scores) stored in SharedPreferences. Sync when network available.

---

### 3.4 Telemetry Endpoints

**Bulk HR Insert:**
```json
// POST /rest/v1/hr_stream
// Headers: Prefer: return=minimal
[
  {
    "time": "2026-05-19T05:01:00Z",
    "session_id": "<uuid>",
    "athlete_id": "ATH001",
    "bpm": 72,
    "rr_interval": 833,
    "source": "polar_h10"
  }
]
// Response 201 (empty body due to return=minimal)
```

**Flush Strategy:**
- Every 10 seconds OR 500 rows, whichever first
- On Pause: flush immediately
- On End Session: flush all remaining

**Failure Handling:**
- Network error during flush → buffer retained, retry next flush interval
- Max buffer size 2000 rows → oldest entries dropped with warning log

---

### 3.5 Performance Summary Endpoint

```json
// POST /rest/v1/performance_summary
// Headers: Prefer: return=representation
{
  "athlete_id": "ATH001",
  "session_id": "<uuid>",
  "total_score": 123.0,
  "max_possible": 218.0,
  "avg_per_shot": 6.15,
  "score_variance": 0.89,
  "consistency_pct": 62.0,
  "performance_rating": 6,
  "focus_level": "moderate"
}
// Response 201
[{ "id": "<uuid>", ... }]
```

**Calculation (done client-side before POST):**
```
total_score = sum(series_totals)
max_possible = series_count * shots_per_series * 10.9
avg_per_shot = total_score / total_shots
performance_rating = clamp(round((total_score / max_possible) * 10), 1, 10)
focus_level = rating >= 7 ? "high" : rating >= 5 ? "moderate" : "low"
consistency_pct = (1 - (std_dev(per_shot_avgs) / mean(per_shot_avgs))) * 100
```

---

### 3.6 Check-in Endpoint

```json
// POST /rest/v1/daily_checkins
// Headers: Prefer: return=representation
{
  "athlete_id": "<uuid>",
  "checkin_date": "2026-05-19",
  "mood": 8,
  "energy": 5,
  "sleep_quality": 7,
  "sleep_hours": 7.0,
  "stress_level": null,
  "soreness": null,
  "notes": "Focused,Motivated"
}
```

**Idempotency:** UPSERT on `(athlete_id, checkin_date)` unique constraint.
```
// PATCH /rest/v1/daily_checkins?athlete_id=eq.<uuid>&checkin_date=eq.<today>
// if record already exists for today
```

---

### 3.7 Saarthi Edge Function

```json
// POST /functions/v1/saarthi-chat
// Headers: Authorization: Bearer <user_jwt>
{
  "athlete_id": "<uuid>",
  "session_id": "<uuid>",
  "message": "How do I manage pre-competition anxiety?",
  "context_mode": "general"
}

// Response 200
{
  "reply": "Pre-competition anxiety is your body's preparation signal...",
  "suggestions": [
    "Try 4-7-8 breathing 10 minutes before",
    "Review your pre-shot routine cues"
  ],
  "mood_flag": "high_anxiety"
}

// Response 500 (AI error)
{
  "error": "upstream_error",
  "reply": "I'm having trouble connecting right now. Please try again."
}
```

**Context Mode Values:** `"pre_session"` | `"post_session"` | `"general"`

**Offline Behavior:** Queue message locally. Show "Message will be sent when online." Retry when network restores.

---

### 3.8 Dashboard RPC

```json
// POST /rest/v1/rpc/get_dashboard_data
// Headers: Authorization: Bearer <user_jwt>
{ "p_athlete_id": "ATH001" }

// Response 200
{
  "avg_score_7d": 513.4,
  "consistency_7d": 88.3,
  "sessions_this_week": 4,
  "readiness_score": 76,
  "trend": "improving"
}

// Note: RPC existence unconfirmed. Caller catches all errors silently.
```

---

## 4. Database Mapping (Per Screen)

| Screen | Table READ | Table WRITE | Required Fields |
|---|---|---|---|
| Splash | — | — | — |
| Welcome | — | — | — |
| Sign Up | — | — | — |
| Phone Entry | — | — | — |
| OTP Verify | `App_Users` (created by Supabase Auth) | `App_Users` | auth_uid, phone |
| Onboarding 1–3 | — | SharedPrefs only | — |
| Onboarding 4 | — | `athletes`, `athlete_details` | full_name, athlete_id, discipline |
| Psychology Qs | `psychology_questions` | `psychology_responses` | question_id, response_value |
| Polar Permissions | — | — | — |
| Polar Scan | — | — | — |
| Polar Connected | — | `polar_devices` | athlete_id, device_id |
| Baseline Capture | — | SharedPrefs | baseline_hr |
| Baseline Result | `athlete_details` | `athlete_details` (PATCH) | resting_hr |
| Onboarding Complete | — | SharedPrefs | onboarding_complete = true |
| Athlete Home | `daily_checkins`, `ai_insights`, `performance_summary` | — | — |
| Saarthi Chat | `athlete_chat` (last 20) | `athlete_chat` | athlete_id, role, content |
| Daily Check-in | `daily_checkins` (today) | `daily_checkins` | athlete_id, checkin_date, mood, energy, sleep_quality |
| Session Setup | — | `App_Sessions` | athlete_id, session_type, start_time |
| Pre-Session Ritual | — | — | — |
| Live Training | — | `hr_stream` (bulk), `App_Sessions` (status) | time, session_id, bpm |
| Score Entry | — | `performance_summary` | session_id, total_score |
| Reflection | — | `session_reflections`, `App_Sessions` (complete) | session_id, emotion_rating |
| Session Summary | `performance_summary`, `session_series` | — | — |
| Session Report | `performance_summary` | — | — |
| Insights | `ai_insights`, `psychology_scores`, `hr_stream` | `ai_insights` (mark read) | — |
| Profile | `athletes`, `athlete_details`, `psychology_scores` | — | — |

---

## 5. State Management Flow

### 5.1 BLoC Responsibilities

| BLoC | Feature | States | Events |
|---|---|---|---|
| `AuthBloc` | auth | AuthInitial, AuthLoading, Authenticated, Unauthenticated | CheckAuth, SendOtp, VerifyOtp, SignOut |
| `OnboardingBloc` | onboarding | StepState(1–4), OnboardingComplete | StepSubmitted, StepBack |
| `SessionBloc` | session | SessionInitial, SessionLoading, SessionStarted, SessionPaused, SessionCompleted | SessionStartRequested, SessionPauseRequested, SessionCompleteRequested |
| `CheckinBloc` | checkin | CheckinInitial, CheckinLoaded, CheckinSaved | LoadCheckin, SaveCheckin |
| `ScoreEntryBloc` | score_entry | ScoreEntryInitial, SeriesInProgress, AllSeriesEntered | SaveSeriesScore, UndoLastEntry |
| `DashboardBloc` | dashboard | DashboardLoading, DashboardLoaded, DashboardError | LoadDashboard |
| `PolarBloc` | polar | PolarDisconnected, PolarScanning, PolarConnected, PolarStreaming, PolarError | ScanDevices, ConnectDevice, StartStreaming, StopStreaming |
| `SaarthiBloc` | saarthi | SaarthiIdle, SaarthiTyping, SaarthiResponseReceived, SaarthiError | SendMessage, LoadHistory |
| `ProfileBloc` | profile | ProfileLoading, ProfileLoaded | LoadProfile |
| `InsightsBloc` | insights/dashboard | InsightsLoading, InsightsLoaded | LoadInsights, MarkInsightRead |

### 5.2 SharedPreferences Key Registry

| Key | Type | Written By | Read By |
|---|---|---|---|
| `auth_token` | String | OtpVerifyScreen | All API calls |
| `refresh_token` | String | OtpVerifyScreen | AuthBloc refresh |
| `onboarding_step` | int | Each onboarding screen | SplashScreen |
| `onboarding_complete` | bool | OnboardingCompleteScreen | SplashScreen |
| `athlete_profile` | JSON String | Onboarding Step 1–2 | ProfileBloc |
| `session_setup` | JSON String | SessionSetupScreen | SessionBloc, ScoreEntryBloc |
| `score_summary` | JSON String | ScoreEntryBloc | SessionSummaryBloc |
| `current_checkin` | JSON String | CheckinBloc | DashboardBloc |
| `baseline_scores` | JSON String | Onboarding Step 3 | ProfileBloc |
| `baseline_hr` | int | BaselineResultScreen | LiveTrainingScreen |
| `polar_device_id` | String | PolarConnectedScreen | PolarBloc |
| `journal_entries` | JSON String | ReflectionBloc | ProfileBloc |

### 5.3 SessionMemory (In-Memory Only)

```dart
class SessionMemory {
  static String? sessionId;    // cleared on app restart
  static String? athleteId;    // set on login
}
```

**Lifecycle:** Set when session created in Supabase. Cleared on app cold-start. No persistence.

### 5.4 Offline-First Decision Tree

```
User action triggered
  │
  ├─ Is action purely local? (score entry, reflection text)
  │    └─ YES → save to SharedPreferences → complete UI flow
  │             → try API sync (non-blocking fire-and-forget)
  │
  └─ Is action network-gated? (OTP, auth)
       └─ YES → check network → if offline → show "No internet" toast
                                          → disable submit button
```

---

## 6. Polar BLE Flow

### 6.1 Full Pairing Sequence

```
Step 1: User taps "Continue & Allow" on PolarPermissionsScreen
  └─ Request Android/iOS permissions:
       - Bluetooth Scan (Android 12+: BLUETOOTH_SCAN)
       - Bluetooth Connect (BLUETOOTH_CONNECT)
       - Location (for BLE scan on older Android)
       - Push Notifications
       - Microphone (optional)

Step 2: On permission grant → PolarScanScreen
  └─ PolarBleApi.searchForDevice()
  └─ List discovered devices (filter: model == "H10")
  └─ User taps "Connect"

Step 3: PolarBleApi.connectToDevice(deviceId)
  └─ Success → PolarConnectedScreen
  └─ Failure → error card on PolarScanScreen

Step 4: PolarConnectedScreen
  └─ Register device in polar_devices table (non-blocking)
  └─ Save deviceId to SharedPreferences
  └─ "Done Let's go" → BaselinePromptScreen

Step 5: Baseline Capture
  └─ PolarBleApi.startHrStreaming(deviceId)
  └─ Accumulate 60 samples
  └─ Calculate mean BPM
  └─ Stop HR stream
  └─ Save result locally + PATCH athlete_details.resting_hr

Step 6: Session streaming (LiveTrainingScreen)
  └─ PolarBleApi.startHrStreaming(deviceId)   // 1 Hz
  └─ Optional: PolarBleApi.startEcgStreaming(deviceId, settings)   // 130 Hz
  └─ Optional: PolarBleApi.startAccStreaming(deviceId, settings)   // 200 Hz
  └─ TelemetryBuffer.collect(sample)
  └─ Every 10s: TelemetryBuffer.flush() → POST /rest/v1/hr_stream
```

### 6.2 Polar Sensor Settings (Dart)

```dart
// ECG
final ecgSettings = PolarSensorSetting({
  PolarSensorSetting.settingSampleRate: 130,
  PolarSensorSetting.settingResolution: 14,
});

// ACC
final accSettings = PolarSensorSetting({
  PolarSensorSetting.settingSampleRate: 200,
  PolarSensorSetting.settingResolution: 16,
  PolarSensorSetting.settingRange: 8,  // ±8G
});
```

### 6.3 Disconnect and Reconnection

```
On PolarBleApi deviceDisconnected event:
  1. Log disconnect timestamp
  2. Mark LiveTrainingScreen as "reconnecting..." 
  3. Wait 2 seconds (debounce)
  4. Attempt reconnect: PolarBleApi.connectToDevice(savedDeviceId)
  5. Retry schedule: 2s → 4s → 8s → 16s → 30s (max 5 attempts)
  6. On success: resume streams, continue buffer
  7. On permanent failure:
     - Stop streaming
     - Retain buffer in memory
     - Show "Polar disconnected" badge on LiveTrainingScreen
     - Allow session to continue without HR
     - Flush buffer when reconnected or on session end
```

### 6.4 Buffer Management

```dart
class TelemetryBuffer {
  static const _hrFlushInterval  = Duration(seconds: 10);
  static const _ecgFlushInterval = Duration(seconds: 5);
  static const _maxBatchSize     = 500;       // rows per POST
  static const _maxBufferSize    = 2000;      // drop oldest beyond this

  List<Map<String, dynamic>> _hrBuffer  = [];
  List<Map<String, dynamic>> _ecgBuffer = [];
  List<Map<String, dynamic>> _accBuffer = [];

  // Flush triggers: timer, maxBatchSize, session end
}
```

### 6.5 Live Training HR Display Logic

```
currentBpm = latest HR sample
baselineHr = SharedPreferences.getInt('baseline_hr')
delta = currentBpm - baselineHr
deltaLabel = delta > 0 ? "+$delta" : "$delta"
deltaColor = delta > 10 ? Colors.red : delta > 5 ? Colors.orange : Colors.green

Display: "${currentBpm} bpm · Baseline ${baselineHr} ↑ ${deltaLabel}"
```

---

## 7. Saarthi AI Flow

### 7.1 Interaction Lifecycle

```
1. User opens SaarthiChatScreen
   └─ Load last 20 messages from athlete_chat (Supabase or local cache)
   └─ Display in chat bubble format

2. User types message or taps Quick Action
   └─ Append user message to chat (local, immediate)
   └─ Show typing indicator

3. POST /functions/v1/saarthi-chat
   └─ Edge Function builds context:
        - Rolling 20 chat turns (from Redis or Supabase)
        - Athlete snapshot (profile, discipline, experience)
        - Today's check-in (mood, energy, sleep)
        - Last session summary (score, consistency)
        - Last 3 unread ai_insights
        - Active session context (if session_id provided)
   └─ Calls Claude claude-sonnet-4-6 API
        max_tokens: 1024, temperature: 0.7
   └─ Parses response
   └─ Inserts 2 rows into athlete_chat (user + assistant)
   └─ Updates Redis cache saarthi:context:{athlete_id}
   └─ Checks for mood_flag → queues insight generation if needed

4. Response received by Flutter
   └─ Append assistant reply to chat
   └─ Hide typing indicator
   └─ Show suggestions chips if present

5. Mood flag handling:
   └─ "high_anxiety" → flag for coach notification (Needs backend confirmation)
   └─ "low_motivation" → queue motivational insight generation
```

### 7.2 Context Mode Mapping

| Trigger | context_mode | Additional context injected |
|---|---|---|
| Pre-session (from ritual screen) | `pre_session` | session setup params |
| Post-session (from insights) | `post_session` | session summary, scores |
| Home screen / any other | `general` | daily check-in |

### 7.3 Insight Generation Pipeline

```
Trigger: session completed (ReflectionScreen saved)
  → Non-blocking Edge Function call: generate-insights

  Edge Function steps:
  1. Gather last 30 days of data:
     SELECT * FROM App_Sessions WHERE athlete_id = $1 ORDER BY created_at DESC LIMIT 30
     SELECT * FROM performance_summary WHERE athlete_id = $1 ORDER BY created_at DESC LIMIT 30
     SELECT * FROM daily_checkins WHERE athlete_id = $1 ORDER BY checkin_date DESC LIMIT 30
     SELECT avg(bpm) FROM hr_stream WHERE athlete_id = $1 AND time > NOW() - INTERVAL '30 days'

  2. Build Claude prompt:
     "Analyze this athlete's last 30 days and identify 3 actionable insights.
      Output JSON: [{type, title, body, priority}]"

  3. Parse JSON response → INSERT INTO ai_insights (3 rows)
  4. Mark old is_read=false insights as superseded (optional)
  5. Return 201 to caller

Nightly job (pg_cron, Phase 2):
  - Same pipeline for all athletes who had sessions in last 7 days
  - Runs at 2 AM IST
```

### 7.4 Redis Cache Structure

```
saarthi:context:{athlete_id}
  TTL: 24h
  Value: {
    "chat_history": [...last 20 turns...],
    "athlete": { name, discipline, experience_years },
    "last_checkin": { mood, energy, sleep_hours },
    "last_session": { avg_per_shot, consistency_pct, total_score }
  }
```

---

## 8. Coach / Admin Flow

**From visible screenshots:** No dedicated coach portal screens are visible in either PDF.

**Inferred from Profile Screen:**
- "Coach — Not linked" indicates a coach-linking feature exists
- Coaches table is defined in the schema
- `coach_feedback` table exists

**Needs backend confirmation:**
- Coach web portal (separate from mobile app?)
- Coach linking mechanism (invite code? QR code? search?)
- Coach dashboard (view multiple athletes)
- Coach feedback submission endpoint

**From architecture.md RLS policies:**
```sql
CREATE POLICY coach_read_sessions ON "App_Sessions"
  FOR SELECT
  USING (
    athlete_id IN (
      SELECT a.athlete_id FROM athletes a
      JOIN athlete_details ad ON ad.athlete_id = a.id
      WHERE ad.coach_id = (
        SELECT id FROM coaches WHERE user_id = auth.uid()
      )
    )
  );
```
This confirms coach access is scoped but the UI is not yet visible.

---

## 9. Offline Behavior & Sync Strategy

### 9.1 Offline-Safe Operations (Local First)

| Operation | Local Storage | Sync Trigger |
|---|---|---|
| Onboarding data entry | SharedPreferences | On each step completion |
| Daily check-in | SharedPreferences | Immediate non-blocking POST |
| Session setup | SharedPreferences | Session start |
| Score entry (all series) | SharedPreferences | After all series saved |
| Reflection | SharedPreferences | On save tap |
| Psychology responses | SharedPreferences | Per answer |

### 9.2 Network-Required Operations

| Operation | Reason |
|---|---|
| OTP send/verify | Auth is server-side |
| Saarthi chat | LLM call — no local fallback |
| AI insights fetch | Requires server generation |

### 9.3 Sync Queue (Future Enhancement)

For Phase 2: implement a local `SyncQueue` that:
1. Enqueues failed API calls with payload
2. Retries on `Connectivity` restored event
3. Deduplicates by idempotency key

---

## 10. Error States & Edge Cases

### 10.1 Error State Catalogue

| Screen | Error Condition | UI Treatment |
|---|---|---|
| OTP Verify | Wrong code | Inline error text below input |
| OTP Verify | Code expired | Toast + "Resend" link |
| Polar Scan | No devices found | Warning card (yellow border) |
| Polar Scan | BLE disabled | System prompt to enable BT |
| Baseline Capture | Polar disconnects | Error overlay + retry button |
| Live Training | Polar disconnects mid-session | "Polar disconnected" badge, session continues |
| Live Training | Network lost | Telemetry buffered locally |
| Score Entry | Score > max_per_series | Validation message "Score cannot exceed {max}" |
| API generic | 401 Unauthorized | Auto-refresh token → retry once → re-login |
| API generic | 503 / timeout | Silent for non-blocking calls; toast for blocking calls |
| Saarthi | Edge Function error | "I'm having trouble. Please try again." in chat |

### 10.2 Empty States

| Screen | Empty Condition | UI Treatment |
|---|---|---|
| Athlete Home | No check-in today | Readiness/Recovery/Stress show "—" or 0 |
| Athlete Home | No sessions | "Start your first session" prompt |
| Profile | No sessions logged | "—" in BEST AVG, PERIOD AVG, BEST SERIES |
| Profile | No coach linked | "Coach — Not linked" (link action **Needs backend confirmation**) |
| Profile | Goals not set | "Not set yet" + "0%" progress bars |
| Insights | No AI insights | "Complete more sessions to unlock insights" (**Needs backend confirmation**) |
| Session History | No sessions | Empty list state (**Needs backend confirmation**) |
| Saarthi | No chat history | Quick actions grid (current implementation) |

### 10.3 Uncertain / Needs Confirmation Items

| # | Item | Where |
|---|---|---|
| 1 | Full discipline dropdown options | Onboarding Step 2 |
| 2 | Carousel slides 2 and 3 content | WelcomeScreen |
| 3 | "Log In Here" flow — separate from Sign Up or same? | WelcomeScreen |
| 4 | "What if my number changes?" action | PhoneEntryScreen |
| 5 | Psychology question bank (all 25 questions, dimensions) | PsychologyQuestionsScreen |
| 6 | Pre-Session Ritual screen content/duration | PreSessionRitualScreen |
| 7 | Live Training without Polar — HR card shown or hidden? | LiveTrainingScreen |
| 8 | Electronic range score entry flow | ScoreEntryScreen |
| 9 | Sessions tab — list view vs. latest summary | SessionsScreen |
| 10 | Notification bell action | AthleteHomeScreen |
| 11 | Athlete ID auto-generation strategy (ATH001, ATH002...) | athletes table |
| 12 | Coach linking UX (invite code / search) | ProfileScreen |
| 13 | Push notification setup (APNs/FCM integration) | Phase 2 |
| 14 | Stress/Soreness capture (present in schema, not visible in checkin screenshots) | DailyCheckinScreen |
| 15 | Score vs HR Trust chart — real-time or post-session computed? | InsightsScreen |
| 16 | `get_dashboard_data` RPC — does it exist? | AthleteHomeScreen |
| 17 | Dream Goal field — where is it set? | ProfileScreen |
| 18 | Short-term/Long-term goal progress calculation | ProfileScreen |
| 19 | Streak calculation logic (1-day streaks seen) | ProfileScreen |
| 20 | "Save & View Full Report" — does it generate a PDF? | SessionSummaryScreen |

---

## Appendix A — Screen Route Registry

| Route | Screen | Auth Required |
|---|---|---|
| `/` | SplashScreen | No |
| `/welcome` | WelcomeScreen | No |
| `/signup` | SignUpScreen | No |
| `/phone-entry` | PhoneEntryScreen | No |
| `/otp-verify` | OtpVerificationScreen | No |
| `/onboarding/step/1` | OnboardingStep1Screen | Yes |
| `/onboarding/step/2` | OnboardingStep2Screen | Yes |
| `/onboarding/step/3` | OnboardingStep3Screen | Yes |
| `/onboarding/step/4` | OnboardingStep4Screen | Yes |
| `/onboarding/complete` | OnboardingCompleteScreen | Yes |
| `/psychology/questions` | PsychologyQuestionsScreen | Yes |
| `/polar/permissions` | PolarPermissionsScreen | Yes |
| `/polar/scan` | PolarScanScreen | Yes |
| `/polar/connected` | PolarConnectedScreen | Yes |
| `/polar/baseline/prompt` | BaselinePromptScreen | Yes |
| `/polar/baseline/capturing` | BaselineCapturingScreen | Yes |
| `/polar/baseline/result` | BaselineResultScreen | Yes |
| `/home` | AthleteHomeScreen | Yes |
| `/saarthi` | SaarthiChatScreen | Yes |
| `/checkin` | DailyCheckinScreen | Yes |
| `/session/setup` | SessionSetupScreen | Yes |
| `/session/ritual` | PreSessionRitualScreen | Yes |
| `/session/live` | LiveTrainingScreen | Yes |
| `/session/score` | ScoreEntryScreen | Yes |
| `/session/reflection` | ReflectionScreen | Yes |
| `/session/summary` | SessionSummaryScreen | Yes |
| `/session/report` | SessionReportScreen | Yes |
| `/session/insights` | InsightsScreen | Yes |
| `/sessions` | SessionsScreen | Yes |
| `/profile` | ProfileScreen | Yes |

---

## Appendix B — Psychology Dimensions Observed

From Profile screen Quick Psychology Scores and Insights screen:

| Dimension | Profile Bar Color | Insights Card |
|---|---|---|
| Social | Green | SOCIAL |
| Arousal | Orange | AROUSAL |
| Decision | Teal/dark | DECISION |
| Focus | Blue/purple | FOCUS |
| Recovery | Red | RECOVERY |

**Note:** Onboarding psychology questions reference "focus, confidence, anxiety, motivation, resilience" per architecture.md, but the displayed dimensions in Profile/Insights use a different set (Social, Arousal, Decision, Focus, Recovery). **Needs backend confirmation** — alignment between question dimensions and display dimensions.

---

## Appendix C — Metric Labels Mapping

| Display Label | Source | Computation |
|---|---|---|
| READINESS | daily_checkins | Weighted: sleep × 0.30 + energy × 0.25 + mood × 0.20 + (10-stress) × 0.15 + (10-soreness) × 0.10, × 10 |
| RECOVERY | daily_checkins | (sleep_hours/8)×40 + ((10-soreness)/10)×30 + ((10-stress)/10)×30 |
| STRESS | daily_checkins | stress_level directly (**Needs backend confirmation** — not in checkin UI) |
| MENTAL STATE | psychology_scores | Derived label from composite_score |
| PERFORMANCE | performance_summary | performance_rating (1–10) |
| HOLD STABILITY | acc_stream or performance | Best avg/shot across series |
| MENTAL SCORE | psychology_scores | composite_score |
| CONSISTENCY | performance_summary | consistency_pct |
| SOCIAL | psychology_scores | social dimension score |
| AROUSAL | psychology_scores | arousal dimension score |
| DECISION | psychology_scores | decision dimension score |
| FOCUS | psychology_scores | focus_score |
| RECOVERY (psych) | psychology_scores | resilience/recovery dimension score |

---

*Document generated: 2026-05-19 · ASTRA Product Flow v1.0*  
*Total screens documented: 30 (confirmed) + 2 inferred*  
*Uncertain items: 20 (marked "Needs backend confirmation")*
