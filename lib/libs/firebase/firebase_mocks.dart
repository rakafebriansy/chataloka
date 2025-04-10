import 'package:cloud_firestore/cloud_firestore.dart';

class QuerySnapshotMock implements QuerySnapshot {
  @override
  List<QueryDocumentSnapshot> get docs => [];

  @override
  SnapshotMetadata get metadata => SnapshotMetadataMock();

  @override
  int get size => 0;

  @override
  List<DocumentChange> get docChanges => [];
}

class SnapshotMetadataMock implements SnapshotMetadata {
  @override
  bool get hasPendingWrites => false;

  @override
  bool get isFromCache => false;
}