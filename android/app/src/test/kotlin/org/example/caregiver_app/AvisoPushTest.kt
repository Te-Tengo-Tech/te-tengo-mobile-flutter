package org.example.caregiver_app

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class AvisoPushTest {

    private val datos = mapOf(
        "tipo" to "ALERTA_CAIDA",
        "alertaId" to "a-1",
        "ocurridaEn" to "2026-11-15T18:00:00Z",
        "titulo" to "Posible caída",
        "cuerpo" to "Sala · 13:00",
        "grupo" to "a-1",
        "canal" to "alertas_caida",
        "google.message_id" to "0:1",
        "from" to "123",
    )

    @Test
    fun `lee un aviso solo de datos de la API`() {
        val aviso = AvisoPush.desde(datos)!!
        assertEquals("Posible caída", aviso.titulo)
        assertEquals("Sala · 13:00", aviso.cuerpo)
        assertEquals("a-1", aviso.grupo)
        assertEquals("alertas_caida", aviso.canal)
        // Only the API's data travels with the tap.
        assertEquals(setOf("tipo", "alertaId", "ocurridaEn", "titulo", "cuerpo", "grupo", "canal"), aviso.datos.keys)
    }

    @Test
    fun `sin canal usa el de alertas y sin grupo el id de la alerta`() {
        val aviso = AvisoPush.desde(datos - "canal" - "grupo")!!
        assertEquals(MainActivity.CANAL_ALERTAS, aviso.canal)
        assertEquals("a-1", aviso.grupo)
    }

    @Test
    fun `no dibuja los mensajes de notificacion, que dibuja FCM`() {
        assertNull(AvisoPush.desde(datos + ("gcm.notification.title" to "Posible caída")))
        assertNull(AvisoPush.desde(datos + ("gcm.n.e" to "1")))
    }

    @Test
    fun `sin titulo no hay nada que mostrar`() {
        assertNull(AvisoPush.desde(datos - "titulo"))
        assertNull(AvisoPush.desde(mapOf("tipo" to "ALERTA_CAIDA")))
    }
}
