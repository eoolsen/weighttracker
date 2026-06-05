# Screenshots Workflow

App Store requires at least one screenshot at **6.9"** (iPhone 16 Pro Max).  
Optional but recommended: **6.5"** and iPad 13" Pro if you want iPad-specific shots.

---

## Recommended Screens to Capture

Capture these 4–5 screens — they tell the full story of the app:

1. **Log tab with entries** — shows the weight list with several entries logged
2. **Charts tab — Goal Progress** — gauge showing progress toward goal
3. **Charts tab — Weight Over Time** — line chart with trend
4. **Charts tab — BMI** — BMI chart with category lines
5. **Settings** — height and goal weight input

---

## Step-by-step with Xcode Simulator

1. Open the project in Xcode
2. Select the **iPhone 16 Pro Max** simulator (6.9")
3. Run the app (`Cmd+R`)
4. Add realistic sample data:
   - Go to Settings → enter height (e.g. `1.80`) and goal (e.g. `80.0`) → Save
   - Go to Log → add 6–10 entries spanning several weeks with realistic weights
     - Tip: use entries like 88.5, 87.8, 87.2, 86.9, 86.1, 85.5, 85.0 to show a downward trend
5. Navigate to each screen listed above
6. Take screenshot: **Cmd+S** in Simulator (saves to Desktop)
7. Repeat for iPhone 15 Plus simulator (6.5") — or skip if Apple auto-scaling is acceptable

---

## Simulator Sizes Reference

| Simulator | Display Size | Required? |
|---|---|---|
| iPhone 16 Pro Max | 6.9" | Yes |
| iPhone 15 Plus or 14 Plus | 6.5" | Recommended |
| iPad Pro 13" (M4) | 13" Pro | Only if supporting iPad |

---

## Optional: Add a Background / Frame

For a more polished look, tools like **Rottenwood**, **AppShots**, or **Sketch** let you place screenshots inside device frames with a caption. Not required by Apple but common in the store.

---

## Upload in App Store Connect

1. Go to your app listing → **1.0 Prepare for Submission**
2. Under **iPhone Screenshots**, drag in your 6.9" shots
3. Reorder them — put the most compelling screen first
4. Add optional caption text per screenshot (appears as overlay text in some storefronts)

---

## Tips

- Use real-looking data, not placeholder values
- Avoid showing the status bar with a low battery or bad signal — Simulator uses a clean status bar by default
- Screenshots must not contain the iPad home indicator if submitted as iPhone screenshots
- PNG or JPEG accepted; PNG preferred for sharpness
