package tech.tetengo.te_tengo

import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    /** The answer to `instalar`, waiting for the Android installer to close. */
    private var instalacionPendiente: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        crearCanalDeAlertas()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CANAL_ACTUALIZACIONES)
            .setMethodCallHandler { llamada, resultado ->
                when (llamada.method) {
                    "puedeInstalar" -> resultado.success(puedeInstalar())
                    "abrirAjustesPermiso" -> {
                        abrirAjustesPermiso()
                        resultado.success(null)
                    }
                    "instalar" -> instalar(llamada.argument<String>("ruta"), resultado)
                    else -> resultado.notImplemented()
                }
            }
    }

    /**
     * The channel of the alert pushes (`android.notification.channel_id` = `alertas_caida`, API
     * contract §7), with high importance so a fall shows as a heads-up notification with sound. It is
     * also the default channel in AndroidManifest.xml, for pushes that name none. Created at every
     * start: it is a no-op once it exists, and the user's own settings for it are kept.
     */
    private fun crearCanalDeAlertas() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val canal = NotificationChannel(CANAL_ALERTAS, "Alertas", NotificationManager.IMPORTANCE_HIGH)
        canal.enableVibration(true)
        canal.lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
        getSystemService(NotificationManager::class.java)?.createNotificationChannel(canal)
    }

    // ---- US-43: updating the sideloaded APK (lib/features/actualizaciones/data/plataforma.dart) ----

    /** Android's «Instalar apps desconocidas» for this app (API 26+; earlier, the system setting). */
    private fun puedeInstalar(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.O || packageManager.canRequestPackageInstalls()

    /** Opens «Instalar apps desconocidas» on this app's own switch. */
    private fun abrirAjustesPermiso() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, Uri.parse("package:$packageName"))
        try {
            startActivity(intent)
        } catch (e: ActivityNotFoundException) {
            startActivity(Intent(Settings.ACTION_SETTINGS))
        }
    }

    /**
     * Opens the Android installer with the verified APK at [ruta] (inside the cache folder that
     * res/xml/actualizaciones.xml shares) through a FileProvider `content://` URI with a temporary
     * read grant. Answers `instalada`, `cancelada` or `fallo` when the installer closes. Android
     * only installs it over this app when it is signed with the same certificate.
     */
    @Suppress("DEPRECATION") // ACTION_INSTALL_PACKAGE is the only intent that reports the result.
    private fun instalar(ruta: String?, resultado: MethodChannel.Result) {
        val archivo = ruta?.let(::File)
        if (archivo == null || !archivo.isFile) {
            resultado.success("fallo")
            return
        }
        instalacionPendiente?.success("fallo")
        try {
            val uri = FileProvider.getUriForFile(this, "$packageName.actualizaciones", archivo)
            val intent = Intent(Intent.ACTION_INSTALL_PACKAGE)
                .setDataAndType(uri, "application/vnd.android.package-archive")
                .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                .putExtra(Intent.EXTRA_RETURN_RESULT, true)
            instalacionPendiente = resultado
            startActivityForResult(intent, PEDIDO_INSTALAR)
        } catch (e: Exception) {
            instalacionPendiente = null
            resultado.success("fallo")
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != PEDIDO_INSTALAR) return
        val pendiente = instalacionPendiente ?: return
        instalacionPendiente = null
        pendiente.success(
            when (resultCode) {
                Activity.RESULT_OK -> "instalada"
                Activity.RESULT_CANCELED -> "cancelada"
                else -> "fallo"
            },
        )
    }

    companion object {
        const val CANAL_ALERTAS = "alertas_caida"
        const val CANAL_ACTUALIZACIONES = "tech.tetengo.te_tengo/actualizaciones"
        const val PEDIDO_INSTALAR = 4301
    }
}
