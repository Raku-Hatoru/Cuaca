---
name: Nocturne Celestial Weather
colors:
  surface: '#051231'
  surface-dim: '#051231'
  surface-bright: '#2d3859'
  surface-container-lowest: '#010c2b'
  surface-container-low: '#0e1a39'
  surface-container: '#121e3d'
  surface-container-high: '#1d2948'
  surface-container-highest: '#283454'
  on-surface: '#dae1ff'
  on-surface-variant: '#c2c6d6'
  inverse-surface: '#dae1ff'
  inverse-on-surface: '#242f4f'
  outline: '#8c909f'
  outline-variant: '#424753'
  surface-tint: '#aec6ff'
  primary: '#aec6ff'
  on-primary: '#002e6a'
  primary-container: '#4e8eff'
  on-primary-container: '#00275d'
  inverse-primary: '#005ac3'
  secondary: '#b7c4ff'
  on-secondary: '#002681'
  secondary-container: '#0443ce'
  on-secondary-container: '#b6c3ff'
  tertiary: '#b6c4ff'
  on-tertiary: '#00287e'
  tertiary-container: '#678aff'
  on-tertiary-container: '#00226f'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#aec6ff'
  on-primary-fixed: '#001a42'
  on-primary-fixed-variant: '#004395'
  secondary-fixed: '#dce1ff'
  secondary-fixed-dim: '#b7c4ff'
  on-secondary-fixed: '#001551'
  on-secondary-fixed-variant: '#0039b4'
  tertiary-fixed: '#dce1ff'
  tertiary-fixed-dim: '#b6c4ff'
  on-tertiary-fixed: '#00164f'
  on-tertiary-fixed-variant: '#003bb0'
  background: '#051231'
  on-background: '#dae1ff'
  surface-variant: '#283454'
  background-top: '#071433'
  background-bottom: '#0B1F5C'
  electric-glow: '#1E4FD8'
  accent-gradient-start: '#4C8DFF'
  accent-gradient-end: '#2B5BE0'
  text-primary: '#FFFFFF'
  text-secondary: '#A9B8DC'
  text-muted: '#687B9E'
  surface-glass: rgba(255, 255, 255, 0.07)
  surface-glass-active: rgba(255, 255, 255, 0.14)
  border-glass: rgba(255, 255, 255, 0.10)
  ring-outer: rgba(255, 255, 255, 0.18)
  ring-inner: rgba(30, 79, 216, 0.45)
  error-alert: '#FF5A5F'
  status-warning: '#FDB44B'
typography:
  display-hero:
    fontFamily: Manrope
    fontSize: 84px
    fontWeight: '300'
    lineHeight: 92px
    letterSpacing: -0.04em
  display-hero-mobile:
    fontFamily: Manrope
    fontSize: 68px
    fontWeight: '300'
    lineHeight: 76px
    letterSpacing: -0.03em
  headline-xl:
    fontFamily: Manrope
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  title-md:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  body-lg:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Manrope
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-md:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.04em
  label-sm:
    fontFamily: Manrope
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.02em
  caption:
    fontFamily: Manrope
    fontSize: 10px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.06em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-2xs: 0.25rem
  space-xs: 0.5rem
  space-sm: 0.75rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
  space-2xl: 2.5rem
  space-3xl: 3.5rem
---

## Brand & Style

The design system embodies a modern, atmospheric nocturnal aesthetic crafted for high-clarity meteorological visualization. It balances scientific precision with a serene, nocturnal ambiance—evoking the quiet depth of a starry night sky illuminated by electric bioluminescent glows.

### Personality & Emotional Response
- **Atmospheric & Immersive:** Deep navy tones mimic real nighttime sky environments, instilling calmness, focus, and wonder.
- **Precise & Scientific:** Data points, percentages, and metrics are rendered with surgical clarity and high visual hierarchy.
- **Fluid & Tactile:** Elements feel lightweight and buoyant, floating naturally above the celestial canvas with translucent glassmorphism and subtle ring glows.

### Visual Style
The system employs an **Atmospheric Glassmorphic** aesthetic characterized by:
- Deep multi-stop navy gradients (`#071433` to `#0B1F5C`) paired with ambient radial electric glows (`#1E4FD8`).
- Concentric, glowing semi-transparent gauge rings for hero temperature indicators.
- Ultra-low opacity glass card surfaces with delicate 10% white perimeter strokes.
- Floating bottom navigation with a sculpted convex circular center notch that anchors the core action (Search).

## Colors

The palette is engineered exclusively for a rich dark mode experience. High-contrast celestial blues contrast against ink-like nocturnal surfaces, ensuring effortless glanceability under any lighting condition.

### Palette Architecture
- **Primary (`#4C8DFF`):** Vibrant electric sky blue used for active focal elements, primary button fills, selected chips, and dynamic weather highlights.
- **Secondary (`#1E4FD8`):** Deep cobalt blue used for underlying atmospheric halos, progress ring fills, and interactive press states.
- **Tertiary (`#2B5BE0`):** Saturated royal blue providing depth and contrast within gradient progressions.
- **Neutral (`#071433`):** Inky deep navy foundation tone that guarantees black-level contrast without harsh true-black clipping.

### Functional Surfaces & Tokens
- **Background Atmosphere:** Linear gradient running from `#071433` (zenith) to `#0B1F5C` (nadir), enriched with a radial blur node of `rgba(30, 79, 216, 0.40)` centered behind the hero weather ring.
- **Glass Surfaces:** Cards and bottom tab bars utilize `rgba(255, 255, 255, 0.07)` with an ultra-thin border stroke of `rgba(255, 255, 255, 0.10)` to differentiate tiers without visual clutter.
- **Text Layers:** Primary metrics and titles strictly utilize pure `#FFFFFF`, while metadata, secondary parameters, and inactive labels utilize `#A9B8DC`.

## Typography

The design system relies on **Manrope**, an open-source modern geometric sans-serif featuring crisp curves, clear numerals, and wide letter apertures that maintain legibility at glance speed.

### Type Scale Roles
- **Hero Display (`display-hero` / `display-hero-mobile`):** Dedicated to the central current temperature. Rendered with a light weight (`300`) to keep the massive glyphs light, airy, and elegant inside the circular weather ring.
- **Section Headlines (`headline-xl`, `headline-lg`):** Anchors major sections like "Detail Hari Ini" and city headers with high contrast weight (`600` / `700`).
- **Body & Metrics (`body-lg`, `body-md`):** Presents condition descriptions, wind speeds, humidity indices, and apparent temperatures.
- **Labels & Overlines (`label-md`, `label-sm`, `caption`):** Capitalized or tracking-boosted micro-copy used for time markers, tabular headers (e.g., "SEMALAM", "HARI INI", "MALAM INI"), and navigation item descriptions.

## Layout & Spacing

The layout model is anchored on an 8pt spatial grid system, standardizing component distances, card padding, and vertical rhythm.

### Grid & Adaptive Layout
- **Mobile First Canvas (Fluid):** Standard outer horizontal gutter is `1.25rem` (20px), ensuring edge-to-edge immersion while avoiding bezel clipping on curved glass phones.
- **Safe Area & Floating Navigation Clearance:** Because the navigation bar floats dynamically above content, all scrolling containers must terminate with a mandatory bottom padding of `6.5rem` (104px) to ensure no list items or buttons are obscured.
- **Weather Ring Proportions:** The central weather ring scales dynamically to exactly `58vw` on compact viewports, with a strict minimum of `220px` and maximum clamp of `310px`.

### Spacing Breakpoints
- **Mobile (<600px):** Single-column layout, vertical metric stacking, full-width glass cards.
- **Tablet (600px - 1024px):** Dual-column layout; hero weather ring pinned to the left column, 24-hour horizontal carousel and 7-day forecast cards arranged along the right column.

## Elevation & Depth

Visual hierarchy is constructed through **atmospheric glassmorphism and luminous halo stratification**, rather than conventional drop shadows.

### Depth Layers
1. **Zenith Surface (Base Layer 0):** The deep midnight vertical gradient (`#071433` to `#0B1F5C`) acts as the boundless universe canvas.
2. **Atmospheric Luminescence (Layer 1):** Soft radial glows (`#1E4FD8` at 35% opacity with 48px to 64px gaussian blur) placed directly behind current weather status nodes, establishing local focus.
3. **Glassmorphic Cards (Layer 2):** Translucent containers crafted with:
   - Fill: `rgba(255, 255, 255, 0.07)`
   - Backdrop Filter: `blur(20px)`
   - Border: `1px solid rgba(255, 255, 255, 0.10)`
   - Drop Shadow: `0 8px 32px 0 rgba(7, 20, 51, 0.37)`
4. **Floating Notch Navigation Bar (Layer 3):**
   - Fill: `rgba(9, 27, 74, 0.88)`
   - Backdrop Filter: `blur(24px)`
   - Border: `1px solid rgba(255, 255, 255, 0.12)`
   - Shadow: `0 16px 40px rgba(0, 0, 0, 0.45)`
5. **Floating Action Hub (Layer 4 - Center Search):** Elevated circular pill with radiant gradient (`#4C8DFF` to `#2B5BE0`) paired with an electric aura shadow: `0 8px 24px rgba(76, 141, 255, 0.50)`.

## Shapes

The geometric personality features soft, fluid contours that complement cloud formations and planetary arcs. Sharp corners are avoided.

### Corner Radius System
- **Metric Cards & Detail Containers:** `16px` (`rounded-lg`) curvature provides a refined, friendly enclosure.
- **Floating Bar Body:** Sculpted with `28px` corner radiuses for an ergonomic, pill-like handheld perimeter.
- **Circular Indicators & Center Search Button:** Completely circular (`9999px` / `rounded-full`), providing instant visual contrast against rectangular glass cards.
- **Weather Ring Hero:** A multi-layered concentric circle. Outer ring stroke: `2px` with `rgba(255, 255, 255, 0.18)`; inner accent ring: `3px` with `#4C8DFF` tracking dynamic precipitation probability or humidity.

## Components

### Hero Weather Ring
- **Visual Composition:** A concentric circular gauge centered in the viewport.
- **Content Flow:** Weather condition outline icon at top center (e.g., crescent moon or sun with clouds), followed by the colossal `display-hero` temperature value, apparent temperature ("Terasa seperti 28°"), and an interactive pill trigger ("Cuaca Mendatang →") that navigates directly to the 7-day outlook.

### Floating Notch Tab Bar
- **Geometry:** Suspended `16px` above the bottom screen margin and inset `16px` from left and right edges.
- **Notch Feature:** A custom convex curved cutout at top-center housing the 56px circular Search FAB.
- **Tab Arrangement:** 
  - Left of notch: "Hari Ini" (Home) and "Per Jam" (Hourly).
  - Center: Blue gradient circular Search action button (`#4C8DFF` to `#2B5BE0`) with magnifying glass icon.
  - Right of notch: "Harian" (7-Day) and "Favorit" (Saved Cities).
- **Tab Item State:** Inactive tabs display outline icons and text at `rgba(255, 255, 255, 0.60)`; active tab switches to full `#FFFFFF` with a bright indicator dot underneath.

### Hourly Forecast Timeline Tile
- **Structure:** Horizontal rail of vertical glass capsules or list rows.
- **Current Hour Highlight:** Highlighted with a solid white circular background pill (`#FFFFFF`), flipping the font color to `#071433` for instant scan visibility.
- **Data Nodes:** Displays hour timestamp, weather condition icon, primary temperature, apparent temperature, and droplet icon with precipitation percentage (`#4C8DFF`).

### Glassmorphic Metric Cards
- **Grid Tiles:** 2x2 or 3x1 glass tiles displaying Humidity (`%`), Wind Speed (`km/j`), Precipitation (`mm`), and Sunrise/Sunset times.
- **Visual Pattern:** Small icon in upper-left in `#4C8DFF`, small uppercase label in `#A9B8DC`, followed by bold metric display in `#FFFFFF`.

### Search Input Field & Geocoding Results
- **Search Bar:** Pill-shaped glass container (`border-radius: 9999px`) with search icon prefix, clear button suffix, and placeholder text in `#687B9E`. Debounced at 500ms.
- **Result Row:** Glass list tile with city name in `title-md` (`#FFFFFF`), administrative division and country in `body-sm` (`#A9B8DC`), and a trailing star icon button for instant local storage favoriting (`#FDB44B` when bookmarked).

### Feedback & Error States
- **Loading:** Pulsing glowing ring skeletons accompanied by a slender electric blue `CircularProgressIndicator`.
- **Empty & Error Messages:** Centered state illustration, clear Indonesian narrative ("Kota tidak ditemukan" or "Gagal memuat data cuaca"), paired with a glass-morphic pill button styled with `#4C8DFF` border for "Coba Lagi".