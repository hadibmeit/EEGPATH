//
//  ContentView.swift
//  exer1.1
//
//  Created by Hadi Nosrati on 14/11/25.
//
import SwiftUI
import Charts
import UniformTypeIdentifiers

struct EEGPoint: Identifiable {
    var id = UUID()
    var t: Double
    var v: Double
}

struct ContentView: View {

    @State private var dataList: [EEGPoint] = []
    @State private var status = "No data loaded"

    var body: some View {

        ZStack {
            Image("NeuroBG")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 25) {

                Text("NEURO PATH")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)

                if dataList.isEmpty {
                    Text(status)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.top, 25)
                }

                if !dataList.isEmpty {
                    ZStack {
                        checkerBG
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                            .blur(radius: 0)

                        Chart {
                            ForEach(dataList) { p in
                                LineMark(
                                    x: .value("Time", p.t),
                                    y: .value("Value", p.v)
                                )
                                    .foregroundStyle(.cyan)
                                    .interpolationMethod(.linear)
                                    .lineStyle(.init(lineWidth: 2))
                            }
                        }
                        .chartXAxis { AxisMarks() }
                        .chartYAxis { AxisMarks(position: .leading) }
                        .padding()
                    }
                    .frame(height: 300)
                    .padding(.horizontal)
                }

                Spacer()
            }

            VStack {
                Spacer()
                HStack {
                    Button(action: { openCSV() }) {
                        HStack {
                            Image(systemName: "tray.and.arrow.down")
                            Text("Load EEG CSV")
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .background(.white.opacity(0.12))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding([.leading, .bottom], 20)

                    Spacer()
                }
            }
        }
    }

    // MARK: - Checkerboard Background
    var checkerBG: some View {
        GeometryReader { geo in
            let size: CGFloat = 26
            let cols = Int(geo.size.width / size)
            let rows = Int(geo.size.height / size)

            VStack(spacing: 0) {
                ForEach(0..<rows, id: \.self) { r in
                    HStack(spacing: 0) {
                        ForEach(0..<cols, id: \.self) { c in
                            Rectangle()
                                .fill((r + c).isMultiple(of: 2) ?
                                      Color.black.opacity(0.32) :
                                      Color.white.opacity(0.12))
                                .frame(width: size, height: size)
                        }
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Open File Panel
    func openCSV() {
        let p = NSOpenPanel()
        p.allowedContentTypes = [.commaSeparatedText]
        p.allowsMultipleSelection = false

        if p.runModal() == .OK, let url = p.url {
            loadCSV(url)
        }
    }

    // MARK: - Load CSV
    func loadCSV(_ url: URL) {
        dataList.removeAll()

        guard let txt = try? String(contentsOf: url) else {
            status = "Could not read file"
            return
        }

        let rows = txt.components(separatedBy: .newlines)

        for r in rows {
            let c = r.split(separator: ",")
            if c.count >= 2,
               let t = Double(c[0]),
               let v = Double(c[1]) {
                dataList.append(EEGPoint(t: t, v: v))
            }
        }

        status = dataList.isEmpty ? "No valid data found" : "EEG Loaded"
    }
}

#Preview {
    ContentView()
}
