//
//  TimerView.swift
//  BlankTimer Watch App
//
//  Created by Vaibhav on 22/07/24.
//

import SwiftUI
import WatchKit
import WidgetKit

struct TimerView: View {
    let hours: Int
    let minutes: Int
    let seconds: Int
    
    @State private var timeRemaining: TimeInterval
    @State private var progress: CGFloat = 1.0
    @State private var circleColor: Color = .green
    @State private var isPaused: Bool = false
    @State private var isCompleted: Bool = false
    @State private var isTimerCancelled: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.presentationMode) var presentationMode
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(hours: Int, minutes: Int, seconds: Int) {
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
        _timeRemaining = State(initialValue: TimeInterval(hours * 3600 + minutes * 60 + seconds))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(circleColor.opacity(0.4), style: StrokeStyle(lineWidth: 15, lineCap: .round))
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(circleColor, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)
                
                VStack {
                    if timeRemaining > 0 {
                        Text(timeString(time: timeRemaining))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                    } else {
                        Text(isTimerCancelled ? "Cancelled" : "Done")
                            .font(.system(size: isTimerCancelled ? 16 : 24, weight: .bold, design: .rounded))
                            .foregroundColor(isTimerCancelled ? .red : .blue)
                    }
                    Text("\(String(format: "%02d", hours)):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))")
                        .font(.system(size: 10, weight: .light, design: .rounded))
                }
            }
            .frame(width: min(geometry.size.width, geometry.size.height) * 0.8, height: min(geometry.size.width, geometry.size.height) * 0.8)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .onReceive(timer) { _ in
            updateTimer()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                updateTimerFromStoredEndTime()
            }
        }
        .onAppear {
            storeEndTime()
        }
        
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button { addNew() } label: {
                    Label("New timer", systemImage: "plus")
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Button { cancel() } label: {
                    Label("Cancel timer", systemImage: "xmark").foregroundColor(.red).opacity(0.5)
                }
                Button { pauseTimer() } label: {
                    Label(isPaused ? "Play timer" : isCompleted ? "Re-run timer" : "Pause timer", systemImage: isPaused ? "play.fill" : isCompleted ? "arrow.clockwise" : "pause.fill")
                }
                .background(Color.orange)
                .clipShape(.circle)
            }
        }
    }
    
    func addNew() {
        presentationMode.wrappedValue.dismiss()
    }
    
    func cancel() {
        timeRemaining = 0
        circleColor = .red.opacity(0.5)
        progress = 1.0
        isCompleted = true
        isTimerCancelled = true
        UserDefaults.standard.removeObject(forKey: "timerEndTime")
    }
    
    func pauseTimer() {
        if isCompleted {
            timeRemaining = TimeInterval(hours * 3600 + minutes * 60 + seconds)
            circleColor = .green
            isCompleted = false
            isPaused = false
            isTimerCancelled = false
            storeEndTime()
        } else {
            isPaused.toggle()
            if isPaused {
                UserDefaults.standard.removeObject(forKey: "timerEndTime")
            } else {
                storeEndTime()
            }
        }
    }
    
    func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func updateProgress() {
        let totalTime = TimeInterval(hours * 3600 + minutes * 60 + seconds)
        progress = CGFloat(timeRemaining / totalTime)
        
        if progress <= 0.75 && progress > 0.5 {
            circleColor = .green
        } else if progress <= 0.5 && progress > 0.25 {
            circleColor = .orange
        } else if progress <= 0.25 && progress > 0 {
            circleColor = .red.opacity(0.5)
        } else if progress <= 0 {
            circleColor = .blue
        }
    }
    
    func updateTimer() {
        if !isPaused && timeRemaining > 0 {
            timeRemaining -= 1
            updateProgress()
        }
        if timeRemaining <= 0 {
            isCompleted = true
            UserDefaults.standard.removeObject(forKey: "timerEndTime")
        }
    }
    
    func storeEndTime() {
        let endTime = Date().addingTimeInterval(timeRemaining)
        UserDefaults.standard.set(endTime.timeIntervalSince1970, forKey: "timerEndTime")
    }
    
    func updateTimerFromStoredEndTime() {
        if let storedEndTime = UserDefaults.standard.object(forKey: "timerEndTime") as? TimeInterval {
            let endTime = Date(timeIntervalSince1970: storedEndTime)
            timeRemaining = max(0, endTime.timeIntervalSinceNow)
            updateProgress()
            if timeRemaining <= 0 {
                isCompleted = true
                UserDefaults.standard.removeObject(forKey: "timerEndTime")
            }
        }
    }
}
