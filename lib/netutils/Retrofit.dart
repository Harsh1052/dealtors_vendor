library flutter_images.globals;

import 'package:http/http.dart' as http;

String url = 'http://24.24.25.48/dealtors/service/';
//String url = 'http://craftbox.in/demo/dealtors/service/';
//String url = 'http://admin.onemegaconcept.com/service/';
String image = 'http://admin.onemegaconcept.com/images/no_image.png';

String secure_field = "key";
String secure_value = "1226";
String secure_service = "s";

signup(String name, String email, String mobile_no, String otp) {
  return http.post(
      url +
          "service_user.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "2",
      body: {
        'appFlag': "1",
        'first_name': name,
        'email_address': email,
        'mobile_no': mobile_no,
        'otp': otp,
      });
}

editProfile(String id, String name, String email, String mobile_no) {
  print(url +
      "service_vendor.php?" +
      secure_field +
      "=" +
      secure_value +
      "&" +
      secure_service +
      "=" +
      "30" +
      '&id=' +
      id +
      '&first_name=' +
      name +
      '&email_address=' +
      email +
      '&mobile_no=' +
      mobile_no);
  return http.post(
      url +
          "service_vendor.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "30",
      body: {
        'id': id,
        'first_name': name,
        'email_address': email,
        'mobile_no': mobile_no,
        'appFlag': "1"
      });
}

editBussiness(
    String id,
    String name,
    String email,
    String mobile_no,
    String business_category_id,
    String business_name,
    String about_business,
    String business_contact_no,
    String business_location,
    String business_area,
    String business_landmark,
    String opening_time,
    String closing_time,
    String morningOpenTime,
    String morningCloseTime,
    String eveningOpenTime,
    String eveningCloseTime,
    bool split) {
  print(url +
      "service_user.php?" +
      secure_field +
      "=" +
      secure_value +
      "&" +
      secure_service +
      "=" +
      "3" +
      "&id=" +
      id +
      '&first_name=' +
      name +
      '&email_address=' +
      email +
      '&mobile_no=' +
      mobile_no +
      '&business_category_id=' +
      business_category_id +
      '&business_name=' +
      business_name +
      '&about_business=' +
      about_business +
      '&business_contact_no=' +
      business_contact_no +
      '&business_location=' +
      business_location +
      '&business_area=' +
      business_area +
      '&business_landmark=' +
      business_landmark +
      '&opening_time=' +
      opening_time +
      '&closing_time=' +
      closing_time +
      morningOpenTime +
      morningCloseTime +
      eveningOpenTime +
      eveningCloseTime);
  return http.post(
      url +
          "service_user.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "3",
      body: {
        'id': id,
        'first_name': name,
        'email_address': email,
        'mobile_no': mobile_no,
        'business_category_id': business_category_id,
        'business_name': business_name,
        'about_business': about_business,
        'business_contact_no': business_contact_no,
        'business_location': business_location,
        'business_area': business_area,
        'business_landmark': business_landmark,
        'opening_time': split ? morningOpenTime : opening_time,
        'closing_time': split ? morningCloseTime : closing_time,
        'opening_time_evening': eveningOpenTime ?? "",
        'closing_time_evening': eveningCloseTime ?? "",
        'appFlag': "1",
        'time_split_flag': split ? '1' : '0',
      });
}

editBussinessWithImage(
    String id,
    String name,
    String email,
    String mobile_no,
    String business_category_id,
    String business_name,
    String about_business,
    String business_contact_no,
    String business_location,
    String business_area,
    String business_landmark,
    String opening_time,
    String closing_time,
    String image_path,
    String morningOpenTime,
    String morningCloseTime,
    String eveningOpenTime,
    String eveningCloseTime,
    bool split) {
  print(morningOpenTime);
  print(morningCloseTime);
  print(eveningCloseTime);
  print(eveningOpenTime);
  print(url +
      "service_user.php?" +
      secure_field +
      "=" +
      secure_value +
      "&" +
      secure_service +
      "=" +
      "3" +
      "&id=" +
      id +
      '&first_name=' +
      name +
      '&email_address=' +
      email +
      '&mobile_no=' +
      mobile_no +
      '&business_category_id=' +
      business_category_id +
      '&business_name=' +
      business_name +
      '&about_business=' +
      about_business +
      '&business_contact_no=' +
      business_contact_no +
      '&business_location=' +
      business_location +
      '&business_area=' +
      business_area +
      '&business_landmark=' +
      business_landmark +
      '&opening_time=' +
      opening_time +
      '&closing_time=' +
      closing_time +
      morningOpenTime +
      morningCloseTime +
      eveningOpenTime +
      eveningCloseTime);
  return http.post(
      url +
          "service_user.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "3",
      body: {
        'id': id,
        'first_name': name,
        'email_address': email,
        'mobile_no': mobile_no,
        'business_category_id': business_category_id,
        'business_name': business_name,
        'about_business': about_business,
        'business_contact_no': business_contact_no,
        'business_location': business_location,
        'business_area': business_area,
        'business_landmark': business_landmark,
        'opening_time': split ? morningOpenTime : opening_time,
        'closing_time': split ? morningCloseTime : closing_time,
        'opening_time_evening': eveningOpenTime ?? "",
        'closing_time_evening': eveningCloseTime ?? "",
        'image_path': image_path,
        'appFlag': "1",
        'time_split_flag': split ? '1' : '0',
      });
}

login(String mobile_no, String otp) {
  return http.post(
      url +
          "service_vendor.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "21",
      body: {'mobile_no': mobile_no, 'otp': otp, 'appFlag': "1"});
}

sendOtpForLogin(String mobile_no) {
  return http.post(
      url +
          "service_vendor.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "20",
      body: {'mobile_no': mobile_no, 'appFlag': "1"});
}

getbanner(String uid) {
  return http.post(
      url +
          "service_vendor.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "27",
      body: {'vendor_id': uid, 'appFlag': "1"});
}

checkVendorStatus(String uid) {
  print(url +
      "service_vendor.php?" +
      secure_field +
      "=" +
      secure_value +
      "&" +
      "vendor_id" +
      uid +
      "appFlag" +
      "1" +
      secure_service +
      "=" +
      "23");
  return http.post(
      url +
          "service_vendor.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "23",
      body: {
        'vendor_id': uid,
        'appFlag': "1",
      });
}

getCategory(String uid /*,String ll,String ul*/) {
  print(url +
      "service_user.php?" +
      secure_field +
      "=" +
      secure_value +
      "&" +
      secure_service +
      "=" +
      "10" +
      '&appFlag=1' /*+'&ll='+ll+'&ul='+ul*/);
  return http.post(
      url +
          "service_user.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "10",
      body: {
        'uid': uid,
        'appFlag': "1" /* ,'ll':ll,'ul':ul*/
      });
}

getLiveCoupon(String uid, String ll, String ul) {
  print(url +
      "service_user.php?" +
      secure_field +
      "=" +
      secure_value +
      "&" +
      secure_service +
      "=" +
      "11" +
      "&appFlag=1&flag=1&vendor_id=" +
      uid +
      "&ll=" +
      ll +
      "&ul=" +
      ul);
  return http.post(
      url +
          "service_user.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "11",
      body: {
        'appFlag': "1",
        'vendor_id': uid,
        'flag': "1",
        'll': ll,
        'ul': ul
      });
}

getDisableCoupon(String uid, String ll, String ul) {
  print(url +
      "service_user.php?" +
      secure_field +
      "=" +
      secure_value +
      "&" +
      secure_service +
      "=" +
      "11" +
      "&appFlag=1&flag=2&vendor_id=" +
      uid +
      "&ll=" +
      ll +
      "&ul=" +
      ul);
  return http.post(
      url +
          "service_user.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "11",
      body: {
        'appFlag': "1",
        'vendor_id': uid,
        'flag': "2",
        'll': ll,
        'ul': ul
      });
}

getExpireCoupon(String uid, String ll, String ul) {
  return http.post(
      url +
          "service_user.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "11",
      body: {
        'appFlag': "1",
        'vendor_id': uid,
        'flag': "3",
        'll': ll,
        'ul': ul
      });
}

addCoupon(String uid, String title, String des, String start_date,
    String expiry_date) {
  print(url +
      "service_user.php?" +
      secure_field +
      "=" +
      secure_value +
      "&" +
      secure_service +
      "=" +
      "13" +
      '&appFlag=' +
      "1" +
      '&vendor_id=' +
      uid +
      '&title=' +
      title +
      '&description=' +
      des +
      '&start_date=' +
      start_date +
      '&expiry_date=' +
      expiry_date);
  return http.post(
      url +
          "service_user.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "13",
      body: {
        'appFlag': "1",
        'vendor_id': uid,
        'title': title,
        'description': des,
        'start_date': start_date,
        'expiry_date': expiry_date
      });
}

editCoupon(String uid, String title, String des, String start_date,
    String expiry_date, String id) {
  print(url +
      "service_user.php?" +
      secure_field +
      "=" +
      secure_value +
      "&" +
      secure_service +
      "=" +
      "14" +
      '&appFlag=1' +
      '&id=' +
      id +
      '&vendor_id=' +
      uid +
      '&title=' +
      title +
      '&description=' +
      des +
      '&start_date=' +
      start_date +
      '&expiry_date=' +
      expiry_date);

  return http.post(
      url +
          "service_user.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "14",
      body: {
        'appFlag': "1",
        'id': id,
        'vendor_id': uid,
        'title': title,
        'description': des,
        'start_date': start_date,
        'expiry_date': expiry_date
      });
}

deleteCoupon(String id) {
  print(url +
      "service_user.php?" +
      secure_field +
      "=" +
      secure_value +
      "&" +
      secure_service +
      "=" +
      "28" +
      "&id=" +
      id);
  return http.post(
      url +
          "service_user.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "28",
      body: {'id': id});
}

getVendor(String id) {
  print(url +
      "service_user.php?" +
      secure_field +
      "=" +
      secure_value +
      "&" +
      secure_service +
      "=" +
      "5" +
      'id=$id&appFlag=1');
  return http.post(
      url +
          "service_user.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "5",
      body: {'id': id, 'appFlag': "1"});
}

getCouponDetail(String user_id, String coupon_id) {
  return http.post(
      url +
          "service_user.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "11",
      body: {'user_id': user_id, 'id': coupon_id, 'appFlag': "1"});
}

aboutUs(String user_id) {
  return http.post(
      url +
          "service_vendor.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "22",
      body: {'user_id': user_id, 'appFlag': "1"});
}

verifyCoupon(String user_id, String coupon_code, String bill_amount) {
  print(url +
      "service_general.php?" +
      secure_field +
      "=" +
      secure_value +
      "&" +
      secure_service +
      "=" +
      "18" +
      '&vendor_id=' +
      user_id +
      '&coupon_code=' +
      coupon_code +
      '&bill_amount=' +
      bill_amount);
  return http.post(
      url +
          "service_general.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "18",
      body: {
        'vendor_id': user_id,
        'coupon_code': coupon_code,
        'bill_amount': bill_amount,
        'appFlag': "1"
      });
}

getUsedCoupon(String user_id, String ll, String ul) {
  return http.post(
      url +
          "service_general.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "19",
      body: {
        'vendor_id': user_id,
        'isUsed': "1",
        'll': ll,
        'ul': ul,
        'appFlag': "1"
      });
}

getReview(String user_id, String ll, String ul) {
  return http.post(
      url +
          "service_vendor.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "26",
      body: {'vendor_id': user_id, 'll': ll, 'ul': ul, 'appFlag': "1"});
}

couponStatus(String user_id, coupon_id, String status) {
  return http.post(
      url +
          "service_vendor.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "29",
      body: {
        'vendor_id': user_id,
        'id': coupon_id,
        'status': status,
        'appFlag': "1"
      });
}

getContury() {
  return http.post(
      url +
          "service_user.php?" +
          secure_field +
          "=" +
          secure_value +
          "&" +
          secure_service +
          "=" +
          "31",
      body: {});
}
