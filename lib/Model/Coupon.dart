import 'package:html/dom.dart';

class Coupon {
  String title;
  String id;
  String expiery_date;
  String used_date;
  String used_at;
  String description;
  String start_date;
  String used_count;
  String business_category_name;
  String isActive;

  Coupon(
      {this.id,
      this.title,
      this.expiery_date,
      this.description,
      this.used_date,
      this.used_at,
      this.start_date,
      this.used_count,
      this.business_category_name,
      this.isActive});

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        id: json["id"] != null ? json["id"] : "",
        title: json["title"] != null ? json["title"] : "",
        description: json["description"] != null ? json["description"] : "",
        start_date:
            json["start_date_format"] != null ? json["start_date_format"] : "",
        expiery_date: json["expiry_date_format"] != null
            ? json["expiry_date_format"]
            : "",
        used_count: json["total_used_count"].toString() != null
            ? json["total_used_count"].toString()
            : "",
        business_category_name: json["business_category_name"] != null
            ? json["business_category_name"]
            : "",
        isActive: json["isActive"] != null ? json["isActive"] : "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "expiery_date": expiery_date,
        "description": description,
        "start_date": start_date,
        "used_count": used_count,
        "business_category_name": business_category_name,
        "isActive": isActive,
      };
}

class CouponDetail {
  final String title;
  final String id;
  final String expiery_date;
  final String used_date;
  final String used_at;
  final String description;
  final String start_date;
  final String vendor_name;
  final String business_category_name;
  final String vendor_email_address;
  final String vendor_mobile_no;
  final String vendor_business_name;
  final String used_count;

  factory CouponDetail.fromJson(Map<String, dynamic> json) => CouponDetail(
        id: json["id"] != null ? json["id"] : "",
        title: json["title"] != null ? json["title"] : "",
        description: json["description"] != null ? json["description"] : "",
        start_date:
            json["start_date_format"] != null ? json["start_date_format"] : "",
        expiery_date: json["expiry_date_format"] != null
            ? json["expiry_date_format"]
            : "",
        vendor_name: json["vendor_name"] != null ? json["vendor_name"] : "",
        business_category_name: json["business_category_name"] != null
            ? json["business_category_name"]
            : "",
        vendor_email_address: json["vendor_email_address"] != null
            ? json["vendor_email_address"]
            : "",
        vendor_mobile_no:
            json["vendor_mobile_no"] != null ? json["vendor_mobile_no"] : "",
        vendor_business_name: json["vendor_business_name"] != null
            ? json["vendor_business_name"]
            : "",
        used_count: json["used_count"] != null ? json["used_count"] : "",
      );

  CouponDetail({
    this.id,
    this.title,
    this.expiery_date,
    this.description,
    this.used_date,
    this.used_at,
    this.start_date,
    this.vendor_name,
    this.business_category_name,
    this.vendor_email_address,
    this.vendor_mobile_no,
    this.vendor_business_name,
    this.used_count,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "expiery_date": expiery_date,
        "description": description,
        "start_date": start_date,
        "vendor_name": vendor_name,
        "business_category_name": business_category_name,
        "vendor_email_address": vendor_email_address,
        "vendor_mobile_no": vendor_mobile_no,
        "vendor_business_name": vendor_business_name,
        "used_count": used_count,
      };
}

class UsedCouponModel {
  String title;
  String id;
  String used_date;
  String used_at;
  String description;
  String vendor_id;
  String business_category_name;
  String customer_name;
  String bill_amount;

  UsedCouponModel({
    this.id,
    this.title,
    this.description,
    this.used_date,
    this.used_at,
    this.vendor_id,
    this.business_category_name,
    this.customer_name,
    this.bill_amount,
  });

  factory UsedCouponModel.fromJson(Map<String, dynamic> json) =>
      UsedCouponModel(
        id: json["id"] != null ? json["id"] : "",
        title: json["coupon_name"] != null ? json["coupon_name"] : "",
        description: json["description"] != null ? json["description"] : "",
        used_date: json["used_date"] != null ? json["used_date"] : "",
        used_at: json["business_name"] != null ? json["business_name"] : "",
        vendor_id: json["vendor_id"] != null ? json["vendor_id"] : "",
        business_category_name: json["business_category_name"] != null
            ? json["business_category_name"]
            : "",
        customer_name: json["user_name"] != null ? json["user_name"] : "",
        bill_amount: json["bill_amount"] != null ? json["bill_amount"] : "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "used_date": used_date,
        "description": description,
        "used_at": used_at,
        "vendor_id": vendor_id,
        "business_category_name": business_category_name,
        "customer_name": customer_name,
        "bill_amount": bill_amount,
      };
}
