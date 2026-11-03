# 🤖 Reglas de protección para LiteRT (Antes TensorFlow Lite)
-keep class com.google.android.litert.** { *; }
-dontwarn com.google.android.litert.**

# 📈 Reglas de protección para ONNX Runtime (Recomendación de presupuestos)
-keep class ai.onnxruntime.** { *; }
-dontwarn ai.onnxruntime.**

# Reglas generales para evitar que Flutter rompa la serialización de modelos JSON
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}