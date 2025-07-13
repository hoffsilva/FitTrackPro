import SwiftUI
import SDWebImageSwiftUI

struct GifImageView: View {
    let url: String?
    let width: CGFloat?
    let height: CGFloat?
    let cornerRadius: CGFloat
    
    init(
        url: String?,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        cornerRadius: CGFloat = 8
    ) {
        self.url = url
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Group {
            if let url = url, let gifURL = URL(string: url) {
                AnimatedImage(url: gifURL)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .font(.title2)
                    )
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview {
    VStack(spacing: 20) {
        GifImageView(
            url:"https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExYzA0c2M1YmF2aXJveTh4NzNienRxbGlicDZpMnJwbW9ncnMydjdnMSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/7kn27lnYSAE9O/giphy.gif",
            width: 200,
            height: 200
        )
        
        GifImageView(
            url: nil,
            width: 150,
            height: 150,
            cornerRadius: 12
        )
    }
    .padding()
}
