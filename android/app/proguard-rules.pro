# BouncyCastle
-keep class org.bouncycastle.** { *; }

# Conscrypt
-keep class org.conscrypt.** { *; }

# OpenJSSE
-keep class org.openjsse.** { *; }

# OkHttp / Retrofit (Optional, prevents networking issues)
-keepattributes Signature
-keepattributes *Annotation*
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }
-keep class javax.annotation.** { *; }
-dontwarn okhttp3.**
-dontwarn retrofit2.**
-dontwarn javax.annotation.**
