class AddressDetails {
  String addressNickname;
  String fullAddress;

  AddressDetails({
    required this.addressNickname,
    required this.fullAddress,
  });

  factory AddressDetails.fromJson(Map<String, dynamic> json) {
    return AddressDetails(
      addressNickname: json['addressNickname'],
      fullAddress: json['fullAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressNickname': addressNickname,
      'fullAddress': fullAddress,
    };
  }
}
