// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:tasklist_backend/hash_extension.dart';

part 'item_repository.g.dart';

@visibleForTesting
// Datasource - in-mem cache
Map<String, TaskItem> itemDB = {};

// Equatble helps compare 2 Tasklist objects for equality
@JsonSerializable()
class TaskItem extends Equatable {
  const TaskItem({
    required this.id,
    required this.listid,
    required this.name,
    required this.description,
    required this.status,
  });

  // deserialization - json data to string
  factory TaskItem.fromJson(Map<String, dynamic> json) =>
      _$TaskItemFromJson(json);

  final String id;
  final String listid;
  final String name;
  final String description;
  final bool status;

  // serialization - string data to json format
  Map<String, dynamic> toJson() => _$TaskItemToJson(this);

  TaskItem copywith({
    String? id,
    String? listid,
    String? name,
    String? description,
    bool? status,
  }) {
    return TaskItem(
      id: id ?? this.id,
      listid: listid ?? this.listid,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, name];
}

// Repository class for TaskItem
class TaskItemRepository {
  // Check in the internal data source for a item with given id
  Future<TaskItem?> itemById(String id) async {
    return itemDB[id];
  }

  // Get all items from the internal data source
  Map<String, dynamic> getAllItems() {
    final formatedLists = <String, dynamic>{};

    if (itemDB.isNotEmpty) {
      itemDB.forEach(
        (String id) {
          final currentList = itemDB[id];
          formatedLists[id] = currentList?.toJson();
        } as void Function(String key, TaskItem value),
      );
    }

    return formatedLists;
  }

  // Create a new item from given information
  String createItem({
    required String name,
    required String description,
    required String listid,
    required bool status,
  }) {
    // dynamically generates id
    final id = name.hashValue;

    // create our new TaskList object and passing all parameters
    final item = TaskItem(
      id: id,
      name: name,
      description: description,
      listid: listid,
      status: status,
    );

    // add a new TaskList object to our data source
    itemDB[id] = item;

    return id;
  }

  // Delete a TaskItem object with given id
  void deleteItem(String id) {
    itemDB.remove(id);
  }

  // Update operation
  Future<void> updateItem(
    String id, {
    required String name,
    required String listid,
    required String description,
    required bool status,
  }) async {
    final currentItem = itemDB[id];

    if (currentItem == null) {
      return Future.error(Exception('List not found'));
    }

    itemDB[id] = TaskItem(
      id: id,
      name: name,
      description: description,
      listid: listid,
      status: status,
    );
  }
}
