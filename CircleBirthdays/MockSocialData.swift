import Foundation

enum MockSocialData {
    static func memories() -> [MemoryPost] {
        [
            MemoryPost(
                id: "memory-1",
                userId: "A111",
                userName: "Prachi Vijay Gulab Chand",
                imageURL: "",
                caption: "A quiet family lunch that turned into a three-hour storytelling session.",
                timestamp: .now.addingTimeInterval(-172_800),
                status: "APPROVED",
                reactions: ["❤️": ["A112", "admin"], "🙏": ["A61"]],
                comments: [
                    PostComment(id: "c1", userId: "A112", userName: "Varun Vijay Gulab Chand", text: "This was such a good day.", timestamp: .now.addingTimeInterval(-86_400)),
                    PostComment(id: "c2", userId: "admin", userName: "Admin", text: "Add more old photos like this.", timestamp: .now.addingTimeInterval(-43_200))
                ]
            ),
            MemoryPost(
                id: "memory-2",
                userId: "A61",
                userName: "Pratish Kanti",
                imageURL: "",
                caption: "Wedding invitation cards are finally printed.",
                timestamp: .now.addingTimeInterval(-604_800),
                status: "PENDING",
                reactions: ["👍": ["A111"]],
                comments: []
            )
        ]
    }

    static func discussions() -> [DiscussionThread] {
        [
            DiscussionThread(
                id: "discussion-1",
                userId: "admin",
                userName: "Admin",
                type: .poll,
                title: "Venue for next family meet",
                content: "Pick the city that works best for most people.",
                pollOptions: [
                    PollOption(id: "poll-1", text: "Indore", voterIds: ["admin", "A112"]),
                    PollOption(id: "poll-2", text: "Ujjain", voterIds: ["A111"]),
                    PollOption(id: "poll-3", text: "Pune", voterIds: [])
                ],
                timestamp: .now.addingTimeInterval(-259_200),
                status: "APPROVED",
                comments: [
                    PostComment(id: "dc1", userId: "A111", userName: "Prachi Vijay Gulab Chand", text: "Pune is easier for me, but I can travel either way.", timestamp: .now.addingTimeInterval(-70_000))
                ]
            ),
            DiscussionThread(
                id: "discussion-2",
                userId: "A112",
                userName: "Varun Vijay Gulab Chand",
                type: .text,
                title: "Birthday reminder format",
                content: "Should we keep the current reminder style or add WhatsApp templates too?",
                pollOptions: [],
                timestamp: .now.addingTimeInterval(-86_400),
                status: "APPROVED",
                comments: []
            )
        ]
    }

    static func recipes() -> [Recipe] {
        [
            Recipe(
                id: "recipe-1",
                title: "Maa ke Haath ka Poha",
                authorId: "A111",
                authorName: "Prachi Vijay Gulab Chand",
                category: "Breakfast",
                description: "A family favorite for Sunday mornings.",
                ingredients: ["Poha", "Onion", "Peanuts", "Mustard seeds", "Lemon"],
                instructions: "Rinse the poha gently.\nTemper mustard seeds.\nAdd onion, peanuts, and poha.\nFinish with lemon and coriander.",
                imageURL: "",
                reactions: ["❤️": ["A112"], "🔥": ["admin"]],
                comments: [
                    PostComment(id: "rc1", userId: "A112", userName: "Varun Vijay Gulab Chand", text: "This is still the best breakfast.", timestamp: .now.addingTimeInterval(-65_000))
                ],
                timestamp: .now.addingTimeInterval(-129_600)
            ),
            Recipe(
                id: "recipe-2",
                title: "Family Kheer",
                authorId: "admin",
                authorName: "Admin",
                category: "Dessert",
                description: "Shared on festival evenings.",
                ingredients: ["Milk", "Rice", "Sugar", "Cardamom", "Dry fruits"],
                instructions: "Slow cook milk with rice until thick.\nAdd sugar and cardamom.\nGarnish with dry fruits.",
                imageURL: "",
                reactions: [:],
                comments: [],
                timestamp: .now.addingTimeInterval(-86_400)
            )
        ]
    }

    static func traditions() -> [Tradition] {
        [
            Tradition(
                id: "tradition-1",
                title: "Sunday family call",
                authorId: "admin",
                authorName: "Admin",
                description: "Every Sunday evening, at least one call goes around to every branch of the family.",
                imageURL: "",
                reactions: ["🙏": ["A111", "A112"]],
                comments: [
                    PostComment(id: "tc1", userId: "A111", userName: "Prachi Vijay Gulab Chand", text: "This keeps everyone connected.", timestamp: .now.addingTimeInterval(-54_000))
                ],
                timestamp: .now.addingTimeInterval(-172_800)
            ),
            Tradition(
                id: "tradition-2",
                title: "Festival group photo",
                authorId: "A112",
                authorName: "Varun Vijay Gulab Chand",
                description: "We always take one group photo before dinner starts.",
                imageURL: "",
                reactions: [:],
                comments: [],
                timestamp: .now.addingTimeInterval(-259_200)
            )
        ]
    }

    static func milestones() -> [Milestone] {
        [
            Milestone(
                id: "milestone-1",
                title: "First house in town",
                description: "The family moved into the first shared house and celebrated with a big meal.",
                year: "1998",
                imageURL: "",
                audioURL: "",
                location: "Jabalpur",
                timestamp: .now.addingTimeInterval(-345_600),
                authorId: "admin",
                authorName: "Admin",
                visibilityType: "GLOBAL",
                familyContextId: "",
                reactions: ["🙏": ["A111"]],
                comments: []
            ),
            Milestone(
                id: "milestone-2",
                title: "Grand wedding gathering",
                description: "One of the largest family functions remembered by everyone.",
                year: "2005",
                imageURL: "",
                audioURL: "",
                location: "Indore",
                timestamp: .now.addingTimeInterval(-172_800),
                authorId: "A111",
                authorName: "Prachi Vijay Gulab Chand",
                visibilityType: "GLOBAL",
                familyContextId: "",
                reactions: [:],
                comments: []
            )
        ]
    }

    static func channels() -> [ChatChannel] {
        [
            ChatChannel(
                id: "A111_A112",
                userIds: ["A111", "A112"],
                lastMessage: "I’ll call Bade Papa tonight.",
                lastTimestamp: .now.addingTimeInterval(-4_000),
                unreadCount: ["A111": 0, "A112": 1]
            ),
            ChatChannel(
                id: "A111_admin",
                userIds: ["A111", "admin"],
                lastMessage: "Please review the pending memory upload.",
                lastTimestamp: .now.addingTimeInterval(-9_000),
                unreadCount: ["A111": 1, "admin": 0]
            )
        ]
    }

    static func messages() -> [ChatMessage] {
        [
            ChatMessage(id: "m1", senderId: "A111", senderName: "Prachi Vijay Gulab Chand", receiverId: "A112", text: "Did you call home?", timestamp: .now.addingTimeInterval(-8_000)),
            ChatMessage(id: "m2", senderId: "A112", senderName: "Varun Vijay Gulab Chand", receiverId: "A111", text: "Not yet, doing it after dinner.", timestamp: .now.addingTimeInterval(-7_200)),
            ChatMessage(id: "m3", senderId: "A112", senderName: "Varun Vijay Gulab Chand", receiverId: "A111", text: "I’ll call Bade Papa tonight.", timestamp: .now.addingTimeInterval(-4_000)),
            ChatMessage(id: "m4", senderId: "admin", senderName: "Admin", receiverId: "A111", text: "Can you verify the new member entry?", timestamp: .now.addingTimeInterval(-12_000)),
            ChatMessage(id: "m5", senderId: "A111", senderName: "Prachi Vijay Gulab Chand", receiverId: "admin", text: "Please review the pending memory upload.", timestamp: .now.addingTimeInterval(-9_000))
        ]
    }
}
