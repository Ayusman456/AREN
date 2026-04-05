//
//  SplashView.swift
//  AREN
//
//  Created by Ayusman sahu on 05/04/26.
//
import SwiftUI

struct SplashView: View {
    private let letters: [String] = ["A", "R", "Ē", "N"]
    @State private var visibleCount = 0

    var body: some View {
        ZStack {
            ArenColor.Surface.primary
                .ignoresSafeArea()

            HStack(spacing: 2) {
                ForEach(Array(letters.enumerated()), id: \.offset) { index, letter in
                    Text(letter)
                        .font(.custom("HelveticaNowText-Light", size: 36))
                        .foregroundStyle(ArenColor.Text.primary)
                        .opacity(index < visibleCount ? 1 : 0)
                }
            }
        }
        .onAppear {
            animateLetters()
        }
    }

    private func animateLetters() {
        for i in 0..<letters.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation(.easeOut(duration: 0.2)) {
                    visibleCount = i + 1
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
