class User {
  final int? contactId;
  final int? spId;
  final int? vendorId;
  final int? employeeId;
  final int? customerId;
  final int? contactType;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? gender;
  final String? salutation;
  final String? phoneExt;
  final String? cell;
  final String? phone1;
  final String? phone2;
  final String? beeper;
  final String? birthDate;
  final String? email;
  final String? marriageDate;
  final String? note;
  final String? address1;
  final String? address2;
  final String? fax;
  final String? city;
  final String? stateRegion;
  final String? country;
  final String? zip;
  final String? image;
  final int? nonActive;
  final String? createUserId;
  final String? createDateTime;
  final String? updateUserId;
  final String? updateDateTime;
  final String? website;
  final String? gstNumber;
  final String? stateCode;
  final bool? isToken;
  final String? tokenNo;
  final String? tokenExpDate;
  final String? fintechVendor;
  final String? ltPassword;

  User({
    this.contactId,
    this.spId,
    this.vendorId,
    this.employeeId,
    this.customerId,
    this.contactType,
    this.firstName,
    this.middleName,
    this.lastName,
    this.gender,
    this.salutation,
    this.phoneExt,
    this.cell,
    this.phone1,
    this.phone2,
    this.beeper,
    this.birthDate,
    this.email,
    this.marriageDate,
    this.note,
    this.address1,
    this.address2,
    this.fax,
    this.city,
    this.stateRegion,
    this.country,
    this.zip,
    this.image,
    this.nonActive,
    this.createUserId,
    this.createDateTime,
    this.updateUserId,
    this.updateDateTime,
    this.website,
    this.gstNumber,
    this.stateCode,
    this.isToken,
    this.tokenNo,
    this.tokenExpDate,
    this.fintechVendor,
    this.ltPassword,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      contactId: json['contact_id'],
      spId: json['sp_id'],
      vendorId: json['vendor_id'],
      employeeId: json['employee_id'],
      customerId: json['customer_id'],
      contactType: json['contacttype'],
      firstName: json['firstname'],
      middleName: json['middlename'],
      lastName: json['lastname'],
      gender: json['gender'],
      salutation: json['salutation'],
      phoneExt: json['phoneext'],
      cell: json['cell'],
      phone1: json['phone1'],
      phone2: json['phone2'],
      beeper: json['beeper'],
      birthDate: json['birthdate'],
      email: json['email'],
      marriageDate: json['marriagedate'],
      note: json['note'],
      address1: json['address1'],
      address2: json['address2'],
      fax: json['fax'],
      city: json['city'],
      stateRegion: json['stateregion'],
      country: json['country'],
      zip: json['zip'],
      image: json['image'],
      nonActive: json['nonactive'],
      createUserId: json['createuserid'],
      createDateTime: json['createdatetime'],
      updateUserId: json['updateuserid'],
      updateDateTime: json['updatedatetime'],
      website: json['website'],
      gstNumber: json['gstnumber'],
      stateCode: json['statecode'],
      isToken: json['istoken'],
      tokenNo: json['tokenno'],
      tokenExpDate: json['tokenexpdate'],
      fintechVendor: json['fintechvendor'],
      ltPassword: json['lt_password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contact_id': contactId,
      'sp_id': spId,
      'vendor_id': vendorId,
      'employee_id': employeeId,
      'customer_id': customerId,
      'contacttype': contactType,
      'firstname': firstName,
      'middlename': middleName,
      'lastname': lastName,
      'gender': gender,
      'salutation': salutation,
      'phoneext': phoneExt,
      'cell': cell,
      'phone1': phone1,
      'phone2': phone2,
      'beeper': beeper,
      'birthdate': birthDate,
      'email': email,
      'marriagedate': marriageDate,
      'note': note,
      'address1': address1,
      'address2': address2,
      'fax': fax,
      'city': city,
      'stateregion': stateRegion,
      'country': country,
      'zip': zip,
      'image': image,
      'nonactive': nonActive,
      'createuserid': createUserId,
      'createdatetime': createDateTime,
      'updateuserid': updateUserId,
      'updatedatetime': updateDateTime,
      'website': website,
      'gstnumber': gstNumber,
      'statecode': stateCode,
      'istoken': isToken,
      'tokenno': tokenNo,
      'tokenexpdate': tokenExpDate,
      'fintechvendor': fintechVendor,
      'lt_password': ltPassword,
    };
  }
}
