//
//  CustomIndicatorView.swift
//  ScannerQRSwiftUI
//
//  Created by Slacker on 25/04/23.
//

import SwiftUI

struct CustomIndicatorView: View {
    var totalPages: Int
    var currentPages: Int
    var activeTint: Color = .black
    var inActiveTint: Color = .gray.opacity(0.5)
    
    var body: some View {
        HStack(spacing: 8){
            ForEach(0..<totalPages, id: \.self){
                Circle()
                    .fill(currentPages == $0 ? activeTint : inActiveTint)
                    .frame(width: 4, height: 4)
            }
        }
    }
}

struct CustomIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
