import Foundation

struct DrawingLesson: Identifiable, Hashable, Decodable {
    let id: Int
    let title: String
    let subtitle: String
    let minutes: Int
    let idea: String
    let observation: String
    let steps: [String]
    let check: String
    let transfer: String

    var chapter: Int { id <= 20 ? (id - 1) / 5 : 4 + (id - 21) / 10 }
    static let chapters = ["The language of line", "Learning to see", "Giving things form", "Making it your own", "Botanical sketchbook", "The quiet still life", "Forms from nature", "Landscape & atmosphere", "Spaces & perspective", "People & expression", "Animals in motion", "Your artist’s voice"]
    var reference: StudyReference { StudyReference.forLesson(id) }
    var level: String { id <= 20 ? "Foundation" : id <= 60 ? "Developing" : "Exploring" }
    static var count: Int { all.count }
    static let chapterNotes = ["Confidence, rhythm, contour", "Shape, space, proportion", "Value, light, volume", "Gesture, composition, memory", "Growth, petals, natural rhythms", "Objects, surfaces, shared light", "Spirals, planes, tactile marks", "Distance, weather, open space", "Depth, architecture, interiors", "Portraits, hands, observation", "Structure, balance, character", "Design, storytelling, personal studies"]
    var chapterTitle: String { Self.chapters[chapter] }
    var number: String { String(format: "%02d", id) }

    static let foundations: [DrawingLesson] = [
        .init(id: 1, title: "A line with intention", subtitle: "Let your eye lead your hand.", minutes: 5,
              idea: "A useful line begins before the pencil touches the page. Choose a starting point and an ending point, rehearse the movement above the surface, then make one unhurried stroke. A slightly uneven line can still be confident.",
              observation: "The dots in the study are destinations. Notice how each line travels between them without a cluster of little corrections. Confidence comes from committing to a direction, not from drawing perfectly straight.",
              steps: ["Connect each pair of dots with one stroke. Move from your arm as well as your fingers.", "Switch to Faint and repeat beside the first lines. Try a different direction each time.", "Choose Freehand. Draw five new pairs of dots and connect them without tracing."],
              check: "Can I see a clear beginning and end in each stroke?", transfer: "Draw the long edges of a book in front of you, using one stroke for each edge."),
        .init(id: 2, title: "Curves that breathe", subtitle: "Build rhythm with C and S curves.", minutes: 6,
              idea: "Curves carry movement. A C curve bends in one direction; an S curve changes direction around an inflection point. Think about the whole gesture rather than slowly assembling a curve from short pieces.",
              observation: "Follow the outer sweep of the examples. The widest bend sits away from the endpoints. In the S curve, the change of direction is gradual rather than a sharp corner.",
              steps: ["Trace the three curves once, following their full movement.", "With a faint guide, draw a second curve just inside each original.", "Hide the guide and invent a leaf, a ribbon, and a wave using only C and S curves."],
              check: "Do my curves change direction smoothly?", transfer: "Find three curves in a houseplant and draw their movement without the small details."),
        .init(id: 3, title: "The ellipse warm-up", subtitle: "Give circles a sense of space.", minutes: 6,
              idea: "An ellipse describes a circle seen at an angle. Its two halves mirror around a long axis and a short axis. As a circular opening tilts away from you, it appears flatter, but the ends remain rounded.",
              observation: "The center lines divide each ellipse into balanced halves. Compare the narrow opening with the rounder one. Avoid turning the ends into points: an ellipse is not an almond shape.",
              steps: ["Rehearse each oval in the air, then draw around it in one movement.", "Use Faint and add the long and short axes before drawing each ellipse.", "Without a guide, draw five ellipses from nearly flat to nearly circular."],
              check: "Are both ends rounded and both halves balanced?", transfer: "Look down into a cup, then lower your eye level and sketch how its opening changes."),
        .init(id: 4, title: "Weight tells a story", subtitle: "Make some edges speak louder.", minutes: 7,
              idea: "Line weight creates hierarchy. A heavier edge can suggest overlap, a shadow, or a focal point. Lighter marks can describe a lit edge or an early construction. Weight works best when it has a reason.",
              observation: "The overlapping shapes use stronger lines where one form passes in front of another. The light construction lines remain visible, but they do not compete with the main edges.",
              steps: ["Draw all three forms lightly with the pencil tool.", "Choose Ink and strengthen only the edges that overlap another form.", "Hide the guide and draw three new overlapping objects. Leave the distant edges light."],
              check: "Can I tell which form is in front without adding shading?", transfer: "Sketch a folded cloth and strengthen just the edges where one fold covers another."),
        .init(id: 5, title: "One continuous contour", subtitle: "Slow down and follow an edge.", minutes: 8,
              idea: "Contour drawing trains attention. Your eye follows an object's boundary while your hand records the journey. Resist naming the parts: look instead for changes in direction, tight bends, and long stretches.",
              observation: "The leaf's outline changes pace: it widens, narrows, and returns to the stem. The central vein is a separate decision. A contour can describe an object with very few marks.",
              steps: ["Follow the leaf outline slowly without lifting your pencil.", "Repeat with a faint guide, paying attention to where the edge changes direction.", "Hide the guide and draw a nearby leaf or spoon in one continuous line."],
              check: "Did I follow what I saw rather than a symbol for the object?", transfer: "Spend two minutes drawing your free hand while looking mostly at the hand."),
        .init(id: 6, title: "Big shapes first", subtitle: "Find the simple structure beneath detail.", minutes: 8,
              idea: "Complex subjects become manageable when you begin with large shapes. An envelope is a simple outer boundary that contains the subject. Place that boundary before describing any small indentation or feature.",
              observation: "The pear fits inside a broad envelope. Its upper mass is smaller than its lower mass. Those relationships make it recognizable before you add the stem or refine the contour.",
              steps: ["Sketch the angular outer envelope with light strokes.", "Place the two main masses inside it, then connect their edges.", "Hide the guide and draw a different piece of fruit, beginning with its envelope."],
              check: "Does the large shape read before I add details?", transfer: "Reduce a shoe to three large shapes before drawing any laces."),
        .init(id: 7, title: "Drawing the spaces", subtitle: "Look at what surrounds the subject.", minutes: 8,
              idea: "Negative space is the shape around or between objects. Drawing a gap can be easier than drawing a familiar object, because you have fewer assumptions about what that gap should look like.",
              observation: "Study the opening inside the handle and the space beside the cup. These spaces have their own proportions. If the opening is too wide, the handle will feel wrong even when its outer edge is smooth.",
              steps: ["Draw the empty opening in the handle before drawing the cup.", "Add the outside edges, keeping the opening intact.", "With Freehand selected, draw the gaps between two fingers of your free hand."],
              check: "Do the empty shapes have the right width and height?", transfer: "Sketch a chair by drawing the spaces between its legs first."),
        .init(id: 8, title: "Measure relationships", subtitle: "Compare sizes instead of guessing.", minutes: 9,
              idea: "Proportion is a relationship, not an isolated measurement. Choose one length as a unit and compare everything else with it. Ask how many widths fit into a height, and where important landmarks fall.",
              observation: "The bottle is divided into quarters. Its shoulder, neck, and base can be located by comparing them with the whole height. The horizontal marks help you check both sides together.",
              steps: ["Draw a center line and mark the top and bottom.", "Divide the height into four equal parts and place the neck and shoulders.", "Hide the guide and draw a real bottle, checking width against height."],
              check: "Can I describe my object's height in units of its width?", transfer: "Compare a mug and a bottle side by side using the mug's height as one unit."),
        .init(id: 9, title: "Angles before outlines", subtitle: "Block in a subject with straight lines.", minutes: 8,
              idea: "A block-in uses a small number of straight segments to describe a complex silhouette. Straight segments make slopes easier to compare. Curves can come later, after the overall direction is convincing.",
              observation: "The mountain contour can be reduced to a few slopes. Check each segment against an imaginary horizontal. A small angle error can shift the highest point much farther than you expect.",
              steps: ["Draw the angular mountain outline with five or six strokes.", "Check where each peak sits relative to the valley beside it.", "Hide the guide and block in the silhouette of a crumpled cloth using straight lines."],
              check: "Have I compared the steepness of neighboring slopes?", transfer: "Block in the outside shape of a plant without drawing individual leaves."),
        .init(id: 10, title: "A grid you can leave behind", subtitle: "Use structure, then trust your eye.", minutes: 10,
              idea: "A grid breaks a large problem into smaller comparisons. Look for where a contour crosses a cell edge. The purpose is to train observation, so eventually reduce the help and redraw without it.",
              observation: "The leaf crosses several cells. Notice its widest point and where the stem meets a grid line. Compare crossings rather than copying each square as an isolated picture.",
              steps: ["Copy the leaf by locating its intersections with the grid.", "Choose Faint and connect those landmarks with a continuous contour.", "Choose Freehand and redraw the leaf beside your first study from memory."],
              check: "Does my second drawing keep the same large proportions?", transfer: "In the reference studio, use the grid on your own photo, then try the subject again on paper without it."),
        .init(id: 11, title: "Five steps of value", subtitle: "Describe light before adding color.", minutes: 8,
              idea: "Value means how light or dark something appears. A small set of clearly separated values can describe a subject more effectively than many uncertain shades. Keep your lightest paper area available for the brightest light.",
              observation: "The five squares progress from paper white to dark ink. The middle steps should remain distinguishable. The challenge is separation, not a perfectly smooth transition.",
              steps: ["Leave the first square empty and fill the last with dense hatching.", "Build three middle values by varying the spacing and layering of strokes.", "Hide the guide and create another five-step scale without looking at the first."],
              check: "Can I distinguish every neighboring pair when I squint?", transfer: "Choose three values to describe a white object beside a window."),
        .init(id: 12, title: "Light around a sphere", subtitle: "Turn a flat circle into a solid form.", minutes: 10,
              idea: "A sphere turns gradually away from a light source. Separate the light family from the shadow family first, then add intermediate values. The cast shadow rests on the surface beneath the object and helps locate it in space.",
              observation: "Light comes from the upper left. The lower right of the sphere belongs to shadow, and the cast shadow extends rightward. Preserve a light area rather than outlining a bright highlight.",
              steps: ["Draw the circular silhouette lightly and mark the direction of light.", "Build the shadow side with curved hatching; keep the lit side open.", "Hide the guide and draw another sphere lit from the opposite direction."],
              check: "Do the sphere's shading and cast shadow agree on the light direction?", transfer: "Place an egg near one lamp and identify the light and shadow families before drawing."),
        .init(id: 13, title: "Hatching follows form", subtitle: "Make every mark describe a surface.", minutes: 9,
              idea: "Hatching builds tone from repeated lines. Crosshatching adds another direction. Marks that curve around a form can describe its volume as well as its darkness. Begin lightly so additional layers remain a choice.",
              observation: "The three patches show parallel, crossed, and curved marks. Darker tone comes from closer spacing and additional layers. Curved marks suggest a rounded surface rather than a flat patch.",
              steps: ["Fill the first patch with evenly spaced parallel lines.", "Add a second direction to the next patch, leaving small gaps of paper.", "Use curved hatching to describe a cylinder without filling it with a solid color."],
              check: "Are my marks describing the surface as well as its value?", transfer: "Draw a folded towel using one hatch direction per plane."),
        .init(id: 14, title: "A room in perspective", subtitle: "Let parallel edges meet at a distance.", minutes: 12,
              idea: "In one-point perspective, edges that travel straight away from you converge toward one vanishing point on the horizon. Vertical edges remain vertical and edges parallel to the picture plane remain horizontal in this simple setup.",
              observation: "The room's floor and ceiling edges aim toward the same point. The rectangle at the back is smaller, but its corners sit on the converging lines. The horizon represents the viewer's eye level.",
              steps: ["Place the vanishing point and draw a horizontal horizon through it.", "Connect the room's outer corners to the vanishing point, then draw the back wall.", "Hide the guide and invent a room with a window aligned to the same point."],
              check: "Do all edges moving away from me aim toward the same point?", transfer: "Look along a hallway and sketch where its ceiling and floor edges appear to meet."),
        .init(id: 15, title: "Build a cylinder", subtitle: "Connect ellipses into a believable object.", minutes: 10,
              idea: "A cylinder combines two circular ends and a continuous side. The ellipses share a center axis. When you see a cylinder below eye level, its lower ellipse often appears more open than the upper one.",
              observation: "The side edges meet the ellipses smoothly. The back half of the bottom ellipse is construction: it helps establish the form, but a finished opaque cylinder would hide it.",
              steps: ["Draw a center axis and place two ellipses along it.", "Join their outer edges with straight, parallel sides.", "Hide the guide and turn the cylinder into a tin, a candle, or a flowerpot."],
              check: "Do the ellipses share an axis and connect without pointed corners?", transfer: "Sketch three cylindrical objects at different heights relative to your eyes."),
        .init(id: 16, title: "A botanical study", subtitle: "Grow a complex drawing from one gesture.", minutes: 12,
              idea: "Botanical drawing begins with growth and rhythm. Establish the main stem and the direction of each leaf before its contour. Repetition becomes more convincing when sizes and angles vary naturally.",
              observation: "Leaves branch from the main stem with different tilts. Each has a central gesture and two edges. The intervals between leaves matter as much as the leaves themselves.",
              steps: ["Draw the stem's movement and short directions for each leaf.", "Build leaf contours around those directions, varying their widths.", "Hide the guide and draw a real sprig, preserving its irregular spacing."],
              check: "Does every leaf feel connected to the same growing stem?", transfer: "Make two studies of the same plant: one with only gestures and one with contours."),
        .init(id: 17, title: "Catch the gesture", subtitle: "Draw action before anatomy.", minutes: 8,
              idea: "Gesture describes movement, balance, and energy. Begin with the main sweep of the pose, then place the head, rib cage, and pelvis as simple masses. A gesture study can be informative without finished anatomy.",
              observation: "The curved action line connects the leaning head and torso to the supporting leg. The shoulder and hip tilts differ, giving the pose its rhythm. Avoid treating the limbs as isolated sticks.",
              steps: ["Draw the action line in a single sweeping stroke.", "Place the head, torso, and pelvis; connect the limbs to those masses.", "Hide the guide and invent three poses using no more than ten strokes each."],
              check: "Can I read the movement before seeing any small features?", transfer: "Draw three quick poses from your own photographs, focusing on balance rather than likeness."),
        .init(id: 18, title: "Compose with empty space", subtitle: "Decide where the viewer looks first.", minutes: 12,
              idea: "Composition is the arrangement of attention. Size, placement, overlap, and empty space can establish a focal point. Small thumbnails let you compare arrangements before committing to a larger drawing.",
              observation: "The three little frames rearrange the same circle and rectangle. Compare the quiet centered layout with the off-center version and the version with a smaller focal shape. No layout is automatically best; each creates a different emphasis.",
              steps: ["Copy the three thumbnails, keeping their frames the same size.", "Make one object dominant through scale or placement in each version.", "Hide the guide and create a fourth layout with generous empty space."],
              check: "Can I name the first place my eye lands in each composition?", transfer: "Arrange two photos in the reference studio and compare three placements before tracing."),
        .init(id: 19, title: "Trace, fade, remember", subtitle: "Use a reference as a bridge to independence.", minutes: 12,
              idea: "Tracing can make a structure easier to notice, but copying alone does not test what you remember. Use three passes: an attentive trace, a faintly guided reconstruction, and a drawing made with the guide hidden.",
              observation: "The flower uses a central disk, a ring of petals, and a curved stem. Those are the relationships to remember. You do not need to memorize every irregularity to rebuild its structure.",
              steps: ["In Guide mode, trace the flower and say its main parts to yourself.", "Switch to Faint. Reconstruct the flower beside your traced version.", "Choose Freehand and draw a third flower from memory. Reveal the guide to compare."],
              check: "Which relationship did I remember, and which would I check next time?", transfer: "Repeat the three-pass method with a reference photo you own. Change its arrangement in the final drawing."),
        .init(id: 20, title: "Your first personal study", subtitle: "Bring observation, structure, and choice together.", minutes: 15,
              idea: "A personal study combines the skills you have practiced with a choice of your own. Pick a simple subject, decide what interests you, and use only the tools that serve that intention. Finishing means making a clear decision, not adding every detail.",
              observation: "The still life combines a rounded fruit, a cylindrical cup, and a shared ground. Notice the overlap and the single light direction. You can use this arrangement or substitute objects near you.",
              steps: ["Make a tiny composition plan, then block in the large shapes lightly.", "Check negative spaces and proportions before adding three clear values.", "Hide the guide and make your own variation. Write one observation and one next step in your journal."],
              check: "Is there one clear focal point, and do my shadows share a light direction?", transfer: "Return to the same objects tomorrow and draw them again from a new viewpoint.")
    ]

    static let all: [DrawingLesson] = foundations + extendedCourse
    private static let extendedCourse: [DrawingLesson] = {
        guard let url = Bundle.main.url(forResource: "ExtendedCourse", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let lessons = try? JSONDecoder().decode([DrawingLesson].self, from: data) else {
            assertionFailure("The offline course could not be loaded")
            return []
        }
        return lessons
    }()
}

struct LessonWorkshop: Decodable {
    let lessonID: Int
    let setup: String
    let demonstration: String
    let mistakes: String
    let challenge: String
    static let all: [LessonWorkshop] = {
        guard let url = Bundle.main.url(forResource: "LessonWorkshops", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let result = try? JSONDecoder().decode([LessonWorkshop].self, from: data) else { return [] }
        return result
    }()
}

extension DrawingLesson {
    var workshop: LessonWorkshop? { LessonWorkshop.all.first { $0.lessonID == id } }
    var readingWordCount: Int {
        let extra = workshop.map { [$0.setup, $0.demonstration, $0.mistakes, $0.challenge] } ?? []
        return ([idea, observation, check, transfer] + steps + extra).joined(separator: " ").split { $0.isWhitespace }.count
    }
}
