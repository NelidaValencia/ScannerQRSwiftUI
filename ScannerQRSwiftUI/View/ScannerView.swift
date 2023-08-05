//
//  ScannerView.swift
//  ScannerQRSwiftUI
//
//  Created by Slacker on 10/04/23.
//

import SwiftUI
import AVKit

struct ScannerView: View {
    @State private var isScanning: Bool = false
    @State private var session : AVCaptureSession = .init()
    @State private var cameraPermission : Permission = .idle
    @State private var qrOutput: AVCaptureMetadataOutput = .init()
    @State private var errorMessage : String = ""
    @State private var showError : Bool = false
    @Environment(\.openURL) private var openURL
    @StateObject private var qrDelegate = qrSannerDelegate()
    @State  private var scannedCode : String = ""
    @State private var text: String = ""
    var body: some View {
        VStack(spacing: 8) {
            Button{
                
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(Color(.blue))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text("Place the QR code inside the area")
                .font(.title3)
                .foregroundColor(.black.opacity(0.8))
                .padding(.top, 20)
            Text("Scanning will start automatically")
                .font(.callout)
                .foregroundColor(.gray)
            Text(text)
                .font(.title3).bold()
                .foregroundColor(.red)
            Spacer(minLength: 0)
            
            ///scanner
        
            GeometryReader{
                let size = $0.size
                ZStack{
                    CameraView(frameSize: CGSize(width: size.width, height: size.width), session: $session)
                        .scaleEffect(0.97)
                    
                    ForEach (0...4, id: \.self){ index in
                        let rotation = Double(index) * 90
                        
                        RoundedRectangle(cornerRadius: 2, style: .circular)
                            .trim(from: 0.61, to: 0.64)
                            .stroke(Color(.blue), style: StrokeStyle(lineWidth: 5 , lineCap: .round, lineJoin: .round))
                            .rotationEffect(.init(degrees: rotation))
                    }
                    
                }
                .frame(width: size.width, height: size.width)
                .overlay(alignment: .top, content: {
                    Rectangle()
                        .fill(Color(.blue))
                        .frame(height: 2.5)
                        .shadow(color: .black.opacity(0.8), radius: 8, x: 0, y: isScanning ? 15 : -15)
                        .offset(y: isScanning ? size.width : 0)
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal, 45)
            
            Spacer(minLength: 15)
            Button {
                if !session.isRunning && cameraPermission == .approved{
                    reactivateCamera()
                    activateScannerAnimation()
                    self.text = ""
                }
            } label: {
                Image(systemName: "qrcode.viewfinder")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                
            }
            Spacer(minLength: 45)
        }
        .padding(15)
        .onAppear(perform: checkCameraPermissions)
        .alert(errorMessage, isPresented: $showError) {
            if cameraPermission == .denied{
                Button("Settings") {
                    let settingsStrings = UIApplication.openSettingsURLString
                    if let settingsURL = URL(string: settingsStrings) {
                        openURL(settingsURL)
                    }
                }
                Button("Cancel", role: .cancel) {
                }
            }
        }
        .onChange(of: qrDelegate.scannedCode) { newValue in
            if let code = newValue {
                scannedCode = code
                self.text = scannedCode
                session.stopRunning()
                desactivateScannerAnimation()
                qrDelegate.scannedCode = nil
            }
        }
    }
    
    func reactivateCamera() {
        DispatchQueue.global(qos: .background).async {
            session.startRunning()
        }
    }
    
    func activateScannerAnimation() {
        withAnimation(.easeInOut(duration: 0.85).delay(0.1).repeatForever(autoreverses: true)){
            isScanning = true
        }
    }
    
    func desactivateScannerAnimation() {
        withAnimation(.easeInOut(duration: 0.85)){
            isScanning = false
        }
    }
    
    func checkCameraPermissions() {
        Task{
            switch AVCaptureDevice.authorizationStatus(for: .video){
            case .authorized:
                cameraPermission = .approved
                if session.inputs.isEmpty{
                    setUpCamera()
                }else{
                    session.startRunning()
                }
                
            case .notDetermined:
                if await AVCaptureDevice.requestAccess(for: .video) {
                    cameraPermission = .approved
                    setUpCamera()
                }else{
                    cameraPermission = .denied
                    presentError("Please provide access to camera for scanning codes")
                }
                
            case .denied, .restricted:
                cameraPermission = .denied
                presentError("Please provide access to camera for scanning codes")
            default: break
            }
        }
    }
    
    func setUpCamera() {
        do{
            guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first else {
                presentError("UNOWNED DEVICE ERROR")
                return
            }
            let input = try AVCaptureDeviceInput(device: device)
            guard session.canAddInput(input), session.canAddOutput(qrOutput) else {
                presentError("UNOWNED INPUT/OUTPUT ERROR")
                return
            }
            session.beginConfiguration()
            session.addInput(input)
            session.addOutput(qrOutput)
            qrOutput.metadataObjectTypes = [.qr]
            qrOutput.setMetadataObjectsDelegate(qrDelegate, queue: .main)
            session.commitConfiguration()
            DispatchQueue.global(qos: .background).async {
                session.startRunning()
            }
            activateScannerAnimation()
        }catch{
            presentError(error.localizedDescription)
        }
    }
    
    func presentError(_ message: String) {
        errorMessage = message
        showError.toggle()
        
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView()
    }
}
