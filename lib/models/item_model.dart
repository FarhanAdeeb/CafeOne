class ItemModel {
  String? itemId;
  String? itemName;
  String? itemPrice;
  String? itemPic;
  bool isAvailable = true;

  ItemModel({
    this.itemId,
    this.itemName,
    this.itemPrice,
    this.itemPic,
  });

  ItemModel.fromMap(Map<String, dynamic> map) {
    itemId = map["itemId"];
    itemName = map["itemName"];
    itemPrice = map["itemPrice"];
    itemPic = map["itemPic"];
    isAvailable = map["isAvailable"];
  }

  Map<String, dynamic> toMap() {
    return {
      "itemId": itemId,
      "itemName": itemName,
      "itemPrice": itemPrice,
      "itemPic": itemPic,
      "isAvailable": isAvailable,
    };
  }
}
