//
//  Untitled.swift
//  AREN
//
//  Created by Ayusman sahu on 11/04/26.
//

// DebugBorder.swift

import SwiftUI

enum ArenDebug {
    static var isDebug = false
}

extension View {
    @ViewBuilder
    func debugBorder(_ color: Color = .red, width: CGFloat = 1, enabled: Bool = ArenDebug.isDebug) -> some View {
#if DEBUG
        self.border(enabled ? color : .clear, width: width)
#else
        self
#endif
    }
}
