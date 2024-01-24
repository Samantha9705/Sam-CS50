import SwiftUI

struct Line {
    var points: [Point]
    var color: Color
    var width: Float
}

struct Point {
    let currentPoint: CGPoint
    let lastPoint: CGPoint
}
struct ContentView: View {
    @State var lines: [Line] = []
    @State var points: [Point] = []
    @State var currentLine: Int = 0
    @State var currentLineColor: Color = .black
    @State var currentLineWidth: Float = 1.0

    var body: some View {
        VStack {
            Form {
                ColorPicker("Color", selection: $currentLineColor)
                Slider(value: $currentLineWidth, in: 1...4, step: 1)
            }
            .frame(height: 120)
            Canvas { context, size in
                createNewPath(context: context, lines: lines)
            }
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        let point = value.location
                        let lastPoint = points.isEmpty ? point : points.last!.currentPoint
                        let currentLinePoints = Point(currentPoint: point, lastPoint: lastPoint)
                        points.append(currentLinePoints)

                        if lines.isEmpty {
                            let line = Line(points: [currentLinePoints],
                                            color: currentLineColor,
                                            width: currentLineWidth)
                            lines.append(line)
                        } else {
                            var line: Line?

                            if currentLine >= lines.count {
                                line = Line(points: [currentLinePoints],
                                            color: currentLineColor,
                                            width: currentLineWidth)
                                lines.append(line!)
                            } else {
                                line = lines[currentLine]
                                line?.points = points
                                line?.color = currentLineColor
                            }

                            lines[currentLine] = line!
                        }
                    })
                    .onEnded({ value in
                        currentLine += 1
                        points.removeAll()
                    })
            )
            .background(.white)
        }
    }

    private func createNewPath(context: GraphicsContext,
                               lines: [Line]) {

        guard !lines.isEmpty else { return }

        for line in lines {
            var newPath = Path()
            for point in line.points {
                newPath.move(to: point.lastPoint)
                newPath.addLine(to: point.currentPoint)
            }
            context.stroke(newPath, with: .color(line.color), lineWidth: CGFloat(line.width))
        }
    }
}
