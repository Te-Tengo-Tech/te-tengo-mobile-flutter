package org.example.caregiver_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.core.app.NotificationCompat

/**
 * A notice the app draws itself, read from the data of an FCM data-only push (API contract §7,
 * `avisoEnLaApp`). FCM keeps only the latest *notification* message while a phone is offline
 * (notification messages are always collapsible), so the API sends this phone data-only messages,
 * which FCM stores up to 100 of, and the app shows each one as FCM showed a notification message:
 * same channel, same tag (a later notice of the same alert replaces the earlier one), same tap.
 */
data class AvisoPush(
    val titulo: String,
    val cuerpo: String,
    val grupo: String,
    val canal: String,
    val datos: Map<String, String>,
) {
    companion object {
        /**
         * Null when the push is not a data-only notice of the API: FCM's own notification messages
         * (`gcm.notification.*`, which FCM draws) and data without `titulo` (nothing to show).
         */
        fun desde(extras: Map<String, String>): AvisoPush? {
            if (extras.keys.any { it.startsWith("gcm.notification.") || it.startsWith("gcm.n.") }) return null
            val titulo = extras["titulo"]?.takeIf { it.isNotBlank() } ?: return null
            val datos = extras.filterKeys { !it.startsWith("google.") && !it.startsWith("gcm.") && it != "from" && it != "collapse_key" }
            return AvisoPush(
                titulo = titulo,
                cuerpo = extras["cuerpo"].orEmpty(),
                grupo = extras["grupo"]?.takeIf { it.isNotBlank() } ?: extras["alertaId"] ?: titulo,
                canal = extras["canal"]?.takeIf { it.isNotBlank() } ?: MainActivity.CANAL_ALERTAS,
                datos = datos,
            )
        }
    }
}

/**
 * Receives every FCM message of the app, like Firebase's own receivers (the same broadcast, only
 * the push service may send it), and draws the data-only notices while the app is not in the
 * foreground. In the foreground nothing is drawn, as with FCM's notification messages: the app shows
 * the notice itself (`FirebaseMessaging.onMessage`). Firebase's receivers still get the message, so
 * the widget update in the background (lib/features/widget) and `onMessage` keep working.
 */
class ReceptorAvisosPush : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (MainActivity.enPrimerPlano) return
        val extras = intent.extras ?: return
        val mapa = extras.keySet().mapNotNull { k -> extras.getString(k)?.let { k to it } }.toMap()
        val aviso = AvisoPush.desde(mapa) ?: return
        mostrar(context, aviso)
    }

    companion object {
        /** Extra of the tap's intent: the push data, read by MainActivity (canal `avisos`). */
        const val EXTRA_PUSH = "tt_push"

        fun mostrar(context: Context, aviso: AvisoPush) {
            val gestor = context.getSystemService(NotificationManager::class.java) ?: return
            crearCanal(gestor, aviso.canal)
            val datos = Bundle().apply { aviso.datos.forEach { (k, v) -> putString(k, v) } }
            val abrir = Intent(context, MainActivity::class.java)
                .setAction("org.example.caregiver_app.AVISO.${aviso.grupo}")
                .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                .putExtra(EXTRA_PUSH, datos)
            val alTocar = PendingIntent.getActivity(
                context,
                aviso.grupo.hashCode(),
                abrir,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            val notificacion = NotificationCompat.Builder(context, aviso.canal)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(aviso.titulo)
                .setContentText(aviso.cuerpo)
                .setStyle(NotificationCompat.BigTextStyle().bigText(aviso.cuerpo))
                .setAutoCancel(true)
                .setContentIntent(alTocar)
                // Android 7 and earlier have no channels: the channel's importance and sound here.
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setDefaults(NotificationCompat.DEFAULT_ALL)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .build()
            // FCM draws its notification messages with id 0 and the message's tag: the same here, so
            // a later notice of the same alert replaces the earlier one.
            gestor.notify(aviso.grupo, 0, notificacion)
        }

        /** The alert channel may not exist yet if the app was never opened since installed. */
        private fun crearCanal(gestor: NotificationManager, canal: String) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
            if (gestor.getNotificationChannel(canal) != null) return
            if (canal != MainActivity.CANAL_ALERTAS) return
            gestor.createNotificationChannel(MainActivity.canalDeAlertas())
        }
    }
}
