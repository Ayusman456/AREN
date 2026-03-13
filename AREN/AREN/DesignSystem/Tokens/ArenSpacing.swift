import SwiftUI

private enum ArenSpacingScale {
    static let sp0: CGFloat = 0
    static let sp1: CGFloat = 1
    static let sp2: CGFloat = 2
    static let sp3: CGFloat = 4
    static let sp4: CGFloat = 8
    static let sp5: CGFloat = 12
    static let sp6: CGFloat = 16
    static let sp7: CGFloat = 20
    static let sp8: CGFloat = 24
    static let sp9: CGFloat = 32
    static let sp10: CGFloat = 40
    static let sp11: CGFloat = 48
    static let sp12: CGFloat = 64
    static let sp13: CGFloat = 80
    static let sp14: CGFloat = 96
    static let sp15: CGFloat = 128
}

enum ArenSpacing {
    static let none: CGFloat = ArenSpacingScale.sp0
    static let hairline: CGFloat = ArenSpacingScale.sp1
    static let micro: CGFloat = ArenSpacingScale.sp2
    static let xxs: CGFloat = ArenSpacingScale.sp3
    static let xs: CGFloat = ArenSpacingScale.sp4
    static let sm: CGFloat = ArenSpacingScale.sp5
    static let md: CGFloat = ArenSpacingScale.sp6
    static let lg: CGFloat = ArenSpacingScale.sp7
    static let xl: CGFloat = ArenSpacingScale.sp8
    static let xxl: CGFloat = ArenSpacingScale.sp9
    static let xxxl: CGFloat = ArenSpacingScale.sp10
    static let screen: CGFloat = ArenSpacingScale.sp11
    static let hero: CGFloat = ArenSpacingScale.sp12
    static let section: CGFloat = ArenSpacingScale.sp13
    static let editorial: CGFloat = ArenSpacingScale.sp14
    static let canvas: CGFloat = ArenSpacingScale.sp15
}
