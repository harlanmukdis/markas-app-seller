import '../../../utils/json_parse.dart';

/// A node of `GET /categories`.
///
/// The endpoint returns a tree: level-0 parents each carrying `children`.
/// Both levels are accepted as a product's `category_id`, so the picker offers
/// all of them rather than forcing a leaf.
///
/// **Ids are not stable.** The seed has been rebuilt more than once and every id
/// moved with it, so nothing may persist a category id as a default or a
/// constant — read the tree and match on what comes back.
class Category {
  const Category({
    required this.id,
    required this.name,
    this.parentId,
    this.slug,
    this.iconUrl,
    this.level = 0,
    this.sortOrder = 0,
    this.isActive = true,
    this.children = const <Category>[],
  });

  final int id;
  final String name;
  final int? parentId;
  final String? slug;
  final String? iconUrl;
  final int level;
  final int sortOrder;
  final bool isActive;
  final List<Category> children;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: asInt(json['id']),
        name: asString(json['name']),
        parentId: asIntOrNull(json['parent_id']),
        slug: asStringOrNull(json['slug']),
        iconUrl: asStringOrNull(json['icon_url']),
        level: asInt(json['level']),
        sortOrder: asInt(json['sort_order']),
        isActive: asBool(json['is_active'], fallback: true),
        children: asModelList(json['children'], Category.fromJson),
      );

  bool get hasChildren => children.isNotEmpty;
}

/// One row of a picker: every node of [tree], depth-first, parents before their
/// own children, each paired with the parent name so "Sepatu Pria" and "Sepatu
/// Wanita" are told apart in a flat list.
class CategoryOption {
  const CategoryOption({
    required this.category,
    this.parentName,
  });

  final Category category;
  final String? parentName;

  int get id => category.id;

  String get label =>
      parentName == null ? category.name : '$parentName › ${category.name}';
}

List<CategoryOption> flattenCategories(List<Category> tree) {
  final options = <CategoryOption>[];

  void walk(List<Category> nodes, String? parentName) {
    for (final node in nodes) {
      if (!node.isActive) continue;
      options.add(CategoryOption(category: node, parentName: parentName));
      walk(node.children, node.name);
    }
  }

  walk(tree, null);
  return options;
}
