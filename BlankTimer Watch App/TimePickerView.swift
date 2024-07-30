//
//  TimePickerView.swift
//  BlankTimer Watch App
//
//  Created by Vaibhav on 22/07/24.
//

import SwiftUI

struct TimePickerView: View {
    let label: String
    let range: ClosedRange<Int>
    @Binding var selection: Int
    
    var body: some View {
        VStack {
            Text(label)
            Picker("", selection: $selection) {
                ForEach(range, id: \.self) { value in
                    Text(String(format: "%02d", value)).tag(value)
                }
            }
        }
        .pickerStyle(WheelPickerStyle())
        .frame(width: 50, height: 100)
        .clipped()
    }
}
