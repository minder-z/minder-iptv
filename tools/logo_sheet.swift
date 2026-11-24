// 拼成对比图：swift tools/logo_sheet.swift <目录> <输出.png>
import AppKit
let dir = CommandLine.arguments[1]
let items: [(String, String, String)] = [
  ("A_planet", "A 星球", "现在用的"),
  ("B_wheat", "B 麦穗信号", "小满节气 · 麦穗发出信号"),
  ("C_moon_tv", "C 满月电视", "屏幕里一轮将满的月亮"),
  ("D_seal", "D 小满印章", "中国红印章 · 魏碑字"),
  ("E_sprout_tv", "E 发芽电视", "可爱小电视 · 天线是嫩芽"),
  ("F_sunrise_m", "F 日出 M", "Minder 的 M · 群山日出"),
  ("G_signal_bars", "G 信号小满", "信号格最后一格将满未满"),
]
let cell: CGFloat = 320, cols = 4, pad: CGFloat = 30
let rows = Int(ceil(Double(items.count) / Double(cols)))
let W = CGFloat(cols) * cell + pad * 2, H = CGFloat(rows) * (cell + 150) + pad * 2
let img = NSImage(size: NSSize(width: W, height: H))
img.lockFocus()
NSColor(white: 0.96, alpha: 1).setFill(); NSRect(x: 0, y: 0, width: W, height: H).fill()
for (i, it) in items.enumerated() {
  let col = CGFloat(i % cols), row = CGFloat(i / cols)
  let x = pad + col * cell, top = H - pad - row * (cell + 150)
  let icon = NSImage(contentsOfFile: "\(dir)/\(it.0).png")!
  icon.draw(in: NSRect(x: x + 20, y: top - 280, width: 280, height: 280))
  // 小尺寸预览（Dock / 菜单栏大小）
  icon.draw(in: NSRect(x: x + 60, y: top - 350, width: 64, height: 64))
  icon.draw(in: NSRect(x: x + 140, y: top - 334, width: 32, height: 32))
  icon.draw(in: NSRect(x: x + 188, y: top - 326, width: 16, height: 16))
  let t = NSAttributedString(string: it.1, attributes: [.font: NSFont.boldSystemFont(ofSize: 22), .foregroundColor: NSColor.black])
  t.draw(at: NSPoint(x: x + 30, y: top - 395))
  let d = NSAttributedString(string: it.2, attributes: [.font: NSFont.systemFont(ofSize: 15), .foregroundColor: NSColor.darkGray])
  d.draw(at: NSPoint(x: x + 30, y: top - 420))
}
img.unlockFocus()
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[2]))
