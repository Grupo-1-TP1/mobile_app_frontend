# Reglas de protección para TensorFlow Lite (Machine Learning de tu Tesis)
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# Evitar la optimización agresiva sobre los paquetes de la GPU
-dontwarn org.tensorflow.lite.gpu.**