class AppwriteConstants {
  static const String databaseId = "642672351f3d5edc667e";
  static const String projectId = "64266ce0503a043f2e0b";
  static const String endPoint = "http://localhost:80/v1";

  static const String userCollection = "6427e910230e0149f35f";
  static const String tweetCollection = "64311dc4a52e600b64be";
  static const String imagesBucket = "643128aeab4416efd54b";

  static String imageUrl(String imageId) =>
      '$endPoint/storage/buckets/$imagesBucket/files/$imageId/view?project=$projectId&mode=admin';
}
