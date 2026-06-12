# CircleBirthdays AI Database Context

This file is intended as grounding context for AI features and future client work. It summarizes the Firestore data model used by the iOS app and the relationship rules the assistant should use when answering questions.

## Will This Help The AI Chat?

Yes, but only if the AI chat is changed to use this context and the live in-memory app data. A schema file helps the assistant understand what data exists and how relationships are represented. It does not by itself add memory, fuzzy matching, or relationship reasoning.

For a better AI chat, use this document plus:
- Current logged-in user: `AppViewModel.currentUser`
- Resolved member list: `AppViewModel.allResolvedMembers` or `FamilyUtils.populateAllLinks(...)`
- Conversation state: previous matched members and previous question intent
- Fuzzy search over member names, nicknames, parent names, spouse names, locations, relationship words, and family IDs

## Core Concepts

### Status Values

Many records use `status`:
- `APPROVED`: visible to normal users
- `PENDING`: visible to admins and usually hidden from normal users
- `REMOVED`: used for soft-removed member profiles

The app normalizes statuses by trimming whitespace and uppercasing.

### Admin Access

Admin privileges are based on the logged-in member document:
- `members/{userId}.isAdmin == true`

Do not hardcode admin phone numbers. The phone number is only used to find the login member.

### Member Identity

Important member identifiers:
- Firestore document ID: internal app/user ID, such as `A111` or `admin`
- `familyId`: family hierarchy ID used for tree and relationship inference
- `phoneNumber`: login lookup key

## Collections

## `members`

Approved member profiles. This is the canonical profile table.

Document ID:
- Member/user ID

Fields:
- `familyId: String` - hierarchy ID, also used for parent/child inference
- `name: String`
- `gender: String`
- `dateOfBirth: String | Timestamp` - normalized to `yyyy-MM-dd`
- `phoneNumber: String`
- `email: String?`
- `location: String?`
- `spouseName: String?`
- `fatherName: String?`
- `motherName: String?`
- `marriageDate: String | Timestamp?`
- `bereavementDate: String | Timestamp?`
- `photoUrl: String?`
- `immediateFamily: String`
- `address: String?`
- `latitude: Double?`
- `longitude: Double?`
- `flatNumber: String?`
- `floor: String?`
- `landmark: String?`
- `password: String?` - SHA-256 hash when set
- `isAdmin: Bool`
- `isEditor: Bool`
- `isPrimaryTree: Bool`
- `secondaryTreeEnabled: Bool`
- `treeId: String` - defaults to `primary`
- `status: String` - defaults to `APPROVED`
- `lastLoggedIn: Int64?` - epoch milliseconds
- `relationship: String?` - often a display/cache value, not the source of truth
- `fcmToken: String?`
- `facebookUrl: String?`
- `instagramUrl: String?`
- `youtubeUrl: String?`
- `manualRelationships: Map<String, String>` - observer member ID to custom relationship label
- `requestedBy: String?`
- `requestedByName: String?`
- `requestedRelationship: String?`
- `points: Int`
- `level: Int`
- `badges: [String]`

AI guidance:
- Prefer live relationship inference over stored `relationship`.
- Use `manualRelationships[currentUser.id]` first when present.
- Include deceased/remembrance context when `bereavementDate` is set.

## `pending_updates`

Pending member profile edits. Admins approve these into `members`.

Document ID:
- Same member/user ID as the profile being edited.

Fields:
- Same shape as `members`
- Usually `status: PENDING`
- `requestedBy` and `requestedByName` identify who submitted the change
- `requestedRelationship` may contain a requested relationship override

Important behavior:
- Pending docs may be incomplete if written by another client.
- Admin clients should fetch all docs without requiring `familyId`.
- Approving writes the pending member to `members/{id}` with `status: APPROVED`, then deletes `pending_updates/{id}`.

AI guidance:
- Mention pending edits only to admins.
- If a user asks why a change is missing, check `pending_updates`.

## `signup_requests`

Requests from new users who already have a family profile but no phone number/login mapped yet.

Document ID:
- Generated ID like `signup-{UUID}`

Fields:
- `name: String`
- `parentName: String`
- `mobileNumber: String`
- `email: String`
- `status: String` - usually `PENDING`
- `requestedAt: Int64` - epoch milliseconds
- `suggestedMemberID: String?`
- `suggestedMemberName: String?`

Important behavior:
- Signup must not create a new profile.
- Admin maps the request to an existing member profile.
- Approval updates that member’s `phoneNumber` and optionally `email`, sets profile `status: APPROVED`, then removes the signup request.
- If no suggested match exists, admin can reassign to a profile or reject.

AI guidance:
- If a phone number already exists in `members`, tell the user to login instead of signing up.

## `relationship_overrides`

Pending custom relationship labels.

Document ID:
- Often `{observerId}_{targetId}`

Fields:
- `id: String`
- `observerId: String` - member who wants a custom relationship label
- `observerName: String`
- `targetId: String` - member being labeled
- `targetName: String`
- `relationship: String`
- `status: String` - usually `PENDING`

Approval behavior:
- On approval, update `members/{targetId}.manualRelationships[observerId] = relationship`
- Delete the override request

AI guidance:
- When answering “what is X to me?”, use `target.manualRelationships[currentUser.id]` first.

## `memories`

Gallery/photo posts.

Fields:
- `id: String`
- `userId: String`
- `userName: String`
- `imageUrl: String`
- `caption: String`
- `timestamp: Int64 | Timestamp`
- `status: String`
- `reactions: Map<String, [String]>` - emoji to member IDs
- `comments: [PostComment]`

`PostComment` fields:
- `id: String`
- `userId: String`
- `userName: String`
- `text: String`
- `timestamp: Int64 | Timestamp`

AI guidance:
- Normal users should only see approved memories.
- Admins may see pending memories.

## `discussions`

Discussion threads and polls.

Fields:
- `id: String`
- `userId: String`
- `userName: String`
- `type: String` - `TEXT`, `IMAGE`, or `POLL`
- `title: String`
- `content: String`
- `pollOptions: [{ id, text, voterIds }]`
- `timestamp: Int64 | Timestamp`
- `status: String`
- `comments: [PostComment]`

## `recipes`

Family cookbook entries.

Fields:
- `id: String`
- `title: String`
- `authorId: String`
- `authorName: String`
- `category: String`
- `description: String`
- `ingredients: [String]`
- `instructions: String`
- `imageUrl: String`
- `reactions: Map<String, [String]>`
- `comments: [PostComment]`
- `status: String`
- `timestamp: Int64 | Timestamp`

Compatibility:
- `ingredients` may be a string or array in older data.
- `instructions` may also appear as `instruction`, `steps`, or `method`.

## `traditions`

Family traditions.

Fields:
- `id: String`
- `title: String`
- `authorId: String`
- `authorName: String`
- `description: String`
- `imageUrl: String`
- `reactions: Map<String, [String]>`
- `comments: [PostComment]`
- `status: String`
- `timestamp: Int64 | Timestamp`

## `memorylane`

Milestones and memory lane entries.

Fields:
- `id: String`
- `title: String`
- `description: String`
- `year: String`
- `imageUrl: String`
- `audioUrl: String`
- `location: String`
- `timestamp: Int64 | Timestamp`
- `authorId: String`
- `authorName: String`
- `visibilityType: String` - defaults to `GLOBAL`
- `familyContextId: String`
- `reactions: Map<String, [String]>`
- `comments: [PostComment]`
- `status: String`

## `businesses`

Family business directory.

Fields:
- `id: String`
- `name: String`
- `ownerName: String`
- `contactNumber: String`
- `type: String`
- `address: String`
- `locationLink: String`
- `latitude: Double?`
- `longitude: Double?`
- `addedBy: String`
- `treeId: String`
- `timestamp: Int64`

## `deletion_requests`

Admin approval queue for content deletion.

Fields:
- `id: String`
- `collectionName: String`
- `docId: String`
- `title: String`
- `reason: String`
- `requestedBy: String`
- `requestedByName: String`
- `timestamp: Int64 | Timestamp`
- `status: String`

Compatibility:
- `docId` may also be stored as `itemId`, `targetId`, `postId`, or `memoryId`.
- `requestedByName` may also be stored as `requesterName` or `userName`.

## `channels`

Chat channel between members.

Document ID:
- Sorted pair of member IDs joined with `_`, for example `A111_admin`

Fields:
- `userIds: [String]`
- `lastMessage: String`
- `lastTimestamp: Int64 | Timestamp`
- `unreadCount: Map<String, Int>`

Subcollection:
- `channels/{channelId}/messages`

Message fields:
- `id: String`
- `senderId: String`
- `senderName: String`
- `receiverId: String`
- `text: String`
- `timestamp: Int64 | Timestamp`

AI guidance:
- The current in-app AI chat is not the same as member-to-member chat.
- If adding AI memory, store it separately or keep it local/session-scoped.

## `notifications`

App notifications and admin alerts.

Fields:
- `id: String`
- `type: String`
- `title: String`
- `body: String`
- `timestamp: Int64 | Timestamp`
- `readBy: [String]`
- `targetUserId: String?`
- `senderId: String?`
- `senderName: String?`
- `relatedId: String?`
- `isAdminOnly: Bool`
- `topic: String?`
- `metadata: Map<String, String>`

Visibility:
- If `isAdminOnly == true`, show only to admin users.
- If `targetUserId` is set, show only to that user.
- Topic and metadata may further describe content type.

## `game_sessions`

Family games state.

Fields:
- `id: String`
- `gameType: String` - `SNAKES_LADDERS`, `CHESS`, `CHAUPAD`, `HANGMAN`, `RUMMY`, `ANTAKSHARI`
- `players: [String]`
- `playerNames: Map<String, String>`
- `status: String` - for example `WAITING`, `ACTIVE`, `COMPLETED`
- `currentTurn: String`
- `gameState: Map<String, Any>`
- `winnerId: String?`
- `lastUpdated: Int64`

## Relationship Model

The family tree is primarily inferred from `familyId`.

### Spouse Convention

- A spouse member usually has a `familyId` ending in `0`.
- Example: if primary member is `A11`, spouse is usually `A110`.
- For spouse entries, the base person is `familyId.dropLast()`.

### Parent/Child Convention

- Parent base ID is generally the child base ID with the last character removed.
- Example: `A111` child parent base is `A11`.
- For top-level descendants, parent base may be `P`.
- Children are members whose base ID starts with the parent base and is one character longer.

### Relationship Inference Order

When answering relationship questions from the logged-in user’s perspective:

1. If target is current user, say it is the user themself.
2. If `target.manualRelationships[currentUser.id]` exists, use that.
3. Otherwise use `FamilyUtils.getRelationship(target: observer: allMembers:)`.
4. If no relationship is inferred, fall back to saved `relationship`, family ID, or a neutral description.

### Common Relationship Labels

The app may infer labels such as:
- Self/spouse: `Husband`, `Wife`
- Siblings/cousins: `Bhai`, `Bhaiya`, `Behan`, `Didi`
- Parents: `Papa`, `Mummy`
- Grandparents: `Dadaji`, `Dadi`, `Nana`, `Nani`
- In-laws: `Sasurji`, `Saasuma`, `Devar`, `Jeth`, `Nanad`, `Saala`, `Saali`
- Extended family: `Bade Papa`, `Chachaji`, `Badi Bua`, `Choti Bua`, `Bade Mamaji`, `Chote Mamaji`, `Badi Mausi`, `Choti Mausi`, `Bhabhi`, `Jijaji`

## AI Chat Recommendations

The current AI should be upgraded to:

1. Keep short session context:
   - last mentioned members
   - last intent, such as birthday, phone, relationship, location
   - selected match when user says “first one”, “same person”, “his”, “her”, or “their”

2. Use fuzzy member matching:
   - tokenize names
   - search father/mother/spouse names
   - search family ID
   - handle partial names and common spelling differences
   - support relationship terms such as “mummy”, “papa”, “bade papa”, “didi”, “bhai”

3. Always reason from logged-in user:
   - Current user is `AppViewModel.currentUser`
   - Relationship answers are observer-dependent
   - “my father”, “my sister”, “my bade papa” should use current user’s `familyId`

4. Prefer resolved members:
   - Use `FamilyUtils.populateAllLinks(members: allMembers, allMembers: allMembers, currentUser: currentUser)`
   - This fills inferred spouse, parents, siblings, children, immediate family, and relationship labels.

5. Ask clarifying questions only when needed:
   - If multiple likely matches exist, list names with family IDs and one useful disambiguator.
   - Remember the options for the next user response.

6. Respect visibility:
   - Non-admin users should not see pending approvals or admin-only notifications.
   - Admins can see `pending_updates`, `signup_requests`, pending content, relationship overrides, and deletion requests.

## Example AI Query Handling

Question: “When is Prachi birthday?”
- Fuzzy match `Prachi Vijay Gulab Chand`
- Read `dateOfBirth`
- Answer date and optionally days until birthday.

Question: “What is she to me?”
- Use previous matched member as target.
- Use current logged-in user as observer.
- Check target `manualRelationships[currentUser.id]`
- Else infer with `FamilyUtils.getRelationship`.

Question: “Who is my father?”
- Use current user’s `familyId`.
- Parent base is current user base without last character.
- Determine father by matching parent/spouse gender.

Question: “Show pending approvals”
- Only if `currentUser.isAdmin == true`
- Use `pending_updates`, `signup_requests`, and pending content collections.
