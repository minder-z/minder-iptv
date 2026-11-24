// 生成多款 logo 备选：swift tools/logo_concepts.swift <输出目录>
import AppKit

let S: CGFloat = 1024
let rgb = CGColorSpaceCreateDeviceRGB()
func c(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor { CGColor(red: r/255, green: g/255, blue: b/255, alpha: a) }
func grad(_ cols: [CGColor], _ locs: [CGFloat]? = nil) -> CGGradient {
    let l = locs ?? cols.indices.map { CGFloat($0) / CGFloat(max(cols.count - 1, 1)) }
    return CGGradient(colorsSpace: rgb, colors: cols as CFArray, locations: l)!
}
let plate = CGRect(x: 100, y: 100, width: 824, height: 824)
let platePath = CGPath(roundedRect: plate, cornerWidth: 186, cornerHeight: 186, transform: nil)

func render(_ name: String, _ dir: String, _ draw: (CGContext) -> Void) {
    let img = NSImage(size: NSSize(width: S, height: S))
    img.lockFocus()
    let ctx = NSGraphicsContext.current!.cgContext
    // 底板投影
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 28, color: c(0, 0, 0, 0.35))
    ctx.addPath(platePath); ctx.setFillColor(c(0, 0, 0)); ctx.fillPath()
    ctx.restoreGState()
    ctx.saveGState()
    ctx.addPath(platePath); ctx.clip()
    draw(ctx)
    ctx.restoreGState()
    ctx.addPath(platePath); ctx.setStrokeColor(c(255, 255, 255, 0.12)); ctx.setLineWidth(3); ctx.strokePath()
    img.unlockFocus()
    let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(dir)/\(name).png"))
}

func linear(_ ctx: CGContext, _ cols: [CGColor], from: CGPoint = CGPoint(x: 512, y: 924), to: CGPoint = CGPoint(x: 512, y: 100)) {
    ctx.drawLinearGradient(grad(cols), start: from, end: to, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
}
func glow(_ ctx: CGContext, _ p: CGPoint, _ r: CGFloat, _ col: CGColor) {
    ctx.drawRadialGradient(grad([col, col.copy(alpha: 0)!]), startCenter: p, startRadius: 0, endCenter: p, endRadius: r, options: [])
}
var seed: UInt64 = 7
func rnd() -> CGFloat { seed = seed &* 6364136223846793005 &+ 1442695040888963407; return CGFloat(seed >> 33) / CGFloat(1 << 31) }
func stars(_ ctx: CGContext, _ n: Int, _ alpha: CGFloat = 0.8) {
    for _ in 0..<n {
        let p = CGPoint(x: 120 + rnd() * 784, y: 120 + rnd() * 784), r = 1.5 + rnd() * rnd() * 5
        ctx.setFillColor(c(255, 255, 255, alpha * (0.4 + rnd() * 0.6)))
        ctx.fillEllipse(in: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2))
    }
}
func text(_ s: String, font: String, size: CGFloat, color: NSColor, center: CGPoint) {
    let f = NSFont(name: font, size: size) ?? .boldSystemFont(ofSize: size)
    let a = NSAttributedString(string: s, attributes: [.font: f, .foregroundColor: color])
    let b = a.size()
    a.draw(at: CGPoint(x: center.x - b.width / 2, y: center.y - b.height / 2))
}

let dir = CommandLine.arguments[1]

// ───────── A 星球（现用）─────────
render("A_planet", dir) { ctx in
    linear(ctx, [c(8, 10, 32), c(28, 18, 72), c(52, 22, 96)], from: CGPoint(x: 200, y: 924), to: CGPoint(x: 824, y: 100))
    glow(ctx, CGPoint(x: 820, y: 800), 420, c(0, 200, 255, 0.28))
    seed = 20261124; stars(ctx, 60)
    let center = CGPoint(x: 512, y: 500), tilt: CGFloat = -0.38, A: CGFloat = 330, B: CGFloat = 112
    func ring(front: Bool) {
        ctx.saveGState()
        if front {
            ctx.translateBy(x: center.x, y: center.y); ctx.rotate(by: tilt)
            ctx.clip(to: CGRect(x: -600, y: -600, width: 1200, height: 600))
            ctx.rotate(by: -tilt); ctx.translateBy(x: -center.x, y: -center.y)
        }
        var t = CGAffineTransform(translationX: center.x, y: center.y).rotated(by: tilt)
        ctx.addPath(CGPath(ellipseIn: CGRect(x: -A, y: -B, width: A * 2, height: B * 2), transform: &t))
        ctx.setLineWidth(26); ctx.replacePathWithStrokedPath(); ctx.clip()
        ctx.drawLinearGradient(grad([c(90, 240, 255), c(160, 130, 255), c(255, 120, 200)]),
                               start: CGPoint(x: 160, y: 380), end: CGPoint(x: 860, y: 620), options: [])
        ctx.restoreGState()
    }
    ctx.setAlpha(0.55); ring(front: false); ctx.setAlpha(1)
    let R: CGFloat = 200
    glow(ctx, center, R * 1.6, c(255, 100, 120, 0.4))
    ctx.saveGState()
    ctx.addEllipse(in: CGRect(x: center.x - R, y: center.y - R, width: R * 2, height: R * 2)); ctx.clip()
    ctx.drawRadialGradient(grad([c(255, 226, 150), c(255, 140, 90), c(232, 60, 120), c(110, 30, 120)], [0, 0.35, 0.7, 1]),
                           startCenter: CGPoint(x: center.x - 70, y: center.y + 80), startRadius: 0, endCenter: center, endRadius: R * 1.05, options: [])
    ctx.restoreGState()
    ring(front: true)
    let th: CGFloat = -0.55 * .pi
    let lp = CGPoint(x: A * cos(th), y: B * sin(th))
    let sat = CGPoint(x: center.x + lp.x * cos(tilt) - lp.y * sin(tilt), y: center.y + lp.x * sin(tilt) + lp.y * cos(tilt))
    glow(ctx, sat, 70, c(180, 245, 255, 0.9))
    ctx.setFillColor(c(255, 255, 255)); ctx.fillEllipse(in: CGRect(x: sat.x - 20, y: sat.y - 20, width: 40, height: 40))
}

// ───────── B 麦穗信号：小满节气的麦穗，顶端发出信号波 ─────────
render("B_wheat", dir) { ctx in
    linear(ctx, [c(18, 70, 56), c(10, 38, 34)])
    glow(ctx, CGPoint(x: 512, y: 700), 460, c(255, 210, 110, 0.22))
    let gold = [c(255, 226, 140), c(240, 170, 60)]
    // 茎
    ctx.setStrokeColor(c(235, 180, 80)); ctx.setLineWidth(22); ctx.setLineCap(.round)
    ctx.move(to: CGPoint(x: 470, y: 190)); ctx.addQuadCurve(to: CGPoint(x: 512, y: 620), control: CGPoint(x: 520, y: 360)); ctx.strokePath()
    // 麦粒：沿茎两侧交错
    for i in 0..<6 {
        let t = CGFloat(i)
        let y = 330 + t * 52, x = 505 + t * 1.5
        for side: CGFloat in [-1, 1] {
            ctx.saveGState()
            ctx.translateBy(x: x + side * 34, y: y + (side > 0 ? 22 : 0))
            ctx.rotate(by: side * -0.55)
            let w: CGFloat = 48 - t * 3, h: CGFloat = 92 - t * 4
            ctx.addEllipse(in: CGRect(x: -w / 2, y: -h / 2, width: w, height: h)); ctx.clip()
            ctx.drawLinearGradient(grad(gold), start: CGPoint(x: 0, y: h / 2), end: CGPoint(x: 0, y: -h / 2), options: [])
            ctx.restoreGState()
        }
    }
    // 顶粒
    ctx.saveGState(); ctx.translateBy(x: 514, y: 655)
    ctx.addEllipse(in: CGRect(x: -24, y: -46, width: 48, height: 92)); ctx.clip()
    ctx.drawLinearGradient(grad(gold), start: CGPoint(x: 0, y: 46), end: CGPoint(x: 0, y: -46), options: [])
    ctx.restoreGState()
    // 信号波
    ctx.setLineCap(.round)
    for (i, r) in [120.0, 185.0, 250.0].enumerated() {
        ctx.setStrokeColor(c(255, 222, 140, 0.95 - CGFloat(i) * 0.25)); ctx.setLineWidth(24)
        ctx.addArc(center: CGPoint(x: 514, y: 655), radius: r, startAngle: .pi * 0.28, endAngle: .pi * 0.72, clockwise: false)
        ctx.strokePath()
    }
}

// ───────── C 满月电视：电视屏幕里一轮将满的月亮 ─────────
render("C_moon_tv", dir) { ctx in
    linear(ctx, [c(22, 30, 74), c(8, 12, 36)])
    seed = 3; stars(ctx, 45, 0.7)
    // 天线
    ctx.setStrokeColor(c(255, 255, 255, 0.92)); ctx.setLineWidth(24); ctx.setLineCap(.round)
    ctx.move(to: CGPoint(x: 512, y: 690)); ctx.addLine(to: CGPoint(x: 410, y: 800))
    ctx.move(to: CGPoint(x: 512, y: 690)); ctx.addLine(to: CGPoint(x: 620, y: 815)); ctx.strokePath()
    ctx.setFillColor(c(255, 255, 255)); ctx.fillEllipse(in: CGRect(x: 595, y: 790, width: 50, height: 50))
    // 机身
    let body = CGRect(x: 210, y: 250, width: 604, height: 450)
    ctx.addPath(CGPath(roundedRect: body, cornerWidth: 110, cornerHeight: 110, transform: nil))
    ctx.setFillColor(c(255, 255, 255, 0.96)); ctx.fillPath()
    // 屏幕
    let scr = body.insetBy(dx: 40, dy: 40)
    let scrPath = CGPath(roundedRect: scr, cornerWidth: 80, cornerHeight: 80, transform: nil)
    ctx.saveGState(); ctx.addPath(scrPath); ctx.clip()
    linear(ctx, [c(36, 44, 110), c(18, 20, 60)], from: CGPoint(x: 512, y: scr.maxY), to: CGPoint(x: 512, y: scr.minY))
    let m = CGPoint(x: 512, y: 475), R: CGFloat = 130
    glow(ctx, m, 260, c(255, 210, 120, 0.45))
    ctx.drawRadialGradient(grad([c(255, 240, 190), c(255, 200, 100)]), startCenter: CGPoint(x: m.x - 40, y: m.y + 40), startRadius: 0, endCenter: m, endRadius: R, options: [])
    // 让月亮"将满未满"：右侧一小块阴影
    ctx.setBlendMode(.normal)
    ctx.saveGState()
    ctx.addEllipse(in: CGRect(x: m.x - R, y: m.y - R, width: R * 2, height: R * 2)); ctx.clip()
    ctx.setFillColor(c(24, 28, 76, 0.92))
    ctx.fillEllipse(in: CGRect(x: m.x - R + 205, y: m.y - R - 10, width: R * 2, height: R * 2 + 20))
    ctx.restoreGState()
    ctx.restoreGState()
}

// ───────── D 印章「小满」：中国红印章，魏碑字体 ─────────
render("D_seal", dir) { ctx in
    linear(ctx, [c(250, 245, 236), c(236, 226, 210)])
    let seal = CGRect(x: 232, y: 232, width: 560, height: 560)
    ctx.addPath(CGPath(roundedRect: seal, cornerWidth: 70, cornerHeight: 70, transform: nil))
    ctx.saveGState(); ctx.clip()
    linear(ctx, [c(222, 52, 44), c(186, 28, 30)], from: CGPoint(x: 300, y: 792), to: CGPoint(x: 720, y: 232))
    ctx.restoreGState()
    // 内框
    ctx.addPath(CGPath(roundedRect: seal.insetBy(dx: 30, dy: 30), cornerWidth: 46, cornerHeight: 46, transform: nil))
    ctx.setStrokeColor(c(255, 244, 232)); ctx.setLineWidth(12); ctx.strokePath()
    let cream = NSColor(red: 1, green: 0.96, blue: 0.91, alpha: 1)
    text("小", font: "Weibei-SC-Bold", size: 232, color: cream, center: CGPoint(x: 512, y: 640))
    text("满", font: "Weibei-SC-Bold", size: 232, color: cream, center: CGPoint(x: 512, y: 395))
    // 印泥斑驳感
    seed = 11
    ctx.setFillColor(c(222, 52, 44, 0.5))
    for _ in 0..<26 {
        let p = CGPoint(x: seal.minX + 40 + rnd() * (seal.width - 80), y: seal.minY + 40 + rnd() * (seal.height - 80))
        let r = 2 + rnd() * 5
        ctx.fillEllipse(in: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2))
    }
}

// ───────── E 发芽电视：复古小电视，天线是一株嫩芽 ─────────
render("E_sprout_tv", dir) { ctx in
    linear(ctx, [c(198, 240, 214), c(150, 214, 186)])
    // 芽
    ctx.setStrokeColor(c(46, 140, 84)); ctx.setLineWidth(22); ctx.setLineCap(.round)
    ctx.move(to: CGPoint(x: 512, y: 640)); ctx.addQuadCurve(to: CGPoint(x: 520, y: 770), control: CGPoint(x: 500, y: 710)); ctx.strokePath()
    func leaf(_ base: CGPoint, _ angle: CGFloat, _ len: CGFloat) {
        ctx.saveGState(); ctx.translateBy(x: base.x, y: base.y); ctx.rotate(by: angle)
        let p = CGMutablePath()
        p.move(to: .zero)
        p.addQuadCurve(to: CGPoint(x: len, y: 0), control: CGPoint(x: len * 0.5, y: len * 0.42))
        p.addQuadCurve(to: .zero, control: CGPoint(x: len * 0.5, y: -len * 0.42))
        ctx.addPath(p); ctx.clip()
        ctx.drawLinearGradient(grad([c(120, 210, 110), c(56, 160, 90)]), start: .zero, end: CGPoint(x: len, y: 0), options: [])
        ctx.restoreGState()
    }
    leaf(CGPoint(x: 518, y: 760), .pi * 0.85, 150)
    leaf(CGPoint(x: 520, y: 762), .pi * 0.18, 170)
    // 机身
    let body = CGRect(x: 200, y: 215, width: 624, height: 450)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 0, color: c(200, 80, 70))
    ctx.addPath(CGPath(roundedRect: body, cornerWidth: 120, cornerHeight: 120, transform: nil))
    ctx.setFillColor(c(255, 122, 104)); ctx.fillPath()
    ctx.restoreGState()
    // 屏幕
    let scr = CGRect(x: 250, y: 265, width: 400, height: 350)
    ctx.addPath(CGPath(roundedRect: scr, cornerWidth: 80, cornerHeight: 80, transform: nil))
    ctx.saveGState(); ctx.clip()
    linear(ctx, [c(60, 64, 90), c(30, 32, 50)], from: CGPoint(x: 450, y: 615), to: CGPoint(x: 450, y: 265))
    // 屏幕反光
    ctx.setFillColor(c(255, 255, 255, 0.12))
    ctx.fillEllipse(in: CGRect(x: 230, y: 470, width: 260, height: 200))
    ctx.restoreGState()
    // 笑脸
    ctx.setStrokeColor(c(255, 255, 255, 0.95)); ctx.setLineWidth(20); ctx.setLineCap(.round)
    ctx.fillEllipse(in: .zero)
    ctx.setFillColor(c(255, 255, 255))
    ctx.fillEllipse(in: CGRect(x: 365, y: 455, width: 34, height: 44))
    ctx.fillEllipse(in: CGRect(x: 500, y: 455, width: 34, height: 44))
    ctx.addArc(center: CGPoint(x: 450, y: 420), radius: 52, startAngle: .pi * 1.15, endAngle: .pi * 1.85, clockwise: false); ctx.strokePath()
    // 旋钮
    ctx.setFillColor(c(255, 236, 220))
    ctx.fillEllipse(in: CGRect(x: 700, y: 520, width: 66, height: 66))
    ctx.fillEllipse(in: CGRect(x: 708, y: 400, width: 50, height: 50))
    ctx.setFillColor(c(200, 80, 70, 0.6))
    for i in 0..<3 { ctx.fill(CGRect(x: 703, y: 300 + CGFloat(i) * 26, width: 60, height: 10)) }
}

// ───────── F 日出 M：白色圆润的 M 像群山，中间升起一轮太阳 ─────────
render("F_sunrise_m", dir) { ctx in
    linear(ctx, [c(255, 150, 70), c(255, 84, 112), c(160, 60, 200)], from: CGPoint(x: 260, y: 924), to: CGPoint(x: 764, y: 100))
    glow(ctx, CGPoint(x: 512, y: 600), 300, c(255, 240, 180, 0.55))
    ctx.setFillColor(c(255, 246, 210))
    ctx.fillEllipse(in: CGRect(x: 512 - 82, y: 560 - 82, width: 164, height: 164))
    let m = CGMutablePath()
    m.move(to: CGPoint(x: 250, y: 300))
    m.addLine(to: CGPoint(x: 250, y: 640))
    m.addLine(to: CGPoint(x: 512, y: 400))
    m.addLine(to: CGPoint(x: 774, y: 640))
    m.addLine(to: CGPoint(x: 774, y: 300))
    ctx.addPath(m)
    ctx.setStrokeColor(c(255, 255, 255)); ctx.setLineWidth(84); ctx.setLineCap(.round); ctx.setLineJoin(.round)
    ctx.strokePath()
}

// ───────── G 信号满格：四格信号柱，最后一格是一枚月牙（"小满"=快满了）─────────
render("G_signal_bars", dir) { ctx in
    linear(ctx, [c(30, 34, 48), c(14, 16, 24)])
    glow(ctx, CGPoint(x: 700, y: 700), 420, c(80, 220, 180, 0.22))
    let cols = [c(80, 220, 180), c(90, 200, 240), c(150, 150, 255), c(255, 200, 110)]
    let w: CGFloat = 108, gap: CGFloat = 46, base: CGFloat = 270
    let x0: CGFloat = 512 - (w * 4 + gap * 3) / 2
    for i in 0..<3 {
        let h = 150 + CGFloat(i) * 130
        let r = CGRect(x: x0 + CGFloat(i) * (w + gap), y: base, width: w, height: h)
        ctx.addPath(CGPath(roundedRect: r, cornerWidth: w / 2, cornerHeight: w / 2, transform: nil))
        ctx.setFillColor(cols[i]); ctx.fillPath()
    }
    // 第四格只"满"了一半：下半实心，上半描边
    let r4 = CGRect(x: x0 + 3 * (w + gap), y: base, width: w, height: 540)
    ctx.addPath(CGPath(roundedRect: r4.insetBy(dx: 7, dy: 7), cornerWidth: w / 2 - 7, cornerHeight: w / 2 - 7, transform: nil))
    ctx.setStrokeColor(cols[3]); ctx.setLineWidth(14); ctx.strokePath()
    ctx.saveGState()
    ctx.addPath(CGPath(roundedRect: r4, cornerWidth: w / 2, cornerHeight: w / 2, transform: nil)); ctx.clip()
    ctx.setFillColor(cols[3]); ctx.fill(CGRect(x: r4.minX, y: r4.minY, width: w, height: 380))
    ctx.restoreGState()
}

print("done")
