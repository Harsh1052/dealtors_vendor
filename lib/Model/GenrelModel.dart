
class GenrelModel {
   String code;
   String country;
   String id;

  GenrelModel(
      {this.id, this.country,this.code});

  factory GenrelModel.fromJson(Map<String, dynamic> json) => GenrelModel(
    id: json["id"],
    code: "+"+json["phonecode"],
    country: json["name"],
     );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "country": country,

  };
}
