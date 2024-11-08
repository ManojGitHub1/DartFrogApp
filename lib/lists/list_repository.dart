// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:tasklist_backend/hash_extension.dart';

part 'list_repository.g.dart';

@visibleForTesting
// Datasource - in-mem cache
Map<String, TaskList> listDB = {};

// Equatble helps compare 2 Tasklist objects for equality
@JsonSerializable()
class TaskList extends Equatable {
  const TaskList({required this.id, required this.name});

  // deserialization - json data to string
  factory TaskList.fromJson(Map<String, dynamic> json) =>
      _$TaskListFromJson(json);

  final String id;
  final String name;

  // serialization - string data to json format
  Map<String, dynamic> toJson() => _$TaskListToJson(this);

  TaskList copywith({
    String? id,
    String? name,
  }) {
    return TaskList(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  List<Object?> get props => [id, name];
}

// Repository class for TaskList
class TaskListRepository {
  // Check in the internal data source for a list with given id
  Future<TaskList?> listById(String id) async {
    return listDB[id];
  }

  // Get all lists from the internal data source
  Map<String, dynamic> getAllLists() {
    final formatedLists = <String, dynamic>{};

    if (listDB.isNotEmpty) {
      listDB.forEach(
        (String id) {
          final currentList = listDB[id];
          formatedLists[id] = currentList?.toJson();
        } as void Function(String key, TaskList value),
      );
    }

    return formatedLists;
  }

  // Create a new list from given name
  String createList({required String name}) {
    // dynamically generates id
    final id = name.hashValue;

    // create our new TaskList object and pass our 2 parameters
    final list = TaskList(id: id, name: name);

    // add a new TaskList object to our data source
    listDB[id] = list;

    return id;
  }

  // Delete a TaskList object with given id
  void deleteList(String id) {
    listDB.remove(id);
  }

  // Update operation
  Future<void> updateList(String id, {required String name}) async {
    final currentList = listDB[id];

    if (currentList == null) {
      return Future.error(Exception('List not found'));
    }

    listDB[id] = TaskList(id: id, name: name);
  }
}
