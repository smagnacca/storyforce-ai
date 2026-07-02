# StoryForce — Complete UI/UX Design System & Flows
## iOS App Interface Specification for Claude Fable Development

**Purpose:** Handoff specification for Fable to build production-ready iOS interface  
**Last Updated:** July 2, 2026  
**Platform:** iOS 15+, SwiftUI, Dark/Light mode support  
**Design System:** Modern, minimalist, voice-first

---

## 1. DESIGN PHILOSOPHY & PRINCIPLES

### Core UX Principles
1. **Voice-First Design** — Audio is primary input, not secondary; visual UI supports voice interaction
2. **Confidence Building** — Every screen removes friction and builds trust
3. **Clarity Over Complexity** — Show only what's needed; hide settings
4. **Progressive Disclosure** — Advanced features revealed after basics mastered
5. **Real-Time Feedback** — User never waits > 2 sec without feedback

### Design Goals for Sales Reps
- **Fast:** Describe client in 90 seconds → Story in 3 minutes
- **Natural:** Speak, don't type; AI listens and understands
- **Confident:** Practice until delivery feels effortless
- **Sharable:** Save stories, see what worked, share with team

---

## 2. DESIGN SYSTEM TOKENS

### Color Palette

**Primary Brand Colors:**
```
StoryForce Blue: #0066FF (main CTAs, accent)
Success Green: #00AA44 (completion, scores 8+)
Warning Orange: #FF9900 (practice feedback, needs improvement)
Neutral Dark: #1A1A1A (text, dark mode background)
Neutral Light: #F5F5F5 (light mode background)
Neutral Gray: #666666 (secondary text)
```

**Semantic Colors:**
```
Background Light: #FFFFFF
Background Dark: #0D0D0D
Surface Light: #F9F9F9
Surface Dark: #1A1A1A
Border Light: #EBEBEB
Border Dark: #333333
Text Primary: #1A1A1A / #FFFFFF (theme-aware)
Text Secondary: #666666 / #999999 (theme-aware)
```

**Voice State Indicators:**
```
Recording (live): #FF4444 (red pulsing)
Listening: #0066FF (blue spinning)
Processing: #FF9900 (orange loading)
Complete: #00AA44 (green check)
Error: #CC0000 (dark red)
```

### Typography

```
Font Stack: -apple-system, San Francisco, system-ui (native iOS)

Display (Headlines):
  Font: SF Pro Display Bold
  Size: 32px
  Weight: 700
  Line Height: 1.2
  Use: Screen titles ("Describe Your Client")

Headline (Section titles):
  Font: SF Pro Display Semibold
  Size: 20px
  Weight: 600
  Line Height: 1.3
  Use: Card headers, step labels

Body (Primary text):
  Font: SF Pro Text Regular
  Size: 16px
  Weight: 400
  Line Height: 1.5
  Use: Story text, instructions

Subheading (Secondary text):
  Font: SF Pro Text Regular
  Size: 14px
  Weight: 500
  Line Height: 1.4
  Use: Labels, meta information

Caption (Fine print):
  Font: SF Pro Text Regular
  Size: 12px
  Weight: 400
  Line Height: 1.4
  Use: Hints, timestamps, scores
```

### Spacing System (Base unit = 4px)

```
XS: 4px (tight, element separations)
S: 8px (small gaps)
M: 16px (standard padding)
L: 24px (section spacing)
XL: 32px (major sections)
2XL: 48px (screen-to-screen spacing)

Standard Padding (cards, containers):
  Horizontal: 16px
  Vertical: 16px
  
Standard Margin (between elements):
  Small elements: 8px
  Medium elements: 12px
  Large elements: 16px
```

### Border Radius & Shadows

```
Corner Radius:
  Small (buttons, badges): 8px
  Medium (cards, modals): 12px
  Large (hero elements): 16px
  Pill (tags, badges): 20px

Shadows (Dark mode aware):
  Light: 0 2px 4px rgba(0,0,0,0.08)
  Medium: 0 4px 12px rgba(0,0,0,0.12)
  Deep: 0 8px 24px rgba(0,0,0,0.16)
  Elevated (floating elements): 0 12px 32px rgba(0,0,0,0.20)
```

### Component States

Every interactive component has 4 states:
```
Default: Standard appearance
Hover: Slight scale (1.02x), shadow lift
Active/Pressed: Scale (0.98x), shadow reduced
Disabled: Opacity 0.5, cursor not-allowed
Loading: Pulsing animation or spinner
```

---

## 3. CORE USER FLOWS

### Flow 1: Onboarding (First-Time User)

```
Splash Screen (3 sec)
    ↓
"Welcome to StoryForce" hero + tagline
    ↓
"How It Works" carousel (3 slides):
  1. "Describe your client"
  2. "AI generates your story"
  3. "Practice with a coach"
    ↓
Sign-up/Login (email + password or Apple Sign-In)
    ↓
"Subscription" choice (Free vs. Professional)
    ↓
Permission requests (Microphone access)
    ↓
Tutorial: "Let's practice describing a client"
    ↓
First prompt from Gemini: "Tell me about a client..."
    ↓
Dashboard (empty state)
```

### Flow 2: Main Loop (Describe → Generate → Practice)

```
Dashboard (Home screen)
    ↓
User taps "New Story"
    ↓
Screen 1: "Describe Your Client"
  - Voice button (tap to record)
  - OR text input (tap to type)
  - Gemini listens & clarifies
    ↓
Screen 2: "Confirm Client Profile"
  - Show extracted profile
  - Edit any fields
  - Confirm to proceed
    ↓
Screen 3: "Generating Your Story..." (loading)
  - Fable creates Three-Act structure
  - Metaphors generated
  - Delivery guidance prepared
    ↓
Screen 4: "Your Story" (display)
  - Act 1 Hook (bold, short)
  - Act 2 Bridge (longer, case study)
  - Act 3 Payoff (vivid, emotional)
  - Metaphors panel (swipeable)
  - Delivery tips panel
    ↓
User taps "Practice Now"
    ↓
Screen 5: "Practice Your Story"
  - Voice button (red, pulsing)
  - "Tap & hold to record"
  - Rep speaks story
    ↓
Gemini analyzes delivery
    ↓
Screen 6: "Coaching Feedback"
  - Scores (Pace, Resonance, Clarity, Credibility)
  - Audio feedback from Gemini: "Great job, but..."
  - Option to record again OR continue
    ↓
Repeat until satisfied
    ↓
Screen 7: "Save Story"
  - Auto-save with date + client name
  - Add notes (optional)
  - Share with team (if Teams tier)
    ↓
Back to Dashboard
```

### Flow 3: Story Library & Analytics

```
Dashboard (Home)
    ↓
User taps "My Stories" tab
    ↓
List view:
  - Story 1: "Mike Johnson | July 2" | 8.2 score
  - Story 2: "Sarah Chen | June 30" | 7.5 score
  - Story 3: "David Park | June 28" | 8.9 score
    ↓
User taps a story
    ↓
Story detail screen:
  - Full story text
  - Practice attempts (expandable list)
  - Meeting outcome (if available)
  - Edit/Delete options
    ↓
User taps "Record Meeting Outcome"
    ↓
Quick form:
  - Did you use this story in a meeting?
  - Result: Won / Lost / Pending
  - Deal value (optional)
  - Client feedback (1-10 rating)
    ↓
Analytics update (saved to backend)
    ↓
Dashboard shows updated stats
```

---

## 4. SCREEN LAYOUTS & WIREFRAMES

### Screen 1: Dashboard (Home)

```
┌─────────────────────────────────────┐
│  8:42                          🔔   │  (Status bar)
├─────────────────────────────────────┤
│  StoryForce                         │  (Logo/title, top-left)
│                                     │
│  Good morning, John! 👋             │  (Personalized greeting)
│                                     │
├─────────────────────────────────────┤
│  📊 YOUR STATS THIS MONTH           │  (Section header)
│  ┌─────────────────────────────────┐│
│  │ Stories Generated    ●●●●● 12    ││  (Progress card)
│  │ Practice Sessions    ●●●● 8      ││
│  │ Avg Delivery Score   ⭐ 7.8/10  ││
│  │ Conversion Rate      ↗️ 67%      ││
│  └─────────────────────────────────┘│
│                                     │
├─────────────────────────────────────┤
│  🎯 QUICK ACTION                    │  (Section header)
│  ┌─────────────────────────────────┐│
│  │ [  🎙️ DESCRIBE A CLIENT  ]      ││  (Primary CTA button)
│  │ (Large, blue, with mic icon)    ││
│  └─────────────────────────────────┘│
│                                     │
├─────────────────────────────────────┤
│  📚 RECENT STORIES                  │  (Section header)
│  ┌─────────────────────────────────┐│
│  │ Mike Johnson                 7/2  ││  (Story card)
│  │ VP Ops, Pharma Corp              ││
│  │ Score: 8.2  |  Status: Pending   ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │ Sarah Chen                   6/30 ││  (Story card)
│  │ CFO, FinTech Startup             ││
│  │ Score: 7.5  |  Status: Won       ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │ [  SEE ALL STORIES  ]            ││  (Link)
│  └─────────────────────────────────┘│
│                                     │
├─────────────────────────────────────┤
│  Tabs: Home | My Stories | Settings │  (Bottom tab bar)
└─────────────────────────────────────┘
```

**Component Breakdown:**
- Status Bar: iOS default
- Header: Logo + personalized greeting
- Stats Cards: 4 key metrics in a single scrollable container
- CTA Button: Full-width, blue, prominent
- Story Cards: Touchable rows with name, role/company, score, status
- Tab Bar: Navigation (Home, Stories, Settings)

**Interactions:**
- Stats cards: Tap to drill into analytics
- Story cards: Swipe left to delete, tap to view details
- CTA button: Tap → goes to "Describe Client" screen
- Tab bar: Switches between sections

---

### Screen 2: Describe Your Client (Voice Entry)

```
┌─────────────────────────────────────┐
│  < Back                        Close │  (Top nav)
├─────────────────────────────────────┤
│                                     │
│  Describe Your Client               │  (Title)
│                                     │
│  Tell me about the client you're    │  (Instruction)
│  meeting today. Who are they? What  │
│  is their biggest challenge?        │
│                                     │
├─────────────────────────────────────┤
│                                     │
│          ●  ●  ●                    │  (Listening animation)
│                                     │
│  [  🎙️  LISTENING  ]                │  (Tap to stop)
│  Tap to speak...                    │
│                                     │
├─────────────────────────────────────┤
│  Or, if you prefer:                 │
│  ┌─────────────────────────────────┐│
│  │ [  ✏️  TYPE INSTEAD  ]          ││  (Secondary CTA)
│  └─────────────────────────────────┘│
│                                     │
│  Transcription so far:              │  (Real-time display)
│  "Mike is a VP of Operations at...  │
│   He's worried about cost..."       │
│                                     │
└─────────────────────────────────────┘
```

**Component Breakdown:**
- Top Nav: Back button (left), Close button (right)
- Title: Large, clear
- Instruction: Concise, friendly tone
- Voice Input: Large, animated microphone with pulsing dots
- Status Label: Changes ("LISTENING" → "PROCESSING" → "DONE")
- Text Fallback: "Or type instead" link
- Live Transcription: Shows what Gemini is hearing in real-time

**Interactions:**
- Tap microphone: Starts recording (visual feedback: pulsing, red ring)
- Release microphone: Stops recording, begins transcription
- Text fallback: Switches to keyboard input
- Real-time transcription: Appears as user speaks (no latency)

---

### Screen 3: Confirm Client Profile (Review & Edit)

```
┌─────────────────────────────────────┐
│  < Back                        Edit  │
├─────────────────────────────────────┤
│  Confirm Client Profile             │
│  Everything look right?             │
│                                     │
├─────────────────────────────────────┤
│  CLIENT DETAILS                     │
│  ┌─────────────────────────────────┐│
│  │ Name:   Mike Johnson            ││
│  │ Role:   VP of Operations        ││
│  │ Company: Pharma Corp Inc        ││
│  │ Industry: Pharmaceutical        ││
│  └─────────────────────────────────┘│
│                                     │
│  CURRENT STATE (Winter)             │
│  ┌─────────────────────────────────┐│
│  │ Primary Fear: Cost containment  ││
│  │             + operational risk  ││
│  │                                 ││
│  │ Pain Points:                    ││
│  │ • Budget cuts expected Q3      ││
│  │ • Legacy systems hard to change ││
│  │ • Team resistant to new methods ││
│  └─────────────────────────────────┘│
│                                     │
│  DESIRED STATE (Spring)             │
│  ┌─────────────────────────────────┐│
│  │ Main Goal: 20% cost reduction   ││
│  │ without service disruption      ││
│  │                                 ││
│  │ Success Metrics:                ││
│  │ • Cost savings achieved         ││
│  │ • Team confidence in process    ││
│  │ • Zero downtime during rollout  ││
│  └─────────────────────────────────┘│
│                                     │
├─────────────────────────────────────┤
│  [  ✅ LOOKS GOOD, GENERATE STORY ] │  (Primary CTA)
│  [       EDIT DETAILS       ]       │  (Secondary CTA)
│                                     │
└─────────────────────────────────────┘
```

**Component Breakdown:**
- Top Nav: Back button, Edit button (opens edit mode)
- Title: Clear confirmation message
- Profile Section: Editable fields (client details)
- Winter Section: Extracted fears and pain points (editable)
- Spring Section: Extracted goals and success metrics (editable)
- CTAs: Primary (generate) in blue, secondary (edit) in gray

**Interactions:**
- Tap any field: Inline editing (e.g., change "VP Operations" to "Director Operations")
- Edit button: Enters edit mode for all fields
- Generate Story button: Validates all required fields, then proceeds to loading screen

---

### Screen 4: Your Story (Display & Review)

```
┌─────────────────────────────────────┐
│  < Back              ⭐ Save        │  (Top nav)
├─────────────────────────────────────┤
│  Your Three-Act Story               │
│  Mike Johnson | Pharma Corp         │
│  Score: -- (not yet practiced)      │
│                                     │
├─────────────────────────────────────┤
│  ACT 1: THE HOOK                    │  (Section header)
│  ┌─────────────────────────────────┐│
│  │ I see your fear. You've been    ││
│  │ burned before by consultants    ││
│  │ making promises they didn't     ││
│  │ keep. And now your CFO is       ││
│  │ asking you to do more with less.││
│  │ That's a lot of pressure.       ││
│  └─────────────────────────────────┘│
│  Delivery tip: Pause for 2 sec     │
│  after "That's a lot of pressure"  │
│                                     │
├─────────────────────────────────────┤
│  ACT 2: THE BRIDGE                  │  (Section header)
│  ┌─────────────────────────────────┐│
│  │ I had a client named Sarah,     ││
│  │ also a VP of Operations at a    ││
│  │ pharma company. Same situation. ││
│  │ We were worried about disruption││
│  │ but committed to a phased       ││
│  │ approach...                     ││
│  └─────────────────────────────────┘│
│  Case Study: Sarah @ MediTech      │
│  Results: 18% cost savings, 6mo    │
│                                     │
├─────────────────────────────────────┤
│  ACT 3: THE PAYOFF                  │  (Section header)
│  ┌─────────────────────────────────┐│
│  │ Imagine next year. Your team is ││
│  │ running lean, operations are    ││
│  │ 20% more efficient. Your CFO is ││
│  │ happy. Your board is impressed. ││
│  │ And you? You sleep better at    ││
│  │ night knowing the ship is       ││
│  │ steady. That's Spring.          ││
│  └─────────────────────────────────┘│
│                                     │
├─────────────────────────────────────┤
│  METAPHORS THAT RESONATE            │
│  ┌─────────────────────────────────┐│
│  │ "Like a gardener trimming      ││
│  │ branches—removing waste, not    ││
│  │ health"                         ││
│  │                                 ││
│  │ → Swipe to see more →           ││
│  └─────────────────────────────────┘│
│                                     │
├─────────────────────────────────────┤
│  [ 🎙️ PRACTICE THIS STORY NOW ]     │  (Primary CTA)
│                                     │
└─────────────────────────────────────┘
```

**Component Breakdown:**
- Top Nav: Back, Save (bookmarks story)
- Title: Client name, company, current score
- Three Sections: Act 1, Act 2, Act 3 (each collapsible or scrollable)
- Text Display: Large, readable, with delivery tips inline
- Case Study Reference: Shows case study name, key metrics
- Metaphors: Horizontally scrollable cards
- CTA: Full-width blue button to practice

**Interactions:**
- Tap Save: Bookmarks story (star fills in)
- Swipe on metaphors: Reveals next metaphor
- Tap delivery tips: Expands full guidance
- Practice button: Goes to Practice screen

---

### Screen 5: Practice Your Story (Voice Recording)

```
┌─────────────────────────────────────┐
│  < Back                        Info  │
├─────────────────────────────────────┤
│  Practice Your Story                │
│  Attempt #1 of unlimited            │
│                                     │
│  Let's hear how it sounds!          │
│                                     │
├─────────────────────────────────────┤
│                                     │
│               ●                     │  (Large microphone icon)
│                                     │
│    [  🎙️ TAP & HOLD TO SPEAK ]     │  (Red, pulsing button)
│                                     │
│       "Try delivering Act 1         │
│        with more emotion..."        │  (Hint)
│                                     │
├─────────────────────────────────────┤
│                                     │
│  Timer: 00:45 / 07:00               │  (Current / Total expected)
│  ⏸  Stop  ⏯  (if playing back)     │  (Playback controls)
│                                     │
│  OR                                 │
│                                     │
│  [  ✖️ CLEAR THIS RECORDING  ]      │  (Secondary action)
│                                     │
├─────────────────────────────────────┤
│  📊 PREVIOUS ATTEMPTS               │  (Collapsed section)
│  Attempt 1: 7.8/10 score | 6/2      │
│  Tap to review...                   │
│                                     │
└─────────────────────────────────────┘
```

**Component Breakdown:**
- Top Nav: Back, Info (help)
- Title: Practice messaging + attempt counter
- Microphone Button: Large, red, pulsing (indicates ready to record)
- Timer: Shows elapsed time and expected duration
- Playback Controls: Play/stop if user wants to hear recording again
- Previous Attempts: Expandable list of past takes

**Interactions:**
- Tap & hold microphone: Starts recording (button turns dark red, pulsing stops)
- Release microphone: Stops recording, immediately sends to Gemini + Fable for analysis
- Clear recording: Discards current recording, allows re-record
- Play previous: Listens to prior attempts

---

### Screen 6: Coaching Feedback (Delivery Scores & Guidance)

```
┌─────────────────────────────────────┐
│  < Back                        Save  │
├─────────────────────────────────────┤
│  Coaching Feedback                  │
│  Let's make that even better        │
│                                     │
├─────────────────────────────────────┤
│  DELIVERY SCORES                    │
│  ┌─────────────────────────────────┐│
│  │ Pace              ⭐⭐⭐⭐⭐ 8/10  ││
│  │ Emotional Resonance ⭐⭐⭐⭐ 7/10 ││
│  │ Clarity           ⭐⭐⭐⭐⭐ 9/10  ││
│  │ Credibility       ⭐⭐⭐⭐⭐ 8/10  ││
│  └─────────────────────────────────┘│
│                                     │
│  Overall Score: 8.0/10 ✨           │  (Large, prominent)
│                                     │
├─────────────────────────────────────┤
│  🎤 GEMINI'S FEEDBACK               │  (Audio feedback indicator)
│  ┌─────────────────────────────────┐│
│  │ [  ▶️  Listen to Feedback  ]    ││  (Tap to play audio)
│  └─────────────────────────────────┘│
│                                     │
│  Transcript:                        │
│  "Great pace! You really nailed     │
│  the emotional arc. One suggestion: │
│  pause for 1 second after 'I see    │
│  your fear' so it lands. Want to    │
│  try again?"                        │
│                                     │
├─────────────────────────────────────┤
│  [ 🎙️ TRY AGAIN  ]   [  CONTINUE  ] │  (CTAs)
│                                     │
│  (If score 8+) ✨ Ready for your     │
│  meeting! This story will resonate. │
│                                     │
└─────────────────────────────────────┘
```

**Component Breakdown:**
- Top Nav: Back, Save (saves this attempt)
- Title: Coaching message
- Scores: 4 metrics with star ratings (visual + numeric)
- Overall Score: Large, highlighted (color changes: 5-6 = orange, 7-8 = blue, 8+ = green)
- Audio Feedback: Play button + transcript (so user can read or listen)
- CTAs: Try Again (loop back), Continue (accept score)
- Success Message: If score 8+, celebrates readiness

**Interactions:**
- Tap play button: Plays Gemini's voice feedback
- Try Again button: Goes back to practice screen
- Continue button: Saves attempt, option to finalize story

---

### Screen 7: Story Library (My Stories)

```
┌─────────────────────────────────────┐
│  My Stories                    🔍   │  (Search)
├─────────────────────────────────────┤
│  Filters: ▼ Date | ▼ Score          │
│                                     │
│  ┌─────────────────────────────────┐│
│  │ Mike Johnson                 7/2 ││
│  │ VP Ops, Pharma Corp              ││
│  │ 🟢 Score: 8.2 | Won $250K        ││
│  │ Practice: 2 attempts             ││
│  │                                  ││
│  │ [Delete]  [Edit]  [Share]  [•••] ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────────────────────┐│
│  │ Sarah Chen                   6/30 ││
│  │ CFO, FinTech Startup             ││
│  │ 🟠 Score: 7.5 | Pending          ││
│  │ Practice: 1 attempt              ││
│  │                                  ││
│  │ [Delete]  [Edit]  [Share]  [•••] ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────────────────────┐│
│  │ David Park                   6/28 ││
│  │ Director, Enterprise Sales       ││
│  │ 🟢 Score: 8.9 | Won $1.2M        ││
│  │ Practice: 3 attempts             ││
│  │                                  ││
│  │ [Delete]  [Edit]  [Share]  [•••] ││
│  └─────────────────────────────────┘│
│                                     │
│  [ + NEW STORY ]                    │
│                                     │
└─────────────────────────────────────┘
```

**Component Breakdown:**
- Header: "My Stories" title + search icon
- Filters: Sort by date, score, result, etc.
- Story Cards: Name, role, company, score (color-coded), outcome, practice count
- Actions: Delete, Edit, Share, More (3-dot menu)
- CTA: "New Story" button (sticky at bottom)

**Interactions:**
- Tap story card: Opens story detail view
- Swipe left on card: Reveals delete/archive options
- Filter dropdown: Changes sort order
- Share button: Opens share sheet (copy link, Slack, email)

---

## 5. COMPONENT LIBRARY

### Button Styles

**Primary Button (Blue, Full-Width)**
```swift
Button(action: {}) {
    Text("DESCRIBE A CLIENT")
        .font(.headline)
        .fontWeight(.semibold)
}
.frame(height: 56)
.frame(maxWidth: .infinity)
.background(Color(#0066FF))
.foregroundColor(.white)
.cornerRadius(12)
.padding(.horizontal, 16)
```

**Secondary Button (Gray Outline)**
```swift
Button(action: {}) {
    Text("TRY AGAIN")
        .font(.subheading)
        .foregroundColor(Color(#0066FF))
}
.frame(height: 44)
.frame(maxWidth: .infinity)
.overlay(
    RoundedRectangle(cornerRadius: 8)
        .stroke(Color(#0066FF), lineWidth: 1)
)
```

**Tertiary Button (Text Only)**
```swift
Button(action: {}) {
    Text("Edit Details")
        .font(.subheading)
        .foregroundColor(Color(#0066FF))
        .underline()
}
```

### Card Component

```swift
VStack(alignment: .leading, spacing: 12) {
    HStack {
        VStack(alignment: .leading, spacing: 4) {
            Text("Mike Johnson")
                .font(.headline)
                .fontWeight(.semibold)
            Text("VP Ops, Pharma Corp")
                .font(.subheading)
                .foregroundColor(.gray)
        }
        Spacer()
        Text("7/2")
            .font(.caption)
            .foregroundColor(.gray)
    }
    
    Divider()
    
    HStack {
        Label("8.2", systemImage: "star.fill")
            .font(.subheading)
            .foregroundColor(.orange)
        Spacer()
        Text("Won • $250K")
            .font(.caption)
            .foregroundColor(.green)
    }
}
.padding(16)
.background(Color(#F9F9F9))
.cornerRadius(12)
.overlay(
    RoundedRectangle(cornerRadius: 12)
        .stroke(Color(#EBEBEB), lineWidth: 1)
)
```

### Input Field (Voice Recorder)

```swift
VStack(spacing: 24) {
    // Recording state indicator
    ZStack {
        Circle()
            .stroke(Color(#FF4444).opacity(0.3), lineWidth: 4)
            .frame(width: 120, height: 120)
        
        Circle()
            .fill(Color(#FF4444))
            .frame(width: 80, height: 80)
        
        VStack(spacing: 8) {
            Image(systemName: "mic.fill")
                .font(.system(size: 28))
                .foregroundColor(.white)
            Text("TAP & HOLD")
                .font(.caption)
                .foregroundColor(.white)
        }
    }
    
    Text("Listening...")
        .font(.subheading)
        .foregroundColor(.gray)
}
```

### Score Badge (Color-Coded)

```swift
HStack(spacing: 8) {
    Image(systemName: "star.fill")
        .font(.system(size: 14))
    Text("8.2/10")
        .font(.subheading)
        .fontWeight(.semibold)
}
.padding(.vertical, 6)
.padding(.horizontal, 12)
.background(Color.green.opacity(0.15))
.foregroundColor(.green)
.cornerRadius(6)

// Colors by score:
// 5-6: Orange
// 7-8: Blue
// 8+: Green
```

### Loading State (Animation)

```swift
VStack(spacing: 16) {
    HStack(spacing: 8) {
        Circle().fill(Color.blue)
        Circle().fill(Color.blue)
        Circle().fill(Color.blue)
    }
    .frame(height: 40)
    .onAppear {
        // Pulsing animation
    }
    
    Text("Generating Your Story...")
        .font(.headline)
}
```

---

## 6. ACCESSIBILITY CONSIDERATIONS

### Voice-First Accessibility
- All voice input is captured with live transcription (for deaf/hard-of-hearing users)
- Text-to-speech feedback can be toggled to silent mode (on-screen text only)
- Alternative: Full keyboard navigation available

### Contrast & Legibility
- All text meets WCAG AA contrast standards (4.5:1 minimum)
- Font sizes: minimum 16px for body text
- Line height: 1.5+ for readability

### Motor Accessibility
- Touch targets: minimum 44x44 pt (accessibility minimum)
- No small buttons or fine gestures required
- Tap & hold microphone: 1-2 second recognition window
- Swipe actions: Also available via 3-dot menu

### Cognitive Accessibility
- Language: Simple, clear (avoid jargon)
- Progressive disclosure: Hide advanced features initially
- Confirmation dialogs: Before destructive actions (delete, clear)

### VoiceOver Support
- All interactive elements have descriptive labels
- Scores announced as "8 out of 10, good"
- Status indicators described: "Recording", "Processing", "Complete"

---

## 7. MOTION & ANIMATION GUIDELINES

### Microphone Recording (Loop)

```
Idle: Microphone icon static
Tap: Button scales to 0.95x
Hold: Red circle expands + contracts (pulsing)
Release: Button scales back, checkmark appears
```

### Loading States

```
"Generating Story":
  3 dots pulsing sequentially (600ms each)
  Duration: Until generation complete
  
"Analyzing Delivery":
  Waveform animation (simulated audio analysis)
  Duration: 2-3 seconds
```

### Feedback Animations

```
Score reveal: Fade-in + slide up
  Stagger each metric by 100ms
  
Success checkmark: Scale + bounce
  1.2x scale, then settle to 1.0x
  Duration: 600ms
  
Error shake: Horizontal oscillation
  ±4px, 3 cycles, 150ms total
```

### Transitions Between Screens

```
Next screen (forward): Slide right + fade
  Duration: 300ms
  Easing: Ease out
  
Back navigation: Slide left + fade
  Duration: 200ms
  Easing: Ease in
```

---

## 8. DARK MODE SUPPORT

### Color Adjustments (Automatic)

```swift
// Light Mode
.background(Color(#FFFFFF))
.foregroundColor(Color(#1A1A1A))

// Dark Mode (via @Environment)
.background(Color(#0D0D0D))
.foregroundColor(Color(#FFFFFF))

// Use: Color adaptations automatically applied
// iOS handles switching based on device settings
```

### Contrast in Dark Mode
- Ensure all colors maintain 4.5:1 contrast in dark mode
- Reduce shadow opacity (shadows less visible in dark)
- Increase border opacity for component definition

---

## 9. ONBOARDING FLOW (Detailed)

### Step 1: Splash Screen (3 sec auto-advance)
```
"StoryForce"
"Generate research-backed sales stories in 90 seconds"
[Loading animation]
```

### Step 2: Welcome Carousel (3 slides)
```
Slide 1: "Describe Your Client"
  Icon: 🎙️
  "Speak naturally. We'll understand your client's situation."

Slide 2: "AI Generates Your Story"
  Icon: ✨
  "In seconds, get a Three-Act story that resonates."

Slide 3: "Practice With a Coach"
  Icon: 🎤
  "Deliver with confidence. Real-time feedback from AI."

[Skip]  [Next]  [Next]  [Start →]
```

### Step 3: Authentication
```
"Sign up for StoryForce"

[  Sign up with Email  ]
[  Continue with Apple  ]

"Already have an account? Log in"
```

### Step 4: Subscription Choice
```
"Choose Your Plan"

[Free]
  ✓ 5 stories/month
  ✓ Basic feedback
  (Continue with Free)

[Professional] ← Recommended
  ✓ Unlimited stories
  ✓ Full voice coaching
  ✓ Advanced analytics
  $12.99/month
  (Subscribe Now)
```

### Step 5: Permissions
```
"StoryForce needs microphone access"

"We use your microphone to capture your voice and 
analyze your delivery. No audio is stored without 
your permission."

[Allow]  [Not Now]
```

### Step 6: First Practice
```
"Let's practice!"

"Describe a client you're meeting with. Try: 
name, role, company, and their biggest challenge."

[Microphone ready]

(Rep speaks; Gemini listens)
(After recording: show extracted profile)

"Does that sound right?"
[Edit]  [Looks Good!]

(If "Looks Good": generate sample story)
(Proceed to dashboard)
```

---

## 10. SETTINGS & ACCOUNT SCREENS

### Settings Tab

```
┌─────────────────────────────────────┐
│  Settings                           │
├─────────────────────────────────────┤
│  ACCOUNT                            │
│  John Doe (john@company.com)        │
│  Professional subscription          │
│  ✅ Active until July 15, 2026      │
│                                     │
│  [  Edit Profile  ]                 │
│  [  Manage Subscription  ]          │
│                                     │
├─────────────────────────────────────┤
│  PREFERENCES                        │
│  Dark Mode                    ▲ ON  │
│  Push Notifications          ▲ ON  │
│  Voice Feedback (TTS)        ▲ ON  │
│                                     │
├─────────────────────────────────────┤
│  DATA & PRIVACY                     │
│  Download My Data                   │
│  Delete All Recordings              │
│  Privacy Policy                     │
│  Terms of Service                   │
│                                     │
├─────────────────────────────────────┤
│  SUPPORT                            │
│  Send Feedback                      │
│  Report a Bug                       │
│  Contact Support                    │
│  Version 1.0.1                      │
│                                     │
│  [  LOG OUT  ]                      │
│                                     │
└─────────────────────────────────────┘
```

---

## 11. ERROR STATES & FALLBACKS

### Network Error (API Down)
```
┌─────────────────────────────────────┐
│  ⚠️                                 │
│                                     │
│  Can't Connect Right Now            │
│                                     │
│  We're having trouble reaching our  │
│  servers. Please check your internet│
│  connection and try again.          │
│                                     │
│  [  TRY AGAIN  ]  [  RETRY  ]      │
│                                     │
│  You can still review your saved    │
│  stories while offline.             │
│                                     │
└─────────────────────────────────────┘
```

### Microphone Permission Denied
```
┌─────────────────────────────────────┐
│  🎙️                                 │
│                                     │
│  Microphone Access Required         │
│                                     │
│  StoryForce needs microphone access │
│  to capture your practice delivery. │
│                                     │
│  [  ENABLE IN SETTINGS  ]           │
│  [  USE TEXT INSTEAD  ]             │
│                                     │
└─────────────────────────────────────┘
```

### Story Generation Failed
```
┌─────────────────────────────────────┐
│  ❌                                 │
│                                     │
│  Couldn't Generate Story            │
│                                     │
│  Something went wrong. This might   │
│  be because your client profile is  │
│  incomplete. Try filling in more    │
│  details.                           │
│                                     │
│  [  BACK TO PROFILE  ]  [  TRY AGAIN ]
│                                     │
└─────────────────────────────────────┘
```

---

## 12. DEVELOPMENT HANDOFF CHECKLIST FOR FABLE

### SwiftUI Components to Build
- [ ] Custom microphone button with recording state animation
- [ ] Voice waveform visualizer (during recording + playback)
- [ ] Score badge (color-coded by rating)
- [ ] Three-act story card (expandable sections)
- [ ] Practice attempt list (collapsible)
- [ ] Loading spinner (pulsing dots)
- [ ] Error state templates
- [ ] Tab navigation bar

### Screens to Implement (In Order)
1. [ ] Splash screen + onboarding carousel
2. [ ] Authentication (sign up / login)
3. [ ] Subscription tier selection
4. [ ] Dashboard (home)
5. [ ] Describe client (voice input)
6. [ ] Confirm profile (review & edit)
7. [ ] Story display (three acts)
8. [ ] Practice screen (voice recording)
9. [ ] Coaching feedback (scores & guidance)
10. [ ] Story library (history)
11. [ ] Settings/account

### API Integration Points
- [ ] /auth/signup, /auth/login
- [ ] /api/profiles/from-voice (Gemini speech-to-text)
- [ ] /api/stories/generate (Fable story generation)
- [ ] /api/stories/:id/practice (Gemini feedback)
- [ ] /api/stories (fetch saved stories)

### Testing Checklist
- [ ] All screens render in light + dark mode
- [ ] Voice recording works on physical device (not just simulator)
- [ ] Accessibility: VoiceOver navigation works
- [ ] Accessibility: Contrast ratios meet WCAG AA
- [ ] All buttons have tactile feedback (haptics)
- [ ] Error states display correctly
- [ ] Network errors handled gracefully
- [ ] Loading states don't block UI

---

## SUMMARY: UI/UX READY FOR IMPLEMENTATION

This design system is **production-ready** for Fable to:
1. ✅ Build screens in SwiftUI using provided layouts
2. ✅ Implement components from the library
3. ✅ Integrate voice input/output via Gemini + Fable
4. ✅ Handle error states and edge cases
5. ✅ Optimize for accessibility (WCAG AA)
6. ✅ Test on device before App Store submission

**Estimated UI/UX development time for Fable:** 120–150 hours  
**Status:** Ready for handoff

---

*Design system prepared for Claude Fable implementation*  
*UI/UX review completed: July 2, 2026*  
*Status: APPROVED FOR DEVELOPMENT*
