// CI: bazı eklentiler (ör. flutter_plugin_android_lifecycle, file_picker'ın
// geçişli bağımlılığı) compileSdk 36 ister. Eklenti alt-projeleri kendi
// compileSdk'sini flutter.compileSdkVersion'dan alır; bu blok, kök
// android/build.gradle.kts'e eklenir ve değerlendirme anında tüm Android
// alt-projelerinin compileSdk'sini 36'ya yükseltir.
//
// AGP sürümleri arasında setter adı/imzası değişebildiğinden yansıma ile
// hem `setCompileSdk(Integer)` hem `setCompileSdkVersion(int)` denenir.
subprojects {
    afterEvaluate {
        val androidExt = extensions.findByName("android") ?: return@afterEvaluate
        val setter = androidExt.javaClass.methods.firstOrNull {
            (it.name == "setCompileSdkVersion" || it.name == "setCompileSdk") &&
                it.parameterTypes.size == 1 &&
                (it.parameterTypes[0] == Int::class.javaPrimitiveType ||
                    it.parameterTypes[0] == Integer::class.java)
        }
        try {
            setter?.invoke(androidExt, 36)
        } catch (_: Throwable) {
        }
    }
}
