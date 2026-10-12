package tech.tetengo.te_tengo

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * The home-screen widget of Te Tengo (US-44): the older adult's state as the app last saved it
 * (`lib/features/widget`), never an image of the home (CA-44.1). A tap opens the app on the active
 * alert, «Cámaras» or Inicio, and «Ver en vivo» opens it on the room picker; the widget never opens
 * the live view by itself (CA-44.2). Signed out, it only asks to open the app (CA-44.3).
 */
abstract class WidgetTeTengo(private val diseno: Int) : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, vistas(context, widgetData))
        }
    }

    private fun vistas(context: Context, datos: SharedPreferences): RemoteViews {
        val v = RemoteViews(context.packageName, diseno)
        val tono = datos.getString("tt_tono", null) ?: "pausa"
        val conSesion = datos.getString("tt_conSesion", "no") == "si"
        val titulo = datos.getString("tt_titulo", null) ?: context.getString(R.string.widget_nombre)
        val linea = datos.getString("tt_linea", null) ?: context.getString(R.string.widget_cargando)
        v.setTextViewText(R.id.titulo, titulo)
        v.setTextViewText(R.id.linea, linea)
        if (diseno == R.layout.widget_te_tengo_grande) {
            v.setTextViewText(R.id.actualizado, datos.getString("tt_actualizado", "") ?: "")
        }
        v.setTextViewText(R.id.iniciales, datos.getString("tt_iniciales", "") ?: "")

        val fondo = when (tono) {
            "caida" -> R.drawable.widget_fondo_caida
            "inestable" -> R.drawable.widget_fondo_inestable
            "aviso" -> R.drawable.widget_fondo_aviso
            "pausa" -> R.drawable.widget_fondo_pausa
            else -> R.drawable.widget_fondo_calma
        }
        v.setInt(R.id.raiz, "setBackgroundResource", fondo)

        // The state's icon on a round badge: never color alone (DESIGN.md).
        val (insignia, icono, colorIcono) = when (tono) {
            "caida" -> Triple(R.drawable.widget_insignia_caida, R.drawable.widget_ico_fall, 0xFFD63B2F.toInt())
            "inestable" -> Triple(R.drawable.widget_insignia_inestable, R.drawable.widget_ico_unsteady, 0xFF2B1D4E.toInt())
            "aviso" -> Triple(R.drawable.widget_insignia_aviso, R.drawable.widget_ico_wifioff, Color.WHITE)
            "pausa" -> Triple(R.drawable.widget_insignia_pausa, R.drawable.widget_ico_lock, Color.WHITE)
            else -> Triple(R.drawable.widget_insignia_calma, R.drawable.widget_ico_check, Color.WHITE)
        }
        v.setInt(R.id.insignia, "setBackgroundResource", insignia)
        v.setImageViewResource(R.id.insignia, icono)
        v.setInt(R.id.insignia, "setColorFilter", colorIcono)

        // Over the red and mustard floods the text and the button turn as in the prototype.
        when (tono) {
            "caida" -> {
                for (id in textos()) v.setTextColor(id, Color.WHITE)
                botonClaro(v, R.drawable.widget_ico_video_rojo, 0xFFA12A1F.toInt())
            }
            "inestable" -> {
                for (id in textos()) v.setTextColor(id, 0xFF2B1D4E.toInt())
                botonClaro(v, R.drawable.widget_ico_video_tinta, 0xFF2B1D4E.toInt())
            }
            "aviso" -> v.setTextColor(R.id.linea, context.getColor(R.color.widget_aviso_tinta))
        }

        v.setViewVisibility(R.id.foto, if (conSesion) View.VISIBLE else View.GONE)
        v.setViewVisibility(R.id.ver_en_vivo, if (conSesion) View.VISIBLE else View.GONE)
        v.setContentDescription(R.id.raiz, "Te Tengo: $titulo, $linea. Abrir la app")

        val destino = datos.getString("tt_destino", "/inicio") ?: "/inicio"
        v.setOnClickPendingIntent(
            R.id.raiz,
            HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("tetengo-widget://abrir?ir=" + Uri.encode(destino)),
            ),
        )
        v.setOnClickPendingIntent(
            R.id.ver_en_vivo,
            HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("tetengo-widget://abrir?ir=%2Finicio&vivo=1"),
            ),
        )
        return v
    }

    /** The texts of this size: the 2 × 2 has no brand line nor time. */
    private fun textos(): List<Int> =
        if (diseno == R.layout.widget_te_tengo_grande) {
            listOf(R.id.titulo, R.id.linea, R.id.marca, R.id.actualizado)
        } else {
            listOf(R.id.titulo, R.id.linea)
        }

    private fun botonClaro(v: RemoteViews, icono: Int, color: Int) {
        v.setInt(R.id.ver_en_vivo, "setBackgroundResource", R.drawable.widget_boton_claro)
        v.setTextColor(R.id.ver_en_vivo, color)
        v.setTextViewCompoundDrawablesRelative(R.id.ver_en_vivo, icono, 0, 0, 0)
    }
}

/** 4 × 2. */
class WidgetTeTengoGrande : WidgetTeTengo(R.layout.widget_te_tengo_grande)

/** 2 × 2. */
class WidgetTeTengoPequeno : WidgetTeTengo(R.layout.widget_te_tengo_pequeno)
