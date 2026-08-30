import SwiftUI

enum DTTheme {
    static let ink = Color(red: 0.10, green: 0.095, blue: 0.08)
    static let paper = Color(red: 0.91, green: 0.87, blue: 0.79)
    static let warmPaper = Color(red: 0.96, green: 0.93, blue: 0.87)
    static let line = Color.black.opacity(0.13)
    static let clay = Color(red: 0.45, green: 0.35, blue: 0.27)
}

struct PaperBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [DTTheme.warmPaper, DTTheme.paper], startPoint: .topLeading, endPoint: .bottomTrailing)
            Canvas { context, size in
                for i in 0..<90 {
                    let x = CGFloat((i * 73) % 101) / 101 * size.width
                    let y = CGFloat((i * 41) % 97) / 97 * size.height
                    context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 1.2, height: 1.2)), with: .color(.black.opacity(0.025)))
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct InkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(DTTheme.ink.opacity(configuration.isPressed ? 0.78 : 1), in: RoundedRectangle(cornerRadius: 13))
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
    }
}

