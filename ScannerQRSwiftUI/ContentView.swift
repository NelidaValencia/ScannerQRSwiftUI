//
//  ContentView.swift
//  ScannerQRSwiftUI
//
//  Created by Slacker on 10/04/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
//        ScannerView()
        AnimationHome()
            .preferredColorScheme(.light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
