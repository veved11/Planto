import SwiftUI

// أنماط الخطوط المستخدمة في شاشات التطبيق ومكوّناته.
enum AppTypography {

    // عنوان الشاشة الرئيسية.
    static let screenTitle = Font.system(size: 28, weight: .bold)

    // عنوان شاشة البداية.
    static let welcomeTitle = Font.system(size: 20, weight: .bold)

    // النص التوضيحي في شاشة البداية.
    static let welcomeDescription = Font.system(size: 14, weight: .regular)

    // النص داخل الزر.
    static let buttonTitle = Font.system(size: 18, weight: .medium)

    // اسم النبتة في صف القائمة.
    static let plantName = Font.system(size: 28, weight: .regular)

    // موقع النبتة بجانب أيقونة الغرفة.
    static let plantLocation = Font.system(size: 15, weight: .regular)

    // النص داخل شارات الإضاءة والماء.
    static let careDetail = Font.system(size: 14, weight: .medium)

    // رسالة الحالة الفارغة.
    static let emptyState = Font.system(size: 16, weight: .semibold)

    // رسالة التقدم اليومي فوق شريط الإنجاز.
    static let progressMessage = Font.system(size: 18, weight: .regular)
}
