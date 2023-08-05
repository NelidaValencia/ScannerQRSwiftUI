//
//  PageIntro.swift
//  ScannerQRSwiftUI
//
//  Created by Slacker on 14/04/23.
//

import Foundation
import SwiftUI

struct PageIntro : Identifiable, Hashable {
    var id: UUID = .init()
    var introAssetImage: String
    var title : String
    var subTitle: String
    var displaysAction: Bool = false
}

var pageIntros: [PageIntro] = [
    .init(introAssetImage: "Page1", title: "Lorem ipsum dolor sit amet", subTitle: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium"),
    .init(introAssetImage: "Page2", title: "On the other hand, we denounce ", subTitle: "And dislike men who are so beguiled and demoralized by the charms of pleasure of the moment"),
    .init(introAssetImage: "Page3", title: "The wise man therefore always holds", subTitle: "He rejects pleasures to secure other greater pleasures, or else he endures pains to avoid worse pains.", displaysAction: true)
    
]
