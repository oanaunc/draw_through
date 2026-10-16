import AppKit

// Reproducible store artwork: real, unmodified app captures inside a graphic frame.
// Only uniformly scales captures; no controls or app content are synthesized.
let root = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : FileManager.default.currentDirectoryPath)
struct Plate { let file: String; let title: String; let subtitle: String; let tone: Int }
let plates = [
    Plate(file:"01-Learn", title:"Learn to look.\nLove to draw.", subtitle:"100 complete lessons. A new reference every time.", tone:0),
    Plate(file:"02-References", title:"A reference for\nevery idea.", subtitle:"Explore 100 unique images across 12 chapters.", tone:1),
    Plate(file:"03-Workshop", title:"Read. Notice.\nMake your mark.", subtitle:"Full workshops, clear steps, and helpful fixes.", tone:0),
    Plate(file:"04-Own-Photo", title:"Your photos.\nYour point of view.", subtitle:"Bring your own references into drawing practice.", tone:2),
    Plate(file:"05-Practice", title:"Find your line.\nThen trust it.", subtitle:"Draw with Guide, Faint, or Freehand.", tone:1),
    Plate(file:"06-Observation", title:"See light in\na new way.", subtitle:"Compare values with Monochrome and Grid.", tone:2),
    Plate(file:"07-Light-Table", title:"Build your world\nof references.", subtitle:"Arrange personal photos on a layered light table.", tone:0),
    Plate(file:"08-Adjust", title:"Make it work\nfor your drawing.", subtitle:"Fine-tune opacity, contrast, and outlines.", tone:1),
    Plate(file:"09-Journal", title:"Keep the marks.\nSee the progress.", subtitle:"Save your studies and personal reflections.", tone:2),
    Plate(file:"10-Assignment", title:"Take your art\nbeyond the screen.", subtitle:"An independent assignment in every lesson.", tone:0)
]
func color(_ r:CGFloat,_ g:CGFloat,_ b:CGFloat)->NSColor { NSColor(srgbRed:r/255,green:g/255,blue:b/255,alpha:1) }
let ink=color(37,47,43), clay=color(127,91,70)
let backgrounds=[color(245,239,227),color(221,230,216),color(219,230,232)]
func render(_ plate:Plate, device:String, index:Int) throws {
    let w:CGFloat=device=="iPhone" ? 1320:2064, h:CGFloat=device=="iPhone" ? 2868:2752
    let factor=w/1320
    let rep=NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:Int(w),pixelsHigh:Int(h),bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
    NSGraphicsContext.saveGraphicsState();NSGraphicsContext.current=NSGraphicsContext(bitmapImageRep:rep)
    backgrounds[plate.tone].setFill();NSRect(x:0,y:0,width:w,height:h).fill()
    func rect(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat)->NSRect { NSRect(x:x,y:h-y-height,width:width,height:height) }
    func text(_ value:String,_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat,_ size:CGFloat,_ serif:Bool=false,_ foreground:NSColor=ink) {
        let style=NSMutableParagraphStyle();style.lineBreakMode = .byWordWrapping;style.lineSpacing=serif ? 0:8
        let font=serif ? (NSFont(name:"Georgia-Bold",size:size) ?? NSFont.systemFont(ofSize:size,weight:.bold)) : NSFont.systemFont(ofSize:size,weight:.medium)
        (value as NSString).draw(in:rect(x,y,width,height),withAttributes:[.font:font,.foregroundColor:foreground,.paragraphStyle:style])
    }
    let margin:CGFloat=84*factor
    text("DRAW THROUGH  /  FIELD SCHOOL",margin,70*factor,w-2*margin,45*factor,25*factor,false,clay)
    clay.withAlphaComponent(0.3).setStroke();let rule=NSBezierPath();rule.move(to:NSPoint(x:margin,y:h-126*factor));rule.line(to:NSPoint(x:w-margin,y:h-126*factor));rule.lineWidth=1.5*factor;rule.stroke()
    let titleY:CGFloat=device=="iPhone" ? 170:190
    let titleSize:CGFloat=device=="iPhone" ? 104:140
    text(plate.title,margin,titleY,w-2*margin,device=="iPhone" ? 270:345,titleSize,true)
    let subY:CGFloat=device=="iPhone" ? 455:550
    text(plate.subtitle,margin,subY,w-2*margin,105*factor,36*factor,false,clay)
    let input=root.appendingPathComponent("Raw/\(device)/\(plate.file).png")
    guard let capture=NSImage(contentsOf:input) else { fatalError("Missing real capture: \(input.path)") }
    let targetW:CGFloat=device=="iPhone" ? 950:1460
    let targetH=targetW*capture.size.height/capture.size.width
    let targetY:CGFloat=device=="iPhone" ? 650:730
    let target=rect((w-targetW)/2,targetY,targetW,targetH)
    let border:CGFloat=device=="iPhone" ? 20:16
    let outer=target.insetBy(dx:-border,dy:-border)
    let shadow=NSShadow();shadow.shadowColor=ink.withAlphaComponent(0.18);shadow.shadowBlurRadius=40;shadow.shadowOffset=NSSize(width:0,height:-18)
    NSGraphicsContext.saveGraphicsState();shadow.set();ink.setFill();NSBezierPath(roundedRect:outer,xRadius:64,yRadius:64).fill();NSGraphicsContext.restoreGraphicsState()
    NSGraphicsContext.saveGraphicsState();NSBezierPath(roundedRect:target,xRadius:48,yRadius:48).addClip();capture.draw(in:target,from:.zero,operation:.sourceOver,fraction:1,respectFlipped:false,hints:[.interpolation:NSImageInterpolation.high.rawValue]);NSGraphicsContext.restoreGraphicsState()
    text(String(format:"%02d / 10",index+1),margin,h-77,w-2*margin,40,22*factor,false,clay)
    NSGraphicsContext.restoreGraphicsState()
    let folder=root.appendingPathComponent(device=="iPhone" ? "iPhone-6.9-inch":"iPad-13-inch")
    try FileManager.default.createDirectory(at:folder,withIntermediateDirectories:true)
    try rep.representation(using:.jpeg,properties:[.compressionFactor:0.95])!.write(to:folder.appendingPathComponent(plate.file+".jpg"))
}
for device in ["iPhone","iPad"] { for (index,plate) in plates.enumerated(){ try render(plate,device:device,index:index) } }
print("Rendered 10 screenshot plates for each device family")
