# ── Flutter ───────────────────────────────────────────────────────────────────
# Flutter embedding uses reflection to load the FlutterMain class and JNI.
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# ── Kotlin / Coroutines ───────────────────────────────────────────────────────
-keep class kotlin.** { *; }
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.coroutines.**

# ── Supabase / Ktor / OkHttp ──────────────────────────────────────────────────
# Supabase-kt uses Ktor under the hood (OkHttp engine on Android).
# Ktor's OkHttp engine uses reflection for platform detection.
-keep class io.ktor.** { *; }
-dontwarn io.ktor.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# ── kotlinx.serialization ─────────────────────────────────────────────────────
# Supabase-kt uses kotlinx.serialization. The plugin generates companion objects
# that must survive shrinking.
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.**
-keepclassmembers class kotlinx.serialization.json.** { *** Companion; }
-keep @kotlinx.serialization.Serializable class ** { *; }
-keepclassmembers @kotlinx.serialization.Serializable class ** {
    *** Companion;
    *** serializer(...);
}

# ── Google Sign-In ────────────────────────────────────────────────────────────
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.**

# ── Dio (via dart:ffi) — Dart-only, no JVM rules needed ──────────────────────
# Dio runs in Dart; the JVM classes below are for Android platform channels only.

# ── Play Core / SplitCompat (suppressed warnings) ────────────────────────────
-dontwarn com.google.android.play.**

# ── Miscellaneous safe-to-ignore warnings ─────────────────────────────────────
-dontwarn java.lang.instrument.**
-dontwarn sun.misc.**
