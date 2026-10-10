package tech.tetengo.te_tengo

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        crearCanalDeAlertas()
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

    companion object {
        const val CANAL_ALERTAS = "alertas_caida"
    }
}
