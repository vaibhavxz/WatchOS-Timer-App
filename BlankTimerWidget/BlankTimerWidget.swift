//
//  BlankTimerWidget.swift
//  BlankTimerWidget
//
//  Created by Vaibhav on 22/07/24.
//

import SwiftUI
import WidgetKit

struct TimerWidget: Widget {
    let kind: String = "TimerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimerProvider()) { entry in
            TimerWidgetView(entry: entry)
        }
        .configurationDisplayName("Timer Widget")
        .description("Shows your current timer")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct TimerProvider: TimelineProvider {
    func placeholder(in context: Context) -> TimerEntry {
        TimerEntry(date: Date(), timeRemaining: 60, isPaused: false)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TimerEntry) -> ()) {
        let entry = TimerEntry(date: Date(), timeRemaining: 60, isPaused: false)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TimerEntry>) -> ()) {
        var entries: [TimerEntry] = []
        let currentDate = Date()
        
        for secondOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .second, value: secondOffset, to: currentDate)!
            let timeRemaining = max(0, 60 - Double(secondOffset))
            let entry = TimerEntry(date: entryDate, timeRemaining: timeRemaining, isPaused: false)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct TimerEntry: TimelineEntry {
    let date: Date
    let timeRemaining: TimeInterval
    let isPaused: Bool
}

struct TimerWidgetView: View {
    var entry: TimerProvider.Entry
    
    var body: some View {
        HStack {
            Text(timeString(time: entry.timeRemaining))
                .font(.system(size: 16, weight: .bold, design: .rounded))
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.green.opacity(0.4), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                
                Circle()
                    .trim(from: 0, to: CGFloat(entry.timeRemaining / 60))
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: entry.isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            }
            .frame(width: 30, height: 30)
        }
        .padding()
    }
    
    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

@main
struct TimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        TimerWidget()
    }
}
