//
//  NationalityFlags.swift
//  WebstarF1App
//
//  Created by Bence on 2026.03.27.
//

enum NationalityFlags {
    static let map: [String: String] = [
        "British": "🇬🇧",
        "German": "🇩🇪",
        "French": "🇫🇷",
        "Finnish": "🇫🇮",
        "Spanish": "🇪🇸",
        "Dutch": "🇳🇱",
        "Australian": "🇦🇺",
        "Canadian": "🇨🇦",
        "Mexican": "🇲🇽",
        "Thai": "🇹🇭",
        "Italian": "🇮🇹",
        "Russian": "🇷🇺",
        "Polish": "🇵🇱",
        "Brazilian": "🇧🇷",
        "Japanese": "🇯🇵",
        "Monegasque": "🇲🇨",
        "Danish": "🇩🇰",
        "American": "🇺🇸",
        "Swiss": "🇨🇭",
        "Indian": "🇮🇳",
        "Chinese": "🇨🇳",
        "Swedish": "🇸🇪",
        "Austrian": "🇦🇹",
        "Belgian": "🇧🇪",
        "Colombian": "🇨🇴",
        "Portuguese": "🇵🇹",
        "Argentine": "🇦🇷",
        "Hungarian": "🇭🇺",
        "Irish": "🇮🇪",
        "South African": "🇿🇦",
        "New Zealander": "🇳🇿",
        "Venezuelan": "🇻🇪",
        "Indonesian": "🇮🇩",
        "Korean": "🇰🇷"
    ]
    
    static func flag(for nationality: String) -> String {
        map[nationality] ?? nationality
    }
}
