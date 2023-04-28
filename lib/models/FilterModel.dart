// To parse this JSON data, do
//
//     final filterModel = filterModelFromJson(jsonString);

import 'dart:convert';

FilterModel filterModelFromJson(String str) => FilterModel.fromJson(json.decode(str));

String filterModelToJson(FilterModel data) => json.encode(data.toJson());

class FilterModel {
  FilterModel({
    required this.appliedFilter,
    required this.filterKey,
    required this.filterTitle,
  });

  List<AppliedFilter> appliedFilter;
  String filterKey;
  String filterTitle;

  factory FilterModel.fromJson(Map<String, dynamic> json) => FilterModel(
    appliedFilter: List<AppliedFilter>.from(json["applied_filter"].map((x) => AppliedFilter.fromJson(x))),
    filterKey: json["filter_key"],
    filterTitle: json["filter_title"],
  );

  Map<String, dynamic> toJson() => {
    "applied_filter": List<dynamic>.from(appliedFilter.map((x) => x.toJson())),
    "filter_key": filterKey,
    "filter_title": filterTitle,
  };
}

class AppliedFilter {
  AppliedFilter({
    required this.filterTitle,
    required this.filterKey,
  });

  String filterTitle;
  String filterKey;

  factory AppliedFilter.fromJson(Map<String, dynamic> json) => AppliedFilter(
    filterTitle: json["filter_title"],
    filterKey: json["filter_key"],
  );

  Map<String, dynamic> toJson() => {
    "filter_title": filterTitle,
    "filter_key": filterKey,
  };
}
