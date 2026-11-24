// 生成小满 IPTV 应用图标：星空里的一颗星球，倾斜的轨道环绕，轨道上有一颗发光的卫星
// 用法：swift tools/make_icon.swift out.png
import AppKit

let S: CGFloat = 1024
let img = NSImage(size: NSSize(width: S, height: S))
img.lockFocus()
let ctx = NSGraphicsContext.current!.cgContext
let rgb = CGColorSpaceCreateDeviceRGB()
func c(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor { CGColor(red: r/255, green: g/255, blue: b/255, alpha: a) }
func grad(_ cols: [CGColor], _ locs: [CGFloat]) -> CGGradient { CGGradient(colorsSpace: rgb, colors: cols as CFArray, locations: locs)! }

// 1. 圆角底板：深夜蓝紫渐变
let plate = CGRect(x: 100, y: 100, width: 824, height: 824)
let platePath = CGPath(roundedRect: plate, cornerWidth: 186, cornerHeight: 186, transform: nil)
ctx.saveGState()
ctx.addPath(platePath); ctx.clip()
ctx.drawLinearGradient(grad([c(8, 10, 32), c(28, 18, 72), c(52, 22, 96)], [0, 0.6, 1]),
                       start: CGPoint(x: 200, y: 924), end: CGPoint(x: 824, y: 100), options: [])
// 角落的星云光晕
ctx.drawRadialGradient(grad([c(0, 200, 255, 0.28), c(0, 200, 255, 0)], [0, 1]),
                       startCenter: CGPoint(x: 820, y: 800), startRadius: 0,
                       endCenter: CGPoint(x: 820, y: 800), endRadius: 420, options: [])
ctx.drawRadialGradient(grad([c(255, 60, 160, 0.22), c(255, 60, 160, 0)], [0, 1]),
                       startCenter: CGPoint(x: 220, y: 220), startRadius: 0,
                       endCenter: CGPoint(x: 220, y: 220), endRadius: 380, options: [])

// 2. 星星（固定种子，图标每次生成都一样）
var seed: UInt64 = 20261124
func rnd() -> CGFloat { seed = seed &* 6364136223846793005 &+ 1442695040888963407; return CGFloat(seed >> 33) / CGFloat(1 << 31) }
for _ in 0..<70 {
    let p = CGPoint(x: 110 + rnd() * 804, y: 110 + rnd() * 804)
    let r = 1.5 + rnd() * rnd() * 5
    ctx.setFillColor(c(255, 255, 255, 0.35 + rnd() * 0.6))
    ctx.fillEllipse(in: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2))
}
// 一颗十字闪光星
func sparkle(_ p: CGPoint, _ len: CGFloat) {
    ctx.setFillColor(c(255, 255, 255, 0.95))
    let path = CGMutablePath()
    path.move(to: CGPoint(x: p.x, y: p.y + len))
    path.addQuadCurve(to: CGPoint(x: p.x + len, y: p.y), control: p)
    path.addQuadCurve(to: CGPoint(x: p.x, y: p.y - len), control: p)
    path.addQuadCurve(to: CGPoint(x: p.x - len, y: p.y), control: p)
    path.addQuadCurve(to: CGPoint(x: p.x, y: p.y + len), control: p)
    ctx.addPath(path); ctx.fillPath()
}
sparkle(CGPoint(x: 260, y: 760), 34)
sparkle(CGPoint(x: 790, y: 300), 22)

// 3. 轨道参数（倾斜椭圆）
let center = CGPoint(x: 512, y: 500)
let tilt: CGFloat = -0.38
let ringA: CGFloat = 330, ringB: CGFloat = 112
func ringPath() -> CGPath {
    var t = CGAffineTransform(translationX: center.x, y: center.y).rotated(by: tilt)
    return CGPath(ellipseIn: CGRect(x: -ringA, y: -ringB, width: ringA * 2, height: ringB * 2), transform: &t)
}
func strokeRing(frontOnly: Bool) {
    ctx.saveGState()
    if frontOnly {
        // 只画靠近观众的下半圈（在旋转坐标里 y < 0）
        ctx.translateBy(x: center.x, y: center.y); ctx.rotate(by: tilt)
        ctx.clip(to: CGRect(x: -600, y: -600, width: 1200, height: 600))
        ctx.rotate(by: -tilt); ctx.translateBy(x: -center.x, y: -center.y)
    }
    ctx.addPath(ringPath())
    ctx.setLineWidth(26)
    ctx.replacePathWithStrokedPath()
    ctx.clip()
    ctx.drawLinearGradient(grad([c(90, 240, 255), c(160, 130, 255), c(255, 120, 200)], [0, 0.5, 1]),
                           start: CGPoint(x: 160, y: 380), end: CGPoint(x: 860, y: 620), options: [])
    ctx.restoreGState()
}

// 后半圈
ctx.setAlpha(0.55); strokeRing(frontOnly: false); ctx.setAlpha(1)

// 4. 星球：暖色球体 + 外发光
let R: CGFloat = 200
ctx.drawRadialGradient(grad([c(255, 120, 90, 0.45), c(255, 80, 140, 0)], [0, 1]),
                       startCenter: center, startRadius: R * 0.8, endCenter: center, endRadius: R * 1.65, options: [])
ctx.saveGState()
ctx.addEllipse(in: CGRect(x: center.x - R, y: center.y - R, width: R * 2, height: R * 2)); ctx.clip()
ctx.drawRadialGradient(grad([c(255, 226, 150), c(255, 140, 90), c(232, 60, 120), c(110, 30, 120)], [0, 0.35, 0.7, 1]),
                       startCenter: CGPoint(x: center.x - 70, y: center.y + 80), startRadius: 0,
                       endCenter: center, endRadius: R * 1.05, options: [])
// 星球表面的条带
ctx.setStrokeColor(c(255, 255, 255, 0.16)); ctx.setLineWidth(18)
for dy: CGFloat in [-90, -20, 60] {
    ctx.move(to: CGPoint(x: center.x - R, y: center.y + dy + 30))
    ctx.addCurve(to: CGPoint(x: center.x + R, y: center.y + dy - 30),
                 control1: CGPoint(x: center.x - 60, y: center.y + dy + 70),
                 control2: CGPoint(x: center.x + 60, y: center.y + dy - 70))
}
ctx.strokePath()
ctx.restoreGState()

// 前半圈压在星球上
strokeRing(frontOnly: true)

// 5. 卫星：轨道前侧的发光点
let theta: CGFloat = -0.55 * .pi
let local = CGPoint(x: ringA * cos(theta), y: ringB * sin(theta))
let sat = CGPoint(x: center.x + local.x * cos(tilt) - local.y * sin(tilt),
                  y: center.y + local.x * sin(tilt) + local.y * cos(tilt))
ctx.drawRadialGradient(grad([c(255, 255, 255, 1), c(150, 240, 255, 0.8), c(90, 240, 255, 0)], [0, 0.3, 1]),
                       startCenter: sat, startRadius: 0, endCenter: sat, endRadius: 70, options: [])
ctx.setFillColor(c(255, 255, 255))
ctx.fillEllipse(in: CGRect(x: sat.x - 20, y: sat.y - 20, width: 40, height: 40))
ctx.restoreGState()

// 底板细描边
ctx.addPath(platePath); ctx.setStrokeColor(c(255, 255, 255, 0.10)); ctx.setLineWidth(4); ctx.strokePath()

img.unlockFocus()
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
