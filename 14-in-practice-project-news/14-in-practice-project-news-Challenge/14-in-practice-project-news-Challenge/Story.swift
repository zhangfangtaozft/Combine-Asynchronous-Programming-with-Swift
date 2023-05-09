//
//  Story.swift
//  14-in-practice-project-news-Challenge
//
//  Created by 张芳涛 on 2023/5/10.
//

import Foundation

public struct Story: Codable {
    public let id: Int
    public let title: String
    public let by: String
    public let time: TimeInterval
    public let url: String
}

extension Story: Comparable {
    public static func < (lhs: Story, rhs: Story) -> Bool {
        return lhs.time > rhs.time
    }
}

extension Story: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\n\(title)\nby \(by)\n\(url)\n-----"
    }
}
