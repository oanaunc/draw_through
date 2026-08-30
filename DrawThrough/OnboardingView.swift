import SwiftUI

struct OnboardingView: View {
    let finish: () -> Void
    @State private var page = 0
    private let pages = [
        ("OnboardingPlace", "Place your reference", "Add one or more images to use as references."),
        ("OnboardingArrange", "Arrange your composition", "Move, resize and rotate images to create the perfect composition."),
        ("OnboardingTrace", "Lock and draw through", "Keep everything still while your paper rests on the screen.")
    ]

    var body: some View {
        ZStack {
            PaperBackground()
            VStack(spacing: 24) {
                HStack { Text("Draw Through").font(DTTheme.title(29)).italic(); Spacer(); Text("CHAPTER  \(page + 1) / 3").font(DTTheme.smallCaps).tracking(1.2).foregroundStyle(DTTheme.clay.opacity(0.7)) }
                .padding(.horizontal, 24).padding(.top, 18)
                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 18) {
                            Spacer()
                            Image(pages[index].0)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .aspectRatio(0.82, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .overlay(alignment: .bottom) { LinearGradient(colors: [.clear, DTTheme.ink.opacity(0.18)], startPoint: .top, endPoint: .bottom).clipShape(RoundedRectangle(cornerRadius: 30)) }
                                .overlay { RoundedRectangle(cornerRadius: 30).stroke(.white.opacity(0.45), lineWidth: 1) }
                                .shadow(color: .black.opacity(0.18), radius: 26, y: 14)
                            Text(pages[index].1).font(DTTheme.display(36)).foregroundStyle(DTTheme.ink)
                            Text(pages[index].2).font(.system(.body, design: .serif)).foregroundStyle(DTTheme.ink.opacity(0.62)).lineSpacing(4).fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }.padding(.horizontal, 28).tag(index)
                    }
                }.tabViewStyle(.page(indexDisplayMode: .never))
                HStack(spacing: 7) { ForEach(pages.indices, id: \.self) { Circle().fill(page == $0 ? DTTheme.ink : .black.opacity(0.18)).frame(width: 7, height: 7) } }
                Button(page == 2 ? "Start Drawing" : "Continue") { if page == 2 { finish() } else { withAnimation { page += 1 } } }
                    .buttonStyle(InkButtonStyle()).padding(.horizontal, 24).padding(.bottom, 18)
            }
        }
    }
}
