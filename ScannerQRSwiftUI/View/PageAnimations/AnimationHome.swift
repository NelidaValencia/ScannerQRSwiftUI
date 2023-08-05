//
//  AnimationHome.swift
//  ScannerQRSwiftUI
//
//  Created by Slacker on 25/04/23.
//

import SwiftUI

struct AnimationHome: View {
    @State private var activeIntro : PageIntro = pageIntros[0]
    @State private var emailID : String = ""
    @State private var password : String = ""
    @State private var keyboardHeight : CGFloat = 0
    var body: some View {
        GeometryReader {
            let size = $0.size
            IntroView(intro: $activeIntro, size: size){
                // Login/Register
                VStack(spacing: 10) {
                    // Custom TextField
                    CustomTextField(text: $emailID, hint: "Email Address", leadingIcon: Image(systemName: "envelope"))
                    CustomTextField(text: $password, hint: "Password", leadingIcon: Image(systemName: "lock"), isPassword: true)
                    Spacer(minLength: 10)
                    Button{
                        
                    } label: {
                        Text("Continue")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .background{
                                Capsule()
                                    .fill(.black)
                            }
                    }
                    

                }
            }
        }
        .padding(15)
       
        // Manual Keyboard Push
        .offset(y: -keyboardHeight)
        // Disable Native Keyboard push
        .ignoresSafeArea(.keyboard, edges: .all)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { output in
            if let info = output.userInfo, let height = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height{
                keyboardHeight = height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: keyboardHeight)
    }
}

struct AnimationHome_Previews: PreviewProvider {
    static var previews: some View {
//        AnimationHome()
        ContentView()
    }
}

struct IntroView <ActionView:View>: View {
    @Binding var intro : PageIntro
    var size : CGSize
    var actionView: ActionView
    
    init(intro: Binding<PageIntro>, size: CGSize, @ViewBuilder actionView: @escaping () -> ActionView) {
        self._intro = intro
        self.size = size
        self.actionView = actionView()
    }
    
    // Animation Properties
    @State private var showView : Bool = false
    @State private var hideWholeView : Bool = false
    
    var body: some View{
        VStack{
            //Image View
            GeometryReader{
                let size = $0.size
                Image(intro.introAssetImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(15)
                    .frame(width: size.width, height: size.height)
            }
            // Animation Moving up
            .offset(y: showView ? 0 : -size.height / 2)
            .opacity(showView ? 1 : 0)
            
            VStack(alignment: .leading, spacing: 10){
                Spacer(minLength: 0)
                Text(intro.title)
                    .font(.system(size: 40))
                    .fontWeight(.black)
                Text(intro.subTitle)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 15)
                
                if !intro.displaysAction{
                    Group{
                        Spacer(minLength: 25)
                        CustomIndicatorView(totalPages: pageIntros.count, currentPages: pageIntros.firstIndex(of: intro) ?? 0)
                            .frame(maxWidth: .infinity)
                        Spacer(minLength: 10)
                        Button {
                            changeIntro()
                        } label: {
                            Text("Next")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: size.width * 0.4)
                                .padding(.vertical, 15)
                                .background{
                                    Capsule()
                                        .fill(.black)
                                }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }else{
                    actionView
                        .offset(y: showView ? 0 : size.height / 2)
                        .opacity(showView ? 1 : 0)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Animations Moving down
            .offset(y: showView ? 0 : size.height / 2)
            .opacity(showView ? 1 : 0)
        }
        
        .offset(y: hideWholeView ? size.height / 2 : 0)
        .opacity(hideWholeView ? 0 : 1)
        
        //Back Button
        .overlay(alignment: .topLeading) {
            if intro != pageIntros.first {
                Button {
                    changeIntro(true)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .containerShape(Rectangle())
                }
                .padding(10)
                
                /// Animating back button Comes from top when active
                .offset(y: showView ? 0 : -200)
                .offset(y: hideWholeView ? -200 : 0)
            }
        }
        .onAppear{
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(0.1)){
                showView = true
            }
        }
    }
    
    
    
    func changeIntro(_ isPrevious: Bool = false) {
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)){
            hideWholeView = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            /***
                Si el indice actual no es igual al ultimo indice de matriz, significa que todavia hay paginas disponibles
                para iterar y por lo tanto lo estamos iterando haciendo (indice +1) De lo contrario es el ultimo indice
                y no hay mas paginas disponibles para iterar, por lo que estamos configurando el indice como la ultima pagina en la parte else.
             ***/
            if let index = pageIntros.firstIndex(of: intro), (isPrevious ? index != 0 : index != pageIntros.count - 1) {
                intro = isPrevious ? pageIntros[index - 1] : pageIntros[index + 1]
            }else{
                intro = isPrevious ? pageIntros[0] : pageIntros[pageIntros.count - 1]
            }
            
            //Reanimating as SplitPage
            hideWholeView = false
            showView = false
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)){
                showView = true
            }
        }
        
    }
    
    var filteredPages : [PageIntro]{
        return pageIntros.filter { !$0.displaysAction }
    }
}
