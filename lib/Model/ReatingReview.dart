class ReatingReview {
   String user_name;
   String review_date;
   String rate;
   String review;
   String image_path;
   String id;

  ReatingReview({
    this.id,
    this.user_name,
    this.review_date,
    this.rate,
    this.review,
    this.image_path,
  });

  factory ReatingReview.fromJson(Map<String, dynamic> json) => ReatingReview(
        id: json["id"],
        user_name: json["user_name"],
        review_date:
            json["review_date"] != null ? json["review_date"].toString() : "",
        image_path: json["image_path"],
        rate: json["rate"] != null ? json["rate"].toString() : "",
        review: json["review"] != null ? json["review"].toString() : "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_name": user_name,
        "review_date": review_date,
        "image_path": image_path,
        "rate": rate,
        "review": review,
      };
}
