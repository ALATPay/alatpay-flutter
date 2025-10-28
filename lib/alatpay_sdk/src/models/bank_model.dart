class Bank {
  final String imageUrl;
  final String bankCode;
  final String scCode;
  final String bankName;

  const Bank({
    required this.imageUrl,
    required this.bankCode,
    required this.scCode,
    required this.bankName,
  });

  factory Bank.fromJson(Map<String, dynamic> json) => Bank(
        imageUrl: json['imageUrl'] ?? '',
        bankCode: json['bankCode'] ?? '',
        scCode: json['scCode'] ?? '',
        bankName: json['bankName'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'imageUrl': imageUrl,
        'bankCode': bankCode,
        'scCode': scCode,
        'bankName': bankName,
      };
}
