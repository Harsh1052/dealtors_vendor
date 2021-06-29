
import 'Coupon.dart';

class Vendor {
  final String id;
  final String first_name;
  final String totalCoupon;
  final String image_path;
  final String business_name;

  Vendor(
      {this.first_name,
      this.image_path,
      this.totalCoupon,
      this.id,
      this.business_name});

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
        id: json["id"],
        first_name: json["first_name"],
        totalCoupon:
            json["totalCoupon"] != null ? json["totalCoupon"].toString() : "",
        image_path: json["image_path"],
        business_name: json["business_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": first_name,
        "totalCoupon": totalCoupon,
        "image_path": image_path,
        "business_name": business_name
      };
}

class VendorDetail {
  final String id;
  final String first_name;
  final String business_category_name;
  final String email_address;
  final String totalCoupon;
  final String image_path;
  final String business_name;
  final String address;
  final String rate;
  final String mobile_no;
  final String about_business;
  final String open_time;
  final String close_time;
  final String business_contact_no;
  final String business_area;
  final String business_landmark;
  final String business_location;
  final String business_category_id;
  List<Coupon> coupons;

  VendorDetail(
      {this.first_name,
      this.business_category_name,
      this.email_address,
      this.image_path,
      this.totalCoupon,
      this.id,
      this.business_name,
      this.close_time,
      this.open_time,
      this.rate,
      this.address,
      this.mobile_no,
      this.about_business,
      this.business_contact_no,
      this.business_area,
      this.business_landmark,
      this.business_location,
      this.business_category_id,
      this.coupons});

  factory VendorDetail.fromJson(Map<String, dynamic> json) => VendorDetail(
      id: json["id"],
      first_name: json["first_name"] != null ? json["first_name"] : "",
      business_category_name: json["business_category_name"] != null
          ? json["business_category_name"]
          : "",
      totalCoupon: "",
      /*json["totalCoupon"] as String,*/
      image_path: json["image_path"] != null ? json["image_path"] : "",
      business_name: json["business_name"] != null ? json["business_name"] : "",
      close_time: json["closing_time"] != null ? json["closing_time"] : "",
      open_time: json["opening_time"] != null ? json["opening_time"] : "",
      rate: "" + json["average_rating"].toString() != null
          ? json["average_rating"].toString()
          : "",
      address: "" + json["address"] != null ? json["address"] : "",
      mobile_no: json["mobile_no"] != null ? json["mobile_no"] : "",
      about_business:
          json["about_business"] != null ? json["about_business"] : "",
      email_address: json["email_address"] != null ? json["email_address"] : "",
      business_contact_no: json["business_contact_no"] != null ? json["business_contact_no"] : "",
      business_area: json["business_area"] != null ? json["business_area"] : "",
      business_landmark: json["business_landmark"] != null ? json["business_landmark"] : "",
      business_location: json["business_location"] != null ? json["business_location"] : "",
      business_category_id: json["business_category_id"] != null ? json["business_category_id"] : "",
      coupons: json["coupons"] == ""
          ? null
          : List<Coupon>.from(json["coupons"].map((x) => Coupon.fromJson(x))));

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": first_name,
        "business_category_name": business_category_name,
        "totalCoupon": totalCoupon,
        "image_path": image_path,
        "business_name": business_name,
        "close_time": close_time,
        "open_time": open_time,
        "rate": rate,
        "address": address,
        "mobile_no": mobile_no,
        "about_business": about_business,
        "email_address": email_address,
        "business_contact_no": business_contact_no,
        "business_area": business_area,
        "business_landmark": business_landmark,
        "business_category_id": business_category_id,
        "coupons":
            coupons == "" ? null : List<dynamic>.from(coupons.map((x) => x)),
      };
}
