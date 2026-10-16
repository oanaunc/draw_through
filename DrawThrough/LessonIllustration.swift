import SwiftUI

/// Original instructional artwork. Coordinates share the practice pad's 4:3 space.
struct LessonIllustration: View {
    let lessonID: Int
    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 720, y: size.height / 540)
            let ink = DTTheme.ink.opacity(0.78)
            let guide = DTTheme.sepia.opacity(0.45)
            func line(_ points: [CGPoint], color: Color = ink, width: CGFloat = 2) {
                guard let first = points.first else { return }
                var path = Path(); path.move(to: first)
                points.dropFirst().forEach { path.addLine(to: $0) }
                context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
            }
            func stroke(_ path: Path, color: Color = ink, width: CGFloat = 2) {
                context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
            }
            func oval(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, fill: Color? = nil) {
                let path = Path(ellipseIn: CGRect(x: x, y: y, width: w, height: h))
                if let fill { context.fill(path, with: .color(fill)) }
                stroke(path)
            }
            func box(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, fill: Color? = nil) {
                let path = Path(CGRect(x: x, y: y, width: w, height: h))
                if let fill { context.fill(path, with: .color(fill)) }
                stroke(path)
            }
            func dot(_ x: CGFloat, _ y: CGFloat) {
                context.fill(Path(ellipseIn: CGRect(x: x - 5, y: y - 5, width: 10, height: 10)), with: .color(DTTheme.clay))
            }
            func label(_ text: String, _ x: CGFloat, _ y: CGFloat) {
                context.draw(Text(text).font(.system(size: 17, weight: .medium, design: .serif)).foregroundStyle(DTTheme.clay), at: CGPoint(x: x, y: y))
            }
            func leaf(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
                var path = Path(); path.move(to: CGPoint(x: x, y: y + h))
                path.addQuadCurve(to: CGPoint(x: x + w, y: y), control: CGPoint(x: x - w * 0.25, y: y - h * 0.2))
                path.addQuadCurve(to: CGPoint(x: x, y: y + h), control: CGPoint(x: x + w * 1.2, y: y + h * 0.9))
                stroke(path)
                line([CGPoint(x: x, y: y + h), CGPoint(x: x + w, y: y)], color: guide)
            }
            switch lessonID {
            case 1:
                for i in 0..<5 {
                    let y = CGFloat(105 + i * 77)
                    dot(125, y); dot(595, y - CGFloat(i * 8))
                    line([CGPoint(x: 125, y: y), CGPoint(x: 595, y: y - CGFloat(i * 8))], width: 1.5)
                }
            case 2:
                for i in 0..<3 {
                    let x = CGFloat(125 + i * 220)
                    var p = Path(); p.move(to: CGPoint(x: x + 80, y: 100))
                    if i == 1 {
                        p.addCurve(to: CGPoint(x: x + 80, y: 430), control1: CGPoint(x: x - 130, y: 210), control2: CGPoint(x: x + 240, y: 320))
                    } else {
                        p.addCurve(to: CGPoint(x: x + 80, y: 430), control1: CGPoint(x: x - 90, y: 140), control2: CGPoint(x: x - 90, y: 390))
                    }
                    stroke(p); dot(x + 80, 100); dot(x + 80, 430)
                }
            case 3:
                for i in 0..<3 {
                    let y = CGFloat(90 + i * 150), h = CGFloat(45 + i * 35)
                    oval(175, y, 370, h)
                    line([CGPoint(x: 150, y: y + h / 2), CGPoint(x: 570, y: y + h / 2)], color: guide, width: 1)
                    line([CGPoint(x: 360, y: y - 15), CGPoint(x: 360, y: y + h + 15)], color: guide, width: 1)
                }
            case 4:
                oval(130, 100, 250, 250); box(290, 215, 250, 210)
                line([CGPoint(x: 290, y: 350), CGPoint(x: 290, y: 215), CGPoint(x: 380, y: 215)], width: 6)
                line([CGPoint(x: 540, y: 425), CGPoint(x: 290, y: 425)], width: 4)
                label("overlap → stronger edge", 360, 475)
            case 5, 10:
                if lessonID == 10 {
                    for i in 0...4 {
                        let n = CGFloat(110 + i * 125)
                        line([CGPoint(x: n, y: 65), CGPoint(x: n, y: 475)], color: guide, width: 1)
                    }
                    for i in 0...4 {
                        let n = CGFloat(65 + i * 102)
                        line([CGPoint(x: 110, y: n), CGPoint(x: 610, y: n)], color: guide, width: 1)
                    }
                }
                leaf(220, 100, 275, 320)
                line([CGPoint(x: 220, y: 420), CGPoint(x: 195, y: 465)])
            case 6:
                line([CGPoint(x: 350, y: 85), CGPoint(x: 435, y: 135), CGPoint(x: 545, y: 360), CGPoint(x: 455, y: 465), CGPoint(x: 230, y: 465), CGPoint(x: 175, y: 360), CGPoint(x: 275, y: 135), CGPoint(x: 350, y: 85)], color: guide)
                oval(285, 125, 135, 160); oval(205, 260, 310, 200)
                var p = Path(); p.move(to: CGPoint(x: 350, y: 135)); p.addQuadCurve(to: CGPoint(x: 385, y: 70), control: CGPoint(x: 350, y: 85)); stroke(p, width: 4)
            case 7:
                oval(465, 180, 140, 180, fill: DTTheme.sepia.opacity(0.13)); oval(485, 205, 85, 125)
                var p = Path(); p.move(to: CGPoint(x: 175, y: 170)); p.addQuadCurve(to: CGPoint(x: 210, y: 405), control: CGPoint(x: 175, y: 395)); p.addQuadCurve(to: CGPoint(x: 465, y: 405), control: CGPoint(x: 335, y: 460)); p.addLine(to: CGPoint(x: 500, y: 170)); stroke(p)
                oval(175, 130, 325, 80)
                label("observe the opening", 360, 485)
            case 8:
                line([CGPoint(x: 360, y: 65), CGPoint(x: 360, y: 475)], color: guide, width: 1)
                for i in 0...4 {
                    let y = CGFloat(75 + i * 100)
                    line([CGPoint(x: 175, y: y), CGPoint(x: 545, y: y)], color: guide, width: 1)
                }
                line([CGPoint(x: 320, y: 75), CGPoint(x: 400, y: 75), CGPoint(x: 400, y: 170), CGPoint(x: 470, y: 235), CGPoint(x: 470, y: 475), CGPoint(x: 250, y: 475), CGPoint(x: 250, y: 235), CGPoint(x: 320, y: 170), CGPoint(x: 320, y: 75)])
            case 9:
                line([CGPoint(x: 90, y: 410), CGPoint(x: 225, y: 165), CGPoint(x: 310, y: 290), CGPoint(x: 440, y: 95), CGPoint(x: 630, y: 410)])
                line([CGPoint(x: 70, y: 430), CGPoint(x: 650, y: 430)], color: guide)
                line([CGPoint(x: 225, y: 165), CGPoint(x: 440, y: 165)], color: guide, width: 1)
                label("compare each slope", 360, 485)
            case 11:
                for i in 0..<5 {
                    let x = CGFloat(70 + i * 120)
                    box(x, 170, 100, 150, fill: DTTheme.ink.opacity(Double(i) * 0.22))
                    label("\(i + 1)", x + 50, 355)
                }
                label("light                           →                           dark", 360, 110)
            case 12:
                oval(280, 385, 310, 65, fill: DTTheme.ink.opacity(0.16))
                oval(195, 100, 300, 300, fill: DTTheme.sepia.opacity(0.10))
                line([CGPoint(x: 110, y: 70), CGPoint(x: 190, y: 140)], color: guide)
                label("light", 105, 45)
                context.clip(to: Path(ellipseIn: CGRect(x: 195, y: 100, width: 300, height: 300)))
                for i in 0..<13 {
                    let x = CGFloat(290 + i * 13)
                    var p = Path(); p.move(to: CGPoint(x: x, y: 205))
                    p.addQuadCurve(to: CGPoint(x: x - 40, y: 365), control: CGPoint(x: x + 65, y: 290)); stroke(p, color: guide)
                }
            case 13:
                for i in 0..<3 {
                    let x = CGFloat(75 + i * 220)
                    for j in 0..<10 {
                        let offset = CGFloat(j * 14)
                        var p = Path(); p.move(to: CGPoint(x: x, y: 180 + offset))
                        if i == 2 { p.addQuadCurve(to: CGPoint(x: x + 145, y: 180 + offset), control: CGPoint(x: x + 72, y: 250 + offset)) }
                        else { p.addLine(to: CGPoint(x: x + 145, y: 225 + offset)) }
                        stroke(p, width: 1.5)
                        if i == 1 { line([CGPoint(x: x + offset, y: 170), CGPoint(x: x + offset + 15, y: 365)], width: 1.5) }
                    }
                }
            case 14:
                let center = CGPoint(x: 360, y: 250)
                box(80, 65, 560, 410); box(265, 180, 190, 140)
                for p in [CGPoint(x: 80, y: 65), CGPoint(x: 640, y: 65), CGPoint(x: 80, y: 475), CGPoint(x: 640, y: 475)] { line([p, center], color: guide) }
                line([CGPoint(x: 65, y: 250), CGPoint(x: 655, y: 250)], color: guide, width: 1)
                dot(360, 250); label("eye level", 125, 230)
            case 15:
                oval(225, 105, 270, 85); oval(225, 350, 270, 110)
                line([CGPoint(x: 225, y: 147), CGPoint(x: 225, y: 405)])
                line([CGPoint(x: 495, y: 147), CGPoint(x: 495, y: 405)])
                line([CGPoint(x: 360, y: 70), CGPoint(x: 360, y: 480)], color: guide, width: 1)
            case 16:
                var p = Path(); p.move(to: CGPoint(x: 300, y: 475)); p.addQuadCurve(to: CGPoint(x: 390, y: 65), control: CGPoint(x: 390, y: 280)); stroke(p, width: 3)
                leaf(335, 110, 60, 125); leaf(215, 170, 135, 115); leaf(355, 220, 150, 110); leaf(205, 320, 125, 90)
            case 17:
                var p = Path(); p.move(to: CGPoint(x: 430, y: 70)); p.addCurve(to: CGPoint(x: 260, y: 470), control1: CGPoint(x: 280, y: 200), control2: CGPoint(x: 440, y: 310)); stroke(p, color: guide, width: 4)
                oval(390, 70, 75, 85); oval(300, 175, 120, 150); oval(310, 320, 110, 70)
                line([CGPoint(x: 320, y: 205), CGPoint(x: 210, y: 250), CGPoint(x: 150, y: 190)])
                line([CGPoint(x: 405, y: 210), CGPoint(x: 500, y: 265), CGPoint(x: 555, y: 225)])
                line([CGPoint(x: 330, y: 375), CGPoint(x: 300, y: 425), CGPoint(x: 260, y: 475)])
                line([CGPoint(x: 390, y: 375), CGPoint(x: 470, y: 410), CGPoint(x: 490, y: 475)])
            case 18:
                for i in 0..<3 {
                    let x = CGFloat(50 + i * 225)
                    box(x, 160, 185, 210)
                    oval(x + CGFloat(30 + i * 13), 200, CGFloat(100 - i * 8), 100, fill: DTTheme.sepia.opacity(0.10))
                    box(x + 80, 280, 80, 65, fill: DTTheme.ink.opacity(0.12))
                    label(["balance", "emphasis", "space"][i], x + 90, 410)
                }
            case 19:
                oval(315, 185, 90, 90)
                for i in 0..<8 {
                    var petal = Path(ellipseIn: CGRect(x: 335, y: 75, width: 50, height: 110))
                    let angle = CGFloat(i) * .pi / 4
                    petal = petal.applying(CGAffineTransform(translationX: -360, y: -230).concatenating(CGAffineTransform(rotationAngle: angle)).concatenating(CGAffineTransform(translationX: 360, y: 230)))
                    stroke(petal)
                }
                line([CGPoint(x: 360, y: 350), CGPoint(x: 340, y: 470)])
                leaf(350, 365, 105, 70)
            default:
                line([CGPoint(x: 100, y: 430), CGPoint(x: 630, y: 430)], color: guide)
                oval(150, 260, 220, 165, fill: DTTheme.sepia.opacity(0.08))
                line([CGPoint(x: 400, y: 180), CGPoint(x: 415, y: 405), CGPoint(x: 570, y: 405), CGPoint(x: 590, y: 180)])
                oval(400, 145, 190, 70); oval(580, 210, 65, 105)
                line([CGPoint(x: 250, y: 265), CGPoint(x: 275, y: 230)], width: 4)
                oval(270, 410, 340, 35, fill: DTTheme.ink.opacity(0.10))
            }
        }
        .aspectRatio(4 / 3, contentMode: .fit)
        .accessibilityLabel("Instructional illustration for \(DrawingLesson.all.first { $0.id == lessonID }?.title ?? "drawing")")
    }
}
