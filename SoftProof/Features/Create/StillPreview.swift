import SwiftUI
import UIKit

struct StillPreview: View {
    let image: UIImage
    var caption: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: AppMetrics.tightSpacing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: AppMetrics.cardRadius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: AppMetrics.cardRadius, style: .continuous)
                        .stroke(AppTheme.hairline, lineWidth: AppMetrics.hairlineWidth)
                }
                .frame(maxWidth: .infinity)
                .frame(maxHeight: AppMetrics.readoutPadding * 14)
                .accessibilityLabel(caption.isEmpty ? "Still preview" : caption)

            if !caption.isEmpty {
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }
}

#Preview {
    ScreenScaffold {
        StillPreview(image: StillFiles.placeholder, caption: "Placeholder still")
    }
}
