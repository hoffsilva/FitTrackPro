//
//  ContentView.swift
//  FitTrackPro
//
//  Created by Hoff Henry Pereira da Silva on 2025-07-13.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            GifImageView(url: "https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExYzA0c2M1YmF2aXJveTh4NzNienRxbGlicDZpMnJwbW9ncnMydjdnMSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/7kn27lnYSAE9O/giphy.gif")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
