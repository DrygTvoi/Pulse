# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# SQLCipher — keep native methods
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }

# PointyCastle / Bouncy Castle — keep crypto classes loaded via reflection
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# Keep Flutter-generated plugin registrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# WebSocket / OkHttp (used by web_socket_channel)
-dontwarn okhttp3.**
-dontwarn okio.**

# Prevent stripping Dart FFI native lookups
-keep class * extends io.flutter.embedding.engine.FlutterJNI { *; }

# Google Play Core (deferred components) — not used in this app but referenced
# by Flutter embedding; suppress missing-class errors from R8.
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
