# Royal Match - Match-3 Puzzle Game

لعبة Match-3 كاملة مبنية باستخدام **Flutter** — تعمل على Android و iOS.

## المميزات ✨

- 🎮 **10 مراحل كاملة** مع أهداف متنوعة (Score / Collect)
- 💥 **Special Tiles**: Rocket (أفقي/رأسي)، Bomb (3×3)، Rainbow (مسح لون كامل)
- ⭐ **نظام نجوم** (1-3 نجمة حسب الأداء)
- 💾 **حفظ التقدم** باستخدام SharedPreferences
- 🎯 **Hint System** — يقترح حركات صحيحة
- 🔄 **Auto-shuffle** عند انسداد اللوحة
- 📊 **HUD ديناميكي** — Score bar / Collect goals
- 🎨 **UI جذاب** — animations smooth

---

## كيفية التشغيل 🚀

### المتطلبات
- Flutter SDK 3.22.0 أو أحدث
- Android Studio (للتشغيل على Android) أو Xcode (لـ iOS)

### التثبيت
```bash
cd match3_game
flutter pub get
flutter run
```

### بناء APK للإنتاج
```bash
flutter build apk --release
```
الملف يكون في: `build/app/outputs/flutter-apk/app-release.apk`

---

## البنية 📂

```
lib/
├── main.dart                    ← نقطة البداية
├── models/                      ← Grid, Tile, TileType
├── logic/                       ← Match detection + Cascade
├── game/                        ← GameController (state management)
├── levels/                      ← Level configs + Progress
├── screens/                     ← UI screens (Menu, Game, Results)
└── widgets/                     ← Reusable components
```

---

## كيفية إضافة مراحل جديدة 🎯

افتح `lib/levels/level_config.dart` وأضف مرحلة جديدة في `levels` list:

```dart
LevelConfig(
  levelNumber: 11,
  moves: 20,
  targetScore: 3000,
  goalType: GoalType.score,
  storyText: 'نص القصة (اختياري)',
),
```

---

## الأداء ⚡

- استخدمنا **SimpleBoard** بدلاً من animations معقدة عشان الأداء على الموبايلات الضعيفة
- الـ Grid بيتولد بدون matches في البداية
- Auto-deadlock detection مع shuffle

---

## الترخيص 📜

هذا المشروع تعليمي — استخدمه كما تشاء.

---

## تواصل 📧

لأي استفسارات أو تحسينات: افتح Issue على GitHub
