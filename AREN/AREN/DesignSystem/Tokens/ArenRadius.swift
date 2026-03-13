import SwiftUI

private enum ArenRadiusScale {
    static let rNone: CGFloat = 0
    static let rXS: CGFloat = 2
    static let rSM: CGFloat = 4
    static let rMD: CGFloat = 8
    static let rLG: CGFloat = 12
    static let rFull: CGFloat = 9999
}

enum ArenRadius {
    static let none: CGFloat = ArenRadiusScale.rNone
    static let xs: CGFloat = ArenRadiusScale.rXS
    static let sm: CGFloat = ArenRadiusScale.rSM
    static let md: CGFloat = ArenRadiusScale.rMD
    static let lg: CGFloat = ArenRadiusScale.rLG
    static let full: CGFloat = ArenRadiusScale.rFull
}
