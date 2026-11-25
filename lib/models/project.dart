import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    this.id,
    required this.title,
    required this.category,
    required this.shortDescription,
    required this.fullDescription,
    required this.tags,
    this.imageUrl = '',
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String category;
  final String shortDescription;
  final String fullDescription;
  final String tags;
  @JsonKey(defaultValue: '')
  final String imageUrl;

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
