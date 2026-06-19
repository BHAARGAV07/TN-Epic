# Premium AR Heritage UI - Visual Architecture

## Layer Stack Diagram

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  LAYER 4G: Calibration Indicator                       │
│  (Bottom-Right Corner, IgnorePointer)                  │
│  ✓ Only visible during floor detection                 │
│  ✓ Non-blocking, semi-transparent                      │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  LAYER 4F: Checkpoint Notifications                     │
│  (Top-Center, IgnorePointer, Auto-Dismiss)             │
│  ✓ Slides in from left                                 │
│  ✓ Displays 2.8 seconds, fades out                     │
│  ✓ Never covers path                                   │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  LAYER 4E: Active Simulation HUD                        │
│  (Bottom, Semi-Transparent Bar)                        │
│  ✓ Walking indicator + Speed display                   │
│  ✓ Appears only during simulation                      │
│  ✓ Dark background with gold accent                    │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  LAYER 4D: Simulation Control Center                    │
│  (Bottom, Large Glowing Button)                        │
│  ✓ "START SACRED WALK" button                          │
│  ✓ Pulsing walk icon                                   │
│  ✓ Elastic entrance animation                          │
│  ✓ Gold glow effect                                    │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  LAYER 4C: Right Navigation Telemetry                   │
│  (Top-Right Corner)                                     │
│  ✓ Distance to destination                             │
│  ✓ Checkpoints counter                                 │
│  ✓ Gold-tinted glassmorphism                           │
│  ✓ Slides in from right                                │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  LAYER 4B: Left Discovery Card                         │
│  (Top-Left Corner)                                     │
│  ✓ Heritage title & description                        │
│  ✓ Cyan-tinted glassmorphism                           │
│  ✓ Slides in from left                                 │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  LAYER 4A: Top Status Bar                              │
│  (Top, Full-Width Gradient)                            │
│  ✓ VIO Status Badge ("HERITAGE CORRIDOR LOCKED")       │
│  ✓ Score Display (Tokens + Dharma)                     │
│  ✓ Telemetry Chips (VION, AR, GPS, PATH)              │
│  ✓ Fades from opaque to transparent bottom             │
│                                                         │
├──────────────────────────────────────────────────────────┤
│                         ★ CRITICAL ★                    │
│                  LAYER 2: GOLDEN PATH                   │
│           (ArViewport CustomPainter)                    │
│                                                          │
│  ✓✓✓ ALWAYS VISIBLE AT 100% OPACITY ✓✓✓               │
│  ✓ Golden corridor mesh (glowing edges)                │
│  ✓ Direction chevrons (animated)                       │
│  ✓ Corridor walls (wireframe)                          │
│  ✓ Floor plane grid (cyan)                             │
│  ✓ Quest nodes (coins, checkpoints, beacons)           │
│  ✓ Particle effects on collection                      │
│  ✓ NEVER covered by UI overlays                        │
│  ✓ ALWAYS rendered above background                    │
│                                                          │
├──────────────────────────────────────────────────────────┤
│                                                         │
│  LAYER 1: AR Camera Stream                              │
│  (CameraPreview, Full-Screen)                          │
│  ✓ Live camera feed                                    │
│  ✓ Foundation for AR rendering                         │
│  ✓ Initialization tracked by FutureBuilder             │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Stack Composition (Code View)

```dart
Stack(
  children: [
    // Layer 1: Camera
    Positioned.fill(CameraPreview),
    
    // Layer 2: Golden Path (CRITICAL)
    Positioned.fill(RepaintBoundary(ArViewport)),
    
    // Layer 4: UI Overlays (Non-blocking)
    ARPremiumHUD(
      // 4A: Top Status Bar
      // 4B: Left Discovery Card
      // 4C: Right Navigation Telemetry
      // 4D: Simulation Controls
      // 4E: Active Simulation HUD
      // 4F: Checkpoint Notifications
      // 4G: Calibration Indicator
    ),
    
    // Layer 4 Extra: Reward Notifications
    RewardNotificationManager(
      // Stacked notifications (IgnorePointer enabled)
      // Auto-dismiss after 2.8 seconds
    ),
  ],
)
```

## Color Palette

```
╔═══════════════════════════════════════════════════════════════╗
║             CYBER-HERITAGE COLOR SYSTEM                      ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  PRIMARY (Heritage)                                           ║
║  ■ Chola Gold         #D4AF37  RGB(212, 175, 55)             ║
║    └─ Used for: Path, buttons, primary text                  ║
║                                                               ║
║  SECONDARY (Futuristic)                                       ║
║  ■ Neon Cyan          #00E5FF  RGB(0, 229, 255)              ║
║    └─ Used for: Status, checkpoints, glow effects            ║
║                                                               ║
║  BACKGROUND                                                   ║
║  ■ Deep Navy          #0A0E27  RGB(10, 14, 39)               ║
║    └─ Used for: Main background, dark panels                 ║
║                                                               ║
║  ACCENT                                                       ║
║  ■ Emerald Green      #10B981  RGB(16, 185, 129)             ║
║    └─ Used for: Floor plane, subtle accents                  ║
║                                                               ║
║  TEXT                                                         ║
║  ■ Premium White      #F3F4F6  RGB(243, 244, 246)            ║
║    └─ Used for: Body text, high contrast                     ║
║                                                               ║
║  TRANSPARENCY PALETTE                                         ║
║  ■ Ultra Light        withOpacity(0.03)  - Subtle            ║
║  ■ Light              withOpacity(0.08)  - Borders            ║
║  ■ Medium             withOpacity(0.15)  - Overlays           ║
║  ■ Heavy              withOpacity(0.25)  - Strong glow        ║
║  ■ Strong             withOpacity(0.6)   - UI panels          ║
║  ■ Opaque             1.0                - Golden path        ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

## Animation Timings

```
╔══════════════════════════════════════════════════════════════╗
║                 ANIMATION SPECIFICATION                      ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  Top Status Bar                                              ║
║  ├─ Entrance: Fade in (gradient opacity)                    ║
║  └─ Duration: 300ms (Curves.easeOut)                        ║
║                                                              ║
║  Left Discovery Card                                         ║
║  ├─ Entrance: Slide from left (-200px → 0px)               ║
║  ├─ Duration: 700ms (Curves.easeOut)                        ║
║  └─ Effect: Smooth deceleration                             ║
║                                                              ║
║  Right Navigation Telemetry                                  ║
║  ├─ Entrance: Slide from right (+200px → 0px)              ║
║  ├─ Duration: 700ms (Curves.easeOut)                        ║
║  └─ Effect: Smooth deceleration                             ║
║                                                              ║
║  Start Sacred Walk Button                                    ║
║  ├─ Entrance: Scale (0.8 → 1.0) + Slide up                 ║
║  ├─ Duration: 600ms (Curves.elasticOut)                     ║
║  ├─ Pulse Animation: 2000ms repeat                          ║
║  │  └─ Scale: 0.8 ↔ 1.2 (icon only)                        ║
║  └─ Effect: Bouncy, inviting                                ║
║                                                              ║
║  Checkpoint Notification                                     ║
║  ├─ Entrance: Slide from left (-1x → 0x)                   ║
║  ├─ Scale: 0 → 1 (elastic)                                  ║
║  ├─ Display: 2800ms total                                   ║
║  └─ Exit: Fade out (1 → 0 opacity) in last 300ms           ║
║                                                              ║
║  Reward Notification                                         ║
║  ├─ Entrance: Slide right (100px → 0px) + Scale            ║
║  │  └─ Duration: 400ms (Curves.elasticOut)                 ║
║  ├─ Display: 2200ms idle                                    ║
║  ├─ Exit: Slide out + Fade (700ms)                         ║
║  └─ Total: 2800ms                                           ║
║                                                              ║
║  Calibration Ring                                            ║
║  ├─ Progress: Linear (0% → 100%)                            ║
║  ├─ Pulse: 2000ms repeat (scale 0.8 ↔ 1.2)                ║
║  ├─ Smoothness: Smooth curve transitions                     ║
║  └─ Effect: Reassuring activity                             ║
║                                                              ║
║  Golden Path Glow (During Simulation)                        ║
║  ├─ Bloom: 1.0 → 1.22 (bloom boost)                        ║
║  ├─ Chevron: Animated along path                            ║
║  └─ Effect: Enhanced visual feedback                        ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

## Glassmorphism Specification

```
╔═════════════════════════════════════════════════════════════╗
║          GLASSMORPHISM DESIGN SYSTEM                        ║
╠═════════════════════════════════════════════════════════════╣
║                                                             ║
║  LIGHT GLASS (Discovery Card, Telemetry)                  ║
║  ├─ Background: Gradient start 12%, end 3% opacity        ║
║  ├─ Color: Cyan (light) or Gold (warm)                    ║
║  ├─ Border: 1.2px with 25% opacity                        ║
║  ├─ Shadow: Glow shadow at 8-16px blur                    ║
║  └─ Effect: Premium, ethereal appearance                   ║
║                                                             ║
║  MEDIUM GLASS (Status Bar, HUD Cards)                      ║
║  ├─ Background: 40-60% opacity dark layer                  ║
║  ├─ Gradient: Fade from opaque top to transparent          ║
║  ├─ Border: Optional, 15-20% opacity                       ║
║  └─ Effect: Modern, semi-transparent overlay               ║
║                                                             ║
║  DARK GLASS (Panels & Buttons)                             ║
║  ├─ Background: 85% opacity background color               ║
║  ├─ Gradient: Often radial for depth                       ║
║  ├─ Border: Colored (gold/cyan) at 30-40% opacity         ║
║  ├─ Shadow: Multiple layers (12-24px blur)                ║
║  └─ Effect: Solid yet sophisticated                        ║
║                                                             ║
║  ICON GLOW                                                  ║
║  ├─ Radial Gradient: Center bright, edges transparent     ║
║  ├─ Colors: Match primary element color                    ║
║  ├─ Opacity: 30% at center, 5% at edges                   ║
║  └─ Effect: Soft, inviting icon appearance                 ║
║                                                             ║
╚═════════════════════════════════════════════════════════════╝
```

## Interaction States

```
╔═══════════════════════════════════════════════════════════╗
║              UI ELEMENT STATES                            ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║  START SACRED WALK BUTTON                                ║
║  ├─ Default:  Glowing, pulsing icon, full opacity       ║
║  ├─ Hover:    Slight scale up, enhanced glow            ║
║  ├─ Pressed:  Scale down slightly, brief hold           ║
║  └─ Active:   Changes to "WALKING SACRED PATH" HUD      ║
║                                                           ║
║  STATUS BADGE                                             ║
║  ├─ Calibrating: Gold color, pulse animation            ║
║  ├─ Locked:      Cyan color, checkmark icon             ║
║  └─ Active:      Continues to update in real-time       ║
║                                                           ║
║  DISCOVERY CARDS                                          ║
║  ├─ Before Load:   Hidden (slide in from side)          ║
║  ├─ Loaded:        Fully visible, static                ║
║  ├─ Content:       Updates dynamically                   ║
║  └─ Visibility:    Always above path (non-blocking)      ║
║                                                           ║
║  CHECKPOINTS                                              ║
║  ├─ Undiscovered:  Not rendered in HUD                   ║
║  ├─ Discovered:    Notification slides in                ║
║  ├─ Display:       2.8 seconds, then fades              ║
║  └─ Indicator:     Counter updates in telemetry         ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

## Performance Targets

```
╔════════════════════════════════════════════════════════════╗
║              PERFORMANCE SPECIFICATIONS                   ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║  FRAME RATE                                                ║
║  Target: 60 FPS (16.67ms per frame)                       ║
║  Method: AnimationController with vsync:true             ║
║  Optimization: RepaintBoundary on ArViewport             ║
║                                                            ║
║  MEMORY USAGE                                              ║
║  Target: <50MB for UI layer                               ║
║  Method: Const constructors, proper disposal              ║
║  Monitoring: Dart DevTools profiler                       ║
║                                                            ║
║  STARTUP TIME                                              ║
║  Cold Start: <3 seconds to path visibility                ║
║  Floor Detect: <30 seconds calibration                    ║
║  Method: Efficient initialization, lazy loading           ║
║                                                            ║
║  ANIMATION SMOOTHNESS                                      ║
║  Jank Prevention: No blocking operations in UI             ║
║  State Updates: Minimal setState scope                     ║
║  Paint Calls: Optimized CustomPainter rendering           ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
```

## Responsiveness Across Devices

```
╔═════════════════════════════════════════════════════════════╗
║           DEVICE ADAPTATION STRATEGY                       ║
╠═════════════════════════════════════════════════════════════╣
║                                                             ║
║  SMALL PHONES (360x640)                                    ║
║  ├─ Card Width: Reduced to ~160px                         ║
║  ├─ Font Size: Smaller (9-11px)                            ║
║  ├─ Padding: Minimal (8px)                                 ║
║  └─ Layout: Stacked efficiently                            ║
║                                                             ║
║  STANDARD PHONES (412x915)                                 ║
║  ├─ Card Width: Optimal ~165px                             ║
║  ├─ Font Size: Standard (10-13px)                          ║
║  ├─ Padding: Comfortable (12-16px)                         ║
║  └─ Layout: Balanced symmetry                              ║
║                                                             ║
║  TABLETS (768x1024)                                        ║
║  ├─ Card Width: Larger ~200px                              ║
║  ├─ Font Size: Readable (11-14px)                          ║
║  ├─ Padding: Generous (16-20px)                            ║
║  └─ Layout: Spacious, centered                             ║
║                                                             ║
║  SAFE AREAS                                                │
║  ├─ Top: MediaQuery.of(context).padding.top               ║
║  ├─ Bottom: Accounted in button positioning                ║
║  ├─ Notches: Properly inset                                ║
║  └─ Landscape: Handled by responsive design                ║
║                                                             ║
╚═════════════════════════════════════════════════════════════╝
```

## Critical Success Path ✨

```
USER JOURNEY → PATH VISIBILITY GUARANTEE

1. App Opens
   └─→ Camera loads
       └─→ Path NOT yet visible (floor detecting)

2. Floor Detection (30s)
   └─→ Scan completes
       └─→ STATUS CHANGES TO "HERITAGE CORRIDOR LOCKED"
           └─→ PATH BECOMES VISIBLE ✨ ✨ ✨

3. Exploration Phase
   └─→ Path remains visible
       ├─→ Cards slide in (path still visible)
       └─→ Discovery continues (path always visible)

4. Start Simulation
   └─→ Button animates
       └─→ User taps "START SACRED WALK"
           └─→ PATH REMAINS VISIBLE ✨ (CRITICAL)
               └─→ Camera moves to eye-level
                   └─→ Walking begins
                       └─→ Path guides entire journey

5. Checkpoint Found
   └─→ Notification slides in
       └─→ PATH STILL FULLY VISIBLE ✨ (IgnorePointer)
           └─→ Notification auto-dismisses
               └─→ Journey continues with clear path

6. Route Complete
   └─→ Beacon reached
       └─→ Celebration animation
           └─→ PATH VISIBLE TO THE END ✨
               └─→ Option to reset and walk again

═══════════════════════════════════════════════════════════════
GUARANTEE: Golden path is ALWAYS visible from floor detection
           through the entire user journey. Never obscured,
           never dimmed, never hidden. 100% uptime.
═══════════════════════════════════════════════════════════════
```
