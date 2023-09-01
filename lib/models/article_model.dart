class ArticleModel {
  String articleAuthor, articleDepartment, articleDescription, articleImage, articlePublished, articleTitle;

  ArticleModel({
    required this.articleAuthor,
    required this.articleDepartment,
    required this.articleDescription,
    required this.articleImage,
    required this.articlePublished,
    required this.articleTitle,
  });

  static ArticleModel fromMap(Map<dynamic, dynamic> map) {
    return ArticleModel(
      articleAuthor: map['ArticleAuthor'],
      articleDepartment: map['ArticleDepartment'],
      articleDescription: map['ArticleDescription'],
      articleImage: map['ArticleImage'],
      articlePublished: map['ArticlePublished'],
      articleTitle: map['ArticleTitle'],
    );
  }
}
