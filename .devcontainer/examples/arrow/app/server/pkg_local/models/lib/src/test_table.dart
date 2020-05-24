import 'package:stanza/annotations.dart';
import 'package:stanza/stanza.dart';

part 'test_table.g.dart';

@StanzaEntity(snakeCase: true)
class TestTable {
  @StanzaField(readOnly: true)
  int id;
  String textField;
  int intField;

  static _$TestTableTable $table = _$TestTableTable();
}