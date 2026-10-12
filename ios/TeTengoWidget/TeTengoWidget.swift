// Home-screen widget of Te Tengo for iPhone (US-44), WidgetKit, systemMedium (4 × 2) and
// systemSmall (2 × 2). It shows the state the app saved through `home_widget` in the App Group
// `group.tech.tetengo.teTengo` (lib/features/widget/data/widget_sistema.dart), never an image of
// the home (CA-44.1). A tap opens the app on the active alert, «Cámaras» or Inicio, and «Ver en vivo»
// on the room picker (CA-44.2); signed out it only asks to open the app (CA-44.3).
//
// NOT YET IN THE XCODE PROJECT: a widget extension needs its own App ID
// (`tech.tetengo.teTengo.TeTengoWidget`), the App Groups capability on both App IDs and provisioning
// profiles for both, from the Apple account owner (docs/BLOCKERS.md, «US-44 widget»). Then, in Xcode:
// File › New › Target › Widget Extension named `TeTengoWidget` (no configuration intent), replace its
// Swift file with this one, set its deployment target to iOS 17 (`containerBackground`; checked with
// `swiftc -parse-as-library -typecheck -target arm64-apple-ios17.0`), add the App Groups capability
// with `group.tech.tetengo.teTengo` to Runner and to the extension, and archive as usual.

import SwiftUI
import WidgetKit

private let grupo = "group.tech.tetengo.teTengo"

struct EstadoTeTengo: TimelineEntry {
    let date: Date
    let tono: String
    let titulo: String
    let linea: String
    let iniciales: String
    /// The PNG of the older adult's round photo the app rendered (`tt_foto`), if any.
    let foto: String?
    let destino: String
    let actualizado: String
    let conSesion: Bool

    static let vacio = EstadoTeTengo(
        date: Date(), tono: "pausa", titulo: "Te Tengo",
        linea: "Abre la app para ver el estado.", iniciales: "", foto: nil, destino: "/inicio",
        actualizado: "", conSesion: false)

    static func leido() -> EstadoTeTengo {
        guard let d = UserDefaults(suiteName: grupo), let tono = d.string(forKey: "tt_tono") else {
            return vacio
        }
        return EstadoTeTengo(
            date: Date(), tono: tono,
            titulo: d.string(forKey: "tt_titulo") ?? "Te Tengo",
            linea: d.string(forKey: "tt_linea") ?? "",
            iniciales: d.string(forKey: "tt_iniciales") ?? "",
            foto: d.string(forKey: "tt_foto"),
            destino: d.string(forKey: "tt_destino") ?? "/inicio",
            actualizado: d.string(forKey: "tt_actualizado") ?? "",
            conSesion: d.string(forKey: "tt_conSesion") == "si")
    }
}

struct Proveedor: TimelineProvider {
    func placeholder(in context: Context) -> EstadoTeTengo { .vacio }

    func getSnapshot(in context: Context, completion: @escaping (EstadoTeTengo) -> Void) {
        completion(.leido())
    }

    /// The app reloads the timeline whenever it saves a state; iOS also asks again in about 30 min.
    func getTimeline(in context: Context, completion: @escaping (Timeline<EstadoTeTengo>) -> Void) {
        let siguiente = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [.leido()], policy: .after(siguiente)))
    }
}

private func url(_ destino: String, vivo: Bool = false) -> URL {
    var c = URLComponents()
    c.scheme = "tetengo-widget"
    c.host = "abrir"
    c.queryItems = [URLQueryItem(name: "ir", value: destino)]
    if vivo { c.queryItems?.append(URLQueryItem(name: "vivo", value: "1")) }
    return c.url!
}

struct VistaTeTengo: View {
    @Environment(\.widgetFamily) var familia
    @Environment(\.colorScheme) var esquema
    let e: EstadoTeTengo

    private var oscuro: Bool { esquema == .dark }
    private var fondo: Color {
        switch e.tono {
        case "caida": return Color(red: 0.84, green: 0.23, blue: 0.18)
        case "inestable": return Color(red: 0.95, green: 0.71, blue: 0.18)
        case "aviso": return oscuro ? Color(red: 0.23, green: 0.17, blue: 0.07) : Color(red: 0.98, green: 0.94, blue: 0.85)
        case "pausa": return oscuro ? Color(red: 0.15, green: 0.17, blue: 0.22) : Color(red: 0.93, green: 0.93, blue: 0.95)
        default: return oscuro ? Color(red: 0.13, green: 0.11, blue: 0.18) : .white
        }
    }
    private var tinta: Color {
        switch e.tono {
        case "caida": return .white
        case "inestable": return Color(red: 0.17, green: 0.11, blue: 0.31)
        default: return oscuro ? Color(red: 0.95, green: 0.94, blue: 0.97) : Color(red: 0.17, green: 0.11, blue: 0.31)
        }
    }
    private var icono: String {
        switch e.tono {
        case "caida": return "figure.fall"
        case "inestable": return "exclamationmark.triangle"
        case "aviso": return "wifi.slash"
        case "pausa": return "lock"
        default: return "checkmark"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if familia == .systemMedium {
                HStack {
                    Text("Te Tengo").font(.subheadline.bold())
                    Spacer()
                    Text(e.actualizado).font(.subheadline.monospacedDigit())
                }
            }
            HStack(spacing: 12) {
                if e.conSesion {
                    ZStack(alignment: .bottomTrailing) {
                        if let ruta = e.foto, let imagen = UIImage(contentsOfFile: ruta) {
                            Image(uiImage: imagen).resizable().scaledToFill()
                                .frame(width: 52, height: 52)
                                .clipShape(Circle())
                                .accessibilityHidden(true)
                        } else {
                            Text(e.iniciales).font(.title3.bold())
                                .frame(width: 52, height: 52)
                                .background(Circle().fill(Color(red: 0.96, green: 0.89, blue: 0.93)))
                                .foregroundColor(Color(red: 0.48, green: 0.14, blue: 0.34))
                        }
                        Image(systemName: icono).font(.caption.bold())
                            .padding(5).background(Circle().fill(Color.white))
                            .foregroundColor(Color(red: 0.11, green: 0.48, blue: 0.30))
                            .accessibilityHidden(true)
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(e.titulo).font(.headline).lineLimit(2)
                    Text(e.linea).font(.subheadline).lineLimit(1)
                }
            }
            Spacer(minLength: 0)
            if e.conSesion {
                Link(destination: url("/inicio", vivo: true)) {
                    Label("Ver en vivo", systemImage: "video")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Capsule().fill(e.tono == "caida" || e.tono == "inestable" ? Color.white : Color(red: 0.29, green: 0.18, blue: 0.51)))
                        .foregroundColor(e.tono == "caida" ? Color(red: 0.63, green: 0.16, blue: 0.12) : e.tono == "inestable" ? tinta : .white)
                }
            }
        }
        .foregroundColor(tinta)
        .padding(14)
        .widgetURL(url(e.destino))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Te Tengo: \(e.titulo), \(e.linea). Abrir la app")
        .containerBackground(fondo, for: .widget)
    }
}

@main
struct TeTengoWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "TeTengoWidget", provider: Proveedor()) { e in
            VistaTeTengo(e: e)
        }
        .configurationDisplayName("Te Tengo")
        .description("Muestra el estado, nunca imágenes de la casa.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
