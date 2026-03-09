//
//  UmiApp.swift
//  UmiApp
//
//  Aplicación educativa accesible para niños con discapacidades
//  Centro de Atención Múltiple (CAM)
//

import SwiftUI

@main
struct UmiApp: App {
    @StateObject private var colorManager = ColorManager()
    @StateObject private var speechManager = SpeechManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(colorManager)
                .environmentObject(speechManager)
        }
    }
}
