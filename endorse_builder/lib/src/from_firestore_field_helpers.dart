import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import 'package:endorse/annotations.dart';

import 'package:loose_builder/src/loose_builder_exception.dart';
import 'package:loose_builder/src/recase_helper.dart';

final _checkForLooseDocument = const TypeChecker.fromRuntime(LooseDocument);
final _checkForLooseMap = const TypeChecker.fromRuntime(LooseMap);
final _checkForLooseField = const TypeChecker.fromRuntime(LooseField);

Iterable<DartType> _getGenericTypes(DartType type) {
  return type is ParameterizedType ? type.typeArguments : const [];
}

String convertFromFirestore(ClassElement clazz, int recase, bool globalAllowNulls, bool globalReadonlyNulls, {String parent = '', int nestLevel = 0, bool inList = false}) {
  
  final classBuffer = StringBuffer();

  final classElements = <ClassElement>[];
    classElements.add(clazz);
    for (final superType in clazz.allSupertypes) {
      if (superType.element is ClassElement) {
        classElements.add(superType.element);
      }
    }
  
  for (final klass in classElements) {
    for (final field in klass.fields) {

      if (field.isStatic || field.isSynthetic) {
        continue;
      }

      var dbname = field.name;
      dbname = recaseFieldName(recase, dbname);
      var allowNull = globalAllowNulls || globalReadonlyNulls;

      if (_checkForLooseField.hasAnnotationOfExact(field)) {
        final reader = ConstantReader(_checkForLooseField.firstAnnotationOf(field));
        
        final ignore = reader.peek('ignore')?.boolValue ?? false;
        if (ignore) {
          continue;
        }
        
        if ((reader.peek('ignoreIfNested')?.boolValue ?? false) && nestLevel > 0) {
          continue;
        }

        if ((reader.peek('ignoreInLists')?.boolValue ?? false) && inList) {
          continue;
        }
        
        final rename = reader.peek('name')?.stringValue ?? '';
        if (rename.isNotEmpty) {
          dbname = rename;
        }
        final readNull = reader.peek('readNulls')?.boolValue;
        allowNull = (reader.peek('allowNull')?.boolValue ?? readNull) ?? globalAllowNulls;
      }
      
      String displayName;
      if (parent.isEmpty) {
        displayName = '${field.name}';
      } else {
        displayName = '$parent.${field.name}';
      }
      

      String mode = '';
      if (allowNull) {
        mode = ', allowNull: true';
      }

      if (field.type.isDartCoreString) {
        classBuffer.writeln("..${field.name} = FromFs.string(m['${dbname}'], name: '${displayName}'$mode)");
      } else if (field.type.isDartCoreInt) {
        classBuffer.writeln("..${field.name} = FromFs.integer(m['${dbname}'], name: '${displayName}'$mode)");
      } else if (field.type.isDartCoreDouble) {
        classBuffer.writeln("..${field.name} = FromFs.float(m['${dbname}'], name: '${displayName}'$mode)");
      } else if (field.type.isDartCoreBool) {
        classBuffer.writeln("..${field.name} = FromFs.boolean(m['${dbname}'], name: '${displayName}'$mode)");
      } else if (field.type.getDisplayString() == 'DateTime') {
        classBuffer.writeln("..${field.name} = FromFs.datetime(m['${dbname}'], name: '${displayName}'$mode)");
      } else if (field.type.getDisplayString() == 'Reference') {
        classBuffer.writeln("..${field.name} = FromFs.reference(m['${dbname}'], name: '${displayName}'$mode)");
      
      // Map
      } else if (_checkForLooseMap.hasAnnotationOfExact(field.type.element)
      || _checkForLooseDocument.hasAnnotationOfExact(field.type.element)) {
        if (field.type.element is! ClassElement) {
          throw LooseBuilderException('LooseDocument or LooseMap must only annotate classes. Field "${field.name}" is not a class.');
        }

        var childAllowNulls = false;
        var childReadonlyNulls = false;
        if (_checkForLooseDocument.hasAnnotationOfExact(field.type.element)) {
          final reader = ConstantReader(_checkForLooseDocument.firstAnnotationOf(field.type.element));
          final thisAllowNulls = reader.peek('allowNulls')?.boolValue ?? false;
          final thisReadonlyNulls = reader.peek('readonlyNulls')?.boolValue ?? false;
          childAllowNulls = thisAllowNulls ? true : allowNull;
          childReadonlyNulls = thisReadonlyNulls ? true : allowNull;
          nestLevel = nestLevel + 1;
        }

        if (_checkForLooseMap.hasAnnotationOfExact(field.type.element)) {
          final reader = ConstantReader(_checkForLooseMap.firstAnnotationOf(field.type.element));
          final thisAllowNulls = reader.peek('allowNulls')?.boolValue ?? false;
          final thisReadonlyNulls = reader.peek('readonlyNulls')?.boolValue ?? false;
          childAllowNulls = thisAllowNulls ? true : allowNull;
          childReadonlyNulls = thisReadonlyNulls ? true : allowNull;
        }

        final mapBuf = StringBuffer();
        mapBuf.writeln("..${field.name} = FromFs.map(m['${dbname}'], (m) => ${field.type.getDisplayString()}()");
        mapBuf.writeln('${convertFromFirestore(field.type.element, recase, childAllowNulls, childReadonlyNulls, parent: displayName, nestLevel: nestLevel)}');
        mapBuf.writeln(", name: '${displayName}'$mode)");
        classBuffer.write(mapBuf.toString());
      
      // List
      } else if (field.type.isDartCoreList) {
        final elementTypes = _getGenericTypes(field.type);
        if (elementTypes.isEmpty) {
          throw LooseBuilderException('The element type of ${field.name} should be specified.');
        }
        if (elementTypes.first.isDartCoreList) {
          throw LooseBuilderException('Cannot nest a list within the list ${field.name}.');
        }
        if (elementTypes.first.isDartCoreMap) {
          throw LooseBuilderException('Maps within the list ${field.name} must be implemented by using a class annotated with @LooseMap');
        }
        final elementType = elementTypes.first;
        final listBuf = StringBuffer();
        listBuf.write("..${field.name} = FromFs.list(m['${field.name}'], ");
        if (elementType.isDartCoreString) {
          listBuf.write('(e) => FromFs.string(e, allowNull: true)');
        } else if (elementType.isDartCoreInt) {
          listBuf.write('(e) => FromFs.integer(e, allowNull: true)');
        } else if (elementType.isDartCoreDouble) {
          listBuf.write('(e) => FromFs.float(e, allowNull: true)');
        } else if (elementType.isDartCoreBool) {
          listBuf.write('(e) => FromFs.boolean(e, allowNull: true)');
        } else if (elementType.getDisplayString() == 'DateTime') {
          listBuf.write('(e) => FromFs.datetime(e, allowNull: true)');
        } else if (elementType.getDisplayString() == 'Reference') {
          listBuf.write('(e) => FromFs.reference(e, allowNull: true)');
        } else if (_checkForLooseMap.hasAnnotationOfExact(elementType.element)
          || _checkForLooseDocument.hasAnnotationOfExact(elementType.element)) {
          if (elementType.element is! ClassElement) {
            throw LooseBuilderException('LooseDocument or LooseMap must only annotate classes. Field "${field.name}" is not a class.');
          }

          var childAllowNulls = false;
          var childReadonlyNulls = false;
          if (_checkForLooseDocument.hasAnnotationOfExact(field.type.element)) {
            final reader = ConstantReader(_checkForLooseDocument.firstAnnotationOf(field.type.element));
            final thisAllowNulls = reader.peek('allowNulls')?.boolValue ?? false;
            final thisReadonlyNulls = reader.peek('readonlyNulls')?.boolValue ?? false;
            childAllowNulls = thisAllowNulls ? true : allowNull;
            childReadonlyNulls = thisReadonlyNulls ? true : allowNull;
          }

          if (_checkForLooseMap.hasAnnotationOfExact(field.type.element)) {
            final reader = ConstantReader(_checkForLooseMap.firstAnnotationOf(field.type.element));
            final thisAllowNulls = reader.peek('allowNulls')?.boolValue ?? false;
            final thisReadonlyNulls = reader.peek('readonlyNulls')?.boolValue ?? false;
            childAllowNulls = thisAllowNulls ? true : allowNull;
            childReadonlyNulls = thisReadonlyNulls ? true : allowNull;
          }

          listBuf.write("(e) => FromFs.map(e, (m) => ${elementType.getDisplayString()}()");
          listBuf.writeln('${convertFromFirestore(elementType.element, recase, childAllowNulls, childReadonlyNulls, nestLevel: 0, inList: true)}');
          listBuf.write(", name: '${displayName}'$mode)");
        }
        listBuf.writeln(')');
        classBuffer.writeln(listBuf.toString());
      }
    }
    // print(classBuffer);
    return classBuffer.toString();
  }
}