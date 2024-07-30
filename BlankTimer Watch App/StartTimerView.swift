//
//  ContentView.swift
//  BlankTimer Watch App
//
//  Created by Vaibhav on 21/07/24.
//

import SwiftUI
import WatchKit


struct StartTimerView: View {
    @State private var hours = 0
    @State private var minutes = 0
    @State private var seconds = 0
    @State private var isTimerViewActive = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 20) {
                    TimePickerView(label: "Hour", range: 0...9, selection: $hours)
                    TimePickerView(label: "Min", range: 0...59, selection: $minutes)
                    TimePickerView(label: "Sec", range: 0...59, selection: $seconds)
                }
                
                NavigationLink(destination: TimerView(hours: hours, minutes: minutes, seconds: seconds), isActive: $isTimerViewActive) {
                    Button("Start") {
                        isTimerViewActive = true
                    }
                    .background(.blue)
                    .clipped()
                    .clipShape(.capsule)
                }
            }
        }
    }
}
