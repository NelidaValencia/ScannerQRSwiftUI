//
//  qrSannerDelegate.swift
//  ScannerQRSwiftUI
//
//  Created by Slacker on 11/04/23.
//

import SwiftUI
import AVKit

class qrSannerDelegate: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate{
    
    @Published var scannedCode : String?
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metaObject = metadataObjects.first {
            guard let readableObject = metaObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let Code = readableObject.stringValue else { return }
            print(Code)
            scannedCode = Code
        }
    }
}
