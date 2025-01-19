class AccrualResponse {
  String id;
  double totalAmountEuro;
  String account;

  AccrualResponse({
    required this.id,
    required this.totalAmountEuro,
    required this.account,
  });
}

class AccrualRecord {
  String id;
  DateTime day;
  String description;
  double amountEuro;
  String account;

  AccrualRecord({
    required this.id,
    required this.day,
    required this.description,
    required this.amountEuro,
    required this.account,
  });

  @override
  String toString() {
    return 'id: $id, day: $day, description: $description, amount: $amountEuro, account: $account';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day.toIso8601String(),
      'description': description,
      'amountEuro': amountEuro,
      'account': account,
    };
  }

  factory AccrualRecord.fromJson(Map<String, dynamic> json) {
    return AccrualRecord(
      id: json['id'],
      day: DateTime.parse(json['day']),
      description: json['description'],
      amountEuro: json['amountEuros'],
      account: json['account'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day': day.toIso8601String(),
      'description': description,
      'amount_euro': amountEuro,
      'account': account,
    };
  }
}

enum AccountTypes {
  ansparen,
  sabadell,
  heizen,
  lucy,
  taschengeld,
  cut,
  essen,
  strom,
  miete,
  telekom,
  sonstiges,
  orf
}

