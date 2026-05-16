import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:math_legends/models/user_model.dart';

class FirestoreUserService {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  /// CREATE user (use UID from Firebase Auth)
  Future<void> addUserData(User user) async {
    await userCollection.doc(user.uid).set(user.toMap());
  }

  /// GET user by UID
  Future<User?> getUserByUid(String uid) async {
    final doc = await userCollection.doc(uid).get();
    if (!doc.exists) return null;
    return User.fromMap(doc.data() as Map<String, dynamic>);
  }

  /// UPDATE NAME
  Future<void> updateUserName({
    required String uid,
    required String name,
  }) async {
    await userCollection.doc(uid).update({
      'name': name,
    });
  }

  /// UPDATE PROFILE PICTURE
  Future<void> updateUserProfilePic({
    required String uid,
    required String profilePic,
  }) async {
    await userCollection.doc(uid).update({
      'profilePic': profilePic,
    });
  }

  /// UPDATE XP
  Future<void> updateUserXP({
    required String uid,
    required double xp,
  }) async {
    await userCollection.doc(uid).update({
      'xp': xp,
    });
  }

  /// UPDATE RP
  Future<void> updateUserRP({
    required String uid,
    required double rp,
  }) async {
    await userCollection.doc(uid).update({
      'rp': rp,
    });
  }

  Future<void> updateUserCoins({
    required String uid,
    required int coins,
  }) async {
    await userCollection.doc(uid).update({
      'coins': coins,
    });
  }

  /// UPDATE USER PLAY STATS
  Future<void> updateUserPlayStats({
    required String uid,
    required int chapter,
    required int stage
  }) async {
    await userCollection.doc(uid).update({
      'playStats': {
        'chapter': chapter,
        'stage': stage
      }
    });
  }

  /// UPDATE USER PLAY STATS
  Future<void> updateUserPets({
    required String uid,
    required Pet petData
  }) async {
    await userCollection.doc(uid).update({
      'petData': petData.toMap()
    });
  }

  /// UPDATE FULL USER
  Future<void> updateUser(User user) async {
    await userCollection.doc(user.uid).update(user.toMap());
  }
}
