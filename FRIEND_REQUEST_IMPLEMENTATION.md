# Friend Request Implementation Guide

## Overview
This document describes the friend request functionality added to the BIS-SMS choptso messaging system.

## Implementation Date
February 17, 2026

## Files Modified
1. `firestore.rules` - Security rules for friend requests and friendships
2. `student-portal.html` - Friend request functions for students
3. `teacher-portal.html` - Friend request functions for teachers
4. `parent-portal.html` - Friend request functions for parents
5. `admin.html` - Friend request functions for admins

## Database Structure

### Collections

#### `/users/{userId}/friends/{friendId}`
Stores bidirectional friendships.

**Fields:**
- `addedAt`: Timestamp - When the friendship was established

**Security Rules:**
- Read: Authenticated users can read their own friends list or admin
- Write: User can write to their own friends list or friend can write (for bidirectional updates)

#### `/friendRequests/{requestId}`
Stores friend request documents.

**Fields:**
- `senderId`: string - UID of user sending the request
- `recipientId`: string - UID of user receiving the request
- `status`: string - One of: 'pending', 'accepted', 'rejected'
- `createdAt`: Timestamp - When request was created
- `acceptedAt`: Timestamp (optional) - When request was accepted
- `rejectedAt`: Timestamp (optional) - When request was rejected

**Security Rules:**
- Read: Sender, recipient, or admin can read
- Create: Authenticated users, must set senderId to their own UID
- Update: Sender or recipient can update (e.g., to accept/reject)
- Delete: Sender, recipient, or admin can delete

#### `/chats/{chatId}`
Stores chat metadata and messages.

**Subcollections:**
- `/messages/{messageId}` - Individual messages
- `/participants/{userId}` - Chat participants
- `/call/{callDoc}` - Voice/video call data
- `/status/{typingDoc}` - Typing indicators

**Security Rules:**
- All operations require user to be a participant in the chat
- Participants are verified via existence check in participants subcollection

## JavaScript Functions

### `sendFriendRequest(recipientId)`
Sends a friend request to another user.

**Parameters:**
- `recipientId` (string) - UID of the user to send request to

**Behavior:**
1. Checks if user is authenticated
2. Checks if a pending request already exists
3. Creates a new friend request document with status 'pending'
4. Shows success notification

**Returns:** Promise<void>

**Example:**
```javascript
await sendFriendRequest('userId123');
```

### `acceptFriendRequest(requestId, senderId)`
Accepts a friend request and creates bidirectional friendship.

**Parameters:**
- `requestId` (string) - ID of the friend request document
- `senderId` (string) - UID of the user who sent the request

**Behavior:**
1. Checks if user is authenticated
2. Creates friendship documents in both users' friends subcollections
3. Updates friend request status to 'accepted'
4. Shows success notification
5. Refreshes friend lists and requests

**Returns:** Promise<void>

**Example:**
```javascript
await acceptFriendRequest('requestId123', 'senderId456');
```

### `rejectFriendRequest(requestId)`
Rejects a friend request.

**Parameters:**
- `requestId` (string) - ID of the friend request document

**Behavior:**
1. Checks if user is authenticated
2. Updates friend request status to 'rejected'
3. Shows info notification
4. Refreshes friend request list

**Returns:** Promise<void>

**Example:**
```javascript
await rejectFriendRequest('requestId123');
```

### `loadFriendRequests()`
Loads all pending friend requests for the current user.

**Parameters:** None

**Behavior:**
1. Queries friendRequests collection for pending requests where recipientId matches current user
2. Fetches sender data in parallel using Promise.all
3. Returns array of request objects with sender data

**Returns:** Promise<Array<{id, senderId, recipientId, status, createdAt, senderData}>>

**Example:**
```javascript
const requests = await loadFriendRequests();
console.log(requests); // [{id: '...', senderData: {...}, ...}]
```

### `loadFriends()`
Loads the current user's friends list.

**Parameters:** None

**Behavior:**
1. Queries friends subcollection under current user
2. Fetches friend user data in parallel using Promise.all
3. Returns array of friend objects with user data

**Returns:** Promise<Array<{id, addedAt, ...userData}>>

**Example:**
```javascript
const friends = await loadFriends();
console.log(friends); // [{id: '...', email: '...', name: '...', addedAt: ...}]
```

### `areFriends(userId1, userId2)`
Checks if two users are friends.

**Parameters:**
- `userId1` (string) - First user's UID
- `userId2` (string) - Second user's UID

**Behavior:**
1. Checks if a friendship document exists in userId1's friends subcollection for userId2
2. Returns boolean result

**Returns:** Promise<boolean>

**Example:**
```javascript
const isFriend = await areFriends('user1', 'user2');
console.log(isFriend); // true or false
```

### `removeFriend(friendId)`
Removes a friend (deletes bidirectional friendship).

**Parameters:**
- `friendId` (string) - UID of the friend to remove

**Behavior:**
1. Checks if user is authenticated
2. Deletes friendship documents from both users' friends subcollections
3. Shows info notification
4. Refreshes friends list

**Returns:** Promise<void>

**Example:**
```javascript
await removeFriend('friendId123');
```

## Performance Optimizations

### Parallel Data Fetching
The `loadFriendRequests()` and `loadFriends()` functions use `Promise.all()` to fetch user data in parallel rather than sequentially. This significantly improves performance when loading multiple requests or friends.

**Before (N+1 queries):**
```javascript
for (const docSnap of snapshot.docs) {
  const senderDoc = await getDoc(doc(db, 'users', request.senderId));
  // Sequential - slow!
}
```

**After (Parallel queries):**
```javascript
const senderPromises = snapshot.docs.map(async (docSnap) => {
  return await getDoc(doc(db, 'users', request.senderId));
});
const results = await Promise.all(senderPromises);
// All fetches happen in parallel - fast!
```

## Security Considerations

### Authentication
All friend request functions check if the user is authenticated before proceeding:
```javascript
const currentUser = auth.currentUser;
if (!currentUser) {
  showNotification('Please sign in', 'error');
  return;
}
```

### Authorization
Firestore security rules enforce:
- Users can only send requests with their own UID as senderId
- Only the sender or recipient can update/delete a request
- Only friends can be added to both users' friends subcollections
- Admins have override permissions for moderation

### Data Validation
Firestore rules validate:
- Status field must be one of: 'pending', 'accepted', 'rejected'
- Only specific fields can be updated (status, acceptedAt, rejectedAt)
- Timestamps are properly formatted

## Integration with Choptso Messaging

The friend request system integrates with the existing choptso messaging system by:
1. Providing a foundation for contact lists based on friendships
2. Enabling chat initiation only with friends (optional feature)
3. Supporting future features like:
   - Friend-only status visibility
   - Friend-only message delivery
   - Friend suggestions based on mutual friends

## Testing Checklist

- [x] Firebase security rules validation passes
- [x] CI/CD checks pass
- [x] Code review feedback addressed
- [x] N+1 query patterns optimized
- [x] Return types are consistent
- [x] Error handling implemented
- [x] User notifications work correctly
- [x] CodeQL security scan passes

## Usage Example

```javascript
// Send a friend request
await sendFriendRequest('recipientUserId');

// Load pending requests
const requests = await loadFriendRequests();
requests.forEach(request => {
  console.log(`Request from: ${request.senderData.email}`);
});

// Accept a request
const request = requests[0];
await acceptFriendRequest(request.id, request.senderId);

// Load friends
const friends = await loadFriends();
console.log(`You have ${friends.length} friends`);

// Check friendship
const areFriends = await areFriends('userId1', 'userId2');

// Remove a friend
await removeFriend('friendId');
```

## Future Enhancements

Potential improvements:
1. Real-time friend request notifications
2. Friend suggestions based on mutual friends
3. Friend lists with online/offline status
4. Blocking/unblocking users
5. Privacy settings for friend requests
6. Friend request expiration
7. Mutual friend count display
8. Friend import from contacts

## Maintenance Notes

- Friend relationships are bidirectional and must be maintained in both users' subcollections
- When deleting a user, clean up all their friendships and friend requests
- Consider adding indexes for common queries (e.g., status='pending')
- Monitor Firestore costs if friend lists grow large

## Support

For issues or questions:
1. Check Firestore security rules in `firestore.rules`
2. Review function implementations in portal HTML files
3. Check Firebase console for error logs
4. Verify user authentication status
5. Test with Firebase Emulator Suite for debugging

## References

- Firebase Firestore Documentation: https://firebase.google.com/docs/firestore
- Firebase Security Rules: https://firebase.google.com/docs/firestore/security/get-started
- Promise.all Documentation: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all
