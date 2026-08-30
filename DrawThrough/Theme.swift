import SwiftUI

enum DTTheme {
    static let ink = Color(red: 0.105, green: 0.098, blue: 0.082)
    static let paper = Color(red: 0.86, green: 0.81, blue: 0.72)
    static let warmPaper = Color(red: 0.955, green: 0.925, blue: 0.865)
    static let parchment = Color(red: 0.91, green: 0.86, blue: 0.77)
    static let vellum = Color(red: 0.98, green: 0.955, blue: 0.90)
    static let line = Color(red: 0.28, green: 0.23, blue: 0.18).opacity(0.18)
    static let clay = Color(red: 0.43, green: 0.32, blue: 0.235)
    static let sepia = Color(red: 0.59, green: 0.46, blue: 0.34)

    static func display(_ size: CGFloat) -> Font { .custom("Didot", size: size, relativeTo: .largeTitle) }
    static func title(_ size: CGFloat) -> Font { .custom("Didot", size: size, relativeTo: .title) }
    static let smallCaps = Font.system(.caption, design: .serif, weight: .semibold).smallCaps()
}

struct PaperBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [DTTheme.vellum, DTTheme.warmPaper, DTTheme.parchment], startPoint: .topLeading, endPoint: .bottomTrailing)
            RadialGradient(colors: [.white.opacity(0.38), .clear], center: .topLeading, startRadius: 10, endRadius: 430)
            RadialGradient(colors: [DTTheme.sepia.opacity(0.12), .clear], center: .bottomTrailing, startRadius: 20, endRadius: 520)
            Canvas { context, size in
                for i in 0..<180 {
                    let x = CGFloat((i * 73) % 101) / 101 * size.width
                    let y = CGFloat((i * 41) % 97) / 97 * size.height
                    let length = CGFloat(2 + (i % 7))
                    var fiber = Path()
                    fiber.move(to: CGPoint(x: x, y: y))
                    fiber.addQuadCurve(to: CGPoint(x: x + length, y: y + CGFloat((i % 3) - 1)), control: CGPoint(x: x + length / 2, y: y - 1))
                    context.stroke(fiber, with: .color(i.isMultiple(of: 3) ? .white.opacity(0.08) : .black.opacity(0.025)), lineWidth: 0.45)
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct InkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .serif, weight: .semibold))
            .foregroundStyle(DTTheme.vellum)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(LinearGradient(colors: [DTTheme.ink, DTTheme.ink.opacity(0.88)], startPoint: .top, endPoint: .bottom), in: RoundedRectangle(cornerRadius: 14))
            .overlay { RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.14), lineWidth: 0.7) }
            .shadow(color: DTTheme.ink.opacity(configuration.isPressed ? 0.08 : 0.18), radius: 12, y: 7)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
    }
}

struct VellumSurface: ViewModifier {
    var radius: CGFloat = 18
    func body(content: Content) -> some View {
        content
            .background(LinearGradient(colors: [.white.opacity(0.48), DTTheme.vellum.opacity(0.30)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: radius))
            .overlay { RoundedRectangle(cornerRadius: radius).stroke(.white.opacity(0.48), lineWidth: 0.7) }
            .shadow(color: DTTheme.ink.opacity(0.09), radius: 18, y: 10)
    }
}

extension View {
    func vellumSurface(radius: CGFloat = 18) -> some View { modifier(VellumSurface(radius: radius)) }
    func parchmentList() -> some View {
        scrollContentBackground(.hidden)
            .background { PaperBackground() }
            .tint(DTTheme.clay)
    }
}

struct WarmGlass: View {
    var cornerRadius: CGFloat = 24
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.ultraThinMaterial)
            .overlay { RoundedRectangle(cornerRadius: cornerRadius).fill(DTTheme.warmPaper.opacity(0.30)) }
            .overlay { RoundedRectangle(cornerRadius: cornerRadius).stroke(.white.opacity(0.32), lineWidth: 0.7) }
            .shadow(color: DTTheme.ink.opacity(0.14), radius: 18, y: 8)
    }
}
