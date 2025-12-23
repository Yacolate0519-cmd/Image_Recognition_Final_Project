//
//  SegmentationResultView.swift
//  HerbScholar_Test
//
//  Created by Yacolate on 2025/12/21.
//

import SwiftUI

struct SegmentationResultView: View {
    
    let resultImage: UIImage
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                Image(uiImage: resultImage)
                    .resizable()
                    .scaledToFit()
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
        }
//        GeometryReader { geo in
//            ZStack {
//                Color.black
//                    .ignoresSafeArea()
//                
//                Image(uiImage: resultImage)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: geo.size.height * 2, height: geo.size.width * 2)
////                    .rotationEffect(.degrees(-270))
//                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
//            }
//        }
//        .ignoresSafeArea()
    }
}
