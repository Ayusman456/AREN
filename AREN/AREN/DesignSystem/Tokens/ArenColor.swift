import SwiftUI

private extension Color {
    init(hex: UInt64, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

enum ArenPalette {
    enum Neutral {
        static let n01 = Color(hex: 0x000000)
        static let n02 = Color(hex: 0x111111)
        static let n03 = Color(hex: 0x1F1F1F)
        static let n04 = Color(hex: 0x2E2E2E)
        static let n05 = Color(hex: 0x3D3D3D)
        static let n06 = Color(hex: 0x4D4D4D)
        static let n07 = Color(hex: 0x5D5D5D)
        static let n08 = Color(hex: 0x737373)
        static let n09 = Color(hex: 0x878787)
        static let n10 = Color(hex: 0x9B9B9B)
        static let n11 = Color(hex: 0xADADAD)
        static let n12 = Color(hex: 0xC2C2C2)
        static let n13 = Color(hex: 0xD4D4D4)
        static let n14 = Color(hex: 0xE3E3E3)
        static let n15 = Color(hex: 0xF2F2F2)
        static let n16 = Color(hex: 0xFFFFFF)
    }

    enum Red {
        static let r01 = Color(hex: 0x1A0003)
        static let r02 = Color(hex: 0x370006)
        static let r03 = Color(hex: 0x560009)
        static let r04 = Color(hex: 0x75000D)
        static let r05 = Color(hex: 0x930010)
        static let r06 = Color(hex: 0xB20013)
        static let r07 = Color(hex: 0xCC0012)
        static let r08 = Color(hex: 0xDC000F)
        static let r09 = Color(hex: 0xE50010)
        static let r10 = Color(hex: 0xEC2530)
        static let r11 = Color(hex: 0xF04D56)
        static let r12 = Color(hex: 0xF47079)
        static let r13 = Color(hex: 0xF7939A)
        static let r14 = Color(hex: 0xFAB5B9)
        static let r15 = Color(hex: 0xFCD8DA)
        static let r16 = Color(hex: 0xFEF0F0)
    }

    enum Green {
        static let g01 = Color(hex: 0x071A0F)
        static let g02 = Color(hex: 0x0D3320)
        static let g03 = Color(hex: 0x0F4D2E)
        static let g04 = Color(hex: 0x006A38)
        static let g05 = Color(hex: 0x007840)
        static let g06 = Color(hex: 0x007D42)
        static let g07 = Color(hex: 0x008744)
        static let g08 = Color(hex: 0x009A4E)
        static let g09 = Color(hex: 0x00AE5C)
        static let g10 = Color(hex: 0x00BC65)
        static let g11 = Color(hex: 0x1AC97A)
        static let g12 = Color(hex: 0x47D690)
        static let g13 = Color(hex: 0x76E3AA)
        static let g14 = Color(hex: 0xA8EFC8)
        static let g15 = Color(hex: 0xD0F7E3)
        static let g16 = Color(hex: 0xEDFCF4)
    }

    enum Orange {
        static let o01 = Color(hex: 0x2A1600)
        static let o02 = Color(hex: 0x4D2800)
        static let o03 = Color(hex: 0x6B3A00)
        static let o04 = Color(hex: 0x8A4D00)
        static let o05 = Color(hex: 0xA85E00)
        static let o06 = Color(hex: 0xC47000)
        static let o07 = Color(hex: 0xDC8200)
        static let o08 = Color(hex: 0xF09200)
        static let o09 = Color(hex: 0xFF9C00)
        static let o10 = Color(hex: 0xFFAB26)
        static let o11 = Color(hex: 0xFFB84D)
        static let o12 = Color(hex: 0xFFC670)
        static let o13 = Color(hex: 0xFFD699)
        static let o14 = Color(hex: 0xFFE4BB)
        static let o15 = Color(hex: 0xFFF0D6)
        static let o16 = Color(hex: 0xFFF8EC)
    }

    enum Blue {
        static let b01 = Color(hex: 0x0A1014)
        static let b02 = Color(hex: 0x141F26)
        static let b03 = Color(hex: 0x1E2F38)
        static let b04 = Color(hex: 0x293F4D)
        static let b05 = Color(hex: 0x354F61)
        static let b06 = Color(hex: 0x406075)
        static let b07 = Color(hex: 0x4E7389)
        static let b08 = Color(hex: 0x5D8599)
        static let b09 = Color(hex: 0x6F96A8)
        static let b10 = Color(hex: 0x87A9B8)
        static let b11 = Color(hex: 0x9DBBC8)
        static let b12 = Color(hex: 0xB4CDD7)
        static let b13 = Color(hex: 0xD3DFE8)
        static let b14 = Color(hex: 0xE0E9EF)
        static let b15 = Color(hex: 0xEDF3F6)
        static let b16 = Color(hex: 0xF5F8FA)
    }

    enum Overlay {
        static let o01 = Color(hex: 0x000000, opacity: 0.75)
    }
}

enum ArenColor {
    enum Text {
        static let primary = ArenPalette.Neutral.n01
        static let secondary = ArenPalette.Neutral.n08
        static let tertiary = ArenPalette.Neutral.n09
        static let disabled = ArenPalette.Neutral.n10
        static let inverse = ArenPalette.Neutral.n16

        static let accentGreenPrimary = ArenPalette.Green.g07
        static let accentGreenSecondary = ArenPalette.Green.g06
        static let accentOrangePrimary = ArenPalette.Orange.o07
        static let accentOrangeSecondary = ArenPalette.Orange.o06
        static let accentRedPrimary = ArenPalette.Red.r06
        static let accentRedSecondary = ArenPalette.Red.r05
        static let accentBluePrimary = ArenPalette.Blue.b06
        static let accentBlueSecondary = ArenPalette.Blue.b05
    }

    enum Surface {
        static let primary = ArenPalette.Neutral.n16
        static let secondary = ArenPalette.Neutral.n15
        static let tertiary = ArenPalette.Neutral.n14
        static let overlay = ArenPalette.Overlay.o01

        static let accentGreenPrimary = ArenPalette.Green.g16
        static let accentGreenSecondary = ArenPalette.Green.g15
        static let accentOrangePrimary = ArenPalette.Orange.o16
        static let accentOrangeSecondary = ArenPalette.Orange.o15
        static let accentRedPrimary = ArenPalette.Red.r16
        static let accentRedSecondary = ArenPalette.Red.r15
        static let accentBluePrimary = ArenPalette.Blue.b16
        static let accentBlueSecondary = ArenPalette.Blue.b15
    }

    enum Fill {
        static let primary = ArenPalette.Neutral.n01
        static let secondary = ArenPalette.Neutral.n06
        static let tertiary = ArenPalette.Neutral.n13

        static let accentGreenPrimary = ArenPalette.Green.g10
        static let accentGreenSecondary = ArenPalette.Green.g11
        static let accentOrangePrimary = ArenPalette.Orange.o09
        static let accentOrangeSecondary = ArenPalette.Orange.o10
        static let accentRedPrimary = ArenPalette.Red.r09
        static let accentRedSecondary = ArenPalette.Red.r10
        static let accentBluePrimary = ArenPalette.Blue.b13
        static let accentBlueSecondary = ArenPalette.Blue.b14
    }

    enum Border {
        static let primary = ArenPalette.Neutral.n13
        static let secondary = ArenPalette.Neutral.n14
        static let inverse = ArenPalette.Neutral.n16

        static let accentGreen = ArenPalette.Green.g12
        static let accentOrange = ArenPalette.Orange.o11
        static let accentRed = ArenPalette.Red.r11
        static let accentBlue = ArenPalette.Blue.b12
    }

    enum Icon {
        static let primary = ArenPalette.Neutral.n01
        static let secondary = ArenPalette.Neutral.n08
        static let disabled = ArenPalette.Neutral.n10
        static let inverse = ArenPalette.Neutral.n16

        static let accentGreen = ArenPalette.Green.g09
        static let accentOrange = ArenPalette.Orange.o08
        static let accentRed = ArenPalette.Red.r08
        static let accentBlue = ArenPalette.Blue.b07
    }
}
