import '../utils/game_data.dart';

class User {
  String? uid;
  String? name;
  String? email;
  double? xp;
  double? rp;
  int? coins;
  String? profilePic;
  PlayStats? playStats;
  Pet? petData;

  User(this.uid, this.name, this.email, this.xp, this.rp, this.coins,
      this.profilePic, this.playStats);

  User.fromMap(Map<String, dynamic> data) {
    uid = data['uid'];
    name = data['name'];
    email = data['email'];
    xp = data['xp'].toDouble() ?? 0.00;
    rp = data['rp'].toDouble() ?? 0.00;
    coins = data['coins'] ?? 0;
    profilePic = data['profilePic'];
    playStats = PlayStats.fromMap(data['playStats']);
    petData = Pet.fromMap(data['petData'] ?? Pet().toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'xp': xp,
      'rp': rp,
      'coins': coins,
      'profilePic': profilePic,
      'playStats': playStats!.toMap(),
      'petData': petData!.toMap()
    };
  }
}

class PlayStats {
  int? chapter;
  int? stage;

  PlayStats(this.chapter, this.stage);

  PlayStats.fromMap(Map<String, dynamic> data) {
    chapter = data["chapter"] ?? 1;
    stage = data["stage"] ?? 1;
  }

  Map<String, dynamic> toMap() {
    return {'chapter': chapter, 'stage': stage};
  }
}

class Pet {
  Map<PetData, PetStats>? petData = Map.fromEntries(
      GameData.pets.map((e) => MapEntry(e, PetStats(false, false))));

  Pet();

  Pet.fromMap(Map<String, dynamic> data) {
    for (final entry in data.entries) {
      final id = int.tryParse(entry.key);
      if (id != null) {
        petData![GameData.getPetById(id)] = PetStats.fromMap(entry.value);
      }
    }
  }

  Map<String, dynamic> toMap() {
    return petData!.map(
      (key, value) => MapEntry(key.id.toString(), value.toMap()),
    );
  }
}

class PetStats {
  bool? discovered;
  bool? equipped;

  PetStats(this.discovered, this.equipped);

  PetStats.fromMap(Map<String, dynamic> data) {
    discovered = data["discovered"] ?? false;
    equipped = data["equipped"] ?? false;
  }

  Map<String, dynamic> toMap() {
    return {'discovered': discovered ?? false, 'equipped': equipped ?? false};
  }
}
